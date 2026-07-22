import 'dart:io';

import '../db/content_dao.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import '../services/content_environment_preferences.dart';
import '../services/content_manifest_service.dart';
import '../services/media_cache_service.dart';
import '../services/media_download_preferences.dart';

/// Repository boundary for public cloud-hosted Tonos content.
///
/// Keep widgets talking to this layer instead of directly knowing about
/// manifests, cache directories, or remote object storage.
class ContentRepository {
  ContentRepository({
    DatabaseHelper? db,
    ContentManifestService? manifestService,
    MediaCacheService? cacheService,
    MediaDownloadPolicy? downloadPolicy,
    ContentEnvironmentPreferences? environmentPreferences,
  }) : _db = db ?? DatabaseHelper(),
       _manifestService = manifestService ?? const ContentManifestService(),
       _cacheService = cacheService ?? const MediaCacheService(),
       _downloadPolicy = downloadPolicy ?? MediaDownloadPolicy(),
       _environmentPreferences =
           environmentPreferences ?? const ContentEnvironmentPreferences();

  final DatabaseHelper _db;
  final ContentManifestService _manifestService;
  final MediaCacheService _cacheService;
  final MediaDownloadPolicy _downloadPolicy;
  final ContentEnvironmentPreferences _environmentPreferences;
  static Future<ContentManifest>? _bundledExerciseManifestSync;
  static Future<SharedMediaManifest>? _bundledSharedMediaManifestSync;
  static Future<ContentEnvironmentConfig>? _bundledContentEnvironments;
  static Future<void>? _exerciseMediaBootstrapSync;
  static Future<void>? _sharedMediaBootstrapSync;

  Future<ContentEnvironmentConfig> loadContentEnvironments() {
    return _bundledContentEnvironments ??=
        _manifestService.loadBundledContentEnvironments();
  }

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

  Future<SharedMediaManifest> syncBundledSharedMediaManifest() async {
    final inFlight = _bundledSharedMediaManifestSync;
    if (inFlight != null) return inFlight;

    final sync = _syncBundledSharedMediaManifest();
    _bundledSharedMediaManifestSync = sync;
    try {
      return await sync;
    } catch (_) {
      _bundledSharedMediaManifestSync = null;
      rethrow;
    }
  }

  Future<SharedMediaManifest> _syncBundledSharedMediaManifest() async {
    final manifest = await _manifestService.loadBundledSharedMediaManifest();
    final db = await _db.database;
    final existingVersion = await ContentDao.getManifestVersion(
      db,
      manifest.namespace,
    );
    if (existingVersion != null && existingVersion >= manifest.version) {
      return manifest;
    }
    await ContentDao.upsertSharedMediaManifest(db, manifest);
    return manifest;
  }

  Future<SharedMediaManifest> syncRemoteSharedMediaManifest(
    Uri manifestUri,
  ) async {
    final manifest = await _manifestService.fetchSharedMediaManifest(
      manifestUri,
    );
    final db = await _db.database;
    await ContentDao.upsertSharedMediaManifest(db, manifest);
    return manifest;
  }

  Future<void> ensureExerciseMediaManifestReady() async {
    final inFlight = _exerciseMediaBootstrapSync;
    if (inFlight != null) return inFlight;

    final sync = _bootstrapExerciseMediaManifest();
    _exerciseMediaBootstrapSync = sync;
    return sync;
  }

  Future<void> _bootstrapExerciseMediaManifest() async {
    if (await _trySyncConfiguredRemoteExerciseMediaManifest()) return;

    try {
      await syncBundledExerciseMediaManifest();
    } catch (_) {
      // Exercise media is optional; the UI can still fall back to heatmaps.
    }
  }

  Future<void> ensureSharedMediaManifestReady() async {
    final inFlight = _sharedMediaBootstrapSync;
    if (inFlight != null) return inFlight;

    final sync = _bootstrapSharedMediaManifest();
    _sharedMediaBootstrapSync = sync;
    return sync;
  }

  Future<void> _bootstrapSharedMediaManifest() async {
    if (await _trySyncConfiguredRemoteSharedMediaManifest()) return;

    try {
      await syncBundledSharedMediaManifest();
    } catch (_) {
      // Shared media is optional; each caller owns a meaningful local fallback.
    }
  }

  Future<bool> _trySyncConfiguredRemoteExerciseMediaManifest() async {
    try {
      final config = await loadContentEnvironments();
      final manifestUrl =
          (await _environmentPreferences.loadExerciseMediaManifestUrl(
            config,
          )).trim();
      final uri = Uri.tryParse(manifestUrl);
      final validRemoteUri =
          uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty;
      if (!validRemoteUri) return false;

      await syncRemoteExerciseMediaManifest(uri);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySyncConfiguredRemoteSharedMediaManifest() async {
    try {
      final config = await loadContentEnvironments();
      final manifestUrl =
          (await _environmentPreferences.loadSharedMediaManifestUrl(
            config,
          )).trim();
      final uri = Uri.tryParse(manifestUrl);
      final validRemoteUri =
          uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty;
      if (!validRemoteUri) return false;

      await syncRemoteSharedMediaManifest(uri);
      return true;
    } catch (_) {
      return false;
    }
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

  Future<List<SharedMediaItem>> fetchSharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) {
    return _db.getSharedMedia(entityType, entityId);
  }

  Future<SharedMediaItem?> fetchPrimarySharedMedia(
    SharedMediaEntityType entityType,
    int entityId,
  ) async {
    final media = await fetchSharedMedia(entityType, entityId);
    if (media.isEmpty) return null;
    final images = media.where(_isDisplayableSharedImage).toList();
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
    if (!await _downloadPolicy.canDownloadRemoteMedia()) {
      throw const MediaDownloadBlockedException();
    }

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

  Future<File?> cachedSharedMediaFile(
    SharedMediaItem item, {
    required bool thumbnail,
  }) {
    return _cacheService.cachedSharedFileFor(item, thumbnail: thumbnail);
  }

  Future<File> cacheSharedMedia(
    SharedMediaItem item, {
    required bool thumbnail,
  }) async {
    if (!await _downloadPolicy.canDownloadRemoteMedia()) {
      throw const MediaDownloadBlockedException();
    }

    final file = await _cacheService.downloadSharedMedia(
      item,
      thumbnail: thumbnail,
    );
    final db = await _db.database;
    await ContentDao.updateCachedSharedMediaPath(
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

  Future<void> markSharedMediaAccessed(SharedMediaItem item) async {
    final db = await _db.database;
    await ContentDao.markSharedMediaAccessed(db, item);
  }

  Future<ContentCacheUsage> getCacheUsage() => _cacheService.getCacheUsage();

  Future<ContentManifestStatus?> getManifestStatus(String namespace) async {
    final db = await _db.database;
    return ContentDao.getManifestStatus(db, namespace);
  }

  Future<void> clearCache() => _cacheService.clearCache();

  Future<bool> isWifiOnlyMediaDownloadEnabled() {
    return _downloadPolicy.isWifiOnlyEnabled();
  }

  Future<void> setWifiOnlyMediaDownloadEnabled(bool value) {
    return _downloadPolicy.setWifiOnlyEnabled(value);
  }

  bool _isDisplayableImage(ExerciseMediaItem item) {
    final type = item.mediaType.toLowerCase();
    if (type == 'image' || type == 'thumbnail' || type == 'still') return true;
    final url = (item.thumbnailUrl ?? item.remoteUrl).toLowerCase();
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.webp');
  }

  bool _isDisplayableSharedImage(SharedMediaItem item) {
    final type = item.mediaType.toLowerCase();
    if (type == 'image' || type == 'thumbnail' || type == 'still') return true;
    final url = (item.thumbnailUrl ?? item.remoteUrl).toLowerCase();
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.webp');
  }
}
