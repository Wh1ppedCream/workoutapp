import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';

enum _Control { checkbox, radio, toggle }

ToggleablePainter _painter(WidgetTester tester, Finder control) {
  final paint = find.descendant(
    of: control,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is ToggleablePainter,
    ),
  );
  expect(paint, findsOneWidget);
  return tester.widget<CustomPaint>(paint).painter! as ToggleablePainter;
}

void main() {
  for (final brightness in Brightness.values) {
    for (final kind in _Control.values) {
      for (final selected in [false, true]) {
        for (final enabled in [false, true]) {
          testWidgets('$brightness $kind selected=$selected enabled=$enabled', (
            tester,
          ) async {
            final theme =
                brightness == Brightness.dark
                    ? AppThemeFactory.dark(AppThemeFamily.neoBrutalism)
                    : AppThemeFactory.light(AppThemeFamily.neoBrutalism);
            final semantics = tester.ensureSemantics();
            try {
              final focus = FocusNode();
              addTearDown(focus.dispose);
              final highlightStrategy = FocusManager.instance.highlightStrategy;
              FocusManager.instance.highlightStrategy =
                  FocusHighlightStrategy.alwaysTraditional;
              addTearDown(() {
                FocusManager.instance.highlightStrategy = highlightStrategy;
              });
              const controlKey = ValueKey('control');
              var value = selected;
              var activations = 0;

              await tester.pumpWidget(
                MaterialApp(
                  theme: theme,
                  home: Scaffold(
                    body: Center(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          void update(bool next) {
                            activations++;
                            setState(() => value = next);
                          }

                          return switch (kind) {
                            _Control.checkbox => Checkbox(
                              key: controlKey,
                              value: value,
                              focusNode: focus,
                              onChanged:
                                  enabled ? (next) => update(next!) : null,
                            ),
                            _Control.radio => Radio<bool>(
                              key: controlKey,
                              value: true,
                              groupValue: value,
                              focusNode: focus,
                              onChanged:
                                  enabled ? (next) => update(next!) : null,
                            ),
                            _Control.toggle => Switch(
                              key: controlKey,
                              value: value,
                              focusNode: focus,
                              onChanged: enabled ? update : null,
                            ),
                          };
                        },
                      ),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final control = find.byKey(controlKey);
              final painter = _painter(tester, control);
              final active =
                  kind == _Control.radio
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary;
              final inactive = switch (kind) {
                _Control.checkbox => Colors.transparent,
                _Control.radio => theme.colorScheme.onSurface,
                _Control.toggle =>
                  brightness == Brightness.dark
                      ? const Color(0xFFD8CFBE)
                      : theme.colorScheme.surfaceContainer,
              };
              expect(painter.activeColor, active);
              expect(painter.inactiveColor, inactive);
              expect(painter.position.value, selected ? 1 : 0);
              expect(
                tester.getSemantics(control).hasFlag(SemanticsFlag.isEnabled),
                enabled,
              );
              final selectionFlag =
                  kind == _Control.toggle
                      ? SemanticsFlag.isToggled
                      : SemanticsFlag.isChecked;
              expect(
                tester.getSemantics(control).hasFlag(selectionFlag),
                selected,
              );

              focus.requestFocus();
              await tester.pumpAndSettle();
              expect(_painter(tester, control).isFocused, enabled);
              expect(_painter(tester, control).activeColor, active);
              expect(_painter(tester, control).inactiveColor, inactive);
              if (enabled) {
                expect(focus.hasFocus, isTrue);
                expect(
                  _painter(tester, control).reactionFocusFade.value,
                  greaterThan(0),
                );
                await tester.sendKeyEvent(LogicalKeyboardKey.space);
              } else {
                await tester.tap(control);
              }
              await tester.pumpAndSettle();
              final shouldActivate =
                  enabled && (kind != _Control.radio || !selected);
              expect(activations, shouldActivate ? 1 : 0);
              expect(value, shouldActivate ? !selected : selected);
              expect(
                tester.getSemantics(control).hasFlag(selectionFlag),
                value,
              );
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          });
        }
      }
    }
  }
}
