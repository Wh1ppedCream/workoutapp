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
    required bool   weightCheck,    
  required bool   repCheck,     
  required bool   volumeCheck,   
  required bool adjustAllSets,
  required bool useManualSelect,          // ← new
  String? manualSelectionJson,            // ← new
  }) async {
    // 1) Pull the existing row so we can keep its flow_definition JSON
    final existing = await getAutoSettings(db, presetId);
    final existingFlowDef = existing?['flow_definition'] as String? ?? '{}';
    // also preserve whatever was in manual_selection_json
    final existingManualJson = existing?['manual_selection_json'] as String? ?? '{}';

    // 2) Prepare the full row
  final values = {
    'preset_id':        presetId,
    'is_automatic':     isAutomatic   ? 1 : 0,
    'global_increment': globalIncrement,
    'skip_first_set':   skipFirstSet  ? 1 : 0,
    'weight_check':     weightCheck   ? 1 : 0,
    'rep_check':        repCheck      ? 1 : 0,
    'volume_check':     volumeCheck   ? 1 : 0,
    'adjust_all_sets':  adjustAllSets ? 1 : 0,
    'use_manual_select':       useManualSelect ? 1 : 0,          // ←
    // if caller passed a new JSON, use it; otherwise keep the old or default '{}'
    'manual_selection_json':   manualSelectionJson ?? existingManualJson,
    'flow_definition':  existingFlowDef,
  };

  // 3) Try an UPDATE first
  final updated = await db.update(
    'preset_auto_settings',
    values,
    where: 'preset_id = ?',
    whereArgs: [presetId],
  );
  if (updated == 0) {
    // 4) If no row was updated, INSERT a new one
    await db.insert('preset_auto_settings', values);
  }
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


/// Reads the saved flow‐graph JSON for a preset.
static Future<String> getFlowDefinition(
  Database db,
  int presetId,
) async {
  final rows = await db.query(
    'preset_auto_settings',
    columns: ['flow_definition'],
    where: 'preset_id = ?',
    whereArgs: [presetId],
    limit: 1,
  );
  if (rows.isEmpty) return '{}';
  return rows.first['flow_definition'] as String;
}

/// Updates only the flow_definition column.
static Future<void> upsertFlowDefinition(
  Database db,
  int presetId,
  String flowJson,
) {
  return db.update(
    'preset_auto_settings',
    { 'flow_definition': flowJson },
    where: 'preset_id = ?',
    whereArgs: [presetId],
  );
}
}

