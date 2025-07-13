// File: lib/widgets/nutrition_circle_details.dart

import 'package:flutter/material.dart';
import 'rounded_progress_indicator.dart';

/// Shows calories and macros in ring charts that can scale via [scale].
class NutritionCircleDetails extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

  /// Uniform scale factor for all sizes, paddings, and fonts.
  final double scale;

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
    this.scale = 1.0,   // default to 1.0 to keep original sizing
  });

  Widget _buildDonut(
    BuildContext context,
    String label,
    int consumed,
    int target,
    double baseSize,
    Color color,
  ) {
    final pct = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final textStyle = Theme.of(context)
        .textTheme
        .bodySmall!
        .copyWith(color: color, fontSize: 12 * scale);

    return Stack(
      alignment: Alignment.center,
      children: [
        RoundedProgressIndicator(
          progress: pct,
          size: baseSize * scale,
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
          strokeWidth: (baseSize * 0.12) * scale,
          scale: 1.0, // strokewidth is already scaled above
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$consumed / $target', style: textStyle),
            SizedBox(height: 2 * scale),
            Text(label, style: textStyle),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final kcalColor   = Colors.green.shade600;
    final proteinColor= Theme.of(context).colorScheme.primary;
    final carbColor   = Colors.blue.shade600;
    final fatColor    = Colors.orange.shade600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * scale),
      child: Column(
        children: [
          // Large calorie ring
          _buildDonut(
            context,
            'Calories',
            caloriesConsumed,
            calorieGoal,
            180,                // base size
            kcalColor,
          ),

          SizedBox(height: 10 * scale),

          // Three smaller rings for macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDonut(
                context,
                'Protein',
                proteinConsumed,
                proteinTarget,
                100,           // base size
                proteinColor,
              ),
              _buildDonut(
                context,
                'Carbs',
                carbConsumed,
                carbTarget,
                100,
                carbColor,
              ),
              _buildDonut(
                context,
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
