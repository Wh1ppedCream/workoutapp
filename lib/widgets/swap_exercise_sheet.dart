import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../theme/theme_extensions.dart';
import '../utils/async_pool.dart';
import 'body_heatmap.dart';

class SwapExerciseSheet extends StatefulWidget {
  final ExerciseDefinition currentDefinition;

  const SwapExerciseSheet({super.key, required this.currentDefinition});

  @override
  State<SwapExerciseSheet> createState() => _SwapExerciseSheetState();
}

class _SwapExerciseSheetState extends State<SwapExerciseSheet> {
  static const int _candidateBuildConcurrency = 4;

  final _repo = AppRepository();
  late final Future<_SwapExerciseData> _dataFuture;
  int _selectedIndex = 0;
  _ExerciseSwapEntry? _manualReplacement;
  bool _isLoadingManualReplacement = false;

  @override
  void initState() {
    super.initState();
    BodyHeatmap.preload();
    _dataFuture = _loadData();
  }

  Future<_SwapExerciseData> _loadData() async {
    final current = await _buildEntry(widget.currentDefinition);
    final definitions = await _loadCandidateDefinitions(current);
    final candidates = await _buildCandidateEntries(
      definitions
          .where((definition) => definition.id != widget.currentDefinition.id)
          .toList(),
      current,
    );

    candidates.sort((a, b) => b.score.compareTo(a.score));

    return _SwapExerciseData(
      current: current,
      candidates: candidates.take(40).toList(),
    );
  }

  Future<List<ExerciseDefinition>> _loadCandidateDefinitions(
    _ExerciseSwapEntry current,
  ) async {
    final bodyPartIds = current.bodyPartUnitsById.keys.toList();
    final muscleIds = current.muscleUnitsById.keys.toList();

    var definitions = await _repo.lookupDefsFiltered(
      bodypartIds: bodyPartIds.isEmpty ? null : bodyPartIds,
      muscleIds: muscleIds.isEmpty ? null : muscleIds,
    );

    if (definitions.where((def) => def.id != current.definition.id).isEmpty &&
        bodyPartIds.isNotEmpty) {
      definitions = await _repo.lookupDefsFiltered(bodypartIds: bodyPartIds);
    }

    if (definitions.where((def) => def.id != current.definition.id).isEmpty &&
        muscleIds.isNotEmpty) {
      definitions = await _repo.lookupDefsFiltered(muscleIds: muscleIds);
    }

    if (definitions.where((def) => def.id != current.definition.id).isEmpty) {
      return _repo.lookupDefsDetailed();
    }

    return _repo.lookupDefsDetailedByIds(
      definitions.map((definition) => definition.id).toList(),
    );
  }

  Future<_ExerciseSwapEntry> _buildEntry(
    ExerciseDefinition definition, {
    bool hydrateDefinition = true,
  }) async {
    final detailedDefinition =
        hydrateDefinition ? await _hydrateDefinition(definition) : definition;
    final bodyPartUnitsFuture = _repo.computeBodyPartPercents(
      detailedDefinition.id,
    );
    final muscleRowsFuture = _repo.computeMusclePercents(detailedDefinition.id);
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
    final detailed = await _repo.fetchDefinitionById(definition.id);
    final hydrated = detailed ?? definition;
    if (hydrated.equipmentList.isNotEmpty) return hydrated;

    final info = await _repo.fetchDefinitionInfo(hydrated.id);
    final equipmentName = info['equipmentName']?.trim();
    if (equipmentName == null || equipmentName.isEmpty) return hydrated;

    return ExerciseDefinition(
      id: hydrated.id,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That exercise is already selected.')),
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingManualReplacement = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load that replacement exercise.'),
        ),
      );
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
    final candidates = data.candidates;
    final hasCandidates = candidates.isNotEmpty;
    final manualReplacementActive = _manualReplacement != null;
    final selected =
        _manualReplacement ??
        (hasCandidates ? candidates[_selectedIndex] : null);
    final canCycleRecommendations =
        candidates.length > 1 || (manualReplacementActive && hasCandidates);

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _ExerciseSwapBox(label: 'Current', entry: data.current),
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
                      ? 'Loading selected exercise...'
                      : 'Browse Exercise Catalog',
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
                              label: 'Replacement',
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
                    child: const Text('Cancel'),
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
                    child: const Text('Confirm Swap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _equipmentText(ExerciseDefinition definition) {
    final equipment = definition.equipmentList
        .map((item) => item.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    return equipment.isEmpty ? 'No equipment listed' : equipment;
  }
}

class _SwapSheetHeader extends StatelessWidget {
  final bool isLoading;

  const _SwapSheetHeader({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swap Exercise',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoading
                      ? 'Finding similar bodypart and muscle matches...'
                      : 'Choose a similar replacement.',
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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: entry.definition.name),
                  TextSpan(
                    text: '  •  ${entry.equipmentText}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(184),
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
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 340;
                final heatmap = SizedBox(
                  height: compact ? 124 : 150,
                  child: BodyHeatmap(
                    frequencyMap: entry.frequencyMap,
                    lowColor: colors.historySummaryHeatmapLow!,
                    highColor: colors.historySummaryHeatmapHigh!,
                    width: compact ? 118 : 145,
                    height: compact ? 118 : 145,
                  ),
                );
                final focusList = _BodyPartNameList(hits: entry.bodyPartHits);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: compact ? 118 : 145, child: heatmap),
                    SizedBox(width: compact ? 8 : 14),
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
    final theme = Theme.of(context);
    final visibleHits = hits.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bodyparts Hit',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        if (visibleHits.isEmpty)
          Text('No bodypart data found.', style: theme.textTheme.bodySmall)
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
    final percent = (score * 100).clamp(0, 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green.withAlpha(110)),
      ),
      child: Text(
        '$percent% match',
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
              'No similar replacements found yet.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This exercise may need more muscle or bodypart metadata before it can be swapped well.',
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

  const _SwapExerciseData({required this.current, required this.candidates});
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
