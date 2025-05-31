
import 'package:flutter/material.dart';
import '../models.dart';
import 'dart:async';


enum CardType { weight, cardio, stretch }

class ExerciseCard extends StatefulWidget {
  final WorkoutExercise exercise;
  final CardType cardType;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final VoidCallback? onSetDeleted;
  final VoidCallback? onValueChanged;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.cardType = CardType.weight,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
  }) : super(key: key);

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}


class _ExerciseCardState extends State<ExerciseCard> {
  late String _note;
  bool _isEditingNote = false;
  final Set<int> _completedSets = {};
  
  int _cardioMinutes = 0;
Timer? _cardioTimer;
int _secondsLeft = 0;

final List<TextEditingController> _stretchControllers = [];
  

  // track whether we’re in “Make ChangeSet” mode
bool _isChangeSetMode = false;

// for each original `set` index, a list of its child ChangeSets
final Map<int, List<ExerciseSet>> _cSets = {};


  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;

  @override
  void initState() {
    super.initState();
    // Initialize note from whatever was passed in as equipment
    _note = widget.exercise.equipment;

    _weightControllers = widget.exercise.sets
        .map((s) => TextEditingController(text: s.weight.toString()))
        .toList();
    _repsControllers = widget.exercise.sets
        .map((s) => TextEditingController(text: s.reps.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _weightControllers) {
      c.dispose();
    }
    for (var c in _repsControllers) {
      c.dispose();
    }
	_cardioTimer?.cancel();
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
    child: widget.cardType == CardType.cardio
      ? _buildCardioCard()
      : widget.cardType == CardType.stretch
        ? _buildStretchCard()
        : _buildWeightCard(),  // your existing code
  ),
);

  
  
  }
  
  
  Widget _buildWeightCard() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
            // Header: Name, Equipment, Delete Exercise
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),

                    // Tappable note
                    _isEditingNote
                        ? TextFormField(
                            initialValue: _note,
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'Note',
                            ),
                            onFieldSubmitted: (val) {
                              setState(() {
                                _note = val;
                                _isEditingNote = false;
                              });
                            },
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _isEditingNote = true),
                            child: Text(
                              _note.isNotEmpty ? _note : 'Tap to add note',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                  ],
                ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (choice) async {
                    if (choice == 'remove') {
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
                      if (confirm == true) {
                        widget.onDeleteExercise?.call();
                      }
                    } else if (choice == 'changeSet') {
    setState(() {
      _isChangeSetMode = true;
    });
  }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'remove', child: Text('Remove Exercise')),
                    const PopupMenuItem(value: 'changeSet', child: Text('Make ChangeSet')),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // Set Rows
...List.generate(widget.exercise.sets.length, (index) {
  final set = widget.exercise.sets[index];
  final children = <Widget>[];

  // 3a) the original set row, but boxed if in ChangeSet mode
  children.add(
    Container(
      decoration: _isChangeSetMode
          ? BoxDecoration(border: Border.all(color: Colors.grey))
          : null,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: _completedSets.contains(index),
            onChanged: (yes) {
                        setState(() {
                          if (yes == true) {
                            _completedSets.add(index);
                          } else {
                            _completedSets.remove(index);
                          }
                        });
                      },
          ),
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
    ),
  );

  // 3b) if in ChangeSet mode, show an “Add CSet” bar under it
  if (_isChangeSetMode) {
    children.add(
      GestureDetector(
        onTap: () => setState(() {
          _cSets.putIfAbsent(index, () => []);
          _cSets[index]!.add(ExerciseSet(weight: set.weight, reps: set.reps));
        }),
        child: Container(
          margin: const EdgeInsets.only(left: 16, bottom: 4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('Add CSet'),
        ),
      ),
    );

    // 3c) render any existing ChangeSets for this original set,
    //    scaled to 80% size, indented
    final cList = _cSets[index] ?? [];
    for (var ci = 0; ci < cList.length; ci++) {
      final cset = cList[ci];
      children.add(
        Transform.scale(
          scale: 0.8,
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 32, bottom: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Row(
              children: [
                Text('CSet ${ci+1}'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: cset.weight.toString(),
                    decoration: const InputDecoration(labelText: 'Wt'),
                    onChanged: (v) => cset.weight = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: TextFormField(
                    initialValue: cset.reps.toString(),
                    decoration: const InputDecoration(labelText: 'Reps'),
                    onChanged: (v) => cset.reps = int.tryParse(v) ?? 0,
                  ),
                ),
                // you can add delete‐icon logic here if desired

                const Spacer(),  // push the button to the right
  IconButton(
    icon: const Icon(Icons.remove_circle_outline),
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove CSet'),
          content: const Text('Are you sure you want to remove this CSet?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
          ],
        ),
      );
      if (confirm == true) {
        setState(() {
          _cSets[index]!.removeAt(ci);
        });
      }
    },
  ),

              ],
            ),
          ),
        ),
      );
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
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
  );
}

Widget _buildCardioCard() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header row: name + 3-dot menu (only “Remove Cardio”)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.exercise.name, style: Theme.of(context).textTheme.titleMedium),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'remove') {
                Navigator.of(context).pop();
      widget.onDeleteExercise?.call();
                }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'remove', child: Text('Remove Cardio')),
            ],
          ),
        ],
      ),
      const SizedBox(height: 4),
      // Note (reuse your _note logic if you like)
      Text(widget.exercise.equipment, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),

      // Minutes input + GO button
      Row(
        children: [
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: '$_cardioMinutes',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutes'),
              onChanged: (v) => _cardioMinutes = int.tryParse(v) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('GO'),
            onPressed: () {
              setState(() {
                _secondsLeft = _cardioMinutes * 60;
              });
              _cardioTimer?.cancel();
              _cardioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (_secondsLeft > 0) {
                  setState(() => _secondsLeft--);
                } else {
                  _cardioTimer?.cancel();
                }
              });
            },
          ),
        ],
      ),

      // Countdown display
      // Countdown display + Start/Stop button
if (_secondsLeft > 0) ...[
  const SizedBox(height: 16),
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Time display
      Text(
        '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:'
        '${(_secondsLeft % 60).toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(width: 12),

      // Start/Stop toggle button
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: (_cardioTimer?.isActive ?? false)
              ? Colors.red
              : Colors.green,
        ),
        onPressed: () {
          // If timer is currently running, stop it
          if (_cardioTimer?.isActive ?? false) {
            _cardioTimer!.cancel();
            setState(() {});
          }
          // If timer is paused (still have seconds left), resume
          else if (_secondsLeft > 0) {
            _cardioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              if (_secondsLeft > 0) {
                setState(() => _secondsLeft--);
              } else {
                _cardioTimer?.cancel();
                setState(() {}); // ensure button disappears at 0
              }
            });
            setState(() {});
          }
        },
        child: Text(
          (_cardioTimer?.isActive ?? false) ? 'Stop' : 'Start',
        ),
      ),
    ],
  ),
],

    ],
  );
}

Widget _buildStretchCard() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Header + remove menu
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.exercise.name, style: Theme.of(context).textTheme.titleMedium),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'remove') {
                Navigator.of(context).pop();
      widget.onDeleteExercise?.call();
                }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'remove', child: Text('Remove Stretch')),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),

      // List of stretch steps (text fields)
      ..._stretchControllers.map((ctrl) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
          controller: ctrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Step',
          ),
        ),
      )),

      // “Add Step” button
      TextButton.icon(
        onPressed: () {
          setState(() => _stretchControllers.add(TextEditingController()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Step'),
      ),
    ],
  );
}

  
}

