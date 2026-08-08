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
    expect(source, contains('sendControlledTestEvent'));
    expect(source, contains("category: 'controlled_diagnostics_test'"));
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
    expect(privacy, matches(RegExp(r'no\s+more than 90 days')));
    expect(deletion, matches(RegExp(r'no\s+more than 90 days')));
  });

  test('production release and policy publishing use guarded workflows', () {
    final release =
        File('.github/workflows/production-release.yml').readAsStringSync();
    final pages =
        File('.github/workflows/privacy-pages.yml').readAsStringSync();

    expect(release, contains('environment: production'));
    expect(release, contains(r'${{ secrets.TONOS_SENTRY_DSN }}'));
    expect(release, contains('TONOS_ENVIRONMENT=production'));
    expect(release, isNot(contains('ingest.sentry.io')));
    expect(pages, contains('pages: write'));
    expect(pages, contains('docs/privacy.html'));
    expect(pages, contains('docs/data-deletion.html'));
    expect(pages, isNot(contains('cp -r docs')));
  });
}
