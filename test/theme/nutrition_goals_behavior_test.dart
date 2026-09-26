import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/profile/settings/goal_manual_entry_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _EmptyCatalogSource implements FoodCatalogSource {
  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async => const <String, double>{};

  @override
  Future<Food?> getFood(int id) async => null;

  @override
  Future<Food?> getFoodByBarcode(String code) async => null;

  @override
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async =>
      const <String, double>{};

  @override
  Future<List<FoodPortion>> getPortionsForFood(int foodId) async => const [];

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async =>
      const [];
}

class _GoalRepository extends AppRepository {
  _GoalRepository({required this.failOnSave})
    : catalog = FoodCatalogRepository(source: _EmptyCatalogSource()),
      super();

  final bool failOnSave;
  final FoodCatalogRepository catalog;
  NutritionGoal? savedGoal;

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
      savedGoal;

  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async => const [];

  @override
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      const [];

  @override
  Future<void> setGoals(NutritionGoal goal) async {
    if (failOnSave) throw StateError('write failed');
    savedGoal = goal;
  }
}

Future<void> _pumpGoalEditor(
  WidgetTester tester,
  NutritionProfile profile,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<NutritionProfile>(
      create: (_) => profile,
      child: MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GoalManualEntryPage(),
                        ),
                      ),
                  child: const Text('Open goals'),
                ),
              ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open goals'));
  await tester.pumpAndSettle();
}

Future<void> _saveFirstField(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).first, '2000');
  final context = tester.element(find.byType(GoalManualEntryPage));
  final strings = AppLocalizations.of(context);
  final save = find.text(strings.nutritionSaveGoals);
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('goal editor saves and returns the entered targets', (
    tester,
  ) async {
    final repository = _GoalRepository(failOnSave: false);
    final profile = NutritionProfile(repository: repository);

    await _pumpGoalEditor(tester, profile);
    await _saveFirstField(tester);

    expect(repository.savedGoal, isNotNull);
    expect(repository.savedGoal!.kcalTarget, 2000);
    expect(find.byType(GoalManualEntryPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'goal editor stays open and shows safe feedback when saving fails',
    (tester) async {
      final repository = _GoalRepository(failOnSave: true);
      final profile = NutritionProfile(repository: repository);

      await _pumpGoalEditor(tester, profile);
      await _saveFirstField(tester);

      final context = tester.element(find.byType(GoalManualEntryPage));
      final strings = AppLocalizations.of(context);
      expect(find.byType(GoalManualEntryPage), findsOneWidget);
      expect(find.textContaining(strings.safeFailureSaveTitle), findsOneWidget);
      expect(repository.savedGoal, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
