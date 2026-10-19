import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/safe_failure_localizations.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../services/catalog_entity_localizer.dart';
import '../services/exercise_equipment_compatibility.dart';
import '../theme/theme_extensions.dart';
import '../theme/expressive_planning_tokens.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/workout_actions.dart';
import '../utils/async_pool.dart';
import 'body_heatmap.dart';
import 'localized_catalog_entity_name.dart';
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

  late Future<_SwapExerciseData> _dataFuture;
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

  void _retryLoad() {
    setState(() {
      _dataFuture = _loadData();
    });
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
    final detailedDefinition = hydrateDefinition
        ? await _hydrateDefinition(definition)
        : definition;
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
      equipment: _equipmentEntities(detailedDefinition),
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
    final currentNames = current.equipmentList
        .map((equipment) => equipment.name.toLowerCase())
        .toSet();
    final candidateNames = candidate.equipmentList
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
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.catalog,
          child: ExerciseCatalogPage(
            onExercisePicked: (_) {},
            expressiveCatalogPresentation: context.usesExpressivePresentation,
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;

    if (picked.id == current.definition.id) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_strings.swapAlreadySelected)));
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
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          color: planning?.pageCanvas,
          elevation: context.effectTokens.swapSheetElevation,
          borderRadius: context.shapeTokens.swapSheet,
          clipBehavior: Clip.antiAlias,
          child: FutureBuilder<_SwapExerciseData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;

              return Column(
                children: [
                  _SwapSheetHeader(
                    isLoading:
                        snapshot.connectionState != ConnectionState.done &&
                        !snapshot.hasError,
                  ),
                  Expanded(
                    child: snapshot.hasError
                        ? _SwapLoadError(
                            error: snapshot.error!,
                            planning: planning,
                            onRetry: _retryLoad,
                          )
                        : data == null
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .swapFindingMatches,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildLoadedContent(context, scrollController, data),
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
    final selectedIndex = hasCandidates
        ? _selectedIndex.clamp(0, candidates.length - 1)
        : 0;
    final manualReplacementActive = _manualReplacement != null;
    final selected =
        _manualReplacement ??
        (hasCandidates ? candidates[selectedIndex] : null);
    final canCycleRecommendations =
        candidates.length > 1 || (manualReplacementActive && hasCandidates);
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final browseLabel = _isLoadingManualReplacement
        ? strings.swapLoadingSelected
        : strings.swapBrowseCatalog;
    final browseAction = planning == null
        ? OutlinedButton.icon(
            onPressed: _isLoadingManualReplacement
                ? null
                : () => _browseExerciseCatalog(data.current),
            icon: _isLoadingManualReplacement
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(browseLabel),
          )
        : FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: planning.actionSecondary,
              foregroundColor: planning.actionSecondaryForeground,
              shape: RoundedRectangleBorder(borderRadius: planning.rowShape),
            ),
            onPressed: _isLoadingManualReplacement
                ? null
                : () => _browseExerciseCatalog(data.current),
            icon: _isLoadingManualReplacement
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(browseLabel),
          );

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
              const SizedBox(height: 8),
              _ExerciseSwapBox(
                label: strings.swapCurrent,
                entry: data.current,
                compact: planning != null,
              ),
              const SizedBox(height: 8),
              if (selected == null)
                _NoReplacementBox(planning: planning)
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (canCycleRecommendations)
                      _SwapArrowButton(
                        icon: Icons.chevron_left,
                        enabled: true,
                        onPressed: () => _showPrevious(candidates.length),
                      ),
                    Expanded(
                      child: _ExerciseSwapBox(
                        label: strings.swapReplacement,
                        entry: selected,
                        matchScore: selected.score,
                        compact: planning != null,
                      ),
                    ),
                    if (canCycleRecommendations)
                      _SwapArrowButton(
                        icon: Icons.chevron_right,
                        enabled: true,
                        onPressed: () => _showNext(candidates.length),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Align(alignment: Alignment.center, child: browseAction),
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
                  child: _buildSwapAction(
                    planning: planning,
                    cancel: true,
                    label: strings.commonCancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSwapAction(
                    planning: planning,
                    label: strings.swapConfirm,
                    onPressed: selected == null
                        ? null
                        : () => Navigator.pop(context, selected.definition),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapAction({
    required AppExpressivePlanningTokens? planning,
    required String label,
    required VoidCallback? onPressed,
    bool cancel = false,
  }) {
    if (planning == null) {
      return WorkoutSwapAction(
        cancel: cancel,
        label: label,
        onPressed: onPressed,
      );
    }

    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(borderRadius: planning.rowShape);
    final Widget button = cancel
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: planning.configurationForeground,
              side: BorderSide(color: planning.outline),
              minimumSize: const Size.fromHeight(48),
              shape: shape,
            ),
            onPressed: onPressed,
            child: Text(label),
          )
        : FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? theme.colorScheme.surfaceContainerHighest
                    : planning.actionPrimary,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? theme.disabledColor
                    : planning.actionPrimaryForeground,
              ),
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
              shape: WidgetStatePropertyAll(shape),
            ),
            onPressed: onPressed,
            child: Text(label),
          );
    return TonosExpressivePressResponse(
      enabled: onPressed != null,
      borderRadius: planning.rowShape,
      pressedBorderRadius: planning.rowShape,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      child: button,
    );
  }

  List<CatalogEntityDisplayName> _equipmentEntities(
    ExerciseDefinition definition,
  ) {
    return definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);
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
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final theme = Theme.of(context);
    return Container(
      color: planning?.planFocalSurface,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.swapTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: planning?.planFocalForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLoading
                            ? strings.swapFindingMatches
                            : strings.swapChooseReplacement,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: planning?.planFocalForeground,
                        ),
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: planning?.planAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: strings.commonClose,
            style: planning == null
                ? null
                : IconButton.styleFrom(
                    foregroundColor: planning.planFocalForeground,
                  ),
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
    return WorkoutEquipmentFilter(
      label: strings.swapFilterProfileEquipment,
      value: value,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class _ExerciseSwapBox extends StatelessWidget {
  final String label;
  final _ExerciseSwapEntry entry;
  final double? matchScore;
  final bool compact;

  const _ExerciseSwapBox({
    required this.label,
    required this.entry,
    this.matchScore,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final fill = planning == null
        ? null
        : matchScore == null
        ? planning.planSupportSurface
        : planning.configurationSurface;
    final foreground = planning == null
        ? theme.colorScheme.onSurface
        : matchScore == null
        ? planning.planSupportForeground
        : planning.configurationForeground;
    final secondaryForeground =
        (planning == null ? theme.textTheme.bodySmall?.color : foreground)
            ?.withValues(alpha: surfaces.swapSecondaryTextOpacity);

    final card = Card(
      color: fill,
      shape: planning == null
          ? null
          : RoundedRectangleBorder(borderRadius: planning.supportShape),
      child: Padding(
        padding: EdgeInsets.all(planning == null ? 12 : 10),
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
                      color: planning?.planAccent ?? theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (matchScore != null) _MatchBadge(score: matchScore!),
              ],
            ),
            SizedBox(height: planning == null ? 8 : 5),
            LocalizedExerciseNameBuilder(
              definition: entry.definition,
              builder: (context, name) => LocalizedCatalogEntityNamesBuilder(
                entities: entry.equipment,
                builder: (context, equipmentNames) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name),
                      TextSpan(
                        text:
                            '  •  ${equipmentNames.isEmpty ? AppLocalizations.of(context).swapNoEquipment : equipmentNames.join(', ')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryForeground,
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
            ),
            SizedBox(height: planning == null ? 16 : 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final gap = maxWidth < 330 ? 8.0 : 14.0;
                final heatmapWidth = planning == null
                    ? (maxWidth * 0.42).clamp(106.0, 145.0).toDouble()
                    : (maxWidth * 0.32).clamp(84.0, 112.0).toDouble();
                final heatmapSize = planning == null
                    ? heatmapWidth.clamp(100.0, 145.0).toDouble()
                    : heatmapWidth.clamp(84.0, 112.0).toDouble();
                final heatmap = SizedBox(
                  width: heatmapWidth,
                  height: heatmapSize,
                  child: Center(
                    child: BodyHeatmap(
                      frequencyMap: entry.frequencyMap,
                      lowColor: tonosHeatmapLowForSurface(
                        context,
                        fill ?? surfaces.card,
                      ),
                      highColor: tonosHeatmapHighForSurface(
                        context,
                        fill ?? surfaces.card,
                      ),
                      width: heatmapSize,
                      height: heatmapSize,
                    ),
                  ),
                );
                final focusList = _BodyPartNameList(
                  hits: entry.bodyPartHits,
                  compact: compact,
                  foreground: foreground,
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heatmap,
                    SizedBox(
                      width: planning == null ? gap : gap.clamp(6.0, 10.0),
                    ),
                    Expanded(child: focusList),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
    if (planning == null) return card;
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          surface: fill,
          onSurface: foreground,
          onSurfaceVariant: secondaryForeground,
          primary: planning.planAccent,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: foreground,
          displayColor: foreground,
        ),
      ),
      child: card,
    );
  }
}

class _BodyPartNameList extends StatelessWidget {
  final List<_BodyPartHit> hits;
  final bool compact;
  final Color foreground;

  const _BodyPartNameList({
    required this.hits,
    required this.compact,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final visibleHits = hits.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.usesExpressivePresentation
              ? strings.swapBodyPartsWorked
              : strings.swapBodypartsHit,
          style: theme.textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: compact ? 3 : 6),
        if (visibleHits.isEmpty)
          Text(strings.swapNoBodypartData, style: theme.textTheme.bodySmall)
        else
          for (final hit in visibleHits)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 2 : 4),
              child: Row(
                children: [
                  const WorkoutMatchMarker(),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground,
                        fontSize: 11,
                        height: compact ? 1.0 : 1.1,
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
    return WorkoutMatchBadge(label: strings.swapMatch(percent));
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
  final AppExpressivePlanningTokens? planning;

  const _NoReplacementBox({required this.planning});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = planning;
    final foreground =
        tokens?.configurationForeground ?? theme.colorScheme.onSurface;
    return Card(
      color: tokens?.configurationSurface,
      shape: tokens == null
          ? null
          : RoundedRectangleBorder(borderRadius: tokens.supportShape),
      child: Padding(
        padding: EdgeInsets.all(tokens == null ? 24 : 14),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: tokens == null ? 40 : 28,
              color: tokens?.planAccent ?? theme.colorScheme.primary,
            ),
            SizedBox(height: tokens == null ? 12 : 6),
            Text(
              strings.swapNoReplacements,
              style: theme.textTheme.titleMedium?.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens == null ? 8 : 4),
            Text(
              strings.swapNoReplacementsBody,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapLoadError extends StatelessWidget {
  final Object error;
  final AppExpressivePlanningTokens? planning;
  final VoidCallback onRetry;

  const _SwapLoadError({
    required this.error,
    required this.planning,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = planning;
    final foreground =
        tokens?.configurationForeground ?? theme.colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: tokens?.configurationSurface,
        shape: tokens == null
            ? null
            : RoundedRectangleBorder(borderRadius: tokens.supportShape),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: tokens?.planAccent ?? theme.colorScheme.error,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                strings.safeFailureLoadTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                safeFailureMessage(strings, error),
                style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (tokens == null)
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.commonRetry),
                )
              else
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.actionSecondary,
                    foregroundColor: tokens.actionSecondaryForeground,
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.rowShape,
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.commonRetry),
                ),
            ],
          ),
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
  final List<CatalogEntityDisplayName> equipment;
  final double score;

  const _ExerciseSwapEntry({
    required this.definition,
    required this.bodyPartUnitsById,
    required this.muscleUnitsById,
    required this.bodyPartHits,
    required this.frequencyMap,
    required this.equipment,
    this.score = 1.0,
  });

  _ExerciseSwapEntry copyWith({double? score}) {
    return _ExerciseSwapEntry(
      definition: definition,
      bodyPartUnitsById: bodyPartUnitsById,
      muscleUnitsById: muscleUnitsById,
      bodyPartHits: bodyPartHits,
      frequencyMap: frequencyMap,
      equipment: equipment,
      score: score ?? this.score,
    );
  }
}

class _BodyPartHit {
  final String name;
  final double units;

  const _BodyPartHit({required this.name, required this.units});
}
