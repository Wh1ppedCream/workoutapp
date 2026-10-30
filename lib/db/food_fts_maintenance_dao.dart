import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';

import 'database_metadata_dao.dart';
import 'db_query_utils.dart';
import 'seed.dart';
import 'schema.dart';

/// Database operations for FoodFtsMaintenance without owning a connection.
class FoodFtsMaintenanceDao {
  static const String _kOpenTriggerResetKey = 'open_trigger_reset_v1';
  static const String _kOpenIndexEnsureKey = 'open_index_ensure_v3';
  static const String _kEmptyStarterPlanCleanupKey =
      'empty_starter_plan_cleanup_v1';
  static bool? _fts4Available;

  /// Clears the capability memo only when the explicit test database is reset.
  static void resetCapabilities() => _fts4Available = null;

  static Future<void> resetDbTriggers(Database db, {bool force = false}) async {
    if (!force) {
      final previous = await getAppMeta(db, _kOpenTriggerResetKey);
      if (previous != null) {
        logOnOpenStep('trigger-reset', 0, 'skipped ($previous)');
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
      await setAppMeta(
        db,
        _kOpenTriggerResetKey,
        'done:${sw.elapsedMilliseconds}',
      );
      logOnOpenStep('trigger-reset', sw.elapsedMilliseconds, 'repaired');
    }
  }

  static void logOnOpenStep(String label, int elapsedMs, String detail) {
    debugPrint('[db] onOpen step $label: ${elapsedMs}ms - $detail');
  }

  static void logProgress(String phase, int total) {
    if (total == 1 || total == 1000 || total % 5000 == 0) {
      debugPrint('[$phase] processed $total');
    }
  }

  static Future<void> backfillNormalizedFoodKeysTx(DatabaseExecutor ex) async {
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
    if (await DatabaseMetadataDao.tableHasColumn(ex, 'foods', 'barcode') &&
        await DatabaseMetadataDao.tableExists(ex, 'food_barcodes')) {
      final rows = await ex.query(
        'foods',
        columns: ['id', 'barcode'],
        where: "barcode IS NOT NULL AND TRIM(barcode) <> ''",
      );
      for (final r in rows) {
        final raw = (r['barcode'] as String?) ?? '';
        final upc = raw.replaceAll(RegExp(r'\D'), '');
        if (!isValidEanUpc(upc)) continue;
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
    if (await DatabaseMetadataDao.tableHasColumn(
      ex,
      'foods',
      'default_portion_id',
    )) {
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

  static Future<void> backfillNormalizedFoodKeys(Database db) async {
    await db.transaction((txn) async {
      await backfillNormalizedFoodKeysTx(txn);
    });
  }

  static Future<void> rebuildFoodFtsIfExists(Database db) async {
    if (!await hasFts4(db)) return;

    final exists = await hasFoodFtsTable(db);

    if (!exists) return;

    try {
      await db.execute(
        "INSERT INTO food_search_fts(food_search_fts) VALUES('rebuild')",
      );
      await db.execute(
        "INSERT INTO food_search_fts(food_search_fts) VALUES('optimize')",
      );
      await ensureFoodFtsTriggers(db);
      debugPrint('[fts4] food_search_fts rebuild+optimize done');
    } catch (_) {
      /* ignore */
    }
  }

  static Future<void> ensureFoodFtsReady(Database db) async {
    final sw = Stopwatch()..start();
    if (!await hasFts4(db)) {
      logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (fts4 unavailable)',
      );
      return;
    }
    if (!await hasFoodFtsTable(db)) {
      logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (fts table missing)',
      );
      return;
    }
    if (!await DatabaseMetadataDao.tableExists(db, 'foods')) {
      logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'skipped (no foods table)',
      );
      return;
    }

    try {
      await ensureFoodFtsTriggers(db);

      final foodCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM foods'),
          ) ??
          0;
      if (foodCount == 0) {
        logOnOpenStep(
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
        await rebuildFoodFtsIfExists(db);
        rebuilt = true;
      }
      logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        rebuilt
            ? 'rebuilt (foods=$foodCount, fts=$ftsCount)'
            : 'ok (foods=$foodCount, fts=$ftsCount)',
      );
    } catch (_) {
      // Search can still fall back to LIKE if FTS is unavailable or unhealthy.
      logOnOpenStep(
        'fts-ready',
        sw.elapsedMilliseconds,
        'fallback (fts check failed)',
      );
    }
  }

  static Future<void> ensureFoodFtsTriggers(DatabaseExecutor db) async {
    await Schema.ensureFoodFtsTriggers(db);
  }

  static Future<void> dropFoodFtsTriggers(DatabaseExecutor db) async {
    await db.execute('DROP TRIGGER IF EXISTS foods_ai;');
    await db.execute('DROP TRIGGER IF EXISTS foods_ad;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bd;');
    await db.execute('DROP TRIGGER IF EXISTS foods_bu;');
    await db.execute('DROP TRIGGER IF EXISTS foods_au;');
  }

  static Future<bool> hasFoodFtsTable(DatabaseExecutor db) async {
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

  static Future<void> ensureIndexes(Database db, {bool force = false}) async {
    if (!force) {
      final previous = await getAppMeta(db, _kOpenIndexEnsureKey);
      if (previous != null) {
        logOnOpenStep('ensure-indexes', 0, 'skipped ($previous)');
        return;
      }
    }

    final sw = Stopwatch()..start();
    // ── Workout sessions & exercise logs ─────────────────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'sessions')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_completed_at_ms '
        'ON sessions(completed_at_ms, id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_training_day '
        'ON sessions(training_day, completed_at_ms, id)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'exercises')) {
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
    if (await DatabaseMetadataDao.tableExists(db, 'sets')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sets_exercise_order '
        'ON sets(exercise_id, order_index)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sets_parent ON sets(parent_set_id)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'preset_exercises')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_preset_exercises_focus '
        'ON preset_exercises(preset_id, type, exercise_def_id)',
      );
    }

    // ── Foods & lookups ───────────────────────────────────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'foods')) {
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
      if (await DatabaseMetadataDao.tableHasColumn(
        db,
        'foods',
        'default_portion_id',
      )) {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_foods_default_portion ON foods(default_portion_id)',
        );
      }
    }

    if (await DatabaseMetadataDao.tableExists(db, 'brands')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name COLLATE NOCASE)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'sources')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sources_name ON sources(name COLLATE NOCASE)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'categories')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name COLLATE NOCASE)',
      );
    }

    // ── Portions & barcodes ───────────────────────────────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'food_portions')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_portions_food ON food_portions(food_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_portions_default ON food_portions(food_id, is_default)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'food_barcodes')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_barcodes_food ON food_barcodes(food_id)',
      );
    }

    // ── Nutrients (flex + lookups) ────────────────────────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'food_nutrient_values')) {
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
    if (await DatabaseMetadataDao.tableExists(db, 'nutrients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_nutrients_code ON nutrients(code)',
      );
    }

    // ── Recipes ───────────────────────────────────────────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'recipe_nutrients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_nutrients_recipe ON recipe_nutrients(recipe_id)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'recipe_ingredients')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_food ON recipe_ingredients(food_id)',
      );
    }

    // ── Diary / favorites / usage / tags / day cache ─────────────────────────
    if (await DatabaseMetadataDao.tableExists(db, 'diary_entries')) {
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
    if (await DatabaseMetadataDao.tableExists(db, 'day_totals_cache')) {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_day_totals_profile_date '
        'ON day_totals_cache(profile_id, date)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'favorite_foods')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_favorite_foods_profile ON favorite_foods(profile_id)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'food_usage_stats')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_usage_profile_last '
        'ON food_usage_stats(profile_id, last_used)',
      );
    }
    if (await DatabaseMetadataDao.tableExists(db, 'diary_entry_tags')) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_entry ON diary_entry_tags(entry_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_tag ON diary_entry_tags(tag)',
      );
    }

    if (!force) {
      await setAppMeta(
        db,
        _kOpenIndexEnsureKey,
        'done:${sw.elapsedMilliseconds}',
      );
      logOnOpenStep('ensure-indexes', sw.elapsedMilliseconds, 'ensured');
    }
  }

  static Future<void> ensureAppMetaTable(DatabaseExecutor db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS app_meta(
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''');
  }

  static Future<String?> getAppMeta(DatabaseExecutor db, String key) async {
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

  static Future<void> setAppMeta(
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

  static Future<void> maybeCompactLegacyFoodCatalog(Database db) async {
    final sw = Stopwatch()..start();
    if (!await DatabaseMetadataDao.tableExists(db, 'foods')) {
      logOnOpenStep(
        'legacy-catalog-compact',
        sw.elapsedMilliseconds,
        'skipped (no foods table)',
      );
      return;
    }

    const flagKey = 'catalog_cleanup_v1';
    final previous = await getAppMeta(db, flagKey);
    if (previous != null) {
      logOnOpenStep(
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
      await setAppMeta(db, flagKey, 'not_needed:$totalFoods:$importedFoods');
      logOnOpenStep(
        'legacy-catalog-compact',
        sw.elapsedMilliseconds,
        'not needed (foods=$totalFoods, imported=$importedFoods)',
      );
      return;
    }

    final hasDiaryEntries = await DatabaseMetadataDao.tableExists(
      db,
      'diary_entries',
    );
    final hasRecipeIngredients = await DatabaseMetadataDao.tableExists(
      db,
      'recipe_ingredients',
    );
    final hasFavoriteFoods = await DatabaseMetadataDao.tableExists(
      db,
      'favorite_foods',
    );
    final hasFoodUsageStats = await DatabaseMetadataDao.tableExists(
      db,
      'food_usage_stats',
    );
    final hasBrands = await DatabaseMetadataDao.tableExists(db, 'brands');
    final hasCategories = await DatabaseMetadataDao.tableExists(
      db,
      'categories',
    );
    final hasSources = await DatabaseMetadataDao.tableExists(db, 'sources');

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
      onProgress: (c) => logProgress('starter-foods', c),
    );
    await backfillNormalizedFoodKeys(db);
    await backfillEnergyKcalFromMacros(db);
    await ensureIndexes(db);
    await rebuildFoodFtsIfExists(db);

    final remaining =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM foods WHERE COALESCE(is_deleted, 0) = 0',
          ),
        ) ??
        0;
    await setAppMeta(
      db,
      flagKey,
      'done:$deleted:$remaining:${sw.elapsedMilliseconds}',
    );
    debugPrint(
      '[foods] legacy catalog compacted in ${sw.elapsedMilliseconds}ms - removed: $deleted, remaining: $remaining',
    );
    logOnOpenStep(
      'legacy-catalog-compact',
      sw.elapsedMilliseconds,
      'removed=$deleted, remaining=$remaining',
    );
  }

  static Future<void> removeEmptyStarterPlans(Database db) async {
    final sw = Stopwatch()..start();
    final previous = await getAppMeta(db, _kEmptyStarterPlanCleanupKey);
    if (previous != null) {
      logOnOpenStep(
        'starter-plan-cleanup',
        sw.elapsedMilliseconds,
        'skipped ($previous)',
      );
      return;
    }

    if (!await DatabaseMetadataDao.tableExists(db, 'preset_definitions')) {
      await setAppMeta(
        db,
        _kEmptyStarterPlanCleanupKey,
        'skipped:no-table:${sw.elapsedMilliseconds}',
      );
      logOnOpenStep(
        'starter-plan-cleanup',
        sw.elapsedMilliseconds,
        'skipped (no preset table)',
      );
      return;
    }

    final hasExercisesTable = await DatabaseMetadataDao.tableExists(
      db,
      'preset_exercises',
    );
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
    final emptyPresetGuard = hasExercisesTable
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

    await setAppMeta(
      db,
      _kEmptyStarterPlanCleanupKey,
      'done:$deleted:${sw.elapsedMilliseconds}',
    );
    logOnOpenStep(
      'starter-plan-cleanup',
      sw.elapsedMilliseconds,
      deleted == 0 ? 'none found' : 'removed=$deleted',
    );
  }

  static Future<bool> seedFoodsIfEmpty(Database db) async {
    final sw = Stopwatch()..start();
    final n =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM foods'),
        ) ??
        0;
    if (n > 0) {
      logOnOpenStep('seed-foods', sw.elapsedMilliseconds, 'skipped (count=$n)');
      return false;
    }

    debugPrint(
      '[foods] seeding starter catalog from ${Seed.defaultFoodsAssetPath}',
    );
    var seeded = false;

    try {
      await Seed.seedFoods(
        db,
        onProgress: (c) => logProgress('foods', c), // ← progress pings
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
          onProgress: (c) => logProgress('foods', c),
        );
        seeded = true;
      } catch (e2) {
        debugPrint('[foods] fallback starter seed also failed: $e2');
      }
    }

    if (seeded) {
      // Make the new catalog immediately usable
      await backfillNormalizedFoodKeys(db);
      await backfillEnergyKcalFromMacros(db);
      await ensureIndexes(db);
      await rebuildFoodFtsIfExists(db);

      final total =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM foods'),
          ) ??
          0;
      debugPrint(
        '[foods] seeding complete in ${sw.elapsedMilliseconds}ms - total rows: $total',
      );
      logOnOpenStep(
        'seed-foods',
        sw.elapsedMilliseconds,
        'seeded ($total rows)',
      );
    } else {
      logOnOpenStep('seed-foods', sw.elapsedMilliseconds, 'failed');
    }
    return seeded;
  }

  /// Ensures KCAL exists per_100g for foods that have P/C/F but no KCAL yet.
  /// Also mirrors into legacy food_nutrients for back-compat reads.
  static Future<void> backfillEnergyKcalFromMacros(DatabaseExecutor db) async {
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

  static Future<bool> hasFts4(DatabaseExecutor db) async {
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

  static bool isValidEanUpc(String raw) {
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
}
