import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/providers/dashboard_config.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('app configuration persistence', () {
    test('unit preference loads and persists kilograms', () async {
      SharedPreferences.setMockInitialValues({
        'weight_unit_preference': 'kilograms',
      });
      final provider = UnitPreferenceProvider();
      await settlePreferenceReads();

      expect(provider.loaded, isTrue);
      expect(provider.weightUnit, WeightUnit.kilograms);

      await provider.setWeightUnit(WeightUnit.pounds);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('weight_unit_preference'), 'pounds');
    });

    test(
      'locale preference loads safely and persists supported locales',
      () async {
        SharedPreferences.setMockInitialValues({
          LocalePreferenceProvider.preferenceKey: 'unsupported-old-value',
        });
        final provider = LocalePreferenceProvider();
        await provider.ready;

        expect(provider.loaded, isTrue);
        expect(provider.preference, AppLanguagePreference.system);
        expect(provider.locale, isNull);

        await provider.setPreference(AppLanguagePreference.english);
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString(LocalePreferenceProvider.preferenceKey),
          'english',
        );
        expect(provider.locale, const Locale('en'));

        await provider.setPreference(AppLanguagePreference.canadianFrench);
        expect(
          prefs.getString(LocalePreferenceProvider.preferenceKey),
          'canadianFrench',
        );
        expect(provider.locale, const Locale('fr', 'CA'));

        final reloadedProvider = LocalePreferenceProvider();
        await reloadedProvider.ready;
        expect(
          reloadedProvider.preference,
          AppLanguagePreference.canadianFrench,
        );
        expect(reloadedProvider.locale, const Locale('fr', 'CA'));

        await provider.setPreference(AppLanguagePreference.bengaliBangladesh);
        expect(
          prefs.getString(LocalePreferenceProvider.preferenceKey),
          'bengaliBangladesh',
        );
        expect(provider.locale, const Locale('bn'));
      },
    );

    test('theme defaults to dark and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      await settlePreferenceReads();
      expect(provider.mode, ThemeMode.dark);

      await provider.setMode(ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test(
      'legacy onboarding replay is migrated into a fresh onboarding run',
      () async {
        SharedPreferences.setMockInitialValues({
          'always_show_onboarding': true,
          'onboarding_completed': true,
        });
        final config = OnboardingConfig();
        await config.init();

        expect(config.initialized, isTrue);
        expect(config.showOnboarding, isTrue);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('always_show_onboarding'), isFalse);
        expect(prefs.getBool('onboarding_completed'), isFalse);
      },
    );

    test(
      'bottom tabs ignore stale stored values and preserve profile',
      () async {
        SharedPreferences.setMockInitialValues({
          'navBarOrder': ['TabItem.train', 'removed-tab'],
          'navBarEnabled': ['TabItem.catalog', 'removed-tab'],
        });
        final config = NavBarConfig();
        await settlePreferenceReads();

        expect(config.loaded, isTrue);
        expect(config.order, contains(TabItem.train));
        expect(config.order, contains(TabItem.profile));
        expect(config.enabledTabs, contains(TabItem.catalog));
        expect(config.enabledTabs, contains(TabItem.profile));
        expect(config.enabledTabs, hasLength(2));
      },
    );

    test('dashboard keeps defaults when a saved layout is malformed', () async {
      SharedPreferences.setMockInitialValues({
        'dashboard_config': 'not valid JSON',
      });
      final config = DashboardConfig();
      await settlePreferenceReads();

      expect(config.widgetOrder, contains('quickActions'));
      expect(config.isVisible('quickActions'), isTrue);
    });

    test(
      'dashboard keeps optional main-tab sections available by default',
      () async {
        SharedPreferences.setMockInitialValues({});
        final config = DashboardConfig();
        await settlePreferenceReads();

        expect(
          config.widgetOrder,
          containsAll(<String>[
            'workoutMetrics',
            'activePlans',
            'archivedPlans',
            'premadePlans',
            'planTools',
            'exerciseCatalog',
            'targetAnatomy',
          ]),
        );
        expect(config.isVisible('exerciseCatalog'), isFalse);

        await config.toggleVisibility('exerciseCatalog');
        expect(config.isVisible('exerciseCatalog'), isTrue);
      },
    );

    test(
      'dashboard migrates supported legacy sections into the new layout',
      () {
        final layout = DashboardConfig.normalizeLayout(
          rawOrder: <String>[
            'sessionList',
            'quickBar',
            'nutritionDash',
            'workoutDashboard',
          ],
          rawHidden: <String>['quickBar', 'CurrentMetricsSection'],
        );

        expect(layout.order.take(4), <String>[
          'recentWorkouts',
          'quickActions',
          'nutritionDash',
          'training',
        ]);
        expect(layout.order, contains('exerciseProgress'));
        expect(layout.order, contains('nutritionDash'));
        expect(layout.order, contains('dataRecords'));
        expect(
          layout.hidden,
          containsAll(<String>{
            'quickActions',
            'workoutMetrics',
            'activePlans',
            'archivedPlans',
            'premadePlans',
            'planTools',
            'exerciseCatalog',
            'targetAnatomy',
          }),
        );
      },
    );

    test('active plans are stored independently per profile', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = _FakeActivePlanRepository();
      final store = ActivePlanStore(repository: repository);

      await store.save(1, {3, 5});
      await store.add(1, 8);
      await store.remove(1, 5);

      expect(await store.load(1), {3, 8});
      expect(await store.load(2), isEmpty);
      expect(await store.load(null), isEmpty);
    });
  });
}

class _FakeActivePlanRepository extends AppRepository {
  final Map<int, Set<int>> _plansByProfile = <int, Set<int>>{};

  @override
  Future<Set<int>> loadActivePlans(int profileId) async =>
      Set<int>.from(_plansByProfile[profileId] ?? const <int>{});

  @override
  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {
    _plansByProfile[profileId] = Set<int>.from(presetIds);
  }

  @override
  Future<void> addActivePlan(int profileId, int presetId) async {
    _plansByProfile.putIfAbsent(profileId, () => <int>{}).add(presetId);
  }

  @override
  Future<void> removeActivePlan(int profileId, int presetId) async {
    _plansByProfile[profileId]?.remove(presetId);
  }
}
