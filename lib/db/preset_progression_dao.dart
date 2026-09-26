import 'package:sqflite/sqflite.dart';

import '../models/preset_models.dart';
import '../services/preset_progression_batch_validator.dart';

/// Commits all plan mutations produced by one progression evaluation.
class PresetProgressionDao {
  static Future<void> apply(
    Database db,
    PresetProgressionBatch progression,
  ) async {
    if (progression.isEmpty) return;
    await db.transaction((txn) async {
      await applyInTransaction(txn, progression);
    });
  }

  static Future<void> applyInTransaction(
    DatabaseExecutor db,
    PresetProgressionBatch progression,
  ) async {
    PresetProgressionBatchValidator.validateOrThrow(progression);
    for (final setId in progression.deletedSetIds) {
      await db.delete('preset_sets', where: 'id = ?', whereArgs: [setId]);
    }
    for (final update in progression.updates) {
      await db.update(
        'preset_sets',
        {
          'weight': update.weight,
          'reps': update.reps,
          'order_index': update.orderIndex,
        },
        where: 'id = ?',
        whereArgs: [update.setId],
      );
    }
    for (final insert in progression.inserts) {
      await db.insert('preset_sets', {
        'preset_exercise_id': insert.presetExerciseId,
        'weight': insert.weight,
        'reps': insert.reps,
        'order_index': insert.orderIndex,
        'parent_set_id': null,
      });
    }
    for (final state in progression.exerciseStates) {
      await db.insert('preset_exercise_auto', {
        'preset_exercise_id': state.presetExerciseId,
        'increment_amount': state.incrementAmount,
        'last_set_index': state.lastSetIndex,
        'last_node': state.lastNode,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
