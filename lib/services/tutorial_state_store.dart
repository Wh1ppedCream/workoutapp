import 'package:shared_preferences/shared_preferences.dart';

class TutorialIds {
  static const firstWorkoutSession = 'first_workout_session_v1';
  static const trainHome = 'train_home_v1';
  static const catalogHome = 'catalog_home_v1';
  static const logbookHome = 'logbook_home_v1';
  static const progressHome = 'progress_home_v1';
  static const profileHome = 'profile_home_v1';
  static const planDetail = 'plan_detail_v1';
  static const generatePlans = 'generate_plans_v1';
  static const optimizedWorkoutSettings = 'optimized_workout_settings_v1';
  static const premadePlans = 'premade_plans_v1';
  static const planManagement = 'plan_management_v1';
  static const exerciseCatalog = 'exercise_catalog_v1';
  static const exerciseDetail = 'exercise_detail_v1';
  static const targetAnatomy = 'target_anatomy_v1';
  static const anatomyDetail = 'anatomy_detail_v1';
  static const bodypartDetail = 'bodypart_detail_v1';
  static const muscleDetail = 'muscle_detail_v1';
  static const weeklySetsOverview = 'weekly_sets_overview_v1';
  static const workoutDetail = 'workout_detail_v1';
  static const exerciseProgressDetail = 'exercise_progress_detail_v1';
  static const measurementTrendDetail = 'measurement_trend_detail_v1';
  static const gymProfileEditor = 'gym_profile_editor_v1';
  static const uiAppearanceSettings = 'ui_appearance_settings_v1';
  static const databaseSettings = 'database_settings_v1';
  static const onboardingManualPlan = 'onboarding_manual_plan_v1';

  static const all = <String>[
    firstWorkoutSession,
    trainHome,
    catalogHome,
    logbookHome,
    progressHome,
    profileHome,
    planDetail,
    generatePlans,
    optimizedWorkoutSettings,
    premadePlans,
    planManagement,
    exerciseCatalog,
    exerciseDetail,
    targetAnatomy,
    anatomyDetail,
    bodypartDetail,
    muscleDetail,
    weeklySetsOverview,
    workoutDetail,
    exerciseProgressDetail,
    measurementTrendDetail,
    gymProfileEditor,
    uiAppearanceSettings,
    databaseSettings,
    onboardingManualPlan,
  ];
}

class TutorialStateStore {
  static const _prefix = 'guided_tutorial_completed.';

  const TutorialStateStore();

  Future<bool> isCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tutorialId') ?? false;
  }

  Future<void> markCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tutorialId', true);
  }

  Future<void> reset(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tutorialId');
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final tutorialId in TutorialIds.all) {
      await prefs.remove('$_prefix$tutorialId');
    }
  }

  /// Hides every tutorial without preventing an individual replay later.
  Future<void> skipAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final tutorialId in TutorialIds.all) {
      await prefs.setBool('$_prefix$tutorialId', true);
    }
  }
}
