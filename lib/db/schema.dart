// File: lib/db/schema.dart

import 'package:sqflite/sqflite.dart';

/// Database schema manager: creates tables and handles version migrations.
///
/// Contains methods to:
///  • Create initial schema (v1).
///  • Migrate to v3, v4, and v5.
///
/// Usage:
/// ```dart
/// await Schema.createTables(db);
/// await Schema.migrateV3(db);
/// // etc.
/// ```
class Schema {
  /// Creates all tables for the initial schema (version 1).
  ///
  /// - [db]: The open database instance.
  static Future<void> createTables(Database db) async {
    // 1) sessions: stores workout sessions
    await db.execute('''
      CREATE TABLE sessions(
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        date     TEXT    NOT NULL,
        duration INTEGER NOT NULL
      );
    ''');

    // 2) equipment & bodypart lookup tables
    await db.execute('''
      CREATE TABLE equipment(
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      );
    ''');
    await db.execute('''
      CREATE TABLE bodypart(
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      );
    ''');

    // 3) exercise definitions and junction to body parts
    await db.execute('''
      CREATE TABLE exercise_definitions(
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL,
        equipment_id INTEGER,
        rating       INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE exercise_bodypart(
        exercise_id INTEGER NOT NULL,
        bodypart_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, bodypart_id),
        FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)            ON DELETE CASCADE
      );
    ''');

    // 4) exercises (instances in sessions)
    await db.execute('''
      CREATE TABLE exercises(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id      INTEGER NOT NULL,
        exercise_def_id INTEGER,
        type            TEXT    NOT NULL,
        order_index     INTEGER NOT NULL,
        FOREIGN KEY(session_id)      REFERENCES sessions(id)            ON DELETE CASCADE,
        FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
      );
    ''');

    // 5) sets for weight exercises
    await db.execute('''
      CREATE TABLE sets(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id    INTEGER NOT NULL,
        weight         REAL    NOT NULL,
        reps           INTEGER NOT NULL,
        order_index    INTEGER NOT NULL,
        parent_set_id  INTEGER,
        FOREIGN KEY(exercise_id)   REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');

    // 6) measurement definitions and measurements
    await db.execute('''
      CREATE TABLE measurement_definitions(
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE,
        type TEXT    NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE measurements(
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        def_id    INTEGER NOT NULL,
        timestamp TEXT    NOT NULL,
        value     REAL    NOT NULL,
        unit      TEXT    NOT NULL,
        note      TEXT,
        FOREIGN KEY(def_id) REFERENCES measurement_definitions(id) ON DELETE CASCADE
      );
    ''');

    // 7) equipment and muscle relationships for definitions
    await db.execute('''
      CREATE TABLE exercise_equipment(
        exercise_id  INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, equipment_id),
        FOREIGN KEY(exercise_id)   REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id)  REFERENCES equipment(id)            ON DELETE CASCADE
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

    // 8) stretch definitions and join table
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

    // 9) cardio details for exercises
    await db.execute('''
      CREATE TABLE cardio_details(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id     INTEGER NOT NULL UNIQUE,
        cardio_name     TEXT    NOT NULL,
        note            TEXT,
        planned_minutes INTEGER NOT NULL,
        elapsed_seconds INTEGER NOT NULL,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');

    // 10) stretch instances and items in sessions
    await db.execute('''
      CREATE TABLE stretch_instances(
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE stretch_instance_items(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id    INTEGER NOT NULL,
        stretch_id     INTEGER,
        is_custom      INTEGER NOT NULL DEFAULT 0,
        custom_name    TEXT,
        custom_desc    TEXT,
        is_checked     INTEGER NOT NULL DEFAULT 0,
        order_index    INTEGER NOT NULL,
        FOREIGN KEY(exercise_id) REFERENCES stretch_instances(exercise_id) ON DELETE CASCADE,
        FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id)    ON DELETE CASCADE
      );
    ''');
  }

  /// Applies database migrations for version 3.
  ///
  /// - Adds [rating] column to exercise_definitions.
  /// - Creates equipment/muscle lookup tables.
  static Future<void> migrateV3(Database db) async {
    await db.execute('ALTER TABLE exercise_definitions ADD COLUMN rating INTEGER NOT NULL DEFAULT 0;');
    await db.execute('''
      CREATE TABLE exercise_equipment(
        exercise_id  INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, equipment_id),
        FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)             ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE TABLE muscles(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE);');
    await db.execute('''
      CREATE TABLE exercise_muscle(
        exercise_id INTEGER NOT NULL,
        muscle_id   INTEGER NOT NULL,
        rank        INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, rank),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
      );
    ''');
  }

  /// Applies database migrations for version 4.
  ///
  /// - Creates stretch definitions and join table.
  static Future<void> migrateV4(Database db) async {
    await db.execute('''
      CREATE TABLE stretch_definitions(
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL UNIQUE,
        description TEXT    NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE stretch_bodypart(
        stretch_id   INTEGER NOT NULL,
        bodypart_id  INTEGER NOT NULL,
        PRIMARY KEY(stretch_id, bodypart_id),
        FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)            ON DELETE CASCADE
      );
    ''');
  }

  /// Applies database migrations for version 5.
  ///
  /// - Adds [type] column to exercises.
  /// - Creates cardio_details and stretch instance tables.
  /// - Adds [parent_set_id] to sets.
  static Future<void> migrateV5(Database db) async {
    await db.execute("ALTER TABLE exercises ADD COLUMN type TEXT NOT NULL DEFAULT 'weight';");
    await db.execute('''
      CREATE TABLE cardio_details(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id     INTEGER NOT NULL UNIQUE,
        cardio_name     TEXT    NOT NULL,
        note            TEXT,
        planned_minutes INTEGER NOT NULL,
        elapsed_seconds INTEGER NOT NULL,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE stretch_instances(
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE stretch_instance_items(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id    INTEGER NOT NULL,
        stretch_id     INTEGER,
        is_custom      INTEGER NOT NULL DEFAULT 0,
        custom_name    TEXT,
        custom_desc    TEXT,
        is_checked     INTEGER NOT NULL DEFAULT 0,
        order_index    INTEGER NOT NULL,
        FOREIGN KEY(exercise_id) REFERENCES stretch_instances(exercise_id) ON DELETE CASCADE,
        FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id)    ON DELETE CASCADE
      );
    ''');
    await db.execute('ALTER TABLE sets ADD COLUMN parent_set_id INTEGER;');
  }
}
