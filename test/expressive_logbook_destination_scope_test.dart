import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/full_history_screen.dart';
import 'package:env_test/screens/exercise/history_screen.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/workout_history_calendar.dart';

void main() {
  testWidgets(
    'Progress Session Detail keeps origin identity at 320dp and 2x text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      final repository = _LogbookRepository([
        WorkoutSession(id: 12, date: DateTime(2026, 10, 3, 12), duration: 1800),
      ], const <WorkoutReportSession>[]);
      final tokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.progress,
        Brightness.light,
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 1800),
                textScaler: TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.progress,
                child: SessionDetailScreen(
                  WorkoutSession(
                    id: 12,
                    date: DateTime(2026, 10, 3, 12),
                    duration: 1800,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final detail = find.byType(SessionDetailScreen);
      expect(
        Theme.of(tester.element(detail))
            .extension<AppExpressiveDestinationTokens>()
            ?.family,
        AppExpressiveDestinationFamily.progress,
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
        tokens.pageCanvas,
      );
      final strings = AppLocalizations.of(tester.element(detail));
      expect(find.text(strings.workoutDetailCompletedSets(1)), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      final metricRail = tester.widget<Wrap>(
        find
            .ancestor(
              of: find.text(strings.workoutDetailVolume),
              matching: find.byType(Wrap),
            )
            .first,
      );
      expect((metricRail.children.first as SizedBox).width, greaterThan(200));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip(strings.workoutDetailEditSession));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ExerciseCard>(find.byType(ExerciseCard))
            .expressiveWorkoutPresentation,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets('Logbook scopes calendar, Full History, and Session Detail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      'guided_tutorial_completed.${TutorialIds.logbookHome}': true,
    });
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);

    final today = DateUtils.dateOnly(DateTime.now());
    final sessions = [
      WorkoutSession(
        id: 12,
        date: today.add(const Duration(hours: 12)),
        duration: 1800,
      ),
      WorkoutSession(
        id: 13,
        date: today.add(const Duration(hours: 16)),
        duration: 3600,
      ),
    ];
    final reportSessions = [
      WorkoutReportSession(
        id: 12,
        date: today.add(const Duration(hours: 12)),
        durationSeconds: 1800,
        totalVolume: 420,
        exerciseCount: 2,
        setCount: 6,
      ),
    ];
    final repository = _LogbookRepository(sessions, reportSessions);
    final activeSession = ActiveSession(repository: repository);
    await activeSession.ready;
    addTearDown(activeSession.dispose);
    final theme = ExpressiveThemeDefinition.light();
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.logbook,
      Brightness.light,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final calendar = find.byType(WorkoutHistoryCalendar);
    expect(
      Theme.of(tester.element(calendar))
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.logbook,
    );
    expect(
      tester.widgetList<TonosSurface>(find.byType(TonosSurface)).first.color,
      tokens.surfacePrimary,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      tokens.pageCanvas,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.selected == true &&
            widget.properties.label?.contains(today.day.toString()) == true,
      ),
      findsOneWidget,
    );
    expect(find.text('M'), findsWidgets);

    for (final mode in ['3M', 'Y', '4Y', 'M']) {
      await tester.tap(find.text(mode).first);
      await tester.pumpAndSettle();
      expect(find.text(mode), findsWidgets);
    }

    final fullHistoryButton = find.byTooltip(
      AppLocalizations.of(tester.element(calendar)).logbookViewAllSessions,
    );
    await tester.ensureVisible(fullHistoryButton);
    await tester.tap(fullHistoryButton);
    await tester.pumpAndSettle();
    expect(find.byType(FullHistoryScreen), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(FullHistoryScreen)))
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.logbook,
    );
    expect(
      find.text(
        AppLocalizations.of(tester.element(find.byType(FullHistoryScreen)))
            .fullHistoryTitle,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TonosSurface && widget.color == tokens.surfaceSecondary,
      ),
      findsOneWidget,
    );
    final historyTime = LocalizedFormatters.time(
      reportSessions.single.displayDateTime,
      const Locale('en'),
    );
    expect(find.text(historyTime), findsOneWidget);

    await tester.tap(find.text(historyTime));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 520));
    await tester.pumpAndSettle();
    expect(find.byType(SessionDetailScreen), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(SessionDetailScreen)))
          .extension<AppExpressiveDestinationTokens>()
          ?.family,
      AppExpressiveDestinationFamily.logbook,
    );
    final strings = AppLocalizations.of(
      tester.element(find.byType(SessionDetailScreen)),
    );
    expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
    expect(find.byIcon(Icons.event_outlined), findsOneWidget);
    expect(find.text(strings.workoutDetailCompletedSets(1)), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.textContaining(' x '), findsOneWidget);
    final detailSummary = find.byWidgetPredicate(
      (widget) =>
          widget is TonosSurface && widget.color == tokens.surfacePrimary,
    );
    expect(detailSummary, findsOneWidget);

    final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
    await tester.ensureVisible(saveAsPlan);
    await tester.tap(saveAsPlan);
    await tester.pumpAndSettle();
    expect(find.byKey(AppTestKeys.workoutPlanName), findsOneWidget);
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _LogbookRepository extends AppRepository {
  _LogbookRepository(this.sessions, this.reportSessions);

  final List<WorkoutSession> sessions;
  final List<WorkoutReportSession> reportSessions;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<WorkoutSession>> fetchWorkoutSessions() async => sessions;

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => reportSessions;

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => const <BodyPart, double>{};

  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async => [
    <String, dynamic>{'id': 8, 'type': 'weight', 'exercise_def_id': 12},
  ];

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async => const <int, WorkoutExerciseRecordBadges>{};

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int definitionId) async =>
      const <String, String?>{'name': 'Squat', 'equipmentName': 'Barbell'};

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int definitionId) async =>
      null;

  @override
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) async => [
    <String, dynamic>{
      'id': 20,
      'parent_set_id': null,
      'weight': 100.0,
      'reps': 5,
    },
  ];

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async =>
      const <BodyPart, double>{};
}
