// File: lib/db/db_query_utils.dart

const int sqliteBindParameterChunkSize = 800;

Iterable<List<T>> sqliteChunks<T>(
  List<T> values, {
  int chunkSize = sqliteBindParameterChunkSize,
}) sync* {
  for (var start = 0; start < values.length; start += chunkSize) {
    final chunkEnd = start + chunkSize;
    final end = chunkEnd < values.length ? chunkEnd : values.length;
    yield values.sublist(start, end);
  }
}

String sqlitePlaceholders(int count) => List.filled(count, '?').join(',');

int sqliteBool(bool value) => value ? 1 : 0;

Map<String, dynamic>? firstDynamicRow(List<Map<String, Object?>> rows) {
  return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
}

List<Map<String, dynamic>> dynamicRows(List<Map<String, Object?>> rows) {
  return rows.map((row) => Map<String, dynamic>.from(row)).toList();
}
