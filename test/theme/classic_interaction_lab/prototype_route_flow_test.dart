import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_route_flow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('RouteFlowPrototype', () {
    testWidgets('platform and selective routes show the same local session', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      await _pumpPrototype(tester, observer: observer);

      await tester.tap(find.byKey(const ValueKey('route-flow-platform-open')));
      await tester.pumpAndSettle();
      final platformRoute = observer.pushed.last;
      expect(platformRoute, isA<MaterialPageRoute<void>>());
      expect(_sessionContent(tester), _expectedSessionContent);
      final platformContent = _sessionContent(tester);

      await _sendPlatformBack(tester);
      expect(
        find.byKey(const ValueKey('route-flow-prototype')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('route-flow-selective-open')));
      await tester.pumpAndSettle();
      final selectiveRoute = observer.pushed.last as PageRoute<void>;
      expect(selectiveRoute, isNot(isA<MaterialPageRoute<void>>()));
      expect(
        selectiveRoute.transitionDuration,
        const Duration(milliseconds: 240),
      );
      expect(
        selectiveRoute.reverseTransitionDuration,
        const Duration(milliseconds: 240),
      );
      expect(_sessionContent(tester), platformContent);
      expect(_sessionContent(tester), _expectedSessionContent);

      await _sendPlatformBack(tester);
      expect(
        find.byKey(const ValueKey('route-flow-prototype')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion makes the selective route zero-duration', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      await _pumpPrototype(tester, observer: observer, disableAnimations: true);

      expect(find.text('No-motion route'), findsOneWidget);
      expect(
        find.text(
          'Reduced motion resolves the selective route to zero duration and '
          'removes movement.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('route-flow-selective-open')));
      await tester.pumpAndSettle();

      final selectiveRoute = observer.pushed.last as PageRoute<void>;
      expect(selectiveRoute.transitionDuration, Duration.zero);
      expect(selectiveRoute.reverseTransitionDuration, Duration.zero);
      expect(_sessionContent(tester), _expectedSessionContent);

      await _sendPlatformBack(tester);
      expect(
        find.byKey(const ValueKey('route-flow-prototype')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('both routes retain the Navigator top safe inset', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 2.625;
      tester.view.padding = const FakeViewPadding(top: 63, bottom: 63);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpPrototype(tester);

      for (final routeKey in [
        const ValueKey('route-flow-platform-open'),
        const ValueKey('route-flow-selective-open'),
      ]) {
        await tester.tap(find.byKey(routeKey));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<MediaQuery>(
                find.byKey(const ValueKey('route-flow-session-media-query')),
              )
              .data
              .padding
              .top,
          24,
        );

        await _sendPlatformBack(tester);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('both routes keep the same local completion-sheet behavior', (
      tester,
    ) async {
      await _pumpPrototype(tester);

      for (final routeKey in [
        const ValueKey('route-flow-platform-open'),
        const ValueKey('route-flow-selective-open'),
      ]) {
        await tester.tap(find.byKey(routeKey));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('route-flow-session-finish')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('route-flow-completion-sheet')),
          findsOneWidget,
        );
        expect(find.text('Workout complete'), findsOneWidget);
        expect(
          find.text('Local route-flow demo. No session was saved.'),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('route-flow-completion-close')),
        );
        await tester.pumpAndSettle();
        await _sendPlatformBack(tester);
      }

      expect(
        find.byKey(const ValueKey('route-flow-prototype')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

const _expectedSessionContent = <String, int>{
  'Workout Session': 1,
  'Barbell Squat': 1,
  '2/2 done': 1,
  'Bench Press - Barbell': 1,
  '1/2 done': 1,
  'Set 1': 1,
  'Weight (lbs)   115': 1,
  'Reps   10': 1,
  'Finish Workout': 1,
};

Map<String, int> _sessionContent(WidgetTester tester) => {
  for (final label in _expectedSessionContent.keys)
    label: find.text(label).evaluate().length,
};

Future<void> _pumpPrototype(
  WidgetTester tester, {
  NavigatorObserver? observer,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemeFactory.light(AppThemeFamily.classic),
      navigatorObservers: [if (observer != null) observer],
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: RouteFlowPrototype(),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _sendPlatformBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}
