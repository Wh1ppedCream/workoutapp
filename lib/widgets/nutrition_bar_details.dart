// File: lib/widgets/nutrition_bar_details.dart

import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Shows calories as a thick horizontal bar (with consumed / target / remaining inside),
/// and protein, carbs, fat as three vertical bars (remaining at top, consumed at bottom).
class NutritionBarDetails extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

  /// Uniform scale factor for all dimensions.
  final double scale;

  const NutritionBarDetails({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    this.scale = 1.0, // default to 1.0 for existing sizes
  });

  @override
  Widget build(BuildContext context) {
    final remainingCalories = calorieGoal - caloriesConsumed;
    final pctCal =
        calorieGoal > 0
            ? (caloriesConsumed / calorieGoal).clamp(0.0, 1.0)
            : 0.0;
    final pctProtein =
        proteinTarget > 0
            ? (proteinConsumed / proteinTarget).clamp(0.0, 1.0)
            : 0.0;
    final pctCarb =
        carbTarget > 0 ? (carbConsumed / carbTarget).clamp(0.0, 1.0) : 0.0;
    final pctFat =
        fatTarget > 0 ? (fatConsumed / fatTarget).clamp(0.0, 1.0) : 0.0;

    // pull in AppColors & ColorScheme
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * scale),
      child: Column(
        children: [
          // ─── Horizontal calories bar ─────────────────────────
          _buildHorizontalBar(
            context: context,
            consumed: caloriesConsumed,
            target: calorieGoal,
            remaining: remainingCalories,
            factor: pctCal,
            height: 80 * scale,
            color: colors.nutritionCalorieBar!,
          ),

          SizedBox(height: 24 * scale),

          // ─── Vertical macro bars ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVerticalBar(
                context: context,
                label: 'Protein',
                consumed: proteinConsumed,
                target: proteinTarget,
                factor: pctProtein,
                height: 140 * scale,
                width: 50 * scale,
                color: colors.nutritionProteinBar!,
              ),
              _buildVerticalBar(
                context: context,
                label: 'Carbs',
                consumed: carbConsumed,
                target: carbTarget,
                factor: pctCarb,
                height: 140 * scale,
                width: 50 * scale,
                color: colors.nutritionCarbBar!,
              ),
              _buildVerticalBar(
                context: context,
                label: 'Fat',
                consumed: fatConsumed,
                target: fatTarget,
                factor: pctFat,
                height: 140 * scale,
                width: 50 * scale,
                color: colors.nutritionFatBar!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar({
    required BuildContext context,
    required int consumed,
    required int target,
    required int remaining,
    required double factor,
    required double height,
    required Color color,
  }) {
    // light version for unfilled track
    final trackColor = color.withValues(alpha: 0.3);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final fullWidth = constraints.maxWidth;
        final filledWidth = fullWidth * factor;

        return Stack(
          alignment: Alignment.center,
          children: [
            // track
            Container(
              width: fullWidth,
              height: height,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // filled portion aligned to left
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: filledWidth,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),

            // texts
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Row(
                children: [
                  // consumed on left
                  Text(
                    '$consumed',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                  ),
                  const Spacer(),
                  // target in center
                  Text(
                    '$target kcal',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                  ),
                  const Spacer(),
                  // remaining on right
                  Text(
                    '$remaining',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalBar({
    required BuildContext context,
    required String label,
    required int consumed,
    required int target,
    required double factor,
    required double height,
    required double width,
    required Color color,
  }) {
    final trackColor = color.withValues(alpha: 0.3);
    final remaining = target - consumed;

    return Column(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // track
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(width / 2),
                ),
              ),

              // filled portion from bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: width,
                  height: height * factor,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(width / 2),
                      top: Radius.circular(factor == 1.0 ? width / 2 : 0),
                    ),
                  ),
                ),
              ),

              // remaining at top
              Positioned(
                top: 4 * scale,
                child: Text(
                  '$remaining',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 12 * scale,
                  ),
                ),
              ),

              // consumed at bottom
              Positioned(
                bottom: 4 * scale,
                child: Text(
                  '$consumed',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 12 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4 * scale),

        // label below bar
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: color, fontSize: 12 * scale),
        ),
      ],
    );
  }
}
