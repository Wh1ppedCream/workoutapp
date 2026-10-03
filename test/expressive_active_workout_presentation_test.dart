import 'dart:ui' show CheckedState;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/tonos_expressive_workout_shapes.dart';
import 'package:env_test/theme/widgets/workout_actions.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/weight_card.dart';

const _weightKey = ValueKey('expressive-first-weight');
const _repsKey = ValueKey('expressive-first-reps');
const _addSetKey = ValueKey('expressive-add-set');

void main() {
  testWidgets('active-session opt-in is limited to Expressive sessions', (
    tester,
  ) async {
    final cases = <({ThemeData theme, bool expressive})>[
      (theme: AppThemeFactory.light(AppThemeFamily.classic), expressive: false),
      (
        theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
        expressive: false,
      ),
      (theme: ExpressiveThemeDefinition.light(), expressive: true),
    ];

    for (final testCase in cases) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final repository = _EmptyRepository();
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      final units = UnitPreferenceProvider();
      addTearDown(session.dispose);
      addTearDown(units.dispose);
      await Future.wait<void>([session.ready, units.ready]);
      session
        ..exercises.add(_exercise())
        ..cardTypes.add(CardType.weight);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(value: session),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
            Provider<AppRepository>.value(value: repository),
          ],
          child: MaterialApp(
            theme: testCase.theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SessionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 421));
      await tester.pumpAndSettle();

      final exerciseCard = tester.widget<ExerciseCard>(
        find.byType(ExerciseCard),
      );
      expect(exerciseCard.expressiveWorkoutPresentation, testCase.expressive);
      final card = tester.widget<WeightCard>(find.byType(WeightCard));
      expect(card.expressiveWorkoutPresentation, testCase.expressive);
      final addFab = tester.widget<AddExerciseFab>(find.byType(AddExerciseFab));
      expect(addFab.expressiveWorkoutPresentation, testCase.expressive);
      final finishAction = tester.widget<WorkoutFinishAction>(
        find.byType(WorkoutFinishAction),
      );
      expect(finishAction.expressiveWorkoutPresentation, testCase.expressive);

      final outerCard = tester.widget<Card>(
        find.descendant(
          of: find.byType(WeightCard),
          matching: find.byType(Card),
        ),
      );
      expect(
        outerCard.shape,
        testCase.expressive
            ? RoundedRectangleBorder(
                borderRadius: TonosExpressiveWorkoutShapes.exerciseCard,
              )
            : isNot(
                RoundedRectangleBorder(
                  borderRadius: TonosExpressiveWorkoutShapes.exerciseCard,
                ),
              ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('shared WeightCard keeps the opt-in default off', (tester) async {
    final exercise = _exercise();
    await tester.pumpWidget(_weightCardHost(exercise));
    await tester.pumpAndSettle();

    final weightCard = tester.widget<WeightCard>(find.byType(WeightCard));
    expect(weightCard.expressiveWorkoutPresentation, isFalse);
    final card = tester.widget<Card>(
      find.descendant(of: find.byType(WeightCard), matching: find.byType(Card)),
    );
    expect(card.shape, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Expressive exercise menu keeps a safe screen-edge inset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _weightCardHost(_exercise(), expressiveWorkoutPresentation: true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final menuItems = find.byType(MenuItemButton);
    expect(menuItems, findsNWidgets(2));
    for (final actionLabel in ['Remove Exercise', 'Make ChangeSet']) {
      final label = find.text(actionLabel);
      expect(label, findsOneWidget);
      expect(tester.getRect(label).right, lessThanOrEqualTo(348));
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('focused field contrast and header geometry work in both themes', (
    tester,
  ) async {
    final cases = <({String name, ThemeData theme})>[
      (name: 'light', theme: ExpressiveThemeDefinition.light()),
      (name: 'dark', theme: ExpressiveThemeDefinition.dark()),
    ];

    for (final testCase in cases) {
      final focusNode = FocusNode(debugLabel: '${testCase.name} weight field');
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _weightCardHost(
          _exercise(),
          theme: testCase.theme,
          expressiveWorkoutPresentation: true,
          firstSetWeightFocusNode: focusNode,
        ),
      );
      await tester.pumpAndSettle();

      final weightField = find.byKey(_weightKey);
      await tester.ensureVisible(weightField);
      focusNode.requestFocus();
      await tester.pump();

      final fieldTheme = Theme.of(tester.element(weightField));
      final tokens = testCase.theme.extension<AppExpressiveTrainTokens>()!;
      final focusedBorder =
          fieldTheme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(
        focusedBorder.borderRadius,
        TonosExpressiveWorkoutShapes.numericField,
        reason: testCase.name,
      );
      expect(
        focusedBorder.borderSide.color,
        tokens.actionPrimary,
        reason: testCase.name,
      );
      expect(
        _contrastRatio(tokens.actionPrimary, tokens.activePlansSurface),
        greaterThanOrEqualTo(3),
        reason: '${testCase.name} focus outline contrast',
      );

      final header = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius ==
                TonosExpressiveWorkoutShapes.exerciseHeader,
      );
      expect(header, findsOneWidget);
      final paintedHeader = find
          .descendant(of: header, matching: find.byType(DecoratedBox))
          .first;
      final headerWidget = tester.widget<Container>(header);
      expect(
        headerWidget.padding,
        const EdgeInsets.symmetric(horizontal: 8),
        reason: '${testCase.name} header keeps compact horizontal padding',
      );
      expect(
        tester.getSize(paintedHeader).height,
        closeTo(48, 0.1),
        reason: '${testCase.name} preserves the visible header surface height',
      );
      expect(
        tester.getRect(paintedHeader).top - tester.getRect(header).top,
        closeTo(8, 0.1),
        reason: '${testCase.name} preserves the visible header top inset',
      );
      expect(
        headerWidget.margin?.resolve(TextDirection.ltr).bottom,
        6,
        reason: '${testCase.name} reserves the 6dp expanded divider gap',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'Expressive workout roles retain completion semantics and fit compact 2x rows',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final exercise = _exercise(setCount: 6);
      var addSetCalls = 0;

      await tester.pumpWidget(
        _weightCardHost(
          exercise,
          expressiveWorkoutPresentation: true,
          textScale: 2,
          onSetAdded: () => addSetCalls++,
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(WeightCard);
      expect(
        tester.widget<WeightCard>(card).expressiveWorkoutPresentation,
        isTrue,
      );
      final outerCard = tester.widget<Card>(
        find.descendant(of: card, matching: find.byType(Card)),
      );
      expect(
        outerCard.shape,
        RoundedRectangleBorder(
          borderRadius: TonosExpressiveWorkoutShapes.exerciseCard,
        ),
      );
      final setRow = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius ==
                TonosExpressiveWorkoutShapes.setRow,
      );
      expect(setRow, findsNWidgets(6));

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(6));
      for (var index = 0; index < checkboxes.evaluate().length; index++) {
        final checkbox = checkboxes.at(index);
        expect(tester.getSize(checkbox), const Size(48, 48));
        final row = find
            .ancestor(of: checkbox, matching: find.byType(Container))
            .first;
        expect(tester.getRect(row).overlaps(tester.getRect(checkbox)), isTrue);
      }

      final weightField = find.byKey(_weightKey);
      final repsField = find.byKey(_repsKey);
      expect(weightField, findsOneWidget);
      expect(repsField, findsOneWidget);
      expect(
        tester.getRect(repsField).top,
        greaterThanOrEqualTo(tester.getRect(weightField).bottom),
      );
      for (final checkbox in checkboxes.evaluate()) {
        final rect = tester.getRect(find.byWidget(checkbox.widget));
        expect(rect.overlaps(tester.getRect(weightField)), isFalse);
        expect(rect.overlaps(tester.getRect(repsField)), isFalse);
      }

      final strings = AppLocalizations.of(tester.element(card));
      final semantics = tester.ensureSemantics();
      try {
        final firstSet = tester
            .getSemantics(checkboxes.first)
            .getSemanticsData();
        expect(firstSet.label, strings.weightSetLabel(1));
        expect(firstSet.flagsCollection.isChecked, CheckedState.isFalse);
        expect(firstSet.hasAction(SemanticsAction.tap), isTrue);

        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();
        expect(exercise.completedParents, {0});
        expect(find.byType(TextFormField), findsNWidgets(12));
        expect(find.byTooltip(strings.weightCollapseSets), findsOneWidget);

        for (var index = 1; index < 6; index++) {
          final checkbox = find.byType(Checkbox).at(index);
          await tester.ensureVisible(checkbox);
          await tester.tap(checkbox);
          await tester.pumpAndSettle();
        }
        expect(exercise.completedParents, {0, 1, 2, 3, 4, 5});
        expect(find.byType(TextFormField), findsNothing);
        expect(find.byTooltip(strings.weightExpandSets), findsOneWidget);
        expect(
          tester
              .widget<Card>(
                find.descendant(of: card, matching: find.byType(Card)),
              )
              .shape,
          RoundedRectangleBorder(
            borderRadius: TonosExpressiveWorkoutShapes.exerciseCardCollapsed,
          ),
        );

        await tester.tap(find.byTooltip(strings.weightExpandSets));
        await tester.pumpAndSettle();
        expect(find.byType(Checkbox), findsNWidgets(6));
        expect(
          tester
              .widget<Card>(
                find.descendant(of: card, matching: find.byType(Card)),
              )
              .shape,
          RoundedRectangleBorder(
            borderRadius: TonosExpressiveWorkoutShapes.exerciseCard,
          ),
        );
        expect(
          tester
              .widgetList<Checkbox>(find.byType(Checkbox))
              .map((box) => box.value),
          everyElement(isTrue),
        );
      } finally {
        semantics.dispose();
      }

      await tester.ensureVisible(find.byKey(_addSetKey));
      await tester.tap(find.byKey(_addSetKey));
      await tester.pumpAndSettle();
      expect(addSetCalls, 1);
      expect(exercise.sets, hasLength(7));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('finish action preserves its 48dp semantic button role', (
    tester,
  ) async {
    var finishCalls = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        home: Scaffold(
          body: Center(
            child: WorkoutFinishAction(
              label: 'Finish workout',
              expressiveWorkoutPresentation: true,
              onPressed: () => finishCalls++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    final data = tester.getSemantics(button).getSemanticsData();
    expect(data.label, contains('Finish workout'));
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    await tester.tap(button);
    await tester.pump();
    expect(finishCalls, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Expressive session FAB floats over content and final controls scroll clear',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(432, 936));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final repository = _EmptyRepository();
      final session = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      final units = UnitPreferenceProvider();
      addTearDown(session.dispose);
      addTearDown(units.dispose);
      await Future.wait<void>([session.ready, units.ready]);
      session
        ..exercises.add(_exercise(setCount: 3))
        ..cardTypes.add(CardType.weight)
        ..exercises.add(_exercise(setCount: 3))
        ..cardTypes.add(CardType.weight);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(value: session),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
            Provider<AppRepository>.value(value: repository),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SessionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 421));
      await tester.pumpAndSettle();

      final addFab = find.byType(AddExerciseFab);
      final fabRect = tester.getRect(addFab);
      final listViewport = tester.getRect(find.byType(ListView));
      final removeSetButtons = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip ==
                AppLocalizations.of(tester.element(find.byType(SessionScreen)))
                    .weightRemoveSetTitle,
      );
      expect(removeSetButtons, findsNWidgets(6));
      expect(listViewport.bottom, greaterThan(fabRect.top));
      final finalCardRect = tester
          .getRect(find.byType(ExerciseCard).last)
          .intersect(listViewport);
      expect(finalCardRect.isEmpty, isFalse);
      expect(
        fabRect.overlaps(finalCardRect),
        isTrue,
        reason: 'Exercise content should be able to continue behind the FAB',
      );
      final lastRemoveSet = removeSetButtons.last;
      await tester.ensureVisible(lastRemoveSet);
      await tester.pumpAndSettle();
      final reachableRemoveSetRect = tester.getRect(lastRemoveSet);
      expect(reachableRemoveSetRect.overlaps(fabRect), isFalse);
      expect(
        reachableRemoveSetRect.bottom,
        lessThanOrEqualTo(listViewport.bottom),
      );
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
    (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
  ),
);

Widget _weightCardHost(
  WeightExercise exercise, {
  ThemeData? theme,
  bool expressiveWorkoutPresentation = false,
  double textScale = 1,
  VoidCallback? onSetAdded,
  FocusNode? firstSetWeightFocusNode,
}) => MaterialApp(
  theme: theme ?? ExpressiveThemeDefinition.light(),
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
          child: WeightCard(
            exercise: exercise,
            previewWeightUnit: WeightUnit.pounds,
            expressiveWorkoutPresentation: expressiveWorkoutPresentation,
            animateExpansion: true,
            firstSetWeightKey: _weightKey,
            firstSetRepsKey: _repsKey,
            addSetKey: _addSetKey,
            firstSetWeightFocusNode: firstSetWeightFocusNode,
            onSetAdded: onSetAdded,
          ),
        ),
      ),
    ),
  ),
);

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

class _EmptyRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async => 1;

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int id) async => null;
}
