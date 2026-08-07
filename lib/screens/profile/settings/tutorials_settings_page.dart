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
              trailing: _ResetPill(label: strings.tutorialsResetAll),
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
        _TutorialSettingsSection(
          title: strings.tutorialsMainTabsTitle,
          subtitle: strings.tutorialsMainTabsSubtitle,
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
        _TutorialSettingsSection(
          title: strings.tutorialsWorkoutTitle,
          subtitle: strings.tutorialsWorkoutSubtitle,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.play_circle_outline,
              tutorialId: TutorialIds.firstWorkoutSession,
            ),
          ]),
        ),
        _TutorialSettingsSection(
          title: strings.tutorialsPlansTitle,
          subtitle: strings.tutorialsPlansSubtitle,
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
        _TutorialSettingsSection(
          title: strings.tutorialsCatalogTitle,
          subtitle: strings.tutorialsCatalogSubtitle,
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
        _TutorialSettingsSection(
          title: strings.tutorialsProgressTitle,
          subtitle: strings.tutorialsProgressSubtitle,
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
      trailing: _ResetPill(label: strings.tutorialsReset),
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

class _TutorialSettingsSection extends StatelessWidget {
  const _TutorialSettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withValues(alpha: 0.46)),
        ),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
            colorScheme: scheme.copyWith(primary: accentColor),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.school_outlined, color: accentColor, size: 22),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _ResetPill extends StatelessWidget {
  final String label;

  const _ResetPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.42)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
