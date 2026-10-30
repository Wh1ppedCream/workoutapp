part of '../preset_generation_service.dart';

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

extension _GeneratedWeightEstimator on PresetGenerationService {
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
      final weightMultiplier = math
          .max(0.0, 1.0 - distanceFromPeak * 0.10)
          .toDouble();
      final steppedWeight = peakWeight <= 0
          ? 0.0
          : peakWeight * weightMultiplier;
      return ExerciseSet(
        weight: _roundGeneratedWeight(
          def,
          steppedWeight,
          direction: distanceFromPeak == 0
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
          source: starterWeight.isBodyweightOnly
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
    final usableEvidence = rows
        .map(
          (row) => (
            repCount: row.repCount,
            oneRepMax: row.oneErm > 0
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

  int _targetRirForIntensity(StarterWeightIntensity intensity) {
    return switch (intensity) {
      StarterWeightIntensity.easy => 4,
      StarterWeightIntensity.medium => 2,
      StarterWeightIntensity.hard => 1,
    };
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

    final estimate = target.sourceEstimate == target.weight
        ? ''
        : ' estimate=${target.sourceEstimate.toStringAsFixed(1)}'
              ' working=${target.workingWeight.toStringAsFixed(1)}';
    final fatigue = target.fatigueMultiplier >= 0.999
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
}
