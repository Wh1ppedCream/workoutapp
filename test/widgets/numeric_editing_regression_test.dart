import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/nutrition/food_customization_page.dart';
import 'package:env_test/screens/profile/settings/user_information_settings_page.dart';
import 'package:env_test/screens/profile/settings/exercise_analytics_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';
import 'package:env_test/widgets/automatic_settings_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final unit in WeightUnit.values) {
    testWidgets(
      'progression keeps fractional overrides on save in ${unit.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repo = _NumericRepository();
        final preset = PresetSession(1, repository: repo);
        await preset.ready;
        addTearDown(preset.dispose);
        final units = UnitPreferenceProvider();
        await units.ready;
        await units.setWeightUnit(unit);
        addTearDown(units.dispose);
        final original = WeightUnitFormatter.toPounds(0.125, unit);
        preset.globalIncrement = original;
        preset.exerciseIncrementOverrides[11] = original;
        preset.setIncrementOverrides[101] = original;
        preset.setIncrementOverrides[102] = null;

        await tester.pumpWidget(
          _host(
            repo,
            units,
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AutomaticSettingsSheet(preset: preset),
                ),
                child: const Text('Open editor'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open editor'));
        await tester.pumpAndSettle();
        final fields = find.byType(TextField);
        expect(
          tester.widget<TextField>(fields.at(0)).controller!.text,
          '0.125',
        );
        expect(
          tester.widget<TextField>(fields.at(1)).controller!.text,
          '0.125',
        );
        expect(
          tester.widget<TextField>(fields.at(2)).controller!.text,
          '0.125',
        );
        // Change one override; every untouched canonical value must stay exact.
        await tester.enterText(fields.at(3), '0.25');
        tester.testTextInput.hide();
        final save = find.widgetWithText(ElevatedButton, 'Save');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        final written = repo.autoWrite!;
        expect(written.settings.globalIncrement, original);
        expect(written.exerciseIncrements[11], original);
        expect(written.setIncrements[101], original);
        expect(
          written.setIncrements[102],
          WeightUnitFormatter.toPounds(0.25, unit),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'profile metadata edits preserve weight and fractional edits are recorded in ${unit.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repo = _NumericRepository();
        final original = WeightUnitFormatter.toPounds(70.125, unit);
        repo.info = PersonalInfo(name: 'Taylor', weight: original.toString());
        repo.latestWeight = original;
        final units = UnitPreferenceProvider();
        await units.ready;
        await units.setWeightUnit(unit);
        addTearDown(units.dispose);
        await tester.pumpWidget(
          _host(repo, units, const UserInformationSettingsPage()),
        );
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
          tester.element(find.byType(UserInformationSettingsPage)),
        );
        final weight = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == strings.userInfoCurrentWeight,
        );
        await tester.ensureVisible(weight);
        expect(tester.widget<TextField>(weight).controller!.text, '70.125');
        await tester.ensureVisible(find.byKey(AppTestKeys.userInformationName));
        await tester.enterText(
          find.byKey(AppTestKeys.userInformationName),
          'Updated name',
        );
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.userInformationSave));
        await tester.pumpAndSettle();
        expect(repo.savedInfo!.weight, repo.info!.weight);
        expect(repo.savedBodyWeight, isNull);
        ScaffoldMessenger.of(
          tester.element(find.byType(UserInformationSettingsPage)),
        ).removeCurrentSnackBar();
        await tester.ensureVisible(weight);
        await tester.enterText(weight, '70.2');
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.userInformationSave));
        await tester.pumpAndSettle();
        expect(repo.savedBodyWeight, 70.2);
        expect(repo.savedUnit, unit);
        expect(
          double.parse(repo.savedInfo!.weight!),
          WeightUnitFormatter.toPounds(70.2, unit),
        );
        ScaffoldMessenger.of(
          tester.element(find.byType(UserInformationSettingsPage)),
        ).removeCurrentSnackBar();
        // A later name edit must not record the same reading again.
        await tester.ensureVisible(find.byKey(AppTestKeys.userInformationName));
        await tester.enterText(
          find.byKey(AppTestKeys.userInformationName),
          'Another name',
        );
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(AppTestKeys.userInformationSave));
        await tester.pumpAndSettle();
        expect(repo.savedBodyWeight, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('editing one allocation credit preserves other precise credits', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _NumericRepository();
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    await tester.pumpWidget(
      _host(repo, units, const ExerciseAnalyticsScreen()),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    expect(
      tester.widget<TextFormField>(fields.first).controller!.text,
      '0.004125',
    );
    await tester.enterText(fields.at(1), '2.25');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(repo.savedCredits, {1: 0.004125, 2: 2.25});
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'food editing preserves small nutrients, density and portion metadata in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final portions = List<FoodPortion>.unmodifiable([
          FoodPortion(
            foodId: 7,
            measureName: 'Tiny scoop',
            amount: 1.125,
            gramWeight: 0.000125,
            unit: 'g',
            listKind: 'usual',
            label: 'My scoop',
            isDefault: true,
          ),
          FoodPortion(
            foodId: 7,
            measureName: 'Micro portion',
            amount: 25,
            unit: 'µg',
            listKind: 'basis',
          ),
        ]);
        Map<String, dynamic>? result;
        final repo = _NumericRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);
        await tester.pumpWidget(
          _host(
            repo,
            units,
            Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => FoodCustomizationPage(
                            initialFoodId: 7,
                            initialName: 'Test food',
                            initialCalories: 0.004,
                            initialProteinG: 0.0000001,
                            initialCarbsG: 1.23456789,
                            initialFatsG: 2.5,
                            initialDensityGPerMl: 1.000125,
                            initialPortions: portions,
                          ),
                        ),
                      );
                },
                child: const Text('Open editor'),
              ),
            ),
            brightness: brightness,
          ),
        );
        await tester.tap(find.text('Open editor'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'The caller may supply an immutable portion list.',
        );
        final save = find.byWidgetPredicate(
          (w) => w is FloatingActionButton && w.heroTag == 'fab-save',
        );
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(result, isNotNull);
        expect(result!['KCAL'], 0.004);
        expect(result!['PROTEIN_G'], 0.0000001);
        expect(result!['CARB_G'], 1.23456789);
        expect(result!['FAT_G'], 2.5);
        expect(result!['density_g_per_ml'], 1.000125);
        final savedPortions = (result!['portions'] as List)
            .cast<Map<String, dynamic>>();
        expect(
          savedPortions.singleWhere((p) => p['unit'] == 'µg')['gram_weight'],
          0.000025,
        );
        final scoop = savedPortions.singleWhere(
          (p) => p['label'] == 'My scoop',
        );
        expect(scoop['gram_weight'], 0.000125);
        expect(scoop['amount'], 1.125);
        expect(scoop['measure_name'], 'Tiny scoop');
        expect(scoop['is_default'], isTrue);
        expect(portions.first.measureName, 'Tiny scoop');
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _host(
  AppRepository repo,
  UnitPreferenceProvider units,
  Widget page, {
  Brightness brightness = Brightness.light,
}) => MultiProvider(
  providers: [
    Provider<AppRepository>.value(value: repo),
    ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
  ],
  child: MaterialApp(
    theme: brightness == Brightness.light
        ? AppThemeFactory.light(AppThemeFamily.expressive)
        : AppThemeFactory.dark(AppThemeFamily.expressive),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: page),
  ),
);

class _NumericRepository extends AppRepository {
  PersonalInfo? info;
  double? latestWeight;
  PersonalInfo? savedInfo;
  double? savedBodyWeight;
  WeightUnit? savedUnit;
  PresetAutoConfigurationWrite? autoWrite;
  Map<int, double>? savedCredits;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    ExerciseDefinition(
      id: 21,
      name: 'Squat',
      bodyParts: const [],
      muscles: [
        RankedMuscle(muscle: Muscle(id: 1, name: 'First muscle'), rank: 1),
        RankedMuscle(muscle: Muscle(id: 2, name: 'Second muscle'), rank: 2),
      ],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];
  @override
  Future<ResolvedExerciseAllocation> resolveExerciseAllocation(
    int defId,
  ) async => ResolvedExerciseAllocation(
    exerciseDefinitionId: defId,
    muscleCredits: {1: 0.004125, 2: 1.333333333},
    bodyPartCredits: const {},
    derivedBodyPartCredits: const {},
    muscleHistoryCredits: const {},
    bodyPartHistoryCredits: const {},
    muscleSource: ExerciseAllocationSource.personalOverride,
    bodyPartSource: ExerciseAllocationSource.automatic,
  );
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [];
  @override
  Future<void> replacePersonalExerciseAllocationCredits({
    required int defId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) async {
    savedCredits = credits;
  }

  @override
  Future<PersonalInfo?> fetchPersonalInfo() async => info;
  @override
  Future<double?> fetchLatestBodyWeightLbs() async => latestWeight;
  @override
  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) async {
    savedInfo = info;
    savedBodyWeight = bodyWeightValue;
    savedUnit = bodyWeightUnit;
  }

  @override
  Future<PresetDefinition?> fetchPresetById(int id) async => PresetDefinition(
    id: id,
    name: 'Test preset',
    createdAt: DateTime.utc(2026),
  );
  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [
        {'id': 11, 'type': 'weight', 'exercise_def_id': 21},
      ];
  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async => {
    'name': 'Squat',
    'equipmentName': 'Barbell',
  };
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => [
    {'id': 101, 'parent_set_id': null, 'weight': 20.0, 'reps': 8},
    {'id': 102, 'parent_set_id': null, 'weight': 25.0, 'reps': 6},
  ];
  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => null;
  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async =>
      null;
  @override
  Future<void> savePresetAutoConfigurationAtomic({
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) async {
    autoWrite = configuration;
  }
}
