import 'dart:async';

import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/providers/dashboard_config.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/services/preference_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Backend failure injection without reading device preferences.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('disposing a unit provider during initialization is safe', () async {
    final provider = UnitPreferenceProvider();
    provider.dispose();
    await expectLater(provider.ready, completes);
  });
  test('disposing a language provider during initialization is safe', () async {
    final provider = LocalePreferenceProvider();
    provider.dispose();
    await expectLater(provider.ready, completes);
  });
  test('disposing onboarding during initialization is safe', () async {
    final provider = OnboardingConfig();
    final ready = provider.init();
    provider.dispose();
    await expectLater(ready, completes);
  });
  test('disposing Dashboard during initialization is safe', () async {
    final provider = DashboardConfig();
    provider.dispose();
    await expectLater(provider.ready, completes);
  });
  test('disposing navigation during initialization is safe', () async {
    final provider = NavBarConfig();
    provider.dispose();
    await expectLater(provider.ready, completes);
  });

  test(
    'failed Dashboard saves retain the visible layout and can retry',
    () async {
      final store = _Store();
      SharedPreferencesStorePlatform.instance = store;
      final config = DashboardConfig();
      await config.ready;
      addTearDown(config.dispose);
      final oldOrder = config.widgetOrder;
      store.failNextWrite = true;
      await expectLater(
        config.toggleVisibility('quickActions'),
        throwsStateError,
      );
      expect(config.isVisible('quickActions'), isTrue);
      expect(config.widgetOrder, oldOrder);
      expect(
        (await SharedPreferences.getInstance()).getString('dashboard_config'),
        isNull,
      );
      await config.toggleVisibility('quickActions');
      expect(config.isVisible('quickActions'), isFalse);
    },
  );

  test('a failed onboarding completion compensates both stored keys', () async {
    final store = _Store();
    SharedPreferencesStorePlatform.instance = store;
    final config = OnboardingConfig();
    await config.init();
    addTearDown(config.dispose);
    store.failAtWrite = store.writes + 2;
    await expectLater(config.markCompleted(), throwsStateError);
    expect(config.completed, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_completed'), isNull);
    expect(prefs.getBool('always_show_onboarding'), isNull);
    await config.markCompleted();
    expect(config.completed, isTrue);
    expect(prefs.getBool('onboarding_completed'), isTrue);
    expect(prefs.getBool('always_show_onboarding'), isFalse);
  });

  test('batch writer validates types before touching preferences', () async {
    final prefs = await SharedPreferences.getInstance();
    await expectLater(
      writePreferences(prefs, {
        'first': true,
        'bad': <int>[1],
      }),
      throwsArgumentError,
    );
    expect(prefs.containsKey('first'), isFalse);
  });

  test(
    'batch writer restores each supported value type after a partial failure',
    () async {
      final store = _Store();
      SharedPreferencesStorePlatform.instance = store;
      final prefs = await SharedPreferences.getInstance();
      final original = <String, Object?>{
        'text': 'old',
        'bool': true,
        'int': 3,
        'double': 1.25,
        'list': <String>['old'],
      };
      await writePreferences(prefs, original);
      store.failAtWrite = store.writes + 4;
      await expectLater(
        writePreferences(prefs, {
          'text': 'new',
          'bool': false,
          'int': 4,
          'double': 2.5,
          'list': <String>['new'],
        }),
        throwsStateError,
      );
      for (final entry in original.entries) {
        expect(prefs.get(entry.key), entry.value);
      }
    },
  );

  test('a unit change waits for initial preferences before applying', () async {
    final store = _Store()..readGate = Completer<Map<String, Object>>();
    SharedPreferencesStorePlatform.instance = store;
    final provider = UnitPreferenceProvider();
    addTearDown(provider.dispose);
    final change = provider.setWeightUnit(WeightUnit.kilograms);
    store.readGate!.complete({'flutter.weight_unit_preference': 'pounds'});
    await provider.ready;
    await change;
    expect(provider.weightUnit, WeightUnit.kilograms);
    expect(
      (await SharedPreferences.getInstance()).getString(
        'weight_unit_preference',
      ),
      'kilograms',
    );
  });

  test(
    'a failed unit write retains the old model and preference cache',
    () async {
      final store = _Store();
      SharedPreferencesStorePlatform.instance = store;
      final provider = UnitPreferenceProvider();
      await provider.ready;
      addTearDown(provider.dispose);
      await provider.setWeightUnit(WeightUnit.kilograms);
      store.failNextWrite = true;
      await expectLater(
        provider.setWeightUnit(WeightUnit.pounds),
        throwsStateError,
      );
      expect(provider.weightUnit, WeightUnit.kilograms);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'weight_unit_preference',
        ),
        'kilograms',
      );
      await provider.setWeightUnit(WeightUnit.pounds);
      expect(provider.weightUnit, WeightUnit.pounds);
    },
  );

  test(
    'a failed language write retains the previous locale and can retry',
    () async {
      final store = _Store();
      SharedPreferencesStorePlatform.instance = store;
      final provider = LocalePreferenceProvider();
      await provider.ready;
      addTearDown(provider.dispose);
      await provider.setPreference(AppLanguagePreference.english);
      store.failNextWrite = true;
      await expectLater(
        provider.setPreference(AppLanguagePreference.spanish),
        throwsStateError,
      );
      expect(provider.preference, AppLanguagePreference.english);
      expect(
        (await SharedPreferences.getInstance()).getString(
          LocalePreferenceProvider.preferenceKey,
        ),
        'english',
      );
      await provider.setPreference(AppLanguagePreference.spanish);
      expect(provider.locale!.languageCode, 'es');
    },
  );
}

class _Store extends InMemorySharedPreferencesStore {
  _Store() : super.empty();
  Completer<Map<String, Object>>? readGate;
  bool failNextWrite = false;
  int writes = 0;
  int? failAtWrite;

  @override
  Future<Map<String, Object>> getAll() => readGate?.future ?? super.getAll();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes++;
    if (failNextWrite || writes == failAtWrite) {
      failNextWrite = false;
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}
