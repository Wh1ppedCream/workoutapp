// File: lib/widgets/nutrition_dash.dart

import 'package:flutter/material.dart';
import 'nutrition_text_details.dart';
import 'meal_plan_add_bar.dart';
import 'nutrition_circle_details.dart';
import 'nutrition_bar_details.dart';



/// A dashboard section that lets users swipe between different
/// nutrition detail views, then shows the meal plan/add bar below.
class NutritionDash extends StatefulWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

  const NutritionDash({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
  });

  @override
  State<NutritionDash> createState() => _NutritionDashState();
}

class _NutritionDashState extends State<NutritionDash> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final detailWidgets = <Widget>[
      NutritionCircleDetails(
        caloriesConsumed: widget.caloriesConsumed,
        calorieGoal: widget.calorieGoal,
        proteinConsumed: widget.proteinConsumed,
        proteinTarget: widget.proteinTarget,
        carbConsumed: widget.carbConsumed,
        carbTarget: widget.carbTarget,
        fatConsumed: widget.fatConsumed,
        fatTarget: widget.fatTarget,
      ),
      NutritionBarDetails(
  caloriesConsumed: widget.caloriesConsumed,
  calorieGoal:    widget.calorieGoal,
  proteinConsumed: widget.proteinConsumed,
  proteinTarget:   widget.proteinTarget,
  carbConsumed:    widget.carbConsumed,
  carbTarget:      widget.carbTarget,
  fatConsumed:     widget.fatConsumed,
  fatTarget:       widget.fatTarget,
),
      NutritionTextDetails(
        caloriesConsumed: widget.caloriesConsumed,
        calorieGoal: widget.calorieGoal,
        proteinConsumed: widget.proteinConsumed,
        proteinTarget: widget.proteinTarget,
        carbConsumed: widget.carbConsumed,
        carbTarget: widget.carbTarget,
        fatConsumed: widget.fatConsumed,
        fatTarget: widget.fatTarget,
      ),
       
      

    ];

    return Column(
      children: [
        // Swipeable detail section
        SizedBox(
          height: 330, // adjust as needed
          child: PageView(
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: detailWidgets,
          ),
        ),

        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(detailWidgets.length, (idx) {
            final selected = idx == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: selected ? 12 : 8,
              height: selected ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            );
          }),
        ),

        // Meal plan / Add bar
        const MealPlanAddBar(),
      ],
    );
  }
}
