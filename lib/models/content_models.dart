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
    sharedMediaManifestUrl: '',
  );

  final String id;
  final String label;
  final String exerciseMediaManifestUrl;
  final String sharedMediaManifestUrl;
  final String description;
  final bool isProduction;

  const ContentEnvironment({
    required this.id,
    required this.label,
    required this.exerciseMediaManifestUrl,
    this.sharedMediaManifestUrl = '',
    this.description = '',
    this.isProduction = false,
  });

  bool get hasExerciseMediaManifestUrl =>
      exerciseMediaManifestUrl.trim().isNotEmpty;

  bool get hasSharedMediaManifestUrl =>
      sharedMediaManifestUrl.trim().isNotEmpty;

  factory ContentEnvironment.fromJson(Map<String, dynamic> json) {
    return ContentEnvironment(
      id: (json['id'] as String?)?.trim() ?? '',
      label: (json['label'] as String?)?.trim() ?? '',
      exerciseMediaManifestUrl:
          (json['exerciseMediaManifestUrl'] as String?)?.trim() ?? '',
      sharedMediaManifestUrl:
          (json['sharedMediaManifestUrl'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      isProduction: json['isProduction'] == true,
    );
  }
}

/// Stable types of shared catalog entities that can receive optional cloud
/// illustrations. These remain separate from exercise-specific media.
enum SharedMediaEntityType { equipment, bodypart, muscle }

SharedMediaEntityType? sharedMediaEntityTypeFromString(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'equipment':
      return SharedMediaEntityType.equipment;
    case 'bodypart':
    case 'bodyparts':
    case 'body_part':
      return SharedMediaEntityType.bodypart;
    case 'muscle':
    case 'muscles':
      return SharedMediaEntityType.muscle;
    default:
      return null;
  }
}

String sharedMediaEntityTypeToString(SharedMediaEntityType value) {
  return value.name;
}

/// Manifest for optional equipment, bodypart, and muscle illustrations.
///
/// Source IDs are retained for pipeline validation, but the app resolves every
/// entry by its type and canonical slug. Local lookup IDs are autoincremented
/// and can differ between database histories, so they must not identify cloud
/// media on their own.
class SharedMediaManifest {
  final String namespace;
  final int version;
  final DateTime? generatedAt;
  final List<SharedMediaManifestEntry> entities;

  const SharedMediaManifest({
    required this.namespace,
    required this.version,
    this.generatedAt,
    this.entities = const [],
  });

  factory SharedMediaManifest.fromJson(Map<String, dynamic> json) {
    final entries = <SharedMediaManifestEntry>[];
    final rawEntities = json['entities'] as List? ?? const [];
    for (final rawEntry in rawEntities.whereType<Map>()) {
      final entry = SharedMediaManifestEntry.fromJson(
        Map<String, dynamic>.from(rawEntry),
      );
      if (entry != null) entries.add(entry);
    }

    // Accept grouped manifests too, which keeps manually-authored source files
    // easy to read while the app stores one normalized entity list.
    const groupedTypes = <String, SharedMediaEntityType>{
      'equipment': SharedMediaEntityType.equipment,
      'bodyparts': SharedMediaEntityType.bodypart,
      'muscles': SharedMediaEntityType.muscle,
    };
    for (final group in groupedTypes.entries) {
      final rawGroup = json[group.key] as List? ?? const [];
      for (final rawEntry in rawGroup.whereType<Map>()) {
        final map = Map<String, dynamic>.from(rawEntry);
        map.putIfAbsent('entityType', () => group.value.name);
        final entry = SharedMediaManifestEntry.fromJson(map);
        if (entry != null) entries.add(entry);
      }
    }

    return SharedMediaManifest(
      namespace: (json['namespace'] as String?)?.trim() ?? 'shared_media',
      version: (json['version'] as num?)?.toInt() ?? 1,
      generatedAt: DateTime.tryParse((json['generatedAt'] as String?) ?? ''),
      entities: entries,
    );
  }
}

class SharedMediaManifestEntry {
  final SharedMediaEntityType entityType;
  final int entityId;
  final String slug;
  final List<SharedMediaItem> assets;

  const SharedMediaManifestEntry({
    required this.entityType,
    required this.entityId,
    required this.slug,
    required this.assets,
  });

  static SharedMediaManifestEntry? fromJson(Map<String, dynamic> json) {
    final type = sharedMediaEntityTypeFromString(
      json['entityType'] as String? ?? json['type'] as String?,
    );
    final entityId = (json['entityId'] as num?)?.toInt() ?? -1;
    if (type == null || entityId <= 0) return null;

    final assets =
        (json['assets'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (asset) => SharedMediaItem.fromManifestJson(
                entityType: type,
                entityId: entityId,
                map: Map<String, dynamic>.from(asset),
              ),
            )
            .where((asset) => asset.remoteUrl.isNotEmpty)
            .toList();

    return SharedMediaManifestEntry(
      entityType: type,
      entityId: entityId,
      slug: (json['slug'] as String?)?.trim() ?? '',
      assets: assets,
    );
  }
}

/// One cacheable media item attached to a shared catalog entity.
class SharedMediaItem {
  final int? id;
  final SharedMediaEntityType entityType;
  final int entityId;
  final String? assetId;
  final String mediaType;
  final String remoteUrl;
  final String? thumbnailUrl;
  final String? localCachePath;
  final String? localThumbnailPath;
  final String? title;
  final int sortOrder;
  final int version;
  final int? bytes;
  final int? width;
  final int? height;
  final String? sha256;
  final String? licenseId;
  final DateTime? lastAccessedAt;
  final DateTime? downloadedAt;

  const SharedMediaItem({
    this.id,
    required this.entityType,
    required this.entityId,
    this.assetId,
    required this.mediaType,
    required this.remoteUrl,
    this.thumbnailUrl,
    this.localCachePath,
    this.localThumbnailPath,
    this.title,
    this.sortOrder = 0,
    this.version = 1,
    this.bytes,
    this.width,
    this.height,
    this.sha256,
    this.licenseId,
    this.lastAccessedAt,
    this.downloadedAt,
  });

  factory SharedMediaItem.fromManifestJson({
    required SharedMediaEntityType entityType,
    required int entityId,
    required Map<String, dynamic> map,
  }) {
    return SharedMediaItem(
      entityType: entityType,
      entityId: entityId,
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
  }

  factory SharedMediaItem.fromMap(Map<String, Object?> map) {
    return SharedMediaItem(
      id: map['id'] as int?,
      entityType:
          sharedMediaEntityTypeFromString(map['entity_type'] as String?) ??
          SharedMediaEntityType.equipment,
      entityId: (map['entity_id'] as num?)?.toInt() ?? -1,
      assetId: map['asset_id'] as String?,
      mediaType: (map['media_type'] as String?) ?? 'image',
      remoteUrl: (map['remote_url'] as String?) ?? '',
      thumbnailUrl: map['thumbnail_url'] as String?,
      localCachePath: map['local_cache_path'] as String?,
      localThumbnailPath: map['local_thumbnail_path'] as String?,
      title: map['title'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      version: (map['version'] as num?)?.toInt() ?? 1,
      bytes: (map['bytes'] as num?)?.toInt(),
      width: (map['width'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toInt(),
      sha256: map['sha256'] as String?,
      licenseId: map['license_id'] as String?,
      lastAccessedAt: _contentDateTime(map['last_accessed_at'] as String?),
      downloadedAt: _contentDateTime(map['downloaded_at'] as String?),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'entity_type': sharedMediaEntityTypeToString(entityType),
      'entity_id': entityId,
      'asset_id': assetId,
      'media_type': mediaType,
      'remote_url': remoteUrl,
      'thumbnail_url': thumbnailUrl,
      'local_cache_path': localCachePath,
      'local_thumbnail_path': localThumbnailPath,
      'title': title,
      'sort_order': sortOrder,
      'version': version,
      'bytes': bytes,
      'width': width,
      'height': height,
      'sha256': sha256,
      'license_id': licenseId,
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'downloaded_at': downloadedAt?.toIso8601String(),
    };
  }

  SharedMediaItem copyWith({
    int? id,
    int? entityId,
    String? assetId,
    String? mediaType,
    String? remoteUrl,
    String? thumbnailUrl,
    String? localCachePath,
    String? localThumbnailPath,
    String? title,
    int? sortOrder,
    int? version,
    int? bytes,
    int? width,
    int? height,
    String? sha256,
    String? licenseId,
    DateTime? lastAccessedAt,
    DateTime? downloadedAt,
  }) {
    return SharedMediaItem(
      id: id ?? this.id,
      entityType: entityType,
      entityId: entityId ?? this.entityId,
      assetId: assetId ?? this.assetId,
      mediaType: mediaType ?? this.mediaType,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localCachePath: localCachePath ?? this.localCachePath,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      version: version ?? this.version,
      bytes: bytes ?? this.bytes,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      licenseId: licenseId ?? this.licenseId,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}

DateTime? _contentDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
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
