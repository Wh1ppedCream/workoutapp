import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/tokens/app_shape_tokens.dart';
import '../../../theme/tokens/app_settings_presentation_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../widgets/settings_tiles.dart';

class TutorialsSettingsPage extends StatelessWidget {
  const TutorialsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressiveProfile =
        context.usesExpressivePresentation &&
        Theme.of(context).extension<AppExpressiveTrainTokens>() != null;
    return _withExpressiveProfileTheme(
      context,
      SettingsPageScaffold(
        title: strings.tutorialsSettingsTitle,
        subtitle: strings.tutorialsSettingsSubtitle,
        icon: Icons.school_outlined,
        heroAccentColor: SettingsAccent.appearance,
        children: [
          SettingsSection(
            title: strings.tutorialsControlsTitle,
            subtitle: expressiveProfile
                ? strings.tutorialsExpressiveControlsSubtitle
                : strings.tutorialsControlsSubtitle,
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.restart_alt,
                title: strings.tutorialsResetAllTitle,
                subtitle: strings.tutorialsResetAllSubtitle,
                trailing: _tutorialResetPill(
                  context,
                  strings.tutorialsResetAll,
                ),
                onTap: () => _resetAllTutorials(
                  context,
                  strings.tutorialsResetAllMessage,
                ),
              ),
            ]),
          ),
          SettingsInfoCard(
            icon: Icons.lightbulb_outline,
            title: strings.tutorialsHowItWorksTitle,
            body: expressiveProfile
                ? strings.tutorialsExpressiveHowItWorksBody
                : strings.tutorialsHowItWorksBody,
          ),
          const SizedBox(height: 16),
          SettingsExpansionSection(
            title: strings.tutorialsMainTabsTitle,
            subtitle: strings.tutorialsMainTabsSubtitle,
            icon: Icons.school_outlined,
            accentColor: SettingsAccent.appearance,
            compact: expressiveProfile,
            compactHeaderVerticalPadding: expressiveProfile ? 0 : null,
            subtitleMaxLines: expressiveProfile ? 2 : 1,
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
            icon: Icons.fitness_center,
            accentColor: SettingsAccent.training,
            compact: expressiveProfile,
            compactHeaderVerticalPadding: expressiveProfile ? 0 : null,
            subtitleMaxLines: expressiveProfile ? 2 : 1,
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
            icon: Icons.auto_awesome_outlined,
            accentColor: SettingsAccent.training,
            compact: expressiveProfile,
            compactHeaderVerticalPadding: expressiveProfile ? 0 : null,
            subtitleMaxLines: expressiveProfile ? 2 : 1,
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
            icon: Icons.menu_book_outlined,
            accentColor: SettingsAccent.advanced,
            compact: expressiveProfile,
            compactHeaderVerticalPadding: expressiveProfile ? 0 : null,
            subtitleMaxLines: expressiveProfile ? 2 : 1,
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
            icon: Icons.trending_up,
            accentColor: SettingsAccent.progress,
            compact: expressiveProfile,
            compactHeaderVerticalPadding: expressiveProfile ? 0 : null,
            subtitleMaxLines: expressiveProfile ? 2 : 1,
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
      ),
    );
  }

  SettingsActionTile _tutorialResetTile(
    BuildContext context, {
    required IconData icon,
    required String tutorialId,
  }) {
    final strings = AppLocalizations.of(context);
    final topic = _tutorialTopic(strings, tutorialId);
    final expressiveProfile =
        context.usesExpressivePresentation &&
        Theme.of(context).extension<AppExpressiveTrainTokens>() != null;
    final expressiveTopic = expressiveProfile
        ? _expressiveTutorialTopic(context, topic)
        : topic;
    return SettingsActionTile(
      icon: icon,
      title: expressiveProfile
          ? strings.tutorialsExpressiveTitle(expressiveTopic)
          : strings.tutorialsReplayTitle(topic),
      subtitle: expressiveProfile
          ? strings.tutorialsExpressiveShownNextTime(expressiveTopic)
          : strings.tutorialsShownNextTime(topic),
      trailing: _tutorialResetPill(context, strings.tutorialsReset),
      compact: expressiveProfile,
      compactVerticalPadding: expressiveProfile ? 0 : null,
      onTap: () => _resetTutorial(
        context,
        tutorialId,
        strings.tutorialsWillReplayNextTime(topic),
      ),
    );
  }

  String _expressiveTutorialTopic(BuildContext context, String topic) {
    if (Localizations.localeOf(context).languageCode != 'en') return topic;
    return switch (topic) {
      'first workout' => 'First workout',
      'optimized workout settings' => 'Optimized Workout Settings',
      'plan management' => 'Plan Management',
      'plan details' => 'Plan Details',
      'plan builder' => 'Plan Builder',
      'workout details' => 'Workout Details',
      'exercise details' => 'Exercise Details',
      'bodypart details' => 'Body Part Details',
      'muscle details' => 'Muscle Details',
      'exercise progress' => 'Exercise Progress',
      'measurement trend' => 'Measurement Trend',
      'Gym Profile editor' => 'Gym Profile Editor',
      'guided help' => 'Guided Help',
      _ => topic,
    };
  }

  Future<void> _resetTutorial(
    BuildContext context,
    String tutorialId,
    String message,
  ) async {
    await const TutorialStateStore().reset(tutorialId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetAllTutorials(BuildContext context, String message) async {
    await const TutorialStateStore().resetAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
  final theme = Theme.of(context);
  final expressive = theme.extension<AppExpressiveTrainTokens>();
  final destination = theme.extension<AppExpressiveDestinationTokens>();
  if (context.usesExpressivePresentation &&
      destination?.family == AppExpressiveDestinationFamily.profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: destination!.surfaceSelected,
        borderRadius: ExpressiveTrainShapes.compactControl,
        border: Border.all(
          color: destination.outlineAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: destination.onSurfaceSelected,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
  if (context.usesExpressivePresentation && expressive != null) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: expressive.focusInset,
        borderRadius: ExpressiveTrainShapes.compactControl,
        border: Border.all(
          color: expressive.focusInsetForeground.withValues(alpha: 0.32),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: expressive.focusInsetForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  return SettingsAccentPill(
    label: label,
    color: theme.colorScheme.primary,
    parentSurface: context.surfaceTokens.settingsSection,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    backgroundAlpha: 0.13,
    borderAlpha: 0.42,
    fontWeight: FontWeight.w900,
  );
}

Widget _withExpressiveProfileTheme(BuildContext context, Widget child) {
  final theme = Theme.of(context);
  final expressive = theme.extension<AppExpressiveTrainTokens>();
  if (!context.usesExpressivePresentation || expressive == null) return child;

  final updatedExtensions = theme.extensions.values
      .where(
        (extension) =>
            extension is! AppShapeTokens &&
            extension is! AppSettingsPresentationTokens,
      )
      .toList();
  updatedExtensions.add(
    theme.shapeTokens.copyWith(
      hero: ExpressiveTrainShapes.focusHero,
      sheet: ExpressiveTrainShapes.section,
      settingsPanel: ExpressiveTrainShapes.section,
      settingsAction: ExpressiveTrainShapes.compactControl,
      settingsInput: ExpressiveTrainShapes.compactControl,
      settingsField: ExpressiveTrainShapes.compactControl,
      dialogChoice: ExpressiveTrainShapes.menu,
    ),
  );
  updatedExtensions.add(
    theme.settingsPresentationTokens.copyWith(
      sectionHeaderUsesLabel: true,
      sectionHeaderFill: expressive.selectorTrack,
      sectionHeaderForeground: expressive.navigationLabel,
    ),
  );
  updatedExtensions.removeWhere(
    (extension) => extension is AppExpressiveDestinationTokens,
  );
  final profilePalette = AppExpressiveDestinationTokens.forFamily(
    AppExpressiveDestinationFamily.profile,
    theme.brightness,
  );
  Color tint(Color role) => Color.lerp(profilePalette.pageCanvas, role, 0.16)!;
  updatedExtensions.add(
    profilePalette.copyWith(
      surfacePrimary: profilePalette.surfacePrimary,
      onSurfacePrimary: profilePalette.onSurfacePrimary,
      surfaceSecondary: tint(profilePalette.surfaceSecondary),
      onSurfaceSecondary: profilePalette.supportingForeground,
      surfaceTertiary: tint(profilePalette.surfaceTertiary),
      onSurfaceTertiary: profilePalette.supportingForeground,
      surfaceAccent: tint(profilePalette.surfaceAccent),
      onSurfaceAccent: profilePalette.supportingForeground,
    ),
  );

  return AppExpressiveDestinationTheme(
    family: AppExpressiveDestinationFamily.profile,
    child: Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: expressive.pageCanvas,
        dialogTheme: theme.dialogTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: ExpressiveTrainShapes.menu,
          ),
        ),
        extensions: updatedExtensions,
      ),
      child: child,
    ),
  );
}
