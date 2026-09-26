import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/exercise_catalog_page.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../services/exercise_content_localizer.dart';
import '../services/tutorial_state_store.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_progress_colors.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/localized_formatters.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/weight_unit_formatter.dart';
import 'guided_tutorial_overlay.dart';
import 'localized_exercise_name.dart';

const _exerciseProgressTileIdsKey = 'exercise_progress_tile_ids_v1';
const _exerciseProgressHiddenAutoIdsKey =
    'exercise_progress_hidden_auto_ids_v1';

class ExerciseProgressSection extends StatefulWidget {
  final int refreshToken;

  const ExerciseProgressSection({super.key, this.refreshToken = 0});

  @override
  State<ExerciseProgressSection> createState() =>
      _ExerciseProgressSectionState();
}

class _ExerciseProgressSectionState extends State<ExerciseProgressSection>
    with AutomaticKeepAliveClientMixin<ExerciseProgressSection> {
  AppRepository get _repo => context.read<AppRepository>();

  late Future<_ExerciseProgressSectionData> _dataFuture;
  _ExerciseProgressSectionData? _lastData;
  List<int> _savedDefinitionIds = const <int>[];
  List<int> _hiddenAutoDefinitionIds = const <int>[];
  List<int> _visibleDefinitionIds = const <int>[];
  int? _selectedDefinitionId;
  bool _isEditingExerciseProgress = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  void didUpdateWidget(covariant ExerciseProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _reload() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  Future<_ExerciseProgressSectionData> _loadData() async {
    final prefsFuture = SharedPreferences.getInstance();
    final mostUsedRowsFuture = _repo.fetchMostUsedExerciseDefinitionsRaw(
      limit: 1,
    );

    final prefs = await prefsFuture;
    final savedIds =
        prefs
            .getStringList(_exerciseProgressTileIdsKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toList() ??
        const <int>[];
    _savedDefinitionIds = savedIds;
    final hiddenAutoIds =
        prefs
            .getStringList(_exerciseProgressHiddenAutoIdsKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toList() ??
        const <int>[];
    _hiddenAutoDefinitionIds = hiddenAutoIds;

    final ids = <int>[];
    final mostUsedRows = await mostUsedRowsFuture;
    final mostUsedId =
        mostUsedRows.isEmpty
            ? null
            : (mostUsedRows.first['definition_id'] as num?)?.toInt();
    if (mostUsedId != null &&
        (!hiddenAutoIds.contains(mostUsedId) ||
            savedIds.contains(mostUsedId))) {
      ids.add(mostUsedId);
    }
    for (final id in savedIds) {
      if (!ids.contains(id)) ids.add(id);
    }
    _visibleDefinitionIds = ids;

    if (ids.isEmpty) {
      return const _ExerciseProgressSectionData(tiles: <_ExerciseTrendTile>[]);
    }

    final definitions = await _repo.lookupDefsDetailedByIds(ids);
    final definitionById = {for (final def in definitions) def.id: def};
    final tiles = <_ExerciseTrendTile>[];
    for (final id in ids) {
      final definition = definitionById[id];
      if (definition == null) continue;
      final rows = await _repo.fetchExerciseOneRmTrendRows(
        definitionId: id,
        limit: 60,
      );
      tiles.add(
        _ExerciseTrendTile(
          definition: definition,
          points: rows.map(_ExerciseProgressPoint.fromRow).toList(),
        ),
      );
    }

    return _ExerciseProgressSectionData(tiles: tiles);
  }

  Future<void> _addExerciseTile(ExerciseDefinition definition) async {
    if (_visibleDefinitionIds.contains(definition.id)) {
      final displayName = await ExerciseContentLocalizer.instance.resolveName(
        definition,
        Localizations.localeOf(context),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.exerciseProgressAlreadyShown(displayName)),
        ),
      );
      return;
    }

    final nextIds = [
      ..._savedDefinitionIds,
      if (!_savedDefinitionIds.contains(definition.id)) definition.id,
    ];
    final nextHiddenAutoIds = [
      for (final id in _hiddenAutoDefinitionIds)
        if (id != definition.id) id,
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _exerciseProgressTileIdsKey,
      nextIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(
      _exerciseProgressHiddenAutoIdsKey,
      nextHiddenAutoIds.map((id) => id.toString()).toList(),
    );
    if (!mounted) return;
    setState(() {
      _savedDefinitionIds = nextIds;
      _hiddenAutoDefinitionIds = nextHiddenAutoIds;
      _dataFuture = _loadData();
    });
  }

  Future<void> _removeExerciseTile(_ExerciseTrendTile tile) async {
    final id = tile.definition.id;
    final nextSavedIds = [
      for (final savedId in _savedDefinitionIds)
        if (savedId != id) savedId,
    ];
    final nextHiddenAutoIds = [
      ..._hiddenAutoDefinitionIds,
      if (!_savedDefinitionIds.contains(id) &&
          !_hiddenAutoDefinitionIds.contains(id))
        id,
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _exerciseProgressTileIdsKey,
      nextSavedIds.map((savedId) => savedId.toString()).toList(),
    );
    await prefs.setStringList(
      _exerciseProgressHiddenAutoIdsKey,
      nextHiddenAutoIds.map((hiddenId) => hiddenId.toString()).toList(),
    );
    if (!mounted) return;
    setState(() {
      if (_selectedDefinitionId == id) _selectedDefinitionId = null;
      _savedDefinitionIds = nextSavedIds;
      _hiddenAutoDefinitionIds = nextHiddenAutoIds;
      _visibleDefinitionIds = [
        for (final visibleId in _visibleDefinitionIds)
          if (visibleId != id) visibleId,
      ];
      final lastData = _lastData;
      if (lastData != null) {
        _lastData = _ExerciseProgressSectionData(
          tiles: [
            for (final existingTile in lastData.tiles)
              if (existingTile.definition.id != id) existingTile,
          ],
        );
      }
      _dataFuture = _loadData();
    });
  }

  void _openExercisePicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ExerciseCatalogPage(
              onExercisePicked: (definition) {
                unawaited(_addExerciseTile(definition));
              },
            ),
      ),
    );
  }

  void _openDetail(_ExerciseTrendTile tile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ExerciseProgressDetailPage(tile: tile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final dataVisualization = context.dataVisualizationTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final surfaces = context.surfaceTokens;
    final sectionForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              surfaces.exerciseProgressSelector,
            )
            : null;

    return FutureBuilder<_ExerciseProgressSectionData>(
      future: _dataFuture,
      initialData: _lastData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _lastData = snapshot.data;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = _ExerciseProgressLayout.fromWidth(
              constraints.maxWidth,
            );

            Widget shell(Widget child) {
              if (usesInkRecipe) {
                return TonosSurface(
                  variant: TonosSurfaceVariant.panelRaised,
                  color: surfaces.exerciseProgressSelector,
                  padding: EdgeInsets.all(layout.cardPadding),
                  borderRadius: context.shapeTokens.card,
                  clipBehavior: Clip.antiAlias,
                  child: child,
                );
              }
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.all(layout.cardPadding),
                  child: child,
                ),
              );
            }

            if (data == null &&
                snapshot.connectionState != ConnectionState.done) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.outerPaddingHorizontal,
                  vertical: layout.outerPaddingVertical,
                ),
                child: shell(
                  SizedBox(
                    height: layout.loadingHeight,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: dataVisualization.selection,
                      ),
                    ),
                  ),
                ),
              );
            }

            final tiles = data?.tiles ?? const <_ExerciseTrendTile>[];
            final selectedTile = _selectedTile(tiles);
            final selectedId = selectedTile?.definition.id;
            final carouselTiles = [
              for (final tile in tiles)
                if (tile.definition.id != selectedId) tile,
            ];
            final selectorChildren = <Widget>[
              for (final tile in carouselTiles)
                _ExerciseProgressSelectorTile(
                  tile: tile,
                  layout: layout,
                  isSelected: false,
                  isEditing: _isEditingExerciseProgress,
                  onRemove: () => unawaited(_removeExerciseTile(tile)),
                  onTap:
                      () => setState(() {
                        _isEditingExerciseProgress = false;
                        _selectedDefinitionId = tile.definition.id;
                      }),
                ),
              if (_isEditingExerciseProgress)
                _AddExerciseProgressTile(
                  layout: layout,
                  onTap: _openExercisePicker,
                )
              else
                _EditExerciseProgressTile(
                  layout: layout,
                  onTap:
                      () => setState(() {
                        _isEditingExerciseProgress = true;
                      }),
                ),
            ];
            final preservesClassicGeometry =
                context.usesClassicPresentation &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.15;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.outerPaddingHorizontal,
                vertical: layout.outerPaddingVertical,
              ),
              child: shell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).dashboardSectionExerciseProgressTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: sectionForeground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: layout.sectionGap),
                    if (selectedTile == null)
                      _ExerciseProgressEmptyHero(
                        layout: layout,
                        onTap: _openExercisePicker,
                      )
                    else
                      _ExerciseProgressHero(
                        tile: selectedTile,
                        layout: layout,
                        isEditing: _isEditingExerciseProgress,
                        onRemove:
                            () => unawaited(_removeExerciseTile(selectedTile)),
                        onTap: () => _openDetail(selectedTile),
                      ),
                    SizedBox(height: layout.sectionGap),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            preservesClassicGeometry
                                ? layout.selectorMinimumHeight
                                : 0,
                      ),
                      child: SingleChildScrollView(
                        key: const ValueKey('exercise-progress-selector-strip'),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment:
                              preservesClassicGeometry
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                          children: [
                            for (final child in selectorChildren)
                              if (preservesClassicGeometry)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: layout.selectorMinimumHeight,
                                  ),
                                  child: child,
                                )
                              else
                                child,
                            SizedBox(width: layout.value(4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _ExerciseTrendTile? _selectedTile(List<_ExerciseTrendTile> tiles) {
    if (tiles.isEmpty) return null;
    final selectedId = _selectedDefinitionId;
    if (selectedId != null) {
      for (final tile in tiles) {
        if (tile.definition.id == selectedId) return tile;
      }
    }
    return tiles.first;
  }
}

class _ExerciseProgressLayout {
  final double scale;

  const _ExerciseProgressLayout._(this.scale);

  factory _ExerciseProgressLayout.fromWidth(double width) {
    return _ExerciseProgressLayout._(
      (width / 416).clamp(0.84, 1.12).toDouble(),
    );
  }

  double value(double base) => base * scale;

  double get outerPaddingHorizontal => value(16);
  double get outerPaddingVertical => value(8);
  double get cardPadding => value(16);
  double get sectionGap => value(14);
  double get loadingHeight => value(248);
  double get heroPadding => value(10);
  double get heroHeight => value(226);
  double get heroChartHeight => value(166);
  double get heroStackedChartHeight => value(166);
  double get heroColumnGap => value(12);
  double get heroRowGap => value(8);
  double heroMinimumChartWidth(double textScale) =>
      168.0 * (1 + (textScale - 1) * 0.18);
  double heroMinimumStatsWidth(double textScale) => 116.0 * textScale;
  double get chartTitleGap => value(6);
  double get statPaddingHorizontal => value(9);
  double get statPaddingVertical => value(7);
  double get statBoxHeight => value(106);
  double get statIconSize => value(15);
  double get statIconGap => value(3);
  double get statLabelGap => value(3);
  double get statHelperGap => value(2);
  double get selectorMinimumHeight => value(138);
  double get selectorWidth => value(154);
  double get selectorChartHeight => value(52);
  double get selectorActionMinHeight => value(112);
  double get selectorMarginRight => value(10);
  double get selectorPadding => value(10);
  double get selectorGraphGap => value(5);
  double get selectorDeltaGap => value(3);
  double get compactIconSize => value(12);
  double get compactIconGap => value(2);
  double get removeBadgeSize => value(24);
  double get removeBadgeHitSize => math.max(48, removeBadgeSize);
  double get removeIconSize => value(15);
  double get addTileWidth => value(120);
  double get addTileMarginRight => value(8);
  double get addIconSize => value(32);
  double get emptyPadding => value(18);
  double get emptyIconSize => value(34);
  double get emptyTitleGap => value(10);
  double get emptyBodyGap => value(4);
}

class _ExerciseProgressSectionData {
  final List<_ExerciseTrendTile> tiles;

  const _ExerciseProgressSectionData({required this.tiles});
}

class _ExerciseTrendTile {
  final ExerciseDefinition definition;
  final List<_ExerciseProgressPoint> points;

  const _ExerciseTrendTile({required this.definition, required this.points});

  _ExerciseProgressPoint? get latestPoint =>
      points.isEmpty ? null : points.last;
}

class _ExerciseProgressPoint {
  final int sessionId;
  final DateTime completedAt;
  final LocalCalendarDay calendarDay;
  final double? actualOneRm;
  final double estimatedOneRm;

  const _ExerciseProgressPoint({
    required this.sessionId,
    required this.completedAt,
    required this.calendarDay,
    required this.actualOneRm,
    required this.estimatedOneRm,
  });

  DateTime get displayDateTime => calendarDay.atLocalTime(completedAt);

  factory _ExerciseProgressPoint.fromRow(Map<String, dynamic> row) {
    return _ExerciseProgressPoint(
      sessionId: row['session_id'] as int,
      completedAt: TemporalSemantics.readLocalDateTime(
        epochMilliseconds: row['completed_at_ms'],
        legacyIso: row['session_date'],
      ),
      calendarDay: TemporalSemantics.readCalendarDay(
        calendarDay: row['training_day'],
        legacyIso: row['session_date'],
        epochMilliseconds: row['completed_at_ms'],
      ),
      actualOneRm: (row['actual_one_rm'] as num?)?.toDouble(),
      estimatedOneRm: ((row['estimated_one_rm'] as num?) ?? 0).toDouble(),
    );
  }
}

class _ExerciseProgressHero extends StatelessWidget {
  final _ExerciseTrendTile tile;
  final _ExerciseProgressLayout layout;
  final bool isEditing;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _ExerciseProgressHero({
    required this.tile,
    required this.layout,
    required this.isEditing,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LocalizedExerciseNameBuilder(
      definition: tile.definition,
      builder: (context, localizedName) => _buildHero(context, localizedName),
    );
  }

  Widget _buildHero(BuildContext context, String localizedName) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final foreground = tonosForegroundForSurface(
      context,
      surfaces.exerciseProgressHero,
    );
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final tooltipForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              surfaces.exerciseProgressTooltip,
            )
            : theme.colorScheme.onSurface;
    final body = Semantics(
      button: true,
      label: localizedName,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: shapes.exerciseProgressHero * layout.scale,
        child: Padding(
          padding: EdgeInsets.all(layout.heroPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale =
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(1).clamp(1.0, 2.0).toDouble();
              final preservesClassicGeometry =
                  context.usesClassicPresentation && textScale <= 1.15;
              final minimumChartWidth = layout.heroMinimumChartWidth(textScale);
              final minimumStatsWidth = layout.heroMinimumStatsWidth(textScale);
              final classicStacked =
                  preservesClassicGeometry &&
                  constraints.maxWidth <
                      math.max(
                        layout.value(270),
                        minimumChartWidth +
                            layout.heroRowGap +
                            minimumStatsWidth,
                      );
              final useStacked =
                  constraints.maxWidth <
                  minimumChartWidth + layout.heroRowGap + minimumStatsWidth;
              final chartColumn = _ExerciseProgressHeroChart(
                tile: tile,
                localizedName: localizedName,
                layout: layout,
                chartHeight:
                    classicStacked
                        ? layout.heroStackedChartHeight
                        : layout.heroChartHeight,
                tooltipTextColor: tooltipForeground,
                isEditing: isEditing,
              );
              final statsColumn = _ExerciseProgressStatsColumn(
                tile: tile,
                layout: layout,
              );

              if (preservesClassicGeometry) {
                if (classicStacked) {
                  return Column(
                    key: const ValueKey('exercise-progress-hero-stacked'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      chartColumn,
                      SizedBox(height: layout.heroColumnGap),
                      statsColumn,
                    ],
                  );
                }
                return ConstrainedBox(
                  key: const ValueKey('exercise-progress-hero-side-by-side'),
                  constraints: BoxConstraints(minHeight: layout.heroHeight),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: chartColumn),
                      SizedBox(width: layout.heroRowGap),
                      Expanded(flex: 3, child: statsColumn),
                    ],
                  ),
                );
              }

              if (useStacked) {
                return Column(
                  key: const ValueKey('exercise-progress-hero-stacked'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    chartColumn,
                    SizedBox(height: layout.heroColumnGap),
                    statsColumn,
                  ],
                );
              }

              return Row(
                key: const ValueKey('exercise-progress-hero-side-by-side'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: chartColumn),
                  SizedBox(width: layout.heroRowGap),
                  SizedBox(width: minimumStatsWidth, child: statsColumn),
                ],
              );
            },
          ),
        ),
      ),
    );
    final content = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: surfaces.exerciseProgressHero,
          borderRadius: shapes.exerciseProgressHero * layout.scale,
        ),
        child: Stack(
          children: [
            body,
            if (isEditing)
              Positioned(
                top: 0,
                right: 0,
                child: _ExerciseProgressRemoveBadge(
                  layout: layout,
                  localizedName: localizedName,
                  onTap: onRemove,
                ),
              ),
          ],
        ),
      ),
    );
    final container = Semantics(
      container: true,
      explicitChildNodes: true,
      child: content,
    );
    if (!usesInkRecipe) return container;
    final progressColors = context.progressColors;
    // Chart descendants read the surface-resolved progress roles from Theme.
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          onSurface: foreground,
          onSurfaceVariant: foreground.withValues(alpha: 0.72),
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: foreground,
          displayColor: foreground,
        ),
        extensions: [
          for (final extension in theme.extensions.values)
            if (extension is! AppProgressColors) extension,
          progressColors.copyWith(
            estimated: foreground.withValues(alpha: 0.72),
            grid: foreground.withValues(alpha: 0.24),
            label: foreground.withValues(alpha: 0.72),
            neutral: foreground.withValues(alpha: 0.62),
          ),
        ],
      ),
      child: container,
    );
  }
}

class _ExerciseProgressHeroChart extends StatelessWidget {
  final _ExerciseTrendTile tile;
  final String localizedName;
  final _ExerciseProgressLayout layout;
  final double chartHeight;
  final Color tooltipTextColor;
  final bool isEditing;

  const _ExerciseProgressHeroChart({
    required this.tile,
    required this.localizedName,
    required this.layout,
    required this.chartHeight,
    required this.tooltipTextColor,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final surfaces = context.surfaceTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isEditing ? layout.removeBadgeHitSize : 0,
                ),
                child: Text(
                  localizedName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: layout.value(20),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        SizedBox(height: layout.chartTitleGap),
        SizedBox(
          height: chartHeight,
          child: _ExerciseProgressChart(
            points: tile.points,
            showEmptyLabel: true,
            showAxes: true,
            weightUnit: weightUnit,
            tooltipTextColor: tooltipTextColor,
            actualColor: tonosPrimarySeriesForSurface(
              context,
              surfaces.exerciseProgressHero,
            ),
            estimatedColor: tonosSecondarySeriesForSurface(
              context,
              surfaces.exerciseProgressHero,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseProgressStatsColumn extends StatelessWidget {
  final _ExerciseTrendTile tile;
  final _ExerciseProgressLayout layout;

  const _ExerciseProgressStatsColumn({
    required this.tile,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final latest = tile.latestPoint;
    final actualOneRm = latest?.actualOneRm;
    final actualDelta = _deltaFromPrevious(
      tile.points,
      valueForPoint: (point) => point.actualOneRm,
    );
    final estimatedDelta = _deltaFromPrevious(
      tile.points,
      valueForPoint: (point) => point.estimatedOneRm,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExerciseProgressStatBox(
          label: strings.exerciseProgressOneRepMax,
          value:
              actualOneRm == null
                  ? '--'
                  : _formatWeight(actualOneRm, weightUnit, locale: locale),
          delta: actualDelta,
          layout: layout,
        ),
        SizedBox(height: layout.heroRowGap),
        _ExerciseProgressStatBox(
          label: strings.exerciseProgressEstimatedOneRepMax,
          value:
              latest == null
                  ? '--'
                  : _formatWeight(
                    latest.estimatedOneRm,
                    weightUnit,
                    locale: locale,
                  ),
          delta: estimatedDelta,
          layout: layout,
        ),
      ],
    );
  }
}

class _ExerciseProgressStatBox extends StatelessWidget {
  final String label;
  final String value;
  final double? delta;
  final _ExerciseProgressLayout layout;

  const _ExerciseProgressStatBox({
    required this.label,
    required this.value,
    required this.layout,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final icon = _deltaIcon(delta);
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final foreground = tonosForegroundForSurface(
      context,
      surfaces.exerciseProgressStat,
    );
    final secondary = tonosSecondaryForegroundForSurface(
      context,
      surfaces.exerciseProgressStat,
    );
    final deltaColor =
        neo
            ? (delta == null || delta == 0 ? secondary : foreground)
            : _deltaColor(context, delta);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: layout.statBoxHeight),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: layout.statPaddingHorizontal,
          vertical: layout.statPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: surfaces.exerciseProgressStat,
          borderRadius: shapes.exerciseProgressStat * layout.scale,
          border: Border.all(
            color:
                context.surfaceDecorationTokens.panel.outlined
                    ? tonosOutlineForSurface(
                      context,
                      surfaces.exerciseProgressStat,
                      neutral: true,
                    )
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: layout.statLabelGap),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: layout.statHelperGap),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: layout.statIconGap,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: layout.statIconSize, color: deltaColor),
                ],
                Text(
                  _formatDeltaWeight(
                    delta,
                    weightUnit,
                    locale: Localizations.localeOf(context),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseProgressSelectorTile extends StatelessWidget {
  final _ExerciseTrendTile tile;
  final _ExerciseProgressLayout layout;
  final bool isSelected;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ExerciseProgressSelectorTile({
    required this.tile,
    required this.layout,
    required this.isSelected,
    required this.isEditing,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LocalizedExerciseNameBuilder(
      definition: tile.definition,
      builder:
          (context, localizedName) => _buildSelector(context, localizedName),
    );
  }

  Widget _buildSelector(BuildContext context, String localizedName) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;
    final progressColors = context.progressColors;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final latest = tile.latestPoint;
    final delta = _deltaFromPrevious(tile.points);
    final accent = progressColors.accent;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final selectedFill = accent.withValues(alpha: 0.14);
    final tileFill =
        isSelected ? selectedFill : surfaces.exerciseProgressSelector;
    final tileForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              tileFill,
              parentSurface: surfaces.card,
            )
            : theme.colorScheme.onSurface;
    final tileSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              tileFill,
              parentSurface: surfaces.card,
            )
            : theme.colorScheme.onSurfaceVariant;
    final tooltipForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              surfaces.exerciseProgressTooltip,
            )
            : theme.colorScheme.onSurface;
    final tileTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onSurface: tileForeground,
        onSurfaceVariant: tileSecondaryForeground,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: tileForeground,
        displayColor: tileForeground,
      ),
      extensions: [
        for (final extension in theme.extensions.values)
          if (extension is! AppProgressColors) extension,
        progressColors.copyWith(
          estimated: tileSecondaryForeground,
          grid: tileForeground.withValues(alpha: 0.24),
          label: tileSecondaryForeground,
          neutral: tileSecondaryForeground,
          exerciseIncrease: tileForeground,
          exerciseDecrease: tileForeground,
        ),
      ],
    );

    final selectorBody = Semantics(
      key: ValueKey('exercise-progress-selector-${tile.definition.id}'),
      container: true,
      excludeSemantics: true,
      button: true,
      label: localizedName,
      selected: isSelected,
      onTap: onTap,
      child: InkWell(
        excludeFromSemantics: true,
        borderRadius: shapes.exerciseProgressSelector * layout.scale,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: layout.selectorPadding,
            left: layout.selectorPadding,
            right:
                layout.selectorPadding +
                (isEditing ? layout.removeBadgeHitSize : 0),
            bottom: layout.selectorPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: tileForeground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: layout.selectorGraphGap),
              SizedBox(
                height: layout.selectorChartHeight,
                child: _ExerciseProgressChart(
                  points: tile.points,
                  showEmptyLabel: false,
                  weightUnit: weightUnit,
                  tooltipTextColor: tooltipForeground,
                  actualColor: tonosPrimarySeriesForSurface(
                    context,
                    surfaces.exerciseProgressSelector,
                  ),
                  estimatedColor: tonosSecondarySeriesForSurface(
                    context,
                    surfaces.exerciseProgressSelector,
                  ),
                ),
              ),
              SizedBox(height: layout.selectorGraphGap),
              _ExerciseProgressSelectorValues(
                latestValue:
                    latest == null
                        ? '--'
                        : _formatWeight(
                          latest.estimatedOneRm,
                          weightUnit,
                          locale: Localizations.localeOf(context),
                        ),
                delta: delta,
                layout: layout,
                weightUnit: weightUnit,
                foreground: tileForeground,
              ),
            ],
          ),
        ),
      ),
    );
    final selector = Semantics(
      container: true,
      explicitChildNodes: true,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: layout.selectorWidth,
          margin: EdgeInsets.only(right: layout.selectorMarginRight),
          child: Ink(
            decoration: BoxDecoration(
              color: tileFill,
              border: Border.all(
                color:
                    isSelected
                        ? accent
                        : context.surfaceDecorationTokens.panel.outlined
                        ? tonosOutlineForSurface(
                          context,
                          surfaces.exerciseProgressSelector,
                        )
                        : surfaces.subtleOutline,
                width: isSelected ? layout.value(1.5) : layout.value(1),
              ),
              borderRadius: shapes.exerciseProgressSelector * layout.scale,
              boxShadow:
                  usesInkRecipe
                      ? [
                        BoxShadow(
                          color: effects.cardShadow,
                          blurRadius: 0,
                          offset: effects.cardShadowOffset,
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              children: [
                // The body establishes the selector's natural height. Keeping
                // it non-positioned avoids an unbounded cross-axis layout in
                // the horizontal carousel when names or values wrap.
                selectorBody,
                if (isEditing)
                  Positioned(
                    key: ValueKey(
                      'exercise-progress-remove-${tile.definition.id}',
                    ),
                    top: 0,
                    right: 0,
                    child: _ExerciseProgressRemoveBadge(
                      layout: layout,
                      localizedName: localizedName,
                      onTap: onRemove,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // The selector scopes selected-surface foregrounds for nested chart labels.
    return usesInkRecipe ? Theme(data: tileTheme, child: selector) : selector;
  }
}

class _ExerciseProgressSelectorValues extends StatelessWidget {
  final String latestValue;
  final double? delta;
  final _ExerciseProgressLayout layout;
  final WeightUnit weightUnit;
  final Color foreground;

  const _ExerciseProgressSelectorValues({
    required this.latestValue,
    required this.delta,
    required this.layout,
    required this.weightUnit,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final latestStyle = theme.textTheme.labelMedium?.copyWith(
      color: foreground,
      fontWeight: FontWeight.w800,
    );
    final deltaStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final deltaText = _formatDeltaWeight(
      delta,
      weightUnit,
      locale: Localizations.localeOf(context),
    );
    final deltaIcon = _deltaIcon(delta);
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final latestWidth = _measureText(
          latestValue,
          latestStyle,
          textScaler,
          textDirection,
        );
        final deltaWidth = _measureText(
          deltaText,
          deltaStyle,
          textScaler,
          textDirection,
        );
        final deltaDecorationWidth =
            deltaIcon == null
                ? 0.0
                : layout.compactIconSize + layout.compactIconGap;
        final requiredInlineWidth =
            latestWidth +
            layout.selectorDeltaGap +
            deltaDecorationWidth +
            deltaWidth;
        final useStacked =
            textScaler.scale(1) > 1.15 ||
            !constraints.hasBoundedWidth ||
            requiredInlineWidth > constraints.maxWidth;
        final values =
            useStacked
                ? Column(
                  key: const ValueKey(
                    'exercise-progress-selector-values-stacked',
                  ),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(latestValue, style: latestStyle),
                    _CompactDelta(
                      delta: delta,
                      layout: layout,
                      weightUnit: weightUnit,
                    ),
                  ],
                )
                : Row(
                  key: const ValueKey('exercise-progress-selector-values-row'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(latestValue, style: latestStyle)),
                    SizedBox(width: layout.selectorDeltaGap),
                    Expanded(
                      child: _CompactDelta(
                        delta: delta,
                        layout: layout,
                        weightUnit: weightUnit,
                      ),
                    ),
                  ],
                );
        return values;
      },
    );
  }
}

double _measureText(
  String text,
  TextStyle? style,
  TextScaler textScaler,
  TextDirection textDirection,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();
  return painter.width;
}

class _ExerciseProgressRemoveBadge extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final String localizedName;
  final VoidCallback onTap;

  const _ExerciseProgressRemoveBadge({
    required this.layout,
    required this.localizedName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effects = context.effectTokens;
    final badgeShadow = effects.progressRemoveBadgeShadow;
    final shadows =
        badgeShadow.color.a == 0 ? const <BoxShadow>[] : [badgeShadow];
    final strings = AppLocalizations.of(context);
    final hitSize = layout.removeBadgeHitSize;
    final label = strings.exerciseProgressRemoveExerciseLabel(localizedName);
    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onTap,
      child: Tooltip(
        excludeFromSemantics: true,
        message: label,
        child: Material(
          key: const ValueKey('exercise-progress-remove-action'),
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: Ink(
            width: hitSize,
            height: hitSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              boxShadow: [
                for (final shadow in shadows)
                  BoxShadow(
                    color: shadow.color,
                    blurRadius: layout.value(shadow.blurRadius),
                    spreadRadius: layout.value(shadow.spreadRadius),
                    offset: Offset(
                      layout.value(shadow.offset.dx),
                      layout.value(shadow.offset.dy),
                    ),
                  ),
              ],
            ),
            child: InkWell(
              excludeFromSemantics: true,
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Center(
                child: Icon(
                  Icons.remove,
                  size: layout.removeIconSize,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactDelta extends StatelessWidget {
  final double? delta;
  final _ExerciseProgressLayout layout;
  final WeightUnit weightUnit;

  const _CompactDelta({
    required this.delta,
    required this.layout,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final color = _deltaColor(context, delta);
    final icon = _deltaIcon(delta);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: layout.compactIconSize, color: color),
          SizedBox(width: layout.compactIconGap),
        ],
        Expanded(
          child: Text(
            _formatDeltaWeight(
              delta,
              weightUnit,
              locale: Localizations.localeOf(context),
            ),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

double? _deltaFromPrevious(
  List<_ExerciseProgressPoint> points, {
  double? Function(_ExerciseProgressPoint point)? valueForPoint,
}) {
  final valid = _validPoints(points, valueForPoint: valueForPoint);
  if (valid.length < 2) return null;
  final valueFor = valueForPoint ?? (point) => point.estimatedOneRm;
  return valueFor(valid.last)! - valueFor(valid[valid.length - 2])!;
}

List<_ExerciseProgressPoint> _validPoints(
  List<_ExerciseProgressPoint> points, {
  double? Function(_ExerciseProgressPoint point)? valueForPoint,
}) {
  final valueFor = valueForPoint ?? (point) => point.estimatedOneRm;
  return [
    for (final point in points)
      if ((valueFor(point) ?? 0) > 0) point,
  ];
}

String _formatDeltaWeight(double? delta, WeightUnit unit, {Locale? locale}) {
  if (delta == null) return '--';
  final value = WeightUnitFormatter.fromPounds(delta, unit);
  final rounded = value.round();
  final number =
      locale == null
          ? rounded.abs().toString()
          : LocalizedFormatters.number(
            rounded.abs(),
            locale,
            maximumFractionDigits: 0,
          );
  if (rounded == 0) return '0 ${unit.shortLabel}';
  return '${rounded > 0 ? '+' : '-'}$number ${unit.shortLabel}';
}

Color _deltaColor(BuildContext context, double? delta) {
  final progressColors = context.progressColors;
  if (delta == null || delta == 0) return progressColors.neutral;
  return delta > 0
      ? progressColors.exerciseIncrease
      : progressColors.exerciseDecrease;
}

IconData? _deltaIcon(double? delta) {
  if (delta == null || delta == 0) return null;
  return delta > 0 ? Icons.arrow_upward : Icons.arrow_downward;
}

class _ExerciseProgressEmptyHero extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final VoidCallback onTap;

  const _ExerciseProgressEmptyHero({required this.layout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final foreground = tonosForegroundForSurface(
      context,
      surfaces.exerciseProgressHero,
    );
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: surfaces.exerciseProgressHero,
          borderRadius: shapes.exerciseProgressHero * layout.scale,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: shapes.exerciseProgressHero * layout.scale,
          child: Padding(
            padding: EdgeInsets.all(layout.emptyPadding),
            child: Column(
              children: [
                Icon(
                  Icons.add_chart,
                  size: layout.emptyIconSize,
                  color: neo ? foreground : theme.colorScheme.primary,
                ),
                SizedBox(height: layout.emptyTitleGap),
                Text(
                  strings.exerciseProgressTrackExercise,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: neo ? foreground : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: layout.emptyBodyGap),
                Text(
                  strings.exerciseProgressTrackExerciseBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tonosSecondaryForegroundForSurface(
                      context,
                      surfaces.exerciseProgressHero,
                    ),
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

class _AddExerciseProgressTile extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final VoidCallback onTap;

  const _AddExerciseProgressTile({required this.layout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: strings.commonAdd,
      onTap: onTap,
      child: Tooltip(
        message: strings.commonAdd,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: layout.addTileWidth,
            constraints: BoxConstraints(
              minHeight: layout.selectorActionMinHeight,
            ),
            margin: EdgeInsets.only(right: layout.addTileMarginRight),
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      context.surfaceDecorationTokens.panel.outlined
                          ? tonosOutlineForSurface(
                            context,
                            context.cs.surface,
                            neutral: true,
                          )
                          : surfaces.subtleOutline,
                ),
                borderRadius: shapes.exerciseProgressAddTile * layout.scale,
              ),
              child: InkWell(
                borderRadius: shapes.exerciseProgressAddTile * layout.scale,
                onTap: onTap,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: layout.addIconSize,
                    color: dataVisualization.label,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditExerciseProgressTile extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final VoidCallback onTap;

  const _EditExerciseProgressTile({required this.layout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: strings.commonEdit,
      onTap: onTap,
      child: Tooltip(
        message: strings.commonEdit,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: layout.addTileWidth,
            constraints: BoxConstraints(
              minHeight: layout.selectorActionMinHeight,
            ),
            margin: EdgeInsets.only(right: layout.addTileMarginRight),
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      context.surfaceDecorationTokens.panel.outlined
                          ? tonosOutlineForSurface(
                            context,
                            context.cs.surface,
                            neutral: true,
                          )
                          : surfaces.subtleOutline,
                ),
                borderRadius: shapes.exerciseProgressAddTile * layout.scale,
              ),
              child: InkWell(
                borderRadius: shapes.exerciseProgressAddTile * layout.scale,
                onTap: onTap,
                child: Center(
                  child: Icon(
                    Icons.edit,
                    size: layout.value(26),
                    color: dataVisualization.label,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseProgressDetailPage extends StatefulWidget {
  final _ExerciseTrendTile tile;

  const _ExerciseProgressDetailPage({required this.tile});

  @override
  State<_ExerciseProgressDetailPage> createState() =>
      _ExerciseProgressDetailPageState();
}

class _ExerciseProgressDetailPageState
    extends State<_ExerciseProgressDetailPage> {
  final _chartTutorialKey = GlobalKey(
    debugLabel: 'exercise_progress_detail_chart',
  );
  final _recordsTutorialKey = GlobalKey(
    debugLabel: 'exercise_progress_detail_records',
  );
  bool _tutorialQueued = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
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
        tutorialId: TutorialIds.exerciseProgressDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _chartTutorialKey,
            icon: Icons.show_chart,
            title: _strings.exerciseProgressTrendTitle,
            body: _strings.exerciseProgressTrendBody,
          ),
          GuidedTutorialStep(
            targetKey: _recordsTutorialKey,
            icon: Icons.history,
            title: _strings.exerciseProgressRecordings,
            body: _strings.exerciseProgressRecordingsBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<void> _openSession(BuildContext context, int sessionId) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    WorkoutSession? session;
    try {
      session = await context.read<AppRepository>().fetchSessionById(sessionId);
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_strings.exerciseProgressSessionOpenFailed)),
      );
      return;
    }
    if (!context.mounted) return;

    final resolvedSession = session;
    if (resolvedSession == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(_strings.exerciseProgressSessionMissing)),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(builder: (_) => SessionDetailScreen(resolvedSession)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return Scaffold(
      appBar: AppBar(
        title: LocalizedExerciseName(definition: widget.tile.definition),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          KeyedSubtree(
            key: _chartTutorialKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _strings.exerciseProgressTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _ExerciseProgressChart(
                        points: widget.tile.points,
                        showEmptyLabel: true,
                        showAxes: true,
                        interactive: true,
                        weightUnit: weightUnit,
                        estimatedColor: tonosSecondarySeriesForSurface(
                          context,
                          context.surfaceTokens.exerciseProgressStat,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ExerciseProgressLegend(
                      estimatedColor: tonosSecondarySeriesForSurface(
                        context,
                        context.surfaceTokens.exerciseProgressStat,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _strings.exerciseProgressRecordings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.tile.points.isEmpty)
            Text(
              _strings.exerciseProgressEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            KeyedSubtree(
              key: _recordsTutorialKey,
              child: Column(
                children: [
                  for (final point in widget.tile.points.reversed)
                    _ExerciseProgressRecordingRow(
                      point: point,
                      onTap: () {
                        _openSession(context, point.sessionId);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseProgressLegend extends StatelessWidget {
  final Color? estimatedColor;

  const _ExerciseProgressLegend({this.estimatedColor});

  @override
  Widget build(BuildContext context) {
    final progressColors = context.progressColors;
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: progressColors.accent,
          label: AppLocalizations.of(context).exerciseProgressActual,
        ),
        _LegendItem(
          color: estimatedColor ?? progressColors.estimated,
          label: AppLocalizations.of(context).exerciseProgressEstimated,
          dashed: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(28, 10),
          painter: _LegendLinePainter(color: color, dashed: dashed),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ExerciseProgressRecordingRow extends StatelessWidget {
  final _ExerciseProgressPoint point;
  final VoidCallback onTap;

  const _ExerciseProgressRecordingRow({
    required this.point,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final locale = Localizations.localeOf(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocalizedFormatters.dateTime(
                    point.displayDateTime,
                    Localizations.localeOf(context),
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context).exerciseProgressEstimatedValue(
                      _formatWeight(
                        point.estimatedOneRm,
                        weightUnit,
                        locale: locale,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    point.actualOneRm == null
                        ? AppLocalizations.of(context).exerciseProgressNoActual
                        : AppLocalizations.of(
                          context,
                        ).exerciseProgressActualValue(
                          _formatWeight(
                            point.actualOneRm!,
                            weightUnit,
                            locale: locale,
                          ),
                        ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseProgressChart extends StatefulWidget {
  final List<_ExerciseProgressPoint> points;
  final bool showEmptyLabel;
  final bool showAxes;
  final bool interactive;
  final WeightUnit weightUnit;
  final Color? tooltipTextColor;
  final Color? actualColor;
  final Color? estimatedColor;

  const _ExerciseProgressChart({
    required this.points,
    this.showEmptyLabel = false,
    this.showAxes = false,
    this.interactive = false,
    this.weightUnit = WeightUnit.pounds,
    this.tooltipTextColor,
    this.actualColor,
    this.estimatedColor,
  });

  @override
  State<_ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends State<_ExerciseProgressChart> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialSelectedIndex;
  }

  @override
  void didUpdateWidget(covariant _ExerciseProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactive || widget.points.isEmpty) {
      _selectedIndex = null;
    } else if ((_selectedIndex ?? -1) >= widget.points.length) {
      _selectedIndex = widget.points.length - 1;
    } else if (_selectedIndex == null && oldWidget.points != widget.points) {
      _selectedIndex = _initialSelectedIndex;
    }
  }

  int? get _initialSelectedIndex {
    if (!widget.interactive || widget.points.isEmpty) return null;
    return widget.points.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty && widget.showEmptyLabel) {
      return Center(
        child: Text(
          AppLocalizations.of(context).exerciseProgressNoRecordings,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final chart = CustomPaint(
          size: size,
          painter: _ExerciseProgressChartPainter(
            points: widget.points,
            actualColor:
                widget.actualColor ??
                tonosPrimarySeriesForSurface(
                  context,
                  surfaces.exerciseProgressStat,
                ),
            estimatedColor:
                widget.estimatedColor ??
                tonosSecondarySeriesForSurface(
                  context,
                  surfaces.exerciseProgressStat,
                ),
            gridColor: progressColors.grid,
            axisLabelColor: progressColors.label,
            tooltipBackgroundColor: surfaces.exerciseProgressTooltip,
            tooltipTextColor: widget.tooltipTextColor ?? cs.onSurface,
            tooltipBorderRadius: shapes.exerciseProgressTooltip,
            showAxes: widget.showAxes,
            selectedIndex: _selectedIndex,
            weightUnit: widget.weightUnit,
            locale: locale,
            estimatedValueLabel: strings.exerciseProgressEstimatedValue,
            actualValueLabel: strings.exerciseProgressActualValue,
            noActualLabel: strings.exerciseProgressNoActual,
          ),
        );

        if (!widget.interactive || widget.points.isEmpty) return chart;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final selected = _nearestPointIndex(details.localPosition, size);
            if (selected == null) return;
            setState(() => _selectedIndex = selected);
          },
          child: chart,
        );
      },
    );
  }

  int? _nearestPointIndex(Offset tapPosition, Size size) {
    if (widget.points.isEmpty) return null;

    final scale = _ExerciseProgressChartScale(
      points: widget.points,
      size: size,
      showAxes: widget.showAxes,
    );
    if (!scale.plotRect.inflate(28).contains(tapPosition)) return null;

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < widget.points.length; i++) {
      final distance = (tapPosition.dx - scale.xFor(i)).abs();
      if (distance < bestDistance) {
        bestIndex = i;
        bestDistance = distance;
      }
    }

    return bestIndex;
  }
}

class _ExerciseProgressChartPainter extends CustomPainter {
  final List<_ExerciseProgressPoint> points;
  final Color actualColor;
  final Color estimatedColor;
  final Color gridColor;
  final Color axisLabelColor;
  final Color tooltipBackgroundColor;
  final Color tooltipTextColor;
  final BorderRadius tooltipBorderRadius;
  final bool showAxes;
  final int? selectedIndex;
  final WeightUnit weightUnit;
  final Locale locale;
  final String Function(String value) estimatedValueLabel;
  final String Function(String value) actualValueLabel;
  final String noActualLabel;

  const _ExerciseProgressChartPainter({
    required this.points,
    required this.actualColor,
    required this.estimatedColor,
    required this.gridColor,
    required this.axisLabelColor,
    required this.tooltipBackgroundColor,
    required this.tooltipTextColor,
    required this.tooltipBorderRadius,
    required this.showAxes,
    required this.selectedIndex,
    required this.weightUnit,
    required this.locale,
    required this.estimatedValueLabel,
    required this.actualValueLabel,
    required this.noActualLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = _ExerciseProgressChartScale(
      points: points,
      size: size,
      showAxes: showAxes,
    );
    if (!scale.hasUsableValues) return;

    final gridPaint =
        Paint()
          ..color = gridColor.withValues(alpha: 0.45)
          ..strokeWidth = 1;
    for (final tick in scale.yTicks) {
      final y = scale.yFor(tick);
      canvas.drawLine(
        Offset(scale.plotRect.left, y),
        Offset(scale.plotRect.right, y),
        gridPaint,
      );
      if (showAxes) {
        _drawText(
          canvas,
          _formatAxisWeight(tick, weightUnit, locale),
          Offset(0, y - 7),
          TextStyle(
            color: axisLabelColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
      }
    }

    if (showAxes) {
      _drawDateLabels(canvas, scale);
    }

    final estimatedOffsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        if (points[i].estimatedOneRm > 0)
          scale.pointFor(i, points[i].estimatedOneRm),
    ];
    final actualOffsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        if ((points[i].actualOneRm ?? 0) > 0)
          scale.pointFor(i, points[i].actualOneRm!),
    ];

    _drawPolyline(
      canvas,
      estimatedOffsets,
      Paint()
        ..color = estimatedColor.withValues(alpha: 0.85)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
      dashed: true,
    );
    _drawPolyline(
      canvas,
      actualOffsets,
      Paint()
        ..color = actualColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    if (showAxes && selectedIndex != null) {
      _drawSelectedPoint(canvas, size, scale, selectedIndex!);
    }
  }

  void _drawDateLabels(Canvas canvas, _ExerciseProgressChartScale scale) {
    final dateStyle = TextStyle(
      color: axisLabelColor,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    for (final index in scale.dateTickIndexes) {
      final label = LocalizedFormatters.shortDate(
        points[index].calendarDay.toLocalDateTime(),
        locale,
      );
      final painter = TextPainter(
        text: TextSpan(text: label, style: dateStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final x = math.max(
        scale.plotRect.left,
        math.min(
          scale.plotRect.right - painter.width,
          scale.xFor(index) - painter.width / 2,
        ),
      );
      painter.paint(canvas, Offset(x, scale.plotRect.bottom + 9));
    }
  }

  void _drawSelectedPoint(
    Canvas canvas,
    Size size,
    _ExerciseProgressChartScale scale,
    int index,
  ) {
    if (index < 0 || index >= points.length) return;

    final point = points[index];
    final x = scale.xFor(index);
    final guidePaint =
        Paint()
          ..color = actualColor.withValues(alpha: 0.28)
          ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x, scale.plotRect.top),
      Offset(x, scale.plotRect.bottom),
      guidePaint,
    );

    final highlightPaint =
        Paint()
          ..color = tooltipBackgroundColor
          ..style = PaintingStyle.fill;
    final estimatedPaint =
        Paint()
          ..color = estimatedColor
          ..style = PaintingStyle.fill;
    if (point.estimatedOneRm > 0) {
      final offset = scale.pointFor(index, point.estimatedOneRm);
      canvas.drawCircle(offset, 6.5, highlightPaint);
      canvas.drawCircle(offset, 4.4, estimatedPaint);
    }

    if ((point.actualOneRm ?? 0) > 0) {
      final offset = scale.pointFor(index, point.actualOneRm!);
      canvas.drawCircle(offset, 7, highlightPaint);
      canvas.drawCircle(offset, 4.8, Paint()..color = actualColor);
    }

    _drawTooltip(canvas, size, scale, point);
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    _ExerciseProgressChartScale scale,
    _ExerciseProgressPoint point,
  ) {
    final titleStyle = TextStyle(
      color: tooltipTextColor,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );
    final bodyStyle = TextStyle(
      color: tooltipTextColor.withValues(alpha: 0.86),
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    final lines = [
      (LocalizedFormatters.dateTime(point.displayDateTime, locale), titleStyle),
      (
        estimatedValueLabel(
          _formatWeight(point.estimatedOneRm, weightUnit, locale: locale),
        ),
        bodyStyle,
      ),
      (
        point.actualOneRm == null
            ? noActualLabel
            : actualValueLabel(
              _formatWeight(point.actualOneRm!, weightUnit, locale: locale),
            ),
        bodyStyle,
      ),
    ];

    final painters =
        lines
            .map(
              (line) => TextPainter(
                text: TextSpan(text: line.$1, style: line.$2),
                textDirection: ui.TextDirection.ltr,
              )..layout(maxWidth: 150),
            )
            .toList();
    final width =
        painters.fold<double>(0, (maxWidth, painter) {
          return math.max(maxWidth, painter.width);
        }) +
        20;
    final height =
        painters.fold<double>(0, (sum, painter) => sum + painter.height) + 16;
    final selectedX = scale.xFor(points.indexOf(point));
    final maxLeft = math.max(2.0, size.width - width - 2);
    final left = math.max(2.0, math.min(maxLeft, selectedX - width / 2));
    final rect = Rect.fromLTWH(left, 2, width, height);
    final background =
        Paint()
          ..color = tooltipBackgroundColor.withValues(alpha: 0.96)
          ..style = PaintingStyle.fill;
    canvas.drawRRect(tooltipBorderRadius.toRRect(rect), background);

    var y = rect.top + 8;
    for (final painter in painters) {
      painter.paint(canvas, Offset(rect.left + 10, y));
      y += painter.height;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: 40);
    painter.paint(canvas, offset);
  }

  void _drawPolyline(
    Canvas canvas,
    List<Offset> offsets,
    Paint paint, {
    bool dashed = false,
  }) {
    if (offsets.isEmpty) return;
    if (offsets.length == 1) {
      canvas.drawCircle(offsets.single, 3.5, paint);
      return;
    }

    for (var i = 1; i < offsets.length; i++) {
      if (dashed) {
        _drawDashedLine(canvas, offsets[i - 1], offsets[i], paint);
      } else {
        canvas.drawLine(offsets[i - 1], offsets[i], paint);
      }
    }
    for (final offset in offsets) {
      canvas.drawCircle(offset, 3.2, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    final distance = (end - start).distance;
    if (distance <= 0) return;

    final direction = (end - start) / distance;
    var traveled = 0.0;
    while (traveled < distance) {
      final dashEnd = math.min(traveled + dashLength, distance);
      canvas.drawLine(
        start + direction * traveled,
        start + direction * dashEnd,
        paint,
      );
      traveled += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseProgressChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.actualColor != actualColor ||
        oldDelegate.estimatedColor != estimatedColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisLabelColor != axisLabelColor ||
        oldDelegate.tooltipBackgroundColor != tooltipBackgroundColor ||
        oldDelegate.tooltipTextColor != tooltipTextColor ||
        oldDelegate.tooltipBorderRadius != tooltipBorderRadius ||
        oldDelegate.showAxes != showAxes ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.weightUnit != weightUnit ||
        oldDelegate.locale != locale ||
        oldDelegate.noActualLabel != noActualLabel;
  }
}

class _ExerciseProgressChartScale {
  final List<_ExerciseProgressPoint> points;
  final Size size;
  final bool showAxes;

  _ExerciseProgressChartScale({
    required this.points,
    required this.size,
    required this.showAxes,
  });

  late final List<double> _values = <double>[
    for (final point in points)
      if (point.estimatedOneRm > 0) point.estimatedOneRm,
    for (final point in points)
      if ((point.actualOneRm ?? 0) > 0) point.actualOneRm!,
  ];

  late final Rect plotRect =
      showAxes
          ? Rect.fromLTWH(
            26,
            18,
            math.max(1.0, size.width - 30),
            math.max(1.0, size.height - 42),
          )
          : Rect.fromLTWH(
            0,
            6,
            math.max(1.0, size.width),
            math.max(1.0, size.height - 12),
          );

  late final double _rawMinY = _values.isEmpty ? 0 : _values.reduce(math.min);
  late final double _rawMaxY = _values.isEmpty ? 1 : _values.reduce(math.max);
  late final double _rangeY = math.max(1.0, _rawMaxY - _rawMinY);
  late final double _paddingY = math.max(2.0, _rangeY * 0.08);
  late final double _paddedMinY = math.max(0, _rawMinY - _paddingY);
  late final double _paddedMaxY = _rawMaxY + _paddingY;
  late final double _tickStep = _niceTickStep(
    math.max(1.0, (_paddedMaxY - _paddedMinY) / 2),
  );
  late final double minY = (_paddedMinY / _tickStep).floor() * _tickStep;
  late final double maxY = math.max(
    minY + 1,
    (_paddedMaxY / _tickStep).ceil() * _tickStep,
  );

  bool get hasUsableValues => _values.isNotEmpty;

  List<double> get yTicks => [minY, (minY + maxY) / 2, maxY];

  List<int> get dateTickIndexes {
    if (points.isEmpty) return const [];
    if (points.length <= 4) {
      return [for (var i = 0; i < points.length; i++) i];
    }
    return [0, points.length ~/ 2, points.length - 1];
  }

  double xFor(int index) {
    if (points.length <= 1) return plotRect.center.dx;
    final normalized = index / (points.length - 1);
    return plotRect.left + plotRect.width * normalized;
  }

  double yFor(double value) {
    final normalized =
        ((value - minY) / (maxY - minY)).clamp(0.0, 1.0).toDouble();
    return plotRect.bottom - plotRect.height * normalized;
  }

  Offset pointFor(int index, double value) {
    return Offset(xFor(index), yFor(value));
  }

  static double _niceTickStep(double value) {
    if (value <= 0) return 1;
    final scale =
        math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
    final normalized = value / scale;
    final multiplier =
        normalized <= 1
            ? 1.0
            : normalized <= 1.5
            ? 1.5
            : normalized <= 2
            ? 2.0
            : normalized <= 2.5
            ? 2.5
            : normalized <= 3
            ? 3.0
            : normalized <= 4
            ? 4.0
            : normalized <= 5
            ? 5.0
            : normalized <= 7.5
            ? 7.5
            : 10.0;
    return multiplier * scale;
  }
}

class _LegendLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;

  const _LegendLinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    var x = 0.0;
    while (x < size.width) {
      final end = math.min(x + 5, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += 9;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashed != dashed;
  }
}

String _formatWeight(double value, WeightUnit unit, {Locale? locale}) {
  return WeightUnitFormatter.formatWeight(value, unit, locale: locale);
}

String _formatAxisWeight(double value, WeightUnit unit, [Locale? locale]) {
  final displayValue = WeightUnitFormatter.fromPounds(value, unit);
  final rounded = displayValue.round();
  if (rounded >= 1000) {
    final compact = rounded / 1000;
    final digits = compact >= 10 ? 0 : 1;
    final text =
        locale == null
            ? compact.toStringAsFixed(digits)
            : LocalizedFormatters.number(
              compact,
              locale,
              minimumFractionDigits: digits,
              maximumFractionDigits: digits,
            );
    return '${text}k';
  }
  return locale == null
      ? '$rounded'
      : LocalizedFormatters.number(rounded, locale, maximumFractionDigits: 0);
}
