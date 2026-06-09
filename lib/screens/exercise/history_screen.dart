// File: lib/screens/exercise/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/active_session.dart';
import '../../widgets/history_content.dart';

/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _refreshToken = 0;
  int? _seenCompletedSessionVersion;

  @override
  Widget build(BuildContext context) {
    final completedSessionVersion = context.select<ActiveSession, int>(
      (session) => session.completedSessionVersion,
    );
    if (_seenCompletedSessionVersion == null) {
      _seenCompletedSessionVersion = completedSessionVersion;
    } else if (_seenCompletedSessionVersion != completedSessionVersion) {
      _seenCompletedSessionVersion = completedSessionVersion;
      _refreshToken++;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: HistoryContent(
            refreshToken: _refreshToken,
            onReload: () => setState(() => _refreshToken++),
          ),
        ),
      ),
    );
  }
}
