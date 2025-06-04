// File: lib/db/database_helper.dart

import 'dart:async';
import 'dart:convert';                       // ← for json.decode()
import 'package:flutter/services.dart';     // ← for rootBundle.loadString()
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models.dart';

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
    version: 4,  // bumped to 4 now that we have stretch tables
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: _onCreate,
    onUpgrade: (db, oldVersion, newVersion) async {
      // ─── Version 3 migrations ───
      if (oldVersion < 3) {
        // V3: add rating & equipment/muscle join tables

        // 1) add "rating" column to exercise_definitions
        await db.execute('''
          ALTER TABLE exercise_definitions
            ADD COLUMN rating INTEGER NOT NULL DEFAULT 0;
        ''');

        // 2) exercise_equipment join table
        await db.execute('''
          CREATE TABLE exercise_equipment(
            exercise_id  INTEGER NOT NULL,
            equipment_id INTEGER NOT NULL,
            PRIMARY KEY(exercise_id, equipment_id),
            FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
            FOREIGN KEY(equipment_id) REFERENCES equipment(id)     ON DELETE CASCADE
          );
        ''');

        // 3) muscles lookup table
        await db.execute('''
          CREATE TABLE muscles(
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT    NOT NULL UNIQUE
          );
        ''');

        // 4) exercise_muscle join table
        await db.execute('''
          CREATE TABLE exercise_muscle(
            exercise_id INTEGER NOT NULL,
            muscle_id   INTEGER NOT NULL,
            rank        INTEGER NOT NULL,
            PRIMARY KEY(exercise_id, rank),
            FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
            FOREIGN KEY(muscle_id)   REFERENCES muscles(id)             ON DELETE CASCADE
          );
        ''');

        // After creating new tables, seed equipment/bodypart/muscle/exercise JSONs.
        await _seedFromAssets(db);
      }

      // ─── Version 4 (stretch) migrations ───
      if (oldVersion < 4) {
        // 1) Create stretch_definitions table
        await db.execute('''
          CREATE TABLE stretch_definitions(
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT    NOT NULL UNIQUE,
            description TEXT
          );
        ''');

        // 2) Create stretch_bodypart join table
        await db.execute('''
          CREATE TABLE stretch_bodypart(
            stretch_id   INTEGER NOT NULL,
            bodypart_id  INTEGER NOT NULL,
            PRIMARY KEY(stretch_id, bodypart_id),
            FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id) ON DELETE CASCADE,
            FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)             ON DELETE CASCADE
          );
        ''');

        // 3) Seed only the stretches from JSON (so _seedFromAssets should handle the stretch part,
        //    or you may extract a separate function like _seedStretchesFromAssets(db) if you prefer).
        await _seedFromAssets(db);
      }
    },
  );
}


/// (right after your table‐creation calls)
Future<void> _seedFromAssets(Database db) async {
  // 1) Equipment lookup
  final eqJson = await rootBundle.loadString('assets/equipment.json');
  final List eqList = json.decode(eqJson);
  for (var item in eqList) {
    await db.insert(
      'equipment',
      {'name': item['name']},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 2) Body parts lookup
  final bpJson = await rootBundle.loadString('assets/bodyparts.json');
  final List bpList = json.decode(bpJson);
  for (var item in bpList) {
    await db.insert(
      'bodypart',
      {'name': item['name']},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 3) Muscles lookup
  final mJson = await rootBundle.loadString('assets/muscles.json');
  final List mList = json.decode(mJson);
  for (var item in mList) {
    await db.insert(
      'muscles',
      {'name': item['name']},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 4) Exercises
  final exJson = await rootBundle.loadString('assets/exercises.json');
  final List exList = json.decode(exJson);
  for (var item in exList) {
    // 4.1) Determine primary equipment_id (first in list)
    final List eqNames = item['equipment'] as List;
    int? eqId;
    if (eqNames.isNotEmpty) {
      final primaryName = eqNames.first as String;
      final eqRows = await db.query(
        'equipment',
        where: 'name = ?',
        whereArgs: [primaryName],
      );
      eqId = eqRows.isNotEmpty ? eqRows.first['id'] as int : null;
    }

    // 4.2) Insert the exercise definition
    final defId = await db.insert(
      'exercise_definitions',
      {
        'name':        item['name'],
        'equipment_id': eqId,
        'rating':      item['rating'],
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // 4.3) Link *all* equipment entries (many-to-many)
    for (var eqName in eqNames) {
      final eqRows2 = await db.query(
        'equipment',
        where: 'name = ?',
        whereArgs: [eqName],
      );
      if (eqRows2.isNotEmpty) {
        await db.insert(
          'exercise_equipment',
          {
            'exercise_id':  defId,
            'equipment_id': eqRows2.first['id'] as int,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    // 4.4) Link to body parts
    for (var bpName in item['bodyparts'] as List) {
      final bpRows = await db.query(
        'bodypart',
        where: 'name = ?',
        whereArgs: [bpName],
      );
      if (bpRows.isNotEmpty) {
        await db.insert(
          'exercise_bodypart',
          {
            'exercise_id':  defId,
            'bodypart_id':  bpRows.first['id'] as int,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    // 4.5) Link ranked muscles
    for (var muscleEntry in item['muscles'] as List) {
      final name = muscleEntry['name'] as String;
      final rank = (muscleEntry['rank'] as num).toInt();
      final mRows2 = await db.query(
        'muscles',
        where: 'name = ?',
        whereArgs: [name],
      );
      if (mRows2.isNotEmpty) {
        await db.insert(
          'exercise_muscle',
          {
            'exercise_id': defId,
            'muscle_id':   mRows2.first['id'] as int,
            'rank':        rank,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

// 5) Stretches
  final stJson = await rootBundle.loadString('assets/stretches.json');
  final List stList = json.decode(stJson);
  for (var item in stList) {
    // 5.1) insert into stretch_definitions
    final stretchId = await db.insert(
      'stretch_definitions',
      {
        'name':        item['name'],
        'description': item['description'] ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // 5.2) link to each bodypart
    for (var bpName in (item['bodyparts'] as List)) {
      final bpRows = await db.query(
        'bodypart',
        where: 'name = ?',
        whereArgs: [bpName],
      );
      if (bpRows.isNotEmpty) {
        await db.insert(
          'stretch_bodypart',
          {
            'stretch_id':   stretchId,
            'bodypart_id':  bpRows.first['id'] as int,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

}



  /// Builds initial schema with lookups first.
Future<void> _onCreate(Database db, int version) async {
  // 1) Sessions table
  await db.execute('''
    CREATE TABLE sessions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL
    );
  ''');

  // 2) Lookup tables: equipment & bodypart
  await db.execute('''
    CREATE TABLE equipment(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    );
  ''');
  await db.execute('''
    CREATE TABLE bodypart(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    );
  ''');

  // 3) Exercise definitions & junction to body parts
  await db.execute('''
    CREATE TABLE exercise_definitions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      equipment_id INTEGER,
      rating INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(equipment_id) REFERENCES equipment(id)
    );
  ''');
  await db.execute('''
    CREATE TABLE exercise_bodypart(
      exercise_id INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL,
      PRIMARY KEY(exercise_id, bodypart_id),
      FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
      FOREIGN KEY(bodypart_id) REFERENCES bodypart(id)             ON DELETE CASCADE
    );
  ''');

  // 4) Instance tables: exercises & sets
  await db.execute('''
    CREATE TABLE exercises(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER NOT NULL,
      exercise_def_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      FOREIGN KEY(session_id) REFERENCES sessions(id)            ON DELETE CASCADE,
      FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
    );
  ''');
  await db.execute('''
    CREATE TABLE sets(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_id INTEGER NOT NULL,
      weight REAL NOT NULL,
      reps INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    );
  ''');

  // 5) Measurement definitions & measurements
  await db.execute('''
    CREATE TABLE measurement_definitions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      type TEXT NOT NULL
    );
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
    );
  ''');

  // 5a) Seed some default measurement definitions
  for (var def in [
    {'name': 'Bodyweight', 'type': 'weight'},
    {'name': 'Height',     'type': 'height'},
    {'name': 'Forearm',    'type': 'bodypart'},
    // … add others as desired …
  ]) {
    await db.insert('measurement_definitions', def);
  }
  for (var part in [
    'Forearm','Arm','Neck','Shoulder','Chest','Waist','Hip','Thigh','Calf'
  ]) {
    await db.insert(
      'measurement_definitions',
      {'name': part, 'type': 'bodypart'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 6) Many-to-many tables for exercises
  await db.execute('''
    CREATE TABLE exercise_equipment(
      exercise_id  INTEGER NOT NULL,
      equipment_id INTEGER NOT NULL,
      PRIMARY KEY(exercise_id, equipment_id),
      FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
      FOREIGN KEY(equipment_id) REFERENCES equipment(id)            ON DELETE CASCADE
    );
  ''');
  await db.execute('''
    CREATE TABLE muscles(
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT    NOT NULL UNIQUE
    );
  ''');
  await db.execute('''
    CREATE TABLE exercise_muscle(
      exercise_id INTEGER NOT NULL,
      muscle_id   INTEGER NOT NULL,
      rank        INTEGER NOT NULL,
      PRIMARY KEY(exercise_id, rank),
      FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
      FOREIGN KEY(muscle_id)   REFERENCES muscles(id)             ON DELETE CASCADE
    );
  ''');

  // 7) Stretch tables
  await db.execute('''
    CREATE TABLE stretch_definitions(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      name        TEXT NOT NULL UNIQUE,
      description TEXT NOT NULL
    );
  ''');
  await db.execute('''
    CREATE TABLE stretch_bodypart(
      stretch_id  INTEGER NOT NULL,
      bodypart_id INTEGER NOT NULL,
      PRIMARY KEY(stretch_id, bodypart_id),
      FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id) ON DELETE CASCADE,
      FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)            ON DELETE CASCADE
    );
  ''');

  // 8) Finally, seed from assets (equipment.json, bodyparts.json, muscles.json,
  //    exercises.json, stretches.json)
  await _seedFromAssets(db);
}


  /// Inserts a new session and returns its id.
 Future<int> insertSession(String date, int duration) async {
    final db = await database;
    return db.insert('sessions', {'date': date, 'duration': duration});
  }

  /// Inserts or finds the exercise definition, then the instance.
  Future<int> insertExercise(int sessionId, String name, String equipmentName, int orderIndex) async {
    final db = await database;

    // 1. Lookup equipment_id
    final eq = await db.query('equipment', where: 'name=?', whereArgs: [equipmentName]);

    final eqId = eq.isNotEmpty ? eq.first['id'] as int : null;
var def = await db.query(
  'exercise_definitions',

      where: eqId!=null ? 'name=? AND equipment_id=?' : 'name=? AND equipment_id IS NULL',

      whereArgs: eqId!=null ? [name, eqId] : [name],

  );
  int defId = def.isNotEmpty ? def.first['id'] as int
    : await db.insert('exercise_definitions', {'name': name, 'equipment_id': eqId});


    // 3. Insert the exercise instance
    return db.insert('exercises', {
      'session_id': sessionId,
      'exercise_def_id': defId,
      'order_index': orderIndex,
    });
  }

  /// Inserts a set belonging to an exercise instance.
  Future<int> insertSet(int exerciseId, double weight, int reps, int orderIndex) async {
    final db = await database;
    return db.insert('sets', {
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
  Future<List<Map<String, dynamic>>> getExercisesForSession(int sid) async {
    final db = await database;
    return db.query('exercises', where: 'session_id=?', whereArgs: [sid], orderBy: 'order_index');
  }

  // Fetch sets for an exercise
Future<List<Map<String, dynamic>>> getSetsForExercise(int eid) async {
    final db = await database;
    return db.query('sets', where: 'exercise_id=?', whereArgs: [eid], orderBy: 'order_index');
}

  /// Delete a session (cascades exercises & sets)
Future<void> deleteSession(int sid) async {
    final db = await database;
    await db.delete('sessions', where: 'id=?', whereArgs: [sid]);
  }


  /// Delete all exercises for a session (cascades sets)
 Future<void> deleteExercisesForSession(int sid) async {
    final db = await database;
    await db.delete('exercises', where: 'session_id=?', whereArgs: [sid]);
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

/// Fetches every definition with its full equipment/bodypart/muscle lists
  Future<List<Map<String, dynamic>>> getAllExercisesRaw() async {
    final db = await database;
    return db.query('exercise_definitions', orderBy: 'name');
  }

  /// Detailed fetch all
/// Fetch all exercise definitions along with their equipmentList, bodyParts, and muscles.
Future<List<ExerciseDefinition>> getAllExerciseDefinitionsDetailed() async {
  final db = await database;

  // 1) Load base definitions
  final defRows = await db.query(
    'exercise_definitions',
    orderBy: 'name',
  );

  final List<ExerciseDefinition> defs = [];

  for (final row in defRows) {
    final defId = row['id'] as int;
    final name = row['name'] as String;
    final equipmentId = row['equipment_id'] as int?;
    final rating = (row['rating'] as num?)?.toInt() ?? 0;

    // 2) Load extra equipment
    final equipRows = await db.rawQuery('''
      SELECT e.id, e.name
        FROM equipment e
        JOIN exercise_equipment ee ON ee.equipment_id = e.id
       WHERE ee.exercise_id = ?
       ORDER BY e.name
    ''', [defId]);
   final equipmentList = equipRows.map((e) =>
  Equipment(
    e['id']   as int,
    e['name'] as String,
  )
).toList();

    // 3) Load bodyParts
    final bpRows = await db.rawQuery('''
      SELECT b.id, b.name
        FROM bodypart b
        JOIN exercise_bodypart eb ON eb.bodypart_id = b.id
       WHERE eb.exercise_id = ?
       ORDER BY b.name
    ''', [defId]);
    final bodyParts = bpRows.map((b) =>
  BodyPart(
    b['id']   as int,
    b['name'] as String,
  )
).toList();

    // 4) Load ranked muscles
    final mRows = await db.rawQuery('''
      SELECT m.id AS muscle_id, m.name AS muscle_name, em.rank
        FROM muscles m
        JOIN exercise_muscle em ON em.muscle_id = m.id
       WHERE em.exercise_id = ?
       ORDER BY em.rank
    ''', [defId]);
    final muscles = mRows.map((m) => RankedMuscle(
      muscleId: m['muscle_id'] as int,
      muscleName: m['muscle_name'] as String,
      rank: (m['rank'] as num).toInt(),
    )).toList();

    defs.add(ExerciseDefinition(
      id: defId,
      name: name,
      equipmentId: equipmentId,
      rating: rating,
      equipmentList: equipmentList,
      bodyParts: bodyParts,
      muscles: muscles,
    ));
  }

  return defs;
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

  /// Fetch all equipment names.
  Future<List<String>> getAllEquipmentNames() async {
    final db = await database;
    final rows = await db.query('equipment', columns: ['name'], orderBy: 'name');
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Fetch all body-part names.
  Future<List<String>> getAllBodyPartNames() async {
    final db = await database;
    final rows = await db.query('bodypart', columns: ['name'], orderBy: 'name');
    return rows.map((r) => r['name'] as String).toList();
  }

/// Fetch all bodyparts (you already have getAllBodyPartNames), 
/// but we want IDs+names:
Future<List<BodyPart>> getAllBodyPartsFull() async {
  final db = await database;
  final rows = await db.query('bodypart', orderBy: 'name');
  return rows.map((r) => BodyPart(r['id'] as int, r['name'] as String)).toList();
}

/// Fetch stretches by an optional bodypart ID (or all if null)
Future<List<StretchDefinition>> getStretches({int? bodypartId}) async {
  final db = await database;
  // 1) Load base stretch rows
  final stretchRows = (bodypartId == null)
      ? await db.query('stretch_definitions', orderBy: 'name')
      : await db.rawQuery('''
          SELECT sd.id, sd.name, sd.description
            FROM stretch_definitions sd
            JOIN stretch_bodypart sb ON sb.stretch_id = sd.id
           WHERE sb.bodypart_id = ?
           ORDER BY sd.name
        ''', [bodypartId]);

  final List<StretchDefinition> result = [];
  for (final r in stretchRows) {
    final id = r['id'] as int;
    final nm = r['name'] as String;
    final desc = (r['description'] as String?) ?? '';
    // 2) load the bodyparts for this stretch:
    final bpRows = await db.rawQuery('''
      SELECT b.id, b.name
        FROM bodypart b
        JOIN stretch_bodypart sb ON sb.bodypart_id = b.id
       WHERE sb.stretch_id = ?
       ORDER BY b.name
    ''', [id]);
    final bpList = bpRows.map((b) => BodyPart(b['id'] as int, b['name'] as String)).toList();

    result.add(StretchDefinition(id: id, name: nm, description: desc, bodyParts: bpList));
  }
  return result;
}


  /// Fetch all muscle names.
  Future<List<String>> getAllMuscleNames() async {
    final db = await database;
    final rows = await db.query(
  'muscles',        // ← match your CREATE TABLE muscles(...)
  columns: ['name'],
  orderBy: 'name',
);
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Fetch all exercises whose equipment is *at least one* of [equipmentNames].
  Future<List<ExerciseDefinition>> getExerciseDefsWithAnyEquipment(List<String> equipmentNames) async {
    if (equipmentNames.isEmpty) return [];
    final db = await database;
    // lookup the equipment IDs
    final eqRows = await db.query(
      'equipment',
      where: 'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
      whereArgs: equipmentNames,
    );
    final eqIds = eqRows.map((r) => r['id'] as int).toList();
    if (eqIds.isEmpty) return [];

    // fetch definitions whose equipment_id matches any of these IDs
    final defRows = await db.query(
      'exercise_definitions',
      where: 'equipment_id IN (${List.filled(eqIds.length, '?').join(',')})',
      whereArgs: eqIds,
      orderBy: 'name',
    );
    return defRows.map((r) => ExerciseDefinition(
      id: r['id'] as int,
      name: r['name'] as String,
      equipmentId: r['equipment_id'] as int?,
      rating: r['rating'] as int,
    )).toList();
  }

  /// Fetch all exercises whose equipment is *only* drawn from [equipmentNames].
  ///
  /// Because each definition has a single `equipment_id`, this currently
  /// returns those whose `equipment_id` ∈ list, or `NULL` if you consider
  /// “bodyweight/no equipment” as allowed.
  Future<List<ExerciseDefinition>> getExerciseDefsOnlyWithEquipment(List<String> equipmentNames, {bool includeNone = true}) async {
    final db = await database;
    // lookup the equipment IDs
    final eqRows = await db.query(
      'equipment',
      where: 'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
      whereArgs: equipmentNames,
    );
    final eqIds = eqRows.map((r) => r['id'] as int).toList();

    // build WHERE clause: equipment_id IN (...) 
    // plus optionally include NULL (for 'None') if includeNone==true
    final whereClauses = <String>[];
    final args = <Object?>[];
    if (eqIds.isNotEmpty) {
      whereClauses.add('equipment_id IN (${List.filled(eqIds.length, '?').join(',')})');
      args.addAll(eqIds);
    }
    if (includeNone) {
      whereClauses.add('equipment_id IS NULL');
    }
    if (whereClauses.isEmpty) {
      // no filter—return all
      return getAllExerciseDefinitionsDetailed();
    }

    final defRows = await db.query(
      'exercise_definitions',
      where: whereClauses.join(' OR '),
      whereArgs: args,
      orderBy: 'name',
    );
    return defRows.map((r) => ExerciseDefinition(
      id: r['id'] as int,
      name: r['name'] as String,
      equipmentId: r['equipment_id'] as int?,
      rating: r['rating'] as int,
    )).toList();
  }

  /// Fetch exercise definitions, optionally filtering by:
  ///  – equipmentNames: list of equipment.name
  ///  – bodypartIds:  list of bodypart.id
  ///  – muscleIds:    list of muscle.id
  ///
  /// Each non-null filter list requires the definition to be associated
  /// with *at least one* entry in that list. All supplied filters are ANDed.
  Future<List<ExerciseDefinition>> getExerciseDefinitionsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    final db = await database;

    // 1) Resolve equipment names → ids
    List<int> equipmentIds = [];
    if (equipmentNames != null && equipmentNames.isNotEmpty) {
      final eqRows = await db.query(
        'equipment',
        columns: ['id'],
        where: 'name IN (${List.filled(equipmentNames.length, '?').join(',')})',
        whereArgs: equipmentNames,
      );
      equipmentIds = eqRows.map((r) => r['id'] as int).toList();
    }

    // Start building our WHERE clauses and args
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    // equipment filter
    if (equipmentIds.isNotEmpty) {
      whereClauses.add('ed.equipment_id IN (${List.filled(equipmentIds.length, '?').join(',')})');
      whereArgs.addAll(equipmentIds);
    }

    // bodypart filter
    if (bodypartIds != null && bodypartIds.isNotEmpty) {
      whereClauses.add('eb.bodypart_id IN (${List.filled(bodypartIds.length, '?').join(',')})');
      whereArgs.addAll(bodypartIds);
    }

    // muscle filter (requires you have exercise_muscle/exercise_muscles table)
    if (muscleIds != null && muscleIds.isNotEmpty) {
      whereClauses.add('em.muscle_id IN (${List.filled(muscleIds.length, '?').join(',')})');
      whereArgs.addAll(muscleIds);
    }

    // Build the full SQL with the necessary JOINs
    final sql = StringBuffer()
      ..write('''
        SELECT DISTINCT ed.id, ed.name, ed.equipment_id, ed.rating
          FROM exercise_definitions ed
        ''')
      // only join bodypart table if needed
      ..write((bodypartIds != null && bodypartIds.isNotEmpty)
          ? 'JOIN exercise_bodypart eb ON eb.exercise_id = ed.id '
          : '')
      // only join muscle table if needed
      ..write((muscleIds != null && muscleIds.isNotEmpty)
          ? 'JOIN exercise_muscle em ON em.exercise_id = ed.id '
          : '')
      // add WHERE if any filters
      ..write(whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')} '
          : '')
      ..write('ORDER BY ed.name');

    final rows = await db.rawQuery(sql.toString(), whereArgs);
    return rows.map((r) => ExerciseDefinition(
      id: r['id'] as int,
      name: r['name'] as String,
      equipmentId: r['equipment_id'] as int?,
      rating: r['rating'] as int,
    )).toList();
  }

/// Fetch all body parts with their IDs.
Future<List<BodyPart>> getAllBodyParts() async {
  final db = await database;
  final rows = await db.query('bodypart', orderBy: 'name');
  return rows
      .map((r) => BodyPart(r['id'] as int, r['name'] as String))
      .toList();
}


}
