// File: lib/widgets/workout_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/selected_profile.dart';
import '../providers/active_session.dart';
import '../screens/exercise/session_screen.dart';
import '../theme/theme_extensions.dart';
import 'presets_loaded.dart';

/// A self-contained dashboard widget showing:
/// 1️⃣ Profile selector dropdown
/// 2️⃣ Gym presets list
/// 3️⃣ “Start Workout” button
///
/// Pass [scale] to shrink/grow everything.
class WorkoutDashboard extends StatefulWidget {
  /// Uniform scale factor for all paddings, fonts, and sizes.
  final double scale;
  final VoidCallback? onSessionComplete;

  const WorkoutDashboard({super.key, this.scale = 1, this.onSessionComplete});

  @override
  State<WorkoutDashboard> createState() => _WorkoutDashboardState();
}

class _WorkoutDashboardState extends State<WorkoutDashboard>
    with AutomaticKeepAliveClientMixin<WorkoutDashboard> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = widget.scale;
    final sel = context.watch<SelectedProfile>();
    final colors = context.colors;
    final profiles = sel.profiles.where((p) => p.id != null).toList();
    final selectedProfileId = sel.currentProfile?.id;
    final dropdownValue =
        profiles.any((p) => p.id == selectedProfileId)
            ? selectedProfileId
            : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ Profile selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          child: DropdownButtonFormField<int>(
            value: dropdownValue,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12 * s,
                vertical: 8 * s,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * s),
              ),
            ),
            items:
                profiles
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p.id!,
                        child: Text(p.name, style: TextStyle(fontSize: 14 * s)),
                      ),
                    )
                    .toList(),
            onChanged: (newProfileId) {
              if (newProfileId == null) return;
              final newProfile = profiles.firstWhere(
                (p) => p.id == newProfileId,
              );
              sel.selectProfile(newProfile);
              setState(() {});
            },
          ),
        ),

        // 2️⃣ Gym presets list (now delegated)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: PresetsLoaded(
            scale: 0.8 * s,
            onRefresh: () => setState(() {}),
          ),
        ),

        SizedBox(height: 6 * s),

        // 3️⃣ Start Workout button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 8 * s),
          child: ElevatedButton(
            onPressed: () {
              context.read<ActiveSession>().start();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (_) => const SessionScreen()),
                  )
                  .then((_) {
                    if (!mounted) return;
                    widget.onSessionComplete?.call();
                  });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.workoutStartBg!,
              foregroundColor: colors.workoutStartText!,
              minimumSize: Size.fromHeight(55 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * s),
              ),
            ),
            child: Text(
              'Start Workout',
              style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
