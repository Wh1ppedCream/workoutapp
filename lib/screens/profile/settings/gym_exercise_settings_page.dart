// lib/screens/profile/settings/gym_exercise_settings_page.dart

import 'package:flutter/material.dart';

import '../../../services/workout_exit_preferences.dart';
import '../../../widgets/settings_tiles.dart';
import 'analytics_setting_screen.dart';
import 'flow_methods_page.dart';
import 'workout_progress_flows_page.dart';

class GymExerciseSettingsPage extends StatefulWidget {
  const GymExerciseSettingsPage({super.key});

  @override
  State<GymExerciseSettingsPage> createState() =>
      _GymExerciseSettingsPageState();
}

class _GymExerciseSettingsPageState extends State<GymExerciseSettingsPage> {
  static const _exitPreferences = WorkoutExitPreferences();

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Gym & Workout Settings',
      subtitle:
          'Tune workout generation, analytics, and workout-flow behavior.',
      icon: Icons.fitness_center,
      heroAccentColor: SettingsAccent.training,
      children: [
        SettingsSection(
          title: 'Workout Logic',
          subtitle: 'Settings that affect planning and generated workouts.',
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.bar_chart,
              iconColor: SettingsAccent.training,
              title: 'Workout Settings',
              subtitle:
                  'Volume limits, analytics defaults, and training controls.',
              onTap: () => _open(context, const AnalyticsSettingsScreen()),
            ),
            FutureBuilder<WorkoutExitBehavior>(
              future: _exitPreferences.load(),
              builder: (context, snapshot) {
                final behavior =
                    snapshot.data ?? WorkoutExitBehavior.askEveryTime;
                return SettingsActionTile(
                  icon: Icons.exit_to_app_outlined,
                  iconColor: SettingsAccent.training,
                  title: 'Ongoing Workout Exit',
                  subtitle: _exitBehaviorLabel(behavior),
                  onTap: () => _chooseExitBehavior(behavior),
                );
              },
            ),
          ]),
        ),
        SettingsSection(
          title: 'Flow Tools',
          subtitle: 'Manage saved progression paths and actions.',
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.schema_outlined,
              iconColor: SettingsAccent.advanced,
              title: 'Workout Progress Flows',
              subtitle:
                  'Edit progression flows for app defaults, gyms, and plans.',
              onTap: () => _open(context, const WorkoutProgressFlowsPage()),
            ),
            SettingsActionTile(
              icon: Icons.route_outlined,
              iconColor: SettingsAccent.advanced,
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

  String _exitBehaviorLabel(WorkoutExitBehavior behavior) {
    return switch (behavior) {
      WorkoutExitBehavior.askEveryTime => 'Ask before ending completed work.',
      WorkoutExitBehavior.discard => 'Cancel without saving completed work.',
      WorkoutExitBehavior.saveCompleted => 'Save completed work to Logbook.',
    };
  }

  Future<void> _chooseExitBehavior(WorkoutExitBehavior current) async {
    final selected = await showDialog<WorkoutExitBehavior>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: const Text('Ongoing Workout Exit'),
            children: [
              for (final behavior in WorkoutExitBehavior.values)
                RadioListTile<WorkoutExitBehavior>(
                  value: behavior,
                  groupValue: current,
                  title: Text(
                    switch (behavior) {
                      WorkoutExitBehavior.askEveryTime => 'Ask every time',
                      WorkoutExitBehavior.discard => 'Cancel workout',
                      WorkoutExitBehavior.saveCompleted => 'End and save',
                    },
                  ),
                  subtitle: Text(_exitBehaviorLabel(behavior)),
                  onChanged:
                      (value) => Navigator.pop(dialogContext, value),
                ),
            ],
          ),
    );
    if (selected == null) return;
    await _exitPreferences.save(selected);
    if (mounted) setState(() {});
  }
}
