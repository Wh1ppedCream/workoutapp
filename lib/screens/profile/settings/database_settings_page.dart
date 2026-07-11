import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../db/database_maintenance.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/content_environment_preferences.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../utils/tutorial_launcher.dart';
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
  late Future<String> _manifestUrlFuture;
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
    _selectedContentEnvironmentFuture = _loadSelectedContentEnvironment();
    _manifestUrlFuture = _loadManifestUrl();
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
      _selectedContentEnvironmentFuture = _loadSelectedContentEnvironment();
      _manifestUrlFuture = _loadManifestUrl();
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
            title: 'Database files',
            body:
                'Export a backup or import a saved database file. Imports require a backup first.',
          ),
          GuidedTutorialStep(
            targetKey: _healthTutorialKey,
            icon: Icons.health_and_safety_outlined,
            title: 'Database health',
            body:
                'This card shows schema version, database size, table counts, and search-index health.',
          ),
          GuidedTutorialStep(
            targetKey: _maintenanceTutorialKey,
            icon: Icons.build_outlined,
            title: 'Maintenance tools',
            body:
                'Use these actions for integrity checks, optimization, WAL checkpointing, or vacuuming when needed.',
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
    return FilePicker.platform.saveFile(
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
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<({String name, String contents})?> _pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
      dialogTitle: 'Select a database export file',
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    if (picked.path != null && picked.path!.isNotEmpty) {
      final file = File(picked.path!);
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
      final jsonStr = await _repo.exportDatabase();
      final location = await _saveJsonFileWithPicker(
        filename: 'fitness_tracker_database_export.json',
        contents: jsonStr,
        dialogTitle: 'Save database export',
      );
      if (location == null) return;
      await _showSavedFileDialog(
        title: 'Database Export Saved',
        message: 'The database export was saved to your selected location.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
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
          SnackBar(content: Text('Import blocked: ${preview.message}')),
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
          const SnackBar(
            content: Text('Import canceled: backup was not saved.'),
          ),
        );
        return;
      }

      await _repo.importDatabase(picked.contents, clearFirst: true);
      if (!mounted) return;
      _refreshHealth();
      await _showSavedFileDialog(
        title: 'Import Succeeded',
        message:
            'Imported ${picked.name}. A backup of the previous local database '
            'was saved to your selected location first.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<bool?> _confirmImport(
    DatabaseImportPreview preview, {
    String? sourceName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Import'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'This replaces the local database. A backup file of the '
                      'current database will be written first.',
                    ),
                    if (sourceName != null) ...[
                      const SizedBox(height: 12),
                      Text('File: $sourceName'),
                    ],
                    const SizedBox(height: 12),
                    Text('Tables: ${preview.importableTables.length}'),
                    Text('Rows: ${preview.totalRows}'),
                    if (preview.schemaVersion != null)
                      Text('Export schema: v${preview.schemaVersion}'),
                    if (preview.isLegacyFormat)
                      const Text('Format: legacy table map'),
                    if (preview.warnings.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Warnings:'),
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Back Up & Import'),
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
        SnackBar(content: Text('Database maintenance failed: $e')),
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
    if (value == null) return 'Never';
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

  Future<void> _saveSelectedContentEnvironment(String environmentId) async {
    await _contentEnvironmentPreferences.saveSelectedEnvironment(environmentId);
    if (!mounted) return;
    _refreshContentStatus();
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
    await _contentEnvironmentPreferences.saveCustomExerciseMediaManifestUrl(
      value,
    );
    if (!mounted) return;
    _refreshContentStatus();
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
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    if (manifestUrl.isEmpty || !validRemoteUri) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a valid exercise media manifest URL first.'),
        ),
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
            'Synced ${manifest.exerciseMedia.length} exercise media entries '
            '(v${manifest.version}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Content sync failed: $e')));
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
            'Loaded bundled exercise media manifest '
            '(v${manifest.version}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bundled content sync failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _contentActionRunning = false);
      }
    }
  }

  Future<void> _clearContentCache() async {
    if (_contentActionRunning) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear Downloaded Media?'),
            content: const Text(
              'This removes cached exercise thumbnails and media files. '
              'The app can download them again when needed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Clear Cache'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded media cache cleared.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Clear cache failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _contentActionRunning = false);
      }
    }
  }

  Widget _buildCloudContentSection() {
    final theme = Theme.of(context);

    return SettingsSection(
      title: 'Cloud Content',
      subtitle: 'Manage exercise thumbnails, manifests, and cache storage.',
      accentColor: SettingsAccent.data,
      children: settingsTilesWithDividers(context, [
        FutureBuilder<ContentEnvironment>(
          future: _selectedContentEnvironmentFuture,
          builder: (context, snapshot) {
            final environment = snapshot.data;
            return SettingsActionTile(
              icon: Icons.public_outlined,
              title: 'Content Environment',
              subtitle:
                  environment == null
                      ? 'Loading environment...'
                      : '${environment.label}${environment.isProduction ? ' (production)' : ''}'
                          '${environment.description.isEmpty ? '' : '\n${environment.description}'}',
              trailing: IconButton(
                tooltip: 'Change environment',
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
              title: 'Manifest URL',
              subtitle:
                  url.isEmpty
                      ? 'No remote manifest URL set for this environment.'
                      : url,
              trailing: IconButton(
                tooltip: 'Override URL',
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
                      ? 'No Manifest Synced'
                      : 'Manifest v${status.version}',
              subtitle:
                  'Last checked: ${_formatDateTime(status?.lastCheckedAt)}',
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
              title: 'Downloaded Media Cache',
              subtitle:
                  '${usage.fileCount} files, ${_formatBytes(usage.totalBytes)}',
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
              title: 'Wi-Fi Only Downloads',
              subtitle:
                  'New thumbnails and videos download only on Wi-Fi. Cached media still works offline.',
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
          title: 'Sync Remote Exercise Media',
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
          icon: Icons.inventory_2_outlined,
          title: 'Load Bundled Manifest',
          onTap:
              _contentActionRunning ? null : _syncBundledExerciseMediaManifest,
        ),
        SettingsActionTile(
          icon: Icons.cleaning_services_outlined,
          title: 'Clear Downloaded Media Cache',
          subtitle: 'Removes cached remote media files from this device.',
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
        dialogTitle: 'Save $filename',
      );
      if (location == null) return;
      await _showSavedFileDialog(
        title: 'Export Saved',
        message: '$filename was saved to your selected location.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export $filename failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Database Settings',
      subtitle: 'Backups, cloud media, health checks, and developer exports.',
      icon: Icons.storage_outlined,
      heroAccentColor: SettingsAccent.data,
      children: [
        KeyedSubtree(
          key: _fileActionsTutorialKey,
          child: SettingsSection(
            title: 'Backup & Restore',
            subtitle: 'Move your local Tonos data in or out safely.',
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.upload_file,
                title: 'Export Database Backup',
                onTap: _exportDatabase,
              ),
              SettingsActionTile(
                icon: Icons.download,
                title: 'Import Database Backup',
                subtitle: 'Replace local data from a saved export file.',
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
    return SettingsSection(
      title: 'Health',
      subtitle:
          'A quick read on database size, schema, and search index state.',
      accentColor: SettingsAccent.progress,
      children: [
        FutureBuilder<DatabaseHealthSnapshot>(
          future: _healthFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SettingsActionTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Checking database health...',
                subtitle: 'Reading schema, size, tables, and indexes.',
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
                title: 'Database health check failed',
                subtitle: '${snapshot.error}',
                trailing: IconButton(
                  tooltip: 'Retry',
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
    return SettingsSection(
      title: 'Maintenance',
      subtitle: 'Safe tools for checks, optimization, and storage cleanup.',
      accentColor: SettingsAccent.advanced,
      children: settingsTilesWithDividers(context, [
        SettingsActionTile(
          icon: Icons.refresh,
          title: 'Refresh Health',
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
          title: 'Run Integrity Check',
          subtitle: 'Ask SQLite to verify the local database file.',
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.runDatabaseIntegrityCheck),
        ),
        SettingsActionTile(
          icon: Icons.auto_fix_high,
          title: 'Optimize Database',
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.optimizeDatabase),
        ),
        SettingsActionTile(
          icon: Icons.save_alt,
          title: 'Checkpoint WAL',
          subtitle: 'Flushes the write-ahead log into the database file.',
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.checkpointWal),
        ),
        SettingsActionTile(
          icon: Icons.compress,
          title: 'Vacuum Database',
          subtitle: 'Reclaims free space after large deletes/imports.',
          onTap:
              _maintenanceRunning
                  ? null
                  : () => _runMaintenance(_repo.vacuumDatabase),
        ),
      ]),
    );
  }

  Widget _buildDeveloperExportSection() {
    return SettingsSection(
      title: 'Definition Exports',
      subtitle: 'Export app definition files for inspection or tooling.',
      accentColor: SettingsAccent.data,
      children: settingsTilesWithDividers(context, [
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export equipment.json',
          onTap:
              () => _exportAsset(_repo.exportEquipmentJson, 'equipment.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export bodyparts.json',
          onTap:
              () => _exportAsset(_repo.exportBodypartsJson, 'bodyparts.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export muscles.json',
          onTap: () => _exportAsset(_repo.exportMusclesJson, 'muscles.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export exercises.json',
          onTap:
              () => _exportAsset(_repo.exportExercisesJson, 'exercises.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export stretches.json',
          onTap:
              () => _exportAsset(_repo.exportStretchesJson, 'stretches.json'),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export muscle_bodypart.json',
          onTap:
              () => _exportAsset(
                _repo.exportMuscleBodypartJson,
                'muscle_bodypart.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export bodypart_ranking.json',
          onTap:
              () => _exportAsset(
                _repo.exportBodypartRankingJson,
                'bodypart_ranking.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export muscle_ranking.json',
          onTap:
              () => _exportAsset(
                _repo.exportMuscleRankingJson,
                'muscle_ranking.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export bodypart_muscle_rankings.json',
          onTap:
              () => _exportAsset(
                _repo.exportBodypartMuscleRankingsJson,
                'bodypart_muscle_rankings.json',
              ),
        ),
        SettingsActionTile(
          icon: Icons.data_object,
          title: 'Export volume_boundaries.json',
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HealthInfoRow(
            label: 'Schema',
            value:
                'v${health.schemaVersion} / target v${health.targetSchemaVersion}',
            healthy: health.isSchemaCurrent,
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(label: 'Size', value: formatBytes(health.totalBytes)),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(label: 'Journal', value: health.journalMode),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: 'Tables',
            value:
                '${health.tableCount} tables, ${health.indexCount} indexes, ${health.triggerCount} triggers',
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(
            label: 'Food search',
            value: '${health.foodCount} foods, ${health.foodFtsCount} FTS rows',
            healthy: health.isFoodSearchAligned,
          ),
          _HealthDivider(color: scheme.outlineVariant),
          _HealthInfoRow(label: 'Path', value: health.path, maxLines: 2),
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
      title: const Text('Exercise Media Manifest'),
      content: TextField(
        controller: _controller,
        autofocus: false,
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(
          labelText: 'Manifest URL',
          hintText:
              'https://cdn.tonos.app/manifests/exercise_media_manifest.json',
        ),
        minLines: 1,
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(''),
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
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
      title: const Text('Content Environment'),
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
                    '${environment.label}${environment.isProduction ? ' (production)' : ''}',
                  ),
                  subtitle: Text(
                    [
                      if (environment.description.isNotEmpty)
                        environment.description,
                      if (environment.exerciseMediaManifestUrl.isEmpty)
                        'No manifest URL configured yet.',
                    ].join('\n'),
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedEnvironmentId),
          child: const Text('Use Environment'),
        ),
      ],
    );
  }
}
