// File: lib/screens/profile/settings/app_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key}); // use_super_parameters

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  AppRepository get _repo => context.read<AppRepository>();

  Future<void> _exportDatabase() async {
    try {
      final jsonStr = await _repo.exportDatabase();

      if (!mounted) return; // guard context after async

      await showDialog<void>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text(AppLocalizations.of(context).databaseExportTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(child: SelectableText(jsonStr)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).databaseCopied,
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context).commonCopy),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLocalizations.of(context).commonClose),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return; // guard context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).databaseExportFailed(e.toString()),
          ),
        ),
      );
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
              title: Text(AppLocalizations.of(context).databaseImportTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: controller,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).databasePasteJson,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(AppLocalizations.of(context).commonCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(controller.text),
                  child: Text(AppLocalizations.of(context).commonImport),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).databaseImportSucceeded),
        ),
      );
    } catch (e) {
      if (!mounted) return; // guard before showing snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).databaseImportFailed(e.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(AppLocalizations.of(context).databaseExportTitle),
            onTap: _exportDatabase,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(AppLocalizations.of(context).databaseImportTitle),
            onTap: _importDatabase,
          ),
        ],
      ),
    );
  }
}
