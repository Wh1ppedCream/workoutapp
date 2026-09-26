import 'package:flutter/material.dart';

import '../theme_extensions.dart';
import 'tonos_action_depth.dart';

/// Semantic Material action recipes used by Tonos feature surfaces.
enum TonosActionVariant { primary, tonal, outlined, destructive, text }

/// A theme-driven action that keeps standard button behavior in one place.
///
/// Most variants defer their appearance to the active Material button theme.
/// The destructive variant adds only the semantic negative roles supplied by
/// the active theme. Feature widgets provide intent and callbacks without
/// supplying colors, shapes, or arbitrary button styles.
class TonosAction extends StatelessWidget {
  const TonosAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TonosActionVariant.primary,
    this.icon,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
    this.expand = false,
    this.tooltip,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final TonosActionVariant variant;
  final Widget? icon;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool expand;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget action = switch (variant) {
      TonosActionVariant.primary => _buildFilledButton(),
      TonosActionVariant.tonal => _buildTonalButton(),
      TonosActionVariant.outlined => _buildOutlinedButton(),
      TonosActionVariant.destructive => _buildDestructiveButton(context),
      TonosActionVariant.text => _buildTextButton(),
    };

    if (expand) {
      action = SizedBox(width: double.infinity, child: action);
    }
    action = tonosWithPrimaryActionDepth(
      context,
      action,
      enabled:
          variant == TonosActionVariant.primary &&
          (onPressed != null || onLongPress != null),
    );
    if (tooltip != null) {
      action = Tooltip(message: tooltip!, child: action);
    }
    if (semanticLabel != null) {
      action = Semantics(label: semanticLabel, child: action);
    }
    return action;
  }

  Widget _buildFilledButton() {
    final buttonLabel = Text(label);
    if (icon == null) {
      return FilledButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus,
        child: buttonLabel,
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: icon!,
      label: buttonLabel,
    );
  }

  Widget _buildTonalButton() {
    final buttonLabel = Text(label);
    if (icon == null) {
      return FilledButton.tonal(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus,
        child: buttonLabel,
      );
    }
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: icon!,
      label: buttonLabel,
    );
  }

  Widget _buildOutlinedButton() {
    final buttonLabel = Text(label);
    if (icon == null) {
      return OutlinedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus,
        child: buttonLabel,
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: icon!,
      label: buttonLabel,
    );
  }

  Widget _buildDestructiveButton(BuildContext context) {
    final buttonLabel = Text(label);
    final style = _destructiveStyle(context);
    if (icon == null) {
      return FilledButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus,
        style: style,
        child: buttonLabel,
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus,
      style: style,
      icon: icon!,
      label: buttonLabel,
    );
  }

  Widget _buildTextButton() {
    final buttonLabel = Text(label);
    if (icon == null) {
      return TextButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus,
        child: buttonLabel,
      );
    }
    return TextButton.icon(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: icon!,
      label: buttonLabel,
    );
  }

  ButtonStyle _destructiveStyle(BuildContext context) {
    final colors = context.semanticColors;
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled)
                ? colors.disabledContainer
                : colors.negative,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled)
                ? colors.disabledContent
                : colors.onNegative,
      ),
    );
  }
}
