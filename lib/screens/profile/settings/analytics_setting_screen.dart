// File: lib/screens/profile/settings/analytics_setting_screen.dart
// Hub for exercise analytics and training recommendation settings.

import 'package:flutter/material.dart';

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
    return SettingsPageScaffold(
      title: 'Workout Settings',
      subtitle:
          'Tune how the app understands anatomy, training bias, and volume targets.',
      icon: Icons.tune,
      heroAccentColor: SettingsAccent.training,
      children: [
        SettingsSection(
          title: 'Training Bias',
          subtitle: 'Controls used by generated plans and optimized workouts.',
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.accessibility_new,
              iconColor: SettingsAccent.training,
              title: 'Body Part Rankings',
              subtitle: 'Prioritize which body parts should receive more work.',
              onTap: () => _open(context, const BodyPartRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.fitness_center,
              iconColor: SettingsAccent.training,
              title: 'Muscle Rankings',
              subtitle: 'Prioritize specific muscles inside the anatomy model.',
              onTap: () => _open(context, const MuscleRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.track_changes,
              iconColor: SettingsAccent.training,
              title: 'Volume Boundaries',
              subtitle:
                  'Set recommended weekly ranges for body parts and muscles.',
              onTap: () => _open(context, const VolumeBoundariesScreen()),
            ),
          ]),
        ),
        SettingsSection(
          title: 'Exercise Definitions',
          subtitle: 'Maintain the anatomy and exercise data used by the app.',
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.hub,
              iconColor: SettingsAccent.advanced,
              title: 'Body Part / Muscle Mapping',
              subtitle: 'Choose which muscles belong to each body part.',
              onTap: () => _open(context, const BodyPartMuscleMappingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.analytics,
              iconColor: SettingsAccent.advanced,
              title: 'Exercise Set Allocation',
              subtitle:
                  'Review how each exercise contributes to muscles and body parts.',
              onTap: () => _open(context, const ExerciseAnalyticsScreen()),
            ),
            SettingsActionTile(
              icon: Icons.edit_note,
              iconColor: SettingsAccent.advanced,
              title: 'Exercise Editor',
              subtitle:
                  'Update exercise names, details, equipment, and mappings.',
              onTap: () => _open(context, const ExerciseEditorScreen()),
            ),
          ]),
        ),
      ],
    );
  }
}
