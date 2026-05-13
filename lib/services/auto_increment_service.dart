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

  _AutoSettings({
    required this.globalIncrement,
    required this.skipFirst,
    required this.weightCheck,
    required this.repCheck,
    required this.volumeCheck,
    required this.adjustAllSets,

    required this.useManualSelect,
    required this.manualSelections,
  });
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

    final flowDefFuture = _repo.fetchFlowDefinition(presetId);
    final methodsFuture = _repo.fetchFlowMethods(presetId);
    final presetExercisesFuture = _repo.fetchPresetExercises(presetId);
    final sessionExercisesFuture = _repo.fetchExercises(sessionId);

    final flowDef = await flowDefFuture;
    final methods = await methodsFuture;
    final executor = FlowExecutor(flowDef: flowDef, methods: methods);

    final presetExercises = await presetExercisesFuture;
    final sessionExercises = await sessionExercisesFuture;

    for (
      var i = 0;
      i < presetExercises.length && i < sessionExercises.length;
      i++
    ) {
      final pe = presetExercises[i];
      final se = sessionExercises[i];
      if (pe['type'] != 'weight') continue;

      final peId = pe['id'] as int;
      final seExId = se['id'] as int;

      // Compare the completed exercise against the preset target before
      // deciding which flow branch to traverse.
      final isSuccess = await _determineSuccessForTarget(
        peId,
        seExId,
        settings,
      );

      final exAuto = await _repo.fetchPresetExerciseAuto(peId);
      final lastNodeKey = exAuto?['last_node'] as String?;

      final result = executor.traverse(
        lastNodeKey: lastNodeKey,
        outcome: isSuccess,
      );
      await _applyMethods(peId, result.methods, settings, result.nodeKey);
    }
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
    );
  }

  /// Returns true when the selected completed set satisfies the preset target
  /// under the enabled weight, rep, and volume checks.
  Future<bool> _determineSuccessForTarget(
    int presetExerciseId,
    int sessionExerciseId,
    _AutoSettings settings,
  ) async {
    final parents = await _fetchParentSets(presetExerciseId);
    if (parents.isEmpty) return false;
    final lastIdx = await _computeLastIndex(
      presetExerciseId,
      parents.length,
      settings.skipFirst,
    );

    final sessionSets = await _repo.fetchSets(sessionExerciseId);
    final perfParents =
        sessionSets.where((r) => r['parent_set_id'] == null).toList();
    if (perfParents.length < lastIdx) return false;

    final perf = perfParents[lastIdx - 1];
    final w = (perf['weight'] as num).toDouble();
    final r = perf['reps'] as int;
    final vol = w * r;

    final tgt = parents[lastIdx - 1];
    final tW = (tgt['weight'] as num).toDouble();
    final tR = (tgt['reps'] as num).toInt();
    final tVol = tW * tR;

    if (settings.weightCheck && w < tW) return false;
    if (settings.repCheck && r < tR) return false;
    if (settings.volumeCheck && vol < tVol) return false;

    return true;
  }

  /// Applies each flow method to the selected future preset sets.
  Future<void> _applyMethods(
    int presetExerciseId,
    List<FlowMethod> methods,
    _AutoSettings settings,
    String? newLastNode,
  ) async {
    final parents = await _fetchParentSets(presetExerciseId);
    if (parents.isEmpty) return;

    final lastIdx = await _computeLastIndex(
      presetExerciseId,
      parents.length,
      settings.skipFirst,
    );

    final allSets = await _repo.fetchPresetSets(presetExerciseId);
    final targets = _selectTargetRows(settings, allSets, parents, lastIdx);

    for (final m in methods) {
      switch (m.type) {
        case MethodType.weight:
          final sign = m.params['sign'] as String;
          final factor = m.params['factor'] as double;

          for (var row in targets) {
            final setId = row['id'] as int;
            final ia = await _resolveIncrementAmount(
              presetExerciseId,
              setId,
              settings,
            );
            final oldW = (row['weight'] as num).toDouble();
            final newW =
                (sign == '+')
                    ? oldW + factor * ia
                    : max(0.0, oldW - factor * ia);
            await _repo.updatePresetSetWeight(setId, newW);
          }
          break;

        case MethodType.rep:
          final sign = m.params['sign'] as String;
          final amt = m.params['amount'] as int;
          for (var row in targets) {
            final id = row['id'] as int;
            final oldR = row['reps'] as int;
            final newR = (sign == '+') ? oldR + amt : max(0, oldR - amt);
            await _repo.updatePresetSetReps(id, newR);
          }
          break;

        case MethodType.addSet:
          parents.addAll(await _fetchParentSets(presetExerciseId));
          break;

        case MethodType.delSet:
          final last = parents.removeLast();
          await _repo.deletePresetSet(last['id'] as int);
          break;
      }
    }

    if (!settings.adjustAllSets && !settings.useManualSelect) {
      await _rotatePointer(
        presetExerciseId,
        lastIdx,
        settings.skipFirst,
        newLastNode,
        parents.length,
      );
    }
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

  /// Returns only top-level preset sets, excluding child change sets.
  Future<List<Map<String, dynamic>>> _fetchParentSets(
    int presetExerciseId,
  ) async {
    final allSets = await _repo.fetchPresetSets(presetExerciseId);
    return allSets.where((r) => r['parent_set_id'] == null).toList();
  }

  /// Chooses the next parent-set index to evaluate for rotating auto mode.
  Future<int> _computeLastIndex(
    int presetExerciseId,
    int parentCount,
    bool skipFirst,
  ) async {
    final exAuto = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    int idx = exAuto?['last_set_index'] as int? ?? 1;
    if (skipFirst && idx == 1) idx = 2;
    if (idx > parentCount) {
      idx = (skipFirst && parentCount >= 2) ? 2 : 1;
    }
    return idx;
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

  /// Selects the preset set rows that should receive flow method updates.
  List<Map<String, dynamic>> _selectTargetRows(
    _AutoSettings settings,
    List<Map<String, dynamic>> allSets,
    List<Map<String, dynamic>> parents,
    int lastIdx,
  ) {
    if (settings.useManualSelect) {
      return allSets
          .where((r) => settings.manualSelections[r['id'] as int] == true)
          .toList();
    }
    if (settings.adjustAllSets) return parents;
    return [parents[lastIdx - 1]];
  }

  /// Advances the rotating set pointer and persists the latest flow node.
  Future<void> _rotatePointer(
    int presetExerciseId,
    int lastIdx,
    bool skipFirst,
    String? newLastNode,
    int parentCount,
  ) async {
    int nextIdx = lastIdx + 1;
    if (nextIdx > parentCount) {
      nextIdx = (skipFirst && parentCount >= 2) ? 2 : 1;
    }
    final exAuto2 = await _repo.fetchPresetExerciseAuto(presetExerciseId);
    await _repo.upsertPresetExerciseAuto(
      presetExerciseId: presetExerciseId,
      incrementAmount: exAuto2?['increment_amount'] as double?,
      lastSetIndex: nextIdx,
      lastNode: newLastNode,
    );
  }
}
