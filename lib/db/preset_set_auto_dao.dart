// File: lib/db/preset_set_auto_dao.dart

import 'package:sqflite/sqflite.dart';
import 'db_query_utils.dart';

/// DAO for managing per-set automatic-preset overrides.
class PresetSetAutoDao {
  static Map<String, Object?> _autoValues({
    required int presetSetId,
    double? incrementAmount,
  }) {
    return {'preset_set_id': presetSetId, 'increment_amount': incrementAmount};
  }

  /// Reads the auto override for a given preset set.
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
    return firstDynamicRow(rows);
  }

  /// Inserts or updates the auto override for a preset set.
  static Future<void> upsertSetAuto(
    Database db, {
    required int presetSetId,
    double? incrementAmount,
  }) async {
    await db.insert(
      'preset_set_auto',
      _autoValues(presetSetId: presetSetId, incrementAmount: incrementAmount),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the auto override for a preset set.
  static Future<int> deleteSetAuto(Database db, int presetSetId) {
    return db.delete(
      'preset_set_auto',
      where: 'preset_set_id = ?',
      whereArgs: [presetSetId],
    );
  }
}
