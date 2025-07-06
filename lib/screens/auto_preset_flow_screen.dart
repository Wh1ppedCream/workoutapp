// File: lib/screens/auto_preset_flow_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import '../models/preset_models.dart';
import '../repositories/app_repository.dart';

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

  final Map<String, List<String>> _attachedMethodsByNode = {};


  FlowMethod? _selectedMethod;

  // inside class _AutoPresetFlowScreenState
String? _selectedBranchParent;
String? _selectedMethodNode;


  // Spacing constants
  static const double _hSpacing = 100;
  static const double _vSpacing = 100;
  static const Offset _baseOffset = Offset(60, 50);

  @override
  void initState() {
    super.initState();
    // ① Initialize your dashboard here
    _dashboard = Dashboard(
      defaultArrowStyle: ArrowStyle.curve,
    );
    // ② Now load any saved nodes/edges and then call your buildRoutine:
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
  _initializeCounters();    // ← reset counters here
}

  void _initializeCounters() {
  _successCounter = 
    _nodes.keys.where((name) => name.startsWith('success')).length;
  _failureCounter = 
    _nodes.keys.where((name) => name.startsWith('fail')).length;
}

  void _buildDashboard() {
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();
    // 0.5) Rebuild any saved “method” attachments
   _attachedMethodsByNode.clear();
   for (final e in _flowDef?.edges ?? []) {
     if (e.outcome == 'method') {
       _attachedMethodsByNode
         .putIfAbsent(e.from, () => <String>[])
        .add(e.to);
     }
   }

    // If no nodes defined, fall back to default tree.
    if (_flowDef == null || _flowDef!.nodes.isEmpty) {
      _initializeDefaultTree();
    } else {

    // 1) Compute depths via BFS from "1st attempt"
    final depths = <String,int>{};
    final q = <String>[];
    depths['1st attempt'] = 0;
    q.add('1st attempt');

    final adjacency = <String, List<String>>{};
    for (var e in _flowDef!.edges.where((e) => e.outcome != 'method')) {
      adjacency.putIfAbsent(e.from, () => []).add(e.to);
    }

    while (q.isNotEmpty) {
      final cur = q.removeAt(0);
      final d = depths[cur]!;
      for (var child in adjacency[cur] ?? []) {
      if (!depths.containsKey(child)) {
        depths[child] = d + 1;
        q.add(child);
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
        textSize: 7,
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
    // 3) Add *only branch* edges (success/failure).  Skip outcome=='method'
    //for (var e in _edges) {
    for (var e in _edges.where((e) => e.outcome != 'method')) {
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

    // 4) Now render bullet‐lists for each node that has attached methods
    for (var parent in _attachedMethodsByNode.keys) {
      _refreshNodeText(parent);
    }
    
    _applyLoopbacks();
  
  }

  /// Default starting tree: root → success1 + fail1
void _initializeDefaultTree() {
  // 1) Root
  final root = FlowElement(
    position: const Offset(60, 50),
    size: const Size(60, 30),
    text: '1st attempt',
    textSize: 7,
    kind: ElementKind.rectangle,
    handlers: [
    Handler.topCenter,
    Handler.bottomCenter,
    Handler.leftCenter,    // ← this one
    Handler.rightCenter,   // ← optional but symmetric
  ],
  );
  _dashboard.addElement(root);
  _nodes[root.text]    = root;
  _nodeData[root.text] = _NodeData(depth: 0);
  _placement[0]        = 1;

  // 2) First success and first failure, with unique names
  final sName = 'success${++_successCounter}';
  _createBranchNode('1st attempt', sName, 'success');

  final fName = 'fail${++_failureCounter}';
  _createBranchNode('1st attempt', fName, 'failure');
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
  final nameCtl      = TextEditingController();
  MethodType type    = MethodType.weight;
  String sign        = '+';
  final factorCtl    = TextEditingController(text: '1.0');
  final amountCtl    = TextEditingController(text: '0');
  AddSetMode addMode = AddSetMode.explicit;
  final weightCtl    = TextEditingController(text: '0.0');
  final repsCtl      = TextEditingController(text: '0');
  final copyIndexCtl = TextEditingController(text: '-1');

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('New Method'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) Method name
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),

              const SizedBox(height: 12),

              // 2) Method type
              DropdownButton<MethodType>(
                value: type,
                isExpanded: true,
                onChanged: (v) => setState(() => type = v!),
                items: MethodType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toShortString()),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // 3) Dynamic fields
              if (type == MethodType.weight) ...[
                // Sign picker
                DropdownButton<String>(
                  value: sign,
                  onChanged: (v) => setState(() => sign = v!),
                  items: const [
                    DropdownMenuItem(value: '+', child: Text('+')),
                    DropdownMenuItem(value: '-', child: Text('-')),
                  ],
                ),
                const SizedBox(height: 8),
                // Factor input
                TextField(
                  controller: factorCtl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Factor'),
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
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ] else if (type == MethodType.addSet) ...[
                // Mode selector
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

                if (addMode == AddSetMode.explicit) ...[
                  TextField(
                    controller: weightCtl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: repsCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ] else ...[
                  TextField(
                    controller: copyIndexCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Set index (-1 = last)',
                    ),
                  ),
                ],
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

  // Build params map
  Map<String, dynamic> params;
  switch (type) {
    case MethodType.weight:
      params = {
        'sign': sign,
        'factor': double.tryParse(factorCtl.text) ?? 1.0,
      };
      break;
    case MethodType.rep:
      params = {
        'sign': sign,
        'amount': int.tryParse(amountCtl.text) ?? 0,
      };
      break;
    case MethodType.addSet:
      if (addMode == AddSetMode.explicit) {
        params = {
          'weight': double.tryParse(weightCtl.text) ?? 0.0,
          'reps': int.tryParse(repsCtl.text) ?? 0,
        };
      } else {
        params = {
          'copyFromSetIndex': int.tryParse(copyIndexCtl.text) ?? -1,
        };
      }
      break;
    case MethodType.delSet:
      params = {};
      break;
  }

  // Persist via repository
  await _repo.upsertFlowMethod(
    presetId: widget.presetId,
    name: nameCtl.text.trim(),
    type: type,
    params: params,
  );

  // Reload methods list
  _methods = await _repo.fetchFlowMethods(widget.presetId);
  setState(() { /* refresh dropdowns */ });
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


/// Shared logic to place a branch node under [parent] with [name]/[outcome].
void _createBranchNode(String parent, String name, String outcome) {
  final pData = _nodeData[parent]!;
  final depth = pData.depth + 1;
  final idx   = (_placement[depth] ?? 0);
  _placement[depth] = idx + 1;

  final pos = Offset(60 + idx * _hSpacing, 50 + depth * _vSpacing);
  final el = FlowElement(
    position: pos,
    size: const Size(60, 30),
    text: name,
    textSize: 7,
    kind: ElementKind.rectangle,
    handlers: [
    Handler.topCenter,
    Handler.bottomCenter,
    Handler.leftCenter,   // ← so loopbacks can hook here
    Handler.rightCenter,  // optional
  ],
  );
  _dashboard.addElement(el);
  _nodes[name]      = el;
  _nodeData[name]   = _NodeData(depth: depth);

  // 2) Draw the real branch arrow (blue for success, red for failure)
  final branchColor = outcome == 'success' ? Colors.blue : Colors.red;
  final branchStyle = outcome == 'success'
      ? ArrowStyle.segmented
      : ArrowStyle.curve;
  _dashboard.addNextById(
    _nodes[parent]!,
    el.id,
    ArrowParams(
      color: branchColor,
      thickness: 2,
      style: branchStyle,
      startArrowPosition: Alignment.bottomCenter,
      endArrowPosition:   Alignment.topCenter,
    ),
  );

  // 3) Record it in your model
  _edges.add(FlowEdge(from: parent, outcome: outcome, to: name));

  // 4) Immediately give the NEW node its own grey loop-back
  final rootEl = _nodes['1st attempt']!;
  _dashboard.addNextById(
    el,
    rootEl.id,
    ArrowParams(
      color: Colors.grey,
      thickness: 2,
      style: ArrowStyle.curve,
      startArrowPosition: Alignment.centerLeft,
      endArrowPosition:   Alignment.centerLeft,
    ),
  );

  // 5) If the PARENT now has *both* branches, remove its loop-back
  final hasSucc = _edges.any((e) => e.from == parent && e.outcome == 'success');
  final hasFail = _edges.any((e) => e.from == parent && e.outcome == 'failure');
  if (hasSucc && hasFail) {
    _dashboard.removeElementConnection(
      _nodes[parent]!,
      Handler.leftCenter,
    );
  }

  // 6) Trigger a repaint
  setState(() {});
}

/// Add a success branch from the selected parent.
/// Creates a new success‐branch node with unique name.
void _onAddSuccess() {
  final parent = _selectedBranchParent;
  if (parent == null) return;

  final name = 'success${++_successCounter}';
  _createBranchNode(parent, name, 'success');
}

/// Add a failure branch from the selected parent.
/// Creates a new failure‐branch node with unique name.
void _onAddFailure() {
  final parent = _selectedBranchParent;
  if (parent == null) return;

  final name = 'fail${++_failureCounter}';
  _createBranchNode(parent, name, 'failure');
}

void _refreshNodeText(String nodeName) {
  final el = _nodes[nodeName]!;
  final methods = _attachedMethodsByNode[nodeName] ?? [];

  // Build a multi-line label: first the node name, then bullets
  final lines = [nodeName, ...methods.map((m) => m)];
  el.setText(lines.join('\n'));

  // Grow height to fit up to 3 methods (adjust px as needed)
  final baseHeight = 30.0;
  final lineHeight = 16.0;
  final newHeight = baseHeight + methods.length * lineHeight;
  el.changeSize(Size(el.size.width, newHeight));
}


/// Attach the selected method to the selected node.
void _onAddMethod() {
  final target = _selectedMethodNode;
  final method = _selectedMethod;
  if (target == null || method == null) return;

  // Keep at most 3 methods per node
  final list = _attachedMethodsByNode[target] ?? <String>[];
  if (list.length >= 3) return;

  // Attach it
  list.add(method.name);
  _attachedMethodsByNode[target] = list;

  _edges.add(FlowEdge( from: target, outcome: 'method', to: method.name));

  // Redraw that node’s label
  _refreshNodeText(target);

  setState(() {});
}


/// Remove the last attached method under the selected node.
void _onRemoveMethod() {
  final target = _selectedMethodNode;
  if (target == null) return;

  final attached = _attachedMethodsByNode[target];
  if (attached == null || attached.isEmpty) return;

  // 1) Pop off the last method name
  final removedMethod = attached.removeLast();

  // 2) If that was the only one, remove the entry entirely
  if (attached.isEmpty) {
    _attachedMethodsByNode.remove(target);
  } else {
    _attachedMethodsByNode[target] = attached;
  }

  // 3) Remove its FlowEdge from the model
  _edges.removeWhere((e) =>
    e.from == target &&
    e.outcome == 'method' &&
    e.to == removedMethod
  );

  // 4) Update the node's label to drop the bullet
  _refreshNodeText(target);

  // 5) Repaint
  setState(() {});
}


void _onRemoveNode() {
  final name = _selectedMethodNode;
  if (name == null || name == '1st attempt') return;

  // Safety re-check:
  final branchKids = _edges.where((e) =>
    e.from == name &&
    (e.outcome == 'success' || e.outcome == 'failure'));
  final hasMethods = (_attachedMethodsByNode[name]?.isNotEmpty ?? false);
  if (branchKids.isNotEmpty || hasMethods) return;

  // 1) Remove any incoming branch edges (so parents drop their arrow)
  _edges.removeWhere((e) => e.to == name && 
    (e.outcome == 'success' || e.outcome == 'failure'));

  // 2) Remove this element from the dashboard & your maps
  final el = _nodes.remove(name)!;
  _dashboard.removeElement(el);
  _nodeData.remove(name);
  _attachedMethodsByNode.remove(name);

  // 3) Clear selection
  _selectedMethodNode = null;
  _selectedMethod = null;

  setState(() {});
}



void _applyLoopbacks() {
  final rootEl = _nodes['1st attempt']!;

  // 1) Build quick lookups of which branch type each node already has:
  final hasSuccess = <String,bool>{};
  final hasFailure = <String,bool>{};
  for (var e in _edges) {
    if (e.outcome == 'success') hasSuccess[e.from] = true;
    if (e.outcome == 'failure') hasFailure[e.from] = true;
  }

  // 2) For every non-root node, if a branch is missing, add the grey loop:
  for (var name in _nodes.keys) {
    if (name == '1st attempt') continue;
    final fromEl = _nodes[name]!;

    // success loopback
    if (hasSuccess[name] != true) {
      _dashboard.addNextById(
        fromEl,
        rootEl.id,
        ArrowParams(
          color: Colors.grey,
          thickness: 2,
          style: ArrowStyle.curve,
          startArrowPosition: Alignment.centerLeft,
          endArrowPosition:   Alignment.centerLeft,
        ),
      );
    }

    // failure loopback
    if (hasFailure[name] != true) {
      _dashboard.addNextById(
        fromEl,
        rootEl.id,
        ArrowParams(
          color: Colors.grey,
          thickness: 2,
          style: ArrowStyle.curve,
          startArrowPosition: Alignment.centerLeft,
          endArrowPosition:   Alignment.centerLeft,
        ),
      );
    }
  }
}



 @override
Widget build(BuildContext context) {
  // Compute branchable nodes (out-degree < 2)
  final outCounts = <String,int>{};
  for (var e in _edges.where((e) => e.outcome=='success' || e.outcome=='failure')) {
  outCounts[e.from] = (outCounts[e.from] ?? 0) + 1;
}

  final branchable = _nodes.keys
    .where((n) => (outCounts[n] ?? 0) < 2)
    .toList();

  // Compute which branches exist for the selected branch‐parent
  int existingSuccess = _edges
      .where((e) => e.from == _selectedBranchParent && e.outcome == 'success')
      .length;
  int existingFailure = _edges
      .where((e) => e.from == _selectedBranchParent && e.outcome == 'failure')
      .length;

  // Compute method‐targets: all except root
  final methodTargets = _nodes.keys.where((n) => n != '1st attempt').toList();

  // Compute how many methods are attached to the selected method‐target
  // (i.e. outgoing edges that point to a method‐node)
  _methods.map((m) => m.name).toSet();
  final attachedMethods = _attachedMethodsByNode[_selectedMethodNode] ?? <String>[];

  // 1) Figure out which method-types are already on the selected node
final attachedNames = _attachedMethodsByNode[_selectedMethodNode] ?? [];

// 2) Map each attached name into its MethodType (or null if not found)
final attachedTypes = attachedNames
  .map<MethodType?>((name) {
    // find all methods matching that name
    final matches = _methods.where((m) => m.name == name);
    if (matches.isEmpty) return null;        // no such method
    return matches.first.type;               // return its type
  })
  .whereType<MethodType>()                  // drop any nulls
  .toSet();                                 // unique set of types


// 2) Build the list of methods *not* yet attached (one per type)
final availableMethods = _methods
  .where((m) => !attachedTypes.contains(m.type))
  .toList();

final canAdd = 
  _selectedMethodNode != null &&
  _selectedMethod != null &&
  availableMethods.contains(_selectedMethod!);


  bool canDeleteNode = true;
  final selected = _selectedMethodNode;

// 1) No deletion of root:
if (selected == null || selected == '1st attempt') {
  canDeleteNode = false;
} else {
  // 2) no branch children?
  final branchKids = _edges.where((e) =>
    e.from == selected &&
    (e.outcome == 'success' || e.outcome == 'failure'));
  final hasBranchChildren = branchKids.isNotEmpty;

  // 3) no methods?
  final hasMethods = (_attachedMethodsByNode[selected]?.isNotEmpty ?? false);

  canDeleteNode = !hasBranchChildren && !hasMethods;
}


  return Scaffold(
    appBar: AppBar(
    title: const Text('Edit Auto-Preset Flow'),
    actions: [
      IconButton(
        icon: const Icon(Icons.build),
        tooltip: 'Manage Methods',
        onPressed: _showManageMethodsDialog,
      ),
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save Flow',
        onPressed: _saveFlow,
      ),
    ],
  ),
    body: Column(
      children: [
        // ── Controls Row ─────────────────────────────────────
        Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // 1) Branch Parent
            SizedBox(
              width: 140,
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Branch From'),
                value: branchable.contains(_selectedBranchParent)
    ? _selectedBranchParent
    : null,
                items: branchable.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (v) => setState(() {
                  _selectedBranchParent = v;
                }),
              ),
            ),

            // 2) + Success
            ElevatedButton(
              onPressed: (_selectedBranchParent == null || existingSuccess >= 1)
                  ? null
                  : _onAddSuccess,
              child: const Text('+ Success'),
            ),

            // 3) + Failure
            ElevatedButton(
              onPressed: (_selectedBranchParent == null || existingFailure >= 1)
                  ? null
                  : _onAddFailure,
              child: const Text('+ Failure'),
            ),

            // 4) Method Target
            SizedBox(
  width: 140,
  child: DropdownButton<String>(
    isExpanded: true,
    hint: const Text('Select Node'),
    value: methodTargets.contains(_selectedMethodNode)
      ? _selectedMethodNode
      : null,
    items: methodTargets.map((name) {
      return DropdownMenuItem(value: name, child: Text(name));
    }).toList(),
    onChanged: (v) => setState(() {
      _selectedMethodNode = v;
      _selectedMethod = null;
    }),
  ),
),


            // between the “Select Node” and “+ Method” buttons:
// Method Target ▼
SizedBox(
  width: 140,
  child: DropdownButton<FlowMethod>(
    isExpanded: true,
    hint: const Text('Select Method'),
    value: availableMethods.contains(_selectedMethod)
      ? _selectedMethod
      : null,
    items: availableMethods.map((m) {
      return DropdownMenuItem(value: m, child: Text(m.name));
    }).toList(),
    onChanged: (m) => setState(() => _selectedMethod = m),
  ),
),

ElevatedButton(
  onPressed: canAdd ? _onAddMethod : null,
  child: const Text('+ Method'),
),

            // 6) - Method
            ElevatedButton(
  onPressed: (_selectedMethodNode == null || attachedMethods.isEmpty)
      ? null
      : _onRemoveMethod,
  child: const Text('- Method'),
),
ElevatedButton(
  onPressed: canDeleteNode ? _onRemoveNode : null,
  child: const Text('- Node'),
),

          ],
        ),
      ),

      // ─── The FlowChart Canvas ───────────────────────────────────
      Expanded(
        child: FlowChart(
          dashboard: _dashboard,
          onDashboardTapped: (_, __) {},
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
