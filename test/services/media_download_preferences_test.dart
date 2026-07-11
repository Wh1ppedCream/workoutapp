import 'package:env_test/services/media_download_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.tonos/media_download_policy');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('allows downloads when Wi-Fi-only is disabled', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await MediaDownloadPolicy().canDownloadRemoteMedia(), isTrue);
  });

  test('uses the native unmetered result when Wi-Fi-only is enabled', () async {
    SharedPreferences.setMockInitialValues({
      MediaDownloadPreferences.wifiOnlyKey: true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'isUnmeteredConnection');
          return true;
        });

    expect(await MediaDownloadPolicy().canDownloadRemoteMedia(), isTrue);
  });

  test(
    'allows downloads on platforms without the Android network channel',
    () async {
      SharedPreferences.setMockInitialValues({
        MediaDownloadPreferences.wifiOnlyKey: true,
      });

      expect(await MediaDownloadPolicy().canDownloadRemoteMedia(), isTrue);
    },
  );

  test('blocks downloads when the Android network check fails', () async {
    SharedPreferences.setMockInitialValues({
      MediaDownloadPreferences.wifiOnlyKey: true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'network-check-failed');
        });

    expect(await MediaDownloadPolicy().canDownloadRemoteMedia(), isFalse);
  });
}
