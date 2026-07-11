import 'package:env_test/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SessionSpec derives a bounded exercise count from the time budget', () {
    expect(
      SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: 60,
        minSetsPerExercise: 2,
      ),
      5,
    );
    expect(
      SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: 0,
        minSetsPerExercise: 2,
      ),
      1,
    );
  });

  test('targets report only outstanding weekly work as a deficit', () {
    final chest = BodyPart(1, 'Chest');
    const muscle = MuscleTarget(
      muscleId: 4,
      weeklyTargetUnits: 12,
      doneThisWeek: 15,
    );
    final bodyPart = BodyPartTarget(
      bodyPart: chest,
      weeklyTargetUnits: 12,
      doneThisWeek: 8,
    );

    expect(bodyPart.deficit, 4);
    expect(muscle.deficit, 0);
    expect(bodyPart.copyWith(doneThisWeek: 15).deficit, 0);
  });
}
