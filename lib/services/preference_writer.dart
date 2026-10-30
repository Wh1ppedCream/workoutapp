import 'package:shared_preferences/shared_preferences.dart';

/// Checks backend write results and restores the previous preference snapshot
/// after failure. This is best-effort compensation, not a storage transaction.
/// Callers serialize mutations to the same keys and publish state after success.
Future<void> writePreferences(
  SharedPreferences preferences,
  Map<String, Object?> changes,
) async {
  for (final value in changes.values) {
    if (value != null &&
        value is! String &&
        value is! bool &&
        value is! int &&
        value is! double &&
        value is! List<String>) {
      throw ArgumentError.value(
        value,
        'changes',
        'Unsupported preference value',
      );
    }
  }
  final previous = {for (final key in changes.keys) key: preferences.get(key)};
  try {
    for (final entry in changes.entries) {
      if (!await _write(preferences, entry.key, entry.value)) {
        throw StateError('Preference write failed: ${entry.key}');
      }
    }
  } catch (_) {
    for (final entry in previous.entries) {
      try {
        await _write(preferences, entry.key, entry.value);
      } catch (_) {
        // Retain the original failure; durable rollback cannot be guaranteed.
      }
    }
    rethrow;
  }
}

Future<bool> _write(SharedPreferences preferences, String key, Object? value) =>
    switch (value) {
      null => preferences.remove(key),
      String value => preferences.setString(key, value),
      bool value => preferences.setBool(key, value),
      int value => preferences.setInt(key, value),
      double value => preferences.setDouble(key, value),
      List<String> value => preferences.setStringList(key, value),
      _ => throw ArgumentError.value(value),
    };
