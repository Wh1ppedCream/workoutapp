import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets/exercise_card.dart';
import 'package:intl/intl.dart';
import 'db/database_helper.dart';
import 'history_screen.dart';

const List<String> kDefaultExercises = [
  'Barbell Curl',
  'Squat',
  'Bench Press',
  'Deadlift',
];

const List<String> kEquipments = [
  'None',
  'Barbell',
  'Dumbbell',
  'Machine',
  'Kettlebell',
];

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final List<WorkoutExercise> _exercises = [];
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // record when session begins
  }

  void _addExercise() async {
    final newEx = await _showAddExerciseDialog(context);
    if (newEx != null) {
      setState(() {
        _exercises.add(newEx);
      });
    }
  }

  Future<void> _finishWorkout() async {
    if (_exercises.isEmpty) return;

    final db = DatabaseHelper();
    final endTime = DateTime.now();
    final durationSec = endTime.difference(_startTime).inSeconds;
    final dateStr = DateFormat('yyyy-MM-dd').format(_startTime);

    // 1. Insert session row
    final sessionId = await db.insertSession(dateStr, durationSec);

    // 2. Insert exercises & their sets
    for (var i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      final exId = await db.insertExercise(
        sessionId,
        ex.name,
        ex.equipment,
        i, // order_index
      );

      for (var j = 0; j < ex.sets.length; j++) {
        final set = ex.sets[j];
        await db.insertSet(
          exId,
          set.weight,
          set.reps,
          j, // order_index
        );
      }
    }

    // 3. Reset for a new session
    setState(() {
      _exercises.clear();
      _startTime = DateTime.now();
    });

    // 4. Provide feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < _exercises.length; i++)
          ExerciseCard(
            exercise: _exercises[i],
            onDeleteExercise: () {
              setState(() {
                _exercises.removeAt(i);
              }
              );
            },
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _finishWorkout,
          child: const Text('Finish Workout'),
        ),
      ),
    );
  }
}

/// The dialog for adding a new exercise remains unchanged.
Future<WorkoutExercise?> _showAddExerciseDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String? selectedExercise;
  String customExercise = '';
  String selectedEquipment = kEquipments.first;

  return showDialog<WorkoutExercise>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Exercise'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Exercise'),
            items: kDefaultExercises
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            value: selectedExercise,
            hint: const Text('Select exercise'),
            onChanged: (v) => selectedExercise = v,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Or enter custom'),
            onChanged: (v) => customExercise = v.trim(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Equipment'),
            items: kEquipments
                .map((eq) => DropdownMenuItem(value: eq, child: Text(eq)))
                .toList(),
            value: selectedEquipment,
            onChanged: (v) {
              if (v != null) selectedEquipment = v;
            },
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name =
                customExercise.isNotEmpty ? customExercise : selectedExercise;
            if (name == null || name.isEmpty) return;
            final newEx = WorkoutExercise(
              name: name,
              equipment: selectedEquipment,
              sets: [ExerciseSet()],
            );
            Navigator.of(ctx).pop(newEx);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
