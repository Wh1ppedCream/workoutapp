import 'package:sqflite/sqflite.dart';

import '../models/preset_models.dart';
import 'preset_progression_dao.dart';

/// Durable handoff between workout completion and automatic plan progression.
class PendingWorkoutProgressionDao {
  static Future<void> enqueue(
    DatabaseExecutor db, {
    required int sessionId,
    required int presetId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('pending_workout_progression', {
      'session_id': sessionId,
      'preset_id': presetId,
      'created_at': now,
      'updated_at': now,
      'attempt_count': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> loadAll(DatabaseExecutor db) async {
    final rows = await db.query(
      'pending_workout_progression',
      orderBy: 'created_at ASC, session_id ASC',
    );
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  static Future<void> recordFailedAttempt(
    DatabaseExecutor db,
    int sessionId,
  ) async {
    await db.rawUpdate(
      '''
      UPDATE pending_workout_progression
      SET attempt_count = attempt_count + 1,
          updated_at = ?
      WHERE session_id = ?
      ''',
      [DateTime.now().toUtc().toIso8601String(), sessionId],
    );
  }

  /// Applies the deterministic batch and acknowledges its job atomically.
  static Future<void> applyAndDelete(
    Database db, {
    required int sessionId,
    required PresetProgressionBatch progression,
  }) async {
    await db.transaction((txn) async {
      final jobs = await txn.query(
        'pending_workout_progression',
        columns: ['session_id'],
        where: 'session_id = ?',
        whereArgs: [sessionId],
        limit: 1,
      );
      if (jobs.isEmpty) return;
      await PresetProgressionDao.applyInTransaction(txn, progression);
      await txn.delete(
        'pending_workout_progression',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    });
  }
}
