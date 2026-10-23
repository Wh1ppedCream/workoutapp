import 'package:material_ui/material_ui.dart';

import 'expressive_review_main.dart' as regular_app;

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

/// Compatibility entrypoint: the former preview now opens the regular app UI.
/// Existing data is retained; launching this entrypoint never reseeds fixtures.
Future<void> main() => regular_app.main();
