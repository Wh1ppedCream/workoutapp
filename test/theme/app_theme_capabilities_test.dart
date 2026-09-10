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

    test('compile-time policy fails closed for release mode', () {
      final capabilities = AppThemeCapabilities.fromCompileTime(
        releaseMode: true,
        debugMode: true,
      );

      expect(capabilities.isReleaseMode, isTrue);
      expect(capabilities.availableFamilies, <AppThemeFamily>[
        AppThemeFamily.classic,
      ]);
    });
  });
}
