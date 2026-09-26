import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/widgets/tonos_segmented_action_bar.dart';

void main() {
  testWidgets('uses the active shape recipe and preserves action semantics', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: TonosSegmentedActionBar(
              items: [
                TonosActionBarItem(
                  label: 'Measure',
                  semanticLabel: 'Record a measurement',
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  onPressed: () => taps++,
                ),
                const TonosActionBarItem(
                  label: 'Workout',
                  semanticLabel: 'Start a workout',
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.borderRadius, AppShapeTokens.classic.actionBar);
    expect(clip.child, isA<Row>());
    final context = tester.element(find.byType(TonosSegmentedActionBar));
    final divider = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints ==
                const BoxConstraints.tightFor(width: 1, height: 40),
      ),
    );
    expect(
      divider.color,
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Record a measurement',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Measure'));
    expect(taps, 1);
  });

  testWidgets('allows a caller to preserve label and divider roles', (
    tester,
  ) async {
    const labelStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.7,
    );
    const foreground = Color(0xFF111111);
    const dividerColor = Color(0xFF456789);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TonosSegmentedActionBar(
            dividerColor: dividerColor,
            items: const [
              TonosActionBarItem(
                label: 'Meal',
                semanticLabel: 'Add a meal',
                backgroundColor: Colors.white,
                foregroundColor: foreground,
                labelStyle: labelStyle,
                onPressed: _noop,
              ),
              TonosActionBarItem(
                label: 'Plan',
                semanticLabel: 'Plan a meal',
                backgroundColor: Colors.white,
                foregroundColor: foreground,
                labelStyle: labelStyle,
                onPressed: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Meal'));
    expect(text.style?.fontSize, labelStyle.fontSize);
    expect(text.style?.fontWeight, labelStyle.fontWeight);
    expect(text.style?.letterSpacing, labelStyle.letterSpacing);
    expect(text.style?.color, foreground);
    final divider = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints ==
                const BoxConstraints.tightFor(width: 1, height: 40),
      ),
    );
    expect(divider.color, dividerColor);
  });

  testWidgets('stacks segments when accessibility text needs more room', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: TonosSegmentedActionBar(
                items: [
                  _item('Pantry Log'),
                  _item('Add Meal', onPressed: () => taps++),
                  _item('Plan Meal'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.child, isA<Column>());
    expect(find.text('Pantry Log'), findsOneWidget);
    expect(find.text('Add Meal'), findsOneWidget);
    expect(find.text('Plan Meal'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Pantry Log')).dy,
      lessThan(tester.getCenter(find.text('Add Meal')).dy),
    );
    expect(
      tester.getCenter(find.text('Add Meal')).dy,
      lessThan(tester.getCenter(find.text('Plan Meal')).dy),
    );
    await tester.tap(find.text('Add Meal'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks segments when the available width cannot fit labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            child: TonosSegmentedActionBar(
              items: [
                _item('Pantry Log'),
                _item('Add Meal'),
                _item('Plan Meal'),
              ],
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.child, isA<Column>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses finite stacked width inside a horizontal scroll view', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TonosSegmentedActionBar(
              items: [
                _item('Pantry Log'),
                _item('Add Meal'),
                _item('Plan Meal'),
              ],
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    final size = tester.getSize(find.byType(ClipRRect));
    expect(clip.child, isA<Column>());
    expect(size.width.isFinite, isTrue);
    expect(size.width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a row when scaled labels still fit', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: TonosSegmentedActionBar(
                items: [_item('A'), _item('B'), _item('C')],
              ),
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.child, isA<Row>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks labels that exceed the compact segment height', (
    tester,
  ) async {
    const tallLabel = TextStyle(fontSize: 48);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: TonosSegmentedActionBar(
              items: [
                _item('A', labelStyle: tallLabel),
                _item('B', labelStyle: tallLabel),
                _item('C', labelStyle: tallLabel),
              ],
            ),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(TonosSegmentedActionBar),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.child, isA<Column>());
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

TonosActionBarItem _item(
  String label, {
  VoidCallback? onPressed,
  TextStyle? labelStyle,
}) {
  return TonosActionBarItem(
    label: label,
    semanticLabel: label,
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    onPressed: onPressed ?? _noop,
    labelStyle: labelStyle,
  );
}
