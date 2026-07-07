import 'definition_models.dart';

class ContentEnvironmentConfig {
  final String defaultEnvironmentId;
  final List<ContentEnvironment> environments;

  const ContentEnvironmentConfig({
    required this.defaultEnvironmentId,
    required this.environments,
  });

  ContentEnvironment get defaultEnvironment {
    return environments.firstWhere(
      (environment) => environment.id == defaultEnvironmentId,
      orElse:
          () =>
              environments.isNotEmpty
                  ? environments.first
                  : ContentEnvironment.empty,
    );
  }

  ContentEnvironment? environmentById(String id) {
    for (final environment in environments) {
      if (environment.id == id) return environment;
    }
    return null;
  }

  factory ContentEnvironmentConfig.fromJson(Map<String, dynamic> json) {
    final environments =
        (json['environments'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (entry) =>
                  ContentEnvironment.fromJson(Map<String, dynamic>.from(entry)),
            )
            .where((environment) => environment.id.isNotEmpty)
            .toList();

    return ContentEnvironmentConfig(
      defaultEnvironmentId:
          (json['defaultEnvironment'] as String?) ??
          (environments.isEmpty ? '' : environments.first.id),
      environments: environments,
    );
  }
}

class ContentEnvironment {
  static const empty = ContentEnvironment(
    id: '',
    label: 'No environment',
    exerciseMediaManifestUrl: '',
  );

  final String id;
  final String label;
  final String exerciseMediaManifestUrl;
  final String description;
  final bool isProduction;

  const ContentEnvironment({
    required this.id,
    required this.label,
    required this.exerciseMediaManifestUrl,
    this.description = '',
    this.isProduction = false,
  });

  bool get hasExerciseMediaManifestUrl =>
      exerciseMediaManifestUrl.trim().isNotEmpty;

  factory ContentEnvironment.fromJson(Map<String, dynamic> json) {
    return ContentEnvironment(
      id: (json['id'] as String?)?.trim() ?? '',
      label: (json['label'] as String?)?.trim() ?? '',
      exerciseMediaManifestUrl:
          (json['exerciseMediaManifestUrl'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      isProduction: json['isProduction'] == true,
    );
  }
}

/// Top-level manifest describing the shared cloud content version the app can
/// sync into its local cache.
class ContentManifest {
  final String namespace;
  final int version;
  final DateTime? generatedAt;
  final List<ExerciseMediaManifestEntry> exerciseMedia;

  const ContentManifest({
    required this.namespace,
    required this.version,
    this.generatedAt,
    this.exerciseMedia = const [],
  });

  factory ContentManifest.fromJson(Map<String, dynamic> json) {
    final exercises =
        (json['exercises'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (entry) => ExerciseMediaManifestEntry.fromJson(
                Map<String, dynamic>.from(entry),
              ),
            )
            .toList();

    return ContentManifest(
      namespace: (json['namespace'] as String?) ?? 'exercise_media',
      version: (json['version'] as num?)?.toInt() ?? 1,
      generatedAt: DateTime.tryParse((json['generatedAt'] as String?) ?? ''),
      exerciseMedia: exercises,
    );
  }
}

/// Media assets attached to one stable local exercise definition.
class ExerciseMediaManifestEntry {
  final int exerciseId;
  final String slug;
  final List<ExerciseMediaItem> assets;

  const ExerciseMediaManifestEntry({
    required this.exerciseId,
    required this.slug,
    required this.assets,
  });

  factory ExerciseMediaManifestEntry.fromJson(Map<String, dynamic> json) {
    final exerciseId = (json['exerciseId'] as num?)?.toInt() ?? -1;
    final assets =
        (json['assets'] as List? ?? const [])
            .whereType<Map>()
            .map((asset) {
              final map = Map<String, dynamic>.from(asset);
              return ExerciseMediaItem(
                exerciseDefId: exerciseId,
                assetId: map['assetId'] as String?,
                mediaType: (map['type'] as String?) ?? 'image',
                remoteUrl: (map['url'] as String?) ?? '',
                thumbnailUrl: map['thumbnailUrl'] as String?,
                title: map['title'] as String?,
                sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
                version: (map['version'] as num?)?.toInt() ?? 1,
                bytes: (map['bytes'] as num?)?.toInt(),
                width: (map['width'] as num?)?.toInt(),
                height: (map['height'] as num?)?.toInt(),
                sha256: map['sha256'] as String?,
                licenseId: map['licenseId'] as String?,
              );
            })
            .where((asset) => asset.remoteUrl.isNotEmpty)
            .toList();

    return ExerciseMediaManifestEntry(
      exerciseId: exerciseId,
      slug: (json['slug'] as String?) ?? '',
      assets: assets,
    );
  }
}

class ContentCacheUsage {
  final int fileCount;
  final int totalBytes;

  const ContentCacheUsage({required this.fileCount, required this.totalBytes});
}

class ContentManifestStatus {
  final String namespace;
  final int version;
  final String? etag;
  final DateTime? lastCheckedAt;
  final DateTime? downloadedAt;

  const ContentManifestStatus({
    required this.namespace,
    required this.version,
    this.etag,
    this.lastCheckedAt,
    this.downloadedAt,
  });

  factory ContentManifestStatus.fromMap(Map<String, Object?> row) {
    return ContentManifestStatus(
      namespace: row['namespace'] as String,
      version: (row['version'] as num?)?.toInt() ?? 0,
      etag: row['etag'] as String?,
      lastCheckedAt: _dateTimeFromString(row['last_checked_at'] as String?),
      downloadedAt: _dateTimeFromString(row['downloaded_at'] as String?),
    );
  }

  static DateTime? _dateTimeFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
