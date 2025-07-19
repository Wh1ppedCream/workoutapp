// lib/widgets/flow_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../theme/app_colors.dart';

/// Data class to track child counts, depth, and event list for each node.
class NodeData {
  int successCount = 0;
  int failureCount = 0;
  int depth;
  final List<String> events = [];
  FlowElement? listElement;
  NodeData({this.depth = 0});
}

/// A reusable widget that encapsulates a full flow chart UI,
/// including success/failure branching and event boxes.
class FlowChartWidget extends StatefulWidget {
  const FlowChartWidget({super.key});

  @override
  FlowChartWidgetState createState() => FlowChartWidgetState();
}

class FlowChartWidgetState extends State<FlowChartWidget> {
  late Dashboard _dashboard;
  final Map<String, FlowElement> _nodes = {};
  final Map<String, NodeData> _nodeData = {};
  String? _selectedNode;
  String? _selectedTargetNode;
  String? _selectedEvent;

  int _successCounter = 0;
  int _failureCounter = 0;
  static const double _hSpacing = 60;
  static const double _vSpacing = 100;
  final Map<int, int> _placement = {};

  List<String> get _targetableNodes =>
      _nodes.keys.where((n) => n != '1st attempt').toList();
  List<String> get _leafSelectableNodes => _nodes.keys.where((name) {
        final d = _nodeData[name]!;
        return (d.successCount + d.failureCount) <= 1;
      }).toList();

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _initializeTree();
  }

  void _initializeTree() {
    final root = FlowElement(
      position: const Offset(60, 50),
      size: const Size(60, 30),
      text: '1st attempt',
      textSize: 7,
      handlerSize: 5,
      kind: ElementKind.rectangle,
      handlers: [Handler.bottomCenter, Handler.leftCenter, Handler.rightCenter],
    );
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = NodeData(depth: 0);
    _placement[0] = 1;
    _addChild(parentName: root.text, isSuccess: true);
    _addChild(parentName: root.text, isSuccess: false);
    _selectedNode = null;
    _selectedTargetNode = null;
  }

  void _addChild({required String parentName, required bool isSuccess}) {
    final parent = _nodes[parentName]!;
    final data = _nodeData[parentName]!;
    final root = _nodes['1st attempt']!;
    final childDepth = data.depth + 1;
    final idxInRow = (_placement[childDepth] ?? 0);
    _placement[childDepth] = idxInRow + 1;
    final idx = isSuccess ? ++_successCounter : ++_failureCounter;
    final name = '${isSuccess ? 'success' : 'fail'}$idx';
    if (isSuccess) {
      data.successCount++;
    } else {
      data.failureCount++;
    }
    final x = 100 + idxInRow * _hSpacing;
    final y = 50 + childDepth * _vSpacing;
    final newNode = FlowElement(
      position: Offset(x, y),
      size: const Size(50, 25),
      text: name,
      textSize: 7,
      handlerSize: 5,
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
    _nodeData[name] = NodeData(depth: childDepth);
    _dashboard.addNextById(parent, newNode.id, _arrow(parent, newNode));
    final childCount = data.successCount + data.failureCount;
    if (childCount == 1) {
      _dashboard.addNextById(parent, root.id, _loopArrow(parent, root));
    } else if (childCount == 2) {
      _dashboard.removeElementConnection(parent, Handler.leftCenter);
    }
    _dashboard.addNextById(newNode, root.id, _loopArrow(newNode, root));
  }

  void _layoutListBox(String nodeName) {
    final data = _nodeData[nodeName]!;
    final parent = _nodes[nodeName]!;
    if (data.listElement == null) return;
    final width = 80.0;
    final height = 20.0 * data.events.length + 20.0;
    final newPos =
        parent.position + Offset(parent.size.width + 10, 0);
    final listEl = data.listElement!;
    listEl.changePosition(newPos);
    listEl.changeSize(Size(width, height));
    listEl.setText('List\n${data.events.join('\n')}');
    _bringToFront(listEl);
  }

  Future<void> _showAddEventDialog() async {
    if (_selectedTargetNode == null) return;
    final keyCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final key = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(labelText: 'Event key'),
            ),
            TextField(
              controller: labelCtrl,
              decoration:
                  const InputDecoration(labelText: 'Display label (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            
            onPressed: () {
              final k = keyCtrl.text.trim();
              if (k.isEmpty) return;
              Navigator.of(ctx).pop(k);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (key == null) return;
    _onAddEvent(key, labelCtrl.text.trim());
  }

  void _onAddEvent(String newKey, String display) {
    final node = _selectedTargetNode!;
    final data = _nodeData[node]!;
    if (data.events.length >= 3) return;
    final label = display.isNotEmpty ? display : newKey;
    data.events.add(label);
    if (data.listElement == null) {
      final listEl = FlowElement(
        position: Offset.zero,
        size: const Size(80, 40),
        text: 'List\n$label',
        kind: ElementKind.rectangle,
        handlers: [],
      );
      _dashboard.addElement(listEl);
      data.listElement = listEl;
      _bringToFront(listEl);
    }
    _layoutListBox(node);
    setState(() {});
  }

  void _onRemoveSelectedEvent() {
    final node = _selectedTargetNode;
    final evt = _selectedEvent;
    if (node == null || evt == null) return;
    final data = _nodeData[node]!;
    data.events.remove(evt);
    if (data.events.isEmpty) {
      _dashboard.removeElement(data.listElement!);
      data.listElement = null;
    } else {
      _layoutListBox(node);
    }
    _selectedEvent = null;
    setState(() {});
  }

  void _bringToFront(FlowElement el) {
    final list = _dashboard.elements;
    list.remove(el);
    list.add(el);
  }

  ArrowParams _arrow(FlowElement f, FlowElement t) => ArrowParams(
        color: Colors.green,
        thickness: 2,
        style: ArrowStyle.segmented,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      );

  ArrowParams _loopArrow(FlowElement f, FlowElement t) => ArrowParams(
        color: Colors.yellow.withValues(alpha: 0.3),
        thickness: 2,
        style: ArrowStyle.curve,
        startArrowPosition: Alignment.centerLeft,
        endArrowPosition: Alignment.centerRight,
      );

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
final cs     = theme.colorScheme;
final extras = theme.extension<AppColors>()!;


    return Column(
      children: [
        // success/fail controls
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              NodeSelector(
                nodes: _leafSelectableNodes,
                selected: _selectedNode,
                hint: 'Select node',
                onChanged: (v) => setState(() => _selectedNode = v),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
    backgroundColor: extras.buttonBg ?? cs.primary,
    foregroundColor: extras.buttonText ?? cs.onPrimary,
  ),
                onPressed: (_selectedNode == null || _nodeData[_selectedNode!]!.successCount >= 1)
                    ? null
                    : () {
                        _addChild(parentName: _selectedNode!, isSuccess: true);
                        setState(() {});
                      },
                child: const Text('Add Success Node'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
    backgroundColor: extras.buttonBg ?? cs.primary,
    foregroundColor: extras.buttonText ?? cs.onPrimary,
  ),
                onPressed: (_selectedNode == null || _nodeData[_selectedNode!]!.failureCount >= 1)
                    ? null
                    : () {
                        _addChild(parentName: _selectedNode!, isSuccess: false);
                        setState(() {});
                      },
                child: const Text('Add Failure Node'),
              ),
            ],
          ),
        ),
        // event controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              NodeSelector(
                nodes: _targetableNodes,
                selected: _selectedTargetNode,
                hint: 'Select node',
                onChanged: (v) => setState(() {
                  _selectedTargetNode = v;
                  _selectedEvent = null;
                }),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
    backgroundColor: extras.buttonBg ?? cs.primary,
    foregroundColor: extras.buttonText ?? cs.onPrimary,
  ),
                onPressed: _showAddEventDialog,
                child: const Text('+ Event'),
              ),
            ],
          ),
        ),
        if (_selectedTargetNode != null && _nodeData[_selectedTargetNode!]!.events.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                NodeSelector(
                  nodes: _nodeData[_selectedTargetNode!]!.events,
                  selected: _selectedEvent,
                  hint: 'Select Event',
                  onChanged: (v) => setState(() => _selectedEvent = v),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
    backgroundColor: extras.buttonBg ?? cs.primary,
    foregroundColor: extras.buttonText ?? cs.onPrimary,
  ),
                  onPressed: _onRemoveSelectedEvent,
                  child: const Text('Remove Event'),
                ),
              ],
            ),
          ),
        // flow chart area
        Expanded(
          child: Container(
            color: extras.flowChartBackground ?? cs.surface,
            child: FlowChart(
              dashboard: _dashboard,
              onDashboardTapped: (_, __) {},
              onElementPressed: (_, __, ___) {},
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable dropdown selector widget
class NodeSelector extends StatelessWidget {
  final List<String> nodes;
  final String? selected;
  final String hint;
  final ValueChanged<String?> onChanged;

  const NodeSelector({
    super.key,
    required this.nodes,
    required this.selected,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
final cs     = theme.colorScheme;
final extras = theme.extension<AppColors>()!;

    return SizedBox(
      width: 150,
      child: DropdownButton<String>(
        
  dropdownColor: extras.dialogBackground ?? cs.surface,
  style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface),
        isExpanded: true,
        hint: Text(hint),
        value: selected,
        items: nodes.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
