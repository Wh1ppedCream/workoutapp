import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/nutrition/food_logging_page.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _CatalogSource implements FoodCatalogSource {
  _CatalogSource(this.food, this.portions);

  final Food food;
  final List<FoodPortion> portions;

  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async => {
    'KCAL': 100 * quantity,
    'PROTEIN_G': 10 * quantity,
    'CARB_G': 20 * quantity,
    'FAT_G': 5 * quantity,
  };

  @override
  Future<Food?> getFood(int id) async => id == food.id ? food : null;

  @override
  Future<Food?> getFoodByBarcode(String code) async => null;

  @override
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async => {
    'KCAL': 100,
    'PROTEIN_G': 10,
    'CARB_G': 20,
    'FAT_G': 5,
  };

  @override
  Future<List<FoodPortion>> getPortionsForFood(int foodId) async =>
      idMatches(foodId) ? portions : const [];

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async =>
      query.toLowerCase().contains(food.name.toLowerCase()) ? [food] : const [];

  bool idMatches(int id) => id == food.id;
}

class _FakeRepository extends AppRepository {
  _FakeRepository(
    this.food,
    this.portions, {
    this.failFavorites = false,
    this.failDiaryWrite = false,
  }) : catalog = FoodCatalogRepository(source: _CatalogSource(food, portions)),
       super();

  final Food food;
  final List<FoodPortion> portions;
  final FoodCatalogRepository catalog;
  final bool failFavorites;
  final bool failDiaryWrite;
  final Set<int> favorites = {};
  final logged = <Map<String, Object?>>[];
  final diary = <DiaryEntryWithItem>[];

  @override
  FoodCatalogRepository get foodCatalog => catalog;

  @override
  Future<void> seedNutrientsIfEmpty() async {}

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [
    GymProfile(id: 1, name: 'Test profile', createdAt: DateTime(2026)),
  ];

  @override
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async =>
      DayTotals(profileId: profileId, date: date);

  @override
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      null;

  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async => diary.where((row) => row.entry.date == date).toList();

  @override
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      favorites.contains(food.id) ? [food] : const [];

  @override
  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) async =>
      const [];

  @override
  Future<List<Recipe>> getRecentRecipes(
    int profileId, {
    int limit = 20,
  }) async => const [];

  @override
  Future<void> addFavorite(int profileId, int foodId) async {
    if (failFavorites) throw StateError('favorite write failed');
    favorites.add(foodId);
  }

  @override
  Future<void> removeFavorite(int profileId, int foodId) async {
    if (failFavorites) throw StateError('favorite write failed');
    favorites.remove(foodId);
  }

  @override
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
  }) async {
    if (failDiaryWrite) throw StateError('diary write failed');
    logged.add({
      'foodId': foodId,
      'portionId': portionId,
      'quantity': quantity,
      'gramsOverride': gramsOverride,
      'loggedGrams': loggedGrams,
      'mealType': mealType,
    });
    return logged.length;
  }

  @override
  Future<void> addDiaryTag(int entryId, String tag) async {}
}

Food _food() => Food(
  id: 7,
  name: 'Test oats',
  brand: 'Tonos',
  isCustom: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeRepository repository,
  NutritionProfile profile,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<NutritionProfile>(
        create: (_) => profile,
        child: FoodLoggingPage(repository: repository),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  testWidgets('log entry renders requested date, names and saved macros', (
    tester,
  ) async {
    final date = DateTime(2020, 1, 2);
    final repository = _FakeRepository(_food(), []);
    repository.diary.add(
      DiaryEntryWithItem(
        itemName: 'Saved oats',
        entry: DiaryEntry(
          id: 1,
          profileId: 1,
          date: date,
          mealType: MealType.breakfast,
          foodId: 7,
          quantity: 2,
          loggedAt: DateTime(2020, 1, 2, 1),
          kcalSnapshot: 200,
          proteinGSnapshot: 20,
          carbGSnapshot: 40,
          fatGSnapshot: 10,
        ),
      ),
    );
    final profile = NutritionProfile(repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<NutritionProfile>(
          create: (_) => profile,
          child: LogEntryPage(date: date),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(LogEntryPage));
    expect(
      find.text(MaterialLocalizations.of(context).formatMediumDate(date)),
      findsOneWidget,
    );
    expect(profile.error, isNull);
    expect(profile.day, date);
    expect(profile.mealsWithItems.map((row) => row.itemName), ['Saved oats']);
    // The entry chip uses one Text.rich for both lines, not separate Texts.
    final summary = AppLocalizations.of(
      context,
    ).nutritionMacroSummary(200, 20, 40, 10);
    expect(find.text('Saved oats\n$summary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search, favorite, portion quantity and log preserve behavior', (
    tester,
  ) async {
    final food = _food();
    final portions = [
      FoodPortion(
        id: 11,
        foodId: food.id!,
        measureName: 'bowl',
        gramWeight: 200,
        isDefault: true,
      ),
      FoodPortion(
        id: 12,
        foodId: food.id!,
        measureName: 'half bowl',
        gramWeight: 100,
      ),
    ];
    final repository = _FakeRepository(food, portions);
    final profile = NutritionProfile(repository: repository);
    await _pumpPage(tester, repository, profile);

    final search = find.byType(TextField).last;
    await tester.enterText(search, 'Test oats');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.widgetWithText(ListTile, food.name), findsOneWidget);

    final strings = AppLocalizations.of(
      tester.element(find.byType(FoodLoggingPage)),
    );
    await tester.tap(find.byTooltip(strings.foodFavorite));
    await tester.pump();
    expect(repository.favorites, contains(food.id));
    expect(find.byTooltip(strings.foodUnfavorite), findsOneWidget);

    await tester.tap(find.byTooltip(strings.foodEditAndAdd));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<FoodPortion>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('half bowl • 100 g'));
    await tester.pump();
    final quantity = find.byType(TextFormField).first;
    await tester.enterText(quantity, '2');
    await tester.tap(find.text('Add to Plate'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Log 1'));
    await tester.pumpAndSettle();
    expect(repository.logged, hasLength(1));
    expect(repository.logged.single['foodId'], food.id);
    expect(repository.logged.single['portionId'], 12);
    expect(repository.logged.single['quantity'], 2.0);
    expect(repository.logged.single['gramsOverride'], isNull);
    expect(repository.logged.single['loggedGrams'], 200.0);
    expect(tester.takeException(), isNull);
  });

  test(
    'nutrition profile rolls back failed favorites and records log errors',
    () async {
      final food = _food();
      final repository = _FakeRepository(
        food,
        const [],
        failFavorites: true,
        failDiaryWrite: true,
      );
      final profile = NutritionProfile(repository: repository);
      await _waitForProfile(profile);

      await profile.toggleFavorite(food.id!);
      expect(profile.isFavorite(food.id!), isFalse);
      expect(profile.error, isNotNull);

      await profile.addFood(meal: MealType.lunch, foodId: food.id!);
      expect(repository.logged, isEmpty);
      expect(profile.error, isNotNull);
      profile.dispose();
    },
  );

  testWidgets(
    'log entry groups same-time rows and keeps stable date ordering',
    (tester) async {
      final date = DateTime(2020, 1, 2);
      final repository = _FakeRepository(_food(), []);
      repository.diary.addAll([
        _diaryRow(
          id: 2,
          name: 'Breakfast later',
          date: date,
          meal: MealType.breakfast,
          loggedAt: DateTime(2020, 1, 2, 8, 2),
        ),
        _diaryRow(
          id: 1,
          name: 'Breakfast first',
          date: date,
          meal: MealType.breakfast,
          loggedAt: DateTime(2020, 1, 2, 8, 2),
        ),
        _diaryRow(
          id: 3,
          name: 'Dinner',
          date: date,
          meal: MealType.dinner,
          loggedAt: DateTime(2020, 1, 2, 18),
        ),
      ]);
      final profile = NutritionProfile(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider<NutritionProfile>(
            create: (_) => profile,
            child: LogEntryPage(date: date),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(profile.mealsWithItems.map((row) => row.itemName).toList(), [
        'Breakfast first',
        'Breakfast later',
        'Dinner',
      ]);
      Finder chipWithTitle(String title) => find.byWidgetPredicate((widget) {
        return widget is RichText &&
            widget.text.toPlainText().startsWith('$title\n');
      });

      expect(chipWithTitle('Breakfast first'), findsOneWidget);
      expect(chipWithTitle('Breakfast later'), findsOneWidget);
      expect(chipWithTitle('Dinner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

DiaryEntryWithItem _diaryRow({
  required int id,
  required String name,
  required DateTime date,
  required MealType meal,
  required DateTime loggedAt,
}) {
  return DiaryEntryWithItem(
    itemName: name,
    entry: DiaryEntry(
      id: id,
      profileId: 1,
      date: date,
      mealType: meal,
      foodId: 7,
      quantity: 1,
      loggedAt: loggedAt,
      kcalSnapshot: 100,
      proteinGSnapshot: 10,
      carbGSnapshot: 20,
      fatGSnapshot: 5,
    ),
  );
}

Future<void> _waitForProfile(NutritionProfile profile) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (profile.profileId != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(profile.profileId, isNotNull);
}
