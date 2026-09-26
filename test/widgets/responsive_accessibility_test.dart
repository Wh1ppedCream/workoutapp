import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/guided_tutorial_overlay.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings hero reflows long French titles at large text sizes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const title = 'Paramètres de progression des entraînements';
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'CA'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: const Scaffold(
            body: SingleChildScrollView(
              child: SettingsHeroCard(
                title: title,
                subtitle: 'Les options restent lisibles sans réduire le texte.',
                icon: Icons.tune,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new locales keep privacy settings copy readable at large text sizes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final locale in const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('fr', 'CA'),
        Locale('bn'),
        Locale('hi'),
        Locale('zh'),
      ]) {
        final strings = await AppLocalizations.delegate.load(locale);
        for (final width in const [320.0, 420.0]) {
          await tester.binding.setSurfaceSize(Size(width, 640));
          for (final theme in [
            AppThemeFactory.light(AppThemeFamily.classic),
            AppThemeFactory.dark(AppThemeFamily.classic),
            AppThemeFactory.light(AppThemeFamily.neoBrutalism),
            AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                theme: theme,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: MediaQuery(
                  data: const MediaQueryData(
                    textScaler: TextScaler.linear(2.0),
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: SettingsHeroCard(
                        title: strings.profileDiagnosticsTitle,
                        subtitle: strings.diagnosticsPrivacyPromiseBody,
                        icon: Icons.shield_outlined,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            expect(find.text(strings.profileDiagnosticsTitle), findsOneWidget);
            final title = tester.widget<Text>(
              find.text(strings.profileDiagnosticsTitle),
            );
            final subtitle = tester.widget<Text>(
              find.text(strings.diagnosticsPrivacyPromiseBody),
            );
            expect(title.maxLines, isNull);
            expect(title.overflow, isNull);
            expect(subtitle.maxLines, isNull);
            expect(subtitle.overflow, isNull);
            expect(tester.takeException(), isNull);
          }
        }
      }
    },
  );

  testWidgets('Spanish settings hero allows a third subtitle line', (
    tester,
  ) async {
    final strings = await AppLocalizations.delegate.load(const Locale('es'));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsHeroCard(
            title: strings.uiAppearanceTitle,
            subtitle: strings.uiAppearanceSubtitle,
            icon: Icons.palette_outlined,
          ),
        ),
      ),
    );

    final subtitle = tester.widget<Text>(
      find.text(strings.uiAppearanceSubtitle),
    );
    expect(subtitle.maxLines, isNull);
    expect(subtitle.overflow, isNull);
    expect(tester.takeException(), isNull);

    final frenchStrings = await AppLocalizations.delegate.load(
      const Locale('fr'),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsHeroCard(
            title: frenchStrings.uiAppearanceTitle,
            subtitle: frenchStrings.uiAppearanceSubtitle,
            icon: Icons.palette_outlined,
          ),
        ),
      ),
    );

    final frenchSubtitle = tester.widget<Text>(
      find.text(frenchStrings.uiAppearanceSubtitle),
    );
    expect(frenchSubtitle.maxLines, isNull);
    expect(frenchSubtitle.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add exercise button exposes a localized accessible label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(floatingActionButton: AddExerciseFab()),
      ),
    );

    expect(find.byTooltip('Add'), findsOneWidget);
  });

  testWidgets('French tutorial actions stack at large text sizes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final targetKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'CA'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder:
            (context, child) => MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
              child: child!,
            ),
        home: Scaffold(
          body: Center(child: SizedBox(key: targetKey, width: 120, height: 80)),
        ),
      ),
    );

    final completion = GuidedTutorialOverlay.show(
      tester.element(find.byType(Scaffold)),
      steps: [
        GuidedTutorialStep(
          targetKey: targetKey,
          title: 'Tutoriel de progression des entraînements',
          body:
              'Cette étape reste lisible lorsque la taille du texte augmente.',
        ),
        GuidedTutorialStep(
          targetKey: targetKey,
          title: 'Deuxième étape',
          body: 'Le bouton principal doit apparaître sous les autres actions.',
        ),
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final secondaryActions = find.byType(TextButton);
    final primaryAction = find.byType(FilledButton);
    expect(secondaryActions, findsNWidgets(2));
    expect(primaryAction, findsOneWidget);
    expect(
      tester.getTopLeft(primaryAction).dy,
      greaterThan(tester.getBottomLeft(secondaryActions.last).dy),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(secondaryActions.first);
    await tester.pumpAndSettle();
    expect(await completion, isFalse);
  });

  testWidgets('English tutorial actions reflow across accessibility scales', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final targetKey = GlobalKey();

    for (final scale in [1.0, 1.3, 1.6, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
          home: Scaffold(
            body: Center(
              child: SizedBox(key: targetKey, width: 120, height: 80),
            ),
          ),
        ),
      );

      final completion = GuidedTutorialOverlay.show(
        tester.element(find.byType(Scaffold)),
        steps: [
          GuidedTutorialStep(
            targetKey: targetKey,
            title: 'Workout progress overview',
            body: 'This tutorial remains readable at larger text sizes.',
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(TextButton), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(await completion, isFalse);
    }
  });
}
