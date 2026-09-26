import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/active_session.dart';
import '../theme/theme_extensions.dart';

/// Persistent, app-level recovery notice for workout durability failures.
class ActiveSessionDurabilityBanner extends StatelessWidget {
  const ActiveSessionDurabilityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<ActiveSession>(
          builder: (context, session, _) {
            final issue = session.durabilityIssue;
            if (issue == null) return const SizedBox.shrink();
            final strings = AppLocalizations.of(context);
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;
            final shapes = context.shapeTokens;
            final effects = context.effectTokens;
            final message = switch (issue) {
              ActiveSessionDurabilityIssue.restore =>
                strings.workoutDurabilityRestoreWarning,
              ActiveSessionDurabilityIssue.draftSave =>
                strings.workoutDurabilityDraftSaveWarning,
              ActiveSessionDurabilityIssue.progression =>
                strings.workoutDurabilityProgressionWarning,
            };

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Material(
                      color: scheme.errorContainer,
                      elevation: effects.feedbackElevation,
                      shadowColor: effects.shadowColor,
                      borderRadius: shapes.card,
                      child: Semantics(
                        liveRegion: true,
                        container: true,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: scheme.onErrorContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  message,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (session.isRetryingDurability)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: session.retryDurability,
                                  child: Text(strings.commonRetry),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
