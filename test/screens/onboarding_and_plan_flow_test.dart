import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.plan_detail_v1': true,
      'guided_tutorial_completed.onboarding_manual_plan_v1': true,
    });
  });

  testWidgets('first onboarding page changes and persists its language', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: _OnboardingRepository()),
          ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
          ChangeNotifierProvider(create: (_) => LocalePreferenceProvider()),
        ],
        child: Consumer<LocalePreferenceProvider>(
          builder: (context, localePreferences, _) {
            return MaterialApp(
              locale: localePreferences.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingFlow(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Tonos'), findsOneWidget);
    await tester.tap(
      find.byType(DropdownButtonFormField<AppLanguagePreference>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français (Canada)').last);
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue dans Tonos'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Suivant'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(LocalePreferenceProvider.preferenceKey),
      'canadianFrench',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Parlez-nous de vous'), findsOneWidget);
    expect(find.text('Renseignements'), findsOneWidget);
  });

  testWidgets('onboarding converts an entered weight when units change', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _OnboardingRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
          ChangeNotifierProvider(create: (_) => LocalePreferenceProvider()),
        ],
        child: Consumer<LocalePreferenceProvider>(
          builder: (context, localePreferences, _) {
            return MaterialApp(
              locale: localePreferences.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingFlow(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    final weightField = find.descendant(
      of: find.byKey(const Key('onboarding-current-weight')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(weightField);
    await tester.enterText(weightField, '160');
    await tester.tap(find.widgetWithText(ChoiceChip, 'kg'));
    await tester.pump();

    expect(tester.widget<TextField>(weightField).controller?.text, '73');

    await tester.tap(find.widgetWithText(ChoiceChip, 'lbs'));
    await tester.pump();
    expect(tester.widget<TextField>(weightField).controller?.text, '160');
  });

  testWidgets('onboarding saves weight units and recommendation history', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _OnboardingRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
          ChangeNotifierProvider(create: (_) => LocalePreferenceProvider()),
          ChangeNotifierProvider(create: (_) => OnboardingConfig()..init()),
        ],
        child: Consumer<LocalePreferenceProvider>(
          builder: (context, localePreferences, _) {
            return MaterialApp(
              locale: localePreferences.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const OnboardingFlow(),
              routes: {'/main': (_) => const Scaffold(body: Text('Home'))},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'kg'));

    final weightField = find.descendant(
      of: find.byKey(const Key('onboarding-current-weight')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(weightField);
    await tester.enterText(weightField, '70');
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(repository.savedInfo?.weight, '154');
    expect(repository.savedBodyWeightValue, 70);
    expect(repository.savedBodyWeightUnit, WeightUnit.kilograms);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('weight_unit_preference'), 'kilograms');
  });

  testWidgets('leaving an onboarding plan returns discarded', (tester) async {
    final repository = _PlanEditorRepository();
    PresetDetailResult? result;

    await tester.pumpWidget(
      _PlanTestApp(repository: repository, onResult: (value) => result = value),
    );
    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(result, PresetDetailResult.discarded);
    expect(repository.publishRequested, isFalse);
  });

  testWidgets('saving an onboarding plan publishes the draft', (tester) async {
    final repository = _PlanEditorRepository();
    PresetDetailResult? result;

    await tester.pumpWidget(
      _PlanTestApp(repository: repository, onResult: (value) => result = value),
    );
    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Preset'));
    await tester.pumpAndSettle();

    expect(result, PresetDetailResult.saved);
    expect(repository.publishRequested, isTrue);
  });
}

class _PlanTestApp extends StatelessWidget {
  const _PlanTestApp({required this.repository, required this.onResult});

  final _PlanEditorRepository repository;
  final ValueChanged<PresetDetailResult?> onResult;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(
                        context,
                      ).push<PresetDetailResult>(
                        MaterialPageRoute(
                          builder:
                              (_) => ChangeNotifierProvider(
                                create:
                                    (_) => PresetSession(
                                      1,
                                      repository: repository,
                                    ),
                                child: const PresetDetailScreen(
                                  startInEditingMode: true,
                                  closeAfterSave: true,
                                ),
                              ),
                        ),
                      );
                      onResult(result);
                    },
                    child: const Text('Open plan'),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _OnboardingRepository extends AppRepository {
  PersonalInfo? savedInfo;
  double? savedBodyWeightValue;
  WeightUnit? savedBodyWeightUnit;

  @override
  Future<List<Equipment>> fetchAllEquipment() async => const <Equipment>[];

  @override
  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) async {
    savedInfo = info;
    savedBodyWeightValue = bodyWeightValue;
    savedBodyWeightUnit = bodyWeightUnit;
  }
}

class _PlanEditorRepository extends AppRepository {
  bool publishRequested = false;
  bool _isDraft = true;

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    return PresetDefinition(
      id: presetId,
      name: 'New Plan',
      createdAt: DateTime.utc(2026, 7, 26),
      profileId: 1,
      isDraft: _isDraft,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async {
    return null;
  }

  @override
  Future<void> replacePresetAtomic({
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool publishDraft = false,
  }) async {
    publishRequested = publishDraft;
    if (publishDraft) _isDraft = false;
  }
}
