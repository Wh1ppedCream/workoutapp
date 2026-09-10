import 'package:flutter/material.dart';

/// Fixed identity colors used by the current profile and saved gym spaces.
///
/// These colors distinguish user-created profiles from one another. They are
/// identity data rather than application-state accents, so alternate theme
/// families must preserve the palette until a product decision explicitly
/// changes that ownership.
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
/// states. They remain fixed until plan identity is given a product-owned
/// palette contract.
abstract final class PlanIdentityPalette {
  static const List<Color> colors = <Color>[
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];
}
