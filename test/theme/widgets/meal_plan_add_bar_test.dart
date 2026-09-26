import 'dart:math' as math;

import 'package:env_test/screens/nutrition/pantry_log_page.dart';
import 'package:env_test/screens/nutrition/plan_meal_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_segmented_action_bar.dart';
import 'package:env_test/widgets/meal_plan_add_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.name} ${brightness.name} meal action bar uses shared theme roles',
        (tester) async {
          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: const Scaffold(body: MealPlanAddBar()),
            ),
          );

          final bar = tester.widget<TonosSegmentedActionBar>(
            find.byType(TonosSegmentedActionBar),
          );
          final context = tester.element(find.byType(MealPlanAddBar));
          final expected = [
            ('Pantry Log', context.nutritionTokens.pantryLogSurface),
            ('Add Meal', context.nutritionTokens.addMealSurface),
            ('Plan Meal', context.nutritionTokens.planMealSurface),
          ];

          expect(bar.scale, 0.8);
          expect(bar.dividerColor, context.surfaceTokens.divider);
          expect(bar.items, hasLength(expected.length));
          for (var index = 0; index < expected.length; index++) {
            final (label, surface) = expected[index];
            final item = bar.items[index];
            expect(item.label, label);
            expect(item.semanticLabel, label);
            expect(item.backgroundColor, surface);
            expect(
              item.foregroundColor,
              tonosForegroundForSurface(context, surface),
            );
            expect(
              _contrastRatio(item.foregroundColor, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$label should remain readable on its nutrition surface',
            );
            expect(
              item.labelStyle?.fontSize,
              Theme.of(context).textTheme.bodyMedium?.fontSize,
            );
            final renderedLabel = tester.widget<Text>(find.text(label));
            expect(
              renderedLabel.style,
              item.labelStyle?.copyWith(color: item.foregroundColor),
            );
          }

          final clip = tester.widget<ClipRRect>(
            find.descendant(
              of: find.byType(TonosSegmentedActionBar),
              matching: find.byType(ClipRRect),
            ),
          );
          expect(
            clip.borderRadius,
            BorderRadius.lerp(
              BorderRadius.zero,
              theme.shapeTokens.actionBar,
              0.8,
            ),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Pantry Log and Plan Meal actions keep their destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: const Scaffold(body: MealPlanAddBar())),
    );

    await tester.tap(find.text('Pantry Log'));
    await tester.pumpAndSettle();
    expect(find.byType(PantryLogPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan Meal'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanMealPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('meal actions reflow without clipping at large text scale', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: SizedBox(width: 320, child: const MealPlanAddBar()),
              ),
            ),
          ),
        );

        final clip = tester.widget<ClipRRect>(
          find.descendant(
            of: find.byType(TonosSegmentedActionBar),
            matching: find.byType(ClipRRect),
          ),
        );
        expect(
          clip.child,
          isA<Column>(),
          reason: '${family.name} ${brightness.name}',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '${family.name} ${brightness.name}',
        );
      }
    }
  });
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = math.max(first, second).toDouble();
  final darker = math.min(first, second).toDouble();
  return (lighter + 0.05) / (darker + 0.05);
}
