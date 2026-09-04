import '../models/training_plan_models.dart';

/// Checks that a generated selection still satisfies the constraints supplied
/// to the generator before the selection is persisted as a preset.
class GeneratedPlanValidator {
  static const double _epsilon = 0.000001;

  const GeneratedPlanValidator._();

  static void validateOrThrow({
    required SessionSpec spec,
    required List<CandidateExercisePlan> plans,
  }) {
    final violations = validate(spec: spec, plans: plans);
    if (violations.isNotEmpty) {
      throw StateError(
        'Generated plan violated its selection constraints: '
        '${violations.join('; ')}',
      );
    }
  }

  static List<String> validate({
    required SessionSpec spec,
    required List<CandidateExercisePlan> plans,
  }) {
    final violations = <String>[];
    if (plans.isEmpty) {
      violations.add('must contain at least one exercise');
      return violations;
    }
    if (plans.length > spec.maxExercises) {
      violations.add('exceeds the exercise limit');
    }

    final definitionIds = <int>{};
    final blacklistedBodyPartIds = spec.blacklistedBodypartIds.toSet();
    final sessionBodyPartUnits = <int, double>{};
    var estimatedMinutes = 0;

    for (final plan in plans) {
      if (!definitionIds.add(plan.def.id)) {
        violations.add('contains a duplicate exercise definition');
      }
      if (!plan.score.isFinite || plan.score < 0) {
        violations.add('contains an invalid candidate score');
      }
      if (plan.suggestedSets < spec.minSetsPerExercise ||
          plan.suggestedSets > spec.maxSetsPerExercise) {
        violations.add('contains a set count outside the requested range');
      }

      estimatedMinutes +=
          spec.setupMinutesPerExercise +
          plan.suggestedSets * spec.minutesPerSet;
      var hasPositiveBodyPartUnits = false;
      for (final entry in plan.unitsPerSet.entries) {
        if (!entry.value.isFinite || entry.value < 0) {
          violations.add('contains invalid body-part allocation units');
          continue;
        }
        if (entry.value <= 0) continue;
        hasPositiveBodyPartUnits = true;
        if (blacklistedBodyPartIds.contains(entry.key.id)) {
          violations.add('includes a blacklisted body part');
        }
        sessionBodyPartUnits[entry.key.id] =
            (sessionBodyPartUnits[entry.key.id] ?? 0) +
            entry.value * plan.suggestedSets;
      }
      if (!hasPositiveBodyPartUnits) {
        violations.add('contains an exercise with no body-part allocation');
      }
    }

    if (estimatedMinutes > spec.sessionDurationMinutes) {
      violations.add('exceeds the requested duration');
    }
    if (sessionBodyPartUnits.values.any(
      (units) => units > SessionSpec.maxBodyPartSetUnitsPerSession + _epsilon,
    )) {
      violations.add('exceeds the per-session body-part volume limit');
    }
    return violations;
  }
}
