import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_progress_interaction.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpPrototype(
    WidgetTester tester, {
    double width = 420,
    double textScale = 1,
    bool reducedMotion = false,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 1400));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        locale: const Locale('en'),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: const [Locale('en')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reducedMotion,
          ),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: ProgressInteractionPrototype(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  }

  Future<void> selectRange(
    WidgetTester tester, {
    required String controlKey,
    required String label,
  }) async {
    final control = find.byKey(ValueKey(controlKey));
    final option = find
        .descendant(of: control, matching: find.text(label))
        .first;
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  }

  testWidgets('all six ranges preserve selected meaning in both variants', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPrototype(tester);
    const options = <(String, String)>[
      ('1W', '1 Week'),
      ('1M', '1 Month'),
      ('3M', '3 Months'),
      ('6M', '6 Months'),
      ('1Y', '1 Year'),
      ('All', 'All'),
    ];
    for (final controlKey in [
      'progress-tonos-range',
      'progress-standard-material-range',
    ]) {
      for (final (shortLabel, fullLabel) in options) {
        await selectRange(tester, controlKey: controlKey, label: shortLabel);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('progress-selected-range')),
              )
              .data,
          'Selected range: $fullLabel',
        );
      }
    }
  });

  testWidgets('chart point semantics, tooltip, and keyboard selection work', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    try {
      await pumpPrototype(tester);
      final chart = find.byKey(const ValueKey('progress-chart-semantics'));
      var data = tester.getSemantics(chart).getSemanticsData();
      expect(data.label, 'Workout trend chart');
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.hasAction(SemanticsAction.increase), isFalse);

      tester.semantics.tap(find.semantics.byLabel('Workout trend chart'));
      await tester.pump();
      data = tester.getSemantics(chart).getSemanticsData();
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);
      final beforeIncrease = tester
          .widget<Text>(
            find.byKey(const ValueKey('progress-selected-point-value')),
          )
          .data;
      tester.semantics.increase(find.semantics.byLabel('Workout trend chart'));
      await tester.pump();
      final afterIncrease = tester
          .widget<Text>(
            find.byKey(const ValueKey('progress-selected-point-value')),
          )
          .data;
      expect(afterIncrease, isNot(beforeIncrease));

      final canvas = find.byKey(const ValueKey('progress-chart-canvas'));
      final topLeft = tester.getTopLeft(canvas);
      final size = tester.getSize(canvas);
      await tester.tapAt(
        Offset(topLeft.dx + size.width * .55, topLeft.dy + size.height * .5),
      );
      await tester.pump();
      final beforeKeyboardMove = tester
          .widget<Text>(
            find.byKey(const ValueKey('progress-selected-point-value')),
          )
          .data;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      final afterKeyboardMove = tester
          .widget<Text>(
            find.byKey(const ValueKey('progress-selected-point-value')),
          )
          .data;
      expect(beforeKeyboardMove, contains('workout'));
      expect(afterKeyboardMove, isNot(beforeKeyboardMove));
      expect(afterKeyboardMove, contains('workout'));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('changing range clears point selection', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPrototype(tester);
    final semantics = tester.ensureSemantics();
    try {
      tester.semantics.tap(find.semantics.byLabel('Workout trend chart'));
      await tester.pump();
      await tester.tapAt(
        tester.getCenter(find.byKey(const ValueKey('progress-chart-canvas'))),
      );
      await tester.pump();
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('progress-selected-point-value')),
            )
            .data,
        contains('workout'),
      );
      await selectRange(
        tester,
        controlKey: 'progress-tonos-range',
        label: '1M',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('progress-selected-point-value')),
            )
            .data,
        contains('Tap a chart point'),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('standard Material selector uses more vertical space', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPrototype(tester);
    final current = tester.getSize(
      find.byKey(const ValueKey('progress-tonos-range')),
    );
    final material = tester.getSize(
      find.byKey(const ValueKey('progress-standard-material-range')),
    );
    expect(current.height, lessThanOrEqualTo(48));
    expect(material.height, lessThanOrEqualTo(48));
  });

  testWidgets('reduced motion is immediate and 320 dp at 2x remains usable', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPrototype(tester, reducedMotion: true);
    final currentOption = find.byKey(
      const ValueKey('progress-tonos-range-oneWeek'),
    );
    final animation = find.descendant(
      of: currentOption,
      matching: find.byType(AnimatedContainer),
    );
    expect(
      tester.widget<AnimatedContainer>(animation.first).duration,
      Duration.zero,
    );

    await pumpPrototype(tester, width: 320, textScale: 2);
    for (final controlKey in [
      'progress-tonos-range',
      'progress-standard-material-range',
    ]) {
      final control = find.byKey(ValueKey(controlKey));
      for (final label in ['1W', '1M', '3M', '6M', '1Y', 'All']) {
        expect(
          find.descendant(of: control, matching: find.text(label)),
          findsWidgets,
        );
      }
      expect(tester.getSize(control).width, lessThanOrEqualTo(320));
    }
    expect(tester.takeException(), isNull);
  });
}
