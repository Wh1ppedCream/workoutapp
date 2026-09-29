import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../widgets/tonos_train_tabs.dart';

/// Compares the production Train selector with standard Material selection.
class TrainTabsPrototype extends StatefulWidget {
  const TrainTabsPrototype({super.key});

  @override
  State<TrainTabsPrototype> createState() => _TrainTabsPrototypeState();
}

class _TrainTabsPrototypeState extends State<TrainTabsPrototype> {
  int _tonosSelection = 0;
  int _materialSelection = 0;

  @override
  Widget build(BuildContext context) {
    final tonosHeight = TonosTrainTabs.preferredHeight(context);
    return Column(
      key: const ValueKey('train-tabs-interaction-prototype'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Train tab selection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _ComparisonRow(
          title: 'A · TonosTrainTabs',
          detail: '${tonosHeight.toStringAsFixed(0)} dp frame',
          child: _sizedControl(
            context,
            key: const ValueKey('train-tabs-baseline-control'),
            height: tonosHeight,
            child: TonosTrainTabs(
              overviewLabel: 'Overview',
              plansLabel: 'Plans',
              selectedIndex: _tonosSelection,
              onChanged: (index) => setState(() => _tonosSelection = index),
              overviewKey: const ValueKey('train-tabs-baseline-overview'),
              plansKey: const ValueKey('train-tabs-baseline-plans'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ComparisonRow(
          title: 'B · SegmentedButton',
          detail: 'standard Material',
          child: _sizedControl(
            context,
            key: const ValueKey('train-tabs-material-control'),
            height: 48,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('Overview')),
                ButtonSegment<int>(value: 1, label: Text('Plans')),
              ],
              selected: {_materialSelection},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _materialSelection = selection.single),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Both choices keep Overview and Plans in place. Compare the '
          'compact Tonos frame with the standard 48 dp Material target.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _sizedControl(
    BuildContext context, {
    required Key key,
    required double height,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? math.min(320, constraints.maxWidth).toDouble()
            : 320.0;
        return SizedBox(key: key, width: width, height: height, child: child);
      },
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.title,
    required this.detail,
    required this.child,
  });

  final String title;
  final String detail;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.labelLarge),
          ),
          Text(detail, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
      const SizedBox(height: 4),
      child,
    ],
  );
}
