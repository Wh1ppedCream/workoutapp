import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';

void main() {
  testWidgets(
    'selection decoration preserves RTL targets and semantics at 2x text in a compact width',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        var selectedIndex = 0;
        var tappedIndex = -1;
        late StateSetter setSelection;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQuery = MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  size: const Size(320, 720),
                  textScaler: TextScaler.linear(2),
                );
                return MediaQuery(
                  data: mediaQuery,
                  child: Scaffold(
                    body: Center(
                      child: StatefulBuilder(
                        builder: (context, update) {
                          setSelection = update;
                          return SizedBox(
                            key: const ValueKey('compact-train-tabs'),
                            width: 320,
                            height: 96,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TonosExpressiveSelectionIndicator(
                                selectedIndex: selectedIndex,
                                itemCount: 2,
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(18),
                                topologyKey: 'overview-plans',
                                child: Row(
                                  children: [
                                    _tabTarget(
                                      index: 0,
                                      label: 'Overview',
                                      selectedIndex: selectedIndex,
                                      onTap: (index) {
                                        tappedIndex = index;
                                        setSelection(() {
                                          selectedIndex = index;
                                        });
                                      },
                                    ),
                                    _tabTarget(
                                      index: 1,
                                      label: 'Plans',
                                      selectedIndex: selectedIndex,
                                      onTap: (index) {
                                        tappedIndex = index;
                                        setSelection(() {
                                          selectedIndex = index;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        final overview = find.bySemanticsLabel('Overview');
        final plans = find.bySemanticsLabel('Plans');
        expect(overview, findsOneWidget);
        expect(plans, findsOneWidget);
        expect(
          tester
              .getSemantics(overview)
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );
        expect(
          tester
              .getSemantics(plans)
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          isNot(Tristate.isTrue),
        );
        expect(
          tester
              .getSemantics(plans)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );

        for (final key in const ['overview-target', 'plans-target']) {
          final size = tester.getSize(find.byKey(ValueKey(key)));
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }

        final groupRect = tester.getRect(
          find.byKey(const ValueKey('compact-train-tabs')),
        );
        final indicator = find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.deepPurple,
        );
        expect(
          tester.getCenter(indicator).dx - groupRect.left,
          closeTo(240, 0.1),
        );

        await tester.tap(find.byKey(const ValueKey('plans-target')));
        await tester.pump();
        expect(tappedIndex, 1);
        expect(
          tester.getCenter(indicator).dx - groupRect.left,
          closeTo(80, 0.1),
        );
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}

Widget _tabTarget({
  required int index,
  required String label,
  required int selectedIndex,
  required ValueChanged<int> onTap,
}) {
  return Expanded(
    child: Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      selected: selectedIndex == index,
      label: label,
      onTap: () => onTap(index),
      child: InkWell(
        key: ValueKey(index == 0 ? 'overview-target' : 'plans-target'),
        excludeFromSemantics: true,
        onTap: () => onTap(index),
        child: Center(
          child: Text(label, maxLines: 2, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}
