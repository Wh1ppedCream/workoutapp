import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_theme_ready.dart';

void main() {
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
  };

  for (final entry in themes.entries) {
    testWidgets('${entry.key} food customization expansion recipes', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: entry.value,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FoodCustomizationPage(initialName: 'Test oats'),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(FoodCustomizationPage));
      final strings = AppLocalizations.of(pageContext);
      final nutrition = pageContext.nutritionTokens;
      final cards =
          tester
              .widgetList<TonosThemeReadyCard>(find.byType(TonosThemeReadyCard))
              .toList();
      final sectionCards =
          cards.where((card) {
            final shape = card.shape;
            return shape is RoundedRectangleBorder &&
                shape.borderRadius == nutrition.sectionShape;
          }).toList();

      expect(sectionCards, hasLength(4));
      for (final card in sectionCards) {
        final shape = card.shape! as RoundedRectangleBorder;
        expect(shape.side.color, nutrition.foodBorder);
      }

      final usualPortionTitle = find.text(
        strings.foodCustomizationUsualPortion,
      );
      await tester.ensureVisible(usualPortionTitle);
      await tester.tap(usualPortionTitle);
      await tester.pumpAndSettle();

      final portionCards =
          tester
              .widgetList<TonosThemeReadyCard>(find.byType(TonosThemeReadyCard))
              .where((card) {
                final shape = card.shape;
                return shape is RoundedRectangleBorder &&
                    shape.borderRadius == nutrition.portionShape;
              })
              .toList();
      expect(portionCards, hasLength(2));

      final densityHelp = tester.widget<Text>(
        find.text(strings.foodCustomizationDensityHelp),
      );
      expect(densityHelp.style?.fontSize, 12);
      expect(densityHelp.style?.color, nutrition.densityHelp);

      TextStyle? titleStyle(String title) =>
          tester.widget<Text>(find.text(title)).style;

      expect(
        titleStyle(strings.foodCustomizationMacronutrients)?.fontWeight,
        FontWeight.w600,
      );
      expect(
        titleStyle(strings.foodCustomizationMicronutrients)?.fontWeight,
        FontWeight.w600,
      );
      expect(
        titleStyle(strings.foodCustomizationAdditionalComponents)?.fontWeight,
        FontWeight.w600,
      );
      expect(
        titleStyle(strings.foodCustomizationPortionInfo)?.fontWeight,
        FontWeight.w600,
      );
      expect(
        titleStyle(strings.foodCustomizationBasisPortion)?.fontWeight,
        FontWeight.w500,
      );
      expect(
        titleStyle(strings.foodCustomizationUsualPortion)?.fontWeight,
        FontWeight.w500,
      );

      final expansionTiles = find.byType(ExpansionTile);
      expect(expansionTiles, findsNWidgets(9));
      for (final element in expansionTiles.evaluate()) {
        expect(Theme.of(element).dividerColor, Colors.transparent);
      }

      final basisTitle = find.text(strings.foodCustomizationBasisPortion);
      expect(Theme.of(tester.element(basisTitle)).listTileTheme.dense, isTrue);

      final alanine = find.text('Alanine (g)');
      expect(alanine, findsNothing);
      final proteinBreakdown = find.text('Protein Components');
      await tester.ensureVisible(proteinBreakdown);
      await tester.tap(proteinBreakdown);
      await tester.pumpAndSettle();
      expect(alanine, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
