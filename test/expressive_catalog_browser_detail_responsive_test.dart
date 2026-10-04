import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/exercise_detail_sheet.dart';
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
        expect(find.text(strings.exerciseDetailTabDetails), findsOneWidget);
        expect(find.text(strings.exerciseDetailTabMetrics), findsOneWidget);
        expect(find.text(strings.exerciseDetailTabRecords), findsOneWidget);
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
        await tester.tap(find.text(strings.exerciseDetailTabRecords));
        await _settle(tester);
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
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

class _CatalogDetailRepository extends AppRepository {
  _CatalogDetailRepository() : super(db: _CatalogDetailDatabase());

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
  Future<List<Map<String, dynamic>>> fetchRecentWeightExerciseHistoryRows({
    required int definitionId,
    int? beforeCompletedAtMilliseconds,
    int? beforeExerciseId,
    int limit = 10,
  }) async => [];

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Future<List<RepMaxRow>> fetchRepMaxes(int defId, String timeframe) async =>
      [];

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
