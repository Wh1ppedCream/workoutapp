import 'dart:convert';
import 'dart:io';

import 'package:env_test/db/database_maintenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('database import contract', () {
    test('accepts versioned export envelopes', () {
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(
          schemaVersion: 49,
          tables: {
            'sessions': [
              {'id': 1, 'date': '2026-04-26T12:00:00.000', 'duration': 45},
            ],
            'foods': const [],
          },
        ),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 49);

      expect(preview.canImport, isTrue);
      expect(preview.isLegacyFormat, isFalse);
      expect(preview.schemaVersion, 49);
      expect(preview.rowCounts['sessions'], 1);
      expect(decodeDatabaseExportTables(jsonStr), contains('sessions'));
    });

    test('keeps backward compatibility with legacy table-map exports', () {
      final jsonStr = jsonEncode({
        'sessions': [
          {'id': 1, 'date': '2026-04-26T12:00:00.000', 'duration': 45},
        ],
      });

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 49);

      expect(preview.canImport, isTrue);
      expect(preview.isLegacyFormat, isTrue);
      expect(
        preview.warnings,
        contains('Legacy export has no schema version metadata.'),
      );
    });

    test('blocks exports from newer schemas before destructive import', () {
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(
          schemaVersion: 50,
          tables: {'sessions': const []},
        ),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 49);

      expect(preview.canImport, isFalse);
      expect(preview.schemaVersionTooNew, isTrue);
      expect(preview.message, contains('newer than app schema'));
    });

    test('rejects malformed table rows before destructive import', () {
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(
          schemaVersion: 49,
          tables: {
            'sessions': ['not a row map'],
          },
        ),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 49);

      expect(preview.canImport, isFalse);
      expect(preview.invalidTables, contains('sessions'));
    });

    test('export table allow-list has no duplicates', () {
      expect(
        kDatabaseExportTableNames.toSet().length,
        kDatabaseExportTableNames.length,
      );
    });

    test('full imports suspend food FTS triggers during rebuild', () {
      final helper = File('lib/db/database_helper.dart').readAsStringSync();

      expect(helper, contains('Future<void> _dropFoodFtsTriggers'));
      expect(helper, contains('DROP TRIGGER IF EXISTS foods_ai'));
      expect(helper, contains('DROP TRIGGER IF EXISTS foods_ad'));
      expect(helper, contains('DROP TRIGGER IF EXISTS foods_au'));

      final importStart = helper.indexOf('Future<void> importDatabase');
      expect(importStart, isNot(-1));
      final importEnd = helper.indexOf('// equipment.json', importStart);
      expect(importEnd, greaterThan(importStart));
      final importBody = helper.substring(importStart, importEnd);

      final dropIndex = importBody.indexOf('await _dropFoodFtsTriggers(db);');
      final clearIndex = importBody.indexOf(
        'final tablesToClear = kDatabaseExportTableNames.reversed;',
      );
      final rebuildIndex = importBody.indexOf(
        'await _rebuildFoodFtsIfExists(db);',
      );
      final restoreIndex = importBody.lastIndexOf(
        'await _ensureFoodFtsTriggers(db);',
      );

      expect(dropIndex, isNot(-1));
      expect(clearIndex, greaterThan(dropIndex));
      expect(rebuildIndex, greaterThan(clearIndex));
      expect(restoreIndex, greaterThan(rebuildIndex));
    });
  });
}
