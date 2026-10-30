part of '../workout_metric_chart_card.dart';

class _EmptyMetricChartMessage extends StatelessWidget {
  final WorkoutReportMetric metric;

  const _EmptyMetricChartMessage({required this.metric});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cs = context.cs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_emptyMetricIcon(metric), color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              _emptyMetricTitle(metric, strings),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              _emptyMetricSubtitle(metric, strings),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final WorkoutReportRange selectedRange;
  final ValueChanged<WorkoutReportRange> onSelectRange;

  const _RangeSelector({
    required this.selectedRange,
    required this.onSelectRange,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isProgressDestination = _usesProgressExpressiveReport(context);
    final isDarkProgressDestination =
        isProgressDestination &&
        Theme.of(context).brightness == Brightness.dark;
    final selectedFill = isProgressDestination
        ? destinationTokens!.surfaceSelected
        : destinationTokens?.actionPrimary ??
              expressiveTokens?.selectorActive ??
              progressColors.accent;
    final unselectedForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, surfaces.workoutMetricRange)
        : usesExpressiveRecipe
        ? isProgressDestination
              ? destinationTokens!.onSurfacePrimary
              : destinationTokens?.onSurfaceTertiary ??
                    (Theme.of(context).brightness == Brightness.light
                        ? expressiveTokens!.focusSurface
                        : expressiveTokens!.focusForeground)
        : context.cs.onSurface;
    final selectedForeground = usesInkRecipe
        ? tonosForegroundForSurface(
            context,
            selectedFill,
            parentSurface: surfaces.workoutMetricRange,
          )
        : isProgressDestination
        ? destinationTokens!.onSurfaceSelected
        : destinationTokens?.onActionPrimary ??
              expressiveTokens?.selectorActiveForeground ??
              context.cs.onPrimary;
    return Container(
      key: isProgressDestination
          ? const ValueKey('workout-report-expressive-range-rail')
          : null,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isProgressDestination
            ? Color.lerp(
                destinationTokens!.surfacePrimary,
                destinationTokens.surfaceSelected,
                0.12,
              )
            : destinationTokens?.surfaceTertiary ??
                  expressiveTokens?.selectorTrack ??
                  surfaces.workoutMetricRange,
        borderRadius: shapes.workoutMetricRange,
        border: usesInkRecipe
            ? Border.all(
                color: tonosOutlineForSurface(
                  context,
                  surfaces.workoutMetricRange,
                ),
                width: shapes.outlineWidth,
              )
            : isDarkProgressDestination
            ? Border.all(
                color: destinationTokens!.outlineAccent.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final compactLayout = textScale <= 1.15;
          final columns = compactLayout
              ? WorkoutReportRange.values.length
              : constraints.maxWidth < 360 || textScale > 1.15
              ? 3
              : WorkoutReportRange.values.length;
          const gap = 4.0;
          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final range in WorkoutReportRange.values)
                SizedBox(
                  width: itemWidth,
                  child: _RangeSelectorOption(
                    label: _rangeLabel(range, strings),
                    selected: selectedRange == range,
                    selectedFill: selectedFill,
                    selectedForeground: selectedForeground,
                    unselectedForeground: unselectedForeground,
                    borderRadius: shapes.workoutMetricRangeOption,
                    onTap: () => onSelectRange(range),
                    compactLayout: compactLayout,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RangeSelectorOption extends StatelessWidget {
  const _RangeSelectorOption({
    required this.label,
    required this.selected,
    required this.selectedFill,
    required this.selectedForeground,
    required this.unselectedForeground,
    required this.borderRadius,
    required this.onTap,
    this.compactLayout = false,
  });

  final String label;
  final bool selected;
  final Color selectedFill;
  final Color selectedForeground;
  final Color unselectedForeground;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback onTap;
  final bool compactLayout;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? selectedForeground : unselectedForeground;
    if (compactLayout) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius.resolve(Directionality.of(context)),
            onTap: onTap,
            child: AnimatedContainer(
              duration: appMotionDuration(context, context.motionTokens.quick),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? selectedFill : Colors.transparent,
                borderRadius: borderRadius,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Ink(
              decoration: BoxDecoration(
                color: selected ? selectedFill : Colors.transparent,
                borderRadius: borderRadius,
              ),
              child: InkWell(
                borderRadius: borderRadius.resolve(Directionality.of(context)),
                onTap: onTap,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
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

class _AdditionalDetailsDropdown extends StatelessWidget {
  final bool expanded;
  final List<_ReportInsight> insights;
  final VoidCallback onToggle;

  const _AdditionalDetailsDropdown({
    required this.expanded,
    required this.insights,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = usesExpressiveRecipe
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isProgressDestination = _usesProgressExpressiveReport(context);
    // In Flutter 3.47.5, a muted Progress tab can build AnimatedSize through
    // AnimatedCrossFade with zero duration and mark layout dirty while sizing.
    // Keep this compatibility path preview-only and preserve the parent's
    // expanded state so the same disclosure returns when the tab is active.
    final usesStaticExpressiveDisclosure =
        context.usesExpressivePresentation &&
        !TickerMode.valuesOf(context).enabled &&
        MediaQuery.disableAnimationsOf(context);
    if (usesExpressiveRecipe && !usesStaticExpressiveDisclosure) {
      final surface =
          destinationTokens?.surfaceAccent ?? expressiveTokens!.selectorTrack;
      final foreground =
          destinationTokens?.onSurfaceAccent ?? expressiveTokens!.actionPrimary;
      return Material(
        key: isProgressDestination
            ? const ValueKey('workout-report-expressive-details-module')
            : null,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: shapes.workoutMetricDetails,
          side: BorderSide(
            color: destinationTokens?.outlineAccent ?? cs.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTileTheme(
          data: ListTileTheme.of(context).copyWith(
            minTileHeight: 48,
            minVerticalPadding: 4,
            minLeadingWidth: 32,
            horizontalTitleGap: 10,
          ),
          child: TonosExpressiveInsetAccordion(
            surface: surface,
            foreground: foreground,
            outline: destinationTokens?.outlineAccent ?? cs.outlineVariant,
            borderRadius: shapes.workoutMetricDetails,
            initiallyExpanded: expanded,
            onExpansionChanged: (value) {
              if (value != expanded) onToggle();
            },
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            headerBodySpacing: 8,
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.insights_outlined, size: 19, color: foreground),
            ),
            title: Text(
              AppLocalizations.of(context).workoutReportAdditionalDetails,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
            ),
            children: [_ReportInsightGrid(insights: insights)],
          ),
        ),
      );
    }
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: isProgressDestination
                  ? Colors.transparent
                  : destinationTokens?.surfaceAccent ??
                        expressiveTokens?.selectorTrack ??
                        surfaces.workoutMetricDetails,
              borderRadius: shapes.workoutMetricDetails,
              border: usesExpressiveRecipe
                  ? null
                  : Border.all(
                      color: usesInkRecipe
                          ? tonosOutlineForSurface(
                              context,
                              surfaces.workoutMetricDetails,
                              neutral: true,
                            )
                          : cs.outlineVariant.withValues(alpha: 0.55),
                    ),
            ),
            child: InkWell(
              borderRadius: shapes.workoutMetricDetails,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    if (usesExpressiveRecipe) ...[
                      Container(
                        width: 3,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              destinationTokens?.actionPrimary ??
                              expressiveTokens!.selectorActive,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)
                            .workoutReportAdditionalDetails,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color:
                              destinationTokens?.onSurfaceAccent ??
                              expressiveTokens?.actionPrimary ??
                              cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isProgressDestination
                          ? destinationTokens!.onSurfaceAccent
                          : expressiveTokens?.focusCool ?? cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (usesStaticExpressiveDisclosure)
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ReportInsightGrid(insights: insights),
            )
          else
            const SizedBox.shrink()
        else
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ReportInsightGrid(insights: insights),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: appMotionDuration(context, context.motionTokens.quick),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
          ),
      ],
    );
    if (!isProgressDestination) return details;

    return Material(
      key: const ValueKey('workout-report-expressive-details-module'),
      color: destinationTokens!.surfaceAccent,
      borderRadius: shapes.workoutMetricDetails,
      clipBehavior: Clip.antiAlias,
      child: details,
    );
  }
}

class _ReportInsightGrid extends StatelessWidget {
  final List<_ReportInsight> insights;

  const _ReportInsightGrid({required this.insights});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final preservesClassicLayout =
            context.usesClassicPresentation && textScale <= 1.15;
        const gridSpacing = 8.0;
        const neoMinimumTileWidth = 160.0;
        final useTwoColumns =
            preservesClassicLayout ||
            (textScale <= 1.15 &&
                !context.usesClassicPresentation &&
                constraints.maxWidth >= neoMinimumTileWidth * 2 + gridSpacing);
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - gridSpacing) / 2
            : constraints.maxWidth;
        final classicTileHeight = preservesClassicLayout
            ? (Localizations.localeOf(context).languageCode == 'en'
                  ? 68.0
                  : 88.0)
            : null;
        return Wrap(
          key: ValueKey(
            useTwoColumns
                ? 'workout-report-insight-grid-two-columns'
                : 'workout-report-insight-grid-one-column',
          ),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final insight in insights)
              SizedBox(
                width: itemWidth,
                height: classicTileHeight,
                child: _ReportInsightTile(insight: insight),
              ),
          ],
        );
      },
    );
  }
}

class _ReportInsightTile extends StatelessWidget {
  final _ReportInsight insight;

  const _ReportInsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final progressColors = context.progressColors;
    final usesClassicPresentation = context.usesClassicPresentation;
    final expressiveTokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()
        : null;
    final destinationTokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final isProgressDestination =
        context.usesExpressivePresentation &&
        destinationTokens?.family == AppExpressiveDestinationFamily.progress;
    final isDarkProgressDestination =
        isProgressDestination &&
        Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final classicNormalScale = usesClassicPresentation && textScale <= 1.15;
    final compactClassicTile = classicNormalScale && textScale > 1.0;
    return Semantics(
      container: true,
      label: insight.detail.isEmpty
          ? '${insight.label}, ${insight.value}'
          : '${insight.label}, ${insight.value}, ${insight.detail}',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compactClassicTile ? 5 : 10,
          ),
          decoration: BoxDecoration(
            color: isProgressDestination
                ? Color.lerp(
                    destinationTokens!.surfaceAccent,
                    destinationTokens.surfaceSelected,
                    isDarkProgressDestination ? 0.4 : 0.16,
                  )
                : surfaces.workoutMetricInsight,
            borderRadius: shapes.workoutMetricInsight,
            border: context.usesExpressivePresentation
                ? null
                : Border.all(
                    color: context.surfaceDecorationTokens.panel.outlined
                        ? tonosOutlineForSurface(
                            context,
                            surfaces.workoutMetricInsight,
                          )
                        : cs.outlineVariant.withValues(alpha: 0.55),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                insight.icon,
                size: 18,
                color: isProgressDestination
                    ? destinationTokens!.onSurfaceAccent
                    : expressiveTokens?.focusCool ?? progressColors.accent,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, _) {
                    final useStackedValues = textScale > 1.15;
                    return Column(
                      key: ValueKey(
                        useStackedValues
                            ? 'workout-report-insight-values-stacked'
                            : 'workout-report-insight-values-inline',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isProgressDestination
                          ? [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: insight.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: destinationTokens!
                                                .onSurfaceAccent,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    if (insight.detail.isNotEmpty)
                                      TextSpan(
                                        text: ' ${insight.detail}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: destinationTokens!
                                                  .onSurfaceAccent,
                                            ),
                                      ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                insight.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: destinationTokens!.onSurfaceAccent,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ]
                          : [
                              Text(
                                insight.label,
                                maxLines: classicNormalScale ? 1 : null,
                                overflow: classicNormalScale
                                    ? TextOverflow.ellipsis
                                    : null,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: isProgressDestination
                                          ? destinationTokens!.onSurfaceAccent
                                          : cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              useStackedValues
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          insight.value,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: isProgressDestination
                                                    ? destinationTokens!
                                                          .onSurfaceAccent
                                                    : null,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        if (insight.detail.isNotEmpty)
                                          Text(
                                            insight.detail,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: isProgressDestination
                                                      ? destinationTokens!
                                                            .onSurfaceAccent
                                                      : cs.onSurfaceVariant,
                                                ),
                                          ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            insight.value,
                                            maxLines: classicNormalScale
                                                ? 1
                                                : null,
                                            overflow: classicNormalScale
                                                ? TextOverflow.ellipsis
                                                : null,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: isProgressDestination
                                                      ? destinationTokens!
                                                            .onSurfaceAccent
                                                      : null,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                        if (insight.detail.isNotEmpty) ...[
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              insight.detail,
                                              maxLines: classicNormalScale
                                                  ? 1
                                                  : null,
                                              overflow: classicNormalScale
                                                  ? TextOverflow.ellipsis
                                                  : null,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: isProgressDestination
                                                        ? destinationTokens!
                                                              .onSurfaceAccent
                                                        : cs.onSurfaceVariant,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                            ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
