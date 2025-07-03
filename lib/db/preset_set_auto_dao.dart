
// File: lib/db/preset_set_auto_dao.dart

import 'package:sqflite/sqflite.dart';

/// DAO for managing per‑set automatic‐preset overrides.
class PresetSetAutoDao {
  /// Reads the auto override for a given preset_set.
  static Future<Map<String, dynamic>?> getSetAuto(
    Database db,
    int presetSetId,
  ) async {
    final rows = await db.query(
      'preset_set_auto',
      where: 'preset_set_id = ?',
      whereArgs: [presetSetId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Inserts or updates the auto override for a preset set.
  static Future<void> upsertSetAuto(
    Database db, {
    required int presetSetId,
    double? incrementAmount,
  }) async {
    await db.insert(
      'preset_set_auto',
      {
        'preset_set_id': presetSetId,
        'increment_amount': incrementAmount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the auto override for a preset set.
  static Future<int> deleteSetAuto(
    Database db,
    int presetSetId,
  ) {
    return db.delete(
      'preset_set_auto',
      where: 'preset_set_id = ?',
      whereArgs: [presetSetId],
    );
  }
}
