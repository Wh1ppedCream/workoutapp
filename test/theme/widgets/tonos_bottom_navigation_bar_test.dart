import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/tonos_bottom_navigation_bar.dart';

void main() {
  const items = [
    BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Train'),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logbook'),
  ];

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.name} ${brightness.name} navigation exposes selection semantics',
        (tester) async {
          final semanticsHandle = tester.ensureSemantics();
          try {
            final theme =
                brightness == Brightness.light
                    ? AppThemeFactory.light(family)
                    : AppThemeFactory.dark(family);
            await tester.pumpWidget(
              MaterialApp(
                theme: theme,
                home: Scaffold(
                  bottomNavigationBar: TonosBottomNavigationBar(
                    items: items,
                    currentIndex: 0,
                    onTap: (_) {},
                  ),
                ),
              ),
            );

            final train =
                tester
                    .getSemantics(find.bySemanticsLabel(RegExp(r'^Train')))
                    .getSemanticsData();
            final catalog =
                tester
                    .getSemantics(find.bySemanticsLabel(RegExp(r'^Catalog')))
                    .getSemanticsData();
            expect(train.hasAction(SemanticsAction.tap), isTrue);
            expect(train.hasFlag(SemanticsFlag.isSelected), isTrue);
            expect(catalog.hasAction(SemanticsAction.tap), isTrue);
            expect(catalog.hasFlag(SemanticsFlag.isSelected), isFalse);
          } finally {
            semanticsHandle.dispose();
          }
        },
      );
    }
  }

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.name} ${brightness.name} navigation preserves its theme owner',
        (tester) async {
          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          var selectedIndex = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                bottomNavigationBar: TonosBottomNavigationBar(
                  items: items,
                  currentIndex: selectedIndex,
                  onTap: (index) => selectedIndex = index,
                ),
              ),
            ),
          );

          final context = tester.element(find.byType(TonosBottomNavigationBar));
          final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
          final navigation = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(navigation.currentIndex, 0);

          if (!usesInkRecipe) {
            expect(
              find.byKey(const ValueKey('tonos-bottom-navigation-frame')),
              findsNothing,
            );
          } else {
            final frame = tester.widget<DecoratedBox>(
              find.byKey(const ValueKey('tonos-bottom-navigation-frame')),
            );
            final decoration = frame.decoration as BoxDecoration;
            final effects = context.effectTokens;
            final shapes = context.shapeTokens;
            final expectedBackground =
                Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                context.cs.primaryContainer;
            expect(decoration.color, expectedBackground);
            expect(decoration.border, isNotNull);
            expect(decoration.border!.top.width, shapes.outlineWidth);
            expect(decoration.borderRadius, shapes.trainTab);
            expect(navigation.backgroundColor, Colors.transparent);
            expect(navigation.elevation, 0);
            expect(
              navigation.selectedItemColor,
              context.cs.onSecondaryContainer,
            );
            expect(
              navigation.unselectedItemColor,
              context.cs.onPrimaryContainer,
            );
            expect(
              navigation.selectedIconTheme?.color,
              context.cs.onSecondaryContainer,
            );
            expect(
              navigation.unselectedIconTheme?.color,
              context.cs.onPrimaryContainer,
            );
            final shadows = decoration.boxShadow;
            final hasVisibleShadow =
                effects.cardShadow.a != 0 &&
                (effects.cardShadowBlur > 0 ||
                    effects.cardShadowOffset != Offset.zero);
            if (!hasVisibleShadow) {
              expect(shadows, isNull);
            } else {
              final visibleShadows = shadows!;
              expect(visibleShadows, hasLength(1));
              expect(visibleShadows.single.color, effects.cardShadow);
              expect(visibleShadows.single.offset, effects.cardShadowOffset);
              expect(visibleShadows.single.blurRadius, effects.cardShadowBlur);
            }
            expect(
              tester
                  .widget<ColoredBox>(
                    find.byKey(
                      const ValueKey(
                        'tonos-bottom-navigation-selected-segment',
                      ),
                    ),
                  )
                  .color,
              context.cs.secondaryContainer,
            );
            expect(
              tester
                  .widget<ColoredBox>(
                    find.byKey(
                      const ValueKey(
                        'tonos-bottom-navigation-selected-underline',
                      ),
                    ),
                  )
                  .color,
              context.surfaceTokens.subtleOutline,
            );
            final underline = tester.widget<ColoredBox>(
              find.byKey(
                const ValueKey('tonos-bottom-navigation-selected-underline'),
              ),
            );
            expect(underline.child, isA<SizedBox>());
            expect((underline.child! as SizedBox).height, 4);
          }

          await tester.tap(find.text('Catalog'));
          await tester.pump();
          expect(selectedIndex, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
