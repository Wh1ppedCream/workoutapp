import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_state_motion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _body = ValueKey('disclosure-body');
const _reveal = ValueKey('disclosure-reveal');

Widget _host(Widget child, Brightness brightness) => MaterialApp(
  theme: brightness == Brightness.light
      ? ExpressiveThemeDefinition.light()
      : ExpressiveThemeDefinition.dark(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Widget _disclosure(bool expanded) => AnimatedCrossFade(
  key: _reveal,
  firstChild: const SizedBox(width: double.infinity),
  secondChild: const SizedBox(key: _body, height: 500, width: double.infinity),
  crossFadeState: expanded
      ? CrossFadeState.showSecond
      : CrossFadeState.showFirst,
  duration: TonosExpressiveStateMotion.standard,
  sizeCurve: TonosExpressiveStateMotion.spatial,
);

Widget _accordion({bool initiallyExpanded = true}) => Builder(
  builder: (context) => ExpansionTile(
    initiallyExpanded: initiallyExpanded,
    maintainState: true,
    expansionAnimationStyle: TonosExpressiveStateMotion.expansionStyle(
      context,
      settleOnCollapse: true,
    ),
    title: const Text('Section'),
    children: const [SizedBox(height: 500)],
  ),
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('disclosure brakes before the last frame ${brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_disclosure(true), brightness));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(_disclosure(false), brightness));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 344));
      expect(
        tester.getSize(find.byKey(_reveal)).height,
        lessThan(5),
        reason: 'The last frame should not remove a large slice of content.',
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getSize(find.byKey(_reveal)).height, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'custom accordion brakes before the last frame ${brightness.name}',
      (tester) async {
        await tester.pumpWidget(_host(_accordion(), brightness));
        await tester.pumpAndSettle();
        final tile = find.byType(ExpansionTile);
        final expandedHeight = tester.getSize(tile).height;
        await tester.tap(find.text('Section'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 344));
        final penultimateHeight = tester.getSize(tile).height;
        await tester.pumpAndSettle();
        final collapsedHeight = tester.getSize(tile).height;
        expect(
          penultimateHeight - collapsedHeight,
          lessThan((expandedHeight - collapsedHeight) * .01),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'accordion survives rapid reversals and rebuilds ${brightness.name}',
      (tester) async {
        final rebuild = ValueNotifier<int>(0);
        addTearDown(rebuild.dispose);
        await tester.pumpWidget(
          _host(
            ValueListenableBuilder<int>(
              valueListenable: rebuild,
              builder: (_, value, _) => _accordion(),
            ),
            brightness,
          ),
        );
        await tester.pumpAndSettle();
        final tile = find.byType(ExpansionTile);
        final openHeight = tester.getSize(tile).height;
        await tester.tap(find.text('Section'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        final closingHeight = tester.getSize(tile).height;
        rebuild.value++;
        await tester.pump();
        expect(tester.getSize(tile).height, closeTo(closingHeight, .01));
        await tester.tap(find.text('Section'));
        await tester.pump();
        expect(tester.getSize(tile).height, closeTo(closingHeight, .01));
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getSize(tile).height, greaterThan(closingHeight));
        await tester.pumpAndSettle();
        expect(tester.getSize(tile).height, closeTo(openHeight, .01));
        await tester.tap(find.text('Section'));
        await tester.pumpAndSettle();
        expect(tester.getSize(tile).height, closeTo(openHeight - 500, .01));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('accordion respects reduced motion ${brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: _accordion(),
          ),
          brightness,
        ),
      );
      await tester.pumpAndSettle();
      final tile = find.byType(ExpansionTile);
      final openHeight = tester.getSize(tile).height;
      await tester.tap(find.text('Section'));
      await tester.pump();
      expect(tester.getSize(tile).height, closeTo(openHeight - 500, .01));
      expect(tester.takeException(), isNull);
    });
  }
}
