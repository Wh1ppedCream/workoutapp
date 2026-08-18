// file: lib/models/measurement_models.dart

// ─────────────────────────────────────────────────────────────────────────────
// MEASUREMENTS
// ─────────────────────────────────────────────────────────────────────────────

// ignore_for_file: constant_identifier_names

/// Enumeration of measurement types a user can track (e.g., body weight, height).
enum MeasurementType {
  BodyWeight,
  Height,
  Forearm,
  Arm,
  Neck,
  Shoulder,
  Chest,
  Waist,
  Hip,
  Thigh,
  Calf,
  Custom,
}

/// Context selected alongside a measurement without storing display copy.
enum MeasurementContext { wakeUp, bedtime, overall, withPump, withoutPump }

/// Definition of a measurement kind, linking to [MeasurementType].
class MeasurementDefinition {
  final int id;
  final String name;
  final MeasurementType type;

  /// Creates a [MeasurementDefinition].
  MeasurementDefinition({
    required this.id,
    required this.name,
    required this.type,
  });
}

/// A recorded measurement with timestamp, value, unit, and optional note.
class Measurement {
  final int id;
  final int defId;
  final DateTime timestamp;
  final double value;
  final String unit;
  final String? note;
  final MeasurementContext? context;

  /// Creates a [Measurement] record.
  Measurement({
    required this.id,
    required this.defId,
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
    this.context,
  });
}
