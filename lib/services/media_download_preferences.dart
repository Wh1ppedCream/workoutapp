import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaDownloadBlockedException implements Exception {
  final String message;

  const MediaDownloadBlockedException([
    this.message = 'Media downloads are limited to Wi-Fi.',
  ]);

  @override
  String toString() => message;
}

class MediaDownloadPreferences {
  static const String wifiOnlyKey = 'content.media_downloads.wifi_only';

  const MediaDownloadPreferences();

  Future<bool> loadWifiOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(wifiOnlyKey) ?? false;
  }

  Future<void> saveWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(wifiOnlyKey, value);
  }
}

class MediaDownloadPolicy {
  MediaDownloadPolicy({
    MediaDownloadPreferences? preferences,
    MethodChannel? channel,
  }) : _preferences = preferences ?? const MediaDownloadPreferences(),
       _channel = channel ?? _defaultChannel;

  static const MethodChannel _defaultChannel = MethodChannel(
    'com.tonos/media_download_policy',
  );

  final MediaDownloadPreferences _preferences;
  final MethodChannel _channel;

  Future<bool> isWifiOnlyEnabled() => _preferences.loadWifiOnly();

  Future<void> setWifiOnlyEnabled(bool value) {
    return _preferences.saveWifiOnly(value);
  }

  Future<bool> canDownloadRemoteMedia() async {
    if (!await isWifiOnlyEnabled()) return true;

    try {
      return await _channel.invokeMethod<bool>('isUnmeteredConnection') ??
          false;
    } on MissingPluginException {
      // Non-Android targets do not currently expose this native check.
      return true;
    } on PlatformException {
      // If the platform check fails on Android, honor the safer preference.
      return false;
    }
  }
}
