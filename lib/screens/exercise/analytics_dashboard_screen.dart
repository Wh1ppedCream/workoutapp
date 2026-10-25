// File: lib/screens/exercise/analytics_dashboard_screen.dart
// Weekly muscle/bodypart set-unit overview.

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/unit_preference_provider.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/tutorial_state_store.dart';
import '../../services/safe_failure.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/completed_workout_duration_formatter.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/tutorial_launcher.dart';
import '../../utils/weight_unit_formatter.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/safe_error_view.dart';
import 'definitions_by_bodypart_page.dart';
import 'definitions_by_muscle_page.dart';

/// Displays the current seven-day training distribution by bodypart and muscle.
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  AppRepository get _repo => context.read<AppRepository>();
  final _headerTutorialKey = GlobalKey(debugLabel: 'weekly_sets_header');
  final _tabsTutorialKey = GlobalKey(debugLabel: 'weekly_sets_tabs');
  final _listTutorialKey = GlobalKey(debugLabel: 'weekly_sets_list');

  bool _isLoading = true;
  SafeFailure? _failure;
  _WeeklySetOverviewData? _data;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _failure = null;
    });

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final sessionsFuture = _repo.fetchWorkoutReportSessions(
        start: weekAgo,
        end: now,
      );
      final muscleMapFuture = _repo.fetchSetsPerMuscle(
        start: weekAgo,
        end: now,
      );
      final bodyMapFuture = _repo.fetchAllBodyPartSetsOverTimeRange(
        start: weekAgo,
        end: now,
      );
      final musclesFuture = _repo.fetchAllMusclesFull();
      final muscleBoundsFuture = _repo.fetchAllMuscleVolumeBounds();
      final bodyPartBoundsFuture = _repo.fetchAllBodyPartVolumeBounds();

      final sessions = await sessionsFuture;
      final muscleMap = await muscleMapFuture;
      final bodyMap = await bodyMapFuture;
      final muscles = await musclesFuture;
      final muscleBoundsRows = await muscleBoundsFuture;
      final bodyPartBoundsRows = await bodyPartBoundsFuture;

      final muscleById = {for (final muscle in muscles) muscle.id: muscle};
      final muscleBounds = _boundsById(muscleBoundsRows);
      final bodyPartBounds = _boundsById(bodyPartBoundsRows);

      final bodyPartCounts =
          bodyMap.entries
              .where((entry) => entry.value > 0)
              .map(
                (entry) => _BodyPartSetCount(
                  bodyPart: entry.key,
                  count: entry.value,
                  bounds: bodyPartBounds[entry.key.id],
                ),
              )
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));

      final muscleCounts =
          muscleMap.entries
              .where(
                (entry) => entry.value > 0 && muscleById[entry.key] != null,
              )
              .map(
                (entry) => _MuscleSetCount(
                  muscle: muscleById[entry.key]!,
                  count: entry.value,
                  bounds: muscleBounds[entry.key],
                ),
              )
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));

      final nextData = _WeeklySetOverviewData(
        totalSets: sessions.fold<int>(
          0,
          (sum, session) => sum + session.setCount,
        ),
        totalDurationSeconds: sessions.fold<int>(
          0,
          (sum, session) => sum + session.durationSeconds,
        ),
        totalVolume: sessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        ),
        heatmapFrequencyMap: bodyPartFrequencyMapFromNames({
          for (final item in bodyPartCounts) item.bodyPart.name: item.count,
        }),
        bodyParts: bodyPartCounts,
        muscles: muscleCounts,
      );

      if (!mounted) return;
      setState(() {
        _data = nextData;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueTutorial();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = SafeFailure.classify(e);
        _isLoading = false;
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
      final strings = AppLocalizations.of(context);
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.weeklySetsOverview,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.accessibility_new,
            title: strings.weeklySetsTutorialOverviewTitle,
            body: strings.weeklySetsTutorialOverviewBody,
          ),
          GuidedTutorialStep(
            targetKey: _tabsTutorialKey,
            icon: Icons.swap_horiz,
            title: strings.weeklySetsTutorialAnatomyTitle,
            body: strings.weeklySetsTutorialAnatomyBody,
          ),
          GuidedTutorialStep(
            targetKey: _listTutorialKey,
            icon: Icons.check_circle_outline,
            title: strings.weeklySetsTutorialStatusTitle,
            body: strings.weeklySetsTutorialStatusBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  Map<int, VolumeBoundaries> _boundsById(List<Map<String, dynamic>> rows) {
    final boundsById = <int, VolumeBoundaries>{};
    for (final row in rows) {
      final bounds = VolumeBoundaries.fromMap(row);
      boundsById[bounds.id] = bounds;
    }
    return boundsById;
  }

  void _openBodyPart(BodyPart bodyPart) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DefinitionsByBodyPartPage(
          bodyPart: bodyPart,
          expressiveAnalyticsPresentation: true,
        ),
      ),
    );
  }

  void _openMuscle(Muscle muscle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DefinitionsByMusclePage(
          muscle: muscle,
          expressiveAnalyticsPresentation: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.analytics,
      child: Builder(builder: _buildScreen),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final data = _data;
    final strings = AppLocalizations.of(context);
    final expressive = Theme.of(context).usesExpressivePresentation;
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    return Scaffold(
      backgroundColor: destinationTokens?.pageCanvas,
      appBar: AppBar(
        title: Text(strings.weeklySetsTitle),
        backgroundColor: expressive
            ? destinationTokens?.pageCanvas
            : destinationTokens?.surfacePrimary,
        foregroundColor: expressive
            ? destinationTokens?.supportingForeground
            : destinationTokens?.onSurfacePrimary,
        titleTextStyle: expressive
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                color: destinationTokens?.supportingForeground,
                fontWeight: FontWeight.w800,
              )
            : null,
        toolbarHeight: expressive ? 56 : null,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : _failure != null && data == null
          ? SafeErrorView(
              title: strings.weeklySetsLoadError,
              failure: _failure!,
              onRetry: _loadData,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final compactLandscape =
                    constraints.maxWidth > constraints.maxHeight &&
                    constraints.maxHeight < 380;
                return Column(
                  children: [
                    KeyedSubtree(
                      key: _headerTutorialKey,
                      child: _WeeklyOverviewHeader(
                        data: data ?? _emptyWeeklyData,
                        compactLandscape: compactLandscape,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: KeyedSubtree(
                        key: _tabsTutorialKey,
                        child: expressive
                            ? Row(
                                children: [
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _tabController,
                                      builder: (context, _) => SegmentedButton<int>(
                                        segments: [
                                          ButtonSegment<int>(
                                            value: 0,
                                            label: Text(
                                              strings.weeklySetsBodyParts,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ButtonSegment<int>(
                                            value: 1,
                                            label: Text(
                                              strings.weeklySetsMuscles,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                        selected: {_tabController.index},
                                        showSelectedIcon: false,
                                        style: ButtonStyle(
                                          shape: WidgetStateProperty.all(
                                            const StadiumBorder(),
                                          ),
                                          foregroundColor:
                                              WidgetStateProperty.resolveWith((
                                                states,
                                              ) {
                                                if (states.contains(
                                                  WidgetState.selected,
                                                )) {
                                                  return destinationTokens
                                                      ?.onActionPrimary;
                                                }
                                                return destinationTokens
                                                    ?.supportingForeground;
                                              }),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith((
                                                states,
                                              ) {
                                                if (states.contains(
                                                  WidgetState.selected,
                                                )) {
                                                  return destinationTokens
                                                      ?.actionPrimary;
                                                }
                                                return Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Color.alphaBlend(
                                                        destinationTokens!
                                                            .surfaceSelected
                                                            .withValues(
                                                              alpha: 0.45,
                                                            ),
                                                        destinationTokens
                                                            .pageCanvas,
                                                      )
                                                    : Colors.transparent;
                                              }),
                                          side: WidgetStateProperty.all(
                                            BorderSide(
                                              color: destinationTokens!
                                                  .outlineAccent
                                                  .withValues(alpha: 0.45),
                                            ),
                                          ),
                                        ),
                                        onSelectionChanged: (selection) =>
                                            _tabController.animateTo(
                                              selection.single,
                                            ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: strings.allocationHowTitle,
                                    color:
                                        destinationTokens?.supportingForeground,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 48,
                                      height: 48,
                                    ),
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () => showTonosDialog<void>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: Text(strings.allocationHowTitle),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            strings.weeklySetsExplanationBody,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(),
                                            child: Text(strings.commonClose),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : TabBar(
                                controller: _tabController,
                                labelColor: destinationTokens?.actionPrimary,
                                unselectedLabelColor:
                                    destinationTokens?.supportingForeground,
                                indicatorColor:
                                    destinationTokens?.outlineAccent,
                                tabs: [
                                  Tab(text: strings.weeklySetsBodyParts),
                                  Tab(text: strings.weeklySetsMuscles),
                                ],
                              ),
                      ),
                    ),
                    Expanded(
                      child: KeyedSubtree(
                        key: _listTutorialKey,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _BodyPartSetList(
                              items: data?.bodyParts ?? const [],
                              onTap: _openBodyPart,
                            ),
                            _MuscleSetList(
                              items: data?.muscles ?? const [],
                              onTap: _openMuscle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _WeeklyOverviewHeader extends StatelessWidget {
  final _WeeklySetOverviewData data;
  final bool compactLandscape;

  const _WeeklyOverviewHeader({
    required this.data,
    this.compactLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final theme = Theme.of(context);
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final expressive = theme.usesExpressivePresentation;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, expressive ? 8 : 12, 16, 10),
      child: Card(
        color: expressive ? destinationTokens?.surfacePrimary : surfaces.card,
        shape: expressive
            ? RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(12),
                ),
                side: BorderSide(
                  color: destinationTokens!.outlineAccent.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.32 : 0.46,
                  ),
                  width: 1,
                ),
              )
            : null,
        child: Padding(
          padding: expressive
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 11)
              : const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final viewportWidth = MediaQuery.sizeOf(context).width;
              final stacked = expressive
                  ? textScale > 1.3 &&
                        constraints.maxWidth < 600 &&
                        !compactLandscape
                  : viewportWidth < 360 ||
                        (textScale > 1.3 && viewportWidth < 640);
              final heatmapSurface = expressive
                  ? destinationTokens?.surfaceSelected ?? surfaces.card
                  : surfaces.card;
              final heatmapBox = expressive
                  ? compactLandscape
                        ? 96.0
                        : stacked
                        ? (constraints.maxWidth * 0.58)
                              .clamp(128.0, 192.0)
                              .toDouble()
                        : (constraints.maxWidth - 12) * 0.55
                  : compactLandscape
                  ? 140.0
                  : stacked
                  ? (constraints.maxWidth * 0.54).clamp(128.0, 184.0).toDouble()
                  : (constraints.maxWidth * 0.48)
                        .clamp(128.0, 184.0)
                        .toDouble();
              final heatmapSize = expressive
                  ? heatmapBox - 12
                  : (heatmapBox - 6).clamp(120.0, 176.0).toDouble();

              final heatmapLowColor = expressive
                  ? theme.colorScheme.onSurfaceVariant
                  : tonosHeatmapLowForSurface(context, heatmapSurface);

              final heatmapContent = Center(
                child: BodyHeatmap(
                  frequencyMap: data.heatmapFrequencyMap,
                  lowColor: heatmapLowColor,
                  highColor: tonosHeatmapHighForSurface(
                    context,
                    heatmapSurface,
                  ),
                  width: heatmapSize,
                  height: heatmapSize,
                ),
              );
              final heatmapFrame = expressive
                  ? Container(
                      width: heatmapBox,
                      height: stacked || compactLandscape ? heatmapBox : null,
                      decoration: BoxDecoration(
                        color: heatmapSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: destinationTokens!.outlineAccent.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.24
                                : 0.34,
                          ),
                        ),
                      ),
                      child: heatmapContent,
                    )
                  : SizedBox(
                      width: heatmapBox,
                      height: heatmapBox,
                      child: heatmapContent,
                    );
              final heatmap = heatmapFrame;
              final statBoxes = [
                _SummaryStatBox(
                  label: AppLocalizations.of(context).weeklySetsTotal,
                  value: LocalizedFormatters.number(
                    data.totalSets,
                    Localizations.localeOf(context),
                    maximumFractionDigits: 0,
                  ),
                  fill: destinationTokens?.surfaceSecondary,
                  foreground: destinationTokens?.onSurfaceSecondary,
                  compact: expressive,
                  inline: expressive && (compactLandscape || stacked),
                ),
                _SummaryStatBox(
                  label: AppLocalizations.of(context).weeklySetsTime,
                  value: _durationLabel(
                    AppLocalizations.of(context),
                    data.totalDurationSeconds,
                  ),
                  fill: destinationTokens?.surfaceTertiary,
                  foreground: destinationTokens?.onSurfaceTertiary,
                  compact: expressive,
                  inline: expressive && (compactLandscape || stacked),
                ),
                _SummaryStatBox(
                  label: AppLocalizations.of(context).weeklySetsVolume,
                  value: WeightUnitFormatter.formatVolume(
                    data.totalVolume,
                    weightUnit,
                    locale: Localizations.localeOf(context),
                  ),
                  fill: destinationTokens?.surfaceAccent,
                  foreground: destinationTokens?.onSurfaceAccent,
                  compact: expressive,
                  inline: expressive && (compactLandscape || stacked),
                ),
              ];
              final stats = expressive && !compactLandscape
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0; index < statBoxes.length; index++)
                          if (index == 0)
                            statBoxes[index]
                          else ...[
                            const SizedBox(height: 6),
                            statBoxes[index],
                          ],
                      ],
                    )
                  : compactLandscape
                  ? Row(
                      children: [
                        for (var index = 0; index < statBoxes.length; index++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == statBoxes.length - 1 ? 0 : 8,
                              ),
                              child: statBoxes[index],
                            ),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0; index < statBoxes.length; index++)
                          if (index == 0)
                            statBoxes[index]
                          else ...[
                            const SizedBox(height: 8),
                            statBoxes[index],
                          ],
                      ],
                    );

              if (expressive) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (stacked)
                      Column(
                        children: [
                          Center(child: heatmap),
                          const SizedBox(height: 8),
                          stats,
                        ],
                      )
                    else
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            heatmap,
                            const SizedBox(width: 12),
                            Expanded(child: stats),
                          ],
                        ),
                      ),
                  ],
                );
              }

              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: heatmap),
                        const SizedBox(height: 12),
                        stats,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        heatmap,
                        const SizedBox(width: 14),
                        Expanded(child: stats),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? fill;
  final Color? foreground;
  final bool compact;
  final bool inline;

  const _SummaryStatBox({
    required this.label,
    required this.value,
    this.fill,
    this.foreground,
    this.compact = false,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: compact ? BoxConstraints(minHeight: inline ? 48 : 68) : null,
      alignment: compact ? AlignmentDirectional.centerStart : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? (inline ? 6 : 8) : 10,
      ),
      decoration: BoxDecoration(
        color:
            fill ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: theme.shapeTokens.dashboardRow,
      ),
      child: inline
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground ?? theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  textAlign: compact ? TextAlign.start : null,
                  style:
                      (compact
                              ? theme.textTheme.labelMedium
                              : theme.textTheme.labelSmall)
                          ?.copyWith(
                            color:
                                foreground ??
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: compact ? TextAlign.start : null,
                  maxLines: compact ? null : 2,
                  style:
                      (compact
                              ? theme.textTheme.titleLarge
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                            color: foreground,
                            fontSize: compact
                                ? (theme.textTheme.titleLarge?.fontSize ?? 22) *
                                      0.9
                                : null,
                            fontWeight: FontWeight.w900,
                          ),
                ),
              ],
            ),
    );
  }
}

class _BodyPartSetList extends StatelessWidget {
  final List<_BodyPartSetCount> items;
  final ValueChanged<BodyPart> onTap;

  const _BodyPartSetList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).weeklySetsNoBodyParts),
      );
    }

    final theme = Theme.of(context);
    final expressive = theme.usesExpressivePresentation;
    final lightTokens = expressive && theme.brightness == Brightness.light
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, expressive ? 8 : 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: expressive ? 6 : 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SetOverviewRow(
          title: localizedBodyPartName(context, item.bodyPart.name),
          count: item.count,
          bounds: item.bounds,
          leading: SingleBodyPartHeatmap(
            bodyPartName: item.bodyPart.name,
            size: expressive ? 53 : 52,
            backgroundColor: lightTokens?.surfaceSelected,
            lowColor: lightTokens?.onSurfaceSelected.withValues(alpha: 0.6),
          ),
          onTap: () => onTap(item.bodyPart),
        );
      },
    );
  }
}

class _MuscleSetList extends StatelessWidget {
  final List<_MuscleSetCount> items;
  final ValueChanged<Muscle> onTap;

  const _MuscleSetList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).weeklySetsNoMuscles),
      );
    }

    final expressive = Theme.of(context).usesExpressivePresentation;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, expressive ? 8 : 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: expressive ? 6 : 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SetOverviewRow(
          title: item.muscle.name,
          entity: CatalogEntityDisplayName(
            catalogId: item.muscle.catalogId,
            canonicalName: item.muscle.name,
          ),
          count: item.count,
          bounds: item.bounds,
          leading: _MuscleLeadingIcon(size: expressive ? 48 : 52),
          onTap: () => onTap(item.muscle),
        );
      },
    );
  }
}

class _SetOverviewRow extends StatelessWidget {
  final String title;
  final CatalogEntityDisplayName? entity;
  final double count;
  final VolumeBoundaries? bounds;
  final Widget leading;
  final VoidCallback onTap;

  const _SetOverviewRow({
    required this.title,
    this.entity,
    required this.count,
    required this.bounds,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expressive = theme.usesExpressivePresentation;
    final status = _boundaryStatus(count, bounds);
    final originalTint = _tintForBoundaryStatus(theme, status);
    final lightNeutral =
        expressive &&
        theme.brightness == Brightness.light &&
        (status == _BoundaryStatus.under || status == _BoundaryStatus.unset);
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    final tint = !expressive
        ? originalTint
        : _StatusTint(
            background: lightNeutral
                ? Color.alphaBlend(
                    destinationTokens!.surfaceTertiary.withValues(alpha: 0.45),
                    destinationTokens.pageCanvas,
                  )
                : originalTint.background.withValues(
                    alpha: status == _BoundaryStatus.within
                        ? (theme.brightness == Brightness.dark ? 0.34 : 0.18)
                        : status == _BoundaryStatus.under ||
                              status == _BoundaryStatus.unset
                        ? (theme.brightness == Brightness.dark ? 0.1 : 0.2)
                        : 0.07,
                  ),
            border: originalTint.border.withValues(
              alpha: status == _BoundaryStatus.within
                  ? (theme.brightness == Brightness.dark ? 0.82 : 0.64)
                  : (theme.brightness == Brightness.dark ? 0.2 : 0.3),
            ),
          );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: theme.shapeTokens.weeklySetRow,
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: expressive ? 10 : 12,
            vertical: expressive ? 7 : 11,
          ),
          decoration: BoxDecoration(
            color: tint.background,
            borderRadius: theme.shapeTokens.weeklySetRow,
            border: Border.all(
              color: tint.border,
              width: expressive ? 1 : theme.shapeTokens.outlineWidth,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 320 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              final titleMaxLines = compact ? null : 2;
              final titleOverflow = compact ? null : TextOverflow.ellipsis;
              final titleStyle =
                  (expressive
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.titleMedium)
                      ?.copyWith(
                        fontWeight: expressive
                            ? FontWeight.w700
                            : FontWeight.w800,
                      );
              final titleWidget = entity == null
                  ? Text(
                      title,
                      maxLines: titleMaxLines,
                      overflow: titleOverflow,
                      style: titleStyle,
                    )
                  : LocalizedCatalogEntityName(
                      entity: entity!,
                      maxLines: titleMaxLines,
                      overflow: titleOverflow,
                      style: titleStyle,
                    );
              final countLabel = Text(
                _setUnitsLabel(
                  AppLocalizations.of(context),
                  count,
                  Localizations.localeOf(context),
                ),
                style:
                    (expressive
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          fontWeight: expressive
                              ? FontWeight.w700
                              : FontWeight.w900,
                        ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        leading,
                        const SizedBox(width: 12),
                        Expanded(child: titleWidget),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: countLabel),
                  ],
                );
              }
              return Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(child: titleWidget),
                  const SizedBox(width: 12),
                  countLabel,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MuscleLeadingIcon extends StatelessWidget {
  final double size;

  const _MuscleLeadingIcon({this.size = 52});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lightTokens =
        theme.usesExpressivePresentation && theme.brightness == Brightness.light
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    // Keep primary-colored icons except when a light palette makes the
    // primary foreground identical to its container fill.
    final iconColor =
        lightTokens?.onSurfaceSelected ??
        (theme.brightness == Brightness.light &&
                scheme.primary == scheme.primaryContainer
            ? scheme.onPrimaryContainer
            : scheme.primary);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            lightTokens?.surfaceSelected ??
            scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: theme.shapeTokens.dashboardRow,
      ),
      child: Icon(
        Icons.fitness_center,
        color: iconColor,
        size: theme.usesExpressivePresentation ? 28 : null,
      ),
    );
  }
}

enum _BoundaryStatus { under, within, over, unset }

class _StatusTint {
  final Color background;
  final Color border;

  const _StatusTint({required this.background, required this.border});
}

_BoundaryStatus _boundaryStatus(double count, VolumeBoundaries? bounds) {
  if (bounds == null) return _BoundaryStatus.unset;
  if (count > bounds.maxRecoverable) return _BoundaryStatus.over;
  if (count >= bounds.minEffective) return _BoundaryStatus.within;
  return _BoundaryStatus.under;
}

_StatusTint _tintForBoundaryStatus(ThemeData theme, _BoundaryStatus status) {
  final colorScheme = theme.colorScheme;
  final base = switch (status) {
    _BoundaryStatus.within => theme.dataVisualizationTokens.positive,
    _BoundaryStatus.over => colorScheme.error,
    _BoundaryStatus.under => colorScheme.surfaceContainerHighest,
    _BoundaryStatus.unset => colorScheme.surfaceContainerHighest,
  };

  return _StatusTint(
    background: base.withValues(
      alpha: status == _BoundaryStatus.unset ? 0.45 : 0.13,
    ),
    border: base.withValues(
      alpha: status == _BoundaryStatus.unset ? 0.7 : 0.35,
    ),
  );
}

String _setUnitsLabel(AppLocalizations strings, double count, Locale locale) {
  final rounded = count.roundToDouble();
  final fractionDigits = (count - rounded).abs() < 0.05 ? 0 : 1;
  final value = LocalizedFormatters.number(
    count,
    locale,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  );
  return rounded == 1
      ? strings.weeklySetsSingleCount(value)
      : strings.weeklySetsCount(value);
}

String _durationLabel(AppLocalizations strings, int seconds) {
  return formatCompletedWorkoutDuration(strings, seconds);
}

const _emptyWeeklyData = _WeeklySetOverviewData(
  totalSets: 0,
  totalDurationSeconds: 0,
  totalVolume: 0,
  heatmapFrequencyMap: {},
  bodyParts: [],
  muscles: [],
);

class _WeeklySetOverviewData {
  final int totalSets;
  final int totalDurationSeconds;
  final double totalVolume;
  final Map<String, double> heatmapFrequencyMap;
  final List<_BodyPartSetCount> bodyParts;
  final List<_MuscleSetCount> muscles;

  const _WeeklySetOverviewData({
    required this.totalSets,
    required this.totalDurationSeconds,
    required this.totalVolume,
    required this.heatmapFrequencyMap,
    required this.bodyParts,
    required this.muscles,
  });
}

class _BodyPartSetCount {
  final BodyPart bodyPart;
  final double count;
  final VolumeBoundaries? bounds;

  const _BodyPartSetCount({
    required this.bodyPart,
    required this.count,
    required this.bounds,
  });
}

class _MuscleSetCount {
  final Muscle muscle;
  final double count;
  final VolumeBoundaries? bounds;

  const _MuscleSetCount({
    required this.muscle,
    required this.count,
    required this.bounds,
  });
}
