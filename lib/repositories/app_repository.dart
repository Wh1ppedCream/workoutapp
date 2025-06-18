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

/// A single entrypoint for all SQLite operations in your UI code.
/// Under the hood it delegates to your DAOs, but screens/widgets
/// never import DatabaseHelper or run raw SQL.
class AppRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _db = DatabaseHelper();

  // ─── SESSIONS ───────────────────────────────────────────

  Future<int> createSession(String date, int duration) async {
    final db = await _dbHelper.database;
    return SessionDao.insertSession(db, date, duration);
  }

  Future<List<Map<String, dynamic>>> fetchAllSessions() async {
    final db = await _dbHelper.database;
    return SessionDao.getAllSessionsRaw(db);
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    return SessionDao.deleteSession(db, sessionId);
  }

/// Fetch a single session by ID, or null if missing.
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

  /// Fetches sessions between [start] and [end].
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

  Future<int> addExercise(
    int sessionId,
    String name,
    String equipmentName,
    int orderIndex,
  ) async {
    final db = await _dbHelper.database;
    return ExerciseDao.insertExercise(db, sessionId, name, equipmentName, orderIndex);
  }

  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async {
    final db = await _dbHelper.database;
    return ExerciseDao.getExercisesForSession(db, sessionId);
  }

  Future<void> deleteExercises(int sessionId) async {
    final db = await _dbHelper.database;
    return ExerciseDao.deleteExercisesForSession(db, sessionId);
  }

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


Future<WorkoutExercise?> fetchDetailedExercise(int id) {
    return _db.fetchDetailedExercise(id);
  }
  Future<void> deleteExercise(int id) {
    return _db.deleteExercise(id); // or use ExerciseDao.deleteExerciseById under the hood
  }

  // ─── SETS ───────────────────────────────────────────────

  Future<int> addSet(
    int exerciseId,
    double weight,
    int reps,
    int orderIndex,
  ) async {
    final db = await _dbHelper.database;
    return SetDao.insertSet(db, exerciseId, weight, reps, orderIndex);
  }

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

  /// Reorder a list of sets (by IDs) within an exercise.
  Future<void> reorderSets(int exerciseId, List<int> setIds) async {
    final db = await _dbHelper.database;
    await SetDao.reorderSets(db, exerciseId, setIds);
  }


  // ─── CARDIO ────────────────────────────────────────────

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

  Future<List<Map<String, dynamic>>> fetchStretchItems(int exerciseId) async {
    final db = await _dbHelper.database;
    return StretchDao.getStretchItemsForExercise(db, exerciseId);
  }

/// Update fields on one stretch‐instance item.
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

  /// Delete one stretch instance item.
  Future<void> deleteStretchItem(int itemId) async {
    final db = await _dbHelper.database;
    await StretchDao.deleteStretchItem(db, itemId);
  }

  /// Delete an entire stretch instance and its items.
  Future<void> deleteStretchInstance(int exerciseId) async {
    final db = await _dbHelper.database;
    await StretchDao.deleteStretchInstance(db, exerciseId);
  }

  /// Reorder the items of a stretch instance.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) async {
    final db = await _dbHelper.database;
    await StretchDao.reorderStretchItems(db, exerciseId, itemIds);
  }

  // ─── DEFINITIONS & FILTERS ─────────────────────────────

  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(int bodyPartId) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
  }

  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    final db = await _dbHelper.database;
    return DefinitionDao.getAllExerciseDefinitionsDetailed(db);
  }

  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() async {
    final db = await _dbHelper.database;
    return DefinitionDao.getAllExercisesRaw(db);
  }

  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(List<String> equipmentNames) async {
    final db = await _dbHelper.database;
    return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
  }

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

  /// Finds (or creates) an ExerciseDefinition via DefinitionDao.
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

  /// Delete a definition and its joins.
  Future<void> deleteExerciseDefinition(int defId) async {
    final db = await _dbHelper.database;
    await DefinitionDao.deleteExerciseDefinition(db, defId);
  }

  /// Search for definitions whose name contains [query].
  Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) async {
    final db   = await _dbHelper.database;
    return DefinitionDao.searchExerciseDefinitions(db, query);
  }


  // ─── MEASUREMENTS & LOOKUPS ────────────────────────────

  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementDefinitions(db);
  }

  /// Returns the ID of the measurement definition with [name], or null.
  Future<int?> fetchMeasurementDefinitionId(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementDefinitionId(db, name);
  }

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

  Future<List<Map<String, dynamic>>> fetchMeasurementsForDefinition(int defId) async {
    final db = await _dbHelper.database;
    return LookupDao.getMeasurementsForDefinition(db, defId);
  }

  /// Fetches all recorded measurements for the given definition ID,
  /// mapped into your domain model.
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


  Future<List<String>> fetchAllEquipmentNames() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllEquipmentNames(db);
  }

  Future<List<BodyPart>> fetchAllBodyParts() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllBodyParts(db);
  }

  /// Fetch all muscles as full models (id + name).
  Future<List<Muscle>> fetchAllMuscles() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscles(db);
  }

  Future<List<String>> fetchAllMuscleNames() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscleNames(db);
  }

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

// Equipment
  Future<List<Equipment>> fetchAllEquipment() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllEquipment(db);
  }
  Future<int> createEquipment(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertEquipment(db, name);
  }
  Future<void> updateEquipment(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateEquipment(db, id, name);
  }
  Future<void> deleteEquipment(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteEquipment(db, id);
  }

  // BodyPart
  Future<List<BodyPart>> fetchAllBodyPartsFull() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllBodyParts(db);
  }
  Future<int> createBodyPart(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertBodyPart(db, name);
  }
  Future<void> updateBodyPartEntry(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateBodyPart(db, id, name);
  }
  Future<void> deleteBodyPartEntry(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteBodyPart(db, id);
  }

  // Muscle
  Future<List<Muscle>> fetchAllMusclesFull() async {
    final db = await _dbHelper.database;
    return LookupDao.getAllMuscles(db);
  }
  Future<int> createMuscle(String name) async {
    final db = await _dbHelper.database;
    return LookupDao.insertMuscle(db, name);
  }
  Future<void> updateMuscleEntry(int id, String name) async {
    final db = await _dbHelper.database;
    await LookupDao.updateMuscle(db, id, name);
  }
  Future<void> deleteMuscleEntry(int id) async {
    final db = await _dbHelper.database;
    await LookupDao.deleteMuscle(db, id);
  }

  // Reseed lookups from JSON
  Future<void> reseedLookupData() async {
    await _dbHelper.reseedLookupData();
  }

/// Export full DB as JSON.
  Future<String> exportDatabase() async {
    return _dbHelper.exportDatabase();
  }

  /// Import full DB from JSON.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    await _dbHelper.importDatabase(jsonStr, clearFirst: clearFirst);
  }

  /// Search exercises by name substring.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) async {
    final db = await _dbHelper.database;
    return DefinitionDao.fuzzsearchExerciseDefinitions(db, term);
  }


}
