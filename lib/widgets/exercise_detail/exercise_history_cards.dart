part of '../exercise_detail_sheet.dart';

class _ExerciseHistorySessionCard extends StatelessWidget {
  final HistoryRecord record;
  final WeightUnit weightUnit;
  final bool catalogBrowserRefinement;
  final VoidCallback onOpenSession;

  const _ExerciseHistorySessionCard({
    required this.record,
    required this.weightUnit,
    this.catalogBrowserRefinement = false,
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
        ? catalogBrowserRefinement
              ? scheme.surfaceContainerHigh
              : destination!.surfaceSelected
        : scheme.secondary.withValues(
            alpha: surfaces.exerciseDetailRecordActionFillOpacity,
          );
    final recordActionForeground = expressive
        ? catalogBrowserRefinement
              ? scheme.onSurface
              : destination!.onSurfaceSelected
        : neo
        ? tonosForegroundForSurface(
            context,
            recordActionFill,
            parentSurface: surfaces.exerciseDetailRecord,
          )
        : scheme.secondary;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dateLabel = expressive
        ? LocalizedFormatters.date(record.displayDateTime, locale)
        : LocalizedFormatters.dateTime(record.displayDateTime, locale);
    final timeLabel = LocalizedFormatters.time(record.displayDateTime, locale);
    final setCount = record.sets.length;
    final actionVisual = Container(
      key: catalogBrowserRefinement
          ? const ValueKey('exercise-detail-expressive-session-action-surface')
          : null,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: recordActionFill,
        borderRadius: shapes.exerciseDetailRecordAction,
        border: catalogBrowserRefinement
            ? Border.all(color: scheme.outlineVariant)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              strings.exerciseDetailSetCount(setCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: recordActionForeground,
                fontWeight: FontWeight.w800,
              ),
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
    );

    return Container(
      padding: EdgeInsets.all(catalogBrowserRefinement ? 11 : 12),
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
              if (expressive) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (catalogBrowserRefinement)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dateLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timeLabel,
                              maxLines: 1,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        Text(
                          dateLabel,
                          softWrap: true,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (record.badges.isFirstRecord) ...[
                        SizedBox(height: catalogBrowserRefinement ? 4 : 6),
                        _ExpressiveFirstRecordBadge(
                          tokens: destination!,
                          label: strings.recordFirst,
                          compact: catalogBrowserRefinement,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  container: true,
                  button: true,
                  label: strings.exerciseDetailOpenWorkoutWithSets(setCount),
                  onTap: onOpenSession,
                  excludeSemantics: true,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: shapes.exerciseDetailRecordAction,
                    child: InkWell(
                      key: const ValueKey(
                        'exercise-detail-expressive-session-action',
                      ),
                      onTap: onOpenSession,
                      borderRadius: shapes.exerciseDetailRecordAction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                          maxWidth: 100,
                        ),
                        child: catalogBrowserRefinement
                            ? Center(
                                widthFactor: 1,
                                heightFactor: 1,
                                child: actionVisual,
                              )
                            : actionVisual,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: neo ? recordForeground : scheme.primary,
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
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
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
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: catalogBrowserRefinement ? 6 : 10,
            ),
            child: const Divider(height: 1),
          ),
          for (final entry in record.sets.asMap().entries)
            _ExerciseHistorySetRow(
              index: entry.key + 1,
              set: entry.value,
              badges: record.badges.forSet(entry.key),
              weightUnit: weightUnit,
              expressive: expressive,
              catalogBrowserRefinement: catalogBrowserRefinement,
              recordSurface: recordSurface,
              destination: destination,
            ),
        ],
      ),
    );
  }
}

class _ExpressiveFirstRecordBadge extends StatelessWidget {
  final AppExpressiveDestinationTokens tokens;
  final String label;
  final bool compact;

  const _ExpressiveFirstRecordBadge({
    required this.tokens,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      key: const ValueKey('exercise-detail-expressive-first-record-badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceSelected,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: tokens.outlineAccent.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tokens.onSurfaceSelected,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _ExerciseHistorySetRow extends StatelessWidget {
  final int index;
  final ExerciseSet set;
  final List<WorkoutRecordBadge> badges;
  final WeightUnit weightUnit;
  final bool expressive;
  final Color recordSurface;
  final AppExpressiveDestinationTokens? destination;
  final bool catalogBrowserRefinement;

  const _ExerciseHistorySetRow({
    required this.index,
    required this.set,
    required this.badges,
    required this.weightUnit,
    this.expressive = false,
    this.recordSurface = Colors.transparent,
    this.destination,
    this.catalogBrowserRefinement = false,
  });

  Widget _buildSetIndex(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    Color recordForeground,
  ) => Container(
    width: 25,
    height: 25,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: expressive
          ? destination?.surfaceSelected
          : scheme.primary.withValues(
              alpha: theme.surfaceTokens.exerciseDetailRecordSetFillOpacity,
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
            : context.usesNeoPresentation
            ? recordForeground
            : scheme.primary,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

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

    if (catalogBrowserRefinement && badges.isNotEmpty) {
      final localizedSet = _formatSet(
        set,
        weightUnit,
        locale: Localizations.localeOf(context),
        omitNonPositiveWeight: expressive,
        repsLabel: AppLocalizations.of(context).exerciseDetailReps,
      );
      final hasEstimatedOneRm =
          set.reps > 0 &&
          set.weight.isFinite &&
          set.weight > 0 &&
          _estimatedOneRm(set).isFinite &&
          _estimatedOneRm(set) > 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSetIndex(context, theme, scheme, recordForeground),
            const SizedBox(width: 8),
            Expanded(
              flex: hasEstimatedOneRm ? 4 : 5,
              child: FittedBox(
                key: const ValueKey('exercise-detail-record-set-details'),
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizedSet,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: neo ? recordForeground : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: hasEstimatedOneRm ? 5 : 6,
              child: FittedBox(
                key: const ValueKey('exercise-detail-record-set-badges'),
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < badges.length; index++) ...[
                      if (index > 0) const SizedBox(width: 3),
                      WorkoutRecordBadgeChip(
                        badge: badges[index],
                        compact: true,
                        catalogBrowserRefinement: true,
                        foregroundSurface: recordSurface,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (hasEstimatedOneRm) ...[
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      key: const ValueKey(
                        'exercise-detail-record-estimated-max',
                      ),
                      AppLocalizations.of(context).exerciseDetailEstimatedMax(
                        WeightUnitFormatter.formatWeight(
                          _estimatedOneRm(set),
                          weightUnit,
                          locale: Localizations.localeOf(context),
                        ),
                      ),
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: recordSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: catalogBrowserRefinement ? 3 : 4),
      child: Row(
        children: [
          _buildSetIndex(context, theme, scheme, recordForeground),
          const SizedBox(width: 10),
          if (badges.isEmpty)
            Expanded(
              child: Text(
                _formatSet(
                  set,
                  weightUnit,
                  locale: Localizations.localeOf(context),
                  omitNonPositiveWeight: expressive,
                  repsLabel: AppLocalizations.of(context).exerciseDetailReps,
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
                  omitNonPositiveWeight: expressive,
                  repsLabel: AppLocalizations.of(context).exerciseDetailReps,
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
                          compact: catalogBrowserRefinement,
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
          if (!expressive ||
              (set.reps > 0 &&
                  set.weight.isFinite &&
                  set.weight > 0 &&
                  _estimatedOneRm(set).isFinite &&
                  _estimatedOneRm(set) > 0))
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
