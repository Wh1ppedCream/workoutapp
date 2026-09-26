import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

/// Translates names from the built-in body-part lookup table.
///
/// Custom lookup entries intentionally fall back to their saved name.
String localizedBodyPartName(BuildContext context, String bodyPartName) {
  final strings = AppLocalizations.of(context);
  return switch (bodyPartName) {
    'Neck' => strings.bodyPartNeck,
    'Shoulders' => strings.bodyPartShoulders,
    'Chest' => strings.bodyPartChest,
    'Core' => strings.bodyPartCore,
    'Upper Back' => strings.bodyPartUpperBack,
    'Lower Back' => strings.bodyPartLowerBack,
    'Biceps' => strings.bodyPartBiceps,
    'Triceps' => strings.bodyPartTriceps,
    'Forearms' => strings.bodyPartForearms,
    'Hips' => strings.bodyPartHips,
    'Hamstrings' => strings.bodyPartHamstrings,
    'Quads' => strings.bodyPartQuads,
    'Calves' => strings.bodyPartCalves,
    _ => bodyPartName,
  };
}
