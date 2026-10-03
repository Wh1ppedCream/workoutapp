import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/weight_card.dart';

void main() {
  for (final textScale in [1.0, 1.15, 1.5, 2.0]) {
    testWidgets('Expressive WeightCard fits 320dp at ${textScale}x text scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final exercise = WeightExercise(
        name: 'Squat',
        equipment: 'Barbell',
        sets: List.generate(
          4,
          (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
        ),
      );
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
                      previewWeightUnit: WeightUnit.pounds,
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

      final rowHeights = <double>[];
      for (var index = 0; index < 4; index++) {
        final checkbox = checkboxes.at(index);
        expect(tester.getSize(checkbox), const Size(48, 48));

        final row = find
            .ancestor(of: checkbox, matching: find.byType(AnimatedContainer))
            .first;
        final rowRect = tester.getRect(row);
        rowHeights.add(rowRect.height);
        expect(rowRect.width, lessThanOrEqualTo(304));
        expect(rowRect.height, greaterThanOrEqualTo(48));
        expect(rowRect.height, lessThan(260));

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
}
