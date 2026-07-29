import 'package:env_test/l10n/generated/app_localizations.dart';
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
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: const Scaffold(
            body: SettingsHeroCard(
              title: title,
              subtitle: 'Les options restent lisibles sans réduire le texte.',
              icon: Icons.tune,
            ),
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
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
}
