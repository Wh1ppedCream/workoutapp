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
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Deletes every exercise (and cascades its sets) for a given session
  Future<void> deleteExercisesForSession(int sessionId) async {
    final db = await database;
    await db.delete(
     'exercises',
     where: 'session_id = ?',
     whereArgs: [sessionId],
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        equipment TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE
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
  }

  // Insert a new session and return its id
  Future<int> insertSession(String date, int duration) async {
    final db = await database;
    return await db.insert('sessions', {
      'date': date,
      'duration': duration,
    });
  }

  // Insert an exercise and return its id
  Future<int> insertExercise(int sessionId, String name, String equipment, int orderIndex) async {
    final db = await database;
    return await db.insert('exercises', {
      'session_id': sessionId,
      'name': name,
      'equipment': equipment,
      'order_index': orderIndex,
    });
  }

  // Insert a set
  Future<int> insertSet(int exerciseId, double weight, int reps, int orderIndex) async {
    final db = await database;
    return await db.insert('sets', {
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'order_index': orderIndex,
    });
  }

  // Fetch all sessions with nested exercises and sets
  Future<List<Map<String, dynamic>>> getAllSessionsRaw() async {
    final db = await database;
    return await db.query('sessions', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getExercisesForSession(int sessionId) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'order_index',
    );
  }

  Future<List<Map<String, dynamic>>> getSetsForExercise(int exerciseId) async {
    final db = await database;
    return await db.query(
      'sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'order_index',
    );
  }
  
  Future<void> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
