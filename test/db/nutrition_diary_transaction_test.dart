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
  late int profileId;
  late int foodId;
  late int recipeId;
  final day = DateTime(2026, 10, 31);
  final nextDay = DateTime(2026, 11, 1);

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        onConfigure: (database) => database.execute('PRAGMA foreign_keys=ON'),
      ),
    );
    await Schema.createTables(db);
    nutrition = NutritionDao(db);
    profileId = await db.insert('gym_profiles', {'name': 'Diary test'});
    await nutrition.seedNutrientsIfEmpty();
    foodId = await nutrition.insertCustomFood(name: 'Test food');
    await nutrition.replacePer100gByCode(foodId, {
      'ENERGY_KCAL': 100,
      'PROTEIN': 10,
      'CARB': 20,
      'FAT': 2,
    });
    recipeId = await nutrition.createOrUpdateRecipe(
      Recipe(
        name: 'Test recipe',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      [RecipeIngredient(recipeId: 0, foodId: foodId, grams: 100)],
    );
  });
  tearDown(() => db.close());

  Future<int> addFood({DateTime? date, double grams = 100}) =>
      nutrition.addDiaryFood(
        profileId: profileId,
        date: date ?? day,
        mealType: MealType.lunch,
        foodId: foodId,
        loggedGrams: grams,
        loggedAt: DateTime.utc(2026, 10, 31, 16),
        notes: 'Retained note',
      );

  Future<Map<String, List<Map<String, Object?>>>> snapshot() async => {
    'entries': await db.query('diary_entries', orderBy: 'id'),
    'totals': await db.query('day_totals_cache', orderBy: 'profile_id, date'),
    'usage': await db.query('food_usage_stats', orderBy: 'profile_id, food_id'),
    'recipes': await db.query('recipe_nutrients', orderBy: 'recipe_id, code'),
  };

  Future<void> rejectTotals({bool onlyNextDay = false}) => db.execute('''
    CREATE TRIGGER reject_totals BEFORE INSERT ON day_totals_cache
    ${onlyNextDay ? "WHEN NEW.date = '2026-11-01'" : ''}
    BEGIN SELECT RAISE(ABORT, 'Injected totals failure'); END
  ''');

  test(
    'successful logging preserves food snapshots, totals and usage',
    () async {
      final id = await addFood(grams: 50);
      final entry = (await nutrition.getDiaryEntriesForDate(
        profileId,
        day,
      )).single;
      final totals = await nutrition.getDayTotals(profileId, day);
      expect(entry.id, id);
      expect(entry.loggedGrams, 50);
      expect(entry.notes, 'Retained note');
      expect(entry.kcalSnapshot, 50);
      expect(entry.proteinGSnapshot, 5);
      expect(totals.kcal, 50);
      expect((await db.query('food_usage_stats')).single['hits'], 1);
    },
  );

  test('a failed later entry retains earlier committed entries', () async {
    await addFood();
    final before = await snapshot();
    await rejectTotals(onlyNextDay: true);
    await expectLater(
      addFood(date: nextDay, grams: 50),
      throwsA(isA<DatabaseException>()),
    );
    expect(await snapshot(), before);
    expect(
      await nutrition.getDiaryEntriesForDate(profileId, day),
      hasLength(1),
    );
    expect(await nutrition.getDiaryEntriesForDate(profileId, nextDay), isEmpty);
  });

  test('late food usage failure restores both entry and totals', () async {
    await addFood();
    final before = await snapshot();
    await db.execute('''
      CREATE TRIGGER reject_usage BEFORE INSERT ON food_usage_stats
      BEGIN SELECT RAISE(ABORT, 'Injected usage failure'); END
    ''');
    await expectLater(addFood(grams: 50), throwsA(isA<DatabaseException>()));
    expect(await snapshot(), before);
  });

  test('recipe logging rolls back when totals cannot be written', () async {
    final before = await snapshot();
    await rejectTotals();
    await expectLater(
      nutrition.addDiaryRecipe(
        profileId: profileId,
        date: day,
        mealType: MealType.dinner,
        recipeId: recipeId,
        quantity: 1.5,
      ),
      throwsA(isA<DatabaseException>()),
    );
    expect(await snapshot(), before);
  });

  test('a failed date move restores the entry and both day caches', () async {
    await addFood();
    final entry = (await nutrition.getDiaryEntriesForDate(
      profileId,
      day,
    )).single;
    final before = await snapshot();
    await rejectTotals(onlyNextDay: true);
    await expectLater(
      nutrition.updateDiaryEntry(
        entry.copyWith(date: nextDay, loggedGrams: 50),
      ),
      throwsA(isA<DatabaseException>()),
    );
    expect(await snapshot(), before);
  });

  test('failed delete leaves the original entry visible', () async {
    final id = await addFood();
    final before = await snapshot();
    await rejectTotals();
    await expectLater(
      nutrition.deleteDiaryEntry(id, profileId: profileId, date: day),
      throwsA(isA<DatabaseException>()),
    );
    expect(await snapshot(), before);
    expect(
      await nutrition.getDiaryEntriesForDate(profileId, day),
      hasLength(1),
    );
  });

  test(
    'caller transaction owns rollback of completed diary operations',
    () async {
      final before = await snapshot();
      await expectLater(
        db
            .transaction((transaction) async {
              final scoped = NutritionDao.inTransaction(transaction);
              await scoped.addDiaryFood(
                profileId: profileId,
                date: day,
                mealType: MealType.lunch,
                foodId: foodId,
                loggedGrams: 100,
              );
              await scoped.addDiaryRecipe(
                profileId: profileId,
                date: day,
                mealType: MealType.dinner,
                recipeId: recipeId,
              );
              throw StateError('Abort outer transaction');
            })
            .timeout(const Duration(seconds: 5)),
        throwsA(isA<StateError>()),
      );
      expect(await snapshot(), before);
    },
  );

  test(
    'caller transaction remains usable and commits all diary operations',
    () async {
      await db
          .transaction((transaction) async {
            final scoped = NutritionDao.inTransaction(transaction);
            await scoped.addDiaryFood(
              profileId: profileId,
              date: day,
              mealType: MealType.lunch,
              foodId: foodId,
              loggedGrams: 50,
            );
            await scoped.addDiaryRecipe(
              profileId: profileId,
              date: day,
              mealType: MealType.dinner,
              recipeId: recipeId,
            );
            await transaction.update(
              'gym_profiles',
              {'name': 'Outer transaction completed'},
              where: 'id = ?',
              whereArgs: [profileId],
            );
          })
          .timeout(const Duration(seconds: 5));
      expect(
        await nutrition.getDiaryEntriesForDate(profileId, day),
        hasLength(2),
      );
      expect((await nutrition.getDayTotals(profileId, day)).kcal, 150);
      expect(
        (await db.query('gym_profiles')).single['name'],
        'Outer transaction completed',
      );
    },
  );
}
