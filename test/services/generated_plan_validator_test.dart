import 'package:env_test/models/models.dart';
import 'package:env_test/services/generated_plan_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final chest = BodyPart(1, 'Chest');
  final back = BodyPart(2, 'Back');

  final spec = SessionSpec(
    profileId: 1,
    name: 'Generated plan',
    focusBodypartIds: const [1, 2],
    minSetsPerExercise: 2,
    maxSetsPerExercise: 4,
    maxExercises: 2,
    sessionDurationMinutes: 30,
    minutesPerSet: 3,
    setupMinutesPerExercise: 5,
    now: DateTime.utc(2026, 8, 14),
  );

  CandidateExercisePlan plan({
    required int id,
    required Map<BodyPart, double> units,
    int sets = 3,
  }) {
    return CandidateExercisePlan(
      def: ExerciseDefinition(
        id: id,
        name: 'Exercise $id',
        useManualBodyparts: false,
        multiplyByRating: false,
      ),
      unitsPerSet: units,
      score: 1,
      suggestedSets: sets,
    );
  }

  test('accepts a plan within the existing generation constraints', () {
    expect(
      GeneratedPlanValidator.validate(
        spec: spec,
        plans: [
          plan(id: 1, units: {chest: 1}),
          plan(id: 2, units: {back: 1}),
        ],
      ),
      isEmpty,
    );
  });

  test(
    'rejects structural violations without defining new training policy',
    () {
      final violations = GeneratedPlanValidator.validate(
        spec: spec.copyWith(blacklistedBodypartIds: const [1]),
        plans: [
          plan(id: 1, units: {chest: 1}, sets: 5),
          plan(id: 1, units: {back: 6}, sets: 3),
          plan(id: 3, units: const {}, sets: 3),
        ],
      );

      expect(violations, contains('exceeds the exercise limit'));
      expect(violations, contains('contains a duplicate exercise definition'));
      expect(
        violations,
        contains('contains a set count outside the requested range'),
      );
      expect(violations, contains('includes a blacklisted body part'));
      expect(
        violations,
        contains('contains an exercise with no body-part allocation'),
      );
    },
  );
}
