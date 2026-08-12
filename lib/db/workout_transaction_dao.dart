import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'active_workout_dao.dart';
import 'pending_workout_progression_dao.dart';
import 'workout_record_events_dao.dart';

/// Atomic writes for completed and edited workout-session graphs.
class WorkoutTransactionDao {
  static Future<int> completeWorkout(
    Database db, {
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
    int? autoPresetId,
  }) {
    if (exercises.isEmpty) {
      throw ArgumentError.value(
        exercises,
        'exercises',
        'A completed workout must contain completed work.',
      );
    }
    return db.transaction((txn) async {
      final sessionId = await txn.insert('sessions', {
        'date': completedAt.toIso8601String(),
        'duration': durationSeconds,
      });
      final definitionIds = await _insertExercises(
        txn,
        sessionId,
        exercises,
        updateStats: true,
      );
      await ActiveWorkoutDao.clear(txn);
      if (autoPresetId != null) {
        await PendingWorkoutProgressionDao.enqueue(
          txn,
          sessionId: sessionId,
          presetId: autoPresetId,
        );
      }
      await WorkoutRecordEventsDao.rebuildForDefinitions(txn, definitionIds);
      return sessionId;
    });
  }

  static Future<void> replaceSessionExercises(
    Database db, {
    required int sessionId,
    required List<WorkoutExerciseWrite> exercises,
  }) async {
    await db.transaction((txn) async {
      final touchedDefinitionIds = await _sessionDefinitionIds(txn, sessionId);
      touchedDefinitionIds.addAll(
        exercises.map((item) => item.definitionId).whereType<int>(),
      );
      await txn.delete(
        'exercises',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
      final insertedDefinitionIds = await _insertExercises(
        txn,
        sessionId,
        exercises,
        updateStats: false,
      );
      touchedDefinitionIds.addAll(insertedDefinitionIds);
      await _clearStoredStats(txn, touchedDefinitionIds);
      await WorkoutRecordEventsDao.rebuildForDefinitions(
        txn,
        touchedDefinitionIds,
      );
    });
  }

  static Future<void> deleteSession(Database db, int sessionId) async {
    await db.transaction((txn) async {
      final definitionIds = await _sessionDefinitionIds(txn, sessionId);
      await txn.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
      await _clearStoredStats(txn, definitionIds);
      await WorkoutRecordEventsDao.rebuildForDefinitions(txn, definitionIds);
    });
  }

  static Future<Set<int>> _insertExercises(
    Transaction txn,
    int sessionId,
    List<WorkoutExerciseWrite> exercises, {
    required bool updateStats,
  }) async {
    final definitionIds = <int>{};
    for (var index = 0; index < exercises.length; index++) {
      final item = exercises[index];
      final exercise = item.exercise;
      final definitionId =
          item.type == 'weight'
              ? item.definitionId ??
                  await _resolveDefinitionId(
                    txn,
                    exercise.name,
                    exercise.equipment,
                  )
              : item.definitionId;
      final exerciseId = await txn.insert('exercises', {
        'session_id': sessionId,
        'exercise_def_id': definitionId,
        'type': item.type,
        'order_index': index,
        'source_preset_exercise_id': item.sourcePresetExerciseId,
      });

      if (exercise is WeightExercise) {
        await _insertWeightSets(txn, exerciseId, exercise);
        if (definitionId != null) definitionIds.add(definitionId);
        if (updateStats && definitionId != null) {
          await _updateStoredStats(txn, definitionId, exercise.sets);
        }
      } else if (exercise is CardioExercise) {
        await txn.insert('cardio_details', {
          'exercise_id': exerciseId,
          'cardio_name': exercise.cardioName,
          'note': exercise.cardioNote,
          'planned_minutes': exercise.plannedMinutes,
          'elapsed_seconds': exercise.elapsedSeconds,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } else if (exercise is StretchExercise) {
        for (final stretch in exercise.stretchInstances) {
          await txn.insert('stretch_instance_items', {
            'exercise_id': exerciseId,
            'stretch_id': stretch.stretchId,
            'is_custom': stretch.isCustom ? 1 : 0,
            'custom_name': stretch.customName,
            'custom_desc': stretch.customDesc,
            'is_checked': stretch.isChecked ? 1 : 0,
            'order_index': stretch.orderIndex,
          });
        }
      }
    }
    return definitionIds;
  }

  static Future<void> _insertWeightSets(
    Transaction txn,
    int exerciseId,
    WeightExercise exercise,
  ) async {
    for (var index = 0; index < exercise.sets.length; index++) {
      final parent = exercise.sets[index];
      final parentId = await txn.insert('sets', {
        'exercise_id': exerciseId,
        'weight': parent.weight,
        'reps': parent.reps,
        'order_index': index,
        'parent_set_id': null,
        'source_preset_set_id': parent.sourcePresetSetId,
      });
      final children = exercise.changeSets[index] ?? const <ExerciseSet>[];
      for (var childIndex = 0; childIndex < children.length; childIndex++) {
        final child = children[childIndex];
        await txn.insert('sets', {
          'exercise_id': exerciseId,
          'weight': child.weight,
          'reps': child.reps,
          'order_index': childIndex,
          'parent_set_id': parentId,
          'source_preset_set_id': child.sourcePresetSetId,
        });
      }
    }
  }

  static Future<int> _resolveDefinitionId(
    Transaction txn,
    String name,
    String equipmentName,
  ) async {
    int? equipmentId;
    if (equipmentName.trim().isNotEmpty) {
      final equipmentRows = await txn.query(
        'equipment',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [equipmentName],
        limit: 1,
      );
      equipmentId =
          equipmentRows.isEmpty ? null : equipmentRows.first['id'] as int;
    }

    final rows = await txn.rawQuery('''
      SELECT ed.id
      FROM exercise_definitions ed
      LEFT JOIN exercise_equipment ee ON ee.exercise_id = ed.id
      WHERE ed.name = ?
        AND (${equipmentId == null ? 'ed.equipment_id IS NULL' : 'ed.equipment_id = ? OR ee.equipment_id = ?'})
      LIMIT 1
      ''', equipmentId == null ? [name] : [name, equipmentId, equipmentId]);
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return txn.insert('exercise_definitions', {
      'name': name,
      'equipment_id': equipmentId,
    });
  }

  static Future<Set<int>> _sessionDefinitionIds(
    Transaction txn,
    int sessionId,
  ) async {
    final rows = await txn.query(
      'exercises',
      columns: ['exercise_def_id'],
      where: 'session_id = ? AND exercise_def_id IS NOT NULL',
      whereArgs: [sessionId],
    );
    return rows.map((row) => row['exercise_def_id'] as int).toSet();
  }

  static Future<void> _clearStoredStats(
    Transaction txn,
    Set<int> definitionIds,
  ) async {
    for (final definitionId in definitionIds) {
      await txn.delete(
        'exercise_rep_max',
        where: 'def_id = ?',
        whereArgs: [definitionId],
      );
      await txn.delete(
        'exercise_volume_max',
        where: 'def_id = ?',
        whereArgs: [definitionId],
      );
    }
  }

  static Future<void> _updateStoredStats(
    Transaction txn,
    int definitionId,
    List<ExerciseSet> sets,
  ) async {
    var sessionVolumeMax = 0.0;
    for (final set in sets) {
      sessionVolumeMax = max(sessionVolumeMax, set.weight * set.reps);
      final oneErm = set.weight * (1 + 0.0333 * set.reps);
      final existing = await txn.query(
        'exercise_rep_max',
        columns: ['rm_value', 'one_erm'],
        where: 'def_id = ? AND rep_count = ? AND timeframe = ?',
        whereArgs: [definitionId, set.reps, 'all'],
        limit: 1,
      );
      final shouldWrite =
          existing.isEmpty ||
          oneErm > (existing.first['one_erm'] as num).toDouble() ||
          (oneErm == (existing.first['one_erm'] as num).toDouble() &&
              set.weight > (existing.first['rm_value'] as num).toDouble());
      if (shouldWrite) {
        await txn.insert('exercise_rep_max', {
          'def_id': definitionId,
          'rep_count': set.reps,
          'timeframe': 'all',
          'rm_value': set.weight,
          'one_erm': oneErm,
          'is_erm': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    final existingVolume = await txn.query(
      'exercise_volume_max',
      columns: ['vm_value'],
      where: 'def_id = ? AND timeframe = ?',
      whereArgs: [definitionId, 'all'],
      limit: 1,
    );
    if (existingVolume.isEmpty ||
        sessionVolumeMax >
            (existingVolume.first['vm_value'] as num).toDouble()) {
      await txn.insert('exercise_volume_max', {
        'def_id': definitionId,
        'timeframe': 'all',
        'vm_value': sessionVolumeMax,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
