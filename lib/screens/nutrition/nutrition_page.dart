// File: lib/screens/nutrition/nutrition_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/nutrition_profile.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../widgets/nutrition_dash.dart';
import '../../widgets/health_trends_section.dart';
import '../../widgets/data_records_section.dart';
import '../../widgets/current_metrics_section.dart';
import '../../widgets/drawers.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(title: const Text('Nutrition Dashboard'), centerTitle: true),
      body: Consumer<NutritionProfile>(
        builder: (context, p, _) {
          if (p.isLoading && p.totals == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return Center(child: Text('Error: ${p.error}'));
          }

          final kcalGoal = (p.activeGoal?.kcalTarget ?? 0).round();
          final proGoal  = (p.activeGoal?.proteinG   ?? 0).round();
          final carbGoal = (p.activeGoal?.carbsG     ?? 0).round();
          final fatGoal  = (p.activeGoal?.fatG       ?? 0).round();

          final kcal = (p.totals?.kcal     ?? 0).round();
          final pro  = (p.totals?.proteinG ?? 0).round();
          final carb = (p.totals?.carbsG   ?? 0).round();
          final fat  = (p.totals?.fatG     ?? 0).round();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: NutritionDash(
                    caloriesConsumed: kcal,
                    calorieGoal:      kcalGoal,
                    proteinConsumed:  pro,
                    proteinTarget:    proGoal,
                    carbConsumed:     carb,
                    carbTarget:       carbGoal,
                    fatConsumed:      fat,
                    fatTarget:        fatGoal,
                  ),
                ),
                const Divider(height: 25),
                const HealthTrendsSection(),
                const DataRecordsSection(),
                CurrentMetricsSection(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<NutritionProfile>(
  builder: (context, p, _) {
    return SpeedDialFab(
      onFoodLogged: () async => p.reloadDay(),
      onMeasurementLogged: () async => p.reloadDay(), // if you show weight, etc. in dash
    );
  },
),
    );
  }
}
