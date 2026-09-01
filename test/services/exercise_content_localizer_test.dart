import 'dart:convert';
import 'dart:io';

import 'package:env_test/models/definition_models.dart';
import 'package:env_test/services/exercise_content_localizer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExerciseDefinition definition({String? catalogId}) => ExerciseDefinition(
    id: 7,
    catalogId: catalogId,
    name: 'Example exercise',
    useManualBodyparts: false,
    multiplyByRating: false,
    setupNotes: '1. English setup.',
    executionNotes: '1. English execution.',
    tipsNotes: '- English tip.',
  );

  ExerciseContentLocalizer localizerWith(Map<String, Object?> source) {
    return ExerciseContentLocalizer(
      bundleLoader: () async => jsonEncode(source),
    );
  }

  const spanishContent = {
    'setupNotes': '1. Preparacion.',
    'executionNotes': '1. Ejecucion.',
    'tipsNotes': '- Consejo.',
  };

  test('uses stable catalog IDs to resolve localized guidance', () async {
    final localizer = localizerWith({
      'version': 1,
      'locales': {
        'es': {'tonos.exercise.0007': spanishContent},
      },
    });

    final resolved = await localizer.resolve(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('es'),
    );

    expect(resolved.setupNotes, spanishContent['setupNotes']);
    expect(resolved.executionNotes, spanishContent['executionNotes']);
    expect(resolved.tipsNotes, spanishContent['tipsNotes']);
  });

  test('uses stable catalog IDs to resolve localized display names', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'es': {'tonos.exercise.0007': 'Press de banca con barra'},
      },
      'locales': {
        'es': {'tonos.exercise.0007': spanishContent},
      },
    });

    final resolved = await localizer.resolveName(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('es'),
    );

    expect(resolved, 'Press de banca con barra');
  });

  test('uses a base-language translation for a regional locale', () async {
    final localizer = localizerWith({
      'version': 1,
      'locales': {
        'fr': {'tonos.exercise.0007': spanishContent},
      },
    });

    final resolved = await localizer.resolve(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('fr', 'CA'),
    );

    expect(resolved.setupNotes, spanishContent['setupNotes']);
  });

  test('uses a base-language display name for a regional locale', () async {
    final localizer = localizerWith({
      'version': 1,
      'names': {
        'fr': {'tonos.exercise.0007': 'Développé couché avec barre'},
      },
      'locales': {
        'fr': {'tonos.exercise.0007': spanishContent},
      },
    });

    final resolved = await localizer.resolveName(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('fr', 'CA'),
    );

    expect(resolved, 'Développé couché avec barre');
  });

  test('bundled French content serves Canadian French', () async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader:
          () =>
              File('assets/exercise_content_localizations.json').readAsString(),
    );
    final exercise = definition(catalogId: 'tonos.exercise.0007');
    final resolved = await localizer.resolve(
      exercise,
      const Locale('fr', 'CA'),
    );
    final displayName = await localizer.resolveName(
      exercise,
      const Locale('fr', 'CA'),
    );

    expect(resolved.setupNotes, contains('Allongez-vous'));
    expect(resolved.setupNotes, isNot('1. English setup.'));
    expect(resolved.executionNotes, contains('Descendez la barre'));
    expect(resolved.tipsNotes, contains('barres de sécurité'));
    expect(displayName, 'Développé couché avec barre');
  });

  test('bundled Spanish names cover stable catalog identities', () async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader:
          () =>
              File('assets/exercise_content_localizations.json').readAsString(),
    );

    final resolved = await localizer.resolveName(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('es'),
    );

    expect(resolved, 'Press de banca con barra');
  });

  test('bundled Bangla names cover stable catalog identities', () async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader:
          () =>
              File('assets/exercise_content_localizations.json').readAsString(),
    );

    final resolved = await localizer.resolveName(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('bn'),
    );

    expect(resolved, 'বারবেল বেঞ্চ প্রেস');
  });

  test(
    'bundled Simplified Chinese names cover stable catalog identities',
    () async {
      final localizer = ExerciseContentLocalizer(
        bundleLoader:
            () =>
                File(
                  'assets/exercise_content_localizations.json',
                ).readAsString(),
      );

      final resolved = await localizer.resolveName(
        definition(catalogId: 'tonos.exercise.0007'),
        const Locale('zh'),
      );

      expect(resolved, '杠铃卧推');
    },
  );

  test('bundled Hindi names cover stable catalog identities', () async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader:
          () =>
              File('assets/exercise_content_localizations.json').readAsString(),
    );

    final resolved = await localizer.resolveName(
      definition(catalogId: 'tonos.exercise.0007'),
      const Locale('hi'),
    );

    expect(resolved, 'बारबेल बेंच प्रेस');
  });

  test(
    'keeps English guidance for custom, English, and missing content',
    () async {
      final localizer = localizerWith({
        'version': 1,
        'locales': {
          'es': {'tonos.exercise.0007': spanishContent},
        },
      });

      final custom = await localizer.resolve(definition(), const Locale('es'));
      final english = await localizer.resolve(
        definition(catalogId: 'tonos.exercise.0007'),
        const Locale('en'),
      );
      final missing = await localizer.resolve(
        definition(catalogId: 'tonos.exercise.0008'),
        const Locale('es'),
      );

      for (final resolved in [custom, english, missing]) {
        expect(resolved.setupNotes, '1. English setup.');
        expect(resolved.executionNotes, '1. English execution.');
        expect(resolved.tipsNotes, '- English tip.');
      }

      expect(
        await localizer.resolveName(definition(), const Locale('es')),
        'Example exercise',
      );
      expect(
        await localizer.resolveName(
          definition(catalogId: 'tonos.exercise.0007'),
          const Locale('en'),
        ),
        'Example exercise',
      );
      expect(
        await localizer.resolveName(
          definition(catalogId: 'tonos.exercise.0008'),
          const Locale('es'),
        ),
        'Example exercise',
      );
    },
  );

  test('rejects incomplete localized guidance bundles', () async {
    final localizer = localizerWith({
      'version': 1,
      'locales': {
        'es': {
          'tonos.exercise.0007': {
            'setupNotes': '1. Preparacion.',
            'executionNotes': '1. Ejecucion.',
          },
        },
      },
    });

    await expectLater(
      localizer.resolve(
        definition(catalogId: 'tonos.exercise.0007'),
        const Locale('es'),
      ),
      throwsFormatException,
    );
  });
}
