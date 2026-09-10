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
}

void _noop() {}
