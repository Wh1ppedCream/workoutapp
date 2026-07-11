// File: lib/screens/profile/settings/app_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../repositories/app_repository.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key}); // use_super_parameters

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final _repo = AppRepository();

  Future<void> _exportDatabase() async {
    try {
      final jsonStr = await _repo.exportDatabase();

      if (!mounted) return; // guard context after async

      await showDialog<void>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Export Database'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(child: SelectableText(jsonStr)),
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
      if (!mounted) return; // guard context
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importDatabase() async {
    final controller = TextEditingController();
    String? result;
    try {
      if (!mounted) return; // guard before dialog
      result = await showDialog<String?>(
        context: context,
        builder:
            (ctx) => AlertDialog(
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
    } finally {
      controller.dispose();
    }

    if (result == null) return;
    try {
      await _repo.importDatabase(result, clearFirst: true);

      if (!mounted) return; // guard before showing snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Import succeeded')));
    } catch (e) {
      if (!mounted) return; // guard before showing snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
