import 'dart:convert';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a restored workout cannot be overwritten by a new plan', () async {
    final repository = _FakeAppRepository(
      draft: {
        'started_at':
            DateTime.now()
                .subtract(const Duration(minutes: 5))
                .toUtc()
                .toIso8601String(),
        'auto_preset_id': 12,
        'payload_json': jsonEncode({
          'version': 1,
          'exercises': [
            {
              'type': 'weight',
              'name': 'Saved Squat',
              'equipment': 'Barbell',
              'sets': [
                {'weight': 135, 'reps': 5},
              ],
            },
          ],
        }),
      },
    );
    final session = ActiveSession(repository: repository);
    addTearDown(session.dispose);
    await session.ready;

    final started = await session.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: 'New Bench Press',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 95, reps: 8)],
        ),
      ],
      workoutCardTypes: const [CardType.weight],
      presetId: 99,
    );

    expect(started, isFalse);
    expect(session.exercises.single.name, 'Saved Squat');
    expect(repository.saveCount, 0);
  });

  test(
    'starting a workout writes its first durable draft immediately',
    () async {
      final repository = _FakeAppRepository();
      final session = ActiveSession(repository: repository);
      addTearDown(session.dispose);
      await session.ready;

      final started = await session.startWithExercises(
        workoutExercises: [
          WeightExercise(
            name: 'Bench Press',
            equipment: 'Barbell',
            sets: [ExerciseSet(weight: 95, reps: 8)],
          ),
        ],
        workoutCardTypes: const [CardType.weight],
        presetId: 7,
      );

      expect(started, isTrue);
      expect(repository.saveCount, 1);
      expect(repository.draft?['auto_preset_id'], 7);
      expect(repository.draft?['payload_json'], contains('Bench Press'));
    },
  );

  test('finishing without completed work keeps the workout active', () async {
    final repository = _FakeAppRepository();
    final session = ActiveSession(repository: repository);
    addTearDown(session.dispose);
    await session.ready;
    await session.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: 'Bench Press',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 95, reps: 8)],
        ),
      ],
      workoutCardTypes: const [CardType.weight],
    );

    expect(await session.finish(), isNull);
    expect(session.isActive, isTrue);
    expect(repository.completionCount, 0);
    expect(repository.draft, isNotNull);
  });
}

class _FakeAppRepository extends AppRepository {
  _FakeAppRepository({this.draft});

  Map<String, dynamic>? draft;
  int saveCount = 0;
  int completionCount = 0;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => draft;

  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    saveCount++;
    draft = {
      'started_at': startedAt.toUtc().toIso8601String(),
      'auto_preset_id': autoPresetId,
      'payload_json': payloadJson,
    };
  }

  @override
  Future<int> completeWorkoutAtomic({
    required DateTime completedAt,
    required int durationSeconds,
    required List<WorkoutExerciseWrite> exercises,
  }) async {
    completionCount++;
    return 1;
  }

  @override
  Future<void> clearActiveWorkoutDraft() async {
    draft = null;
  }
}
