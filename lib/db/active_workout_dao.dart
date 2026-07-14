import 'package:sqflite/sqflite.dart';

import 'db_query_utils.dart';

/// Persists the single in-progress workout so it can survive process restarts.
class ActiveWorkoutDao {
  static Future<void> save(
    Database db, {
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('active_workout_draft', {
      'id': 1,
      'started_at': startedAt.toUtc().toIso8601String(),
      'auto_preset_id': autoPresetId,
      'payload_json': payloadJson,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> load(Database db) async {
    final rows = await db.query(
      'active_workout_draft',
      where: 'id = 1',
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  static Future<void> clear(DatabaseExecutor db) async {
    await db.delete('active_workout_draft', where: 'id = 1');
  }
}
