import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-Android platform shells use the Tonos release identity', () {
    const platformFiles = <String>[
      'ios/Runner/Info.plist',
      'ios/Runner.xcodeproj/project.pbxproj',
      'macos/Runner/Configs/AppInfo.xcconfig',
      'macos/Runner.xcodeproj/project.pbxproj',
      'macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
      'linux/CMakeLists.txt',
      'linux/runner/my_application.cc',
      'windows/CMakeLists.txt',
      'windows/runner/main.cpp',
      'windows/runner/Runner.rc',
      'web/manifest.json',
      'web/index.html',
    ];

    final platformSource = platformFiles
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(platformSource, isNot(contains('env_test')));
    expect(platformSource, isNot(contains('com.example')));
    expect(platformSource, contains('com.tonos'));
    expect(platformSource, contains('Tonos'));
  });
}
