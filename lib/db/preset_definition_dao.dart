// File: lib/db/preset_definition_dao.dart

import 'package:sqflite/sqflite.dart';

/// Data Access Object for preset definitions.
///
/// Encapsulates CRUD operations on the `preset_definitions` table.
class PresetDefinitionDao {
  /// Inserts a new preset and returns its ID.
  static Future<int> insertPreset(
    Database db,
    String name,
  ) {
    return db.insert(
      'preset_definitions',
      {'name': name},
    );
  }

  /// Finds a preset by [name] or inserts it if missing.
  ///
  /// Returns the existing or newly created preset ID.
  static Future<int> findOrCreatePresetDefinition(
    Database db,
    String name,
  ) async {
    // 1) Try to find an existing preset with this name
    final rows = await db.query(
      'preset_definitions',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return rows.first['id'] as int;
    }
    // 2) Not found — insert new preset
    return insertPreset(db, name);
  }

  /// Retrieves all presets as raw maps, ordered by creation time.
  static Future<List<Map<String, dynamic>>> getAllPresetsRaw(
    Database db,
  ) {
    return db.query(
      'preset_definitions',
      orderBy: 'created_at DESC',
    );
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
    return rows.isNotEmpty ? rows.first : null;
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
  static Future<int> deletePreset(
    Database db,
    int presetId,
  ) {
    return db.delete(
      'preset_definitions',
      where: 'id = ?',
      whereArgs: [presetId],
    );
  }




}


