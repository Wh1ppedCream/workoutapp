import 'package:flutter/material.dart';

import '../models/models.dart';

class RecommendedSetsEditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RecommendedSetsEditButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit recommended sets',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.edit, size: 16),
        ),
      ),
    );
  }
}

Future<VolumeBoundaries?> showRecommendedSetsEditorDialog(
  BuildContext context, {
  required String targetName,
  required int targetId,
  required VolumeBoundaries? currentBounds,
}) {
  return showDialog<VolumeBoundaries>(
    context: context,
    builder: (_) => _RecommendedSetsEditorDialog(
      targetName: targetName,
      targetId: targetId,
      currentBounds: currentBounds,
    ),
  );
}

class _RecommendedSetsEditorDialog extends StatefulWidget {
  final String targetName;
  final int targetId;
  final VolumeBoundaries? currentBounds;

  const _RecommendedSetsEditorDialog({
    required this.targetName,
    required this.targetId,
    required this.currentBounds,
  });

  @override
  State<_RecommendedSetsEditorDialog> createState() =>
      _RecommendedSetsEditorDialogState();
}

class _RecommendedSetsEditorDialogState
    extends State<_RecommendedSetsEditorDialog> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final bounds = widget.currentBounds;
    _minController = TextEditingController(
      text: _formatNumber(bounds?.minEffective ?? 5),
    );
    _maxController = TextEditingController(
      text: _formatNumber(bounds?.maxRecoverable ?? 20),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Recommended sets'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.targetName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Minimum recommended sets',
              suffixText: 'sets',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _maxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Maximum recommended sets',
              suffixText: 'sets',
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final min = double.tryParse(_minController.text.trim());
    final max = double.tryParse(_maxController.text.trim());

    if (min == null || max == null) {
      setState(() => _errorText = 'Enter valid set numbers.');
      return;
    }
    if (min < 0 || max < 0) {
      setState(() => _errorText = 'Set numbers cannot be negative.');
      return;
    }
    if (max < min) {
      setState(() => _errorText = 'Maximum must be at least the minimum.');
      return;
    }

    final current = widget.currentBounds;
    final maxAdaptive = (current?.maxAdaptive ?? ((min + max) / 2))
        .clamp(min, max)
        .toDouble();

    Navigator.of(context).pop(
      VolumeBoundaries(
        id: widget.targetId,
        maintenance: current?.maintenance ?? min,
        minEffective: min,
        maxAdaptive: maxAdaptive,
        maxRecoverable: max,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}
