import 'package:env_test/db/food_customization_dao.dart';
import 'package:env_test/db/nutrition_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;
  late NutritionDao nutrition;
  late int foodId;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await Schema.createTables(db);
    // The DAO also supports upgraded databases with a default-portion link.
    await db.execute('ALTER TABLE foods ADD COLUMN default_portion_id INTEGER');
    nutrition = NutritionDao(db);
    await nutrition.seedNutrientsIfEmpty();
    foodId = await nutrition.insertCustomFood(
      name: 'Original food',
      brand: 'Original brand',
    );
    await nutrition.replacePer100gByCode(foodId, {
      'ENERGY_KCAL': 100,
      'PROTEIN': 10,
    });
    final portionId = await db.insert('food_portions', {
      'food_id': foodId,
      'measure_name': 'Original portion',
      'gram_weight': 100,
      'is_default': 1,
    });
    await db.update(
      'foods',
      {'default_portion_id': portionId},
      where: 'id = ?',
      whereArgs: [foodId],
    );
  });
  tearDown(() => db.close());

  test('customization saves names, density, nutrient precision and portion metadata', () async {
    await FoodCustomizationDao.update(db, {
      'food_id': foodId,
      'name': 'Updated food',
      'brand': 'Updated brand',
      'density_g_per_ml': 1.00125,
      'calories': 42.25,
      'protein_g': 2.125,
      'carbs_g': 6.5,
      'fats_g': 1.5,
      'portions': [
        {
          'measure_name': 'My scoop',
          'gram_weight': 12.125,
          'ml_volume': null,
          'is_default': true,
          'list_kind': 'usual',
          'sort_order': 0,
          'amount': 1.25,
          'unit': 'g',
          'label': 'Scoop label',
        },
      ],
    });
    final food = await nutrition.getFood(foodId);
    expect(food!.name, 'Updated food');
    expect(food.densityGPerMl, 1.00125);
    final nutrients = await nutrition.getFoodNutrientsPer100gByCode(foodId);
    expect(nutrients['ENERGY_KCAL'], 42.25);
    expect(nutrients['PROTEIN'], 2.125);
    final portions = await nutrition.getPortionsForFood(foodId);
    expect(portions, hasLength(1));
    expect(portions.single.gramWeight, 12.125);
    expect(portions.single.isDefault, isTrue);
    expect(portions.single.label, 'Scoop label');
    expect(portions.single.amount, 1.25);
  });

  test('a missing food ID is rejected before writes', () async {
    await expectLater(
      FoodCustomizationDao.update(db, {'name': 'Changed'}),
      throwsArgumentError,
    );
    expect((await nutrition.getFood(foodId))!.name, 'Original food');
  });
}
