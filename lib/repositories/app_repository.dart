// File: lib/repositories/app_repository.dart

import '../db/database_helper.dart';
import '../models/models.dart';

/// Central repository providing a unified interface for all

/// database operations in the UI layer.

///

/// Screens and widgets use [AppRepository] to perform CRUD on sessions,

/// exercises, sets, cardio details, stretch details, definitions,

/// measurements, and lookup tables. Internally delegates to DAOs via

/// [DatabaseHelper].
class AppRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

    /// Exposes the internal DatabaseHelper instance for extensions.
  DatabaseHelper get dbHelper => _dbHelper;


  // ─── SESSIONS ───────────────────────────────────────────

  /// Creates a new workout session.
  ///
  /// - [date]: ISO 8601 date string representing session start.
  /// - [duration]: Duration in seconds.
  ///
  /// Returns the newly inserted session ID.
  Future<int> createSession(String date, int duration) => _dbHelper.createSession(date, duration);

/// Fetches all sessions as raw maps ordered by date descending.
  Future<List<Map<String, dynamic>>> fetchAllSessions() => _dbHelper.getAllSessionsRaw();

/// Deletes a session by its ID, cascading to related exercises & sets.
  Future<void> deleteSession(int id) => _dbHelper.deleteSession(id);

 /// Fetches a single session by ID.
 /// Returns a [WorkoutSession] or `null` if not found.
  Future<WorkoutSession?> fetchSessionById(int id) => _dbHelper.fetchSessionById(id);

  /// Updates an existing session's date/duration.
  Future<void> updateSession(int id, DateTime d, int dur) => _dbHelper.updateSession(id, d, dur);

/// Retrieves sessions between [start] and [end] dates.
  Future<List<WorkoutSession>> fetchSessionsInRange(DateTime s, DateTime e) => _dbHelper.fetchSessionsInRange(s, e);

// ─── EXERCISES ──────────────────────────────────────────

/// Adds a weight-based exercise to a session.
  Future<int> addExercise(int sid, String name, String eq, int idx) => _dbHelper.addExercise(sid, name, eq, idx);

 /// Fetches exercise rows for a session.
  Future<List<Map<String,dynamic>>> fetchExercises(int sid) => _dbHelper.fetchExercisesRaw(sid);

/// Deletes all exercises (and related details) in a session.
  Future<void> deleteExercises(int sid) => _dbHelper.deleteExercises(sid);

/// Inserts a generic exercise row of any type (weight, cardio, stretch).
  Future<int> addExerciseRow({ int?    exerciseDefId, required String type, required int orderIndex, required int sessionId,}) 
  => _dbHelper.addExerciseRow( exerciseDefId: exerciseDefId, type: type, orderIndex: orderIndex, sessionId: sessionId, );

 /// Fetches a fully-detailed [WorkoutExercise] by its ID.
Future<WorkoutExercise?> fetchDetailedExercise(int id) => _dbHelper.fetchDetailedExercise(id);

 /// Deletes an exercise instance by its ID.
  Future<void> deleteExercise(int id) => _dbHelper.deleteExercise(id);

  // ─── SETS ───────────────────────────────────────────────

/// Inserts a single set row for an exercise.
  Future<int> addSet(int exerciseId, double weight, int reps, int orderIndex) => _dbHelper.addSet(exerciseId, weight, reps, orderIndex);

 /// Inserts parent and child sets for a weight exercise.
  Future<void> addWeightSets({ required int exerciseId, required List<ExerciseSet> parentSets, required Map<int,List<ExerciseSet>> childChangeSets,}) 
  => _dbHelper.addWeightSets( exerciseId: exerciseId, parentSets: parentSets, childChangeSets: childChangeSets, );

/// Fetches all sets for an exercise.
  Future<List<Map<String,dynamic>>> fetchSets(int exerciseId) => _dbHelper.fetchSetsRaw(exerciseId);

  /// Update a single weight set’s weight & reps.
 Future<void> updateSet(int setId, double weight, int reps) => _dbHelper.updateSet(setId, weight, reps);

  /// Delete a single set by its ID.
  Future<void> deleteSet(int setId) => _dbHelper.deleteSet(setId);

 /// Reorders sets within an exercise by their IDs.
  Future<void> reorderSets(int exerciseId, List<int> setIds) => _dbHelper.reorderSets(exerciseId, setIds);


  // ─── CARDIO ────────────────────────────────────────────

/// Saves cardio details for an exercise (insert or replace).
  Future<void> saveCardioDetails({required int exerciseId, required String cardioName, String? note, required int plannedMinutes, required int elapsedSeconds,}) 
  => _dbHelper.saveCardioDetails( exerciseId: exerciseId, cardioName: cardioName, note: note, plannedMinutes: plannedMinutes, elapsedSeconds: elapsedSeconds, );

/// Fetches cardio details by exercise ID.
Future<Map<String,dynamic>?> fetchCardioDetails(int exerciseId) => _dbHelper.fetchCardioDetails(exerciseId);

/// Insert or replace cardio details for an exercise.
  Future<void> setCardioDetails({required int exerciseId, required String cardioName, String? note, required int plannedMinutes, required int elapsedSeconds,}) 
  => _dbHelper.saveCardioDetails( exerciseId: exerciseId, cardioName: cardioName, note: note, plannedMinutes: plannedMinutes, elapsedSeconds: elapsedSeconds, );

 /// Update cardio details for an exercise.
  Future<void> updateCardioDetails({ required int exerciseId,  required String cardioName, String? note, required int plannedMinutes, required int elapsedSeconds,}) 
  => _dbHelper.updateCardioDetails(exerciseId: exerciseId, cardioName: cardioName, note: note, plannedMinutes: plannedMinutes, elapsedSeconds: elapsedSeconds, );

/// Delete cardio details for a specific exercise.
  Future<void> deleteCardioDetails(int exerciseId) => _dbHelper.deleteCardioDetails(exerciseId);


  // ─── STRETCH ────────────────────────────────────────────

/// Saves a stretch instance and its items for an exercise.
Future<void> saveStretchInstance({required int exerciseId, required List<Map<String, dynamic>> items,}) 
=> _dbHelper.saveStretchInstance( exerciseId: exerciseId, items: items, );

/// Fetches stretch items for an exercise.
  Future<List<Map<String,dynamic>>> fetchStretchItems(int id) =>  _dbHelper.fetchStretchItemsRaw(id);


/// Updates a single stretch item’s fields.
  Future<int> updateStretchItem({required int itemId, int? stretchId, bool? isCustom, String? customName, String? customDesc, bool? isChecked, int? orderIndex,}) =>
  _dbHelper.updateStretchItem(    itemId: itemId,    stretchId: stretchId,    isCustom: isCustom,    customName: customName,    customDesc: customDesc,    isChecked: isChecked,    orderIndex: orderIndex,  );

/// Deletes a single stretch item by ID.
  Future<void> deleteStretchItem(int itemId) =>  _dbHelper.deleteStretchItem(itemId);

  /// Delete an entire stretch instance and its items.
  Future<void> deleteStretchInstance(int exerciseId) =>  _dbHelper.deleteStretchInstance(exerciseId);

  /// Reorders stretch items by their IDs.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) => _dbHelper.reorderStretchItems(exerciseId, itemIds);

  // ─── DEFINITIONS & FILTERS ─────────────────────────────

/// Fetch exercise definitions by body part ID.
  Future<List<Map<String,dynamic>>> lookupDefsByBodyPart(int id) => _dbHelper.lookupDefsByBodyPart(id);

/// Fetches all detailed definitions with equipment, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> lookupDefsDetailed() => _dbHelper.lookupDefsDetailed();

/// Fetches shallow definition rows.
  Future<List<Map<String,dynamic>>> fetchAllExercisesRaw() => _dbHelper.fetchAllExercisesRaw();

/// Filters definitions by any of the provided equipment names.
  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(List<String> equipmentNames) =>  _dbHelper.lookupDefsWithAnyEquipment(equipmentNames);

/// Filters definitions by equipment only, including or excluding null.
  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment( List<String> equipmentNames,   { bool includeNone = true,}) =>
  _dbHelper.lookupDefsOnlyWithEquipment(equipmentNames, includeNone: includeNone);


/// Applies combined filters on definitions.
 Future<List<ExerciseDefinition>> lookupDefsFiltered({  List<String>? equipmentNames,  List<int>?    bodypartIds,  List<int>?    muscleIds,}) =>
  _dbHelper.lookupDefsFiltered(    equipmentNames: equipmentNames,    bodypartIds: bodypartIds,    muscleIds: muscleIds,  );

/// New: Fetches catalog definitions with optional workspace-profile and
  /// detailed filters.
  Future<List<ExerciseDefinition>> fetchCatalogDefinitions(
    {required bool useProfileFilter, int? profileId, String? equipmentFilter, List<int>? bodypartIds, List<int>? muscleIds,}) => 
  _dbHelper.fetchCatalogDefinitions( 
    useProfileFilter: useProfileFilter, profileId: profileId, equipmentFilter: equipmentFilter, bodypartIds: bodypartIds, muscleIds: muscleIds,
    );


/// Finds or creates a definition by name and equipment, returns its ID.
  Future<int> findOrCreateExerciseDefinition(String name, String equipmentName) => _dbHelper.findOrCreateExerciseDefinition(name, equipmentName);


  /// Fetches the name & equipment for a definition ID.
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) => _dbHelper.fetchDefinitionInfo(defId);


/// Update an existing exercise definition’s name/equipment/rating.
  Future<void> updateExerciseDefinition(ExerciseDefinition def) => _dbHelper.updateExerciseDefinition(def);

/// Deletes a definition and cascades its joins.
  Future<void> deleteExerciseDefinition(int defId) => _dbHelper.deleteExerciseDefinition(defId);

/// Performs case-insensitive name search on definitions.
  Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) => _dbHelper.searchExerciseDefinitions(query);

/// Fetches a full ExerciseDefinition by ID (including equipment/bodyParts/muscles).
Future<ExerciseDefinition?> fetchDefinitionById(int defId) => _dbHelper.getExerciseDefinitionById(defId);


  // ─── MEASUREMENTS & LOOKUPS ────────────────────────────

/// Fetches all measurement definitions.
Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() => _dbHelper.fetchMeasurementDefinitions();

// Retrieves definition ID for a given name, or null if not exists.
Future<int?> fetchMeasurementDefinitionId(String name) =>  _dbHelper.fetchMeasurementDefinitionId(name);

/// Inserts a new measurement record.
Future<int> insertMeasurement(  int defId,  DateTime timestamp,  double value,  String unit,  String? note,) =>
  _dbHelper.insertMeasurement(defId, timestamp, value, unit, note);

  /// Fetches measurements for a definition as raw maps.
Future<List<Map<String, dynamic>>> fetchMeasurementsForDefinition(int defId) => _dbHelper.fetchMeasurementsRaw(defId);


/// Fetches all measurements for a definition and maps to [Measurement] models.
Future<List<Measurement>> fetchClassMeasurementsForDefinition(int defId) =>  _dbHelper.fetchClassMeasurementsForDefinition(defId);


/// Retrieves only those measurement definitions that have at least one recorded entry.
///
/// Delegates to [Lookup_Dao.getUsedMeasurementDefinitions], which performs a JOIN
/// between `measurement_definitions` and `measurements` and returns:
///   • `id`
///   • `name`
///   • `type`
///
/// - Returns: A list of maps, each containing the `id`, `name`, and `type` of
///   a measurement definition that’s been used at least once.
Future<List<Map<String, dynamic>>> fetchUsedMeasurementDefinitions() =>  _dbHelper.fetchUsedMeasurementDefinitionsRaw();

/// Returns definitions with at least one measurement recorded.
Future<List<MeasurementDefinition>> fetchUsedClassMeasurementDefinitions() =>  _dbHelper.fetchUsedClassMeasurementDefinitions();

  /// Retrieve a single measurement as a raw map.
Future<Map<String, dynamic>?> fetchMeasurementById(int id) =>  _dbHelper.fetchMeasurementById(id);


  /// Update an existing measurement.
Future<void> updateMeasurement({  required int measurementId,  required DateTime timestamp,  required double value,  required String unit,  String? note,}) =>
  _dbHelper.updateMeasurement(    measurementId: measurementId,    timestamp: timestamp,    value: value,    unit: unit,    note: note,  );

  /// Delete a measurement by its ID.
Future<void> deleteMeasurement(int measurementId) =>  _dbHelper.deleteMeasurement(measurementId);

 /// Fetches all equipment names.
Future<List<String>> fetchAllEquipmentNames() =>  _dbHelper.fetchAllEquipmentNames();


/// Fetches all body parts as [BodyPart] models.
Future<List<BodyPart>> fetchAllBodyParts() =>  _dbHelper.fetchAllBodyParts();

  /// Fetch all muscles as full models (id + name).
  /// /// Fetches all muscles as [Muscle] models.
Future<List<Muscle>> fetchAllMuscles() =>  _dbHelper.fetchAllMuscles();

/// Fetches all muscle names.
Future<List<String>> fetchAllMuscleNames() =>  _dbHelper.fetchAllMuscleNames();

/// Fetches stretch definitions, optionally filtered by body part ID.
Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) =>  _dbHelper.fetchStretches(bodypartId: bodypartId);

/// Fetches a stretch definition's name by ID.
Future<String?> fetchStretchDefinitionNameById(int stretchId) =>  _dbHelper.fetchStretchDefinitionNameById(stretchId);

/// Fetches exercise definitions with optional filters.
  Future<List<ExerciseDefinition>> fetchExerciseDefinitionsFiltered({ List<String>? equipmentNames,  List<int>?    bodypartIds,  List<int>?    muscleIds,}) 
  => _dbHelper.lookupDefsFiltered( equipmentNames: equipmentNames,bodypartIds:    bodypartIds, muscleIds:      muscleIds, );

/// Retrieves all equipment entries as [Equipment] models.
Future<List<Equipment>> fetchAllEquipment() =>  _dbHelper.fetchAllEquipment();


/// Creates a new equipment entry with the given [name].
  ///
  /// Returns the newly inserted equipment’s row ID.
Future<int> createEquipment(String name) =>  _dbHelper.createEquipment(name);

  /// Updates the equipment entry identified by [id] to have the new [name].
  ///
  /// Completes when the update has been applied.
Future<void> updateEquipment(int id, String name) =>  _dbHelper.updateEquipment(id, name);

  /// Deletes the equipment entry identified by [id].
  ///
  /// Any relationships in join tables will cascade if foreign keys are enabled.
Future<void> deleteEquipment(int id) =>  _dbHelper.deleteEquipment(id);

 /// Retrieves all body‐part entries as [BodyPart] models
Future<List<BodyPart>> fetchAllBodyPartsFull() =>  _dbHelper.fetchAllBodyPartsFull();

  /// Creates a new body‐part entry with the given [name].
  ///
  /// Returns the newly inserted body‐part’s row ID.
Future<int> createBodyPart(String name) =>  _dbHelper.createBodyPart(name);

  /// Updates the body‐part entry identified by [id] to have the new [name].
Future<void> updateBodyPartEntry(int id, String name) =>  _dbHelper.updateBodyPartEntry(id, name);

  /// Deletes the body‐part entry identified by [id].
Future<void> deleteBodyPartEntry(int id) =>  _dbHelper.deleteBodyPartEntry(id);

/// Retrieves all muscle entries as [Muscle] models.
Future<List<Muscle>> fetchAllMusclesFull() =>  _dbHelper.fetchAllMusclesFull();

  /// Creates a new muscle entry with the given [name].
  ///
  /// Returns the newly inserted muscle’s row ID.
Future<int> createMuscle(String name) =>  _dbHelper.createMuscle(name);

  /// Updates the muscle entry identified by [id] to have the new [name].
Future<void> updateMuscleEntry(int id, String name) =>  _dbHelper.updateMuscleEntry(id, name);

  /// Deletes the muscle entry identified by [id].
Future<void> deleteMuscleEntry(int id) =>  _dbHelper.deleteMuscleEntry(id);

  /// Re-runs JSON-based seeding for lookup tables and stretches.
Future<void> reseedLookupData() =>  _dbHelper.reseedLookupData();

/// Exports the entire database to a JSON string for backup.
  Future<String> exportDatabase() async { return _dbHelper.exportDatabase(); }

  /// Imports the database from a JSON string.
  ///
  /// If [clearFirst] is true, existing rows are deleted before import.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    await _dbHelper.importDatabase(jsonStr, clearFirst: clearFirst);
  }

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) =>  _dbHelper.fuzzsearchExercises(term);


  /// Returns all sessions as WorkoutSession objects, sorted by date desc.
Future<List<WorkoutSession>> fetchWorkoutSessions() =>  _dbHelper.fetchWorkoutSessions();

// ─── STATS ───────────────────────────────────────────────────────────────

/// Record or update a rep-max stat.
Future<void> updateRepMax(int defId, int repCount, String timeframe, double rmValue, double oneErm, bool isErm,)
=> _dbHelper.upsertRepMax( defId,    repCount, timeframe, rmValue, oneErm, isErm,);

/// Record or update a volume-max stat.
Future<void> updateVolumeMax(int defId, String timeframe, double vmValue,) => _dbHelper.upsertVolumeMax(defId, timeframe, vmValue);

// ─── STATS QUERIES ─────────────────────────────────────────────────────

/// Fetches rep-max stats (rep_count, rm_value, one_erm, is_erm) for an exercise.
Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) => _dbHelper.fetchRepMaxes(defId, timeframe);

/// Fetches the volume-max value (or null) for an exercise.
Future<double?> fetchVolumeMax(int defId, String timeframe) => _dbHelper.fetchVolumeMax(defId, timeframe);

/// Calculates the total weight-×-reps volume across the given session IDs.
Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) =>  _dbHelper.calculateTotalVolumeForSessions(sessionIds);

//analytics_dao.dart
 // ─── ANALYTICS ─────────────────────────────────────────────

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) =>  _dbHelper.linkMuscleToBodyPart(muscleId, bodypartId);

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) => _dbHelper.unlinkMuscleFromBodyPart(muscleId, bodypartId);

Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) => _dbHelper.fetchBodyPartsForMuscle(muscleId);

Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) => _dbHelper.fetchMusclesForBodyPart(bodypartId);

Future<int> setBodyPartRank(int bodypartId, int rank) => _dbHelper.setBodyPartRank(bodypartId, rank);

Future<BodyPartRanking?> getBodyPartRank(int bodypartId) => _dbHelper.getBodyPartRank(bodypartId);

Future<List<BodyPartRanking>> getAllBodyPartRanks() => _dbHelper.getAllBodyPartRanks();

  Future<int> deleteBodyPartRank(int bodypartId) =>  _dbHelper.deleteBodyPartRank(bodypartId);

Future<int> setMuscleRank(int muscleId, int rank) =>  _dbHelper.setMuscleRank(muscleId, rank);

Future<MuscleRanking?> getMuscleRank(int muscleId) => _dbHelper.getMuscleRank(muscleId);

Future<List<MuscleRanking>> getAllMuscleRanks() => _dbHelper.getAllMuscleRanks();

Future<int> deleteMuscleRank(int muscleId) => _dbHelper.deleteMuscleRank(muscleId);

Future<int> setExerciseMuscleHitPercent(int defId, int muscleId, double pct) => _dbHelper.setExerciseMuscleHitPercent(defId, muscleId, pct);

Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(int defId, int muscleId) => _dbHelper.fetchExerciseMusclePercent(defId, muscleId);

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) => _dbHelper.removeExerciseMusclePercent(defId, muscleId);

Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(int defId) => _dbHelper.fetchPercentsForExercise(defId);

Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) => _dbHelper.setMuscleVolumeBounds(muscleId, b);

Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) => _dbHelper.fetchMuscleVolumeBounds(muscleId);

Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() => _dbHelper.fetchAllMuscleVolumeBounds();

Future<int> removeMuscleVolumeBounds(int muscleId) => _dbHelper.removeMuscleVolumeBounds(muscleId);

Future<int> setBodyPartVolumeBounds(int bodyPartId, VolumeBoundaries bounds) => _dbHelper.setBodyPartVolumeBounds(bodyPartId, bounds);

Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) => _dbHelper.fetchBodyPartVolumeBounds(bodyPartId);

Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() => _dbHelper.fetchAllBodyPartVolumeBounds();

Future<int> removeBodyPartVolumeBounds(int bodyPartId) => _dbHelper.removeBodyPartVolumeBounds(bodyPartId);

  /// Public getters so screens can read the current formula params:
  Future<double> getFormulaStep() => _dbHelper.getFormulaStep();
  Future<double> getFormulaMin() => _dbHelper.getFormulaMin();
  Future<double> getFormulaMax() => _dbHelper.getFormulaMax();


  /// Updates the default-step parameter (e.g. 0.05).
  Future<void> setFormulaStep(double s) => _dbHelper.setFormulaStep(s);
  Future<void> setFormulaMin(double m) => _dbHelper.setFormulaMin(m);
  Future<void> setFormulaMax(double m) => _dbHelper.setFormulaMax(m);

  /// Computes per-muscle % for [exerciseDefId], using formula params + any overrides.
   Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) => _dbHelper.computeMusclePercents(defId);



  /// Computes per-body-part % by averaging muscle percents belonging to each part.
  Future<Map<BodyPart,double>> computeBodyPartPercents(int defId) => _dbHelper.computeBodyPartPercents(defId);

/// Returns a map muscleId → total “sets” for that muscle, summing
  /// (1 × muscleHitPercent) for every weight‐exercise set in sessions
  /// between [start] and [end].
  Future<Map<int,double>> fetchSetsPerMuscle({ required DateTime start, required DateTime end, }) => _dbHelper.fetchSetsPerMuscle(start: start, end: end);

  /// Returns a map BodyPart → total “sets” for that body‐part over
  /// [start]…[end], by summing the muscle‐level contributions
  /// into their linked body‐parts.
  Future<Map<BodyPart,double>> fetchSetsPerBodyPart({required DateTime start, required DateTime end, }) 
   => _dbHelper.fetchSetsPerBodyPart(start: start, end: end);

  /// Look up an existing definition by name & equipment, but do *not* create it.
/// Returns the defId, or throws if not found.
Future<int> findExerciseDefinitionId(String name, String equipmentName) => _dbHelper.findExerciseDefinitionId(name, equipmentName);

// ─── GYM PROFILES ────────────────────────────────────────

  /// Creates a new gym profile and returns its id.
Future<int> createProfile(String name) => _dbHelper.createProfile(name);

  /// Retrieves all gym profiles.
Future<List<GymProfile>> fetchAllProfiles() => _dbHelper.fetchAllProfiles();

  /// Updates an existing gym profile.
Future<int> updateProfile(GymProfile profile) => _dbHelper.updateProfile(profile);

  /// Deletes a gym profile by id.
Future<int> deleteProfile(int profileId) => _dbHelper.deleteProfile(profileId);

  /// Adds equipment to a gym profile.
Future<void> addEquipmentToProfile(int profileId, int equipmentId) => _dbHelper.addEquipmentToProfile(profileId, equipmentId);

  /// Removes equipment from a gym profile.
Future<void> removeEquipmentFromProfile(int profileId, int equipmentId) => _dbHelper.removeEquipmentFromProfile(profileId, equipmentId);

  /// Fetches equipment for a specific gym profile.
Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(int profileId) => _dbHelper.fetchEquipmentForProfile(profileId);

// ─── PRESETS: Definition CRUD ─────────────────────────────

  /// Creates a new Preset with the given [name], optionally scoped to [profileId].
  /// Returns the new Preset's database ID.
Future<int> createPreset(String name, {int? profileId}) => _dbHelper.createPreset(name, profileId: profileId);

  /// Finds an existing Preset by [name] and optional [profileId], or creates one.
  /// Returns the Preset's database ID.
Future<int> findOrCreatePreset(String name, {int? profileId}) => _dbHelper.findOrCreatePreset(name, profileId: profileId);

  /// Retrieves all Presets as raw maps, scoped to [profileId] if provided.
Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({int? profileId}) => _dbHelper.fetchAllPresetsRaw(profileId: profileId);

// Fetches a single Preset by its [presetId].
Future<PresetDefinition?> fetchPresetById(int presetId) => _dbHelper.fetchPresetById(presetId);

 /// Updates the name of an existing Preset.
Future<void> updatePresetName(int presetId, String name) => _dbHelper.updatePresetName(presetId, name);

/// Deletes a Preset and cascades removal of its exercises and details.
Future<void> deletePreset(int presetId) => _dbHelper.deletePreset(presetId);

// ─── PRESETS: Exercise CRUD ───────────────────────────────

/// Adds a new exercise to a Preset.
Future<int> addExerciseToPreset(  int presetId,  int? exerciseDefId,  String type,  int orderIndex,) =>
  _dbHelper.addExerciseToPreset(presetId, exerciseDefId, type, orderIndex);

/// Retrieves raw exercise rows for a given Preset.
Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) => _dbHelper.fetchPresetExercises(presetId);

 
Future<void> deletePresetExercises(int presetId) => _dbHelper.deletePresetExercises(presetId);

// ─── PRESETS: Detail CRUD ─────────────────────────────────

/// Saves weight sets for a Preset exercise.
Future<void> savePresetWeightSets( int presetExerciseId, List<ExerciseSet> parents, Map<int, List<ExerciseSet>> children,) =>
  _dbHelper.savePresetWeightSets(presetExerciseId, parents, children);

  /// Fetches weight sets for a Preset exercise.
Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) => _dbHelper.fetchPresetSets(presetExerciseId);

/// Saves cardio details for a Preset exercise.
Future<void> savePresetCardio( int presetExerciseId, String cardioName, String? note, int plannedMinutes, int elapsedSeconds,) =>
  _dbHelper.savePresetCardio(presetExerciseId,cardioName,  note, plannedMinutes,elapsedSeconds,);

/// Fetches the saved cardio details row for a Preset exercise.
Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) => _dbHelper.fetchPresetCardio(presetExerciseId);

 /// Saves stretch items for a Preset exercise.
Future<void> savePresetStretch( int presetExerciseId, List<Map<String, dynamic>> items,) => _dbHelper.savePresetStretch(presetExerciseId, items);

/// Fetches stored stretch items for a Preset exercise.
Future<List<Map<String, dynamic>>> fetchPresetStretchItems(int presetExerciseId) => _dbHelper.fetchPresetStretchItems(presetExerciseId);


// ─── AUTOPRESET SETTINGS ───────────────────────────────────────────────

  /// Fetches the global auto-preset settings for a given preset.
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) =>
      _dbHelper.fetchPresetAutoSettings(presetId);

  /// Inserts or updates the global auto-preset settings.
  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
  required bool   weightCheck,
  required bool   repCheck,
  required bool   volumeCheck,
  required bool   adjustAllSets,
  }) => _dbHelper.upsertPresetAutoSettings(
        presetId: presetId,
        isAutomatic: isAutomatic,
        globalIncrement: globalIncrement,
        skipFirstSet: skipFirstSet,
    weightCheck:     weightCheck,
    repCheck:        repCheck,
    volumeCheck:     volumeCheck,
    adjustAllSets:     adjustAllSets,
      );

  /// Deletes the auto-preset settings (disables automatic) for a preset.
  Future<void> deletePresetAutoSettings(int presetId) =>
      _dbHelper.deletePresetAutoSettings(presetId);

  // ─── PER-EXERCISE OVERRIDES ───────────────────────────────────────────

  /// Fetches the auto override (IA + rotation) for a specific preset exercise.
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
          int presetExerciseId) =>
      _dbHelper.fetchPresetExerciseAuto(presetExerciseId);

  /// Inserts or updates the per-exercise IA override and last_set_index.
  Future<void> upsertPresetExerciseAuto({ required int presetExerciseId, double? incrementAmount, required int lastSetIndex,}) => 
  _dbHelper.upsertPresetExerciseAuto( presetExerciseId: presetExerciseId, incrementAmount: incrementAmount, lastSetIndex: lastSetIndex,  );

  /// Deletes the per-exercise auto override for a preset exercise.
  Future<void> deletePresetExerciseAuto(int presetExerciseId) =>  _dbHelper.deletePresetExerciseAuto(presetExerciseId);

  // ─── PER-SET OVERRIDES ─────────────────────────────────────────────────

  /// Fetches the per-set IA override for a specific preset set.
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) =>
      _dbHelper.fetchPresetSetAuto(presetSetId);

  /// Inserts or updates the per-set IA override.
  Future<void> upsertPresetSetAuto({ required int presetSetId,  double? incrementAmount, }) => 
  _dbHelper.upsertPresetSetAuto( presetSetId: presetSetId, incrementAmount: incrementAmount,  );

  /// Deletes the per-set IA override for a preset set.
  Future<void> deletePresetSetAuto(int presetSetId) => _dbHelper.deletePresetSetAuto(presetSetId);

  /// Updates the weight for a preset set.
  Future<void> updatePresetSetWeight(int presetSetId, double weight) =>  _dbHelper.updatePresetSetWeight(presetSetId, weight);

  /// Flow‐chart JSON for a preset.
Future<FlowDefinition> fetchFlowDefinition(int presetId) async {
  final jsonStr = await _dbHelper.fetchFlowDefinition(presetId);
  return FlowDefinition.fromJson(jsonStr);
}

/// Save flow‐chart JSON for a preset.
Future<void> upsertFlowDefinition(int presetId, FlowDefinition def) {
  return _dbHelper.upsertFlowDefinition(presetId, def.toJson());
}

/// Retrieve all FlowMethods for a preset.
Future<List<FlowMethod>> fetchFlowMethods(int presetId) async {
  final rows = await _dbHelper.fetchFlowMethods(presetId);
  return rows.map((r) => FlowMethod.fromMap(r)).toList();
}

/// Create or update a FlowMethod.
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
  return FlowMethod(id: id, presetId: presetId, name: name, type: type, params: params);
}

/// Delete a FlowMethod by its ID.
Future<void> deleteFlowMethod(int methodId) {
  return _dbHelper.deleteFlowMethod(methodId);
}

}