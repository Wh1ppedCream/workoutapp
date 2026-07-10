// lib/screens/profile/settings/gym_exercise_settings_page.dart

import 'package:flutter/material.dart';

import '../../../widgets/settings_tiles.dart';
import 'analytics_setting_screen.dart';
import 'flow_chart_page.dart';
import 'flow_methods_page.dart';
import 'preset_flow_settings_screen.dart';

class GymExerciseSettingsPage extends StatelessWidget {
  const GymExerciseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Gym & Workout Settings',
      subtitle:
          'Tune workout generation, analytics, and workout-flow behavior.',
      icon: Icons.fitness_center,
      children: [
        SettingsSection(
          title: 'Workout Logic',
          subtitle: 'Settings that affect planning and generated workouts.',
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.bar_chart,
              title: 'Workout Settings',
              subtitle:
                  'Volume limits, analytics defaults, and training controls.',
              onTap: () => _open(context, const AnalyticsSettingsScreen()),
            ),
            SettingsActionTile(
              icon: Icons.account_tree_outlined,
              title: 'Plan Flow Settings',
              subtitle:
                  'Configure the logic used when plan flow automation runs.',
              onTap: () => _open(context, const PresetFlowSettingsScreen()),
            ),
          ]),
        ),
        SettingsSection(
          title: 'Flow Tools',
          subtitle: 'Advanced setup tools for workout flow experiments.',
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.schema_outlined,
              title: 'Flow Chart',
              subtitle: 'Preview and inspect flow chart behavior.',
              onTap: () => _open(context, const FlowChartPage()),
            ),
            SettingsActionTile(
              icon: Icons.route_outlined,
              title: 'Workout Progress Rules',
              subtitle: 'Manage weight, rep, and set progression rules.',
              onTap: () => _open(context, const FlowMethodsPage()),
            ),
          ]),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
