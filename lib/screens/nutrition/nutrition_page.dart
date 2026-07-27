// File: lib/screens/nutrition/nutrition_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/nutrition_profile.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../widgets/nutrition_dash.dart';
import '../../widgets/health_trends_section.dart';
import '../../widgets/data_records_section.dart';
import '../../widgets/current_metrics_section.dart';
import '../../widgets/drawers.dart';
import '../profile/settings/diet_nutrition_settings_page.dart';
import 'food_logging_page.dart';
import 'log_entry_page.dart';
import 'measured_items_page.dart';
import 'new_measurement_item_page.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      drawer: _buildNutritionDrawer(strings),
      appBar: AppBar(
        title: Text(strings.nutritionDashboardTitle),
        centerTitle: true,
      ),
      body: Consumer<NutritionProfile>(
        builder: (context, p, _) {
          if (p.isLoading && p.totals == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return Center(
              child: Text(strings.nutritionDashboardError(p.error!)),
            );
          }

          final kcalGoal = (p.activeGoal?.kcalTarget ?? 0).round();
          final proGoal = (p.activeGoal?.proteinG ?? 0).round();
          final carbGoal = (p.activeGoal?.carbsG ?? 0).round();
          final fatGoal = (p.activeGoal?.fatG ?? 0).round();

          final kcal = (p.totals?.kcal ?? 0).round();
          final pro = (p.totals?.proteinG ?? 0).round();
          final carb = (p.totals?.carbsG ?? 0).round();
          final fat = (p.totals?.fatG ?? 0).round();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: NutritionDash(
                    caloriesConsumed: kcal,
                    calorieGoal: kcalGoal,
                    proteinConsumed: pro,
                    proteinTarget: proGoal,
                    carbConsumed: carb,
                    carbTarget: carbGoal,
                    fatConsumed: fat,
                    fatTarget: fatGoal,
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
            onMeasurementLogged:
                () async => p.reloadDay(), // if you show weight, etc. in dash
          );
        },
      ),
    );
  }

  MainDrawer _buildNutritionDrawer(AppLocalizations strings) {
    return MainDrawer(
      headerTitle: strings.nutritionMenuTitle,
      items: [
        DrawerItem(
          title: strings.nutritionLogFood,
          icon: Icons.restaurant,
          onTap: _openFoodLogger,
        ),
        DrawerItem(
          title: strings.nutritionTrackMeasurement,
          icon: Icons.straighten,
          onTap: _openMeasurementLogger,
        ),
        DrawerItem(
          title: strings.nutritionMeasuredItems,
          icon: Icons.monitor_weight,
          builder: (_) => const MeasuredItemsPage(),
        ),
        DrawerItem(
          title: strings.nutritionTodayRecords,
          icon: Icons.calendar_today,
          builder: (_) => LogEntryPage(date: DateTime.now()),
        ),
        DrawerItem(
          title: strings.nutritionGoalsMenu,
          icon: Icons.flag,
          builder: (_) => const DietNutritionSettingsPage(),
        ),
      ],
    );
  }

  Future<void> _openFoodLogger(BuildContext drawerContext) async {
    final navigator = Navigator.of(drawerContext);
    final profile = drawerContext.read<NutritionProfile>();
    navigator.pop();

    final changed = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
    );
    if (changed == true) {
      await profile.reloadDay();
    }
  }

  Future<void> _openMeasurementLogger(BuildContext drawerContext) async {
    final navigator = Navigator.of(drawerContext);
    final profile = drawerContext.read<NutritionProfile>();
    navigator.pop();

    final changed = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const NewMeasurementItemPage()),
    );
    if (changed == true) {
      await profile.reloadDay();
    }
  }
}
