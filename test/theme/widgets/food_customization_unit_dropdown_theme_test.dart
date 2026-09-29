import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';

void main() {
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
  };

  for (final entry in themes.entries) {
    testWidgets('${entry.key} food portion unit dropdown uses Material roles', (
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
      final theme = Theme.of(pageContext);
      final strings = AppLocalizations.of(pageContext);
      await tester.ensureVisible(
        find.text(strings.foodCustomizationPortionInfo),
      );

      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      expect(dropdownFinder, findsOneWidget);
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        dropdownFinder,
      );
      final decoration = dropdown.decoration;
      expect(decoration.labelText, strings.foodCustomizationUnit);
      expect(decoration.isDense, isTrue);
      expect(
        decoration.contentPadding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
      expect(decoration.border, isA<OutlineInputBorder>());
      final buttonFinder = find.descendant(
        of: dropdownFinder,
        matching: find.byType(DropdownButton<String>),
      );
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<DropdownButton<String>>(buttonFinder);
      expect(button.isExpanded, isTrue);
      expect(button.dropdownColor, isNull);
      expect(button.style, isNull);

      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      final optionFinder = find.text('kilogram (kg)').last;
      expect(optionFinder, findsOneWidget);
      final optionContext = tester.element(optionFinder);
      final optionInk = DefaultTextStyle.of(optionContext).style.color;
      expect(optionInk, theme.colorScheme.onSurface);
      expect(
        _contrastRatio(optionInk!, theme.canvasColor),
        greaterThanOrEqualTo(4.5),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter =
      firstLuminance > secondLuminance ? firstLuminance : secondLuminance;
  final darker =
      firstLuminance > secondLuminance ? secondLuminance : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
