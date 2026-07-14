import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/auto_increment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoIncrementService', () {
    test('matches completed sets by stable preset IDs', () async {
      final repo = _FakeProgressionRepository(
        successScope: ProgressionSuccessScope.set,
        methods: [_weightMethod()],
        presetSets: {
          10: [_presetSet(11, 100, 5, 0), _presetSet(12, 100, 5, 1)],
        },
        exerciseAuto: {
          10: {'last_set_index': 2, 'last_node': null},
        },
        sessionSets: {
          20: [_sessionSet(31, 12, 100, 5, 0)],
        },
      );

      await AutoIncrementService(repo).apply(sessionId: 1, presetId: 1);

      final batch = repo.appliedBatch!;
      expect(_updatedWeight(batch, 11), 100);
      expect(_updatedWeight(batch, 12), 105);
      expect(batch.exerciseStates.single.lastNode, 'success');
    });

    test(
      'exercise scope fails when any planned set was not completed',
      () async {
        final repo = _FakeProgressionRepository(
          successScope: ProgressionSuccessScope.exercise,
          presetSets: {
            10: [_presetSet(11, 100, 5, 0), _presetSet(12, 100, 5, 1)],
          },
          sessionSets: {
            20: [_sessionSet(31, 12, 100, 5, 0)],
          },
        );

        await AutoIncrementService(repo).apply(sessionId: 1, presetId: 1);

        expect(repo.appliedBatch!.exerciseStates.single.lastNode, 'failure');
      },
    );

    test('add-set actions create the configured parent set', () async {
      final repo = _FakeProgressionRepository(
        successScope: ProgressionSuccessScope.set,
        methods: [
          FlowMethod(
            id: 1,
            presetId: 1,
            name: 'Add work set',
            type: MethodType.addSet,
            params: {'weight': 75.0, 'reps': 8},
          ),
        ],
      );

      await AutoIncrementService(repo).apply(sessionId: 1, presetId: 1);

      final insert = repo.appliedBatch!.inserts.single;
      expect(insert.weight, 75);
      expect(insert.reps, 8);
      expect(insert.orderIndex, 1);
    });

    test('delete-set actions never remove the final parent set', () async {
      final repo = _FakeProgressionRepository(
        successScope: ProgressionSuccessScope.set,
        methods: [
          FlowMethod(
            id: 1,
            presetId: 1,
            name: 'Remove work set',
            type: MethodType.delSet,
            params: const {},
          ),
        ],
      );

      await AutoIncrementService(repo).apply(sessionId: 1, presetId: 1);

      expect(repo.appliedBatch!.deletedSetIds, isEmpty);
      expect(repo.appliedBatch!.updates, hasLength(1));
    });

    test('all-set mode still persists the traversed flow node', () async {
      final repo = _FakeProgressionRepository(
        successScope: ProgressionSuccessScope.set,
        adjustAllSets: true,
      );

      await AutoIncrementService(repo).apply(sessionId: 1, presetId: 1);

      final state = repo.appliedBatch!.exerciseStates.single;
      expect(state.lastNode, 'success');
      expect(state.lastSetIndex, 1);
    });
  });
}

FlowMethod _weightMethod() => FlowMethod(
  id: 1,
  presetId: 1,
  name: 'Increase weight',
  type: MethodType.weight,
  params: {'sign': '+', 'factor': 1.0},
);

Map<String, dynamic> _presetSet(
  int id,
  double weight,
  int reps,
  int orderIndex,
) => {
  'id': id,
  'preset_exercise_id': 10,
  'weight': weight,
  'reps': reps,
  'order_index': orderIndex,
  'parent_set_id': null,
};

Map<String, dynamic> _sessionSet(
  int id,
  int sourceSetId,
  double weight,
  int reps,
  int orderIndex,
) => {
  'id': id,
  'exercise_id': 20,
  'weight': weight,
  'reps': reps,
  'order_index': orderIndex,
  'parent_set_id': null,
  'source_preset_set_id': sourceSetId,
};

double? _updatedWeight(PresetProgressionBatch batch, int setId) {
  for (final update in batch.updates) {
    if (update.setId == setId) return update.weight;
  }
  return null;
}

class _FakeProgressionRepository extends AppRepository {
  _FakeProgressionRepository({
    required this.successScope,
    this.methods = const [],
    this.adjustAllSets = false,
    Map<int, List<Map<String, dynamic>>>? presetSets,
    Map<int, Map<String, dynamic>>? exerciseAuto,
    Map<int, List<Map<String, dynamic>>>? sessionSets,
  }) : presetSets =
           presetSets ??
           {
             10: [_presetSet(11, 100, 5, 0)],
           },
       exerciseAuto =
           exerciseAuto ??
           {
             10: {'last_set_index': 1, 'last_node': null},
           },
       sessionSets =
           sessionSets ??
           {
             20: [_sessionSet(31, 11, 100, 5, 0)],
           };

  final ProgressionSuccessScope successScope;
  final List<FlowMethod> methods;
  final bool adjustAllSets;
  final Map<int, List<Map<String, dynamic>>> presetSets;
  final Map<int, Map<String, dynamic>> exerciseAuto;
  final Map<int, List<Map<String, dynamic>>> sessionSets;
  PresetProgressionBatch? appliedBatch;

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async => {
    'preset_id': presetId,
    'is_automatic': 1,
    'global_increment': 5.0,
    'skip_first_set': 0,
    'weight_check': 1,
    'rep_check': 1,
    'volume_check': 0,
    'adjust_all_sets': adjustAllSets ? 1 : 0,
    'use_manual_select': 0,
    'manual_selection_json': '{}',
    'success_count_mode': successScope.name,
  };

  @override
  Future<FlowDefinition> fetchFlowDefinition(int presetId) async =>
      FlowDefinition(
        nodes: ['root', 'success', 'failure'],
        edges: [
          FlowEdge(from: 'root', outcome: 'success', to: 'success'),
          FlowEdge(from: 'root', outcome: 'failure', to: 'failure'),
          for (final method in methods)
            FlowEdge(from: 'success', outcome: 'method', to: method.name),
        ],
      );

  @override
  Future<List<FlowMethod>> fetchFlowMethods(int presetId) async => methods;

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      [
        {'id': 10, 'preset_id': presetId, 'type': 'weight', 'order_index': 0},
      ];

  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async => [
    {
      'id': 20,
      'session_id': sessionId,
      'type': 'weight',
      'order_index': 0,
      'source_preset_exercise_id': 10,
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => presetSets[presetExerciseId] ?? const [];

  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => exerciseAuto[presetExerciseId];

  @override
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) async =>
      sessionSets[exerciseId] ?? const [];

  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async =>
      null;

  @override
  Future<void> applyPresetProgressionBatch(
    PresetProgressionBatch progression,
  ) async {
    appliedBatch = progression;
  }
}
