class PremadeTrainingPlan {
  final String id;
  final String sourceName;
  final String name;
  final String description;
  final List<PremadeTrainingExercise> exercises;

  const PremadeTrainingPlan({
    required this.id,
    required this.sourceName,
    required this.name,
    required this.description,
    required this.exercises,
  });
}

class PremadeTrainingExercise {
  final String name;
  final String equipment;
  final int sets;
  final int reps;
  final double weight;

  const PremadeTrainingExercise({
    required this.name,
    required this.equipment,
    required this.sets,
    required this.reps,
    this.weight = 0,
  });
}

/// Built-in plan catalog shown on the Train > Plans tab.
///
/// Add influencer, coach, or app-curated routines here as data entries. Users
/// can copy any plan into their own presets, then edit the created preset like
/// any other workout. Keep exercise names/equipment aligned with the seeded
/// exercise library so copied plans inherit existing muscles and bodyparts.
const premadeTrainingPlans = <PremadeTrainingPlan>[
  PremadeTrainingPlan(
    id: 'built_in_full_body_strength',
    sourceName: 'Built-in',
    name: 'Full Body Strength',
    description: 'A simple barbell-first strength session for the major movers.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'built_in_upper_push_pull',
    sourceName: 'Built-in',
    name: 'Upper Push/Pull',
    description: 'Balanced upper-body pressing and pulling work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        equipment: 'Barbell',
        sets: 4,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lat Pulldown - Lat Pulldown Machine',
        equipment: 'Lat Pulldown Machine',
        sets: 4,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Bicep Curl - Dumbbell',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
];
