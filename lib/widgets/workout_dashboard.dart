// File: lib/widgets/workout_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_profile.dart';
import '../providers/active_session.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/session_screen.dart';
import 'preset_bar.dart';

/// A self-contained dashboard widget showing:
/// 1️⃣ Profile selector dropdown
/// 2️⃣ Gym presets list
/// 3️⃣ “Start Workout” button
///
/// Pass [scale] to shrink/grow everything.
class WorkoutDashboard extends StatefulWidget {
  /// Uniform scale factor for all paddings, fonts, and sizes.
  final double scale;

  const WorkoutDashboard({super.key, this.scale = 1});

  @override
  State<WorkoutDashboard> createState() => _WorkoutDashboardState();
}

class _WorkoutDashboardState extends State<WorkoutDashboard> {
  static const _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  final _repo = AppRepository();

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final sel = context.watch<SelectedProfile>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Profile selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          child: DropdownButtonFormField<String>(
            value: sel.currentProfile?.name,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * s),
              ),
            ),
            items: sel.profiles
                .map((p) => DropdownMenuItem(
                      value: p.name,
                      child: Text(p.name, style: TextStyle(fontSize: 14 * s)),
                    ))
                .toList(),
            onChanged: (newName) {
              if (newName == null) return;
              final newProfile =
                  sel.profiles.firstWhere((p) => p.name == newName);
              sel.selectProfile(newProfile);
              setState(() {});
            },
          ),
        ),

        // 2️⃣ Gym presets list
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _repo.fetchAllPresetsRaw(
                profileId: sel.currentProfile?.id),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24 * s),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: EdgeInsets.all(16 * s),
                  child: Text('Error loading presets'),
                );
              }
              final rows = snap.data!;
              if (rows.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16 * s),
                  child: Text('No presets found.'),
                );
              }

              return Column(
                children: rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  final presetId = row['id'] as int;
                  final name = row['name'] as String;
                  final color = _palette[i % _palette.length];

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _repo.fetchPresetAutoSettings(presetId),
                    builder: (ctx2, autoSnap) {
                      final isAuto = autoSnap.connectionState ==
                                  ConnectionState.done &&
                              (autoSnap.data?['is_automatic'] as int? ?? 0) ==
                                  1;

                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 6 * s),
                        child: PresetBar(
                          presetId:   presetId,
                          label:      name,
                          color:      color,
                          index:      i,
                          isAutomatic:isAuto,
                          onRefresh:  () => setState(() {}),
                          scale:      0.2 * s,
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),

        SizedBox(height: 6 * s),

        // 3️⃣ Start Workout button
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 15 * s, vertical: 8 * s),
          child: ElevatedButton(
            onPressed: () {
              context.read<ActiveSession>().start();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size.fromHeight(55 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * s),
              ),
            ),
            child: Text(
              'Start Workout',
              style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
