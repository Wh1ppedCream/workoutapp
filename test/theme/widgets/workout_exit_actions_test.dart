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
      '${theme.brightness} workout actions preserve Classic and overrides',
      (tester) async {
        var changes = 0;
        var saves = 0;
        var discards = 0;
        Widget host(ThemeData data, {bool enabled = true}) => MaterialApp(
          theme: data,
          home: Scaffold(
            body: Column(
              children: [
                WorkoutAddChangeSetAction(
                  label: 'Add change set',
                  onTap: () => changes++,
                ),
                WorkoutExitAction(
                  label: 'Save',
                  onPressed: enabled ? () => saves++ : null,
                ),
                WorkoutExitAction(
                  label: 'Discard',
                  discard: true,
                  onPressed: enabled ? () => discards++ : null,
                ),
              ],
            ),
          ),
        );
        final outlined = find.byWidgetPredicate((w) => w is OutlinedButton);
        final filled = find.byWidgetPredicate((w) => w is FilledButton);
        BoxDecoration decoration() =>
            tester
                    .widget<Container>(
                      find.descendant(
                        of: find.byType(WorkoutAddChangeSetAction),
                        matching: find.byType(Container),
                      ),
                    )
                    .decoration!
                as BoxDecoration;

        await tester.pumpWidget(host(theme));
        expect(decoration().border, Border.all(color: Colors.blueAccent));
        expect(decoration().borderRadius, BorderRadius.circular(4));
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WorkoutAddChangeSetAction),
            matching: find.byType(Container),
          ),
        );
        expect(
          container.padding,
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        );
        final discard = tester.widget<OutlinedButton>(outlined);
        expect(
          discard.style!.foregroundColor!.resolve({}),
          theme.colorScheme.error,
        );
        expect(
          discard.style!.side!.resolve({}),
          BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.7)),
        );
        expect(
          discard.style!.minimumSize!.resolve({}),
          const Size.fromHeight(48),
        );
        final save = tester.widget<FilledButton>(filled);
        expect(save.style!.minimumSize!.resolve({}), const Size.fromHeight(48));
        expect(save.style!.backgroundColor, isNull);
        expect(save.style!.shape, isNull);
        expect(tester.widget<Icon>(find.byIcon(Icons.save_outlined)).size, 18);
        expect(tester.widget<Icon>(find.byIcon(Icons.delete_outline)).size, 18);
        await tester.tap(find.text('Add change set'));
        await tester.tap(filled);
        await tester.tap(outlined);
        expect([changes, saves, discards], [1, 1, 1]);

        final semantic = theme.semanticColors.copyWith(
          workoutAddChangeSet: Colors.orange,
        );
        final shapes = theme.shapeTokens.copyWith(
          workoutAddChangeSet: BorderRadius.circular(10),
        );
        final surfaces = theme.surfaceTokens.copyWith(
          workoutDiscardBorder: 0.3,
        );
        final custom = theme.copyWith(
          extensions: [
            ...theme.extensions.values.where(
              (e) =>
                  e.runtimeType != semantic.runtimeType &&
                  e.runtimeType != shapes.runtimeType &&
                  e.runtimeType != surfaces.runtimeType,
            ),
            semantic,
            shapes,
            surfaces,
          ],
        );
        await tester.pumpWidget(host(custom, enabled: false));
        await tester.pumpAndSettle();
        expect(decoration().border, Border.all(color: Colors.orange));
        expect(decoration().borderRadius, BorderRadius.circular(10));
        expect(
          tester.widget<OutlinedButton>(outlined).style!.side!.resolve({}),
          BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
        );
        expect(tester.widget<OutlinedButton>(outlined).onPressed, isNull);
        expect(tester.widget<FilledButton>(filled).onPressed, isNull);
        await tester.tap(filled);
        await tester.tap(outlined);
        expect([saves, discards], [1, 1]);
        for (final t in [0.0, 0.5, 1.0]) {
          expect(
            theme.semanticColors.lerp(semantic, t).workoutAddChangeSet,
            Color.lerp(Colors.blueAccent, Colors.orange, t),
          );
          expect(
            theme.shapeTokens.lerp(shapes, t).workoutAddChangeSet,
            BorderRadius.lerp(
              BorderRadius.circular(4),
              BorderRadius.circular(10),
              t,
            ),
          );
          expect(
            theme.surfaceTokens.lerp(surfaces, t).workoutDiscardBorder,
            closeTo(0.7 + (0.3 - 0.7) * t, 0.000001),
          );
        }
      },
    );
  }
}
