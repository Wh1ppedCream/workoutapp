//session_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';

/// Displays and allows editing of a saved workout session.
class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  const SessionDetailScreen(this.session, {super.key});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final _repo = AppRepository();
  List<WorkoutExercise> _exercises = [];
  bool _hasChanges = false;
  bool _isEditing = false;
  late DateFormat _dateFmt;

  @override
  void initState() {
    super.initState();
    _dateFmt = DateFormat('yyyy-MM-dd – HH:mm');
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exRows = await _repo.fetchExercises(widget.session.id);
    final loaded = <WorkoutExercise>[];

    for (var exRow in exRows) {
      final instanceId = exRow['id'] as int;
      final storedType = exRow['type'] as String;

      if (storedType == 'weight') {
        // ─── WEIGHT ───────────────────────────────────────────────
        final defId = exRow['exercise_def_id'] as int?;
        if (defId == null) continue;
        final defInfo = await _repo.fetchDefinitionInfo(defId);
        final name = defInfo['name']!;
        final equipmentName = defInfo['equipmentName'] ?? '';

        // Fetch all sets for this exercise:
        final allSetRows = await _repo.fetchSets(instanceId);
        final parentRows = allSetRows
            .where((r) => r['parent_set_id'] == null)
            .toList();

        final parentSets = <ExerciseSet>[];
        final csetsMap = <int, List<ExerciseSet>>{};
        for (var pIdx = 0; pIdx < parentRows.length; pIdx++) {
          final p = parentRows[pIdx];
          parentSets.add(ExerciseSet(
            weight: (p['weight'] as num).toDouble(),
            reps: p['reps'] as int,
          ));

          // find its children
          final parentId = p['id'] as int;
          final childRows = allSetRows
              .where((r) => r['parent_set_id'] == parentId)
              .toList();
          if (childRows.isNotEmpty) {
            csetsMap[pIdx] = childRows.map((c) {
              return ExerciseSet(
                weight: (c['weight'] as num).toDouble(),
                reps: c['reps'] as int,
              );
            }).toList();
          }
        }

        // mark all as completed when loading detail
        final completedParents = { for (var i = 0; i < parentSets.length; i++) i };
        final completedChildren = <int, Set<int>>{};
        csetsMap.forEach((pIdx, children) {
          completedChildren[pIdx] = { for (var i = 0; i < children.length; i++) i };
        });

        loaded.add(WeightExercise(
          name:             name,
          equipment:        equipmentName,
          sets:             parentSets,
          changeSets:       csetsMap,
          completedParents: completedParents,
          completedChildren: completedChildren,
        ));
      }
      else if (storedType == 'cardio') {
        // ─── CARDIO ────────────────────────────────────────────────
        final cRow = await _repo.fetchCardioDetails(instanceId);
        if (cRow == null) continue;
        loaded.add(CardioExercise(
          name:           cRow['cardio_name']      as String,
          equipment:      '',
          cardioName:     cRow['cardio_name']      as String,
          cardioNote:     cRow['note']             as String?,
          plannedMinutes: (cRow['planned_minutes'] as num).toInt(),
          elapsedSeconds: (cRow['elapsed_seconds'] as num).toInt(),
        ));
      }
      else if (storedType == 'stretch') {
        // ─── STRETCH ────────────────────────────────────────────────
        final itemRows = await _repo.fetchStretchItems(instanceId);

        final items = <Map<String, dynamic>>[];
        final checkedIndices = <int>{};
        for (var idx = 0; idx < itemRows.length; idx++) {
          final r = itemRows[idx];
          final isChecked = (r['is_checked'] as int) == 1;
          items.add({
            'stretch_id':  r['stretch_id']  as int?,
            'is_custom':   (r['is_custom']  as int) == 1,
            'custom_name': r['custom_name'] as String?,
            'custom_desc': r['custom_desc'] as String?,
            'is_checked':  isChecked,
            'order_index': (r['order_index'] as num).toInt(),
          });
          if (isChecked) checkedIndices.add(idx);
        }

        // Determine header name
        String stretchCardName = 'Stretch';
        if (items.isNotEmpty) {
          final first = items.first;
          if (first['stretch_id'] != null) {
            final sdName = await _repo.fetchStretchDefinitionNameById(
              first['stretch_id'] as int,
            );
            if (sdName != null) stretchCardName = sdName;
          } else if (first['is_custom'] == true) {
            stretchCardName = first['custom_name'] as String? ?? 'Stretch';
          }
        }

        loaded.add(StretchExercise(
          name:                    stretchCardName,
          equipment:               '',
          stretchInstances:        items,
          completedStretchIndices: checkedIndices,
        ));
      }
    }

    if (!mounted) return;
    setState(() {
      _exercises = loaded;
      _hasChanges = false;
    });
  }

  /// Deletes the entire session
  Future<void> _deleteSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    await _repo.deleteSession(widget.session.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Saves edits back to the database.
  Future<void> _saveChanges() async {
    // 1) Delete old exercises
    await _repo.deleteExercises(widget.session.id);

    // 2) Re-insert everything
    for (var i = 0; i < _exercises.length; i++) {
      final we = _exercises[i];
      int? defId;
      if (we is WeightExercise) {
        defId = await _repo.findOrCreateExerciseDefinition(we.name, we.equipment);
      }

      final exId = await _repo.addExerciseRow(
        sessionId:      widget.session.id,
        exerciseDefId:  defId,
        type:           we is WeightExercise ? 'weight' :
                        we is CardioExercise ? 'cardio' : 'stretch',
        orderIndex:     i,
      );

      if (we is WeightExercise) {
        await _repo.addWeightSets(
          exerciseId:      exId,
          parentSets:      we.sets,
          childChangeSets: we.changeSets,
        );
      } else if (we is CardioExercise) {
        await _repo.saveCardioDetails(
          exerciseId:     exId,
          cardioName:     we.cardioName,
          note:           we.cardioNote,
          plannedMinutes: we.plannedMinutes,
          elapsedSeconds: we.elapsedSeconds,
        );
      } else if (we is StretchExercise) {
        await _repo.saveStretchInstance(
          exerciseId: exId,
          items:       we.stretchInstances,
        );
      }
    }

    if (!mounted) return;
    setState(() => _hasChanges = false);

    // Safe to use context here after mounted check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved!')),
    );
  }

  /// Warns if there are unsaved changes.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them and leave?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _dateFmt.format(widget.session.date);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _onWillPop();
        if (!mounted) {
          return;
        }
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child:  Scaffold(
        appBar: AppBar(
          title: Text(dateStr),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: _isEditing ? Colors.green : Colors.grey),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _deleteSession,
            ),
          ],
        ),
        body: _exercises.isEmpty
            ? const Center(child: Text('No exercises in this session.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length,
                itemBuilder: (_, i) {
                  final we = _exercises[i];
                  final cardType = we is WeightExercise
                      ? CardType.weight
                      : we is CardioExercise
                          ? CardType.cardio
                          : CardType.stretch;
                  return ExerciseCard(
                    key: ValueKey(i),
                    exercise: we,
                    cardType: cardType,
                    readOnlyMode: !_isEditing,
                    initialCompletedParents: we is WeightExercise ? we.completedParents : null,
                    initialCompletedChildren: we is WeightExercise ? we.completedChildren : null,
                    onDeleteExercise: _isEditing
                        ? () {
                            setState(() {
                              _exercises.removeAt(i);
                              _hasChanges = true;
                            });
                          }
                        : null,
                    onSetAdded: _isEditing ? () => setState(() => _hasChanges = true) : null,
                    onSetDeleted: _isEditing ? () => setState(() => _hasChanges = true) : null,
                    onValueChanged: _isEditing ? () => setState(() => _hasChanges = true) : null,
                  );
                },
              ),
        bottomNavigationBar: _hasChanges
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              )
            : null,
      ),
    );
  }
}
