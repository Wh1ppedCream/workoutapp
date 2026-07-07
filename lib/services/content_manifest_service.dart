import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/models.dart';

class ContentManifestService {
  static const String defaultBundledManifestAsset =
      'assets/content/exercise_media_manifest.json';

  const ContentManifestService({
    this.bundledManifestAsset = defaultBundledManifestAsset,
  });

  final String bundledManifestAsset;

  Future<ContentManifest> loadBundledExerciseMediaManifest() async {
    final raw = await rootBundle.loadString(bundledManifestAsset);
    return ContentManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<ContentManifest> fetchExerciseMediaManifest(Uri manifestUri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(manifestUri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Manifest request failed with HTTP ${response.statusCode}',
          uri: manifestUri,
        );
      }
      final raw = await response.transform(utf8.decoder).join();
      return ContentManifest.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } finally {
      client.close(force: true);
    }
  }
}
