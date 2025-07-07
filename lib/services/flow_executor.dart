// File: lib/services/flow_executor.dart

import '../models/preset_models.dart';


/// When you traverse, you need both the node you landed on
/// *and* the methods attached there.
class TraverseResult {
  /// The node key (e.g. "success1" or "fail2")
  final String nodeKey;

  /// The ordered list of FlowMethods to run at that node
  final List<FlowMethod> methods;

  TraverseResult(this.nodeKey, this.methods);
}

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

/// Walks one step from [lastNodeKey] (or root) with [outcome].
  /// Returns both the nodeKey you land on, and its methods.
  Future<TraverseResult> traverse({
    String? lastNodeKey,
    required bool outcome,
  }) async {
    // start from where we left off (or from root)
    final start = lastNodeKey ?? _rootKey;
    final branch = outcome ? 'success' : 'failure';
    var next = _branchMap['$start:$branch'];

    if (next == null) {
      // loop back to root and try again
      next = _branchMap['$_rootKey:$branch'];
      next ??= _rootKey;
    }

     // 3) gather method names attached to that node
  final names = _methodMap[next] ?? [];

  // 4) map each name back to its FlowMethod object, skipping any missing
  final resultMethods = <FlowMethod>[];
  for (var name in names) {
    for (var method in _methods) {
      if (method.name == name) {
        resultMethods.add(method);
        break;    // stop searching once we've found the match
      }
    }
    // if no method matched that name, we simply skip it
  }

  return TraverseResult(next, resultMethods);
  }
}