import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'shipped exercise catalog has stable IDs and alphabetical display order',
    () async {
      final source = await File('assets/exercises.json').readAsString();
      final catalog = jsonDecode(source) as Map<String, dynamic>;
      final exercises =
          (catalog['exercises'] as List).cast<Map<String, dynamic>>();

      expect(catalog['revision'], isA<int>());
      expect(catalog['revision'], greaterThanOrEqualTo(1));
      expect(exercises, isNotEmpty);

      final catalogIds =
          exercises.map((exercise) => exercise['catalogId'] as String).toList();
      final legacyMediaIds =
          exercises
              .map((exercise) => exercise['legacyMediaId'] as int)
              .toList();
      expect(catalogIds.toSet(), hasLength(exercises.length));
      expect(legacyMediaIds.toSet(), hasLength(exercises.length));
      final names =
          exercises
              .map((exercise) => (exercise['name'] as String).toLowerCase())
              .toSet();
      expect(names, hasLength(exercises.length));
      final aliases = <String>{};
      for (final exercise in exercises) {
        expect(
          (exercise['equipment'] as List? ?? const []).every(
            (value) => value is String && value.trim().isNotEmpty,
          ),
          isTrue,
          reason: '${exercise['name']} has an empty equipment relationship.',
        );
        expect(
          (exercise['bodyparts'] as List? ?? const []).every(
            (value) => value is String && value.trim().isNotEmpty,
          ),
          isTrue,
          reason: '${exercise['name']} has an empty body-part relationship.',
        );
        for (final muscle in (exercise['muscles'] as List? ?? const [])) {
          expect(muscle, isA<Map>());
          expect(
            (muscle as Map)['name'] is String &&
                ((muscle['name'] as String).trim().isNotEmpty),
            isTrue,
            reason: '${exercise['name']} has an empty muscle relationship.',
          );
          expect(
            muscle['rank'] is int && (muscle['rank'] as int) > 0,
            isTrue,
            reason: '${exercise['name']} has an invalid muscle rank.',
          );
        }
        final muscleNames =
            (exercise['muscles'] as List? ?? const [])
                .map((muscle) => (muscle as Map)['name'] as String)
                .map((name) => name.trim().toLowerCase())
                .toList();
        expect(
          muscleNames.toSet(),
          hasLength(muscleNames.length),
          reason: '${exercise['name']} repeats a muscle relationship.',
        );
        for (final alias in (exercise['aliases'] as List? ?? const [])) {
          final normalizedAlias = (alias as String).toLowerCase();
          expect(names, isNot(contains(normalizedAlias)));
          expect(aliases.add(normalizedAlias), isTrue);
        }
      }
      expect(
        catalogIds.every(
          (catalogId) =>
              RegExp(r'^tonos\.exercise\.\d{4}$').hasMatch(catalogId),
        ),
        isTrue,
      );

      for (var index = 1; index < exercises.length; index++) {
        final previous = exercises[index - 1]['name'] as String;
        final current = exercises[index]['name'] as String;
        expect(
          previous.toLowerCase().compareTo(current.toLowerCase()),
          lessThanOrEqualTo(0),
          reason: 'Keep exercises.json alphabetized by display name.',
        );
      }
    },
  );
}
