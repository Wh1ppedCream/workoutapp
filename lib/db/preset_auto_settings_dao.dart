// File: lib/db/preset_auto_settings_dao.dart

import 'package:sqflite/sqflite.dart';
import 'db_query_utils.dart';

/// DAO for managing global automatic-preset settings.
class PresetAutoSettingsDao {
  static Future<Map<String, dynamic>?> _getByPresetId(
    Database db,
    int presetId, {
    List<String>? columns,
  }) async {
    final rows = await db.query(
      'preset_auto_settings',
      columns: columns,
      where: 'preset_id = ?',
      whereArgs: [presetId],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  /// Reads the automatic settings for a given preset.
  /// Returns null if none exist.
  static Future<Map<String, dynamic>?> getAutoSettings(
    Database db,
    int presetId,
  ) {
    return _getByPresetId(db, presetId);
  }

  /// Inserts or updates the automatic settings for a preset.
  static Future<void> upsertAutoSettings(
    Database db, {
    required int presetId,
    required bool isAutomatic,
    required double globalIncrement,
    required bool skipFirstSet,
    required bool weightCheck,
    required bool repCheck,
    required bool volumeCheck,
    required bool adjustAllSets,
    required bool useManualSelect,
    String? manualSelectionJson,
    String? successCountMode,
  }) async {
    final existing = await getAutoSettings(db, presetId);
    final existingFlowDef = existing?['flow_definition'] as String? ?? '{}';
    final existingManualJson =
        existing?['manual_selection_json'] as String? ?? '{}';
    final existingSuccessCountMode =
        existing?['success_count_mode'] as String? ?? 'set';

    final values = {
      'preset_id': presetId,
      'is_automatic': sqliteBool(isAutomatic),
      'global_increment': globalIncrement,
      'skip_first_set': sqliteBool(skipFirstSet),
      'weight_check': sqliteBool(weightCheck),
      'rep_check': sqliteBool(repCheck),
      'volume_check': sqliteBool(volumeCheck),
      'adjust_all_sets': sqliteBool(adjustAllSets),
      'use_manual_select': sqliteBool(useManualSelect),
      'manual_selection_json': manualSelectionJson ?? existingManualJson,
      'success_count_mode': successCountMode ?? existingSuccessCountMode,
      'flow_definition': existingFlowDef,
    };

    final updated = await db.update(
      'preset_auto_settings',
      values,
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
    if (updated == 0) {
      await db.insert('preset_auto_settings', values);
    }
  }

  /// Deletes the automatic settings for a preset (disables automatic).
  static Future<int> deleteAutoSettings(Database db, int presetId) {
    return db.delete(
      'preset_auto_settings',
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
  }

  /// Reads the saved flow-graph JSON for a preset.
  static Future<String> getFlowDefinition(Database db, int presetId) async {
    final row = await _getByPresetId(
      db,
      presetId,
      columns: ['flow_definition'],
    );
    return row?['flow_definition'] as String? ?? '{}';
  }

  /// Updates only the flow_definition column.
  static Future<void> upsertFlowDefinition(
    Database db,
    int presetId,
    String flowJson,
  ) async {
    await db.update(
      'preset_auto_settings',
      {'flow_definition': flowJson},
      where: 'preset_id = ?',
      whereArgs: [presetId],
    );
  }
}
