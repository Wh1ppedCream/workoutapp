// File: lib/db/preset_definition_dao.dart

import 'package:sqflite/sqflite.dart';

import 'db_query_utils.dart';

/// DAO for accessing preset_definitions table, with optional profile filtering.
class PresetDefinitionDao {
  /// Inserts a new preset and returns its ID.
  ///
  /// Optionally scopes the preset to [profileId].
  static Future<int> insertPreset(
    Database db,
    String name, {
    int? profileId,
    bool isDraft = false,
  }) {
    final data = <String, dynamic>{'name': name, 'is_draft': isDraft ? 1 : 0};
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
    final whereClause = profileId != null
        ? 'name = ? AND profile_id = ? AND is_draft = 0'
        : 'name = ? AND profile_id IS NULL AND is_draft = 0';
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
        where: 'profile_id = ? AND is_draft = 0',
        whereArgs: [profileId],
        orderBy: 'created_at',
      );
    }
    return db.query(
      'preset_definitions',
      where: 'is_draft = 0',
      orderBy: 'created_at',
    );
  }

  /// Retrieves the resumable onboarding draft for a profile, if one exists.
  static Future<Map<String, dynamic>?> getDraftForProfile(
    Database db,
    int profileId,
  ) async {
    final rows = await db.query(
      'preset_definitions',
      where: 'profile_id = ? AND is_draft = 1',
      whereArgs: [profileId],
      orderBy: 'created_at DESC, id DESC',
      limit: 1,
    );
    return firstDynamicRow(rows);
  }

  static Future<int> deleteDraftsForProfile(Database db, int profileId) {
    return db.delete(
      'preset_definitions',
      where: 'profile_id = ? AND is_draft = 1',
      whereArgs: [profileId],
    );
  }

  /// Retrieves a single preset definition by ID.
  static Future<Map<String, dynamic>?> getPresetById(
    DatabaseExecutor db,
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

  static Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw(
    DatabaseExecutor db, {
    int? profileId,
  }) async {
    final where = profileId != null
        ? 'WHERE p.profile_id = ? AND p.is_draft = 0'
        : 'WHERE p.is_draft = 0';
    return db.rawQuery('''
      SELECT
        p.id AS id,
        p.name AS name,
        p.created_at AS created_at,
        p.profile_id AS profile_id,
        COALESCE(a.is_automatic, 0) AS is_automatic
      FROM preset_definitions p
      LEFT JOIN preset_auto_settings a ON a.preset_id = p.id
      $where
      ORDER BY p.created_at
      ''', profileId != null ? [profileId] : const <Object?>[]);
  }

  static Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw(
    DatabaseExecutor db, {
    required List<int> presetIds,
  }) async {
    if (presetIds.isEmpty) return const <Map<String, dynamic>>[];

    final rows = <Map<String, dynamic>>[];
    final uniquePresetIds = presetIds.toSet().toList();
    for (final chunk in sqliteChunks(uniquePresetIds)) {
      final placeholders = sqlitePlaceholders(chunk.length);
      rows.addAll(
        await db.rawQuery('''
          SELECT
            pe.preset_id AS preset_id,
            pe.exercise_def_id AS def_id,
            COUNT(ps.id) AS set_count
          FROM preset_exercises pe
          LEFT JOIN preset_sets ps ON ps.preset_exercise_id = pe.id
          WHERE pe.type = 'weight'
            AND pe.exercise_def_id IS NOT NULL
            AND pe.preset_id IN ($placeholders)
          GROUP BY pe.preset_id, pe.exercise_def_id
          ''', chunk),
      );
    }

    return rows;
  }
}
