import 'package:env_test/l10n/app_localization_extensions.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/exercise_allocation_models.dart';
import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'localization bundle exposes French, Bangla, Simplified Chinese, Hindi, and Spanish',
    () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('fr')));
      expect(
        AppLocalizations.supportedLocales,
        contains(const Locale('fr', 'CA')),
      );
      expect(AppLocalizations.supportedLocales, contains(const Locale('bn')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('zh')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('hi')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
    },
  );

  test(
    'Canadian French includes workout report and set-editor labels',
    () async {
      final strings = await AppLocalizations.delegate.load(
        const Locale('fr', 'CA'),
      );

      expect(
        strings.workoutReportAdditionalDetails,
        isNot('Additional Details'),
      );
      expect(strings.recommendedSetsTitle, isNot('Recommended sets'));
      expect(strings.recommendedSetsMinimum, isNot('Minimum recommended sets'));
    },
  );

  test(
    'Bangla localization includes translated training and nutrition copy',
    () async {
      final strings = await AppLocalizations.delegate.load(const Locale('bn'));

      expect(strings.trainTab, 'প্রশিক্ষণ');
      expect(strings.nutritionDashboardTitle, 'পুষ্টি ড্যাশবোর্ড');
      expect(strings.bengaliBangladeshLanguage, 'বাংলা (বাংলাদেশ)');
    },
  );

  test(
    'Simplified Chinese localization includes translated core copy',
    () async {
      final strings = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(strings.trainTab, '训练');
      expect(strings.nutritionDashboardTitle, '营养仪表板');
      expect(strings.simplifiedChineseLanguage, '简体中文');
    },
  );

  test('Hindi localization includes translated core copy', () async {
    final strings = await AppLocalizations.delegate.load(const Locale('hi'));

    expect(strings.trainTab, 'प्रशिक्षण');
    expect(strings.nutritionDashboardTitle, 'पोषण डैशबोर्ड');
    expect(strings.hindiLanguage, 'हिंदी');
  });

  test('Spanish localization includes translated core copy', () async {
    final strings = await AppLocalizations.delegate.load(const Locale('es'));

    expect(strings.trainTab, 'Entrenamiento');
    expect(strings.nutritionDashboardTitle, 'Panel de nutrición');
    expect(strings.spanishLanguage, 'Español');
  });

  test(
    'stable active copy is translated across supported non-English locales',
    () async {
      const locales = [
        Locale('es'),
        Locale('fr'),
        Locale('fr', 'CA'),
        Locale('bn'),
        Locale('zh'),
        Locale('hi'),
      ];

      for (final locale in locales) {
        final strings = await AppLocalizations.delegate.load(locale);

        expect(strings.quickActionMeasurement, isNot('+ Measurement'));
        expect(strings.quickActionFood, isNot('+ Food'));
        expect(strings.quickActionWorkout, isNot('+ Workout'));
        expect(
          strings.allocationSourceAutomatic,
          isNot('Automatic calculation'),
        );
        expect(
          strings.healthTrendNeedEntries,
          isNot('Log entries to build a trend.'),
        );
        expect(
          strings.healthTrendNeedOneMore,
          isNot('Log one more entry to draw a trend.'),
        );
        expect(strings.healthNoChange, isNot('No change yet'));
        expect(strings.healthEntryActions, isNot('Entry actions'));
        expect(
          ExerciseAllocationSource.personalOverride.localizedLabel(strings),
          isNot('Your custom allocation'),
        );
        expect(WeightUnit.pounds.localizedLabel(strings), isNot('Pounds'));
      }
    },
  );

  test(
    'active navigation labels stay translated across supported locales',
    () async {
      const locales = [
        Locale('es'),
        Locale('fr'),
        Locale('fr', 'CA'),
        Locale('bn'),
        Locale('zh'),
        Locale('hi'),
      ];
      const activeTabs = <TabItem, String>{
        TabItem.train: 'Train',
        TabItem.catalog: 'Catalog',
        TabItem.history: 'Logbook',
        TabItem.measurementsTrends: 'Progress',
        TabItem.profile: 'Profile',
      };

      for (final locale in locales) {
        final strings = await AppLocalizations.delegate.load(locale);
        for (final entry in activeTabs.entries) {
          final label = entry.key.localizedTitle(strings);
          expect(label.trim(), isNotEmpty);
          expect(
            label,
            isNot(entry.value),
            reason:
                '${locale.toLanguageTag()} still uses English navigation copy.',
          );
        }
      }
    },
  );

  testWidgets('English localization delegates resolve app strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context);
            return Text('${strings.appTitle}|${strings.languageTitle}');
          },
        ),
      ),
    );

    expect(find.text('Tonos|Language'), findsOneWidget);
  });

  testWidgets('Canadian French localization resolves translated strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'CA'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context);
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    '${strings.uiAppearanceTitle}|'
                    '${strings.languageTitle}|'
                    '${strings.canadianFrenchLanguage}',
                  ),
                  Text(strings.onboardingWelcomeTitle),
                  Text(strings.onboardingPlansAdded(2)),
                  Text(strings.onboardingStepProgress(1, 8)),
                  Text(
                    '${TabItem.train.localizedTitle(strings)}|'
                    '${TabItem.catalog.localizedTitle(strings)}|'
                    '${TabItem.profile.localizedTitle(strings)}',
                  ),
                  Text(
                    '${strings.trainOverviewTab}|'
                    '${strings.trainPlansTab}|'
                    '${strings.planManagementTitle}',
                  ),
                  Text(strings.trainGeneratedPlans(3)),
                  Text(
                    '${strings.optimizedRepsWeightsTitle}|'
                    '${strings.generatePageTitle}|'
                    '${strings.sessionTitle}',
                  ),
                  Text(
                    '${strings.recordRepBest(8)}|'
                    '${strings.recordVolumeBest}',
                  ),
                  Text(
                    '${strings.planProgression}|'
                    '${strings.rulesPageTitle}|'
                    '${strings.flowPageTitle}',
                  ),
                  Text(strings.rulesProfileSummary(2, 3)),
                  Text(strings.flowSummary(2, 1, 3)),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(
      find.text('Interface et apparence|Langue|Français (Canada)'),
      findsOneWidget,
    );
    expect(find.text('Bienvenue dans Tonos'), findsOneWidget);
    expect(
      find.text('2 plans ont été ajoutés aux plans actifs.'),
      findsOneWidget,
    );
    expect(find.text('Étape 1 sur 8'), findsOneWidget);
    expect(find.text('Entraînement|Catalogue|Profil'), findsOneWidget);
    expect(find.text('Aperçu|Plans|Gérer les plans'), findsOneWidget);
    expect(find.text('3 plans ont été générés.'), findsOneWidget);
    expect(
      find.text(
        'Répétitions et poids|Générer des plans|'
        'Séance d’entraînement',
      ),
      findsOneWidget,
    );
    expect(find.text('Meilleur à 8 rép.|Meilleur volume'), findsOneWidget);
  });
}
