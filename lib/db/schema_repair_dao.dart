import 'package:sqflite/sqflite.dart';

import 'database_metadata_dao.dart';
import 'seed.dart';

/// Database operations for SchemaRepair without owning a connection.
class SchemaRepairDao {
  static Future<void> ensureExerciseDefNewCols(DatabaseExecutor db) async {
    // Flags
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'use_manual_bodyparts',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN use_manual_bodyparts INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'use_manual_muscles',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN use_manual_muscles INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'multiply_by_rating',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN multiply_by_rating INTEGER NOT NULL DEFAULT 0',
      );
    }

    // Optional text fields used by your seeder
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'setup_notes',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN setup_notes TEXT',
      );
    }
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'execution_notes',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN execution_notes TEXT',
      );
    }
    if (!await DatabaseMetadataDao.tableHasColumn(
      db,
      'exercise_definitions',
      'tips_notes',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN tips_notes TEXT',
      );
    }
  }

  static Future<void> ensureExerciseJoinTables(DatabaseExecutor db) async {
    // exercise_equipment (M:N)
    if (!await DatabaseMetadataDao.tableExists(db, 'exercise_equipment')) {
      await db.execute('''
      CREATE TABLE exercise_equipment(
        exercise_id INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        PRIMARY KEY (exercise_id, equipment_id),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(equipment_id) REFERENCES equipment(id) ON DELETE RESTRICT
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exeq_exercise  ON exercise_equipment(exercise_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exeq_equipment ON exercise_equipment(equipment_id)',
      );
    }

    // exercise_bodypart (M:N)
    if (!await DatabaseMetadataDao.tableExists(db, 'exercise_bodypart')) {
      await db.execute('''
      CREATE TABLE exercise_bodypart(
        exercise_id INTEGER NOT NULL,
        bodypart_id INTEGER NOT NULL,
        PRIMARY KEY (exercise_id, bodypart_id),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(bodypart_id) REFERENCES bodypart(id)             ON DELETE RESTRICT
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exbp_exercise ON exercise_bodypart(exercise_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exbp_bodypart ON exercise_bodypart(bodypart_id)',
      );
    }

    // exercise_muscle (M:N + rank)
    if (!await DatabaseMetadataDao.tableExists(db, 'exercise_muscle')) {
      await db.execute('''
      CREATE TABLE exercise_muscle(
        exercise_id INTEGER NOT NULL,
        muscle_id   INTEGER NOT NULL,
        rank        INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (exercise_id, muscle_id),
        FOREIGN KEY(exercise_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE,
        FOREIGN KEY(muscle_id)   REFERENCES muscles(id)              ON DELETE RESTRICT
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exmu_exercise ON exercise_muscle(exercise_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exmu_muscle   ON exercise_muscle(muscle_id)',
      );
    }
  }

  static Future<void> ensureStatsTables(DatabaseExecutor db) async {
    // exercise_rep_max
    if (!await DatabaseMetadataDao.tableExists(db, 'exercise_rep_max')) {
      await db.execute('''
      CREATE TABLE exercise_rep_max(
        def_id     INTEGER NOT NULL,
        rep_count  INTEGER NOT NULL,
        timeframe  TEXT    NOT NULL,   -- e.g. 'all','y90','m12','w8'
        rm_value   REAL    NOT NULL,   -- the RM (for rep_count)
        one_erm    REAL    NOT NULL,   -- 1RM estimate
        is_erm     INTEGER NOT NULL DEFAULT 0, -- 1 if rep_count==1 entry
        PRIMARY KEY(def_id, rep_count, timeframe),
        FOREIGN KEY(def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_rm_def_time ON exercise_rep_max(def_id, timeframe)',
      );
    }

    // exercise_volume_max
    if (!await DatabaseMetadataDao.tableExists(db, 'exercise_volume_max')) {
      await db.execute('''
      CREATE TABLE exercise_volume_max(
        def_id    INTEGER NOT NULL,
        timeframe TEXT    NOT NULL,
        vm_value  REAL    NOT NULL,    -- max total volume for timeframe
        PRIMARY KEY(def_id, timeframe),
        FOREIGN KEY(def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vm_def_time ON exercise_volume_max(def_id, timeframe)',
      );
    }
  }

  static Future<void> ensureStretchLookups(Database db) async {
    // Base tables used by lookups and presets
    if (!await DatabaseMetadataDao.tableExists(db, 'stretch_definitions')) {
      await db.execute('''
      CREATE TABLE stretch_definitions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT
      );
    ''');
    }

    if (!await DatabaseMetadataDao.tableExists(db, 'stretch_bodypart')) {
      await db.execute('''
      CREATE TABLE stretch_bodypart(
        stretch_id  INTEGER NOT NULL,
        bodypart_id INTEGER NOT NULL,
        PRIMARY KEY(stretch_id, bodypart_id)
      );
    ''');
      // Optional but nice-to-have
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_stretch_bp_bp ON stretch_bodypart(bodypart_id)',
      );
    }

    // Seed if newly created / empty
    final n =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM stretch_definitions'),
        ) ??
        0;
    if (n == 0) {
      await Seed.seedStretches(db);
    }
  }

  static Future<void> ensureAutoPresetFlowTables(DatabaseExecutor db) async {
    // 1) preset_flow_methods (per-preset custom methods)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS preset_flow_methods(
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      preset_id  INTEGER NOT NULL,
      name       TEXT    NOT NULL,
      type       TEXT    NOT NULL,
      params     TEXT    NOT NULL,   -- JSON
      UNIQUE(preset_id, name)
    );
  ''');

    // 2) flow_defaults (app/profile default flow JSON)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS flow_defaults(
      scope      TEXT    NOT NULL,   -- 'app' | 'profile'
      profile_id INTEGER,
      flow_json  TEXT    NOT NULL,   -- JSON
      PRIMARY KEY(scope, profile_id)
    );
  ''');

    // 3) flow_default_methods (methods attached to defaults)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS flow_default_methods(
      scope      TEXT    NOT NULL,   -- 'app' | 'profile'
      profile_id INTEGER,
      name       TEXT    NOT NULL,
      type       TEXT    NOT NULL,
      params     TEXT    NOT NULL,   -- JSON
      PRIMARY KEY(scope, profile_id, name)
    );
  ''');

    // 4) preset_auto_settings (global preset auto/flow settings)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS preset_auto_settings(
      preset_id           INTEGER PRIMARY KEY,
      is_automatic        INTEGER NOT NULL DEFAULT 0,
      global_increment    REAL,
      skip_first_set      INTEGER NOT NULL DEFAULT 0,
      weight_check        INTEGER NOT NULL DEFAULT 1,
      rep_check           INTEGER NOT NULL DEFAULT 1,
      volume_check        INTEGER NOT NULL DEFAULT 0,
      adjust_all_sets     INTEGER NOT NULL DEFAULT 0,
      use_manual_select   INTEGER NOT NULL DEFAULT 0,
      manual_selection_json TEXT,
      flow_json           TEXT                 -- preset-level flow graph
    );
  ''');

    // 5) preset_exercise_auto (per-exercise overrides)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS preset_exercise_auto(
      preset_exercise_id INTEGER PRIMARY KEY,
      increment_amount   REAL,
      last_set_index     INTEGER NOT NULL DEFAULT 0,
      last_node          TEXT
    );
  ''');

    // 6) preset_set_auto (per-set overrides)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS preset_set_auto(
      preset_set_id    INTEGER PRIMARY KEY,
      increment_amount REAL
    );
  ''');

    // Small, helpful indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pfm_preset ON preset_flow_methods(preset_id)',
    );
  }

  static Future<void> ensureCardioTables(DatabaseExecutor db) async {
    // One row per exercise entry that represents a cardio block.
    await db.execute('''
    CREATE TABLE IF NOT EXISTS cardio_details(
      exercise_id      INTEGER PRIMARY KEY,   -- ties to your exercise row
      cardio_name      TEXT    NOT NULL,      -- e.g., "Running"
      note             TEXT,                  -- optional user note
      planned_minutes  INTEGER,               -- nullable plan
      elapsed_seconds  INTEGER NOT NULL DEFAULT 0  -- actual elapsed
      -- You can add FOREIGN KEY(exercise_id) ... if you have FK enforcement on
    );
  ''');

    // Helpful index if you ever join/filter by name
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cardio_name ON cardio_details(cardio_name)',
    );
  }

  static Future<void> ensureFormulaSettings(DatabaseExecutor db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS formula_settings (
      key   TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''');

    // Optional: seed sane defaults only if missing
    final defaults = <String, String>{
      // tweak to whatever keys your app expects:
      'one_rm_formula': 'epley', // e.g., 'epley' | 'brzycki' | 'lombardi'
      'rounding_mode': 'nearest', // 'floor' | 'ceil' | 'nearest'
      'default_timeframe': 'all', // 'all' | '90d' | etc.
    };

    for (final e in defaults.entries) {
      await db.execute(
        'INSERT OR IGNORE INTO formula_settings(key, value) VALUES(?, ?)',
        [e.key, e.value],
      );
    }

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_formula_key ON formula_settings(key)',
    );
  }

  static Future<void> ensureExerciseBodypartPercent(DatabaseExecutor db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_bodypart_percent (
      exercise_def_id INTEGER NOT NULL,
      bodypart_id     INTEGER NOT NULL,
      percent         REAL    NOT NULL,
      PRIMARY KEY (exercise_def_id, bodypart_id)
      -- Optionally add FKs if you enforce them:
      -- ,FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
      -- ,FOREIGN KEY(bodypart_id) REFERENCES bodyparts(id)
    );
  ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_ebp_def ON exercise_bodypart_percent(exercise_def_id)',
    );
  }

  static Future<void> ensureExerciseMediaTable(DatabaseExecutor db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_media (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_def_id INTEGER NOT NULL,
      media_type TEXT NOT NULL,
      remote_url TEXT NOT NULL,
      thumbnail_url TEXT,
      local_cache_path TEXT,
      local_thumbnail_path TEXT,
      title TEXT,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY(exercise_def_id) REFERENCES exercise_definitions(id) ON DELETE CASCADE
    );
  ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_exercise_media_def_sort ON exercise_media(exercise_def_id, sort_order, id)',
    );
  }

  static Future<void> addColumnIfMissing(
    DatabaseExecutor db, {
    required String table,
    required String column,
    required String typeAndDefaultSql, // e.g. 'REAL NOT NULL DEFAULT 0'
  }) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    final hasCol = rows.any(
      (r) => (r['name'] as String).toLowerCase() == column.toLowerCase(),
    );
    if (!hasCol) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $typeAndDefaultSql;',
      );
    }
  }

  static Future<void> ensureNutritionGoalsColumns(DatabaseExecutor db) async {
    // If you prefer nullable columns, drop the "NOT NULL DEFAULT 0" bits.
    await addColumnIfMissing(
      db,
      table: 'nutrition_goals',
      column: 'protein_g',
      typeAndDefaultSql: 'REAL NOT NULL DEFAULT 0',
    );
    await addColumnIfMissing(
      db,
      table: 'nutrition_goals',
      column: 'fat_g',
      typeAndDefaultSql: 'REAL NOT NULL DEFAULT 0',
    );
    await addColumnIfMissing(
      db,
      table: 'nutrition_goals',
      column: 'carbs_g',
      typeAndDefaultSql: 'REAL NOT NULL DEFAULT 0',
    );

    // Optional: helpful index when you lookup by profile & date
    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_nutrition_goals_profile_date
    ON nutrition_goals(profile_id, start_date);
  ''');
  }

  static Future<void> ensureSchemaRepairs(DatabaseExecutor db) async {
    Future<void> addCol(
      String table,
      String name,
      String typeAndDefault,
    ) async {
      final cols = await db.rawQuery("PRAGMA table_info('$table')");
      final exists = cols.any(
        (c) => (c['name'] as String).toLowerCase() == name.toLowerCase(),
      );
      if (!exists) {
        await db.execute(
          "ALTER TABLE $table ADD COLUMN $name $typeAndDefault;",
        );
      }
    }

    // —— ensure critical tables exist (cheap if already present) ——
    Future<void> ensureTable(String sqlCreate) async => db.execute(sqlCreate);

    // Training / stretch / cardio / presets / flows
    await ensureTable("""
    CREATE TABLE IF NOT EXISTS stretch_definitions(
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, description TEXT NOT NULL
    );
  """);
    await ensureTable("""
    CREATE TABLE IF NOT EXISTS preset_flow_methods(
      id INTEGER PRIMARY KEY AUTOINCREMENT, preset_id INTEGER NOT NULL, name TEXT NOT NULL,
      type TEXT NOT NULL, params TEXT NOT NULL,
      FOREIGN KEY(preset_id) REFERENCES preset_auto_settings(preset_id) ON DELETE CASCADE,
      UNIQUE(preset_id, name)
    );
  """);
    await ensureTable("""
    CREATE TABLE IF NOT EXISTS cardio_details(
      id INTEGER PRIMARY KEY AUTOINCREMENT, exercise_id INTEGER NOT NULL UNIQUE,
      cardio_name TEXT NOT NULL, note TEXT, planned_minutes INTEGER NOT NULL,
      elapsed_seconds INTEGER NOT NULL,
      FOREIGN KEY(exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    );
  """);
    await ensureTable("""
    CREATE TABLE IF NOT EXISTS formula_settings(
      key TEXT PRIMARY KEY, value REAL NOT NULL
    );
  """);

    // —— column ensures ——
    await addCol('exercises', 'type', "TEXT NOT NULL DEFAULT 'weight'");
    await addCol('sets', 'parent_set_id', 'INTEGER');
    await addCol(
      'preset_definitions',
      'profile_id',
      'INTEGER REFERENCES gym_profiles(id) ON DELETE SET NULL',
    );
    await addCol('preset_exercise_auto', 'last_node', 'TEXT');

    await addCol(
      'preset_auto_settings',
      'flow_definition',
      "TEXT NOT NULL DEFAULT '{}'",
    );
    await addCol(
      'preset_auto_settings',
      'use_manual_select',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await addCol('preset_auto_settings', 'manual_selection_json', 'TEXT');

    await addCol(
      'exercise_definitions',
      'use_manual_bodyparts',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await addCol(
      'exercise_definitions',
      'use_manual_muscles',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await addCol(
      'exercise_definitions',
      'setup_notes',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addCol(
      'exercise_definitions',
      'execution_notes',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addCol(
      'exercise_definitions',
      'tips_notes',
      "TEXT NOT NULL DEFAULT ''",
    );
    await addCol(
      'exercise_definitions',
      'multiply_by_rating',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await addCol('exercise_definitions', 'starter_load_type', 'TEXT');
    await addCol('exercise_definitions', 'starter_easy_value', 'REAL');
    await addCol('exercise_definitions', 'starter_medium_value', 'REAL');
    await addCol('exercise_definitions', 'starter_hard_value', 'REAL');
    await addCol(
      'exercise_definitions',
      'starter_minimum_weight',
      'REAL NOT NULL DEFAULT 0',
    );
    await addCol('exercise_definitions', 'starter_maximum_weight', 'REAL');
    await addCol(
      'exercise_definitions',
      'starter_rounding_increment',
      'REAL NOT NULL DEFAULT 5',
    );
    await addCol(
      'exercise_definitions',
      'starter_unit_mode',
      "TEXT NOT NULL DEFAULT 'total'",
    );
    await addCol(
      'exercise_definitions',
      'starter_confidence',
      "TEXT NOT NULL DEFAULT 'medium'",
    );
    await addCol(
      'exercise_definitions',
      'starter_note',
      "TEXT NOT NULL DEFAULT ''",
    );

    await addCol(
      'foods',
      'brand_id',
      'INTEGER REFERENCES brands(id) ON DELETE SET NULL',
    );
    await addCol(
      'foods',
      'category_id',
      'INTEGER REFERENCES categories(id) ON DELETE SET NULL',
    );
    await addCol('foods', 'fdc_id', 'INTEGER');
    await addCol('foods', 'verified', 'INTEGER NOT NULL DEFAULT 0');
    await addCol('foods', 'quality_score', 'REAL');
    await addCol('foods', 'version', 'INTEGER NOT NULL DEFAULT 1');
    await addCol('foods', 'preparation', 'TEXT');
    await addCol('foods', 'edible_portion_pct', 'REAL');
    await addCol('foods', 'yield_pct', 'REAL');
    await addCol(
      'foods',
      'source_id',
      'INTEGER REFERENCES sources(id) ON DELETE SET NULL',
    );

    await addCol('food_portions', 'list_kind', 'TEXT');
    await addCol('food_portions', 'sort_order', 'INTEGER NOT NULL DEFAULT 0');
    await addCol('food_portions', 'amount', 'REAL');
    await addCol('food_portions', 'unit', 'TEXT');
    await addCol('food_portions', 'label', 'TEXT');

    for (final c in [
      'protein_g',
      'fat_g',
      'carbs_g',
      'fiber_g',
      'sugar_g',
      'sat_fat_g',
      'sodium_mg',
    ]) {
      await addCol('nutrition_goals', c, 'REAL');
    }

    await addCol('diary_entries', 'logged_grams', 'REAL');
    await addCol('diary_entries', 'kcal_snapshot', 'REAL');
    await addCol('diary_entries', 'protein_g_snapshot', 'REAL');
    await addCol('diary_entries', 'carb_g_snapshot', 'REAL');
    await addCol('diary_entries', 'fat_g_snapshot', 'REAL');
    await addCol('diary_entries', 'nutrient_snapshot_json', 'TEXT');
    await addCol('diary_entries', 'logged_at', 'INTEGER');
    await addCol('diary_entries', 'updated_at', 'INTEGER');
    await addCol('diary_entries', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
    await addCol('diary_entries', 'grams_override', 'REAL');
  }

  static Future<void> ensureFavoriteFoodsShape(DatabaseExecutor db) async {
    // 1) Create from scratch if missing
    final exists = await DatabaseMetadataDao.tableExists(db, 'favorite_foods');
    if (!exists) {
      await db.execute('''
      CREATE TABLE favorite_foods (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id  INTEGER NOT NULL,
        food_id     INTEGER NOT NULL,
        created_at  INTEGER,
        UNIQUE(profile_id, food_id)
      );
    ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fav_profile ON favorite_foods(profile_id);',
      );
    } else {
      // 2) Inspect current columns
      final cols = await db.rawQuery("PRAGMA table_info('favorite_foods');");
      bool hasId = cols.any((c) => (c['name'] as String?) == 'id');
      bool hasCreatedAt = cols.any(
        (c) => (c['name'] as String?) == 'created_at',
      );

      // 2a) If there’s no `id`, rebuild the table with the proper schema
      if (!hasId) {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS favorite_foods_new (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          profile_id  INTEGER NOT NULL,
          food_id     INTEGER NOT NULL,
          created_at  INTEGER,
          UNIQUE(profile_id, food_id)
        );
      ''');

        // copy rows (created_at may not exist in legacy table; COALESCE handles that)
        await db.execute('''
        INSERT OR IGNORE INTO favorite_foods_new (profile_id, food_id, created_at)
        SELECT profile_id, food_id,
               COALESCE(created_at, NULL)
        FROM favorite_foods;
      ''');

        await db.execute('DROP TABLE favorite_foods;');
        await db.execute(
          'ALTER TABLE favorite_foods_new RENAME TO favorite_foods;',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_fav_profile ON favorite_foods(profile_id);',
        );
      } else {
        // 2b) If `id` exists but `created_at` is missing, just add it
        if (!hasCreatedAt) {
          await db.execute(
            "ALTER TABLE favorite_foods ADD COLUMN created_at INTEGER;",
          );
        }
        // Ensure uniqueness even on odd legacy shapes
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_fav_profile_food ON favorite_foods(profile_id, food_id);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_fav_profile ON favorite_foods(profile_id);',
        );
      }
    }

    // 3) Recreate a safe created_at trigger (works on all shapes)
    await db.execute('DROP TRIGGER IF EXISTS trg_fav_set_created_at_ai;');
    await db.execute('''
    CREATE TRIGGER IF NOT EXISTS trg_fav_set_created_at_ai
    AFTER INSERT ON favorite_foods
    WHEN NEW.created_at IS NULL
    BEGIN
      UPDATE favorite_foods
      SET created_at = CAST(strftime('%s','now') AS INTEGER) * 1000
      WHERE id = NEW.id
         OR (id IS NULL AND profile_id = NEW.profile_id AND food_id = NEW.food_id);
    END;
  ''');
  }
}
