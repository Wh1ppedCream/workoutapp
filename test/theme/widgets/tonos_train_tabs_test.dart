import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
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
}
