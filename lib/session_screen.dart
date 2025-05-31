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
List<String> _equipmentNames = [];

final List<CardType> _cardTypes = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
    _loadEquipmentNames();
  }

  Future<void> _loadEquipmentNames() async {
  final names = await DatabaseHelper().getAllEquipmentNames();
  setState(() => _equipmentNames = names);
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
                cardType: _cardTypes[i],
                onDeleteExercise: () {
                  setState(() {
                    _exercises.removeAt(i);
                    _cardTypes.removeAt(i);
                  });
                },
                //onDeleteExercise: () => setState(() => _exercises.removeAt(i)),
                onSetAdded: () => setState(() {}),
                onSetDeleted: () => setState(() {}),
                onValueChanged: () => setState(() {}),
              ),
            ),
      floatingActionButton: FloatingActionButton(
  onPressed: () => _showAddCardTypeDialog(context),
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

void _showAddCardTypeDialog(BuildContext ctx) {
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Add a Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Exercise'),
            onTap: () {
              Navigator.of(ctx).pop();
              // push catalog and add a weight card
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExerciseCatalogPage(
                    onExercisePicked: (def) {
                      setState(() {
                        _exercises.add(WorkoutExercise(
                          name: def.name,
                          equipment: def.equipmentList.isNotEmpty
                              ? def.equipmentList.first.name
                              : '',
                          sets: [ExerciseSet()],
                        ));
                        _cardTypes.add(CardType.weight);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Cardio'),
            onTap: () {
              Navigator.of(ctx).pop();
              setState(() {
                _exercises.add(WorkoutExercise(
                  name: 'Cardio',
                  equipment: '',  // or use a note field
                  sets: [],
                ));
                _cardTypes.add(CardType.cardio);
              });
            },
          ),
          ListTile(
            title: const Text('Stretch'),
            onTap: () {
              Navigator.of(ctx).pop();
              setState(() {
                _exercises.add(WorkoutExercise(
                  name: 'Stretch',
                  equipment: '',
                  sets: [],
                ));
                _cardTypes.add(CardType.stretch);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        )
      ],
    ),
  );
}


}
