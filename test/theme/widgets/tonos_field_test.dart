import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('preserves URL and multiline field configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const TonosField(
          keyboardType: TextInputType.url,
          labelText: 'Manifest URL',
          hintText: 'https://example.test/manifest.json',
          minLines: 1,
          maxLines: 3,
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.url);
    expect(field.minLines, 1);
    expect(field.maxLines, 3);
    expect(field.decoration?.labelText, 'Manifest URL');
    expect(field.decoration?.hintText, 'https://example.test/manifest.json');
    expect(field.decoration?.border, isNull);
  });

  testWidgets('preserves explicit multiline outline configuration', (
    tester,
  ) async {
    final controller = TextEditingController(text: '{"version": 1}');
    await tester.pumpWidget(
      _testApp(
        TonosField(
          controller: controller,
          maxLines: 10,
          border: const OutlineInputBorder(),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller, same(controller));
    expect(field.maxLines, 10);
    expect(field.decoration?.border, isA<OutlineInputBorder>());
    expect(controller.text, '{"version": 1}');
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('obscured fields ignore multiline configuration', (tester) async {
    await tester.pumpWidget(
      _testApp(const TonosField(obscureText: true, minLines: 2, maxLines: 4)),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(field.minLines, isNull);
    expect(field.maxLines, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form fields preserve validation, formatting, and saving', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    String? savedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TonosFormField(
              controller: controller,
              labelText: 'Amount',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
              onSaved: (value) => savedValue = value,
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.enterText(find.byType(TextFormField), '12a3');
    expect(controller.text, '123');
    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();

    final formField = tester.widget<TextFormField>(find.byType(TextFormField));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(savedValue, '123');
    expect(formField.controller, same(controller));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(field.textInputAction, TextInputAction.next);
    expect(field.decoration?.isDense, isTrue);
    expect(
      field.decoration?.contentPadding,
      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    );
    expect(field.textAlign, TextAlign.center);
    expect(field.decoration?.border, isA<OutlineInputBorder>());
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
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
