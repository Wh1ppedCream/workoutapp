import 'dart:ui' show CheckedState;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/weight_card.dart';

const _weightKey = ValueKey('weight-card-first-weight');
const _repsKey = ValueKey('weight-card-first-reps');

void main() {
  testWidgets(
    'WeightCard starts open, toggles semantically, retargets, and unfocuses on collapse',
    (tester) async {
      await _withSemantics(tester, () async {
        final weightFocus = FocusNode();
        addTearDown(weightFocus.dispose);
        final exercise = _exercise();

        await tester.pumpWidget(
          _host(exercise, firstSetWeightFocusNode: weightFocus),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(WeightCard)),
        );
        final card = find.byType(WeightCard);
        final weightField = find.byKey(_weightKey);

        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(weightField, findsOneWidget);
        _expectButtonSemantics(
          tester,
          find.byType(IconButton).first,
          strings.weightCollapseSets,
        );

        weightFocus.requestFocus();
        await tester.pump();
        expect(weightFocus.hasFocus, isTrue);

        await tester.tap(find.byTooltip(strings.weightCollapseSets));
        // Start the retarget before advancing fake time. pumpAndSettle is
        // avoided because a focused EditableText can request cursor-blink frames.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
        expect(weightFocus.hasFocus, isFalse);
        _expectButtonSemantics(
          tester,
          find.byType(IconButton).first,
          strings.weightExpandSets,
        );

        await tester.tap(find.byTooltip(strings.weightExpandSets));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsNWidgets(4));

        // Retarget while the size transition is still in progress. Assert only
        // the final state, so the contract does not depend on animation frames.
        final expansionButton =
            find.descendant(of: card, matching: find.byType(IconButton)).first;
        for (var index = 0; index < 3; index++) {
          await tester.tap(expansionButton);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsNothing);
        expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    },
  );

  testWidgets(
    'only completing the final set auto-collapses and reopening retains checks',
    (tester) async {
      await _withSemantics(tester, () async {
        final exercise = _exercise();

        await tester.pumpWidget(_host(exercise));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(WeightCard)),
        );
        final checkboxes = find.byType(Checkbox);
        expect(checkboxes, findsNWidgets(2));

        var firstSetSemantics =
            tester.getSemantics(checkboxes.first).getSemanticsData();
        expect(firstSetSemantics.label, strings.weightSetLabel(1));
        expect(
          firstSetSemantics.flagsCollection.isChecked,
          CheckedState.isFalse,
        );
        expect(firstSetSemantics.hasAction(SemanticsAction.tap), isTrue);

        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();
        expect(exercise.completedParents, {0});
        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(find.byTooltip(strings.weightCollapseSets), findsOneWidget);

        firstSetSemantics =
            tester.getSemantics(find.byType(Checkbox).first).getSemanticsData();
        expect(
          firstSetSemantics.flagsCollection.isChecked,
          CheckedState.isTrue,
        );

        await tester.tap(find.byType(Checkbox).last);
        await tester.pumpAndSettle();
        expect(exercise.completedParents, {0, 1});
        expect(find.byType(TextFormField), findsNothing);
        expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);

        await tester.tap(find.byTooltip(strings.weightExpandSets));
        await tester.pumpAndSettle();
        expect(find.byType(Checkbox), findsNWidgets(2));
        expect(
          tester
              .widgetList<Checkbox>(find.byType(Checkbox))
              .map((box) => box.value),
          everyElement(isTrue),
        );
        for (var index = 0; index < 2; index++) {
          final data =
              tester
                  .getSemantics(find.byType(Checkbox).at(index))
                  .getSemanticsData();
          expect(data.flagsCollection.isChecked, CheckedState.isTrue);
          expect(data.hasAction(SemanticsAction.tap), isTrue);
        }

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    },
  );

  testWidgets('reduced motion makes expansion changes immediate', (
    tester,
  ) async {
    final exercise = _exercise();
    await tester.pumpWidget(_host(exercise, disableAnimations: true));
    await tester.pumpAndSettle();

    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );
    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.tap(find.byTooltip(strings.weightCollapseSets));
    await tester.pump();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);

    await tester.tap(find.byTooltip(strings.weightExpandSets));
    await tester.pump();
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('compact 2x layout keeps fields stacked and focus usable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final weightFocus = FocusNode();
    addTearDown(weightFocus.dispose);
    final exercise = _exercise();

    await tester.pumpWidget(
      _host(exercise, textScale: 2, firstSetWeightFocusNode: weightFocus),
    );
    await tester.pumpAndSettle();

    final weightField = find.byKey(_weightKey);
    final repsField = find.byKey(_repsKey);
    expect(weightField, findsOneWidget);
    expect(repsField, findsOneWidget);
    expect(
      tester.getRect(repsField).top,
      greaterThanOrEqualTo(tester.getRect(weightField).bottom),
    );

    await tester.ensureVisible(weightField);
    weightFocus.requestFocus();
    await tester.pump();
    expect(weightFocus.hasFocus, isTrue);

    await tester.enterText(weightField, '125.5');
    await tester.pump();
    expect(exercise.sets.first.weight, 125.5);
    expect(weightFocus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    '48dp completion targets preserve six-row geometry across widths and text scales',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const cases = [
        (width: 393.0, textScale: 1.0, baselineRowHeight: 80.0),
        (width: 393.0, textScale: 2.0, baselineRowHeight: 222.0),
        (width: 320.0, textScale: 1.0, baselineRowHeight: 80.0),
        (width: 320.0, textScale: 2.0, baselineRowHeight: 218.0),
      ];

      for (final testCase in cases) {
        await tester.binding.setSurfaceSize(Size(testCase.width, 850));
        final exercise = _exercise(setCount: 6);
        await tester.pumpWidget(_host(exercise, textScale: testCase.textScale));
        await tester.pumpAndSettle();

        final checkboxes = find.byType(Checkbox);
        expect(checkboxes, findsNWidgets(6));
        for (var index = 0; index < 6; index++) {
          final checkbox = checkboxes.at(index);
          expect(tester.getSize(checkbox), const Size(48, 48));
          final row = find
              .ancestor(of: checkbox, matching: find.byType(Container))
              .first;
          expect(
            tester.getSize(row).height,
            testCase.baselineRowHeight,
            reason:
                'row $index at ${testCase.width}dp and '
                '${testCase.textScale}x text',
          );
        }

        final checkboxRect = tester.getRect(checkboxes.first);
        final weightRect = tester.getRect(find.byKey(_weightKey));
        final repsRect = tester.getRect(find.byKey(_repsKey));
        expect(checkboxRect.overlaps(weightRect), isFalse);
        expect(checkboxRect.overlaps(repsRect), isFalse);
        if (testCase.textScale > 1.15) {
          expect(weightRect.bottom, lessThanOrEqualTo(repsRect.top));
        } else {
          expect(weightRect.right, lessThanOrEqualTo(repsRect.left));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'completion target edges toggle once without stealing field input or focus',
    (tester) async {
      final exercise = _exercise();
      final weightFocus = FocusNode();
      addTearDown(weightFocus.dispose);
      var refreshCount = 0;
      await tester.pumpWidget(
        _host(
          exercise,
          firstSetWeightFocusNode: weightFocus,
          onValueChanged: () => refreshCount++,
        ),
      );
      await tester.pumpAndSettle();

      final weightField = find.byKey(_weightKey);
      await tester.tap(weightField);
      await tester.pump();
      expect(exercise.completedParents, isEmpty);
      expect(weightFocus.hasFocus, isTrue);
      await tester.enterText(weightField, '125');
      await tester.pump();
      expect(exercise.completedParents, isEmpty);
      expect(weightFocus.hasFocus, isTrue);

      refreshCount = 0;
      final checkbox = find.byType(Checkbox).first;
      final rect = tester.getRect(checkbox);
      await tester.tapAt(Offset(rect.left + 1, rect.center.dy));
      await tester.pump();
      expect(exercise.completedParents, {0});
      expect(refreshCount, 1);
      expect(weightFocus.hasFocus, isTrue);

      await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
      await tester.pump();
      expect(exercise.completedParents, isEmpty);
      expect(refreshCount, 2);

      await tester.tapAt(rect.center);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tapAt(rect.center);
      await tester.pumpAndSettle();
      expect(exercise.completedParents, isEmpty);
      expect(refreshCount, 4);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

WeightExercise _exercise({int setCount = 2}) => WeightExercise(
  name: 'Squat',
  equipment: 'Barbell',
  sets: List.generate(
    setCount,
    (index) => ExerciseSet(
      weight: 100 - index * 5,
      reps: index == 0 ? 5 : 8 + index - 1,
    ),
  ),
);

Widget _host(
  WeightExercise exercise, {
  bool disableAnimations = false,
  double textScale = 1,
  FocusNode? firstSetWeightFocusNode,
  void Function()? onValueChanged,
}) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  themeAnimationDuration: Duration.zero,
  locale: const Locale('en'),
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) {
      final media = MediaQuery.of(context).copyWith(
        disableAnimations: disableAnimations,
        textScaler: TextScaler.linear(textScale),
      );
      return MediaQuery(
        data: media,
        child: Scaffold(
          body: SingleChildScrollView(
            child: WeightCard(
              key: const ValueKey('weight-card'),
              exercise: exercise,
              previewWeightUnit: WeightUnit.pounds,
              animateExpansion: true,
              firstSetWeightKey: _weightKey,
              firstSetRepsKey: _repsKey,
              firstSetWeightFocusNode: firstSetWeightFocusNode,
              onValueChanged: onValueChanged,
            ),
          ),
        ),
      );
    },
  ),
);

void _expectButtonSemantics(
  WidgetTester tester,
  Finder finder,
  String expectedLabel,
) {
  expect(finder, findsOneWidget);
  final data = tester.getSemantics(finder).getSemanticsData();
  expect(data.tooltip, expectedLabel);
  expect(data.hasAction(SemanticsAction.tap), isTrue);
}

Future<void> _withSemantics(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  final semantics = tester.ensureSemantics();
  try {
    await body();
  } finally {
    semantics.dispose();
  }
}
