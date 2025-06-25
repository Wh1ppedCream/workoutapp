// File: lib/models/preset_models.dart

/// Represents a stored Preset definition, including metadata.
///
/// - [id]: Unique database identifier for the preset.
/// - [name]: Human-readable name of the preset.
/// - [createdAt]: Timestamp when the preset was created.
class PresetDefinition {
  final int id;
  final String name;
  final DateTime createdAt;

  PresetDefinition({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

