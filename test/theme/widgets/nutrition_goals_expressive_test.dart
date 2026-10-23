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
  _GoalRepository? repository,
}) async {
  final profile = NutritionProfile(repository: repository ?? _GoalRepository());
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
  await tester.pumpAndSettle();
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
      tester.element(find.text(strings.nutritionEditGoals)),
    ).extension<AppExpressiveDestinationTokens>()!;
    expect(destination.family, AppExpressiveDestinationFamily.nutrition);
    expect(find.text(strings.nutritionGoalsMenu), findsOneWidget);
    expect(find.text(strings.nutritionCurrentGoals), findsOneWidget);
    expect(find.text(strings.nutritionManualGoalsSubtitle), findsOneWidget);
    expect(find.text(strings.nutritionGoalsSubtitle), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
      destination.pageCanvas,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive goal summary distinguishes unset and zero extras', (
    tester,
  ) async {
    final repository = _GoalRepository()
      ..savedGoal = NutritionGoal(profileId: 1, startDate: DateTime.now());
    final profile = NutritionProfile(repository: repository);
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
    final strings = AppLocalizations.of(
      tester.element(find.byType(DietNutritionSettingsPage)),
    );
    expect(find.text(strings.nutritionNoAdditionalTargets), findsOneWidget);

    repository.savedGoal = NutritionGoal(
      profileId: 1,
      startDate: DateTime.now(),
      fiberG: 0,
    );
    await profile.reloadDay();
    await tester.pumpAndSettle();
    expect(find.text(strings.nutritionNoAdditionalTargets), findsNothing);
    expect(find.text('0 g'), findsOneWidget);
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
        find.text(
          '${strings.nutritionNoFoodLogged}\n${strings.nutritionTapToAddFirstEntry}',
        ),
        findsOneWidget,
      );
      expect(find.textContaining(strings.nutritionNoGoalSet), findsNWidgets(4));
      expect(
        find.byTooltip(strings.nutritionAddEntryActionLabel),
        findsOneWidget,
      );
      Finder statCard(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container && widget.constraints?.minHeight == 52,
        ),
      );
      final calories = tester.getTopLeft(
        statCard(strings.nutritionCaloriesLabel),
      );
      final protein = tester.getTopLeft(
        statCard(strings.nutritionProteinLabel),
      );
      final carbs = tester.getTopLeft(statCard(strings.nutritionCarbsLabel));
      final fat = tester.getTopLeft(statCard(strings.nutritionFatLabel));
      expect(protein.dx, greaterThan(calories.dx));
      expect(protein.dy, closeTo(calories.dy, 1));
      expect(carbs.dy, closeTo(protein.dy, 1));
      expect(carbs.dx, greaterThan(protein.dx));
      expect(fat.dx, greaterThan(carbs.dx));
      expect(fat.dy, closeTo(carbs.dy, 1));
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.height == 64,
        ),
        findsAtLeastNWidgets(24),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive records preserve an explicitly configured zero goal',
    (tester) async {
      final repository = _GoalRepository()
        ..savedGoal = NutritionGoal(
          profileId: 1,
          startDate: DateTime.now(),
          kcalTarget: 0,
        );
      final profile = NutritionProfile(repository: repository);
      await tester.pumpWidget(
        ChangeNotifierProvider<NutritionProfile>(
          create: (_) => profile,
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LogEntryPage(date: DateTime.now()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 0 kcal'), findsOneWidget);
      final pageContext = tester.element(find.byType(LogEntryPage));
      expect(
        find.textContaining(
          AppLocalizations.of(pageContext).nutritionNoGoalSet,
        ),
        findsNWidgets(3),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive goal editor uses nutrition surfaces in both modes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);

    for (final theme in [
      ExpressiveThemeDefinition.light(),
      ExpressiveThemeDefinition.dark(),
    ]) {
      await _pumpEditor(tester, theme: theme, largeText: true);
      expect(find.byType(AppExpressiveDestinationTheme), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
      expect(tester.takeException(), isNull);

      final pageContext = tester.element(find.byType(GoalManualEntryPage));
      final strings = AppLocalizations.of(pageContext);
      expect(find.text(strings.nutritionOptionalTargetsHint), findsOneWidget);
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
      expect(find.text(strings.nutritionCaloriesAndMacros), findsOneWidget);
      expect(find.text(strings.nutritionAdditionalNutrients), findsOneWidget);
      for (var index = 0; index < 8; index++) {
        final field = find.byType(TextFormField).at(index);
        final heightConstraint = find.ancestor(
          of: field,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is ConstrainedBox && widget.constraints.minHeight == 52,
          ),
        );
        expect(heightConstraint, findsOneWidget);
      }
      final macroHeadingFinder = find.text(strings.nutritionCaloriesAndMacros);
      await tester.ensureVisible(macroHeadingFinder);
      await tester.pumpAndSettle();
      final appBar = tester.getRect(find.byType(AppBar).last);
      expect(
        tester.getRect(macroHeadingFinder).top,
        greaterThanOrEqualTo(appBar.bottom),
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      final lastField = find.byType(TextFormField).last;
      await tester.ensureVisible(lastField);
      await tester.pumpAndSettle();
      // Revealing the last section updates the lazy list's extent after the
      // keyboard resize; reveal again using that settled extent.
      await tester.ensureVisible(lastField);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(lastField).bottom,
        lessThan(tester.getRect(find.text(strings.nutritionSaveGoals)).top),
      );
      tester.view.resetViewInsets();
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

  testWidgets('Expressive goal editor preserves existing precision on save', (
    tester,
  ) async {
    final repository = _GoalRepository()
      ..savedGoal = NutritionGoal(
        profileId: 1,
        startDate: DateTime.now(),
        kcalTarget: 2000,
        proteinG: 130.5,
        carbsG: 0,
        fatG: 80.25,
        fiberG: 0,
        satFatG: 10.5,
        sodiumMg: 2000,
      );
    await _pumpEditor(
      tester,
      theme: ExpressiveThemeDefinition.light(),
      repository: repository,
    );
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(fields.map((field) => field.controller!.text).toList(), [
      '2000',
      '130.5',
      '0',
      '80.25',
      '0',
      '',
      '10.5',
      '2000',
    ]);
    final strings = AppLocalizations.of(
      tester.element(find.byType(GoalManualEntryPage)),
    );
    await tester.tap(find.text(strings.nutritionSaveGoals));
    await tester.pumpAndSettle();
    final saved = repository.savedGoal!;
    expect(saved.kcalTarget, 2000);
    expect(saved.proteinG, 130.5);
    expect(saved.carbsG, 0);
    expect(saved.fatG, 80.25);
    expect(saved.fiberG, 0);
    expect(saved.sugarG, isNull);
    expect(saved.satFatG, 10.5);
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
