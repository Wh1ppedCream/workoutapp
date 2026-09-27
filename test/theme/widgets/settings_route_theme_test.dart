import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/screens/profile/settings/gym_exercise_settings_page.dart';
import 'package:env_test/screens/profile/settings/nav_bar_settings_page.dart';
import 'package:env_test/services/workout_exit_preferences.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('navigation and gym settings have exact scoped inventory ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    const expected = <String, (String, int, List<String>)>{
      'navigation-settings-theme-recipes': (
        'lib/screens/profile/settings/nav_bar_settings_page.dart',
        3,
        ['color', 'color_transform', 'decoration'],
      ),
      'gym-exercise-settings-dialog-ink': (
        'lib/screens/profile/settings/gym_exercise_settings_page.dart',
        2,
        ['text_style'],
      ),
    };

    for (final entry in expected.entries) {
      final rule = inventory.pathRules.singleWhere(
        (rule) => rule.id == entry.key,
      );
      expect(rule.pattern, entry.value.$1);
      expect(rule.classification, 'structural_theme');
      expect(rule.status, 'migrated');
      expect(rule.kinds, unorderedEquals(entry.value.$3));

      final findings =
          report.findings
              .where((finding) => finding.ruleId == rule.id)
              .toList();
      expect(findings, hasLength(entry.value.$2), reason: entry.key);
      expect(
        findings.map((finding) => finding.status),
        everyElement('migrated'),
      );
      expect(
        report.findings.where(
          (finding) =>
              finding.file == rule.pattern && finding.status == 'pending',
        ),
        isEmpty,
        reason: rule.pattern,
      );
    }
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Navigation Settings retains Material ownership', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(430, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = NavBarConfig(
          buildPolicy: const NavigationBuildPolicy(
            experimentalTabsEnabled: false,
            isReleaseMode: false,
          ),
        );
        addTearDown(config.dispose);

        await tester.pumpWidget(
          ChangeNotifierProvider<NavBarConfig>.value(
            value: config,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const NavBarSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(NavBarSettingsPage));
        final shapes = context.shapeTokens;
        final badges =
            tester.widgetList<Container>(find.byType(Container)).where((
              container,
            ) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  container.child is Icon &&
                  decoration.color != null &&
                  decoration.borderRadius == shapes.settingsAction;
            }).toList();
        expect(badges, isNotEmpty);
        for (final badge in badges) {
          final decoration = badge.decoration as BoxDecoration;
          expect(decoration.borderRadius, shapes.settingsAction);
          expect(badge.child, isA<Icon>());
          final iconColor = (badge.child as Icon).color!;
          expect(decoration.color, iconColor.withValues(alpha: 0.16));
        }

        final reorderable = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView).first,
        );
        final dragProxy = reorderable.proxyDecorator!(
          const SizedBox.shrink(),
          0,
          const AlwaysStoppedAnimation<double>(1),
        );
        expect(dragProxy, isA<Material>());
        expect((dragProxy as Material).color, Colors.transparent);
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      });

      testWidgets('$mode Gym Settings dialog ink is surface-qualified', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(430, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const GymExerciseSettingsPage(),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(GymExerciseSettingsPage)),
        );
        await tester.tap(find.text(strings.gymSettingsExitTitle));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(TonosDialogFrame));
        final neo = family == AppThemeFamily.neoBrutalism;
        final expectedInk = neo ? context.cs.onPrimaryContainer : null;
        final choices = tester.widgetList<RadioListTile<WorkoutExitBehavior>>(
          find.byType(RadioListTile<WorkoutExitBehavior>),
        );
        expect(choices, hasLength(WorkoutExitBehavior.values.length));
        for (final choice in choices) {
          expect((choice.title! as Text).style?.color, expectedInk);
          expect((choice.subtitle! as Text).style?.color, expectedInk);
        }
        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
