import 'package:material_ui/material_ui.dart';

enum _MenuTreatment { tonosPopup, materialAnchor }

extension on _MenuTreatment {
  String get label => switch (this) {
    _MenuTreatment.tonosPopup => 'Tonos',
    _MenuTreatment.materialAnchor => 'MenuAnchor',
  };
}

class _ExerciseAction {
  const _ExerciseAction(this.value, this.label);

  final String value;
  final String label;
}

const _exerciseActions = <_ExerciseAction>[
  _ExerciseAction('swap', 'Swap Exercise'),
  _ExerciseAction('remove', 'Remove Exercise'),
  _ExerciseAction('changeSet', 'Make ChangeSet'),
];

/// Local-only comparison for the actual trailing WeightCard overflow menu.
///
/// The action ordering and labels follow WeightCard's current PopupMenuButton;
/// no real exercise, workout callback, or persistence is involved here.
class AnchoredMenuPrototype extends StatefulWidget {
  const AnchoredMenuPrototype({
    super.key,
    this.materialFocusNode,
    this.materialMenuItemFocusNode,
  });

  final FocusNode? materialFocusNode;
  final FocusNode? materialMenuItemFocusNode;

  @override
  State<AnchoredMenuPrototype> createState() => _AnchoredMenuPrototypeState();
}

class _AnchoredMenuPrototypeState extends State<AnchoredMenuPrototype> {
  _MenuTreatment _treatment = _MenuTreatment.tonosPopup;
  String? _lastChoice;

  @override
  Widget build(BuildContext context) {
    final selectedTreatment = _treatment;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise overflow menu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Same WeightCard anchor, action order, and local-only result.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final treatment in _MenuTreatment.values)
                  ChoiceChip(
                    label: Text(treatment.label),
                    selected: _treatment == treatment,
                    onSelected: (_) => setState(() => _treatment = treatment),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _ExerciseFixtureCard(
              treatment: selectedTreatment,
              materialFocusNode: widget.materialFocusNode,
              materialMenuItemFocusNode: widget.materialMenuItemFocusNode,
              onSelected: _recordChoice,
            ),
            const SizedBox(height: 8),
            Text(
              _lastChoice == null
                  ? 'Choose an action to see its local result.'
                  : 'Last local choice: $_lastChoice',
              key: const Key('exercise-menu-last-choice'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _recordChoice(String value) {
    final action = _exerciseActions.firstWhere((item) => item.value == value);
    setState(() => _lastChoice = action.label);
  }
}

class _ExerciseFixtureCard extends StatelessWidget {
  const _ExerciseFixtureCard({
    required this.treatment,
    required this.materialFocusNode,
    required this.materialMenuItemFocusNode,
    required this.onSelected,
  });

  final _MenuTreatment treatment;
  final FocusNode? materialFocusNode;
  final FocusNode? materialMenuItemFocusNode;
  final ValueChanged<String> onSelected;

  String get _anchorKey => switch (treatment) {
    _MenuTreatment.tonosPopup => 'tonos-popup-anchor',
    _MenuTreatment.materialAnchor => 'material-anchor-button',
  };

  @override
  Widget build(BuildContext context) {
    final actionMenu = switch (treatment) {
      _MenuTreatment.tonosPopup => _tonosPopupMenu(),
      _MenuTreatment.materialAnchor => _materialMenuAnchor(),
    };

    return Card(
      key: Key('exercise-fixture-${treatment.name}'),
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  tooltip: 'Collapse sets',
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bench Press - Barbell',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1/3 done',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                actionMenu,
              ],
            ),
            const Divider(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Set 2     135 lb     8 reps',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tonosPopupMenu() {
    return PopupMenuButton<String>(
      key: const Key('tonos-popup-anchor'),
      tooltip: 'Exercise actions',
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final action in _exerciseActions)
          PopupMenuItem<String>(value: action.value, child: Text(action.label)),
      ],
    );
  }

  Widget _materialMenuAnchor() {
    return MenuAnchor(
      key: const Key('material-menu-anchor'),
      childFocusNode: materialFocusNode,
      style: const MenuStyle(alignment: AlignmentDirectional.bottomEnd),
      menuChildren: [
        for (final action in _exerciseActions)
          MenuItemButton(
            key: Key('material-menu-${action.value}'),
            focusNode: action.value == 'swap'
                ? materialMenuItemFocusNode
                : null,
            onPressed: () => onSelected(action.value),
            child: Text(action.label),
          ),
      ],
      builder: (context, controller, child) => Semantics(
        container: true,
        label: 'Exercise actions',
        button: true,
        child: IconButton(
          key: Key(_anchorKey),
          tooltip: 'Exercise actions',
          icon: const Icon(Icons.more_vert),
          focusNode: materialFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        ),
      ),
    );
  }
}
