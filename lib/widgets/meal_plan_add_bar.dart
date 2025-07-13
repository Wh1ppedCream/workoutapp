// File: lib/widgets/meal_plan_add_bar.dart

import 'package:flutter/material.dart';
import '../screens/nutrition/pantry_log_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/plan_meal_page.dart';

class MealPlanAddBar extends StatelessWidget {
  /// Scale factor for all dimensions (padding, radius, divider thickness).
  final double scale;

  const MealPlanAddBar({super.key, this.scale = 0.8});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.grey.shade400;
    final margin = EdgeInsets.symmetric(
      horizontal: 16 * scale,
      vertical: 8 * scale,
    );
    final handlePadding = EdgeInsets.symmetric(vertical: 12 * scale);
    final radius = BorderRadius.circular(24 * scale);
    final dividerThickness = 1.0 * scale;
    final segmentHeight = 40 * scale;

    return Container(
      margin: margin,
      decoration: BoxDecoration(borderRadius: radius),
      child: Row(
        children: [
          // Pantry Log (light yellow)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(24 * scale),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(24 * scale),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantryLogPage()),
                  );
                },
                child: Padding(
                  padding: handlePadding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: const Center(child: Text('Pantry Log')),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: dividerThickness,
            height: segmentHeight,
            color: dividerColor,
          ),

          // Add Meal (light green)
          Expanded(
            child: Container(
              color: Colors.green.shade100,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodLoggingPage()),
                  );
                },
                child: Padding(
                  padding: handlePadding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: const Center(child: Text('Add Meal')),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: dividerThickness,
            height: segmentHeight,
            color: dividerColor,
          ),

          // Plan Meal (light blue)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(24 * scale),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(24 * scale),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlanMealPage()),
                  );
                },
                child: Padding(
                  padding: handlePadding,
                  child: SizedBox(
                    height: segmentHeight,
                    child: const Center(child: Text('Plan Meal')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
