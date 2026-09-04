// File: lib/widgets/current_metrics_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/nutrition/measured_items_page.dart';
import '../utils/localized_formatters.dart';

class _CurrentMetric {
  const _CurrentMetric({required this.definition, required this.measurement});

  final MeasurementDefinition definition;
  final Measurement measurement;
}

/// A persisted measurement value and its most recent recording date.
class MetricItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String recordedOn;

  const MetricItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.recordedOn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
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
          const SizedBox(height: 2),
          Text(
            recordedOn,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows “Current Metrics” with a date, dynamic metric tiles, and add button
class CurrentMetricsSection extends StatefulWidget {
  const CurrentMetricsSection({super.key, this.refreshToken = 0});

  final int refreshToken;

  @override
  CurrentMetricsSectionState createState() => CurrentMetricsSectionState();
}

class CurrentMetricsSectionState extends State<CurrentMetricsSection>
    with AutomaticKeepAliveClientMixin<CurrentMetricsSection> {
  AppRepository get _repo => context.read<AppRepository>();

  late Future<List<_CurrentMetric>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _loadMetrics();
  }

  @override
  void didUpdateWidget(covariant CurrentMetricsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _reload();
  }

  void _reload() {
    setState(() {
      _metricsFuture = _loadMetrics();
    });
  }

  Future<List<_CurrentMetric>> _loadMetrics() async {
    await _repo.ensureDefaultMeasurementDefinitions();
    final definitions = await _repo.fetchClassMeasurementDefinitions();
    final metrics = await Future.wait(
      definitions.map((definition) async {
        final entries = await _repo.fetchClassMeasurementsForDefinition(
          definition.id,
        );
        if (entries.isEmpty) return null;

        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return _CurrentMetric(
          definition: definition,
          measurement: entries.first,
        );
      }),
    );

    final savedMetrics =
        metrics.whereType<_CurrentMetric>().toList()..sort(
          (a, b) => b.measurement.timestamp.compareTo(a.measurement.timestamp),
        );
    return savedMetrics;
  }

  Future<void> _openMeasurementLogger() async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const MeasuredItemsPage()));
    if (changed == true && mounted) _reload();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final strings = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.dashboardCurrentMetrics,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _openMeasurementLogger,
                icon: const Icon(Icons.add, size: 18),
                label: Text(strings.nutritionTrackMeasurement),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<_CurrentMetric>>(
            future: _metricsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 96,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _MetricsMessage(
                  title: strings.healthUnableToLoad,
                  actionLabel: strings.commonRetry,
                  onAction: _reload,
                );
              }

              final metrics = snapshot.data ?? const <_CurrentMetric>[];
              if (metrics.isEmpty) {
                return _MetricsMessage(
                  title: strings.healthNoMeasurements,
                  body: strings.healthNoMeasurementsBody,
                  actionLabel: strings.healthCreateMetric,
                  onAction: _openMeasurementLogger,
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final metric in metrics)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: MetricItem(
                          color: _metricColor(metric.definition.type),
                          label: _metricLabel(metric.definition, strings),
                          value: _formatMeasurement(
                            metric.measurement,
                            Localizations.localeOf(context),
                          ),
                          recordedOn: LocalizedFormatters.monthDay(
                            metric.measurement.calendarDay.toLocalDateTime(),
                            Localizations.localeOf(context),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}

class _MetricsMessage extends StatelessWidget {
  const _MetricsMessage({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.body,
  });

  final String title;
  final String? body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (body != null) ...[
            const SizedBox(height: 4),
            Text(body!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

Color _metricColor(MeasurementType type) {
  return switch (type) {
    MeasurementType.BodyWeight => Colors.green,
    MeasurementType.Height => Colors.blue,
    MeasurementType.Waist || MeasurementType.Hip => Colors.purple,
    MeasurementType.Chest ||
    MeasurementType.Shoulder ||
    MeasurementType.Arm => Colors.orange,
    _ => Colors.teal,
  };
}

String _metricLabel(
  MeasurementDefinition definition,
  AppLocalizations strings,
) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => strings.measurementWeight,
    MeasurementType.Height => strings.measurementHeight,
    MeasurementType.Forearm => strings.measurementForearm,
    MeasurementType.Arm => strings.measurementArm,
    MeasurementType.Neck => strings.measurementNeck,
    MeasurementType.Shoulder => strings.measurementShoulders,
    MeasurementType.Chest => strings.measurementChest,
    MeasurementType.Waist => strings.measurementWaist,
    MeasurementType.Hip => strings.measurementHips,
    MeasurementType.Thigh => strings.measurementThigh,
    MeasurementType.Calf => strings.measurementCalves,
    MeasurementType.Custom => definition.name,
  };
}

String _formatMeasurement(Measurement measurement, Locale locale) {
  final fractionDigits =
      measurement.value == measurement.value.roundToDouble() ? 0 : 1;
  final value = LocalizedFormatters.number(
    measurement.value,
    locale,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  );
  return '$value ${measurement.unit}'.trim();
}
