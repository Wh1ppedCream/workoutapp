import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('database settings require explicit plaintext export consent', () {
    final source =
        File(
          'lib/screens/profile/settings/database_settings_page.dart',
        ).readAsStringSync();

    final exportStart = source.indexOf('Future<void> _exportDatabase()');
    final exportEnd = source.indexOf(
      'Future<void> _importDatabase()',
      exportStart,
    );
    final exportBody = source.substring(exportStart, exportEnd);

    expect(exportBody, contains('await _confirmPlaintextExport()'));
    expect(exportBody, contains('databaseExportFailedSafe'));
    expect(source, contains('databaseConfirmExportTitle'));
    expect(source, contains('databaseConfirmExportBody'));
  });

  test('database import rejects oversized files before reading them', () {
    final source =
        File(
          'lib/screens/profile/settings/database_settings_page.dart',
        ).readAsStringSync();

    expect(source, contains('kDatabaseImportMaxBytes'));
    expect(source, contains('database_import_file_too_large'));
    expect(source, contains('databaseImportFileTooLarge'));
    expect(source, contains('databaseImportBlockedSafe'));
  });

  test('privacy pages disclose backup exclusion and plaintext exports', () {
    final privacy = File('docs/privacy.html').readAsStringSync();
    final deletion = File('docs/data-deletion.html').readAsStringSync();

    expect(
      privacy,
      contains('automatic cloud backup and device-to-device transfer'),
    );
    expect(privacy, contains('unencrypted JSON files'));
    expect(deletion, contains('unencrypted JSON files'));
    expect(deletion, contains('automatic backup and device transfer exclude'));
  });
}
