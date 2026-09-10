import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeFamily', () {
    test('declares Classic as a stable family with light and dark support', () {
      expect(AppThemeFamily.classic.code, 'classic');
      expect(AppThemeFamily.classic.supportedBrightnesses, <Brightness>{
        Brightness.light,
        Brightness.dark,
      });
      expect(AppThemeFamily.classic.supports(Brightness.light), isTrue);
      expect(AppThemeFamily.classic.supports(Brightness.dark), isTrue);
    });

    test('parses only stable family codes', () {
      expect(AppThemeFamily.fromCode('classic'), AppThemeFamily.classic);
      expect(AppThemeFamily.fromCode('Classic'), isNull);
      expect(AppThemeFamily.fromCode(null), isNull);
    });

    test(
      'ThemeProvider identifies the current appearance as Classic',
      () async {
        SharedPreferences.setMockInitialValues({});
        final provider = ThemeProvider();
        await settlePreferenceReads();

        expect(provider.family, AppThemeFamily.classic);
      },
    );
  });
}
