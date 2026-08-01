import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Shared semantic accents for grouped settings content.
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
    final accent = accentColor ?? scheme.primary;
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.26),
            scheme.surfaceContainerHighest.withValues(alpha: 0.54),
          ],
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
                    maxLines: 2,
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
                      borderRadius: BorderRadius.circular(99),
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
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(24),
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

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: resolvedIconColor, size: 22),
      ),
      title: Text(
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
    final resolvedIconColor = iconColor ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
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
              borderRadius: BorderRadius.circular(15),
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

List<Widget> settingsTilesWithDividers(
  BuildContext context,
  List<Widget> tiles,
) {
  final dividerColor = Theme.of(
    context,
  ).colorScheme.outlineVariant.withValues(alpha: 0.55);
  return [
    for (var i = 0; i < tiles.length; i++) ...[
      tiles[i],
      if (i != tiles.length - 1)
        Divider(height: 1, indent: 70, color: dividerColor),
    ],
  ];
}
