// file: lib/widgets/drawers.dart
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/widgets/tonos_overlay_routes.dart';

import '../l10n/generated/app_localizations.dart';
import '../screens/exercise/gym_profile_screen.dart';
import '../theme/theme_extensions.dart';
import 'identity_color_palettes.dart';

export 'identity_color_palettes.dart';

/// Represents an entry in the main drawer.
class DrawerItem {
  final String title;
  final WidgetBuilder? builder;
  final IconData? icon;
  final Future<void> Function(BuildContext context)? onTap;

  const DrawerItem({required this.title, this.builder, this.icon, this.onTap})
    : assert(builder != null || onTap != null);
}

/// A simple, configurable drawer for main navigation options.
/// If [items] is null or empty, shows default placeholder options.
class MainDrawer extends StatelessWidget {
  final List<DrawerItem>? items;

  const MainDrawer({super.key, this.headerTitle, this.items});

  final String? headerTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = context.semanticColors;
    final strings = AppLocalizations.of(context);
    final useDefault = items == null || items!.isEmpty;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Text(
              headerTitle ?? strings.drawerNavigation,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: semantic.drawerHeaderForeground,
              ),
            ),
          ),
          if (useDefault) ...[
            ListTile(title: Text(strings.drawerOptionA)),
            ListTile(title: Text(strings.drawerOptionB)),
            ListTile(title: Text(strings.drawerOptionC)),
          ] else
            ...items!.map((item) {
              return ListTile(
                leading: item.icon == null ? null : Icon(item.icon),
                title: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final customTap = item.onTap;
                  if (customTap != null) {
                    unawaited(customTap(context));
                    return;
                  }

                  final builder = item.builder;
                  if (builder == null) return;
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    await navigator.maybePop();
                  }
                  if (!navigator.mounted) return;
                  unawaited(
                    navigator.push(MaterialPageRoute(builder: builder)),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}

/// A drawer listing gym profiles with selection, edit, and delete actions.
class ProfileDrawer extends StatelessWidget {
  final List profiles;
  final dynamic selected;
  final ValueChanged<dynamic> onSelect;
  final ValueChanged<dynamic> onEdit;
  final ValueChanged<dynamic> onDelete;

  const ProfileDrawer({
    super.key,
    required this.profiles,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final useExpressive = context.usesExpressivePresentation;
    return Drawer(
      backgroundColor: useExpressive
          ? (theme.brightness == Brightness.dark
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainerLow)
          : scheme.surface,
      surfaceTintColor: useExpressive ? Colors.transparent : null,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          children: [
            Container(
              padding: EdgeInsets.all(useExpressive ? 16 : 18),
              decoration: BoxDecoration(
                borderRadius: shapes.sheet,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.88),
                    scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (useExpressive)
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: scheme.onPrimaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            strings.drawerGymProfiles,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Icon(
                      Icons.fitness_center,
                      color: scheme.onPrimaryContainer,
                      size: 28,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      strings.drawerGymProfiles,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  SizedBox(height: useExpressive ? 8 : 6),
                  Text(
                    selected == null
                        ? strings.drawerSavedSpaces(profiles.length)
                        : strings.drawerProfileActive(selected.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...profiles.asMap().entries.map((entry) {
              final index = entry.key;
              final profile = entry.value;
              final color = ProfileIdentityPalette
                  .colors[index % ProfileIdentityPalette.colors.length];
              final isSelected = profile.id == selected?.id;
              return ProfileTile(
                profile: profile,
                isSelected: isSelected,
                color: color,
                selectionColor: useExpressive ? scheme.primary : color,
                onSelect: onSelect,
                onEdit: onEdit,
                onDelete: () => onDelete(profile),
              );
            }),
            const SizedBox(height: 12),
            _NewProfileTile(
              onTap: () async {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  await navigator.maybePop();
                }
                if (!navigator.mounted) return;
                unawaited(
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const GymProfileScreen()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row in [ProfileDrawer].
class ProfileTile extends StatelessWidget {
  final dynamic profile;
  final bool isSelected;
  final Color color;
  final Color? selectionColor;
  final ValueChanged<dynamic> onSelect;
  final ValueChanged<dynamic> onEdit;
  final VoidCallback onDelete;

  const ProfileTile({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.color,
    this.selectionColor,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final motion = context.motionTokens;
    final useExpressive = context.usesExpressivePresentation;
    final activeColor = selectionColor ?? color;
    final tileColor = isSelected
        ? activeColor.withValues(alpha: useExpressive ? 0.18 : 0.22)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.36);

    return AnimatedContainer(
      duration: appMotionDuration(context, motion.quick),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(
          color: isSelected
              ? activeColor
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.4 : 1,
        ),
        borderRadius: shapes.profileTile,
      ),
      child: InkWell(
        borderRadius: shapes.profileTile,
        onTap: () => onSelect(profile),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isSelected ? 0.28 : 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.fitness_center,
                  color: isSelected ? activeColor : scheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: useExpressive ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSelected
                          ? strings.drawerActiveProfile
                          : strings.drawerTapToSwitch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                popUpAnimationStyle: tonosOverlayMotion(context),
                icon: Icon(
                  Icons.more_vert,
                  color: scheme.onSurfaceVariant,
                  size: useExpressive ? 20 : null,
                ),
                padding: useExpressive
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(8),
                constraints: useExpressive
                    ? const BoxConstraints(
                        minWidth: 132,
                        maxWidth: 192,
                        minHeight: 48,
                        maxHeight: 240,
                      )
                    : null,
                shape: useExpressive
                    ? RoundedRectangleBorder(
                        borderRadius: shapes.settingsPicker,
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                      )
                    : null,
                color: useExpressive ? scheme.surfaceContainerHigh : null,
                surfaceTintColor: useExpressive ? Colors.transparent : null,
                menuPadding: useExpressive
                    ? const EdgeInsets.symmetric(vertical: 4)
                    : null,
                onSelected: (action) {
                  if (action == 'edit') {
                    onEdit(profile);
                  } else if (action == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    height: useExpressive ? 44 : kMinInteractiveDimension,
                    padding: useExpressive
                        ? const EdgeInsets.symmetric(horizontal: 16)
                        : null,
                    child: useExpressive
                        ? Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                strings.commonEdit,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          )
                        : Text(strings.commonEdit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    height: useExpressive ? 44 : kMinInteractiveDimension,
                    padding: useExpressive
                        ? const EdgeInsets.symmetric(horizontal: 16)
                        : null,
                    child: useExpressive
                        ? Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: scheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                strings.commonDelete,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.error,
                                ),
                              ),
                            ],
                          )
                        : Text(strings.commonDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewProfileTile extends StatelessWidget {
  final VoidCallback onTap;

  const _NewProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;

    return InkWell(
      borderRadius: shapes.profileTile,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: shapes.profileTile,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.drawerNewProfile,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
