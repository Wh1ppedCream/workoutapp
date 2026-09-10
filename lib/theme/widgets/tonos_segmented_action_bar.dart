import 'package:flutter/material.dart';

import '../theme_extensions.dart';

/// One semantic action rendered by [TonosSegmentedActionBar].
@immutable
class TonosActionBarItem {
  const TonosActionBarItem({
    required this.label,
    required this.semanticLabel,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.fontSize,
  });

  final String label;
  final String semanticLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final double? fontSize;
}

/// A theme-driven segmented action bar for compact, high-frequency actions.
///
/// The feature supplies semantic colors and callbacks. Shape, clipping,
/// divider treatment, typography, and interaction rendering stay in the
/// shared theme boundary.
class TonosSegmentedActionBar extends StatelessWidget {
  const TonosSegmentedActionBar({
    super.key,
    required this.items,
    this.scale = 1.0,
  }) : assert(items.length > 0);

  final List<TonosActionBarItem> items;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final dividerColor = context.cs.onSurface.withValues(alpha: 0.12);
    final radius =
        BorderRadius.lerp(BorderRadius.zero, shapes.actionBar, scale)!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) _divider(dividerColor),
              Expanded(
                child: _segment(
                  context,
                  item: items[index],
                  borderRadius: _segmentRadius(index, radius),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BorderRadius _segmentRadius(int index, BorderRadius radius) {
    final isFirst = index == 0;
    final isLast = index == items.length - 1;
    return BorderRadius.only(
      topLeft: isFirst ? radius.topLeft : Radius.zero,
      bottomLeft: isFirst ? radius.bottomLeft : Radius.zero,
      topRight: isLast ? radius.topRight : Radius.zero,
      bottomRight: isLast ? radius.bottomRight : Radius.zero,
    );
  }

  Widget _segment(
    BuildContext context, {
    required TonosActionBarItem item,
    required BorderRadius borderRadius,
  }) {
    final theme = Theme.of(context);
    final textStyle = (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: item.foregroundColor,
      fontSize: item.fontSize == null ? null : item.fontSize! * scale,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      button: true,
      label: item.semanticLabel,
      onTap: item.onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: item.backgroundColor,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: item.onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: SizedBox(
                height: 40 * scale,
                child: Center(child: Text(item.label, style: textStyle)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(Color color) =>
      Container(width: scale, height: 40 * scale, color: color);
}
