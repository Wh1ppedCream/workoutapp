import 'dart:convert';

import 'package:env_test/services/diagnostics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('crash reporting is opt-in and persists the choice', () async {
    const preferences = DiagnosticsPreferences();

    expect(await preferences.loadCrashReportingEnabled(), isFalse);

    await preferences.saveCrashReportingEnabled(true);
    expect(await preferences.loadCrashReportingEnabled(), isTrue);
  });

  test('sync diagnostic JSON contains only the approved safe fields', () {
    final event = SyncDiagnosticEvent(
      timestamp: DateTime.utc(2026, 8, 7, 12, 30),
      operation: 'exercise_media',
      source: 'remote',
      outcome: SyncDiagnosticOutcome.failed,
      durationMilliseconds: 420,
      manifestVersion: 7,
      itemCount: 107,
      errorType: 'SocketException',
    );

    final encoded = jsonEncode(event.toJson());

    expect(
      event.toJson().keys,
      unorderedEquals(<String>[
        'timestamp',
        'operation',
        'source',
        'outcome',
        'duration_ms',
        'manifest_version',
        'item_count',
        'error_type',
      ]),
    );
    expect(encoded, isNot(contains('url')));
    expect(encoded, isNot(contains('message')));
    expect(encoded, isNot(contains('profile')));
    expect(encoded, isNot(contains('workout')));
  });

  test('sync diagnostic history keeps only the newest 30 entries', () async {
    final store = SyncDiagnosticsStore();

    for (var index = 0; index < 35; index++) {
      await store.record(
        SyncDiagnosticEvent(
          timestamp: DateTime.utc(2026, 8, 7).add(Duration(minutes: index)),
          operation: 'exercise_media',
          source: 'bundled',
          outcome: SyncDiagnosticOutcome.succeeded,
          durationMilliseconds: index,
        ),
      );
    }

    final events = await store.load();
    expect(events, hasLength(SyncDiagnosticsStore.maxEvents));
    expect(events.first.durationMilliseconds, 34);
    expect(events.last.durationMilliseconds, 5);

    await store.clear();
    expect(await store.load(), isEmpty);
  });

  test('error sanitizer returns a type without the private message', () {
    final type = DiagnosticsSanitizer.errorType(
      StateError('private workout and health details'),
    );

    expect(type, 'StateError');
    expect(type, isNot(contains('private')));
    expect(type, isNot(contains('health')));
  });

  test('remote event sanitizer removes user data and trace context', () {
    final event = SentryEvent(
      user: SentryUser(ipAddress: '{{auto}}'),
      contexts: Contexts(trace: SentryTraceContext(operation: 'default')),
    );
    final hint = Hint();

    DiagnosticsEventSanitizer.scrubRemoteEvent(event, hint);

    expect(event.user, isNull);
    expect(event.contexts.containsKey(SentryTraceContext.type), isFalse);
  });

  test('version display includes the build number when available', () {
    expect(
      const AppVersionInfo(version: '1.2.3', buildNumber: '45').displayVersion,
      '1.2.3 (45)',
    );
    expect(
      const AppVersionInfo(version: '1.2.3', buildNumber: '').displayVersion,
      '1.2.3',
    );
  });

  test('controlled report cannot send without active consent', () async {
    final diagnostics = DiagnosticsService(sentryDsn: '');

    expect(await diagnostics.sendControlledTestEvent(), isFalse);
  });
}
