import 'package:env_test/models/models.dart';
import 'package:env_test/services/starter_weight_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StarterWeightRecommendationService', () {
    final service = StarterWeightRecommendationService();

    test('keeps bodyweight exercises at zero with bodyweight-only source', () {
      final result = service.recommend(
        definition: _definition(
          name: 'Push-Up',
          equipment: const ['Bodyweight'],
        ),
        intensity: StarterWeightIntensity.medium,
        targetReps: 10,
      );

      expect(result.weight, 0);
      expect(result.isBodyweightOnly, isTrue);
      expect(result.source, StarterWeightRecommendationSource.bodyweightOnly);
    });

    test('uses exercise profile estimates when bodyweight is available', () {
      final result = service.recommend(
        definition: _definition(
          name: 'Bench Press - Barbell',
          equipment: const ['Barbell', 'Weight Plates'],
        ),
        intensity: StarterWeightIntensity.medium,
        targetReps: 6,
        bodyWeightLbs: 200,
      );

      expect(result.weight, 70);
      expect(result.source, StarterWeightRecommendationSource.exerciseProfile);
    });

    test(
      'falls back to conservative equipment estimates without bodyweight',
      () {
        final result = service.recommend(
          definition: _definition(
            name: 'Bench Press - Barbell',
            equipment: const ['Barbell', 'Weight Plates'],
          ),
          intensity: StarterWeightIntensity.medium,
          targetReps: 8,
        );

        expect(result.weight, 55);
        expect(
          result.source,
          StarterWeightRecommendationSource.equipmentFallback,
        );
      },
    );

    test('keeps light starter profiles above zero after rounding', () {
      final result = service.recommend(
        definition: _definition(
          name: 'Lateral Raise - Dumbbell',
          equipment: const ['Dumbbell'],
        ),
        intensity: StarterWeightIntensity.easy,
        targetReps: 15,
      );

      expect(result.weight, 5);
      expect(result.source, StarterWeightRecommendationSource.exerciseProfile);
    });

    test('uses total-stack mode for cable lateral raises', () {
      final result = service.recommend(
        definition: _definition(
          name: 'Lateral Raise - Cable Machine',
          equipment: const ['Cable Machine'],
        ),
        intensity: StarterWeightIntensity.medium,
        targetReps: 12,
      );

      expect(result.weight, greaterThan(0));
      expect(result.unitMode, StarterLoadUnitMode.total);
    });

    test('marks unsupported exercises unavailable instead of pretending', () {
      final result = service.recommend(
        definition: _definition(name: 'Mystery Movement'),
        intensity: StarterWeightIntensity.medium,
        targetReps: 10,
      );

      expect(result.isAvailable, isFalse);
      expect(result.weight, 0);
      expect(result.source, StarterWeightRecommendationSource.unavailable);
    });
  });
}

ExerciseDefinition _definition({
  required String name,
  List<String> equipment = const [],
  List<String> bodyParts = const [],
  StarterLoadProfile? starterLoadProfile,
}) {
  return ExerciseDefinition(
    id: 1,
    name: name,
    equipmentList: _equipmentList(equipment),
    bodyParts: _bodyPartList(bodyParts),
    useManualBodyparts: false,
    multiplyByRating: false,
    starterLoadProfile: starterLoadProfile,
  );
}

List<Equipment> _equipmentList(List<String> names) {
  final items = <Equipment>[];
  for (var i = 0; i < names.length; i++) {
    items.add(Equipment(i + 1, names[i]));
  }
  return items;
}

List<BodyPart> _bodyPartList(List<String> names) {
  final items = <BodyPart>[];
  for (var i = 0; i < names.length; i++) {
    items.add(BodyPart(i + 1, names[i]));
  }
  return items;
}
