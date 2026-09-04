import 'dart:convert';

import 'package:flutter/services.dart';

/// The shipped entity families whose English catalog names have stable IDs.
///
/// The IDs are persisted on built-in rows. Display localizers must use these
/// IDs rather than a canonical name so catalog renames do not affect history.
enum CatalogEntityKind { equipment, muscle, stretch }

typedef CatalogEntityRegistryLoader = Future<String> Function();

class CatalogEntityRegistry {
  CatalogEntityRegistry({CatalogEntityRegistryLoader? loader})
    : _loader = loader ?? (() => rootBundle.loadString(_assetPath));

  static const _assetPath = 'assets/catalog_entity_registry.json';

  static final instance = CatalogEntityRegistry();

  final CatalogEntityRegistryLoader _loader;
  Future<CatalogEntityRegistryData>? _dataFuture;

  Future<CatalogEntityRegistryData> load() => _dataFuture ??= _load();

  Future<CatalogEntityRegistryData> _load() async {
    final decoded = jsonDecode(await _loader());
    if (decoded is! Map || (decoded['version'] as num?)?.toInt() != 1) {
      throw const FormatException(
        'Catalog entity registry needs version 1 and an object root.',
      );
    }

    return CatalogEntityRegistryData(
      equipment: _readEntries(
        decoded['equipment'],
        CatalogEntityKind.equipment,
      ),
      muscles: _readEntries(decoded['muscles'], CatalogEntityKind.muscle),
      stretches: _readEntries(decoded['stretches'], CatalogEntityKind.stretch),
    );
  }

  static List<CatalogEntityEntry> _readEntries(
    Object? raw,
    CatalogEntityKind kind,
  ) {
    if (raw is! List) {
      throw FormatException('Catalog entity registry is missing ${kind.name}.');
    }
    final ids = <String>{};
    final names = <String>{};
    final prefix = 'tonos.${kind.name}.';
    return raw
        .map((item) {
          if (item is! Map) {
            throw FormatException(
              'Catalog ${kind.name} entry must be an object.',
            );
          }
          final id = item['catalogId']?.toString().trim();
          final name = item['canonicalName']?.toString().trim();
          if (id == null ||
              !RegExp('^${RegExp.escape(prefix)}\\d{4}\$').hasMatch(id)) {
            throw FormatException('Invalid ${kind.name} catalog ID.');
          }
          if (name == null || name.isEmpty) {
            throw FormatException('Catalog ${kind.name} name is missing.');
          }
          if (!ids.add(id) || !names.add(name)) {
            throw FormatException('Duplicate catalog ${kind.name} identity.');
          }
          return CatalogEntityEntry(
            kind: kind,
            catalogId: id,
            canonicalName: name,
          );
        })
        .toList(growable: false);
  }
}

class CatalogEntityRegistryData {
  const CatalogEntityRegistryData({
    required this.equipment,
    required this.muscles,
    required this.stretches,
  });

  final List<CatalogEntityEntry> equipment;
  final List<CatalogEntityEntry> muscles;
  final List<CatalogEntityEntry> stretches;

  Iterable<CatalogEntityEntry> entriesFor(CatalogEntityKind kind) =>
      switch (kind) {
        CatalogEntityKind.equipment => equipment,
        CatalogEntityKind.muscle => muscles,
        CatalogEntityKind.stretch => stretches,
      };

  String? catalogIdFor(CatalogEntityKind kind, String canonicalName) {
    for (final entry in entriesFor(kind)) {
      if (entry.canonicalName == canonicalName) return entry.catalogId;
    }
    return null;
  }
}

class CatalogEntityEntry {
  const CatalogEntityEntry({
    required this.kind,
    required this.catalogId,
    required this.canonicalName,
  });

  final CatalogEntityKind kind;
  final String catalogId;
  final String canonicalName;
}
