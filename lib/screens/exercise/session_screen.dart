// File: lib/screens/exercise/session_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../widgets/exercise_card.dart';
import '../../providers/active_session.dart';
import '../../widgets/add_exercise_fab.dart';
import '../../widgets/session_complete_sheet.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _tutorialStore = const TutorialStateStore();
  final _firstExerciseTutorialKey = GlobalKey(
    debugLabel: 'first_workout_exercise_card_tutorial',
  );
  final _addExerciseTutorialKey = GlobalKey(
    debugLabel: 'first_workout_add_exercise_tutorial',
  );
  final _finishWorkoutTutorialKey = GlobalKey(
    debugLabel: 'first_workout_finish_tutorial',
  );

  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueWorkoutTutorial();
    });
  }

  void _queueWorkoutTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showWorkoutTutorialIfNeeded());
  }

  Future<void> _showWorkoutTutorialIfNeeded() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    final completed = await _tutorialStore.isCompleted(
      TutorialIds.firstWorkoutSession,
    );
    if (completed || !mounted) return;

    final session = context.read<ActiveSession>();
    final steps = <GuidedTutorialStep>[
      if (session.exercises.isNotEmpty)
        GuidedTutorialStep(
          targetKey: _firstExerciseTutorialKey,
          icon: Icons.fitness_center,
          title: 'Exercise cards',
          body:
              'Each card holds one exercise. Open it to edit weights and reps, then tick sets off as you complete them.',
        ),
      GuidedTutorialStep(
        targetKey: _addExerciseTutorialKey,
        icon: Icons.add_circle_outline,
        title: 'Add exercises',
        body:
            'Use this button when you want to add another exercise from the catalog during the workout.',
      ),
      GuidedTutorialStep(
        targetKey: _finishWorkoutTutorialKey,
        icon: Icons.flag_outlined,
        title: 'Finish workout',
        body:
            'When you are done, finish the session so Tonos can save the workout and update your history, analytics, and progress widgets.',
      ),
    ];

    await GuidedTutorialOverlay.show(context, steps: steps);
    await _tutorialStore.markCompleted(TutorialIds.firstWorkoutSession);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ActiveSession>();
    _queueWorkoutTutorial();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Workout Timer', style: TextStyle(fontSize: 20)),
              ),
              ValueListenableBuilder<int>(
                valueListenable: session.elapsedSecondsListenable,
                builder: (_, seconds, __) {
                  final m = seconds ~/ 60;
                  final s = seconds % 60;
                  return Text(
                    '$m:${s.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 48),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder:
              (innerCtx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(innerCtx).openDrawer(),
              ),
        ),
        title: const Text('Workout Session'),
        centerTitle: true,
      ),

      body:
          session.exercises.isEmpty
              ? const Center(child: Text('No exercises added.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: session.exercises.length,
                itemBuilder: (ctx, i) {
                  final ex = session.exercises[i];
                  final type = session.cardTypes[i];
                  return KeyedSubtree(
                    key: i == 0 ? _firstExerciseTutorialKey : null,
                    child: ExerciseCard(
                      exercise: ex,
                      cardType: type,
                      onDetails:
                          type == CardType.weight
                              ? () async {
                                final repo = AppRepository();
                                final defId = await repo
                                    .findOrCreateExerciseDefinition(
                                      ex.name,
                                      ex.equipment,
                                    );
                                final def = await repo.fetchDefinitionById(
                                  defId,
                                );
                                if (def != null && context.mounted) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder:
                                        (_) => ExerciseDetailSheet(
                                          definition: def,
                                          defId: defId,
                                        ),
                                  );
                                }
                              }
                              : null,
                      initialCompletedParents:
                          type == CardType.weight
                              ? (ex as WeightExercise).completedParents
                              : null,
                      initialCompletedChildren:
                          type == CardType.weight
                              ? (ex as WeightExercise).completedChildren
                              : null,
                      onDeleteExercise:
                          () => context.read<ActiveSession>().removeExercise(i),
                      onSetAdded: () => context.read<ActiveSession>().refresh(),
                      onSetDeleted:
                          () => context.read<ActiveSession>().refresh(),
                      onValueChanged:
                          () => context.read<ActiveSession>().refresh(),
                    ),
                  );
                },
              ),

      floatingActionButton: KeyedSubtree(
        key: _addExerciseTutorialKey,
        child: AddExerciseFab(
          onWeightPicked: (def) async {
            // build a brand-new WeightExercise with one empty set:
            final ex = WeightExercise(
              name: def.name,
              equipment:
                  def.equipmentList.isNotEmpty
                      ? def.equipmentList.first.name
                      : '',
              sets: [ExerciseSet()],
            );
            context.read<ActiveSession>().addExercise(ex, CardType.weight);
          },
          // TODO(cardio/stretch): add cardio and stretch creation back after
          // their workout-session cards are fixed and updated.
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: KeyedSubtree(
            key: _finishWorkoutTutorialKey,
            child: ElevatedButton(
              onPressed:
                  session.isFinishing
                      ? null
                      : () async {
                        try {
                          final sid = await session.finish();
                          if (!context.mounted) return;
                          if (sid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Complete at least one set before finishing the workout.',
                                ),
                              ),
                            );
                            return;
                          }
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (_) => SessionCompleteSheet(sessionId: sid),
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Could not save workout. Your ongoing workout is still available. $error',
                              ),
                            ),
                          );
                        }
                      },
              child:
                  session.isFinishing
                      ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Finish Workout'),
            ),
          ),
        ),
      ),
    );
  }
}
