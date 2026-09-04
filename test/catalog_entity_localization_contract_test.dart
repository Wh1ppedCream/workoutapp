import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = ['es', 'fr', 'bn', 'zh', 'hi'];

  test(
    'all built-in equipment has one localized label per supported locale',
    () {
      final registry =
          jsonDecode(
                File('assets/catalog_entity_registry.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final bundle =
          jsonDecode(
                File(
                  'assets/catalog_entity_localizations.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final equipmentIds =
          (registry['equipment'] as List<Object?>)
              .cast<Map<String, Object?>>()
              .map((entry) => entry['catalogId'] as String)
              .toSet();
      final names = bundle['names'] as Map<String, dynamic>;

      for (final locale in locales) {
        final localeNames = names[locale] as Map<String, dynamic>;
        final localizedEquipment =
            localeNames.keys
                .where((id) => id.startsWith('tonos.equipment.'))
                .toSet();
        expect(localizedEquipment, containsAll(equipmentIds));
        expect(localizedEquipment, hasLength(equipmentIds.length));
        for (final id in equipmentIds) {
          expect(localeNames[id], isA<String>());
          expect((localeNames[id] as String).trim(), isNotEmpty);
        }
      }
    },
  );

  test('completed muscle locale batches cover every built-in muscle', () {
    final registry =
        jsonDecode(
              File('assets/catalog_entity_registry.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final bundle =
        jsonDecode(
              File(
                'assets/catalog_entity_localizations.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final muscleIds =
        (registry['muscles'] as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((entry) => entry['catalogId'] as String)
            .toSet();
    final names = bundle['names'] as Map<String, dynamic>;

    for (final locale in const ['es', 'fr', 'bn', 'zh', 'hi']) {
      final localeNames = names[locale] as Map<String, dynamic>;
      final localizedMuscles =
          localeNames.keys
              .where((id) => id.startsWith('tonos.muscle.'))
              .toSet();
      expect(localizedMuscles, containsAll(muscleIds));
      expect(localizedMuscles, hasLength(muscleIds.length));
      for (final id in muscleIds) {
        expect(localeNames[id], isA<String>());
        expect((localeNames[id] as String).trim(), isNotEmpty);
      }
    }
  });
}
