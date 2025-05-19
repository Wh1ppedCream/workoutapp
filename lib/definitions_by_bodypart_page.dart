import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';

class DefinitionsByBodyPartPage extends StatelessWidget {
  final BodyPart bodyPart;
  const DefinitionsByBodyPartPage({Key? key, required this.bodyPart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${bodyPart.name} Exercises')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getExerciseDefsByBodyPart(bodyPart.id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return Center(child: Text('No exercises for ${bodyPart.name}.'));
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              final def = ExerciseDefinition(
                id: row['id'] as int,
                name: row['name'] as String,
                equipmentId: row['equipment_id'] as int?,
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(def.name),
                  subtitle: Text(def.equipmentId != null
                      ? 'Equipment ID: ${def.equipmentId}'
                      : 'No equipment'),
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