import 'dart:convert';
import 'dart:io';

import 'package:env_test/services/catalog_entity_localizer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CatalogEntityLocalizer localizerWith(Map<String, Object?> source) {
    return CatalogEntityLocalizer(bundleLoader: () async => jsonEncode(source));
  }

  const barbell = CatalogEntityDisplayName(
    catalogId: 'tonos.equipment.0005',
    canonicalName: 'Barbell',
  );
  const bicepsBrachii = CatalogEntityDisplayName(
    catalogId: 'tonos.muscle.0006',
    canonicalName: 'Biceps Brachii',
  );

  test('resolves a built-in entity by stable ID', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'es': {'tonos.equipment.0005': 'Barra'},
      },
    });

    expect(await localizer.resolveName(barbell, const Locale('es')), 'Barra');
  });

  test('uses a base language for a regional locale', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'fr': {'tonos.equipment.0005': 'Barre'},
      },
    });

    expect(
      await localizer.resolveName(barbell, const Locale('fr', 'CA')),
      'Barre',
    );
  });

  test('keeps English and custom values verbatim', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'es': {'tonos.equipment.0005': 'Barra'},
      },
    });
    const custom = CatalogEntityDisplayName(canonicalName: 'My cable handle');

    expect(await localizer.resolveName(barbell, const Locale('en')), 'Barbell');
    expect(
      await localizer.resolveName(custom, const Locale('es')),
      'My cable handle',
    );
  });

  test('bundled equipment translations cover every supported locale', () async {
    final localizer = CatalogEntityLocalizer(
      bundleLoader:
          () => File('assets/catalog_entity_localizations.json').readAsString(),
    );

    expect(await localizer.resolveName(barbell, const Locale('es')), 'Barra');
    expect(await localizer.resolveName(barbell, const Locale('fr')), 'Barre');
    expect(await localizer.resolveName(barbell, const Locale('bn')), 'বারবেল');
    expect(await localizer.resolveName(barbell, const Locale('zh')), '杠铃');
    expect(await localizer.resolveName(barbell, const Locale('hi')), 'बारबेल');
  });

  test('bundled Spanish muscle translations resolve by stable ID', () async {
    final localizer = CatalogEntityLocalizer(
      bundleLoader:
          () => File('assets/catalog_entity_localizations.json').readAsString(),
    );

    expect(
      await localizer.resolveName(bicepsBrachii, const Locale('es')),
      'Bíceps braquial',
    );
  });

  test('rejects invalid entity localization IDs', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'es': {'not-a-catalog-id': 'Barra'},
      },
    });

    await expectLater(
      localizer.resolveName(barbell, const Locale('es')),
      throwsFormatException,
    );
  });
}
