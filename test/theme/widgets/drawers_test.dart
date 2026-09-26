import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/widgets/drawers.dart';

void main() {
  test('profile identity palette remains explicit and distinct', () {
    expect(ProfileIdentityPalette.colors, <Color>[
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ]);
    expect(ProfileIdentityPalette.colors.toSet(), hasLength(5));
    expect(ProfileIdentityPalette.currentProfileAvatar, Colors.lightGreen);
  });

  test(
    'plan identity palette remains fixed and distinct from state colors',
    () {
      expect(PlanIdentityPalette.colors, <Color>[
        Colors.blue,
        Colors.orange,
        Colors.green,
        Colors.purple,
        Colors.teal,
      ]);
      expect(PlanIdentityPalette.colors.toSet(), hasLength(5));
    },
  );

  testWidgets(
    'Classic drawer headers preserve the original light and dark role',
    (tester) async {
      for (final theme in <ThemeData>[
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainDrawer(headerTitle: 'Menu', items: <DrawerItem>[]),
          ),
        );

        final header = tester.widget<Text>(find.text('Menu'));
        expect(header.style?.color, Colors.white);
        expect(header.style?.fontSize, 18);
      }
    },
  );
}
