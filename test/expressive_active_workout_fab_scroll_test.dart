import 'package:material_ui/material_ui.dart';
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
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/exercise_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Expressive session keeps a full-height list and scrolls its end clear of the FAB',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(432, 936));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final fixture = await _makeFixture();
      addTearDown(fixture.session.dispose);
      addTearDown(fixture.units.dispose);

      await tester.pumpWidget(_host(fixture));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 421));
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      final addFab = find.byType(AddExerciseFab);
      final fabRect = tester.getRect(addFab);
      final viewportRect = tester.getRect(list);
      final listPadding = tester.widget<ListView>(list).padding! as EdgeInsets;
      final finish = find.byKey(AppTestKeys.sessionFinish);
      final finishRect = tester.getRect(finish);
      final exerciseCards = find.byType(ExerciseCard);
      expect(exerciseCards, findsNWidgets(2));

      // The list remains full-height behind the floating control.
      expect(viewportRect.bottom, greaterThan(fabRect.top));
      expect(viewportRect.bottom - fabRect.bottom, lessThanOrEqualTo(20));
      expect(listPadding.bottom, 72);
      expect(tester.getRect(exerciseCards.last).overlaps(fabRect), isTrue);
      expect(tester.getSize(finish).height, greaterThanOrEqualTo(48));

      // Reach the natural end of the list, then verify the final set controls
      // are clear of the FAB in the actual max-scroll state.
      final strings = AppLocalizations.of(tester.element(list));
      final removeTargets = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip == strings.weightRemoveSetTitle,
      );
      expect(removeTargets, findsNWidgets(6));
      await tester.drag(list, const Offset(0, -3000));
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable.first).position;
      expect(position.pixels, closeTo(position.maxScrollExtent, 1));
      final scrolledViewportRect = tester.getRect(list);
      final lastCheckboxRect = tester.getRect(find.byType(Checkbox).last);
      final lastWeightFieldRect = tester.getRect(
        find
            .byType(TextFormField)
            .at(find.byType(TextFormField).evaluate().length - 2),
      );
      final lastRepsFieldRect = tester.getRect(find.byType(TextFormField).last);
      final lastRemoveRect = tester.getRect(removeTargets.last);
      for (final controlRect in [
        lastCheckboxRect,
        lastWeightFieldRect,
        lastRepsFieldRect,
        lastRemoveRect,
      ]) {
        expect(scrolledViewportRect.contains(controlRect.topLeft), isTrue);
        expect(scrolledViewportRect.contains(controlRect.bottomRight), isTrue);
        expect(fabRect.overlaps(controlRect), isFalse);
      }
      expect(tester.getRect(finish), finishRect);

      // Add Exercise remains a live floating action at the same location.
      expect(tester.getRect(addFab), fabRect);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keyboard resizing moves the FAB and preserves Finish placement',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(432, 936));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final fixture = await _makeFixture();
      addTearDown(fixture.session.dispose);
      addTearDown(fixture.units.dispose);

      await tester.pumpWidget(_host(fixture));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 421));
      await tester.pumpAndSettle();
      final finishWithoutKeyboard = tester.getRect(
        find.byKey(AppTestKeys.sessionFinish),
      );
      final listWithoutKeyboard = tester.getRect(find.byType(ListView));

      await tester.pumpWidget(
        _host(fixture, viewInsets: const EdgeInsets.only(bottom: 300)),
      );
      await tester.pumpAndSettle();

      final fabRect = tester.getRect(find.byType(AddExerciseFab));
      final finishRect = tester.getRect(find.byKey(AppTestKeys.sessionFinish));
      final listRect = tester.getRect(find.byType(ListView));
      expect(fabRect.bottom, lessThan(936 - 300));
      expect(finishRect, finishWithoutKeyboard);
      expect(listRect.height, lessThan(listWithoutKeyboard.height));
      expect(listRect.bottom, greaterThan(fabRect.top));
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _host(
  _SessionFixture fixture, {
  EdgeInsets viewInsets = EdgeInsets.zero,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider<ActiveSession>.value(value: fixture.session),
    ChangeNotifierProvider<UnitPreferenceProvider>.value(value: fixture.units),
    Provider<AppRepository>.value(value: fixture.repository),
  ],
  child: MaterialApp(
    theme: ExpressiveThemeDefinition.light(),
    themeAnimationDuration: Duration.zero,
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
        child: const SessionScreen(),
      ),
    ),
  ),
);

Future<_SessionFixture> _makeFixture() async {
  final repository = _EmptyRepository();
  final session = ActiveSession(
    repository: repository,
    retryDelay: (_) async {},
  );
  final units = UnitPreferenceProvider();
  await Future.wait<void>([session.ready, units.ready]);
  session
    ..exercises.add(_exercise('Squat'))
    ..cardTypes.add(CardType.weight)
    ..exercises.add(_exercise('Deadlift'))
    ..cardTypes.add(CardType.weight);
  return _SessionFixture(
    repository: repository,
    session: session,
    units: units,
  );
}

WeightExercise _exercise(String name) => WeightExercise(
  name: name,
  equipment: 'Barbell',
  sets: List.generate(
    3,
    (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
  ),
);

class _SessionFixture {
  const _SessionFixture({
    required this.repository,
    required this.session,
    required this.units,
  });

  final AppRepository repository;
  final ActiveSession session;
  final UnitPreferenceProvider units;
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
