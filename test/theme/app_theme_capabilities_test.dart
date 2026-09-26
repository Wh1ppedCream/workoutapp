import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/app_theme_family.dart';

void main() {
  group('AppThemeCapabilities', () {
    test('Classic remains available in release builds', () {
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: true,
      );

      expect(capabilities.isAvailable(AppThemeFamily.classic), isTrue);
      expect(capabilities.availableFamilies, <AppThemeFamily>[
        AppThemeFamily.classic,
      ]);
      expect(capabilities.isCodeAvailable('classic'), isTrue);
      expect(capabilities.isCodeAvailable('expressive'), isFalse);
      expect(
        capabilities.resolve(AppThemeFamily.classic),
        AppThemeFamily.classic,
      );
    });

    test('unknown family codes are never exposed by the current build', () {
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: false,
      );

      expect(capabilities.isCodeAvailable(null), isFalse);
      expect(capabilities.isCodeAvailable('liquid_glass'), isFalse);
      expect(capabilities.availableFamilies, contains(AppThemeFamily.classic));
    });

    test('Neo-Brutalism is available only for eligible development builds', () {
      const developmentCapabilities = AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: false,
      );
      const disabledCapabilities = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: false,
      );

      expect(
        developmentCapabilities.isAvailable(AppThemeFamily.neoBrutalism),
        isTrue,
      );
      expect(developmentCapabilities.availableFamilies, <AppThemeFamily>[
        AppThemeFamily.classic,
        AppThemeFamily.neoBrutalism,
      ]);
      expect(
        disabledCapabilities.isAvailable(AppThemeFamily.neoBrutalism),
        isFalse,
      );
      expect(
        disabledCapabilities.resolve(AppThemeFamily.neoBrutalism),
        AppThemeFamily.classic,
      );
    });

    test('experimental switch alone cannot enable Neo in release mode', () {
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: true,
      );

      expect(capabilities.isAvailable(AppThemeFamily.neoBrutalism), isFalse);
      expect(capabilities.isCodeAvailable('neo_brutalism'), isFalse);
    });

    test('explicit Neo release opt-in exposes both families', () {
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: true,
        neoReleaseEnabled: true,
      );

      expect(capabilities.availableFamilies, <AppThemeFamily>[
        AppThemeFamily.classic,
        AppThemeFamily.neoBrutalism,
      ]);
      expect(capabilities.isCodeAvailable('neo_brutalism'), isTrue);
      expect(
        capabilities.resolve(AppThemeFamily.neoBrutalism),
        AppThemeFamily.neoBrutalism,
      );
      expect(capabilities.isCodeAvailable('expressive'), isFalse);
    });

    test('release opt-in does not bypass disabled development themes', () {
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: false,
        neoReleaseEnabled: true,
      );

      expect(capabilities.availableFamilies, <AppThemeFamily>[
        AppThemeFamily.classic,
      ]);
    });
  });
}
