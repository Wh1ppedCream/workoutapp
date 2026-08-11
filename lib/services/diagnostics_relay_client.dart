import 'dart:convert';

import 'package:http/http.dart' as http;

enum DiagnosticsRelayKind { appFault, contentSync }

enum DiagnosticsRelayPlatform { android, ios, windows, macos, linux, web }

enum DiagnosticsRelayCode {
  flutterFrameworkError,
  asyncUncaughtError,
  startupError,
  contentManifestFetchFailed,
  contentManifestDecodeFailed,
  contentAssetFetchFailed,
  contentCacheWriteFailed,
  contentSyncSkipped,
}

enum DiagnosticsRelaySource { app, remoteMedia, bundledMedia, mediaCache }

enum DiagnosticsRelayOutcome { failed, skipped }

enum DiagnosticsRelayDurationBucket {
  underOneSecond,
  oneToFiveSeconds,
  fiveToThirtySeconds,
  overThirtySeconds,
  unknown,
}

enum DiagnosticsRelayItemCountBucket {
  zero,
  oneToNine,
  tenToNinetyNine,
  oneHundredOrMore,
  unknown,
}

extension on DiagnosticsRelayKind {
  String get wireValue => switch (this) {
    DiagnosticsRelayKind.appFault => 'app_fault',
    DiagnosticsRelayKind.contentSync => 'content_sync',
  };
}

extension on DiagnosticsRelayPlatform {
  String get wireValue => name;
}

extension on DiagnosticsRelayCode {
  String get wireValue => switch (this) {
    DiagnosticsRelayCode.flutterFrameworkError => 'flutter_framework_error',
    DiagnosticsRelayCode.asyncUncaughtError => 'async_uncaught_error',
    DiagnosticsRelayCode.startupError => 'startup_error',
    DiagnosticsRelayCode.contentManifestFetchFailed =>
      'content_manifest_fetch_failed',
    DiagnosticsRelayCode.contentManifestDecodeFailed =>
      'content_manifest_decode_failed',
    DiagnosticsRelayCode.contentAssetFetchFailed =>
      'content_asset_fetch_failed',
    DiagnosticsRelayCode.contentCacheWriteFailed =>
      'content_cache_write_failed',
    DiagnosticsRelayCode.contentSyncSkipped => 'content_sync_skipped',
  };
}

extension on DiagnosticsRelaySource {
  String get wireValue => switch (this) {
    DiagnosticsRelaySource.app => 'app',
    DiagnosticsRelaySource.remoteMedia => 'remote_media',
    DiagnosticsRelaySource.bundledMedia => 'bundled_media',
    DiagnosticsRelaySource.mediaCache => 'media_cache',
  };
}

extension on DiagnosticsRelayOutcome {
  String get wireValue => name;
}

extension on DiagnosticsRelayDurationBucket {
  String get wireValue => switch (this) {
    DiagnosticsRelayDurationBucket.underOneSecond => 'under_1s',
    DiagnosticsRelayDurationBucket.oneToFiveSeconds => '1_to_5s',
    DiagnosticsRelayDurationBucket.fiveToThirtySeconds => '5_to_30s',
    DiagnosticsRelayDurationBucket.overThirtySeconds => 'over_30s',
    DiagnosticsRelayDurationBucket.unknown => 'unknown',
  };
}

extension on DiagnosticsRelayItemCountBucket {
  String get wireValue => switch (this) {
    DiagnosticsRelayItemCountBucket.zero => 'zero',
    DiagnosticsRelayItemCountBucket.oneToNine => 'one_to_nine',
    DiagnosticsRelayItemCountBucket.tenToNinetyNine => 'ten_to_ninety_nine',
    DiagnosticsRelayItemCountBucket.oneHundredOrMore => 'one_hundred_or_more',
    DiagnosticsRelayItemCountBucket.unknown => 'unknown',
  };
}

class DiagnosticsRelayEvent {
  static const int schemaVersion = 1;

  const DiagnosticsRelayEvent({
    required this.kind,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.code,
    required this.source,
    required this.outcome,
    required this.durationBucket,
    required this.itemCountBucket,
    this.manifestVersion,
  });

  final DiagnosticsRelayKind kind;
  final String appVersion;
  final int buildNumber;
  final DiagnosticsRelayPlatform platform;
  final DiagnosticsRelayCode code;
  final DiagnosticsRelaySource source;
  final DiagnosticsRelayOutcome outcome;
  final DiagnosticsRelayDurationBucket durationBucket;
  final DiagnosticsRelayItemCountBucket itemCountBucket;
  final int? manifestVersion;

  Map<String, Object> toJson() => <String, Object>{
    'schema_version': schemaVersion,
    'kind': kind.wireValue,
    'app_version': appVersion,
    'build_number': buildNumber,
    'platform': platform.wireValue,
    'code': code.wireValue,
    'source': source.wireValue,
    'outcome': outcome.wireValue,
    'duration_bucket': durationBucket.wireValue,
    'item_count_bucket': itemCountBucket.wireValue,
    if (manifestVersion != null) 'manifest_version': manifestVersion!,
  };
}

class DiagnosticsRelayReceipt {
  const DiagnosticsRelayReceipt({
    required this.receiptId,
    required this.deletionToken,
    required this.endpoint,
  });

  final String receiptId;
  final String deletionToken;
  final String endpoint;

  Map<String, String> toJson() => <String, String>{
    'receipt_id': receiptId,
    'deletion_token': deletionToken,
    'endpoint': endpoint,
  };

  factory DiagnosticsRelayReceipt.fromJson(Map<String, Object?> json) {
    return DiagnosticsRelayReceipt(
      receiptId: json['receipt_id'] as String? ?? '',
      deletionToken: json['deletion_token'] as String? ?? '',
      endpoint: json['endpoint'] as String? ?? '',
    );
  }

  /// A relay response supplies these two fields. The client attaches the
  /// configured endpoint before persisting the receipt locally.
  bool get hasReceiptData => receiptId.isNotEmpty && deletionToken.isNotEmpty;

  bool get isValid => hasReceiptData && endpoint.isNotEmpty;
}

class DiagnosticsRelayResponse {
  const DiagnosticsRelayResponse({required this.statusCode, this.body = ''});

  final int statusCode;
  final String body;
}

abstract interface class DiagnosticsRelayTransport {
  Future<DiagnosticsRelayResponse> post(
    Uri endpoint,
    Map<String, Object> payload,
  );

  Future<DiagnosticsRelayResponse> delete(
    Uri endpoint, {
    required String deletionToken,
  });
}

class HttpDiagnosticsRelayTransport implements DiagnosticsRelayTransport {
  HttpDiagnosticsRelayTransport({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<DiagnosticsRelayResponse> post(
    Uri endpoint,
    Map<String, Object> payload,
  ) async {
    final response = await _client.post(
      endpoint,
      headers: const <String, String>{
        'content-type': 'application/json',
        'cache-control': 'no-store',
      },
      body: jsonEncode(payload),
    );
    return DiagnosticsRelayResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<DiagnosticsRelayResponse> delete(
    Uri endpoint, {
    required String deletionToken,
  }) async {
    final response = await _client.delete(
      endpoint,
      headers: <String, String>{
        'cache-control': 'no-store',
        'x-tonos-deletion-token': deletionToken,
      },
    );
    return DiagnosticsRelayResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class DiagnosticsRelayClient {
  DiagnosticsRelayClient({
    required String relayUrl,
    DiagnosticsRelayTransport? transport,
  }) : _relayUrl = relayUrl.trim(),
       _transport = transport ?? HttpDiagnosticsRelayTransport();

  final String _relayUrl;
  final DiagnosticsRelayTransport _transport;

  Uri? get endpoint {
    final candidate = Uri.tryParse(_relayUrl);
    if (candidate == null ||
        !candidate.hasScheme ||
        candidate.host.isEmpty ||
        candidate.scheme != 'https' ||
        candidate.userInfo.isNotEmpty ||
        candidate.hasQuery ||
        candidate.hasFragment) {
      return null;
    }
    return candidate.replace(
      path:
          candidate.path.endsWith('/') ? candidate.path : '${candidate.path}/',
    );
  }

  bool get isConfigured => endpoint != null;

  Future<DiagnosticsRelayReceipt?> submit(DiagnosticsRelayEvent event) async {
    final baseEndpoint = endpoint;
    if (baseEndpoint == null) return null;

    try {
      final response = await _transport.post(
        baseEndpoint.resolve('v1/events'),
        event.toJson(),
      );
      if (response.statusCode != 202) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final receipt = DiagnosticsRelayReceipt.fromJson(
        decoded.map(
          (key, value) => MapEntry<String, Object?>(key.toString(), value),
        ),
      );
      return receipt.hasReceiptData
          ? DiagnosticsRelayReceipt(
            receiptId: receipt.receiptId,
            deletionToken: receipt.deletionToken,
            endpoint: baseEndpoint.toString(),
          )
          : null;
    } on Object {
      return null;
    }
  }

  Future<bool> deleteReceipt(DiagnosticsRelayReceipt receipt) async {
    final baseEndpoint = Uri.tryParse(receipt.endpoint);
    if (!receipt.isValid ||
        baseEndpoint == null ||
        baseEndpoint.scheme != 'https' ||
        baseEndpoint.host.isEmpty) {
      return false;
    }

    try {
      final response = await _transport.delete(
        baseEndpoint.resolve('v1/events/${receipt.receiptId}'),
        deletionToken: receipt.deletionToken,
      );
      return response.statusCode == 204;
    } on Object {
      return false;
    }
  }
}

DiagnosticsRelayDurationBucket diagnosticsDurationBucket(
  int durationMilliseconds,
) {
  if (durationMilliseconds < 0) return DiagnosticsRelayDurationBucket.unknown;
  if (durationMilliseconds < 1000) {
    return DiagnosticsRelayDurationBucket.underOneSecond;
  }
  if (durationMilliseconds < 5000) {
    return DiagnosticsRelayDurationBucket.oneToFiveSeconds;
  }
  if (durationMilliseconds < 30000) {
    return DiagnosticsRelayDurationBucket.fiveToThirtySeconds;
  }
  return DiagnosticsRelayDurationBucket.overThirtySeconds;
}

DiagnosticsRelayItemCountBucket diagnosticsItemCountBucket(int? itemCount) {
  if (itemCount == null || itemCount < 0) {
    return DiagnosticsRelayItemCountBucket.unknown;
  }
  if (itemCount == 0) return DiagnosticsRelayItemCountBucket.zero;
  if (itemCount < 10) return DiagnosticsRelayItemCountBucket.oneToNine;
  if (itemCount < 100) return DiagnosticsRelayItemCountBucket.tenToNinetyNine;
  return DiagnosticsRelayItemCountBucket.oneHundredOrMore;
}
