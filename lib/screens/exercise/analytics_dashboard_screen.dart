// File: lib/screens/exercise/analytics_dashboard_screen.dart
// Weekly muscle/bodypart set-unit overview.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/unit_preference_provider.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/theme_extensions.dart';
import '../../utils/tutorial_launcher.dart';
import '../../utils/weight_unit_formatter.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/guided_tutorial_overlay.dart';
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
  String? _error;
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
      _error = null;
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
        _error = e.toString();
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
        builder: (_) => DefinitionsByBodyPartPage(bodyPart: bodyPart),
      ),
    );
  }

  void _openMuscle(Muscle muscle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DefinitionsByMusclePage(muscle: muscle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.weeklySetsTitle)),
      body:
          _isLoading && data == null
              ? const Center(child: CircularProgressIndicator())
              : _error != null && data == null
              ? Center(child: Text(strings.weeklySetsLoadError))
              : Column(
                children: [
                  KeyedSubtree(
                    key: _headerTutorialKey,
                    child: _WeeklyOverviewHeader(
                      data: data ?? _emptyWeeklyData,
                    ),
                  ),
                  KeyedSubtree(
                    key: _tabsTutorialKey,
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: strings.weeklySetsBodyParts),
                        Tab(text: strings.weeklySetsMuscles),
                      ],
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
              ),
    );
  }
}

class _WeeklyOverviewHeader extends StatelessWidget {
  final _WeeklySetOverviewData data;

  const _WeeklyOverviewHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final heatmapBox =
                  (constraints.maxWidth * 0.48).clamp(128.0, 184.0).toDouble();
              final heatmapSize =
                  (heatmapBox - 6).clamp(120.0, 176.0).toDouble();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: heatmapBox,
                    height: heatmapBox,
                    child: Center(
                      child: BodyHeatmap(
                        frequencyMap: data.heatmapFrequencyMap,
                        lowColor: colors.historySummaryHeatmapLow!,
                        highColor: colors.historySummaryHeatmapHigh!,
                        width: heatmapSize,
                        height: heatmapSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryStatBox(
                          label: AppLocalizations.of(context).weeklySetsTotal,
                          value: data.totalSets.toString(),
                        ),
                        const SizedBox(height: 8),
                        _SummaryStatBox(
                          label: AppLocalizations.of(context).weeklySetsTime,
                          value: _durationLabel(
                            AppLocalizations.of(context),
                            data.totalDurationSeconds,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SummaryStatBox(
                          label: AppLocalizations.of(context).weeklySetsVolume,
                          value: WeightUnitFormatter.formatVolume(
                            data.totalVolume,
                            weightUnit,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  const _SummaryStatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SetOverviewRow(
          title: item.bodyPart.name,
          count: item.count,
          bounds: item.bounds,
          leading: SingleBodyPartHeatmap(
            bodyPartName: item.bodyPart.name,
            size: 52,
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _SetOverviewRow(
          title: item.muscle.name,
          count: item.count,
          bounds: item.bounds,
          leading: const _MuscleLeadingIcon(),
          onTap: () => onTap(item.muscle),
        );
      },
    );
  }
}

class _SetOverviewRow extends StatelessWidget {
  final String title;
  final double count;
  final VolumeBoundaries? bounds;
  final Widget leading;
  final VoidCallback onTap;

  const _SetOverviewRow({
    required this.title,
    required this.count,
    required this.bounds,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = _tintForBoundaryStatus(theme, _boundaryStatus(count, bounds));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: tint.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tint.border),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _setUnitsLabel(AppLocalizations.of(context), count),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleLeadingIcon extends StatelessWidget {
  const _MuscleLeadingIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.fitness_center, color: theme.colorScheme.primary),
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
    _BoundaryStatus.within => Colors.green,
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

String _setUnitsLabel(AppLocalizations strings, double count) {
  final rounded = count.roundToDouble();
  final value =
      (count - rounded).abs() < 0.05
          ? rounded.toInt().toString()
          : count.toStringAsFixed(1);
  return strings.weeklySetsCount(value);
}

String _durationLabel(AppLocalizations strings, int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0 && minutes > 0) {
    return strings.durationHoursMinutes(hours, minutes);
  }
  if (hours > 0) return strings.durationHours(hours);
  return strings.durationMinutes(duration.inMinutes);
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
