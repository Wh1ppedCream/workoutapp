import 'dart:math' as math;

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';

class PresetGenerationService {
  static const int _candidateAnalysisConcurrency = 4;

  final AppRepository _repo;

  PresetGenerationService(this._repo);

  Future<int> generatePreset(SessionSpec spec) async {
    final result = await generatePresetWithDetails(spec);
    return result.presetId;
  }

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

    final result = await _createPresetInDb(spec, selected);
    await _initAutoSettings(result.presetId);
    return result;
  }

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

  Future<List<CandidateExercisePlan>> _selectGeneratedPlan({
    required SessionSpec spec,
    required List<BodyPartTarget> bodyTargets,
    required List<MuscleTarget> muscleTargets,
  }) async {
    final avoidedBodyPartIds = await _bodyPartIdsToAvoid(spec);

    if (bodyTargets.isNotEmpty) {
      final candidates = await _buildCandidatePool(
        spec: spec,
        targets: bodyTargets,
        muscleTargets: muscleTargets,
        avoidedBodyPartIds: avoidedBodyPartIds,
      );

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) => b.score.compareTo(a.score));
        final selected = _staggerExercises(
          _selectWithinTimeBudget(candidates, spec, bodyTargets, muscleTargets),
        );
        if (selected.isNotEmpty) {
          return selected;
        }
      }
    }

    final fallback = await _buildFallbackCandidatePool(
      spec: spec,
      avoidedBodyPartIds: avoidedBodyPartIds,
    );
    return _staggerExercises(
      _selectWithinTimeBudget(fallback, spec, bodyTargets, muscleTargets),
    );
  }

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
    return candidate.unitsPerSet.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key
        .id;
  }

  int _estimatedMinutesForExercise(int sets, SessionSpec spec) {
    return spec.setupMinutesPerExercise + sets * spec.minutesPerSet;
  }

  Future<PresetGenerationResult> _createPresetInDb(
    SessionSpec spec,
    List<CandidateExercisePlan> selected,
  ) async {
    final name = await _pickUniquePresetName(spec, selected);
    final presetId = await _repo.createPreset(name, profileId: spec.profileId);
    final missingWeightHistoryNames = <String>{};

    var orderIndex = 0;
    for (final candidate in selected) {
      final presetExerciseId = await _repo.addExerciseToPreset(
        presetId,
        candidate.def.id,
        'weight',
        orderIndex++,
      );

      final parents = await _buildGeneratedSets(
        spec: spec,
        candidate: candidate,
        missingWeightHistoryNames: missingWeightHistoryNames,
      );

      await _repo.savePresetWeightSets(
        presetExerciseId,
        parents,
        <int, List<ExerciseSet>>{},
      );
    }

    return PresetGenerationResult(
      presetId: presetId,
      exercisesMissingWeightHistory: missingWeightHistoryNames.toList()..sort(),
    );
  }

  Future<List<ExerciseSet>> _buildGeneratedSets({
    required SessionSpec spec,
    required CandidateExercisePlan candidate,
    required Set<String> missingWeightHistoryNames,
  }) async {
    if (!spec.useGeneratedRepWeights) {
      return List<ExerciseSet>.generate(
        candidate.suggestedSets,
        (_) => ExerciseSet(weight: 0, reps: 10),
      );
    }

    final targetReps = math.max(1, spec.targetRepCount).toInt();
    final peakWeight = await _targetWeightForReps(
      defId: candidate.def.id,
      targetReps: targetReps,
      exerciseName: candidate.def.name,
      missingWeightHistoryNames: missingWeightHistoryNames,
    );

    final mode = _resolvedRepWeightMode(
      spec.repWeightMode,
      candidate.suggestedSets,
    );
    switch (mode) {
      case RepWeightGenerationMode.pyramid:
        return _buildPyramidSets(
          totalSets: candidate.suggestedSets,
          peakReps: targetReps,
          peakWeight: peakWeight,
        );
      case RepWeightGenerationMode.consistent:
      case RepWeightGenerationMode.mixed:
        return List<ExerciseSet>.generate(
          candidate.suggestedSets,
          (_) => ExerciseSet(weight: peakWeight, reps: targetReps),
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

  List<ExerciseSet> _buildPyramidSets({
    required int totalSets,
    required int peakReps,
    required double peakWeight,
  }) {
    final peakIndex = totalSets ~/ 2;
    return List<ExerciseSet>.generate(totalSets, (index) {
      final distanceFromPeak = (index - peakIndex).abs();
      final weightMultiplier = math.max(0.0, 1.0 - distanceFromPeak * 0.10);
      return ExerciseSet(
        weight: peakWeight <= 0 ? 0 : peakWeight * weightMultiplier,
        reps: peakReps + distanceFromPeak * 2,
      );
    });
  }

  Future<double> _targetWeightForReps({
    required int defId,
    required int targetReps,
    required String exerciseName,
    required Set<String> missingWeightHistoryNames,
  }) async {
    final repMaxRows = await _repo.fetchRepMaxes(defId, 'all');
    if (repMaxRows.isEmpty) {
      missingWeightHistoryNames.add(exerciseName);
      return 0.0;
    }

    for (final row in repMaxRows) {
      if (row.repCount == targetReps) {
        return row.rmValue;
      }
    }

    final bestOneRepMax = repMaxRows.fold<double>(
      0.0,
      (best, row) => row.oneErm > best ? row.oneErm : best,
    );
    if (bestOneRepMax <= 0) return 0.0;

    return bestOneRepMax / (1 + targetReps / 30.0);
  }

  Future<void> _initAutoSettings(int presetId) async {
    await _repo.upsertPresetAutoSettings(
      presetId: presetId,
      isAutomatic: true,
      globalIncrement: 5.0,
      skipFirstSet: true,
      weightCheck: true,
      repCheck: true,
      volumeCheck: false,
      adjustAllSets: false,
      useManualSelect: false,
      manualSelectionJson: '{}',
    );
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

    candidates.sort((a, b) => b.score.compareTo(a.score));
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
