import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/widgets/nutrition_text_details.dart';

void main() {
  const scale = 1.25;

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode ValueCard retains its nutrition border recipe', (
        tester,
      ) async {
        const overrideBorder = Color(0xFFFF8800);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            home: const Scaffold(
              body: Center(
                child: ValueCard(
                  label: 'Calories',
                  value: '250 kcal',
                  scale: scale,
                ),
              ),
            ),
          ),
        );

        final card = tester
            .widgetList<Container>(find.byType(Container))
            .singleWhere((container) => container.child is Column);
        final nutritionTokens = theme.extension<AppNutritionTokens>()!;
        expect(card.padding, const EdgeInsets.all(8 * scale));
        expect(
          card.decoration,
          BoxDecoration(
            border: Border.all(color: nutritionTokens.textDetailsBorder),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
        );

        final labelFinder = find.text('Calories');
        final valueFinder = find.text('250 kcal');
        final renderedTheme = Theme.of(tester.element(labelFinder));
        final labelBase = renderedTheme.textTheme.bodySmall!;
        final valueBase = renderedTheme.textTheme.titleMedium!;
        expect(
          tester.widget<Text>(labelFinder).style,
          labelBase.copyWith(fontSize: (labelBase.fontSize ?? 14) * scale),
        );
        expect(
          tester.widget<Text>(valueFinder).style,
          valueBase.copyWith(fontSize: (valueBase.fontSize ?? 18) * scale),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            home: const Scaffold(
              body: Center(
                child: ValueCard(
                  label: 'Calories',
                  value: '250 kcal',
                  scale: scale,
                  borderColor: overrideBorder,
                ),
              ),
            ),
          ),
        );
        final overrideCard = tester
            .widgetList<Container>(find.byType(Container))
            .singleWhere((container) => container.child is Column);
        final overrideDecoration = overrideCard.decoration! as BoxDecoration;
        expect(overrideDecoration.border!.top.color, overrideBorder);
        expect(
          overrideDecoration.borderRadius,
          BorderRadius.circular(8 * scale),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
