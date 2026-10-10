import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/preset_models.dart';
import '../../theme/expressive_planning_tokens.dart';

class FlowEditorGraphMetrics {
  const FlowEditorGraphMetrics({
    required this.rootCenter,
    required this.branchOrigin,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    required this.nodeSize,
    required this.textSize,
    required this.lineHeight,
    required this.minimumNodeHeight,
    required this.actionRowHeight,
    required this.expressive,
  });

  final Offset rootCenter;
  final Offset branchOrigin;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Size nodeSize;
  final double textSize;
  final double lineHeight;
  final double minimumNodeHeight;
  final double actionRowHeight;
  final bool expressive;
}

FlowEditorGraphMetrics flowEditorGraphMetrics({required bool expressive}) {
  if (!expressive) {
    return const FlowEditorGraphMetrics(
      rootCenter: Offset(84, 50),
      branchOrigin: Offset(60, 50),
      horizontalSpacing: 100,
      verticalSpacing: 100,
      nodeSize: Size(60, 30),
      textSize: 7,
      lineHeight: 16,
      minimumNodeHeight: 30,
      actionRowHeight: 16,
      expressive: false,
    );
  }

  return const FlowEditorGraphMetrics(
    rootCenter: Offset(160, 96),
    branchOrigin: Offset(160, 96),
    horizontalSpacing: 190,
    verticalSpacing: 200,
    nodeSize: Size(160, 60),
    textSize: 13,
    lineHeight: 18,
    minimumNodeHeight: 60,
    actionRowHeight: 22,
    expressive: true,
  );
}

double flowEditorNodeHeight(
  String nodeName,
  Iterable<String> methodNames,
  FlowEditorGraphMetrics metrics,
) {
  if (!metrics.expressive) {
    return metrics.minimumNodeHeight +
        methodNames.length * metrics.actionRowHeight;
  }

  final charactersPerLine = math
      .max(8, (metrics.nodeSize.width / (metrics.textSize * 0.56)).floor())
      .toInt();
  var lineCount = 0;
  for (final label in [nodeName, ...methodNames]) {
    lineCount += math.max(1, (label.length / charactersPerLine).ceil()).toInt();
  }
  return math
      .max(metrics.minimumNodeHeight, 16 + lineCount * metrics.lineHeight)
      .toDouble();
}

Color flowEditorGridColor(BuildContext context, Color grid) {
  if (AppExpressivePlanningTokens.maybeOf(context) != null &&
      Theme.of(context).brightness == Brightness.light) {
    return grid.withValues(alpha: grid.a * 0.45);
  }
  return grid;
}

class FlowEditorAnchoredChoiceField<T> extends StatefulWidget {
  const FlowEditorAnchoredChoiceField({
    super.key,
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.decoration,
    required this.textStyle,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final List<T> values;
  final T? value;
  final String Function(T value) label;
  final String Function(T value)? subtitle;
  final InputDecoration decoration;
  final TextStyle? textStyle;
  final ValueChanged<T?>? onChanged;

  @override
  State<FlowEditorAnchoredChoiceField<T>> createState() =>
      _FlowEditorAnchoredChoiceFieldState<T>();
}

class _FlowEditorAnchoredChoiceFieldState<T>
    extends State<FlowEditorAnchoredChoiceField<T>> {
  late final FocusNode _focusNode;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Flow editor choice field')
      ..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppExpressivePlanningTokens.maybeOf(context)!;
    final screenSize = MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final enabled = widget.onChanged != null && widget.values.isNotEmpty;
    final selectedValue = widget.value;
    final selectedLabel = selectedValue == null
        ? ''
        : widget.label(selectedValue);
    final fieldBorder =
        widget.decoration.enabledBorder ??
        widget.decoration.border ??
        widget.decoration.focusedBorder;
    final borderRadius = fieldBorder is OutlineInputBorder
        ? fieldBorder.borderRadius
        : tokens.supportShape;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = math.max(0.0, screenSize.width - 48);
        final width = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, screenSize.width - 24)
            : fallbackWidth;
        final menuMaxHeight = math.max(
          0.0,
          screenSize.height -
              mediaQuery.padding.vertical -
              mediaQuery.viewInsets.vertical -
              24,
        );
        return MenuAnchor(
          key: PageStorageKey<String>('flow-editor-choice-${widget.title}'),
          useRootOverlay: true,
          crossAxisUnconstrained: false,
          childFocusNode: _focusNode,
          onOpen: () => setState(() => _menuOpen = true),
          onClose: () => setState(() => _menuOpen = false),
          style: MenuStyle(
            alignment: AlignmentDirectional.bottomStart,
            backgroundColor: WidgetStatePropertyAll(
              tokens.configurationSurface,
            ),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(2),
            side: WidgetStatePropertyAll(
              BorderSide(color: tokens.outline, width: 1),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: tokens.supportShape),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
            minimumSize: WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll(Size(width, menuMaxHeight)),
          ),
          menuChildren: [
            for (var index = 0; index < widget.values.length; index++)
              _menuItem(context, tokens, index),
          ],
          builder: (context, controller, child) => PopScope(
            canPop: !controller.isOpen,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && controller.isOpen) controller.close();
            },
            child: Semantics(
              button: true,
              enabled: enabled,
              expanded: _menuOpen,
              label: widget.title,
              value: selectedLabel,
              onTap: enabled
                  ? () => controller.isOpen
                        ? controller.close()
                        : controller.open()
                  : null,
              child: ExcludeSemantics(
                child: InkWell(
                  focusNode: _focusNode,
                  canRequestFocus: enabled,
                  borderRadius: borderRadius,
                  onTap: enabled
                      ? () => controller.isOpen
                            ? controller.close()
                            : controller.open()
                      : null,
                  child: InputDecorator(
                    decoration: widget.decoration.copyWith(
                      enabled: enabled,
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: tokens.configurationForeground,
                      ),
                    ),
                    isFocused: _focusNode.hasFocus || _menuOpen,
                    isEmpty: selectedValue == null,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DefaultTextStyle.merge(
                        style: widget.textStyle,
                        child: selectedValue == null
                            ? const SizedBox.shrink()
                            : Text(
                                selectedLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(
    BuildContext context,
    AppExpressivePlanningTokens tokens,
    int index,
  ) {
    final value = widget.values[index];
    final selected = value == widget.value;
    final foreground = selected
        ? tokens.actionPrimaryForeground
        : tokens.configurationForeground;
    final background = selected
        ? tokens.actionPrimary
        : tokens.configurationSurface;
    final subtitle = widget.subtitle?.call(value);
    return MenuItemButton(
      key: ValueKey<int>(index),
      onPressed: () => widget.onChanged?.call(value),
      style: ButtonStyle(
        alignment: AlignmentDirectional.centerStart,
        foregroundColor: WidgetStatePropertyAll(foreground),
        backgroundColor: WidgetStatePropertyAll(background),
        minimumSize: const WidgetStatePropertyAll(Size(0, 50)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: tokens.rowShape),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: foreground,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
      trailingIcon: selected
          ? Icon(Icons.check, color: foreground, size: 18)
          : null,
      child: SizedBox(
        width: double.infinity,
        child: subtitle == null
            ? Text(
                widget.label(value),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label(value),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: foreground.withValues(alpha: 0.8)),
                  ),
                ],
              ),
      ),
    );
  }
}

void fitFlowDashboardToViewport(
  Dashboard dashboard,
  Size viewport, {
  bool includeCurveBounds = false,
}) {
  if (dashboard.elements.isEmpty ||
      viewport.width <= 0 ||
      viewport.height <= 0) {
    return;
  }

  const margin = 28.0;
  final availableWidth = viewport.width - margin * 2;
  final availableHeight = viewport.height - margin * 2;
  if (availableWidth <= 0 || availableHeight <= 0) return;

  Rect? bounds = _flowBounds(dashboard, includeCurveBounds: includeCurveBounds);
  if (bounds == null || bounds.width <= 0 || bounds.height <= 0) return;

  final currentScale = dashboard.zoomFactor;
  final scale =
      (currentScale *
              math.min(
                availableWidth / bounds.width,
                availableHeight / bounds.height,
              ))
          .clamp(dashboard.minimumZoomFactor, 1.12);
  final center = Offset(viewport.width / 2, viewport.height / 2);
  dashboard.setZoomFactor(scale, focalPoint: center);

  bounds = _flowBounds(dashboard, includeCurveBounds: includeCurveBounds);
  if (bounds == null) return;
  final translation = center - bounds.center;
  for (final element in dashboard.elements) {
    element.changePosition(element.position + translation);
    for (final connection in element.next) {
      for (final pivot in connection.pivots) {
        pivot.pivot += translation;
      }
    }
  }
  dashboard.gridBackgroundParams.offset = translation;
}

Rect? _flowBounds(Dashboard dashboard, {required bool includeCurveBounds}) {
  Rect? bounds;
  void include(Offset point) {
    final pointBounds = Rect.fromCenter(center: point, width: 1, height: 1);
    bounds = bounds == null
        ? pointBounds
        : bounds!.expandToInclude(pointBounds);
  }

  for (final element in dashboard.elements) {
    final elementBounds = Rect.fromLTWH(
      element.position.dx,
      element.position.dy,
      element.size.width + element.handlerSize,
      element.size.height + element.handlerSize,
    );
    bounds = bounds == null
        ? elementBounds
        : bounds!.expandToInclude(elementBounds);
    for (final connection in element.next) {
      final params = connection.arrowParams;
      final destination = dashboard.findElementById(connection.destElementId);
      if (includeCurveBounds &&
          params.style == ArrowStyle.curve &&
          destination != null) {
        final from = element.getHandlerPosition(params.startArrowPosition);
        final to = destination.getHandlerPosition(params.endArrowPosition);
        final distance = (to - from).distance / 3;
        Offset directedOffset(Alignment alignment) =>
            Offset(alignment.x.sign * distance, alignment.y.sign * distance);
        final firstControl = from + directedOffset(params.startArrowPosition);
        final thirdControl = params.endArrowPosition == Alignment.center
            ? to
            : to + directedOffset(params.endArrowPosition);
        final secondControl = Offset(
          (firstControl.dx + thirdControl.dx) / 2,
          (firstControl.dy + thirdControl.dy) / 2,
        );
        include(firstControl);
        include(secondControl);
        include(thirdControl);
      }
      for (final pivot in connection.pivots) {
        include(pivot.pivot);
      }
    }
  }
  return bounds;
}

class ExpressiveFlowEditorHeader extends StatelessWidget {
  const ExpressiveFlowEditorHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onManageActions,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onManageActions;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppExpressivePlanningTokens.maybeOf(context)!;
    final strings = AppLocalizations.of(context);

    Widget heading({required bool inline}) => Semantics(
      header: true,
      label: '$title. $subtitle',
      child: ExcludeSemantics(
        child: Text(
          title,
          maxLines: inline ? 2 : null,
          overflow: inline ? TextOverflow.ellipsis : null,
          style:
              (inline
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: tokens.onPage,
                  ),
        ),
      ),
    );

    Widget actions() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: strings.flowManageActionsTooltip,
          style: IconButton.styleFrom(
            backgroundColor: tokens.actionSecondary,
            foregroundColor: tokens.actionSecondaryForeground,
          ),
          onPressed: onManageActions,
          icon: const Icon(Icons.tune_outlined),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: tokens.actionPrimary,
            foregroundColor: tokens.actionPrimaryForeground,
          ),
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(strings.commonSave),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleRow =
            constraints.maxWidth >= 390 &&
            MediaQuery.textScalerOf(context).scale(18) <= 21.6;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            10,
            useSingleRow ? 4 : 8,
            16,
            useSingleRow ? 4 : 6,
          ),
          child: useSingleRow
              ? Row(
                  children: [
                    IconButton(
                      tooltip: strings.commonBack,
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: heading(inline: true)),
                    const SizedBox(width: 4),
                    actions(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: strings.commonBack,
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        actions(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 2),
                      child: heading(inline: false),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class ExpressiveFlowEditorWorkspace extends StatelessWidget {
  const ExpressiveFlowEditorWorkspace({
    super.key,
    required this.controls,
    required this.graph,
  });

  final Widget controls;
  final Widget graph;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      final minimumGraphHeight = math.min(
        200.0,
        math.max(100.0, height * 0.28),
      );
      final maximumControlsHeight = math.min(
        height * 0.68,
        math.max(0.0, height - minimumGraphHeight),
      );
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maximumControlsHeight),
            child: SingleChildScrollView(
              key: const PageStorageKey('expressive-flow-editor-controls'),
              padding: const EdgeInsets.only(bottom: 16),
              child: controls,
            ),
          ),
          Expanded(child: graph),
        ],
      );
    },
  );
}

class FlowEditorFitToViewButton extends StatelessWidget {
  const FlowEditorFitToViewButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppExpressivePlanningTokens.maybeOf(context)!;
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton.filledTonal(
        key: const ValueKey('flow-fit-to-view'),
        tooltip: AppLocalizations.of(context).flowFitToViewTooltip,
        style: IconButton.styleFrom(
          backgroundColor: tokens.actionSecondary,
          foregroundColor: tokens.actionSecondaryForeground,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.fit_screen_outlined),
      ),
    );
  }
}

class FlowEditorGuidance extends StatelessWidget {
  const FlowEditorGuidance({
    super.key,
    required this.text,
    required this.foreground,
  });

  final String text;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 2),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foreground),
    ),
  );
}

ShapeBorder flowEditorTileShape(BorderRadius radius) =>
    RoundedRectangleBorder(borderRadius: radius);

class FlowEditorManageActionsList extends StatelessWidget {
  const FlowEditorManageActionsList({
    super.key,
    required this.methods,
    required this.typeLabel,
    required this.onDelete,
    required this.onAdd,
  });

  final List<FlowMethod> methods;
  final String Function(FlowMethod method) typeLabel;
  final ValueChanged<FlowMethod> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final availableHeight =
        screenSize.height - MediaQuery.viewInsetsOf(context).vertical;
    final maxHeight = availableHeight * 0.62;
    final contentWidth = math.min(420.0, math.max(0.0, screenSize.width - 56));
    return SizedBox(
      width: contentWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: methods.length + 1,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == methods.length) {
              return ListTile(
                minTileHeight: 52,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.add),
                title: Text(strings.flowAddNewMethod),
                onTap: onAdd,
              );
            }
            final method = methods[index];
            return ListTile(
              minTileHeight: 56,
              visualDensity: VisualDensity.compact,
              title: Text(
                method.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                typeLabel(method),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: strings.commonDelete,
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(method),
              ),
            );
          },
        ),
      ),
    );
  }
}
