import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_set_completion.dart';

Widget _testApp(Widget child, {double textScale = 1}) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  home: Scaffold(
    body: SingleChildScrollView(
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Center(child: child),
      ),
    ),
  ),
);

void main() {
  testWidgets('both set rows retain the same data and completion semantics', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const SetCompletionPrototype()));

    expect(find.text('Set 1'), findsNWidgets(2));
    expect(find.text('Weight (lbs)'), findsNWidgets(2));
    expect(find.text('Reps'), findsNWidgets(2));
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('set-completion-material-checkbox')),
          )
          .label,
      'Material set 1',
    );
  });

  testWidgets('both checkboxes toggle independently', (tester) async {
    await tester.pumpWidget(_testApp(const SetCompletionPrototype()));

    await tester.tap(
      find.byKey(const ValueKey('set-completion-baseline-checkbox')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('set-completion-material-checkbox')),
    );
    await tester.pump();

    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('set-completion-baseline-checkbox')),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('set-completion-material-checkbox')),
          )
          .value,
      isTrue,
    );
  });

  testWidgets(
    'standard checkbox provides the larger target without losing density',
    (tester) async {
      await tester.pumpWidget(_testApp(const SetCompletionPrototype()));

      final compact = tester.getSize(
        find.byKey(const ValueKey('set-completion-baseline-checkbox')),
      );
      final standard = tester.getSize(
        find.byKey(const ValueKey('set-completion-material-checkbox')),
      );
      final compactRow = tester.getSize(
        find.byKey(const ValueKey('set-completion-baseline-row-layout')),
      );
      final standardRow = tester.getSize(
        find.byKey(const ValueKey('set-completion-candidate-row-layout')),
      );

      expect(standard, const Size(48, 48));
      expect(compact.height, lessThan(standard.height));
      expect(standardRow.height - compactRow.height, lessThanOrEqualTo(8));
    },
  );

  testWidgets('larger text keeps labels and both rows readable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const SetCompletionPrototype(), textScale: 2),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Weight (lbs)'), findsNWidgets(2));
    expect(find.text('Reps'), findsNWidgets(2));
  });
}
