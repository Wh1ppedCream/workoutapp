import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/definition_models.dart';

typedef ExerciseContentBundleLoader = Future<String> Function();

/// The guidance displayed for an exercise's three form-guide sections.
class ExerciseInstructionContent {
  final String setupNotes;
  final String executionNotes;
  final String tipsNotes;

  const ExerciseInstructionContent({
    required this.setupNotes,
    required this.executionNotes,
    required this.tipsNotes,
  });

  factory ExerciseInstructionContent.fromDefinition(
    ExerciseDefinition definition,
  ) {
    return ExerciseInstructionContent(
      setupNotes: definition.setupNotes,
      executionNotes: definition.executionNotes,
      tipsNotes: definition.tipsNotes,
    );
  }
}

/// Resolves bundled exercise guidance and display names by catalog identity.
///
/// English catalog text remains the source and fallback. Custom exercises and
/// catalog entries without a reviewed translation keep their stored guidance.
class ExerciseContentLocalizer {
  ExerciseContentLocalizer({ExerciseContentBundleLoader? bundleLoader})
    : _bundleLoader =
          bundleLoader ?? (() => rootBundle.loadString(_bundleAssetPath));

  static const _bundleAssetPath = 'assets/exercise_content_localizations.json';

  static final ExerciseContentLocalizer instance = ExerciseContentLocalizer();

  final ExerciseContentBundleLoader _bundleLoader;
  Future<_ExerciseContentBundle>? _bundleFuture;

  Future<ExerciseInstructionContent> resolve(
    ExerciseDefinition definition,
    Locale locale,
  ) async {
    final fallback = ExerciseInstructionContent.fromDefinition(definition);
    final catalogId = definition.catalogId;
    if (catalogId == null || catalogId.isEmpty || locale.languageCode == 'en') {
      return fallback;
    }

    final bundle = await (_bundleFuture ??= _loadBundle());
    for (final localeKey in _localeKeys(locale)) {
      final localized = bundle.contentFor(localeKey, catalogId);
      if (localized != null) return localized;
    }
    return fallback;
  }

  /// Resolves the display name for a built-in exercise without changing its
  /// canonical database name. User-created and untranslated exercises retain
  /// the name saved with their definition.
  Future<String> resolveName(
    ExerciseDefinition definition,
    Locale locale,
  ) async {
    return resolveNameForCatalogId(
      catalogId: definition.catalogId,
      fallbackName: definition.name,
      locale: locale,
    );
  }

  /// Resolves a built-in name when the caller has catalog identity but not a
  /// full [ExerciseDefinition], such as a premade-plan preview row.
  Future<String> resolveNameForCatalogId({
    required String? catalogId,
    required String fallbackName,
    required Locale locale,
  }) async {
    if (catalogId == null || catalogId.isEmpty || locale.languageCode == 'en') {
      return fallbackName;
    }

    final bundle = await (_bundleFuture ??= _loadBundle());
    for (final localeKey in _localeKeys(locale)) {
      final localized = bundle.nameFor(localeKey, catalogId);
      if (localized != null) return localized;
    }
    return fallbackName;
  }

  Future<_ExerciseContentBundle> _loadBundle() async {
    final decoded = jsonDecode(await _bundleLoader());
    if (decoded is! Map) {
      throw const FormatException(
        'Exercise-content localizations must contain an object.',
      );
    }
    final version = (decoded['version'] as num?)?.toInt();
    final rawLocales = decoded['locales'];
    if (version != 1 || rawLocales is! Map) {
      throw const FormatException(
        'Exercise-content localizations need version 1 and a locales object.',
      );
    }

    final byLocale = <String, Map<String, ExerciseInstructionContent>>{};
    for (final localeEntry in rawLocales.entries) {
      final localeKey = localeEntry.key.toString();
      if (!_localeKeyPattern.hasMatch(localeKey) || localeEntry.value is! Map) {
        throw FormatException('Invalid exercise-content locale "$localeKey".');
      }
      final byCatalogId = <String, ExerciseInstructionContent>{};
      for (final contentEntry in (localeEntry.value as Map).entries) {
        final catalogId = contentEntry.key.toString();
        if (!_catalogIdPattern.hasMatch(catalogId) ||
            contentEntry.value is! Map) {
          throw FormatException(
            'Invalid localized exercise content for "$catalogId".',
          );
        }
        final content = Map<String, dynamic>.from(contentEntry.value as Map);
        byCatalogId[catalogId] = ExerciseInstructionContent(
          setupNotes: _requiredText(content, 'setupNotes', catalogId),
          executionNotes: _requiredText(content, 'executionNotes', catalogId),
          tipsNotes: _requiredText(content, 'tipsNotes', catalogId),
        );
      }
      byLocale[localeKey] = byCatalogId;
    }

    final namesByLocale = <String, Map<String, String>>{};
    final rawNames = decoded['names'];
    if (rawNames != null) {
      if (rawNames is! Map) {
        throw const FormatException(
          'Exercise-name localizations must contain a locales object.',
        );
      }
      for (final localeEntry in rawNames.entries) {
        final localeKey = localeEntry.key.toString();
        if (!_localeKeyPattern.hasMatch(localeKey) ||
            localeEntry.value is! Map) {
          throw FormatException('Invalid exercise-name locale "$localeKey".');
        }
        final byCatalogId = <String, String>{};
        for (final nameEntry in (localeEntry.value as Map).entries) {
          final catalogId = nameEntry.key.toString();
          if (!_catalogIdPattern.hasMatch(catalogId)) {
            throw FormatException(
              'Invalid localized exercise name for "$catalogId".',
            );
          }
          final name = nameEntry.value?.toString().trim();
          if (name == null || name.isEmpty) {
            throw FormatException(
              'Localized exercise name is missing for "$catalogId".',
            );
          }
          byCatalogId[catalogId] = name;
        }
        namesByLocale[localeKey] = byCatalogId;
      }
    }
    return _ExerciseContentBundle(byLocale, namesByLocale);
  }

  static String _requiredText(
    Map<String, dynamic> content,
    String key,
    String catalogId,
  ) {
    final value = content[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw FormatException('Localized $key is missing for "$catalogId".');
    }
    return value;
  }

  static Iterable<String> _localeKeys(Locale locale) sync* {
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      yield '${locale.languageCode}_$countryCode';
    }
    yield locale.languageCode;
  }

  static final _catalogIdPattern = RegExp(r'^tonos\.exercise\.\d{4}$');
  static final _localeKeyPattern = RegExp(r'^[a-z]{2,3}(?:_[A-Z]{2})?$');
}

class _ExerciseContentBundle {
  const _ExerciseContentBundle(this._byLocale, this._namesByLocale);

  final Map<String, Map<String, ExerciseInstructionContent>> _byLocale;
  final Map<String, Map<String, String>> _namesByLocale;

  ExerciseInstructionContent? contentFor(String locale, String catalogId) {
    return _byLocale[locale]?[catalogId];
  }

  String? nameFor(String locale, String catalogId) {
    return _namesByLocale[locale]?[catalogId];
  }
}
