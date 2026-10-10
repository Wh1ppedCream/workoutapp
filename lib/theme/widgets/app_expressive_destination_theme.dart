import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';
import '../tokens/app_expressive_destination_tokens.dart';
import '../tokens/app_nutrition_tokens.dart';

/// Installs a candidate destination palette only inside the wrapped subtree.
///
/// Classic, Neo, and untagged themes pass through unchanged. This wrapper does
/// not replace shared ColorScheme, surface, semantic, or data-visualization
/// roles; destination widgets opt in to the extension's chromatic roles.
class AppExpressiveDestinationTheme extends StatelessWidget {
  const AppExpressiveDestinationTheme({
    super.key,
    required this.family,
    required this.child,
  });

  final AppExpressiveDestinationFamily family;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.appThemeFamilyIdentity !=
        AppThemeFamilyIdentity.expressivePreview) {
      return child;
    }

    final destinationTokens = AppExpressiveDestinationTokens.forFamily(
      family,
      theme.brightness,
    );
    final extensions =
        theme.extensions.values
            .where(
              (extension) =>
                  extension is! AppExpressiveDestinationTokens &&
                  !(family == AppExpressiveDestinationFamily.nutrition &&
                      extension is AppNutritionTokens),
            )
            .toList(growable: true)
          ..add(destinationTokens);
    if (family == AppExpressiveDestinationFamily.nutrition) {
      extensions.add(AppNutritionTokens.expressive(theme.brightness));
    }

    final scopedTheme = theme.copyWith(
      extensions: extensions,
      dialogTheme: _expressiveDialogTheme(theme, destinationTokens),
    );

    return Theme(data: scopedTheme, child: child);
  }
}

DialogThemeData _expressiveDialogTheme(
  ThemeData theme,
  AppExpressiveDestinationTokens tokens,
) => theme.dialogTheme.copyWith(
  backgroundColor: tokens.surfaceTertiary,
  titleTextStyle: theme.textTheme.titleLarge?.copyWith(
    color: tokens.onSurfaceTertiary,
    fontWeight: FontWeight.w800,
  ),
  contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
    color: tokens.onSurfaceTertiary,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(28),
      topRight: Radius.circular(28),
      bottomRight: Radius.circular(28),
      bottomLeft: Radius.circular(10),
    ),
    side: BorderSide(color: tokens.outlineAccent),
  ),
);
