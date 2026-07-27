// lib/screens/profile/settings/gym_exercise_settings_page.dart

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
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
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.gymSettingsTitle,
      subtitle: strings.gymSettingsSubtitle,
      icon: Icons.fitness_center,
      heroAccentColor: SettingsAccent.training,
      children: [
        SettingsSection(
          title: strings.gymSettingsLogicTitle,
          subtitle: strings.gymSettingsLogicSubtitle,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.bar_chart,
              iconColor: SettingsAccent.training,
              title: strings.gymSettingsWorkoutTitle,
              subtitle: strings.gymSettingsWorkoutSubtitle,
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
                  title: strings.gymSettingsExitTitle,
                  subtitle: _exitBehaviorLabel(behavior, strings),
                  onTap: () => _chooseExitBehavior(behavior),
                );
              },
            ),
          ]),
        ),
        SettingsSection(
          title: strings.gymSettingsFlowToolsTitle,
          subtitle: strings.gymSettingsFlowToolsSubtitle,
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.schema_outlined,
              iconColor: SettingsAccent.advanced,
              title: strings.flowPageTitle,
              subtitle: strings.gymSettingsFlowsSubtitle,
              onTap: () => _open(context, const WorkoutProgressFlowsPage()),
            ),
            SettingsActionTile(
              icon: Icons.route_outlined,
              iconColor: SettingsAccent.advanced,
              title: strings.rulesPageTitle,
              subtitle: strings.gymSettingsRulesSubtitle,
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

  String _exitBehaviorLabel(
    WorkoutExitBehavior behavior,
    AppLocalizations strings,
  ) {
    return switch (behavior) {
      WorkoutExitBehavior.askEveryTime => strings.gymExitAskBody,
      WorkoutExitBehavior.discard => strings.gymExitDiscardBody,
      WorkoutExitBehavior.saveCompleted => strings.gymExitSaveBody,
    };
  }

  Future<void> _chooseExitBehavior(WorkoutExitBehavior current) async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<WorkoutExitBehavior>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: Text(strings.gymSettingsExitTitle),
            children: [
              for (final behavior in WorkoutExitBehavior.values)
                RadioListTile<WorkoutExitBehavior>(
                  value: behavior,
                  groupValue: current,
                  title: Text(switch (behavior) {
                    WorkoutExitBehavior.askEveryTime => strings.gymExitAsk,
                    WorkoutExitBehavior.discard => strings.gymExitDiscard,
                    WorkoutExitBehavior.saveCompleted => strings.gymExitSave,
                  }),
                  subtitle: Text(_exitBehaviorLabel(behavior, strings)),
                  onChanged: (value) => Navigator.pop(dialogContext, value),
                ),
            ],
          ),
    );
    if (selected == null) return;
    await _exitPreferences.save(selected);
    if (mounted) setState(() {});
  }
}
