import 'dart:convert';
import 'dart:io';

import 'package:env_test/models/definition_models.dart';
import 'package:flutter_test/flutter_test.dart';

const _requiredExerciseFields = {
  'name',
  'rating',
  'equipment',
  'bodyparts',
  'muscles',
  'setupNotes',
  'executionNotes',
  'tipsNotes',
  'catalogId',
  'legacyMediaId',
};

const _allowedExerciseFields = {
  ..._requiredExerciseFields,
  'aliases',
  'creatorAllocation',
  'multiplyByRating',
  'starterLoadProfile',
  'useManualBodyparts',
  'useManualMuscles',
};

const _allowedStarterProfileFields = {
  'type',
  'easy',
  'medium',
  'hard',
  'minimumWeight',
  'maximumWeight',
  'roundingIncrement',
  'unitMode',
  'confidence',
  'note',
};

const _mojibakeFragments = ['Ã', 'Â', 'â€'];

void main() {
  test(
    'shipped exercise catalog satisfies the data-quality audit contract',
    () async {
      final catalog = await _readObject('assets/exercises.json');
      expect(catalog.keys.toSet(), equals({'revision', 'exercises'}));
      expect(catalog['revision'], isA<int>());
      expect(catalog['revision'], greaterThanOrEqualTo(1));

      final exercises = _objectList(catalog['exercises'], 'catalog exercises');
      expect(exercises, isNotEmpty);
      final equipment = await _readReferenceNames('assets/equipment.json');
      final bodyParts = await _readReferenceNames('assets/bodyparts.json');
      final muscles = await _readReferenceNames('assets/muscles.json');

      final catalogNames = <String>{};
      final catalogIds = <String>{};
      final catalogByLegacyId = <int, Map<String, dynamic>>{};
      for (final exercise in exercises) {
        _expectRequiredAndKnownFields(exercise);

        final name = _expectCleanText(exercise['name'], 'exercise name');
        expect(
          catalogNames.add(_normalize(name)),
          isTrue,
          reason: 'Catalog exercise names must be unique ignoring case.',
        );
        final catalogId = _expectCleanText(
          exercise['catalogId'],
          '$name catalog ID',
        );
        expect(
          catalogIds.add(catalogId),
          isTrue,
          reason: '$name repeats a stable catalog ID.',
        );

        final legacyMediaId = exercise['legacyMediaId'];
        expect(legacyMediaId, isA<int>());
        expect(legacyMediaId, greaterThan(0));
        expect(
          catalogByLegacyId.putIfAbsent(legacyMediaId as int, () => exercise),
          same(exercise),
          reason: '$name repeats a legacy media identity.',
        );
      }

      for (var index = 1; index < exercises.length; index++) {
        final previous = exercises[index - 1]['name'] as String;
        final current = exercises[index]['name'] as String;
        expect(
          _normalize(previous).compareTo(_normalize(current)),
          lessThanOrEqualTo(0),
          reason: 'Keep exercises.json alphabetized by display name.',
        );
      }

      final aliases = <String>{};
      for (final exercise in exercises) {
        final name = _expectCleanText(exercise['name'], 'exercise name');
        _expectRating(exercise['rating'], name);
        _expectCatalogId(exercise['catalogId'], name);
        _expectReferenceList(
          exercise['equipment'],
          field: 'equipment',
          owner: name,
          allowedNames: equipment,
        );
        _expectReferenceList(
          exercise['bodyparts'],
          field: 'bodyparts',
          owner: name,
          allowedNames: bodyParts,
        );
        _expectMuscles(exercise['muscles'], name, muscles);
        _expectInstructionNotes(exercise, name);
        _expectAliases(exercise['aliases'], name, catalogNames, aliases);
        _expectOptionalFlags(exercise, name);
        _expectStarterLoadProfile(exercise['starterLoadProfile'], name);
        _expectCreatorAllocation(
          exercise['creatorAllocation'],
          name,
          muscles,
          bodyParts,
        );
      }
    },
  );

  test(
    'reviewed exercise variants retain movement-specific guidance',
    () async {
      final catalog = await _readObject('assets/exercises.json');
      final exercises = _objectList(catalog['exercises'], 'catalog exercises');
      final byCatalogId = <String, Map<String, dynamic>>{
        for (final exercise in exercises)
          exercise['catalogId'] as String: exercise,
      };

      expect(
        byCatalogId,
        isNot(contains('tonos.exercise.0054')),
        reason:
            'The unsupported donkey-kick/leg-extension duplicate must stay '
            'retired.',
      );

      const requiredGuidance = <String, List<String>>{
        'tonos.exercise.0006': ['bar', 'shoulder-width', 'rack safeties'],
        'tonos.exercise.0021': ['bar', 'bench', 'front foot'],
        'tonos.exercise.0029': ['assistance', 'parallel bars', 'press through'],
        'tonos.exercise.0034': [
          'assistance',
          'pull-up handles',
          'pull your chest',
        ],
        'tonos.exercise.0055': ['cable', 'diagonally', 'switch sides'],
        'tonos.exercise.0064': ['floor', 'dumbbell', 'upper arms'],
        'tonos.exercise.0065': ['floor', 'bar', 'safety supports'],
        'tonos.exercise.0069': ['cable', 'rope', 'pulls you forward'],
        'tonos.exercise.0070': ['dumbbell', 'shoulder-width', 'chest drops'],
        'tonos.exercise.0088': [
          'ankle',
          'away from the machine',
          'switch sides',
        ],
        'tonos.exercise.0089': ['ankle', 'across the front', 'switch sides'],
        'tonos.exercise.0099': ['incline bench', 'wide arc', 'very light'],
        'tonos.exercise.0109': [
          'raised surface',
          'straight line',
          'cannot move',
        ],
        'tonos.exercise.0126': ['kneel', 'high cable', 'torso upright'],
        'tonos.exercise.0127': [
          'kneel',
          'rope behind your head',
          'upper arms still',
        ],
        'tonos.exercise.0139': [
          'cable cuff',
          'heel behind you',
          'switch sides',
        ],
        'tonos.exercise.0151': [
          'dumbbell',
          'between your feet',
          'hold the dumbbell securely',
        ],
      };
      const forbiddenGuidance = <String, List<String>>{
        'tonos.exercise.0006': ['bench', 'front foot'],
        'tonos.exercise.0029': ['pull-up handles', 'pull your chest'],
        'tonos.exercise.0034': ['parallel bars', 'assisted dip'],
        'tonos.exercise.0069': ['bar in a rack'],
        'tonos.exercise.0070': ['bar in a rack'],
        'tonos.exercise.0088': ['seat and pads', 'push your knees apart'],
        'tonos.exercise.0089': ['seat and pads', 'bring your knees together'],
        'tonos.exercise.0109': ['hands on the floor'],
        'tonos.exercise.0126': ['thighs secured', 'sit tall'],
        'tonos.exercise.0127': ['stand, sit, or lie'],
        'tonos.exercise.0139': ['machine pivot', 'pull the pad'],
        'tonos.exercise.0151': ['machine pivot', 'pull the pad'],
      };

      for (final expectation in requiredGuidance.entries) {
        final exercise = byCatalogId[expectation.key];
        expect(
          exercise,
          isNotNull,
          reason: '${expectation.key} is a reviewed catalog identity.',
        );
        final guidance =
            [
              exercise!['setupNotes'],
              exercise['executionNotes'],
              exercise['tipsNotes'],
            ].join('\n').toLowerCase();

        for (final phrase in expectation.value) {
          expect(
            guidance,
            contains(phrase),
            reason: '${exercise['name']} must retain "$phrase" guidance.',
          );
        }
        for (final phrase
            in forbiddenGuidance[expectation.key] ?? const <String>[]) {
          expect(
            guidance,
            isNot(contains(phrase)),
            reason: '${exercise['name']} contains copied "$phrase" guidance.',
          );
        }
      }
    },
  );

  test(
    'exercise media source maps only to current catalog identities',
    () async {
      final catalog = await _readObject('assets/exercises.json');
      final exercises = _objectList(catalog['exercises'], 'catalog exercises');
      final byLegacyId = <int, Map<String, dynamic>>{
        for (final exercise in exercises)
          exercise['legacyMediaId'] as int: exercise,
      };

      final source = await _readObject(
        'tools/content_pipeline/exercise_media_source.example.json',
      );
      final mediaExercises = _objectList(
        source['exercises'],
        'exercise media source exercises',
      );
      final mediaIds = <int>{};

      for (final mediaExercise in mediaExercises) {
        final exerciseId = mediaExercise['exerciseId'];
        expect(exerciseId, isA<int>());
        expect(exerciseId, greaterThan(0));
        expect(
          mediaIds.add(exerciseId as int),
          isTrue,
          reason: 'Exercise media source repeats ID $exerciseId.',
        );

        final catalogExercise = byLegacyId[exerciseId];
        expect(
          catalogExercise,
          isNotNull,
          reason:
              'Media source ID $exerciseId has no current catalog exercise.',
        );
        final mediaName = _expectCleanText(
          mediaExercise['exerciseName'],
          'media exercise name',
        );
        final acceptedNames = <String>{
          _normalize(catalogExercise!['name'] as String),
          for (final alias in (catalogExercise['aliases'] as List? ?? const []))
            _normalize(alias as String),
        };
        expect(
          acceptedNames,
          contains(_normalize(mediaName)),
          reason:
              'Media source name "$mediaName" must match the current catalog '
              'name or a declared alias for ${catalogExercise['name']}.',
        );

        final assets = _objectList(mediaExercise['assets'], 'media assets');
        expect(assets, isNotEmpty);
        for (final asset in assets) {
          _expectCleanText(asset['assetId'], 'media asset ID');
          _expectCleanText(asset['title'], 'media asset title');
          expect(asset['type'], isA<String>());
          expect(asset['sortOrder'], isA<int>());
          expect(asset['version'], isA<int>());
        }
      }
    },
  );
}

Future<Map<String, dynamic>> _readObject(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  expect(decoded, isA<Map>());
  return Map<String, dynamic>.from(decoded as Map);
}

Future<Set<String>> _readReferenceNames(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  expect(decoded, isA<List>());
  final names = <String>{};
  for (final rawEntry in decoded as List) {
    expect(rawEntry, isA<Map>());
    final entry = Map<String, dynamic>.from(rawEntry as Map);
    final name = _expectCleanText(entry['name'], '$path reference name');
    expect(names.add(_normalize(name)), isTrue);
  }
  return names;
}

List<Map<String, dynamic>> _objectList(Object? value, String description) {
  expect(value, isA<List>(), reason: '$description must be a list.');
  return (value as List)
      .map((rawEntry) {
        expect(
          rawEntry,
          isA<Map>(),
          reason: '$description must contain objects.',
        );
        return Map<String, dynamic>.from(rawEntry as Map);
      })
      .toList(growable: false);
}

void _expectRequiredAndKnownFields(Map<String, dynamic> exercise) {
  for (final field in _requiredExerciseFields) {
    expect(exercise.containsKey(field), isTrue, reason: 'Missing $field.');
  }
  final unknownFields =
      exercise.keys
          .where((field) => !_allowedExerciseFields.contains(field))
          .toList();
  expect(unknownFields, isEmpty, reason: 'Unknown catalog fields are unsafe.');
}

void _expectRating(Object? value, String name) {
  expect(value, isA<int>(), reason: '$name needs an integer rating.');
  expect(
    value as int,
    inInclusiveRange(0, 100),
    reason: '$name has a rating outside the supported 0-100 range.',
  );
}

void _expectCatalogId(Object? value, String name) {
  final catalogId = _expectCleanText(value, '$name catalog ID');
  expect(
    RegExp(r'^tonos\.exercise\.\d{4}$').hasMatch(catalogId),
    isTrue,
    reason: '$name has an invalid catalog ID.',
  );
}

void _expectReferenceList(
  Object? value, {
  required String field,
  required String owner,
  required Set<String> allowedNames,
}) {
  expect(value, isA<List>(), reason: '$owner $field must be a list.');
  final values = value as List;
  expect(values, isNotEmpty, reason: '$owner needs at least one $field value.');
  final normalizedValues = <String>{};
  for (final rawValue in values) {
    final text = _expectCleanText(rawValue, '$owner $field');
    final normalized = _normalize(text);
    expect(
      normalizedValues.add(normalized),
      isTrue,
      reason: '$owner repeats $field "$text".',
    );
    expect(
      allowedNames,
      contains(normalized),
      reason: '$owner references unknown $field "$text".',
    );
  }
}

void _expectMuscles(Object? value, String owner, Set<String> allowedNames) {
  expect(value, isA<List>(), reason: '$owner muscles must be a list.');
  final rawMuscles = value as List;
  expect(rawMuscles, isNotEmpty, reason: '$owner needs at least one muscle.');
  final names = <String>{};
  final ranks = <int>{};
  for (final rawMuscle in rawMuscles) {
    expect(rawMuscle, isA<Map>(), reason: '$owner has a malformed muscle.');
    final muscle = Map<String, dynamic>.from(rawMuscle as Map);
    expect(muscle.keys.toSet(), equals({'name', 'rank'}));
    final name = _expectCleanText(muscle['name'], '$owner muscle name');
    final normalized = _normalize(name);
    expect(
      names.add(normalized),
      isTrue,
      reason: '$owner repeats muscle $name.',
    );
    expect(
      allowedNames,
      contains(normalized),
      reason: '$owner references unknown muscle "$name".',
    );
    expect(
      muscle['rank'],
      isA<int>(),
      reason: '$owner has a non-integer rank.',
    );
    final rank = muscle['rank'] as int;
    expect(rank, greaterThan(0), reason: '$owner has a non-positive rank.');
    expect(
      ranks.add(rank),
      isTrue,
      reason: '$owner repeats muscle rank $rank.',
    );
  }
  expect(
    ranks,
    equals({for (var rank = 1; rank <= rawMuscles.length; rank++) rank}),
    reason: '$owner muscle ranks must be sequential, starting at 1.',
  );
}

void _expectInstructionNotes(Map<String, dynamic> exercise, String name) {
  _expectNumberedLines(exercise['setupNotes'], '$name setup notes');
  _expectNumberedLines(exercise['executionNotes'], '$name execution notes');
  _expectBulletLines(exercise['tipsNotes'], '$name tips notes');
}

void _expectNumberedLines(Object? value, String field) {
  final text = _expectCleanText(value, field);
  final lines = text.split('\n');
  expect(lines, hasLength(3), reason: '$field needs exactly three steps.');
  for (var index = 0; index < lines.length; index++) {
    expect(
      lines[index],
      matches(RegExp('^${index + 1}\\.\\s+\\S.*\$')),
      reason: '$field step ${index + 1} is invalid.',
    );
    expect(lines[index].length, lessThanOrEqualTo(100));
  }
}

void _expectBulletLines(Object? value, String field) {
  final text = _expectCleanText(value, field);
  final lines = text.split('\n');
  expect(lines, hasLength(3), reason: '$field needs exactly three tips.');
  for (final line in lines) {
    expect(line, matches(RegExp(r'^-\s+\S.*$')), reason: '$field is invalid.');
    expect(line.length, lessThanOrEqualTo(100));
  }
}

void _expectAliases(
  Object? value,
  String owner,
  Set<String> catalogNames,
  Set<String> aliases,
) {
  if (value == null) return;
  expect(value, isA<List>(), reason: '$owner aliases must be a list.');
  for (final rawAlias in value as List) {
    final alias = _expectCleanText(rawAlias, '$owner alias');
    final normalized = _normalize(alias);
    expect(normalized, isNot(_normalize(owner)));
    expect(catalogNames, isNot(contains(normalized)));
    expect(
      aliases.add(normalized),
      isTrue,
      reason: 'Duplicate alias "$alias".',
    );
  }
}

void _expectOptionalFlags(Map<String, dynamic> exercise, String name) {
  for (final field in const [
    'multiplyByRating',
    'useManualBodyparts',
    'useManualMuscles',
  ]) {
    if (exercise.containsKey(field)) {
      expect(
        exercise[field],
        isA<bool>(),
        reason: '$name $field must be true or false.',
      );
    }
  }
}

void _expectStarterLoadProfile(Object? value, String owner) {
  if (value == null) return;
  expect(
    value,
    isA<Map>(),
    reason: '$owner starter profile must be an object.',
  );
  final profile = Map<String, dynamic>.from(value as Map);
  final unknownFields =
      profile.keys
          .where((field) => !_allowedStarterProfileFields.contains(field))
          .toList();
  expect(
    unknownFields,
    isEmpty,
    reason: '$owner starter profile has unknown fields.',
  );

  final type = _expectCleanText(profile['type'], '$owner starter profile type');
  final supportedTypes =
      StarterLoadType.values
          .where((candidate) => candidate != StarterLoadType.unknown)
          .map((candidate) => candidate.name)
          .toSet();
  expect(supportedTypes, contains(type));

  final easy = _expectNonNegativeNumber(profile['easy'], '$owner easy load');
  final medium = _expectNonNegativeNumber(
    profile['medium'],
    '$owner medium load',
  );
  final hard = _expectNonNegativeNumber(profile['hard'], '$owner hard load');
  expect(easy, lessThanOrEqualTo(medium));
  expect(medium, lessThanOrEqualTo(hard));
  final minimum = _expectNonNegativeNumber(
    profile['minimumWeight'],
    '$owner minimum starter load',
  );
  final maximum = profile['maximumWeight'];
  if (maximum != null) {
    expect(
      _expectNonNegativeNumber(maximum, '$owner maximum starter load'),
      greaterThanOrEqualTo(minimum),
    );
  }
  expect(
    _expectNonNegativeNumber(
      profile['roundingIncrement'],
      '$owner rounding increment',
    ),
    greaterThan(0),
  );
  expect(const {
    'total',
    'perHand',
    'perSide',
  }, contains(_expectCleanText(profile['unitMode'], '$owner unit mode')));
  expect(const {
    'high',
    'medium',
    'low',
  }, contains(_expectCleanText(profile['confidence'], '$owner confidence')));
  _expectCleanText(profile['note'], '$owner starter note');
}

void _expectCreatorAllocation(
  Object? value,
  String owner,
  Set<String> muscles,
  Set<String> bodyParts,
) {
  if (value == null) return;
  expect(
    value,
    isA<Map>(),
    reason: '$owner creator allocation must be an object.',
  );
  final allocation = Map<String, dynamic>.from(value as Map);
  final dimensions = <String, Set<String>>{
    'muscles': muscles,
    'bodyparts': bodyParts,
  };
  final unknownDimensions =
      allocation.keys
          .where((dimension) => !dimensions.containsKey(dimension))
          .toList();
  expect(
    unknownDimensions,
    isEmpty,
    reason: '$owner has an unknown allocation dimension.',
  );
  for (final entry in allocation.entries) {
    expect(entry.value, isA<Map>());
    for (final credit in (entry.value as Map).entries) {
      final reference = _expectCleanText(
        credit.key,
        '$owner ${entry.key} allocation target',
      );
      expect(dimensions[entry.key], contains(_normalize(reference)));
      _expectNonNegativeNumber(
        credit.value,
        '$owner ${entry.key} allocation credit',
      );
    }
  }
}

double _expectNonNegativeNumber(Object? value, String field) {
  expect(value, isA<num>(), reason: '$field must be numeric.');
  final number = (value as num).toDouble();
  expect(number.isFinite, isTrue, reason: '$field must be finite.');
  expect(number, greaterThanOrEqualTo(0), reason: '$field cannot be negative.');
  return number;
}

String _expectCleanText(Object? value, String field) {
  expect(value, isA<String>(), reason: '$field must be text.');
  final text = value as String;
  expect(text, isNotEmpty, reason: '$field cannot be empty.');
  expect(
    text,
    text.trim(),
    reason: '$field cannot have surrounding whitespace.',
  );
  expect(
    RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\uFFFD]').hasMatch(text),
    isFalse,
    reason: '$field contains a control or replacement character.',
  );
  expect(
    _mojibakeFragments.any(text.contains),
    isFalse,
    reason: '$field appears to contain mojibake.',
  );
  return text;
}

String _normalize(String value) => value.trim().toLowerCase();
