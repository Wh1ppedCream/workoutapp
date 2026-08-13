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

    test(
      'rejects unknown tables and unsafe or oversized input before import',
      () {
        final unknown = inspectDatabaseImport(
          jsonEncode({'sessions': const [], 'unexpected_table': const []}),
          currentSchemaVersion: 49,
        );
        expect(unknown.canImport, isFalse);
        expect(unknown.unknownTables, contains('unexpected_table'));

        final nestedValue = inspectDatabaseImport(
          jsonEncode({
            'sessions': [
              {
                'id': 1,
                'metadata': {'unexpected': true},
              },
            ],
          }),
          currentSchemaVersion: 49,
        );
        expect(nestedValue.canImport, isFalse);
        expect(nestedValue.invalidTables, contains('sessions'));

        final oversizedField = inspectDatabaseImport(
          jsonEncode({
            'sessions': [
              {'id': 1, 'notes': 'x' * (kDatabaseImportMaxTextFieldLength + 1)},
            ],
          }),
          currentSchemaVersion: 49,
        );
        expect(oversizedField.canImport, isFalse);
        expect(oversizedField.invalidTables, contains('sessions'));

        final oversized = inspectDatabaseImport(
          'x' * (kDatabaseImportMaxBytes + 1),
          currentSchemaVersion: 49,
        );
        expect(oversized.canImport, isFalse);
        expect(oversized.message, contains('exceeds'));
      },
    );

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

    test('validates before replacement and keeps destructive work atomic', () {
      final helper = File('lib/db/database_helper.dart').readAsStringSync();
      final importStart = helper.indexOf('Future<void> importDatabase');
      final importEnd = helper.indexOf('// equipment.json', importStart);
      final importBody = helper.substring(importStart, importEnd);

      final previewIndex = importBody.indexOf(
        'final preview = previewDatabaseImport',
      );
      final transactionIndex = importBody.indexOf('await db.transaction');
      final clearIndex = importBody.indexOf(
        'final tablesToClear = kDatabaseExportTableNames.reversed;',
      );
      final normalizedIndex = importBody.indexOf(
        'await _backfillNormalizedFoodKeysTx(txn);',
      );
      final energyIndex = importBody.indexOf(
        'await _backfillEnergyKcalFromMacros(txn);',
      );
      final foreignKeyIndex = importBody.indexOf('PRAGMA foreign_key_check');

      expect(previewIndex, isNot(-1));
      expect(transactionIndex, greaterThan(previewIndex));
      expect(clearIndex, greaterThan(transactionIndex));
      expect(normalizedIndex, greaterThan(clearIndex));
      expect(energyIndex, greaterThan(normalizedIndex));
      expect(foreignKeyIndex, greaterThan(energyIndex));
    });
  });
}
