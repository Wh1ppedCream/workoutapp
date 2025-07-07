// File: lib/db/database_helper.dart

import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'schema.dart';
import 'seed.dart';
import 'session_dao.dart';
import 'exercise_dao.dart';
import 'set_dao.dart';
import 'cardio_dao.dart';
import 'stretch_dao.dart';
import 'definition_dao.dart';
import 'lookup_dao.dart';
import 'stats_dao.dart';
import 'analytics_dao.dart';
import 'formula_settings_dao.dart';
import '../db/gym_profile_dao.dart';
import '../db/preset_definition_dao.dart';
import '../db/preset_exercise_dao.dart';
import '../db/preset_detail_dao.dart';
import '../db/preset_auto_settings_dao.dart';
import '../db/preset_exercise_auto_dao.dart';
import '../db/preset_set_auto_dao.dart';
import '../db/preset_flow_methods_dao.dart';





/// Singleton helper for managing the SQLite database.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 13,  
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 3) {
      await Schema.migrateV3(db);
      await Seed.seedLookupsAndExercises(db);
    }
    if (oldVersion < 4) {
      await Schema.migrateV4(db);
      await Seed.seedStretches(db);
    }
    if (oldVersion < 5) {
      await Schema.migrateV5(db);
    }
   if (oldVersion < 6) {
     await Schema.migrateV6(db);
   }
   // v7: gym_profiles + profile_equipment + preset_definitions.profile_id
        if (oldVersion < 7) {
          await Schema.migrateV7(db);
          await db.execute('CREATE INDEX IF NOT EXISTS idx_preset_profile ON preset_definitions(profile_id);');
        }

    if (oldVersion < 8) {
     await Schema.migrateV8(db);
   }

   if (oldVersion < 9) {
  await Schema.migrateV9(db);
  await Seed.seedAnalyticsDefaults(db);
}
if (oldVersion < 10) {
        await Schema.migrateV10(db);
      }
  if (oldVersion < 11) {
      await Schema.migrateV11(db);
    }
if (oldVersion < 12) {
      await Schema.migrateV12(db);
    }
    if (oldVersion < 13) {
      await Schema.migrateV13(db);
    }
  },
);
  }

  /// Builds initial schema and seeds all data.
  Future<void> _onCreate(Database db, int version) async {
    // Create schema v1 + migrations v3–v9
    await Schema.createTables(db);
    // Seed lookup and exercise definitions
    await Seed.seedLookupsAndExercises(db);
    // Seed stretches
    await Seed.seedStretches(db);
    // Seed analytics defaults
    await Seed.seedAnalyticsDefaults(db);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CRUD METHODS
  // ────────────────────────────────────────────────────────────────────────────

//session_dao

Future<int> createSession(String date, int duration) async {
  final db = await database;
  return SessionDao.insertSession(db, date, duration);
}

Future<List<Map<String, dynamic>>> getAllSessionsRaw() async {
  final db = await database;
  return SessionDao.getAllSessionsRaw(db);
}

Future<void> deleteSession(int sid) async {
  final db = await database;
  return SessionDao.deleteSession(db, sid);
}


Future<WorkoutSession?> fetchSessionById(int sessionId) async {
  final db = await database;
  final row = await SessionDao.getSessionById(db, sessionId);
  if (row == null) return null;
  return WorkoutSession(
      id:       row['id']       as int,
      date:     DateTime.parse(row['date'] as String),
      duration: row['duration'] as int,
    );
}

Future<void> updateSession(int id, DateTime newDate, int newDuration) async {
  final db = await database;
  await SessionDao.updateSession(
    db,
    id,
    newDate.toIso8601String(),
    newDuration,
  );
}

// Fetch range + map
Future<List<WorkoutSession>> fetchSessionsInRange(
    DateTime start, DateTime end) async {
  final db = await database;
  final rows = await SessionDao.getSessionsInRange(
    db, start.toIso8601String(), end.toIso8601String());
  return rows.map((row) => WorkoutSession(
      id:       row['id']       as int,
      date:     DateTime.parse(row['date'] as String),
      duration: row['duration'] as int,
    )).toList();
}




//exercise_dao

Future<int> addExercise(int sessionId, String name, String equipment, int idx) async {
  final db = await database;
  return ExerciseDao.insertExercise(db, sessionId, name, equipment, idx);
}

Future<List<Map<String,dynamic>>> fetchExercisesRaw(int sessionId) async {
  final db = await database;
  return ExerciseDao.getExercisesForSession(db, sessionId);
}

  Future<void> deleteExercises(int sessionId) async {
  final db = await database;
  await ExerciseDao.deleteExercisesForSession(db, sessionId);
}

  Future<int> addExerciseRow({
    int?    exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
  }) async {
    final db = await database;
    return ExerciseDao.insertExerciseRow(
      db: db,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
      sessionId: sessionId,
    );
  }

 /// Fetches a fully-detailed WorkoutExercise (Weight/Cardio/Stretch).
Future<WorkoutExercise?> fetchDetailedExercise(int exerciseId) async {
  final db = await database;

  // 1) Base row
  final exRow = await ExerciseDao.getExerciseById(db, exerciseId);
  if (exRow == null) return null;
  final type = exRow['type'] as String;

  if (type == 'weight') {
    // — definition info (name+equipment)
    final defInfo = await DefinitionDao.getDefinitionInfo(db, exRow['exercise_def_id'] as int);

    // — sets & changeSets
    final parentRows = await db.query(
      'sets',
      where: 'exercise_id = ? AND parent_set_id IS NULL',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
    final sets = <ExerciseSet>[];
    final changeSets = <int, List<ExerciseSet>>{};
    final completedParents = <int>{};
    final completedChildren = <int, Set<int>>{};

    for (var i = 0; i < parentRows.length; i++) {
      final p = parentRows[i];
      sets.add(ExerciseSet(weight: (p['weight'] as num).toDouble(), reps: p['reps'] as int));
      completedParents.add(i);

      final children = await db.query(
        'sets',
        where: 'parent_set_id = ?',
        whereArgs: [p['id']],
        orderBy: 'order_index',
      );
      if (children.isNotEmpty) {
        changeSets[i] = children.map((c) => ExerciseSet(
          weight: (c['weight'] as num).toDouble(),
          reps:   c['reps']   as int,
        )).toList();
        completedChildren[i] = Set.from(List.generate(children.length, (j) => j));
      }
    }

    return WeightExercise(
      name:              defInfo['name']!,
      equipment:         defInfo['equipmentName'] ?? '',
      sets:              sets,
      changeSets:        changeSets,
      completedParents:  completedParents,
      completedChildren: completedChildren,
    );
  }

  if (type == 'cardio') {
    final c = await getCardioDetailsForExercise(exerciseId);
    if (c == null) return null;
    return CardioExercise(
      name:           c['cardio_name']    as String,
      equipment:      '',
      cardioName:     c['cardio_name']    as String,
      cardioNote:     c['note']           as String?,
      plannedMinutes: (c['planned_minutes'] as num).toInt(),
      elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
    );
  }

  if (type == 'stretch') {
    final items = await getStretchItemsForExercise(exerciseId);
      // Decode rows into our StretchInstance models
   final insts = items
       .map((r) => StretchInstance.fromMap(r))
       .toList();
   // Track which indices were checked
   final completed = <int>{};
   for (var i = 0; i < insts.length; i++) {
     if (insts[i].isChecked) completed.add(i);
   }
    // determine header name…
    String hdr = 'Stretch';
       if (insts.isNotEmpty && insts.first.stretchId != null) {
     final sd = await DefinitionDao.getDefinitionInfo(db, insts.first.stretchId!);
      hdr = sd['name']!;
    }
    return StretchExercise(
      name:                    hdr,
      equipment:               '',
      stretchInstances:        insts,
      completedStretchIndices: completed,
    );
  }

  return null;
}

/// Deletes a single exercise (and all its child rows) by ID.
Future<void> deleteExercise(int exerciseId) async {
  final db = await database;
  // Delegate to the DAO
  await ExerciseDao.deleteExerciseById(db, exerciseId);
}

 // set_dao.dart

  /// Inserts a set belonging to an exercise instance.
  Future<int> addSet(int exerciseId, double weight, int reps, int orderIndex) async {
  final db = await database;
  return SetDao.insertSet(db, exerciseId, weight, reps, orderIndex);
}

  /// Given a parentSets list and childChangeSets map, insert into sets.
  /// parentSets is List < ExerciseSet >  where each is a top-level set.
  /// childChangeSets is a Map < parentIndex, List < ExerciseSet>>.
  Future<void> addWeightSets({
  required int exerciseId,
  required List<ExerciseSet> parentSets,
  required Map<int,List<ExerciseSet>> childChangeSets,
}) async {
  final db = await database;
  await SetDao.insertWeightSets(
    db: db,
    exerciseId: exerciseId,
    parentSets: parentSets,
    childChangeSets: childChangeSets,
  );
}

   // Fetch raw set-rows.
Future<List<Map<String,dynamic>>> fetchSetsRaw(int exerciseId) async {
  final db = await database;
  return SetDao.getSetsForExercise(db, exerciseId);
}

 // Update a single set.
Future<void> updateSet(int setId, double weight, int reps) async {
  final db = await database;
  await SetDao.updateSet(db, setId, weight, reps);
}

// Delete a single set.
Future<void> deleteSet(int setId) async {
  final db = await database;
  await SetDao.deleteSet(db, setId);
}

// Reorder sets.
Future<void> reorderSets(int exerciseId, List<int> setIds) async {
  final db = await database;
  await SetDao.reorderSets(db, exerciseId, setIds);
}


  
  //cardio_dao.dart
  
  /// After you create a cardio exercise row (type='cardio'), call:
 Future<void> saveCardioDetails({
  required int exerciseId,
  required String cardioName,
  String? note,
  required int plannedMinutes,
  required int elapsedSeconds,
}) async {
  final db = await database;
  await CardioDao.insertCardioDetails(
    db: db,
    exerciseId: exerciseId,
    cardioName: cardioName,
    note: note,
    plannedMinutes: plannedMinutes,
    elapsedSeconds: elapsedSeconds,
  );
}
  
 /// Fetch cardio_details for a session.
 Future<Map<String, dynamic>?> getCardioDetailsForExercise(int eid) async {
   final db = await database;
   return CardioDao.getCardioDetailsForExercise(db, eid);
 }

// Fetch raw cardio map.
Future<Map<String,dynamic>?> fetchCardioDetails(int exerciseId) async {
  final db = await database;
  return CardioDao.getCardioDetailsForExercise(db, exerciseId);
}

// Update cardio details.
Future<void> updateCardioDetails({
  required int exerciseId,
  required String cardioName,
  String? note,
  required int plannedMinutes,
  required int elapsedSeconds,
}) async {
  final db = await database;
  await CardioDao.updateCardioDetails(
    db: db,
    exerciseId: exerciseId,
    cardioName: cardioName,
    note: note,
    plannedMinutes: plannedMinutes,
    elapsedSeconds: elapsedSeconds,
  );
}

// Delete cardio details.
Future<void> deleteCardioDetails(int exerciseId) async {
  final db = await database;
  await CardioDao.deleteCardioDetails(db, exerciseId);
}

//stretch_dao.dart

  /// After you create a stretch-type exercise row, call:
  /// Inserts one stretch-type exercise’s “instance” and all of its items.
  /// uses class StretchInstance.
Future<void> saveClassStretchInstance({
  required int exerciseId,
  required List<StretchInstance> instances,
}) async {
  final db = await database;
  await StretchDao.insertStretchInstance(
    db: db,
    exerciseId: exerciseId,
    items: instances,
  );
}

Future<void> saveStretchInstance({
  required int exerciseId,
  required List<Map<String, dynamic>> items,
}) async {
  final db = await database;
  final instances = items.map((m) => StretchInstance.fromMap(m)).toList();
  await StretchDao.insertStretchInstance(
    db: db,
    exerciseId: exerciseId,
    items: instances,
  );
}

  /// Fetch all items in a stretch instance for a given exercise.
Future<List<Map<String, dynamic>>> getStretchItemsForExercise(int eid) async {
  final db = await database;
  // DAO now returns List<StretchInstance>
  final instances = await StretchDao.getStretchItemsForExercise(db, eid);
  // convert back to the old map format so callers see the same type
  return instances.map((inst) => inst.toMap()).toList();
}

// Fetch raw stretch-item maps.
Future<List<Map<String,dynamic>>> fetchStretchItemsRaw(int exerciseId) async {
  final db = await database;
  final insts = await StretchDao.getStretchItemsForExercise(db, exerciseId);
  return insts.map((i) => i.toMap()).toList();
}


// Update one stretch item.
Future<int> updateStretchItem({
  required int itemId,
  int? stretchId,
  bool? isCustom,
  String? customName,
  String? customDesc,
  bool? isChecked,
  int? orderIndex,
}) async {
  final db = await database;
  return StretchDao.updateStretchItem(
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

// Delete a stretch item.
Future<void> deleteStretchItem(int itemId) async {
  final db = await database;
  await StretchDao.deleteStretchItem(db, itemId);
}

// Delete whole stretch instance.
Future<void> deleteStretchInstance(int exerciseId) async {
  final db = await database;
  await StretchDao.deleteStretchInstance(db, exerciseId);
}

// Reorder stretch items.
Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) async {
  final db = await database;
  await StretchDao.reorderStretchItems(db, exerciseId, itemIds);
}


//definition_dao.dart

  /// Fetch exercise definitions by bodyPart ID.
  Future<List<Map<String,dynamic>>> lookupDefsByBodyPart(int bodyPartId) async {
  final db = await database;
  return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
}

  /// Fetch every definition with its full equipmentList, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
  final db = await database;
  return DefinitionDao.getAllExerciseDefinitionsDetailed(db);
}

/// Fetch all exercise definitions (shallow, without join lists).
Future<List<Map<String,dynamic>>> fetchAllExercisesRaw() async {
  final db = await database;
  return DefinitionDao.getAllExercisesRaw(db);
}

 /// Fetch all exercises whose equipment is *at least one* of [equipmentNames].
 Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(List<String> equipmentNames) async {
  final db = await database;
  return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
}

  /// Fetch all exercises whose equipment is *only* drawn from [equipmentNames].
  ///
  /// Because each definition has a single equipment_id, this currently
  /// returns those whose equipment_id ∈ list, or NULL if you consider
  /// “bodyweight/no equipment” as allowed.
 Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
  List<String> equipmentNames, {
  bool includeNone = true,
}) async {
  final db = await database;
  return DefinitionDao.getExerciseDefsOnlyWithEquipment(
    db,
    equipmentNames,
    includeNone: includeNone,
  );
}

/// Fetch exercise definitions, optionally filtering by:
  ///  – equipmentNames: list of equipment.name
  ///  – bodypartIds:    list of bodypart.id
  ///  – muscleIds:      list of muscle.id
  ///
  /// Each non-null filter list requires the definition to be associated
  /// with *at least one* entry in that list. All supplied filters are ANDed.
Future<List<ExerciseDefinition>> lookupDefsFiltered({
  List<String>? equipmentNames,
  List<int>?    bodypartIds,
  List<int>?    muscleIds,
}) async {
  final db = await database;
  return DefinitionDao.getExerciseDefinitionsFiltered(
    db,
    equipmentNames: equipmentNames,
    bodypartIds: bodypartIds,
    muscleIds: muscleIds,
  );
}

Future<int> findOrCreateExerciseDefinition(String name, String equipmentName) async {
  final db = await database;
  return DefinitionDao.findOrCreateExerciseDefinition(
    db,
    name,
    equipmentName,
  );
}

Future<Map<String, String?>> fetchDefinitionInfo(int defId) async {
  final db = await database;
  return DefinitionDao.getDefinitionInfo(db, defId);
}

Future<void> updateExerciseDefinition(ExerciseDefinition def) async {
  final db = await database;
  await DefinitionDao.updateExerciseDefinition(db, def);
}

Future<void> deleteExerciseDefinition(int defId) async {
  final db = await database;
  await DefinitionDao.deleteExerciseDefinition(db, defId);
}

Future<List<ExerciseDefinition>> searchExerciseDefinitions(String query) async {
  final db = await database;
  return DefinitionDao.searchExerciseDefinitions(db, query);
}

/// Fetch a single detailed ExerciseDefinition by its ID.
Future<ExerciseDefinition?> getExerciseDefinitionById(int defId) async {
  final db = await database;
  return DefinitionDao.getExerciseDefinitionById(db, defId);
}


/// Fetches catalog definitions with optional profile & filters.
Future<List<ExerciseDefinition>> fetchCatalogDefinitions({
  required bool useProfileFilter,
  int? profileId,
  String? equipmentFilter,
  List<int>? bodypartIds,
  List<int>? muscleIds,
}) async {
  // 1) Base equipment names from profile
  List<String>? eqNames;
  if (useProfileFilter && profileId != null) {
    final eqMaps = await fetchEquipmentForProfile(profileId);
    eqNames = eqMaps.map((e) => e['name'] as String).toList();
  }
  // 2) Override by single filter
  if (equipmentFilter != null) {
    eqNames = [equipmentFilter];
  }

  // 3) Get defs
  List<ExerciseDefinition> defs;
  if (eqNames != null && eqNames.isNotEmpty) {
    defs = await lookupDefsOnlyWithEquipment(eqNames);
  } else {
    defs = await lookupDefsFiltered(
      equipmentNames: eqNames,
      bodypartIds: bodypartIds,
      muscleIds: muscleIds,
    );
  }

  // 4) Post‐filter by body/muscle
  if (eqNames != null && eqNames.isNotEmpty) {
    defs = defs.where((d) {
      final areaOk = bodypartIds == null ||
          bodypartIds.any((id) => d.bodyParts.any((bp) => bp.id == id));
      final muscleOk = muscleIds == null ||
          muscleIds.any((id) =>
              d.muscles.any((rm) => rm.muscle.id == id));
      return areaOk && muscleOk;
    }).toList();
  }

  return defs;
}

//lookup_dao.dart
  
  /// Fetch all measurement definitions.
Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async {
  final db = await database;
  return LookupDao.getMeasurementDefinitions(db);
}

Future<int?> fetchMeasurementDefinitionId(String name) async {
  final db = await database;
  return LookupDao.getMeasurementDefinitionId(db, name);
}


  /// Insert a new measurement instance.
Future<int> insertMeasurement(  int defId,  DateTime timestamp,  double value,  String unit,  String? note,
) async {
  final db = await database;
  return LookupDao.insertMeasurement(db, defId, timestamp, value, unit, note);
}

/// Fetch all measurements for a definition.
 Future<List<Map<String, dynamic>>> fetchMeasurementsRaw(int defId) async {
  final db = await database;
  return LookupDao.getMeasurementsForDefinition(db, defId);
}

Future<List<Measurement>> fetchClassMeasurementsForDefinition(int defId) async {
  final rows = await fetchMeasurementsRaw(defId);
  return rows.map((r) => Measurement(
      id:        r['id'] as int,
      defId:     r['def_id'] as int,
      timestamp: DateTime.parse(r['timestamp'] as String),
      value:     (r['value'] as num).toDouble(),
      unit:      r['unit'] as String,
      note:      r['note'] as String?,
    )).toList();
}

  /// Returns only the definitions that have at least one measurement recorded.
 Future<List<Map<String, dynamic>>> fetchUsedMeasurementDefinitionsRaw() async {
  final db = await database;
  return LookupDao.getUsedMeasurementDefinitions(db);
}

Future<List<MeasurementDefinition>> fetchUsedClassMeasurementDefinitions() async {
  final raw = await fetchUsedMeasurementDefinitionsRaw();
  return raw.map((r) => MeasurementDefinition(
    id:   r['id']   as int,
    name: r['name'] as String,
    type: MeasurementType.values.firstWhere((mt) => mt.name == (r['type'] as String)),
  )).toList();
}

Future<Map<String, dynamic>?> fetchMeasurementById(int id) async {
  final db = await database;
  return LookupDao.getMeasurementById(db, id);
}

Future<void> updateMeasurement({
  required int measurementId,
  required DateTime timestamp,
  required double value,
  required String unit,
  String? note,
}) async {
  final db = await database;
  await LookupDao.updateMeasurement(
    db: db,
    measurementId: measurementId,
    timestamp: timestamp,
    value: value,
    unit: unit,
    note: note,
  );
}

Future<void> deleteMeasurement(int measurementId) async {
  final db = await database;
  await LookupDao.deleteMeasurement(db, measurementId);
}

  /// Fetch all equipment names.
Future<List<String>> fetchAllEquipmentNames() async {
  final db = await database;
  return LookupDao.getAllEquipmentNames(db);
}

  /// Fetch all body-part IDs and names.
Future<List<BodyPart>> fetchAllBodyParts() async {
  final db = await database;
  return LookupDao.getAllBodyParts(db);
}

  /// Fetch all muscle names.
Future<List<Muscle>> fetchAllMuscles() async {
  final db = await database;
  return LookupDao.getAllMuscles(db);
}

Future<List<String>> fetchAllMuscleNames() async {
  final db = await database;
  return LookupDao.getAllMuscleNames(db);
}

  /// Fetch stretches by an optional bodypart ID (or all if null).
Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) async {
  final db = await database;
  return LookupDao.getStretches(db, bodypartId);
}

Future<String?> fetchStretchDefinitionNameById(int stretchId) async {
  final db = await database;
  return LookupDao.getStretchDefinitionNameById(db, stretchId);
}

Future<List<Equipment>> fetchAllEquipment() async {
  final db = await database;
  return LookupDao.getAllEquipment(db);
}

Future<int> createEquipment(String name) async {
  final db = await database;
  return LookupDao.insertEquipment(db, name);
}

Future<void> updateEquipment(int id, String name) async {
  final db = await database;
  await LookupDao.updateEquipment(db, id, name);
}

Future<void> deleteEquipment(int id) async {
  final db = await database;
  await LookupDao.deleteEquipment(db, id);
}

Future<List<BodyPart>> fetchAllBodyPartsFull() async {
  final db = await database;
  return LookupDao.getAllBodyParts(db);
}

Future<int> createBodyPart(String name) async {
  final db = await database;
  return LookupDao.insertBodyPart(db, name);
}

Future<void> updateBodyPartEntry(int id, String name) async {
  final db = await database;
  await LookupDao.updateBodyPart(db, id, name);
}

Future<void> deleteBodyPartEntry(int id) async {
  final db = await database;
  await LookupDao.deleteBodyPart(db, id);
}

Future<List<Muscle>> fetchAllMusclesFull() async {
  final db = await database;
  return LookupDao.getAllMuscles(db);
}

Future<int> createMuscle(String name) async {
  final db = await database;
  return LookupDao.insertMuscle(db, name);
}

Future<void> updateMuscleEntry(int id, String name) async {
  final db = await database;
  await LookupDao.updateMuscle(db, id, name);
}

Future<void> deleteMuscleEntry(int id) async {
  final db = await database;
  await LookupDao.deleteMuscle(db, id);
}

/// Rerun JSON-seeding for lookup tables & stretches.
Future<void> reseedLookupData() async {
  final db = await database;
  await Seed.seedLookupsAndExercises(db);
  await Seed.seedStretches(db);
}

/// Export the entire database to a JSON string.
  Future<String> exportDatabase() async {
    final db = await database;
    final tables = [
      'sessions',
      'exercises',
      'sets',
      'cardio_details',
      'stretch_instances',
      'stretch_instance_items',
      'measurement_definitions',
      'measurements',
      'equipment',
      'bodypart',
      'muscles',
      'exercise_definitions',
      'exercise_equipment',
      'exercise_bodypart',
      'exercise_muscle',
      'stretch_definitions',
      'stretch_bodypart',
      'muscle_bodypart',
      'bodypart_ranking',
      'muscle_ranking',
      'exercise_muscle_percent',
      'bodypart_muscle_rankings',
      'muscle_volume_boundaries',
      'bodypart_volume_boundaries',
      'preset_definitions',
      'preset_exercises',
      'preset_sets',
      'preset_cardio_details',
      'preset_stretch_items',
      'gym_profiles',
      'profile_equipment',
      'exercise_rep_max',
      'exercise_volume_max',
    ];
    final Map<String, dynamic> data = {};
    for (final table in tables) {
      data[table] = await db.query(table);
    }
    return jsonEncode(data);
  }

  /// Import the database from a JSON string.
  /// If [clearFirst] is true, all existing rows are deleted before import.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    final db = await database;
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF;');
      if (clearFirst) {
        for (final table in data.keys) {
          await txn.delete(table);
        }
     }
      for (final table in data.keys) {
        final rows = List<Map<String, dynamic>>.from(data[table] as List);
        for (final row in rows) {
          await txn.insert(table, row);
        }
      }
      await txn.execute('PRAGMA foreign_keys = ON;');
    });
  }

/// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) async {
    final db = await database;
    return DefinitionDao.fuzzsearchExerciseDefinitions(db, term);
  }


// stats_dao.dart methods:

/// Upsert a rep-max stat row.
Future<void> upsertRepMax(
  int defId,
  int repCount,
  String timeframe,
  double rmValue,
  double oneErm,
  bool isErm,
) async {
  final db = await database;
  return StatsDao.upsertRepMax(db, defId, repCount, timeframe, rmValue, oneErm, isErm);
}

/// Upsert a volume-max stat row.
Future<void> upsertVolumeMax(
  int defId,
  String timeframe,
  double vmValue,
) async {
  final db = await database;
  return StatsDao.upsertVolumeMax(db, defId, timeframe, vmValue);
}

// —————————————— Rep-Max + Volume-Max Queries ——————————————

/// Returns list of rep-max rows for [defId] & [timeframe].
Future<List<Map<String, dynamic>>> getRepMaxes(
  int defId,
  String timeframe,
) async {
  final db = await database;
  return StatsDao.getRepMaxes(db, defId, timeframe);
}

/// Returns the volume-max row (or null) for [defId] & [timeframe].
Future<Map<String, dynamic>?> getVolumeMax(
  int defId,
  String timeframe,
) async {
  final db = await database;
  return StatsDao.getVolumeMax(db, defId, timeframe);
}

Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) async {
  final db = await database;
  double volume = 0;
  for (var sid in sessionIds) {
    final exRows = await ExerciseDao.getExercisesForSession(db, sid);
    for (var ex in exRows.where((e) => e['type']=='weight')) {
      final eid = ex['id'] as int;
      final setRows = await SetDao.getSetsForExercise(db, eid);
      for (var s in setRows) {
        volume += (s['weight'] as num) * (s['reps'] as num);
      }
    }
  }
  return volume;
}


 // ─── Formula Settings ──────────────────────────────────────

  static const _stepKey = 'step';
  static const _minKey  = 'min';
  static const _maxKey  = 'max';

  /// Reads a formula parameter or returns [fallback].
  Future<double> _getFormulaParam(String key, double fallback) async {
    final db = await database;
    final v  = await FormulaSettingsDao.getParam(db, key);
    return v ?? fallback;
  }

  Future<double> getFormulaStep() => _getFormulaParam(_stepKey, 0.05);
  Future<double> getFormulaMin()  => _getFormulaParam(_minKey,  0.0);
  Future<double> getFormulaMax()  => _getFormulaParam(_maxKey,  1.0);

  Future<void> setFormulaStep(double step) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _stepKey, step);
  }
  Future<void> setFormulaMin(double min) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _minKey, min);
  }
  Future<void> setFormulaMax(double max) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _maxKey, max);
  }


// ─── ANALYTICS ─────────────────────────────────────────────

Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) async {
  final db = await database;
  return AnalyticsDao.insertMuscleBodyPart(db, muscleId, bodypartId);
}

Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) async {
  final db = await database;
  return AnalyticsDao.deleteMuscleBodyPart(db, muscleId, bodypartId);
}

Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async {
  final db = await database;
  return AnalyticsDao.getBodyPartsForMuscle(db, muscleId);
}

Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async {
  final db = await database;
  return AnalyticsDao.getMusclesForBodyPart(db, bodypartId);
}

Future<int> setBodyPartRank(int bodypartId, int rank) async {
  final db = await database;
  return AnalyticsDao.setBodyPartRanking(db, bodypartId, rank);
}

Future<BodyPartRanking?> getBodyPartRank(int bodypartId) async {
  final db = await database;
  return AnalyticsDao.getBodyPartRanking(db, bodypartId);
}

Future<List<BodyPartRanking>> getAllBodyPartRanks() async {
  final db = await database;
  return AnalyticsDao.getAllBodyPartRankings(db);
}

Future<int> deleteBodyPartRank(int bodypartId) async {
  final db = await database;
  return AnalyticsDao.deleteBodyPartRanking(db, bodypartId);
}

Future<int> setMuscleRank(int muscleId, int rank) async {
  final db = await database;
  return AnalyticsDao.setMuscleRanking(db, muscleId, rank);
}

Future<MuscleRanking?> getMuscleRank(int muscleId) async {
  final db = await database;
  return AnalyticsDao.getMuscleRanking(db, muscleId);
}

Future<List<MuscleRanking>> getAllMuscleRanks() async {
  final db = await database;
  return AnalyticsDao.getAllMuscleRankings(db);
}

Future<int> deleteMuscleRank(int muscleId) async {
  final db = await database;
  return AnalyticsDao.deleteMuscleRanking(db, muscleId);
}

Future<int> setExerciseMuscleHitPercent(int defId, int muscleId, double pct) async {
  final db = await database;
  return AnalyticsDao.setExerciseMusclePercent(db, defId, muscleId, pct);
}

Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(int defId, int muscleId) async {
  final db = await database;
  return AnalyticsDao.getExerciseMusclePercent(db, defId, muscleId);
}

Future<int> removeExerciseMusclePercent(int defId, int muscleId) async {
  final db = await database;
  return AnalyticsDao.deleteExerciseMusclePercent(db, defId, muscleId);
}

Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(int defId) async {
  final db = await database;
  return AnalyticsDao.getPercentsForExercise(db, defId);
}

Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) async {
  final db = await database;
  return AnalyticsDao.setMuscleVolumeBoundaries(db, muscleId, b);
}

Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async {
  final db = await database;
  return AnalyticsDao.getMuscleVolumeBoundaries(db, muscleId);
}

Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() async {
  final db = await database;
  return AnalyticsDao.getAllMuscleVolumeBoundaries(db);
}

Future<int> removeMuscleVolumeBounds(int muscleId) async {
  final db = await database;
  return AnalyticsDao.deleteMuscleVolumeBoundaries(db, muscleId);
}

Future<int> setBodyPartVolumeBounds(int bodyPartId, VolumeBoundaries bounds) async {
  final db = await database;
  return AnalyticsDao.setBodyPartVolumeBoundaries(db, bodyPartId, bounds);
}

Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async {
  final db = await database;
  return AnalyticsDao.getBodyPartVolumeBoundaries(db, bodyPartId);
}

Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() async {
  final db = await database;
  return AnalyticsDao.getAllBodyPartVolumeBoundaries(db);
}

Future<int> removeBodyPartVolumeBounds(int bodyPartId) async {
  final db = await database;
  return AnalyticsDao.deleteBodyPartVolumeBoundaries(db, bodyPartId);
}

/// Fetches rep‐max rows and maps to model.
Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async {
  final db = await database;
  final raw = await StatsDao.getRepMaxes(db, defId, timeframe);
  return raw.map((r) => RepMaxRow(
    repCount: r['rep_count'] as int,
    rmValue:  (r['rm_value']   as num).toDouble(),
    oneErm:   (r['one_erm']    as num).toDouble(),
    isErm:    (r['is_erm']     as int) == 1,
  )).toList();
}

/// Fetches a volume‐max value (or null).
Future<double?> fetchVolumeMax(int defId, String timeframe) async {
  final db = await database;
  final row = await StatsDao.getVolumeMax(db, defId, timeframe);
  if (row == null) return null;
  return (row['vm_value'] as num).toDouble();
}

  // ─── Muscle % Computations ────────────────────────────────


  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async {
    final def = await getExerciseDefinitionById(defId);
    if (def == null) return [];

    final step = await getFormulaStep();
    final mn   = await getFormulaMin();
    final mx   = await getFormulaMax();

    final overrides = await AnalyticsDao.getPercentsForExercise(await database, defId);
    final overrideMap = { for (var e in overrides) e.muscleId : e.percent };

    return def.muscles.map((rm) {
      final defaultPct = (1.0 - step * (rm.rank - 1)).clamp(mn, mx);
      return ExerciseMusclePercent(
        exerciseDefId: defId,
        muscleId: rm.muscle.id,
        percent: overrideMap[rm.muscle.id] ?? defaultPct,
      );
    }).toList();
  }


  Future<Map<BodyPart,double>> computeBodyPartPercents(int defId) async {
    final musclePercs = await computeMusclePercents(defId);
    final percMap = { for (var e in musclePercs) e.muscleId : e.percent };

    final db = await database;
    final def = await getExerciseDefinitionById(defId);
    if (def == null) return {};

    final result = <BodyPart,double>{};
    for (var bp in def.bodyParts) {
      final links = await AnalyticsDao.getMusclesForBodyPart(db, bp.id);
      final hits = links
        .map((l) => percMap[l.muscleId])
        .whereType<double>()
        .toList();
      if (hits.isEmpty) continue;
      result[bp] = hits.reduce((a,b) => a+b) / hits.length;
    }
    return result;
  }

  // ─── Session/Set Analytics ───────────────────────────────

  Future<Map<int,double>> fetchSetsPerMuscle({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    final sessions = await SessionDao.getSessionsInRange(
      db, start.toIso8601String(), end.toIso8601String());
    final result = <int,double>{};

    for (var s in sessions) {
      final exRows = await ExerciseDao.getExercisesForSession(db, s['id'] as int);
      for (var ex in exRows.where((e) => e['type']=='weight')) {
        final eid = ex['id'] as int;
        final percents = await computeMusclePercents(ex['exercise_def_id'] as int);
        final sets = await SetDao.getSetsForExercise(db, eid);
        // ignore: unused_local_variable
        for (var set in sets) {
          for (var mp in percents) {
            result[mp.muscleId] = (result[mp.muscleId] ?? 0) + mp.percent;
          }
        }
      }
    }
    return result;
  }

  Future<Map<BodyPart,double>> fetchSetsPerBodyPart({
    required DateTime start,
    required DateTime end,
  }) async {
    final muscleTotals = await fetchSetsPerMuscle(start: start, end: end);
    final allBps = await LookupDao.getAllBodyParts(await database);
    final bpById = { for (var bp in allBps) bp.id : bp };
    final result = <BodyPart,double>{};

    for (var entry in muscleTotals.entries) {
      final links = await AnalyticsDao.getBodyPartsForMuscle(
        await database, entry.key);
      for (var link in links) {
        final bp = bpById[link.bodyPartId];
        if (bp!=null) result[bp] = (result[bp] ?? 0) + entry.value;
      }
    }
    return result;
  }


// GYM PROFILES

/// Creates a new gym profile and returns its ID.
Future<int> createProfile(String name) async {
  final db = await database;
  final profile = GymProfile(id: null, name: name, createdAt: DateTime.now());
  return GymProfileDao.insertProfile(db, profile);
}

/// Retrieves all gym profiles.
Future<List<GymProfile>> fetchAllProfiles() async {
  final db = await database;
  return GymProfileDao.getAllProfiles(db);
}

/// Updates an existing gym profile.
Future<int> updateProfile(GymProfile profile) async {
  final db = await database;
  return GymProfileDao.updateProfile(db, profile);
}

/// Deletes a gym profile by ID.
Future<int> deleteProfile(int profileId) async {
  final db = await database;
  return GymProfileDao.deleteProfile(db, profileId);
}

/// Adds equipment to a gym profile.
Future<void> addEquipmentToProfile(int profileId, int equipmentId) async {
  final db = await database;
  await GymProfileDao.insertProfileEquipment(db, profileId, equipmentId);
}

/// Removes equipment from a gym profile.
Future<void> removeEquipmentFromProfile(int profileId, int equipmentId) async {
  final db = await database;
  await GymProfileDao.deleteProfileEquipment(db, profileId, equipmentId);
}

/// Fetches equipment for a specific gym profile.
Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(int profileId) async {
  final db = await database;
  return GymProfileDao.getEquipmentForProfile(db, profileId);
}

/// Look up an existing definition by name+equipment; throws if not found.
Future<int> findExerciseDefinitionId(String name, String equipmentName) async {
  final db = await database;
  int? eqId;
  if (equipmentName.isNotEmpty) {
    final eqRows = await db.query(
      'equipment', where: 'name = ?', whereArgs: [equipmentName]);
    if (eqRows.isNotEmpty) eqId = eqRows.first['id'] as int;
  }
  final whereClause = eqId != null
      ? 'name = ? AND equipment_id = ?'
      : 'name = ? AND equipment_id IS NULL';
  final args = eqId != null ? [name, eqId] : [name];
  final rows = await db.query(
    'exercise_definitions',
    columns: ['id'],
    where: whereClause,
    whereArgs: args,
  );
  if (rows.isEmpty) {
    throw Exception('ExerciseDefinition("$name",$equipmentName) not found');
  }
  return rows.first['id'] as int;
}

/// Returns all sessions as WorkoutSession objects, sorted by date desc.
Future<List<WorkoutSession>> fetchWorkoutSessions() async {
  // raw maps
  final raw = await getAllSessionsRaw();
  // map to model
  return raw.map((row) => WorkoutSession(
    id:       row['id']       as int,
    date:     DateTime.parse(row['date'] as String),
    duration: row['duration'] as int,
  )).toList();
}

// ─── PRESETS: Definition CRUD ─────────────────────────────

Future<int> createPreset(String name, {int? profileId}) async {
  final db = await database;
  return PresetDefinitionDao.insertPreset(
    db,
    name,
    profileId: profileId,
  );
}

Future<int> findOrCreatePreset(String name, {int? profileId}) async {
  final db = await database;
  return PresetDefinitionDao.findOrCreatePresetDefinition(
    db,
    name,
    profileId: profileId,
  );
}

Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({int? profileId}) async {
  final db = await database;
  return PresetDefinitionDao.getAllPresetsRaw(
    db,
    profileId: profileId,
  );
}

Future<PresetDefinition?> fetchPresetById(int presetId) async {
  final db = await database;
  final row = await PresetDefinitionDao.getPresetById(db, presetId);
  if (row == null) return null;
  return PresetDefinition(
    id:        row['id']         as int,
    name:      row['name']       as String,
    createdAt: DateTime.parse(row['created_at'] as String),
  );
}

Future<void> updatePresetName(int presetId, String name) async {
  final db = await database;
  await PresetDefinitionDao.updatePresetName(db, presetId, name);
}

Future<void> deletePreset(int presetId) async {
  final db = await database;
  await PresetDefinitionDao.deletePreset(db, presetId);
}

// ─── PRESETS: Exercise CRUD ───────────────────────────────

Future<int> addExerciseToPreset(
  int presetId,
  int? exerciseDefId,
  String type,
  int orderIndex,
) async {
  final db = await database;
  return PresetExerciseDao.insertPresetExercise(
    db: db,
    presetId: presetId,
    exerciseDefId: exerciseDefId,
    type: type,
    orderIndex: orderIndex,
  );
}

Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
  final db = await database;
  return PresetExerciseDao.getExercisesForPreset(db, presetId);
}

Future<void> deletePresetExercises(int presetId) async {
  final db = await database;
  await PresetExerciseDao.deleteExercisesForPreset(db, presetId);
}

// ─── PRESETS: Detail CRUD ─────────────────────────────────

Future<void> savePresetWeightSets(
  int presetExerciseId,
  List<ExerciseSet> parents,
  Map<int, List<ExerciseSet>> children,
) async {
  final db = await database;
  await PresetDetailDao.insertPresetSets(
    db: db,
    presetExerciseId: presetExerciseId,
    parentSets: parents,
    childChangeSets: children,
  );
}

Future<List<Map<String, dynamic>>> fetchPresetSets(int presetExerciseId) async {
  final db = await database;
  return PresetDetailDao.getPresetSets(db, presetExerciseId);
}

Future<void> savePresetCardio(
  int presetExerciseId,
  String cardioName,
  String? note,
  int plannedMinutes,
  int elapsedSeconds,
) async {
  final db = await database;
  await PresetDetailDao.insertPresetCardioDetails(
    db: db,
    presetExerciseId: presetExerciseId,
    cardioName: cardioName,
    note: note,
    plannedMinutes: plannedMinutes,
    elapsedSeconds: elapsedSeconds,
  );
}

Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
  final db = await database;
  return PresetDetailDao.getPresetCardioDetails(db, presetExerciseId);
}

Future<void> savePresetStretch(
  int presetExerciseId,
  List<Map<String, dynamic>> items,
) async {
  final db = await database;
  await PresetDetailDao.insertPresetStretchItems(
    db: db,
    presetExerciseId: presetExerciseId,
    items: items,
  );
}

Future<List<Map<String, dynamic>>> fetchPresetStretchItems(int presetExerciseId) async {
  final db = await database;
  return PresetDetailDao.getPresetStretchItems(db, presetExerciseId);
}


  // ─── AUTOPRESET SETTINGS WRAPPERS ───────────────────────────────────────

  /// Fetches the global auto‐preset settings for a given preset.
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async {
    final db = await database;
    return PresetAutoSettingsDao.getAutoSettings(db, presetId);
  }

  /// Inserts or updates the global auto‐preset settings.
  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
  required bool   weightCheck,
  required bool   repCheck,
  required bool   volumeCheck,
  required bool   adjustAllSets,
  }) async {
    final db = await database;
    await PresetAutoSettingsDao.upsertAutoSettings(
      db,
      presetId: presetId,
      isAutomatic: isAutomatic,
      globalIncrement: globalIncrement,
      skipFirstSet: skipFirstSet,
    weightCheck:     weightCheck,
    repCheck:        repCheck,
    volumeCheck:     volumeCheck,
    adjustAllSets:     adjustAllSets,
    
    );
  }


  /// Deletes the auto‐preset settings (disables automatic) for a preset.
  Future<void> deletePresetAutoSettings(int presetId) async {
    final db = await database;
    await PresetAutoSettingsDao.deleteAutoSettings(db, presetId);
  }

  // ─── PER-EXERCISE OVERRIDES ──────────────────────────────────────────────

  /// Fetches the auto override (IA + rotation) for a specific preset exercise.
  /// Fetches auto overrides _including_ last_node.
Future<Map<String, dynamic>?> fetchPresetExerciseAuto(int presetExerciseId) async {
  final db = await database;
  return PresetExerciseAutoDao.getExerciseAuto(db, presetExerciseId);
}

  /// Inserts or updates the per-exercise IA override and last_set_index.
  /// Upsert with lastNode.
Future<void> upsertPresetExerciseAuto({
  required int presetExerciseId,
  double? incrementAmount,
  required int lastSetIndex,
  String? lastNode,
}) async {
  final db = await database;
  await PresetExerciseAutoDao.upsertExerciseAuto(
    db,
    presetExerciseId: presetExerciseId,
    incrementAmount: incrementAmount,
    lastSetIndex: lastSetIndex,
    lastNode: lastNode,
  );
}
  
  
  /// Deletes the per-exercise auto override for a preset exercise.
  Future<void> deletePresetExerciseAuto(int presetExerciseId) async {
    final db = await database;
    await PresetExerciseAutoDao.deleteExerciseAuto(db, presetExerciseId);
  }

  // ─── PER-SET OVERRIDES ──────────────────────────────────────────────────

  /// Fetches the per-set IA override for a specific preset set.
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async {
    final db = await database;
    return PresetSetAutoDao.getSetAuto(db, presetSetId);
  }

  /// Inserts or updates the per-set IA override.
  Future<void> upsertPresetSetAuto({
    required int presetSetId,
    double? incrementAmount,
  }) async {
    final db = await database;
    await PresetSetAutoDao.upsertSetAuto(
      db,
      presetSetId: presetSetId,
      incrementAmount: incrementAmount,
    );
  }

  /// Deletes the per-set IA override for a preset set.
  Future<void> deletePresetSetAuto(int presetSetId) async {
    final db = await database;
    await PresetSetAutoDao.deleteSetAuto(db, presetSetId);
  }


  /// Update the target weight of a preset set.
  Future<void> updatePresetSetWeight(int presetSetId, double weight) async {
    final db = await database;
    await PresetDetailDao.updatePresetSetWeight(db: db, presetSetId: presetSetId, weight: weight);
  }


  /// Fetch the flow‐graph JSON for a preset.
Future<String> fetchFlowDefinition(int presetId) async {
  final db = await database;
  return PresetAutoSettingsDao.getFlowDefinition(db, presetId);
}

/// Save the flow‐graph JSON for a preset.
Future<void> upsertFlowDefinition(int presetId, String flowJson) async {
  final db = await database;
  await PresetAutoSettingsDao.upsertFlowDefinition(db, presetId, flowJson);
}

/// Fetch all user‐defined methods for a preset.
Future<List<Map<String, dynamic>>> fetchFlowMethods(int presetId) async {
  final db = await database;
  return PresetFlowMethodsDao.getMethods(db, presetId);
}

/// Insert or update a flow method; returns its new row ID.
Future<int> upsertFlowMethod({
  required int presetId,
  required String name,
  required String type,
  required Map<String, dynamic> params,
}) async {
  final db = await database;
  final paramsJson = jsonEncode(params);
  return PresetFlowMethodsDao.upsertMethod(
    db,
    presetId: presetId,
    name: name,
    type: type,
    paramsJson: paramsJson,
  );
}

/// Delete a flow method by ID.
Future<int> deleteFlowMethod(int methodId) async {
  final db = await database;
  return PresetFlowMethodsDao.deleteMethod(db, methodId);
}


Future<void> updatePresetSetReps(int presetSetId, int reps) async {
  final db = await database;
  await PresetDetailDao.updatePresetSetReps(
    db: db,
    presetSetId: presetSetId,
    reps: reps,
  );
}

Future<int> addPresetSet({
  required int presetExerciseId,
  required double weight,
  required int reps,
  required int orderIndex,
  int? parentSetId,
}) async {
  final db = await database;
  return PresetDetailDao.addPresetSet(
    db: db,
    presetExerciseId: presetExerciseId,
    weight: weight,
    reps: reps,
    orderIndex: orderIndex,
    parentSetId: parentSetId,
  );
}

Future<int> deletePresetSet(int presetSetId) async {
  final db = await database;
  return PresetDetailDao.deletePresetSet(
    db: db,
    presetSetId: presetSetId,
  );
}

}