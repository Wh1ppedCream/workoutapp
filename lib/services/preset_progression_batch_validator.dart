import '../models/preset_models.dart';

/// Rejects malformed automatic-progression mutations before they reach SQLite.
class PresetProgressionBatchValidator {
  const PresetProgressionBatchValidator._();

  static void validateOrThrow(PresetProgressionBatch progression) {
    final violations = validate(progression);
    if (violations.isNotEmpty) {
      throw ArgumentError.value(
        progression,
        'progression',
        'Invalid preset progression batch: ${violations.join('; ')}',
      );
    }
  }

  static List<String> validate(PresetProgressionBatch progression) {
    final violations = <String>[];
    final deletedSetIds = progression.deletedSetIds.toSet();
    if (deletedSetIds.length != progression.deletedSetIds.length ||
        deletedSetIds.any((id) => id <= 0)) {
      violations.add('deleted set IDs must be unique positive values');
    }

    final updatedSetIds = <int>{};
    for (final update in progression.updates) {
      if (!updatedSetIds.add(update.setId) || update.setId <= 0) {
        violations.add('updated set IDs must be unique positive values');
      }
      if (deletedSetIds.contains(update.setId)) {
        violations.add('a set cannot be both updated and deleted');
      }
      if (!update.weight.isFinite ||
          update.weight < 0 ||
          update.reps < 0 ||
          update.orderIndex < 0) {
        violations.add('set updates require finite non-negative values');
      }
    }

    for (final insert in progression.inserts) {
      if (insert.presetExerciseId <= 0 ||
          !insert.weight.isFinite ||
          insert.weight < 0 ||
          insert.reps < 0 ||
          insert.orderIndex < 0) {
        violations.add('set inserts require finite non-negative values');
      }
    }

    final exerciseIds = <int>{};
    for (final state in progression.exerciseStates) {
      if (!exerciseIds.add(state.presetExerciseId) ||
          state.presetExerciseId <= 0 ||
          state.lastSetIndex < 1 ||
          (state.incrementAmount != null &&
              (!state.incrementAmount!.isFinite ||
                  state.incrementAmount! < 0))) {
        violations.add('exercise progression state is invalid');
      }
    }
    return violations;
  }
}
