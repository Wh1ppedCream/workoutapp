import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production diagnostics retain privacy-safe defaults', () {
    final source =
        File('lib/services/diagnostics_service.dart').readAsStringSync();

    expect(source, contains("String.fromEnvironment('TONOS_SENTRY_DSN')"));
    expect(source, contains("package:sentry/sentry.dart"));
    expect(source, isNot(contains('SentryFlutter.init')));
    expect(source, contains('sendDefaultPii = false'));
    expect(source, contains('captureFailedRequests = false'));
    expect(source, contains('captureNativeFailedRequests = false'));
    expect(source, contains('tracesSampleRate = 0'));
    expect(source, contains('whereType<IsolateErrorIntegration>()'));
    expect(
      source,
      contains('event.throwable is! _RedactedDiagnosticException'),
    );
    expect(source, contains('hint.attachments.clear()'));
    expect(source, contains('?? false'));
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('sentry: 9.25.0'));
    expect(pubspec, isNot(contains('sentry_flutter:')));
    expect(
      RegExp(r'https://[^\s]+@[^\s]+\.ingest\.sentry\.io').hasMatch(source),
      isFalse,
      reason: 'The Sentry DSN must be supplied at build time, not committed.',
    );
  });

  test('privacy and deletion documentation ship together', () {
    final privacy = File('docs/privacy.html').readAsStringSync();
    final deletion = File('docs/data-deletion.html').readAsStringSync();

    expect(privacy, contains('Optional Crash Diagnostics'));
    expect(privacy, contains('data-deletion.html'));
    expect(deletion, contains('Delete Your Tonos Data'));
    expect(deletion, contains('Clear sync history'));
    expect(deletion, contains('uninstall'));
  });
}
