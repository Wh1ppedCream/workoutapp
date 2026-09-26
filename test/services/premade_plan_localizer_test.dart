import 'dart:convert';

import 'package:env_test/data/premade_training_plans.dart';
import 'package:env_test/services/premade_plan_localizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final plan = premadeTrainingPlans.first;

  test('resolves localized plan fields by immutable ID', () async {
    final localizer = PremadePlanLocalizer(
      loader:
          () async => jsonEncode({
            'version': 1,
            'plans': {
              'es': {
                plan.catalogId: {
                  'sourceName': 'Hecho en casa',
                  'groupName': 'Cuerpo completo',
                  'name': 'Cuerpo completo',
                  'description': 'Sesión completa.',
                },
              },
            },
          }),
    );

    final resolved = await localizer.resolve(plan, const Locale('es'));
    expect(resolved.name, 'Cuerpo completo');
    expect(resolved.description, 'Sesión completa.');
  });

  test('falls back to canonical plan fields when untranslated', () async {
    final localizer = PremadePlanLocalizer(
      loader: () async => '{"version":1,"plans":{}}',
    );
    final resolved = await localizer.resolve(plan, const Locale('hi'));
    expect(resolved.name, plan.name);
    expect(resolved.description, plan.description);
  });

  test('prefers an exact regional translation before base language', () async {
    final localizer = PremadePlanLocalizer(
      loader:
          () async => jsonEncode({
            'version': 1,
            'plans': {
              'fr': {
                plan.catalogId: {
                  'sourceName': 'Créé par Tonos',
                  'groupName': 'Corps entier',
                  'name': 'Corps entier',
                  'description': 'Description française.',
                },
              },
              'fr_CA': {
                plan.catalogId: {
                  'sourceName': 'Créé par Tonos',
                  'groupName': 'Corps entier',
                  'name': 'Entraînement complet',
                  'description': 'Description canadienne.',
                },
              },
            },
          }),
    );

    final resolved = await localizer.resolve(plan, const Locale('fr', 'CA'));
    expect(resolved.name, 'Entraînement complet');
    expect(resolved.description, 'Description canadienne.');
  });

  test('inherits localized content for generated one-hour plans', () async {
    final oneHour = PremadeTrainingPlan(
      id: '${plan.id}_one_hour',
      sourceName: plan.sourceName,
      planGroupName: plan.planGroupName,
      name: plan.name,
      description: 'One-hour fallback.',
      exercises: plan.exercises,
      durationMinutes: 60,
    );
    final localizer = PremadePlanLocalizer(
      loader:
          () async => jsonEncode({
            'version': 1,
            'plans': {
              'es': {
                plan.catalogId: {
                  'sourceName': 'Hecho en casa',
                  'groupName': 'Cuerpo completo',
                  'name': 'Cuerpo completo',
                  'description': 'Sesión completa.',
                },
              },
            },
          }),
    );

    final resolved = await localizer.resolve(
      oneHour,
      const Locale('es'),
      oneHourDurationLabel: '1 hora',
      oneHourDescriptionBuilder:
          (duration, name) => 'Versión de $duration de $name.',
    );
    expect(resolved.name, 'Cuerpo completo');
    expect(resolved.description, 'Versión de 1 hora de Cuerpo completo.');
  });

  test(
    'uses the localization builder for the English one-hour version',
    () async {
      final oneHour = PremadeTrainingPlan(
        id: '${plan.id}_one_hour',
        sourceName: plan.sourceName,
        planGroupName: plan.planGroupName,
        name: plan.name,
        description: 'One-hour fallback.',
        exercises: plan.exercises,
        durationMinutes: 60,
      );
      final localizer = PremadePlanLocalizer(
        loader: () async => '{"version":1,"plans":{}}',
      );

      final resolved = await localizer.resolve(
        oneHour,
        const Locale('en'),
        oneHourDurationLabel: '1 hr',
        oneHourDescriptionBuilder:
            (duration, name) => '$duration version of $name.',
      );

      expect(resolved.description, '1 hr version of Full Body.');
    },
  );

  test(
    'uses one coherent fallback for a one-hour plan without a builder',
    () async {
      final oneHour = PremadeTrainingPlan(
        id: '${plan.id}_one_hour',
        sourceName: plan.sourceName,
        planGroupName: plan.planGroupName,
        name: plan.name,
        description: 'Canonical one-hour fallback.',
        exercises: plan.exercises,
        durationMinutes: 60,
      );
      final localizer = PremadePlanLocalizer(
        loader:
            () async => jsonEncode({
              'version': 1,
              'plans': {
                'es': {
                  plan.catalogId: {
                    'sourceName': 'Hecho en casa',
                    'groupName': 'Cuerpo completo',
                    'name': 'Cuerpo completo',
                    'description': 'Sesión completa.',
                  },
                },
              },
            }),
      );

      final resolved = await localizer.resolve(oneHour, const Locale('es'));
      expect(resolved.sourceName, oneHour.sourceName);
      expect(resolved.groupName, oneHour.planGroupName);
      expect(resolved.name, oneHour.name);
      expect(resolved.description, 'Canonical one-hour fallback.');
    },
  );

  test('rejects malformed locale and plan objects', () async {
    final malformedLocale = PremadePlanLocalizer(
      loader: () async => '{"version":1,"plans":{"es":[]}}',
    );
    await expectLater(
      malformedLocale.resolve(plan, const Locale('es')),
      throwsFormatException,
    );

    final malformedPlan = PremadePlanLocalizer(
      loader: () async => '{"version":1,"plans":{"es":{"invalid-plan":[]}}}',
    );
    await expectLater(
      malformedPlan.resolve(plan, const Locale('es')),
      throwsFormatException,
    );
  });

  test('ships every direct built-in plan in every supported locale', () async {
    final decoded =
        jsonDecode(
              await rootBundle.loadString(
                'assets/premade_plan_localizations.json',
              ),
            )
            as Map<String, dynamic>;
    final plansByLocale = Map<String, dynamic>.from(decoded['plans'] as Map);
    expect(
      plansByLocale.keys,
      unorderedEquals(const ['es', 'fr', 'bn', 'zh', 'hi']),
    );
    final directPlans = premadeTrainingPlans
        .where((candidate) => !candidate.id.endsWith('_one_hour'))
        .toList(growable: false);
    final expectedIds =
        directPlans.map((candidate) => candidate.catalogId).toSet();

    for (final localeCode in const ['es', 'fr', 'bn', 'zh', 'hi']) {
      final entries = Map<String, dynamic>.from(
        plansByLocale[localeCode] as Map,
      );
      expect(entries.keys.toSet(), expectedIds);
      for (final plan in directPlans) {
        final fields = Map<String, dynamic>.from(
          entries[plan.catalogId] as Map,
        );
        for (final field in const [
          'sourceName',
          'groupName',
          'name',
          'description',
        ]) {
          expect(fields[field], isA<String>());
          expect((fields[field] as String).trim(), isNotEmpty);
        }
      }
    }
  });

  test(
    'switching locales does not pin the cached bundle to one language',
    () async {
      final localizer = PremadePlanLocalizer(
        loader:
            () async => jsonEncode({
              'version': 1,
              'plans': {
                'fr': {
                  plan.catalogId: {
                    'sourceName': 'Créé par Tonos',
                    'groupName': 'Corps entier',
                    'name': 'Corps entier',
                    'description': 'Séance complète.',
                  },
                },
                'zh': {
                  plan.catalogId: {
                    'sourceName': 'Tonos 创建',
                    'groupName': '全身',
                    'name': '全身训练',
                    'description': '完整训练。',
                  },
                },
              },
            }),
      );

      expect(
        (await localizer.resolve(plan, const Locale('fr'))).name,
        'Corps entier',
      );
      expect((await localizer.resolve(plan, const Locale('zh'))).name, '全身训练');
    },
  );
}
