// lib/screens/profile/settings/gym_exercise_settings_page.dart
import 'package:flutter/material.dart';
import 'analytics_setting_screen.dart';
import 'flow_chart_page.dart';
import 'preset_flow_settings_screen.dart';

class GymExerciseSettingsPage extends StatelessWidget {
  const GymExerciseSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym & Workout Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Workout Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsSettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Flowchart Example'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FlowChartPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Preset Flow Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PresetFlowSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}