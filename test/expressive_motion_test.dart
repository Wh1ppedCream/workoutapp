import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';

const _indicatorColor = Color(0xFF2468AC);

Widget _host(
  Widget child, {
  bool disableAnimations = false,
  bool tickerEnabled = true,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: TickerMode(
            enabled: tickerEnabled,
            child: Scaffold(body: Center(child: child)),
          ),
        );
      },
    ),
  );
}

Widget _selectionGroup({
  required int selectedIndex,
  required int itemCount,
  required ValueChanged<int> onTap,
  Object? topologyKey = 'stable',
}) {
  return SizedBox(
    width: 240,
    height: 48,
    child: TonosExpressiveSelectionIndicator(
      selectedIndex: selectedIndex,
      itemCount: itemCount,
      color: _indicatorColor,
      borderRadius: BorderRadius.circular(20),
      travelBorderRadius: BorderRadius.circular(8),
      topologyKey: topologyKey,
      child: Row(
        children: List.generate(
          itemCount,
          (index) => Expanded(
            child: Semantics(
              button: true,
              selected: selectedIndex == index,
              label: 'Choice ${index + 1}',
              child: InkWell(
                onTap: () => onTap(index),
                child: Center(child: Text('Choice ${index + 1}')),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _selectionDecoration() {
  return find.byWidgetPredicate((widget) {
    if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
      return false;
    }
    return (widget.decoration as BoxDecoration).color == _indicatorColor;
  });
}

BorderRadius _selectionRadius(WidgetTester tester) {
  return (tester.widget<DecoratedBox>(_selectionDecoration()).decoration
          as BoxDecoration)
      .borderRadius!
      .resolve(TextDirection.ltr);
}

double _relativeIndicatorCenterX(WidgetTester tester) {
  return tester.getCenter(_selectionDecoration()).dx -
      tester.getRect(find.byType(TonosExpressiveSelectionIndicator)).left;
}

Widget _pressHost({
  required VoidCallback onTap,
  bool disableAnimations = false,
  bool tickerEnabled = true,
  bool autofocus = false,
  bool responseEnabled = true,
  bool childActionEnabled = true,
}) {
  return _host(
    SizedBox(
      key: const ValueKey('press-layout'),
      width: 240,
      height: 64,
      child: TonosExpressivePressResponse(
        enabled: responseEnabled,
        borderRadius: BorderRadius.circular(22),
        pressedBorderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.deepPurple,
          child: InkWell(
            key: const ValueKey('start-action'),
            autofocus: autofocus,
            onTap: childActionEnabled ? onTap : null,
            child: const Center(child: Text('Start workout')),
          ),
        ),
      ),
    ),
    disableAnimations: disableAnimations,
    tickerEnabled: tickerEnabled,
  );
}

Widget _ambientHost({
  required bool disableAnimations,
  required bool tickerEnabled,
  bool enabled = true,
}) {
  return _host(
    TonosExpressiveAmbientMotion(
      enabled: enabled,
      child: const SizedBox(width: 40, height: 40, key: ValueKey('ambient')),
      builder: (context, phase, child) => Transform.translate(
        key: const ValueKey('ambient-transform'),
        offset: Offset(phase * 12, 0),
        transformHitTests: false,
        child: child,
      ),
    ),
    disableAnimations: disableAnimations,
    tickerEnabled: tickerEnabled,
  );
}

Widget _revealHost({
  required bool disableAnimations,
  required VoidCallback onTap,
}) {
  return _host(
    TonosExpressiveReveal(
      staggerIndex: 2,
      child: Material(
        child: InkWell(
          key: const ValueKey('reveal-action'),
          onTap: onTap,
          child: const SizedBox(width: 160, height: 64),
        ),
      ),
    ),
    disableAnimations: disableAnimations,
  );
}

BorderRadius _pressRadius(WidgetTester tester) {
  return tester
          .widget<ClipRRect>(
            find.descendant(
              of: find.byType(TonosExpressivePressResponse),
              matching: find.byType(ClipRRect),
            ),
          )
          .borderRadius
      as BorderRadius;
}

void main() {
  testWidgets('selection spring retargets and settles to the latest choice', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      var selectedIndex = 0;
      var tappedIndex = -1;
      Widget group() => _selectionGroup(
        selectedIndex: selectedIndex,
        itemCount: 3,
        onTap: (index) => tappedIndex = index,
      );

      await tester.pumpWidget(_host(group()));
      expect(_relativeIndicatorCenterX(tester), closeTo(40, 0.1));

      selectedIndex = 2;
      await tester.pumpWidget(_host(group()));
      await tester.pump(const Duration(milliseconds: 80));
      final inFlightCenter = _relativeIndicatorCenterX(tester);
      expect(inFlightCenter, greaterThan(40));
      expect(inFlightCenter, lessThan(200));

      selectedIndex = 1;
      await tester.pumpWidget(_host(group()));
      await tester.pumpAndSettle();

      expect(_relativeIndicatorCenterX(tester), closeTo(120, 0.1));
      final choiceTwo = tester.getSemantics(
        find.bySemanticsLabel(RegExp(r'Choice 2')),
      );
      expect(
        choiceTwo.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        choiceTwo.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(tappedIndex, -1);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('selection fill morphs its bounded width and silhouette', (
    tester,
  ) async {
    var selectedIndex = 0;
    Widget group() => _selectionGroup(
      selectedIndex: selectedIndex,
      itemCount: 3,
      onTap: (_) {},
    );

    await tester.pumpWidget(_host(group()));
    final groupRect = tester.getRect(
      find.byType(TonosExpressiveSelectionIndicator),
    );
    final selectedWidth = groupRect.width / 3 * 0.94;
    final travelRadius = BorderRadius.circular(8);
    expect(
      tester.getSize(_selectionDecoration()).width,
      closeTo(selectedWidth, 0.1),
    );
    expect(_selectionRadius(tester), BorderRadius.circular(20));

    selectedIndex = 2;
    await tester.pumpWidget(_host(group()));
    await tester.pump(const Duration(milliseconds: 25));
    final travelingWidth = tester.getSize(_selectionDecoration()).width;
    expect(travelingWidth, lessThan(selectedWidth));
    expect(travelingWidth, greaterThan(groupRect.width / 3 * 0.78));
    expect(
      _selectionRadius(tester).topLeft.x,
      greaterThan(travelRadius.topLeft.x),
    );
    expect(_selectionRadius(tester).topLeft.x, lessThan(20));

    await tester.pumpAndSettle();
    expect(
      tester.getSize(_selectionDecoration()).width,
      closeTo(selectedWidth, 0.1),
    );
    expect(_selectionRadius(tester), BorderRadius.circular(20));
  });

  testWidgets('selection snaps when count or ordered topology changes', (
    tester,
  ) async {
    var selectedIndex = 0;
    var itemCount = 3;
    Object topologyKey = 'first-order';
    Widget group() => _selectionGroup(
      selectedIndex: selectedIndex,
      itemCount: itemCount,
      topologyKey: topologyKey,
      onTap: (_) {},
    );

    await tester.pumpWidget(_host(group()));
    selectedIndex = 2;
    topologyKey = 'reordered';
    await tester.pumpWidget(_host(group()));
    expect(_relativeIndicatorCenterX(tester), closeTo(200, 0.1));

    itemCount = 2;
    selectedIndex = 1;
    await tester.pumpWidget(_host(group()));
    expect(_relativeIndicatorCenterX(tester), closeTo(180, 0.1));
  });

  testWidgets('selection indicator follows RTL slot order', (tester) async {
    await tester.pumpWidget(
      _host(
        Directionality(
          textDirection: TextDirection.rtl,
          child: _selectionGroup(selectedIndex: 0, itemCount: 3, onTap: (_) {}),
        ),
      ),
    );

    expect(_relativeIndicatorCenterX(tester), closeTo(200, 0.1));
  });

  testWidgets('reduced motion snaps before and during selection movement', (
    tester,
  ) async {
    var selectedIndex = 0;
    var disableAnimations = false;
    Widget group() => _selectionGroup(
      selectedIndex: selectedIndex,
      itemCount: 3,
      onTap: (_) {},
    );

    await tester.pumpWidget(_host(group()));
    selectedIndex = 2;
    disableAnimations = true;
    await tester.pumpWidget(
      _host(group(), disableAnimations: disableAnimations),
    );
    expect(_relativeIndicatorCenterX(tester), closeTo(200, 0.1));

    disableAnimations = false;
    selectedIndex = 0;
    await tester.pumpWidget(
      _host(group(), disableAnimations: disableAnimations),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(_relativeIndicatorCenterX(tester), greaterThan(40));

    disableAnimations = true;
    await tester.pumpWidget(
      _host(group(), disableAnimations: disableAnimations),
    );
    expect(_relativeIndicatorCenterX(tester), closeTo(40, 0.1));
  });

  testWidgets(
    'press release springs while layout and callback stay owned by child',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        var tapCount = 0;
        await tester.pumpWidget(_pressHost(onTap: () => tapCount++));

        final layoutRect = tester.getRect(
          find.byKey(const ValueKey('press-layout')),
        );
        final actionRect = tester.getRect(
          find.byKey(const ValueKey('start-action')),
        );
        final startSemantics = tester.getSemantics(
          find.bySemanticsLabel('Start workout'),
        );
        expect(
          startSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );

        // Rounded visual clipping must leave the child's rectangular hit area
        // and semantics bounds intact, including at a clipped corner.
        final gesture = await tester.startGesture(
          Offset(actionRect.right - 1, actionRect.top + 1),
        );
        await tester.pump();
        expect(_pressRadius(tester), BorderRadius.circular(14));
        expect(
          tester.getRect(find.byKey(const ValueKey('press-layout'))),
          layoutRect,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('start-action'))),
          actionRect.size,
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Start workout')).rect,
          startSemantics.rect,
        );

        await gesture.up();
        await tester.pump();
        expect(tapCount, 1);
        await tester.pump(const Duration(milliseconds: 50));
        expect(_pressRadius(tester).topLeft.x, greaterThan(14));
        expect(_pressRadius(tester).topLeft.x, lessThan(22));
        await tester.pumpAndSettle();

        expect(tapCount, 1);
        expect(_pressRadius(tester), BorderRadius.circular(22));
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets('reduced motion cancels an in-flight press recovery', (
    tester,
  ) async {
    var tapCount = 0;
    var disableAnimations = false;
    Widget host() => _pressHost(
      onTap: () => tapCount++,
      disableAnimations: disableAnimations,
    );

    await tester.pumpWidget(host());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('start-action'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(_pressRadius(tester).topLeft.x, greaterThan(14));
    expect(_pressRadius(tester).topLeft.x, lessThan(22));

    disableAnimations = true;
    await tester.pumpWidget(host());
    expect(_pressRadius(tester), BorderRadius.circular(22));
    await tester.pumpAndSettle();
    expect(_pressRadius(tester), BorderRadius.circular(22));
    expect(tapCount, 1);
  });

  testWidgets('TickerMode snaps a press response when its owner is hidden', (
    tester,
  ) async {
    var tickerEnabled = true;
    Widget host() => _pressHost(onTap: () {}, tickerEnabled: tickerEnabled);

    await tester.pumpWidget(host());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('start-action'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(_pressRadius(tester).topLeft.x, greaterThan(14));
    expect(_pressRadius(tester).topLeft.x, lessThan(22));

    tickerEnabled = false;
    await tester.pumpWidget(host());
    expect(_pressRadius(tester), BorderRadius.circular(22));
    await tester.pumpAndSettle();
    expect(_pressRadius(tester), BorderRadius.circular(22));
  });

  testWidgets('disabled action has no visual press or child activation', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      var tapCount = 0;
      await tester.pumpWidget(
        _pressHost(
          onTap: () => tapCount++,
          responseEnabled: false,
          childActionEnabled: false,
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('start-action'))),
      );
      await tester.pump();
      expect(_pressRadius(tester), BorderRadius.circular(22));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapCount, 0);
      expect(_pressRadius(tester), BorderRadius.circular(22));
      expect(find.bySemanticsLabel('Start workout'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Start workout'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('pointer cancel returns the press shape without activation', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(_pressHost(onTap: () => tapCount++));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('start-action'))),
    );
    await tester.pump();
    expect(_pressRadius(tester), BorderRadius.circular(14));

    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(tapCount, 0);
    expect(_pressRadius(tester), BorderRadius.circular(22));
  });

  testWidgets('a second press retargets the current release without queuing', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(_pressHost(onTap: () => tapCount++));
    final target = tester.getCenter(find.byKey(const ValueKey('start-action')));

    final firstGesture = await tester.startGesture(target);
    await tester.pump();
    await firstGesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(_pressRadius(tester).topLeft.x, greaterThan(14));
    expect(_pressRadius(tester).topLeft.x, lessThan(22));

    final secondGesture = await tester.startGesture(target);
    await tester.pump();
    expect(_pressRadius(tester), BorderRadius.circular(14));
    await secondGesture.up();
    await tester.pump();
    expect(tapCount, 2);
    await tester.pumpAndSettle();

    expect(tapCount, 2);
    expect(_pressRadius(tester), BorderRadius.circular(22));
  });

  testWidgets('disposing a running press simulation leaves no ticker behind', (
    tester,
  ) async {
    await tester.pumpWidget(_pressHost(onTap: () {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('start-action'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keyboard activation stays on child and does not synthesize a press',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        var tapCount = 0;
        await tester.pumpWidget(
          _pressHost(onTap: () => tapCount++, autofocus: true),
        );

        expect(find.bySemanticsLabel('Start workout'), findsOneWidget);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Start workout'))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(tapCount, 1);
        expect(_pressRadius(tester), BorderRadius.circular(22));
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets('press scale keeps the full child hit target and callback', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _host(
        TonosExpressivePressResponse(
          enabled: true,
          pressedScale: 0.84,
          borderRadius: BorderRadius.circular(22),
          pressedBorderRadius: BorderRadius.circular(12),
          child: Material(
            child: InkWell(
              key: const ValueKey('scaled-action'),
              onTap: () => tapCount++,
              child: const SizedBox(width: 160, height: 64),
            ),
          ),
        ),
      ),
    );
    final action = find.byKey(const ValueKey('scaled-action'));
    final target = tester.getRect(action);
    final gesture = await tester.startGesture(
      Offset(target.right - 1, target.center.dy),
    );
    await tester.pump();
    expect(tester.getRect(action).width, lessThan(target.width));
    await gesture.up();
    await tester.pump();
    expect(tapCount, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('ambient motion breathes in the resumed active region', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ambientHost(disableAnimations: false, tickerEnabled: true),
    );
    final start = tester.getRect(find.byKey(const ValueKey('ambient')));
    await tester.pump(const Duration(seconds: 4));
    final middle = tester.getRect(find.byKey(const ValueKey('ambient')));
    await tester.pump(const Duration(seconds: 4));
    final peak = tester.getRect(find.byKey(const ValueKey('ambient')));

    expect(middle.left, greaterThan(start.left));
    expect(peak.left, greaterThan(middle.left));
    await tester.pump(const Duration(seconds: 8));
    expect(
      tester.getRect(find.byKey(const ValueKey('ambient'))).left,
      closeTo(start.left, 0.1),
    );
  });

  testWidgets('ambient motion snaps for reduced motion and disabled tickers', (
    tester,
  ) async {
    var disableAnimations = true;
    var tickerEnabled = true;
    Widget host() => _ambientHost(
      disableAnimations: disableAnimations,
      tickerEnabled: tickerEnabled,
    );

    await tester.pumpWidget(host());
    final start = tester.getRect(find.byKey(const ValueKey('ambient')));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.getRect(find.byKey(const ValueKey('ambient'))), start);

    disableAnimations = false;
    tickerEnabled = false;
    await tester.pumpWidget(host());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.getRect(find.byKey(const ValueKey('ambient'))), start);
  });

  testWidgets('ambient motion stops while its visual owner is inactive', (
    tester,
  ) async {
    var enabled = false;
    Widget host() => _ambientHost(
      disableAnimations: false,
      tickerEnabled: true,
      enabled: enabled,
    );

    await tester.pumpWidget(host());
    final start = tester.getRect(find.byKey(const ValueKey('ambient')));
    await tester.pump(const Duration(seconds: 4));
    expect(tester.getRect(find.byKey(const ValueKey('ambient'))), start);

    enabled = true;
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(
      tester.getRect(find.byKey(const ValueKey('ambient'))).left,
      greaterThan(start.left),
    );
  });

  testWidgets('ambient motion stops when app is inactive and resumes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ambientHost(disableAnimations: false, tickerEnabled: true),
    );
    await tester.pump(const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    final paused = tester.getRect(find.byKey(const ValueKey('ambient')));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.getRect(find.byKey(const ValueKey('ambient'))), paused);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.getRect(find.byKey(const ValueKey('ambient'))).left,
      greaterThan(paused.left),
    );
  });

  testWidgets('ambient controller disposes while looping', (tester) async {
    await tester.pumpWidget(
      _ambientHost(disableAnimations: false, tickerEnabled: true),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reveal staggers, stays interactive, and snaps for reduced motion',
    (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _revealHost(disableAnimations: false, onTap: () => tapCount++),
      );
      final action = find.byKey(const ValueKey('reveal-action'));
      final initial = tester.getRect(action);
      await tester.pump(const Duration(milliseconds: 170));
      final arriving = tester.getRect(action);
      expect(arriving.top, lessThan(initial.top));
      await tester.tap(action);
      await tester.pump();
      expect(tapCount, 1);
      await tester.pumpAndSettle();

      var disableAnimations = true;
      await tester.pumpWidget(
        _host(
          TonosExpressiveReveal(
            staggerIndex: 4,
            child: const SizedBox(
              key: ValueKey('reduced-reveal-child'),
              width: 100,
              height: 40,
            ),
          ),
          disableAnimations: disableAnimations,
        ),
      );
      final child = find.byKey(const ValueKey('reduced-reveal-child'));
      expect(tester.getSize(child), const Size(100, 40));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getSize(child), const Size(100, 40));
    },
  );
}
