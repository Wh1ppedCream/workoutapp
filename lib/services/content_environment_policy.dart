import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/content_models.dart';

const String _compileTimeContentEnvironment = String.fromEnvironment(
  'TONOS_CONTENT_ENVIRONMENT',
);
const String _legacyCompileTimeEnvironment = String.fromEnvironment(
  'TONOS_ENVIRONMENT',
);
const String _compileTimeOverrideSetting = String.fromEnvironment(
  'TONOS_CONTENT_ALLOW_OVERRIDES',
);

class ContentEnvironmentPolicyException implements Exception {
  const ContentEnvironmentPolicyException(this.message);

  final String message;

  @override
  String toString() => 'ContentEnvironmentPolicyException: $message';
}

class ContentBuildPolicy {
  const ContentBuildPolicy({
    required this.targetEnvironmentId,
    required this.environmentWasExplicit,
    required this.allowRuntimeOverrides,
    required this.isReleaseMode,
  });

  final String targetEnvironmentId;
  final bool environmentWasExplicit;
  final bool allowRuntimeOverrides;
  final bool isReleaseMode;

  factory ContentBuildPolicy.fromCompileTime({bool? releaseMode}) {
    final contentEnvironment = _compileTimeContentEnvironment.trim();
    final legacyEnvironment = _legacyCompileTimeEnvironment.trim();
    if (contentEnvironment.isNotEmpty &&
        legacyEnvironment.isNotEmpty &&
        contentEnvironment != legacyEnvironment) {
      throw const ContentEnvironmentPolicyException(
        'TONOS_CONTENT_ENVIRONMENT conflicts with legacy TONOS_ENVIRONMENT.',
      );
    }

    final configuredEnvironment =
        contentEnvironment.isNotEmpty
            ? contentEnvironment
            : legacyEnvironment.isNotEmpty
            ? legacyEnvironment
            : 'development';
    final effectiveReleaseMode = releaseMode ?? kReleaseMode;

    return ContentBuildPolicy(
      targetEnvironmentId: configuredEnvironment,
      environmentWasExplicit:
          contentEnvironment.isNotEmpty || legacyEnvironment.isNotEmpty,
      allowRuntimeOverrides: _parseOverrideSetting(
        _compileTimeOverrideSetting,
        fallback: !effectiveReleaseMode,
      ),
      isReleaseMode: effectiveReleaseMode,
    );
  }

  static bool _parseOverrideSetting(String value, {required bool fallback}) {
    switch (value.trim().toLowerCase()) {
      case '':
        return fallback;
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw const ContentEnvironmentPolicyException(
          'TONOS_CONTENT_ALLOW_OVERRIDES must be true or false.',
        );
    }
  }
}

enum ContentEnvironmentSelectionSource {
  build,
  savedPreference,
  customExerciseManifest,
}

enum ContentEnvironmentScopeAction { none, adopt, reset }

class EffectiveContentEnvironment {
  const EffectiveContentEnvironment({
    required this.environment,
    required this.exerciseMediaManifestUrl,
    required this.sharedMediaManifestUrl,
    required this.source,
    required this.allowRuntimeOverrides,
    required this.cacheScope,
  });

  final ContentEnvironment environment;
  final String exerciseMediaManifestUrl;
  final String sharedMediaManifestUrl;
  final ContentEnvironmentSelectionSource source;
  final bool allowRuntimeOverrides;
  final String cacheScope;

  bool get isLocked => !allowRuntimeOverrides;
}

class ContentEnvironmentPolicy {
  ContentEnvironmentPolicy({ContentBuildPolicy? buildPolicy})
    : buildPolicy = buildPolicy ?? ContentBuildPolicy.fromCompileTime();

  final ContentBuildPolicy buildPolicy;

  EffectiveContentEnvironment resolve({
    required ContentEnvironmentConfig config,
    String? savedEnvironmentId,
    String? customExerciseMediaManifestUrl,
  }) {
    _validateConfig(config);
    if (buildPolicy.isReleaseMode && buildPolicy.allowRuntimeOverrides) {
      throw const ContentEnvironmentPolicyException(
        'Release builds cannot enable runtime content overrides.',
      );
    }

    final buildEnvironment = config.environmentById(
      buildPolicy.targetEnvironmentId.trim(),
    );
    if (buildEnvironment == null) {
      throw ContentEnvironmentPolicyException(
        'Build target "${buildPolicy.targetEnvironmentId}" is not configured.',
      );
    }
    if (buildPolicy.targetEnvironmentId == 'production' &&
        !buildEnvironment.isProduction) {
      throw const ContentEnvironmentPolicyException(
        'The production build target is not marked as production.',
      );
    }
    if (!buildPolicy.environmentWasExplicit && buildEnvironment.isProduction) {
      throw const ContentEnvironmentPolicyException(
        'An implicit build target cannot select production content.',
      );
    }

    var environment = buildEnvironment;
    var source = ContentEnvironmentSelectionSource.build;
    final savedId = savedEnvironmentId?.trim() ?? '';
    if (buildPolicy.allowRuntimeOverrides && savedId.isNotEmpty) {
      final savedEnvironment = config.environmentById(savedId);
      if (savedEnvironment != null) {
        environment = savedEnvironment;
        source = ContentEnvironmentSelectionSource.savedPreference;
      }
    }

    var exerciseManifestUrl = environment.exerciseMediaManifestUrl.trim();
    final customUrl = customExerciseMediaManifestUrl?.trim() ?? '';
    if (buildPolicy.allowRuntimeOverrides && customUrl.isNotEmpty) {
      _requireHttpsManifestUrl(customUrl, description: 'Custom exercise');
      exerciseManifestUrl = customUrl;
      source = ContentEnvironmentSelectionSource.customExerciseManifest;
    }

    _validateEnvironmentUrls(environment);
    final sharedManifestUrl = environment.sharedMediaManifestUrl.trim();
    final scopeInput = [
      'v1',
      environment.id,
      exerciseManifestUrl,
      sharedManifestUrl,
    ].join('|');
    final scopeHash = sha256.convert(utf8.encode(scopeInput)).toString();

    return EffectiveContentEnvironment(
      environment: environment,
      exerciseMediaManifestUrl: exerciseManifestUrl,
      sharedMediaManifestUrl: sharedManifestUrl,
      source: source,
      allowRuntimeOverrides: buildPolicy.allowRuntimeOverrides,
      cacheScope: 'content-v1:${environment.id}:$scopeHash',
    );
  }

  ContentEnvironmentScopeAction scopeAction({
    required String? activeScope,
    required EffectiveContentEnvironment selection,
  }) {
    final current = activeScope?.trim() ?? '';
    if (current == selection.cacheScope) {
      return ContentEnvironmentScopeAction.none;
    }
    if (current.isEmpty && selection.allowRuntimeOverrides) {
      return ContentEnvironmentScopeAction.adopt;
    }
    return ContentEnvironmentScopeAction.reset;
  }

  void requireSelectedManifestUri(
    EffectiveContentEnvironment selection,
    Uri manifestUri, {
    required bool sharedMedia,
  }) {
    final description = sharedMedia ? 'Shared media' : 'Exercise media';
    final expectedValue =
        sharedMedia
            ? selection.sharedMediaManifestUrl
            : selection.exerciseMediaManifestUrl;
    final expected = _requireHttpsManifestUrl(
      expectedValue,
      description: description,
    );
    _requireHttpsManifestUrl(manifestUri.toString(), description: description);
    if (manifestUri != expected) {
      throw ContentEnvironmentPolicyException(
        '$description sync must use the resolved content environment URL.',
      );
    }
  }

  void _validateConfig(ContentEnvironmentConfig config) {
    if (config.environments.isEmpty) {
      throw const ContentEnvironmentPolicyException(
        'At least one content environment is required.',
      );
    }
    final ids = <String>{};
    for (final environment in config.environments) {
      if (environment.id.isEmpty || !ids.add(environment.id)) {
        throw const ContentEnvironmentPolicyException(
          'Content environment IDs must be non-empty and unique.',
        );
      }
    }
    if (config.environmentById(config.defaultEnvironmentId) == null) {
      throw const ContentEnvironmentPolicyException(
        'The default content environment is not configured.',
      );
    }
    if (config.environments
            .where((environment) => environment.isProduction)
            .length !=
        1) {
      throw const ContentEnvironmentPolicyException(
        'Exactly one content environment must be marked as production.',
      );
    }
    if (config.environmentById('production')?.isProduction != true) {
      throw const ContentEnvironmentPolicyException(
        'The production content environment must use the ID "production".',
      );
    }

    final productionHosts = <String>{};
    final nonProductionHosts = <String>{};
    for (final environment in config.environments) {
      _validateEnvironmentUrls(environment);
      final destination =
          environment.isProduction ? productionHosts : nonProductionHosts;
      destination.addAll(environment.allowedManifestHosts);
    }
    if (productionHosts.intersection(nonProductionHosts).isNotEmpty) {
      throw const ContentEnvironmentPolicyException(
        'Production and non-production manifest hosts must be distinct.',
      );
    }
  }

  void _validateEnvironmentUrls(ContentEnvironment environment) {
    final hosts = environment.allowedManifestHosts;
    if (hosts.isEmpty ||
        hosts.any(
          (host) =>
              host.isEmpty || host != host.trim() || host != host.toLowerCase(),
        ) ||
        hosts.toSet().length != hosts.length) {
      throw ContentEnvironmentPolicyException(
        'Content environment ${environment.id} requires unique lowercase '
        'manifest hosts.',
      );
    }

    for (final entry in <(String, String)>[
      ('Exercise media', environment.exerciseMediaManifestUrl),
      ('Shared media', environment.sharedMediaManifestUrl),
    ]) {
      final uri = _requireHttpsManifestUrl(
        entry.$2.trim(),
        description: entry.$1,
      );
      if (!hosts.contains(uri.host.toLowerCase())) {
        throw ContentEnvironmentPolicyException(
          '${entry.$1} manifest host is not allowlisted for '
          '${environment.id}.',
        );
      }
    }
  }

  Uri _requireHttpsManifestUrl(String value, {required String description}) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.hasPort ||
        uri.userInfo.isNotEmpty) {
      throw ContentEnvironmentPolicyException(
        '$description manifest URL must be an HTTPS URL without credentials.',
      );
    }
    return uri;
  }
}
