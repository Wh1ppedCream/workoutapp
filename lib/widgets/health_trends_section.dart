import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/widgets/tonos_expressive_state_motion.dart';
import '../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../services/tutorial_state_store.dart';
import '../services/measurement_validation.dart';
import '../services/height_unit.dart';
import '../services/measurement_comparison.dart';
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

part 'health_trends/trend_tiles.dart';
part 'health_trends/measurement_charts.dart';
part 'health_trends/measurement_dialogs.dart';
part 'health_trends/measurement_models_and_units.dart';

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

AppExpressiveDestinationTokens? _measurementDetailTokens(BuildContext context) {
  return context.usesExpressivePresentation
      ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
      : null;
}

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

AppExpressiveDestinationTokens? _profileMeasurementTokens(
  BuildContext context,
) {
  if (!context.usesExpressivePresentation) return null;
  final tokens = Theme.of(context).extension<AppExpressiveDestinationTokens>();
  return tokens?.family == AppExpressiveDestinationFamily.profile
      ? tokens
      : null;
}

bool _usesExpressiveHealthTrendChart(BuildContext context) =>
    context.usesExpressivePresentation;

Color _measurementTrendChartSurface(BuildContext context) {
  if (_usesExpressiveHealthTrendChart(context)) {
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    if (destination != null) {
      return Theme.of(context).brightness == Brightness.light
          ? Color.lerp(
              destination.surfaceSecondary,
              destination.pageCanvas,
              0.28,
            )!
          : destination.surfaceSecondary;
    }
  }
  if (context.usesNeoPresentation) return context.surfaceTokens.card;
  return context.progressColors.healthCard;
}

Widget _withMeasurementTrendChartTheme(
  BuildContext context, {
  required Widget child,
}) {
  if (!_usesExpressiveHealthTrendChart(context)) return child;
  final destination = Theme.of(context)
      .extension<AppExpressiveDestinationTokens>();
  if (destination == null) return child;

  final theme = Theme.of(context);
  final foreground = destination.onSurfaceSecondary;
  final supportingForeground = foreground.withValues(alpha: 0.82);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: _measurementTrendChartSurface(context),
        onSurface: foreground,
        onSurfaceVariant: supportingForeground,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      iconTheme: theme.iconTheme.copyWith(color: foreground),
    ),
    child: child,
  );
}

Color _profileMeasurementDialogSurface(
  BuildContext context,
  AppExpressiveDestinationTokens tokens,
) {
  return Theme.of(context).brightness == Brightness.light
      ? Color.lerp(tokens.pageCanvas, tokens.surfaceTertiary, 0.30)!
      : tokens.surfaceTertiary;
}

ThemeData _profileMeasurementDialogTheme(
  BuildContext context,
  AppExpressiveDestinationTokens tokens,
) {
  final theme = Theme.of(context);
  final surface = _profileMeasurementDialogSurface(context, tokens);
  final outline = tokens.outlineAccent;
  final fieldShape = context.shapeTokens.healthTrendEntry;
  final fieldBorder = OutlineInputBorder(
    borderRadius: fieldShape,
    borderSide: BorderSide(color: outline.withValues(alpha: 0.45)),
  );
  final selectedFill = Color.alphaBlend(
    tokens.surfaceSelected.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.48 : 0.30,
    ),
    surface,
  );
  final selectedSegmentFill = theme.brightness == Brightness.dark
      ? Color.alphaBlend(
          tokens.actionPrimary.withValues(alpha: 0.16),
          tokens.surfaceSelected,
        )
      : tokens.surfaceSelected;

  return theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(
      surface: surface,
      onSurface: tokens.supportingForeground,
      onSurfaceVariant: tokens.supportingForeground,
      primary: tokens.actionPrimary,
      onPrimary: tokens.onActionPrimary,
      secondaryContainer: tokens.surfaceSelected,
      onSecondaryContainer: tokens.onSurfaceSelected,
      outline: outline,
    ),
    textTheme: theme.textTheme.apply(
      bodyColor: tokens.supportingForeground,
      displayColor: tokens.supportingForeground,
    ),
    iconTheme: theme.iconTheme.copyWith(color: tokens.supportingForeground),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: selectedFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldShape,
        borderSide: BorderSide(color: tokens.actionPrimary, width: 2),
      ),
      labelStyle: TextStyle(color: tokens.supportingForeground),
      floatingLabelStyle: TextStyle(color: tokens.actionPrimary),
      hintStyle: TextStyle(
        color: tokens.supportingForeground.withValues(alpha: 0.78),
      ),
    ),
    segmentedButtonTheme: theme.segmentedButtonTheme.copyWith(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? tokens.onSurfaceSelected
              : tokens.supportingForeground;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? selectedSegmentFill
              : tokens.surfaceAccent.withValues(alpha: 0.36);
        }),
        side: WidgetStateProperty.resolveWith((states) {
          return BorderSide(
            color: outline.withValues(
              alpha: states.contains(WidgetState.selected) ? 0.72 : 0.40,
            ),
          );
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: context.shapeTokens.dialogChoice,
          ),
        ),
      ),
    ),
  );
}

Color _measurementDetailSurface(
  BuildContext context, {
  _MeasurementDetailRole role = _MeasurementDetailRole.history,
}) {
  final destination = role == _MeasurementDetailRole.dialog
      ? _progressDetailTokens(context)
      : _measurementDetailTokens(context);
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
      _MeasurementDetailRole.dialog => Color.lerp(
        destination.pageCanvas,
        destination.surfaceSelected,
        isLight ? 0.54 : 0.56,
      )!,
    };
  }
  return _healthTrendCardSurface(context);
}

Color _measurementDetailForeground(
  BuildContext context, {
  _MeasurementDetailRole role = _MeasurementDetailRole.history,
}) {
  final destination = role == _MeasurementDetailRole.dialog
      ? _progressDetailTokens(context)
      : _measurementDetailTokens(context);
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
  final destination = role == _MeasurementDetailRole.dialog
      ? _progressDetailTokens(context)
      : _measurementDetailTokens(context);
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
  bool expressiveFormFields = false,
}) {
  final destination = role == _MeasurementDetailRole.dialog
      ? _progressDetailTokens(context)
      : _measurementDetailTokens(context);
  if (destination == null) return child;

  final theme = Theme.of(context);
  final surface = _measurementDetailSurface(context, role: role);
  final foreground = _measurementDetailForeground(context, role: role);
  final supportingForeground = _measurementDetailSupportingForeground(
    context,
    role: role,
  );
  final dialogRole = role == _MeasurementDetailRole.dialog;
  final dialogFieldBorder = OutlineInputBorder(
    borderRadius: context.shapeTokens.healthTrendEntry,
    borderSide: BorderSide(
      color: destination.outlineAccent.withValues(alpha: 0.52),
    ),
  );
  final dialogFieldFill = Color.alphaBlend(
    destination.surfaceSelected.withValues(alpha: 0.30),
    surface,
  );
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
              filled: expressiveFormFields,
              fillColor: expressiveFormFields ? dialogFieldFill : null,
              border: expressiveFormFields ? dialogFieldBorder : null,
              enabledBorder: expressiveFormFields
                  ? dialogFieldBorder
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: destination.outlineAccent.withValues(
                          alpha: 0.52,
                        ),
                      ),
                    ),
              focusedBorder: expressiveFormFields
                  ? dialogFieldBorder.copyWith(
                      borderSide: BorderSide(
                        color: destination.actionPrimary,
                        width: 2,
                      ),
                    )
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: destination.actionPrimary,
                        width: 2,
                      ),
                    ),
              floatingLabelStyle: TextStyle(color: destination.actionPrimary),
              labelStyle: expressiveFormFields
                  ? theme.textTheme.labelSmall?.copyWith(
                      color: supportingForeground,
                    )
                  : TextStyle(color: supportingForeground),
              floatingLabelBehavior: expressiveFormFields
                  ? FloatingLabelBehavior.always
                  : null,
              contentPadding: expressiveFormFields
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 13)
                  : null,
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
  return _measurementDetailTokens(context)?.pageCanvas;
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
    final route = MaterialPageRoute<bool>(
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
    );
    final changed = await Navigator.of(context).push<bool>(route);
    if (changed == true && mounted && context.usesExpressivePresentation) {
      // The covered parent may still have its tickers disabled at this point.
      await route.completed;
    }
    if (changed == true && mounted) {
      _reload();
      _notifyChanged();
    }
  }

  Future<void> _logEntry(_MeasurementTrend trend) async {
    final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
    final input = await _showMeasurementEntryDialog(
      context: context,
      builder: (_) => _MeasurementEntryDialog(
        title: _strings.healthLogMeasurement(
          _measurementTitle(trend.definition, _strings),
        ),
        definition: trend.definition,
        defaultUnit:
            trend.latest?.unit ?? _defaultUnitFor(trend.definition, weightUnit),
        measurementLibrary:
            widget.fullPage && _profileMeasurementTokens(context) != null,
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
    final input = await showTonosDialog<_MeasurementDefinitionInput>(
      context: context,
      builder: (_) => TonosDialogFrame(
        styleFormControls: true,
        child: _MeasurementDefinitionDialog(
          measurementLibrary:
              widget.fullPage && _profileMeasurementTokens(context) != null,
        ),
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
              widget.fullPage && _profileMeasurementTokens(context) != null
                  ? strings.healthTrackedMetrics
                  : strings.healthTrendsTitle,
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
        if (snapshot.connectionState != ConnectionState.done &&
            !(context.usesExpressivePresentation && snapshot.hasData)) {
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
                measurementLibrary: _profileMeasurementTokens(context) != null,
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
    final input = await _showMeasurementEntryDialog(
      context: context,
      builder: (_) => _MeasurementEntryDialog(
        title: _strings.healthLogMeasurement(
          _measurementTitle(widget.definition, _strings),
        ),
        definition: widget.definition,
        defaultUnit: entries.isNotEmpty
            ? entries.last.unit
            : _defaultUnitFor(widget.definition, weightUnit),
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
    final input = await _showMeasurementEntryDialog(
      context: context,
      builder: (_) => _MeasurementEntryDialog(
        title: _strings.healthEditMeasurement(
          _measurementTitle(widget.definition, _strings),
        ),
        definition: widget.definition,
        defaultUnit: entry.unit,
        entry: entry,
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
    final expressive = _progressDetailTokens(context) != null;
    final confirmed = await showTonosDialog<bool>(
      context: context,
      builder: (context) => TonosDialogFrame(
        child: AlertDialog(
          key: const ValueKey('measurement-trend-delete-entry-dialog'),
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
          backgroundColor: expressive
              ? _measurementDetailSurface(
                  context,
                  role: _MeasurementDetailRole.dialog,
                )
              : null,
          insetPadding: expressive
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
              : null,
          titlePadding: expressive
              ? const EdgeInsets.fromLTRB(24, 20, 24, 4)
              : null,
          contentPadding: expressive
              ? const EdgeInsets.fromLTRB(24, 8, 24, 6)
              : null,
          surfaceTintColor: expressive ? Colors.transparent : null,
          shape: expressive
              ? RoundedRectangleBorder(
                  borderRadius: context.shapeTokens.healthTrendCard,
                  side: BorderSide(
                    color: _progressDetailTokens(context)!.outlineAccent
                        .withValues(alpha: 0.48),
                  ),
                )
              : null,
          scrollable: expressive,
          titleTextStyle: expressive
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _measurementDetailForeground(
                    context,
                    role: _MeasurementDetailRole.dialog,
                  ),
                  fontWeight: FontWeight.w800,
                )
              : null,
          contentTextStyle: expressive
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _measurementDetailSupportingForeground(
                    context,
                    role: _MeasurementDetailRole.dialog,
                  ),
                )
              : null,
          actionsPadding: expressive
              ? const EdgeInsets.fromLTRB(20, 4, 20, 16)
              : null,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_strings.commonCancel),
            ),
            expressive
                ? FilledButton(
                    key: const ValueKey('measurement-trend-delete-confirm'),
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      minimumSize: const Size(84, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: context.shapeTokens.dialogChoice,
                      ),
                    ),
                    child: Text(_strings.commonDelete),
                  )
                : TextButton(
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
    final detailTokens = _measurementDetailTokens(context);
    final expressiveDetail = detailTokens != null;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: detailTokens?.pageCanvas,
        appBar: AppBar(
          key: const ValueKey('measurement-trend-detail-app-bar'),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Text(title),
          titleTextStyle: expressiveDetail
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                )
              : null,
          backgroundColor: _measurementDetailAppBarSurface(context),
          foregroundColor: expressiveDetail
              ? Theme.of(context).colorScheme.onSurface
              : null,
          surfaceTintColor: expressiveDetail ? Colors.transparent : null,
          elevation: expressiveDetail ? 0 : null,
          scrolledUnderElevation: expressiveDetail ? 0 : null,
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
            if (snapshot.connectionState != ConnectionState.done &&
                !(context.usesExpressivePresentation && snapshot.hasData)) {
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
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                expressiveDetail ? 24 : 100,
              ),
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
                    height: context.usesExpressivePresentation ? 225 : 250,
                  ),
                ),
                SizedBox(height: expressiveDetail ? 16 : 20),
                KeyedSubtree(
                  key: _entriesTutorialKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.healthEntries,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: expressiveDetail ? 20 : null,
                          fontWeight: expressiveDetail ? FontWeight.w700 : null,
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
                            type: widget.definition.type,
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
                style: expressiveDetail
                    ? FilledButton.styleFrom(
                        backgroundColor: detailTokens.actionPrimary,
                        foregroundColor: detailTokens.onActionPrimary,
                        minimumSize: const Size.fromHeight(48),
                        textStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(
                          borderRadius: ExpressiveTrainShapes.compactControl,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
