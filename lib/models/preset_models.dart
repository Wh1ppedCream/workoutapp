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

  PresetDefinition({
    required this.id,
    required this.name,
    required this.createdAt,
  });
Map<String, dynamic> toMap() => {
    'id':          id,
    'name':        name,
    'created_at':  createdAt.toIso8601String(),
  };
}

/// A single user‐defined “method” node in the flowchart.
class FlowMethod {
  final int    id;
  final int    presetId;
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
    id:       m['id']        as int,
    presetId: m['preset_id'] as int,
    name:     m['name']      as String,
    type:     MethodTypeX.fromString(m['type'] as String),
    params:   jsonDecode(m['params'] as String) as Map<String, dynamic>,
  );

  Map<String, dynamic> toMap() => {
    'id':        id,
    'preset_id': presetId,
    'name':      name,
    'type':      type.toShortString(),
    'params':    jsonEncode(params),
  };
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


/// A single directed edge in the flow graph.
class FlowEdge {
  final String from;      // node name
  final String outcome;   // 'success' or 'failure'
  final String to;        // next node name

  FlowEdge({
    required this.from,
    required this.outcome,
    required this.to,
  });

  factory FlowEdge.fromMap(Map<String, dynamic> m) => FlowEdge(
    from:    m['from']    as String,
    outcome: m['outcome'] as String,
    to:      m['to']      as String,
  );

  Map<String, dynamic> toMap() => {
    'from':    from,
    'outcome': outcome,
    'to':      to,
  };
}

/// The overall flow definition stored as a JSON blob.
class FlowDefinition {
  final List<String> nodes;
  final List<FlowEdge> edges;

  FlowDefinition({ required this.nodes, required this.edges });

  factory FlowDefinition.fromJson(String jsonStr) {
  final Map<String, dynamic> m = jsonDecode(jsonStr) as Map<String, dynamic>;

  // Safely handle missing or null 'nodes' and 'edges'
  final rawNodes = m['nodes'];
  final nodes = rawNodes != null
      ? List<String>.from(rawNodes as List)
      : <String>[];

  final rawEdges = m['edges'];
  final edges = rawEdges != null
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
