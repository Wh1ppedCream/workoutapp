import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Updates owned diagram paint without rebuilding user-edited graph objects.
void updateFlowDiagramPresentation({
  required Iterable<FlowElement> nodes,
  required String rootId,
  required Color success,
  required Color failure,
  required Color loopback,
  Color? background,
  Color? border,
  Color? text,
}) {
  for (final node in nodes) {
    if (background != null && node.backgroundColor != background) {
      node.setBackgroundColor(background);
    }
    if (border != null && node.borderColor != border) {
      node.setBorderColor(border);
    }
    if (text != null && node.textColor != text) {
      node.setTextColor(text);
    }
    for (var index = 0; index < node.next.length; index++) {
      final connection = node.next[index];
      final arrow = connection.arrowParams;
      final color =
          connection.destElementId == rootId
              ? loopback
              : arrow.style == ArrowStyle.segmented
              ? success
              : failure;
      if (arrow.color == color) continue;
      // Package copyWith omits head/tail dimensions, including zoomed values.
      node.next[index] = ConnectionParams(
        destElementId: connection.destElementId,
        pivots: connection.pivots,
        arrowParams: ArrowParams(
          color: color,
          thickness: arrow.thickness,
          headRadius: arrow.headRadius,
          tailLength: arrow.tailLength,
          style: arrow.style,
          tension: arrow.tension,
          startArrowPosition: arrow.startArrowPosition,
          endArrowPosition: arrow.endArrowPosition,
        ),
      );
    }
  }
}
