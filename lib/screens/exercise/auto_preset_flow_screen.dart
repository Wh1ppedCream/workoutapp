// File: lib/screens/exercise/auto_preset_flow_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../../models/preset_models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/flow_screen_widgets.dart';

import '../../theme/theme_extensions.dart';

enum AddSetMode { explicit, copy }

/// Screen to edit the automatic‐preset flowchart for a given preset.
class AutoPresetFlowScreen extends StatefulWidget {
  final int presetId;
  const AutoPresetFlowScreen({super.key, required this.presetId});

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
    final definitionFuture = _repo.fetchFlowDefinition(widget.presetId);
    final methodsFuture = _repo.fetchFlowMethods(widget.presetId);
    final def = await definitionFuture;
    final methods = await methodsFuture;
    if (!mounted) return;
    setState(() {
      _flowDef = def;
      _methods = methods;
      _edges = def.edges;
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

    if (_flowDef == null || _flowDef!.nodes.isEmpty) {
      _initializeDefaultTree();
    } else {
      // BFS to compute depths
      final depths = {'1st attempt': 0};
      final queue = ['1st attempt'];
      final adj = <String, List<String>>{};
      for (var e in _flowDef!.edges.where((e) => e.outcome != 'method')) {
        adj.putIfAbsent(e.from, () => []).add(e.to);
      }
      while (queue.isNotEmpty) {
        final cur = queue.removeAt(0);
        final d = depths[cur]!;
        for (var nb in adj[cur] ?? []) {
          if (!depths.containsKey(nb)) {
            depths[nb] = d + 1;
            queue.add(nb);
          }
        }
      }

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
        final fromEl = _nodes[e.from]!;
        final toEl = _nodes[e.to]!;
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

    if (_flowDef != null && _flowDef!.nodes.isNotEmpty) {
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
    final rootEl = _nodes['1st attempt']!;
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
                          await _repo.deleteFlowMethod(m.id);
                          if (!mounted) return;
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
    _methods = await _repo.fetchFlowMethods(widget.presetId);
    if (!mounted) return;
    setState(() {});
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

    try {
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
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
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
                                  onChanged:
                                      (v) => setState(() => addMode = v!),
                                ),
                                const Text('Explicit'),
                                Radio<AddSetMode>(
                                  value: AddSetMode.copy,
                                  groupValue: addMode,
                                  onChanged:
                                      (v) => setState(() => addMode = v!),
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
      if (saved != true) return;

      Map<String, dynamic> params;
      switch (type) {
        case MethodType.weight:
          params = {
            'sign': sign,
            'factor': double.tryParse(factorCtl.text) ?? 1.0,
          };
          break;
        case MethodType.rep:
          params = {'sign': sign, 'amount': int.tryParse(amountCtl.text) ?? 0};
          break;
        case MethodType.addSet:
          params =
              addMode == AddSetMode.explicit
                  ? {
                    'weight': double.tryParse(weightCtl.text) ?? 0.0,
                    'reps': int.tryParse(repsCtl.text) ?? 0,
                  }
                  : {'copyFromSetIndex': int.tryParse(copyIndexCtl.text) ?? -1};
          break;
        case MethodType.delSet:
          params = {};
          break;
      }

      await _repo.upsertFlowMethod(
        presetId: widget.presetId,
        name: nameCtl.text.trim(),
        type: type,
        params: params,
      );
      _methods = await _repo.fetchFlowMethods(widget.presetId);
      if (!mounted) return;
      setState(() {});
    } finally {
      nameCtl.dispose();
      factorCtl.dispose();
      amountCtl.dispose();
      weightCtl.dispose();
      repsCtl.dispose();
      copyIndexCtl.dispose();
    }
  }

  Future<void> _saveFlow() async {
    final def = FlowDefinition(nodes: _nodes.keys.toList(), edges: _edges);
    await _repo.upsertFlowDefinition(widget.presetId, def);
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
      appBar: AppBar(
        title: const Text('Edit Auto-Preset Flow'),
        backgroundColor: cs.surface,
        iconTheme: IconThemeData(color: cs.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            color: cs.primary,
            tooltip: 'Manage Methods',
            onPressed: _showManageMethodsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            color: cs.primary,
            tooltip: 'Save Flow',
            onPressed: _saveFlow,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                BranchControls(
                  branchable: branchable,
                  selectedParent: _selectedBranchParent,
                  onParentChanged:
                      (v) => setState(() => _selectedBranchParent = v),
                  onAddSuccess: _onAddSuccess,
                  onAddFailure: _onAddFailure,
                  existingSuccess: existingSuccess,
                  existingFailure: existingFailure,
                ),
                MethodControls(
                  methodTargets: methodTargets,
                  selectedNode: _selectedMethodNode,
                  onNodeChanged: (v) {
                    setState(() {
                      _selectedMethodNode = v;
                      _selectedMethod = null;
                    });
                  },
                  availableMethods: availableMethods,
                  selectedMethod: _selectedMethod,
                  onMethodChanged: (m) => setState(() => _selectedMethod = m),
                  canAdd: canAdd,
                  onAddMethod: _onAddMethod,
                  hasMethods: attachedMethods.isNotEmpty,
                  onRemoveMethod: _onRemoveMethod,
                  canDeleteNode: canDeleteNode,
                  onRemoveNode: _onRemoveNode,
                ),
              ],
            ),
          ),

          Expanded(
            child: FlowChartCanvas(
              dashboard: _dashboard,
              onTap: (_, __) {},
              onElementPressed: (_, __, ___) {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal data for positioning
class _NodeData {
  final int depth;
  _NodeData({required this.depth});
}
