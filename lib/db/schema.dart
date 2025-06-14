// File: lib/db/schema.dart

import 'package:sqflite/sqflite.dart';

/// Holds all SQL for creating tables and performing schema migrations.
class Schema {
  /// Initial schema creation (onCreate).
  static Future<void> createTables(Database db) async {
    // 1) sessions
    await db.execute('''
      CREATE TABLE sessions(
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        date     TEXT    NOT NULL,
        duration INTEGER NOT NULL
      );
    ''');

    // 2) equipment & bodypart
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

    // 3) exercise_definitions & junction
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

    // 4) exercises
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

    // 5) sets
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

    // 6) measurement_definitions & measurements
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

    // 7) exercise_equipment & muscles & exercise_muscle
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

    // 8) stretch_definitions & stretch_bodypart
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

    // 9) cardio_details
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

    // 10) stretch_instances & items
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

  /// Migrations for version 3
  static Future<void> migrateV3(Database db) async {
    // Add rating to exercise_definitions
    await db.execute('''
      ALTER TABLE exercise_definitions
        ADD COLUMN rating INTEGER NOT NULL DEFAULT 0;
    ''');
    // exercise_equipment join table
    await db.execute('''
      CREATE TABLE exercise_equipment(
        exercise_id  INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, equipment_id),
        FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)             ON DELETE CASCADE
      );
    ''');
    // muscles lookup
    await db.execute('''
      CREATE TABLE muscles(
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      );
    ''');
    // exercise_muscle join table
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

  /// Migrations for version 4
  static Future<void> migrateV4(Database db) async {
    // Create stretch_definitions & join
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

  /// Migrations for version 5
  static Future<void> migrateV5(Database db) async {
    // Add type column to exercises
    await db.execute('''
      ALTER TABLE exercises
        ADD COLUMN type TEXT NOT NULL DEFAULT 'weight';
    ''');
    // Create cardio_details
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
    // Create stretch_instances
    await db.execute('''
      CREATE TABLE stretch_instances(
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');
    // Create stretch_instance_items
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
    // Modify sets for parent_set_id
    await db.execute('''
      ALTER TABLE sets
        ADD COLUMN parent_set_id INTEGER;
    ''');
  }
}
