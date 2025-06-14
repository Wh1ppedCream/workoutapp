// definitions_by_bodypart_page.dart

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/models.dart';

/// Displays exercises filtered by a specific body part.
class DefinitionsByBodyPartPage extends StatelessWidget {
  final BodyPart bodyPart;
  const DefinitionsByBodyPartPage({Key? key, required this.bodyPart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${bodyPart.name} Exercises')),
      body: FutureBuilder<List<ExerciseDefinition>>(
        future: DatabaseHelper().getExerciseDefinitionsFiltered(
          bodypartIds: [bodyPart.id],
        ),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final defs = snap.data!;
          if (defs.isEmpty) {
            return Center(child: Text('No exercises for ${bodyPart.name}.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: defs.length,
            itemBuilder: (context, i) {
              final def = defs[i];
              // If you want to show the primary equipment name, 
              // note that getExerciseDefinitionsFiltered() returns shallow definitions
              // (equipmentList will be empty). You could display def.equipmentId instead,
              // or fetch detailed definitions here. For now, show 'None' if equipmentList is empty.
              final equipmentName = def.equipmentList.isNotEmpty
                  ? def.equipmentList.first.name
                  : 'None';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(def.name),
                  subtitle: Text('Equipment: $equipmentName'),
                  trailing: Text('⭐️ ${def.rating}'),
                  onTap: () {
                    // TODO: drill into past instances for this definition
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
