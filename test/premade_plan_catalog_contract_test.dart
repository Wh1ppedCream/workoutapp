import 'dart:convert';
import 'dart:io';

import 'package:env_test/data/premade_training_plans.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premade plans resolve to current shipped catalog definitions', () {
    final catalog =
        jsonDecode(File('assets/exercises.json').readAsStringSync())
            as Map<String, dynamic>;
    final exercises =
        (catalog['exercises'] as List).cast<Map<String, dynamic>>();
    final catalogByName = <String, Map<String, dynamic>>{
      for (final exercise in exercises) exercise['name'] as String: exercise,
    };

    for (final plan in premadeTrainingPlans) {
      for (final plannedExercise in plan.exercises) {
        final catalogExercise = catalogByName[plannedExercise.name];
        expect(
          catalogExercise,
          isNotNull,
          reason:
              '${plan.id} references ${plannedExercise.name}, which is not a '
              'current catalog name. Premade plans must use exact current '
              'names so copying a plan cannot create a duplicate definition.',
        );

        final supportedEquipment =
            (catalogExercise!['equipment'] as List).cast<String>();
        expect(
          supportedEquipment,
          contains(plannedExercise.equipment),
          reason:
              '${plan.id} uses ${plannedExercise.equipment} for '
              '${plannedExercise.name}, but the catalog supports only '
              '${supportedEquipment.join(', ')}.',
        );
      }
    }
  });
}
