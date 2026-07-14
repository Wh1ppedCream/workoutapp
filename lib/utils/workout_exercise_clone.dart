import '../models/models.dart';

/// Creates a detached copy of an exercise before moving it between providers.
///
/// Generated optimized workouts are first loaded as a temporary preset, then
/// copied into ActiveSession. Copying avoids sharing mutable set lists with the
/// temporary PresetSession object that gets disposed/deleted immediately after.
WorkoutExercise cloneWorkoutExercise(
  WorkoutExercise exercise, {
  bool preservePresetSource = false,
}) {
  if (exercise is WeightExercise) {
    return WeightExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      sourcePresetExerciseId:
          preservePresetSource ? exercise.sourcePresetExerciseId : null,
      sets: _cloneSets(exercise.sets, preservePresetSource),
      changeSets: _cloneChangeSets(exercise.changeSets, preservePresetSource),
    );
  }
  if (exercise is CardioExercise) {
    return CardioExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      cardioName: exercise.cardioName,
      cardioNote: exercise.cardioNote,
      plannedMinutes: exercise.plannedMinutes,
      elapsedSeconds: exercise.elapsedSeconds,
    );
  }
  if (exercise is StretchExercise) {
    return StretchExercise(
      name: exercise.name,
      equipment: exercise.equipment,
      stretchInstances:
          exercise.stretchInstances
              .map(
                (instance) => StretchInstance(
                  stretchId: instance.stretchId,
                  isCustom: instance.isCustom,
                  customName: instance.customName,
                  customDesc: instance.customDesc,
                  isChecked: instance.isChecked,
                  orderIndex: instance.orderIndex,
                ),
              )
              .toList(),
    );
  }
  return exercise;
}

List<ExerciseSet> _cloneSets(
  List<ExerciseSet> sets,
  bool preservePresetSource,
) {
  return sets
      .map(
        (set) => ExerciseSet(
          sourcePresetSetId:
              preservePresetSource ? set.sourcePresetSetId : null,
          weight: set.weight,
          reps: set.reps,
        ),
      )
      .toList();
}

Map<int, List<ExerciseSet>> _cloneChangeSets(
  Map<int, List<ExerciseSet>> changeSets,
  bool preservePresetSource,
) {
  return {
    for (final entry in changeSets.entries)
      entry.key: _cloneSets(entry.value, preservePresetSource),
  };
}
