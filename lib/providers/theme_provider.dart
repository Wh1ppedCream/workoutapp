// File: lib/providers/theme_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_preferences.dart';
import 'package:env_test/theme/app_theme_selection.dart';

class ThemeProvider extends ChangeNotifier {
  static const defaultMode = AppThemePreferences.defaultMode;
  static const defaultFamily = AppThemePreferences.defaultFamily;

  ThemeProvider({
    AppThemePreferences? preferences,
    AppThemeCapabilities? capabilities,
  }) : _preferences = preferences ?? AppThemePreferences(),
       _capabilities = capabilities ?? AppThemeCapabilities.fromCompileTime() {
    ready = _load();
  }

  ThemeProvider._initialized(
    AppThemePreferences preferences,
    AppThemeCapabilities capabilities,
  ) : _preferences = preferences,
      _capabilities = capabilities {
    ready = Future<void>.value();
  }

  static Future<ThemeProvider> load({
    AppThemePreferences? preferences,
    AppThemeCapabilities? capabilities,
  }) async {
    final provider = ThemeProvider._initialized(
      preferences ?? await AppThemePreferences.load(),
      capabilities ?? AppThemeCapabilities.fromCompileTime(),
    );
    await provider._load(notify: false);
    return provider;
  }

  final AppThemePreferences _preferences;
  final AppThemeCapabilities _capabilities;
  late final Future<void> ready;
  Future<void> _mutationQueue = Future<void>.value();
  bool _disposed = false;

  AppThemeSelection _selection = const AppThemeSelection(
    family: defaultFamily,
    mode: defaultMode,
  );
  bool _loaded = false;

  ThemeMode get mode => _selection.mode;
  AppThemeFamily get family => _selection.family;
  AppThemeSelection get selection => _selection;
  List<AppThemeFamily> get availableFamilies => _capabilities.availableFamilies;
  bool get loaded => _loaded;

  Future<void> _load({bool notify = true}) async {
    final storedSelection = await _preferences.readSelection();
    if (_disposed) return;
    _selection = AppThemeSelection(
      family: _capabilities.resolve(storedSelection.family),
      mode: storedSelection.mode,
    );
    _loaded = true;
    if (notify && !_disposed) notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) => _enqueue(() async {
    if (_disposed) return;
    if (!_loaded) await ready;
    if (_disposed || _selection.mode == newMode) return;
    await _preferences.writeMode(newMode);
    if (_disposed) return;
    _selection = AppThemeSelection(family: _selection.family, mode: newMode);
    notifyListeners();
  });

  Future<void> setFamily(AppThemeFamily newFamily) => _enqueue(() async {
    if (_disposed) return;
    if (!_loaded) await ready;
    final resolvedFamily = _capabilities.resolve(newFamily);
    if (_disposed || _selection.family == resolvedFamily) return;
    await _preferences.writeFamily(resolvedFamily);
    if (_disposed) return;
    _selection = AppThemeSelection(
      family: resolvedFamily,
      mode: _selection.mode,
    );
    notifyListeners();
  });

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = Completer<void>();
    _mutationQueue = _mutationQueue.then<void>(
      (_) => _runQueued(operation, result),
      onError: (Object _, StackTrace __) => _runQueued(operation, result),
    );
    return result.future;
  }

  Future<void> _runQueued(
    Future<void> Function() operation,
    Completer<void> result,
  ) async {
    try {
      await operation();
      if (!result.isCompleted) result.complete();
    } catch (error, stackTrace) {
      if (!result.isCompleted) result.completeError(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
