import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/workout_actions.dart';
import 'package:env_test/theme/widgets/workout_sheet_handle.dart';
import 'package:env_test/widgets/weight_card.dart';
import 'package:env_test/widgets/workout_record_badges.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final theme in [
    AppThemeFactory.light(AppThemeFamily.classic),
    AppThemeFactory.dark(AppThemeFamily.classic),
  ]) {
    testWidgets('${theme.brightness} finish retains busy state and callback', (
      tester,
    ) async {
      var calls = 0;
      const key = ValueKey('finish');
      await tester.pumpWidget(
        _host(
          theme,
          WorkoutFinishAction(
            buttonKey: key,
            label: 'Finish',
            onPressed: () => calls++,
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byKey(key));
      expect(button.style, isNull);
      await tester.tap(find.byKey(key));
      expect(calls, 1);
      await tester.pumpWidget(
        _host(
          theme,
          WorkoutFinishAction(
            buttonKey: key,
            label: 'Finish',
            busy: true,
            onPressed: () => calls++,
          ),
        ),
      );
      expect(tester.widget<ElevatedButton>(find.byKey(key)).onPressed, isNull);
      expect(find.text('Finish'), findsNothing);
      final spinner = find.byType(CircularProgressIndicator);
      expect(tester.getSize(spinner), const Size(20, 20));
      expect(tester.widget<CircularProgressIndicator>(spinner).strokeWidth, 2);
      expect(calls, 1);
    });

    testWidgets('${theme.brightness} done retains height and filled styling', (
      tester,
    ) async {
      var calls = 0;
      const key = ValueKey('done');
      await tester.pumpWidget(
        _host(
          theme,
          WorkoutDoneAction(
            buttonKey: key,
            label: 'Done',
            onPressed: () => calls++,
          ),
        ),
      );
      final button = tester.widget<FilledButton>(find.byKey(key));
      expect(button.style!.minimumSize!.resolve({}), const Size.fromHeight(48));
      expect(button.style!.backgroundColor, isNull);
      expect(button.style!.foregroundColor, isNull);
      expect(button.style!.shape, isNull);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.byKey(key));
      expect(calls, 1);
    });

    testWidgets(
      '${theme.brightness} handle and badges resolve surface overrides',
      (tester) async {
        for (final override in [false, true]) {
          final surfaces = theme.surfaceTokens.copyWith(
            workoutHandle:
                override ? Colors.pink : theme.surfaceTokens.workoutHandle,
            firstRecordFill: override ? 0.4 : 0.12,
            firstRecordBorder: override ? 0.8 : 0.72,
            recordBadgeFill: override ? 0.5 : 0.14,
            recordBadgeBorder: override ? 0.9 : 0.62,
          );
          final activeTheme = theme.copyWith(
            extensions: [
              ...theme.extensions.values.where(
                (e) => e.runtimeType != surfaces.runtimeType,
              ),
              surfaces,
            ],
          );
          for (final compact in [false, true]) {
            await tester.pumpWidget(
              _host(
                activeTheme,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WorkoutSheetHandle(),
                    FirstRecordBadge(compact: compact),
                    WorkoutRecordBadgeChip(
                      compact: compact,
                      badge: const WorkoutRecordBadge(
                        tier: WorkoutRecordBadgeTier.allTime,
                        type: WorkoutRecordBadgeType.volumeBest,
                      ),
                    ),
                  ],
                ),
              ),
            );
            final handle = tester.widget<Container>(
              find.descendant(
                of: find.byType(WorkoutSheetHandle),
                matching: find.byType(Container),
              ),
            );
            expect(
              tester.getSize(find.byType(WorkoutSheetHandle)),
              const Size(36, 4),
            );
            expect(
              (handle.decoration! as BoxDecoration).color,
              override
                  ? Colors.pink
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            );
            for (final first in [false, true]) {
              final container = tester.widget<Container>(
                find.descendant(
                  of: find.byType(
                    first ? FirstRecordBadge : WorkoutRecordBadgeChip,
                  ),
                  matching: find.byType(Container),
                ),
              );
              final decoration = container.decoration! as BoxDecoration;
              final color =
                  first
                      ? theme.dataVisualizationTokens.firstRecord
                      : theme.dataVisualizationTokens.recordAllTime;
              expect(
                decoration.color,
                color.withValues(
                  alpha:
                      first
                          ? surfaces.firstRecordFill
                          : surfaces.recordBadgeFill,
                ),
              );
              expect(
                (decoration.border! as Border).top.color,
                color.withValues(
                  alpha:
                      first
                          ? surfaces.firstRecordBorder
                          : surfaces.recordBadgeBorder,
                ),
              );
              expect(
                decoration.borderRadius,
                compact
                    ? theme.shapeTokens.recordBadgeCompact
                    : theme.shapeTokens.recordBadge,
              );
            }
            expect(tester.takeException(), isNull);
          }
        }
      },
    );

    testWidgets('${theme.brightness} editable workout survives theme changes', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      const weightKey = ValueKey('editable-weight');
      final exercise = WeightExercise(
        name: 'Squat',
        equipment: 'Barbell',
        sets: [
          ExerciseSet(weight: 100, reps: 5),
          ExerciseSet(weight: 90, reps: 8),
        ],
      );
      var changes = 0;
      Widget host(ThemeData selected) => _host(
        selected,
        ChangeNotifierProvider.value(
          value: units,
          child: WeightCard(
            exercise: exercise,
            firstSetWeightKey: weightKey,
            firstSetWeightFocusNode: focus,
            onValueChanged: () => changes++,
          ),
        ),
      );
      await tester.pumpWidget(host(theme));
      await tester.tap(find.byType(Checkbox).last);
      await tester.pump();
      await tester.enterText(find.byKey(weightKey), '123.5');
      await tester.pump();
      final field = tester.widget<TextFormField>(find.byKey(weightKey));
      final controller = field.controller!;
      controller.selection = const TextSelection.collapsed(offset: 3);
      expect(focus.hasFocus, isTrue);
      expect(exercise.sets.first.weight, 123.5);
      expect(exercise.completedParents, {1});
      expect(changes, 2);

      final opposite =
          theme.brightness == Brightness.light
              ? AppThemeFactory.dark(AppThemeFamily.classic)
              : AppThemeFactory.light(AppThemeFamily.classic);
      for (final selected in [opposite, theme]) {
        await tester.pumpWidget(host(selected));
        await tester.pump();
        expect(
          tester.widget<TextFormField>(find.byKey(weightKey)).controller,
          same(controller),
        );
        expect(controller.text, '123.5');
        expect(controller.selection, const TextSelection.collapsed(offset: 3));
        expect(focus.hasFocus, isTrue);
        expect(exercise.sets.first.weight, 123.5);
        expect(exercise.sets.first.reps, 5);
        expect(exercise.completedParents, {1});
        expect(
          tester.widget<Checkbox>(find.byType(Checkbox).last).value,
          isTrue,
        );
        expect(changes, 2);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('${theme.brightness} WeightCard resolves workout roles', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      final surfaces = theme.surfaceTokens.copyWith(
        workoutCardCompleteFill: 0.4,
        workoutSetCompleteFill: 0.6,
        workoutChangeSetOutline: Colors.cyan,
      );
      final activeTheme = theme.copyWith(
        extensions: [
          ...theme.extensions.values.where(
            (extension) =>
                extension.runtimeType != surfaces.runtimeType &&
                extension.runtimeType != theme.semanticColors.runtimeType &&
                extension.runtimeType != theme.shapeTokens.runtimeType,
          ),
          surfaces,
          theme.semanticColors.copyWith(
            workoutCompleted: Colors.pink,
            workoutExerciseCompleted: Colors.orange,
            workoutSetCompleted: Colors.teal,
          ),
          theme.shapeTokens.copyWith(control: BorderRadius.circular(3)),
        ],
      );
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
        _host(
          theme,
          ChangeNotifierProvider.value(
            value: units,
            child: WeightCard(exercise: exercise, readOnlyMode: true),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();

      expect(
        tester.widget<Card>(find.byType(Card)).color,
        theme.semanticColors.workoutExerciseCompleted.withValues(
          alpha: theme.surfaceTokens.workoutCardCompleteFill,
        ),
      );
      final strings = AppLocalizations.of(
        tester.element(find.byType(WeightCard)),
      );
      expect(
        tester
            .widget<Text>(find.text(strings.weightCardSetsDone(1, 1)))
            .style
            ?.color,
        theme.semanticColors.workoutCompleted,
      );
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).activeColor,
        theme.semanticColors.workoutCompleted,
      );
      final classicRow = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color ==
                  theme.semanticColors.workoutSetCompleted.withValues(
                    alpha: theme.surfaceTokens.workoutSetCompleteFill,
                  ),
        ),
      );
      final classicDecoration = classicRow.decoration! as BoxDecoration;
      expect(classicDecoration.borderRadius, BorderRadius.circular(12));
      expect(classicDecoration.border!.top.color, Colors.grey);

      await tester.pumpWidget(
        _host(
          activeTheme,
          ChangeNotifierProvider.value(
            value: units,
            child: WeightCard(exercise: exercise, readOnlyMode: true),
          ),
        ),
      );
      await tester.pump();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.orange.withValues(alpha: 0.4));
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).activeColor,
        Colors.pink,
      );
      final setRow = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.borderRadius == BorderRadius.circular(3) &&
              decoration.color == Colors.teal.withValues(alpha: 0.6);
        }),
      );
      expect(
        (setRow.decoration! as BoxDecoration).border!.top.color,
        Colors.cyan,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);
