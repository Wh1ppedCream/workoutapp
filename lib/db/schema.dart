// File: lib/db/schema.dart

import 'package:sqflite/sqflite.dart';

/// Database schema manager: handles initial schema and migrations up to v10.
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

  }

  /// Handler for onUpgrade callback.
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
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

  }

  /// Migration to version 3: adds rating, equipment/muscle tables.
  static Future<void> migrateV3(Database db) async {

    // 1) Check if 'rating' already exists
      final cols = await db.rawQuery("PRAGMA table_info('exercise_definitions')");
      final hasRating = cols.any((c) => c['name'] == 'rating');
    await db.transaction((txn) async {
      if (!hasRating) {
      await txn.execute(
        "ALTER TABLE exercise_definitions ADD COLUMN rating INTEGER NOT NULL DEFAULT 0;"
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
        "ALTER TABLE exercises ADD COLUMN type TEXT NOT NULL DEFAULT 'weight';"
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
      // gym profiles
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS gym_profiles (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          name        TEXT    NOT NULL,
          created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
        );
      ''');
      // profile_equipment join
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS profile_equipment (
          profile_id    INTEGER NOT NULL,
          equipment_id  INTEGER NOT NULL,
          PRIMARY KEY(profile_id, equipment_id),
          FOREIGN KEY(profile_id)   REFERENCES gym_profiles(id) ON DELETE CASCADE,
          FOREIGN KEY(equipment_id) REFERENCES equipment(id)     ON DELETE CASCADE
        );
      ''');
      // add profile_id to preset_definitions
      await txn.execute(
        "ALTER TABLE preset_definitions ADD COLUMN profile_id INTEGER REFERENCES gym_profiles(id) ON DELETE SET NULL;"
      );
      // 4) enforce uniqueness per (name, profile_id)
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
    final cols = await txn.rawQuery("PRAGMA table_info('preset_exercise_auto')");
    final hasLastNode = cols.any((c) => c['name'] == 'last_node');
    if (!hasLastNode) {
      await txn.execute(
        "ALTER TABLE preset_exercise_auto ADD COLUMN last_node TEXT;"
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
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);");
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_foods_barcode ON foods(barcode);");

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
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_food_portions_food ON food_portions(food_id);");

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
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_food_nutrients_food ON food_nutrients(food_id);");
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_food_nutrients_nutr ON food_nutrients(nutrient_id);");

    // Try to create FTS5 outside the transaction, only if supported.
  try {
    final opts = await txn.rawQuery('PRAGMA compile_options;'); // ✅ use txn
    final hasFts5 = opts.any((row) => row.values.first.toString().toUpperCase().contains('FTS5'));
    if (hasFts5) {
      await txn.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts
        USING fts5(name, brand, content='foods', content_rowid='id');
      ''');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS foods_ai AFTER INSERT ON foods BEGIN
          INSERT INTO food_search_fts(rowid, name, brand)
          VALUES (new.id, new.name, new.brand);
        END;
      ''');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS foods_ad AFTER DELETE ON foods BEGIN
          INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
          VALUES('delete', old.id, old.name, old.brand);
        END;
      ''');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS foods_au AFTER UPDATE ON foods BEGIN
          INSERT INTO food_search_fts(food_search_fts, rowid, name, brand)
          VALUES('delete', old.id, old.name, old.brand);
          INSERT INTO food_search_fts(rowid, name, brand)
          VALUES (new.id, new.name, new.brand);
        END;
      ''');
    }
  } catch (_) {
    // Silently skip; DAO already falls back to LIKE search.
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
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_recipe_ing_recipe ON recipe_ingredients(recipe_id);");

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
    // New columns to preserve UI details
    await txn.execute("ALTER TABLE food_portions ADD COLUMN list_kind TEXT;");
    await txn.execute("ALTER TABLE food_portions ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0;");
    await txn.execute("ALTER TABLE food_portions ADD COLUMN amount REAL;");
    await txn.execute("ALTER TABLE food_portions ADD COLUMN unit TEXT;");
    await txn.execute("ALTER TABLE food_portions ADD COLUMN label TEXT;");

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

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS food_barcodes (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        upc     TEXT    NOT NULL UNIQUE,
        FOREIGN KEY(food_id) REFERENCES foods(id) ON DELETE CASCADE
      );
    ''');
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_food_barcodes_food ON food_barcodes(food_id);");
    await txn.execute("CREATE INDEX IF NOT EXISTS idx_food_barcodes_upc  ON food_barcodes(upc);");

    // 2) Extend foods with new columns (guarded adds)
    Future<void> addCol(String table, String colDef) async {
      final cols = await txn.rawQuery("PRAGMA table_info('$table');");
      final name = colDef.split(' ').first;
      final exists = cols.any((c) => c['name'] == name);
      if (!exists) await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
    }

    await addCol('foods', 'brand_id INTEGER REFERENCES brands(id) ON DELETE SET NULL');
    await addCol('foods', 'category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL');
    await addCol('foods', 'fdc_id INTEGER');
    await addCol('foods', 'verified INTEGER NOT NULL DEFAULT 0');
    await addCol('foods', 'quality_score REAL');
    await addCol('foods', 'version INTEGER NOT NULL DEFAULT 1');
    await addCol('foods', 'preparation TEXT');
    await addCol('foods', 'edible_portion_pct REAL');
    await addCol('foods', 'yield_pct REAL');

    // 3) Helpful indexes (and partial uniqueness for fdc_id when present)
    await txn.execute("CREATE INDEX  IF NOT EXISTS idx_foods_brand_id     ON foods(brand_id);");
    await txn.execute("CREATE INDEX  IF NOT EXISTS idx_foods_category_id  ON foods(category_id);");
    await txn.execute("CREATE INDEX  IF NOT EXISTS idx_foods_verified     ON foods(verified);");
    // Partial unique index: only enforce uniqueness when fdc_id is not null
    await txn.execute("CREATE UNIQUE INDEX IF NOT EXISTS ux_foods_fdc_id  ON foods(fdc_id) WHERE fdc_id IS NOT NULL;");

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

    await txn.execute('''
      INSERT OR IGNORE INTO food_barcodes(food_id, upc)
      SELECT id, barcode FROM foods
      WHERE barcode IS NOT NULL AND TRIM(barcode) <> '';
    ''');

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
      if (!exists) await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
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
        "ALTER TABLE foods ADD COLUMN source_id INTEGER REFERENCES sources(id) ON DELETE SET NULL;"
      );
      await txn.execute(
        "CREATE INDEX IF NOT EXISTS idx_foods_source_id ON foods(source_id);"
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
        if (!exists) await txn.execute("ALTER TABLE $table ADD COLUMN $colDef;");
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

      // Backfill: initialize logged_at from existing date for legacy rows (idempotent)
      await txn.execute('''
        UPDATE diary_entries
        SET logged_at = CAST(strftime('%s', date || 'T00:00:00Z') AS INTEGER) * 1000
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

      await txn.execute('CREATE INDEX IF NOT EXISTS idx_det_entry ON diary_entry_tags(entry_id);');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_det_tag   ON diary_entry_tags(tag);');
      await txn.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_det_entry_tag ON diary_entry_tags(entry_id, tag);');

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

      await txn.execute('CREATE INDEX IF NOT EXISTS idx_rnut_recipe ON recipe_nutrients(recipe_id);');
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

      await txn.execute('CREATE INDEX IF NOT EXISTS idx_fav_profile ON favorite_foods(profile_id);');

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

      await txn.execute('CREATE INDEX IF NOT EXISTS idx_dea_entry ON diary_entry_audit(entry_id);');
    });
  }

// v33 — Legacy grams_override shim (transition to logged_grams)
static Future<void> migrateV33(Database db) async {
  await db.transaction((txn) async {
    // Add column if missing
    final cols = await txn.rawQuery("PRAGMA table_info('diary_entries');");
    final hasCol = cols.any((c) => c['name'] == 'grams_override');
    if (!hasCol) {
      await txn.execute("ALTER TABLE diary_entries ADD COLUMN grams_override REAL;");
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
    await txn.execute('DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_ins;');
    await txn.execute("""
      CREATE TRIGGER IF NOT EXISTS trg_touch_food_on_barcode_ins
      AFTER INSERT ON food_barcodes
      BEGIN
        UPDATE foods SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now') WHERE id = NEW.food_id;
      END;
    """);
    await txn.execute('DROP TRIGGER IF EXISTS trg_touch_food_on_barcode_del;');
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


}
