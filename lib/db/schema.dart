// File: lib/db/schema.dart

import 'package:sqflite/sqflite.dart';

import 'content_dao.dart';

/// Database schema manager for fresh installs and every historical migration.
class Schema {
  /// Creates initial schema (version 1).
  static Future<void> createV1(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
    await db.transaction((txn) async {
      // 1) sessions
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          date     TEXT    NOT NULL,
          duration INTEGER NOT NULL
        );
      ''');

      // 2) equipment & bodypart lookup
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS equipment (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT    NOT NULL UNIQUE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS bodypart (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT    NOT NULL UNIQUE
        );
      ''');

      // 3) exercise definitions & bodypart join
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_definitions (
          id           INTEGER PRIMARY KEY AUTOINCREMENT,
          name         TEXT NOT NULL,
          equipment_id INTEGER,
          rating       INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(equipment_id) REFERENCES equipment(id),
          UNIQUE(name, equipment_id)
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_bodypart (
          exercise_id INTEGER NOT NULL,
          bodypart_id INTEGER NOT NULL,
          PRIMARY KEY(exercise_id, bodypart_id),
          FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)            ON DELETE CASCADE
        );
      ''');

      // 4) exercises (instances in sessions)
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercises (
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
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS sets (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id INTEGER NOT NULL,
          weight      REAL    NOT NULL,
          reps        INTEGER NOT NULL,
          order_index INTEGER NOT NULL,
          parent_set_id  INTEGER,
          FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
        );
      ''');

      // 6) measurement definitions & measurements
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS measurement_definitions (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT    NOT NULL UNIQUE,
          type TEXT    NOT NULL
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS measurements (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          def_id    INTEGER NOT NULL,
          timestamp TEXT    NOT NULL,
          value     REAL    NOT NULL,
          unit      TEXT    NOT NULL,
          note      TEXT,
          FOREIGN KEY(def_id) REFERENCES measurement_definitions(id) ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Creates full schema for fresh installs (v1 + all migrations).
  static Future<void> createTables(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
    await createV1(db);
    await migrateV3(db);
    await migrateV4(db);
    await migrateV5(db);
    await migrateV6(db);
    await migrateV7(db);
    await migrateV8(db);
    await migrateV9(db);
    await migrateV10(db);
    await migrateV11(db);
    await migrateV12(db);
    await migrateV13(db);
    await migrateV14(db);
    await migrateV15(db);
    await migrateV16(db);
    await migrateV17(db);
    await migrateV18(db);
    await migrateV19(db);
    await migrateV20(db);
    await migrateV21(db);
    await migrateV22(db);
    await migrateV23(db);
    await migrateV24(db);
    await migrateV25(db);
    await migrateV26(db);
    await migrateV27(db);
    await migrateV28(db);
    await migrateV29(db);
    await migrateV30(db);
    await migrateV31(db);
    await migrateV32(db);
    await migrateV33(db);
    await migrateV34(db);
    await migrateV35(db);
    await migrateV36(db);
    await migrateV37(db);
    await migrateV38(db);
    await migrateV39(db);
    await migrateV40(db);
    await migrateV41(db);
    await migrateV42(db);
    await migrateV43(db);
    await migrateV44(db);
    await migrateV45(db);
    await migrateV46(db);
    await migrateV47(db);
    await migrateV48(db);
    await migrateV49(db);
    await migrateV50(db);
    await migrateV51(db);
    await migrateV52(db);
    await migrateV53(db);
    await migrateV54(db);
    await migrateV55(db);
    await migrateV56(db);
  }

  /// Handler for onUpgrade callback.
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await db.execute('PRAGMA foreign_keys = ON;');
    if (oldVersion < 3) await migrateV3(db);
    if (oldVersion < 4) await migrateV4(db);
    if (oldVersion < 5) await migrateV5(db);
    if (oldVersion < 6) await migrateV6(db);
    if (oldVersion < 7) await migrateV7(db);
    if (oldVersion < 8) await migrateV8(db);
    if (oldVersion < 9) await migrateV9(db);
    if (oldVersion < 10) await migrateV10(db);
    if (oldVersion < 11) await migrateV11(db);
    if (oldVersion < 12) await migrateV12(db);
    if (oldVersion < 13) await migrateV13(db);
    if (oldVersion < 14) await migrateV14(db);
    if (oldVersion < 15) await migrateV15(db);
    if (oldVersion < 16) await migrateV16(db);
    if (oldVersion < 17) await migrateV17(db);
    if (oldVersion < 18) await migrateV18(db);
    if (oldVersion < 19) await migrateV19(db);
    if (oldVersion < 20) await migrateV20(db);
    if (oldVersion < 21) await migrateV21(db);
    if (oldVersion < 22) await migrateV22(db);
    if (oldVersion < 23) await migrateV23(db);
    if (oldVersion < 24) await migrateV24(db);
    if (oldVersion < 25) await migrateV25(db);
    if (oldVersion < 26) await migrateV26(db);
    if (oldVersion < 27) await migrateV27(db);
    if (oldVersion < 28) await migrateV28(db);
    if (oldVersion < 29) await migrateV29(db);
    if (oldVersion < 30) await migrateV30(db);
    if (oldVersion < 31) await migrateV31(db);
    if (oldVersion < 32) await migrateV32(db);
    if (oldVersion < 33) await migrateV33(db);
    if (oldVersion < 34) await migrateV34(db);
    if (oldVersion < 35) await migrateV35(db);
    if (oldVersion < 36) await migrateV36(db);
    if (oldVersion < 37) await migrateV37(db);
    if (oldVersion < 38) await migrateV38(db);
    if (oldVersion < 39) await migrateV39(db);
    if (oldVersion < 40) await migrateV40(db);
    if (oldVersion < 41) await migrateV41(db);
    if (oldVersion < 42) await migrateV42(db);
    if (oldVersion < 43) await migrateV43(db);
    if (oldVersion < 44) await migrateV44(db);
    if (oldVersion < 45) await migrateV45(db);
    if (oldVersion < 46) await migrateV46(db);
    if (oldVersion < 47) await migrateV47(db);
    if (oldVersion < 48) await migrateV48(db);
    if (oldVersion < 49) await migrateV49(db);
    if (oldVersion < 50) await migrateV50(db);
    if (oldVersion < 51) await migrateV51(db);
    if (oldVersion < 52) await migrateV52(db);
    if (oldVersion < 53) await migrateV53(db);
    if (oldVersion < 54) await migrateV54(db);
    if (oldVersion < 55) await migrateV55(db);
    if (oldVersion < 56) await migrateV56(db);
  }

  /// Migration to version 3: adds rating, equipment/muscle tables.
  static Future<void> migrateV3(Database db) async {
    // 1) Check if 'rating' already exists
    final cols = await db.rawQuery("PRAGMA table_info('exercise_definitions')");
    final hasRating = cols.any((c) => c['name'] == 'rating');
    await db.transaction((txn) async {
      if (!hasRating) {
        await txn.execute(
          "ALTER TABLE exercise_definitions ADD COLUMN rating INTEGER NOT NULL DEFAULT 0;",
        );
      }
      // **new**: unique index on name+equipment
      await txn.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_ex_def_name_equipment
        ON exercise_definitions(name, equipment_id);
    ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_equipment (
          exercise_id  INTEGER NOT NULL,
          equipment_id INTEGER NOT NULL,
          PRIMARY KEY(exercise_id, equipment_id),
          FOREIGN KEY(exercise_id)   REFERENCES exercise_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(equipment_id)  REFERENCES equipment(id)             ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS muscles (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT    NOT NULL UNIQUE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_muscle (
          exercise_id INTEGER NOT NULL,
          muscle_id   INTEGER NOT NULL,
          rank        INTEGER NOT NULL,
          PRIMARY KEY(exercise_id, rank),
          UNIQUE(exercise_id, muscle_id),
          FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(muscle_id)   REFERENCES muscles(id)             ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Migration to version 4: adds stretch definitions and join table.
  static Future<void> migrateV4(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS stretch_definitions (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          name        TEXT NOT NULL UNIQUE,
          description TEXT NOT NULL
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS stretch_bodypart (
          stretch_id  INTEGER NOT NULL,
          bodypart_id INTEGER NOT NULL,
          PRIMARY KEY(stretch_id, bodypart_id),
          FOREIGN KEY(stretch_id)  REFERENCES stretch_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(bodypart_id) REFERENCES bodypart(id)            ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Migration to version 5: adds exercise type, cardio & stretch tables.
  static Future<void> migrateV5(Database db) async {
    // 1) Check if 'type' already exists
    final cols = await db.rawQuery("PRAGMA table_info('exercises')");
    final hasType = cols.any((c) => c['name'] == 'type');

    await db.transaction((txn) async {
      if (!hasType) {
        await txn.execute(
          "ALTER TABLE exercises ADD COLUMN type TEXT NOT NULL DEFAULT 'weight';",
        );
      }

      // cardio details
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS cardio_details (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id     INTEGER NOT NULL UNIQUE,
          cardio_name     TEXT    NOT NULL,
          note            TEXT,
          planned_minutes INTEGER NOT NULL,
          elapsed_seconds INTEGER NOT NULL,
          FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
        );
      ''');

      // stretch instances
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS stretch_instances (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id INTEGER NOT NULL UNIQUE,
          FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
        );
      ''');

      // stretch items keyed by exercise_id
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS stretch_instance_items (
          id             INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id    INTEGER NOT NULL,
          stretch_id     INTEGER,
          is_custom      INTEGER NOT NULL DEFAULT 0,
          custom_name    TEXT,
          custom_desc    TEXT,
          is_checked     INTEGER NOT NULL DEFAULT 0,
          order_index    INTEGER NOT NULL,
          FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
          FOREIGN KEY(stretch_id)   REFERENCES stretch_definitions(id) ON DELETE CASCADE
        );
      ''');

      // parent_set_id on sets
      final setCols = await txn.rawQuery("PRAGMA table_info('sets')");
      final hasParent = setCols.any((c) => c['name'] == 'parent_set_id');
      if (!hasParent) {
        await txn.execute("ALTER TABLE sets ADD COLUMN parent_set_id INTEGER;");
      }
    });
  }

  /// Migration to version 6: adds presets tables.
  static Future<void> migrateV6(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_definitions (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          name        TEXT    NOT NULL,
          created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_exercises (
          id                INTEGER PRIMARY KEY AUTOINCREMENT,
          preset_id         INTEGER NOT NULL,
          exercise_def_id   INTEGER,
          type              TEXT    NOT NULL,
          order_index       INTEGER NOT NULL,
          FOREIGN KEY(preset_id)       REFERENCES preset_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_sets (
          id                   INTEGER PRIMARY KEY AUTOINCREMENT,
          preset_exercise_id   INTEGER NOT NULL,
          weight               REAL    NOT NULL,
          reps                 INTEGER NOT NULL,
          order_index          INTEGER NOT NULL,
          parent_set_id        INTEGER,
          FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_cardio_details (
          id                  INTEGER PRIMARY KEY AUTOINCREMENT,
          preset_exercise_id  INTEGER NOT NULL UNIQUE,
          cardio_name         TEXT    NOT NULL,
          note                TEXT,
          planned_minutes     INTEGER NOT NULL,
          elapsed_seconds     INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_stretch_items (
          id                   INTEGER PRIMARY KEY AUTOINCREMENT,
          preset_exercise_id   INTEGER NOT NULL,
          stretch_id           INTEGER,
          is_custom            INTEGER NOT NULL DEFAULT 0,
          custom_name          TEXT,
          custom_desc          TEXT,
          order_index          INTEGER NOT NULL,
          FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE,
          FOREIGN KEY(stretch_id)            REFERENCES stretch_definitions(id)
        );
      ''');
    });
  }

  /// Migration to version 7: adds gym profiles and profile_id on presets.
  static Future<void> migrateV7(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS gym_profiles (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS profile_equipment (
        profile_id    INTEGER NOT NULL,
        equipment_id  INTEGER NOT NULL,
        PRIMARY KEY(profile_id, equipment_id),
        FOREIGN KEY(profile_id)   REFERENCES gym_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)     ON DELETE CASCADE
      );
    ''');

      final tableExists =
          (await txn.rawQuery(
            "SELECT 1 FROM sqlite_master WHERE type='table' AND name='preset_definitions' LIMIT 1;",
          )).isNotEmpty;

      if (tableExists) {
        final cols = await txn.rawQuery(
          "PRAGMA table_info('preset_definitions');",
        );
        final hasProfileId = cols.any((c) => c['name'] == 'profile_id');
        if (!hasProfileId) {
          await txn.execute(
            "ALTER TABLE preset_definitions ADD COLUMN profile_id INTEGER REFERENCES gym_profiles(id) ON DELETE SET NULL;",
          );
        }
      }

      await txn.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS ux_preset_name_profile
      ON preset_definitions(name, profile_id);
    ''');
    });
  }

  /// Migration to version 8: adds rep-max & volume-max tables.
  static Future<void> migrateV8(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_rep_max (
          def_id     INTEGER NOT NULL,
          rep_count  INTEGER NOT NULL,
          timeframe  TEXT    NOT NULL,  -- 'week', 'month', 'all'
          rm_value   REAL    NOT NULL,
          one_erm    REAL    NOT NULL,
          is_erm     INTEGER NOT NULL,
          PRIMARY KEY(def_id, rep_count, timeframe),
          FOREIGN KEY(def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_volume_max (
          def_id     INTEGER NOT NULL,
          timeframe  TEXT    NOT NULL,
          vm_value   REAL    NOT NULL,
          PRIMARY KEY(def_id, timeframe),
          FOREIGN KEY(def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Migration to version 9: adds analytics & volume boundary tables.
  static Future<void> migrateV9(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS muscle_bodypart (
          muscle_id    INTEGER NOT NULL,
          bodypart_id  INTEGER NOT NULL,
          PRIMARY KEY(muscle_id, bodypart_id),
          FOREIGN KEY(muscle_id)    REFERENCES muscles(id) ON DELETE CASCADE,
          FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS bodypart_ranking (
          bodypart_id INTEGER PRIMARY KEY,
          rank        INTEGER NOT NULL,
          FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS muscle_ranking (
          muscle_id INTEGER PRIMARY KEY,
          rank      INTEGER NOT NULL,
          FOREIGN KEY(muscle_id) REFERENCES muscles(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_muscle_percent (
          exercise_def_id INTEGER NOT NULL,
          muscle_id       INTEGER NOT NULL,
          percent         REAL    NOT NULL,
          PRIMARY KEY(exercise_def_id, muscle_id),
          FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
          FOREIGN KEY(muscle_id)       REFERENCES muscles(id)             ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS muscle_volume_boundaries (
          muscle_id              INTEGER PRIMARY KEY,
          maintenance_volume     REAL    NOT NULL,
          min_effective_volume   REAL    NOT NULL,
          max_adaptive_volume    REAL    NOT NULL,
          max_recoverable_volume REAL    NOT NULL,
          FOREIGN KEY(muscle_id) REFERENCES muscles(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS bodypart_volume_boundaries (
          bodypart_id            INTEGER PRIMARY KEY,
          maintenance_volume     REAL    NOT NULL,
          min_effective_volume   REAL    NOT NULL,
          max_adaptive_volume    REAL    NOT NULL,
          max_recoverable_volume REAL    NOT NULL,
          FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
        );
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS bodypart_muscle_rankings (
          bodypart_id   INTEGER NOT NULL,
          muscle_id     INTEGER NOT NULL,
          rank          INTEGER NOT NULL,
          PRIMARY KEY(bodypart_id, muscle_id),
          FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE,
          FOREIGN KEY(muscle_id)   REFERENCES muscles(id)    ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Migration to version 10: adds formula_settings.
  static Future<void> migrateV10(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS formula_settings (
        key   TEXT    PRIMARY KEY,
        value REAL    NOT NULL
      );
    ''');
  }

  /// Migration to version 11: adds automatic‐preset tables.
  static Future<void> migrateV11(Database db) async {
    await db.transaction((txn) async {
      // 1) Global settings for each preset
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_auto_settings (
          preset_id        INTEGER PRIMARY KEY,
          is_automatic     INTEGER NOT NULL DEFAULT 0,
          global_increment REAL    NOT NULL DEFAULT 5,
          skip_first_set   INTEGER NOT NULL DEFAULT 1,
          weight_check    INTEGER NOT NULL DEFAULT 1,
          rep_check       INTEGER NOT NULL DEFAULT 1,
          volume_check    INTEGER NOT NULL DEFAULT 0,
          adjust_all_sets INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(preset_id) REFERENCES preset_definitions(id) ON DELETE CASCADE
        );
      ''');

      // 2) Per‐exercise overrides + rotation pointer
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_exercise_auto (
          preset_exercise_id INTEGER PRIMARY KEY,
          increment_amount   REAL,
          last_set_index     INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY(preset_exercise_id)
            REFERENCES preset_exercises(id) ON DELETE CASCADE
        );
      ''');

      // 3) Per‐set overrides
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preset_set_auto (
          preset_set_id    INTEGER PRIMARY KEY,
          increment_amount REAL,
          FOREIGN KEY(preset_set_id)
            REFERENCES preset_sets(id) ON DELETE CASCADE
        );
      ''');
    });
  }

  /// Migration to version 12: flow‐chart persistence
  static Future<void> migrateV12(Database db) async {
    await db.transaction((txn) async {
      // 1) Add JSON column to hold the graph
      await txn.execute('''
      ALTER TABLE preset_auto_settings
        ADD COLUMN flow_definition TEXT NOT NULL DEFAULT '{}';
    ''');

      // 2) Create table for reusable methods
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_flow_methods (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id        INTEGER NOT NULL,
        name             TEXT    NOT NULL,
        type             TEXT    NOT NULL,  -- 'weight','rep','addSet','delSet'
        params           TEXT    NOT NULL,  -- JSON blob
        FOREIGN KEY(preset_id)
          REFERENCES preset_auto_settings(preset_id) ON DELETE CASCADE,
        UNIQUE(preset_id, name)
      );
    ''');
    });
  }

  /// Migration to version 13: add last_node to per-exercise auto table.
  static Future<void> migrateV13(Database db) async {
    await db.transaction((txn) async {
      // Add last_node TEXT if not already present
      final cols = await txn.rawQuery(
        "PRAGMA table_info('preset_exercise_auto')",
      );
      final hasLastNode = cols.any((c) => c['name'] == 'last_node');
      if (!hasLastNode) {
        await txn.execute(
          "ALTER TABLE preset_exercise_auto ADD COLUMN last_node TEXT;",
        );
      }
    });
  }

  static Future<void> migrateV14(Database db) async {
    await db.execute('''
    ALTER TABLE preset_auto_settings
      ADD COLUMN use_manual_select INTEGER NOT NULL DEFAULT 0;
  ''');
    await db.execute('''
    ALTER TABLE preset_auto_settings
      ADD COLUMN manual_selection_json TEXT;
  ''');
  }

  /// Migration to version 15: per‐exercise body-part % overrides
  static Future<void> migrateV15(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_bodypart_percent (
      exercise_def_id INTEGER NOT NULL,
      bodypart_id     INTEGER NOT NULL,
      percent         REAL    NOT NULL,
      PRIMARY KEY(exercise_def_id, bodypart_id),
      FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
      FOREIGN KEY(bodypart_id)     REFERENCES bodypart(id)           ON DELETE CASCADE
    );
  ''');
    await db.execute('''
    ALTER TABLE exercise_definitions
  ADD COLUMN use_manual_bodyparts INTEGER NOT NULL DEFAULT 0;
  ''');
    await db.execute('''
    ALTER TABLE exercise_definitions
  ADD COLUMN use_manual_muscles INTEGER NOT NULL DEFAULT 1;
  ''');
  }

  static Future<void> migrateV16(Database db) async {
    await db.execute("""
    ALTER TABLE exercise_definitions
      ADD COLUMN setup_notes     TEXT NOT NULL DEFAULT '';
  """);
    await db.execute("""
    ALTER TABLE exercise_definitions
      ADD COLUMN execution_notes TEXT NOT NULL DEFAULT '';
  """);
    await db.execute("""
    ALTER TABLE exercise_definitions
      ADD COLUMN tips_notes      TEXT NOT NULL DEFAULT '';
  """);
    await db.execute("""
    ALTER TABLE exercise_definitions
      ADD COLUMN multiply_by_rating INTEGER NOT NULL DEFAULT 0;
  """);
  }

  /// Migration to version 17: editable flow‐chart defaults (app & per‐profile)
  static Future<void> migrateV17(Database db) async {
    await db.transaction((txn) async {
      // 1) Table holding the JSON blob for each scope (app‐wide or per‐profile)
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS flow_defaults (
        scope       TEXT    NOT NULL,                               
        profile_id  INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,  
        flow_json   TEXT    NOT NULL,
        PRIMARY KEY(scope, profile_id)
      );
    ''');

      // 2) Table holding all the user‐defined methods attached to those defaults
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS flow_default_methods (
        scope       TEXT    NOT NULL,                               
        profile_id  INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,
        name        TEXT    NOT NULL,
        type        TEXT    NOT NULL,
        params      TEXT    NOT NULL,                              
        PRIMARY KEY(scope, profile_id, name),
        FOREIGN KEY(scope, profile_id)
          REFERENCES flow_defaults(scope, profile_id)
          ON DELETE CASCADE
      );
    ''');
    });
  }

  /// Migration to version 18: personal_info table
  static Future<void> migrateV18(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS personal_info (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        name               TEXT,
        gender             TEXT,
        dob                TEXT,
        height             TEXT,
        weight             TEXT,
        bodyfat_estimate   TEXT,
        weight_trend       TEXT,
        activity_level     TEXT
      );
    ''');
    });
  }

  /// v19 – Nutrition core: nutrients, foods, portions, per-100g nutrients, FTS
  static Future<void> migrateV19(Database db) async {
    await db.transaction((txn) async {
      // 1) Nutrient master
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS nutrients (
        id    INTEGER PRIMARY KEY,
        code  TEXT UNIQUE,
        name  TEXT NOT NULL,
        unit  TEXT NOT NULL
      );
    ''');

      // 2) Foods catalog
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS foods (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        name              TEXT    NOT NULL,
        brand             TEXT,
        is_custom         INTEGER NOT NULL DEFAULT 0,
        data_source       TEXT,
        data_source_id    TEXT,
        barcode           TEXT,
        density_g_per_ml  REAL,
        is_deleted        INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      );
    ''');
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);",
      );
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_foods_barcode ON foods(barcode);",
      );

      // 3) Portion options per food
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS food_portions (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id       INTEGER NOT NULL,
        measure_name  TEXT    NOT NULL,
        gram_weight   REAL,
        ml_volume     REAL,
        is_default    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(food_id) REFERENCES foods(id) ON DELETE CASCADE
      );
    ''');
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_food_portions_food ON food_portions(food_id);",
      );

      // 4) Per-100g nutrient amounts for each food
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS food_nutrients (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id      INTEGER NOT NULL,
        nutrient_id  INTEGER NOT NULL,
        amount_per_100g REAL NOT NULL,
        UNIQUE(food_id, nutrient_id),
        FOREIGN KEY(food_id)     REFERENCES foods(id)     ON DELETE CASCADE,
        FOREIGN KEY(nutrient_id) REFERENCES nutrients(id) ON DELETE RESTRICT
      );
    ''');
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_food_nutrients_food ON food_nutrients(food_id);",
      );
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_food_nutrients_nutr ON food_nutrients(nutrient_id);",
      );

      // Try to create FTS4 only if supported.
      try {
        final hasFts4 = await _fts4Available(txn);
        if (hasFts4) {
          // First try with unicode61 + prefix
          try {
            await txn.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts
        USING fts4(
          name, brand,
          content=foods,
          tokenize=unicode61,
          prefix=2 3
        );
      """);
          } catch (_) {
            // Fallback: some devices don't ship unicode61
            await txn.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts
        USING fts4(
          name, brand,
          content=foods,
          prefix=2 3
        );
      """);
          }

          await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS foods_ai AFTER INSERT ON foods BEGIN
        INSERT INTO food_search_fts(rowid, name, brand)
        VALUES (NEW.id, COALESCE(NEW.name,''), COALESCE(NEW.brand,''));
      END;
    """);
          await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS foods_ad AFTER DELETE ON foods BEGIN
        INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
        VALUES('delete', OLD.id, COALESCE(OLD.name,''), COALESCE(OLD.brand,''));
      END;
    """);
          await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS foods_au AFTER UPDATE ON foods BEGIN
        INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
        VALUES('delete', OLD.id, COALESCE(OLD.name,''), COALESCE(OLD.brand,''));
        INSERT INTO food_search_fts(rowid, name, brand)
        VALUES (NEW.id, COALESCE(NEW.name,''), COALESCE(NEW.brand,''));
      END;
    """);
        }
      } catch (_) {
        // Silently skip; DAO can fall back to LIKE search.
      }
    });
  }

  /// v20 – Recipes & diary
  static Future<void> migrateV20(Database db) async {
    await db.transaction((txn) async {
      // 1) Recipes
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS recipes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        notes       TEXT,
        is_custom   INTEGER NOT NULL DEFAULT 1,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        updated_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      );
    ''');

      // 2) Recipe ingredients
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS recipe_ingredients (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id   INTEGER NOT NULL,
        food_id     INTEGER NOT NULL,
        portion_id  INTEGER,      -- optional (when used, client should also persist 'grams')
        quantity    REAL,         -- optional count of portions
        grams       REAL,         -- resolved mass; prefer filling this on insert
        FOREIGN KEY(recipe_id)  REFERENCES recipes(id)       ON DELETE CASCADE,
        FOREIGN KEY(food_id)    REFERENCES foods(id)         ON DELETE RESTRICT,
        FOREIGN KEY(portion_id) REFERENCES food_portions(id) ON DELETE SET NULL
      );
    ''');
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_recipe_ing_recipe ON recipe_ingredients(recipe_id);",
      );

      // 3) Food diary (per profile)
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS diary_entries (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id  INTEGER NOT NULL,
        date        TEXT    NOT NULL,   -- 'YYYY-MM-DD' in local tz
        meal_type   INTEGER NOT NULL,   -- 0=breakfast,1=lunch,2=dinner,3=snack
        food_id     INTEGER,
        recipe_id   INTEGER,
        portion_id  INTEGER,
        quantity    REAL    NOT NULL DEFAULT 1.0,
        grams       REAL,               -- resolved mass at insert time (stable)
        notes       TEXT,
        FOREIGN KEY(profile_id) REFERENCES gym_profiles(id)  ON DELETE CASCADE,
        FOREIGN KEY(food_id)    REFERENCES foods(id)         ON DELETE RESTRICT,
        FOREIGN KEY(recipe_id)  REFERENCES recipes(id)       ON DELETE RESTRICT,
        FOREIGN KEY(portion_id) REFERENCES food_portions(id) ON DELETE SET NULL
      );
    ''');
      await txn.execute('''
      CREATE INDEX IF NOT EXISTS idx_diary_profile_date ON diary_entries(profile_id, date);
    ''');
    });
  }

  /// v21 – Goals, day totals cache, usage stats
  static Future<void> migrateV21(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS nutrition_goals (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id  INTEGER NOT NULL,
        start_date  TEXT    NOT NULL,
        end_date    TEXT,
        kcal_target REAL,
        protein_g   REAL,
        fat_g       REAL,
        carbs_g     REAL,
        fiber_g     REAL,
        sugar_g     REAL,
        sat_fat_g   REAL,
        sodium_mg   REAL,
        FOREIGN KEY(profile_id) REFERENCES gym_profiles(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS day_totals_cache (
        profile_id  INTEGER NOT NULL,
        date        TEXT    NOT NULL,
        kcal        REAL DEFAULT 0,
        protein_g   REAL DEFAULT 0,
        fat_g       REAL DEFAULT 0,
        carbs_g     REAL DEFAULT 0,
        fiber_g     REAL DEFAULT 0,
        sugar_g     REAL DEFAULT 0,
        sat_fat_g   REAL DEFAULT 0,
        sodium_mg   REAL DEFAULT 0,
        PRIMARY KEY(profile_id, date),
        FOREIGN KEY(profile_id) REFERENCES gym_profiles(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS food_usage_stats (
        profile_id INTEGER NOT NULL,
        food_id    INTEGER NOT NULL,
        hits       INTEGER NOT NULL DEFAULT 0,
        last_used  TEXT,
        PRIMARY KEY(profile_id, food_id),
        FOREIGN KEY(profile_id) REFERENCES gym_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(food_id)    REFERENCES foods(id)        ON DELETE RESTRICT
      );
    ''');
    });
  }

  static Future<void> migrateV22(Database db) async {
    await db.transaction((txn) async {
      // 1) Flexible nutrient values (supports per_100g, per_100ml, per_portion, absolute)
      await txn.execute("""
      CREATE TABLE IF NOT EXISTS food_nutrient_values (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id       INTEGER NOT NULL,
        nutrient_id   INTEGER NOT NULL,
        amount        REAL    NOT NULL,
        basis         TEXT    NOT NULL CHECK (basis IN ('per_100g','per_100ml','per_portion','absolute')),
        portion_id    INTEGER,        -- used when basis = 'per_portion'
        unit_override TEXT,           -- optional unit override for odd cases
        FOREIGN KEY(food_id)     REFERENCES foods(id)          ON DELETE CASCADE,
        FOREIGN KEY(nutrient_id) REFERENCES nutrients(id)      ON DELETE RESTRICT,
        FOREIGN KEY(portion_id)  REFERENCES food_portions(id)  ON DELETE SET NULL
      );
    """);

      // Uniqueness with NULL-safe portion handling
      await txn.execute("""
      CREATE UNIQUE INDEX IF NOT EXISTS ux_fnv_unique
      ON food_nutrient_values(food_id, nutrient_id, basis, COALESCE(portion_id, -1));
    """);

      // Helpful indexes for common reads
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_fnv_food_nutrient_basis
      ON food_nutrient_values(food_id, nutrient_id, basis);
    """);

      // One-time backfill from legacy per-100g table (safe to run multiple times)
      await txn.execute("""
      INSERT OR IGNORE INTO food_nutrient_values (food_id, nutrient_id, amount, basis)
      SELECT food_id, nutrient_id, amount_per_100g, 'per_100g'
      FROM food_nutrients;
    """);

      // 2) Optional: grouping for UI organization / ordering
      await txn.execute("""
      CREATE TABLE IF NOT EXISTS nutrient_groups (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT NOT NULL,
        parent_id INTEGER,
        sort_key  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(parent_id) REFERENCES nutrient_groups(id) ON DELETE CASCADE
      );
    """);

      await txn.execute("""
      CREATE TABLE IF NOT EXISTS nutrient_group_members (
        group_id    INTEGER NOT NULL,
        nutrient_id INTEGER NOT NULL,
        sort_key    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(group_id, nutrient_id),
        FOREIGN KEY(group_id)    REFERENCES nutrient_groups(id)  ON DELETE CASCADE,
        FOREIGN KEY(nutrient_id) REFERENCES nutrients(id)        ON DELETE CASCADE
      );
    """);

      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_ngm_group ON nutrient_group_members(group_id);
    """);
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_ngm_nutrient ON nutrient_group_members(nutrient_id);
    """);

      // 3) Optional: aliases to resolve multiple labels to the same nutrient
      await txn.execute("""
      CREATE TABLE IF NOT EXISTS nutrient_aliases (
        nutrient_id INTEGER NOT NULL,
        alias       TEXT    NOT NULL,
        PRIMARY KEY(nutrient_id, alias),
        FOREIGN KEY(nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE
      );
    """);

      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_aliases_alias ON nutrient_aliases(alias);
    """);
    });
  }

  static Future<void> migrateV23(Database db) async {
    await db.transaction((txn) async {
      Future<void> addCol(String table, String colDef) async {
        final cols = await txn.rawQuery("PRAGMA table_info('$table');");
        final name = colDef.split(' ').first;
        final exists = cols.any((c) => c['name'] == name);
        if (!exists) {
          await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
        }
      }

      await addCol('food_portions', 'list_kind TEXT');
      await addCol('food_portions', 'sort_order INTEGER NOT NULL DEFAULT 0');
      await addCol('food_portions', 'amount REAL');
      await addCol('food_portions', 'unit TEXT');
      await addCol('food_portions', 'label TEXT');

      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_food_portions_food_sort
      ON food_portions(food_id, list_kind, sort_order, id);
    """);
    });
  }

  static Future<void> migrateV24(Database db) async {
    await db.transaction((txn) async {
      // 1) Normalized lookups
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS brands (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL UNIQUE,
        manufacturer TEXT
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT NOT NULL,
        parent_id INTEGER,
        UNIQUE(name, parent_id),
        FOREIGN KEY(parent_id) REFERENCES categories(id) ON DELETE SET NULL
      );
    ''');

      // If a legacy categories table existed without parent_id, add it now.
      final catCols = await txn.rawQuery("PRAGMA table_info('categories');");
      final hasParentId = catCols.any(
        (c) => (c['name'] as String?)?.toLowerCase() == 'parent_id',
      );
      if (!hasParentId) {
        await txn.execute(
          "ALTER TABLE categories ADD COLUMN parent_id INTEGER;",
        );
      }

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS food_barcodes (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        upc     TEXT    NOT NULL UNIQUE,
        FOREIGN KEY(food_id) REFERENCES foods(id) ON DELETE CASCADE
      );
    ''');
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_food_barcodes_food ON food_barcodes(food_id);",
      );
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_food_barcodes_upc  ON food_barcodes(upc);",
      );

      // 2) Extend foods with new columns (guarded adds)
      Future<void> addCol(String table, String colDef) async {
        final cols = await txn.rawQuery("PRAGMA table_info('$table');");
        final name = colDef.split(' ').first;
        final exists = cols.any((c) => c['name'] == name);
        if (!exists) {
          await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
        }
      }

      await addCol(
        'foods',
        'brand_id INTEGER REFERENCES brands(id) ON DELETE SET NULL',
      );
      await addCol(
        'foods',
        'category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL',
      );
      await addCol('foods', 'fdc_id INTEGER');
      await addCol('foods', 'verified INTEGER NOT NULL DEFAULT 0');
      await addCol('foods', 'quality_score REAL');
      await addCol('foods', 'version INTEGER NOT NULL DEFAULT 1');
      await addCol('foods', 'preparation TEXT');
      await addCol('foods', 'edible_portion_pct REAL');
      await addCol('foods', 'yield_pct REAL');

      // 3) Helpful indexes (and partial uniqueness for fdc_id when present)
      await txn.execute(
        "CREATE INDEX  IF NOT EXISTS idx_foods_brand_id     ON foods(brand_id);",
      );
      await txn.execute(
        "CREATE INDEX  IF NOT EXISTS idx_foods_category_id  ON foods(category_id);",
      );
      await txn.execute(
        "CREATE INDEX  IF NOT EXISTS idx_foods_verified     ON foods(verified);",
      );
      // Partial unique index: only enforce uniqueness when fdc_id is not null
      await txn.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS ux_foods_fdc_id  ON foods(fdc_id) WHERE fdc_id IS NOT NULL;",
      );

      // 4) Backfill: move legacy brand names & barcodes into normalized tables (idempotent)
      await txn.execute('''
      INSERT OR IGNORE INTO brands(name)
      SELECT DISTINCT TRIM(brand) FROM foods
      WHERE brand IS NOT NULL AND TRIM(brand) <> '';
    ''');

      await txn.execute('''
      UPDATE foods
      SET brand_id = (
        SELECT id FROM brands b WHERE b.name = TRIM(foods.brand)
      )
      WHERE brand_id IS NULL AND brand IS NOT NULL AND TRIM(brand) <> '';
    ''');

      // Backfill barcodes only if the legacy foods.barcode column exists.
      final foodsCols = await txn.rawQuery("PRAGMA table_info('foods');");
      final hasBarcodeCol = foodsCols.any(
        (c) => (c['name'] as String?)?.toLowerCase() == 'barcode',
      );
      if (hasBarcodeCol) {
        await txn.execute('''
    INSERT OR IGNORE INTO food_barcodes(food_id, upc)
    SELECT id,
           REPLACE(REPLACE(TRIM(barcode), ' ', ''), '-', '')
    FROM foods
    WHERE barcode IS NOT NULL AND TRIM(barcode) <> '';
  ''');
      }

      // 5) (Optional) sanity constraints via CHECKs on new numeric fields
      // Note: SQLite won't add CHECK via ALTER on existing column; keep logical checks in app layer.
    });
  }

  static Future<void> migrateV25(Database db) async {
    await db.transaction((txn) async {
      Future<void> addCol(String table, String colDef) async {
        final cols = await txn.rawQuery("PRAGMA table_info('$table');");
        final name = colDef.split(' ').first;
        final exists = cols.any((c) => c['name'] == name);
        if (!exists) {
          await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
        }
      }

      await addCol('diary_entries', 'logged_grams REAL');

      await addCol('diary_entries', 'kcal_snapshot REAL');
      await addCol('diary_entries', 'protein_g_snapshot REAL');
      await addCol('diary_entries', 'carb_g_snapshot REAL');
      await addCol('diary_entries', 'fat_g_snapshot REAL');
      await addCol('diary_entries', 'nutrient_snapshot_json TEXT');

      // (Optional) extra index to speed daily readbacks with meal filters
      await txn.execute('''
      CREATE INDEX IF NOT EXISTS idx_diary_profile_date_meal
      ON diary_entries(profile_id, date, meal_type);
    ''');
    });
  }

  static Future<void> migrateV26(Database db) async {
    await db.transaction((txn) async {
      // Helper to (re)create a trigger safely
      Future<void> createTrigger(String name, String sql) async {
        await txn.execute("DROP TRIGGER IF EXISTS $name;");
        await txn.execute(sql);
      }

      // 1) Foods: bump updated_at on UPDATE to foods
      await createTrigger('trg_foods_set_updated_at', '''
      CREATE TRIGGER IF NOT EXISTS trg_foods_set_updated_at
      AFTER UPDATE ON foods
      WHEN NEW.updated_at <= OLD.updated_at
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.id;
      END;
    ''');

      // 2) Foods: bump updated_at when portions/nutrients/fnv change
      await createTrigger('trg_touch_food_on_portion_ins', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_portion_ins
      AFTER INSERT ON food_portions
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_portion_upd', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_portion_upd
      AFTER UPDATE ON food_portions
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_portion_del', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_portion_del
      AFTER DELETE ON food_portions
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    ''');

      await createTrigger('trg_touch_food_on_nutr_ins', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_nutr_ins
      AFTER INSERT ON food_nutrients
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_nutr_upd', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_nutr_upd
      AFTER UPDATE ON food_nutrients
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_nutr_del', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_nutr_del
      AFTER DELETE ON food_nutrients
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    ''');

      await createTrigger('trg_touch_food_on_fnv_ins', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_fnv_ins
      AFTER INSERT ON food_nutrient_values
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_fnv_upd', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_fnv_upd
      AFTER UPDATE ON food_nutrient_values
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    ''');
      await createTrigger('trg_touch_food_on_fnv_del', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_fnv_del
      AFTER DELETE ON food_nutrient_values
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    ''');

      // 3) Recipes: bump updated_at on direct update and ingredient changes
      await createTrigger('trg_recipes_set_updated_at', '''
      CREATE TRIGGER IF NOT EXISTS trg_recipes_set_updated_at
      AFTER UPDATE ON recipes
      WHEN NEW.updated_at <= OLD.updated_at
      BEGIN
        UPDATE recipes SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.id;
      END;
    ''');

      await createTrigger('trg_touch_recipe_on_ing_ins', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_ing_ins
      AFTER INSERT ON recipe_ingredients
      BEGIN
        UPDATE recipes SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.recipe_id;
      END;
    ''');
      await createTrigger('trg_touch_recipe_on_ing_upd', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_ing_upd
      AFTER UPDATE ON recipe_ingredients
      BEGIN
        UPDATE recipes SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.recipe_id;
      END;
    ''');
      await createTrigger('trg_touch_recipe_on_ing_del', '''
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_ing_del
      AFTER DELETE ON recipe_ingredients
      BEGIN
        UPDATE recipes SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.recipe_id;
      END;
    ''');
    });
  }

  static Future<void> migrateV27(Database db) async {
    await db.transaction((txn) async {
      // 1) normalized sources lookup
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS sources (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        name  TEXT NOT NULL UNIQUE
      );
    ''');

      // 2) add foods.source_id if missing
      final cols = await txn.rawQuery("PRAGMA table_info('foods');");
      final hasSourceId = cols.any((c) => c['name'] == 'source_id');
      if (!hasSourceId) {
        await txn.execute(
          "ALTER TABLE foods ADD COLUMN source_id INTEGER REFERENCES sources(id) ON DELETE SET NULL;",
        );
        await txn.execute(
          "CREATE INDEX IF NOT EXISTS idx_foods_source_id ON foods(source_id);",
        );
      }

      // 3) backfill distinct data_source values into sources
      await txn.execute('''
      INSERT OR IGNORE INTO sources(name)
      SELECT DISTINCT TRIM(COALESCE(data_source,'')) AS name
      FROM foods
      WHERE TRIM(COALESCE(data_source,'')) <> '';
    ''');

      // 4) link foods.source_id from data_source where possible
      await txn.execute('''
      UPDATE foods
SET source_id = (
  SELECT s.id    
  FROM sources s
  WHERE s.name = TRIM(COALESCE(foods.data_source,''))
)
WHERE source_id IS NULL
  AND TRIM(COALESCE(data_source,'')) <> '';
    ''');
    });
  }

  /// v28 — Diary timestamps & soft delete
  static Future<void> migrateV28(Database db) async {
    await db.transaction((txn) async {
      Future<void> addCol(String table, String colDef) async {
        final cols = await txn.rawQuery("PRAGMA table_info('$table');");
        final name = colDef.split(' ').first;
        final exists = cols.any((c) => c['name'] == name);
        if (!exists) {
          await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
        }
      }

      // Columns (nullable for legacy; app/trigger will set values)
      await addCol('diary_entries', 'logged_at INTEGER');
      await addCol('diary_entries', 'updated_at INTEGER');
      await addCol('diary_entries', 'is_deleted INTEGER NOT NULL DEFAULT 0');

      // Indexes for fast timelines / recents / live reads
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_diary_profile_logged_at
        ON diary_entries(profile_id, logged_at);
      ''');
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_diary_is_deleted
        ON diary_entries(is_deleted);
      ''');
      // Partial index for common reads (supported on modern SQLite)
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_diary_profile_date_live
        ON diary_entries(profile_id, date)
        WHERE is_deleted = 0;
      ''');

      // Triggers: set defaults on insert, bump updated_at on update.
      // Set logged_at if missing at insert
      await txn.execute('DROP TRIGGER IF EXISTS trg_diary_set_logged_at_ai;');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS trg_diary_set_logged_at_ai
        AFTER INSERT ON diary_entries
        WHEN NEW.logged_at IS NULL
        BEGIN
          UPDATE diary_entries
          SET logged_at = CAST(strftime('%s','now') AS INTEGER) * 1000
          WHERE id = NEW.id;
        END;
      ''');

      // Set updated_at if missing at insert
      await txn.execute('DROP TRIGGER IF EXISTS trg_diary_set_updated_at_ai;');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS trg_diary_set_updated_at_ai
        AFTER INSERT ON diary_entries
        WHEN NEW.updated_at IS NULL
        BEGIN
          UPDATE diary_entries
          SET updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000
          WHERE id = NEW.id;
        END;
      ''');

      // Bump updated_at on update when not advanced
      await txn.execute('DROP TRIGGER IF EXISTS trg_diary_bump_updated_at_au;');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS trg_diary_bump_updated_at_au
        AFTER UPDATE ON diary_entries
        WHEN NEW.updated_at IS NULL OR NEW.updated_at <= OLD.updated_at
        BEGIN
          UPDATE diary_entries
          SET updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000
          WHERE id = NEW.id;
        END;
      ''');

      // Backfill: initialize logged_at from existing local day (use local NOON to avoid DST issues)
      await txn.execute('''
  UPDATE diary_entries
  SET logged_at = CAST(strftime('%s', date || ' 12:00:00') AS INTEGER) * 1000
  WHERE logged_at IS NULL;
''');
    });
  }

  /// v29 — Entry tags
  static Future<void> migrateV29(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS diary_entry_tags (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          entry_id   INTEGER NOT NULL,
          tag        TEXT    NOT NULL,
          created_at INTEGER,
          FOREIGN KEY(entry_id) REFERENCES diary_entries(id) ON DELETE CASCADE
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_det_entry ON diary_entry_tags(entry_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_det_tag   ON diary_entry_tags(tag);',
      );
      await txn.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS ux_det_entry_tag ON diary_entry_tags(entry_id, tag);',
      );

      // Optional: default created_at
      await txn.execute('DROP TRIGGER IF EXISTS trg_det_set_created_at_ai;');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS trg_det_set_created_at_ai
        AFTER INSERT ON diary_entry_tags
        WHEN NEW.created_at IS NULL
        BEGIN
          UPDATE diary_entry_tags
          SET created_at = CAST(strftime('%s','now') AS INTEGER) * 1000
          WHERE id = NEW.id;
        END;
      ''');
    });
  }

  /// v30 — Recipe nutrient cache (per-100g by code)
  static Future<void> migrateV30(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS recipe_nutrients (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          recipe_id  INTEGER NOT NULL,
          code       TEXT    NOT NULL,
          per_100g   REAL    NOT NULL,
          UNIQUE(recipe_id, code),
          FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_rnut_recipe ON recipe_nutrients(recipe_id);',
      );
    });
  }

  /// v31 — Favorites (per profile)
  static Future<void> migrateV31(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS favorite_foods (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          profile_id  INTEGER NOT NULL,
          food_id     INTEGER NOT NULL,
          created_at  INTEGER,
          UNIQUE(profile_id, food_id),
          FOREIGN KEY(profile_id) REFERENCES gym_profiles(id) ON DELETE CASCADE,
          FOREIGN KEY(food_id)    REFERENCES foods(id)        ON DELETE RESTRICT
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_fav_profile ON favorite_foods(profile_id);',
      );

      // Optional: default created_at
      await txn.execute('DROP TRIGGER IF EXISTS trg_fav_set_created_at_ai;');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS trg_fav_set_created_at_ai
        AFTER INSERT ON favorite_foods
        WHEN NEW.created_at IS NULL
        BEGIN
          UPDATE favorite_foods
          SET created_at = CAST(strftime('%s','now') AS INTEGER) * 1000
          WHERE id = NEW.id;
        END;
      ''');
    });
  }

  /// v32 — OPTIONAL: Diary audit trail
  static Future<void> migrateV32(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS diary_entry_audit (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          entry_id    INTEGER NOT NULL,
          action      TEXT    NOT NULL,  -- 'create'|'update'|'delete'|'restore'
          at          INTEGER NOT NULL,
          before_json TEXT,
          after_json  TEXT,
          FOREIGN KEY(entry_id) REFERENCES diary_entries(id) ON DELETE CASCADE
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_dea_entry ON diary_entry_audit(entry_id);',
      );
    });
  }

  // v33 — Legacy grams_override shim (transition to logged_grams)
  static Future<void> migrateV33(Database db) async {
    await db.transaction((txn) async {
      // Add column if missing
      final cols = await txn.rawQuery("PRAGMA table_info('diary_entries');");
      final hasCol = cols.any((c) => c['name'] == 'grams_override');
      if (!hasCol) {
        await txn.execute(
          "ALTER TABLE diary_entries ADD COLUMN grams_override REAL;",
        );
        // Backfill from best available source
        await txn.execute("""
        UPDATE diary_entries
        SET grams_override = COALESCE(grams_override, logged_grams, grams)
        WHERE grams_override IS NULL;
      """);
      }
    });
  }

  /// v34
  static Future<void> migrateV34(Database db) async {
    await db.transaction((txn) async {
      // 🔹 Normalize duplicate defaults: keep the smallest-id default per food
      await txn.execute("""
      UPDATE food_portions
      SET is_default = 0
      WHERE is_default = 1
        AND id NOT IN (
          SELECT MIN(id)
          FROM food_portions
          WHERE is_default = 1
          GROUP BY food_id
        );
    """);

      // 2) One default portion per food
      await txn.execute("""
      CREATE UNIQUE INDEX IF NOT EXISTS ux_food_portions_default
      ON food_portions(food_id)
      WHERE is_default = 1;
    """);

      // 3) XOR constraint for diary entries
      await txn.execute('DROP TRIGGER IF EXISTS trg_diary_entries_xor_ai;');
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_diary_entries_xor_ai
      BEFORE INSERT ON diary_entries
      WHEN (NEW.food_id IS NULL AND NEW.recipe_id IS NULL)
        OR (NEW.food_id IS NOT NULL AND NEW.recipe_id IS NOT NULL)
      BEGIN
        SELECT RAISE(ABORT, 'Exactly one of food_id or recipe_id must be set');
      END;
    """);
      await txn.execute('DROP TRIGGER IF EXISTS trg_diary_entries_xor_au;');
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_diary_entries_xor_au
      BEFORE UPDATE ON diary_entries
      WHEN (NEW.food_id IS NULL AND NEW.recipe_id IS NULL)
        OR (NEW.food_id IS NOT NULL AND NEW.recipe_id IS NOT NULL)
      BEGIN
        SELECT RAISE(ABORT, 'Exactly one of food_id or recipe_id must be set');
      END;
    """);

      // 4) Recents performance
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_diary_profile_food_logged_at
      ON diary_entries(profile_id, food_id, logged_at);
    """);
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_diary_profile_recipe_logged_at
      ON diary_entries(profile_id, recipe_id, logged_at);
    """);

      // 5) Optional: barcode edits bump foods.updated_at
      await txn.execute(
        'DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_ins;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_ins
      AFTER INSERT ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    """);
      await txn.execute(
        'DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_del;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_del
      AFTER DELETE ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    """);
    });
  }

  /// v35 — Data guards & helpful indexes:
  /// - Enforce DiaryEntry.quantity > 0
  /// - Constrain DiaryEntry.meal_type to 0..3
  /// - Enforce per-portion nutrient rows have portion_id
  /// - Limit diary_entry_tags.tag length (<= 40)
  /// - Composite index for tag timelines (tag, created_at)
  static Future<void> migrateV35(Database db) async {
    await db.transaction((txn) async {
      // Small helper to (re)create triggers safely.
      Future<void> createTrigger(String name, String sql) async {
        await txn.execute('DROP TRIGGER IF EXISTS $name;');
        await txn.execute(sql);
      }

      // 1) DiaryEntry.quantity > 0
      await createTrigger('trg_diary_quantity_check_bi', '''
      CREATE TRIGGER IF NOT EXISTS trg_diary_quantity_check_bi
      BEFORE INSERT ON diary_entries
      WHEN NEW.quantity IS NULL OR NEW.quantity <= 0
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry.quantity must be > 0');
      END;
    ''');

      await createTrigger('trg_diary_quantity_check_bu', '''
      CREATE TRIGGER IF NOT EXISTS trg_diary_quantity_check_bu
      BEFORE UPDATE ON diary_entries
      WHEN NEW.quantity IS NULL OR NEW.quantity <= 0
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry.quantity must be > 0');
      END;
    ''');

      // 2) DiaryEntry.meal_type in 0..3
      await createTrigger('trg_diary_mealtype_check_bi', '''
      CREATE TRIGGER IF NOT EXISTS trg_diary_mealtype_check_bi
      BEFORE INSERT ON diary_entries
      WHEN NEW.meal_type IS NULL OR NEW.meal_type < 0 OR NEW.meal_type > 3
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry.meal_type must be 0..3');
      END;
    ''');

      await createTrigger('trg_diary_mealtype_check_bu', '''
      CREATE TRIGGER IF NOT EXISTS trg_diary_mealtype_check_bu
      BEFORE UPDATE ON diary_entries
      WHEN NEW.meal_type IS NULL OR NEW.meal_type < 0 OR NEW.meal_type > 3
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry.meal_type must be 0..3');
      END;
    ''');

      // 3) food_nutrient_values: per_portion rows require portion_id
      await createTrigger('trg_fnv_portion_required_bi', '''
      CREATE TRIGGER IF NOT EXISTS trg_fnv_portion_required_bi
      BEFORE INSERT ON food_nutrient_values
      WHEN NEW.basis = 'per_portion' AND NEW.portion_id IS NULL
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrient_values.per_portion requires portion_id');
      END;
    ''');

      await createTrigger('trg_fnv_portion_required_bu', '''
      CREATE TRIGGER IF NOT EXISTS trg_fnv_portion_required_bu
      BEFORE UPDATE ON food_nutrient_values
      WHEN NEW.basis = 'per_portion' AND NEW.portion_id IS NULL
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrient_values.per_portion requires portion_id');
      END;
    ''');

      // 4) diary_entry_tags: limit tag length (<= 40)
      await createTrigger('trg_det_tag_len_bi', '''
      CREATE TRIGGER IF NOT EXISTS trg_det_tag_len_bi
      BEFORE INSERT ON diary_entry_tags
      WHEN NEW.tag IS NULL OR length(trim(NEW.tag)) > 40
      BEGIN
        SELECT RAISE(ABORT, 'diary_entry_tags.tag must be <= 40 chars');
      END;
    ''');

      await createTrigger('trg_det_tag_len_bu', '''
      CREATE TRIGGER IF NOT EXISTS trg_det_tag_len_bu
      BEFORE UPDATE ON diary_entry_tags
      WHEN NEW.tag IS NULL OR length(trim(NEW.tag)) > 40
      BEGIN
        SELECT RAISE(ABORT, 'diary_entry_tags.tag must be <= 40 chars');
      END;
    ''');

      // 5) Helpful composite index for tag timelines (filter + sort)
      await txn.execute('''
      CREATE INDEX IF NOT EXISTS idx_det_tag_created_at
      ON diary_entry_tags(tag, created_at);
    ''');
    });
  }

  /// v36 — QoL:
  /// - Touch recipes.updated_at when recipe_nutrients change
  /// - Partial index for live recents (profile_id, logged_at) where not deleted
  static Future<void> migrateV36(Database db) async {
    await db.transaction((txn) async {
      // Touch recipes on recipe_nutrients changes
      Future<void> trig(String name, String body) async {
        await txn.execute('DROP TRIGGER IF EXISTS $name;');
        await txn.execute(body);
      }

      await trig('trg_touch_recipe_on_rnut_ins', """
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_rnut_ins
      AFTER INSERT ON recipe_nutrients
      BEGIN
        UPDATE recipes
        SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
        WHERE id = NEW.recipe_id;
      END;
    """);

      await trig('trg_touch_recipe_on_rnut_upd', """
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_rnut_upd
      AFTER UPDATE ON recipe_nutrients
      BEGIN
        UPDATE recipes
        SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
        WHERE id = NEW.recipe_id;
      END;
    """);

      await trig('trg_touch_recipe_on_rnut_del', """
      CREATE TRIGGER IF NOT EXISTS trg_touch_recipe_on_rnut_del
      AFTER DELETE ON recipe_nutrients
      BEGIN
        UPDATE recipes
        SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
        WHERE id = OLD.recipe_id;
      END;
    """);

      // Live timeline/recents: profile + time, ignoring deleted
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_diary_profile_logged_at_live
      ON diary_entries(profile_id, logged_at)
      WHERE is_deleted = 0;
    """);
    });
  }

  static Future<void> migrateV37(Database db) async {
    await db.transaction((txn) async {
      Future<void> dropCreateTrig(String name, String sql) async {
        await txn.execute("DROP TRIGGER IF EXISTS $name;");
        await txn.execute(sql);
      }

      // ──────────────────────────────────────────────────────────────────
      // 1) Keep foods.brand (TEXT) in sync with normalized brands
      //    so FTS remains correct even when only brand_id changes.
      // ──────────────────────────────────────────────────────────────────

      // After INSERT: if brand_id present, mirror brand text
      await dropCreateTrig('trg_foods_sync_brand_ai', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_sync_brand_ai
      AFTER INSERT ON foods
      WHEN NEW.brand_id IS NOT NULL
           AND COALESCE(NEW.brand,'') <> COALESCE((SELECT name FROM brands WHERE id = NEW.brand_id),'')
      BEGIN
        UPDATE foods
        SET brand = (SELECT name FROM brands WHERE id = NEW.brand_id)
        WHERE id = NEW.id;
      END;
    """);

      // After UPDATE of brand_id: mirror brand text when it actually changes
      await dropCreateTrig('trg_foods_sync_brand_au', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_sync_brand_au
      AFTER UPDATE OF brand_id ON foods
      WHEN COALESCE(NEW.brand,'') <> COALESCE((SELECT name FROM brands WHERE id = NEW.brand_id),'')
      BEGIN
        UPDATE foods
        SET brand = (SELECT name FROM brands WHERE id = NEW.brand_id)
        WHERE id = NEW.id;
      END;
    """);

      // When a brand name changes, push into all referencing foods
      await dropCreateTrig('trg_brands_cascade_name_au', """
      CREATE TRIGGER IF NOT EXISTS trg_brands_cascade_name_au
      AFTER UPDATE OF name ON brands
      BEGIN
        UPDATE foods
        SET brand = NEW.name
        WHERE brand_id = NEW.id
          AND COALESCE(brand,'') <> COALESCE(NEW.name,'');
      END;
    """);

      // One-time backfill: ensure foods.brand matches brands.name where brand_id is set
      await txn.execute("""
      UPDATE foods
      SET brand = (SELECT name FROM brands WHERE id = foods.brand_id)
      WHERE brand_id IS NOT NULL
        AND EXISTS (SELECT 1 FROM brands b WHERE b.id = foods.brand_id)
        AND COALESCE(brand,'') <> COALESCE((SELECT name FROM brands WHERE id = foods.brand_id),'');
    """);

      // Rebuild FTS only if it exists (works for FTS4 or FTS5)
      try {
        final rows = await txn.rawQuery(
          "SELECT 1 FROM sqlite_master WHERE type='table' AND name='food_search_fts' LIMIT 1;",
        );
        if (rows.isNotEmpty) {
          await txn.execute(
            "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild');",
          );
        }
      } catch (_) {
        /* ignore */
      }

      // ──────────────────────────────────────────────────────────────────
      // 2) Portion validity: require at least one converter
      //    (gram_weight OR ml_volume) on insert/update.
      // ──────────────────────────────────────────────────────────────────
      await dropCreateTrig('trg_portion_converter_req_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_portion_converter_req_bi
      BEFORE INSERT ON food_portions
      WHEN (NEW.gram_weight IS NULL OR NEW.gram_weight < 0)
        AND (NEW.ml_volume  IS NULL OR NEW.ml_volume  < 0)
      BEGIN
        SELECT RAISE(ABORT, 'food_portions requires gram_weight >= 0 or ml_volume >= 0');
      END;
    """);

      await dropCreateTrig('trg_portion_converter_req_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_portion_converter_req_bu
      BEFORE UPDATE ON food_portions
      WHEN (NEW.gram_weight IS NULL OR NEW.gram_weight < 0)
        AND (NEW.ml_volume  IS NULL OR NEW.ml_volume  < 0)
      BEGIN
        SELECT RAISE(ABORT, 'food_portions requires gram_weight >= 0 or ml_volume >= 0');
      END;
    """);

      // ──────────────────────────────────────────────────────────────────
      // 3) Nutrient value sanity: non-negative
      // ──────────────────────────────────────────────────────────────────
      await dropCreateTrig('trg_food_nutrients_nonneg_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_food_nutrients_nonneg_bi
      BEFORE INSERT ON food_nutrients
      WHEN NEW.amount_per_100g < 0
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrients.amount_per_100g must be >= 0');
      END;
    """);
      await dropCreateTrig('trg_food_nutrients_nonneg_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_food_nutrients_nonneg_bu
      BEFORE UPDATE ON food_nutrients
      WHEN NEW.amount_per_100g < 0
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrients.amount_per_100g must be >= 0');
      END;
    """);

      await dropCreateTrig('trg_fnv_nonneg_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_fnv_nonneg_bi
      BEFORE INSERT ON food_nutrient_values
      WHEN NEW.amount < 0
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrient_values.amount must be >= 0');
      END;
    """);
      await dropCreateTrig('trg_fnv_nonneg_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_fnv_nonneg_bu
      BEFORE UPDATE ON food_nutrient_values
      WHEN NEW.amount < 0
      BEGIN
        SELECT RAISE(ABORT, 'food_nutrient_values.amount must be >= 0');
      END;
    """);

      // ──────────────────────────────────────────────────────────────────
      // 4) Nutrient aliases: enforce global uniqueness (case-insensitive)
      //    Cleanup dupes first, then create a unique index on lower(alias).
      // ──────────────────────────────────────────────────────────────────
      await txn.execute("""
      DELETE FROM nutrient_aliases
      WHERE rowid NOT IN (
        SELECT MIN(rowid) FROM nutrient_aliases GROUP BY lower(alias)
      );
    """);
      await txn.execute("""
      CREATE UNIQUE INDEX IF NOT EXISTS ux_nutrient_alias_nocase
      ON nutrient_aliases(lower(alias));
    """);

      // ──────────────────────────────────────────────────────────────────
      // 5) Helpful NOCASE name index (LIKE/ORDER BY)
      // ──────────────────────────────────────────────────────────────────
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_foods_name_nocase
      ON foods(name COLLATE NOCASE);
    """);
    });
  }

  // v38 — Data hygiene, case-insensitive uniqueness, guards
  static Future<void> migrateV38(Database db) async {
    await db.transaction((txn) async {
      Future<void> trig(String name, String body) async {
        await txn.execute('DROP TRIGGER IF EXISTS $name;');
        await txn.execute(body);
      }

      // A) De-dupe brands by lower(name); keep smallest id, retarget foods.brand_id, then enforce unique(lower(name))
      await txn.execute("""
      WITH d AS (
        SELECT MIN(id) AS keep_id, lower(trim(name)) AS k
        FROM brands
        GROUP BY lower(trim(name))
      )
      UPDATE foods
      SET brand_id = (
        SELECT d.keep_id
        FROM brands b
        JOIN d ON lower(trim(b.name)) = d.k
        WHERE b.id = foods.brand_id
      )
      WHERE brand_id IS NOT NULL;
    """);
      await txn.execute("""
      DELETE FROM brands
      WHERE id NOT IN (
        SELECT keep_id FROM (
          SELECT MIN(id) AS keep_id FROM brands GROUP BY lower(trim(name))
        )
      );
    """);
      await txn.execute("""
      CREATE UNIQUE INDEX IF NOT EXISTS ux_brands_name_nocase
      ON brands(lower(name));
    """);

      // B) De-dupe categories by (lower(name), parent_id)
      //    Guard for legacy DBs that had `categories` without `parent_id`.
      final catCols = await txn.rawQuery("PRAGMA table_info('categories');");
      final hasParentId = catCols.any(
        (c) => (c['name'] as String?)?.toLowerCase() == 'parent_id',
      );
      if (!hasParentId) {
        await txn.execute(
          "ALTER TABLE categories ADD COLUMN parent_id INTEGER;",
        );
      }

      await txn.execute("""
  WITH d AS (
    SELECT MIN(id) AS keep_id, lower(trim(name)) AS k, parent_id
    FROM categories
    GROUP BY lower(trim(name)), parent_id
  )
  UPDATE foods
  SET category_id = (
    SELECT d.keep_id
    FROM categories c
    JOIN d ON lower(trim(c.name)) = d.k
          AND COALESCE(c.parent_id,-1) = COALESCE(d.parent_id,-1)
    WHERE c.id = foods.category_id
  )
  WHERE category_id IS NOT NULL;
""");

      await txn.execute("""
  DELETE FROM categories
  WHERE id NOT IN (
    SELECT keep_id FROM (
      SELECT MIN(id) AS keep_id
      FROM categories
      GROUP BY lower(trim(name)), parent_id
    )
  );
""");

      await txn.execute("""
  CREATE UNIQUE INDEX IF NOT EXISTS ux_categories_name_parent_nocase
  ON categories(lower(name), parent_id);
""");

      // C) Portion converter > 0 (tighten v37 from >= 0 to > 0)
      await trig('trg_portion_converter_req_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_portion_converter_req_bi
      BEFORE INSERT ON food_portions
      WHEN (NEW.gram_weight IS NULL OR NEW.gram_weight <= 0)
        AND (NEW.ml_volume  IS NULL OR NEW.ml_volume  <= 0)
      BEGIN
        SELECT RAISE(ABORT, 'food_portions requires gram_weight > 0 or ml_volume > 0');
      END;
    """);
      await trig('trg_portion_converter_req_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_portion_converter_req_bu
      BEFORE UPDATE ON food_portions
      WHEN (NEW.gram_weight IS NULL OR NEW.gram_weight <= 0)
        AND (NEW.ml_volume  IS NULL OR NEW.ml_volume  <= 0)
      BEGIN
        SELECT RAISE(ABORT, 'food_portions requires gram_weight > 0 or ml_volume > 0');
      END;
    """);

      // D) Recipe ingredients: require grams OR (portion_id & quantity)
      await trig('trg_recipe_ing_require_mass_or_portion_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_recipe_ing_require_mass_or_portion_bi
      BEFORE INSERT ON recipe_ingredients
      WHEN (NEW.grams IS NULL OR NEW.grams < 0)
       AND (NEW.portion_id IS NULL OR NEW.quantity IS NULL OR NEW.quantity <= 0)
      BEGIN
        SELECT RAISE(ABORT, 'recipe_ingredients requires grams >= 0 OR (portion_id AND quantity > 0)');
      END;
    """);
      await trig('trg_recipe_ing_require_mass_or_portion_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_recipe_ing_require_mass_or_portion_bu
      BEFORE UPDATE ON recipe_ingredients
      WHEN (NEW.grams IS NULL OR NEW.grams < 0)
       AND (NEW.portion_id IS NULL OR NEW.quantity IS NULL OR NEW.quantity <= 0)
      BEGIN
        SELECT RAISE(ABORT, 'recipe_ingredients requires grams >= 0 OR (portion_id AND quantity > 0)');
      END;
    """);

      // E) Diary grams non-negative
      await trig('trg_diary_nonneg_grams_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_diary_nonneg_grams_bi
      BEFORE INSERT ON diary_entries
      WHEN (NEW.grams IS NOT NULL AND NEW.grams < 0)
        OR (NEW.logged_grams IS NOT NULL AND NEW.logged_grams < 0)
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry grams must be >= 0');
      END;
    """);
      await trig('trg_diary_nonneg_grams_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_diary_nonneg_grams_bu
      BEFORE UPDATE ON diary_entries
      WHEN (NEW.grams IS NOT NULL AND NEW.grams < 0)
        OR (NEW.logged_grams IS NOT NULL AND NEW.logged_grams < 0)
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry grams must be >= 0');
      END;
    """);

      // F) Barcode length sanity (8..18) — use IGNORE to avoid log spam on bad data
      await trig('trg_barcodes_len_bi', """
  CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bi
  BEFORE INSERT ON food_barcodes
  WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
  BEGIN
    SELECT RAISE(IGNORE);
  END;
""");
      await trig('trg_barcodes_len_bu', """
  CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bu
  BEFORE UPDATE ON food_barcodes
  WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
  BEGIN
    SELECT RAISE(IGNORE);
  END;
""");

      // G) Foods numeric guardrails
      await trig('trg_foods_quality_score_guard_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_quality_score_guard_bu
      BEFORE UPDATE OF quality_score ON foods
      WHEN NEW.quality_score IS NOT NULL AND (NEW.quality_score < 0 OR NEW.quality_score > 1)
      BEGIN
        SELECT RAISE(ABORT, 'foods.quality_score must be between 0 and 1');
      END;
    """);
      await trig('trg_foods_pct_guards_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_pct_guards_bu
      BEFORE UPDATE OF edible_portion_pct, yield_pct ON foods
      WHEN (NEW.edible_portion_pct IS NOT NULL AND (NEW.edible_portion_pct < 0 OR NEW.edible_portion_pct > 100))
        OR (NEW.yield_pct IS NOT NULL AND (NEW.yield_pct < 0 OR NEW.yield_pct > 100))
      BEGIN
        SELECT RAISE(ABORT, 'foods edible_portion_pct/yield_pct must be 0..100');
      END;
    """);
      await trig('trg_foods_density_guard_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_density_guard_bu
      BEFORE UPDATE OF density_g_per_ml ON foods
      WHEN NEW.density_g_per_ml IS NOT NULL AND NEW.density_g_per_ml <= 0
      BEGIN
        SELECT RAISE(ABORT, 'foods.density_g_per_ml must be > 0');
      END;
    """);
    });
  }

  // v39 — Drop redundant indexes and tighten name search
  static Future<void> migrateV39(Database db) async {
    await db.transaction((txn) async {
      // Drop redundant explicit index on a UNIQUE column
      await txn.execute('DROP INDEX IF EXISTS idx_food_barcodes_upc;');

      // Keep NOCASE name index; drop the older plain one to save space
      await txn.execute('DROP INDEX IF EXISTS idx_foods_name;');

      // nutrient_aliases: old non-unique alias index redundant with ux_nutrient_alias_nocase
      await txn.execute('DROP INDEX IF EXISTS idx_aliases_alias;');
    });
  }

  // Add near the bottom of schema.dart, after migrateV39

  /// v40 — Consolidated:
  /// - Fix diary logged_at backfill to **local** noon for prior backfilled rows
  /// - Recreate FTS with unicode tokenizer + prefix search; rebuild & resync triggers
  /// - Helpful indexes (foods category/brand/name; fnv food/basis)
  /// - (Optional) Guard: sets.parent_set_id must reference an existing set
  static Future<void> migrateV40(Database db) async {
    await db.transaction((txn) async {
      Future<void> dropCreateTrig(String name, String sql) async {
        await txn.execute("DROP TRIGGER IF EXISTS $name;");
        await txn.execute(sql);
      }

      // ──────────────────────────────────────────────────────────────────
      // A) Diary backfill: convert prior “noon” backfill to *local* noon
      //    Only adjust rows that look like the earlier backfill at exactly 12:00.
      // ──────────────────────────────────────────────────────────────────
      await txn.execute("""
      UPDATE diary_entries
      SET logged_at = CAST(strftime('%s', date || ' 12:00:00', 'localtime') AS INTEGER) * 1000
      WHERE logged_at IS NOT NULL
        AND strftime('%H:%M', logged_at/1000, 'unixepoch') = '12:00';
    """);

      // ──────────────────────────────────────────────────────────────────
      // B) Recreate FTS (FTS4) with unicode tokenizer + short prefixes; rebuild
      {
        await txn.execute("DROP TRIGGER IF EXISTS foods_ai;");
        await txn.execute("DROP TRIGGER IF EXISTS foods_ad;");
        await txn.execute("DROP TRIGGER IF EXISTS foods_au;");
        await txn.execute("DROP TABLE IF EXISTS food_search_fts;");

        if (await _fts4Available(txn)) {
          // Try unicode61 first…
          bool created = false;
          try {
            await txn.execute("""
        CREATE VIRTUAL TABLE food_search_fts
        USING fts4(
          name, brand,
          content=foods,
          tokenize=unicode61,
          prefix=2 3
        );
      """);
            created = true;
          } catch (_) {
            // …fallback without tokenizer if it's missing on this device.
            await txn.execute("""
        CREATE VIRTUAL TABLE food_search_fts
        USING fts4(
          name, brand,
          content=foods,
          prefix=2 3
        );
      """);
            created = true;
          }

          if (created) {
            await txn.execute("""
        CREATE TRIGGER IF NOT EXISTS foods_ai
        AFTER INSERT ON foods BEGIN
          INSERT INTO food_search_fts(rowid, name, brand)
          VALUES (NEW.id, COALESCE(NEW.name,''), COALESCE(NEW.brand,''));
        END;
      """);
            await txn.execute("""
        CREATE TRIGGER IF NOT EXISTS foods_ad
        AFTER DELETE ON foods BEGIN
          INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
          VALUES('delete', OLD.id, COALESCE(OLD.name,''), COALESCE(OLD.brand,''));
        END;
      """);
            await txn.execute("""
        CREATE TRIGGER IF NOT EXISTS foods_au
        AFTER UPDATE ON foods BEGIN
          INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
          VALUES('delete', OLD.id, COALESCE(OLD.name,''), COALESCE(OLD.brand,''));
          INSERT INTO food_search_fts(rowid, name, brand)
          VALUES (NEW.id, COALESCE(NEW.name,''), COALESCE(NEW.brand,''));
        END;
      """);

            // Rebuild/optimize are supported on FTS3/4.
            try {
              await txn.execute(
                "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild');",
              );
            } catch (_) {}
            try {
              await txn.execute(
                "INSERT INTO food_search_fts(food_search_fts) VALUES('optimize');",
              );
            } catch (_) {}
          }
        }
      }

      // ──────────────────────────────────────────────────────────────────
      // C) Practical indexes
      // ──────────────────────────────────────────────────────────────────
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_foods_category_brand_name
      ON foods(category_id, brand_id, name COLLATE NOCASE);
    """);
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_fnv_food_basis
      ON food_nutrient_values(food_id, basis);
    """);

      // ──────────────────────────────────────────────────────────────────
      // D) (Optional) parent_set_id guard (no FK table rebuild needed)
      //    Only create these triggers if the DB actually has a `sets` table.
      // ──────────────────────────────────────────────────────────────────
      final hasSetsTable =
          (await txn.rawQuery(
            "SELECT 1 FROM sqlite_master WHERE type='table' AND name='sets' LIMIT 1;",
          )).isNotEmpty;

      if (hasSetsTable) {
        await dropCreateTrig('trg_sets_parent_exists_bi', """
    CREATE TRIGGER IF NOT EXISTS trg_sets_parent_exists_bi
    BEFORE INSERT ON sets
    WHEN NEW.parent_set_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM sets p WHERE p.id = NEW.parent_set_id)
    BEGIN
      SELECT RAISE(ABORT, 'parent_set_id must reference an existing set');
    END;
  """);

        await dropCreateTrig('trg_sets_parent_exists_bu', """
    CREATE TRIGGER IF NOT EXISTS trg_sets_parent_exists_bu
    BEFORE UPDATE OF parent_set_id ON sets
    WHEN NEW.parent_set_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM sets p WHERE p.id = NEW.parent_set_id)
    BEGIN
      SELECT RAISE(ABORT, 'parent_set_id must reference an existing set');
    END;
  """);
      }
    });
  }

  /// v41 — Final polish:
  /// - INSERT guards for foods (quality_score, pct fields, density > 0)
  /// - Diary grams: include grams_override in non-negative checks
  /// - Index: foods(is_deleted)
  /// - Optional: ANALYZE after big dedupe runs (safe to call anytime)
  static Future<void> migrateV41(Database db) async {
    await db.transaction((txn) async {
      Future<void> trig(String name, String body) async {
        await txn.execute('DROP TRIGGER IF EXISTS $name;');
        await txn.execute(body);
      }

      // 1) Foods numeric guards on INSERT (mirror v38 UPDATE guards)
      await trig('trg_foods_quality_score_guard_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_quality_score_guard_bi
      BEFORE INSERT ON foods
      WHEN NEW.quality_score IS NOT NULL AND (NEW.quality_score < 0 OR NEW.quality_score > 1)
      BEGIN
        SELECT RAISE(ABORT, 'foods.quality_score must be between 0 and 1');
      END;
    """);
      await trig('trg_foods_pct_guards_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_pct_guards_bi
      BEFORE INSERT ON foods
      WHEN (NEW.edible_portion_pct IS NOT NULL AND (NEW.edible_portion_pct < 0 OR NEW.edible_portion_pct > 100))
        OR (NEW.yield_pct IS NOT NULL AND (NEW.yield_pct < 0 OR NEW.yield_pct > 100))
      BEGIN
        SELECT RAISE(ABORT, 'foods edible_portion_pct/yield_pct must be 0..100');
      END;
    """);
      await trig('trg_foods_density_guard_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_foods_density_guard_bi
      BEFORE INSERT ON foods
      WHEN NEW.density_g_per_ml IS NOT NULL AND NEW.density_g_per_ml <= 0
      BEGIN
        SELECT RAISE(ABORT, 'foods.density_g_per_ml must be > 0');
      END;
    """);

      // 2) Diary grams: include grams_override in non-negative checks
      await trig('trg_diary_nonneg_grams_bi', """
      CREATE TRIGGER IF NOT EXISTS trg_diary_nonneg_grams_bi
      BEFORE INSERT ON diary_entries
      WHEN (NEW.grams IS NOT NULL AND NEW.grams < 0)
        OR (NEW.logged_grams IS NOT NULL AND NEW.logged_grams < 0)
        OR (NEW.grams_override IS NOT NULL AND NEW.grams_override < 0)
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry grams must be >= 0');
      END;
    """);
      await trig('trg_diary_nonneg_grams_bu', """
      CREATE TRIGGER IF NOT EXISTS trg_diary_nonneg_grams_bu
      BEFORE UPDATE ON diary_entries
      WHEN (NEW.grams IS NOT NULL AND NEW.grams < 0)
        OR (NEW.logged_grams IS NOT NULL AND NEW.logged_grams < 0)
        OR (NEW.grams_override IS NOT NULL AND NEW.grams_override < 0)
      BEGIN
        SELECT RAISE(ABORT, 'DiaryEntry grams must be >= 0');
      END;
    """);

      // 3) Helpful index for live food reads (hide deleted)
      await txn.execute("""
      CREATE INDEX IF NOT EXISTS idx_foods_is_deleted
      ON foods(is_deleted);
    """);

      // 4) (Optional) stats update
      await txn.execute("ANALYZE;");
    });
  }

  /// v42 — Rebuild `food_barcodes` so `upc` is TEXT (preserve leading zeros),
  ///       and recreate length triggers to operate on TEXT explicitly.
  static Future<void> migrateV42(Database db) async {
    await db.transaction((txn) async {
      // Detect current column type
      String? upcType;
      final info = await txn.rawQuery("PRAGMA table_info('food_barcodes');");
      for (final r in info) {
        if ((r['name'] as String?) == 'upc') {
          upcType = (r['type'] as String?)?.toUpperCase();
          break;
        }
      }

      final needsRebuild = upcType == null || upcType != 'TEXT';
      if (needsRebuild) {
        // Build new table with TEXT upc + global uniqueness on upc
        await txn.execute('''
        CREATE TABLE IF NOT EXISTS food_barcodes_new (
          id      INTEGER PRIMARY KEY AUTOINCREMENT,
          food_id INTEGER NOT NULL,
          upc     TEXT    NOT NULL,
          UNIQUE(upc),
          FOREIGN KEY(food_id) REFERENCES foods(id) ON DELETE CASCADE
        );
      ''');

        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_food_barcodes_food_new ON food_barcodes_new(food_id);',
        );

        // Copy valid rows, forcing TEXT and filtering bad lengths
        await txn.execute('''
        INSERT OR IGNORE INTO food_barcodes_new (id, food_id, upc)
        SELECT id, food_id, trim(CAST(upc AS TEXT))
        FROM food_barcodes
        WHERE upc IS NOT NULL
          AND length(trim(CAST(upc AS TEXT))) BETWEEN 8 AND 18;
      ''');

        await txn.execute('DROP TABLE IF EXISTS food_barcodes;');
        await txn.execute(
          'ALTER TABLE food_barcodes_new RENAME TO food_barcodes;',
        );
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_food_barcodes_food ON food_barcodes(food_id);',
        );
        // no separate index on upc needed; UNIQUE(upc) creates an implicit index
      }

      // Make the barcode length triggers operate on TEXT explicitly and IGNORE bad rows
      await txn.execute('DROP TRIGGER IF EXISTS trg_barcodes_len_bi;');
      await txn.execute('DROP TRIGGER IF EXISTS trg_barcodes_len_bu;');

      await txn.execute("""
  CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bi
  BEFORE INSERT ON food_barcodes
  WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
  BEGIN
    SELECT RAISE(IGNORE);
  END;
""");
      await txn.execute("""
  CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bu
  BEFORE UPDATE ON food_barcodes
  WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
  BEGIN
    SELECT RAISE(IGNORE);
  END;
""");
    });
  }

  // v43 — Nuke legacy barcode triggers (some old builds ABORTed) and recreate safe ones
  static Future<void> migrateV43(Database db) async {
    await db.transaction((txn) async {
      // Drop every trigger currently attached to food_barcodes
      final trigs = await txn.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='trigger' AND tbl_name='food_barcodes';",
      );
      for (final t in trigs) {
        final name = t['name'] as String;
        await txn.execute("DROP TRIGGER IF EXISTS $name;");
      }

      // Guard: ignore invalid length (8..18) — never ABORT
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bi
      BEFORE INSERT ON food_barcodes
      WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
      BEGIN
        SELECT RAISE(IGNORE);
      END;
    """);
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bu
      BEFORE UPDATE ON food_barcodes
      WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
      BEGIN
        SELECT RAISE(IGNORE);
      END;
    """);

      // Keep foods.updated_at in sync when barcodes change
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_ins
      AFTER INSERT ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    """);
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_del
      AFTER DELETE ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    """);
    });
  }

  static Future<void> migrateV44(Database db) async {
    await db.transaction((txn) async {
      // 1) Remove redundant unique index (table already has UNIQUE constraint)
      await txn.execute('DROP INDEX IF EXISTS idx_ex_def_name_equipment;');

      // 2) Tighten diary tag constraint: 1..40 visible chars
      await txn.execute('DROP TRIGGER IF EXISTS trg_det_tag_len_bi;');
      await txn.execute('DROP TRIGGER IF EXISTS trg_det_tag_len_bu;');
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_det_tag_len_bi
      BEFORE INSERT ON diary_entry_tags
      WHEN NEW.tag IS NULL OR length(trim(NEW.tag)) = 0 OR length(trim(NEW.tag)) > 40
      BEGIN
        SELECT RAISE(ABORT, 'diary_entry_tags.tag must be 1..40 chars');
      END;
    """);
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_det_tag_len_bu
      BEFORE UPDATE ON diary_entry_tags
      WHEN NEW.tag IS NULL OR length(trim(NEW.tag)) = 0 OR length(trim(NEW.tag)) > 40
      BEGIN
        SELECT RAISE(ABORT, 'diary_entry_tags.tag must be 1..40 chars');
      END;
    """);

      // 3) Optional: if you're deprecating foods.barcode, drop its index
      await txn.execute('DROP INDEX IF EXISTS idx_foods_barcode;');

      // 4) Optional: helper index for parent_set lookups
      final hasSets =
          (await txn.rawQuery(
            "SELECT 1 FROM sqlite_master WHERE type='table' AND name='sets' LIMIT 1;",
          )).isNotEmpty;
      if (hasSets) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_sets_parent ON sets(parent_set_id);',
        );
      }
    });
  }

  /// v45 — Purge legacy ABORT triggers on barcodes/portions; ensure only safe triggers exist.
  /// Also add safe single-default triggers for portions (no ABORTs).
  static Future<void> migrateV45(Database db) async {
    await db.transaction((txn) async {
      // Drop any triggers on these tables that still call RAISE(ABORT|FAIL|ROLLBACK)
      Future<void> purgeAborty(String table) async {
        final rows = await txn.rawQuery(
          """
        SELECT name, sql FROM sqlite_master
        WHERE type='trigger' AND tbl_name=?
      """,
          [table],
        );
        for (final r in rows) {
          final name = (r['name'] ?? '') as String;
          final sql = ((r['sql'] ?? '') as String).toUpperCase();
          if (sql.contains('RAISE(ABORT') ||
              sql.contains('RAISE(FAIL') ||
              sql.contains('RAISE(ROLLBACK')) {
            await txn.execute('DROP TRIGGER IF EXISTS "$name";');
          }
        }
      }

      await purgeAborty('food_barcodes');
      await purgeAborty('food_portions');

      // Recreate ONLY safe barcode length guards (IGNORE bad lengths).
      await txn.execute('DROP TRIGGER IF EXISTS trg_barcodes_len_bi;');
      await txn.execute('DROP TRIGGER IF EXISTS trg_barcodes_len_bu;');
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bi
      BEFORE INSERT ON food_barcodes
      WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
      BEGIN
        SELECT RAISE(IGNORE);
      END;
    """);
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_barcodes_len_bu
      BEFORE UPDATE ON food_barcodes
      WHEN length(trim(CAST(NEW.upc AS TEXT))) < 8 OR length(trim(CAST(NEW.upc AS TEXT))) > 18
      BEGIN
        SELECT RAISE(IGNORE);
      END;
    """);

      // Keep your "touch foods.updated_at" triggers (recreate to be safe)
      await txn.execute(
        'DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_ins;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_ins
      AFTER INSERT ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    """);
      await txn.execute(
        'DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_del;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_del
      AFTER DELETE ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = OLD.food_id;
      END;
    """);

      // SAFE single-default triggers for portions (no ABORT; cooperate with your partial UNIQUE)
      await txn.execute(
        'DROP TRIGGER IF EXISTS food_portions_single_default_ai;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS food_portions_single_default_ai
      AFTER INSERT ON food_portions
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE food_portions
        SET is_default = 0
        WHERE food_id = NEW.food_id AND id != NEW.id AND is_default = 1;
      END;
    """);
      await txn.execute(
        'DROP TRIGGER IF EXISTS food_portions_single_default_au;',
      );
      await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS food_portions_single_default_au
      AFTER UPDATE OF is_default ON food_portions
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE food_portions
        SET is_default = 0
        WHERE food_id = NEW.food_id AND id != NEW.id AND is_default = 1;
      END;
    """);
    });
  }

  // v46 — Catch-up for devices that missed v6/v7 (presets + gym_profiles)
  static Future<void> migrateV46(Database db) async {
    await db.transaction((txn) async {
      // ── Ensure v7: profiles & equipment join ──────────────────────────
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS gym_profiles (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS profile_equipment (
        profile_id    INTEGER NOT NULL,
        equipment_id  INTEGER NOT NULL,
        PRIMARY KEY(profile_id, equipment_id),
        FOREIGN KEY(profile_id)   REFERENCES gym_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id)     ON DELETE CASCADE
      );
    ''');

      // ── Ensure v6: all preset tables exist (create with profile_id already present) ──
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_definitions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
        profile_id  INTEGER REFERENCES gym_profiles(id) ON DELETE SET NULL
      );
    ''');

      // If the table existed from old builds without profile_id, add it.
      final cols = await txn.rawQuery(
        "PRAGMA table_info('preset_definitions');",
      );
      final hasProfileId = cols.any((c) => c['name'] == 'profile_id');
      if (!hasProfileId) {
        await txn.execute(
          "ALTER TABLE preset_definitions ADD COLUMN profile_id INTEGER REFERENCES gym_profiles(id) ON DELETE SET NULL;",
        );
      }

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_exercises (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id         INTEGER NOT NULL,
        exercise_def_id   INTEGER,
        type              TEXT    NOT NULL,
        order_index       INTEGER NOT NULL,
        FOREIGN KEY(preset_id)       REFERENCES preset_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_sets (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id   INTEGER NOT NULL,
        weight               REAL    NOT NULL,
        reps                 INTEGER NOT NULL,
        order_index          INTEGER NOT NULL,
        parent_set_id        INTEGER,
        FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_cardio_details (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id  INTEGER NOT NULL UNIQUE,
        cardio_name         TEXT    NOT NULL,
        note                TEXT,
        planned_minutes     INTEGER NOT NULL,
        elapsed_seconds     INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_stretch_items (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_exercise_id   INTEGER NOT NULL,
        stretch_id           INTEGER,
        is_custom            INTEGER NOT NULL DEFAULT 0,
        custom_name          TEXT,
        custom_desc          TEXT,
        order_index          INTEGER NOT NULL,
        FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE,
        FOREIGN KEY(stretch_id)         REFERENCES stretch_definitions(id)
      );
    ''');

      // Uniqueness per (name, profile_id)
      await txn.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS ux_preset_name_profile
      ON preset_definitions(name, profile_id);
    ''');
    });
  }

  /// v47 — Repair sweep for out-of-sync DBs
  /// Creates critical tables if they were skipped on some devices:
  /// - Base training tables from v1 (sessions/exercises/sets/...).
  /// - Flow tables from v17 (flow_defaults / flow_default_methods).
  /// - Auto-preset tables from v11 (so createProfile never explodes).
  static Future<void> migrateV47(Database db) async {
    await db.transaction((txn) async {
      // ── v1 core (CREATE IF NOT EXISTS; safe on all DBs) ───────────────
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        date     TEXT    NOT NULL,
        duration INTEGER NOT NULL
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS equipment (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS bodypart (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS exercise_definitions (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL,
        equipment_id INTEGER,
        rating       INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id),
        UNIQUE(name, equipment_id)
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS exercise_bodypart (
        exercise_id INTEGER NOT NULL,
        bodypart_id INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, bodypart_id),
        FOREIGN KEY(exercise_id)  REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id)  REFERENCES bodypart(id)            ON DELETE CASCADE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS exercises (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id      INTEGER NOT NULL,
        exercise_def_id INTEGER,
        type            TEXT    NOT NULL,
        order_index     INTEGER NOT NULL,
        FOREIGN KEY(session_id)      REFERENCES sessions(id)            ON DELETE CASCADE,
        FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id)
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS sets (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id   INTEGER NOT NULL,
        weight        REAL    NOT NULL,
        reps          INTEGER NOT NULL,
        order_index   INTEGER NOT NULL,
        parent_set_id INTEGER,
        FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS measurement_definitions (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE,
        type TEXT    NOT NULL
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS measurements (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        def_id    INTEGER NOT NULL,
        timestamp TEXT    NOT NULL,
        value     REAL    NOT NULL,
        unit      TEXT    NOT NULL,
        note      TEXT,
        FOREIGN KEY(def_id) REFERENCES measurement_definitions(id) ON DELETE CASCADE
      );
    ''');

      // ── v11: auto-preset tables (used by createProfile on first run) ──
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_auto_settings (
        preset_id        INTEGER PRIMARY KEY,
        is_automatic     INTEGER NOT NULL DEFAULT 0,
        global_increment REAL    NOT NULL DEFAULT 5,
        skip_first_set   INTEGER NOT NULL DEFAULT 1,
        weight_check     INTEGER NOT NULL DEFAULT 1,
        rep_check        INTEGER NOT NULL DEFAULT 1,
        volume_check     INTEGER NOT NULL DEFAULT 0,
        adjust_all_sets  INTEGER NOT NULL DEFAULT 0,
        flow_definition  TEXT    NOT NULL DEFAULT '{}',
        use_manual_select INTEGER NOT NULL DEFAULT 0,
        manual_selection_json TEXT,
        FOREIGN KEY(preset_id) REFERENCES preset_definitions(id) ON DELETE CASCADE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_exercise_auto (
        preset_exercise_id INTEGER PRIMARY KEY,
        increment_amount   REAL,
        last_set_index     INTEGER NOT NULL DEFAULT 1,
        last_node          TEXT,
        FOREIGN KEY(preset_exercise_id) REFERENCES preset_exercises(id) ON DELETE CASCADE
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS preset_set_auto (
        preset_set_id    INTEGER PRIMARY KEY,
        increment_amount REAL,
        FOREIGN KEY(preset_set_id) REFERENCES preset_sets(id) ON DELETE CASCADE
      );
    ''');

      // ── v17: flow tables (the ones your crash complained about) ───────
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS flow_defaults (
        scope       TEXT    NOT NULL,
        profile_id  INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,
        flow_json   TEXT    NOT NULL,
        PRIMARY KEY(scope, profile_id)
      );
    ''');
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS flow_default_methods (
        scope       TEXT    NOT NULL,
        profile_id  INTEGER REFERENCES gym_profiles(id) ON DELETE CASCADE,
        name        TEXT    NOT NULL,
        type        TEXT    NOT NULL,
        params      TEXT    NOT NULL,
        PRIMARY KEY(scope, profile_id, name),
        FOREIGN KEY(scope, profile_id)
          REFERENCES flow_defaults(scope, profile_id) ON DELETE CASCADE
      );
    ''');
    });
  }

  /// v48 — Repair: ensure muscle + analytics lookups exist on out-of-sync DBs
  static Future<void> migrateV48(Database db) async {
    await db.transaction((txn) async {
      // -- Core muscle lookups (from v3 & v9 family) --------------------
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS muscles (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS exercise_muscle (
        exercise_id INTEGER NOT NULL,
        muscle_id   INTEGER NOT NULL,
        rank        INTEGER NOT NULL,
        PRIMARY KEY(exercise_id, rank),
        UNIQUE(exercise_id, muscle_id),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(muscle_id)   REFERENCES muscles(id)              ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS muscle_bodypart (
        muscle_id    INTEGER NOT NULL,
        bodypart_id  INTEGER NOT NULL,
        PRIMARY KEY(muscle_id, bodypart_id),
        FOREIGN KEY(muscle_id)   REFERENCES muscles(id)  ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS bodypart_ranking (
        bodypart_id INTEGER PRIMARY KEY,
        rank        INTEGER NOT NULL,
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS muscle_ranking (
        muscle_id INTEGER PRIMARY KEY,
        rank      INTEGER NOT NULL,
        FOREIGN KEY(muscle_id) REFERENCES muscles(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS exercise_muscle_percent (
        exercise_def_id INTEGER NOT NULL,
        muscle_id       INTEGER NOT NULL,
        percent         REAL    NOT NULL,
        PRIMARY KEY(exercise_def_id, muscle_id),
        FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(muscle_id)       REFERENCES muscles(id)              ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS muscle_volume_boundaries (
        muscle_id              INTEGER PRIMARY KEY,
        maintenance_volume     REAL NOT NULL,
        min_effective_volume   REAL NOT NULL,
        max_adaptive_volume    REAL NOT NULL,
        max_recoverable_volume REAL NOT NULL,
        FOREIGN KEY(muscle_id) REFERENCES muscles(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS bodypart_volume_boundaries (
        bodypart_id            INTEGER PRIMARY KEY,
        maintenance_volume     REAL NOT NULL,
        min_effective_volume   REAL NOT NULL,
        max_adaptive_volume    REAL NOT NULL,
        max_recoverable_volume REAL NOT NULL,
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE
      );
    ''');

      await txn.execute('''
      CREATE TABLE IF NOT EXISTS bodypart_muscle_rankings (
        bodypart_id INTEGER NOT NULL,
        muscle_id   INTEGER NOT NULL,
        rank        INTEGER NOT NULL,
        PRIMARY KEY(bodypart_id, muscle_id),
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id) ON DELETE CASCADE,
        FOREIGN KEY(muscle_id)   REFERENCES muscles(id)  ON DELETE CASCADE
      );
    ''');

      // Helpful indexes for common reads (idempotent)
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_exmuscle_ex ON exercise_muscle(exercise_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_exmuscle_muscle ON exercise_muscle(muscle_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_exmusclepct_ex ON exercise_muscle_percent(exercise_def_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_muscle_bodypart_m ON muscle_bodypart(muscle_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_muscle_bodypart_b ON muscle_bodypart(bodypart_id);',
      );
    });
  }

  /// v49 - Adds bodyweight training equipment used by onboarding gym profiles.
  static Future<void> migrateV49(Database db) async {
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final name in const ['Pull-Up Bar', 'Gymnastics Rings']) {
        batch.insert('equipment', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      await txn.rawInsert('''
      INSERT OR IGNORE INTO profile_equipment(profile_id, equipment_id)
      SELECT gp.id, e.id
      FROM gym_profiles gp
      CROSS JOIN equipment e
      WHERE LOWER(gp.name) = 'general'
        AND e.name IN ('Pull-Up Bar', 'Gymnastics Rings')
    ''');
    });
  }

  /// v50 - Optional starter-weight metadata for no-history generated exercises.
  static Future<void> migrateV50(Database db) async {
    Future<void> addExerciseDefinitionColumn(
      String columnName,
      String definition,
    ) async {
      final columns = await db.rawQuery(
        'PRAGMA table_info(exercise_definitions);',
      );
      final exists = columns.any((row) => row['name'] == columnName);
      if (exists) return;
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN $columnName $definition',
      );
    }

    await addExerciseDefinitionColumn('starter_load_type', 'TEXT');
    await addExerciseDefinitionColumn('starter_easy_value', 'REAL');
    await addExerciseDefinitionColumn('starter_medium_value', 'REAL');
    await addExerciseDefinitionColumn('starter_hard_value', 'REAL');
    await addExerciseDefinitionColumn(
      'starter_minimum_weight',
      'REAL NOT NULL DEFAULT 0',
    );
    await addExerciseDefinitionColumn('starter_maximum_weight', 'REAL');
    await addExerciseDefinitionColumn(
      'starter_rounding_increment',
      'REAL NOT NULL DEFAULT 5',
    );
    await addExerciseDefinitionColumn(
      'starter_unit_mode',
      "TEXT NOT NULL DEFAULT 'total'",
    );
    await addExerciseDefinitionColumn(
      'starter_confidence',
      "TEXT NOT NULL DEFAULT 'medium'",
    );
    await addExerciseDefinitionColumn(
      'starter_note',
      "TEXT NOT NULL DEFAULT ''",
    );
  }

  /// v51 - Stable preset-to-session progression links and success scope.
  static Future<void> migrateV51(Database db) async {
    Future<void> addColumn(
      String table,
      String column,
      String definition,
    ) async {
      final columns = await db.rawQuery('PRAGMA table_info($table);');
      if (columns.any((row) => row['name'] == column)) return;
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }

    await addColumn('exercises', 'source_preset_exercise_id', 'INTEGER');
    await addColumn('sets', 'source_preset_set_id', 'INTEGER');
    await addColumn(
      'preset_auto_settings',
      'success_count_mode',
      "TEXT NOT NULL DEFAULT 'set'",
    );

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_exercises_source_preset
      ON exercises(source_preset_exercise_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sets_source_preset
      ON sets(source_preset_set_id)
    ''');
  }

  /// v52 - Resumable active workouts and database-backed active plans.
  static Future<void> migrateV52(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS active_workout_draft (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          started_at TEXT NOT NULL,
          auto_preset_id INTEGER,
          payload_json TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(auto_preset_id)
            REFERENCES preset_definitions(id) ON DELETE SET NULL
        )
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS active_plans (
          profile_id INTEGER NOT NULL,
          preset_id INTEGER NOT NULL,
          activated_at TEXT NOT NULL,
          PRIMARY KEY(profile_id, preset_id),
          FOREIGN KEY(profile_id)
            REFERENCES gym_profiles(id) ON DELETE CASCADE,
          FOREIGN KEY(preset_id)
            REFERENCES preset_definitions(id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_active_plans_profile
        ON active_plans(profile_id, activated_at)
      ''');
    });
  }

  /// v53 - Source-aware creator and personal exercise allocation credits.
  ///
  /// Legacy percent tables intentionally remain in place. The resolver reads
  /// them as a compatibility source so this migration cannot change an
  /// existing user's anatomy calculations on its own.
  static Future<void> migrateV53(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_allocation_source (
          exercise_def_id INTEGER PRIMARY KEY,
          muscle_mode TEXT NOT NULL DEFAULT 'automatic'
            CHECK (muscle_mode IN ('automatic', 'user')),
          bodypart_mode TEXT NOT NULL DEFAULT 'automatic'
            CHECK (bodypart_mode IN ('automatic', 'user')),
          FOREIGN KEY(exercise_def_id)
            REFERENCES exercise_definitions(id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_allocation_creator_default (
          exercise_def_id INTEGER NOT NULL,
          dimension TEXT NOT NULL
            CHECK (dimension IN ('muscle', 'bodypart')),
          target_id INTEGER NOT NULL,
          credit REAL NOT NULL CHECK (credit >= 0),
          PRIMARY KEY(exercise_def_id, dimension, target_id),
          FOREIGN KEY(exercise_def_id)
            REFERENCES exercise_definitions(id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS exercise_allocation_user_override (
          exercise_def_id INTEGER NOT NULL,
          dimension TEXT NOT NULL
            CHECK (dimension IN ('muscle', 'bodypart')),
          target_id INTEGER NOT NULL,
          credit REAL NOT NULL CHECK (credit >= 0),
          PRIMARY KEY(exercise_def_id, dimension, target_id),
          FOREIGN KEY(exercise_def_id)
            REFERENCES exercise_definitions(id) ON DELETE CASCADE
        )
      ''');
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_exercise_allocation_creator_lookup
        ON exercise_allocation_creator_default(exercise_def_id, dimension)
      ''');
      await txn.execute('''
        CREATE INDEX IF NOT EXISTS idx_exercise_allocation_user_lookup
        ON exercise_allocation_user_override(exercise_def_id, dimension)
      ''');
    });
  }

  /// v54 - optional cloud media for shared catalog entities such as equipment
  /// and anatomy. This never changes local workout or definition data.
  static Future<void> migrateV54(Database db) async {
    await ContentDao.ensureTables(db);
  }

  /// v55 - keeps unfinished onboarding plans out of normal plan lists.
  static Future<void> migrateV55(Database db) async {
    final columns = await db.rawQuery(
      "PRAGMA table_info('preset_definitions')",
    );
    final hasDraftColumn = columns.any((row) => row['name'] == 'is_draft');
    if (!hasDraftColumn) {
      await db.execute('''
        ALTER TABLE preset_definitions
        ADD COLUMN is_draft INTEGER NOT NULL DEFAULT 0
      ''');
    }
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_preset_definitions_draft_profile
      ON preset_definitions(is_draft, profile_id, created_at)
    ''');
  }

  /// v56 - repair FTS4 synchronization triggers created with FTS5 syntax.
  static Future<void> migrateV56(Database db) async {
    await ensureFoodFtsTriggers(db);
  }

  /// Keeps the external-content FTS4 index synchronized with `foods`.
  ///
  /// FTS4 removes indexed rows with a normal DELETE. The special `'delete'`
  /// INSERT command used by older migrations belongs to FTS5 and can make an
  /// otherwise harmless food update fail with `SQL logic error`.
  static Future<void> ensureFoodFtsTriggers(DatabaseExecutor db) async {
    final ftsTable = await db.rawQuery('''
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'food_search_fts'
        AND lower(coalesce(sql, '')) LIKE '%using fts4%'
      LIMIT 1
    ''');
    if (ftsTable.isEmpty) return;

    await db.execute('DROP TRIGGER IF EXISTS foods_ai;');
    await db.execute('DROP TRIGGER IF EXISTS foods_ad;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bd;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bu;');
    await db.execute('DROP TRIGGER IF EXISTS foods_au;');

    await db.execute('''
      CREATE TRIGGER foods_ai
      AFTER INSERT ON foods BEGIN
        INSERT INTO food_search_fts(rowid, name, brand)
        VALUES (NEW.id, COALESCE(NEW.name, ''), COALESCE(NEW.brand, ''));
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER foods_bd
      BEFORE DELETE ON foods BEGIN
        DELETE FROM food_search_fts WHERE docid = OLD.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER foods_bu
      BEFORE UPDATE ON foods BEGIN
        DELETE FROM food_search_fts WHERE docid = OLD.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER foods_au
      AFTER UPDATE ON foods BEGIN
        INSERT INTO food_search_fts(rowid, name, brand)
        VALUES (NEW.id, COALESCE(NEW.name, ''), COALESCE(NEW.brand, ''));
      END;
    ''');
  }

  static Future<bool> _fts4Available(DatabaseExecutor db) async {
    // 1) Prefer compile_options (avoids "no such module" log spam)
    try {
      final opts = await db.rawQuery('PRAGMA compile_options;');
      if (opts.isNotEmpty) {
        final up = opts
            .map((r) => r.values.first.toString().toUpperCase())
            .join('|');
        if (up.contains('ENABLE_FTS4') || up.contains('ENABLE_FTS3')) {
          return true;
        }
      }
    } catch (_) {
      /* ignore and probe directly */
    }

    // 2) Definitive probe
    try {
      await db.execute(
        "CREATE VIRTUAL TABLE temp.__fts4_probe__ USING fts4(x)",
      );
      await db.execute("DROP TABLE IF EXISTS temp.__fts4_probe__");
      return true;
    } catch (_) {
      return false;
    }
  }
}
