// File: lib/services/auto_increment_service.dart

import 'dart:math';
import '../repositories/app_repository.dart';

/// Applies the auto-increment algorithm to a completed session
/// that was started from a preset.
class AutoIncrementService {
  final AppRepository _repo;

  /// Allows injecting a custom repo for tests; defaults to real.
  AutoIncrementService([AppRepository? repo]) : _repo = repo ?? AppRepository();

  /// Applies auto-increment for [sessionId] and [presetId].
  Future<void> apply({required int sessionId, required int presetId}) async {
    // 1) Load global settings
    final auto = await _repo.fetchPresetAutoSettings(presetId);
    if (auto == null || (auto['is_automatic'] as int) != 1) return;

    final globalIA = (auto['global_increment'] as num).toDouble();
    final skipFirst = (auto['skip_first_set'] as int) == 1;

    // 2) Load preset exercises and session exercises (same orderIndex)
    final presetExercises = await _repo.fetchPresetExercises(presetId);
    // final sessionExercises = await _repo.fetchExercisesRaw(sessionId);
    final sessionExercises = await _repo.fetchExercises(sessionId);

    // 3) For each weight exercise in the preset…
    for (var i = 0; i < presetExercises.length && i < sessionExercises.length; i++) {
      final pe = presetExercises[i];
      final se = sessionExercises[i];
      if (pe['type'] != 'weight') continue;

      final peId = pe['id'] as int;
      final seExId = se['id'] as int;

      // 4) Resolve this exercise's increment amount & pointer
      final exAuto = await _repo.fetchPresetExerciseAuto(peId);
int lastIdx = exAuto?['last_set_index'] as int? ?? 1;
if (skipFirst && lastIdx == 1) lastIdx = 2;

      // 5) Fetch preset's parent set rows
      final presetSets = await _repo.fetchPresetSets(peId);
      final parentRows = presetSets.where((r) => r['parent_set_id'] == null).toList();
      if (parentRows.isEmpty) continue;

      // Clamp pointer
      if (lastIdx > parentRows.length) {
        lastIdx = (skipFirst && parentRows.length >= 2) ? 2 : 1;
      }

      // 6) Determine success vs. failure
      // 6a) Target values
      final target = parentRows[lastIdx - 1];
      final setId     = target['id'] as int;

      // 6*) (start) Set IA values: THREE-TIER IA LOOKUP: set → exercise → global
double ia = globalIA;

// 6a) 1) set-level override?
final setAuto = await _repo.fetchPresetSetAuto(setId);
if (setAuto != null && setAuto['increment_amount'] != null) {
  ia = (setAuto['increment_amount'] as num).toDouble();
}
// 6b) 2) else exercise-level override?
else if (exAuto != null && exAuto['increment_amount'] != null) {
  ia = (exAuto['increment_amount'] as num).toDouble();
}
// 6c) 3) else globalIA (already set above)
// back to 6a)

      final targetWeight = (target['weight'] as num).toDouble();
      final targetReps   = target['reps'] as int;

      // 6b) Actual performance
      final sessionSets = await _repo.fetchSets(seExId);
      final perfParents = sessionSets.where((r) => r['parent_set_id'] == null).toList();
      final didPerform = perfParents.length >= lastIdx;
      bool success = false;
      if (didPerform) {
        final perf = perfParents[lastIdx - 1];
        final w = (perf['weight'] as num).toDouble();
        final r = perf['reps'] as int;
        success = (w >= targetWeight && r >= targetReps);
      }

      // 7) Compute new weight
      final newWeight = success
          ? targetWeight + ia
          : max(0.0, targetWeight - 2 * ia);

      // 8) Persist updated target
      await _repo.updatePresetSetWeight(setId, newWeight);

      // 9) Advance pointer (wrapping)
      int nextIdx = lastIdx + 1;
      if (nextIdx > parentRows.length) {
        nextIdx = (skipFirst && parentRows.length >= 2) ? 2 : 1;
      }

      // 10) Save the updated pointer (and preserve IA override)
      await _repo.upsertPresetExerciseAuto(
        presetExerciseId: peId,
        incrementAmount: exAuto?['increment_amount'] as double?,
        lastSetIndex: nextIdx,
      );
    }
  }
}
