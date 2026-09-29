import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_exercise_expansion.dart';

Widget _testApp(Widget child) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Finder _setCheckbox(String prefix, int number) => find.descendant(
  of: find.byKey(ValueKey('exercise-expansion-$prefix-set-$number')),
  matching: find.byType(Checkbox),
);

void main() {
  testWidgets('both variants preserve the same exercise and set content', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const ExerciseExpansionPrototype()));

    expect(find.text('Arnold Press'), findsNWidgets(2));
    expect(find.text('Set 1'), findsNWidgets(2));
    expect(find.text('Set 2'), findsNWidgets(2));
    expect(find.text('Add Set'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('exercise-expansion-current-animation')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('exercise-expansion-animated-animation')),
      findsOneWidget,
    );
  });

  testWidgets(
    'current disclosure is immediate and standard candidate animates',
    (tester) async {
      await tester.pumpWidget(_testApp(const ExerciseExpansionPrototype()));

      await tester.tap(
        find.byKey(const ValueKey('exercise-expansion-current-toggle')),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('exercise-expansion-current-sets')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('exercise-expansion-animated-toggle')),
      );
      await tester.pump();
      expect(
        tester
            .widget<AnimatedSize>(
              find.byKey(
                const ValueKey('exercise-expansion-animated-animation'),
              ),
            )
            .duration,
        const Duration(milliseconds: 180),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('exercise-expansion-animated-sets')),
        findsNothing,
      );
    },
  );

  testWidgets('both variants auto-collapse when the final set is checked', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const ExerciseExpansionPrototype()));

    await tester.tap(_setCheckbox('current', 2));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('exercise-expansion-current-sets')),
      findsNothing,
    );

    await tester.tap(_setCheckbox('animated', 2));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('exercise-expansion-animated-sets')),
      findsNothing,
    );
  });

  testWidgets('reduced motion makes the standard transition immediate', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const ExerciseExpansionPrototype(),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('exercise-expansion-animated-animation')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const ValueKey('exercise-expansion-animated-toggle')),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('exercise-expansion-animated-sets')),
      findsNothing,
    );
  });

  testWidgets('standard transition remains usable at a phone width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: const ExerciseExpansionPrototype(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('exercise-expansion-animated-toggle')),
          )
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
  });
}
