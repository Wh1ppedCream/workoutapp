import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:package_info_plus/package_info_plus.dart';

/// Validates the isolated preview identity before preferences or SQLite open.
abstract final class ExpressivePreviewSafety {
  static const applicationId = 'com.tonos.expressivepreview';
  static const databaseName = 'tonos_expressive_preview.db';

  static const _previewEnabled = bool.fromEnvironment(
    'TONOS_EXPRESSIVE_PREVIEW',
    defaultValue: false,
  );
  static const _previewAndroidBuild = bool.fromEnvironment(
    'TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD',
    defaultValue: false,
  );
  static const _internalAndroidBuild = bool.fromEnvironment(
    'TONOS_ANDROID_INTERNAL_BUILD',
    defaultValue: false,
  );
  static const _configuredDatabaseName = String.fromEnvironment(
    'TONOS_DATABASE_NAME',
    defaultValue: '',
  );

  /// Must run before SharedPreferences, ThemeProvider, or AppRepository access.
  static Future<void> verifyBeforeDataAccess() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!_previewEnabled || !_previewAndroidBuild) {
      throw StateError(
        'Expressive preview requires its explicit preview build flags.',
      );
    }
    if (_internalAndroidBuild) {
      throw StateError(
        'Expressive preview and internal Android build flags cannot overlap.',
      );
    }
    if (_configuredDatabaseName != databaseName) {
      throw StateError(
        'Expressive preview requires the isolated $databaseName database.',
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();
    validateIdentity(
      packageName: packageInfo.packageName,
      databaseName: _configuredDatabaseName,
      previewEnabled: _previewEnabled,
      previewAndroidBuild: _previewAndroidBuild,
      internalAndroidBuild: _internalAndroidBuild,
    );
  }

  /// Pure guard kept public for focused contract tests.
  static void validateIdentity({
    required String packageName,
    required String databaseName,
    required bool previewEnabled,
    required bool previewAndroidBuild,
    required bool internalAndroidBuild,
  }) {
    if (!previewEnabled || !previewAndroidBuild) {
      throw StateError('Expressive preview flags are missing.');
    }
    if (internalAndroidBuild) {
      throw StateError('Conflicting Android build flags were supplied.');
    }
    if (packageName != applicationId) {
      throw StateError(
        'Refusing preview startup for unexpected package $packageName.',
      );
    }
    if (databaseName != ExpressivePreviewSafety.databaseName) {
      throw StateError('Refusing preview startup with a shared database.');
    }
  }
}
