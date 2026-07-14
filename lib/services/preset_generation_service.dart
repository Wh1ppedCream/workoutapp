import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';
import '../utils/generated_weight_rounding.dart';
import 'starter_weight_recommendation_service.dart';

enum _GeneratedWeightHistoryScope { recent, allTime }

enum _GeneratedWeightSource {
  recentHistoryBlend,
  allTimeHistoryBlend,
  starterEstimate,
  bodyweightOnly,
  unavailable,
}

extension on _GeneratedWeightSource {
  String get debugLabel {
    return switch (this) {
      _GeneratedWeightSource.recentHistoryBlend => 'recent-history-blend',
      _GeneratedWeightSource.allTimeHistoryBlend => 'all-time-history-blend',
      _GeneratedWeightSource.starterEstimate => 'starter-estimate',
      _GeneratedWeightSource.bodyweightOnly => 'bodyweight-only',
      _GeneratedWeightSource.unavailable => 'unavailable',
    };
  }
}

class _GeneratedWeightHistory {
  final List<RepMaxRow> rows;
  final _GeneratedWeightHistoryScope scope;

  const _GeneratedWeightHistory({required this.rows, required this.scope});
}

class _GeneratedWeightTarget {
  final double weight;
  final double sourceEstimate;
  final double workingWeight;
  final _GeneratedWeightSource source;
  final double fatigueMultiplier;

  const _GeneratedWeightTarget({
    required this.weight,
    required this.sourceEstimate,
    required this.workingWeight,
    required this.source,
    this.fatigueMultiplier = 1.0,
  });

  bool get usesStarterEstimate =>
      source == _GeneratedWeightSource.starterEstimate;

  _GeneratedWeightTarget copyWithWorkingWeight({
    required double weight,
    required double workingWeight,
    required double fatigueMultiplier,
  }) {
    return _GeneratedWeightTarget(
      weight: weight,
      sourceEstimate: sourceEstimate,
      workingWeight: workingWeight,
      source: source,
      fatigueMultiplier: fatigueMultiplier,
    );
  }
}

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

    return _createPresetInDb(
      spec,
      selected,
      bodyTargets: bodyTargets,
    );
  }

  Future<PresetBundleGenerationResult> generatePresetBundle(
    SessionSpec spec, {
    required int planCount,
  }) async {
    final requestedCount =
        planCount.clamp(1, SessionSpec.maxGeneratedPlansPerBundle).toInt();
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
    final oneSetExercises =
        selected.where((plan) => plan.suggestedSets == 1).length;

    return oneSetExercises >= SessionSpec.oneSetExerciseRestWarningCount;
  }

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

  /// Returns bodyparts from the most recent session so optimized workouts can
  /// avoid immediately repeating the bodypart that was worked the most.
  Future<Set<int>> _bodyPartIdsToAvoid(SessionSpec spec) async {
    if (!spec.avoidMostRecentBodyPart || !spec.useRecentTrainingHistory) {
      return const <int>{};
    }

    final sessions = await _repo.fetchAllSessions();
    if (sessions.isEmpty) return const <int>{};

    Map<String, dynamic>? latestSession;
    DateTime? latestDate;
    for (final session in sessions) {
      final rawDate = session['date'];
      if (rawDate is! String) continue;
      final date = DateTime.tryParse(rawDate);
      if (date == null || date.isAfter(spec.now)) continue;
      if (latestDate == null || date.isAfter(latestDate)) {
        latestDate = date;
        latestSession = session;
      }
    }

    if (latestSession == null || latestDate == null) return const <int>{};

    final bodyPartSets = await _repo.fetchAllBodyPartSetsOverTimeRange(
      start: latestDate.subtract(const Duration(seconds: 1)),
      end: latestDate.add(const Duration(seconds: 1)),
    );
    if (bodyPartSets.isEmpty) return const <int>{};

    final maxUnits = bodyPartSets.values.fold<double>(
      0.0,
      (max, value) => value > max ? value : max,
    );
    if (maxUnits <= 0.0) return const <int>{};

    return {
      for (final entry in bodyPartSets.entries)
        if ((entry.value - maxUnits).abs() < 0.0001) entry.key.id,
    };
  }

  List<CandidateExercisePlan> _avoidBodyPartsWhenPossible(
    List<CandidateExercisePlan> candidates,
    Set<int> avoidedBodyPartIds,
  ) {
    if (candidates.isEmpty || avoidedBodyPartIds.isEmpty) {
      return candidates;
    }

    final preferred =
        candidates
            .where(
              (candidate) =>
                  !_hitsAnyBodyPart(candidate.unitsPerSet, avoidedBodyPartIds),
            )
            .toList();
    return preferred.isEmpty ? candidates : preferred;
  }

  Set<int> _autoAvoidedBodyPartIdsForSpec(
    SessionSpec spec,
    Set<int> avoidedBodyPartIds,
  ) {
    if (avoidedBodyPartIds.isEmpty || spec.preferredBodypartIds.isEmpty) {
      return avoidedBodyPartIds;
    }
    return avoidedBodyPartIds.difference(spec.preferredBodypartIds.toSet());
  }

  bool _hitsAnyBodyPart(
    Map<BodyPart, double> unitsPerSet,
    Set<int> bodyPartIds,
  ) {
    return unitsPerSet.entries.any(
      (entry) => entry.value > 0.0 && bodyPartIds.contains(entry.key.id),
    );
  }

  double _hitUnitsForBodyParts(
    Map<BodyPart, double> unitsPerSet,
    Set<int> bodyPartIds,
  ) {
    if (bodyPartIds.isEmpty) return 0.0;
    var total = 0.0;
    for (final entry in unitsPerSet.entries) {
      if (entry.value <= 0.0 || !bodyPartIds.contains(entry.key.id)) {
        continue;
      }
      total += entry.value;
    }
    return total;
  }

  /// Builds bodypart targets from volume bounds, optional recent history, and
  /// the current priority mode.
  ///
  /// Preferred bodyparts increase bias, blacklisted bodyparts receive no bias,
  /// and muscle-ranking mode only opens bodyparts linked to ranked muscles.
  Future<List<BodyPartTarget>> _loadBodyPartTargets({
    required SessionSpec spec,
    required DateTime start,
    required DateTime end,
  }) async {
    final allBodyParts = await _repo.fetchAllBodyParts();
    final historyById = <int, double>{};
    if (spec.useRecentTrainingHistory) {
      final historyMap = await _repo.fetchAllBodyPartSetsOverTimeRange(
        start: start,
        end: end,
      );
      historyMap.forEach((bp, value) {
        historyById[bp.id] = value;
      });
    }

    final bodyPartRankWeights =
        spec.priorityMode == TrainingPriorityMode.bodyPartRanking
            ? _bodyPartRankWeights(await _repo.getAllBodyPartRanks())
            : <int, double>{};
    final rankedMuscleBodyParts =
        spec.priorityMode == TrainingPriorityMode.muscleRanking
            ? await _bodyPartIdsForRankedMuscles()
            : <int>{};

    final result = <BodyPartTarget>[];
    for (final bodyPart in allBodyParts) {
      final bounds = await _repo.fetchBodyPartVolumeBounds(bodyPart.id);
      final targetUnits = _weeklyTargetUnits(bounds);
      final done = historyById[bodyPart.id] ?? 0.0;
      final biasWeight = _bodyPartBiasWeight(
        spec: spec,
        bodyPartId: bodyPart.id,
        rankedWeights: bodyPartRankWeights,
        rankedMuscleBodyParts: rankedMuscleBodyParts,
      );

      result.add(
        BodyPartTarget(
          bodyPart: bodyPart,
          weeklyTargetUnits: targetUnits,
          doneThisWeek: done,
          biasWeight: biasWeight,
        ),
      );
    }

    return result;
  }

  /// Builds muscle targets only for muscle-ranking mode.
  ///
  /// In other modes bodypart targets are enough, so this returns an empty list.
  Future<List<MuscleTarget>> _loadMuscleTargets({
    required SessionSpec spec,
    required DateTime start,
    required DateTime end,
  }) async {
    if (spec.priorityMode != TrainingPriorityMode.muscleRanking) {
      return const [];
    }

    final ranks = await _repo.getAllMuscleRanks();
    if (ranks.isEmpty) return const [];

    final rankWeights = _muscleRankWeights(ranks);
    final historyById =
        spec.useRecentTrainingHistory
            ? await _repo.fetchSetsPerMuscle(start: start, end: end)
            : <int, double>{};
    final result = <MuscleTarget>[];

    for (final rank in ranks) {
      final bounds = await _repo.fetchMuscleVolumeBounds(rank.muscleId);
      result.add(
        MuscleTarget(
          muscleId: rank.muscleId,
          weeklyTargetUnits: _weeklyTargetUnits(bounds),
          doneThisWeek: historyById[rank.muscleId] ?? 0.0,
          biasWeight: rankWeights[rank.muscleId] ?? 1.0,
        ),
      );
    }

    return result;
  }

  /// Converts catalog exercise definitions into scored candidates.
  ///
  /// A candidate is discarded if it hits blacklisted bodyparts, has no useful
  /// bodypart/muscle mapping, or cannot help any active target. Otherwise its
  /// score combines target deficit, ranking/preference bias, and exercise
  /// rating. Suggested sets start from the target deficit ratio, then later get
  /// clamped by time and volume limits.
  Future<List<CandidateExercisePlan>> _buildCandidatePool({
    required SessionSpec spec,
    required List<BodyPartTarget> targets,
    required List<MuscleTarget> muscleTargets,
    required Set<int> avoidedBodyPartIds,
  }) async {
    final targetById = {
      for (final target in targets) target.bodyPart.id: target,
    };
    final muscleTargetById = {
      for (final target in muscleTargets) target.muscleId: target,
    };

    final activeBodyPartIds =
        targets
            .where((target) => target.biasWeight > 0 && target.deficit > 0)
            .map((target) => target.bodyPart.id)
            .toList();
    final activeMuscleIds =
        muscleTargets
            .where((target) => target.biasWeight > 0 && target.deficit > 0)
            .map((target) => target.muscleId)
            .toList();

    if (spec.priorityMode == TrainingPriorityMode.bodyPartRanking &&
        activeBodyPartIds.isEmpty) {
      return const [];
    }
    if (spec.priorityMode == TrainingPriorityMode.muscleRanking &&
        activeMuscleIds.isEmpty &&
        spec.preferredBodypartIds.isEmpty) {
      return const [];
    }

    final preferredBodyPartIds = spec.preferredBodypartIds.toSet();
    final defs = await _repo.fetchCatalogDefinitions(
      useProfileFilter: true,
      profileId: spec.profileId,
      equipmentFilter: null,
      bodypartIds:
          spec.priorityMode == TrainingPriorityMode.bodyPartRanking
              ? activeBodyPartIds
              : spec.focusBodypartIds.isEmpty
              ? null
              : spec.focusBodypartIds,
      muscleIds:
          spec.priorityMode == TrainingPriorityMode.muscleRanking &&
                  preferredBodyPartIds.isEmpty
              ? activeMuscleIds
              : null,
    );

    final blacklistedBodyPartIds = spec.blacklistedBodypartIds.toSet();
    final candidates = await _mapDefinitionsWithConcurrency(defs, (def) async {
      final unitsPerSet = await _repo.computeBodyPartPercents(def.id);
      if (unitsPerSet.isEmpty) return null;
      if (_hitsAnyBodyPart(unitsPerSet, blacklistedBodyPartIds)) {
        return null;
      }
      final preferredHitUnits = _hitUnitsForBodyParts(
        unitsPerSet,
        preferredBodyPartIds,
      );

      final muscleUnitsPerSet = {
        for (final row in await _repo.computeMusclePercents(def.id))
          if (row.percent > 0) row.muscleId: row.percent,
      };

      var scoreResult =
          spec.priorityMode == TrainingPriorityMode.muscleRanking &&
                  muscleTargetById.isNotEmpty
              ? _scoreAgainstMuscles(
                muscleUnitsPerSet: muscleUnitsPerSet,
                targetById: muscleTargetById,
              )
              : _scoreAgainstBodyParts(
                unitsPerSet: unitsPerSet,
                targetById: targetById,
              );
      if ((scoreResult.score <= 0 || scoreResult.hitUnits <= 0) &&
          preferredHitUnits > 0.0) {
        scoreResult = _scoreAgainstBodyParts(
          unitsPerSet: unitsPerSet,
          targetById: targetById,
        );
      }

      if (scoreResult.score <= 0 || scoreResult.hitUnits <= 0) return null;

      final rating = def.rating.toDouble();
      final ratingFactor =
          rating <= 0 ? 1.0 : (0.5 + rating / 100.0).clamp(0.5, 2.0);
      var score = scoreResult.score * ratingFactor;
      if (preferredHitUnits > 0.0) {
        score *=
            1.0 +
            preferredHitUnits *
                SessionSpec.preferredBodypartCandidateScoreMultiplier;
      }
      if (score <= 0.0) return null;

      final deficitRatio = scoreResult.deficitRatio;
      final setRange = spec.maxSetsPerExercise - spec.minSetsPerExercise;
      final suggestedSets =
          (spec.minSetsPerExercise + deficitRatio * setRange)
              .round()
              .clamp(spec.minSetsPerExercise, spec.maxSetsPerExercise)
              .toInt();

      return CandidateExercisePlan(
        def: def,
        unitsPerSet: unitsPerSet,
        muscleUnitsPerSet: muscleUnitsPerSet,
        score: score,
        suggestedSets: suggestedSets,
      );
    });

    return _avoidBodyPartsWhenPossible(
      candidates,
      _autoAvoidedBodyPartIdsForSpec(spec, avoidedBodyPartIds),
    );
  }

  SessionSpec _specForBundleStage(
    SessionSpec spec,
    _BundleFallbackStage stage,
  ) {
    if (stage == _BundleFallbackStage.allowOneSetExercises) {
      return spec;
    }

    final minSets =
        math
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
                  ? candidate.score * _previousPlanBodyPartPenaltyMultiplier
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
    final ranked =
        totals.entries.toList()..sort((a, b) {
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

  /// Allocates exercises and set counts while tracking projected bodypart and
  /// muscle volume.
  ///
  /// This is where preferred bodyparts are guaranteed coverage when viable,
  /// session minutes are spent, one-set exercises are avoided where possible,
  /// and weekly/session bodypart limits prevent over-allocation.
  List<CandidateExercisePlan> _selectWithinTimeBudget(
    List<CandidateExercisePlan> rankedCandidates,
    SessionSpec spec,
    List<BodyPartTarget> bodyTargets,
    List<MuscleTarget> muscleTargets,
  ) {
    final bodyTargetById = {
      for (final target in bodyTargets) target.bodyPart.id: target,
    };
    final muscleTargetById = {
      for (final target in muscleTargets) target.muscleId: target,
    };
    final projectedBodyUnits = {
      for (final target in bodyTargets) target.bodyPart.id: target.doneThisWeek,
    };
    final projectedSessionBodyUnits = {
      for (final target in bodyTargets) target.bodyPart.id: 0.0,
    };
    final projectedMuscleUnits = {
      for (final target in muscleTargets) target.muscleId: target.doneThisWeek,
    };

    final selected = <CandidateExercisePlan>[];
    final remainingCandidates = [...rankedCandidates];
    final budget = spec.sessionDurationMinutes;
    var usedMinutes = 0;

    usedMinutes = _coverPreferredBodyParts(
      spec: spec,
      remainingCandidates: remainingCandidates,
      selected: selected,
      usedMinutes: usedMinutes,
      budget: budget,
      bodyTargetById: bodyTargetById,
      muscleTargetById: muscleTargetById,
      projectedBodyUnits: projectedBodyUnits,
      projectedSessionBodyUnits: projectedSessionBodyUnits,
      projectedMuscleUnits: projectedMuscleUnits,
    );

    for (final candidate in remainingCandidates) {
      if (selected.length >= spec.maxExercises) break;

      final targetLimitedSets = _maxAllowedSetsForTargets(
        candidate: candidate,
        spec: spec,
        bodyTargetById: bodyTargetById,
        muscleTargetById: muscleTargetById,
        projectedBodyUnits: projectedBodyUnits,
        projectedSessionBodyUnits: projectedSessionBodyUnits,
        projectedMuscleUnits: projectedMuscleUnits,
      );
      if (targetLimitedSets < spec.minSetsPerExercise) continue;

      final preferredMinSets = _preferredMinSetsFor(
        spec: spec,
        targetLimitedSets: targetLimitedSets,
      );
      final boundedSuggestedSets =
          candidate.suggestedSets
              .clamp(spec.minSetsPerExercise, spec.maxSetsPerExercise)
              .toInt();
      final desiredSets =
          math
              .min(
                math.max(boundedSuggestedSets, preferredMinSets),
                targetLimitedSets,
              )
              .toInt();
      final desiredMinutes = _estimatedMinutesForExercise(desiredSets, spec);

      if (usedMinutes + desiredMinutes <= budget) {
        selected.add(candidate.copyWith(suggestedSets: desiredSets));
        usedMinutes += desiredMinutes;
        _applyProjectedVolume(
          candidate: candidate,
          sets: desiredSets,
          bodyTargetById: bodyTargetById,
          muscleTargetById: muscleTargetById,
          projectedBodyUnits: projectedBodyUnits,
          projectedSessionBodyUnits: projectedSessionBodyUnits,
          projectedMuscleUnits: projectedMuscleUnits,
        );
        continue;
      }

      final affordableSets =
          (budget - usedMinutes - spec.setupMinutesPerExercise) ~/
          spec.minutesPerSet;
      final reducedSets =
          math
              .min(desiredSets, math.min(affordableSets, targetLimitedSets))
              .toInt();
      if (reducedSets >= preferredMinSets ||
          (selected.isEmpty && reducedSets >= spec.minSetsPerExercise)) {
        selected.add(candidate.copyWith(suggestedSets: reducedSets));
        usedMinutes += _estimatedMinutesForExercise(reducedSets, spec);
        _applyProjectedVolume(
          candidate: candidate,
          sets: reducedSets,
          bodyTargetById: bodyTargetById,
          muscleTargetById: muscleTargetById,
          projectedBodyUnits: projectedBodyUnits,
          projectedSessionBodyUnits: projectedSessionBodyUnits,
          projectedMuscleUnits: projectedMuscleUnits,
        );
      }
      break;
    }

    while (budget - usedMinutes >= spec.minutesPerSet) {
      var addedSet = false;
      for (var i = 0; i < selected.length; i++) {
        final plan = selected[i];
        if (plan.suggestedSets >= spec.maxSetsPerExercise) continue;
        if (!_canAddSet(
          candidate: plan,
          bodyTargetById: bodyTargetById,
          muscleTargetById: muscleTargetById,
          projectedBodyUnits: projectedBodyUnits,
          projectedSessionBodyUnits: projectedSessionBodyUnits,
          projectedMuscleUnits: projectedMuscleUnits,
        )) {
          continue;
        }

        selected[i] = plan.copyWith(suggestedSets: plan.suggestedSets + 1);
        usedMinutes += spec.minutesPerSet;
        _applyProjectedVolume(
          candidate: plan,
          sets: 1,
          bodyTargetById: bodyTargetById,
          muscleTargetById: muscleTargetById,
          projectedBodyUnits: projectedBodyUnits,
          projectedSessionBodyUnits: projectedSessionBodyUnits,
          projectedMuscleUnits: projectedMuscleUnits,
        );
        addedSet = true;
        break;
      }
      if (!addedSet) break;
    }

    return selected;
  }

  int _coverPreferredBodyParts({
    required SessionSpec spec,
    required List<CandidateExercisePlan> remainingCandidates,
    required List<CandidateExercisePlan> selected,
    required int usedMinutes,
    required int budget,
    required Map<int, BodyPartTarget> bodyTargetById,
    required Map<int, MuscleTarget> muscleTargetById,
    required Map<int, double> projectedBodyUnits,
    required Map<int, double> projectedSessionBodyUnits,
    required Map<int, double> projectedMuscleUnits,
  }) {
    if (spec.preferredBodypartIds.isEmpty) return usedMinutes;

    var minutesUsed = usedMinutes;
    for (final preferredBodyPartId in spec.preferredBodypartIds) {
      if (selected.length >= spec.maxExercises) break;
      if (_hasFocusedBodyPart(selected, preferredBodyPartId)) continue;

      var coverage = _bestPreferredCoverageCandidate(
        bodyPartId: preferredBodyPartId,
        requirePrimaryBodyPart: true,
        remainingCandidates: remainingCandidates,
        spec: spec,
        usedMinutes: minutesUsed,
        budget: budget,
        bodyTargetById: bodyTargetById,
        muscleTargetById: muscleTargetById,
        projectedBodyUnits: projectedBodyUnits,
        projectedSessionBodyUnits: projectedSessionBodyUnits,
        projectedMuscleUnits: projectedMuscleUnits,
      );

      coverage ??= _bestPreferredCoverageCandidate(
        bodyPartId: preferredBodyPartId,
        requirePrimaryBodyPart: false,
        remainingCandidates: remainingCandidates,
        spec: spec,
        usedMinutes: minutesUsed,
        budget: budget,
        bodyTargetById: bodyTargetById,
        muscleTargetById: muscleTargetById,
        projectedBodyUnits: projectedBodyUnits,
        projectedSessionBodyUnits: projectedSessionBodyUnits,
        projectedMuscleUnits: projectedMuscleUnits,
      );

      if (coverage == null) continue;

      final candidate = remainingCandidates.removeAt(coverage.index);
      selected.add(candidate.copyWith(suggestedSets: coverage.sets));
      minutesUsed += _estimatedMinutesForExercise(coverage.sets, spec);
      _applyProjectedVolume(
        candidate: candidate,
        sets: coverage.sets,
        bodyTargetById: bodyTargetById,
        muscleTargetById: muscleTargetById,
        projectedBodyUnits: projectedBodyUnits,
        projectedSessionBodyUnits: projectedSessionBodyUnits,
        projectedMuscleUnits: projectedMuscleUnits,
      );
    }

    return minutesUsed;
  }

  _PreferredCoveragePick? _bestPreferredCoverageCandidate({
    required int bodyPartId,
    required bool requirePrimaryBodyPart,
    required List<CandidateExercisePlan> remainingCandidates,
    required SessionSpec spec,
    required int usedMinutes,
    required int budget,
    required Map<int, BodyPartTarget> bodyTargetById,
    required Map<int, MuscleTarget> muscleTargetById,
    required Map<int, double> projectedBodyUnits,
    required Map<int, double> projectedSessionBodyUnits,
    required Map<int, double> projectedMuscleUnits,
  }) {
    _PreferredCoveragePick? bestPick;
    var bestScore = double.negativeInfinity;

    for (var i = 0; i < remainingCandidates.length; i++) {
      final candidate = remainingCandidates[i];
      final bodyPartUnits = _unitsForBodyPart(candidate, bodyPartId);
      if (bodyPartUnits <= 0.0) continue;
      if (requirePrimaryBodyPart &&
          _primaryBodyPartId(candidate) != bodyPartId) {
        continue;
      }

      final targetLimitedSets = _maxAllowedSetsForTargets(
        candidate: candidate,
        spec: spec,
        bodyTargetById: bodyTargetById,
        muscleTargetById: muscleTargetById,
        projectedBodyUnits: projectedBodyUnits,
        projectedSessionBodyUnits: projectedSessionBodyUnits,
        projectedMuscleUnits: projectedMuscleUnits,
      );
      if (targetLimitedSets < spec.minSetsPerExercise) continue;

      final desiredSets = _preferredMinSetsFor(
        spec: spec,
        targetLimitedSets: targetLimitedSets,
      );
      final fittedSets = _fitSetsWithinBudget(
        desiredSets: desiredSets,
        targetLimitedSets: targetLimitedSets,
        minSets: spec.minSetsPerExercise,
        usedMinutes: usedMinutes,
        budget: budget,
        spec: spec,
      );
      if (fittedSets < spec.minSetsPerExercise) continue;

      final score = bodyPartUnits * fittedSets + candidate.score * 0.001;
      if (score > bestScore) {
        bestScore = score;
        bestPick = _PreferredCoveragePick(index: i, sets: fittedSets);
      }
    }

    return bestPick;
  }

  int _fitSetsWithinBudget({
    required int desiredSets,
    required int targetLimitedSets,
    required int minSets,
    required int usedMinutes,
    required int budget,
    required SessionSpec spec,
  }) {
    if (usedMinutes + _estimatedMinutesForExercise(desiredSets, spec) <=
        budget) {
      return desiredSets;
    }

    final affordableSets =
        (budget - usedMinutes - spec.setupMinutesPerExercise) ~/
        spec.minutesPerSet;
    final reducedSets = math.min(
      desiredSets,
      math.min(affordableSets, targetLimitedSets),
    );
    return reducedSets >= minSets ? reducedSets.toInt() : 0;
  }

  bool _hasFocusedBodyPart(
    List<CandidateExercisePlan> selected,
    int bodyPartId,
  ) {
    return selected.any(
      (candidate) => _primaryBodyPartId(candidate) == bodyPartId,
    );
  }

  double _unitsForBodyPart(CandidateExercisePlan candidate, int bodyPartId) {
    var total = 0.0;
    candidate.unitsPerSet.forEach((bodyPart, units) {
      if (bodyPart.id == bodyPartId && units > 0.0) {
        total += units;
      }
    });
    return total;
  }

  int _preferredMinSetsFor({
    required SessionSpec spec,
    required int targetLimitedSets,
  }) {
    final preferred =
        math
            .min(
              math.max(
                spec.minSetsPerExercise,
                SessionSpec.preferredMinSetsPerExercise,
              ),
              spec.maxSetsPerExercise,
            )
            .toInt();
    return targetLimitedSets >= preferred ? preferred : spec.minSetsPerExercise;
  }

  int _maxAllowedSetsForTargets({
    required CandidateExercisePlan candidate,
    required SessionSpec spec,
    required Map<int, BodyPartTarget> bodyTargetById,
    required Map<int, MuscleTarget> muscleTargetById,
    required Map<int, double> projectedBodyUnits,
    required Map<int, double> projectedSessionBodyUnits,
    required Map<int, double> projectedMuscleUnits,
  }) {
    var allowed = spec.maxSetsPerExercise;

    for (final entry in candidate.unitsPerSet.entries) {
      if (entry.value <= 0) continue;
      final target = bodyTargetById[entry.key.id];
      if (target == null) continue;
      final remaining = math.min(
        target.weeklyTargetUnits -
            (projectedBodyUnits[entry.key.id] ?? target.doneThisWeek),
        SessionSpec.maxBodyPartSetUnitsPerSession -
            (projectedSessionBodyUnits[entry.key.id] ?? 0.0),
      );
      if (remaining <= 0) return 0;
      allowed = math.min(allowed, (remaining / entry.value).floor());
    }

    for (final entry in candidate.muscleUnitsPerSet.entries) {
      if (entry.value <= 0) continue;
      final target = muscleTargetById[entry.key];
      if (target == null) continue;
      final remaining =
          target.weeklyTargetUnits -
          (projectedMuscleUnits[entry.key] ?? target.doneThisWeek);
      if (remaining <= 0) return 0;
      allowed = math.min(allowed, (remaining / entry.value).floor());
    }

    return allowed;
  }

  bool _canAddSet({
    required CandidateExercisePlan candidate,
    required Map<int, BodyPartTarget> bodyTargetById,
    required Map<int, MuscleTarget> muscleTargetById,
    required Map<int, double> projectedBodyUnits,
    required Map<int, double> projectedSessionBodyUnits,
    required Map<int, double> projectedMuscleUnits,
  }) {
    for (final entry in candidate.unitsPerSet.entries) {
      final target = bodyTargetById[entry.key.id];
      if (target == null || entry.value <= 0) continue;
      final next =
          (projectedBodyUnits[entry.key.id] ?? target.doneThisWeek) +
          entry.value;
      if (next > target.weeklyTargetUnits) return false;
      final nextSession =
          (projectedSessionBodyUnits[entry.key.id] ?? 0.0) + entry.value;
      if (nextSession > SessionSpec.maxBodyPartSetUnitsPerSession) {
        return false;
      }
    }

    for (final entry in candidate.muscleUnitsPerSet.entries) {
      final target = muscleTargetById[entry.key];
      if (target == null || entry.value <= 0) continue;
      final next =
          (projectedMuscleUnits[entry.key] ?? target.doneThisWeek) +
          entry.value;
      if (next > target.weeklyTargetUnits) return false;
    }

    return true;
  }

  void _applyProjectedVolume({
    required CandidateExercisePlan candidate,
    required int sets,
    required Map<int, BodyPartTarget> bodyTargetById,
    required Map<int, MuscleTarget> muscleTargetById,
    required Map<int, double> projectedBodyUnits,
    required Map<int, double> projectedSessionBodyUnits,
    required Map<int, double> projectedMuscleUnits,
  }) {
    for (final entry in candidate.unitsPerSet.entries) {
      if (!bodyTargetById.containsKey(entry.key.id)) continue;
      projectedBodyUnits[entry.key.id] =
          (projectedBodyUnits[entry.key.id] ?? 0.0) + entry.value * sets;
      projectedSessionBodyUnits[entry.key.id] =
          (projectedSessionBodyUnits[entry.key.id] ?? 0.0) + entry.value * sets;
    }
    for (final entry in candidate.muscleUnitsPerSet.entries) {
      if (!muscleTargetById.containsKey(entry.key)) continue;
      projectedMuscleUnits[entry.key] =
          (projectedMuscleUnits[entry.key] ?? 0.0) + entry.value * sets;
    }
  }

  /// Reorders selected exercises so different primary bodyparts alternate when
  /// possible, while preserving the ranked order as the fallback.
  List<CandidateExercisePlan> _staggerExercises(
    List<CandidateExercisePlan> selected,
  ) {
    final remaining = [...selected];
    final staggered = <CandidateExercisePlan>[];

    while (remaining.isNotEmpty) {
      if (staggered.isEmpty) {
        staggered.add(remaining.removeAt(0));
        continue;
      }

      final previous = staggered.last;
      final nextIndex = remaining.indexWhere(
        (candidate) => _canStaggerBetween(previous, candidate),
      );
      staggered.add(remaining.removeAt(nextIndex == -1 ? 0 : nextIndex));
    }

    return staggered;
  }

  bool _canStaggerBetween(
    CandidateExercisePlan previous,
    CandidateExercisePlan candidate,
  ) {
    final previousPrimary = _primaryBodyPartId(previous);
    final candidatePrimary = _primaryBodyPartId(candidate);
    if (previousPrimary == null || candidatePrimary == null) return false;
    if (previousPrimary == candidatePrimary) return false;

    final previousHitsCandidate = previous.unitsPerSet.entries.any(
      (entry) => entry.key.id == candidatePrimary && entry.value > 0,
    );
    final candidateHitsPrevious = candidate.unitsPerSet.entries.any(
      (entry) => entry.key.id == previousPrimary && entry.value > 0,
    );

    return !previousHitsCandidate && !candidateHitsPrevious;
  }

  int? _primaryBodyPartId(CandidateExercisePlan candidate) {
    if (candidate.unitsPerSet.isEmpty) return null;
    final ranked =
        candidate.unitsPerSet.entries.where((entry) => entry.value > 0).toList()
          ..sort((a, b) {
            final byUnits = b.value.compareTo(a.value);
            if (byUnits != 0) return byUnits;
            final byName = a.key.name.compareTo(b.key.name);
            if (byName != 0) return byName;
            return a.key.id.compareTo(b.key.id);
          });
    return ranked.isEmpty ? null : ranked.first.key.id;
  }

  int _estimatedMinutesForExercise(int sets, SessionSpec spec) {
    return spec.setupMinutesPerExercise + sets * spec.minutesPerSet;
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
            equipment:
                candidate.def.equipmentList.isEmpty
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
      exercisesWithStarterWeightEstimates:
          starterWeightEstimateNames.toList()..sort(),
      exercisesWithUnavailableStarterWeights:
          unavailableStarterWeightNames.toList()..sort(),
    );
  }

  /// Builds the weight/reps rows saved into a generated preset.
  ///
  /// When generated rep/weight values are off, this intentionally falls back to
  /// neutral 0 lb x 10 reps rows so users can fill them in. When enabled, the
  /// system estimates a working weight from history or starter profiles, then
  /// applies exercise-aware reps, effort/RIR, rounding, and fatigue rules.
  Future<List<ExerciseSet>> _buildGeneratedSets({
    required SessionSpec spec,
    required CandidateExercisePlan candidate,
    required List<BodyPartTarget> bodyTargets,
    required Set<String> missingWeightHistoryNames,
    required Set<String> starterWeightEstimateNames,
    required Set<String> unavailableStarterWeightNames,
  }) async {
    if (!spec.useGeneratedRepWeights) {
      return List<ExerciseSet>.generate(
        candidate.suggestedSets,
        (_) => ExerciseSet(weight: 0, reps: 10),
      );
    }

    final requestedTargetReps = math.max(1, spec.targetRepCount).toInt();
    final targetReps = _effectiveTargetReps(candidate.def, requestedTargetReps);
    final mode = _resolvedRepWeightMode(
      spec.repWeightMode,
      candidate.suggestedSets,
    );
    final baseTarget = await _targetWeightForReps(
      def: candidate.def,
      targetReps: targetReps,
      additionalRir: _straightSetRirAdjustment(mode, candidate.suggestedSets),
      starterIntensity: spec.starterWeightIntensity,
      missingWeightHistoryNames: missingWeightHistoryNames,
      starterWeightEstimateNames: starterWeightEstimateNames,
      unavailableStarterWeightNames: unavailableStarterWeightNames,
    );
    final fatigueMultiplier = _optimizedFatigueMultiplier(
      spec: spec,
      candidate: candidate,
      bodyTargets: bodyTargets,
    );
    final target = _applyOptimizedFatigueAdjustment(
      def: candidate.def,
      target: baseTarget,
      fatigueMultiplier: fatigueMultiplier,
    );
    _debugLogGeneratedWeightTarget(
      def: candidate.def,
      target: target,
      reps: targetReps,
      sets: candidate.suggestedSets,
      mode: mode,
      intensity: spec.starterWeightIntensity,
    );

    switch (mode) {
      case RepWeightGenerationMode.pyramid:
        return _buildPyramidSets(
          def: candidate.def,
          totalSets: candidate.suggestedSets,
          peakReps: targetReps,
          peakWeight: target.weight,
          intensity: spec.starterWeightIntensity,
        );
      case RepWeightGenerationMode.consistent:
      case RepWeightGenerationMode.mixed:
        return List<ExerciseSet>.generate(
          candidate.suggestedSets,
          (_) => ExerciseSet(weight: target.weight, reps: targetReps),
        );
    }
  }

  RepWeightGenerationMode _resolvedRepWeightMode(
    RepWeightGenerationMode mode,
    int totalSets,
  ) {
    if (mode != RepWeightGenerationMode.mixed) return mode;
    return totalSets >= 3
        ? RepWeightGenerationMode.pyramid
        : RepWeightGenerationMode.consistent;
  }

  int _straightSetRirAdjustment(RepWeightGenerationMode mode, int totalSets) {
    if (mode != RepWeightGenerationMode.consistent) return 0;
    if (totalSets >= 5) return 2;
    if (totalSets >= 3) return 1;
    return 0;
  }

  /// Test seam for exercise-aware target rep selection.
  @visibleForTesting
  int debugEffectiveTargetReps(ExerciseDefinition def, int requestedReps) {
    return _effectiveTargetReps(def, requestedReps);
  }

  int _effectiveTargetReps(ExerciseDefinition def, int requestedReps) {
    final text = _normalizedExerciseText(def);
    final range = _repRangeForExerciseText(text);
    if (requestedReps == SessionSpec.defaultTargetRepCount) {
      return _defaultRepsForRange(range);
    }
    return requestedReps.clamp(range.min, range.max).toInt();
  }

  ({int min, int max, int preferred}) _repRangeForExerciseText(String text) {
    if (_looksCorrectiveOrRearDeltWork(text)) {
      return (min: 12, max: 25, preferred: 15);
    }
    if (_looksIsolationExercise(text)) {
      return (min: 10, max: 20, preferred: 12);
    }
    if (_looksMachineOrCableExercise(text)) {
      return (min: 8, max: 15, preferred: 10);
    }
    if (_looksModerateCompoundExercise(text)) {
      return (min: 6, max: 12, preferred: 8);
    }
    return (min: 3, max: 8, preferred: SessionSpec.defaultTargetRepCount);
  }

  int _defaultRepsForRange(({int min, int max, int preferred}) range) {
    return range.preferred.clamp(range.min, range.max).toInt();
  }

  bool _looksCorrectiveOrRearDeltWork(String text) {
    return text.contains('face pull') ||
        text.contains('rear delt') ||
        text.contains('external rotation') ||
        text.contains('rotator');
  }

  bool _looksIsolationExercise(String text) {
    return text.contains('curl') ||
        text.contains('lateral raise') ||
        text.contains('raise') ||
        text.contains('fly') ||
        text.contains('extension') ||
        text.contains('leg curl') ||
        text.contains('calf raise') ||
        text.contains('pushdown') ||
        text.contains('pressdown') ||
        text.contains('tricep');
  }

  bool _looksMachineOrCableExercise(String text) {
    return text.contains('machine') ||
        text.contains('cable') ||
        text.contains('pulldown') ||
        text.contains('leg press');
  }

  bool _looksModerateCompoundExercise(String text) {
    return text.contains('dumbbell press') ||
        text.contains('row') ||
        text.contains('pulldown') ||
        text.contains('pull up') ||
        text.contains('pull-up');
  }

  String _normalizedExerciseText(ExerciseDefinition def) {
    return [
      def.name,
      ...def.equipmentList.map((equipment) => equipment.name),
    ].join(' ').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  /// Creates a pyramid around the peak set.
  ///
  /// Sets farther from the peak drop weight by 10% per step and add two reps,
  /// so a four-set plan with a 6-rep peak produces 10/8/6/8 reps.
  List<ExerciseSet> _buildPyramidSets({
    required ExerciseDefinition def,
    required int totalSets,
    required int peakReps,
    required double peakWeight,
    required StarterWeightIntensity intensity,
  }) {
    final peakIndex = totalSets ~/ 2;
    return List<ExerciseSet>.generate(totalSets, (index) {
      final distanceFromPeak = (index - peakIndex).abs();
      final weightMultiplier =
          math.max(0.0, 1.0 - distanceFromPeak * 0.10).toDouble();
      final steppedWeight =
          peakWeight <= 0 ? 0.0 : peakWeight * weightMultiplier;
      return ExerciseSet(
        weight: _roundGeneratedWeight(
          def,
          steppedWeight,
          direction:
              distanceFromPeak == 0
                  ? _roundingDirectionForIntensity(intensity)
                  : GeneratedWeightRoundingDirection.down,
        ),
        reps: peakReps + distanceFromPeak * 2,
      );
    });
  }

  /// Finds the generated working weight for the requested rep count.
  ///
  /// Historical rows first become a capability estimate. That estimate is then
  /// converted into a working weight using the requested reps plus an internal
  /// RIR target, so exact rep-max rows are evidence rather than prescriptions.
  Future<_GeneratedWeightTarget> _targetWeightForReps({
    required ExerciseDefinition def,
    required int targetReps,
    required int additionalRir,
    required StarterWeightIntensity starterIntensity,
    required Set<String> missingWeightHistoryNames,
    required Set<String> starterWeightEstimateNames,
    required Set<String> unavailableStarterWeightNames,
  }) async {
    final history = await _preferredRepMaxHistory(def.id);
    final repMaxRows = history.rows;
    if (repMaxRows.isEmpty) {
      missingWeightHistoryNames.add(def.name);
      final starterWeight = _starterWeightService.recommend(
        definition: def,
        intensity: starterIntensity,
        targetReps: targetReps + additionalRir,
        bodyWeightLbs: await _latestBodyWeightLbs(),
      );
      if (starterWeight.isAvailable) {
        if (!starterWeight.isBodyweightOnly) {
          starterWeightEstimateNames.add(def.name);
        }
        return _GeneratedWeightTarget(
          weight: starterWeight.weight,
          sourceEstimate: starterWeight.roundedFrom,
          workingWeight: starterWeight.weight,
          source:
              starterWeight.isBodyweightOnly
                  ? _GeneratedWeightSource.bodyweightOnly
                  : _GeneratedWeightSource.starterEstimate,
        );
      }
      unavailableStarterWeightNames.add(def.name);
      return const _GeneratedWeightTarget(
        weight: 0,
        sourceEstimate: 0,
        workingWeight: 0,
        source: _GeneratedWeightSource.unavailable,
      );
    }

    final strengthEstimate = _strengthEstimateFromRepMaxRows(
      rows: repMaxRows,
      targetReps: targetReps,
    );
    if (strengthEstimate <= 0) {
      return const _GeneratedWeightTarget(
        weight: 0,
        sourceEstimate: 0,
        workingWeight: 0,
        source: _GeneratedWeightSource.unavailable,
      );
    }

    return _finalizeHistoricalWeight(
      def: def,
      oneRepMaxEstimate: strengthEstimate,
      targetReps: targetReps,
      additionalRir: additionalRir,
      intensity: starterIntensity,
      source: _historyWeightSource(scope: history.scope),
    );
  }

  Future<_GeneratedWeightHistory> _preferredRepMaxHistory(int defId) async {
    final recentRows = await _repo.fetchRepMaxes(defId, 'month');
    if (recentRows.isNotEmpty) {
      return _GeneratedWeightHistory(
        rows: recentRows,
        scope: _GeneratedWeightHistoryScope.recent,
      );
    }

    return _GeneratedWeightHistory(
      rows: await _repo.fetchRepMaxes(defId, 'all'),
      scope: _GeneratedWeightHistoryScope.allTime,
    );
  }

  _GeneratedWeightTarget _finalizeHistoricalWeight({
    required ExerciseDefinition def,
    required double oneRepMaxEstimate,
    required int targetReps,
    required int additionalRir,
    required StarterWeightIntensity intensity,
    required _GeneratedWeightSource source,
  }) {
    final workingWeight = _workingWeightFromOneRepMax(
      oneRepMaxEstimate: oneRepMaxEstimate,
      targetReps: targetReps,
      additionalRir: additionalRir,
      intensity: intensity,
    );
    return _GeneratedWeightTarget(
      weight: _roundGeneratedWeight(
        def,
        workingWeight,
        direction: _roundingDirectionForIntensity(intensity),
      ),
      sourceEstimate: oneRepMaxEstimate,
      workingWeight: workingWeight,
      source: source,
    );
  }

  double _strengthEstimateFromRepMaxRows({
    required List<RepMaxRow> rows,
    required int targetReps,
  }) {
    final usableEvidence =
        rows
            .map(
              (row) => (
                repCount: row.repCount,
                oneRepMax:
                    row.oneErm > 0
                        ? row.oneErm
                        : row.rmValue * (1 + row.repCount / 30.0),
              ),
            )
            .where((entry) => entry.oneRepMax > 0)
            .toList();
    if (usableEvidence.isEmpty) return 0;

    final medianOneRepMax = _medianOneRepMax(usableEvidence);
    final evidence =
        usableEvidence
            .map(
              (entry) => (
                repCount: entry.repCount,
                oneRepMax: entry.oneRepMax,
                score: _repMaxEvidenceScore(
                  repCount: entry.repCount,
                  oneRepMax: entry.oneRepMax,
                  targetReps: targetReps,
                  medianOneRepMax: medianOneRepMax,
                ),
              ),
            )
            .where((entry) => entry.score > 0)
            .toList()
          ..sort((a, b) {
            final byScore = b.score.compareTo(a.score);
            if (byScore != 0) return byScore;
            return b.oneRepMax.compareTo(a.oneRepMax);
          });
    if (evidence.isEmpty) return 0;

    var total = 0.0;
    var totalWeight = 0.0;
    for (var i = 0; i < evidence.length && i < 4; i++) {
      final entry = evidence[i];
      final evidenceWeight = entry.score;
      total += entry.oneRepMax * evidenceWeight;
      totalWeight += evidenceWeight;
    }

    return totalWeight <= 0 ? 0 : total / totalWeight;
  }

  double _medianOneRepMax(List<({int repCount, double oneRepMax})> evidence) {
    final values = evidence.map((entry) => entry.oneRepMax).toList()..sort();
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return (values[middle - 1] + values[middle]) / 2;
  }

  double _repMaxEvidenceScore({
    required int repCount,
    required double oneRepMax,
    required int targetReps,
    required double medianOneRepMax,
  }) {
    final repDistance = (repCount - targetReps).abs();
    final repCloseness = switch (repDistance) {
      0 => 1.25,
      <= 2 => 1.10,
      <= 4 => 0.95,
      <= 8 => 0.75,
      _ => 0.55,
    };

    final repReliability = switch (repCount) {
      >= 20 => 0.45,
      >= 16 => 0.65,
      >= 13 => 0.80,
      <= 1 => targetReps >= 8 ? 0.70 : 0.90,
      <= 3 => targetReps >= 10 ? 0.75 : 0.95,
      _ => 1.0,
    };

    final outlierReliability = _oneRepMaxOutlierReliability(
      oneRepMax: oneRepMax,
      medianOneRepMax: medianOneRepMax,
    );

    return repCloseness * repReliability * outlierReliability;
  }

  double _oneRepMaxOutlierReliability({
    required double oneRepMax,
    required double medianOneRepMax,
  }) {
    if (medianOneRepMax <= 0) return 1.0;
    final ratio = oneRepMax / medianOneRepMax;
    if (ratio >= 1.35) return 0.35;
    if (ratio >= 1.20) return 0.65;
    if (ratio <= 0.65) return 0.55;
    if (ratio <= 0.80) return 0.75;
    return 1.0;
  }

  _GeneratedWeightSource _historyWeightSource({
    required _GeneratedWeightHistoryScope scope,
  }) {
    // Exact-rep rows improve evidence scoring, but the final recommendation is
    // still a blended capability estimate rather than a direct PR prescription.
    return scope == _GeneratedWeightHistoryScope.recent
        ? _GeneratedWeightSource.recentHistoryBlend
        : _GeneratedWeightSource.allTimeHistoryBlend;
  }

  double _workingWeightFromOneRepMax({
    required double oneRepMaxEstimate,
    required int targetReps,
    required int additionalRir,
    required StarterWeightIntensity intensity,
  }) {
    if (oneRepMaxEstimate <= 0) return 0;
    final effortReps =
        targetReps + _targetRirForIntensity(intensity) + additionalRir;
    return oneRepMaxEstimate / (1 + effortReps / 30.0);
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

  int _targetRirForIntensity(StarterWeightIntensity intensity) {
    return switch (intensity) {
      StarterWeightIntensity.easy => 4,
      StarterWeightIntensity.medium => 2,
      StarterWeightIntensity.hard => 1,
    };
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

  double _optimizedFatigueMultiplier({
    required SessionSpec spec,
    required CandidateExercisePlan candidate,
    required List<BodyPartTarget> bodyTargets,
  }) {
    if (!spec.avoidMostRecentBodyPart ||
        !spec.useRecentTrainingHistory ||
        bodyTargets.isEmpty ||
        candidate.unitsPerSet.isEmpty) {
      return 1.0;
    }

    final targetsById = {
      for (final target in bodyTargets) target.bodyPart.id: target,
    };
    var highestRecentRatio = 0.0;
    for (final entry in candidate.unitsPerSet.entries) {
      if (entry.value <= 0) continue;
      final target = targetsById[entry.key.id];
      if (target == null || target.weeklyTargetUnits <= 0) continue;
      final ratio = target.doneThisWeek / target.weeklyTargetUnits;
      if (ratio > highestRecentRatio) highestRecentRatio = ratio;
    }

    if (highestRecentRatio >= 1.0) return 0.90;
    if (highestRecentRatio >= 0.85) return 0.95;
    if (highestRecentRatio >= 0.70) return 0.975;
    return 1.0;
  }

  _GeneratedWeightTarget _applyOptimizedFatigueAdjustment({
    required ExerciseDefinition def,
    required _GeneratedWeightTarget target,
    required double fatigueMultiplier,
  }) {
    if (target.weight <= 0 || fatigueMultiplier >= 0.999) return target;

    final workingWeight = target.workingWeight * fatigueMultiplier;
    return target.copyWithWorkingWeight(
      weight: _roundGeneratedWeight(
        def,
        workingWeight,
        direction: GeneratedWeightRoundingDirection.down,
      ),
      workingWeight: workingWeight,
      fatigueMultiplier: fatigueMultiplier,
    );
  }

  GeneratedWeightRoundingDirection _roundingDirectionForIntensity(
    StarterWeightIntensity intensity,
  ) {
    return switch (intensity) {
      StarterWeightIntensity.easy => GeneratedWeightRoundingDirection.down,
      StarterWeightIntensity.medium => GeneratedWeightRoundingDirection.down,
      StarterWeightIntensity.hard => GeneratedWeightRoundingDirection.nearest,
    };
  }

  double _roundGeneratedWeight(
    ExerciseDefinition def,
    double weight, {
    GeneratedWeightRoundingDirection direction =
        GeneratedWeightRoundingDirection.nearest,
  }) {
    return GeneratedWeightRounding.roundForExercise(
      definition: def,
      weight: weight,
      direction: direction,
      minimumWeight: GeneratedWeightRounding.minimumForExercise(def),
    );
  }

  void _debugLogGeneratedWeightTarget({
    required ExerciseDefinition def,
    required _GeneratedWeightTarget target,
    required int reps,
    required int sets,
    required RepWeightGenerationMode mode,
    required StarterWeightIntensity intensity,
  }) {
    if (!kDebugMode) return;

    final estimate =
        target.sourceEstimate == target.weight
            ? ''
            : ' estimate=${target.sourceEstimate.toStringAsFixed(1)}'
                ' working=${target.workingWeight.toStringAsFixed(1)}';
    final fatigue =
        target.fatigueMultiplier >= 0.999
            ? ''
            : ' fatigue=${target.fatigueMultiplier.toStringAsFixed(3)}';
    final starterFlag = target.usesStarterEstimate ? ' starter=true' : '';
    debugPrint(
      '[generated-weight] ${def.name}: '
      '${target.weight.toStringAsFixed(0)} lbs x $reps, '
      'sets=$sets mode=${mode.name} intensity=${intensity.name} '
      'source=${target.source.debugLabel}$starterFlag$estimate$fatigue',
    );
  }

  Future<double?> _latestBodyWeightLbs() {
    return _bodyWeightLbsFuture ??= _repo.fetchLatestBodyWeightLbs();
  }

  Future<List<CandidateExercisePlan>> _buildFallbackCandidatePool({
    required SessionSpec spec,
    required Set<int> avoidedBodyPartIds,
  }) async {
    final defs = await _repo.fetchCatalogDefinitions(
      useProfileFilter: true,
      profileId: spec.profileId,
      equipmentFilter: null,
      bodypartIds: spec.focusBodypartIds.isEmpty ? null : spec.focusBodypartIds,
      muscleIds: null,
    );

    final blacklistedBodyPartIds = spec.blacklistedBodypartIds.toSet();
    final preferredBodyPartIds = spec.preferredBodypartIds.toSet();
    final candidates = await _mapDefinitionsWithConcurrency(defs, (def) async {
      final unitsPerSet = await _repo.computeBodyPartPercents(def.id);
      if (unitsPerSet.isEmpty) return null;
      if (_hitsAnyBodyPart(unitsPerSet, blacklistedBodyPartIds)) {
        return null;
      }
      final preferredHitUnits = _hitUnitsForBodyParts(
        unitsPerSet,
        preferredBodyPartIds,
      );
      final muscleUnitsPerSet = {
        for (final row in await _repo.computeMusclePercents(def.id))
          if (row.percent > 0) row.muscleId: row.percent,
      };
      return CandidateExercisePlan(
        def: def,
        unitsPerSet: unitsPerSet,
        muscleUnitsPerSet: muscleUnitsPerSet,
        score:
            1.0 +
            preferredHitUnits *
                SessionSpec.preferredBodypartCandidateScoreMultiplier,
        suggestedSets: spec.minSetsPerExercise,
      );
    });

    _sortCandidates(candidates);
    return _avoidBodyPartsWhenPossible(
      candidates,
      _autoAvoidedBodyPartIdsForSpec(spec, avoidedBodyPartIds),
    );
  }

  _CandidateScore _scoreAgainstBodyParts({
    required Map<BodyPart, double> unitsPerSet,
    required Map<int, BodyPartTarget> targetById,
  }) {
    var rawScore = 0.0;
    var hitUnits = 0.0;
    var weightedDeficitRatio = 0.0;

    unitsPerSet.forEach((bodyPart, units) {
      final target = targetById[bodyPart.id];
      if (target == null ||
          units <= 0 ||
          target.biasWeight <= 0 ||
          target.deficit <= 0) {
        return;
      }

      hitUnits += units;
      weightedDeficitRatio +=
          units *
          (target.deficit / target.weeklyTargetUnits) *
          target.biasWeight;
      rawScore += units * (1.0 + target.deficit) * target.biasWeight;
    });

    return _CandidateScore(
      score: rawScore,
      hitUnits: hitUnits,
      deficitRatio: hitUnits <= 0 ? 0.0 : weightedDeficitRatio / hitUnits,
    );
  }

  _CandidateScore _scoreAgainstMuscles({
    required Map<int, double> muscleUnitsPerSet,
    required Map<int, MuscleTarget> targetById,
  }) {
    var rawScore = 0.0;
    var hitUnits = 0.0;
    var weightedDeficitRatio = 0.0;

    muscleUnitsPerSet.forEach((muscleId, units) {
      final target = targetById[muscleId];
      if (target == null ||
          units <= 0 ||
          target.biasWeight <= 0 ||
          target.deficit <= 0) {
        return;
      }

      hitUnits += units;
      weightedDeficitRatio +=
          units *
          (target.deficit / target.weeklyTargetUnits) *
          target.biasWeight;
      rawScore += units * (1.0 + target.deficit) * target.biasWeight;
    });

    return _CandidateScore(
      score: rawScore,
      hitUnits: hitUnits,
      deficitRatio: hitUnits <= 0 ? 0.0 : weightedDeficitRatio / hitUnits,
    );
  }

  double _bodyPartBiasWeight({
    required SessionSpec spec,
    required int bodyPartId,
    required Map<int, double> rankedWeights,
    required Set<int> rankedMuscleBodyParts,
  }) {
    if (spec.blacklistedBodypartIds.contains(bodyPartId)) {
      return 0.0;
    }

    double baseWeight;
    if (spec.priorityMode == TrainingPriorityMode.bodyPartRanking &&
        rankedWeights.isNotEmpty) {
      baseWeight = rankedWeights[bodyPartId] ?? 0.0;
    } else if (spec.priorityMode == TrainingPriorityMode.muscleRanking &&
        rankedMuscleBodyParts.isNotEmpty) {
      baseWeight = rankedMuscleBodyParts.contains(bodyPartId) ? 1.0 : 0.0;
    } else if (spec.focusBodypartIds.isNotEmpty) {
      baseWeight = spec.focusBodypartIds.contains(bodyPartId) ? 1.0 : 0.0;
    } else {
      baseWeight = 1.0;
    }

    final isPreferred = spec.preferredBodypartIds.contains(bodyPartId);
    if (baseWeight <= 0.0) {
      return isPreferred ? SessionSpec.preferredBodypartBiasMultiplier : 0.0;
    }
    return isPreferred
        ? baseWeight * SessionSpec.preferredBodypartBiasMultiplier
        : baseWeight;
  }

  Future<Set<int>> _bodyPartIdsForRankedMuscles() async {
    final ranks = await _repo.getAllMuscleRanks();
    final bodyPartIds = <int>{};
    for (final rank in ranks) {
      final links = await _repo.fetchBodyPartsForMuscle(rank.muscleId);
      bodyPartIds.addAll(links.map((link) => link.bodyPartId));
    }
    return bodyPartIds;
  }

  Map<int, double> _bodyPartRankWeights(List<BodyPartRanking> ranks) {
    final sorted = [...ranks]..sort((a, b) => a.rank.compareTo(b.rank));
    final count = sorted.length;
    if (count == 0) return const {};

    return {
      for (var i = 0; i < sorted.length; i++)
        sorted[i].bodyPartId: 1.0 + (count - i) / count,
    };
  }

  Map<int, double> _muscleRankWeights(List<MuscleRanking> ranks) {
    final sorted = [...ranks]..sort((a, b) => a.rank.compareTo(b.rank));
    final count = sorted.length;
    if (count == 0) return const {};

    return {
      for (var i = 0; i < sorted.length; i++)
        sorted[i].muscleId: 1.0 + (count - i) / count,
    };
  }

  double _weeklyTargetUnits(VolumeBoundaries? boundaries) {
    return boundaries?.maxRecoverable ??
        SessionSpec.defaultWeeklyTargetSetUnits;
  }

  Future<String> _pickUniquePresetName(
    SessionSpec spec,
    List<CandidateExercisePlan> selected,
  ) async {
    final generatedName = _bodyPartSummaryName(selected);
    final baseName =
        spec.name.isNotEmpty
            ? spec.name
            : generatedName ??
                'Auto preset ${spec.now.toIso8601String().split('T').first}';

    final rows = await _repo.fetchAllPresetsRaw(profileId: spec.profileId);
    final existingNames =
        rows.map((row) => row['name']).whereType<String>().toSet();

    var name = baseName;
    var suffix = 2;
    while (existingNames.contains(name)) {
      name = '$baseName ($suffix)';
      suffix++;
    }

    return name;
  }

  String? _bodyPartSummaryName(List<CandidateExercisePlan> selected) {
    final bodyPartNamesById = <int, String>{};
    final bodyPartTotalsById = <int, double>{};

    for (final plan in selected) {
      plan.unitsPerSet.forEach((bodyPart, unitsPerSet) {
        if (unitsPerSet <= 0.0 || plan.suggestedSets <= 0) return;
        bodyPartNamesById[bodyPart.id] = bodyPart.name;
        bodyPartTotalsById[bodyPart.id] =
            (bodyPartTotalsById[bodyPart.id] ?? 0.0) +
            unitsPerSet * plan.suggestedSets;
      });
    }

    final ranked =
        bodyPartTotalsById.entries.where((entry) => entry.value > 0.0).toList()
          ..sort((a, b) {
            final byUnits = b.value.compareTo(a.value);
            if (byUnits != 0) return byUnits;
            return (bodyPartNamesById[a.key] ?? '').compareTo(
              bodyPartNamesById[b.key] ?? '',
            );
          });

    final names =
        ranked
            .take(2)
            .map((entry) => bodyPartNamesById[entry.key])
            .whereType<String>()
            .toList();
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  Future<List<T>> _mapDefinitionsWithConcurrency<T>(
    List<ExerciseDefinition> definitions,
    Future<T?> Function(ExerciseDefinition definition) mapper,
  ) async {
    final results = await mapWithConcurrency<ExerciseDefinition, T?>(
      definitions,
      maxConcurrency: _candidateAnalysisConcurrency,
      mapper: (definition, _) => mapper(definition),
    );
    return [
      for (final result in results)
        if (result != null) result,
    ];
  }
}

class _CandidateScore {
  final double score;
  final double hitUnits;
  final double deficitRatio;

  const _CandidateScore({
    required this.score,
    required this.hitUnits,
    required this.deficitRatio,
  });
}

class _PreferredCoveragePick {
  final int index;
  final int sets;

  const _PreferredCoveragePick({required this.index, required this.sets});
}

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
