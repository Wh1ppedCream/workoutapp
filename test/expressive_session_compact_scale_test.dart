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
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(320, 960);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
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

        expect(tester.takeException(), isNull);
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

  testWidgets('Expressive SessionScreen adapts across viewport sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
    });
    final fixture = await _makeFixture();
    addTearDown(fixture.session.dispose);
    addTearDown(fixture.units.dispose);

    const viewports = <(double, double, double)>[
      (320, 960, 1),
      (360, 800, 1),
      (390, 844, 1),
      (430, 932, 1),
      (600, 960, 1),
      (800, 1100, 1),
      (1024, 1366, 1),
      (640, 360, 1),
      (1024, 768, 1),
      (320, 720, 2),
      (390, 844, 1.3),
      (430, 932, 1.5),
      (800, 600, 1.5),
    ];

    for (final (width, height, textScale) in viewports) {
      tester.view.physicalSize = Size(width, height);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      await tester.pumpWidget(_host(fixture, textScale: textScale));
      await tester.pumpAndSettle();

      final cardRect = tester.getRect(find.byType(ExerciseCard));
      expect(
        cardRect.width,
        lessThanOrEqualTo(width < 792 ? width - 32 : 760),
        reason: 'card width $width, height $height, text $textScale',
      );
      final finishRect = tester.getRect(find.byKey(AppTestKeys.sessionFinish));
      final bottomSafeArea = find
          .ancestor(
            of: find.byKey(AppTestKeys.sessionFinish),
            matching: find.byType(SafeArea),
          )
          .first;
      final bottomBarRect = tester.getRect(bottomSafeArea);
      expect(
        bottomBarRect.height,
        lessThanOrEqualTo(finishRect.height + 16),
        reason: 'Finish bar should wrap its action at $width×$height',
      );
      final sessionListRect = tester.getRect(find.byType(ListView));
      expect(
        sessionListRect.height,
        greaterThan(0),
        reason: 'Session list should retain a viewport at $width×$height',
      );
      expect(finishRect.top, greaterThanOrEqualTo(0));
      expect(finishRect.bottom, lessThanOrEqualTo(height));
      expect(
        tester.takeException(),
        isNull,
        reason: 'width $width, height $height, text $textScale',
      );
    }
  });

  testWidgets(
    'Expressive session keeps focused inputs and finish action inset',
    (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
      });
      final fixture = await _makeFixture();
      addTearDown(fixture.session.dispose);
      addTearDown(fixture.units.dispose);

      await tester.pumpWidget(_host(fixture, textScale: 1.5, bottomInset: 280));
      await tester.pumpAndSettle();
      final weightField = find.byType(TextFormField).first;
      await tester.tap(weightField);
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue,
      );
      expect(
        tester.getRect(weightField).bottom,
        lessThanOrEqualTo(360),
        reason: 'the focused field should remain above the represented keyboard inset',
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(fixture, textScale: 1.5));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(AppTestKeys.sessionFinish)).bottom,
        lessThanOrEqualTo(640),
        reason: 'the Finish action should return within screen bounds after IME dismissal',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _host(
  _SessionFixture fixture, {
  required double textScale,
  double bottomInset = 0,
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
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: bottomInset),
        ),
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
