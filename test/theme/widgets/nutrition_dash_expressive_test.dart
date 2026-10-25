import 'dart:ui' show Tristate;

import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/expressive_nutrition_summary.dart';
import 'package:env_test/widgets/nutrition_circle_details.dart';
import 'package:env_test/widgets/nutrition_dash.dart';
import 'package:env_test/widgets/rounded_progress_indicator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

const _summary = NutritionDash(
  caloriesConsumed: 1350,
  calorieGoal: 2200,
  proteinConsumed: 86,
  proteinTarget: 150,
  carbConsumed: 142,
  carbTarget: 250,
  fatConsumed: 48,
  fatTarget: 70,
);

Widget _host(
  ThemeData theme, {
  Widget summary = _summary,
  double textScale = 1,
  bool tickerEnabled = true,
  bool disableAnimations = false,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  theme: theme,
  locale: locale,
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
    ),
    child: child!,
  ),
  home: AppExpressiveDestinationTheme(
    family: AppExpressiveDestinationFamily.nutrition,
    child: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TickerMode(enabled: tickerEnabled, child: summary),
        ),
      ),
    ),
  ),
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Nutrition view buttons combine selection and action ${brightness.name}',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          final theme = brightness == Brightness.light
              ? ExpressiveThemeDefinition.light()
              : ExpressiveThemeDefinition.dark();
          await tester.pumpWidget(_host(theme));
          await tester.pumpAndSettle();
          SemanticsData buttonData(int index) {
            final control = find.byKey(
              ValueKey('nutrition-display-mode-$index'),
            );
            return tester
                .getSemantics(
                  find
                      .ancestor(
                        of: control,
                        matching: find.byType(MergeSemantics),
                      )
                      .first,
                )
                .getSemanticsData();
          }

          expect(buttonData(0).tooltip, 'Ring view');
          expect(buttonData(0).flagsCollection.isSelected, Tristate.isTrue);
          expect(buttonData(0).hasAction(SemanticsAction.tap), isTrue);
          expect(buttonData(1).flagsCollection.isSelected, Tristate.isFalse);
          await tester.tap(
            find.byKey(const ValueKey('nutrition-display-mode-1')),
          );
          await tester.pumpAndSettle();
          expect(buttonData(0).flagsCollection.isSelected, Tristate.isFalse);
          expect(buttonData(1).tooltip, 'Bar view');
          expect(buttonData(1).flagsCollection.isSelected, Tristate.isTrue);
          expect(buttonData(1).hasAction(SemanticsAction.tap), isTrue);
          expect(tester.takeException(), isNull);
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets('Nutrition rings replay on page entry in ${brightness.name}', (
      tester,
    ) async {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      const targets = [1350 / 2200, 86 / 150, 142 / 250, 48 / 70];
      List<double> progress() => tester
          .widgetList<RoundedProgressIndicator>(
            find.byType(RoundedProgressIndicator),
          )
          .map((ring) => ring.progress)
          .toList();

      await tester.pumpWidget(_host(theme));
      expect(progress(), everyElement(0));
      expect(find.text('1350'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final midway = progress();
      for (var i = 0; i < targets.length; i++) {
        expect(midway[i], greaterThan(0));
        expect(midway[i], lessThan(targets[i]));
      }
      // A normal dependency rebuild must not restart the entry animation.
      await tester.pumpWidget(_host(theme, textScale: 1.05));
      expect(progress(), orderedEquals(midway));
      await tester.pumpAndSettle();
      expect(progress(), orderedEquals(targets));

      final originalState = tester.state(
        find.byType(ExpressiveNutritionSummary),
      );
      await tester.pumpWidget(_host(theme, tickerEnabled: false));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(_host(theme));
      expect(
        tester.state(find.byType(ExpressiveNutritionSummary)),
        originalState,
      );
      expect(progress(), everyElement(0));
      await tester.pumpAndSettle();
      expect(progress(), orderedEquals(targets));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Nutrition rings respect reduced motion in ${brightness.name}',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(_host(theme, disableAnimations: true));
        expect(
          tester
              .widgetList<RoundedProgressIndicator>(
                find.byType(RoundedProgressIndicator),
              )
              .map((ring) => ring.progress),
          orderedEquals([1350 / 2200, 86 / 150, 142 / 250, 48 / 70]),
        );
        await tester.pump(const Duration(milliseconds: 450));
        expect(
          tester
              .widgetList<RoundedProgressIndicator>(
                find.byType(RoundedProgressIndicator),
              )
              .map((ring) => ring.progress),
          orderedEquals([1350 / 2200, 86 / 150, 142 / 250, 48 / 70]),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('Nutrition summary keeps views usable in ${brightness.name}', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final (width, scale) in [
        (390.0, 1.0),
        (320.0, 2.0),
        (600.0, 1.3),
        (1000.0, 1.0),
      ]) {
        await tester.binding.setSurfaceSize(Size(width, 900));
        await tester.pumpWidget(_host(theme, textScale: scale));
        await tester.pumpAndSettle();
        expect(find.text('1350'), findsOneWidget);
        expect(find.text('of 2200 kcal'), findsOneWidget);
        final rings = tester
            .widgetList<RoundedProgressIndicator>(
              find.byType(RoundedProgressIndicator),
            )
            .toList();
        expect(
          rings.map((ring) => ring.progress),
          orderedEquals([1350 / 2200, 86 / 150, 142 / 250, 48 / 70]),
        );
        expect(rings.first.size, greaterThanOrEqualTo(190));
        expect(
          rings.skip(1).map((ring) => ring.size),
          everyElement(inInclusiveRange(88, 112)),
          reason: '$width dp at $scale text: ${rings.map((ring) => ring.size)}',
        );
        final caloriesPanel = tester.getSize(
          find.byKey(const ValueKey('nutrition-panel-Calories')),
        );
        final proteinPanel = tester.getSize(
          find.byKey(const ValueKey('nutrition-panel-Protein')),
        );
        if (scale <= 1.4) {
          expect(caloriesPanel.width, greaterThan(proteinPanel.width * 2.5));
          expect(caloriesPanel.height, greaterThan(proteinPanel.height));
        } else {
          expect(proteinPanel.width, closeTo(caloriesPanel.width, 1));
        }
        expect(find.textContaining('remaining'), findsNothing);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('Carbs'), findsOneWidget);
        expect(find.text('Fat'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: '$width dp at $scale text',
        );

        for (final view in ['Bar view', 'Summary view', 'Ring view']) {
          await tester.ensureVisible(find.byTooltip(view));
          await tester.tap(find.byTooltip(view));
          await tester.pumpAndSettle();
          expect(find.text('of 2200 kcal'), findsOneWidget);
          if (view == 'Bar view') {
            final card = find.byKey(const ValueKey('nutrition-panel-Calories'));
            final shape =
                (tester.widget<Container>(card).decoration as BoxDecoration)
                    .borderRadius!
                    .resolve(TextDirection.ltr)
                    .toRRect(tester.getRect(card));
            final meterBounds = tester
                .getRect(find.byKey(const ValueKey('nutrition-meter-Calories')))
                .deflate(1);
            for (final point in [
              meterBounds.topLeft,
              meterBounds.topRight,
              meterBounds.bottomLeft,
              meterBounds.bottomRight,
            ]) {
              expect(
                shape.contains(point),
                isTrue,
                reason: 'Calorie meter stays inside the card curve',
              );
            }
            expect(
              tester
                  .getSize(
                    find.byKey(const ValueKey('nutrition-meter-Calories')),
                  )
                  .height,
              greaterThanOrEqualTo(40),
            );
            for (final nutrient in ['Protein', 'Carbs', 'Fat']) {
              final meter = tester.getSize(
                find.byKey(ValueKey('nutrition-meter-$nutrient')),
              );
              expect(meter.height, greaterThanOrEqualTo(40));
              expect(meter.width, greaterThanOrEqualTo(88));
            }
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '$view at $width dp / $scale',
          );
        }

        final pages = find.byType(PageView);
        await tester.ensureVisible(pages);
        await tester.drag(pages, Offset(-width, 0));
        await tester.pumpAndSettle();
        expect(tester.widget<PageView>(pages).controller!.page, 1);
        await tester.ensureVisible(find.byTooltip('Ring view'));
        await tester.tap(find.byTooltip('Ring view'));
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets(
    'Nutrition summary distinguishes missing goals and exceeded goals',
    (tester) async {
      for (final goal in [0, 1000]) {
        await tester.pumpWidget(
          _host(
            ExpressiveThemeDefinition.light(),
            summary: NutritionDash(
              caloriesConsumed: 1350,
              calorieGoal: goal,
              proteinConsumed: 86,
              proteinTarget: 0,
              carbConsumed: 142,
              carbTarget: 0,
              fatConsumed: 48,
              fatTarget: 0,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('1350'), findsOneWidget);
        expect(
          find.text(goal == 0 ? 'kcal · No goal set' : 'of 1000 kcal'),
          findsOneWidget,
        );
        expect(find.text('g · No goal set'), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Bar and compact views center values and show low progress clearly',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 900));
      const summary = NutritionDash(
        caloriesConsumed: 1,
        calorieGoal: 10000,
        proteinConsumed: 1,
        proteinTarget: 10000,
        carbConsumed: 0,
        carbTarget: 10000,
        fatConsumed: 0,
        fatTarget: 0,
      );

      for (final theme in [
        ExpressiveThemeDefinition.light(),
        ExpressiveThemeDefinition.dark(),
      ]) {
        await tester.pumpWidget(_host(theme, summary: summary));
        await tester.pumpAndSettle();
        for (var index = 0; index < 3; index++) {
          expect(
            tester
                .getSize(find.byKey(ValueKey('nutrition-display-mode-$index')))
                .shortestSide,
            greaterThanOrEqualTo(48),
          );
        }

        await tester.tap(find.byTooltip('Bar view'));
        await tester.pumpAndSettle();
        final caloriesPanel = tester.widget<Container>(
          find.byKey(const ValueKey('nutrition-panel-Calories')),
        );
        expect((caloriesPanel.decoration! as BoxDecoration).border, isNotNull);
        for (final nutrient in ['Calories', 'Protein', 'Carbs', 'Fat']) {
          expect(
            tester.widget<Text>(find.text(nutrient)).textAlign,
            TextAlign.center,
          );
        }
        final calorieTrack = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('nutrition-meter-track-Calories')),
        );
        final proteinTrack = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('nutrition-meter-track-Protein')),
        );
        expect(calorieTrack.color, isNot(proteinTrack.color));
        final smallProteinFill = tester.getSize(
          find.byKey(const ValueKey('nutrition-meter-fill-Protein')),
        );
        expect(smallProteinFill.width, greaterThan(0));
        expect(smallProteinFill.width, lessThanOrEqualTo(5));
        expect(smallProteinFill.height, lessThanOrEqualTo(5));
        expect(
          find.byKey(const ValueKey('nutrition-meter-fill-Carbs')),
          findsNothing,
        );
        for (final nutrient in ['Calories', 'Protein', 'Carbs', 'Fat']) {
          expect(
            tester
                .getSize(find.byKey(ValueKey('nutrition-meter-$nutrient')))
                .height,
            44,
          );
        }

        final tokens = Theme.of(
          tester.element(find.byType(ExpressiveNutritionSummary)),
        ).extension<AppExpressiveDestinationTokens>()!;
        final outerBar = tester.widget<Material>(
          find.byKey(const ValueKey('nutrition-action-bar-material')),
        );
        expect(outerBar.elevation, lessThanOrEqualTo(2));
        for (final (index, expectedSurface) in [
          (0, tokens.surfaceTertiary),
          (2, tokens.surfaceAccent),
        ]) {
          final action = find.byKey(ValueKey('nutrition-action-$index'));
          final material = tester.widget<Material>(
            find.descendant(of: action, matching: find.byType(Material)),
          );
          expect(material.color, isNot(expectedSurface));
          expect(
            tester
                .getSize(find.text(index == 0 ? 'Pantry Log' : 'Plan Meal'))
                .height,
            greaterThan(0),
          );
        }
        final addMeal = tester.widget<Material>(
          find.descendant(
            of: find.byKey(const ValueKey('nutrition-action-1')),
            matching: find.byType(Material),
          ),
        );
        expect(addMeal.color, tokens.actionPrimary);

        await tester.tap(find.byTooltip('Summary view'));
        await tester.pumpAndSettle();
        for (final label in ['Calories', 'Protein', 'Carbs', 'Fat']) {
          expect(
            tester.widget<Text>(find.text(label)).textAlign,
            TextAlign.center,
          );
        }
        final compactPanel = tester.widget<Container>(
          find.byKey(const ValueKey('nutrition-panel-Protein')),
        );
        expect((compactPanel.decoration! as BoxDecoration).border, isNotNull);

        await tester.tap(find.byTooltip('Ring view'));
        await tester.pumpAndSettle();
        final ringPanel = tester.widget<Container>(
          find.byKey(const ValueKey('nutrition-panel-Calories')),
        );
        expect((ringPanel.decoration! as BoxDecoration).border, isNull);
        expect(
          tester.widget<Text>(find.text('Calories')).textAlign,
          TextAlign.center,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Classic and Neo retain their original nutrition charts', (
    tester,
  ) async {
    for (final theme in [
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.light(),
    ]) {
      await tester.pumpWidget(_host(theme));
      await tester.pumpAndSettle();
      expect(find.byType(ExpressiveNutritionSummary), findsNothing);
      expect(find.byType(NutritionCircleDetails), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Large totals, reached goals, and unset goals remain explicit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _host(
        ExpressiveThemeDefinition.dark(),
        textScale: 2,
        summary: const NutritionDash(
          caloriesConsumed: 135000,
          calorieGoal: 100000,
          proteinConsumed: 165,
          proteinTarget: 150,
          carbConsumed: 80,
          carbTarget: 80,
          fatConsumed: 0,
          fatTarget: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('of 100000 kcal'), findsOneWidget);
    expect(find.text('of 150 g'), findsOneWidget);
    expect(find.text('of 80 g'), findsOneWidget);
    expect(find.text('g · No goal set'), findsOneWidget);
    expect(
      tester
          .widgetList<RoundedProgressIndicator>(
            find.byType(RoundedProgressIndicator),
          )
          .map((ring) => ring.progress),
      [1, 1, 1, 0],
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byTooltip('Bar view'));
    await tester.tap(find.byTooltip('Bar view'));
    await tester.pumpAndSettle();
    expect(find.text('135000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Unavailable actions do not open placeholders and have disabled semantics',
    (tester) async {
      await tester.pumpWidget(_host(ExpressiveThemeDefinition.light()));
      await tester.pumpAndSettle();
      expect(find.text('Unavailable'), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.enabled == false,
        ),
        findsNWidgets(2),
      );
      for (final label in ['Pantry Log', 'Plan Meal']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(ExpressiveNutritionSummary), findsOneWidget);
      }
      final addMeal = tester.widget<InkWell>(
        find
            .ancestor(of: find.text('Add Meal'), matching: find.byType(InkWell))
            .first,
      );
      expect(addMeal.onTap, isNotNull);
    },
  );

  testWidgets(
    'Localized summaries reflow across narrow widths and large text',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final locale in AppLocalizations.supportedLocales) {
        for (final (width, scale) in [
          (320.0, 1.0),
          (320.0, 2.0),
          (600.0, 1.3),
        ]) {
          await tester.binding.setSurfaceSize(Size(width, 900));
          await tester.pumpWidget(
            _host(
              ExpressiveThemeDefinition.dark(),
              locale: locale,
              textScale: scale,
            ),
          );
          await tester.pumpAndSettle();
          final strings = AppLocalizations.of(
            tester.element(find.byType(ExpressiveNutritionSummary)),
          );
          expect(find.text(strings.nutritionSummaryTitle), findsOneWidget);
          expect(find.text(strings.nutritionPantryLogAction), findsOneWidget);
          for (final view in [
            strings.nutritionBarView,
            strings.nutritionSummaryView,
            strings.nutritionRingView,
          ]) {
            await tester.ensureVisible(find.byTooltip(view));
            await tester.tap(find.byTooltip(view));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$locale $width dp / $scale text / $view',
            );
          }
        }
      }
    },
  );

  testWidgets(
    'Screen reader announces actual totals, targets, and missing goals',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          ExpressiveThemeDefinition.light(),
          summary: const NutritionDash(
            caloriesConsumed: 2300,
            calorieGoal: 2000,
            proteinConsumed: 80,
            proteinTarget: 0,
            carbConsumed: 100,
            carbTarget: 150,
            fatConsumed: 30,
            fatTarget: 60,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Calories: 2300 of 2000 kcal consumed.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Protein: 80 g consumed. No daily goal set.'),
        findsOneWidget,
      );
      for (final tooltip in ['Ring view', 'Bar view', 'Summary view']) {
        expect(
          tester.getSize(find.byTooltip(tooltip)).shortestSide,
          greaterThanOrEqualTo(48),
        );
      }
      semantics.dispose();
    },
  );
}
