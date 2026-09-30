import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'dev/expressive_preview_fixtures.dart';
import 'dev/expressive_preview_safety.dart';
import 'main.dart' show MainScreen, runTonosApp;
import 'providers/active_session.dart';
import 'providers/selected_profile.dart';
import 'repositories/app_repository.dart';
import 'services/active_plan_store.dart';
import 'theme/tonos_preview_presentation.dart';

@visibleForTesting
Future<bool> resetExpressivePreviewFixturesSafely({
  required bool Function() sessionIsFinishing,
  required Future<bool> Function() hasPendingProgressions,
  required Future<void> Function() discardSession,
  required Future<void> Function() resetFixtures,
  required void Function() onBusy,
}) async {
  void reportBusy() => onBusy();

  if (sessionIsFinishing()) {
    reportBusy();
    return false;
  }

  final pendingProgressions = await hasPendingProgressions();
  if (pendingProgressions || sessionIsFinishing()) {
    reportBusy();
    return false;
  }

  await discardSession();
  if (sessionIsFinishing()) {
    reportBusy();
    return false;
  }

  await resetFixtures();
  return true;
}

Future<void> main() async {
  ExpressivePreviewFixtures? fixtures;
  AppRepository? previewRepository;
  final presentation = TonosPreviewPresentation(
    fixtureReset: (navigator) async {
      final currentFixtures = fixtures;
      final repository = previewRepository;
      if (currentFixtures == null || repository == null) return;
      final appContext = navigator.context;
      final activeSession = appContext.read<ActiveSession>();
      final selectedProfile = appContext.read<SelectedProfile>();
      final activePlanStore = appContext.read<ActivePlanStore>();
      await resetExpressivePreviewFixturesSafely(
        sessionIsFinishing: () => activeSession.isFinishing,
        hasPendingProgressions: () async =>
            (await repository.loadPendingWorkoutProgressions()).isNotEmpty,
        discardSession: activeSession.discard,
        onBusy: () {
          ScaffoldMessenger.of(appContext).showSnackBar(
            const SnackBar(
              content: Text(
                'Wait for the workout and plan updates to finish, then reset the preview.',
              ),
            ),
          );
        },
        resetFixtures: () async {
          final nextFixtures = await currentFixtures.resetAndSeed();
          fixtures = nextFixtures;
          await selectedProfile.loadProfiles(
            preferredProfileId: nextFixtures.profileId,
          );
          await activePlanStore.load(nextFixtures.profileId);
          navigator.pushAndRemoveUntil<void>(
            MaterialPageRoute<void>(builder: (_) => const MainScreen()),
            (_) => false,
          );
        },
      );
    },
    missingProfileFixture: (navigator) {
      final selectedProfile = navigator.context.read<SelectedProfile>();
      selectedProfile
        ..currentProfile = null
        ..equipment = <Map<String, dynamic>>[];
      navigator.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        (_) => false,
      );
      return Future<void>.value();
    },
  );

  await runTonosApp(
    previewPresentation: presentation,
    beforeDataAccess: ExpressivePreviewSafety.verifyBeforeDataAccess,
    beforeRunApp: (repository) async {
      previewRepository = repository;
      fixtures = await ExpressivePreviewFixtures.prepare(repository);
    },
  );
}
