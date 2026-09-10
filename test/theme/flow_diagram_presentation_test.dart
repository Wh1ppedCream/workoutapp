import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/flow_diagram_presentation.dart';

void main() {
  test('theme refresh preserves graph geometry and connection routing', () {
    final root = FlowElement(
      position: const Offset(34, 56),
      size: const Size(90, 40),
      text: 'edited root',
    );
    final child = FlowElement(
      position: const Offset(140, 180),
      size: const Size(60, 30),
    );
    final branch = ConnectionParams(
      destElementId: child.id,
      arrowParams: ArrowParams(
        color: Colors.black,
        style: ArrowStyle.segmented,
        thickness: 4,
        headRadius: 9,
        tailLength: 42,
        tension: 0.6,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    )..dissect(const Offset(70, 100));
    root.next.add(branch);
    root.next.add(
      ConnectionParams(
        destElementId: child.id,
        arrowParams: ArrowParams(style: ArrowStyle.curve),
      ),
    );
    child.next.add(
      ConnectionParams(
        destElementId: root.id,
        arrowParams: ArrowParams(style: ArrowStyle.curve),
      ),
    );
    final rootId = root.id;
    final rootPosition = root.position;
    final rootSize = root.size;
    final childPosition = child.position;
    final childSize = child.size;

    void refresh() => updateFlowDiagramPresentation(
      nodes: [root, child],
      rootId: rootId,
      success: Colors.blue,
      failure: Colors.orange,
      loopback: Colors.purple,
      background: Colors.white,
      border: Colors.grey,
      text: Colors.black,
    );
    refresh();
    expect(root.id, rootId);
    expect(root.text, 'edited root');
    expect(root.position, rootPosition);
    expect(root.size, rootSize);
    expect(child.position, childPosition);
    expect(child.size, childSize);
    expect(root.next, hasLength(2));
    expect(root.next.first.destElementId, child.id);
    expect(root.next.first.pivots, same(branch.pivots));
    final arrow = root.next.first.arrowParams;
    expect(arrow.color, Colors.blue);
    expect(arrow.thickness, 4);
    expect(arrow.headRadius, 9);
    expect(arrow.tailLength, 42);
    expect(arrow.tension, 0.6);
    expect(arrow.startArrowPosition, Alignment.bottomCenter);
    expect(arrow.endArrowPosition, Alignment.topCenter);
    expect(root.next.last.arrowParams.color, Colors.orange);
    expect(child.next.single.arrowParams.color, Colors.purple);
    expect(root.backgroundColor, Colors.white);
    expect(root.borderColor, Colors.grey);
    expect(root.textColor, Colors.black);
    final connection = root.next.first;
    refresh();
    expect(root.next.first, same(connection));
  });
}
