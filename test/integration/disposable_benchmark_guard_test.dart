import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/support/disposable_benchmark_guard.dart';

void main() {
  test('benchmark rejects missing disposable-device authorization', () {
    expect(
      () => requireDisposableBenchmarkInstallation(
        explicitlyDisposable: false,
        markedDisposable: true,
        preferenceKeys: {},
      ),
      throwsStateError,
    );
  });
  test('benchmark refuses an existing unmarked review installation', () {
    expect(
      () => requireDisposableBenchmarkInstallation(
        explicitlyDisposable: true,
        markedDisposable: false,
        preferenceKeys: {'onboarding_completed', 'themeFamily'},
      ),
      throwsStateError,
    );
  });
  test('benchmark accepts a fresh dedicated installation', () {
    expect(
      () => requireDisposableBenchmarkInstallation(
        explicitlyDisposable: true,
        markedDisposable: false,
        preferenceKeys: {},
      ),
      returnsNormally,
    );
  });
  test(
    'benchmark permits reruns only on its marked disposable installation',
    () {
      expect(
        () => requireDisposableBenchmarkInstallation(
          explicitlyDisposable: true,
          markedDisposable: true,
          preferenceKeys: {'onboarding_completed'},
        ),
        returnsNormally,
      );
    },
  );
}
