// file: lib/widgets/ongoing_session_fab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_session.dart';
import '../screens/exercise/session_screen.dart'; // adjust path if needed

/// A FAB that toggles between a single dumbbell icon and
/// a green “Resume” + red “Exit” pair when tapped.
class OngoingSessionFab extends StatefulWidget {
  const OngoingSessionFab({super.key});

  @override
  State<OngoingSessionFab> createState() => _OngoingSessionFabState();
}

class _OngoingSessionFabState extends State<OngoingSessionFab> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
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
          label: const Text('Resume'),
          onPressed: () {
            setState(() => _open = false);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SessionScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Exit'),
          onPressed: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Exit your ongoing workout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.deepPurple)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child:
                        const Text('Exit', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (shouldExit == true) {
              await activeSession.finish();
            }
            if (!mounted) return; 
            // guard before setState
            setState(() => _open = false);
          },
        ),
      ],
    );
  }
}
