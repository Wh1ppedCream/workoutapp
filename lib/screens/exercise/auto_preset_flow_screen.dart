// File: lib/screens/exercise/auto_preset_flow_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../../models/preset_models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/flow_screen_widgets.dart';

import '../../theme/theme_extensions.dart';

enum AddSetMode { explicit, copy }

/// The persisted location for a progression flow and its reusable actions.
enum FlowProgressionScope { plan, appDefault, profileDefault }

/// Lets the same progression editor work with a plan, app defaults, or a
/// gym-profile default without duplicating the graph editing experience.
class FlowProgressionTarget {
  final FlowProgressionScope scope;
  final int? presetId;
  final int? profileId;
  final String? profileName;

  const FlowProgressionTarget._({
    required this.scope,
    this.presetId,
    this.profileId,
    this.profileName,
  });

  FlowProgressionTarget.plan({required int presetId})
    : this._(scope: FlowProgressionScope.plan, presetId: presetId);

  const FlowProgressionTarget.appDefaults()
    : this._(scope: FlowProgressionScope.appDefault);

  FlowProgressionTarget.profileDefaults({
    required int profileId,
    required String profileName,
  }) : this._(
         scope: FlowProgressionScope.profileDefault,
         profileId: profileId,
         profileName: profileName,
       );

  String get title => switch (scope) {
    FlowProgressionScope.plan => 'Plan Progression',
    FlowProgressionScope.appDefault => 'App Default Progression',
    FlowProgressionScope.profileDefault => 'Gym Default Progression',
  };

  String get subtitle => switch (scope) {
    FlowProgressionScope.plan =>
      'Set how this plan progresses after each workout.',
    FlowProgressionScope.appDefault =>
      'Set the starting progression flow for new gym profiles.',
    FlowProgressionScope.profileDefault =>
      'Set the starting progression flow for new plans in ${profileName ?? 'this gym profile'}.',
  };

  Future<FlowDefinition> fetchDefinition(AppRepository repository) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.fetchFlowDefinition(presetId!),
      FlowProgressionScope.appDefault => repository.fetchDefaultFlowDefinition(
        'app',
      ),
      FlowProgressionScope.profileDefault => repository
          .fetchDefaultFlowDefinition('profile', profileId: profileId),
    };
  }

  Future<List<FlowMethod>> fetchMethods(AppRepository repository) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.fetchFlowMethods(presetId!),
      FlowProgressionScope.appDefault => repository.fetchDefaultFlowMethods(
        'app',
      ),
      FlowProgressionScope.profileDefault => repository.fetchDefaultFlowMethods(
        'profile',
        profileId: profileId,
      ),
    };
  }

  Future<void> saveDefinition(
    AppRepository repository,
    FlowDefinition definition,
  ) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.upsertFlowDefinition(
        presetId!,
        definition,
      ),
      FlowProgressionScope.appDefault => repository.upsertDefaultFlow(
        'app',
        flowJson: definition.toJson(),
      ),
      FlowProgressionScope.profileDefault => repository.upsertDefaultFlow(
        'profile',
        profileId: profileId,
        flowJson: definition.toJson(),
      ),
    };
  }

  Future<FlowMethod> addMethod(
    AppRepository repository, {
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.upsertFlowMethod(
        presetId: presetId!,
        name: name,
        type: type,
        params: params,
      ),
      FlowProgressionScope.appDefault => repository.upsertDefaultFlowMethod(
        scope: 'app',
        name: name,
        type: type,
        params: params,
      ),
      FlowProgressionScope.profileDefault => repository.upsertDefaultFlowMethod(
        scope: 'profile',
        profileId: profileId,
        name: name,
        type: type,
        params: params,
      ),
    };
  }

  Future<void> deleteMethod(AppRepository repository, FlowMethod method) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.deleteFlowMethodAndReferences(
        method,
      ),
      FlowProgressionScope.appDefault => repository
          .deleteDefaultFlowMethodAndReferences(
            scope: 'app',
            name: method.name,
          ),
      FlowProgressionScope.profileDefault => repository
          .deleteDefaultFlowMethodAndReferences(
            scope: 'profile',
            profileId: profileId,
            name: method.name,
          ),
    };
  }
}

/// Screen to edit the automatic‐preset flowchart for a given preset.
class AutoPresetFlowScreen extends StatefulWidget {
  final FlowProgressionTarget target;

  AutoPresetFlowScreen({super.key, required int presetId})
    : target = FlowProgressionTarget.plan(presetId: presetId);

  const AutoPresetFlowScreen.appDefaults({super.key})
    : target = const FlowProgressionTarget.appDefaults();

  AutoPresetFlowScreen.profileDefaults({
    super.key,
    required int profileId,
    required String profileName,
  }) : target = FlowProgressionTarget.profileDefaults(
         profileId: profileId,
         profileName: profileName,
       );

  @override
  State<AutoPresetFlowScreen> createState() => _AutoPresetFlowScreenState();
}

class _AutoPresetFlowScreenState extends State<AutoPresetFlowScreen> {
  final _repo = AppRepository();

  late Dashboard _dashboard;
  final Map<String, FlowElement> _nodes = {};
  final Map<String, _NodeData> _nodeData = {};
  final Map<int, int> _placement = {}; // depth → count in that row

  int _successCounter = 0;
  int _failureCounter = 0;

  List<FlowEdge> _edges = [];
  FlowDefinition? _flowDef;
  List<FlowMethod> _methods = [];

  FlowMethod? _selectedMethod;
  String? _selectedBranchParent;
  String? _selectedMethodNode;

  static const double _hSpacing = 100;
  static const double _vSpacing = 100;
  static const Offset _baseOffset = Offset(60, 50);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colors = context.colors;
    final cs = context.cs;

    final bg = colors.flowChartBackground!;
    final grid =
        cs.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.15) // light grid in dark mode
            : colors.flowChartGrid!; // theme default in light mode

    _dashboard.setGridBackgroundParams(
      GridBackgroundParams(backgroundColor: bg, gridColor: grid),
    );
  }

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _loadAll();
  }

  Future<void> _loadAll() async {
    final definitionFuture = widget.target.fetchDefinition(_repo);
    final methodsFuture = widget.target.fetchMethods(_repo);
    final def = await definitionFuture;
    final methods = await methodsFuture;
    if (!mounted) return;
    setState(() {
      _flowDef = def;
      _methods = methods;
      _edges = def.edges.toList();
      _selectedMethod = null;
      _selectedBranchParent = null;
      _selectedMethodNode = null;
      _successCounter = 0;
      _failureCounter = 0;
    });
    _buildDashboard();
    _initializeCounters();
  }

  void _initializeCounters() {
    final succRe = RegExp(r'^success(\d+)$');
    final failRe = RegExp(r'^fail(\d+)$');
    final succNums = <int>[];
    final failNums = <int>[];

    for (final name in _nodes.keys) {
      final ms = succRe.firstMatch(name);
      if (ms != null) succNums.add(int.tryParse(ms.group(1)!) ?? 0);
      final mf = failRe.firstMatch(name);
      if (mf != null) failNums.add(int.tryParse(mf.group(1)!) ?? 0);
    }

    _successCounter = succNums.isEmpty ? 0 : succNums.reduce(max);
    _failureCounter = failNums.isEmpty ? 0 : failNums.reduce(max);
  }

  void _buildDashboard() {
    final extras = context.colors;

    // 1) Create dashboard
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);

    // 2) Re-set your grid colors on the fresh dashboard
    final colors = context.colors;
    _dashboard.setGridBackgroundParams(
      GridBackgroundParams(
        backgroundColor: colors.flowChartBackground!,
        gridColor: colors.flowChartGrid!,
      ),
    );
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();

    final savedNodes = _flowDef?.nodes.toSet() ?? const <String>{};
    if (!savedNodes.contains('1st attempt')) {
      // Recover safely from an empty or malformed legacy definition.
      _edges = [];
      _initializeDefaultTree();
    } else {
      _edges =
          _edges.where((edge) {
            if (edge.outcome == 'method') {
              return savedNodes.contains(edge.from);
            }
            return (edge.outcome == 'success' || edge.outcome == 'failure') &&
                savedNodes.contains(edge.from) &&
                savedNodes.contains(edge.to);
          }).toList();

      // BFS to compute depths
      final depths = {'1st attempt': 0};
      final queue = ['1st attempt'];
      var queueIndex = 0;
      final adj = <String, List<String>>{};
      for (final e in _edges.where((e) => e.outcome != 'method')) {
        adj.putIfAbsent(e.from, () => []).add(e.to);
      }
      while (queueIndex < queue.length) {
        final cur = queue[queueIndex++];
        final d = depths[cur]!;
        for (var nb in adj[cur] ?? []) {
          if (!depths.containsKey(nb)) {
            depths[nb] = d + 1;
            queue.add(nb);
          }
        }
      }

      final reachableNodes = depths.keys.toSet();
      _edges =
          _edges.where((edge) {
            if (!reachableNodes.contains(edge.from)) return false;
            return edge.outcome == 'method' || reachableNodes.contains(edge.to);
          }).toList();

      // create nodes
      final sorted =
          depths.keys.toList()
            ..sort((a, b) => depths[a]!.compareTo(depths[b]!));
      for (var name in sorted) {
        final depth = depths[name]!;
        final idx = (_placement[depth] ?? 0);
        _placement[depth] = idx + 1;
        final pos = _baseOffset + Offset(idx * _hSpacing, depth * _vSpacing);

        final el = FlowElement(
          position: pos,
          size: const Size(60, 30),
          text: name,
          backgroundColor: extras.flowNodeBg!,
          borderColor: extras.flowNodeBorder!,
          textColor: extras.flowNodeText!,
          textSize: 7,
          kind: ElementKind.rectangle,
          handlers: const [
            Handler.bottomCenter,
            Handler.topCenter,
            Handler.leftCenter,
            Handler.rightCenter,
          ],
        );
        _dashboard.addElement(el);
        _nodes[name] = el;
        _nodeData[name] = _NodeData(depth: depth);
      }

      // branch edges
      for (var e in _edges.where((e) => e.outcome != 'method')) {
        final fromEl = _nodes[e.from];
        final toEl = _nodes[e.to];
        if (fromEl == null || toEl == null) continue;
        final isSucc = e.outcome == 'success';

        // grab your colors once per loop

        _dashboard.addNextById(
          fromEl,
          toEl.id,
          ArrowParams(
            color:
                isSucc
                    ? extras.flowArrowSuccess! // ← use your success arrow color
                    : extras
                        .flowArrowFailure!, // ← use your failure arrow color
            thickness: 2,
            style: isSucc ? ArrowStyle.segmented : ArrowStyle.curve,
            startArrowPosition: Alignment.bottomCenter,
            endArrowPosition: Alignment.topCenter,
          ),
        );
      }
    }

    // method bullets
    for (var node in _nodes.keys) {
      _refreshNodeText(node);
    }

    if (_nodes.containsKey('1st attempt')) {
      _applyLoopbacks();
    }
  }

  void _initializeDefaultTree() {
    final extras = context.colors;
    final root = FlowElement(
      position: const Offset(60, 50),
      size: const Size(60, 30),
      text: '1st attempt',
      backgroundColor: extras.flowNodeBg!,
      borderColor: extras.flowNodeBorder!,
      textColor: extras.flowNodeText!,
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: const [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = _NodeData(depth: 0);
    _placement[0] = 1;

    final sName = 'success${++_successCounter}';
    _createBranchNode('1st attempt', sName, 'success');
    final fName = 'fail${++_failureCounter}';
    _createBranchNode('1st attempt', fName, 'failure');
  }

  // ─── Helper methods ───────────────────────────────────────

  void _refreshNodeText(String nodeName) {
    final methods =
        _edges
            .where((e) => e.from == nodeName && e.outcome == 'method')
            .map((e) => e.to)
            .toList();

    final el = _nodes[nodeName]!;
    el.setText([nodeName, ...methods].join('\n'));

    final newHeight = 30.0 + methods.length * 16.0;
    el.changeSize(Size(el.size.width, newHeight));
  }

  void _applyLoopbacks() {
    final extras = context.colors;
    final rootEl = _nodes['1st attempt'];
    if (rootEl == null) return;
    final hasSucc = <String, bool>{};
    final hasFail = <String, bool>{};
    for (var e in _edges) {
      if (e.outcome == 'success') hasSucc[e.from] = true;
      if (e.outcome == 'failure') hasFail[e.from] = true;
    }
    for (var name in _nodes.keys) {
      if (name == '1st attempt') continue;
      final fromEl = _nodes[name]!;
      if (hasSucc[name] != true) {
        _dashboard.addNextById(
          fromEl,
          rootEl.id,
          ArrowParams(
            color: extras.flowArrowLoopback!,
            thickness: 2,
            style: ArrowStyle.curve,
            startArrowPosition: Alignment.centerLeft,
            endArrowPosition: Alignment.centerLeft,
          ),
        );
      }
      if (hasFail[name] != true) {
        _dashboard.addNextById(
          fromEl,
          rootEl.id,
          ArrowParams(
            color: extras.flowArrowLoopback!,
            thickness: 2,
            style: ArrowStyle.curve,
            startArrowPosition: Alignment.centerLeft,
            endArrowPosition: Alignment.centerLeft,
          ),
        );
      }
    }
  }

  void _createBranchNode(String parent, String name, String outcome) {
    final extras = context.colors;
    final pData = _nodeData[parent]!;
    final depth = pData.depth + 1;
    final idx = (_placement[depth] ?? 0);
    _placement[depth] = idx + 1;

    final pos = Offset(60 + idx * _hSpacing, 50 + depth * _vSpacing);
    final el = FlowElement(
      position: pos,
      size: const Size(60, 30),
      text: name,
      backgroundColor: extras.flowNodeBg!,
      borderColor: extras.flowNodeBorder!,
      textColor: extras.flowNodeText!,
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: const [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    _dashboard.addElement(el);
    _nodes[name] = el;
    _nodeData[name] = _NodeData(depth: depth);

    final branchColor =
        outcome == 'success'
            ? context.colors.flowArrowSuccess!
            : context.colors.flowArrowFailure!;
    final branchStyle =
        outcome == 'success' ? ArrowStyle.segmented : ArrowStyle.curve;
    _dashboard.addNextById(
      _nodes[parent]!,
      el.id,
      ArrowParams(
        color: branchColor,
        thickness: 2,
        style: branchStyle,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );

    _edges.add(FlowEdge(from: parent, outcome: outcome, to: name));

    // loopback
    final rootEl = _nodes['1st attempt']!;
    _dashboard.addNextById(
      el,
      rootEl.id,
      ArrowParams(
        color: context.colors.flowArrowLoopback!,
        thickness: 2,
        style: ArrowStyle.curve,
        startArrowPosition: Alignment.centerLeft,
        endArrowPosition: Alignment.centerLeft,
      ),
    );

    if (_edges.any((e) => e.from == parent && e.outcome == 'success') &&
        _edges.any((e) => e.from == parent && e.outcome == 'failure')) {
      _dashboard.removeElementConnection(_nodes[parent]!, Handler.leftCenter);
    }

    setState(() {});
  }

  Future<void> _showManageMethodsDialog() async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Manage Methods'),
            content: SizedBox(
              width: 300,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var m in _methods)
                    ListTile(
                      title: Text(
                        m.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        m.type.toShortString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final navigator = Navigator.of(ctx);
                          await widget.target.deleteMethod(_repo, m);
                          if (!ctx.mounted || !mounted) return;
                          navigator.pop();
                        },
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add New Method…'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showAddMethodDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
    if (!mounted) return;
    await _loadAll();
  }

  Future<void> _showAddMethodDialog() async {
    final nameCtl = TextEditingController();
    MethodType type = MethodType.weight;
    String sign = '+';
    final factorCtl = TextEditingController(text: '1.0');
    final amountCtl = TextEditingController(text: '0');
    AddSetMode addMode = AddSetMode.explicit;
    final weightCtl = TextEditingController(text: '0.0');
    final repsCtl = TextEditingController(text: '0');
    final copyIndexCtl = TextEditingController(text: '-1');

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: const Text('New Method'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nameCtl,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<MethodType>(
                          value: type,
                          isExpanded: true,
                          onChanged: (v) => setState(() => type = v!),
                          items:
                              MethodType.values
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.toShortString()),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                        if (type == MethodType.weight) ...[
                          DropdownButton<String>(
                            value: sign,
                            onChanged: (v) => setState(() => sign = v!),
                            items: const [
                              DropdownMenuItem(value: '+', child: Text('+')),
                              DropdownMenuItem(value: '-', child: Text('-')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: factorCtl,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Factor',
                            ),
                          ),
                        ] else if (type == MethodType.rep) ...[
                          DropdownButton<String>(
                            value: sign,
                            onChanged: (v) => setState(() => sign = v!),
                            items: const [
                              DropdownMenuItem(value: '+', child: Text('+')),
                              DropdownMenuItem(value: '-', child: Text('-')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountCtl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ] else if (type == MethodType.addSet) ...[
                          Row(
                            children: [
                              Radio<AddSetMode>(
                                value: AddSetMode.explicit,
                                groupValue: addMode,
                                onChanged: (v) => setState(() => addMode = v!),
                              ),
                              const Text('Explicit'),
                              Radio<AddSetMode>(
                                value: AddSetMode.copy,
                                groupValue: addMode,
                                onChanged: (v) => setState(() => addMode = v!),
                              ),
                              const Text('Copy from set'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (addMode == AddSetMode.explicit)
                            TextField(
                              controller: weightCtl,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                              ),
                            ),
                          if (addMode == AddSetMode.explicit)
                            const SizedBox(height: 8),
                          if (addMode == AddSetMode.explicit)
                            TextField(
                              controller: repsCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                              ),
                            ),
                          if (addMode == AddSetMode.copy)
                            TextField(
                              controller: copyIndexCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Set index (-1 = last)',
                              ),
                            ),
                        ] else if (type == MethodType.delSet) ...[
                          const Text('This method will delete the last set.'),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );

    final methodName = nameCtl.text.trim();
    final factor = double.tryParse(factorCtl.text) ?? 1.0;
    final amount = int.tryParse(amountCtl.text) ?? 0;
    final weight = double.tryParse(weightCtl.text) ?? 0.0;
    final reps = int.tryParse(repsCtl.text) ?? 0;
    final copyIndex = int.tryParse(copyIndexCtl.text) ?? -1;
    for (final controller in [
      nameCtl,
      factorCtl,
      amountCtl,
      weightCtl,
      repsCtl,
      copyIndexCtl,
    ]) {
      controller.dispose();
    }

    if (saved != true || !mounted) return;

    Map<String, dynamic> params;
    switch (type) {
      case MethodType.weight:
        params = {'sign': sign, 'factor': factor};
        break;
      case MethodType.rep:
        params = {'sign': sign, 'amount': amount};
        break;
      case MethodType.addSet:
        params =
            addMode == AddSetMode.explicit
                ? {'weight': weight, 'reps': reps}
                : {'copyFromSetIndex': copyIndex};
        break;
      case MethodType.delSet:
        params = {};
        break;
    }

    if (methodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Method name cannot be empty')),
      );
      return;
    }

    await widget.target.addMethod(
      _repo,
      name: methodName,
      type: type,
      params: params,
    );
    final methods = await widget.target.fetchMethods(_repo);
    if (!mounted) return;
    _methods = methods;
    setState(() {});
  }

  Future<void> _saveFlow() async {
    final def = FlowDefinition(nodes: _nodes.keys.toList(), edges: _edges);
    await widget.target.saveDefinition(_repo, def);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _onAddSuccess() {
    final parent = _selectedBranchParent;
    if (parent == null) return;
    final name = 'success${++_successCounter}';
    _createBranchNode(parent, name, 'success');
  }

  void _onAddFailure() {
    final parent = _selectedBranchParent;
    if (parent == null) return;
    final name = 'fail${++_failureCounter}';
    _createBranchNode(parent, name, 'failure');
  }

  void _onAddMethod() {
    final target = _selectedMethodNode;
    final method = _selectedMethod;
    if (target == null || method == null) return;
    _edges.add(FlowEdge(from: target, outcome: 'method', to: method.name));
    _refreshNodeText(target);
    setState(() {});
  }

  void _onRemoveMethod() {
    final target = _selectedMethodNode;
    if (target == null) return;
    final methodEdges =
        _edges.where((e) => e.from == target && e.outcome == 'method').toList();
    if (methodEdges.isEmpty) return;
    _edges.remove(methodEdges.last);
    _refreshNodeText(target);
    setState(() {});
  }

  void _onRemoveNode() {
    final name = _selectedMethodNode;
    if (name == null || name == '1st attempt') return;
    final branchKids = _edges.where(
      (e) =>
          e.from == name && (e.outcome == 'success' || e.outcome == 'failure'),
    );
    if (branchKids.isNotEmpty) return;
    final hasMethods = _edges.any(
      (e) => e.from == name && e.outcome == 'method',
    );
    if (hasMethods) return;
    _edges.removeWhere(
      (e) => e.to == name && (e.outcome == 'success' || e.outcome == 'failure'),
    );
    final el = _nodes.remove(name)!;
    _dashboard.removeElement(el);
    _nodeData.remove(name);
    _selectedMethodNode = null;
    _selectedMethod = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //for colors
    final cs = context.cs;

    // branchable nodes
    final outCounts = <String, int>{};
    for (var e in _edges.where(
      (e) => e.outcome == 'success' || e.outcome == 'failure',
    )) {
      outCounts[e.from] = (outCounts[e.from] ?? 0) + 1;
    }
    final branchable =
        _nodes.keys.where((n) => (outCounts[n] ?? 0) < 2).toList();

    final existingSuccess =
        _edges
            .where(
              (e) => e.from == _selectedBranchParent && e.outcome == 'success',
            )
            .length;
    final existingFailure =
        _edges
            .where(
              (e) => e.from == _selectedBranchParent && e.outcome == 'failure',
            )
            .length;

    final methodTargets = _nodes.keys.where((n) => n != '1st attempt').toList();
    final attachedMethods =
        _edges
            .where(
              (e) => e.from == _selectedMethodNode && e.outcome == 'method',
            )
            .map((e) => e.to)
            .toList();
    final attachedTypes =
        attachedMethods
            .map<MethodType?>((name) {
              final m = _methods.where((m) => m.name == name);
              return m.isEmpty ? null : m.first.type;
            })
            .whereType<MethodType>()
            .toSet();
    final availableMethods =
        _methods.where((m) => !attachedTypes.contains(m.type)).toList();
    final canAdd =
        _selectedMethodNode != null &&
        _selectedMethod != null &&
        availableMethods.contains(_selectedMethod);
    final canDeleteNode =
        !(_selectedMethodNode == null ||
            _selectedMethodNode == '1st attempt' ||
            _edges.any(
              (e) =>
                  e.from == _selectedMethodNode! &&
                  (e.outcome == 'success' || e.outcome == 'failure'),
            ) ||
            attachedMethods.isNotEmpty);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _AutoFlowHeader(
              title: widget.target.title,
              subtitle: widget.target.subtitle,
              onBack: () => Navigator.maybePop(context),
              onManageMethods: _showManageMethodsDialog,
              onSave: _saveFlow,
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _FlowControlDeck(
                      branchable: branchable,
                      selectedBranchParent: _selectedBranchParent,
                      onBranchParentChanged:
                          (value) =>
                              setState(() => _selectedBranchParent = value),
                      onAddSuccess: _onAddSuccess,
                      onAddFailure: _onAddFailure,
                      existingSuccess: existingSuccess,
                      existingFailure: existingFailure,
                      methodTargets: methodTargets,
                      selectedMethodNode: _selectedMethodNode,
                      onMethodNodeChanged: (value) {
                        setState(() {
                          _selectedMethodNode = value;
                          _selectedMethod = null;
                        });
                      },
                      availableMethods: availableMethods,
                      selectedMethod: _selectedMethod,
                      onMethodChanged:
                          (method) => setState(() => _selectedMethod = method),
                      canAddMethod: canAdd,
                      onAddMethod: _onAddMethod,
                      hasAttachedMethods: attachedMethods.isNotEmpty,
                      onRemoveMethod: _onRemoveMethod,
                      canDeleteNode: canDeleteNode,
                      onRemoveNode: _onRemoveNode,
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: FlowChartCanvas(
                        dashboard: _dashboard,
                        onTap: (_, __) {},
                        onElementPressed: (_, __, ___) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal data for positioning
class _NodeData {
  final int depth;
  _NodeData({required this.depth});
}

class _AutoFlowHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onManageMethods;
  final VoidCallback onSave;

  const _AutoFlowHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onManageMethods,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 27,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Manage progression actions',
            onPressed: onManageMethods,
            icon: const Icon(Icons.tune_outlined),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _FlowControlDeck extends StatelessWidget {
  final List<String> branchable;
  final String? selectedBranchParent;
  final ValueChanged<String?> onBranchParentChanged;
  final VoidCallback onAddSuccess;
  final VoidCallback onAddFailure;
  final int existingSuccess;
  final int existingFailure;
  final List<String> methodTargets;
  final String? selectedMethodNode;
  final ValueChanged<String?> onMethodNodeChanged;
  final List<FlowMethod> availableMethods;
  final FlowMethod? selectedMethod;
  final ValueChanged<FlowMethod?> onMethodChanged;
  final bool canAddMethod;
  final VoidCallback onAddMethod;
  final bool hasAttachedMethods;
  final VoidCallback onRemoveMethod;
  final bool canDeleteNode;
  final VoidCallback onRemoveNode;

  const _FlowControlDeck({
    required this.branchable,
    required this.selectedBranchParent,
    required this.onBranchParentChanged,
    required this.onAddSuccess,
    required this.onAddFailure,
    required this.existingSuccess,
    required this.existingFailure,
    required this.methodTargets,
    required this.selectedMethodNode,
    required this.onMethodNodeChanged,
    required this.availableMethods,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.canAddMethod,
    required this.onAddMethod,
    required this.hasAttachedMethods,
    required this.onRemoveMethod,
    required this.canDeleteNode,
    required this.onRemoveNode,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final success = context.colors.flowArrowSuccess ?? const Color(0xFF66BB6A);
    final failure = context.colors.flowArrowFailure ?? scheme.error;

    return Column(
      children: [
        _FlowControlCard(
          color: success,
          icon: Icons.account_tree_outlined,
          title: 'Add a branch',
          subtitle: 'Choose where the next success or miss should lead.',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value:
                    branchable.contains(selectedBranchParent)
                        ? selectedBranchParent
                        : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Branch from',
                  prefixIcon: Icon(Icons.account_tree_outlined),
                ),
                items:
                    branchable
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                onChanged: onBranchParentChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: success,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          selectedBranchParent == null || existingSuccess >= 1
                              ? null
                              : onAddSuccess,
                      icon: const Icon(Icons.trending_up, size: 18),
                      label: const Text('Success'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: failure,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          selectedBranchParent == null || existingFailure >= 1
                              ? null
                              : onAddFailure,
                      icon: const Icon(Icons.trending_down, size: 18),
                      label: const Text('Miss'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _FlowControlCard(
          color: scheme.primary,
          icon: Icons.tune_outlined,
          title: 'Attach a progression action',
          subtitle: 'Apply one adjustment of each type to a flow node.',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value:
                    methodTargets.contains(selectedMethodNode)
                        ? selectedMethodNode
                        : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Apply action to',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items:
                    methodTargets
                        .map(
                          (name) =>
                              DropdownMenuItem(value: name, child: Text(name)),
                        )
                        .toList(),
                onChanged: onMethodNodeChanged,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<FlowMethod>(
                value:
                    availableMethods.contains(selectedMethod)
                        ? selectedMethod
                        : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Progression action',
                  prefixIcon: Icon(Icons.bolt_outlined),
                ),
                items:
                    availableMethods
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              method.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onMethodChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      onPressed: canAddMethod ? onAddMethod : null,
                      child: const Text('+ Action'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      onPressed: hasAttachedMethods ? onRemoveMethod : null,
                      child: const Text('- Action'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        foregroundColor: scheme.error,
                        side: BorderSide(
                          color: scheme.error.withValues(alpha: .6),
                        ),
                      ),
                      onPressed: canDeleteNode ? onRemoveNode : null,
                      child: const Text('- Node'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowControlCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _FlowControlCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .46)),
      ),
      child: ExpansionTile(
        key: PageStorageKey(title),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        collapsedBackgroundColor: color.withValues(alpha: .05),
        backgroundColor: color.withValues(alpha: .04),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: [child],
      ),
    );
  }
}
