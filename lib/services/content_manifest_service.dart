import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/models.dart';

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
  });

  final String bundledManifestAsset;
  final String bundledSharedMediaManifestAsset;
  final String bundledEnvironmentsAsset;

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
    return ContentManifest.fromJson(raw);
  }

  Future<SharedMediaManifest> loadBundledSharedMediaManifest() async {
    final raw = await rootBundle.loadString(bundledSharedMediaManifestAsset);
    return SharedMediaManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<SharedMediaManifest> fetchSharedMediaManifest(Uri manifestUri) async {
    return SharedMediaManifest.fromJson(await _fetchManifestJson(manifestUri));
  }

  Future<Map<String, dynamic>> _fetchManifestJson(Uri manifestUri) async {
    final client = HttpClient()..connectionTimeout = _networkTimeout;
    try {
      final request = await client.getUrl(manifestUri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Manifest request failed with HTTP ${response.statusCode}',
          uri: manifestUri,
        );
      }
      final raw = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_networkTimeout);
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } finally {
      client.close(force: true);
    }
  }
}
