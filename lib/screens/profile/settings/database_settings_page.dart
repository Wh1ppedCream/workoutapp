import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../repositories/app_repository.dart';

class DatabaseSettingsPage extends StatefulWidget {
  const DatabaseSettingsPage({super.key});

  @override
  State<DatabaseSettingsPage> createState() => _DatabaseSettingsPageState();
}

class _DatabaseSettingsPageState extends State<DatabaseSettingsPage> {
  final _repo = AppRepository();

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
    if (result == null) return;
    try {
      await _repo.importDatabase(result, clearFirst: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import succeeded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
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