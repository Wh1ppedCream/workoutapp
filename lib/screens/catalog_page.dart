import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/active_session.dart';
import '../repositories/app_repository.dart';
import '../services/tutorial_state_store.dart';
import '../widgets/body_heatmap.dart';
import '../widgets/exercise_media_thumbnail.dart';
import '../widgets/guided_tutorial_overlay.dart';
import 'exercise/exercise_catalog_page.dart';
import 'exercise/muscle_filter_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _exerciseCatalogTutorialKey = GlobalKey(
    debugLabel: 'catalog_exercise_catalog_tutorial',
  );
  final _targetAnatomyTutorialKey = GlobalKey(
    debugLabel: 'catalog_target_anatomy_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  late Future<_CatalogOverviewData> _overviewFuture;
  _CatalogOverviewData? _lastOverview;
  int? _seenCompletedSessionVersion;
  bool _catalogTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    unawaited(BodyHeatmap.preload());
    _overviewFuture = _loadOverview();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActiveTab = TickerMode.of(context);
    final completedSessionVersion =
        Provider.of<ActiveSession>(context).completedSessionVersion;

    if (_seenCompletedSessionVersion == null) {
      _seenCompletedSessionVersion = completedSessionVersion;
    } else if (_seenCompletedSessionVersion != completedSessionVersion) {
      _seenCompletedSessionVersion = completedSessionVersion;
      _overviewFuture = _loadOverview();
    }
    if (isActiveTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueCatalogTutorial();
      });
    }
  }

  Future<void> _refreshOverview() async {
    final next = _loadOverview();
    setState(() => _overviewFuture = next);
    await next;
  }

  Future<_CatalogOverviewData> _loadOverview() async {
    final repo = context.read<AppRepository>();
    final now = DateTime.now();
    final start = DateTime.fromMillisecondsSinceEpoch(0);

    final exerciseRowsFuture = repo.fetchMostUsedExerciseDefinitionsRaw(
      limit: 4,
    );
    final bodyPartSetsFuture = repo.fetchAllBodyPartSetsOverTimeRange(
      start: start,
      end: now,
    );
    final muscleSetsFuture = repo.fetchSetsPerMuscle(start: start, end: now);
    final musclesFuture = repo.fetchAllMusclesFull();

    final exerciseRows = await exerciseRowsFuture;
    final definitionIds =
        exerciseRows
            .map((row) => (row['definition_id'] as num?)?.toInt())
            .whereType<int>()
            .toList();
    final definitions = await repo.lookupDefsDetailedByIds(definitionIds);
    final definitionsById = {for (final def in definitions) def.id: def};
    final exerciseStats = <_ExerciseUsageSummary>[
      for (final row in exerciseRows)
        if (definitionsById[(row['definition_id'] as num?)?.toInt()] != null)
          _ExerciseUsageSummary(
            definition: definitionsById[(row['definition_id'] as num).toInt()]!,
            useCount: ((row['use_count'] as num?) ?? 0).toInt(),
          ),
    ];

    final bodyPartSets = await bodyPartSetsFuture;
    final muscleSets = await muscleSetsFuture;
    final muscles = await musclesFuture;
    final muscleById = {for (final muscle in muscles) muscle.id: muscle};

    final bodyPartStats =
        bodyPartSets.entries
            .where((entry) => entry.value > 0)
            .map((entry) => _FocusUsageSummary(entry.key.name, entry.value))
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));
    final muscleStats =
        muscleSets.entries
            .where((entry) => entry.value > 0 && muscleById[entry.key] != null)
            .map(
              (entry) =>
                  _FocusUsageSummary(muscleById[entry.key]!.name, entry.value),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _CatalogOverviewData(
      exercises: exerciseStats,
      bodyParts: bodyPartStats.take(5).toList(),
      muscles: muscleStats.take(5).toList(),
    );
  }

  void _openExerciseCatalog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ExerciseCatalogPage()));
  }

  void _openFocusLibrary(int initialTabIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MuscleFilterPage(initialTabIndex: initialTabIndex),
      ),
    );
  }

  void _queueCatalogTutorial() {
    if (!mounted || _catalogTutorialQueued || !TickerMode.of(context)) return;
    if (_exerciseCatalogTutorialKey.currentContext == null ||
        _targetAnatomyTutorialKey.currentContext == null) {
      return;
    }
    _catalogTutorialQueued = true;
    unawaited(_showCatalogTutorialIfNeeded());
  }

  Future<void> _showCatalogTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted || !TickerMode.of(context)) return;

      final completed = await _tutorialStore.isCompleted(
        TutorialIds.catalogHome,
      );
      if (completed || !mounted) return;
      final strings = AppLocalizations.of(context);

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _exerciseCatalogTutorialKey,
            icon: Icons.menu_book_outlined,
            title: strings.catalogExerciseTutorialTitle,
            body: strings.catalogExerciseTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _targetAnatomyTutorialKey,
            icon: Icons.bubble_chart_outlined,
            title: strings.catalogAnatomyTutorialTitle,
            body: strings.catalogAnatomyTutorialBody,
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.catalogHome);
    } finally {
      _catalogTutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_CatalogOverviewData>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            final data = snapshot.data ?? _lastOverview;

            if (data == null &&
                snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (data == null && snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(strings.catalogLoadError('${snapshot.error}')),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              _lastOverview = snapshot.data;
            }
            final overview = data;
            if (overview == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(strings.catalogNoData),
                ),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _queueCatalogTutorial();
            });

            return RefreshIndicator(
              onRefresh: _refreshOverview,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  KeyedSubtree(
                    key: _exerciseCatalogTutorialKey,
                    child: _ExerciseCatalogCard(
                      exercises: overview.exercises,
                      onTap: _openExerciseCatalog,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _targetAnatomyTutorialKey,
                    child: _TargetAnatomyCard(
                      muscles: overview.muscles,
                      bodyParts: overview.bodyParts,
                      onMusclesTap: () => _openFocusLibrary(1),
                      onBodyPartsTap: () => _openFocusLibrary(0),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseCatalogCard extends StatelessWidget {
  final List<_ExerciseUsageSummary> exercises;
  final VoidCallback onTap;

  const _ExerciseCatalogCard({required this.exercises, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CatalogCardHeader(
                icon: Icons.fitness_center,
                title: strings.catalogExerciseTitle,
              ),
              const SizedBox(height: 16),
              Text(
                strings.catalogMostUsedExercises,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (exercises.isEmpty)
                Text(
                  strings.catalogNoExerciseHistory,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Column(
                  children: [
                    for (final exercise in exercises)
                      _ExerciseUsageBar(summary: exercise),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetAnatomyCard extends StatelessWidget {
  final List<_FocusUsageSummary> muscles;
  final List<_FocusUsageSummary> bodyParts;
  final VoidCallback onMusclesTap;
  final VoidCallback onBodyPartsTap;

  const _TargetAnatomyCard({
    required this.muscles,
    required this.bodyParts,
    required this.onMusclesTap,
    required this.onBodyPartsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CatalogCardHeader(
              icon: Icons.bubble_chart_outlined,
              title: strings.catalogTargetAnatomyTitle,
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _FocusSummaryPane(
                      title: strings.catalogBodyparts,
                      icon: Icons.accessibility_new,
                      items: bodyParts,
                      emptyText: strings.catalogNoBodypartHistory,
                      onTap: onBodyPartsTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FocusSummaryPane(
                      title: strings.catalogMuscles,
                      icon: Icons.fitness_center,
                      items: muscles,
                      emptyText: strings.catalogNoMuscleHistory,
                      onTap: onMusclesTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CatalogCardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseUsageBar extends StatelessWidget {
  final _ExerciseUsageSummary summary;

  const _ExerciseUsageBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final equipmentNames = summary.definition.equipmentList
        .map((equipment) => equipment.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.definition.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (equipmentNames.isNotEmpty) equipmentNames,
                    strings.catalogTimesUsed(summary.useCount),
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ExerciseMediaThumbnail(
            definition: summary.definition,
            size: 52,
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.zero,
            framed: false,
          ),
        ],
      ),
    );
  }
}

class _FocusSummaryPane extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_FocusUsageSummary> items;
  final String emptyText;
  final VoidCallback onTap;

  const _FocusSummaryPane({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(
                emptyText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final item in items.take(4)) _FocusUsageRow(summary: item),
          ],
        ),
      ),
    );
  }
}

class _FocusUsageRow extends StatelessWidget {
  final _FocusUsageSummary summary;

  const _FocusUsageRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            strings.catalogSetUnits(summary.units.round()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogOverviewData {
  final List<_ExerciseUsageSummary> exercises;
  final List<_FocusUsageSummary> bodyParts;
  final List<_FocusUsageSummary> muscles;

  const _CatalogOverviewData({
    required this.exercises,
    required this.bodyParts,
    required this.muscles,
  });
}

class _ExerciseUsageSummary {
  final ExerciseDefinition definition;
  final int useCount;

  const _ExerciseUsageSummary({
    required this.definition,
    required this.useCount,
  });
}

class _FocusUsageSummary {
  final String name;
  final double units;

  const _FocusUsageSummary(this.name, this.units);
}
