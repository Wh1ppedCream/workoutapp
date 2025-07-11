// File: lib/screens/log_entry_page.dart

import 'package:flutter/material.dart';
import '../../widgets/speed_dial_fab.dart';

/// A daily log view: header with date + macros, then hourly timeline.
class LogEntryPage extends StatelessWidget {
  final DateTime date;

  const LogEntryPage({
    super.key,
    required this.date,
  });

  String _hourLabel(int hour) {
    if (hour == 0) return '12 a.m.';
    if (hour < 12) return '$hour a.m.';
    if (hour == 12) return '12 p.m.';
    return '${hour - 12} p.m.';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: wire these to your real daily summary values
    final consumedCal = 1200, calTarget = 2000;
    final consumedFat =  30, fatTarget =  70;
    final consumedP   =  50, pTarget   = 100;
    final consumedC   = 120, cTarget   = 200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${date.month}/${date.day}/${date.year}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          // ─── Header Stats ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Calories',
                    value: '$consumedCal/$calTarget kcal',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStat(
                    label: 'Fats',
                    value: '$consumedFat/$fatTarget g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStat(
                    label: 'Protein',
                    value: '$consumedP/$pTarget g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStat(
                    label: 'Carbs',
                    value: '$consumedC/$cTarget g',
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ─── 24-Hour Timeline ───────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, hour) {
                return SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      // Time label
                      SizedBox(
                        width: 72,
                        child: Text(
                          _hourLabel(hour),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      // Vertical divider
                      const VerticalDivider(width: 1),
                      // Empty slot for entries
                      Expanded(
                        child: Container(
                          // TODO: render meal/workout entries here at correct vertical positions
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const SpeedDialFab(),

    );
  }
}

/// A very compact stat card for the header row.
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    // ignore: unused_element_parameter
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
