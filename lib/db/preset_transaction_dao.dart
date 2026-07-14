import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Atomic creation and replacement of complete workout-plan graphs.
class PresetTransactionDao {
  static Future<int> createPreset(
    Database db, {
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
  }) {
    return db.transaction((txn) async {
      final values = <String, Object?>{'name': name};
      if (profileId != null) values['profile_id'] = profileId;
      final presetId = await txn.insert('preset_definitions', values);
      final defaultFlow = await _copyDefaultProgression(
        txn,
        presetId,
        profileId,
      );
      await _insertExercises(txn, presetId, exercises);
      if (autoSettings != null) {
        await _writeAutoSettings(
          txn,
          presetId,
          autoSettings,
          defaultFlow,
          const <int, bool>{},
        );
      }
      if (activate && profileId != null) {
        await txn.insert('active_plans', {
          'profile_id': profileId,
          'preset_id': presetId,
          'activated_at': DateTime.now().toUtc().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return presetId;
    });
  }

  static Future<void> replacePreset(
    Database db, {
    required int presetId,
    required String? name,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
  }) async {
    await db.transaction((txn) async {
      if (name != null && name.trim().isNotEmpty) {
        await txn.update(
          'preset_definitions',
          {'name': name.trim()},
          where: 'id = ?',
          whereArgs: [presetId],
        );
      }

      final exerciseOverrides = <int, Map<String, Object?>>{};
      final setOverrides = <int, double>{};
      final oldExercises = await txn.query(
        'preset_exercises',
        columns: ['id'],
        where: 'preset_id = ?',
        whereArgs: [presetId],
      );
      for (final oldExercise in oldExercises) {
        final oldExerciseId = oldExercise['id'] as int;
        final exerciseAuto = await txn.query(
          'preset_exercise_auto',
          where: 'preset_exercise_id = ?',
          whereArgs: [oldExerciseId],
          limit: 1,
        );
        if (exerciseAuto.isNotEmpty) {
          exerciseOverrides[oldExerciseId] = Map<String, Object?>.from(
            exerciseAuto.first,
          );
        }
        final oldSets = await txn.query(
          'preset_sets',
          columns: ['id'],
          where: 'preset_exercise_id = ?',
          whereArgs: [oldExerciseId],
        );
        for (final oldSet in oldSets) {
          final oldSetId = oldSet['id'] as int;
          final setAuto = await txn.query(
            'preset_set_auto',
            columns: ['increment_amount'],
            where: 'preset_set_id = ?',
            whereArgs: [oldSetId],
            limit: 1,
          );
          final increment =
              setAuto.isEmpty
                  ? null
                  : (setAuto.first['increment_amount'] as num?)?.toDouble();
          if (increment != null) setOverrides[oldSetId] = increment;
        }
      }

      final existingSettings = await txn.query(
        'preset_auto_settings',
        where: 'preset_id = ?',
        whereArgs: [presetId],
        limit: 1,
      );
      final flowDefinition =
          existingSettings.isEmpty
              ? '{}'
              : existingSettings.first['flow_definition'] as String? ?? '{}';

      await txn.delete(
        'preset_exercises',
        where: 'preset_id = ?',
        whereArgs: [presetId],
      );

      final remappedManualSelections = <int, bool>{};
      for (var index = 0; index < exercises.length; index++) {
        final item = exercises[index];
        final newExerciseId = await _insertExerciseRow(
          txn,
          presetId,
          item,
          index,
          setOverrides: setOverrides,
          oldManualSelections:
              autoSettings?.manualSelections ?? const <int, bool>{},
          remappedManualSelections: remappedManualSelections,
        );
        final oldExerciseId = item.previousPresetExerciseId;
        final override =
            oldExerciseId == null ? null : exerciseOverrides[oldExerciseId];
        if (override != null) {
          final weightExercise =
              item.exercise is WeightExercise
                  ? item.exercise as WeightExercise
                  : null;
          var lastSetIndex = override['last_set_index'] as int? ?? 1;
          if (weightExercise != null &&
              (lastSetIndex < 1 || lastSetIndex > weightExercise.sets.length)) {
            lastSetIndex =
                autoSettings?.skipFirstSet == true &&
                        weightExercise.sets.length >= 2
                    ? 2
                    : 1;
          }
          await txn.insert('preset_exercise_auto', {
            'preset_exercise_id': newExerciseId,
            'increment_amount': override['increment_amount'],
            'last_set_index': lastSetIndex,
            'last_node': override['last_node'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (autoSettings != null) {
        await _writeAutoSettings(
          txn,
          presetId,
          autoSettings,
          flowDefinition,
          remappedManualSelections,
        );
      }
    });
  }

  /// Saves global, exercise, and set automatic settings in one transaction.
  static Future<void> saveAutoConfiguration(
    Database db, {
    required int presetId,
    required PresetAutoConfigurationWrite configuration,
  }) async {
    await db.transaction((txn) async {
      final existingSettings = await txn.query(
        'preset_auto_settings',
        columns: ['flow_definition'],
        where: 'preset_id = ?',
        whereArgs: [presetId],
        limit: 1,
      );
      final flowDefinition =
          existingSettings.isEmpty
              ? '{}'
              : existingSettings.first['flow_definition'] as String? ?? '{}';

      final exerciseRows = await txn.query(
        'preset_exercises',
        columns: ['id'],
        where: 'preset_id = ?',
        whereArgs: [presetId],
      );
      final validExerciseIds =
          exerciseRows.map((row) => row['id'] as int).toSet();
      final setRows = await txn.rawQuery(
        '''
        SELECT ps.id
        FROM preset_sets ps
        INNER JOIN preset_exercises pe ON pe.id = ps.preset_exercise_id
        WHERE pe.preset_id = ?
        ''',
        [presetId],
      );
      final validSetIds = setRows.map((row) => row['id'] as int).toSet();

      if (!validExerciseIds.containsAll(
            configuration.exerciseIncrements.keys,
          ) ||
          !validSetIds.containsAll(configuration.setIncrements.keys)) {
        throw StateError('Automatic settings contain stale plan rows.');
      }

      final validSelections = <int, bool>{
        for (final entry in configuration.settings.manualSelections.entries)
          if (validSetIds.contains(entry.key)) entry.key: entry.value,
      };
      await _writeAutoSettings(
        txn,
        presetId,
        configuration.settings,
        flowDefinition,
        validSelections,
      );

      for (final entry in configuration.exerciseIncrements.entries) {
        final existing = await txn.query(
          'preset_exercise_auto',
          columns: ['last_set_index', 'last_node'],
          where: 'preset_exercise_id = ?',
          whereArgs: [entry.key],
          limit: 1,
        );
        await txn.insert('preset_exercise_auto', {
          'preset_exercise_id': entry.key,
          'increment_amount': entry.value,
          'last_set_index':
              configuration.exerciseLastSetIndices[entry.key] ??
              (existing.isEmpty
                  ? 1
                  : existing.first['last_set_index'] as int? ?? 1),
          'last_node':
              existing.isEmpty ? null : existing.first['last_node'] as String?,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final entry in configuration.setIncrements.entries) {
        await txn.insert('preset_set_auto', {
          'preset_set_id': entry.key,
          'increment_amount': entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<String> _copyDefaultProgression(
    Transaction txn,
    int presetId,
    int? profileId,
  ) async {
    final scope = profileId == null ? 'app' : 'profile';
    final where =
        profileId == null
            ? 'scope = ? AND profile_id IS NULL'
            : 'scope = ? AND profile_id = ?';
    final args =
        profileId == null ? <Object?>[scope] : <Object?>[scope, profileId];
    final flowRows = await txn.query(
      'flow_defaults',
      columns: ['flow_json'],
      where: where,
      whereArgs: args,
      limit: 1,
    );
    final flow =
        flowRows.isEmpty
            ? '{}'
            : flowRows.first['flow_json'] as String? ?? '{}';
    final methods = await txn.query(
      'flow_default_methods',
      where: where,
      whereArgs: args,
    );
    if (flow.trim() != '{}' || methods.isNotEmpty) {
      await txn.insert('preset_auto_settings', {
        'preset_id': presetId,
        'is_automatic': 0,
        'global_increment': 5.0,
        'skip_first_set': 1,
        'weight_check': 1,
        'rep_check': 1,
        'volume_check': 0,
        'adjust_all_sets': 0,
        'use_manual_select': 0,
        'manual_selection_json': '{}',
        'success_count_mode': 'set',
        'flow_definition': flow,
      });
      for (final method in methods) {
        await txn.insert('preset_flow_methods', {
          'preset_id': presetId,
          'name': method['name'],
          'type': method['type'],
          'params': method['params'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    return flow;
  }

  static Future<void> _insertExercises(
    Transaction txn,
    int presetId,
    List<WorkoutExerciseWrite> exercises,
  ) async {
    for (var index = 0; index < exercises.length; index++) {
      await _insertExerciseRow(
        txn,
        presetId,
        exercises[index],
        index,
        setOverrides: const <int, double>{},
        oldManualSelections: const <int, bool>{},
        remappedManualSelections: <int, bool>{},
      );
    }
  }

  static Future<int> _insertExerciseRow(
    Transaction txn,
    int presetId,
    WorkoutExerciseWrite item,
    int orderIndex, {
    required Map<int, double> setOverrides,
    required Map<int, bool> oldManualSelections,
    required Map<int, bool> remappedManualSelections,
  }) async {
    final exerciseId = await txn.insert('preset_exercises', {
      'preset_id': presetId,
      'exercise_def_id': item.definitionId,
      'type': item.type,
      'order_index': orderIndex,
    });
    final exercise = item.exercise;
    if (exercise is WeightExercise) {
      for (
        var parentIndex = 0;
        parentIndex < exercise.sets.length;
        parentIndex++
      ) {
        final parent = exercise.sets[parentIndex];
        final parentId = await txn.insert('preset_sets', {
          'preset_exercise_id': exerciseId,
          'weight': parent.weight,
          'reps': parent.reps,
          'order_index': parentIndex,
          'parent_set_id': null,
        });
        await _restoreSetMetadata(
          txn,
          parent.sourcePresetSetId,
          parentId,
          setOverrides,
          oldManualSelections,
          remappedManualSelections,
        );
        final children =
            exercise.changeSets[parentIndex] ?? const <ExerciseSet>[];
        for (var childIndex = 0; childIndex < children.length; childIndex++) {
          final child = children[childIndex];
          final childId = await txn.insert('preset_sets', {
            'preset_exercise_id': exerciseId,
            'weight': child.weight,
            'reps': child.reps,
            'order_index': childIndex,
            'parent_set_id': parentId,
          });
          await _restoreSetMetadata(
            txn,
            child.sourcePresetSetId,
            childId,
            setOverrides,
            oldManualSelections,
            remappedManualSelections,
          );
        }
      }
    } else if (exercise is CardioExercise) {
      await txn.insert('preset_cardio_details', {
        'preset_exercise_id': exerciseId,
        'cardio_name': exercise.cardioName,
        'note': exercise.cardioNote,
        'planned_minutes': exercise.plannedMinutes,
        'elapsed_seconds': exercise.elapsedSeconds,
      });
    } else if (exercise is StretchExercise) {
      for (final stretch in exercise.stretchInstances) {
        await txn.insert('preset_stretch_items', {
          'preset_exercise_id': exerciseId,
          'stretch_id': stretch.stretchId,
          'is_custom': stretch.isCustom ? 1 : 0,
          'custom_name': stretch.customName,
          'custom_desc': stretch.customDesc,
          'order_index': stretch.orderIndex,
        });
      }
    }
    return exerciseId;
  }

  static Future<void> _restoreSetMetadata(
    Transaction txn,
    int? oldSetId,
    int newSetId,
    Map<int, double> setOverrides,
    Map<int, bool> oldManualSelections,
    Map<int, bool> remappedManualSelections,
  ) async {
    if (oldSetId == null) return;
    final increment = setOverrides[oldSetId];
    if (increment != null) {
      await txn.insert('preset_set_auto', {
        'preset_set_id': newSetId,
        'increment_amount': increment,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    final selected = oldManualSelections[oldSetId];
    if (selected != null) remappedManualSelections[newSetId] = selected;
  }

  static Future<void> _writeAutoSettings(
    Transaction txn,
    int presetId,
    PresetAutoSettingsWrite settings,
    String flowDefinition,
    Map<int, bool> remappedManualSelections,
  ) async {
    await txn.insert('preset_auto_settings', {
      'preset_id': presetId,
      'is_automatic': settings.isAutomatic ? 1 : 0,
      'global_increment': settings.globalIncrement,
      'skip_first_set': settings.skipFirstSet ? 1 : 0,
      'weight_check': settings.weightCheck ? 1 : 0,
      'rep_check': settings.repCheck ? 1 : 0,
      'volume_check': settings.volumeCheck ? 1 : 0,
      'adjust_all_sets': settings.adjustAllSets ? 1 : 0,
      'use_manual_select': settings.useManualSelect ? 1 : 0,
      'manual_selection_json': jsonEncode(
        remappedManualSelections.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
      'success_count_mode': settings.successCountMode,
      'flow_definition': flowDefinition,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
