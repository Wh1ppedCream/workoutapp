import 'dart:math' as math;

import '../repositories/app_repository.dart';
import '../models/models.dart';

class PresetGenerationService {
  final AppRepository _repo;

  PresetGenerationService(this._repo);

  Future<int> generatePreset(SessionSpec spec) async {
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

    final presetId = await _createPresetInDb(spec, selected);
    await _initAutoSettings(presetId);
    return presetId;
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
    if (!spec.avoidMostRecentBodyPart) return const <int>{};

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

  bool _hitsAnyBodyPart(
    Map<BodyPart, double> unitsPerSet,
    Set<int> bodyPartIds,
  ) {
    return unitsPerSet.entries.any(
      (entry) => entry.value > 0.0 && bodyPartIds.contains(entry.key.id),
    );
  }

  Future<List<BodyPartTarget>> _loadBodyPartTargets({
    required SessionSpec spec,
    required DateTime start,
    required DateTime end,
  }) async {
    final allBodyParts = await _repo.fetchAllBodyParts();
    final historyMap = await _repo.fetchAllBodyPartSetsOverTimeRange(
      start: start,
      end: end,
    );
    final historyById = <int, double>{};
    historyMap.forEach((bp, value) {
      historyById[bp.id] = value;
    });

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
    final historyById = await _repo.fetchSetsPerMuscle(start: start, end: end);
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
        activeMuscleIds.isEmpty) {
      return const [];
    }

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
          spec.priorityMode == TrainingPriorityMode.muscleRanking
              ? activeMuscleIds
              : null,
    );

    final candidates = <CandidateExercisePlan>[];
    for (final def in defs) {
      final unitsPerSet = await _repo.computeBodyPartPercents(def.id);
      if (unitsPerSet.isEmpty) continue;

      final muscleUnitsPerSet = {
        for (final row in await _repo.computeMusclePercents(def.id))
          if (row.percent > 0) row.muscleId: row.percent,
      };

      final scoreResult =
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

      if (scoreResult.score <= 0 || scoreResult.hitUnits <= 0) continue;

      final rating = def.rating.toDouble();
      final ratingFactor =
          rating <= 0 ? 1.0 : (0.5 + rating / 100.0).clamp(0.5, 2.0);
      final score = scoreResult.score * ratingFactor;
      if (score <= 0.0) continue;

      final deficitRatio = scoreResult.deficitRatio;
      final setRange = spec.maxSetsPerExercise - spec.minSetsPerExercise;
      final suggestedSets =
          (spec.minSetsPerExercise + deficitRatio * setRange)
              .round()
              .clamp(spec.minSetsPerExercise, spec.maxSetsPerExercise)
              .toInt();

      candidates.add(
        CandidateExercisePlan(
          def: def,
          unitsPerSet: unitsPerSet,
          muscleUnitsPerSet: muscleUnitsPerSet,
          score: score,
          suggestedSets: suggestedSets,
        ),
      );
    }

    return _avoidBodyPartsWhenPossible(candidates, avoidedBodyPartIds);
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
    final budget = spec.sessionDurationMinutes;
    var usedMinutes = 0;

    for (final candidate in rankedCandidates) {
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

  Future<int> _createPresetInDb(
    SessionSpec spec,
    List<CandidateExercisePlan> selected,
  ) async {
    final name = await _pickUniquePresetName(spec);
    final presetId = await _repo.createPreset(name, profileId: spec.profileId);

    var orderIndex = 0;
    for (final candidate in selected) {
      final presetExerciseId = await _repo.addExerciseToPreset(
        presetId,
        candidate.def.id,
        'weight',
        orderIndex++,
      );

      final parents = List<ExerciseSet>.generate(
        candidate.suggestedSets,
        (_) => ExerciseSet(weight: 0, reps: 10),
      );

      await _repo.savePresetWeightSets(
        presetExerciseId,
        parents,
        <int, List<ExerciseSet>>{},
      );
    }

    return presetId;
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

    final candidates = <CandidateExercisePlan>[];
    for (final def in defs) {
      final unitsPerSet = await _repo.computeBodyPartPercents(def.id);
      if (unitsPerSet.isEmpty) continue;
      final muscleUnitsPerSet = {
        for (final row in await _repo.computeMusclePercents(def.id))
          if (row.percent > 0) row.muscleId: row.percent,
      };
      candidates.add(
        CandidateExercisePlan(
          def: def,
          unitsPerSet: unitsPerSet,
          muscleUnitsPerSet: muscleUnitsPerSet,
          score: 1.0,
          suggestedSets: spec.minSetsPerExercise,
        ),
      );
    }

    return _avoidBodyPartsWhenPossible(candidates, avoidedBodyPartIds);
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
    if (spec.priorityMode == TrainingPriorityMode.bodyPartRanking &&
        rankedWeights.isNotEmpty) {
      return rankedWeights[bodyPartId] ?? 0.0;
    }

    if (spec.priorityMode == TrainingPriorityMode.muscleRanking &&
        rankedMuscleBodyParts.isNotEmpty) {
      return rankedMuscleBodyParts.contains(bodyPartId) ? 1.0 : 0.0;
    }

    if (spec.focusBodypartIds.isNotEmpty) {
      return spec.focusBodypartIds.contains(bodyPartId) ? 1.0 : 0.0;
    }

    return 1.0;
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

  Future<String> _pickUniquePresetName(SessionSpec spec) async {
    final baseName =
        spec.name.isNotEmpty
            ? spec.name
            : 'Auto preset ${spec.now.toIso8601String().split('T').first}';

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
