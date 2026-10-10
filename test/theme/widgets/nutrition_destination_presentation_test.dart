import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/screens/nutrition/food_logging_page.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:env_test/screens/nutrition/nutrition_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Nutrition editor owns ${brightness.name} destination colors at 320dp with large text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final baseTheme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final expectedDestination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          brightness,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: baseTheme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const FoodCustomizationPage(initialName: 'Test oats'),
          ),
        );
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        final pageContext = tester.element(find.byType(Scaffold));
        final destination = Theme.of(pageContext)
            .extension<AppExpressiveDestinationTokens>();
        final nutrition = Theme.of(pageContext).extension<AppNutritionTokens>();
        expect(destination?.family, AppExpressiveDestinationFamily.nutrition);
        expect(destination?.pageCanvas, expectedDestination.pageCanvas);
        expect(nutrition?.foodBorder, isNotNull);
        expect(scaffold.backgroundColor, expectedDestination.pageCanvas);
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, expectedDestination.surfacePrimary);
        expect(appBar.foregroundColor, expectedDestination.onSurfacePrimary);
        final nameField = find.byType(TextFormField).first;
        final fieldTheme = Theme.of(tester.element(nameField));
        expect(fieldTheme.inputDecorationTheme.filled, isTrue);
        expect(
          fieldTheme.inputDecorationTheme.fillColor,
          expectedDestination.surfaceSecondary,
        );
        final identityCard = find.ancestor(
          of: nameField,
          matching: find.byType(Card),
        );
        expect(identityCard, findsOneWidget);
        expect(
          tester.widget<Card>(identityCard).color,
          expectedDestination.surfaceSelected,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive Food Customization keeps Amount and footer clear across narrow widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      const widths = [320.0, 360.0, 390.0];
      const scales = [1.0, 1.3, 1.5, 2.0];
      for (final width in widths) {
        for (final scale in scales) {
          final keyboardInset = scale >= 1.5 ? 240.0 : 0.0;
          tester.view.physicalSize = Size(width, 900);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          await tester.pumpWidget(
            MaterialApp(
              theme: ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  viewInsets: EdgeInsets.only(bottom: keyboardInset),
                ),
                child: child!,
              ),
              home: const FoodCustomizationPage(initialName: 'Test oats'),
            ),
          );
          await tester.pumpAndSettle();

          final amount = find.byKey(
            const PageStorageKey('portion_basis_0_amount'),
          );
          expect(amount, findsOneWidget, reason: '$width dp at $scale x');
          await tester.ensureVisible(amount);
          await tester.pumpAndSettle();
          expect(
            tester.getSize(amount).width,
            greaterThanOrEqualTo(140),
            reason: 'Amount field width at $width dp and $scale x',
          );

          final pageContext = tester.element(
            find.byType(FoodCustomizationPage),
          );
          final strings = AppLocalizations.of(pageContext);
          final scrollView = tester.widget<SingleChildScrollView>(
            find.byType(SingleChildScrollView).first,
          );
          final bottomPadding = scrollView.padding!
              .resolve(TextDirection.ltr)
              .bottom;
          expect(
            bottomPadding,
            keyboardInset > 0
                ? greaterThanOrEqualTo(176)
                : greaterThanOrEqualTo(120),
            reason: 'Scroll clearance at $width dp and $scale x',
          );

          if (keyboardInset > 0) {
            await tester.tap(amount);
            await tester.showKeyboard(amount);
            await tester.pumpAndSettle();
          }
          final saveButton = find.ancestor(
            of: find.text(strings.commonSave),
            matching: find.byType(FloatingActionButton),
          );
          expect(saveButton, findsOneWidget);
          expect(
            tester.getRect(saveButton).bottom,
            lessThanOrEqualTo(900 - keyboardInset),
            reason: 'Save stays in view at $width dp and $scale x',
          );
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Nutrition diary title uses its app bar foreground in ${brightness.name}',
      (tester) async {
        final baseTheme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final expectedDestination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          brightness,
        );
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: baseTheme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: LogEntryPage(date: DateTime(2026, 10, 5)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        final title = tester.widget<Text>(
          find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
        );
        expect(appBar.backgroundColor, expectedDestination.surfacePrimary);
        expect(appBar.foregroundColor, expectedDestination.onSurfacePrimary);
        expect(title.style?.color, expectedDestination.onSurfacePrimary);
        expect(
          _contrastRatio(
            title.style!.color!,
            expectedDestination.surfacePrimary,
          ),
          greaterThanOrEqualTo(4.5),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Food Logging maps summary cards to ${brightness.name} roles',
      (tester) async {
        final baseTheme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          brightness,
        );
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: baseTheme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: FoodLoggingPage(repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();

        _expectStatCardRole(
          tester,
          'Calories',
          destination.surfaceTertiary,
          destination.onSurfaceTertiary,
        );
        _expectStatCardRole(
          tester,
          'Protein',
          destination.surfaceAccent,
          destination.onSurfaceAccent,
        );
        _expectStatCardRole(
          tester,
          'Carbs',
          destination.surfaceSelected,
          destination.onSurfaceSelected,
        );
        _expectStatCardRole(
          tester,
          'Fat',
          destination.surfaceSecondary,
          destination.onSurfaceSecondary,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive Food Logging respects the 500dp inner stat-grid breakpoint',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      const viewports = <(double, double, int)>[
        (512, 1, 2), // 480dp inner width stays two columns.
        (532, 1, 4), // 500dp inner width switches to four columns.
        (600, 1, 4), // Wider content remains four columns.
        (512, 1.3, 2),
        (532, 1.3, 4),
        (600, 1.3, 4),
        (512, 1.5, 2),
        (532, 1.5, 4),
        (600, 1.5, 4),
        (512, 2, 2),
        (532, 2, 4),
        (600, 2, 4),
      ];

      for (final (width, textScale, expectedColumns) in viewports) {
        tester.view.physicalSize = Size(width, 900);
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: FoodLoggingPage(repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final labels = ['Calories', 'Protein', 'Carbs', 'Fat'];
        final labelRects = [
          for (final label in labels)
            tester.getRect(find.text(label).first),
        ];
        final observedColumns = labelRects
            .map((rect) => rect.center.dx.round())
            .toSet()
            .length;
        final innerWidth = width - 32;

        expect(
          observedColumns,
          expectedColumns,
          reason:
              'The stat grid changes at 500dp inner width; '
              '$innerWidth dp inner, $textScale× text.',
        );
        expect(
          labels.map((label) => find.text(label).evaluate().length),
          everyElement(1),
          reason: 'All four summary labels remain present.',
        );
        expect(
          labelRects.every(
            (rect) => rect.left >= 0 && rect.right <= width,
          ),
          isTrue,
          reason: 'Summary labels remain within the $width dp viewport.',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'No layout overflow at $width dp and $textScale× text.',
        );
      }
    },
  );

  testWidgets('Expressive rapid logger fits 320dp with 2x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _ResponsiveNutritionRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: ChangeNotifierProvider<NutritionProfile>(
          create: (_) => NutritionProfile(repository: repository),
          child: FoodLoggingPage(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final destination = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.nutrition,
      Brightness.light,
    );
    expect(appBar.backgroundColor, destination.surfacePrimary);
    expect(appBar.foregroundColor, destination.onSurfacePrimary);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive Nutrition pages cap wide content and retain phone width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final width in [390.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 900);
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: const NutritionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final nutritionScroll = find.byType(SingleChildScrollView).first;
        expect(
          tester.getRect(nutritionScroll).width,
          width < 960 ? width : 960,
          reason: 'Nutrition dashboard width at $width dp',
        );
        expect(tester.takeException(), isNull);
      }

      for (final width in [390.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 900);
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: FoodLoggingPage(repository: repository),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        final body = find.byWidget((scaffold.body! as Center).child!);
        expect(
          tester.getRect(body).width,
          width < 960 ? width : 960,
          reason: 'Food logging width at $width dp',
        );
        expect(tester.takeException(), isNull);
      }

      for (final width in [390.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 900);
        final repository = _ResponsiveNutritionRepository();
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NutritionProfile>(
              create: (_) => NutritionProfile(repository: repository),
              child: LogEntryPage(date: DateTime(2026, 10, 5)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        final body = find.byWidget((scaffold.body! as Center).child!);
        expect(
          tester.getRect(body).width,
          width < 960 ? width : 960,
          reason: 'Log entry width at $width dp',
        );
        expect(tester.takeException(), isNull);
      }

      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FoodCustomizationPage(initialName: 'Test oats'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(SingleChildScrollView).first).width,
        760,
        reason: 'Food editor width at 1440 dp',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

void _expectStatCardRole(
  WidgetTester tester,
  String label,
  Color surface,
  Color foreground,
) {
  final textFinder = find.text(label);
  expect(textFinder, findsOneWidget, reason: label);
  final text = tester.widget<Text>(textFinder);
  expect(text.style?.color, foreground, reason: label);
  final cardFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(Container),
  ).first;
  final decoration = tester.widget<Container>(cardFinder).decoration;
  expect((decoration as BoxDecoration).color, surface, reason: label);
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final brighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (brighter + 0.05) / (darker + 0.05);
}

class _ResponsiveNutritionRepository extends AppRepository {
  _ResponsiveNutritionRepository()
    : catalog = FoodCatalogRepository(source: _EmptyFoodCatalogSource()),
      super();

  final FoodCatalogRepository catalog;

  @override
  FoodCatalogRepository get foodCatalog => catalog;

  @override
  Future<void> seedNutrientsIfEmpty() async {
  }

  @override
  Future<List<GymProfile>> fetchAllProfiles() async {
    return [
      GymProfile(id: 1, name: 'Test profile', createdAt: DateTime(2026)),
    ];
  }

  @override
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async {
    return DayTotals(profileId: profileId, date: date);
  }

  @override
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async {
    return null;
  }

  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async {
    return <DiaryEntryWithItem>[];
  }

  @override
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async {
    return const [];
  }

  @override
  Future<List<Food>> getRecentFoods(int profileId, {int limit = 20}) async =>
      const [];

  @override
  Future<List<Recipe>> getRecentRecipes(
    int profileId, {
    int limit = 20,
  }) async => const [];
}

class _EmptyFoodCatalogSource implements FoodCatalogSource {
  @override
  Future<Map<String, double>> calcForPortion({
    required int foodId,
    required int portionId,
    double quantity = 1,
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
