import 'dart:async';

import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/services/optimized_workout_preferences.dart';
import 'package:env_test/services/preset_generation_service.dart';
import 'package:env_test/services/safe_failure.dart';
import 'package:env_test/services/workout_launch_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/preset_repository_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _LaunchRepository repository;
  late ActiveSession session;
  late _Generator generator;
  late WorkoutLaunchCoordinator coordinator;
  var canContinue = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = _LaunchRepository();
    session = ActiveSession(repository: repository, retryDelay: (_) async {});
    await session.ready;
    generator = _Generator(repository);
    coordinator = WorkoutLaunchCoordinator(
      repository: repository,
      activeSession: session,
      generator: generator,
    );
    canContinue = true;
  });
  tearDown(() => session.dispose());

  Future<OptimizedWorkoutLaunchResult> launch() =>
      coordinator.startOptimized(spec: _spec(), canContinue: () => canContinue);

  test('different training callers share one in-flight preparation', () async {
    final gate = Completer<void>();
    generator.beforeGeneration = () => gate.future;
    final first = coordinator.startOptimized(
      spec: _spec(),
      canContinue: () => true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(session.isPreparingWorkout, isTrue);
    final otherGenerator = _Generator(repository);
    final other = WorkoutLaunchCoordinator(
      repository: repository,
      activeSession: session,
      generator: otherGenerator,
    );
    try {
      final duplicate = await other.startOptimized(
        spec: _spec(),
        canContinue: () => true,
      );
      expect(duplicate.status, OptimizedWorkoutLaunchStatus.inProgress);
      expect(otherGenerator.generationCalls, 0);
    } finally {
      gate.complete();
    }
    expect((await first).status, OptimizedWorkoutLaunchStatus.started);
    expect(session.isPreparingWorkout, isFalse);
  });

  test('cancellation after rest checking prevents generation', () async {
    generator.beforeRestCheck = () => canContinue = false;
    expect((await launch()).status, OptimizedWorkoutLaunchStatus.cancelled);
    expect(generator.generationCalls, 0);
    expect(session.isPreparingWorkout, isFalse);
  });

  test(
    'generation failure releases preparation so a later retry can start',
    () async {
      generator.beforeGeneration = () async =>
          throw StateError('Injected generation failure');
      await expectLater(launch(), throwsStateError);
      expect(session.isPreparingWorkout, isFalse);
      generator.beforeGeneration = null;
      expect((await launch()).status, OptimizedWorkoutLaunchStatus.started);
    },
  );

  test('database replacement blocks generation rather than reporting another workout', () async {
    await session.prepareForDatabaseReplace();
    await expectLater(launch(), throwsA(isA<SafeFailure>()));
    expect(generator.generationCalls, 0);
    expect(session.isPreparingWorkout, isFalse);
    session.abortDatabaseReplace();
  });

  test(
    'cancellation during active-plan migration prevents manual creation',
    () async {
      repository.onActivePlanRead = () => canContinue = false;
      final id = await coordinator.createManualPreset(
        profileId: 7,
        nameForNumber: (number) => 'Plan $number',
        canContinue: () => canContinue,
      );
      expect(id, isNull);
      expect(repository.createdName, isNull);
    },
  );

  test('both presentations use the same normalized generation policy', () {
    const settings = OptimizedWorkoutSettings(
      sessionMinutes: 45,
      minSetsPerExercise: 4,
      maxSetsPerExercise: 3,
      repWeightMode: RepWeightGenerationMode.consistent,
      targetRepCount: 12,
      starterWeightIntensity: StarterWeightIntensity.hard,
    );
    final now = DateTime.utc(2026, 10, 31);
    final spec = settings.buildSessionSpec(
      profileId: 7,
      name: 'Localized workout name',
      now: now,
      preferredBodypartIds: {2},
      blacklistedBodypartIds: {3},
    );
    expect(spec.profileId, 7);
    expect(spec.name, 'Localized workout name');
    expect(spec.now, now);
    expect(spec.sessionDurationMinutes, 45);
    expect(spec.minSetsPerExercise, 3);
    expect(spec.maxSetsPerExercise, 3);
    expect(
      spec.maxExercises,
      SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: 45,
        minSetsPerExercise: 3,
      ),
    );
    expect(spec.preferredBodypartIds, [2]);
    expect(spec.blacklistedBodypartIds, [3]);
    expect(spec.repWeightMode, RepWeightGenerationMode.consistent);
    expect(spec.targetRepCount, 12);
    expect(spec.starterWeightIntensity, StarterWeightIntensity.hard);
    expect(spec.useGeneratedRepWeights, isTrue);
    expect(spec.historyWindow, const Duration(days: 7));
    expect(spec.avoidMostRecentBodyPart, isTrue);
  });

  test(
    'starts a durable one-off workout and removes its temporary plan',
    () async {
      final result = await launch();
      expect(result.status, OptimizedWorkoutLaunchStatus.started);
      expect(result.generationResult!.exercisesWithStarterWeightEstimates, [
        'Squat',
      ]);
      expect(session.isActive, isTrue);
      expect(session.cardTypes, [CardType.weight]);
      final exercise = session.exercises.single as WeightExercise;
      expect(exercise.name, 'Squat');
      expect(exercise.sets.map((set) => set.reps), [8, 6]);
      expect(exercise.changeSets[0]!.single.weight, 20);
      expect(repository.savedPayloads, hasLength(1));
      expect(repository.deletedIds, [42]);
    },
  );

  test('resumes an existing session without generating another plan', () async {
    await session.start();
    final result = await launch();
    expect(result.status, OptimizedWorkoutLaunchStatus.alreadyActive);
    expect(generator.restChecks, 0);
    expect(generator.generationCalls, 0);
    expect(repository.deletedIds, isEmpty);
  });

  test('a rest recommendation does not generate or start a workout', () async {
    generator.shouldRest = true;
    expect(
      (await launch()).status,
      OptimizedWorkoutLaunchStatus.restRecommended,
    );
    expect(generator.generationCalls, 0);
    expect(session.isActive, isFalse);
    expect(repository.deletedIds, isEmpty);
  });

  test('an empty generated plan is cleaned up without starting', () async {
    repository.empty = true;
    expect(
      (await launch()).status,
      OptimizedWorkoutLaunchStatus.noEligibleExercises,
    );
    expect(session.isActive, isFalse);
    expect(repository.deletedIds, [42]);
  });

  test('leaving before launch avoids generation', () async {
    canContinue = false;
    expect((await launch()).status, OptimizedWorkoutLaunchStatus.cancelled);
    expect(generator.restChecks, 0);
    expect(generator.generationCalls, 0);
  });

  test('leaving during plan loading cleans up without starting', () async {
    repository.onPresetRead = () => canContinue = false;
    expect((await launch()).status, OptimizedWorkoutLaunchStatus.cancelled);
    expect(session.isActive, isFalse);
    expect(repository.deletedIds, [42]);
  });

  test(
    'a competing session is preserved and the generated plan is removed',
    () async {
      generator.beforeGeneration = () async {
        await session.startWithExercises(
          workoutExercises: [
            WeightExercise(name: 'Existing', equipment: '', sets: []),
          ],
          workoutCardTypes: [CardType.weight],
        );
      };
      expect(
        (await launch()).status,
        OptimizedWorkoutLaunchStatus.alreadyActive,
      );
      expect(session.exercises.single.name, 'Existing');
      expect(repository.savedPayloads, hasLength(1));
      expect(repository.deletedIds, [42]);
    },
  );

  test(
    'a failed plan read propagates safely and removes the temporary plan',
    () async {
      repository.failRead = true;
      await expectLater(launch(), throwsA(isA<SafeFailure>()));
      expect(session.isActive, isFalse);
      expect(repository.deletedIds, [42]);
    },
  );

  test(
    'failed cleanup is retried without discarding the started workout',
    () async {
      repository.deleteFailures = 1;
      await expectLater(launch(), throwsStateError);
      expect(session.isActive, isTrue);
      expect(session.exercises.single.name, 'Squat');
      expect(repository.deletedIds, [42, 42]);
    },
  );

  test('manual creation preserves profile, numbering, activation and unique naming', () async {
    final id = await coordinator.createManualPreset(
      profileId: 7,
      nameForNumber: (number) => 'Plan $number',
      canContinue: () => true,
    );
    expect(id, 77);
    expect(repository.readProfileId, 7);
    expect(repository.loadedActiveProfileId, 7);
    expect(repository.createdName, 'Plan 3');
    expect(repository.createdProfileId, 7);
    expect(repository.createdActive, isTrue);
    expect(repository.createdUnique, isTrue);
  });

  test(
    'manual creation stops if its caller leaves during the initial read',
    () async {
      final id = await coordinator.createManualPreset(
        profileId: 7,
        nameForNumber: (number) => 'Plan $number',
        canContinue: () => false,
      );
      expect(id, isNull);
      expect(repository.createdName, isNull);
      expect(repository.loadedActiveProfileId, isNull);
    },
  );
}

SessionSpec _spec() => const OptimizedWorkoutSettings().buildSessionSpec(
  profileId: 7,
  name: 'Optimized workout',
  now: DateTime.utc(2026, 10, 31),
  preferredBodypartIds: {},
  blacklistedBodypartIds: {},
);

class _Generator extends PresetGenerationService {
  _Generator(super.repository);

  bool shouldRest = false;
  int restChecks = 0;
  int generationCalls = 0;
  Future<void> Function()? beforeGeneration;
  void Function()? beforeRestCheck;

  @override
  Future<bool> shouldRestBeforeOptimizedWorkout(SessionSpec spec) async {
    restChecks++;
    beforeRestCheck?.call();
    return shouldRest;
  }

  @override
  Future<PresetGenerationResult> generatePresetWithDetails(
    SessionSpec spec,
  ) async {
    generationCalls++;
    await beforeGeneration?.call();
    return const PresetGenerationResult(
      presetId: 42,
      exercisesWithStarterWeightEstimates: ['Squat'],
    );
  }
}

class _LaunchRepository extends PresetRepositoryFixture {
  bool empty = false;
  bool failRead = false;
  int deleteFailures = 0;
  void Function()? onPresetRead;
  void Function()? onActivePlanRead;
  final deletedIds = <int>[];
  final savedPayloads = <String>[];
  int? readProfileId;
  int? loadedActiveProfileId;
  String? createdName;
  int? createdProfileId;
  bool? createdActive;
  bool? createdUnique;

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      [];

  @override
  Future<void> saveActiveWorkoutDraft({
    required DateTime startedAt,
    required int? autoPresetId,
    required String payloadJson,
  }) async {
    savedPayloads.add(payloadJson);
  }

  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) {
    onPresetRead?.call();
    if (failRead) throw StateError('Injected read failure');
    return super.fetchPresetById(presetId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      empty ? [] : await super.fetchPresetExercises(presetId);

  @override
  Future<void> deletePreset(int presetId) async {
    deletedIds.add(presetId);
    if (deleteFailures-- > 0) throw StateError('Injected delete failure');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllPresetsRaw({
    int? profileId,
  }) async {
    readProfileId = profileId;
    return [
      {'id': 1},
      {'id': 2},
    ];
  }

  @override
  Future<Set<int>> loadActivePlans(int profileId) async {
    loadedActiveProfileId = profileId;
    onActivePlanRead?.call();
    return {};
  }

  @override
  Future<int> createPresetAtomic({
    required String name,
    required int? profileId,
    required List<WorkoutExerciseWrite> exercises,
    PresetAutoSettingsWrite? autoSettings,
    bool activate = false,
    bool uniqueName = false,
    bool isDraft = false,
  }) async {
    createdName = name;
    createdProfileId = profileId;
    createdActive = activate;
    createdUnique = uniqueName;
    expect(exercises, isEmpty);
    return 77;
  }
}
