// File: lib/db/preset_auto_settings_dao.dart

import 'package:sqflite/sqflite.dart';

/// DAO for managing global automatic‐preset settings.
class PresetAutoSettingsDao {
  /// Reads the automatic settings for a given preset.
  /// Returns null if none exist.
  static Future<Map<String, dynamic>?> getAutoSettings(
    Database db,
    int presetId,
  ) async {
    final rows = await db.query(
      'preset_auto_settings',
      where: 'preset_id = ?',
      whereArgs: [presetId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Inserts or updates the automatic settings for a preset.
  static Future<void> upsertAutoSettings(
    Database db, {
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool   weightCheck,    // NEW
  required bool   repCheck,       // NEW
  required bool   volumeCheck,    // NEW
  required bool adjustAllSets,
  }) async {
    await db.insert(
      'preset_auto_settings',
      {
        'preset_id': presetId,
        'is_automatic': isAutomatic ? 1 : 0,
        'global_increment': globalIncrement,
        'skip_first_set': skipFirstSet ? 1 : 0,
      'weight_check'     : weightCheck    ? 1 : 0,  // NEW
      'rep_check'        : repCheck       ? 1 : 0,  // NEW
      'volume_check'     : volumeCheck    ? 1 : 0,  // NEW
      'adjust_all_sets':  adjustAllSets ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// Deletes the automatic settings for a preset (disables automatic).
  static Future<int> deleteAutoSettings(
    Database db,
    int presetId,
  ) {
    return db.delete(
      'preset_auto_settings',
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
  }
}

