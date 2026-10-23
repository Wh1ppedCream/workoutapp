// File: lib/widgets/data_records_section.dart

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../screens/nutrition/log_entry_page.dart';

import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../utils/localized_formatters.dart';

/// A calendar‐style grid plus summary for “Data & Records”.
class DataRecordsSection extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final DateTime? referenceDate;

  const DataRecordsSection({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = referenceDate ?? DateTime.now();
    final theme = Theme.of(context);
    final surfaces = context.surfaceTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    final expressiveNutrition =
        context.usesExpressivePresentation &&
        destination?.family == AppExpressiveDestinationFamily.nutrition;
    final expressiveTokens = expressiveNutrition ? destination : null;
    final dark = theme.brightness == Brightness.dark;
    final calendarDayBorder =
        context.surfaceDecorationTokens.panel.outlined &&
            theme.brightness == Brightness.dark
        ? surfaces.neutralOutline
        : surfaces.divider;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    final firstDate = DateTime(today.year, today.month, today.day - 27);
    final dayLabels = List.generate(
      DateTime.daysPerWeek,
      (index) => LocalizedFormatters.weekdayNarrow(
        DateTime(firstDate.year, firstDate.month, firstDate.day + index),
        locale,
      ),
    );

    final weekdayLabels = Padding(
      padding: EdgeInsets.symmetric(horizontal: expressiveNutrition ? 4 : 16),
      child: Row(
        children: dayLabels.map((label) {
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: expressiveTokens?.supportingForeground,
                  fontWeight: expressiveNutrition ? FontWeight.w700 : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    final calendarDays = Padding(
      padding: EdgeInsets.symmetric(horizontal: expressiveNutrition ? 4 : 16),
      child: GridView.count(
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
        children: List.generate(28, (i) {
          final date = DateTime(
            firstDate.year,
            firstDate.month,
            firstDate.day + i,
          );
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return Semantics(
            button: true,
            label: LocalizedFormatters.longDate(date, locale),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LogEntryPage(date: date)),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday
                      ? expressiveTokens?.surfaceSelected ??
                            dataVisualization.recordTodayContainer
                      : Colors.transparent,
                  border: Border.all(
                    color: isToday
                        ? expressiveTokens?.outlineAccent ??
                              dataVisualization.recordTodayBorder
                        : expressiveTokens?.outlineAccent.withValues(
                                alpha: dark ? 0.30 : 0.24,
                              ) ??
                              calendarDayBorder,
                  ),
                ),
                child: Text(
                  LocalizedFormatters.number(
                    date.day,
                    locale,
                    maximumFractionDigits: 0,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? expressiveTokens?.onSurfaceSelected ??
                              dataVisualization.onRecordTodayContainer
                        : expressiveTokens?.onSurfaceTertiary,
                    fontWeight: isToday || expressiveNutrition
                        ? FontWeight.w700
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    final weekCount = strings.dashboardRecordsThisWeek(1, 7);
    final allTimeCount = strings.dashboardRecordsAllTime(1);
    Widget countChip(String label, IconData icon) {
      final tokens = expressiveTokens!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.surfaceSelected,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: tokens.outlineAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: tokens.onSurfaceSelected),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: tokens.onSurfaceSelected,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final countSummary = expressiveNutrition
        ? Row(
            children: [
              Expanded(
                child: countChip(weekCount, Icons.calendar_view_week_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(child: countChip(allTimeCount, Icons.history_rounded)),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: expressiveTokens!.outlineAccent,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  weekCount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Flexible(
                child: Text(
                  allTimeCount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: dataVisualization.label.withValues(alpha: 0.45),
              ),
            ],
          );

    final calendarContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        weekdayLabels,
        const SizedBox(height: 8),
        calendarDays,
        const SizedBox(height: 8),
        countSummary,
      ],
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.dashboardSectionDataRecordsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: expressiveTokens?.supportingForeground,
              fontWeight: expressiveNutrition ? FontWeight.w800 : null,
            ),
          ),
          const SizedBox(height: 8),
          if (expressiveTokens != null)
            Container(
              decoration: BoxDecoration(
                color: expressiveTokens.surfaceTertiary,
                borderRadius: context.shapeTokens.healthTrendCard,
                border: Border.all(
                  color: expressiveTokens.outlineAccent.withValues(
                    alpha: dark ? 0.32 : 0.22,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: calendarContent,
            )
          else ...[
            calendarContent,
            const Divider(height: 32),
          ],
        ],
      ),
    );
  }
}
