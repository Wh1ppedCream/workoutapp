import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/nutrition/barcode_scanner_page.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:env_test/services/barcode_scanner_session.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/theme/widgets/tonos_theme_ready.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class _CatalogSource implements FoodCatalogSource {
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

class _DiaryRepository extends AppRepository {
  _DiaryRepository(this.entries)
    : catalog = FoodCatalogRepository(source: _CatalogSource()),
      super();

  final List<DiaryEntryWithItem> entries;
  final FoodCatalogRepository catalog;

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
  ) async => entries;

  @override
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      const [];
}

DiaryEntryWithItem _entry(int id, String name, DateTime stamp) =>
    DiaryEntryWithItem(
      entry: DiaryEntry(
        id: id,
        profileId: 1,
        date: DateTime(2026, 1, 2),
        mealType: MealType.breakfast,
        foodId: id,
        loggedAt: stamp,
        kcalSnapshot: 320,
        proteinGSnapshot: 24,
        carbGSnapshot: 37,
        fatGSnapshot: 10,
      ),
      itemName: name,
    );

class _PreviewSession implements BarcodeScannerSession {
  final StreamController<String?> _codes = StreamController.broadcast();

  @override
  Stream<String?> get codes => _codes.stream;

  @override
  bool get hasPermission => true;

  @override
  Widget buildPreview() => const ColoredBox(color: Colors.black);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> switchCamera() async {}

  @override
  Future<void> toggleTorch() async {}

  @override
  Future<void> dispose() => _codes.close();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive food customization groups tonal fields in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FoodCustomizationPage(initialName: 'Test oats'),
          ),
        );
        await tester.pumpAndSettle();

        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          brightness,
        );
        final nutrition = AppNutritionTokens.expressive(brightness);
        debugPrint(
          tester
              .widgetList<TonosThemeReadyCard>(find.byType(TonosThemeReadyCard))
              .map((card) => '${card.shape} | ${card.color}')
              .join('\n'),
        );
        expect(
          Theme.of(tester.element(find.byType(TonosFormField).first))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.nutrition,
        );
        final portionSection = tester
            .widgetList<TonosThemeReadyCard>(find.byType(TonosThemeReadyCard))
            .firstWhere(
              (card) =>
                  card.color == destination.surfaceTertiary &&
                  card.shape is RoundedRectangleBorder &&
                  (card.shape! as RoundedRectangleBorder).borderRadius ==
                      nutrition.sectionShape,
            );
        expect(portionSection.color, destination.surfaceTertiary);

        final usualPortionLabel = AppLocalizations.of(
          tester.element(find.byType(FoodCustomizationPage)),
        ).foodCustomizationUsualPortion;
        await tester.tap(find.text(usualPortionLabel));
        await tester.pumpAndSettle();

        final portionRows = tester
            .widgetList<TonosThemeReadyCard>(find.byType(TonosThemeReadyCard))
            .where((card) {
              final shape = card.shape;
              return shape is RoundedRectangleBorder &&
                  shape.borderRadius == nutrition.portionShape;
            })
            .toList();
        expect(portionRows, hasLength(2));
        expect(
          portionRows.map((card) => card.color),
          everyElement(destination.surfaceAccent),
        );

        final pageField = find.byType(TonosFormField).first;
        expect(
          Theme.of(tester.element(pageField)).inputDecorationTheme.fillColor,
          destination.surfaceSecondary,
        );
        final portionField = find.byKey(
          const PageStorageKey('portion_basis_0_grams'),
        );
        expect(portionField, findsOneWidget);
        expect(
          Theme.of(tester.element(portionField))
              .inputDecorationTheme
              .fillColor,
          destination.surfaceTertiary,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive diary date title contrasts with the nutrition header in ${brightness.name}',
      (tester) async {
        final date = DateTime(2026, 1, 2);

        await tester.pumpWidget(
          ChangeNotifierProvider<NutritionProfile>(
            create: (_) => NutritionProfile(repository: _DiaryRepository(const [])),
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: LogEntryPage(date: date),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(LogEntryPage));
        final title = MaterialLocalizations.of(pageContext).formatMediumDate(
          date,
        );
        final titleFinder = find.descendant(
          of: find.byType(AppBar),
          matching: find.text(title),
        );
        expect(titleFinder, findsOneWidget);

        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          brightness,
        );
        final titleText = tester.widget<Text>(titleFinder);
        expect(titleText.style?.color, destination.onSurfacePrimary);
        expect(
          _contrastRatio(
            destination.onSurfacePrimary,
            destination.surfacePrimary,
          ),
          greaterThanOrEqualTo(4.5),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Expressive diary separates colliding populated entries at 2x', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final day = DateTime(2026, 1, 2);
    final repository = _DiaryRepository([
      _entry(
        1,
        'Very long imported breakfast item with a detailed product name',
        DateTime(2026, 1, 2, 3, 0),
      ),
      _entry(
        2,
        'Second detailed food entry recorded five minutes later',
        DateTime(2026, 1, 2, 3, 5),
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<NutritionProfile>(
        create: (_) => NutritionProfile(repository: repository),
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: LogEntryPage(date: day),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder chipFor(String label) => find
        .ancestor(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is RichText && widget.text.toPlainText().contains(label),
          ),
          matching: find.byType(Material),
        )
        .first;
    final firstChip = chipFor('Very long imported breakfast item');
    final secondChip = chipFor('Second detailed food entry');
    final firstRect = tester.getRect(firstChip);
    final secondRect = tester.getRect(secondChip);
    expect(
      secondRect.top - firstRect.top,
      greaterThanOrEqualTo(firstRect.height),
      reason: 'Dense large-text entries move to readable chronological cards below the timeline.',
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Positioned && widget.height == 2,
      ),
      findsNWidgets(2),
      reason: 'Both records retain their exact time markers in the grid.',
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(
              'Very long imported breakfast item',
            ),
      ),
      findsOneWidget,
      reason: 'The complete long label remains in a visible detail card.',
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(
              '3:00 AM · Very long imported breakfast item',
            ),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(
              '3:05 AM · Second detailed food entry',
            ),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().contains('320'),
      ),
      findsAtLeastNWidgets(1),
      reason: 'Macro details remain visible in the detail cards.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive scanner reticle contrasts with camera black', (
    tester,
  ) async {
    final session = _PreviewSession();
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BarcodeScannerPage(session: session),
      ),
    );
    await tester.pumpAndSettle();

    final frameFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container || widget.decoration is! BoxDecoration) {
        return false;
      }
      final decoration = widget.decoration! as BoxDecoration;
      return decoration.borderRadius == BorderRadius.circular(12);
    });
    expect(
      Theme.of(tester.element(frameFinder))
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.nutrition,
    );
    final frame = tester.widget<Container>(frameFinder);
    final border = (frame.decoration! as BoxDecoration).border! as Border;
    final frameColor = border.top.color;
    final contrastAgainstBlack = (frameColor.computeLuminance() + 0.05) / 0.05;
    expect(
      contrastAgainstBlack,
      greaterThanOrEqualTo(4.5),
      reason: 'The reticle stays easy to see against the black camera preview.',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Expressive populated unit control has room at 320dp and 2x', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: FoodCustomizationPage(
          initialName: 'Oats',
          initialPortions: [
            FoodPortion(
              foodId: 1,
              measureName: 'fluid ounce (fl oz)',
              amount: 1,
              unit: 'fl oz',
              mlVolume: 30,
              listKind: 'basis',
              isDefault: true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final unitDropdown = find.byKey(
      const PageStorageKey('portion_basis_0_unit'),
    );
    await tester.ensureVisible(unitDropdown);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(unitDropdown))
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.nutrition,
    );
    final unitWidth = tester.getSize(unitDropdown).width;
    expect(
      unitWidth,
      greaterThan(160),
      reason:
          'The stacked control gives the full selected unit room to display.',
    );
    final selectedUnitLabel = find
        .descendant(
          of: unitDropdown,
          matching: find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'fluid ounce (fl oz)',
          ),
        )
        .first;
    expect(
      tester.renderObject<RenderParagraph>(selectedUnitLabel).didExceedMaxLines,
      isFalse,
      reason: 'The complete selected unit label remains visible.',
    );
    expect(tester.takeException(), isNull);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final brighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (brighter + 0.05) / (darker + 0.05);
}
