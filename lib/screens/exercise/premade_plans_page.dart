import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/premade_training_plans.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/exercise_equipment_compatibility.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/async_pool.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/guided_tutorial_overlay.dart';

class PremadePlansPage extends StatefulWidget {
  final int? profileId;
  final VoidCallback onPlanAdded;
  final ValueChanged<int>? onPlanCreated;
  final bool onboardingMode;

  const PremadePlansPage({
    super.key,
    required this.profileId,
    required this.onPlanAdded,
    this.onPlanCreated,
    this.onboardingMode = false,
  });

  @override
  State<PremadePlansPage> createState() => _PremadePlansPageState();
}

class _PremadePlansPageState extends State<PremadePlansPage> {
  static const _replacementBuildConcurrency = 4;
  static const _homemadeSourceName = 'Homemade';
  static const _homemadePlanGroups = [
    'Full Body',
    'Push Pull Legs',
    'Upper Lower',
    'Body Part (Bro) Split',
  ];

  AppRepository get _repo => context.read<AppRepository>();
  final _durationTutorialKey = GlobalKey(debugLabel: 'premade_duration');
  final _equipmentFilterTutorialKey = GlobalKey(
    debugLabel: 'premade_equipment_filter',
  );
  final _planListTutorialKey = GlobalKey(debugLabel: 'premade_plan_list');
  final _addingPlanIds = <String>{};
  final _onboardingCreatedPlanIds = <int>[];
  Future<_PremadePlanAdaptationData>? _adaptationFuture;
  int? _adaptationProfileId;
  int? _adaptationDurationMinutes;
  bool? _adaptationFilterValue;
  bool _isDiscardingOnboardingPlans = false;
  bool _filterForProfileEquipment = true;
  var _selectedDurationMinutes = 60;
  bool _tutorialQueued = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.premadePlans,
        steps: [
          GuidedTutorialStep(
            targetKey: _durationTutorialKey,
            icon: Icons.schedule,
            title: _strings.premadeTutorialLengthTitle,
            body: _strings.premadeTutorialLengthBody,
          ),
          GuidedTutorialStep(
            targetKey: _equipmentFilterTutorialKey,
            icon: Icons.tune,
            title: _strings.premadeTutorialEquipmentTitle,
            body: _strings.premadeTutorialEquipmentBody,
          ),
          GuidedTutorialStep(
            targetKey: _planListTutorialKey,
            icon: Icons.library_books_outlined,
            title: _strings.premadeTutorialLibraryTitle,
            body: _strings.premadeTutorialLibraryBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _addPlan(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  ) async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.premadeSelectProfile)));
      return;
    }

    setState(() => _addingPlanIds.add(plan.id));
    try {
      final presetName = await _uniqueAddedPlanName(plan.name, profileId);
      final writes = <WorkoutExerciseWrite>[];
      for (final exercise in exercises) {
        final defId = await _repo.findOrCreateExerciseDefinition(
          exercise.name,
          exercise.equipment,
        );
        writes.add(
          WorkoutExerciseWrite(
            exercise: WeightExercise(
              name: exercise.name,
              equipment: exercise.equipment,
              sets: List<ExerciseSet>.generate(
                exercise.sets,
                (_) =>
                    ExerciseSet(weight: exercise.weight, reps: exercise.reps),
              ),
            ),
            type: 'weight',
            definitionId: defId,
          ),
        );
      }
      final presetId = await _repo.createPresetAtomic(
        name: presetName,
        profileId: profileId,
        exercises: writes,
        activate: true,
      );

      if (!mounted) return;
      widget.onPlanAdded();
      widget.onPlanCreated?.call(presetId);
      if (widget.onboardingMode) {
        setState(() => _onboardingCreatedPlanIds.add(presetId));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.premadePlanAdded(presetName))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.premadePlanAddFailed(plan.name, error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingPlanIds.remove(plan.id));
      }
    }
  }

  Future<_PremadePlanAdaptationData> _ensureAdaptationData() {
    if (_adaptationFuture == null ||
        _adaptationProfileId != widget.profileId ||
        _adaptationDurationMinutes != _selectedDurationMinutes ||
        _adaptationFilterValue != _filterForProfileEquipment) {
      _adaptationProfileId = widget.profileId;
      _adaptationDurationMinutes = _selectedDurationMinutes;
      _adaptationFilterValue = _filterForProfileEquipment;
      _adaptationFuture = _loadAdaptationData();
    }
    return _adaptationFuture!;
  }

  Future<_PremadePlanAdaptationData> _loadAdaptationData() async {
    final profileEquipmentNames = await _loadProfileEquipmentNames();
    final normalizedProfileEquipmentNames = _normalizeEquipmentNames(
      profileEquipmentNames,
    );
    if (!_filterForProfileEquipment || widget.profileId == null) {
      return _PremadePlanAdaptationData(
        profileEquipmentNames: profileEquipmentNames,
        adaptations: const <String, _PremadePlanAdaptation>{},
      );
    }

    final plans =
        premadeTrainingPlans
            .where((plan) => plan.durationMinutes == _selectedDurationMinutes)
            .toList();
    final candidates = await _loadProfileCandidateEntries(
      normalizedProfileEquipmentNames,
    );
    if (candidates.isEmpty) {
      return _PremadePlanAdaptationData(
        profileEquipmentNames: profileEquipmentNames,
        adaptations: const <String, _PremadePlanAdaptation>{},
      );
    }

    final replacementCache = <String, PremadeTrainingExercise?>{};
    final definitionCache = <String, Future<ExerciseDefinition?>>{};
    final adaptations = <String, _PremadePlanAdaptation>{};
    for (final plan in plans) {
      var replacementCount = 0;
      final adaptedExercises = <PremadeTrainingExercise>[];

      for (final exercise in plan.exercises) {
        final cacheKey = _premadeExerciseCacheKey(exercise);
        final definition = await definitionCache.putIfAbsent(
          cacheKey,
          () => _findPremadeExerciseDefinition(exercise),
        );
        if (_premadeExerciseFitsProfile(
          exercise,
          normalizedProfileEquipmentNames,
          definition: definition,
        )) {
          adaptedExercises.add(exercise);
          continue;
        }

        final replacement =
            replacementCache.containsKey(cacheKey)
                ? replacementCache[cacheKey]
                : await _findReplacementExercise(exercise, candidates);
        replacementCache[cacheKey] = replacement;

        if (replacement == null) {
          adaptedExercises.add(exercise);
        } else {
          adaptedExercises.add(replacement);
          replacementCount++;
        }
      }

      if (replacementCount > 0) {
        adaptations[plan.id] = _PremadePlanAdaptation(
          exercises: List<PremadeTrainingExercise>.unmodifiable(
            adaptedExercises,
          ),
          replacementCount: replacementCount,
        );
      }
    }

    return _PremadePlanAdaptationData(
      profileEquipmentNames: profileEquipmentNames,
      adaptations: adaptations,
    );
  }

  Future<Set<String>> _loadProfileEquipmentNames() async {
    final profileId = widget.profileId;
    if (profileId == null) return const <String>{};
    final rows = await _repo.fetchEquipmentForProfile(profileId);
    return {
      for (final row in rows)
        if ((row['name'] as String?)?.trim().isNotEmpty ?? false)
          (row['name'] as String).trim(),
    };
  }

  Set<String> _normalizeEquipmentNames(Iterable<String> equipmentNames) {
    return {
      for (final name in equipmentNames)
        if (name.trim().isNotEmpty) name.trim().toLowerCase(),
    };
  }

  Future<List<_PremadeExerciseMatchEntry>> _loadProfileCandidateEntries(
    Set<String> normalizedProfileEquipmentNames,
  ) async {
    final definitions = await _repo.lookupDefsDetailed();
    final entries = await mapWithConcurrency<
      ExerciseDefinition,
      _PremadeExerciseMatchEntry?
    >(
      definitions,
      maxConcurrency: _replacementBuildConcurrency,
      mapper: (definition, _) async {
        if (!_definitionFitsProfile(
          definition,
          normalizedProfileEquipmentNames,
        )) {
          return null;
        }
        return _buildMatchEntry(definition);
      },
    );

    return [
      for (final entry in entries)
        if (entry != null) entry,
    ];
  }

  Future<PremadeTrainingExercise?> _findReplacementExercise(
    PremadeTrainingExercise exercise,
    List<_PremadeExerciseMatchEntry> candidates,
  ) async {
    final current = await _buildPremadeExerciseEntry(exercise);
    if (current == null) return null;

    _PremadeExerciseMatchEntry? bestCandidate;
    var bestScore = 0.0;
    for (final candidate in candidates) {
      if (candidate.definition.id == current.definition.id) continue;
      final score = _similarityScore(current, candidate);
      if (score > bestScore) {
        bestScore = score;
        bestCandidate = candidate;
      }
    }

    if (bestCandidate == null || bestScore <= 0.05) return null;
    final equipment = _primaryEquipmentName(bestCandidate.definition);

    return PremadeTrainingExercise(
      name: bestCandidate.definition.name,
      equipment: equipment,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
    );
  }

  Future<_PremadeExerciseMatchEntry?> _buildPremadeExerciseEntry(
    PremadeTrainingExercise exercise,
  ) async {
    final definition = await _findPremadeExerciseDefinition(exercise);
    if (definition == null) return null;
    return _buildMatchEntry(definition);
  }

  Future<ExerciseDefinition?> _findPremadeExerciseDefinition(
    PremadeTrainingExercise exercise,
  ) async {
    try {
      final id = await _repo.findExerciseDefinitionId(
        exercise.name,
        exercise.equipment,
      );
      return _repo.fetchDefinitionById(id);
    } catch (_) {
      // Fall through to name search. Some definitions store extra equipment in
      // the join table, while the strict ID lookup checks only the primary
      // equipment column.
    }

    final searchResults = await _repo.searchExerciseDefinitions(exercise.name);
    if (searchResults.isEmpty) return null;
    final detailedResults = await _repo.lookupDefsDetailedByIds(
      searchResults.map((definition) => definition.id).toSet().toList(),
    );
    final targetName = exercise.name.trim().toLowerCase();
    final targetEquipment = exercise.equipment.trim().toLowerCase();

    for (final definition in detailedResults) {
      final names = ExerciseEquipmentCompatibility.requiredEquipmentNames(
        definition,
      );
      if (definition.name.trim().toLowerCase() == targetName &&
          names.contains(targetEquipment)) {
        return definition;
      }
    }

    for (final definition in detailedResults) {
      if (definition.name.trim().toLowerCase() == targetName) {
        return definition;
      }
    }

    return detailedResults.first;
  }

  Future<_PremadeExerciseMatchEntry> _buildMatchEntry(
    ExerciseDefinition definition,
  ) async {
    final bodyPartUnits = await _repo.computeBodyPartPercents(definition.id);
    final muscleRows = await _repo.computeMusclePercents(definition.id);
    return _PremadeExerciseMatchEntry(
      definition: definition,
      bodyPartUnitsById: {
        for (final entry in bodyPartUnits.entries)
          if (entry.value > 0.0) entry.key.id: entry.value,
      },
      muscleUnitsById: {
        for (final row in muscleRows)
          if (row.percent > 0.0) row.muscleId: row.percent,
      },
    );
  }

  double _similarityScore(
    _PremadeExerciseMatchEntry current,
    _PremadeExerciseMatchEntry candidate,
  ) {
    final bodyPartScore = _cosineSimilarity(
      current.bodyPartUnitsById,
      candidate.bodyPartUnitsById,
    );
    final muscleScore = _cosineSimilarity(
      current.muscleUnitsById,
      candidate.muscleUnitsById,
    );
    return bodyPartScore * 0.60 + muscleScore * 0.40;
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

  bool _premadeExerciseFitsProfile(
    PremadeTrainingExercise exercise,
    Set<String> profileEquipmentNames, {
    ExerciseDefinition? definition,
  }) {
    if (definition != null) {
      return _definitionFitsProfile(definition, profileEquipmentNames);
    }
    // Keep static-plan entries without a matching definition compatible with
    // their existing one-equipment fallback behavior.
    return _profileContainsEquipment(profileEquipmentNames, exercise.equipment);
  }

  bool _definitionFitsProfile(
    ExerciseDefinition definition,
    Set<String> profileEquipmentNames,
  ) => ExerciseEquipmentCompatibility.fitsProfileNames(
    definition,
    profileEquipmentNames,
  );

  String _premadeExerciseCacheKey(PremadeTrainingExercise exercise) =>
      '${exercise.name.trim().toLowerCase()}|'
      '${exercise.equipment.trim().toLowerCase()}';

  bool _profileContainsEquipment(
    Set<String> profileEquipmentNames,
    String equipmentName,
  ) {
    final equipment = equipmentName.trim().toLowerCase();
    if (equipment.isEmpty) return true;
    if (profileEquipmentNames.contains(equipment)) return true;
    if (equipment == 'bodyweight' || equipment == 'none') {
      return profileEquipmentNames.contains('bodyweight') ||
          profileEquipmentNames.contains('none');
    }
    return false;
  }

  String _primaryEquipmentName(ExerciseDefinition definition) {
    for (final equipment in definition.equipmentList) {
      final name = equipment.name.trim();
      if (name.isNotEmpty) return name;
    }
    return 'Bodyweight';
  }

  Future<void> _discardOnboardingPlans() async {
    if (_isDiscardingOnboardingPlans) return;
    final activePlanStore = context.read<ActivePlanStore>();
    final repository = _repo;
    setState(() => _isDiscardingOnboardingPlans = true);
    try {
      final profileId = widget.profileId;
      for (final presetId in List<int>.from(_onboardingCreatedPlanIds)) {
        if (profileId != null) {
          await activePlanStore.remove(profileId, presetId);
        }
        await repository.deletePreset(presetId);
      }
      if (!mounted) return;
      Navigator.of(context).pop<List<int>>(const <int>[]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.premadeDiscardFailed(error.toString())),
        ),
      );
      setState(() => _isDiscardingOnboardingPlans = false);
    }
  }

  void _finishOnboardingPlanSelection() {
    if (_onboardingCreatedPlanIds.isEmpty) return;
    Navigator.of(
      context,
    ).pop<List<int>>(List<int>.unmodifiable(_onboardingCreatedPlanIds));
  }

  Future<String> _uniqueAddedPlanName(String baseName, int profileId) async {
    final existingRows = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final existingNames = {
      for (final row in existingRows) (row['name'] as String).trim(),
    };
    if (!existingNames.contains(baseName)) return baseName;

    var copyNumber = 2;
    while (existingNames.contains('$baseName ($copyNumber)')) {
      copyNumber++;
    }
    return '$baseName ($copyNumber)';
  }

  Map<String, List<PremadeTrainingPlan>> _plansBySource() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    final filteredPlans = premadeTrainingPlans.where(
      (plan) => plan.durationMinutes == _selectedDurationMinutes,
    );
    for (final plan in filteredPlans) {
      grouped
          .putIfAbsent(plan.sourceName, () => <PremadeTrainingPlan>[])
          .add(plan);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final groupedPlans = _plansBySource();
    final homemadePlans =
        groupedPlans.remove(_homemadeSourceName) ??
        const <PremadeTrainingPlan>[];
    final adaptationFuture = _ensureAdaptationData();
    final content = Scaffold(
      appBar: AppBar(title: Text(strings.premadePlansTitle)),
      bottomNavigationBar:
          widget.onboardingMode
              ? _OnboardingPlanActionBar(
                addedCount: _onboardingCreatedPlanIds.length,
                isBusy: _isDiscardingOnboardingPlans,
                onCancel: _discardOnboardingPlans,
                onSave:
                    _onboardingCreatedPlanIds.isEmpty
                        ? null
                        : _finishOnboardingPlanSelection,
              )
              : null,
      body: FutureBuilder<_PremadePlanAdaptationData>(
        future: adaptationFuture,
        builder: (context, snapshot) {
          final loadedAdaptationData =
              snapshot.data ?? _PremadePlanAdaptationData.empty;
          final adaptationData =
              _filterForProfileEquipment
                  ? loadedAdaptationData
                  : _PremadePlanAdaptationData(
                    profileEquipmentNames:
                        loadedAdaptationData.profileEquipmentNames,
                    adaptations: const <String, _PremadePlanAdaptation>{},
                  );
          final isPreparingFilter =
              _filterForProfileEquipment &&
              snapshot.connectionState != ConnectionState.done;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              widget.onboardingMode ? 112 : 24,
            ),
            children: [
              KeyedSubtree(
                key: _durationTutorialKey,
                child: _PremadeDurationHeader(
                  durationMinutes: _selectedDurationMinutes,
                  onChanged: (durationMinutes) {
                    setState(() {
                      _selectedDurationMinutes = durationMinutes;
                      _adaptationFuture = null;
                    });
                  },
                  child: Text(
                    strings.premadeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: _equipmentFilterTutorialKey,
                child: _PremadeProfileEquipmentFilterCard(
                  value: _filterForProfileEquipment,
                  enabled: widget.profileId != null,
                  isLoading: isPreparingFilter,
                  hasProfileEquipment:
                      adaptationData.profileEquipmentNames.isNotEmpty,
                  replacementCount: adaptationData.totalReplacementCount,
                  onChanged: (value) {
                    setState(() {
                      _filterForProfileEquipment = value;
                      _adaptationFuture = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              KeyedSubtree(
                key: _planListTutorialKey,
                child: _PremadeSourceSection(
                  sourceName: _homemadeSourceName,
                  plans: homemadePlans,
                  planGroupNames: _homemadePlanGroups,
                  initiallyExpanded: true,
                  addingPlanIds: _addingPlanIds,
                  adaptationData: adaptationData,
                  isPreparingFilter: isPreparingFilter,
                  onAddPlan: _addPlan,
                ),
              ),
              const SizedBox(height: 16),
              for (final entry in groupedPlans.entries) ...[
                _PremadeSourceSection(
                  sourceName: entry.key,
                  plans: entry.value,
                  initiallyExpanded: false,
                  addingPlanIds: _addingPlanIds,
                  adaptationData: adaptationData,
                  isPreparingFilter: isPreparingFilter,
                  onAddPlan: _addPlan,
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );

    if (!widget.onboardingMode) return content;
    return PopScope<List<int>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _discardOnboardingPlans();
      },
      child: content,
    );
  }
}

class _OnboardingPlanActionBar extends StatelessWidget {
  final int addedCount;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  const _OnboardingPlanActionBar({
    required this.addedCount,
    required this.isBusy,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : onCancel,
                child: Text(
                  isBusy ? strings.premadeDiscarding : strings.commonCancel,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onSave,
                icon: _PlanCountBadge(count: addedCount),
                label: Text(strings.premadeReviewPlans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  final int count;

  const _PlanCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.save_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: scheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PremadePlanAdaptationData {
  final Set<String> profileEquipmentNames;
  final Map<String, _PremadePlanAdaptation> adaptations;

  const _PremadePlanAdaptationData({
    required this.profileEquipmentNames,
    required this.adaptations,
  });

  static const empty = _PremadePlanAdaptationData(
    profileEquipmentNames: <String>{},
    adaptations: <String, _PremadePlanAdaptation>{},
  );

  int get totalReplacementCount => adaptations.values.fold<int>(
    0,
    (sum, adaptation) => sum + adaptation.replacementCount,
  );

  List<PremadeTrainingExercise> exercisesFor(PremadeTrainingPlan plan) {
    return adaptations[plan.id]?.exercises ?? plan.exercises;
  }

  int replacementCountFor(PremadeTrainingPlan plan) {
    return adaptations[plan.id]?.replacementCount ?? 0;
  }
}

class _PremadePlanAdaptation {
  final List<PremadeTrainingExercise> exercises;
  final int replacementCount;

  const _PremadePlanAdaptation({
    required this.exercises,
    required this.replacementCount,
  });
}

class _PremadeExerciseMatchEntry {
  final ExerciseDefinition definition;
  final Map<int, double> bodyPartUnitsById;
  final Map<int, double> muscleUnitsById;

  const _PremadeExerciseMatchEntry({
    required this.definition,
    required this.bodyPartUnitsById,
    required this.muscleUnitsById,
  });
}

class _PremadeProfileEquipmentFilterCard extends StatelessWidget {
  final bool value;
  final bool enabled;
  final bool isLoading;
  final bool hasProfileEquipment;
  final int replacementCount;
  final ValueChanged<bool> onChanged;

  const _PremadeProfileEquipmentFilterCard({
    required this.value,
    required this.enabled,
    required this.isLoading,
    required this.hasProfileEquipment,
    required this.replacementCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final subtitle =
        !enabled
            ? strings.premadeEquipmentSelectProfile
            : !value
            ? strings.premadeEquipmentExact
            : isLoading
            ? strings.premadeEquipmentChecking
            : !hasProfileEquipment
            ? strings.premadeEquipmentMissing
            : replacementCount > 0
            ? strings.premadeEquipmentReplacements(replacementCount)
            : strings.premadeEquipmentFits;

    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Icon(Icons.tune, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.swapFilterProfileEquipment,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }
}

class _PremadeDurationHeader extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;
  final Widget child;

  const _PremadeDurationHeader({
    required this.durationMinutes,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final switcher = _PremadeDurationSwitch(
      durationMinutes: durationMinutes,
      onChanged: onChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: switcher),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child),
            const SizedBox(width: 14),
            switcher,
          ],
        );
      },
    );
  }
}

class _PremadeDurationSwitch extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;

  const _PremadeDurationSwitch({
    required this.durationMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final isTwoHour = durationMinutes == 120;
    final activeStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w800,
    );
    final inactiveStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.premadeOneHour,
              style: isTwoHour ? inactiveStyle : activeStyle,
            ),
            Switch(
              value: isTwoHour,
              onChanged: (value) => onChanged(value ? 120 : 60),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              strings.premadeTwoHours,
              style: isTwoHour ? activeStyle : inactiveStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremadeSourceSection extends StatelessWidget {
  final String sourceName;
  final List<PremadeTrainingPlan> plans;
  final List<String> planGroupNames;
  final bool initiallyExpanded;
  final Set<String> addingPlanIds;
  final _PremadePlanAdaptationData adaptationData;
  final bool isPreparingFilter;
  final Future<void> Function(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  )
  onAddPlan;

  const _PremadeSourceSection({
    required this.sourceName,
    required this.plans,
    this.planGroupNames = const <String>[],
    required this.initiallyExpanded,
    required this.addingPlanIds,
    required this.adaptationData,
    required this.isPreparingFilter,
    required this.onAddPlan,
  });

  Map<String, List<PremadeTrainingPlan>> _plansByGroup() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    for (final plan in plans) {
      grouped
          .putIfAbsent(plan.planGroupName, () => <PremadeTrainingPlan>[])
          .add(plan);
    }
    return grouped;
  }

  List<String> _orderedGroupNames(
    Map<String, List<PremadeTrainingPlan>> grouped,
  ) {
    final ordered = <String>[
      ...planGroupNames,
      for (final groupName in grouped.keys)
        if (!planGroupNames.contains(groupName)) groupName,
    ];
    if (ordered.isNotEmpty) return ordered;
    return grouped.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final grouped = _plansByGroup();
    final orderedGroupNames = _orderedGroupNames(grouped);
    final planCount = plans.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          sourceName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          strings.premadePlansAvailable(planCount),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          for (final groupName in orderedGroupNames)
            _PremadePlanGroupTile(
              groupName: groupName,
              plans: grouped[groupName] ?? const <PremadeTrainingPlan>[],
              addingPlanIds: addingPlanIds,
              adaptationData: adaptationData,
              isPreparingFilter: isPreparingFilter,
              onAddPlan: onAddPlan,
            ),
        ],
      ),
    );
  }
}

class _PremadePlanGroupTile extends StatelessWidget {
  final String groupName;
  final List<PremadeTrainingPlan> plans;
  final Set<String> addingPlanIds;
  final _PremadePlanAdaptationData adaptationData;
  final bool isPreparingFilter;
  final Future<void> Function(
    PremadeTrainingPlan plan,
    List<PremadeTrainingExercise> exercises,
  )
  onAddPlan;

  const _PremadePlanGroupTile({
    required this.groupName,
    required this.plans,
    required this.addingPlanIds,
    required this.adaptationData,
    required this.isPreparingFilter,
    required this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final planCount = plans.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        title: Text(
          groupName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          planCount == 0
              ? strings.premadeNoTemplates
              : strings.premadePlansCount(planCount),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.premadeTemplatesLater,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final plan in plans) ...[
              _PremadePlanCard(
                plan: plan,
                exercises: adaptationData.exercisesFor(plan),
                replacementCount: adaptationData.replacementCountFor(plan),
                isAdding: addingPlanIds.contains(plan.id),
                isPreparing: isPreparingFilter,
                onAdd: () {
                  onAddPlan(plan, adaptationData.exercisesFor(plan));
                },
              ),
              if (plan != plans.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PremadePlanCard extends StatefulWidget {
  final PremadeTrainingPlan plan;
  final List<PremadeTrainingExercise> exercises;
  final int replacementCount;
  final bool isAdding;
  final bool isPreparing;
  final VoidCallback onAdd;

  const _PremadePlanCard({
    required this.plan,
    required this.exercises,
    required this.replacementCount,
    required this.isAdding,
    required this.isPreparing,
    required this.onAdd,
  });

  @override
  State<_PremadePlanCard> createState() => _PremadePlanCardState();
}

class _PremadePlanCardState extends State<_PremadePlanCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  bool _exerciseChangedAt(int index) {
    final originalExercises = widget.plan.exercises;
    if (index >= originalExercises.length) return false;
    final original = originalExercises[index];
    final current = widget.exercises[index];
    return original.name != current.name ||
        original.equipment != current.equipment;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final plan = widget.plan;
    final exercises = widget.exercises;
    final totalSets = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          plan.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < exercises.length; i++)
          _PremadeExerciseRow(
            exercise: exercises[i],
            wasSwapped: _exerciseChangedAt(i),
          ),
      ],
    );
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plan.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            strings.premadeExerciseCount(exercises.length),
            strings.premadeSetCount(totalSets),
            if (widget.replacementCount > 0)
              strings.premadeSwappedCount(widget.replacementCount),
          ].join(' - '),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    final addButton = FilledButton.tonalIcon(
      onPressed: widget.isAdding || widget.isPreparing ? null : widget.onAdd,
      icon:
          widget.isAdding || widget.isPreparing
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.add),
      label: Text(
        widget.isAdding
            ? strings.premadeAdding
            : widget.isPreparing
            ? strings.premadeChecking
            : strings.commonAdd,
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpanded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titleWithIcon = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: titleBlock),
                    ],
                  );

                  if (constraints.maxWidth < 330) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWithIcon,
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: addButton),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleWithIcon),
                      const SizedBox(width: 12),
                      addButton,
                    ],
                  );
                },
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: details,
              ),
              crossFadeState:
                  _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremadeExerciseRow extends StatelessWidget {
  final PremadeTrainingExercise exercise;
  final bool wasSwapped;

  const _PremadeExerciseRow({required this.exercise, required this.wasSwapped});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fitness_center,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' - ${exercise.equipment}',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      TextSpan(
                        text: ' - ${exercise.sets} x ${exercise.reps}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (wasSwapped)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        strings.premadeProfileSwap,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
