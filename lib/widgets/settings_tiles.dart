import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/theme_extensions.dart';

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

/// Displays a compact settings value using the active accent role.
class SettingsValueText extends StatelessWidget {
  final String value;

  const SettingsValueText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      value,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaces.panelRaised,
        borderRadius: shapes.pill,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foregroundColor ?? scheme.onSurfaceVariant,
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
  final EdgeInsetsGeometry padding;
  final double backgroundAlpha;
  final double? borderAlpha;
  final FontWeight fontWeight;

  const SettingsAccentPill({
    super.key,
    required this.label,
    required this.color,
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
          color: color,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.shapeTokens.pill,
        border: Border.all(color: color.withValues(alpha: 0.36)),
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
              color: color,
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
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: context.shapeTokens.pill,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
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
  final surfaces = context.surfaceTokens;
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixText: suffixText,
    filled: true,
    fillColor: surfaces.settingsInput,
    border: OutlineInputBorder(borderRadius: context.shapeTokens.settingsField),
  );
}

/// Builds the outlined field recipe used by compact settings forms.
InputDecoration settingsFieldDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  String? suffixText,
  bool isDense = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    isDense: isDense,
    border: OutlineInputBorder(borderRadius: context.shapeTokens.settingsField),
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
    final accent = accentColor ?? scheme.primary;
    final languageCode = Localizations.localeOf(context).languageCode;
    final usesLocalizedLayout = languageCode != 'en';
    final isSpanish = languageCode == 'es';

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
                      maxLines: 2,
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
                    maxLines: isSpanish ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
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
}

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color? accentColor;

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final accent = accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
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
              color: surfaces.settingsSection,
              borderRadius: shapes.sheet,
              border: Border.all(
                color: (accent ?? scheme.outlineVariant).withValues(
                  alpha: accent == null ? 0.55 : 0.46,
                ),
              ),
            ),
            child:
                accent == null
                    ? Column(children: children)
                    : Theme(
                      data: theme.copyWith(
                        colorScheme: scheme.copyWith(primary: accent),
                      ),
                      child: Column(children: children),
                    ),
          ),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: surfaces.settingsSection,
          borderRadius: shapes.sheet,
          border: Border.all(color: accentColor.withValues(alpha: 0.46)),
        ),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
            colorScheme: scheme.copyWith(primary: accentColor),
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
                color: accentColor.withValues(alpha: 0.16),
                borderRadius: shapes.settingsAction,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaces.settingsSection,
        borderRadius: shapes.settingsPanel,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(alpha: 0.16),
            child: Icon(icon, color: scheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: name),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: TextFormField(
              key: ValueKey('rank-$rank'),
              initialValue: rank.toString(),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: rankLabel,
                isDense: true,
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
    final resolvedIconColor = iconColor ?? scheme.primary;
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: resolvedIconColor.withValues(alpha: 0.16),
          borderRadius: shapes.settingsAction,
        ),
        child: Icon(icon, color: resolvedIconColor, size: 22),
      ),
      title:
          titleWidget ??
          Text(
            title,
            maxLines: usesLocalizedLayout ? 2 : 1,
            overflow: usesLocalizedLayout ? null : TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                subtitle!,
                maxLines: usesLocalizedLayout ? 3 : 2,
                overflow: usesLocalizedLayout ? null : TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
      onTap: onTap,
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
    final resolvedIconColor = iconColor ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaces.settingsSection,
        borderRadius: shapes.sheet,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: resolvedIconColor.withValues(alpha: 0.16),
              borderRadius: shapes.settingsAction,
            ),
            child: Icon(icon, color: resolvedIconColor, size: 22),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final motion = context.motionTokens;
    final saveButton = FilledButton.icon(
      key: buttonKey,
      onPressed: isVisible ? onPressed : null,
      icon: saveIcon ?? const Icon(Icons.save_outlined),
      label: Text(label),
    );
    final action = switch (cancelLabel) {
      null => saveButton,
      final label => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isVisible ? onCancel : null,
              child: Text(label),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: saveButton),
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
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
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
