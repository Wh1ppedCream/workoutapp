import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String crashReportingEnabledKey =
      'diagnostics.crash_reporting.enabled';

  const DiagnosticsPreferences();

  Future<bool> loadCrashReportingEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(crashReportingEnabledKey) ?? false;
  }

  Future<void> saveCrashReportingEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(crashReportingEnabledKey, enabled);
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

class _RedactedDiagnosticException implements Exception {
  final String type;

  const _RedactedDiagnosticException(this.type);

  @override
  String toString() => 'RedactedDiagnosticException($type)';
}

class DiagnosticsService {
  DiagnosticsService({
    DiagnosticsPreferences preferences = const DiagnosticsPreferences(),
    SyncDiagnosticsStore? syncStore,
    String sentryDsn = const String.fromEnvironment('TONOS_SENTRY_DSN'),
  }) : _preferences = preferences,
       _syncStore = syncStore ?? SyncDiagnosticsStore(),
       _sentryDsn = sentryDsn.trim();

  static final DiagnosticsService instance = DiagnosticsService();

  final DiagnosticsPreferences _preferences;
  final SyncDiagnosticsStore _syncStore;
  final String _sentryDsn;

  bool _remoteReportingActive = false;
  bool _initialized = false;

  bool get crashReportingConfigured => _sentryDsn.isNotEmpty;
  bool get crashReportingActive => _remoteReportingActive;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final enabled = await _preferences.loadCrashReportingEnabled();
      if (enabled) await _startRemoteReporting();
    } catch (error) {
      debugPrint(
        '[diagnostics] initialization unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
    }
  }

  Future<bool> loadCrashReportingEnabled() {
    return _preferences.loadCrashReportingEnabled();
  }

  Future<void> setCrashReportingEnabled(bool enabled) async {
    await _preferences.saveCrashReportingEnabled(enabled);
    if (!enabled) {
      if (_remoteReportingActive) {
        try {
          await Sentry.close();
        } catch (error) {
          debugPrint(
            '[diagnostics] shutdown unavailable: '
            '${DiagnosticsSanitizer.errorType(error)}',
          );
        }
      }
      _remoteReportingActive = false;
      return;
    }
    await _startRemoteReporting();
  }

  Future<void> _startRemoteReporting() async {
    if (_remoteReportingActive || !crashReportingConfigured) return;

    AppVersionInfo? versionInfo;
    try {
      versionInfo = await loadVersionInfo();
    } catch (_) {
      // Version context is useful but not required for crash capture.
    }

    await Sentry.init((options) {
      options.dsn = _sentryDsn;
      options.environment = const String.fromEnvironment(
        'TONOS_ENVIRONMENT',
        defaultValue: 'production',
      );
      if (versionInfo != null) {
        options.release =
            'tonos@${versionInfo.version}+${versionInfo.buildNumber}';
      }
      options.sendDefaultPii = false;
      options.enableLogs = false;
      options.captureFailedRequests = false;
      options.captureNativeFailedRequests = false;
      options.tracesSampleRate = 0;
      options.maxBreadcrumbs = 30;
      options.debug = false;
      for (final integration
          in options.integrations
              .whereType<IsolateErrorIntegration>()
              .toList()) {
        options.removeIntegration(integration);
      }
      options.beforeSend = (event, hint) {
        // Reject captures that did not pass through captureException's
        // redaction boundary, including direct SDK calls added accidentally.
        if (event.throwable is! _RedactedDiagnosticException) return null;
        hint.attachments.clear();
        hint.screenshot = null;
        hint.viewHierarchy = null;
        return event;
      };
    });
    _remoteReportingActive = true;
  }

  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String category,
  }) async {
    debugPrint(
      '[diagnostics] $category: ${DiagnosticsSanitizer.errorType(error)}',
    );
    if (!_remoteReportingActive) return;

    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          category: 'tonos.error',
          message: category,
          level: SentryLevel.error,
        ),
      );
      await Sentry.captureException(
        _RedactedDiagnosticException(DiagnosticsSanitizer.errorType(error)),
        stackTrace: stackTrace,
      );
    } catch (captureError) {
      debugPrint(
        '[diagnostics] remote capture unavailable: '
        '${DiagnosticsSanitizer.errorType(captureError)}',
      );
    }
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

    if (!_remoteReportingActive) return;
    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          category: 'tonos.content_sync',
          message: event.operation,
          level:
              event.outcome == SyncDiagnosticOutcome.failed
                  ? SentryLevel.warning
                  : SentryLevel.info,
          data: <String, Object?>{
            'source': event.source,
            'outcome': event.outcome.name,
            'duration_ms': event.durationMilliseconds,
            if (event.manifestVersion != null)
              'manifest_version': event.manifestVersion,
            if (event.itemCount != null) 'item_count': event.itemCount,
            if (event.errorType != null) 'error_type': event.errorType,
          },
        ),
      );
    } catch (error) {
      debugPrint(
        '[diagnostics] remote breadcrumb unavailable: '
        '${DiagnosticsSanitizer.errorType(error)}',
      );
    }
  }

  Future<List<SyncDiagnosticEvent>> loadSyncEvents() => _syncStore.load();

  Future<void> clearSyncEvents() => _syncStore.clear();

  Future<AppVersionInfo> loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppVersionInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
