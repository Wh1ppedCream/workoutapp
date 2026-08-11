import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/diagnostics_service.dart';
import '../../../widgets/settings_tiles.dart';

class DiagnosticsSettingsPage extends StatefulWidget {
  const DiagnosticsSettingsPage({super.key});

  @override
  State<DiagnosticsSettingsPage> createState() =>
      _DiagnosticsSettingsPageState();
}

class _DiagnosticsSettingsPageState extends State<DiagnosticsSettingsPage> {
  final DiagnosticsService _diagnostics = DiagnosticsService.instance;

  AppVersionInfo? _version;
  List<SyncDiagnosticEvent> _events = const [];
  bool _anonymousDiagnosticsEnabled = false;
  bool _hasSharedDiagnostics = false;
  bool _sendingTestEvent = false;
  bool _deletingSharedDiagnostics = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _diagnostics.loadAnonymousDiagnosticsEnabled();
    final events = await _diagnostics.loadSyncEvents();
    final hasSharedDiagnostics = await _diagnostics.hasSharedDiagnostics();
    AppVersionInfo? version;
    try {
      version = await _diagnostics.loadVersionInfo();
    } catch (_) {
      // The version row can remain unavailable without blocking settings.
    }
    if (!mounted) return;
    setState(() {
      _anonymousDiagnosticsEnabled = enabled;
      _events = events;
      _hasSharedDiagnostics = hasSharedDiagnostics;
      _version = version;
      _loading = false;
    });
  }

  Future<void> _setAnonymousDiagnostics(bool enabled) async {
    try {
      await _diagnostics.setAnonymousDiagnosticsEnabled(enabled);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diagnosticsUnavailable),
        ),
      );
      return;
    }
    if (!mounted) return;
    final hasSharedDiagnostics = await _diagnostics.hasSharedDiagnostics();
    if (!mounted) return;
    setState(() {
      _anonymousDiagnosticsEnabled = enabled;
      _hasSharedDiagnostics = hasSharedDiagnostics;
    });
  }

  Future<void> _clearHistory() async {
    await _diagnostics.clearSyncEvents();
    if (!mounted) return;
    setState(() => _events = const []);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).diagnosticsHistoryCleared),
      ),
    );
  }

  Future<void> _sendTestEvent() async {
    if (_sendingTestEvent) return;
    setState(() => _sendingTestEvent = true);
    final sent = await _diagnostics.sendControlledTestEvent();
    if (!mounted) return;
    setState(() => _sendingTestEvent = false);
    final strings = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? strings.diagnosticsTestReportSent
              : strings.diagnosticsTestReportFailed,
        ),
      ),
    );
  }

  Future<void> _deleteSharedDiagnostics() async {
    if (_deletingSharedDiagnostics || !_hasSharedDiagnostics) return;
    setState(() => _deletingSharedDiagnostics = true);
    final result = await _diagnostics.deleteSharedDiagnostics();
    if (!mounted) return;
    setState(() {
      _deletingSharedDiagnostics = false;
      _hasSharedDiagnostics = result.pending > 0;
    });
    final strings = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.pending == 0
              ? strings.diagnosticsSharedDeleted
              : strings.diagnosticsSharedDeletionPending,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final configured = _diagnostics.anonymousDiagnosticsConfigured;
    final diagnosticsBody =
        !configured
            ? strings.diagnosticsCrashUnavailable
            : _anonymousDiagnosticsEnabled
            ? strings.diagnosticsCrashEnabledBody
            : strings.diagnosticsCrashDisabledBody;

    return SettingsPageScaffold(
      title: strings.diagnosticsTitle,
      subtitle: strings.diagnosticsSubtitle,
      icon: Icons.shield_outlined,
      heroAccentColor: SettingsAccent.data,
      children: [
        SettingsSection(
          title: strings.diagnosticsAppSection,
          subtitle: strings.diagnosticsAppSectionSubtitle,
          accentColor: SettingsAccent.data,
          children: [
            SettingsActionTile(
              icon: Icons.info_outline,
              iconColor: SettingsAccent.data,
              title: strings.diagnosticsVersion,
              subtitle:
                  _loading
                      ? strings.diagnosticsLoading
                      : _version?.displayVersion ??
                          strings.diagnosticsUnavailable,
              trailing: const SizedBox.shrink(),
            ),
          ],
        ),
        SettingsSection(
          title: strings.diagnosticsCrashSection,
          subtitle: strings.diagnosticsCrashSectionSubtitle,
          accentColor: SettingsAccent.safety,
          children: settingsTilesWithDividers(context, [
            SettingsSwitchTile(
              icon: Icons.bug_report_outlined,
              iconColor: SettingsAccent.safety,
              title: strings.diagnosticsCrashReporting,
              subtitle: diagnosticsBody,
              value: configured && _anonymousDiagnosticsEnabled,
              onChanged: configured ? _setAnonymousDiagnostics : null,
            ),
            if (_diagnostics.controlledTestAvailable)
              SettingsActionTile(
                icon: Icons.send_outlined,
                iconColor: SettingsAccent.safety,
                title: strings.diagnosticsSendTestReport,
                subtitle: strings.diagnosticsSendTestReportBody,
                trailing:
                    _sendingTestEvent
                        ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap:
                    _anonymousDiagnosticsEnabled && !_sendingTestEvent
                        ? _sendTestEvent
                        : null,
              ),
            SettingsInfoCard(
              icon: Icons.visibility_off_outlined,
              iconColor: SettingsAccent.safety,
              title: strings.diagnosticsPrivacyPromiseTitle,
              body: strings.diagnosticsPrivacyPromiseBody,
            ),
          ]),
        ),
        SettingsSection(
          title: strings.diagnosticsSyncSection,
          subtitle: strings.diagnosticsSyncSectionSubtitle,
          accentColor: SettingsAccent.training,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_events.isEmpty)
              SettingsInfoCard(
                icon: Icons.sync_outlined,
                iconColor: SettingsAccent.training,
                title: strings.diagnosticsNoSyncEvents,
                body: strings.diagnosticsNoSyncEventsBody,
              )
            else ...[
              for (final event in _events.take(10))
                _SyncEventTile(event: event),
              Divider(
                height: 1,
                indent: 70,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              SettingsActionTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: SettingsAccent.safety,
                title: strings.diagnosticsClearHistory,
                subtitle: strings.diagnosticsClearHistoryBody,
                onTap: _clearHistory,
              ),
            ],
          ],
        ),
        SettingsSection(
          title: strings.diagnosticsPrivacySection,
          subtitle: strings.diagnosticsPrivacySectionSubtitle,
          accentColor: SettingsAccent.progress,
          children: [
            SettingsInfoCard(
              icon: Icons.phone_android_outlined,
              iconColor: SettingsAccent.progress,
              title: strings.diagnosticsLocalDataTitle,
              body: strings.diagnosticsLocalDataBody,
            ),
            const SizedBox(height: 10),
            SettingsInfoCard(
              icon: Icons.delete_forever_outlined,
              iconColor: SettingsAccent.progress,
              title: strings.diagnosticsDeletionTitle,
              body: strings.diagnosticsDeletionBody,
            ),
            const SizedBox(height: 10),
            SettingsActionTile(
              icon: Icons.delete_outline,
              iconColor: SettingsAccent.safety,
              title: strings.diagnosticsDeleteShared,
              subtitle: strings.diagnosticsDeleteSharedBody,
              trailing:
                  _deletingSharedDiagnostics
                      ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : null,
              onTap:
                  _hasSharedDiagnostics && !_deletingSharedDiagnostics
                      ? _deleteSharedDiagnostics
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _SyncEventTile extends StatelessWidget {
  const _SyncEventTile({required this.event});

  final SyncDiagnosticEvent event;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final succeeded = event.outcome == SyncDiagnosticOutcome.succeeded;
    final color = succeeded ? SettingsAccent.progress : SettingsAccent.safety;
    final operation =
        event.operation == 'exercise_media'
            ? strings.diagnosticsExerciseMedia
            : strings.diagnosticsSharedMedia;
    final source =
        event.source == 'remote'
            ? strings.diagnosticsRemoteSource
            : strings.diagnosticsBundledSource;
    final outcome =
        succeeded
            ? strings.diagnosticsSyncSucceeded
            : strings.diagnosticsSyncFailed;
    final timestamp = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_jm().format(event.timestamp.toLocal());

    return ListTile(
      leading: Icon(
        succeeded ? Icons.check_circle_outline : Icons.error_outline,
        color: color,
      ),
      title: Text(strings.diagnosticsSyncEventTitle(operation, outcome)),
      subtitle: Text(
        strings.diagnosticsSyncEventDetails(
          source,
          timestamp,
          event.durationMilliseconds,
          event.manifestVersion?.toString() ?? '-',
          event.itemCount?.toString() ?? '-',
        ),
      ),
      isThreeLine: true,
    );
  }
}
