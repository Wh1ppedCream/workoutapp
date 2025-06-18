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

}
