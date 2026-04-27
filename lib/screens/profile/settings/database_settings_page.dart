import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../db/database_maintenance.dart';
import '../../../repositories/app_repository.dart';

class DatabaseSettingsPage extends StatefulWidget {
  const DatabaseSettingsPage({super.key});

  @override
  State<DatabaseSettingsPage> createState() => _DatabaseSettingsPageState();
}

class _DatabaseSettingsPageState extends State<DatabaseSettingsPage> {
  final _repo = AppRepository();
  late Future<DatabaseHealthSnapshot> _healthFuture;
  bool _maintenanceRunning = false;

  @override
  void initState() {
    super.initState();
    _healthFuture = _repo.getDatabaseHealthSnapshot();
  }

  void _refreshHealth() {
    setState(() {
      _healthFuture = _repo.getDatabaseHealthSnapshot();
    });
  }

  Future<void> _exportDatabase() async {
    try {
      final jsonStr = await _repo.exportDatabase();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export Database'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(jsonStr),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importDatabase() async {
    final controller = TextEditingController();
    if (!mounted) return;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Database'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;

    final preview = _repo.previewDatabaseImport(result);
    if (!preview.canImport) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import blocked: ${preview.message}')),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await _confirmImport(preview);
    if (confirmed != true) return;

    try {
      final backup = await _repo.exportDatabase();
      await Clipboard.setData(ClipboardData(text: backup));
      await _repo.importDatabase(result, clearFirst: true);
      if (!mounted) return;
      _refreshHealth();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Import succeeded. Previous database copied to clipboard.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  Future<bool?> _confirmImport(DatabaseImportPreview preview) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Import'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This replaces the local database. A backup of the current '
                  'database will be copied to the clipboard first.',
                ),
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
                  for (final warning in preview.warnings) Text('- $warning'),
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
    final icon = healthy == null
        ? Icons.info_outline
        : healthy
            ? Icons.check_circle_outline
            : Icons.warning_amber_outlined;
    final color = healthy == null
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

  /// Generic asset exporter dialog
  Future<void> _exportAsset(
    Future<String> Function() exporter,
    String filename,
  ) async {
    try {
      final jsonStr = await exporter();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Export $filename'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(jsonStr),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$filename copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export $filename failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Entire Database'),
            onTap: _exportDatabase,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Database'),
            onTap: _importDatabase,
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Health & Maintenance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          FutureBuilder<DatabaseHealthSnapshot>(
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
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Database Health'),
            onTap: _maintenanceRunning ? null : _refreshHealth,
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            title: const Text('Run Integrity Check'),
            onTap: _maintenanceRunning
                ? null
                : () => _runMaintenance(_repo.runDatabaseIntegrityCheck),
          ),
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: const Text('Optimize Database'),
            subtitle: const Text('Runs SQLite PRAGMA optimize.'),
            onTap: _maintenanceRunning
                ? null
                : () => _runMaintenance(_repo.optimizeDatabase),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Checkpoint WAL'),
            subtitle: const Text(
              'Flushes the write-ahead log into the database file.',
            ),
            onTap: _maintenanceRunning
                ? null
                : () => _runMaintenance(_repo.checkpointWal),
          ),
          ListTile(
            leading: const Icon(Icons.compress),
            title: const Text('Vacuum Database'),
            subtitle: const Text('Reclaims free space after large deletes/imports.'),
            onTap: _maintenanceRunning
                ? null
                : () => _runMaintenance(_repo.vacuumDatabase),
          ),

          const Divider(),

          // Asset‐style exports
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export equipment.json'),
            onTap: () =>
                _exportAsset(_repo.exportEquipmentJson, 'equipment.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export bodyparts.json'),
            onTap: () =>
                _exportAsset(_repo.exportBodypartsJson, 'bodyparts.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscles.json'),
            onTap: () => _exportAsset(_repo.exportMusclesJson, 'muscles.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export exercises.json'),
            onTap: () =>
                _exportAsset(_repo.exportExercisesJson, 'exercises.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export stretches.json'),
            onTap: () =>
                _exportAsset(_repo.exportStretchesJson, 'stretches.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscle_bodypart.json'),
            onTap: () => _exportAsset(
                _repo.exportMuscleBodypartJson, 'muscle_bodypart.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export bodypart_ranking.json'),
            onTap: () => _exportAsset(
                _repo.exportBodypartRankingJson, 'bodypart_ranking.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export muscle_ranking.json'),
            onTap: () => _exportAsset(
                _repo.exportMuscleRankingJson, 'muscle_ranking.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title:
                const Text('Export bodypart_muscle_rankings.json'),
            onTap: () => _exportAsset(_repo.exportBodypartMuscleRankingsJson,
                'bodypart_muscle_rankings.json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export volume_boundaries.json'),
            onTap: () => _exportAsset(
                _repo.exportVolumeBoundariesJson, 'volume_boundaries.json'),
          ),
        ],
      ),
    );
  }
}
