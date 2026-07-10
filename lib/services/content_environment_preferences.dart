import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class ContentEnvironmentPreferences {
  static const String exerciseMediaManifestUrlKey =
      'content.exercise_media.remote_manifest_url';
  static const String exerciseMediaEnvironmentKey =
      'content.exercise_media.environment';

  const ContentEnvironmentPreferences();

  Future<String> loadCustomExerciseMediaManifestUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(exerciseMediaManifestUrlKey) ?? '';
  }

  Future<ContentEnvironment> loadSelectedEnvironment(
    ContentEnvironmentConfig config,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedId = prefs.getString(exerciseMediaEnvironmentKey);
    if (selectedId != null) {
      final selected = config.environmentById(selectedId);
      if (selected != null) return selected;
    }
    return config.defaultEnvironment;
  }

  Future<String> loadExerciseMediaManifestUrl(
    ContentEnvironmentConfig config,
  ) async {
    final customUrl = (await loadCustomExerciseMediaManifestUrl()).trim();
    if (customUrl.isNotEmpty) return customUrl;

    final environment = await loadSelectedEnvironment(config);
    return environment.exerciseMediaManifestUrl;
  }

  Future<void> saveSelectedEnvironment(String environmentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(exerciseMediaEnvironmentKey, environmentId);
    await prefs.remove(exerciseMediaManifestUrlKey);
  }

  Future<void> saveCustomExerciseMediaManifestUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(exerciseMediaManifestUrlKey);
    } else {
      await prefs.setString(exerciseMediaManifestUrlKey, trimmed);
    }
  }
}
