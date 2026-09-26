import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef CatalogEntityLocalizationBundleLoader = Future<String> Function();

/// A stored catalog name paired with its optional stable shipped identity.
///
/// A null [catalogId] identifies a user-created or legacy local value. It must
/// remain verbatim rather than being guessed from its text.
class CatalogEntityDisplayName {
  const CatalogEntityDisplayName({required this.canonicalName, this.catalogId});

  final String canonicalName;
  final String? catalogId;
}

/// Resolves translated names for built-in lookup entities by stable catalog ID.
///
/// The canonical database text remains the English and missing-content
/// fallback. This keeps matching, exports, migrations, and custom entries
/// independent from the application's current locale.
class CatalogEntityLocalizer {
  CatalogEntityLocalizer({CatalogEntityLocalizationBundleLoader? bundleLoader})
    : _bundleLoader =
          bundleLoader ?? (() => rootBundle.loadString(_bundleAssetPath));

  static const _bundleAssetPath = 'assets/catalog_entity_localizations.json';

  static final CatalogEntityLocalizer instance = CatalogEntityLocalizer();

  final CatalogEntityLocalizationBundleLoader _bundleLoader;
  Future<_CatalogEntityLocalizationBundle>? _bundleFuture;

  Future<String> resolveName(
    CatalogEntityDisplayName entity,
    Locale locale,
  ) async {
    final catalogId = entity.catalogId;
    if (catalogId == null || catalogId.isEmpty || locale.languageCode == 'en') {
      return entity.canonicalName;
    }

    final bundle = await (_bundleFuture ??= _loadBundle());
    for (final localeKey in _localeKeys(locale)) {
      final localized = bundle.nameFor(localeKey, catalogId);
      if (localized != null) return localized;
    }
    return entity.canonicalName;
  }

  Future<List<String>> resolveNames(
    Iterable<CatalogEntityDisplayName> entities,
    Locale locale,
  ) {
    return Future.wait(entities.map((entity) => resolveName(entity, locale)));
  }

  Future<_CatalogEntityLocalizationBundle> _loadBundle() async {
    final decoded = jsonDecode(await _bundleLoader());
    if (decoded is! Map) {
      throw const FormatException(
        'Catalog entity localizations must contain an object.',
      );
    }
    final version = (decoded['version'] as num?)?.toInt();
    final rawNames = decoded['names'];
    if (version != 1 || rawNames is! Map) {
      throw const FormatException(
        'Catalog entity localizations need version 1 and a names object.',
      );
    }

    final namesByLocale = <String, Map<String, String>>{};
    for (final localeEntry in rawNames.entries) {
      final localeKey = localeEntry.key.toString();
      if (!_localeKeyPattern.hasMatch(localeKey) || localeEntry.value is! Map) {
        throw FormatException('Invalid catalog entity locale "$localeKey".');
      }
      final byCatalogId = <String, String>{};
      for (final nameEntry in (localeEntry.value as Map).entries) {
        final catalogId = nameEntry.key.toString();
        final name = nameEntry.value?.toString().trim();
        if (!_catalogIdPattern.hasMatch(catalogId) ||
            name == null ||
            name.isEmpty) {
          throw FormatException(
            'Invalid localized catalog entity name for "$catalogId".',
          );
        }
        byCatalogId[catalogId] = name;
      }
      namesByLocale[localeKey] = byCatalogId;
    }
    return _CatalogEntityLocalizationBundle(namesByLocale);
  }

  static Iterable<String> _localeKeys(Locale locale) sync* {
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      yield '${locale.languageCode}_$countryCode';
    }
    yield locale.languageCode;
  }

  static final _catalogIdPattern = RegExp(
    r'^tonos\.(?:equipment|muscle|stretch)\.\d{4}$',
  );
  static final _localeKeyPattern = RegExp(r'^[a-z]{2,3}(?:_[A-Z]{2})?$');
}

class _CatalogEntityLocalizationBundle {
  const _CatalogEntityLocalizationBundle(this._namesByLocale);

  final Map<String, Map<String, String>> _namesByLocale;

  String? nameFor(String locale, String catalogId) {
    return _namesByLocale[locale]?[catalogId];
  }
}
