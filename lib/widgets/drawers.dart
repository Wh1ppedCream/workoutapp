// file: lib/widgets/drawers.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../screens/exercise/gym_profile_screen.dart';

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
  final String headerTitle;
  final List<DrawerItem>? items;

  const MainDrawer({super.key, this.headerTitle = 'Navigation', this.items});

  @override
  Widget build(BuildContext context) {
    final useDefault = items == null || items!.isEmpty;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              headerTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          if (useDefault) ...[
            const ListTile(title: Text('Option A')),
            const ListTile(title: Text('Option B')),
            const ListTile(title: Text('Option C')),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const palette = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
                  Icon(
                    Icons.fitness_center,
                    color: scheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Gym Profiles',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selected == null
                        ? '${profiles.length} saved spaces'
                        : '${selected.name} is active',
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
              final color = palette[index % palette.length];
              final isSelected = profile.id == selected?.id;
              return ProfileTile(
                profile: profile,
                isSelected: isSelected,
                color: color,
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
  final ValueChanged<dynamic> onSelect;
  final ValueChanged<dynamic> onEdit;
  final VoidCallback onDelete;

  const ProfileTile({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.color,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tileColor =
        isSelected
            ? color.withValues(alpha: 0.22)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.36);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(
          color: isSelected ? color : scheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
                  color: isSelected ? color : scheme.onSurfaceVariant,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSelected ? 'Active profile' : 'Tap to switch',
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
                icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                onSelected: (action) {
                  if (action == 'edit') {
                    onEdit(profile);
                  } else if (action == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
                'New Profile',
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
