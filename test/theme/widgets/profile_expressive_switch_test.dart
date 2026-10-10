import 'dart:ui' as ui;

import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Profile switches use the Tonos palette in ${brightness.name}',
      (tester) async {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final tokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.profile,
          brightness,
        );
        final changes = <bool>[];

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.profile,
              child: Scaffold(
                body: SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: false,
                  onChanged: changes.add,
                ),
              ),
            ),
          ),
        );

        final switchFinder = find.byType(Switch);
        final switchContext = tester.element(switchFinder);
        final switchTheme = Theme.of(switchContext).switchTheme;
        final offStates = const <WidgetState>{};
        final onStates = const <WidgetState>{WidgetState.selected};
        final offTrack = switchTheme.trackColor!.resolve(offStates)!;
        final offThumb = switchTheme.thumbColor!.resolve(offStates)!;
        final onTrack = switchTheme.trackColor!.resolve(onStates)!;
        final onThumb = switchTheme.thumbColor!.resolve(onStates)!;

        expect(offTrack, tokens.surfaceTertiary);
        expect(offThumb, tokens.onSurfaceTertiary);
        expect(onTrack, tokens.actionPrimary);
        expect(onThumb, tokens.onActionPrimary);
        expect(_contrastRatio(offThumb, offTrack), greaterThanOrEqualTo(4.5));
        expect(_contrastRatio(onThumb, onTrack), greaterThanOrEqualTo(4.5));
        expect(
          switchTheme.trackOutlineColor!.resolve(offStates),
          tokens.outlineAccent,
        );
        expect(
          switchTheme.trackOutlineWidth!.resolve(const {WidgetState.focused}),
          2,
        );
        expect(
          switchTheme.overlayColor!.resolve(const {WidgetState.focused}),
          tokens.actionPrimary.withValues(alpha: 0.12),
        );

        final semantics = tester.ensureSemantics();
        final switchSemantics = tester
            .getSemantics(switchFinder)
            .getSemanticsData();
        expect(switchSemantics.flagsCollection.isToggled, ui.Tristate.isFalse);
        expect(switchSemantics.hasAction(SemanticsAction.tap), isTrue);

        await tester.tap(switchFinder);
        expect(changes, <bool>[true]);
        semantics.dispose();
      },
    );
  }

  testWidgets('disabled Profile switch stays subdued and disabled', (
    tester,
  ) async {
    final theme = ExpressiveThemeDefinition.light();
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      Brightness.light,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.profile,
          child: const Scaffold(
            body: SettingsSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: false,
              onChanged: null,
            ),
          ),
        ),
      ),
    );

    final switchFinder = find.byType(Switch);
    final switchWidget = tester.widget<Switch>(switchFinder);
    final switchTheme = Theme.of(tester.element(switchFinder)).switchTheme;
    const disabled = <WidgetState>{WidgetState.disabled};

    expect(switchWidget.onChanged, isNull);
    expect(
      switchTheme.thumbColor!.resolve(disabled),
      tokens.onSurfaceTertiary.withValues(alpha: 0.38),
    );
    expect(
      switchTheme.trackColor!.resolve(disabled),
      tokens.surfaceTertiary.withValues(alpha: 0.24),
    );
    expect(switchTheme.overlayColor!.resolve(disabled), isNull);

    final semantics = tester.ensureSemantics();
    final data = tester.getSemantics(switchFinder).getSemanticsData();
    expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
    semantics.dispose();
  });

  for (final entry in <(String, ThemeData, AppExpressiveDestinationFamily)>[
    (
      'Classic',
      ClassicThemeDefinition.light(),
      AppExpressiveDestinationFamily.profile,
    ),
    (
      'Neo',
      NeoBrutalismThemeDefinition.light(),
      AppExpressiveDestinationFamily.profile,
    ),
    (
      'Expressive non-Profile destination',
      ExpressiveThemeDefinition.light(),
      AppExpressiveDestinationFamily.analytics,
    ),
  ]) {
    testWidgets('${entry.$1} keeps its existing switch theme', (tester) async {
      final baseSwitchTheme = entry.$2.switchTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: entry.$2,
          home: AppExpressiveDestinationTheme(
            family: entry.$3,
            child: Scaffold(
              body: SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final switchTheme = Theme.of(tester.element(find.byType(Switch)))
          .switchTheme;
      expect(switchTheme, same(baseSwitchTheme));
    });
  }
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
