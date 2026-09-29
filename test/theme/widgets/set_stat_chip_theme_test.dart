import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/set_stat_chip.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode metric chip keeps its surface and shape roles', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            home: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 220,
                  child: SetStatChip(label: 'Sets', value: '12'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final chip = find.byType(SetStatChip);
        final container = tester.widget<Container>(
          find.descendant(of: chip, matching: find.byType(Container)),
        );
        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.color, theme.surfaceTokens.metricChip);
        expect(decoration.borderRadius, theme.shapeTokens.metric);
        expect(decoration.border, isNull);
        expect(decoration.boxShadow, isNull);

        final labelContext = tester.element(find.text('Sets'));
        final expectedForeground =
            family == AppThemeFamily.neoBrutalism
                ? tonosForegroundForSurface(
                  labelContext,
                  theme.surfaceTokens.metricChip,
                )
                : theme.colorScheme.onSurface;
        for (final textFinder in [find.text('Sets'), find.text('12')]) {
          final text = tester.widget<Text>(textFinder);
          final actualStyle =
              tester.renderObject<RenderParagraph>(textFinder).text.style;
          final defaultStyle =
              DefaultTextStyle.of(tester.element(textFinder)).style;
          expect(actualStyle, defaultStyle.merge(text.style));
          expect(actualStyle?.color, expectedForeground);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
