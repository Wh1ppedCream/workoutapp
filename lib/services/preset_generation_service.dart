// lib/services/preset_generation_service.dart

import '../repositories/app_repository.dart';
import '../models/models.dart';

/// Service that generates presets automatically from:
/// - recent training history
/// - bodypart volume bounds / deficits
/// - catalog definitions & ratings
class PresetGenerationService {
  final AppRepository _repo;

  PresetGenerationService(this._repo);

  /// Main entry point.
  ///
  /// Creates a new preset according to [spec] and returns its presetId.
  Future<int> generatePreset(SessionSpec spec) async {
    final end = spec.now;
    final start = end.subtract(spec.historyWindow);

    // 1) Figure out which bodyparts are under-trained (deficits).
    final targets = await _loadBodyPartTargets(
      focusIds: spec.focusBodypartIds,
      start: start,
      end: end,
    );

    if (targets.isEmpty) {
      // No bodyparts or no bounds → trivial fallback preset.
      return _createFallbackPreset(spec);
    }

    // 2) Build candidate exercise pool scored by how well they
    // hit your deficits + their catalog rating.
    final candidates = await _buildCandidatePool(
      spec: spec,
      targets: targets,
    );

    if (candidates.isEmpty) {
      return _createFallbackPreset(spec);
    }

    // 3) Rank by score and select the top N.
    candidates.sort((a, b) => b.score.compareTo(a.score));
    final selected = candidates.take(spec.maxExercises).toList();

    // 4) Persist into preset_* tables.
    final presetId = await _createPresetInDb(spec, selected);

    // 5) Initialize Auto-Preset defaults so it’s ready to auto-progress.
    await _initAutoSettings(presetId);

    return presetId;
  }

  // ──────────────────────────────────────────────────────────────
  // STEP 1: Bodypart targets & deficits
  // ──────────────────────────────────────────────────────────────

  Future<List<BodyPartTarget>> _loadBodyPartTargets({
    required List<int> focusIds,
    required DateTime start,
    required DateTime end,
  }) async {
    // All bodyparts from lookup table
    final allBodyParts = await _repo.fetchAllBodyParts();

    // Historical “set units” per bodypart over [start, end].
    final historyMap = await _repo.fetchAllBodyPartSetsOverTimeRange(
      start: start,
      end: end,
    ); // Map<BodyPart, double>

    final historyById = <int, double>{};
    historyMap.forEach((bp, val) {
      historyById[bp.id] = val;
    });

    final result = <BodyPartTarget>[];

    for (final bp in allBodyParts) {
      // If focus list is non-empty, only consider those bodyparts.
      if (focusIds.isNotEmpty && !focusIds.contains(bp.id)) continue;

      final VolumeBoundaries? bounds =
          await _repo.fetchBodyPartVolumeBounds(bp.id);

      // Very simple default if no bounds defined.
      final weeklyTarget = bounds?.minEffective ?? 10.0;
      final done = historyById[bp.id] ?? 0.0;

      result.add(
        BodyPartTarget(
          bodyPart: bp,
          weeklyTargetUnits: weeklyTarget,
          doneThisWeek: done,
        ),
      );
    }

    return result;
  }

  // ──────────────────────────────────────────────────────────────
  // STEP 2: Candidate exercise pool
  // ──────────────────────────────────────────────────────────────

  Future<List<CandidateExercisePlan>> _buildCandidatePool({
    required SessionSpec spec,
    required List<BodyPartTarget> targets,
  }) async {
    // Map bodypartId → deficit units
    final deficitById = <int, double>{
      for (final t in targets) t.bodyPart.id: t.deficit,
    };

    // Catalog defs filtered by profile + optional focus bodyparts.
    final defs = await _repo.fetchCatalogDefinitions(
      useProfileFilter: true,
      profileId: spec.profileId,
      equipmentFilter: null,
      bodypartIds: spec.focusBodypartIds.isEmpty
          ? null
          : spec.focusBodypartIds,
      muscleIds: null,
    );

    final candidates = <CandidateExercisePlan>[];

    for (final def in defs) {
      // Bodypart “units” per set for this exercise.
      final unitsPerSet = await _repo.computeBodyPartPercents(def.id);
      if (unitsPerSet.isEmpty) continue;

      double rawScore = 0.0;
      double totalHit = 0.0;

      unitsPerSet.forEach((bp, units) {
        totalHit += units;
        final deficit = deficitById[bp.id] ?? 0.0;
        // Prioritize bodyparts that are further below their target.
        rawScore += units * (1.0 + deficit);
      });

      if (totalHit <= 0.0) continue;

      // Use catalog rating as a soft multiplier; safe even if 0 / missing.
      final num ratingNum = def.rating; // assuming your model has this
      final double rating =
          ratingNum.toDouble(); // convert int/num to double
      final ratingFactor =
          rating <= 0 ? 1.0 : (0.5 + rating / 100.0).clamp(0.5, 2.0);

      final score = rawScore * ratingFactor;
      if (score <= 0.0) continue;

      candidates.add(
        CandidateExercisePlan(
          def: def,
          unitsPerSet: unitsPerSet,
          score: score,
          // For now: fixed min sets.
          suggestedSets: spec.minSetsPerExercise,
        ),
      );
    }

    return candidates;
  }

  // ──────────────────────────────────────────────────────────────
  // STEP 3: Persist preset + exercises + sets
  // ──────────────────────────────────────────────────────────────

   Future<int> _createPresetInDb(
    SessionSpec spec,
    List<CandidateExercisePlan> selected,
  ) async {
    // Ensure we don't violate UNIQUE(name, profile_id).
    final name = await _pickUniquePresetName(spec);

    final presetId = await _repo.createPreset(
      name,
      profileId: spec.profileId,
    );

    var orderIndex = 0;
    for (final candidate in selected) {
      final defId = candidate.def.id;

      final presetExerciseId = await _repo.addExerciseToPreset(
        presetId,
        defId,
        'weight', // these are all weight exercises for now
        orderIndex++,
      );

      // Simple placeholder sets: 0kg x 10 reps.
      // Auto-Preset logic will handle real progression.
      final parents = List<ExerciseSet>.generate(
        candidate.suggestedSets,
        (_) => ExerciseSet(weight: 0, reps: 10),
      );

      final children = <int, List<ExerciseSet>>{};

      await _repo.savePresetWeightSets(
        presetExerciseId,
        parents,
        children,
      );
    }

    return presetId;
  }

  // ──────────────────────────────────────────────────────────────
  // STEP 4: Initialize auto-preset defaults
  // ──────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────
  // Fallback if analytics don’t give us anything
  // ──────────────────────────────────────────────────────────────

  Future<int> _createFallbackPreset(SessionSpec spec) async {
    // If analytics fail (no bounds / no percents), just grab some
    // reasonable exercises from the catalog and create a basic preset.
    final defs = await _repo.fetchCatalogDefinitions(
      useProfileFilter: true,
      profileId: spec.profileId,
      equipmentFilter: null,
      bodypartIds:
          spec.focusBodypartIds.isEmpty ? null : spec.focusBodypartIds,
      muscleIds: null,
    );

    if (defs.isEmpty) {
      // Worst case: an empty preset with just a name.
      return _repo.createPreset(spec.name, profileId: spec.profileId);
    }

    final selected = defs.take(spec.maxExercises).map((def) {
      return CandidateExercisePlan(
        def: def,
        unitsPerSet: const {},
        score: 1.0,
        suggestedSets: spec.minSetsPerExercise,
      );
    }).toList();

    final presetId = await _createPresetInDb(spec, selected);
    await _initAutoSettings(presetId);
    return presetId;
  }

  /// Picks a unique preset name for this profile, based on [spec.name]
  /// (or a dated default if spec.name is empty).
  Future<String> _pickUniquePresetName(SessionSpec spec) async {
    // Base name: use spec.name if provided, otherwise a simple dated default.
    final baseName = spec.name.isNotEmpty
        ? spec.name
        : 'Auto preset ${spec.now.toIso8601String().split('T').first}';

    // Fetch existing presets for this profile so we can avoid name clashes.
    final rows = await _repo.fetchAllPresetsRaw(profileId: spec.profileId);
    final existingNames = rows
        .map((row) => row['name'])
        .whereType<String>()
        .toSet();

    // If baseName is taken, append " (2)", " (3)", ... until unique.
    var name = baseName;
    var suffix = 2;
    while (existingNames.contains(name)) {
      name = '$baseName ($suffix)';
      suffix++;
    }

    return name;
  }


}
