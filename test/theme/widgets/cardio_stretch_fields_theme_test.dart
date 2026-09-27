import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/theme/widgets/tonos_theme_ready.dart';
import 'package:env_test/widgets/cardio_card.dart';
import 'package:env_test/widgets/stretch_card.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode cardio fields preserve field contracts', (
        tester,
      ) async {
        final exercise = CardioExercise(
          name: 'Treadmill walk',
          equipment: 'Treadmill',
          plannedMinutes: 30,
          cardioNote: 'Steady pace',
        );
        var changes = 0;

        await tester.pumpWidget(
          _host(
            theme,
            CardioCard(exercise: exercise, onValueChanged: () => changes++),
          ),
        );

        final context = tester.element(find.byType(CardioCard));
        final usesNeoRoles = family == AppThemeFamily.neoBrutalism;
        expect(
          tester.widget<Text>(find.text('Treadmill walk')).style,
          Theme.of(context).textTheme.titleMedium,
        );
        expect(
          tester.widget<Text>(find.text('Steady pace')).style,
          Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        );
        expect(
          tester.widget<Text>(find.text('30:00')).style,
          Theme.of(context).textTheme.headlineMedium,
        );
        _expectThemeReadyCard(tester, usesNeo: usesNeoRoles);
        expect(
          _buttonColor(tester, 'Start'),
          usesNeoRoles ? context.semanticColors.positive : Colors.green,
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Start'));
        await tester.pump();
        expect(
          _buttonColor(tester, 'Stop'),
          usesNeoRoles ? context.semanticColors.negative : Colors.red,
        );

        expect(find.byType(TonosFormField), findsOneWidget);
        var formFields = tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        );
        var fields = tester.widgetList<TextField>(find.byType(TextField));
        expect(formFields, hasLength(1));
        expect(formFields.single.initialValue, '30');
        expect(fields.single.readOnly, isFalse);
        expect(fields.single.keyboardType, TextInputType.number);
        expect(fields.single.decoration?.labelText, 'Minutes');
        expect(fields.single.decoration?.isDense, isFalse);

        await tester.enterText(find.byType(TextFormField), '25');
        await tester.pump();
        expect(exercise.plannedMinutes, 25);
        expect(changes, greaterThan(0));

        await tester.tap(find.text('Steady pace'));
        await tester.pump();
        expect(find.byType(TonosFormField), findsNWidgets(2));
        formFields = tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        );
        fields = tester.widgetList<TextField>(find.byType(TextField));
        expect(formFields, hasLength(2));
        expect(formFields.first.initialValue, 'Steady pace');
        final noteField = fields.first;
        expect(noteField.decoration?.labelText, 'Note');
        expect(noteField.decoration?.isDense, isTrue);

        await tester.enterText(find.byType(TextFormField).first, 'Easy pace');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(exercise.cardioNote, 'Easy pace');
        expect(find.byType(TonosFormField), findsOneWidget);

        await tester.pumpWidget(
          _host(theme, CardioCard(exercise: exercise, readOnlyMode: true)),
        );
        expect(
          tester.widget<Text>(find.text('Easy pace')).style,
          Theme.of(
            tester.element(find.byType(CardioCard)),
          ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        );

        final replacementExercise = CardioExercise(
          name: 'Treadmill walk',
          equipment: 'Treadmill',
          plannedMinutes: 45,
        );
        await tester.pumpWidget(
          _host(theme, CardioCard(exercise: replacementExercise)),
        );
        expect(
          tester.widget<TextFormField>(find.byType(TextFormField)).initialValue,
          '45',
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          '45',
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode stretch text retains inherited typography', (
        tester,
      ) async {
        final exercise = StretchExercise(
          name: 'Mobility',
          equipment: 'Mat',
          stretchInstances: [
            StretchInstance(
              stretchId: 1,
              isCustom: false,
              customName: 'Hip flexor stretch',
              customDesc: 'Hold for 20 seconds.',
              isChecked: false,
              orderIndex: 0,
            ),
          ],
        );

        await tester.pumpWidget(_host(theme, StretchCard(exercise: exercise)));

        final context = tester.element(find.byType(StretchCard));
        expect(
          tester.widget<Text>(find.text('Hip flexor stretch')).style,
          Theme.of(context).textTheme.bodyLarge,
        );
        expect(
          tester.widget<Text>(find.text('Hold for 20 seconds.')).style,
          Theme.of(context).textTheme.bodySmall,
        );
        _expectThemeReadyCard(
          tester,
          usesNeo: family == AppThemeFamily.neoBrutalism,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode stretch custom field preserves edit behavior', (
        tester,
      ) async {
        final exercise = StretchExercise(name: 'Mobility', equipment: 'Mat');
        var changes = 0;

        await tester.pumpWidget(
          _host(
            theme,
            StretchCard(exercise: exercise, onValueChanged: () => changes++),
          ),
        );

        final context = tester.element(find.byType(StretchCard));
        final addButtonFinder = find.ancestor(
          of: find.byIcon(Icons.add_circle_outline),
          matching: find.byType(IconButton),
        );
        expect(
          tester.widget<IconButton>(addButtonFinder).color,
          family == AppThemeFamily.neoBrutalism
              ? context.semanticColors.info
              : Colors.blue,
        );
        expect(find.byType(TonosFormField), findsOneWidget);
        final formField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        var field = tester.widget<TextField>(find.byType(TextField));
        expect(formField.controller, isNotNull);
        expect(field.readOnly, isFalse);
        expect(field.decoration?.hintText, 'Custom');
        expect(field.decoration?.isDense, isTrue);

        await tester.enterText(find.byType(TextFormField), 'Hamstring hold');
        await tester.pump();
        expect(changes, 0);
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
        expect(exercise.stretchInstances, hasLength(1));
        expect(exercise.stretchInstances.single.customName, 'Hamstring hold');
        expect(changes, 1);

        await tester.pumpWidget(
          _host(theme, StretchCard(exercise: exercise, readOnlyMode: true)),
        );
        field = tester.widget<TextField>(find.byType(TextField));
        expect(field.readOnly, isTrue);
        expect(
          tester
              .widget<IconButton>(
                find.ancestor(
                  of: find.byIcon(Icons.add_circle_outline),
                  matching: find.byType(IconButton),
                ),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Color? _buttonColor(WidgetTester tester, String label) {
  final button = tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, label),
  );
  return button.style?.backgroundColor?.resolve({});
}

void _expectThemeReadyCard(WidgetTester tester, {required bool usesNeo}) {
  expect(find.byType(TonosThemeReadyCard), findsOneWidget);
  expect(find.byType(TonosSurface), usesNeo ? findsOneWidget : findsNothing);
  expect(find.byType(Card), usesNeo ? findsNothing : findsOneWidget);
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
