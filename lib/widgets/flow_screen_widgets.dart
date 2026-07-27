// File: lib/widgets/flow_screen_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/preset_models.dart';
import '../theme/theme_extensions.dart';

// Callback types for reusability
typedef BranchParentChanged = void Function(String? newParent);
typedef MethodNodeChanged = void Function(String? newNode);
typedef MethodSelectedChanged = void Function(FlowMethod? method);
typedef VoidCallback = void Function();

/// Encapsulates the FlowChart canvas and exposes its Dashboard.
class FlowChartCanvas extends StatelessWidget {
  final Dashboard dashboard;
  final void Function(BuildContext context, Offset localPosition)? onTap;
  final void Function(
    BuildContext context,
    Offset localPosition,
    FlowElement element,
  )?
  onElementPressed;

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

/// Controls row for adding branches (success/failure), themed.
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
    final strings = AppLocalizations.of(context);
    final cs = context.cs;
    final extras = context.colors;
    final dropdownBg = extras.dialogBackground ?? cs.surface;
    final textColor = cs.onSurface;
    final btnBg = extras.buttonBg ?? cs.primary;
    final btnText = extras.buttonText ?? cs.onPrimary;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: DropdownButton<String>(
            dropdownColor: dropdownBg,
            isExpanded: true,
            hint: Text(
              strings.flowBranchFrom,
              style: TextStyle(color: textColor),
            ),
            value: branchable.contains(selectedParent) ? selectedParent : null,
            items:
                branchable.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name, style: TextStyle(color: textColor)),
                  );
                }).toList(),
            onChanged: onParentChanged,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnText,
          ),
          onPressed:
              (selectedParent == null || existingSuccess >= 1)
                  ? null
                  : onAddSuccess,
          child: Text(strings.flowAddSuccess),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnText,
          ),
          onPressed:
              (selectedParent == null || existingFailure >= 1)
                  ? null
                  : onAddFailure,
          child: Text(strings.flowAddFailure),
        ),
      ],
    );
  }
}

/// Controls for attaching/detaching methods to nodes, themed.
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
    final strings = AppLocalizations.of(context);
    final cs = context.cs;
    final extras = context.colors;
    final dropdownBg = extras.dialogBackground ?? cs.surface;
    final textColor = cs.onSurface;
    final btnBg = extras.buttonBg ?? cs.primary;
    final btnText = extras.buttonText ?? cs.onPrimary;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: DropdownButton<String>(
            dropdownColor: dropdownBg,
            isExpanded: true,
            hint: Text(
              strings.flowSelectNode,
              style: TextStyle(color: textColor),
            ),
            value: methodTargets.contains(selectedNode) ? selectedNode : null,
            items:
                methodTargets.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name, style: TextStyle(color: textColor)),
                  );
                }).toList(),
            onChanged: onNodeChanged,
          ),
        ),
        SizedBox(
          width: 140,
          child: DropdownButton<FlowMethod>(
            dropdownColor: dropdownBg,
            isExpanded: true,
            hint: Text(
              strings.flowSelectMethod,
              style: TextStyle(color: textColor),
            ),
            value:
                availableMethods.contains(selectedMethod)
                    ? selectedMethod
                    : null,
            items:
                availableMethods.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m.name, style: TextStyle(color: textColor)),
                  );
                }).toList(),
            onChanged: onMethodChanged,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnText,
          ),
          onPressed: canAdd ? onAddMethod : null,
          child: Text(strings.flowAddMethod),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnText,
          ),
          onPressed: hasMethods ? onRemoveMethod : null,
          child: Text(strings.flowRemoveMethod),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            foregroundColor: btnText,
          ),
          onPressed: canDeleteNode ? onRemoveNode : null,
          child: Text(strings.flowRemoveNode),
        ),
      ],
    );
  }
}
