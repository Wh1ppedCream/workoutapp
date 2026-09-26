import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release manifest permits HTTPS content networking without backups', () {
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
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );

    for (final path in const [
      'android/app/src/main/res/xml/backup_rules.xml',
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ]) {
      final rules = File(path).readAsStringSync();
      expect(rules, contains('<exclude domain="database" path="." />'));
      expect(rules, contains('<exclude domain="sharedpref" path="." />'));
    }
  });
}
