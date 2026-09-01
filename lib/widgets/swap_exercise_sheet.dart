import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../services/exercise_equipment_compatibility.dart';
import '../theme/theme_extensions.dart';
import '../utils/async_pool.dart';
import 'body_heatmap.dart';
import 'localized_exercise_name.dart';

/// Bottom sheet that helps replace the current exercise with a similar one.
///
/// Similarity is based mostly on bodypart and muscle overlap, with a small
/// equipment match bonus. The sheet also exposes the exercise catalog so users
/// can override the recommendations manually when they know exactly what they
/// want.
class SwapExerciseSheet extends StatefulWidget {
  final AppRepository repository;
  final ExerciseDefinition currentDefinition;
  final int? profileId;

  const SwapExerciseSheet({
    super.key,
    required this.repository,
    required this.currentDefinition,
    this.profileId,
  });

  @override
  State<SwapExerciseSheet> createState() => _SwapExerciseSheetState();
}

class _SwapExerciseSheetState extends State<SwapExerciseSheet> {
  static const int _candidateBuildConcurrency = 4;

  late final Future<_SwapExerciseData> _dataFuture;
  int _selectedIndex = 0;
  _ExerciseSwapEntry? _manualReplacement;
  bool _isLoadingManualReplacement = false;
  bool _filterForProfileEquipment = true;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    BodyHeatmap.preload();
    _dataFuture = _loadData();
  }

  /// Loads the current exercise summary and the top replacement candidates.
  Future<_SwapExerciseData> _loadData() async {
    final current = await _buildEntry(widget.currentDefinition);
    final definitions = await _loadCandidateDefinitions(current);
    final profileEquipmentNames = await _loadProfileEquipmentNames();
    final candidates = await _buildCandidateEntries(
      definitions
          .where((definition) => definition.id != widget.currentDefinition.id)
          .toList(),
      current,
    );

    candidates.sort((a, b) => b.score.compareTo(a.score));

    return _SwapExerciseData(
      current: current,
      candidates: candidates,
      profileEquipmentNames: profileEquipmentNames,
      hasProfile: widget.profileId != null,
    );
  }

  Future<Set<String>> _loadProfileEquipmentNames() async {
    final profileId = widget.profileId;
    if (profileId == null) return const <String>{};
    final rows = await widget.repository.fetchEquipmentForProfile(profileId);
    return {
      for (final row in rows)
        if ((row['name'] as String?)?.trim().isNotEmpty ?? false)
          (row['name'] as String).trim().toLowerCase(),
    };
  }

  /// Starts with the tightest bodypart+muscle lookup, then progressively widens
  /// the search so the sheet still has useful options for sparse definitions.
  Future<List<ExerciseDefinition>> _loadCandidateDefinitions(
    _ExerciseSwapEntry current,
  ) async {
    final bodyPartIds = current.bodyPartUnitsById.keys.toList();
    final muscleIds = current.muscleUnitsById.keys.toList();

    var definitions = await widget.repository.lookupDefsFiltered(
      bodypartIds: bodyPartIds.isEmpty ? null : bodyPartIds,
      muscleIds: muscleIds.isEmpty ? null : muscleIds,
    );

    if (definitions.where((def) => def.id != current.definition.id).isEmpty &&
        bodyPartIds.isNotEmpty) {
      definitions = await widget.repository.lookupDefsFiltered(
        bodypartIds: bodyPartIds,
      );
    }

    if (definitions.where((def) => def.id != current.definition.id).isEmpty &&
        muscleIds.isNotEmpty) {
      definitions = await widget.repository.lookupDefsFiltered(
        muscleIds: muscleIds,
      );
    }

    if (definitions.where((def) => def.id != current.definition.id).isEmpty) {
      return widget.repository.lookupDefsDetailed();
    }

    return widget.repository.lookupDefsDetailedByIds(
      definitions.map((definition) => definition.id).toList(),
    );
  }

  /// Hydrates an exercise definition into everything the sheet needs to render
  /// and score it: equipment text, bodypart units, muscle units, and heatmap.
  Future<_ExerciseSwapEntry> _buildEntry(
    ExerciseDefinition definition, {
    bool hydrateDefinition = true,
  }) async {
    final detailedDefinition =
        hydrateDefinition ? await _hydrateDefinition(definition) : definition;
    final bodyPartUnitsFuture = widget.repository.computeBodyPartPercents(
      detailedDefinition.id,
    );
    final muscleRowsFuture = widget.repository.computeMusclePercents(
      detailedDefinition.id,
    );
    final bodyPartUnits = await bodyPartUnitsFuture;
    final muscleRows = await muscleRowsFuture;
    final muscleUnitsById = <int, double>{
      for (final row in muscleRows)
        if (row.percent > 0.0) row.muscleId: row.percent,
    };

    final bodyPartUnitsById = <int, double>{};
    final bodyPartNamesById = <int, String>{};

    for (final entry in bodyPartUnits.entries) {
      if (entry.value <= 0.0) continue;
      bodyPartUnitsById[entry.key.id] = entry.value;
      bodyPartNamesById[entry.key.id] = entry.key.name;
    }

    final maxUnits = bodyPartUnitsById.values.fold<double>(
      0.0,
      (max, units) => units > max ? units : max,
    );
    final frequencyMap = <String, double>{};
    for (final entry in bodyPartUnitsById.entries) {
      final bodyPartName = bodyPartNamesById[entry.key];
      if (bodyPartName == null) continue;
      final svgIds = bodyPartNameToSvgIds[bodyPartName] ?? const <String>[];
      final normalized = maxUnits == 0.0 ? 0.0 : entry.value / maxUnits;
      for (final svgId in svgIds) {
        frequencyMap[svgId] = normalized;
      }
    }

    final bodyPartHits =
        bodyPartUnitsById.entries
            .map(
              (entry) => _BodyPartHit(
                name: bodyPartNamesById[entry.key] ?? 'Bodypart',
                units: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _ExerciseSwapEntry(
      definition: detailedDefinition,
      bodyPartUnitsById: bodyPartUnitsById,
      muscleUnitsById: muscleUnitsById,
      bodyPartHits: bodyPartHits,
      frequencyMap: frequencyMap,
      equipmentText: _equipmentText(detailedDefinition),
    );
  }

  Future<List<_ExerciseSwapEntry>> _buildCandidateEntries(
    List<ExerciseDefinition> definitions,
    _ExerciseSwapEntry current,
  ) async {
    final results =
        await mapWithConcurrency<ExerciseDefinition, _ExerciseSwapEntry?>(
          definitions,
          maxConcurrency: _candidateBuildConcurrency,
          mapper: (definition, _) async {
            final entry = await _buildEntry(
              definition,
              hydrateDefinition: false,
            );
            final score = _similarityScore(current, entry);
            if (score > 0.05) {
              return entry.copyWith(score: score);
            }
            return null;
          },
        );
    return [
      for (final result in results)
        if (result != null) result,
    ];
  }

  Future<ExerciseDefinition> _hydrateDefinition(
    ExerciseDefinition definition,
  ) async {
    final detailed = await widget.repository.fetchDefinitionById(definition.id);
    final hydrated = detailed ?? definition;
    if (hydrated.equipmentList.isNotEmpty) return hydrated;

    final info = await widget.repository.fetchDefinitionInfo(hydrated.id);
    final equipmentName = info['equipmentName']?.trim();
    if (equipmentName == null || equipmentName.isEmpty) return hydrated;

    return ExerciseDefinition(
      id: hydrated.id,
      catalogId: hydrated.catalogId,
      name: hydrated.name,
      equipmentId: hydrated.equipmentId,
      rating: hydrated.rating,
      equipmentList: [Equipment(hydrated.equipmentId ?? -1, equipmentName)],
      bodyParts: hydrated.bodyParts,
      muscles: hydrated.muscles,
      useManualBodyparts: hydrated.useManualBodyparts,
      setupNotes: hydrated.setupNotes,
      executionNotes: hydrated.executionNotes,
      tipsNotes: hydrated.tipsNotes,
      multiplyByRating: hydrated.multiplyByRating,
    );
  }

  /// Scores candidates on a 0-1-ish scale. Bodypart overlap matters most,
  /// muscle overlap refines the match, and equipment is a light tie-breaker.
  double _similarityScore(
    _ExerciseSwapEntry current,
    _ExerciseSwapEntry candidate,
  ) {
    final bodyPartScore = _cosineSimilarity(
      current.bodyPartUnitsById,
      candidate.bodyPartUnitsById,
    );
    final muscleScore = _cosineSimilarity(
      current.muscleUnitsById,
      candidate.muscleUnitsById,
    );
    final equipmentScore = _equipmentSimilarity(
      current.definition,
      candidate.definition,
    );

    return bodyPartScore * 0.55 + muscleScore * 0.35 + equipmentScore * 0.10;
  }

  double _cosineSimilarity(Map<int, double> a, Map<int, double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    var dot = 0.0;
    var aMagnitude = 0.0;
    var bMagnitude = 0.0;

    for (final entry in a.entries) {
      aMagnitude += entry.value * entry.value;
      dot += entry.value * (b[entry.key] ?? 0.0);
    }

    for (final value in b.values) {
      bMagnitude += value * value;
    }

    if (aMagnitude == 0.0 || bMagnitude == 0.0) return 0.0;
    return dot / (math.sqrt(aMagnitude) * math.sqrt(bMagnitude));
  }

  double _equipmentSimilarity(
    ExerciseDefinition current,
    ExerciseDefinition candidate,
  ) {
    final currentNames =
        current.equipmentList
            .map((equipment) => equipment.name.toLowerCase())
            .toSet();
    final candidateNames =
        candidate.equipmentList
            .map((equipment) => equipment.name.toLowerCase())
            .toSet();
    if (currentNames.isEmpty || candidateNames.isEmpty) return 0.0;
    return currentNames.intersection(candidateNames).isNotEmpty ? 1.0 : 0.0;
  }

  void _showPrevious(int count) {
    if (count == 0) return;
    setState(() {
      _manualReplacement = null;
      _selectedIndex = (_selectedIndex - 1 + count) % count;
    });
  }

  void _showNext(int count) {
    if (count == 0) return;
    setState(() {
      _manualReplacement = null;
      _selectedIndex = (_selectedIndex + 1) % count;
    });
  }

  Future<void> _browseExerciseCatalog(_ExerciseSwapEntry current) async {
    final picked = await Navigator.of(context).push<ExerciseDefinition>(
      MaterialPageRoute(
        builder: (_) => ExerciseCatalogPage(onExercisePicked: (_) {}),
      ),
    );
    if (picked == null || !mounted) return;

    if (picked.id == current.definition.id) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.swapAlreadySelected)));
      return;
    }

    final data = await _dataFuture;
    if (!mounted) return;
    if (_filterForProfileEquipment &&
        data.hasProfile &&
        !ExerciseEquipmentCompatibility.fitsProfileNames(
          picked,
          data.profileEquipmentNames,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.swapNeedsProfileEquipment)),
      );
      return;
    }

    setState(() => _isLoadingManualReplacement = true);
    try {
      final entry = await _buildEntry(picked);
      final score = _similarityScore(current, entry);
      if (!mounted) return;

      setState(() {
        _manualReplacement = entry.copyWith(score: score);
        _isLoadingManualReplacement = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingManualReplacement = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.swapLoadFailed(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: FutureBuilder<_SwapExerciseData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;

              return Column(
                children: [
                  _SwapSheetHeader(
                    isLoading: snapshot.connectionState != ConnectionState.done,
                  ),
                  Expanded(
                    child:
                        data == null
                            ? const Center(child: CircularProgressIndicator())
                            : _buildLoadedContent(
                              context,
                              scrollController,
                              data,
                            ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    ScrollController scrollController,
    _SwapExerciseData data,
  ) {
    final strings = AppLocalizations.of(context);
    final canFilterForProfile = data.hasProfile;
    final candidates = _filteredCandidates(data);
    final hasCandidates = candidates.isNotEmpty;
    final selectedIndex =
        hasCandidates ? _selectedIndex.clamp(0, candidates.length - 1) : 0;
    final manualReplacementActive = _manualReplacement != null;
    final selected =
        _manualReplacement ??
        (hasCandidates ? candidates[selectedIndex] : null);
    final canCycleRecommendations =
        candidates.length > 1 || (manualReplacementActive && hasCandidates);

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _ProfileEquipmentFilterRow(
                value: _filterForProfileEquipment && canFilterForProfile,
                enabled: canFilterForProfile,
                onChanged: (value) {
                  setState(() {
                    _filterForProfileEquipment = value;
                    _manualReplacement = null;
                    _selectedIndex = 0;
                  });
                },
              ),
              const SizedBox(height: 12),
              _ExerciseSwapBox(label: strings.swapCurrent, entry: data.current),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    _isLoadingManualReplacement
                        ? null
                        : () => _browseExerciseCatalog(data.current),
                icon:
                    _isLoadingManualReplacement
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.search),
                label: Text(
                  _isLoadingManualReplacement
                      ? strings.swapLoadingSelected
                      : strings.swapBrowseCatalog,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SwapArrowButton(
                    icon: Icons.chevron_left,
                    enabled: canCycleRecommendations,
                    onPressed: () => _showPrevious(candidates.length),
                  ),
                  Expanded(
                    child:
                        selected == null
                            ? const _NoReplacementBox()
                            : _ExerciseSwapBox(
                              label: strings.swapReplacement,
                              entry: selected,
                              matchScore: selected.score,
                            ),
                  ),
                  _SwapArrowButton(
                    icon: Icons.chevron_right,
                    enabled: canCycleRecommendations,
                    onPressed: () => _showNext(candidates.length),
                  ),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.commonCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                        selected == null
                            ? null
                            : () => Navigator.pop(context, selected.definition),
                    child: Text(strings.swapConfirm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _equipmentText(ExerciseDefinition definition) {
    final equipment = definition.equipmentList
        .map((item) => item.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    return equipment.isEmpty ? _strings.swapNoEquipment : equipment;
  }

  List<_ExerciseSwapEntry> _filteredCandidates(_SwapExerciseData data) {
    if (!_filterForProfileEquipment || !data.hasProfile) {
      return data.candidates;
    }
    return data.candidates
        .where(
          (candidate) => ExerciseEquipmentCompatibility.fitsProfileNames(
            candidate.definition,
            data.profileEquipmentNames,
          ),
        )
        .toList();
  }
}

class _SwapSheetHeader extends StatelessWidget {
  final bool isLoading;

  const _SwapSheetHeader({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.swapTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoading
                      ? strings.swapFindingMatches
                      : strings.swapChooseReplacement,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileEquipmentFilterRow extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ProfileEquipmentFilterRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.swapFilterProfileEquipment,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: enabled ? null : scheme.onSurfaceVariant,
              ),
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _ExerciseSwapBox extends StatelessWidget {
  final String label;
  final _ExerciseSwapEntry entry;
  final double? matchScore;

  const _ExerciseSwapBox({
    required this.label,
    required this.entry,
    this.matchScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (matchScore != null) _MatchBadge(score: matchScore!),
              ],
            ),
            const SizedBox(height: 8),
            LocalizedExerciseNameBuilder(
              definition: entry.definition,
              builder:
                  (context, name) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: name),
                        TextSpan(
                          text: '  •  ${entry.equipmentText}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              184,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final gap = maxWidth < 330 ? 8.0 : 14.0;
                final heatmapWidth =
                    (maxWidth * 0.42).clamp(106.0, 145.0).toDouble();
                final heatmapSize = heatmapWidth.clamp(100.0, 145.0).toDouble();
                final heatmap = SizedBox(
                  width: heatmapWidth,
                  height: heatmapSize,
                  child: Center(
                    child: BodyHeatmap(
                      frequencyMap: entry.frequencyMap,
                      lowColor: colors.historySummaryHeatmapLow!,
                      highColor: colors.historySummaryHeatmapHigh!,
                      width: heatmapSize,
                      height: heatmapSize,
                    ),
                  ),
                );
                final focusList = _BodyPartNameList(hits: entry.bodyPartHits);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heatmap,
                    SizedBox(width: gap),
                    Expanded(child: focusList),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyPartNameList extends StatelessWidget {
  final List<_BodyPartHit> hits;

  const _BodyPartNameList({required this.hits});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final visibleHits = hits.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.swapBodypartsHit,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        if (visibleHits.isEmpty)
          Text(strings.swapNoBodypartData, style: theme.textTheme.bodySmall)
        else
          for (final hit in visibleHits)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double score;

  const _MatchBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final percent = (score * 100).clamp(0, 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green.withAlpha(110)),
      ),
      child: Text(
        strings.swapMatch(percent),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.green,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SwapArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _SwapArrowButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: Icon(icon),
      onPressed: enabled ? onPressed : null,
    );
  }
}

class _NoReplacementBox extends StatelessWidget {
  const _NoReplacementBox();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.swapNoReplacements,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.swapNoReplacementsBody,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapExerciseData {
  final _ExerciseSwapEntry current;
  final List<_ExerciseSwapEntry> candidates;
  final Set<String> profileEquipmentNames;
  final bool hasProfile;

  const _SwapExerciseData({
    required this.current,
    required this.candidates,
    this.profileEquipmentNames = const <String>{},
    this.hasProfile = false,
  });
}

class _ExerciseSwapEntry {
  final ExerciseDefinition definition;
  final Map<int, double> bodyPartUnitsById;
  final Map<int, double> muscleUnitsById;
  final List<_BodyPartHit> bodyPartHits;
  final Map<String, double> frequencyMap;
  final String equipmentText;
  final double score;

  const _ExerciseSwapEntry({
    required this.definition,
    required this.bodyPartUnitsById,
    required this.muscleUnitsById,
    required this.bodyPartHits,
    required this.frequencyMap,
    required this.equipmentText,
    this.score = 1.0,
  });

  _ExerciseSwapEntry copyWith({double? score}) {
    return _ExerciseSwapEntry(
      definition: definition,
      bodyPartUnitsById: bodyPartUnitsById,
      muscleUnitsById: muscleUnitsById,
      bodyPartHits: bodyPartHits,
      frequencyMap: frequencyMap,
      equipmentText: equipmentText,
      score: score ?? this.score,
    );
  }
}

class _BodyPartHit {
  final String name;
  final double units;

  const _BodyPartHit({required this.name, required this.units});
}
