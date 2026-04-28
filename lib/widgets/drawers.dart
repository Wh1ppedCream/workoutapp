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
                title: Text(item.title),
                onTap: () {
                  final customTap = item.onTap;
                  if (customTap != null) {
                    unawaited(customTap(context));
                    return;
                  }

                  final builder = item.builder;
                  if (builder == null) return;
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: builder));
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
  final VoidCallback onDeleteAll;

  const ProfileDrawer({
    super.key,
    required this.profiles,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    // define a palette for row highlighting
    const palette = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightGreen),
            child: Text(
              'Gym Profiles',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // one tile per profile
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
              onDelete: () => onDeleteAll(),
            );
          }),

          const Divider(),

          // add a new profile
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GymProfileScreen()),
              );
            },
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Radio<bool>(
          value: true,
          groupValue: isSelected,
          onChanged: (_) => onSelect(profile),
        ),
        title: Text(profile.name),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') {
              Navigator.of(context).pop();
              onEdit(profile);
            } else if (action == 'delete') {
              Navigator.of(context).pop();
              onDelete();
            }
          },
          itemBuilder:
              (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }
}
