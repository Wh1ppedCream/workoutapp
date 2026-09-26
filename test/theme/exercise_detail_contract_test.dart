import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';

String _section(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end, startIndex + start.length);
  if (startIndex < 0 || endIndex < 0) {
    throw StateError('Could not isolate $start to $end');
  }
  return source.substring(startIndex, endIndex);
}

void main() {
  test(
    'C2 detail sections use focused roles and preserve state boundaries',
    () {
      final source =
          File('lib/widgets/exercise_detail_sheet.dart').readAsStringSync();
      final detailCard = _section(
        source,
        'Widget _buildDetailCard',
        'Widget _buildDetailLabel',
      );
      final detailTag = _section(
        source,
        'Widget _buildDetailTag',
        'Widget _buildGuideEntry',
      );
      final timeframe = _section(
        source,
        'Widget _buildMetricsTimeframePicker',
        'Widget _buildMetricResults',
      );
      final recordsTab = _section(
        source,
        'Widget _buildRecordsTab',
        'Widget _buildSheetDragHandle',
      );
      final historyCard = _section(
        source,
        'class _ExerciseHistorySessionCard',
        'class _ExerciseHistorySetRow',
      );
      final historySet = _section(
        source,
        'class _ExerciseHistorySetRow',
        'class _MetricSummaryCard',
      );
      final metricCard = _section(
        source,
        'class _MetricSummaryCard',
        'class _RepBestMetricsList',
      );
      final metricList = _section(
        source,
        'class _RepBestMetricsList',
        'class _CompactRepMetricValue',
      );
      final stateCard = _section(
        source,
        'class _MetricsStateCard',
        'List<_ExerciseRecordPoint> _buildRecordTrendPoints',
      );
      final chart = _section(
        source,
        'class _ExerciseRecordTrendChart',
        'class _RecordLegendDot',
      );
      final legend = _section(
        source,
        'class _RecordLegendDot',
        'class _RecordChartBounds',
      );

      expect(detailCard, contains('surfaces.exerciseDetailCard'));
      expect(detailCard, contains('shapes.exerciseDetailCard'));
      expect(detailCard, contains('motion.quick'));
      expect(detailTag, contains('surfaces.exerciseDetailTagFillOpacity'));
      expect(detailTag, contains('surfaces.exerciseDetailTagBorderOpacity'));
      expect(detailTag, contains('shapes.exerciseDetailTag'));
      expect(timeframe, contains('surfaces.exerciseDetailTimeframe'));
      expect(
        timeframe,
        contains('surfaces.exerciseDetailTimeframeBorderOpacity'),
      );
      expect(timeframe, contains('motion.exerciseDetailSelection'));
      expect(timeframe, contains('shapes.exerciseDetailTimeframeOption'));
      expect(
        recordsTab,
        contains('surfaces.exerciseDetailLoadMoreBorderOpacity'),
      );
      expect(recordsTab, contains('shapes.exerciseDetailLoadMore'));
      expect(recordsTab, contains('_exerciseRecordActualSeriesColor'));
      expect(recordsTab, contains('_exerciseRecordEstimatedSeriesColor'));
      expect(historyCard, contains('surfaces.exerciseDetailRecord'));
      expect(historyCard, contains('shapes.exerciseDetailRecord'));
      expect(
        historySet,
        contains('surfaces.exerciseDetailRecordSetFillOpacity'),
      );
      expect(metricCard, contains('surfaces.exerciseDetailMetricFillOpacity'));
      expect(metricCard, contains('shapes.exerciseDetailMetric'));
      expect(metricList, contains('surfaces.exerciseDetailMetricList'));
      expect(
        metricList,
        contains('surfaces.exerciseDetailMetricRepFillOpacity'),
      );
      expect(stateCard, contains('surfaces.exerciseDetailState'));
      expect(stateCard, contains('shapes.exerciseDetailState'));
      expect(chart, contains('surfaces.exerciseDetailChart'));
      expect(chart, contains('surfaces.exerciseDetailChartGridOpacity'));
      expect(chart, contains('surfaces.exerciseDetailTooltip'));
      expect(chart, contains('motion.exerciseDetailSelection'));
      expect(chart, contains('_exerciseRecordActualSeriesColor'));
      expect(chart, contains('_exerciseRecordEstimatedSeriesColor'));
      expect(source, contains('tonosEstimatedOneRmForSurface'));
      expect(source, contains('tonosPrimarySeriesForSurface'));
      expect(chart, isNot(contains('Colors.green.shade400')));
      expect(source, isNot(contains('Colors.green.shade400')));
      expect(legend, contains('tonosForegroundForSurface'));
      expect(legend, contains('surfaces.sheet'));
      expect(legend, contains('theme.shapeTokens.outlineWidth'));

      expect(source, contains('DefaultTabController'));
      expect(source, contains('TabBarView'));
      expect(source, contains('NeverScrollableScrollPhysics'));
      expect(source, contains('_olderHistory'));
      expect(source, contains('exerciseDetailNoBestLifts'));
      final handle = _section(
        source,
        'Widget _buildSheetDragHandle',
        'Widget build(BuildContext context)',
      );
      expect(handle, contains('exerciseDetailHandleOpacity'));
      expect(handle, isNot(contains('workoutHandle')));
      expect(source, contains('effects.exerciseDetailSheetElevation'));

      expect(detailCard, isNot(contains('surfaceContainerHighest')));
      expect(detailTag, isNot(contains('alpha: 0.13')));
      expect(timeframe, isNot(contains('alpha: 0.58')));
      expect(recordsTab, isNot(contains('alpha: 0.55')));
      expect(historyCard, isNot(contains('alpha: 0.42')));
      expect(metricList, isNot(contains('alpha: 0.44')));
      expect(stateCard, isNot(contains('alpha: 0.44')));
      expect(chart, isNot(contains('alpha: 0.26')));
    },
  );

  test('C2 surface roles preserve the Classic recipes', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final surfaces = theme.surfaceTokens;
      final scheme = theme.colorScheme;

      expect(
        surfaces.exerciseDetailCard,
        scheme.surfaceContainerHighest.withValues(alpha: 0.52),
      );
      expect(
        surfaces.exerciseDetailTimeframe,
        scheme.surfaceContainerHighest.withValues(alpha: 0.58),
      );
      expect(
        surfaces.exerciseDetailRecord,
        scheme.surfaceContainerHighest.withValues(alpha: 0.42),
      );
      expect(
        surfaces.exerciseDetailMetricList,
        scheme.surfaceContainerHighest.withValues(alpha: 0.44),
      );
      expect(
        surfaces.exerciseDetailState,
        scheme.surfaceContainerHighest.withValues(alpha: 0.44),
      );
      expect(
        surfaces.exerciseDetailChart,
        scheme.surfaceContainerHighest.withValues(alpha: 0.26),
      );
      expect(
        surfaces.exerciseDetailChartEmpty,
        scheme.surfaceContainerHighest.withValues(alpha: 0.28),
      );
      expect(
        surfaces.exerciseDetailTooltip,
        scheme.surfaceContainerHighest.withValues(alpha: 0.96),
      );
      expect(surfaces.exerciseDetailCardBorderOpacity, 0.32);
      expect(surfaces.exerciseDetailHandleOpacity, 0.55);
      expect(surfaces.exerciseDetailIconFillOpacity, 0.16);
      expect(surfaces.exerciseDetailTagFillOpacity, 0.13);
      expect(surfaces.exerciseDetailTagBorderOpacity, 0.28);
      expect(surfaces.exerciseDetailTimeframeBorderOpacity, 0.6);
      expect(surfaces.exerciseDetailMetricFillOpacity, 0.12);
      expect(surfaces.exerciseDetailMetricBorderOpacity, 0.38);
      expect(surfaces.exerciseDetailRangeFillOpacity, 0.12);
      expect(surfaces.exerciseDetailRecordBorderOpacity, 0.36);
      expect(surfaces.exerciseDetailRecordIconFillOpacity, 0.15);
      expect(surfaces.exerciseDetailRecordActionFillOpacity, 0.13);
      expect(surfaces.exerciseDetailRecordSetFillOpacity, 0.18);
      expect(surfaces.exerciseDetailLoadMoreBorderOpacity, 0.55);
      expect(surfaces.exerciseDetailMetricListBorderOpacity, 0.65);
      expect(surfaces.exerciseDetailMetricRepFillOpacity, 0.15);
      expect(surfaces.exerciseDetailMetricListDividerOpacity, 0.58);
      expect(surfaces.exerciseDetailStateBorderOpacity, 0.65);
      expect(surfaces.exerciseDetailChartBorderOpacity, 0.6);
      expect(surfaces.exerciseDetailChartGridOpacity, 0.42);
      expect(surfaces.exerciseDetailChartAreaOpacity, 0.08);
    }
  });

  test('C2 roles copy and interpolate independently', () {
    final surfaces =
        AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
    final target = surfaces.copyWith(
      exerciseDetailCard: const Color(0xFF112233),
      exerciseDetailTimeframe: const Color(0xFF223344),
      exerciseDetailRecord: const Color(0xFF334455),
      exerciseDetailMetricList: const Color(0xFF445566),
      exerciseDetailState: const Color(0xFF556677),
      exerciseDetailChart: const Color(0xFF667788),
      exerciseDetailChartEmpty: const Color(0xFF778899),
      exerciseDetailTooltip: const Color(0xFF8899AA),
      exerciseDetailCardBorderOpacity: 0.42,
      exerciseDetailHandleOpacity: 0.75,
      exerciseDetailIconFillOpacity: 0.26,
      exerciseDetailTagFillOpacity: 0.23,
      exerciseDetailTagBorderOpacity: 0.38,
      exerciseDetailTimeframeBorderOpacity: 0.7,
      exerciseDetailMetricFillOpacity: 0.22,
      exerciseDetailMetricBorderOpacity: 0.48,
      exerciseDetailRangeFillOpacity: 0.22,
      exerciseDetailRecordBorderOpacity: 0.46,
      exerciseDetailRecordIconFillOpacity: 0.25,
      exerciseDetailRecordActionFillOpacity: 0.23,
      exerciseDetailRecordSetFillOpacity: 0.28,
      exerciseDetailLoadMoreBorderOpacity: 0.65,
      exerciseDetailMetricListBorderOpacity: 0.75,
      exerciseDetailMetricRepFillOpacity: 0.25,
      exerciseDetailMetricListDividerOpacity: 0.68,
      exerciseDetailStateBorderOpacity: 0.75,
      exerciseDetailChartBorderOpacity: 0.7,
      exerciseDetailChartGridOpacity: 0.52,
      exerciseDetailChartAreaOpacity: 0.18,
    );
    final midpoint = surfaces.lerp(target, 0.5);
    expect(surfaces.copyWith().exerciseDetailHandleOpacity, 0.55);
    expect(target.exerciseDetailHandleOpacity, 0.75);
    expect(midpoint.exerciseDetailHandleOpacity, closeTo(0.65, 1e-9));

    expect(surfaces.copyWith().exerciseDetailCard, surfaces.exerciseDetailCard);
    expect(
      midpoint.exerciseDetailCard,
      Color.lerp(surfaces.exerciseDetailCard, target.exerciseDetailCard, 0.5),
    );
    expect(midpoint.exerciseDetailCardBorderOpacity, closeTo(0.37, 1e-9));
    expect(midpoint.exerciseDetailChartAreaOpacity, closeTo(0.13, 1e-9));
    expect(
      midpoint.exerciseDetailMetricListDividerOpacity,
      closeTo(0.63, 1e-9),
    );
    expect(midpoint.exerciseDetailRecordActionFillOpacity, closeTo(0.18, 1e-9));
    expect(midpoint.exerciseDetailTagBorderOpacity, closeTo(0.33, 1e-9));
    expect(
      midpoint.exerciseDetailTooltip,
      Color.lerp(
        surfaces.exerciseDetailTooltip,
        target.exerciseDetailTooltip,
        0.5,
      ),
    );
  });

  test('C2 shape, motion, and elevation roles preserve Classic values', () {
    final shapes = AppShapeTokens.classic;
    expect(
      shapes.exerciseDetailSheet,
      const BorderRadius.vertical(top: Radius.circular(16)),
    );
    expect(shapes.exerciseDetailCard, BorderRadius.circular(16));
    expect(shapes.exerciseDetailIcon, BorderRadius.circular(10));
    expect(shapes.exerciseDetailTag, BorderRadius.circular(9));
    expect(shapes.exerciseDetailMetric, BorderRadius.circular(15));
    expect(shapes.exerciseDetailTimeframe, BorderRadius.circular(15));
    expect(shapes.exerciseDetailTimeframeOption, BorderRadius.circular(11));
    expect(shapes.exerciseDetailRecord, BorderRadius.circular(15));
    expect(shapes.exerciseDetailRecordAction, BorderRadius.circular(9));
    expect(shapes.exerciseDetailLoadMore, BorderRadius.circular(13));
    expect(shapes.exerciseDetailMetricRep, BorderRadius.circular(11));
    expect(shapes.exerciseDetailState, BorderRadius.circular(18));
    expect(shapes.exerciseDetailChart, BorderRadius.circular(18));
    expect(shapes.exerciseDetailChartTooltip, BorderRadius.circular(10));

    expect(
      AppMotionTokens.classic.exerciseDetailSelection,
      const Duration(milliseconds: 160),
    );
    expect(
      AppEffectTokens.classic(Brightness.light).exerciseDetailSheetElevation,
      12,
    );
  });
}
