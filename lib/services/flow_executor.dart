// File: lib/services/flow_executor.dart

import '../models/preset_models.dart';

/// Result of a single flow traversal step.
///
/// The node key is persisted as the next starting point, while [methods] are
/// the progression actions attached to that node.
class TraverseResult {
  /// The node key, for example "success1" or "fail2".
  final String nodeKey;

  /// The ordered list of flow methods to run at that node.
  final List<FlowMethod> methods;

  TraverseResult(this.nodeKey, this.methods);
}

/// Walks a saved automatic-preset flow graph one outcome at a time.
///
/// [FlowDefinition] stores the graph edges. [FlowMethod] stores the actions
/// attached to method nodes. The executor is intentionally pure: it decides
/// which node/methods apply, while AutoIncrementService performs database
/// updates and pointer persistence.
class FlowExecutor {
  final String _rootKey;
  final Map<String, String> _branchMap = {};
  final Map<String, List<String>> _methodMap = {};
  final Map<String, FlowMethod> _methodsByName = {};

  /// [flowDef] comes from fetchFlowDefinition(), and [methods] comes from
  /// fetchFlowMethods().
  FlowExecutor({
    required FlowDefinition flowDef,
    required List<FlowMethod> methods,
  }) : _rootKey =
           flowDef.nodes.isNotEmpty ? flowDef.nodes.first : '1st attempt' {
    for (final method in methods) {
      _methodsByName.putIfAbsent(method.name, () => method);
    }
    for (final edge in flowDef.edges) {
      if (edge.outcome == 'method') {
        _methodMap.putIfAbsent(edge.from, () => []).add(edge.to);
      } else {
        _branchMap['${edge.from}:${edge.outcome}'] = edge.to;
      }
    }
  }

  /// Walks one step from [lastNodeKey] (or root) with [outcome].
  ///
  /// Returns both the node key landed on and the methods attached there.
  TraverseResult traverse({String? lastNodeKey, required bool outcome}) {
    final start = lastNodeKey ?? _rootKey;
    final branch = outcome ? 'success' : 'failure';
    var next = _branchMap['$start:$branch'];

    if (next == null) {
      next = _branchMap['$_rootKey:$branch'];
      next ??= _rootKey;
    }

    final names = _methodMap[next] ?? [];
    final resultMethods = [
      for (final name in names)
        if (_methodsByName[name] != null) _methodsByName[name]!,
    ];

    return TraverseResult(next, resultMethods);
  }
}
