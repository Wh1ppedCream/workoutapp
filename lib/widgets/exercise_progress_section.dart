import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/tokens/app_progress_colors.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/localized_formatters.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/weight_unit_formatter.dart';
import 'guided_tutorial_overlay.dart';
import 'localized_exercise_name.dart';

part 'exercise_progress/progress_models.dart';
part 'exercise_progress/progress_tiles.dart';
part 'exercise_progress/progress_detail_page.dart';
part 'exercise_progress/progress_chart.dart';

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
    final mostUsedId = mostUsedRows.isEmpty
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
      final points = await _repo.fetchExerciseOneRmTrend(
        definitionId: id,
        limit: 60,
      );
      tiles.add(_ExerciseTrendTile(definition: definition, points: points));
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
    final expressive = context.usesExpressivePresentation;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          final page = ExerciseCatalogPage(
            expressiveCatalogPresentation: expressive,
            onExercisePicked: (definition) {
              unawaited(_addExerciseTile(definition));
            },
          );
          if (!expressive) return page;
          return AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.catalog,
            child: page,
          );
        },
      ),
    );
  }

  void _openDetail(_ExerciseTrendTile tile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.progress,
          child: _ExerciseProgressDetailPage(tile: tile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final dataVisualization = context.dataVisualizationTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final destinationTokens = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    final isExpressiveProgress =
        usesExpressive &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final surfaces = context.surfaceTokens;
    final sectionForeground = usesInkRecipe || usesExpressive
        ? (isExpressiveProgress
                  ? theme.colorScheme.onSurface
                  : destinationTokens?.onSurfaceTertiary) ??
              tonosForegroundForSurface(
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
              if (usesInkRecipe || usesExpressive) {
                return TonosSurface(
                  key: isExpressiveProgress
                      ? const ValueKey('exercise-progress-expressive-shell')
                      : null,
                  variant: isExpressiveProgress
                      ? TonosSurfaceVariant.panel
                      : TonosSurfaceVariant.panelRaised,
                  color:
                      (isExpressiveProgress
                          ? destinationTokens!.pageCanvas
                          : destinationTokens?.surfaceTertiary) ??
                      surfaces.exerciseProgressSelector,
                  padding: EdgeInsets.all(layout.cardPadding),
                  borderRadius: context.shapeTokens.exerciseProgressSelector,
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
                  onTap: () => setState(() {
                    _isEditingExerciseProgress = false;
                    _selectedDefinitionId = tile.definition.id;
                  }),
                ),
              if (_isEditingExerciseProgress)
                _AddExerciseProgressTile(
                  layout: layout,
                  onTap: _openExercisePicker,
                )
              else if (!usesExpressive)
                _EditExerciseProgressTile(
                  layout: layout,
                  onTap: () => setState(() {
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
                    if (usesExpressive)
                      _ExpressiveExerciseProgressHeader(
                        layout: layout,
                        isEditing: _isEditingExerciseProgress,
                        onEdit: () => setState(() {
                          _isEditingExerciseProgress =
                              !_isEditingExerciseProgress;
                        }),
                      )
                    else
                      Text(
                        AppLocalizations.of(context)
                            .dashboardSectionExerciseProgressTitle,
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
                        onRemove: () =>
                            unawaited(_removeExerciseTile(selectedTile)),
                        onTap: () => _openDetail(selectedTile),
                      ),
                    SizedBox(height: layout.sectionGap),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: preservesClassicGeometry
                            ? layout.selectorMinimumHeight
                            : 0,
                      ),
                      child: SingleChildScrollView(
                        key: const ValueKey('exercise-progress-selector-strip'),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: preservesClassicGeometry
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
