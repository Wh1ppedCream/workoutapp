import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/widgets/expressive_train_focus_progress.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final hits = <FocusedSetHit>[
    FocusedSetHit(bodyPart: BodyPart(1, 'Chest'), units: 12),
    FocusedSetHit(bodyPart: BodyPart(2, 'Back'), units: 3),
    FocusedSetHit(bodyPart: BodyPart(3, 'Legs'), units: 2),
  ];

  Widget host(
    Widget child, {
    TextScaler textScaler = TextScaler.noScaling,
    bool disableAnimations = false,
    bool tickerEnabled = true,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return MaterialApp(
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: textScaler,
          disableAnimations: disableAnimations,
        ),
        child: TickerMode(enabled: tickerEnabled, child: child!),
      ),
      home: Scaffold(
        body: Directionality(textDirection: textDirection, child: child),
      ),
    );
  }

  testWidgets('Train opt-in waves keep exact progress values and semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    final phase = ValueNotifier<double>(0);
    addTearDown(phase.dispose);
    try {
      await tester.pumpWidget(
        host(FocusedSetsList(hits: hits, expressiveProgressPhase: phase)),
      );

      final indicators = find.byType(LinearProgressIndicator);
      expect(indicators, findsNWidgets(3));
      _expectValues(tester, indicators, <double>[1, 0.25, 2 / 12]);
      _expectSemanticValues(tester, indicators, <String>['100', '25', '17']);

      phase.value = 0.25;
      await tester.pump();

      final painters = _painters(tester);
      expect(painters, hasLength(3));
      for (final painter in painters) {
        expect(painter.phase, 0.25);
      }
      _expectValues(tester, indicators, <double>[1, 0.25, 2 / 12]);
      _expectSemanticValues(tester, indicators, <String>['100', '25', '17']);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('default FocusedSetsList keeps native static indicators', (
    tester,
  ) async {
    await tester.pumpWidget(host(FocusedSetsList(hits: hits)));

    expect(find.byType(ExpressiveTrainFocusProgress), findsNothing);
    expect(_painters(tester), isEmpty);
    _expectValues(tester, find.byType(LinearProgressIndicator), <double>[
      1,
      0.25,
      2 / 12,
    ]);
  });

  testWidgets('reduced motion and disabled tickers pin the wave at zero', (
    tester,
  ) async {
    final phase = ValueNotifier<double>(0.25);
    addTearDown(phase.dispose);

    await tester.pumpWidget(
      host(
        FocusedSetsList(hits: hits, expressiveProgressPhase: phase),
        disableAnimations: true,
      ),
    );
    expect(_painters(tester).map((painter) => painter.phase), everyElement(0));

    await tester.pumpWidget(
      host(
        FocusedSetsList(hits: hits, expressiveProgressPhase: phase),
        tickerEnabled: false,
      ),
    );
    expect(_painters(tester).map((painter) => painter.phase), everyElement(0));
    _expectValues(tester, find.byType(LinearProgressIndicator), <double>[
      1,
      0.25,
      2 / 12,
    ]);
  });

  test('active sinusoid travels without changing determinate extent', () {
    const size = Size(120, 6);
    final phaseZero = _painter(value: 0.7, phase: 0);
    final phaseQuarter = _painter(value: 0.7, phase: 0.25);
    final phaseZeroBounds = phaseZero.activeStrokePathFor(size)!.getBounds();
    final phaseQuarterBounds = phaseQuarter
        .activeStrokePathFor(size)!
        .getBounds();

    expect(phaseZero.activeRectFor(size), const Rect.fromLTWH(0, 0, 84, 6));
    expect(phaseQuarter.activeRectFor(size), phaseZero.activeRectFor(size));
    expect(phaseQuarterBounds.left, phaseZeroBounds.left);
    expect(phaseQuarterBounds.right, phaseZeroBounds.right);
    expect(phaseZeroBounds.left, greaterThanOrEqualTo(0));
    expect(phaseZeroBounds.right, lessThanOrEqualTo(84));
    expect(phaseZeroBounds.top, lessThan(1.6));
    expect(phaseZeroBounds.bottom, greaterThan(4.4));
    expect(
      phaseQuarter.terminalMarkerCenterFor(size),
      phaseZero.terminalMarkerCenterFor(size),
    );

    final phaseZeroMetric = phaseZero
        .activeStrokePathFor(size)!
        .computeMetrics()
        .single;
    final phaseQuarterMetric = phaseQuarter
        .activeStrokePathFor(size)!
        .computeMetrics()
        .single;
    final phaseZeroPoint = phaseZeroMetric
        .getTangentForOffset(phaseZeroMetric.length * 0.1)!
        .position;
    final phaseQuarterPoint = phaseQuarterMetric
        .getTangentForOffset(phaseQuarterMetric.length * 0.1)!
        .position;
    expect(
      phaseZeroPoint.dy,
      isNot(closeTo(phaseQuarterPoint.dy, 0.05)),
      reason: 'phase changes the stroke contour within the active extent',
    );
    expect(phaseZero.activeWaveStrokeWidth, 2.5);
    expect(
      phaseZero.activeWaveColor.computeLuminance(),
      greaterThan(phaseZero.fillColor.computeLuminance()),
    );
  });

  test('short, empty, full, and RTL values keep exact active extents', () {
    const size = Size(120, 6);
    final empty = _painter(value: 0, phase: 0.6);
    final short = _painter(value: 0.1, phase: 0.6);
    final tiny = _painter(value: 0.02, phase: 0.6);
    final full = _painter(value: 1, phase: 0.6);
    final rtl = _painter(
      value: 0.7,
      phase: 0.6,
      textDirection: TextDirection.rtl,
    );

    expect(empty.activeRectFor(size), const Rect.fromLTWH(0, 0, 0, 6));
    expect(empty.activeStrokePathFor(size), isNull);
    expect(short.activeRectFor(size), const Rect.fromLTWH(0, 0, 12, 6));
    expect(short.activeStrokePathFor(size), isNotNull);
    expect(tiny.activeRectFor(size), const Rect.fromLTWH(0, 0, 2.4, 6));
    final tinyStroke = tiny.activeStrokePathFor(size);
    expect(tinyStroke, isNotNull);
    expect(tinyStroke!.getBounds().height, greaterThan(0.4));
    expect(full.activeRectFor(size), const Rect.fromLTWH(0, 0, 120, 6));
    expect(full.activeStrokePathFor(size), isNotNull);
    expect(rtl.activeRectFor(size), const Rect.fromLTRB(36, 0, 120, 6));
    expect(
      rtl.activeStrokePathFor(size)!.getBounds().left,
      greaterThanOrEqualTo(36),
    );
    expect(
      rtl.activeStrokePathFor(size)!.getBounds().right,
      lessThanOrEqualTo(120),
    );
  });

  test(
    'straight remainder track starts outside the active wave in LTR and RTL',
    () {
      const size = Size(120, 6);
      final empty = _painter(value: 0, phase: 0.2);
      final short = _painter(value: 0.1, phase: 0.2);
      final full = _painter(value: 1, phase: 0.2);
      final rtl = _painter(
        value: 0.7,
        phase: 0.2,
        textDirection: TextDirection.rtl,
      );

      expect(
        empty.inactiveTrackPathFor(size)!.getBounds(),
        const Rect.fromLTRB(0, 3, 120, 3),
      );
      expect(
        short.inactiveTrackRectFor(size),
        const Rect.fromLTRB(12, 0, 120, 6),
      );
      expect(
        short.activeStrokePathFor(size)!.getBounds().right,
        short.inactiveTrackPathFor(size)!.getBounds().left,
      );
      expect(
        short.inactiveTrackPathFor(size)!.getBounds(),
        const Rect.fromLTRB(12, 3, 120, 3),
      );
      expect(full.inactiveTrackPathFor(size), isNull);
      expect(rtl.inactiveTrackRectFor(size), const Rect.fromLTRB(0, 0, 36, 6));
      expect(
        rtl.inactiveTrackPathFor(size)!.getBounds(),
        const Rect.fromLTRB(0, 3, 36, 3),
      );
      expect(
        rtl.inactiveTrackPathFor(size)!.getBounds().right,
        rtl.activeStrokePathFor(size)!.getBounds().left,
      );
    },
  );

  testWidgets('reduced motion keeps the sinusoid in its static pose', (
    tester,
  ) async {
    final phase = ValueNotifier<double>(0.75);
    addTearDown(phase.dispose);

    await tester.pumpWidget(
      host(
        FocusedSetsList(hits: hits, expressiveProgressPhase: phase),
        disableAnimations: true,
      ),
    );
    final reducedMotionPainters = _painters(tester);
    expect(
      reducedMotionPainters.map((painter) => painter.phase),
      everyElement(0),
    );
    final reducedStroke = reducedMotionPainters.last.activeStrokePathFor(
      const Size(100, 6),
    );
    expect(reducedStroke, isNotNull);
    expect(
      reducedStroke!
          .computeMetrics()
          .single
          .getTangentForOffset(3)!
          .position
          .dy,
      closeTo(
        _painter(value: 2 / 12, phase: 0)
            .activeStrokePathFor(const Size(100, 6))!
            .computeMetrics()
            .single
            .getTangentForOffset(3)!
            .position
            .dy,
        0.000001,
      ),
    );
  });

  testWidgets('wave bars fit compact width with 2x text and RTL', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final phase = ValueNotifier<double>(0.25);
    addTearDown(phase.dispose);

    await tester.pumpWidget(
      host(
        SizedBox(
          width: 288,
          child: FocusedSetsList(hits: hits, expressiveProgressPhase: phase),
        ),
        textScaler: const TextScaler.linear(2),
        textDirection: TextDirection.rtl,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
    expect(_painters(tester), hasLength(3));
    for (final bar in find.byType(ExpressiveTrainFocusProgress).evaluate()) {
      expect(tester.getSize(find.byWidget(bar.widget)).height, 6);
      expect(
        tester.getSize(find.byWidget(bar.widget)).width,
        lessThanOrEqualTo(288),
      );
    }
  });
}

void _expectValues(
  WidgetTester tester,
  Finder indicators,
  List<double> expected,
) {
  final values = tester
      .widgetList<LinearProgressIndicator>(indicators)
      .map((indicator) => indicator.value!)
      .toList();
  expect(values, hasLength(expected.length));
  for (var index = 0; index < expected.length; index++) {
    expect(values[index], closeTo(expected[index], 0.000001));
  }
}

void _expectSemanticValues(
  WidgetTester tester,
  Finder indicators,
  List<String> expected,
) {
  final nodes = indicators.evaluate().toList();
  expect(nodes, hasLength(expected.length));
  for (var index = 0; index < nodes.length; index++) {
    final data = tester
        .getSemantics(find.byWidget(nodes[index].widget))
        .getSemanticsData();
    expect(data.value, expected[index]);
  }
}

List<ExpressiveTrainFocusProgressPainter> _painters(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((widget) => widget.painter)
      .whereType<ExpressiveTrainFocusProgressPainter>()
      .toList();
}

ExpressiveTrainFocusProgressPainter _painter({
  required double value,
  required double phase,
  TextDirection textDirection = TextDirection.ltr,
}) => ExpressiveTrainFocusProgressPainter(
  value: value,
  phase: phase,
  fillColor: Colors.amber,
  trackColor: Colors.grey,
  borderRadius: BorderRadius.circular(99),
  textDirection: textDirection,
);
