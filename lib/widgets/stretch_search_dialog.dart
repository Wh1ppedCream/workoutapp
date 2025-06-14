// File: lib/widgets/stretch_search_dialog.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../db/database_helper.dart';

/// A dialog that lets the user pick a stretch by body part,
/// returning the chosen StretchDefinition (or null if cancelled).
class StretchSearchDialog {
  static Future<StretchDefinition?> show(BuildContext context) {
    return showDialog<StretchDefinition>(
      context: context,
      builder: (dialogCtx) {
        int? selectedBodyPartId;
        int? selectedStretchId;
        List<StretchDefinition> currentStretches = [];

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Stretch Search'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1) Body-part dropdown
                  FutureBuilder<List<BodyPart>>(
                    future: DatabaseHelper().getAllBodyParts(),
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final parts = snap.data ?? [];
                      return DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Body Part'),
                        value: selectedBodyPartId,
                        items: parts.map((bp) {
                          return DropdownMenuItem<int>(
                            value: bp.id,
                            child: Text(bp.name),
                          );
                        }).toList(),
                        onChanged: (newBpId) {
                          setState(() {
                            selectedBodyPartId = newBpId;
                            selectedStretchId = null;
                            currentStretches = [];
                          });
                          if (newBpId != null) {
                            DatabaseHelper()
                                .getStretches(bodypartId: newBpId)
                                .then((list) {
                              setState(() {
                                currentStretches = list;
                              });
                            });
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2) Stretch dropdown (once a body part is chosen)
                  if (selectedBodyPartId != null) 
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Stretch'),
                      value: selectedStretchId,
                      items: currentStretches.map((st) {
                        return DropdownMenuItem<int>(
                          value: st.id,
                          child: Text(st.name),
                        );
                      }).toList(),
                      onChanged: (newStId) {
                        setState(() {
                          selectedStretchId = newStId;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStretchId != null
                      ? () {
                          final chosen = currentStretches.firstWhere(
                            (st) => st.id == selectedStretchId,
                          );
                          Navigator.of(dialogCtx).pop(chosen);
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
