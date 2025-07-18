// file: lib/models/analytics_models.dart

/// A single rep-max record (for the Metrics tab).
class RepMaxRow {
  /// NEW: the exercise definition ID (`def_id` in the table)
  final int defId;
  final int repCount;
  final double rmValue;
  final double oneErm;
  final bool isErm;
  /// NEW: timeframe string (e.g. '7d', '30d')
  final String timeframe;

  RepMaxRow({
    required this.repCount,
    required this.rmValue,
    required this.oneErm,
    required this.isErm,
    this.defId = 0,
    this.timeframe = '',
  });

  /// NEW: helper to decode a row from SQL
  factory RepMaxRow.fromMap(Map<String, dynamic> m) => RepMaxRow(
        defId:     m['def_id']    as int,
        repCount:  m['rep_count'] as int,
        timeframe: m['timeframe'] as String,
        rmValue:   (m['rm_value'] as num).toDouble(),
        oneErm:    (m['one_erm']  as num).toDouble(),
        isErm:     (m['is_erm']   as int) == 1,
      );

  /// NEW: helper to encode back to SQL
  Map<String, dynamic> toMap() => {
        'def_id':     defId,
        'rep_count':  repCount,
        'timeframe':  timeframe,
        'rm_value':   rmValue,
        'one_erm':    oneErm,
        'is_erm':     isErm ? 1 : 0,
      };
}

/// Associates a muscle with a body part
class MuscleBodyPart {
  final int muscleId;
  final int bodyPartId;
  MuscleBodyPart({required this.muscleId, required this.bodyPartId});
}

/// Ranking for a body part
class BodyPartRanking {
  final int bodyPartId;
  int rank;
  BodyPartRanking({required this.bodyPartId, required this.rank});
}

/// Ranking for a muscle
class MuscleRanking {
  final int muscleId;
  int rank;
  MuscleRanking({required this.muscleId, required this.rank});
}

/// Percent association between exercise and muscle
class ExerciseMusclePercent {
  final int exerciseDefId;
  final int muscleId;
  double percent;
  ExerciseMusclePercent({
    required this.exerciseDefId,
    required this.muscleId,
    required this.percent,
  });
}

/// Volume boundaries for muscle or body part
class VolumeBoundaries {
  final int id; // muscleId or bodyPartId
  final double maintenance;
  final double minEffective;
  final double maxAdaptive;
  final double maxRecoverable;
  VolumeBoundaries({
    required this.id,
    required this.maintenance,
    required this.minEffective,
    required this.maxAdaptive,
    required this.maxRecoverable,
  });

  /// NEW: decode from either muscle or bodypart boundaries table
  factory VolumeBoundaries.fromMap(Map<String, dynamic> m) {
    final keyId = m.containsKey('muscle_id') ? 'muscle_id' : 'bodypart_id';
    return VolumeBoundaries(
      id:               m[keyId] as int,
      maintenance:      (m['maintenance_volume']   as num).toDouble(),
      minEffective:     (m['min_effective_volume'] as num).toDouble(),
      maxAdaptive:      (m['max_adaptive_volume']  as num).toDouble(),
      maxRecoverable:   (m['max_recoverable_volume'] as num).toDouble(),
    );
  }

  /// NEW: encode for muscle table
  Map<String, dynamic> toMuscleMap() => {
        'muscle_id':            id,
        'maintenance_volume':   maintenance,
        'min_effective_volume': minEffective,
        'max_adaptive_volume':  maxAdaptive,
        'max_recoverable_volume': maxRecoverable,
      };

  /// NEW: encode for bodypart table
  Map<String, dynamic> toBodyPartMap() => {
        'bodypart_id':           id,
        'maintenance_volume':    maintenance,
        'min_effective_volume':  minEffective,
        'max_adaptive_volume':   maxAdaptive,
        'max_recoverable_volume': maxRecoverable,
      };
}