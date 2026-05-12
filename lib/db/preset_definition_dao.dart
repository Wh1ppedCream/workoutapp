// File: lib/db/preset_definition_dao.dart

import 'package:sqflite/sqflite.dart';
import 'db_query_utils.dart';

/// DAO for accessing preset_definitions table, with optional profile filtering.
class PresetDefinitionDao {
  /// Inserts a new preset and returns its ID.
  ///
  /// Optionally scopes the preset to [profileId].
  static Future<int> insertPreset(Database db, String name, {int? profileId}) {
    final data = <String, dynamic>{'name': name};
    if (profileId != null) {
      data['profile_id'] = profileId;
    }
    return db.insert('preset_definitions', data);
  }

  /// Finds a preset by [name] and optional [profileId], or inserts it if missing.
  ///
  /// Returns the existing or newly created preset ID.
  static Future<int> findOrCreatePresetDefinition(
    Database db,
    String name, {
    int? profileId,
  }) async {
    final whereClause =
        profileId != null
            ? 'name = ? AND profile_id = ?'
            : 'name = ? AND profile_id IS NULL';
    final whereArgs = profileId != null ? [name, profileId] : [name];
    final rows = await db.query(
      'preset_definitions',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return rows.first['id'] as int;
    }
    // Not found — insert new preset with optional profileId
    return insertPreset(db, name, profileId: profileId);
  }

  /// Fetches all presets, optionally scoped to a gym profile.
  static Future<List<Map<String, dynamic>>> getAllPresetsRaw(
    Database db, {
    int? profileId,
  }) async {
    if (profileId != null) {
      return db.query(
        'preset_definitions',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'created_at',
      );
    }
    return db.query('preset_definitions', orderBy: 'created_at');
  }

  /// Retrieves a single preset definition by ID.
  static Future<Map<String, dynamic>?> getPresetById(
    Database db,
    int presetId,
  ) async {
    final rows = await db.query(
      'preset_definitions',
      where: 'id = ?',
      whereArgs: [presetId],
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  /// Updates the name of an existing preset.
  static Future<int> updatePresetName(
    Database db,
    int presetId,
    String newName,
  ) {
    return db.update(
      'preset_definitions',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [presetId],
    );
  }

  /// Deletes a preset and cascades to its exercises.
  static Future<int> deletePreset(Database db, int presetId) {
    return db.delete(
      'preset_definitions',
      where: 'id = ?',
      whereArgs: [presetId],
    );
  }
}
