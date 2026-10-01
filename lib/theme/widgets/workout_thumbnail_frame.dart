import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';

/// Shared frame for workout thumbnails whose size follows accessibility scale.
class WorkoutThumbnailFrame extends StatelessWidget {
  const WorkoutThumbnailFrame({
    super.key,
    required this.scale,
    required this.child,
    this.backgroundColor,
  });

  final double scale;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = 60 * scale;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.surfaceTokens.presetFocus,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: child,
    );
  }
}
