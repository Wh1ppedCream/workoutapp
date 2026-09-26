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
      '${theme.brightness} swap visuals preserve Classic and respond to themes',
      (tester) async {
        var value = false;
        var changes = 0;
        Widget host(ThemeData data, {bool enabled = true}) => MaterialApp(
          theme: data,
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    children: [
                      const WorkoutMatchBadge(label: '92% match'),
                      const WorkoutMatchMarker(),
                      WorkoutEquipmentFilter(
                        label: 'Profile equipment',
                        value: value,
                        enabled: enabled,
                        onChanged:
                            (next) => setState(() {
                              value = next;
                              changes++;
                            }),
                      ),
                    ],
                  ),
            ),
          ),
        );
        Container container(Type type) => tester.widget<Container>(
          find
              .descendant(
                of: find.byType(type),
                matching: find.byType(Container),
              )
              .first,
        );
        BoxDecoration decoration(Type type) =>
            container(type).decoration! as BoxDecoration;

        await tester.pumpWidget(host(theme));
        expect(decoration(WorkoutMatchBadge).color, Colors.green.withAlpha(30));
        expect(
          decoration(WorkoutMatchBadge).border,
          Border.all(color: Colors.green.withAlpha(110)),
        );
        expect(
          decoration(WorkoutMatchBadge).borderRadius,
          BorderRadius.circular(999),
        );
        expect(
          container(WorkoutMatchBadge).padding,
          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        );
        final label = tester.widget<Text>(find.text('92% match'));
        expect(label.style!.color, Colors.green);
        expect(label.style!.fontSize, 10);
        expect(label.style!.height, 1);
        expect(label.style!.fontWeight, FontWeight.w700);
        expect(decoration(WorkoutMatchMarker).color, Colors.green);
        expect(decoration(WorkoutMatchMarker).shape, BoxShape.circle);
        expect(
          tester.getSize(find.byType(WorkoutMatchMarker)),
          const Size(6, 6),
        );
        expect(
          decoration(WorkoutEquipmentFilter).color,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        );
        expect(
          decoration(WorkoutEquipmentFilter).border,
          Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        );
        expect(
          decoration(WorkoutEquipmentFilter).borderRadius,
          BorderRadius.circular(16),
        );
        expect(
          container(WorkoutEquipmentFilter).padding,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(value, isTrue);
        expect(changes, 1);

        final semantic = theme.semanticColors.copyWith(
          swapMatch: Colors.orange,
        );
        final surfaces = theme.surfaceTokens.copyWith(
          swapMatchFill: 0.4,
          swapMatchBorder: 0.8,
          swapFilterBorder: 0.25,
          planFilter: Colors.cyan,
        );
        final shapes = theme.shapeTokens.copyWith(
          pill: BorderRadius.circular(12),
          card: BorderRadius.circular(20),
        );
        final custom = theme.copyWith(
          extensions: [
            ...theme.extensions.values.where(
              (e) =>
                  e.runtimeType != semantic.runtimeType &&
                  e.runtimeType != surfaces.runtimeType &&
                  e.runtimeType != shapes.runtimeType,
            ),
            semantic,
            surfaces,
            shapes,
          ],
        );
        await tester.pumpWidget(host(custom, enabled: false));
        await tester.pumpAndSettle();
        expect(
          decoration(WorkoutMatchBadge).color,
          Colors.orange.withValues(alpha: 0.4),
        );
        expect(
          decoration(WorkoutMatchBadge).border,
          Border.all(color: Colors.orange.withValues(alpha: 0.8)),
        );
        expect(
          decoration(WorkoutMatchBadge).borderRadius,
          BorderRadius.circular(12),
        );
        expect(decoration(WorkoutMatchMarker).color, Colors.orange);
        expect(decoration(WorkoutEquipmentFilter).color, Colors.cyan);
        expect(
          decoration(WorkoutEquipmentFilter).borderRadius,
          BorderRadius.circular(20),
        );
        expect(
          decoration(WorkoutEquipmentFilter).border,
          Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        );
        expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
        expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
        expect(
          tester.widget<Text>(find.text('Profile equipment')).style!.color,
          theme.colorScheme.onSurfaceVariant,
        );
        await tester.tap(find.byType(Switch));
        expect(changes, 1);

        for (final t in [0.0, 0.5, 1.0]) {
          expect(
            theme.semanticColors.lerp(semantic, t).swapMatch,
            Color.lerp(Colors.green, Colors.orange, t),
          );
          final mixed = theme.surfaceTokens.lerp(surfaces, t);
          expect(
            mixed.swapMatchFill,
            closeTo(30 / 255 + (0.4 - 30 / 255) * t, 0.000001),
          );
          expect(
            mixed.swapMatchBorder,
            closeTo(110 / 255 + (0.8 - 110 / 255) * t, 0.000001),
          );
          expect(
            mixed.swapFilterBorder,
            closeTo(0.55 + (0.25 - 0.55) * t, 0.000001),
          );
        }
      },
    );
  }
}
