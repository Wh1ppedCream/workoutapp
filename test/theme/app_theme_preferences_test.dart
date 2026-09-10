import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_preferences.dart';
import 'package:env_test/theme/app_theme_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemePreferences', () {
    test('defaults to Classic and materializes its family key', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();

      await provider.ready;

      expect(provider.loaded, isTrue);
      expect(
        provider.selection,
        const AppThemeSelection(
          family: AppThemeFamily.classic,
          mode: ThemeMode.dark,
        ),
      );
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(AppThemePreferences.themeFamilyKey),
        'classic',
      );
    });

    test(
      'preserves legacy brightness and writes explicit mode codes',
      () async {
        SharedPreferences.setMockInitialValues({
          AppThemePreferences.themeModeKey: 'light',
        });
        final provider = ThemeProvider();

        await provider.ready;
        expect(provider.mode, ThemeMode.light);

        await provider.setMode(ThemeMode.system);
        final preferences = await SharedPreferences.getInstance();
        expect(
          preferences.getString(AppThemePreferences.themeModeKey),
          'system',
        );

        await provider.setMode(ThemeMode.dark);
        expect(preferences.getString(AppThemePreferences.themeModeKey), 'dark');
      },
    );

    test(
      'falls back safely without erasing an unknown future family',
      () async {
        SharedPreferences.setMockInitialValues({
          AppThemePreferences.themeModeKey: 'not-a-mode',
          AppThemePreferences.themeFamilyKey: 'liquid_glass',
        });
        final provider = ThemeProvider();

        await provider.ready;

        expect(provider.family, AppThemeFamily.classic);
        expect(provider.mode, ThemeMode.dark);

        await provider.setMode(ThemeMode.light);
        final preferences = await SharedPreferences.getInstance();
        expect(
          preferences.getString(AppThemePreferences.themeFamilyKey),
          'liquid_glass',
        );
      },
    );

    test('supports loading the selection before app startup', () async {
      SharedPreferences.setMockInitialValues({
        AppThemePreferences.themeModeKey: 'light',
      });

      final provider = await ThemeProvider.load();

      expect(provider.loaded, isTrue);
      expect(provider.mode, ThemeMode.light);
      expect(provider.family, AppThemeFamily.classic);
    });

    test('falls back when the preference store cannot be read', () async {
      final preferences = AppThemePreferences(
        preferences: Future<SharedPreferences>.error(StateError('read failed')),
      );

      expect(
        await preferences.readSelection(),
        const AppThemeSelection(
          family: AppThemeFamily.classic,
          mode: ThemeMode.dark,
        ),
      );
    });

    test(
      'startup load remains safe when the preference store cannot be read',
      () async {
        final provider = await ThemeProvider.load(
          preferences: AppThemePreferences(
            preferences: Future<SharedPreferences>.error(
              StateError('read failed'),
            ),
          ),
        );

        expect(provider.loaded, isTrue);
        expect(
          provider.selection,
          const AppThemeSelection(
            family: AppThemeFamily.classic,
            mode: ThemeMode.dark,
          ),
        );
      },
    );

    test('ignores wrong-type stored values without overwriting them', () async {
      SharedPreferences.setMockInitialValues({
        AppThemePreferences.themeModeKey: 7,
        AppThemePreferences.themeFamilyKey: true,
      });
      final provider = ThemeProvider();

      await provider.ready;

      expect(provider.mode, ThemeMode.dark);
      expect(provider.family, AppThemeFamily.classic);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.get(AppThemePreferences.themeModeKey), 7);
      expect(preferences.get(AppThemePreferences.themeFamilyKey), true);
    });

    test(
      'reports a failed write and restores the previous cached value',
      () async {
        final backing = _FailingPreferences({
          AppThemePreferences.themeModeKey: 'dark',
        });
        final preferences = AppThemePreferences(
          preferences: Future<SharedPreferences>.value(backing),
        );

        await expectLater(
          preferences.writeMode(ThemeMode.light),
          throwsA(isA<AppThemePreferenceWriteException>()),
        );
        expect(backing.get(AppThemePreferences.themeModeKey), 'dark');
      },
    );

    test('restores every supported value type after a failed write', () async {
      for (final value in <Object>[
        true,
        7,
        2.5,
        <String>['classic'],
      ]) {
        final backing = _FailingPreferences({
          AppThemePreferences.themeModeKey: value,
        });
        final preferences = AppThemePreferences(
          preferences: Future<SharedPreferences>.value(backing),
        );

        await expectLater(
          preferences.writeMode(ThemeMode.light),
          throwsA(isA<AppThemePreferenceWriteException>()),
        );
        expect(backing.get(AppThemePreferences.themeModeKey), value);
      }
    });

    test('does not notify or change mode when persistence fails', () async {
      final provider = ThemeProvider(preferences: _RejectingThemePreferences());
      await provider.ready;
      var notifications = 0;
      provider.addListener(() => notifications++);

      await expectLater(
        provider.setMode(ThemeMode.light),
        throwsA(isA<StateError>()),
      );

      expect(provider.mode, ThemeMode.dark);
      expect(notifications, 0);
    });

    test(
      'serializes rapid mode writes and commits them in call order',
      () async {
        final preferences = _QueuedThemePreferences();
        final provider = ThemeProvider(preferences: preferences);
        await provider.ready;
        var notifications = 0;
        provider.addListener(() => notifications++);

        final first = provider.setMode(ThemeMode.light);
        await preferences.modeStarted[0].future;
        final second = provider.setMode(ThemeMode.dark);
        expect(preferences.modeWrites, [ThemeMode.light]);

        preferences.modeGates[0].complete();
        await preferences.modeStarted[1].future;
        expect(preferences.modeWrites, [ThemeMode.light, ThemeMode.dark]);
        preferences.modeGates[1].complete();

        await Future.wait([first, second]);
        expect(provider.mode, ThemeMode.dark);
        expect(notifications, 2);
      },
    );

    test('does not enqueue a duplicate write after the first commit', () async {
      final preferences = _QueuedThemePreferences(holdModeWrites: false);
      final provider = ThemeProvider(preferences: preferences);
      await provider.ready;
      var notifications = 0;
      provider.addListener(() => notifications++);

      await Future.wait([
        provider.setMode(ThemeMode.light),
        provider.setMode(ThemeMode.light),
      ]);

      expect(preferences.modeWrites, [ThemeMode.light]);
      expect(provider.mode, ThemeMode.light);
      expect(notifications, 1);
    });

    test('continues with later writes after an earlier write fails', () async {
      final preferences = _QueuedThemePreferences(
        holdModeWrites: false,
        failNextModeWrite: true,
      );
      final provider = ThemeProvider(preferences: preferences);
      await provider.ready;
      var notifications = 0;
      provider.addListener(() => notifications++);

      final first = expectLater(
        provider.setMode(ThemeMode.light),
        throwsA(isA<StateError>()),
      );
      final second = provider.setMode(ThemeMode.system);
      await first;
      await second;

      expect(preferences.modeWrites, [ThemeMode.light, ThemeMode.system]);
      expect(provider.mode, ThemeMode.system);
      expect(notifications, 1);
    });

    test('does not notify after disposal while a write is pending', () async {
      final preferences = _QueuedThemePreferences();
      final provider = ThemeProvider(preferences: preferences);
      await provider.ready;
      var notifications = 0;
      provider.addListener(() => notifications++);

      final write = provider.setMode(ThemeMode.light);
      await preferences.modeStarted[0].future;
      provider.dispose();
      preferences.modeGates[0].complete();
      await write;

      expect(provider.mode, ThemeMode.dark);
      expect(notifications, 0);
    });
  });
}

class _RejectingThemePreferences extends AppThemePreferences {
  _RejectingThemePreferences()
    : super(
        preferences: Future<SharedPreferences>.value(
          _FailingPreferences(<String, Object>{}),
        ),
      );

  @override
  Future<AppThemeSelection> readSelection() async => const AppThemeSelection(
    family: AppThemeFamily.classic,
    mode: ThemeMode.dark,
  );

  @override
  Future<void> writeMode(ThemeMode mode) async {
    throw StateError('write failed');
  }
}

class _FailingPreferences implements SharedPreferences {
  _FailingPreferences(this.values);

  final Map<String, Object> values;

  @override
  Object? get(String key) => values[key];

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  String? getString(String key) => values[key] as String?;

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return false;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QueuedThemePreferences extends AppThemePreferences {
  _QueuedThemePreferences({
    this.holdModeWrites = true,
    this.failNextModeWrite = false,
  }) : super(
         preferences: Future<SharedPreferences>.value(
           _FailingPreferences(<String, Object>{}),
         ),
       );

  final bool holdModeWrites;
  bool failNextModeWrite;
  final List<ThemeMode> modeWrites = <ThemeMode>[];
  final List<Completer<void>> modeGates = <Completer<void>>[];
  final List<Completer<void>> modeStarted = List<Completer<void>>.generate(
    8,
    (_) => Completer<void>(),
  );

  @override
  Future<AppThemeSelection> readSelection() async => const AppThemeSelection(
    family: AppThemeFamily.classic,
    mode: ThemeMode.dark,
  );

  @override
  Future<void> writeMode(ThemeMode mode) async {
    final index = modeWrites.length;
    modeWrites.add(mode);
    modeStarted[index].complete();
    if (failNextModeWrite) {
      failNextModeWrite = false;
      throw StateError('write failed');
    }
    if (!holdModeWrites) return;
    final gate = Completer<void>();
    modeGates.add(gate);
    await gate.future;
  }
}
