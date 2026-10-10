import 'dart:ui' show SemanticsAction;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/full_history_screen.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/completed_workout_duration_formatter.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';

void main() {
  testWidgets(
    'Expressive Full History groups dates and exposes session summaries',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      const locale = Locale('en');
      final newerSession = _reportSession(
        id: 5,
        date: DateTime(2026, 9, 27, 18),
        durationSeconds: 2700,
        exerciseCount: 2,
        setCount: 6,
        totalVolume: 1300,
      );
      final olderSession = _reportSession(
        id: 4,
        date: DateTime(2026, 9, 26, 12),
        durationSeconds: 1800,
        exerciseCount: 1,
        setCount: 4,
        totalVolume: 0,
      );
      final repository = _FullHistoryRepository([olderSession, newerSession]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            locale: locale,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.logbook,
              child: FullHistoryScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(FullHistoryScreen));
      final strings = AppLocalizations.of(screenContext);
      final newerDate = LocalizedFormatters.date(
        newerSession.calendarDay.toLocalDateTime(),
        locale,
      );
      final olderDate = LocalizedFormatters.date(
        olderSession.calendarDay.toLocalDateTime(),
        locale,
      );
      final newerTime = LocalizedFormatters.time(
        newerSession.displayDateTime,
        locale,
      );
      final newerDuration = formatCompletedWorkoutDuration(
        strings,
        newerSession.durationSeconds,
      );
      final newerMetadata = strings.logbookSessionSummary(
        newerDuration,
        newerSession.exerciseCount,
        newerSession.setCount,
        WeightUnitFormatter.formatVolume(
          newerSession.totalVolume,
          WeightUnit.pounds,
          locale: locale,
        ),
      );
      final newerAccessibleLabel = strings.fullHistorySessionSummary(
        newerDate,
        '$newerTime. $newerMetadata',
      );

      expect(find.text(newerDate), findsOneWidget);
      expect(find.text(newerTime), findsOneWidget);
      expect(find.text(newerMetadata), findsOneWidget);
      final newerSemanticRow = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == newerAccessibleLabel,
      );
      expect(newerSemanticRow, findsOneWidget);
      final newerSemantics = tester
          .getSemantics(newerSemanticRow)
          .getSemanticsData();
      expect(newerSemantics.label, newerAccessibleLabel);
      expect(newerSemantics.hasAction(SemanticsAction.tap), isTrue);
      final rowSize = tester.getSize(newerSemanticRow);
      expect(rowSize.height, greaterThanOrEqualTo(56));
      expect(rowSize.height, lessThan(100));

      final destinationTokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.logbook,
        Brightness.light,
      );
      final groupPanelFinder = find.ancestor(
        of: newerSemanticRow,
        matching: find.byType(TonosSurface),
      );
      expect(groupPanelFinder, findsOneWidget);
      final groupPanel = tester.widget<TonosSurface>(groupPanelFinder);
      expect(groupPanel.color, destinationTokens.surfaceSecondary);
      expect(groupPanel.onTap, isNull);
      expect(
        groupPanel.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      );

      final dateBandFinder = find.ancestor(
        of: find.text(newerDate),
        matching: find.byType(TonosSurface),
      );
      final dateBand = tester.widget<TonosSurface>(dateBandFinder);
      expect(dateBand.color, destinationTokens.surfacePrimary);
      expect(
        dateBand.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      );
      expect(
        tester.getTopLeft(find.text(newerDate)).dy,
        lessThan(tester.getTopLeft(find.text(olderDate)).dy),
        reason: 'Full History should preserve newest-first date order.',
      );

      await tester.ensureVisible(find.text(newerTime));
      await tester.tap(find.text(newerTime));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 520));
      await tester.pumpAndSettle();
      expect(find.byType(SessionDetailScreen), findsOneWidget);
      expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Expressive Full History uses one content surface per date with row dividers',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      final sameDay = DateTime(2026, 9, 27);
      final repositorySessions = [
        _reportSession(
          id: 4,
          date: DateTime(2026, 9, 26, 6),
          durationSeconds: 1500,
        ),
        _reportSession(
          id: 5,
          date: sameDay.add(const Duration(hours: 8)),
          durationSeconds: 1200,
        ),
        _reportSession(
          id: 6,
          date: sameDay.add(const Duration(hours: 10)),
          durationSeconds: 1800,
        ),
        _reportSession(
          id: 7,
          date: sameDay.add(const Duration(hours: 12)),
          durationSeconds: 2700,
        ),
      ];
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(
              value: _FullHistoryRepository(repositorySessions),
            ),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.logbook,
              child: FullHistoryScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.logbook,
        Brightness.light,
      );
      final surfaces = tester
          .widgetList<TonosSurface>(find.byType(TonosSurface))
          .toList();
      expect(
        surfaces.where((surface) => surface.color == tokens.surfaceSecondary),
        hasLength(2),
        reason: 'A shared supporting surface should contain each date group.',
      );
      expect(
        surfaces.where((surface) => surface.color == tokens.surfacePrimary),
        hasLength(2),
        reason: 'Each day should have one compact plum identity header.',
      );
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byType(InkWell), findsNWidgets(4));

      final locale = Localizations.localeOf(
        tester.element(find.byType(FullHistoryScreen)),
      );
      final orderedSessions = repositorySessions.reversed.toList();
      final displayedTimes = orderedSessions
          .map(
            (session) =>
                LocalizedFormatters.time(session.displayDateTime, locale),
          )
          .toList();
      expect(find.text(displayedTimes[0]), findsOneWidget);
      expect(find.text(displayedTimes[1]), findsOneWidget);
      expect(find.text(displayedTimes[2]), findsOneWidget);
      expect(find.text(displayedTimes[3]), findsOneWidget);
      for (var index = 0; index < displayedTimes.length - 1; index++) {
        expect(
          tester.getTopLeft(find.text(displayedTimes[index])).dy,
          lessThan(tester.getTopLeft(find.text(displayedTimes[index + 1])).dy),
          reason:
              'Session order within and across date groups is newest first.',
        );
      }

      final firstGroupDate = LocalizedFormatters.date(
        orderedSessions.first.calendarDay.toLocalDateTime(),
        locale,
      );
      expect(find.text(firstGroupDate), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Expressive Full History wraps at 320dp and remains accessible through 2x text',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(320, 1800));

      const locale = Locale('en');
      final repositorySessions = [
        _reportSession(
          id: 3,
          date: DateTime(2026, 9, 26, 6),
          durationSeconds: 1500,
          exerciseCount: 1,
          setCount: 2,
          totalVolume: 450,
        ),
        _reportSession(
          id: 4,
          date: DateTime(2026, 9, 27, 10),
          durationSeconds: 1800,
          exerciseCount: 2,
          setCount: 5,
          totalVolume: 1300,
        ),
        _reportSession(
          id: 5,
          date: DateTime(2026, 9, 27, 12),
          durationSeconds: 2700,
          exerciseCount: 3,
          setCount: 8,
          totalVolume: 2750,
        ),
      ];
      final repository = _FullHistoryRepository(repositorySessions);

      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        for (final scale in [1.0, 1.15, 1.5, 2.0]) {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                locale: locale,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: const AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.logbook,
                  child: FullHistoryScreen(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final strings = AppLocalizations.of(
            tester.element(find.byType(FullHistoryScreen)),
          );
          final newest = repositorySessions.last;
          final date = LocalizedFormatters.date(
            newest.calendarDay.toLocalDateTime(),
            locale,
          );
          final time = LocalizedFormatters.time(newest.displayDateTime, locale);
          final duration = formatCompletedWorkoutDuration(
            strings,
            newest.durationSeconds,
          );
          final metadata = strings.logbookSessionSummary(
            duration,
            newest.exerciseCount,
            newest.setCount,
            WeightUnitFormatter.formatVolume(
              newest.totalVolume,
              WeightUnit.pounds,
              locale: locale,
            ),
          );
          final semanticLabel = strings.fullHistorySessionSummary(
            date,
            '$time. $metadata',
          );
          expect(find.text(date), findsOneWidget);
          expect(find.text(time), findsOneWidget);
          expect(find.text(metadata), findsOneWidget);
          final semanticRow = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.label == semanticLabel,
          );
          expect(semanticRow, findsOneWidget);
          final semantics = tester.getSemantics(semanticRow).getSemanticsData();
          expect(semantics.label, semanticLabel);
          expect(semantics.hasAction(SemanticsAction.tap), isTrue);
          expect(
            tester.getSize(semanticRow).height,
            greaterThanOrEqualTo(56),
            reason: '${brightness.name}, text scale $scale',
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, text scale $scale',
          );

          await tester.ensureVisible(find.text(time));
          await tester.tap(find.text(time));
          await tester.pumpAndSettle();
          expect(find.byType(SessionDetailScreen), findsOneWidget);
          expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
          await tester.pump(const Duration(milliseconds: 520));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, detail route at text scale $scale',
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }
    },
    semanticsEnabled: true,
  );

  testWidgets('Full History metadata and grouping remain Expressive-only', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
    });
    final session = _reportSession(
      id: 5,
      date: DateTime(2026, 9, 27, 12),
      durationSeconds: 2700,
      exerciseCount: 2,
      setCount: 6,
      totalVolume: 1300,
    );
    final expectedDate = LocalizedFormatters.date(
      session.calendarDay.toLocalDateTime(),
      const Locale('en'),
    );

    final themes = <(String, ThemeData)>[
      ('Classic', ClassicThemeDefinition.light()),
      ('Neo', NeoBrutalismThemeDefinition.light()),
    ];
    for (final (name, theme) in themes) {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(
              value: _FullHistoryRepository([session]),
            ),
          ],
          child: MaterialApp(
            theme: theme,
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FullHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(FullHistoryScreen)),
      );
      final duration = formatCompletedWorkoutDuration(
        strings,
        session.durationSeconds,
      );
      final time = LocalizedFormatters.time(
        session.displayDateTime,
        const Locale('en'),
      );
      final metadata = strings.logbookSessionSummary(
        duration,
        session.exerciseCount,
        session.setCount,
        WeightUnitFormatter.formatVolume(
          session.totalVolume,
          WeightUnit.pounds,
          locale: const Locale('en'),
        ),
      );
      expect(
        find.text(strings.fullHistorySessionSummary(expectedDate, duration)),
        findsOneWidget,
        reason: '$name retains its existing summary row.',
      );
      expect(find.text(time), findsNothing, reason: '$name is unchanged.');
      expect(find.text(metadata), findsNothing, reason: '$name is unchanged.');
    }
  });
}

WorkoutReportSession _reportSession({
  required int id,
  required DateTime date,
  required int durationSeconds,
  double totalVolume = 0,
  int exerciseCount = 1,
  int setCount = 1,
}) => WorkoutReportSession(
  id: id,
  date: date,
  durationSeconds: durationSeconds,
  totalVolume: totalVolume,
  exerciseCount: exerciseCount,
  setCount: setCount,
);

class _FullHistoryRepository extends AppRepository {
  _FullHistoryRepository(this.sessions);

  final List<WorkoutReportSession> sessions;

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => sessions;

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
  Future<Map<BodyPart, double>> computeBodyPartPercents(
    int definitionId,
  ) async => const <BodyPart, double>{};
}
