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
    this.labelStyle,
  }) : assert(fontSize == null || labelStyle == null);

  final String label;
  final String semanticLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final double? fontSize;
  final TextStyle? labelStyle;
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
    this.dividerColor,
  }) : assert(items.length > 0);

  final List<TonosActionBarItem> items;
  final double scale;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final resolvedDividerColor =
        dividerColor ?? context.cs.onSurface.withValues(alpha: 0.12);
    final radius =
        BorderRadius.lerp(BorderRadius.zero, shapes.actionBar, scale)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasUnboundedWidth = !constraints.maxWidth.isFinite;
        final stackSegments =
            hasUnboundedWidth || _shouldStack(context, constraints.maxWidth);
        final stackedWidth =
            hasUnboundedWidth ? _naturalStackWidth(context) : null;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child:
                stackSegments
                    ? Column(
                      children: [
                        for (var index = 0; index < items.length; index++) ...[
                          if (index > 0)
                            _divider(
                              resolvedDividerColor,
                              vertical: true,
                              width: stackedWidth,
                            ),
                          SizedBox(
                            width: stackedWidth ?? double.infinity,
                            child: _segment(
                              context,
                              item: items[index],
                              borderRadius: _segmentRadius(
                                index,
                                radius,
                                vertical: true,
                              ),
                              allowWrapping: true,
                            ),
                          ),
                        ],
                      ],
                    )
                    : Row(
                      children: [
                        for (var index = 0; index < items.length; index++) ...[
                          if (index > 0) _divider(resolvedDividerColor),
                          Expanded(
                            child: _segment(
                              context,
                              item: items[index],
                              borderRadius: _segmentRadius(index, radius),
                              allowWrapping: false,
                            ),
                          ),
                        ],
                      ],
                    ),
          ),
        );
      },
    );
  }

  bool _shouldStack(BuildContext context, double maxWidth) {
    final media = MediaQuery.of(context);
    if (!maxWidth.isFinite) return false;

    final totalDividerWidth = (items.length - 1) * scale;
    final segmentWidth =
        (maxWidth - 32 * scale - totalDividerWidth) / items.length;
    if (segmentWidth <= 0) return true;

    final textDirection = Directionality.of(context);
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final locale = Localizations.maybeLocaleOf(context);
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: inheritedStyle.merge(_textStyle(context, item)),
        ),
        textDirection: textDirection,
        locale: locale,
        textScaler: media.textScaler,
        maxLines: 1,
      )..layout(maxWidth: segmentWidth);
      final exceedsWidth = painter.didExceedMaxLines;
      final exceedsHeight = painter.height > 40 * scale;
      painter.dispose();
      if (exceedsWidth || exceedsHeight) return true;
    }
    return false;
  }

  double _naturalStackWidth(BuildContext context) {
    final media = MediaQuery.of(context);
    final textDirection = Directionality.of(context);
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final locale = Localizations.maybeLocaleOf(context);
    var widestLabel = 0.0;

    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: inheritedStyle.merge(_textStyle(context, item)),
        ),
        textDirection: textDirection,
        locale: locale,
        textScaler: media.textScaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widestLabel) widestLabel = painter.width;
      painter.dispose();
    }

    return widestLabel + 24 * scale;
  }

  BorderRadius _segmentRadius(
    int index,
    BorderRadius radius, {
    bool vertical = false,
  }) {
    final isFirst = index == 0;
    final isLast = index == items.length - 1;
    if (vertical) {
      return BorderRadius.only(
        topLeft: isFirst ? radius.topLeft : Radius.zero,
        topRight: isFirst ? radius.topRight : Radius.zero,
        bottomLeft: isLast ? radius.bottomLeft : Radius.zero,
        bottomRight: isLast ? radius.bottomRight : Radius.zero,
      );
    }
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
    required bool allowWrapping,
  }) {
    final textStyle = _textStyle(context, item);
    final label = Text(
      item.label,
      textAlign: allowWrapping ? TextAlign.center : null,
      style: textStyle,
    );
    final labelBox =
        allowWrapping
            ? ConstrainedBox(
              constraints: BoxConstraints(minHeight: 40 * scale),
              child: Center(child: label),
            )
            : SizedBox(height: 40 * scale, child: Center(child: label));

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
              child: labelBox,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(BuildContext context, TonosActionBarItem item) {
    final labelStyle = item.labelStyle;
    if (labelStyle != null) {
      return labelStyle.copyWith(color: item.foregroundColor);
    }
    final baseStyle =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    return baseStyle.copyWith(
      color: item.foregroundColor,
      fontSize: item.fontSize == null ? null : item.fontSize! * scale,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _divider(Color color, {bool vertical = false, double? width}) =>
      vertical
          ? Container(
            height: scale,
            width: width ?? double.infinity,
            color: color,
          )
          : Container(width: scale, height: 40 * scale, color: color);
}
