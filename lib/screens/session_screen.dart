// File: lib/screens/session_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';
import '../models/active_session.dart';
import '../widgets/add_exercise_fab.dart';
import '../widgets/session_complete_sheet.dart';





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
    leading: Builder(
      builder: (innerCtx) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(innerCtx).openDrawer(),
      ),
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

           floatingActionButton: AddExerciseFab(
        onWeightPicked: (def) async {
          // build a brand-new WeightExercise with one empty set:
          final ex = WeightExercise(
            name: def.name,
            equipment: def.equipmentList.isNotEmpty
                ? def.equipmentList.first.name
                : '',
            sets: [ExerciseSet()],
          );
          context.read<ActiveSession>().addExercise(ex, CardType.weight);
        },
        onCardioPicked: (cardioName) async {
          final ex = CardioExercise(
            name: cardioName,
            equipment: '',
            cardioName: cardioName,
          );
          context.read<ActiveSession>().addExercise(ex, CardType.cardio);
        },
        onStretchPicked: () async {
          final ex = StretchExercise(
            name: 'Stretch',
            equipment: '',
          );
          context.read<ActiveSession>().addExercise(ex, CardType.stretch);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () async {
             final sid = await context.read<ActiveSession>().finish();
              if (!context.mounted || sid == null) return;
              // show the completion sheet
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SessionCompleteSheet(sessionId: sid),
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();  // back to train page
            },
            child: const Text('Finish Workout'),
          ),
        ),
      ),
    );
  }


}
