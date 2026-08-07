// File: lib/screens/exercise/session_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../widgets/exercise_card.dart';
import '../../providers/active_session.dart';
import '../../widgets/add_exercise_fab.dart';
import '../../widgets/session_complete_sheet.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/app_test_keys.dart';

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
    final strings = AppLocalizations.of(context);
    final steps = <GuidedTutorialStep>[
      if (session.exercises.isNotEmpty)
        GuidedTutorialStep(
          targetKey: _firstExerciseTutorialKey,
          icon: Icons.fitness_center,
          title: strings.sessionTutorialCardsTitle,
          body: strings.sessionTutorialCardsBody,
        ),
      GuidedTutorialStep(
        targetKey: _addExerciseTutorialKey,
        icon: Icons.add_circle_outline,
        title: strings.sessionTutorialAddTitle,
        body: strings.sessionTutorialAddBody,
      ),
      GuidedTutorialStep(
        targetKey: _finishWorkoutTutorialKey,
        icon: Icons.flag_outlined,
        title: strings.sessionTutorialFinishTitle,
        body: strings.sessionTutorialFinishBody,
      ),
    ];

    await GuidedTutorialOverlay.show(context, steps: steps);
    await _tutorialStore.markCompleted(TutorialIds.firstWorkoutSession);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ActiveSession>();
    final strings = AppLocalizations.of(context);
    _queueWorkoutTutorial();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  strings.sessionTimerTitle,
                  style: const TextStyle(fontSize: 20),
                ),
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
        title: Text(strings.sessionTitle),
        centerTitle: true,
      ),

      body:
          session.exercises.isEmpty
              ? Center(child: Text(strings.sessionNoExercises))
              : ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                                final repo = context.read<AppRepository>();
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
              key: AppTestKeys.sessionFinish,
              onPressed:
                  session.isFinishing
                      ? null
                      : () async {
                        try {
                          final sid = await session.finish();
                          if (!context.mounted) return;
                          if (sid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.sessionNeedCompletedSet),
                              ),
                            );
                            return;
                          }
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: false,
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
                                strings.sessionSaveFailed('$error'),
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
                      : Text(strings.sessionFinishWorkout),
            ),
          ),
        ),
      ),
    );
  }
}
