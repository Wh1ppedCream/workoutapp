import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/train_page.dart';
import 'package:env_test/screens/exercise/train2_page.dart';
import 'package:env_test/widgets/generic_bar.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final route in ['train', 'train2', 'train2-classic']) {
    for (final leaveBeforeReady in [false, true]) {
      testWidgets(
        '$route manual plan waits for profile readiness; leave=$leaveBeforeReady',
        (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          await const TutorialStateStore().skipAll();
          await tester.binding.setSurfaceSize(const Size(430, 1800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final repository = _DelayedProfileRepository();
          final profile = SelectedProfile(repository: repository);
          final session = ActiveSession(
            repository: repository,
            retryDelay: (_) async {},
          );
          await session.ready;
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(() async {
            await tester.pumpWidget(const SizedBox.shrink());
            if (!repository.profiles.isCompleted) {
              repository.profiles.complete([_profile]);
            }
            if (!repository.creation.isCompleted) {
              repository.creation.complete(42);
            }
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 750));
            units.dispose();
            profile.dispose();
            session.dispose();
          });
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                Provider<ActivePlanStore>.value(
                  value: ActivePlanStore(repository: repository),
                ),
                ChangeNotifierProvider<SelectedProfile>.value(value: profile),
                ChangeNotifierProvider<ActiveSession>.value(value: session),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: AppThemeFactory.light(
                  route == 'train2-classic'
                      ? AppThemeFamily.classic
                      : AppThemeFamily.expressive,
                ),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: TickerMode(
                  enabled: false,
                  child: route == 'train'
                      ? const TrainPage()
                      : const Train2Page(),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump();
          if (route == 'train') {
            await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
            await tester.pump();
            await tester.pump();
            tester
                .widget<ExpressiveTrainPlanActions>(
                  find.byType(ExpressiveTrainPlanActions),
                )
                .onCreateManual();
          } else {
            final strings = AppLocalizations.of(
              tester.element(find.byType(Train2Page)),
            );
            if (route == 'train2-classic') {
              tester
                  .widget<GenericBar>(
                    find.widgetWithText(GenericBar, strings.trainAddPlan),
                  )
                  .onTap!();
            } else {
              await tester.tap(find.text(strings.commonAdd));
              await tester.pumpAndSettle();
              await tester.tap(find.text(strings.trainManuallyAddPlan));
              await tester.pumpAndSettle();
            }
          }
          await tester.pump();
          expect(
            repository.createdProfiles,
            isEmpty,
            reason: 'A quick tap must not create a plan with a null profile.',
          );
          if (leaveBeforeReady) {
            await tester.pumpWidget(const SizedBox.shrink());
          }
          repository.profiles.complete([_profile]);
          for (var frame = 0; frame < 10; frame++) {
            await tester.pump(const Duration(milliseconds: 1));
          }
          expect(
            repository.createdProfiles,
            leaveBeforeReady ? isEmpty : <int?>[7],
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

final _profile = GymProfile(
  id: 7,
  name: 'Saved gym',
  createdAt: DateTime(2026),
);

class _DelayedProfileRepository extends AppRepository {
  final profiles = Completer<List<GymProfile>>();
  final creation = Completer<int>();
  final createdProfiles = <int?>[];

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => [];

  @override
  Future<List<GymProfile>> fetchAllProfiles() => profiles.future;
  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [];
  @override
  Future<String?> getAppState(String key) async =>
      key == 'selected_gym_profile_id' ? '7' : null;
  @override
  Future<void> setAppState(String key, String? value) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async => [];
  @override
  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) {
    createdProfiles.add(profileId);
    return creation.future;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => [];
  @override
  Future<Set<int>> loadActivePlans(int profileId) async => {};
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;
  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      [];
  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => {};
}
