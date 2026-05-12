import 'package:flutter/material.dart';

import '../models/models.dart';
import 'exercise_detail_sheet.dart';

class ExerciseDefinitionInfoTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final Widget subtitle;

  const ExerciseDefinitionInfoTile({
    super.key,
    required this.definition,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        isThreeLine: true,
        title: Text(
          definition.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle,
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showDetails(context),
        ),
        onTap: () => _showDetails(context),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) =>
              ExerciseDetailSheet(definition: definition, defId: definition.id),
    );
  }
}
