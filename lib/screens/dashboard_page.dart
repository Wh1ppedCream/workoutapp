// File: lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_config.dart';
import '../widgets/nutrition_dash.dart';
import '../widgets/workout_dashboard.dart';
import '../widgets/quick_bar.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardSettingsPage()),
              );
            },
          )
        ],
      ),
      body: Consumer<DashboardConfig>(
        builder: (_, config, __) => ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            config.reorder(oldIndex, newIndex);
          },
          children: [
            for (var id in config.widgetOrder)
              if (config.isVisible(id))
                _buildDashboardTile(id, key: ValueKey(id)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(String id, { required Key key }) {
    switch (id) {
      
      case 'quickBar':
       return Card(
         key: key,
         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         child: const QuickBar(),    // ← your new QuickBar
       );

      case 'nutritionDash':
        return Card(
          key: key,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: NutritionDash(
              caloriesConsumed: 500,    // TODO: wire real values here
              calorieGoal:    2000,
              proteinConsumed: 20,
              proteinTarget:   100,
              carbConsumed:    50,
              carbTarget:      200,
              fatConsumed:     10,
              fatTarget:       70,
              scale: 0.7,  // pass scale down
            ),
          ),
        );

      case 'workoutDashboard':
  return Card(
    key: key,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const WorkoutDashboard( 
      scale: 0.7,  // default scale for existing sizes
    ),
  );



      default:
        return Card(
          key: key,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Placeholder for $id'),
          ),
        );
    }
  }
}

class DashboardSettingsPage extends StatelessWidget {
  const DashboardSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Dashboard')),
      body: Consumer<DashboardConfig>(
        builder: (_, config, __) => ListView(
          children: [
            for (var id in config.widgetOrder)
              SwitchListTile(
                title: Text(_labelFor(id)),
                value: config.isVisible(id),
                onChanged: (_) => config.toggleVisibility(id),
              ),
          ],
        ),
      ),
    );
  }

  String _labelFor(String id) {
    switch (id) {
      case 'quickBar':
     return 'Quick Actions';
      case 'nutritionDash':
        return 'Nutrition Dashboard';
      case 'workoutDashboard':
        return 'Workout Dashboard';
      case 'quickStats':
        return 'Quick Stats';
      case 'recentWorkouts':
        return 'Recent Workouts';
      case 'profileSummary':
        return 'Profile Summary';
      default:
        return id;
    }
  }
}
