// File: lib/screens/auto_preset_flow_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import '../models/preset_models.dart';
import '../repositories/app_repository.dart';

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


List<FlowEdge> _edges = [];
  FlowDefinition? _flowDef;
  List<FlowMethod> _methods = [];

  String? _selectedParent;
  String _selectedOutcome = 'success';
  FlowMethod? _selectedMethod;
  bool _isLoading = true;

  // Spacing constants
  static const double _hSpacing = 100;
  static const double _vSpacing = 100;
  static const Offset _baseOffset = Offset(60, 50);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
  final def = await _repo.fetchFlowDefinition(widget.presetId);
  final methods = await _repo.fetchFlowMethods(widget.presetId);
  setState(() {
    _flowDef = def;
    _methods = methods;
    _edges = def.edges;       // ✦ track the existing edges
  });
  _buildDashboard();
  setState(() => _isLoading = false);
}

  void _buildDashboard() {
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();

    // If no nodes defined, fall back to default tree.
    if (_flowDef == null || _flowDef!.nodes.isEmpty) {
      _initializeDefaultTree();
      return;
    }

    // 1) Compute depths via BFS from "1st attempt"
    final depths = <String,int>{};
    final q = <String>[];
    depths['1st attempt'] = 0;
    q.add('1st attempt');

    final adjacency = <String, List<MapEntry<String,String>>>{}; 
    // map from node to list of (outcome, toNode)
    for (var e in _flowDef!.edges) {
      adjacency.putIfAbsent(e.from, () => []).add(
        MapEntry(e.outcome, e.to)
      );
    }

    while (q.isNotEmpty) {
      final cur = q.removeAt(0);
      final d = depths[cur]!;
      for (var edge in adjacency[cur] ?? []) {
        if (!depths.containsKey(edge.value)) {
          depths[edge.value] = d + 1;
          q.add(edge.value);
        }
      }
    }

    // 2) Create elements in depth order
    final sorted = depths.keys.toList()
      ..sort((a,b) => depths[a]!.compareTo(depths[b]!));
    for (var name in sorted) {
      final depth = depths[name]!;
      final idxInRow = (_placement[depth] ?? 0);
      _placement[depth] = idxInRow + 1;

      final pos = _baseOffset + Offset(idxInRow * _hSpacing, depth * _vSpacing);

      final el = FlowElement(
        position: pos,
        size: const Size(60, 30),
        text: name,
        textSize: 10,
        kind: ElementKind.rectangle,
        handlers: [
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

    // 3) Add edges
    for (var e in _flowDef!.edges) {
      final fromEl = _nodes[e.from]!;
      final toEl   = _nodes[e.to]!;
      final style = e.outcome == 'success'
        ? ArrowStyle.segmented
        : ArrowStyle.curve;
      final color = e.outcome == 'success' ? Colors.blue : Colors.red;
      _dashboard.addNextById(
        fromEl, 
        toEl.id, 
        ArrowParams(
          color: color,
          thickness: 2,
          style: style,
          startArrowPosition: Alignment.bottomCenter,
          endArrowPosition: Alignment.topCenter,
        ),
      );
    }
  }

  /// Default starting tree: root → success1 + fail1
  void _initializeDefaultTree() {
    // 1) root
    final root = FlowElement(
      position: _baseOffset,
      size: const Size(60, 30),
      text: '1st attempt',
      textSize: 10,
      kind: ElementKind.rectangle,
      handlers: [Handler.bottomCenter],
    );
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = _NodeData(depth: 0);
    _placement[0] = 1;

    // 2) two leaves
    _addNode(root.text, isSuccess: true);
    _addNode(root.text, isSuccess: false);
  }

  /// Adds a new method‐node under [parentName] on the given branch.
  void _addNode(String parentName, { required bool isSuccess }) {
    final parent = _nodes[parentName]!;
    final pData  = _nodeData[parentName]!;

    final depth = pData.depth + 1;
    final idx   = (_placement[depth] ?? 0);
    _placement[depth] = idx + 1;

    final name = _selectedMethod?.name ?? '??';
    final pos = _baseOffset + Offset(idx * _hSpacing, depth * _vSpacing);

    final newEl = FlowElement(
      position: pos,
      size: const Size(60, 30),
      text: name,
      textSize: 10,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter],
    );
    _dashboard.addElement(newEl);
    _nodes[name] = newEl;
    _nodeData[name] = _NodeData(depth: depth);

    final newName = newEl.text;
  _edges.add(FlowEdge(
    from: parentName,
    outcome: isSuccess ? 'success' : 'failure',
    to: newName,
  ));

    // connect
    _dashboard.addNextById(
      parent, 
      newEl.id,
      ArrowParams(
        color: isSuccess ? Colors.blue : Colors.red,
        thickness: 2,
        style: isSuccess ? ArrowStyle.segmented : ArrowStyle.curve,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );
  }

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

  if (!mounted) return; // ensures this State is still active

  Navigator.of(context).pop(); // use the widget's own context
}


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
    // refresh
    _methods = await _repo.fetchFlowMethods(widget.presetId);
    setState(() {});
  }

  Future<void> _showAddMethodDialog() async {
    final nameCtl   = TextEditingController();
    MethodType type = MethodType.weight;
    final paramsCtl = TextEditingController(text: '{}');

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DropdownButton<MethodType>(
              value: type,
              onChanged: (v) => setState(() => type = v!),
              items: MethodType.values
                .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.toShortString()),
                ))
                .toList(),
            ),
            TextField(
              controller: paramsCtl,
              decoration: const InputDecoration(
                labelText: 'Params (JSON)',
                hintText: '{"sign":"+","factor":1.0}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (res == true) {
      final name = nameCtl.text.trim();
      final params = jsonDecode(paramsCtl.text) as Map<String,dynamic>;
      await _repo.upsertFlowMethod(
        presetId: widget.presetId,
        name: name,
        type: type,
        params: params,
      );
      _methods = await _repo.fetchFlowMethods(widget.presetId);
      setState(() {});
    }
  }

  Future<void> _saveFlow() async {
  final def = FlowDefinition(
    nodes: _nodes.keys.toList(),
    edges: _edges,
  );
  await _repo.upsertFlowDefinition(widget.presetId, def);
  if (!mounted) return;
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Auto‐Preset Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showManageMethodsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFlow,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Parent selector
                      DropdownButton<String>(
                        hint: const Text('Parent node'),
                        value: _selectedParent,
                        items: _nodes.keys
                            .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedParent = v;
                        }),
                      ),
                      const SizedBox(width: 8),
                      // Outcome selector
                      DropdownButton<String>(
                        value: _selectedOutcome,
                        items: const [
                          DropdownMenuItem(value: 'success', child: Text('Success')),
                          DropdownMenuItem(value: 'failure', child: Text('Failure')),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedOutcome = v!;
                        }),
                      ),
                      const SizedBox(width: 8),
                      // Method selector
                      DropdownButton<FlowMethod>(
                        hint: const Text('Method'),
                        value: _selectedMethod,
                        items: _methods
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedMethod = v;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (_selectedParent != null && _selectedMethod != null)
                                ? () {
                                    _addNode(
                                      _selectedParent!,
                                      isSuccess: _selectedOutcome == 'success',
                                    );
                                    setState(() {});
                                  }
                                : null,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: FlowChart(
                      dashboard: _dashboard,
                      onDashboardTapped: (_, __) {},
                      onElementPressed: (_, __, ___) {},
                    ),
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
