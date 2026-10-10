import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/workout_exit_preferences.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/ongoing_session_fab.dart';
import 'package:env_test/widgets/session_complete_sheet.dart';

void main() {
  testWidgets('Expressive completed-work exit dialog keeps actions reachable '
      'at compact sizes', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const cases = <({Size size, double scale})>[
      (size: Size(320, 760), scale: 1),
      (size: Size(320, 760), scale: 1.5),
      (size: Size(320, 760), scale: 2),
      (size: Size(390, 844), scale: 1),
      (size: Size(390, 844), scale: 2),
      (size: Size(640, 360), scale: 1.5),
      (size: Size(640, 360), scale: 2),
      (size: Size(800, 360), scale: 1),
      (size: Size(800, 360), scale: 1.5),
      (size: Size(800, 360), scale: 2),
    ];
    tester.view.devicePixelRatio = 1;

    for (final testCase in cases) {
      tester.view.physicalSize = testCase.size;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'workout_exit_behavior': WorkoutExitBehavior.askEveryTime.name,
      });
      final session = ActiveSession(
        repository: _OverlayTestRepository(),
        retryDelay: (_) async {},
      );
      await session.ready;
      session.exercises.add(
        WeightExercise(
          name: 'Squat',
          equipment: 'Barbell',
          sets: [ExerciseSet(), ExerciseSet()],
          completedParents: <int>{0, 1},
        ),
      );
      session.cardTypes.add(CardType.weight);

      await tester.pumpWidget(
        ChangeNotifierProvider<ActiveSession>.value(
          value: session,
          child: _expressiveHost(
            testCase.scale,
            Scaffold(
              body: const SizedBox.expand(),
              floatingActionButton: const OngoingSessionFab(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.ongoingSessionMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AppTestKeys.ongoingSessionExit));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      expect(dialog, findsOneWidget);
      final dialogRect = tester.getRect(dialog);
      expect(dialogRect.left, greaterThanOrEqualTo(0));
      expect(dialogRect.right, lessThanOrEqualTo(testCase.size.width));
      expect(dialogRect.top, greaterThanOrEqualTo(0));
      expect(
        dialogRect.bottom,
        lessThanOrEqualTo(testCase.size.height),
        reason: '${testCase.size}, text scale ${testCase.scale}',
      );

      final strings = AppLocalizations.of(tester.element(dialog));
      for (final label in [
        strings.sessionCancelDelete,
        strings.sessionEndSave,
        strings.sessionRememberChoice,
      ]) {
        final text = find.text(label, skipOffstage: false);
        expect(text, findsOneWidget, reason: label);
        await tester.ensureVisible(text);
        await tester.pumpAndSettle();
        final rect = tester.getRect(text);
        expect(rect.left, greaterThanOrEqualTo(dialogRect.left));
        expect(rect.right, lessThanOrEqualTo(dialogRect.right));
        expect(rect.top, greaterThanOrEqualTo(dialogRect.top));
        expect(
          rect.bottom,
          lessThanOrEqualTo(dialogRect.bottom),
          reason:
              '${testCase.size}, scale ${testCase.scale}, $label, $rect / $dialogRect',
        );
      }
      expect(
        tester.takeException(),
        isNull,
        reason: '${testCase.size}, text scale ${testCase.scale}',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      session.dispose();
    }
  });

  testWidgets(
    'Expressive empty-work exit confirmation keeps recovery action reachable',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;

      for (final viewport in [
        (size: const Size(320, 760), scale: 2.0),
        (size: const Size(640, 360), scale: 2.0),
      ]) {
        tester.view.physicalSize = viewport.size;
        SharedPreferences.setMockInitialValues(<String, Object>{
          'workout_exit_behavior': WorkoutExitBehavior.askEveryTime.name,
        });
        final session = ActiveSession(
          repository: _OverlayTestRepository(),
          retryDelay: (_) async {},
        );
        await session.ready;

        await tester.pumpWidget(
          ChangeNotifierProvider<ActiveSession>.value(
            value: session,
            child: _expressiveHost(
              viewport.scale,
              Scaffold(
                body: const SizedBox.expand(),
                floatingActionButton: const OngoingSessionFab(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.ongoingSessionMenu));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.ongoingSessionExit));
        await tester.pumpAndSettle();

        final dialog = find.byType(Dialog);
        expect(dialog, findsOneWidget);
        final rect = tester.getRect(dialog);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(viewport.size.width));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(viewport.size.height));
        final strings = AppLocalizations.of(tester.element(dialog));
        final keep = find.text(strings.sessionKeepWorkout);
        expect(keep, findsOneWidget);
        final keepRect = tester.getRect(keep);
        expect(keepRect.left, greaterThanOrEqualTo(rect.left));
        expect(keepRect.right, lessThanOrEqualTo(rect.right));
        expect(keepRect.bottom, lessThanOrEqualTo(rect.bottom));
        expect(tester.takeException(), isNull);

        await tester.tap(keep);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        session.dispose();
      }
    },
  );

  testWidgets('Expressive completion sheet keeps Done fixed while long results '
      'remain scrollable', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const cases = <({Size size, double scale})>[
      (size: Size(320, 760), scale: 1),
      (size: Size(320, 760), scale: 1.5),
      (size: Size(320, 760), scale: 2),
      (size: Size(390, 844), scale: 1),
      (size: Size(390, 844), scale: 2),
      (size: Size(640, 360), scale: 1.5),
      (size: Size(640, 360), scale: 2),
      (size: Size(800, 360), scale: 1),
      (size: Size(800, 360), scale: 1.5),
      (size: Size(800, 360), scale: 2),
    ];
    tester.view.devicePixelRatio = 1;

    for (final testCase in cases) {
      tester.view.physicalSize = testCase.size;
      final scrollController = ScrollController();
      var completed = false;
      await tester.pumpWidget(
        _expressiveHost(
          testCase.scale,
          Scaffold(
            body: SizedBox.expand(
              child: WorkoutCompletionPresentation(
                exercises: _completionExercises(),
                totalSets: 20,
                duration: '2h 34m',
                volume: '7.7k lbs',
                onDone: () => completed = true,
                doneButtonKey: AppTestKeys.sessionCompleteDone,
                scrollController: scrollController,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byKey(AppTestKeys.sessionCompleteDone), findsOneWidget);
      final doneRect = tester.getRect(
        find.byKey(AppTestKeys.sessionCompleteDone),
      );
      expect(doneRect.left, greaterThanOrEqualTo(0));
      expect(doneRect.right, lessThanOrEqualTo(testCase.size.width));
      expect(doneRect.bottom, lessThanOrEqualTo(testCase.size.height));
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -8000));
      await tester.pumpAndSettle();
      expect(find.text('Long-name exercise 5'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(AppTestKeys.sessionCompleteDone)).bottom,
        lessThanOrEqualTo(testCase.size.height),
      );
      await tester.tap(find.byKey(AppTestKeys.sessionCompleteDone));
      expect(completed, isTrue);
      expect(
        tester.takeException(),
        isNull,
        reason: '${testCase.size}, text scale ${testCase.scale}',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      scrollController.dispose();
    }
  });
}

Widget _expressiveHost(double textScale, Widget child) => MaterialApp(
  theme: ExpressiveThemeDefinition.light(),
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, appChild) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: appChild!,
  ),
  home: child,
);

List<WorkoutCompletionExercise> _completionExercises() => [
  for (var index = 1; index <= 5; index++)
    WorkoutCompletionExercise(
      exercise: WeightExercise(
        name: 'Long-name exercise $index',
        equipment: 'Barbell',
        sets: [
          for (var set = 0; set < 4; set++) ExerciseSet(weight: 135, reps: 8),
        ],
      ),
      weightUnit: WeightUnit.pounds,
      badges: const WorkoutExerciseRecordBadges(isFirstRecord: false),
    ),
];

class _OverlayTestRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];
}
