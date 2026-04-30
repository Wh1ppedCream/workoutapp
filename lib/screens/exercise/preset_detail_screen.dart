// File: lib/screens/exercise/preset_detail_screen.dart
// for viewing and editing a Preset using the PresetSession notifier.

import 'package:env_test/providers/active_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../providers/preset_session.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/add_exercise_fab.dart';
import '../../widgets/automatic_settings_sheet.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/preset_info_card.dart';
import 'session_screen.dart';
import 'auto_preset_flow_screen.dart';


/// Screen to view and edit a Preset using the PresetSession notifier.
class PresetDetailScreen extends StatefulWidget {
  const PresetDetailScreen({super.key});

  @override
  State<PresetDetailScreen> createState() => _PresetDetailScreenState();
}

class _PresetDetailScreenState extends State<PresetDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final preset = context.read<PresetSession>();
    _nameController = TextEditingController(text: preset.presetName);
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
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Discard changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
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
          title: _isEditing
              ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  onSubmitted: (v) => preset.updateName(v),
                )
              : Text(preset.presetName),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: _isEditing ? Colors.green : Colors.grey),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
            // Overflow menu replacing delete icon
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) async {
                if (action == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Preset'),
                      content: const Text('Are you sure you want to delete this preset?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
  builder: (_) => AutomaticSettingsSheet(
    preset: context.read<PresetSession>(),
  ),
);

                }

                else if (action == 'flow' && preset.isAutomatic) {
     // Navigate to the full‐screen flow editor
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (_) => AutoPresetFlowScreen(presetId: preset.presetId),
       ),
     );
   }
              },
              itemBuilder: (_) {
                return [
                  const PopupMenuItem(value: 'delete', child: Text('Delete Preset')),
                  PopupMenuItem(
                    value: 'toggle_auto',
                    child: Text(preset.isAutomatic ? 'Disable Automatic' : 'Make Automatic'),
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

        body: preset.exercises.isEmpty && !_isEditing
            ? const Center(child: Text('No exercises in this preset.'))
            : _isEditing
                ? ReorderableListView(
                    padding: const EdgeInsets.all(16),
                    onReorder: (oldIndex, newIndex) {
                      final sess = context.read<PresetSession>();
                      if (newIndex > oldIndex) newIndex--;
                      sess.exercises.insert(newIndex, sess.exercises.removeAt(oldIndex));
                      sess.cardTypes.insert(newIndex, sess.cardTypes.removeAt(oldIndex));
                      sess.refresh();
                    },
                    children: [
                      for (var i = 0; i < preset.exercises.length; i++)
                        ExerciseCard(
                          key: ValueKey(i),
                          exercise: preset.exercises[i],
                          cardType: preset.cardTypes[i],
                          readOnlyMode: false,
                          initialCompletedParents: preset.exercises[i] is WeightExercise
                              ? (preset.exercises[i] as WeightExercise).completedParents
                              : null,
                          initialCompletedChildren: preset.exercises[i] is WeightExercise
                              ? (preset.exercises[i] as WeightExercise).completedChildren
                              : null,
                          onDetails: preset.cardTypes[i] == CardType.weight
                              ? () => _showExerciseDetails(preset, i)
                              : null,
                          onDeleteExercise: () => context.read<PresetSession>().removeExercise(i),
                          onSetAdded: () => context.read<PresetSession>().refresh(),
                          onSetDeleted: () => context.read<PresetSession>().refresh(),
                          onValueChanged: () => context.read<PresetSession>().refresh(),
                        ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: preset.exercises.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) {
                        return PresetInfoCard(
                          exercises: preset.exercises,
                          cardTypes: preset.cardTypes,
                          definitionIds: List<int?>.generate(
                            preset.exercises.length,
                            preset.definitionIdForExercise,
                          ),
                        );
                      }

                      final exerciseIndex = i - 1;
                      return ExerciseCard(
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
                        onDetails: preset.cardTypes[exerciseIndex] ==
                                CardType.weight
                            ? () => _showExerciseDetails(preset, exerciseIndex)
                            : null,
                      );
                    },
                  ),

        floatingActionButton: _isEditing
            ? AddExerciseFab(
                onWeightPicked: (def) async {
                  final equipment = def.equipmentList
                      .map((equipment) => equipment.name)
                      .join(', ');
                  final we = WeightExercise(name: def.name, equipment: equipment, sets: [ExerciseSet()], changeSets: {});
                  context.read<PresetSession>().addExercise(we, CardType.weight, defId: def.id);
                },
                onCardioPicked: (name) async {
                  final ce = CardioExercise(name: name, equipment: '', cardioName: name);
                  context.read<PresetSession>().addExercise(ce, CardType.cardio);
                },
                onStretchPicked: () async {
                  final se = StretchExercise(name: 'Stretch', equipment: '', stretchInstances: []);
                  context.read<PresetSession>().addExercise(se, CardType.stretch);
                },
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
                _isEditing
  ? ElevatedButton(
      onPressed: () async {
        final sess = context.read<PresetSession>();
        final newName = _nameController.text.trim();

        // 1) If the name changed, push it to the DB and local state
        if (newName.isNotEmpty && newName != sess.presetName) {
          await sess.updateName(newName);
        }

        // 2) Then save any exercise changes
        await sess.saveChanges();

        setState(() => _isEditing = false);
      },
      child: const Text('Save Preset'),
    )

                : ElevatedButton(
                    onPressed: () {
                      // 1) Capture Navigator and notifiers up-front
                      final nav = Navigator.of(context);
                      final preset = context.read<PresetSession>();
                      final active = context.read<ActiveSession>();

                      // 2) Seed the live session
                      active.exercises.clear();
                      active.cardTypes.clear();
                      for (var i = 0; i < preset.exercises.length; i++) {
                        active.addExercise(preset.exercises[i], preset.cardTypes[i]);
                      }
                      // 3) Start the timer
                      active.start(presetId: preset.presetId);


                      // 4) Navigate
                      nav.pushReplacement(
                        MaterialPageRoute(builder: (_) => const SessionScreen()),
                      );
                    },
                    child: const Text('Start Session'),
                  ),
          ),
        ),
      ),
    );
  }
}
