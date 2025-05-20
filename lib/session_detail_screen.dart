// File: lib/session_detail_screen.dart

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
  _SessionDetailScreenState createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  // -- State fields --
  List<WorkoutExercise> _exercises = [];
  bool _hasChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  /// Loads exercises and their sets from the database.
  Future<void> _loadExercises() async {
    final dbHelper = DatabaseHelper();
    // 1) Fetch instance rows
    final exRows = await dbHelper.getExercisesForSession(widget.session.id);

    final list = <WorkoutExercise>[];
    for (var exRow in exRows) {
      final instanceId = exRow['id'] as int;
      final defId = exRow['exercise_def_id'] as int;

      // 2) Lookup definition
      final defRows = await dbHelper.database.then((db) => db.query(
            'exercise_definitions',
            where: 'id = ?',
            whereArgs: [defId],
          ));
      if (defRows.isEmpty) continue;
      final defRow = defRows.first;
      final name = defRow['name'] as String;
      final equipmentId = defRow['equipment_id'] as int?;

      // 3) Resolve equipment name
      var equipment = 'None';
      if (equipmentId != null) {
        final eqRows = await dbHelper.database.then((db) => db.query(
              'equipment',
              where: 'id = ?',
              whereArgs: [equipmentId],
            ));
        if (eqRows.isNotEmpty) {
          equipment = eqRows.first['name'] as String;
        }
      }

      // 4) Load sets
      final setsRows = await dbHelper.getSetsForExercise(instanceId);
      final sets = setsRows
          .map((s) => ExerciseSet(
                weight: (s['weight'] as num).toDouble(),
                reps: s['reps'] as int,
              ))
          .toList();

      list.add(WorkoutExercise(
        name: name,
        equipment: equipment,
        sets: sets,
      ));
    }

    setState(() {
      _exercises = list;
      _hasChanges = false;
      _isLoading = false;
    });
  }

  /// Deletes the entire session (cascades exercises/sets).
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

  /// Saves any in-session edits back to the database.
  Future<void> _saveChanges() async {
    final db = DatabaseHelper();
    // Remove old exercises & cascade-delete sets
    await db.deleteExercisesForSession(widget.session.id);
    // Re-insert updated exercises & sets
    for (var i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      final exId = await db.insertExercise(
        widget.session.id,
        ex.name,
        ex.equipment,
        i,
      );
      for (var j = 0; j < ex.sets.length; j++) {
        final set = ex.sets[j];
        await db.insertSet(
          exId,
          set.weight,
          set.reps,
          j,
        );
      }
    }
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy-MM-dd – kk:mm').format(widget.session.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session: $dateStr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _deleteSession(context),
          ),
        ],
      ),

      // Loading spinner or the exercise list
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < _exercises.length; i++)
                  ExerciseCard(
                    exercise: _exercises[i],
                    onDeleteExercise: () {
                      setState(() {
                        _exercises.removeAt(i);
                        _hasChanges = true;
                      });
                    },
                    onSetAdded: () => setState(() => _hasChanges = true),
                    onSetDeleted: () => setState(() => _hasChanges = true),
                    onValueChanged: () => setState(() => _hasChanges = true),
                  ),
              ],
            ),

      // Bottom bar: shows only if there are unsaved changes
      bottomNavigationBar: _hasChanges
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            )
          : null,
    );
  }
}
