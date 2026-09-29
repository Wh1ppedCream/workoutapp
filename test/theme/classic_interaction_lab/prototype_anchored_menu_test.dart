import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_anchored_menu.dart';

Widget _testApp(Widget child, {double textScale = 1}) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Center(child: child),
    ),
  ),
);

Future<void> _select(TWidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

typedef TWidgetTester = WidgetTester;

void main() {
  testWidgets('both menus retain Tonos action names and order', (tester) async {
    await tester.pumpWidget(_testApp(const AnchoredMenuPrototype()));

    expect(find.text('Swap Exercise'), findsNothing);
    await tester.tap(find.byKey(const Key('tonos-popup-anchor')));
    await tester.pumpAndSettle();
    expect(find.text('Swap Exercise'), findsOneWidget);
    expect(find.text('Remove Exercise'), findsOneWidget);
    expect(find.text('Make ChangeSet'), findsOneWidget);

    await tester.tap(find.text('Swap Exercise'));
    await tester.pumpAndSettle();
    await _select(tester, 'MenuAnchor');
    await tester.tap(find.byKey(const Key('material-anchor-button')));
    await tester.pumpAndSettle();
    expect(find.text('Swap Exercise'), findsOneWidget);
    expect(find.text('Remove Exercise'), findsOneWidget);
    expect(find.text('Make ChangeSet'), findsOneWidget);
  });

  testWidgets('MenuAnchor records a local choice without changing app data', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const AnchoredMenuPrototype()));
    await _select(tester, 'MenuAnchor');
    await tester.tap(find.byKey(const Key('material-anchor-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('material-menu-remove')));
    await tester.pumpAndSettle();

    expect(find.text('Last local choice: Remove Exercise'), findsOneWidget);
    expect(find.text('Bench Press - Barbell'), findsOneWidget);
  });

  testWidgets('standard menu anchor is labelled and toggles its menu', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const AnchoredMenuPrototype()));
    await _select(tester, 'MenuAnchor');
    final anchor = find.byKey(const Key('material-anchor-button'));
    expect(tester.widget<IconButton>(anchor).tooltip, 'Exercise actions');
    await tester.tap(anchor);
    await tester.pumpAndSettle();
    expect(find.text('Swap Exercise'), findsOneWidget);

    await tester.tap(anchor);
    await tester.pumpAndSettle();
    expect(find.text('Swap Exercise'), findsNothing);
  });

  testWidgets('standard Material menu opens and selects from the keyboard', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final itemFocusNode = FocusNode();
    addTearDown(focusNode.dispose);
    addTearDown(itemFocusNode.dispose);
    await tester.pumpWidget(
      _testApp(
        AnchoredMenuPrototype(
          materialFocusNode: focusNode,
          materialMenuItemFocusNode: itemFocusNode,
        ),
      ),
    );
    await _select(tester, 'MenuAnchor');
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Swap Exercise'), findsOneWidget);
    itemFocusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Last local choice: Swap Exercise'), findsOneWidget);
  });

  testWidgets('both menu variants fit a narrow layout at 2x text', (
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
                child: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: const AnchoredMenuPrototype(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('tonos-popup-anchor')), findsOneWidget);
    await tester.ensureVisible(find.text('MenuAnchor'));
    await _select(tester, 'MenuAnchor');
    expect(find.byKey(const Key('material-anchor-button')), findsOneWidget);
  });
}
