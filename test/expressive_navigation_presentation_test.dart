import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/widgets/tonos_bottom_navigation_bar.dart';

void main() {
  testWidgets(
    'Expressive navigation uses its chromatic surface and static selected shape',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Train',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logbook'),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Progress',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
      final callbacks = <int>[];
      var currentIndex = 0;
      late StateSetter setCurrentIndex;
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 800),
                disableAnimations: true,
              ),
              child: StatefulBuilder(
                builder: (context, update) {
                  setCurrentIndex = update;
                  return Scaffold(
                    bottomNavigationBar: TonosBottomNavigationBar(
                      items: items,
                      currentIndex: currentIndex,
                      onTap: callbacks.add,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        setCurrentIndex(() => currentIndex = 4);
        await tester.pump();

        final navigation = find.byType(TonosBottomNavigationBar);
        final frame = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('tonos-expressive-navigation-frame')),
        );
        final frameDecoration = frame.decoration as BoxDecoration;
        expect(
          frameDecoration.color,
          AppExpressiveTrainTokens.light.navigationSurface,
        );
        expect(frameDecoration.borderRadius, ExpressiveTrainShapes.navigation);

        final selectedFill = find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
            return false;
          }
          return (widget.decoration as BoxDecoration).color ==
              AppExpressiveTrainTokens.light.navigationSelected;
        });
        expect(selectedFill, findsOneWidget);
        final fillDecoration =
            tester.widget<DecoratedBox>(selectedFill).decoration
                as BoxDecoration;
        expect(
          fillDecoration.borderRadius,
          ExpressiveTrainShapes.selectedSelector,
        );
        final profile = find.bySemanticsLabel('Profile');
        expect(
          tester
              .getSemantics(profile)
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );
        expect(
          tester
              .getSemantics(profile)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          tester
              .getSize(
                find
                    .ancestor(
                      of: find.text('Profile'),
                      matching: find.byType(InkWell),
                    )
                    .first,
              )
              .width,
          greaterThanOrEqualTo(48),
        );
        final destination = find
            .ancestor(of: find.text('Profile'), matching: find.byType(InkWell))
            .first;
        expect(
          tester.getSize(selectedFill).width,
          closeTo(tester.getSize(destination).width * 0.94, 0.1),
        );

        await tester.tap(find.text('Profile'));
        expect(callbacks, [4]);
        expect(tester.getSize(navigation).width, closeTo(360, 0.1));
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'Compact stacked selection settles immediately with reduced motion',
    (tester) async {
      const size = Size(320, 800);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final items = List<BottomNavigationBarItem>.generate(
        5,
        (index) => BottomNavigationBarItem(
          icon: const Icon(Icons.circle_outlined),
          activeIcon: const Icon(Icons.circle),
          label: 'Destination ${index + 1}',
        ),
        growable: false,
      );
      var selectedIndex = 0;
      late StateSetter updateSelection;

      Widget host(ThemeData theme) => MaterialApp(
        theme: theme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              updateSelection = setState;
              return Scaffold(
                bottomNavigationBar: TonosBottomNavigationBar(
                  items: items,
                  currentIndex: selectedIndex,
                  onTap: (index) => updateSelection(() {
                    selectedIndex = index;
                  }),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(host(ExpressiveThemeDefinition.light()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Destination 5'));
      await tester.pump();

      expect(selectedIndex, 4);
      final previousSelection = tester.widget<AnimatedContainer>(
        find.byKey(
          const ValueKey('tonos-expressive-navigation-inline-selection-0'),
        ),
      );
      final newSelection = tester.widget<AnimatedContainer>(
        find.byKey(
          const ValueKey('tonos-expressive-navigation-inline-selection-4'),
        ),
      );
      expect(previousSelection.duration, Duration.zero);
      expect(newSelection.duration, Duration.zero);
      expect(
        (previousSelection.decoration! as BoxDecoration).color,
        Colors.transparent,
      );
      expect(
        (newSelection.decoration! as BoxDecoration).color,
        AppExpressiveTrainTokens.light.navigationSelected,
      );

      for (final family in [
        AppThemeFamily.classic,
        AppThemeFamily.neoBrutalism,
      ]) {
        selectedIndex = 0;
        await tester.pumpWidget(host(AppThemeFactory.light(family)));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('tonos-expressive-navigation-frame')),
          findsNothing,
        );
        expect(
          find.byKey(
            const ValueKey('tonos-expressive-navigation-inline-selection-4'),
          ),
          findsNothing,
        );
        await tester.tap(find.text('Destination 5'));
        await tester.pumpAndSettle();
        expect(selectedIndex, 4);
        expect(tester.takeException(), isNull);
      }
    },
  );

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

  for (final scenario in [
    ('320dp at 1x', 320.0, 1.0),
    ('320dp at 1.15x', 320.0, 1.15),
    ('320dp at 1.5x', 320.0, 1.5),
    ('320dp at 2x', 320.0, 2.0),
    ('normal width', 393.0, 1.0),
  ]) {
    testWidgets(
      scenario.$1 == 'normal width'
          ? 'Expressive navigation preserves normal-width behavior'
          : 'Expressive navigation exposes all five destinations at '
                '${scenario.$1}',
      (tester) async {
        final width = scenario.$2;
        final textScale = scenario.$3;
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const items = <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logbook'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
        var selectedIndex = 0;
        final tappedIndexes = <int>[];
        final semanticsHandle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: ExpressiveThemeDefinition.light(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    bottomNavigationBar: TonosBottomNavigationBar(
                      items: items,
                      currentIndex: selectedIndex,
                      onTap: (index) {
                        tappedIndexes.add(index);
                        setState(() => selectedIndex = index);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final frameRect = tester.getRect(
            find.byKey(const ValueKey('tonos-expressive-navigation-frame')),
          );
          expect(items, hasLength(5));
          final compactFiveDestinations = width <= 360;
          if (compactFiveDestinations) {
            expect(find.byType(SingleChildScrollView), findsNothing);
          } else if (width > 360) {
            expect(find.byType(SingleChildScrollView), findsOneWidget);
          }
          final destinationRects = <Rect>[];
          for (final item in items) {
            final labelFinder = find.text(item.label!);
            expect(labelFinder, findsOneWidget, reason: item.label);
            final labelRect = tester.getRect(labelFinder);
            if (compactFiveDestinations) {
              expect(labelRect.left, greaterThanOrEqualTo(frameRect.left));
              expect(labelRect.right, lessThanOrEqualTo(frameRect.right));
              expect(labelRect.top, greaterThanOrEqualTo(frameRect.top));
              expect(labelRect.bottom, lessThanOrEqualTo(frameRect.bottom));
            }
            if (compactFiveDestinations && textScale > 1.15) {
              expect(
                tester.getSize(labelFinder).height,
                lessThan(40),
                reason:
                    '${item.label} size ${tester.getSize(labelFinder)} in '
                    '${tester.getRect(find.ancestor(of: labelFinder, matching: find.byType(InkWell)).first)}',
              );
            }
            final destination = find
                .ancestor(of: labelFinder, matching: find.byType(InkWell))
                .first;
            final destinationRect = tester.getRect(destination);
            destinationRects.add(destinationRect);
            expect(destinationRect.width, greaterThanOrEqualTo(48));
            expect(destinationRect.height, greaterThanOrEqualTo(48));
            expect(
              tester
                  .getSemantics(find.bySemanticsLabel(item.label!))
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isTrue,
            );
            if (compactFiveDestinations) {
              expect(
                destinationRect.left,
                greaterThanOrEqualTo(frameRect.left),
              );
              expect(destinationRect.right, lessThanOrEqualTo(frameRect.right));
              expect(destinationRect.top, greaterThanOrEqualTo(frameRect.top));
              expect(
                destinationRect.bottom,
                lessThanOrEqualTo(frameRect.bottom),
              );
            }
          }
          if (compactFiveDestinations) {
            for (var first = 0; first < destinationRects.length; first++) {
              for (
                var second = first + 1;
                second < destinationRects.length;
                second++
              ) {
                expect(
                  destinationRects[first].overlaps(destinationRects[second]),
                  isFalse,
                );
              }
            }
          }

          if (compactFiveDestinations && textScale > 1.15) {
            expect(
              tester.getSize(find.byType(TonosBottomNavigationBar)).height,
              greaterThan(100),
              reason: 'high-scale destinations occupy compact stacked rows',
            );
          }
          await tester.ensureVisible(find.text('Catalog'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Catalog'));
          await tester.pumpAndSettle();
          expect(tappedIndexes, [1]);
          expect(selectedIndex, 1);
          expect(items, hasLength(5));
          expect(
            tester
                .getSemantics(find.bySemanticsLabel('Catalog'))
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
          if (compactFiveDestinations && textScale > 1.15) {
            final selectedFill = tester.widget<AnimatedContainer>(
              find.byKey(
                const ValueKey(
                  'tonos-expressive-navigation-inline-selection-1',
                ),
              ),
            );
            expect(
              (selectedFill.decoration! as BoxDecoration).color,
              AppExpressiveTrainTokens.light.navigationSelected,
            );
            expect(
              tester.widget<Text>(find.text('Catalog')).style?.color,
              AppExpressiveTrainTokens.light.navigationSelectedForeground,
              reason:
                  'the selected stacked row uses its selected-surface '
                  'foreground',
            );
          }
          expect(tester.takeException(), isNull);
        } finally {
          semanticsHandle.dispose();
        }
      },
    );
  }

  testWidgets(
    'Expressive selected navigation label contrasts with its surface',
    (tester) async {
      const items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Train',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
      ];

      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final tokens = brightness == Brightness.light
            ? AppExpressiveTrainTokens.light
            : AppExpressiveTrainTokens.dark;
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
        await tester.pumpAndSettle();

        final selectedLabel = tester.widget<Text>(find.text('Train'));
        expect(selectedLabel.style?.color, tokens.navigationLabel);
        expect(selectedLabel.style?.fontWeight, FontWeight.w700);
      }

      expect(tester.takeException(), isNull);
    },
  );

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
          final visibleHitWidth =
              (math.min(destinationRect.right, width) -
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
        final rowHeight = math.max(
          56.0,
          width <= 360 ? tallestLabel + 8 : 32 + tallestLabel + 8,
        );
        final rowCount = width <= 360 && items.length > 3 ? items.length : 1;
        final expectedHeight = rowHeight * rowCount + 4 * (rowCount - 1);
        expect(navSize.height, closeTo(expectedHeight, 0.1));
        expect(tester.takeException(), isNull);
      }
      semanticsHandle.dispose();
    },
  );

  const navigationWidths = <({String label, Size size})>[
    (label: '320dp', size: Size(320, 800)),
    (label: '390dp', size: Size(390, 844)),
    (label: '800dp', size: Size(800, 1280)),
  ];
  for (final viewport in navigationWidths) {
    for (final textScale in [1.0, 2.0]) {
      for (final count in [5, 6, 8, 11]) {
        testWidgets(
          'Expressive navigation keeps $count destinations interactive at '
          '${viewport.label} and ${textScale}x text',
          (tester) async {
            await tester.binding.setSurfaceSize(viewport.size);
            addTearDown(() => tester.binding.setSurfaceSize(null));

            final items = List<BottomNavigationBarItem>.generate(
              count,
              (index) => BottomNavigationBarItem(
                icon: const Icon(Icons.circle_outlined),
                activeIcon: const Icon(Icons.circle),
                label: 'Destination ${index + 1}',
              ),
              growable: false,
            );
            var selectedIndex = count - 1;
            late StateSetter updateSelection;
            Widget host() => MaterialApp(
              theme: ExpressiveThemeDefinition.light(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: viewport.size,
                  textScaler: TextScaler.linear(textScale),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    updateSelection = setState;
                    return Scaffold(
                      bottomNavigationBar: TonosBottomNavigationBar(
                        items: items,
                        currentIndex: selectedIndex,
                        onTap: (index) => updateSelection(() {
                          selectedIndex = index;
                        }),
                      ),
                    );
                  },
                ),
              ),
            );

            final semantics = tester.ensureSemantics();
            try {
              await tester.pumpWidget(host());
              await tester.pumpAndSettle();

              final navigation = find.byType(TonosBottomNavigationBar);
              expect(tester.getSize(navigation).width, viewport.size.width);
              final navigationScrollables = find.descendant(
                of: navigation,
                matching: find.byType(Scrollable),
              );
              final scrollableCount = navigationScrollables.evaluate().length;
              expect(scrollableCount, lessThanOrEqualTo(1));
              if (scrollableCount == 1) {
                expect(
                  tester
                      .state<ScrollableState>(navigationScrollables)
                      .axisDirection,
                  isIn([AxisDirection.left, AxisDirection.right]),
                );
              }

              final selectedLabel = items.last.label!;
              final selectedText = find.text(selectedLabel);
              expect(selectedText, findsOneWidget);
              final selectedRect = tester.getRect(selectedText);
              expect(selectedRect.left, greaterThanOrEqualTo(0));
              expect(
                selectedRect.right,
                lessThanOrEqualTo(viewport.size.width),
              );
              final selectedSemantics = tester
                  .getSemantics(find.bySemanticsLabel(selectedLabel))
                  .getSemanticsData();
              expect(selectedSemantics.hasAction(SemanticsAction.tap), isTrue);
              expect(
                selectedSemantics.flagsCollection.isSelected,
                Tristate.isTrue,
              );

              final firstLabel = items.first.label!;
              final firstText = find.text(firstLabel);
              await tester.ensureVisible(firstText);
              await tester.pumpAndSettle();
              final firstRect = tester.getRect(firstText);
              expect(firstRect.left, greaterThanOrEqualTo(0));
              expect(firstRect.right, lessThanOrEqualTo(viewport.size.width));
              await tester.tap(firstText);
              await tester.pumpAndSettle();

              expect(selectedIndex, 0);
              final firstSemantics = tester
                  .getSemantics(find.bySemanticsLabel(firstLabel))
                  .getSemanticsData();
              expect(firstSemantics.hasAction(SemanticsAction.tap), isTrue);
              expect(
                firstSemantics.flagsCollection.isSelected,
                Tristate.isTrue,
              );
              final firstSelectedRect = tester.getRect(firstText);
              expect(firstSelectedRect.left, greaterThanOrEqualTo(0));
              expect(
                firstSelectedRect.right,
                lessThanOrEqualTo(viewport.size.width),
              );
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          },
        );
      }
    }
  }

  for (final textScale in [1.0, 2.0]) {
    testWidgets(
      'Expressive selected destination stays visible after 800-to-320dp '
      'reflow at ${textScale}x text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        const items = <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 1'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 2'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 3'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 4'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 5'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 6'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 7'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 8'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 9'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 10'),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: 'Tab 11'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: Scaffold(
              bottomNavigationBar: TonosBottomNavigationBar(
                items: items,
                currentIndex: 10,
                onTap: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.binding.setSurfaceSize(const Size(320, 800));
        await tester.pumpAndSettle();
        final selected = find.text('Tab 11');
        final rect = tester.getRect(selected);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
        expect(tester.takeException(), isNull);
      },
    );
  }

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
