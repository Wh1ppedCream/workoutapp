import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/screens/exercise/train2_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/optimized_workout_preferences.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/generic_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Train2 classic manual plan opens PresetDetailScreen in edit mode and refreshes on return',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await const TutorialStateStore().skipAll();
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _Train2FixtureRepository();
      final selectedProfile = SelectedProfile(repository: repository);
      await selectedProfile.ready;
      final activeSession = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      await activeSession.ready;
      final units = UnitPreferenceProvider();
      await units.ready;

      addTearDown(() {
        units.dispose();
        selectedProfile.dispose();
        activeSession.dispose();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            Provider<ActivePlanStore>.value(
              value: ActivePlanStore(repository: repository),
            ),
            ChangeNotifierProvider<SelectedProfile>.value(
              value: selectedProfile,
            ),
            ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: AppThemeFactory.light(AppThemeFamily.classic),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TickerMode(enabled: false, child: Train2Page()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fetchesBeforeAdd = repository.presetSummaryFetches;
      final strings = AppLocalizations.of(
        tester.element(find.byType(Train2Page)),
      );
      await tester.tap(find.widgetWithText(GenericBar, strings.trainAddPlan));
      await tester.pumpAndSettle();

      expect(find.byType(PresetDetailScreen), findsOneWidget);
      expect(find.byKey(AppTestKeys.planName), findsOneWidget);

      final fetchesWhileEditing = repository.presetSummaryFetches;
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(PresetDetailScreen), findsNothing);
      expect(repository.presetSummaryFetches, greaterThan(fetchesWhileEditing));
      expect(fetchesWhileEditing, greaterThan(fetchesBeforeAdd));
    },
  );

  testWidgets(
    'Train2 optimized settings save preserves sibling preferences and clamps minSets',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        OptimizedWorkoutPreferences.sessionMinutesKey: 60,
        OptimizedWorkoutPreferences.minSetsKey: 4,
        OptimizedWorkoutPreferences.maxSetsKey: 5,
        OptimizedWorkoutPreferences.repWeightModeKey:
            RepWeightGenerationMode.consistent.name,
        OptimizedWorkoutPreferences.targetRepsKey: 12,
        OptimizedWorkoutPreferences.starterIntensityKey:
            StarterWeightIntensity.hard.name,
      });
      await const TutorialStateStore().skipAll();
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _Train2FixtureRepository();
      final selectedProfile = SelectedProfile(repository: repository);
      await selectedProfile.ready;
      final activeSession = ActiveSession(
        repository: repository,
        retryDelay: (_) async {},
      );
      await activeSession.ready;
      final units = UnitPreferenceProvider();
      await units.ready;

      addTearDown(() {
        units.dispose();
        selectedProfile.dispose();
        activeSession.dispose();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            Provider<ActivePlanStore>.value(
              value: ActivePlanStore(repository: repository),
            ),
            ChangeNotifierProvider<SelectedProfile>.value(
              value: selectedProfile,
            ),
            ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: AppThemeFactory.light(AppThemeFamily.classic),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TickerMode(enabled: false, child: Train2Page()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(Train2Page)),
      );
      await tester.tap(find.byTooltip(strings.trainOptimizedSettingsTitle));
      await tester.pumpAndSettle();

      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), '35');
      await tester.enterText(fields.at(1), '2');
      await tester.tap(find.widgetWithText(TextButton, strings.commonSave));
      await tester.pumpAndSettle();

      final reloaded = await const OptimizedWorkoutPreferences().load();
      expect(reloaded.sessionMinutes, 35);
      expect(reloaded.maxSetsPerExercise, 2);
      expect(reloaded.minSetsPerExercise, 2);
      expect(reloaded.repWeightMode, RepWeightGenerationMode.consistent);
      expect(reloaded.targetRepCount, 12);
      expect(reloaded.starterWeightIntensity, StarterWeightIntensity.hard);
    },
  );
}

class _Train2FixtureRepository extends AppRepository {
  int presetSummaryFetches = 0;
  final List<Map<String, dynamic>> _presets = [];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [
    GymProfile(id: 1, name: 'General', createdAt: DateTime(2026)),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [];

  @override
  Future<String?> getAppState(String key) async =>
      key == 'selected_gym_profile_id' ? '1' : null;

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async => List<Map<String, dynamic>>.from(_presets);

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async {
    presetSummaryFetches++;
    return _presets
        .map(
          (preset) => <String, dynamic>{
            ...preset,
            'exercise_count': 0,
            'set_count': 0,
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => const [];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async =>
      _presets.map((p) => p['id'] as int).toSet();

  @override
  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) async {
    final id = _presets.length + 1;
    _presets.add({
      'id': id,
      'name': name,
      'profile_id': profileId,
      'created_at': DateTime(2026).millisecondsSinceEpoch,
      'is_draft': isDraft ? 1 : 0,
    });
    return id;
  }

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async {
    final row = _presets.where((p) => p['id'] == presetId).firstOrNull;
    if (row == null) return null;
    return PresetDefinition(
      id: presetId,
      name: row['name'] as String,
      profileId: row['profile_id'] as int?,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      const [];

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => const [];
}
