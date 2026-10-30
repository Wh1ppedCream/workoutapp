import 'package:env_test/db/food_customization_dao.dart';
import 'package:env_test/db/nutrition_dao.dart';
import 'package:env_test/db/schema.dart';
import 'package:env_test/models/nutrition_models.dart';
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

  Future<Map<String, List<Map<String, Object?>>>> snapshot() async => {
    for (final table in [
      'foods',
      'brands',
      'food_barcodes',
      'food_nutrients',
      'food_nutrient_values',
      'food_portions',
    ])
      table: await db.query(table, orderBy: 'id'),
  };

  test('a late portion failure rolls back every part of the edit', () async {
    final original = await snapshot();
    await db.execute('''
      CREATE TRIGGER reject_portion BEFORE INSERT ON food_portions
      WHEN NEW.measure_name = 'Reject'
      BEGIN SELECT RAISE(ABORT, 'Injected portion failure'); END
    ''');
    await expectLater(
      FoodCustomizationDao.update(db, {
        'food_id': foodId,
        'name': 'Should roll back',
        'brand': 'Should not remain',
        'density_g_per_ml': 1.5,
        'barcode': '4006381333931',
        'calories': 22.5,
        'protein_g': 1.25,
        'portions': [
          {
            'measure_name': 'Valid',
            'gram_weight': 40,
            'is_default': true,
            'sort_order': 0,
          },
          {'measure_name': 'Reject', 'gram_weight': 60, 'sort_order': 1},
        ],
      }),
      throwsA(isA<DatabaseException>()),
    );
    expect(await snapshot(), original);
  });

  test('adding a portion uses its transaction for schema lookup', () async {
    final id = await nutrition.addPortion(
      foodId,
      measureName: 'Scoop',
      gramWeight: 42.125,
      isDefault: true,
      amount: 1.5,
      unit: 'g',
      label: 'Label',
    );
    final portions = await nutrition.getPortionsForFood(foodId);
    expect(portions.where((p) => p.isDefault).single.id, id);
    expect(portions.first.gramWeight, 42.125);
    expect(portions.first.label, 'Label');
    expect((await db.query('foods')).single['default_portion_id'], id);
  });

  test(
    'upserting a portion preserves ID, metadata and a single default',
    () async {
      final old = (await nutrition.getPortionsForFood(foodId)).single;
      final id = await nutrition.upsertFoodPortion(
        FoodPortion(
          id: old.id,
          foodId: foodId,
          measureName: 'Edited',
          gramWeight: 20.25,
          isDefault: true,
          amount: 2,
          unit: 'g',
          listKind: 'usual',
          sortOrder: 1,
          label: 'Edited label',
        ),
      );
      final portion = (await nutrition.getPortionsForFood(foodId)).single;
      expect(id, old.id);
      expect(portion.isDefault, isTrue);
      expect(portion.label, 'Edited label');
      expect(portion.gramWeight, 20.25);
      expect((await db.query('foods')).single['default_portion_id'], id);
    },
  );

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

  test(
    'creating a custom food retains its identity and default portion',
    () async {
      final id = await FoodCustomizationDao.create(db, {
        'name': 'New food',
        'brand': 'New brand',
        'calories': 80.25,
        'density_g_per_ml': 1.25,
        'Protein > Protein (g)': 2.5,
      });
      final food = (await db.query(
        'foods',
        where: 'id = ?',
        whereArgs: [id],
      )).single;
      expect(food['is_custom'], 1);
      expect(food['data_source'], 'user');
      expect(food['density_g_per_ml'], 1.25);
      final nutrients = await nutrition.getFoodNutrientsPer100gByCode(id);
      expect(nutrients['ENERGY_KCAL'], 80.25);
      expect(nutrients['PROTEIN'], 2.5);
      final portion = (await nutrition.getPortionsForFood(id)).single;
      expect(portion.measureName, '100 g');
      expect(portion.isDefault, isTrue);
    },
  );

  test('a failed creation leaves no food shell or orphaned brand', () async {
    final original = await snapshot();
    await expectLater(
      FoodCustomizationDao.create(db, {
        'name': 'Incomplete food',
        'brand': 'Incomplete brand',
        'calories': 200,
        'portions': [
          {'measure_name': 42, 'gram_weight': 10},
        ],
      }),
      throwsA(isA<TypeError>()),
    );
    expect(await snapshot(), original);
  });

  for (final barcode in [
    '96385074',
    '036000291452',
    '4006381333931',
    '10012345000017',
  ]) {
    test('valid barcode $barcode saves and resolves without mutation errors', () async {
      await nutrition.addBarcode(foodId, barcode);
      await nutrition.addBarcode(foodId, barcode);
      expect((await nutrition.getFoodByBarcode(barcode))!.id, foodId);
      final invalid =
          '${barcode.substring(0, barcode.length - 1)}${(int.parse(barcode[barcode.length - 1]) + 1) % 10}';
      await nutrition.addBarcode(foodId, invalid);
      expect(await nutrition.getFoodByBarcode(invalid), isNull);
    });
  }

  test(
    'portion inserts work on the supported schema without a default link',
    () async {
      await db.execute('ALTER TABLE foods DROP COLUMN default_portion_id');
      final id = await nutrition.addPortion(
        foodId,
        measureName: 'Legacy compatible',
        gramWeight: 50,
        isDefault: true,
      );
      expect((await nutrition.getPortionsForFood(foodId)).first.id, id);
    },
  );
}
