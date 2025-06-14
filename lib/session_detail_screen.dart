// session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db/database_helper.dart';
import 'models.dart';
import 'widgets/exercise_card.dart';

/// Displays and allows editing of a saved workout session.
class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  const SessionDetailScreen(this.session, {Key? key}) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  List<WorkoutExercise> _exercises = [];
  bool _hasChanges = false;

  bool _isEditing = false;


  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

Future<void> _loadExercises() async {
  final dbHelper = DatabaseHelper();

  // 1) Fetch all exercise‐instance rows for this session
  final exRows = await dbHelper.getExercisesForSession(widget.session.id);
  final loaded = <WorkoutExercise>[];

  for (var exRow in exRows) {
    final instanceId = exRow['id'] as int;
    final storedType = exRow['type'] as String; // "weight", "cardio", or "stretch"

    if (storedType == 'weight') {
      // ─── WEIGHT ─────────────────────────────────────────────────
      // Lookup definition
      final defId = exRow['exercise_def_id'] as int?;
      String name = '';
      String equipmentName = '';
      if (defId != null) {
        final defRows = await (await dbHelper.database).query(
          'exercise_definitions',
          where: 'id = ?',
          whereArgs: [defId],
        );
        if (defRows.isEmpty) continue;
        final defRow = defRows.first;
        name = defRow['name'] as String;
        final eqId = defRow['equipment_id'] as int?;
        if (eqId != null) {
          final eqRows = await (await dbHelper.database).query(
            'equipment',
            where: 'id = ?',
            whereArgs: [eqId],
          );
          if (eqRows.isNotEmpty) equipmentName = eqRows.first['name'] as String;
        }
      }

      // Load parent sets + changeSets
      final parentRows = await (await dbHelper.database).query(
        'sets',
        where: 'exercise_id = ? AND parent_set_id IS NULL',
        whereArgs: [instanceId],
        orderBy: 'order_index',
      );
      final parentSets = <ExerciseSet>[];
      final csetsMap = <int, List<ExerciseSet>>{};
      for (var pRow in parentRows) {
        final parentId = pRow['id'] as int;
        parentSets.add(ExerciseSet(
          weight: (pRow['weight'] as num).toDouble(),
          reps: pRow['reps'] as int,
        ));
        final childRows = await (await dbHelper.database).query(
          'sets',
          where: 'parent_set_id = ?',
          whereArgs: [parentId],
          orderBy: 'order_index',
        );
        if (childRows.isNotEmpty) {
          csetsMap[parentSets.length - 1] = childRows.map((cRow) =>
            ExerciseSet(
              weight: (cRow['weight'] as num).toDouble(),
              reps: cRow['reps'] as int,
            )
          ).toList();
        }
      }

      // Mark all parents & children completed
      final completedParents = <int>{ for (var i = 0; i < parentSets.length; i++) i };
      final completedChildren = <int, Set<int>>{};
      csetsMap.forEach((parentIdx, kids) {
        completedChildren[parentIdx] = { for (var i = 0; i < kids.length; i++) i };
      });

      loaded.add(WeightExercise(
        name:              name,
        equipment:         equipmentName,
        sets:              parentSets,
        changeSets:        csetsMap,
        completedParents:  completedParents,
        completedChildren: completedChildren,
      ));
    }
    else if (storedType == 'cardio') {
      // ─── CARDIO ─────────────────────────────────────────────────
      final cardioRows = await (await dbHelper.database).query(
        'cardio_details',
        where: 'exercise_id = ?',
        whereArgs: [instanceId],
      );
      if (cardioRows.isEmpty) continue;
      final cRow = cardioRows.first;
      loaded.add(CardioExercise(
        name:            cRow['cardio_name'] as String,
        equipment:       '',
        cardioName:      cRow['cardio_name'] as String,
        cardioNote:      cRow['note'] as String?,
        plannedMinutes:  (cRow['planned_minutes'] as num).toInt(),
        elapsedSeconds:  (cRow['elapsed_seconds'] as num).toInt(),
      ));
    }
    else if (storedType == 'stretch') {
      // ─── STRETCH ────────────────────────────────────────────────
      final itemRows = await (await dbHelper.database).query(
        'stretch_instance_items',
        where: 'exercise_id = ?',
        whereArgs: [instanceId],
        orderBy: 'order_index',
      );

      final items = <Map<String, dynamic>>[];
      final checkedIndices = <int>{};
      for (var idx = 0; idx < itemRows.length; idx++) {
        final r = itemRows[idx];
        final isChecked = (r['is_checked'] as int) == 1;
        items.add({
          'stretch_id':  r['stretch_id'] as int?,
          'is_custom':   (r['is_custom'] as int) == 1,
          'custom_name': r['custom_name'] as String?,
          'custom_desc': r['custom_desc'] as String?,
          'is_checked':  isChecked,
          'order_index': (r['order_index'] as num).toInt(),
        });
        if (isChecked) checkedIndices.add(idx);
      }

      // Determine card header
      String stretchCardName = 'Stretch';
      if (items.isNotEmpty) {
        final first = items.first;
        if (first['stretch_id'] != null) {
          final sdRows = await (await dbHelper.database).query(
            'stretch_definitions',
            where: 'id = ?',
            whereArgs: [first['stretch_id'] as int],
          );
          if (sdRows.isNotEmpty) {
            stretchCardName = sdRows.first['name'] as String;
          }
        } else if (first['is_custom'] == true) {
          stretchCardName = first['custom_name'] as String? ?? 'Stretch';
        }
      }

      loaded.add(StretchExercise(
        name:                    stretchCardName,
        equipment:               '',
        stretchInstances:        items,
        completedStretchIndices: checkedIndices,
      ));
    }
  }

  if (!mounted) return;
  setState(() {
    _exercises = loaded;
    _hasChanges = false;
  });
}



  /// Deletes the entire session (cascades exercises & child rows).
  Future<void> _deleteSession(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DatabaseHelper().deleteSession(widget.session.id);
    Navigator.of(context).pop();
  }

  /// Saves in‐session edits back to the database.
  Future<void> _saveChanges() async {
    final db = DatabaseHelper();

    // 1) Delete all old exercises for this session (cascade deletes child rows)
    await db.deleteExercisesForSession(widget.session.id);

    // 2) Re-insert each item in _exercises, using its concrete subclass
    for (int i = 0; i < _exercises.length; i++) {
      final we = _exercises[i];

      int? defId;
      if (we is WeightExercise) {
        // Look up or insert into exercise_definitions
        final eqRows = await (await db.database).query(
          'equipment',
          where: 'name = ?',
          whereArgs: [we.equipment],
        );
        final eqId = eqRows.isNotEmpty ? eqRows.first['id'] as int : null;

        final defRows = await (await db.database).query(
          'exercise_definitions',
          where: eqId != null
              ? 'name = ? AND equipment_id = ?'
              : 'name = ? AND equipment_id IS NULL',
          whereArgs: eqId != null ? [we.name, eqId] : [we.name],
        );

        if (defRows.isNotEmpty) {
          defId = defRows.first['id'] as int;
        } else {
          defId = await (await db.database).insert(
            'exercise_definitions',
            {
              'name': we.name,
              'equipment_id': eqId,
              'rating': 0,
            },
          );
        }
      }

      // Insert into `exercises` with type = appropriate string
      final exerciseId = await db.insertExerciseRow(
        sessionId: widget.session.id,
        exerciseDefId: defId,
        type: we is WeightExercise
            ? 'weight'
            : we is CardioExercise
                ? 'cardio'
                : 'stretch',
        orderIndex: i,
      );

      // 3) Insert child rows based on subclass
      if (we is WeightExercise) {
        await db.insertWeightSets(
          exerciseId: exerciseId,
          parentSets: we.sets,
          childChangeSets: we.changeSets,
        );
      }
      else if (we is CardioExercise) {
        await db.insertCardioDetails(
          exerciseId: exerciseId,
          cardioName: we.cardioName,
          note: we.cardioNote,
          plannedMinutes: we.plannedMinutes,
          elapsedSeconds: we.elapsedSeconds,
        );
      }
      else if (we is StretchExercise) {
  await db.insertStretchInstance(
    exerciseId: exerciseId,
    items: we.stretchInstances, // pass the raw List<Map<String,dynamic>>
  );
}

    }

    if (!mounted) return;
    setState(() => _hasChanges = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved!')),
    );
  }

  /// If there are unsaved changes, prompt the user before popping.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Do you want to discard them and leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd – HH:mm')
        .format(widget.session.date);

    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final allowPop = await _onWillPop();
        if (allowPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$dateStr'),
          actions: [
            IconButton(
      icon: Icon(
        Icons.edit,
        color: _isEditing ? Colors.green : Colors.grey,
      ),
      onPressed: () => setState(() => _isEditing = !_isEditing),
    ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _deleteSession(context),
            ),
          ],
        ),
        body: _exercises.isEmpty
            ? const Center(child: Text('No exercises in this session.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length,
                itemBuilder: (_, i) {
                  final we = _exercises[i];
                  // Determine cardType by concrete class
                  final cardType = we is WeightExercise
                      ? CardType.weight
                      : we is CardioExercise
                          ? CardType.cardio
                          : CardType.stretch;
                  return ExerciseCard(
  key: ValueKey(i),
  exercise: we,
  cardType: cardType,
  readOnlyMode: !_isEditing,
  initialCompletedParents: (we is WeightExercise) ? we.completedParents : null,
  initialCompletedChildren:(we is WeightExercise) ? we.completedChildren : null,

  // when editing, allow removal/add/edit → set _hasChanges
  onDeleteExercise: _isEditing
    ? () {
        setState(() {
          _exercises.removeAt(i);
          _hasChanges = true;
        });
      }
    : null,
  onSetAdded: _isEditing ? () => setState(() => _hasChanges = true) : null,
  onSetDeleted: _isEditing ? () => setState(() => _hasChanges = true) : null,
  onValueChanged: _isEditing ? () => setState(() => _hasChanges = true) : null,
);

                },
              ),
        bottomNavigationBar: _hasChanges
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              )
            : null,

            
      ),
    );
  }
}
