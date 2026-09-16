import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_settings_presentation_tokens.dart';
import '../theme/widgets/tonos_action_depth.dart';

/// Stable category accents for grouped settings content.
///
/// These colors communicate product categories such as training, progress,
/// data, safety, and advanced controls. They are intentionally not aliases for
/// the active primary color; future families may provide contrast-safe
/// variants, but must preserve the category mapping.
abstract final class SettingsAccent {
  static const Color account = Color(0xFFB39DDB);
  static const Color appearance = Color(0xFFCE93D8);
  static const Color training = Color(0xFF4DB6AC);
  static const Color progress = Color(0xFF81C784);
  static const Color data = Color(0xFF64B5F6);
  static const Color advanced = Color(0xFFFFB74D);
  static const Color safety = Color(0xFFEF9A9A);
  static const Color muted = Color(0xFF9E9E9E);
}

/// Displays a compact settings value using its enclosing foreground in Neo.
class SettingsValueText extends StatelessWidget {
  final String value;

  const SettingsValueText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        context.surfaceDecorationTokens.panel.outlined
            ? theme.colorScheme.onSurface
            : theme.colorScheme.primary;
    return Text(
      value,
      style: theme.textTheme.labelLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

/// Displays a compact status label for unavailable or deferred settings.
class SettingsStatusBadge extends StatelessWidget {
  final String label;
  final Color? foregroundColor;

  const SettingsStatusBadge({
    super.key,
    required this.label,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final badgeForeground =
        foregroundColor ??
        (usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.panelRaised)
            : scheme.onSurfaceVariant);
    final badgeBorder =
        usesInkRecipe
            ? tonosOutlineForSurface(context, surfaces.panelRaised)
            : scheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaces.panelRaised,
        borderRadius: shapes.pill,
        border: Border.all(color: badgeBorder),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Displays a compact label whose foreground and tint come from one accent.
///
/// This is intentionally a small visual primitive for category/source labels,
/// not a replacement for [SettingsStatusBadge], which owns a surface role.
class SettingsAccentPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? parentSurface;
  final EdgeInsetsGeometry padding;
  final double backgroundAlpha;
  final double? borderAlpha;
  final FontWeight fontWeight;

  const SettingsAccentPill({
    super.key,
    required this.label,
    required this.color,
    this.parentSurface,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundAlpha = 0.14,
    this.borderAlpha,
    this.fontWeight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: context.shapeTokens.pill,
        border:
            borderAlpha == null
                ? null
                : Border.all(color: color.withValues(alpha: borderAlpha!)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color:
              context.surfaceDecorationTokens.panel.outlined
                  ? tonosForegroundForSurface(
                    context,
                    color.withValues(alpha: backgroundAlpha),
                    parentSurface: parentSurface ?? theme.colorScheme.surface,
                  )
                  : color,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

/// Displays a compact colored legend item with a matching marker.
class SettingsLegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const SettingsLegendChip({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final chipSurface = color.withValues(alpha: neo ? 0.18 : 0.12);
    final foreground =
        neo ? tonosForegroundForSurface(context, chipSurface) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipSurface,
        borderRadius: context.shapeTokens.pill,
        border: Border.all(
          color:
              neo
                  ? tonosOutlineForSurface(context, chipSurface)
                  : color.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a compact count using the accent that owns the surrounding scope.
class SettingsCountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const SettingsCountBadge({
    super.key,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final badgeSurface = color.withValues(alpha: neo ? 0.22 : 0.16);
    final foreground =
        neo ? tonosForegroundForSurface(context, badgeSurface) : color;
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeSurface,
        borderRadius: context.shapeTokens.pill,
        border:
            neo
                ? Border.all(
                  color: tonosOutlineForSurface(context, badgeSurface),
                  width: context.shapeTokens.outlineWidth,
                )
                : null,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Displays an outlined action with the standard in-section settings padding.
class SettingsInlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const SettingsInlineActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

/// Builds the shared input recipe used by profile settings forms.
InputDecoration settingsInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  required IconData icon,
  String? suffixText,
}) {
  final shapes = context.shapeTokens;
  final surfaces = context.surfaceTokens;
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixText: suffixText,
      filled: true,
      fillColor: surfaces.settingsInput,
      border: OutlineInputBorder(borderRadius: shapes.settingsField),
    );
  }
  final fieldInk = _settingsInputInk(context);
  final fieldBorder = BorderSide(color: fieldInk, width: shapes.outlineWidth);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixText: suffixText,
    filled: true,
    fillColor: surfaces.settingsInput,
    labelStyle: TextStyle(color: fieldInk.withValues(alpha: 0.78)),
    floatingLabelStyle: TextStyle(color: fieldInk),
    hintStyle: TextStyle(color: fieldInk.withValues(alpha: 0.62)),
    prefixIconColor: fieldInk,
    suffixStyle: TextStyle(color: fieldInk),
    disabledBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: fieldInk.withValues(alpha: 0.38),
        width: shapes.outlineWidth,
      ),
    ),
    errorStyle: const TextStyle(color: Color(0xFFB3261E)),
    errorBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: const Color(0xFFB3261E),
        width: shapes.outlineWidth,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: const Color(0xFFB3261E),
        width: shapes.focusRingWidth,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: fieldBorder,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: context.semanticColors.focusRing,
        width: shapes.focusRingWidth,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: fieldBorder,
    ),
  );
}

/// Resolves the foreground style for values entered into a colored settings
/// field. Classic keeps its inherited input text style; outlined families
/// choose ink from the field surface so dark mode cannot leak canvas text onto
/// a bright field.
TextStyle? settingsInputTextStyle(BuildContext context, {bool enabled = true}) {
  if (!context.surfaceDecorationTokens.panel.outlined) return null;
  final fieldInk = _settingsInputInk(context);
  return Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: enabled ? fieldInk : fieldInk.withValues(alpha: 0.38),
  );
}

/// Resolves the icon foreground for a colored settings field.
Color? settingsInputForeground(BuildContext context) {
  if (!context.surfaceDecorationTokens.panel.outlined) return null;
  return _settingsInputInk(context);
}

/// Resolves a neutral popup surface for selectors whose trigger is a bright
/// settings field. The popup keeps its independent surface/foreground pairing.
Color? settingsDropdownMenuColor(BuildContext context) {
  if (!context.surfaceDecorationTokens.panel.outlined) return null;
  return Theme.of(context).colorScheme.surfaceContainerHighest;
}

/// Gives Neo dropdown entries the foreground of their neutral popup surface.
Widget settingsDropdownMenuLabel(BuildContext context, Widget child) {
  if (!context.surfaceDecorationTokens.panel.outlined) return child;
  final theme = Theme.of(context);
  final foreground = theme.colorScheme.onSurface;
  return DefaultTextStyle.merge(
    style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: foreground,
    ),
    child: IconTheme.merge(
      data: IconThemeData(color: foreground),
      child: child,
    ),
  );
}

/// Gives Neo's bright dropdown trigger the ink foreground of its field.
Widget settingsDropdownTriggerLabel(BuildContext context, Widget child) {
  final style = settingsInputTextStyle(context);
  if (style == null) return child;
  return DefaultTextStyle.merge(
    style: style,
    child: IconTheme.merge(
      data: IconThemeData(color: settingsInputForeground(context)),
      child: child,
    ),
  );
}

Color _settingsInputInk(BuildContext context) {
  final surfaces = context.surfaceTokens;
  return tonosForegroundForSurface(context, surfaces.settingsInput);
}

/// Builds the outlined field recipe used by compact settings forms.
InputDecoration settingsFieldDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  String? suffixText,
  bool isDense = false,
}) {
  final shapes = context.shapeTokens;
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      isDense: isDense,
      border: OutlineInputBorder(borderRadius: shapes.settingsField),
    );
  }

  final surfaces = context.surfaceTokens;
  final fieldInk = _settingsInputInk(context);
  final fieldBorder = BorderSide(
    color: tonosOutlineForSurface(context, surfaces.settingsInput),
    width: shapes.outlineWidth,
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    isDense: isDense,
    filled: true,
    fillColor: surfaces.settingsInput,
    labelStyle: TextStyle(color: fieldInk.withValues(alpha: 0.78)),
    floatingLabelStyle: TextStyle(color: fieldInk),
    hintStyle: TextStyle(color: fieldInk.withValues(alpha: 0.62)),
    prefixIconColor: fieldInk,
    suffixStyle: TextStyle(color: fieldInk),
    enabledBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: fieldBorder,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: context.semanticColors.focusRing,
        width: shapes.focusRingWidth,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: BorderSide(
        color: fieldInk.withValues(alpha: 0.38),
        width: shapes.outlineWidth,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: shapes.settingsField,
      borderSide: fieldBorder,
    ),
  );
}

/// Shared building blocks for the app's settings and profile pages.
class SettingsPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;
  final Widget? bottomNavigationBar;
  final Color? heroAccentColor;

  /// Shows the compact in-page back affordance above the hero card.
  /// The profile tab disables this because it is a root bottom-tab screen.
  final bool showBackButton;

  const SettingsPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.children,
    this.bottomNavigationBar,
    this.heroAccentColor,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            if (showBackButton) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: AppLocalizations.of(context).commonBack,
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: 4),
            ],
            SettingsHeroCard(
              title: title,
              subtitle: subtitle,
              icon: icon,
              accentColor: heroAccentColor,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
      backgroundColor: scheme.surface,
    );
  }
}

class SettingsHeroCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;

  const SettingsHeroCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final presentation = context.settingsPresentationTokens;
    final accent = accentColor ?? scheme.primary;
    final usesClassicPresentation = context.usesClassicPresentation;

    // Classic keeps its established compact hero at ordinary text sizes.
    // The responsive treatment remains available for large accessibility text.
    if (usesClassicPresentation &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15) {
      final languageCode = Localizations.localeOf(context).languageCode;
      final usesLocalizedLayout = languageCode != 'en';
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: shapes.hero,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.26), surfaces.settingsHero],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.42)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  usesLocalizedLayout
                      ? Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.onSurface,
                        ),
                      )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          final fontSize =
                              constraints.maxWidth >= 290
                                  ? 28.0
                                  : constraints.maxWidth >= 220
                                  ? 25.0
                                  : 22.0;
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              maxLines: 1,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    final heroForeground =
        presentation.heroUsesGradient
            ? scheme.onSurface
            : tonosForegroundForSurface(context, surfaces.settingsHero);
    final heroShadow =
        presentation.heroUsesHardShadow && effects.cardShadow.a > 0
            ? <BoxShadow>[
              BoxShadow(
                color: effects.cardShadow,
                blurRadius: effects.cardShadowBlur,
                offset: effects.raisedPanelShadowOffset,
              ),
            ]
            : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: shapes.hero,
        color: presentation.heroUsesGradient ? null : surfaces.settingsHero,
        gradient:
            presentation.heroUsesGradient
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(
                      alpha: presentation.heroAccentFillOpacity,
                    ),
                    surfaces.settingsHero,
                  ],
                )
                : null,
        border: Border.all(
          color:
              presentation.heroUsesGradient
                  ? accent.withValues(alpha: presentation.heroBorderOpacity)
                  : tonosOutlineForSurface(context, surfaces.settingsHero),
          width: shapes.outlineWidth,
        ),
        boxShadow: heroShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final scaleForLayout = textScale.clamp(1.0, 1.6).toDouble();
          final minimumCopyWidth = 210.0 * scaleForLayout;
          final useStackedLayout =
              textScale > 1.15 || constraints.maxWidth < 68 + minimumCopyWidth;
          final iconBubble = Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: presentation.heroIconFillOpacity),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: presentation.heroUsesGradient ? accent : heroForeground,
              size: 28,
            ),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: heroForeground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        presentation.heroUsesGradient
                            ? scheme.onSurfaceVariant
                            : heroForeground.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ],
          );
          if (useStackedLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [iconBubble, const SizedBox(height: 12), copy],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconBubble,
              const SizedBox(width: 14),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color? accentColor;
  final Color? surfaceColor;
  final bool? neutralSurface;

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.accentColor,
    this.surfaceColor,
    this.neutralSurface,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final presentation = context.settingsPresentationTokens;
    final accent = accentColor;
    final resolvedSurface = surfaceColor ?? surfaces.settingsSection;
    final usesCategoryLabel =
        presentation.sectionHeaderUsesLabel && accent != null;
    final controlForeground = tonosForegroundForSurface(
      context,
      resolvedSurface,
    );
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;

    final sectionContents = Column(children: children);
    final sectionChild =
        usesInkRecipe ||
                (accent != null && presentation.sectionUsesAccentForControls)
            ? Theme(
              data: theme.copyWith(
                colorScheme: scheme.copyWith(
                  surface: usesInkRecipe ? resolvedSurface : scheme.surface,
                  primary:
                      presentation.sectionUsesAccentForControls &&
                              accent != null
                          ? accent
                          : scheme.primary,
                  onSurface: controlForeground,
                  onSurfaceVariant: tonosSecondaryForegroundForSurface(
                    context,
                    resolvedSurface,
                  ),
                ),
                textTheme:
                    usesInkRecipe
                        ? theme.textTheme.apply(
                          bodyColor: controlForeground,
                          displayColor: controlForeground,
                        )
                        : theme.textTheme,
                iconTheme:
                    usesInkRecipe
                        ? theme.iconTheme.copyWith(color: controlForeground)
                        : theme.iconTheme,
                listTileTheme:
                    usesInkRecipe
                        ? theme.listTileTheme.copyWith(
                          textColor: controlForeground,
                          iconColor: controlForeground,
                        )
                        : theme.listTileTheme,
                progressIndicatorTheme:
                    usesInkRecipe
                        ? theme.progressIndicatorTheme.copyWith(
                          color: controlForeground,
                        )
                        : theme.progressIndicatorTheme,
              ),
              child: sectionContents,
            )
            : sectionContents;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child:
                usesCategoryLabel
                    ? _SettingsCategoryLabelHeader(
                      title: title,
                      subtitle: subtitle,
                      presentation: presentation,
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (accent != null) ...[
                          Container(
                            width: 4,
                            height: subtitle == null ? 22 : 38,
                            margin: const EdgeInsets.only(top: 1, right: 9),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: shapes.pill,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: accent ?? scheme.onSurface,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
          Container(
            decoration: BoxDecoration(
              color: resolvedSurface,
              borderRadius: shapes.sheet,
              border: Border.all(
                color:
                    usesInkRecipe
                        ? tonosOutlineForSurface(
                          context,
                          resolvedSurface,
                          neutral: neutralSurface,
                        )
                        : (usesCategoryLabel
                            ? surfaces.subtleOutline
                            : (accent ?? scheme.outlineVariant).withValues(
                              alpha:
                                  accent == null
                                      ? presentation.sectionNeutralBorderOpacity
                                      : presentation.sectionAccentBorderOpacity,
                            )),
                width: shapes.outlineWidth,
              ),
            ),
            child: sectionChild,
          ),
        ],
      ),
    );
  }
}

class _SettingsCategoryLabelHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AppSettingsPresentationTokens presentation;

  const _SettingsCategoryLabelHeader({
    required this.title,
    required this.subtitle,
    required this.presentation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: presentation.sectionHeaderFill,
            border: Border.all(
              color: tonosOutlineForSurface(
                context,
                presentation.sectionHeaderFill,
              ),
              width: shapes.outlineWidth,
            ),
            borderRadius: shapes.compact,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: presentation.sectionHeaderForeground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shared expandable section recipe for settings pages.
class SettingsExpansionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final Color accentColor;

  const SettingsExpansionSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final presentation = context.settingsPresentationTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final controlForeground = tonosForegroundForSurface(
      context,
      surfaces.settingsSection,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: surfaces.settingsSection,
          borderRadius: shapes.sheet,
          border: Border.all(
            color:
                usesInkRecipe
                    ? tonosOutlineForSurface(context, surfaces.settingsSection)
                    : accentColor.withValues(
                      alpha: presentation.sectionAccentBorderOpacity,
                    ),
            width: shapes.outlineWidth,
          ),
        ),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
            colorScheme: scheme.copyWith(
              primary:
                  presentation.sectionUsesAccentForControls
                      ? accentColor
                      : scheme.primary,
              onSurface: usesInkRecipe ? controlForeground : scheme.onSurface,
              onSurfaceVariant:
                  usesInkRecipe
                      ? tonosSecondaryForegroundForSurface(
                        context,
                        surfaces.settingsSection,
                      )
                      : scheme.onSurfaceVariant,
            ),
            textTheme:
                usesInkRecipe
                    ? theme.textTheme.apply(
                      bodyColor: controlForeground,
                      displayColor: controlForeground,
                    )
                    : theme.textTheme,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    usesInkRecipe
                        ? accentColor.withValues(alpha: 0.28)
                        : accentColor.withValues(
                          alpha: presentation.iconFillOpacity,
                        ),
                borderRadius: shapes.settingsAction,
              ),
              child: Icon(
                icon,
                color: usesInkRecipe ? controlForeground : accentColor,
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: usesInkRecipe ? controlForeground : null,
              ),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    usesInkRecipe
                        ? controlForeground.withValues(alpha: 0.72)
                        : scheme.onSurfaceVariant,
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Explicitly styled names are created outside the ranked row's subtree.
TextStyle? settingsRankingNameTextStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.w900,
    color:
        context.surfaceDecorationTokens.panel.outlined
            ? tonosForegroundForSurface(
              context,
              context.surfaceTokens.settingsSection,
            )
            : theme.textTheme.titleSmall?.color,
  );
}

/// Shared ranked settings row with reorder and compact rank editing.
class SettingsRankingTile extends StatelessWidget {
  final int index;
  final Widget name;
  final int rank;
  final IconData icon;
  final String rankLabel;
  final ValueChanged<String> onRankSubmitted;

  const SettingsRankingTile({
    super.key,
    required this.index,
    required this.name,
    required this.rank,
    required this.icon,
    required this.rankLabel,
    required this.onRankSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final presentation = context.settingsPresentationTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final rowForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.settingsSection)
            : scheme.onSurface;
    final rowSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              surfaces.settingsSection,
            )
            : scheme.onSurfaceVariant;
    final rankFieldInk = settingsInputForeground(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaces.settingsSection,
        borderRadius: shapes.settingsPanel,
        border: Border.all(
          color:
              usesInkRecipe
                  ? tonosOutlineForSurface(context, surfaces.settingsSection)
                  : scheme.outlineVariant.withValues(
                    alpha: presentation.sectionNeutralBorderOpacity,
                  ),
          width: shapes.outlineWidth,
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: rowSecondaryForeground),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(
              alpha: presentation.iconFillOpacity,
            ),
            child: Icon(
              icon,
              color: usesInkRecipe ? rowForeground : scheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: rowForeground),
              child: IconTheme.merge(
                data: IconThemeData(color: rowForeground),
                child: name,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: TextFormField(
              key: ValueKey('rank-$rank'),
              initialValue: rank.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: settingsInputTextStyle(context),
              decoration: InputDecoration(
                labelText: rankLabel,
                isDense: true,
                filled: usesInkRecipe,
                fillColor: usesInkRecipe ? surfaces.settingsInput : null,
                labelStyle:
                    rankFieldInk == null
                        ? null
                        : TextStyle(
                          color: rankFieldInk.withValues(alpha: 0.78),
                        ),
                floatingLabelStyle:
                    rankFieldInk == null
                        ? null
                        : TextStyle(color: rankFieldInk),
                border: OutlineInputBorder(borderRadius: shapes.settingsInput),
              ),
              onFieldSubmitted: onRankSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final presentation = context.settingsPresentationTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final controlForeground = scheme.onSurface;
    final resolvedIconColor = iconColor ?? scheme.primary;
    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              usesInkRecipe
                  ? resolvedIconColor.withValues(alpha: 0.28)
                  : resolvedIconColor.withValues(
                    alpha: presentation.iconFillOpacity,
                  ),
          borderRadius: shapes.settingsAction,
        ),
        child: Icon(
          icon,
          color: usesInkRecipe ? controlForeground : resolvedIconColor,
          size: 22,
        ),
      ),
      title:
          titleWidget ??
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: usesInkRecipe ? controlForeground : null,
            ),
          ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                subtitle!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      usesInkRecipe
                          ? controlForeground.withValues(alpha: 0.72)
                          : scheme.onSurfaceVariant,
                ),
              ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: usesInkRecipe ? controlForeground : scheme.onSurfaceVariant,
          ),
      onTap: onTap,
    );
    if (!usesInkRecipe) return tile;
    return DefaultTextStyle.merge(
      style: TextStyle(color: controlForeground),
      child: IconTheme.merge(
        data: IconThemeData(color: controlForeground),
        child: tile,
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsActionTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}

class SettingsInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color? iconColor;

  const SettingsInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final presentation = context.settingsPresentationTokens;
    final resolvedIconColor = iconColor ?? scheme.primary;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final foreground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.settingsSection)
            : scheme.onSurface;
    final secondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(
              context,
              surfaces.settingsSection,
            )
            : scheme.onSurfaceVariant;
    final iconForeground = usesInkRecipe ? foreground : resolvedIconColor;

    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaces.settingsSection,
        borderRadius: shapes.sheet,
        border: Border.all(
          color:
              usesInkRecipe
                  ? tonosOutlineForSurface(context, surfaces.settingsSection)
                  : scheme.outlineVariant.withValues(
                    alpha: presentation.infoBorderOpacity,
                  ),
          width: shapes.outlineWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: resolvedIconColor.withValues(
                alpha: presentation.iconFillOpacity,
              ),
              borderRadius: shapes.settingsAction,
            ),
            child: Icon(icon, color: iconForeground, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!usesInkRecipe) return content;
    return Theme(
      data: theme.copyWith(
        colorScheme: scheme.copyWith(
          onSurface: foreground,
          onSurfaceVariant: secondaryForeground,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: foreground,
          displayColor: foreground,
        ),
      ),
      child: content,
    );
  }
}

/// Shared save action bar for settings screens.
class SettingsSaveBar extends StatelessWidget {
  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final Widget? saveIcon;
  final bool isVisible;
  final bool animate;
  final bool decorated;
  final EdgeInsetsGeometry padding;

  const SettingsSaveBar({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
    this.cancelLabel,
    this.onCancel,
    this.saveIcon,
    this.isVisible = true,
    this.animate = false,
    this.decorated = true,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.cs;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final motion = context.motionTokens;
    final presentation = context.settingsPresentationTokens;
    final saveBarBorderColor =
        presentation.saveActionUsesHardShadow &&
                context.surfaceDecorationTokens.panel.outlined
            ? tonosOutlineForSurface(context, surfaces.settingsSaveBar)
            : presentation.saveActionUsesHardShadow
            ? surfaces.subtleOutline
            : scheme.outlineVariant.withValues(
              alpha: presentation.saveBarBorderOpacity,
            );
    final saveButton = FilledButton.icon(
      key: buttonKey,
      onPressed: isVisible ? onPressed : null,
      icon: saveIcon ?? const Icon(Icons.save_outlined),
      label: Text(label),
    );
    final decoratedSaveButton =
        presentation.saveActionUsesHardShadow
            ? tonosWithPrimaryActionDepth(
              context,
              saveButton,
              borderRadius: shapes.settingsAction,
              enabled: isVisible && onPressed != null,
            )
            : saveButton;
    final action = switch (cancelLabel) {
      null => decoratedSaveButton,
      final label => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isVisible ? onCancel : null,
              child: Text(label),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: decoratedSaveButton),
        ],
      ),
    };
    final button = Padding(padding: padding, child: action);
    final bar = SafeArea(
      top: false,
      child:
          decorated
              ? Container(
                decoration: BoxDecoration(
                  color: surfaces.settingsSaveBar,
                  border: Border(
                    top: BorderSide(
                      color: saveBarBorderColor,
                      width: shapes.outlineWidth,
                    ),
                  ),
                ),
                child: button,
              )
              : button,
    );
    if (!animate) return bar;
    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? motion.reduced
            : motion.standard;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: duration,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: duration,
        child: bar,
      ),
    );
  }
}

List<Widget> settingsTilesWithDividers(
  BuildContext context,
  List<Widget> tiles,
) {
  final dividerColor = context.cs.outlineVariant.withValues(alpha: 0.55);
  return [
    for (var i = 0; i < tiles.length; i++) ...[
      tiles[i],
      if (i != tiles.length - 1)
        Divider(height: 1, indent: 70, color: dividerColor),
    ],
  ];
}
