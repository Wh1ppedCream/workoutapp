// File: lib/services/auto_increment_service.dart

import 'dart:math';
import '../repositories/app_repository.dart';

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
  Future<void> apply({required int sessionId, required int presetId}) async {
    final settings = await _loadAutoSettings(presetId);
    if (settings == null) return;

    final presetExercises = await _repo.fetchPresetExercises(presetId);
    final sessionExercises = await _repo.fetchExercises(sessionId);

    for (var i = 0;
        i < presetExercises.length && i < sessionExercises.length;
        i++) {
      final pe = presetExercises[i];
      final se = sessionExercises[i];
      if (pe['type'] != 'weight') continue;
      await _processExercise(pe, se, settings);
    }
  }

  Future<_AutoSettings?> _loadAutoSettings(int presetId) async {
    final auto = await _repo.fetchPresetAutoSettings(presetId);
    if (auto == null || (auto['is_automatic'] as int) != 1) return null;

    double globalIA = (auto['global_increment'] as num).toDouble();
    bool skipFirst = (auto['skip_first_set'] as int) == 1;
    bool intToBool(int v) => v == 1;

    return _AutoSettings(
      globalIncrement: globalIA,
      skipFirst: skipFirst,
      weightCheck: intToBool(auto['weight_check'] as int),
      repCheck: intToBool(auto['rep_check'] as int),
      volumeCheck: intToBool(auto['volume_check'] as int),
      adjustAllSets: intToBool(auto['adjust_all_sets']),
    );
  }

  Future<void> _processExercise(
    Map<String, dynamic> pe,
    Map<String, dynamic> se,
    _AutoSettings settings,
  ) async {
    final peId = pe['id'] as int;
    final seExId = se['id'] as int;

    final exAuto = await _repo.fetchPresetExerciseAuto(peId);
    int lastIdx = _resolveLastIdx(exAuto, settings.skipFirst);

    final presetSets = await _repo.fetchPresetSets(peId);
    final parentRows =
        presetSets.where((r) => r['parent_set_id'] == null).toList();
    if (parentRows.isEmpty) return;

    lastIdx = _clampLastIdx(lastIdx, parentRows.length, settings.skipFirst);

    // If the user has chosen “Adjust All sets,” loop through every parent set:
  if (settings.adjustAllSets) {
    // Determine the first index we should adjust
    final startIdx = (settings.skipFirst && parentRows.length >= 2) ? 2 : 1;

    for (var idx = startIdx; idx <= parentRows.length; idx++) {
      final row    = parentRows[idx - 1];
      final setId  = row['id'] as int;
      final w0     = (row['weight'] as num).toDouble();
      final r0     = row['reps']   as int;

      // pick the correct IA for this set (per-set → per-exercise → global)
      final ia = await _resolveIncrementAmount(setId, exAuto, settings.globalIncrement);

      // decide success / failure for this set
      final success = await _determineSuccess(
        seExId,
        idx,
        w0,
        r0,
        settings,
      );

      // compute and persist the new weight
      final newW = _computeNewWeight(w0, success, ia);
      await _persistUpdatedTarget(setId, newW);
    }

    // when adjusting ALL sets, we do _not_ change the “lastSetIndex” pointer
    return;
  }

    // ───────────────────────────────────────────────────────────
  // Single‐set mode (unchanged from before)
  //
  // 1) Target the single set at lastIdx
    final target = parentRows[lastIdx - 1];
    final setId = target['id'] as int;

    final ia = await _resolveIncrementAmount(setId, exAuto, settings.globalIncrement);
    final targetWeight = (target['weight'] as num).toDouble();
    final targetReps = (target['reps'] as int);

    final success = await _determineSuccess(
      seExId,
      lastIdx,
      targetWeight,
      targetReps,
      settings,
    );

    final newWeight = _computeNewWeight(targetWeight, success, ia);
    await _persistUpdatedTarget(setId, newWeight);

    final nextIdx =
        _computeNextIdx(lastIdx, parentRows.length, settings.skipFirst);
    await _saveNextPointer(
      peId,
      exAuto?['increment_amount'] as double?,
      nextIdx,
    );
  }

  int _resolveLastIdx(Map<String, dynamic>? exAuto, bool skipFirst) {
    int lastIdx = exAuto?['last_set_index'] as int? ?? 1;
    if (skipFirst && lastIdx == 1) lastIdx = 2;
    return lastIdx;
  }

  int _clampLastIdx(int lastIdx, int parentCount, bool skipFirst) {
    if (lastIdx > parentCount) {
      return (skipFirst && parentCount >= 2) ? 2 : 1;
    }
    return lastIdx;
  }

  Future<double> _resolveIncrementAmount(
    int setId,
    Map<String, dynamic>? exAuto,
    double globalIA,
  ) async {
    double ia = globalIA;
    final setAuto = await _repo.fetchPresetSetAuto(setId);
    if (setAuto != null && setAuto['increment_amount'] != null) {
      ia = (setAuto['increment_amount'] as num).toDouble();
    } else if (exAuto != null && exAuto['increment_amount'] != null) {
      ia = (exAuto['increment_amount'] as num).toDouble();
    }
    return ia;
  }

  Future<bool> _determineSuccess(
    int seExId,
    int lastIdx,
    double targetWeight,
    int targetReps,
    _AutoSettings settings,
  ) async {
    final sessionSets = await _repo.fetchSets(seExId);
    final perfParents =
        sessionSets.where((r) => r['parent_set_id'] == null).toList();
    if (perfParents.length < lastIdx) return false;

    final perf = perfParents[lastIdx - 1];
    final w = (perf['weight'] as num).toDouble();
    final r = perf['reps'] as int;
    final perfVol = w * r;
    final targetVol = targetWeight * targetReps;

    if (settings.weightCheck && w < targetWeight) return false;
    if (settings.repCheck && r < targetReps) return false;
    if (settings.volumeCheck && perfVol < targetVol) return false;

    return true;
  }

  double _computeNewWeight(double targetWeight, bool success, double ia) {
    return success ? targetWeight + ia : max(0.0, targetWeight - 2 * ia);
  }

  Future<void> _persistUpdatedTarget(int setId, double newWeight) async {
    await _repo.updatePresetSetWeight(setId, newWeight);
  }

  int _computeNextIdx(int lastIdx, int parentCount, bool skipFirst) {
    int nextIdx = lastIdx + 1;
    if (nextIdx > parentCount) {
      nextIdx = (skipFirst && parentCount >= 2) ? 2 : 1;
    }
    return nextIdx;
  }

  Future<void> _saveNextPointer(
    int presetExerciseId,
    double? incrementAmount,
    int nextIdx,
  ) async {
    await _repo.upsertPresetExerciseAuto(
      presetExerciseId: presetExerciseId,
      incrementAmount: incrementAmount,
      lastSetIndex: nextIdx,
    );
  }
}
