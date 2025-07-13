// File: lib/widgets/nutrition_text_details.dart

import 'package:flutter/material.dart';

/// Shows calorie stats (Remaining, Consumed, Target)
/// and macro stats (Protein, Carbs, Fat) in two rows of ValueCards.
class NutritionTextDetails extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;

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
  });

  @override
  Widget build(BuildContext context) {
    // compute remaining calories
    final remaining = calorieGoal - caloriesConsumed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ValueCard(
                    label: 'Remaining',
                    value: '$remaining kcal',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueCard(
                    label: 'Consumed',
                    value: '$caloriesConsumed kcal',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueCard(
                    label: 'Target',
                    value: '$calorieGoal kcal',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Macro summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ValueCard(
                    label: 'Protein',
                    value: '$proteinConsumed / $proteinTarget g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueCard(
                    label: 'Carbs',
                    value: '$carbConsumed / $carbTarget g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueCard(
                    label: 'Fat',
                    value: '$fatConsumed / $fatTarget g',
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

/// A generic card that shows a label and a single line of text.
/// Use it for stats (e.g. “Remaining: 800 kcal”) or macros (e.g. “80 / 100 g”).
class ValueCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? borderColor;

  const ValueCard({
    super.key,
    required this.label,
    required this.value,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderClr = borderColor ?? Colors.grey[300]!;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: borderClr),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
