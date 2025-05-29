import 'package:flutter/material.dart';
import '../models.dart';

class ExerciseCard extends StatefulWidget {
  final WorkoutExercise exercise;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final VoidCallback? onSetDeleted;
  final VoidCallback? onValueChanged;

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
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;

  @override
  void initState() {
    super.initState();
    _weightControllers = widget.exercise.sets
        .map((s) => TextEditingController(text: s.weight.toString()))
        .toList();
    _repsControllers = widget.exercise.sets
        .map((s) => TextEditingController(text: s.reps.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _weightControllers) c.dispose();
    for (var c in _repsControllers) c.dispose();
    super.dispose();
  }

  void _updateSetFromControllers(int index) {
    final w = double.tryParse(_weightControllers[index].text) ?? 0;
    final r = int.tryParse(_repsControllers[index].text) ?? 0;
    setState(() {
      widget.exercise.sets[index].weight = w;
      widget.exercise.sets[index].reps = r;
    });
    widget.onValueChanged?.call();
  }

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
                          content: const Text(
                              'Are you sure you want to remove this exercise?'),
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
                      if (confirm == true) widget.onDeleteExercise!();
                    },
                  ),
              ],
            ),
            const Divider(height: 16),

            // Set Rows
            ...List.generate(widget.exercise.sets.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Set ${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _weightControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight'),
                        onChanged: (_) => _updateSetFromControllers(index),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _repsControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps'),
                        onChanged: (_) => _updateSetFromControllers(index),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove Set'),
                            content: const Text(
                                'Are you sure you want to remove this set?'),
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
                            _weightControllers.removeAt(index).dispose();
                            _repsControllers.removeAt(index).dispose();
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
                    final last = widget.exercise.sets.isNotEmpty
                        ? widget.exercise.sets.last
                        : ExerciseSet();
                    widget.exercise.sets.add(
                      ExerciseSet(weight: last.weight, reps: last.reps),
                    );
                    _weightControllers.add(
                        TextEditingController(text: last.weight.toString()));
                    _repsControllers.add(
                        TextEditingController(text: last.reps.toString()));
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
