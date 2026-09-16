import 'package:flutter/material.dart';

import '../theme_extensions.dart';
import '../tokens/app_surface_decoration_tokens.dart';

/// A theme-driven modal-sheet surface for feature content.
class TonosSheet extends StatelessWidget {
  const TonosSheet({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.closeTooltip,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
    this.showHandle = true,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final String? closeTooltip;
  final EdgeInsetsGeometry padding;
  final bool showHandle;

  /// Presents [builder] inside a theme-driven modal sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    String? closeTooltip,
    bool isScrollControlled = false,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      builder:
          (sheetContext) => TonosSheet(
            title: title,
            closeTooltip: closeTooltip,
            onClose: () => Navigator.of(sheetContext).pop(),
            child: builder(sheetContext),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final decoration = context.surfaceDecorationTokens.forRole(
      AppSurfaceDecorationRole.sheet,
    );
    final sheetShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: shapes.sheet.topLeft,
        topRight: shapes.sheet.topRight,
      ),
      side:
          decoration.outlined
              ? BorderSide(
                color: tonosOutlineForSurface(
                  context,
                  surfaces.sheet,
                  neutral: true,
                ),
                width: shapes.outlineWidth,
              )
              : BorderSide.none,
    );
    final elevation = switch (decoration.depth) {
      AppSurfaceDepth.materialElevation => effects.sheetElevation,
      AppSurfaceDepth.none || AppSurfaceDepth.explicitShadow => 0.0,
    };
    final shadow = switch (decoration.depth) {
      AppSurfaceDepth.explicitShadow => BoxShadow(
        color: effects.cardShadow,
        blurRadius: effects.cardShadowBlur,
        offset: effects.raisedPanelShadowOffset,
      ),
      AppSurfaceDepth.none || AppSurfaceDepth.materialElevation => null,
    };

    Widget sheet = Material(
      color: surfaces.sheet,
      elevation: elevation,
      shadowColor: effects.shadowColor,
      shape: sheetShape,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHandle)
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant,
                      borderRadius: shapes.compact,
                    ),
                  ),
                ),
              if (showHandle && title != null) const SizedBox(height: 12),
              if (title != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(title!, style: theme.textTheme.titleLarge),
                    ),
                    if (onClose != null)
                      IconButton(
                        tooltip: closeTooltip,
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              if (title != null) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
    if (shadow != null && _hasVisibleShadow(shadow)) {
      sheet = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: sheetShape.borderRadius,
          boxShadow: [shadow],
        ),
        child: sheet,
      );
    }
    return sheet;
  }
}

bool _hasVisibleShadow(BoxShadow shadow) {
  return shadow.color.a > 0 &&
      (shadow.blurRadius > 0 ||
          shadow.spreadRadius != 0 ||
          shadow.offset != Offset.zero);
}
