// File: lib/db/database_helper.dart

import 'dart:async';
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
      version: 5,  // bumped to 5
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
},
);
  }

  /// Builds initial schema with lookups first.
 Future<void> _onCreate(Database db, int version) async {
	// 1) Create all tables
  await Schema.createTables(db);
  // 2) Seed lookups & exercises
  await Seed.seedLookupsAndExercises(db);
  // 3) Seed stretches
  await Seed.seedStretches(db);
}

  // ────────────────────────────────────────────────────────────────────────────
  // CRUD METHODS
  // ────────────────────────────────────────────────────────────────────────────

//session_dao
Future<int> insertSession(String date, int duration) async {
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

//exercise_dao
Future<int> insertExercise(int sessionId, String name, String equipmentName, int orderIndex) async {
    final db = await database;
    return ExerciseDao.insertExercise(db, sessionId, name, equipmentName, orderIndex);
  }


  Future<int> insertExerciseRow({
    required int sessionId,
    int?    exerciseDefId,
    required String type,
    required int orderIndex,
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


  Future<List<Map<String, dynamic>>> getExercisesForSession(int sid) async {
    final db = await database;
    return ExerciseDao.getExercisesForSession(db, sid);
  }


  Future<void> deleteExercisesForSession(int sid) async {
    final db = await database;
    return ExerciseDao.deleteExercisesForSession(db, sid);
  }
 
 
 // set_dao.dart

  /// Inserts a set belonging to an exercise instance.
  Future<int> insertSet(int exerciseId, double weight, int reps, int orderIndex) async {
    final db = await database;
   return SetDao.insertSet(
     db,
     exerciseId,
     weight,
     reps,
     orderIndex,
   );
  }

  /// Given a parentSets list and childChangeSets map, insert into `sets`.
  /// `parentSets` is List < ExerciseSet >  where each is a top-level set.
  /// `childChangeSets` is a Map < parentIndex, List < ExerciseSet>>.
  Future<void> insertWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    final db = await database;
    return SetDao.insertWeightSets(
      db: db,
      exerciseId: exerciseId,
      parentSets: parentSets,
      childChangeSets: childChangeSets,
      );
  }

   /// Fetch sets for an exercise.
  Future<List<Map<String, dynamic>>> getSetsForExercise(int eid) async {
    final db = await database;
    return SetDao.getSetsForExercise(db, eid);
  }

 
  
  //cardio_dao.dart
  
  /// After you create a cardio exercise row (type='cardio'), call:
 Future<void> insertCardioDetails({
   required int exerciseId,
   required String cardioName,
   String? note,
   required int plannedMinutes,
   required int elapsedSeconds,
 }) async {
   final db = await database;
   return CardioDao.insertCardioDetails(
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


//stretch_dao.dart

  /// After you create a stretch-type exercise row, call:
  /// Inserts one stretch-type exercise’s “instance” and all of its items.
 Future<void> insertStretchInstance({
   required int exerciseId,
   required List<Map<String, dynamic>> items,
 }) async {
   final db = await database;
   return StretchDao.insertStretchInstance(
     db: db,
     exerciseId: exerciseId,
     items: items,
   );
 }

  /// Fetch all items in a stretch instance for a given exercise.
 Future<List<Map<String, dynamic>>> getStretchItemsForExercise(int eid) async {
   final db = await database;
   return StretchDao.getStretchItemsForExercise(db, eid);
 }
 
//definition_dao.dart

  /// Fetch exercise definitions by bodyPart ID.
  Future<List<Map<String, dynamic>>> getExerciseDefsByBodyPart(int bodyPartId) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
    }


  /// Fetch every definition with its full equipmentList, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> getAllExerciseDefinitionsDetailed() async {
    final db = await database;
    return DefinitionDao.getAllExerciseDefinitionsDetailed(db);
  }

/// Fetch all exercise definitions (shallow, without join lists).
Future<List<Map<String, dynamic>>> getAllExercisesRaw() async {
  final db = await database;
  return DefinitionDao.getAllExercisesRaw(db);
}

 /// Fetch all exercises whose equipment is *at least one* of [equipmentNames].
 Future<List<ExerciseDefinition>> getExerciseDefsWithAnyEquipment(List<String> equipmentNames) async {
  final db = await database;
  return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
}

  /// Fetch all exercises whose equipment is *only* drawn from [equipmentNames].
  ///
  /// Because each definition has a single `equipment_id`, this currently
  /// returns those whose `equipment_id` ∈ list, or `NULL` if you consider
  /// “bodyweight/no equipment” as allowed.
 Future<List<ExerciseDefinition>> getExerciseDefsOnlyWithEquipment(
  List<String> equipmentNames, { bool includeNone = true }
) async {
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
Future<List<ExerciseDefinition>> getExerciseDefinitionsFiltered({
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


//lookup_dao.dart
  
  /// Fetch all measurement definitions.
Future<List<Map<String, dynamic>>> getMeasurementDefinitions() async {
  final db = await database;
  return LookupDao.getMeasurementDefinitions(db);
}

  /// Insert a new measurement instance.
Future<int> insertMeasurement(int defId, DateTime ts, double value, String unit, String? note) async {
  final db = await database;
  return LookupDao.insertMeasurement(db, defId, ts, value, unit, note);
}

/// Fetch all measurements for a definition.
 Future<List<Map<String, dynamic>>> getMeasurementsForDefinition(int defId) async {
  final db = await database;
  return LookupDao.getMeasurementsForDefinition(db, defId);
}

  /// Returns only the definitions that have at least one measurement recorded.
 Future<List<Map<String, dynamic>>> getUsedMeasurementDefinitions() async {
  final db = await database;
  return LookupDao.getUsedMeasurementDefinitions(db);
}

  /// Fetch all equipment names.
Future<List<String>> getAllEquipmentNames() async {
  final db = await database;
  return LookupDao.getAllEquipmentNames(db);
}

  /// Fetch all body-part IDs and names.
Future<List<BodyPart>> getAllBodyParts() async {
  final db = await database;
  return LookupDao.getAllBodyParts(db);
}

  /// Fetch stretches by an optional bodypart ID (or all if null).
Future<List<StretchDefinition>> getStretches({int? bodypartId}) async {
  final db = await database;
  return LookupDao.getStretches(db, bodypartId);
}

  /// Fetch all muscle names.
Future<List<String>> getAllMuscleNames() async {
  final db = await database;
  return LookupDao.getAllMuscleNames(db);
}
}