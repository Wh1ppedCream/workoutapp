import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/workout_thumbnail_frame.dart';

void main() {
  for (final theme in [
    AppThemeFactory.light(AppThemeFamily.classic),
    AppThemeFactory.dark(AppThemeFamily.classic),
  ]) {
    testWidgets(
      '${theme.brightness} thumbnail frame preserves scale and surface',
      (tester) async {
        Widget host(ThemeData data, {double scale = 1}) => MaterialApp(
          theme: data,
          home: Scaffold(
            body: WorkoutThumbnailFrame(
              scale: scale,
              child: const Text('thumbnail'),
            ),
          ),
        );

        Container frame() => tester.widget<Container>(
          find.descendant(
            of: find.byType(WorkoutThumbnailFrame),
            matching: find.byType(Container),
          ),
        );

        await tester.pumpWidget(host(theme, scale: 1.5));
        expect(
          tester.getSize(find.byType(WorkoutThumbnailFrame)),
          const Size(90, 90),
        );
        expect(frame().padding, const EdgeInsets.all(4.5));
        final decoration = frame().decoration! as BoxDecoration;
        expect(decoration.color, theme.surfaceTokens.presetFocus);
        expect(decoration.borderRadius, BorderRadius.circular(15));
        expect(find.text('thumbnail'), findsOneWidget);

        final customSurfaces = theme.surfaceTokens.copyWith(
          presetFocus: Colors.orange,
        );
        final custom = theme.copyWith(
          extensions: [
            ...theme.extensions.values.where(
              (extension) =>
                  extension.runtimeType != customSurfaces.runtimeType,
            ),
            customSurfaces,
          ],
        );
        await tester.pumpWidget(host(custom));
        await tester.pumpAndSettle();
        expect((frame().decoration! as BoxDecoration).color, Colors.orange);
      },
    );
  }
}
