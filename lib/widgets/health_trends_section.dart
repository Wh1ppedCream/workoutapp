import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../services/tutorial_state_store.dart';
import '../services/measurement_validation.dart';
import '../services/safe_failure.dart';
import '../theme/tokens/app_data_visualization_tokens.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_dialog.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/app_test_keys.dart';
import '../utils/localized_formatters.dart';
import 'guided_tutorial_overlay.dart';
import 'safe_error_view.dart';

Widget _withHealthCardForeground(
  BuildContext context,
  Widget child, {
  Color? surface,
}) {
  return TonosSurfaceTheme(
    surface: surface ?? _healthTrendCardSurface(context),
    child: child,
  );
}

Color _expressiveHealthTrendSurface(
  BuildContext context, {
  bool alternate = false,
}) {
  final destination = Theme.of(context)
      .extension<AppExpressiveDestinationTokens>();
  if (destination?.family == AppExpressiveDestinationFamily.profile) {
    return context.progressColors.healthCard;
  }

  final tokens = Theme.of(context).extension<AppExpressiveTrainTokens>()!;
  if (destination?.family == AppExpressiveDestinationFamily.progress &&
      !alternate) {
    return context.progressColors.healthCard;
  }
  return alternate ? tokens.creationSurface : tokens.activePlansSurface;
}

Color _healthTrendCardSurface(BuildContext context) {
  if (context.usesNeoPresentation) {
    return context.surfaceTokens.catalogSelection;
  }
  if (context.usesExpressivePresentation) {
    return context.progressColors.healthCard;
  }
  return context.progressColors.healthCard;
}

enum _MeasurementDetailRole { focal, analytical, history, dialog }

AppExpressiveDestinationTokens? _progressDetailTokens(BuildContext context) {
  if (context.usesExpressivePresentation) {
    final tokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    if (tokens?.family == AppExpressiveDestinationFamily.progress) {
      return tokens;
    }
  }
  return null;
}

Color _measurementDetailSurface(
  BuildContext context, {
  _MeasurementDetailRole role = _MeasurementDetailRole.history,
}) {
  final destination = _progressDetailTokens(context);
  if (destination != null) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return switch (role) {
      _MeasurementDetailRole.focal => destination.surfacePrimary,
      _MeasurementDetailRole.analytical =>
        isLight
            ? Color.lerp(
                destination.surfaceSecondary,
                destination.pageCanvas,
                0.28,
              )!
            : destination.surfaceSecondary,
      _MeasurementDetailRole.history => Color.alphaBlend(
        destination.surfaceAccent.withValues(alpha: 0.42),
        destination.pageCanvas,
      ),
      _MeasurementDetailRole.dialog =>
        isLight
            ? Color.lerp(
                destination.pageCanvas,
                destination.surfaceTertiary,
                0.30,
              )!
            : destination.surfaceTertiary,
    };
  }
  return _healthTrendCardSurface(context);
}

Color _measurementDetailForeground(
  BuildContext context, {
  _MeasurementDetailRole role = _MeasurementDetailRole.history,
}) {
  final destination = _progressDetailTokens(context);
  if (destination != null) {
    return switch (role) {
      _MeasurementDetailRole.focal => destination.onSurfacePrimary,
      _MeasurementDetailRole.analytical => destination.onSurfaceSecondary,
      _MeasurementDetailRole.history => destination.onSurfaceAccent,
      _MeasurementDetailRole.dialog => destination.supportingForeground,
    };
  }
  return Theme.of(context).colorScheme.onSurface;
}

Color _measurementDetailSupportingForeground(
  BuildContext context, {
  _MeasurementDetailRole role = _MeasurementDetailRole.history,
}) {
  final destination = _progressDetailTokens(context);
  if (destination != null) {
    return _measurementDetailForeground(
      context,
      role: role,
    ).withValues(alpha: 0.82);
  }
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

Widget _withMeasurementDetailSurfaceTheme(
  BuildContext context, {
  required _MeasurementDetailRole role,
  required Widget child,
}) {
  final destination = _progressDetailTokens(context);
  if (destination == null) return child;

  final theme = Theme.of(context);
  final surface = _measurementDetailSurface(context, role: role);
  final foreground = _measurementDetailForeground(context, role: role);
  final supportingForeground = _measurementDetailSupportingForeground(
    context,
    role: role,
  );
  final dialogRole = role == _MeasurementDetailRole.dialog;
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: surface,
        onSurface: foreground,
        onSurfaceVariant: supportingForeground,
        primary: dialogRole ? destination.actionPrimary : null,
        onPrimary: dialogRole ? destination.onActionPrimary : null,
        outline: dialogRole ? destination.outlineAccent : null,
        outlineVariant: dialogRole
            ? destination.outlineAccent.withValues(alpha: 0.48)
            : null,
        secondaryContainer: dialogRole ? destination.surfaceSelected : null,
        onSecondaryContainer: dialogRole ? destination.onSurfaceSelected : null,
      ),
      inputDecorationTheme: dialogRole
          ? theme.inputDecorationTheme.copyWith(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: destination.outlineAccent.withValues(alpha: 0.52),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: destination.actionPrimary,
                  width: 2,
                ),
              ),
              floatingLabelStyle: TextStyle(color: destination.actionPrimary),
            )
          : theme.inputDecorationTheme,
      textTheme: theme.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      iconTheme: theme.iconTheme.copyWith(color: foreground),
    ),
    child: child,
  );
}

Color? _measurementDetailAppBarSurface(BuildContext context) {
  return _progressDetailTokens(context)?.pageCanvas;
}

class HealthTrendsSection extends StatefulWidget {
  final int refreshToken;
  final VoidCallback? onChanged;
  final bool fullPage;

  const HealthTrendsSection({
    super.key,
    this.refreshToken = 0,
    this.onChanged,
    this.fullPage = false,
  });

  @override
  State<HealthTrendsSection> createState() => HealthTrendsSectionState();
}

class HealthTrendsSectionState extends State<HealthTrendsSection>
    with AutomaticKeepAliveClientMixin<HealthTrendsSection> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<_MeasurementTrend>> _trendsFuture;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _trendsFuture = _loadTrends();
  }

  @override
  void didUpdateWidget(covariant HealthTrendsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  void _reload() {
    setState(() {
      _trendsFuture = _loadTrends();
    });
  }

  void _notifyChanged() => widget.onChanged?.call();

  Future<List<_MeasurementTrend>> _loadTrends() async {
    await _repo.ensureDefaultMeasurementDefinitions();
    final definitions = await _repo.fetchClassMeasurementDefinitions();
    final trends = await Future.wait(
      definitions.map((definition) async {
        final entries = await _repo.fetchClassMeasurementsForDefinition(
          definition.id,
        );
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return _MeasurementTrend(definition: definition, entries: entries);
      }),
    );

    trends.sort((a, b) {
      final usedCompare = (b.entries.isNotEmpty ? 1 : 0).compareTo(
        a.entries.isNotEmpty ? 1 : 0,
      );
      if (usedCompare != 0) return usedCompare;
      final orderCompare = _definitionOrder(a.definition)
          .compareTo(_definitionOrder(b.definition));
      if (orderCompare != 0) return orderCompare;
      return _measurementSortName(a.definition)
          .compareTo(_measurementSortName(b.definition));
    });
    return trends;
  }

  Future<void> _openTrend(_MeasurementTrend trend) async {
    final currentTheme = Theme.of(context);
    final expressivePageTheme = context.usesExpressivePresentation
        ? currentTheme
        : null;
    final destinationFamily = currentTheme
        .extension<AppExpressiveDestinationTokens>()
        ?.family;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          final page = MeasurementTrendDetailPage(definition: trend.definition);
          final pageTheme = expressivePageTheme;
          if (pageTheme == null) return page;
          final destination = destinationFamily;
          final child = destination == null
              ? page
              : AppExpressiveDestinationTheme(family: destination, child: page);
          return Theme(data: pageTheme, child: child);
        },
      ),
    );
    if (changed == true && mounted) {
      _reload();
      _notifyChanged();
    }
  }

  Future<void> _logEntry(_MeasurementTrend trend) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder: (_) => TonosDialogFrame(
        styleFormControls: true,
        styleDarkNeoPickerSurfaces: true,
        child: _MeasurementEntryDialog(
          title: _strings.healthLogMeasurement(
            _measurementTitle(trend.definition, _strings),
          ),
          definition: trend.definition,
          defaultUnit:
              trend.latest?.unit ??
              _defaultUnitFor(trend.definition, weightUnit),
        ),
      ),
    );
    if (input == null) return;

    await _repo.insertMeasurement(
      trend.definition.id,
      input.timestamp,
      input.value,
      input.unit,
      input.note,
      input.context,
    );
    if (mounted) {
      _reload();
      _notifyChanged();
    }
  }

  Future<void> _createCustomMetric() async {
    final input = await showDialog<_MeasurementDefinitionInput>(
      context: context,
      builder: (_) => const TonosDialogFrame(
        styleFormControls: true,
        child: _MeasurementDefinitionDialog(),
      ),
    );
    if (input == null) return;

    try {
      final defId = await _repo.insertMeasurementDefinition(
        name: input.name,
        type: MeasurementType.Custom,
      );
      if (input.initialValue != null) {
        await _repo.insertMeasurement(
          defId,
          DateTime.now(),
          input.initialValue!,
          input.unit,
          input.note,
          null,
        );
      }
    } on MeasurementValidationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_measurementValidationMessage(_strings, error)),
          ),
        );
      }
      return;
    }
    if (mounted) {
      _reload();
      _notifyChanged();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressive
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final metricButton = TextButton.icon(
      onPressed: _createCustomMetric,
      icon: const Icon(Icons.add, size: 18),
      label: Text(strings.healthMetric),
      style: usesInkRecipe
          ? TextButton.styleFrom(
              backgroundColor: context.cs.primary,
              foregroundColor: tonosForegroundForSurface(
                context,
                context.cs.primary,
              ),
              side: BorderSide(
                color: tonosOutlineForSurface(context, context.cs.primary),
                width: context.shapeTokens.outlineWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: context.shapeTokens.control,
              ),
            )
          : usesExpressive
          ? TextButton.styleFrom(
              backgroundColor: expressiveTokens!.actionSecondary,
              foregroundColor: expressiveTokens.actionSecondaryForeground,
              shape: RoundedRectangleBorder(
                borderRadius: context.shapeTokens.healthTrendEntry,
              ),
            )
          : null,
    );
    final styledMetricButton = usesExpressive
        ? TonosExpressivePressResponse(
            enabled: true,
            borderRadius: context.shapeTokens.healthTrendEntry,
            pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
            pressedScale: TonosExpressiveMotionTiers.compactScale,
            pressedOffset: TonosExpressiveMotionTiers.compactOffset,
            child: metricButton,
          )
        : metricButton;

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.healthTrendsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          styledMetricButton,
        ],
      ),
    );

    if (widget.fullPage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          Expanded(child: _buildTrends(strings)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, _buildTrends(strings)],
    );
  }

  Widget _buildTrends(AppLocalizations strings) {
    return FutureBuilder<List<_MeasurementTrend>>(
      future: _trendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          if (widget.fullPage) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox(
            height: 162,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SafeErrorView(
            title: strings.safeFailureLoadTitle,
            failure: SafeFailure.classify(snapshot.error!),
            onRetry: _reload,
            compact: !widget.fullPage,
          );
        }

        final trends = snapshot.data ?? const <_MeasurementTrend>[];
        if (trends.isEmpty) {
          return _HealthTrendMessageCard(
            icon: Icons.straighten,
            title: strings.healthNoMeasurements,
            message: strings.healthNoMeasurementsBody,
            actionLabel: strings.healthCreateMetric,
            onAction: _createCustomMetric,
          );
        }

        if (widget.fullPage) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: textScale <= 1.15 ? 0.88 : 0.88 / textScale,
            ),
            itemBuilder: (context, index) {
              if (index == trends.length) {
                return _AddTrendTile(
                  onTap: _createCustomMetric,
                  fillCell: true,
                  arrivalIndex: index,
                );
              }
              final trend = trends[index];
              return _TrendTile(
                trend: trend,
                onTap: () => _openTrend(trend),
                onAdd: () => _logEntry(trend),
                alternateSurface: index.isOdd,
                arrivalIndex: index,
                fillCell: true,
              );
            },
            itemCount: trends.length + 1,
          );
        }

        final shadowBottom = context.usesNeoPresentation
            ? math.max(0.0, context.effectTokens.cardShadowOffset.dy)
            : 0.0;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final tileHeight = (162 + math.max(0.0, (textScale - 1) * 72))
            .toDouble();
        return SizedBox(
          height: tileHeight + shadowBottom,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16, 0, 16, shadowBottom),
            itemBuilder: (context, index) {
              if (index == trends.length) {
                return _AddTrendTile(
                  onTap: _createCustomMetric,
                  arrivalIndex: index,
                );
              }
              final trend = trends[index];
              return _TrendTile(
                trend: trend,
                onTap: () => _openTrend(trend),
                onAdd: () => _logEntry(trend),
                alternateSurface: index.isOdd,
                arrivalIndex: index,
                height: tileHeight,
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemCount: trends.length + 1,
          ),
        );
      },
    );
  }
}

class MeasurementTrendDetailPage extends StatefulWidget {
  final MeasurementDefinition definition;

  const MeasurementTrendDetailPage({super.key, required this.definition});

  @override
  State<MeasurementTrendDetailPage> createState() =>
      _MeasurementTrendDetailPageState();
}

class _MeasurementTrendDetailPageState
    extends State<MeasurementTrendDetailPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _addTutorialKey = GlobalKey(debugLabel: 'measurement_trend_add');
  final _summaryTutorialKey = GlobalKey(
    debugLabel: 'measurement_trend_summary',
  );
  final _chartTutorialKey = GlobalKey(debugLabel: 'measurement_trend_chart');
  final _entriesTutorialKey = GlobalKey(
    debugLabel: 'measurement_trend_entries',
  );
  late Future<List<Measurement>> _entriesFuture;
  bool _changed = false;

  AppLocalizations get _strings => AppLocalizations.of(context);
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<Measurement>> _loadEntries() async {
    final entries = await _repo.fetchClassMeasurementsForDefinition(
      widget.definition.id,
    );
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  void _reload() {
    setState(() {
      _entriesFuture = _loadEntries();
      _changed = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.measurementTrendDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _summaryTutorialKey,
            icon: Icons.speed,
            title: _strings.healthTutorialSummaryTitle,
            body: _strings.healthTutorialSummaryBody,
          ),
          GuidedTutorialStep(
            targetKey: _chartTutorialKey,
            icon: Icons.show_chart,
            title: _strings.healthTutorialChartTitle,
            body: _strings.healthTutorialChartBody,
          ),
          GuidedTutorialStep(
            targetKey: _entriesTutorialKey,
            icon: Icons.list_alt,
            title: _strings.healthTutorialEntriesTitle,
            body: _strings.healthTutorialEntriesBody,
          ),
          GuidedTutorialStep(
            targetKey: _addTutorialKey,
            icon: Icons.add,
            title: _strings.healthTutorialLogTitle,
            body: _strings.healthTutorialLogBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _addEntry(List<Measurement> entries) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder: (_) => TonosDialogFrame(
        styleFormControls: true,
        styleDarkNeoPickerSurfaces: true,
        child: _MeasurementEntryDialog(
          title: _strings.healthLogMeasurement(
            _measurementTitle(widget.definition, _strings),
          ),
          definition: widget.definition,
          defaultUnit: entries.isNotEmpty
              ? entries.last.unit
              : _defaultUnitFor(widget.definition, weightUnit),
        ),
      ),
    );
    if (input == null) return;

    await _repo.insertMeasurement(
      widget.definition.id,
      input.timestamp,
      input.value,
      input.unit,
      input.note,
      input.context,
    );
    if (mounted) _reload();
  }

  Future<void> _editEntry(Measurement entry) async {
    final input = await showDialog<_MeasurementEntryInput>(
      context: context,
      builder: (_) => TonosDialogFrame(
        styleFormControls: true,
        styleDarkNeoPickerSurfaces: true,
        child: _MeasurementEntryDialog(
          title: _strings.healthEditMeasurement(
            _measurementTitle(widget.definition, _strings),
          ),
          definition: widget.definition,
          defaultUnit: entry.unit,
          entry: entry,
        ),
      ),
    );
    if (input == null) return;

    await _repo.updateMeasurement(
      measurementId: entry.id,
      timestamp: input.timestamp,
      value: input.value,
      unit: input.unit,
      note: input.note,
      context: input.context,
    );
    if (mounted) _reload();
  }

  Future<void> _deleteEntry(Measurement entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(_strings.healthDeleteEntryTitle),
          content: Text(
            _strings.healthDeleteEntryBody(
              _formatMeasurement(entry, Localizations.localeOf(context)),
              _formatDateTime(
                entry.displayDateTime,
                Localizations.localeOf(context),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_strings.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_strings.commonDelete),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    await _repo.deleteMeasurement(entry.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = _measurementTitle(widget.definition, strings);
    final progressExpressiveDetail = _progressDetailTokens(context) != null;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          key: const ValueKey('measurement-trend-detail-app-bar'),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Text(title),
          backgroundColor: _measurementDetailAppBarSurface(context),
          foregroundColor: progressExpressiveDetail
              ? Theme.of(context).colorScheme.onSurface
              : null,
          surfaceTintColor: progressExpressiveDetail
              ? Colors.transparent
              : null,
          elevation: progressExpressiveDetail ? 0 : null,
          scrolledUnderElevation: progressExpressiveDetail ? 0 : null,
          actions: [
            IconButton(
              key: const ValueKey('measurement-trend-detail-add'),
              tooltip: strings.healthLogEntry,
              onPressed: () async {
                final entries = await _entriesFuture;
                if (!context.mounted) return;
                await _addEntry(entries);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder<List<Measurement>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return SafeErrorView(
                title: strings.safeFailureLoadTitle,
                failure: SafeFailure.classify(snapshot.error!),
                onRetry: _reload,
              );
            }

            final entries = snapshot.data ?? const <Measurement>[];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _queueTutorial();
            });
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                KeyedSubtree(
                  key: _summaryTutorialKey,
                  child: _MeasurementSummaryCard(
                    definition: widget.definition,
                    entries: entries,
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _chartTutorialKey,
                  child: _MeasurementChartCard(
                    definition: widget.definition,
                    entries: entries,
                    height: progressExpressiveDetail ? 225 : 250,
                  ),
                ),
                const SizedBox(height: 20),
                KeyedSubtree(
                  key: _entriesTutorialKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.healthEntries,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: progressExpressiveDetail ? 20 : null,
                          fontWeight: progressExpressiveDetail
                              ? FontWeight.w700
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        _HealthTrendMessageCard(
                          icon: Icons.add_chart,
                          title: strings.healthNoEntries,
                          message: strings.healthFirstEntry(title),
                          actionLabel: strings.healthLogEntry,
                          onAction: () => _addEntry(entries),
                          compactAction: _progressDetailTokens(context) != null,
                        )
                      else
                        for (final entry in entries.reversed)
                          _MeasurementEntryTile(
                            entry: entry,
                            onTap: () => _editEntry(entry),
                            onDelete: () => _deleteEntry(entry),
                          ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: KeyedSubtree(
              key: _addTutorialKey,
              child: FilledButton.icon(
                onPressed: () async {
                  final entries = await _entriesFuture;
                  if (!context.mounted) return;
                  await _addEntry(entries);
                },
                icon: const Icon(Icons.add),
                label: Text(strings.healthLogEntry),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final _MeasurementTrend trend;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool fillCell;
  final bool alternateSurface;
  final int arrivalIndex;
  final double? height;

  const _TrendTile({
    required this.trend,
    required this.onTap,
    required this.onAdd,
    this.fillCell = false,
    this.alternateSurface = false,
    this.arrivalIndex = 0,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final title = _measurementTitle(trend.definition, strings);
    final latest = trend.latest;
    final delta = trend.delta;
    final deltaColor = _deltaColor(context, delta);
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressive
        ? theme.extension<AppExpressiveTrainTokens>()!
        : null;
    final cardShape = usesExpressive ? shapes.healthTrendCard : shapes.card;
    final cardSurface = usesExpressive
        ? _expressiveHealthTrendSurface(context, alternate: alternateSurface)
        : _healthTrendCardSurface(context);
    final cardForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, cardSurface)
        : usesExpressive
        ? theme.colorScheme.onSurface
        : null;
    final cardSecondaryForeground = usesInkRecipe
        ? tonosSecondaryForegroundForSurface(context, cardSurface)
        : usesExpressive
        ? theme.colorScheme.onSurfaceVariant
        : null;
    final effects = context.effectTokens;
    final borderColor = usesInkRecipe
        ? tonosOutlineForSurface(context, cardSurface)
        : surfaces.subtleOutline;
    final logButton = usesExpressive
        ? Semantics(
            key: ValueKey(
              'measurement-trend-${trend.definition.id}-log-semantics',
            ),
            container: true,
            button: true,
            label: strings.healthLogMeasurement(title),
            onTap: onAdd,
            child: ExcludeSemantics(
              child: IconButton(
                key: AppTestKeys.measurementTrendAdd(trend.definition.id),
                onPressed: onAdd,
                style: IconButton.styleFrom(
                  backgroundColor: expressiveTokens!.actionSecondary,
                  foregroundColor: expressiveTokens.actionSecondaryForeground,
                ),
                icon: Icon(
                  Icons.add,
                  color: expressiveTokens.actionSecondaryForeground,
                ),
              ),
            ),
          )
        : Semantics(
            button: true,
            label: strings.healthLogMeasurement(title),
            onTap: onAdd,
            child: ExcludeSemantics(
              child: InkResponse(
                key: AppTestKeys.measurementTrendAdd(trend.definition.id),
                onTap: onAdd,
                radius: 18,
                child: Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: cardSecondaryForeground ?? dataVisualization.label,
                ),
              ),
            ),
          );

    final card = Material(
      color: cardSurface,
      borderRadius: cardShape,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardShape,
        child: Container(
          key: AppTestKeys.measurementTrend(trend.definition.id),
          width: fillCell ? double.infinity : 154,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: usesExpressive
                ? null
                : Border.all(
                    color: borderColor,
                    width: usesInkRecipe ? shapes.outlineWidth : 1,
                  ),
            borderRadius: cardShape,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: usesInkRecipe || usesExpressive ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cardForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  logButton,
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _MeasurementSparkline(
                  definition: trend.definition,
                  entries: trend.entries,
                  lineColor: usesInkRecipe
                      ? tonosPrimarySeriesForSurface(context, cardSurface)
                      : dataVisualization.tertiarySeries,
                  emptyColor: cardSecondaryForeground,
                  useExpressiveEmptyState: usesExpressive,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                latest == null
                    ? strings.healthNoEntries
                    : _formatMeasurement(latest, locale),
                maxLines: usesInkRecipe ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cardForeground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latest == null
                    ? strings.healthTapToLog
                    : _formatDelta(delta, strings, locale),
                maxLines: usesInkRecipe ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: usesExpressive && latest != null
                      ? deltaColor
                      : cardSecondaryForeground ?? deltaColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final tile = _withHealthCardForeground(
      context,
      usesInkRecipe
          // The opaque Material must cover the shadow's interior.
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: shapes.card,
                boxShadow: [
                  BoxShadow(
                    color: effects.cardShadow,
                    blurRadius: 0,
                    offset: effects.cardShadowOffset,
                  ),
                ],
              ),
              child: card,
            )
          : card,
      surface: cardSurface,
    );
    final sizedTile = height == null
        ? tile
        : SizedBox(height: height, child: tile);
    if (!usesExpressive) return sizedTile;
    return TonosExpressiveReveal(
      staggerIndex: arrivalIndex,
      child: TonosExpressivePressResponse(
        enabled: true,
        borderRadius: cardShape,
        pressedBorderRadius: ExpressiveTrainShapes.focusInsetPressed,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: sizedTile,
      ),
    );
  }
}

class _AddTrendTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool fillCell;
  final int arrivalIndex;

  const _AddTrendTile({
    required this.onTap,
    this.fillCell = false,
    this.arrivalIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressive
        ? theme.extension<AppExpressiveTrainTokens>()!
        : null;
    final fill = usesInkRecipe
        ? context.cs.primary
        : usesExpressive
        ? expressiveTokens!.actionSecondary
        : Colors.transparent;
    final foreground = usesInkRecipe
        ? tonosForegroundForSurface(context, fill)
        : usesExpressive
        ? expressiveTokens!.actionSecondaryForeground
        : dataVisualization.label;
    final borderColor = usesInkRecipe
        ? tonosOutlineForSurface(context, fill)
        : surfaces.subtleOutline;
    final addTile = Semantics(
      button: true,
      label: strings.healthCreateMetric,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: fill,
          borderRadius: usesExpressive ? shapes.healthTrendEntry : shapes.card,
          child: InkWell(
            onTap: onTap,
            borderRadius: usesExpressive
                ? shapes.healthTrendEntry
                : shapes.card,
            child: Container(
              width: fillCell ? double.infinity : 132,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: usesExpressive ? null : Border.all(color: borderColor),
                borderRadius: usesExpressive
                    ? shapes.healthTrendEntry
                    : shapes.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: usesExpressive
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: foreground, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    strings.healthCustomMetric,
                    textAlign: usesExpressive
                        ? TextAlign.start
                        : TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!usesExpressive) return addTile;
    return TonosExpressiveReveal(
      staggerIndex: arrivalIndex,
      child: TonosExpressivePressResponse(
        enabled: true,
        borderRadius: shapes.healthTrendEntry,
        pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: addTile,
      ),
    );
  }
}

class _MeasurementSparkline extends StatelessWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  final Color lineColor;
  final Color? emptyColor;
  final bool useExpressiveEmptyState;

  const _MeasurementSparkline({
    required this.definition,
    required this.entries,
    required this.lineColor,
    this.emptyColor,
    this.useExpressiveEmptyState = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    if (entries.length < 2) {
      return Semantics(
        key: ValueKey('measurement-sparkline-${definition.id}-semantics'),
        container: true,
        label: _measurementTrendSemanticsLabel(
          definition,
          entries,
          strings,
          locale,
        ),
        child: ExcludeSemantics(
          child: Center(
            child: useExpressiveEmptyState
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final prompt = entries.isEmpty
                          ? strings.healthTrendNeedEntries
                          : strings.healthTrendNeedOneMore;
                      final promptStyle = Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          );
                      final promptPainter = TextPainter(
                        text: TextSpan(text: prompt, style: promptStyle),
                        textAlign: TextAlign.center,
                        textDirection: Directionality.of(context),
                        textScaler: MediaQuery.textScalerOf(context),
                        maxLines: 2,
                        ellipsis: '\u2026',
                      )..layout(maxWidth: constraints.maxWidth);
                      final icon = Icon(
                        Icons.show_chart,
                        size: 19,
                        color:
                            emptyColor ??
                            Theme.of(context).iconTheme.color
                                ?.withValues(alpha: 0.55),
                      );
                      if (constraints.maxHeight < promptPainter.height + 23) {
                        return icon;
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon,
                          const SizedBox(height: 4),
                          Text(
                            prompt,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: promptStyle,
                          ),
                        ],
                      );
                    },
                  )
                : Icon(
                    Icons.show_chart,
                    color:
                        emptyColor ??
                        Theme.of(context).iconTheme.color
                            ?.withValues(alpha: 0.25),
                  ),
          ),
        ),
      );
    }

    final spots = _spotsFor(entries);
    final bounds = _chartBounds(entries.map((m) => m.value).toList());
    return Semantics(
      key: ValueKey('measurement-sparkline-${definition.id}-semantics'),
      container: true,
      label: _measurementTrendSemanticsLabel(
        definition,
        entries,
        strings,
        locale,
      ),
      child: ExcludeSemantics(
        child: LineChart(
          LineChartData(
            minX: spots.first.x,
            maxX: spots.last.x,
            minY: bounds.minY,
            maxY: bounds.maxY,
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                color: lineColor,
                dotData: FlDotData(show: entries.length <= 4),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          duration: appMotionDuration(
            context,
            const Duration(milliseconds: 150),
          ),
          curve: Curves.linear,
        ),
      ),
    );
  }
}

class _MeasurementSummaryCard extends StatelessWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;

  const _MeasurementSummaryCard({
    required this.definition,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final latest = entries.isEmpty ? null : entries.last;
    final previous = entries.length < 2 ? null : entries[entries.length - 2];
    final delta = latest == null || previous == null
        ? null
        : latest.value - previous.value;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final records = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-records'),
      label: strings.healthRecords,
      value: LocalizedFormatters.number(
        entries.length,
        locale,
        maximumFractionDigits: 0,
      ),
      detail: _defaultUnitFor(definition, weightUnit),
    );
    final summaryStats = [
      _SummaryStat(
        valueKey: const ValueKey('measurement-trend-summary-latest'),
        label: strings.healthLatest,
        value: latest == null
            ? strings.healthNoEntry
            : _formatMeasurement(latest, locale),
        detail: latest == null
            ? strings.healthNotTrackedYet
            : LocalizedFormatters.date(
                latest.calendarDay.toLocalDateTime(),
                locale,
              ),
      ),
      _SummaryStat(
        valueKey: const ValueKey('measurement-trend-summary-change'),
        label: strings.healthChange,
        value: delta == null
            ? strings.healthNoChange
            : _formatDelta(delta, strings, locale),
        detail: entries.length < 2
            ? strings.healthNeedTwoEntries
            : strings.healthVersusPrevious,
        valueColor: _deltaColor(context, delta),
      ),
      records,
    ];

    final legacySummary = _withHealthCardForeground(
      context,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _healthTrendCardSurface(context),
          borderRadius: shapes.healthTrendCard,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useStackedLayout =
                constraints.maxWidth < 420 || textScale > 1.15;
            if (useStackedLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < summaryStats.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    summaryStats[index],
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var index = 0; index < summaryStats.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(child: summaryStats[index]),
                ],
              ],
            );
          },
        ),
      ),
    );

    final expressiveForeground = _measurementDetailForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final expressiveSupportingForeground =
        _measurementDetailSupportingForeground(
          context,
          role: _MeasurementDetailRole.focal,
        );
    final expressiveRecords = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-records'),
      label: strings.healthRecords,
      value: LocalizedFormatters.number(
        entries.length,
        locale,
        maximumFractionDigits: 0,
      ),
      detail: null,
      foreground: expressiveForeground,
      supportingForeground: expressiveSupportingForeground,
      wrapValues: true,
      compact: true,
    );
    final expressiveChange = _SummaryStat(
      valueKey: const ValueKey('measurement-trend-summary-change'),
      label: strings.healthChange,
      value: delta == null
          ? (entries.isEmpty ? '—' : strings.healthNoChange)
          : _formatDelta(delta, strings, locale),
      detail: entries.length < 2
          ? strings.healthNeedTwoEntries
          : strings.healthVersusPrevious,
      valueColor: delta == null
          ? expressiveForeground
          : _deltaColor(context, delta),
      foreground: expressiveForeground,
      supportingForeground: expressiveSupportingForeground,
      wrapValues: true,
      compact: true,
    );
    final expressiveSummary = _withMeasurementDetailSurfaceTheme(
      context,
      role: _MeasurementDetailRole.focal,
      child: _withHealthCardForeground(
        context,
        Material(
          color: surface,
          borderRadius: shapes.healthTrendCard,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (latest == null)
                  _EmptyMeasurementSummary(
                    title: strings.healthNoEntry,
                    detail: strings.healthNotTrackedYet,
                  )
                else ...[
                  Text(
                    strings.healthLatest,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: expressiveSupportingForeground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatMeasurement(latest, locale),
                    key: const ValueKey('measurement-trend-summary-latest'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: expressiveForeground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    LocalizedFormatters.date(
                      latest.calendarDay.toLocalDateTime(),
                      locale,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: expressiveSupportingForeground,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Divider(
                  height: 1,
                  color: expressiveForeground.withValues(alpha: 0.22),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackStats =
                        constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.15;
                    if (stackStats) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          expressiveChange,
                          const SizedBox(height: 8),
                          expressiveRecords,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: expressiveChange),
                        const SizedBox(width: 20),
                        Expanded(child: expressiveRecords),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        surface: surface,
      ),
    );
    if (_progressDetailTokens(context) != null) return expressiveSummary;
    return legacySummary;
  }
}

class _EmptyMeasurementSummary extends StatelessWidget {
  const _EmptyMeasurementSummary({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = _progressDetailTokens(context);
    final iconSurface =
        destination?.surfaceSecondary ??
        theme.colorScheme.surfaceContainerHighest;
    final iconForeground =
        destination?.onSurfaceSecondary ?? theme.colorScheme.onSurfaceVariant;
    final foreground = _measurementDetailForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    final supportingForeground = _measurementDetailSupportingForeground(
      context,
      role: _MeasurementDetailRole.focal,
    );
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconSurface,
            borderRadius: context.shapeTokens.healthTrendEntry,
          ),
          child: Icon(Icons.show_chart, color: iconForeground),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                key: const ValueKey('measurement-trend-summary-latest'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: supportingForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final Key? valueKey;
  final String label;
  final String value;
  final String? detail;
  final Color? valueColor;
  final Color? foreground;
  final Color? supportingForeground;
  final bool wrapValues;
  final bool compact;

  const _SummaryStat({
    this.valueKey,
    required this.label,
    required this.value,
    required this.detail,
    this.valueColor,
    this.foreground,
    this.supportingForeground,
    this.wrapValues = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: supportingForeground ?? theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          value,
          key: valueKey,
          maxLines: wrapValues ? null : 1,
          overflow: wrapValues ? null : TextOverflow.ellipsis,
          style:
              (compact
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    color:
                        valueColor ?? foreground ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
        ),
        if (detail != null) ...[
          SizedBox(height: compact ? 1 : 2),
          Text(
            detail,
            maxLines: wrapValues ? null : 1,
            overflow: wrapValues ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: supportingForeground ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _MeasurementChartCard extends StatefulWidget {
  final MeasurementDefinition definition;
  final List<Measurement> entries;
  final double height;

  const _MeasurementChartCard({
    required this.definition,
    required this.entries,
    required this.height,
  });

  @override
  State<_MeasurementChartCard> createState() => _MeasurementChartCardState();
}

class _MeasurementChartCardState extends State<_MeasurementChartCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _MeasurementChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _selectedIndex = null;
    }
  }

  void _selectIndex(int index) {
    if (index < 0 ||
        index >= widget.entries.length ||
        _selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _selectNext() {
    if (widget.entries.isEmpty) return;
    final currentIndex = _selectedIndex ?? widget.entries.length - 1;
    if (currentIndex + 1 >= widget.entries.length) return;
    _selectIndex(currentIndex + 1);
  }

  void _selectPrevious() {
    if (widget.entries.isEmpty) return;
    final currentIndex = _selectedIndex ?? widget.entries.length - 1;
    if (currentIndex <= 0) return;
    _selectIndex(currentIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dataVisualization = context.dataVisualizationTokens;
    final entries = widget.entries;
    final spots = _spotsFor(entries);
    final bounds = _chartBounds(entries.map((m) => m.value).toList());
    final chartSemantics = _measurementTrendSemanticsLabel(
      widget.definition,
      entries,
      strings,
      locale,
    );
    final selectedIndex = _selectedIndex;
    final currentIndex = entries.isEmpty
        ? null
        : (selectedIndex ?? entries.length - 1)
              .clamp(0, entries.length - 1)
              .toInt();
    final currentPoint = currentIndex == null ? null : entries[currentIndex];
    final nextPoint = currentIndex != null && currentIndex + 1 < entries.length
        ? entries[currentIndex + 1]
        : null;
    final previousPoint = currentIndex != null && currentIndex > 0
        ? entries[currentIndex - 1]
        : null;
    final canIncrease = nextPoint != null;
    final canDecrease = previousPoint != null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final isSparse = entries.length < 2;
    final expressiveDetail = _progressDetailTokens(context) != null;
    final compactExpressiveEmpty = isSparse && expressiveDetail;
    final responsiveHeight = compactExpressiveEmpty
        ? math
              .min(widget.height, 128 + math.max(0.0, (textScale - 1) * 64))
              .toDouble()
        : (widget.height + math.max(0.0, (textScale - 1) * 80)).toDouble();

    return Semantics(
      key: const ValueKey('measurement-trend-chart-semantics'),
      container: true,
      label: chartSemantics,
      value: currentPoint == null
          ? null
          : _measurementPointSemanticsValue(currentPoint, locale),
      increasedValue: nextPoint == null
          ? null
          : _measurementPointSemanticsValue(nextPoint, locale),
      decreasedValue: previousPoint == null
          ? null
          : _measurementPointSemanticsValue(previousPoint, locale),
      focusable: canIncrease || canDecrease,
      onIncrease: canIncrease ? _selectNext : null,
      onDecrease: canDecrease ? _selectPrevious : null,
      child: ExcludeSemantics(
        child: _withMeasurementDetailSurfaceTheme(
          context,
          role: _MeasurementDetailRole.analytical,
          child: Container(
            height: responsiveHeight,
            padding: expressiveDetail
                ? const EdgeInsets.fromLTRB(18, 13, 18, 16)
                : const EdgeInsets.fromLTRB(14, 16, 14, 12),
            decoration: BoxDecoration(
              color: _progressDetailTokens(context) != null
                  ? _measurementDetailSurface(
                      context,
                      role: _MeasurementDetailRole.analytical,
                    )
                  : context.usesNeoPresentation
                  ? context.surfaceTokens.card
                  : context.progressColors.healthCard,
              borderRadius: shapes.healthTrendCard,
            ),
            child: _buildChart(
              context: context,
              strings: strings,
              locale: locale,
              dataVisualization: dataVisualization,
              entries: entries,
              spots: spots,
              bounds: bounds,
              selectedIndex: selectedIndex,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart({
    required BuildContext context,
    required AppLocalizations strings,
    required Locale locale,
    required AppDataVisualizationTokens dataVisualization,
    required List<Measurement> entries,
    required List<FlSpot> spots,
    required _ChartBounds bounds,
    required int? selectedIndex,
  }) {
    final theme = Theme.of(context);
    if (entries.length < 2) {
      final message = entries.isEmpty
          ? strings.healthTrendNeedEntries
          : strings.healthTrendNeedOneMore;
      if (_progressDetailTokens(context) != null) {
        return Container(
          key: const ValueKey('measurement-trend-chart-empty'),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _measurementDetailSurface(
              context,
              role: _MeasurementDetailRole.analytical,
            ),
            borderRadius: context.shapeTokens.healthTrendEntry,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _measurementDetailSupportingForeground(
                      context,
                      role: _MeasurementDetailRole.analytical,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final expressiveDetail = _progressDetailTokens(context) != null;
    final xInset = expressiveDetail ? 0.18 : 0.0;
    final chartLine = LineChartBarData(
      spots: spots,
      isCurved: !expressiveDetail,
      color: dataVisualization.tertiarySeries,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: dataVisualization.tertiarySeries.withValues(alpha: 0.12),
      ),
    );
    final dateTickIndexes = _measurementDateTickIndexes(entries);
    final yAxisTickValues = _chartYAxisTickValues(bounds);
    final yAxisLabels = _formatChartYAxisLabels(
      yAxisTickValues,
      bounds.interval,
      locale,
    );
    final yAxisLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: _measurementDetailForeground(
        context,
        role: _MeasurementDetailRole.analytical,
      ),
    );
    final yAxisReservedSize = _chartYAxisReservedSize(
      context,
      yAxisLabels,
      yAxisLabelStyle,
      locale,
    );
    final showingTooltipIndicators = selectedIndex == null
        ? const <ShowingTooltipIndicators>[]
        : <ShowingTooltipIndicators>[
            ShowingTooltipIndicators([
              LineBarSpot(chartLine, 0, spots[selectedIndex]),
            ]),
          ];

    return LineChart(
      LineChartData(
        minX: spots.first.x - xInset,
        maxX: spots.last.x + xInset,
        minY: bounds.minY,
        maxY: bounds.maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: context.progressColors.healthGrid.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yAxisReservedSize,
              interval: bounds.interval,
              getTitlesWidget: (value, _) {
                final tickIndex = ((value - bounds.minY) / bounds.interval)
                    .round();
                if (tickIndex < 0 || tickIndex >= yAxisLabels.length) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  width: yAxisReservedSize - 6,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        yAxisLabels[tickIndex],
                        key: ValueKey(
                          'measurement-trend-chart-y-tick-$tickIndex',
                        ),
                        maxLines: 1,
                        softWrap: false,
                        style: yAxisLabelStyle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: expressiveDetail ? 34 : 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                final index = value.round();
                if ((value - index).abs() > 0.05 ||
                    index < 0 ||
                    index >= entries.length ||
                    !dateTickIndexes.contains(index)) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _shortDate(
                    entries[index].calendarDay.toLocalDateTime(),
                    locale,
                  ),
                  key: ValueKey('measurement-trend-chart-tick-$index'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _measurementDetailForeground(
                      context,
                      role: _MeasurementDetailRole.analytical,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            final touchedSpots = response?.lineBarSpots;
            if (touchedSpots == null || touchedSpots.isEmpty) return;
            _selectIndex(touchedSpots.first.spotIndex);
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final index = spot.spotIndex.clamp(0, entries.length - 1).toInt();
              final entry = entries[index];
              return LineTooltipItem(
                '${_formatDateTime(entry.displayDateTime, locale)}\n${_formatMeasurement(entry, locale)}',
                theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ) ??
                    TextStyle(color: theme.colorScheme.onSurface),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [chartLine],
        showingTooltipIndicators: showingTooltipIndicators,
      ),
      duration: appMotionDuration(context, const Duration(milliseconds: 150)),
      curve: Curves.linear,
    );
  }
}

class _MeasurementEntryTile extends StatelessWidget {
  final Measurement entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MeasurementEntryTile({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final expressive = _progressDetailTokens(context) != null;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.history,
    );
    final foreground = expressive
        ? _measurementDetailForeground(
            context,
            role: _MeasurementDetailRole.history,
          )
        : null;
    final supportingForeground = expressive
        ? _measurementDetailSupportingForeground(
            context,
            role: _MeasurementDetailRole.history,
          )
        : null;
    final contextLabel = _measurementContextLabel(entry, strings);
    final note = _measurementNote(entry);
    final details = <String>[
      _formatDateTime(entry.displayDateTime, locale),
      if (contextLabel != null) contextLabel,
      if (note != null) note,
    ].join(' - ');
    return _withMeasurementDetailSurfaceTheme(
      context,
      role: _MeasurementDetailRole.history,
      child: _withHealthCardForeground(
        context,
        Card(
          key: ValueKey('measurement-trend-entry-${entry.id}'),
          color: expressive ? surface : null,
          elevation: expressive ? 0 : null,
          margin: EdgeInsets.symmetric(vertical: expressive ? 3 : 5),
          child: ListTile(
            dense: expressive,
            visualDensity: expressive ? VisualDensity.compact : null,
            onTap: onTap,
            title: Text(
              _formatMeasurement(entry, locale),
              style: expressive
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
            subtitle: Text(
              details,
              style: expressive
                  ? Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: supportingForeground)
                  : null,
            ),
            trailing: PopupMenuButton<String>(
              tooltip: strings.healthEntryActions,
              onSelected: (value) {
                if (value == 'edit') onTap();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context).commonEdit),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context).commonDelete),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: shapes.healthTrendEntry,
            ),
            tileColor: surface,
          ),
        ),
      ),
    );
  }
}

class _HealthTrendMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compactAction;

  const _HealthTrendMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compactAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionLabel = this.actionLabel;

    final shapes = context.shapeTokens;
    if (context.usesExpressivePresentation) {
      final expressiveTokens = Theme.of(context)
          .extension<AppExpressiveTrainTokens>()!;
      final surface = _expressiveHealthTrendSurface(context);
      final stateCard = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TonosSurfaceTheme(
          surface: surface,
          child: Material(
            color: surface,
            borderRadius: shapes.healthTrendCard,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: expressiveTokens.actionSecondary,
                          borderRadius: ExpressiveTrainShapes.compactControl,
                        ),
                        child: Icon(
                          icon,
                          color: expressiveTokens.actionSecondaryForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TonosExpressivePressResponse(
                        enabled: true,
                        borderRadius: shapes.healthTrendEntry,
                        pressedBorderRadius:
                            ExpressiveTrainShapes.compactControlPressed,
                        pressedScale: TonosExpressiveMotionTiers.compactScale,
                        pressedOffset: TonosExpressiveMotionTiers.compactOffset,
                        child: TextButton.icon(
                          onPressed: onAction,
                          icon: Icon(Icons.add, size: compactAction ? 16 : 18),
                          label: Text(actionLabel),
                          style: compactAction
                              ? TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                )
                              : TextButton.styleFrom(
                                  backgroundColor:
                                      expressiveTokens.actionSecondary,
                                  foregroundColor: expressiveTokens
                                      .actionSecondaryForeground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: shapes.healthTrendEntry,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      return TonosExpressiveReveal(child: stateCard);
    }

    final foreground = context.usesNeoPresentation
        ? tonosForegroundForSurface(context, _healthTrendCardSurface(context))
        : theme.colorScheme.onSurface;
    return _withHealthCardForeground(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _healthTrendCardSurface(context),
            borderRadius: shapes.healthTrendCard,
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.usesNeoPresentation
                            ? tonosSecondaryForegroundForSurface(
                                context,
                                _healthTrendCardSurface(context),
                              )
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: compactAction
                        ? theme.colorScheme.onSurfaceVariant
                        : foreground,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementEntryDialog extends StatefulWidget {
  final String title;
  final MeasurementDefinition definition;
  final String defaultUnit;
  final Measurement? entry;

  const _MeasurementEntryDialog({
    required this.title,
    required this.definition,
    required this.defaultUnit,
    this.entry,
  });

  @override
  State<_MeasurementEntryDialog> createState() =>
      _MeasurementEntryDialogState();
}

class _MeasurementEntryDialogState extends State<_MeasurementEntryDialog> {
  late DateTime _timestamp;
  late final TextEditingController _valueController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  bool _heightUsesFeetAndInches = false;
  String? _bodyWeightVariation;
  bool _withPump = false;

  bool get _isHeight => widget.definition.type == MeasurementType.Height;
  bool get _isBodyWeight =>
      widget.definition.type == MeasurementType.BodyWeight;
  bool get _isBodyPart =>
      !_isHeight &&
      !_isBodyWeight &&
      widget.definition.type != MeasurementType.Custom;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final unit = entry?.unit ?? widget.defaultUnit;
    final note = entry?.note ?? '';
    final measurementContext =
        entry?.context ??
        MeasurementValidation.legacyContextFor(
          type: widget.definition.type,
          note: entry?.note,
        );
    _timestamp = entry?.timestamp ?? DateTime.now();
    _heightUsesFeetAndInches = _isHeight && unit == 'in';
    if (_heightUsesFeetAndInches && entry != null) {
      final totalInches = entry.value.round();
      _valueController = TextEditingController(
        text: (totalInches ~/ 12).toString(),
      );
      _heightInchesController = TextEditingController(
        text: (totalInches % 12).toString(),
      );
    } else {
      _valueController = TextEditingController(
        text: entry == null ? '' : _cleanNumber(entry.value),
      );
      _heightInchesController = TextEditingController();
    }
    _unitController = TextEditingController(text: unit);
    _bodyWeightVariation = switch (measurementContext) {
      MeasurementContext.wakeUp => 'WakeUp',
      MeasurementContext.bedtime => 'BedTime',
      MeasurementContext.overall => 'Overall',
      _ => _isBodyWeight && _isKnownBodyWeightVariation(note) ? note : null,
    };
    _withPump =
        measurementContext == MeasurementContext.withPump ||
        (_isBodyPart && note == 'With pump');
    _noteController = TextEditingController(
      text: _usesPresetNote(note) ? '' : note,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _heightInchesController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _timestamp,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  void _save() {
    final value = _heightUsesFeetAndInches
        ? _heightInchesValue()
        : double.tryParse(_valueController.text.trim());
    final unit = _heightUsesFeetAndInches ? 'in' : _unitController.text.trim();
    if (value == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthEntryValueUnitRequired,
          ),
        ),
      );
      return;
    }
    try {
      MeasurementValidation.validateEntry(
        type: widget.definition.type,
        value: value,
        unit: unit,
        context: _resolvedContext(),
      );
    } on MeasurementValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _measurementValidationMessage(AppLocalizations.of(context), error),
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _MeasurementEntryInput(
        timestamp: _timestamp,
        value: value,
        unit: unit,
        note: _resolvedNote(),
        context: _resolvedContext(),
      ),
    );
  }

  double? _heightInchesValue() {
    final feet = int.tryParse(_valueController.text.trim());
    final inches = int.tryParse(_heightInchesController.text.trim());
    if (feet == null || inches == null || inches < 0 || inches >= 12) {
      return null;
    }
    return (feet * 12 + inches).toDouble();
  }

  String? _resolvedNote() {
    final typedNote = _noteController.text.trim();
    if (typedNote.isNotEmpty) return typedNote;
    return null;
  }

  MeasurementContext? _resolvedContext() {
    if (_isBodyWeight) {
      return switch (_bodyWeightVariation) {
        'WakeUp' => MeasurementContext.wakeUp,
        'BedTime' => MeasurementContext.bedtime,
        'Overall' => MeasurementContext.overall,
        _ => null,
      };
    }
    if (_isBodyPart) {
      return _withPump
          ? MeasurementContext.withPump
          : MeasurementContext.withoutPump;
    }
    return null;
  }

  bool _usesPresetNote(String note) {
    return _isKnownBodyWeightVariation(note) ||
        (_isBodyPart && (note == 'With pump' || note == 'Without pump'));
  }

  bool _isKnownBodyWeightVariation(String note) {
    return note == 'WakeUp' || note == 'BedTime' || note == 'Overall';
  }

  void _setHeightUnit(bool useFeetAndInches) {
    if (_heightUsesFeetAndInches == useFeetAndInches) return;

    if (useFeetAndInches) {
      final centimeters = double.tryParse(_valueController.text.trim());
      if (centimeters == null) {
        _valueController.clear();
        _heightInchesController.clear();
      } else {
        final totalInches = (centimeters / 2.54).round();
        _valueController.text = (totalInches ~/ 12).toString();
        _heightInchesController.text = (totalInches % 12).toString();
      }
    } else {
      final totalInches = _heightInchesValue();
      _valueController.text = totalInches == null
          ? ''
          : _cleanNumber(totalInches * 2.54);
    }
    setState(() {
      _heightUsesFeetAndInches = useFeetAndInches;
      _unitController.text = useFeetAndInches ? 'in' : 'cm';
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final destination = _progressDetailTokens(context);
    final expressiveBodyWeight = _isBodyWeight && destination != null;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.dialog,
    );
    final dialogForeground = _measurementDetailForeground(
      context,
      role: _MeasurementDetailRole.dialog,
    );
    final fieldPadding = expressiveBodyWeight
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : null;
    final fieldGap = expressiveBodyWeight ? 8.0 : 10.0;
    final dateGap = expressiveBodyWeight ? 10.0 : 12.0;
    final dialog = AlertDialog(
      key: const ValueKey('measurement-trend-entry-dialog'),
      title: Text(widget.title),
      backgroundColor: expressiveBodyWeight ? surface : null,
      surfaceTintColor: expressiveBodyWeight ? Colors.transparent : null,
      titleTextStyle: expressiveBodyWeight
          ? theme.textTheme.titleLarge?.copyWith(
              color: _measurementDetailForeground(
                context,
                role: _MeasurementDetailRole.dialog,
              ),
              fontWeight: FontWeight.w800,
            )
          : null,
      contentTextStyle: expressiveBodyWeight
          ? theme.textTheme.bodyMedium?.copyWith(
              color: _measurementDetailSupportingForeground(
                context,
                role: _MeasurementDetailRole.dialog,
              ),
            )
          : null,
      shape: expressiveBodyWeight
          ? RoundedRectangleBorder(
              borderRadius: context.shapeTokens.healthTrendCard,
              side: BorderSide(
                color: destination.outlineAccent.withValues(alpha: 0.48),
              ),
            )
          : null,
      contentPadding: expressiveBodyWeight
          ? const EdgeInsets.fromLTRB(24, 12, 24, 6)
          : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isHeight) ...[
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      '${strings.measurementFeet}/${strings.measurementInches}',
                    ),
                    selected: _heightUsesFeetAndInches,
                    onSelected: (_) => _setHeightUnit(true),
                  ),
                  ChoiceChip(
                    label: Text(strings.measurementCentimeters),
                    selected: !_heightUsesFeetAndInches,
                    onSelected: (_) => _setHeightUnit(false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (_heightUsesFeetAndInches)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.measurementFeet,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightInchesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.measurementInches,
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                key: AppTestKeys.measurementEntryValue,
                controller: _valueController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: expressiveBodyWeight
                    ? theme.textTheme.headlineSmall?.copyWith(
                        color: dialogForeground,
                        fontWeight: FontWeight.w700,
                      )
                    : null,
                decoration: InputDecoration(
                  contentPadding: fieldPadding,
                  prefixIcon: expressiveBodyWeight
                      ? const Icon(Icons.monitor_weight_outlined)
                      : null,
                  filled: expressiveBodyWeight,
                  fillColor: expressiveBodyWeight
                      ? Color.alphaBlend(
                          destination.surfaceSelected.withValues(alpha: 0.30),
                          surface,
                        )
                      : null,
                  prefixIconColor: expressiveBodyWeight
                      ? destination.actionPrimary
                      : null,
                  labelText: _measurementTitle(widget.definition, strings),
                  labelStyle: expressiveBodyWeight
                      ? theme.textTheme.bodySmall?.copyWith(
                          color: dialogForeground,
                        )
                      : null,
                  floatingLabelStyle: expressiveBodyWeight
                      ? theme.textTheme.bodySmall?.copyWith(
                          color: destination.actionPrimary,
                        )
                      : null,
                ),
              ),
            SizedBox(height: fieldGap),
            if (!_heightUsesFeetAndInches)
              TextField(
                key: AppTestKeys.measurementEntryUnit,
                controller: _unitController,
                decoration: InputDecoration(
                  contentPadding: fieldPadding,
                  labelText: strings.healthUnit,
                ),
              ),
            if (!_heightUsesFeetAndInches) SizedBox(height: fieldGap),
            if (_isBodyWeight) ...[
              DropdownButtonFormField<String>(
                key: const ValueKey('measurement-entry-variation'),
                initialValue: _bodyWeightVariation,
                isExpanded: expressiveBodyWeight,
                decoration: InputDecoration(
                  contentPadding: fieldPadding,
                  labelText: strings.measurementVariation,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'WakeUp',
                    child: Text(strings.measurementWakeUp),
                  ),
                  DropdownMenuItem(
                    value: 'BedTime',
                    child: Text(strings.measurementBedtime),
                  ),
                  DropdownMenuItem(
                    value: 'Overall',
                    child: Text(strings.measurementOverall),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _bodyWeightVariation = value);
                },
              ),
              SizedBox(height: fieldGap),
            ],
            if (_isBodyPart)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _withPump,
                onChanged: (value) =>
                    setState(() => _withPump = value ?? false),
                title: Text(strings.measurementWithPump),
              ),
            TextField(
              key: const ValueKey('measurement-entry-note'),
              controller: _noteController,
              decoration: InputDecoration(
                contentPadding: fieldPadding,
                labelText: strings.healthNote,
                hintText: strings.healthOptional,
              ),
            ),
            SizedBox(height: dateGap),
            SizedBox(
              width: expressiveBodyWeight ? double.infinity : null,
              child: expressiveBodyWeight
                  ? OutlinedButton(
                      key: const ValueKey('measurement-entry-date'),
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: destination.actionPrimary,
                        side: BorderSide(
                          color: destination.outlineAccent.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        minimumSize: const Size(48, 48),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(
                              _timestamp,
                              Localizations.localeOf(context),
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ],
                      ),
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('measurement-entry-date'),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _formatDateTime(
                          _timestamp,
                          Localizations.localeOf(context),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          key: AppTestKeys.measurementEntrySave,
          onPressed: _save,
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ],
    );
    return expressiveBodyWeight
        ? _withMeasurementDetailSurfaceTheme(
            context,
            role: _MeasurementDetailRole.dialog,
            child: dialog,
          )
        : dialog;
  }
}

class _MeasurementDefinitionDialog extends StatefulWidget {
  const _MeasurementDefinitionDialog();

  @override
  State<_MeasurementDefinitionDialog> createState() =>
      _MeasurementDefinitionDialogState();
}

class _MeasurementDefinitionDialogState
    extends State<_MeasurementDefinitionDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'in');
  final _initialValueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _initialValueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final initialText = _initialValueController.text.trim();
    final initialValue = initialText.isEmpty
        ? null
        : double.tryParse(initialText);

    if (name.isEmpty ||
        unit.isEmpty ||
        (initialText.isNotEmpty && initialValue == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthDefinitionFieldsRequired,
          ),
        ),
      );
      return;
    }
    try {
      MeasurementValidation.validateDefinition(name: name, unit: unit);
      if (initialValue != null) {
        MeasurementValidation.validateEntry(
          type: MeasurementType.Custom,
          value: initialValue,
          unit: unit,
        );
      }
    } on MeasurementValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _measurementValidationMessage(AppLocalizations.of(context), error),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _MeasurementDefinitionInput(
        name: name,
        unit: unit,
        initialValue: initialValue,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return AlertDialog(
      title: Text(AppLocalizations.of(context).healthCreateMetric),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthMetricName,
                hintText: AppLocalizations.of(context).healthMetricNameHint,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthUnit,
                hintText: AppLocalizations.of(context)
                    .healthUnitHint(weightUnit.shortLabel),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _initialValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthStartingValue,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthNote,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).healthCreate),
        ),
      ],
    );
  }
}

class _MeasurementTrend {
  final MeasurementDefinition definition;
  final List<Measurement> entries;

  const _MeasurementTrend({required this.definition, required this.entries});

  Measurement? get latest => entries.isEmpty ? null : entries.last;

  Measurement? get previous =>
      entries.length < 2 ? null : entries[entries.length - 2];

  double? get delta {
    final last = latest;
    final prior = previous;
    if (last == null || prior == null) return null;
    return last.value - prior.value;
  }
}

String _measurementTrendSemanticsLabel(
  MeasurementDefinition definition,
  List<Measurement> entries,
  AppLocalizations strings,
  Locale locale,
) {
  final latest = entries.isEmpty ? null : entries.last;
  final latestValue = latest == null
      ? strings.healthNoEntry
      : _formatMeasurement(latest, locale);
  final summary = strings.healthTrendChartSemantics(
    _measurementTitle(definition, strings),
    entries.length,
    latestValue,
  );
  final latestDate = latest == null
      ? null
      : '${strings.healthLatest}: ${LocalizedFormatters.dateTime(latest.displayDateTime, locale)}';
  final sparseState = entries.isEmpty
      ? strings.healthTrendNeedEntries
      : entries.length == 1
      ? strings.healthTrendNeedOneMore
      : null;
  return [summary, latestDate, sparseState].whereType<String>().join(' ');
}

String _measurementPointSemanticsValue(Measurement entry, Locale locale) {
  return '${LocalizedFormatters.dateTime(entry.displayDateTime, locale)}, ${_formatMeasurement(entry, locale)}';
}

class _MeasurementEntryInput {
  final DateTime timestamp;
  final double value;
  final String unit;
  final String? note;
  final MeasurementContext? context;

  const _MeasurementEntryInput({
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
    this.context,
  });
}

String _measurementValidationMessage(
  AppLocalizations strings,
  MeasurementValidationException error,
) {
  return switch (error.error) {
    MeasurementValidationError.missingName ||
    MeasurementValidationError.invalidName ||
    MeasurementValidationError.duplicateName ||
    MeasurementValidationError.invalidUnit => strings.healthMetricInvalid,
    MeasurementValidationError.unsupportedUnit ||
    MeasurementValidationError.invalidValue ||
    MeasurementValidationError.implausibleValue ||
    MeasurementValidationError.invalidContext =>
      strings.healthMeasurementEntryInvalid,
  };
}

class _MeasurementDefinitionInput {
  final String name;
  final String unit;
  final double? initialValue;
  final String? note;

  const _MeasurementDefinitionInput({
    required this.name,
    required this.unit,
    this.initialValue,
    this.note,
  });
}

class _ChartBounds {
  final double minY;
  final double maxY;
  final double interval;

  const _ChartBounds({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}

List<FlSpot> _spotsFor(List<Measurement> entries) {
  return List.generate(
    entries.length,
    (index) => FlSpot(index.toDouble(), entries[index].value),
  );
}

Set<int> _measurementDateTickIndexes(List<Measurement> entries) {
  final firstIndexByDay = <String, int>{};
  for (var index = 0; index < entries.length; index++) {
    firstIndexByDay.putIfAbsent(
      entries[index].calendarDay.storageKey,
      () => index,
    );
  }
  final dayIndexes = firstIndexByDay.values.toList(growable: false);
  const maxLabels = 5;
  if (dayIndexes.length <= maxLabels) return dayIndexes.toSet();

  return List.generate(
    maxLabels,
    (index) =>
        dayIndexes[(index * (dayIndexes.length - 1) / (maxLabels - 1)).round()],
  ).toSet();
}

_ChartBounds _chartBounds(List<double> values) {
  if (values.isEmpty) {
    return const _ChartBounds(minY: 0, maxY: 1, interval: 1);
  }

  final dataMin = values.reduce(math.min);
  final dataMax = values.reduce(math.max);
  final range = dataMax - dataMin;
  final valueScale = math.max(dataMin.abs(), dataMax.abs()).toDouble();
  final precisionFloor = valueScale * 2.220446049250313e-16 * 8;
  final padding = range == 0
      ? (valueScale == 0
            ? 1.0
            : math.max(valueScale * 0.04, precisionFloor).toDouble())
      : math.max(range * 0.08, precisionFloor).toDouble();
  final rawInterval = math
      .max((range + 2 * padding) / 4, precisionFloor)
      .toDouble();
  final interval = _niceChartInterval(rawInterval);
  final minY = (((dataMin - padding) / interval).floor() * interval).toDouble();
  final maxY = (((dataMax + padding) / interval).ceil() * interval).toDouble();
  return _ChartBounds(
    minY: minY,
    maxY: maxY > minY ? maxY : minY + interval,
    interval: interval,
  );
}

double _niceChartInterval(double interval) {
  if (!interval.isFinite || interval <= 0) return 1;
  final exponent = math.pow(10, (math.log(interval) / math.ln10).floor());
  final magnitude = exponent.toDouble();
  final fraction = interval / magnitude;
  final niceFraction = switch (fraction) {
    <= 1 => 1.0,
    <= 2 => 2.0,
    <= 2.5 => 2.5,
    <= 5 => 5.0,
    _ => 10.0,
  };
  return niceFraction * magnitude;
}

List<double> _chartYAxisTickValues(_ChartBounds bounds) {
  final count = ((bounds.maxY - bounds.minY) / bounds.interval)
      .round()
      .clamp(1, 8)
      .toInt();
  return List.generate(
    count + 1,
    (index) => bounds.minY + bounds.interval * index,
  );
}

List<String> _formatChartYAxisLabels(
  List<double> values,
  double interval,
  Locale locale,
) {
  final compactLabels = values
      .map((value) => LocalizedFormatters.compactNumber(value, locale))
      .toList(growable: false);
  if (compactLabels.toSet().length == compactLabels.length) {
    return compactLabels;
  }

  var fractionDigits = _chartIntervalFractionDigits(interval);
  while (fractionDigits <= 12) {
    final labels = values
        .map(
          (value) => LocalizedFormatters.number(
            value,
            locale,
            minimumFractionDigits: fractionDigits,
            maximumFractionDigits: fractionDigits,
          ),
        )
        .toList(growable: false);
    if (labels.toSet().length == labels.length) return labels;
    fractionDigits++;
  }

  return values
      .map(
        (value) => LocalizedFormatters.number(
          value,
          locale,
          maximumFractionDigits: 12,
        ),
      )
      .toList(growable: false);
}

int _chartIntervalFractionDigits(double interval) {
  for (var fractionDigits = 0; fractionDigits <= 12; fractionDigits++) {
    final scale = math.pow(10, fractionDigits).toDouble();
    final scaledInterval = interval * scale;
    if ((scaledInterval - scaledInterval.round()).abs() < 1e-7) {
      return fractionDigits;
    }
  }
  return 12;
}

double _chartYAxisReservedSize(
  BuildContext context,
  List<String> labels,
  TextStyle? style,
  Locale locale,
) {
  var widestLabel = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: locale,
      maxLines: 1,
    )..layout();
    widestLabel = math.max(widestLabel, painter.width).toDouble();
  }
  return (widestLabel + 8).clamp(42.0, 100.0).toDouble();
}

int _definitionOrder(MeasurementDefinition definition) {
  const order = <MeasurementType, int>{
    MeasurementType.BodyWeight: 0,
    MeasurementType.Height: 1,
    MeasurementType.Chest: 2,
    MeasurementType.Waist: 3,
    MeasurementType.Hip: 4,
    MeasurementType.Shoulder: 5,
    MeasurementType.Arm: 6,
    MeasurementType.Forearm: 7,
    MeasurementType.Thigh: 8,
    MeasurementType.Calf: 9,
    MeasurementType.Neck: 10,
    MeasurementType.Custom: 100,
  };
  return order[definition.type] ?? 100;
}

String _measurementTitle(
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

String _measurementSortName(MeasurementDefinition definition) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => 'Weight',
    MeasurementType.Height => 'Height',
    MeasurementType.Forearm => 'Forearm',
    MeasurementType.Arm => 'Arm',
    MeasurementType.Neck => 'Neck',
    MeasurementType.Shoulder => 'Shoulders',
    MeasurementType.Chest => 'Chest',
    MeasurementType.Waist => 'Waist',
    MeasurementType.Hip => 'Hips',
    MeasurementType.Thigh => 'Thigh',
    MeasurementType.Calf => 'Calves',
    MeasurementType.Custom => definition.name,
  };
}

String _defaultUnitFor(
  MeasurementDefinition definition, [
  WeightUnit weightUnit = WeightUnit.pounds,
]) {
  return switch (definition.type) {
    MeasurementType.BodyWeight => weightUnit.shortLabel,
    MeasurementType.Height => 'in',
    MeasurementType.Custom => '',
    _ => 'in',
  };
}

String _formatMeasurement(Measurement entry, Locale locale) {
  return '${_localizedNumber(entry.value, locale)} ${entry.unit}'.trim();
}

String _formatDelta(double? delta, AppLocalizations strings, Locale locale) {
  if (delta == null || delta.abs() < 0.001) return strings.healthNoChange;
  final prefix = delta > 0 ? '+' : '';
  return strings.healthChangeSinceLast(
    '$prefix${_localizedNumber(delta, locale)}',
  );
}

String _localizedNumber(double value, Locale locale) {
  final maximumFractionDigits =
      value.abs() >= 1000 || value == value.roundToDouble() ? 0 : 1;
  return LocalizedFormatters.number(
    value,
    locale,
    maximumFractionDigits: maximumFractionDigits,
  );
}

String? _measurementContextLabel(Measurement entry, AppLocalizations strings) {
  final context = entry.context ?? _legacyMeasurementContext(entry.note);
  return switch (context) {
    MeasurementContext.wakeUp => strings.measurementWakeUp,
    MeasurementContext.bedtime => strings.measurementBedtime,
    MeasurementContext.overall => strings.measurementOverall,
    MeasurementContext.withPump => strings.measurementWithPump,
    MeasurementContext.withoutPump => strings.measurementWithoutPump,
    null => null,
  };
}

MeasurementContext? _legacyMeasurementContext(String? note) {
  return switch (note?.trim()) {
    'WakeUp' => MeasurementContext.wakeUp,
    'BedTime' => MeasurementContext.bedtime,
    'Overall' => MeasurementContext.overall,
    'With pump' => MeasurementContext.withPump,
    'Without pump' => MeasurementContext.withoutPump,
    _ => null,
  };
}

String? _measurementNote(Measurement entry) {
  final note = entry.note?.trim();
  if (note == null || note.isEmpty) return null;
  return _legacyMeasurementContext(note) == null ? note : null;
}

Color? _deltaColor(BuildContext context, double? delta) {
  if (delta == null || delta.abs() < 0.001) {
    return Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7);
  }
  final surface = _healthTrendCardSurface(context);
  return delta > 0
      ? tonosHealthIncreaseForSurface(context, surface)
      : tonosHealthDecreaseForSurface(context, surface);
}

String _cleanNumber(double value) {
  if (value.abs() >= 1000) {
    return value.toStringAsFixed(0);
  }
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String _shortDate(DateTime value, Locale locale) {
  return LocalizedFormatters.shortDate(value, locale);
}

String _formatDateTime(DateTime value, Locale locale) {
  return LocalizedFormatters.dateTime(value, locale);
}
