import '../db/database_helper.dart';
import '../models/models.dart';

/// Boundary for food-catalog lookups so the UI can swap local and remote
/// catalog sources without rewriting nutrition flows.
abstract class FoodCatalogSource {
  Future<List<Food>> searchFoods(String query, {int limit = 50});
  Future<Food?> getFood(int id);
  Future<Food?> getFoodByBarcode(String code);
  Future<List<FoodPortion>> getPortionsForFood(int foodId);
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  });
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId);
}

class LocalFoodCatalogSource implements FoodCatalogSource {
  LocalFoodCatalogSource(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) =>
      _dbHelper.searchFoods(query, limit: limit);

  @override
  Future<Food?> getFood(int id) => _dbHelper.getFood(id);

  @override
  Future<Food?> getFoodByBarcode(String code) => _dbHelper.getFoodByBarcode(code);

  @override
  Future<List<FoodPortion>> getPortionsForFood(int foodId) =>
      _dbHelper.getPortionsForFood(foodId);

  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) => _dbHelper.calcForPortion(
        foodId: foodId,
        portionId: portionId,
        quantity: quantity,
      );

  @override
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) =>
      _dbHelper.getMacroPer100gLegacySafe(foodId);
}

class FoodCatalogRepository implements FoodCatalogSource {
  FoodCatalogRepository({FoodCatalogSource? source})
      : _source = source ?? LocalFoodCatalogSource(DatabaseHelper());

  final FoodCatalogSource _source;

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) =>
      _source.searchFoods(query, limit: limit);

  @override
  Future<Food?> getFood(int id) => _source.getFood(id);

  @override
  Future<Food?> getFoodByBarcode(String code) => _source.getFoodByBarcode(code);

  @override
  Future<List<FoodPortion>> getPortionsForFood(int foodId) =>
      _source.getPortionsForFood(foodId);

  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) => _source.calcForPortion(
        foodId: foodId,
        portionId: portionId,
        quantity: quantity,
      );

  @override
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) =>
      _source.getMacroPer100gLegacySafe(foodId);
}
