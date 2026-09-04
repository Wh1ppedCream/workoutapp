class PremadeTrainingPlan {
  final String id;
  final String sourceName;
  final String planGroupName;
  final int durationMinutes;
  final String name;
  final String description;
  final List<PremadeTrainingExercise> exercises;

  const PremadeTrainingPlan({
    required this.id,
    required this.sourceName,
    required this.planGroupName,
    this.durationMinutes = 120,
    required this.name,
    required this.description,
    required this.exercises,
  });

  /// Stable identity for translating built-in plan presentation without using
  /// a user-visible name as persistence or matching data.
  String get catalogId => 'tonos.plan.$id';
}

class PremadeTrainingExercise {
  final String name;
  final String? catalogId;
  final String equipment;
  final int sets;
  final int reps;
  final double weight;

  const PremadeTrainingExercise({
    required this.name,
    required this.catalogId,
    required this.equipment,
    required this.sets,
    required this.reps,
    this.weight = 0,
  });

  /// Stable equipment identity for authored plan rows.
  ///
  /// These rows are shipped app content rather than user-created snapshots,
  /// so the mapping stays explicit and does not affect matching or storage.
  String? get equipmentCatalogId => _premadeEquipmentCatalogIds[equipment];
}

const _premadeEquipmentCatalogIds = <String, String>{
  'Barbell': 'tonos.equipment.0005',
  'Bodyweight': 'tonos.equipment.0006',
  'Cable Machine': 'tonos.equipment.0011',
  'Dip Bars': 'tonos.equipment.0013',
  'Dumbbell': 'tonos.equipment.0014',
  'Lat Pulldown Machine': 'tonos.equipment.0023',
  'Leg Curl Machine (lying)': 'tonos.equipment.0025',
  'Leg Curl Machine (seated)': 'tonos.equipment.0026',
  'Leg Extension Machine': 'tonos.equipment.0027',
  'Leg Press Machine': 'tonos.equipment.0028',
  'Seated Calf Raise Machine': 'tonos.equipment.0035',
  'Standing Calf Raise Machine': 'tonos.equipment.0039',
};

/// Homemade plan catalog shown on the Train > Plans tab.
///
/// Add influencer, coach, or app-curated routines here as data entries. Users
/// can copy any plan into their own plans, then edit the created plan like
/// any other workout. Keep exercise names/equipment aligned with the seeded
/// exercise library so copied plans inherit existing muscles and bodyparts.
final premadeTrainingPlans = <PremadeTrainingPlan>[
  ..._authoredPremadeTrainingPlans,
  ..._oneHourPlanCounterparts,
  ..._twoHourPlanCounterparts,
];

const _authoredPremadeTrainingPlans = <PremadeTrainingPlan>[
  PremadeTrainingPlan(
    id: 'homemade_full_body_1',
    sourceName: 'Homemade',
    planGroupName: 'Full Body',
    name: 'Full Body',
    description:
        'A complete full-body session built around squat, bench, vertical pull, hinge, delts, arms, and calves.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        catalogId: 'tonos.exercise.0006',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        catalogId: 'tonos.exercise.0007',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lat Pulldown - Lat Pulldown Machine',
        catalogId: 'tonos.exercise.0130',
        equipment: 'Lat Pulldown Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Dumbbell (Straight Arm)',
        catalogId: 'tonos.exercise.0137',
        equipment: 'Dumbbell',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bicep Curl - Dumbbell',
        catalogId: 'tonos.exercise.0105',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Calf Raise - Standing Calf Raise Machine',
        catalogId: 'tonos.exercise.0025',
        equipment: 'Standing Calf Raise Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_full_body_2',
    sourceName: 'Homemade',
    planGroupName: 'Full Body',
    name: 'Full Body 2',
    description:
        'A posterior-chain first full-body day with overhead pressing, rows, quad volume, chest isolation, triceps, and rear delts.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        catalogId: 'tonos.exercise.0050',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        catalogId: 'tonos.exercise.0162',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Barbell',
        catalogId: 'tonos.exercise.0221',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Chest Fly - Cable Machine',
        catalogId: 'tonos.exercise.0030',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Tricep Extension - Cable Machine',
        catalogId: 'tonos.exercise.0287',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Face Pull - Cable Machine',
        catalogId: 'tonos.exercise.0061',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_full_body_3',
    sourceName: 'Homemade',
    planGroupName: 'Full Body',
    name: 'Full Body 3',
    description:
        'A hinge and incline-press full-body day with cable rows, unilateral legs, side delts, biceps, and triceps.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bench Press - Barbell',
        catalogId: 'tonos.exercise.0103',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Cable Machine',
        catalogId: 'tonos.exercise.0219',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Bulgarian Split Squat',
        catalogId: 'tonos.exercise.0020',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Cable Machine',
        catalogId: 'tonos.exercise.0136',
        equipment: 'Cable Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Hammer Curl - Dumbbell',
        catalogId: 'tonos.exercise.0081',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Tricep Pushdown - Cable Machine',
        catalogId: 'tonos.exercise.0293',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_push_1',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Push',
    description:
        'A chest, shoulder, and triceps day built around flat pressing, shoulder pressing, fly work, and direct arm volume.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        catalogId: 'tonos.exercise.0007',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Press - Dumbbell',
        catalogId: 'tonos.exercise.0163',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bench Fly - Dumbbell',
        catalogId: 'tonos.exercise.0101',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Dumbbell (Straight Arm)',
        catalogId: 'tonos.exercise.0137',
        equipment: 'Dumbbell',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Tricep Extension - Cable Machine',
        catalogId: 'tonos.exercise.0287',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Tricep Pushdown - Cable Machine',
        catalogId: 'tonos.exercise.0293',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_pull_1',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Pull',
    description:
        'A posterior-chain and back-focused day with deadlifts, vertical pulling, rows, rear delts, and curls.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        catalogId: 'tonos.exercise.0050',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
      PremadeTrainingExercise(
        name: 'Pull Up',
        catalogId: 'tonos.exercise.0180',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Barbell',
        catalogId: 'tonos.exercise.0221',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Face Pull - Cable Machine',
        catalogId: 'tonos.exercise.0061',
        equipment: 'Cable Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bicep Curl - Dumbbell',
        catalogId: 'tonos.exercise.0105',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Hammer Curl - Dumbbell',
        catalogId: 'tonos.exercise.0081',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_legs_1',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Legs',
    description:
        'A squat-led leg day pairing quad and glute work with hamstring isolation and standing calf volume.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        catalogId: 'tonos.exercise.0006',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Lying Leg Curl - Leg Curl Machine',
        catalogId: 'tonos.exercise.0150',
        equipment: 'Leg Curl Machine (lying)',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Calf Raise - Standing Calf Raise Machine',
        catalogId: 'tonos.exercise.0025',
        equipment: 'Standing Calf Raise Machine',
        sets: 4,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_push_2',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Push 2',
    description:
        'An upper-chest and triceps-biased push day with incline pressing, overhead strength work, and dips.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Incline Bench Press - Barbell',
        catalogId: 'tonos.exercise.0103',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        catalogId: 'tonos.exercise.0162',
        equipment: 'Barbell',
        sets: 3,
        reps: 7,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Dumbbells',
        catalogId: 'tonos.exercise.0009',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Cable Machine',
        catalogId: 'tonos.exercise.0136',
        equipment: 'Cable Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell (Close Grip)',
        catalogId: 'tonos.exercise.0008',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Chest Dip - Dip Bars',
        catalogId: 'tonos.exercise.0028',
        equipment: 'Dip Bars',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_pull_2',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Pull 2',
    description:
        'A row-heavy pull day for back thickness, unilateral lat work, rear delts, and biceps.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Pendlay Row - Barbell',
        catalogId: 'tonos.exercise.0167',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Cable Machine',
        catalogId: 'tonos.exercise.0219',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Single Arm Row - Dumbbell (Kneeling)',
        catalogId: 'tonos.exercise.0247',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Reverse Fly - Dumbbell (Bent Over)',
        catalogId: 'tonos.exercise.0198',
        equipment: 'Dumbbell',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Bicep Curl - Barbell',
        catalogId: 'tonos.exercise.0012',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Preacher Curl - Barbell (with Preacher Bench)',
        catalogId: 'tonos.exercise.0176',
        equipment: 'Barbell',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_ppl_legs_2',
    sourceName: 'Homemade',
    planGroupName: 'Push Pull Legs',
    name: 'Legs 2',
    description:
        'A hamstring-biased leg day with Romanian deadlifts, unilateral quad/glute work, and seated calf volume.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Bulgarian Split Squat',
        catalogId: 'tonos.exercise.0020',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Leg Extension - Leg Extension Machine',
        catalogId: 'tonos.exercise.0142',
        equipment: 'Leg Extension Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Curl',
        catalogId: 'tonos.exercise.0230',
        equipment: 'Leg Curl Machine (seated)',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Calf Raise - Seated Calf Raise Machine',
        catalogId: 'tonos.exercise.0024',
        equipment: 'Seated Calf Raise Machine',
        sets: 4,
        reps: 20,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_upper_1',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    durationMinutes: 60,
    name: 'Upper 1',
    description:
        'A compact upper-body day built around horizontal pressing, rowing, and direct side-delt work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        catalogId: 'tonos.exercise.0007',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Barbell',
        catalogId: 'tonos.exercise.0221',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Dumbbell (Straight Arm)',
        catalogId: 'tonos.exercise.0137',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_lower_1',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    durationMinutes: 60,
    name: 'Lower 1',
    description:
        'A squat-led lower day with calves first, then quad, hamstring, and glute-focused work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Calf Raise - Standing Calf Raise Machine',
        catalogId: 'tonos.exercise.0025',
        equipment: 'Standing Calf Raise Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        catalogId: 'tonos.exercise.0006',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Leg Extension - Leg Extension Machine',
        catalogId: 'tonos.exercise.0142',
        equipment: 'Leg Extension Machine',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_upper_2',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    durationMinutes: 60,
    name: 'Upper 2',
    description:
        'A vertical upper-body day pairing overhead pressing, pull-ups, and direct lateral delt work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        catalogId: 'tonos.exercise.0162',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Pull Up',
        catalogId: 'tonos.exercise.0180',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Cable Machine',
        catalogId: 'tonos.exercise.0136',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_lower_2',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    durationMinutes: 60,
    name: 'Lower 2',
    description:
        'A deadlift-led lower day with calves first, then posterior-chain and leg-press volume.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Calf Raise - Seated Calf Raise Machine',
        catalogId: 'tonos.exercise.0024',
        equipment: 'Seated Calf Raise Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        catalogId: 'tonos.exercise.0050',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lying Leg Curl - Leg Curl Machine',
        catalogId: 'tonos.exercise.0150',
        equipment: 'Leg Curl Machine (lying)',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_bro_chest_biceps',
    sourceName: 'Homemade',
    planGroupName: 'Body Part (Bro) Split',
    name: 'Chest & Biceps',
    description:
        'A chest-first day with flat power, incline volume, cable isolation, and three biceps angles.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        catalogId: 'tonos.exercise.0007',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bench Press - Dumbbell',
        catalogId: 'tonos.exercise.0104',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Chest Fly - Cable Machine',
        catalogId: 'tonos.exercise.0030',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Bicep Curl - Barbell',
        catalogId: 'tonos.exercise.0012',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Incline Bicep Curl - Dumbbell',
        catalogId: 'tonos.exercise.0105',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Hammer Curl - Dumbbell',
        catalogId: 'tonos.exercise.0081',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_bro_back_rear_delts',
    sourceName: 'Homemade',
    planGroupName: 'Body Part (Bro) Split',
    name: 'Back & Rear Delts',
    description:
        'A back-focused day with deadlifts, vertical pulling, rows, face pulls, and rear-delt isolation.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        catalogId: 'tonos.exercise.0050',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
      PremadeTrainingExercise(
        name: 'Lat Pulldown - Lat Pulldown Machine',
        catalogId: 'tonos.exercise.0130',
        equipment: 'Lat Pulldown Machine',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Barbell',
        catalogId: 'tonos.exercise.0221',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Row - Cable Machine',
        catalogId: 'tonos.exercise.0219',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Face Pull - Cable Machine',
        catalogId: 'tonos.exercise.0061',
        equipment: 'Cable Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Reverse Fly - Dumbbell (Bent Over)',
        catalogId: 'tonos.exercise.0198',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_bro_shoulders_triceps',
    sourceName: 'Homemade',
    planGroupName: 'Body Part (Bro) Split',
    name: 'Shoulders & Triceps',
    description:
        'An overhead-power day with shoulder volume, side-delt isolation, and triceps compound plus stretch work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        catalogId: 'tonos.exercise.0162',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Press - Dumbbell',
        catalogId: 'tonos.exercise.0163',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Dumbbell (Straight Arm)',
        catalogId: 'tonos.exercise.0137',
        equipment: 'Dumbbell',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Cable Machine',
        catalogId: 'tonos.exercise.0136',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell (Close Grip)',
        catalogId: 'tonos.exercise.0008',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Overhead Tricep Extension - Cable Machine',
        catalogId: 'tonos.exercise.0287',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_bro_legs',
    sourceName: 'Homemade',
    planGroupName: 'Body Part (Bro) Split',
    name: 'Legs',
    description:
        'A leg-day split with squat strength, Romanian deadlifts, quad volume, hamstring isolation, and two calf angles.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        catalogId: 'tonos.exercise.0006',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Lying Leg Curl - Leg Curl Machine',
        catalogId: 'tonos.exercise.0150',
        equipment: 'Leg Curl Machine (lying)',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Calf Raise - Standing Calf Raise Machine',
        catalogId: 'tonos.exercise.0025',
        equipment: 'Standing Calf Raise Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Calf Raise - Seated Calf Raise Machine',
        catalogId: 'tonos.exercise.0024',
        equipment: 'Seated Calf Raise Machine',
        sets: 3,
        reps: 20,
      ),
    ],
  ),
];

final _oneHourPlanCounterparts = _authoredPremadeTrainingPlans
    .where((plan) => plan.durationMinutes == 120)
    .map(_toOneHourVersion)
    .toList(growable: false);

PremadeTrainingPlan _toOneHourVersion(PremadeTrainingPlan plan) {
  return PremadeTrainingPlan(
    id: '${plan.id}_one_hour',
    sourceName: plan.sourceName,
    planGroupName: plan.planGroupName,
    durationMinutes: 60,
    name: plan.name,
    description:
        'A focused 1-hour version of ${plan.name} using the main movements from the full template.',
    exercises: _compactOneHourExercises(plan.exercises),
  );
}

List<PremadeTrainingExercise> _compactOneHourExercises(
  List<PremadeTrainingExercise> exercises,
) {
  final selected = <PremadeTrainingExercise>[];
  var totalSets = 0;
  for (final exercise in exercises) {
    final nextTotal = totalSets + exercise.sets;
    if (selected.length >= 4) break;
    if (selected.length >= 2 && nextTotal > 15) break;
    selected.add(exercise);
    totalSets = nextTotal;
  }
  return List<PremadeTrainingExercise>.unmodifiable(selected);
}

const _twoHourPlanCounterparts = <PremadeTrainingPlan>[
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_upper_1_two_hour',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    name: 'Upper 1',
    description:
        'A 2-hour horizontal upper day with pressing, rows, vertical pulling, side delts, chest isolation, and triceps.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Bench Press - Barbell',
        catalogId: 'tonos.exercise.0007',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Row - Barbell',
        catalogId: 'tonos.exercise.0221',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lat Pulldown - Lat Pulldown Machine',
        catalogId: 'tonos.exercise.0130',
        equipment: 'Lat Pulldown Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Dumbbell (Straight Arm)',
        catalogId: 'tonos.exercise.0137',
        equipment: 'Dumbbell',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Chest Fly - Cable Machine',
        catalogId: 'tonos.exercise.0030',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Tricep Pushdown - Cable Machine',
        catalogId: 'tonos.exercise.0293',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_lower_1_two_hour',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    name: 'Lower 1',
    description:
        'A 2-hour squat-led lower day with calves, quad volume, hamstring work, and leg-press volume.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Calf Raise - Standing Calf Raise Machine',
        catalogId: 'tonos.exercise.0025',
        equipment: 'Standing Calf Raise Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Barbell Squat',
        catalogId: 'tonos.exercise.0006',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Romanian Deadlift - Barbell',
        catalogId: 'tonos.exercise.0215',
        equipment: 'Barbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Leg Extension - Leg Extension Machine',
        catalogId: 'tonos.exercise.0142',
        equipment: 'Leg Extension Machine',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Lying Leg Curl - Leg Curl Machine',
        catalogId: 'tonos.exercise.0150',
        equipment: 'Leg Curl Machine (lying)',
        sets: 3,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 12,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_upper_2_two_hour',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    name: 'Upper 2',
    description:
        'A 2-hour vertical upper day with overhead press, pull-ups, cable raises, pressing, rows, and rear-delt health work.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Overhead Press - Barbell',
        catalogId: 'tonos.exercise.0162',
        equipment: 'Barbell',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Pull Up',
        catalogId: 'tonos.exercise.0180',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 8,
      ),
      PremadeTrainingExercise(
        name: 'Lateral Raise - Cable Machine',
        catalogId: 'tonos.exercise.0136',
        equipment: 'Cable Machine',
        sets: 4,
        reps: 15,
      ),
      PremadeTrainingExercise(
        name: 'Bench Press - Dumbbells',
        catalogId: 'tonos.exercise.0009',
        equipment: 'Dumbbell',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Row - Cable Machine',
        catalogId: 'tonos.exercise.0219',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Face Pull - Cable Machine',
        catalogId: 'tonos.exercise.0061',
        equipment: 'Cable Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
  PremadeTrainingPlan(
    id: 'homemade_upper_lower_lower_2_two_hour',
    sourceName: 'Homemade',
    planGroupName: 'Upper Lower',
    name: 'Lower 2',
    description:
        'A 2-hour deadlift-led lower day with seated calves, leg press, hamstrings, unilateral legs, and quad isolation.',
    exercises: [
      PremadeTrainingExercise(
        name: 'Calf Raise - Seated Calf Raise Machine',
        catalogId: 'tonos.exercise.0024',
        equipment: 'Seated Calf Raise Machine',
        sets: 4,
        reps: 20,
      ),
      PremadeTrainingExercise(
        name: 'Deadlift - Barbell',
        catalogId: 'tonos.exercise.0050',
        equipment: 'Barbell',
        sets: 3,
        reps: 5,
      ),
      PremadeTrainingExercise(
        name: 'Seated Leg Press',
        catalogId: 'tonos.exercise.0231',
        equipment: 'Leg Press Machine',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Lying Leg Curl - Leg Curl Machine',
        catalogId: 'tonos.exercise.0150',
        equipment: 'Leg Curl Machine (lying)',
        sets: 3,
        reps: 12,
      ),
      PremadeTrainingExercise(
        name: 'Bulgarian Split Squat',
        catalogId: 'tonos.exercise.0020',
        equipment: 'Bodyweight',
        sets: 3,
        reps: 10,
      ),
      PremadeTrainingExercise(
        name: 'Leg Extension - Leg Extension Machine',
        catalogId: 'tonos.exercise.0142',
        equipment: 'Leg Extension Machine',
        sets: 3,
        reps: 15,
      ),
    ],
  ),
];
