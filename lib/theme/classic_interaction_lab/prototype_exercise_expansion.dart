import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';

/// Compares current immediate disclosure with a restrained standard-Material
/// AnimatedSize recipe. Every value is local fixture state.
class ExerciseExpansionPrototype extends StatefulWidget {
  const ExerciseExpansionPrototype({super.key});

  @override
  State<ExerciseExpansionPrototype> createState() =>
      _ExerciseExpansionPrototypeState();
}

class _ExerciseExpansionPrototypeState
    extends State<ExerciseExpansionPrototype> {
  bool _currentExpanded = true;
  bool _animatedExpanded = true;
  int _currentSetCount = 2;
  int _animatedSetCount = 2;
  Set<int> _currentCompleted = {1};
  Set<int> _animatedCompleted = {1};

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Column(
      key: const ValueKey('exercise-expansion-prototype'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Exercise-card expansion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Same local exercise and set-row fixture. No workout data is read or saved.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        _ExercisePanel(
          title: 'A · Current disclosure',
          detail: 'immediate',
          prefix: 'current',
          expanded: _currentExpanded,
          setCount: _currentSetCount,
          completedSets: _currentCompleted,
          duration: Duration.zero,
          onToggle: () => setState(() => _currentExpanded = !_currentExpanded),
          onSetChanged: (number, complete) =>
              _setCompleted(number, complete, animated: false),
          onAddSet: () => setState(() => _currentSetCount++),
        ),
        const SizedBox(height: 10),
        _ExercisePanel(
          title: 'B · AnimatedSize',
          detail: reduceMotion
              ? 'immediate, reduced motion'
              : '180 ms, no spring',
          prefix: 'animated',
          expanded: _animatedExpanded,
          setCount: _animatedSetCount,
          completedSets: _animatedCompleted,
          duration: duration,
          onToggle: () =>
              setState(() => _animatedExpanded = !_animatedExpanded),
          onSetChanged: (number, complete) =>
              _setCompleted(number, complete, animated: true),
          onAddSet: () => setState(() => _animatedSetCount++),
        ),
      ],
    );
  }

  void _setCompleted(int number, bool complete, {required bool animated}) {
    setState(() {
      final completed = Set<int>.from(
        animated ? _animatedCompleted : _currentCompleted,
      );
      final count = animated ? _animatedSetCount : _currentSetCount;
      if (complete) {
        completed.add(number);
      } else {
        completed.remove(number);
      }
      if (animated) {
        _animatedCompleted = completed;
        if (count > 0 && completed.length >= count) _animatedExpanded = false;
      } else {
        _currentCompleted = completed;
        if (count > 0 && completed.length >= count) _currentExpanded = false;
      }
    });
  }
}

class _ExercisePanel extends StatelessWidget {
  const _ExercisePanel({
    required this.title,
    required this.detail,
    required this.prefix,
    required this.expanded,
    required this.setCount,
    required this.completedSets,
    required this.duration,
    required this.onToggle,
    required this.onSetChanged,
    required this.onAddSet,
  });

  final String title;
  final String detail;
  final String prefix;
  final bool expanded;
  final int setCount;
  final Set<int> completedSets;
  final Duration duration;
  final VoidCallback onToggle;
  final void Function(int number, bool complete) onSetChanged;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sets = Column(
      key: ValueKey('exercise-expansion-$prefix-sets'),
      children: [
        const Divider(height: 16),
        for (var number = 1; number <= setCount; number++) ...[
          if (number > 1) const SizedBox(height: 8),
          _SetRow(
            prefix: prefix,
            number: number,
            completed: completedSets.contains(number),
            onChanged: (complete) => onSetChanged(number, complete),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: ValueKey('exercise-expansion-$prefix-add-set'),
            onPressed: onAddSet,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Set'),
          ),
        ),
      ],
    );
    return Card(
      key: ValueKey('exercise-expansion-$prefix-card'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  key: ValueKey('exercise-expansion-$prefix-toggle'),
                  tooltip: expanded ? 'Collapse sets' : 'Expand sets',
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggle,
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arnold Press', style: theme.textTheme.titleMedium),
                      Text(
                        '${completedSets.length}/$setCount done',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Exercise actions',
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            if (duration == Duration.zero)
              if (expanded) sets,
            if (duration != Duration.zero)
              AnimatedSize(
                key: ValueKey('exercise-expansion-$prefix-animation'),
                duration: duration,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: expanded ? sets : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.prefix,
    required this.number,
    required this.completed,
    required this.onChanged,
  });

  final String prefix;
  final int number;
  final bool completed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final surface = theme.colorScheme.surface;
    final completedFill = Color.alphaBlend(
      semantic.workoutSetCompleted.withValues(
        alpha: theme.surfaceTokens.workoutSetCompleteFill,
      ),
      surface,
    );
    return Container(
      key: ValueKey('exercise-expansion-$prefix-set-$number'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: completed ? completedFill : surface,
        borderRadius: theme.shapeTokens.control,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Checkbox(
              value: completed,
              semanticLabel: '$prefix set $number',
              activeColor: semantic.workoutCompleted,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
          SizedBox(width: 42, child: Text('Set $number')),
          const SizedBox(width: 4),
          const Expanded(
            child: _SetValue(label: 'Weight (lbs)', value: '115'),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: _SetValue(label: 'Reps', value: '10'),
          ),
        ],
      ),
    );
  }
}

class _SetValue extends StatelessWidget {
  const _SetValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      Text(value, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
