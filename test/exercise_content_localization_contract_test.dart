import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'localized exercise content has valid catalog IDs and guidance sections',
    () async {
      final catalog =
          jsonDecode(await File('assets/exercises.json').readAsString())
              as Map<String, dynamic>;
      final catalogIds =
          (catalog['exercises'] as List)
              .cast<Map<String, dynamic>>()
              .map((exercise) => exercise['catalogId'] as String)
              .toSet();
      final bundle =
          jsonDecode(
                await File(
                  'assets/exercise_content_localizations.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;

      expect(bundle['version'], 1);
      final locales = bundle['locales'] as Map<String, dynamic>;
      final coverage = bundle['coverage'] as Map<String, dynamic>;
      for (final locale in locales.entries) {
        expect(locale.key, matches(RegExp(r'^[a-z]{2,3}(?:_[A-Z]{2})?$')));
        final entries = locale.value as Map<String, dynamic>;
        for (final entry in entries.entries) {
          expect(catalogIds, contains(entry.key));
          final content = entry.value as Map<String, dynamic>;
          final setup = content['setupNotes'] as String;
          final execution = content['executionNotes'] as String;
          final tips = content['tipsNotes'] as String;
          _expectNumberedLines(setup, '${locale.key} ${entry.key} setup');
          _expectNumberedLines(
            execution,
            '${locale.key} ${entry.key} execution',
          );
          _expectBulletLines(tips, '${locale.key} ${entry.key} tips');
        }
        expect(
          coverage[locale.key],
          entries.length,
          reason: 'Update the declared ${locale.key} translation coverage.',
        );
      }
      expect(coverage.keys, containsAll(locales.keys));
      expect(coverage.keys, hasLength(locales.length));

      final names = bundle['names'] as Map<String, dynamic>;
      final nameCoverage = bundle['nameCoverage'] as Map<String, dynamic>;
      expect(names, isNotEmpty);
      expect(names.keys, unorderedEquals(locales.keys));
      expect(names.keys, unorderedEquals(nameCoverage.keys));
      for (final locale in names.entries) {
        expect(locales, contains(locale.key));
        final entries = locale.value as Map<String, dynamic>;
        expect(entries.keys, unorderedEquals(catalogIds));
        expect(
          nameCoverage[locale.key],
          entries.length,
          reason: 'Update the declared ${locale.key} name coverage.',
        );
        for (final entry in entries.entries) {
          expect(entry.value, isA<String>());
          expect((entry.value as String).trim(), isNotEmpty);
        }
      }
    },
  );
}

void _expectNumberedLines(String text, String description) {
  final lines = text.split('\n');
  expect(lines, isNotEmpty, reason: '$description cannot be empty.');
  for (var index = 0; index < lines.length; index++) {
    expect(
      lines[index],
      matches(RegExp('^${index + 1}\\.\\s+.+\$')),
      reason: '$description has invalid numbering.',
    );
  }
}

void _expectBulletLines(String text, String description) {
  final lines = text.split('\n');
  expect(lines, isNotEmpty, reason: '$description cannot be empty.');
  for (final line in lines) {
    expect(
      line,
      matches(RegExp(r'^-\s+.+$')),
      reason: '$description has an invalid bullet.',
    );
  }
}
