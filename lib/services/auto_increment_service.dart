// File: lib/services/auto_increment_service.dart

import 'dart:math';
import 'dart:convert';
import '../repositories/app_repository.dart';
import 'flow_executor.dart';
import '../models/preset_models.dart';

/// Parsed automatic-progression settings for one preset.
///
/// The database stores these values in several auto-setting tables. This value
/// object keeps the service code focused on progression decisions instead of
/// raw SQLite maps.
class _AutoSettings {
  final double globalIncrement;
  final bool skipFirst;
  final bool weightCheck;
  final bool repCheck;
  final bool volumeCheck;
  final bool adjustAllSets;

  final bool useManualSelect;
  final Map<int, bool> manualSelections;
  final ProgressionSuccessScope successScope;

  _AutoSettings({
    required this.globalIncrement,
    required this.skipFirst,
    required this.weightCheck,
    required this.repCheck,
    required this.volumeCheck,
    required this.adjustAllSets,

    required this.useManualSelect,
    required this.manualSelections,
    required this.successScope,
  });
}

class _ExerciseContext {
  final int presetExerciseId;
  final int? sessionExerciseId;
  final List<Map<String, dynamic>> allPresetSets;
  final List<Map<String, dynamic>> parentPresetSets;
  final List<Map<String, dynamic>> sessionSets;
  final Map<String, dynamic>? exerciseAuto;
  final int targetIndex;

  const _ExerciseContext({
    required this.presetExerciseId,
    required this.sessionExerciseId,
    required this.allPresetSets,
    required this.parentPresetSets,
    required this.sessionSets,
    required this.exerciseAuto,
    required this.targetIndex,
  });
}

class _WorkingSet {
  final int? id;
  final int? parentSetId;
  double weight;
  int reps;
  int orderIndex;

  _WorkingSet({
    required this.id,
    required this.parentSetId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });

  factory _WorkingSet.fromRow(Map<String, dynamic> row) => _WorkingSet(
    id: row['id'] as int,
    parentSetId: row['parent_set_id'] as int?,
    weight: (row['weight'] as num).toDouble(),
    reps: (row['reps'] as num).toInt(),
    orderIndex: (row['order_index'] as num).toInt(),
  );
}

/// Applies automatic preset progression after a preset-based workout finishes.
///
/// The service compares completed session sets against the preset targets,
/// traverses the saved flow graph, and applies the returned methods to the
/// preset's future sets. It never changes the completed session itself.
class AutoIncrementService {
  final AppRepository _repo;

  /// Allows injecting a custom repo for tests; defaults to real.
  AutoIncrementService([AppRepository? repo]) : _repo = repo ?? AppRepository();

  /// Applies auto-increment for [sessionId] and [presetId].
  Future<void> apply({required int sessionId, required int presetId}) async {
    final settings = await _loadAutoSettings(presetId);
    if (settings == null) return;

    final results = await Future.wait<Object>([
      _repo.fetchFlowDefinition(presetId),
      _repo.fetchFlowMethods(presetId),
      _repo.fetchPresetExercises(presetId),
      _repo.fetchExercises(sessionId),
    ]);
    final flowDef = results[0] as FlowDefinition;
    final methods = results[1] as List<FlowMethod>;
    final executor = FlowExecutor(flowDef: flowDef, methods: methods);
    final presetExercises = results[2] as List<Map<String, dynamic>>;
    final sessionExercises = results[3] as List<Map<String, dynamic>>;

    final sessionBySource = <int, Map<String, dynamic>>{};
    for (final row in sessionExercises) {
      final sourceId = row['source_preset_exercise_id'] as int?;
      if (sourceId != null) sessionBySource[sourceId] = row;
    }
    final hasStableLinks = sessionBySource.isNotEmpty;
    final contexts = <_ExerciseContext>[];

    for (final presetExercise in presetExercises) {
      if (presetExercise['type'] != 'weight') continue;
      final presetExerciseId = presetExercise['id'] as int;
      Map<String, dynamic>? sessionExercise = sessionBySource[presetExerciseId];
      if (sessionExercise == null && !hasStableLinks) {
        final orderIndex = presetExercise['order_index'] as int;
        for (final candidate in sessionExercises) {
          if (candidate['type'] == 'weight' &&
              candidate['order_index'] == orderIndex) {
            sessionExercise = candidate;
            break;
          }
        }
      }

      final allPresetSets = await _repo.fetchPresetSets(presetExerciseId);
      final parentPresetSets =
          allPresetSets.where((row) => row['parent_set_id'] == null).toList();
      if (parentPresetSets.isEmpty) continue;
      final exerciseAuto = await _repo.fetchPresetExerciseAuto(
        presetExerciseId,
      );
      final targetIndex = _normalizedTargetIndex(
        exerciseAuto?['last_set_index'] as int? ?? 1,
        parentPresetSets.length,
        settings.skipFirst,
      );
      final sessionExerciseId = sessionExercise?['id'] as int?;
      contexts.add(
        _ExerciseContext(
          presetExerciseId: presetExerciseId,
          sessionExerciseId: sessionExerciseId,
          allPresetSets: allPresetSets,
          parentPresetSets: parentPresetSets,
          sessionSets:
              sessionExerciseId == null
                  ? <Map<String, dynamic>>[]
                  : await _repo.fetchSets(sessionExerciseId),
          exerciseAuto: exerciseAuto,
          targetIndex: targetIndex,
        ),
      );
    }
    if (contexts.isEmpty) return;

    final exerciseSuccesses = <int, bool>{
      for (final context in contexts)
        context.presetExerciseId: _exerciseSucceeded(context, settings),
    };
    final sessionSucceeded =
        exerciseSuccesses.isNotEmpty &&
        exerciseSuccesses.values.every((succeeded) => succeeded);
    final updates = <PresetSetProgressionUpdate>[];
    final inserts = <PresetSetProgressionInsert>[];
    final deletedSetIds = <int>{};
    final exerciseStates = <PresetExerciseProgressionState>[];

    for (final context in contexts) {
      final succeeded = switch (settings.successScope) {
        ProgressionSuccessScope.session => sessionSucceeded,
        ProgressionSuccessScope.exercise =>
          exerciseSuccesses[context.presetExerciseId] ?? false,
        ProgressionSuccessScope.set => _targetSetSucceeded(context, settings),
      };
      final result = executor.traverse(
        lastNodeKey: context.exerciseAuto?['last_node'] as String?,
        outcome: succeeded,
      );
      await _buildExerciseMutation(
        context: context,
        methods: result.methods,
        settings: settings,
        newLastNode: result.nodeKey,
        updates: updates,
        inserts: inserts,
        deletedSetIds: deletedSetIds,
        exerciseStates: exerciseStates,
      );
    }

    await _repo.applyPresetProgressionBatch(
      PresetProgressionBatch(
        updates: updates,
        inserts: inserts,
        deletedSetIds: deletedSetIds.toList(),
        exerciseStates: exerciseStates,
      ),
    );
  }

  Future<_AutoSettings?> _loadAutoSettings(int presetId) async {
    final auto = await _repo.fetchPresetAutoSettings(presetId);
    if (auto == null || (auto['is_automatic'] as int) != 1) return null;

    bool intToBool(int v) => v == 1;
    final useManual = intToBool(auto['use_manual_select'] as int? ?? 0);
    final rawJson = auto['manual_selection_json'] as String? ?? '{}';

    final manualSelections = _parseManualSelections(rawJson);

    return _AutoSettings(
      globalIncrement: (auto['global_increment'] as num).toDouble(),
      skipFirst: intToBool(auto['skip_first_set'] as int),
      weightCheck: intToBool(auto['weight_check'] as int),
      repCheck: intToBool(auto['rep_check'] as int),
      volumeCheck: intToBool(auto['volume_check'] as int),
      adjustAllSets: intToBool(auto['adjust_all_sets'] as int),
      useManualSelect: useManual,
      manualSelections: manualSelections,
      successScope: ProgressionSuccessScopeX.fromStorage(
        auto['success_count_mode'],
      ),
    );
  }

  bool _targetSetSucceeded(_ExerciseContext context, _AutoSettings settings) {
    final index = context.targetIndex - 1;
    return _setSucceeded(
      context.parentPresetSets[index],
      index,
      context.sessionSets,
      settings,
    );
  }

  bool _exerciseSucceeded(_ExerciseContext context, _AutoSettings settings) {
    if (context.sessionExerciseId == null) return false;
    final firstIndex =
        settings.skipFirst && context.parentPresetSets.length >= 2 ? 1 : 0;
    for (var i = firstIndex; i < context.parentPresetSets.length; i++) {
      if (!_setSucceeded(
        context.parentPresetSets[i],
        i,
        context.sessionSets,
        settings,
      )) {
        return false;
      }
    }
    return true;
  }

  bool _setSucceeded(
    Map<String, dynamic> target,
    int fallbackIndex,
    List<Map<String, dynamic>> sessionSets,
    _AutoSettings settings,
  ) {
    final performedParents =
        sessionSets.where((row) => row['parent_set_id'] == null).toList();
    final targetId = target['id'] as int;
    Map<String, dynamic>? performed;
    var hasStableLinks = false;
    for (final row in performedParents) {
      final sourceId = row['source_preset_set_id'] as int?;
      if (sourceId != null) {
        hasStableLinks = true;
        if (sourceId == targetId) performed = row;
      }
    }
    if (performed == null &&
        !hasStableLinks &&
        fallbackIndex < performedParents.length) {
      performed = performedParents[fallbackIndex];
    }
    if (performed == null) return false;

    final completedWeight = (performed['weight'] as num).toDouble();
    final completedReps = (performed['reps'] as num).toInt();
    final targetWeight = (target['weight'] as num).toDouble();
    final targetReps = (target['reps'] as num).toInt();
    if (settings.weightCheck && completedWeight < targetWeight) return false;
    if (settings.repCheck && completedReps < targetReps) return false;
    if (settings.volumeCheck &&
        completedWeight * completedReps < targetWeight * targetReps) {
      return false;
    }
    return true;
  }

  Future<void> _buildExerciseMutation({
    required _ExerciseContext context,
    required List<FlowMethod> methods,
    required _AutoSettings settings,
    required String? newLastNode,
    required List<PresetSetProgressionUpdate> updates,
    required List<PresetSetProgressionInsert> inserts,
    required Set<int> deletedSetIds,
    required List<PresetExerciseProgressionState> exerciseStates,
  }) async {
    final allSets = context.allPresetSets.map(_WorkingSet.fromRow).toList();
    final parents = allSets.where((set) => set.parentSetId == null).toList();
    final targetIndex = _normalizedTargetIndex(
      context.targetIndex,
      parents.length,
      settings.skipFirst,
    );
    final targets = _selectTargets(settings, allSets, parents, targetIndex);

    for (final method in methods) {
      switch (method.type) {
        case MethodType.weight:
          final sign = method.params['sign'] == '-' ? '-' : '+';
          final factor = max(
            0.0,
            (method.params['factor'] as num? ?? 1).toDouble(),
          );
          for (final target in targets) {
            final setId = target.id;
            if (setId == null) continue;
            final increment = await _resolveIncrementAmount(
              context.presetExerciseId,
              setId,
              settings,
            );
            final delta = factor * increment;
            target.weight =
                sign == '+'
                    ? target.weight + delta
                    : max(0.0, target.weight - delta);
          }
          break;
        case MethodType.rep:
          final sign = method.params['sign'] == '-' ? '-' : '+';
          final amount = (method.params['amount'] as num? ?? 0).toInt().abs();
          for (final target in targets) {
            target.reps =
                sign == '+'
                    ? target.reps + amount
                    : max(0, target.reps - amount);
          }
          break;
        case MethodType.addSet:
          final copyIndex = method.params['copyFromSetIndex'] as num?;
          if (copyIndex != null) {
            var index = copyIndex.toInt();
            if (index < 0 || index >= parents.length) {
              index = parents.length - 1;
            }
            final source = parents[index];
            parents.add(
              _WorkingSet(
                id: null,
                parentSetId: null,
                weight: source.weight,
                reps: source.reps,
                orderIndex: parents.length,
              ),
            );
          } else {
            parents.add(
              _WorkingSet(
                id: null,
                parentSetId: null,
                weight: max(
                  0.0,
                  (method.params['weight'] as num? ?? 0).toDouble(),
                ),
                reps: max(0, (method.params['reps'] as num? ?? 0).toInt()),
                orderIndex: parents.length,
              ),
            );
          }
          break;
        case MethodType.delSet:
          if (parents.length <= 1) break;
          final removed = parents.removeLast();
          if (removed.id != null) {
            deletedSetIds.add(removed.id!);
            for (final child in allSets) {
              if (child.parentSetId == removed.id && child.id != null) {
                deletedSetIds.add(child.id!);
              }
            }
          }
          break;
      }
    }

    for (var i = 0; i < parents.length; i++) {
      parents[i].orderIndex = i;
    }
    final survivingSets = <_WorkingSet>[
      ...allSets.where(
        (set) => set.parentSetId != null && !deletedSetIds.contains(set.id),
      ),
      ...parents,
    ];
    for (final set in survivingSets) {
      if (set.id == null) {
        inserts.add(
          PresetSetProgressionInsert(
            presetExerciseId: context.presetExerciseId,
            weight: set.weight,
            reps: set.reps,
            orderIndex: set.orderIndex,
          ),
        );
      } else if (!deletedSetIds.contains(set.id)) {
        updates.add(
          PresetSetProgressionUpdate(
            setId: set.id!,
            weight: set.weight,
            reps: set.reps,
            orderIndex: set.orderIndex,
          ),
        );
      }
    }

    var nextIndex = targetIndex;
    if (!settings.adjustAllSets && !settings.useManualSelect) nextIndex++;
    nextIndex = _normalizedTargetIndex(
      nextIndex,
      parents.length,
      settings.skipFirst,
    );
    exerciseStates.add(
      PresetExerciseProgressionState(
        presetExerciseId: context.presetExerciseId,
        incrementAmount:
            (context.exerciseAuto?['increment_amount'] as num?)?.toDouble(),
        lastSetIndex: nextIndex,
        lastNode: newLastNode,
      ),
    );
  }

  /// Decodes the manual set-selection map stored in preset auto settings.
  Map<int, bool> _parseManualSelections(String? rawJson) {
    try {
      final decoded = jsonDecode(rawJson ?? '{}');
      if (decoded is! Map) return const <int, bool>{};

      final selections = <int, bool>{};
      decoded.forEach((key, value) {
        final setId = int.tryParse(key.toString());
        if (setId != null && value is bool) {
          selections[setId] = value;
        }
      });
      return selections;
    } catch (_) {
      return const <int, bool>{};
    }
  }

  /// Resolves the increment amount with set override, exercise override, then
  /// global preset fallback priority.
  Future<double> _resolveIncrementAmount(
    int presetExerciseId,
    int setId,
    _AutoSettings settings,
  ) async {
    final setAuto = await _repo.fetchPresetSetAuto(setId);
    if (setAuto?['increment_amount'] != null) {
      return (setAuto!['increment_amount'] as num).toDouble();
    }
    final exAuto = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    if (exAuto?['increment_amount'] != null) {
      return (exAuto!['increment_amount'] as num).toDouble();
    }
    return settings.globalIncrement;
  }

  List<_WorkingSet> _selectTargets(
    _AutoSettings settings,
    List<_WorkingSet> allSets,
    List<_WorkingSet> parents,
    int targetIndex,
  ) {
    if (settings.useManualSelect) {
      return allSets
          .where(
            (set) =>
                set.id != null && settings.manualSelections[set.id] == true,
          )
          .toList();
    }
    if (settings.adjustAllSets) return parents;
    return <_WorkingSet>[parents[targetIndex - 1]];
  }

  int _normalizedTargetIndex(int index, int parentCount, bool skipFirst) {
    if (parentCount <= 0) return 1;
    final firstAllowed = skipFirst && parentCount >= 2 ? 2 : 1;
    if (index < firstAllowed || index > parentCount) return firstAllowed;
    return index;
  }
}
