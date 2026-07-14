// File: lib/screens/exercise/preset_detail_screen.dart
// for viewing and editing a Preset using the PresetSession notifier.

import 'dart:async';

import 'package:env_test/providers/active_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/selected_profile.dart';
import '../../repositories/app_repository.dart';
import '../../providers/preset_session.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/add_exercise_fab.dart';
import '../../widgets/automatic_settings_sheet.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/preset_info_card.dart';
import '../../widgets/swap_exercise_sheet.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../utils/workout_exercise_clone.dart';
import 'session_screen.dart';
import 'auto_preset_flow_screen.dart';

/// Screen to view and edit a Preset using the PresetSession notifier.
class PresetDetailScreen extends StatefulWidget {
  const PresetDetailScreen({super.key});

  @override
  State<PresetDetailScreen> createState() => _PresetDetailScreenState();
}

class _PresetDetailScreenState extends State<PresetDetailScreen> {
  final _editTutorialKey = GlobalKey(debugLabel: 'plan_detail_edit');
  final _summaryTutorialKey = GlobalKey(debugLabel: 'plan_detail_summary');
  final _exerciseTutorialKey = GlobalKey(debugLabel: 'plan_detail_exercise');
  final _actionTutorialKey = GlobalKey(debugLabel: 'plan_detail_action');
  bool _isEditing = false;
  bool _collapseWeightCardsForReorder = false;
  bool _tutorialQueued = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final preset = context.read<PresetSession>();
    _nameController = TextEditingController(text: preset.presetName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isEditing || !context.read<PresetSession>().hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text('Discard changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
    return discard == true;
  }

  Future<void> _showExerciseDetails(PresetSession preset, int index) async {
    final exercise = preset.exercises[index];
    if (exercise is! WeightExercise) return;

    final repo = AppRepository();
    final defId =
        preset.definitionIdForExercise(index) ??
        await repo.findOrCreateExerciseDefinition(
          exercise.name,
          exercise.equipment,
        );
    final def = await repo.fetchDefinitionById(defId);
    if (def == null || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExerciseDetailSheet(definition: def, defId: defId),
    );
  }

  Key _exerciseCardKey(WorkoutExercise exercise) {
    return ValueKey('preset-exercise-${identityHashCode(exercise)}');
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.planDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _editTutorialKey,
            icon: Icons.edit,
            title: 'Edit plan',
            body:
                'Use this to rename the plan, reorder exercises, add exercises, swap movements, and change sets.',
          ),
          GuidedTutorialStep(
            targetKey: _summaryTutorialKey,
            icon: Icons.accessibility_new,
            title: 'Plan summary',
            body:
                'This shows estimated time, volume, and the main bodyparts this plan targets before you start it.',
          ),
          GuidedTutorialStep(
            targetKey: _exerciseTutorialKey,
            icon: Icons.fitness_center,
            title: 'Exercise cards',
            body:
                'Open exercise cards to review the planned sets. In edit mode, use the menu to swap or remove exercises.',
          ),
          GuidedTutorialStep(
            targetKey: _actionTutorialKey,
            icon: Icons.play_circle_outline,
            title: 'Start or save',
            body:
                'Start Session begins this plan as a workout. In edit mode, this changes to Save Preset so your changes are stored.',
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _showSwapExercisePicker(PresetSession preset, int index) async {
    final exercise = preset.exercises[index];
    if (exercise is! WeightExercise) return;

    final repo = AppRepository();
    final defId =
        preset.definitionIdForExercise(index) ??
        await repo.findOrCreateExerciseDefinition(
          exercise.name,
          exercise.equipment,
        );
    final definition = await repo.fetchDefinitionById(defId);
    if (definition == null || !mounted) return;

    final replacement = await showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => SwapExerciseSheet(
            currentDefinition: definition,
            profileId: context.read<SelectedProfile>().currentProfile?.id,
          ),
    );
    if (replacement == null || !mounted) return;

    context.read<PresetSession>().replaceWeightExerciseDefinition(
      index,
      replacement,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = context.watch<PresetSession>();

    return PopScope<bool>(
      // Disable the system back gesture so we can intercept it
      canPop: false,
      // Called whenever a pop is attempted (back button or gesture)
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final nav = Navigator.of(context);
        // If it actually popped (unlikely, since canPop is false), do nothing
        if (didPop) return;
        // Otherwise show our unsaved-changes dialog
        final shouldPop = await _onWillPop();
        if (!mounted) return;
        if (shouldPop) nav.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title:
              _isEditing
                  ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onSubmitted: (_) {},
                  )
                  : Text(preset.presetName),
          centerTitle: true,
          actions: [
            KeyedSubtree(
              key: _editTutorialKey,
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: _isEditing ? Colors.green : Colors.grey,
                ),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ),
            // Overflow menu replacing delete icon
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) async {
                if (action == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Delete Preset'),
                          content: const Text(
                            'Are you sure you want to delete this preset?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    final navContext = context;
                    await AppRepository().deletePreset(preset.presetId);
                    if (navContext.mounted) {
                      Navigator.of(navContext).pop();
                    }
                  }
                } else if (action == 'toggle_auto') {
                  if (preset.isAutomatic) {
                    await preset.disableAutomatic();
                  } else {
                    await preset.enableAutomatic();
                  }
                  setState(() {});
                } else if (action == 'settings' && preset.isAutomatic) {
                  // Open Automatic Settings modal
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder:
                        (_) => AutomaticSettingsSheet(
                          preset: context.read<PresetSession>(),
                        ),
                  );
                } else if (action == 'flow' && preset.isAutomatic) {
                  // Navigate to the full‐screen flow editor
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              AutoPresetFlowScreen(presetId: preset.presetId),
                    ),
                  );
                }
              },
              itemBuilder: (_) {
                return [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Preset'),
                  ),
                  PopupMenuItem(
                    value: 'toggle_auto',
                    child: Text(
                      preset.isAutomatic
                          ? 'Disable Automatic'
                          : 'Make Automatic',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    enabled: preset.isAutomatic,
                    child: const Text('Automatic Settings'),
                  ),

                  PopupMenuItem(
                    value: 'flow',
                    enabled: preset.isAutomatic,
                    child: const Text('Edit Auto‐Flow'),
                  ),
                ];
              },
            ),
          ],
        ),

        body:
            preset.exercises.isEmpty && !_isEditing
                ? const Center(child: Text('No exercises in this preset.'))
                : _isEditing
                ? ReorderableListView(
                  padding: const EdgeInsets.all(16),
                  onReorderStart: (_) {
                    setState(() => _collapseWeightCardsForReorder = true);
                  },
                  onReorderEnd: (_) {
                    setState(() => _collapseWeightCardsForReorder = false);
                  },
                  onReorder: (oldIndex, newIndex) {
                    context.read<PresetSession>().reorderExercise(
                      oldIndex,
                      newIndex,
                    );
                  },
                  children: [
                    for (var i = 0; i < preset.exercises.length; i++)
                      KeyedSubtree(
                        key: _exerciseCardKey(preset.exercises[i]),
                        child: KeyedSubtree(
                          key: i == 0 ? _exerciseTutorialKey : null,
                          child: ExerciseCard(
                            exercise: preset.exercises[i],
                            cardType: preset.cardTypes[i],
                            readOnlyMode: false,
                            forceCollapsed: _collapseWeightCardsForReorder,
                            initialCompletedParents:
                                preset.exercises[i] is WeightExercise
                                    ? (preset.exercises[i] as WeightExercise)
                                        .completedParents
                                    : null,
                            initialCompletedChildren:
                                preset.exercises[i] is WeightExercise
                                    ? (preset.exercises[i] as WeightExercise)
                                        .completedChildren
                                    : null,
                            onDetails:
                                preset.cardTypes[i] == CardType.weight
                                    ? () => _showExerciseDetails(preset, i)
                                    : null,
                            onSwapExercise:
                                preset.cardTypes[i] == CardType.weight
                                    ? () => _showSwapExercisePicker(preset, i)
                                    : null,
                            onDeleteExercise:
                                () => context
                                    .read<PresetSession>()
                                    .removeExercise(i),
                            onSetAdded:
                                () => context.read<PresetSession>().refresh(),
                            onSetDeleted:
                                () => context.read<PresetSession>().refresh(),
                            onValueChanged:
                                () => context.read<PresetSession>().refresh(),
                          ),
                        ),
                      ),
                  ],
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: preset.exercises.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return KeyedSubtree(
                        key: _summaryTutorialKey,
                        child: PresetInfoCard(
                          exercises: preset.exercises,
                          cardTypes: preset.cardTypes,
                          definitionIds: List<int?>.generate(
                            preset.exercises.length,
                            preset.definitionIdForExercise,
                          ),
                        ),
                      );
                    }

                    final exerciseIndex = i - 1;
                    return KeyedSubtree(
                      key: exerciseIndex == 0 ? _exerciseTutorialKey : null,
                      child: ExerciseCard(
                        exercise: preset.exercises[exerciseIndex],
                        cardType: preset.cardTypes[exerciseIndex],
                        readOnlyMode: true,
                        initialCompletedParents:
                            preset.exercises[exerciseIndex] is WeightExercise
                                ? (preset.exercises[exerciseIndex]
                                        as WeightExercise)
                                    .completedParents
                                : null,
                        initialCompletedChildren:
                            preset.exercises[exerciseIndex] is WeightExercise
                                ? (preset.exercises[exerciseIndex]
                                        as WeightExercise)
                                    .completedChildren
                                : null,
                        onDetails:
                            preset.cardTypes[exerciseIndex] == CardType.weight
                                ? () =>
                                    _showExerciseDetails(preset, exerciseIndex)
                                : null,
                      ),
                    );
                  },
                ),

        floatingActionButton:
            _isEditing
                ? AddExerciseFab(
                  onWeightPicked: (def) async {
                    final equipment = def.equipmentList
                        .map((equipment) => equipment.name)
                        .join(', ');
                    final we = WeightExercise(
                      name: def.name,
                      equipment: equipment,
                      sets: [ExerciseSet()],
                      changeSets: {},
                    );
                    context.read<PresetSession>().addExercise(
                      we,
                      CardType.weight,
                      defId: def.id,
                    );
                  },
                  // TODO(cardio/stretch): add cardio and stretch creation back
                  // after their plan-editing cards are fixed and updated.
                )
                : null,

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
            // old save button logic
            /*_isEditing
                ? ElevatedButton(
                    onPressed: () async {
                      await context.read<PresetSession>().saveChanges();
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Save Preset'),
                  )
                  */
            KeyedSubtree(
              key: _actionTutorialKey,
              child:
                  _isEditing
                      ? ElevatedButton(
                        onPressed: () async {
                          final sess = context.read<PresetSession>();
                          final newName = _nameController.text.trim();

                          try {
                            await sess.saveChanges(
                              newName:
                                  newName.isNotEmpty
                                      ? newName
                                      : sess.presetName,
                            );
                            if (mounted) setState(() => _isEditing = false);
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not save plan. The previous version is unchanged. $error',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Save Preset'),
                      )
                      : ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final preset = context.read<PresetSession>();
                          final active = context.read<ActiveSession>();
                          final workoutExercises = <WorkoutExercise>[];
                          final workoutCardTypes = <CardType>[];
                          for (var i = 0; i < preset.exercises.length; i++) {
                            // TODO(cardio/stretch): add cardio and stretch back
                            // to plan-start sessions after those cards are fixed
                            // and updated.
                            if (preset.cardTypes[i] != CardType.weight) {
                              continue;
                            }
                            workoutExercises.add(
                              cloneWorkoutExercise(
                                preset.exercises[i],
                                preservePresetSource: true,
                              ),
                            );
                            workoutCardTypes.add(preset.cardTypes[i]);
                          }
                          final started = await active.startWithExercises(
                            workoutExercises: workoutExercises,
                            workoutCardTypes: workoutCardTypes,
                            presetId: preset.presetId,
                          );
                          if (!context.mounted) return;
                          if (!started) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Your ongoing workout was kept. Finish or cancel it before starting this plan.',
                                ),
                              ),
                            );
                          }

                          nav.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SessionScreen(),
                            ),
                          );
                        },
                        child: const Text('Start Session'),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
