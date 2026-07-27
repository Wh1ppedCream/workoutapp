import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/nutrition_profile.dart';
import '../../../widgets/settings_tiles.dart';
import 'goal_manual_entry_page.dart';

class DietNutritionSettingsPage extends StatelessWidget {
  const DietNutritionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<NutritionProfile>();
    final goal = profile.activeGoal;
    final strings = AppLocalizations.of(context);

    return SettingsPageScaffold(
      title: strings.nutritionSettingsTitle,
      subtitle: strings.nutritionSettingsSubtitle,
      icon: Icons.restaurant_menu,
      children: [
        if (goal != null) ...[
          SettingsInfoCard(
            icon: Icons.flag_outlined,
            title: strings.nutritionCurrentGoals,
            body: _formatGoalSummary(strings, goal),
          ),
          const SizedBox(height: 16),
        ],
        SettingsSection(
          title: strings.nutritionGoals,
          subtitle: strings.nutritionGoalsSubtitle,
          children: [
            SettingsActionTile(
              icon: Icons.edit_note,
              title: strings.nutritionManualGoals,
              subtitle: strings.nutritionManualGoalsSubtitle,
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GoalManualEntryPage(),
                  ),
                );
                if (changed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.nutritionGoalsSaved)),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatGoalSummary(AppLocalizations strings, dynamic goal) {
    String number(double? value, {String unit = ''}) {
      if (value == null) return '-';
      return '${value.toStringAsFixed(0)}$unit';
    }

    return strings.nutritionGoalSummary(
      number(goal.kcalTarget, unit: ' kcal'),
      number(goal.proteinG, unit: ' g'),
      number(goal.carbsG, unit: ' g'),
      number(goal.fatG, unit: ' g'),
      number(goal.fiberG, unit: ' g'),
      number(goal.sugarG, unit: ' g'),
      number(goal.satFatG, unit: ' g'),
      goal.sodiumMg == null ? '-' : '${goal.sodiumMg!.round()} mg',
    );
  }
}
