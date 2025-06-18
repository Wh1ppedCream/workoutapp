// File: lib/widgets/stretch_card.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'stretch_search_dialog.dart';

/// Displays and edits a StretchExercise, including search and custom entries.
class StretchCard extends StatefulWidget {
  final StretchExercise exercise;
  final bool            readOnlyMode;
  final VoidCallback?   onDeleteExercise;
  final VoidCallback?   onValueChanged;

  const StretchCard({
    super.key,
    required this.exercise,
    this.readOnlyMode = false,
    this.onDeleteExercise,
    this.onValueChanged,
  });

  @override
  State<StretchCard> createState() => _StretchCardState();
}

class _StretchCardState extends State<StretchCard> {
  late TextEditingController _stretchCustomController;
  final Set<int> _completedStretches = {};

  @override
  void initState() {
    super.initState();
    _stretchCustomController = TextEditingController();
    // Seed which stretches were already checked
    final instances = widget.exercise.stretchInstances;
    for (var i = 0; i < instances.length; i++) {
      if (instances[i]['is_checked'] == true) {
        _completedStretches.add(i);
      }
    }
  }

  @override
  void dispose() {
    _stretchCustomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnlyMode;
    final stretchList = widget.exercise.stretchInstances;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row: name + remove menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.exercise.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                PopupMenuButton<String>(
                  enabled: !readOnly,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'remove') widget.onDeleteExercise?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'remove', child: Text('Remove Stretch')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search + custom entry row
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  onPressed: readOnly
                      ? null
                      : () async {
                          final chosen = await StretchSearchDialog.show(context);
                          if (chosen != null) {
                            setState(() {
                              stretchList.add({
                                'stretch_id':     chosen.id,
                                'is_custom':      false,
                                'custom_name':    chosen.name,
                                'custom_desc':    chosen.description,
                                'is_checked':     true,
                                'order_index':    stretchList.length,
                              });
                              _completedStretches.add(stretchList.length - 1);
                            });
                            widget.onValueChanged?.call();
                          }
                        },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stretchCustomController,
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      hintText: 'Custom',
                      isDense: true,
                    ),
                    onChanged: readOnly ? null : (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: readOnly || _stretchCustomController.text.trim().isEmpty
                      ? null
                      : () {
                          setState(() {
                            stretchList.add({
                              'stretch_id':     null,
                              'is_custom':      true,
                              'custom_name':    _stretchCustomController.text.trim(),
                              'custom_desc':    '',
                              'is_checked':     false,
                              'order_index':    stretchList.length,
                            });
                            _completedStretches.add(stretchList.length - 1);
                            _stretchCustomController.clear();
                          });
                          widget.onValueChanged?.call();
                        },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List of stretch instances with checkboxes and remove buttons
            for (var i = 0; i < stretchList.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: stretchList[i]['is_checked'] as bool,
                      onChanged: readOnly
                          ? null
                          : (checked) {
                              setState(() {
                                stretchList[i]['is_checked'] = (checked == true);
                                if (checked == true) {
                                  _completedStretches.add(i);
                                } else {
                                  _completedStretches.remove(i);
                                }
                              });
                              widget.onValueChanged?.call();
                            },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stretchList[i]['custom_name'] as String,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if ((stretchList[i]['custom_desc'] as String).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                stretchList[i]['custom_desc'] as String,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: readOnly
                          ? null
                          : () {
                              setState(() {
                                stretchList.removeAt(i);
                                _completedStretches.remove(i);
                                // Reindex order_index fields
                                for (int k = 0; k < stretchList.length; k++) {
                                  stretchList[k]['order_index'] = k;
                                }
                                // Adjust completed indices
                                final toAdjust = _completedStretches
                                    .where((idx) => idx > i)
                                    .toList();
                                for (var oldIdx in toAdjust) {
                                  _completedStretches.remove(oldIdx);
                                  _completedStretches.add(oldIdx - 1);
                                }
                              });
                              widget.onValueChanged?.call();
                            },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
