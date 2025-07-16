// File: lib/widgets/data_records_section.dart

import 'package:flutter/material.dart';
import '../screens/nutrition/log_entry_page.dart';

/// A calendar‐style grid plus summary for “Data & Records”.
class DataRecordsSection extends StatelessWidget {
  const DataRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

// Two‐letter labels for Monday–Sunday
    const dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data & Records', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // ─── New: Day‐of‐week header ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: dayLabels.map((lbl) {
                return Expanded(
                  child: Center(
                    child: Text(lbl, style: Theme.of(context).textTheme.bodySmall),
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
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
              children: List.generate(28, (i) {
                final date = today.subtract(Duration(days: 27 - i));
                final isToday = date.year == today.year
                    && date.month == today.month
                    && date.day == today.day;

                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LogEntryPage(date: date)),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isToday ? Colors.green : Colors.grey[400]!,
                      ),
                    ),
                   child: Text(
                      '${date.day}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: isToday ? Colors.green : null),
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
              Text('1/7 this week', style: Theme.of(context).textTheme.bodySmall),
              Text('1 all time',    style: Theme.of(context).textTheme.bodySmall),
              GestureDetector(onTap: () { /* TODO */ }, child: const Icon(Icons.chevron_right, size: 16)),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}
