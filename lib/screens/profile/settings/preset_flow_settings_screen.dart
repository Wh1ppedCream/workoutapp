// File: lib/screens/profile/settings/preset_flow_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../../../models/preset_models.dart';
import '../../../models/gym_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/flow_screen_widgets.dart';
import '../../../theme/theme_extensions.dart';

/// same enum you use in auto_preset_flow_screen.dart
enum AddSetMode { explicit, copy }


/// Screen to view and edit any preset’s automatic flow, scoped by profile.
class PresetFlowSettingsScreen extends StatefulWidget {
  const PresetFlowSettingsScreen({super.key});

  @override
  _PresetFlowSettingsScreenState createState() =>
      _PresetFlowSettingsScreenState();
}

class _PresetFlowSettingsScreenState extends State<PresetFlowSettingsScreen> {
  final _repo = AppRepository();
  // ─── Dropdown state ───────────────────────────────────────
  List<GymProfile> _profiles = [];
  GymProfile? _selectedProfile;

  List<Map<String, dynamic>> _presetsRaw = [];
  int? _selectedPresetId;

  // ─── Flowchart state ──────────────────────────────────────
  FlowDefinition? _flowDef;
  List<FlowMethod> _methods = [];

  late Dashboard _dashboard;
  final Map<String, FlowElement> _nodes = {};
  final Map<String, _NodeData> _nodeData = {};
  final Map<int, int> _placement = {};
  List<FlowEdge> _edges = [];

  int _successCounter = 0;
  int _failureCounter = 0;

  String? _selectedBranchParent;
  String? _selectedMethodNode;
  FlowMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _loadProfiles();
    _loadDefaultFlow(scope: 'app'); // <-- show global default right away
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colors = context.colors;
    final bg = colors.flowChartBackground!;
    final grid = context.cs.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.15)
        : colors.flowChartGrid!;
    _dashboard.setGridBackgroundParams(
      GridBackgroundParams(
        backgroundColor: bg,
        gridColor: grid,
      ),
    );
  }

  Future<void> _loadProfiles() async {
    final profiles = await _repo.fetchAllProfiles();
    setState(() => _profiles = profiles);
  }

  Future<void> _loadPresets() async {
    if (_selectedProfile == null) return;
    final raw = await _repo.fetchAllPresetsRaw(profileId: _selectedProfile!.id);
    setState(() => _presetsRaw = raw);
  }

  Future<void> _loadFlowAndMethods() async {
  if (_selectedPresetId == null) return;
  final def     = await _repo.fetchFlowDefinition(_selectedPresetId!);
  final methods = await _repo.fetchFlowMethods(_selectedPresetId!);
  setState(() {
    _flowDef            = def;
    _methods            = methods;
    _edges              = def.edges.toList();        // clone so you can mutate
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();
    _selectedBranchParent = null;
    _selectedMethodNode   = null;
    _selectedMethod       = null;
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

    _successCounter = succNums.isEmpty ? 0 : succNums.reduce((a, b) => a > b ? a : b);
    _failureCounter = failNums.isEmpty ? 0 : failNums.reduce((a, b) => a > b ? a : b);
  }

  void _buildDashboard() {
    final extras = context.colors;
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _dashboard.setGridBackgroundParams(GridBackgroundParams(
      backgroundColor: extras.flowChartBackground!,
      gridColor: extras.flowChartGrid!,
    ));

    if (_flowDef == null || _flowDef!.nodes.isEmpty) {
      _nodes.clear();
      _nodeData.clear();
      _placement.clear();
      _initializeDefaultTree();
    } else {
      // BFS to compute depths
      final depths = {'1st attempt': 0};
      final queue = ['1st attempt'];
      final adj = <String, List<String>>{};
      for (var e in _edges.where((e) => e.outcome != 'method')) {
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
      final sorted = depths.keys.toList()
        ..sort((a, b) => depths[a]!.compareTo(depths[b]!));
      for (var name in sorted) {
        final depth = depths[name]!;
        final idx = (_placement[depth] ?? 0);
        _placement[depth] = idx + 1;
        final pos = Offset(60 + idx * 100, 50 + depth * 100);

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

      // draw success/failure edges
      for (var e in _edges.where((e) => e.outcome != 'method')) {
        final fromEl = _nodes[e.from]!;
        final toEl = _nodes[e.to]!;
        final isSucc = e.outcome == 'success';
        _dashboard.addNextById(
          fromEl,
          toEl.id,
          ArrowParams(
            color: isSucc ? extras.flowArrowSuccess! : extras.flowArrowFailure!,
            thickness: 2,
            style: isSucc ? ArrowStyle.segmented : ArrowStyle.curve,
            startArrowPosition: Alignment.bottomCenter,
            endArrowPosition: Alignment.topCenter,
          ),
        );
      }
    }

    // draw method attachments
    for (var node in _nodes.keys) {
      _refreshNodeText(node);
    }

    // loopbacks
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
    _nodes['1st attempt'] = root;
    _nodeData['1st attempt'] = _NodeData(depth: 0);
    _placement[0] = 1;

    final sName = 'success${++_successCounter}';
    _createBranchNode('1st attempt', sName, 'success');
    final fName = 'fail${++_failureCounter}';
    _createBranchNode('1st attempt', fName, 'failure');
  }

  void _refreshNodeText(String nodeName) {
    final methods = _edges
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

    final pos = Offset(60 + idx * 100, 50 + depth * 100);
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

    final branchColor = outcome == 'success'
        ? extras.flowArrowSuccess!
        : extras.flowArrowFailure!;
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
        color: extras.flowArrowLoopback!,
        thickness: 2,
        style: ArrowStyle.curve,
        startArrowPosition: Alignment.centerLeft,
        endArrowPosition: Alignment.centerLeft,
      ),
    );

    setState(() {});
  }

  Future<void> _saveFlow() async {
    if (_selectedPresetId == null || _flowDef == null) return;
    final def = FlowDefinition(nodes: _nodes.keys.toList(), edges: _edges);
    await _repo.upsertFlowDefinition(_selectedPresetId!, def);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flow saved')),
    );
  }

// ─── Manage Methods ───────────────────────────────────────

  Future<void> _showManageMethodsDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manage Methods'),
        content: SizedBox(
          width: 300,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var m in _methods)
                ListTile(
                  title: Text(m.name),
                  subtitle: Text(m.type.toShortString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _repo.deleteFlowMethod(m.id);
                      Navigator.of(ctx).pop();
                      _methods = await _repo.fetchFlowMethods(_selectedPresetId!);
                      setState(() {});
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
    // refresh after manage
    _methods = await _repo.fetchFlowMethods(_selectedPresetId!);
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

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('New Method'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                DropdownButton<MethodType>(
                  value: type,
                  isExpanded: true,
                  onChanged: (v) => setSt(() => type = v!),
                  items: MethodType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toShortString())))
                      .toList(),
                ),
                const SizedBox(height: 12),
                if (type == MethodType.weight) ...[
                  DropdownButton<String>(
                    value: sign,
                    onChanged: (v) => setSt(() => sign = v!),
                    items: const [
                      DropdownMenuItem(value: '+', child: Text('+')),
                      DropdownMenuItem(value: '-', child: Text('-')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: factorCtl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Factor'),
                  ),
                ] else if (type == MethodType.rep) ...[
                  DropdownButton<String>(
                    value: sign,
                    onChanged: (v) => setSt(() => sign = v!),
                    items: const [
                      DropdownMenuItem(value: '+', child: Text('+')),
                      DropdownMenuItem(value: '-', child: Text('-')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                ] else if (type == MethodType.addSet) ...[
                  Row(
                    children: [
                      Radio<AddSetMode>(
                          value: AddSetMode.explicit,
                          groupValue: addMode,
                          onChanged: (v) => setSt(() => addMode = v!)),
                      const Text('Explicit'),
                      Radio<AddSetMode>(
                          value: AddSetMode.copy,
                          groupValue: addMode,
                          onChanged: (v) => setSt(() => addMode = v!)),
                      const Text('Copy from set'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (addMode == AddSetMode.explicit)
                    TextField(
                      controller: weightCtl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight'),
                    ),
                  if (addMode == AddSetMode.explicit) const SizedBox(height: 8),
                  if (addMode == AddSetMode.explicit)
                    TextField(
                      controller: repsCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                    ),
                  if (addMode == AddSetMode.copy)
                    TextField(
                      controller: copyIndexCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Set index (-1 = last)'),
                    ),
                ] else if (type == MethodType.delSet) ...[
                  const Text('This method will delete the last set.'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    late Map<String, dynamic> params;
    switch (type) {
      case MethodType.weight:
        params = {'sign': sign, 'factor': double.tryParse(factorCtl.text) ?? 1.0};
        break;
      case MethodType.rep:
        params = {'sign': sign, 'amount': int.tryParse(amountCtl.text) ?? 0};
        break;
      case MethodType.addSet:
        params = addMode == AddSetMode.explicit
            ? {
                'weight': double.tryParse(weightCtl.text) ?? 0.0,
                'reps': int.tryParse(repsCtl.text) ?? 0
              }
            : {'copyFromSetIndex': int.tryParse(copyIndexCtl.text) ?? -1};
        break;
      case MethodType.delSet:
        params = {};
        break;
    }
      await _repo.upsertFlowMethod(
      presetId: _selectedPresetId!,
      name: nameCtl.text.trim(),
      type: type,
      params: params,
    );
    _methods = await _repo.fetchFlowMethods(_selectedPresetId!);
    setState(() {});
  }

  void _onAddSuccess() => _createBranchNode(
      _selectedBranchParent!, 'success${++_successCounter}', 'success');

  void _onAddFailure() => _createBranchNode(
      _selectedBranchParent!, 'fail${++_failureCounter}', 'failure');

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
        _edges.where((e) => e.from == target && e.outcome == 'method');
    if (methodEdges.isEmpty) return;
    _edges.remove(methodEdges.last);
    _refreshNodeText(target);
    setState(() {});
  }

  void _onRemoveNode() {
    final name = _selectedMethodNode;
    if (name == null || name == '1st attempt') return;
    final branchKids = _edges.where((e) =>
        e.from == name && (e.outcome == 'success' || e.outcome == 'failure'));
    if (branchKids.isNotEmpty) return;
    final hasMethods =
        _edges.any((e) => e.from == name && e.outcome == 'method');
    if (hasMethods) return;
    _edges.removeWhere((e) =>
        e.to == name && (e.outcome == 'success' || e.outcome == 'failure'));
    final el = _nodes.remove(name)!;
    _dashboard.removeElement(el);
    _nodeData.remove(name);
    _selectedMethodNode = null;
    _selectedMethod = null;
    setState(() {});
  }


/// scope: 'app' or 'profile'
Future<void> _loadDefaultFlow({ required String scope, int? profileId }) async {
  // your new repo methods:
  final def     = await _repo.fetchDefaultFlowDefinition(scope, profileId: profileId);
  final methods = await _repo.fetchDefaultFlowMethods(scope, profileId: profileId);

  setState(() {
    _flowDef  = def;
    _methods  = methods;
    _edges    = def.edges.toList();
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();
    _selectedBranchParent = null;
    _selectedMethodNode   = null;
    _selectedMethod       = null;
  });
  _buildDashboard();
  _initializeCounters();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preset Flow Settings'),
        actions: [
          IconButton(
              icon: const Icon(Icons.build), // wrench icon
              tooltip: 'Manage Methods',
              onPressed: _showManageMethodsDialog,
            ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveFlow),
        ],
      ),
      body: Column(
        children: [
          // Profile selector
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<GymProfile>(
              isExpanded: true,
              hint: const Text('Select Profile'),
              value: _selectedProfile,
              items: _profiles
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (p) {
                setState(() {
                  _selectedProfile = p;
                  _selectedPresetId = null;
                  _presetsRaw = [];
                  _flowDef = null;
                  _methods = [];
                });
                _loadPresets();
                // load the profile‐scoped default flow
     _loadDefaultFlow(scope: 'profile', profileId: p?.id);
              },
            ),
          ),

          // Preset selector
          if (_selectedProfile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Select Preset'),
                value: _selectedPresetId,
                items: _presetsRaw
                    .map((r) => DropdownMenuItem(
                          value: r['id'] as int,
                          child: Text(r['name'] as String),
                        ))
                    .toList(),
                onChanged: (pid) {
                  setState(() => _selectedPresetId = pid);
                  if (pid == null) {
       // no specific preset chosen → show that profile’s default
       _loadDefaultFlow(scope: 'profile', profileId: _selectedProfile!.id);
     } else {
       // a real preset → show that preset’s own flow
       _loadFlowAndMethods();
     }
                },
              ),
            ),

          // Flow editor
          if (_flowDef != null)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        BranchControls(
                          branchable: _nodes.keys
                              .where((n) =>
                                  (_edges.where((e) =>
                                              (e.from == n &&
                                               (e.outcome == 'success' ||
                                                e.outcome == 'failure')))
                                          .length) <
                                  2)
                              .toList(),
                          selectedParent: _selectedBranchParent,
                          onParentChanged: (v) =>
                              setState(() => _selectedBranchParent = v),
                          onAddSuccess: _onAddSuccess,
                          onAddFailure: _onAddFailure,
                          existingSuccess: _edges
                              .where((e) =>
                                  e.from == _selectedBranchParent &&
                                  e.outcome == 'success')
                              .length,
                          existingFailure: _edges
                              .where((e) =>
                                  e.from == _selectedBranchParent &&
                                  e.outcome == 'failure')
                              .length,
                        ),
                        MethodControls(
                          methodTargets: _nodes.keys.toList(),
                          selectedNode: _selectedMethodNode,
                          onNodeChanged: (v) =>
                              setState(() {
                                _selectedMethodNode = v;
                                _selectedMethod = null;
                              }),
                          availableMethods: _methods,
                          selectedMethod: _selectedMethod,
                          onMethodChanged: (m) =>
                              setState(() => _selectedMethod = m),
                          canAdd: _selectedMethodNode != null &&
                              _selectedMethod != null &&
                              !_edges.any((e) =>
                                  e.from == _selectedMethodNode &&
                                  e.outcome == 'method' &&
                                  e.to == _selectedMethod!.name),
                          onAddMethod: _onAddMethod,
                          hasMethods: _edges.any((e) =>
                              e.from == _selectedMethodNode &&
                              e.outcome == 'method'),
                          onRemoveMethod: _onRemoveMethod,
                          canDeleteNode: _selectedMethodNode != null &&
                              _selectedMethodNode != '1st attempt' &&
                              !_edges.any((e) =>
                                  e.from == _selectedMethodNode! &&
                                  (e.outcome == 'success' ||
                                   e.outcome == 'failure')) &&
                              !_edges.any((e) =>
                                  e.from == _selectedMethodNode! &&
                                  e.outcome == 'method'),
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
