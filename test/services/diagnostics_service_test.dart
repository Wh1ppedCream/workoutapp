import 'dart:convert';

import 'package:env_test/services/diagnostics_relay_client.dart';
import 'package:env_test/services/diagnostics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'anonymous diagnostics are opt-in and ignore legacy Sentry consent',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'diagnostics.crash_reporting.enabled': true,
      });
      const preferences = DiagnosticsPreferences();

      expect(await preferences.loadAnonymousDiagnosticsEnabled(), isFalse);

      await preferences.saveAnonymousDiagnosticsEnabled(true);
      expect(await preferences.loadAnonymousDiagnosticsEnabled(), isTrue);
    },
  );

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

  test('relay event JSON has only the approved categorical fields', () {
    final event = DiagnosticsRelayEvent(
      kind: DiagnosticsRelayKind.contentSync,
      appVersion: '1.2.3',
      buildNumber: 45,
      platform: DiagnosticsRelayPlatform.android,
      code: DiagnosticsRelayCode.contentManifestFetchFailed,
      source: DiagnosticsRelaySource.remoteMedia,
      outcome: DiagnosticsRelayOutcome.failed,
      durationBucket: DiagnosticsRelayDurationBucket.oneToFiveSeconds,
      itemCountBucket: DiagnosticsRelayItemCountBucket.unknown,
    );

    final payload = event.toJson();
    expect(
      payload.keys,
      unorderedEquals(<String>[
        'schema_version',
        'kind',
        'app_version',
        'build_number',
        'platform',
        'code',
        'source',
        'outcome',
        'duration_bucket',
        'item_count_bucket',
      ]),
    );
    final encoded = jsonEncode(payload);
    expect(encoded, isNot(contains('message')));
    expect(encoded, isNot(contains('stack')));
    expect(encoded, isNot(contains('runtime')));
    expect(encoded, isNot(contains('url')));
    expect(encoded, isNot(contains('profile')));
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
    final diagnostics = DiagnosticsService(
      relayClient: DiagnosticsRelayClient(relayUrl: ''),
      controlledTestMode: true,
    );

    expect(await diagnostics.sendControlledTestEvent(), isFalse);
  });

  test(
    'configured relay stores a deletion receipt and honors opt-out',
    () async {
      final transport = _RecordingRelayTransport();
      final diagnostics = DiagnosticsService(
        relayClient: DiagnosticsRelayClient(
          relayUrl: 'https://relay.example.invalid/',
          transport: transport,
        ),
        versionInfoLoader:
            () async =>
                const AppVersionInfo(version: '1.2.3', buildNumber: '45'),
        controlledTestMode: true,
      );

      await diagnostics.setAnonymousDiagnosticsEnabled(true);
      expect(await diagnostics.sendControlledTestEvent(), isTrue);
      expect(transport.submittedPayloads, hasLength(1));
      expect(
        transport.submittedPayloads.single,
        isNot(containsPair('stack_trace', anything)),
      );
      expect(await diagnostics.hasSharedDiagnostics(), isTrue);

      await diagnostics.setAnonymousDiagnosticsEnabled(false);
      expect(transport.deletedReceiptIds, <String>['receipt-0000000001']);
      expect(await diagnostics.hasSharedDiagnostics(), isFalse);
    },
  );

  test('application diagnostics keep the relay disabled without a URL', () {
    expect(DiagnosticsService().anonymousDiagnosticsConfigured, isFalse);
  });

  test('relay endpoint rejects embedded credentials and URL metadata', () {
    expect(
      DiagnosticsRelayClient(
        relayUrl: 'https://operator:secret@relay.example.invalid/',
      ).isConfigured,
      isFalse,
    );
    expect(
      DiagnosticsRelayClient(
        relayUrl: 'https://relay.example.invalid/?deployment=staging',
      ).isConfigured,
      isFalse,
    );
    expect(
      DiagnosticsRelayClient(
        relayUrl: 'https://relay.example.invalid/#diagnostics',
      ).isConfigured,
      isFalse,
    );
    expect(
      DiagnosticsRelayClient(
        relayUrl: 'https://relay.example.invalid/diagnostics',
      ).isConfigured,
      isTrue,
    );
  });
}

class _RecordingRelayTransport implements DiagnosticsRelayTransport {
  final List<Map<String, Object>> submittedPayloads = <Map<String, Object>>[];
  final List<String> deletedReceiptIds = <String>[];

  @override
  Future<DiagnosticsRelayResponse> post(
    Uri endpoint,
    Map<String, Object> payload,
  ) async {
    submittedPayloads.add(payload);
    return const DiagnosticsRelayResponse(
      statusCode: 202,
      body:
          '{"receipt_id":"receipt-0000000001","deletion_token":"12345678901234567890123456789012"}',
    );
  }

  @override
  Future<DiagnosticsRelayResponse> delete(
    Uri endpoint, {
    required String deletionToken,
  }) async {
    deletedReceiptIds.add(endpoint.pathSegments.last);
    return const DiagnosticsRelayResponse(statusCode: 204);
  }
}
