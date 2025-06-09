// File: lib/widgets/exercise_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../db/database_helper.dart';

enum CardType { weight, cardio, stretch }

class ExerciseCard extends StatefulWidget {
  final WorkoutExercise exercise;
  final CardType cardType;

  final bool         readOnlyMode;               // NEW: if true, disable UI inputs
  final Set<int>?    initialCompletedParents;    // NEW
  final Map<int, Set<int>>? initialCompletedChildren; // NEW

  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final VoidCallback? onSetDeleted;
  final VoidCallback? onValueChanged;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.cardType = CardType.weight,
    this.readOnlyMode = false,
    this.initialCompletedParents,
    this.initialCompletedChildren,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
  }) : super(key: key);

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  // ------ Common fields ------
  late String _note;
  bool _isEditingNote = false;

  // ------ Weight‐specific fields ------
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;
  bool _isChangeSetMode = false;
  final Map<int, List<ExerciseSet>> _cSets = {};
  final Set<int> _completedSets = {};

  // ------ Cardio‐specific fields ------
  int _cardioMinutes = 0;
  Timer? _cardioTimer;
  int _secondsLeft = 0;
  late TextEditingController _cardioNameController;

  // ------ Stretch‐specific fields ------
  late TextEditingController _stretchCustomController;
  final Set<int> _completedStretches = {};

@override
void initState() {
  super.initState();

  // 1) Always seed the note from the model
  _note = widget.exercise.equipment;

  // 2) CARDIO
  if (widget.cardType == CardType.cardio) {
    if (widget.exercise is CardioExercise) {
      final ce = widget.exercise as CardioExercise;
      _cardioMinutes = ce.plannedMinutes;
      _secondsLeft    = ce.elapsedSeconds;
      _cardioNameController =
          TextEditingController(text: ce.cardioName);
    } else {
      // fallback
      _cardioMinutes = 0;
      _secondsLeft   = 0;
      _cardioNameController =
          TextEditingController(text: widget.exercise.name);
    }
  }

  // 3) WEIGHT
  if (widget.cardType == CardType.weight) {
    // a) pull the sets list to initialize controllers
    final sets = widget.exercise is WeightExercise
        ? (widget.exercise as WeightExercise).sets
        : <ExerciseSet>[];
    _weightControllers = sets
        .map((s) => TextEditingController(text: s.weight.toString()))
        .toList();
    _repsControllers   = sets
        .map((s) => TextEditingController(text: s.reps.toString()))
        .toList();

    // b) if we're in read-only mode, seed the completed‐sets
    if (widget.readOnlyMode && widget.initialCompletedParents != null) {
      _completedSets.addAll(widget.initialCompletedParents!);
    }

    // c) if read-only, also seed any existing ChangeSets so they show up
    if (widget.readOnlyMode && widget.exercise is WeightExercise) {
  final we = widget.exercise as WeightExercise;
  _cSets.clear();
  we.changeSets.forEach((parentIdx, children) {
    // make a copy so you don't accidentally share the same list
    _cSets[parentIdx] = List<ExerciseSet>.from(children);
  });
}
  }

  // 1) Seed _cSets from the model:
  if (widget.exercise is WeightExercise) {
    final we = widget.exercise as WeightExercise;
    _cSets.clear();
    we.changeSets.forEach((parentIdx, children) {
      _cSets[parentIdx] = List<ExerciseSet>.from(children);
    });

    // 2) If we’re in read-only mode and there _were_ changeSets saved,
    //    we want to show them boxed:
    if (widget.readOnlyMode && we.changeSets.isNotEmpty) {
      _isChangeSetMode = true;
    }
  }



  // 4) STRETCH
  if (widget.cardType == CardType.stretch) {
    _stretchCustomController = TextEditingController();
  // Pull the existing stretchInstances from the model
  // (Every WorkoutExercise now has a stretchInstances list by default.)
  // Pull the existing stretchInstances from the model
    // (Every WorkoutExercise now has a stretchInstances list by default.)
    if (widget.exercise is StretchExercise) {
      final stretchEx = widget.exercise as StretchExercise;
      for (var i = 0; i < stretchEx.stretchInstances.length; i++) {
        final inst = stretchEx.stretchInstances[i];
        // If it was already checked in the model, mark its index
        if (inst['is_checked'] == true) {
          _completedStretches.add(i);
        }
      }
    }
  }
}



  @override
  void dispose() {
    if (widget.cardType == CardType.weight) {
      for (var c in _weightControllers) {
        c.dispose();
      }
      for (var c in _repsControllers) {
        c.dispose();
      }
    }
    if (widget.cardType == CardType.cardio) {
      _cardioTimer?.cancel();
      _cardioNameController.dispose();
    }
    if (widget.cardType == CardType.stretch) {
      _stretchCustomController.dispose();
    }
    super.dispose();
  }

  void _updateWeightSet(int index) {
    final w = double.tryParse(_weightControllers[index].text) ?? 0;
    final r = int.tryParse(_repsControllers[index].text) ?? 0;
    if (widget.exercise is WeightExercise) {
      final we = widget.exercise as WeightExercise;
      // replace the old set with a freshly-configured one
      we.sets[index] = ExerciseSet(weight: w, reps: r);
    }
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
                : _buildWeightCard(),
      ),
    );
  }

  // -------------------- Weight Card --------------------

  Widget _buildWeightCard() {
    final readOnly = widget.readOnlyMode;
    final we = widget.exercise as WeightExercise;
  final sets = we.sets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Name, Note, Options
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
                  _isEditingNote
                      ? TextFormField(
                        readOnly: readOnly,
                          initialValue: _note,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Note',
                          ),
                          onFieldSubmitted: readOnly ? null : (val) {
                            setState(() {
                              _note = val.trim();
                              _isEditingNote = false;
                              // We do not assign to widget.exercise.equipment here
                            });
                            widget.onValueChanged?.call();
                          },
                        )
                      : (!readOnly)
  ? GestureDetector(
                          onTap: () => setState(() => _isEditingNote = true),
                          child: Text(
                            _note.isNotEmpty ? _note : 'Tap to add note',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ): Text(
                            _note.isNotEmpty ? _note : 'Tap to add note',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: !readOnly,
              icon: const Icon(Icons.more_vert),
              onSelected: (choice) async {
                if (choice == 'remove') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove Exercise'),
                      content: const Text('Are you sure you want to remove this exercise?'),
                      actions: [
                        TextButton(
                          onPressed: readOnly ? null
                          : () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: readOnly ? null
                          : () => Navigator.of(ctx).pop(true),
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
                    _isChangeSetMode = !_isChangeSetMode;
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

        // List each set
        ...List.generate(sets.length, (index) {
          final set = sets[index];
          final children = <Widget>[];

          // Original set row
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
                    onChanged: readOnly
      ? null
                    : (yes) {
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
                      readOnly: readOnly,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      onChanged: readOnly
        ? null
        : (_) => _updateWeightSet(index),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _repsControllers[index],
                      readOnly: readOnly,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      onChanged: readOnly
        ? null
        : (_) => _updateWeightSet(index),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: readOnly ? null
                    : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Set'),
                          content: const Text('Are you sure you want to remove this set?'),
                          actions: [
                            TextButton(
                              onPressed: readOnly ? null
                              : () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: readOnly ? null
                              : () => Navigator.of(ctx).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() {
                          sets.removeAt(index);
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

          
// Boxed C-Sets
        if (_isChangeSetMode || (readOnly && we.changeSets.isNotEmpty)) {
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
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Row(
                    children: [
                      Text('CSet ${ci + 1}'),
                      const SizedBox(width: 8),

                      // Weight field
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          readOnly: readOnly,
                          keyboardType: TextInputType.number,
                          initialValue: cset.weight.toString(),
                          decoration: const InputDecoration(labelText: 'Wt'),
                          onChanged: readOnly
                              ? null
                              : (v) {
                                  cset.weight =
                                      double.tryParse(v) ?? cset.weight;
                                  we.changeSets[index] =
                                      List.from(_cSets[index]!);
                                  widget.onValueChanged?.call();
                                },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reps field
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          readOnly: readOnly,
                          keyboardType: TextInputType.number,
                          initialValue: cset.reps.toString(),
                          decoration: const InputDecoration(labelText: 'Reps'),
                          onChanged: readOnly
                              ? null
                              : (v) {
                                  cset.reps =
                                      int.tryParse(v) ?? cset.reps;
                                  we.changeSets[index] =
                                      List.from(_cSets[index]!);
                                  widget.onValueChanged?.call();
                                },
                        ),
                      ),

                      // Remove CSet confirmation (edit-only)
                      if (!readOnly) ...[
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Remove CSet'),
                                content: const Text(
                                  'Are you sure you want to remove this CSet?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              setState(() {
                                _cSets[index]!.removeAt(ci);
                                we.changeSets[index] =
                                    List.from(_cSets[index]!);
                              });
                              widget.onValueChanged?.call();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        }

        // Add C-Set button (edit-only)
        if (!readOnly && _isChangeSetMode) {
          children.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  _cSets.putIfAbsent(index, () => []);
                  _cSets[index]!.add(
                    ExerciseSet(weight: set.weight, reps: set.reps),
                  );
                  we.changeSets[index] = List.from(_cSets[index]!);
                });
                widget.onValueChanged?.call();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, bottom: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Add CSet'),
              ),
            ),
          );
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
          onPressed: readOnly
              ? null
              : () {
                  setState(() {
                    final last = sets.isNotEmpty
                        ? sets.last
                        : ExerciseSet();
                    sets.add(
                      ExerciseSet(weight: last.weight, reps: last.reps),
                    );
                    _weightControllers.add(
                      TextEditingController(text: last.weight.toString()),
                    );
                    _repsControllers.add(
                      TextEditingController(text: last.reps.toString()),
                    );
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

  // -------------------- Cardio Card --------------------

  Widget _buildCardioCard() {
    final readOnly = widget.readOnlyMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Cardio Name + Remove menu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.exercise.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            PopupMenuButton<String>(
              enabled: !readOnly,
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'remove') {
                  widget.onDeleteExercise?.call();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'remove', child: Text('Remove Cardio')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Tappable note under name
        _isEditingNote
            ? TextFormField(
              readOnly: readOnly,
                initialValue: _note,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Note',
                ),
                 onFieldSubmitted: readOnly ? null : (val) {
                  setState(() {
                    _note = val.trim();
                    _isEditingNote = false;
                    // Do not assign to final model
                  });
                  widget.onValueChanged?.call();
                },
              )
            : (!readOnly)
  ? GestureDetector(
                onTap: () => setState(() => _isEditingNote = true),
                child: Text(
                  _note.isNotEmpty ? _note : 'Tap to add note',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ): Text(
                  _note.isNotEmpty ? _note : 'Tap to add note',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                ),
        const SizedBox(height: 16),

        // Minutes input + GO button
        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
      initialValue: '$_cardioMinutes',
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Minutes'),
      onChanged: readOnly
        ? null
        : (v) {
            final mins = int.tryParse(v) ?? 0;
            setState(() {
              _cardioMinutes = mins;
            });
            if (widget.exercise is CardioExercise) {
              (widget.exercise as CardioExercise).plannedMinutes = mins;
            }
            widget.onValueChanged?.call();
          },
    ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
      onPressed: readOnly ? null : () {
        setState(() {
          _secondsLeft = _cardioMinutes * 60;
        });
        if (widget.exercise is CardioExercise) {
          (widget.exercise as CardioExercise).elapsedSeconds = _secondsLeft;
        }
        widget.onValueChanged?.call();

        _cardioTimer?.cancel();
        _cardioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (_secondsLeft > 0) {
            setState(() => _secondsLeft--);
            if (widget.exercise is CardioExercise) {
              (widget.exercise as CardioExercise).elapsedSeconds = _secondsLeft;
            }
            widget.onValueChanged?.call();
          } else {
            _cardioTimer?.cancel();
          }
        });
      },
      child: const Text('GO'),
    ),
          ],
        ),

        // Countdown display + Start/Stop toggle
        if (_secondsLeft > 0) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:'
                '${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_cardioTimer?.isActive ?? false) ? Colors.red : Colors.green,
                ),
                onPressed: readOnly ? null
                : () {
                  if (_cardioTimer?.isActive ?? false) {
                    _cardioTimer!.cancel();
                    setState(() {});
                  } else if (_secondsLeft > 0) {
                    _cardioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                      if (_secondsLeft > 0) {
                        setState(() => _secondsLeft--);
                        widget.onValueChanged?.call();
                      } else {
                        _cardioTimer?.cancel();
                        setState(() {});
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

  // -------------------- Stretch Card --------------------

Widget _buildStretchCard() {
  final readOnly = widget.readOnlyMode;
  // Because we added `stretchInstances` to the base WorkoutExercise,
  // every exercise (even non‐stretch) has this field. Here we assume
  // that cardType == CardType.stretch implies widget.exercise is a StretchExercise.
  final stretchList = (widget.exercise as StretchExercise).stretchInstances;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // 1) Header: exercise name + “Remove Stretch” menu
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.exercise.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          PopupMenuButton<String>(
            enabled: !readOnly,
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'remove') {
                widget.onDeleteExercise?.call();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove Stretch'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),

      // 2) “Search” / “Custom” / “+” row
      Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            onPressed: readOnly ? null
            : _showStretchSearchDialog,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _stretchCustomController,
              readOnly: readOnly,
              decoration: const InputDecoration(
                hintText: 'Custom',
                isDense: true,
              ),
              onChanged: readOnly
      ? null
              : (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: readOnly ? null
            : _stretchCustomController.text.trim().isEmpty
                ? null
                : () {
                    setState(() {
                      // 2a) Append a new “custom” entry into stretchInstances
                      stretchList.add({
                        'stretch_id': null, // custom
                        'is_custom': true,
                        'custom_name': _stretchCustomController.text.trim(),
                        'custom_desc': '',
                        'is_checked': false,
                        'order_index': stretchList.length,
                      });
                      // 2b) Mark it as checked if desired (or skip if un‐checked by default)
                      _completedStretches.add(stretchList.length - 1);
                      // 2c) Clear the text field
                      _stretchCustomController.clear();
                    });
                    widget.onValueChanged?.call();
                  },
          ),
        ],
      ),

      const SizedBox(height: 16),

      // 3) Render each stretchInstance (with checkbox + name + description + delete)
      for (var i = 0; i < stretchList.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: stretchList[i]['is_checked'] as bool,
                onChanged: readOnly
      ? null
                : (checked) {
                  setState(() {
                    // Update the underlying map’s `is_checked` field
                    stretchList[i]['is_checked'] = (checked == true);
                    if (checked == true) {
                      _completedStretches.add(i);
                    } else {
                      _completedStretches.remove(i);
                    }
                  });
                  widget.onValueChanged?.call();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // If it’s custom, show custom_name; otherwise show some default name/description
                      stretchList[i]['is_custom'] as bool
                          ? (stretchList[i]['custom_name'] as String)
                          : (stretchList[i]['custom_name'] as String),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if ((stretchList[i]['custom_desc'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          stretchList[i]['custom_desc'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: readOnly ? null 
                : () {
                  setState(() {
                    // Remove the instance from the model list
                    stretchList.removeAt(i);
                    _completedStretches.remove(i);

                    // Re‐index every remaining item’s order_index
                    for (int k = 0; k < stretchList.length; k++) {
                      stretchList[k]['order_index'] = k;
                    }

                    // Adjust _completedStretches indices > i by shifting them down 1
                    final toAdjust = _completedStretches.where((idx) => idx > i).toList();
                    for (var oldIdx in toAdjust) {
                      _completedStretches.remove(oldIdx);
                      _completedStretches.add(oldIdx - 1);
                    }
                  });
                  widget.onValueChanged?.call();
                },
              ),
            ],
          ),
        ),
    ],
  );
}
 
 // -------------------- Stretch Search Dialog --------------------
void _showStretchSearchDialog() {
  showDialog<StretchDefinition>(
    context: context,
    builder: (dialogCtx) {
      int? selectedBodyPartId;
      int? selectedStretchId;
      List<StretchDefinition> currentStretches = [];

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Stretch Search'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) Body‐part dropdown
                FutureBuilder<List<BodyPart>>(
                  future: DatabaseHelper().getAllBodyParts(),
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final parts = snap.data!;
                    return DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Body Part'),
                      value: selectedBodyPartId,
                      items: parts.map((bp) {
                        return DropdownMenuItem<int>(
                          value: bp.id,
                          child: Text(bp.name),
                        );
                      }).toList(),
                      onChanged: (newBpId) {
                        setState(() {
                          selectedBodyPartId = newBpId;
                          selectedStretchId = null;
                          currentStretches = [];
                        });
                        if (newBpId != null) {
                          DatabaseHelper()
                              .getStretches(bodypartId: newBpId)
                              .then((list) {
                            if (!mounted) return;
                            setState(() {
                              currentStretches = list;
                            });
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2) Stretch dropdown (once a body part is chosen)
                if (selectedBodyPartId != null) ...[
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Stretch'),
                    value: selectedStretchId,
                    items: currentStretches.map((st) {
                      return DropdownMenuItem<int>(
                        value: st.id,
                        child: Text(st.name),
                      );
                    }).toList(),
                    onChanged: (newStId) {
                      setState(() {
                        selectedStretchId = newStId;
                      });
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedStretchId != null)
                    ? () {
                        final chosen = currentStretches.firstWhere(
                          (st) => st.id == selectedStretchId,
                        );
                        Navigator.of(dialogCtx).pop(chosen);
                      }
                    : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  ).then((chosenStretch) {
    if (chosenStretch != null) {
      // 3) Insert the chosen stretch into the model's stretchInstances:
      setState(() {
        final stretchList =
            (widget.exercise as StretchExercise).stretchInstances;

        stretchList.add({
          'stretch_id': chosenStretch.id,
          'is_custom': false,
          'custom_name': chosenStretch.name,
          'custom_desc': chosenStretch.description,
          'is_checked': true, // mark it checked by default
          'order_index': stretchList.length,
        });

        // 4) Track this index as checked
        _completedStretches.add(stretchList.length - 1);
      });
      widget.onValueChanged?.call();
    }
  });
}


}
