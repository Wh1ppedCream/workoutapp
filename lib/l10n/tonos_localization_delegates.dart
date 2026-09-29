import 'package:material_ui/material_ui.dart';

import 'generated/app_localizations.dart';

/// The app's generated strings and the standalone Material UI localizations.
///
/// `flutter gen-l10n` still emits delegates for Flutter's legacy Material
/// library. Keep that generated output untouched and compose Tonos's delegate
/// with the replacement package's supported Material, Cupertino, and Widgets
/// delegates here.
const List<LocalizationsDelegate<dynamic>> tonosLocalizationDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ];
