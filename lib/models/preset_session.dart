import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../repositories/app_repository_presets.dart';
import '../widgets/exercise_card.dart'; // for CardType

/// ChangeNotifier driving the Preset detail/edit UI, mirroring ActiveSession.
class PresetSession extends ChangeNotifier {
  final int presetId;
  final _repo = AppRepository();

  /// Preset's current name, loaded from the definition.
    String presetName = '';

  /// In-memory list of exercises and their types.
  final List<WorkoutExercise> exercises = [];
  final List<CardType> cardTypes = [];

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  PresetSession(this.presetId) {
    _loadPreset();
  }

  /// Loads the preset definition and all child details.
  Future<void> _loadPreset() async {
    final def = await _repo.fetchPresetById(presetId);
    presetName = def?.name ?? '';

    exercises.clear();
    cardTypes.clear();

    final rawRows = await _repo.fetchPresetExercises(presetId);
    for (var row in rawRows) {
      final exId = row['id'] as int;
      final type = row['type'] as String;

      if (type == 'weight') {
  // 1) fetch definition info
  final defId = row['exercise_def_id'] as int?;
  final info = defId != null
      ? await _repo.fetchDefinitionInfo(defId)
      : {'name': '', 'equipment': ''};
  final name = info['name'] ?? '';
  final equipment = info['equipment'] ?? '';

  // 2) pull all rows, group parents vs. children
  final rawSets   = await _repo.fetchPresetSets(exId);
  final parentRows= rawSets.where((r) => r['parent_set_id'] == null).toList();
  final parents   = <ExerciseSet>[];
  final changeSets= <int, List<ExerciseSet>>{};

  // build parent list
  for (var i = 0; i < parentRows.length; i++) {
    final r = parentRows[i];
    parents.add(ExerciseSet(
      weight: (r['weight'] as num).toDouble(),
      reps:   r['reps']   as int,
    ));
  }

  // assign each child row to its parent index
  for (var r in rawSets.where((r) => r['parent_set_id'] != null)) {
    final pid   = r['parent_set_id'] as int;
    final pIndex= parentRows.indexWhere((pr) => pr['id'] == pid);
    if (pIndex == -1) continue; // skip orphaned child
    changeSets[pIndex] ??= [];
    changeSets[pIndex]!.add(ExerciseSet(
      weight: (r['weight'] as num).toDouble(),
      reps:   r['reps']   as int,
    ));
  }

  // finally add into our in-memory list
  exercises.add(WeightExercise(
    name:       name,
    equipment:  equipment,
    sets:       parents,
    changeSets: changeSets,
  ));
  cardTypes.add(CardType.weight);
}
 else if (type == 'cardio') {
        final c = await _repo.fetchPresetCardio(exId);
        if (c != null) {
          exercises.add(CardioExercise(
            name: c['cardio_name'] as String,
            equipment: '',
            cardioName: c['cardio_name'] as String,
            cardioNote: c['note'] as String?,
            plannedMinutes: (c['planned_minutes'] as num).toInt(),
            elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
          ));
          cardTypes.add(CardType.cardio);
        }
      } else if (type == 'stretch') {
        final rawItems = await _repo.fetchPresetStretchItems(exId);
        final items = rawItems.map((r) {
          return <String, dynamic>{
            'stretch_id':  r['stretch_id'] as int?,
            'is_custom':   (r['is_custom'] as int) == 1,
            'custom_name': r['custom_name'] as String?,
            'custom_desc': r['custom_desc'] as String?,
            'order_index': (r['order_index'] as num).toInt(),
            // presets have no "completed" info
            'is_checked':  false,
          };
        }).toList();
        final completed = <int>{};

        // determine header
        String stretchName = 'Stretch';
        if (items.isNotEmpty) {
          final first = items.first;
          if (first['stretch_id'] != null) {
            final dn = await _repo.fetchStretchDefinitionNameById(
              first['stretch_id'] as int,
            );
            if (dn != null) stretchName = dn;
          } else if (first['is_custom'] == true) {
            stretchName = first['custom_name'] as String? ?? 'Stretch';
          }
        }

        exercises.add(StretchExercise(
          name:                    stretchName,
          equipment:               '',
          stretchInstances:        items,
          completedStretchIndices: completed,
        ));
        cardTypes.add(CardType.stretch);
      }
    }

    _hasChanges = false;
    notifyListeners();
  }

  /// Mirrors ActiveSession.addExercise.
  void addExercise(WorkoutExercise ex, CardType type) {
    exercises.add(ex);
    cardTypes.add(type);
    _hasChanges = true;
    notifyListeners();
  }

  /// Mirrors ActiveSession.removeExercise.
  void removeExercise(int index) {
    exercises.removeAt(index);
    cardTypes.removeAt(index);
    _hasChanges = true;
    notifyListeners();
  }

  /// Marks in-memory state dirty without modifying lists.
  void refresh() {
    _hasChanges = true;
    notifyListeners();
  }

  /// Updates the preset definition's name.
  Future<void> updateName(String newName) async {
    await _repo.updatePresetName(presetId, newName);
    presetName = newName;
    notifyListeners();
  }

  /// Persists all in-memory exercises back to the preset tables.
  Future<void> saveChanges() async {
    await _repo.deletePresetExercises(presetId);
    for (var i = 0; i < exercises.length; i++) {
      final we = exercises[i];
      int? defId;
      if (we is WeightExercise) {
        defId = await _repo.findOrCreateExerciseDefinition(we.name, we.equipment);
      }
      final newId = await _repo.addExerciseToPreset(
        presetId,
        defId,
        we is WeightExercise ? 'weight' : we is CardioExercise ? 'cardio' : 'stretch',
        i,
      );
      if (we is WeightExercise) {
        await _repo.savePresetWeightSets(newId, we.sets, we.changeSets);
      } else if (we is CardioExercise) {
        await _repo.savePresetCardio(
          newId,
          we.cardioName,
          we.cardioNote,
          we.plannedMinutes,
          we.elapsedSeconds,
        );
      } else if (we is StretchExercise) {
        await _repo.savePresetStretch(newId, we.stretchInstances);
      }
    }

    _hasChanges = false;
    notifyListeners();
  }

  /// Starts a live session by writing this preset's exercises into the session tables.
Future<int> startSession() async {
  // 1) Create the session row
  final nowIso   = DateTime.now().toIso8601String();
  final sessionId = await _repo.createSession(nowIso, 0);

  // 2) Persist each in-memory exercise
  for (var i = 0; i < exercises.length; i++) {
    final we = exercises[i];

    // Ensure a definition exists for this exercise (never null)
    final defId = await _repo.findOrCreateExerciseDefinition(we.name, we.equipment);

    // Insert the exercise row—
    // now exercise_def_id is always non-null
    final exId = await _repo.addExerciseRow(
      sessionId:      sessionId,
      exerciseDefId:  defId,
      type:           we is WeightExercise
                       ? 'weight'
                       : we is CardioExercise
                         ? 'cardio'
                         : 'stretch',
      orderIndex:     i,
    );

    // And insert its details just like ActiveSession.finish()
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

  return sessionId;
}

}
