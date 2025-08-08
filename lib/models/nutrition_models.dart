// File: lib/models/nutrition_models.dart

// Nutrition domain models:
// - Nutrient master
// - Foods + portions + per-100g nutrients
// - Recipes + ingredients
// - Diary entries (per profile, per local day)
// - Goals and per-day rollups (DayTotals)
//
// Notes:
// • Booleans are stored as 0/1 in SQLite.
// • Dates: diary/goals use local-day 'YYYY-MM-DD' TEXT in DB; here we expose DateTime.
//• Units: amounts are raw (no rounding); format in UI.

/// The four standard meal buckets.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  int toInt() => index;
  static MealType fromInt(int v) => MealType.values[v.clamp(0, MealType.values.length - 1)];
}

/// Master list of nutrients (e.g., Energy, Protein, Fat, Carbs).
class Nutrient {
  final int id;          // e.g., 1008 Energy (kcal), 1003 Protein (g), etc.
  final String? code;    // optional external code
  final String name;
  final String unit;     // "kcal","g","mg","µg"

  Nutrient({
    required this.id,
    required this.name,
    required this.unit,
    this.code,
  });

  factory Nutrient.fromMap(Map<String, dynamic> m) => Nutrient(
        id:   m['id'] as int,
        code: m['code'] as String?,
        name: m['name'] as String,
        unit: m['unit'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id':   id,
        'code': code,
        'name': name,
        'unit': unit,
      };
}

/// A food item (generic, branded, or user-created).
class Food {
  final int? id;
  final String name;
  final String? brand;
  final bool isCustom;
  final String? dataSource;    // 'seed','fdc','user', etc.
  final String? dataSourceId;  // external id if imported
  final String? barcode;       // UPC/EAN
  final double? densityGPerMl; // for volume → grams conversions
  final bool isDeleted;        // soft-delete
  final DateTime createdAt;
  final DateTime updatedAt;

  Food({
    this.id,
    required this.name,
    this.brand,
    required this.isCustom,
    this.dataSource,
    this.dataSourceId,
    this.barcode,
    this.densityGPerMl,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id:            m['id'] as int?,
        name:          m['name'] as String,
        brand:         m['brand'] as String?,
        isCustom:     (m['is_custom'] as int) == 1,
        dataSource:    m['data_source'] as String?,
        dataSourceId:  m['data_source_id'] as String?,
        barcode:       m['barcode'] as String?,
        densityGPerMl:(m['density_g_per_ml'] as num?)?.toDouble(),
        isDeleted:    (m['is_deleted'] as int? ?? 0) == 1,
        createdAt:     DateTime.parse(m['created_at'] as String),
        updatedAt:     DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name':             name,
        'brand':            brand,
        'is_custom':        isCustom ? 1 : 0,
        'data_source':      dataSource,
        'data_source_id':   dataSourceId,
        'barcode':          barcode,
        'density_g_per_ml': densityGPerMl,
        'is_deleted':       isDeleted ? 1 : 0,
        'created_at':       createdAt.toIso8601String(),
        'updated_at':       updatedAt.toIso8601String(),
      };
}

/// Portion definition for a food (e.g., "cup", "tbsp", "1 bar").
class FoodPortion {
  final int? id;
  final int foodId;
  final String measureName;
  final double? gramWeight; // direct converter
  final double? mlVolume;   // optional, use density if only volume given
  final bool isDefault;

  FoodPortion({
    this.id,
    required this.foodId,
    required this.measureName,
    this.gramWeight,
    this.mlVolume,
    this.isDefault = false,
  });

  factory FoodPortion.fromMap(Map<String, dynamic> m) => FoodPortion(
        id:          m['id'] as int?,
        foodId:      m['food_id'] as int,
        measureName: m['measure_name'] as String,
        gramWeight: (m['gram_weight'] as num?)?.toDouble(),
        mlVolume:   (m['ml_volume'] as num?)?.toDouble(),
        isDefault:  (m['is_default'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'food_id':      foodId,
        'measure_name': measureName,
        'gram_weight':  gramWeight,
        'ml_volume':    mlVolume,
        'is_default':   isDefault ? 1 : 0,
      };
}

/// Per-100g nutrient amount for a food.
class FoodNutrient {
  final int? id;
  final int foodId;
  final int nutrientId;
  final double amountPer100g;

  FoodNutrient({
    this.id,
    required this.foodId,
    required this.nutrientId,
    required this.amountPer100g,
  });

  factory FoodNutrient.fromMap(Map<String, dynamic> m) => FoodNutrient(
        id:            m['id'] as int?,
        foodId:        m['food_id'] as int,
        nutrientId:    m['nutrient_id'] as int,
        amountPer100g:(m['amount_per_100g'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'food_id':         foodId,
        'nutrient_id':     nutrientId,
        'amount_per_100g': amountPer100g,
      };
}

/// A user-visible recipe (collection of foods).
class Recipe {
  final int? id;
  final String name;
  final String? notes;
  final bool isCustom;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.name,
    this.notes,
    this.isCustom = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe(
        id:        m['id'] as int?,
        name:      m['name'] as String,
        notes:     m['notes'] as String?,
        isCustom: (m['is_custom'] as int? ?? 1) == 1,
        isDeleted:(m['is_deleted'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name':       name,
        'notes':      notes,
        'is_custom':  isCustom ? 1 : 0,
        'is_deleted': isDeleted ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// A single ingredient line in a recipe.
/// Either (portionId + quantity) or direct grams can be used.
/// Ideally 'grams' is resolved and stored at insert for stability.
class RecipeIngredient {
  final int? id;
  final int recipeId;
  final int foodId;
  final int? portionId;
  final double? quantity; // count of portions
  final double? grams;    // resolved mass (preferred persisted)

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.foodId,
    this.portionId,
    this.quantity,
    this.grams,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> m) => RecipeIngredient(
        id:        m['id'] as int?,
        recipeId:  m['recipe_id'] as int,
        foodId:    m['food_id'] as int,
        portionId: m['portion_id'] as int?,
        quantity: (m['quantity'] as num?)?.toDouble(),
        grams:    (m['grams'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'recipe_id':  recipeId,
        'food_id':    foodId,
        'portion_id': portionId,
        'quantity':   quantity,
        'grams':      grams,
      };
}

/// A diary entry for a given profile and local day.
/// Exactly one of [foodId] or [recipeId] must be set.
class DiaryEntry {
  final int? id;
  final int profileId;
  final DateTime date;  // local day
  final MealType mealType;
  final int? foodId;
  final int? recipeId;
  final int? portionId;
  final double quantity;   // portions (or multiplier for grams)
  final double? grams;     // resolved mass at insert time
  final String? notes;

  DiaryEntry({
    this.id,
    required this.profileId,
    required this.date,
    required this.mealType,
    this.foodId,
    this.recipeId,
    this.portionId,
    this.quantity = 1.0,
    this.grams,
    this.notes,
  });

  factory DiaryEntry.fromMap(Map<String, dynamic> m) => DiaryEntry(
        id:         m['id'] as int?,
        profileId:  m['profile_id'] as int,
        date:       _parseYMD(m['date'] as String),
        mealType:   MealTypeX.fromInt(m['meal_type'] as int),
        foodId:     m['food_id'] as int?,
        recipeId:   m['recipe_id'] as int?,
        portionId:  m['portion_id'] as int?,
        quantity:  (m['quantity'] as num?)?.toDouble() ?? 1.0,
        grams:     (m['grams'] as num?)?.toDouble(),
        notes:      m['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'date':       _toYMD(date),
        'meal_type':  mealType.toInt(),
        'food_id':    foodId,
        'recipe_id':  recipeId,
        'portion_id': portionId,
        'quantity':   quantity,
        'grams':      grams,
        'notes':      notes,
      };
}

/// Nutrition goals for a profile over a time window (open-ended if endDate null).
class NutritionGoal {
  final int? id;
  final int profileId;
  final DateTime startDate; // local day
  final DateTime? endDate;  // local day or null
  final double? kcalTarget;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
  final double? fiberG;
  final double? sugarG;
  final double? satFatG;
  final double? sodiumMg;

  NutritionGoal({
    this.id,
    required this.profileId,
    required this.startDate,
    this.endDate,
    this.kcalTarget,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.fiberG,
    this.sugarG,
    this.satFatG,
    this.sodiumMg,
  });

  factory NutritionGoal.fromMap(Map<String, dynamic> m) => NutritionGoal(
        id:         m['id'] as int?,
        profileId:  m['profile_id'] as int,
        startDate:  _parseYMD(m['start_date'] as String),
        endDate:   (m['end_date'] as String?) != null
                    ? _parseYMD(m['end_date'] as String)
                    : null,
        kcalTarget:(m['kcal_target'] as num?)?.toDouble(),
        proteinG:  (m['protein_g'] as num?)?.toDouble(),
        fatG:      (m['fat_g'] as num?)?.toDouble(),
        carbsG:    (m['carbs_g'] as num?)?.toDouble(),
        fiberG:    (m['fiber_g'] as num?)?.toDouble(),
        sugarG:    (m['sugar_g'] as num?)?.toDouble(),
        satFatG:   (m['sat_fat_g'] as num?)?.toDouble(),
        sodiumMg:  (m['sodium_mg'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id':  profileId,
        'start_date':  _toYMD(startDate),
        'end_date':    endDate != null ? _toYMD(endDate!) : null,
        'kcal_target': kcalTarget,
        'protein_g':   proteinG,
        'fat_g':       fatG,
        'carbs_g':     carbsG,
        'fiber_g':     fiberG,
        'sugar_g':     sugarG,
        'sat_fat_g':   satFatG,
        'sodium_mg':   sodiumMg,
      };
}

/// Cached daily totals per profile/date (fast dashboard reads).
class DayTotals {
  final int profileId;
  final DateTime date;  // local day
  final double kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double fiberG;
  final double sugarG;
  final double satFatG;
  final double sodiumMg;

  DayTotals({
    required this.profileId,
    required this.date,
    this.kcal = 0,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
    this.satFatG = 0,
    this.sodiumMg = 0,
  });

  factory DayTotals.fromMap(Map<String, dynamic> m) => DayTotals(
        profileId: m['profile_id'] as int,
        date:      _parseYMD(m['date'] as String),
        kcal:     (m['kcal'] as num?)?.toDouble() ?? 0,
        proteinG: (m['protein_g'] as num?)?.toDouble() ?? 0,
        fatG:     (m['fat_g'] as num?)?.toDouble() ?? 0,
        carbsG:   (m['carbs_g'] as num?)?.toDouble() ?? 0,
        fiberG:   (m['fiber_g'] as num?)?.toDouble() ?? 0,
        sugarG:   (m['sugar_g'] as num?)?.toDouble() ?? 0,
        satFatG:  (m['sat_fat_g'] as num?)?.toDouble() ?? 0,
        sodiumMg: (m['sodium_mg'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'profile_id': profileId,
        'date':       _toYMD(date),
        'kcal':       kcal,
        'protein_g':  proteinG,
        'fat_g':      fatG,
        'carbs_g':    carbsG,
        'fiber_g':    fiberG,
        'sugar_g':    sugarG,
        'sat_fat_g':  satFatG,
        'sodium_mg':  sodiumMg,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Parse 'YYYY-MM-DD' (local-day) into DateTime at local midnight.
DateTime _parseYMD(String s) {
  // Simple fast parse; assumes valid input "YYYY-MM-DD"
  final year  = int.parse(s.substring(0, 4));
  final month = int.parse(s.substring(5, 7));
  final day   = int.parse(s.substring(8, 10));
  return DateTime(year, month, day);
}

/// Convert DateTime to local-day 'YYYY-MM-DD'.
String _toYMD(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final da = d.day.toString().padLeft(2, '0');
  return '$y-$m-$da';
}
