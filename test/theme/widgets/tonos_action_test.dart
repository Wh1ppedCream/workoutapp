import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/widgets/tonos_action.dart';

const _testSemanticColors = AppSemanticColors(
  positive: Color(0xFF008000),
  onPositive: Color(0xFFFFFFFF),
  warning: Color(0xFFFFA000),
  databaseHealthy: Color(0xFF008800),
  databaseWarning: Color(0xFFFF8800),
  onWarning: Color(0xFF000000),
  negative: Color(0xFFB00020),
  onNegative: Color(0xFFFFFFFF),
  info: Color(0xFF0066CC),
  onInfo: Color(0xFFFFFFFF),
  strongContent: Color(0xFF111111),
  mutedContent: Color(0xFF666666),
  measurementContainer: Color(0xFFE0F2F1),
  onMeasurementContainer: Color(0xFF00695C),
  nutritionContainer: Color(0xFFFFE0B2),
  onNutritionContainer: Color(0xFFEF6C00),
  workoutContainer: Color(0xFFC8E6C9),
  onWorkoutContainer: Color(0xFF2E7D32),
  primaryAction: Color(0xFF6200EE),
  onPrimaryAction: Color(0xFFFFFFFF),
  automaticPlanBadge: Color(0xFF4EDA41),
  onAutomaticPlanBadge: Color(0xFFFFFFFF),
  workoutAction: Color(0xFF4CAF50),
  onWorkoutAction: Color(0xFFFFFFFF),
  startWorkoutAction: Color(0xFF388E3C),
  onStartWorkoutAction: Color(0xFFFFFFFF),
  completionAccent: Color(0xFF7CFF8B),
  drawerHeaderForeground: Color(0xFFFFFFFF),
  ongoingSessionAction: Color(0xFF008800),
  ongoingSessionExit: Color(0xFFCC0000),
  focusRing: Color(0xFF6200EE),
  disabledContent: Color(0x61000000),
  disabledContainer: Color(0x1F000000),
);

void main() {
  testWidgets('maps variants to standard Material button families', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Column(
          children: [
            TonosAction(label: 'Primary', onPressed: _noop),
            TonosAction(
              label: 'Tonal',
              variant: TonosActionVariant.tonal,
              onPressed: _noop,
            ),
            TonosAction(
              label: 'Outlined',
              variant: TonosActionVariant.outlined,
              onPressed: _noop,
            ),
            TonosAction(
              label: 'Destructive',
              variant: TonosActionVariant.destructive,
              onPressed: _noop,
            ),
            TonosAction(
              label: 'Text',
              variant: TonosActionVariant.text,
              onPressed: _noop,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNWidgets(3));
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('uses semantic negative roles for destructive actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Column(
          children: [
            TonosAction(
              key: ValueKey('destructive'),
              label: 'Delete',
              variant: TonosActionVariant.destructive,
              onPressed: _noop,
            ),
            TonosAction(
              key: ValueKey('disabled-destructive'),
              label: 'Delete disabled',
              variant: TonosActionVariant.destructive,
              onPressed: null,
            ),
          ],
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('destructive')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(
      button.style?.backgroundColor?.resolve({}),
      _testSemanticColors.negative,
    );
    expect(
      button.style?.foregroundColor?.resolve({}),
      _testSemanticColors.onNegative,
    );

    final disabledButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('disabled-destructive')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(
      disabledButton.style?.backgroundColor?.resolve({WidgetState.disabled}),
      _testSemanticColors.disabledContainer,
    );
    expect(
      disabledButton.style?.foregroundColor?.resolve({WidgetState.disabled}),
      _testSemanticColors.disabledContent,
    );
  });

  testWidgets('preserves callbacks, expansion, tooltip, and semantics', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(
        TonosAction(
          label: 'Save',
          onPressed: () => taps++,
          expand: true,
          tooltip: 'Save changes',
          semanticLabel: 'Save workout changes',
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    expect(taps, 1);
    expect(tester.getSize(find.byType(FilledButton)).width, 320);
    expect(find.byTooltip('Save changes'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Save workout changes',
      ),
      findsOneWidget,
    );
  });
}

void _noop() {}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      extensions: const <ThemeExtension<dynamic>>[_testSemanticColors],
    ),
    home: Scaffold(body: SizedBox(width: 320, child: child)),
  );
}
