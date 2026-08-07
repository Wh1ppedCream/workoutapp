import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release manifest permits cloud content networking', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(
      manifest,
      contains(
        '<uses-permission android:name="android.permission.INTERNET" />',
      ),
      reason:
          'Cloud media synchronization needs INTERNET in the main manifest so '
          'release builds inherit it, not only debug and profile builds.',
    );
  });
}
