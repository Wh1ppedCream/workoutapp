import 'package:shared_preferences/shared_preferences.dart';

import 'dev/expressive_preview_safety.dart';
import 'main.dart' show runTonosApp;
import 'theme/app_theme_family.dart';
import 'theme/app_theme_preferences.dart';

/// Opens the regular app UI using the existing isolated installation's data.
/// Expressive now uses the same persisted appearance settings as other themes.
/// No review controls, theme override, or fixture preparation are installed.
Future<void> main() => runTonosApp(beforeDataAccess: _prepareRegularAppearance);

Future<void> _prepareRegularAppearance() async {
  await ExpressivePreviewSafety.verifyBeforeDataAccess();
  final preferences = await SharedPreferences.getInstance();
  const migrationKey = 'tonos.expressive.regular_appearance.v1';
  if (preferences.getBool(migrationKey) == true) return;

  // The old review theme was not persisted. Adopt it once for this installation,
  // then honor every later settings choice, including Classic or Neo.
  await AppThemePreferences(preferences: Future.value(preferences))
      .writeFamily(AppThemeFamily.expressive);
  if (!await preferences.setBool(migrationKey, true)) {
    throw StateError('Could not finish adopting regular appearance settings.');
  }
}
