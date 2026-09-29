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
}

WeightExercise _exercise() => WeightExercise(
  name: 'Squat',
  equipment: 'Barbell',
  sets: [ExerciseSet(weight: 100, reps: 5), ExerciseSet(weight: 90, reps: 8)],
);

Widget _host(
  WeightExercise exercise, {
  bool disableAnimations = false,
  double textScale = 1,
  FocusNode? firstSetWeightFocusNode,
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
