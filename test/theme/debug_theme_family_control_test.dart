import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/debug_theme_family_control.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('switches and persists above the Navigator without an Overlay', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider(
      capabilities: const AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: false,
      ),
    );
    await provider.ready;

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          builder:
              (context, child) => Stack(
                children: [
                  child!,
                  const Positioned(
                    top: 0,
                    right: 48,
                    child: SafeArea(child: DebugThemeFamilyControl()),
                  ),
                ],
              ),
          home: const Scaffold(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('debug-theme-family-control')));
    await tester.pumpAndSettle();

    expect(provider.family, AppThemeFamily.neoBrutalism);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme_family'), 'neo_brutalism');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('debug-theme-family-control')));
    await tester.pumpAndSettle();
    expect(provider.family, AppThemeFamily.classic);
    expect(preferences.getString('theme_family'), 'classic');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('hides the family switcher when experimental families are off', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider(
      capabilities: const AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: false,
      ),
    );
    await provider.ready;

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          home: const Scaffold(body: DebugThemeFamilyControl()),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('debug-theme-family-control')),
      findsNothing,
    );
    provider.dispose();
  });
}
