// File: lib/screens/nutrition/log_entry_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/theme_extensions.dart';

import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/nutrition_profile.dart';
import '../../models/nutrition_models.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../widgets/speed_dial_fab.dart';

class LogEntryPage extends StatefulWidget {
  final DateTime date;
  const LogEntryPage({super.key, required this.date});

  @override
  State<LogEntryPage> createState() => _LogEntryPageState();
}

class _LogEntryPageState extends State<LogEntryPage> {
  final _scroll = ScrollController();
  bool _didSyncDay = false;

  static const double _rowHeight = 64; // 24 rows → 1536px scroll height
  static const double _gutterW = 72; // time labels
  static const double _chipH = 52; // keep
  static const double _chipW = 195; // NEW: fixed width for each entry chip

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSyncDay) return;
    final p = context.read<NutritionProfile>();
    // Defer notification until provider mounting has finished.
    _didSyncDay = true;

    // If viewing today, auto-scroll near “now” after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await p.setDay(widget.date);
      if (!mounted) return;
      if (p.isToday && _scroll.hasClients) {
        final now = DateTime.now();
        final minutes = now.hour * 60 + now.minute;
        final totalH = 24 * _rowHeight;
        final targetOffset = math.max(0, (minutes / (24 * 60)) * totalH - 200);
        final maxExtent = _scroll.position.maxScrollExtent;
        _scroll.jumpTo(
          targetOffset.clamp(0, maxExtent).toDouble(),
        ); // ← cast to double
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _hourLabel(BuildContext context, int hour) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: hour, minute: 0));
  }

  Color _mealFill(MealType m, ColorScheme cs) {
    // Solid container colors work well in Material 3
    switch (m) {
      case MealType.breakfast:
        return cs.primaryContainer;
      case MealType.lunch:
        return cs.tertiaryContainer;
      case MealType.dinner:
        return cs.secondaryContainer;
      case MealType.snack:
        return cs.errorContainer;
    }
  }

  Color _mealOnFill(MealType m, ColorScheme cs) {
    switch (m) {
      case MealType.breakfast:
        return cs.onPrimaryContainer;
      case MealType.lunch:
        return cs.onTertiaryContainer;
      case MealType.dinner:
        return cs.onSecondaryContainer;
      case MealType.snack:
        return cs.onErrorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.usesExpressivePresentation) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.nutrition,
        child: Builder(
          builder: (scopedContext) =>
              _buildPage(scopedContext, expressive: true),
        ),
      );
    }
    return _buildPage(context, expressive: false);
  }

  Widget _buildPage(BuildContext context, {required bool expressive}) {
    final p = context.watch<NutritionProfile>();
    final cs = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final destination = expressive
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    // Header stats (from provider)
    final kcal = (p.totals?.kcal ?? 0).round();
    final kcalTgt = (p.activeGoal?.kcalTarget ?? 0).round();
    final fat = (p.totals?.fatG ?? 0).round();
    final fatTgt = (p.activeGoal?.fatG ?? 0).round();
    final pro = (p.totals?.proteinG ?? 0).round();
    final proTgt = (p.activeGoal?.proteinG ?? 0).round();
    final carb = (p.totals?.carbsG ?? 0).round();
    final carbTgt = (p.activeGoal?.carbsG ?? 0).round();

    final date = widget.date;
    final title = MaterialLocalizations.of(context).formatMediumDate(date);

    return Scaffold(
      backgroundColor: destination?.pageCanvas,
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: destination?.onSurfacePrimary,
          ),
        ),
        backgroundColor: destination?.surfacePrimary,
        foregroundColor: destination?.onSurfacePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: expressive ? 960 : double.infinity,
          ),
          child: Column(
            children: [
          // ── Header stats ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: expressive
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 8) / 2;
                      final cards = <_MiniStat>[
                        _MiniStat(
                          label: strings.nutritionCaloriesLabel,
                          value: '$kcal / $kcalTgt kcal',
                          expressive: true,
                          surface: destination!.surfaceTertiary,
                          foreground: destination.onSurfaceTertiary,
                        ),
                        _MiniStat(
                          label: strings.nutritionFatLabel,
                          value: '$fat / $fatTgt g',
                          expressive: true,
                          surface: destination.surfaceSecondary,
                          foreground: destination.onSurfaceSecondary,
                        ),
                        _MiniStat(
                          label: strings.nutritionProteinLabel,
                          value: '$pro / $proTgt g',
                          expressive: true,
                          surface: destination.surfaceAccent,
                          foreground: destination.onSurfaceAccent,
                        ),
                        _MiniStat(
                          label: strings.nutritionCarbsLabel,
                          value: '$carb / $carbTgt g',
                          expressive: true,
                          surface: destination.surfaceSelected,
                          foreground: destination.onSurfaceSelected,
                        ),
                      ];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final card in cards)
                            SizedBox(width: cardWidth, child: card),
                        ],
                      );
                    },
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: strings.nutritionCaloriesLabel,
                          value: '$kcal / $kcalTgt kcal',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                          label: strings.nutritionFatLabel,
                          value: '$fat / $fatTgt g',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                          label: strings.nutritionProteinLabel,
                          value: '$pro / $proTgt g',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                          label: strings.nutritionCarbsLabel,
                          value: '$carb / $carbTgt g',
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1),

          // ── 24-hr timeline (stacked) ─────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, bx) {
                final totalHeight = 24 * _rowHeight;
                final chipHeight = expressive && textScale > 1.15
                    ? math.max(_chipH, 64 * textScale)
                    : _chipH;
                final chipWidth = expressive
                    ? math.max(_chipW, bx.maxWidth - _gutterW - 17)
                    : _chipW;

                // Hour lines + labels
                final hourLines = List<Widget>.generate(24, (h) {
                  final top = h * _rowHeight;
                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    height: _rowHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: _gutterW,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _hourLabel(context, h),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: context.nutritionTokens.logGrid,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });

                // “Now” indicator (only when viewing today)
                final nowLine = <Widget>[];
                if (p.isToday) {
                  final now = DateTime.now();
                  final minutes = now.hour * 60 + now.minute;
                  final y = (minutes / (24 * 60)) * totalHeight;
                  nowLine.add(
                    Positioned(
                      top: y,
                      left: _gutterW + 1,
                      right: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(height: 2, color: cs.primary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ── Side-by-side layout with LEFT origin + horizontal scroll per time bucket ──
                final chips = <Widget>[];
                const bucketSizeMin = 5; // group items within 5 minutes
                const innerGap = 8.0; // gap between chips in the row

                int bucketKeyFor(DateTime stamp) {
                  final mins = stamp.hour * 60 + stamp.minute;
                  return mins ~/ bucketSizeMin;
                }

                // 1) Bucket ALL entries by time bucket (ignore meal for positioning)
                final buckets = <int, List<DiaryEntryWithItem>>{};
                for (final row in p.mealsWithItems) {
                  final e = row.entry;
                  final stamp = (e.loggedAt ?? date).toLocal();
                  buckets
                      .putIfAbsent(
                        bucketKeyFor(stamp),
                        () => <DiaryEntryWithItem>[],
                      )
                      .add(row);
                }

                final bucketKeys = buckets.keys.toList()..sort();
                final useChronologicalDetails =
                    expressive &&
                    textScale >= 1.5 &&
                    bucketKeys.asMap().entries.any((entry) {
                      if (entry.key == 0) return false;
                      final previous = bucketKeys[entry.key - 1];
                      final minutesApart =
                          (entry.value - previous) * bucketSizeMin;
                      final verticalGap = (minutesApart / 60) * _rowHeight;
                      return verticalGap < chipHeight;
                    });

                String macroSummary(DiaryEntryWithItem row) {
                  final macros = row.snapshotMacros;
                  if (macros == null) return '';
                  return strings.nutritionMacroSummary(
                    macros.kcal.round(),
                    macros.proteinG.round(),
                    macros.carbsG.round(),
                    macros.fatG.round(),
                  );
                }

                final chronologicalRows = p.mealsWithItems.toList()
                  ..sort((a, b) {
                    final ta = (a.entry.loggedAt ?? date).toLocal();
                    final tb = (b.entry.loggedAt ?? date).toLocal();
                    final comparison = ta.compareTo(tb);
                    if (comparison != 0) return comparison;
                    return (a.entry.id ?? 0).compareTo(b.entry.id ?? 0);
                  });

                // 2) For each bucket, place a horizontally scrollable row that starts at the LEFT edge
                buckets.forEach((key, entries) {
                  // Stable order within the bucket
                  entries.sort((a, b) {
                    final ta = (a.entry.loggedAt ?? date).toLocal();
                    final tb = (b.entry.loggedAt ?? date).toLocal();
                    final c = ta.compareTo(tb);
                    if (c != 0) return c;
                    return (a.entry.id ?? 0).compareTo(b.entry.id ?? 0);
                  });

                  final bucketMinutes = key * bucketSizeMin;
                  final y =
                      (bucketMinutes / (24 * 60)) * totalHeight -
                      (chipHeight / 2);

                  if (useChronologicalDetails) {
                    for (final row in entries) {
                      final stamp = (row.entry.loggedAt ?? date).toLocal();
                      final minutes = stamp.hour * 60 + stamp.minute;
                      final markerY = (minutes / (24 * 60)) * totalHeight - 1;
                      final time = MaterialLocalizations.of(context)
                          .formatTimeOfDay(TimeOfDay.fromDateTime(stamp));
                      chips.add(
                        Positioned(
                          top: markerY.clamp(0, totalHeight - 2).toDouble(),
                          left: _gutterW + 1,
                          right: 0,
                          height: 2,
                          child: Semantics(
                            label:
                                '$time, ${row.chipTitle}, ${macroSummary(row)}',
                            child: IgnorePointer(
                              child: ColoredBox(
                                color: _mealFill(row.entry.mealType, cs),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  chips.add(
                    Positioned(
                      top: (y.clamp(
                        4,
                        totalHeight - chipHeight - 4,
                      )).toDouble(),
                      left: _gutterW + 1,
                      right: 0,
                      height: chipHeight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Row(
                          children: [
                            for (final row in entries) ...[
                              SizedBox(
                                width: chipWidth,
                                child: _EntryChip(
                                  // 👇 First line: FOOD / RECIPE NAME
                                  title: row.chipTitle,

                                  // Second line: macros (reuse your existing formatter)
                                  subtitle: macroSummary(row),

                                  bg: _mealFill(row.entry.mealType, cs),
                                  fg: _mealOnFill(row.entry.mealType, cs),
                                  expressive: expressive,
                                  onTap: () =>
                                      _showEntryActions(context, row.entry),
                                ),
                              ),
                              const SizedBox(width: innerGap),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                });

                final timeline = SizedBox(
                  height: totalHeight,
                  child: Stack(children: [...hourLines, ...nowLine, ...chips]),
                );
                final content = useChronologicalDetails
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          timeline,
                          const Divider(height: 1),
                          for (final row in chronologicalRows)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: _EntryChip(
                                title:
                                    '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime((row.entry.loggedAt ?? date).toLocal()))} · ${row.chipTitle}',
                                subtitle: macroSummary(row),
                                bg: _mealFill(row.entry.mealType, cs),
                                fg: _mealOnFill(row.entry.mealType, cs),
                                expressive: true,
                                onTap: () =>
                                    _showEntryActions(context, row.entry),
                              ),
                            ),
                        ],
                      )
                    : timeline;

                return Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: totalHeight),
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
            ],
          ),
        ),
      ),

      // Keep your existing SpeedDial without unsupported params
      floatingActionButton: const SpeedDialFab(),
    );
  }

  Future<void> _showEntryActions(BuildContext context, DiaryEntry e) async {
    final prof = context.read<NutritionProfile>();
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(strings.nutritionEditEntry),
              onTap: () async {
                Navigator.pop(context);
                messenger.showSnackBar(
                  SnackBar(content: Text(strings.nutritionEditNotAvailable)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(strings.commonDelete),
              onTap: () async {
                Navigator.pop(context);
                if (e.id != null) {
                  await prof.deleteEntry(e.id!);
                  await prof.reloadIfToday();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text(strings.nutritionEntryDeleted)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact stat card
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool expressive;
  final Color? surface;
  final Color? foreground;

  const _MiniStat({
    required this.label,
    required this.value,
    this.expressive = false,
    this.surface,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (expressive) {
      return Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: context.nutritionTokens.foodBorder),
          borderRadius: context.nutritionTokens.compactShape,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              softWrap: true,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              softWrap: true,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ), // no vertical padding
        decoration: BoxDecoration(
          border: Border.all(color: context.nutritionTokens.foodBorder),
          borderRadius: context.nutritionTokens.quantityShape,
        ),
        // Prevent system text scaling from pushing us over 36px
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$label\n'),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              // Tight line height so 2 lines fit comfortably
              style: theme.textTheme.labelSmall?.copyWith(height: 1.0),
              textAlign: TextAlign.left,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              strutStyle: const StrutStyle(height: 1.0, leading: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final bool expressive;

  const _EntryChip({
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.expressive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: expressive
            ? context.nutritionTokens.portionShape
            : context.nutritionTokens.sectionShape,
      ),
      clipBehavior: Clip.hardEdge, // <- clip any accidental overflow
      child: expressive
          ? InkWell(
              borderRadius: context.nutritionTokens.portionShape,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$title\n',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: fg.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            )
          : MediaQuery(
              // <- prevent system text scaling from breaking fixed height
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: InkWell(
                borderRadius: context.nutritionTokens.sectionShape,
                onTap: onTap,
                child: Padding(
                  // keep this modest so content fits in _chipH
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$title\n',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: fg,
                            ),
                          ),
                          TextSpan(
                            text: subtitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: fg.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // tight line height so 2 lines always fit in _chipH
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      strutStyle: const StrutStyle(height: 1.0, leading: 0),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
