// File: lib/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db/database_helper.dart';
import 'models.dart';
import 'widgets/exercise_card.dart';

/// Displays and allows editing of a saved workout session.
/// Shows “Save Changes” when in-session edits occur.
class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  const SessionDetailScreen(this.session, {Key? key}) : super(key: key);

  @override
  _SessionDetailScreenState createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  // -- State fields (around line 15) --
  late List<WorkoutExercise> _exercises;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadExercises(); // load from DB on screen open
  }

  /// (Around line 25) Loads exercises and their sets from the database.
  Future<void> _loadExercises() async {
    final db = DatabaseHelper();
    final exRows = await db.getExercisesForSession(widget.session.id);
    final list = <WorkoutExercise>[];
    for (var exRow in exRows) {
      final setsRows = await db.getSetsForExercise(exRow['id'] as int);
      final sets = setsRows.map((s) => ExerciseSet(
            weight: (s['weight'] as num).toDouble(),
            reps: s['reps'] as int,
          )).toList();
      list.add(WorkoutExercise(
        name: exRow['name'] as String,
        equipment: exRow['equipment'] as String,
        sets: sets,
      ));
    }
    setState(() {
      _exercises = list;
      _hasChanges = false;
    });
  }

  /// (Around line 45) Deletes the entire session (cascades exercises/sets).
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
    Navigator.of(context).pop(); // go back to history
  }

  /// (Around line 65) Saves any in-session edits back to the database.
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
      // AppBar with delete icon
      appBar: AppBar(
        title: Text('Session: $dateStr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _deleteSession(context),
          ),
        ],
      ),

      // Body: editable list of ExerciseCard widgets
      body: ListView(
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

      // Bottom bar: shows only if there are changes
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
