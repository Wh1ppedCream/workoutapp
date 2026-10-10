import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/profile/settings/tutorials_settings_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive Profile tutorial groups use subtle category surfaces and compact rows in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.light
                ? ExpressiveThemeDefinition.light()
                : ExpressiveThemeDefinition.dark(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TutorialsSettingsPage(),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(TutorialsSettingsPage));
        final strings = AppLocalizations.of(pageContext);
        final tokens = Theme.of(pageContext)
            .extension<AppExpressiveDestinationTokens>();
        // The destination wrapper is inside the route, so read the page's
        // palette from one of its category surfaces.
        final categoryTitle = find.text(strings.tutorialsMainTabsTitle);
        final categoryContext = tester.element(categoryTitle);
        final categoryTokens = Theme.of(categoryContext)
            .extension<AppExpressiveDestinationTokens>()!;
        final baseTokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.profile,
          brightness,
        );
        expect(tokens, isNull);
        expect(categoryTokens.family, AppExpressiveDestinationFamily.profile);
        expect(categoryTokens.surfacePrimary, baseTokens.surfacePrimary);
        expect(
          categoryTokens.surfaceSecondary,
          isNot(baseTokens.surfaceSecondary),
        );
        expect(
          categoryTokens.surfaceTertiary,
          isNot(baseTokens.surfaceTertiary),
        );
        expect(categoryTokens.surfaceAccent, isNot(baseTokens.surfaceAccent));
        expect(categoryTokens.onSurfacePrimary, baseTokens.onSurfacePrimary);
        expect(
          categoryTokens.onSurfaceSecondary,
          categoryTokens.supportingForeground,
        );
        expect(
          categoryTokens.onSurfaceTertiary,
          categoryTokens.supportingForeground,
        );
        expect(
          categoryTokens.onSurfaceAccent,
          categoryTokens.supportingForeground,
        );

        final sections = tester.widgetList<SettingsExpansionSection>(
          find.byType(SettingsExpansionSection),
        );
        expect(sections, hasLength(5));
        expect(sections.every((section) => section.compact), isTrue);
        expect(
          sections.every((section) => section.subtitleMaxLines == 2),
          isTrue,
        );

        final mainTabsTile = tester.widget<ExpansionTile>(
          find.byType(ExpansionTile).first,
        );
        expect(mainTabsTile.tilePadding!.resolve(TextDirection.ltr).top, 0);
        final subtitle = tester.widget<Text>(
          find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.text(strings.tutorialsMainTabsSubtitle),
          ),
        );
        expect(subtitle.maxLines, 2);

        await tester.tap(categoryTitle);
        await tester.pumpAndSettle();
        final trainReplay = strings.tutorialsExpressiveTitle(
          strings.tutorialsTopicTrain,
        );
        expect(find.text(trainReplay), findsOneWidget);
        final replayTile = tester.widget<SettingsActionTile>(
          find.ancestor(
            of: find.text(trainReplay),
            matching: find.byType(SettingsActionTile),
          ),
        );
        expect(replayTile.compact, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final (name, theme) in <(String, ThemeData)>[
    ('Classic', ClassicThemeDefinition.light()),
    ('Neo', NeoBrutalismThemeDefinition.light()),
  ]) {
    testWidgets('$name tutorial sections retain the default settings density', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TutorialsSettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      final sections = tester.widgetList<SettingsExpansionSection>(
        find.byType(SettingsExpansionSection),
      );
      expect(sections, hasLength(5), reason: name);
      expect(sections.every((section) => !section.compact), isTrue);
      expect(
        sections.every((section) => section.subtitleMaxLines == 1),
        isTrue,
      );
      final firstTile = tester.widget<ExpansionTile>(
        find.byType(ExpansionTile).first,
      );
      expect(firstTile.tilePadding!.resolve(TextDirection.ltr).top, 4);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('default settings tiles keep their original density', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SettingsExpansionSection(
          title: 'Tutorials',
          subtitle: 'Replay guided help',
          icon: Icons.school_outlined,
          accentColor: Colors.teal,
          children: [
            SettingsActionTile(
              icon: Icons.refresh,
              title: 'Replay tutorial',
              subtitle: 'Shown next time',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final section = tester.widget<SettingsExpansionSection>(
      find.byType(SettingsExpansionSection),
    );
    final tile = tester.widget<ExpansionTile>(find.byType(ExpansionTile));
    final actionTile = section.children.single as SettingsActionTile;
    expect(section.compact, isFalse);
    expect(section.subtitleMaxLines, 1);
    expect(tile.tilePadding!.resolve(TextDirection.ltr).top, 4);
    expect(actionTile.compact, isFalse);
  });
}
