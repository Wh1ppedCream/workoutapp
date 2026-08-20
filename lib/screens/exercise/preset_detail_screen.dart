// File: lib/screens/exercise/preset_detail_screen.dart
// for viewing and editing a Preset using the PresetSession notifier.

import 'dart:async';

import 'package:env_test/providers/active_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
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
import '../../widgets/onboarding_plan_builder_coach.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../utils/workout_exercise_clone.dart';
import '../../utils/app_test_keys.dart';
import 'session_screen.dart';
import 'auto_preset_flow_screen.dart';

enum PresetDetailResult { saved, discarded, deleted }

enum _OnboardingPlanBuilderStep {
  namePlan,
  addExercise,
  configureWeight,
  configureReps,
  addSet,
  savePlan,
}

/// Screen to view and edit a Preset using the PresetSession notifier.
class PresetDetailScreen extends StatefulWidget {
  const PresetDetailScreen({
    super.key,
    this.startInEditingMode = false,
    this.showOnboardingManualPlanTutorial = false,
    this.closeAfterSave = false,
  });

  /// Opens a newly-created plan ready for the user to build it.
  final bool startInEditingMode;

  /// Uses the focused first-plan walkthrough instead of the regular overview.
  final bool showOnboardingManualPlanTutorial;

  /// Returns to the caller once a newly-created onboarding plan is saved.
  final bool closeAfterSave;

  @override
  State<PresetDetailScreen> createState() => _PresetDetailScreenState();
}

class _PresetDetailScreenState extends State<PresetDetailScreen> {
  final _tutorialStore = const TutorialStateStore();
  final _editTutorialKey = GlobalKey(debugLabel: 'plan_detail_edit');
  final _nameTutorialKey = GlobalKey(debugLabel: 'plan_detail_name');
  final _summaryTutorialKey = GlobalKey(debugLabel: 'plan_detail_summary');
  final _exerciseTutorialKey = GlobalKey(debugLabel: 'plan_detail_exercise');
  final _firstSetWeightTutorialKey = GlobalKey(
    debugLabel: 'plan_detail_first_set_weight',
  );
  final _firstSetRepsTutorialKey = GlobalKey(
    debugLabel: 'plan_detail_first_set_reps',
  );
  final _addSetTutorialKey = GlobalKey(debugLabel: 'plan_detail_add_set');
  final _addExerciseTutorialKey = GlobalKey(
    debugLabel: 'plan_detail_add_exercise',
  );
  final _actionTutorialKey = GlobalKey(debugLabel: 'plan_detail_action');
  bool _isEditing = false;
  bool _collapseWeightCardsForReorder = false;
  bool _tutorialQueued = false;
  bool _onboardingPlanGuideSkipped = false;
  bool _onboardingPlanGuideAvailable = false;
  _OnboardingPlanBuilderStep _onboardingPlanBuilderStep =
      _OnboardingPlanBuilderStep.namePlan;
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  final _firstSetWeightFocusNode = FocusNode();
  final _firstSetRepsFocusNode = FocusNode();

  bool get _showsOnboardingPlanGuide =>
      widget.showOnboardingManualPlanTutorial &&
      _onboardingPlanGuideAvailable &&
      !_onboardingPlanGuideSkipped;

  @override
  void initState() {
    super.initState();
    final preset = context.read<PresetSession>();
    _nameController = TextEditingController(text: preset.presetName);
    _nameFocusNode = FocusNode();
    _isEditing = widget.startInEditingMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
      unawaited(_loadOnboardingPlanGuideAvailability());
      unawaited(_syncLoadedPresetName(preset));
    });
  }

  Future<void> _syncLoadedPresetName(PresetSession preset) async {
    await preset.ready;
    if (!mounted || _nameController.text.trim().isNotEmpty) return;
    _nameController.text = preset.presetName;
  }

  Future<void> _loadOnboardingPlanGuideAvailability() async {
    if (!widget.showOnboardingManualPlanTutorial) return;

    final completed = await _tutorialStore.isCompleted(
      TutorialIds.onboardingManualPlan,
    );
    if (!mounted || completed) return;

    setState(() => _onboardingPlanGuideAvailable = true);
    _syncOnboardingPlanGuideFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _firstSetWeightFocusNode.dispose();
    _firstSetRepsFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isEditing || !context.read<PresetSession>().hasChanges) return true;
    final strings = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(strings.planUnsavedChangesTitle),
            content: Text(strings.planDiscardChangesQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(strings.planDiscard),
              ),
            ],
          ),
    );
    return discard == true;
  }

  Future<void> _showExerciseDetails(PresetSession preset, int index) async {
    final exercise = preset.exercises[index];
    if (exercise is! WeightExercise) return;

    final repo = context.read<AppRepository>();
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
    if (widget.showOnboardingManualPlanTutorial) return;
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.planDetail,
        steps: _planDetailTutorialSteps,
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  List<GuidedTutorialStep> get _planDetailTutorialSteps {
    final strings = AppLocalizations.of(context);
    return [
      GuidedTutorialStep(
        targetKey: _editTutorialKey,
        icon: Icons.edit,
        title: strings.planTutorialEditTitle,
        body: strings.planTutorialEditBody,
      ),
      GuidedTutorialStep(
        targetKey: _summaryTutorialKey,
        icon: Icons.accessibility_new,
        title: strings.planTutorialSummaryTitle,
        body: strings.planTutorialSummaryBody,
      ),
      GuidedTutorialStep(
        targetKey: _exerciseTutorialKey,
        icon: Icons.fitness_center,
        title: strings.planTutorialExerciseCardsTitle,
        body: strings.planTutorialExerciseCardsBody,
      ),
      GuidedTutorialStep(
        targetKey: _actionTutorialKey,
        icon: Icons.play_circle_outline,
        title: strings.planTutorialStartOrSaveTitle,
        body: strings.planTutorialStartOrSaveBody,
      ),
    ];
  }

  void _advanceOnboardingPlanGuide(_OnboardingPlanBuilderStep expectedStep) {
    if (!_showsOnboardingPlanGuide ||
        _onboardingPlanBuilderStep != expectedStep) {
      return;
    }

    setState(() {
      switch (_onboardingPlanBuilderStep) {
        case _OnboardingPlanBuilderStep.namePlan:
          _onboardingPlanBuilderStep = _OnboardingPlanBuilderStep.addExercise;
          break;
        case _OnboardingPlanBuilderStep.configureWeight:
          _onboardingPlanBuilderStep = _OnboardingPlanBuilderStep.configureReps;
          break;
        case _OnboardingPlanBuilderStep.configureReps:
          _onboardingPlanBuilderStep = _OnboardingPlanBuilderStep.addSet;
          break;
        case _OnboardingPlanBuilderStep.addSet:
          _onboardingPlanBuilderStep = _OnboardingPlanBuilderStep.savePlan;
          break;
        case _OnboardingPlanBuilderStep.addExercise:
        case _OnboardingPlanBuilderStep.savePlan:
          break;
      }
    });
    _syncOnboardingPlanGuideFocus();
  }

  void _skipOnboardingPlanGuide() {
    setState(() => _onboardingPlanGuideSkipped = true);
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(_tutorialStore.markCompleted(TutorialIds.onboardingManualPlan));
  }

  /// Keeps the input method aligned with the live walkthrough target.
  void _syncOnboardingPlanGuideFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showsOnboardingPlanGuide) {
        FocusManager.instance.primaryFocus?.unfocus();
        return;
      }

      switch (_onboardingPlanBuilderStep) {
        case _OnboardingPlanBuilderStep.namePlan:
          _nameFocusNode.requestFocus();
          break;
        case _OnboardingPlanBuilderStep.configureWeight:
          _firstSetWeightFocusNode.requestFocus();
          break;
        case _OnboardingPlanBuilderStep.configureReps:
          _firstSetRepsFocusNode.requestFocus();
          break;
        case _OnboardingPlanBuilderStep.addExercise:
        case _OnboardingPlanBuilderStep.addSet:
        case _OnboardingPlanBuilderStep.savePlan:
          FocusManager.instance.primaryFocus?.unfocus();
          break;
      }
    });
  }

  InteractiveTutorialStep? _buildOnboardingPlanGuideStep() {
    if (!_showsOnboardingPlanGuide) return null;
    final strings = AppLocalizations.of(context);

    switch (_onboardingPlanBuilderStep) {
      case _OnboardingPlanBuilderStep.namePlan:
        return InteractiveTutorialStep(
          targetKey: _nameTutorialKey,
          stepNumber: 1,
          totalSteps: 8,
          icon: Icons.edit_note,
          title: strings.planGuideNameTitle,
          body: strings.planGuideNameBody,
          continueLabel: strings.commonContinue,
          onContinue:
              () => _advanceOnboardingPlanGuide(
                _OnboardingPlanBuilderStep.namePlan,
              ),
        );
      case _OnboardingPlanBuilderStep.addExercise:
        return InteractiveTutorialStep(
          targetKey: _addExerciseTutorialKey,
          stepNumber: 2,
          totalSteps: 8,
          icon: Icons.add_circle_outline,
          title: strings.planGuideBrowseTitle,
          body: strings.planGuideBrowseBody,
        );
      case _OnboardingPlanBuilderStep.configureWeight:
        return InteractiveTutorialStep(
          targetKey: _firstSetWeightTutorialKey,
          stepNumber: 5,
          totalSteps: 8,
          icon: Icons.tune,
          title: strings.planGuideWeightTitle,
          body: strings.planGuideWeightBody,
          continueLabel: strings.planGuideWeightSet,
          onContinue:
              () => _advanceOnboardingPlanGuide(
                _OnboardingPlanBuilderStep.configureWeight,
              ),
        );
      case _OnboardingPlanBuilderStep.configureReps:
        return InteractiveTutorialStep(
          targetKey: _firstSetRepsTutorialKey,
          stepNumber: 6,
          totalSteps: 8,
          icon: Icons.repeat,
          title: strings.planGuideRepsTitle,
          body: strings.planGuideRepsBody,
          continueLabel: strings.planGuideRepsSet,
          onContinue:
              () => _advanceOnboardingPlanGuide(
                _OnboardingPlanBuilderStep.configureReps,
              ),
        );
      case _OnboardingPlanBuilderStep.addSet:
        return InteractiveTutorialStep(
          targetKey: _addSetTutorialKey,
          stepNumber: 7,
          totalSteps: 8,
          icon: Icons.playlist_add,
          title: strings.planGuideAddSetTitle,
          body: strings.planGuideAddSetBody,
        );
      case _OnboardingPlanBuilderStep.savePlan:
        return InteractiveTutorialStep(
          targetKey: _actionTutorialKey,
          stepNumber: 8,
          totalSteps: 8,
          icon: Icons.save_outlined,
          title: strings.planGuideSaveTitle,
          body: strings.planGuideSaveBody,
        );
    }
  }

  Future<void> _savePlan() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final session = context.read<PresetSession>();
    final newName = _nameController.text.trim();

    try {
      await session.saveChanges(
        newName: newName.isNotEmpty ? newName : session.presetName,
        publishDraft: widget.closeAfterSave && session.isDraft,
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      if (widget.closeAfterSave) {
        Navigator.of(context).pop(PresetDetailResult.saved);
      }
    } catch (error) {
      if (!context.mounted) return;
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.planSaveFailed(safeFailureMessage(strings, error)),
          ),
        ),
      );
    }
  }

  Future<void> _startPlanSession() async {
    final navigator = Navigator.of(context);
    final preset = context.read<PresetSession>();
    final activeSession = context.read<ActiveSession>();
    final workoutExercises = <WorkoutExercise>[];
    final workoutCardTypes = <CardType>[];
    for (var i = 0; i < preset.exercises.length; i++) {
      // TODO(cardio/stretch): add cardio and stretch back to plan-start
      // sessions after those cards are fixed and updated.
      if (preset.cardTypes[i] != CardType.weight) continue;
      workoutExercises.add(
        cloneWorkoutExercise(preset.exercises[i], preservePresetSource: true),
      );
      workoutCardTypes.add(preset.cardTypes[i]);
    }
    final started = await activeSession.startWithExercises(
      workoutExercises: workoutExercises,
      workoutCardTypes: workoutCardTypes,
      presetId: preset.presetId,
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).planOngoingWorkoutKept),
        ),
      );
    }

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const SessionScreen()),
    );
  }

  Future<void> _showSwapExercisePicker(PresetSession preset, int index) async {
    final exercise = preset.exercises[index];
    if (exercise is! WeightExercise) return;

    final repo = context.read<AppRepository>();
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
            repository: repo,
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
    final strings = AppLocalizations.of(context);
    final onboardingPlanGuideStep = _buildOnboardingPlanGuideStep();
    final isNamingPlan =
        _showsOnboardingPlanGuide &&
        _onboardingPlanBuilderStep == _OnboardingPlanBuilderStep.namePlan;

    return PopScope<PresetDetailResult>(
      // Disable the system back gesture so we can intercept it
      canPop: false,
      // Called whenever a pop is attempted (back button or gesture)
      onPopInvokedWithResult: (bool didPop, PresetDetailResult? result) async {
        final nav = Navigator.of(context);
        // If it actually popped (unlikely, since canPop is false), do nothing
        if (didPop) return;
        // Otherwise show our unsaved-changes dialog
        final shouldPop = await _onWillPop();
        if (!mounted) return;
        if (shouldPop) {
          nav.pop(widget.closeAfterSave ? PresetDetailResult.discarded : null);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title:
                  _isEditing
                      ? KeyedSubtree(
                        key: _nameTutorialKey,
                        child: TextField(
                          key: AppTestKeys.planName,
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: InputDecoration(
                            border:
                                isNamingPlan
                                    ? UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    )
                                    : InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textInputAction:
                              isNamingPlan ? TextInputAction.next : null,
                          onSubmitted:
                              isNamingPlan
                                  ? (_) => _advanceOnboardingPlanGuide(
                                    _OnboardingPlanBuilderStep.namePlan,
                                  )
                                  : (_) {},
                        ),
                      )
                      : Text(preset.presetName),
              centerTitle: true,
              actions: [
                KeyedSubtree(
                  key: _editTutorialKey,
                  child: IconButton(
                    key: AppTestKeys.planEdit,
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
                      final repository = context.read<AppRepository>();
                      final navigator = Navigator.of(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text(strings.planDeleteTitle),
                              content: Text(strings.planDeleteBody),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(strings.commonCancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(strings.commonDelete),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await repository.deletePreset(preset.presetId);
                        if (mounted) {
                          navigator.pop(
                            widget.closeAfterSave
                                ? PresetDetailResult.deleted
                                : null,
                          );
                        }
                      }
                    } else if (action == 'toggle_auto') {
                      if (preset.isAutomatic) {
                        await preset.disableAutomatic();
                      } else {
                        await preset.enableAutomatic();
                      }
                      if (!mounted) return;
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
                              (_) => AutoPresetFlowScreen(
                                presetId: preset.presetId,
                              ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) {
                    return [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(strings.planDeletePreset),
                      ),
                      PopupMenuItem(
                        value: 'toggle_auto',
                        child: Text(
                          preset.isAutomatic
                              ? strings.planDisableAutomatic
                              : strings.planMakeAutomatic,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        enabled: preset.isAutomatic,
                        child: Text(strings.planAutomaticSettings),
                      ),

                      PopupMenuItem(
                        value: 'flow',
                        enabled: preset.isAutomatic,
                        child: Text(strings.planProgression),
                      ),
                    ];
                  },
                ),
              ],
            ),

            body:
                preset.exercises.isEmpty && !_isEditing
                    ? Center(child: Text(strings.planNoExercises))
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
                                definitionId: preset.definitionIdForExercise(i),
                                readOnlyMode: false,
                                forceCollapsed: _collapseWeightCardsForReorder,
                                initialCompletedParents:
                                    preset.exercises[i] is WeightExercise
                                        ? (preset.exercises[i]
                                                as WeightExercise)
                                            .completedParents
                                        : null,
                                initialCompletedChildren:
                                    preset.exercises[i] is WeightExercise
                                        ? (preset.exercises[i]
                                                as WeightExercise)
                                            .completedChildren
                                        : null,
                                onDetails:
                                    preset.cardTypes[i] == CardType.weight
                                        ? () => _showExerciseDetails(preset, i)
                                        : null,
                                onSwapExercise:
                                    preset.cardTypes[i] == CardType.weight
                                        ? () =>
                                            _showSwapExercisePicker(preset, i)
                                        : null,
                                onDeleteExercise:
                                    () => context
                                        .read<PresetSession>()
                                        .removeExercise(i),
                                onSetAdded: () {
                                  context.read<PresetSession>().refresh();
                                  if (i == 0 &&
                                      _showsOnboardingPlanGuide &&
                                      _onboardingPlanBuilderStep ==
                                          _OnboardingPlanBuilderStep.addSet) {
                                    setState(() {
                                      _onboardingPlanBuilderStep =
                                          _OnboardingPlanBuilderStep.savePlan;
                                    });
                                    _syncOnboardingPlanGuideFocus();
                                  }
                                },
                                onSetDeleted:
                                    () =>
                                        context.read<PresetSession>().refresh(),
                                onValueChanged:
                                    () =>
                                        context.read<PresetSession>().refresh(),
                                firstSetWeightKey:
                                    i == 0 ? _firstSetWeightTutorialKey : null,
                                firstSetRepsKey:
                                    i == 0 ? _firstSetRepsTutorialKey : null,
                                addSetKey: i == 0 ? _addSetTutorialKey : null,
                                firstSetWeightFocusNode:
                                    i == 0 ? _firstSetWeightFocusNode : null,
                                firstSetRepsFocusNode:
                                    i == 0 ? _firstSetRepsFocusNode : null,
                                onFirstSetWeightSubmitted:
                                    i == 0 && _showsOnboardingPlanGuide
                                        ? () => _advanceOnboardingPlanGuide(
                                          _OnboardingPlanBuilderStep
                                              .configureWeight,
                                        )
                                        : null,
                                onFirstSetRepsSubmitted:
                                    i == 0 && _showsOnboardingPlanGuide
                                        ? () => _advanceOnboardingPlanGuide(
                                          _OnboardingPlanBuilderStep
                                              .configureReps,
                                        )
                                        : null,
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
                              repository: context.read<AppRepository>(),
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
                            definitionId: preset.definitionIdForExercise(
                              exerciseIndex,
                            ),
                            readOnlyMode: true,
                            initialCompletedParents:
                                preset.exercises[exerciseIndex]
                                        is WeightExercise
                                    ? (preset.exercises[exerciseIndex]
                                            as WeightExercise)
                                        .completedParents
                                    : null,
                            initialCompletedChildren:
                                preset.exercises[exerciseIndex]
                                        is WeightExercise
                                    ? (preset.exercises[exerciseIndex]
                                            as WeightExercise)
                                        .completedChildren
                                    : null,
                            onDetails:
                                preset.cardTypes[exerciseIndex] ==
                                        CardType.weight
                                    ? () => _showExerciseDetails(
                                      preset,
                                      exerciseIndex,
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),

            floatingActionButton:
                _isEditing
                    ? KeyedSubtree(
                      key: _addExerciseTutorialKey,
                      child: AddExerciseFab(
                        onCatalogSelectionChanged:
                            _showsOnboardingPlanGuide ? (_) {} : null,
                        onCatalogExerciseAdded:
                            _showsOnboardingPlanGuide
                                ? () {
                                  if (!mounted) return;
                                  setState(() {
                                    _onboardingPlanBuilderStep =
                                        _OnboardingPlanBuilderStep
                                            .configureWeight;
                                  });
                                }
                                : null,
                        onCatalogTutorialSkipped:
                            _showsOnboardingPlanGuide
                                ? _skipOnboardingPlanGuide
                                : null,
                        onCatalogClosed:
                            _showsOnboardingPlanGuide
                                ? _syncOnboardingPlanGuideFocus
                                : null,
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
                      ),
                    )
                    : null,

            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: KeyedSubtree(
                  key: _actionTutorialKey,
                  child:
                      _isEditing
                          ? ElevatedButton(
                            key: AppTestKeys.planSave,
                            onPressed: _savePlan,
                            child: Text(strings.planSavePreset),
                          )
                          : ElevatedButton(
                            key: AppTestKeys.planStartSession,
                            onPressed: _startPlanSession,
                            child: Text(strings.planStartSession),
                          ),
                ),
              ),
            ),
          ),
          if (onboardingPlanGuideStep != null)
            InteractiveTutorialOverlay(
              step: onboardingPlanGuideStep,
              onSkip: _skipOnboardingPlanGuide,
            ),
        ],
      ),
    );
  }
}
