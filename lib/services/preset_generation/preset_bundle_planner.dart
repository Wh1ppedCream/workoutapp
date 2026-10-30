part of '../preset_generation_service.dart';

enum _BundleFallbackStage {
  normal,
  allowPreviousBodyParts,
  allowPreviousExercises,
  allowOneSetExercises,
}

enum _PresetBundleStrategy { balancedWeeklyCoverage }

extension _PresetBundleStrategyLabel on _PresetBundleStrategy {
  String get label {
    switch (this) {
      case _PresetBundleStrategy.balancedWeeklyCoverage:
        return 'balanced-weekly-coverage';
    }
  }
}

extension _BundleFallbackStageLabel on _BundleFallbackStage {
  String get label {
    switch (this) {
      case _BundleFallbackStage.normal:
        return 'normal';
      case _BundleFallbackStage.allowPreviousBodyParts:
        return 'allow-previous-bodyparts';
      case _BundleFallbackStage.allowPreviousExercises:
        return 'allow-previous-exercises';
      case _BundleFallbackStage.allowOneSetExercises:
        return 'allow-one-set-exercises';
    }
  }
}

class _GeneratedPlanSelection {
  final List<CandidateExercisePlan> selected;
  final _BundleFallbackStage fallbackStage;

  const _GeneratedPlanSelection({
    required this.selected,
    required this.fallbackStage,
  });
}

class _GenerationSelectionOptions {
  final Set<int> blockedExerciseIds;
  final Set<int> penalizedBodyPartIds;

  const _GenerationSelectionOptions({
    this.blockedExerciseIds = const <int>{},
    this.penalizedBodyPartIds = const <int>{},
  });
}

class _PresetBundleGenerationState {
  final _PresetBundleStrategy strategy;
  final Map<int, double> projectedBodyUnits;
  final Map<int, double> projectedMuscleUnits;
  Set<int> previousPlanExerciseIds = const <int>{};
  Set<int> previousPlanHeavyBodyPartIds = const <int>{};

  _PresetBundleGenerationState({
    required this.strategy,
    required this.projectedBodyUnits,
    required this.projectedMuscleUnits,
  });

  factory _PresetBundleGenerationState.fromTargets({
    required _PresetBundleStrategy strategy,
    required List<BodyPartTarget> bodyTargets,
    required List<MuscleTarget> muscleTargets,
  }) {
    return _PresetBundleGenerationState(
      strategy: strategy,
      projectedBodyUnits: {
        for (final target in bodyTargets)
          target.bodyPart.id: target.doneThisWeek,
      },
      projectedMuscleUnits: {
        for (final target in muscleTargets)
          target.muscleId: target.doneThisWeek,
      },
    );
  }
}

extension _PresetBundlePlanner on PresetGenerationService {
  /// Chooses the best available plan for either preset generation or optimized
  /// workout start.
  ///
  /// The targeted candidate pool is preferred. If no targeted candidate can be
  /// selected inside the constraints, the fallback pool keeps the feature usable
  /// by considering profile-compatible catalog exercises.
  Future<List<CandidateExercisePlan>> _selectGeneratedPlan({
    required SessionSpec spec,
    required List<BodyPartTarget> bodyTargets,
    required List<MuscleTarget> muscleTargets,
  }) async {
    return _selectGeneratedPlanWithOptions(
      spec: spec,
      bodyTargets: bodyTargets,
      muscleTargets: muscleTargets,
      options: const _GenerationSelectionOptions(),
    );
  }

  Future<_GeneratedPlanSelection> _selectGeneratedPlanForBundle({
    required SessionSpec spec,
    required List<BodyPartTarget> baseBodyTargets,
    required List<MuscleTarget> baseMuscleTargets,
    required _PresetBundleGenerationState state,
  }) async {
    for (final stage in _BundleFallbackStage.values) {
      final stageSpec = _specForBundleStage(spec, stage);
      final selected = await _selectGeneratedPlanWithOptions(
        spec: stageSpec,
        bodyTargets: _bodyTargetsWithProjectedVolume(
          baseBodyTargets,
          state.projectedBodyUnits,
        ),
        muscleTargets: _muscleTargetsWithProjectedVolume(
          baseMuscleTargets,
          state.projectedMuscleUnits,
        ),
        options: _optionsForBundleStage(stage, state),
      );
      if (selected.isNotEmpty) {
        return _GeneratedPlanSelection(
          selected: selected,
          fallbackStage: stage,
        );
      }
    }

    return const _GeneratedPlanSelection(
      selected: <CandidateExercisePlan>[],
      fallbackStage: _BundleFallbackStage.allowOneSetExercises,
    );
  }

  Future<List<CandidateExercisePlan>> _selectGeneratedPlanWithOptions({
    required SessionSpec spec,
    required List<BodyPartTarget> bodyTargets,
    required List<MuscleTarget> muscleTargets,
    required _GenerationSelectionOptions options,
  }) async {
    final avoidedBodyPartIds = await _bodyPartIdsToAvoid(spec);

    if (bodyTargets.isNotEmpty) {
      final candidates = _prepareCandidatesForSelection(
        await _buildCandidatePool(
          spec: spec,
          targets: bodyTargets,
          muscleTargets: muscleTargets,
          avoidedBodyPartIds: avoidedBodyPartIds,
        ),
        options,
      );

      if (candidates.isNotEmpty) {
        _sortCandidates(candidates);
        final selected = _staggerExercises(
          _selectWithinTimeBudget(candidates, spec, bodyTargets, muscleTargets),
        );
        if (selected.isNotEmpty) {
          return selected;
        }
      }
    }

    final fallback = _prepareCandidatesForSelection(
      await _buildFallbackCandidatePool(
        spec: spec,
        avoidedBodyPartIds: avoidedBodyPartIds,
      ),
      options,
    );
    _sortCandidates(fallback);
    return _staggerExercises(
      _selectWithinTimeBudget(fallback, spec, bodyTargets, muscleTargets),
    );
  }

  /// Counts bodyparts whose recent volume is already within one unit of their
  /// current target boundary. This drives the "take time to rest" warning.
  int _nearBodyPartLimitCount(List<BodyPartTarget> bodyTargets) {
    var count = 0;
    for (final target in bodyTargets) {
      if (target.weeklyTargetUnits <= 0) continue;
      final nearLimitAt = math.max(0.0, target.weeklyTargetUnits - 1.0);
      if (target.doneThisWeek >= nearLimitAt) {
        count++;
      }
    }
    return count;
  }

  SessionSpec _specForBundleStage(
    SessionSpec spec,
    _BundleFallbackStage stage,
  ) {
    if (stage == _BundleFallbackStage.allowOneSetExercises) {
      return spec;
    }

    final minSets = math
        .min(
          math.max(
            spec.minSetsPerExercise,
            SessionSpec.preferredMinSetsPerExercise,
          ),
          spec.maxSetsPerExercise,
        )
        .toInt();
    if (minSets == spec.minSetsPerExercise) return spec;
    return spec.copyWith(minSetsPerExercise: minSets);
  }

  _GenerationSelectionOptions _optionsForBundleStage(
    _BundleFallbackStage stage,
    _PresetBundleGenerationState state,
  ) {
    switch (stage) {
      case _BundleFallbackStage.normal:
        return _GenerationSelectionOptions(
          blockedExerciseIds: state.previousPlanExerciseIds,
          penalizedBodyPartIds: state.previousPlanHeavyBodyPartIds,
        );
      case _BundleFallbackStage.allowPreviousBodyParts:
        return _GenerationSelectionOptions(
          blockedExerciseIds: state.previousPlanExerciseIds,
        );
      case _BundleFallbackStage.allowPreviousExercises:
      case _BundleFallbackStage.allowOneSetExercises:
        return const _GenerationSelectionOptions();
    }
  }

  List<BodyPartTarget> _bodyTargetsWithProjectedVolume(
    List<BodyPartTarget> targets,
    Map<int, double> projectedBodyUnits,
  ) {
    return [
      for (final target in targets)
        target.copyWith(doneThisWeek: projectedBodyUnits[target.bodyPart.id]),
    ];
  }

  List<MuscleTarget> _muscleTargetsWithProjectedVolume(
    List<MuscleTarget> targets,
    Map<int, double> projectedMuscleUnits,
  ) {
    return [
      for (final target in targets)
        target.copyWith(doneThisWeek: projectedMuscleUnits[target.muscleId]),
    ];
  }

  List<CandidateExercisePlan> _prepareCandidatesForSelection(
    List<CandidateExercisePlan> candidates,
    _GenerationSelectionOptions options,
  ) {
    final filtered = [
      for (final candidate in candidates)
        if (!options.blockedExerciseIds.contains(candidate.def.id)) candidate,
    ];
    if (options.penalizedBodyPartIds.isEmpty) return filtered;

    return [
      for (final candidate in filtered)
        candidate.copyWith(
          score:
              _hitsAnyBodyPart(
                candidate.unitsPerSet,
                options.penalizedBodyPartIds,
              )
              ? candidate.score *
                    PresetGenerationService
                        ._previousPlanBodyPartPenaltyMultiplier
              : candidate.score,
        ),
    ];
  }

  void _sortCandidates(List<CandidateExercisePlan> candidates) {
    candidates.sort((a, b) {
      final byScore = _compareDescendingDouble(a.score, b.score);
      if (byScore != 0) return byScore;
      final byRating = b.def.rating.compareTo(a.def.rating);
      if (byRating != 0) return byRating;
      final byName = a.def.name.toLowerCase().compareTo(
        b.def.name.toLowerCase(),
      );
      if (byName != 0) return byName;
      return a.def.id.compareTo(b.def.id);
    });
  }

  int _compareDescendingDouble(double a, double b) {
    if ((a - b).abs() <= 0.000001) return 0;
    return b.compareTo(a);
  }

  void _applyPlanToBundleState(
    _PresetBundleGenerationState state,
    List<CandidateExercisePlan> selected,
  ) {
    for (final plan in selected) {
      for (final entry in plan.unitsPerSet.entries) {
        if (entry.value <= 0.0) continue;
        state.projectedBodyUnits[entry.key.id] =
            (state.projectedBodyUnits[entry.key.id] ?? 0.0) +
            entry.value * plan.suggestedSets;
      }
      for (final entry in plan.muscleUnitsPerSet.entries) {
        if (entry.value <= 0.0) continue;
        state.projectedMuscleUnits[entry.key] =
            (state.projectedMuscleUnits[entry.key] ?? 0.0) +
            entry.value * plan.suggestedSets;
      }
    }
  }

  Set<int> _heavyBodyPartIdsForPlan(List<CandidateExercisePlan> selected) {
    final totals = <int, double>{};
    for (final plan in selected) {
      for (final entry in plan.unitsPerSet.entries) {
        if (entry.value <= 0.0) continue;
        totals[entry.key.id] =
            (totals[entry.key.id] ?? 0.0) + entry.value * plan.suggestedSets;
      }
    }

    return {
      for (final entry in totals.entries)
        if (entry.value >= SessionSpec.recoverySignificantBodyPartUnits)
          entry.key,
    };
  }

  String _topBodyPartDebugLabel(List<CandidateExercisePlan> selected) {
    final bodyPartNamesById = <int, String>{};
    final totals = <int, double>{};
    for (final plan in selected) {
      for (final entry in plan.unitsPerSet.entries) {
        if (entry.value <= 0.0) continue;
        bodyPartNamesById[entry.key.id] = entry.key.name;
        totals[entry.key.id] =
            (totals[entry.key.id] ?? 0.0) + entry.value * plan.suggestedSets;
      }
    }
    final ranked = totals.entries.toList()
      ..sort((a, b) {
        final byUnits = b.value.compareTo(a.value);
        if (byUnits != 0) return byUnits;
        return (bodyPartNamesById[a.key] ?? '').compareTo(
          bodyPartNamesById[b.key] ?? '',
        );
      });
    if (ranked.isEmpty) return 'none';
    return ranked
        .take(3)
        .map(
          (entry) =>
              '${bodyPartNamesById[entry.key] ?? entry.key}:'
              '${entry.value.toStringAsFixed(1)}',
        )
        .join(', ');
  }

  Future<String> _pickUniquePresetName(
    SessionSpec spec,
    List<CandidateExercisePlan> selected,
  ) async {
    final generatedName = _bodyPartSummaryName(selected);
    final baseName = spec.name.isNotEmpty
        ? spec.name
        : generatedName ??
              'Auto preset ${spec.now.toIso8601String().split('T').first}';

    final rows = await _repo.fetchAllPresetsRaw(profileId: spec.profileId);
    final existingNames = rows
        .map((row) => row['name'])
        .whereType<String>()
        .toSet();

    var name = baseName;
    var suffix = 2;
    while (existingNames.contains(name)) {
      name = '$baseName ($suffix)';
      suffix++;
    }

    return name;
  }
}
