import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/nutrition_profile.dart';
import '../../../widgets/settings_tiles.dart';
import 'goal_manual_entry_page.dart';

class DietNutritionSettingsPage extends StatelessWidget {
  const DietNutritionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<NutritionProfile>();
    final goal = profile.activeGoal;

    return SettingsPageScaffold(
      title: 'Diet & Nutrition Settings',
      subtitle: 'Configure nutrition targets and food-related preferences.',
      icon: Icons.restaurant_menu,
      children: [
        if (goal != null) ...[
          SettingsInfoCard(
            icon: Icons.flag_outlined,
            title: 'Current Goals',
            body: _formatGoalSummary(goal),
          ),
          const SizedBox(height: 16),
        ],
        SettingsSection(
          title: 'Goals',
          subtitle: 'Set the targets used by nutrition tracking.',
          children: [
            SettingsActionTile(
              icon: Icons.edit_note,
              title: 'Manually Set Nutrition Goals',
              subtitle: 'Enter calories, macros, and key nutrients yourself.',
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalManualEntryPage()),
                );
                if (changed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goals saved')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatGoalSummary(dynamic goal) {
    String number(double? value, {String unit = ''}) {
      if (value == null) return '-';
      return '${value.toStringAsFixed(0)}$unit';
    }

    return [
      'Calories: ${number(goal.kcalTarget, unit: ' kcal')}',
      'Protein: ${number(goal.proteinG, unit: ' g')}',
      'Carbs: ${number(goal.carbsG, unit: ' g')}',
      'Fat: ${number(goal.fatG, unit: ' g')}',
      'Fiber: ${number(goal.fiberG, unit: ' g')}',
      'Sugar: ${number(goal.sugarG, unit: ' g')}',
      'Sat. Fat: ${number(goal.satFatG, unit: ' g')}',
      'Sodium: ${goal.sodiumMg == null ? '-' : '${goal.sodiumMg!.round()} mg'}',
    ].join(' / ');
  }
}
