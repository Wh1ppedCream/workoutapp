// lib/screens/flow_chart_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

class FlowChartPage extends StatefulWidget {
  const FlowChartPage({super.key});

  @override
  State<FlowChartPage> createState() => _FlowChartPageState();
}

class _FlowChartPageState extends State<FlowChartPage> {
  late Dashboard _dashboard;
  final Map<String, FlowElement> _nodes = {};
  final Map<String, NodeData> _nodeData = {};
  String? _selectedNode;

  // Counter for globally unique node naming
  int _nodeCounter = 0;

  static const double _hSpacing = 150;
  static const double _vSpacing = 150;

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(
      defaultArrowStyle: ArrowStyle.curve,
    );
    _initializeTree();
  }

  void _initializeTree() {
    // Create the root "initial event"
    final root = FlowElement(
      position: const Offset(200, 100),
      size: const Size(120, 60),
      text: 'initial event',
      handlerSize: 20,
      kind: ElementKind.rectangle,
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = NodeData();

    // Add initial leaf nodes
    _addChild(parentName: root.text, isSuccess: true, init: true);
    _addChild(parentName: root.text, isSuccess: false, init: true);

    _selectedNode = null;
  }

  void _addChild({
    required String parentName,
    required bool isSuccess,
    bool init = false,
  }) {
    final parent = _nodes[parentName]!;
    final data = _nodeData[parentName]!;

    // Determine unique name using global counter
    final idx = ++_nodeCounter;
    final name = '${isSuccess ? 'success' : 'fail'}$idx';

    // Track per-node counts for enabling/disabling
    if (isSuccess) {
      data.successCount++;
    } else {
      data.failureCount++;
    }

    final newPos = parent.position + Offset(isSuccess ? -_hSpacing : _hSpacing, _vSpacing);

    final newNode = FlowElement(
      position: newPos,
      size: const Size(100, 50),
      text: name,
      handlerSize: 20,
      kind: ElementKind.rectangle,
      handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    _dashboard.addElement(newNode);
    _nodes[name] = newNode;
    _nodeData[name] = NodeData();

    _dashboard.addNextById(
      parent,
      newNode.id,
      ArrowParams(
        thickness: 1.5,
        color: Colors.black26,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );

    if (init) {
      final root = _nodes['initial event']!;
      _dashboard.addNextById(
        newNode,
        root.id,
        ArrowParams(
          thickness: 1.5,
          startArrowPosition: Alignment.topCenter,
          endArrowPosition: Alignment.bottomCenter,
        ),
      );
    }
  }

  /// Only nodes with 0 or 1 child appear in the dropdown
  List<String> get _selectableNodes => _nodes.keys.where((name) {
        final d = _nodeData[name]!;
        return (d.successCount + d.failureCount) <= 1;
      }).toList();

  void _onAddSuccess() {
    if (_selectedNode != null) {
      _addChild(parentName: _selectedNode!, isSuccess: true);
      setState(() {});
    }
  }

  void _onAddFailure() {
    if (_selectedNode != null) {
      _addChild(parentName: _selectedNode!, isSuccess: false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vertical Tree FlowChart')),
      body: Column(
        children: [
          // Selector and buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select node'),
                    value: (_selectedNode != null && _selectableNodes.contains(_selectedNode))
                        ? _selectedNode
                        : null,
                    items: _selectableNodes.map((name) {
                      return DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedNode = v;
                    }),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_selectedNode == null || _nodeData[_selectedNode!]!.successCount >= 1)
                      ? null
                      : _onAddSuccess,
                  child: const Text('Add Success Node'),
                ),
                ElevatedButton(
                  onPressed: (_selectedNode == null || _nodeData[_selectedNode!]!.failureCount >= 1)
                      ? null
                      : _onAddFailure,
                  child: const Text('Add Failure Node'),
                ),
              ],
            ),
          ),
          // Flow chart
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

/// Tracks how many success/failure children a node has for enabling logic
class NodeData {
  int successCount = 0;
  int failureCount = 0;
}
