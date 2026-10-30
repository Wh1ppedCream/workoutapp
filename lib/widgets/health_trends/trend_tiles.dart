part of '../health_trends_section.dart';

class _TrendTile extends StatelessWidget {
  final _MeasurementTrend trend;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool fillCell;
  final bool alternateSurface;
  final int arrivalIndex;
  final double? height;
  final bool measurementLibrary;

  const _TrendTile({
    required this.trend,
    required this.onTap,
    required this.onAdd,
    this.fillCell = false,
    this.alternateSurface = false,
    this.arrivalIndex = 0,
    this.height,
    this.measurementLibrary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final title = _measurementTitle(trend.definition, strings);
    final latest = trend.latest;
    final delta = trend.delta;
    final incompatibleUnits =
        latest != null && trend.previous != null && delta == null;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final destination = usesExpressive
        ? theme.extension<AppExpressiveDestinationTokens>()
        : null;
    final profileMeasurement =
        measurementLibrary &&
        destination?.family == AppExpressiveDestinationFamily.profile;
    final expressiveTokens = usesExpressive
        ? theme.extension<AppExpressiveTrainTokens>()!
        : null;
    final cardShape = usesExpressive ? shapes.healthTrendCard : shapes.card;
    final cardSurface = usesExpressive
        ? _expressiveHealthTrendSurface(context, alternate: alternateSurface)
        : _healthTrendCardSurface(context);
    final cardForeground = usesInkRecipe
        ? tonosForegroundForSurface(context, cardSurface)
        : usesExpressive
        ? profileMeasurement
              ? destination!.onSurfaceAccent
              : theme.colorScheme.onSurface
        : null;
    final cardSecondaryForeground = usesInkRecipe
        ? tonosSecondaryForegroundForSurface(context, cardSurface)
        : usesExpressive
        ? profileMeasurement
              ? destination!.onSurfaceAccent
              : theme.colorScheme.onSurfaceVariant
        : null;
    final deltaColor = profileMeasurement
        ? cardSecondaryForeground!
        : _deltaColor(context, delta);
    final effects = context.effectTokens;
    final borderColor = usesInkRecipe
        ? tonosOutlineForSurface(context, cardSurface)
        : surfaces.subtleOutline;
    final logButton = usesExpressive
        ? Semantics(
            key: ValueKey(
              'measurement-trend-${trend.definition.id}-log-semantics',
            ),
            container: true,
            button: true,
            label: strings.healthLogMeasurement(title),
            onTap: onAdd,
            child: ExcludeSemantics(
              child: IconButton(
                key: AppTestKeys.measurementTrendAdd(trend.definition.id),
                onPressed: onAdd,
                style: IconButton.styleFrom(
                  backgroundColor: expressiveTokens!.actionSecondary,
                  foregroundColor: expressiveTokens.actionSecondaryForeground,
                ),
                icon: Icon(
                  Icons.add,
                  color: expressiveTokens.actionSecondaryForeground,
                ),
              ),
            ),
          )
        : Semantics(
            button: true,
            label: strings.healthLogMeasurement(title),
            onTap: onAdd,
            child: ExcludeSemantics(
              child: InkResponse(
                key: AppTestKeys.measurementTrendAdd(trend.definition.id),
                onTap: onAdd,
                radius: 18,
                child: Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: cardSecondaryForeground ?? dataVisualization.label,
                ),
              ),
            ),
          );

    final card = Material(
      color: cardSurface,
      borderRadius: cardShape,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardShape,
        child: Container(
          key: AppTestKeys.measurementTrend(trend.definition.id),
          width: fillCell ? double.infinity : 154,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: usesExpressive
                ? null
                : Border.all(
                    color: borderColor,
                    width: usesInkRecipe ? shapes.outlineWidth : 1,
                  ),
            borderRadius: cardShape,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: usesInkRecipe || usesExpressive ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cardForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  logButton,
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _MeasurementSparkline(
                  definition: trend.definition,
                  entries: trend.entries,
                  lineColor: usesInkRecipe
                      ? tonosPrimarySeriesForSurface(context, cardSurface)
                      : dataVisualization.tertiarySeries,
                  emptyColor: cardSecondaryForeground,
                  useExpressiveEmptyState: usesExpressive,
                  hideEmptyPrompt: profileMeasurement && latest == null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                latest == null
                    ? strings.healthNoEntries
                    : _formatMeasurement(latest, locale),
                maxLines: usesInkRecipe ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cardForeground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latest == null
                    ? strings.healthTapToLog
                    : incompatibleUnits
                    ? strings.healthUnitsNotComparable
                    : _formatDelta(
                        delta,
                        strings,
                        locale,
                        unit:
                            profileMeasurement ||
                                trend.definition.type == MeasurementType.Height
                            ? latest.unit
                            : null,
                      ),
                maxLines: usesInkRecipe ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: usesExpressive && latest != null
                      ? deltaColor
                      : cardSecondaryForeground ?? deltaColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final tile = _withHealthCardForeground(
      context,
      usesInkRecipe
          // The opaque Material must cover the shadow's interior.
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: shapes.card,
                boxShadow: [
                  BoxShadow(
                    color: effects.cardShadow,
                    blurRadius: 0,
                    offset: effects.cardShadowOffset,
                  ),
                ],
              ),
              child: card,
            )
          : card,
      surface: cardSurface,
    );
    final sizedTile = height == null
        ? tile
        : SizedBox(height: height, child: tile);
    if (!usesExpressive) return sizedTile;
    return TonosExpressiveReveal(
      staggerIndex: arrivalIndex,
      child: TonosExpressivePressResponse(
        enabled: true,
        borderRadius: cardShape,
        pressedBorderRadius: ExpressiveTrainShapes.focusInsetPressed,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: sizedTile,
      ),
    );
  }
}

class _AddTrendTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool fillCell;
  final int arrivalIndex;

  const _AddTrendTile({
    required this.onTap,
    this.fillCell = false,
    this.arrivalIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final expressiveTokens = usesExpressive
        ? theme.extension<AppExpressiveTrainTokens>()!
        : null;
    final fill = usesInkRecipe
        ? context.cs.primary
        : usesExpressive
        ? expressiveTokens!.actionSecondary
        : Colors.transparent;
    final foreground = usesInkRecipe
        ? tonosForegroundForSurface(context, fill)
        : usesExpressive
        ? expressiveTokens!.actionSecondaryForeground
        : dataVisualization.label;
    final borderColor = usesInkRecipe
        ? tonosOutlineForSurface(context, fill)
        : surfaces.subtleOutline;
    final addTile = Semantics(
      button: true,
      label: strings.healthCreateMetric,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: fill,
          borderRadius: usesExpressive ? shapes.healthTrendEntry : shapes.card,
          child: InkWell(
            onTap: onTap,
            borderRadius: usesExpressive
                ? shapes.healthTrendEntry
                : shapes.card,
            child: Container(
              width: fillCell ? double.infinity : 132,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: usesExpressive ? null : Border.all(color: borderColor),
                borderRadius: usesExpressive
                    ? shapes.healthTrendEntry
                    : shapes.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: usesExpressive
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: foreground, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    strings.healthCustomMetric,
                    textAlign: usesExpressive
                        ? TextAlign.start
                        : TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!usesExpressive) return addTile;
    return TonosExpressiveReveal(
      staggerIndex: arrivalIndex,
      child: TonosExpressivePressResponse(
        enabled: true,
        borderRadius: shapes.healthTrendEntry,
        pressedBorderRadius: ExpressiveTrainShapes.compactControlPressed,
        pressedScale: TonosExpressiveMotionTiers.supportingScale,
        pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
        child: addTile,
      ),
    );
  }
}

class _MeasurementEntryTile extends StatelessWidget {
  final Measurement entry;
  final MeasurementType type;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MeasurementEntryTile({
    required this.entry,
    required this.type,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = context.shapeTokens;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final expressive = _progressDetailTokens(context) != null;
    final expressiveRow = _measurementDetailTokens(context) != null;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.history,
    );
    final menuSurface = expressive
        ? _measurementDetailSurface(
            context,
            role: _MeasurementDetailRole.dialog,
          )
        : null;
    final menuForeground = expressive
        ? _measurementDetailForeground(
            context,
            role: _MeasurementDetailRole.dialog,
          )
        : null;
    final foreground = expressiveRow
        ? _measurementDetailForeground(
            context,
            role: _MeasurementDetailRole.history,
          )
        : null;
    final supportingForeground = expressiveRow
        ? _measurementDetailSupportingForeground(
            context,
            role: _MeasurementDetailRole.history,
          )
        : null;
    final contextLabel = _measurementContextLabel(entry, strings, type);
    final note = _measurementNote(entry, type);
    final details = <String>[
      _formatDateTime(entry.displayDateTime, locale),
      if (contextLabel != null) contextLabel,
      if (note != null) note,
    ].join(' - ');
    return _withMeasurementDetailSurfaceTheme(
      context,
      role: _MeasurementDetailRole.history,
      child: _withHealthCardForeground(
        context,
        Card(
          key: ValueKey('measurement-trend-entry-${entry.id}'),
          color: expressiveRow ? surface : null,
          elevation: expressiveRow ? 0 : null,
          margin: EdgeInsets.symmetric(vertical: expressiveRow ? 4 : 5),
          shape: expressiveRow
              ? RoundedRectangleBorder(borderRadius: shapes.healthTrendEntry)
              : null,
          clipBehavior: expressiveRow ? Clip.antiAlias : Clip.none,
          child: ListTile(
            dense: expressiveRow,
            visualDensity: expressiveRow ? VisualDensity.compact : null,
            minTileHeight: expressiveRow ? 64 : null,
            contentPadding: expressiveRow
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 4)
                : null,
            horizontalTitleGap: expressiveRow ? 12 : null,
            leading: expressiveRow
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: foreground!.withValues(alpha: 0.08),
                      borderRadius: shapes.healthTrendEntry,
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: foreground,
                      size: 18,
                    ),
                  )
                : null,
            onTap: onTap,
            title: Text(
              _formatMeasurement(entry, locale),
              style: expressiveRow
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
            subtitle: Text(
              details,
              style: expressiveRow
                  ? Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: supportingForeground)
                  : null,
            ),
            trailing: PopupMenuButton<String>(
              popUpAnimationStyle: tonosOverlayMotion(context),
              key: ValueKey('measurement-trend-entry-actions-${entry.id}'),
              tooltip: strings.healthEntryActions,
              position: expressive ? PopupMenuPosition.over : null,
              // Two 48dp actions plus vertical menu padding leave a small gap
              // above the trigger and keep the menu clear of Log entry.
              offset: expressive ? const Offset(0, -112) : Offset.zero,
              constraints: expressive
                  ? const BoxConstraints(minWidth: 172, maxWidth: 232)
                  : null,
              menuPadding: expressive
                  ? const EdgeInsets.symmetric(vertical: 4)
                  : null,
              color: menuSurface,
              surfaceTintColor: expressive ? Colors.transparent : null,
              elevation: expressive ? 4 : null,
              shape: expressive
                  ? RoundedRectangleBorder(
                      borderRadius: ExpressiveTrainShapes.menu,
                      side: BorderSide(
                        color: _progressDetailTokens(context)!.outlineAccent
                            .withValues(alpha: 0.50),
                      ),
                    )
                  : null,
              onSelected: (value) {
                if (value == 'edit') onTap();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  height: 48,
                  child: expressive
                      ? Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: menuForeground,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).commonEdit,
                                style: expressive
                                    ? TextStyle(color: menuForeground)
                                    : null,
                              ),
                            ),
                          ],
                        )
                      : Text(AppLocalizations.of(context).commonEdit),
                ),
                PopupMenuItem(
                  value: 'delete',
                  height: 48,
                  child: expressive
                      ? Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).commonDelete,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(AppLocalizations.of(context).commonDelete),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: shapes.healthTrendEntry,
            ),
            tileColor: surface,
          ),
        ),
      ),
    );
  }
}

class _HealthTrendMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compactAction;

  const _HealthTrendMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compactAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionLabel = this.actionLabel;

    final shapes = context.shapeTokens;
    if (context.usesExpressivePresentation) {
      final expressiveTokens = Theme.of(context)
          .extension<AppExpressiveTrainTokens>()!;
      final surface = _expressiveHealthTrendSurface(context);
      final stateCard = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TonosSurfaceTheme(
          surface: surface,
          child: Material(
            color: surface,
            borderRadius: shapes.healthTrendCard,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: expressiveTokens.actionSecondary,
                          borderRadius: ExpressiveTrainShapes.compactControl,
                        ),
                        child: Icon(
                          icon,
                          color: expressiveTokens.actionSecondaryForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TonosExpressivePressResponse(
                        enabled: true,
                        borderRadius: shapes.healthTrendEntry,
                        pressedBorderRadius:
                            ExpressiveTrainShapes.compactControlPressed,
                        pressedScale: TonosExpressiveMotionTiers.compactScale,
                        pressedOffset: TonosExpressiveMotionTiers.compactOffset,
                        child: TextButton.icon(
                          onPressed: onAction,
                          icon: Icon(Icons.add, size: compactAction ? 16 : 18),
                          label: Text(actionLabel),
                          style: compactAction
                              ? TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                )
                              : TextButton.styleFrom(
                                  backgroundColor:
                                      expressiveTokens.actionSecondary,
                                  foregroundColor: expressiveTokens
                                      .actionSecondaryForeground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: shapes.healthTrendEntry,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      return TonosExpressiveReveal(child: stateCard);
    }

    final foreground = context.usesNeoPresentation
        ? tonosForegroundForSurface(context, _healthTrendCardSurface(context))
        : theme.colorScheme.onSurface;
    return _withHealthCardForeground(
      context,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _healthTrendCardSurface(context),
            borderRadius: shapes.healthTrendCard,
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.usesNeoPresentation
                            ? tonosSecondaryForegroundForSurface(
                                context,
                                _healthTrendCardSurface(context),
                              )
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: compactAction
                        ? theme.colorScheme.onSurfaceVariant
                        : foreground,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
