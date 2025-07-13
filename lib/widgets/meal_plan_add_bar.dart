// File: lib/widgets/meal_plan_add_bar.dart

import 'package:flutter/material.dart';
import '../screens/nutrition/pantry_log_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/plan_meal_page.dart';

class MealPlanAddBar extends StatelessWidget {
  const MealPlanAddBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Pantry Log (light yellow)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(24)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PantryLogPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Pantry Log')),
                ),
              ),
            ),
          ),

          // Divider
          Container(width: 1, height: 40, color: dividerColor),

          // Add Meal (light green)
          Expanded(
            child: Container(
              color: Colors.green.shade100,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const FoodLoggingPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Add Meal')),
                ),
              ),
            ),
          ),

          // Divider
          Container(width: 1, height: 40, color: dividerColor),

          // Plan Meal (light blue)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(24),
                ),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(24)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PlanMealPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Plan Meal')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
