import 'dart:convert';

const String kDatabaseExportFormat = 'env_test.database_export';
const int kDatabaseExportFormatVersion = 2;

const List<String> kDatabaseExportTableNames = [
  'sessions',
  'exercises',
  'sets',
  'cardio_details',
  'stretch_instances',
  'stretch_instance_items',
  'measurement_definitions',
  'measurements',
  'equipment',
  'bodypart',
  'muscles',
  'exercise_definitions',
  'exercise_equipment',
  'exercise_bodypart',
  'exercise_muscle',
  'stretch_definitions',
  'stretch_bodypart',
  'muscle_bodypart',
  'bodypart_ranking',
  'muscle_ranking',
  'exercise_muscle_percent',
  'bodypart_muscle_rankings',
  'muscle_volume_boundaries',
  'bodypart_volume_boundaries',
  'preset_definitions',
  'preset_exercises',
  'preset_sets',
  'preset_cardio_details',
  'preset_stretch_items',
  'gym_profiles',
  'profile_equipment',
  'exercise_rep_max',
  'exercise_volume_max',
  'nutrients',
  'nutrient_aliases',
  'nutrient_groups',
  'nutrient_group_members',
  'foods',
  'food_portions',
  'food_barcodes',
  'food_nutrients',
  'food_nutrient_values',
  'recipes',
  'recipe_ingredients',
  'recipe_nutrients',
  'diary_entries',
  'day_totals_cache',
  'nutrition_goals',
  'brands',
  'sources',
  'categories',
  'food_usage_stats',
  'favorite_foods',
  'diary_entry_tags',
  'diary_entry_audit',
  'personal_info',
  'flow_defaults',
  'flow_default_methods',
  'preset_flow_methods',
  'formula_settings',
  'exercise_bodypart_percent',
  'preset_auto_settings',
  'preset_exercise_auto',
  'preset_set_auto',
  'active_plans',
  'active_workout_draft',
];

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
    this.schemaVersion,
    this.formatVersion,
    this.schemaVersionTooNew = false,
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

  bool get canImport =>
      valid &&
      !schemaVersionTooNew &&
      importableTables.isNotEmpty &&
      invalidTables.isEmpty;

  int get totalRows => rowCounts.values.fold<int>(0, (sum, count) => sum + count);
}

Map<String, dynamic> buildDatabaseExportEnvelope({
  required int schemaVersion,
  required Map<String, dynamic> tables,
}) {
  return {
    'format': kDatabaseExportFormat,
    'formatVersion': kDatabaseExportFormatVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'tables': tables,
  };
}

Map<String, dynamic> decodeDatabaseExportTables(String jsonStr) {
  final decoded = jsonDecode(jsonStr);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Database import must be a JSON object.');
  }

  if (decoded['format'] == kDatabaseExportFormat) {
    final tables = decoded['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException('Database export is missing a tables object.');
    }
    return tables;
  }

  // Backward compatibility for older exports that were just a table map.
  return decoded;
}

DatabaseImportPreview inspectDatabaseImport(
  String jsonStr, {
  required int currentSchemaVersion,
  Iterable<String> supportedTables = kDatabaseExportTableNames,
}) {
  final supported = supportedTables.toSet();

  try {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      return _invalidPreview('Database import must be a JSON object.');
    }

    final isEnvelope = decoded['format'] == kDatabaseExportFormat;
    final tablesRaw = isEnvelope ? decoded['tables'] : decoded;
    final schemaVersion = _readInt(decoded['schemaVersion']);
    final formatVersion = _readInt(decoded['formatVersion']);

    if (isEnvelope && formatVersion != kDatabaseExportFormatVersion) {
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

      importableTables.add(table);
      rowCounts[table] = rows.length;
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
      warnings.add('${unknownTables.length} unknown table(s) will be skipped.');
    }

    final message = schemaVersionTooNew
        ? 'Export schema v$schemaVersion is newer than app schema v$currentSchemaVersion.'
        : invalidTables.isNotEmpty
            ? '${invalidTables.length} table(s) have invalid row data.'
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
    );
  } on FormatException catch (e) {
    return _invalidPreview(e.message);
  } catch (e) {
    return _invalidPreview('Could not read database import: $e');
  }
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
  );
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
