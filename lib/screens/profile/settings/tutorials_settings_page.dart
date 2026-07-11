import 'package:flutter/material.dart';

import '../../../services/tutorial_state_store.dart';
import '../../../widgets/settings_tiles.dart';

class TutorialsSettingsPage extends StatelessWidget {
  const TutorialsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Guided Tutorials',
      subtitle: 'Replay walkthroughs or reset them while learning the app.',
      icon: Icons.school_outlined,
      heroAccentColor: SettingsAccent.appearance,
      children: [
        const SettingsInfoCard(
          icon: Icons.lightbulb_outline,
          title: 'How tutorials work',
          body:
              'Tutorials appear once, then stay out of the way. Reset one here when you want it to show again.',
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Main Tabs',
          subtitle: 'Replay walkthroughs for each main area.',
          accentColor: SettingsAccent.appearance,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.fitness_center,
              title: 'Replay Train Tutorial',
              subtitle: 'Shows next time you open the Train tab.',
              tutorialId: TutorialIds.trainHome,
              message: 'Train tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.menu_book_outlined,
              title: 'Replay Catalog Tutorial',
              subtitle: 'Shows next time you open the Catalog tab.',
              tutorialId: TutorialIds.catalogHome,
              message: 'Catalog tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.history_outlined,
              title: 'Replay Logbook Tutorial',
              subtitle: 'Shows next time you open the Logbook tab.',
              tutorialId: TutorialIds.logbookHome,
              message: 'Logbook tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.trending_up,
              title: 'Replay Progress Tutorial',
              subtitle: 'Shows next time you open the Progress tab.',
              tutorialId: TutorialIds.progressHome,
              message: 'Progress tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.person_outline,
              title: 'Replay Profile Tutorial',
              subtitle: 'Shows next time you open the Profile tab.',
              tutorialId: TutorialIds.profileHome,
              message: 'Profile tutorial will replay next time.',
            ),
          ]),
        ),
        SettingsSection(
          title: 'Workout',
          subtitle: 'Help for logging your first session.',
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.play_circle_outline,
              title: 'Replay First Workout Tutorial',
              subtitle: 'Shows next time you open a workout session.',
              tutorialId: TutorialIds.firstWorkoutSession,
              message: 'First workout tutorial will replay next time.',
            ),
          ]),
        ),
        SettingsSection(
          title: 'Plans & Workouts',
          subtitle: 'Replay plan creation, editing, and workout detail help.',
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.auto_awesome,
              title: 'Replay Generate Plans Tutorial',
              subtitle: 'Shows next time you open Generate Plans.',
              tutorialId: TutorialIds.generatePlans,
              message: 'Generate Plans tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.tune,
              title: 'Replay Optimized Settings Tutorial',
              subtitle: 'Shows next time you open optimized workout settings.',
              tutorialId: TutorialIds.optimizedWorkoutSettings,
              message:
                  'Optimized workout settings tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.library_books_outlined,
              title: 'Replay Premade Plans Tutorial',
              subtitle: 'Shows next time you open Premade Plans.',
              tutorialId: TutorialIds.premadePlans,
              message: 'Premade Plans tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.fact_check_outlined,
              title: 'Replay Plan Management Tutorial',
              subtitle: 'Shows next time you manage plans.',
              tutorialId: TutorialIds.planManagement,
              message: 'Plan Management tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.edit_note,
              title: 'Replay Plan Detail Tutorial',
              subtitle: 'Shows next time you open a plan.',
              tutorialId: TutorialIds.planDetail,
              message: 'Plan Detail tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.receipt_long,
              title: 'Replay Workout Detail Tutorial',
              subtitle: 'Shows next time you open a past workout.',
              tutorialId: TutorialIds.workoutDetail,
              message: 'Workout Detail tutorial will replay next time.',
            ),
          ]),
        ),
        SettingsSection(
          title: 'Catalog & Anatomy',
          subtitle: 'Replay exercise and target anatomy help.',
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.search,
              title: 'Replay Exercise Catalog Tutorial',
              subtitle: 'Shows next time you open the Exercise Catalog.',
              tutorialId: TutorialIds.exerciseCatalog,
              message: 'Exercise Catalog tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.info_outline,
              title: 'Replay Exercise Detail Tutorial',
              subtitle: 'Shows next time you open an exercise detail sheet.',
              tutorialId: TutorialIds.exerciseDetail,
              message: 'Exercise Detail tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.accessibility_new,
              title: 'Replay Target Anatomy Tutorial',
              subtitle: 'Shows next time you open Target Anatomy.',
              tutorialId: TutorialIds.targetAnatomy,
              message: 'Target Anatomy tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.accessibility,
              title: 'Replay Bodypart Detail Tutorial',
              subtitle: 'Shows next time you open a bodypart page.',
              tutorialId: TutorialIds.bodypartDetail,
              message: 'Bodypart Detail tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.fitness_center,
              title: 'Replay Muscle Detail Tutorial',
              subtitle: 'Shows next time you open a muscle page.',
              tutorialId: TutorialIds.muscleDetail,
              message: 'Muscle Detail tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Replay Weekly Sets Tutorial',
              subtitle: 'Shows next time you open Weekly Sets Overview.',
              tutorialId: TutorialIds.weeklySetsOverview,
              message: 'Weekly Sets tutorial will replay next time.',
            ),
          ]),
        ),
        SettingsSection(
          title: 'Progress & Settings',
          subtitle: 'Replay progress detail and settings page help.',
          accentColor: SettingsAccent.progress,
          children: settingsTilesWithDividers(context, [
            _tutorialResetTile(
              context,
              icon: Icons.show_chart,
              title: 'Replay Exercise Progress Tutorial',
              subtitle: 'Shows next time you open an exercise progress detail.',
              tutorialId: TutorialIds.exerciseProgressDetail,
              message: 'Exercise Progress tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.monitor_heart_outlined,
              title: 'Replay Measurement Trend Tutorial',
              subtitle: 'Shows next time you open a measurement trend.',
              tutorialId: TutorialIds.measurementTrendDetail,
              message: 'Measurement Trend tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.home_work_outlined,
              title: 'Replay Gym Profile Tutorial',
              subtitle: 'Shows next time you edit a gym profile.',
              tutorialId: TutorialIds.gymProfileEditor,
              message: 'Gym Profile tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Replay UI Settings Tutorial',
              subtitle: 'Shows next time you open UI & Appearance.',
              tutorialId: TutorialIds.uiAppearanceSettings,
              message: 'UI Settings tutorial will replay next time.',
            ),
            _tutorialResetTile(
              context,
              icon: Icons.storage_outlined,
              title: 'Replay Database Tutorial',
              subtitle: 'Shows next time you open Database Settings.',
              tutorialId: TutorialIds.databaseSettings,
              message: 'Database tutorial will replay next time.',
            ),
          ]),
        ),
        SettingsSection(
          title: 'All Tutorials',
          subtitle: 'Useful while testing new guided help.',
          accentColor: SettingsAccent.data,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.restart_alt,
              title: 'Reset All Tutorials',
              subtitle: 'Makes every guided tutorial available again.',
              trailing: _ResetPill(label: 'Reset all'),
              onTap:
                  () => _resetAllTutorials(
                    context,
                    'All tutorials have been reset.',
                  ),
            ),
          ]),
        ),
      ],
    );
  }

  SettingsActionTile _tutorialResetTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String tutorialId,
    required String message,
  }) {
    return SettingsActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: _ResetPill(label: 'Reset'),
      onTap: () => _resetTutorial(context, tutorialId, message),
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
