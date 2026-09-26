import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/workout_actions.dart';

void main() {
  for (final theme in [
    AppThemeFactory.light(AppThemeFamily.classic),
    AppThemeFactory.dark(AppThemeFamily.classic),
  ]) {
    testWidgets(
      '${theme.brightness} swap actions retain styles and disabled state',
      (tester) async {
        var cancels = 0;
        var confirms = 0;
        Widget host(ThemeData data, {bool enabled = true}) => MaterialApp(
          theme: data,
          home: Scaffold(
            body: Column(
              children: [
                WorkoutSwapAction(
                  label: 'Cancel',
                  cancel: true,
                  onPressed: () => cancels++,
                ),
                WorkoutSwapAction(
                  label: 'Confirm',
                  onPressed: enabled ? () => confirms++ : null,
                ),
              ],
            ),
          ),
        );
        await tester.pumpWidget(host(theme));
        final cancelFinder = find.byType(OutlinedButton);
        final confirmFinder = find.byType(FilledButton);
        final cancel = tester.widget<OutlinedButton>(cancelFinder);
        final confirm = tester.widget<FilledButton>(confirmFinder);
        expect(cancel.style!.foregroundColor!.resolve({}), Colors.redAccent);
        expect(
          cancel.style!.side!.resolve({}),
          const BorderSide(color: Colors.redAccent),
        );
        expect(confirm.style!.backgroundColor!.resolve({}), Colors.green);
        expect(confirm.style!.foregroundColor!.resolve({}), Colors.white);
        for (final style in [cancel.style!, confirm.style!]) {
          expect(
            style.padding!.resolve({}),
            const EdgeInsets.symmetric(vertical: 14),
          );
          expect(style.shape, isNull);
          expect(style.minimumSize, isNull);
        }
        await tester.tap(cancelFinder);
        await tester.tap(confirmFinder);
        expect([cancels, confirms], [1, 1]);
        final colors = theme.semanticColors.copyWith(
          swapCancel: Colors.orange,
          swapConfirm: Colors.blue,
          onSwapConfirm: Colors.black,
        );
        final custom = theme.copyWith(
          extensions: [
            ...theme.extensions.values.where(
              (e) => e.runtimeType != colors.runtimeType,
            ),
            colors,
          ],
        );
        await tester.pumpWidget(host(custom));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<OutlinedButton>(cancelFinder)
              .style!
              .foregroundColor!
              .resolve({}),
          Colors.orange,
        );
        expect(
          tester
              .widget<FilledButton>(confirmFinder)
              .style!
              .backgroundColor!
              .resolve({}),
          Colors.blue,
        );
        expect(
          tester
              .widget<FilledButton>(confirmFinder)
              .style!
              .foregroundColor!
              .resolve({}),
          Colors.black,
        );
        await tester.pumpWidget(host(custom, enabled: false));
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNull);
        await tester.tap(confirmFinder);
        expect(confirms, 1);
        for (final t in [0.0, 0.5, 1.0]) {
          final mixed = theme.semanticColors.lerp(colors, t);
          expect(
            mixed.swapCancel,
            Color.lerp(Colors.redAccent, Colors.orange, t),
          );
          expect(mixed.swapConfirm, Color.lerp(Colors.green, Colors.blue, t));
          expect(
            mixed.onSwapConfirm,
            Color.lerp(Colors.white, Colors.black, t),
          );
        }
      },
    );
  }
}
