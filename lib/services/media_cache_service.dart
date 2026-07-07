import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

class MediaCacheService {
  static const String _cacheFolder = 'tonos_content_cache';

  const MediaCacheService();

  Future<File?> cachedFileFor(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) async {
    final path = thumbnail ? item.localThumbnailPath : item.localCachePath;
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    return file.existsSync() ? file : null;
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
    await targetFile.parent.create(recursive: true);

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media request failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      await response.pipe(targetFile.openWrite());
      return targetFile;
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
