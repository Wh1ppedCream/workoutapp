import 'package:env_test/models/preset_models.dart';
import 'package:env_test/services/flow_executor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final increase = FlowMethod(
    id: 1,
    presetId: 9,
    name: 'Increase weight',
    type: MethodType.weight,
    params: const {'amount': 5},
  );
  final hold = FlowMethod(
    id: 2,
    presetId: 9,
    name: 'Hold weight',
    type: MethodType.weight,
    params: const {'amount': 0},
  );

  FlowExecutor buildExecutor() => FlowExecutor(
    flowDef: FlowDefinition(
      nodes: const ['first', 'success', 'failure'],
      edges: [
        FlowEdge(from: 'first', outcome: 'success', to: 'success'),
        FlowEdge(from: 'first', outcome: 'failure', to: 'failure'),
        FlowEdge(from: 'success', outcome: 'method', to: increase.name),
        FlowEdge(from: 'failure', outcome: 'method', to: hold.name),
      ],
    ),
    methods: [increase, hold],
  );

  group('FlowExecutor', () {
    test('follows success and returns its attached rules', () {
      final result = buildExecutor().traverse(outcome: true);
      expect(result.nodeKey, 'success');
      expect(result.methods, [increase]);
    });

    test('follows failure and returns its attached rules', () {
      final result = buildExecutor().traverse(outcome: false);
      expect(result.nodeKey, 'failure');
      expect(result.methods, [hold]);
    });

    test('falls back to the root when the saved node has no matching edge', () {
      final result = buildExecutor().traverse(
        lastNodeKey: 'missing-node',
        outcome: false,
      );
      expect(result.nodeKey, 'failure');
      expect(result.methods, [hold]);
    });

    test('ignores missing rule references without failing traversal', () {
      final executor = FlowExecutor(
        flowDef: FlowDefinition(
          nodes: const ['first', 'success'],
          edges: [
            FlowEdge(from: 'first', outcome: 'success', to: 'success'),
            FlowEdge(from: 'success', outcome: 'method', to: 'removed rule'),
          ],
        ),
        methods: const [],
      );

      final result = executor.traverse(outcome: true);
      expect(result.nodeKey, 'success');
      expect(result.methods, isEmpty);
    });
  });
}
