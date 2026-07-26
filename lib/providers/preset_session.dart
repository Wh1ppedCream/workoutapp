// File: lib/providers/preset_session.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../widgets/exercise_card.dart'; // for CardType
import 'dart:convert';

/// Source of truth for the preset detail/edit UI.
///
/// The database stores a preset as a definition row plus ordered exercise rows,
/// parent set rows, child/change-set rows, and automatic progression settings.
/// This provider loads that shape into mutable UI-friendly lists, while keeping
/// the original database row IDs beside each exercise/set so edits can be saved
/// without refetching everything.
class PresetSession extends ChangeNotifier {
  final int presetId;
  final AppRepository _repo;
  late final Future<void> ready;

  /// Preset's current name, loaded from the definition.
  String presetName = '';
  int? profileId;
  bool isDraft = false;

  // ─── Automatic Preset State ─────────────────────────────────────────────

  /// Whether this preset is automatic.
  bool isAutomatic = false;

  /// Global increment amount (fallback if no overrides).
  double globalIncrement = 5.0;

  /// Whether to skip the first set.
  bool skipFirstSet = true;

  bool weightCheck = true;
  bool repCheck = true;
  bool volumeCheck = false;
  bool adjustAllSets = false;
  ProgressionSuccessScope successScope = ProgressionSuccessScope.set;

  /// Whether the user picked manual-select mode.
  bool manualSelect = false;

  /// When in manual mode, which set IDs should be ticked.
  Map<int, bool> manualSelections = {};

  /// Per-exercise override: preset_exercise_id → increment amount.
  final Map<int, double?> exerciseIncrementOverrides = {};

  /// Per-exercise rotation pointer: preset_exercise_id → last_set_index.
  final Map<int, int> lastSetIndexByExercise = {};

  /// Per-set override: preset_set_id → increment amount.
  final Map<int, double?> setIncrementOverrides = {};

  // ─── In-memory Workout Representation ───────────────────────────────────

  /// In-memory list of exercises and their types, plus original definition IDs.
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

  PresetSession(this.presetId, {required AppRepository repository})
    : _repo = repository {
    ready = _loadPreset();
  }

  /// Loads the preset definition and all child details.
  ///
  /// The index of each entry in [_presetExerciseIds], [_presetParentSetIds],
  /// and [_presetChildSetIds] mirrors the same index in [exercises]. Keeping
  /// that parallel structure lets edit widgets save/delete rows without needing
  /// to ask the database to rediscover which row belongs to which card.
  Future<void> _loadPreset() async {
    final def = await _repo.fetchPresetById(presetId);
    presetName = def?.name ?? '';
    profileId = def?.profileId;
    isDraft = def?.isDraft ?? false;

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
        final info =
            defId != null
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
          parents.add(
            ExerciseSet(
              sourcePresetSetId: r['id'] as int,
              weight: (r['weight'] as num).toDouble(),
              reps: r['reps'] as int,
            ),
          );
          parentIds.add(r['id'] as int);
        }

        // assign each child row to its parent index
        for (var r in rawSets.where((r) => r['parent_set_id'] != null)) {
          final pid = r['parent_set_id'] as int;
          final pIndex = parentRows.indexWhere((pr) => pr['id'] == pid);
          if (pIndex == -1) continue; // skip orphaned child
          changeSets[pIndex] ??= [];
          changeSets[pIndex]!.add(
            ExerciseSet(
              sourcePresetSetId: r['id'] as int,
              weight: (r['weight'] as num).toDouble(),
              reps: r['reps'] as int,
            ),
          );
          childIdsMap[pIndex] =
              (childIdsMap[pIndex] ?? [])..add(r['id'] as int);
        }

        _presetParentSetIds.add(parentIds);
        _presetChildSetIds.add(childIdsMap);

        // finally add into our in-memory list
        exercises.add(
          WeightExercise(
            name: name,
            equipment: equipment,
            sourcePresetExerciseId: exRowId,
            sets: parents,
            changeSets: changeSets,
          ),
        );
        cardTypes.add(CardType.weight);
        _originalDefIds.add(defId);
      } else if (type == 'cardio') {
        _presetParentSetIds.add(<int>[]);
        _presetChildSetIds.add(<int, List<int>>{});
        cardTypes.add(CardType.cardio);
        _originalDefIds.add(null);
        final c = await _repo.fetchPresetCardio(exRowId);
        if (c != null) {
          exercises.add(
            CardioExercise(
              name: c['cardio_name'] as String,
              equipment: '',
              cardioName: c['cardio_name'] as String,
              cardioNote: c['note'] as String?,
              plannedMinutes: (c['planned_minutes'] as num).toInt(),
              elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
            ),
          );
        }
      } else if (type == 'stretch') {
        cardTypes.add(CardType.stretch);
        _originalDefIds.add(null);

        _presetParentSetIds.add(<int>[]);
        _presetChildSetIds.add(<int, List<int>>{});

        final rawItems = await _repo.fetchPresetStretchItems(exRowId);
        // Build typed StretchInstance list (all unchecked)
        final instances =
            rawItems.map((r) {
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
            final dn = await _repo.fetchStretchDefinitionNameById(
              first.stretchId!,
            );
            if (dn != null) stretchName = dn;
          } else if (first.isCustom) {
            stretchName = first.customName ?? 'Stretch';
          }
        }
        exercises.add(
          StretchExercise(
            name: stretchName,
            equipment: '',
            stretchInstances: instances,
            completedStretchIndices: completed,
          ),
        );
      }
    }

    // 4) Load Automatic Settings
    final autoRow = await _repo.fetchPresetAutoSettings(presetId);
    isAutomatic = (autoRow?['is_automatic'] as int? ?? 0) == 1;
    globalIncrement =
        autoRow != null ? (autoRow['global_increment'] as num).toDouble() : 5.0;
    skipFirstSet = (autoRow?['skip_first_set'] as int? ?? 1) == 1;

    // 5) Load per-exercise overrides
    for (var exRowId in _presetExerciseIds) {
      final exAuto = await _repo.fetchPresetExerciseAuto(exRowId);
      final inc =
          exAuto?['increment_amount'] == null
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
        setIncrementOverrides[pid] =
            setAuto?['increment_amount'] == null
                ? null
                : (setAuto!['increment_amount'] as num).toDouble();
      }
      // child sets
      for (var entry in _presetChildSetIds[i].entries) {
        for (var cid in entry.value) {
          final setAuto = await _repo.fetchPresetSetAuto(cid);
          setIncrementOverrides[cid] =
              setAuto?['increment_amount'] == null
                  ? null
                  : (setAuto!['increment_amount'] as num).toDouble();
        }
      }
    }

    // NEW flags:
    weightCheck = (autoRow?['weight_check'] as int? ?? 1) == 1;
    repCheck = (autoRow?['rep_check'] as int? ?? 1) == 1;
    volumeCheck = (autoRow?['volume_check'] as int? ?? 0) == 1;
    adjustAllSets =
        (autoRow?['adjust_all_sets'] as int? ?? 0) == 0 ? false : true;
    successScope = ProgressionSuccessScopeX.fromStorage(
      autoRow?['success_count_mode'],
    );

    // 7) Load our new Manual‐Select settings
    manualSelect = (autoRow?['use_manual_select'] as int? ?? 0) == 1;

    final manualJson = autoRow?['manual_selection_json'] as String? ?? '{}';
    final Map<String, dynamic> decoded =
        json.decode(manualJson) as Map<String, dynamic>;
    // keys in JSON are strings, parse back to int→bool
    manualSelections = decoded.map(
      (key, value) => MapEntry(int.parse(key), value as bool),
    );

    _hasChanges = false;
    notifyListeners();
  }

  /// Mirrors ActiveSession.addExercise.
  void addExercise(WorkoutExercise ex, CardType type, {int? defId}) {
    exercises.add(ex);
    cardTypes.add(type);
    _originalDefIds.add(defId);
    _presetExerciseIds.add(-1);
    _presetParentSetIds.add(<int>[]);
    _presetChildSetIds.add(<int, List<int>>{});
    _hasChanges = true;
    notifyListeners();
  }

  int? definitionIdForExercise(int index) {
    if (index < 0 || index >= _originalDefIds.length) return null;
    return _originalDefIds[index];
  }

  /// Mirrors ActiveSession.removeExercise.
  void removeExercise(int index) {
    final exerciseId =
        index < _presetExerciseIds.length ? _presetExerciseIds[index] : -1;
    final parentIds =
        index < _presetParentSetIds.length
            ? _presetParentSetIds[index]
            : const <int>[];
    final childIds =
        index < _presetChildSetIds.length
            ? _presetChildSetIds[index].values.expand((ids) => ids)
            : const <int>[];

    exercises.removeAt(index);
    cardTypes.removeAt(index);
    _originalDefIds.removeAt(index);
    if (index < _presetExerciseIds.length) _presetExerciseIds.removeAt(index);
    if (index < _presetParentSetIds.length) {
      _presetParentSetIds.removeAt(index);
    }
    if (index < _presetChildSetIds.length) _presetChildSetIds.removeAt(index);

    if (exerciseId > 0) {
      exerciseIncrementOverrides.remove(exerciseId);
      lastSetIndexByExercise.remove(exerciseId);
    }
    for (final setId in [...parentIds, ...childIds]) {
      setIncrementOverrides.remove(setId);
      manualSelections.remove(setId);
    }
    _hasChanges = true;
    notifyListeners();
  }

  /// Swaps a weight exercise to a new definition while preserving its sets.
  void replaceWeightExerciseDefinition(
    int index,
    ExerciseDefinition replacement,
  ) {
    if (index < 0 || index >= exercises.length) return;
    final current = exercises[index];
    if (current is! WeightExercise) return;

    final equipment = replacement.equipmentList
        .map((equipment) => equipment.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    exercises[index] = WeightExercise(
      name: replacement.name,
      equipment: equipment,
      sourcePresetExerciseId: current.sourcePresetExerciseId,
      sets: current.sets,
      changeSets: current.changeSets,
      completedParents: current.completedParents,
      completedChildren: current.completedChildren,
    );

    if (index < _originalDefIds.length) {
      _originalDefIds[index] = replacement.id;
    }

    _hasChanges = true;
    notifyListeners();
  }

  /// Reorders a preset exercise and any aligned metadata that belongs to it.
  void reorderExercise(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= exercises.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= exercises.length) newIndex = exercises.length - 1;
    if (oldIndex == newIndex) return;

    final previousLength = exercises.length;
    _moveListItem(exercises, oldIndex, newIndex);
    _moveListItemIfAligned(cardTypes, previousLength, oldIndex, newIndex);
    _moveListItemIfAligned(_originalDefIds, previousLength, oldIndex, newIndex);
    _moveListItemIfAligned(
      _presetExerciseIds,
      previousLength,
      oldIndex,
      newIndex,
    );
    _moveListItemIfAligned(
      _presetParentSetIds,
      previousLength,
      oldIndex,
      newIndex,
    );
    _moveListItemIfAligned(
      _presetChildSetIds,
      previousLength,
      oldIndex,
      newIndex,
    );
    _hasChanges = true;
    notifyListeners();
  }

  void _moveListItemIfAligned<T>(
    List<T> list,
    int expectedLength,
    int oldIndex,
    int newIndex,
  ) {
    if (list.length != expectedLength) return;
    _moveListItem(list, oldIndex, newIndex);
  }

  void _moveListItem<T>(List<T> list, int oldIndex, int newIndex) {
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
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

  /// Persists all in-memory exercises back to the preset tables,
  /// but preserves any existing per-exercise and per-set overrides.
  Future<void> saveChanges({String? newName, bool publishDraft = false}) async {
    final writes = <WorkoutExerciseWrite>[];
    for (var index = 0; index < exercises.length; index++) {
      final exercise = exercises[index];
      final previousExerciseId =
          index < _presetExerciseIds.length && _presetExerciseIds[index] > 0
              ? _presetExerciseIds[index]
              : null;
      int? definitionId =
          index < _originalDefIds.length ? _originalDefIds[index] : null;
      if (exercise is WeightExercise && definitionId == null) {
        definitionId = await _repo.findExerciseDefinitionId(
          exercise.name,
          exercise.equipment,
        );
      }
      writes.add(
        WorkoutExerciseWrite(
          exercise: exercise,
          type:
              exercise is WeightExercise
                  ? 'weight'
                  : exercise is CardioExercise
                  ? 'cardio'
                  : 'stretch',
          definitionId: definitionId,
          previousPresetExerciseId:
              exercise is WeightExercise
                  ? exercise.sourcePresetExerciseId ?? previousExerciseId
                  : previousExerciseId,
        ),
      );
    }

    await _repo.replacePresetAtomic(
      presetId: presetId,
      name: newName,
      exercises: writes,
      autoSettings:
          isAutomatic
              ? PresetAutoSettingsWrite(
                isAutomatic: true,
                globalIncrement: globalIncrement,
                skipFirstSet: skipFirstSet,
                weightCheck: weightCheck,
                repCheck: repCheck,
                volumeCheck: volumeCheck,
                adjustAllSets: adjustAllSets,
                useManualSelect: manualSelect,
                manualSelections: manualSelections,
                successCountMode: successScope.name,
              )
              : null,
      publishDraft: publishDraft,
    );

    if (newName != null && newName.trim().isNotEmpty) {
      presetName = newName.trim();
    }
    _hasChanges = false;
    if (publishDraft) {
      isDraft = false;
      notifyListeners();
      return;
    }
    await _loadPreset();
  }

  /// Starts a live session by writing this preset's exercises into the session tables.
  Future<int> startSession() async {
    // 1) Create the session row (no ISO string needed anymore)
    final sessionId = await _repo.createSessionAt(DateTime.now(), 0);

    // 2) Persist each in-memory exercise
    for (var i = 0; i < exercises.length; i++) {
      final we = exercises[i];

      // Ensure a definition exists for this exercise (never null)
      final defId = await _repo.findExerciseDefinitionId(we.name, we.equipment);

      // Insert the exercise row — exercise_def_id is always non-null
      final exId = await _repo.addExerciseRow(
        sessionId: sessionId,
        exerciseDefId: defId,
        type:
            we is WeightExercise
                ? 'weight'
                : we is CardioExercise
                ? 'cardio'
                : 'stretch',
        orderIndex: i,
        sourcePresetExerciseId:
            we is WeightExercise ? we.sourcePresetExerciseId : null,
      );

      // And insert its details just like ActiveSession.finish()
      if (we is WeightExercise) {
        await _repo.addWeightSets(
          exerciseId: exId,
          parentSets: we.sets,
          childChangeSets: we.changeSets,
        );
      } else if (we is CardioExercise) {
        await _repo.saveCardioDetails(
          exerciseId: exId,
          cardioName: we.cardioName,
          note: we.cardioNote,
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
      weightCheck: weightCheck,
      repCheck: repCheck,
      volumeCheck: volumeCheck,
      adjustAllSets: adjustAllSets,
      useManualSelect: manualSelect,
      manualSelectionJson: json.encode(
        manualSelections.map((key, value) => MapEntry(key.toString(), value)),
      ),
      successCountMode: successScope.name,
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

  /// Commits every automatic setting and override together, then publishes the
  /// new in-memory state only after the database transaction succeeds.
  Future<void> saveAutoConfiguration({
    required double newGlobalIncrement,
    required bool newSkipFirstSet,
    required bool newWeightCheck,
    required bool newRepCheck,
    required bool newVolumeCheck,
    required bool newAdjustAllSets,
    required bool newUseManualSelect,
    required Map<int, bool> newManualSelections,
    required ProgressionSuccessScope newSuccessScope,
    required Map<int, double?> newExerciseIncrements,
    required Map<int, double?> newSetIncrements,
  }) async {
    await _repo.savePresetAutoConfigurationAtomic(
      presetId: presetId,
      configuration: PresetAutoConfigurationWrite(
        settings: PresetAutoSettingsWrite(
          isAutomatic: isAutomatic,
          globalIncrement: newGlobalIncrement,
          skipFirstSet: newSkipFirstSet,
          weightCheck: newWeightCheck,
          repCheck: newRepCheck,
          volumeCheck: newVolumeCheck,
          adjustAllSets: newAdjustAllSets,
          useManualSelect: newUseManualSelect,
          manualSelections: newManualSelections,
          successCountMode: newSuccessScope.name,
        ),
        exerciseIncrements: newExerciseIncrements,
        exerciseLastSetIndices: lastSetIndexByExercise,
        setIncrements: newSetIncrements,
      ),
    );

    globalIncrement = newGlobalIncrement;
    skipFirstSet = newSkipFirstSet;
    weightCheck = newWeightCheck;
    repCheck = newRepCheck;
    volumeCheck = newVolumeCheck;
    adjustAllSets = newAdjustAllSets;
    manualSelect = newUseManualSelect;
    manualSelections = Map<int, bool>.from(newManualSelections);
    successScope = newSuccessScope;
    exerciseIncrementOverrides
      ..clear()
      ..addAll(newExerciseIncrements);
    setIncrementOverrides
      ..clear()
      ..addAll(newSetIncrements);
    notifyListeners();
  }

  /// Updates and saves global automatic settings.
  Future<void> saveAutoSettings({
    required double newGlobalIncrement,
    required bool newSkipFirstSet,
    required bool newWeightCheck,
    required bool newRepCheck,
    required bool newVolumeCheck,
    required bool newAdjustAllSets,

    required bool newUseManualSelect,
    required String newManualSelectionJson,
    required ProgressionSuccessScope newSuccessScope,
  }) async {
    // 1) write the NEW settings into the DB
    await _repo.upsertPresetAutoSettings(
      presetId: presetId,
      isAutomatic: isAutomatic,
      globalIncrement: newGlobalIncrement,
      skipFirstSet: newSkipFirstSet,
      weightCheck: newWeightCheck,
      repCheck: newRepCheck,
      volumeCheck: newVolumeCheck,
      adjustAllSets: newAdjustAllSets,
      useManualSelect: newUseManualSelect,
      manualSelectionJson: newManualSelectionJson,
      successCountMode: newSuccessScope.name,
    );
    // 2) then update in-memory to match
    globalIncrement = newGlobalIncrement;
    skipFirstSet = newSkipFirstSet;
    weightCheck = newWeightCheck;
    repCheck = newRepCheck;
    volumeCheck = newVolumeCheck;
    adjustAllSets = newAdjustAllSets;
    manualSelect = newUseManualSelect;
    successScope = newSuccessScope;

    // decode the JSON back into our Map<int,bool>
    final decoded = json.decode(newManualSelectionJson);
    if (decoded is Map<String, dynamic>) {
      manualSelections = decoded.map<int, bool>(
        (key, value) => MapEntry(int.parse(key), value as bool),
      );
    } else {
      manualSelections = <int, bool>{};
    }

    notifyListeners();
  }

  /// Updates and saves a per-exercise increment override.
  Future<void> saveExerciseOverride(
    int presetExerciseId,
    double? incrementAmount,
  ) async {
    if (presetExerciseId <= 0) return;
    final existing = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    await _repo.upsertPresetExerciseAuto(
      presetExerciseId: presetExerciseId,
      incrementAmount: incrementAmount,
      lastSetIndex:
          lastSetIndexByExercise[presetExerciseId] ??
          (existing?['last_set_index'] as int?) ??
          1,
      lastNode: existing?['last_node'] as String?,
    );
    exerciseIncrementOverrides[presetExerciseId] = incrementAmount;
    notifyListeners();
  }

  /// Updates and saves a per-set increment override.
  Future<void> saveSetOverride(int presetSetId, double? incrementAmount) async {
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
