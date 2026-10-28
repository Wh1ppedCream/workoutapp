import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_inset_accordion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:ui' show Tristate;

const _title = 'Section with a longer title';
const _outer = ValueKey('outer');
const _body = ValueKey('body');
const _leading = ValueKey('leading');

Widget _host(
  Brightness brightness,
  Widget child, {
  double textScale = 1,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: brightness == Brightness.light
      ? ExpressiveThemeDefinition.light()
      : ExpressiveThemeDefinition.dark(),
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reducedMotion,
    ),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

Widget _accordion({Widget? body, VoidCallback? onBodyTap, Key? key}) =>
    Material(
      key: _outer,
      child: TonosExpressiveInsetAccordion(
        key: key,
        surface: const Color(0xFFE7D7EF),
        foreground: const Color(0xFF35203F),
        outline: const Color(0xFF76528B),
        borderRadius: BorderRadius.circular(24),
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: const SizedBox(key: _leading, width: 38, height: 38),
        title: const Text(_title),
        subtitle: const Text('Existing summary and controls'),
        children: [
          SizedBox(
            key: _body,
            height: 320,
            child:
                body ??
                TextButton(
                  onPressed: onBodyTap,
                  child: const Text('Body action'),
                ),
          ),
        ],
      ),
    );

Finder get _header => find.byType(ListTile).first;

void main() {
  for (final brightness in Brightness.values) {
    for (final width in [320.0, 411.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'inset preserves content gutters inside its shape ${brightness.name} $width $scale',
          (tester) async {
            await tester.binding.setSurfaceSize(Size(width, 1400));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            var bodyTaps = 0;
            await tester.pumpWidget(
              _host(
                brightness,
                _accordion(onBodyTap: () => bodyTaps++),
                textScale: scale,
              ),
            );
            await tester.pumpAndSettle();
            final initialLeadingX = tester.getTopLeft(find.byKey(_leading)).dx;
            final closedHeight = tester.getSize(find.byKey(_outer)).height;
            await tester.tap(find.text(_title));
            await tester.pumpAndSettle();
            final outerRect = tester.getRect(find.byKey(_outer));
            final headerRect = tester.getRect(_header);
            expect(headerRect.left, closeTo(outerRect.left + 10, .01));
            expect(headerRect.right, closeTo(outerRect.right - 10, .01));
            expect(headerRect.top, closeTo(outerRect.top + 10, .01));
            expect(
              tester.getTopLeft(find.byKey(_leading)).dx,
              closeTo(initialLeadingX + 10, .01),
            );
            expect(
              tester.getTopLeft(find.byKey(_leading)).dx - headerRect.left,
              closeTo(16, .01),
            );
            expect(
              headerRect.right -
                  tester.getRect(find.byIcon(Icons.expand_more)).right,
              closeTo(16, .01),
            );
            final headerMaterial = tester.widget<Material>(
              find.ancestor(of: _header, matching: find.byType(Material)).first,
            );
            expect(
              (headerMaterial.shape! as RoundedRectangleBorder).borderRadius,
              BorderRadius.circular(16),
            );
            expect(
              tester.getSize(find.byKey(_body)).width,
              closeTo(width - 24, .01),
            );
            expect(
              tester.getTopLeft(find.byKey(_body)).dy - headerRect.bottom,
              closeTo(12, .01),
            );
            await tester.tap(find.text('Body action'));
            await tester.pumpAndSettle();
            expect(bodyTaps, 1);
            expect(
              tester
                  .widget<Expansible>(find.byType(Expansible))
                  .controller
                  .isExpanded,
              isTrue,
            );
            await tester.tap(find.text(_title));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 344));
            expect(
              tester.getSize(find.byKey(_outer)).height - closedHeight,
              lessThan(4),
            );
            await tester.pumpAndSettle();
            expect(
              tester.getSize(find.byKey(_outer)).height,
              closeTo(closedHeight, .01),
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets(
      'inset reverses without a jump and retains fields ${brightness.name}',
      (tester) async {
        final controller = TextEditingController(text: 'Existing value');
        final rebuild = ValueNotifier<int>(0);
        addTearDown(controller.dispose);
        addTearDown(rebuild.dispose);
        await tester.pumpWidget(
          _host(
            brightness,
            ValueListenableBuilder<int>(
              valueListenable: rebuild,
              builder: (_, value, _) =>
                  _accordion(body: TextField(controller: controller)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(_title));
        await tester.pumpAndSettle();
        final openHeight = tester.getSize(find.byKey(_outer)).height;
        await tester.tap(find.text(_title));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        final interruptedHeight = tester.getSize(find.byKey(_outer)).height;
        rebuild.value++;
        await tester.pump();
        expect(
          tester.getSize(find.byKey(_outer)).height,
          closeTo(interruptedHeight, .01),
        );
        await tester.tap(find.text(_title));
        await tester.pump();
        expect(
          tester.getSize(find.byKey(_outer)).height,
          closeTo(interruptedHeight, .01),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byKey(_outer)).height,
          closeTo(openHeight, .01),
        );
        expect(controller.text, 'Existing value');
        expect(find.byType(TextField), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('inset respects reduced motion ${brightness.name}', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _host(brightness, _accordion(), reducedMotion: true),
        );
        await tester.pumpAndSettle();
        final closedHeight = tester.getSize(find.byKey(_outer)).height;
        await tester.tap(find.text(_title));
        await tester.pump();
        expect(
          tester.getSize(find.byKey(_outer)).height,
          closeTo(closedHeight + 342, .01),
        );
        final headerSemantics = find
            .ancestor(of: _header, matching: find.byType(Semantics))
            .first;
        expect(
          tester.getSemantics(headerSemantics).flagsCollection.isExpanded,
          Tristate.isTrue,
        );
        await tester.tap(find.text(_title));
        await tester.pump();
        expect(
          tester.getSize(find.byKey(_outer)).height,
          closeTo(closedHeight, .01),
        );
        expect(find.text('Body action'), findsNothing);
        expect(
          tester.getSemantics(headerSemantics).flagsCollection.isExpanded,
          Tristate.isFalse,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
}
