// File: lib/repositories/app_repository.dart

import '../db/database_helper.dart';
import '../db/session_dao.dart';
import '../db/exercise_dao.dart';
import '../db/set_dao.dart';
import '../db/cardio_dao.dart';
import '../db/stretch_dao.dart';
import '../db/definition_dao.dart';
import '../db/lookup_dao.dart';
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
  final _db = DatabaseHelper();

  // ─── SESSIONS ───────────────────────────────────────────



  /// Creates a new workout session.
  ///
  /// - [date]: ISO 8601 date string representing session start.
  /// - [duration]: Duration in seconds.
  ///
  /// Returns the newly inserted session ID.
  Future<int> createSession(String date, int duration) async {
    final db = await _dbHelper.database;
    return SessionDao.insertSession(db, date, duration);
  }

/// Fetches all sessions as raw maps ordered by date descending.
  Future<List<Map<String, dynamic>>> fetchAllSessions() async {
    final db = await _dbHelper.database;
    return SessionDao.getAllSessionsRaw(db);
  }

/// Deletes a session by its ID, cascading to related exercises & sets.
  Future<void> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    return SessionDao.deleteSession(db, sessionId);
  }

 /// Fetches a single session by ID.
 /// Returns a [WorkoutSession] or `null` if not found.
  Future<WorkoutSession?> fetchSessionById(int sessionId) async {
    final db  = await _dbHelper.database;
    final row = await SessionDao.getSessionById(db, sessionId);
    if (row == null) return null;
    return WorkoutSession(
      id:       row['id']       as int,
      date:     DateTime.parse(row['date'] as String),
      duration: row['duration'] as int,
    );
  }

  /// Updates an existing session's date/duration.
  Future<void> updateSession(
    int sessionId,
    DateTime newDate,
    int newDuration,
  ) async {
    final db   = await _dbHelper.database;
    final iso  = newDate.toIso8601String();
    await SessionDao.updateSession(db, sessionId, iso, newDuration);
  }

/// Retrieves sessions between [start] and [end] dates.
  Future<List<WorkoutSession>> fetchSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db    = await _dbHelper.database;
    final raw   = await SessionDao.getSessionsInRange(
      db,
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return raw.map((row) => WorkoutSession(
      id:       row['id']       as int,
      date:     DateTime.parse(row['date'] as String),
      duration: row['duration'] as int,
    )).toList();
  }

  // ─── EXERCISES ──────────────────────────────────────────

/// Adds a weight-based exercise to a session.
  Future<int> addExercise(
    int sessionId,
    String name,
    String equipmentName,
    int orderIndex,
  ) async {
    final db = await _dbHelper.database;
    return ExerciseDao.insertExercise(db, sessionId, name, equipmentName, orderIndex);
  }

 /// Fetches exercise rows for a session.
  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async {
    final db = await _dbHelper.database;
    return ExerciseDao.getExercisesForSession(db, sessionId);
  }

/// Deletes all exercises (and related details) in a session.
  Future<void> deleteExercises(int sessionId) async {
    final db = await _dbHelper.database;
    return ExerciseDao.deleteExercisesForSession(db, sessionId);
  }

/// Inserts a generic exercise row of any type (weight, cardio, stretch).
  Future<int> addExerciseRow({
    int?    exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
  }) async {
    final db = await _dbHelper.database;
    return ExerciseDao.insertExerciseRow(
      db: db,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
      sessionId: sessionId,
    );
  }

 /// Fetches a fully-detailed [WorkoutExercise] by its ID.
Future<WorkoutExercise?> fetchDetailedExercise(int id) {
    return _db.fetchDetailedExercise(id);
  }

 /// Deletes an exercise instance by its ID.
  Future<void> deleteExercise(int id) {
    return _db.deleteExercise(id); // or use ExerciseDao.deleteExerciseById under the hood
  }

  // ─── SETS ───────────────────────────────────────────────

/// Inserts a single set row for an exercise.
  Future<int> addSet(
    int exerciseId,
    double weight,
    int reps,
    int orderIndex,
  ) async {
    final db = await _dbHelper.database;
    return SetDao.insertSet(db, exerciseId, weight, reps, orderIndex);
  }

 /// Inserts parent and child sets for a weight exercise.
  Future<void> addWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    final db = await _dbHelper.database;
    return SetDao.insertWeightSets(
      db: db,
      exerciseId: exerciseId,
      parentSets: parentSets,
      childChangeSets: childChangeSets,
    );
  }

/// Fetches all sets for an exercise.
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) async {
    final db = await _dbHelper.database;
    return SetDao.getSetsForExercise(db, exerciseId);
  }

  /// Update a single weight set’s weight & reps.
  Future<void> updateSet(int setId, double weight, int reps) async {
    final db = await _dbHelper.database;
    await SetDao.updateSet(db, setId, weight, reps);
  }

  /// Delete a single set by its ID.
  Future<void> deleteSet(int setId) async {
    final db = await _dbHelper.database;
    await SetDao.deleteSet(db, setId);
  }

 /// Reorders sets within an exercise by their IDs.
  Future<void> reorderSets(int exerciseId, List<int> setIds) async {
    final db = await _dbHelper.database;
    await SetDao.reorderSets(db, exerciseId, setIds);
  }


  // ─── CARDIO ────────────────────────────────────────────

/// Saves cardio details for an exercise (insert or replace).
  Future<void> saveCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await _dbHelper.database;
    return CardioDao.insertCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

/// Fetches cardio details by exercise ID.
  Future<Map<String, dynamic>?> fetchCardioDetails(int exerciseId) async {
    final db = await _dbHelper.database;
    return CardioDao.getCardioDetailsForExercise(db, exerciseId);
  }

/// Insert or replace cardio details for an exercise.
  Future<void> setCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await _dbHelper.database;
    await CardioDao.insertCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

 /// Update cardio details for an exercise.
  Future<void> updateCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await _dbHelper.database;
    await CardioDao.updateCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

/// Delete cardio details for a specific exercise.
  Future<void> deleteCardioDetails(int exerciseId) async {
    final db = await _dbHelper.database;
    await CardioDao.deleteCardioDetails(db, exerciseId);
  }


  // ─── STRETCH ────────────────────────────────────────────

/// Saves a stretch instance and its items for an exercise.
  Future<void> saveStretchInstance({
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await _dbHelper.database;
    return StretchDao.insertStretchInstance(
      db: db,
      exerciseId: exerciseId,
      items: items,
    );
  }

/// Fetches stretch items for an exercise.
  Future<List<Map<String, dynamic>>> fetchStretchItems(int exerciseId) async {
    final db = await _dbHelper.database;
    return StretchDao.getStretchItemsForExercise(db, exerciseId);
  }

/// Updates a single stretch item’s fields.
  Future<void> updateStretchItem({
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) async {
    final db = await _dbHelper.database;
    await StretchDao.updateStretchItem(
     db: db,
      itemId: itemId,
      stretchId: stretchId,
      isCustom: isCustom,
      customName: customName,
      customDesc: customDesc,
      isChecked: isChecked,
      orderIndex: orderIndex,
    );
  }

/// Deletes a single stretch item by ID.
  Future<void> deleteStretchItem(int itemId) async {
    final db = await _dbHelper.database;
    await StretchDao.deleteStretchItem(db, itemId);
  }

  /// Delete an entire stretch instance and its items.
  Future<void> deleteStretchInstance(int exerciseId) async {
    final db = await _dbHelper.database;
    await StretchDao.deleteStretchInstance(db, exerciseId);
  }

  /// Reorders stretch items by their IDs.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) async {
    final db = await _dbHelper.database;
    await StretchDao.reorderStretchItems(db, exerciseId, itemIds);
  }

  // ─── DEFINITIONS & FILTERS ─────────────────────────────

/// Fetch exercise definitions by body part ID.
  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(int bodyPartId) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
  }

/// Fetches all detailed definitions with equipment, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    final db = await _dbHelper.database;
    return DefinitionDao.getAllExerciseDefinitionsDetailed(db);
  }

/// Fetches shallow definition rows.
  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() async {
    final db = await _dbHelper.database;
    return DefinitionDao.getAllExercisesRaw(db);
  }

/// Filters definitions by any of the provided equipment names.
  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(List<String> equipmentNames) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
  }

/// Filters definitions by equipment only, including or excluding null.
  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
    List<String> equipmentNames, {
    bool includeNone = true,
  }) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefsOnlyWithEquipment(
      db,
      equipmentNames,
      includeNone: includeNone,
    );
  }

/// Applies combined filters on definitions.
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>?    bodypartIds,
    List<int>?    muscleIds,
  }) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefinitionsFiltered(
      db,
      equipmentNames: equipmentNames,
      bodypartIds: bodypartIds,
      muscleIds: muscleIds,
    );
  }

/// Finds or creates a definition by name and equipment, returns its ID.
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async {
    final db = await _dbHelper.database;
    return DefinitionDao.findOrCreateExerciseDefinition(
      db,
      name,
      equipmentName,
    );
  }


  /// Fetches the name & equipment for a definition ID.
  Future<Map<String,String?>> fetchDefinitionInfo(int defId) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getDefinitionInfo(db, defId);
  }

/// Update an existing exercise definition’s name/equipment/rating.
  Future<void> updateExerciseDefinition(ExerciseDefinition def) async {
    final db = await _dbHelper.database;
    await DefinitionDao.updateExerciseDefinition(db, def);
  }

/// Deletes a definition and cascades its joins.
  Future<void> deleteExerciseDefinition(int defId) async {
    final db = await _dbHelper.database;
    await DefinitionDao.deleteExerciseDefinition(db, defId);
  }

/// Performs case-insensitive name search on definitions.
  Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) async {
    final db   = await _dbHelper.database;
    return DefinitionDao.searchExerciseDefinitions(db, query);
  }


  // ─── MEASUREMENTS & LOOKUPS ────────────────────────────

/// Fetches all measurement definitions.
  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementDefinitions(db);
  }

// Retrieves definition ID for a given name, or null if not exists.
  Future<int?> fetchMeasurementDefinitionId(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementDefinitionId(db, name);
  }

/// Inserts a new measurement record.
  Future<int> insertMeasurement(
    int defId,
    DateTime timestamp,
    double value,
    String unit,
    String? note,
  ) async {
    final db = await _dbHelper.database;
    return LookupDao.insertMeasurement(db, defId, timestamp, value, unit, note);
  }

  /// Fetches measurements for a definition as raw maps.
  Future<List<Map<String, dynamic>>> fetchMeasurementsForDefinition(int defId) async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementsForDefinition(db, defId);
  }

/// Fetches all measurements for a definition and maps to [Measurement] models.
  Future<List<Measurement>> fetchClassMeasurementsForDefinition(int defId) async {
    final db = await _dbHelper.database;
    final rows = await LookupDao.getMeasurementsForDefinition(db, defId);
    return rows.map((r) => Measurement(
      id:        r['id'] as int,
      defId:     r['def_id'] as int,
      timestamp: DateTime.parse(r['timestamp'] as String),
      value:     (r['value'] as num).toDouble(),
      unit:      r['unit'] as String,
      note:      r['note'] as String?,
    )).toList();
  }


/// Retrieves only those measurement definitions that have at least one recorded entry.
///
/// Delegates to [LookupDao.getUsedMeasurementDefinitions], which performs a JOIN
/// between `measurement_definitions` and `measurements` and returns:
///   • `id`
///   • `name`
///   • `type`
///
/// - Returns: A list of maps, each containing the `id`, `name`, and `type` of
///   a measurement definition that’s been used at least once.
  Future<List<Map<String, dynamic>>> fetchUsedMeasurementDefinitions() async {
    final db = await _dbHelper.database;
    return LookupDao.getUsedMeasurementDefinitions(db);
  }

  /// Retrieve a single measurement as a raw map.
  Future<Map<String, dynamic>?> fetchMeasurementById(int id) async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementById(db, id);
  }

  /// Update an existing measurement.
  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
  }) async {
    final db = await _dbHelper.database;
    await LookupDao.updateMeasurement(
      db: db,
      measurementId: measurementId,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
    );
  }

  /// Delete a measurement by its ID.
  Future<void> deleteMeasurement(int measurementId) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteMeasurement(db, measurementId);
  }

/// Returns definitions with at least one measurement recorded.
Future<List<MeasurementDefinition>> fetchUsedClassMeasurementDefinitions() async {
  final raw = await _dbHelper.getUsedMeasurementDefinitions();
  return raw.map((r) => MeasurementDefinition(
    id:   r['id']   as int,
    name: r['name'] as String,
    type: MeasurementType.values.firstWhere(
      (mt) => mt.name == (r['type'] as String),
    ),
  )).toList();
}

 /// Fetches all equipment names.
  Future<List<String>> fetchAllEquipmentNames() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllEquipmentNames(db);
  }

/// Fetches all body parts as [BodyPart] models.
  Future<List<BodyPart>> fetchAllBodyParts() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllBodyParts(db);
  }

  /// Fetch all muscles as full models (id + name).
  /// /// Fetches all muscles as [Muscle] models.
  Future<List<Muscle>> fetchAllMuscles() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscles(db);
  }

/// Fetches all muscle names.
  Future<List<String>> fetchAllMuscleNames() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscleNames(db);
  }

/// Fetches stretch definitions, optionally filtered by body part ID.
  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) async {
    final db = await _dbHelper.database;
    return LookupDao.getStretches(db, bodypartId);
  }

/// Fetches a stretch definition's name by ID.
  Future<String?> fetchStretchDefinitionNameById(int stretchId) async {
    final db = await _dbHelper.database;
    return LookupDao.getStretchDefinitionNameById(db, stretchId);
  }



  /// Returns all sessions as WorkoutSession objects, sorted by date desc.
  Future<List<WorkoutSession>> fetchWorkoutSessions() async {
    final raw = await fetchAllSessions(); // List<Map<String,dynamic>>
    return raw.map((row) {
      return WorkoutSession(
        id:       row['id'] as int,
        date:     DateTime.parse(row['date'] as String),
        duration: row['duration'] as int,
      );
    }).toList();
  }


/// Fetches exercise definitions with optional filters.
  Future<List<ExerciseDefinition>> fetchExerciseDefinitionsFiltered({
    List<String>? equipmentNames,
    List<int>?    bodypartIds,
    List<int>?    muscleIds,
  }) {
    return _dbHelper.getExerciseDefinitionsFiltered(
      equipmentNames: equipmentNames,
      bodypartIds:    bodypartIds,
      muscleIds:      muscleIds,
    );
  }

/// Retrieves all equipment entries as [Equipment] models.
  Future<List<Equipment>> fetchAllEquipment() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllEquipment(db);
  }

/// Creates a new equipment entry with the given [name].
  ///
  /// Returns the newly inserted equipment’s row ID.
  Future<int> createEquipment(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertEquipment(db, name);
  }

  /// Updates the equipment entry identified by [id] to have the new [name].
  ///
  /// Completes when the update has been applied.
  Future<void> updateEquipment(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateEquipment(db, id, name);
  }

  /// Deletes the equipment entry identified by [id].
  ///
  /// Any relationships in join tables will cascade if foreign keys are enabled.
  Future<void> deleteEquipment(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteEquipment(db, id);
  }

 /// Retrieves all body‐part entries as [BodyPart] models
  Future<List<BodyPart>> fetchAllBodyPartsFull() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllBodyParts(db);
  }

  /// Creates a new body‐part entry with the given [name].
  ///
  /// Returns the newly inserted body‐part’s row ID.
  Future<int> createBodyPart(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertBodyPart(db, name);
  }

  /// Updates the body‐part entry identified by [id] to have the new [name].
  Future<void> updateBodyPartEntry(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateBodyPart(db, id, name);
  }

  /// Deletes the body‐part entry identified by [id].
  Future<void> deleteBodyPartEntry(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteBodyPart(db, id);
  }

/// Retrieves all muscle entries as [Muscle] models.
  Future<List<Muscle>> fetchAllMusclesFull() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscles(db);
  }

  /// Creates a new muscle entry with the given [name].
  ///
  /// Returns the newly inserted muscle’s row ID.
  Future<int> createMuscle(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertMuscle(db, name);
  }

  /// Updates the muscle entry identified by [id] to have the new [name].
  Future<void> updateMuscleEntry(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateMuscle(db, id, name);
  }

  /// Deletes the muscle entry identified by [id].
  Future<void> deleteMuscleEntry(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteMuscle(db, id);
  }

  /// Re-runs JSON-based seeding for lookup tables and stretches.
  Future<void> reseedLookupData() async {
    await _dbHelper.reseedLookupData();
  }

/// Exports the entire database to a JSON string for backup.
  Future<String> exportDatabase() async {
    return _dbHelper.exportDatabase();
  }

  /// Imports the database from a JSON string.
  ///
  /// If [clearFirst] is true, existing rows are deleted before import.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    await _dbHelper.importDatabase(jsonStr, clearFirst: clearFirst);
  }

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) async {
    final db = await _dbHelper.database;
    return DefinitionDao.fuzzsearchExerciseDefinitions(db, term);
  }


}
