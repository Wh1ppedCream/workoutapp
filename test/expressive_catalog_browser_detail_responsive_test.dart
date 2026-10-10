import 'dart:ui' show Tristate;

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const browserDetailViewports = <({String label, Size size})>[
    (label: '320 dp compact portrait', size: Size(320, 780)),
    (label: '390 dp phone', size: Size(390, 844)),
    (label: '600 dp compact tablet', size: Size(600, 960)),
    (label: '800 dp tablet', size: Size(800, 1280)),
    (label: '1024 dp tablet', size: Size(1024, 768)),
    (label: 'compact landscape', size: Size(640, 360)),
    (label: 'wide landscape', size: Size(800, 360)),
  ];

  for (final brightness in Brightness.values) {
    for (final viewport in browserDetailViewports) {
      testWidgets('Expressive browser and detail fit ${viewport.label} in '
          '${brightness.name}', (tester) async {
        await tester.binding.setSurfaceSize(viewport.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
          'guided_tutorial_completed.exercise_detail_v1': true,
        });

        final repository = _CatalogDetailRepository();
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = _CatalogDetailDatabase.profiles.first;
        final units = UnitPreferenceProvider();
        addTearDown(profile.dispose);
        addTearDown(units.dispose);
        await units.ready;
        final theme = brightness == Brightness.dark
            ? ExpressiveThemeDefinition.dark()
            : ExpressiveThemeDefinition.light();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              ),
              home: const ExerciseCatalogPage(
                expressiveCatalogPresentation: true,
              ),
            ),
          ),
        );
        await _settle(tester);

        final pageBounds = Rect.fromLTWH(
          0,
          0,
          viewport.size.width,
          viewport.size.height,
        );
        for (final key in [
          const ValueKey('expressive-catalog-search-panel'),
          const ValueKey('expressive-catalog-results'),
        ]) {
          final finder = find.byKey(key);
          expect(finder, findsOneWidget);
          final rect = tester.getRect(finder);
          expect(rect.left, greaterThanOrEqualTo(pageBounds.left));
          expect(rect.right, lessThanOrEqualTo(pageBounds.right));
        }
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Goblet Squat'), findsOneWidget);
        expect(tester.takeException(), isNull);

        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseCatalogPage)),
        );
        await tester.tap(find.byTooltip(strings.catalogFilters));
        await _settle(tester);
        final filterDialog = find.byKey(
          const ValueKey('expressive-catalog-filter-dialog'),
        );
        expect(filterDialog, findsOneWidget);
        final cancel = find.text(strings.commonCancel);
        final save = find.text(strings.commonSave);
        await tester.ensureVisible(cancel);
        await tester.ensureVisible(save);
        for (final action in [cancel, save]) {
          final actionRect = tester.getRect(action);
          expect(actionRect.left, greaterThanOrEqualTo(pageBounds.left));
          expect(actionRect.right, lessThanOrEqualTo(pageBounds.right));
          expect(actionRect.top, greaterThanOrEqualTo(pageBounds.top));
          expect(actionRect.bottom, lessThanOrEqualTo(pageBounds.bottom));
        }
        await tester.tap(cancel);
        await _settle(tester);
        expect(
          find.byKey(const ValueKey('expressive-catalog-filter-dialog')),
          findsNothing,
        );

        final exerciseInfo = find.byType(ExerciseMediaThumbnail);
        await tester.ensureVisible(exerciseInfo);
        await _settle(tester);
        await tester.tap(exerciseInfo);
        await _settle(tester);

        expect(find.byType(ExerciseDetailSheet), findsOneWidget);
        final detailShell = find.byKey(
          const ValueKey('exercise-detail-expressive-shell'),
        );
        expect(detailShell, findsOneWidget);
        final shellRect = tester.getRect(detailShell);
        expect(shellRect.left, greaterThanOrEqualTo(pageBounds.left));
        expect(shellRect.top, greaterThanOrEqualTo(pageBounds.top));
        expect(shellRect.right, lessThanOrEqualTo(pageBounds.right));
        expect(shellRect.bottom, lessThanOrEqualTo(pageBounds.bottom));
        expect(find.text('Goblet Squat'), findsWidgets);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final brightness in Brightness.values) {
    for (final scale in <double>[1, 1.15, 1.5, 2]) {
      testWidgets('Expressive Catalog details remain usable at 320 dp, '
          '${brightness.name}, ${scale}x text', (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
          'guided_tutorial_completed.exercise_detail_v1': true,
        });

        final repository = _CatalogDetailRepository(includeHistory: scale == 2);
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = _CatalogDetailDatabase.profiles.first;
        final units = UnitPreferenceProvider();
        addTearDown(profile.dispose);
        addTearDown(units.dispose);
        await units.ready;
        final theme = brightness == Brightness.dark
            ? ExpressiveThemeDefinition.dark()
            : ExpressiveThemeDefinition.light();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const ExerciseCatalogPage(
                expressiveCatalogPresentation: true,
              ),
            ),
          ),
        );
        await _settle(tester);

        final strings = AppLocalizations.of(
          tester.element(find.byType(ExerciseCatalogPage)),
        );
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Goblet Squat'), findsOneWidget);
        expect(find.byTooltip(strings.catalogFilters), findsOneWidget);
        expect(tester.takeException(), isNull);

        final exerciseInfo = find.byType(ExerciseMediaThumbnail);
        await tester.ensureVisible(exerciseInfo);
        await tester.tap(exerciseInfo);
        await _settle(tester);

        expect(find.byType(ExerciseDetailSheet), findsOneWidget);
        final detailTokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.catalog,
          brightness,
        );
        expect(
          tester
              .widget<Material>(
                find.byKey(const ValueKey('exercise-detail-expressive-shell')),
              )
              .color,
          detailTokens.pageCanvas,
        );
        expect(
          (tester
                      .widget<DecoratedBox>(
                        find.byKey(
                          const ValueKey('exercise-detail-expressive-header'),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color,
          detailTokens.surfacePrimary,
        );
        expect(
          (tester
                      .widget<Container>(
                        find.byKey(
                          const ValueKey('exercise-detail-expressive-tab-rail'),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color,
          theme.colorScheme.surfaceContainerHigh,
        );
        expect(
          tester
              .widget<ColoredBox>(
                find.byKey(
                  const ValueKey('exercise-detail-expressive-content-zone'),
                ),
              )
              .color,
          detailTokens.pageCanvas,
        );
        expect(
          tester
              .widget<ColoredBox>(
                find.byKey(
                  const ValueKey('exercise-detail-expressive-content-zone'),
                ),
              )
              .color,
          isNot(detailTokens.surfaceAccent),
        );
        expect(find.text(strings.exerciseDetailTabDetails), findsOneWidget);
        expect(find.text(strings.exerciseDetailTabMetrics), findsOneWidget);
        expect(find.text(strings.exerciseDetailTabRecords), findsOneWidget);
        if (scale == 1) {
          final railFinder = find.byKey(
            const ValueKey('exercise-detail-expressive-tab-rail'),
          );
          final railRect = tester.getRect(railFinder);
          final tabBarFinder = find.descendant(
            of: railFinder,
            matching: find.byType(TabBar),
          );
          expect(tabBarFinder, findsOneWidget);
          final tabBarRect = tester.getRect(tabBarFinder);
          final labels = [
            strings.exerciseDetailTabDetails,
            strings.exerciseDetailTabMetrics,
            strings.exerciseDetailTabRecords,
          ];
          for (final label in labels) {
            final labelFinder = find.text(label);
            final labelWidget = tester.widget<Text>(labelFinder);
            final paragraph = tester.renderObject<RenderParagraph>(labelFinder);
            final tabRect = tester.getRect(
              find.ancestor(of: labelFinder, matching: find.byType(Tab)).first,
            );
            final labelRect = tester.getRect(labelFinder);

            expect(labelWidget.overflow, isNot(TextOverflow.ellipsis));
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(labelRect.left, greaterThanOrEqualTo(tabRect.left));
            expect(labelRect.right, lessThanOrEqualTo(tabRect.right));
          }
          expect(tabBarRect.left, greaterThanOrEqualTo(railRect.left));
          expect(tabBarRect.right, lessThanOrEqualTo(railRect.right));
        }
        if (scale == 2) {
          final railFinder = find.byKey(
            const ValueKey('exercise-detail-expressive-tab-rail'),
          );
          final railRect = tester.getRect(railFinder);
          final labels = [
            strings.exerciseDetailTabDetails,
            strings.exerciseDetailTabMetrics,
            strings.exerciseDetailTabRecords,
          ];
          final segmentTops = <double>[];
          for (final label in labels) {
            final labelFinder = find.text(label);
            final paragraph = tester.renderObject<RenderParagraph>(labelFinder);
            final labelWidget = tester.widget<Text>(labelFinder);
            final labelRect = tester.getRect(labelFinder);
            final segmentFinder = find
                .ancestor(
                  of: labelFinder,
                  matching: find.byType(AnimatedContainer),
                )
                .first;
            final segmentRect = tester.getRect(segmentFinder);

            expect(labelWidget.maxLines, 1);
            expect(labelWidget.softWrap, isFalse);
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(labelRect.left, greaterThanOrEqualTo(railRect.left));
            expect(labelRect.right, lessThanOrEqualTo(railRect.right));
            expect(
              segmentRect.width,
              greaterThanOrEqualTo(railRect.width * 0.9),
            );
            expect(segmentRect.height, greaterThanOrEqualTo(48));
            segmentTops.add(segmentRect.top);
          }
          expect(segmentTops[0], lessThan(segmentTops[1]));
          expect(segmentTops[1], lessThan(segmentTops[2]));
        }
        expect(find.byTooltip(strings.commonClose), findsOneWidget);
        expect(find.text(strings.exerciseDetailFormGuide), findsOneWidget);
        expect(find.text(strings.catalogEquipment), findsOneWidget);
        expect(find.text(strings.exerciseDetailTargetAnatomy), findsOneWidget);
        expect(tester.takeException(), isNull);

        final equipmentHeading = find.text(strings.catalogEquipment);
        await tester.ensureVisible(equipmentHeading);
        await tester.tap(equipmentHeading);
        await _settle(tester);
        expect(find.text('Dumbbell'), findsNWidgets(2));

        await tester.tap(find.text(strings.exerciseDetailTabMetrics));
        await _settle(tester);
        final semantics = tester.ensureSemantics();
        try {
          expect(
            tester
                .getSemantics(find.text(strings.exerciseDetailTabMetrics))
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
        } finally {
          semantics.dispose();
        }
        if (scale == 2) {
          final repBests = find.text(strings.exerciseDetailRepBests);
          final rangeCount = find.text(strings.exerciseDetailRanges(1));
          final repBadge = find.byKey(
            const ValueKey('exercise-detail-rep-best-badge'),
          );
          final repCount = find.descendant(
            of: repBadge,
            matching: find.text('10'),
          );
          final repsLabel = find.descendant(
            of: repBadge,
            matching: find.text(strings.exerciseDetailReps),
          );
          final bestWeight = find.text(strings.exerciseDetailBestWeight);
          final setVolume = find.text(strings.exerciseDetailSetVolume);

          for (final label in [
            repBests,
            rangeCount,
            repCount,
            repsLabel,
            bestWeight,
            setVolume,
          ]) {
            expect(label, findsOneWidget);
            final paragraph = tester.renderObject<RenderParagraph>(label);
            expect(paragraph.didExceedMaxLines, isFalse);
            final bounds = tester.getRect(label);
            expect(bounds.left, greaterThanOrEqualTo(0));
            expect(bounds.right, lessThanOrEqualTo(320));
          }
          expect(
            tester.getRect(repBests).overlaps(tester.getRect(rangeCount)),
            isFalse,
          );
          expect(
            tester.getRect(repBadge).overlaps(tester.getRect(bestWeight)),
            isFalse,
          );
          expect(
            tester.getRect(bestWeight).overlaps(tester.getRect(setVolume)),
            isFalse,
          );
          expect(tester.takeException(), isNull);
        }
        await tester.tap(find.text(strings.exerciseDetailTabRecords));
        await _settle(tester);
        if (scale == 2) {
          final bestWeight = find.text(strings.exerciseDetailBestWeight);
          final estimatedOneRm = find.text(
            strings.exerciseDetailEstimatedOneRm,
          );
          expect(bestWeight, findsOneWidget);
          expect(estimatedOneRm, findsOneWidget);
          for (final label in [bestWeight, estimatedOneRm]) {
            final text = tester.widget<Text>(label);
            final paragraph = tester.renderObject<RenderParagraph>(label);
            expect(text.maxLines, isNull);
            expect(text.overflow, isNull);
            expect(paragraph.didExceedMaxLines, isFalse);
          }
          expect(
            tester.getRect(bestWeight).bottom,
            lessThan(tester.getRect(estimatedOneRm).top),
          );
        }
        await tester.tap(find.text(strings.exerciseDetailTabDetails));
        await _settle(tester);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

class _CatalogDetailRepository extends AppRepository {
  _CatalogDetailRepository({this.includeHistory = false})
    : super(db: _CatalogDetailDatabase());

  final bool includeHistory;

  static final _chest = BodyPart(1, 'Chest');
  static final _pectorals = Muscle(id: 1, name: 'Pectorals');

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    ExerciseDefinition(
      id: 1,
      name: 'Goblet Squat',
      equipmentList: [_CatalogDetailDatabase.equipment.first],
      bodyParts: [_chest],
      muscles: [RankedMuscle(muscle: _pectorals, rank: 1)],
      setupNotes: 'Hold the weight close to your chest.',
      executionNotes: 'Lower under control, then stand tall.',
      tipsNotes: 'Keep your feet planted.',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>>
  fetchCurrentExerciseRecordBadges(int definitionId) async => {};

  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      includeHistory
      ? [
          RepMaxRow(
            repCount: 10,
            rmValue: 40,
            oneErm: 53.3,
            isErm: false,
            defId: defId,
            timeframe: timeframe,
          ),
        ]
      : [];

  @override
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async => includeHistory
      ? [
          {
            'exercise_id': 11,
            'session_id': 4,
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
  Future<WorkoutExercise?> fetchDetailedExercise(int id) async => includeHistory
      ? WeightExercise(
          name: 'Goblet Squat',
          equipment: 'Dumbbell',
          sets: [ExerciseSet(weight: 40, reps: 8)],
        )
      : null;

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Future<double?> fetchVolumeMax(int defId, String timeframe) async => null;
}

class _CatalogDetailDatabase implements DatabaseHelper {
  static final profiles = [
    GymProfile(id: 1, name: 'Home Gym', createdAt: DateTime.utc(2026)),
  ];
  static final equipment = [Equipment(1, 'Dumbbell')];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [
    {'id': 1, 'name': 'Dumbbell', 'catalog_id': null},
  ];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    _CatalogDetailRepository._chest,
  ];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    _CatalogDetailRepository._pectorals,
  ];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => equipment;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
