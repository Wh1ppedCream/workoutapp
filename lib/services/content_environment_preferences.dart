import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'content_environment_policy.dart';

class ContentEnvironmentPreferences {
  static const String exerciseMediaManifestUrlKey =
      'content.exercise_media.remote_manifest_url';
  static const String exerciseMediaEnvironmentKey =
      'content.exercise_media.environment';
  static const String activeContentScopeKey = 'content.active_scope.v1';

  ContentEnvironmentPreferences({ContentEnvironmentPolicy? policy})
    : policy = policy ?? ContentEnvironmentPolicy();

  final ContentEnvironmentPolicy policy;

  bool get allowsRuntimeOverrides => policy.buildPolicy.allowRuntimeOverrides;

  Future<String> loadCustomExerciseMediaManifestUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(exerciseMediaManifestUrlKey) ?? '';
  }

  Future<ContentEnvironment> loadSelectedEnvironment(
    ContentEnvironmentConfig config,
  ) async {
    return (await loadEffectiveEnvironment(config)).environment;
  }

  Future<EffectiveContentEnvironment> loadEffectiveEnvironment(
    ContentEnvironmentConfig config,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return policy.resolve(
      config: config,
      savedEnvironmentId: prefs.getString(exerciseMediaEnvironmentKey),
      customExerciseMediaManifestUrl: prefs.getString(
        exerciseMediaManifestUrlKey,
      ),
    );
  }

  Future<String> loadExerciseMediaManifestUrl(
    ContentEnvironmentConfig config,
  ) async {
    return (await loadEffectiveEnvironment(config)).exerciseMediaManifestUrl;
  }

  /// Shared catalog media always follows the selected content environment.
  /// A custom exercise-media URL intentionally does not redirect equipment or
  /// anatomy content to an unrelated manifest.
  Future<String> loadSharedMediaManifestUrl(
    ContentEnvironmentConfig config,
  ) async {
    return (await loadEffectiveEnvironment(config)).sharedMediaManifestUrl;
  }

  Future<void> saveSelectedEnvironment(String environmentId) async {
    _requireRuntimeOverrides();
    final trimmed = environmentId.trim();
    if (trimmed.isEmpty) {
      throw const ContentEnvironmentPolicyException(
        'A content environment ID is required.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(exerciseMediaEnvironmentKey, trimmed);
    await prefs.remove(exerciseMediaManifestUrlKey);
  }

  Future<void> saveCustomExerciseMediaManifestUrl(String value) async {
    _requireRuntimeOverrides();
    final prefs = await SharedPreferences.getInstance();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(exerciseMediaManifestUrlKey);
      return;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.hasPort ||
        uri.userInfo.isNotEmpty) {
      throw const ContentEnvironmentPolicyException(
        'Custom manifest URLs must use HTTPS without credentials.',
      );
    }
    await prefs.setString(exerciseMediaManifestUrlKey, trimmed);
  }

  Future<String?> loadActiveContentScope() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeContentScopeKey);
  }

  Future<void> saveActiveContentScope(String scope) async {
    final trimmed = scope.trim();
    if (trimmed.isEmpty) {
      throw const ContentEnvironmentPolicyException(
        'The active content scope cannot be empty.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeContentScopeKey, trimmed);
  }

  void _requireRuntimeOverrides() {
    if (!allowsRuntimeOverrides) {
      throw const ContentEnvironmentPolicyException(
        'This build locks its content environment.',
      );
    }
  }
}
