// File: lib/db/nutrition_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/nutrition_models.dart';
import 'dart:convert';
import 'db_query_utils.dart';

// Row used by the day view: a DiaryEntry plus its display name.
class DiaryEntryRow {
  final DiaryEntry entry;
  final String displayTitle;
  DiaryEntryRow({required this.entry, required this.displayTitle});
}

String _toYMD(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final da = d.day.toString().padLeft(2, '0');
  return '$y-$m-$da';
}

// Treat these labels as kilojoules and convert to kcal.

class NutritionDao {
  final Database db;
  NutritionDao(this.db);

  // DB → friendly (what your code uses everywhere like ENERGY_KCAL/PROTEIN/CARB/FAT/SUGARS/FASAT/SODIUM)
  static const Map<String, String> _codeSynonyms = {
    // Let raw DB primaries pass through too (harmless, but saves a branch)
    // Energy
    'KCAL': 'ENERGY_KCAL',
    'CALORIES': 'ENERGY_KCAL',
    'ENERC_KJ': 'ENERGY_KCAL', // <- accept kJ labels as "energy"
    'ENERGY_KJ': 'ENERGY_KCAL',
    'KJ': 'ENERGY_KCAL',

    // Macros
    'PROTEIN_G': 'PROTEIN',
    'PROCNT': 'PROTEIN', // USDA legacy
    'CARB_G': 'CARB',
    'CHOCDF': 'CARB', // USDA legacy
    'FAT_G': 'FAT',

    // Fiber & sugars
    'FIBER_G': 'FIBER',
    'FIBTG': 'FIBER', // USDA legacy
    'SUGAR_G': 'SUGARS',
    'SUGARS_TOTAL_G': 'SUGARS',

    // Saturated fat
    'SAT_FAT_G': 'FASAT',
    'FA_SAT_G': 'FASAT',
    'FASAT': 'FASAT',

    // Sodium
    'SODIUM_MG': 'SODIUM',
    'SODIUM': 'SODIUM',
    'NA': 'SODIUM', // USDA legacy
    // Optional convenience (polish)
    'SUGARS_ADDED_G': 'SUGARS_ADDED',
    'CARB_NET_G': 'CARB_NET',
  };

  String _canonCode(String code) {
    final up = code.toUpperCase();
    return _codeSynonyms[up] ?? up;
  }

  // Friendly/UI → DB nutrient.code (match nutrients_extended.json primaries)
  static const Map<String, String> _toDbCode = {
    // Energy
    'ENERGY_KCAL': 'KCAL',
    'KCAL': 'KCAL',
    'CALORIES': 'KCAL',
    'ENERC_KJ': 'KCAL', // allow callers to pass kJ-ish keys
    'ENERGY_KJ': 'KCAL',
    'KJ': 'KCAL',

    // Macros
    'PROTEIN': 'PROTEIN_G',
    'PROCNT': 'PROTEIN_G',
    'CARB': 'CARB_G',
    'CHOCDF': 'CARB_G',
    'FAT': 'FAT_G',

    // Fiber & sugars
    'FIBER': 'FIBER_G',
    'FIBTG': 'FIBER_G',
    'SUGARS': 'SUGARS_TOTAL_G',
    'SUGAR': 'SUGARS_TOTAL_G',
    'SUGAR_G': 'SUGARS_TOTAL_G',
    'SUGARS_TOTAL_G': 'SUGARS_TOTAL_G',

    // Saturated fat
    'FASAT': 'FA_SAT_G',
    'SAT_FAT_G': 'FA_SAT_G',
    'FA_SAT_G': 'FA_SAT_G',

    // Sodium
    'SODIUM': 'SODIUM_MG',
    'SODIUM_MG': 'SODIUM_MG',
    'NA': 'SODIUM_MG',

    // Optional convenience (polish)
    'SUGARS_ADDED': 'SUGARS_ADDED_G',
    'CARB_NET': 'CARB_NET_G',
  };
  String _toDb(String code) =>
      _toDbCode[code.toUpperCase()] ?? code.toUpperCase();

  // ───────────────────────────────────────────────────────────────────────────
  // SEEDING
  // ───────────────────────────────────────────────────────────────────────────

  // Bool → 0/1 (or NULL) and "only write columns that exist" for the current DB.
  int? _b(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v != 0 ? 1 : 0;
    if (v is String) return (v.toLowerCase() == 'true') ? 1 : 0;
    return null;
  }

  Future<Map<String, Object?>> _sanitizeFoodWriteTx(
    DatabaseExecutor ex,
    Map<String, Object?> inRow,
  ) async {
    final row = Map<String, Object?>.from(inRow);

    // 1) Coerce booleans expected by schema
    for (final k in const ['is_custom', 'is_deleted', 'verified']) {
      if (row.containsKey(k)) row[k] = _b(row[k]);
    }

    // 2) Normalize empty strings → NULL (avoids odd UNIQUE/NOT NULL checks)
    for (final k in const ['brand', 'data_source', 'preparation']) {
      final v = row[k];
      if (v is String && v.trim().isEmpty) row[k] = null;
    }

    // 3) Drop keys that aren’t real columns on this device’s schema
    final cols = await ex.rawQuery('PRAGMA table_info(foods)');
    final have = <String>{
      for (final r in cols) (r['name'] as String).toLowerCase(),
    };
    row.removeWhere((k, _) => !have.contains(k.toLowerCase()));

    return row;
  }

  /// TODO: DOUBLE CHECK REQUIREMENT AND USE
  /*
Future<bool> _foodExists(int foodId) async {
    final r = await db.rawQuery('SELECT 1 FROM foods WHERE id = ? LIMIT 1;', [foodId]);
    return r.isNotEmpty;
  }
*/

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

  // Add near the top (private helper)
  Future<void> _insertBarcodeSafe(
    DatabaseExecutor ex,
    int foodId,
    String raw,
  ) async {
    final upc = raw.replaceAll(RegExp(r'\D'), '');
    if (!_isValidEanUpc(upc)) return; // <- check digit

    try {
      await ex.insert('food_barcodes', {
        'food_id': foodId,
        'upc': upc,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } on DatabaseException catch (e) {
      final msg = e.toString();
      final benign =
          msg.contains('UNIQUE') ||
          msg.contains('constraint failed') ||
          msg.contains('trigger') ||
          msg.contains('RAISE(');
      if (!benign) rethrow;
    }
  }

  Future<void> seedNutrientsIfEmpty() async {
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM nutrients'),
        ) ??
        0;
    if (count > 0) return;

    final batch = db.batch();
    void add(String code, String name, String unit) {
      batch.insert('nutrients', {
        'code': code,
        'name': name,
        'unit': unit,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Extended “starter set” that matches nutrients_extended.json
    add('KCAL', 'Calories', 'kcal');
    add('PROTEIN_G', 'Protein', 'g');
    add('CARB_G', 'Carbohydrate', 'g');
    add('FAT_G', 'Fat', 'g');
    add('FIBER_G', 'Fiber', 'g');
    add('SUGARS_TOTAL_G', 'Sugars, total', 'g'); // <- was SUGAR_G
    add('FA_SAT_G', 'Saturated fat', 'g'); // <- was SAT_FAT_G
    add('SODIUM_MG', 'Sodium', 'mg');

    await batch.commit(noResult: true);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FOODS & PORTIONS & NUTRIENTS
  // ───────────────────────────────────────────────────────────────────────────

  Future<int> upsertFood(Food f) async {
    final map = f.toMap();
    if (f.id == null) {
      return db.insert('foods', map);
    } else {
      await db.update('foods', map, where: 'id = ?', whereArgs: [f.id]);
      return f.id!;
    }
  }

  Future<Food?> getFood(int id) async {
    final rows = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Food.fromMap(rows.first);
  }

  Future<List<Food>> searchFoods(String query, {int limit = 50}) async {
    final q = query.trim();
    if (q.isEmpty) {
      final rows = await db.query(
        'foods',
        where: 'is_deleted = 0',
        orderBy: 'name',
        limit: limit,
      );
      return rows.map(Food.fromMap).toList();
    }

    // 1) If it looks like a barcode, try exact UPC/EAN first
    final digits = q.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 8 && digits.length <= 18) {
      final byCode = await db.rawQuery(
        '''
      SELECT f.*
      FROM food_barcodes b
      JOIN foods f ON f.id = b.food_id
      WHERE b.upc = ? AND f.is_deleted = 0
      LIMIT ?
    ''',
        [digits, limit],
      );
      if (byCode.isNotEmpty) return byCode.map(Food.fromMap).toList();
    }

    // 2) Try FTS (FTS4/3) if available
    try {
      // Build an FTS4-friendly query: each token gets a trailing '*'
      String fts4Match(String input) {
        final tokens =
            input
                .trim()
                .split(RegExp(r'\s+'))
                .where((t) => t.isNotEmpty)
                .map((t) => '${t.replaceAll('"', '').replaceAll("'", '')}*')
                .toList();
        return tokens.isEmpty ? input : tokens.join(' ');
      }

      String escPrefix(String s) => s
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');

      final ftsQuery = fts4Match(q);
      final pfx = escPrefix(q);

      final rows = await db.rawQuery(
        '''
    SELECT f.*
    FROM food_search_fts
    JOIN foods f ON f.id = food_search_fts.rowid
    WHERE food_search_fts MATCH ?
      AND f.is_deleted = 0
    ORDER BY
      CASE
        WHEN f.name LIKE ? || '%' ESCAPE '\\' THEN 0
        WHEN f.brand IS NOT NULL AND f.brand LIKE ? || '%' ESCAPE '\\' THEN 1
        ELSE 2
      END,
      length(f.name) ASC,
      f.id ASC
    LIMIT ?
  ''',
        [ftsQuery, pfx, pfx, limit],
      );

      if (rows.isNotEmpty) return rows.map(Food.fromMap).toList();
    } catch (_) {}

    // 3) Fallback LIKE, including brand via LEFT JOIN brands
    String escLike(String s) =>
        '%${s.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';

    final like = escLike(q);
    final rows = await db.rawQuery(
      '''
    SELECT f.*
    FROM foods f
    LEFT JOIN brands b ON b.id = f.brand_id
    WHERE f.is_deleted = 0
      AND (f.name LIKE ? ESCAPE '\\'
        OR (b.name IS NOT NULL AND b.name LIKE ? ESCAPE '\\')
        OR (f.brand IS NOT NULL AND f.brand LIKE ? ESCAPE '\\'))
    ORDER BY f.name
    LIMIT ?
  ''',
      [like, like, like, limit],
    );

    return rows.map(Food.fromMap).toList();
  }

  Future<int> upsertFoodPortion(FoodPortion p) async {
    final id = await db.transaction<int>((txn) async {
      // sanitize converters (0 → NULL)
      final gw =
          (p.gramWeight != null && p.gramWeight! > 0) ? p.gramWeight : null;
      final mv = (p.mlVolume != null && p.mlVolume! > 0) ? p.mlVolume : null;
      if (gw == null && mv == null) {
        throw StateError('Portion requires gram_weight > 0 OR ml_volume > 0');
      }

      // If this one should be default, clear others for this food in-tx
      if (p.isDefault) {
        if (p.id == null) {
          await txn.update(
            'food_portions',
            {'is_default': 0},
            where: 'food_id = ?',
            whereArgs: [p.foodId],
          );
        } else {
          await txn.update(
            'food_portions',
            {'is_default': 0},
            where: 'food_id = ? AND id <> ?',
            whereArgs: [p.foodId, p.id],
          );
        }
      }

      // Build full row (may include columns not present on older DBs)
      final raw = {
        'food_id': p.foodId,
        'measure_name':
            (p.measureName.trim().isNotEmpty)
                ? p.measureName.trim()
                : 'Portion',
        'gram_weight': gw,
        'ml_volume': mv,
        'is_default': p.isDefault ? 1 : 0,
        'list_kind': p.listKind,
        'sort_order': p.sortOrder,
        'amount': p.amount,
        'unit': p.unit,
        'label': p.label,
      };

      // 🔧 prune to actual table columns to avoid “no such column …”
      final row = await _pruneToTable('food_portions', raw);

      int outId;
      if (p.id == null) {
        outId = await txn.insert('food_portions', row);
      } else {
        await txn.update(
          'food_portions',
          row,
          where: 'id = ?',
          whereArgs: [p.id],
        );
        outId = p.id!;
      }

      // Optional: also set foods.default_portion_id if present
      if (p.isDefault) {
        try {
          await txn.update(
            'foods',
            {'default_portion_id': outId},
            where: 'id = ?',
            whereArgs: [p.foodId],
          );
        } catch (_) {
          /* older schema may not have the column */
        }
      }
      return outId;
    });

    await _refreshRecipeCachesForFood(p.foodId);
    return id;
  }

  Future<List<FoodPortion>> getPortionsForFood(int foodId) async {
    final rows = await db.query(
      'food_portions',
      where: 'food_id = ?',
      whereArgs: [foodId],
      // default first, then group, then sort_order, then id
      orderBy:
          "is_default DESC, COALESCE(list_kind,''), COALESCE(sort_order, 999999), id ASC",
    );
    return rows.map(FoodPortion.fromMap).toList();
  }

  Future<void> setDefaultPortion(int foodId, int portionId) =>
      setFoodDefaultPortion(foodId, portionId);

  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) async {
    await db.transaction((txn) async {
      await txn.delete(
        'food_nutrients',
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      await txn.delete(
        'food_nutrient_values',
        where: 'food_id = ? AND basis = ?',
        whereArgs: [foodId, 'per_100g'],
      );

      for (final r in rows) {
        await txn.insert('food_nutrients', {
          'food_id': foodId,
          'nutrient_id': r.nutrientId,
          'amount_per_100g': r.amountPer100g,
        });

        await txn.insert('food_nutrient_values', {
          'food_id': foodId,
          'nutrient_id': r.nutrientId,
          'amount': r.amountPer100g,
          'basis': 'per_100g',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });

    await _maybeEnsureEnergyKcalInV22(foodId);
    await _refreshRecipeCachesForFood(foodId);
  }

  Future<Map<int, double>> getFoodNutrientsPer100g(int foodId) async {
    // Prefer v22 flexible table
    final v22 = await db.query(
      'food_nutrient_values',
      columns: ['nutrient_id', 'amount'],
      where: 'food_id = ? AND basis = ?',
      whereArgs: [foodId, 'per_100g'],
    );
    if (v22.isNotEmpty) {
      final m = <int, double>{};
      for (final r in v22) {
        m[r['nutrient_id'] as int] = (r['amount'] as num).toDouble();
      }
      return m;
    }

    // Fallback to legacy table
    final rows = await db.query(
      'food_nutrients',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
    final map = <int, double>{};
    for (final r in rows) {
      map[r['nutrient_id'] as int] = (r['amount_per_100g'] as num).toDouble();
    }
    return map;
  }

  // keep your existing int-keyed method if you want; add this alongside it
  Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) async {
    // Prefer v22 flexible table
    final rows = await db.rawQuery(
      '''
      SELECT n.code AS code, fnv.amount AS amount
      FROM food_nutrient_values fnv
      JOIN nutrients n ON n.id = fnv.nutrient_id
      WHERE fnv.food_id = ? AND fnv.basis = 'per_100g'
    ''',
      [foodId],
    );

    if (rows.isNotEmpty) {
      final out = <String, double>{};
      for (final r in rows) {
        final code = _canonCode(r['code'] as String);
        out[code] = (r['amount'] as num).toDouble();
      }
      return out;
    }

    // Fallback to legacy per_100g table (if any)
    final legacy = await db.rawQuery(
      '''
      SELECT n.code AS code, fn.amount_per_100g AS amount
      FROM food_nutrients fn
      JOIN nutrients n ON n.id = fn.nutrient_id
      WHERE fn.food_id = ?
    ''',
      [foodId],
    );

    final out = <String, double>{};
    for (final r in legacy) {
      final code = _canonCode(r['code'] as String);
      out[code] = (r['amount'] as num).toDouble();
    }
    return out;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // RECIPES
  // ───────────────────────────────────────────────────────────────────────────

  Future<int> createOrUpdateRecipe(
    Recipe r,
    List<RecipeIngredient> ings,
  ) async {
    final rid = await db.transaction<int>((txn) async {
      int outId;
      final map = r.toMap();
      if (r.id == null) {
        outId = await txn.insert('recipes', map);
      } else {
        outId = r.id!;
        await txn.update('recipes', map, where: 'id = ?', whereArgs: [outId]);
        await txn.delete(
          'recipe_ingredients',
          where: 'recipe_id = ?',
          whereArgs: [outId],
        );
      }
      for (final ing in ings) {
        await txn.insert('recipe_ingredients', {
          'recipe_id': outId,
          'food_id': ing.foodId,
          'portion_id': ing.portionId,
          'quantity': ing.quantity,
          'grams': ing.grams,
        });
      }
      return outId;
    });

    // do this after commit
    await rebuildRecipeNutrientCache(rid);
    return rid;
  }

  Future<Recipe?> getRecipe(int id) async {
    final rows = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Recipe.fromMap(rows.first);
  }

  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    final rows = await db.query(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return rows.map(RecipeIngredient.fromMap).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DIARY (insert/update/delete + fetch)
  // ───────────────────────────────────────────────────────────────────────────

  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride, // legacy, still accepted
    double? loggedGrams, // NEW preferred override
    DateTime? loggedAt, // NEW precise timestamp
    String? notes,
  }) async {
    // Resolve grams (loggedGrams > legacy gramsOverride > derive from portion)
    final resolvedGrams =
        loggedGrams ??
        gramsOverride ??
        await _resolveFoodGrams(foodId, portionId, quantity);

    // Compute snapshots once at insert (optional but recommended)
    Map<String, double>? snap;
    if (resolvedGrams != null && resolvedGrams > 0) {
      final per100 = await _per100WithFallback(foodId, portionId: portionId);
      if (per100.isNotEmpty) {
        snap = _computeMacroSnapshot(per100, resolvedGrams);
      }
    }

    final values = {
      'profile_id': profileId,
      'date': _toYMD(date),
      'meal_type': mealType.index,
      'food_id': foodId,
      'recipe_id': null,
      'portion_id': portionId,
      'quantity': quantity,
      'grams': resolvedGrams,
      'logged_grams': resolvedGrams,
      'grams_override': resolvedGrams, // legacy shim
      'notes': notes,
      'kcal_snapshot': snap?['kcal'],
      'protein_g_snapshot': snap?['protein_g'],
      'carb_g_snapshot': snap?['carb_g'],
      'fat_g_snapshot': snap?['fat_g'],
      'nutrient_snapshot_json':
          (snap == null)
              ? null
              : jsonEncode({
                'KCAL': snap['kcal'],
                'PROTEIN_G': snap['protein_g'],
                'CARB_G': snap['carb_g'],
                'FAT_G': snap['fat_g'],
              }),
      'logged_at': loggedAt?.toUtc().millisecondsSinceEpoch,
    };

    // 🔐 Back-compat: drop column if this DB doesn't have it
    if (!await _hasColumn('diary_entries', 'grams_override')) {
      values.remove('grams_override');
    }

    final id = await db.insert('diary_entries', values);
    await recalcDayTotals(profileId, date);
    await _bumpFoodUsage(profileId, foodId);
    return id;
  }

  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt, // NEW
    String? notes,
  }) async {
    // Build a snapshot (kcal/P/C/F) for 1x recipe, then scale by quantity.
    double rK = 0, rP = 0, rF = 0, rC = 0;

    // Try cache first
    final cached = await getRecipePer100gByCode(recipeId);
    if (cached.isNotEmpty) {
      // Need total grams to turn per-100g into absolute. Derive from ingredients quickly.
      final ings = await getRecipeIngredients(recipeId);
      double totalGrams = 0;
      for (final ing in ings) {
        final g = await _resolveIngredientGrams(ing);
        if (g != null && g > 0) totalGrams += g;
      }
      if (totalGrams > 0) {
        rP = _calcCode(cached, totalGrams, 'PROTEIN');
        rF = _calcCode(cached, totalGrams, 'FAT');
        rC = _calcCode(cached, totalGrams, 'CARB');
        final kcalDirect = _calcCode(cached, totalGrams, 'ENERGY_KCAL');
        rK = (kcalDirect > 0) ? kcalDirect : 4 * rP + 4 * rC + 9 * rF;
      }
    }

    // Fallback: compute from ingredients if cache/grams insufficient
    if (rK == 0 && rP == 0 && rF == 0 && rC == 0) {
      final ings = await getRecipeIngredients(recipeId);
      for (final ing in ings) {
        final g = await _resolveIngredientGrams(ing);
        if (g == null || g <= 0) continue;
        final per100 = await _per100WithFallback(
          ing.foodId,
          portionId: ing.portionId,
        );
        rP += _calcCode(per100, g, 'PROTEIN');
        rF += _calcCode(per100, g, 'FAT');
        rC += _calcCode(per100, g, 'CARB');
        final kcalDirect = _calcCode(per100, g, 'ENERGY_KCAL');
        rK +=
            (kcalDirect > 0)
                ? kcalDirect
                : 4 * _calcCode(per100, g, 'PROTEIN') +
                    4 * _calcCode(per100, g, 'CARB') +
                    9 * _calcCode(per100, g, 'FAT');
      }
    }

    // Scale by entry quantity
    final sK = rK * quantity,
        sP = rP * quantity,
        sF = rF * quantity,
        sC = rC * quantity;

    final id = await db.insert('diary_entries', {
      'profile_id': profileId,
      'date': _toYMD(date),
      'meal_type': mealType.index,
      'food_id': null,
      'recipe_id': recipeId,
      'portion_id': null,
      'quantity': quantity,
      'grams': null, // recipes not massed directly at entry
      'logged_grams': null,
      'notes': notes,

      'kcal_snapshot': sK,
      'protein_g_snapshot': sP,
      'carb_g_snapshot': sC,
      'fat_g_snapshot': sF,
      'nutrient_snapshot_json': jsonEncode({
        'KCAL': sK,
        'PROTEIN_G': sP,
        'CARB_G': sC,
        'FAT_G': sF,
      }),

      'logged_at': loggedAt?.toUtc().millisecondsSinceEpoch,
    });

    await recalcDayTotals(profileId, date);
    return id;
  }

  Future<void> updateDiaryEntry(DiaryEntry e) async {
    // Read old entry to know prior date for recalc if the date changed.
    final oldRows = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [e.id],
      limit: 1,
    );
    DateTime? oldDate =
        oldRows.isNotEmpty ? _parseYMD(oldRows.first['date'] as String) : null;

    final map = e.toMap();

    // Recompute snapshots if grams/portion/food/recipe changed or if missing.
    double? grams = e.loggedGrams ?? e.grams;
    Map<String, double>? snap;
    if (e.foodId != null) {
      grams ??= await _resolveFoodGrams(e.foodId!, e.portionId, e.quantity);
      if (grams != null && grams > 0) {
        final per100 = await _per100WithFallback(
          e.foodId!,
          portionId: e.portionId,
        );
        if (per100.isNotEmpty) snap = _computeMacroSnapshot(per100, grams);
      }
    } else if (e.recipeId != null) {
      // Use recipe cache path similar to addDiaryRecipe
      double rK = 0, rP = 0, rF = 0, rC = 0;
      final cached = await getRecipePer100gByCode(e.recipeId!);
      double totalGrams = 0;
      final ings = await getRecipeIngredients(e.recipeId!);
      for (final ing in ings) {
        final g = await _resolveIngredientGrams(ing);
        if (g != null && g > 0) totalGrams += g;
      }
      if (cached.isNotEmpty && totalGrams > 0) {
        rP = _calcCode(cached, totalGrams, 'PROTEIN');
        rF = _calcCode(cached, totalGrams, 'FAT');
        rC = _calcCode(cached, totalGrams, 'CARB');
        final kcalDirect = _calcCode(cached, totalGrams, 'ENERGY_KCAL');
        rK = (kcalDirect > 0) ? kcalDirect : 4 * rP + 4 * rC + 9 * rF;
      } else {
        // fallback: full recompute
        for (final ing in ings) {
          final g = await _resolveIngredientGrams(ing);
          if (g == null || g <= 0) continue;
          final per100 = await _per100WithFallback(
            ing.foodId,
            portionId: ing.portionId,
          );
          rP += _calcCode(per100, g, 'PROTEIN');
          rF += _calcCode(per100, g, 'FAT');
          rC += _calcCode(per100, g, 'CARB');
          final kcalDirect = _calcCode(per100, g, 'ENERGY_KCAL');
          rK +=
              (kcalDirect > 0)
                  ? kcalDirect
                  : 4 * _calcCode(per100, g, 'PROTEIN') +
                      4 * _calcCode(per100, g, 'CARB') +
                      9 * _calcCode(per100, g, 'FAT');
        }
      }
      // Scale by quantity
      rK *= e.quantity;
      rP *= e.quantity;
      rF *= e.quantity;
      rC *= e.quantity;
      snap = {'kcal': rK, 'protein_g': rP, 'carb_g': rC, 'fat_g': rF};
    }

    if (snap != null) {
      map['kcal_snapshot'] = snap['kcal'];
      map['protein_g_snapshot'] = snap['protein_g'];
      map['carb_g_snapshot'] = snap['carb_g'];
      map['fat_g_snapshot'] = snap['fat_g'];
      map['nutrient_snapshot_json'] = jsonEncode({
        'KCAL': snap['kcal'],
        'PROTEIN_G': snap['protein_g'],
        'CARB_G': snap['carb_g'],
        'FAT_G': snap['fat_g'],
      });
    }

    // Ensure updated_at bumps (even if trigger exists)
    map['updated_at'] = _nowEpochMs();

    await db.update('diary_entries', map, where: 'id = ?', whereArgs: [e.id]);

    // Recalc day totals (old + new if date changed)
    if (oldDate != null && oldDate != e.date) {
      await recalcDayTotals(e.profileId, oldDate);
    }
    await recalcDayTotals(e.profileId, e.date);
  }

  Future<void> deleteDiaryEntry(
    int id, {
    required int profileId,
    required DateTime date,
  }) async {
    await db.update(
      'diary_entries',
      {'is_deleted': 1, 'updated_at': _nowEpochMs()},
      where: 'id = ?',
      whereArgs: [id],
    );

    await recalcDayTotals(profileId, date);
  }

  Future<List<DiaryEntry>> getDiaryEntriesForDate(
    int profileId,
    DateTime date,
  ) async {
    final rows = await db.query(
      'diary_entries',
      where: 'profile_id = ? AND date = ? AND is_deleted = 0',
      whereArgs: [profileId, _toYMD(date)],
      // chronological within the day, then meal, then id
      orderBy: 'COALESCE(logged_at, 0) ASC, meal_type ASC, id ASC',
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime day,
  ) async {
    final ymd = _toYMD(day); // same helper you use elsewhere for 'YYYY-MM-DD'

    final rows = await db.rawQuery(
      '''
    SELECT
      d.*,
      COALESCE(f.name, r.name) AS item_name
    FROM diary_entries d
    LEFT JOIN foods   f ON d.food_id   = f.id
    LEFT JOIN recipes r ON d.recipe_id = r.id
    WHERE
      d.profile_id = ? AND
      d.date = ? AND
      d.is_deleted = 0
  ''',
      [profileId, ymd],
    );

    return rows.map((m) => DiaryEntryWithItem.fromJoinedMap(m)).toList();
  }

  /// Chronological range query by precise timestamps.
  Future<List<DiaryEntry>> getDiaryEntriesBetween(
    int profileId,
    DateTime start,
    DateTime end, {
    MealType? mealType,
    int limit = 1000,
  }) async {
    final where = StringBuffer(
      'profile_id = ? AND is_deleted = 0 AND logged_at IS NOT NULL AND logged_at BETWEEN ? AND ?',
    );
    final args = <Object?>[
      profileId,
      start.toUtc().millisecondsSinceEpoch,
      end.toUtc().millisecondsSinceEpoch,
    ];
    if (mealType != null) {
      where.write(' AND meal_type = ?');
      args.add(mealType.index);
    }
    final rows = await db.query(
      'diary_entries',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'logged_at ASC, id ASC',
      limit: limit,
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GOALS
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> setGoals(NutritionGoal goal) async {
    await db.transaction((txn) async {
      // Close any open goal overlapping this start
      await txn.update(
        'nutrition_goals',
        {'end_date': _toYMD(goal.startDate.subtract(const Duration(days: 1)))},
        where: 'profile_id = ? AND (end_date IS NULL OR end_date >= ?)',
        whereArgs: [goal.profileId, _toYMD(goal.startDate)],
      );
      // Insert new goal
      await txn.insert('nutrition_goals', goal.toMap());
    });
  }

  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async {
    final rows = await db.query(
      'nutrition_goals',
      where:
          'profile_id = ? AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
      whereArgs: [profileId, _toYMD(date), _toYMD(date)],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return NutritionGoal.fromMap(rows.first);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DAY TOTALS (cache)
  // ───────────────────────────────────────────────────────────────────────────

  Future<DayTotals> getDayTotals(int profileId, DateTime date) async {
    final ymd = _toYMD(date);
    final rows = await db.query(
      'day_totals_cache',
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, ymd],
      limit: 1,
    );
    if (rows.isNotEmpty) return DayTotals.fromMap(rows.first);
    // Build it on demand
    await recalcDayTotals(profileId, date);
    final rows2 = await db.query(
      'day_totals_cache',
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, ymd],
      limit: 1,
    );
    if (rows2.isNotEmpty) return DayTotals.fromMap(rows2.first);
    // No entries -> all zeros
    return DayTotals(profileId: profileId, date: date);
  }

  Future<void> recalcDayTotals(int profileId, DateTime date) async {
    final ymd = _toYMD(date);
    final entries = await getDiaryEntriesForDate(profileId, date);

    double kcal = 0,
        pro = 0,
        fat = 0,
        carb = 0,
        fiber = 0,
        sugar = 0,
        sat = 0,
        sodium = 0;

    for (final e in entries) {
      if (e.foodId != null) {
        final grams =
            e.loggedGrams ??
            e.grams ??
            await _resolveFoodGrams(e.foodId!, e.portionId, e.quantity);

        if (grams == null || grams <= 0) continue;

        final per100 = await _per100WithFallback(
          e.foodId!,
          portionId: e.portionId,
        );

        pro += _calcCode(per100, grams, 'PROTEIN');
        fat += _calcCode(per100, grams, 'FAT');
        carb += _calcCode(per100, grams, 'CARB');
        fiber += _calcCode(per100, grams, 'FIBER');
        sugar += _calcCode(
          per100,
          grams,
          'SUGARS',
        ); // (SUGARS_TOTAL_G is canonicalized → SUGARS)
        sat += _calcCode(per100, grams, 'FASAT');
        sodium += _calcCode(per100, grams, 'SODIUM'); // (SODIUM_MG → SODIUM)

        final k = _calcCode(per100, grams, 'ENERGY_KCAL');
        kcal +=
            (k > 0)
                ? k
                : (4 * _calcCode(per100, grams, 'PROTEIN') +
                    4 * _calcCode(per100, grams, 'CARB') +
                    9 *
                        _calcCode(
                          per100,
                          grams,
                          'FAT',
                        )); // fallback if KCAL missing
      } else if (e.recipeId != null) {
        final ings = await getRecipeIngredients(e.recipeId!);
        double rK = 0,
            rP = 0,
            rF = 0,
            rC = 0,
            rFi = 0,
            rSu = 0,
            rSa = 0,
            rNa = 0;

        for (final ing in ings) {
          final g = await _resolveIngredientGrams(ing);
          if (g == null || g <= 0) continue;
          final per100 = await _per100WithFallback(
            ing.foodId,
            portionId: ing.portionId,
          );

          rP += _calcCode(per100, g, 'PROTEIN');
          rF += _calcCode(per100, g, 'FAT');
          rC += _calcCode(per100, g, 'CARB');
          rFi += _calcCode(per100, g, 'FIBER');
          rSu += _calcCode(per100, g, 'SUGARS');
          rSa += _calcCode(per100, g, 'FASAT');
          rNa += _calcCode(per100, g, 'SODIUM');

          final k = _calcCode(per100, g, 'ENERGY_KCAL');
          rK +=
              (k > 0)
                  ? k
                  : (4 * _calcCode(per100, g, 'PROTEIN') +
                      4 * _calcCode(per100, g, 'CARB') +
                      9 * _calcCode(per100, g, 'FAT'));
        }

        final q = e.quantity;
        kcal += rK * q;
        pro += rP * q;
        fat += rF * q;
        carb += rC * q;
        fiber += rFi * q;
        sugar += rSu * q;
        sat += rSa * q;
        sodium += rNa * q;
      }
    }

    await db.insert('day_totals_cache', {
      'profile_id': profileId,
      'date': ymd,
      'kcal': kcal,
      'protein_g': pro,
      'fat_g': fat,
      'carbs_g': carb,
      'fiber_g': fiber,
      'sugar_g': sugar,
      'sat_fat_g': sat,
      'sodium_mg': sodium,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  double _calcCode(
    Map<String, double> per100ByCode,
    double grams,
    String code,
  ) {
    final v = per100ByCode[_canonCode(code)];
    if (v == null) return 0;
    return v * (grams / 100.0);
  }

  Future<double?> _resolveFoodGrams(
    int foodId,
    int? portionId,
    double quantity,
  ) async {
    if (portionId == null) return null;
    final rows = await db.query(
      'food_portions',
      where: 'id = ?',
      whereArgs: [portionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final p = FoodPortion.fromMap(rows.first);
    if (p.gramWeight != null) return p.gramWeight! * quantity;

    if (p.mlVolume != null) {
      final food = await getFood(foodId);
      final density = food?.densityGPerMl;
      if (density == null || density <= 0) return null; // guard
      return p.mlVolume! * quantity * density;
    }
    return null;
  }

  Future<double?> _resolveIngredientGrams(RecipeIngredient ing) async {
    if (ing.grams != null) return ing.grams;
    if (ing.portionId != null && ing.quantity != null) {
      final rows = await db.query(
        'food_portions',
        where: 'id = ?',
        whereArgs: [ing.portionId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final p = FoodPortion.fromMap(rows.first);
        if (p.gramWeight != null) return p.gramWeight! * ing.quantity!;
        if (p.mlVolume != null) {
          final food = await getFood(ing.foodId);
          final density = food?.densityGPerMl;
          if (density == null || density <= 0) return null; // guard
          return p.mlVolume! * ing.quantity! * density;
        }
      }
    }
    return null;
  }

  Future<void> _bumpFoodUsage(int profileId, int foodId) async {
    final now = DateTime.now().toIso8601String();
    await db.rawInsert(
      '''
    INSERT INTO food_usage_stats(profile_id, food_id, hits, last_used)
    VALUES(?, ?, 1, ?)
    ON CONFLICT(profile_id, food_id)
    DO UPDATE SET hits = hits + 1, last_used = excluded.last_used
  ''',
      [profileId, foodId, now],
    );
  }

  // --- CREATE a custom food -----------------------------------------------
  Future<int> insertCustomFood({required String name, String? brand}) async {
    final nowIso = DateTime.now().toIso8601String();
    final brandName = (brand?.trim().isEmpty ?? true) ? null : brand!.trim();

    return await db.transaction<int>((txn) async {
      // Ensure 'user' source exists
      await txn.insert('sources', {
        'name': 'user',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      final srcId = Sqflite.firstIntValue(
        await txn.rawQuery(
          "SELECT id FROM sources WHERE name = 'user' LIMIT 1",
        ),
      );

      int? brandId;
      if (brandName != null) {
        await txn.insert('brands', {
          'name': brandName,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        brandId = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT id FROM brands WHERE name = ? LIMIT 1', [
            brandName,
          ]),
        );
      }

      return await txn.insert('foods', {
        'name': name.trim(),
        'brand': brandName, // keep text column for FTS/back-compat
        'brand_id': brandId,
        'is_custom': 1,
        'data_source': 'user',
        'source_id': srcId,
        'created_at': nowIso,
        'updated_at': nowIso,
        'is_deleted': 0,
      });
    });
  }

  // --- Utility: map nutrient code -> id ------------------------------------
  Future<Map<String, int>> _codeToId(Set<String> codes) async {
    if (codes.isEmpty) return {};

    // Build the set of lookups we’ll try per incoming code:
    //  - the raw (uppercased)
    //  - the DB primary via _toDb(code)
    final wanted = <String>{};
    for (final c in codes) {
      wanted.add(c.toUpperCase());
      wanted.add(_toDb(c)); // already uppercased inside
    }

    // 1) Hit nutrients.code directly
    final placeholders = sqlitePlaceholders(wanted.length);
    final codeRows = await db.query(
      'nutrients',
      columns: ['id', 'code'],
      where: 'UPPER(code) IN ($placeholders)',
      whereArgs: wanted.toList(),
    );
    final byCode = <String, int>{
      for (final r in codeRows)
        (r['code'] as String).toUpperCase(): (r['id'] as int),
    };

    // 2) Also resolve via nutrient_aliases.alias
    final aliasRows = await db.rawQuery('''
    SELECT UPPER(a.alias) AS alias, a.nutrient_id AS nid
    FROM nutrient_aliases a
    WHERE UPPER(a.alias) IN ($placeholders)
  ''', wanted.toList());
    final byAlias = <String, int>{
      for (final r in aliasRows) (r['alias'] as String): (r['nid'] as int),
    };

    // 3) For each original requested code, prefer the DB primary, then direct, then alias.
    final out = <String, int>{};
    for (final orig in codes) {
      final dbCode = _toDb(orig); // preferred
      final uOrig = orig.toUpperCase();

      final id =
          byCode[dbCode] ?? byCode[uOrig] ?? byAlias[dbCode] ?? byAlias[uOrig];

      if (id != null) out[orig] = id;
    }
    return out;
  }

  // --- UPSERT per-100g by code into v22 table ------------------------------
  Future<void> replacePer100gByCode(
    int foodId,
    Map<String, double> codeToAmount,
  ) async {
    if (codeToAmount.isEmpty) return;

    final pre = <String, double>{};
    codeToAmount.forEach((k, v) {
      // guard: finite & non-negative
      final val = v;
      if (!val.isFinite || val < 0) return;
      final u = k.toUpperCase().trim();
      if (u == 'KJ' || u == 'ENERC_KJ' || u == 'ENERGY_KJ') {
        pre['ENERGY_KCAL'] = val / 4.184;
      } else {
        pre[k] = val;
      }
    });

    // normalize incoming keys first (existing logic)
    final normalized = <String, double>{};
    pre.forEach((k, v) => normalized[_canonCode(k)] = v);

    final c2i = await _codeToId(normalized.keys.toSet());
    await db.transaction((txn) async {
      await txn.delete(
        'food_nutrient_values',
        where: 'food_id = ? AND basis = ?',
        whereArgs: [foodId, 'per_100g'],
      );
      for (final e in normalized.entries) {
        final nid = c2i[e.key];
        if (nid == null) continue;
        await txn.insert('food_nutrient_values', {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount': e.value,
          'basis': 'per_100g',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        await txn.insert('food_nutrients', {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount_per_100g': e.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    await _maybeEnsureEnergyKcalInV22(foodId);
    await _refreshRecipeCachesForFood(foodId);
  }

  // Utility: normalize a UI label like "Vitamin C (mg)" → "vitamin c"
  String _normalizeLabel(String s) {
    // strip trailing " (unit)" if present, then lowercase+trim
    final i = s.lastIndexOf(' (');
    final base = i >= 0 ? s.substring(0, i) : s;
    return base.trim().toLowerCase();
  }

  /// Load a mapping of alias/name/code -> code, all normalized.
  /// We include:
  ///  - nutrient_aliases.alias
  ///  - nutrients.name
  ///  - nutrients.code (so direct code matches work too)
  Future<Map<String, String>> _buildAliasToCodeMap(Database db) async {
    final map = <String, String>{};

    // aliases
    final aliasRows = await db.rawQuery('''
    SELECT n.code AS code, a.alias AS alias
    FROM nutrient_aliases a
    JOIN nutrients n ON n.id = a.nutrient_id
  ''');
    for (final r in aliasRows) {
      final code = (r['code'] as String);
      final alias = _normalizeLabel(r['alias'] as String);
      map[alias] = code;
    }

    // names
    final nameRows = await db.query('nutrients', columns: ['code', 'name']);
    for (final r in nameRows) {
      final code = (r['code'] as String);
      final name = _normalizeLabel(r['name'] as String);
      map[name] = code;
    }

    // also allow direct code match (already normalized-ish)
    final codeRows = await db.query('nutrients', columns: ['code']);
    for (final r in codeRows) {
      final code = (r['code'] as String);
      map[code.toLowerCase()] = code;
    }

    // A few hard defaults that are common in our UI
    map.putIfAbsent(
      'calories',
      () => 'ENERGY_KCAL',
    ); // canonical → will map to KCAL via _toDb
    map.putIfAbsent('protein', () => 'PROTEIN');
    map.putIfAbsent('carbs', () => 'CARB');
    map.putIfAbsent('fats', () => 'FAT');

    // Extra forgiving fallbacks
    map.putIfAbsent('energy', () => 'ENERGY_KCAL'); // handles "Energy"
    map.putIfAbsent('kj', () => 'KJ'); // → KCAL via _toDb
    map.putIfAbsent('kilojoules', () => 'KJ'); // new
    map.putIfAbsent('kilojoule', () => 'KJ'); // new
    map.putIfAbsent('net carbs', () => 'CARB_NET_G');
    map.putIfAbsent('added sugars', () => 'SUGARS_ADDED_G');
    map.putIfAbsent('total sugars', () => 'SUGARS'); // “Total Sugars”
    map.putIfAbsent('sugars total', () => 'SUGARS'); // “Sugars total”
    map.putIfAbsent('saturated fat', () => 'FASAT'); // you already had this
    map.putIfAbsent('sat fat', () => 'FASAT'); // label variants
    // Add these three convenience fallbacks we depend on elsewhere:
    map.putIfAbsent('sugar', () => 'SUGARS'); // → SUGARS_TOTAL_G via _toDb
    map.putIfAbsent('saturated fat', () => 'FASAT'); // → FA_SAT_G via _toDb
    map.putIfAbsent('sodium', () => 'SODIUM'); // → SODIUM_MG via _toDb

    return map;
  }

  /// Convert a “label → value” map (coming from FoodCustomizationPage payload)
  /// into “code → amount” using aliases/names/codes.
  Future<Map<String, double>> mapLabelsToCodes(
    Database db,
    Map<String, dynamic> labelToValue,
  ) async {
    final aliasMap = await _buildAliasToCodeMap(db);

    double nums(dynamic x) =>
        (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0.0;
    bool containsKj(String s) => RegExp(
      r'\b(kj|kilojoule|kilojoules)\b',
      caseSensitive: false,
    ).hasMatch(s);

    final out = <String, double>{};

    for (final e in labelToValue.entries) {
      final rawKey = e.key;
      // Keep the raw leaf (to detect "(kJ)" reliably), and also a normalized version for alias lookup.
      final leafRaw = rawKey.split('>').last.trim();
      final norm = _normalizeLabel(
        leafRaw,
      ); // strips " (unit)" → e.g., "energy"

      final resolved = aliasMap[norm];
      if (resolved == null) continue;

      var code =
          resolved; // e.g., "KCAL", "PROTEIN_G", "ENERGY_KCAL", "KJ", ...
      var val = nums(e.value);
      if (!val.isFinite || val < 0) continue;

      final isKjLabel = containsKj(leafRaw);

      // Handle energy special-casing robustly.
      // - If alias resolved to KCAL and label suggests kJ → convert.
      // - If alias resolved to KJ → convert and store as KCAL.
      final up = code.toUpperCase();

      if (up == 'KCAL' && isKjLabel) {
        val = val / 4.184;
      } else if (up == 'KJ' || up == 'ENERC_KJ' || up == 'ENERGY_KJ') {
        val = val / 4.184;
        code = 'KCAL';
      }

      out[code] = val;
    }
    return out;
  }

  /// Save a payload from FoodCustomizationPage into per_100g values.
  /// This will wipe old per_100g values and replace them with the new set.
  Future<void> savePer100gFromLabelPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) async {
    // Step 1: pull top-level fields (the simple ones you already show at the top)
    final base = <String, double>{};
    double nums(dynamic x) =>
        (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0.0;

    if (payload.containsKey('calories')) {
      base['ENERGY_KCAL'] = nums(payload['calories']); // ← single canonical
    }
    if (payload.containsKey('protein_g')) {
      base['PROTEIN'] = nums(payload['protein_g']);
    }
    if (payload.containsKey('carbs_g')) base['CARB'] = nums(payload['carbs_g']);
    if (payload.containsKey('fats_g')) base['FAT'] = nums(payload['fats_g']);

    // Step 2: convert the rest of the form fields via alias mapping
    // Strip out known meta keys so we only feed nutrient-ish keys into the mapper.
    final copy =
        Map<String, dynamic>.from(payload)
          ..remove('name')
          ..remove('brand')
          ..remove('calories')
          ..remove('protein_g')
          ..remove('carbs_g')
          ..remove('fats_g');

    final mapped = await mapLabelsToCodes(db, copy);

    // Canonicalize all codes in one place
    final mappedNorm = {
      for (final e in mapped.entries) _canonCode(e.key): e.value,
    };
    final baseNorm = {for (final e in base.entries) _canonCode(e.key): e.value};

    // Merge (explicit base wins if there’s conflict)
    final codeToAmount =
        <String, double>{}
          ..addAll(mappedNorm)
          ..addAll(baseNorm);

    // Persist using your v22 table
    await replacePer100gByCode(foodId, codeToAmount);

    // Ensure KCAL is present (if macros exist) and refresh caches
    await _maybeEnsureEnergyKcalInV22(foodId);
    await _refreshRecipeCachesForFood(foodId);
  }

  /// Returns (code, unit) for a display alias (e.g., "Lysine (g)").
  Future<Map<String, String>?> resolveAlias(String alias) async {
    final rows = await db.rawQuery(
      '''
    SELECT n.code AS code, n.unit AS unit
    FROM nutrient_aliases a
    JOIN nutrients n ON n.id = a.nutrient_id
    WHERE a.alias = ?
    LIMIT 1
  ''',
      [alias.trim()],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return {'code': r['code'] as String, 'unit': r['unit'] as String};
  }

  /// Upsert per-100g values using alias labels as keys.
  Future<void> savePer100gByAlias(
    int foodId,
    Map<String, double> aliasToAmount,
  ) async {
    // Build alias -> (code, unit) map on the fly
    await db.transaction((txn) async {
      for (final entry in aliasToAmount.entries) {
        final alias = entry.key.trim();
        final amount = entry.value;

        final rows = await txn.rawQuery(
          '''
        SELECT n.id AS nid, n.code AS code, n.unit AS unit
        FROM nutrient_aliases a
        JOIN nutrients n ON n.id = a.nutrient_id
        WHERE a.alias = ?
        LIMIT 1
      ''',
          [alias],
        );

        if (rows.isEmpty) continue; // unknown alias -> skip silently
        final nid = rows.first['nid'] as int;

        // Write into the *new* flexible table as per_100g
        await txn.insert('food_nutrient_values', {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount': amount,
          'basis': 'per_100g',
          'portion_id': null,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Keep legacy mirror in sync (handy until you fully move off it)
        await txn.insert('food_nutrients', {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount_per_100g': amount,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    // Per-100g changed -> ensure KCAL and refresh caches.
    await _maybeEnsureEnergyKcalInV22(foodId);
    await _refreshRecipeCachesForFood(foodId);
  }

  Future<int> addPortion(
    int foodId, {
    required String measureName,
    double? gramWeight,
    double? mlVolume,
    bool isDefault = false,
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) async {
    return await db.transaction((txn) async {
      if (isDefault) {
        await txn.update(
          'food_portions',
          {'is_default': 0},
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
      }

      final rawRow = _buildPortionRow(
        foodId: foodId,
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

      final row = await _pruneToTable('food_portions', rawRow); // ← prune here
      final newId = await txn.insert('food_portions', row);

      if (isDefault) {
        try {
          await txn.update(
            'foods',
            {'default_portion_id': newId},
            where: 'id = ?',
            whereArgs: [foodId],
          );
        } catch (_) {
          /* older schema */
        }
      }
      return newId;
    });
  }

  Future<void> replacePortions(int foodId, List<FoodPortion> portions) async {
    await db.transaction((txn) async {
      // Clear existing portions for this food.
      await txn.delete(
        'food_portions',
        where: 'food_id = ?',
        whereArgs: [foodId],
      );

      // Discover which columns exist on this device's DB.
      final cols = await txn.rawQuery('PRAGMA table_info(food_portions)');
      final haveCols = {for (final r in cols) (r['name'] as String)};
      Map<String, Object?> prune(Map<String, Object?> raw) {
        final out = <String, Object?>{};
        raw.forEach((k, v) {
          if (haveCols.contains(k)) out[k] = v;
        });
        return out;
      }

      final anyDefault = portions.any((p) => p.isDefault);
      bool assignedDefault = false;
      int order = 0;
      int? defaultId;

      for (final p in portions) {
        final gw =
            (p.gramWeight != null && p.gramWeight! > 0) ? p.gramWeight : null;
        final mv = (p.mlVolume != null && p.mlVolume! > 0) ? p.mlVolume : null;
        if (gw == null && mv == null) {
          continue; // skip invalid portion; don't advance order
        }

        final isDef = anyDefault ? p.isDefault : !assignedDefault;

        final measureName =
            (p.measureName.trim().isNotEmpty)
                ? p.measureName.trim()
                : _composeMeasureName(p);

        // Build full row with new columns…
        final raw = <String, Object?>{
          'food_id': foodId,
          'measure_name': measureName,
          'gram_weight': gw,
          'ml_volume': mv,
          'is_default': isDef ? 1 : 0,
          // v23+ (will be pruned on older schemas):
          'list_kind': p.listKind,
          'sort_order': p.sortOrder ?? order,
          'amount': p.amount,
          'unit': p.unit,
          'label': p.label,
        };

        // …but insert only the columns the table actually has.
        final row = prune(raw);
        final newId = await txn.insert('food_portions', row);

        if (isDef) {
          defaultId = newId;
          assignedDefault = true;
        }
        order++; // advance order only when we inserted a row
      }

      if (defaultId != null) {
        try {
          await txn.update(
            'foods',
            {'default_portion_id': defaultId},
            where: 'id = ?',
            whereArgs: [foodId],
          );
        } catch (_) {
          // older schema without foods.default_portion_id — safe to ignore
        }
      }
    });

    // Keep any dependent recipe caches in sync with new portions.
    await _refreshRecipeCachesForFood(foodId);
  }

  // Helpers (keep private in the DAO file)
  String _composeMeasureName(FoodPortion p) {
    if ((p.measureName).trim().isNotEmpty) return p.measureName.trim();
    if ((p.label ?? '').trim().isNotEmpty) return p.label!.trim();

    final parts = <String>[];
    if (p.amount != null && (p.unit?.trim().isNotEmpty ?? false)) {
      parts.add('${_trimNum(p.amount!)} ${p.unit!.trim()}');
    }
    if (p.gramWeight != null) parts.add('• ${_trimNum(p.gramWeight!)} g');
    if (p.mlVolume != null) parts.add('• ${_trimNum(p.mlVolume!)} ml');

    return parts.isEmpty ? 'Portion' : parts.join(' ');
  }

  String _trimNum(num v) {
    final s = v.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Future<void> updateFoodBasics(int id, {String? name, String? brand}) async {
    await db.transaction((txn) async {
      final brandTrim = brand?.trim();
      final brandId = await _ensureBrandTx(txn, brandTrim);

      final raw = <String, Object?>{
        if (name != null) 'name': name.trim(),
        'brand': (brandTrim?.isEmpty ?? true) ? null : brandTrim,
        'brand_id': brandId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final row = await _sanitizeFoodWriteTx(txn, raw);
      await txn.update('foods', row, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int?> _ensureBrandTx(DatabaseExecutor ex, String? name) async {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    await ex.insert('brands', {
      'name': n,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return Sqflite.firstIntValue(
      await ex.rawQuery(
        'SELECT id FROM brands WHERE lower(name) = lower(?) LIMIT 1',
        [n],
      ),
    );
  }

  Future<int?> _ensureSourceTx(DatabaseExecutor ex, String? name) async {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    await ex.insert('sources', {
      'name': n,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return Sqflite.firstIntValue(
      await ex.rawQuery(
        'SELECT id FROM sources WHERE lower(name) = lower(?) LIMIT 1',
        [n],
      ),
    );
  }

  Future<int?> _ensureCategoryTx(DatabaseExecutor ex, String? name) async {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    await ex.insert('categories', {
      'name': n,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return Sqflite.firstIntValue(
      await ex.rawQuery(
        'SELECT id FROM categories WHERE lower(name) = lower(?) LIMIT 1',
        [n],
      ),
    );
  }

  Future<int> upsertFoodWithKeys({
    int? id,
    required String name,
    String? brandName,
    String? sourceName,
    String? categoryName,
    List<String> barcodes = const [],
    double? densityGPerMl,
    bool isCustom = false,
    String? dataSource, // e.g. 'seed','fdc','user'
    String? dataSourceId, // external id
    bool? verified, // ← NEW (coerced to 0/1/NULL)
    int? version, // ← NEW (optional)
    int? qualityScore, // ← NEW (optional)
    String? preparation, // ← NEW (optional)
  }) async {
    final foodId = await db.transaction<int>((txn) async {
      final brandId = await _ensureBrandTx(txn, brandName);
      final sourceId = await _ensureSourceTx(txn, sourceName ?? dataSource);
      final categoryId = await _ensureCategoryTx(txn, categoryName);

      final raw = <String, Object?>{
        'name': name.trim(),
        'brand': (brandName?.trim().isEmpty ?? true) ? null : brandName!.trim(),
        'brand_id': brandId,
        'category_id': categoryId,
        'is_custom': isCustom, // coerced later
        'verified': verified, // coerced later
        'data_source': dataSource,
        'data_source_id': dataSourceId,
        'source_id': sourceId,
        'density_g_per_ml':
            (densityGPerMl != null && densityGPerMl > 0) ? densityGPerMl : null,
        'quality_score': qualityScore,
        'version': version,
        'preparation': preparation,
        'is_deleted': 0, // coerced later
        'updated_at': DateTime.now().toIso8601String(),
      };

      final row = await _sanitizeFoodWriteTx(txn, raw);

      int outId;
      if (id == null) {
        row['created_at'] = DateTime.now().toIso8601String();
        outId = await txn.insert('foods', row);
      } else {
        await txn.update('foods', row, where: 'id = ?', whereArgs: [id]);
        outId = id;
      }

      for (final raw in barcodes) {
        await _insertBarcodeSafe(txn, outId, raw);
      }
      return outId;
    });

    await _refreshRecipeCachesForFood(foodId);
    return foodId;
  }

  Future<Food?> getFoodByBarcode(String code) async {
    final upc = code.replaceAll(RegExp(r'\D'), '');
    if (upc.isEmpty) return null;
    final rows = await db.rawQuery(
      '''
    SELECT f.*
    FROM food_barcodes b
    JOIN foods f ON f.id = b.food_id
    WHERE b.upc = ? AND f.is_deleted = 0
    LIMIT 1
  ''',
      [upc],
    );
    if (rows.isEmpty) return null;
    return Food.fromMap(rows.first);
  }

  Future<void> addBarcode(int foodId, String code) async {
    await _insertBarcodeSafe(db, foodId, code);
  }

  Future<void> setFoodDefaultPortion(int foodId, int portionId) async {
    await db.transaction((txn) async {
      await txn.update(
        'food_portions',
        {'is_default': 0},
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      await txn.update(
        'food_portions',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [portionId],
      );
      try {
        await txn.update(
          'foods',
          {'default_portion_id': portionId},
          where: 'id = ?',
          whereArgs: [foodId],
        );
      } catch (_) {
        /* column may not exist on older DBs */
      }
    });
  }

  /// Returns a small map of macro totals for a given food/portion/quantity.
  /// Keys: kcal, protein_g, fat_g, carbs_g, fiber_g, sugar_g, sat_fat_g, sodium_mg
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async {
    final grams = await _resolveFoodGrams(foodId, portionId, quantity);
    if (grams == null || grams <= 0) return {};

    // Use the same fallback chain you use for diary totals
    final per100 = await _per100WithFallback(foodId, portionId: portionId);
    double pick(String code) => _calcCode(per100, grams, code);
    final kcal = pick('ENERGY_KCAL');

    return {
      'kcal':
          (kcal > 0)
              ? kcal
              : (4 * pick('PROTEIN') + 4 * pick('CARB') + 9 * pick('FAT')),
      'protein_g': pick('PROTEIN'),
      'fat_g': pick('FAT'),
      'carbs_g': pick('CARB'),
      'fiber_g': pick('FIBER'),
      'sugar_g': pick('SUGARS'),
      'sat_fat_g': pick('FASAT'),
      'sodium_mg': pick('SODIUM'),
    };
  }

  Future<Map<String, double>> _per100WithFallback(
    int foodId, {
    int? portionId,
  }) async {
    // 1) Prefer per_portion for the selected (or default) portion, converting to per-100g
    int? pid = portionId;
    if (pid == null) {
      try {
        final f = await db.query(
          'foods',
          columns: ['default_portion_id'],
          where: 'id = ?',
          whereArgs: [foodId],
          limit: 1,
        );
        pid = f.isNotEmpty ? f.first['default_portion_id'] as int? : null;
      } catch (_) {
        // older schema may not have foods.default_portion_id; ignore
      }
    }

    if (pid != null) {
      final perPortion = await db.rawQuery(
        '''
      SELECT n.code AS code, fnv.amount AS amount
      FROM food_nutrient_values fnv
      JOIN nutrients n ON n.id = fnv.nutrient_id
      WHERE fnv.food_id = ? AND fnv.basis = 'per_portion' AND fnv.portion_id = ?
    ''',
        [foodId, pid],
      );

      if (perPortion.isNotEmpty) {
        final pRow = await db.query(
          'food_portions',
          where: 'id = ?',
          whereArgs: [pid],
          limit: 1,
        );
        if (pRow.isNotEmpty) {
          final grams = (pRow.first['gram_weight'] as num?)?.toDouble();
          if (grams != null && grams > 0) {
            final factor = 100.0 / grams;
            return {
              for (final r in perPortion)
                _canonCode(r['code'] as String):
                    (r['amount'] as num).toDouble() * factor,
            };
          }
        }
      }
    }

    // 2) Fall back to stored per_100g
    final per100 = await getFoodNutrientsPer100gByCode(foodId);
    if (per100.isNotEmpty) return per100;

    // 3) Fall back to per_100ml → per_100g using density
    final per100ml = await db.rawQuery(
      '''
    SELECT n.code AS code, fnv.amount AS amount
    FROM food_nutrient_values fnv
    JOIN nutrients n ON n.id = fnv.nutrient_id
    WHERE fnv.food_id = ? AND fnv.basis = 'per_100ml'
  ''',
      [foodId],
    );

    if (per100ml.isNotEmpty) {
      final food = await getFood(foodId);
      final rho = food?.densityGPerMl;
      if (rho != null && rho > 0) {
        return {
          for (final r in per100ml)
            _canonCode(r['code'] as String):
                (r['amount'] as num).toDouble() / rho,
        };
      }
    }

    // Nothing available
    return {};
  }

  int _nowEpochMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Compute kcal/protein/carb/fat snapshot for a given grams amount.
  Map<String, double> _computeMacroSnapshot(
    Map<String, double> per100ByCode,
    double grams,
  ) {
    double pick(String code) => _calcCode(per100ByCode, grams, code);

    final protein = pick('PROTEIN');
    final carbs = pick('CARB');
    final fat = pick('FAT');

    final kcalDirect = pick('ENERGY_KCAL');
    final kcal =
        (kcalDirect > 0) ? kcalDirect : 4 * protein + 4 * carbs + 9 * fat;

    return {'kcal': kcal, 'protein_g': protein, 'carb_g': carbs, 'fat_g': fat};
  }

  /// Compute and persist per-100g nutrients for a recipe into recipe_nutrients.
  /// Uses ingredient grams; if total grams is 0, clears the cache.
  Future<void> rebuildRecipeNutrientCache(int recipeId) async {
    final ings = await getRecipeIngredients(recipeId);

    // Accumulate absolute totals across ingredients.
    final totals = <String, double>{};
    double totalGrams = 0;

    for (final ing in ings) {
      final g = await _resolveIngredientGrams(ing);
      if (g == null || g <= 0) continue;
      totalGrams += g;

      final per100 = await _per100WithFallback(
        ing.foodId,
        portionId: ing.portionId,
      );
      if (per100.isEmpty) continue;

      per100.forEach((code, per100Val) {
        final add = per100Val * (g / 100.0);
        totals[code] = (totals[code] ?? 0) + add;
      });
    }

    final batch = db.batch();
    // Wipe previous cache
    batch.delete(
      'recipe_nutrients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    if (totalGrams > 0) {
      // Convert absolute totals → per 100g
      totals.forEach((code, absVal) {
        final per100g = absVal * (100.0 / totalGrams);
        // Store DB-friendly codes (e.g., ENERGY_KCAL → KCAL, SUGARS → SUGARS_TOTAL_G)
        final dbCode = _toDb(code);
        batch.insert('recipe_nutrients', {
          'recipe_id': recipeId,
          'code': dbCode,
          'per_100g': per100g,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }

    await batch.commit(noResult: true);
  }

  /// Read cached per-100g by code for a recipe.
  /// Returns keys canonicalized (ENERGY_KCAL/PROTEIN/CARB/FAT/SUGARS/FASAT/SODIUM...).
  Future<Map<String, double>> getRecipePer100gByCode(int recipeId) async {
    final rows = await db.query(
      'recipe_nutrients',
      columns: ['code', 'per_100g'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    final out = <String, double>{};
    for (final r in rows) {
      final canon = _canonCode(r['code'] as String);
      out[canon] = (r['per_100g'] as num).toDouble();
    }
    return out;
  }

  /// All recipes that reference a given food.
  Future<List<int>> _recipeIdsUsingFood(int foodId) async {
    final rows = await db.rawQuery(
      'SELECT DISTINCT recipe_id FROM recipe_ingredients WHERE food_id = ?',
      [foodId],
    );
    return rows.map((r) => (r['recipe_id'] as int)).toList();
  }

  /// Rebuild caches for any recipes that include this food.
  Future<void> _refreshRecipeCachesForFood(int foodId) async {
    final recipeIds = await _recipeIdsUsingFood(foodId);
    for (final rid in recipeIds) {
      await rebuildRecipeNutrientCache(rid);
    }
  }

  DateTime _parseYMD(String s) {
    // Stored as 'YYYY-MM-DD' (local-date semantics)
    final p = s.split('-');
    if (p.length != 3) throw FormatException('Bad YMD: $s');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAGS (CRUD + filter)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> addDiaryTag(int entryId, String tag) async {
    final t = normalizeDiaryTag(tag);
    if (t.isEmpty) return;
    await db.insert('diary_entry_tags', {
      'entry_id': entryId,
      'tag': t,
      'created_at': _nowEpochMs(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeDiaryTag(int entryId, String tag) async {
    final t = normalizeDiaryTag(tag);
    await db.delete(
      'diary_entry_tags',
      where: 'entry_id = ? AND tag = ?',
      whereArgs: [entryId, t],
    );
  }

  Future<List<String>> getTagsForEntry(int entryId) async {
    final rows = await db.query(
      'diary_entry_tags',
      columns: ['tag'],
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'tag ASC',
    );
    return rows.map((r) => r['tag'] as String).toList();
  }

  /// Optional: fetch entries by tag (time window inclusive if provided).
  Future<List<DiaryEntry>> getEntriesByTag({
    required int profileId,
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) async {
    final t = normalizeDiaryTag(tag);
    final args = <Object?>[profileId, t];
    final where = StringBuffer(
      'e.profile_id = ? AND det.tag = ? AND e.is_deleted = 0',
    );

    if (start != null) {
      where.write(' AND (e.logged_at IS NOT NULL AND e.logged_at >= ?)');
      args.add(start.toUtc().millisecondsSinceEpoch);
    }
    if (end != null) {
      where.write(' AND (e.logged_at IS NOT NULL AND e.logged_at <= ?)');
      args.add(end.toUtc().millisecondsSinceEpoch);
    }

    final rows = await db.rawQuery(
      '''
    SELECT e.*
    FROM diary_entry_tags det
    JOIN diary_entries e ON e.id = det.entry_id
    WHERE $where
    ORDER BY COALESCE(e.logged_at, 0) DESC, e.id DESC
    LIMIT ?
  ''',
      [...args, limit],
    );

    return rows.map(DiaryEntry.fromMap).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FAVORITES (CRUD + list)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> addFavorite(int profileId, int foodId) async {
    await db.insert('favorite_foods', {
      'profile_id': profileId,
      'food_id': foodId,
      'created_at': _nowEpochMs(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFavorite(int profileId, int foodId) async {
    await db.delete(
      'favorite_foods',
      where: 'profile_id = ? AND food_id = ?',
      whereArgs: [profileId, foodId],
    );
  }

  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async {
    final rows = await db.rawQuery(
      '''
    SELECT f.*
    FROM favorite_foods fav
    JOIN foods f ON f.id = fav.food_id
    WHERE fav.profile_id = ? AND f.is_deleted = 0
    ORDER BY fav.created_at DESC
    LIMIT ?
  ''',
      [profileId, limit],
    );

    return rows.map(Food.fromMap).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // RECENTS (by MAX(logged_at))
  // ───────────────────────────────────────────────────────────────────────────

  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) async {
    final rows = await db.rawQuery(
      '''
    SELECT f.*
    FROM (
      SELECT food_id, MAX(logged_at) AS last_used
      FROM diary_entries
      WHERE profile_id = ? AND is_deleted = 0 AND food_id IS NOT NULL
      GROUP BY food_id
      ORDER BY last_used DESC
      LIMIT ?
    ) r
    JOIN foods f ON f.id = r.food_id
    WHERE f.is_deleted = 0
    ORDER BY r.last_used DESC
  ''',
      [profileId, limit],
    );

    return rows.map(Food.fromMap).toList();
  }

  Future<List<Recipe>> getRecentRecipes(int profileId, {int limit = 20}) async {
    final rows = await db.rawQuery(
      '''
      SELECT rc.*
      FROM (
        SELECT recipe_id, MAX(logged_at) AS last_used
        FROM diary_entries
        WHERE profile_id = ? AND is_deleted = 0 AND recipe_id IS NOT NULL
        GROUP BY recipe_id
        ORDER BY last_used DESC
        LIMIT ?
      ) r
      JOIN recipes rc ON rc.id = r.recipe_id
      WHERE rc.is_deleted = 0
      ORDER BY r.last_used DESC
    ''',
      [profileId, limit],
    );

    return rows.map(Recipe.fromMap).toList();
  }

  /// Aggregate selected micronutrient codes for a given profile/day.
  Future<Map<String, double>> getDayMicros(
    int profileId,
    DateTime date,
    List<String> codes,
  ) async {
    if (codes.isEmpty) return {};
    final origToCanon = {for (final c in codes) c: _canonCode(c)};
    final canonSet = origToCanon.values.toSet();

    final entries = await getDiaryEntriesForDate(profileId, date);
    final totalsByCanon = <String, double>{for (final c in canonSet) c: 0.0};

    for (final e in entries) {
      if (e.foodId != null) {
        final grams =
            e.loggedGrams ??
            e.grams ??
            await _resolveFoodGrams(e.foodId!, e.portionId, e.quantity);
        if (grams == null || grams <= 0) continue;
        final per100 = await _per100WithFallback(
          e.foodId!,
          portionId: e.portionId,
        );
        for (final canon in canonSet) {
          totalsByCanon[canon] =
              (totalsByCanon[canon] ?? 0) + _calcCode(per100, grams, canon);
        }
      } else if (e.recipeId != null) {
        final ings = await getRecipeIngredients(e.recipeId!);
        for (final ing in ings) {
          final g = await _resolveIngredientGrams(ing);
          if (g == null || g <= 0) continue;
          final per100 = await _per100WithFallback(
            ing.foodId,
            portionId: ing.portionId,
          );
          for (final canon in canonSet) {
            totalsByCanon[canon] =
                (totalsByCanon[canon] ?? 0) +
                _calcCode(per100, g * e.quantity, canon);
          }
        }
      }
    }

    final out = <String, double>{};
    origToCanon.forEach((orig, canon) {
      out[orig] = totalsByCanon[canon] ?? 0.0;
    });
    return out;
  }

  Future<void> _maybeEnsureEnergyKcalInV22(int foodId) async {
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

    final rows = await db.rawQuery(
      '''
      SELECT nutrient_id, amount
      FROM food_nutrient_values
      WHERE food_id = ? AND basis = 'per_100g' AND nutrient_id IN (?,?,?,?)
    ''',
      [foodId, kcalId, pId, cId, fId],
    );

    double? kcal, p, c, f;
    for (final r in rows) {
      final nid = r['nutrient_id'] as int;
      final v = (r['amount'] as num).toDouble();
      if (nid == kcalId) kcal = v;
      if (nid == pId) p = v;
      if (nid == cId) c = v;
      if (nid == fId) f = v;
    }
    if (kcal != null) return;

    final est = 4.0 * ((p ?? 0) + (c ?? 0)) + 9.0 * (f ?? 0);
    if (est <= 0) return;

    await db.transaction((txn) async {
      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': kcalId,
        'amount': est,
        'basis': 'per_100g',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('food_nutrients', {
        'food_id': foodId,
        'nutrient_id': kcalId,
        'amount_per_100g': est,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    });
  }

  // Add near the bottom of the class (private helper)
  Future<bool> _hasColumn(String table, String col) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any(
      (r) => (r['name'] as String).toLowerCase() == col.toLowerCase(),
    );
  }

  Map<String, Object?> _buildPortionRow({
    required int foodId,
    required String measureName,
    double? gramWeight,
    double? mlVolume,
    required bool isDefault,
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) {
    final gw = (gramWeight != null && gramWeight > 0) ? gramWeight : null;
    final mv = (mlVolume != null && mlVolume > 0) ? mlVolume : null;

    if (gw == null && mv == null) {
      throw StateError('Portion requires gram_weight > 0 OR ml_volume > 0');
    }

    return {
      'food_id': foodId,
      'measure_name':
          measureName.trim().isEmpty ? 'Portion' : measureName.trim(),
      'gram_weight': gw, // keep NULL, not 0
      'ml_volume': mv, // keep NULL, not 0
      'is_default': isDefault ? 1 : 0,
      'list_kind': listKind,
      'sort_order': sortOrder,
      'amount': amount,
      'unit': unit,
      'label': label,
    };
  }

  Future<Map<String, Object?>> _pruneToTable(
    String table,
    Map<String, Object?> row,
  ) async {
    final cols = await db.rawQuery('PRAGMA table_info($table)');
    final have = {for (final r in cols) (r['name'] as String)};
    final out = <String, Object?>{};
    row.forEach((k, v) {
      if (have.contains(k)) out[k] = v;
    });
    return out;
  }

  Future<List<DiaryEntryRow>> getDiaryEntryRowsForDate(
    int profileId,
    DateTime date,
  ) async {
    final rows = await db.rawQuery(
      '''
    SELECT e.*,
           COALESCE(f.name, r.name) AS display_title
    FROM diary_entries e
    LEFT JOIN foods   f ON e.food_id   = f.id
    LEFT JOIN recipes r ON e.recipe_id = r.id
    WHERE e.profile_id = ? AND e.date = ? AND e.is_deleted = 0
    ORDER BY COALESCE(e.logged_at, 0) ASC, e.meal_type ASC, e.id ASC
  ''',
      [profileId, _toYMD(date)],
    );

    return rows.map((m) {
      final entry = DiaryEntry.fromMap(m);
      final title = (m['display_title'] as String?)?.trim();
      return DiaryEntryRow(
        entry: entry,
        displayTitle:
            (title == null || title.isEmpty) ? entry.defaultTitle : title,
      );
    }).toList();
  }
}
