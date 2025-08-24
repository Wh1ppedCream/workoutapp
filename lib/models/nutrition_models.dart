// File: lib/models/nutrition_models.dart

// Nutrition domain models:
// - Nutrient master
// - Foods + portions + per-100g nutrients
// - Brands, Categories, Barcodes  ← NEW
// - Recipes + ingredients
// - Diary entries (per profile, per local day) + snapshots  ← EXPANDED
// - Goals and per-day rollups (DayTotals)
//
// Notes:
// • Booleans are stored as 0/1 in SQLite.
// • Dates: diary/goals use local-day 'YYYY-MM-DD' TEXT in DB; here we expose DateTime.
// • Timestamps:
//    - DiaryEntry.logged_at / updated_at are stored as INTEGER epoch ms (UTC) in DB.
//    - Food/Recipe created_at / updated_at are stored as ISO 8601 TEXT in DB.
// • Units: amounts are raw (no rounding); format in UI.

import 'dart:convert' show jsonDecode, jsonEncode;

/// The four standard meal buckets.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  int toInt() => index;
  static MealType fromInt(int v) {
    final i = v.clamp(0, MealType.values.length - 1).toInt();
    return MealType.values[i];
  }
}

/// Canonical nutrient codes used across DAO/Repo/UI.
/// Centralizing them avoids stringly-typed bugs.
class NutrientCodes {
  static const String KCAL = 'KCAL';
  static const String PROTEIN_G = 'PROTEIN_G';
  static const String CARB_G = 'CARB_G';
  static const String FAT_G = 'FAT_G';
  // Common micros for day rollups:
  static const String FIBER_G = 'FIBER_G';
  static const String SUGAR_G = 'SUGAR_G';
  static const String SODIUM_MG = 'SODIUM_MG';
  static const String POTASSIUM_MG = 'POTASSIUM_MG';
  static const String SAT_FAT_G = 'SAT_FAT_G';
}

/// Suggested default set for a "Micros" day card (tweak in UI if needed).
const Set<String> kDefaultMicrosForDay = {
  NutrientCodes.SODIUM_MG,
  NutrientCodes.FIBER_G,
  NutrientCodes.SUGAR_G,
};

/// Master list of nutrients (e.g., Energy, Protein, Fat, Carbs).
class Nutrient {
  final int id; // e.g., 1008 Energy (kcal), 1003 Protein (g), etc.
  final String? code; // optional external/code string (e.g., 'KCAL','PROTEIN_G')
  final String name;
  final String unit; // "kcal","g","mg","µg"

  Nutrient({
    required this.id,
    required this.name,
    required this.unit,
    this.code,
  });

  factory Nutrient.fromMap(Map<String, dynamic> m) => Nutrient(
        id: m['id'] as int,
        code: m['code'] as String?,
        name: m['name'] as String,
        unit: m['unit'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'unit': unit,
      };
}

/// ────────────────────────────────────────────────────────────────────────────
/// NEW: Normalized brand & category & barcode models
/// ────────────────────────────────────────────────────────────────────────────

class Brand {
  final int? id;
  final String name;
  final String? manufacturer;

  Brand({this.id, required this.name, this.manufacturer});

  factory Brand.fromMap(Map<String, dynamic> m) => Brand(
        id: m['id'] as int?,
        name: m['name'] as String,
        manufacturer: m['manufacturer'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'manufacturer': manufacturer,
      };
}

class Category {
  final int? id;
  final String name;
  final int? parentId;

  Category({this.id, required this.name, this.parentId});

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as int?,
        name: m['name'] as String,
        parentId: m['parent_id'] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'parent_id': parentId,
      };
}

/// Separate table so a food can have many UPC/EANs / packaging variants.
class FoodBarcode {
  final int? id;
  final int foodId;
  final String upc; // UPC/EAN

  FoodBarcode({this.id, required this.foodId, required this.upc});

  factory FoodBarcode.fromMap(Map<String, dynamic> m) => FoodBarcode(
        id: m['id'] as int?,
        foodId: m['food_id'] as int,
        upc: m['upc'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'food_id': foodId,
        'upc': upc,
      };
}

/// A food item (generic, branded, or user-created).
class Food {
  final int? id;
  final String name;

  // Legacy/compat
  final String? brand; // DEPRECATED when brandId present (kept for backwards compatibility)
  final String? barcode; // DEPRECATED: use FoodBarcode rows

  // Normalization / provenance (NEW)
  final int? brandId; // → Brand.id
  final int? categoryId; // → Category.id
  final String? dataSource; // e.g., 'seed','fdc','user','openfoodfacts'
  final String? dataSourceId; // external id if imported
  final int? fdcId; // USDA FDC numeric id (if available)
  final bool verified; // trusted/approved source flag
  final double? qualityScore; // 0..1 or any scoring scheme
  final int version; // increment on import/edits

  // Preparation/state (NEW)
  final String? preparation; // 'raw','boiled','grilled','drained','skinless', etc.
  final double? ediblePortionPct; // e.g., 100.0 for boneless edible portion, otherwise <100
  final double? yieldPct; // cooking yield %, e.g., 70.0 for grilled chicken

  // Physical
  final double? densityGPerMl; // for volume → grams conversions

  // Soft-delete & timestamps
  final bool isCustom; // user-created
  final bool isDeleted; // soft-delete
  final DateTime createdAt;
  final DateTime updatedAt;

  Food({
    this.id,
    required this.name,
    this.brand, // legacy
    this.barcode, // legacy
    this.brandId, // NEW
    this.categoryId, // NEW
    required this.isCustom,
    this.dataSource,
    this.dataSourceId,
    this.fdcId, // NEW
    this.verified = false, // NEW
    this.qualityScore, // NEW
    this.version = 1, // NEW
    this.preparation, // NEW
    this.ediblePortionPct, // NEW
    this.yieldPct, // NEW
    this.densityGPerMl,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: m['id'] as int?,
        name: m['name'] as String,
        brand: m['brand'] as String?, // legacy
        barcode: m['barcode'] as String?, // legacy
        brandId: m['brand_id'] as int?, // NEW
        categoryId: m['category_id'] as int?, // NEW
        isCustom: (m['is_custom'] as int? ?? 0) == 1,
        dataSource: m['data_source'] as String?,
        dataSourceId: m['data_source_id'] as String?,
        fdcId: m['fdc_id'] as int?, // NEW
        verified: (m['verified'] as int? ?? 0) == 1, // NEW
        qualityScore: (m['quality_score'] as num?)?.toDouble(), // NEW
        version: (m['version'] as int? ?? 1), // NEW
        preparation: m['preparation'] as String?, // NEW
        ediblePortionPct: (m['edible_portion_pct'] as num?)?.toDouble(), // NEW
        yieldPct: (m['yield_pct'] as num?)?.toDouble(), // NEW
        densityGPerMl: (m['density_g_per_ml'] as num?)?.toDouble(),
        isDeleted: (m['is_deleted'] as int? ?? 0) == 1,
        createdAt: _parseIsoOrNow(m['created_at']),
        updatedAt: _parseIsoOrNow(m['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,

        // legacy/compat
        'brand': brand,
        'barcode': barcode,

        // normalization / provenance
        'brand_id': brandId,
        'category_id': categoryId,
        'is_custom': isCustom ? 1 : 0,
        'data_source': dataSource,
        'data_source_id': dataSourceId,
        'fdc_id': fdcId,
        'verified': verified ? 1 : 0,
        'quality_score': qualityScore,
        'version': version,

        // preparation/state
        'preparation': preparation,
        'edible_portion_pct': ediblePortionPct,
        'yield_pct': yieldPct,

        'density_g_per_ml': densityGPerMl,
        'is_deleted': isDeleted ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      }..removeWhere((_, v) => v == null);
}

/// Portion definition for a food (e.g., "cup", "tbsp", "1 bar").
class FoodPortion {
  final int? id;
  final int foodId;
  final String measureName;
  final double? gramWeight; // direct converter
  final double? mlVolume; // optional, use density if only volume given
  final bool isDefault;

  // v23
  final String? listKind; // 'basis' | 'usual' | null
  final int? sortOrder;
  final double? amount;
  final String? unit;
  final String? label;

  FoodPortion({
    this.id,
    required this.foodId,
    required this.measureName,
    this.gramWeight,
    this.mlVolume,
    this.isDefault = false,
    this.listKind,
    this.sortOrder,
    this.amount,
    this.unit,
    this.label,
  });

  factory FoodPortion.fromMap(Map<String, dynamic> m) => FoodPortion(
        id: m['id'] as int?,
        foodId: m['food_id'] as int,
        measureName: m['measure_name'] as String,
        gramWeight: (m['gram_weight'] as num?)?.toDouble(),
        mlVolume: (m['ml_volume'] as num?)?.toDouble(),
        isDefault: (m['is_default'] as int? ?? 0) == 1,
        listKind: m['list_kind'] as String?,
        sortOrder: m['sort_order'] as int?,
        amount: (m['amount'] as num?)?.toDouble(),
        unit: m['unit'] as String?,
        label: m['label'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'food_id': foodId,
        'measure_name': measureName,
        'gram_weight': gramWeight,
        'ml_volume': mlVolume,
        'is_default': isDefault ? 1 : 0,
        'list_kind': listKind,
        'sort_order': sortOrder,
        'amount': amount,
        'unit': unit,
        'label': label,
      }..removeWhere((_, v) => v == null);
}

/// Portion list kinds as a typed enum (DB still stores TEXT).
enum PortionListKind { basis, usual }

String? portionListKindToDb(PortionListKind? k) {
  if (k == null) return null;
  switch (k) {
    case PortionListKind.basis:
      return 'basis';
    case PortionListKind.usual:
      return 'usual';
  }
}

PortionListKind? portionListKindFromDb(String? s) {
  switch (s) {
    case 'basis':
      return PortionListKind.basis;
    case 'usual':
      return PortionListKind.usual;
    default:
      return null;
  }
}

extension FoodPortionX on FoodPortion {
  /// True if this portion specifies only volume and expects density conversion.
  bool get isVolumeOnly => gramWeight == null && mlVolume != null;

  /// True if this portion specifies only grams (direct mass).
  bool get isGramOnly => gramWeight != null && mlVolume == null;

  /// Typed accessor for list kind.
  PortionListKind? get listKindEnum => portionListKindFromDb(listKind);

  /// Convenience immutable update.
  FoodPortion copyWith({
    int? id,
    int? foodId,
    String? measureName,
    double? gramWeight,
    double? mlVolume,
    bool? isDefault,
    String? listKind,
    int? sortOrder,
    double? amount,
    String? unit,
    String? label,
  }) {
    return FoodPortion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      measureName: measureName ?? this.measureName,
      gramWeight: gramWeight ?? this.gramWeight,
      mlVolume: mlVolume ?? this.mlVolume,
      isDefault: isDefault ?? this.isDefault,
      listKind: listKind ?? this.listKind,
      sortOrder: sortOrder ?? this.sortOrder,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      label: label ?? this.label,
    );
  }
}

/// Per-100g nutrient amount for a food.
class FoodNutrient {
  final int? id;
  final int foodId;
  final int nutrientId; // → Nutrient.id (you can also map from code in repo)
  final double amountPer100g;

  FoodNutrient({
    this.id,
    required this.foodId,
    required this.nutrientId,
    required this.amountPer100g,
  });

  factory FoodNutrient.fromMap(Map<String, dynamic> m) => FoodNutrient(
        id: m['id'] as int?,
        foodId: m['food_id'] as int,
        nutrientId: m['nutrient_id'] as int,
        amountPer100g: (m['amount_per_100g'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'food_id': foodId,
        'nutrient_id': nutrientId,
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
        id: m['id'] as int?,
        name: m['name'] as String,
        notes: m['notes'] as String?,
        isCustom: (m['is_custom'] as int? ?? 1) == 1,
        isDeleted: (m['is_deleted'] as int? ?? 0) == 1,
        createdAt: _parseIsoOrNow(m['created_at']),
        updatedAt: _parseIsoOrNow(m['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'notes': notes,
        'is_custom': isCustom ? 1 : 0,
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
  final double? grams; // resolved mass (preferred persisted)

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.foodId,
    this.portionId,
    this.quantity,
    this.grams,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> m) => RecipeIngredient(
        id: m['id'] as int?,
        recipeId: m['recipe_id'] as int,
        foodId: m['food_id'] as int,
        portionId: m['portion_id'] as int?,
        quantity: (m['quantity'] as num?)?.toDouble(),
        grams: (m['grams'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'recipe_id': recipeId,
        'food_id': foodId,
        'portion_id': portionId,
        'quantity': quantity,
        'grams': grams,
      };
}

/// A diary entry for a given profile and local day.
/// Exactly one of [foodId] or [recipeId] must be set.
class DiaryEntry {
  final int? id;
  final int profileId;
  final DateTime date; // local day
  final MealType mealType;
  final int? foodId;
  final int? recipeId;
  final int? portionId;
  final double quantity; // portions (or multiplier for grams)

  // Resolved mass at insert time (compat) + NEW alias
  final double? grams; // legacy field kept for backward compatibility
  final double? loggedGrams; // NEW preferred field

  final String? notes;

  // nutrient snapshots (freeze values at log time)
  final double? kcalSnapshot;
  final double? proteinGSnapshot;
  final double? carbGSnapshot;
  final double? fatGSnapshot;

  /// Optional sparse map for extended nutrients.
  /// Expected JSON shape (canonical codes): {"KCAL":123.0,"PROTEIN_G":23.4,...}
  /// Consumers should tolerate missing keys.
  final String? nutrientSnapshotJson;

  // NEW: precise timestamps & soft delete
  final DateTime? loggedAt; // exact log time (UTC epoch ms in DB)
  final DateTime? updatedAt; // last modification time (UTC epoch ms in DB)
  final bool isDeleted; // soft delete flag

  DiaryEntry({
    this.id,
    required this.profileId,
    required this.date,
    required this.mealType,
    this.foodId,
    this.recipeId,
    this.portionId,
    this.quantity = 1.0,
    this.grams, // legacy
    this.loggedGrams, // NEW
    this.notes,
    this.kcalSnapshot, // NEW
    this.proteinGSnapshot, // NEW
    this.carbGSnapshot, // NEW
    this.fatGSnapshot, // NEW
    this.nutrientSnapshotJson, // NEW
    this.loggedAt, // NEW
    this.updatedAt, // NEW
    this.isDeleted = false, // NEW (default)
  })  : assert(quantity > 0, 'DiaryEntry.quantity must be > 0'),
        // Exactly one of [foodId] or [recipeId] must be set.
        assert(
          (foodId == null) != (recipeId == null), // boolean XOR
          'Exactly one of foodId or recipeId must be set',
        );

  factory DiaryEntry.fromMap(Map<String, dynamic> m) => DiaryEntry(
        id: m['id'] as int?,
        profileId: m['profile_id'] as int,
        date: _parseYMD(m['date'] as String),
        mealType: MealTypeX.fromInt(m['meal_type'] as int),
        foodId: m['food_id'] as int?,
        recipeId: m['recipe_id'] as int?,
        portionId: m['portion_id'] as int?,
        quantity: (m['quantity'] as num?)?.toDouble() ?? 1.0,
        grams: (m['grams'] as num?)?.toDouble(), // legacy
        // NEW: prefer 'logged_grams'; fallback to legacy 'grams_override' for back-compat
        loggedGrams: (m['logged_grams'] as num?)?.toDouble() ??
            (m['grams_override'] as num?)?.toDouble(), // TEMP back-compat
        notes: m['notes'] as String?,
        kcalSnapshot: (m['kcal_snapshot'] as num?)?.toDouble(), // NEW
        proteinGSnapshot:
            (m['protein_g_snapshot'] as num?)?.toDouble(), // NEW
        carbGSnapshot: (m['carb_g_snapshot'] as num?)?.toDouble(), // NEW
        fatGSnapshot: (m['fat_g_snapshot'] as num?)?.toDouble(), // NEW
        nutrientSnapshotJson: m['nutrient_snapshot_json'] as String?, // NEW
        loggedAt: _fromEpochMsOrNull(m['logged_at']), // NEW
        updatedAt: _fromEpochMsOrNull(m['updated_at']), // NEW
        isDeleted: ((m['is_deleted'] as int?) ?? 0) == 1, // NEW
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'date': _toYMD(date),
        'meal_type': mealType.toInt(),
        'food_id': foodId,
        'recipe_id': recipeId,
        'portion_id': portionId,
        'quantity': quantity,

        // keep both for back/forward compat
        'grams': grams,
        'logged_grams': loggedGrams,

        'notes': notes,

        // TEMP back-compat: write legacy column until migrations remove it.
        // Safe to delete once your schema has fully adopted 'logged_grams'.
        // TODO(drop-legacy-grams): remove 'grams_override' write after migration v23.1.x
        'grams_override': loggedGrams,

        // snapshots
        'kcal_snapshot': kcalSnapshot,
        'protein_g_snapshot': proteinGSnapshot,
        'carb_g_snapshot': carbGSnapshot,
        'fat_g_snapshot': fatGSnapshot,
        'nutrient_snapshot_json': nutrientSnapshotJson,
        // timestamps & soft delete
        'logged_at': _toEpochMsOrNull(loggedAt),
        'updated_at': _toEpochMsOrNull(updatedAt),
        'is_deleted': isDeleted ? 1 : 0,
      }..removeWhere((_, v) => v == null);

  /// Convenience: immutably modify a diary entry.
  DiaryEntry copyWith({
    int? id,
    int? profileId,
    DateTime? date,
    MealType? mealType,
    int? foodId,
    int? recipeId,
    int? portionId,
    double? quantity,
    double? grams,
    double? loggedGrams,
    String? notes,
    double? kcalSnapshot,
    double? proteinGSnapshot,
    double? carbGSnapshot,
    double? fatGSnapshot,
    String? nutrientSnapshotJson,
    DateTime? loggedAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodId: foodId ?? this.foodId,
      recipeId: recipeId ?? this.recipeId,
      portionId: portionId ?? this.portionId,
      quantity: quantity ?? this.quantity,
      grams: grams ?? this.grams,
      loggedGrams: loggedGrams ?? this.loggedGrams,
      notes: notes ?? this.notes,
      kcalSnapshot: kcalSnapshot ?? this.kcalSnapshot,
      proteinGSnapshot: proteinGSnapshot ?? this.proteinGSnapshot,
      carbGSnapshot: carbGSnapshot ?? this.carbGSnapshot,
      fatGSnapshot: fatGSnapshot ?? this.fatGSnapshot,
      nutrientSnapshotJson:
          nutrientSnapshotJson ?? this.nutrientSnapshotJson,
      loggedAt: loggedAt ?? this.loggedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// True if this entry references a single food; false if it references a recipe.
  bool get isFood => foodId != null;

  /// True if this entry references a recipe; false if it references a food.
  bool get isRecipe => recipeId != null;

  /// Safe, typed view of the JSON nutrient snapshot (canonical codes → amounts).
  Map<String, double> get nutrientSnapshot {
    final s = nutrientSnapshotJson;
    if (s == null || s.isEmpty) return const {};
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) return const {};
      final out = <String, double>{};
      decoded.forEach((k, v) {
        num? n;
        if (v is num) {
          n = v;
        } else if (v is String) {
          n = num.tryParse(v);
        }
        if (k is String && n != null) out[k] = n.toDouble();
      });
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// Returns a copy with the JSON snapshot set from a typed Map.
  DiaryEntry copyWithNutrientSnapshot(Map<String, double> m) =>
      copyWith(nutrientSnapshotJson: jsonEncode(m));

  /// Intent-specific constructor for food entries (recipeId is null).
  factory DiaryEntry.forFood({
    int? id,
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? grams,
    double? loggedGrams,
    String? notes,
    double? kcalSnapshot,
    double? proteinGSnapshot,
    double? carbGSnapshot,
    double? fatGSnapshot,
    String? nutrientSnapshotJson,
    DateTime? loggedAt,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    return DiaryEntry(
      id: id,
      profileId: profileId,
      date: date,
      mealType: mealType,
      foodId: foodId,
      recipeId: null,
      portionId: portionId,
      quantity: quantity,
      grams: grams,
      loggedGrams: loggedGrams,
      notes: notes,
      kcalSnapshot: kcalSnapshot,
      proteinGSnapshot: proteinGSnapshot,
      carbGSnapshot: carbGSnapshot,
      fatGSnapshot: fatGSnapshot,
      nutrientSnapshotJson: nutrientSnapshotJson,
      loggedAt: loggedAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Intent-specific constructor for recipe entries (foodId is null).
  factory DiaryEntry.forRecipe({
    int? id,
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    int? portionId,
    double quantity = 1.0,
    double? grams,
    double? loggedGrams,
    String? notes,
    double? kcalSnapshot,
    double? proteinGSnapshot,
    double? carbGSnapshot,
    double? fatGSnapshot,
    String? nutrientSnapshotJson,
    DateTime? loggedAt,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    return DiaryEntry(
      id: id,
      profileId: profileId,
      date: date,
      mealType: mealType,
      foodId: null,
      recipeId: recipeId,
      portionId: portionId,
      quantity: quantity,
      grams: grams,
      loggedGrams: loggedGrams,
      notes: notes,
      kcalSnapshot: kcalSnapshot,
      proteinGSnapshot: proteinGSnapshot,
      carbGSnapshot: carbGSnapshot,
      fatGSnapshot: fatGSnapshot,
      nutrientSnapshotJson: nutrientSnapshotJson,
      loggedAt: loggedAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }
}

/// Nutrition goals for a profile over a time window (open-ended if endDate null).
class NutritionGoal {
  final int? id;
  final int profileId;
  final DateTime startDate; // local day
  final DateTime? endDate; // local day or null
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
        id: m['id'] as int?,
        profileId: m['profile_id'] as int,
        startDate: _parseYMD(m['start_date'] as String),
        endDate: (m['end_date'] as String?) != null
            ? _parseYMD(m['end_date'] as String)
            : null,
        kcalTarget: (m['kcal_target'] as num?)?.toDouble(),
        proteinG: (m['protein_g'] as num?)?.toDouble(),
        fatG: (m['fat_g'] as num?)?.toDouble(),
        carbsG: (m['carbs_g'] as num?)?.toDouble(),
        fiberG: (m['fiber_g'] as num?)?.toDouble(),
        sugarG: (m['sugar_g'] as num?)?.toDouble(),
        satFatG: (m['sat_fat_g'] as num?)?.toDouble(),
        sodiumMg: (m['sodium_mg'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'start_date': _toYMD(startDate),
        'end_date': endDate != null ? _toYMD(endDate!) : null,
        'kcal_target': kcalTarget,
        'protein_g': proteinG,
        'fat_g': fatG,
        'carbs_g': carbsG,
        'fiber_g': fiberG,
        'sugar_g': sugarG,
        'sat_fat_g': satFatG,
        'sodium_mg': sodiumMg,
      }..removeWhere((_, v) => v == null);
}

/// Cached daily totals per profile/date (fast dashboard reads).
class DayTotals {
  final int profileId;
  final DateTime date; // local day
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
        date: _parseYMD(m['date'] as String),
        kcal: (m['kcal'] as num?)?.toDouble() ?? 0,
        proteinG: (m['protein_g'] as num?)?.toDouble() ?? 0,
        fatG: (m['fat_g'] as num?)?.toDouble() ?? 0,
        carbsG: (m['carbs_g'] as num?)?.toDouble() ?? 0,
        fiberG: (m['fiber_g'] as num?)?.toDouble() ?? 0,
        sugarG: (m['sugar_g'] as num?)?.toDouble() ?? 0,
        satFatG: (m['sat_fat_g'] as num?)?.toDouble() ?? 0,
        sodiumMg: (m['sodium_mg'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'profile_id': profileId,
        'date': _toYMD(date),
        'kcal': kcal,
        'protein_g': proteinG,
        'fat_g': fatG,
        'carbs_g': carbsG,
        'fiber_g': fiberG,
        'sugar_g': sugarG,
        'sat_fat_g': satFatG,
        'sodium_mg': sodiumMg,
      };
}

/// Optional tag attached to a diary entry (e.g., 'eating_out', 'pre_workout').
class DiaryEntryTag {
  final int? id;
  final int entryId;
  final String tag;
  final DateTime? createdAt;

  DiaryEntryTag({
    this.id,
    required this.entryId,
    required this.tag,
    this.createdAt,
  });

  factory DiaryEntryTag.fromMap(Map<String, dynamic> m) => DiaryEntryTag(
        id: m['id'] as int?,
        entryId: m['entry_id'] as int,
        tag: m['tag'] as String,
        createdAt: _fromEpochMsOrNull(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'entry_id': entryId,
        'tag': tag,
        'created_at': _toEpochMsOrNull(createdAt),
      }..removeWhere((_, v) => v == null);
}

String normalizeDiaryTag(String input) {
  var t = input.trim().toLowerCase();
  t = t.replaceAll(RegExp(r'[ \t\-]+'), '_');
  t = t.replaceAll(RegExp(r'[^a-z0-9_]'), '');
  if (t.length > 40) t = t.substring(0, 40);
  return t;
}

/// Cached per-100g nutrient for a recipe by canonical code (e.g., 'KCAL','PROTEIN_G').
class RecipeNutrient {
  final int? id;
  final int recipeId;
  final String code;
  final double per100g;

  RecipeNutrient({
    this.id,
    required this.recipeId,
    required this.code,
    required this.per100g,
  });

  factory RecipeNutrient.fromMap(Map<String, dynamic> m) => RecipeNutrient(
        id: m['id'] as int?,
        recipeId: m['recipe_id'] as int,
        code: m['code'] as String,
        per100g: (m['per_100g'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'recipe_id': recipeId,
        'code': code,
        'per_100g': per100g,
      };
}

/// A user's pinned food (per profile).
class FavoriteFood {
  final int? id;
  final int profileId;
  final int foodId;
  final DateTime? createdAt;

  FavoriteFood({
    this.id,
    required this.profileId,
    required this.foodId,
    this.createdAt,
  });

  factory FavoriteFood.fromMap(Map<String, dynamic> m) => FavoriteFood(
        id: m['id'] as int?,
        profileId: m['profile_id'] as int,
        foodId: m['food_id'] as int,
        createdAt: _fromEpochMsOrNull(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'food_id': foodId,
        'created_at': _toEpochMsOrNull(createdAt),
      }..removeWhere((_, v) => v == null);
}

/// OPTIONAL: snapshot audit for diary entry changes.
class DiaryEntryAudit {
  final int? id;
  final int entryId;
  final String action; // 'create' | 'update' | 'delete' | 'restore'
  final DateTime at; // UTC epoch ms in DB
  final String? beforeJson; // serialized prior state
  final String? afterJson; // serialized new state

  DiaryEntryAudit({
    this.id,
    required this.entryId,
    required this.action,
    required this.at,
    this.beforeJson,
    this.afterJson,
  });

  factory DiaryEntryAudit.fromMap(Map<String, dynamic> m) => DiaryEntryAudit(
        id: m['id'] as int?,
        entryId: m['entry_id'] as int,
        action: m['action'] as String,
        at: _fromEpochMsOrNull(m['at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        beforeJson: m['before_json'] as String?,
        afterJson: m['after_json'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'entry_id': entryId,
        'action': action,
        'at': _toEpochMsOrNull(at),
        'before_json': beforeJson,
        'after_json': afterJson,
      }..removeWhere((_, v) => v == null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Parse 'YYYY-MM-DD' (local-day) into DateTime at local midnight.
DateTime _parseYMD(String s) {
  // Simple fast parse; assumes valid input "YYYY-MM-DD"
  final year = int.parse(s.substring(0, 4));
  final month = int.parse(s.substring(5, 7));
  final day = int.parse(s.substring(8, 10));
  return DateTime(year, month, day);
}

/// Convert DateTime to local-day 'YYYY-MM-DD'.
String _toYMD(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final da = d.day.toString().padLeft(2, '0');
  return '$y-$m-$da';
}

/// Convert epoch ms (int) to DateTime UTC, or null if missing.
DateTime? _fromEpochMsOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
  if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: true);
  if (v is String) {
    final parsed = int.tryParse(v);
    if (parsed != null) {
      return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true);
    }
  }
  return null;
}

DateTime _parseIsoOrNow(dynamic v) {
  if (v is String) {
    final dt = DateTime.tryParse(v);
    if (dt != null) return dt;
  }
  return DateTime.now();
}

/// Convert DateTime? to epoch ms (int), or null.
int? _toEpochMsOrNull(DateTime? dt) => dt?.toUtc().millisecondsSinceEpoch;
