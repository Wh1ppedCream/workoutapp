import 'dart:io';

import '../db/content_dao.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import '../services/content_manifest_service.dart';
import '../services/media_cache_service.dart';

/// Repository boundary for public cloud-hosted Tonos content.
///
/// Keep widgets talking to this layer instead of directly knowing about
/// manifests, cache directories, or remote object storage.
class ContentRepository {
  ContentRepository({
    DatabaseHelper? db,
    ContentManifestService? manifestService,
    MediaCacheService? cacheService,
  }) : _db = db ?? DatabaseHelper(),
       _manifestService = manifestService ?? const ContentManifestService(),
       _cacheService = cacheService ?? const MediaCacheService();

  final DatabaseHelper _db;
  final ContentManifestService _manifestService;
  final MediaCacheService _cacheService;
  static Future<ContentManifest>? _bundledExerciseManifestSync;

  Future<ContentManifest> syncBundledExerciseMediaManifest() async {
    final inFlight = _bundledExerciseManifestSync;
    if (inFlight != null) return inFlight;

    final sync = _syncBundledExerciseMediaManifest();
    _bundledExerciseManifestSync = sync;
    try {
      return await sync;
    } catch (_) {
      _bundledExerciseManifestSync = null;
      rethrow;
    }
  }

  Future<ContentManifest> _syncBundledExerciseMediaManifest() async {
    final manifest = await _manifestService.loadBundledExerciseMediaManifest();
    final db = await _db.database;
    final existingVersion = await ContentDao.getManifestVersion(
      db,
      manifest.namespace,
    );
    if (existingVersion != null && existingVersion >= manifest.version) {
      return manifest;
    }
    await ContentDao.upsertExerciseMediaManifest(db, manifest);
    return manifest;
  }

  Future<ContentManifest> syncRemoteExerciseMediaManifest(
    Uri manifestUri,
  ) async {
    final manifest = await _manifestService.fetchExerciseMediaManifest(
      manifestUri,
    );
    final db = await _db.database;
    await ContentDao.upsertExerciseMediaManifest(db, manifest);
    return manifest;
  }

  Future<List<ExerciseMediaItem>> fetchExerciseMedia(int exerciseDefId) {
    return _db.getExerciseMedia(exerciseDefId);
  }

  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(
    int exerciseDefId,
  ) async {
    final media = await fetchExerciseMedia(exerciseDefId);
    if (media.isEmpty) return null;

    final images = media.where(_isDisplayableImage).toList();
    return images.isNotEmpty ? images.first : media.first;
  }

  Future<File?> cachedFileFor(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) {
    return _cacheService.cachedFileFor(item, thumbnail: thumbnail);
  }

  Future<File> cacheMedia(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async {
    final file = await _cacheService.downloadMedia(item, thumbnail: thumbnail);
    final db = await _db.database;
    await ContentDao.updateCachedMediaPath(
      db,
      item,
      thumbnail: thumbnail,
      localPath: file.path,
    );
    return file;
  }

  Future<void> markMediaAccessed(ExerciseMediaItem item) async {
    final db = await _db.database;
    await ContentDao.markMediaAccessed(db, item);
  }

  Future<ContentCacheUsage> getCacheUsage() => _cacheService.getCacheUsage();

  Future<ContentManifestStatus?> getManifestStatus(String namespace) async {
    final db = await _db.database;
    return ContentDao.getManifestStatus(db, namespace);
  }

  Future<void> clearCache() => _cacheService.clearCache();

  bool _isDisplayableImage(ExerciseMediaItem item) {
    final type = item.mediaType.toLowerCase();
    if (type == 'image' || type == 'thumbnail' || type == 'still') return true;
    final url = (item.thumbnailUrl ?? item.remoteUrl).toLowerCase();
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.webp');
  }
}
