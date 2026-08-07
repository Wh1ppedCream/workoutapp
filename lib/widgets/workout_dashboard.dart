// File: lib/widgets/workout_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
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
    final activeSession = context.watch<ActiveSession>();
    final colors = context.colors;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profiles = sel.profiles.where((p) => p.id != null).toList();
    final selectedProfileId = sel.currentProfile?.id;
    final dropdownValue =
        profiles.any((p) => p.id == selectedProfileId)
            ? selectedProfileId
            : null;
    final hasActiveWorkout =
        activeSession.isActive && !activeSession.isRestoring;
    final strings = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42 * s,
                height: 42 * s,
                decoration: BoxDecoration(
                  color: colors.workoutStartBg!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: colors.workoutStartText!,
                  size: 21 * s,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  hasActiveWorkout
                      ? strings.dashboardWorkoutInProgress
                      : strings.dashboardSectionTrainingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * s),
          // 1️⃣ Profile selector
          Padding(
            padding: EdgeInsets.zero,
            child: DropdownButtonFormField<int>(
              value: dropdownValue,
              decoration: InputDecoration(
                labelText: strings.onboardingSummaryGymProfile,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12 * s,
                  vertical: 8 * s,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14 * s),
                ),
              ),
              items:
                  profiles
                      .map(
                        (p) => DropdownMenuItem<int>(
                          value: p.id!,
                          child: Text(
                            p.name,
                            style: TextStyle(fontSize: 14 * s),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (newProfileId) async {
                if (newProfileId == null) return;
                final newProfile = profiles.firstWhere(
                  (p) => p.id == newProfileId,
                );
                await sel.selectProfile(newProfile);
                if (!mounted) return;
                setState(() {});
              },
            ),
          ),

          // 2️⃣ Gym presets list (now delegated)
          SizedBox(height: 14 * s),
          Text(
            strings.trainPlansTab,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4 * s),
            child: PresetsLoaded(
              scale: 0.8 * s,
              progressiveReveal: true,
              emptyMessage: strings.dashboardNoSavedPlans,
              physics: const NeverScrollableScrollPhysics(),
              onRefresh: () => setState(() {}),
            ),
          ),

          SizedBox(height: 6 * s),

          // 3️⃣ Start Workout button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 8 * s),
            child: ElevatedButton(
              onPressed: () async {
                final session = context.read<ActiveSession>();
                final navigator = Navigator.of(context);
                if (!hasActiveWorkout) {
                  await session.start();
                }
                if (!mounted) return;
                await navigator.push(
                  MaterialPageRoute(builder: (_) => const SessionScreen()),
                );
                if (!mounted) return;
                widget.onSessionComplete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.workoutStartBg!,
                foregroundColor: colors.workoutStartText!,
                minimumSize: Size.fromHeight(52 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * s),
                ),
              ),
              child: Text(
                hasActiveWorkout
                    ? strings.dashboardResumeWorkout
                    : strings.trainStartWorkout,
                style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
