import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings scaffold remains usable across release layout matrix', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const scenarios = <({Size size, Locale locale, double textScale})>[
      (size: Size(320, 640), locale: Locale('en'), textScale: 1),
      (size: Size(320, 640), locale: Locale('es'), textScale: 1.3),
      (size: Size(430, 932), locale: Locale('bn'), textScale: 1.3),
      (size: Size(800, 1280), locale: Locale('hi'), textScale: 1.3),
    ];

    for (final scenario in scenarios) {
      await tester.binding.setSurfaceSize(scenario.size);
      final strings = await AppLocalizations.delegate.load(scenario.locale);
      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: scenario.size,
              textScaler: TextScaler.linear(scenario.textScale),
            ),
            child: SettingsPageScaffold(
              title: strings.profileDiagnosticsTitle,
              subtitle: strings.diagnosticsPrivacyPromiseBody,
              icon: Icons.shield_outlined,
              children: [
                SettingsSection(
                  title: strings.diagnosticsTitle,
                  subtitle: strings.diagnosticsAppSectionSubtitle,
                  children: const [SizedBox(height: 48)],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip(strings.commonBack), findsOneWidget);
      expect(find.text(strings.profileDiagnosticsTitle), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'icon-only primary actions expose a semantic name and tap action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(floatingActionButton: AddExerciseFab()),
          ),
        );

        final node = tester.getSemantics(find.byType(AddExerciseFab));
        expect(node.label, 'Add');
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    },
  );
}
