// File: lib/screens/exercise/history_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/active_session.dart';
import '../../services/tutorial_state_store.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/history_content.dart';

/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _logbookCalendarTutorialKey = GlobalKey(
    debugLabel: 'logbook_calendar_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  int _refreshToken = 0;
  int? _seenCompletedSessionVersion;
  bool _logbookTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueLogbookTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueLogbookTutorial();
      });
    }
  }

  void _queueLogbookTutorial() {
    if (!mounted || _logbookTutorialQueued || !TickerMode.of(context)) return;
    _logbookTutorialQueued = true;
    unawaited(_showLogbookTutorialIfNeeded());
  }

  Future<void> _showLogbookTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted || !TickerMode.of(context)) return;

      final completed = await _tutorialStore.isCompleted(
        TutorialIds.logbookHome,
      );
      if (completed || !mounted) return;

      final strings = AppLocalizations.of(context);
      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _logbookCalendarTutorialKey,
            icon: Icons.history_outlined,
            title: strings.logbookTutorialCalendarTitle,
            body: strings.logbookTutorialCalendarBody,
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.logbookHome);
    } finally {
      _logbookTutorialQueued = false;
    }
  }

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
          child: KeyedSubtree(
            key: _logbookCalendarTutorialKey,
            child: HistoryContent(
              refreshToken: _refreshToken,
              onReload: () => setState(() => _refreshToken++),
            ),
          ),
        ),
      ),
    );
  }
}
