import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/services/media_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory cacheDirectory;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp(
      'tonos_media_cache_test_',
    );
  });

  tearDown(() async {
    if (await cacheDirectory.exists()) {
      await cacheDirectory.delete(recursive: true);
    }
  });

  test('prunes orphaned and interrupted files', () async {
    final keep = File(
      '${cacheDirectory.path}${Platform.pathSeparator}keep.webp',
    );
    final orphan = File(
      '${cacheDirectory.path}${Platform.pathSeparator}orphan.webp',
    );
    final interrupted = File(
      '${cacheDirectory.path}${Platform.pathSeparator}stale.download',
    );
    await keep.writeAsBytes([1, 2, 3]);
    await orphan.writeAsBytes([4, 5, 6]);
    await interrupted.writeAsBytes([7]);

    final service = MediaCacheService(
      cacheDirectoryProvider: () async => cacheDirectory,
    );
    await service.pruneUnreferencedFiles({keep.path});

    expect(await keep.exists(), isTrue);
    expect(await orphan.exists(), isFalse);
    expect(await interrupted.exists(), isFalse);
  });

  test('bounded cache evicts the least recently used verified file', () async {
    final older = File('${cacheDirectory.path}${Platform.pathSeparator}older');
    final newer = File('${cacheDirectory.path}${Platform.pathSeparator}newer');
    await older.writeAsBytes([1, 2, 3]);
    await newer.writeAsBytes([4, 5, 6]);
    await older.setLastModified(DateTime.utc(2026));
    await newer.setLastModified(DateTime.utc(2026, 1, 2));

    final service = MediaCacheService(
      cacheDirectoryProvider: () async => cacheDirectory,
      maxCacheBytes: 3,
      maxCacheFiles: 1,
    );
    await service.enforceCacheBounds();

    expect(await older.exists(), isFalse);
    expect(await newer.exists(), isTrue);
    final usage = await service.getCacheUsage();
    expect(usage.fileCount, 1);
    expect(usage.totalBytes, 3);
  });

  test('rejects and removes a same-size corrupt cached file', () async {
    final expectedBytes = [1, 2, 3];
    final digest = sha256.convert(expectedBytes).toString();
    final file = File(
      '${cacheDirectory.path}${Platform.pathSeparator}'
      'asset.media.${digest.substring(0, 16)}.webp',
    );
    await file.writeAsBytes([1, 2, 4]);
    final item = ExerciseMediaItem(
      exerciseDefId: 1,
      mediaType: 'image',
      remoteUrl: 'https://content.example/asset.webp',
      localCachePath: file.path,
      bytes: expectedBytes.length,
      sha256: digest,
    );
    final service = MediaCacheService(
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    expect(await service.cachedFileFor(item, thumbnail: false), isNull);
    expect(await file.exists(), isFalse);
  });

  test('rejects a cached path outside the managed cache root', () async {
    final bytes = [1, 2, 3];
    final digest = sha256.convert(bytes).toString();
    final outsideDirectory = await Directory.systemTemp.createTemp(
      'tonos_media_cache_outside_',
    );
    addTearDown(() => outsideDirectory.delete(recursive: true));
    final file = File(
      '${outsideDirectory.path}${Platform.pathSeparator}'
      'asset.media.${digest.substring(0, 16)}.webp',
    );
    await file.writeAsBytes(bytes);
    final item = ExerciseMediaItem(
      exerciseDefId: 1,
      mediaType: 'image',
      remoteUrl: 'https://content.example/asset.webp',
      localCachePath: file.path,
      bytes: bytes.length,
      sha256: digest,
    );
    final service = MediaCacheService(
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    expect(await service.cachedFileFor(item, thumbnail: false), isNull);
    expect(await file.exists(), isTrue);
  });
}
