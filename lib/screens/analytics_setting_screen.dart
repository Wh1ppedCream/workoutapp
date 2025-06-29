import 'package:flutter/material.dart';
import 'bodypart_muscle_mapping_screen.dart';
import 'bodypart_ranking_screen.dart';
import 'muscle_ranking_screen.dart';
import 'exercise_muscle_percent_screen.dart';
import 'volume_boundaries_screen.dart';

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
            title: const Text('BodyPart Rankings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const BodyPartRankingScreen()),
            ),
          ),
          ListTile(
            title: const Text('Muscle Rankings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const MuscleRankingScreen()),
            ),
          ),
          ListTile(
            title: const Text('Exercise–Muscle % Hit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const ExerciseMusclePercentScreen()),
            ),
          ),
          ListTile(
            title: const Text('Volume Boundaries'),
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
