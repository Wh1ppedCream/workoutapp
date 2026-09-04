import 'dart:convert';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/services/catalog_entity_localizer.dart';
import 'package:env_test/widgets/localized_catalog_entity_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _muscle = CatalogEntityDisplayName(
  catalogId: 'tonos.muscle.0006',
  canonicalName: 'Biceps Brachii',
);
const _custom = CatalogEntityDisplayName(canonicalName: 'My custom muscle');

void main() {
  testWidgets('resolves built-in labels and preserves custom labels', (
    tester,
  ) async {
    final localizer = _testLocalizer();

    await tester.pumpWidget(_host(const Locale('es'), localizer));
    await tester.pumpAndSettle();

    expect(find.text('Bíceps braquial'), findsOneWidget);
    expect(find.text('My custom muscle'), findsOneWidget);

    await tester.pumpWidget(_host(const Locale('zh'), localizer));
    await tester.pumpAndSettle();

    expect(find.text('肱二头肌'), findsOneWidget);
    expect(find.text('My custom muscle'), findsOneWidget);
  });
}

CatalogEntityLocalizer _testLocalizer() {
  return CatalogEntityLocalizer(
    bundleLoader:
        () async => jsonEncode({
          'version': 1,
          'names': {
            'es': {'tonos.muscle.0006': 'Bíceps braquial'},
            'zh': {'tonos.muscle.0006': '肱二头肌'},
          },
        }),
  );
}

Widget _host(Locale locale, CatalogEntityLocalizer localizer) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Column(
        children: [
          LocalizedCatalogEntityName(entity: _muscle, localizer: localizer),
          LocalizedCatalogEntityName(entity: _custom, localizer: localizer),
        ],
      ),
    ),
  );
}
