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
    final rows = await db.query('food_portions',
      where: 'food_id = ?',
      whereArgs: [foodId],
      orderBy: 'is_default DESC, id ASC',
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
    final rows = await db.query('food_nutrients', where: 'food_id = ?', whereArgs: [foodId]);
    final map = <int, double>{};
    for (final r in rows) {
      map[r['nutrient_id'] as int] = (r['amount_per_100g'] as num).toDouble();
    }
    return map;
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

    // try ml → g using density
    if (p.mlVolume != null) {
      final food = await getFood(foodId);
      if (food?.densityGPerMl != null) {
        return p.mlVolume! * quantity * food!.densityGPerMl!;
      }
    }
    return null;
  }

  Future<double?> _resolveIngredientGrams(RecipeIngredient ing) async {
    if ( ing.grams != null ) return ing.grams;
    if ( ing.portionId != null && ing.quantity != null ) {
      final rows = await db.query('food_portions', where: 'id = ?', whereArgs: [ing.portionId], limit: 1);
      if (rows.isNotEmpty) {
        final p = FoodPortion.fromMap(rows.first);
        if (p.gramWeight != null) return p.gramWeight! * ing.quantity!;
        if (p.mlVolume != null) {
          final food = await getFood(ing.foodId);
          if (food?.densityGPerMl != null) return p.mlVolume! * ing.quantity! * food!.densityGPerMl!;
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
}
