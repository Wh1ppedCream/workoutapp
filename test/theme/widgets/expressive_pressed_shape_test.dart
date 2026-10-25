import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _captureKey = ValueKey('surface-capture');
const _targetKey = ValueKey('surface-action');
const _shape = BorderRadius.only(
  topLeft: Radius.circular(40),
  topRight: Radius.circular(12),
  bottomLeft: Radius.circular(12),
  bottomRight: Radius.circular(40),
);

void main() {
  for (final brightness in Brightness.values) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'inset settings ink follows its shape ${brightness.name} ${textScale}x',
        (tester) async {
          var taps = 0;
          await tester.pumpWidget(
            _host(
              brightness: brightness,
              textScale: textScale,
              child: TonosSurface(
                borderRadius: _shape,
                color: const Color(0xFFDDDDDD),
                padding: const EdgeInsets.all(5),
                child: SettingsActionTile(
                  key: _targetKey,
                  icon: Icons.palette_outlined,
                  title: 'Theme family',
                  titleWidget: const SizedBox.shrink(),
                  trailing: const SizedBox.shrink(),
                  onTap: () => taps++,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final before = await _pixels(tester);
          final gesture = await tester.startGesture(
            tester.getCenter(find.byKey(_targetKey)),
          );
          await tester.pump(const Duration(milliseconds: 120));
          await tester.pump(const Duration(milliseconds: 250));
          final pressed = await _pixels(tester);
          // These points are inside the outer silhouette but outside the inset
          // control's matching curves, so outer clipping alone cannot fix them.
          for (final point in [const Offset(42, 28), const Offset(198, 112)]) {
            expect(_pixel(pressed, point), _pixel(before, point));
          }
          expect(
            _pixel(pressed, const Offset(120, 70)),
            isNot(_pixel(before, const Offset(120, 70))),
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(taps, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets(
      'pressed ink follows the Expressive surface ${brightness.name}',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _host(
            brightness: brightness,
            child: TonosSurface(
              borderRadius: _shape,
              color: const Color(0xFFDDDDDD),
              padding: const EdgeInsets.all(5),
              child: InkWell(
                key: _targetKey,
                onTap: () => taps++,
                highlightColor: const Color(0xFFCC0022),
                splashFactory: NoSplash.splashFactory,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final before = await _pixels(tester);
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(_targetKey)),
        );
        await tester.pump(const Duration(milliseconds: 120));
        await tester.pump(const Duration(milliseconds: 250));
        final pressed = await _pixels(tester);

        // These points are inside the rectangular tile but outside its two
        // large curved corners. A rectangular highlight must not paint here.
        for (final point in [const Offset(28, 28), const Offset(212, 112)]) {
          expect(_pixel(pressed, point), _pixel(before, point));
        }
        expect(
          _pixel(pressed, const Offset(120, 70)),
          isNot(_pixel(before, const Offset(120, 70))),
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive retains custom shapes and explicit clipping overrides',
    (tester) async {
      const customShape = BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      );
      for (final clipping in <Clip?>[null, Clip.none]) {
        await tester.pumpWidget(
          _host(
            child: TonosSurface(
              shape: customShape,
              clipBehavior: clipping,
              child: const SizedBox.expand(),
            ),
          ),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(TonosSurface),
            matching: find.byType(Material),
          ),
        );
        expect(material.shape, customShape);
        expect(material.clipBehavior, clipping ?? Clip.antiAlias);
      }
    },
  );

  testWidgets('Classic and Neo keep their surface clipping policy', (
    tester,
  ) async {
    for (final family in [
      AppThemeFamily.classic,
      AppThemeFamily.neoBrutalism,
    ]) {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          _host(
            family: family,
            brightness: brightness,
            child: const TonosSurface(child: SizedBox.expand()),
          ),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(TonosSurface),
            matching: find.byType(Material),
          ),
        );
        expect(material.clipBehavior, Clip.none);
      }
    }
  });
}

Widget _host({
  required Widget child,
  AppThemeFamily family = AppThemeFamily.expressive,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => MaterialApp(
  theme:
      (brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family))
          .copyWith(
            highlightColor: const Color(0xFFCC0022),
            splashFactory: NoSplash.splashFactory,
          ),
  themeAnimationDuration: Duration.zero,
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _captureKey,
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(width: 200, height: 100, child: child),
            ),
          ),
        ),
      ),
    ),
  ),
);

Future<Uint8List> _pixels(WidgetTester tester) async => (await tester.runAsync(
  () async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return bytes!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  },
))!;

List<int> _pixel(Uint8List bytes, Offset point) {
  final offset = (point.dy.toInt() * 240 + point.dx.toInt()) * 4;
  return bytes.sublist(offset, offset + 4);
}
