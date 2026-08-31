import 'dart:convert';

import 'database_backup_policy.dart';

const String kDatabaseExportFormat = 'env_test.database_export';
const int kDatabaseExportFormatVersion = 3;
const Set<int> kSupportedDatabaseExportFormatVersions = {2, 3};
const int kDatabaseImportMaxBytes = 25 * 1024 * 1024;
const int kDatabaseImportMaxRows = 250000;
const int kDatabaseImportMaxRowsPerTable = 100000;
const int kDatabaseImportMaxTextFieldLength = 100000;

class DatabaseHealthSnapshot {
  const DatabaseHealthSnapshot({
    required this.path,
    required this.schemaVersion,
    required this.targetSchemaVersion,
    required this.journalMode,
    required this.databaseBytes,
    required this.walBytes,
    required this.shmBytes,
    required this.pageCount,
    required this.pageSize,
    required this.tableCount,
    required this.indexCount,
    required this.triggerCount,
    required this.foodCount,
    required this.foodFtsCount,
    required this.checkedAt,
  });

  final String path;
  final int schemaVersion;
  final int targetSchemaVersion;
  final String journalMode;
  final int databaseBytes;
  final int walBytes;
  final int shmBytes;
  final int pageCount;
  final int pageSize;
  final int tableCount;
  final int indexCount;
  final int triggerCount;
  final int foodCount;
  final int foodFtsCount;
  final DateTime checkedAt;

  int get totalBytes => databaseBytes + walBytes + shmBytes;
  bool get isSchemaCurrent => schemaVersion == targetSchemaVersion;
  bool get isFoodSearchAligned =>
      foodCount == 0 || foodFtsCount >= (foodCount * 0.9).floor();
}

class DatabaseMaintenanceResult {
  const DatabaseMaintenanceResult({
    required this.title,
    required this.message,
    this.rows = const [],
  });

  final String title;
  final String message;
  final List<Map<String, Object?>> rows;
}

class DatabaseImportPreview {
  const DatabaseImportPreview({
    required this.valid,
    required this.message,
    required this.isLegacyFormat,
    required this.importableTables,
    required this.unknownTables,
    required this.invalidTables,
    required this.warnings,
    required this.rowCounts,
    required this.missingRequiredTables,
    this.schemaVersion,
    this.formatVersion,
    this.schemaVersionTooNew = false,
    this.isCompleteSnapshot = false,
  });

  final bool valid;
  final String message;
  final bool isLegacyFormat;
  final int? schemaVersion;
  final int? formatVersion;
  final bool schemaVersionTooNew;
  final List<String> importableTables;
  final List<String> unknownTables;
  final List<String> invalidTables;
  final List<String> warnings;
  final Map<String, int> rowCounts;
  final List<String> missingRequiredTables;
  final bool isCompleteSnapshot;

  bool get canImport =>
      valid &&
      !schemaVersionTooNew &&
      importableTables.isNotEmpty &&
      unknownTables.isEmpty &&
      invalidTables.isEmpty;

  /// Only a current, complete snapshot may replace existing database data.
  /// Older backups can merge their available rows without first clearing data.
  bool get canReplace => canImport && isCompleteSnapshot;

  int get totalRows =>
      rowCounts.values.fold<int>(0, (sum, count) => sum + count);
}

Map<String, dynamic> buildDatabaseExportEnvelope({
  required int schemaVersion,
  required Map<String, dynamic> tables,
  int formatVersion = kDatabaseExportFormatVersion,
}) {
  final envelope = <String, dynamic>{
    'format': kDatabaseExportFormat,
    'formatVersion': formatVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'tables': tables,
  };
  if (formatVersion >= kDatabaseExportFormatVersion) {
    envelope.addAll({
      'backupScope': 'database',
      'backupPolicyVersion': kDatabaseBackupPolicyVersion,
      'isCompleteSnapshot': true,
    });
  }
  return envelope;
}

Map<String, dynamic> decodeDatabaseExportTables(String jsonStr) {
  final decoded = jsonDecode(jsonStr);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Database import must be a JSON object.');
  }

  if (decoded['format'] == kDatabaseExportFormat) {
    final tables = decoded['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException(
        'Database export is missing a tables object.',
      );
    }
    return tables;
  }

  // Backward compatibility for older exports that were just a table map.
  return decoded;
}

DatabaseImportPreview inspectDatabaseImport(
  String jsonStr, {
  required int currentSchemaVersion,
  Iterable<String>? supportedTables,
}) {
  final supported =
      (supportedTables ?? kDatabaseBackupPolicyByName.keys).toSet();

  if (utf8.encode(jsonStr).length > kDatabaseImportMaxBytes) {
    return _invalidPreview(
      'Database import exceeds the ${kDatabaseImportMaxBytes ~/ (1024 * 1024)} MB limit.',
    );
  }

  try {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      return _invalidPreview('Database import must be a JSON object.');
    }

    final isEnvelope = decoded['format'] == kDatabaseExportFormat;
    final tablesRaw = isEnvelope ? decoded['tables'] : decoded;
    final schemaVersion = _readInt(decoded['schemaVersion']);
    final formatVersion = _readInt(decoded['formatVersion']);

    if (isEnvelope &&
        (formatVersion == null ||
            !kSupportedDatabaseExportFormatVersions.contains(formatVersion))) {
      return _invalidPreview(
        'Unsupported database export format version: $formatVersion.',
        schemaVersion: schemaVersion,
        formatVersion: formatVersion,
      );
    }

    if (tablesRaw is! Map<String, dynamic>) {
      return _invalidPreview(
        'Database export is missing a valid tables object.',
        schemaVersion: schemaVersion,
        formatVersion: formatVersion,
      );
    }

    final importableTables = <String>[];
    final unknownTables = <String>[];
    final invalidTables = <String>[];
    final warnings = <String>[];
    final rowCounts = <String, int>{};
    var totalRows = 0;

    for (final entry in tablesRaw.entries) {
      final table = entry.key;
      final rows = entry.value;

      if (!supported.contains(table)) {
        unknownTables.add(table);
        continue;
      }
      if (rows is! List || rows.any((row) => row is! Map)) {
        invalidTables.add(table);
        continue;
      }
      if (rows.length > kDatabaseImportMaxRowsPerTable ||
          rows.any((row) => !_isSafeImportRow(row as Map))) {
        invalidTables.add(table);
        continue;
      }

      importableTables.add(table);
      rowCounts[table] = rows.length;
      totalRows += rows.length;
    }

    if (totalRows > kDatabaseImportMaxRows) {
      return _invalidPreview(
        'Database import exceeds the $kDatabaseImportMaxRows row limit.',
        schemaVersion: schemaVersion,
        formatVersion: formatVersion,
      );
    }

    final requiredTables = kDatabaseExportTableNames.toSet();
    final presentTables = importableTables.toSet();
    final missingRequiredTables =
        requiredTables.difference(presentTables).toList()..sort();
    final isCurrentFormat =
        isEnvelope && formatVersion == kDatabaseExportFormatVersion;
    final declaresCompleteSnapshot = decoded['isCompleteSnapshot'] == true;
    final isCompleteSnapshot =
        isCurrentFormat &&
        declaresCompleteSnapshot &&
        missingRequiredTables.isEmpty;

    if (isCurrentFormat && !declaresCompleteSnapshot) {
      invalidTables.add('backup_snapshot_metadata');
    }
    if (isCurrentFormat && decoded['backupScope'] != 'database') {
      invalidTables.add('backup_scope_metadata');
    }
    if (isCurrentFormat && missingRequiredTables.isNotEmpty) {
      invalidTables.addAll(missingRequiredTables);
    } else if (!isCompleteSnapshot && missingRequiredTables.isNotEmpty) {
      warnings.add(
        'Legacy or partial import will merge available data and cannot replace the current database.',
      );
    }

    final schemaVersionTooNew =
        schemaVersion != null && schemaVersion > currentSchemaVersion;
    if (schemaVersion == null) {
      warnings.add('Legacy export has no schema version metadata.');
    } else if (schemaVersion < currentSchemaVersion) {
      warnings.add(
        'Export schema v$schemaVersion is older than app schema v$currentSchemaVersion.',
      );
    } else if (schemaVersionTooNew) {
      warnings.add(
        'Export schema v$schemaVersion is newer than app schema v$currentSchemaVersion.',
      );
    }
    if (unknownTables.isNotEmpty) {
      warnings.add(
        '${unknownTables.length} unknown table(s) are not supported.',
      );
    }
    if (isCurrentFormat &&
        decoded['backupPolicyVersion'] != kDatabaseBackupPolicyVersion) {
      invalidTables.add('backup_policy_metadata');
    }

    final message =
        schemaVersionTooNew
            ? 'Export schema v$schemaVersion is newer than app schema v$currentSchemaVersion.'
            : invalidTables.isNotEmpty
            ? '${invalidTables.length} table(s) have invalid row data.'
            : unknownTables.isNotEmpty
            ? '${unknownTables.length} table(s) are not supported.'
            : isCurrentFormat && missingRequiredTables.isNotEmpty
            ? 'Database backup is missing ${missingRequiredTables.length} required table(s).'
            : 'Found ${importableTables.length} importable table(s).';

    return DatabaseImportPreview(
      valid: true,
      message: message,
      isLegacyFormat: !isEnvelope,
      schemaVersion: schemaVersion,
      formatVersion: formatVersion,
      schemaVersionTooNew: schemaVersionTooNew,
      importableTables: importableTables..sort(),
      unknownTables: unknownTables..sort(),
      invalidTables: invalidTables..sort(),
      warnings: warnings,
      rowCounts: rowCounts,
      missingRequiredTables: missingRequiredTables,
      isCompleteSnapshot: isCompleteSnapshot,
    );
  } on FormatException catch (e) {
    return _invalidPreview(e.message);
  } catch (e) {
    return _invalidPreview('Could not read database import: $e');
  }
}

bool _isSafeImportRow(Map row) {
  if (row.keys.any((key) => key is! String)) return false;

  for (final value in row.values) {
    if (value is String && value.length > kDatabaseImportMaxTextFieldLength) {
      return false;
    }
    if (value is Map || value is List) return false;
    if (value != null && value is! num && value is! bool && value is! String) {
      return false;
    }
  }
  return true;
}

DatabaseImportPreview _invalidPreview(
  String message, {
  int? schemaVersion,
  int? formatVersion,
}) {
  return DatabaseImportPreview(
    valid: false,
    message: message,
    isLegacyFormat: false,
    schemaVersion: schemaVersion,
    formatVersion: formatVersion,
    importableTables: const [],
    unknownTables: const [],
    invalidTables: const [],
    warnings: const [],
    rowCounts: const {},
    missingRequiredTables: const [],
  );
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
