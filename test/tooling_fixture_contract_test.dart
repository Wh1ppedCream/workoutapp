import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content-pipeline JSON fixtures remain parseable', () {
    final files =
        Directory('tools/content_pipeline')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(files, isNotEmpty);
    for (final file in files) {
      expect(
        () => jsonDecode(file.readAsStringSync()),
        returnsNormally,
        reason: '${file.path} must contain valid JSON.',
      );
    }
  });

  test('exercise-media identities and licenses match the catalog', () {
    final catalog = _readObject('assets/exercises.json');
    final exercises = _objectList(catalog, 'exercises');
    final byLegacyId = <int, Map<String, dynamic>>{
      for (final exercise in exercises)
        exercise['legacyMediaId'] as int: exercise,
    };
    final sourceFiles =
        Directory('tools/content_pipeline').listSync().whereType<File>().where((
            file,
          ) {
            final path = file.path.replaceAll('\\', '/');
            return RegExp(r'exercise_media.*\.source\.json$').hasMatch(path) ||
                path.endsWith('exercise_media_source.example.json');
          }).toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(sourceFiles.length, greaterThanOrEqualTo(10));
    for (final file in sourceFiles) {
      final source = _readObject(file.path);
      expect(source['namespace'], 'exercise_media');
      _expectHttps(source['baseUrl'], '${file.path} baseUrl');

      final seenExerciseIds = <int>{};
      final seenAssetIds = <String>{};
      for (final entry in _objectList(source, 'exercises')) {
        final exerciseId = entry['exerciseId'] as int;
        final exerciseName = entry['exerciseName'] as String;
        expect(
          seenExerciseIds.add(exerciseId),
          isTrue,
          reason: '${file.path} repeats exercise ID $exerciseId.',
        );

        final catalogExercise = byLegacyId[exerciseId];
        expect(
          catalogExercise,
          isNotNull,
          reason: '${file.path} references unknown exercise ID $exerciseId.',
        );
        final acceptedNames = <String>{
          catalogExercise!['name'] as String,
          ...((catalogExercise['aliases'] as List?) ?? const <dynamic>[])
              .cast<String>(),
        };
        expect(
          acceptedNames,
          contains(exerciseName),
          reason: '${file.path} maps $exerciseId to an unrecognized name.',
        );

        for (final asset in _objectList(entry, 'assets')) {
          final assetId = asset['assetId'] as String;
          expect(assetId.trim(), isNotEmpty);
          expect(
            seenAssetIds.add(assetId),
            isTrue,
            reason: '${file.path} repeats asset ID $assetId.',
          );
          _expectLicensed(asset, file.path);
          _expectSafeRemoteLocation(asset, file.path);
        }
      }
    }
  });

  test('shared equipment media stays tied to equipment fixtures', () {
    final equipment = jsonDecode(
      File('assets/equipment.json').readAsStringSync(),
    );
    final equipmentById = <int, String>{
      for (var index = 0; index < (equipment as List).length; index++)
        index + 1: (equipment[index] as Map<String, dynamic>)['name'] as String,
    };
    final source = _readObject(
      'tools/content_pipeline/shared_media_equipment_batch_001.source.json',
    );

    expect(source['namespace'], 'shared_media');
    _expectHttps(source['baseUrl'], 'shared-media baseUrl');
    final seenEntityIds = <int>{};
    final seenAssetIds = <String>{};
    for (final entity in _objectList(source, 'entities')) {
      final entityId = entity['entityId'] as int;
      expect(entity['entityType'], 'equipment');
      expect(seenEntityIds.add(entityId), isTrue);
      expect(equipmentById[entityId], entity['entityName']);
      for (final asset in _objectList(entity, 'assets')) {
        final assetId = asset['assetId'] as String;
        expect(seenAssetIds.add(assetId), isTrue);
        _expectLicensed(asset, 'shared equipment source');
        _expectSafeRemoteLocation(asset, 'shared equipment source');
      }
    }
  });

  test('food fixture declares dataset and asset provenance', () {
    final source = _readObject(
      'tools/content_pipeline/food_content_source.example.json',
    );
    final dataset = source['dataset'] as Map<String, dynamic>;

    expect(source['namespace'], 'food_content');
    _expectHttps(source['baseUrl'], 'food-content baseUrl');
    expect((dataset['source'] as String).trim(), isNotEmpty);
    expect((dataset['licenseId'] as String).trim(), isNotEmpty);
    for (final food in _objectList(source, 'foods')) {
      expect((food['source'] as String).trim(), isNotEmpty);
      expect((food['licenseId'] as String).trim(), isNotEmpty);
      for (final asset in _objectList(food, 'assets')) {
        _expectLicensed(asset, 'food source');
        _expectSafeRemoteLocation(asset, 'food source');
      }
    }
  });
}

Map<String, dynamic> _readObject(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _objectList(
  Map<String, dynamic> source,
  String key,
) {
  return (source[key] as List).cast<Map<String, dynamic>>();
}

void _expectLicensed(Map<String, dynamic> asset, String source) {
  expect(
    (asset['licenseId'] as String?)?.trim(),
    isNotEmpty,
    reason: '$source contains an asset without a license ID.',
  );
}

void _expectSafeRemoteLocation(Map<String, dynamic> asset, String source) {
  final url = asset['url'] as String?;
  if (url != null) {
    _expectHttps(url, '$source asset URL');
  }
  for (final key in ['path', 'remotePath', 'thumbnailPath']) {
    final path = asset[key] as String?;
    if (path == null) continue;
    expect(path, isNot(contains('..')));
    expect(path, isNot(startsWith('/')));
    expect(path, isNot(contains('\\')));
  }
  expect(
    asset.keys.any((key) => ['url', 'path', 'remotePath'].contains(key)),
    isTrue,
    reason: '$source contains an asset without a remote location.',
  );
}

void _expectHttps(Object? value, String label) {
  final uri = Uri.parse(value as String);
  expect(uri.scheme, 'https', reason: '$label must use HTTPS.');
  expect(uri.host, isNotEmpty, reason: '$label must include a host.');
}
