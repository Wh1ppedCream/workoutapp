import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'shipped exercise catalog has stable IDs and alphabetical display order',
    () async {
      final source = await File('assets/exercises.json').readAsString();
      final catalog = jsonDecode(source) as Map<String, dynamic>;
      final exercises = (catalog['exercises'] as List)
          .cast<Map<String, dynamic>>();

      expect(catalog['revision'], isA<int>());
      expect(catalog['revision'], greaterThanOrEqualTo(1));
      expect(exercises, isNotEmpty);

      final catalogIds = exercises
          .map((exercise) => exercise['catalogId'] as String)
          .toList();
      final legacyMediaIds = exercises
          .map((exercise) => exercise['legacyMediaId'] as int)
          .toList();
      expect(catalogIds.toSet(), hasLength(exercises.length));
      expect(legacyMediaIds.toSet(), hasLength(exercises.length));
      final names = exercises
          .map((exercise) => (exercise['name'] as String).toLowerCase())
          .toSet();
      expect(names, hasLength(exercises.length));
      final aliases = <String>{};
      for (final exercise in exercises) {
        final setupNotes = (exercise['setupNotes'] as String).split('\n');
        final executionNotes = (exercise['executionNotes'] as String).split(
          '\n',
        );
        final tipsNotes = (exercise['tipsNotes'] as String).split('\n');
        expect(
          setupNotes.length,
          greaterThanOrEqualTo(2),
          reason: '${exercise['name']} needs numbered setup instructions.',
        );
        expect(
          executionNotes.length,
          greaterThanOrEqualTo(2),
          reason: '${exercise['name']} needs numbered execution instructions.',
        );
        expect(
          tipsNotes.length,
          greaterThanOrEqualTo(2),
          reason: '${exercise['name']} needs bullet-point tips.',
        );
        for (var index = 0; index < setupNotes.length; index++) {
          expect(
            setupNotes[index],
            matches(RegExp('^${index + 1}\\.\\s+.+\$')),
            reason: '${exercise['name']} has invalid setup note numbering.',
          );
        }
        for (var index = 0; index < executionNotes.length; index++) {
          expect(
            executionNotes[index],
            matches(RegExp('^${index + 1}\\.\\s+.+\$')),
            reason: '${exercise['name']} has invalid execution note numbering.',
          );
        }
        for (final tip in tipsNotes) {
          expect(
            tip,
            matches(RegExp(r'^-\s+.+$')),
            reason: '${exercise['name']} has an invalid tip format.',
          );
        }
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
        final muscleNames = (exercise['muscles'] as List? ?? const [])
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

  test('named equipment variants have accurate primary equipment', () async {
    final source = await File('assets/exercises.json').readAsString();
    final catalog = jsonDecode(source) as Map<String, dynamic>;
    final exercises = (catalog['exercises'] as List)
        .cast<Map<String, dynamic>>();
    Map<String, dynamic> exercise(String name) => exercises.singleWhere(
      (entry) => entry['name'] == name,
      orElse: () => throw StateError('Missing exercise "$name".'),
    );

    expect(
      (exercise('Bicep Curl - Cable Machine')['equipment'] as List).first,
      'Cable Machine',
    );
    expect(
      (exercise('Bicep Curl - Resistance Band')['equipment'] as List).first,
      'Resistance Band',
    );
    expect(
      (exercise('Bicep Curl - Smith Machine')['equipment'] as List).first,
      'Smith Machine',
    );
    expect(
      (exercise('Bench Press - Barbell')['equipment'] as List).first,
      'Barbell',
    );
    expect(
      (exercise('Bench Press - Dumbbells')['equipment'] as List).first,
      'Dumbbell',
    );
    expect((exercise('Push-up')['equipment'] as List).first, 'Bodyweight');
  });

  test('Bench Press - Barbell setup guide describes bench setup', () async {
    final source = await File('assets/exercises.json').readAsString();
    final catalog = jsonDecode(source) as Map<String, dynamic>;
    final exercises = (catalog['exercises'] as List)
        .cast<Map<String, dynamic>>();
    final benchPress = exercises.singleWhere(
      (entry) => entry['catalogId'] == 'tonos.exercise.0007',
    );

    expect(
      benchPress['setupNotes'],
      contains('Lie on the bench with your eyes beneath the bar.'),
    );
    expect(benchPress['setupNotes'], isNot(contains('Sit or stand tall')));

    final translations = jsonDecode(
      await File('assets/exercise_content_localizations.json').readAsString(),
    ) as Map<String, dynamic>;
    final spanishSetup =
        (((translations['locales'] as Map)['es'] as Map)['tonos.exercise.0007']
                as Map)['setupNotes']
            as String;
    expect(spanishSetup, contains('Túmbate en el banco'));
    expect(spanishSetup, isNot(contains('Siéntate o ponte de pie')));
  });
}
