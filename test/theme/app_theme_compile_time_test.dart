import 'package:flutter_test/flutter_test.dart';

import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/app_theme_family.dart';

const _expectedNeoRelease = bool.fromEnvironment('TONOS_EXPECT_NEO_RELEASE');
const _expectedInvalidFlag = bool.fromEnvironment(
  'TONOS_EXPECT_INVALID_NEO_RELEASE',
);

void main() {
  test('release theme policy honors the compiled Neo opt-in', () {
    AppThemeCapabilities load() => AppThemeCapabilities.fromCompileTime(
      releaseMode: true,
      debugMode: false,
    );

    if (_expectedInvalidFlag) {
      expect(
        load,
        throwsA(
          isA<AppThemeCapabilitiesException>().having(
            (error) => error.message,
            'message',
            'TONOS_ENABLE_NEO_RELEASE must be true or false.',
          ),
        ),
      );
      return;
    }

    final capabilities = load();
    expect(capabilities.isReleaseMode, isTrue);
    expect(capabilities.neoReleaseEnabled, _expectedNeoRelease);
    expect(capabilities.isAvailable(AppThemeFamily.classic), isTrue);
    expect(
      capabilities.isAvailable(AppThemeFamily.neoBrutalism),
      _expectedNeoRelease,
    );
    expect(
      capabilities.resolve(AppThemeFamily.neoBrutalism),
      _expectedNeoRelease
          ? AppThemeFamily.neoBrutalism
          : AppThemeFamily.classic,
    );
    expect(capabilities.isCodeAvailable('unknown'), isFalse);
  });
}
