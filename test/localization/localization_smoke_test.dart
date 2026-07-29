import 'package:env_test/l10n/app_localization_extensions.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localization bundle exposes French and Canadian French', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('fr')));
    expect(
      AppLocalizations.supportedLocales,
      contains(const Locale('fr', 'CA')),
    );
  });

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
