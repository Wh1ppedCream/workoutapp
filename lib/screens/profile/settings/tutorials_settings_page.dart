import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../widgets/settings_tiles.dart';

class TutorialsSettingsPage extends StatelessWidget {
  const TutorialsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.tutorialsSettingsTitle,
      subtitle: strings.tutorialsSettingsSubtitle,
      icon: Icons.school_outlined,
      heroAccentColor: SettingsAccent.appearance,
      children: [
        SettingsSection(
          title: strings.tutorialsControlsTitle,
          subtitle: strings.tutorialsControlsSubtitle,
          accentColor: SettingsAccent.data,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.restart_alt,
              title: strings.tutorialsResetAllTitle,
              subtitle: strings.tutorialsResetAllSubtitle,
              trailing: _tutorialResetPill(context, strings.tutorialsResetAll),
              onTap:
                  () => _resetAllTutorials(
                    context,
                    strings.tutorialsResetAllMessage,
                  ),
            ),
          ]),
        ),
        SettingsInfoCard(
          icon: Icons.lightbulb_outline,
          title: strings.tutorialsHowItWorksTitle,
          body: strings.tutorialsHowItWorksBody,
        ),
        const SizedBox(height: 16),
        SettingsExpansionSection(
          title: strings.tutorialsMainTabsTitle,
          subtitle: strings.tutorialsMainTabsSubtitle,
          icon: Icons.school_outlined,
          accentColor: SettingsAccent.appearance,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.fitness_center,
              tutorialId: TutorialIds.trainHome,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.menu_book_outlined,
              tutorialId: TutorialIds.catalogHome,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.history_outlined,
              tutorialId: TutorialIds.logbookHome,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.trending_up,
              tutorialId: TutorialIds.progressHome,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.person_outline,
              tutorialId: TutorialIds.profileHome,
            ),
          ]),
        ),
        SettingsExpansionSection(
          title: strings.tutorialsWorkoutTitle,
          subtitle: strings.tutorialsWorkoutSubtitle,
          icon: Icons.school_outlined,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.play_circle_outline,
              tutorialId: TutorialIds.firstWorkoutSession,
            ),
          ]),
        ),
        SettingsExpansionSection(
          title: strings.tutorialsPlansTitle,
          subtitle: strings.tutorialsPlansSubtitle,
          icon: Icons.school_outlined,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.auto_awesome,
              tutorialId: TutorialIds.generatePlans,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.tune,
              tutorialId: TutorialIds.optimizedWorkoutSettings,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.library_books_outlined,
              tutorialId: TutorialIds.premadePlans,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.fact_check_outlined,
              tutorialId: TutorialIds.planManagement,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.edit_note,
              tutorialId: TutorialIds.planDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.school_outlined,
              tutorialId: TutorialIds.onboardingManualPlan,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.receipt_long,
              tutorialId: TutorialIds.workoutDetail,
            ),
          ]),
        ),
        SettingsExpansionSection(
          title: strings.tutorialsCatalogTitle,
          subtitle: strings.tutorialsCatalogSubtitle,
          icon: Icons.school_outlined,
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.search,
              tutorialId: TutorialIds.exerciseCatalog,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.info_outline,
              tutorialId: TutorialIds.exerciseDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.accessibility_new,
              tutorialId: TutorialIds.targetAnatomy,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.accessibility,
              tutorialId: TutorialIds.bodypartDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.fitness_center,
              tutorialId: TutorialIds.muscleDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.analytics_outlined,
              tutorialId: TutorialIds.weeklySetsOverview,
            ),
          ]),
        ),
        SettingsExpansionSection(
          title: strings.tutorialsProgressTitle,
          subtitle: strings.tutorialsProgressSubtitle,
          icon: Icons.school_outlined,
          accentColor: SettingsAccent.progress,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.show_chart,
              tutorialId: TutorialIds.exerciseProgressDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.monitor_heart_outlined,
              tutorialId: TutorialIds.measurementTrendDetail,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.home_work_outlined,
              tutorialId: TutorialIds.gymProfileEditor,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.palette_outlined,
              tutorialId: TutorialIds.uiAppearanceSettings,
            ),
            _tutorialResetTile(
              context,
              icon: Icons.storage_outlined,
              tutorialId: TutorialIds.databaseSettings,
            ),
          ]),
        ),
      ],
    );
  }

  SettingsActionTile _tutorialResetTile(
    BuildContext context, {
    required IconData icon,
    required String tutorialId,
  }) {
    final strings = AppLocalizations.of(context);
    final topic = _tutorialTopic(strings, tutorialId);
    return SettingsActionTile(
      icon: icon,
      title: strings.tutorialsReplayTitle(topic),
      subtitle: strings.tutorialsShownNextTime(topic),
      trailing: _tutorialResetPill(context, strings.tutorialsReset),
      onTap:
          () => _resetTutorial(
            context,
            tutorialId,
            strings.tutorialsWillReplayNextTime(topic),
          ),
    );
  }

  Future<void> _resetTutorial(
    BuildContext context,
    String tutorialId,
    String message,
  ) async {
    await const TutorialStateStore().reset(tutorialId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetAllTutorials(BuildContext context, String message) async {
    await const TutorialStateStore().resetAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _tutorialTopic(AppLocalizations strings, String tutorialId) {
    return switch (tutorialId) {
      TutorialIds.trainHome => strings.tutorialsTopicTrain,
      TutorialIds.catalogHome => strings.tutorialsTopicCatalog,
      TutorialIds.logbookHome => strings.tutorialsTopicLogbook,
      TutorialIds.progressHome => strings.tutorialsTopicProgress,
      TutorialIds.profileHome => strings.tutorialsTopicProfile,
      TutorialIds.firstWorkoutSession => strings.tutorialsTopicFirstWorkout,
      TutorialIds.generatePlans => strings.tutorialsTopicGeneratePlans,
      TutorialIds.optimizedWorkoutSettings =>
        strings.tutorialsTopicOptimizedSettings,
      TutorialIds.premadePlans => strings.tutorialsTopicPremadePlans,
      TutorialIds.planManagement => strings.tutorialsTopicPlanManagement,
      TutorialIds.planDetail => strings.tutorialsTopicPlanDetail,
      TutorialIds.onboardingManualPlan => strings.tutorialsTopicPlanBuilder,
      TutorialIds.workoutDetail => strings.tutorialsTopicWorkoutDetail,
      TutorialIds.exerciseCatalog => strings.tutorialsTopicExerciseCatalog,
      TutorialIds.exerciseDetail => strings.tutorialsTopicExerciseDetail,
      TutorialIds.targetAnatomy => strings.tutorialsTopicTargetAnatomy,
      TutorialIds.bodypartDetail => strings.tutorialsTopicBodypartDetail,
      TutorialIds.muscleDetail => strings.tutorialsTopicMuscleDetail,
      TutorialIds.weeklySetsOverview => strings.tutorialsTopicWeeklySets,
      TutorialIds.exerciseProgressDetail =>
        strings.tutorialsTopicExerciseProgress,
      TutorialIds.measurementTrendDetail =>
        strings.tutorialsTopicMeasurementTrend,
      TutorialIds.gymProfileEditor => strings.tutorialsTopicGymProfile,
      TutorialIds.uiAppearanceSettings => strings.tutorialsTopicUiAppearance,
      TutorialIds.databaseSettings => strings.tutorialsTopicDatabaseSettings,
      _ => strings.tutorialsTopicGuide,
    };
  }
}

Widget _tutorialResetPill(BuildContext context, String label) {
  return SettingsAccentPill(
    label: label,
    color: Theme.of(context).colorScheme.primary,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    backgroundAlpha: 0.13,
    borderAlpha: 0.42,
    fontWeight: FontWeight.w900,
  );
}
