// File: lib/widgets/meal_plan_add_bar.dart

import 'package:flutter/material.dart';

import '../screens/nutrition/pantry_log_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/plan_meal_page.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_segmented_action_bar.dart';

class MealPlanAddBar extends StatelessWidget {
  /// Scale factor for all dimensions (padding, radius, divider thickness).
  final double scale;

  const MealPlanAddBar({super.key, this.scale = 0.8});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.nutritionTokens;
    final labelStyle = Theme.of(context).textTheme.bodyMedium;

    return TonosSegmentedActionBar(
      scale: scale,
      dividerColor: context.surfaceTokens.divider,
      items: [
        TonosActionBarItem(
          label: 'Pantry Log',
          semanticLabel: 'Pantry Log',
          backgroundColor: nutrition.pantryLogSurface,
          foregroundColor: tonosForegroundForSurface(
            context,
            nutrition.pantryLogSurface,
          ),
          labelStyle: labelStyle,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PantryLogPage()));
          },
        ),
        TonosActionBarItem(
          label: 'Add Meal',
          semanticLabel: 'Add Meal',
          backgroundColor: nutrition.addMealSurface,
          foregroundColor: tonosForegroundForSurface(
            context,
            nutrition.addMealSurface,
          ),
          labelStyle: labelStyle,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FoodLoggingPage()));
          },
        ),
        TonosActionBarItem(
          label: 'Plan Meal',
          semanticLabel: 'Plan Meal',
          backgroundColor: nutrition.planMealSurface,
          foregroundColor: tonosForegroundForSurface(
            context,
            nutrition.planMealSurface,
          ),
          labelStyle: labelStyle,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PlanMealPage()));
          },
        ),
      ],
    );
  }
}
