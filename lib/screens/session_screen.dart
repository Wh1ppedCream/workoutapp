// File: lib/widgets/session_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';
import 'exercise_catalog_page.dart'; // For Catalog flow
import '../models/active_session.dart';

const List<String> _bodyweightCardioOptions = [
  'Aerobics',
  'Box Jumps',
  'Jump Squats',
  'Running',
  'Swimming',
  'Walking',
  'Zumba',
];

const List<String> _equipmentCardioOptions = [
  'Battle Ropes',
  'Bicycle',
  'Elliptical',
  'Rowing Machine',
  'Ski Machine',
  'Skipping Rope',
  'Stair Climber',
  'Stationary Bike',
  'Treadmill',
  'Vertical Climber',
];

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
              itemBuilder: (ctx, i) => ExerciseCard(
                exercise: session.exercises[i],
                cardType: session.cardTypes[i],
                onDeleteExercise: () => context.read<ActiveSession>().removeExercise(i),
                onSetAdded: () {/* handled within card, optional: notify if needed */},
                onSetDeleted: () {/* optional */},
                onValueChanged: () {/* optional */},
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
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseCatalogPage(
                      onExercisePicked: (def) {
                        ctx.read<ActiveSession>().addExercise(
                          WeightExercise(
                            name: def.name,
                            equipment: def.equipmentList.isNotEmpty
                                ? def.equipmentList.first.name
                                : '',
                            sets: [ExerciseSet()],
                            changeSets: {},
                          ),
                          CardType.weight,
                        );
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
                _showCardioDetailDialog(ctx);
              },
            ),
            ListTile(
              title: const Text('Stretch'),
              onTap: () {
                Navigator.of(ctx).pop();
                ctx.read<ActiveSession>().addExercise(
                  StretchExercise(
                    name: 'Stretch',
                    equipment: '',
                    stretchInstances: [],
                  ),
                  CardType.stretch,
                );
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

  void _showCardioDetailDialog(BuildContext context) {
    String? selectedCategory;
    String? selectedExercise;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final options = (selectedCategory == 'Bodyweight')
              ? _bodyweightCardioOptions
              : (selectedCategory == 'Equipment Based')
                  ? _equipmentCardioOptions
                  : <String>[];

          return AlertDialog(
            title: const Text('Choose Cardio Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Bodyweight'),
                        value: 'Bodyweight',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Equipment Based'),
                        value: 'Equipment Based',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedCategory != null) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Exercise'),
                    value: selectedExercise,
                    items: options
                        .map((ex) => DropdownMenuItem(value: ex, child: Text(ex)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedExercise = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedExercise == null)
                    ? null
                    : () {
                        Navigator.of(dialogCtx).pop();
                        context.read<ActiveSession>().addExercise(
                          CardioExercise(
                            name: selectedExercise!,
                            equipment: '',
                            cardioName: selectedExercise!,
                            cardioNote: null,
                            plannedMinutes: 0,
                            elapsedSeconds: 0,
                          ),
                          CardType.cardio,
                        );
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
