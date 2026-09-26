import 'package:flutter/material.dart';

/// Fixed identity colors used by the current profile and saved gym spaces.
///
/// These colors distinguish user-created profiles from one another. They are
/// identity data rather than application-state accents. Keep their mapping
/// independent from theme family, brightness, and future selectable app color
/// palettes. If identity palettes become selectable, persist a stable palette
/// identifier and resolve it to curated, contrast-qualified swatches instead
/// of persisting raw colors or reusing status roles.
abstract final class ProfileIdentityPalette {
  static const Color currentProfileAvatar = Colors.lightGreen;

  static const List<Color> colors = <Color>[
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];
}

/// Fixed colors assigned to saved plans.
///
/// Plan colors identify list entries and are not success, warning, or error
/// states. Their current mapping is shared across theme families and
/// brightness modes; any future selectable identity palette should follow the
/// same stable-identifier and curated-swatch contract as profile colors.
abstract final class PlanIdentityPalette {
  static const List<Color> colors = <Color>[
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];
}
