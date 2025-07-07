// File: lib/services/flow_executor.dart

import '../models/preset_models.dart';

/// Walks a saved FlowDefinition + list of FlowMethods
/// to decide, on each session outcome, which methods to run.
class FlowExecutor {
  final String _rootKey;
  final Map<String, String> _branchMap = {};
  final Map<String, List<String>> _methodMap = {};
  final List<FlowMethod> _methods;

  /// [flowDef] comes from fetchFlowDefinition(),
  /// [methods] comes from fetchFlowMethods().
  FlowExecutor({
    required FlowDefinition flowDef,
    required List<FlowMethod> methods,
  }) : _rootKey = flowDef.nodes.isNotEmpty
          ? flowDef.nodes.first
          : '1st attempt',
      _methods = methods {
    for (final e in flowDef.edges) {
      if (e.outcome == 'method') {
        // collect method names per node in insertion order
        _methodMap.putIfAbsent(e.from, () => []).add(e.to);
      } else {
        // branch edge: <from>:<success|failure> -> to
        _branchMap['${e.from}:${e.outcome}'] = e.to;
      }
    }
  }

  /// Walks from [lastNodeKey] (or root) using [outcome] (true=success,false=failure),
  /// returns the ordered FlowMethod objects to apply.
  Future<List<FlowMethod>> traverse({
    String? lastNodeKey,
    required bool outcome,
  }) async {
    final start = lastNodeKey ?? _rootKey;
    final key    = '$start:${outcome ? 'success' : 'failure'}';

    // 1) find the next node on this branch
    String? next = _branchMap[key];
    if (next == null) {
      // 2) if missing, loop back to root and try again
      final rootKey = '$_rootKey:${outcome ? 'success' : 'failure'}';
      next = _branchMap[rootKey];
      if (next == null) {
        // no branch at all for this outcome
        return [];
      }
    }

    // 3) gather method names attached to that node
    final names = _methodMap[next] ?? [];

    // 4) map each name back to its FlowMethod object
    return names.map((n) {
      return _methods.firstWhere((m) => m.name == n);
    }).toList();
  }
}
