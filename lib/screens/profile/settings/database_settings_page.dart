import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../db/database_maintenance.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/content_environment_preferences.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../utils/tutorial_launcher.dart';
import '../../../utils/app_test_keys.dart';
import '../../../widgets/guided_tutorial_overlay.dart';
import '../../../widgets/settings_tiles.dart';

class DatabaseSettingsPage extends StatefulWidget {
  const DatabaseSettingsPage({super.key});

  @override
  State<DatabaseSettingsPage> createState() => _DatabaseSettingsPageState();
}

class _DatabaseSettingsPageState extends State<DatabaseSettingsPage> {
  late final AppRepository _repo;
  final _contentEnvironmentPreferences = const ContentEnvironmentPreferences();
  late Future<DatabaseHealthSnapshot> _healthFuture;
  late Future<ContentCacheUsage> _contentCacheFuture;
  late Future<ContentManifestStatus?> _exerciseMediaManifestStatusFuture;
  late Future<ContentManifestStatus?> _sharedMediaManifestStatusFuture;
  late Future<String> _manifestUrlFuture;
  late Future<String> _sharedMediaManifestUrlFuture;
  late Future<ContentEnvironment> _selectedContentEnvironmentFuture;
  late Future<bool> _wifiOnlyMediaDownloadsFuture;
  final _fileActionsTutorialKey = GlobalKey(
    debugLabel: 'database_file_actions',
  );
  final _healthTutorialKey = GlobalKey(debugLabel: 'database_health');
  final _maintenanceTutorialKey = GlobalKey(debugLabel: 'database_maintenance');
  bool _maintenanceRunning = false;
  bool _contentActionRunning = false;
  bool _repoBound = false;
  bool _tutorialQueued = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repoBound) return;
    _repo = context.read<AppRepository>();
    _healthFuture = _repo.getDatabaseHealthSnapshot();
    _contentCacheFuture = _repo.getContentCacheUsage();
    _exerciseMediaManifestStatusFuture = _repo.getContentManifestStatus(
      'exercise_media',
    );
    _sharedMediaManifestStatusFuture = _repo.getContentManifestStatus(
      'shared_media',
    );
    _selectedContentEnvironmentFuture = _loadSelectedContentEnvironment();
    _manifestUrlFuture = _loadManifestUrl();
    _sharedMediaManifestUrlFuture = _loadSharedMediaManifestUrl();
    _wifiOnlyMediaDownloadsFuture = _repo.isWifiOnlyMediaDownloadEnabled();
    _repoBound = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  void _refreshHealth() {
    setState(() {
      _healthFuture = _repo.getDatabaseHealthSnapshot();
    });
  }

  void _refreshContentStatus() {
    setState(() {
      _contentCacheFuture = _repo.getContentCacheUsage();
      _exerciseMediaManifestStatusFuture = _repo.getContentManifestStatus(
        'exercise_media',
      );
      _sharedMediaManifestStatusFuture = _repo.getContentManifestStatus(
        'shared_media',
      );
      _selectedContentEnvironmentFuture = _loadSelectedContentEnvironment();
      _manifestUrlFuture = _loadManifestUrl();
      _sharedMediaManifestUrlFuture = _loadSharedMediaManifestUrl();
      _wifiOnlyMediaDownloadsFuture = _repo.isWifiOnlyMediaDownloadEnabled();
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.databaseSettings,
        steps: [
          GuidedTutorialStep(
            targetKey: _fileActionsTutorialKey,
            icon: Icons.import_export,
            title: _strings.databaseTutorialFilesTitle,
            body: _strings.databaseTutorialFilesBody,
          ),
          GuidedTutorialStep(
            targetKey: _healthTutorialKey,
            icon: Icons.health_and_safety_outlined,
            title: _strings.databaseTutorialHealthTitle,
            body: _strings.databaseTutorialHealthBody,
          ),
          GuidedTutorialStep(
            targetKey: _maintenanceTutorialKey,
            icon: Icons.build_outlined,
            title: _strings.databaseTutorialMaintenanceTitle,
            body: _strings.databaseTutorialMaintenanceBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _timestampTag() {
    final now = DateTime.now();
    return '${now.year}'
        '${_twoDigits(now.month)}'
        '${_twoDigits(now.day)}_'
        '${_twoDigits(now.hour)}'
        '${_twoDigits(now.minute)}'
        '${_twoDigits(now.second)}';
  }

  String _timestampedFilename(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    final stamp = _timestampTag();
    if (dotIndex <= 0) {
      return '${filename}_$stamp';
    }
    final basename = filename.substring(0, dotIndex);
    final extension = filename.substring(dotIndex);
    return '${basename}_$stamp$extension';
  }

  Future<String?> _saveJsonFileWithPicker({
    required String filename,
    required String contents,
    required String dialogTitle,
  }) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: _timestampedFilename(filename),
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
  }

  Future<void> _showSavedFileDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(message)],
                ),
              ),
            ),
            actions: [
              TextButton(
                key: AppTestKeys.databaseResultClose,
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(_strings.commonClose),
              ),
            ],
          ),
    );
  }

  Future<({String name, String contents})?> _pickJsonFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
      dialogTitle: 'Select a database export file',
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    if (picked.size > kDatabaseImportMaxBytes) {
      throw const FormatException('database_import_file_too_large');
    }
    if (picked.path != null && picked.path!.isNotEmpty) {
      final file = File(picked.path!);
      if (await file.length() > kDatabaseImportMaxBytes) {
        throw const FormatException('database_import_file_too_large');
      }
      return (name: picked.name, contents: await file.readAsString());
    }
    if (picked.bytes != null) {
      return (
        name: picked.name,
        contents: utf8.decode(picked.bytes!, allowMalformed: false),
      );
    }
    throw StateError('The selected file could not be read.');
  }

  Future<void> _exportDatabase() async {
    try {
      final confirmed = await _confirmPlaintextExport();
      if (confirmed != true) return;
      final jsonStr = await _repo.exportDatabase();
      final location = await _saveJsonFileWithPicker(
        filename: 'fitness_tracker_database_export.json',
        contents: jsonStr,
        dialogTitle: 'Save database export',
      );
      if (location == null) return;
      await _showSavedFileDialog(
        title: _strings.databaseExportSavedTitle,
        message: _strings.databaseExportSavedBody,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.databaseExportFailedSafe)),
      );
    }
  }

  Future<void> _importDatabase() async {
    try {
      final picked = await _pickJsonFile();
      if (picked == null) return;

      final preview = _repo.previewDatabaseImport(picked.contents);
      if (!preview.canImport) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.databaseImportBlockedSafe)),
        );
        return;
      }

      if (!mounted) return;
      final confirmed = await _confirmImport(preview, sourceName: picked.name);
      if (confirmed != true) return;

      final backupLocation = await _saveJsonFileWithPicker(
        filename: 'fitness_tracker_database_backup_before_import.json',
        contents: await _repo.exportDatabase(),
        dialogTitle: 'Save backup before import',
      );
      if (backupLocation == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.databaseImportBackupCanceled)),
        );
        return;
      }

      await _repo.importDatabase(picked.contents, clearFirst: true);
      if (!mounted) return;
      _refreshHealth();
      await _showSavedFileDialog(
        title: _strings.databaseImportSucceededTitle,
        message: _strings.databaseImportSucceededBody(picked.name),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      final message =
          error.message == 'database_import_file_too_large'
              ? _strings.databaseImportFileTooLarge
              : _strings.databaseImportBlockedSafe;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.databaseImportFailedSafe)),
      );
    }
  }

  Future<bool?> _confirmPlaintextExport() {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_strings.databaseConfirmExportTitle),
            content: Text(_strings.databaseConfirmExportBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(_strings.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_strings.databaseContinueExport),
              ),
            ],
          ),
    );
  }

  Future<bool?> _confirmImport(
    DatabaseImportPreview preview, {
    String? sourceName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_strings.databaseConfirmImportTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_strings.databaseConfirmImportBody),
                    if (sourceName != null) ...[
                      const SizedBox(height: 12),
                      Text(_strings.databaseImportFile(sourceName)),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      _strings.databaseImportTables(
                        preview.importableTables.length,
                      ),
                    ),
                    Text(_strings.databaseImportRows(preview.totalRows)),
                    if (preview.schemaVersion != null)
                      Text(
                        _strings.databaseImportSchema(preview.schemaVersion!),
                      ),
                    if (preview.isLegacyFormat)
                      Text(_strings.databaseImportLegacyFormat),
                    if (preview.warnings.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_strings.databaseImportWarnings),
                      for (final warning in preview.warnings)
                        Text('- $warning'),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(_strings.commonCancel),
              ),
              ElevatedButton(
                key: AppTestKeys.databaseConfirmImport,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_strings.databaseBackupAndImport),
              ),
            ],
          ),
    );
  }

  Future<void> _runMaintenance(
    Future<DatabaseMaintenanceResult> Function() action,
  ) async {
    if (_maintenanceRunning) return;
    setState(() => _maintenanceRunning = true);
    try {
      final result = await action();
      if (!mounted) return;
      _refreshHealth();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.title}: ${result.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.databaseMaintenanceFailed(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _maintenanceRunning = false);
      }
    }
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final decimals = unit == 0 || size >= 100 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unit]}';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return _strings.databaseNever;
    final local = value.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  Future<String> _loadCustomManifestUrl() async {
    return _contentEnvironmentPreferences.loadCustomExerciseMediaManifestUrl();
  }

  Future<ContentEnvironment> _loadSelectedContentEnvironment() async {
    final config = await _repo.loadContentEnvironments();
    return _contentEnvironmentPreferences.loadSelectedEnvironment(config);
  }

  Future<String> _loadManifestUrl() async {
    final config = await _repo.loadContentEnvironments();
    return _contentEnvironmentPreferences.loadExerciseMediaManifestUrl(config);
  }

  Future<String> _loadSharedMediaManifestUrl() async {
    final config = await _repo.loadContentEnvironments();
    return _contentEnvironmentPreferences.loadSharedMediaManifestUrl(config);
  }

  Future<void> _saveSelectedContentEnvironment(String environmentId) async {
    if (_contentActionRunning) return;
    setState(() => _contentActionRunning = true);
    try {
      await _contentEnvironmentPreferences.saveSelectedEnvironment(
        environmentId,
      );
      await _repo.refreshSelectedContentEnvironment();
      if (!mounted) return;
      _refreshContentStatus();
    } finally {
      if (mounted) setState(() => _contentActionRunning = false);
    }
  }

  Future<void> _editContentEnvironment() async {
    final config = await _repo.loadContentEnvironments();
    final selected = await _loadSelectedContentEnvironment();
    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => _ContentEnvironmentDialog(
            config: config,
            selectedEnvironmentId: selected.id,
          ),
    );

    if (result == null || result == selected.id) return;
    await _saveSelectedContentEnvironment(result);
  }

  Future<void> _saveManifestUrl(String value) async {
    if (_contentActionRunning) return;
    setState(() => _contentActionRunning = true);
    try {
      await _contentEnvironmentPreferences.saveCustomExerciseMediaManifestUrl(
        value,
      );
      await _repo.refreshSelectedContentEnvironment();
      if (!mounted) return;
      _refreshContentStatus();
    } finally {
      if (mounted) setState(() => _contentActionRunning = false);
    }
  }

  Future<void> _editManifestUrl() async {
    final currentUrl = await _loadCustomManifestUrl();
    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ManifestUrlDialog(initialUrl: currentUrl),
    );

    if (result == null) return;
    if (!mounted) return;
    await _saveManifestUrl(result);
  }

  Future<void> _setWifiOnlyMediaDownloads(bool value) async {
    await _repo.setWifiOnlyMediaDownloadEnabled(value);
    if (!mounted) return;
    setState(() {
      _wifiOnlyMediaDownloadsFuture = Future.value(value);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'New media downloads will wait for Wi-Fi.'
              : 'New media downloads can use any connection.',
        ),
      ),
    );
  }

  Future<void> _syncRemoteExerciseMediaManifest() async {
    if (_contentActionRunning) return;
    final manifestUrl = (await _loadManifestUrl()).trim();
    final uri = Uri.tryParse(manifestUrl);

    final validRemoteUri =
        uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
    if (manifestUrl.isEmpty || !validRemoteUri) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.databaseManifestUrlRequired)),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _contentActionRunning = true);
    try {
      final manifest = await _repo.syncRemoteExerciseMediaManifest(uri);
      if (!mounted) return;
      _refreshContentStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseExerciseMediaSyncSuccess(
              manifest.exerciseMedia.length,
              manifest.version,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.databaseContentSyncFailed(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _contentActionRunning = false);
      }
    }
  }

  Future<void> _syncBundledExerciseMediaManifest() async {
    if (_contentActionRunning) return;
    setState(() => _contentActionRunning = true);
    try {
      final manifest = await _repo.syncBundledExerciseMediaManifest();
      if (!mounted) return;
      _refreshContentStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseBundledManifestLoaded(manifest.version),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseBundledContentSyncFailed(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _contentActionRunning = false);
      }
    }
  }

  Future<void> _syncRemoteSharedMediaManifest() async {
    if (_contentActionRunning) return;
    final manifestUrl = (await _loadSharedMediaManifestUrl()).trim();
    final uri = Uri.tryParse(manifestUrl);
    final validRemoteUri =
        uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
    if (!validRemoteUri) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.databaseSharedMediaUrlMissing)),
      );
      return;
    }

    setState(() => _contentActionRunning = true);
    try {
      final manifest = await _repo.syncRemoteSharedMediaManifest(uri);
      if (!mounted) return;
      _refreshContentStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseSharedMediaSyncSuccess(
              manifest.entities.length,
              manifest.version,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseSharedContentSyncFailed(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _contentActionRunning = false);
    }
  }

  Future<void> _clearContentCache() async {
    if (_contentActionRunning) return;
    final strings = _strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(strings.databaseClearMediaTitle),
            content: Text(strings.databaseClearMediaBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(strings.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(strings.databaseClearCache),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _contentActionRunning = true);
    try {
      await _repo.clearContentCache();
      if (!mounted) return;
      _refreshContentStatus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.databaseCacheCleared)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseClearCacheFailed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _contentActionRunning = false);
      }
    }
  }

  Widget _buildCloudContentSection() {
    final theme = Theme.of(context);
    final strings = _strings;

    return SettingsSection(
      title: strings.databaseCloudContent,
      subtitle: strings.databaseCloudContentSubtitle,
      accentColor: SettingsAccent.data,
      children: settingsTilesWithDividers(context, [
        FutureBuilder<ContentEnvironment>(
          future: _selectedContentEnvironmentFuture,
          builder: (context, snapshot) {
            final environment = snapshot.data;
            return SettingsActionTile(
              icon: Icons.public_outlined,
              title: strings.databaseContentEnvironment,
              subtitle:
                  environment == null
                      ? strings.databaseLoadingEnvironment
                      : '${environment.label}${environment.isProduction ? ' (production)' : ''}'
                          '${environment.description.isEmpty ? '' : '\n${environment.description}'}',
              trailing: IconButton(
                tooltip: strings.databaseChangeEnvironment,
                icon: const Icon(Icons.swap_horiz),
                color: theme.colorScheme.primary,
                onPressed:
                    _contentActionRunning ? null : _editContentEnvironment,
              ),
              onTap: _contentActionRunning ? null : _editContentEnvironment,
            );
          },
        ),
        FutureBuilder<String>(
          future: _manifestUrlFuture,
          builder: (context, snapshot) {
            final url = snapshot.data ?? '';
            return SettingsActionTile(
              icon: Icons.cloud_outlined,
              title: strings.databaseExerciseManifestUrl,
              subtitle:
                  url.isEmpty ? strings.databaseNoExerciseManifestUrl : url,
              trailing: IconButton(
                tooltip: strings.databaseOverrideUrl,
                icon: const Icon(Icons.edit),
                color: theme.colorScheme.primary,
                onPressed: _contentActionRunning ? null : _editManifestUrl,
              ),
              onTap: _contentActionRunning ? null : _editManifestUrl,
            );
          },
        ),
        FutureBuilder<ContentManifestStatus?>(
          future: _exerciseMediaManifestStatusFuture,
          builder: (context, snapshot) {
            final status = snapshot.data;
            return SettingsActionTile(
              icon: Icons.description_outlined,
              title:
                  status == null
                      ? strings.databaseNoManifestSynced
                      : strings.databaseManifestVersion(status.version),
              subtitle: strings.databaseLastChecked(
                _formatDateTime(status?.lastCheckedAt),
              ),
              trailing: const SizedBox.shrink(),
            );
          },
        ),
        FutureBuilder<ContentManifestStatus?>(
          future: _sharedMediaManifestStatusFuture,
          builder: (context, snapshot) {
            final status = snapshot.data;
            return SettingsActionTile(
              icon: Icons.category_outlined,
              title: strings.databaseSharedCatalogMedia,
              subtitle:
                  status == null
                      ? strings.databaseSharedMediaNotSynced
                      : strings.databaseManifestLastChecked(
                        status.version,
                        _formatDateTime(status.lastCheckedAt),
                      ),
              trailing: const SizedBox.shrink(),
            );
          },
        ),
        FutureBuilder<String>(
          future: _sharedMediaManifestUrlFuture,
          builder: (context, snapshot) {
            final url = snapshot.data ?? '';
            return SettingsActionTile(
              icon: Icons.collections_outlined,
              title: strings.databaseSharedManifestUrl,
              subtitle: url.isEmpty ? strings.databaseNoSharedManifestUrl : url,
              trailing: const SizedBox.shrink(),
            );
          },
        ),
        FutureBuilder<ContentCacheUsage>(
          future: _contentCacheFuture,
          builder: (context, snapshot) {
            final usage =
                snapshot.data ??
                const ContentCacheUsage(fileCount: 0, totalBytes: 0);
            return SettingsActionTile(
              icon: Icons.folder_copy_outlined,
              title: strings.databaseDownloadedMediaCache,
              subtitle: strings.databaseCacheUsage(
                usage.fileCount,
                _formatBytes(usage.totalBytes),
              ),
              trailing: const SizedBox.shrink(),
            );
          },
        ),
        FutureBuilder<bool>(
          future: _wifiOnlyMediaDownloadsFuture,
          builder: (context, snapshot) {
            final wifiOnly = snapshot.data ?? false;
            return SettingsSwitchTile(
              icon: Icons.wifi,
              title: strings.databaseWifiOnly,
              subtitle: strings.databaseWifiOnlySubtitle,
              value: wifiOnly,
              onChanged:
                  _contentActionRunning
                      ? null
                      : (value) {
                        unawaited(_setWifiOnlyMediaDownloads(value));
                      },
            );
          },
        ),
        SettingsActionTile(
          icon: Icons.sync,
          title: strings.databaseSyncExerciseMedia,
          trailing:
              _contentActionRunning
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : null,
          onTap:
              _contentActionRunning ? null : _syncRemoteExerciseMediaManifest,
        ),
        SettingsActionTile(
          icon: Icons.collections_outlined,
          title: strings.databaseSyncSharedMedia,
          subtitle: strings.databaseSyncSharedMediaSubtitle,
          trailing:
              _contentActionRunning
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : null,
          onTap: _contentActionRunning ? null : _syncRemoteSharedMediaManifest,
        ),
        SettingsActionTile(
          icon: Icons.inventory_2_outlined,
          title: strings.databaseLoadBundledManifest,
          onTap:
              _contentActionRunning ? null : _syncBundledExerciseMediaManifest,
        ),
        SettingsActionTile(
          icon: Icons.cleaning_services_outlined,
          title: strings.databaseClearMediaCache,
          subtitle: strings.databaseClearMediaCacheSubtitle,
          iconColor: theme.colorScheme.error,
          onTap: _contentActionRunning ? null : _clearContentCache,
        ),
      ]),
    );
  }

  /// Generic asset exporter file helper.
  Future<void> _exportAsset(
    Future<String> Function() exporter,
    String filename,
  ) async {
    try {
      final jsonStr = await exporter();
      final location = await _saveJsonFileWithPicker(
        filename: filename,
        contents: jsonStr,
        dialogTitle: _strings.databaseSaveFile(filename),
      );
      if (location == null) return;
      await _showSavedFileDialog(
        title: _strings.databaseExportSavedTitle,
        message: _strings.databaseFileSaved(filename),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.databaseDefinitionExportFailed(filename, e.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    return SettingsPageScaffold(
      title: strings.databaseSettingsTitle,
      subtitle: strings.databaseSettingsSubtitle,
      icon: Icons.storage_outlined,
      heroAccentColor: SettingsAccent.data,
      children: [
        KeyedSubtree(
          key: _fileActionsTutorialKey,
          child: SettingsSection(
            title: strings.databaseBackupRestore,
            subtitle: strings.databaseBackupRestoreSubtitle,
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                key: AppTestKeys.databaseExport,
                icon: Icons.upload_file,
                title: strings.databaseExportBackup,
                onTap: _exportDatabase,
              ),
              SettingsActionTile(
                key: AppTestKeys.databaseImport,
                icon: Icons.download,
                title: strings.databaseImportBackup,
                subtitle: strings.databaseImportBackupSubtitle,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: _importDatabase,
              ),
            ]),
          ),
        ),

        KeyedSubtree(key: _healthTutorialKey, child: _buildHealthSection()),
        KeyedSubtree(
          key: _maintenanceTutorialKey,
          child: _buildMaintenanceSection(),
        ),

        _buildCloudContentSection(),

        _buildDeveloperExportSection(),
      ],
    );
  }

  Widget _buildHealthSection() {
    final strings = _strings;
    return SettingsSection(
      title: strings.databaseHealth,
      subtitle: strings.databaseHealthSubtitle,
      accentColor: SettingsAccent.progress,
      children: [
        FutureBuilder<DatabaseHealthSnapshot>(
          future: _healthFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SettingsActionTile(
                icon: Icons.health_and_safety_outlined,
                title: strings.databaseCheckingHealth,
                subtitle: strings.databaseCheckingHealthSubtitle,
                trailing: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (snapshot.hasError) {
              return SettingsActionTile(
                icon: Icons.error_outline,
                iconColor: Theme.of(context).colorScheme.error,
                title: strings.databaseHealthFailed,
                subtitle: '${snapshot.error}',
                trailing: IconButton(
                  tooltip: _strings.commonRetry,
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshHealth,
                ),
                onTap: _refreshHealth,
              );
            }

            return _DatabaseHealthCard(
              health: snapshot.data!,
              formatBytes: _formatBytes,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    final strings = _strings;
    return SettingsSection(
      title: strings.databaseMaintenance,
      subtitle: strings.databaseMaintenanceSubtitle,
      accentColor: SettingsAccent.advanced,
      children: settingsTilesWithDividers(context, [
        SettingsActionTile(
          icon: Icons.refresh,
          title: strings.databaseRefreshHealth,
          trailing:
              _maintenanceRunning
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : null,
          onTap: _maintenanceRunning ? null : _refreshHealth,
        ),
        SettingsActionTile(
          icon: Icons.fact_check,
          title: strings.databaseIntegrityCheck,
          subtitle: strings.databaseIntegrityCheckSubtitle,
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.runDatabaseIntegrityCheck),
        ),
        SettingsActionTile(
          icon: Icons.auto_fix_high,
          title: strings.databaseOptimize,
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.optimizeDatabase),
        ),
        SettingsActionTile(
          icon: Icons.save_alt,
          title: strings.databaseCheckpointWal,
          subtitle: strings.databaseCheckpointWalSubtitle,
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.checkpointWal),
        ),
        SettingsActionTile(
          icon: Icons.compress,
          title: strings.databaseVacuum,
          subtitle: strings.databaseVacuumSubtitle,
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.vacuumDatabase),
        ),
      ]),
    );
  }

  Widget _buildDeveloperExportSection() {
    final strings = _strings;
    return SettingsSection(
      title: strings.databaseDefinitionExports,
      subtitle: strings.databaseDefinitionExportsSubtitle,
      accentColor: SettingsAccent.data,
      children: settingsTilesWithDividers(context, [
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('equipment.json'),
          onTap:
              () => _exportAsset(_repo.exportEquipmentJson, 'equipment.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('bodyparts.json'),
          onTap:
              () => _exportAsset(_repo.exportBodypartsJson, 'bodyparts.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('muscles.json'),
          onTap: () => _exportAsset(_repo.exportMusclesJson, 'muscles.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('exercises.json'),
          onTap:
              () => _exportAsset(_repo.exportExercisesJson, 'exercises.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('stretches.json'),
          onTap:
              () => _exportAsset(_repo.exportStretchesJson, 'stretches.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('muscle_bodypart.json'),
          onTap:
              () => _exportAsset(
                _repo.exportMuscleBodypartJson,
                'muscle_bodypart.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('bodypart_ranking.json'),
          onTap:
              () => _exportAsset(
                _repo.exportBodypartRankingJson,
                'bodypart_ranking.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('muscle_ranking.json'),
          onTap:
              () => _exportAsset(
                _repo.exportMuscleRankingJson,
                'muscle_ranking.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition(
            'bodypart_muscle_rankings.json',
          ),
          onTap:
              () => _exportAsset(
                _repo.exportBodypartMuscleRankingsJson,
                'bodypart_muscle_rankings.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: strings.databaseExportDefinition('volume_boundaries.json'),
          onTap:
              () => _exportAsset(
                _repo.exportVolumeBoundariesJson,
                'volume_boundaries.json',
              ),
        ),
      ]),
    );
  }
}

class _DatabaseHealthCard extends StatelessWidget {
  final DatabaseHealthSnapshot health;
  final String Function(int bytes) formatBytes;

  const _DatabaseHealthCard({required this.health, required this.formatBytes});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HealthInfoRow(
            label: strings.databaseHealthSchema,
            value: strings.databaseHealthSchemaValue(
              health.schemaVersion,
              health.targetSchemaVersion,
            ),
            healthy: health.isSchemaCurrent,
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: strings.databaseHealthSize,
            value: formatBytes(health.totalBytes),
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: strings.databaseHealthJournal,
            value: health.journalMode,
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: strings.databaseHealthTables,
            value: strings.databaseHealthTablesValue(
              health.tableCount,
              health.indexCount,
              health.triggerCount,
            ),
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: strings.databaseHealthFoodSearch,
            value: strings.databaseHealthFoodSearchValue(
              health.foodCount,
              health.foodFtsCount,
            ),
            healthy: health.isFoodSearchAligned,
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: strings.databaseHealthPath,
            value: health.path,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _HealthDivider extends StatelessWidget {
  final Color color;

  const _HealthDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: color.withValues(alpha: 0.42));
  }
}

class _HealthInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? healthy;
  final int maxLines;

  const _HealthInfoRow({
    required this.label,
    required this.value,
    this.healthy,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor =
        healthy == null
            ? scheme.primary
            : healthy!
            ? Colors.green
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            healthy == null
                ? Icons.info_outline
                : healthy!
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            size: 18,
            color: statusColor,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManifestUrlDialog extends StatefulWidget {
  final String initialUrl;

  const _ManifestUrlDialog({required this.initialUrl});

  @override
  State<_ManifestUrlDialog> createState() => _ManifestUrlDialogState();
}

class _ManifestUrlDialogState extends State<_ManifestUrlDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).databaseExerciseManifestDialogTitle,
      ),
      content: TextField(
        controller: _controller,
        autofocus: false,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).databaseManifestUrl,
          hintText:
              'https://cdn.tonos.app/manifests/exercise_media_manifest.json',
        ),
        minLines: 1,
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(''),
          child: Text(AppLocalizations.of(context).databaseClear),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ],
    );
  }
}

class _ContentEnvironmentDialog extends StatefulWidget {
  final ContentEnvironmentConfig config;
  final String selectedEnvironmentId;

  const _ContentEnvironmentDialog({
    required this.config,
    required this.selectedEnvironmentId,
  });

  @override
  State<_ContentEnvironmentDialog> createState() =>
      _ContentEnvironmentDialogState();
}

class _ContentEnvironmentDialogState extends State<_ContentEnvironmentDialog> {
  late String _selectedEnvironmentId;

  @override
  void initState() {
    super.initState();
    _selectedEnvironmentId = widget.selectedEnvironmentId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).databaseContentEnvironment),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.config.environments.map((environment) {
                return RadioListTile<String>(
                  value: environment.id,
                  groupValue: _selectedEnvironmentId,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedEnvironmentId = value);
                  },
                  title: Text(
                    environment.isProduction
                        ? AppLocalizations.of(
                          context,
                        ).databaseProductionEnvironment(environment.label)
                        : environment.label,
                  ),
                  subtitle: Text(
                    [
                      if (environment.description.isNotEmpty)
                        environment.description,
                      if (environment.exerciseMediaManifestUrl.isEmpty)
                        AppLocalizations.of(
                          context,
                        ).databaseNoManifestConfigured,
                    ].join('\n'),
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedEnvironmentId),
          child: Text(AppLocalizations.of(context).databaseUseEnvironment),
        ),
      ],
    );
  }
}
