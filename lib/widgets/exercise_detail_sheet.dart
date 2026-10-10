// File: lib/widgets/exercise_detail_sheet.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../services/catalog_entity_localizer.dart';
import '../services/exercise_content_localizer.dart';
import '../services/tutorial_state_store.dart';
import '../utils/localized_body_part_name.dart';
import '../utils/localized_formatters.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/app_expressive_destination_theme.dart';
import '../theme/tokens/app_media_tokens.dart';
import '../theme/widgets/media_viewer_image.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';
import 'guided_tutorial_overlay.dart';
import 'localized_catalog_entity_name.dart';
import 'localized_exercise_name.dart';
import 'workout_record_badges.dart';

/// Simple record model for history tab
class HistoryRecord {
  final DateTime date;
  final LocalCalendarDay calendarDay;
  final int sessionId;
  final int exerciseId;
  final int sessionCompletedAtMilliseconds;
  final List<ExerciseSet> sets;
  final WorkoutExerciseRecordBadges badges;

  HistoryRecord({
    required this.date,
    required this.calendarDay,
    required this.sessionId,
    required this.exerciseId,
    required this.sessionCompletedAtMilliseconds,
    required this.sets,
    required this.badges,
  });

  DateTime get displayDateTime => calendarDay.atLocalTime(date);
}

class _ExerciseHistoryPage {
  final List<HistoryRecord> records;
  final bool hasMore;

  const _ExerciseHistoryPage({required this.records, required this.hasMore});
}

class _LoadedExerciseMedia {
  final ExerciseMediaItem media;
  final File previewFile;

  const _LoadedExerciseMedia({required this.media, required this.previewFile});
}

class _ExerciseMediaPreviewCard extends StatelessWidget {
  final File previewFile;
  final Widget? heatmapOverlay;
  final bool expressive;
  final VoidCallback onImageTap;
  final VoidCallback onImageLoadFailed;

  const _ExerciseMediaPreviewCard({
    required this.previewFile,
    required this.heatmapOverlay,
    this.expressive = false,
    required this.onImageTap,
    required this.onImageLoadFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: expressive
            ? theme.colorScheme.surfaceContainerLow
            : theme.surfaceTokens.mediaPlaceholder,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(26),
                bottomLeft: Radius.circular(14),
              )
            : theme.mediaTokens.previewShape,
        border: expressive
            ? null
            : Border.all(color: theme.surfaceTokens.mediaOutline),
      ),
      padding: expressive ? const EdgeInsets.all(6) : EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        // A 4:3 frame keeps square source art compact while preserving the
        // complete original image in the tap-to-zoom viewer.
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              button: true,
              label: AppLocalizations.of(context).exerciseDetailOpenImage,
              child: GestureDetector(
                onTap: onImageTap,
                child: ColoredBox(
                  color: expressive
                      ? theme.colorScheme.surfaceContainerLowest
                      : theme.surfaceTokens.media,
                  child: Image.file(
                    previewFile,
                    fit: expressive ? BoxFit.contain : BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      onImageLoadFailed();
                      return heatmapOverlay ?? const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MediaViewingColors.indicator,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.zoom_in,
                      color: MediaViewingColors.onIndicator,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            if (heatmapOverlay != null)
              Positioned(right: 8, bottom: 8, child: heatmapOverlay!),
          ],
        ),
      ),
    );
  }
}

/// Exercise Detail Bottom Sheet with tabs: Details, Metrics, Records
class ExerciseDetailSheet extends StatefulWidget {
  final ExerciseDefinition definition;
  final int defId;

  /// Enables the Catalog-only Expressive treatment for the Details tab.
  ///
  /// The detail sheet is also used by workout, plan, and history flows, so
  /// callers outside the Catalog browser keep the existing presentation.
  final bool expressiveCatalogPresentation;

  const ExerciseDetailSheet({
    super.key,
    required this.definition,
    required this.defId,
    this.expressiveCatalogPresentation = false,
  });

  /// Presents the detail sheet with one owner for its draggable handle.
  static Future<T?> show<T>({
    required BuildContext context,
    required ExerciseDefinition definition,
    required int defId,
    bool expressiveCatalogPresentation = false,
  }) {
    final neoSheet = context.surfaceDecorationTokens.sheet.outlined;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: neoSheet ? Colors.transparent : null,
      elevation: neoSheet ? 0 : null,
      showDragHandle: neoSheet ? false : null,
      builder: (_) {
        final sheet = ExerciseDetailSheet(
          definition: definition,
          defId: defId,
          expressiveCatalogPresentation: expressiveCatalogPresentation,
        );
        if (!expressiveCatalogPresentation) return sheet;
        return AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.catalog,
          child: sheet,
        );
      },
    );
  }

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  static const _historyPageSize = 10;
  static const _sheetMinSize = 0.25;
  static const _sheetInitialSize = 0.7;
  static const _sheetMaxSize = 0.95;

  AppRepository get _repo => context.read<AppRepository>();
  AppLocalizations get _strings => AppLocalizations.of(context);
  AppExpressiveDestinationTokens? get _destinationTokens =>
      Theme.of(context).extension<AppExpressiveDestinationTokens>();
  bool get _usesExpressiveCatalogSheet =>
      widget.expressiveCatalogPresentation &&
      Theme.of(context).appThemeFamilyIdentity ==
          AppThemeFamilyIdentity.expressivePreview &&
      _destinationTokens?.family == AppExpressiveDestinationFamily.catalog;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late Future<_ExerciseHistoryPage> _historyFuture;
  late Future<Map<int, WorkoutExerciseRecordBadges>>
  _currentHistoryBadgesFuture;
  late Future<_LoadedExerciseMedia?> _primaryMediaFuture;
  final Map<String, Future<List<RepMaxRow>>> _repMaxFutures = {};
  final Map<String, Future<double?>> _volumeMaxFutures = {};
  final Map<String, Future<File?>> _mediaPreviewFutures = {};
  final Map<String, Future<ExerciseInstructionContent>>
  _localizedInstructionFutures = {};
  bool _hasRetriedMissingPreview = false;
  final List<HistoryRecord> _olderHistory = [];
  final _headerTutorialKey = GlobalKey(debugLabel: 'exercise_detail_header');
  final _tabsTutorialKey = GlobalKey(debugLabel: 'exercise_detail_tabs');
  final _contentTutorialKey = GlobalKey(debugLabel: 'exercise_detail_content');
  bool _tutorialQueued = false;
  bool _equipmentExpanded = false;
  bool _targetAnatomyExpanded = false;
  bool _formGuideExpanded = true;
  bool _isLoadingMoreHistory = false;
  bool _hasMoreHistory = true;
  int _historyRequestGeneration = 0;

  // Timeframe toggles
  final List<String> _timeframes = ['week', 'month', 'all'];
  late List<bool> _tfSelected;

  @override
  void initState() {
    super.initState();
    _tfSelected = [false, false, true]; // default to "all"
    unawaited(BodyHeatmap.preload());
    _currentHistoryBadgesFuture = _repo.fetchCurrentExerciseRecordBadges(
      widget.defId,
    );
    _historyFuture = _loadHistoryPage();
    _primaryMediaFuture = _loadPrimaryMedia();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExerciseDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition != widget.definition) {
      _localizedInstructionFutures.clear();
    }
    if (oldWidget.defId != widget.defId) {
      _repMaxFutures.clear();
      _volumeMaxFutures.clear();
      _mediaPreviewFutures.clear();
      _localizedInstructionFutures.clear();
      _hasRetriedMissingPreview = false;
      _historyRequestGeneration++;
      _olderHistory.clear();
      _isLoadingMoreHistory = false;
      _hasMoreHistory = true;
      _currentHistoryBadgesFuture = _repo.fetchCurrentExerciseRecordBadges(
        widget.defId,
      );
      _historyFuture = _loadHistoryPage();
      _primaryMediaFuture = _loadPrimaryMedia();
      _tutorialQueued = false;
      _equipmentExpanded = false;
      _targetAnatomyExpanded = false;
      _formGuideExpanded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueTutorial();
      });
    }
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
        tutorialId: TutorialIds.exerciseDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.info_outline,
            title: _strings.exerciseDetailTutorialTitle,
            body: _strings.exerciseDetailTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _tabsTutorialKey,
            icon: Icons.tab,
            title: _strings.exerciseDetailTabsTutorialTitle,
            body: _strings.exerciseDetailTabsTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _contentTutorialKey,
            icon: Icons.accessibility_new,
            title: _strings.exerciseDetailContextTutorialTitle,
            body: _strings.exerciseDetailContextTutorialBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Future<List<RepMaxRow>> _repMaxFuture(String timeframe) {
    return _repMaxFutures.putIfAbsent(
      timeframe,
      () => _repo.fetchRepMaxes(widget.defId, timeframe),
    );
  }

  Future<double?> _volumeMaxFuture(String timeframe) {
    return _volumeMaxFutures.putIfAbsent(
      timeframe,
      () => _repo.fetchVolumeMax(widget.defId, timeframe),
    );
  }

  Future<ExerciseInstructionContent> _localizedInstructionsFor(
    ExerciseDefinition definition,
  ) {
    final locale = Localizations.localeOf(context);
    final localeKey = '${locale.languageCode}_${locale.countryCode ?? ''}';
    final cacheKey =
        '${definition.id}|${definition.catalogId ?? ''}|$localeKey';
    return _localizedInstructionFutures.putIfAbsent(
      cacheKey,
      () => ExerciseContentLocalizer.instance.resolve(definition, locale),
    );
  }

  /// Loads one cursor-based page of weight exercise history for this definition.
  Future<_ExerciseHistoryPage> _loadHistoryPage({HistoryRecord? before}) async {
    final historyRows = await _repo.fetchRecentWeightExerciseHistoryRows(
      definitionId: widget.defId,
      beforeCompletedAtMilliseconds: before?.sessionCompletedAtMilliseconds,
      beforeExerciseId: before?.exerciseId,
      // Fetch one additional row to know whether the next page exists.
      limit: _historyPageSize + 1,
    );
    final hasMore = historyRows.length > _historyPageSize;
    final pageRows = historyRows.take(_historyPageSize).toList();
    final exercises = await Future.wait(
      pageRows.map(
        (row) => _repo.fetchDetailedExercise(row['exercise_id'] as int),
      ),
    );
    final badgesByExercise = await _currentHistoryBadgesFuture;

    final records = <HistoryRecord>[];
    for (var i = 0; i < pageRows.length; i++) {
      final exercise = exercises[i];
      if (exercise is! WeightExercise) continue;
      final row = pageRows[i];
      records.add(
        HistoryRecord(
          date: TemporalSemantics.readLocalDateTime(
            epochMilliseconds: row['session_completed_at_ms'],
            legacyIso: row['session_date'],
          ),
          calendarDay: TemporalSemantics.readCalendarDay(
            calendarDay: row['session_training_day'],
            legacyIso: row['session_date'],
            epochMilliseconds: row['session_completed_at_ms'],
          ),
          sessionId: row['session_id'] as int,
          exerciseId: row['exercise_id'] as int,
          sessionCompletedAtMilliseconds: row['session_completed_at_ms'] as int,
          sets: exercise.sets,
          badges:
              badgesByExercise[row['exercise_id'] as int] ??
              const WorkoutExerciseRecordBadges(isFirstRecord: false),
        ),
      );
    }
    return _ExerciseHistoryPage(records: records, hasMore: hasMore);
  }

  Future<void> _loadMoreHistory(List<HistoryRecord> loadedHistory) async {
    if (_isLoadingMoreHistory || !_hasMoreHistory || loadedHistory.isEmpty) {
      return;
    }

    setState(() => _isLoadingMoreHistory = true);
    final requestGeneration = _historyRequestGeneration;
    try {
      final nextPage = await _loadHistoryPage(before: loadedHistory.last);
      if (!mounted || requestGeneration != _historyRequestGeneration) return;

      setState(() {
        _olderHistory.addAll(nextPage.records);
        _hasMoreHistory = nextPage.hasMore && nextPage.records.isNotEmpty;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMoreHistory = false);
      }
    }
  }

  Future<void> _openHistorySession(BuildContext context, int sessionId) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    WorkoutSession? session;

    try {
      session = await _repo.fetchSessionById(sessionId);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_strings.exerciseDetailSessionOpenFailed)),
      );
      return;
    }

    if (!mounted) return;
    final resolvedSession = session;
    if (resolvedSession == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(_strings.exerciseDetailSessionNotFound)),
      );
      return;
    }

    final destinationFamily = _destinationTokens?.family;
    await navigator.push(
      MaterialPageRoute(
        builder: (_) {
          final detail = SessionDetailScreen(resolvedSession);
          if (destinationFamily == null) return detail;
          return AppExpressiveDestinationTheme(
            family: destinationFamily,
            child: detail,
          );
        },
      ),
    );
    if (!mounted) return;

    setState(() {
      _historyRequestGeneration++;
      _olderHistory.clear();
      _isLoadingMoreHistory = false;
      _hasMoreHistory = true;
      _historyFuture = _loadHistoryPage();
    });
  }

  Future<_LoadedExerciseMedia?> _loadPrimaryMedia() async {
    try {
      await _repo.syncBundledExerciseMediaManifest();
    } catch (_) {
      // Media is optional. If the bundled manifest cannot be read, the detail
      // sheet should still work from local exercise metadata.
    }
    final media = await _repo.fetchPrimaryExerciseMedia(widget.defId);
    if (media == null) return null;

    final previewFile = await _previewFileFuture(media);
    if (previewFile == null) return null;

    return _LoadedExerciseMedia(media: media, previewFile: previewFile);
  }

  Future<File?> _previewFileFuture(ExerciseMediaItem item) {
    final key = '${item.id ?? item.assetId ?? item.remoteUrl}:thumb';
    return _mediaPreviewFutures.putIfAbsent(key, () async {
      final cached = await _repo.cachedExerciseMediaFile(item, thumbnail: true);
      if (cached != null) return cached;

      if (!_looksLikeImage(item.thumbnailUrl ?? item.remoteUrl)) return null;

      try {
        return await _repo.cacheExerciseMedia(item, thumbnail: true);
      } catch (_) {
        return null;
      }
    });
  }

  bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  Widget _buildDetailsTab(ScrollController scrollCtrl) {
    final def = widget.definition;
    final heatmapSurface = context.surfaceTokens.mediaPlaceholder;
    final heatmapLow = tonosHeatmapLowForSurface(context, heatmapSurface);
    final heatmapHigh = tonosHeatmapHighForSurface(context, heatmapSurface);
    final heatmapFrequencyMap = bodyPartFrequencyMapFromNames({
      for (final bodyPart in def.bodyParts) bodyPart.name: 1.0,
    });

    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 +
            (_usesExpressiveCatalogSheet
                ? MediaQuery.viewPaddingOf(context).bottom
                : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailsMediaFocal(
            FutureBuilder<_LoadedExerciseMedia?>(
              future: _primaryMediaFuture,
              builder: (context, snapshot) {
                final loadedMedia = snapshot.data;
                if (loadedMedia == null) {
                  return Center(
                    child: _buildHeatmapButton(
                      definition: def,
                      frequencyMap: heatmapFrequencyMap,
                      lowColor: heatmapLow,
                      highColor: heatmapHigh,
                      size: 220,
                      padding: 12,
                      borderRadius: context.mediaTokens.previewShape,
                    ),
                  );
                }

                return _ExerciseMediaPreviewCard(
                  previewFile: loadedMedia.previewFile,
                  heatmapOverlay: heatmapFrequencyMap.isEmpty
                      ? null
                      : _buildHeatmapButton(
                          definition: def,
                          frequencyMap: heatmapFrequencyMap,
                          lowColor: heatmapLow,
                          highColor: heatmapHigh,
                          size: 98,
                          padding: 6,
                          borderRadius: context.mediaTokens.overlayShape,
                          elevated: true,
                        ),
                  expressive: _usesExpressiveCatalogSheet,
                  onImageTap: () => _showImageViewer(
                    loadedMedia.previewFile,
                    definition: def,
                  ),
                  onImageLoadFailed: _recoverFromMissingPreview,
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _buildFormGuideCard(def),
          const SizedBox(height: 12),
          _buildEquipmentCard(def),
          const SizedBox(height: 12),
          _buildTargetAnatomyCard(def),
        ],
      ),
    );
  }

  Widget _buildDetailsMediaFocal(Widget media) {
    if (!_usesExpressiveCatalogSheet) return media;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(28),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: media,
    );
  }

  void _recoverFromMissingPreview() {
    if (_hasRetriedMissingPreview) return;
    _hasRetriedMissingPreview = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _mediaPreviewFutures.clear();
        _primaryMediaFuture = _loadPrimaryMedia();
      });
    });
  }

  Widget _buildEquipmentCard(ExerciseDefinition definition) {
    final theme = Theme.of(context);
    final strings = _strings;
    final equipment = definition.equipmentList
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);

    return _buildDetailCard(
      icon: Icons.fitness_center_outlined,
      title: strings.catalogEquipment,
      accent: _destinationTokens?.actionPrimary ?? theme.colorScheme.primary,
      expressiveContainer: theme.colorScheme.surfaceContainerLow,
      expressiveOnContainer: theme.colorScheme.onSurface,
      expressive: _usesExpressiveCatalogSheet,
      expressiveShape: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(9),
        bottomLeft: Radius.circular(9),
        bottomRight: Radius.circular(22),
      ),
      isExpanded: _equipmentExpanded,
      onExpandedChanged: (expanded) =>
          setState(() => _equipmentExpanded = expanded),
      child: equipment.isEmpty
          ? Text(
              strings.exerciseDetailNoEquipment,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : LocalizedCatalogEntityNamesBuilder(
              entities: equipment,
              builder: (context, names) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: names
                    .map(
                      (name) => _buildDetailTag(
                        name,
                        color:
                            _destinationTokens?.actionPrimary ??
                            theme.colorScheme.primary,
                        expressiveContainer:
                            _destinationTokens?.surfaceSelected ??
                            theme.colorScheme.primaryContainer,
                        expressiveForeground:
                            _destinationTokens?.onSurfaceSelected ??
                            theme.colorScheme.onPrimaryContainer,
                        expressive: _usesExpressiveCatalogSheet,
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildTargetAnatomyCard(
    ExerciseDefinition definition, {
    bool expandable = true,
    bool expressive = true,
  }) {
    final theme = Theme.of(context);
    final strings = _strings;
    final bodyParts = definition.bodyParts
        .map((item) => localizedBodyPartName(context, item.name))
        .toList();
    final muscles = definition.muscles
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.muscle.catalogId,
            canonicalName: item.muscle.name,
          ),
        )
        .toList(growable: false);

    return _buildDetailCard(
      icon: Icons.accessibility_new,
      title: strings.exerciseDetailTargetAnatomy,
      accent:
          _destinationTokens?.onSurfaceSecondary ?? theme.colorScheme.tertiary,
      expressiveContainer: theme.colorScheme.surfaceContainerLow,
      expressiveOnContainer: theme.colorScheme.onSurface,
      expressive: expressive && _usesExpressiveCatalogSheet,
      expressiveShape: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(10),
      ),
      isExpanded: expandable ? _targetAnatomyExpanded : true,
      onExpandedChanged: expandable
          ? (expanded) => setState(() => _targetAnatomyExpanded = expanded)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailLabel(strings.exerciseDetailBodyParts),
          const SizedBox(height: 7),
          if (bodyParts.isEmpty)
            Text(
              strings.exerciseDetailNoBodyParts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bodyParts
                  .map(
                    (item) => _buildDetailTag(
                      item,
                      color:
                          _destinationTokens?.actionPrimary ??
                          theme.colorScheme.tertiary,
                      expressiveContainer:
                          _destinationTokens?.surfaceSecondary ??
                          theme.colorScheme.tertiaryContainer,
                      expressiveForeground:
                          _destinationTokens?.onSurfaceSecondary ??
                          theme.colorScheme.onTertiaryContainer,
                      expressive: expressive && _usesExpressiveCatalogSheet,
                    ),
                  )
                  .toList(),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildDetailLabel(strings.exerciseDetailMuscles),
          const SizedBox(height: 7),
          if (muscles.isEmpty)
            Text(
              strings.exerciseDetailNoMuscles,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            LocalizedCatalogEntityNamesBuilder(
              entities: muscles,
              builder: (context, names) => Wrap(
                spacing: 7,
                runSpacing: 7,
                children: names
                    .map(
                      (name) => _buildDetailTag(
                        name,
                        color: theme.colorScheme.secondary,
                        expressiveContainer: _usesExpressiveCatalogSheet
                            ? _destinationTokens?.surfaceSecondary ??
                                  theme.colorScheme.secondaryContainer
                            : theme.colorScheme.secondaryContainer,
                        expressiveForeground: _usesExpressiveCatalogSheet
                            ? _destinationTokens?.onSurfaceSecondary ??
                                  theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                        expressive: expressive && _usesExpressiveCatalogSheet,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormGuideCard(
    ExerciseDefinition definition, {
    bool expandable = true,
    bool expressive = true,
  }) {
    final fallback = ExerciseInstructionContent.fromDefinition(definition);
    return FutureBuilder<ExerciseInstructionContent>(
      future: _localizedInstructionsFor(definition),
      initialData: fallback,
      builder: (context, snapshot) => _buildLocalizedFormGuideCard(
        snapshot.data ?? fallback,
        expandable: expandable,
        expressive: expressive,
      ),
    );
  }

  Widget _buildLocalizedFormGuideCard(
    ExerciseInstructionContent instructions, {
    required bool expandable,
    required bool expressive,
  }) {
    final theme = Theme.of(context);
    final strings = _strings;
    final guideEntries = [
      (
        icon: Icons.self_improvement_outlined,
        title: strings.exerciseDetailSetup,
        body: instructions.setupNotes.isNotEmpty
            ? instructions.setupNotes
            : strings.exerciseDetailNoSetup,
      ),
      (
        icon: Icons.directions_run_outlined,
        title: strings.exerciseDetailExecution,
        body: instructions.executionNotes.isNotEmpty
            ? instructions.executionNotes
            : strings.exerciseDetailNoExecution,
      ),
      (
        icon: Icons.lightbulb_outline,
        title: strings.exerciseDetailTips,
        body: instructions.tipsNotes.isNotEmpty
            ? instructions.tipsNotes
            : strings.exerciseDetailNoTips,
      ),
    ];

    return _buildDetailCard(
      icon: Icons.menu_book_outlined,
      title: strings.exerciseDetailFormGuide,
      accent: _destinationTokens?.actionPrimary ?? theme.colorScheme.secondary,
      expressiveContainer: theme.colorScheme.surfaceContainerLow,
      expressiveOnContainer: theme.colorScheme.onSurface,
      expressive: expressive && _usesExpressiveCatalogSheet,
      expressiveShape: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(24),
      ),
      isExpanded: expandable ? _formGuideExpanded : true,
      onExpandedChanged: expandable
          ? (expanded) => setState(() => _formGuideExpanded = expanded)
          : null,
      child: Column(
        children: [
          for (var index = 0; index < guideEntries.length; index++) ...[
            if (index > 0) const Divider(height: 24),
            _buildGuideEntry(
              icon: guideEntries[index].icon,
              title: guideEntries[index].title,
              body: guideEntries[index].body,
              expressive: expressive && _usesExpressiveCatalogSheet,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required Color accent,
    required Color expressiveContainer,
    required Color expressiveOnContainer,
    required bool expressive,
    BorderRadius? expressiveShape,
    required bool isExpanded,
    required ValueChanged<bool>? onExpandedChanged,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final motion = theme.motionTokens;
    final isExpandable = onExpandedChanged != null;
    return AnimatedSize(
      duration: appMotionDuration(context, motion.quick),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: expressive ? expressiveContainer : surfaces.exerciseDetailCard,
          borderRadius: expressive
              ? expressiveShape ??
                    const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                      bottomRight: Radius.circular(20),
                    )
              : shapes.exerciseDetailCard,
          border: expressive
              ? null
              : Border.all(
                  color: accent.withValues(
                    alpha: surfaces.exerciseDetailCardBorderOpacity,
                  ),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              button: isExpandable,
              expanded: isExpanded,
              label: _strings.exerciseDetailSectionLabel(title),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isExpandable
                    ? () => onExpandedChanged(!isExpanded)
                    : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: expressive ? 48 : 34),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: expressive
                              ? accent.withValues(alpha: 0.13)
                              : accent.withValues(
                                  alpha: surfaces.exerciseDetailIconFillOpacity,
                                ),
                          borderRadius: expressive
                              ? const BorderRadius.all(Radius.circular(11))
                              : shapes.exerciseDetailIcon,
                        ),
                        child: Icon(icon, color: accent, size: 19),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: expressive
                                ? expressiveOnContainer
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isExpandable)
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: expressive ? expressiveOnContainer : accent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 13),
              DefaultTextStyle.merge(
                style: expressive
                    ? theme.textTheme.bodyMedium?.copyWith(
                        color: expressiveOnContainer,
                      )
                    : null,
                child: child,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.2),
    );
  }

  Color _vividLightNeoTagColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * 1.16).clamp(0.0, 1.0).toDouble())
        .withLightness((hsl.lightness * 0.62).clamp(0.28, 0.58).toDouble())
        .toColor();
  }

  Widget _buildDetailTag(
    String label, {
    required Color color,
    required Color expressiveContainer,
    required Color expressiveForeground,
    required bool expressive,
  }) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final tagColor =
        context.usesNeoPresentation && theme.brightness == Brightness.light
        ? _vividLightNeoTagColor(color)
        : color;
    final tagSurface = expressive
        ? expressiveContainer
        : tagColor.withValues(alpha: surfaces.exerciseDetailTagFillOpacity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: tagSurface,
        borderRadius: expressive
            ? const BorderRadius.all(Radius.circular(11))
            : shapes.exerciseDetailTag,
        border: expressive
            ? null
            : Border.all(
                color: tagColor.withValues(
                  alpha: surfaces.exerciseDetailTagBorderOpacity,
                ),
              ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: expressive ? expressiveForeground : tagColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGuideEntry({
    required IconData icon,
    required String title,
    required String body,
    required bool expressive,
  }) {
    final theme = Theme.of(context);
    final destination = expressive ? _destinationTokens : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expressive)
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destination?.surfaceTertiary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Icon(icon, size: 18, color: destination?.onSurfaceTertiary),
          )
        else
          Icon(icon, size: 19, color: theme.colorScheme.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: expressive
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapButton({
    required ExerciseDefinition definition,
    required Map<String, double> frequencyMap,
    required Color lowColor,
    required Color highColor,
    required double size,
    required BorderRadius borderRadius,
    double padding = 8,
    bool elevated = false,
  }) {
    final theme = Theme.of(context);
    final hasHeatmap = frequencyMap.isNotEmpty;

    return Semantics(
      button: hasHeatmap,
      label: hasHeatmap
          ? _strings.exerciseDetailOpenHeatmap
          : _strings.exerciseDetailNoHeatmap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasHeatmap
            ? () => _showHeatmapViewer(
                definition: definition,
                frequencyMap: frequencyMap,
                lowColor: lowColor,
                highColor: highColor,
              )
            : null,
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: theme.surfaceTokens.mediaPlaceholder.withValues(
              alpha: elevated ? theme.mediaTokens.overlayOpacity : 1,
            ),
            borderRadius: borderRadius,
            border: Border.all(color: theme.surfaceTokens.mediaOutline),
            boxShadow: elevated ? theme.mediaTokens.overlayShadow : null,
          ),
          child: hasHeatmap
              ? BodyHeatmap(
                  frequencyMap: frequencyMap,
                  lowColor: lowColor,
                  highColor: highColor,
                  width: size - (padding * 2),
                  height: size - (padding * 2),
                )
              : Icon(
                  Icons.accessibility_new,
                  color: theme.colorScheme.primary,
                  size: (size - (padding * 2)).clamp(32, 88).toDouble(),
                ),
        ),
      ),
    );
  }

  Future<void> _showImageViewer(
    File imageFile, {
    required ExerciseDefinition definition,
  }) {
    return showMediaImageViewer(
      context: context,
      file: imageFile,
      imageLabel: _strings.exerciseEditorMediaImage,
      zoomHint: _strings.exerciseDetailZoomHint,
      closeLabel: _strings.commonClose,
      footer: _buildFormGuideCard(
        definition,
        expandable: false,
        expressive: false,
      ),
    );
  }

  Future<void> _showHeatmapViewer({
    required ExerciseDefinition definition,
    required Map<String, double> frequencyMap,
    required Color lowColor,
    required Color highColor,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: MediaViewingColors.barrier,
      builder: (dialogContext) => Material(
        color: dialogContext.surfaceTokens.media,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: dialogContext.surfaceTokens.mediaPlaceholder,
                          borderRadius: dialogContext.mediaTokens.viewerShape,
                          border: Border.all(
                            color: dialogContext.surfaceTokens.mediaOutline,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = constraints.maxWidth;
                              return InteractiveViewer(
                                minScale: 0.8,
                                maxScale: 3,
                                boundaryMargin: const EdgeInsets.all(48),
                                child: SizedBox.expand(
                                  child: BodyHeatmap(
                                    frequencyMap: frequencyMap,
                                    lowColor: lowColor,
                                    highColor: highColor,
                                    width: size,
                                    height: size,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(child: Text(_strings.exerciseDetailZoomHint)),
                      const SizedBox(height: 18),
                      _buildTargetAnatomyCard(
                        definition,
                        expandable: false,
                        expressive: false,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  tooltip: _strings.commonClose,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsTab(ScrollController scrollCtrl) {
    final selectedIndex = _tfSelected.indexWhere((selected) => selected);
    final safeSelectedIndex = selectedIndex < 0
        ? _timeframes.length - 1
        : selectedIndex;
    final timeframe = _timeframes[safeSelectedIndex];
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return FutureBuilder<List<RepMaxRow>>(
      future: _repMaxFuture(timeframe),
      builder: (context, snapshot) {
        return ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            28 +
                (_usesExpressiveCatalogSheet
                    ? MediaQuery.viewPaddingOf(context).bottom
                    : 0),
          ),
          children: [
            _buildMetricsTimeframePicker(safeSelectedIndex),
            const SizedBox(height: 18),
            if (snapshot.connectionState != ConnectionState.done)
              _MetricsStateCard(
                icon: Icons.insights_outlined,
                title: _strings.exerciseDetailLoadingBestLifts,
                message: _strings.exerciseDetailLoadingBestLiftsBody,
                isLoading: true,
              )
            else if (snapshot.hasError)
              _MetricsStateCard(
                icon: Icons.error_outline,
                title: _strings.exerciseDetailMetricsUnavailable,
                message: _strings.exerciseDetailMetricsUnavailableBody,
              )
            else if ((snapshot.data ?? const <RepMaxRow>[]).isEmpty)
              _MetricsStateCard(
                icon: Icons.bar_chart_outlined,
                title: _strings.exerciseDetailNoBestLifts,
                message: _strings.exerciseDetailNoBestLiftsBody,
              )
            else
              _buildMetricResults(
                rows: snapshot.data!,
                timeframe: timeframe,
                weightUnit: weightUnit,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetricsTimeframePicker(int selectedIndex) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final motion = theme.motionTokens;
    final neo = context.usesNeoPresentation;
    final expressive = _usesExpressiveCatalogSheet;
    final destination = expressive ? _destinationTokens : null;
    final selectedSurface = expressive
        ? destination!.surfacePrimary
        : neo
        ? surfaces.settingsHero
        : theme.colorScheme.primary;
    final selectedForeground = expressive
        ? destination!.onSurfacePrimary
        : neo
        ? tonosForegroundForSurface(context, selectedSurface)
        : theme.colorScheme.onPrimary;
    final unselectedForeground = neo
        ? tonosForegroundForSurface(
            context,
            expressive
                ? theme.colorScheme.surfaceContainerLow
                : surfaces.exerciseDetailTimeframe,
          )
        : theme.colorScheme.onSurfaceVariant;
    final labels = <String>[
      _strings.exerciseDetailWeek,
      _strings.exerciseDetailMonth,
      _strings.exerciseDetailAllTime,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: expressive
            ? theme.colorScheme.surfaceContainerHigh
            : surfaces.exerciseDetailTimeframe,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(9),
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(17),
              )
            : shapes.exerciseDetailTimeframe,
        border: expressive
            ? null
            : Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: surfaces.exerciseDetailTimeframeBorderOpacity,
                ),
              ),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: _strings.exerciseDetailTimeframeMetrics(labels[index]),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: expressive
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(13),
                        )
                      : shapes.exerciseDetailTimeframeOption,
                  onTap: selected
                      ? null
                      : () => setState(() {
                          _tfSelected = List<bool>.generate(
                            labels.length,
                            (itemIndex) => itemIndex == index,
                          );
                        }),
                  child: AnimatedContainer(
                    duration: appMotionDuration(
                      context,
                      motion.exerciseDetailSelection,
                    ),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? selectedSurface : Colors.transparent,
                      borderRadius: expressive
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(13),
                              topRight: Radius.circular(7),
                              bottomLeft: Radius.circular(7),
                              bottomRight: Radius.circular(13),
                            )
                          : shapes.exerciseDetailTimeframeOption,
                    ),
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected
                            ? selectedForeground
                            : unselectedForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricResults({
    required List<RepMaxRow> rows,
    required String timeframe,
    required WeightUnit weightUnit,
  }) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final highestEstimatedOneRm = rows.fold<double>(
      0,
      (currentHighest, row) => math.max(currentHighest, row.oneErm),
    );

    return FutureBuilder<double?>(
      future: _volumeMaxFuture(timeframe),
      builder: (context, volumeSnapshot) {
        final volumeValue = volumeSnapshot.data;
        final volumeLabel =
            volumeSnapshot.connectionState != ConnectionState.done ||
                volumeSnapshot.hasError ||
                volumeValue == null
            ? '--'
            : WeightUnitFormatter.formatVolume(
                volumeValue,
                weightUnit,
                locale: Localizations.localeOf(context),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricSummaryCard(
                    icon: Icons.trending_up_rounded,
                    label: _strings.exerciseDetailTopEstimatedOneRm,
                    value: WeightUnitFormatter.formatWeight(
                      highestEstimatedOneRm,
                      weightUnit,
                      locale: Localizations.localeOf(context),
                    ),
                    color: theme.colorScheme.primary,
                    expressiveSurface: _destinationTokens?.surfacePrimary,
                    expressiveForeground: _destinationTokens?.onSurfacePrimary,
                    expressive: _usesExpressiveCatalogSheet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricSummaryCard(
                    icon: Icons.workspace_premium_outlined,
                    label: _strings.exerciseDetailVolumeBest,
                    value: volumeLabel,
                    color: theme.colorScheme.tertiary,
                    expressiveSurface: _destinationTokens?.surfaceTertiary,
                    expressiveForeground: _destinationTokens?.onSurfaceTertiary,
                    expressive: _usesExpressiveCatalogSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final compactHeader =
                    _usesExpressiveCatalogSheet &&
                    (constraints.maxWidth < 360 ||
                        MediaQuery.textScalerOf(context).scale(1) >= 1.5);
                final rangeCount = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _usesExpressiveCatalogSheet
                        ? _destinationTokens!.surfaceSelected
                        : theme.colorScheme.primary.withValues(
                            alpha: surfaces.exerciseDetailRangeFillOpacity,
                          ),
                    borderRadius: _usesExpressiveCatalogSheet
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(11),
                          )
                        : shapes.exerciseDetailTag,
                  ),
                  child: Text(
                    _strings.exerciseDetailRanges(rows.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _usesExpressiveCatalogSheet
                          ? _destinationTokens!.onSurfaceSelected
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
                final heading = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _strings.exerciseDetailRepBests,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _strings.exerciseDetailRepBestsBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _usesExpressiveCatalogSheet
                            ? _destinationTokens?.supportingForeground
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
                if (compactHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heading,
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: rangeCount,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: heading),
                    rangeCount,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _RepBestMetricsList(
              rows: rows,
              weightUnit: weightUnit,
              expressive: _usesExpressiveCatalogSheet,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordsTab(ScrollController scrollCtrl) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return FutureBuilder<_ExerciseHistoryPage>(
      future: _historyFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text(_strings.exerciseDetailHistoryLoadFailed));
        }
        final firstPage = snap.data;
        final history = <HistoryRecord>[
          ...?firstPage?.records,
          ..._olderHistory,
        ];
        if (history.isEmpty) {
          return Center(child: Text(_strings.exerciseDetailNoHistory));
        }
        final hasMoreHistory = _olderHistory.isEmpty
            ? firstPage?.hasMore ?? false
            : _hasMoreHistory;

        final records = _buildRecordTrendPoints(history);
        final hasSetRecordBadges = history.any(
          (record) =>
              record.badges.setBadges.values.any((badges) => badges.isNotEmpty),
        );
        final expressive = _usesExpressiveCatalogSheet;

        return ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            28 +
                (_usesExpressiveCatalogSheet
                    ? MediaQuery.viewPaddingOf(context).bottom
                    : 0),
          ),
          children: [
            if (expressive)
              _buildExpressiveRecordTrendModule(records, weightUnit)
            else ...[
              Text(
                _strings.exerciseDetailPerformanceTrend,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _ExerciseRecordTrendChart(
                points: records,
                weightUnit: weightUnit,
              ),
              const SizedBox(height: 10),
              _buildRecordLegend(),
            ],
            if (expressive) ...[
              const SizedBox(height: 22),
              Text(
                _strings.fullHistoryTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (hasSetRecordBadges)
              if (expressive)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    key: const ValueKey(
                      'exercise-detail-expressive-record-badge-legend',
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: const WorkoutRecordBadgeLegend(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
              else
                const WorkoutRecordBadgeLegend(
                  padding: EdgeInsets.only(bottom: 6),
                ),
            for (var index = 0; index < history.length; index++) ...[
              _ExerciseHistorySessionCard(
                record: history[index],
                weightUnit: weightUnit,
                onOpenSession: () =>
                    _openHistorySession(context, history[index].sessionId),
              ),
              if (index < history.length - 1) const SizedBox(height: 10),
            ],
            if (hasMoreHistory) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingMoreHistory
                      ? null
                      : () => _loadMoreHistory(history),
                  icon: _isLoadingMoreHistory
                      ? SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(
                    _isLoadingMoreHistory
                        ? _strings.exerciseDetailLoadingSessions
                        : _strings.exerciseDetailLoadMoreSessions,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(
                        alpha: surfaces.exerciseDetailLoadMoreBorderOpacity,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: shapes.exerciseDetailLoadMore,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildExpressiveRecordTrendModule(
    List<_ExerciseRecordPoint> records,
    WeightUnit weightUnit,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _strings.exerciseDetailPerformanceTrend,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _ExerciseRecordTrendChart(points: records, weightUnit: weightUnit),
          const SizedBox(height: 10),
          _buildRecordLegend(),
        ],
      ),
    );
  }

  Widget _buildRecordLegend() {
    final bestWeight = _RecordLegendDot(
      color: _exerciseRecordActualSeriesColor(context),
      label: _strings.exerciseDetailBestWeight,
    );
    final estimatedOneRm = _RecordLegendDot(
      color: _exerciseRecordEstimatedSeriesColor(context),
      label: _strings.exerciseDetailEstimatedOneRm,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        if (constraints.maxWidth < 360 || textScale >= 1.5) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: constraints.maxWidth, child: bestWeight),
              const SizedBox(height: 8),
              SizedBox(width: constraints.maxWidth, child: estimatedOneRm),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: bestWeight),
            const SizedBox(width: 16),
            Expanded(child: estimatedOneRm),
          ],
        );
      },
    );
  }

  Widget _buildSheetDragHandle(BuildContext context) {
    final destination = _usesExpressiveCatalogSheet ? _destinationTokens : null;
    return Semantics(
      label: _strings.exerciseDetailResizeLabel,
      hint: _strings.exerciseDetailResizeHint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          final screenHeight = MediaQuery.sizeOf(context).height;
          if (screenHeight <= 0) return;

          final nextSize =
              (_sheetController.size - details.delta.dy / screenHeight)
                  .clamp(_sheetMinSize, _sheetMaxSize)
                  .toDouble();
          _sheetController.jumpTo(nextSize);
        },
        child: SizedBox(
          height: destination == null ? 28 : 48,
          width: double.infinity,
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color:
                    (destination?.onSurfacePrimary ??
                            Theme.of(context).colorScheme.onSurfaceVariant)
                        .withValues(
                          alpha:
                              context.surfaceTokens.exerciseDetailHandleOpacity,
                        ),
                borderRadius: context.shapeTokens.pill,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effects = context.effectTokens;
    final shapes = context.shapeTokens;
    final expressive = _usesExpressiveCatalogSheet;
    final destination = expressive ? _destinationTokens : null;
    return DraggableScrollableSheet(
      controller: _sheetController,
      expand: false,
      minChildSize: _sheetMinSize,
      initialChildSize: _sheetInitialSize,
      maxChildSize: _sheetMaxSize,
      builder: (_, scrollCtrl) => DefaultTabController(
        length: 3,
        child: Material(
          key: expressive
              ? const ValueKey('exercise-detail-expressive-shell')
              : null,
          color: destination?.pageCanvas,
          elevation: effects.exerciseDetailSheetElevation,
          borderRadius: expressive
              ? const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(14),
                )
              : shapes.exerciseDetailSheet,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              if (expressive)
                _buildExpressiveSheetHeader(destination!)
              else ...[
                _buildSheetDragHandle(context),
                _buildStandardSheetHeader(),
              ],
              if (expressive)
                _buildExpressiveTabRail(destination!)
              else ...[
                _buildSheetTabBar(),
                const Divider(height: 1),
              ],

              // Tab Views
              Expanded(
                child: expressive
                    ? ColoredBox(
                        key: const ValueKey(
                          'exercise-detail-expressive-content-zone',
                        ),
                        color: destination!.pageCanvas,
                        child: _buildSheetTabViews(scrollCtrl),
                      )
                    : _buildSheetTabViews(scrollCtrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardSheetHeader() {
    return KeyedSubtree(
      key: _headerTutorialKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: LocalizedExerciseName(
                definition: widget.definition,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: _strings.commonClose,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressiveSheetHeader(AppExpressiveDestinationTokens tokens) {
    final theme = Theme.of(context);
    return DecoratedBox(
      key: const ValueKey('exercise-detail-expressive-header'),
      decoration: BoxDecoration(
        color: tokens.surfacePrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          _buildSheetDragHandle(context),
          KeyedSubtree(
            key: _headerTutorialKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12, bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: LocalizedExerciseName(
                      definition: widget.definition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: tokens.onSurfacePrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: _strings.commonClose,
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      foregroundColor: tokens.onSurfaceSelected,
                      backgroundColor: tokens.surfaceSelected,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetTabBar() {
    return KeyedSubtree(
      key: _tabsTutorialKey,
      child: TabBar(
        tabs: [
          Tab(text: _strings.exerciseDetailTabDetails),
          Tab(text: _strings.exerciseDetailTabMetrics),
          Tab(text: _strings.exerciseDetailTabRecords),
        ],
      ),
    );
  }

  Widget _buildExpressiveTabRail(AppExpressiveDestinationTokens tokens) {
    final theme = Theme.of(context);
    final labels = [
      _strings.exerciseDetailTabDetails,
      _strings.exerciseDetailTabMetrics,
      _strings.exerciseDetailTabRecords,
    ];
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w800,
    );
    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final compactViewport = viewportConstraints.maxWidth < 360;
        return Container(
          key: const ValueKey('exercise-detail-expressive-tab-rail'),
          margin: compactViewport
              ? const EdgeInsets.fromLTRB(4, 10, 4, 8)
              : const EdgeInsets.fromLTRB(12, 10, 12, 8),
          padding: compactViewport ? EdgeInsets.zero : const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Builder(
            builder: (railContext) {
              final controller = DefaultTabController.of(railContext);
              final motion = theme.motionTokens;
              var widestLabel = 0.0;
              for (final label in labels) {
                final painter = TextPainter(
                  text: TextSpan(text: label, style: labelStyle),
                  textDirection: Directionality.of(railContext),
                  textScaler: MediaQuery.textScalerOf(railContext),
                  maxLines: 1,
                )..layout();
                widestLabel = math.max(widestLabel, painter.width);
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final compactRail = compactViewport;
                  final labelPadding = compactRail
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 16);
                  final horizontalLabelWidth =
                      constraints.maxWidth / labels.length -
                      (compactRail ? 0 : 32);
                  final needsStackedLayout = widestLabel > horizontalLabelWidth;
                  final selectionDuration = appMotionDuration(
                    railContext,
                    motion.exerciseDetailSelection,
                  );

                  if (needsStackedLayout) {
                    return KeyedSubtree(
                      key: _tabsTutorialKey,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                              var index = 0;
                              index < labels.length;
                              index++
                            ) ...[
                              if (index > 0)
                                Divider(
                                  height: 1,
                                  indent: 10,
                                  endIndent: 10,
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.55),
                                ),
                              Semantics(
                                button: true,
                                selected: controller.index == index,
                                label: labels[index],
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: controller.index == index
                                        ? null
                                        : () => controller.animateTo(
                                            index,
                                            duration: selectionDuration,
                                            curve: Curves.easeOutCubic,
                                          ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(7),
                                      bottomLeft: Radius.circular(7),
                                      bottomRight: Radius.circular(13),
                                    ),
                                    child: AnimatedContainer(
                                      duration: selectionDuration,
                                      curve: Curves.easeOutCubic,
                                      constraints: const BoxConstraints(
                                        minHeight: 48,
                                      ),
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: controller.index == index
                                            ? tokens.surfacePrimary
                                            : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(7),
                                          bottomLeft: Radius.circular(7),
                                          bottomRight: Radius.circular(13),
                                        ),
                                      ),
                                      child: Text(
                                        labels[index],
                                        maxLines: 1,
                                        softWrap: false,
                                        textAlign: TextAlign.center,
                                        style: labelStyle?.copyWith(
                                          color: controller.index == index
                                              ? tokens.onSurfacePrimary
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          fontWeight: controller.index == index
                                              ? FontWeight.w800
                                              : FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return KeyedSubtree(
                    key: _tabsTutorialKey,
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(2),
                      labelPadding: labelPadding,
                      indicator: BoxDecoration(
                        color: tokens.surfacePrimary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: tokens.onSurfacePrimary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: labelStyle,
                      unselectedLabelStyle: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      tabs: [for (final label in labels) Tab(text: label)],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSheetTabViews(ScrollController scrollCtrl) {
    return KeyedSubtree(
      key: _contentTutorialKey,
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDetailsTab(scrollCtrl),
          _buildMetricsTab(scrollCtrl),
          _buildRecordsTab(scrollCtrl),
        ],
      ),
    );
  }
}

class _ExerciseHistorySessionCard extends StatelessWidget {
  final HistoryRecord record;
  final WeightUnit weightUnit;
  final VoidCallback onOpenSession;

  const _ExerciseHistorySessionCard({
    required this.record,
    required this.weightUnit,
    required this.onOpenSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final neo = context.usesNeoPresentation;
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    final expressive =
        destination?.family == AppExpressiveDestinationFamily.catalog &&
        theme.appThemeFamilyIdentity ==
            AppThemeFamilyIdentity.expressivePreview;
    final recordSurface = expressive
        ? scheme.surfaceContainerLow
        : surfaces.exerciseDetailRecord;
    final recordForeground = neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailRecord)
        : scheme.onSurface;
    final recordActionFill = expressive
        ? destination!.surfaceSelected
        : scheme.secondary.withValues(
            alpha: surfaces.exerciseDetailRecordActionFillOpacity,
          );
    final recordActionForeground = expressive
        ? destination!.onSurfaceSelected
        : neo
        ? tonosForegroundForSurface(
            context,
            recordActionFill,
            parentSurface: surfaces.exerciseDetailRecord,
          )
        : scheme.secondary;
    final strings = AppLocalizations.of(context);
    final dateLabel = LocalizedFormatters.dateTime(
      record.displayDateTime,
      Localizations.localeOf(context),
    );
    final setCount = record.sets.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recordSurface,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(19),
              )
            : shapes.exerciseDetailRecord,
        border: expressive
            ? null
            : Border.all(
                color: scheme.primary.withValues(
                  alpha: surfaces.exerciseDetailRecordBorderOpacity,
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: expressive
                      ? destination!.surfaceSelected
                      : scheme.primary.withValues(
                          alpha: surfaces.exerciseDetailRecordIconFillOpacity,
                        ),
                  borderRadius: expressive
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(12),
                        )
                      : shapes.exerciseDetailIcon,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: expressive
                      ? destination!.onSurfaceSelected
                      : neo
                      ? recordForeground
                      : scheme.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: expressive
                        ? scheme.onSurface
                        : neo
                        ? recordForeground
                        : scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (record.badges.isFirstRecord) ...[
                const SizedBox(width: 8),
                FirstRecordBadge(foregroundSurface: recordSurface),
              ],
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: strings.exerciseDetailOpenWorkoutWithSets(setCount),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: shapes.exerciseDetailRecordAction,
                  child: InkWell(
                    onTap: onOpenSession,
                    borderRadius: shapes.exerciseDetailRecordAction,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: expressive ? 48 : 0,
                        minHeight: expressive ? 48 : 0,
                      ),
                      child: Container(
                        padding: expressive
                            ? const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              )
                            : const EdgeInsets.fromLTRB(8, 5, 5, 5),
                        decoration: BoxDecoration(
                          color: recordActionFill,
                          borderRadius: shapes.exerciseDetailRecordAction,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings.exerciseDetailSetCount(setCount),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: recordActionForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: recordActionForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          for (final entry in record.sets.asMap().entries)
            _ExerciseHistorySetRow(
              index: entry.key + 1,
              set: entry.value,
              badges: record.badges.forSet(entry.key),
              weightUnit: weightUnit,
              expressive: expressive,
              recordSurface: recordSurface,
              destination: destination,
            ),
        ],
      ),
    );
  }
}

class _ExerciseHistorySetRow extends StatelessWidget {
  final int index;
  final ExerciseSet set;
  final List<WorkoutRecordBadge> badges;
  final WeightUnit weightUnit;
  final bool expressive;
  final Color recordSurface;
  final AppExpressiveDestinationTokens? destination;

  const _ExerciseHistorySetRow({
    required this.index,
    required this.set,
    required this.badges,
    required this.weightUnit,
    this.expressive = false,
    this.recordSurface = Colors.transparent,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = theme.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final recordForeground = neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailRecord)
        : scheme.onSurface;
    final recordSecondary = neo
        ? tonosSecondaryForegroundForSurface(
            context,
            surfaces.exerciseDetailRecord,
          )
        : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: expressive
                  ? destination?.surfaceSelected
                  : scheme.primary.withValues(
                      alpha: surfaces.exerciseDetailRecordSetFillOpacity,
                    ),
              shape: BoxShape.circle,
            ),
            child: Text(
              LocalizedFormatters.number(
                index,
                Localizations.localeOf(context),
                maximumFractionDigits: 0,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: expressive
                    ? destination?.onSurfaceSelected
                    : neo
                    ? recordForeground
                    : scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (badges.isEmpty)
            Expanded(
              child: Text(
                _formatSet(
                  set,
                  weightUnit,
                  locale: Localizations.localeOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: neo ? recordForeground : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            Expanded(
              flex: 2,
              child: Text(
                _formatSet(
                  set,
                  weightUnit,
                  locale: Localizations.localeOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: neo ? recordForeground : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        var badgeIndex = 0;
                        badgeIndex < badges.length;
                        badgeIndex++
                      ) ...[
                        if (badgeIndex > 0) const SizedBox(width: 4),
                        WorkoutRecordBadgeChip(
                          badge: badges[badgeIndex],
                          foregroundSurface: recordSurface,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              AppLocalizations.of(context).exerciseDetailEstimatedMax(
                WeightUnitFormatter.formatWeight(
                  _estimatedOneRm(set),
                  weightUnit,
                  locale: Localizations.localeOf(context),
                ),
              ),
              maxLines: 1,
              style: theme.textTheme.labelMedium?.copyWith(
                color: recordSecondary,
                fontStyle: expressive ? null : FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? expressiveSurface;
  final Color? expressiveForeground;
  final bool expressive;

  const _MetricSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.expressiveSurface,
    this.expressiveForeground,
    this.expressive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: expressive
            ? expressiveSurface
            : color.withValues(alpha: surfaces.exerciseDetailMetricFillOpacity),
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(22),
              )
            : shapes.exerciseDetailMetric,
        border: expressive
            ? null
            : Border.all(
                color: color.withValues(
                  alpha: surfaces.exerciseDetailMetricBorderOpacity,
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: expressive ? expressiveForeground : color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: expressive ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: expressive ? expressiveForeground : color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: (theme.textTheme.titleLarge ?? theme.textTheme.titleMedium)
                  ?.copyWith(
                    color: expressive ? expressiveForeground : null,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepBestMetricsList extends StatelessWidget {
  final List<RepMaxRow> rows;
  final WeightUnit weightUnit;
  final bool expressive;

  const _RepBestMetricsList({
    required this.rows,
    required this.weightUnit,
    this.expressive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout =
            expressive &&
            (constraints.maxWidth < 360 ||
                MediaQuery.textScalerOf(context).scale(1) >= 1.5);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: expressive
                ? theme.colorScheme.surfaceContainerLow
                : surfaces.exerciseDetailMetricList,
            borderRadius: expressive
                ? const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(18),
                  )
                : shapes.exerciseDetailMetric,
            border: expressive
                ? null
                : Border.all(
                    color: scheme.outlineVariant.withValues(
                      alpha: surfaces.exerciseDetailMetricListBorderOpacity,
                    ),
                  ),
          ),
          child: Column(
            children: List<Widget>.generate(rows.length, (index) {
              final row = rows[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Builder(
                      builder: (context) {
                        final repBadge = Container(
                          key: const ValueKey('exercise-detail-rep-best-badge'),
                          width: compactLayout ? null : 54,
                          height: 40,
                          padding: compactLayout
                              ? const EdgeInsets.symmetric(horizontal: 10)
                              : EdgeInsets.zero,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: expressive
                                ? theme
                                      .extension<
                                        AppExpressiveDestinationTokens
                                      >()
                                      ?.surfaceSelected
                                : scheme.primary.withValues(
                                    alpha: surfaces
                                        .exerciseDetailMetricRepFillOpacity,
                                  ),
                            borderRadius: expressive
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(13),
                                  )
                                : shapes.exerciseDetailMetricRep,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LocalizedFormatters.number(
                                  row.repCount,
                                  Localizations.localeOf(context),
                                  maximumFractionDigits: 0,
                                ),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: expressive
                                      ? theme
                                            .extension<
                                              AppExpressiveDestinationTokens
                                            >()
                                            ?.onSurfaceSelected
                                      : scheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                AppLocalizations.of(context).exerciseDetailReps,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: expressive
                                      ? theme
                                            .extension<
                                              AppExpressiveDestinationTokens
                                            >()
                                            ?.onSurfaceSelected
                                      : scheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                        final bestWeight = _CompactRepMetricValue(
                          label: AppLocalizations.of(context)
                              .exerciseDetailBestWeight,
                          value: WeightUnitFormatter.formatWeight(
                            row.rmValue,
                            weightUnit,
                            locale: Localizations.localeOf(context),
                          ),
                          color: scheme.onSurface,
                        );
                        final setVolume = _CompactRepMetricValue(
                          label: AppLocalizations.of(context)
                              .exerciseDetailSetVolume,
                          value: WeightUnitFormatter.formatVolume(
                            row.rmValue * row.repCount,
                            weightUnit,
                            locale: Localizations.localeOf(context),
                          ),
                          color: expressive
                              ? theme
                                        .extension<
                                          AppExpressiveDestinationTokens
                                        >()
                                        ?.actionPrimary ??
                                    scheme.tertiary
                              : scheme.tertiary,
                        );
                        if (compactLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: repBadge,
                              ),
                              const SizedBox(height: 12),
                              bestWeight,
                              const SizedBox(height: 10),
                              setVolume,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            repBadge,
                            const SizedBox(width: 12),
                            Expanded(child: bestWeight),
                            const SizedBox(width: 12),
                            Expanded(child: setVolume),
                          ],
                        );
                      },
                    ),
                  ),
                  if (index < rows.length - 1)
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(
                        alpha: surfaces.exerciseDetailMetricListDividerOpacity,
                      ),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _CompactRepMetricValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactRepMetricValue({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool isLoading;

  const _MetricsStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neo = context.usesNeoPresentation;
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final expressive =
        theme.extension<AppExpressiveDestinationTokens>()?.family ==
            AppExpressiveDestinationFamily.catalog &&
        theme.appThemeFamilyIdentity ==
            AppThemeFamilyIdentity.expressivePreview;
    final cardForeground = neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailState)
        : theme.colorScheme.onSurface;
    final cardSecondary = neo
        ? tonosSecondaryForegroundForSurface(
            context,
            surfaces.exerciseDetailState,
          )
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: expressive
            ? theme.colorScheme.surfaceContainerLow
            : surfaces.exerciseDetailState,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(9),
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(20),
              )
            : shapes.exerciseDetailState,
        border: expressive
            ? null
            : Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: surfaces.exerciseDetailStateBorderOpacity,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: neo ? cardForeground : theme.colorScheme.primary,
              ),
            )
          else
            Icon(
              icon,
              color: neo || expressive
                  ? cardForeground
                  : theme.colorScheme.primary,
              size: 24,
            ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: neo || expressive ? cardForeground : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cardSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<_ExerciseRecordPoint> _buildRecordTrendPoints(
  List<HistoryRecord> history,
) {
  final ordered = [...history]..sort((a, b) => a.date.compareTo(b.date));
  final points = <_ExerciseRecordPoint>[];
  for (final record in ordered) {
    if (record.sets.isEmpty) continue;
    final point = _ExerciseRecordPoint.from(record);
    if (point.bestWeight <= 0 && point.bestEstimatedOneRm <= 0) continue;
    points.add(point);
  }
  return points;
}

class _ExerciseRecordPoint {
  final DateTime completedAt;
  final LocalCalendarDay calendarDay;
  final double bestWeight;
  final double bestEstimatedOneRm;
  final ExerciseSet bestSet;

  const _ExerciseRecordPoint({
    required this.completedAt,
    required this.calendarDay,
    required this.bestWeight,
    required this.bestEstimatedOneRm,
    required this.bestSet,
  });

  DateTime get displayDateTime => calendarDay.atLocalTime(completedAt);

  factory _ExerciseRecordPoint.from(HistoryRecord record) {
    var bestSet = record.sets.first;
    var bestEstimatedOneRm = _estimatedOneRm(bestSet);

    for (final set in record.sets.skip(1)) {
      final estimatedOneRm = _estimatedOneRm(set);
      if (estimatedOneRm > bestEstimatedOneRm) {
        bestSet = set;
        bestEstimatedOneRm = estimatedOneRm;
      }
    }

    final bestWeight = record.sets.fold<double>(
      0,
      (best, set) => set.weight > best ? set.weight : best,
    );

    return _ExerciseRecordPoint(
      completedAt: record.date,
      calendarDay: record.calendarDay,
      bestWeight: bestWeight,
      bestEstimatedOneRm: bestEstimatedOneRm,
      bestSet: bestSet,
    );
  }
}

Color _exerciseRecordActualSeriesColor(BuildContext context) {
  final theme = Theme.of(context);
  if (!context.usesNeoPresentation) {
    return theme.colorScheme.primary;
  }
  return tonosPrimarySeriesForSurface(
    context,
    theme.surfaceTokens.exerciseDetailChart,
  );
}

Color _exerciseRecordEstimatedSeriesColor(BuildContext context) {
  return tonosEstimatedOneRmForSurface(
    context,
    Theme.of(context).surfaceTokens.exerciseDetailChart,
  );
}

class _ExerciseRecordTrendChart extends StatelessWidget {
  final List<_ExerciseRecordPoint> points;
  final WeightUnit weightUnit;

  const _ExerciseRecordTrendChart({
    required this.points,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = theme.surfaceTokens;
    final shapes = theme.shapeTokens;
    final motion = theme.motionTokens;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    final expressive =
        destination?.family == AppExpressiveDestinationFamily.catalog &&
        theme.appThemeFamilyIdentity ==
            AppThemeFamilyIdentity.expressivePreview;
    final chartForeground = expressive
        ? scheme.onSurfaceVariant
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailChart)
        : scheme.onSurfaceVariant;
    final chartEmptyForeground = expressive
        ? scheme.onSurfaceVariant
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailChartEmpty)
        : scheme.onSurfaceVariant;
    final tooltipForeground = expressive
        ? scheme.onSurface
        : neo
        ? tonosForegroundForSurface(context, surfaces.exerciseDetailTooltip)
        : scheme.onSurface;

    if (points.isEmpty) {
      return Container(
        height: 188,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: expressive
              ? scheme.surfaceContainerLowest
              : surfaces.exerciseDetailChartEmpty,
          borderRadius: expressive
              ? const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(18),
                )
              : shapes.exerciseDetailChart,
        ),
        child: Text(
          AppLocalizations.of(context).exerciseDetailNoChartData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: chartEmptyForeground,
          ),
        ),
      );
    }

    final bounds = _recordChartBounds(points);
    final labelIndexes = _recordDateLabelIndexes(points.length);
    final showTimes = _shouldUseTimeLabels(points);
    final actualColor = _exerciseRecordActualSeriesColor(context);
    final estimatedColor = _exerciseRecordEstimatedSeriesColor(context);
    final hasBestWeight = points.any((point) => point.bestWeight > 0);
    final hasEstimatedOneRm = points.any(
      (point) => point.bestEstimatedOneRm > 0,
    );

    return Container(
      height: 214,
      padding: const EdgeInsets.fromLTRB(8, 14, 10, 8),
      decoration: BoxDecoration(
        color: expressive
            ? scheme.surfaceContainerLowest
            : surfaces.exerciseDetailChart,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(18),
              )
            : shapes.exerciseDetailChart,
        border: expressive
            ? null
            : Border.all(
                color: scheme.outlineVariant.withValues(
                  alpha: surfaces.exerciseDetailChartBorderOpacity,
                ),
              ),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, points.length - 1).toDouble(),
          minY: bounds.minY,
          maxY: bounds.maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: shapes.exerciseDetailChartTooltip,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              tooltipMargin: 8,
              maxContentWidth: 164,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => surfaces.exerciseDetailTooltip,
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return const <LineTooltipItem?>[];
                final spot = touchedSpots.first;
                final index = spot.x
                    .round()
                    .clamp(0, points.length - 1)
                    .toInt();
                final point = points[index];
                final textStyle =
                    theme.textTheme.labelSmall?.copyWith(
                      color: tooltipForeground,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ) ??
                    TextStyle(
                      color: tooltipForeground,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    );
                return [
                  LineTooltipItem(
                    '${LocalizedFormatters.dateTime(point.displayDateTime, Localizations.localeOf(context))}\n'
                    '${strings.exerciseDetailWeightAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestWeight, weightUnit, locale: Localizations.localeOf(context))} | '
                    '${strings.exerciseDetailEstimatedAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestEstimatedOneRm, weightUnit, locale: Localizations.localeOf(context))} | '
                    '${strings.exerciseDetailTopAbbreviation} ${_formatSet(point.bestSet, weightUnit, locale: Localizations.localeOf(context))}',
                    textStyle,
                  ),
                  for (var i = 1; i < touchedSpots.length; i++) null,
                ];
              },
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: bounds.interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(
                alpha: surfaces.exerciseDetailChartGridOpacity,
              ),
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
                interval: bounds.interval,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 2,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(
                      meta,
                      distanceFromEdge: 2,
                    ),
                    child: Text(
                      _compactWeight(
                        value,
                        weightUnit,
                        Localizations.localeOf(context),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chartForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if ((value - index).abs() > 0.2 ||
                      !labelIndexes.contains(index) ||
                      index < 0 ||
                      index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(
                      meta,
                      distanceFromEdge: 4,
                    ),
                    child: Text(
                      _recordAxisLabel(
                        points[index],
                        showTimes,
                        Localizations.localeOf(context),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chartForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              show: hasBestWeight,
              spots: [
                for (var i = 0; i < points.length; i++)
                  _recordSpot(i, points[i].bestWeight),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: actualColor,
              barWidth: 2.6,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: actualColor.withValues(
                  alpha: surfaces.exerciseDetailChartAreaOpacity,
                ),
              ),
            ),
            LineChartBarData(
              show: hasEstimatedOneRm,
              spots: [
                for (var i = 0; i < points.length; i++)
                  _recordSpot(i, points[i].bestEstimatedOneRm),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: estimatedColor,
              barWidth: 2.4,
              dashArray: const [6, 4],
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
        duration: appMotionDuration(context, motion.exerciseDetailSelection),
        curve: Curves.easeOut,
      ),
    );
  }
}

class _RecordLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _RecordLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = theme.surfaceTokens;
    final outlined = context.surfaceDecorationTokens.panel.outlined;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: outlined
                ? Border.all(
                    color: tonosForegroundForSurface(context, surfaces.sheet),
                    width: theme.shapeTokens.outlineWidth,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: theme.textTheme.labelSmall)),
      ],
    );
  }
}

class _RecordChartBounds {
  final double minY;
  final double maxY;
  final double interval;

  const _RecordChartBounds({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}

_RecordChartBounds _recordChartBounds(List<_ExerciseRecordPoint> points) {
  final values = [
    for (final point in points) point.bestWeight,
    for (final point in points) point.bestEstimatedOneRm,
  ].where((value) => value > 0).toList();

  if (values.isEmpty) {
    return const _RecordChartBounds(minY: 0, maxY: 10, interval: 5);
  }

  final minValue = values.reduce((a, b) => a < b ? a : b);
  final maxValue = values.reduce((a, b) => a > b ? a : b);
  final range = math.max(1.0, maxValue - minValue);
  final padding = math.max(2.5, range * 0.05);
  final rawMinY = math.max(0.0, minValue - padding);
  final rawMaxY = maxValue + padding;
  final interval = _niceRecordInterval((rawMaxY - rawMinY) / 3);
  final minY = math.max(0.0, (rawMinY / interval).floor() * interval);
  final maxY = math.max(
    minY + interval,
    (rawMaxY / interval).ceil() * interval,
  );

  return _RecordChartBounds(minY: minY, maxY: maxY, interval: interval);
}

FlSpot _recordSpot(int index, double value) {
  if (value <= 0) return FlSpot.nullSpot;
  return FlSpot(index.toDouble(), value);
}

double _niceRecordInterval(double target) {
  if (target <= 0) return 1;
  final exponent = (math.log(target) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  for (final multiplier in const [1, 2, 2.5, 5, 10]) {
    final interval = magnitude * multiplier;
    if (interval >= target) return interval.toDouble();
  }
  return magnitude * 10;
}

Set<int> _recordDateLabelIndexes(int length) {
  if (length <= 4) {
    return {for (var i = 0; i < length; i++) i};
  }
  return {0, length ~/ 2, length - 1};
}

bool _shouldUseTimeLabels(List<_ExerciseRecordPoint> points) {
  final days = {for (final point in points) point.calendarDay.storageKey};
  return days.length == 1;
}

String _recordAxisLabel(
  _ExerciseRecordPoint point,
  bool showTime,
  Locale locale,
) {
  return showTime
      ? LocalizedFormatters.time(point.completedAt, locale)
      : LocalizedFormatters.shortDate(
          point.calendarDay.toLocalDateTime(),
          locale,
        );
}

double _estimatedOneRm(ExerciseSet set) {
  if (set.reps <= 1) return set.weight;
  return set.weight * (1 + 0.0333 * set.reps);
}

String _formatSet(ExerciseSet set, WeightUnit weightUnit, {Locale? locale}) {
  final reps = locale == null
      ? set.reps.toString()
      : LocalizedFormatters.number(set.reps, locale, maximumFractionDigits: 0);
  return '${WeightUnitFormatter.formatWeight(set.weight, weightUnit, locale: locale)} x $reps';
}

String _compactWeight(double value, WeightUnit weightUnit, [Locale? locale]) {
  final displayValue = WeightUnitFormatter.fromPounds(value, weightUnit);
  if (displayValue.abs() >= 1000) {
    final digits = displayValue.abs() >= 10000 ? 0 : 1;
    final text = locale == null
        ? (displayValue / 1000).toStringAsFixed(digits)
        : LocalizedFormatters.number(
            displayValue / 1000,
            locale,
            minimumFractionDigits: digits,
            maximumFractionDigits: digits,
          );
    return '${text}k';
  }
  return _cleanNumber(displayValue, locale);
}

String _cleanNumber(double value, [Locale? locale]) {
  final fractionDigits = value == value.roundToDouble() ? 0 : 1;
  if (locale == null) return value.toStringAsFixed(fractionDigits);
  return LocalizedFormatters.number(
    value,
    locale,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  );
}
