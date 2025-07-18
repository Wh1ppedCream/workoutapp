// File: lib/screens/exercise/muscle_filter_page.dart

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import 'definitions_by_bodypart_page.dart';

/// Allows the user to select a body part and view its exercises.
class MuscleFilterPage extends StatelessWidget {
  const MuscleFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Filter by Body Part')),
      body: FutureBuilder<List<BodyPart>>(
        future: repo.fetchAllBodyParts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final parts = snapshot.data!;
          if (parts.isEmpty) {
            return const Center(child: Text('No body parts found.'));
          }
          return ListView.separated(
            itemCount: parts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final part = parts[i];
              return ListTile(
                title: Text(part.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DefinitionsByBodyPartPage(bodyPart: part),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
