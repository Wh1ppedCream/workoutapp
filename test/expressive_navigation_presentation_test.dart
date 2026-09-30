import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/tonos_bottom_navigation_bar.dart';

void main() {
  testWidgets('Expressive keeps the ordinary bottom-bar height at 1x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Train'),
      BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logbook'),
    ];
    Widget host(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Scaffold(
        bottomNavigationBar: TonosBottomNavigationBar(
          items: items,
          currentIndex: 0,
          onTap: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(
      host(AppThemeFactory.light(AppThemeFamily.classic)),
    );
    final classicHeight = tester
        .getSize(find.byType(TonosBottomNavigationBar))
        .height;

    await tester.pumpWidget(host(ExpressiveThemeDefinition.light()));
    final expressiveHeight = tester
        .getSize(find.byType(TonosBottomNavigationBar))
        .height;

    expect(expressiveHeight, closeTo(classicHeight, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive default five destinations keep accessible bounds at 2x',
    (tester) async {
      const tabs = [
        TabItem.train,
        TabItem.catalog,
        TabItem.history,
        TabItem.measurementsTrends,
        TabItem.profile,
      ];
      final items = tabs
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.icon),
              label: tab.bottomLabel,
            ),
          )
          .toList(growable: false);
      const scenarios = [
        ('320dp', 320.0, 900.0, 2.0),
        ('Pixel logical width', 1080 / 2.625, 2400 / 2.625, 2.625),
      ];

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semanticsHandle = tester.ensureSemantics();

      for (final scenario in scenarios) {
        final name = scenario.$1;
        final width = scenario.$2;
        final height = scenario.$3;
        final devicePixelRatio = scenario.$4;
        tester.view.physicalSize = Size(
          width * devicePixelRatio,
          height * devicePixelRatio,
        );
        tester.view.devicePixelRatio = devicePixelRatio;

        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, height),
                textScaler: TextScaler.linear(2),
              ),
              child: Scaffold(
                bottomNavigationBar: TonosBottomNavigationBar(
                  items: items,
                  currentIndex: items.length - 1,
                  onTap: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        final navigation = find.byType(TonosBottomNavigationBar);
        final navSize = tester.getSize(navigation);
        var tallestLabel = 0.0;
        for (final item in items) {
          final label = item.label!;
          final labelFinder = find.text(label);
          expect(labelFinder, findsOneWidget, reason: '$name: $label');
          tallestLabel = math.max(
            tallestLabel,
            tester.getSize(labelFinder).height,
          );
          await tester.ensureVisible(labelFinder);
          await tester.pump();

          final destination = find
              .ancestor(of: labelFinder, matching: find.byType(InkWell))
              .first;
          final destinationRect = tester.getRect(destination);
          final visibleHitWidth = (math.min(destinationRect.right, width) -
                  math.max(destinationRect.left, 0))
              .clamp(0.0, width)
              .toDouble();
          expect(destinationRect.width, greaterThanOrEqualTo(48));
          expect(destinationRect.height, greaterThanOrEqualTo(48));
          expect(visibleHitWidth, greaterThanOrEqualTo(48));
          expect(tester.getRect(labelFinder).left, greaterThanOrEqualTo(0));
          expect(tester.getRect(labelFinder).right, lessThanOrEqualTo(width));
          expect(
            tester
                .getSemantics(find.bySemanticsLabel(label))
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue,
          );
        }
        expect(tallestLabel, greaterThanOrEqualTo(24));
        final expectedHeight = math.max(56.0, 32 + tallestLabel + 8);
        expect(navSize.height, closeTo(expectedHeight, 0.1));
        expect(tester.takeException(), isNull);
      }
      semanticsHandle.dispose();
    },
  );

  for (final brightness in Brightness.values) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'Expressive navigation measures all configured destinations at '
        '${brightness.name} ${textScale}x on a 320dp viewport',
        (tester) async {
          tester.view.physicalSize = const Size(320, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final allTabs = TabItem.values;
          var items = allTabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.icon),
                  label: tab.bottomLabel,
                ),
              )
              .toList(growable: false);
          var selectedIndex = 0;

          Widget host() => MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            darkTheme: ExpressiveThemeDefinition.dark(),
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(320, 800),
                textScaler: TextScaler.linear(textScale),
              ),
              child: StatefulBuilder(
                builder: (context, setState) => Scaffold(
                  bottomNavigationBar: TonosBottomNavigationBar(
                    items: items,
                    currentIndex: selectedIndex,
                    onTap: (index) => setState(() {
                      selectedIndex = index;
                    }),
                  ),
                ),
              ),
            ),
          );

          final semanticsHandle = tester.ensureSemantics();
          try {
            await tester.pumpWidget(host());
            await tester.pump();

            final navigation = find.byType(TonosBottomNavigationBar);
            expect(items.length, TabItem.values.length);
            expect(items.length, 11);
            final maxLabelHeight = items.fold<double>(
              0,
              (height, item) => math
                  .max(height, tester.getSize(find.text(item.label!)).height)
                  .toDouble(),
            );
            expect(
              tester.getSize(navigation).height,
              greaterThanOrEqualTo(maxLabelHeight + 36),
            );
            expect(tester.takeException(), isNull);

            selectedIndex = items.length - 1;
            await tester.pumpWidget(host());
            await tester.pump();
            final lastLabel = items.last.label!;
            final lastLabelRect = tester.getRect(find.text(lastLabel));
            expect(lastLabelRect.left, greaterThanOrEqualTo(0));
            expect(lastLabelRect.right, lessThanOrEqualTo(320));
            final lastSemantics = tester
                .getSemantics(find.bySemanticsLabel(lastLabel))
                .getSemanticsData();
            expect(lastSemantics.hasAction(SemanticsAction.tap), isTrue);
            expect(lastSemantics.flagsCollection.isSelected, Tristate.isTrue);

            items = items.reversed.toList(growable: false);
            selectedIndex = 0;
            await tester.pumpWidget(host());
            await tester.pump();
            final reorderedFirstRect = tester.getRect(
              find.text(items.first.label!),
            );
            expect(reorderedFirstRect.left, greaterThanOrEqualTo(0));
            expect(reorderedFirstRect.right, lessThanOrEqualTo(320));
            expect(
              tester
                  .getSemantics(find.bySemanticsLabel(items.first.label!))
                  .getSemanticsData()
                  .flagsCollection
                  .isSelected,
              Tristate.isTrue,
            );
            expect(tester.takeException(), isNull);
          } finally {
            semanticsHandle.dispose();
          }
        },
      );
    }
  }
}
