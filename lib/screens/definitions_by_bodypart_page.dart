// definitions_by_bodypart_page.dart

import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

import 'definitions_by_muscle_page.dart';

/// Displays exercises filtered by a specific body part.
class DefinitionsByBodyPartPage extends StatelessWidget {
  final BodyPart bodyPart;
  const DefinitionsByBodyPartPage({
    super.key,
    required this.bodyPart,
  });

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    return Scaffold(
      appBar: AppBar(title: Text('${bodyPart.name} Exercises')),
      body: FutureBuilder<List<ExerciseDefinition>>(
        future: repo.fetchExerciseDefinitionsFiltered(
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
            itemCount: defs.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _buildHeader(context);
              final def = defs[i - 1];
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

  Widget _buildHeader(BuildContext context) {
    // TODO: replace placeholders with actual bodyPart fields & repo data
    const setsCount = 0;
    const minSets = 3;
    const maxSets = 5;
    const description = 'Description of the body part goes here.';

// TODO: replace this list with your real BodyPart.muscle list
final musclePlaceholders = ['Muscle A', 'Muscle B', 'Muscle C'];


    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body-part image
         ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Container(
    height: 180, 
    width: double.infinity,
    color: Colors.grey[200],
    child: const Center(
      child: Icon(
        Icons.image,
        size: 64,
        color: Colors.grey,
      ),
    ),
  ),
),
          const SizedBox(height: 12),

          // 7-day sets count
          Text('Sets (7d): $setsCount'),
          const SizedBox(height: 8),

          // Recommended range
          Text('Recommended sets: $minSets–$maxSets'),
          const SizedBox(height: 12),

          // Description
          Text(description),
          const SizedBox(height: 12),

          // Associated muscles
         // Associated muscles (placeholders for now)
          Wrap(
            spacing: 8, runSpacing: 4,
            children: musclePlaceholders.map((muscleName) {
              return ActionChip(
                label: Text(muscleName),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DefinitionsByMusclePage(
                        // TODO: swap these strings out for real models later
                        bodyPartName: bodyPart.name,
                        muscleName: muscleName,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),


          const Divider(height: 32),
        ],
      ),
    );
  
  
  }


}
