part of '../app_repository.dart';

/// Instance APIs for the nutrition domain.
mixin _NutritionRepositoryMethods on _RepositoryDependencies {
  Future<DayTotals> getDayTotals(int profileId, DateTime date) =>
      _dbHelper.getDayTotals(profileId, date);

  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) =>
      _dbHelper.getActiveGoals(profileId, date);

  Future<List<DiaryEntry>> getDiaryEntriesForDate(
    int profileId,
    DateTime date,
  ) => _dbHelper.getDiaryEntriesForDate(profileId, date);

  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime day,
  ) async => _dbHelper.getDiaryEntriesWithItemsForDate(profileId, day);

  Future<int> addDiaryFood({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int foodId,
    int? portionId,
    double quantity = 1.0,
    double? gramsOverride,
    double? loggedGrams,
    DateTime? loggedAt,
    String? notes,
  }) => _dbHelper.addDiaryFood(
    profileId: profileId,
    date: date,
    mealType: mealType,
    foodId: foodId,
    portionId: portionId,
    quantity: quantity,
    gramsOverride: gramsOverride,
    loggedGrams: loggedGrams,
    loggedAt: loggedAt,
    notes: notes,
  );

  Future<int> addDiaryRecipe({
    required int profileId,
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    double quantity = 1.0,
    DateTime? loggedAt,
    String? notes,
  }) => _dbHelper.addDiaryRecipe(
    profileId: profileId,
    date: date,
    mealType: mealType,
    recipeId: recipeId,
    quantity: quantity,
    loggedAt: loggedAt,
    notes: notes,
  );

  Future<void> updateDiaryEntry(DiaryEntry e) => _dbHelper.updateDiaryEntry(e);

  Future<void> deleteDiaryEntry(
    int id, {
    required int profileId,
    required DateTime date,
  }) => _dbHelper.deleteDiaryEntry(id, profileId: profileId, date: date);

  Future<int> upsertFood(Food f) => _dbHelper.upsertFood(f);

  Future<Food?> getFood(int id) => foodCatalog.getFood(id);

  Future<List<Food>> searchFoods(String query, {int limit = 50}) =>
      foodCatalog.searchFoods(query, limit: limit);

  Future<int> upsertFoodPortion(FoodPortion p) =>
      _dbHelper.upsertFoodPortion(p);

  Future<List<FoodPortion>> getPortionsForFood(int foodId) =>
      foodCatalog.getPortionsForFood(foodId);

  Future<void> setDefaultPortion(int foodId, int portionId) =>
      _dbHelper.setDefaultPortion(foodId, portionId);

  Future<void> upsertFoodNutrients(int foodId, List<FoodNutrient> rows) =>
      _dbHelper.upsertFoodNutrients(foodId, rows);

  Future<Map<int, double>> getFoodNutrientsPer100g(int foodId) =>
      _dbHelper.getFoodNutrientsPer100g(foodId);

  Future<Map<String, double>> getFoodNutrientsPer100gByCode(int foodId) =>
      _dbHelper.getFoodNutrientsPer100gByCode(foodId);

  Future<int> createOrUpdateRecipe(Recipe r, List<RecipeIngredient> ings) =>
      _dbHelper.createOrUpdateRecipe(r, ings);

  Future<Recipe?> getRecipe(int id) => _dbHelper.getRecipe(id);

  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) =>
      _dbHelper.getRecipeIngredients(recipeId);

  Future<void> setGoals(NutritionGoal goal) => _dbHelper.setGoals(goal);

  Future<void> recalcDayTotals(int profileId, DateTime date) =>
      _dbHelper.recalcDayTotals(profileId, date);

  Future<int> createCustomFood({required String name, String? brand}) =>
      _dbHelper.createCustomFood(name: name, brand: brand);

  Future<void> savePer100gByCode(
    int foodId,
    Map<String, double> codeToAmount,
  ) => _dbHelper.savePer100gByCode(foodId, codeToAmount);

  Future<void> savePer100gFromLabelPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) => _dbHelper.savePer100gFromLabelPayload(foodId, payload);

  /// Returns a per-100g macro map using UI keys:
  ///   'PROTEIN_G', 'CARB_G', 'FAT_G', 'KCAL'
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) =>
      foodCatalog.getMacroPer100gLegacySafe(foodId);

  Future<void> saveExtendedPer100gFromPayload(
    int foodId,
    Map<String, dynamic> payload,
  ) => _dbHelper.saveExtendedPer100gFromPayload(foodId, payload);

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
  }) => _dbHelper.addPortion(
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

  Future<void> replacePortions(int foodId, List<FoodPortion> portions) =>
      _dbHelper.replacePortions(foodId, portions);

  Future<void> updateFoodBasics(int id, {String? name, String? brand}) =>
      _dbHelper.updateFoodBasics(id, name: name, brand: brand);

  Future<void> updateFoodFromCustomizationPayload(
    Map<String, dynamic> payload,
  ) => _dbHelper.updateFoodFromCustomizationPayload(payload);

  Future<int> createFoodFromCustomizationPayload(
    Map<String, dynamic> payload,
  ) => _dbHelper.createFoodFromCustomizationPayload(payload);

  Future<Food?> getFoodByBarcode(String code) =>
      foodCatalog.getFoodByBarcode(code);

  Future<void> addBarcode(int foodId, String code) =>
      _dbHelper.addBarcode(foodId, code);

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
  }) => _dbHelper.upsertFoodWithKeys(
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

  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) => foodCatalog.calcForPortion(
    foodId: foodId,
    portionId: portionId,
    quantity: quantity,
  );

  Future<List<DiaryEntry>> getDiaryEntriesBetween(
    int profileId,
    DateTime start,
    DateTime end, {
    MealType? mealType,
    int limit = 1000,
  }) => _dbHelper.getDiaryEntriesBetween(
    profileId,
    start,
    end,
    mealType: mealType,
    limit: limit,
  );

  Future<Map<String, double>> getDayMicros(
    int profileId,
    DateTime date,
    List<String> codes,
  ) => _dbHelper.getDayMicros(profileId, date, codes);

  Future<void> addFavorite(int profileId, int foodId) =>
      _dbHelper.addFavorite(profileId, foodId);

  Future<void> removeFavorite(int profileId, int foodId) =>
      _dbHelper.removeFavorite(profileId, foodId);

  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) =>
      _dbHelper.listFavorites(profileId, limit: limit);

  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) =>
      _dbHelper.getRecentFoods(profileId, limit: limit);

  Future<List<Recipe>> getRecentRecipes(int profileId, {int limit = 20}) =>
      _dbHelper.getRecentRecipes(profileId, limit: limit);

  Future<void> addDiaryTag(int entryId, String tag) =>
      _dbHelper.addDiaryTag(entryId, tag);

  Future<void> removeDiaryTag(int entryId, String tag) =>
      _dbHelper.removeDiaryTag(entryId, tag);

  Future<List<String>> getTagsForEntry(int entryId) =>
      _dbHelper.getTagsForEntry(entryId);

  Future<List<DiaryEntry>> getEntriesByTag({
    required int profileId,
    required String tag,
    DateTime? start,
    DateTime? end,
    int limit = 200,
  }) => _dbHelper.getEntriesByTag(
    profileId: profileId,
    tag: tag,
    start: start,
    end: end,
    limit: limit,
  );

  Future<Map<String, double>> getRecipePer100gByCode(int recipeId) =>
      _dbHelper.getRecipePer100gByCode(recipeId);

  Future<void> rebuildRecipeNutrientCache(int recipeId) =>
      _dbHelper.rebuildRecipeNutrientCache(recipeId);

  Future<void> rebuildFoodFts() => _dbHelper.rebuildFoodFts();
}
