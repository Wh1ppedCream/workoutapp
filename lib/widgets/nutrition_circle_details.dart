import 'package:flutter/material.dart';
import 'rounded_progress_indicator.dart';

class NutritionCircleDetails extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

  const NutritionCircleDetails({
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

  Widget _buildDonut(
    BuildContext context,  // ← add context
    String label,
    int consumed,
    int target,
    double size,
    Color color,
  ) {
    final pct = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        RoundedProgressIndicator(
          progress: pct,
          size: size,
          strokeWidth: size * 0.12,
          backgroundColor: color.withValues(alpha: 0.2),
          progressColor: color,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$consumed / $target',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Choose colors (or pull from theme)
    final kcalColor = Colors.green.shade600; 
    final proteinColor = Theme.of(context).colorScheme.primary;
    final carbColor = Colors.blue.shade600;
    final fatColor = Colors.orange.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Large calorie donut
          _buildDonut(context, 'Calories', caloriesConsumed, calorieGoal, 180, kcalColor),

          const SizedBox(height: 10),

          // Three smaller macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDonut(context, 'Protein', proteinConsumed, proteinTarget, 100, proteinColor),
              
              _buildDonut(context, 
                'Carbs',
                carbConsumed,
                carbTarget,
                100,
                carbColor,
              ),
              _buildDonut(context, 
                'Fat',
                fatConsumed,
                fatTarget,
                100,
                fatColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
