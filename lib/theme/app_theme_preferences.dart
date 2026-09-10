import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme_family.dart';
import 'app_theme_selection.dart';

/// Signals that a requested preference value could not be persisted.
///
/// The provider deliberately keeps its current in-memory value when this
/// happens, so callers can show feedback without presenting a false state.
class AppThemePreferenceWriteException implements Exception {
  const AppThemePreferenceWriteException(this.cause, this.stackTrace);

  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'AppThemePreferenceWriteException($cause)';
}

/// Owns all persisted appearance keys, codes, defaults, and migrations.
class AppThemePreferences {
  static const themeModeKey = 'theme_mode';
  static const themeFamilyKey = 'theme_family';
  static const defaultMode = ThemeMode.dark;
  static const defaultFamily = AppThemeFamily.classic;

  AppThemePreferences({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  AppThemePreferences._fromInstance(SharedPreferences preferences)
    : _preferences = Future<SharedPreferences>.value(preferences);

  AppThemePreferences._unavailable() : _preferences = null;

  final Future<SharedPreferences>? _preferences;

  /// Loads a preference store for production startup before the first frame.
  static Future<AppThemePreferences> load() async {
    try {
      return AppThemePreferences._fromInstance(
        await SharedPreferences.getInstance(),
      );
    } catch (_) {
      return AppThemePreferences._unavailable();
    }
  }

  Future<AppThemeSelection> readSelection() async {
    final preferences = await _tryGetPreferences();
    if (preferences == null) {
      return const AppThemeSelection(family: defaultFamily, mode: defaultMode);
    }

    final hasFamilyKey = _containsKey(preferences, themeFamilyKey);
    final storedFamilyCode = _readString(preferences, themeFamilyKey);

    // Add the new key for existing users, but leave unknown future codes
    // untouched so a downgrade does not erase a later preference.
    if (storedFamilyCode == null && !hasFamilyKey) {
      try {
        await preferences.setString(themeFamilyKey, defaultFamily.code);
      } catch (_) {
        // Preference materialization is best effort and must not block launch.
      }
    }

    return AppThemeSelection(
      family: AppThemeFamily.fromCode(storedFamilyCode) ?? defaultFamily,
      mode:
          _modeFromCode(_readString(preferences, themeModeKey)) ?? defaultMode,
    );
  }

  Future<void> writeMode(ThemeMode mode) async {
    await _writeString(themeModeKey, _modeCode(mode));
  }

  Future<void> writeFamily(AppThemeFamily family) async {
    await _writeString(themeFamilyKey, family.code);
  }

  Future<SharedPreferences?> _tryGetPreferences() async {
    final preferences = _preferences;
    if (preferences == null) return null;
    try {
      return await preferences;
    } catch (_) {
      return null;
    }
  }

  Future<SharedPreferences> _requirePreferences() async {
    final preferences = _preferences;
    if (preferences == null) {
      throw AppThemePreferenceWriteException(
        StateError('Theme preferences are unavailable.'),
        StackTrace.current,
      );
    }
    try {
      return await preferences;
    } catch (error, stackTrace) {
      throw AppThemePreferenceWriteException(error, stackTrace);
    }
  }

  Future<void> _writeString(String key, String value) async {
    final preferences = await _requirePreferences();
    final previousValue = _rawValue(preferences, key);
    try {
      final persisted = await preferences.setString(key, value);
      if (!persisted) {
        throw AppThemePreferenceWriteException(
          StateError('Shared preference write returned false.'),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      await _restoreValue(preferences, key, previousValue);
      if (error is AppThemePreferenceWriteException) rethrow;
      throw AppThemePreferenceWriteException(error, stackTrace);
    }
  }

  Object? _rawValue(SharedPreferences preferences, String key) {
    try {
      return preferences.get(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreValue(
    SharedPreferences preferences,
    String key,
    Object? value,
  ) async {
    try {
      if (value is String) {
        await preferences.setString(key, value);
      } else if (value is bool) {
        await preferences.setBool(key, value);
      } else if (value is int) {
        await preferences.setInt(key, value);
      } else if (value is double) {
        await preferences.setDouble(key, value);
      } else if (value is List<String>) {
        await preferences.setStringList(key, value);
      } else {
        await preferences.remove(key);
      }
    } catch (_) {
      // The original write failure remains the actionable error.
    }
  }

  String? _readString(SharedPreferences preferences, String key) {
    try {
      return preferences.getString(key);
    } catch (_) {
      return null;
    }
  }

  bool _containsKey(SharedPreferences preferences, String key) {
    try {
      return preferences.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  static ThemeMode? _modeFromCode(String? code) => switch (code) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => null,
  };

  static String _modeCode(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
  };
}
