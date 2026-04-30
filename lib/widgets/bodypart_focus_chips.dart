import 'package:flutter/material.dart';

import '../models/definition_models.dart';

class BodypartFocusSelection {
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const BodypartFocusSelection({
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

class BodypartFocusChips extends StatelessWidget {
  final List<BodyPart> bodyParts;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;
  final ValueChanged<BodypartFocusSelection> onChanged;
  final String emptyText;

  const BodypartFocusChips({
    super.key,
    required this.bodyParts,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
    required this.onChanged,
    this.emptyText = 'Bodyparts could not be loaded.',
  });

  @override
  Widget build(BuildContext context) {
    if (bodyParts.isEmpty) {
      return Text(emptyText, style: const TextStyle(fontSize: 12));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          bodyParts.map((bodyPart) {
            final isPreferred = preferredBodypartIds.contains(bodyPart.id);
            final isAvoided = blacklistedBodypartIds.contains(bodyPart.id);
            final isSelected = isPreferred || isAvoided;
            final color =
                isPreferred
                    ? Colors.green.shade300
                    : isAvoided
                    ? Colors.red.shade300
                    : null;

            return RawChip(
              label: Text(bodyPart.name),
              selected: isSelected,
              selectedColor: color?.withAlpha(61),
              side: BorderSide(color: color ?? Theme.of(context).dividerColor),
              labelStyle:
                  color == null
                      ? null
                      : TextStyle(color: color, fontWeight: FontWeight.w700),
              avatar:
                  color == null
                      ? null
                      : Icon(
                        isPreferred ? Icons.add_circle_outline : Icons.block,
                        color: color,
                        size: 18,
                      ),
              onPressed: () => _cycleBodyPart(bodyPart.id),
            );
          }).toList(),
    );
  }

  void _cycleBodyPart(int bodyPartId) {
    final preferred = {...preferredBodypartIds};
    final blacklisted = {...blacklistedBodypartIds};
    final isPreferred = preferred.contains(bodyPartId);
    final isAvoided = blacklisted.contains(bodyPartId);

    if (!isPreferred && !isAvoided) {
      preferred.add(bodyPartId);
    } else if (isPreferred) {
      preferred.remove(bodyPartId);
      blacklisted.add(bodyPartId);
    } else {
      blacklisted.remove(bodyPartId);
    }

    onChanged(
      BodypartFocusSelection(
        preferredBodypartIds: preferred,
        blacklistedBodypartIds: blacklisted,
      ),
    );
  }
}
