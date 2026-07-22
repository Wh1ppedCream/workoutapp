import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

class MediaCacheService {
  static const String _cacheFolder = 'tonos_content_cache';
  static const Duration _connectionTimeout = Duration(seconds: 15);
  static const Duration _downloadTimeout = Duration(seconds: 45);

  const MediaCacheService();

  Future<File?> cachedFileFor(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async {
    final path = thumbnail ? item.localThumbnailPath : item.localCachePath;
    if (path == null || path.isEmpty) return null;

    return _cachedFileAtPath(path);
  }

  Future<File?> cachedSharedFileFor(
    SharedMediaItem item, {
    required bool thumbnail,
  }) {
    final path = thumbnail ? item.localThumbnailPath : item.localCachePath;
    return _cachedFileAtPath(path);
  }

  Future<File> downloadMedia(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async {
    final url =
        thumbnail ? item.thumbnailUrl ?? item.remoteUrl : item.remoteUrl;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError.value(url, 'url', 'Expected an absolute media URL.');
    }

    final targetFile = await _targetFileFor(item, uri, thumbnail: thumbnail);
    return _downloadToTarget(uri, targetFile);
  }

  Future<File> downloadSharedMedia(
    SharedMediaItem item, {
    required bool thumbnail,
  }) async {
    final url =
        thumbnail ? item.thumbnailUrl ?? item.remoteUrl : item.remoteUrl;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError.value(url, 'url', 'Expected an absolute media URL.');
    }

    final targetFile = await _targetFileForShared(
      item,
      uri,
      thumbnail: thumbnail,
    );
    return _downloadToTarget(uri, targetFile);
  }

  Future<File?> _cachedFileAtPath(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    if (await file.length() == 0) return null;
    return file;
  }

  Future<File> _downloadToTarget(Uri uri, File targetFile) async {
    await targetFile.parent.create(recursive: true);
    final tempFile = File(
      '${targetFile.path}.${DateTime.now().microsecondsSinceEpoch}.download',
    );

    final client = HttpClient()..connectionTimeout = _connectionTimeout;
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media request failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      await response.pipe(tempFile.openWrite()).timeout(_downloadTimeout);
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return targetFile;
    } catch (_) {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<ContentCacheUsage> getCacheUsage() async {
    final dir = await _cacheDirectory();
    if (!dir.existsSync()) {
      return const ContentCacheUsage(fileCount: 0, totalBytes: 0);
    }

    var fileCount = 0;
    var totalBytes = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        if (entity.path.endsWith('.download')) {
          await entity.delete();
          continue;
        }
        fileCount++;
        totalBytes += await entity.length();
      }
    }
    return ContentCacheUsage(fileCount: fileCount, totalBytes: totalBytes);
  }

  Future<void> clearCache() async {
    final dir = await _cacheDirectory();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<File> _targetFileFor(
    ExerciseMediaItem item,
    Uri uri, {
    required bool thumbnail,
  }) async {
    final dir = await _cacheDirectory();
    final extension =
        p.extension(uri.path).isEmpty ? '.bin' : p.extension(uri.path);
    final role = thumbnail ? 'thumb' : 'media';
    final idPart =
        item.assetId?.isNotEmpty == true
            ? _safeFilePart(item.assetId!)
            : 'exercise_${item.exerciseDefId}_${item.sortOrder}_${item.mediaType}';
    final urlHash = _stableHash(uri.toString()).toRadixString(16);
    return File(
      p.join(dir.path, 'exercises', '$idPart.$role.$urlHash$extension'),
    );
  }

  Future<File> _targetFileForShared(
    SharedMediaItem item,
    Uri uri, {
    required bool thumbnail,
  }) async {
    final dir = await _cacheDirectory();
    final extension =
        p.extension(uri.path).isEmpty ? '.bin' : p.extension(uri.path);
    final role = thumbnail ? 'thumb' : 'media';
    final idPart =
        item.assetId?.isNotEmpty == true
            ? _safeFilePart(item.assetId!)
            : '${item.entityType.name}_${item.entityId}_${item.sortOrder}_${item.mediaType}';
    final urlHash = _stableHash(uri.toString()).toRadixString(16);
    return File(
      p.join(
        dir.path,
        'shared',
        item.entityType.name,
        '$idPart.$role.$urlHash$extension',
      ),
    );
  }

  Future<Directory> _cacheDirectory() async {
    final root = await getTemporaryDirectory();
    return Directory(p.join(root.path, _cacheFolder));
  }

  String _safeFilePart(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_');
  }

  int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
