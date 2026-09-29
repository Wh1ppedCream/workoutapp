import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_primary_action.dart';
import 'package:env_test/theme/widgets/tonos_action.dart';

Widget _testApp(Widget child) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('Tonos and standard buttons keep matching primary sizing', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const PrimaryActionPrototype()));

    final tonos = tester.getSize(
      find.byKey(const ValueKey('primary-action-baseline')),
    );
    final material = tester.getSize(
      find.byKey(const ValueKey('primary-action-material')),
    );
    expect(tonos.height, 48);
    expect(material.height, 48);
    expect(
      Theme.of(tester.element(find.byType(PrimaryActionPrototype)))
          .colorScheme
          .primary,
      isNot(Color(0x00000000)),
    );
  });

  testWidgets('each button invokes only its own local action', (tester) async {
    await tester.pumpWidget(_testApp(const PrimaryActionPrototype()));

    await tester.tap(find.byKey(const ValueKey('primary-action-baseline')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('primary-action-material')));
    await tester.pump();

    expect(find.text('Invoked 1 times'), findsNWidgets(2));
  });

  testWidgets('disabled state is exposed by both controls', (tester) async {
    await tester.pumpWidget(
      _testApp(const PrimaryActionPrototype(enabled: false)),
    );

    final tonos = tester.widget<TonosAction>(
      find.byKey(const ValueKey('primary-action-baseline')),
    );
    final material = tester.widget<FilledButton>(
      find.byKey(const ValueKey('primary-action-material')),
    );
    expect(tonos.onPressed, isNull);
    expect(material.onPressed, isNull);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('primary-action-material')))
          .flagsCollection
          .isEnabled,
      Tristate.isFalse,
    );
  });

  testWidgets('standard Material candidate responds to keyboard activation', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _testApp(PrimaryActionPrototype(materialFocusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(find.text('Invoked 1 times'), findsOneWidget);
  });
}
