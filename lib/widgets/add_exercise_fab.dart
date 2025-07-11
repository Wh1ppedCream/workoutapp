// File: lib/widgets/add_exercise_fab.dart

import 'package:flutter/material.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../models/models.dart';

/// Callback when a weight exercise definition is picked.
typedef WeightPicker = Future<void> Function(ExerciseDefinition definition);
/// Callback when a cardio exercise name is picked.
typedef CardioPicker = Future<void> Function(String cardioName);
/// Callback when a stretch exercise is picked.
typedef StretchPicker = Future<void> Function();

/// A FAB that opens a dialog to add a new exercise card (Weight, Cardio, Stretch).
///
/// Accepts callbacks to handle each choice, so it can be used for sessions or presets.
class AddExerciseFab extends StatelessWidget {
  final WeightPicker? onWeightPicked;
  final CardioPicker? onCardioPicked;
  final StretchPicker? onStretchPicked;

  /// Creates an AddExerciseFab.
  ///
  /// Provide any combination of [onWeightPicked], [onCardioPicked], [onStretchPicked]
  /// to handle the respective selection.
  const AddExerciseFab({
    super.key,
    this.onWeightPicked,
    this.onCardioPicked,
    this.onStretchPicked,
  });

  // Cardio options for bodyweight vs. equipment-based activities.
  // TODO: put in database and put these in json files
  static const List<String> _bodyweightCardioOptions = [
    'Aerobics', 'Box Jumps', 'Jump Squats', 'Running', 'Swimming', 'Walking', 'Zumba',
  ];
  static const List<String> _equipmentCardioOptions = [
    'Battle Ropes', 'Bicycle', 'Elliptical', 'Rowing Machine',
    'Ski Machine', 'Skipping Rope', 'Stair Climber',
    'Stationary Bike', 'Treadmill', 'Vertical Climber',
  ];

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
                      onExercisePicked: (def) async {
                        if (onWeightPicked != null) {
                          await onWeightPicked!(def);
                        }
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
                if (onStretchPicked != null) onStretchPicked!();
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

  void _showCardioDetailDialog(BuildContext dialogCtx) {
    String? selectedCategory;
    String? selectedExercise;

    showDialog(
      context: dialogCtx,
      builder: (innerCtx) => StatefulBuilder(
        builder: (innerCtx, setState) {
          final options = (selectedCategory == 'Bodyweight')
              ? _bodyweightCardioOptions
              : (selectedCategory == 'Equipment Based')
                  ? _equipmentCardioOptions
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
                          setState(() {
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
                          setState(() {
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
                    items: options
                        .map((ex) => DropdownMenuItem(value: ex, child: Text(ex)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedExercise = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(innerCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedExercise == null)
                    ? null
                    : () async {
                        Navigator.of(innerCtx).pop();
                        if (onCardioPicked != null) {
                          await onCardioPicked!(selectedExercise!);
                        }
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
