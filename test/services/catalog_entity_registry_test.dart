import 'dart:convert';

import 'package:env_test/services/catalog_entity_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CatalogEntityRegistry registryWith(Object source) {
    return CatalogEntityRegistry(loader: () async => jsonEncode(source));
  }

  test('loads stable IDs by entity type and canonical name', () async {
    final registry = registryWith({
      'version': 1,
      'equipment': [
        {'catalogId': 'tonos.equipment.0001', 'canonicalName': 'Barbell'},
      ],
      'muscles': [
        {'catalogId': 'tonos.muscle.0001', 'canonicalName': 'Biceps Brachii'},
      ],
      'stretches': [
        {'catalogId': 'tonos.stretch.0001', 'canonicalName': 'Arm Circles'},
      ],
    });

    final data = await registry.load();

    expect(
      data.catalogIdFor(CatalogEntityKind.equipment, 'Barbell'),
      'tonos.equipment.0001',
    );
    expect(
      data.catalogIdFor(CatalogEntityKind.muscle, 'Biceps Brachii'),
      'tonos.muscle.0001',
    );
    expect(
      data.catalogIdFor(CatalogEntityKind.stretch, 'Arm Circles'),
      'tonos.stretch.0001',
    );
    expect(
      data.catalogIdFor(CatalogEntityKind.equipment, 'Custom bar'),
      isNull,
    );
  });

  test(
    'rejects an invalid identity, duplicate ID, or duplicate canonical name',
    () async {
      final invalidId = registryWith({
        'version': 1,
        'equipment': [
          {'catalogId': 'barbell', 'canonicalName': 'Barbell'},
        ],
        'muscles': const [],
        'stretches': const [],
      });
      final duplicateId = registryWith({
        'version': 1,
        'equipment': [
          {'catalogId': 'tonos.equipment.0001', 'canonicalName': 'Barbell'},
          {'catalogId': 'tonos.equipment.0001', 'canonicalName': 'Dumbbell'},
        ],
        'muscles': const [],
        'stretches': const [],
      });
      final duplicateName = registryWith({
        'version': 1,
        'equipment': [
          {'catalogId': 'tonos.equipment.0001', 'canonicalName': 'Barbell'},
          {'catalogId': 'tonos.equipment.0002', 'canonicalName': 'Barbell'},
        ],
        'muscles': const [],
        'stretches': const [],
      });

      await expectLater(invalidId.load(), throwsFormatException);
      await expectLater(duplicateId.load(), throwsFormatException);
      await expectLater(duplicateName.load(), throwsFormatException);
    },
  );
}
