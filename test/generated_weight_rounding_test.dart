import 'package:env_test/models/models.dart';
import 'package:env_test/utils/generated_weight_rounding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneratedWeightRounding', () {
    test('rounds barbell loads to five-pound increments', () {
      final result = GeneratedWeightRounding.roundForExercise(
        definition: _definition(
          name: 'Bench Press - Barbell',
          equipment: const ['Barbell', 'Weight Plates'],
        ),
        weight: 192.3,
      );

      expect(result, 190);
    });

    test('rounds cable loads to ten-pound increments', () {
      final result = GeneratedWeightRounding.roundForExercise(
        definition: _definition(
          name: 'Lat Pulldown - Lat Pulldown Machine',
          equipment: const ['Lat Pulldown Machine'],
        ),
        weight: 46,
      );

      expect(result, 50);
    });

    test('can round cable loads down for conservative generated weights', () {
      final result = GeneratedWeightRounding.roundForExercise(
        definition: _definition(
          name: 'Cable Chest Fly',
          equipment: const ['Cable Machine'],
        ),
        weight: 46,
        direction: GeneratedWeightRoundingDirection.down,
      );

      expect(result, 40);
    });

    test('can round down while respecting a minimum load', () {
      final result = GeneratedWeightRounding.roundForExercise(
        definition: _definition(
          name: 'Barbell Squat',
          equipment: const ['Barbell', 'Weight Plates'],
        ),
        weight: 42,
        direction: GeneratedWeightRoundingDirection.down,
        minimumWeight: 45,
      );

      expect(result, 45);
    });

    test('reports generated minimums for common equipment families', () {
      expect(
        GeneratedWeightRounding.minimumForExercise(
          _definition(
            name: 'Bench Press - Barbell',
            equipment: const ['Barbell', 'Weight Plates'],
          ),
        ),
        45,
      );
      expect(
        GeneratedWeightRounding.minimumForExercise(
          _definition(name: 'Dumbbell Curl', equipment: const ['Dumbbell']),
        ),
        5,
      );
      expect(
        GeneratedWeightRounding.minimumForExercise(
          _definition(name: 'Push-Up', equipment: const ['Bodyweight']),
        ),
        0,
      );
    });
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
