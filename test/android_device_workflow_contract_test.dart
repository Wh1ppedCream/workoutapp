import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android device workflow isolates cold builds from test execution', () {
    final workflow =
        File('.github/workflows/android-device.yml').readAsStringSync();

    final buildIndex = workflow.indexOf('name: Build debug APK');
    final deviceTestIndex = workflow.indexOf(
      'name: Run device-level core flows',
    );
    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(deviceTestIndex, greaterThan(buildIndex));
    expect(workflow, contains('flutter build apk --debug'));
    expect(workflow, contains('--timeout=15m'));
    expect(workflow, contains('adb logcat -d -t 1000 || true'));
  });
}
