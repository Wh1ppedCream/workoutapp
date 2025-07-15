// File: lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_config.dart';
import '../widgets/nutrition_dash.dart';
import '../widgets/workout_dashboard.dart';
import '../widgets/quick_bar.dart';
import '../widgets/history_summary_widget.dart';


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
        builder: (_, config, __) {
          // Only keep the visible IDs
          final visibleIds = config.widgetOrder.where(config.isVisible).toList();
          return ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              config.reorder(oldIndex, newIndex);
            },
            children: [
              for (var i = 0; i < visibleIds.length; i++)
                // Wrap each tile+divider in a Column
                Container(
                  key: ValueKey(visibleIds[i]),
                  // Optional horizontal inset:
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDashboardTile(visibleIds[i]),
                      // Only draw a divider if it's not the last item:
                      if (i < visibleIds.length - 1)
                        const Divider(height: 1, thickness: 1),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Returns the *bare* widget for each section, without any Card/margin.
  Widget _buildDashboardTile(String id) {
    switch (id) {
      
      case 'quickBar':
        return const QuickBar();

       case 'nutritionDash':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: NutritionDash(
            caloriesConsumed: 500,
            calorieGoal: 2000,
            proteinConsumed: 20,
            proteinTarget: 100,
            carbConsumed: 50,
            carbTarget: 200,
            fatConsumed: 10,
            fatTarget: 70,
            scale: 0.7,
          ),
        );

      case 'workoutDashboard':
        return const WorkoutDashboard(scale: 0.7);


       case 'historySummary':
  return const HistorySummaryWidget();


      default:
        // Should never hit this if you've removed placeholders
        return const SizedBox.shrink();
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
      default:
        return id;
    }
  }
}
