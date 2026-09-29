import 'package:material_ui/material_ui.dart';

import '../widgets/tonos_action.dart';

/// Compares the shared Tonos action boundary with a standard Material button.
///
/// Both buttons use the same label, Classic theme, 48 dp minimum height, and
/// local-only callback. Neither action touches workout data.
class PrimaryActionPrototype extends StatefulWidget {
  const PrimaryActionPrototype({
    super.key,
    this.enabled = true,
    this.baselineFocusNode,
    this.materialFocusNode,
  });

  final bool enabled;
  final FocusNode? baselineFocusNode;
  final FocusNode? materialFocusNode;

  @override
  State<PrimaryActionPrototype> createState() => _PrimaryActionPrototypeState();
}

class _PrimaryActionPrototypeState extends State<PrimaryActionPrototype> {
  int _baselineInvocations = 0;
  int _materialInvocations = 0;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Primary action', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionColumn(
                title: 'A · TonosAction',
                button: TonosAction(
                  key: const ValueKey('primary-action-baseline'),
                  label: 'Finish Workout',
                  onPressed: widget.enabled
                      ? () => setState(() => _baselineInvocations++)
                      : null,
                  focusNode: widget.baselineFocusNode,
                  expand: true,
                ),
                count: _baselineInvocations,
                countKey: const ValueKey('primary-action-baseline-count'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionColumn(
                title: 'B · FilledButton',
                button: FilledButton(
                  key: const ValueKey('primary-action-material'),
                  onPressed: widget.enabled
                      ? () => setState(() => _materialInvocations++)
                      : null,
                  focusNode: widget.materialFocusNode,
                  style: buttonStyle,
                  child: const Text('Finish Workout'),
                ),
                count: _materialInvocations,
                countKey: const ValueKey('primary-action-material-count'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Same task and theme; the second control uses standard Material '
          'directly. Press feedback follows the platform Material behavior.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.title,
    required this.button,
    required this.count,
    required this.countKey,
  });

  final String title;
  final Widget button;
  final int count;
  final Key countKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        button,
        const SizedBox(height: 4),
        Text('Invoked $count times', key: countKey),
      ],
    );
  }
}
