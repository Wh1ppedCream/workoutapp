import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('record surfaces copy and interpolate independently', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
    final target = base.copyWith(
      workoutHandle: Colors.orange,
      firstRecordFill: 0.3,
      firstRecordBorder: 0.4,
      recordBadgeFill: 0.5,
      recordBadgeBorder: 0.6000000000000001,
      workoutCardCompleteFill: 0.4,
      workoutSetCompleteFill: 0.7,
      workoutChangeSetOutline: Colors.cyan,
    );
    expect(target.workoutHandle, Colors.orange);
    expect(target.copyWith().workoutHandle, Colors.orange);
    expect(base.firstRecordFill, 0.12);
    expect(target.firstRecordFill, 0.3);
    expect(target.copyWith().firstRecordFill, target.firstRecordFill);
    expect(base.firstRecordBorder, 0.72);
    expect(target.firstRecordBorder, 0.4);
    expect(target.copyWith().firstRecordBorder, target.firstRecordBorder);
    expect(base.recordBadgeFill, 0.14);
    expect(target.recordBadgeFill, 0.5);
    expect(target.copyWith().recordBadgeFill, target.recordBadgeFill);
    expect(base.recordBadgeBorder, 0.62);
    expect(target.recordBadgeBorder, 0.6000000000000001);
    expect(target.copyWith().recordBadgeBorder, target.recordBadgeBorder);
    expect(base.workoutCardCompleteFill, 24 / 255);
    expect(target.workoutCardCompleteFill, 0.4);
    expect(
      target.copyWith().workoutCardCompleteFill,
      target.workoutCardCompleteFill,
    );
    expect(base.workoutSetCompleteFill, 76 / 255);
    expect(target.workoutSetCompleteFill, 0.7);
    expect(
      target.copyWith().workoutSetCompleteFill,
      target.workoutSetCompleteFill,
    );
    expect(target.workoutChangeSetOutline, Colors.cyan);
    expect(
      target.copyWith().workoutChangeSetOutline,
      target.workoutChangeSetOutline,
    );
    for (final t in [0.0, 0.5, 1.0]) {
      final result = base.lerp(target, t);
      expect(
        result.workoutHandle,
        Color.lerp(base.workoutHandle, Colors.orange, t),
      );
      expect(
        result.firstRecordFill,
        closeTo(
          base.firstRecordFill +
              (target.firstRecordFill - base.firstRecordFill) * t,
          1e-9,
        ),
      );
      expect(
        result.firstRecordBorder,
        closeTo(
          base.firstRecordBorder +
              (target.firstRecordBorder - base.firstRecordBorder) * t,
          1e-9,
        ),
      );
      expect(
        result.recordBadgeFill,
        closeTo(
          base.recordBadgeFill +
              (target.recordBadgeFill - base.recordBadgeFill) * t,
          1e-9,
        ),
      );
      expect(
        result.recordBadgeBorder,
        closeTo(
          base.recordBadgeBorder +
              (target.recordBadgeBorder - base.recordBadgeBorder) * t,
          1e-9,
        ),
      );
      expect(
        result.workoutCardCompleteFill,
        closeTo(
          base.workoutCardCompleteFill +
              (target.workoutCardCompleteFill - base.workoutCardCompleteFill) *
                  t,
          1e-9,
        ),
      );
      expect(
        result.workoutSetCompleteFill,
        closeTo(
          base.workoutSetCompleteFill +
              (target.workoutSetCompleteFill - base.workoutSetCompleteFill) * t,
          1e-9,
        ),
      );
      expect(
        result.workoutChangeSetOutline,
        Color.lerp(base.workoutChangeSetOutline, Colors.cyan, t),
      );
    }
  });
  test('completion recipes retain Classic and interpolate independently', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final base = theme.surfaceTokens;
      expect(
        base.sessionSummary,
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      );
      expect(base.completionMetricFill, 0.15);
      expect(base.completionMetricBorder, 0.3);
      expect(base.completionSetFill, 0.2);
      expect(base.completionExerciseFill, 0.1);
      expect(base.completionExerciseBorder, 0.52);
      final target = base.copyWith(
        sessionSummary: Colors.orange,
        completionMetricFill: 0.6,
        completionMetricBorder: 0.65,
        completionSetFill: 0.7,
        completionExerciseFill: 0.75,
        completionExerciseBorder: 0.8,
      );
      expect(target.sessionSummary, Colors.orange);
      expect(target.copyWith().sessionSummary, Colors.orange);
      expect(target.completionMetricFill, 0.6);
      expect(
        target.copyWith().completionMetricFill,
        target.completionMetricFill,
      );
      expect(target.completionMetricBorder, 0.65);
      expect(
        target.copyWith().completionMetricBorder,
        target.completionMetricBorder,
      );
      expect(target.completionSetFill, 0.7);
      expect(target.copyWith().completionSetFill, target.completionSetFill);
      expect(target.completionExerciseFill, 0.75);
      expect(
        target.copyWith().completionExerciseFill,
        target.completionExerciseFill,
      );
      expect(target.completionExerciseBorder, 0.8);
      expect(
        target.copyWith().completionExerciseBorder,
        target.completionExerciseBorder,
      );
      for (final t in [0.0, 0.5, 1.0]) {
        final result = base.lerp(target, t);
        expect(
          result.sessionSummary,
          Color.lerp(base.sessionSummary, Colors.orange, t),
        );
        expect(
          result.completionMetricFill,
          closeTo(
            base.completionMetricFill +
                (target.completionMetricFill - base.completionMetricFill) * t,
            1e-9,
          ),
        );
        expect(
          result.completionMetricBorder,
          closeTo(
            base.completionMetricBorder +
                (target.completionMetricBorder - base.completionMetricBorder) *
                    t,
            1e-9,
          ),
        );
        expect(
          result.completionSetFill,
          closeTo(
            base.completionSetFill +
                (target.completionSetFill - base.completionSetFill) * t,
            1e-9,
          ),
        );
        expect(
          result.completionExerciseFill,
          closeTo(
            base.completionExerciseFill +
                (target.completionExerciseFill - base.completionExerciseFill) *
                    t,
            1e-9,
          ),
        );
        expect(
          result.completionExerciseBorder,
          closeTo(
            base.completionExerciseBorder +
                (target.completionExerciseBorder -
                        base.completionExerciseBorder) *
                    t,
            1e-9,
          ),
        );
      }
      expect(target.panelRaised, base.panelRaised);
    }
  });
  test(
    'workout surfaces preserve independent overrides and interpolate values',
    () {
      final base = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
      final target = base.copyWith(
        flowControl: const Color(0xFF123456),
        planFilter: const Color(0xFF275b6f),
        planDuration: const Color(0xFF3c8288),
        planGroup: const Color(0xFF51a9a1),
        metricChip: const Color(0xFF66d0ba),
        planActionBar: const Color(0xFF7bf7d3),
        optimizedAction: const Color(0xFF911eec),
      );
      expect(target.flowControl, const Color(0xFF123456));
      expect(target.copyWith().flowControl, target.flowControl);
      expect(target.planFilter, const Color(0xFF275b6f));
      expect(target.copyWith().planFilter, target.planFilter);
      expect(target.planDuration, const Color(0xFF3c8288));
      expect(target.copyWith().planDuration, target.planDuration);
      expect(target.planGroup, const Color(0xFF51a9a1));
      expect(target.copyWith().planGroup, target.planGroup);
      expect(target.metricChip, const Color(0xFF66d0ba));
      expect(target.copyWith().metricChip, target.metricChip);
      expect(target.planActionBar, const Color(0xFF7bf7d3));
      expect(target.copyWith().planActionBar, target.planActionBar);
      expect(target.optimizedAction, const Color(0xFF911eec));
      expect(target.copyWith().optimizedAction, target.optimizedAction);
      for (final t in [0.0, 0.25, 0.5, 1.0]) {
        final result = base.lerp(target, t);
        expect(
          result.flowControl,
          Color.lerp(base.flowControl, target.flowControl, t),
        );
        expect(
          result.planFilter,
          Color.lerp(base.planFilter, target.planFilter, t),
        );
        expect(
          result.planDuration,
          Color.lerp(base.planDuration, target.planDuration, t),
        );
        expect(
          result.planGroup,
          Color.lerp(base.planGroup, target.planGroup, t),
        );
        expect(
          result.metricChip,
          Color.lerp(base.metricChip, target.metricChip, t),
        );
        expect(
          result.planActionBar,
          Color.lerp(base.planActionBar, target.planActionBar, t),
        );
        expect(
          result.optimizedAction,
          Color.lerp(base.optimizedAction, target.optimizedAction, t),
        );
      }
      expect(target.card, base.card);
    },
  );

  test('editing roles preserve Classic and support independent overrides', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final base = theme.semanticColors;
      expect(base.editingActive, Colors.green);
      expect(base.editingInactive, Colors.grey);
      final target = base.copyWith(
        editingActive: Colors.blue,
        editingInactive: Colors.orange,
      );
      expect(target.editingActive, Colors.blue);
      expect(target.editingInactive, Colors.orange);
      expect(target.copyWith().editingActive, Colors.blue);
      expect(target.copyWith().editingInactive, Colors.orange);
      expect(target.workoutAction, base.workoutAction);
      for (final t in [0.0, 0.5, 1.0]) {
        final result = base.lerp(target, t);
        expect(result.editingActive, Color.lerp(Colors.green, Colors.blue, t));
        expect(
          result.editingInactive,
          Color.lerp(Colors.grey, Colors.orange, t),
        );
      }
    }
  });
}
