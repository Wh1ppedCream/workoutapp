import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'catalog entity registry covers every shipped lookup row exactly once',
    () async {
      final registry =
          jsonDecode(
                await File(
                  'assets/catalog_entity_registry.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;

      expect(registry['version'], 1);
      await _expectCoverage(
        registry: registry,
        registryKey: 'equipment',
        sourcePath: 'assets/equipment.json',
        prefix: 'tonos.equipment.',
      );
      await _expectCoverage(
        registry: registry,
        registryKey: 'muscles',
        sourcePath: 'assets/muscles.json',
        prefix: 'tonos.muscle.',
      );
      await _expectCoverage(
        registry: registry,
        registryKey: 'stretches',
        sourcePath: 'assets/stretches.json',
        prefix: 'tonos.stretch.',
      );
    },
  );
}

Future<void> _expectCoverage({
  required Map<String, dynamic> registry,
  required String registryKey,
  required String sourcePath,
  required String prefix,
}) async {
  final source =
      (jsonDecode(await File(sourcePath).readAsString()) as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final entries =
      (registry[registryKey] as List<dynamic>).cast<Map<String, dynamic>>();
  final sourceNames = source.map((entry) => entry['name'] as String).toSet();
  final registryNames =
      entries.map((entry) => entry['canonicalName'] as String).toSet();
  final registryIds =
      entries.map((entry) => entry['catalogId'] as String).toSet();

  expect(entries, hasLength(source.length));
  expect(registryNames, sourceNames);
  expect(registryIds, hasLength(entries.length));
  for (final id in registryIds) {
    expect(id, matches(RegExp('^${RegExp.escape(prefix)}\\d{4}\$')));
  }
}
