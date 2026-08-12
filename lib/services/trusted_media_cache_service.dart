import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import 'trusted_content_policy.dart';

typedef MediaCacheDirectoryProvider = Future<Directory> Function();
typedef MediaHttpClientFactory = HttpClient Function();

class MediaCacheService {
  static const String _cacheFolder = 'tonos_content_cache';
  static const Duration _connectionTimeout = Duration(seconds: 15);
  static const Duration _downloadTimeout = Duration(seconds: 45);

  MediaCacheService({
    this.cacheDirectoryProvider,
    this.httpClientFactory,
    this.maxCacheBytes = TrustedContentPolicy.maxCacheBytes,
    this.maxCacheFiles = TrustedContentPolicy.maxCacheFiles,
  });

  final MediaCacheDirectoryProvider? cacheDirectoryProvider;
  final MediaHttpClientFactory? httpClientFactory;
  final int maxCacheBytes;
  final int maxCacheFiles;
  final Map<String, _VerifiedCacheFile> _verifiedFiles = {};

  Future<File?> cachedFileFor(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) {
    final path = thumbnail ? item.localThumbnailPath : item.localCachePath;
    return _cachedFileAtPath(path, item.bytes, item.sha256);
  }

  Future<File?> cachedSharedFileFor(
    SharedMediaItem item, {
    required bool thumbnail,
  }) {
    final path = thumbnail ? item.localThumbnailPath : item.localCachePath;
    return _cachedFileAtPath(path, item.bytes, item.sha256);
  }

  Future<File> downloadMedia(
    ExerciseMediaItem item, {
    required bool thumbnail,
  }) {
    return _downloadManifestAsset(
      url: thumbnail ? item.thumbnailUrl ?? item.remoteUrl : item.remoteUrl,
      mediaType: item.mediaType,
      expectedBytes: item.bytes,
      expectedSha256: item.sha256,
      targetFile:
          (uri, digest) =>
              _targetFileFor(item, uri, digest, thumbnail: thumbnail),
    );
  }

  Future<File> downloadSharedMedia(
    SharedMediaItem item, {
    required bool thumbnail,
  }) {
    return _downloadManifestAsset(
      url: thumbnail ? item.thumbnailUrl ?? item.remoteUrl : item.remoteUrl,
      mediaType: item.mediaType,
      expectedBytes: item.bytes,
      expectedSha256: item.sha256,
      targetFile:
          (uri, digest) =>
              _targetFileForShared(item, uri, digest, thumbnail: thumbnail),
    );
  }

  Future<File?> _cachedFileAtPath(
    String? path,
    int? expectedBytes,
    String? expectedSha256,
  ) async {
    if (path == null || path.isEmpty) return null;
    late final String digest;
    late final int byteCount;
    try {
      digest = TrustedContentPolicy.validatedSha256(expectedSha256);
      byteCount = TrustedContentPolicy.validatedMediaBytes(expectedBytes);
    } on FormatException {
      return null;
    }

    final cacheDirectory = await _cacheDirectory();
    final normalizedPath = p.normalize(p.absolute(path));
    final normalizedRoot = p.normalize(p.absolute(cacheDirectory.path));
    if (!p.isWithin(normalizedRoot, normalizedPath) ||
        !p.basename(normalizedPath).contains('.${digest.substring(0, 16)}')) {
      return null;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      _verifiedFiles.remove(normalizedPath);
      return null;
    }
    final stat = await file.stat();
    if (stat.size != byteCount) {
      await _deleteCachedFile(file);
      return null;
    }

    final verified = _verifiedFiles[normalizedPath];
    if (verified == null ||
        verified.bytes != stat.size ||
        verified.modified != stat.modified ||
        verified.sha256 != digest) {
      final actualDigest = await sha256.bind(file.openRead()).first;
      if (actualDigest.toString() != digest) {
        await _deleteCachedFile(file);
        return null;
      }
    }
    await _touchVerifiedFile(file, byteCount, digest);
    return file;
  }

  Future<File> _downloadManifestAsset({
    required String url,
    required String mediaType,
    required int? expectedBytes,
    required String? expectedSha256,
    required Future<File> Function(Uri uri, String digest) targetFile,
  }) async {
    final uri = Uri.parse(url);
    TrustedContentPolicy.requireHttps(uri, description: 'Media asset');
    final byteCount = TrustedContentPolicy.validatedMediaBytes(expectedBytes);
    final digest = TrustedContentPolicy.validatedSha256(expectedSha256);
    final target = await targetFile(uri, digest);

    final existing = await _verifiedExistingFile(target, byteCount, digest);
    if (existing != null) return existing;

    final client =
        (httpClientFactory?.call() ?? HttpClient())
          ..connectionTimeout = _connectionTimeout;
    try {
      final response = await _open(client, uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Media request failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      if (!TrustedContentPolicy.isMediaContentType(
        response.headers.contentType,
        mediaType,
      )) {
        throw HttpException('Unexpected media content type.', uri: uri);
      }
      if (response.contentLength > byteCount ||
          response.contentLength > TrustedContentPolicy.maxMediaBytes) {
        throw HttpException('Media response was too large.', uri: uri);
      }

      await VerifiedMediaWriter.writeAtomically(
        response,
        target,
        expectedBytes: byteCount,
        expectedSha256: digest,
      ).timeout(_downloadTimeout);
      await _enforceBounds(protectedPath: target.path);
      return target;
    } finally {
      client.close(force: true);
    }
  }

  Future<HttpClientResponse> _open(HttpClient client, Uri initialUri) async {
    var uri = initialUri;
    for (
      var redirects = 0;
      redirects <= TrustedContentPolicy.maxRedirects;
      redirects++
    ) {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close();
      if (!response.isRedirect) return response;
      final location = response.headers.value(HttpHeaders.locationHeader);
      await response.drain<void>();
      if (location == null || redirects == TrustedContentPolicy.maxRedirects) {
        throw HttpException('Media redirect limit exceeded.', uri: uri);
      }
      uri = TrustedContentPolicy.validatedRedirect(uri, location);
    }
    throw HttpException('Media redirect limit exceeded.', uri: initialUri);
  }

  Future<File?> _verifiedExistingFile(
    File file,
    int expectedBytes,
    String expectedSha256,
  ) async {
    if (!await file.exists()) return null;
    if (await file.length() != expectedBytes) {
      await _deleteCachedFile(file);
      return null;
    }
    final digest = await sha256.bind(file.openRead()).first;
    if (digest.toString() != expectedSha256) {
      await _deleteCachedFile(file);
      return null;
    }
    await _touchVerifiedFile(file, expectedBytes, expectedSha256);
    return file;
  }

  Future<void> _touchVerifiedFile(File file, int bytes, String digest) async {
    await file.setLastModified(DateTime.now().toUtc());
    final stat = await file.stat();
    _verifiedFiles[p.normalize(p.absolute(file.path))] = _VerifiedCacheFile(
      bytes: bytes,
      modified: stat.modified,
      sha256: digest,
    );
  }

  Future<void> _deleteCachedFile(File file) async {
    _verifiedFiles.remove(p.normalize(p.absolute(file.path)));
    if (await file.exists()) await file.delete();
  }

  Future<ContentCacheUsage> getCacheUsage() async {
    final files = await _cacheFiles(cleanTemporaryFiles: true);
    var totalBytes = 0;
    for (final file in files) {
      totalBytes += await file.length();
    }
    return ContentCacheUsage(fileCount: files.length, totalBytes: totalBytes);
  }

  Future<void> enforceCacheBounds() => _enforceBounds();

  Future<void> pruneUnreferencedFiles(Set<String> referencedPaths) async {
    final normalizedReferences = referencedPaths.map(p.normalize).toSet();
    final files = await _cacheFiles(cleanTemporaryFiles: true);
    for (final file in files) {
      if (!normalizedReferences.contains(p.normalize(file.path))) {
        await _deleteCachedFile(file);
      }
    }
    await _deleteEmptyDirectories();
  }

  Future<void> clearCache() async {
    final dir = await _cacheDirectory();
    if (await dir.exists()) await dir.delete(recursive: true);
    _verifiedFiles.clear();
  }

  Future<void> _enforceBounds({String? protectedPath}) async {
    final files = await _cacheFiles(cleanTemporaryFiles: true);
    final entries = <({File file, int bytes, DateTime accessed})>[];
    var totalBytes = 0;
    for (final file in files) {
      final stat = await file.stat();
      totalBytes += stat.size;
      entries.add((file: file, bytes: stat.size, accessed: stat.modified));
    }
    entries.sort((a, b) => a.accessed.compareTo(b.accessed));

    var fileCount = entries.length;
    for (final entry in entries) {
      if (totalBytes <= maxCacheBytes && fileCount <= maxCacheFiles) break;
      if (protectedPath != null && p.equals(entry.file.path, protectedPath)) {
        continue;
      }
      await _deleteCachedFile(entry.file);
      totalBytes -= entry.bytes;
      fileCount--;
    }
    await _deleteEmptyDirectories();
  }

  Future<List<File>> _cacheFiles({required bool cleanTemporaryFiles}) async {
    final dir = await _cacheDirectory();
    if (!await dir.exists()) return <File>[];
    final files = <File>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (entity.path.endsWith('.download')) {
        if (cleanTemporaryFiles) await _deleteCachedFile(entity);
        continue;
      }
      files.add(entity);
    }
    return files;
  }

  Future<void> _deleteEmptyDirectories() async {
    final root = await _cacheDirectory();
    if (!await root.exists()) return;
    final directories = <Directory>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is Directory) directories.add(entity);
    }
    directories.sort((a, b) => b.path.length.compareTo(a.path.length));
    for (final directory in directories) {
      if (await directory.list().isEmpty) await directory.delete();
    }
  }

  Future<File> _targetFileFor(
    ExerciseMediaItem item,
    Uri uri,
    String digest, {
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
    return File(
      p.join(
        dir.path,
        'exercises',
        '$idPart.$role.${digest.substring(0, 16)}$extension',
      ),
    );
  }

  Future<File> _targetFileForShared(
    SharedMediaItem item,
    Uri uri,
    String digest, {
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
    return File(
      p.join(
        dir.path,
        'shared',
        item.entityType.name,
        '$idPart.$role.${digest.substring(0, 16)}$extension',
      ),
    );
  }

  Future<Directory> _cacheDirectory() async {
    if (cacheDirectoryProvider != null) return cacheDirectoryProvider!();
    final root = await getTemporaryDirectory();
    return Directory(p.join(root.path, _cacheFolder));
  }

  String _safeFilePart(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_');
  }
}

class _VerifiedCacheFile {
  const _VerifiedCacheFile({
    required this.bytes,
    required this.modified,
    required this.sha256,
  });

  final int bytes;
  final DateTime modified;
  final String sha256;
}
