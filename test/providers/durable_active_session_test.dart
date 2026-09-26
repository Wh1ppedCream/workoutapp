import 'dart:convert';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/durable_active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> noDelay(Duration _) async {}

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

  test('a draft restores after process death', () async {
    final repository = _FakeAppRepository();
    final firstSession = ActiveSession(repository: repository);
    await firstSession.ready;
    await firstSession.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: 'Deadlift',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 225, reps: 5)],
        ),
      ],
      workoutCardTypes: const [CardType.weight],
      presetId: 14,
    );
    firstSession.dispose();

    final restoredSession = ActiveSession(repository: repository);
    addTearDown(restoredSession.dispose);
    await restoredSession.ready;

    expect(restoredSession.exercises.single.name, 'Deadlift');
    expect(restoredSession.isActive, isTrue);
    expect(restoredSession.durabilityIssue, isNull);
  });

  test('draft saves retry transient storage failures', () async {
    final repository = _FakeAppRepository(saveFailuresRemaining: 2);
    final session = ActiveSession(repository: repository, retryDelay: noDelay);
    addTearDown(session.dispose);
    await session.ready;

    expect(await session.start(), isTrue);
    expect(repository.saveCount, 3);
    expect(session.durabilityIssue, isNull);
  });

  test(
    'failed draft save stays visible until a manual retry succeeds',
    () async {
      final repository = _FakeAppRepository(saveFailuresRemaining: 3);
      final session = ActiveSession(
        repository: repository,
        retryDelay: noDelay,
      );
      addTearDown(session.dispose);
      await session.ready;

      expect(await session.start(), isTrue);
      expect(session.durabilityIssue, ActiveSessionDurabilityIssue.draftSave);

      repository.saveFailuresRemaining = 0;
      await session.retryDurability();

      expect(session.durabilityIssue, isNull);
      expect(repository.draft, isNotNull);
    },
  );

  test('failed restore blocks replacement until retry succeeds', () async {
    final repository = _FakeAppRepository(
      draft: _savedDraft('Recovered Row'),
      loadFailuresRemaining: 3,
    );
    final session = ActiveSession(repository: repository, retryDelay: noDelay);
    addTearDown(session.dispose);
    await session.ready;

    expect(session.durabilityIssue, ActiveSessionDurabilityIssue.restore);
    expect(await session.start(), isFalse);

    repository.loadFailuresRemaining = 0;
    await session.retryDurability();

    expect(session.durabilityIssue, isNull);
    expect(session.exercises.single.name, 'Recovered Row');
  });

  test('pending progression survives restart and clears after retry', () async {
    final repository = _FakeAppRepository(
      pendingProgressions: [
        {'session_id': 22, 'preset_id': 7},
      ],
    );
    var progressionFailures = 3;
    final session = ActiveSession(
      repository: repository,
      retryDelay: noDelay,
      progressionRunner: (sessionId, presetId) async {
        if (progressionFailures > 0) {
          progressionFailures--;
          throw StateError('storage unavailable');
        }
        repository.pendingProgressions.removeWhere(
          (job) => job['session_id'] == sessionId,
        );
      },
    );
    addTearDown(session.dispose);
    await session.ready;

    expect(session.durabilityIssue, ActiveSessionDurabilityIssue.progression);
    expect(repository.pendingProgressions, hasLength(1));

    await session.retryDurability();

    expect(session.durabilityIssue, isNull);
    expect(repository.pendingProgressions, isEmpty);
  });

  test('completed workout remains saved when progression fails', () async {
    final repository = _FakeAppRepository();
    final session = ActiveSession(
      repository: repository,
      retryDelay: noDelay,
      progressionRunner: (_, __) async {
        throw StateError('progression write failed');
      },
    );
    addTearDown(session.dispose);
    await session.ready;
    await session.startWithExercises(
      workoutExercises: [
        WeightExercise(
          name: 'Squat',
          equipment: 'Barbell',
          sets: [ExerciseSet(weight: 185, reps: 5)],
          completedParents: {0},
        ),
      ],
      workoutCardTypes: const [CardType.weight],
      presetId: 9,
    );

    expect(await session.finish(), 1);

    expect(repository.completionCount, 1);
    expect(repository.draft, isNull);
    expect(repository.pendingProgressions, hasLength(1));
    expect(session.isActive, isFalse);
    expect(session.durabilityIssue, ActiveSessionDurabilityIssue.progression);
  });
}

Map<String, dynamic> _savedDraft(String exerciseName) => {
  'started_at': DateTime.now().toUtc().toIso8601String(),
  'auto_preset_id': null,
  'payload_json': jsonEncode({
    'version': 1,
    'exercises': [
      {
        'type': 'weight',
        'name': exerciseName,
        'equipment': 'Barbell',
        'sets': [
          {'weight': 100, 'reps': 5},
        ],
      },
    ],
  }),
};

class _FakeAppRepository extends AppRepository {
  _FakeAppRepository({
    this.draft,
    this.saveFailuresRemaining = 0,
    this.loadFailuresRemaining = 0,
    List<Map<String, dynamic>>? pendingProgressions,
  }) : pendingProgressions = pendingProgressions ?? [];

  Map<String, dynamic>? draft;
  int saveFailuresRemaining;
  int loadFailuresRemaining;
  final List<Map<String, dynamic>> pendingProgressions;
  int saveCount = 0;
  int completionCount = 0;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async {
    if (loadFailuresRemaining > 0) {
      loadFailuresRemaining--;
      throw StateError('load failed');
    }
    return draft;
  }

  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    saveCount++;
    if (saveFailuresRemaining > 0) {
      saveFailuresRemaining--;
      throw StateError('save failed');
    }
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
    int? autoPresetId,
  }) async {
    completionCount++;
    draft = null;
    if (autoPresetId != null) {
      pendingProgressions.add({'session_id': 1, 'preset_id': autoPresetId});
    }
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      pendingProgressions.map(Map<String, dynamic>.from).toList();

  @override
  Future<void> recordPendingWorkoutProgressionFailure(int sessionId) async {}

  @override
  Future<void> clearActiveWorkoutDraft() async {
    draft = null;
  }
}
