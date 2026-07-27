// File: lib/screens/profile/settings/analytics_setting_screen.dart
// Hub for exercise analytics and training recommendation settings.

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/settings_tiles.dart';
import 'bodypart_muscle_mapping_screen.dart';
import 'bodypart_ranking_screen.dart';
import 'exercise_analytics_screen.dart';
import 'exercise_editor_screen.dart';
import 'muscle_ranking_screen.dart';
import 'volume_boundaries_screen.dart';

class AnalyticsSettingsScreen extends StatelessWidget {
  const AnalyticsSettingsScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.settingsWorkoutTitle,
      subtitle: strings.settingsWorkoutSubtitle,
      icon: Icons.tune,
      heroAccentColor: SettingsAccent.training,
      children: [
        SettingsSection(
          title: strings.settingsTrainingBiasTitle,
          subtitle: strings.settingsTrainingBiasSubtitle,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.accessibility_new,
              iconColor: SettingsAccent.training,
              title: strings.settingsBodyPartRankings,
              subtitle: strings.settingsBodyPartRankingsSubtitle,
              onTap: () => _open(context, const BodyPartRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.fitness_center,
              iconColor: SettingsAccent.training,
              title: strings.settingsMuscleRankings,
              subtitle: strings.settingsMuscleRankingsSubtitle,
              onTap: () => _open(context, const MuscleRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.track_changes,
              iconColor: SettingsAccent.training,
              title: strings.settingsVolumeBoundaries,
              subtitle: strings.settingsVolumeBoundariesSubtitle,
              onTap: () => _open(context, const VolumeBoundariesScreen()),
            ),
          ]),
        ),
        SettingsSection(
          title: strings.settingsExerciseDefinitionsTitle,
          subtitle: strings.settingsExerciseDefinitionsSubtitle,
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.hub,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsAnatomyMapping,
              subtitle: strings.settingsAnatomyMappingSubtitle,
              onTap: () => _open(context, const BodyPartMuscleMappingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.analytics,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsExerciseSetAllocation,
              subtitle: strings.settingsExerciseSetAllocationSubtitle,
              onTap: () => _open(context, const ExerciseAnalyticsScreen()),
            ),
            SettingsActionTile(
              icon: Icons.edit_note,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsExerciseEditor,
              subtitle: strings.settingsExerciseEditorSubtitle,
              onTap: () => _open(context, const ExerciseEditorScreen()),
            ),
          ]),
        ),
      ],
    );
  }
}
