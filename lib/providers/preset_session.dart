// File: lib/providers/preset_session.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../widgets/exercise_card.dart'; // for CardType

/// ChangeNotifier driving the Preset detail/edit UI, with Automatic Preset support.
class PresetSession extends ChangeNotifier {
  final int presetId;
  final _repo = AppRepository();

  /// Preset's current name, loaded from the definition.
  String presetName = '';

  // ─── Automatic Preset State ─────────────────────────────────────────────

  /// Whether this preset is automatic.
  bool isAutomatic = false;

  /// Global increment amount (fallback if no overrides).
  double globalIncrement = 5.0;

  /// Whether to skip the first set.
  bool skipFirstSet = true;

  /// Per-exercise override: preset_exercise_id → increment amount.
  final Map<int, double?> exerciseIncrementOverrides = {};

  /// Per-exercise rotation pointer: preset_exercise_id → last_set_index.
  final Map<int, int> lastSetIndexByExercise = {};

  /// Per-set override: preset_set_id → increment amount.
  final Map<int, double?> setIncrementOverrides = {};

  // ─── In-memory Workout Representation ───────────────────────────────────

  /// In-memory list of exercises and their types, and their original defIds
  final List<WorkoutExercise> exercises = [];
  final List<CardType> cardTypes = [];
  final List<int?> _originalDefIds = [];

  /// Preset-exercise row IDs (for lookups & overrides).
  final List<int> _presetExerciseIds = [];

  /// Parent set IDs for each weight exercise (in order).
  final List<List<int>> _presetParentSetIds = [];

  /// Child-set IDs grouped by parent index for each weight exercise.
  final List<Map<int, List<int>>> _presetChildSetIds = [];

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  PresetSession(this.presetId) {
    _loadPreset();
  }

  /// Loads the preset definition and all child details.
  Future<void> _loadPreset() async {
    final def = await _repo.fetchPresetById(presetId);
    presetName = def?.name ?? '';

    // 2) Clear all in-memory state (including our new auto-ID lists and overrides)
    exercises.clear();
    cardTypes.clear();
    _originalDefIds.clear();
    _presetExerciseIds.clear();
    _presetParentSetIds.clear();
    _presetChildSetIds.clear();
    exerciseIncrementOverrides.clear();
    lastSetIndexByExercise.clear();
    setIncrementOverrides.clear();

    final rawRows = await _repo.fetchPresetExercises(presetId);
    for (var row in rawRows) {
      final exRowId = row['id'] as int;
      _presetExerciseIds.add(exRowId);

      final type = row['type'] as String;
      final defId = row['exercise_def_id'] as int?;

      if (type == 'weight') {
        // 1) fetch definition info
        final info = defId != null
            ? await _repo.fetchDefinitionInfo(defId)
            : {'name': '', 'equipmentName': ''};
        final name = info['name']!;
        final equipment = info['equipmentName']!;

        // 2) pull all rows, group parents vs. children
        final rawSets = await _repo.fetchPresetSets(exRowId);
        final parentRows =
            rawSets.where((r) => r['parent_set_id'] == null).toList();
        final parents = <ExerciseSet>[];
        final changeSets = <int, List<ExerciseSet>>{};
        final parentIds = <int>[];
        final childIdsMap = <int, List<int>>{};

        // build parent list
        for (var i = 0; i < parentRows.length; i++) {
          final r = parentRows[i];
          parents.add(ExerciseSet(
            weight: (r['weight'] as num).toDouble(),
            reps: r['reps'] as int,
          ));
          parentIds.add(r['id'] as int);
        }

        // assign each child row to its parent index
        for (var r in rawSets.where((r) => r['parent_set_id'] != null)) {
          final pid = r['parent_set_id'] as int;
          final pIndex = parentRows.indexWhere((pr) => pr['id'] == pid);
          if (pIndex == -1) continue; // skip orphaned child
          changeSets[pIndex] ??= [];
          changeSets[pIndex]!.add(ExerciseSet(
            weight: (r['weight'] as num).toDouble(),
            reps: r['reps'] as int,
          ));
          childIdsMap[pIndex] =
              (childIdsMap[pIndex] ?? [])..add(r['id'] as int);
        }

        
        _presetParentSetIds.add(parentIds);
        _presetChildSetIds.add(childIdsMap);

        // finally add into our in-memory list
        exercises.add(WeightExercise(
          name: name,
          equipment: equipment,
          sets: parents,
          changeSets: changeSets,
        ));
        cardTypes.add(CardType.weight);
        _originalDefIds.add(defId);


      } else if (type == 'cardio') {
        _presetParentSetIds.add(<int>[]);
        _presetChildSetIds.add(<int, List<int>>{});
        cardTypes.add(CardType.cardio);
        _originalDefIds.add(null);
        final c = await _repo.fetchPresetCardio(exRowId);
        if (c != null) {
           
          exercises.add(CardioExercise(
            name: c['cardio_name'] as String,
            equipment: '',
            cardioName: c['cardio_name'] as String,
            cardioNote: c['note'] as String?,
            plannedMinutes: (c['planned_minutes'] as num).toInt(),
            elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
          ));
          
        }

       
      } else if (type == 'stretch') {
        cardTypes.add(CardType.stretch);
        _originalDefIds.add(null);

        _presetParentSetIds.add(<int>[]);
        _presetChildSetIds.add(<int, List<int>>{});

        final rawItems = await _repo.fetchPresetStretchItems(exRowId);
        // Build typed StretchInstance list (all unchecked)
        final instances = rawItems.map((r) {
          // Map the DB row plus default is_checked=0 into our model
          return StretchInstance.fromMap(<String, dynamic>{
            'stretch_id': r['stretch_id'] as int?,
            'is_custom': r['is_custom'] as int,
            'custom_name': r['custom_name'] as String?,
            'custom_desc': r['custom_desc'] as String?,
            'is_checked': 0,
            'order_index': (r['order_index'] as num).toInt(),
          });
        }).toList();
        final completed = <int>{};

        // determine header
        String stretchName = 'Stretch';
        if (instances.isNotEmpty) {
          final first = instances.first;
          if (first.stretchId != null) {
            final dn =
                await _repo.fetchStretchDefinitionNameById(first.stretchId!);
            if (dn != null) stretchName = dn;
          } else if (first.isCustom) {
            stretchName = first.customName ?? 'Stretch';
          }
        }
        exercises.add(StretchExercise(
          name: stretchName,
          equipment: '',
          stretchInstances: instances,
          completedStretchIndices: completed,
        ));
        
      }
    }

    // 4) Load Automatic Settings
    final autoRow = await _repo.fetchPresetAutoSettings(presetId);
    isAutomatic = (autoRow?['is_automatic'] as int? ?? 0) == 1;
    globalIncrement = autoRow != null
        ? (autoRow['global_increment'] as num).toDouble()
        : 5.0;
    skipFirstSet = (autoRow?['skip_first_set'] as int? ?? 1) == 1;

    // 5) Load per-exercise overrides
    for (var exRowId in _presetExerciseIds) {
      final exAuto = await _repo.fetchPresetExerciseAuto(exRowId);
      final inc = exAuto?['increment_amount'] == null
          ? null
          : (exAuto!['increment_amount'] as num).toDouble();
      exerciseIncrementOverrides[exRowId] = inc;
      lastSetIndexByExercise[exRowId] =
          (exAuto?['last_set_index'] as int?) ?? (skipFirstSet ? 2 : 1);
    }

    // 6) Load per-set overrides
    for (var i = 0; i < _presetParentSetIds.length; i++) {
      // parent sets
      for (var pid in _presetParentSetIds[i]) {
        final setAuto = await _repo.fetchPresetSetAuto(pid);
        setIncrementOverrides[pid] = setAuto?['increment_amount'] == null
            ? null
            : (setAuto!['increment_amount'] as num).toDouble();
      }
      // child sets
      for (var entry in _presetChildSetIds[i].entries) {
        for (var cid in entry.value) {
          final setAuto = await _repo.fetchPresetSetAuto(cid);
          setIncrementOverrides[cid] = setAuto?['increment_amount'] == null
              ? null
              : (setAuto!['increment_amount'] as num).toDouble();
        }
      }
    }

    _hasChanges = false;
    notifyListeners();
  }

  /// Mirrors ActiveSession.addExercise.
  void addExercise(WorkoutExercise ex, CardType type, {int? defId}) {
    exercises.add(ex);
    cardTypes.add(type);
    _originalDefIds.add(defId);
    _hasChanges = true;
    notifyListeners();
  }

  /// Mirrors ActiveSession.removeExercise.
  void removeExercise(int index) {
    exercises.removeAt(index);
    cardTypes.removeAt(index);
    _originalDefIds.removeAt(index);
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
        defId = _originalDefIds[i] ??
            await _repo.findExerciseDefinitionId(we.name, we.equipment);
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
        // Convert back to raw maps for DAO
        await _repo.savePresetStretch(
          newId,
          we.stretchInstances.map((inst) => inst.toMap()).toList(),
        );
      }
    }

    _hasChanges = false;
    // now re-sync all of the internal lists, including:
  // _presetExerciseIds, _presetParentSetIds, _presetChildSetIds, etc.
  await _loadPreset();
  }

  /// Starts a live session by writing this preset's exercises into the session tables.
  Future<int> startSession() async {
    // 1) Create the session row
    final nowIso = DateTime.now().toIso8601String();
    final sessionId = await _repo.createSession(nowIso, 0);

  // 2) Persist each in-memory exercise
  for (var i = 0; i < exercises.length; i++) {
    final we = exercises[i];

    // Ensure a definition exists for this exercise (never null)
    final defId = await _repo.findExerciseDefinitionId(we.name, we.equipment);

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
        items: we.stretchInstances.map((inst) => inst.toMap()).toList(),
      );
    }
  }

  return sessionId;
}

 // ─── Automatic Settings Actions ───────────────────────────────────────

  /// Enables Automatic mode (creates default settings).
  Future<void> enableAutomatic() async {
    await _repo.upsertPresetAutoSettings(
      presetId: presetId,
      isAutomatic: true,
      globalIncrement: globalIncrement,
      skipFirstSet: skipFirstSet,
    );
    isAutomatic = true;
    notifyListeners();
  }

  /// Disables Automatic mode (removes settings).
  Future<void> disableAutomatic() async {
    await _repo.deletePresetAutoSettings(presetId);
    isAutomatic = false;
    notifyListeners();
  }

  /// Updates and saves global automatic settings.
  Future<void> saveAutoSettings({
  required double newGlobalIncrement,
  required bool newSkipFirstSet,
}) async {
  // 1) write the NEW settings into the DB
  await _repo.upsertPresetAutoSettings(
    presetId:        presetId,
    isAutomatic:     isAutomatic,
    globalIncrement: newGlobalIncrement,   
    skipFirstSet:    newSkipFirstSet,    
  );
  // 2) then update in-memory to match
  globalIncrement = newGlobalIncrement;
  skipFirstSet    = newSkipFirstSet;
  notifyListeners();
}



  /// Updates and saves a per-exercise increment override.
  Future<void> saveExerciseOverride(
    int presetExerciseId,
    double? incrementAmount,
  ) async {
    await _repo.upsertPresetExerciseAuto(
      presetExerciseId: presetExerciseId,
      incrementAmount: incrementAmount,
      lastSetIndex: lastSetIndexByExercise[presetExerciseId]!,
    );
    exerciseIncrementOverrides[presetExerciseId] = incrementAmount;
    notifyListeners();
  }

  /// Updates and saves a per-set increment override.
  Future<void> saveSetOverride(int presetSetId, double? incrementAmount,
  ) async {
    await _repo.upsertPresetSetAuto(
      presetSetId: presetSetId,
      incrementAmount: incrementAmount,
    );
    setIncrementOverrides[presetSetId] = incrementAmount;
    notifyListeners();
  }

// ─── Getters for Preset Data ────────────────────────────────────────────
    List<int> get presetExerciseIds => _presetExerciseIds;
  List<List<int>> get presetParentSetIds => _presetParentSetIds;
  List<Map<int, List<int>>> get presetChildSetIds => _presetChildSetIds;


}
