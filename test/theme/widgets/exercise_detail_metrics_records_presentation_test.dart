import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:env_test/widgets/workout_record_badges.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'exercise detail range labels pluralize across supported locales',
    () async {
      const cases = <({Locale locale, String one, String many})>[
        (locale: Locale('en'), one: '1 rep range', many: '2 rep ranges'),
        (
          locale: Locale('es'),
          one: '1 rango de repeticiones',
          many: '2 rangos de repeticiones',
        ),
        (
          locale: Locale('fr'),
          one: '1 plage de répétitions',
          many: '2 plages de répétitions',
        ),
        (
          locale: Locale('fr', 'CA'),
          one: '1 plage de répétitions',
          many: '2 plages de répétitions',
        ),
        (
          locale: Locale('bn'),
          one: '১টি পুনরাবৃত্তির পরিসর',
          many: '2টি পুনরাবৃত্তির পরিসর',
        ),
        (locale: Locale('hi'), one: '1 रेप रेंज', many: '2 रेप रेंज'),
        (locale: Locale('zh'), one: '1 个重复次数范围', many: '2 个重复次数范围'),
      ];

      for (final item in cases) {
        final strings = await AppLocalizations.delegate.load(item.locale);

        expect(strings.exerciseDetailRanges(1), item.one);
        expect(strings.exerciseDetailRanges(2), item.many);
      }
    },
  );

  testWidgets(
    'Catalog Expressive records hide the left axis and keep a localized empty card',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_detail_v1': true,
      });
      final repository = _RecordsRepository(hasHistory: true);
      final units = UnitPreferenceProvider();
      addTearDown(units.dispose);
      await units.ready;
      await units.setWeightUnit(WeightUnit.kilograms);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: _OpenDetails(),
          ),
        ),
      );
      await tester.tap(find.text('Open details'));
      await tester.pumpAndSettle();
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseDetailSheet)),
      );
      await tester.tap(find.text(strings.exerciseDetailTabRecords));
      await tester.pumpAndSettle();

      final chart = find.byType(LineChart);
      expect(chart, findsOneWidget);
      final yAxisLabels = tester.widgetList<Text>(
        find.descendant(of: chart, matching: find.byType(Text)),
      );
      expect(
        yAxisLabels.any((label) => label.data?.contains('kg') ?? false),
        isFalse,
      );
      expect(
        tester
            .widget<LineChart>(chart)
            .data
            .titlesData
            .leftTitles
            .sideTitles
            .showTitles,
        isFalse,
      );
      expect(
        tester
            .widget<LineChart>(chart)
            .data
            .titlesData
            .leftTitles
            .sideTitles
            .reservedSize,
        0,
      );
      expect(strings.exerciseDetailTopEstimatedOneRm, 'Peak estimated 1RM');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      final emptyRepository = _RecordsRepository(hasHistory: false);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: emptyRepository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: _OpenDetails(),
          ),
        ),
      );
      await tester.tap(find.text('Open details'));
      await tester.pumpAndSettle();
      final emptyStrings = AppLocalizations.of(
        tester.element(find.byType(ExerciseDetailSheet)),
      );
      await tester.tap(find.text(emptyStrings.exerciseDetailTabRecords));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.text(emptyStrings.exerciseDetailNoHistory), findsOneWidget);
      expect(
        find.text(emptyStrings.exerciseDetailNoHistoryBody),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Records distinguishes sessions without chartable sets ${brightness.name}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_detail_v1': true,
          'guided_tutorial_completed.workout_detail_v1': true,
        });
        final repository = _RecordsRepository(
          hasHistory: true,
          trackable: false,
          firstRecord: true,
        );
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        await units.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: _OpenDetails(),
            ),
          ),
        );
        await tester.tap(find.text('Open details'));
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseDetailSheet)),
        );
        await tester.tap(find.text(strings.exerciseDetailTabRecords));
        await tester.pumpAndSettle();

        expect(find.byType(LineChart), findsNothing);
        expect(find.text(strings.exerciseDetailNoChartData), findsOneWidget);
        expect(find.text(strings.fullHistoryTitle), findsNothing);

        final action = find.byKey(
          const ValueKey('exercise-detail-expressive-session-action'),
        );
        await tester.ensureVisible(action);
        expect(action, findsOneWidget);
        expect(tester.getSize(action).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        final actionSurface = find.byKey(
          const ValueKey('exercise-detail-expressive-session-action-surface'),
        );
        expect(actionSurface, findsOneWidget);
        expect(
          tester.getSize(actionSurface).height,
          lessThan(tester.getSize(action).height),
        );
        expect(tester.getSize(actionSurface).height, closeTo(34, 1));
        expect(
          find.bySemanticsLabel(strings.exerciseDetailOpenWorkoutWithSets(1)),
          findsOneWidget,
        );
        final badge = find.byKey(
          const ValueKey('exercise-detail-expressive-first-record-badge'),
        );
        expect(badge, findsOneWidget);
        final badgeDecoration =
            tester.widget<Container>(badge).decoration! as BoxDecoration;
        expect(
          badgeDecoration.color,
          AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.catalog,
            brightness,
          ).surfaceSelected,
        );

        final locale = Localizations.localeOf(
          tester.element(find.byType(ExerciseDetailSheet)),
        );
        final displayDateTime = DateTime(2026, 6, 1, 10);
        final date = LocalizedFormatters.date(displayDateTime, locale);
        final time = LocalizedFormatters.time(displayDateTime, locale);
        expect(find.text(date), findsOneWidget);
        expect(find.text(time), findsOneWidget);
        expect(find.text('8 reps'), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();

        await tester.tap(action);
        await tester.pumpAndSettle();
        final pastWorkout = find.byType(SessionDetailScreen);
        expect(pastWorkout, findsOneWidget);
        expect(tester.widget<SessionDetailScreen>(pastWorkout).session.id, 1);
        expect(
          Theme.of(tester.element(pastWorkout))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.logbook,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(pastWorkout, findsNothing);
        expect(find.byType(ExerciseDetailSheet), findsOneWidget);
        expect(
          Theme.of(tester.element(find.byType(ExerciseDetailSheet)))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.catalog,
        );
        expect(find.text('8 reps'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Catalog records keep set details, badges, and estimated max on one line ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_detail_v1': true,
        });
        final repository = _RecordsRepository(
          hasHistory: true,
          setBadges: {
            0: const [
              WorkoutRecordBadge(
                tier: WorkoutRecordBadgeTier.allTime,
                type: WorkoutRecordBadgeType.repBest,
                reps: 8,
              ),
              WorkoutRecordBadge(
                tier: WorkoutRecordBadgeTier.allTime,
                type: WorkoutRecordBadgeType.volumeBest,
              ),
            ],
          },
        );
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        await units.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: _OpenDetails(),
            ),
          ),
        );
        await tester.tap(find.text('Open details'));
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseDetailSheet)),
        );
        await tester.tap(find.text(strings.exerciseDetailTabMetrics));
        await tester.pumpAndSettle();
        final allTimeOption = find.byKey(
          const ValueKey('exercise-detail-timeframe-all-time-option'),
        );
        final allTimeLabel = find.byKey(
          const ValueKey('exercise-detail-timeframe-all-time-label'),
        );
        expect(allTimeOption, findsOneWidget);
        expect(allTimeLabel, findsOneWidget);
        final allTimeAccent = catalogBrowserAllTimeBadgeAccent(
          tester.element(allTimeLabel),
        );
        final catalogTokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          brightness,
        );
        expect(
          tester.widget<Text>(allTimeLabel).style?.color,
          brightness == Brightness.light
              ? allTimeAccent
              : catalogTokens.onSurfacePrimary,
        );
        final allTimeDecoration =
            tester.widget<AnimatedContainer>(allTimeOption).decoration!
                as BoxDecoration;
        expect(
          allTimeDecoration.color,
          brightness == Brightness.light
              ? allTimeAccent.withValues(alpha: 0.22)
              : catalogTokens.surfacePrimary,
        );
        await tester.tap(find.text(strings.exerciseDetailTabRecords));
        await tester.pumpAndSettle();

        final setDetails = find.byKey(
          const ValueKey('exercise-detail-record-set-details'),
        );
        final badgeRow = find.byKey(
          const ValueKey('exercise-detail-record-set-badges'),
        );
        expect(setDetails, findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.descendant(of: setDetails, matching: find.byType(Text)),
              )
              .data,
          contains('x 8'),
        );
        expect(badgeRow, findsOneWidget);
        expect(
          tester.getRect(badgeRow).center.dy,
          closeTo(tester.getRect(setDetails).center.dy, 1),
        );
        final estimatedMax = find.byKey(
          const ValueKey('exercise-detail-record-estimated-max'),
        );
        expect(estimatedMax, findsOneWidget);
        expect(
          tester.getRect(estimatedMax).center.dy,
          closeTo(tester.getRect(setDetails).center.dy, 1),
        );
        expect(
          find.byKey(const ValueKey('exercise-detail-record-estimated-max')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('exercise-detail-catalog-record-badge')),
          findsNWidgets(2),
        );
        final chart = tester.widget<LineChart>(find.byType(LineChart));
        expect(chart.data.minX, 0);
        expect(chart.data.maxX, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive long exercise title stays clear of close control ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_detail_v1': true,
        });
        final units = UnitPreferenceProvider();
        addTearDown(units.dispose);
        await units.ready;
        final longTitle = 'Single Arm Incline Chest Supported Dumbbell Row';
        final definition = ExerciseDefinition(
          id: 2,
          name: longTitle,
          equipmentList: [],
          bodyParts: [BodyPart(1, 'Chest')],
          muscles: [],
          setupNotes: '',
          executionNotes: '',
          tipsNotes: '',
          useManualBodyparts: false,
          multiplyByRating: false,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(
                value: _RecordsRepository(hasHistory: false),
              ),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: _OpenDetails(definition: definition),
            ),
          ),
        );
        await tester.tap(find.text('Open details'));
        await tester.pumpAndSettle();

        final title = find.text(longTitle);
        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseDetailSheet)),
        );
        final close = find.byTooltip(strings.commonClose);
        expect(title, findsOneWidget);
        expect(close, findsOneWidget);
        expect(
          tester.getRect(title).overlaps(tester.getRect(close)),
          isFalse,
          reason:
              'title ${tester.getRect(title)} overlaps close ${tester.getRect(close)}',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

final _definition = ExerciseDefinition(
  id: 1,
  name: 'Goblet Squat',
  equipmentList: [],
  bodyParts: [BodyPart(1, 'Chest')],
  muscles: [],
  setupNotes: '',
  executionNotes: '',
  tipsNotes: '',
  useManualBodyparts: false,
  multiplyByRating: false,
);

class _OpenDetails extends StatelessWidget {
  _OpenDetails({ExerciseDefinition? definition})
    : definition = definition ?? _definition;

  final ExerciseDefinition definition;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => ExerciseDetailSheet.show(
          context: context,
          definition: definition,
          defId: definition.id,
        ),
        child: const Text('Open details'),
      ),
    ),
  );
}

class _RecordsRepository extends AppRepository {
  _RecordsRepository({
    required this.hasHistory,
    this.trackable = true,
    this.firstRecord = false,
    this.setBadges = const {},
  }) : super(db: _RecordsDatabase());

  final bool hasHistory;
  final bool trackable;
  final bool firstRecord;
  final Map<int, List<WorkoutRecordBadge>> setBadges;

  @override
  Future<WorkoutSession?> fetchSessionById(int sessionId) async =>
      WorkoutSession(
        id: sessionId,
        date: DateTime(2026, 6, 1, 10),
        duration: 60,
      );

  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sid) async => [];

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async => {};

  @override
  Future<ContentManifest> syncBundledExerciseMediaManifest() async =>
      throw UnimplementedError();

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async =>
      firstRecord || setBadges.isNotEmpty
      ? {
          1: WorkoutExerciseRecordBadges(
            isFirstRecord: firstRecord,
            setBadges: setBadges,
          ),
        }
      : {};

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async => hasHistory
      ? [
          {
            'exercise_id': 1,
            'session_id': 1,
            'session_date': '2026-06-01T10:00:00.000',
            'session_completed_at_ms': DateTime(
              2026,
              6,
              1,
              10,
            ).millisecondsSinceEpoch,
            'session_training_day': '2026-06-01',
          },
        ]
      : [];

  @override
  Future<WeightExercise?> fetchDetailedExercise(int id) async => WeightExercise(
    name: 'Goblet Squat',
    equipment: 'Dumbbell',
    sets: [ExerciseSet(weight: trackable ? 40 : 0, reps: 8)],
  );

  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      [];

  @override
  Future<double?> fetchVolumeMax(int defId, String timeframe) async => null;
}

class _RecordsDatabase implements DatabaseHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
