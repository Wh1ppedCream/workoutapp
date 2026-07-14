import 'package:sqflite/sqflite.dart';

/// Stores active/archived plan membership inside the exported app database.
class ActivePlanDao {
  static Future<Set<int>> load(Database db, int profileId) async {
    final rows = await db.query(
      'active_plans',
      columns: ['preset_id'],
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'activated_at, preset_id',
    );
    return rows.map((row) => row['preset_id'] as int).toSet();
  }

  static Future<void> replace(
    Database db,
    int profileId,
    Set<int> presetIds,
  ) async {
    await db.transaction((txn) async {
      await txn.delete(
        'active_plans',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      final now = DateTime.now().toUtc().toIso8601String();
      for (final presetId in presetIds) {
        await txn.insert('active_plans', {
          'profile_id': profileId,
          'preset_id': presetId,
          'activated_at': now,
        });
      }
    });
  }

  static Future<void> add(Database db, int profileId, int presetId) async {
    await db.insert('active_plans', {
      'profile_id': profileId,
      'preset_id': presetId,
      'activated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> remove(Database db, int profileId, int presetId) async {
    await db.delete(
      'active_plans',
      where: 'profile_id = ? AND preset_id = ?',
      whereArgs: [profileId, presetId],
    );
  }
}
