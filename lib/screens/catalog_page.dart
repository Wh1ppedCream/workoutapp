import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/active_session.dart';
import '../repositories/app_repository.dart';
import '../services/catalog_entity_localizer.dart';
import '../services/safe_failure.dart';
import '../services/tutorial_state_store.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/localized_body_part_name.dart';
import '../widgets/body_heatmap.dart';
import '../widgets/exercise_media_thumbnail.dart';
import '../widgets/guided_tutorial_overlay.dart';
import '../widgets/localized_catalog_entity_name.dart';
import '../widgets/localized_exercise_name.dart';
import '../widgets/safe_error_view.dart';
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
              (entry) => _FocusUsageSummary(
                muscleById[entry.key]!.name,
                entry.value,
                entity: CatalogEntityDisplayName(
                  catalogId: muscleById[entry.key]!.catalogId,
                  canonicalName: muscleById[entry.key]!.name,
                ),
              ),
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
              return SafeErrorView(
                title: strings.safeFailureLoadTitle,
                failure: SafeFailure.classify(snapshot.error!),
                onRetry: () {
                  _refreshOverview();
                },
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
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final panelForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              surfaces.exerciseProgressSelector,
            )
            : theme.colorScheme.onSurface;
    final panelSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              surfaces.exerciseProgressSelector,
            )
            : theme.colorScheme.onSurfaceVariant;
    final content = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogCardHeader(
            icon: Icons.fitness_center,
            title: strings.catalogExerciseTitle,
            iconBackground: usesInkRecipe ? surfaces.settingsHero : null,
            iconForeground:
                usesInkRecipe
                    ? tonosForegroundForSurface(context, surfaces.settingsHero)
                    : null,
            titleForeground: panelForeground,
          ),
          const SizedBox(height: 16),
          Text(
            strings.catalogMostUsedExercises,
            style: theme.textTheme.titleMedium?.copyWith(
              color: panelForeground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (exercises.isEmpty)
            Text(
              strings.catalogNoExerciseHistory,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: panelSecondaryForeground,
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
    );

    if (usesInkRecipe) {
      return TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: surfaces.exerciseProgressSelector,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        onTap: onTap,
        child: content,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
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
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final panelColor = usesInkRecipe ? surfaces.settingsHero : surfaces.card;
    final panelForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, panelColor)
            : theme.colorScheme.onSurface;
    final content = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogCardHeader(
            icon: Icons.bubble_chart_outlined,
            title: strings.catalogTargetAnatomyTitle,
            iconBackground:
                usesInkRecipe ? surfaces.exerciseProgressSelector : null,
            iconForeground:
                usesInkRecipe
                    ? tonosForegroundForSurface(
                      context,
                      surfaces.exerciseProgressSelector,
                    )
                    : null,
            titleForeground: panelForeground,
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
                    localizeBuiltInBodyPartNames: true,
                  ),
                ),
                const SizedBox(width: 12),
                VerticalDivider(
                  width: usesInkRecipe ? 2 : 1,
                  thickness: usesInkRecipe ? 2 : 1,
                  color:
                      usesInkRecipe
                          ? tonosOutlineForSurface(context, panelColor)
                          : theme.colorScheme.outlineVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FocusSummaryPane(
                    title: strings.catalogMuscles,
                    icon: Icons.fitness_center,
                    items: muscles,
                    emptyText: strings.catalogNoMuscleHistory,
                    onTap: onMusclesTap,
                    localizeBuiltInBodyPartNames: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (usesInkRecipe) {
      return TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: panelColor,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Card(clipBehavior: Clip.antiAlias, child: content);
  }
}

class _CatalogCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconBackground;
  final Color? iconForeground;
  final Color? titleForeground;

  const _CatalogCardHeader({
    required this.icon,
    required this.title,
    this.iconBackground,
    this.iconForeground,
    this.titleForeground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: iconBackground ?? theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: iconForeground ?? theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleForeground,
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final rowColor =
        usesInkRecipe ? surfaces.catalogSelection : surfaces.catalogUsage;
    final rowForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, rowColor)
            : theme.colorScheme.onSurface;
    final rowSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(context, rowColor)
            : theme.colorScheme.onSurfaceVariant;
    final effects = context.effectTokens;
    final strings = AppLocalizations.of(context);
    final equipment = summary.definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius:
            usesInkRecipe ? shapes.compact : BorderRadius.circular(14),
        border: Border.all(
          color:
              usesInkRecipe
                  ? tonosOutlineForSurface(context, rowColor)
                  : surfaces.catalogOutline,
          width: usesInkRecipe ? shapes.outlineWidth : 1,
        ),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedExerciseName(
                  definition: summary.definition,
                  maxLines: usesInkRecipe ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: rowForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                LocalizedCatalogEntityNamesBuilder(
                  entities: equipment,
                  builder:
                      (context, names) => Text(
                        [
                          if (names.isNotEmpty) names.join(', '),
                          strings.catalogTimesUsed(summary.useCount),
                        ].join(' - '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: rowSecondaryForeground,
                        ),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ExerciseMediaThumbnail(
            definition: summary.definition,
            size: 52,
            borderRadius:
                usesInkRecipe ? shapes.compact : BorderRadius.circular(12),
            padding: EdgeInsets.zero,
            framed: usesInkRecipe,
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
  final bool localizeBuiltInBodyPartNames;

  const _FocusSummaryPane({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.onTap,
    required this.localizeBuiltInBodyPartNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final shapes = context.shapeTokens;
    final iconColor =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              context.surfaceTokens.settingsHero,
            )
            : theme.colorScheme.primary;
    final radius = usesInkRecipe ? shapes.compact : BorderRadius.circular(16);
    final paneForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              context.surfaceTokens.settingsHero,
            )
            : theme.colorScheme.onSurface;
    final paneSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              context.surfaceTokens.settingsHero,
            )
            : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: isSpanish ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: (isSpanish
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          color: paneForeground,
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
                  color: paneSecondaryForeground,
                ),
              )
            else
              for (final item in items.take(4))
                _FocusUsageRow(
                  summary: item,
                  localizeBuiltInBodyPartNames: localizeBuiltInBodyPartNames,
                ),
          ],
        ),
      ),
    );
  }
}

class _FocusUsageRow extends StatelessWidget {
  final _FocusUsageSummary summary;
  final bool localizeBuiltInBodyPartNames;

  const _FocusUsageRow({
    required this.summary,
    required this.localizeBuiltInBodyPartNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final nameForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              context.surfaceTokens.settingsHero,
            )
            : theme.colorScheme.onSurface;
    final setUnitColor =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              context.surfaceTokens.settingsHero,
            )
            : theme.colorScheme.primary;
    final displayName =
        localizeBuiltInBodyPartNames
            ? localizedBodyPartName(context, summary.name)
            : summary.name;
    final nameWidget =
        summary.entity == null
            ? Text(
              displayName,
              maxLines: usesInkRecipe ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: nameForeground,
              ),
            )
            : LocalizedCatalogEntityName(
              entity: summary.entity!,
              maxLines: usesInkRecipe ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: nameForeground,
              ),
            );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child:
                isSpanish && localizeBuiltInBodyPartNames
                    ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: nameWidget,
                    )
                    : nameWidget,
          ),
          const SizedBox(width: 8),
          Text(
            strings.catalogSetUnits(summary.units.round()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: setUnitColor,
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
  final CatalogEntityDisplayName? entity;

  const _FocusUsageSummary(this.name, this.units, {this.entity});
}
