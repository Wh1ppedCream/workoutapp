import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/safe_failure_localizations.dart';
import '../services/safe_failure.dart';

/// Consistent, accessible recovery UI for a failed read operation.
class SafeErrorView extends StatelessWidget {
  const SafeErrorView({
    super.key,
    required this.title,
    required this.failure,
    this.onRetry,
    this.compact = false,
  });

  final String title;
  final SafeFailure failure;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final retry = failure.retryable ? onRetry : null;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: colors.error),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  safeFailureGuidance(strings, failure),
                  textAlign: TextAlign.center,
                ),
                if (retry != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(strings.commonRetry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

SnackBar safeFailureSnackBar(
  BuildContext context, {
  required Object error,
  String? summary,
}) {
  final strings = AppLocalizations.of(context);
  final guidance = safeFailureMessage(strings, error);
  return SnackBar(
    content: Text(
      summary == null
          ? guidance
          : strings.safeFailureWithGuidance(summary, guidance),
    ),
  );
}
