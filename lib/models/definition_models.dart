// File: lib/models/definition_models.dart
// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Master record for an exercise definition, including equipment, body parts,
/// rating, and ranking of targeted muscles.
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
  final bool   multiplyByRating;

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
    this.setupNotes     = '',
    this.executionNotes = '',
    this.tipsNotes      = '',
    required this.multiplyByRating,
  });
}

class ExerciseMediaItem {
  final int? id;
  final int exerciseDefId;
  final String mediaType;
  final String remoteUrl;
  final String? thumbnailUrl;
  final String? localCachePath;
  final String? localThumbnailPath;
  final String? title;
  final int sortOrder;

  ExerciseMediaItem({
    this.id,
    required this.exerciseDefId,
    required this.mediaType,
    required this.remoteUrl,
    this.thumbnailUrl,
    this.localCachePath,
    this.localThumbnailPath,
    this.title,
    this.sortOrder = 0,
  });

  factory ExerciseMediaItem.fromMap(Map<String, dynamic> m) {
    return ExerciseMediaItem(
      id: m['id'] as int?,
      exerciseDefId: m['exercise_def_id'] as int,
      mediaType: (m['media_type'] as String?) ?? 'link',
      remoteUrl: (m['remote_url'] as String?) ?? '',
      thumbnailUrl: m['thumbnail_url'] as String?,
      localCachePath: m['local_cache_path'] as String?,
      localThumbnailPath: m['local_thumbnail_path'] as String?,
      title: m['title'] as String?,
      sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_def_id': exerciseDefId,
      'media_type': mediaType,
      'remote_url': remoteUrl,
      'thumbnail_url': thumbnailUrl,
      'local_cache_path': localCachePath,
      'local_thumbnail_path': localThumbnailPath,
      'title': title,
      'sort_order': sortOrder,
    };
  }

  ExerciseMediaItem copyWith({
    int? id,
    int? exerciseDefId,
    String? mediaType,
    String? remoteUrl,
    String? thumbnailUrl,
    String? localCachePath,
    String? localThumbnailPath,
    String? title,
    int? sortOrder,
  }) {
    return ExerciseMediaItem(
      id: id ?? this.id,
      exerciseDefId: exerciseDefId ?? this.exerciseDefId,
      mediaType: mediaType ?? this.mediaType,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localCachePath: localCachePath ?? this.localCachePath,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
    );
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
  Muscle({
    required this.id,
    required this.name,
  });
}

/// Associates a [Muscle] with a specified [rank] (1 through 7).
class RankedMuscle {
  final Muscle muscle;
  final int rank;

  /// Creates a [RankedMuscle] entry.
  RankedMuscle({
    required this.muscle,
    required this.rank,
  });
}
