import 'dart:convert';
import 'dart:io';

import 'package:env_test/db/database_backup_policy.dart';
import 'package:env_test/db/database_maintenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('database import contract', () {
    test('accepts versioned export envelopes', () {
      final tables = <String, dynamic>{
        for (final table in kDatabaseExportTableNames) table: <Object?>[],
      };
      tables['sessions'] = [
        {'id': 1, 'date': '2026-04-26T12:00:00.000', 'duration': 45},
      ];
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(schemaVersion: 49, tables: tables),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 49);

      expect(preview.canImport, isTrue);
      expect(preview.isLegacyFormat, isFalse);
      expect(preview.schemaVersion, 49);
      expect(preview.rowCounts['sessions'], 1);
      expect(preview.isCompleteSnapshot, isTrue);
      expect(preview.canReplace, isTrue);
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
      expect(preview.canReplace, isFalse);
      expect(
        preview.warnings,
        contains('Legacy export has no schema version metadata.'),
      );
    });

    test('accepts pre-v61 workout and measurement rows for migration', () {
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(
          schemaVersion: 60,
          tables: {
            'sessions': [
              {'id': 1, 'date': '2026-03-08T00:30:00-05:00', 'duration': 45},
            ],
            'measurements': [
              {
                'id': 1,
                'def_id': 1,
                'timestamp': '2026-03-08T00:30:00-05:00',
                'value': 70.0,
                'unit': 'kg',
              },
            ],
          },
          formatVersion: 2,
        ),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 61);

      expect(preview.canImport, isTrue);
      expect(
        preview.warnings,
        contains('Export schema v60 is older than app schema v61.'),
      );
      expect(preview.rowCounts['sessions'], 1);
      expect(preview.rowCounts['measurements'], 1);
      expect(preview.canReplace, isFalse);
    });

    test('blocks incomplete current snapshots before replacement', () {
      final jsonStr = jsonEncode(
        buildDatabaseExportEnvelope(
          schemaVersion: 61,
          tables: {'sessions': const []},
        ),
      );

      final preview = inspectDatabaseImport(jsonStr, currentSchemaVersion: 61);

      expect(preview.canImport, isFalse);
      expect(preview.canReplace, isFalse);
      expect(preview.missingRequiredTables, isNotEmpty);
      expect(preview.invalidTables, contains('exercises'));
    });

    test('requires current snapshot scope and policy metadata', () {
      final tables = <String, dynamic>{
        for (final table in kDatabaseExportTableNames) table: const [],
      };
      final envelope =
          buildDatabaseExportEnvelope(schemaVersion: 61, tables: tables)
            ..remove('backupScope')
            ..['backupPolicyVersion'] = -1;
      final preview = inspectDatabaseImport(
        jsonEncode(envelope),
        currentSchemaVersion: 61,
      );

      expect(preview.canImport, isFalse);
      expect(
        preview.invalidTables,
        containsAll(['backup_scope_metadata', 'backup_policy_metadata']),
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

    test('every durable schema table has an explicit backup policy', () {
      final schemaSources = [
        File('lib/db/schema.dart').readAsStringSync(),
        File('lib/db/content_dao.dart').readAsStringSync(),
      ];
      final tablePattern = RegExp(
        r'CREATE\s+(?:VIRTUAL\s+)?TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([A-Za-z_][A-Za-z0-9_]*)',
        caseSensitive: false,
      );
      const temporaryOrDynamicNames = {
        'favorite_foods_new',
        'food_barcodes_new',
        'for',
        'temp',
      };
      final schemaTables = <String>{
        for (final source in schemaSources)
          for (final match in tablePattern.allMatches(source))
            match.group(1)!.toLowerCase(),
      }..removeAll(temporaryOrDynamicNames);

      expect(
        kDatabaseBackupPolicyByName.keys.toSet(),
        containsAll(schemaTables),
      );
      expect(
        kDatabaseBackupPolicyByName.length,
        kDatabaseBackupTablePolicies.length,
      );
    });

    test('personal allocation overrides are part of complete snapshots', () {
      expect(
        kDatabaseExportTableNames,
        containsAll([
          'exercise_allocation_source',
          'exercise_allocation_user_override',
          'active_workout_draft',
          'pending_workout_progression',
        ]),
      );
      expect(kDatabaseExportTableNames, isNot(contains('day_totals_cache')));
      expect(
        kDatabaseExportTableNames,
        isNot(contains('workout_set_record_events')),
      );
    });

    test('exports every required table in one database transaction', () {
      final helper = File('lib/db/database_helper.dart').readAsStringSync();
      final exportStart = helper.indexOf('Future<String> exportDatabase()');
      final exportEnd = helper.indexOf(
        'Future<void> importDatabase',
        exportStart,
      );
      expect(exportStart, isNot(-1));
      expect(exportEnd, greaterThan(exportStart));

      final exportBody = helper.substring(exportStart, exportEnd);
      final transactionIndex = exportBody.indexOf('await db.transaction');
      final queryIndex = exportBody.indexOf('await txn.query(table)');
      final envelopeIndex = exportBody.indexOf('buildDatabaseExportEnvelope');

      expect(transactionIndex, isNot(-1));
      expect(queryIndex, greaterThan(transactionIndex));
      expect(envelopeIndex, greaterThan(queryIndex));
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
      final fullSnapshotGuardIndex = importBody.indexOf(
        'if (replaceSnapshot) {',
      );
      final rebuildIndex = importBody.indexOf(
        'await _rebuildFoodFtsIfExists(db);',
      );
      final restoreIndex = importBody.lastIndexOf(
        'await _ensureFoodFtsTriggers(db);',
      );

      expect(dropIndex, isNot(-1));
      expect(fullSnapshotGuardIndex, greaterThan(dropIndex));
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
      final replaceDecisionIndex = importBody.indexOf(
        'final replaceSnapshot = clearFirst && preview.canReplace;',
      );
      final normalizedIndex = importBody.indexOf(
        'await _backfillNormalizedFoodKeysTx(txn);',
      );
      final energyIndex = importBody.indexOf(
        'await _backfillEnergyKcalFromMacros(txn);',
      );
      final foreignKeyIndex = importBody.indexOf('PRAGMA foreign_key_check');
      final canonicalizationIndex = importBody.indexOf(
        'await Schema.migrateV61(db);',
      );
      final recordsRebuildIndex = importBody.indexOf(
        'await WorkoutRecordEventsDao.rebuildAll(db);',
      );

      expect(previewIndex, isNot(-1));
      expect(transactionIndex, greaterThan(previewIndex));
      expect(replaceDecisionIndex, greaterThan(previewIndex));
      expect(clearIndex, greaterThan(transactionIndex));
      expect(normalizedIndex, greaterThan(clearIndex));
      expect(energyIndex, greaterThan(normalizedIndex));
      expect(foreignKeyIndex, greaterThan(energyIndex));
      expect(canonicalizationIndex, greaterThan(foreignKeyIndex));
      expect(recordsRebuildIndex, greaterThan(canonicalizationIndex));
    });
  });
}
