import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../models/models.dart';
import 'trusted_content_policy.dart';

typedef ContentHttpClientFactory = HttpClient Function();

class ContentManifestService {
  static const String defaultBundledManifestAsset =
      'assets/content/exercise_media_manifest.json';
  static const String defaultBundledSharedMediaManifestAsset =
      'assets/content/shared_media_manifest.json';
  static const String defaultBundledEnvironmentsAsset =
      'assets/content/content_environments.json';
  static const Duration _networkTimeout = Duration(seconds: 15);

  const ContentManifestService({
    this.bundledManifestAsset = defaultBundledManifestAsset,
    this.bundledSharedMediaManifestAsset =
        defaultBundledSharedMediaManifestAsset,
    this.bundledEnvironmentsAsset = defaultBundledEnvironmentsAsset,
    this.httpClientFactory,
  });

  final String bundledManifestAsset;
  final String bundledSharedMediaManifestAsset;
  final String bundledEnvironmentsAsset;
  final ContentHttpClientFactory? httpClientFactory;

  Future<ContentEnvironmentConfig> loadBundledContentEnvironments() async {
    final raw = await rootBundle.loadString(bundledEnvironmentsAsset);
    return ContentEnvironmentConfig.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<ContentManifest> loadBundledExerciseMediaManifest() async {
    final raw = await rootBundle.loadString(bundledManifestAsset);
    return ContentManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<ContentManifest> fetchExerciseMediaManifest(Uri manifestUri) async {
    final raw = await _fetchManifestJson(manifestUri);
    final manifest = ContentManifest.fromJson(raw);
    _validateExerciseManifest(manifest);
    return manifest;
  }

  Future<SharedMediaManifest> loadBundledSharedMediaManifest() async {
    final raw = await rootBundle.loadString(bundledSharedMediaManifestAsset);
    return SharedMediaManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<SharedMediaManifest> fetchSharedMediaManifest(Uri manifestUri) async {
    final manifest = SharedMediaManifest.fromJson(
      await _fetchManifestJson(manifestUri),
    );
    _validateSharedManifest(manifest);
    return manifest;
  }

  Future<Map<String, dynamic>> _fetchManifestJson(Uri manifestUri) async {
    TrustedContentPolicy.requireHttps(
      manifestUri,
      description: 'Content manifest',
    );
    final client =
        (httpClientFactory?.call() ?? HttpClient())
          ..connectionTimeout = _networkTimeout;
    try {
      final response = await _open(client, manifestUri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Manifest request failed with HTTP ${response.statusCode}',
          uri: manifestUri,
        );
      }
      if (!TrustedContentPolicy.isJsonContentType(
        response.headers.contentType,
      )) {
        throw HttpException(
          'Manifest response was not JSON.',
          uri: manifestUri,
        );
      }
      final declaredLength = response.contentLength;
      if (declaredLength > TrustedContentPolicy.maxManifestBytes) {
        throw HttpException(
          'Manifest response was too large.',
          uri: manifestUri,
        );
      }
      final bytes = await _readLimited(response).timeout(_networkTimeout);
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const FormatException('Content manifest root must be an object.');
      }
      return Map<String, dynamic>.from(decoded);
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
        throw HttpException('Manifest redirect limit exceeded.', uri: uri);
      }
      uri = TrustedContentPolicy.validatedRedirect(uri, location);
    }
    throw HttpException('Manifest redirect limit exceeded.', uri: initialUri);
  }

  Future<List<int>> _readLimited(HttpClientResponse response) async {
    final builder = BytesBuilder(copy: false);
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      if (received > TrustedContentPolicy.maxManifestBytes) {
        throw const FormatException(
          'Manifest response exceeded its size limit.',
        );
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  void _validateExerciseManifest(ContentManifest manifest) {
    if (manifest.namespace != 'exercise_media' || manifest.version <= 0) {
      throw const FormatException('Invalid exercise-media manifest identity.');
    }
    for (final entry in manifest.exerciseMedia) {
      if (entry.exerciseId <= 0) {
        throw const FormatException(
          'Exercise-media entries require a valid ID.',
        );
      }
      for (final asset in entry.assets) {
        _validateAsset(
          remoteUrl: asset.remoteUrl,
          thumbnailUrl: asset.thumbnailUrl,
          bytes: asset.bytes,
          sha256: asset.sha256,
        );
      }
    }
  }

  void _validateSharedManifest(SharedMediaManifest manifest) {
    if (manifest.namespace != 'shared_media' || manifest.version <= 0) {
      throw const FormatException('Invalid shared-media manifest identity.');
    }
    for (final entry in manifest.entities) {
      for (final asset in entry.assets) {
        _validateAsset(
          remoteUrl: asset.remoteUrl,
          thumbnailUrl: asset.thumbnailUrl,
          bytes: asset.bytes,
          sha256: asset.sha256,
        );
      }
    }
  }

  void _validateAsset({
    required String remoteUrl,
    required String? thumbnailUrl,
    required int? bytes,
    required String? sha256,
  }) {
    final remoteUri = Uri.parse(remoteUrl);
    TrustedContentPolicy.requireHttps(remoteUri, description: 'Media asset');
    TrustedContentPolicy.validatedMediaBytes(bytes);
    TrustedContentPolicy.validatedSha256(sha256);
    if (thumbnailUrl != null && thumbnailUrl.trim().isNotEmpty) {
      final thumbnailUri = Uri.parse(thumbnailUrl);
      TrustedContentPolicy.requireHttps(
        thumbnailUri,
        description: 'Media thumbnail',
      );
      if (thumbnailUri != remoteUri) {
        throw const FormatException(
          'A distinct thumbnail requires independent integrity metadata.',
        );
      }
    }
  }
}
