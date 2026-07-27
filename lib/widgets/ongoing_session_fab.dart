// file: lib/widgets/ongoing_session_fab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/active_session.dart';
import '../screens/exercise/session_screen.dart'; // adjust path if needed
import '../services/workout_exit_preferences.dart';

/// A FAB that toggles between a single dumbbell icon and
/// a green “Resume” + red “Exit” pair when tapped.
class OngoingSessionFab extends StatefulWidget {
  const OngoingSessionFab({super.key});

  @override
  State<OngoingSessionFab> createState() => _OngoingSessionFabState();
}

class _OngoingSessionFabState extends State<OngoingSessionFab> {
  static const _exitPreferences = WorkoutExitPreferences();
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (!_open) {
      return FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.fitness_center),
        onPressed: () => setState(() => _open = true),
      );
    }
    final activeSession = context.read<ActiveSession>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          backgroundColor: Colors.green,
          icon: const Icon(Icons.play_arrow),
          label: Text(strings.sessionResume),
          onPressed: () {
            setState(() => _open = false);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SessionScreen()));
          },
        ),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon: const Icon(Icons.exit_to_app),
          label: Text(strings.sessionExit),
          onPressed:
              activeSession.isFinishing
                  ? null
                  : () => _handleExit(activeSession),
        ),
      ],
    );
  }

  Future<void> _handleExit(ActiveSession activeSession) async {
    var behavior = await _exitPreferences.load();
    if (!mounted) return;

    if (behavior == WorkoutExitBehavior.askEveryTime) {
      if (activeSession.completedSetCount > 1) {
        final decision = await _showCompletedWorkDialog();
        if (decision == null || !mounted) return;
        behavior = decision.behavior;
        if (decision.remember) await _exitPreferences.save(behavior);
      } else {
        final shouldDiscard = await _showDiscardConfirmation();
        if (shouldDiscard != true || !mounted) return;
        behavior = WorkoutExitBehavior.discard;
      }
    }

    try {
      if (behavior == WorkoutExitBehavior.saveCompleted &&
          !activeSession.hasCompletedWork) {
        behavior = WorkoutExitBehavior.discard;
      }
      if (behavior == WorkoutExitBehavior.saveCompleted) {
        await activeSession.finish();
      } else {
        await activeSession.discard();
      }
      if (!mounted) return;
      setState(() => _open = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            behavior == WorkoutExitBehavior.saveCompleted
                ? AppLocalizations.of(context).sessionCompletedSaved
                : AppLocalizations.of(context).sessionCancelled,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).sessionEndFailed('$error'),
          ),
        ),
      );
    }
  }

  Future<bool?> _showDiscardConfirmation() {
    final strings = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(strings.sessionCancelQuestion),
            content: Text(strings.sessionCancelBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(strings.sessionKeepWorkout),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(strings.sessionCancelWorkout),
              ),
            ],
          ),
    );
  }

  Future<_WorkoutExitDecision?> _showCompletedWorkDialog() {
    var remember = false;
    final strings = AppLocalizations.of(context);
    return showDialog<_WorkoutExitDecision>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              final colors = Theme.of(context).colorScheme;
              final textTheme = Theme.of(context).textTheme;
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.flag_outlined,
                                color: colors.onPrimaryContainer,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                strings.sessionEndQuestion,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed:
                              () => Navigator.pop(
                                dialogContext,
                                _WorkoutExitDecision(
                                  behavior: WorkoutExitBehavior.discard,
                                  remember: remember,
                                ),
                              ),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: Text(strings.sessionCancelDelete),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: colors.error,
                            side: BorderSide(
                              color: colors.error.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed:
                              () => Navigator.pop(
                                dialogContext,
                                _WorkoutExitDecision(
                                  behavior: WorkoutExitBehavior.saveCompleted,
                                  remember: remember,
                                ),
                              ),
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: Text(strings.sessionEndSave),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: CheckboxListTile(
                            value: remember,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              strings.sessionRememberChoice,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              strings.sessionRememberChoiceBody,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            onChanged:
                                (value) => setDialogState(
                                  () => remember = value ?? false,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}

class _WorkoutExitDecision {
  final WorkoutExitBehavior behavior;
  final bool remember;

  const _WorkoutExitDecision({required this.behavior, required this.remember});
}
