import 'dart:convert';

import 'package:env_test/db/database_maintenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('database import contract', () {
    test('accepts versioned export envelopes', () {
      final jsonStr = jsonEncode(buildDatabaseExportEnvelope(
        schemaVersion: 48,
        tables: {
          'sessions': [
            {'id': 1, 'date': '2026-04-26T12:00:00.000', 'duration': 45},
          ],
          'foods': const [],
        },
      ));

      final preview = inspectDatabaseImport(
        jsonStr,
        currentSchemaVersion: 48,
      );

      expect(preview.canImport, isTrue);
      expect(preview.isLegacyFormat, isFalse);
      expect(preview.schemaVersion, 48);
      expect(preview.rowCounts['sessions'], 1);
      expect(decodeDatabaseExportTables(jsonStr), contains('sessions'));
    });

    test('keeps backward compatibility with legacy table-map exports', () {
      final jsonStr = jsonEncode({
        'sessions': [
          {'id': 1, 'date': '2026-04-26T12:00:00.000', 'duration': 45},
        ],
      });

      final preview = inspectDatabaseImport(
        jsonStr,
        currentSchemaVersion: 48,
      );

      expect(preview.canImport, isTrue);
      expect(preview.isLegacyFormat, isTrue);
      expect(
        preview.warnings,
        contains('Legacy export has no schema version metadata.'),
      );
    });

    test('blocks exports from newer schemas before destructive import', () {
      final jsonStr = jsonEncode(buildDatabaseExportEnvelope(
        schemaVersion: 49,
        tables: {
          'sessions': const [],
        },
      ));

      final preview = inspectDatabaseImport(
        jsonStr,
        currentSchemaVersion: 48,
      );

      expect(preview.canImport, isFalse);
      expect(preview.schemaVersionTooNew, isTrue);
      expect(preview.message, contains('newer than app schema'));
    });

    test('rejects malformed table rows before destructive import', () {
      final jsonStr = jsonEncode(buildDatabaseExportEnvelope(
        schemaVersion: 48,
        tables: {
          'sessions': ['not a row map'],
        },
      ));

      final preview = inspectDatabaseImport(
        jsonStr,
        currentSchemaVersion: 48,
      );

      expect(preview.canImport, isFalse);
      expect(preview.invalidTables, contains('sessions'));
    });

    test('export table allow-list has no duplicates', () {
      expect(
        kDatabaseExportTableNames.toSet().length,
        kDatabaseExportTableNames.length,
      );
    });
  });
}
