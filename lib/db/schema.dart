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
          created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
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
          created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
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
        created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
        updated_at        TEXT    NOT NULL DEFAULT (datetime('now'))
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
        created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
        updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
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


}
