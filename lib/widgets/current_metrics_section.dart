// File: lib/widgets/current_metrics_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/theme_extensions.dart';

enum _MetricKind { visualBodyFat, waist, hips, custom }

/// Data holder for a metric tile
class _MetricData {
  final Color color;
  final _MetricKind kind;
  final String value;

  _MetricData({required this.color, required this.kind, required this.value});
}

/// A single dot + value + label
class MetricItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const MetricItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Shows “Current Metrics” with a date, dynamic metric tiles, and add button
class CurrentMetricsSection extends StatefulWidget {
  const CurrentMetricsSection({super.key});

  @override
  CurrentMetricsSectionState createState() => CurrentMetricsSectionState();
}

class CurrentMetricsSectionState extends State<CurrentMetricsSection>
    with AutomaticKeepAliveClientMixin<CurrentMetricsSection> {
  final DateTime _lastMeasured = DateTime.now();
  final int _daysAgo = 0;

  final List<_MetricData> _metrics = [
    _MetricData(
      color: Colors.green,
      kind: _MetricKind.visualBodyFat,
      value: '26.0 %',
    ),
    _MetricData(color: Colors.blue, kind: _MetricKind.waist, value: '27 in'),
    _MetricData(color: Colors.purple, kind: _MetricKind.hips, value: '36 in'),
  ];

  void _addMetric() {
    setState(() {
      _metrics.add(
        _MetricData(
          color: Colors.orange,
          kind: _MetricKind.custom,
          value: '123 u',
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final strings = AppLocalizations.of(context);
    final fmtDate = DateFormat.Md(strings.localeName).format(_lastMeasured);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.dashboardCurrentMetrics,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(fmtDate, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._metrics.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: MetricItem(
                      color: m.color,
                      label: _metricLabel(m.kind, strings),
                      value: m.value,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _addMetric,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.metricAddBorderColor!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: colors.metricAddIconColor!,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.dashboardDaysAgo(_daysAgo),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.45),
              ),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  String _metricLabel(_MetricKind kind, AppLocalizations strings) {
    return switch (kind) {
      _MetricKind.visualBodyFat => strings.dashboardVisualBodyFat,
      _MetricKind.waist => strings.measurementWaist,
      _MetricKind.hips => strings.measurementHips,
      _MetricKind.custom => strings.dashboardNewMetric,
    };
  }
}
