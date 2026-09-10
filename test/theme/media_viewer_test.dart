import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/widgets/media_viewer_image.dart';

void main() {
  test('Classic media frames and effects retain their original values', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      expect(theme.extension<AppMediaTokens>(), isNotNull);
      final media = theme.mediaTokens;
      expect(media.previewShape, BorderRadius.circular(18));
      expect(media.overlayShape, BorderRadius.circular(12));
      expect(media.viewerShape, BorderRadius.circular(20));
      expect(media.overlayOpacity, 0.96);
      expect(
        media.overlayShadow.single.color,
        Colors.black.withValues(alpha: 0.30),
      );
      expect(media.overlayShadow.single.blurRadius, 10);
      expect(media.overlayShadow.single.offset, const Offset(0, 3));
      final noEffects = media.copyWith(overlayShadow: const []);
      expect(noEffects.copyWith().overlayShadow, isEmpty);
      expect(media.lerp(noEffects, 1).overlayShadow, isEmpty);
      expect(media.lerp(noEffects, 0), same(media));
      expect(noEffects.lerp(media, 0).overlayShadow, isEmpty);
      expect(noEffects.lerp(media, 1), same(media));
      expect(
        media.copyWith(viewerShape: BorderRadius.zero).viewerShape,
        BorderRadius.zero,
      );
      expect(
        media.lerp(media.copyWith(overlayOpacity: 0.4), 0.5).overlayOpacity,
        closeTo(0.68, 1e-9),
      );
    }
    expect(ThemeData().mediaTokens, same(AppMediaTokens.classic));
  });

  testWidgets(
    'missing viewer file renders a fallback without losing the viewer',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('tonos-viewer-');
      addTearDown(() => directory.deleteSync(recursive: true));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: TextButton(
                    onPressed:
                        () => showMediaImageViewer(
                          context: context,
                          file: File('${directory.path}/missing.png'),
                          imageLabel: 'Image',
                          zoomHint: 'Pinch to zoom',
                          closeLabel: 'Close viewer',
                          footer: const Text('Form guide'),
                        ),
                    child: const Text('Open viewer'),
                  ),
                ),
          ),
        ),
      );
      // Start file loading outside fake async so its completion can be awaited.
      await tester.runAsync(() async {
        await tester.tap(find.text('Open viewer'));
        await tester.pump();
        final image = tester.widget<Image>(find.byType(Image));
        await precacheImage(
          image.image,
          tester.element(find.byType(Image)),
          onError: (error, stack) {},
        ).timeout(const Duration(seconds: 10));
      });
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      final viewer = find.byType(InteractiveViewer);
      final center = tester.getCenter(viewer);
      final first = await tester.startGesture(
        center - const Offset(30, 0),
        pointer: 1,
      );
      final second = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 2,
      );
      await tester.pump();
      await first.moveTo(center - const Offset(80, 0));
      await second.moveTo(center + const Offset(80, 0));
      await tester.pump();
      expect(
        tester
            .widgetList<Transform>(
              find.descendant(of: viewer, matching: find.byType(Transform)),
            )
            .any((transform) => transform.transform.getMaxScaleOnAxis() > 1),
        isTrue,
      );
      await first.up();
      await second.up();
      await tester.pumpAndSettle();
      Matrix4 viewerTransform() =>
          tester
              .widgetList<Transform>(
                find.descendant(of: viewer, matching: find.byType(Transform)),
              )
              .firstWhere((t) => t.transform.getMaxScaleOnAxis() > 1)
              .transform
              .clone();
      final beforePan = viewerTransform();
      // Clear slop and avoid the parent's vertical scroll recognizer.
      final pan = await tester.startGesture(center, pointer: 3);
      await pan.moveBy(const Offset(40, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await pan.moveBy(const Offset(40, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await pan.up();
      await tester.pumpAndSettle();
      final afterPan = viewerTransform();
      expect(afterPan.getTranslation(), isNot(beforePan.getTranslation()));
      await tester.tap(find.byTooltip('Close viewer'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(find.text('Open viewer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
