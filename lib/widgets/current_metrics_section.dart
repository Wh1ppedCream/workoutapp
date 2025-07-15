// File: lib/widgets/current_metrics_section.dart

import 'package:flutter/material.dart';

/// A single dot + value + label.
class MetricItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const MetricItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Shows “Current Metrics” with a date, three MetricItems, and footer.
class CurrentMetricsSection extends StatelessWidget {
  final DateTime lastMeasured;
  final String bodyFat;
  final String waist;
  final String hips;
  final int daysAgo;

  const CurrentMetricsSection({
    super.key,
    required this.lastMeasured,
    required this.bodyFat,
    required this.waist,
    required this.hips,
    required this.daysAgo,
  });

  @override
  Widget build(BuildContext context) {
    final fmtDate = '${lastMeasured.month}/${lastMeasured.day}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Current Metrics', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(fmtDate, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        Row(children: [
          MetricItem(color: Colors.green,  label: 'Visual Body Fat', value: bodyFat),
          const SizedBox(width: 16),
          MetricItem(color: Colors.blue,   label: 'Waist',            value: waist),
          const SizedBox(width: 16),
          MetricItem(color: Colors.purple, label: 'Hips',             value: hips),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$daysAgo days ago', style: Theme.of(context).textTheme.bodySmall),
          GestureDetector(onTap: () { /* TODO */ }, child: const Icon(Icons.chevron_right, size: 16)),
        ]),
        const Divider(height: 32),
      ]),
    );
  }
}
