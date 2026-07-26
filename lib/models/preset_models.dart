// File: lib/models/preset_models.dart
import 'dart:convert';

/// Represents a stored Preset definition, including metadata.
///
/// - [id]: Unique database identifier for the preset.
/// - [name]: Human-readable name of the preset.
/// - [createdAt]: Timestamp when the preset was created.
class PresetDefinition {
  final int id;
  final String name;
  final DateTime createdAt;
  final int? profileId;
  final bool isDraft;

  PresetDefinition({
    required this.id,
    required this.name,
    required this.createdAt,
    this.profileId,
    this.isDraft = false,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'profile_id': profileId,
    'is_draft': isDraft ? 1 : 0,
  };
}

/// A single user‐defined “method” node in the flowchart.
class FlowMethod {
  final int id;
  final int presetId;
  final String name;
  final MethodType type;
  final Map<String, dynamic> params; // deserialized JSON

  FlowMethod({
    required this.id,
    required this.presetId,
    required this.name,
    required this.type,
    required this.params,
  });

  factory FlowMethod.fromMap(Map<String, dynamic> m) => FlowMethod(
    id: m['id'] as int,
    presetId: m['preset_id'] as int,
    name: m['name'] as String,
    type: MethodTypeX.fromString(m['type'] as String),
    params: jsonDecode(m['params'] as String) as Map<String, dynamic>,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'preset_id': presetId,
    'name': name,
    'type': type.toShortString(),
    'params': jsonEncode(params),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FlowMethod && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The four method‐types you can apply.
enum MethodType { weight, rep, addSet, delSet }

extension MethodTypeX on MethodType {
  /// Before: describeEnum(this)
  /// Now: use the enum’s built-in `.name`.
  String toShortString() => name;

  static MethodType fromString(String s) =>
      MethodType.values.firstWhere((e) => e.name == s);
}

/// Determines the level at which a completed workout is considered successful.
enum ProgressionSuccessScope { session, exercise, set }

extension ProgressionSuccessScopeX on ProgressionSuccessScope {
  static ProgressionSuccessScope fromStorage(Object? value) {
    final stored = value?.toString();
    return ProgressionSuccessScope.values.firstWhere(
      (scope) => scope.name == stored,
      orElse: () => ProgressionSuccessScope.set,
    );
  }
}

/// A complete, atomic update to one existing preset set.
class PresetSetProgressionUpdate {
  final int setId;
  final double weight;
  final int reps;
  final int orderIndex;

  const PresetSetProgressionUpdate({
    required this.setId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });
}

/// A new parent preset set created by a progression action.
class PresetSetProgressionInsert {
  final int presetExerciseId;
  final double weight;
  final int reps;
  final int orderIndex;

  const PresetSetProgressionInsert({
    required this.presetExerciseId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });
}

/// The traversal and rotating-set state saved for a preset exercise.
class PresetExerciseProgressionState {
  final int presetExerciseId;
  final double? incrementAmount;
  final int lastSetIndex;
  final String? lastNode;

  const PresetExerciseProgressionState({
    required this.presetExerciseId,
    this.incrementAmount,
    required this.lastSetIndex,
    this.lastNode,
  });
}

/// Database mutations produced by one completed automatic workout.
class PresetProgressionBatch {
  final List<PresetSetProgressionUpdate> updates;
  final List<PresetSetProgressionInsert> inserts;
  final List<int> deletedSetIds;
  final List<PresetExerciseProgressionState> exerciseStates;

  const PresetProgressionBatch({
    this.updates = const [],
    this.inserts = const [],
    this.deletedSetIds = const [],
    this.exerciseStates = const [],
  });

  bool get isEmpty =>
      updates.isEmpty &&
      inserts.isEmpty &&
      deletedSetIds.isEmpty &&
      exerciseStates.isEmpty;
}

/// A single directed edge in the flow graph.
class FlowEdge {
  final String from; // node name
  final String outcome; // 'success' or 'failure'
  final String to; // next node name

  FlowEdge({required this.from, required this.outcome, required this.to});

  factory FlowEdge.fromMap(Map<String, dynamic> m) => FlowEdge(
    from: m['from'] as String,
    outcome: m['outcome'] as String,
    to: m['to'] as String,
  );

  Map<String, dynamic> toMap() => {'from': from, 'outcome': outcome, 'to': to};
}

/// The overall flow definition stored as a JSON blob.
class FlowDefinition {
  final List<String> nodes;
  final List<FlowEdge> edges;

  FlowDefinition({required this.nodes, required this.edges});

  factory FlowDefinition.fromJson(String jsonStr) {
    final Map<String, dynamic> m = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Safely handle missing or null 'nodes' and 'edges'
    final rawNodes = m['nodes'];
    final nodes =
        rawNodes != null ? List<String>.from(rawNodes as List) : <String>[];

    final rawEdges = m['edges'];
    final edges =
        rawEdges != null
            ? (rawEdges as List).map((e) {
              return FlowEdge.fromMap(e as Map<String, dynamic>);
            }).toList()
            : <FlowEdge>[];

    return FlowDefinition(nodes: nodes, edges: edges);
  }

  String toJson() => jsonEncode({
    'nodes': nodes,
    'edges': edges.map((e) => e.toMap()).toList(),
  });
}
