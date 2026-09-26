import 'package:flutter/material.dart';

enum _ExpansionTileDensity { inherited, compact, dense }

/// Applies the shared divider and density recipes around an ExpansionTile.
class TonosExpansionTileScope extends StatelessWidget {
  const TonosExpansionTileScope({super.key, required this.child})
    : _density = _ExpansionTileDensity.inherited;

  const TonosExpansionTileScope.compact({super.key, required this.child})
    : _density = _ExpansionTileDensity.compact;

  const TonosExpansionTileScope.dense({super.key, required this.child})
    : _density = _ExpansionTileDensity.dense;

  final Widget child;
  final _ExpansionTileDensity _density;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listTileTheme = switch (_density) {
      _ExpansionTileDensity.inherited => theme.listTileTheme,
      _ExpansionTileDensity.compact => theme.listTileTheme.copyWith(
        dense: true,
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
      ),
      _ExpansionTileDensity.dense => theme.listTileTheme.copyWith(
        dense: true,
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity(horizontal: 0, vertical: -3),
      ),
    };
    final iconTheme =
        _density == _ExpansionTileDensity.inherited
            ? theme.iconTheme
            : theme.iconTheme.copyWith(size: 18);

    return Theme(
      data: theme.copyWith(
        dividerColor: Colors.transparent,
        listTileTheme: listTileTheme,
        iconTheme: iconTheme,
      ),
      child: child,
    );
  }
}
