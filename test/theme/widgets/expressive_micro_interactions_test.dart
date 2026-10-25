import 'dart:ui' as ui;

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/widgets/speed_dial_fab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _actionKey = ValueKey('micro-action');

void main() {
  testWidgets('an inactive nutrition menu cannot intercept another page Back', (
    tester,
  ) async {
    var active = true;
    late StateSetter updatePage;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StatefulBuilder(
                  builder: (context, update) {
                    updatePage = update;
                    return Scaffold(
                      body: TickerMode(
                        enabled: active,
                        child: const SpeedDialFab(),
                      ),
                    );
                  },
                ),
              ),
            ),
            child: const Text('Open nutrition actions'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open nutrition actions'));
    await tester.pumpAndSettle();
    final toggle = find.byWidgetPredicate(
      (widget) => widget is FloatingActionButton && widget.heroTag == 'toggle',
    );
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    updatePage(() => active = false);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SpeedDialFab), findsNothing);
    expect(find.text('Open nutrition actions'), findsOneWidget);
  });

  testWidgets('Back dismisses nutrition actions before leaving the page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: SpeedDialFab()),
              ),
            ),
            child: const Text('Open nutrition actions'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open nutrition actions'));
    await tester.pumpAndSettle();
    final toggle = find.byWidgetPredicate(
      (widget) => widget is FloatingActionButton && widget.heroTag == 'toggle',
    );
    final strings = AppLocalizations.of(tester.element(toggle));
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text(strings.speedDialLogFood), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SpeedDialFab), findsOneWidget);
    expect(find.text(strings.speedDialLogFood), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SpeedDialFab), findsNothing);
    expect(find.text('Open nutrition actions'), findsOneWidget);
  });

  testWidgets('scrolling releases a pressed card before the finger lifts', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        ListView(
          children: [
            const SizedBox(height: 100),
            Center(child: _press(() => taps++)),
            const SizedBox(height: 1000),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(_actionKey)),
    );
    await tester.pump();
    expect(_scale(tester), closeTo(.9, .001));
    await gesture.moveBy(const Offset(0, -48));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_scale(tester), closeTo(1, .001));
    expect(taps, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
    await tester.tap(find.byKey(_actionKey));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('small pointer movement keeps an ordinary press active', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_host(Center(child: _press(() => taps++))));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(_actionKey)),
    );
    await gesture.moveBy(const Offset(2, 2));
    await tester.pump();
    expect(_scale(tester), closeTo(.9, .001));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets(
    'secondary mouse clicks do not press or activate a primary action',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(Center(child: _press(() => taps++))));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(_actionKey)),
        kind: ui.PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await tester.pump();
      expect(_scale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 0);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets('motion overrides stop press feedback ${brightness.name}', (
      tester,
    ) async {
      var taps = 0;
      Widget frame(bool motion) => _host(
        Center(child: _press(() => taps++)),
        theme: _theme(brightness, motion: motion),
      );
      await tester.pumpWidget(frame(false));
      var gesture = await tester.startGesture(
        tester.getCenter(find.byKey(_actionKey)),
      );
      await tester.pump();
      expect(_scale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.pumpWidget(frame(true));
      gesture = await tester.startGesture(
        tester.getCenter(find.byKey(_actionKey)),
      );
      await tester.pump();
      expect(_scale(tester), closeTo(.9, .001));
      await tester.pumpWidget(frame(false));
      expect(_scale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'nutrition toggle announces its purpose and state ${brightness.name}',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _host(const SpeedDialFab(), theme: _theme(brightness)),
          );
          await tester.pumpAndSettle();
          final toggle = find.byWidgetPredicate(
            (widget) =>
                widget is FloatingActionButton && widget.heroTag == 'toggle',
          );
          final strings = AppLocalizations.of(tester.element(toggle));
          final semanticToggle = find
              .ancestor(of: toggle, matching: find.byType(MergeSemantics))
              .first;
          var semantics = tester
              .getSemantics(semanticToggle)
              .getSemanticsData();
          expect(semantics.tooltip, strings.nutritionAddEntryActionLabel);
          expect(semantics.flagsCollection.isExpanded, ui.Tristate.isFalse);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          semantics = tester.getSemantics(semanticToggle).getSemanticsData();
          expect(semantics.tooltip, strings.commonClose);
          expect(semantics.flagsCollection.isExpanded, ui.Tristate.isTrue);
          expect(find.text(strings.speedDialLogFood), findsOneWidget);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          expect(find.text(strings.speedDialLogFood), findsNothing);
          expect(tester.takeException(), isNull);
        } finally {
          handle.dispose();
        }
      },
    );
  }
}

Widget _press(VoidCallback onTap) => SizedBox(
  width: 220,
  height: 64,
  child: TonosExpressivePressResponse(
    enabled: true,
    pressedScale: .9,
    allowReleaseOvershoot: false,
    child: Material(
      child: InkWell(
        key: _actionKey,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    ),
  ),
);

double _scale(WidgetTester tester) => tester
    .widgetList<Transform>(
      find.descendant(
        of: find.byType(TonosExpressivePressResponse),
        matching: find.byType(Transform),
      ),
    )
    .last
    .transform
    .storage[0];

ThemeData _theme(Brightness brightness, {bool motion = true}) {
  final theme = brightness == Brightness.light
      ? AppThemeFactory.light(AppThemeFamily.expressive)
      : AppThemeFactory.dark(AppThemeFamily.expressive);
  return motion
      ? theme
      : theme.copyWith(
          extensions: theme.extensions.values.map(
            (extension) => extension is AppMotionTokens
                ? extension.copyWith(standard: Duration.zero)
                : extension,
          ),
        );
}

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? _theme(Brightness.light),
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);
