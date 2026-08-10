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
    expect(workflow, contains('flutter drive'));
    expect(workflow, contains('--driver=test_driver/integration_test.dart'));
    expect(
      workflow,
      contains('--target=integration_test/core_flows_test.dart'),
    );
    expect(workflow, contains('--timeout=900'));
    expect(workflow, contains('timeout --foreground 10m'));
    expect(workflow, contains('adb logcat -d -t 1000 || true'));
  });
}
