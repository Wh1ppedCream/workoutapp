// File: lib/screens/profile/settings/flow_chart_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// A StatefulWidget that renders a vertical tree-like flow chart
/// with "success" and "failure" branches, starting from an initial event.
class FlowChartPage extends StatefulWidget {
  const FlowChartPage({super.key});

  @override
  State<FlowChartPage> createState() => _FlowChartPageState();
}

/// Private State class for [FlowChartPage]
/// Manages the flow chart dashboard, node data, and UI interactions.
class _FlowChartPageState extends State<FlowChartPage> {
  /// The Dashboard object from flutter_flow_chart, which holds elements and connections.
  late Dashboard _dashboard;

  /// Maps node names (String) to their FlowElement instances for quick lookup.
  final Map<String, FlowElement> _nodes = {};

  /// Tracks how many success/failure children each node has, to enable/disable buttons.
  final Map<String, NodeData> _nodeData = {};

  /// Currently selected node name from the dropdown (or null if none).
  String? _selectedNode;

  String? _selectedTargetNode;
   /// Currently selected event name for removal
  String? _selectedEvent;

/// All nodes except the root “1st attempt”
List<String> get _targetableNodes => 
  _nodes.keys.where((name) => name != '1st attempt').toList();


  // Counters to number success/fail nodes separately
  int _successCounter = 0; // total "success" nodes created
  int _failureCounter = 0; // total "fail" nodes created


  /// Horizontal spacing applied when positioning child nodes relative to parent.
  static const double _hSpacing = 60;

  /// Vertical spacing applied when positioning child nodes relative to parent.
  static const double _vSpacing = 100;

  /// Tracks number of rows and number of nodes in a row (eg: 1st row has 1 node (root node), 2nd row has 2 nodes (success1 and fail2))
  final Map<int, int> _placement = {};

  @override
  void initState() {
    super.initState();

    // Initialize the dashboard with curved arrows by default.
    _dashboard = Dashboard(
      defaultArrowStyle: ArrowStyle.curve,
    );

    // Build the initial tree structure (root + two initial leaves).
    _initializeTree();
  }

  /// Sets up the root node labeled "1st attempt"
  /// and adds its two default children: a success leaf and a failure leaf.
  void _initializeTree() {
    // 1) Create the root FlowElement
    final root = FlowElement(
      position: const Offset(60, 50), // x=60, y=50 near top
      size: const Size(60, 30),        // width=60, height=30
      text: '1st attempt',           // visible label
      textSize: 7,                    // font size 12
      handlerSize: 5,                 // touchable handler radius
      kind: ElementKind.rectangle,     // rectangular shape
      handlers: [                      // handlers where connections attach
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    // Add root to dashboard and tracking maps
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = NodeData(depth: 0);
    _placement[0] = 1;

    // 2) Add two initial leaves (success + failure) that loop back to root
    _addChild(parentName: root.text, isSuccess: true);
    _addChild(parentName: root.text, isSuccess: false);

    // No node pre-selected in the dropdown
    _selectedNode = null;
    _selectedTargetNode = null;
  }

  /// Adds a child node to [parentName], marking it as success or failure.
  /// If [init] is true, the new node also loops back to the root.
  void _addChild({
    required String parentName,
    required bool isSuccess,
  }) {
    // Lookup parent element and its data
    final parent = _nodes[parentName]!;
    final data = _nodeData[parentName]!;
  final root   = _nodes['1st attempt']!;
     // 1) compute this new node’s depth:
  final childDepth = data.depth + 1;
  
  // 2) figure out its index in that row:
  final idxInRow = (_placement[childDepth] ?? 0);
  _placement[childDepth] = idxInRow + 1;

    // Generate an index based on node type
    final idx = isSuccess ? ++_successCounter : ++_failureCounter;
    final name = '${isSuccess ? 'success' : 'fail'}$idx';

    // Update per-node child counts (for button enable logic)
    if (isSuccess) {
      data.successCount++;
      data.successChild = name;
    } else {
      data.failureCount++;
      data.failureChild = name;
    }

    // 4) compute its position:
  final x = 100 + idxInRow * _hSpacing;    // 100px left margin + column-spacing
  final y =  50 + childDepth * _vSpacing;  //  50px top margin + row-spacing
  final newPos = Offset(x, y);
  
    // Create the FlowElement for the new node
    final newNode = FlowElement(
      position: newPos,
      size: const Size(50, 25),       // smaller than root
      text: name,
      textSize: 7,                     // small font for many nodes
      handlerSize: 5,
      kind: ElementKind.rectangle,
      handlers: [                      // allow bi-directional connectors
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    // Add the new node to dashboard and tracking
    _dashboard.addElement(newNode);
    _nodes[name] = newNode;
     _nodeData[name]  = NodeData(depth: childDepth);

    // Draw arrow from parent → newNode
    // 1) connect parent → newNode
_dashboard.addNextById(parent, newNode.id, _arrow(parent, newNode),);

// 2) every leaf (newly‐created node) should loop back to the root
 // 2) Update parent's loop-back arrow:
  final childCount = data.successCount + data.failureCount;
  if (childCount == 1) {
    // Just went 0→1: add the loop back
    _dashboard.addNextById(parent, root.id, _loopArrow(parent, root));
  } else if (childCount == 2) {
    // Just went 1→2: remove its existing loop
    _dashboard.removeElementConnection(parent, Handler.leftCenter);
  }

  // 3) Since newNode has 0 children, add its loop-back
  _dashboard.addNextById(newNode, root.id, _loopArrow(newNode, root));
}

/// After you create or update the event list, call this to resize & reposition:
void _layoutListBox(String nodeName) {
  final data   = _nodeData[nodeName]!;
  final parent = _nodes[nodeName]!;
    if (data.listElement == null) return;


  // Desired size: 
  //  - width = 50
  //  - height = 20px per event + 20px header
  final width  = 50.0;
  final height = 15.0 * data.events.length + 15;

  // Place it just to the right of the parent
  final newPos = parent.position + Offset(-5, parent.size.height - 5);

  final listEl = data.listElement!;
  listEl.changePosition(newPos);
  listEl.changeSize(Size(width, height));
  // Build the text with header + newline‐separated events
  listEl.setText(data.events.join('\n'));
  listEl.setElevation(10);
  _bringElementToFront(data.listElement!);
}

void _onAddEvent(String newKey, String display) {
  if (_selectedTargetNode == null) return;
  final nodeName = _selectedTargetNode!;
  final data     = _nodeData[nodeName]!;

  // Limit to 3
  if (data.events.length >= 3) return;

  // Use display if provided, otherwise use the key itself
    final toShow = display.isNotEmpty ? display : newKey;
    data.events.add(toShow);

  // 2) Create the list‐box element on first event
  if (data.listElement == null) {
    final listEl = FlowElement(
      position: Offset.zero,     // will be repositioned below
      size: const Size(50, 40),  // placeholder
      text: 'List\n$toShow',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [],              // no handlers on these
    );
    _dashboard.addElement(listEl);
    data.listElement = listEl;
    listEl.setElevation(10);

/*
    // Optionally, connect it back to the node with a thin line
    _dashboard.addNextById(
      _nodes[nodeName]!, 
      listEl.id, 
      ArrowParams(
        color: Colors.grey,
        thickness: 1,
        style: ArrowStyle.segmented,
        startArrowPosition: Alignment.centerRight,
        endArrowPosition: Alignment.centerLeft,
      ),
    );
    */
  }

  // 3) Re‐layout the list‐box
  _layoutListBox(nodeName);

  setState(() {});
   _bringElementToFront(data.listElement!);
}


/// Remove a specific event
  void _onRemoveSelectedEvent() {
    if (_selectedTargetNode == null || _selectedEvent == null) return;
    final nodeName = _selectedTargetNode!;
    final data = _nodeData[nodeName]!;
    if (!data.events.contains(_selectedEvent)) return;
    data.events.remove(_selectedEvent);
    if (data.events.isEmpty) {
      _dashboard.removeElement(data.listElement!);
      data.listElement = null;
    } else {
      _layoutListBox(nodeName);
    }
    // clear selection
    _selectedEvent = null;
    setState(() {});
  }

/// Pops up a dialog to let the user type both a key and an optional label.
/// If the label field is empty, we use the key as the display text.
Future<void> _showAddEventDialog() async {
  if (_selectedTargetNode == null) return;

  final keyController   = TextEditingController();
  final labelController = TextEditingController();

  final key = await showDialog<String?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyController,
            decoration: const InputDecoration(
              labelText: 'Event key',
              hintText: 'e.g. event1',
            ),
          ),
          TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Display label (optional)',
              hintText: 'What shows in the list',
            ),
          ),
        ],
      ),
      actions: [
      TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text('Cancel')),
      ElevatedButton(
        onPressed: () {
          final k = keyController.text.trim();
          if (k.isEmpty) return;
          Navigator.of(ctx).pop(k);
        },
        child: Text('Add'),
      ),
    ],
    ),
  );

  if (key == null) return;
_onAddEvent(key, labelController.text.trim());
  }

/// Pulls the given element to the *end* of the draw order,
/// causing it to paint over everything else (including arrows).
void _bringElementToFront(FlowElement el) {
  final list = _dashboard.elements;     // dashboard.elements is the List<FlowElement>
  list.remove(el);
  list.add(el);
}


  /// Returns true if a node has at most one child; used to filter dropdown items.
  List<String> get _selectableNodes => _nodes.keys.where((name) {
        final d = _nodeData[name]!;
        return (d.successCount + d.failureCount) <= 1;
      }).toList();

  /// Defines the arrow style for parent → child connections.
  ArrowParams _arrow(FlowElement from, FlowElement to) {
    return ArrowParams(
      color: Colors.blue,               // blue for forward branches
      thickness: 2,
      style: ArrowStyle.segmented,      // segmented line style
      startArrowPosition: Alignment.bottomCenter,
      endArrowPosition: Alignment.topCenter,
    );
  }

  /// Defines the loop-back arrow style for initial leaf → root.
  ArrowParams _loopArrow(FlowElement from, FlowElement to) {
    return ArrowParams(
      color: Colors.black26,            // light grey for loops
      thickness: 2,
      style: ArrowStyle.curve,          // curved line style
      startArrowPosition: Alignment.centerLeft,
      endArrowPosition: Alignment.centerLeft,
    );
  }

  /// Handler for Add Success Node button tap
  void _onAddSuccess() {
    if (_selectedNode != null) {
      _addChild(parentName: _selectedNode!, isSuccess: true);
      setState(() {});
    }
  }

  /// Handler for Add Failure Node button tap
  void _onAddFailure() {
    if (_selectedNode != null) {
      _addChild(parentName: _selectedNode!, isSuccess: false);
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title
      appBar: AppBar(title: const Text('Vertical Tree FlowChart')),
      body: Column(
        children: [
          // Dropdown selector + Add buttons
          Padding(
  padding: const EdgeInsets.all(8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Node selection dropdown on its own line
      SizedBox(
        width: 150,
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select node'),
          value: (_selectedNode != null &&
                  _selectableNodes.contains(_selectedNode))
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
      const SizedBox(height: 8), // Small vertical spacing
      // Buttons in one row under the dropdown
      Row(
        children: [
          ElevatedButton(
            onPressed: (_selectedNode == null ||
                    _nodeData[_selectedNode!]!.successCount >= 1)
                ? null
                : _onAddSuccess,
            child: const Text('+ Success Node'),
          ),
          const SizedBox(width: 16), // Spacing between buttons
          ElevatedButton(
            onPressed: (_selectedNode == null ||
                    _nodeData[_selectedNode!]!.failureCount >= 1)
                ? null
                : _onAddFailure,
            child: const Text('+ Failure Node'),
          ),
        ],
      ),
    ],
  ),
),


         // Selector for target node + Add Event button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select node'),
                    value: (_selectedTargetNode != null && _targetableNodes.contains(_selectedTargetNode))
                        ? _selectedTargetNode
                        : null,
                    items: _targetableNodes.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedTargetNode = v;
                      _selectedEvent = null;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
  onPressed: _showAddEventDialog,
  child: const Text('+ Event'),
),

              ],
            ),
          ),
          // Dropdown for selecting which event to remove + Remove button
          if (_selectedTargetNode != null && _nodeData[_selectedTargetNode!]!.events.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Event'),
                      value: (_selectedEvent != null && _nodeData[_selectedTargetNode!]!.events.contains(_selectedEvent))
                          ? _selectedEvent
                          : null,
                      items: _nodeData[_selectedTargetNode!]!.events.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() {
                        _selectedEvent = v;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onRemoveSelectedEvent,
                    child: const Text('Remove Event'),
                  ),
                ],
              ),
            ),
          // The flow chart area
          Expanded(
            child: Container(
              color: Colors.white,
              child: FlowChart(
                dashboard: _dashboard,
                onDashboardTapped: (_, __) {},     // no-op handlers
                onElementPressed: (_, __, ___) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple data class to track how many success/failure nodes
/// a given node has, for button enable/disable logic.
class NodeData {
  int successCount = 0;
  int failureCount = 0;
/// New: at what depth (row) this node lives
  int depth;

   /// Holds the event names in order, e.g. ['event1','event2',...]
  final List<String> events = [];
  
  /// Once created, this points at the FlowElement for the list‐box
  FlowElement? listElement;

  /// Child references
  String? successChild;
  String? failureChild;

  NodeData({this.depth = 0});
}
