// File: lib/db/database_helper.dart

import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'schema.dart';
import 'seed.dart';
import 'session_dao.dart';
import 'exercise_dao.dart';
import 'exercise_history_dao.dart';
import 'set_dao.dart';
import 'cardio_dao.dart';
import 'stretch_dao.dart';
import 'definition_dao.dart';
import 'lookup_dao.dart';
import 'stats_dao.dart';
import 'analytics_dao.dart';
import 'formula_settings_dao.dart';
import 'gym_profile_dao.dart';
import 'preset_definition_dao.dart';
import 'preset_exercise_dao.dart';
import 'preset_detail_dao.dart';
import 'preset_auto_settings_dao.dart';
import 'preset_exercise_auto_dao.dart';
import 'preset_set_auto_dao.dart';
import 'preset_progression_dao.dart';
import 'preset_flow_methods_dao.dart';
import 'personal_info_dao.dart';
import 'personal_info_transaction_dao.dart';
import 'nutrition_dao.dart';
import 'content_dao.dart';
import 'database_connection.dart';
import 'database_backup_policy.dart';
import 'database_maintenance.dart';
import 'db_query_utils.dart';
import 'active_plan_dao.dart';
import 'active_workout_dao.dart';
import 'pending_workout_progression_dao.dart';
import 'preset_transaction_dao.dart';
import 'profile_transaction_dao.dart';
import 'progression_rule_propagation_dao.dart';
import 'workout_transaction_dao.dart';
import 'workout_record_events_dao.dart';
import 'exercise_allocation_dao.dart';
import '../services/exercise_allocation_resolver.dart';
import '../services/exercise_equipment_compatibility.dart';

import 'package:flutter/foundation.dart' show debugPrint;

/// Singleton helper for managing the SQLite database.
class DatabaseHelper {
  static const int _kDbVersion = 61;
  static const bool _kIntegrationTestMode = bool.fromEnvironment(
    'TONOS_INTEGRATION_TEST',
  );
  static const String _kDatabaseName = String.fromEnvironment(
    'TONOS_DATABASE_NAME',
    defaultValue: 'fitness_tracker.db',
  );
  static const String _kIntegrationTestDatabaseName =
      'tonos_integration_test.db';
  static int get currentSchemaVersion => _kDbVersion;
  static const String _kOpenTriggerResetKey = 'open_trigger_reset_v1';
  static const String _kOpenIndexEnsureKey = 'open_index_ensure_v3';
  static const String _kEmptyStarterPlanCleanupKey =
      'empty_starter_plan_cleanup_v1';
  static bool? _fts4Available;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  static Future<Database>? _dbFuture;

  Future<Database> get database {
    if (_db != null) return Future.value(_db!);
    return _dbFuture ??= _initDatabase()
        .then((db) {
          _db = db;
          return db;
        })
        .catchError((error) {
          _dbFuture = null;
          throw error;
        });
  }

  Future<Database> _initDatabase() async {
    final sw = Stopwatch()..start();

    final path = await _dbFilePath();
    final dbFile = File(path);
    final existedBeforeOpen = await dbFile.exists();
    final existingBytes = existedBeforeOpen ? await dbFile.length() : 0;
    debugPrint(
      '[db] opening ${existedBeforeOpen ? 'existing' : 'new'} database '
      '(size=${existingBytes}B)',
    );

    final db = await openDatabase(
      path,
      version: _kDbVersion,
      onConfigure: DatabaseConnection.configure,

      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        final sw = Stopwatch()..start();
        debugPrint('[db] onUpgrade $oldVersion -> $newVersion (begin)');

        await Schema.onUpgrade(db, oldVersion, newVersion);
        await _ensureAppMetaTable(db);
        await _ensureExerciseDefNewCols(db); // from previous step
        await _ensureExerciseJoinTables(db); // ← add this line
        await _ensureStatsTables(db); // ← add here
        await _ensureStretchLookups(db);
        await _ensureAutoPresetFlowTables(db); // ← add this line
        await _ensureCardioTables(db); // ← add this
        await _ensureFormulaSettings(db); // ← add
        await _ensureExerciseBodypartPercent(db); // ← add
        await _ensureExerciseMediaTable(db);
        await ContentDao.ensureTables(db);
        await _ensureNutritionGoalsColumns(db);
        await ensureSchemaRepairs(db);
        await _ensureFavoriteFoodsShape(db);

        // triggers, seeding, backfills, FTS, indexes…
        await _resetDbTriggers(db, force: true);
        await SeedBootstrap.seedMissingBlocks(
          db,
          onFoodProgress: (c) => _logProgress('foods', c),
        );
        await Seed.syncExerciseCatalogIfNeeded(db);
        await Seed.syncCreatorExerciseAllocationDefaults(db);
        await _backfillNormalizedFoodKeys(db);
        await _backfillEnergyKcalFromMacros(db);
        if (oldVersion < 22 && await _tableExists(db, 'recipes')) {
          await _rebuildAllRecipeCaches(db);
        }
        await _resetDbTriggers(db);
        await _rebuildFoodFtsIfExists(db);
        await _ensureIndexes(db);
        if (oldVersion < 61) {
          await WorkoutRecordEventsDao.rebuildAll(db);
        }

        debugPrint(
          '[db] onUpgrade $oldVersion -> $newVersion (done in ${sw.elapsedMilliseconds}ms)',
        );
      },

      // NEW:
      onOpen: (db) async {
        final sw = Stopwatch()..start();
        debugPrint('[db] onOpen (begin)');
        await _ensureAppMetaTable(db);
        await _ensureExerciseMediaTable(db);
        await ContentDao.ensureTables(db);
        await Schema.migrateV49(db);
        await Schema.migrateV50(db);
        await Schema.migrateV51(db);
        await Schema.migrateV52(db);
        await Schema.migrateV53(db);
        await Schema.migrateV54(db);
        await Schema.migrateV55(db);
        await Schema.migrateV56(db);
        await Schema.migrateV57(db);
        await Schema.migrateV58(db);
        await Schema.migrateV59(db);
        await Schema.migrateV60(db);
        await Schema.migrateV61(db);
        await Seed.syncExerciseCatalogIfNeeded(db);
        await _resetDbTriggers(db); // <—
        await _maybeCompactLegacyFoodCatalog(db);
        await _removeEmptyStarterPlans(db);
        final didSeed = await _seedFoodsIfEmpty(db); // now returns bool
        await _ensureIndexes(db); // still safe if already created
        if (!didSeed) {
          await _ensureFoodFtsReady(db);
        }
        debugPrint(
          '[db] onOpen (done in ${sw.elapsedMilliseconds}ms) - seeded: $didSeed',
        );
      },
    );
    debugPrint(
      '[db] openDatabase ready in ${sw.elapsedMilliseconds}ms '
      '(existingDb: $existedBeforeOpen)',
    );
    return db;
  }

  /// Builds initial schema and seeds all data.
  Future<void> _onCreate(Database db, int version) async {
    final sw = Stopwatch()..start();
    debugPrint('[db] onCreate -> v$version');
    final stepSw = Stopwatch();

    // 1) Create schema
    stepSw
      ..reset()
      ..start();
    await Schema.createTables(db);
    _logDbInitStep('onCreate', 'create-schema', stepSw.elapsedMilliseconds);

    stepSw
      ..reset()
      ..start();
    await _ensureAppMetaTable(db);
    await _ensureExerciseMediaTable(db);
    await ContentDao.ensureTables(db);
    _logDbInitStep('onCreate', 'ensure-meta-media', stepSw.elapsedMilliseconds);

    // 2) Triggers that are safe to have before foods seeding
    stepSw
      ..reset()
      ..start();
    await _resetDbTriggers(db);
    _logDbInitStep('onCreate', 'prepare-triggers', stepSw.elapsedMilliseconds);

    // 3) Seed only the missing blocks (lookups, stretches, analytics, nutrients, foods)
    stepSw
      ..reset()
      ..start();
    await SeedBootstrap.seedMissingBlocks(
      db,
      onFoodProgress: (c) => _logProgress('foods', c),
    );
    await Seed.syncCreatorExerciseAllocationDefaults(db);
    _logDbInitStep(
      'onCreate',
      'seed-missing-blocks',
      stepSw.elapsedMilliseconds,
    );

    // 4) Normalizations & caches (safe no-ops when nothing was seeded)
    stepSw
      ..reset()
      ..start();
    await _backfillNormalizedFoodKeys(db);
    _logDbInitStep(
      'onCreate',
      'backfill-food-keys',
      stepSw.elapsedMilliseconds,
    );
    stepSw
      ..reset()
      ..start();
    await _backfillEnergyKcalFromMacros(db);
    _logDbInitStep('onCreate', 'backfill-energy', stepSw.elapsedMilliseconds);

    await _rebuildAllRecipeCaches(db); // fresh installs won’t have cache yet
    await _rebuildFoodFtsIfExists(db); // if FTS exists, backfill it once
    await _ensureIndexes(db);

    debugPrint('[db] onCreate complete in ${sw.elapsedMilliseconds}ms');
  }

  Future<void> _ensureExerciseDefNewCols(Database db) async {
    // Flags
    if (!await _tableHasColumn(
      db,
      'exercise_definitions',
      'use_manual_bodyparts',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN use_manual_bodyparts INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _tableHasColumn(
      db,
      'exercise_definitions',
      'use_manual_muscles',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN use_manual_muscles INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _tableHasColumn(
      db,
      'exercise_definitions',
      'multiply_by_rating',
    )) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN multiply_by_rating INTEGER NOT NULL DEFAULT 0',
      );
    }

    // Optional text fields used by your seeder
    if (!await _tableHasColumn(db, 'exercise_definitions', 'setup_notes')) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN setup_notes TEXT',
      );
    }
    if (!await _tableHasColumn(db, 'exercise_definitions', 'execution_notes')) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN execution_notes TEXT',
      );
    }
    if (!await _tableHasColumn(db, 'exercise_definitions', 'tips_notes')) {
      await db.execute(
        'ALTER TABLE exercise_definitions ADD COLUMN tips_notes TEXT',
      );
    }
  }

  Future<void> _ensureExerciseJoinTables(Database db) async {
    // exercise_equipment (M:N)
    if (!await _tableExists(db, 'exercise_equipment')) {
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
    if (!await _tableExists(db, 'exercise_bodypart')) {
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
    if (!await _tableExists(db, 'exercise_muscle')) {
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

  Future<void> _ensureStatsTables(Database db) async {
    // exercise_rep_max
    if (!await _tableExists(db, 'exercise_rep_max')) {
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
    if (!await _tableExists(db, 'exercise_volume_max')) {
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

  Future<void> _ensureStretchLookups(Database db) async {
    // Base tables used by lookups and presets
    if (!await _tableExists(db, 'stretch_definitions')) {
      await db.execute('''
      CREATE TABLE stretch_definitions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT
      );
    ''');
    }

    if (!await _tableExists(db, 'stretch_bodypart')) {
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

  Future<void> _ensureAutoPresetFlowTables(Database db) async {
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

  Future<void> _ensureCardioTables(Database db) async {
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

  Future<void> _ensureFormulaSettings(Database db) async {
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

  Future<void> _ensureExerciseBodypartPercent(Database db) async {
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

  Future<void> _ensureExerciseMediaTable(Database db) async {
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

  Future<void> _addColumnIfMissing(
    Database db, {
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

  Future<void> _ensureNutritionGoalsColumns(Database db) async {
    // If you prefer nullable columns, drop the "NOT NULL DEFAULT 0" bits.
    await _addColumnIfMissing(
      db,
      table: 'nutrition_goals',
      column: 'protein_g',
      typeAndDefaultSql: 'REAL NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      table: 'nutrition_goals',
      column: 'fat_g',
      typeAndDefaultSql: 'REAL NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
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

  Future<void> ensureSchemaRepairs(Database db) async {
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

  Future<void> _ensureFavoriteFoodsShape(Database db) async {
    // 1) Create from scratch if missing
    final exists = await _tableExists(db, 'favorite_foods');
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

  // ────────────────────────────────────────────────────────────────────────────
  // BACKFILL METHODS
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _resetDbTriggers(Database db, {bool force = false}) async {
    if (!force) {
      final previous = await _getAppMeta(db, _kOpenTriggerResetKey);
      if (previous != null) {
        _logOnOpenStep('trigger-reset', 0, 'skipped ($previous)');
        return;
      }
    }

    final sw = Stopwatch()..start();
    // Drop every trigger on these tables, regardless of contents.
    const tables = [
      'foods',
      'food_portions',
      'food_barcodes',
      'food_nutrients',
      'food_nutrient_values',
      'recipes',
      'recipe_ingredients',
    ];
    final qs = sqlitePlaceholders(tables.length);

    await db.transaction((txn) async {
      final rows = await txn.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type='trigger' AND tbl_name IN ($qs)",
        tables,
      );
      for (final r in rows) {
        final name = r['name'] as String;
        await txn.execute('DROP TRIGGER IF EXISTS $name;');
      }

      // Recreate ONLY the 2 safe “single default portion” triggers.
      await txn.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_portion_single_default_ins
      AFTER INSERT ON food_portions
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE food_portions
        SET is_default = 0
        WHERE food_id = NEW.food_id AND id <> NEW.id;
      END;
    ''');

      await txn.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_portion_single_default_upd
      AFTER UPDATE OF is_default ON food_portions
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE food_portions
        SET is_default = 0
        WHERE food_id = NEW.food_id AND id <> NEW.id;
      END;
    ''');
    });

    if (!force) {
      await _setAppMeta(
        db,
        _kOpenTriggerResetKey,
        'done:${sw.elapsedMilliseconds}',
      );
      _logOnOpenStep('trigger-reset', sw.elapsedMilliseconds, 'repaired');
    }
  }

  void _logOnOpenStep(String label, int elapsedMs, String detail) {
    debugPrint('[db] onOpen step $label: ${elapsedMs}ms - $detail');
  }

  void _logDbInitStep(String phase, String label, int elapsedMs) {
    debugPrint('[db] $phase step $label: ${elapsedMs}ms');
  }

  // Log at 1, 1k, then every 5k to keep console readable.
  void _logProgress(String phase, int total) {
    if (total == 1 || total == 1000 || total % 5000 == 0) {
      debugPrint('[$phase] processed $total');
    }
  }

  Future<void> _backfillNormalizedFoodKeysTx(DatabaseExecutor ex) async {
    // 1) Brands
    await ex.execute("""
    INSERT OR IGNORE INTO brands(name)
    SELECT DISTINCT TRIM(brand)
    FROM foods
    WHERE brand IS NOT NULL AND TRIM(brand) <> '';
  """);

    await ex.execute("""
    UPDATE foods
    SET brand_id = (
      SELECT b.id FROM brands b WHERE b.name = TRIM(foods.brand)
    )
    WHERE brand_id IS NULL AND brand IS NOT NULL AND TRIM(brand) <> '';
  """);

    // 2) Barcodes (only if foods.barcode exists AND food_barcodes table exists)
    if (await _tableHasColumn(ex, 'foods', 'barcode') &&
        await _tableExists(ex, 'food_barcodes')) {
      final rows = await ex.query(
        'foods',
        columns: ['id', 'barcode'],
        where: "barcode IS NOT NULL AND TRIM(barcode) <> ''",
      );
      for (final r in rows) {
        final raw = (r['barcode'] as String?) ?? '';
        final upc = raw.replaceAll(RegExp(r'\D'), '');
        if (!_isValidEanUpc(upc)) continue;
        try {
          await ex.insert('food_barcodes', {
            'food_id': r['id'],
            'upc': upc,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        } catch (_) {
          // ignore — if some old trigger slips through, the reset on open will clean it up
        }
      }
    }

    // 3) Sources
    await ex.execute("""
    INSERT OR IGNORE INTO sources(name)
    SELECT DISTINCT TRIM(COALESCE(data_source,'')) AS name
    FROM foods
    WHERE TRIM(COALESCE(data_source,'')) <> '';
  """);

    await ex.execute("""
    UPDATE foods
    SET source_id = (
      SELECT s.id
      FROM sources s
      WHERE s.name = TRIM(COALESCE(foods.data_source,''))
    )
    WHERE source_id IS NULL
      AND TRIM(COALESCE(data_source,'')) <> '';
  """);

    // 4) Default portion pointer (only if the column exists)
    if (await _tableHasColumn(ex, 'foods', 'default_portion_id')) {
      await ex.execute("""
      UPDATE foods
      SET default_portion_id = (
        SELECT fp.id
        FROM food_portions fp
        WHERE fp.food_id = foods.id AND fp.is_default = 1
        ORDER BY fp.id
        LIMIT 1
      )
      WHERE default_portion_id IS NULL
        AND EXISTS (
          SELECT 1 FROM food_portions x
          WHERE x.food_id = foods.id AND x.is_default = 1
        );
    """);
    }

    // 5) Backfill flexible per_100g from legacy
    await ex.execute("""
    INSERT INTO food_nutrient_values(food_id, nutrient_id, amount, basis)
    SELECT fn.food_id, fn.nutrient_id, fn.amount_per_100g, 'per_100g'
    FROM food_nutrients fn
    WHERE NOT EXISTS (
      SELECT 1
      FROM food_nutrient_values v
      WHERE v.food_id = fn.food_id
        AND v.nutrient_id = fn.nutrient_id
        AND v.basis = 'per_100g'
    );
  """);
  }

  Future<void> _backfillNormalizedFoodKeys(Database db) async {
    await db.transaction((txn) async {
      await _backfillNormalizedFoodKeysTx(txn);
    });
  }

  Future<void> _rebuildFoodFtsIfExists(Database db) async {
    if (!await _hasFts4(db)) return;

    final exists = await _hasFoodFtsTable(db);

    if (!exists) return;

    try {
      await db.execute(
        "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild')",
      );
      await db.execute(
        "INSERT INTO food_search_fts(food_search_fts) VALUES('optimize')",
      );
      await _ensureFoodFtsTriggers(db);
      debugPrint('[fts4] food_search_fts rebuild+optimize done');
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _ensureFoodFtsReady(Database db) async {
    final sw = Stopwatch()..start();
    if (!await _hasFts4(db)) {
      _logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (fts4 unavailable)',
      );
      return;
    }
    if (!await _hasFoodFtsTable(db)) {
      _logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (fts table missing)',
      );
      return;
    }
    if (!await _tableExists(db, 'foods')) {
      _logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (no foods table)',
      );
      return;
    }

    try {
      await _ensureFoodFtsTriggers(db);

      final foodCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM foods'),
          ) ??
          0;
      if (foodCount == 0) {
        _logOnOpenStep(
          'fts-ready',
          sw.elapsedMilliseconds,
          'skipped (no foods)',
        );
        return;
      }

      final ftsCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM food_search_fts'),
          ) ??
          0;
      var rebuilt = false;

      // Rebuild only when the FTS table is clearly missing its catalog rows.
      // Normal INSERT/UPDATE/DELETE triggers keep it in sync after that.
      if (ftsCount == 0 || ftsCount < (foodCount * 0.9).floor()) {
        await _rebuildFoodFtsIfExists(db);
        rebuilt = true;
      }
      _logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        rebuilt
            ? 'rebuilt (foods=$foodCount, fts=$ftsCount)'
            : 'ok (foods=$foodCount, fts=$ftsCount)',
      );
    } catch (_) {
      // Search can still fall back to LIKE if FTS is unavailable or unhealthy.
      _logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'fallback (fts check failed)',
      );
    }
  }

  Future<void> _ensureFoodFtsTriggers(DatabaseExecutor db) async {
    await Schema.ensureFoodFtsTriggers(db);
  }

  Future<void> _dropFoodFtsTriggers(DatabaseExecutor db) async {
    await db.execute('DROP TRIGGER IF EXISTS foods_ai;');
    await db.execute('DROP TRIGGER IF EXISTS foods_ad;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bd;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bu;');
    await db.execute('DROP TRIGGER IF EXISTS foods_au;');
  }

  Future<bool> _hasFoodFtsTable(DatabaseExecutor db) async {
    final exists =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                "SELECT COUNT(*) FROM sqlite_master "
                "WHERE name = 'food_search_fts' "
                "AND type IN ('table','view') "
                "AND lower(coalesce(sql,'')) LIKE '%using fts4%'",
              ),
            ) ??
            0) >
        0;
    return exists;
  }

  Future<void> _ensureIndexes(Database db, {bool force = false}) async {
    if (!force) {
      final previous = await _getAppMeta(db, _kOpenIndexEnsureKey);
      if (previous != null) {
        _logOnOpenStep('ensure-indexes', 0, 'skipped ($previous)');
        return;
      }
    }

    final sw = Stopwatch()..start();
    // ── Workout sessions & exercise logs ─────────────────────────────────────
    if (await _tableExists(db, 'sessions')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_completed_at_ms '
        'ON sessions(completed_at_ms, id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_training_day '
        'ON sessions(training_day, completed_at_ms, id)',
      );
    }
    if (await _tableExists(db, 'exercises')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exercises_session_order '
        'ON exercises(session_id, order_index)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exercises_def ON exercises(exercise_def_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_exercises_def_type_session '
        'ON exercises(exercise_def_id, type, session_id)',
      );
    }
    if (await _tableExists(db, 'sets')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sets_exercise_order '
        'ON sets(exercise_id, order_index)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sets_parent ON sets(parent_set_id)',
      );
    }
    if (await _tableExists(db, 'preset_exercises')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_preset_exercises_focus '
        'ON preset_exercises(preset_id, type, exercise_def_id)',
      );
    }

    // ── Foods & lookups ───────────────────────────────────────────────────────
    if (await _tableExists(db, 'foods')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_updated_at ON foods(updated_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_name_nocase ON foods(name COLLATE NOCASE)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_is_deleted ON foods(is_deleted)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_brand_id ON foods(brand_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_category_id ON foods(category_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_source_id ON foods(source_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_foods_category_brand_name '
        'ON foods(category_id, brand_id, name COLLATE NOCASE)',
      );

      // Only if legacy column still exists in your schema
      if (await _tableHasColumn(db, 'foods', 'default_portion_id')) {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_foods_default_portion ON foods(default_portion_id)',
        );
      }
    }

    if (await _tableExists(db, 'brands')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name COLLATE NOCASE)',
      );
    }
    if (await _tableExists(db, 'sources')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sources_name ON sources(name COLLATE NOCASE)',
      );
    }
    if (await _tableExists(db, 'categories')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name COLLATE NOCASE)',
      );
    }

    // ── Portions & barcodes ───────────────────────────────────────────────────
    if (await _tableExists(db, 'food_portions')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_portions_food ON food_portions(food_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_portions_default ON food_portions(food_id, is_default)',
      );
    }
    if (await _tableExists(db, 'food_barcodes')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_barcodes_food ON food_barcodes(food_id)',
      );
    }

    // ── Nutrients (flex + lookups) ────────────────────────────────────────────
    if (await _tableExists(db, 'food_nutrient_values')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fnv_food_basis ON food_nutrient_values(food_id, basis)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fnv_food_basis_nutrient '
        'ON food_nutrient_values(food_id, basis, nutrient_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_fnv_food_basis_portion '
        'ON food_nutrient_values(food_id, basis, portion_id)',
      );
    }
    if (await _tableExists(db, 'nutrients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_nutrients_code ON nutrients(code)',
      );
    }

    // ── Recipes ───────────────────────────────────────────────────────────────
    if (await _tableExists(db, 'recipe_nutrients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_nutrients_recipe ON recipe_nutrients(recipe_id)',
      );
    }
    if (await _tableExists(db, 'recipe_ingredients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_food ON recipe_ingredients(food_id)',
      );
    }

    // ── Diary / favorites / usage / tags / day cache ─────────────────────────
    if (await _tableExists(db, 'diary_entries')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entries_profile_date '
        'ON diary_entries(profile_id, date, is_deleted)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entries_profile_logged '
        'ON diary_entries(profile_id, logged_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_food_profile '
        'ON diary_entries(profile_id, food_id, is_deleted, logged_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_recipe_profile '
        'ON diary_entries(profile_id, recipe_id, is_deleted, logged_at)',
      );
    }
    if (await _tableExists(db, 'day_totals_cache')) {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_day_totals_profile_date '
        'ON day_totals_cache(profile_id, date)',
      );
    }
    if (await _tableExists(db, 'favorite_foods')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorite_foods_profile ON favorite_foods(profile_id)',
      );
    }
    if (await _tableExists(db, 'food_usage_stats')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_usage_profile_last '
        'ON food_usage_stats(profile_id, last_used)',
      );
    }
    if (await _tableExists(db, 'diary_entry_tags')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_entry ON diary_entry_tags(entry_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_tag ON diary_entry_tags(tag)',
      );
    }

    if (!force) {
      await _setAppMeta(
        db,
        _kOpenIndexEnsureKey,
        'done:${sw.elapsedMilliseconds}',
      );
      _logOnOpenStep('ensure-indexes', sw.elapsedMilliseconds, 'ensured');
    }
  }

  Future<void> _ensureAppMetaTable(DatabaseExecutor db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS app_meta(
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''');
  }

  Future<String?> _getAppMeta(DatabaseExecutor db, String key) async {
    final rows = await db.query(
      'app_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _setAppMeta(
    DatabaseExecutor db,
    String key,
    String value,
  ) async {
    await db.insert('app_meta', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _maybeCompactLegacyFoodCatalog(Database db) async {
    final sw = Stopwatch()..start();
    if (!await _tableExists(db, 'foods')) {
      _logOnOpenStep(
        'legacy-catalog-compact',
        sw.elapsedMilliseconds,
        'skipped (no foods table)',
      );
      return;
    }

    const flagKey = 'catalog_cleanup_v1';
    final previous = await _getAppMeta(db, flagKey);
    if (previous != null) {
      _logOnOpenStep(
        'legacy-catalog-compact',
        sw.elapsedMilliseconds,
        'skipped ($previous)',
      );
      return;
    }

    final totalFoods =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM foods WHERE COALESCE(is_deleted, 0) = 0',
          ),
        ) ??
        0;
    final importedFoods =
        Sqflite.firstIntValue(
          await db.rawQuery('''
        SELECT COUNT(*)
        FROM foods
        WHERE COALESCE(is_deleted, 0) = 0
          AND COALESCE(is_custom, 0) = 0
          AND COALESCE(data_source, '') <> 'starter_local'
      '''),
        ) ??
        0;

    if (totalFoods < 500 || importedFoods < 500) {
      await _setAppMeta(db, flagKey, 'not_needed:$totalFoods:$importedFoods');
      _logOnOpenStep(
        'legacy-catalog-compact',
        sw.elapsedMilliseconds,
        'not needed (foods=$totalFoods, imported=$importedFoods)',
      );
      return;
    }

    final hasDiaryEntries = await _tableExists(db, 'diary_entries');
    final hasRecipeIngredients = await _tableExists(db, 'recipe_ingredients');
    final hasFavoriteFoods = await _tableExists(db, 'favorite_foods');
    final hasFoodUsageStats = await _tableExists(db, 'food_usage_stats');
    final hasBrands = await _tableExists(db, 'brands');
    final hasCategories = await _tableExists(db, 'categories');
    final hasSources = await _tableExists(db, 'sources');

    debugPrint(
      '[foods] compacting legacy local catalog ($totalFoods rows, $importedFoods imported)',
    );

    final deleted = await db.transaction<int>((txn) async {
      final deletePredicates = <String>[
        'COALESCE(is_custom, 0) = 0',
        "COALESCE(data_source, '') <> 'starter_local'",
      ];
      if (hasDiaryEntries) {
        deletePredicates.add('''
        id NOT IN (
          SELECT DISTINCT food_id
          FROM diary_entries
          WHERE food_id IS NOT NULL
        )
      ''');
      }
      if (hasRecipeIngredients) {
        deletePredicates.add('''
        id NOT IN (
          SELECT DISTINCT food_id
          FROM recipe_ingredients
          WHERE food_id IS NOT NULL
        )
      ''');
      }
      if (hasFavoriteFoods) {
        deletePredicates.add('''
        id NOT IN (
          SELECT DISTINCT food_id
          FROM favorite_foods
          WHERE food_id IS NOT NULL
        )
      ''');
      }
      if (hasFoodUsageStats) {
        deletePredicates.add('''
        id NOT IN (
          SELECT DISTINCT food_id
          FROM food_usage_stats
          WHERE food_id IS NOT NULL
        )
      ''');
      }

      final deleted = await txn.rawDelete('''
      DELETE FROM foods
      WHERE ${deletePredicates.join('\n        AND ')}
    ''');

      if (hasBrands) {
        await txn.execute('''
        DELETE FROM brands
        WHERE id NOT IN (
          SELECT DISTINCT brand_id
          FROM foods
          WHERE brand_id IS NOT NULL
        )
      ''');
      }
      if (hasCategories) {
        await txn.execute('''
        DELETE FROM categories
        WHERE id NOT IN (
          SELECT DISTINCT category_id
          FROM foods
          WHERE category_id IS NOT NULL
        )
      ''');
      }
      if (hasSources) {
        await txn.execute('''
        DELETE FROM sources
        WHERE id NOT IN (
          SELECT DISTINCT source_id
          FROM foods
          WHERE source_id IS NOT NULL
        )
      ''');
      }

      return deleted;
    });

    await Seed.seedFoods(
      db,
      onProgress: (c) => _logProgress('starter-foods', c),
    );
    await _backfillNormalizedFoodKeys(db);
    await _backfillEnergyKcalFromMacros(db);
    await _ensureIndexes(db);
    await _rebuildFoodFtsIfExists(db);

    final remaining =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM foods WHERE COALESCE(is_deleted, 0) = 0',
          ),
        ) ??
        0;
    await _setAppMeta(
      db,
      flagKey,
      'done:$deleted:$remaining:${sw.elapsedMilliseconds}',
    );
    debugPrint(
      '[foods] legacy catalog compacted in ${sw.elapsedMilliseconds}ms - removed: $deleted, remaining: $remaining',
    );
    _logOnOpenStep(
      'legacy-catalog-compact',
      sw.elapsedMilliseconds,
      'removed=$deleted, remaining=$remaining',
    );
  }

  Future<void> _removeEmptyStarterPlans(Database db) async {
    final sw = Stopwatch()..start();
    final previous = await _getAppMeta(db, _kEmptyStarterPlanCleanupKey);
    if (previous != null) {
      _logOnOpenStep(
        'starter-plan-cleanup',
        sw.elapsedMilliseconds,
        'skipped ($previous)',
      );
      return;
    }

    if (!await _tableExists(db, 'preset_definitions')) {
      await _setAppMeta(
        db,
        _kEmptyStarterPlanCleanupKey,
        'skipped:no-table:${sw.elapsedMilliseconds}',
      );
      _logOnOpenStep(
        'starter-plan-cleanup',
        sw.elapsedMilliseconds,
        'skipped (no preset table)',
      );
      return;
    }

    final hasExercisesTable = await _tableExists(db, 'preset_exercises');
    const legacyNames = <String>[
      'plan 1',
      'plan 2',
      'preset 1',
      'preset 2',
      'plan1',
      'plan2',
      'preset1',
      'preset2',
    ];
    final placeholders = List.filled(legacyNames.length, '?').join(', ');
    final emptyPresetGuard =
        hasExercisesTable
            ? '''
              AND NOT EXISTS (
                SELECT 1
                FROM preset_exercises pe
                WHERE pe.preset_id = preset_definitions.id
              )
            '''
            : '';

    final deleted = await db.rawDelete('''
      DELETE FROM preset_definitions
      WHERE lower(trim(name)) IN ($placeholders)
      $emptyPresetGuard
      ''', legacyNames);

    await _setAppMeta(
      db,
      _kEmptyStarterPlanCleanupKey,
      'done:$deleted:${sw.elapsedMilliseconds}',
    );
    _logOnOpenStep(
      'starter-plan-cleanup',
      sw.elapsedMilliseconds,
      deleted == 0 ? 'none found' : 'removed=$deleted',
    );
  }

  Future<bool> _seedFoodsIfEmpty(Database db) async {
    final sw = Stopwatch()..start();
    final n =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM foods'),
        ) ??
        0;
    if (n > 0) {
      _logOnOpenStep(
        'seed-foods',
        sw.elapsedMilliseconds,
        'skipped (count=$n)',
      );
      return false;
    }

    debugPrint(
      '[foods] seeding starter catalog from ${Seed.defaultFoodsAssetPath}',
    );
    var seeded = false;

    try {
      await Seed.seedFoods(
        db,
        onProgress: (c) => _logProgress('foods', c), // ← progress pings
      ); // defaults to the lightweight local starter catalog
      seeded = true;
    } catch (e1) {
      debugPrint(
        '[foods] primary starter seed failed: $e1 - trying explicit legacy asset',
      );
      try {
        await Seed.seedFoods(
          db,
          assetPath: 'assets/foods.json',
          onProgress: (c) => _logProgress('foods', c),
        );
        seeded = true;
      } catch (e2) {
        debugPrint('[foods] fallback starter seed also failed: $e2');
      }
    }

    if (seeded) {
      // Make the new catalog immediately usable
      await _backfillNormalizedFoodKeys(db);
      await _backfillEnergyKcalFromMacros(db);
      await _ensureIndexes(db);
      await _rebuildFoodFtsIfExists(db);

      final total =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM foods'),
          ) ??
          0;
      debugPrint(
        '[foods] seeding complete in ${sw.elapsedMilliseconds}ms - total rows: $total',
      );
      _logOnOpenStep(
        'seed-foods',
        sw.elapsedMilliseconds,
        'seeded ($total rows)',
      );
    } else {
      _logOnOpenStep('seed-foods', sw.elapsedMilliseconds, 'failed');
    }
    return seeded;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CRUD METHODS
  // ────────────────────────────────────────────────────────────────────────────

  //session_dao

  Future<int> createSession(DateTime completedAt, int duration) async {
    final db = await database;
    return SessionDao.insertSession(
      db,
      completedAt: completedAt,
      duration: duration,
    );
  }

  Future<List<Map<String, dynamic>>> getAllSessionsRaw() async {
    final db = await database;
    return SessionDao.getAllSessionsRaw(db);
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutReportSessionsRaw({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final args = <Object?>[];

    if (start != null) {
      whereClauses.add('sess.completed_at_ms >= ?');
      args.add(TemporalSemantics.utcEpochMilliseconds(start));
    }
    if (end != null) {
      whereClauses.add('sess.completed_at_ms <= ?');
      args.add(TemporalSemantics.utcEpochMilliseconds(end));
    }

    final whereSql =
        whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    return db.rawQuery('''
      SELECT
        sess.id AS session_id,
        sess.date AS date,
        sess.completed_at_ms AS completed_at_ms,
        sess.training_day AS training_day,
        sess.duration AS duration,
        COUNT(DISTINCT e.id) AS exercise_count,
        COUNT(st.id) AS set_count,
        COALESCE(SUM(
          CASE
            WHEN e.type = 'weight' THEN st.weight * st.reps
            ELSE 0
          END
        ), 0) AS total_volume
      FROM sessions sess
      LEFT JOIN exercises e ON e.session_id = sess.id
      LEFT JOIN sets st ON st.exercise_id = e.id
      $whereSql
      GROUP BY sess.id
      ORDER BY sess.completed_at_ms ASC, sess.id ASC
      ''', args);
  }

  Future<void> deleteSession(int sid) async {
    final db = await database;
    return WorkoutTransactionDao.deleteSession(db, sid);
  }

  Future<int> completeWorkoutAtomic({
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
    int? autoPresetId,
  }) async {
    final db = await database;
    return WorkoutTransactionDao.completeWorkout(
      db,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      exercises: exercises,
      autoPresetId: autoPresetId,
    );
  }

  Future<void> replaceSessionExercisesAtomic({
    required int sessionId,
    required List<WorkoutExerciseWrite> exercises,
  }) async {
    final db = await database;
    await WorkoutTransactionDao.replaceSessionExercises(
      db,
      sessionId: sessionId,
      exercises: exercises,
    );
  }

  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    final db = await database;
    await ActiveWorkoutDao.save(
      db,
      startedAt: startedAt,
      autoPresetId: autoPresetId,
      payloadJson: payloadJson,
    );
  }

  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async {
    final db = await database;
    return ActiveWorkoutDao.load(db);
  }

  Future<void> clearActiveWorkoutDraft() async {
    final db = await database;
    await ActiveWorkoutDao.clear(db);
  }

  Future<WorkoutSession?> fetchSessionById(int sessionId) async {
    final db = await database;
    final row = await SessionDao.getSessionById(db, sessionId);
    if (row == null) return null;
    return WorkoutSession(
      id: row['id'] as int,
      date: TemporalSemantics.readLocalDateTime(
        epochMilliseconds: row['completed_at_ms'],
        legacyIso: row['date'],
      ),
      calendarDayKey:
          TemporalSemantics.readCalendarDay(
            calendarDay: row['training_day'],
            legacyIso: row['date'],
            epochMilliseconds: row['completed_at_ms'],
          ).storageKey,
      duration: row['duration'] as int,
    );
  }

  Future<void> updateSession(int id, DateTime newDate, int newDuration) async {
    final db = await database;
    await db.transaction((txn) async {
      final definitionRows = await txn.rawQuery(
        '''
        SELECT DISTINCT exercise_def_id
        FROM exercises
        WHERE session_id = ?
          AND type = 'weight'
          AND exercise_def_id IS NOT NULL
      ''',
        [id],
      );
      await SessionDao.updateSession(
        txn,
        id,
        completedAt: newDate,
        duration: newDuration,
      );
      await WorkoutRecordEventsDao.rebuildForDefinitions(
        txn,
        definitionRows.map((row) => row['exercise_def_id'] as int),
      );
    });
  }

  // Fetch an inclusive exact-instant range and map it to sessions.
  Future<List<WorkoutSession>> fetchSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final rows = await SessionDao.getSessionsForInstantRange(db, start, end);
    return rows
        .map(
          (row) => WorkoutSession(
            id: row['id'] as int,
            date: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: row['completed_at_ms'],
              legacyIso: row['date'],
            ),
            calendarDayKey:
                TemporalSemantics.readCalendarDay(
                  calendarDay: row['training_day'],
                  legacyIso: row['date'],
                  epochMilliseconds: row['completed_at_ms'],
                ).storageKey,
            duration: row['duration'] as int,
          ),
        )
        .toList();
  }

  //exercise_dao

  Future<int> addExercise(
    int sessionId,
    String name,
    String equipment,
    int idx,
  ) async {
    final db = await database;
    return ExerciseDao.insertExercise(db, sessionId, name, equipment, idx);
  }

  Future<List<Map<String, dynamic>>> fetchExercisesRaw(int sessionId) async {
    final db = await database;
    return ExerciseDao.getExercisesForSession(db, sessionId);
  }

  /// Calculates record badges for the parent sets saved in one workout.
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async {
    final db = await database;
    return WorkoutRecordEventsDao.forSession(db, sessionId);
  }

  Future<Map<int, WorkoutExerciseRecordBadges>> fetchExerciseRecordBadges(
    Iterable<int> exerciseIds,
  ) async {
    final db = await database;
    return WorkoutRecordEventsDao.forExerciseIds(db, exerciseIds);
  }

  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async {
    final db = await database;
    return WorkoutRecordEventsDao.currentLeadersForDefinition(db, definitionId);
  }

  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    final db = await database;
    return ExerciseHistoryDao.fetchWeightExerciseRows(
      db,
      definitionId: definitionId,
      beforeCompletedAtMilliseconds: beforeCompletedAtMilliseconds,
      beforeExerciseId: beforeExerciseId,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];

    final db = await database;
    return db.rawQuery(
      '''
      SELECT *
      FROM (
        SELECT
          sess.id AS session_id,
          sess.date AS session_date,
          sess.completed_at_ms AS completed_at_ms,
          sess.training_day AS training_day,
          MAX(CASE WHEN st.reps = 1 THEN st.weight ELSE NULL END)
            AS actual_one_rm,
          MAX(
            CASE
              WHEN st.reps <= 1 THEN st.weight
              ELSE st.weight * (1 + 0.0333 * st.reps)
            END
          ) AS estimated_one_rm
        FROM sets st
        INNER JOIN exercises e ON e.id = st.exercise_id
        INNER JOIN sessions sess ON sess.id = e.session_id
        WHERE e.type = 'weight'
          AND e.exercise_def_id = ?
          AND st.parent_set_id IS NULL
        GROUP BY sess.id
        ORDER BY sess.completed_at_ms DESC, sess.id DESC
        LIMIT ?
      )
      ORDER BY completed_at_ms ASC, session_id ASC
      ''',
      [definitionId, limit],
    );
  }

  Future<void> deleteExercises(int sessionId) async {
    final db = await database;
    await WorkoutTransactionDao.replaceSessionExercises(
      db,
      sessionId: sessionId,
      exercises: const <WorkoutExerciseWrite>[],
    );
  }

  Future<void> saveExerciseDefinitionAtomic(
    ExerciseDefinitionWrite write,
  ) async {
    final db = await database;
    await ProfileTransactionDao.saveExerciseDefinition(db, write);
  }

  Future<int> addExerciseRow({
    int? exerciseDefId,
    required String type,
    required int orderIndex,
    required int sessionId,
    int? sourcePresetExerciseId,
  }) async {
    final db = await database;
    return ExerciseDao.insertExerciseRow(
      db: db,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
      sessionId: sessionId,
      sourcePresetExerciseId: sourcePresetExerciseId,
    );
  }

  /// Fetches a fully-detailed WorkoutExercise (Weight/Cardio/Stretch).
  Future<WorkoutExercise?> fetchDetailedExercise(int exerciseId) async {
    final db = await database;

    // 1) Base row
    final exRow = await ExerciseDao.getExerciseById(db, exerciseId);
    if (exRow == null) return null;
    final type = exRow['type'] as String;

    if (type == 'weight') {
      // — definition info (name+equipment)
      final defInfoFuture = DefinitionDao.getDefinitionInfo(
        db,
        exRow['exercise_def_id'] as int,
      );

      // — sets & changeSets
      final allSetRowsFuture = SetDao.getSetsForExercise(db, exerciseId);
      final defInfo = await defInfoFuture;
      final allSetRows = await allSetRowsFuture;
      final parentRows =
          allSetRows.where((row) => row['parent_set_id'] == null).toList();
      final childRowsByParentId = <int, List<Map<String, dynamic>>>{};
      for (final row in allSetRows) {
        final parentId = row['parent_set_id'] as int?;
        if (parentId == null) continue;
        childRowsByParentId
            .putIfAbsent(parentId, () => <Map<String, dynamic>>[])
            .add(row);
      }
      final sets = <ExerciseSet>[];
      final changeSets = <int, List<ExerciseSet>>{};
      final completedParents = <int>{};
      final completedChildren = <int, Set<int>>{};

      for (var i = 0; i < parentRows.length; i++) {
        final p = parentRows[i];
        sets.add(
          ExerciseSet(
            sourcePresetSetId: p['source_preset_set_id'] as int?,
            weight: (p['weight'] as num).toDouble(),
            reps: p['reps'] as int,
          ),
        );
        completedParents.add(i);

        final children =
            childRowsByParentId[p['id'] as int] ??
            const <Map<String, dynamic>>[];
        if (children.isNotEmpty) {
          changeSets[i] =
              children
                  .map(
                    (c) => ExerciseSet(
                      sourcePresetSetId: c['source_preset_set_id'] as int?,
                      weight: (c['weight'] as num).toDouble(),
                      reps: c['reps'] as int,
                    ),
                  )
                  .toList();
          completedChildren[i] = Set.from(
            List.generate(children.length, (j) => j),
          );
        }
      }

      return WeightExercise(
        name: defInfo['name']!,
        equipment: defInfo['equipmentName'] ?? '',
        sourcePresetExerciseId: exRow['source_preset_exercise_id'] as int?,
        sets: sets,
        changeSets: changeSets,
        completedParents: completedParents,
        completedChildren: completedChildren,
      );
    }

    if (type == 'cardio') {
      final c = await getCardioDetailsForExercise(exerciseId);
      if (c == null) return null;
      return CardioExercise(
        name: c['cardio_name'] as String,
        equipment: '',
        cardioName: c['cardio_name'] as String,
        cardioNote: c['note'] as String?,
        plannedMinutes: (c['planned_minutes'] as num).toInt(),
        elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
      );
    }

    if (type == 'stretch') {
      final items = await getStretchItemsForExercise(exerciseId);
      // Decode rows into our StretchInstance models
      final insts = items.map((r) => StretchInstance.fromMap(r)).toList();
      // Track which indices were checked
      final completed = <int>{};
      for (var i = 0; i < insts.length; i++) {
        if (insts[i].isChecked) completed.add(i);
      }
      // determine header name…
      String hdr = 'Stretch';
      if (insts.isNotEmpty && insts.first.stretchId != null) {
        final sd = await DefinitionDao.getDefinitionInfo(
          db,
          insts.first.stretchId!,
        );
        hdr = sd['name']!;
      }
      return StretchExercise(
        name: hdr,
        equipment: '',
        stretchInstances: insts,
        completedStretchIndices: completed,
      );
    }

    return null;
  }

  /// Deletes a single exercise (and all its child rows) by ID.
  Future<void> deleteExercise(int exerciseId) async {
    final db = await database;
    // Delegate to the DAO
    await ExerciseDao.deleteExerciseById(db, exerciseId);
  }

  // set_dao.dart

  /// Inserts a set belonging to an exercise instance.
  Future<int> addSet(
    int exerciseId,
    double weight,
    int reps,
    int orderIndex,
  ) async {
    final db = await database;
    return SetDao.insertSet(db, exerciseId, weight, reps, orderIndex);
  }

  /// Given a parentSets list and childChangeSets map, insert into sets.
  /// parentSets is List < ExerciseSet >  where each is a top-level set.
  /// childChangeSets is a Map < parentIndex, List < ExerciseSet>>.
  Future<void> addWeightSets({
    required int exerciseId,
    required List<ExerciseSet> parentSets,
    required Map<int, List<ExerciseSet>> childChangeSets,
  }) async {
    final db = await database;
    await SetDao.insertWeightSets(
      db: db,
      exerciseId: exerciseId,
      parentSets: parentSets,
      childChangeSets: childChangeSets,
    );
  }

  // Fetch raw set-rows.
  Future<List<Map<String, dynamic>>> fetchSetsRaw(int exerciseId) async {
    final db = await database;
    return SetDao.getSetsForExercise(db, exerciseId);
  }

  // Update a single set.
  Future<void> updateSet(int setId, double weight, int reps) async {
    final db = await database;
    await db.transaction((txn) async {
      final definitionRows = await txn.rawQuery(
        '''
        SELECT e.exercise_def_id
        FROM sets st
        INNER JOIN exercises e ON e.id = st.exercise_id
        WHERE st.id = ? AND e.type = 'weight'
      ''',
        [setId],
      );
      await txn.update(
        'sets',
        {'weight': weight, 'reps': reps},
        where: 'id = ?',
        whereArgs: [setId],
      );
      await WorkoutRecordEventsDao.rebuildForDefinitions(
        txn,
        definitionRows
            .map((row) => row['exercise_def_id'] as int?)
            .whereType<int>(),
      );
    });
  }

  // Delete a single set.
  Future<void> deleteSet(int setId) async {
    final db = await database;
    await db.transaction((txn) async {
      final definitionRows = await txn.rawQuery(
        '''
        SELECT e.exercise_def_id
        FROM sets st
        INNER JOIN exercises e ON e.id = st.exercise_id
        WHERE st.id = ? AND e.type = 'weight'
      ''',
        [setId],
      );
      await txn.delete('sets', where: 'id = ?', whereArgs: [setId]);
      await WorkoutRecordEventsDao.rebuildForDefinitions(
        txn,
        definitionRows
            .map((row) => row['exercise_def_id'] as int?)
            .whereType<int>(),
      );
    });
  }

  // Reorder sets.
  Future<void> reorderSets(int exerciseId, List<int> setIds) async {
    final db = await database;
    await SetDao.reorderSets(db, exerciseId, setIds);
  }

  //cardio_dao.dart

  /// After you create a cardio exercise row (type='cardio'), call:
  Future<void> saveCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await database;
    await CardioDao.insertCardioDetails(
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

  // Fetch raw cardio map.
  Future<Map<String, dynamic>?> fetchCardioDetails(int exerciseId) async {
    final db = await database;
    return CardioDao.getCardioDetailsForExercise(db, exerciseId);
  }

  // Update cardio details.
  Future<void> updateCardioDetails({
    required int exerciseId,
    required String cardioName,
    String? note,
    required int plannedMinutes,
    required int elapsedSeconds,
  }) async {
    final db = await database;
    await CardioDao.updateCardioDetails(
      db: db,
      exerciseId: exerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  // Delete cardio details.
  Future<void> deleteCardioDetails(int exerciseId) async {
    final db = await database;
    await CardioDao.deleteCardioDetails(db, exerciseId);
  }

  //stretch_dao.dart

  /// After you create a stretch-type exercise row, call:
  /// Inserts one stretch-type exercise’s “instance” and all of its items.
  /// uses class StretchInstance.
  Future<void> saveClassStretchInstance({
    required int exerciseId,
    required List<StretchInstance> instances,
  }) async {
    final db = await database;
    await StretchDao.insertStretchInstance(
      db: db,
      exerciseId: exerciseId,
      items: instances,
    );
  }

  Future<void> saveStretchInstance({
    required int exerciseId,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    final instances = items.map((m) => StretchInstance.fromMap(m)).toList();
    await StretchDao.insertStretchInstance(
      db: db,
      exerciseId: exerciseId,
      items: instances,
    );
  }

  /// Fetch all items in a stretch instance for a given exercise.
  Future<List<Map<String, dynamic>>> getStretchItemsForExercise(int eid) async {
    final db = await database;
    // DAO now returns List<StretchInstance>
    final instances = await StretchDao.getStretchItemsForExercise(db, eid);
    // convert back to the old map format so callers see the same type
    return instances.map((inst) => inst.toMap()).toList();
  }

  // Fetch raw stretch-item maps.
  Future<List<Map<String, dynamic>>> fetchStretchItemsRaw(
    int exerciseId,
  ) async {
    final db = await database;
    final insts = await StretchDao.getStretchItemsForExercise(db, exerciseId);
    return insts.map((i) => i.toMap()).toList();
  }

  // Update one stretch item.
  Future<int> updateStretchItem({
    required int itemId,
    int? stretchId,
    bool? isCustom,
    String? customName,
    String? customDesc,
    bool? isChecked,
    int? orderIndex,
  }) async {
    final db = await database;
    return StretchDao.updateStretchItem(
      db: db,
      itemId: itemId,
      stretchId: stretchId,
      isCustom: isCustom,
      customName: customName,
      customDesc: customDesc,
      isChecked: isChecked,
      orderIndex: orderIndex,
    );
  }

  // Delete a stretch item.
  Future<void> deleteStretchItem(int itemId) async {
    final db = await database;
    await StretchDao.deleteStretchItem(db, itemId);
  }

  // Delete whole stretch instance.
  Future<void> deleteStretchInstance(int exerciseId) async {
    final db = await database;
    await StretchDao.deleteStretchInstance(db, exerciseId);
  }

  // Reorder stretch items.
  Future<void> reorderStretchItems(int exerciseId, List<int> itemIds) async {
    final db = await database;
    await StretchDao.reorderStretchItems(db, exerciseId, itemIds);
  }

  //definition_dao.dart

  /// Fetch exercise definitions by bodyPart ID.
  Future<List<Map<String, dynamic>>> lookupDefsByBodyPart(
    int bodyPartId,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsByBodyPart(db, bodyPartId);
  }

  /// Fetch every definition with its full equipmentList, bodyParts, and muscles.
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async {
    final db = await database;
    final definitions =
        await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(db);
    return DefinitionDao.selectableCatalogDefinitions(definitions);
  }

  /// Fetch a selected subset of definitions with their full join data.
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionsDetailedByIds(db, definitionIds);
  }

  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT
        e.exercise_def_id AS definition_id,
        COUNT(e.id) AS use_count,
        MAX(sess.completed_at_ms) AS last_done
      FROM exercises e
      INNER JOIN sessions sess ON sess.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id IS NOT NULL
      GROUP BY e.exercise_def_id
      ORDER BY use_count DESC, last_done DESC
      LIMIT ?
      ''',
      [limit],
    );
  }

  /// Fetch all exercise definitions (shallow, without join lists).
  Future<List<Map<String, dynamic>>> fetchAllExercisesRaw() async {
    final db = await database;
    return DefinitionDao.getAllExercisesRaw(db);
  }

  /// Fetch all exercises whose equipment is *at least one* of [equipmentNames].
  Future<List<ExerciseDefinition>> lookupDefsWithAnyEquipment(
    List<String> equipmentNames,
  ) async {
    final db = await database;
    return DefinitionDao.getExerciseDefsWithAnyEquipment(db, equipmentNames);
  }

  /// Fetch all exercises whose equipment is *only* drawn from [equipmentNames].
  ///
  /// Because each definition has a single equipment_id, this currently
  /// returns those whose equipment_id ∈ list, or NULL if you consider
  /// “bodyweight/no equipment” as allowed.
  Future<List<ExerciseDefinition>> lookupDefsOnlyWithEquipment(
    List<String> equipmentNames, {
    bool includeNone = true,
  }) async {
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
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionsFiltered(
      db,
      equipmentNames: equipmentNames,
      bodypartIds: bodypartIds,
      muscleIds: muscleIds,
    );
  }

  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async {
    final db = await database;
    return DefinitionDao.findOrCreateExerciseDefinition(
      db,
      name,
      equipmentName,
    );
  }

  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async {
    final db = await database;
    return DefinitionDao.getDefinitionInfo(db, defId);
  }

  Future<void> updateExerciseDefinition(ExerciseDefinition def) async {
    final db = await database;
    await DefinitionDao.updateExerciseDefinition(db, def);
  }

  Future<void> deleteExerciseDefinition(int defId) async {
    final db = await database;
    await DefinitionDao.deleteExerciseDefinition(db, defId);
  }

  Future<List<ExerciseDefinition>> searchExerciseDefinitions(
    String query,
  ) async {
    final db = await database;
    return DefinitionDao.searchExerciseDefinitions(db, query);
  }

  /// Fetch a single detailed ExerciseDefinition by its ID.
  Future<ExerciseDefinition?> getExerciseDefinitionById(int defId) async {
    final db = await database;
    return DefinitionDao.getExerciseDefinitionById(db, defId);
  }

  Future<List<ExerciseMediaItem>> getExerciseMedia(int defId) async {
    final db = await database;
    final rows = await db.query(
      'exercise_media',
      where: 'exercise_def_id = ?',
      whereArgs: [defId],
      orderBy: 'sort_order, id',
    );
    return rows.map(ExerciseMediaItem.fromMap).toList();
  }

  Future<List<SharedMediaItem>> getSharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async {
    final db = await database;
    return ContentDao.getSharedMedia(db, entityType, entityId);
  }

  Future<void> replaceExerciseMedia(
    int defId,
    List<ExerciseMediaItem> items,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'exercise_media',
        where: 'exercise_def_id = ?',
        whereArgs: [defId],
      );
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        await txn.insert('exercise_media', {
          'exercise_def_id': defId,
          'asset_id': item.assetId,
          'media_type': item.mediaType,
          'remote_url': item.remoteUrl,
          'thumbnail_url': item.thumbnailUrl,
          'local_cache_path': item.localCachePath,
          'local_thumbnail_path': item.localThumbnailPath,
          'title': item.title,
          'sort_order': i,
          'version': item.version,
          'bytes': item.bytes,
          'width': item.width,
          'height': item.height,
          'sha256': item.sha256,
          'license_id': item.licenseId,
          'last_accessed_at': item.lastAccessedAt?.toIso8601String(),
          'downloaded_at': item.downloadedAt?.toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });
  }

  /// Fetches catalog definitions with optional profile & filters.
  Future<List<ExerciseDefinition>> fetchCatalogDefinitions({
    required bool useProfileFilter,
    int? profileId,
    String? equipmentFilter,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    var definitions = await lookupDefsDetailed();

    // Require the complete equipment list for profile-aware generation.
    if (useProfileFilter && profileId != null) {
      final profileEquipment = await fetchEquipmentForProfile(profileId);
      final profileEquipmentIds = <int>{
        for (final row in profileEquipment)
          if (row['id'] is int) row['id'] as int,
      };
      definitions =
          definitions
              .where(
                (definition) => ExerciseEquipmentCompatibility.fitsProfileIds(
                  definition,
                  profileEquipmentIds,
                ),
              )
              .toList();
    }

    final selectedEquipment = equipmentFilter?.trim();
    if (selectedEquipment != null &&
        selectedEquipment.isNotEmpty &&
        selectedEquipment != 'All') {
      definitions =
          definitions
              .where(
                (definition) =>
                    ExerciseEquipmentCompatibility.usesEquipmentName(
                      definition,
                      selectedEquipment,
                    ),
              )
              .toList();
    }

    // 4) Post‐filter by body/muscle
    if (bodypartIds != null && bodypartIds.isNotEmpty) {
      final selectedBodypartIds = bodypartIds.toSet();
      definitions =
          definitions
              .where(
                (definition) => definition.bodyParts.any(
                  (bodyPart) => selectedBodypartIds.contains(bodyPart.id),
                ),
              )
              .toList();
    }

    if (muscleIds != null && muscleIds.isNotEmpty) {
      final selectedMuscleIds = muscleIds.toSet();
      definitions =
          definitions
              .where(
                (definition) => definition.muscles.any(
                  (muscle) => selectedMuscleIds.contains(muscle.muscle.id),
                ),
              )
              .toList();
    }

    return definitions;
  }

  Future<int> insertExerciseMuscleMapping(
    int defId,
    int muscleId,
    int rank,
  ) async {
    final db = await database;
    return DefinitionDao.insertExerciseMuscleMapping(db, defId, muscleId, rank);
  }

  /// Deletes the link between a definition and a muscle.
  Future<int> deleteExerciseMuscleMapping(int defId, int muscleId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseMuscleMapping(db, defId, muscleId);
  }

  Future<int> insertExerciseBodypartMapping(int defId, int bpId) async {
    final db = await database;
    return DefinitionDao.insertExerciseBodypartMapping(db, defId, bpId);
  }

  Future<int> deleteExerciseBodypartMapping(int defId, int bpId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseBodypartMapping(db, defId, bpId);
  }

  Future<int> insertExerciseEquipmentMapping(int defId, int eqId) async {
    final db = await database;
    return DefinitionDao.insertExerciseEquipmentMapping(db, defId, eqId);
  }

  Future<int> deleteExerciseEquipmentMapping(int defId, int eqId) async {
    final db = await database;
    return DefinitionDao.deleteExerciseEquipmentMapping(db, defId, eqId);
  }

  //lookup_dao.dart

  /// Fetch all measurement definitions.
  Future<List<Map<String, dynamic>>> fetchMeasurementDefinitions() async {
    final db = await database;
    return LookupDao.getMeasurementDefinitions(db);
  }

  Future<void> ensureDefaultMeasurementDefinitions() async {
    final db = await database;
    await LookupDao.ensureDefaultMeasurementDefinitions(db);
  }

  Future<int> insertMeasurementDefinition({
    required String name,
    required MeasurementType type,
  }) async {
    final db = await database;
    return LookupDao.insertMeasurementDefinition(db, name: name, type: type);
  }

  Future<int?> fetchMeasurementDefinitionId(String name) async {
    final db = await database;
    return LookupDao.getMeasurementDefinitionId(db, name);
  }

  /// Insert a new measurement instance.
  Future<int> insertMeasurement(
    int defId,
    DateTime timestamp,
    double value,
    String unit,
    String? note,
    MeasurementContext? context,
  ) async {
    final db = await database;
    return LookupDao.insertMeasurement(
      db,
      defId,
      timestamp,
      value,
      unit,
      note,
      context,
    );
  }

  /// Fetch all measurements for a definition.
  Future<List<Map<String, dynamic>>> fetchMeasurementsRaw(int defId) async {
    final db = await database;
    return LookupDao.getMeasurementsForDefinition(db, defId);
  }

  Future<List<Measurement>> fetchClassMeasurementsForDefinition(
    int defId,
  ) async {
    final rows = await fetchMeasurementsRaw(defId);
    return rows
        .map(
          (r) => Measurement(
            id: r['id'] as int,
            defId: r['def_id'] as int,
            timestamp: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: r['measured_at_ms'],
              legacyIso: r['timestamp'],
            ),
            calendarDayKey:
                TemporalSemantics.readCalendarDay(
                  calendarDay: r['measured_on'],
                  legacyIso: r['timestamp'],
                  epochMilliseconds: r['measured_at_ms'],
                ).storageKey,
            value: (r['value'] as num).toDouble(),
            unit: r['unit'] as String,
            note: r['note'] as String?,
            context: _measurementContextFromValue(r['context'] as String?),
          ),
        )
        .toList();
  }

  Future<double?> fetchLatestBodyWeightLbs() async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT m.value, m.unit
        FROM measurements m
        JOIN measurement_definitions md ON md.id = m.def_id
       WHERE md.type = ?
       ORDER BY m.measured_at_ms DESC, m.id DESC
       LIMIT 1
    ''',
      [MeasurementType.BodyWeight.name],
    );

    if (rows.isEmpty) return null;
    final value = (rows.first['value'] as num?)?.toDouble();
    if (value == null || value <= 0) return null;

    final unit =
        ((rows.first['unit'] as String?) ?? 'lbs').trim().toLowerCase();
    if (unit == 'kg' ||
        unit == 'kgs' ||
        unit == 'kilogram' ||
        unit == 'kilograms') {
      return value * 2.2046226218;
    }
    if (unit == 'lb' || unit == 'lbs' || unit == 'pound' || unit == 'pounds') {
      return value;
    }
    return null;
  }

  /// Returns only the definitions that have at least one measurement recorded.
  Future<List<Map<String, dynamic>>>
  fetchUsedMeasurementDefinitionsRaw() async {
    final db = await database;
    return LookupDao.getUsedMeasurementDefinitions(db);
  }

  MeasurementDefinition _measurementDefinitionFromRow(
    Map<String, dynamic> row,
  ) {
    return MeasurementDefinition(
      id: row['id'] as int,
      name: row['name'] as String,
      type: MeasurementType.values.firstWhere(
        (mt) => mt.name == (row['type'] as String),
        orElse: () => MeasurementType.Custom,
      ),
    );
  }

  Future<List<MeasurementDefinition>> fetchClassMeasurementDefinitions() async {
    final raw = await fetchMeasurementDefinitions();
    return raw.map(_measurementDefinitionFromRow).toList();
  }

  Future<List<MeasurementDefinition>>
  fetchUsedClassMeasurementDefinitions() async {
    final raw = await fetchUsedMeasurementDefinitionsRaw();
    return raw.map(_measurementDefinitionFromRow).toList();
  }

  Future<Map<String, dynamic>?> fetchMeasurementById(int id) async {
    final db = await database;
    return LookupDao.getMeasurementById(db, id);
  }

  Future<void> updateMeasurement({
    required int measurementId,
    required DateTime timestamp,
    required double value,
    required String unit,
    String? note,
    MeasurementContext? context,
  }) async {
    final db = await database;
    await LookupDao.updateMeasurement(
      db: db,
      measurementId: measurementId,
      timestamp: timestamp,
      value: value,
      unit: unit,
      note: note,
      context: context,
    );
  }

  MeasurementContext? _measurementContextFromValue(String? value) {
    for (final context in MeasurementContext.values) {
      if (context.name == value) return context;
    }
    return null;
  }

  Future<void> deleteMeasurement(int measurementId) async {
    final db = await database;
    await LookupDao.deleteMeasurement(db, measurementId);
  }

  /// Fetch all equipment names.
  Future<List<String>> fetchAllEquipmentNames() async {
    final db = await database;
    return LookupDao.getAllEquipmentNames(db);
  }

  /// Fetch all body-part IDs and names.
  Future<List<BodyPart>> fetchAllBodyParts() async {
    final db = await database;
    return LookupDao.getAllBodyParts(db);
  }

  /// Fetch all muscle names.
  Future<List<Muscle>> fetchAllMuscles() async {
    final db = await database;
    return LookupDao.getAllMuscles(db);
  }

  Future<List<String>> fetchAllMuscleNames() async {
    final db = await database;
    return LookupDao.getAllMuscleNames(db);
  }

  /// Fetch stretches by an optional bodypart ID (or all if null).
  Future<List<StretchDefinition>> fetchStretches({int? bodypartId}) async {
    final db = await database;
    return LookupDao.getStretches(db, bodypartId);
  }

  Future<String?> fetchStretchDefinitionNameById(int stretchId) async {
    final db = await database;
    return LookupDao.getStretchDefinitionNameById(db, stretchId);
  }

  Future<List<Equipment>> fetchAllEquipment() async {
    final db = await database;
    return LookupDao.getAllEquipment(db);
  }

  Future<int> createEquipment(String name) async {
    final db = await database;
    return LookupDao.insertEquipment(db, name);
  }

  Future<void> updateEquipment(int id, String name) async {
    final db = await database;
    await LookupDao.updateEquipment(db, id, name);
  }

  Future<void> deleteEquipment(int id) async {
    final db = await database;
    await LookupDao.deleteEquipment(db, id);
  }

  Future<List<BodyPart>> fetchAllBodyPartsFull() async {
    final db = await database;
    return LookupDao.getAllBodyParts(db);
  }

  Future<int> createBodyPart(String name) async {
    final db = await database;
    return LookupDao.insertBodyPart(db, name);
  }

  Future<void> updateBodyPartEntry(int id, String name) async {
    final db = await database;
    await LookupDao.updateBodyPart(db, id, name);
  }

  Future<void> deleteBodyPartEntry(int id) async {
    final db = await database;
    await LookupDao.deleteBodyPart(db, id);
  }

  Future<List<Muscle>> fetchAllMusclesFull() async {
    final db = await database;
    return LookupDao.getAllMuscles(db);
  }

  Future<int> createMuscle(String name) async {
    final db = await database;
    return LookupDao.insertMuscle(db, name);
  }

  Future<void> updateMuscleEntry(int id, String name) async {
    final db = await database;
    await LookupDao.updateMuscle(db, id, name);
  }

  Future<void> deleteMuscleEntry(int id) async {
    final db = await database;
    await LookupDao.deleteMuscle(db, id);
  }

  /// Rerun JSON-seeding for lookup tables & stretches.
  Future<void> reseedLookupData() async {
    final db = await database;
    await Seed.seedLookupsAndExercises(db);
    await Seed.seedStretches(db);
  }

  Future<DatabaseHealthSnapshot> getDatabaseHealthSnapshot() async {
    final db = await database;
    final path = await _dbFilePath();
    final dbFile = File(path);
    final walFile = File('$path-wal');
    final shmFile = File('$path-shm');

    Future<int> fileLength(File file) async {
      try {
        return await file.exists() ? await file.length() : 0;
      } catch (_) {
        return 0;
      }
    }

    Future<int> intPragma(String pragma) async {
      try {
        return Sqflite.firstIntValue(await db.rawQuery('PRAGMA $pragma')) ?? 0;
      } catch (_) {
        return 0;
      }
    }

    String journalMode = 'unknown';
    try {
      final rows = await db.rawQuery('PRAGMA journal_mode');
      if (rows.isNotEmpty && rows.first.values.isNotEmpty) {
        journalMode = rows.first.values.first.toString();
      }
    } catch (_) {
      journalMode = 'unknown';
    }

    final schemaVersion = await db.getVersion();
    final pageCount = await intPragma('page_count');
    final pageSize = await intPragma('page_size');
    final tableCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master "
            "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          ),
        ) ??
        0;
    final indexCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master "
            "WHERE type = 'index' AND name NOT LIKE 'sqlite_%'",
          ),
        ) ??
        0;
    final triggerCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'trigger'",
          ),
        ) ??
        0;

    return DatabaseHealthSnapshot(
      path: path,
      schemaVersion: schemaVersion,
      targetSchemaVersion: _kDbVersion,
      journalMode: journalMode,
      databaseBytes: await fileLength(dbFile),
      walBytes: await fileLength(walFile),
      shmBytes: await fileLength(shmFile),
      pageCount: pageCount,
      pageSize: pageSize,
      tableCount: tableCount,
      indexCount: indexCount,
      triggerCount: triggerCount,
      foodCount: await _countRowsIfTableExists(db, 'foods'),
      foodFtsCount: await _countRowsIfTableExists(db, 'food_search_fts'),
      checkedAt: DateTime.now(),
    );
  }

  Future<DatabaseMaintenanceResult> runDatabaseIntegrityCheck() async {
    final db = await database;
    final rows = await db.rawQuery('PRAGMA integrity_check');
    final messages =
        rows
            .map((row) => row.values.isEmpty ? '' : row.values.first.toString())
            .where((message) => message.isNotEmpty)
            .toList();
    final ok = messages.length == 1 && messages.first.toLowerCase() == 'ok';

    return DatabaseMaintenanceResult(
      title: 'Integrity Check',
      message: ok ? 'Database integrity check passed.' : messages.join('\n'),
      rows: rows.map((row) => Map<String, Object?>.from(row)).toList(),
    );
  }

  Future<DatabaseMaintenanceResult> optimizeDatabase() async {
    final db = await database;
    await db.rawQuery('PRAGMA optimize');
    return const DatabaseMaintenanceResult(
      title: 'Optimize Database',
      message: 'SQLite optimize completed.',
    );
  }

  Future<DatabaseMaintenanceResult> checkpointWal() async {
    final db = await database;
    final rows = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    return DatabaseMaintenanceResult(
      title: 'WAL Checkpoint',
      message: 'Write-ahead log checkpoint completed.',
      rows: rows.map((row) => Map<String, Object?>.from(row)).toList(),
    );
  }

  Future<DatabaseMaintenanceResult> vacuumDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
    return const DatabaseMaintenanceResult(
      title: 'Vacuum Database',
      message: 'Database vacuum completed.',
    );
  }

  DatabaseImportPreview previewDatabaseImport(String jsonStr) {
    return inspectDatabaseImport(jsonStr, currentSchemaVersion: _kDbVersion);
  }

  /// Export the entire database to a JSON string.
  Future<String> exportDatabase() async {
    final db = await database;
    final tables = kDatabaseExportTableNames;
    final existingTables = await _tableNames(db);
    final missingRequiredTables =
        tables.where((table) => !existingTables.contains(table)).toList();
    if (missingRequiredTables.isNotEmpty) {
      throw StateError(
        'Database backup cannot be created because required tables are missing.',
      );
    }

    final Map<String, dynamic> data = {};
    await db.transaction((txn) async {
      for (final table in tables) {
        data[table] = await txn.query(table);
      }
    });
    return jsonEncode(
      buildDatabaseExportEnvelope(schemaVersion: _kDbVersion, tables: data),
    );
  }

  /// Imports a database backup from JSON.
  ///
  /// Full v3 snapshots replace authoritative rows atomically. Older or partial
  /// exports are merged without clearing existing rows first, so they cannot
  /// erase unrelated current data that the old format did not contain.
  Future<void> importDatabase(String jsonStr, {bool clearFirst = true}) async {
    final db = await database;
    final preview = previewDatabaseImport(jsonStr);
    if (!preview.canImport) {
      throw FormatException(preview.message);
    }
    final data = decodeDatabaseExportTables(jsonStr);
    final tablesToRestore =
        kDatabaseExportTableNames.where(data.containsKey).toList();
    final replaceSnapshot = clearFirst && preview.canReplace;

    final suspendFoodFtsTriggers = await _hasFoodFtsTable(db);
    if (suspendFoodFtsTriggers) {
      await _dropFoodFtsTriggers(db);
    }

    try {
      final foreignKeySetting =
          Sqflite.firstIntValue(await db.rawQuery('PRAGMA foreign_keys')) ?? 0;
      await db.execute('PRAGMA foreign_keys = OFF;');
      try {
        await db.transaction((txn) async {
          final existingTables = await _tableNames(txn);
          if (replaceSnapshot) {
            final missingLocalTables =
                kDatabaseExportTableNames
                    .where((table) => !existingTables.contains(table))
                    .toList();
            if (missingLocalTables.isNotEmpty) {
              throw StateError(
                'Current database cannot accept a complete backup because required tables are missing.',
              );
            }
          }
          if (replaceSnapshot) {
            // Remove snapshot rows in reverse dependency order. Tables omitted
            // from the backup contract are either rebuilt or discarded below.
            final tablesToClear = kDatabaseExportTableNames.reversed;
            for (final table in tablesToClear) {
              if (existingTables.contains(table)) {
                await txn.delete(table);
              }
            }
          }

          // Derived/cache/app-owned rows must never survive a full replacement
          // if they point at the prior snapshot's local IDs.
          for (final table in kDatabaseDerivedOrDiscardedTableNames) {
            if (existingTables.contains(table)) {
              await txn.delete(table);
            }
          }

          // Restore only authoritative snapshot rows. Legacy exports may carry
          // cache rows; their policy intentionally ignores them.
          for (final table in tablesToRestore) {
            if (!existingTables.contains(table)) continue; // skip unknown
            final rows = List<Map<String, dynamic>>.from(data[table] as List);
            for (final row in rows) {
              final sane = await _sanitizeRowForTable(txn, table, row);
              if (sane.isNotEmpty) {
                await txn.insert(
                  table,
                  sane,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            }
          }

          // Keep every authoritative data mutation inside this transaction so
          // a malformed import or storage failure cannot replace only part of
          // the person's existing database.
          await _backfillNormalizedFoodKeysTx(txn);
          await _backfillEnergyKcalFromMacros(txn);

          await _bumpAutoincrement(txn);

          final foreignKeyViolations = await txn.rawQuery(
            'PRAGMA foreign_key_check',
          );
          if (foreignKeyViolations.isNotEmpty) {
            throw StateError(
              'Imported database has ${foreignKeyViolations.length} foreign key '
              'violation(s).',
            );
          }
        });
      } finally {
        if (foreignKeySetting == 1) {
          await db.execute('PRAGMA foreign_keys = ON;');
        }
      }
      // The imported history must be canonical before any following reader can
      // observe it. Derived search/index maintenance remains best-effort.
      await Schema.migrateV61(db);

      // Re-seed current app-owned catalog rows after a full snapshot. The
      // policy clears catalog state, so stable catalog IDs reconcile instead
      // of leaving the backup's bundled revision in control.
      await _ensureAppMetaTable(db);
      if (replaceSnapshot) {
        await Seed.syncExerciseCatalogIfNeeded(db);
        await Seed.syncCreatorExerciseAllocationDefaults(db);
      }

      // Rebuild derived results from restored authoritative data. These are
      // intentionally not serialized as backup payload.
      if (await _tableExists(db, 'recipes')) {
        await _rebuildAllRecipeCaches(db);
      }
      await WorkoutRecordEventsDao.rebuildAll(db);
      await _rebuildFoodFtsIfExists(db);
      await Schema.migrateV49(db);
      await _ensureIndexes(db);
    } finally {
      if (suspendFoodFtsTriggers) {
        try {
          await _ensureFoodFtsTriggers(db);
        } catch (_) {
          // Search falls back safely until maintenance can recreate triggers.
        }
      }
    }
  }

  Future<String> _exportNameListJson(String table) async {
    final db = await database;
    final rows = await db.query(table);
    final out = rows.map((r) => {'name': r['name'] as String}).toList();
    return jsonEncode(out);
  }

  // equipment.json
  Future<String> exportEquipmentJson() => _exportNameListJson('equipment');

  /// bodyparts.json
  Future<String> exportBodypartsJson() => _exportNameListJson('bodypart');

  /// muscles.json
  Future<String> exportMusclesJson() => _exportNameListJson('muscles');

  /// exercises.json
  Future<String> exportExercisesJson() async {
    final db = await database;
    final defs = await DefinitionDao.getAllExerciseDefinitionsDetailedBatched(
      db,
    );
    final out =
        defs.map((def) {
          final map = <String, dynamic>{
            'name': def.name,
            'rating': def.rating,
            'equipment': def.equipmentList.map((e) => e.name).toList(),
            'bodyparts': def.bodyParts.map((bp) => bp.name).toList(),
            'muscles':
                def.muscles
                    .map((rm) => {'name': rm.muscle.name, 'rank': rm.rank})
                    .toList(),
          };
          if (def.useManualBodyparts) {
            map['useManualBodyparts'] = true;
          }
          if (def.setupNotes.isNotEmpty) {
            map['setupNotes'] = def.setupNotes;
          }
          if (def.executionNotes.isNotEmpty) {
            map['executionNotes'] = def.executionNotes;
          }
          if (def.tipsNotes.isNotEmpty) {
            map['tipsNotes'] = def.tipsNotes;
          }
          if (def.multiplyByRating) {
            map['multiplyByRating'] = true;
          }
          return map;
        }).toList();
    return jsonEncode(out);
  }

  /// stretches.json
  Future<String> exportStretchesJson() async {
    final db = await database;
    final defs = await LookupDao.getStretches(db, null);
    final out =
        defs
            .map(
              (s) => {
                'name': s.name,
                'bodyparts': s.bodyParts.map((bp) => bp.name).toList(),
                'description': s.description,
              },
            )
            .toList();
    return jsonEncode(out);
  }

  /// muscle_bodypart.json
  Future<String> exportMuscleBodypartJson() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT bp.name AS bodypart, m.name AS muscle
        FROM muscle_bodypart mb
        JOIN bodypart bp ON mb.bodypart_id = bp.id
        JOIN muscles m    ON mb.muscle_id   = m.id
    ''');
    final Map<String, List<String>> grouped = {};
    for (var r in rows) {
      final bp = r['bodypart'] as String;
      grouped.putIfAbsent(bp, () => []).add(r['muscle'] as String);
    }
    final out =
        grouped.entries
            .map((e) => {'bodypart': e.key, 'muscles': e.value})
            .toList();
    return jsonEncode(out);
  }

  /// bodypart_ranking.json
  Future<String> exportBodypartRankingJson() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT bp.name  AS bodypart,
             r.rank    AS rank
        FROM bodypart_ranking r
        JOIN bodypart bp ON r.bodypart_id = bp.id
    ''');
    final out =
        rows
            .map(
              (r) => {
                'bodypart': r['bodypart'] as String,
                'rank': r['rank'] as int,
              },
            )
            .toList();
    return jsonEncode(out);
  }

  /// muscle_ranking.json
  Future<String> exportMuscleRankingJson() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT m.name  AS muscle,
             r.rank  AS rank
        FROM muscle_ranking r
        JOIN muscles m ON r.muscle_id = m.id
    ''');
    final out =
        rows
            .map(
              (r) => {
                'muscle': r['muscle'] as String,
                'rank': r['rank'] as int,
              },
            )
            .toList();
    return jsonEncode(out);
  }

  /// bodypart_muscle_rankings.json
  Future<String> exportBodypartMuscleRankingsJson() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT bp.name  AS bodypart,
             m.name   AS muscle,
             r.rank   AS rank
        FROM bodypart_muscle_rankings r
        JOIN bodypart bp ON r.bodypart_id = bp.id
        JOIN muscles m    ON r.muscle_id   = m.id
        ORDER BY bp.name, r.rank
    ''');
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in rows) {
      final bp = row['bodypart'] as String;
      grouped.putIfAbsent(bp, () => []).add({
        'muscle': row['muscle'] as String,
        'rank': row['rank'] as int,
      });
    }
    final out =
        grouped.entries
            .map((e) => {'bodypart': e.key, 'muscleRanks': e.value})
            .toList();
    return jsonEncode(out);
  }

  /// volume_boundaries.json
  Future<String> exportVolumeBoundariesJson() async {
    final db = await database;
    final bpRows = await db.rawQuery('''
      SELECT bp.name                     AS bodypart,
             v.maintenance_volume       AS maintenance,
             v.min_effective_volume     AS minEffective,
             v.max_adaptive_volume      AS maxAdaptive,
             v.max_recoverable_volume   AS maxRecoverable
        FROM bodypart_volume_boundaries v
        JOIN bodypart bp ON v.bodypart_id = bp.id
    ''');
    final mRows = await db.rawQuery('''
      SELECT m.name                     AS muscle,
             v.maintenance_volume       AS maintenance,
             v.min_effective_volume     AS minEffective,
             v.max_adaptive_volume      AS maxAdaptive,
             v.max_recoverable_volume   AS maxRecoverable
        FROM muscle_volume_boundaries v
        JOIN muscles m ON v.muscle_id = m.id
    ''');

    return jsonEncode({'bodyparts': bpRows, 'muscles': mRows});
  }

  /// Performs fuzzy search on exercise definition names.
  Future<List<ExerciseDefinition>> fuzzsearchExercises(String term) async {
    final db = await database;
    return DefinitionDao.fuzzsearchExerciseDefinitions(db, term);
  }

  // stats_dao.dart methods:

  /// Upsert a rep-max stat row.
  Future<void> upsertRepMax(
    int defId,
    int repCount,
    String timeframe,
    double rmValue,
    double oneErm,
    bool isErm,
  ) async {
    final db = await database;
    return StatsDao.upsertRepMax(
      db,
      defId,
      repCount,
      timeframe,
      rmValue,
      oneErm,
      isErm,
    );
  }

  /// Upsert a volume-max stat row.
  Future<void> upsertVolumeMax(
    int defId,
    String timeframe,
    double vmValue,
  ) async {
    final db = await database;
    return StatsDao.upsertVolumeMax(db, defId, timeframe, vmValue);
  }

  // —————————————— Rep-Max + Volume-Max Queries ——————————————

  /// Returns list of rep-max rows for [defId] & [timeframe].
  Future<List<Map<String, dynamic>>> getRepMaxes(
    int defId,
    String timeframe,
  ) async {
    final db = await database;
    return StatsDao.getRepMaxes(db, defId, timeframe);
  }

  /// Returns the volume-max row (or null) for [defId] & [timeframe].
  Future<Map<String, dynamic>?> getVolumeMax(
    int defId,
    String timeframe,
  ) async {
    final db = await database;
    return StatsDao.getVolumeMax(db, defId, timeframe);
  }

  Future<double> calculateTotalVolumeForSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return 0.0;

    final db = await database;
    var totalVolume = 0.0;
    final uniqueSessionIds = sessionIds.toSet().toList();
    for (final chunk in sqliteChunks(uniqueSessionIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      final rows = await db.rawQuery('''
        SELECT COALESCE(SUM(s.weight * s.reps), 0) AS total_volume
        FROM sets s
        INNER JOIN exercises e ON e.id = s.exercise_id
        WHERE e.type = 'weight'
          AND e.session_id IN ($placeholders)
        ''', chunk);
      totalVolume += ((rows.first['total_volume'] as num?) ?? 0).toDouble();
    }

    return totalVolume;
  }

  // ─── Formula Settings ──────────────────────────────────────

  static const _stepKey = 'step';
  static const _minKey = 'min';
  static const _maxKey = 'max';

  /// Reads a formula parameter or returns [fallback].
  Future<double> _getFormulaParam(String key, double fallback) async {
    final db = await database;
    final v = await FormulaSettingsDao.getParam(db, key);
    return v ?? fallback;
  }

  Future<double> getFormulaStep() => _getFormulaParam(_stepKey, 0.05);
  Future<double> getFormulaMin() => _getFormulaParam(_minKey, 0.0);
  Future<double> getFormulaMax() => _getFormulaParam(_maxKey, 1.0);

  Future<void> setFormulaStep(double step) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _stepKey, step);
  }

  Future<void> setFormulaMin(double min) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _minKey, min);
  }

  Future<void> setFormulaMax(double max) async {
    final db = await database;
    await FormulaSettingsDao.setParam(db, _maxKey, max);
  }

  // ─── ANALYTICS ─────────────────────────────────────────────

  Future<int> linkMuscleToBodyPart(int muscleId, int bodypartId) async {
    final db = await database;
    return AnalyticsDao.insertMuscleBodyPart(db, muscleId, bodypartId);
  }

  Future<int> unlinkMuscleFromBodyPart(int muscleId, int bodypartId) async {
    final db = await database;
    return AnalyticsDao.deleteMuscleBodyPart(db, muscleId, bodypartId);
  }

  Future<List<MuscleBodyPart>> fetchBodyPartsForMuscle(int muscleId) async {
    final db = await database;
    return AnalyticsDao.getBodyPartsForMuscle(db, muscleId);
  }

  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int bodypartId) async {
    final db = await database;
    return AnalyticsDao.getMusclesForBodyPart(db, bodypartId);
  }

  Future<int> setBodyPartRank(int bodypartId, int rank) async {
    final db = await database;
    return AnalyticsDao.setBodyPartRanking(db, bodypartId, rank);
  }

  Future<BodyPartRanking?> getBodyPartRank(int bodypartId) async {
    final db = await database;
    return AnalyticsDao.getBodyPartRanking(db, bodypartId);
  }

  Future<List<BodyPartRanking>> getAllBodyPartRanks() async {
    final db = await database;
    return AnalyticsDao.getAllBodyPartRankings(db);
  }

  Future<int> deleteBodyPartRank(int bodypartId) async {
    final db = await database;
    return AnalyticsDao.deleteBodyPartRanking(db, bodypartId);
  }

  Future<int> setMuscleRank(int muscleId, int rank) async {
    final db = await database;
    return AnalyticsDao.setMuscleRanking(db, muscleId, rank);
  }

  Future<MuscleRanking?> getMuscleRank(int muscleId) async {
    final db = await database;
    return AnalyticsDao.getMuscleRanking(db, muscleId);
  }

  Future<List<MuscleRanking>> getAllMuscleRanks() async {
    final db = await database;
    return AnalyticsDao.getAllMuscleRankings(db);
  }

  Future<int> deleteMuscleRank(int muscleId) async {
    final db = await database;
    return AnalyticsDao.deleteMuscleRanking(db, muscleId);
  }

  Future<int> setExerciseMuscleHitPercent(
    int defId,
    int muscleId,
    double pct,
  ) async {
    final db = await database;
    return AnalyticsDao.setExerciseMusclePercent(db, defId, muscleId, pct);
  }

  Future<ExerciseMusclePercent?> fetchExerciseMusclePercent(
    int defId,
    int muscleId,
  ) async {
    final db = await database;
    return AnalyticsDao.getExerciseMusclePercent(db, defId, muscleId);
  }

  Future<int> removeExerciseMusclePercent(int defId, int muscleId) async {
    final db = await database;
    return AnalyticsDao.deleteExerciseMusclePercent(db, defId, muscleId);
  }

  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(
    int defId,
  ) async {
    final db = await database;
    return AnalyticsDao.getPercentsForExercise(db, defId);
  }

  Future<int> setMuscleVolumeBounds(int muscleId, VolumeBoundaries b) async {
    final db = await database;
    return AnalyticsDao.setMuscleVolumeBoundaries(db, muscleId, b);
  }

  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async {
    final db = await database;
    return AnalyticsDao.getMuscleVolumeBoundaries(db, muscleId);
  }

  Future<List<Map<String, dynamic>>> fetchAllMuscleVolumeBounds() async {
    final db = await database;
    return AnalyticsDao.getAllMuscleVolumeBoundaries(db);
  }

  Future<int> removeMuscleVolumeBounds(int muscleId) async {
    final db = await database;
    return AnalyticsDao.deleteMuscleVolumeBoundaries(db, muscleId);
  }

  Future<int> setBodyPartVolumeBounds(
    int bodyPartId,
    VolumeBoundaries bounds,
  ) async {
    final db = await database;
    return AnalyticsDao.setBodyPartVolumeBoundaries(db, bodyPartId, bounds);
  }

  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async {
    final db = await database;
    return AnalyticsDao.getBodyPartVolumeBoundaries(db, bodyPartId);
  }

  Future<List<Map<String, dynamic>>> fetchAllBodyPartVolumeBounds() async {
    final db = await database;
    return AnalyticsDao.getAllBodyPartVolumeBoundaries(db);
  }

  Future<int> removeBodyPartVolumeBounds(int bodyPartId) async {
    final db = await database;
    return AnalyticsDao.deleteBodyPartVolumeBoundaries(db, bodyPartId);
  }

  /// Fetch manual body-part percent overrides for an exercise definition
  Future<List<ExerciseBodyPartPercent>> fetchBodyPartPercentsManual(
    int defId,
  ) async {
    final db = await database;
    return AnalyticsDao.getPercentsForExerciseBodyPart(db, defId);
  }

  /// Upsert a manual body-part percent override
  Future<int> setExerciseBodyPartPercent(
    int defId,
    int bpId,
    double pct,
  ) async {
    final db = await database;
    return AnalyticsDao.setExerciseBodyPartPercent(db, defId, bpId, pct);
  }

  /// Delete a manual body-part percent override
  Future<int> deleteExerciseBodyPartPercent(int defId, int bpId) async {
    final db = await database;
    return AnalyticsDao.deleteExerciseBodyPartPercent(db, defId, bpId);
  }

  /// Fetches rep‐max rows and maps to model.
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async {
    final db = await database;
    final raw = await StatsDao.getRepMaxes(db, defId, timeframe);
    return raw
        .map(
          (r) => RepMaxRow(
            repCount: r['rep_count'] as int,
            rmValue: (r['rm_value'] as num).toDouble(),
            oneErm: (r['one_erm'] as num).toDouble(),
            isErm: (r['is_erm'] as int) == 1,
          ),
        )
        .toList();
  }

  /// Fetches a volume‐max value (or null).
  Future<double?> fetchVolumeMax(int defId, String timeframe) async {
    final db = await database;
    final row = await StatsDao.getVolumeMax(db, defId, timeframe);
    if (row == null) return null;
    return (row['vm_value'] as num).toDouble();
  }

  // ─── Exercise allocation resolution ────────────────────────

  /// Returns the source-aware anatomy allocation for one exercise.
  ///
  /// New personal values and future creator values are resolved here, while
  /// legacy percent rows are preserved as a compatibility source.
  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(
    int defId,
  ) async {
    return ExerciseAllocationResolver.resolve(await database, defId);
  }

  Future<void> setPersonalExerciseAllocationCredit({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required int targetId,
    required double credit,
  }) async {
    if (!credit.isFinite || credit < 0) {
      throw ArgumentError.value(
        credit,
        'credit',
        'Set credit must be a finite value of zero or more.',
      );
    }
    final current = await resolveExerciseAllocation(defId);
    final credits = Map<int, double>.from(
      dimension == ExerciseAllocationDimension.muscle
          ? current.muscleCredits
          : current.bodyPartCredits,
    );
    credits[targetId] = credit;
    await ExerciseAllocationDao.replacePersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<void> replacePersonalExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    if (credits.values.any((credit) => !credit.isFinite || credit < 0)) {
      throw ArgumentError(
        'Personal allocation credits must be finite and non-negative.',
      );
    }
    await ExerciseAllocationDao.replacePersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<void> resetPersonalExerciseAllocation({
    required int defId,
    required ExerciseAllocationDimension dimension,
  }) async {
    await ExerciseAllocationDao.resetPersonalCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
    );
  }

  /// Creator defaults are content-owned. This API exists for content seeding
  /// and tests, not normal user-facing settings.
  Future<void> replaceCreatorExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    if (credits.values.any((credit) => !credit.isFinite || credit < 0)) {
      throw ArgumentError(
        'Creator allocation credits must be finite and non-negative.',
      );
    }
    await ExerciseAllocationDao.replaceCreatorCredits(
      await database,
      exerciseDefinitionId: defId,
      dimension: dimension,
      credits: credits,
    );
  }

  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async {
    final def = await getExerciseDefinitionById(defId);
    if (def == null) return [];
    final allocation = await resolveExerciseAllocation(defId);

    return def.muscles.map((rm) {
      return ExerciseMusclePercent(
        exerciseDefId: defId,
        muscleId: rm.muscle.id,
        percent: allocation.muscleCredits[rm.muscle.id] ?? 0.0,
      );
    }).toList();
  }

  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async {
    final db = await database;
    final allocation = await resolveExerciseAllocation(defId);
    if (allocation.bodyPartCredits.isEmpty) return {};
    final bodyParts = await LookupDao.getAllBodyParts(db);
    final byId = {for (final bodyPart in bodyParts) bodyPart.id: bodyPart};
    return <BodyPart, double>{
      for (final entry in allocation.bodyPartCredits.entries)
        if (byId[entry.key] != null) byId[entry.key]!: entry.value,
    };
  }

  /// Estimate how one single set of [exerciseDefId] splits across its body-parts,
  /// *based on the definition’s muscle-percent hits*, not on logged history.
  Future<Map<BodyPart, double>> estimateBodyPartSetDistribution(
    int defId,
  ) async {
    return computeMuscleCalculatedBodyparts(defId);
  }

  /// For a given exercise definition, look at each associated muscle’s %-hit
  /// and push that % into every body-part that muscle maps to.
  Future<Map<BodyPart, double>> computeMuscleCalculatedBodyparts(
    int defId,
  ) async {
    final db = await database;
    final allocation = await resolveExerciseAllocation(defId);
    if (allocation.derivedBodyPartCredits.isEmpty) return {};
    final bodyParts = await LookupDao.getAllBodyParts(db);
    final byId = {for (final bodyPart in bodyParts) bodyPart.id: bodyPart};
    return <BodyPart, double>{
      for (final entry in allocation.derivedBodyPartCredits.entries)
        if (byId[entry.key] != null) byId[entry.key]!: entry.value,
    };
  }

  // ─── Session/Set Analytics ───────────────────────────────

  /// Fetches the total number of sets per body-part for a given time range.
  Future<Map<int, int>> _fetchWeightSetCountsByDefinition({
    required DateTime start,
    required DateTime end,
    int? defId,
  }) async {
    final db = await database;
    final args = <Object?>[
      TemporalSemantics.utcEpochMilliseconds(start),
      TemporalSemantics.utcEpochMilliseconds(end),
    ];
    final defFilter = defId == null ? '' : 'AND e.exercise_def_id = ?';
    if (defId != null) args.add(defId);

    final rows = await db.rawQuery('''
      SELECT e.exercise_def_id AS def_id, COUNT(s.id) AS set_count
      FROM sets s
      INNER JOIN exercises e ON e.id = s.exercise_id
      INNER JOIN sessions sess ON sess.id = e.session_id
      WHERE e.type = 'weight'
        AND e.exercise_def_id IS NOT NULL
        AND sess.completed_at_ms >= ? AND sess.completed_at_ms <= ?
        $defFilter
      GROUP BY e.exercise_def_id
      ''', args);

    return {
      for (final row in rows)
        row['def_id'] as int: ((row['set_count'] as num?) ?? 0).toInt(),
    };
  }

  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    final setCounts = await _fetchWeightSetCountsByDefinition(
      start: start,
      end: end,
    );
    if (setCounts.isEmpty) return {};

    // For each definition, fetch its body-part map and sum by lookup ID.
    // BodyPart is a plain value object, so two BodyPart(Chest) instances from
    // different exercise definitions are not equal as Map keys.
    final allBodyParts = await LookupDao.getAllBodyParts(db);
    final bodyPartById = {
      for (final bodyPart in allBodyParts) bodyPart.id: bodyPart,
    };
    final combinedById = <int, double>{};
    for (final entry in setCounts.entries) {
      final perDef = await fetchBodyPartSetsForExerciseOverTimeRange(
        defId: entry.key,
        start: start,
        end: end,
        setCountOverride: entry.value,
        bodyPartByIdOverride: bodyPartById,
      );
      perDef.forEach((bp, val) {
        combinedById[bp.id] = (combinedById[bp.id] ?? 0.0) + val;
      });
    }
    final combined = <BodyPart, double>{};
    combinedById.forEach((bodyPartId, val) {
      final bodyPart = bodyPartById[bodyPartId];
      if (bodyPart != null) {
        combined[bodyPart] = val;
      }
    });
    return combined;
  }

  ///// Fetches the total number of sets per body-part for a specific exercise definition
  /// over a given time range.
  Future<Map<BodyPart, double>> fetchBodyPartSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
    Map<int, BodyPart>? bodyPartByIdOverride,
  }) async {
    final db = await database;
    final setCount =
        setCountOverride ??
        (await _fetchWeightSetCountsByDefinition(
          start: start,
          end: end,
          defId: defId,
        ))[defId] ??
        0;
    if (setCount <= 0) return {};

    // 2) prepare results & body-part lookup
    final result = <BodyPart, double>{};
    final bpById =
        bodyPartByIdOverride ??
        {for (final bp in await LookupDao.getAllBodyParts(db)) bp.id: bp};

    final def = await DefinitionDao.getExerciseDefinitionById(db, defId);
    if (def == null) return {};
    final multiply = def.multiplyByRating;
    final ratingMul = def.rating / 100.0;
    final allocation = await resolveExerciseAllocation(defId);
    allocation.bodyPartHistoryCredits.forEach((bodyPartId, perSetCredit) {
      final bodyPart = bpById[bodyPartId];
      if (bodyPart != null) {
        result[bodyPart] = (result[bodyPart] ?? 0.0) + perSetCredit * setCount;
      }
    });

    if (multiply) {
      result.updateAll((bp, val) => val * ratingMul);
    }
    return result;
  }

  /// Fetches muscle set credits for a specific exercise definition over a time
  /// range. The allocation resolver retains the legacy manual-toggle behavior
  /// until an explicit creator or personal allocation replaces it.
  Future<Map<int, double>> fetchMuscleSetsForExerciseOverTimeRange({
    required int defId,
    required DateTime start,
    required DateTime end,
    int? setCountOverride,
  }) async {
    final db = await database;
    final setCount =
        setCountOverride ??
        (await _fetchWeightSetCountsByDefinition(
          start: start,
          end: end,
          defId: defId,
        ))[defId] ??
        0;
    if (setCount <= 0) return {};

    final def = await DefinitionDao.getExerciseDefinitionById(db, defId);
    if (def == null) return {};

    final multiply = def.multiplyByRating;
    final ratingMul = def.rating / 100.0;

    final allocation = await resolveExerciseAllocation(defId);

    // Multiply resolved per-set credits by the SQL-counted completed rows.
    final result = <int, double>{};
    allocation.muscleHistoryCredits.forEach((mid, perSet) {
      result[mid] = (result[mid] ?? 0) + perSet * setCount;
    });

    if (multiply) {
      result.updateAll((mid, val) => val * ratingMul);
    }
    return result;
  }

  /// Fetches the total number of “muscle-units” across *all* definitions
  /// for weight exercises in the given time window.
  Future<Map<int, double>> fetchAllMuscleSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final setCounts = await _fetchWeightSetCountsByDefinition(
      start: start,
      end: end,
    );
    if (setCounts.isEmpty) return {};

    // sum each definition’s muscle-units
    final combined = <int, double>{};
    for (final entry in setCounts.entries) {
      final perDef = await fetchMuscleSetsForExerciseOverTimeRange(
        defId: entry.key,
        start: start,
        end: end,
        setCountOverride: entry.value,
      );
      perDef.forEach((mid, val) {
        combined[mid] = (combined[mid] ?? 0) + val;
      });
    }

    return combined;
  }

  // GYM PROFILES

  /// Creates a new gym profile and returns its ID.
  Future<int> createProfile(String name) async {
    final db = await database;
    final newId = await ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: null,
      name: name,
      equipmentIds: const <int>{},
    );
    // copy app‐wide methods into the new profile default:
    return newId;
  }

  Future<int> saveGymProfileAtomic({
    required GymProfile? existingProfile,
    required String name,
    required Set<int> equipmentIds,
  }) async {
    final db = await database;
    return ProfileTransactionDao.saveGymProfile(
      db,
      existingProfile: existingProfile,
      name: name,
      equipmentIds: equipmentIds,
    );
  }

  Future<Set<int>> loadActivePlans(int profileId) async {
    final db = await database;
    return ActivePlanDao.load(db, profileId);
  }

  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {
    final db = await database;
    await ActivePlanDao.replace(db, profileId, presetIds);
  }

  Future<void> addActivePlan(int profileId, int presetId) async {
    final db = await database;
    await ActivePlanDao.add(db, profileId, presetId);
  }

  Future<void> removeActivePlan(int profileId, int presetId) async {
    final db = await database;
    await ActivePlanDao.remove(db, profileId, presetId);
  }

  Future<String?> getAppState(String key) async {
    final db = await database;
    await _ensureAppMetaTable(db);
    return _getAppMeta(db, key);
  }

  Future<void> setAppState(String key, String? value) async {
    final db = await database;
    await _ensureAppMetaTable(db);
    if (value == null) {
      await db.delete('app_meta', where: 'key = ?', whereArgs: [key]);
      return;
    }
    await _setAppMeta(db, key, value);
  }

  /// Retrieves all gym profiles.
  Future<List<GymProfile>> fetchAllProfiles() async {
    final db = await database;
    return GymProfileDao.getAllProfiles(db);
  }

  /// Updates an existing gym profile.
  Future<int> updateProfile(GymProfile profile) async {
    final db = await database;
    return GymProfileDao.updateProfile(db, profile);
  }

  /// Deletes a gym profile by ID.
  Future<int> deleteProfile(int profileId) async {
    final db = await database;
    return GymProfileDao.deleteProfile(db, profileId);
  }

  /// Adds equipment to a gym profile.
  Future<void> addEquipmentToProfile(int profileId, int equipmentId) async {
    final db = await database;
    await GymProfileDao.insertProfileEquipment(db, profileId, equipmentId);
  }

  /// Removes equipment from a gym profile.
  Future<void> removeEquipmentFromProfile(
    int profileId,
    int equipmentId,
  ) async {
    final db = await database;
    await GymProfileDao.deleteProfileEquipment(db, profileId, equipmentId);
  }

  /// Fetches equipment for a specific gym profile.
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async {
    final db = await database;
    return GymProfileDao.getEquipmentForProfile(db, profileId);
  }

  /// Look up an existing definition by name+equipment; throws if not found.
  Future<int> findExerciseDefinitionId(
    String name,
    String equipmentName,
  ) async {
    final db = await database;
    int? eqId;
    if (equipmentName.isNotEmpty) {
      final eqRows = await db.query(
        'equipment',
        where: 'name = ?',
        whereArgs: [equipmentName],
      );
      if (eqRows.isNotEmpty) eqId = eqRows.first['id'] as int;
    }
    final whereClause =
        eqId != null
            ? 'name = ? AND equipment_id = ?'
            : 'name = ? AND equipment_id IS NULL';
    final args = eqId != null ? [name, eqId] : [name];
    final rows = await db.query(
      'exercise_definitions',
      columns: ['id'],
      where: whereClause,
      whereArgs: args,
    );
    if (rows.isEmpty) {
      throw Exception('ExerciseDefinition("$name",$equipmentName) not found');
    }
    return rows.first['id'] as int;
  }

  /// Returns all sessions as WorkoutSession objects, sorted by date desc.
  Future<List<WorkoutSession>> fetchWorkoutSessions() async {
    // raw maps
    final raw = await getAllSessionsRaw();
    // map to model
    return raw
        .map(
          (row) => WorkoutSession(
            id: row['id'] as int,
            date: TemporalSemantics.readLocalDateTime(
              epochMilliseconds: row['completed_at_ms'],
              legacyIso: row['date'],
            ),
            calendarDayKey:
                TemporalSemantics.readCalendarDay(
                  calendarDay: row['training_day'],
                  legacyIso: row['date'],
                  epochMilliseconds: row['completed_at_ms'],
                ).storageKey,
            duration: row['duration'] as int,
          ),
        )
        .toList();
  }

  // ─── PRESETS: Definition CRUD ─────────────────────────────

  Future<int> createPreset(
    String name, {
    int? profileId,
    bool isDraft = false,
  }) async {
    final db = await database;
    return PresetTransactionDao.createPreset(
      db,
      name: name,
      profileId: profileId,
      exercises: const <WorkoutExerciseWrite>[],
      isDraft: isDraft,
    );
    // copy profile‐default methods into this preset (if profileId != null)
  }

  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool isDraft = false,
  }) async {
    final db = await database;
    return PresetTransactionDao.createPreset(
      db,
      name: name,
      profileId: profileId,
      exercises: exercises,
      autoSettings: autoSettings,
      activate: activate,
      isDraft: isDraft,
    );
  }

  Future<void> replacePresetAtomic({
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool publishDraft = false,
  }) async {
    final db = await database;
    await PresetTransactionDao.replacePreset(
      db,
      presetId: presetId,
      name: name,
      exercises: exercises,
      autoSettings: autoSettings,
      publishDraft: publishDraft,
    );
  }

  Future<void> savePresetAutoConfigurationAtomic({
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) async {
    final db = await database;
    await PresetTransactionDao.saveAutoConfiguration(
      db,
      presetId: presetId,
      configuration: configuration,
    );
  }

  Future<int> findOrCreatePreset(String name, {int? profileId}) async {
    final db = await database;
    final whereClause =
        profileId != null
            ? 'name = ? AND profile_id = ? AND is_draft = 0'
            : 'name = ? AND profile_id IS NULL AND is_draft = 0';
    final whereArgs = profileId != null ? [name, profileId] : [name];
    final existing = await db.query(
      'preset_definitions',
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return createPreset(name, profileId: profileId);
  }

  Future<Map<String, dynamic>?> fetchDraftPresetForProfile(
    int profileId,
  ) async {
    final db = await database;
    return PresetDefinitionDao.getDraftForProfile(db, profileId);
  }

  Future<void> deleteDraftPresetsForProfile(int profileId) async {
    final db = await database;
    await PresetDefinitionDao.deleteDraftsForProfile(db, profileId);
  }

  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async {
    final db = await database;
    return PresetDefinitionDao.getAllPresetsRaw(db, profileId: profileId);
  }

  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async {
    final db = await database;
    final where =
        profileId != null
            ? 'WHERE p.profile_id = ? AND p.is_draft = 0'
            : 'WHERE p.is_draft = 0';
    return db.rawQuery('''
      SELECT
        p.id AS id,
        p.name AS name,
        p.created_at AS created_at,
        p.profile_id AS profile_id,
        COALESCE(a.is_automatic, 0) AS is_automatic
      FROM preset_definitions p
      LEFT JOIN preset_auto_settings a ON a.preset_id = p.id
      $where
      ORDER BY p.created_at
      ''', profileId != null ? [profileId] : const <Object?>[]);
  }

  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async {
    if (presetIds.isEmpty) return const <Map<String, dynamic>>[];

    final db = await database;
    final rows = <Map<String, dynamic>>[];
    final uniquePresetIds = presetIds.toSet().toList();
    for (final chunk in sqliteChunks(uniquePresetIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      rows.addAll(
        await db.rawQuery('''
          SELECT
            pe.preset_id AS preset_id,
            pe.exercise_def_id AS def_id,
            COUNT(ps.id) AS set_count
          FROM preset_exercises pe
          LEFT JOIN preset_sets ps ON ps.preset_exercise_id = pe.id
          WHERE pe.type = 'weight'
            AND pe.exercise_def_id IS NOT NULL
            AND pe.preset_id IN ($placeholders)
          GROUP BY pe.preset_id, pe.exercise_def_id
          ''', chunk),
      );
    }

    return rows;
  }

  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    final db = await database;
    final row = await PresetDefinitionDao.getPresetById(db, presetId);
    if (row == null) return null;
    return PresetDefinition(
      id: row['id'] as int,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      profileId: row['profile_id'] as int?,
      isDraft: (row['is_draft'] as int? ?? 0) == 1,
    );
  }

  Future<void> updatePresetName(int presetId, String name) async {
    final db = await database;
    await PresetDefinitionDao.updatePresetName(db, presetId, name);
  }

  Future<void> deletePreset(int presetId) async {
    final db = await database;
    await PresetDefinitionDao.deletePreset(db, presetId);
  }

  // ─── PRESETS: Exercise CRUD ───────────────────────────────

  Future<int> addExerciseToPreset(
    int presetId,
    int? exerciseDefId,
    String type,
    int orderIndex,
  ) async {
    final db = await database;
    return PresetExerciseDao.insertPresetExercise(
      db: db,
      presetId: presetId,
      exerciseDefId: exerciseDefId,
      type: type,
      orderIndex: orderIndex,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
    final db = await database;
    return PresetExerciseDao.getExercisesForPreset(db, presetId);
  }

  Future<void> deletePresetExercises(int presetId) async {
    final db = await database;
    await PresetExerciseDao.deleteExercisesForPreset(db, presetId);
  }

  // ─── PRESETS: Detail CRUD ─────────────────────────────────

  Future<void> savePresetWeightSets(
    int presetExerciseId,
    List<ExerciseSet> parents,
    Map<int, List<ExerciseSet>> children,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetSets(
      db: db,
      presetExerciseId: presetExerciseId,
      parentSets: parents,
      childChangeSets: children,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetDetailDao.getPresetSets(db, presetExerciseId);
  }

  Future<void> savePresetCardio(
    int presetExerciseId,
    String cardioName,
    String? note,
    int plannedMinutes,
    int elapsedSeconds,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetCardioDetails(
      db: db,
      presetExerciseId: presetExerciseId,
      cardioName: cardioName,
      note: note,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: elapsedSeconds,
    );
  }

  Future<Map<String, dynamic>?> fetchPresetCardio(int presetExerciseId) async {
    final db = await database;
    return PresetDetailDao.getPresetCardioDetails(db, presetExerciseId);
  }

  Future<void> savePresetStretch(
    int presetExerciseId,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    await PresetDetailDao.insertPresetStretchItems(
      db: db,
      presetExerciseId: presetExerciseId,
      items: items,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPresetStretchItems(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetDetailDao.getPresetStretchItems(db, presetExerciseId);
  }

  // ─── AUTOPRESET SETTINGS WRAPPERS ───────────────────────────────────────

  /// Fetches the global auto‐preset settings for a given preset.
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async {
    final db = await database;
    return PresetAutoSettingsDao.getAutoSettings(db, presetId);
  }

  /// Inserts or updates the global auto‐preset settings.
  Future<void> upsertPresetAutoSettings({
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool weightCheck,
    required bool repCheck,
    required bool volumeCheck,
    required bool adjustAllSets,
    required bool useManualSelect, // ← NEW
    String? manualSelectionJson, // ← NEW
    String? successCountMode,
  }) async {
    final db = await database;
    await PresetAutoSettingsDao.upsertAutoSettings(
      db,
      presetId: presetId,
      isAutomatic: isAutomatic,
      globalIncrement: globalIncrement,
      skipFirstSet: skipFirstSet,
      weightCheck: weightCheck,
      repCheck: repCheck,
      volumeCheck: volumeCheck,
      adjustAllSets: adjustAllSets,
      useManualSelect: useManualSelect, // ← PASS THROUGH
      manualSelectionJson: manualSelectionJson, // ← PASS THROUGH
      successCountMode: successCountMode,
    );
  }

  /// Deletes the auto‐preset settings (disables automatic) for a preset.
  Future<void> deletePresetAutoSettings(int presetId) async {
    final db = await database;
    await PresetAutoSettingsDao.deleteAutoSettings(db, presetId);
  }

  // ─── PER-EXERCISE OVERRIDES ──────────────────────────────────────────────

  /// Fetches the auto override (IA + rotation) for a specific preset exercise.
  /// Fetches auto overrides _including_ last_node.
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async {
    final db = await database;
    return PresetExerciseAutoDao.getExerciseAuto(db, presetExerciseId);
  }

  /// Inserts or updates the per-exercise IA override and last_set_index.
  /// Upsert with lastNode.
  Future<void> upsertPresetExerciseAuto({
    required int presetExerciseId,
    double? incrementAmount,
    required int lastSetIndex,
    String? lastNode,
  }) async {
    final db = await database;
    await PresetExerciseAutoDao.upsertExerciseAuto(
      db,
      presetExerciseId: presetExerciseId,
      incrementAmount: incrementAmount,
      lastSetIndex: lastSetIndex,
      lastNode: lastNode,
    );
  }

  /// Deletes the per-exercise auto override for a preset exercise.
  Future<void> deletePresetExerciseAuto(int presetExerciseId) async {
    final db = await database;
    await PresetExerciseAutoDao.deleteExerciseAuto(db, presetExerciseId);
  }

  // ─── PER-SET OVERRIDES ──────────────────────────────────────────────────

  /// Fetches the per-set IA override for a specific preset set.
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async {
    final db = await database;
    return PresetSetAutoDao.getSetAuto(db, presetSetId);
  }

  /// Inserts or updates the per-set IA override.
  Future<void> upsertPresetSetAuto({
    required int presetSetId,
    double? incrementAmount,
  }) async {
    final db = await database;
    await PresetSetAutoDao.upsertSetAuto(
      db,
      presetSetId: presetSetId,
      incrementAmount: incrementAmount,
    );
  }

  /// Deletes the per-set IA override for a preset set.
  Future<void> deletePresetSetAuto(int presetSetId) async {
    final db = await database;
    await PresetSetAutoDao.deleteSetAuto(db, presetSetId);
  }

  /// Update the target weight of a preset set.
  Future<void> updatePresetSetWeight(int presetSetId, double weight) async {
    final db = await database;
    await PresetDetailDao.updatePresetSetWeight(
      db: db,
      presetSetId: presetSetId,
      weight: weight,
    );
  }

  /// Fetch the flow‐graph JSON for a preset.
  Future<String> fetchFlowDefinition(int presetId) async {
    final db = await database;
    return PresetAutoSettingsDao.getFlowDefinition(db, presetId);
  }

  /// Save the flow‐graph JSON for a preset.
  Future<void> upsertFlowDefinition(int presetId, String flowJson) async {
    final db = await database;
    await PresetAutoSettingsDao.upsertFlowDefinition(db, presetId, flowJson);
  }

  /// Fetch all user‐defined methods for a preset.
  Future<List<Map<String, dynamic>>> fetchFlowMethods(int presetId) async {
    final db = await database;
    return PresetFlowMethodsDao.getMethods(db, presetId);
  }

  /// Insert or update a flow method; returns its new row ID.
  Future<int> upsertFlowMethod({
    required int presetId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    final paramsJson = jsonEncode(params);
    return PresetFlowMethodsDao.upsertMethod(
      db,
      presetId: presetId,
      name: name,
      type: type,
      paramsJson: paramsJson,
    );
  }

  /// Delete a flow method by ID.
  Future<int> deleteFlowMethod(int methodId) async {
    final db = await database;
    return PresetFlowMethodsDao.deleteMethod(db, methodId);
  }

  Future<void> updatePresetSetReps(int presetSetId, int reps) async {
    final db = await database;
    await PresetDetailDao.updatePresetSetReps(
      db: db,
      presetSetId: presetSetId,
      reps: reps,
    );
  }

  Future<int> addPresetSet({
    required int presetExerciseId,
    required double weight,
    required int reps,
    required int orderIndex,
    int? parentSetId,
  }) async {
    final db = await database;
    return PresetDetailDao.addPresetSet(
      db: db,
      presetExerciseId: presetExerciseId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
      parentSetId: parentSetId,
    );
  }

  Future<int> deletePresetSet(int presetSetId) async {
    final db = await database;
    return PresetDetailDao.deletePresetSet(db: db, presetSetId: presetSetId);
  }

  /// Applies one workout's preset progression as a single transaction.
  Future<void> applyPresetProgressionBatch(
    PresetProgressionBatch progression,
  ) async {
    final db = await database;
    await PresetProgressionDao.apply(db, progression);
  }

  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async {
    final db = await database;
    return PendingWorkoutProgressionDao.loadAll(db);
  }

  Future<void> recordPendingWorkoutProgressionFailure(int sessionId) async {
    final db = await database;
    await PendingWorkoutProgressionDao.recordFailedAttempt(db, sessionId);
  }

  Future<void> completePendingWorkoutProgression({
    required int sessionId,
    required PresetProgressionBatch progression,
  }) async {
    final db = await database;
    await PendingWorkoutProgressionDao.applyAndDelete(
      db,
      sessionId: sessionId,
      progression: progression,
    );
  }

  Future<bool> getUseManualBodyparts(int defId) async {
    final db = await database;
    final r = await db.query(
      'exercise_definitions',
      columns: ['use_manual_bodyparts'],
      where: 'id = ?',
      whereArgs: [defId],
      limit: 1,
    );
    if (r.isEmpty) return false;
    final v = r.first['use_manual_bodyparts'];
    return v is int ? v == 1 : (v is bool ? v : false);
  }

  Future<void> setUseManualBodyparts(int defId, bool value) async {
    final db = await database;
    await db.update(
      'exercise_definitions',
      {'use_manual_bodyparts': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [defId],
    );
  }

  /// Returns whether the exercise definition uses manual muscle selection.
  Future<bool> getUseManualMuscles(int defId) async {
    final db = await database;
    final r = await db.query(
      'exercise_definitions',
      columns: ['use_manual_muscles'],
      where: 'id = ?',
      whereArgs: [defId],
      limit: 1,
    );
    if (r.isEmpty) return false;
    final v = r.first['use_manual_muscles'];
    return v is int ? v == 1 : (v is bool ? v : false);
  }

  /// Sets whether the exercise definition uses manual muscle selection.
  Future<void> setUseManualMuscles(int defId, bool v) async {
    final db = await database;
    await db.update(
      'exercise_definitions',
      {'use_manual_muscles': v ? 1 : 0},
      where: 'id = ?',
      whereArgs: [defId],
    );
  }

  /// Proxy onto DefinitionDao for multiply-by-rating.
  Future<bool> getMultiplyByRating(int defId) async {
    final db = await database; // ensure you await your getter
    return DefinitionDao.getMultiplyByRating(db, defId);
  }

  /// Proxy onto DefinitionDao for multiply-by-rating.
  Future<void> setMultiplyByRating(int defId, bool enabled) async {
    final db = await database; // unwrap the nullable
    await DefinitionDao.setMultiplyByRating(db, defId, enabled);
  }

  // ─── FLOW‐CHART DEFAULTS (v17 tables) ───────────────────────────────────

  ({String whereClause, List<Object?> arguments}) _flowScopeFilter(
    String scope,
    int? profileId,
  ) {
    return profileId == null
        ? (
          whereClause: 'scope = ? AND profile_id IS NULL',
          arguments: <Object?>[scope],
        )
        : (
          whereClause: 'scope = ? AND profile_id = ?',
          arguments: <Object?>[scope, profileId],
        );
  }

  /// Fetch the saved default flow JSON for either the whole app or a specific profile.
  Future<String> fetchDefaultFlow(String scope, {int? profileId}) async {
    final db = await database;
    final filter = _flowScopeFilter(scope, profileId);
    final rows = await db.query(
      'flow_defaults',
      columns: ['flow_json'],
      where: filter.whereClause,
      whereArgs: filter.arguments,
      limit: 1,
    );
    if (rows.isEmpty) return '{}';
    return rows.first['flow_json'] as String;
  }

  /// Upsert default flow JSON for scope=('app' or 'profile') and optional profileId.
  Future<void> upsertDefaultFlow(
    String scope, {
    int? profileId,
    required String flowJson,
  }) async {
    final db = await database;
    final values = {
      'scope': scope,
      'profile_id': profileId,
      'flow_json': flowJson,
    };
    final filter = _flowScopeFilter(scope, profileId);
    final updated = await db.update(
      'flow_defaults',
      values,
      where: filter.whereClause,
      whereArgs: filter.arguments,
    );
    if (updated == 0) {
      await db.insert('flow_defaults', values);
    }
  }

  /// Delete a default flow entry.
  Future<int> deleteDefaultFlow(String scope, {int? profileId}) async {
    final db = await database;
    final filter = _flowScopeFilter(scope, profileId);
    return db.delete(
      'flow_defaults',
      where: filter.whereClause,
      whereArgs: filter.arguments,
    );
  }

  /// Fetch all the methods attached to an app/profile default.
  Future<List<Map<String, dynamic>>> fetchDefaultFlowMethods(
    String scope, {
    int? profileId,
  }) async {
    final db = await database;
    final filter = _flowScopeFilter(scope, profileId);
    return db.rawQuery('''
      SELECT rowid AS id, scope, profile_id, name, type, params
      FROM flow_default_methods
      WHERE ${filter.whereClause}
      ORDER BY name
      ''', filter.arguments);
  }

  /// Upsert one method into the default‐methods table (conflict on PK(scope,profile_id,name)).
  Future<int> upsertDefaultFlowMethod(
    String scope, {
    int? profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params, // <-- accept a Map
  }) async {
    final db = await database;
    final paramsJson = jsonEncode(params); // <-- encode here
    final scopeFilter = _flowScopeFilter(scope, profileId);
    final defaultRows = await db.query(
      'flow_defaults',
      columns: ['scope'],
      where: scopeFilter.whereClause,
      whereArgs: scopeFilter.arguments,
      limit: 1,
    );
    if (defaultRows.isEmpty) {
      await db.insert('flow_defaults', {
        'scope': scope,
        'profile_id': profileId,
        'flow_json': '{}',
      });
    }
    final values = {
      'scope': scope,
      'profile_id': profileId,
      'name': name,
      'type': type,
      'params': paramsJson, // <-- store JSON string
    };
    final whereClause = '${scopeFilter.whereClause} AND name = ?';
    final args = [...scopeFilter.arguments, name];
    final updated = await db.update(
      'flow_default_methods',
      values,
      where: whereClause,
      whereArgs: args,
    );
    if (updated == 0) {
      await db.insert('flow_default_methods', values);
    }
    final rows = await db.rawQuery(
      'SELECT rowid AS id FROM flow_default_methods WHERE $whereClause LIMIT 1',
      args,
    );
    return rows.isEmpty ? 0 : rows.first['id'] as int;
  }

  /// Adds a new app default rule to existing profiles without changing
  /// profile-specific rules or saved flow graphs.
  Future<int> copyAppDefaultRuleToExistingProfiles({
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    return ProgressionRulePropagationDao.copyAppRuleToExistingProfiles(
      db,
      name: name,
      type: type,
      paramsJson: jsonEncode(params),
    );
  }

  /// Adds a new profile default rule to that profile's existing plans without
  /// replacing plan-specific rules or saved flow graphs.
  Future<int> copyProfileDefaultRuleToExistingPlans({
    required int profileId,
    required String name,
    required String type,
    required Map<String, dynamic> params,
  }) async {
    final db = await database;
    return ProgressionRulePropagationDao.copyProfileRuleToExistingPlans(
      db,
      profileId: profileId,
      name: name,
      type: type,
      paramsJson: jsonEncode(params),
    );
  }

  /// Delete one default method by name.
  Future<int> deleteDefaultFlowMethod(
    String scope, {
    int? profileId,
    required String name,
  }) async {
    final db = await database;
    final scopeFilter = _flowScopeFilter(scope, profileId);
    final whereClause = '${scopeFilter.whereClause} AND name = ?';
    final args = [...scopeFilter.arguments, name];
    return db.delete(
      'flow_default_methods',
      where: whereClause,
      whereArgs: args,
    );
  }

  /// Returns a FlowDefinition for the given scope ('app' or 'profile') by
  /// delegating to the flow_defaults table and parsing its JSON.
  Future<FlowDefinition> fetchDefaultFlowDefinition(
    String scope, {
    int? profileId,
  }) async {
    // Reuse the string-based helper
    final jsonStr = await fetchDefaultFlow(scope, profileId: profileId);
    return FlowDefinition.fromJson(jsonStr);
  }

  // ── Forwarders that wrap the DAO ─────────────────────────────

  Future<PersonalInfo?> getPersonalInfo() async {
    final db = await database;
    return PersonalInfoDao(db).get();
  }

  Future<int> upsertPersonalInfo(PersonalInfo info) async {
    final db = await database;
    return PersonalInfoDao(db).upsert(info);
  }

  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) async {
    final db = await database;
    await PersonalInfoTransactionDao.save(
      db,
      info: info,
      bodyWeightValue: bodyWeightValue,
      bodyWeightUnit: bodyWeightUnit,
      measurementNote: measurementNote,
    );
  }

  // NUTIRITOINNNNN ------------------------------------

  Future<void> seedNutrientsIfEmpty() async {
    final d = NutritionDao(await database);
    await d.seedNutrientsIfEmpty();
  }

  // Foods & search
  Future<int> upsertFood(Food f) async =>
      NutritionDao(await database).upsertFood(f);
  Future<Food?> getFood(int id) async =>
      NutritionDao(await database).getFood(id);
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async =>
      NutritionDao(await database).searchFoods(query, limit: limit);
  Future<int> upsertFoodPortion(FoodPortion p) async =>
      NutritionDao(await database).upsertFoodPortion(p);
  Future<List<FoodPortion>> getPortionsForFood(int foodId) async =>
      NutritionDao(await database).getPortionsForFood(foodId);
  Future<void> setDefaultPortion(int foodId, int portionId) async =>
      NutritionDao(await database).setDefaultPortion(foodId, portionId);

  // Nutrients
  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) async =>
      NutritionDao(await database).upsertFoodNutrients(foodId, rows);
  Future<Map<int, double>> getFoodNutrientsPer100g(int foodId) async =>
      NutritionDao(await database).getFoodNutrientsPer100g(foodId);

  Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) async {
    return NutritionDao(await database).getFoodNutrientsPer100gByCode(foodId);
  }

  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async {
    final all = await getFoodNutrientsPer100gByCode(foodId);

    double? pick(List<String> codes) {
      for (final code in codes) {
        final value = all[code];
        if (value != null) return value;
      }
      return null;
    }

    final out = <String, double>{};
    final protein = pick(['PROTEIN_G', 'PROTEIN']);
    if (protein != null) out['PROTEIN_G'] = protein;
    final carbs = pick(['CARB_G', 'CARB']);
    if (carbs != null) out['CARB_G'] = carbs;
    final fat = pick(['FAT_G', 'FAT']);
    if (fat != null) out['FAT_G'] = fat;
    final kcal = pick(['KCAL', 'ENERGY_KCAL', 'CALORIES']);
    if (kcal != null) out['KCAL'] = kcal;
    return out;
  }

  // Recipes
  Future<int> createOrUpdateRecipe(
    Recipe r,
    List<RecipeIngredient> ings,
  ) async => NutritionDao(await database).createOrUpdateRecipe(r, ings);
  Future<Recipe?> getRecipe(int id) async =>
      NutritionDao(await database).getRecipe(id);
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async =>
      NutritionDao(await database).getRecipeIngredients(recipeId);

  // Diary
  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride, // legacy
    double? loggedGrams, // NEW: forward to DAO
    DateTime? loggedAt, // NEW: forward to DAO
    String? notes,
  }) async => NutritionDao(await database).addDiaryFood(
    profileId: profileId,
    date: date,
    mealType: mealType,
    foodId: foodId,
    portionId: portionId,
    quantity: quantity,
    gramsOverride: gramsOverride,
    loggedGrams: loggedGrams, // <—
    loggedAt: loggedAt, // <—
    notes: notes,
  );

  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt, // NEW: forward to DAO
    String? notes,
  }) async => NutritionDao(await database).addDiaryRecipe(
    profileId: profileId,
    date: date,
    mealType: mealType,
    recipeId: recipeId,
    quantity: quantity,
    loggedAt: loggedAt, // <—
    notes: notes,
  );

  Future<void> updateDiaryEntry(DiaryEntry e) async =>
      NutritionDao(await database).updateDiaryEntry(e);

  Future<void> deleteDiaryEntry(
    int id, {
    required int profileId,
    required DateTime date,
  }) async => NutritionDao(
    await database,
  ).deleteDiaryEntry(id, profileId: profileId, date: date);

  Future<List<DiaryEntry>> getDiaryEntriesForDate(
    int profileId,
    DateTime date,
  ) async =>
      NutritionDao(await database).getDiaryEntriesForDate(profileId, date);

  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime day,
  ) async => NutritionDao(
    await database,
  ).getDiaryEntriesWithItemsForDate(profileId, day);

  // Goals
  Future<void> setGoals(NutritionGoal goal) async =>
      NutritionDao(await database).setGoals(goal);

  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      NutritionDao(await database).getActiveGoals(profileId, date);

  // Day totals cache
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async =>
      NutritionDao(await database).getDayTotals(profileId, date);

  Future<void> recalcDayTotals(int profileId, DateTime date) async =>
      NutritionDao(await database).recalcDayTotals(profileId, date);

  Future<int> createCustomFood({required String name, String? brand}) async {
    return NutritionDao(
      await database,
    ).insertCustomFood(name: name, brand: brand);
  }

  Future<void> savePer100gByCode(
    int foodId,
    Map<String, double> codeToAmount,
  ) async {
    await NutritionDao(
      await database,
    ).replacePer100gByCode(foodId, codeToAmount);
  }

  Future<void> savePer100gFromLabelPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) async {
    await NutritionDao(
      await database,
    ).savePer100gFromLabelPayload(foodId, payload);
  }

  /// Extracts leaf labels from the customization payload and persists per-100g values
  /// using nutrient_aliases to resolve labels.
  Future<void> saveExtendedPer100gFromPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) async {
    const skip = {
      'name',
      'brand',
      'calories',
      'protein_g',
      'carbs_g',
      'fats_g',
    };

    final aliasMap = <String, double>{};
    for (final entry in payload.entries) {
      final key = entry.key;
      if (skip.contains(key)) continue;

      final rawVal = entry.value;
      if (rawVal == null) continue;

      final val =
          (rawVal is num) ? rawVal.toDouble() : double.tryParse('$rawVal');
      if (val == null) continue;

      final lastGt = key.lastIndexOf('>');
      final alias = (lastGt == -1 ? key : key.substring(lastGt + 1)).trim();

      aliasMap[alias] = val;
    }
    if (aliasMap.isEmpty) return;
    await NutritionDao(await database).savePer100gByAlias(foodId, aliasMap);
  }

  Future<int> addPortion(
    int foodId, {
    required String measureName,
    double? gramWeight,
    double? mlVolume,
    bool isDefault = false,
    // v23 fields:
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) async {
    return NutritionDao(await database).addPortion(
      foodId,
      measureName: measureName,
      gramWeight: gramWeight,
      mlVolume: mlVolume,
      isDefault: isDefault,
      listKind: listKind,
      sortOrder: sortOrder,
      amount: amount,
      unit: unit,
      label: label,
    );
  }

  Future<void> replacePortions(int foodId, List<FoodPortion> portions) async {
    await NutritionDao(await database).replacePortions(foodId, portions);
  }

  Future<void> updateFoodBasics(int id, {String? name, String? brand}) async {
    return NutritionDao(
      await database,
    ).updateFoodBasics(id, name: name, brand: brand);
  }

  Future<void> updateFoodFromCustomizationPayload(Map payload) async {
    // 1) ID is required for updates
    final foodId = (payload['food_id'] as num?)?.toInt();
    if (foodId == null) {
      throw ArgumentError('food_id is required for updates');
    }

    // 2) Update basic shell (name/brand)
    final name = (payload['name'] as String?)?.trim();
    final brand = (payload['brand'] as String?)?.trim();
    await updateFoodBasics(foodId, name: name, brand: brand);

    // 2b) Optional: density (g/ml)
    final densRaw = payload['density_g_per_ml'];
    if (densRaw != null) {
      final dens =
          (densRaw is num) ? densRaw.toDouble() : double.tryParse('$densRaw');
      if (dens != null) {
        final db = await database;
        await db.update(
          'foods',
          {
            'density_g_per_ml': dens > 0 ? dens : null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [foodId],
        );
      }
    }

    // 2c) Optional: barcode(s)
    final bc = payload['barcodes'] ?? payload['barcode'];
    if (bc != null) {
      final list = (bc is List) ? bc : [bc];
      for (final v in list) {
        final s = '$v'.trim();
        if (s.isNotEmpty) {
          await addBarcode(foodId, s);
        }
      }
    }

    // 3) Replace per-100g values using your flexible label mapper
    await savePer100gFromLabelPayload(
      foodId,
      Map<String, dynamic>.from(payload),
    );

    // 4) Replace portions
    final List portionsJson = (payload['portions'] as List?) ?? const [];
    if (portionsJson.isNotEmpty) {
      final portions = <FoodPortion>[];
      for (final p in portionsJson) {
        final m = Map<String, dynamic>.from(p as Map);
        final rawDefault = m['is_default'];
        final isDefault =
            rawDefault is bool
                ? rawDefault
                : (rawDefault is num ? rawDefault.toInt() == 1 : false);

        portions.add(
          FoodPortion(
            id: null, // replacePortions wipes & re-inserts
            foodId: foodId,
            measureName: m['measure_name'] as String,
            gramWeight: (m['gram_weight'] as num?)?.toDouble(),
            mlVolume: (m['ml_volume'] as num?)?.toDouble(),
            isDefault: isDefault,
            listKind: m['list_kind'] as String?, // 'basis' | 'usual'
            sortOrder: m['sort_order'] as int?,
            amount: (m['amount'] as num?)?.toDouble(),
            unit: m['unit'] as String?,
            label: m['label'] as String?,
          ),
        );
      }
      await replacePortions(foodId, portions);
    }
  }

  // Normalized upsert using brand/source/category + barcodes
  Future<int> upsertFoodWithKeys({
    int? id,
    required String name,
    String? brandName,
    String? sourceName,
    String? categoryName,
    List<String> barcodes = const [],
    double? densityGPerMl,
    bool isCustom = false,
    String? dataSource,
    String? dataSourceId,
  }) async => NutritionDao(await database).upsertFoodWithKeys(
    id: id,
    name: name,
    brandName: brandName,
    sourceName: sourceName,
    categoryName: categoryName,
    barcodes: barcodes,
    densityGPerMl: densityGPerMl,
    isCustom: isCustom,
    dataSource: dataSource,
    dataSourceId: dataSourceId,
  );

  Future<Food?> getFoodByBarcode(String code) async =>
      NutritionDao(await database).getFoodByBarcode(code);

  Future<void> addBarcode(int foodId, String code) async {
    await NutritionDao(await database).addBarcode(foodId, code);
  }

  // Quick calculator for a portion selection
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async => NutritionDao(
    await database,
  ).calcForPortion(foodId: foodId, portionId: portionId, quantity: quantity);

  // Optional: manual rebuild for FTS caller
  Future<void> rebuildFoodFts() async =>
      _rebuildFoodFtsIfExists(await database);

  Future<bool> _tableHasColumn(
    DatabaseExecutor db,
    String table,
    String col,
  ) async {
    final rows = await db.rawQuery("PRAGMA table_info($table)");
    return rows.any(
      (r) => (r['name'] as String).toLowerCase() == col.toLowerCase(),
    );
  }

  Future<bool> _tableExists(DatabaseExecutor db, String name) async {
    final rows = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name=? LIMIT 1",
      [name],
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> _tableNames(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return rows.map((row) => row['name']).whereType<String>().toSet();
  }

  Future<int> _countRowsIfTableExists(DatabaseExecutor db, String name) async {
    if (!await _tableExists(db, name)) return 0;
    try {
      return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $name'),
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _rebuildAllRecipeCaches(Database db) async {
    final rows = await db.query('recipes', columns: ['id']);
    final dao = NutritionDao(db);
    for (final r in rows) {
      await dao.rebuildRecipeNutrientCache(r['id'] as int);
    }
  }

  /// Ensures KCAL exists per_100g for foods that have P/C/F but no KCAL yet.
  /// Also mirrors into legacy food_nutrients for back-compat reads.
  Future<void> _backfillEnergyKcalFromMacros(DatabaseExecutor db) async {
    // Find IDs for KCAL/PROTEIN_G/CARB_G/FAT_G
    final ids = await db.query(
      'nutrients',
      columns: ['id', 'code'],
      where: 'code IN (?,?,?,?)',
      whereArgs: ['KCAL', 'PROTEIN_G', 'CARB_G', 'FAT_G'],
    );

    int? kcalId, pId, cId, fId;
    for (final r in ids) {
      switch (r['code'] as String) {
        case 'KCAL':
          kcalId = r['id'] as int;
          break;
        case 'PROTEIN_G':
          pId = r['id'] as int;
          break;
        case 'CARB_G':
          cId = r['id'] as int;
          break;
        case 'FAT_G':
          fId = r['id'] as int;
          break;
      }
    }
    if (kcalId == null || pId == null || cId == null || fId == null) return;

    // Insert KCAL rows into flexible table when missing but P/C/F exist.
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO food_nutrient_values(food_id, nutrient_id, amount, basis)
      SELECT p.food_id, ?, (4.0*p.amount + 4.0*c.amount + 9.0*f.amount), 'per_100g'
      FROM food_nutrient_values p
      JOIN food_nutrient_values c ON c.food_id = p.food_id AND c.nutrient_id = ? AND c.basis = 'per_100g'
      JOIN food_nutrient_values f ON f.food_id = p.food_id AND f.nutrient_id = ? AND f.basis = 'per_100g'
      LEFT JOIN food_nutrient_values k ON k.food_id = p.food_id AND k.nutrient_id = ? AND k.basis = 'per_100g'
      WHERE p.nutrient_id = ? AND p.basis = 'per_100g' AND k.food_id IS NULL
    ''',
      [kcalId, cId, fId, kcalId, pId],
    );

    // Mirror into legacy table for older code paths.
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO food_nutrients(food_id, nutrient_id, amount_per_100g)
      SELECT v.food_id, ?, v.amount
      FROM food_nutrient_values v
      WHERE v.nutrient_id = ? AND v.basis = 'per_100g'
    ''',
      [kcalId, kcalId],
    );
  }

  // --- Diary (range) ---------------------------------------------------------
  Future<List<DiaryEntry>> getDiaryEntriesBetween(
    int profileId,
    DateTime start,
    DateTime end, {
    MealType? mealType,
    int limit = 1000,
  }) async {
    var s = start, e = end;
    if (s.isAfter(e)) {
      final t = s;
      s = e;
      e = t;
    }
    return NutritionDao(
      await database,
    ).getDiaryEntriesBetween(profileId, s, e, mealType: mealType, limit: limit);
  }

  // --- Day micro aggregation -------------------------------------------------
  Future<Map<String, double>> getDayMicros(
    int profileId,
    DateTime date,
    List<String> codes,
  ) async => NutritionDao(await database).getDayMicros(profileId, date, codes);

  // --- Favorites -------------------------------------------------------------
  Future<void> addFavorite(int profileId, int foodId) async =>
      NutritionDao(await database).addFavorite(profileId, foodId);

  Future<void> removeFavorite(int profileId, int foodId) async =>
      NutritionDao(await database).removeFavorite(profileId, foodId);

  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      NutritionDao(await database).listFavorites(profileId, limit: limit);

  // --- Recents ---------------------------------------------------------------
  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) async =>
      NutritionDao(await database).getRecentFoods(profileId, limit: limit);

  Future<List<Recipe>> getRecentRecipes(
    int profileId, {
    int limit = 20,
  }) async =>
      NutritionDao(await database).getRecentRecipes(profileId, limit: limit);

  // --- Tags ------------------------------------------------------------------
  Future<void> addDiaryTag(int entryId, String tag) async =>
      NutritionDao(await database).addDiaryTag(entryId, tag);

  Future<void> removeDiaryTag(int entryId, String tag) async =>
      NutritionDao(await database).removeDiaryTag(entryId, tag);

  Future<List<String>> getTagsForEntry(int entryId) async =>
      NutritionDao(await database).getTagsForEntry(entryId);

  Future<List<DiaryEntry>> getEntriesByTag({
    required int profileId,
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) async => NutritionDao(await database).getEntriesByTag(
    profileId: profileId,
    tag: tag,
    start: start,
    end: end,
    limit: limit,
  );

  // --- Recipe cache reads (handy for UI) ------------------------------------
  Future<Map<String, double>> getRecipePer100gByCode(int recipeId) async =>
      NutritionDao(await database).getRecipePer100gByCode(recipeId);

  Future<void> rebuildRecipeNutrientCache(int recipeId) async =>
      NutritionDao(await database).rebuildRecipeNutrientCache(recipeId);

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    _dbFuture = null;
  }

  /// Removes only the explicitly named device-test database.
  ///
  /// This is intentionally guarded by compile-time defines so integration
  /// tests cannot accidentally clear a person's normal workout history.
  Future<void> resetIntegrationTestDatabase() async {
    if (!_kIntegrationTestMode ||
        _kDatabaseName != _kIntegrationTestDatabaseName) {
      throw StateError(
        'Integration database reset requires '
        'TONOS_INTEGRATION_TEST=true and '
        'TONOS_DATABASE_NAME=$_kIntegrationTestDatabaseName.',
      );
    }
    await close();
    await deleteDatabase(await _dbFilePath());
    _fts4Available = null;
  }

  Future<void> _bumpAutoincrement(DatabaseExecutor db) async {
    // sqlite_sequence only exists if at least one table was created with AUTOINCREMENT
    if (!await _tableExists(db, 'sqlite_sequence')) return;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    for (final t in tables) {
      final name = t['name'] as String;

      // Only if there's an integer PK called `id`
      final cols = await db.rawQuery("PRAGMA table_info($name)");
      final hasIdPk = cols.any(
        (c) =>
            (c['name'] as String).toLowerCase() == 'id' &&
            (c['pk'] as int) == 1,
      );
      if (!hasIdPk) continue;

      final maxId =
          Sqflite.firstIntValue(
            await db.rawQuery("SELECT MAX(id) FROM $name"),
          ) ??
          0;

      // Update or insert sqlite_sequence row
      final exists =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM sqlite_sequence WHERE name = ?",
              [name],
            ),
          ) ??
          0;

      if (exists > 0) {
        await db.rawUpdate(
          "UPDATE sqlite_sequence SET seq = ? WHERE name = ?",
          [maxId, name],
        );
      } else {
        // Will succeed only for AUTOINCREMENT tables; ignore otherwise
        try {
          await db.rawInsert(
            "INSERT INTO sqlite_sequence(name, seq) VALUES(?, ?)",
            [name, maxId],
          );
        } catch (_) {
          /* ignore */
        }
      }
    }
  }

  Future<bool> _hasFts4(DatabaseExecutor db) async {
    if (_fts4Available != null) return _fts4Available!;

    // Hint via compile options
    try {
      final rows = await db.rawQuery('PRAGMA compile_options');
      for (final m in rows) {
        final v = (m.values.first ?? '').toString().toUpperCase();
        if (v.contains('ENABLE_FTS4')) {
          _fts4Available = true;
          return true;
        }
      }
    } catch (_) {
      /* ignore */
    }

    // Definitive probe: FTS4 only
    try {
      await db.execute(
        "CREATE VIRTUAL TABLE temp.__fts4_probe__ USING fts4(x)",
      );
      await db.execute("DROP TABLE IF EXISTS temp.__fts4_probe__");
      _fts4Available = true;
      return true;
    } catch (_) {
      _fts4Available = false;
      return false;
    }
  }

  bool _isValidEanUpc(String raw) {
    final code = raw.replaceAll(RegExp(r'\D'), '');
    const classic = {8, 12, 13, 14}; // EAN-8, UPC-A, EAN-13, ITF-14
    if (!classic.contains(code.length)) return false;

    final digits = code.split('').map(int.parse).toList(growable: false);
    final check = digits.removeLast();
    int sum = 0;
    for (int i = digits.length - 1, pos = 0; i >= 0; i--, pos++) {
      sum += digits[i] * ((pos % 2 == 0) ? 3 : 1);
    }
    final expected = (10 - (sum % 10)) % 10;
    return check == expected;
  }

  // Coerce any bool → 0/1. Leave everything else alone.
  Object? _sqlBool(Object? v) {
    if (v is bool) return v ? 1 : 0;
    return v;
  }

  // Numeric-ish column?
  bool _isNumericType(String? t) {
    if (t == null) return false;
    final up = t.toUpperCase();
    return up.contains('INT') || up.contains('REAL') || up.contains('NUM');
  }

  // Filter a row to existing columns for [table], coerce booleans → 0/1,
  // and turn empty strings into NULL for numeric columns.
  Future<Map<String, Object?>> _sanitizeRowForTable(
    DatabaseExecutor ex,
    String table,
    Map row,
  ) async {
    final cols = await ex.rawQuery('PRAGMA table_info($table)');
    final info = <String, Map<String, Object?>>{
      for (final c in cols) (c['name'] as String): c,
    };

    final out = <String, Object?>{};
    row.forEach((k, v) {
      final key = k.toString();
      final meta = info[key];
      if (meta == null) return; // drop unknown columns (older schema)

      var val = _sqlBool(v);

      // If the column is numeric and value is an empty string → NULL
      if (val is String &&
          val.trim().isEmpty &&
          _isNumericType(meta['type'] as String?)) {
        val = null;
      }
      out[key] = val;
    });
    return out;
  }

  Future<String> _dbFilePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _kDatabaseName);
  }
}
