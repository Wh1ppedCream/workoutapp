import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../utils/serial_async_queue.dart';
import 'preference_writer.dart';

/// Validated, immutable snapshot of durable Optimized Workout preferences.
class OptimizedWorkoutSettings {
  const OptimizedWorkoutSettings({
    this.sessionMinutes = SessionSpec.defaultSessionDurationMinutes,
    this.minSetsPerExercise = SessionSpec.preferredMinSetsPerExercise,
    this.maxSetsPerExercise = SessionSpec.defaultMaxSetsPerExercise,
    this.repWeightMode = RepWeightGenerationMode.mixed,
    this.targetRepCount = SessionSpec.defaultTargetRepCount,
    this.starterWeightIntensity = StarterWeightIntensity.medium,
  });

  final int sessionMinutes;
  final int minSetsPerExercise;
  final int maxSetsPerExercise;
  final RepWeightGenerationMode repWeightMode;
  final int targetRepCount;
  final StarterWeightIntensity starterWeightIntensity;

  OptimizedWorkoutSettings copyWith({
    int? sessionMinutes,
    int? minSetsPerExercise,
    int? maxSetsPerExercise,
    RepWeightGenerationMode? repWeightMode,
    int? targetRepCount,
    StarterWeightIntensity? starterWeightIntensity,
  }) {
    final nextMaxSets = maxSetsPerExercise ?? this.maxSetsPerExercise;
    var nextMinSets = minSetsPerExercise ?? this.minSetsPerExercise;
    if (nextMinSets > nextMaxSets) {
      nextMinSets = nextMaxSets;
    }
    return OptimizedWorkoutSettings(
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      minSetsPerExercise: nextMinSets,
      maxSetsPerExercise: nextMaxSets,
      repWeightMode: repWeightMode ?? this.repWeightMode,
      targetRepCount: targetRepCount ?? this.targetRepCount,
      starterWeightIntensity:
          starterWeightIntensity ?? this.starterWeightIntensity,
    );
  }

  static OptimizedWorkoutSettings fromPreferences(SharedPreferences prefs) {
    final savedMinutes = prefs.getInt(
      OptimizedWorkoutPreferences.sessionMinutesKey,
    );
    final savedMinSets = prefs.getInt(OptimizedWorkoutPreferences.minSetsKey);
    final savedMaxSets = prefs.getInt(OptimizedWorkoutPreferences.maxSetsKey);
    final savedRepWeightMode = prefs.getString(
      OptimizedWorkoutPreferences.repWeightModeKey,
    );
    final savedTargetReps = prefs.getInt(
      OptimizedWorkoutPreferences.targetRepsKey,
    );
    final savedStarterIntensity = prefs.getString(
      OptimizedWorkoutPreferences.starterIntensityKey,
    );

    final sessionMinutes = savedMinutes != null && savedMinutes > 0
        ? savedMinutes
        : SessionSpec.defaultSessionDurationMinutes;
    final maxSets =
        savedMaxSets != null &&
            savedMaxSets >= SessionSpec.defaultMinSetsPerExercise &&
            savedMaxSets <= SessionSpec.maxAllowedSetsPerExercise
        ? savedMaxSets
        : SessionSpec.defaultMaxSetsPerExercise;
    var minSets =
        savedMinSets != null &&
            savedMinSets >= SessionSpec.defaultMinSetsPerExercise &&
            savedMinSets <= SessionSpec.maxAllowedSetsPerExercise
        ? savedMinSets
        : SessionSpec.preferredMinSetsPerExercise;
    if (minSets > maxSets) {
      minSets = maxSets;
    }
    final repWeightMode =
        _repWeightModeFromName(savedRepWeightMode) ??
        RepWeightGenerationMode.mixed;
    final targetRepCount = savedTargetReps != null && savedTargetReps > 0
        ? savedTargetReps
        : SessionSpec.defaultTargetRepCount;
    final starterWeightIntensity =
        _starterIntensityFromName(savedStarterIntensity) ??
        StarterWeightIntensity.medium;

    return OptimizedWorkoutSettings(
      sessionMinutes: sessionMinutes,
      minSetsPerExercise: minSets,
      maxSetsPerExercise: maxSets,
      repWeightMode: repWeightMode,
      targetRepCount: targetRepCount,
      starterWeightIntensity: starterWeightIntensity,
    );
  }

  static RepWeightGenerationMode? _repWeightModeFromName(String? name) {
    if (name == null) return null;
    for (final mode in RepWeightGenerationMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  static StarterWeightIntensity? _starterIntensityFromName(String? name) {
    if (name == null) return null;
    for (final intensity in StarterWeightIntensity.values) {
      if (intensity.name == name) return intensity;
    }
    return null;
  }
}

/// Shared persistence helper for durable Optimized Workout defaults across
/// training hubs.
class OptimizedWorkoutPreferences {
  const OptimizedWorkoutPreferences({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const sessionMinutesKey = 'train.optimized_session_minutes';
  static const minSetsKey = 'train.optimized_min_sets_per_exercise';
  static const maxSetsKey = 'train.optimized_max_sets_per_exercise';
  static const repWeightModeKey = 'train.optimized_rep_weight_mode';
  static const targetRepsKey = 'train.optimized_target_reps';
  static const starterIntensityKey = 'train.optimized_starter_intensity';

  static final SerialAsyncQueue _writes = SerialAsyncQueue();

  final Future<SharedPreferences> Function() _preferencesLoader;

  Future<OptimizedWorkoutSettings> load() async {
    final prefs = await _preferencesLoader();
    return OptimizedWorkoutSettings.fromPreferences(prefs);
  }

  Future<OptimizedWorkoutSettings> saveAll(OptimizedWorkoutSettings settings) {
    final normalized = settings.copyWith();
    return _writes.run(() async {
      final prefs = await _preferencesLoader();
      await writePreferences(prefs, <String, Object?>{
        sessionMinutesKey: normalized.sessionMinutes,
        minSetsKey: normalized.minSetsPerExercise,
        maxSetsKey: normalized.maxSetsPerExercise,
        repWeightModeKey: normalized.repWeightMode.name,
        targetRepsKey: normalized.targetRepCount,
        starterIntensityKey: normalized.starterWeightIntensity.name,
      });
      return normalized;
    });
  }

  Future<OptimizedWorkoutSettings> saveDurationAndMaxSets({
    required int sessionMinutes,
    required int maxSetsPerExercise,
  }) {
    return _writes.run(() async {
      final prefs = await _preferencesLoader();
      final current = OptimizedWorkoutSettings.fromPreferences(prefs);
      final updated = current.copyWith(
        sessionMinutes: sessionMinutes,
        maxSetsPerExercise: maxSetsPerExercise,
      );
      await writePreferences(prefs, <String, Object?>{
        sessionMinutesKey: updated.sessionMinutes,
        minSetsKey: updated.minSetsPerExercise,
        maxSetsKey: updated.maxSetsPerExercise,
      });
      return updated;
    });
  }
}
