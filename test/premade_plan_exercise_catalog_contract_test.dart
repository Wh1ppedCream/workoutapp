import 'dart:convert';
import 'dart:io';

import 'package:env_test/data/premade_training_plans.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every built-in premade exercise has a matching catalog identity',
    () async {
      final decoded =
          jsonDecode(await File('assets/exercises.json').readAsString())
              as Map<String, dynamic>;
      final catalogById = <String, Map<String, dynamic>>{
        for (final rawExercise in (decoded['exercises'] as List))
          (rawExercise as Map<String, dynamic>)['catalogId'] as String:
              rawExercise,
      };
      final planExercises = premadeTrainingPlans
          .expand((plan) => plan.exercises)
          .toList(growable: false);

      expect(planExercises, isNotEmpty);
      for (final exercise in planExercises) {
        final catalogId = exercise.catalogId;
        expect(
          catalogId,
          isNotNull,
          reason: 'Add a stable exercise catalog ID for ${exercise.name}.',
        );
        if (catalogId == null) continue;
        final catalogExercise = catalogById[catalogId];
        expect(
          catalogExercise,
          isNotNull,
          reason: 'Premade exercise ${exercise.name} uses unknown $catalogId.',
        );
        expect(
          catalogExercise?['name'],
          exercise.name,
          reason:
              'Update the premade identity lookup after an intentional rename.',
        );
      }
    },
  );

  test(
    'every built-in premade equipment label has a matching catalog identity',
    () async {
      final decoded =
          jsonDecode(
                await File(
                  'assets/catalog_entity_registry.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;
      final equipmentByName = <String, String>{
        for (final rawEquipment in (decoded['equipment'] as List))
          (rawEquipment as Map<String, dynamic>)['canonicalName'] as String:
              rawEquipment['catalogId'] as String,
      };
      final planExercises = premadeTrainingPlans
          .expand((plan) => plan.exercises)
          .toList(growable: false);

      expect(planExercises, isNotEmpty);
      for (final exercise in planExercises) {
        final equipmentName = exercise.equipment.trim();
        if (equipmentName.isEmpty) {
          expect(exercise.equipmentCatalogId, isNull);
          continue;
        }

        final expectedCatalogId = equipmentByName[equipmentName];
        expect(
          expectedCatalogId,
          isNotNull,
          reason:
              'Add the premade equipment to the catalog registry: $equipmentName.',
        );
        expect(
          exercise.equipmentCatalogId,
          expectedCatalogId,
          reason:
              'Update the premade equipment identity after an intentional rename.',
        );
      }
    },
  );
}
