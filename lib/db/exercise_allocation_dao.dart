import 'package:sqflite/sqflite.dart';

import '../models/exercise_allocation_models.dart';

/// Persistence for source-aware exercise allocation values.
///
/// Creator defaults are managed by bundled exercise content. Personal rows are
/// local-only and always win over creator and automatic values.
class ExerciseAllocationDao {
  static Future<Set<ExerciseAllocationDimension>> fetchPersonalDimensions(
    DatabaseExecutor db,
    int exerciseDefinitionId,
  ) async {
    final rows = await db.query(
      'exercise_allocation_source',
      columns: ['muscle_mode', 'bodypart_mode'],
      where: 'exercise_def_id = ?',
      whereArgs: [exerciseDefinitionId],
      limit: 1,
    );
    if (rows.isEmpty) return <ExerciseAllocationDimension>{};

    final row = rows.first;
    final dimensions = <ExerciseAllocationDimension>{};
    if (row['muscle_mode'] == 'user') {
      dimensions.add(ExerciseAllocationDimension.muscle);
    }
    if (row['bodypart_mode'] == 'user') {
      dimensions.add(ExerciseAllocationDimension.bodyPart);
    }
    return dimensions;
  }

  static Future<Map<int, double>> fetchCredits(
    DatabaseExecutor db, {
    required String table,
    required int exerciseDefinitionId,
    required ExerciseAllocationDimension dimension,
  }) async {
    final rows = await db.query(
      table,
      columns: ['target_id', 'credit'],
      where: 'exercise_def_id = ? AND dimension = ?',
      whereArgs: [exerciseDefinitionId, dimension.storageName],
    );
    return <int, double>{
      for (final row in rows)
        row['target_id'] as int: (row['credit'] as num).toDouble(),
    };
  }

  static Future<void> replacePersonalCredits(
    Database db, {
    required int exerciseDefinitionId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) {
    return db.transaction((txn) async {
      await txn.delete(
        'exercise_allocation_user_override',
        where: 'exercise_def_id = ? AND dimension = ?',
        whereArgs: [exerciseDefinitionId, dimension.storageName],
      );
      for (final entry in credits.entries) {
        await txn.insert('exercise_allocation_user_override', {
          'exercise_def_id': exerciseDefinitionId,
          'dimension': dimension.storageName,
          'target_id': entry.key,
          'credit': entry.value,
        });
      }

      final existing = await txn.query(
        'exercise_allocation_source',
        columns: ['exercise_def_id'],
        where: 'exercise_def_id = ?',
        whereArgs: [exerciseDefinitionId],
        limit: 1,
      );
      final field =
          dimension == ExerciseAllocationDimension.muscle
              ? 'muscle_mode'
              : 'bodypart_mode';
      if (existing.isEmpty) {
        await txn.insert('exercise_allocation_source', {
          'exercise_def_id': exerciseDefinitionId,
          'muscle_mode':
              dimension == ExerciseAllocationDimension.muscle
                  ? 'user'
                  : 'automatic',
          'bodypart_mode':
              dimension == ExerciseAllocationDimension.bodyPart
                  ? 'user'
                  : 'automatic',
        });
      } else {
        await txn.update(
          'exercise_allocation_source',
          {field: 'user'},
          where: 'exercise_def_id = ?',
          whereArgs: [exerciseDefinitionId],
        );
      }
    });
  }

  static Future<void> resetPersonalCredits(
    Database db, {
    required int exerciseDefinitionId,
    required ExerciseAllocationDimension dimension,
  }) {
    return db.transaction((txn) async {
      await txn.delete(
        'exercise_allocation_user_override',
        where: 'exercise_def_id = ? AND dimension = ?',
        whereArgs: [exerciseDefinitionId, dimension.storageName],
      );
      final field =
          dimension == ExerciseAllocationDimension.muscle
              ? 'muscle_mode'
              : 'bodypart_mode';
      await txn.update(
        'exercise_allocation_source',
        {field: 'automatic'},
        where: 'exercise_def_id = ?',
        whereArgs: [exerciseDefinitionId],
      );
    });
  }

  static Future<void> replaceCreatorCredits(
    Database db, {
    required int exerciseDefinitionId,
    required ExerciseAllocationDimension dimension,
    required Map<int, double> credits,
  }) {
    return db.transaction((txn) async {
      await txn.delete(
        'exercise_allocation_creator_default',
        where: 'exercise_def_id = ? AND dimension = ?',
        whereArgs: [exerciseDefinitionId, dimension.storageName],
      );
      for (final entry in credits.entries) {
        await txn.insert('exercise_allocation_creator_default', {
          'exercise_def_id': exerciseDefinitionId,
          'dimension': dimension.storageName,
          'target_id': entry.key,
          'credit': entry.value,
        });
      }
    });
  }
}
