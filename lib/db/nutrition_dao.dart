// File: lib/db/nutrition_dao.dart
// ignore_for_file: constant_identifier_names

import 'package:sqflite/sqflite.dart';
import '../models/nutrition_models.dart';

/// IMPORTANT: Adjust these IDs to match what you seed in `nutrients`.
/// Suggested defaults (FoodData Central style):
const int NID_KCAL   = 1008;
const int NID_PRO    = 1003;
const int NID_FAT    = 1004;
const int NID_CARB   = 1005;
const int NID_FIBER  = 1079;
const int NID_SUGAR  = 2000; // confirm in your seed
const int NID_SATFAT = 1258; // confirm in your seed
const int NID_SODIUM = 1093;

String _toYMD(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final da = d.day.toString().padLeft(2, '0');
  return '$y-$m-$da';
}


class NutritionDao {
  final Database db;
  NutritionDao(this.db);

  // Put near top of NutritionDao (outside methods)
static const Map<String, String> _CODE_SYNONYMS = {
  // Calories
  'KCAL': 'ENERGY_KCAL',
  'CALORIES': 'ENERGY_KCAL',        // if it ever shows up as a code
  // Macros
  'PROTEIN_G': 'PROTEIN',
  'CARB_G': 'CARB',
  'FAT_G': 'FAT',
  // Common extended -> canonical
  'SUGARS_TOTAL_G': 'SUGARS',
  'FA_SAT_G': 'FASAT',
  'SODIUM_MG': 'SODIUM',
};

String _canonCode(String code) {
  final up = code.toUpperCase();
  return _CODE_SYNONYMS[up] ?? up;
}


  // ───────────────────────────────────────────────────────────────────────────
  // SEEDING
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> seedNutrientsIfEmpty() async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM nutrients')
    ) ?? 0;
    if (count > 0) return;

    final batch = db.batch();
    // Minimal core seed; extend as you like.
    batch.insert('nutrients', {'id': NID_KCAL,   'code': 'ENERGY_KCAL', 'name': 'Energy',      'unit': 'kcal'});
    batch.insert('nutrients', {'id': NID_PRO,    'code': 'PROTEIN',     'name': 'Protein',     'unit': 'g'});
    batch.insert('nutrients', {'id': NID_FAT,    'code': 'FAT',         'name': 'Fat',         'unit': 'g'});
    batch.insert('nutrients', {'id': NID_CARB,   'code': 'CARB',        'name': 'Carbohydrate','unit': 'g'});
    batch.insert('nutrients', {'id': NID_FIBER,  'code': 'FIBER',       'name': 'Fiber',       'unit': 'g'});
    batch.insert('nutrients', {'id': NID_SUGAR,  'code': 'SUGARS',      'name': 'Sugars',      'unit': 'g'});
    batch.insert('nutrients', {'id': NID_SATFAT, 'code': 'FASAT',       'name': 'Sat. Fat',    'unit': 'g'});
    batch.insert('nutrients', {'id': NID_SODIUM, 'code': 'SODIUM',      'name': 'Sodium',      'unit': 'mg'});
    await batch.commit(noResult: true);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FOODS & PORTIONS & NUTRIENTS
  // ───────────────────────────────────────────────────────────────────────────

  Future<int> upsertFood(Food f) async {
    final map = f.toMap();
    if (f.id == null) {
      return await db.insert('foods', map);
    } else {
      await db.update('foods', map, where: 'id = ?', whereArgs: [f.id]);
      return f.id!;
    }
  }

  Future<Food?> getFood(int id) async {
    final rows = await db.query('foods', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Food.fromMap(rows.first);
  }

  Future<List<Food>> searchFoods(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) {
      final rows = await db.query('foods',
        where: 'is_deleted = 0',
        orderBy: 'name',
        limit: limit,
      );
      return rows.map(Food.fromMap).toList();
    }

    // Try FTS5 first
    try {
      final rows = await db.rawQuery('''
        SELECT f.*
        FROM food_search_fts s
        JOIN foods f ON f.id = s.rowid
        WHERE s MATCH ?
        AND f.is_deleted = 0
        ORDER BY bm25(s)
        LIMIT ?
      ''', [query, limit]);
      if (rows.isNotEmpty) return rows.map(Food.fromMap).toList();
    } catch (_) {
      // FTS might not exist; fallback
    }

    final like = '%${query.replaceAll('%', '\\%')}%';
    final rows = await db.query('foods',
      where: 'is_deleted = 0 AND (name LIKE ? OR (brand IS NOT NULL AND brand LIKE ?))',
      whereArgs: [like, like],
      orderBy: 'name',
      limit: limit,
    );
    return rows.map(Food.fromMap).toList();
  }

  Future<int> upsertFoodPortion(FoodPortion p) async {
    final map = p.toMap();
    if (p.id == null) {
      return await db.insert('food_portions', map);
    } else {
      await db.update('food_portions', map, where: 'id = ?', whereArgs: [p.id]);
      return p.id!;
    }
  }

  Future<List<FoodPortion>> getPortionsForFood(int foodId) async {
  final rows = await db.query(
    'food_portions',
    where: 'food_id = ?',
    whereArgs: [foodId],
    // default first, then group, then sort_order, then id
    orderBy: "is_default DESC, COALESCE(list_kind,''), COALESCE(sort_order, 999999), id ASC",
  );
  return rows.map(FoodPortion.fromMap).toList();
}


  Future<void> setDefaultPortion(int foodId, int portionId) async {
    await db.transaction((txn) async {
      await txn.update('food_portions', {'is_default': 0}, where: 'food_id = ?', whereArgs: [foodId]);
      await txn.update('food_portions', {'is_default': 1}, where: 'id = ?', whereArgs: [portionId]);
    });
  }

  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) async {
    await db.transaction((txn) async {
      await txn.delete('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);
      for (final r in rows) {
        await txn.insert('food_nutrients', {
          'food_id': foodId,
          'nutrient_id': r.nutrientId,
          'amount_per_100g': r.amountPer100g,
        });
      }
    });
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
  final rows = await db.query('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);
  final map = <int, double>{};
  for (final r in rows) {
    map[r['nutrient_id'] as int] = (r['amount_per_100g'] as num).toDouble();
  }
  return map;
}


  // keep your existing int-keyed method if you want; add this alongside it
Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) async {
  // Prefer v22 flexible table
    final rows = await db.rawQuery('''
      SELECT n.code AS code, fnv.amount AS amount
      FROM food_nutrient_values fnv
      JOIN nutrients n ON n.id = fnv.nutrient_id
      WHERE fnv.food_id = ? AND fnv.basis = 'per_100g'
    ''', [foodId]);

    if (rows.isNotEmpty) {
    final out = <String, double>{};
    for (final r in rows) {
      final code = _canonCode(r['code'] as String);
      out[code] = (r['amount'] as num).toDouble();
    }
    return out;
  }

    // Fallback to legacy per_100g table (if any)
    final legacy = await db.rawQuery('''
      SELECT n.code AS code, fn.amount_per_100g AS amount
      FROM food_nutrients fn
      JOIN nutrients n ON n.id = fn.nutrient_id
      WHERE fn.food_id = ?
    ''', [foodId]);

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

  Future<int> createOrUpdateRecipe(Recipe r, List<RecipeIngredient> ings) async {
    return await db.transaction<int>((txn) async {
      int rid;
      final map = r.toMap();
      if (r.id == null) {
        rid = await txn.insert('recipes', map);
      } else {
        rid = r.id!;
        await txn.update('recipes', map, where: 'id = ?', whereArgs: [rid]);
        await txn.delete('recipe_ingredients', where: 'recipe_id = ?', whereArgs: [rid]);
      }
      for (final ing in ings) {
        await txn.insert('recipe_ingredients', {
          'recipe_id': rid,
          'food_id': ing.foodId,
          'portion_id': ing.portionId,
          'quantity': ing.quantity,
          'grams': ing.grams,
        });
      }
      return rid;
    });
  }

  Future<Recipe?> getRecipe(int id) async {
    final rows = await db.query('recipes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Recipe.fromMap(rows.first);
  }

  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    final rows = await db.query('recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId]
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
    double? gramsOverride,
    String? notes,
  }) async {
    final resolvedGrams = gramsOverride ?? await _resolveFoodGrams(foodId, portionId, quantity);
    final id = await db.insert('diary_entries', {
      'profile_id': profileId,
      'date': _toYMD(date),
      'meal_type': mealType.index,
      'food_id': foodId,
      'recipe_id': null,
      'portion_id': portionId,
      'quantity': quantity,
      'grams': resolvedGrams,
      'notes': notes,
    });
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
    String? notes,
  }) async {
    final id = await db.insert('diary_entries', {
      'profile_id': profileId,
      'date': _toYMD(date),
      'meal_type': mealType.index,
      'food_id': null,
      'recipe_id': recipeId,
      'portion_id': null,
      'quantity': quantity,
      'grams': null, // recipe grams computed from ingredients on recalc
      'notes': notes,
    });
    await recalcDayTotals(profileId, date);
    return id;
  }

  Future<void> updateDiaryEntry(DiaryEntry e) async {
    await db.update('diary_entries', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
    await recalcDayTotals(e.profileId, e.date);
  }

  Future<void> deleteDiaryEntry(int id, {required int profileId, required DateTime date}) async {
    await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
    await recalcDayTotals(profileId, date);
  }

  Future<List<DiaryEntry>> getDiaryEntriesForDate(int profileId, DateTime date) async {
    final rows = await db.query('diary_entries',
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, _toYMD(date)],
      orderBy: 'meal_type, id',
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GOALS
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> setGoals(NutritionGoal goal) async {
    await db.transaction((txn) async {
      // Close any open goal overlapping this start
      await txn.update('nutrition_goals',
        {'end_date': _toYMD(goal.startDate.subtract(const Duration(days: 1)))},
        where: 'profile_id = ? AND (end_date IS NULL OR end_date >= ?)',
        whereArgs: [goal.profileId, _toYMD(goal.startDate)],
      );
      // Insert new goal
      await txn.insert('nutrition_goals', goal.toMap());
    });
  }

  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async {
    final rows = await db.query('nutrition_goals',
      where: 'profile_id = ? AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
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
    final rows = await db.query('day_totals_cache',
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, ymd],
      limit: 1,
    );
    if (rows.isNotEmpty) return DayTotals.fromMap(rows.first);
    // Build it on demand
    await recalcDayTotals(profileId, date);
    final rows2 = await db.query('day_totals_cache',
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

    double kcal = 0, pro = 0, fat = 0, carb = 0, fiber = 0, sugar = 0, sat = 0, sodium = 0;

    // Pre-fetch frequently used maps to reduce queries where possible.
    Future<Map<int, double>> foodMapCache(int foodId) => getFoodNutrientsPer100g(foodId);

    for (final e in entries) {
      if (e.foodId != null) {
        final grams = e.grams ?? await _resolveFoodGrams(e.foodId!, e.portionId, e.quantity);
        if (grams == null) continue; // skip if unresolved
        final per100 = await foodMapCache(e.foodId!);
        kcal   += _calc(per100, grams, NID_KCAL);
        pro    += _calc(per100, grams, NID_PRO);
        fat    += _calc(per100, grams, NID_FAT);
        carb   += _calc(per100, grams, NID_CARB);
        fiber  += _calc(per100, grams, NID_FIBER);
        sugar  += _calc(per100, grams, NID_SUGAR);
        sat    += _calc(per100, grams, NID_SATFAT);
        sodium += _calc(per100, grams, NID_SODIUM);
      } else if (e.recipeId != null) {
        final ings = await getRecipeIngredients(e.recipeId!);
        double rK = 0, rP = 0, rF = 0, rC = 0, rFi = 0, rSu = 0, rSa = 0, rNa = 0;

        for (final ing in ings) {
          final g = await _resolveIngredientGrams(ing);
          if (g == null || g <= 0) continue;
          final per100 = await foodMapCache(ing.foodId);
          rK  += _calc(per100, g, NID_KCAL);
          rP  += _calc(per100, g, NID_PRO);
          rF  += _calc(per100, g, NID_FAT);
          rC  += _calc(per100, g, NID_CARB);
          rFi += _calc(per100, g, NID_FIBER);
          rSu += _calc(per100, g, NID_SUGAR);
          rSa += _calc(per100, g, NID_SATFAT);
          rNa += _calc(per100, g, NID_SODIUM);
        }

        // Multiply by diary quantity (recipe multiplier)
        final q = e.quantity;
        kcal   += rK  * q;
        pro    += rP  * q;
        fat    += rF  * q;
        carb   += rC  * q;
        fiber  += rFi * q;
        sugar  += rSu * q;
        sat    += rSa * q;
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

  double _calc(Map<int, double> per100, double grams, int nid) {
    final v = per100[nid];
    if (v == null) return 0;
    return v * (grams / 100.0);
    // kcal already per-100g in data; no 4/4/9 here.
  }

  Future<double?> _resolveFoodGrams(int foodId, int? portionId, double quantity) async {
  if (portionId == null) return null;
  final rows = await db.query('food_portions', where: 'id = ?', whereArgs: [portionId], limit: 1);
  if (rows.isEmpty) return null;
  final p = FoodPortion.fromMap(rows.first);
  if (p.gramWeight != null) return p.gramWeight! * quantity;

  if (p.mlVolume != null) {
    final food = await getFood(foodId);
    final density = food?.densityGPerMl ?? 1.0; // TODO: use real density when available
    return p.mlVolume! * quantity * density;
  }
  return null;
}

  Future<double?> _resolveIngredientGrams(RecipeIngredient ing) async {
  if (ing.grams != null) return ing.grams;
  if (ing.portionId != null && ing.quantity != null) {
    final rows = await db.query('food_portions', where: 'id = ?', whereArgs: [ing.portionId], limit: 1);
    if (rows.isNotEmpty) {
      final p = FoodPortion.fromMap(rows.first);
      if (p.gramWeight != null) return p.gramWeight! * ing.quantity!;
      if (p.mlVolume != null) {
        final food = await getFood(ing.foodId);
        final density = food?.densityGPerMl ?? 1.0; // TODO: use real density when available
        return p.mlVolume! * ing.quantity! * density;
      }
    }
  }
  return null;
}

  Future<void> _bumpFoodUsage(int profileId, int foodId) async {
    final now = DateTime.now().toIso8601String();
    await db.insert('food_usage_stats', {
      'profile_id': profileId,
      'food_id': foodId,
      'hits': 1,
      'last_used': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.rawUpdate('''
      UPDATE food_usage_stats
      SET hits = hits + 1, last_used = ?
      WHERE profile_id = ? AND food_id = ?
    ''', [now, profileId, foodId]);
  }

   // --- CREATE a custom food -----------------------------------------------
  Future<int> insertCustomFood({
    required String name,
    String? brand,
  }) async {
    return await db.insert('foods', {
      'name': name,
      'brand': brand?.trim().isEmpty == true ? null : brand?.trim(),
      'is_custom': 1,
      'data_source': 'user',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // --- Utility: map nutrient code -> id ------------------------------------
  Future<Map<String, int>> _codeToId(Set<String> codes) async {
    if (codes.isEmpty) return {};
    final placeholders = List.filled(codes.length, '?').join(',');
    final rows = await db.query(
      'nutrients',
      columns: ['id','code'],
      where: 'code IN ($placeholders)',
      whereArgs: codes.toList(),
    );
    return {
      for (final r in rows) (r['code'] as String): (r['id'] as int),
    };
  }

  // --- UPSERT per-100g by code into v22 table ------------------------------
  Future<void> replacePer100gByCode(int foodId, Map<String, double> codeToAmount) async {
  if (codeToAmount.isEmpty) return;

  // normalize incoming keys first
  final normalized = <String, double>{};
  codeToAmount.forEach((k, v) => normalized[_canonCode(k)] = v);

  final c2i = await _codeToId(normalized.keys.toSet());
  await db.transaction((txn) async {
    await txn.delete(
      'food_nutrient_values',
      where: 'food_id = ? AND basis = ?',
      whereArgs: [foodId, 'per_100g'],
    );

    for (final e in normalized.entries) {      // ← use normalized
      final nid = c2i[e.key];
      if (nid == null) continue;
      await txn.insert('food_nutrient_values', {
        'food_id': foodId,
        'nutrient_id': nid,
        'amount': e.value,
        'basis': 'per_100g',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  });
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
  map.putIfAbsent('calories', () => 'ENERGY_KCAL'); // ← canonical
  map.putIfAbsent('protein',  () => 'PROTEIN');
  map.putIfAbsent('carbs',    () => 'CARB');
  map.putIfAbsent('fats',     () => 'FAT');


  return map;
}

/// Convert a “label → value” map (coming from FoodCustomizationPage payload)
/// into “code → amount” using aliases/names/codes.
Future<Map<String, double>> mapLabelsToCodes(Database db, Map<String, dynamic> labelToValue) async {
  final aliasMap = await _buildAliasToCodeMap(db);

  double nums(dynamic x) => (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0.0;

  final out = <String, double>{};
  for (final e in labelToValue.entries) {
    final rawKey = e.key;

    // The payload may contain full paths "Micronutrients > Vitamins > Vitamin C (mg)".
    // We only care about the leaf label.
    final leaf = rawKey.split('>').last.trim();      // "Vitamin C (mg)"
    final norm = _normalizeLabel(leaf);              // "vitamin c"

    final code = aliasMap[norm];
    if (code == null) continue;                      // unknown → skip

    final val = nums(e.value);
    // keep non-NaN
    if (val.isFinite) out[code] = val;
  }
  return out;
}

/// Save a payload from FoodCustomizationPage into per_100g values.
/// This will wipe old per_100g values and replace them with the new set.
Future<void> savePer100gFromLabelPayload(int foodId, Map<String, dynamic> payload) async {
  // Step 1: pull top-level fields (the simple ones you already show at the top)
    final base = <String, double>{};
  double nums(dynamic x) => (x is num) ? x.toDouble() : double.tryParse('$x') ?? 0.0;

  if (payload.containsKey('calories'))  base['ENERGY_KCAL'] = nums(payload['calories']); // ← single canonical
  if (payload.containsKey('protein_g')) base['PROTEIN']     = nums(payload['protein_g']);
  if (payload.containsKey('carbs_g'))   base['CARB']        = nums(payload['carbs_g']);
  if (payload.containsKey('fats_g'))    base['FAT']         = nums(payload['fats_g']);


  // Step 2: convert the rest of the form fields via alias mapping
  // Strip out known meta keys so we only feed nutrient-ish keys into the mapper.
  final copy = Map<String, dynamic>.from(payload)
    ..remove('name') ..remove('brand')
    ..remove('calories') ..remove('protein_g')
    ..remove('carbs_g') ..remove('fats_g');

  final mapped = await mapLabelsToCodes(db, copy);

  // Canonicalize all codes in one place
  final mappedNorm = {
    for (final e in mapped.entries) _canonCode(e.key): e.value,
  };
  final baseNorm = {
    for (final e in base.entries) _canonCode(e.key): e.value,
  };

  // Merge (explicit base wins if there’s conflict)
  final codeToAmount = <String,double>{}
    ..addAll(mappedNorm)   // mapped first
    ..addAll(baseNorm);    // base wins on conflict

  // Persist using your v22 table
  await replacePer100gByCode(foodId, codeToAmount);
}


/// Returns (code, unit) for a display alias (e.g., "Lysine (g)").
Future<Map<String, String>?> resolveAlias(String alias) async {
  final rows = await db.rawQuery('''
    SELECT n.code AS code, n.unit AS unit
    FROM nutrient_aliases a
    JOIN nutrients n ON n.id = a.nutrient_id
    WHERE a.alias = ?
    LIMIT 1
  ''', [alias.trim()]);
  if (rows.isEmpty) return null;
  final r = rows.first;
  return {'code': r['code'] as String, 'unit': r['unit'] as String};
}

/// Upsert per-100g values using alias labels as keys.
Future<void> savePer100gByAlias(int foodId, Map<String, double> aliasToAmount) async {
  // Build alias -> (code, unit) map on the fly
  await db.transaction((txn) async {
    for (final entry in aliasToAmount.entries) {
      final alias = entry.key.trim();
      final amount = entry.value;

      final rows = await txn.rawQuery('''
        SELECT n.id AS nid, n.code AS code, n.unit AS unit
        FROM nutrient_aliases a
        JOIN nutrients n ON n.id = a.nutrient_id
        WHERE a.alias = ?
        LIMIT 1
      ''', [alias]);

      if (rows.isEmpty) continue; // unknown alias -> skip silently
      final nid = rows.first['nid'] as int;

      // Write into the *new* flexible table as per_100g
      await txn.insert(
        'food_nutrient_values',
        {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount': amount,
          'basis': 'per_100g',
          'portion_id': null,
          'unit_override': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Keep legacy mirror in sync (handy until you fully move off it)
      await txn.insert(
        'food_nutrients',
        {
          'food_id': foodId,
          'nutrient_id': nid,
          'amount_per_100g': amount,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  });
}


Future<int> addPortion(
  int foodId, {
  required String measureName,
  double? gramWeight,
  double? mlVolume,
  bool isDefault = false,

  // v23 fields:
  String? listKind,
  int?    sortOrder,
  double? amount,
  String? unit,
  String? label,
}) async {
  return await db.transaction((txn) async {
    if (isDefault) {
      // ensure only one default per food
      await txn.update(
        'food_portions',
        {'is_default': 0},
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
    }
    return await txn.insert('food_portions', {
      'food_id': foodId,
      'measure_name': measureName,
      'gram_weight': gramWeight,
      'ml_volume': mlVolume,
      'is_default': isDefault ? 1 : 0,
      'list_kind'   : listKind,
      'sort_order'  : sortOrder,
      'amount'      : amount,
      'unit'        : unit,
      'label'       : label,
    });
  });
}


Future<void> replacePortions(int foodId, List<FoodPortion> portions) async {
  await db.transaction((txn) async {
    // wipe existing
    await txn.delete('food_portions', where: 'food_id = ?', whereArgs: [foodId]);

    // ensure at least one default
    final hasDefault = portions.any((p) => p.isDefault);
    var i = 0;

    for (final p in portions) {
      final isDef = hasDefault ? p.isDefault : (i == 0);

      // Compose a good display name if none provided
      final measureName = (p.measureName.trim().isNotEmpty)
          ? p.measureName.trim()
          : _composeMeasureName(p);

      await txn.insert('food_portions', {
        'food_id'     : foodId,
        'measure_name': measureName,
        'gram_weight' : p.gramWeight,
        'ml_volume'   : p.mlVolume,
        'is_default'  : isDef ? 1 : 0,

        // v23 extras (OK if NULL when you don’t care)
        'list_kind'   : p.listKind,                 // 'basis' | 'usual' | null
        'sort_order'  : p.sortOrder ?? i,
        'amount'      : p.amount,
        'unit'        : p.unit,
        'label'       : p.label,
      });

      i++;
    }
  });
}

// Helpers (keep private in the DAO file)
String _composeMeasureName(FoodPortion p) {
  if ((p.label ?? '').trim().isNotEmpty) return p.label!.trim();

  final parts = <String>[];
  if (p.amount != null && (p.unit?.trim().isNotEmpty ?? false)) {
    parts.add('${_trimNum(p.amount!)} ${p.unit!.trim()}');
  }
  if (p.gramWeight != null) parts.add('• ${_trimNum(p.gramWeight!)} g');
  if (p.mlVolume   != null) parts.add('• ${_trimNum(p.mlVolume!)} ml');

  return parts.isEmpty ? 'Portion' : parts.join(' ');
}

String _trimNum(num v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

Future<void> updateFoodBasics(int id, {String? name, String? brand}) async {
  final map = <String, Object?>{
    if (name != null) 'name': name.trim(),
    // store empty brand as NULL
    'brand': (brand?.trim().isEmpty ?? true) ? null : brand!.trim(),
    'updated_at': DateTime.now().toIso8601String(),
  };
  await db.update('foods', map, where: 'id = ?', whereArgs: [id]);
}


  
}
