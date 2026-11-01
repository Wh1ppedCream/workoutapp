import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/preset_models.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../../theme/widgets/tonos_expressive_motion.dart';
import '../../../../theme/widgets/tonos_expressive_state_motion.dart';

enum AddSetMode { explicit, copy }

Widget buildRuleAddSetModeOptions(
  BuildContext context, {
  required AddSetMode selected,
  required ValueChanged<AddSetMode> onChanged,
  bool expressiveSelectionGroup = false,
}) {
  final strings = AppLocalizations.of(context);
  if (expressiveSelectionGroup) {
    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final outline = tokens.outlineAccent.withValues(alpha: 0.38);
    Widget segment(AddSetMode value, String label, String keyName) {
      final isSelected = selected == value;
      final foreground = isSelected
          ? tokens.onSurfaceSelected
          : tokens.onSurfaceTertiary;
      return Expanded(
        child: Semantics(
          key: ValueKey<String>(keyName),
          button: true,
          selected: isSelected,
          inMutuallyExclusiveGroup: true,
          label: label,
          onTap: () => onChanged(value),
          child: ExcludeSemantics(
            child: Material(
              color: isSelected ? tokens.surfaceSelected : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? tokens.actionPrimary : Colors.transparent,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(value),
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceTertiary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          segment(
            AddSetMode.explicit,
            strings.flowExplicit,
            'plan-rule-add-set-explicit',
          ),
          segment(AddSetMode.copy, strings.rulesCopy, 'plan-rule-add-set-copy'),
        ],
      ),
    );
  }

  Radio<AddSetMode> option(AddSetMode value) => Radio<AddSetMode>(value: value);

  Widget choice(AddSetMode value, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      option(value),
      Flexible(child: Text(label, softWrap: true)),
    ],
  );

  final expressive = context.usesExpressivePresentation;
  if (expressive) {
    return RadioGroup<AddSetMode>(
      groupValue: selected,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          choice(AddSetMode.explicit, strings.flowExplicit),
          choice(AddSetMode.copy, strings.rulesCopy),
        ],
      ),
    );
  }

  return RadioGroup<AddSetMode>(
    groupValue: selected,
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
    child: OverflowBar(
      children: [
        choice(AddSetMode.explicit, strings.flowExplicit),
        choice(AddSetMode.copy, strings.rulesCopy),
      ],
    ),
  );
}

String flowMethodTypeLabel(MethodType type, AppLocalizations strings) {
  return switch (type) {
    MethodType.weight => strings.flowMethodWeight,
    MethodType.rep => strings.flowMethodReps,
    MethodType.addSet => strings.flowMethodAddSet,
    MethodType.delSet => strings.flowMethodDeleteSet,
  };
}

/// Field-anchored single-choice menu scoped to the Expressive Flow Methods
/// dialogs. Classic and Neo continue using their existing dropdown controls.
class FlowMethodsChoiceField<T> extends StatefulWidget {
  const FlowMethodsChoiceField({
    super.key,
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.onChanged,
    required this.nonExpressiveButton,
    this.planRuleStyle = false,
    this.scrollFieldIntoUpperArea = false,
  });

  final String title;
  final List<T> values;
  final T value;
  final String Function(T value) label;
  final ValueChanged<T?>? onChanged;
  final Widget Function() nonExpressiveButton;
  final bool planRuleStyle;
  final bool scrollFieldIntoUpperArea;

  @override
  State<FlowMethodsChoiceField<T>> createState() =>
      _FlowMethodsChoiceFieldState<T>();
}

class _FlowMethodsChoiceFieldState<T> extends State<FlowMethodsChoiceField<T>> {
  final GlobalKey _fieldKey = GlobalKey(debugLabel: 'Flow Methods choice');
  late final FocusNode _focusNode;
  bool _menuOpen = false;
  bool _fieldWidthMeasurementScheduled = false;
  double? _fieldWidth;
  double? _menuHeight;
  double _menuOffset = 0;

  Rect? _globalBounds(GlobalKey? key) {
    final renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  Future<void> _toggleMenu(MenuController controller) async {
    if (controller.isOpen) {
      controller.close();
      return;
    }
    if (!widget.planRuleStyle) {
      controller.open();
      return;
    }

    if (widget.scrollFieldIntoUpperArea) {
      final fieldContext = _fieldKey.currentContext;
      if (fieldContext != null) {
        await Scrollable.ensureVisible(
          fieldContext,
          alignment: 0.2,
          duration: Duration.zero,
        );
        await WidgetsBinding.instance.endOfFrame;
      }
      if (!mounted) return;
    }

    final field = _globalBounds(_fieldKey);
    if (field == null) return;
    final media = MediaQuery.of(context);
    final bottom =
        media.size.height - media.padding.bottom - media.viewInsets.bottom - 12;
    final below = math.max(0.0, bottom - field.bottom - 4);
    final style = Theme.of(context).textTheme.bodyLarge!
        .copyWith(fontWeight: FontWeight.w600);
    var desiredHeight = 14.0;
    for (final value in widget.values) {
      final painter = TextPainter(
        text: TextSpan(text: widget.label(value), style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 2,
      )..layout(maxWidth: math.max(1, field.width - 72));
      desiredHeight += math.max(48.0, painter.height + 8);
      painter.dispose();
    }
    final height = math.min(desiredHeight, below);
    setState(() {
      _fieldWidth = field.width;
      _menuHeight = height;
      _menuOffset = 4;
    });
    // MenuAnchor reads the new bounds before its overlay is inserted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.open();
    });
  }

  double? _renderedFieldWidth() {
    final renderObject = _fieldKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }
    return null;
  }

  void _scheduleFieldWidthMeasurement() {
    if (_fieldWidthMeasurementScheduled) return;
    _fieldWidthMeasurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fieldWidthMeasurementScheduled = false;
      if (!mounted) return;
      final width = _renderedFieldWidth();
      if (width == null ||
          (_fieldWidth != null && (_fieldWidth! - width).abs() < 0.5)) {
        return;
      }
      setState(() => _fieldWidth = width);
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Workout progress rule choice');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) {
      return widget.nonExpressiveButton();
    }

    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final enabled = widget.onChanged != null && widget.values.isNotEmpty;
    final valueLabel = widget.label(widget.value);
    final decorationTheme = theme.inputDecorationTheme;
    final fieldBorder =
        decorationTheme.enabledBorder ??
        decorationTheme.border ??
        decorationTheme.focusedBorder;
    final fieldRadius = fieldBorder is OutlineInputBorder
        ? fieldBorder.borderRadius
        : context.shapeTokens.settingsInput;
    final screenSize = MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final dialogInsets =
        theme.dialogTheme.insetPadding ??
        const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    final configuredDialogMaxWidth =
        theme.dialogTheme.constraints?.maxWidth ?? 560.0;
    final dialogMaxWidth = configuredDialogMaxWidth.isFinite
        ? configuredDialogMaxWidth
        : screenSize.width - dialogInsets.horizontal;
    final fallbackWidth = math.max(
      0.0,
      math.min(
        screenSize.width -
            mediaQuery.padding.horizontal -
            dialogInsets.horizontal -
            48,
        dialogMaxWidth - 48,
      ),
    );
    final viewportMenuMaxHeight = math.max(
      0.0,
      screenSize.height -
          mediaQuery.padding.vertical -
          mediaQuery.viewInsets.vertical -
          dialogInsets.vertical * 2,
    );
    final menuMaxHeight = widget.planRuleStyle
        ? math.min(_menuHeight ?? 206, viewportMenuMaxHeight)
        : viewportMenuMaxHeight;
    _scheduleFieldWidthMeasurement();
    final width = _fieldWidth ?? fallbackWidth;

    return MenuAnchor(
      key: ValueKey<String>('rules-choice-${widget.title}'),
      useRootOverlay: true,
      consumeOutsideTap: true,
      crossAxisUnconstrained: false,
      childFocusNode: _focusNode,
      alignmentOffset: Offset(0, widget.planRuleStyle ? _menuOffset : 0),
      onOpen: () {
        final fieldWidth = _renderedFieldWidth();
        if (mounted) {
          setState(() {
            _menuOpen = true;
            if (fieldWidth != null) _fieldWidth = fieldWidth;
          });
        }
      },
      onClose: () {
        if (mounted) setState(() => _menuOpen = false);
      },
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        backgroundColor: WidgetStatePropertyAll(tokens.surfaceTertiary),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(2),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: widget.planRuleStyle
                ? tokens.outlineAccent.withValues(alpha: 0.5)
                : tokens.outlineAccent,
            width: 1,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: ExpressiveTrainShapes.focusInset,
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        maximumSize: WidgetStatePropertyAll(Size(width, menuMaxHeight)),
      ),
      menuChildren: [
        TonosExpressiveReveal(
          enabled: TonosExpressiveStateMotion.enabled(context),
          duration: const Duration(milliseconds: 160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < widget.values.length; index++)
                _menuItem(context, tokens, index),
            ],
          ),
        ),
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
          value: valueLabel,
          onTap: enabled ? () => unawaited(_toggleMenu(controller)) : null,
          child: ExcludeSemantics(
            child: InkWell(
              focusNode: _focusNode,
              canRequestFocus: enabled,
              borderRadius: fieldRadius,
              onTap: enabled ? () => unawaited(_toggleMenu(controller)) : null,
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (_) {
                  _scheduleFieldWidthMeasurement();
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: InputDecorator(
                    key: _fieldKey,
                    decoration: InputDecoration(
                      labelText: widget.planRuleStyle ? null : widget.title,
                      enabled: enabled,
                      suffixIcon: AnimatedRotation(
                        turns: widget.planRuleStyle && _menuOpen ? 0.5 : 0,
                        duration: TonosExpressiveStateMotion.duration(
                          context,
                          TonosExpressiveStateMotion.fast,
                        ),
                        curve: TonosExpressiveStateMotion.spatial,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: tokens.supportingForeground,
                        ),
                      ),
                    ),
                    isFocused: _focusNode.hasFocus || _menuOpen,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TonosExpressiveChangePulse(
                        value: widget.value,
                        scale: 1.015,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          valueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    AppExpressiveDestinationTokens tokens,
    int index,
  ) {
    final value = widget.values[index];
    final selected = value == widget.value;
    final foreground = selected
        ? tokens.onSurfaceSelected
        : tokens.onSurfaceTertiary;
    final background = selected
        ? tokens.surfaceSelected
        : tokens.surfaceTertiary;
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: MenuItemButton(
          key: ValueKey<int>(index),
          onPressed: () => widget.onChanged?.call(value),
          style: ButtonStyle(
            alignment: AlignmentDirectional.centerStart,
            foregroundColor: WidgetStatePropertyAll(foreground),
            backgroundColor: WidgetStatePropertyAll(background),
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            tapTargetSize: widget.planRuleStyle
                ? MaterialTapTargetSize.shrinkWrap
                : null,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.focusInset,
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: foreground,
                fontWeight: selected && !widget.planRuleStyle
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
          trailingIcon: widget.planRuleStyle
              ? SizedBox(
                  width: 20,
                  child: selected
                      ? Icon(Icons.check, size: 18, color: foreground)
                      : null,
                )
              : selected
              ? Icon(Icons.check, color: foreground)
              : null,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.label(value),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
