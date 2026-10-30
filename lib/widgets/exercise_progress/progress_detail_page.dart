part of '../exercise_progress_section.dart';

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
      MaterialPageRoute(
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.progress,
          child: SessionDetailScreen(resolvedSession),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = theme.extension<AppExpressiveTrainTokens>();
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final expressiveProgressLight =
        usesExpressive &&
        theme.brightness == Brightness.light &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final detailModuleSurface = expressiveProgressLight
        ? Color.lerp(
            surfaces.exerciseProgressHero,
            destinationTokens!.surfaceSelected,
            0.22,
          )!
        : surfaces.exerciseProgressHero;
    final detailPlotSurface = expressiveProgressLight
        ? Color.lerp(
            theme.colorScheme.surface,
            destinationTokens!.surfaceSecondary,
            0.28,
          )!
        : null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final detailChartHeight = widget.tile.points.isEmpty && usesExpressive
        ? 112.0 + (textScale - 1).clamp(0.0, 1.0) * 28
        : 220.0;
    final chart = LocalizedExerciseNameBuilder(
      definition: widget.tile.definition,
      builder: (context, localizedName) {
        final chart = _ExerciseProgressChart(
          points: widget.tile.points,
          showEmptyLabel: true,
          showAxes: true,
          interactive: true,
          exerciseName: localizedName,
          weightUnit: weightUnit,
          estimatedColor: tonosSecondarySeriesForSurface(
            context,
            context.surfaceTokens.exerciseProgressStat,
          ),
          plotSurface: detailPlotSurface,
        );
        final emptyPlot = usesExpressive && widget.tile.points.isEmpty
            ? DecoratedBox(
                key: const ValueKey(
                  'exercise-progress-expressive-detail-empty-plot',
                ),
                decoration: BoxDecoration(
                  color: detailPlotSurface ?? theme.colorScheme.surface,
                  borderRadius: shapes.exerciseProgressStat,
                ),
                child: chart,
              )
            : chart;
        return SizedBox(
          key: const ValueKey('exercise-progress-detail-chart-frame'),
          height: detailChartHeight,
          child: emptyPlot,
        );
      },
    );
    final legend = _ExerciseProgressLegend(
      estimatedColor: tonosSecondarySeriesForSurface(
        context,
        surfaces.exerciseProgressStat,
      ),
    );

    Widget chartSurface(Widget child) {
      if (usesExpressive) {
        return TonosSurface(
          key: const ValueKey('exercise-progress-expressive-detail-module'),
          variant: TonosSurfaceVariant.card,
          color: detailModuleSurface,
          padding: EdgeInsets.zero,
          borderRadius: shapes.exerciseProgressHero,
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      }
      return Card(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: LocalizedExerciseName(definition: widget.tile.definition),
        centerTitle: !usesExpressive,
        backgroundColor: usesExpressive
            ? destinationTokens?.surfacePrimary ??
                  expressiveTokens?.focusSurface
            : null,
        foregroundColor: usesExpressive
            ? destinationTokens?.onSurfacePrimary ??
                  expressiveTokens?.focusForeground
            : null,
      ),
      backgroundColor: expressiveProgressLight
          ? destinationTokens!.pageCanvas
          : usesExpressive
          ? destinationTokens?.surfacePrimary ?? expressiveTokens?.focusSurface
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          KeyedSubtree(
            key: _chartTutorialKey,
            child: chartSurface(
              usesExpressive
                  ? Column(
                      key: const ValueKey(
                        'exercise-progress-expressive-detail-chart',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          key: const ValueKey(
                            'exercise-progress-expressive-detail-header',
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                          color:
                              destinationTokens?.surfacePrimary ??
                              expressiveTokens?.focusSurface ??
                              surfaces.exerciseProgressSelector,
                          child: Text(
                            _strings.exerciseProgressTitle,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color:
                                  destinationTokens?.onSurfacePrimary ??
                                  expressiveTokens?.focusForeground ??
                                  tonosForegroundForSurface(
                                    context,
                                    surfaces.exerciseProgressSelector,
                                    parentSurface:
                                        surfaces.exerciseProgressHero,
                                  ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                key: const ValueKey(
                                  'exercise-progress-expressive-detail-plot-inset',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 6,
                                ),
                                child: chart,
                              ),
                              if (widget.tile.points.isNotEmpty)
                                DecoratedBox(
                                  key: const ValueKey(
                                    'exercise-progress-expressive-detail-legend',
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaces.exerciseProgressStat,
                                    border: Border(
                                      top: BorderSide(
                                        color: tonosOutlineForSurface(
                                          context,
                                          surfaces.exerciseProgressStat,
                                          neutral: true,
                                        ).withValues(alpha: 0.48),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      14,
                                    ),
                                    child: legend,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _strings.exerciseProgressTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        chart,
                        const SizedBox(height: 12),
                        legend,
                      ],
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
          const SizedBox(height: 12),
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
              child: usesExpressive
                  ? TonosSurface(
                      key: const ValueKey(
                        'exercise-progress-expressive-recordings-group',
                      ),
                      variant: TonosSurfaceVariant.panelRaised,
                      color: surfaces.exerciseProgressStat,
                      padding: EdgeInsets.zero,
                      borderRadius: shapes.exerciseProgressSelector,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final (index, point)
                              in widget.tile.points.reversed.indexed) ...[
                            _ExerciseProgressRecordingRow(
                              point: point,
                              expressive: true,
                              onTap: () {
                                _openSession(context, point.sessionId);
                              },
                            ),
                            if (index < widget.tile.points.length - 1)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 16,
                                ),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: tonosOutlineForSurface(
                                    context,
                                    surfaces.exerciseProgressStat,
                                    neutral: true,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                          ],
                        ],
                      ),
                    )
                  : Column(
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
