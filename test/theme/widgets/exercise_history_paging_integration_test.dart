import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _definition = ExerciseDefinition(
  id: 1,
  name: 'Paging exercise',
  useManualBodyparts: false,
  multiplyByRating: false,
);

class _PagingRepository extends AppRepository {
  final cursors = <int?>[];
  var badgeReads = 0;
  var failNextPage = false;
  var failInitial = false;

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async {
    cursors.add(beforeExerciseId);
    if (failInitial || (beforeExerciseId != null && failNextPage)) {
      failNextPage = false;
      throw StateError('private SQLite detail must never be displayed');
    }
    return [
      for (
        var id = beforeExerciseId == null ? 12 : beforeExerciseId - 1;
        id > 0 && id > (beforeExerciseId ?? 13) - 1 - limit;
        id--
      )
        {
          'exercise_id': id,
          'session_id': id,
          'session_date': '2026-10-${id.toString().padLeft(2, '0')}T10:00:00Z',
          'session_training_day': '2026-10-${id.toString().padLeft(2, '0')}',
        },
    ];
  }

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async {
    badgeReads++;
    return {};
  }

  @override
  Future<WorkoutExercise?> fetchDetailedExercise(int id) async =>
      WeightExercise(
        name: 'Paging exercise',
        equipment: '',
        sets: [ExerciseSet(weight: id.toDouble(), reps: 8)],
      );

  @override
  Future<ContentManifest> syncBundledExerciseMediaManifest() async =>
      throw StateError('optional media unavailable');
  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;
  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      [];
  @override
  Future<double?> fetchVolumeMax(int defId, String timeframe) async => null;
  @override
  Future<WorkoutSession?> fetchSessionById(int sessionId) async =>
      WorkoutSession(
        id: sessionId,
        date: DateTime(2026, 10, sessionId, 10),
        duration: 60,
      );
  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sid) async => [];
  @override
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async => {};
}

Future<AppLocalizations> _openRecords(
  WidgetTester tester,
  _PagingRepository repository,
  AppThemeFamily family,
  Brightness brightness, {
  AppExpressiveDestinationFamily? parentScope,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({
    'guided_tutorial_completed.exercise_detail_v1': true,
    'guided_tutorial_completed.workout_detail_v1': true,
  });
  final units = UnitPreferenceProvider();
  addTearDown(units.dispose);
  await units.ready;
  final opener = Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => ExerciseDetailSheet.show(
          context: context,
          definition: _definition,
          defId: 1,
        ),
        child: const Text('Open records'),
      ),
    ),
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? AppThemeFactory.dark(family)
            : AppThemeFactory.light(family),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: parentScope == null
            ? opener
            : AppExpressiveDestinationTheme(family: parentScope, child: opener),
      ),
    ),
  );
  await tester.tap(find.text('Open records'));
  await tester.pumpAndSettle();
  final strings = AppLocalizations.of(
    tester.element(find.byType(ExerciseDetailSheet)),
  );
  await tester.tap(find.text(strings.exerciseDetailTabRecords));
  await tester.pumpAndSettle();
  return strings;
}

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'Records paging, retry and session-return refresh ${family.name} ${brightness.name}',
        (tester) async {
          final repository = _PagingRepository();
          final strings = await _openRecords(
            tester,
            repository,
            family,
            brightness,
          );
          expect(repository.cursors, [null]);
          final loadMore = find.text(strings.exerciseDetailLoadMoreSessions);
          await tester.dragUntilVisible(
            loadMore,
            find.byType(ListView).last,
            const Offset(0, -350),
            maxIteration: 24,
          );
          await tester.pumpAndSettle();
          repository.failNextPage = true;
          await tester.tap(loadMore);
          await tester.pumpAndSettle();
          expect(
            find.text(strings.exerciseDetailHistoryLoadFailed),
            findsOneWidget,
          );
          expect(repository.cursors, [null, 3]);
          expect(tester.takeException(), isNull);
          await tester.tap(loadMore);
          await tester.pumpAndSettle();
          expect(repository.cursors, [null, 3, 3]);
          expect(loadMore, findsNothing);
          expect(find.textContaining('private SQLite'), findsNothing);

          final action = find
              .descendant(
                of: find
                    .byWidgetPredicate(
                      (widget) =>
                          widget is Semantics &&
                          widget.properties.label ==
                              strings.exerciseDetailOpenWorkoutWithSets(1),
                    )
                    .last,
                matching: find.byType(InkWell),
              )
              .first;
          await tester.ensureVisible(action);
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(find.byType(SessionDetailScreen), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(repository.cursors.last, isNull);
          expect(repository.badgeReads, 2);
          expect(find.byType(ExerciseDetailSheet), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final parentScope in [
    AppExpressiveDestinationFamily.catalog,
    AppExpressiveDestinationFamily.progress,
    AppExpressiveDestinationFamily.logbook,
    AppExpressiveDestinationFamily.analytics,
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'Records uses approved Catalog scope from ${parentScope.name} ${brightness.name}',
        (tester) async {
          final repository = _PagingRepository();
          await _openRecords(
            tester,
            repository,
            AppThemeFamily.expressive,
            brightness,
            parentScope: parentScope,
          );
          final sheet = find.byType(ExerciseDetailSheet);
          expect(
            Theme.of(tester.element(sheet))
                .extension<AppExpressiveDestinationTokens>()
                ?.family,
            AppExpressiveDestinationFamily.catalog,
          );
          expect(
            tester
                .widget<ExerciseDetailSheet>(sheet)
                .catalogBrowserDetailRefinement,
            isTrue,
          );
          expect(repository.cursors, [null]);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('initial Records failure renders safe existing error copy', (
    tester,
  ) async {
    final repository = _PagingRepository()..failInitial = true;
    final strings = await _openRecords(
      tester,
      repository,
      AppThemeFamily.expressive,
      Brightness.light,
    );
    expect(find.text(strings.exerciseDetailHistoryLoadFailed), findsOneWidget);
    expect(find.textContaining('private SQLite'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
