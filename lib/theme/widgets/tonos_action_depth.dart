import 'package:flutter/material.dart';

import '../theme_extensions.dart';

/// Applies the shared Neo primary-action depth without replacing the button.
///
/// The button remains responsible for interaction, focus, semantics, and
/// state colors. Depth is painted by the button's Material shape, not its
/// larger padded touch target.
Widget tonosWithPrimaryActionDepth(
  BuildContext context,
  Widget child, {
  required bool enabled,
  BorderRadiusGeometry? borderRadius,
}) {
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return child;
  }

  final effects = context.effectTokens;
  final hasDepth =
      enabled &&
      effects.cardShadow.a > 0 &&
      effects.primaryActionShadowOffset != Offset.zero;

  final theme = Theme.of(context);
  ButtonStyle withDepth(ButtonStyle? style) {
    final base = style ?? const ButtonStyle();
    if (!hasDepth) return base;
    return base.copyWith(
      shape: WidgetStateProperty.resolveWith((states) {
        final border =
            base.shape?.resolve(states) ??
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? context.shapeTokens.control,
            );
        if (states.contains(WidgetState.disabled)) return border;
        return TonosActionShadowBorder(
          border: border,
          color: effects.cardShadow,
          offset: effects.primaryActionShadowOffset,
        );
      }),
    );
  }

  return Theme(
    data: theme.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: withDepth(theme.filledButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: withDepth(theme.elevatedButtonTheme.style),
      ),
    ),
    child: child,
  );
}

/// An outline that adds only the exposed hard offset to the Material surface.
/// ButtonStyle can still replace its side for focus and disabled states.
class TonosActionShadowBorder extends OutlinedBorder {
  TonosActionShadowBorder({
    required this.border,
    required this.color,
    required this.offset,
  }) : super(side: border.side);

  final OutlinedBorder border;
  final Color color;
  final Offset offset;

  @override
  EdgeInsetsGeometry get dimensions => border.dimensions;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      border.getOuterPath(rect, textDirection: textDirection);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      border.getInnerPath(rect, textDirection: textDirection);

  Path shadowPath(Rect rect, {TextDirection? textDirection}) {
    final path = getOuterPath(rect, textDirection: textDirection);
    return Path.combine(PathOperation.difference, path.shift(offset), path);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      shadowPath(rect, textDirection: textDirection),
      Paint()..color = color,
    );
    border.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  TonosActionShadowBorder copyWith({BorderSide? side}) =>
      TonosActionShadowBorder(
        border: border.copyWith(side: side),
        color: color,
        offset: offset,
      );

  @override
  OutlinedBorder scale(double t) => TonosActionShadowBorder(
    border: border.scale(t) as OutlinedBorder,
    color: color,
    offset: offset * t,
  );
}
