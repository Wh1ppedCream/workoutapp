// File: lib/widgets/exercise_detail_sheet.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../services/tutorial_state_store.dart';
import '../utils/localized_body_part_name.dart';
import '../theme/theme_extensions.dart';
import '../utils/localized_digit_formatter.dart';
import '../utils/tutorial_launcher.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';
import 'guided_tutorial_overlay.dart';
import 'workout_record_badges.dart';

/// Simple record model for history tab
class HistoryRecord {
  final DateTime date;
  final int sessionId;
  final int exerciseId;
  final String sessionDateValue;
  final List<ExerciseSet> sets;
  final WorkoutExerciseRecordBadges badges;

  HistoryRecord({
    required this.date,
    required this.sessionId,
    required this.exerciseId,
    required this.sessionDateValue,
    required this.sets,
    required this.badges,
  });
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
  final VoidCallback onImageTap;
  final VoidCallback onImageLoadFailed;

  const _ExerciseMediaPreviewCard({
    required this.previewFile,
    required this.heatmapOverlay,
    required this.onImageTap,
    required this.onImageLoadFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
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
                  color: theme.colorScheme.surface,
                  child: Image.file(
                    previewFile,
                    fit: BoxFit.cover,
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
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.zoom_in, color: Colors.white, size: 18),
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

  const ExerciseDetailSheet({
    super.key,
    required this.definition,
    required this.defId,
  });

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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late Future<_ExerciseHistoryPage> _historyFuture;
  late Future<Map<int, WorkoutExerciseRecordBadges>>
  _currentHistoryBadgesFuture;
  late Future<_LoadedExerciseMedia?> _primaryMediaFuture;
  final Map<String, Future<List<RepMaxRow>>> _repMaxFutures = {};
  final Map<String, Future<double?>> _volumeMaxFutures = {};
  final Map<String, Future<File?>> _mediaPreviewFutures = {};
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
    if (oldWidget.defId != widget.defId) {
      _repMaxFutures.clear();
      _volumeMaxFutures.clear();
      _mediaPreviewFutures.clear();
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

  /// Loads one cursor-based page of weight exercise history for this definition.
  Future<_ExerciseHistoryPage> _loadHistoryPage({HistoryRecord? before}) async {
    final historyRows = await _repo.fetchRecentWeightExerciseHistoryRows(
      definitionId: widget.defId,
      beforeSessionDate: before?.sessionDateValue,
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
      final sessionDateValue = row['session_date'] as String;
      records.add(
        HistoryRecord(
          date: DateTime.parse(sessionDateValue),
          sessionId: row['session_id'] as int,
          exerciseId: row['exercise_id'] as int,
          sessionDateValue: sessionDateValue,
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

    await navigator.push(
      MaterialPageRoute(builder: (_) => SessionDetailScreen(resolvedSession)),
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
    final colors = context.colors;
    final heatmapFrequencyMap = bodyPartFrequencyMapFromNames({
      for (final bodyPart in def.bodyParts) bodyPart.name: 1.0,
    });

    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<_LoadedExerciseMedia?>(
            future: _primaryMediaFuture,
            builder: (context, snapshot) {
              final loadedMedia = snapshot.data;
              if (loadedMedia == null) {
                return Center(
                  child: _buildHeatmapButton(
                    definition: def,
                    frequencyMap: heatmapFrequencyMap,
                    lowColor: colors.historySummaryHeatmapLow!,
                    highColor: colors.historySummaryHeatmapHigh!,
                    size: 220,
                    padding: 12,
                    borderRadius: BorderRadius.circular(18),
                  ),
                );
              }

              return _ExerciseMediaPreviewCard(
                previewFile: loadedMedia.previewFile,
                heatmapOverlay:
                    heatmapFrequencyMap.isEmpty
                        ? null
                        : _buildHeatmapButton(
                          definition: def,
                          frequencyMap: heatmapFrequencyMap,
                          lowColor: colors.historySummaryHeatmapLow!,
                          highColor: colors.historySummaryHeatmapHigh!,
                          size: 98,
                          padding: 6,
                          borderRadius: BorderRadius.circular(12),
                          elevated: true,
                        ),
                onImageTap:
                    () => _showImageViewer(
                      loadedMedia.previewFile,
                      definition: def,
                    ),
                onImageLoadFailed: _recoverFromMissingPreview,
              );
            },
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
    final equipment =
        definition.equipmentList.map((item) => item.name).toList();

    return _buildDetailCard(
      icon: Icons.fitness_center_outlined,
      title: strings.catalogEquipment,
      accent: theme.colorScheme.primary,
      isExpanded: _equipmentExpanded,
      onExpandedChanged:
          (expanded) => setState(() => _equipmentExpanded = expanded),
      child:
          equipment.isEmpty
              ? Text(
                strings.exerciseDetailNoEquipment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
              : Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    equipment
                        .map(
                          (item) => _buildDetailTag(
                            item,
                            color: theme.colorScheme.primary,
                          ),
                        )
                        .toList(),
              ),
    );
  }

  Widget _buildTargetAnatomyCard(
    ExerciseDefinition definition, {
    bool expandable = true,
  }) {
    final theme = Theme.of(context);
    final strings = _strings;
    final bodyParts =
        definition.bodyParts
            .map((item) => localizedBodyPartName(context, item.name))
            .toList();
    final muscles = definition.muscles.map((item) => item.muscle.name).toList();

    return _buildDetailCard(
      icon: Icons.accessibility_new,
      title: strings.exerciseDetailTargetAnatomy,
      accent: theme.colorScheme.tertiary,
      isExpanded: expandable ? _targetAnatomyExpanded : true,
      onExpandedChanged:
          expandable
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
              children:
                  bodyParts
                      .map(
                        (item) => _buildDetailTag(
                          item,
                          color: theme.colorScheme.tertiary,
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
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children:
                  muscles
                      .map(
                        (item) => _buildDetailTag(
                          item,
                          color: theme.colorScheme.secondary,
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFormGuideCard(
    ExerciseDefinition definition, {
    bool expandable = true,
  }) {
    final theme = Theme.of(context);
    final strings = _strings;
    final guideEntries = [
      (
        icon: Icons.self_improvement_outlined,
        title: strings.exerciseDetailSetup,
        body:
            definition.setupNotes.isNotEmpty
                ? definition.setupNotes
                : strings.exerciseDetailNoSetup,
      ),
      (
        icon: Icons.directions_run_outlined,
        title: strings.exerciseDetailExecution,
        body:
            definition.executionNotes.isNotEmpty
                ? definition.executionNotes
                : strings.exerciseDetailNoExecution,
      ),
      (
        icon: Icons.lightbulb_outline,
        title: strings.exerciseDetailTips,
        body:
            definition.tipsNotes.isNotEmpty
                ? definition.tipsNotes
                : strings.exerciseDetailNoTips,
      ),
    ];

    return _buildDetailCard(
      icon: Icons.menu_book_outlined,
      title: strings.exerciseDetailFormGuide,
      accent: theme.colorScheme.secondary,
      isExpanded: expandable ? _formGuideExpanded : true,
      onExpandedChanged:
          expandable
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
    required bool isExpanded,
    required ValueChanged<bool>? onExpandedChanged,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isExpandable = onExpandedChanged != null;
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.52,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.32)),
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
                onTap:
                    isExpandable ? () => onExpandedChanged(!isExpanded) : null,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accent, size: 19),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isExpandable)
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: accent,
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[const SizedBox(height: 13), child],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDetailTag(String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGuideEntry({
    required IconData icon,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  color: theme.colorScheme.onSurfaceVariant,
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
      label:
          hasHeatmap
              ? _strings.exerciseDetailOpenHeatmap
              : _strings.exerciseDetailNoHeatmap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            hasHeatmap
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: elevated ? 0.96 : 1,
            ),
            borderRadius: borderRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow:
                elevated
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child:
              hasHeatmap
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
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (dialogContext) => Material(
            color: Colors.black,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 64, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: InteractiveViewer(
                                minScale: 0.8,
                                maxScale: 4,
                                boundaryMargin: const EdgeInsets.all(48),
                                child: SizedBox.expand(
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              _strings.exerciseDetailZoomHint,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildFormGuideCard(definition, expandable: false),
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

  Future<void> _showHeatmapViewer({
    required ExerciseDefinition definition,
    required Map<String, double> frequencyMap,
    required Color lowColor,
    required Color highColor,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (dialogContext) => Material(
            color: Theme.of(dialogContext).colorScheme.surface,
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
                              color:
                                  Theme.of(
                                    dialogContext,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    Theme.of(
                                      dialogContext,
                                    ).colorScheme.outlineVariant,
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
    final safeSelectedIndex =
        selectedIndex < 0 ? _timeframes.length - 1 : selectedIndex;
    final timeframe = _timeframes[safeSelectedIndex];
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return FutureBuilder<List<RepMaxRow>>(
      future: _repMaxFuture(timeframe),
      builder: (context, snapshot) {
        return ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
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
    final labels = <String>[
      _strings.exerciseDetailWeek,
      _strings.exerciseDetailMonth,
      _strings.exerciseDetailAllTime,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.58,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
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
                  borderRadius: BorderRadius.circular(11),
                  onTap:
                      selected
                          ? null
                          : () => setState(() {
                            _tfSelected = List<bool>.generate(
                              labels.length,
                              (itemIndex) => itemIndex == index,
                            );
                          }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color:
                            selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
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
                : WeightUnitFormatter.formatVolume(volumeValue, weightUnit);

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
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricSummaryCard(
                    icon: Icons.workspace_premium_outlined,
                    label: _strings.exerciseDetailVolumeBest,
                    value: volumeLabel,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    _strings.exerciseDetailRanges(rows.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RepBestMetricsList(rows: rows, weightUnit: weightUnit),
          ],
        );
      },
    );
  }

  Widget _buildRecordsTab(ScrollController scrollCtrl) {
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
        final hasMoreHistory =
            _olderHistory.isEmpty
                ? firstPage?.hasMore ?? false
                : _hasMoreHistory;

        final records = _buildRecordTrendPoints(history);
        final hasSetRecordBadges = history.any(
          (record) =>
              record.badges.setBadges.values.any((badges) => badges.isNotEmpty),
        );

        return ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Text(
              _strings.exerciseDetailPerformanceTrend,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _ExerciseRecordTrendChart(points: records, weightUnit: weightUnit),
            const SizedBox(height: 10),
            Row(
              children: [
                _RecordLegendDot(
                  color: Theme.of(context).colorScheme.primary,
                  label: _strings.exerciseDetailBestWeight,
                ),
                const SizedBox(width: 16),
                _RecordLegendDot(
                  color: Colors.green.shade400,
                  label: _strings.exerciseDetailEstimatedOneRm,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (hasSetRecordBadges)
              const WorkoutRecordBadgeLegend(
                padding: EdgeInsets.only(bottom: 6),
              ),
            for (var index = 0; index < history.length; index++) ...[
              _ExerciseHistorySessionCard(
                record: history[index],
                weightUnit: weightUnit,
                onOpenSession:
                    () =>
                        _openHistorySession(context, history[index].sessionId),
              ),
              if (index < history.length - 1) const SizedBox(height: 10),
            ],
            if (hasMoreHistory) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoadingMoreHistory
                          ? null
                          : () => _loadMoreHistory(history),
                  icon:
                      _isLoadingMoreHistory
                          ? SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : const Icon(Icons.expand_more_rounded),
                  label: Text(
                    _isLoadingMoreHistory
                        ? _strings.exerciseDetailLoadingSessions
                        : _strings.exerciseDetailLoadMoreSessions,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
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

  Widget _buildSheetDragHandle(BuildContext context) {
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
          height: 28,
          width: double.infinity,
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      expand: false,
      minChildSize: _sheetMinSize,
      initialChildSize: _sheetInitialSize,
      maxChildSize: _sheetMaxSize,
      builder:
          (_, scrollCtrl) => DefaultTabController(
            length: 3,
            child: Material(
              elevation: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  _buildSheetDragHandle(context),
                  // Header with Close Icon
                  KeyedSubtree(
                    key: _headerTutorialKey,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.definition.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Bar
                  KeyedSubtree(
                    key: _tabsTutorialKey,
                    child: TabBar(
                      tabs: [
                        Tab(text: _strings.exerciseDetailTabDetails),
                        Tab(text: _strings.exerciseDetailTabMetrics),
                        Tab(text: _strings.exerciseDetailTabRecords),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Tab Views
                  Expanded(
                    child: KeyedSubtree(
                      key: _contentTutorialKey,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDetailsTab(scrollCtrl),
                          _buildMetricsTab(scrollCtrl),
                          _buildRecordsTab(scrollCtrl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    final strings = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMd().add_jm().format(record.date);
    final setCount = record.sets.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.36)),
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
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: scheme.primary,
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
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (record.badges.isFirstRecord) ...[
                const SizedBox(width: 8),
                const FirstRecordBadge(),
              ],
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: strings.exerciseDetailOpenWorkoutWithSets(setCount),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    onTap: onOpenSession,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.exerciseDetailSetCount(setCount),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.secondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: scheme.secondary,
                          ),
                        ],
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

  const _ExerciseHistorySetRow({
    required this.index,
    required this.set,
    required this.badges,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              index.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (badges.isEmpty)
            Expanded(
              child: Text(
                _formatSet(set, weightUnit),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            Expanded(
              flex: 2,
              child: Text(
                _formatSet(set, weightUnit),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
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
                        WorkoutRecordBadgeChip(badge: badges[badgeIndex]),
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
                ),
              ),
              maxLines: 1,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
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

  const _MetricSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
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

  const _RepBestMetricsList({required this.rows, required this.weightUnit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        children: List<Widget>.generate(rows.length, (index) {
          final row = rows[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            row.repCount.toString(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            AppLocalizations.of(context).exerciseDetailReps,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactRepMetricValue(
                        label:
                            AppLocalizations.of(
                              context,
                            ).exerciseDetailBestWeight,
                        value: WeightUnitFormatter.formatWeight(
                          row.rmValue,
                          weightUnit,
                        ),
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactRepMetricValue(
                        label:
                            AppLocalizations.of(
                              context,
                            ).exerciseDetailSetVolume,
                        value: WeightUnitFormatter.formatVolume(
                          row.rmValue * row.repCount,
                          weightUnit,
                        ),
                        color: scheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < rows.length - 1)
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.58),
                ),
            ],
          );
        }),
      ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.44,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
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
                color: theme.colorScheme.primary,
              ),
            )
          else
            Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 13),
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
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
  final DateTime date;
  final double bestWeight;
  final double bestEstimatedOneRm;
  final ExerciseSet bestSet;

  const _ExerciseRecordPoint({
    required this.date,
    required this.bestWeight,
    required this.bestEstimatedOneRm,
    required this.bestSet,
  });

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
      date: record.date,
      bestWeight: bestWeight,
      bestEstimatedOneRm: bestEstimatedOneRm,
      bestSet: bestSet,
    );
  }
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
    final strings = AppLocalizations.of(context);

    if (points.isEmpty) {
      return Container(
        height: 188,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          AppLocalizations.of(context).exerciseDetailNoChartData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final bounds = _recordChartBounds(points);
    final labelIndexes = _recordDateLabelIndexes(points.length);
    final showTimes = _shouldUseTimeLabels(points);
    final actualColor = scheme.primary;
    final estimatedColor = Colors.green.shade400;
    final hasBestWeight = points.any((point) => point.bestWeight > 0);
    final hasEstimatedOneRm = points.any(
      (point) => point.bestEstimatedOneRm > 0,
    );

    return Container(
      height: 214,
      padding: const EdgeInsets.fromLTRB(8, 14, 10, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, points.length - 1).toDouble(),
          minY: bounds.minY,
          maxY: bounds.maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              tooltipMargin: 8,
              maxContentWidth: 164,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor:
                  (_) => scheme.surfaceContainerHighest.withValues(alpha: 0.96),
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return const <LineTooltipItem?>[];
                final spot = touchedSpots.first;
                final index =
                    spot.x.round().clamp(0, points.length - 1).toInt();
                final point = points[index];
                final textStyle =
                    theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ) ??
                    TextStyle(
                      color: scheme.onSurface,
                      fontSize: 9,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    );
                return [
                  LineTooltipItem(
                    '${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_jm().format(point.date)}\n'
                    '${strings.exerciseDetailWeightAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestWeight, weightUnit)} | '
                    '${strings.exerciseDetailEstimatedAbbreviation} ${WeightUnitFormatter.formatWeight(point.bestEstimatedOneRm, weightUnit)} | '
                    '${strings.exerciseDetailTopAbbreviation} ${_formatSet(point.bestSet, weightUnit)}',
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
            getDrawingHorizontalLine:
                (_) => FlLine(
                  color: scheme.outlineVariant.withValues(alpha: 0.42),
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
                      _compactWeight(value, weightUnit),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                        points[index].date,
                        showTimes,
                        Localizations.localeOf(context),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                color: actualColor.withValues(alpha: 0.08),
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
        duration: const Duration(milliseconds: 160),
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
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
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
  final values =
      [
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
  final days = {
    for (final point in points)
      DateUtils.dateOnly(point.date).toIso8601String(),
  };
  return days.length == 1;
}

String _recordAxisLabel(DateTime date, bool showTime, Locale locale) {
  return preserveWesternDigits(
    showTime
        ? DateFormat('h:mm a', locale.toLanguageTag()).format(date)
        : DateFormat.MMMd(locale.toLanguageTag()).format(date),
    locale,
  );
}

double _estimatedOneRm(ExerciseSet set) {
  if (set.reps <= 1) return set.weight;
  return set.weight * (1 + 0.0333 * set.reps);
}

String _formatSet(ExerciseSet set, WeightUnit weightUnit) {
  return '${WeightUnitFormatter.formatWeight(set.weight, weightUnit)} x ${set.reps}';
}

String _compactWeight(double value, WeightUnit weightUnit) {
  final displayValue = WeightUnitFormatter.fromPounds(value, weightUnit);
  if (displayValue.abs() >= 1000) {
    return '${(displayValue / 1000).toStringAsFixed(displayValue.abs() >= 10000 ? 0 : 1)}k';
  }
  return _cleanNumber(displayValue);
}

String _cleanNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
