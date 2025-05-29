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
  List<WorkoutExercise> _exercises = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  /// Loads exercises and their sets from the database.
  Future<void> _loadExercises() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database; // Simplify lookup

    final exRows = await db.query(
      'exercises',
      where: 'session_id = ?',
      whereArgs: [widget.session.id],
    );

    final list = <WorkoutExercise>[];
    for (var exRow in exRows) {
      final instanceId = exRow['id'] as int;
      final defId = exRow['exercise_def_id'] as int;

      final defRows = await db.query(
        'exercise_definitions',
        where: 'id = ?',
        whereArgs: [defId],
      );
      if (defRows.isEmpty) continue;
      final defRow = defRows.first;
      final name = defRow['name'] as String;
      final equipmentId = defRow['equipment_id'] as int?;

      // Resolve equipment name
      var equipment = 'None';
      if (equipmentId != null) {
        final eqRows = await db.query(
          'equipment',
          where: 'id = ?',
          whereArgs: [equipmentId],
        );
        if (eqRows.isNotEmpty) {
          equipment = eqRows.first['name'] as String;
        }
      }

      // Load sets
      final setsRows = await db.query(
        'sets',
        where: 'exercise_id = ?',
        whereArgs: [instanceId],
        orderBy: 'order_index',
      );
      final sets = setsRows
          .map((s) => ExerciseSet(
                weight: (s['weight'] as num).toDouble(),
                reps: s['reps'] as int,
              ))
          .toList();

      list.add(WorkoutExercise(name: name, equipment: equipment, sets: sets));
    }

    setState(() {
      _exercises = list;
      _hasChanges = false;
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
    await db.deleteExercisesForSession(widget.session.id);
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
        await db.insertSet(exId, set.weight, set.reps, j);
      }
    }
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved!')),
    );
  }

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
        .format(widget.session.date); // Use HH for 00-23

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session: $dateStr'),
          actions: [
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
                itemBuilder: (_, i) => ExerciseCard(
                  key: ValueKey(i),
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
