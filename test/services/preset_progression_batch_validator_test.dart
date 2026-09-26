import 'package:env_test/models/preset_models.dart';
import 'package:env_test/services/preset_progression_batch_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a structurally valid progression batch', () {
    const progression = PresetProgressionBatch(
      updates: [
        PresetSetProgressionUpdate(
          setId: 1,
          weight: 105,
          reps: 5,
          orderIndex: 0,
        ),
      ],
      inserts: [
        PresetSetProgressionInsert(
          presetExerciseId: 2,
          weight: 50,
          reps: 8,
          orderIndex: 1,
        ),
      ],
      exerciseStates: [
        PresetExerciseProgressionState(
          presetExerciseId: 2,
          incrementAmount: 5,
          lastSetIndex: 1,
          lastNode: 'success',
        ),
      ],
    );

    expect(PresetProgressionBatchValidator.validate(progression), isEmpty);
  });

  test('rejects conflicting and non-finite mutations before persistence', () {
    final violations = PresetProgressionBatchValidator.validate(
      PresetProgressionBatch(
        deletedSetIds: const [1, 1],
        updates: [
          const PresetSetProgressionUpdate(
            setId: 1,
            weight: double.nan,
            reps: -1,
            orderIndex: -1,
          ),
        ],
        exerciseStates: const [
          PresetExerciseProgressionState(
            presetExerciseId: 1,
            incrementAmount: -5,
            lastSetIndex: 0,
          ),
        ],
      ),
    );

    expect(
      violations,
      contains('deleted set IDs must be unique positive values'),
    );
    expect(violations, contains('a set cannot be both updated and deleted'));
    expect(
      violations,
      contains('set updates require finite non-negative values'),
    );
    expect(violations, contains('exercise progression state is invalid'));
  });
}
