import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/profile/settings/diet_nutrition_settings_page.dart';
import 'package:env_test/screens/profile/settings/goal_manual_entry_page.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class _EmptyCatalogSource implements FoodCatalogSource {
  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1.0,
  }) async => const {};

  @override
  Future<Food?> getFood(int id) async => null;

  @override
  Future<Food?> getFoodByBarcode(String code) async => null;

  @override
  Future<Map<String, double>> getMacroPer100gLegacySafe(int foodId) async =>
      const {};

  @override
  Future<List<FoodPortion>> getPortionsForFood(int foodId) async => const [];

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async =>
      const [];
}

class _GoalRepository extends AppRepository {
  _GoalRepository()
    : catalog = FoodCatalogRepository(source: _EmptyCatalogSource()),
      super();

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
    savedGoal = goal;
  }
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  required ThemeData theme,
  bool largeText = false,
}) async {
  final repository = _GoalRepository();
  final profile = NutritionProfile(repository: repository);
  await tester.pumpWidget(
    ChangeNotifierProvider<NutritionProfile>(
      create: (_) => profile,
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
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

void main() {
  testWidgets('Expressive nutrition settings show destination goal surfaces', (
    tester,
  ) async {
    final profile = NutritionProfile(repository: _GoalRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider<NutritionProfile>(
        create: (_) => profile,
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DietNutritionSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pageContext = tester.element(find.byType(DietNutritionSettingsPage));
    final strings = AppLocalizations.of(pageContext);
    final destination = Theme.of(
      tester.element(find.text(strings.nutritionManualGoals)),
    ).extension<AppExpressiveDestinationTokens>()!;
    expect(destination.family, AppExpressiveDestinationFamily.nutrition);
    expect(find.text(strings.nutritionSettingsTitle), findsOneWidget);
    expect(find.text(strings.nutritionGoals), findsOneWidget);
    expect(find.text(strings.nutritionManualGoalsSubtitle), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
      destination.pageCanvas,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive diary keeps the 24-hour grid readable at compact width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final profile = NutritionProfile(repository: _GoalRepository());
      await tester.pumpWidget(
        ChangeNotifierProvider<NutritionProfile>(
          create: (_) => profile,
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.8)),
              child: child!,
            ),
            home: LogEntryPage(date: DateTime(2026, 1, 2)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(LogEntryPage));
      final strings = AppLocalizations.of(pageContext);
      expect(find.text(strings.nutritionCaloriesLabel), findsOneWidget);
      expect(find.text(strings.nutritionFatLabel), findsOneWidget);
      expect(find.text(strings.nutritionProteinLabel), findsOneWidget);
      expect(find.text(strings.nutritionCarbsLabel), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.height == 64,
        ),
        findsAtLeastNWidgets(24),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive goal editor uses nutrition surfaces in both modes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final theme in [
      ExpressiveThemeDefinition.light(),
      ExpressiveThemeDefinition.dark(),
    ]) {
      await _pumpEditor(tester, theme: theme, largeText: true);
      expect(find.byType(AppExpressiveDestinationTheme), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
      expect(tester.takeException(), isNull);

      final pageContext = tester.element(find.byType(GoalManualEntryPage));
      final destination = Theme.of(
        tester.element(find.byType(TextFormField).first),
      ).extension<AppExpressiveDestinationTokens>()!;
      expect(destination.family, AppExpressiveDestinationFamily.nutrition);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
        destination.pageCanvas,
      );
      final editorScroll = find.byType(ListView).first;
      await tester.drag(editorScroll, const Offset(0, -900));
      await tester.pumpAndSettle();
      final strings = AppLocalizations.of(pageContext);
      expect(find.text(strings.nutritionCaloriesAndMacros), findsOneWidget);
      expect(find.text(strings.nutritionAdditionalNutrients), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('goal editor preserves every entered target when saving', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _GoalRepository();
    final profile = NutritionProfile(repository: repository);
    await tester.pumpWidget(
      ChangeNotifierProvider<NutritionProfile>(
        create: (_) => profile,
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
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

    final values = ['2300', '140', '240', '80', '30', '35', '14', '2000'];
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(8));
    for (var index = 0; index < values.length; index++) {
      tester.widget<TextFormField>(fields.at(index)).controller!.text =
          values[index];
    }
    await tester.pump();
    final context = tester.element(find.byType(GoalManualEntryPage));
    await tester.ensureVisible(
      find.text(AppLocalizations.of(context).nutritionSaveGoals),
    );
    await tester.tap(
      find.text(AppLocalizations.of(context).nutritionSaveGoals),
    );
    await tester.pumpAndSettle();

    final saved = repository.savedGoal!;
    expect(saved.kcalTarget, 2300);
    expect(saved.proteinG, 140);
    expect(saved.carbsG, 240);
    expect(saved.fatG, 80);
    expect(saved.fiberG, 30);
    expect(saved.sugarG, 35);
    expect(saved.satFatG, 14);
    expect(saved.sodiumMg, 2000);
    expect(find.byType(GoalManualEntryPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Classic and Neo goal pages keep their existing settings theme', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      await _pumpEditor(tester, theme: theme);
      expect(find.byType(AppExpressiveDestinationTheme), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(8));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
