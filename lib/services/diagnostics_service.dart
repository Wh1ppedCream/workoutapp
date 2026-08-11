import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diagnostics_relay_client.dart';

enum SyncDiagnosticOutcome { succeeded, failed, skipped }

class SyncDiagnosticEvent {
  final DateTime timestamp;
  final String operation;
  final String source;
  final SyncDiagnosticOutcome outcome;
  final int durationMilliseconds;
  final int? manifestVersion;
  final int? itemCount;
  final String? errorType;

  const SyncDiagnosticEvent({
    required this.timestamp,
    required this.operation,
    required this.source,
    required this.outcome,
    required this.durationMilliseconds,
    this.manifestVersion,
    this.itemCount,
    this.errorType,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'timestamp': timestamp.toUtc().toIso8601String(),
    'operation': operation,
    'source': source,
    'outcome': outcome.name,
    'duration_ms': durationMilliseconds,
    if (manifestVersion != null) 'manifest_version': manifestVersion,
    if (itemCount != null) 'item_count': itemCount,
    if (errorType != null) 'error_type': errorType,
  };

  factory SyncDiagnosticEvent.fromJson(Map<String, Object?> json) {
    return SyncDiagnosticEvent(
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      operation: json['operation'] as String? ?? 'unknown',
      source: json['source'] as String? ?? 'unknown',
      outcome: SyncDiagnosticOutcome.values.firstWhere(
        (value) => value.name == json['outcome'],
        orElse: () => SyncDiagnosticOutcome.failed,
      ),
      durationMilliseconds: (json['duration_ms'] as num?)?.toInt() ?? 0,
      manifestVersion: (json['manifest_version'] as num?)?.toInt(),
      itemCount: (json['item_count'] as num?)?.toInt(),
      errorType: json['error_type'] as String?,
    );
  }
}

class DiagnosticsPreferences {
  /// New consent is intentionally separate from the retired direct endpoint key.
  static const String anonymousDiagnosticsEnabledKey =
      'diagnostics.relay.consent.v1';

  const DiagnosticsPreferences();

  Future<bool> loadAnonymousDiagnosticsEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(anonymousDiagnosticsEnabledKey) ?? false;
  }

  Future<void> saveAnonymousDiagnosticsEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(anonymousDiagnosticsEnabledKey, enabled);
  }
}

class SyncDiagnosticsStore {
  static const String eventsKey = 'diagnostics.content_sync.events';
  static const int maxEvents = 30;

  Future<void> _writeQueue = Future<void>.value();

  Future<List<SyncDiagnosticEvent>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(eventsKey);
    if (encoded == null || encoded.isEmpty) return const [];

    try {
      final rows = jsonDecode(encoded) as List<dynamic>;
      return rows
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (row) => SyncDiagnosticEvent.fromJson(
              row.map(
                (key, value) =>
                    MapEntry<String, Object?>(key.toString(), value),
              ),
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  Future<void> record(SyncDiagnosticEvent event) {
    _writeQueue = _writeQueue.then((_) async {
      final events = await load();
      final updated = <SyncDiagnosticEvent>[event, ...events];
      if (updated.length > maxEvents) {
        updated.removeRange(maxEvents, updated.length);
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        eventsKey,
        jsonEncode(updated.map((item) => item.toJson()).toList()),
      );
    });
    return _writeQueue;
  }

  Future<void> clear() async {
    await _writeQueue;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(eventsKey);
  }
}

class DiagnosticsRelayReceiptStore {
  static const String receiptsKey = 'diagnostics.relay.receipts.v1';
  static const int maxReceipts = 20;

  Future<void> _writeQueue = Future<void>.value();

  Future<List<DiagnosticsRelayReceipt>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(receiptsKey);
    if (encoded == null || encoded.isEmpty) return const [];

    try {
      final rows = jsonDecode(encoded) as List<dynamic>;
      return rows
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (row) => DiagnosticsRelayReceipt.fromJson(
              row.map(
                (key, value) =>
                    MapEntry<String, Object?>(key.toString(), value),
              ),
            ),
          )
          .where((receipt) => receipt.isValid)
          .toList(growable: false);
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  Future<void> add(DiagnosticsRelayReceipt receipt) {
    _writeQueue = _writeQueue.then((_) async {
      final receipts = await load();
      final updated = <DiagnosticsRelayReceipt>[receipt, ...receipts];
      if (updated.length > maxReceipts) {
        updated.removeRange(maxReceipts, updated.length);
      }
      await _save(updated);
    });
    return _writeQueue;
  }

  Future<void> replace(List<DiagnosticsRelayReceipt> receipts) {
    _writeQueue = _writeQueue.then((_) => _save(receipts));
    return _writeQueue;
  }

  Future<void> _save(List<DiagnosticsRelayReceipt> receipts) async {
    final preferences = await SharedPreferences.getInstance();
    if (receipts.isEmpty) {
      await preferences.remove(receiptsKey);
      return;
    }
    await preferences.setString(
      receiptsKey,
      jsonEncode(receipts.map((receipt) => receipt.toJson()).toList()),
    );
  }
}

class DiagnosticsRemoteDeletionResult {
  const DiagnosticsRemoteDeletionResult({
    required this.deleted,
    required this.pending,
  });

  final int deleted;
  final int pending;
}

class AppVersionInfo {
  final String version;
  final String buildNumber;

  const AppVersionInfo({required this.version, required this.buildNumber});

  String get displayVersion =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';
}

abstract final class DiagnosticsSanitizer {
  static String errorType(Object error) => error.runtimeType.toString();
}

class DiagnosticsService {
  DiagnosticsService({
    DiagnosticsPreferences preferences = const DiagnosticsPreferences(),
    SyncDiagnosticsStore? syncStore,
    DiagnosticsRelayReceiptStore? receiptStore,
    DiagnosticsRelayClient? relayClient,
    Future<AppVersionInfo> Function()? versionInfoLoader,
    bool controlledTestMode = const bool.fromEnvironment(
      'TONOS_DIAGNOSTICS_TEST_MODE',
      defaultValue: false,
    ),
  }) : _preferences = preferences,
       _syncStore = syncStore ?? SyncDiagnosticsStore(),
       _receiptStore = receiptStore ?? DiagnosticsRelayReceiptStore(),
       _relayClient =
           relayClient ??
           DiagnosticsRelayClient(
             relayUrl: const String.fromEnvironment(
               'TONOS_DIAGNOSTICS_RELAY_URL',
               defaultValue: '',
             ),
           ),
       _versionInfoLoader = versionInfoLoader,
       _controlledTestMode = controlledTestMode;

  static final DiagnosticsService instance = DiagnosticsService();

  final DiagnosticsPreferences _preferences;
  final SyncDiagnosticsStore _syncStore;
  final DiagnosticsRelayReceiptStore _receiptStore;
  final DiagnosticsRelayClient _relayClient;
  final Future<AppVersionInfo> Function()? _versionInfoLoader;
  final bool _controlledTestMode;

  bool _anonymousDiagnosticsActive = false;
  bool _initialized = false;

  bool get anonymousDiagnosticsConfigured => _relayClient.isConfigured;
  bool get anonymousDiagnosticsActive => _anonymousDiagnosticsActive;
  bool get controlledTestAvailable =>
      _controlledTestMode && anonymousDiagnosticsConfigured;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final enabled = await _preferences.loadAnonymousDiagnosticsEnabled();
      _anonymousDiagnosticsActive = enabled && anonymousDiagnosticsConfigured;
      if (!enabled) unawaited(deleteSharedDiagnostics());
    } catch (error) {
      debugPrint(
        '[diagnostics] initialization unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
    }
  }

  Future<bool> loadAnonymousDiagnosticsEnabled() {
    return _preferences.loadAnonymousDiagnosticsEnabled();
  }

  Future<void> setAnonymousDiagnosticsEnabled(bool enabled) async {
    await _preferences.saveAnonymousDiagnosticsEnabled(enabled);
    _anonymousDiagnosticsActive = enabled && anonymousDiagnosticsConfigured;
    if (!enabled) await deleteSharedDiagnostics();
  }

  Future<DiagnosticsRemoteDeletionResult> deleteSharedDiagnostics() async {
    List<DiagnosticsRelayReceipt> receipts;
    try {
      receipts = await _receiptStore.load();
    } catch (error) {
      debugPrint(
        '[diagnostics] local receipt history unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
      return const DiagnosticsRemoteDeletionResult(deleted: 0, pending: 0);
    }
    if (receipts.isEmpty) {
      return const DiagnosticsRemoteDeletionResult(deleted: 0, pending: 0);
    }

    final pending = <DiagnosticsRelayReceipt>[];
    var deleted = 0;
    for (final receipt in receipts) {
      if (await _relayClient.deleteReceipt(receipt)) {
        deleted++;
      } else {
        pending.add(receipt);
      }
    }
    try {
      await _receiptStore.replace(pending);
    } catch (error) {
      debugPrint(
        '[diagnostics] local receipt update unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
      return DiagnosticsRemoteDeletionResult(
        deleted: deleted,
        pending: receipts.length,
      );
    }
    return DiagnosticsRemoteDeletionResult(
      deleted: deleted,
      pending: pending.length,
    );
  }

  Future<bool> hasSharedDiagnostics() async {
    try {
      return (await _receiptStore.load()).isNotEmpty;
    } catch (error) {
      debugPrint(
        '[diagnostics] local receipt history unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
      return false;
    }
  }

  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String category,
  }) async {
    debugPrint(
      '[diagnostics] $category: ${DiagnosticsSanitizer.errorType(error)}',
    );
    await _submitRelayEvent(
      kind: DiagnosticsRelayKind.appFault,
      code: _codeForFaultCategory(category),
      source: DiagnosticsRelaySource.app,
      outcome: DiagnosticsRelayOutcome.failed,
      durationBucket: DiagnosticsRelayDurationBucket.unknown,
      itemCountBucket: DiagnosticsRelayItemCountBucket.unknown,
    );
  }

  Future<bool> sendControlledTestEvent() async {
    if (!_controlledTestMode) return false;
    return _submitRelayEvent(
      kind: DiagnosticsRelayKind.appFault,
      code: DiagnosticsRelayCode.flutterFrameworkError,
      source: DiagnosticsRelaySource.app,
      outcome: DiagnosticsRelayOutcome.failed,
      durationBucket: DiagnosticsRelayDurationBucket.unknown,
      itemCountBucket: DiagnosticsRelayItemCountBucket.unknown,
    );
  }

  Future<void> recordSync(SyncDiagnosticEvent event) async {
    try {
      await _syncStore.record(event);
    } catch (error) {
      debugPrint(
        '[diagnostics] local sync history unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
    }

    if (event.outcome == SyncDiagnosticOutcome.succeeded) return;
    await _submitRelayEvent(
      kind: DiagnosticsRelayKind.contentSync,
      code:
          event.outcome == SyncDiagnosticOutcome.skipped
              ? DiagnosticsRelayCode.contentSyncSkipped
              : DiagnosticsRelayCode.contentManifestFetchFailed,
      source: _sourceForSync(event.source),
      outcome:
          event.outcome == SyncDiagnosticOutcome.skipped
              ? DiagnosticsRelayOutcome.skipped
              : DiagnosticsRelayOutcome.failed,
      durationBucket: diagnosticsDurationBucket(event.durationMilliseconds),
      itemCountBucket: diagnosticsItemCountBucket(event.itemCount),
      manifestVersion: event.manifestVersion,
    );
  }

  Future<List<SyncDiagnosticEvent>> loadSyncEvents() => _syncStore.load();

  Future<void> clearSyncEvents() => _syncStore.clear();

  Future<bool> _submitRelayEvent({
    required DiagnosticsRelayKind kind,
    required DiagnosticsRelayCode code,
    required DiagnosticsRelaySource source,
    required DiagnosticsRelayOutcome outcome,
    required DiagnosticsRelayDurationBucket durationBucket,
    required DiagnosticsRelayItemCountBucket itemCountBucket,
    int? manifestVersion,
  }) async {
    if (!_anonymousDiagnosticsActive) return false;

    try {
      final version = await loadVersionInfo();
      final receipt = await _relayClient.submit(
        DiagnosticsRelayEvent(
          kind: kind,
          appVersion: _safeVersion(version.version),
          buildNumber: int.tryParse(version.buildNumber) ?? 0,
          platform: _currentPlatform(),
          code: code,
          source: source,
          outcome: outcome,
          durationBucket: durationBucket,
          itemCountBucket: itemCountBucket,
          manifestVersion: manifestVersion,
        ),
      );
      if (receipt == null) return false;
      await _receiptStore.add(receipt);
      return true;
    } catch (error) {
      debugPrint(
        '[diagnostics] relay unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
      return false;
    }
  }

  Future<AppVersionInfo> loadVersionInfo() {
    final loader = _versionInfoLoader;
    if (loader != null) return loader();
    return _loadPlatformVersionInfo();
  }

  Future<AppVersionInfo> _loadPlatformVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppVersionInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  static DiagnosticsRelayCode _codeForFaultCategory(String category) {
    return switch (category) {
      'flutter_framework' => DiagnosticsRelayCode.flutterFrameworkError,
      'repository_warmup' => DiagnosticsRelayCode.startupError,
      _ => DiagnosticsRelayCode.asyncUncaughtError,
    };
  }

  static DiagnosticsRelaySource _sourceForSync(String source) {
    return switch (source) {
      'remote' => DiagnosticsRelaySource.remoteMedia,
      'bundled' => DiagnosticsRelaySource.bundledMedia,
      'cache' => DiagnosticsRelaySource.mediaCache,
      _ => DiagnosticsRelaySource.app,
    };
  }

  static DiagnosticsRelayPlatform _currentPlatform() {
    if (kIsWeb) return DiagnosticsRelayPlatform.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => DiagnosticsRelayPlatform.android,
      TargetPlatform.iOS => DiagnosticsRelayPlatform.ios,
      TargetPlatform.windows => DiagnosticsRelayPlatform.windows,
      TargetPlatform.macOS => DiagnosticsRelayPlatform.macos,
      TargetPlatform.linux => DiagnosticsRelayPlatform.linux,
      TargetPlatform.fuchsia => DiagnosticsRelayPlatform.android,
    };
  }

  static String _safeVersion(String version) {
    final trimmed = version.trim();
    return RegExp(r'^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$').hasMatch(trimmed)
        ? trimmed
        : '0.0.0';
  }
}
