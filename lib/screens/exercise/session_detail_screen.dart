// File: lib/screens/exercise/session_detail_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/active_session.dart';
import '../../providers/selected_profile.dart';
import '../../providers/unit_preference_provider.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/theme_extensions.dart';
import '../../utils/async_pool.dart';
import '../../utils/tutorial_launcher.dart';
import '../../utils/weight_unit_formatter.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/exercise_detail_sheet.dart';
import '../../widgets/focused_sets_list.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import 'session_screen.dart';

/// Displays a saved workout session with summary, exercise detail, and reuse
/// actions.
///
/// This screen reconstructs typed exercise models from persisted session rows
/// so users can review, edit, start the workout again, or save it as a preset.
/// Expensive definition/bodypart work is concurrency-limited to keep large
/// sessions responsive.
class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;

  const SessionDetailScreen(this.session, {super.key});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  static const int _exerciseLoadConcurrency = 6;
  static const int _bodyPartSummaryConcurrency = 6;

  final _repo = AppRepository();
  final _dateFmt = DateFormat('MMM d, yyyy - h:mm a');
  final _editTutorialKey = GlobalKey(debugLabel: 'workout_detail_edit');
  final _summaryTutorialKey = GlobalKey(debugLabel: 'workout_detail_summary');
  final _exerciseTutorialKey = GlobalKey(debugLabel: 'workout_detail_exercise');
  final _actionsTutorialKey = GlobalKey(debugLabel: 'workout_detail_actions');

  List<_SessionExerciseDetail> _exerciseDetails = [];
  _SessionSummary? _summary;
  Object? _loadError;
  bool _isLoading = true;
  bool _hasChanges = false;
  bool _isEditing = false;
  bool _isStartingWorkout = false;
  bool _isSavingPreset = false;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    unawaited(BodyHeatmap.preload());
    _loadExercises();
  }

  /// Loads persisted session rows into UI-ready exercise details and summary
  /// data in one pass.
  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final exRows = await _repo.fetchExercises(widget.session.id);
      final loaded = await _loadExerciseDetails(exRows);

      final summary = await _buildSummary(loaded);
      if (!mounted) return;
      setState(() {
        _exerciseDetails = loaded;
        _summary = summary;
        _hasChanges = false;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueTutorial();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<List<_SessionExerciseDetail>> _loadExerciseDetails(
    List<Map<String, dynamic>> exRows,
  ) async {
    final results =
        await mapWithConcurrency<Map<String, dynamic>, _SessionExerciseDetail?>(
          exRows,
          maxConcurrency: _exerciseLoadConcurrency,
          mapper: (exRow, _) async {
            final instanceId = exRow['id'] as int;
            final storedType = exRow['type'] as String;

            if (storedType == 'weight') {
              return await _loadWeightExercise(exRow, instanceId);
            }
            if (storedType == 'cardio') {
              return await _loadCardioExercise(instanceId);
            }
            if (storedType == 'stretch') {
              return await _loadStretchExercise(instanceId);
            }
            return null;
          },
        );
    return results.whereType<_SessionExerciseDetail>().toList();
  }

  Future<_SessionExerciseDetail?> _loadWeightExercise(
    Map<String, dynamic> exRow,
    int instanceId,
  ) async {
    final defId = exRow['exercise_def_id'] as int?;
    if (defId == null) return null;

    final defInfoFuture = _repo.fetchDefinitionInfo(defId);
    final allSetRowsFuture = _repo.fetchSets(instanceId);
    final defInfo = await defInfoFuture;
    final name = defInfo['name'] ?? 'Exercise';
    final equipmentName = defInfo['equipmentName'] ?? '';
    final allSetRows = await allSetRowsFuture;
    final parentRows =
        allSetRows.where((r) => r['parent_set_id'] == null).toList();
    final childRowsByParentId = <int, List<Map<String, dynamic>>>{};
    for (final row in allSetRows) {
      final parentId = row['parent_set_id'] as int?;
      if (parentId == null) continue;
      childRowsByParentId
          .putIfAbsent(parentId, () => <Map<String, dynamic>>[])
          .add(row);
    }
    final parentSets = <ExerciseSet>[];
    final changeSets = <int, List<ExerciseSet>>{};

    for (var parentIndex = 0; parentIndex < parentRows.length; parentIndex++) {
      final parent = parentRows[parentIndex];
      parentSets.add(
        ExerciseSet(
          weight: (parent['weight'] as num).toDouble(),
          reps: (parent['reps'] as num).toInt(),
        ),
      );

      final parentId = parent['id'] as int;
      final childRows =
          childRowsByParentId[parentId] ?? const <Map<String, dynamic>>[];
      if (childRows.isNotEmpty) {
        changeSets[parentIndex] =
            childRows
                .map(
                  (child) => ExerciseSet(
                    weight: (child['weight'] as num).toDouble(),
                    reps: (child['reps'] as num).toInt(),
                  ),
                )
                .toList();
      }
    }

    final completedParents = {for (var i = 0; i < parentSets.length; i++) i};
    final completedChildren = <int, Set<int>>{};
    changeSets.forEach((parentIndex, children) {
      completedChildren[parentIndex] = {
        for (var i = 0; i < children.length; i++) i,
      };
    });

    return _SessionExerciseDetail(
      exercise: WeightExercise(
        name: name,
        equipment: equipmentName,
        sets: parentSets,
        changeSets: changeSets,
        completedParents: completedParents,
        completedChildren: completedChildren,
      ),
      cardType: CardType.weight,
      definitionId: defId,
    );
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
        tutorialId: TutorialIds.workoutDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _summaryTutorialKey,
            icon: Icons.insights,
            title: 'Workout summary',
            body:
                'Review total sets, volume, duration, exercise count, and the bodyparts this workout hit.',
          ),
          GuidedTutorialStep(
            targetKey: _exerciseTutorialKey,
            icon: Icons.fitness_center,
            title: 'Exercise records',
            body:
                'Each exercise shows the completed sets from that session. Tap details to inspect the exercise.',
          ),
          GuidedTutorialStep(
            targetKey: _editTutorialKey,
            icon: Icons.edit,
            title: 'Edit session',
            body:
                'Use edit mode if you need to correct sets, reps, or exercises after the workout.',
          ),
          GuidedTutorialStep(
            targetKey: _actionsTutorialKey,
            icon: Icons.replay,
            title: 'Reuse this workout',
            body:
                'Do the workout again or save the completed session as a reusable plan.',
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<_SessionExerciseDetail?> _loadCardioExercise(int instanceId) async {
    final row = await _repo.fetchCardioDetails(instanceId);
    if (row == null) return null;

    return _SessionExerciseDetail(
      exercise: CardioExercise(
        name: row['cardio_name'] as String,
        equipment: '',
        cardioName: row['cardio_name'] as String,
        cardioNote: row['note'] as String?,
        plannedMinutes: (row['planned_minutes'] as num).toInt(),
        elapsedSeconds: (row['elapsed_seconds'] as num).toInt(),
      ),
      cardType: CardType.cardio,
    );
  }

  Future<_SessionExerciseDetail?> _loadStretchExercise(int instanceId) async {
    final itemRows = await _repo.fetchStretchItems(instanceId);
    final instances = <StretchInstance>[];
    final completed = <int>{};

    for (var i = 0; i < itemRows.length; i++) {
      final instance = StretchInstance.fromMap(itemRows[i]);
      instances.add(instance);
      if (instance.isChecked) completed.add(i);
    }

    var stretchName = 'Stretch';
    if (instances.isNotEmpty) {
      final first = instances.first;
      if (first.stretchId != null) {
        stretchName =
            await _repo.fetchStretchDefinitionNameById(first.stretchId!) ??
            stretchName;
      } else if (first.isCustom) {
        stretchName = first.customName ?? stretchName;
      }
    }

    return _SessionExerciseDetail(
      exercise: StretchExercise(
        name: stretchName,
        equipment: '',
        stretchInstances: instances,
        completedStretchIndices: completed,
      ),
      cardType: CardType.stretch,
    );
  }

  Future<_SessionSummary> _buildSummary(
    List<_SessionExerciseDetail> details,
  ) async {
    var totalVolume = 0.0;
    var totalSets = 0;
    var exerciseCount = 0;
    final bodyPartById = <int, BodyPart>{};
    final bodyPartUnitsById = <int, double>{};
    final setsPerDefinition = <int, int>{};

    for (final detail in details) {
      final exercise = detail.exercise;
      // TODO(cardio/stretch): include cardio and stretch in session summaries
      // after those cards are fixed, updated, and added back into the app.
      if (exercise is! WeightExercise) continue;
      exerciseCount++;

      final sets = _allWeightSets(exercise);
      totalSets += sets.length;
      for (final set in sets) {
        totalVolume += set.weight * set.reps;
      }

      final defId = detail.definitionId;
      if (defId == null || sets.isEmpty) continue;
      setsPerDefinition.update(
        defId,
        (count) => count + sets.length,
        ifAbsent: () => sets.length,
      );
    }

    final bodyPartUnits = await _loadSummaryBodyPartUnits(
      setsPerDefinition.keys.toList(),
    );

    for (final entry in bodyPartUnits) {
      final unitsPerSet = entry.value;
      final setCount = setsPerDefinition[entry.key] ?? 0;
      if (setCount <= 0) continue;
      unitsPerSet.forEach((bodyPart, units) {
        if (units <= 0.0) return;
        bodyPartById[bodyPart.id] = bodyPart;
        bodyPartUnitsById[bodyPart.id] =
            (bodyPartUnitsById[bodyPart.id] ?? 0.0) + units * setCount;
      });
    }

    final bodyPartHits =
        bodyPartUnitsById.entries
            .map(
              (entry) => FocusedSetHit(
                bodyPart: bodyPartById[entry.key]!,
                units: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    final maxUnits = bodyPartHits.fold<double>(
      0.0,
      (max, hit) => hit.units > max ? hit.units : max,
    );
    final frequencyMap = <String, double>{};
    for (final hit in bodyPartHits) {
      final ids = bodyPartNameToSvgIds[hit.bodyPart.name] ?? const <String>[];
      final normalized = maxUnits == 0.0 ? 0.0 : hit.units / maxUnits;
      for (final id in ids) {
        frequencyMap[id] = normalized;
      }
    }

    return _SessionSummary(
      totalVolume: totalVolume,
      totalSets: totalSets,
      exerciseCount: exerciseCount,
      bodyPartHits: bodyPartHits,
      frequencyMap: frequencyMap,
    );
  }

  Future<List<MapEntry<int, Map<BodyPart, double>>>> _loadSummaryBodyPartUnits(
    List<int> definitionIds,
  ) {
    return mapWithConcurrency<int, MapEntry<int, Map<BodyPart, double>>>(
      definitionIds,
      maxConcurrency: _bodyPartSummaryConcurrency,
      mapper:
          (defId, _) async =>
              MapEntry(defId, await _repo.computeBodyPartPercents(defId)),
    );
  }

  Future<void> _deleteSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Session'),
            content: const Text(
              'Are you sure you want to delete this session?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    await _repo.deleteSession(widget.session.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _saveChanges() async {
    await _repo.deleteExercises(widget.session.id);

    for (var i = 0; i < _exerciseDetails.length; i++) {
      final detail = _exerciseDetails[i];
      final exercise = detail.exercise;

      int? defId;
      if (exercise is WeightExercise) {
        defId =
            detail.definitionId ??
            await _repo.findOrCreateExerciseDefinition(
              exercise.name,
              exercise.equipment,
            );
      }

      final exerciseId = await _repo.addExerciseRow(
        sessionId: widget.session.id,
        exerciseDefId: defId,
        type: _typeName(detail.cardType),
        orderIndex: i,
      );

      await _saveExerciseDetails(exerciseId, exercise, forPreset: false);
    }

    final summary = await _buildSummary(_exerciseDetails);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _hasChanges = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes saved.')));
  }

  Future<void> _startWorkoutAgain() async {
    final active = context.read<ActiveSession>();
    if (active.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish your current workout before repeating this one.',
          ),
        ),
      );
      return;
    }

    setState(() => _isStartingWorkout = true);
    var started = false;
    try {
      active.exercises.clear();
      active.cardTypes.clear();

      for (final detail in _exerciseDetails) {
        // TODO(cardio/stretch): repeat cardio and stretch once those cards are
        // fixed, updated, and added back into active workout sessions.
        if (detail.cardType != CardType.weight) continue;
        active.addExercise(_cloneExercise(detail.exercise), detail.cardType);
      }
      active.start();
      started = true;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not repeat workout: $error')),
      );
    } finally {
      if (mounted) setState(() => _isStartingWorkout = false);
    }

    if (!started || !mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
  }

  Future<void> _saveAsPreset() async {
    final defaultName = _defaultPresetName();
    final controller = TextEditingController(text: defaultName);
    final name = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save as Preset'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Preset name'),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => Navigator.pop(context, value.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    if (!mounted) return;

    setState(() => _isSavingPreset = true);
    int? createdPresetId;
    var presetFinished = false;
    try {
      final profileId = context.read<SelectedProfile>().currentProfile?.id;
      final presetName = await _uniquePresetName(name.trim(), profileId);
      final presetId = await _repo.createPreset(
        presetName,
        profileId: profileId,
      );
      createdPresetId = presetId;

      for (var i = 0; i < _exerciseDetails.length; i++) {
        final detail = _exerciseDetails[i];
        // TODO(cardio/stretch): copy cardio and stretch into saved plans after
        // those cards are fixed, updated, and added back into plan screens.
        if (detail.cardType != CardType.weight) continue;
        final exercise = detail.exercise;
        int? defId;
        if (exercise is WeightExercise) {
          defId =
              detail.definitionId ??
              await _repo.findOrCreateExerciseDefinition(
                exercise.name,
                exercise.equipment,
              );
        }

        final presetExerciseId = await _repo.addExerciseToPreset(
          presetId,
          defId,
          _typeName(detail.cardType),
          i,
        );
        await _saveExerciseDetails(presetExerciseId, exercise, forPreset: true);
      }

      presetFinished = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "$presetName" as a preset.')),
      );
    } catch (error) {
      if (createdPresetId != null && !presetFinished) {
        try {
          await _repo.deletePreset(createdPresetId);
        } catch (_) {
          // Best-effort cleanup so a failed copy does not leave a partial preset.
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save preset: $error')));
    } finally {
      if (mounted) setState(() => _isSavingPreset = false);
    }
  }

  Future<void> _saveExerciseDetails(
    int rowId,
    WorkoutExercise exercise, {
    required bool forPreset,
  }) async {
    if (exercise is WeightExercise) {
      if (forPreset) {
        await _repo.savePresetWeightSets(
          rowId,
          _cloneSets(exercise.sets),
          _cloneChangeSets(exercise.changeSets),
        );
      } else {
        await _repo.addWeightSets(
          exerciseId: rowId,
          parentSets: _cloneSets(exercise.sets),
          childChangeSets: _cloneChangeSets(exercise.changeSets),
        );
      }
    } else if (exercise is CardioExercise) {
      final plannedMinutes =
          exercise.plannedMinutes > 0
              ? exercise.plannedMinutes
              : (exercise.elapsedSeconds / 60).ceil();
      if (forPreset) {
        await _repo.savePresetCardio(
          rowId,
          exercise.cardioName,
          exercise.cardioNote,
          plannedMinutes,
          0,
        );
      } else {
        await _repo.saveCardioDetails(
          exerciseId: rowId,
          cardioName: exercise.cardioName,
          note: exercise.cardioNote,
          plannedMinutes: exercise.plannedMinutes,
          elapsedSeconds: exercise.elapsedSeconds,
        );
      }
    } else if (exercise is StretchExercise) {
      final items =
          exercise.stretchInstances.map((inst) => inst.toMap()).toList();
      if (forPreset) {
        await _repo.savePresetStretch(rowId, items);
      } else {
        await _repo.saveStretchInstance(exerciseId: rowId, items: items);
      }
    }
  }

  Future<String> _uniquePresetName(String baseName, int? profileId) async {
    final existingRows = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final existingNames = {
      for (final row in existingRows) (row['name'] as String).trim(),
    };
    if (!existingNames.contains(baseName)) return baseName;

    var copyNumber = 2;
    while (existingNames.contains('$baseName ($copyNumber)')) {
      copyNumber++;
    }
    return '$baseName ($copyNumber)';
  }

  String _defaultPresetName() {
    final focusNames =
        (_summary?.bodyPartHits ?? const <FocusedSetHit>[])
            .take(2)
            .map((hit) => hit.bodyPart.name)
            .toList();
    if (focusNames.isNotEmpty) return focusNames.join(', ');
    return 'Workout ${DateFormat('MMM d').format(widget.session.date)}';
  }

  Future<void> _showExerciseInfo(_SessionExerciseDetail detail) async {
    if (detail.exercise is! WeightExercise) return;
    final exercise = detail.exercise as WeightExercise;
    final defId =
        detail.definitionId ??
        await _repo.findOrCreateExerciseDefinition(
          exercise.name,
          exercise.equipment,
        );
    final definition = await _repo.fetchDefinitionById(defId);
    if (!mounted || definition == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExerciseDetailSheet(definition: definition, defId: defId),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them and leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (!context.mounted) return;
        if (shouldPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Detail'),
          actions: [
            IconButton(
              tooltip: _isEditing ? 'Stop editing' : 'Edit session',
              icon: KeyedSubtree(
                key: _editTutorialKey,
                child: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: _isEditing ? Colors.green : null,
                ),
              ),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
            IconButton(
              tooltip: 'Delete session',
              icon: const Icon(Icons.delete_forever),
              onPressed: _deleteSession,
            ),
          ],
        ),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(child: Text('Error loading session: $_loadError'));
    }
    if (_exerciseDetails.isEmpty) {
      return const Center(child: Text('No exercises in this session.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        KeyedSubtree(
          key: _summaryTutorialKey,
          child: _SessionSummaryCard(
            session: widget.session,
            summary: _summary!,
            dateText: _dateFmt.format(widget.session.date),
          ),
        ),
        const SizedBox(height: 12),
        if (_isEditing)
          ..._buildEditableExerciseCards()
        else
          ...List.generate(_exerciseDetails.length, (index) {
            final detail = _exerciseDetails[index];
            return KeyedSubtree(
              key: index == 0 ? _exerciseTutorialKey : null,
              child: _CompletedExerciseCard(
                detail: detail,
                onDetails:
                    detail.cardType == CardType.weight
                        ? () => _showExerciseInfo(detail)
                        : null,
              ),
            );
          }),
        const SizedBox(height: 88),
      ],
    );
  }

  List<Widget> _buildEditableExerciseCards() {
    return List.generate(_exerciseDetails.length, (index) {
      final detail = _exerciseDetails[index];
      return KeyedSubtree(
        key: index == 0 ? _exerciseTutorialKey : null,
        child: ExerciseCard(
          key: ValueKey('session-detail-$index-${detail.exercise.name}'),
          exercise: detail.exercise,
          cardType: detail.cardType,
          readOnlyMode: false,
          initialCompletedParents:
              detail.exercise is WeightExercise
                  ? (detail.exercise as WeightExercise).completedParents
                  : null,
          initialCompletedChildren:
              detail.exercise is WeightExercise
                  ? (detail.exercise as WeightExercise).completedChildren
                  : null,
          onDetails:
              detail.cardType == CardType.weight
                  ? () => _showExerciseInfo(detail)
                  : null,
          onDeleteExercise: () {
            setState(() {
              _exerciseDetails.removeAt(index);
              _hasChanges = true;
            });
          },
          onSetAdded: () => setState(() => _hasChanges = true),
          onSetDeleted: () => setState(() => _hasChanges = true),
          onValueChanged: () => setState(() => _hasChanges = true),
        ),
      );
    });
  }

  Widget? _buildBottomBar(BuildContext context) {
    if (_isLoading || _loadError != null) {
      return null;
    }

    if (_hasChanges) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: KeyedSubtree(
            key: _actionsTutorialKey,
            child: FilledButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ),
        ),
      );
    }

    if (_exerciseDetails.isEmpty) {
      return null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: KeyedSubtree(
          key: _actionsTutorialKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isStartingWorkout ? null : _startWorkoutAgain,
                  icon:
                      _isStartingWorkout
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.replay),
                  label: const Text('Do Workout Again'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSavingPreset ? null : _saveAsPreset,
                  icon:
                      _isSavingPreset
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save as Preset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  final WorkoutSession session;
  final _SessionSummary summary;
  final String dateText;

  const _SessionSummaryCard({
    required this.session,
    required this.summary,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final durationText = _formatDuration(Duration(seconds: session.duration));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Past Workout',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.totalSets} completed sets',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Volume',
                    value: WeightUnitFormatter.formatVolume(
                      summary.totalVolume,
                      weightUnit,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Duration',
                    value: durationText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Exercises',
                    value: summary.exerciseCount.toString(),
                  ),
                ),
              ],
            ),
            if (summary.bodyPartHits.isNotEmpty) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final gap = maxWidth < 330 ? 10.0 : 16.0;
                  final heatmapWidth =
                      (maxWidth * 0.46).clamp(124.0, 180.0).toDouble();
                  final heatmapSize =
                      heatmapWidth.clamp(118.0, 180.0).toDouble();
                  final heatmap = SizedBox(
                    width: heatmapWidth,
                    height: heatmapSize,
                    child: Center(
                      child: BodyHeatmap(
                        frequencyMap: summary.frequencyMap,
                        lowColor: colors.historySummaryHeatmapLow!,
                        highColor: colors.historySummaryHeatmapHigh!,
                        width: heatmapSize,
                        height: heatmapSize,
                      ),
                    ),
                  );
                  final focusList = FocusedSetsList(
                    hits: summary.bodyPartHits,
                    titleWeight: FontWeight.w800,
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heatmap,
                      SizedBox(width: gap),
                      Expanded(child: focusList),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedExerciseCard extends StatelessWidget {
  final _SessionExerciseDetail detail;
  final VoidCallback? onDetails;

  const _CompletedExerciseCard({required this.detail, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final exercise = detail.exercise;
    if (exercise is WeightExercise) {
      return _CompletedWeightCard(exercise: exercise, onDetails: onDetails);
    }
    // TODO(cardio/stretch): restore completed cardio and stretch detail cards
    // after those cards are fixed, updated, and ready for the user flow.
    return const SizedBox.shrink();
  }
}

class _CompletedWeightCard extends StatelessWidget {
  final WeightExercise exercise;
  final VoidCallback? onDetails;

  const _CompletedWeightCard({required this.exercise, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final rows = _setRows(exercise);
    final bestIndex = _bestSetIndex(rows);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exerciseTitle(exercise),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (exercise.equipment.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          exercise.equipment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDetails != null)
                  IconButton(
                    tooltip: 'Exercise info',
                    onPressed: onDetails,
                    icon: const Icon(Icons.info_outline),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 6),
            for (var i = 0; i < rows.length; i++)
              _CompletedSetRow(row: rows[i], isBest: i == bestIndex),
          ],
        ),
      ),
    );
  }

  static String _exerciseTitle(WeightExercise exercise) {
    return exercise.name;
  }

  static List<_SetDisplayRow> _setRows(WeightExercise exercise) {
    final rows = <_SetDisplayRow>[];
    for (var i = 0; i < exercise.sets.length; i++) {
      rows.add(_SetDisplayRow(label: '${i + 1}', set: exercise.sets[i]));
      final childSets = exercise.changeSets[i] ?? const <ExerciseSet>[];
      for (var childIndex = 0; childIndex < childSets.length; childIndex++) {
        rows.add(
          _SetDisplayRow(
            label: '${i + 1}${String.fromCharCode(97 + childIndex)}',
            set: childSets[childIndex],
            isChild: true,
          ),
        );
      }
    }
    return rows;
  }

  static int _bestSetIndex(List<_SetDisplayRow> rows) {
    var bestIndex = -1;
    var bestErm = 0.0;
    for (var i = 0; i < rows.length; i++) {
      final erm = _epley(rows[i].set);
      if (erm > bestErm) {
        bestErm = erm;
        bestIndex = i;
      }
    }
    return bestIndex;
  }
}

class _CompletedSetRow extends StatelessWidget {
  final _SetDisplayRow row;
  final bool isBest;

  const _CompletedSetRow({required this.row, required this.isBest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eRm = _epley(row.set);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return Padding(
      padding: EdgeInsets.only(left: row.isChild ? 22 : 0, top: 7, bottom: 7),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              row.label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${WeightUnitFormatter.formatWeight(row.set.weight, weightUnit)} x ${row.set.reps}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (isBest && eRm > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Best',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              '1RM = ${WeightUnitFormatter.formatWeight(eRm, weightUnit)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Typed exercise plus metadata needed by the detail screen.
class _SessionExerciseDetail {
  final WorkoutExercise exercise;
  final CardType cardType;
  final int? definitionId;

  const _SessionExerciseDetail({
    required this.exercise,
    required this.cardType,
    this.definitionId,
  });
}

/// Aggregated session metrics used by the summary card and heatmap.
class _SessionSummary {
  final double totalVolume;
  final int totalSets;
  final int exerciseCount;
  final List<FocusedSetHit> bodyPartHits;
  final Map<String, double> frequencyMap;

  const _SessionSummary({
    required this.totalVolume,
    required this.totalSets,
    required this.exerciseCount,
    required this.bodyPartHits,
    required this.frequencyMap,
  });
}

class _SetDisplayRow {
  final String label;
  final ExerciseSet set;
  final bool isChild;

  const _SetDisplayRow({
    required this.label,
    required this.set,
    this.isChild = false,
  });
}

WorkoutExercise _cloneExercise(WorkoutExercise exercise) {
  if (exercise is WeightExercise) {
    return WeightExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      sets: _cloneSets(exercise.sets),
      changeSets: _cloneChangeSets(exercise.changeSets),
    );
  }
  if (exercise is CardioExercise) {
    return CardioExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      cardioName: exercise.cardioName,
      cardioNote: exercise.cardioNote,
      plannedMinutes:
          exercise.plannedMinutes > 0
              ? exercise.plannedMinutes
              : (exercise.elapsedSeconds / 60).ceil(),
      elapsedSeconds: 0,
    );
  }
  if (exercise is StretchExercise) {
    return StretchExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      stretchInstances:
          exercise.stretchInstances
              .map(
                (instance) => StretchInstance(
                  stretchId: instance.stretchId,
                  isCustom: instance.isCustom,
                  customName: instance.customName,
                  customDesc: instance.customDesc,
                  isChecked: false,
                  orderIndex: instance.orderIndex,
                ),
              )
              .toList(),
    );
  }
  return exercise;
}

List<ExerciseSet> _cloneSets(List<ExerciseSet> sets) {
  return sets
      .map((set) => ExerciseSet(weight: set.weight, reps: set.reps))
      .toList();
}

Map<int, List<ExerciseSet>> _cloneChangeSets(
  Map<int, List<ExerciseSet>> changeSets,
) {
  return {
    for (final entry in changeSets.entries) entry.key: _cloneSets(entry.value),
  };
}

List<ExerciseSet> _allWeightSets(WeightExercise exercise) {
  return [
    ...exercise.sets,
    for (final childSets in exercise.changeSets.values) ...childSets,
  ];
}

String _typeName(CardType type) {
  switch (type) {
    case CardType.weight:
      return 'weight';
    case CardType.cardio:
      return 'cardio';
    case CardType.stretch:
      return 'stretch';
  }
}

double _epley(ExerciseSet set) {
  return set.weight * (1 + 0.0333 * set.reps);
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  return '${seconds}s';
}
