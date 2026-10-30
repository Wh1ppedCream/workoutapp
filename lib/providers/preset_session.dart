// File: lib/providers/preset_session.dart
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../services/safe_failure.dart';
import '../widgets/exercise_card.dart'; // for CardType

class _PresetExerciseEntry {
  _PresetExerciseEntry({
    required this.exercise,
    required this.cardType,
    required this.originalDefinitionId,
    required this.presetExerciseId,
    required List<int> parentSetIds,
    required Map<int, List<int>> childSetIds,
  }) : parentSetIds = List<int>.unmodifiable(parentSetIds),
       childSetIds = Map<int, List<int>>.unmodifiable({
         for (final entry in childSetIds.entries)
           entry.key: List<int>.unmodifiable(entry.value),
       });

  WorkoutExercise exercise;
  final CardType cardType;
  int? originalDefinitionId;
  final int presetExerciseId;
  final List<int> parentSetIds;
  final Map<int, List<int>> childSetIds;
}

class _PresetEntryListView<T> extends ListBase<T> {
  _PresetEntryListView(this._entries, this._selector);

  final List<_PresetExerciseEntry> _entries;
  final T Function(_PresetExerciseEntry entry) _selector;

  @override
  int get length => _entries.length;

  @override
  set length(int newLength) {
    throw UnsupportedError('Mutate PresetSession via its editing methods.');
  }

  @override
  T operator [](int index) => _selector(_entries[index]);

  @override
  void operator []=(int index, T value) {
    throw UnsupportedError('Mutate PresetSession via its editing methods.');
  }
}

/// Source of truth for the preset detail/edit UI.
///
/// The database stores a preset as a definition row plus ordered exercise rows,
/// parent set rows, child/change-set rows, and automatic progression settings.
/// This provider loads that shape into a single aligned entry list so exercise
/// cards, card types, definition IDs, and persisted row IDs can never skew.
class PresetSession extends ChangeNotifier {
  final int presetId;
  final AppRepository _repo;
  late final Future<void> ready;

  bool _disposed = false;
  int _loadVersion = 0;
  SafeFailure? _loadFailure;
  bool _hasLoaded = false;
  bool _isLoading = true;

  /// Latest classified load failure, or `null` when the latest load succeeded.
  SafeFailure? get loadFailure => _loadFailure;
  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _isLoading;

  /// Initial read failures are retained for recovery UI, but must never be
  /// interpreted as a valid empty plan by editing or generation callers.
  void requireLoaded() {
    if (_disposed || !_hasLoaded) {
      throw _loadFailure ??
          const SafeFailure(kind: SafeFailureKind.temporary, retryable: true);
    }
  }

  Future<void> retryLoad() => _loadPreset(rethrowErrors: false);

  void _invalidateLoad() {
    _loadVersion++;
    _isLoading = false;
  }

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

  final List<_PresetExerciseEntry> _entries = [];

  /// Read-only aligned projections over [_entries].
  late final List<WorkoutExercise> exercises = _PresetEntryListView(
    _entries,
    (entry) => entry.exercise,
  );
  late final List<CardType> cardTypes = _PresetEntryListView(
    _entries,
    (entry) => entry.cardType,
  );
  late final List<int> presetExerciseIds = _PresetEntryListView(
    _entries,
    (entry) => entry.presetExerciseId,
  );
  late final List<List<int>> presetParentSetIds = _PresetEntryListView(
    _entries,
    (entry) => entry.parentSetIds,
  );
  late final List<Map<int, List<int>>> presetChildSetIds = _PresetEntryListView(
    _entries,
    (entry) => entry.childSetIds,
  );

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  /// Discard only in-memory edits; the persisted preset remains untouched.
  Future<void> discardChanges() => _loadPreset(rethrowErrors: true);

  PresetSession(this.presetId, {required AppRepository repository})
    : _repo = repository {
    ready = _loadPreset(rethrowErrors: false);
  }

  @override
  void dispose() {
    _disposed = true;
    _loadVersion++;
    super.dispose();
  }

  void _notifyIfActive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  static Map<int, bool> _decodeManualSelections(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return <int, bool>{};
    }
    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map) return <int, bool>{};
      final parsed = <int, bool>{};
      for (final entry in decoded.entries) {
        final key = int.tryParse(entry.key.toString());
        final value = entry.value;
        if (key != null && value is bool) {
          parsed[key] = value;
        }
      }
      return parsed;
    } catch (_) {
      return <int, bool>{};
    }
  }

  /// Loads the preset definition and all child details into local staging
  /// structures before publishing them atomically if this load is still the
  /// newest active generation.
  Future<void> _loadPreset({required bool rethrowErrors}) async {
    if (_disposed) return;
    final loadVersion = ++_loadVersion;
    _isLoading = true;
    _notifyIfActive();
    try {
      final def = await _repo.fetchPresetById(presetId);
      if (_disposed || loadVersion != _loadVersion) return;

      final stagedEntries = <_PresetExerciseEntry>[];
      final rawRows = await _repo.fetchPresetExercises(presetId);
      if (_disposed || loadVersion != _loadVersion) return;

      for (final row in rawRows) {
        final exRowId = row['id'] as int;
        final type = row['type'] as String?;
        final defId = row['exercise_def_id'] as int?;

        if (type == 'weight') {
          final info = defId != null
              ? await _repo.fetchDefinitionInfo(defId)
              : const <String, String?>{'name': '', 'equipmentName': ''};
          if (_disposed || loadVersion != _loadVersion) return;
          final name = info['name'] ?? '';
          final equipment = info['equipmentName'] ?? '';

          final rawSets = await _repo.fetchPresetSets(exRowId);
          if (_disposed || loadVersion != _loadVersion) return;
          final parentRows = rawSets
              .where((r) => r['parent_set_id'] == null)
              .toList();
          final parents = <ExerciseSet>[];
          final changeSets = <int, List<ExerciseSet>>{};
          final parentIds = <int>[];
          final childIdsMap = <int, List<int>>{};

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

          for (final r in rawSets.where((r) => r['parent_set_id'] != null)) {
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
            childIdsMap[pIndex] = (childIdsMap[pIndex] ?? [])
              ..add(r['id'] as int);
          }

          stagedEntries.add(
            _PresetExerciseEntry(
              exercise: WeightExercise(
                name: name,
                equipment: equipment,
                sourcePresetExerciseId: exRowId,
                sets: parents,
                changeSets: changeSets,
              ),
              cardType: CardType.weight,
              originalDefinitionId: defId,
              presetExerciseId: exRowId,
              parentSetIds: parentIds,
              childSetIds: childIdsMap,
            ),
          );
        } else if (type == 'cardio') {
          final c = await _repo.fetchPresetCardio(exRowId);
          if (_disposed || loadVersion != _loadVersion) return;
          if (c == null) continue;
          stagedEntries.add(
            _PresetExerciseEntry(
              exercise: CardioExercise(
                name: c['cardio_name'] as String,
                equipment: '',
                cardioName: c['cardio_name'] as String,
                cardioNote: c['note'] as String?,
                plannedMinutes: (c['planned_minutes'] as num).toInt(),
                elapsedSeconds: (c['elapsed_seconds'] as num).toInt(),
              ),
              cardType: CardType.cardio,
              originalDefinitionId: null,
              presetExerciseId: exRowId,
              parentSetIds: const <int>[],
              childSetIds: const <int, List<int>>{},
            ),
          );
        } else if (type == 'stretch') {
          final rawItems = await _repo.fetchPresetStretchItems(exRowId);
          if (_disposed || loadVersion != _loadVersion) return;
          final instances = rawItems.map((r) {
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

          var stretchName = 'Stretch';
          if (instances.isNotEmpty) {
            final first = instances.first;
            if (first.stretchId != null) {
              final dn = await _repo.fetchStretchDefinitionNameById(
                first.stretchId!,
              );
              if (_disposed || loadVersion != _loadVersion) return;
              if (dn != null) stretchName = dn;
            } else if (first.isCustom) {
              stretchName = first.customName ?? 'Stretch';
            }
          }
          stagedEntries.add(
            _PresetExerciseEntry(
              exercise: StretchExercise(
                name: stretchName,
                equipment: '',
                stretchInstances: instances,
                completedStretchIndices: completed,
              ),
              cardType: CardType.stretch,
              originalDefinitionId: null,
              presetExerciseId: exRowId,
              parentSetIds: const <int>[],
              childSetIds: const <int, List<int>>{},
            ),
          );
        }
      }

      final autoRow = await _repo.fetchPresetAutoSettings(presetId);
      if (_disposed || loadVersion != _loadVersion) return;

      final nextIsAutomatic = (autoRow?['is_automatic'] as int? ?? 0) == 1;
      final nextGlobalIncrement = autoRow != null
          ? (autoRow['global_increment'] as num).toDouble()
          : 5.0;
      final nextSkipFirstSet = (autoRow?['skip_first_set'] as int? ?? 1) == 1;

      final stagedExerciseOverrides = <int, double?>{};
      final stagedLastSetIndices = <int, int>{};
      final stagedSetOverrides = <int, double?>{};

      for (final entry in stagedEntries) {
        final exRowId = entry.presetExerciseId;
        final exAuto = await _repo.fetchPresetExerciseAuto(exRowId);
        if (_disposed || loadVersion != _loadVersion) return;
        final inc = exAuto?['increment_amount'] == null
            ? null
            : (exAuto!['increment_amount'] as num).toDouble();
        stagedExerciseOverrides[exRowId] = inc;
        stagedLastSetIndices[exRowId] =
            (exAuto?['last_set_index'] as int?) ?? (nextSkipFirstSet ? 2 : 1);

        for (final pid in entry.parentSetIds) {
          final setAuto = await _repo.fetchPresetSetAuto(pid);
          if (_disposed || loadVersion != _loadVersion) return;
          stagedSetOverrides[pid] = setAuto?['increment_amount'] == null
              ? null
              : (setAuto!['increment_amount'] as num).toDouble();
        }
        for (final childEntry in entry.childSetIds.entries) {
          for (final cid in childEntry.value) {
            final setAuto = await _repo.fetchPresetSetAuto(cid);
            if (_disposed || loadVersion != _loadVersion) return;
            stagedSetOverrides[cid] = setAuto?['increment_amount'] == null
                ? null
                : (setAuto!['increment_amount'] as num).toDouble();
          }
        }
      }

      final nextWeightCheck = (autoRow?['weight_check'] as int? ?? 1) == 1;
      final nextRepCheck = (autoRow?['rep_check'] as int? ?? 1) == 1;
      final nextVolumeCheck = (autoRow?['volume_check'] as int? ?? 0) == 1;
      final nextAdjustAllSets = (autoRow?['adjust_all_sets'] as int? ?? 0) != 0;
      final nextSuccessScope = ProgressionSuccessScopeX.fromStorage(
        autoRow?['success_count_mode'],
      );
      final nextManualSelect =
          (autoRow?['use_manual_select'] as int? ?? 0) == 1;
      final nextManualSelections = _decodeManualSelections(
        autoRow?['manual_selection_json'] as String?,
      );

      presetName = def?.name ?? '';
      profileId = def?.profileId;
      isDraft = def?.isDraft ?? false;
      _entries
        ..clear()
        ..addAll(stagedEntries);
      isAutomatic = nextIsAutomatic;
      globalIncrement = nextGlobalIncrement;
      skipFirstSet = nextSkipFirstSet;
      exerciseIncrementOverrides
        ..clear()
        ..addAll(stagedExerciseOverrides);
      lastSetIndexByExercise
        ..clear()
        ..addAll(stagedLastSetIndices);
      setIncrementOverrides
        ..clear()
        ..addAll(stagedSetOverrides);
      weightCheck = nextWeightCheck;
      repCheck = nextRepCheck;
      volumeCheck = nextVolumeCheck;
      adjustAllSets = nextAdjustAllSets;
      successScope = nextSuccessScope;
      manualSelect = nextManualSelect;
      manualSelections = nextManualSelections;
      _loadFailure = null;
      _hasLoaded = true;
      _hasChanges = false;
      _notifyIfActive();
    } catch (error) {
      if (_disposed || loadVersion != _loadVersion) return;
      _loadFailure = SafeFailure.classify(error);
      debugPrint('PresetSession load failed: $error');
      _notifyIfActive();
      if (rethrowErrors) rethrow;
    } finally {
      if (!_disposed && loadVersion == _loadVersion) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// Mirrors ActiveSession.addExercise.
  void addExercise(WorkoutExercise ex, CardType type, {int? defId}) {
    requireLoaded();
    _invalidateLoad();
    _entries.add(
      _PresetExerciseEntry(
        exercise: ex,
        cardType: type,
        originalDefinitionId: defId,
        presetExerciseId: -1,
        parentSetIds: const <int>[],
        childSetIds: const <int, List<int>>{},
      ),
    );
    _hasChanges = true;
    _notifyIfActive();
  }

  int? definitionIdForExercise(int index) {
    if (index < 0 || index >= _entries.length) return null;
    return _entries[index].originalDefinitionId;
  }

  /// Mirrors ActiveSession.removeExercise.
  void removeExercise(int index) {
    requireLoaded();
    if (index < 0 || index >= _entries.length) return;
    _invalidateLoad();
    final removed = _entries.removeAt(index);
    final exerciseId = removed.presetExerciseId;
    final childIds = removed.childSetIds.values.expand((ids) => ids);

    if (exerciseId > 0) {
      exerciseIncrementOverrides.remove(exerciseId);
      lastSetIndexByExercise.remove(exerciseId);
    }
    for (final setId in [...removed.parentSetIds, ...childIds]) {
      setIncrementOverrides.remove(setId);
      manualSelections.remove(setId);
    }
    _hasChanges = true;
    _notifyIfActive();
  }

  /// Swaps a weight exercise to a new definition while preserving its sets.
  void replaceWeightExerciseDefinition(
    int index,
    ExerciseDefinition replacement,
  ) {
    requireLoaded();
    if (index < 0 || index >= _entries.length) return;
    final entry = _entries[index];
    final current = entry.exercise;
    if (current is! WeightExercise) return;

    _invalidateLoad();
    final equipment = replacement.equipmentList
        .map((equipment) => equipment.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    entry.exercise = WeightExercise(
      name: replacement.name,
      equipment: equipment,
      sourcePresetExerciseId: current.sourcePresetExerciseId,
      sets: current.sets,
      changeSets: current.changeSets,
      completedParents: current.completedParents,
      completedChildren: current.completedChildren,
    );
    entry.originalDefinitionId = replacement.id;

    _hasChanges = true;
    _notifyIfActive();
  }

  /// Reorders a preset exercise and any aligned metadata that belongs to it.
  void reorderExercise(int oldIndex, int newIndex) {
    requireLoaded();
    if (oldIndex < 0 || oldIndex >= _entries.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= _entries.length) newIndex = _entries.length - 1;
    if (oldIndex == newIndex) return;

    _invalidateLoad();
    final item = _entries.removeAt(oldIndex);
    _entries.insert(newIndex, item);
    _hasChanges = true;
    _notifyIfActive();
  }

  /// Marks in-memory state dirty without modifying lists.
  void refresh() {
    requireLoaded();
    _invalidateLoad();
    _hasChanges = true;
    _notifyIfActive();
  }

  /// Updates the preset definition's name.
  Future<void> updateName(String newName) async {
    requireLoaded();
    await _repo.updatePresetName(presetId, newName);
    if (_disposed) return;
    presetName = newName;
    _notifyIfActive();
  }

  /// Persists all in-memory exercises back to the preset tables,
  /// but preserves any existing per-exercise and per-set overrides.
  Future<void> saveChanges({String? newName, bool publishDraft = false}) async {
    requireLoaded();
    final snapshot = List<_PresetExerciseEntry>.from(_entries);
    final writes = <WorkoutExerciseWrite>[];
    for (final entry in snapshot) {
      final exercise = entry.exercise;
      final previousExerciseId = entry.presetExerciseId > 0
          ? entry.presetExerciseId
          : null;
      var definitionId = entry.originalDefinitionId;
      if (exercise is WeightExercise && definitionId == null) {
        definitionId = await _repo.findExerciseDefinitionId(
          exercise.name,
          exercise.equipment,
        );
      }
      writes.add(
        WorkoutExerciseWrite(
          exercise: exercise,
          type: exercise is WeightExercise
              ? 'weight'
              : exercise is CardioExercise
              ? 'cardio'
              : 'stretch',
          definitionId: definitionId,
          previousPresetExerciseId: exercise is WeightExercise
              ? exercise.sourcePresetExerciseId ?? previousExerciseId
              : previousExerciseId,
        ),
      );
    }

    await _repo.replacePresetAtomic(
      presetId: presetId,
      name: newName,
      exercises: writes,
      autoSettings: isAutomatic
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

    if (_disposed) return;
    if (newName != null && newName.trim().isNotEmpty) {
      presetName = newName.trim();
    }
    _hasChanges = false;
    if (publishDraft) {
      isDraft = false;
      _notifyIfActive();
      return;
    }
    await _loadPreset(rethrowErrors: true);
  }

  /// Starts a live session by writing this preset's exercises into the session tables.
  Future<int> startSession() async {
    requireLoaded();
    final sessionId = await _repo.createSessionAt(DateTime.now(), 0);
    final snapshot = List<_PresetExerciseEntry>.from(_entries);

    for (var i = 0; i < snapshot.length; i++) {
      final we = snapshot[i].exercise;
      final defId = await _repo.findExerciseDefinitionId(we.name, we.equipment);

      final exId = await _repo.addExerciseRow(
        sessionId: sessionId,
        exerciseDefId: defId,
        type: we is WeightExercise
            ? 'weight'
            : we is CardioExercise
            ? 'cardio'
            : 'stretch',
        orderIndex: i,
        sourcePresetExerciseId: we is WeightExercise
            ? we.sourcePresetExerciseId
            : null,
      );

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
    requireLoaded();
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
    if (_disposed) return;
    isAutomatic = true;
    _notifyIfActive();
  }

  /// Disables Automatic mode (removes settings).
  Future<void> disableAutomatic() async {
    requireLoaded();
    await _repo.deletePresetAutoSettings(presetId);
    if (_disposed) return;
    isAutomatic = false;
    _notifyIfActive();
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
    requireLoaded();
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
    if (_disposed) return;

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
    _notifyIfActive();
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
    requireLoaded();
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
    if (_disposed) return;

    globalIncrement = newGlobalIncrement;
    skipFirstSet = newSkipFirstSet;
    weightCheck = newWeightCheck;
    repCheck = newRepCheck;
    volumeCheck = newVolumeCheck;
    adjustAllSets = newAdjustAllSets;
    manualSelect = newUseManualSelect;
    successScope = newSuccessScope;
    manualSelections = _decodeManualSelections(newManualSelectionJson);
    _notifyIfActive();
  }

  /// Updates and saves a per-exercise increment override.
  Future<void> saveExerciseOverride(
    int presetExerciseId,
    double? incrementAmount,
  ) async {
    requireLoaded();
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
    if (_disposed) return;
    exerciseIncrementOverrides[presetExerciseId] = incrementAmount;
    _notifyIfActive();
  }

  /// Updates and saves a per-set increment override.
  Future<void> saveSetOverride(int presetSetId, double? incrementAmount) async {
    requireLoaded();
    await _repo.upsertPresetSetAuto(
      presetSetId: presetSetId,
      incrementAmount: incrementAmount,
    );
    if (_disposed) return;
    setIncrementOverrides[presetSetId] = incrementAmount;
    _notifyIfActive();
  }
}
