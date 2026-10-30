import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';
import '../utils/generated_weight_rounding.dart';
import 'generated_plan_validator.dart';
import 'starter_weight_recommendation_service.dart';

part 'preset_generation/generated_weight_estimator.dart';
part 'preset_generation/candidate_pool_scorer.dart';
part 'preset_generation/preset_bundle_planner.dart';

/// Builds generated presets and optimized workout plans from the user's
/// training preferences, exercise definitions, volume boundaries, rankings,
/// and optional recent workout history.
///
/// The service has two public use cases:
/// - "Generate Custom Preset" persists the selected plan as a saved preset.
/// - "Start Optimized Workout" reuses the selection logic without creating an
///   extra preset first.
///
/// The generation pipeline is:
/// 1. Convert rankings, boundaries, preferences, and history into targets.
/// 2. Build a scored exercise candidate pool from catalog definitions.
/// 3. Allocate sets inside the session time budget and volume limits.
/// 4. Stagger exercises so adjacent cards hit different primary bodyparts when
///    possible.
/// 5. Optionally generate reps and suggested weights from saved rep-max data.
class PresetGenerationService {
  static const int _candidateAnalysisConcurrency = 4;
  static const double _previousPlanBodyPartPenaltyMultiplier = 0.25;

  final AppRepository _repo;
  final StarterWeightRecommendationService _starterWeightService =
      StarterWeightRecommendationService();
  Future<double?>? _bodyWeightLbsFuture;

  PresetGenerationService(this._repo);

  /// Convenience wrapper for callers that only need the newly-created preset ID.
  Future<int> generatePreset(SessionSpec spec) async {
    final result = await generatePresetWithDetails(spec);
    return result.presetId;
  }

  /// Generates and saves a preset, returning extra metadata the UI can surface
  /// to the user, such as exercises that had no weight history available.
  Future<PresetGenerationResult> generatePresetWithDetails(
    SessionSpec spec,
  ) async {
    final end = spec.now;
    final start = end.subtract(spec.historyWindow);

    final bodyTargets = await _loadBodyPartTargets(
      spec: spec,
      start: start,
      end: end,
    );
    final muscleTargets = await _loadMuscleTargets(
      spec: spec,
      start: start,
      end: end,
    );

    final selected = await _selectGeneratedPlan(
      spec: spec,
      bodyTargets: bodyTargets,
      muscleTargets: muscleTargets,
    );

    return _createPresetInDb(spec, selected, bodyTargets: bodyTargets);
  }

  Future<PresetBundleGenerationResult> generatePresetBundle(
    SessionSpec spec, {
    required int planCount,
  }) async {
    final requestedCount = planCount
        .clamp(1, SessionSpec.maxGeneratedPlansPerBundle)
        .toInt();
    if (requestedCount == 1) {
      final result = await generatePresetWithDetails(spec);
      return PresetBundleGenerationResult(
        plans: [result],
        requestedCount: requestedCount,
      );
    }

    final end = spec.now;
    final start = end.subtract(spec.historyWindow);
    final baseBodyTargets = await _loadBodyPartTargets(
      spec: spec,
      start: start,
      end: end,
    );
    final baseMuscleTargets = await _loadMuscleTargets(
      spec: spec,
      start: start,
      end: end,
    );
    final state = _PresetBundleGenerationState.fromTargets(
      strategy: _PresetBundleStrategy.balancedWeeklyCoverage,
      bodyTargets: baseBodyTargets,
      muscleTargets: baseMuscleTargets,
    );

    final results = <PresetGenerationResult>[];
    for (var index = 0; index < requestedCount; index++) {
      final selection = await _selectGeneratedPlanForBundle(
        spec: spec,
        baseBodyTargets: baseBodyTargets,
        baseMuscleTargets: baseMuscleTargets,
        state: state,
      );
      if (selection.selected.isEmpty) {
        debugPrint(
          '[preset-bundle] stopped at ${index + 1}/$requestedCount: no viable plan',
        );
        break;
      }

      final result = await _createPresetInDb(
        spec,
        selection.selected,
        bodyTargets: baseBodyTargets,
      );
      results.add(result);
      _applyPlanToBundleState(state, selection.selected);
      state.previousPlanExerciseIds = {
        for (final plan in selection.selected) plan.def.id,
      };
      state.previousPlanHeavyBodyPartIds = _heavyBodyPartIdsForPlan(
        selection.selected,
      );

      debugPrint(
        '[preset-bundle] plan ${index + 1}/$requestedCount '
        'stage=${selection.fallbackStage.label} '
        'top=${_topBodyPartDebugLabel(selection.selected)}',
      );
    }

    debugPrint(
      '[preset-bundle] strategy=${state.strategy.label} '
      'requested=$requestedCount generated=${results.length}',
    );
    return PresetBundleGenerationResult(
      plans: results,
      requestedCount: requestedCount,
    );
  }

  /// Preflight check for optimized workouts.
  ///
  /// The button should warn the user to rest instead of starting a session when
  /// recent training already has several bodyparts near their target boundary,
  /// or when the only viable plan would require multiple one-set exercises.
  Future<bool> shouldRestBeforeOptimizedWorkout(SessionSpec spec) async {
    final end = spec.now;
    final start = end.subtract(spec.historyWindow);
    final bodyTargets = await _loadBodyPartTargets(
      spec: spec,
      start: start,
      end: end,
    );
    if (bodyTargets.isEmpty) return false;

    if (_nearBodyPartLimitCount(bodyTargets) >=
        SessionSpec.restWarningBodyPartLimitCount) {
      return true;
    }

    final muscleTargets = await _loadMuscleTargets(
      spec: spec,
      start: start,
      end: end,
    );
    final selected = await _selectGeneratedPlan(
      spec: spec,
      bodyTargets: bodyTargets,
      muscleTargets: muscleTargets,
    );
    final oneSetExercises = selected
        .where((plan) => plan.suggestedSets == 1)
        .length;

    return oneSetExercises >= SessionSpec.oneSetExerciseRestWarningCount;
  }

  /// Persists the selected plan as a normal preset, then initializes automatic
  /// preset settings so the saved preset can participate in progression logic.
  Future<PresetGenerationResult> _createPresetInDb(
    SessionSpec spec,
    List<CandidateExercisePlan> selected, {
    List<BodyPartTarget> bodyTargets = const <BodyPartTarget>[],
  }) async {
    if (selected.isEmpty) {
      throw StateError(
        'No exercises matched the selected profile and generation settings.',
      );
    }
    GeneratedPlanValidator.validateOrThrow(spec: spec, plans: selected);
    final name = await _pickUniquePresetName(spec, selected);
    final missingWeightHistoryNames = <String>{};
    final starterWeightEstimateNames = <String>{};
    final unavailableStarterWeightNames = <String>{};
    final writes = <WorkoutExerciseWrite>[];

    for (final candidate in selected) {
      final parents = await _buildGeneratedSets(
        spec: spec,
        candidate: candidate,
        bodyTargets: bodyTargets,
        missingWeightHistoryNames: missingWeightHistoryNames,
        starterWeightEstimateNames: starterWeightEstimateNames,
        unavailableStarterWeightNames: unavailableStarterWeightNames,
      );

      writes.add(
        WorkoutExerciseWrite(
          exercise: WeightExercise(
            name: candidate.def.name,
            equipment: candidate.def.equipmentList.isEmpty
                ? ''
                : candidate.def.equipmentList.first.name,
            sets: parents,
          ),
          type: 'weight',
          definitionId: candidate.def.id,
        ),
      );
    }

    final presetId = await _repo.createPresetAtomic(
      name: name,
      profileId: spec.profileId,
      exercises: writes,
      autoSettings: PresetAutoSettingsWrite(
        isAutomatic: true,
        globalIncrement: 5.0,
        skipFirstSet: true,
        weightCheck: true,
        repCheck: true,
        volumeCheck: false,
        adjustAllSets: false,
        useManualSelect: false,
        successCountMode: ProgressionSuccessScope.set.name,
      ),
    );

    return PresetGenerationResult(
      presetId: presetId,
      exercisesMissingWeightHistory: missingWeightHistoryNames.toList()..sort(),
      exercisesWithStarterWeightEstimates: starterWeightEstimateNames.toList()
        ..sort(),
      exercisesWithUnavailableStarterWeights:
          unavailableStarterWeightNames.toList()..sort(),
    );
  }

  /// Test seam for exercise-aware target rep selection.
  @visibleForTesting
  int debugEffectiveTargetReps(ExerciseDefinition def, int requestedReps) {
    return _effectiveTargetReps(def, requestedReps);
  }

  /// Test seam for the RIR-based conversion from capability to working weight.
  @visibleForTesting
  double debugWorkingWeightFromOneRepMax({
    required double oneRepMaxEstimate,
    required int targetReps,
    required int additionalRir,
    required StarterWeightIntensity intensity,
  }) {
    return _workingWeightFromOneRepMax(
      oneRepMaxEstimate: oneRepMaxEstimate,
      targetReps: targetReps,
      additionalRir: additionalRir,
      intensity: intensity,
    );
  }

  /// Test seam for optimized-workout fatigue scaling.
  @visibleForTesting
  double debugOptimizedFatigueMultiplier({
    required SessionSpec spec,
    required CandidateExercisePlan candidate,
    required List<BodyPartTarget> bodyTargets,
  }) {
    return _optimizedFatigueMultiplier(
      spec: spec,
      candidate: candidate,
      bodyTargets: bodyTargets,
    );
  }
}
