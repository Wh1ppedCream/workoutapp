// File: lib/screens/definitions_by_muscle_page.dart

import 'package:flutter/material.dart';
// TODO: import your models (Muscle, ExerciseDefinition) and AppRepository

/// Displays exercises filtered by a specific muscle,
/// plus a header with image, stats, description, and a body-part button.
class DefinitionsByMusclePage extends StatelessWidget {
  // TODO: replace with your actual Muscle model in the constructor
  final String muscleName;
  final String bodyPartName;

  const DefinitionsByMusclePage({
    super.key,
    required this.muscleName,              // TODO: wire in Muscle.name
    required this.bodyPartName,            // TODO: wire in associated BodyPart.name
  });

  @override
  Widget build(BuildContext context) {
    // TODO: fetch your ExerciseDefinition list for this muscle
    final defs = List<Null>.filled(10, null);

    return Scaffold(
      appBar: AppBar(title: Text('$muscleName Exercises')),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: defs.length + 1,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return _buildHeader(context);
          }
          // TODO: replace placeholders below with real ExerciseDefinition data
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: const Text('Exercise Name'),      // TODO
              subtitle: const Text('Equipment: None'), // TODO
              trailing: const Text('⭐️ 0'),            // TODO
              onTap: () {
                // TODO: navigate to exercise detail or history page
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // === PLACEHOLDER DATA ===
    const imageUrl = 'https://via.placeholder.com/600x180';
    const setsCount = 0;    // TODO: compute sets in last 7 days for this muscle
    const minSets = 3;      // TODO: wire in Muscle.minSets
    const maxSets = 5;      // TODO: wire in Muscle.maxSets
    const description = 'Description of the muscle goes here.'; // TODO: wire in Muscle.description
    // ========================

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle image placeholder
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
          Text('Sets (7d): \$setsCount'),

          const SizedBox(height: 8),

          // Recommended sets range
          Text('Recommended sets: \$minSets–\$maxSets'),

          const SizedBox(height: 12),

          // Description text
          Text(description),

          const SizedBox(height: 12),

          // Button to view exercises by body part
          ElevatedButton(
            onPressed: () {
              // TODO: Navigator.push to DefinitionsByBodyPartPage(bodyPartName)
            },
            child: Text('View \$bodyPartName Exercises'),
          ),

          const Divider(height: 32),
        ],
      ),
    );
  }
}
