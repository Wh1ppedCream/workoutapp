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
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/completed_workout_duration_formatter.dart';
import 'package:env_test/utils/localized_formatters.dart';

void main() {
  testWidgets(
    'Expressive Full History exposes session summaries and opens details',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      const locale = Locale('en');
      final newerSession = WorkoutSession(
        id: 5,
        date: DateTime(2026, 9, 27, 12),
        duration: 2700,
      );
      final olderSession = WorkoutSession(
        id: 4,
        date: DateTime(2026, 9, 26, 12),
        duration: 1800,
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(
              value: _FullHistoryRepository([newerSession, olderSession]),
            ),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            locale: locale,
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
      final newerDate = LocalizedFormatters.date(
        newerSession.calendarDay.toLocalDateTime(),
        locale,
      );
      final olderDate = LocalizedFormatters.date(
        olderSession.calendarDay.toLocalDateTime(),
        locale,
      );
      final newerDuration = formatCompletedWorkoutDuration(
        strings,
        newerSession.duration,
      );
      final newerLabel = strings.fullHistorySessionSummary(
        newerDate,
        newerDuration,
      );
      final newerDateText = find.text(newerDate);
      expect(newerDateText, findsOneWidget);
      final newerSemanticRow = find.ancestor(
        of: newerDateText,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == newerLabel,
        ),
      );
      expect(newerSemanticRow, findsOneWidget);
      expect(
        tester
            .getSemantics(newerSemanticRow)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      final rowSurface = find.ancestor(
        of: newerDateText,
        matching: find.byType(TonosSurface),
      );
      expect(rowSurface, findsOneWidget);
      final surfaces = ExpressiveThemeDefinition.light().surfaceTokens;
      final renderedRow = tester.widget<TonosSurface>(rowSurface);
      expect(renderedRow.color, surfaces.dashboardSection);
      expect(renderedRow.onTap, isNotNull);
      expect(find.text(newerDuration), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(newerDate)).dy,
        lessThan(tester.getTopLeft(find.text(olderDate)).dy),
        reason: 'Full History should preserve newest-first session order.',
      );
      await tester.ensureVisible(find.text(newerDate));
      await tester.tap(find.text(newerDate));
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
    'Expressive Full History remains usable at 320dp across text scales',
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
      final session = WorkoutSession(
        id: 5,
        date: DateTime(2026, 9, 27, 12),
        duration: 2700,
      );
      final repository = _FullHistoryRepository([session]);

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
                home: const FullHistoryScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final strings = AppLocalizations.of(
            tester.element(find.byType(FullHistoryScreen)),
          );
          final date = LocalizedFormatters.date(
            session.calendarDay.toLocalDateTime(),
            locale,
          );
          final duration = formatCompletedWorkoutDuration(
            strings,
            session.duration,
          );
          final dateFinder = find.text(date);
          expect(dateFinder, findsOneWidget);
          expect(find.text(duration), findsOneWidget);
          expect(tester.widget<Text>(dateFinder).softWrap, isTrue);
          final semanticRow = find.ancestor(
            of: dateFinder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.button == true &&
                  widget.properties.label ==
                      strings.fullHistorySessionSummary(date, duration),
            ),
          );
          expect(semanticRow, findsOneWidget);
          expect(
            tester
                .getSemantics(semanticRow)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, text scale $scale',
          );

          await tester.ensureVisible(dateFinder);
          await tester.tap(dateFinder);
          await tester.pumpAndSettle();
          expect(find.byType(SessionDetailScreen), findsOneWidget);
          expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
          await tester.pump(const Duration(milliseconds: 520));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, route at text scale $scale',
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }
    },
    semanticsEnabled: true,
  );
}

class _FullHistoryRepository extends AppRepository {
  _FullHistoryRepository(this.sessions);

  final List<WorkoutSession> sessions;

  @override
  Future<List<WorkoutSession>> fetchWorkoutSessions() async => sessions;

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
