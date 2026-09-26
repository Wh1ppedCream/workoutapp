import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/tonos_train_tabs.dart';

void main() {
  testWidgets('Neo Overview/Plans segments expose selected semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      var selectedIndex = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
          home: Scaffold(
            body: TonosTrainTabs(
              overviewLabel: 'Overview',
              plansLabel: 'Plans',
              selectedIndex: selectedIndex,
              onChanged: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      final overviewSemantics = find.bySemanticsLabel('Overview');
      final plansSemantics = find.bySemanticsLabel('Plans');
      expect(
        tester
            .getSemantics(overviewSemantics)
            .hasFlag(SemanticsFlag.isSelected),
        isTrue,
      );
      expect(
        tester.getSemantics(plansSemantics).hasFlag(SemanticsFlag.isSelected),
        isFalse,
      );

      await tester.tap(find.text('Plans'));
      await tester.pump();
      expect(selectedIndex, 1);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('Neo tabs keep their outline and shadow inside the AppBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
        home: Scaffold(
          appBar: AppBar(
            title: TonosTrainTabs(
              overviewLabel: 'Overview',
              plansLabel: 'Plans',
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(TonosTrainTabs)).height,
      TonosTrainTabs.preferredHeight(
        tester.element(find.byType(TonosTrainTabs)),
      ),
    );
    expect(tester.getSize(find.byType(TonosTrainTabs)).height, 48);
    final frame = tester.widget<Container>(
      find.byKey(const ValueKey('tonos-train-tabs-frame')),
    );
    final decoration = frame.decoration! as BoxDecoration;
    expect(decoration.border!.top.width, 2);
    expect(decoration.boxShadow!.single.offset, const Offset(3, 3));
    expect(tester.takeException(), isNull);
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.name} ${brightness.name} Train tabs resolve theme-owned shapes',
        (tester) async {
          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: TonosTrainTabs(
                  overviewLabel: 'Overview',
                  plansLabel: 'Plans',
                  selectedIndex: 1,
                  onChanged: (_) {},
                ),
              ),
            ),
          );

          final context = tester.element(find.byType(TonosTrainTabs));
          final shapes = context.shapeTokens;
          final surfaces = context.surfaceTokens;
          final effects = context.effectTokens;
          final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
          if (usesInkRecipe) {
            expect(shapes.trainTabButton, BorderRadius.circular(3));
          }
          final frame = tester.widget<Container>(
            find.byKey(const ValueKey('tonos-train-tabs-frame')),
          );
          final decoration = frame.decoration! as BoxDecoration;
          expect(
            decoration.color,
            usesInkRecipe
                ? context.cs.secondaryContainer
                : surfaces.panelRaised.withValues(
                  alpha: surfaces.trainTabSurfaceOpacity,
                ),
          );
          expect(
            decoration.borderRadius,
            usesInkRecipe ? shapes.trainTab : shapes.pill,
          );

          if (usesInkRecipe) {
            expect(decoration.border!.top.width, shapes.outlineWidth);
            expect(decoration.border!.top.color, surfaces.subtleOutline);
            final shadows = decoration.boxShadow;
            expect(shadows, hasLength(1));
            final visibleShadow = shadows!.single;
            expect(visibleShadow.color, effects.cardShadow);
            expect(visibleShadow.offset, effects.cardShadowOffset);
            expect(visibleShadow.blurRadius, effects.cardShadowBlur);
          } else {
            expect(decoration.border, isNull);
            expect(decoration.boxShadow, isNull);
          }

          final buttons =
              tester
                  .widgetList<Material>(
                    find.descendant(
                      of: find.byType(TonosTrainTabs),
                      matching: find.byType(Material),
                    ),
                  )
                  .toList();
          expect(buttons, hasLength(2));
          for (var index = 0; index < buttons.length; index++) {
            final isSelected = index == 1;
            final shape = buttons[index].shape! as RoundedRectangleBorder;
            expect(
              shape.borderRadius,
              usesInkRecipe ? shapes.trainTabButton : shapes.pill,
            );
            expect(
              shape.side.style,
              usesInkRecipe ? BorderStyle.solid : BorderStyle.none,
            );
            expect(shape.side.width, usesInkRecipe ? shapes.outlineWidth : 0);
            expect(
              buttons[index].color,
              isSelected
                  ? context.cs.primaryContainer
                  : usesInkRecipe
                  ? context.cs.secondaryContainer
                  : Colors.transparent,
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
