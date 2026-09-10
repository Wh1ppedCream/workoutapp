import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';

void main() {
  testWidgets('maps the search recipe to a themed text field', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const TonosField(
          variant: TonosFieldVariant.search,
          labelText: 'Search exercises',
          hintText: 'Barbell squat',
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Search exercises'), findsOneWidget);
    expect(find.text('Barbell squat'), findsOneWidget);
  });

  testWidgets('preserves text callbacks and semantic labeling', (tester) async {
    String? value;
    await tester.pumpWidget(
      _testApp(
        TonosField(
          labelText: 'Exercise name',
          semanticLabel: 'Exercise name field',
          onChanged: (next) => value = next,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Deadlift');
    expect(value, 'Deadlift');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Exercise name field',
      ),
      findsOneWidget,
    );
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}
