import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/nutrition_profile.dart';
import 'goal_manual_entry_page.dart';

class DietNutritionSettingsPage extends StatelessWidget {
  const DietNutritionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NutritionProfile>();
    final goal = p.activeGoal;

    return Scaffold(
      appBar: AppBar(title: const Text('Diet & Nutrition Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current goal summary (if any)
          if (goal != null)
            Card(
              child: ListTile(
                title: const Text('Current Goals'),
                subtitle: Text(_formatGoalSummary(goal)),
              ),
            ),

          const SizedBox(height: 12),

          // Manual goals option
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Manually Set Nutrition Goals'),
              subtitle: const Text('Enter calories & macros yourself'),
              trailing: const Icon(Icons.chevron_right),
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
          ),
        ],
      ),
    );
  }

  String _formatGoalSummary(goal) {
    String n(double? v, {String unit = ''}) =>
        v == null ? '—' : '${v.toStringAsFixed(unit.isEmpty ? 0 : 0)}$unit';

    return [
      'Calories: ${n(goal.kcalTarget, unit: ' kcal')}',
      'Protein:  ${n(goal.proteinG,  unit: ' g')}',
      'Carbs:    ${n(goal.carbsG,    unit: ' g')}',
      'Fat:      ${n(goal.fatG,      unit: ' g')}',
      'Fiber:    ${n(goal.fiberG,    unit: ' g')}',
      'Sugar:    ${n(goal.sugarG,    unit: ' g')}',
      'Sat. Fat: ${n(goal.satFatG,   unit: ' g')}',
      'Sodium:   ${goal.sodiumMg == null ? '—' : '${goal.sodiumMg!.round()} mg'}',
    ].join(' • ');
  }
}
