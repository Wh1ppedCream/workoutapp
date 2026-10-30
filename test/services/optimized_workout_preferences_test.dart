import 'package:env_test/models/models.dart';
import 'package:env_test/services/optimized_workout_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Backend failure injection without reading device preferences.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'loads defaults and clamps out-of-range or inverted preferences',
    () async {
      const helper = OptimizedWorkoutPreferences();
      final defaults = await helper.load();
      expect(
        defaults.sessionMinutes,
        SessionSpec.defaultSessionDurationMinutes,
      );
      expect(
        defaults.minSetsPerExercise,
        SessionSpec.preferredMinSetsPerExercise,
      );
      expect(
        defaults.maxSetsPerExercise,
        SessionSpec.defaultMaxSetsPerExercise,
      );
      expect(defaults.repWeightMode, RepWeightGenerationMode.mixed);
      expect(defaults.targetRepCount, SessionSpec.defaultTargetRepCount);
      expect(defaults.starterWeightIntensity, StarterWeightIntensity.medium);

      SharedPreferences.setMockInitialValues({
        OptimizedWorkoutPreferences.sessionMinutesKey: -10,
        OptimizedWorkoutPreferences.minSetsKey: 5,
        OptimizedWorkoutPreferences.maxSetsKey: 3,
        OptimizedWorkoutPreferences.repWeightModeKey: 'unknown_mode',
        OptimizedWorkoutPreferences.targetRepsKey: 0,
        OptimizedWorkoutPreferences.starterIntensityKey: 'unknown_intensity',
      });

      final sanitized = await helper.load();
      expect(
        sanitized.sessionMinutes,
        SessionSpec.defaultSessionDurationMinutes,
      );
      expect(sanitized.maxSetsPerExercise, 3);
      expect(sanitized.minSetsPerExercise, 3);
      expect(sanitized.repWeightMode, RepWeightGenerationMode.mixed);
      expect(sanitized.targetRepCount, SessionSpec.defaultTargetRepCount);
      expect(sanitized.starterWeightIntensity, StarterWeightIntensity.medium);
    },
  );

  test('saveAll and saveDurationAndMaxSets preserve sibling settings and clamp minSets', () async {
    const helper = OptimizedWorkoutPreferences();
    final saved = await helper.saveAll(
      const OptimizedWorkoutSettings(
        sessionMinutes: 55,
        minSetsPerExercise: 4,
        maxSetsPerExercise: 5,
        repWeightMode: RepWeightGenerationMode.consistent,
        targetRepCount: 12,
        starterWeightIntensity: StarterWeightIntensity.hard,
      ),
    );
    expect(saved.sessionMinutes, 55);
    expect(saved.minSetsPerExercise, 4);
    expect(saved.maxSetsPerExercise, 5);

    final narrowed = await helper.saveDurationAndMaxSets(
      sessionMinutes: 35,
      maxSetsPerExercise: 2,
    );
    expect(narrowed.sessionMinutes, 35);
    expect(narrowed.maxSetsPerExercise, 2);
    expect(narrowed.minSetsPerExercise, 2);
    expect(narrowed.repWeightMode, RepWeightGenerationMode.consistent);
    expect(narrowed.targetRepCount, 12);
    expect(narrowed.starterWeightIntensity, StarterWeightIntensity.hard);

    final reloaded = await helper.load();
    expect(reloaded.sessionMinutes, 35);
    expect(reloaded.minSetsPerExercise, 2);
    expect(reloaded.maxSetsPerExercise, 2);
    expect(reloaded.repWeightMode, RepWeightGenerationMode.consistent);
    expect(reloaded.targetRepCount, 12);
    expect(reloaded.starterWeightIntensity, StarterWeightIntensity.hard);
  });

  test(
    'rolls back partial preference writes when a mid-batch write fails',
    () async {
      final store = _FailingPreferencesStore();
      SharedPreferencesStorePlatform.instance = store;
      const helper = OptimizedWorkoutPreferences();

      await helper.saveAll(
        const OptimizedWorkoutSettings(
          sessionMinutes: 45,
          minSetsPerExercise: 2,
          maxSetsPerExercise: 4,
          repWeightMode: RepWeightGenerationMode.mixed,
          targetRepCount: 10,
          starterWeightIntensity: StarterWeightIntensity.easy,
        ),
      );

      store.failAtWrite = store.writes + 4;
      await expectLater(
        helper.saveAll(
          const OptimizedWorkoutSettings(
            sessionMinutes: 75,
            minSetsPerExercise: 3,
            maxSetsPerExercise: 5,
            repWeightMode: RepWeightGenerationMode.consistent,
            targetRepCount: 6,
            starterWeightIntensity: StarterWeightIntensity.hard,
          ),
        ),
        throwsStateError,
      );

      final afterFailure = await helper.load();
      expect(afterFailure.sessionMinutes, 45);
      expect(afterFailure.minSetsPerExercise, 2);
      expect(afterFailure.maxSetsPerExercise, 4);
      expect(afterFailure.repWeightMode, RepWeightGenerationMode.mixed);
      expect(afterFailure.targetRepCount, 10);
      expect(afterFailure.starterWeightIntensity, StarterWeightIntensity.easy);
    },
  );
}

class _FailingPreferencesStore extends InMemorySharedPreferencesStore {
  _FailingPreferencesStore() : super.empty();

  int writes = 0;
  int? failAtWrite;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes++;
    if (writes == failAtWrite) {
      failAtWrite = null;
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}
