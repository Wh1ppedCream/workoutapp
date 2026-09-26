import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/screens/exercise/premade_plans_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/set_stat_chip.dart';

void main() {
  for (final brightness in Brightness.values) {
    final classic =
        brightness == Brightness.light
            ? AppThemeFactory.light(AppThemeFamily.classic)
            : AppThemeFactory.dark(AppThemeFamily.classic);

    testWidgets('$brightness plan bar preserves border and action behavior', (
      tester,
    ) async {
      var saves = 0;
      var cancels = 0;
      for (final overridden in [false, true]) {
        final theme =
            overridden
                ? classic.copyWith(
                  extensions: [
                    classic.surfaceTokens.copyWith(
                      planActionBar: Colors.orange,
                      subtleOutline: Colors.cyan,
                    ),
                  ],
                )
                : classic;
        for (final busy in [false, true]) {
          await tester.pumpWidget(
            _app(
              theme,
              OnboardingPlanActionBar(
                addedCount: 2,
                isBusy: busy,
                onCancel: () => cancels++,
                onSave: () => saves++,
              ),
            ),
          );
          final container = tester.widget<Container>(
            find.descendant(
              of: find.byType(OnboardingPlanActionBar),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).border is Border,
              ),
            ),
          );
          final decoration = container.decoration! as BoxDecoration;
          expect(
            decoration.color,
            overridden
                ? Colors.orange
                : classic.colorScheme.surface.withValues(alpha: 0.96),
          );
          expect(
            (decoration.border! as Border).top.color,
            classic.colorScheme.outlineVariant.withValues(alpha: 0.6),
          );
          final save = find.byWidgetPredicate((w) => w is FilledButton);
          final cancel = find.byType(OutlinedButton);
          expect(tester.widget<FilledButton>(save).onPressed == null, busy);
          expect(tester.widget<OutlinedButton>(cancel).onPressed == null, busy);
          if (!busy) {
            await tester.tap(save);
            await tester.tap(cancel);
          }
        }
      }
      expect(saves, 2);
      expect(cancels, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$brightness metric chip follows surface and shape overrides', (
      tester,
    ) async {
      for (final overridden in [false, true]) {
        final theme =
            overridden
                ? classic.copyWith(
                  extensions: [
                    classic.surfaceTokens.copyWith(metricChip: Colors.orange),
                    classic.shapeTokens.copyWith(
                      metric: BorderRadius.circular(3),
                    ),
                  ],
                )
                : classic;
        await tester.pumpWidget(
          _app(
            theme,
            const SizedBox(
              width: 220,
              child: SetStatChip(label: 'Sets', value: '12'),
            ),
          ),
        );
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SetStatChip),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration! as BoxDecoration;
        expect(
          decoration.color,
          overridden
              ? Colors.orange
              : classic.colorScheme.surfaceContainerHighest,
        );
        expect(
          decoration.borderRadius,
          BorderRadius.circular(overridden ? 3 : 14),
        );
        expect(find.text('12'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}

Widget _app(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);
