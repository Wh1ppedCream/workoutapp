part of '../exercise_progress_section.dart';

class _ExpressiveExerciseProgressHeader extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final bool isEditing;
  final VoidCallback onEdit;

  const _ExpressiveExerciseProgressHeader({
    required this.layout,
    required this.isEditing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final tokens = theme.extension<AppExpressiveTrainTokens>()!;
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    final isExpressiveProgress =
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final actionFill = isExpressiveProgress
        ? destinationTokens!.surfaceSelected
        : tokens.actionSecondary;
    final actionForeground = isExpressiveProgress
        ? destinationTokens!.onSurfaceSelected
        : tokens.actionSecondaryForeground;
    final title = Text(
      strings.dashboardSectionExerciseProgressTitle,
      key: const ValueKey('exercise-progress-expressive-title'),
      textAlign: TextAlign.start,
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w900,
      ),
    );
    final actionLabel = isEditing ? strings.commonDone : strings.commonEdit;
    final action = TonosExpressivePressResponse(
      enabled: true,
      borderRadius: context.shapeTokens.exerciseProgressAddTile,
      pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      allowReleaseOvershoot: false,
      child: FilledButton.tonalIcon(
        key: const ValueKey('exercise-progress-header-edit'),
        onPressed: onEdit,
        icon: Icon(isEditing ? Icons.check : Icons.edit_outlined, size: 18),
        label: Text(actionLabel),
        style: FilledButton.styleFrom(
          backgroundColor: actionFill,
          foregroundColor: actionForeground,
          minimumSize: const Size(48, 44),
          padding: EdgeInsets.symmetric(horizontal: layout.value(12)),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: context.shapeTokens.exerciseProgressAddTile,
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stacked =
            constraints.maxWidth < layout.value(330) || textScale > 1.15;
        if (stacked) {
          return Column(
            key: const ValueKey('exercise-progress-expressive-header-stacked'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              SizedBox(height: layout.value(8)),
              Align(alignment: AlignmentDirectional.centerEnd, child: action),
            ],
          );
        }
        return Row(
          key: const ValueKey('exercise-progress-expressive-header-inline'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            SizedBox(width: layout.value(12)),
            action,
          ],
        );
      },
    );
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
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final destinationTokens = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    final isExpressiveProgress =
        usesExpressive &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final tooltipForeground = usesInkRecipe || usesExpressive
        ? tonosForegroundForSurface(context, surfaces.exerciseProgressTooltip)
        : theme.colorScheme.onSurface;
    final body = Semantics(
      button: true,
      label: localizedName,
      selected: usesExpressive ? true : null,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: shapes.exerciseProgressHero * layout.scale,
        child: Padding(
          padding: EdgeInsets.all(layout.heroPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context)
                  .scale(1)
                  .clamp(1.0, 2.0)
                  .toDouble();
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
                chartHeight: classicStacked
                    ? layout.heroStackedChartHeight
                    : layout.heroChartHeight,
                tooltipTextColor: tooltipForeground,
                isEditing: isEditing,
              );
              final statsColumn = _ExerciseProgressStatsColumn(
                tile: tile,
                layout: layout,
              );

              if (usesExpressive) {
                if (useStacked) {
                  return Column(
                    key: const ValueKey(
                      'exercise-progress-expressive-hero-stacked',
                    ),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      chartColumn,
                      SizedBox(height: layout.heroColumnGap),
                      statsColumn,
                    ],
                  );
                }
                return Row(
                  key: const ValueKey(
                    'exercise-progress-expressive-hero-asymmetric',
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chartColumn),
                    SizedBox(width: layout.heroRowGap),
                    SizedBox(width: minimumStatsWidth, child: statsColumn),
                  ],
                );
              }

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
        key: const ValueKey('exercise-progress-hero-surface'),
        decoration: BoxDecoration(
          color: isExpressiveProgress
              ? destinationTokens!.surfacePrimary
              : surfaces.exerciseProgressHero,
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
    final shapes = context.shapeTokens;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressive
        ? theme.extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    final isExpressiveProgress =
        usesExpressive &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final chart = SizedBox(
      height: chartHeight,
      child: _ExerciseProgressChart(
        points: tile.points,
        showEmptyLabel: true,
        showAxes: true,
        exerciseName: localizedName,
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
    );

    if (usesExpressive) {
      final expressiveStyle = expressiveTokens!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.value(12),
              vertical: layout.value(10),
            ),
            decoration: BoxDecoration(
              color: isExpressiveProgress
                  ? destinationTokens!.surfaceSelected
                  : destinationTokens?.surfaceAccent ??
                        expressiveStyle.focusSurface,
              borderRadius: shapes.exerciseProgressStat * layout.scale,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isEditing ? layout.removeBadgeHitSize : 0,
                    ),
                    child: Text(
                      localizedName,
                      key: const ValueKey(
                        'exercise-progress-expressive-identity',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isExpressiveProgress
                            ? destinationTokens!.onSurfaceSelected
                            : destinationTokens?.onSurfaceAccent ??
                                  expressiveStyle.focusForeground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: layout.value(20),
                  color:
                      (isExpressiveProgress
                              ? destinationTokens!.onSurfaceSelected
                              : destinationTokens?.onSurfaceAccent ??
                                    expressiveStyle.focusForeground)
                          .withValues(alpha: 0.82),
                ),
              ],
            ),
          ),
          SizedBox(height: layout.value(10)),
          Container(
            key: const ValueKey('exercise-progress-expressive-chart-inset'),
            decoration: BoxDecoration(
              color: isExpressiveProgress
                  ? Colors.transparent
                  : surfaces.exerciseProgressTooltip,
              borderRadius: shapes.exerciseProgressStat * layout.scale,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: layout.value(6),
              vertical: layout.value(4),
            ),
            child: chart,
          ),
        ],
      );
    }

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
        chart,
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
    if (context.usesExpressivePresentation) {
      final destinationTokens = Theme.of(context)
          .extension<AppExpressiveDestinationTokens>();
      final isProgress =
          destinationTokens?.family == AppExpressiveDestinationFamily.progress;
      return _ExpressiveExerciseProgressSummaryRail(
        layout: layout,
        isProgress: isProgress,
        moduleForeground: isProgress
            ? destinationTokens!.onSurfacePrimary
            : null,
        actualLabel: strings.exerciseProgressActual,
        actualIsMissing: actualOneRm == null,
        actualValue: actualOneRm == null
            ? '—'
            : _formatWeight(actualOneRm, weightUnit, locale: locale),
        noActualValue: strings.exerciseProgressNoActual,
        actualDelta: actualDelta,
        estimatedLabel: strings.exerciseProgressEstimatedOneRepMax,
        estimatedValue: latest == null
            ? '--'
            : _formatWeight(latest.estimatedOneRm, weightUnit, locale: locale),
        estimatedDelta: estimatedDelta,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExerciseProgressStatBox(
          label: strings.exerciseProgressOneRepMax,
          value: actualOneRm == null
              ? '--'
              : _formatWeight(actualOneRm, weightUnit, locale: locale),
          delta: actualDelta,
          layout: layout,
        ),
        SizedBox(height: layout.heroRowGap),
        _ExerciseProgressStatBox(
          label: strings.exerciseProgressEstimatedOneRepMax,
          value: latest == null
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

class _ExpressiveExerciseProgressSummaryRail extends StatelessWidget {
  final _ExerciseProgressLayout layout;
  final bool isProgress;
  final Color? moduleForeground;
  final String actualLabel;
  final bool actualIsMissing;
  final String actualValue;
  final String noActualValue;
  final double? actualDelta;
  final String estimatedLabel;
  final String estimatedValue;
  final double? estimatedDelta;

  const _ExpressiveExerciseProgressSummaryRail({
    required this.layout,
    this.isProgress = false,
    this.moduleForeground,
    required this.actualLabel,
    required this.actualIsMissing,
    required this.actualValue,
    required this.noActualValue,
    required this.actualDelta,
    required this.estimatedLabel,
    required this.estimatedValue,
    required this.estimatedDelta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final locale = Localizations.localeOf(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final secondary =
        moduleForeground?.withValues(alpha: 0.78) ??
        tonosSecondaryForegroundForSurface(
          context,
          surfaces.exerciseProgressStat,
        );
    final dividerColor = isProgress
        ? moduleForeground!.withValues(alpha: 0.32)
        : tonosOutlineForSurface(
            context,
            surfaces.exerciseProgressStat,
            neutral: true,
          ).withValues(alpha: 0.5);

    Widget metric(
      String label,
      String value,
      double? delta, {
      bool supportingValue = false,
      bool showDelta = true,
    }) {
      final deltaIcon = _deltaIcon(delta);
      final semanticDeltaColor = _deltaColor(context, delta);
      final deltaColor = isProgress && (delta == null || delta == 0)
          ? secondary
          : semanticDeltaColor;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: layout.value(3)),
          Text(
            value,
            softWrap: true,
            style: supportingValue
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: secondary,
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.titleLarge?.copyWith(
                    color:
                        moduleForeground ??
                        tonosForegroundForSurface(
                          context,
                          surfaces.exerciseProgressStat,
                        ),
                    fontWeight: FontWeight.w900,
                  ),
          ),
          if (showDelta) ...[
            SizedBox(height: layout.value(3)),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: layout.value(3),
              children: [
                if (deltaIcon != null)
                  Icon(deltaIcon, size: layout.value(14), color: deltaColor),
                Text(
                  _formatDeltaWeight(delta, weightUnit, locale: locale),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Container(
      key: const ValueKey('exercise-progress-expressive-summary-rail'),
      padding: EdgeInsets.symmetric(
        horizontal: layout.value(12),
        vertical: layout.value(10),
      ),
      decoration: BoxDecoration(
        color: isProgress ? Colors.transparent : surfaces.exerciseProgressStat,
        borderRadius: shapes.exerciseProgressStat * layout.scale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (actualIsMissing)
            Semantics(
              container: true,
              label: actualLabel,
              value: noActualValue,
              excludeSemantics: true,
              child: metric(
                actualLabel,
                actualValue,
                actualDelta,
                supportingValue: true,
                showDelta: false,
              ),
            )
          else
            metric(actualLabel, actualValue, actualDelta),
          Padding(
            padding: EdgeInsets.symmetric(vertical: layout.value(8)),
            child: Divider(height: 1, color: dividerColor),
          ),
          metric(estimatedLabel, estimatedValue, estimatedDelta),
        ],
      ),
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
    final neo = context.usesNeoPresentation;
    final foreground = tonosForegroundForSurface(
      context,
      surfaces.exerciseProgressStat,
    );
    final secondary = tonosSecondaryForegroundForSurface(
      context,
      surfaces.exerciseProgressStat,
    );
    final deltaColor = neo
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
            color: context.surfaceDecorationTokens.panel.outlined
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
      builder: (context, localizedName) =>
          _buildSelector(context, localizedName),
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
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = theme.extension<AppExpressiveTrainTokens>();
    final destinationTokens = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    final isExpressiveProgress =
        usesExpressive &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final selectedFill = usesExpressive
        ? expressiveTokens?.selectorActive ?? accent.withValues(alpha: 0.14)
        : accent.withValues(alpha: 0.14);
    final tileFill = isSelected
        ? selectedFill
        : isExpressiveProgress
        ? destinationTokens!.surfacePrimary
        : surfaces.exerciseProgressSelector;
    final chartSeriesSurface = usesInkRecipe && isSelected
        ? surfaces.exerciseProgressSelector
        : tileFill;
    final tileForeground = isExpressiveProgress
        ? destinationTokens!.onSurfacePrimary
        : usesExpressive && isSelected
        ? expressiveTokens?.selectorActiveForeground ??
              tonosForegroundForSurface(
                context,
                tileFill,
                parentSurface: surfaces.card,
              )
        : usesInkRecipe || usesExpressive
        ? tonosForegroundForSurface(
            context,
            tileFill,
            parentSurface: surfaces.card,
          )
        : theme.colorScheme.onSurface;
    final tileSecondaryForeground = usesExpressive && isSelected
        ? expressiveTokens?.selectorActiveForeground.withValues(alpha: 0.76) ??
              tileForeground.withValues(alpha: 0.76)
        : usesInkRecipe || usesExpressive
        ? tonosSecondaryForegroundForSurface(
            context,
            tileFill,
            parentSurface: surfaces.card,
          )
        : theme.colorScheme.onSurfaceVariant;
    final tooltipForeground = usesInkRecipe || usesExpressive
        ? tonosForegroundForSurface(context, surfaces.exerciseProgressTooltip)
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
              if (isExpressiveProgress)
                Container(
                  key: ValueKey(
                    'exercise-progress-selector-identity-${tile.definition.id}',
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.value(8),
                    vertical: layout.value(4),
                  ),
                  decoration: BoxDecoration(
                    color: destinationTokens!.surfaceSelected,
                    borderRadius: shapes.exerciseProgressStat * layout.scale,
                  ),
                  child: Text(
                    localizedName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: destinationTokens.onSurfaceSelected,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
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
                    chartSeriesSurface,
                  ),
                  estimatedColor: tonosSecondarySeriesForSurface(
                    context,
                    chartSeriesSurface,
                  ),
                ),
              ),
              SizedBox(height: layout.selectorGraphGap),
              _ExerciseProgressSelectorValues(
                latestValue: latest == null
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
            key: isExpressiveProgress
                ? ValueKey(
                    'exercise-progress-selector-surface-${tile.definition.id}',
                  )
                : null,
            decoration: BoxDecoration(
              color: tileFill,
              border: Border.all(
                color: isSelected
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
              boxShadow: usesInkRecipe
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
        final deltaDecorationWidth = deltaIcon == null
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
        final values = useStacked
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
    final shadows = badgeShadow.color.a == 0
        ? const <BoxShadow>[]
        : [badgeShadow];
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
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w800),
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
  final number = locale == null
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
    final neo = context.usesNeoPresentation;
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
    final expressiveTokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isExpressiveProgress =
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final actionFill = isExpressiveProgress
        ? destinationTokens!.surfaceSelected
        : expressiveTokens?.actionSecondary;
    final actionForeground = isExpressiveProgress
        ? destinationTokens!.onSurfaceSelected
        : expressiveTokens?.actionSecondaryForeground;
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
              key: isExpressiveProgress
                  ? const ValueKey(
                      'exercise-progress-expressive-add-action-surface',
                    )
                  : null,
              decoration: BoxDecoration(
                color: actionFill,
                border: Border.all(
                  color: context.surfaceDecorationTokens.panel.outlined
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
                    color: actionForeground ?? dataVisualization.label,
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
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final addTileRadius = shapes.exerciseProgressAddTile * layout.scale;
    return Semantics(
      button: true,
      label: strings.commonEdit,
      onTap: onTap,
      child: Tooltip(
        message: strings.commonEdit,
        child: TonosExpressivePressResponse(
          enabled: expressive,
          borderRadius: expressive ? addTileRadius : null,
          pressedBorderRadius: expressive
              ? ExpressiveTrainShapes.compactControlPressed
              : null,
          pressedScale: TonosExpressiveMotionTiers.supportingScale,
          pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
          allowReleaseOvershoot: false,
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
                  color: expressiveTokens?.actionSecondary,
                  border: Border.all(
                    color: context.surfaceDecorationTokens.panel.outlined
                        ? tonosOutlineForSurface(
                            context,
                            context.cs.surface,
                            neutral: true,
                          )
                        : surfaces.subtleOutline,
                  ),
                  borderRadius: addTileRadius,
                ),
                child: InkWell(
                  borderRadius: addTileRadius,
                  onTap: onTap,
                  child: Center(
                    child: Icon(
                      Icons.edit,
                      size: layout.value(26),
                      color:
                          expressiveTokens?.actionSecondaryForeground ??
                          dataVisualization.label,
                    ),
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
