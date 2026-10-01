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
