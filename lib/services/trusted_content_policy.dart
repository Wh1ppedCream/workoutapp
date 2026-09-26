import 'dart:io';

import 'package:crypto/crypto.dart';

/// Network and storage limits for optional public content.
abstract final class TrustedContentPolicy {
  static const int maxManifestBytes = 2 * 1024 * 1024;
  static const int maxMediaBytes = 64 * 1024 * 1024;
  static const int maxCacheBytes = 256 * 1024 * 1024;
  static const int maxCacheFiles = 1000;
  static const int maxRedirects = 2;

  static final RegExp _sha256Pattern = RegExp(r'^[a-fA-F0-9]{64}$');

  static void requireHttps(Uri uri, {required String description}) {
    if (uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
      throw FormatException('$description must use an absolute HTTPS URL.');
    }
    if (uri.userInfo.isNotEmpty) {
      throw FormatException('$description must not contain credentials.');
    }
  }

  static Uri validatedRedirect(Uri origin, String location) {
    final redirected = origin.resolve(location);
    requireHttps(redirected, description: 'Content redirect');
    if (redirected.host.toLowerCase() != origin.host.toLowerCase() ||
        redirected.port != origin.port) {
      throw HttpException(
        'Content redirects must remain on the original host.',
        uri: redirected,
      );
    }
    return redirected;
  }

  static bool isJsonContentType(ContentType? type) {
    if (type == null) return false;
    final mime = type.mimeType.toLowerCase();
    return mime == 'application/json' || mime.endsWith('+json');
  }

  static bool isMediaContentType(ContentType? type, String mediaType) {
    if (type == null) return false;
    final mime = type.mimeType.toLowerCase();
    if (mime == 'application/octet-stream') return true;

    return switch (mediaType.trim().toLowerCase()) {
      'image' || 'thumbnail' || 'still' => mime.startsWith('image/'),
      'video' => mime.startsWith('video/'),
      'audio' => mime.startsWith('audio/'),
      _ => false,
    };
  }

  static String validatedSha256(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (!_sha256Pattern.hasMatch(normalized)) {
      throw const FormatException(
        'Remote media must declare a valid SHA-256 digest.',
      );
    }
    return normalized;
  }

  static int validatedMediaBytes(int? value) {
    if (value == null || value <= 0 || value > maxMediaBytes) {
      throw const FormatException(
        'Remote media must declare a supported positive byte size.',
      );
    }
    return value;
  }
}

abstract final class VerifiedMediaWriter {
  static Future<File> writeAtomically(
    Stream<List<int>> source,
    File targetFile, {
    required int expectedBytes,
    required String expectedSha256,
  }) async {
    await targetFile.parent.create(recursive: true);
    final tempFile = File(
      '${targetFile.path}.${DateTime.now().microsecondsSinceEpoch}.download',
    );
    try {
      await _write(
        source,
        tempFile,
        expectedBytes: expectedBytes,
        expectedSha256: expectedSha256,
      );
      await tempFile.rename(targetFile.path);
      return targetFile;
    } catch (_) {
      if (await tempFile.exists()) await tempFile.delete();
      rethrow;
    }
  }

  static Future<void> _write(
    Stream<List<int>> source,
    File tempFile, {
    required int expectedBytes,
    required String expectedSha256,
  }) async {
    final digestSink = _DigestSink();
    final digestInput = sha256.startChunkedConversion(digestSink);
    final output = tempFile.openWrite(mode: FileMode.writeOnly);
    var received = 0;
    try {
      await for (final chunk in source) {
        received += chunk.length;
        if (received > expectedBytes ||
            received > TrustedContentPolicy.maxMediaBytes) {
          throw const FormatException(
            'Media response exceeded its size limit.',
          );
        }
        digestInput.add(chunk);
        output.add(chunk);
      }
      await output.flush();
    } finally {
      digestInput.close();
      await output.close();
    }

    if (received != expectedBytes) {
      throw FormatException(
        'Media byte count did not match the manifest ($received/$expectedBytes).',
      );
    }
    if (digestSink.value.toString() != expectedSha256) {
      throw const FormatException('Media SHA-256 did not match the manifest.');
    }
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? _value;

  Digest get value {
    final digest = _value;
    if (digest == null) throw StateError('Digest was not finalized.');
    return digest;
  }

  @override
  void add(Digest data) => _value = data;

  @override
  void close() {}
}
