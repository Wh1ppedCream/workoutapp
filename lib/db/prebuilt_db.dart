// lib/db/prebuilt_db.dart
class PrebuiltDb {
  /// Must match PRAGMA user_version baked into the asset DB.
  static const int schemaUserVersion = 22;

  /// Path inside your Flutter bundle.
  static const String assetPath = 'assets/db/app_nutrition_v22.db';

  /// Filename we store on-device (kept stable across releases).
  static const String targetFileName = 'app_nutrition.db';
}
