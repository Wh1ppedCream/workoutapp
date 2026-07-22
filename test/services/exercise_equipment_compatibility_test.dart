import 'package:env_test/models/models.dart';
import 'package:env_test/services/exercise_equipment_compatibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExerciseDefinition definition({
    required List<Equipment> equipment,
    int? primaryEquipmentId,
  }) {
    return ExerciseDefinition(
      id: 1,
      name: 'Example exercise',
      equipmentId: primaryEquipmentId,
      equipmentList: equipment,
      useManualBodyparts: false,
      multiplyByRating: false,
    );
  }

  final barbell = Equipment(1, 'Barbell');
  final bench = Equipment(2, 'Adjustable Bench');
  final cable = Equipment(3, 'Cable Machine');

  test('requires every listed equipment item for a profile', () {
    final exercise = definition(
      primaryEquipmentId: barbell.id,
      equipment: [barbell, bench],
    );

    expect(
      ExerciseEquipmentCompatibility.fitsProfileNames(exercise, ['Barbell']),
      isFalse,
    );
    expect(
      ExerciseEquipmentCompatibility.fitsProfileNames(exercise, [
        'Barbell',
        'Adjustable Bench',
      ]),
      isTrue,
    );
  });

  test('uses the complete list rather than the legacy primary equipment', () {
    final exercise = definition(
      primaryEquipmentId: barbell.id,
      equipment: [barbell, cable],
    );

    expect(
      ExerciseEquipmentCompatibility.fitsProfileIds(exercise, const [1]),
      isFalse,
    );
    expect(
      ExerciseEquipmentCompatibility.fitsProfileIds(exercise, const [1, 3]),
      isTrue,
    );
  });

  test('normalizes equipment names and accepts no-equipment exercises', () {
    final cableExercise = definition(equipment: [cable]);
    final noEquipmentExercise = definition(equipment: []);

    expect(
      ExerciseEquipmentCompatibility.fitsProfileNames(cableExercise, [
        '  cable machine ',
      ]),
      isTrue,
    );
    expect(
      ExerciseEquipmentCompatibility.fitsProfileNames(noEquipmentExercise, []),
      isTrue,
    );
  });

  test('matches a single equipment filter against all requirements', () {
    final exercise = definition(equipment: [barbell, bench]);

    expect(
      ExerciseEquipmentCompatibility.usesEquipmentName(
        exercise,
        'adjustable bench',
      ),
      isTrue,
    );
    expect(
      ExerciseEquipmentCompatibility.usesEquipmentName(
        exercise,
        'Cable Machine',
      ),
      isFalse,
    );
  });
}
