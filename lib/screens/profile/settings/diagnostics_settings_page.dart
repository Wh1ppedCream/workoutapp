import 'package:material_ui/material_ui.dart';

import '../../../theme/widgets/tonos_overlay_routes.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/diagnostics_service.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_dialog.dart';
import '../../../utils/localized_formatters.dart';
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
  bool _showAllSyncEvents = false;
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

  Future<bool> _confirmDiagnosticsAction({
    required String title,
    required String body,
    required String action,
  }) async {
    if (!context.usesExpressivePresentation) return true;
    final strings = AppLocalizations.of(context);
    return await showTonosDialog<bool>(
          context: context,
          builder: (dialogContext) => TonosDialogFrame(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: dialogContext.shapeTokens.sheet,
              ),
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(strings.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(action),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _clearHistory() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await _confirmDiagnosticsAction(
      title: strings.diagnosticsClearHistory,
      body: strings.diagnosticsClearHistoryBody,
      action: strings.diagnosticsClearHistory,
    );
    if (!confirmed || !mounted) return;
    await _diagnostics.clearSyncEvents();
    if (!mounted) return;
    setState(() {
      _events = const [];
      _showAllSyncEvents = false;
    });
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
    final strings = AppLocalizations.of(context);
    final confirmed = await _confirmDiagnosticsAction(
      title: strings.diagnosticsDeleteShared,
      body: strings.diagnosticsDeleteSharedConfirmBody,
      action: strings.diagnosticsDeleteShared,
    );
    if (!confirmed || !mounted) return;
    setState(() => _deletingSharedDiagnostics = true);
    final result = await _diagnostics.deleteSharedDiagnostics();
    if (!mounted) return;
    setState(() {
      _deletingSharedDiagnostics = false;
      _hasSharedDiagnostics = result.pending > 0;
    });
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
    final expressive = context.usesExpressivePresentation;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final configured = _diagnostics.anonymousDiagnosticsConfigured;
    final diagnosticsBody = !configured
        ? strings.diagnosticsCrashUnavailable
        : _anonymousDiagnosticsEnabled
        ? strings.diagnosticsCrashEnabledBody
        : strings.diagnosticsCrashDisabledBody;

    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.profile,
      child: SettingsPageScaffold(
        title: strings.diagnosticsTitle,
        subtitle: strings.diagnosticsSubtitle,
        icon: Icons.shield_outlined,
        heroAccentColor: SettingsAccent.data,
        useExpressiveProfileHeroShape: true,
        children: [
          SettingsSection(
            title: strings.diagnosticsAppSection,
            subtitle: strings.diagnosticsAppSectionSubtitle,
            accentColor: SettingsAccent.data,
            titleColor: _sectionHeadingColor(context, SettingsAccent.data),
            children: [
              SettingsActionTile(
                icon: Icons.info_outline,
                iconColor: SettingsAccent.data,
                title: strings.diagnosticsVersion,
                subtitle: _loading
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
            titleColor: _sectionHeadingColor(context, SettingsAccent.safety),
            surfaceColor: expressive
                ? (dark ? const Color(0xFF402B34) : const Color(0xFFF5E0DE))
                : null,
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
                  trailing: _sendingTestEvent
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _anonymousDiagnosticsEnabled && !_sendingTestEvent
                      ? _sendTestEvent
                      : null,
                ),
              expressive
                  ? _DiagnosticsInlineInfo(
                      icon: Icons.visibility_off_outlined,
                      iconColor: SettingsAccent.safety,
                      title: strings.diagnosticsPrivacyPromiseTitle,
                      body: strings.diagnosticsPrivacyPromiseBody,
                    )
                  : SettingsInfoCard(
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
            titleColor: _sectionHeadingColor(context, SettingsAccent.training),
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
                for (final event in _events.take(
                  _showAllSyncEvents ? _events.length : 5,
                ))
                  _SyncEventTile(event: event),
                if (_events.length > 5)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(
                        () => _showAllSyncEvents = !_showAllSyncEvents,
                      ),
                      icon: Icon(
                        _showAllSyncEvents
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      label: Text(
                        _showAllSyncEvents
                            ? strings.diagnosticsShowLessHistory
                            : strings.diagnosticsShowAllHistory,
                      ),
                    ),
                  ),
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
            accentColor: expressive
                ? const Color(0xFF8B6CA8)
                : SettingsAccent.progress,
            titleColor: expressive
                ? (dark ? const Color(0xFFDCC9F1) : const Color(0xFF64467A))
                : _sectionHeadingColor(context, SettingsAccent.progress),
            surfaceColor: expressive
                ? (dark ? const Color(0xFF33283E) : const Color(0xFFE8DFF1))
                : null,
            children: [
              if (expressive)
                _DiagnosticsInlineInfo(
                  icon: Icons.phone_android_outlined,
                  iconColor: const Color(0xFF8B6CA8),
                  title: strings.diagnosticsLocalDataTitle,
                  body: strings.diagnosticsLocalDataBody,
                )
              else
                SettingsInfoCard(
                  icon: Icons.phone_android_outlined,
                  iconColor: SettingsAccent.progress,
                  title: strings.diagnosticsLocalDataTitle,
                  body: strings.diagnosticsLocalDataBody,
                ),
              if (expressive)
                const _DiagnosticsInlineDivider()
              else
                const SizedBox(height: 10),
              if (expressive)
                _DiagnosticsInlineInfo(
                  icon: Icons.delete_forever_outlined,
                  iconColor: const Color(0xFF8B6CA8),
                  title: strings.diagnosticsDeletionTitle,
                  body: strings.diagnosticsDeletionBody,
                )
              else
                SettingsInfoCard(
                  icon: Icons.delete_forever_outlined,
                  iconColor: SettingsAccent.progress,
                  title: strings.diagnosticsDeletionTitle,
                  body: strings.diagnosticsDeletionBody,
                ),
              if (expressive)
                const _DiagnosticsInlineDivider()
              else
                const SizedBox(height: 10),
              SettingsActionTile(
                icon: Icons.delete_outline,
                iconColor: SettingsAccent.safety,
                title: strings.diagnosticsDeleteShared,
                subtitle: strings.diagnosticsDeleteSharedBody,
                trailing: _deletingSharedDiagnostics
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _hasSharedDiagnostics && !_deletingSharedDiagnostics
                    ? _deleteSharedDiagnostics
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncEventTile extends StatelessWidget {
  const _SyncEventTile({required this.event});

  final SyncDiagnosticEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final succeeded = event.outcome == SyncDiagnosticOutcome.succeeded;
    final skipped = event.outcome == SyncDiagnosticOutcome.skipped;
    final color = succeeded
        ? SettingsAccent.progress
        : skipped
        ? theme.colorScheme.onSurfaceVariant
        : SettingsAccent.safety;
    final operation = switch (event.operation) {
      'exercise_media' => strings.diagnosticsExerciseMedia,
      'shared_media' => strings.diagnosticsSharedMedia,
      _ => event.operation,
    };
    final source = switch (event.source) {
      'remote' => strings.diagnosticsRemoteSource,
      'bundled' => strings.diagnosticsBundledSource,
      _ => event.source,
    };
    final outcome = succeeded
        ? strings.diagnosticsSyncSucceeded
        : skipped
        ? strings.diagnosticsSyncSkipped
        : strings.diagnosticsSyncFailed;
    final timestamp = event.timestamp.toLocal();
    final locale = Localizations.localeOf(context);
    final title = strings.diagnosticsSyncEventTitle(operation, outcome);
    final details = strings.diagnosticsSyncEventDetails(
      source,
      '${LocalizedFormatters.date(timestamp, locale)} · '
      '${LocalizedFormatters.time(timestamp, locale)}',
      event.durationMilliseconds,
      event.manifestVersion?.toString() ?? '-',
      event.itemCount?.toString() ?? '-',
    );

    if (!context.usesExpressivePresentation) {
      return ListTile(
        leading: Icon(
          succeeded
              ? Icons.check_circle_outline
              : skipped
              ? Icons.remove_circle_outline
              : Icons.error_outline,
          color: color,
        ),
        title: Text(title),
        subtitle: Text(details),
        isThreeLine: true,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: context.shapeTokens.settingsAction,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 10),
            child: Icon(
              succeeded
                  ? Icons.check_circle_outline
                  : skipped
                  ? Icons.remove_circle_outline
                  : Icons.error_outline,
              color: color,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsInlineInfo extends StatelessWidget {
  const _DiagnosticsInlineInfo({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expressive = context.usesExpressivePresentation;
    final foreground = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.onSurfaceVariant;
    final iconBackground = iconColor.withValues(
      alpha: expressive ? 0.16 : 0.10,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: context.shapeTokens.settingsAction,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsInlineDivider extends StatelessWidget {
  const _DiagnosticsInlineDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 62,
    endIndent: 14,
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.65),
  );
}

Color? _sectionHeadingColor(BuildContext context, Color accent) {
  if (!context.usesExpressivePresentation ||
      Theme.of(context).brightness == Brightness.dark) {
    return null;
  }
  return Color.lerp(accent, const Color(0xFF33263A), 0.24);
}
