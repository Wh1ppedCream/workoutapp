// File: lib/models/gym_models.dart

/// Represents a workout space with its own presets and equipment list.
class GymProfile {
  final int? id;
  final String name;
  final DateTime createdAt;

  GymProfile({this.id, required this.name, required this.createdAt});

  factory GymProfile.fromMap(Map<String, dynamic> map) {
    return GymProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
