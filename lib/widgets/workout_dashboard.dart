// File: lib/widgets/workout_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/selected_profile.dart';
import '../providers/active_session.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/session_screen.dart';
import 'preset_bar.dart';

/// A self-contained dashboard widget showing:
/// 1️⃣ Profile selector dropdown (reads SelectedProfile)
/// 2️⃣ Gym presets list (fetched from AppRepository)
/// 3️⃣ Green “Start Workout” button (starts ActiveSession + nav)
class WorkoutDashboard extends StatelessWidget {
  const WorkoutDashboard({super.key});

  static const _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final sel = context.watch<SelectedProfile>();
    final repo = AppRepository();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Profile selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DropdownButtonFormField<String>(
            value: sel.currentProfile?.name,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            items: sel.profiles
                .map((p) => DropdownMenuItem(
                      value: p.name,
                      child: Text(p.name),
                    ))
                .toList(),
            onChanged: (newName) {
              if (newName == null) return;
              final newProfile = sel.profiles
                  .firstWhere((p) => p.name == newName);
              sel.selectProfile(newProfile);
            },
          ),
        ),

        // 2️⃣ Gym presets list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: repo.fetchAllPresetsRaw(
                profileId: sel.currentProfile?.id),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading presets'),
                );
              }
              final rows = snap.data!;
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No presets found.'),
                );
              }
              return Column(
                children: rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  final name = row['name'] as String;
                  final color = _palette[i % _palette.length];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: PresetBar(
                      label: name,
                      color: color,
                      index: i,
                      onTap: () {
                        // Navigate into the preset detail
                        // (reuse your existing logic if needed)
                      },
                      onMenuSelected: (action) {
                        // handle edit/delete/profile swap if you like
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // 3️⃣ Start Workout bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              // start session and navigate
              context.read<ActiveSession>().start();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const SessionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Start Workout',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
