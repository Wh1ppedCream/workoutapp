// File: lib/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import '../models.dart';

typedef VoidCallback = void Function();

typedef ValueChangedCallback = void Function();

class ExerciseCard extends StatefulWidget {
  final WorkoutExercise exercise;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final ValueChangedCallback? onSetDeleted;
  final ValueChangedCallback? onValueChanged;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
  }) : super(key: key);

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name, Equipment, Delete Exercise
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Equipment: ${widget.exercise.equipment}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (widget.onDeleteExercise != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Exercise'),
                          content: const Text('Are you sure you want to remove this exercise?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        widget.onDeleteExercise!();
                      }
                    },
                  ),
              ],
            ),
            const Divider(height: 16),

            // Set Rows
            ...List.generate(widget.exercise.sets.length, (index) {
              final set = widget.exercise.sets[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Label: Set 1, Set 2, ...
                    Text('Set ${index + 1}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 16),

                    // Weight Field
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: set.weight.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight'),
                        onChanged: (val) {
                          final w = double.tryParse(val) ?? 0;
                          setState(() {
                            set.weight = w;
                          });
                          widget.onValueChanged?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Reps Field
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: set.reps.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps'),
                        onChanged: (val) {
                          final r = int.tryParse(val) ?? 0;
                          setState(() {
                            set.reps = r;
                          });
                          widget.onValueChanged?.call();
                        },
                      ),
                    ),

                    // Delete Set Icon
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove Set'),
                            content: const Text('Are you sure you want to remove this set?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            widget.exercise.sets.removeAt(index);
                          });
                          widget.onSetDeleted?.call();
                        }
                      },
                    ),
                  ],
                ),
              );
            }),

            // Add Set Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    final last = widget.exercise.sets.last;
                    widget.exercise.sets.add(
                      ExerciseSet(weight: last.weight, reps: last.reps),
                    );
                  });
                  widget.onSetAdded?.call();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
