// File: lib/widgets/current_metrics_section.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/nutrition/measured_items_page.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/tonos_surface.dart';
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

class _ExpressiveMetricQuickCard extends StatelessWidget {
  const _ExpressiveMetricQuickCard({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final AppExpressiveDestinationTokens tokens;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 140,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceSelected,
          borderRadius: context.shapeTokens.healthTrendEntry,
          border: Border.all(
            color: tokens.outlineAccent.withValues(alpha: dark ? 0.32 : 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tokens.onSurfaceSelected.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: tokens.onSurfaceSelected,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the latest saved measurement values and opens the measurement logger.
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

    final savedMetrics = metrics.whereType<_CurrentMetric>().toList()
      ..sort(
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
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final expressiveTokens =
        context.usesExpressivePresentation &&
            destination?.family == AppExpressiveDestinationFamily.nutrition
        ? destination
        : null;
    final theme = Theme.of(context);

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: expressiveTokens?.supportingForeground,
                    fontWeight: expressiveTokens == null
                        ? null
                        : FontWeight.w800,
                  ),
                ),
              ),
              if (expressiveTokens != null)
                FilledButton.icon(
                  onPressed: _openMeasurementLogger,
                  style: FilledButton.styleFrom(
                    backgroundColor: expressiveTokens.surfaceSecondary,
                    foregroundColor: expressiveTokens.onSurfaceSecondary,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    strings.nutritionTrackMeasurement,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
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
                  expressiveTokens: expressiveTokens,
                  actionIcon: Icons.refresh_rounded,
                );
              }

              final metrics = snapshot.data ?? const <_CurrentMetric>[];
              if (metrics.isEmpty) {
                return _MetricsMessage(
                  title: strings.healthNoMeasurements,
                  body: strings.healthNoMeasurementsBody,
                  actionLabel: strings.healthCreateMetric,
                  onAction: _openMeasurementLogger,
                  expressiveTokens: expressiveTokens,
                  actionIcon: Icons.add_rounded,
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final metric in metrics)
                      Padding(
                        padding: EdgeInsets.only(
                          right: expressiveTokens == null ? 16 : 10,
                        ),
                        child: expressiveTokens != null
                            ? _ExpressiveMetricQuickCard(
                                label: _metricLabel(metric.definition, strings),
                                value: _formatMeasurement(
                                  metric.measurement,
                                  Localizations.localeOf(context),
                                ),
                                tokens: expressiveTokens,
                              )
                            : MetricItem(
                                color: _metricColor(
                                  context,
                                  metric.definition.type,
                                ),
                                label: _metricLabel(metric.definition, strings),
                                value: _formatMeasurement(
                                  metric.measurement,
                                  Localizations.localeOf(context),
                                ),
                                recordedOn: LocalizedFormatters.monthDay(
                                  metric.measurement.calendarDay
                                      .toLocalDateTime(),
                                  Localizations.localeOf(context),
                                ),
                              ),
                      ),
                  ],
                ),
              );
            },
          ),
          Divider(
            height: 32,
            color: expressiveTokens?.outlineAccent.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.22 : 0.16,
            ),
          ),
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
    this.expressiveTokens,
    this.actionIcon = Icons.arrow_forward_rounded,
  });

  final String title;
  final String? body;
  final String actionLabel;
  final VoidCallback onAction;
  final AppExpressiveDestinationTokens? expressiveTokens;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    if (expressiveTokens != null) {
      final tokens = expressiveTokens!;
      final dark = Theme.of(context).brightness == Brightness.dark;
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.surfaceSelected,
            borderRadius: context.shapeTokens.healthTrendCard,
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: dark ? 0.34 : 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tokens.outlineAccent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: tokens.onSurfaceSelected,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: tokens.onSurfaceSelected,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (body != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            body!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: tokens.onSurfaceSelected.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.icon(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.actionPrimary,
                    foregroundColor: tokens.onActionPrimary,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(actionIcon, size: 18),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TonosSurfaceTheme(
        surface: context.surfaceTokens.panelRaised,
        child: Builder(
          builder: (surfaceContext) => TonosSurface(
            variant: TonosSurfaceVariant.panelRaised,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(surfaceContext).textTheme.titleSmall,
                ),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    body!,
                    style: Theme.of(surfaceContext).textTheme.bodySmall,
                  ),
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
          ),
        ),
      ),
    );
  }
}

Color _metricColor(BuildContext context, MeasurementType type) {
  if (context.usesNeoPresentation) {
    final data = context.dataVisualizationTokens;
    return switch (type) {
      MeasurementType.BodyWeight => data.positive,
      MeasurementType.Height => data.secondarySeries,
      MeasurementType.Waist || MeasurementType.Hip => data.primarySeries,
      MeasurementType.Chest ||
      MeasurementType.Shoulder ||
      MeasurementType.Arm => data.tertiarySeries,
      _ => data.neutral,
    };
  }

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
  final fractionDigits = measurement.value == measurement.value.roundToDouble()
      ? 0
      : 1;
  final value = LocalizedFormatters.number(
    measurement.value,
    locale,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  );
  return '$value ${measurement.unit}'.trim();
}
