import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// DAO for shared cloud content metadata.
///
/// User-created workout data stays in the existing local-first tables. These
/// tables only track downloadable public content such as exercise media.
class ContentDao {
  static Future<void> ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS content_manifest (
        namespace TEXT PRIMARY KEY,
        version INTEGER NOT NULL,
        etag TEXT,
        last_checked_at TEXT,
        downloaded_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS content_license (
        license_id TEXT PRIMARY KEY,
        source_name TEXT NOT NULL,
        license_name TEXT NOT NULL,
        attribution_text TEXT,
        source_url TEXT,
        requires_attribution INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // This table originally lived in DatabaseHelper's repair path. Keep its
    // base schema here as well so versioned migrations can safely run before
    // DatabaseHelper.onOpen performs any defensive repairs.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercise_media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_def_id INTEGER NOT NULL,
        media_type TEXT NOT NULL,
        remote_url TEXT NOT NULL,
        thumbnail_url TEXT,
        local_cache_path TEXT,
        local_thumbnail_path TEXT,
        title TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(exercise_def_id)
          REFERENCES exercise_definitions(id) ON DELETE CASCADE
      );
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_exercise_media_def_sort '
      'ON exercise_media(exercise_def_id, sort_order, id)',
    );

    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'asset_id',
      typeAndDefaultSql: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'version',
      typeAndDefaultSql: 'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'bytes',
      typeAndDefaultSql: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'width',
      typeAndDefaultSql: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'height',
      typeAndDefaultSql: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'sha256',
      typeAndDefaultSql: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'license_id',
      typeAndDefaultSql: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'last_accessed_at',
      typeAndDefaultSql: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'exercise_media',
      column: 'downloaded_at',
      typeAndDefaultSql: 'TEXT',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_exercise_media_asset_id ON exercise_media(asset_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_exercise_media_accessed ON exercise_media(last_accessed_at)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shared_media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        asset_id TEXT,
        media_type TEXT NOT NULL,
        remote_url TEXT NOT NULL,
        thumbnail_url TEXT,
        local_cache_path TEXT,
        local_thumbnail_path TEXT,
        title TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        version INTEGER NOT NULL DEFAULT 1,
        bytes INTEGER,
        width INTEGER,
        height INTEGER,
        sha256 TEXT,
        license_id TEXT,
        last_accessed_at TEXT,
        downloaded_at TEXT,
        created_at TEXT,
        updated_at TEXT
      );
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shared_media_entity ON shared_media(entity_type, entity_id, sort_order, id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shared_media_asset_id ON shared_media(asset_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shared_media_accessed ON shared_media(last_accessed_at)',
    );
  }

  static Future<void> upsertExerciseMediaManifest(
    Database db,
    ContentManifest manifest,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final activeAssetIds = <String>{};
    final activeRemoteUrls = <String>{};

    await db.transaction((txn) async {
      await txn.insert('content_manifest', {
        'namespace': manifest.namespace,
        'version': manifest.version,
        'last_checked_at': now,
        'downloaded_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final entry in manifest.exerciseMedia) {
        for (var i = 0; i < entry.assets.length; i++) {
          final asset = entry.assets[i].copyWith(
            exerciseDefId: entry.exerciseId,
            sortOrder: i,
          );
          if (asset.assetId?.isNotEmpty == true) {
            activeAssetIds.add(asset.assetId!);
          } else {
            activeRemoteUrls.add(asset.remoteUrl);
          }

          final existingId = await _existingMediaId(txn, asset);
          final row = {...asset.toMap(), 'id': existingId, 'updated_at': now};
          row.removeWhere((_, value) => value == null);

          if (existingId == null) {
            row['created_at'] = now;
          }

          await txn.insert(
            'exercise_media',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await _deleteStaleExerciseMediaRows(
        txn,
        activeAssetIds: activeAssetIds,
        activeRemoteUrls: activeRemoteUrls,
      );
    });
  }

  static Future<int?> getManifestVersion(Database db, String namespace) async {
    final rows = await db.query(
      'content_manifest',
      columns: ['version'],
      where: 'namespace = ?',
      whereArgs: [namespace],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['version'] as num?)?.toInt();
  }

  static Future<ContentManifestStatus?> getManifestStatus(
    Database db,
    String namespace,
  ) async {
    final rows = await db.query(
      'content_manifest',
      where: 'namespace = ?',
      whereArgs: [namespace],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ContentManifestStatus.fromMap(rows.first);
  }

  static Future<void> markMediaAccessed(
    Database db,
    ExerciseMediaItem item,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      'exercise_media',
      {'last_accessed_at': now},
      where:
          item.id != null ? 'id = ?' : 'exercise_def_id = ? AND remote_url = ?',
      whereArgs:
          item.id != null ? [item.id] : [item.exerciseDefId, item.remoteUrl],
    );
  }

  static Future<void> updateCachedMediaPath(
    Database db,
    ExerciseMediaItem item, {
    required bool thumbnail,
    required String localPath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      'exercise_media',
      {
        thumbnail ? 'local_thumbnail_path' : 'local_cache_path': localPath,
        'downloaded_at': now,
        'last_accessed_at': now,
      },
      where:
          item.id != null ? 'id = ?' : 'exercise_def_id = ? AND remote_url = ?',
      whereArgs:
          item.id != null ? [item.id] : [item.exerciseDefId, item.remoteUrl],
    );
  }

  static Future<void> upsertSharedMediaManifest(
    Database db,
    SharedMediaManifest manifest,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final activeAssetIds = <String>{};
    final activeRemoteUrls = <String>{};

    await db.transaction((txn) async {
      await txn.insert('content_manifest', {
        'namespace': manifest.namespace,
        'version': manifest.version,
        'last_checked_at': now,
        'downloaded_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final entry in manifest.entities) {
        // Cloud source IDs validate the manifest, but local lookup IDs depend
        // on when each app database was seeded. Resolve the canonical slug so
        // a media item always stays paired with the right local definition.
        final localEntityId = await _resolveSharedEntityId(
          txn,
          entry.entityType,
          entry.slug,
        );
        if (localEntityId == null) continue;

        for (var index = 0; index < entry.assets.length; index++) {
          final asset = entry.assets[index].copyWith(
            entityId: localEntityId,
            sortOrder: index,
          );
          if (asset.assetId?.isNotEmpty == true) {
            activeAssetIds.add(asset.assetId!);
          } else {
            activeRemoteUrls.add(asset.remoteUrl);
          }

          final existingId = await _existingSharedMediaId(txn, asset);
          final row = <String, Object?>{
            ...asset.toMap(),
            'id': existingId,
            'updated_at': now,
          };
          row.removeWhere((_, value) => value == null);
          if (existingId == null) row['created_at'] = now;

          await txn.insert(
            'shared_media',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await _deleteStaleSharedMediaRows(
        txn,
        activeAssetIds: activeAssetIds,
        activeRemoteUrls: activeRemoteUrls,
      );
    });
  }

  static Future<List<SharedMediaItem>> getSharedMedia(
    Database db,
    SharedMediaEntityType entityType,
    int entityId,
  ) async {
    final rows = await db.query(
      'shared_media',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [sharedMediaEntityTypeToString(entityType), entityId],
      orderBy: 'sort_order, id',
    );
    return rows.map(SharedMediaItem.fromMap).toList();
  }

  static Future<void> markSharedMediaAccessed(
    Database db,
    SharedMediaItem item,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      'shared_media',
      {'last_accessed_at': now},
      where:
          item.id != null
              ? 'id = ?'
              : 'entity_type = ? AND entity_id = ? AND remote_url = ?',
      whereArgs:
          item.id != null
              ? [item.id]
              : [
                sharedMediaEntityTypeToString(item.entityType),
                item.entityId,
                item.remoteUrl,
              ],
    );
  }

  static Future<void> updateCachedSharedMediaPath(
    Database db,
    SharedMediaItem item, {
    required bool thumbnail,
    required String localPath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      'shared_media',
      {
        thumbnail ? 'local_thumbnail_path' : 'local_cache_path': localPath,
        'downloaded_at': now,
        'last_accessed_at': now,
      },
      where:
          item.id != null
              ? 'id = ?'
              : 'entity_type = ? AND entity_id = ? AND remote_url = ?',
      whereArgs:
          item.id != null
              ? [item.id]
              : [
                sharedMediaEntityTypeToString(item.entityType),
                item.entityId,
                item.remoteUrl,
              ],
    );
  }

  static Future<int?> _existingMediaId(
    DatabaseExecutor db,
    ExerciseMediaItem item,
  ) async {
    final rows = await db.query(
      'exercise_media',
      columns: ['id'],
      where:
          item.assetId != null && item.assetId!.isNotEmpty
              ? 'asset_id = ?'
              : 'exercise_def_id = ? AND remote_url = ?',
      whereArgs:
          item.assetId != null && item.assetId!.isNotEmpty
              ? [item.assetId]
              : [item.exerciseDefId, item.remoteUrl],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  static Future<int?> _existingSharedMediaId(
    DatabaseExecutor db,
    SharedMediaItem item,
  ) async {
    final usesAssetId = item.assetId?.isNotEmpty == true;
    final rows = await db.query(
      'shared_media',
      columns: ['id'],
      where:
          usesAssetId
              ? 'asset_id = ?'
              : 'entity_type = ? AND entity_id = ? AND remote_url = ?',
      whereArgs:
          usesAssetId
              ? [item.assetId]
              : [
                sharedMediaEntityTypeToString(item.entityType),
                item.entityId,
                item.remoteUrl,
              ],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  static Future<int?> _resolveSharedEntityId(
    DatabaseExecutor db,
    SharedMediaEntityType entityType,
    String slug,
  ) async {
    if (slug.trim().isEmpty) return null;
    final table = switch (entityType) {
      SharedMediaEntityType.equipment => 'equipment',
      SharedMediaEntityType.bodypart => 'bodypart',
      SharedMediaEntityType.muscle => 'muscles',
    };
    final rows = await db.query(table, columns: ['id', 'name']);
    for (final row in rows) {
      final name = row['name'] as String?;
      final id = row['id'] as int?;
      if (name != null && id != null && _sharedMediaSlug(name) == slug) {
        return id;
      }
    }
    return null;
  }

  static String _sharedMediaSlug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static Future<void> _deleteStaleExerciseMediaRows(
    DatabaseExecutor db, {
    required Set<String> activeAssetIds,
    required Set<String> activeRemoteUrls,
  }) async {
    final rows = await db.query(
      'exercise_media',
      columns: ['id', 'asset_id', 'remote_url'],
    );
    final staleIds = <int>[];
    for (final row in rows) {
      final id = row['id'] as int?;
      if (id == null) continue;

      final assetId = row['asset_id'] as String?;
      final remoteUrl = row['remote_url'] as String?;
      final isActive =
          assetId != null && assetId.isNotEmpty
              ? activeAssetIds.contains(assetId)
              : remoteUrl != null && activeRemoteUrls.contains(remoteUrl);
      if (!isActive) {
        staleIds.add(id);
      }
    }

    const chunkSize = 900;
    for (var i = 0; i < staleIds.length; i += chunkSize) {
      final chunk = staleIds.skip(i).take(chunkSize).toList();
      final placeholders = List.filled(chunk.length, '?').join(',');
      await db.delete(
        'exercise_media',
        where: 'id IN ($placeholders)',
        whereArgs: chunk,
      );
    }
  }

  static Future<void> _deleteStaleSharedMediaRows(
    DatabaseExecutor db, {
    required Set<String> activeAssetIds,
    required Set<String> activeRemoteUrls,
  }) async {
    final rows = await db.query(
      'shared_media',
      columns: ['id', 'asset_id', 'remote_url'],
    );
    final staleIds = <int>[];
    for (final row in rows) {
      final id = row['id'] as int?;
      if (id == null) continue;
      final assetId = row['asset_id'] as String?;
      final remoteUrl = row['remote_url'] as String?;
      final isActive =
          assetId != null && assetId.isNotEmpty
              ? activeAssetIds.contains(assetId)
              : remoteUrl != null && activeRemoteUrls.contains(remoteUrl);
      if (!isActive) staleIds.add(id);
    }

    const chunkSize = 900;
    for (var i = 0; i < staleIds.length; i += chunkSize) {
      final chunk = staleIds.skip(i).take(chunkSize).toList();
      final placeholders = List.filled(chunk.length, '?').join(',');
      await db.delete(
        'shared_media',
        where: 'id IN ($placeholders)',
        whereArgs: chunk,
      );
    }
  }

  static Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String typeAndDefaultSql,
  }) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    final hasColumn = rows.any(
      (row) => (row['name'] as String).toLowerCase() == column.toLowerCase(),
    );
    if (!hasColumn) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $typeAndDefaultSql;',
      );
    }
  }
}
