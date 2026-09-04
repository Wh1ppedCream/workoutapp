// File: lib/widgets/data_records_section.dart

import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../screens/nutrition/log_entry_page.dart';

import '../theme/theme_extensions.dart';
import '../utils/localized_formatters.dart';

/// A calendar‐style grid plus summary for “Data & Records”.
class DataRecordsSection extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const DataRecordsSection({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final colors = context.colors;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final dayLabels = List.generate(
      DateTime.daysPerWeek,
      (index) => LocalizedFormatters.weekdayNarrow(
        monday.add(Duration(days: index)),
        locale,
      ),
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.dashboardSectionDataRecordsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // ─── New: Day‐of‐week header ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  dayLabels.map((lbl) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          lbl,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
              children: List.generate(28, (i) {
                final date = today.subtract(Duration(days: 27 - i));
                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return Semantics(
                  button: true,
                  label: LocalizedFormatters.longDate(date, locale),
                  child: GestureDetector(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LogEntryPage(date: date),
                          ),
                        ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isToday
                                ? colors.dataRecordsTodayBg!.withValues(
                                  alpha: 0.2,
                                )
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              isToday
                                  ? colors.dataRecordsTodayBorder!
                                  : colors.dataRecordsDefaultBorder!,
                        ),
                      ),
                      child: Text(
                        LocalizedFormatters.number(
                          date.day,
                          locale,
                          maximumFractionDigits: 0,
                        ),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isToday ? colors.dataRecordsTodayText! : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  strings.dashboardRecordsThisWeek(1, 7),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Flexible(
                child: Text(
                  strings.dashboardRecordsAllTime(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colors.dataRecordsChevron!.withValues(alpha: 0.45),
              ),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}
