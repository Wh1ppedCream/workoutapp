// File: lib/repositories/app_repository.dart

import '../db/database_helper.dart';
import '../models/models.dart';

/// Central repository providing a unified interface for all
/// database operations in the UI layer.
/// Screens/widgets call into [AppRepository]; this forwards to DAOs via [DatabaseHelper].
class AppRepository {
  // ✨ Allow DI in tests; default to the singleton helper.
  AppRepository({DatabaseHelper? db}) : _dbHelper = db ?? DatabaseHelper();

  final DatabaseHelper _dbHelper;

  /// Exposes the internal DatabaseHelper instance for extensions.
  DatabaseHelper get dbHelper => _dbHelper;

  // ─── SESSIONS ───────────────────────────────────────────

  /// Creates a new workout session (legacy signature).
  /// Prefer [createSessionAt] which takes a DateTime.
  @Deprecated('Use createSessionAt(DateTime date, int duration) instead.')
  Future<int> createSession(String date, int duration) =>
      _dbHelper.createSession(date, duration);

  /// Creates a new workout session using DateTime for safety.
  Future<int> createSessionAt(DateTime date, int duration) =>
      _dbHelper.createSession(date.toIso8601String(), duration);

  /// Fetches all sessions as raw maps ordered by date descending.
  Future<List<Map<String, dynamic>>> fetchAllSessions() =>
      _dbHelper.getAllSessionsRaw();

  /// Deletes a session by its ID, cascading to related exercises & sets.
  Future<void> deleteSession(int id) => _dbHelper.deleteSession(id);

  /// Fetches a single session by ID (or null).
  Future<WorkoutSession?> fetchSessionById(int id) =>
      _dbHelper.fetchSessionById(id);

  /// Updates an existing session's date/duration.
  Future<void> updateSession(int id, DateTime d, int dur) =>
      _dbHelper.updateSession(id, d, dur);

  /// Retrieves sessions between [start] and [end] dates.
  Future<List<WorkoutSession>> fetchSessionsInRange(
          DateTime s, DateTime e) =>
      _dbHelper.fetchSessionsInRange(s, e);

  // ─── EXERCISES ──────────────────────────────────────────

  /// Adds a weight-based exercise to a session.
  Future<int> addExercise(int sid, String name, String eq, int idx) =>
      _dbHelper.addExercise(sid, name, eq, idx);

  /// Fetches exercise rows for a session.
  Future<List<Map<String, dynamic>>> fetchExercises(int sid) =>
      _dbHelper.fetchExercisesRaw(sid);

  /// Deletes all exercises (and related details) in a session.
  Future<void> deleteExercises(int sid) => _dbHelper.deleteExercises(sid);

  /// Inserts a generic exercise row of any type (weight, cardio, stretch).
  Future<int> addExerciseRow({
    int? exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
  }) =>
      _dbHelper.addExerciseRow(
        exerciseDefId: exerciseDefId,
        type: type,
        orderIndex: orderIndex,
        sessionId: sessionId,
      );

  /// Fetches a fully-detailed [WorkoutExercise] by its ID.
  Future<WorkoutExercise?> fetchDetailedExercise(int id) =>
      _dbHelper.fetchDetailedExercise(id);

  /// Deletes an exercise instance by its ID.
  Future<void> deleteExercise(int id) => _dbHelper.deleteExercise(id);

  // ─── SETS ───────────────────────────────────────────────

  /// Inserts a single set row for an exercise.
  Future<int> addSet(int exerciseId, double weight, int reps, int orderIndex) =>
      _dbHelper.addSet(exerciseId, weight, reps, orderIndex);

  /// Inserts parent and child sets for a weight exercise.
  Future<void> addWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) =>
      _dbHelper.addWeightSets(
        exerciseId: exerciseId,
        parentSets: parentSets,
        childChangeSets: childChangeSets,
      );

  /// Fetches all sets for an exercise.
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) =>
      _dbHelper.fetchSetsRaw(exerciseId);

  /// Update a single weight set’s weight & reps.
  Future<void> updateSet(int setId, double weight, int reps) =>
      _dbHelper.updateSet(setId, weight, reps);

  /// Delete a single set by its ID.
  Future<void> deleteSet(int setId) => _dbHelper.deleteSet(setId);

  /// Reorders sets within an exercise by their IDs.
  Future<void> reorderSets(int exerciseId, List<int> setIds) =>
      _dbHelper.reorderSets(exerciseId, setIds);

  // ─── CARDIO ────────────────────────────────────────────

  /// Canonical getter (matches DatabaseHelper).
  Future<Map<String, dynamic>?> getCardioDetailsForExercise(int exerciseId) =>
      _dbHelper.getCardioDetailsForExercise(exerciseId);

  /// Saves cardio details for an exercise (insert or replace).
  Future<void> saveCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) =>
      _dbHelper.saveCardioDetails(
        exerciseId: exerciseId,
        cardioName: cardioName,
        note: note,
        plannedMinutes: plannedMinutes,
        elapsedSeconds: elapsedSeconds,
      );

  /// Legacy alias of [saveCardioDetails]. Prefer the canonical name.
  @Deprecated('Use saveCardioDetails(...)')
  Future<void> setCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) =>
      _dbHelper.saveCardioDetails(
        exerciseId: exerciseId,
        cardioName: cardioName,
        note: note,
        plannedMinutes: plannedMinutes,
        elapsedSeconds: elapsedSeconds,
      );

  /// Fetches cardio details by exercise ID.
  Future<Map<String, dynamic>?> fetchCardioDetails(int exerciseId) =>
      _dbHelper.fetchCardioDetails(exerciseId);

  /// Update cardio details for an exercise.
  Future<void> updateCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) =>
      _dbHelper.updateCardioDetails(
        exerciseId: exerciseId,
        cardioName: cardioName,
        note: note,
        plannedMinutes: plannedMinutes,
        elapsedSeconds: elapsedSeconds,
      );

  /// Delete cardio details for a specific exercise.
  Future<void> deleteCardioDetails(int exerciseId) =>
      _dbHelper.deleteCardioDetails(exerciseId);

  // ─── STRETCH ────────────────────────────────────────────

  /// Strongly-typed variant.
  Future<void> saveClassStretchInstance({
    required int exerciseId,
    required List<StretchInstance> instances,
  }) =>
      _dbHelper.saveClassStretchInstance(
        exerciseId: exerciseId,
        instances: instances,
      );

  /// Saves a stretch instance and its items for an exercise.
  Future<void> saveStretchInstance({
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) =>
      _dbHelper.saveStretchInstance(exerciseId: exerciseId, items: items);

  /// Fetches stretch items for an exercise.
  Future<List<Map<String, dynamic>>> fetchStretchItems(int id) =>
      _dbHelper.fetchStretchItemsRaw(id);

  /// Updates a single stretch item’s fields.
  Future<int> updateStretchItem({
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) =>
      _dbHelper.updateStretchItem(
        itemId: itemId,
        stretchId: stretchId,
        isCustom: isCustom,
        customName: customName,
        customDesc: customDesc,
        isChecked: isChecked,
        orderIndex: orderIndex,
      );

  /// Deletes a single stretch item by ID.
  Future<void> deleteStretchItem(int itemId) =>
      _dbHelper.deleteStretchItem(itemId);

  /// Delete an entire stretch instance and its items.
  Future<void> deleteStretchInstance(int exerciseId) =>
      _dbHelper.deleteStretchInstance(exerciseId);

  /// Reorders stretch items by their IDs.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) =>
      _dbHelper.reorderStretchItems(exerciseId, itemIds);

  // ─── DEFINITIONS & FILTERS ─────────────────────────────

  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(int id) =>
      _dbHelper.lookupDefsByBodyPart(id);

  Future<List<ExerciseDefinition>> lookupDefsDetailed() =>
      _dbHelper.lookupDefsDetailed();

  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() =>
      _dbHelper.fetchAllExercisesRaw();

  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(
          List<String> equipmentNames) =>
      _dbHelper.lookupDefsWithAnyEquipment(equipmentNames);

  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
          List<String> equipmentNames,
          {bool includeNone = true}) =>
      _dbHelper.lookupDefsOnlyWithEquipment(equipmentNames,
          includeNone: includeNone);

  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) =>
      _dbHelper.lookupDefsFiltered(
        equipmentNames: equipmentNames,
        bodypartIds: bodypartIds,
        muscleIds: muscleIds,
      );

  Future<List<ExerciseDefinition>> fetchCatalogDefinitions({
    required bool useProfileFilter,
    int? profileId,
    String? equipmentFilter,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) =>
      _dbHelper.fetchCatalogDefinitions(
        useProfileFilter: useProfileFilter,
        profileId: profileId,
        equipmentFilter: equipmentFilter,
        bodypartIds: bodypartIds,
        muscleIds: muscleIds,
      );

  Future<int> addExerciseMuscleMapping(int defId, int muscleId, int rank) =>
      _dbHelper.insertExerciseMuscleMapping(defId, muscleId, rank);
  Future<int> deleteExerciseMuscleMapping(int defId, int muscleId) =>
      _dbHelper.deleteExerciseMuscleMapping(defId, muscleId);

  Future<int> addExerciseBodypartMapping(int defId, int bpId) =>
      _dbHelper.insertExerciseBodypartMapping(defId, bpId);
  Future<int> deleteExerciseBodypartMapping(int defId, int bpId) =>
      _dbHelper.deleteExerciseBodypartMapping(defId, bpId);

  Future<int> addExerciseEquipmentMapping(int defId, int eqId) =>
      _dbHelper.insertExerciseEquipmentMapping(defId, eqId);
  Future<int> deleteExerciseEquipmentMapping(int defId, int eqId) =>
      _dbHelper.deleteExerciseEquipmentMapping(defId, eqId);

  Future<int> findOrCreateExerciseDefinition(
          String name, String equipmentName) =>
      _dbHelper.findOrCreateExerciseDefinition(name, equipmentName);

  Future<Map<String, String?>> fetchDefinitionInfo(int defId) =>
      _dbHelper.fetchDefinitionInfo(defId);

  Future<void> updateExerciseDefinition(ExerciseDefinition def) =>
      _dbHelper.updateExerciseDefinition(def);

  Future<void> deleteExerciseDefinition(int defId) =>
      _dbHelper.deleteExerciseDefinition(defId);

  Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) =>
      _dbHelper.searchExerciseDefinitions(query);

  Future<ExerciseDefinition?> fetchDefinitionById(int defId) =>
      _dbHelper.getExerciseDefinitionById(defId);

  // ─── MEASUREMENTS & LOOKUPS ────────────────────────────

  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() =>
      _dbHelper.fetchMeasurementDefinitions();

  Future<int?> fetchMeasurementDefinitionId(String name) =>
      _dbHelper.fetchMeasurementDefinitionId(name);

  Future<int> insertMeasurement(
          int defId, DateTime timestamp, double value, String unit, String? note) =>
      _dbHelper.insertMeasurement(defId, timestamp, value, unit, note);

  Future<List<Map<String, dynamic>>> fetchMeasurementsForDefinition(
          int defId) =>
      _dbHelper.fetchMeasurementsRaw(defId);

  Future<List<Measurement>> fetchClassMeasurementsForDefinition(int defId) =>
      _dbHelper.fetchClassMeasurementsForDefinition(defId);

  Future<List<Map<String, dynamic>>> fetchUsedMeasurementDefinitions() =>
      _dbHelper.fetchUsedMeasurementDefinitionsRaw();

  Future<List<MeasurementDefinition>> fetchUsedClassMeasurementDefinitions() =>
      _dbHelper.fetchUsedClassMeasurementDefinitions();

  Future<Map<String, dynamic>?> fetchMeasurementById(int id) =>
      _dbHelper.fetchMeasurementById(id);

  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
  }) =>
      _dbHelper.updateMeasurement(
        measurementId: measurementId,
        timestamp: timestamp,
        value: value,
        unit: unit,
        note: note,
      );

  Future<void> deleteMeasurement(int measurementId) =>
      _dbHelper.deleteMeasurement(measurementId);

  Future<List<String>> fetchAllEquipmentNames() =>
      _dbHelper.fetchAllEquipmentNames();

  Future<List<BodyPart>> fetchAllBodyParts() => _dbHelper.fetchAllBodyParts();

  Future<List<Muscle>> fetchAllMuscles() => _dbHelper.fetchAllMuscles();

  Future<List<String>> fetchAllMuscleNames() =>
      _dbHelper.fetchAllMuscleNames();

  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) =>
      _dbHelper.fetchStretches(bodypartId: bodypartId);

  Future<String?> fetchStretchDefinitionNameById(int stretchId) =>
      _dbHelper.fetchStretchDefinitionNameById(stretchId);

  Future<List<ExerciseDefinition>> fetchExerciseDefinitionsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) =>
      _dbHelper.lookupDefsFiltered(
        equipmentNames: equipmentNames,
        bodypartIds: bodypartIds,
        muscleIds: muscleIds,
      );

  Future<List<Equipment>> fetchAllEquipment() => _dbHelper.fetchAllEquipment();

  Future<int> createEquipment(String name) =>
      _dbHelper.createEquipment(name);

  Future<void> updateEquipment(int id, String name) =>
      _dbHelper.updateEquipment(id, name);

  Future<void> deleteEquipment(int id) => _dbHelper.deleteEquipment(id);

  Future<List<BodyPart>> fetchAllBodyPartsFull() =>
      _dbHelper.fetchAllBodyPartsFull();

  Future<int> createBodyPart(String name) => _dbHelper.createBodyPart(name);

  Future<void> updateBodyPartEntry(int id, String name) =>
      _dbHelper.updateBodyPartEntry(id, name);

  Future<void> deleteBodyPartEntry(int id) =>
      _dbHelper.deleteBodyPartEntry(id);

  Future<List<Muscle>> fetchAllMusclesFull() =>
      _dbHelper.fetchAllMusclesFull();

  Future<int> createMuscle(String name) => _dbHelper.createMuscle(name);

  Future<void> updateMuscleEntry(int id, String name) =>
      _dbHelper.updateMuscleEntry(id, name);

  Future<void> deleteMuscleEntry(int id) =>
      _dbHelper.deleteMuscleEntry(id);

  Future<void> reseedLookupData() => _dbHelper.reseedLookupData();

  // Exporters
  Future<String> exportDatabase() => _dbHelper.exportDatabase();
  Future<String> exportEquipmentJson() => _dbHelper.exportEquipmentJson();
  Future<String> exportBodypartsJson() => _dbHelper.exportBodypartsJson();
  Future<String> exportMusclesJson() => _dbHelper.exportMusclesJson();
  Future<String> exportExercisesJson() => _dbHelper.exportExercisesJson();
  Future<String> exportStretchesJson() => _dbHelper.exportStretchesJson();
  Future<String> exportMuscleBodypartJson() =>
      _dbHelper.exportMuscleBodypartJson();
  Future<String> exportBodypartRankingJson() =>
      _dbHelper.exportBodypartRankingJson();
  Future<String> exportMuscleRankingJson() =>
      _dbHelper.exportMuscleRankingJson();
  Future<String> exportBodypartMuscleRankingsJson() =>
      _dbHelper.exportBodypartMuscleRankingsJson();
  Future<String> exportVolumeBoundariesJson() =>
      _dbHelper.exportVolumeBoundariesJson();

  /// Imports the database from a JSON string.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) =>
      _dbHelper.importDatabase(jsonStr, clearFirst: clearFirst);

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) =>
      _dbHelper.fuzzsearchExercises(term);

  /// Returns all sessions as WorkoutSession objects, sorted by date desc.
  Future<List<WorkoutSession>> fetchWorkoutSessions() =>
      _dbHelper.fetchWorkoutSessions();

  // ─── STATS ───────────────────────────────────────────────────────────────

  Future<void> updateRepMax(
          int defId,
          int repCount,
          String timeframe,
          double rmValue,
          double oneErm,
          bool isErm) =>
      _dbHelper.upsertRepMax(
          defId, repCount, timeframe, rmValue, oneErm, isErm);

  Future<void> updateVolumeMax(int defId, String timeframe, double vmValue) =>
      _dbHelper.upsertVolumeMax(defId, timeframe, vmValue);

  // Stats queries
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) =>
      _dbHelper.fetchRepMaxes(defId, timeframe);

  Future<double?> fetchVolumeMax(int defId, String timeframe) =>
      _dbHelper.fetchVolumeMax(defId, timeframe);

  Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) =>
      _dbHelper.calculateTotalVolumeForSessions(sessionIds);

  // ─── ANALYTICS ─────────────────────────────────────────────

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) =>
      _dbHelper.linkMuscleToBodyPart(muscleId, bodypartId);

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) =>
      _dbHelper.unlinkMuscleFromBodyPart(muscleId, bodypartId);

  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) =>
      _dbHelper.fetchBodyPartsForMuscle(muscleId);

  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) =>
      _dbHelper.fetchMusclesForBodyPart(bodypartId);

  Future<int> setBodyPartRank(int bodypartId, int rank) =>
      _dbHelper.setBodyPartRank(bodypartId, rank);

  Future<BodyPartRanking?> getBodyPartRank(int bodypartId) =>
      _dbHelper.getBodyPartRank(bodypartId);

  Future<List<BodyPartRanking>> getAllBodyPartRanks() =>
      _dbHelper.getAllBodyPartRanks();

  Future<int> deleteBodyPartRank(int bodypartId) =>
      _dbHelper.deleteBodyPartRank(bodypartId);

  Future<int> setMuscleRank(int muscleId, int rank) =>
      _dbHelper.setMuscleRank(muscleId, rank);

  Future<MuscleRanking?> getMuscleRank(int muscleId) =>
      _dbHelper.getMuscleRank(muscleId);

  Future<List<MuscleRanking>> getAllMuscleRanks() =>
      _dbHelper.getAllMuscleRanks();

  Future<int> deleteMuscleRank(int muscleId) =>
      _dbHelper.deleteMuscleRank(muscleId);

  Future<int> setExerciseMuscleHitPercent(
          int defId, int muscleId, double pct) =>
      _dbHelper.setExerciseMuscleHitPercent(defId, muscleId, pct);

  Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(
          int defId, int muscleId) =>
      _dbHelper.fetchExerciseMusclePercent(defId, muscleId);

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) =>
      _dbHelper.removeExerciseMusclePercent(defId, muscleId);

  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(int defId) =>
      _dbHelper.fetchPercentsForExercise(defId);

  Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) =>
      _dbHelper.setMuscleVolumeBounds(muscleId, b);

  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) =>
      _dbHelper.fetchMuscleVolumeBounds(muscleId);

  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() =>
      _dbHelper.fetchAllMuscleVolumeBounds();

  Future<int> removeMuscleVolumeBounds(int muscleId) =>
      _dbHelper.removeMuscleVolumeBounds(muscleId);

  Future<int> setBodyPartVolumeBounds(
          int bodyPartId, VolumeBoundaries bounds) =>
      _dbHelper.setBodyPartVolumeBounds(bodyPartId, bounds);

  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) =>
      _dbHelper.fetchBodyPartVolumeBounds(bodyPartId);

  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() =>
      _dbHelper.fetchAllBodyPartVolumeBounds();

  Future<int> removeBodyPartVolumeBounds(int bodyPartId) =>
      _dbHelper.removeBodyPartVolumeBounds(bodyPartId);

  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
          int defId) =>
      _dbHelper.fetchBodyPartPercentsManual(defId);

  Future<int> setExerciseBodyPartPercent(int defId, int bpId, double pct) =>
      _dbHelper.setExerciseBodyPartPercent(defId, bpId, pct);

  Future<int> removeExerciseBodyPartPercent(int defId, int bpId) =>
      _dbHelper.deleteExerciseBodyPartPercent(defId, bpId);

  Future<double> getFormulaStep() => _dbHelper.getFormulaStep();
  Future<double> getFormulaMin() => _dbHelper.getFormulaMin();
  Future<double> getFormulaMax() => _dbHelper.getFormulaMax();

  Future<void> setFormulaStep(double s) => _dbHelper.setFormulaStep(s);
  Future<void> setFormulaMin(double m) => _dbHelper.setFormulaMin(m);
  Future<void> setFormulaMax(double m) => _dbHelper.setFormulaMax(m);

  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) =>
      _dbHelper.computeMusclePercents(defId);

  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) =>
      _dbHelper.computeBodyPartPercents(defId);

  Future<Map<BodyPart, double>> estimateBodyPartSetDistribution(int defId) =>
      _dbHelper.estimateBodyPartSetDistribution(defId);

  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(int defId) =>
      _dbHelper.computeMuscleCalculatedBodyparts(defId);

  Future<Map<int, double>> fetchMuscleSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
  }) =>
      _dbHelper.fetchMuscleSetsForExerciseOverTimeRange(
          defId: defId, start: start, end: end);

  Future<Map<int, double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) =>
      _dbHelper.fetchAllMuscleSetsOverTimeRange(start: start, end: end);

  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) =>
      _dbHelper.fetchAllBodyPartSetsOverTimeRange(start: start, end: end);

  Future<Map<BodyPart, double>> fetchBodyPartSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
  }) =>
      _dbHelper.fetchBodyPartSetsForExerciseOverTimeRange(
          defId: defId, start: start, end: end);

  Future<int> findExerciseDefinitionId(String name, String equipmentName) =>
      _dbHelper.findExerciseDefinitionId(name, equipmentName);

  // ─── GYM PROFILES ────────────────────────────────────────

  Future<int> createProfile(String name) => _dbHelper.createProfile(name);
  Future<List<GymProfile>> fetchAllProfiles() =>
      _dbHelper.fetchAllProfiles();
  Future<int> updateProfile(GymProfile profile) =>
      _dbHelper.updateProfile(profile);
  Future<int> deleteProfile(int profileId) =>
      _dbHelper.deleteProfile(profileId);
  Future<void> addEquipmentToProfile(int profileId, int equipmentId) =>
      _dbHelper.addEquipmentToProfile(profileId, equipmentId);
  Future<void> removeEquipmentFromProfile(int profileId, int equipmentId) =>
      _dbHelper.removeEquipmentFromProfile(profileId, equipmentId);
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(int profileId) =>
      _dbHelper.fetchEquipmentForProfile(profileId);

  // ─── PRESETS: Definition CRUD ─────────────────────────────

  Future<int> createPreset(String name, {int? profileId}) =>
      _dbHelper.createPreset(name, profileId: profileId);

  Future<int> findOrCreatePreset(String name, {int? profileId}) =>
      _dbHelper.findOrCreatePreset(name, profileId: profileId);

  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({int? profileId}) =>
      _dbHelper.fetchAllPresetsRaw(profileId: profileId);

  Future<PresetDefinition?> fetchPresetById(int presetId) =>
      _dbHelper.fetchPresetById(presetId);

  Future<void> updatePresetName(int presetId, String name) =>
      _dbHelper.updatePresetName(presetId, name);

  Future<void> deletePreset(int presetId) =>
      _dbHelper.deletePreset(presetId);

  // ─── PRESETS: Exercise CRUD ───────────────────────────────

  Future<int> addExerciseToPreset(
          int presetId, int? exerciseDefId, String type, int orderIndex) =>
      _dbHelper.addExerciseToPreset(presetId, exerciseDefId, type, orderIndex);

  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) =>
      _dbHelper.fetchPresetExercises(presetId);

  Future<void> deletePresetExercises(int presetId) =>
      _dbHelper.deletePresetExercises(presetId);

  // ─── PRESETS: Detail CRUD ─────────────────────────────────

  Future<void> savePresetWeightSets(
          int presetExerciseId,
          List<ExerciseSet> parents,
          Map<int, List<ExerciseSet>> children) =>
      _dbHelper.savePresetWeightSets(presetExerciseId, parents, children);

  Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) =>
      _dbHelper.fetchPresetSets(presetExerciseId);

  Future<void> savePresetCardio(
          int presetExerciseId,
          String cardioName,
          String? note,
          int plannedMinutes,
          int elapsedSeconds) =>
      _dbHelper.savePresetCardio(
          presetExerciseId, cardioName, note, plannedMinutes, elapsedSeconds);

  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) =>
      _dbHelper.fetchPresetCardio(presetExerciseId);

  Future<void> savePresetStretch(
          int presetExerciseId, List<Map<String, dynamic>> items) =>
      _dbHelper.savePresetStretch(presetExerciseId, items);

  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
          int presetExerciseId) =>
      _dbHelper.fetchPresetStretchItems(presetExerciseId);

  // ─── AUTOPRESET SETTINGS ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) =>
      _dbHelper.fetchPresetAutoSettings(presetId);

  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool weightCheck,
    required bool repCheck,
    required bool volumeCheck,
    required bool adjustAllSets,
    required bool useManualSelect,
    String? manualSelectionJson,
  }) =>
      _dbHelper.upsertPresetAutoSettings(
        presetId: presetId,
        isAutomatic: isAutomatic,
        globalIncrement: globalIncrement,
        skipFirstSet: skipFirstSet,
        weightCheck: weightCheck,
        repCheck: repCheck,
        volumeCheck: volumeCheck,
        adjustAllSets: adjustAllSets,
        useManualSelect: useManualSelect,
        manualSelectionJson: manualSelectionJson,
      );

  Future<void> deletePresetAutoSettings(int presetId) =>
      _dbHelper.deletePresetAutoSettings(presetId);

  // ─── PER-EXERCISE OVERRIDES ───────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
          int presetExerciseId) =>
      _dbHelper.fetchPresetExerciseAuto(presetExerciseId);

  Future<void> upsertPresetExerciseAuto({
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) =>
      _dbHelper.upsertPresetExerciseAuto(
        presetExerciseId: presetExerciseId,
        incrementAmount: incrementAmount,
        lastSetIndex: lastSetIndex,
        lastNode: lastNode,
      );

  Future<void> deletePresetExerciseAuto(int presetExerciseId) =>
      _dbHelper.deletePresetExerciseAuto(presetExerciseId);

  // ─── PER-SET OVERRIDES ─────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) =>
      _dbHelper.fetchPresetSetAuto(presetSetId);

  Future<void> upsertPresetSetAuto({
    required int presetSetId,
    double? incrementAmount,
  }) =>
      _dbHelper.upsertPresetSetAuto(
        presetSetId: presetSetId,
        incrementAmount: incrementAmount,
      );

  Future<void> deletePresetSetAuto(int presetSetId) =>
      _dbHelper.deletePresetSetAuto(presetSetId);

  Future<void> updatePresetSetWeight(int presetSetId, double weight) =>
      _dbHelper.updatePresetSetWeight(presetSetId, weight);

  Future<void> updatePresetSetReps(int presetSetId, int reps) =>
      _dbHelper.updatePresetSetReps(presetSetId, reps);

  Future<int> addPresetSet({
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) =>
      _dbHelper.addPresetSet(
        presetExerciseId: presetExerciseId,
        weight: weight,
        reps: reps,
        orderIndex: orderIndex,
        parentSetId: parentSetId,
      );

  Future<int> deletePresetSet(int presetSetId) =>
      _dbHelper.deletePresetSet(presetSetId);

  /// Flow‐chart JSON for a preset.
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async {
    final jsonStr = await _dbHelper.fetchFlowDefinition(presetId);
    return FlowDefinition.fromJson(jsonStr);
  }

  Future<void> upsertFlowDefinition(int presetId, FlowDefinition def) =>
      _dbHelper.upsertFlowDefinition(presetId, def.toJson());

  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async {
    final rows = await _dbHelper.fetchFlowMethods(presetId);
    return rows.map((r) => FlowMethod.fromMap(r)).toList();
  }

  Future<FlowMethod> upsertFlowMethod({
    required int presetId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final id = await _dbHelper.upsertFlowMethod(
      presetId: presetId,
      name: name,
      type: type.toShortString(),
      params: params,
    );
    return FlowMethod(
      id: id,
      presetId: presetId,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<void> deleteFlowMethod(int methodId) =>
      _dbHelper.deleteFlowMethod(methodId);

  Future<bool> getUseManualBodyparts(int defId) =>
      _dbHelper.getUseManualBodyparts(defId);
  Future<void> setUseManualBodyparts(int defId, bool value) =>
      _dbHelper.setUseManualBodyparts(defId, value);

  Future<bool> getUseManualMuscles(int defId) =>
      _dbHelper.getUseManualMuscles(defId);
  Future<void> setUseManualMuscles(int defId, bool value) =>
      _dbHelper.setUseManualMuscles(defId, value);

  Future<bool> getMultiplyByRating(int defId) =>
      _dbHelper.getMultiplyByRating(defId);
  Future<void> setMultiplyByRating(int defId, bool enabled) =>
      _dbHelper.setMultiplyByRating(defId, enabled);

  // ─── FLOW‐CHART DEFAULTS WRAPPERS ─────────────────────────────────────

  Future<String> fetchDefaultFlow(
    String scope, {
    int? profileId,
  }) =>
      _dbHelper.fetchDefaultFlow(scope, profileId: profileId);

  Future<void> upsertDefaultFlow(
    String scope, {
    int? profileId,
    required String flowJson,
  }) =>
      _dbHelper.upsertDefaultFlow(
        scope,
        profileId: profileId,
        flowJson: flowJson,
      );

  Future<void> deleteDefaultFlow(
    String scope, {
    int? profileId,
  }) =>
      _dbHelper.deleteDefaultFlow(scope, profileId: profileId);

  Future<List<FlowMethod>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async {
    final rows =
        await _dbHelper.fetchDefaultFlowMethods(scope, profileId: profileId);
    return rows.map((r) => FlowMethod.fromMap(r)).toList();
  }

  /// Upsert one default flow‐method and return its real id.
  Future<FlowMethod> upsertDefaultFlowMethod({
    required String scope,
    int? profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final id = await _dbHelper.upsertDefaultFlowMethod(
      scope,
      profileId: profileId,
      name: name,
      type: type.toShortString(),
      params: params,
    );
    return FlowMethod(
      id: id, // ✅ real row id
      // this model uses `presetId`; for defaults we stash the profileId or -1
      presetId: profileId ?? -1,
      name: name,
      type: type,
      params: params,
    );
  }

  Future<void> deleteDefaultFlowMethod({
    required String scope,
    int? profileId,
    required String name,
  }) =>
      _dbHelper.deleteDefaultFlowMethod(
        scope,
        profileId: profileId,
        name: name,
      );

  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) =>
      _dbHelper.fetchDefaultFlowDefinition(scope, profileId: profileId);

  // ─── Personal info ─────────────────────────────────────

  Future<PersonalInfo?> fetchPersonalInfo() => _dbHelper.getPersonalInfo();
  Future<void> savePersonalInfo(PersonalInfo info) =>
      _dbHelper.upsertPersonalInfo(info);

  // ─── NUTRITION ──────────────────────────────────────────────────────────

  // Day view
  Future<DayTotals> getDayTotals(int profileId, DateTime date) =>
      _dbHelper.getDayTotals(profileId, date);
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) =>
      _dbHelper.getActiveGoals(profileId, date);
  Future<List<DiaryEntry>> getDiaryEntriesForDate(
          int profileId, DateTime date) =>
      _dbHelper.getDiaryEntriesForDate(profileId, date);

  // Logging
  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) =>
      _dbHelper.addDiaryFood(
        profileId: profileId,
        date: date,
        mealType: mealType,
        foodId: foodId,
        portionId: portionId,
        quantity: quantity,
        gramsOverride: gramsOverride,
        loggedGrams: loggedGrams,
        loggedAt: loggedAt,
        notes: notes,
      );

  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) =>
      _dbHelper.addDiaryRecipe(
        profileId: profileId,
        date: date,
        mealType: mealType,
        recipeId: recipeId,
        quantity: quantity,
        loggedAt: loggedAt,
        notes: notes,
      );

  Future<void> updateDiaryEntry(DiaryEntry e) => _dbHelper.updateDiaryEntry(e);
  Future<void> deleteDiaryEntry(int id,
          {required int profileId, required DateTime date}) =>
      _dbHelper.deleteDiaryEntry(id, profileId: profileId, date: date);

  // Foods & portions
  Future<int> upsertFood(Food f) => _dbHelper.upsertFood(f);
  Future<Food?> getFood(int id) => _dbHelper.getFood(id);
  Future<List<Food>> searchFoods(String query, {int limit = 50}) =>
      _dbHelper.searchFoods(query, limit: limit);

  Future<int> upsertFoodPortion(FoodPortion p) =>
      _dbHelper.upsertFoodPortion(p);
  Future<List<FoodPortion>> getPortionsForFood(int foodId) =>
     _dbHelper.getPortionsForFood(foodId);
  Future<void> setDefaultPortion(int foodId, int portionId) =>
      _dbHelper.setDefaultPortion(foodId, portionId);

  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) =>
      _dbHelper.upsertFoodNutrients(foodId, rows);
  Future<Map<int, double>> getFoodNutrientsPer100g(int foodId) =>
      _dbHelper.getFoodNutrientsPer100g(foodId);
  Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) =>
      _dbHelper.getFoodNutrientsPer100gByCode(foodId);

  // Recipes
  Future<int> createOrUpdateRecipe(
          Recipe r, List<RecipeIngredient> ings) =>
      _dbHelper.createOrUpdateRecipe(r, ings);
  Future<Recipe?> getRecipe(int id) => _dbHelper.getRecipe(id);
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) =>
      _dbHelper.getRecipeIngredients(recipeId);

  // Goals & cache
  Future<void> setGoals(NutritionGoal goal) => _dbHelper.setGoals(goal);
  Future<void> recalcDayTotals(int profileId, DateTime date) =>
      _dbHelper.recalcDayTotals(profileId, date);

  Future<int> createCustomFood({required String name, String? brand}) =>
      _dbHelper.createCustomFood(name: name, brand: brand);

  Future<void> savePer100gByCode(
          int foodId, Map<String, double> codeToAmount) =>
      _dbHelper.savePer100gByCode(foodId, codeToAmount);

  Future<void> savePer100gFromLabelPayload(
          int foodId, Map<String, dynamic> payload) =>
      _dbHelper.savePer100gFromLabelPayload(foodId, payload);

  /// Returns a per-100g macro map using UI keys:
  ///   'PROTEIN_G', 'CARB_G', 'FAT_G', 'KCAL'
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async {
    final all = await getFoodNutrientsPer100gByCode(foodId);
    double? pick(List<String> codes) {
      for (final c in codes) {
        final v = all[c];
        if (v != null) return v;
      }
      return null;
    }
    final out = <String, double>{};
    final p = pick(['PROTEIN_G', 'PROTEIN']);
    if (p != null) out['PROTEIN_G'] = p;
    final c = pick(['CARB_G', 'CARB']);
    if (c != null) out['CARB_G'] = c;
    final f = pick(['FAT_G', 'FAT']);
    if (f != null) out['FAT_G'] = f;
    final k = pick(['KCAL', 'ENERGY_KCAL', 'CALORIES']);
    if (k != null) out['KCAL'] = k;
    return out;
  }

  Future<void> saveExtendedPer100gFromPayload(
          int foodId, Map<String, dynamic> payload) =>
      _dbHelper.saveExtendedPer100gFromPayload(foodId, payload);

  Future<int> addPortion(
    int foodId, {
    required String measureName,
    double? gramWeight,
    double? mlVolume,
    bool isDefault = false,
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) =>
      _dbHelper.addPortion(
        foodId,
        measureName: measureName,
        gramWeight: gramWeight,
        mlVolume: mlVolume,
        isDefault: isDefault,
        listKind: listKind,
        sortOrder: sortOrder,
        amount: amount,
        unit: unit,
        label: label,
      );

  Future<void> replacePortions(int foodId, List<FoodPortion> portions) =>
      _dbHelper.replacePortions(foodId, portions);

  Future<void> updateFoodBasics(int id, {String? name, String? brand}) =>
      _dbHelper.updateFoodBasics(id, name: name, brand: brand);

  Future<void> updateFoodFromCustomizationPayload(
          Map<String, dynamic> payload) =>
      _dbHelper.updateFoodFromCustomizationPayload(payload);

  Future<Food?> getFoodByBarcode(String code) =>
      _dbHelper.getFoodByBarcode(code);
  Future<void> addBarcode(int foodId, String code) =>
      _dbHelper.addBarcode(foodId, code);

  Future<int> upsertFoodWithKeys({
    int? id,
    required String name,
    String? brandName,
    String? sourceName,
    String? categoryName,
    List<String> barcodes = const [],
    double? densityGPerMl,
    bool isCustom = false,
    String? dataSource,
    String? dataSourceId,
  }) =>
      _dbHelper.upsertFoodWithKeys(
        id: id,
        name: name,
        brandName: brandName,
        sourceName: sourceName,
        categoryName: categoryName,
        barcodes: barcodes,
        densityGPerMl: densityGPerMl,
        isCustom: isCustom,
        dataSource: dataSource,
        dataSourceId: dataSourceId,
      );

  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) =>
      _dbHelper.calcForPortion(
        foodId: foodId,
        portionId: portionId,
        quantity: quantity,
      );

  // Diary (range)
  Future<List<DiaryEntry>> getDiaryEntriesBetween(
    int profileId,
    DateTime start,
    DateTime end, {
    MealType? mealType,
    int limit = 1000,
  }) =>
      _dbHelper.getDiaryEntriesBetween(
        profileId,
        start,
        end,
        mealType: mealType,
        limit: limit,
      );

  // Day micro aggregation
  Future<Map<String, double>> getDayMicros(
          int profileId, DateTime date, List<String> codes) =>
      _dbHelper.getDayMicros(profileId, date, codes);

  // Favorites
  Future<void> addFavorite(int profileId, int foodId) =>
      _dbHelper.addFavorite(profileId, foodId);
  Future<void> removeFavorite(int profileId, int foodId) =>
      _dbHelper.removeFavorite(profileId, foodId);
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) =>
      _dbHelper.listFavorites(profileId, limit: limit);

  // Recents
  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) =>
      _dbHelper.getRecentFoods(profileId, limit: limit);
  Future<List<Recipe>> getRecentRecipes(int profileId, {int limit = 20}) =>
      _dbHelper.getRecentRecipes(profileId, limit: limit);

  // Tags
  Future<void> addDiaryTag(int entryId, String tag) =>
      _dbHelper.addDiaryTag(entryId, tag);
  Future<void> removeDiaryTag(int entryId, String tag) =>
      _dbHelper.removeDiaryTag(entryId, tag);
  Future<List<String>> getTagsForEntry(int entryId) =>
      _dbHelper.getTagsForEntry(entryId);
  Future<List<DiaryEntry>> getEntriesByTag({
    required int profileId,
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) =>
      _dbHelper.getEntriesByTag(
        profileId: profileId,
        tag: tag,
        start: start,
        end: end,
        limit: limit,
      );

  // Recipe cache reads
  Future<Map<String, double>> getRecipePer100gByCode(int recipeId) =>
      _dbHelper.getRecipePer100gByCode(recipeId);
  Future<void> rebuildRecipeNutrientCache(int recipeId) =>
      _dbHelper.rebuildRecipeNutrientCache(recipeId);

  // FTS maintenance
  Future<void> rebuildFoodFts() => _dbHelper.rebuildFoodFts();

  // DB lifecycle
  Future<void> close() => _dbHelper.close();

  // Seed core nutrient catalog if the nutrients table is empty.
  Future<void> seedNutrientsIfEmpty() => _dbHelper.seedNutrientsIfEmpty();

/// Opens the DB once so first-run copy/migrations happen before UI.
/// Optionally runs a quick integrity check.
Future<bool> warmUp({bool verify = false}) async {
  final db = await _dbHelper.database;
  if (!verify) return true;
  try { await db.rawQuery('PRAGMA quick_check'); return true; }
  catch (_) { return false; }
}



}
