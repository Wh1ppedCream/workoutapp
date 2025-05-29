import 'dart:async';
import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';
import 'widgets/exercise_card.dart';
import 'exercise_catalog_page.dart'; // For Catalog flow

const List<String> kDefaultExercises = [
  'Barbell Curl', 'Squat', 'Bench Press', 'Deadlift'
];

const List<String> kEquipments = [
  'None', 'Barbell', 'Dumbbell', 'Machine', 'Kettlebell'
];

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final List<WorkoutExercise> _exercises = [];
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _finishWorkout() {
    _timer.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Workout Timer', style: TextStyle(fontSize: 20)),
              ),
              Text(_formattedTime, style: const TextStyle(fontSize: 48)),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('New Workout'),
        centerTitle: true,
      ),
      body: _exercises.isEmpty
          ? const Center(child: Text('No exercises added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (ctx, i) => ExerciseCard(
                exercise: _exercises[i],
                onDeleteExercise: () => setState(() => _exercises.removeAt(i)),
                onSetAdded: () => setState(() {}),
                onSetDeleted: () => setState(() {}),
                onValueChanged: () => setState(() {}),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModeDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _finishWorkout,
            child: const Text('Finish Workout'),
          ),
        ),
      ),
    );
  }

  void _showAddModeDialog(BuildContext ctx) {
    var useCustom = true;
    String? selectedExercise;
    String customExercise = '';
    String selectedEquipment = kEquipments.first;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: useCustom ? Colors.deepPurple : null,
                        ),
                        onPressed: () => setDialogState(() => useCustom = true),
                        child: const Text('Custom'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !useCustom ? Colors.deepPurple : null,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExerciseCatalogPage(),
                            ),
                          );
                        },
                        child: const Text('Catalog'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (useCustom) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Exercise'),
                    items: kDefaultExercises
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    value: selectedExercise,
                    hint: const Text('Select exercise'),
                    onChanged: (v) => setDialogState(() => selectedExercise = v),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Or enter custom'),
                    onChanged: (v) => customExercise = v.trim(),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Equipment'),
                    items: kEquipments
                        .map((eq) => DropdownMenuItem(value: eq, child: Text(eq)))
                        .toList(),
                    value: selectedEquipment,
                    onChanged: (v) => setDialogState(() => selectedEquipment = v!),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = customExercise.isNotEmpty ? customExercise : selectedExercise;
                if (name == null || name.isEmpty) return;
                final newEx = WorkoutExercise(
                  name: name,
                  equipment: selectedEquipment,
                  sets: [ExerciseSet()],
                );
                setState(() => _exercises.add(newEx));
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
