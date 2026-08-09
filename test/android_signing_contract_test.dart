import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android debug builds do not require production signing material', () {
    final gradleFile = File('android/app/build.gradle.kts');
    final source = gradleFile.readAsStringSync();

    expect(source, contains('val isReleaseBuild'));
    expect(
      source,
      contains('if (isReleaseBuild && !keystorePropertiesFile.exists())'),
    );
    expect(
      source,
      contains(
        'Missing android/key.properties required to build a signed release.',
      ),
    );
    expect(source, contains('if (keystorePropertiesFile.exists())'));
  });
}
