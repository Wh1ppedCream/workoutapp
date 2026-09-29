import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/classic_interaction_lab/classic_interaction_lab_page.dart';

void main() {
  testWidgets('prototype page is empty when its compile-time gate is off', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        home: const ClassicInteractionLabPage(enabled: false),
      ),
    );

    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('Classic interaction lab'), findsNothing);
  });

  testWidgets('enabled lab contains the seven local comparison areas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: const [Locale('en')],
        home: const ClassicInteractionLabPage(enabled: true),
      ),
    );

    for (final label in [
      'Primary action',
      'Train tab selection',
      'Exercise-card expansion',
      'Set completion',
      'Exercise overflow menu',
      'Progress · ranges and chart points',
      'Train → Session route',
    ]) {
      expect(
        find.text(label),
        findsOneWidget,
        reason: '$label should be in the lab',
      );
    }
  });
}
