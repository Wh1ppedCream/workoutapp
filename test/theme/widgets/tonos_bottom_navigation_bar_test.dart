import 'package:flutter/material.dart';
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

  testWidgets('Neo navigation uses one framed rail and shared selection', (
    tester,
  ) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.neoBrutalism),
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
    final frame = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('tonos-bottom-navigation-frame')),
    );
    final decoration = frame.decoration as BoxDecoration;
    final effects = context.effectTokens;
    final shapes = context.shapeTokens;
    expect(decoration.color, context.cs.primaryContainer);
    expect(decoration.border, isNotNull);
    expect(decoration.border!.top.width, shapes.outlineWidth);
    expect(decoration.borderRadius, shapes.trainTab);
    expect(decoration.boxShadow, hasLength(1));
    expect(decoration.boxShadow!.single.offset, effects.cardShadowOffset);
    expect(decoration.boxShadow!.single.blurRadius, effects.cardShadowBlur);
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(
              const ValueKey('tonos-bottom-navigation-selected-segment'),
            ),
          )
          .color,
      context.cs.secondaryContainer,
    );
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(
              const ValueKey('tonos-bottom-navigation-selected-underline'),
            ),
          )
          .color,
      context.surfaceTokens.subtleOutline,
    );

    await tester.tap(find.text('Catalog'));
    await tester.pump();
    expect(selectedIndex, 1);
  });

  testWidgets('Classic navigation keeps the ordinary Material owner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        home: Scaffold(
          bottomNavigationBar: TonosBottomNavigationBar(
            items: items,
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tonos-bottom-navigation-frame')),
      findsNothing,
    );
  });
}
