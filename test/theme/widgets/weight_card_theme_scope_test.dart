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
  for (final family in AppThemeFamily.values) {
    for (final theme in [
      AppThemeFactory.light(family),
      AppThemeFactory.dark(family),
    ]) {
      testWidgets(
        '${family.name} ${theme.brightness} WeightCard scopes editable fields',
        (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(units.dispose);

          final exercise = WeightExercise(
            name: 'Squat',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 100, reps: 5)],
          );

          await tester.pumpWidget(
            ChangeNotifierProvider<UnitPreferenceProvider>.value(
              value: units,
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: WeightCard(exercise: exercise),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          final expand = find.byIcon(Icons.keyboard_arrow_down);
          if (expand.evaluate().isNotEmpty) {
            await tester.tap(expand);
            await tester.pump(const Duration(milliseconds: 500));
          }

          final fields = find.byType(TextFormField);
          expect(fields, findsNWidgets(2));
          final usesWorkoutTheme =
              theme.surfaceTokens.useSemanticWorkoutCardFill;
          final scopedInk = theme.semanticColors.onWorkoutContainer;

          for (final element in fields.evaluate()) {
            final fieldTheme = Theme.of(element);
            final inputTheme = fieldTheme.inputDecorationTheme;
            final expectedInk =
                usesWorkoutTheme ? scopedInk : theme.textTheme.bodyLarge?.color;

            expect(
              fieldTheme.colorScheme.onSurface,
              usesWorkoutTheme ? scopedInk : theme.colorScheme.onSurface,
            );
            expect(
              fieldTheme.colorScheme.onSurfaceVariant,
              usesWorkoutTheme ? scopedInk : theme.colorScheme.onSurfaceVariant,
            );
            expect(
              fieldTheme.textTheme.bodyLarge?.color,
              usesWorkoutTheme ? scopedInk : theme.textTheme.bodyLarge?.color,
            );

            final editable = tester.widget<EditableText>(
              find.descendant(
                of: find.byWidget(element.widget),
                matching: find.byType(EditableText),
              ),
            );
            expect(editable.style.color, expectedInk);

            if (usesWorkoutTheme) {
              expect(inputTheme.filled, isTrue);
              expect(inputTheme.fillColor, Colors.transparent);
              expect(
                inputTheme.floatingLabelBehavior,
                FloatingLabelBehavior.always,
              );
              expect(inputTheme.labelStyle?.color, scopedInk);
              expect(inputTheme.floatingLabelStyle?.color, scopedInk);
              expect(inputTheme.suffixStyle?.color, scopedInk);
              expect(
                inputTheme.hintStyle?.color,
                scopedInk.withValues(
                  alpha: theme.surfaceTokens.workoutInputHintOpacity,
                ),
              );
              final enabledBorder =
                  inputTheme.enabledBorder! as OutlineInputBorder;
              final focusedBorder =
                  inputTheme.focusedBorder! as OutlineInputBorder;
              expect(enabledBorder.borderRadius, theme.shapeTokens.control);
              expect(enabledBorder.borderSide.color, scopedInk);
              expect(
                enabledBorder.borderSide.width,
                theme.shapeTokens.outlineWidth,
              );
              expect(focusedBorder.borderRadius, theme.shapeTokens.control);
              expect(focusedBorder.borderSide.color, scopedInk);
              expect(
                focusedBorder.borderSide.width,
                theme.shapeTokens.focusRingWidth,
              );
              expect(fieldTheme.textSelectionTheme.cursorColor, scopedInk);
              expect(
                fieldTheme.textSelectionTheme.selectionHandleColor,
                scopedInk,
              );
              expect(
                fieldTheme.textSelectionTheme.selectionColor,
                scopedInk.withValues(
                  alpha: theme.surfaceTokens.workoutTextSelectionOpacity,
                ),
              );
            } else {
              expect(
                inputTheme.fillColor,
                theme.inputDecorationTheme.fillColor,
              );
              expect(
                inputTheme.labelStyle?.color,
                theme.inputDecorationTheme.labelStyle?.color,
              );
              expect(
                inputTheme.focusedBorder,
                theme.inputDecorationTheme.focusedBorder,
              );
              expect(
                fieldTheme.textSelectionTheme.cursorColor,
                theme.textSelectionTheme.cursorColor,
              );
            }
          }

          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        '${family.name} ${theme.brightness} WeightCard recipes resolve tokens',
        (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(units.dispose);

          final exercise = WeightExercise(
            name: 'Squat',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 100, reps: 5)],
            completedParents: {0},
            changeSets: {
              0: [ExerciseSet(weight: 90, reps: 5)],
            },
          );
          await tester.pumpWidget(
            ChangeNotifierProvider<UnitPreferenceProvider>.value(
              value: units,
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: WeightCard(exercise: exercise, readOnlyMode: true),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          final expand = find.byIcon(Icons.keyboard_arrow_down);
          if (expand.evaluate().isNotEmpty) {
            await tester.tap(expand);
            await tester.pump(const Duration(milliseconds: 500));
          }

          final usesInkRecipe = theme.surfaceDecorationTokens.card.outlined;
          final card = tester.widget<Card>(find.byType(Card));
          if (usesInkRecipe) {
            expect(
              (card.shape! as RoundedRectangleBorder).borderRadius,
              theme.shapeTokens.compact,
            );
          } else {
            expect(card.shape, isNull);
          }
          expect(
            card.color,
            theme.semanticColors.workoutExerciseCompleted.withValues(
              alpha: theme.surfaceTokens.workoutCardCompleteFill,
            ),
          );

          final completedFill = theme.semanticColors.workoutSetCompleted
              .withValues(alpha: theme.surfaceTokens.workoutSetCompleteFill);
          final completedRowFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color == completedFill,
          );
          expect(completedRowFinder, findsOneWidget);
          final completedDecoration =
              tester.widget<Container>(completedRowFinder).decoration!
                  as BoxDecoration;
          expect(
            completedDecoration.borderRadius,
            usesInkRecipe
                ? theme.shapeTokens.workoutCompletedSet
                : theme.shapeTokens.control,
          );
          if (usesInkRecipe) {
            final border = completedDecoration.border! as Border;
            expect(
              border.top.width,
              theme.shapeTokens.workoutCompletedSetBorderWidth,
            );
            expect(
              border.left.width,
              theme.shapeTokens.workoutCompletedSetAccentBorderWidth,
            );
            expect(border.top.color, theme.semanticColors.onWorkoutContainer);
            expect(completedDecoration.boxShadow, hasLength(1));
            expect(
              completedDecoration.boxShadow!.single.color,
              theme.effectTokens.cardShadow,
            );
            expect(
              completedDecoration.boxShadow!.single.blurRadius,
              theme.effectTokens.cardShadowBlur,
            );
            expect(
              completedDecoration.boxShadow!.single.offset,
              theme.effectTokens.completedSetShadowOffset,
            );
          } else {
            expect(completedDecoration.boxShadow, isNull);
            expect(
              (completedDecoration.border! as Border).top.color,
              theme.surfaceTokens.workoutChangeSetOutline,
            );
          }

          final changeSetContainerFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.margin == const EdgeInsets.only(left: 32, bottom: 4) &&
                widget.decoration is BoxDecoration,
          );
          expect(changeSetContainerFinder, findsOneWidget);
          final changeSetDecoration =
              tester.widget<Container>(changeSetContainerFinder).decoration!
                  as BoxDecoration;
          expect(
            (changeSetDecoration.border! as Border).top.color,
            theme.surfaceTokens.workoutChangeSetOutline,
          );
          expect((changeSetDecoration.border! as Border).top.width, 1);

          final fields = tester.widgetList<TextFormField>(
            find.byType(TextFormField),
          );
          expect(fields, hasLength(4));
          final inputDecorators = tester.widgetList<InputDecorator>(
            find.byType(InputDecorator),
          );
          expect(inputDecorators, hasLength(4));
          expect(
            inputDecorators.every(
              (decorator) => decorator.decoration.labelText != null,
            ),
            isTrue,
          );
          final fieldTheme = Theme.of(
            tester.element(find.byType(TextFormField).first),
          );
          if (usesInkRecipe) {
            expect(
              fieldTheme.inputDecorationTheme.suffixStyle?.color,
              theme.semanticColors.onWorkoutContainer,
            );
            expect(
              fieldTheme.inputDecorationTheme.hintStyle?.color,
              theme.semanticColors.onWorkoutContainer.withValues(
                alpha: theme.surfaceTokens.workoutInputHintOpacity,
              ),
            );
          } else {
            expect(
              fieldTheme.inputDecorationTheme.suffixStyle,
              theme.inputDecorationTheme.suffixStyle,
            );
            expect(
              fieldTheme.inputDecorationTheme.hintStyle,
              theme.inputDecorationTheme.hintStyle,
            );
          }

          if (!usesInkRecipe) {
            final outlinedSurfaces = theme.surfaceTokens.copyWith(
              workoutSetCompleteOutline: Colors.amber,
            );
            final outlinedTheme = theme.copyWith(
              extensions: [
                ...theme.extensions.values.where(
                  (extension) =>
                      extension.runtimeType != outlinedSurfaces.runtimeType,
                ),
                outlinedSurfaces,
              ],
            );
            final outlinedExercise = WeightExercise(
              name: 'Squat',
              equipment: 'Barbell',
              sets: [ExerciseSet(weight: 100, reps: 5)],
              completedParents: {0},
            );
            await tester.pumpWidget(
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
                child: MaterialApp(
                  theme: outlinedTheme,
                  themeAnimationDuration: Duration.zero,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: Scaffold(
                    body: SingleChildScrollView(
                      child: WeightCard(
                        exercise: outlinedExercise,
                        readOnlyMode: true,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
            final expandOutlined = find.byIcon(Icons.keyboard_arrow_down);
            if (expandOutlined.evaluate().isNotEmpty) {
              await tester.tap(expandOutlined);
              await tester.pump(const Duration(milliseconds: 500));
            }
            final outlinedRowFinder = find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).color == completedFill,
            );
            expect(outlinedRowFinder, findsOneWidget);
            final outlinedRow = tester.widget<Container>(outlinedRowFinder);
            final outlinedBorder =
                (outlinedRow.decoration! as BoxDecoration).border! as Border;
            expect(outlinedBorder.top.color, Colors.amber);
            expect(
              outlinedBorder.top.width,
              outlinedTheme.shapeTokens.outlineWidth,
            );
          }

          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'WeightCard popup labels contrast with their menu surface in all modes',
    (tester) async {
      for (final family in AppThemeFamily.values) {
        for (final theme in [
          AppThemeFactory.light(family),
          AppThemeFactory.dark(family),
        ]) {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(units.dispose);

          await tester.pumpWidget(
            ChangeNotifierProvider<UnitPreferenceProvider>.value(
              value: units,
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: WeightCard(
                    exercise: WeightExercise(
                      name: 'Squat',
                      equipment: 'Barbell',
                      sets: [ExerciseSet(weight: 100, reps: 5)],
                    ),
                    onSwapExercise: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          final popupButton = find.byType(PopupMenuButton<String>);
          await tester.tap(
            find.descendant(
              of: popupButton,
              matching: find.byIcon(Icons.more_vert),
            ),
          );
          await tester.pumpAndSettle();

          final strings = AppLocalizations.of(
            tester.element(find.byType(WeightCard)),
          );
          final menuLabel = find.text(strings.weightSwapExercise);
          expect(
            menuLabel,
            findsOneWidget,
            reason: '${family.name} ${theme.brightness}',
          );

          final popupContext = tester.element(popupButton);
          final popupTheme = Theme.of(popupContext);
          final popupSurface =
              popupTheme.popupMenuTheme.color ??
              popupTheme.colorScheme.surfaceContainer;
          final expectedInk = tonosForegroundForSurface(
            popupContext,
            popupSurface,
          );
          final labelContext = tester.element(menuLabel);
          final label = tester.widget<Text>(menuLabel);
          final effectiveInk =
              label.style?.color ??
              DefaultTextStyle.of(labelContext).style.color ??
              popupTheme.colorScheme.onSurface;

          expect(
            effectiveInk,
            expectedInk,
            reason: '${family.name} ${theme.brightness}',
          );
          if (theme.surfaceDecorationTokens.card.outlined &&
              theme.brightness == Brightness.dark) {
            expect(label.style?.color, expectedInk);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    },
  );
}
