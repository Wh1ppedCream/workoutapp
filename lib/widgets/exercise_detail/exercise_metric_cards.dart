part of '../exercise_detail_sheet.dart';

class _MetricSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? expressiveSurface;
  final Color? expressiveForeground;
  final bool expressive;
  final bool catalogAlignedLabels;

  const _MetricSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.expressiveSurface,
    this.expressiveForeground,
    this.expressive = false,
    this.catalogAlignedLabels = false,
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
          catalogAlignedLabels
              ? ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: _buildLabelRow(theme),
                )
              : _buildLabelRow(theme),
          SizedBox(height: catalogAlignedLabels ? 9 : 12),
          catalogAlignedLabels
              ? Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style:
                          (theme.textTheme.titleLarge ??
                                  theme.textTheme.titleMedium)
                              ?.copyWith(
                                color: expressive ? expressiveForeground : null,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style:
                        (theme.textTheme.titleLarge ??
                                theme.textTheme.titleMedium)
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

  Widget _buildLabelRow(ThemeData theme) => Row(
    children: [
      Icon(icon, size: 17, color: expressive ? expressiveForeground : color),
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
  );
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
    super.key,
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
