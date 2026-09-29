import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/nutrition/food_logging_page.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_support.dart';
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

List<TextSpan> _descendantTextSpans(InlineSpan span) {
  final result = <TextSpan>[];
  void visit(InlineSpan current) {
    if (current is! TextSpan) return;
    for (final child in current.children ?? const <InlineSpan>[]) {
      if (child is TextSpan) {
        result.add(child);
        visit(child);
      }
    }
  }

  visit(span);
  return result;
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeRepository repository,
  NutritionProfile profile,
  ThemeData theme,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      localizationsDelegates: tonosLocalizationDelegates,
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
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
  };

  for (final themeEntry in themes.entries) {
    testWidgets('${themeEntry.key} Log Entry owns nutrition recipes', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final date = DateTime(2020, 1, 2);
      final repository = _FakeRepository(_food(), []);
      void addEntry({
        required int id,
        required String name,
        required MealType mealType,
        required int hour,
      }) {
        repository.diary.add(
          DiaryEntryWithItem(
            itemName: name,
            entry: DiaryEntry(
              id: id,
              profileId: 1,
              date: date,
              mealType: mealType,
              foodId: 7,
              quantity: 2,
              loggedAt: date.add(Duration(hours: hour)),
              kcalSnapshot: 200,
              proteinGSnapshot: 20,
              carbGSnapshot: 40,
              fatGSnapshot: 10,
            ),
          ),
        );
      }

      addEntry(
        id: 1,
        name: 'Saved oats',
        mealType: MealType.breakfast,
        hour: 8,
      );
      addEntry(id: 2, name: 'Saved lunch', mealType: MealType.lunch, hour: 12);
      addEntry(
        id: 3,
        name: 'Saved dinner',
        mealType: MealType.dinner,
        hour: 18,
      );
      addEntry(id: 4, name: 'Saved snack', mealType: MealType.snack, hour: 21);

      final profile = NutritionProfile(repository: repository);
      await tester.pumpWidget(
        MaterialApp(
          theme: themeEntry.value,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider<NutritionProfile>(
            create: (_) => profile,
            child: LogEntryPage(date: date),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(LogEntryPage));
      final strings = AppLocalizations.of(context);
      final nutrition = context.nutritionTokens;
      final scheme = Theme.of(context).colorScheme;
      expect(
        find.text(MaterialLocalizations.of(context).formatMediumDate(date)),
        findsOneWidget,
      );
      expect(profile.error, isNull);
      expect(profile.day, date);
      expect(profile.mealsWithItems.map((row) => row.itemName), [
        'Saved oats',
        'Saved lunch',
        'Saved dinner',
        'Saved snack',
      ]);

      final decorations =
          tester
              .widgetList<Container>(find.byType(Container))
              .map((container) => container.decoration)
              .whereType<BoxDecoration>()
              .toList();
      final miniStatCards = decorations.where(
        (decoration) =>
            decoration.borderRadius == nutrition.quantityShape &&
            decoration.border is Border &&
            (decoration.border! as Border).top.color == nutrition.foodBorder,
      );
      expect(miniStatCards, hasLength(4));
      final timelineRules = decorations.where(
        (decoration) =>
            decoration.border is Border &&
            (decoration.border! as Border).top.color == nutrition.logGrid &&
            (decoration.border! as Border).top.width == 1,
      );
      expect(timelineRules, isNotEmpty);

      final chipColors = <Color>{
        scheme.primaryContainer,
        scheme.tertiaryContainer,
        scheme.secondaryContainer,
        scheme.errorContainer,
      };
      final chipMaterials =
          tester
              .widgetList<Material>(find.byType(Material))
              .where(
                (material) =>
                    chipColors.contains(material.color) &&
                    material.shape is RoundedRectangleBorder &&
                    (material.shape! as RoundedRectangleBorder).borderRadius ==
                        nutrition.sectionShape,
              )
              .toList();
      expect(chipMaterials, hasLength(4));
      expect(
        chipMaterials.map((material) => material.color),
        unorderedEquals(chipColors),
      );

      final mealForegrounds = <MealType, Color>{
        MealType.breakfast: scheme.onPrimaryContainer,
        MealType.lunch: scheme.onTertiaryContainer,
        MealType.dinner: scheme.onSecondaryContainer,
        MealType.snack: scheme.onErrorContainer,
      };
      for (final entry in <(String, MealType)>[
        ('Saved oats', MealType.breakfast),
        ('Saved lunch', MealType.lunch),
        ('Saved dinner', MealType.dinner),
        ('Saved snack', MealType.snack),
      ]) {
        final summary = strings.nutritionMacroSummary(200, 20, 40, 10);
        final richText = tester.widget<RichText>(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText() == '${entry.$1}\n$summary',
          ),
        );
        final spans = _descendantTextSpans(richText.text);
        final foreground = mealForegrounds[entry.$2]!;
        final titleSpan = spans.singleWhere(
          (span) => span.text == '${entry.$1}\n',
        );
        final summarySpan = spans.singleWhere((span) => span.text == summary);
        expect(titleSpan.style?.color, foreground);
        expect(summarySpan.style?.color, foreground.withValues(alpha: 0.85));
      }

      final statTextSpans = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((richText) => _descendantTextSpans(richText.text));
      expect(
        statTextSpans.where(
          (spans) =>
              spans.any((span) => span.style?.fontWeight == FontWeight.w600),
        ),
        hasLength(4),
      );

      final summary = strings.nutritionMacroSummary(200, 20, 40, 10);
      expect(find.text('Saved oats\n$summary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final themeEntry in themes.entries) {
    testWidgets('${themeEntry.key} food logging ownership and meal behavior', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
      await _pumpPage(tester, repository, profile, themeEntry.value);

      final pageContext = tester.element(find.byType(FoodLoggingPage));
      final strings = AppLocalizations.of(pageContext);
      final nutrition = pageContext.nutritionTokens;
      final scheme = Theme.of(pageContext).colorScheme;
      final toggleButtons = tester.widget<ToggleButtons>(
        find.byType(ToggleButtons),
      );
      final usesInkRecipe = pageContext.surfaceDecorationTokens.card.outlined;
      if (usesInkRecipe) {
        expect(toggleButtons.fillColor, scheme.primary);
        expect(toggleButtons.selectedColor, scheme.onPrimary);
        expect(
          _contrastRatio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
      } else {
        expect(toggleButtons.fillColor, Theme.of(pageContext).primaryColor);
        expect(toggleButtons.selectedColor, nutrition.selectedLabel);
      }
      expect(
        toggleButtons.isSelected.where((selected) => selected),
        hasLength(1),
      );
      bool hasBorderColor(BoxDecoration decoration, Color color) =>
          decoration.border is Border &&
          (decoration.border! as Border).top.color == color;
      List<BoxDecoration> currentDecorations() =>
          tester
              .widgetList<Container>(find.byType(Container))
              .map((container) => container.decoration)
              .whereType<BoxDecoration>()
              .toList();

      final statCards = currentDecorations().where(
        (decoration) =>
            decoration.borderRadius == nutrition.compactShape &&
            hasBorderColor(decoration, nutrition.foodBorder),
      );
      expect(statCards, hasLength(4));

      final search = find.byType(TextField).last;
      await tester.enterText(search, 'Test oats');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.widgetWithText(ListTile, food.name), findsOneWidget);

      await tester.tap(findTonosTooltip(strings.foodFavorite));
      await tester.pump();
      expect(repository.favorites, contains(food.id));
      expect(findTonosTooltip(strings.foodUnfavorite), findsOneWidget);

      await tester.tap(findTonosTooltip(strings.foodEditAndAdd));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Breakfast'));
      await tester.tap(find.byType(DropdownButton<FoodPortion>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('half bowl • 100 g'));
      await tester.pump();
      final quantity = find.byType(TextFormField).first;
      await tester.enterText(quantity, '2');
      await tester.tap(find.text(strings.foodAddToPlate));
      await tester.pumpAndSettle();

      for (final meal in [MealType.lunch, MealType.dinner, MealType.snack]) {
        final mealLabel =
            '${meal.name[0].toUpperCase()}${meal.name.substring(1)}';
        await tester.tap(findTonosTooltip(strings.foodEditAndAdd));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ChoiceChip, mealLabel));
        await tester.tap(find.text(strings.foodAddToPlate));
        await tester.pumpAndSettle();
      }

      final plateDecorations = currentDecorations();
      expect(
        plateDecorations.any(
          (decoration) =>
              decoration.borderRadius == nutrition.compactShape &&
              hasBorderColor(decoration, nutrition.addFoodAction),
        ),
        isTrue,
      );

      final plateSummary = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.endsWith(' kcal') &&
            !widget.data!.contains('/'),
      );
      expect(plateSummary, findsOneWidget);
      await tester.tap(plateSummary);
      await tester.pumpAndSettle();

      final expectedMealBorders = <Color>{
        scheme.primary.withValues(alpha: 0.55),
        scheme.tertiary.withValues(alpha: 0.55),
        scheme.secondary.withValues(alpha: 0.55),
        scheme.error.withValues(alpha: 0.45),
      };
      final lineCards =
          tester.widgetList<Card>(find.byType(Card)).where((card) {
            final shape = card.shape;
            return shape is RoundedRectangleBorder &&
                shape.borderRadius == nutrition.sectionShape &&
                expectedMealBorders.contains(shape.side.color);
          }).toList();
      expect(lineCards, hasLength(4));
      expect(
        lineCards
            .map((card) => (card.shape! as RoundedRectangleBorder).side.color)
            .toSet(),
        expectedMealBorders,
      );

      final quantityButtons = currentDecorations().where(
        (decoration) =>
            decoration.borderRadius == nutrition.quantityShape &&
            hasBorderColor(decoration, nutrition.foodBorder),
      );
      expect(quantityButtons.length, greaterThanOrEqualTo(8));

      final logButtonFinder =
          find
              .ancestor(
                of: find.text(strings.foodAddAllToDiary),
                matching: find.byWidgetPredicate(
                  (widget) => widget is ElevatedButton,
                ),
              )
              .first;
      final logButton = tester.widget<ElevatedButton>(logButtonFinder);
      final logStyle = logButton.style!;
      expect(
        logStyle.padding!.resolve(const <WidgetState>{}),
        const EdgeInsets.symmetric(vertical: 14),
      );
      final logShape =
          logStyle.shape!.resolve(const <WidgetState>{})!
              as RoundedRectangleBorder;
      expect(logShape.borderRadius, nutrition.portionShape);
      expect(logShape.side.color, scheme.primary);
      expect(logShape.side.width, 1.25);

      await tester.tap(logButtonFinder);
      await tester.pumpAndSettle();
      expect(repository.logged, hasLength(4));
      expect(repository.logged.first['foodId'], food.id);
      expect(repository.logged.first['mealType'], MealType.breakfast);
      expect(repository.logged.first['portionId'], 12);
      expect(repository.logged.first['quantity'], 2.0);
      expect(repository.logged.first['gramsOverride'], isNull);
      expect(repository.logged.first['loggedGrams'], 200.0);
      expect(tester.takeException(), isNull);
    });
  }

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
          localizationsDelegates: tonosLocalizationDelegates,
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
