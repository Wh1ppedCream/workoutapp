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
  }

  static Future<void> upsertExerciseMediaManifest(
    Database db,
    ContentManifest manifest,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

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
