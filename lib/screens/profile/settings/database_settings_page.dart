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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Database'),
            onTap: _exportDatabase,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Database'),
            onTap: _importDatabase,
          ),
        ],
      ),
    );
  }
}
