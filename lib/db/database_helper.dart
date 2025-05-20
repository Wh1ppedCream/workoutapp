// File: lib/db/database_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 2,  // bumped for new schema
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  /// (Around line 25) Builds initial schema with lookups first.
  Future<void> _onCreate(Database db, int version) async {
    // Sessions table
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    // Lookup tables: equipment & bodypart
    await db.execute('''
      CREATE TABLE equipment(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE bodypart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Exercise definitions & junction to body parts
    await db.execute('''
      CREATE TABLE exercise_definitions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        equipment_id INTEGER,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_bodypart(
        exercise_id INTEGER NOT NULL,
        bodypart_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, bodypart_id),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
      )
    ''');

    // Instance tables: exercises & sets
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_def_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');


    // Seed equipment (line ~65)
    for (var name in ['None', 'Barbell', 'Dumbbell', 'Machine', 'Kettlebell']) {
      await db.insert('equipment', {'name': name});
    }
    // Seed body parts
    for (var part in ['Chest', 'Back', 'Legs', 'Biceps', 'Triceps', 'Shoulders', 'Core']) {
      await db.insert('bodypart', {'name': part});
    }

    await db.execute('''
  CREATE TABLE measurement_definitions(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL
  )
''');

await db.execute('''
  CREATE TABLE measurements(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    def_id INTEGER NOT NULL,
    timestamp TEXT NOT NULL,
    value REAL NOT NULL,
    unit TEXT NOT NULL,
    note TEXT,
    FOREIGN KEY(def_id) REFERENCES measurement_definitions(id) ON DELETE CASCADE
  )
''');

// Seed measurement definitions
for (var def in [
  {'name':'Bodyweight','type':'weight'},
  {'name':'Height','type':'height'},
  {'name':'Forearm','type':'bodypart'},
  // … add others as desired …
]) {
  await db.insert('measurement_definitions', def);
}

for (var part in [
  'Forearm','Arm','Neck','Shoulder','Chest','Waist','Hip','Thigh','Calf'
]) {
  await db.insert('measurement_definitions', {
    'name': part,
    'type': 'bodypart',
  });
}

  }

  /// (Around line 80) Inserts a new session and returns its id.
  Future<int> insertSession(String date, int duration) async {
    final db = await database;
    return await db.insert('sessions', {
      'date': date,
      'duration': duration,
    });
  }

  /// (Around line 90) Inserts or finds the exercise definition, then the instance.
  Future<int> insertExercise(int sessionId, String name, String equipmentName, int orderIndex) async {
    final db = await database;

    // 1. Lookup equipment_id
    final eqRows = await db.query(
      'equipment',
      where: 'name = ?',
      whereArgs: [equipmentName],
    );
    final equipmentId = eqRows.isNotEmpty ? eqRows.first['id'] as int : null;

    // 2. Lookup or insert into exercise_definitions
    List<dynamic> defArgs = equipmentId != null ? [name, equipmentId] : [name];
    final defQuery = equipmentId != null
        ? 'name = ? AND equipment_id = ?'
        : 'name = ? AND equipment_id IS NULL';

    final defRows = await db.query(
      'exercise_definitions',
      where: defQuery,
      whereArgs: defArgs,
    );

    int defId;
    if (defRows.isEmpty) {
      defId = await db.insert('exercise_definitions', {
        'name': name,
        'equipment_id': equipmentId,
      });
    } else {
      defId = defRows.first['id'] as int;
    }

    // 3. Insert the exercise instance
    return await db.insert('exercises', {
      'session_id': sessionId,
      'exercise_def_id': defId,
      'order_index': orderIndex,
    });
  }

  /// (Around line 120) Inserts a set belonging to an exercise instance.
  Future<int> insertSet(int exerciseId, double weight, int reps, int orderIndex) async {
    final db = await database;
    return await db.insert('sets', {
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'order_index': orderIndex,
    });
  }

  // Fetch all sessions
  Future<List<Map<String, dynamic>>> getAllSessionsRaw() async {
    final db = await database;
    return await db.query('sessions', orderBy: 'date DESC');
  }

  // Fetch exercises for a session
  Future<List<Map<String, dynamic>>> getExercisesForSession(int sessionId) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'order_index',
    );
  }

  // Fetch sets for an exercise
  Future<List<Map<String, dynamic>>> getSetsForExercise(int exerciseId) async {
    final db = await database;
    return await db.query(
      'sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
  }

  /// Delete a session (cascades exercises & sets)
  Future<void> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Delete all exercises for a session (cascades sets)
  Future<void> deleteExercisesForSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<Map<String, dynamic>>> getExerciseDefsByBodyPart(int bodyPartId) async {
  final db = await database;
  return await db.rawQuery(
    '''
    SELECT ed.id, ed.name, ed.equipment_id
      FROM exercise_definitions ed
      JOIN exercise_bodypart eb ON eb.exercise_id = ed.id
     WHERE eb.bodypart_id = ?
     ORDER BY ed.name
    ''',
    [bodyPartId],
  );
}

/// Fetch all measurement definitions
Future<List<Map<String,dynamic>>> getMeasurementDefinitions() async {
  final db = await database;
  return db.query('measurement_definitions', orderBy: 'name');
}

/// Insert a new measurement instance
Future<int> insertMeasurement(int defId, DateTime ts, double value, String unit, String? note) async {
  final db = await database;
  return db.insert('measurements', {
    'def_id': defId,
    'timestamp': ts.toIso8601String(),
    'value': value,
    'unit': unit,
    'note': note,
  });
}

/// Fetch all measurements for a definition
Future<List<Map<String,dynamic>>> getMeasurementsForDefinition(int defId) async {
  final db = await database;
  return db.query(
    'measurements',
    where: 'def_id = ?',
    whereArgs: [defId],
    orderBy: 'timestamp DESC',
  );
}

/// Returns only the definitions that have at least one measurement recorded.
Future<List<Map<String, dynamic>>> getUsedMeasurementDefinitions() async {
  final db = await database;
  return db.rawQuery('''
    SELECT md.id, md.name, md.type 
      FROM measurement_definitions md
      JOIN measurements m ON m.def_id = md.id
     GROUP BY md.id
     ORDER BY md.name
  ''');
}

}
