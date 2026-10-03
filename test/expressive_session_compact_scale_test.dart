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
import 'package:env_test/widgets/weight_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final textScale in [1.15, 1.5, 2.0]) {
    testWidgets(
      'Expressive SessionScreen remains usable at 320dp and ${textScale}x text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 960));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues(<String, Object>{
          'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
        });
        final fixture = await _makeFixture();
        addTearDown(fixture.session.dispose);
        addTearDown(fixture.units.dispose);

        await tester.pumpWidget(_host(fixture, textScale: textScale));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 421));
        await tester.pumpAndSettle();

        final exerciseCard = find.byType(ExerciseCard);
        final weightCard = find.byType(WeightCard);
        final checkboxes = find.byType(Checkbox);
        final finish = find.byKey(AppTestKeys.sessionFinish);

        expect(exerciseCard, findsOneWidget);
        expect(weightCard, findsOneWidget);
        expect(checkboxes, findsNWidgets(4));
        expect(find.byType(TextFormField), findsNWidgets(8));
        expect(find.byType(AddExerciseFab), findsOneWidget);
        expect(finish, findsOneWidget);
        final menuTooltip = MaterialLocalizations.of(tester.element(weightCard))
            .showMenuTooltip;
        final menuFinder = find.byType(MenuAnchor);
        final menuButtonFinder = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == menuTooltip,
        );
        expect(tester.getRect(finish).top, greaterThanOrEqualTo(0));
        expect(tester.getRect(finish).bottom, lessThanOrEqualTo(960));
        expect(tester.takeException(), isNull);

        // The full workout screen remains scrollable, with the set controls
        // and persistent Finish action reachable at compact width.
        final list = find.byType(ListView);
        await tester.drag(list, const Offset(0, -1200));
        await tester.pumpAndSettle();
        final lastCheckboxRect = tester.getRect(checkboxes.last);
        expect(lastCheckboxRect.top, greaterThanOrEqualTo(0));
        expect(lastCheckboxRect.bottom, lessThanOrEqualTo(960));
        expect(tester.getRect(finish).bottom, lessThanOrEqualTo(960));
        expect(tester.takeException(), isNull);

        // The menu starts above the viewport after the list reaches its end;
        // ensureVisible must bring the actual control into the hittable area.
        expect(menuFinder, findsOneWidget);
        expect(menuButtonFinder, findsOneWidget);
        await tester.ensureVisible(menuButtonFinder);
        await tester.pumpAndSettle();
        final listRect = tester.getRect(list);
        final menuButtonRect = tester.getRect(menuButtonFinder);
        expect(menuButtonRect.top, greaterThanOrEqualTo(listRect.top));
        expect(menuButtonRect.bottom, lessThanOrEqualTo(listRect.bottom));
        expect(
          tester.widget<IconButton>(menuButtonFinder).onPressed,
          isNotNull,
        );
        await tester.tap(menuButtonFinder);
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(tester.element(weightCard));
        expect(find.text(strings.weightRemoveExerciseTitle), findsOneWidget);
        expect(find.byType(AddExerciseFab), findsOneWidget);
        expect(find.byKey(AppTestKeys.sessionFinish), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

Widget _host(_SessionFixture fixture, {required double textScale}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ActiveSession>.value(value: fixture.session),
        ChangeNotifierProvider<UnitPreferenceProvider>.value(
          value: fixture.units,
        ),
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
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
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
    ..exercises.add(
      WeightExercise(
        name: 'Squat',
        equipment: 'Barbell',
        sets: List.generate(
          4,
          (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
        ),
      ),
    )
    ..cardTypes.add(CardType.weight);
  return _SessionFixture(
    repository: repository,
    session: session,
    units: units,
  );
}

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
