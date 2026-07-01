import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/preset_generation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresetGenerationService weight math', () {
    late PresetGenerationService service;

    setUp(() {
      service = PresetGenerationService(AppRepository());
    });

    test('uses default preferred reps and clamps manual reps into range', () {
      expect(
        service.debugEffectiveTargetReps(
          _definition(
            name: 'Dumbbell Lateral Raise',
            equipment: const ['Dumbbell'],
          ),
          6,
        ),
        12,
      );
      expect(
        service.debugEffectiveTargetReps(
          _definition(
            name: 'Dumbbell Lateral Raise',
            equipment: const ['Dumbbell'],
          ),
          4,
        ),
        10,
      );
      expect(
        service.debugEffectiveTargetReps(
          _definition(name: 'Face Pull - Cable', equipment: const ['Cable']),
          SessionSpec.defaultTargetRepCount,
        ),
        15,
      );
      expect(
        service.debugEffectiveTargetReps(
          _definition(
            name: 'Bench Press - Barbell',
            equipment: const ['Barbell'],
          ),
          15,
        ),
        8,
      );
    });

    test('hard intensity is still a working weight, not a direct max', () {
      const estimatedOneRepMax = 120.0;
      final directSixRepMax = estimatedOneRepMax / (1 + 6 / 30.0);
      final hardWorkingWeight = service.debugWorkingWeightFromOneRepMax(
        oneRepMaxEstimate: estimatedOneRepMax,
        targetReps: 6,
        additionalRir: 0,
        intensity: StarterWeightIntensity.hard,
      );
      final mediumWorkingWeight = service.debugWorkingWeightFromOneRepMax(
        oneRepMaxEstimate: estimatedOneRepMax,
        targetReps: 6,
        additionalRir: 0,
        intensity: StarterWeightIntensity.medium,
      );
      final easyWorkingWeight = service.debugWorkingWeightFromOneRepMax(
        oneRepMaxEstimate: estimatedOneRepMax,
        targetReps: 6,
        additionalRir: 0,
        intensity: StarterWeightIntensity.easy,
      );

      expect(hardWorkingWeight, lessThan(directSixRepMax));
      expect(mediumWorkingWeight, lessThan(hardWorkingWeight));
      expect(easyWorkingWeight, lessThan(mediumWorkingWeight));
    });

    test('extra straight-set RIR lowers the working weight', () {
      final normalMedium = service.debugWorkingWeightFromOneRepMax(
        oneRepMaxEstimate: 200,
        targetReps: 8,
        additionalRir: 0,
        intensity: StarterWeightIntensity.medium,
      );
      final highVolumeMedium = service.debugWorkingWeightFromOneRepMax(
        oneRepMaxEstimate: 200,
        targetReps: 8,
        additionalRir: 2,
        intensity: StarterWeightIntensity.medium,
      );

      expect(highVolumeMedium, lessThan(normalMedium));
    });

    test(
      'optimized fatigue lowers weight targets for recently worked areas',
      () {
        final chest = BodyPart(1, 'Chest');
        final candidate = CandidateExercisePlan(
          def: _definition(
            name: 'Bench Press - Barbell',
            equipment: const ['Barbell'],
          ),
          unitsPerSet: {chest: 1.0},
          score: 1,
          suggestedSets: 3,
        );
        final spec = SessionSpec(
          profileId: 1,
          name: 'Optimized',
          focusBodypartIds: const [],
          avoidMostRecentBodyPart: true,
          useRecentTrainingHistory: true,
          now: DateTime(2026, 1, 1),
        );

        expect(
          service.debugOptimizedFatigueMultiplier(
            spec: spec,
            candidate: candidate,
            bodyTargets: [
              BodyPartTarget(
                bodyPart: chest,
                weeklyTargetUnits: 10,
                doneThisWeek: 9,
              ),
            ],
          ),
          0.95,
        );
        expect(
          service.debugOptimizedFatigueMultiplier(
            spec: spec.copyWith(avoidMostRecentBodyPart: false),
            candidate: candidate,
            bodyTargets: [
              BodyPartTarget(
                bodyPart: chest,
                weeklyTargetUnits: 10,
                doneThisWeek: 9,
              ),
            ],
          ),
          1.0,
        );
      },
    );
  });
}

ExerciseDefinition _definition({
  required String name,
  List<String> equipment = const [],
}) {
  return ExerciseDefinition(
    id: 1,
    name: name,
    equipmentList: [
      for (var i = 0; i < equipment.length; i++) Equipment(i + 1, equipment[i]),
    ],
    useManualBodyparts: false,
    multiplyByRating: false,
  );
}
