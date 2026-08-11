import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production diagnostics use an inactive allowlisted relay by default',
    () {
      final service =
          File('lib/services/diagnostics_service.dart').readAsStringSync();
      final client =
          File('lib/services/diagnostics_relay_client.dart').readAsStringSync();
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(service, contains('diagnostics.relay.consent.v1'));
      expect(service, contains("'TONOS_DIAGNOSTICS_RELAY_URL'"));
      expect(service, contains("defaultValue: ''"));
      expect(service, contains("'TONOS_DIAGNOSTICS_TEST_MODE'"));
      expect(service, isNot(contains('TONOS_SENTRY_DSN')));
      expect(service, isNot(contains('Sentry')));
      expect(client, contains('schema_version'));
      expect(client, isNot(contains('stackTrace')));
      expect(client, isNot(contains('errorMessage')));
      expect(client, contains("'x-tonos-deletion-token'"));
      expect(client, contains('DiagnosticsRelayReceipt'));
      expect(pubspec, contains('http: ^1.6.0'));
      expect(pubspec, isNot(contains('sentry:')));
      expect(pubspec, isNot(contains('sentry_flutter:')));
    },
  );

  test('relay source enforces strict schema, retention, and no egress', () {
    final worker =
        File('services/diagnostics_relay/src/index.js').readAsStringSync();
    final schema =
        File('services/diagnostics_relay/src/schema.mjs').readAsStringSync();
    final migration =
        File(
          'services/diagnostics_relay/migrations/0001_initial.sql',
        ).readAsStringSync();
    final config =
        File(
          'services/diagnostics_relay/wrangler.example.jsonc',
        ).readAsStringSync();

    expect(schema, contains('maxPayloadBytes = 2048'));
    expect(schema, contains('hasOnlyApprovedFields'));
    expect(
      worker,
      contains("'DELETE FROM diagnostic_events WHERE received_at < ?'"),
    );
    expect(
      worker,
      contains('retentionMilliseconds = 14 * 24 * 60 * 60 * 1000'),
    );
    expect(worker, isNot(contains('await fetch(')));
    expect(worker, isNot(contains('console.')));
    expect(worker, isNot(contains('sentry')));
    expect(migration, contains('deletion_token_hash'));
    expect(migration, contains('received_at'));
    expect(config, contains('DIAGNOSTICS_RELAY_WRITES_ENABLED'));
    expect(config, contains('crons'));
  });

  test('privacy and deletion documentation ship together', () {
    final privacy = File('docs/privacy.html').readAsStringSync();
    final deletion = File('docs/data-deletion.html').readAsStringSync();

    expect(privacy, contains('Optional Anonymous Diagnostics'));
    expect(privacy, contains('data-deletion.html'));
    expect(deletion, contains('Delete Your Tonos Data'));
    expect(deletion, contains('Clear sync history'));
    expect(deletion, contains('Delete shared diagnostics'));
    expect(deletion, contains('uninstall'));
    expect(privacy, contains('14 days'));
    expect(privacy, contains('30 additional days'));
    expect(deletion, contains('Cloudflare D1 recovery history'));
    expect(deletion, contains('30 days'));
  });

  test('production release and policy publishing use guarded workflows', () {
    final release =
        File('.github/workflows/production-release.yml').readAsStringSync();
    final pages =
        File('.github/workflows/privacy-pages.yml').readAsStringSync();

    expect(release, contains('environment: production'));
    expect(release, isNot(contains('TONOS_SENTRY_DSN')));
    expect(release, contains('TONOS_ENVIRONMENT=production'));
    expect(release, contains('Build signed production APK'));
    expect(release, contains('tonos-production-apk-'));
    expect(
      RegExp('Build signed production APK').allMatches(release),
      hasLength(1),
    );
    expect(RegExp('Upload production APK').allMatches(release), hasLength(1));
    expect(release, isNot(contains('ingest.sentry.io')));
    expect(pages, contains('pages: write'));
    expect(pages, contains('branches:\n      - master'));
    expect(pages, contains('docs/privacy.html'));
    expect(pages, contains('docs/data-deletion.html'));
    expect(pages, isNot(contains('cp -r docs')));
  });
}
