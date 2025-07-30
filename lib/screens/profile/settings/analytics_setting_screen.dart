// File: lib/screens/profile/settings/analytics_setting_screen.dart
// for viewing and changing settings related to exercise analytics.

import 'package:flutter/material.dart';
import 'bodypart_muscle_mapping_screen.dart';
import 'bodypart_ranking_screen.dart';
import 'muscle_ranking_screen.dart';
import 'volume_boundaries_screen.dart';
import 'exercise_analytics_screen.dart';

import 'exercise_editor_screen.dart';


class AnalyticsSettingsScreen extends StatelessWidget {
  const AnalyticsSettingsScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('BodyPart ↔ Muscle Mapping'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const BodyPartMuscleMappingScreen()),
            ),
          ),
          ListTile(
            title: const Text('BodyPart Training Bias Rankings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const BodyPartRankingScreen()),
            ),
          ),
          ListTile(
            title: const Text('Muscle Training Bias Rankings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const MuscleRankingScreen()),
            ),
          ),
          ListTile(
            title: const Text('Exercise to %Sets per Muscle, Bodypart'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const ExerciseAnalyticsScreen()),
            ),
          ),
          ListTile(
            title: const Text('Exercise Editor'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const ExerciseEditorScreen()),
            ),
          ),
          ListTile(
            title: const Text('Volume Boundaries per BodyPart, Muscle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const VolumeBoundariesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
