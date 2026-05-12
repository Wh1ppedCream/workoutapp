// File: lib/screens/exercise/history_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/history_content.dart';
import '../../widgets/drawers.dart';
import '../profile/settings/gym_exercise_settings_page.dart';
import 'analytics_dashboard_screen.dart';
import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';

/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(
        headerTitle: 'Workout History',
        items: [
          DrawerItem(
            title: 'Exercise Catalog',
            icon: Icons.fitness_center,
            builder: (_) => const ExerciseCatalogPage(),
          ),
          DrawerItem(
            title: 'Exercise Focus Library',
            icon: Icons.accessibility_new,
            builder: (_) => const MuscleFilterPage(),
          ),
          DrawerItem(
            title: '7-Day Analytics',
            icon: Icons.analytics,
            builder: (_) => const AnalyticsDashboardScreen(),
          ),
          DrawerItem(
            title: 'Gym & Workout Settings',
            icon: Icons.settings,
            builder: (_) => const GymExerciseSettingsPage(),
          ),
        ],
      ),
      appBar: AppBar(title: const Text('Workout Log'), centerTitle: true),
      body: HistoryContent(onReload: () => setState(() {})),
    );
  }
}
