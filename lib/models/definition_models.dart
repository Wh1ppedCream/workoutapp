// File: lib/models/definition_models.dart
// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

enum StarterLoadType {
  bodyweightMultiplier,
  fixedTotal,
  fixedPerSide,
  fixedPerHand,
  bodyweightOnly,
  assisted,
  unknown,
}

enum StarterLoadUnitMode { total, perHand, perSide }

enum StarterWeightConfidence { high, medium, low }

StarterLoadType starterLoadTypeFromString(String? value) {
  switch ((value ?? '').trim()) {
    case 'bodyweightMultiplier':
      return StarterLoadType.bodyweightMultiplier;
    case 'fixedTotal':
      return StarterLoadType.fixedTotal;
    case 'fixedPerSide':
      return StarterLoadType.fixedPerSide;
    case 'fixedPerHand':
      return StarterLoadType.fixedPerHand;
    case 'bodyweightOnly':
      return StarterLoadType.bodyweightOnly;
    case 'assisted':
      return StarterLoadType.assisted;
    default:
      return StarterLoadType.unknown;
  }
}

StarterLoadUnitMode starterLoadUnitModeFromString(String? value) {
  switch ((value ?? '').trim()) {
    case 'perHand':
      return StarterLoadUnitMode.perHand;
    case 'perSide':
      return StarterLoadUnitMode.perSide;
    case 'total':
    default:
      return StarterLoadUnitMode.total;
  }
}

StarterWeightConfidence starterWeightConfidenceFromString(String? value) {
  switch ((value ?? '').trim()) {
    case 'high':
      return StarterWeightConfidence.high;
    case 'low':
      return StarterWeightConfidence.low;
    case 'medium':
    default:
      return StarterWeightConfidence.medium;
  }
}

String starterLoadTypeToString(StarterLoadType value) {
  return value.name;
}

String starterLoadUnitModeToString(StarterLoadUnitMode value) {
  return value.name;
}

String starterWeightConfidenceToString(StarterWeightConfidence value) {
  return value.name;
}

/// Optional metadata used only when a generated exercise has no logged history.
class StarterLoadProfile {
  final StarterLoadType type;
  final double? easyValue;
  final double? mediumValue;
  final double? hardValue;
  final double minimumWeight;
  final double? maximumWeight;
  final double roundingIncrement;
  final StarterLoadUnitMode unitMode;
  final StarterWeightConfidence confidence;
  final String note;

  const StarterLoadProfile({
    required this.type,
    this.easyValue,
    this.mediumValue,
    this.hardValue,
    this.minimumWeight = 0,
    this.maximumWeight,
    this.roundingIncrement = 5,
    this.unitMode = StarterLoadUnitMode.total,
    this.confidence = StarterWeightConfidence.medium,
    this.note = '',
  });

  bool get isConfigured => type != StarterLoadType.unknown;
}

/// Master record for an exercise definition, including equipment, body parts,
/// rating, ranking of targeted muscles, and optional starter-load metadata.
class ExerciseDefinition {
  final int id;
  final String name;
  final int? equipmentId;
  final int rating;
  final List<Equipment> equipmentList;
  final List<BodyPart> bodyParts;
  final List<RankedMuscle> muscles;
  final bool useManualBodyparts;
  final String setupNotes;
  final String executionNotes;
  final String tipsNotes;
  final bool multiplyByRating;
  final StarterLoadProfile? starterLoadProfile;

  /// Creates an [ExerciseDefinition].
  ExerciseDefinition({
    required this.id,
    required this.name,
    this.equipmentId,
    this.rating = 0,
    this.equipmentList = const [],
    this.bodyParts = const [],
    this.muscles = const [],
    required this.useManualBodyparts,
    this.setupNotes = '',
    this.executionNotes = '',
    this.tipsNotes = '',
    required this.multiplyByRating,
    this.starterLoadProfile,
  });
}

class ExerciseMediaItem {
  final int? id;
  final int exerciseDefId;
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

  ExerciseMediaItem({
    this.id,
    required this.exerciseDefId,
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

  factory ExerciseMediaItem.fromMap(Map<String, dynamic> m) {
    return ExerciseMediaItem(
      id: m['id'] as int?,
      exerciseDefId: m['exercise_def_id'] as int,
      assetId: m['asset_id'] as String?,
      mediaType: (m['media_type'] as String?) ?? 'link',
      remoteUrl: (m['remote_url'] as String?) ?? '',
      thumbnailUrl: m['thumbnail_url'] as String?,
      localCachePath: m['local_cache_path'] as String?,
      localThumbnailPath: m['local_thumbnail_path'] as String?,
      title: m['title'] as String?,
      sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
      version: (m['version'] as num?)?.toInt() ?? 1,
      bytes: (m['bytes'] as num?)?.toInt(),
      width: (m['width'] as num?)?.toInt(),
      height: (m['height'] as num?)?.toInt(),
      sha256: m['sha256'] as String?,
      licenseId: m['license_id'] as String?,
      lastAccessedAt: _dateTimeFromString(m['last_accessed_at'] as String?),
      downloadedAt: _dateTimeFromString(m['downloaded_at'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_def_id': exerciseDefId,
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

  ExerciseMediaItem copyWith({
    int? id,
    int? exerciseDefId,
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
    return ExerciseMediaItem(
      id: id ?? this.id,
      exerciseDefId: exerciseDefId ?? this.exerciseDefId,
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

  static DateTime? _dateTimeFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

/// Lookup table entry for equipment.
class Equipment {
  final int id;
  final String name;

  /// Creates an [Equipment] entry.
  Equipment(this.id, this.name);
}

/// Lookup table entry for body parts.
class BodyPart {
  final int id;
  final String name;

  /// Creates a [BodyPart] entry.
  BodyPart(this.id, this.name);
}

/// Lookup table entry for a muscle.
class Muscle {
  final int id;
  final String name;

  /// Creates a [Muscle] entry.
  Muscle({required this.id, required this.name});
}

/// Associates a [Muscle] with a specified [rank] (1 through 7).
class RankedMuscle {
  final Muscle muscle;
  final int rank;

  /// Creates a [RankedMuscle] entry.
  RankedMuscle({required this.muscle, required this.rank});
}
