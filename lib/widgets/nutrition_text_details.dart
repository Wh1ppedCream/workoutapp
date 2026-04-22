// File: lib/widgets/nutrition_text_details.dart

import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

/// Shows calorie stats (Remaining, Consumed, Target)
/// and macro stats (Protein, Carbs, Fat) in two rows of ValueCards,
/// with an optional [scale] factor to adjust sizing.
class NutritionTextDetails extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

  /// Uniform scale factor for paddings, spacings, and card sizing.
  final double scale;

  const NutritionTextDetails({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = calorieGoal - caloriesConsumed;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie summary row
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            child: Row(
              children: [
                Expanded(
                  child: ValueCard(
                    label: 'Remaining',
                    value: '$remaining kcal',
                    scale: scale,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: ValueCard(
                    label: 'Consumed',
                    value: '$caloriesConsumed kcal',
                    scale: scale,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: ValueCard(
                    label: 'Target',
                    value: '$calorieGoal kcal',
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16 * scale),

          // Macro summary row
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            child: Row(
              children: [
                Expanded(
                  child: ValueCard(
                    label: 'Protein',
                    value: '$proteinConsumed / $proteinTarget g',
                    scale: scale,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: ValueCard(
                    label: 'Carbs',
                    value: '$carbConsumed / $carbTarget g',
                    scale: scale,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: ValueCard(
                    label: 'Fat',
                    value: '$fatConsumed / $fatTarget g',
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A generic card that shows a [label] and a [value], with optional [scale]
/// to adjust padding, border radius, and font sizes.
class ValueCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? borderColor;

  /// Uniform scale factor for padding, border radius, spacing, and fonts.
  final double scale;

  const ValueCard({
    super.key,
    required this.label,
    required this.value,
    this.borderColor,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // pull your themed border color if no override was passed
    final colors    = context.colors;
    final borderClr = borderColor ?? colors.nutritionTextDetailsBorder!;

    // base text styles
    final theme = Theme.of(context);
    final labelStyleBase = theme.textTheme.bodySmall!;
    final valueStyleBase = theme.textTheme.titleMedium!;

    // scaled text styles
    final labelStyle = labelStyleBase.copyWith(
      fontSize: (labelStyleBase.fontSize ?? 14) * scale,
    );
    final valueStyle = valueStyleBase.copyWith(
      fontSize: (valueStyleBase.fontSize ?? 18) * scale,
    );

    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        border: Border.all(color: borderClr),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          SizedBox(height: 4 * scale),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
