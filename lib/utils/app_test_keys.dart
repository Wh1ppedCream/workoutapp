import 'package:flutter/widgets.dart';

/// Stable identifiers for device-driven core-flow tests.
///
/// These keys intentionally describe user actions rather than visual layout so
/// tests remain valid across localization and responsive UI changes.
abstract final class AppTestKeys {
  static const trainOverviewTab = ValueKey('train-overview-tab');
  static const trainPlansTab = ValueKey('train-plans-tab');
  static const trainPlansList = ValueKey('train-plans-list');
  static const trainCreateManualPlan = ValueKey('train-create-manual-plan');
  static const trainStartWorkout = ValueKey('train-start-workout');

  static const planEdit = ValueKey('plan-edit');
  static const planName = ValueKey('plan-name');
  static const planSave = ValueKey('plan-save');
  static const planStartSession = ValueKey('plan-start-session');

  static const sessionFinish = ValueKey('session-finish');
  static const sessionCompleteDone = ValueKey('session-complete-done');
  static const ongoingSessionMenu = ValueKey('ongoing-session-menu');
  static const ongoingSessionResume = ValueKey('ongoing-session-resume');
  static const ongoingSessionExit = ValueKey('ongoing-session-exit');
  static const ongoingSessionKeep = ValueKey('ongoing-session-keep');

  static const workoutSaveAsPlan = ValueKey('workout-save-as-plan');
  static const workoutDetailList = ValueKey('workout-detail-list');
  static const workoutPlanName = ValueKey('workout-plan-name');
  static const workoutPlanSave = ValueKey('workout-plan-save');

  static const profileUserInformation = ValueKey('profile-user-information');
  static const profileDatabaseSettings = ValueKey('profile-database-settings');
  static const userInformationName = ValueKey('user-information-name');
  static const userInformationSave = ValueKey('user-information-save');

  static const databaseExport = ValueKey('database-export');
  static const databaseImport = ValueKey('database-import');
  static const databaseConfirmImport = ValueKey('database-confirm-import');
  static const databaseResultClose = ValueKey('database-result-close');

  static ValueKey<String> mainTab(String name) => ValueKey('main-tab-$name');

  static ValueKey<String> historySession(int sessionId) =>
      ValueKey('history-session-$sessionId');
}
