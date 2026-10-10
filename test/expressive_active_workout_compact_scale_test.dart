import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/widgets/weight_card.dart';

void main() {
  for (final textScale in [1.0, 1.15, 1.5, 2.0]) {
    testWidgets('Expressive WeightCard fits 320dp at ${textScale}x text scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final exercise = WeightExercise(
        name: 'Ab Wheel',
        equipment: 'Barbell',
        sets: List.generate(
          4,
          (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
        ),
      );
      final previewUnit = textScale == 2.0
          ? WeightUnit.kilograms
          : WeightUnit.pounds;
      const weightKey = ValueKey<String>('compact-scale-weight');
      const repsKey = ValueKey<String>('compact-scale-reps');
      const addSetKey = ValueKey<String>('compact-scale-add-set');

      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          themeAnimationDuration: Duration.zero,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: WeightCard(
                      exercise: exercise,
                      previewWeightUnit: previewUnit,
                      expressiveWorkoutPresentation: true,
                      animateExpansion: true,
                      firstSetWeightKey: weightKey,
                      firstSetRepsKey: repsKey,
                      addSetKey: addSetKey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(4));
      expect(find.byType(TextFormField), findsNWidgets(8));
      expect(find.byKey(weightKey), findsOneWidget);
      expect(find.byKey(repsKey), findsOneWidget);

      final exerciseTitle = find.text('Ab Wheel');
      expect(exerciseTitle, findsOneWidget);
      final titleWidget = tester.widget<Text>(exerciseTitle);
      expect(titleWidget.maxLines, isNull);
      expect(titleWidget.overflow, isNull);
      final titleParagraph = tester.renderObject<RenderParagraph>(
        exerciseTitle,
      );
      expect(titleParagraph.didExceedMaxLines, isFalse);

      final weightLabels = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.startsWith('Weight') == true,
      );
      expect(weightLabels, findsNWidgets(4));
      for (final element in weightLabels.evaluate()) {
        final label = element.widget as Text;
        expect(label.data, contains('('));
        expect(label.data, endsWith(')'));
        expect(label.data, 'Weight (${previewUnit.shortLabel})');
        if (textScale > 1.15) {
          expect(label.maxLines, isNull);
          expect(label.overflow, isNull);
          final paragraph = tester.renderObject<RenderParagraph>(
            find.byWidgetPredicate((widget) => identical(widget, label)),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
        } else {
          expect(label.maxLines, 2);
          expect(label.overflow, TextOverflow.ellipsis);
        }
        final visibleLabel = find.byWidgetPredicate(
          (widget) => identical(widget, label),
        );
        expect(visibleLabel, findsOneWidget);
        expect(tester.getSize(visibleLabel).height, greaterThan(0));
      }

      final repsLabels = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Reps',
      );
      expect(repsLabels, findsNWidgets(4));
      if (textScale > 1.15) {
        for (final element in repsLabels.evaluate()) {
          final label = element.widget as Text;
          expect(label.maxLines, isNull);
          expect(label.overflow, isNull);
          expect(
            tester
                .renderObject<RenderParagraph>(
                  find.byWidgetPredicate((widget) => identical(widget, label)),
                )
                .didExceedMaxLines,
            isFalse,
          );
        }
        final firstWeightField = tester.getRect(
          find.byType(TextFormField).first,
        );
        final firstRepsField = tester.getRect(find.byType(TextFormField).at(1));
        expect(
          firstWeightField.right,
          lessThanOrEqualTo(firstRepsField.left),
          reason: 'compact large-text fields use separate columns',
        );
      }

      if (textScale > 1.15) {
        final semantics = tester.ensureSemantics();
        final expectedWeightLabel = AppLocalizations.of(
          tester.element(find.byType(WeightCard)),
        ).weightLabel(previewUnit.shortLabel);
        final menuTooltip = MaterialLocalizations.of(
          tester.element(find.byType(WeightCard)),
        ).showMenuTooltip;
        final setLabel = find.text('Set 1', skipOffstage: false);
        final removeSet = find
            .byTooltip(
              AppLocalizations.of(tester.element(find.byType(WeightCard)))
                  .weightRemoveSetTitle,
            )
            .first;
        try {
          expect(
            tester.getSemantics(find.byKey(weightKey)).label,
            expectedWeightLabel,
            reason: 'the full compact-width weight label stays accessible',
          );
          expect(setLabel, findsOneWidget);
          expect(
            tester.getRect(exerciseTitle).bottom,
            lessThanOrEqualTo(tester.getRect(find.byTooltip(menuTooltip)).top),
            reason:
                'the full exercise title clears the second-line menu action',
          );
          final setLabelRect = tester.getRect(setLabel);
          expect(
            setLabelRect.overlaps(tester.getRect(checkboxes.first)),
            isFalse,
            reason: 'the set label stays clear of its completion checkbox',
          );
          for (final field in find.byType(TextFormField).evaluate().take(2)) {
            expect(
              setLabelRect.overlaps(
                tester.getRect(find.byWidget(field.widget)),
              ),
              isFalse,
              reason: 'the set label stays clear of weight and reps inputs',
            );
          }
          expect(
            setLabelRect.overlaps(tester.getRect(removeSet)),
            isFalse,
            reason: 'the set label stays clear of the remove action',
          );
        } finally {
          semantics.dispose();
        }
      }

      final rowHeights = <double>[];
      for (var index = 0; index < 4; index++) {
        final checkbox = checkboxes.at(index);
        expect(tester.getSize(checkbox), const Size(48, 48));

        final row = find
            .ancestor(of: checkbox, matching: find.byType(AnimatedContainer))
            .first;
        final rowRect = tester.getRect(row);
        if (textScale == 2.0) {
          expect(rowRect.height, closeTo(219, 2));
        }
        rowHeights.add(rowRect.height);
        expect(rowRect.width, lessThanOrEqualTo(304));
        expect(rowRect.height, greaterThanOrEqualTo(48));
        expect(
          rowRect.height,
          lessThan(textScale > 1.15 ? 240 : 260),
          reason: 'the compact large-text fields fit below their action row',
        );

        final checkboxRect = tester.getRect(checkbox);
        for (final field in find.byType(TextFormField).evaluate()) {
          expect(
            checkboxRect.overlaps(tester.getRect(find.byWidget(field.widget))),
            isFalse,
            reason:
                'Checkbox must not overlap weight or reps fields at $textScale x',
          );
        }
      }

      final addSet = find.byKey(addSetKey);
      expect(addSet, findsOneWidget);
      expect(tester.getSize(addSet).height, greaterThanOrEqualTo(48));

      // Exercise the actual Add Set action while the expanded card is in the
      // compact layout; this also verifies the four-row layout remains live.
      await tester.ensureVisible(addSet);
      await tester.tap(addSet);
      await tester.pumpAndSettle();
      expect(exercise.sets, hasLength(5));
      expect(find.byType(Checkbox), findsNWidgets(5));
      expect(tester.takeException(), isNull);

      // Re-check a representative row after the mutation/rebuild.
      final firstRow = find
          .ancestor(
            of: find.byType(Checkbox).first,
            matching: find.byType(AnimatedContainer),
          )
          .first;
      expect(tester.getRect(firstRow).height, closeTo(rowHeights.first, 0.1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Expressive WeightCard stacks fields when row width is tight', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final exercise = WeightExercise(
      name: 'Squat',
      equipment: 'Barbell',
      sets: [ExerciseSet(weight: 100, reps: 5)],
    );

    for (final width in [360.0, 320.0, 280.0]) {
      await tester.binding.setSurfaceSize(Size(width, 700));
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          themeAnimationDuration: Duration.zero,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: WeightCard(
                  exercise: exercise,
                  previewWeightUnit: WeightUnit.pounds,
                  expressiveWorkoutPresentation: true,
                  animateExpansion: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));
      final weight = tester.getRect(fields.at(0));
      final reps = tester.getRect(fields.at(1));
      if (width < 340) {
        expect(weight.bottom, lessThanOrEqualTo(reps.top));
      } else {
        expect(weight.top, lessThan(reps.bottom));
        expect(reps.top, lessThan(weight.bottom));
        expect(weight.right, lessThanOrEqualTo(reps.left));
      }
      expect(tester.takeException(), isNull, reason: 'viewport width $width');
    }
  });

  for (final entry in <String, ThemeData>{
    'Classic': ClassicThemeDefinition.light(),
    'Neo': NeoBrutalismThemeDefinition.light(),
  }.entries) {
    testWidgets('${entry.key} keeps inline labels at compact 2x', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final exercise = WeightExercise(
        name: 'Squat',
        equipment: 'Barbell',
        sets: [ExerciseSet(weight: 100, reps: 5)],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: entry.value,
          themeAnimationDuration: Duration.zero,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: WeightCard(
                    exercise: exercise,
                    previewWeightUnit: WeightUnit.pounds,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, hasLength(2));
      expect(fields.first.decoration?.labelText, 'Weight (lbs)');
      expect(fields.last.decoration?.labelText, 'Reps');
      final weightLabel = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.startsWith('Weight') == true,
      );
      expect(weightLabel, findsOneWidget);
      expect(
        find.ancestor(of: weightLabel, matching: find.byType(TextField)),
        findsOneWidget,
        reason: 'the weight label remains within its inline field decoration',
      );
      expect(tester.takeException(), isNull);
    });
  }
}
