import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/speed_dial_fab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final settings in [
      (size: const Size(320, 480), keyboard: 0.0, paneWidth: 320.0),
      (size: const Size(640, 320), keyboard: 0.0, paneWidth: 640.0),
      (size: const Size(320, 640), keyboard: 300.0, paneWidth: 320.0),
      (size: const Size(1024, 600), keyboard: 0.0, paneWidth: 320.0),
    ]) {
      testWidgets(
        'nutrition actions remain reachable ${brightness.name} $settings',
        (tester) async {
          await tester.binding.setSurfaceSize(settings.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.light
                  ? AppThemeFactory.light(AppThemeFamily.expressive)
                  : AppThemeFactory.dark(AppThemeFamily.expressive),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr', 'CA'),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: settings.size,
                  textScaler: TextScaler.linear(2),
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  viewPadding: const EdgeInsets.only(top: 24, bottom: 24),
                  viewInsets: EdgeInsets.only(bottom: settings.keyboard),
                ),
                child: child!,
              ),
              home: Scaffold(
                bottomNavigationBar: const SizedBox(height: 72),
                body: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: settings.paneWidth,
                    child: Scaffold(
                      appBar: AppBar(title: const Text('Nutrition')),
                      body: const SizedBox.expand(),
                      floatingActionButton: const SpeedDialFab(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final toggle = _button('toggle');
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final tag in ['log_food', 'log_measurement', 'toggle']) {
            final action = _button(tag);
            await tester.ensureVisible(action);
            await tester.pumpAndSettle();
            expect(action.hitTestable(), findsOneWidget);
            final rect = tester.getRect(action);
            expect(
              rect.left,
              greaterThanOrEqualTo(settings.size.width - settings.paneWidth),
            );
            // A scrollable compact menu can reveal one whole action at a time.
            expect(rect.top, greaterThanOrEqualTo(24));
            expect(
              rect.bottom,
              lessThanOrEqualTo(
                settings.size.height -
                    (settings.keyboard > 72 ? settings.keyboard : 72),
              ),
            );
          }
        },
      );
    }
    testWidgets('normal menu geometry stays unchanged ${brightness.name}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(411, 914));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.light
              ? AppThemeFactory.light(AppThemeFamily.expressive)
              : AppThemeFactory.dark(AppThemeFamily.expressive),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(floatingActionButton: SpeedDialFab()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(_button('toggle'));
      await tester.pumpAndSettle();
      final food = tester.getRect(_button('log_food'));
      final measurement = tester.getRect(_button('log_measurement'));
      final toggle = tester.getRect(_button('toggle'));
      expect(food.height, closeTo(60, .01));
      expect(measurement.height, closeTo(60, .01));
      expect(measurement.top - food.bottom, closeTo(8, .01));
      expect(toggle.top - measurement.bottom, closeTo(8, .01));
      expect(food.right, toggle.right);
      expect(measurement.right, toggle.right);
      expect(
        find.descendant(
          of: find.byType(SpeedDialFab),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Finder _button(String tag) => find.byWidgetPredicate(
  (widget) => widget is FloatingActionButton && widget.heroTag == tag,
);
