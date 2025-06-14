// File: lib/widgets/weight_card.dart

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Displays and edits a WeightExercise, including sets and ChangeSets.
class WeightCard extends StatefulWidget {
  final WeightExercise               exercise;
  final bool                         readOnlyMode;
  final Set<int>?                    initialCompletedParents;
  final Map<int, Set<int>>?          initialCompletedChildren;
  final VoidCallback?                onDeleteExercise;
  final VoidCallback?                onSetAdded;
  final VoidCallback?                onSetDeleted;
  final VoidCallback?                onValueChanged;

  const WeightCard({
    Key? key,
    required this.exercise,
    this.readOnlyMode = false,
    this.initialCompletedParents,
    this.initialCompletedChildren,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
  }) : super(key: key);

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {

   // ───── Note editing ─────

  late String _note;

  bool _isEditingNote = false;

  // ───── State & Controllers ─────
  late List<TextEditingController>   _weightControllers;
  late List<TextEditingController>   _repsControllers;
  bool                               _isChangeSetMode = false;
  final Map<int, List<ExerciseSet>>  _cSets           = {};
  final Set<int>                     _completedSets   = {};

  @override
  void initState() {
    super.initState();

    // Seed the note from the model’s equipment

    _note = widget.exercise.equipment;

    // 1) Seed controllers from existing sets
    final sets = widget.exercise.sets;
    _weightControllers = sets
      .map((s) => TextEditingController(text: s.weight.toString()))
      .toList();
    _repsControllers = sets
      .map((s) => TextEditingController(text: s.reps.toString()))
      .toList();

    // 2) If read-only, restore which parents were completed
    if (widget.readOnlyMode && widget.initialCompletedParents != null) {
      _completedSets.addAll(widget.initialCompletedParents!);
    }

    // 3) Always seed any existing ChangeSets
    widget.exercise.changeSets.forEach((parentIdx, children) {
      _cSets[parentIdx] = List<ExerciseSet>.from(children);
    });
    // 4) In read-only, if there _were_ changeSets saved, show them boxed
    if (widget.readOnlyMode && widget.exercise.changeSets.isNotEmpty) {
      _isChangeSetMode = true;
    }
  }

  @override
  void dispose() {
    // Clean up all controllers
    for (var c in _weightControllers) {c.dispose();}
    for (var c in _repsControllers)   {c.dispose();}
    super.dispose();
  }

  /// Called whenever a weight or reps field changes.
  void _updateWeightSet(int index) {
    final w = double.tryParse(_weightControllers[index].text) ?? 0;
    final r = int.tryParse(_repsControllers[index].text) ?? 0;
    widget.exercise.sets[index] = ExerciseSet(weight: w, reps: r);
    widget.onValueChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final we       = widget.exercise;
    final sets     = we.sets;
    final readOnly = widget.readOnlyMode;
    

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: name, note, menu ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        we.name,

                        style: Theme.of(context).textTheme.titleMedium,

                      ),

                      const SizedBox(height: 4),

                      // Note editor / display

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

                              });

                              widget.onValueChanged?.call();

                            },

                          )

                        : GestureDetector(

                            onTap: readOnly

                              ? null

                              : () => setState(() => _isEditingNote = true),

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
                  enabled: !readOnly,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (choice) async {
                    if (choice == 'remove') {
                      // original confirmation text

                      final confirm = await showDialog<bool>(

                        context: context,

                        builder: (ctx) => AlertDialog(

                          title: const Text('Remove Exercise'),

                          content: const Text('Are you sure you want to remove this exercise?'),

                          actions: [

                            TextButton(

                              onPressed: () => Navigator.pop(ctx, false),

                              child: const Text('Cancel'),

                            ),

                            TextButton(

                              onPressed: () => Navigator.pop(ctx, true),

                              child: const Text('Remove'),

                            ),

                          ],

                        ),

                      );

                      if (confirm == true) widget.onDeleteExercise?.call();
                    } else if (choice == 'changeSet') {
                      setState(() => _isChangeSetMode = !_isChangeSetMode);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'remove',  child: Text('Remove Exercise')),
                    PopupMenuItem(value: 'changeSet', child: Text('Make ChangeSet')),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // ─── List each set (with optional C-Sets) ───
            ...List.generate(sets.length, (index) {
              final set = sets[index];
              final children = <Widget>[];

              // 1) Parent set row
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
                            : (ok) {
                                setState(() {
                                  if (ok == true) {_completedSets.add(index);}
                                  else          { _completedSets.remove(index);}
                                });
                              },
                      ),
                      Expanded(child: Text('Set ${index + 1}')),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _weightControllers[index],
                          readOnly: readOnly,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Weight'),
                          onChanged: readOnly ? null : (_) => _updateWeightSet(index),
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
                          onChanged: readOnly ? null : (_) => _updateWeightSet(index),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: readOnly
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Remove Set'),
                                    content: const Text('Are you sure you want to remove this set?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(ctx,true),  child: const Text('Remove')),
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

              // 2) Boxed C-Sets (if in changeSet mode)
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

              // 3) "Add CSet" button (edit-only)
              if (!readOnly && _isChangeSetMode) {
                children.add(
            Align(

                    alignment: Alignment.centerLeft,

                    child: Container(

                      margin: const EdgeInsets.only(left: 16, bottom: 4),

                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),

                      decoration: BoxDecoration(

                        border: Border.all(color: Colors.blueAccent),

                        borderRadius: BorderRadius.circular(4),

                      ),

                      child: GestureDetector(

                        onTap: () {

                          setState(() {

                            _cSets.putIfAbsent(index, () => []);

                            _cSets[index]!.add(

                              ExerciseSet(weight: sets[index].weight, reps: sets[index].reps),

                            );

                            we.changeSets[index] =

                                List<ExerciseSet>.from(_cSets[index]!);

                          });

                          widget.onValueChanged?.call();

                        },

                        child: const Text('Add CSet'),

                      ),

                    ),

                  ),

                );
              }

              return Column(children: children);
            }),

            // ─── Add Set Button ───
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: readOnly
                    ? null
                    : () {
                        setState(() {
                          final last = sets.isNotEmpty ? sets.last : ExerciseSet();
                          sets.add(ExerciseSet(weight: last.weight, reps: last.reps));
                          _weightControllers.add(TextEditingController(text: last.weight.toString()));
                          _repsControllers.add(TextEditingController(text: last.reps.toString()));
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
