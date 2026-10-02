import 'package:material_ui/material_ui.dart';

/// Role-specific organic shapes for the active workout card preview.
abstract final class TonosExpressiveWorkoutShapes {
  static const exerciseCardCollapsed = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(26),
    bottomLeft: Radius.circular(26),
    bottomRight: Radius.circular(16),
  );

  static const exerciseCard = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(34),
    bottomLeft: Radius.circular(34),
    bottomRight: Radius.circular(20),
  );

  static const exerciseHeader = BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(14),
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(28),
  );

  static const setRow = BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(10),
  );

  static const numericField = BorderRadius.only(
    topLeft: Radius.circular(14),
    topRight: Radius.circular(8),
    bottomLeft: Radius.circular(8),
    bottomRight: Radius.circular(14),
  );
}
