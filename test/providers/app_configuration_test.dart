import 'package:env_test/models/unit_preference.dart';
import 'package:env_test/providers/dashboard_config.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
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

      expect(config.widgetOrder, contains('quickBar'));
      expect(config.isVisible('quickBar'), isTrue);
    });

    test('active plans are stored independently per profile', () async {
      SharedPreferences.setMockInitialValues({});

      await ActivePlanStore.save(1, {3, 5});
      await ActivePlanStore.add(1, 8);
      await ActivePlanStore.remove(1, 5);

      expect(await ActivePlanStore.load(1), {3, 8});
      expect(await ActivePlanStore.load(2), isEmpty);
      expect(await ActivePlanStore.load(null), isEmpty);
    });
  });
}
