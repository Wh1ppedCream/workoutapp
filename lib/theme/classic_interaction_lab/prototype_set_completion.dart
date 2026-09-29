import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';

/// Compares the compact current checkbox with a standard 48 dp Material target.
///
/// Both rows are local demonstration state. The weight and rep values are
/// representative of a Tonos set row; no workout model or repository is read.
class SetCompletionPrototype extends StatefulWidget {
  const SetCompletionPrototype({super.key});

  @override
  State<SetCompletionPrototype> createState() => _SetCompletionPrototypeState();
}

class _SetCompletionPrototypeState extends State<SetCompletionPrototype> {
  bool _baselineComplete = false;
  bool _candidateComplete = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('set-completion-prototype'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Set completion', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _ComparisonPanel(
          title: 'A · Current Material',
          detail: 'Compact checkbox',
          child: _SetCompletionRow(
            key: const ValueKey('set-completion-baseline-row'),
            completed: _baselineComplete,
            candidate: false,
            onChanged: (value) => setState(() => _baselineComplete = value),
          ),
        ),
        const SizedBox(height: 10),
        _ComparisonPanel(
          title: 'B · Material Checkbox',
          detail: 'standard 48 dp target',
          child: _SetCompletionRow(
            key: const ValueKey('set-completion-candidate-row'),
            completed: _candidateComplete,
            candidate: true,
            onChanged: (value) => setState(() => _candidateComplete = value),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Both controls use Tonos completion green. The second uses the '
          'standard Material touch target; the fields and set-row content stay unchanged.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ComparisonPanel extends StatelessWidget {
  const _ComparisonPanel({
    required this.title,
    required this.detail,
    required this.child,
  });

  final String title;
  final String detail;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final heading = Text(title, style: theme.textTheme.labelLarge);
    final note = Text(detail, style: theme.textTheme.labelSmall);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: theme.shapeTokens.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (textScale > 1.15) ...[
            heading,
            const SizedBox(height: 2),
            note,
          ] else
            Row(
              children: [
                Expanded(child: heading),
                const SizedBox(width: 6),
                note,
              ],
            ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _SetCompletionRow extends StatelessWidget {
  const _SetCompletionRow({
    super.key,
    required this.completed,
    required this.candidate,
    required this.onChanged,
  });

  final bool completed;
  final bool candidate;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final controlWidth = candidate ? 48.0 : 40.0;
    final rowSurface = theme.colorScheme.surface;
    final completedFill = Color.alphaBlend(
      semantic.workoutSetCompleted.withValues(
        alpha: theme.surfaceTokens.workoutSetCompleteFill,
      ),
      rowSurface,
    );

    final checkbox = Checkbox(
      key: ValueKey(
        candidate
            ? 'set-completion-material-checkbox'
            : 'set-completion-baseline-checkbox',
      ),
      value: completed,
      semanticLabel: candidate ? 'Material set 1' : 'Current Material set 1',
      activeColor: semantic.workoutCompleted,
      visualDensity: candidate ? VisualDensity.standard : VisualDensity.compact,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final fields = _WeightAndRepsFields(stacked: textScale > 1.15);

    return Container(
      key: ValueKey(
        candidate
            ? 'set-completion-candidate-row-content'
            : 'set-completion-baseline-row-content',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: completed ? completedFill : rowSurface,
        borderRadius: theme.shapeTokens.control,
      ),
      child: Row(
        key: ValueKey(
          candidate
              ? 'set-completion-candidate-row-layout'
              : 'set-completion-baseline-row-layout',
        ),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: controlWidth,
            child: Align(alignment: Alignment.centerLeft, child: checkbox),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 48,
            child: Text(
              'Set 1',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: fields),
        ],
      ),
    );
  }
}

class _WeightAndRepsFields extends StatelessWidget {
  const _WeightAndRepsFields({this.stacked = false});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final fields = const [
      _SetValue(label: 'Weight (lbs)', value: '15'),
      _SetValue(label: 'Reps', value: '10'),
    ];
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [fields[0], const SizedBox(height: 6), fields[1]],
      );
    }
    return Row(
      children: [
        Expanded(child: fields[0]),
        const SizedBox(width: 8),
        Expanded(child: fields[1]),
      ],
    );
  }
}

class _SetValue extends StatelessWidget {
  const _SetValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.semanticColors.mutedContent,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 2, bottom: 1),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
