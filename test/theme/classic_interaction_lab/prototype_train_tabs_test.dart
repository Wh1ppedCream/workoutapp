import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/classic_interaction_lab/prototype_train_tabs.dart';

Widget _testApp(Widget child) => MaterialApp(
  theme: AppThemeFactory.light(AppThemeFamily.classic),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('both variants start on Overview with the same destinations', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const TrainTabsPrototype()));

    expect(find.text('Overview'), findsNWidgets(2));
    expect(find.text('Plans'), findsNWidgets(2));
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('train-tabs-baseline-overview')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
  });

  testWidgets('Tonos tabs and SegmentedButton both change selection', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const TrainTabsPrototype()));

    await tester.tap(find.byKey(const ValueKey('train-tabs-baseline-plans')));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('train-tabs-material-control')),
        matching: find.text('Plans'),
      ),
    );
    await tester.pump();

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('train-tabs-baseline-plans')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    final segmented = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(segmented.selected, {1});
  });

  testWidgets('standard Material selector reflows at larger text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const TrainTabsPrototype(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Overview'), findsNWidgets(2));
    expect(find.text('Plans'), findsNWidgets(2));
  });
}
