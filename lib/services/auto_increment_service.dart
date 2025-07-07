// File: lib/services/auto_increment_service.dart

import 'dart:math';
import '../repositories/app_repository.dart';
import 'flow_executor.dart';  // ← 1) import your executor
import '../models/preset_models.dart';



/// Holds global auto-increment settings and checks.
class _AutoSettings {
  final double globalIncrement;
  final bool skipFirst;
  final bool weightCheck;
  final bool repCheck;
  final bool volumeCheck;
  final bool adjustAllSets; 

  _AutoSettings({
    required this.globalIncrement,
    required this.skipFirst,
    required this.weightCheck,
    required this.repCheck,
    required this.volumeCheck,
    required this.adjustAllSets,
  });
}

/// Applies the auto-increment algorithm to a completed session
/// that was started from a preset.
class AutoIncrementService {
  final AppRepository _repo;

  /// Allows injecting a custom repo for tests; defaults to real.
  AutoIncrementService([AppRepository? repo]) : _repo = repo ?? AppRepository();

  /// Applies auto-increment for [sessionId] and [presetId].
Future<void> apply({
    required int sessionId,
    required int presetId,
  }) async {
    final settings = await _loadAutoSettings(presetId);
    if (settings == null) return;

    final flowDef = await _repo.fetchFlowDefinition(presetId);
    final methods = await _repo.fetchFlowMethods(presetId);
    final executor = FlowExecutor(flowDef: flowDef, methods: methods);

    final presetExercises  = await _repo.fetchPresetExercises(presetId);
    final sessionExercises = await _repo.fetchExercises(sessionId);

    for (var i = 0;
         i < presetExercises.length && i < sessionExercises.length;
         i++) {
      final pe = presetExercises[i];
      final se = sessionExercises[i];
      if (pe['type'] != 'weight') continue;

      final peId   = pe['id']   as int;
      final seExId = se['id']   as int;

      // 2) Use our new helper instead of _determineSuccess directly:
      final isSuccess = await _determineSuccessForTarget(
        peId, seExId, settings
      );

      // 5) Fetch where we left off last time
      final exAuto = await _repo.fetchPresetExerciseAuto(peId);
      final lastNodeKey = exAuto?['last_node'] as String?;

      // 6) Traverse exactly one step
      final result = await executor.traverse(
  lastNodeKey: lastNodeKey,
  outcome: isSuccess,
);
      // 7) Apply all returned methods (this now also rotates & persists both pointers)
      await _applyMethods(
        peId,
        seExId,
        result.methods,
        settings,
        result.nodeKey,    // <-- pass the new last_node here
      );

      

    }
  }



Future<_AutoSettings?> _loadAutoSettings(int presetId) async {
    final auto = await _repo.fetchPresetAutoSettings(presetId);
    if (auto == null || (auto['is_automatic'] as int) != 1) return null;

    bool intToBool(int v) => v == 1;
    return _AutoSettings(
      globalIncrement: (auto['global_increment'] as num).toDouble(),
      skipFirst:       intToBool(auto['skip_first_set'] as int),
      weightCheck:     intToBool(auto['weight_check']   as int),
      repCheck:        intToBool(auto['rep_check']      as int),
      volumeCheck:     intToBool(auto['volume_check']   as int),
      adjustAllSets:   intToBool(auto['adjust_all_sets'] as int),
    );
  }



/// Returns true if the *target* set (or all sets) should be
  /// considered a “success” under the three toggles.
  Future<bool> _determineSuccessForTarget(
    int presetExerciseId,
    int sessionExerciseId,
    _AutoSettings settings,
  ) async {
    final exAuto    = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    int lastIdx     = exAuto?['last_set_index'] as int? ?? 1;
    if (settings.skipFirst && lastIdx == 1) lastIdx = 2;

    final presetSets = await _repo.fetchPresetSets(presetExerciseId);
    final parents    = presetSets.where((r) => r['parent_set_id'] == null).toList();
    if (lastIdx > parents.length) {
      lastIdx = (settings.skipFirst && parents.length >= 2) ? 2 : 1;
    }

    final sessionSets = await _repo.fetchSets(sessionExerciseId);
    final perfParents = sessionSets.where((r) => r['parent_set_id'] == null).toList();
    if (perfParents.length < lastIdx) return false;

    final perf = perfParents[lastIdx - 1];
    final w    = (perf['weight'] as num).toDouble();
    final r    = perf['reps']   as int;
    final vol  = w * r;

    final tgt   = parents[lastIdx - 1];
    final tW    = (tgt['weight'] as num).toDouble();
    final tR    = (tgt['reps']   as num).toInt();
    final tVol  = tW * tR;

    if (settings.weightCheck && w < tW)    return false;
    if (settings.repCheck    && r < tR)    return false;
    if (settings.volumeCheck && vol < tVol) return false;

    return true;
  }



/// Applies each FlowMethod in order to your preset‐sets.
  Future<void> _applyMethods(
    int presetExerciseId,
    int sessionExerciseId,
    List<FlowMethod> methods,
    _AutoSettings settings,
     String? newLastNode,
  ) async {
    // 1) Load current parent sets
    final allSets = await _repo.fetchPresetSets(presetExerciseId);
    final parents = allSets.where((r) => r['parent_set_id'] == null).toList();
    if (parents.isEmpty) return;

    // 2) Compute lastIdx (not changing it here)
    final exAuto = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    int lastIdx  = exAuto?['last_set_index'] as int? ?? 1;
    if (settings.skipFirst && lastIdx == 1) lastIdx = 2;
    if (lastIdx > parents.length) {
      lastIdx = (settings.skipFirst && parents.length >= 2) ? 2 : 1;
    }

    // 3) Pick the target rows
    final targetRows = settings.adjustAllSets
      ? parents
      : [ parents[lastIdx - 1] ];

    // 4) Run each method
    for (final m in methods) {
      switch (m.type) {
      case MethodType.weight:
        final sign   = m.params['sign']   as String;
        final factor = m.params['factor'] as double;

        for (var row in targetRows) {
          final setId = row['id'] as int;

          // ① Try per‐set override
          double ia = settings.globalIncrement;
          final setAuto = await _repo.fetchPresetSetAuto(setId);
          if (setAuto != null && setAuto['increment_amount'] != null) {
            ia = (setAuto['increment_amount'] as num).toDouble();
          } else {
            // ② Fallback to per‐exercise override
            final exAuto = await _repo.fetchPresetExerciseAuto(presetExerciseId);
            if (exAuto != null && exAuto['increment_amount'] != null) {
              ia = (exAuto['increment_amount'] as num).toDouble();
            }
          }

          // ③ Now apply your equation: old ± factor * ia
          final oldW  = (row['weight'] as num).toDouble();
          final delta = factor * ia;
          final newW  = (sign == '+')
            ? oldW + delta
            : max(0.0, oldW - delta);

          await _repo.updatePresetSetWeight(setId, newW);
        }
        break;

        case MethodType.rep:
          final sign = m.params['sign']   as String;
          final amt  = m.params['amount'] as int;
          for (var row in targetRows) {
            final id   = row['id'] as int;
            final oldR = row['reps'] as int;
            final newR = (sign == '+')
              ? oldR + amt
              : max(0, oldR - amt);
            await _repo.updatePresetSetReps(id, newR);
          }
          break;

        case MethodType.addSet:
          // Compute insertion index at end
          final nextIdx = parents.length + 1;
          if (m.params.containsKey('weight')) {
            // explicit
            final w = (m.params['weight'] as num).toDouble();
            final r = (m.params['reps']   as num).toInt();
            await _repo.addPresetSet(
              presetExerciseId: presetExerciseId,
              weight: w,
              reps:   r,
              orderIndex: nextIdx,
              parentSetId: null,
            );
          } else {
            // copy from an existing
            final idx = (m.params['copyFromSetIndex'] as int);
            final src = (idx < 0 ? parents.last : parents[idx]);
            await _repo.addPresetSet(
              presetExerciseId: presetExerciseId,
              weight: (src['weight'] as num).toDouble(),
              reps:   (src['reps']   as num).toInt(),
              orderIndex: nextIdx,
              parentSetId: null,
            );
          }
          // Refresh our in-memory list for any subsequent methods
          parents.addAll(await _repo.fetchPresetSets(presetExerciseId)
            .then((rows) => rows.where((r) => r['parent_set_id']==null)));
          break;

        case MethodType.delSet:
          // delete last parent
          final last = parents.removeLast();
          await _repo.deletePresetSet(last['id'] as int);
          break;
      }

    }

      // ─── 5) rotate & persist the set‐pointer, if not "adjust all" ───
  if (!settings.adjustAllSets) {
    // compute next index (wrap around, honor skipFirst)
    int nextIdx = lastIdx + 1;
    if (nextIdx > parents.length) {
      nextIdx = (settings.skipFirst && parents.length >= 2) ? 2 : 1;
    }

    // fetch the existing per-exercise auto so we preserve incrementAmount + lastNode
    final exAuto2 = await _repo.fetchPresetExerciseAuto(presetExerciseId);

    await _repo.upsertPresetExerciseAuto(
      presetExerciseId: presetExerciseId,
      incrementAmount:  exAuto2?['increment_amount'] as double?,
      lastSetIndex:     nextIdx,
      lastNode:         newLastNode,   // <-- persist the updated flow position
    );
  }

  }


  
}
