import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/weight_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final theme in [
    AppThemeFactory.light(AppThemeFamily.neoBrutalism),
    AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
  ]) {
    for (final complete in [false, true]) {
      testWidgets('${theme.brightness} workout readable, complete=$complete', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);
        final exercise = WeightExercise(
          name: 'Squat',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 100, reps: 5)],
          completedParents: complete ? {0} : <int>{},
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: units,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: WeightCard(
                    exercise: exercise,
                    addSetKey: const ValueKey('neo-readability-add-set'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final card = tester.widget<Card>(find.byType(Card));
        final strings = AppLocalizations.of(
          tester.element(find.byType(WeightCard)),
        );
        final count = tester.widget<Text>(
          find.text(strings.weightCardSetsDone(complete ? 1 : 0, 1)),
        );
        _expectReadable(count.style!.color!, card.color!);
        if (complete) {
          final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
          _expectReadable(icon.color!, card.color!);
        }
        final expand = find.byIcon(Icons.keyboard_arrow_down);
        if (expand.evaluate().isNotEmpty) {
          await tester.tap(expand);
          await tester.pump();
        }
        final fields = find.byType(TextFormField);
        expect(fields, findsWidgets);
        for (final element in fields.evaluate()) {
          final fieldTheme = Theme.of(element);
          // Transparent input fill exposes the peach/green workout surface.
          expect(fieldTheme.inputDecorationTheme.fillColor, Colors.transparent);
          final editable = tester.widget<EditableText>(
            find.descendant(
              of: find.byWidget(element.widget),
              matching: find.byType(EditableText),
            ),
          );
          _expectReadable(editable.style.color!, card.color!);
          _expectReadable(
            fieldTheme.inputDecorationTheme.labelStyle!.color!,
            card.color!,
          );
          expect(
            fieldTheme.inputDecorationTheme.floatingLabelBehavior,
            FloatingLabelBehavior.always,
          );
          expect(
            fieldTheme.inputDecorationTheme.floatingLabelStyle!.fontSize,
            12,
          );
        }
        expect(find.text(strings.weightLabel('lbs')), findsOneWidget);
        final setLabel = tester.widget<Text>(
          find.text(strings.weightSetLabel(1)),
        );
        expect(setLabel.style?.color, theme.semanticColors.onWorkoutContainer);
        final addSetButton = tester.widget<TextButton>(
          find.byKey(const ValueKey('neo-readability-add-set')),
        );
        expect(
          addSetButton.style?.foregroundColor?.resolve(<WidgetState>{}),
          theme.semanticColors.onWorkoutContainer,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('Neo WeightCard uses structured set-row geometry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);

    final theme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
    final exercise = WeightExercise(
      name: 'Squat',
      equipment: 'Barbell',
      sets: [
        ExerciseSet(weight: 100, reps: 5),
        ExerciseSet(weight: 100, reps: 5),
      ],
      completedParents: {0},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: units,
        child: MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: WeightCard(exercise: exercise)),
          ),
        ),
      ),
    );
    await tester.pump();

    final expand = find.byIcon(Icons.keyboard_arrow_down);
    if (expand.evaluate().isNotEmpty) {
      await tester.tap(expand);
      await tester.pump();
    }

    final card = tester.widget<Card>(find.byType(Card));
    final cardShape = card.shape! as RoundedRectangleBorder;
    expect(cardShape.borderRadius, theme.shapeTokens.compact);
    expect(card.color, theme.semanticColors.workoutContainer);

    final completedRow = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == theme.semanticColors.workoutSetCompleted &&
            decoration.borderRadius == BorderRadius.zero;
      }),
    );
    final completedDecoration = completedRow.decoration! as BoxDecoration;
    expect(completedDecoration.color, theme.semanticColors.workoutSetCompleted);
    expect(
      theme.semanticColors.workoutExerciseCompleted.computeLuminance(),
      lessThan(theme.semanticColors.workoutSetCompleted.computeLuminance()),
    );
    final completedBorder = completedDecoration.border! as Border;
    expect(completedBorder.left.width, 3);
    expect(completedBorder.top.width, 1);
    expect(
      completedDecoration.boxShadow!.single.offset,
      theme.effectTokens.completedSetShadowOffset,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Divider && widget.height == 1,
      ),
      findsOneWidget,
    );
  });
}

void _expectReadable(Color foreground, Color background) {
  final ink = Color.alphaBlend(foreground, background).computeLuminance();
  final fill = background.computeLuminance();
  final contrast = (math.max(ink, fill) + 0.05) / (math.min(ink, fill) + 0.05);
  expect(contrast, greaterThanOrEqualTo(4.5));
}
