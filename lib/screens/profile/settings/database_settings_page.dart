import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../db/database_maintenance.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../utils/tutorial_launcher.dart';
import '../../../widgets/guided_tutorial_overlay.dart';

class DatabaseSettingsPage extends StatefulWidget {
  const DatabaseSettingsPage({super.key});

  @override
  State<DatabaseSettingsPage> createState() => _DatabaseSettingsPageState();
}

class _DatabaseSettingsPageState extends State<DatabaseSettingsPage> {
  static const String _exerciseMediaManifestUrlKey =
      'content.exercise_media.remote_manifest_url';

  late final AppRepository _repo;
  late Future<DatabaseHealthSnapshot> _healthFuture;
  late Future<ContentCacheUsage> _contentCacheFuture;
  late Future<ContentManifestStatus?> _exerciseMediaManifestStatusFuture;
  late Future<String> _manifestUrlFuture;
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
    _manifestUrlFuture = _loadManifestUrl();
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
      _manifestUrlFuture = _loadManifestUrl();
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

  Widget _healthRow(String label, String value, {bool? healthy}) {
    final icon =
        healthy == null
            ? Icons.info_outline
            : healthy
            ? Icons.check_circle_outline
            : Icons.warning_amber_outlined;
    final color =
        healthy == null
            ? null
            : healthy
            ? Colors.green
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          SizedBox(width: 92, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
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

  Future<String> _loadManifestUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_exerciseMediaManifestUrlKey) ?? '';
  }

  Future<void> _saveManifestUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(_exerciseMediaManifestUrlKey);
    } else {
      await prefs.setString(_exerciseMediaManifestUrlKey, trimmed);
    }
    if (!mounted) return;
    _refreshContentStatus();
  }

  Future<void> _editManifestUrl() async {
    final currentUrl = await _loadManifestUrl();
    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ManifestUrlDialog(initialUrl: currentUrl),
    );

    if (result == null) return;
    if (!mounted) return;
    await _saveManifestUrl(result);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Cloud Content', style: theme.textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            child: Column(
              children: [
                FutureBuilder<String>(
                  future: _manifestUrlFuture,
                  builder: (context, snapshot) {
                    final url = snapshot.data ?? '';
                    return ListTile(
                      leading: const Icon(Icons.cloud_outlined),
                      title: const Text('Exercise Media Manifest'),
                      subtitle: Text(
                        url.isEmpty ? 'No remote manifest URL set.' : url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Edit URL',
                        icon: const Icon(Icons.edit),
                        onPressed:
                            _contentActionRunning ? null : _editManifestUrl,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                FutureBuilder<ContentManifestStatus?>(
                  future: _exerciseMediaManifestStatusFuture,
                  builder: (context, snapshot) {
                    final status = snapshot.data;
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(
                        status == null
                            ? 'No exercise media manifest synced'
                            : 'Manifest v${status.version}',
                      ),
                      subtitle: Text(
                        'Last checked: ${_formatDateTime(status?.lastCheckedAt)}',
                      ),
                    );
                  },
                ),
                FutureBuilder<ContentCacheUsage>(
                  future: _contentCacheFuture,
                  builder: (context, snapshot) {
                    final usage =
                        snapshot.data ??
                        const ContentCacheUsage(fileCount: 0, totalBytes: 0);
                    return ListTile(
                      leading: const Icon(Icons.folder_copy_outlined),
                      title: const Text('Downloaded Media Cache'),
                      subtitle: Text(
                        '${usage.fileCount} files, ${_formatBytes(usage.totalBytes)}',
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      _contentActionRunning
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.sync),
                  title: const Text('Sync Remote Exercise Media'),
                  subtitle: const Text(
                    'Fetches the manifest from your configured CDN URL.',
                  ),
                  onTap:
                      _contentActionRunning
                          ? null
                          : _syncRemoteExerciseMediaManifest,
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Load Bundled Manifest'),
                  subtitle: const Text(
                    'Loads the safe local manifest included with the app.',
                  ),
                  onTap:
                      _contentActionRunning
                          ? null
                          : _syncBundledExerciseMediaManifest,
                ),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('Clear Downloaded Media Cache'),
                  onTap: _contentActionRunning ? null : _clearContentCache,
                ),
              ],
            ),
          ),
        ),
      ],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Database Settings')),
      body: ListView(
        children: [
          KeyedSubtree(
            key: _fileActionsTutorialKey,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Entire Database to File'),
                  onTap: _exportDatabase,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Database from File'),
                  onTap: _importDatabase,
                ),
              ],
            ),
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Health & Maintenance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          KeyedSubtree(
            key: _healthTutorialKey,
            child: FutureBuilder<DatabaseHealthSnapshot>(
              future: _healthFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Checking database health...'),
                  );
                }

                if (snapshot.hasError) {
                  return ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Database health check failed'),
                    subtitle: Text('${snapshot.error}'),
                    trailing: IconButton(
                      tooltip: 'Retry',
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshHealth,
                    ),
                  );
                }

                final health = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _healthRow(
                            'Schema',
                            'v${health.schemaVersion} / target v${health.targetSchemaVersion}',
                            healthy: health.isSchemaCurrent,
                          ),
                          _healthRow('Size', _formatBytes(health.totalBytes)),
                          _healthRow('Journal', health.journalMode),
                          _healthRow(
                            'Tables',
                            '${health.tableCount} tables, ${health.indexCount} indexes, ${health.triggerCount} triggers',
                          ),
                          _healthRow(
                            'Food search',
                            '${health.foodCount} foods, ${health.foodFtsCount} FTS rows',
                            healthy: health.isFoodSearchAligned,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            health.path,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          KeyedSubtree(
            key: _maintenanceTutorialKey,
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Database Health'),
              onTap: _maintenanceRunning ? null : _refreshHealth,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            title: const Text('Run Integrity Check'),
            onTap:
                _maintenanceRunning
                    ? null
                    : () => _runMaintenance(_repo.runDatabaseIntegrityCheck),
          ),
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: const Text('Optimize Database'),
            subtitle: const Text('Runs SQLite PRAGMA optimize.'),
            onTap:
                _maintenanceRunning
                    ? null
                    : () => _runMaintenance(_repo.optimizeDatabase),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Checkpoint WAL'),
            subtitle: const Text(
              'Flushes the write-ahead log into the database file.',
            ),
            onTap:
                _maintenanceRunning
                    ? null
                    : () => _runMaintenance(_repo.checkpointWal),
          ),
          ListTile(
            leading: const Icon(Icons.compress),
            title: const Text('Vacuum Database'),
            subtitle: const Text(
              'Reclaims free space after large deletes/imports.',
            ),
            onTap:
                _maintenanceRunning
                    ? null
                    : () => _runMaintenance(_repo.vacuumDatabase),
          ),

          _buildCloudContentSection(),

          const Divider(),

          // Asset‐style exports
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export equipment.json'),
            onTap:
                () => _exportAsset(_repo.exportEquipmentJson, 'equipment.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export bodyparts.json'),
            onTap:
                () => _exportAsset(_repo.exportBodypartsJson, 'bodyparts.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscles.json'),
            onTap: () => _exportAsset(_repo.exportMusclesJson, 'muscles.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export exercises.json'),
            onTap:
                () => _exportAsset(_repo.exportExercisesJson, 'exercises.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export stretches.json'),
            onTap:
                () => _exportAsset(_repo.exportStretchesJson, 'stretches.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscle_bodypart.json'),
            onTap:
                () => _exportAsset(
                  _repo.exportMuscleBodypartJson,
                  'muscle_bodypart.json',
                ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export bodypart_ranking.json'),
            onTap:
                () => _exportAsset(
                  _repo.exportBodypartRankingJson,
                  'bodypart_ranking.json',
                ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscle_ranking.json'),
            onTap:
                () => _exportAsset(
                  _repo.exportMuscleRankingJson,
                  'muscle_ranking.json',
                ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export bodypart_muscle_rankings.json'),
            onTap:
                () => _exportAsset(
                  _repo.exportBodypartMuscleRankingsJson,
                  'bodypart_muscle_rankings.json',
                ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export volume_boundaries.json'),
            onTap:
                () => _exportAsset(
                  _repo.exportVolumeBoundariesJson,
                  'volume_boundaries.json',
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
