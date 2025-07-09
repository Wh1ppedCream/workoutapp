// File: lib/widgets/flow_screen_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import '../models/preset_models.dart';

// Callback types for reusability
typedef BranchParentChanged = void Function(String? newParent);
typedef MethodNodeChanged = void Function(String? newNode);
typedef MethodSelectedChanged = void Function(FlowMethod? method);
typedef VoidCallback = void Function();

/// Encapsulates the FlowChart canvas and exposes its Dashboard.
class FlowChartCanvas extends StatelessWidget {
  final Dashboard dashboard;
  final void Function(BuildContext context, Offset localPosition)? onTap;
  final void Function(BuildContext context, Offset localPosition, FlowElement element)? onElementPressed;

  const FlowChartCanvas({
    super.key,
    required this.dashboard,
    this.onTap,
    this.onElementPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlowChart(
      dashboard: dashboard,
      onDashboardTapped: onTap,
      onElementPressed: onElementPressed,
    );
  }
}

/// Controls row for adding branches (success/failure).
class BranchControls extends StatelessWidget {
  final List<String> branchable;
  final String? selectedParent;
  final BranchParentChanged onParentChanged;
  final VoidCallback onAddSuccess;
  final VoidCallback onAddFailure;
  final int existingSuccess;
  final int existingFailure;

  const BranchControls({
    super.key,
    required this.branchable,
    required this.selectedParent,
    required this.onParentChanged,
    required this.onAddSuccess,
    required this.onAddFailure,
    required this.existingSuccess,
    required this.existingFailure,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Branch From'),
            value: branchable.contains(selectedParent) ? selectedParent : null,
            items: branchable.map((name) {
              return DropdownMenuItem(value: name, child: Text(name));
            }).toList(),
            onChanged: onParentChanged,
          ),
        ),
        ElevatedButton(
          onPressed: (selectedParent == null || existingSuccess >= 1) ? null : onAddSuccess,
          child: const Text('+ Success'),
        ),
        ElevatedButton(
          onPressed: (selectedParent == null || existingFailure >= 1) ? null : onAddFailure,
          child: const Text('+ Failure'),
        ),
      ],
    );
  }
}

/// Controls for attaching/detaching methods to nodes.
class MethodControls extends StatelessWidget {
  final List<String> methodTargets;
  final String? selectedNode;
  final MethodNodeChanged onNodeChanged;
  final List<FlowMethod> availableMethods;
  final FlowMethod? selectedMethod;
  final MethodSelectedChanged onMethodChanged;
  final bool canAdd;
  final VoidCallback onAddMethod;
  final bool hasMethods;
  final VoidCallback onRemoveMethod;
  final bool canDeleteNode;
  final VoidCallback onRemoveNode;

  const MethodControls({
    super.key,
    required this.methodTargets,
    required this.selectedNode,
    required this.onNodeChanged,
    required this.availableMethods,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.canAdd,
    required this.onAddMethod,
    required this.hasMethods,
    required this.onRemoveMethod,
    required this.canDeleteNode,
    required this.onRemoveNode,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Select Node'),
            value: methodTargets.contains(selectedNode) ? selectedNode : null,
            items: methodTargets.map((name) {
              return DropdownMenuItem(value: name, child: Text(name));
            }).toList(),
            onChanged: onNodeChanged,
          ),
        ),
        SizedBox(
          width: 140,
          child: DropdownButton<FlowMethod>(
            isExpanded: true,
            hint: const Text('Select Method'),
            value: availableMethods.contains(selectedMethod) ? selectedMethod : null,
            items: availableMethods.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.name));
            }).toList(),
            onChanged: onMethodChanged,
          ),
        ),
        ElevatedButton(
          onPressed: canAdd ? onAddMethod : null,
          child: const Text('+ Method'),
        ),
        ElevatedButton(
          onPressed: hasMethods ? onRemoveMethod : null,
          child: const Text('- Method'),
        ),
        ElevatedButton(
          onPressed: canDeleteNode ? onRemoveNode : null,
          child: const Text('- Node'),
        ),
      ],
    );
  }
}
