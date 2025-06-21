// File: lib/widgets/session_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';
import '../models/active_session.dart';
import '../widgets/add_exercise_fab.dart';




class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ActiveSession>();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Workout Timer', style: TextStyle(fontSize: 20)),
              ),
              Text(session.formattedTime, style: const TextStyle(fontSize: 48)),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Workout Session'),
        centerTitle: true,
      ),

      body: session.exercises.isEmpty
          ? const Center(child: Text('No exercises added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: session.exercises.length,
              itemBuilder: (ctx, i) {
                final ex = session.exercises[i];
                final type = session.cardTypes[i];
                return ExerciseCard(
                  exercise: ex,
                  cardType: type,
                  initialCompletedParents: type == CardType.weight ? (ex as WeightExercise).completedParents : null,
                  initialCompletedChildren: type == CardType.weight ? (ex as WeightExercise).completedChildren : null,
                  onDeleteExercise: () => context.read<ActiveSession>().removeExercise(i),
                  onSetAdded: () => context.read<ActiveSession>().refresh(),
                  onSetDeleted: () => context.read<ActiveSession>().refresh(),
                  onValueChanged: () => context.read<ActiveSession>().refresh(),
                );
              },
              ),

      floatingActionButton: const AddExerciseFab(),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () async {
              await context.read<ActiveSession>().finish();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Finish Workout'),
          ),
        ),
      ),
    );
  }


}
