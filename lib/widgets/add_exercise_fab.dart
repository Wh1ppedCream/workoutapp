// File: lib/widgets/add_exercise_fab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/active_session.dart';
import '../screens/exercise_catalog_page.dart';
import '../models/models.dart';
import 'exercise_card.dart';

/// A FAB that opens a dialog to add a new exercise card (Weight, Cardio, Stretch).
class AddExerciseFab extends StatelessWidget {
  const AddExerciseFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddCardTypeDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddCardTypeDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add a Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Exercise'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseCatalogPage(
                      onExercisePicked: (def) {
                        ctx.read<ActiveSession>().addExercise(
                          WeightExercise(
                            name: def.name,
                            equipment: def.equipmentList.isNotEmpty
                                ? def.equipmentList.first.name
                                : '',
                            sets: [ExerciseSet()],
                            changeSets: {},
                          ),
                          CardType.weight,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Cardio'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showCardioDetailDialog(ctx);
              },
            ),
            ListTile(
              title: const Text('Stretch'),
              onTap: () {
                Navigator.of(ctx).pop();
                ctx.read<ActiveSession>().addExercise(
                  StretchExercise(
                    name: 'Stretch',
                    equipment: '',
                    stretchInstances: [],
                  ),
                  CardType.stretch,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  void _showCardioDetailDialog(BuildContext context) {
    String? selectedCategory;
    String? selectedExercise;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final options = (selectedCategory == 'Bodyweight')
              ? ['Aerobics','Box Jumps','Jump Squats','Running','Swimming','Walking','Zumba']
              : (selectedCategory == 'Equipment Based')
                  ? ['Battle Ropes','Bicycle','Elliptical','Rowing Machine','Ski Machine','Skipping Rope','Stair Climber','Stationary Bike','Treadmill','Vertical Climber']
                  : <String>[];

          return AlertDialog(
            title: const Text('Choose Cardio Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Bodyweight'),
                        value: 'Bodyweight',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Equipment Based'),
                        value: 'Equipment Based',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedCategory != null) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Exercise'),
                    value: selectedExercise,
                    items: options.map((ex) => DropdownMenuItem(value: ex, child: Text(ex))).toList(),
                    onChanged: (v) => setDialogState(() => selectedExercise = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedExercise == null)
                    ? null
                    : () {
                        Navigator.of(dialogCtx).pop();
                        context.read<ActiveSession>().addExercise(
                          CardioExercise(
                            name: selectedExercise!,
                            equipment: '',
                            cardioName: selectedExercise!,
                            cardioNote: null,
                            plannedMinutes: 0,
                            elapsedSeconds: 0,
                          ),
                          CardType.cardio,
                        );
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
