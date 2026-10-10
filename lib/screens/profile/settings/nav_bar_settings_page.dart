import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localization_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/nav_bar_config.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/tokens/app_effect_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../utils/app_test_keys.dart';
import '../../../widgets/settings_tiles.dart';

class NavBarSettingsPage extends StatefulWidget {
  const NavBarSettingsPage({super.key});

  @override
  State<NavBarSettingsPage> createState() => _NavBarSettingsPageState();
}

class _NavBarSettingsPageState extends State<NavBarSettingsPage> {
  late List<TabItem> _activeTabs;
  late List<TabItem> _inactiveTabs;
  late List<TabItem> _savedActiveTabs;
  late List<TabItem> _savedInactiveTabs;

  bool get _hasUnsavedChanges =>
      !_sameTabOrder(_activeTabs, _savedActiveTabs) ||
      !_sameTabOrder(_inactiveTabs, _savedInactiveTabs);

  @override
  void initState() {
    super.initState();
    final config = context.read<NavBarConfig>();
    _activeTabs = config.order
        .where((tab) => config.enabledTabs.contains(tab))
        .toList();
    _inactiveTabs = config.order
        .where((tab) => !config.enabledTabs.contains(tab))
        .toList();
    _savedActiveTabs = List.of(_activeTabs);
    _savedInactiveTabs = List.of(_inactiveTabs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final tab = _activeTabs.removeAt(oldIndex);
      _activeTabs.insert(newIndex, tab);
    });
  }

  void _toggleTab(TabItem tab, bool enable) {
    setState(() {
      if (enable) {
        _inactiveTabs.remove(tab);
        _activeTabs.add(tab);
      } else {
        if (tab == TabItem.profile) return;
        _activeTabs.remove(tab);
        _inactiveTabs.add(tab);
      }
    });
  }

  void _save() {
    final strings = AppLocalizations.of(context);
    if (_activeTabs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.navEditorMinimumTabsError)),
      );
      return;
    }

    final newOrder = [..._activeTabs, ..._inactiveTabs];
    final newEnabled = _activeTabs.toSet();
    context.read<NavBarConfig>().update(
      newOrder: newOrder,
      newEnabled: newEnabled,
    );
    setState(() {
      _activeTabs = newOrder.where((tab) => newEnabled.contains(tab)).toList();
      _inactiveTabs = newOrder
          .where((tab) => !newEnabled.contains(tab))
          .toList();
      _savedActiveTabs = List.of(_activeTabs);
      _savedInactiveTabs = List.of(_inactiveTabs);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings.navEditorSavedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final profileDestination =
        destination?.family == AppExpressiveDestinationFamily.profile;
    if (context.usesExpressivePresentation && !profileDestination) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.profile,
        child: Builder(builder: _buildPage),
      );
    }
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final isProfileExpressive =
        context.usesExpressivePresentation &&
        destination?.family == AppExpressiveDestinationFamily.profile;
    final inactiveDisplay = _inactiveTabs
        .where((tab) => tab != TabItem.profile)
        .toList();

    return SettingsPageScaffold(
      title: strings.navEditorTitle,
      subtitle: strings.navEditorSubtitle,
      icon: Icons.space_dashboard_outlined,
      heroAccentColor: SettingsAccent.data,
      bottomNavigationBar: isProfileExpressive
          ? null
          : SettingsSaveBar(
              buttonKey: AppTestKeys.navigationSave,
              label: strings.navEditorSave,
              onPressed: _save,
              decorated: false,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            ),
      floatingActionButton: isProfileExpressive && _hasUnsavedChanges
          ? FloatingActionButton.extended(
              key: AppTestKeys.navigationSave,
              onPressed: _save,
              backgroundColor: destination!.actionPrimary,
              foregroundColor: destination.onActionPrimary,
              icon: const Icon(Icons.save_outlined),
              label: Text(strings.navEditorSave),
            )
          : null,
      children: [
        SettingsSection(
          title: strings.navEditorActiveTitle,
          subtitle: strings.navEditorActiveSubtitle,
          accentColor: isProfileExpressive
              ? destination!.outlineAccent
              : SettingsAccent.data,
          surfaceColor: isProfileExpressive
              ? Color.lerp(
                  destination!.surfaceSelected,
                  destination.pageCanvas,
                  0.58,
                )
              : null,
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _onReorder,
              itemCount: _activeTabs.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                final contents = MediaQuery.disableAnimationsOf(context)
                    ? child
                    : ScaleTransition(
                        scale: Tween<double>(
                          begin: 1,
                          end: 1.02,
                        ).animate(animation),
                        child: child,
                      );
                return Material(color: Colors.transparent, child: contents);
              },
              itemBuilder: (context, index) {
                final tab = _activeTabs[index];
                return Padding(
                  key: ValueKey('active-${tab.name}'),
                  padding: EdgeInsets.symmetric(
                    vertical: isProfileExpressive ? 2 : 4,
                  ),
                  child: _NavTabTile(
                    tab: tab,
                    isActive: true,
                    isLocked: tab == TabItem.profile,
                    dragIndex: index,
                    isFirstActiveTab: index == 0,
                    isLastActiveTab: index == _activeTabs.length - 1,
                    onToggle: (value) => _toggleTab(tab, value),
                  ),
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: strings.navEditorInactiveTitle,
          subtitle: strings.navEditorInactiveSubtitle,
          accentColor: isProfileExpressive
              ? Color.lerp(
                  SettingsAccent.muted,
                  destination!.supportingForeground,
                  0.42,
                )!
              : SettingsAccent.muted,
          children: inactiveDisplay.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(strings.navEditorNoInactiveTabs),
                  ),
                ]
              : settingsTilesWithDividers(context, [
                  for (final tab in inactiveDisplay)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isProfileExpressive ? 2 : 4,
                      ),
                      child: _NavTabTile(
                        key: ValueKey('inactive-${tab.name}'),
                        tab: tab,
                        isActive: false,
                        onToggle: (value) => _toggleTab(tab, value),
                      ),
                    ),
                ]),
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _NavTabTile extends StatelessWidget {
  final TabItem tab;
  final bool isActive;
  final bool isLocked;
  final int? dragIndex;
  final bool isFirstActiveTab;
  final bool isLastActiveTab;
  final ValueChanged<bool> onToggle;

  const _NavTabTile({
    super.key,
    required this.tab,
    required this.isActive,
    this.isLocked = false,
    this.dragIndex,
    this.isFirstActiveTab = false,
    this.isLastActiveTab = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final trainTokens = theme.extension<AppExpressiveTrainTokens>();
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    final profileDestination =
        destination?.family == AppExpressiveDestinationFamily.profile
        ? destination
        : null;
    final stateForeground = profileDestination == null
        ? null
        : isActive
        ? profileDestination.onSurfaceSelected
        : profileDestination.supportingForeground;
    final profileExpressive = expressive && profileDestination != null;
    final neutralControl = scheme.surfaceContainerHighest;
    final switchWidget = Switch(
      value: isActive,
      onChanged: isLocked ? null : onToggle,
    );
    final themedSwitch = profileExpressive
        ? Theme(
            data: theme.copyWith(
              switchTheme: theme.switchTheme.copyWith(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return scheme.onSurfaceVariant.withValues(alpha: 0.56);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return profileDestination.actionPrimary;
                  }
                  return scheme.onSurfaceVariant;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return neutralControl;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return profileDestination.surfaceSelected;
                  }
                  return neutralControl;
                }),
              ),
            ),
            child: switchWidget,
          )
        : switchWidget;
    final trailing = profileExpressive && isLocked
        ? _RequiredTabIndicator(tokens: profileDestination)
        : themedSwitch;
    final tile = ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: profileExpressive ? 2 : 6,
      ),
      leading: dragIndex == null
          ? _IconBadge(icon: tab.icon, isActive: isActive)
          : ReorderableDragStartListener(
              index: dragIndex!,
              child: _IconBadge(
                icon: tab.icon,
                isActive: isActive,
                showDragAffordance: profileExpressive,
                trailingIcon: profileExpressive ? null : Icons.drag_handle,
              ),
            ),
      title: Text(
        tab.localizedTitle(strings),
        maxLines: expressive ? null : 1,
        overflow: expressive ? null : TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          color: stateForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        isLocked
            ? strings.navEditorAlwaysShown
            : isActive
            ? strings.navEditorVisible
            : strings.navEditorHidden,
        style: theme.textTheme.bodySmall?.copyWith(
          color:
              stateForeground?.withValues(alpha: 0.76) ??
              scheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
    );

    if (!expressive || trainTokens == null) return tile;
    final surface = profileDestination != null
        ? (isActive
              ? Color.lerp(
                  profileDestination.surfaceSelected,
                  profileDestination.pageCanvas,
                  0.34,
                )!
              : context.surfaceTokens.settingsSection)
        : isActive
        ? trainTokens.navigationSurface
        : context.surfaceTokens.settingsSection;
    final foreground = stateForeground;
    final rowSurface = TonosSurface(
      variant: profileDestination != null && !isActive
          ? TonosSurfaceVariant.panel
          : TonosSurfaceVariant.compactCard,
      color: surface,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      borderRadius: profileExpressive && dragIndex != null
          ? _activeTabBorderRadius(
              dragIndex!,
              outerRadius: context.shapeTokens.sheet.topLeft.x,
              roundTopEdge: isFirstActiveTab,
              roundBottomEdge: isLastActiveTab,
            )
          : null,
      child: foreground == null
          ? tile
          : Theme(
              data: theme.copyWith(
                colorScheme: scheme.copyWith(
                  onSurface: foreground,
                  onSurfaceVariant: foreground.withValues(alpha: 0.76),
                ),
                textTheme: theme.textTheme.apply(
                  bodyColor: foreground,
                  displayColor: foreground,
                ),
                listTileTheme: theme.listTileTheme.copyWith(
                  textColor: foreground,
                  iconColor: foreground,
                ),
              ),
              child: tile,
            ),
    );
    final effects = theme.extension<AppEffectTokens>();
    if (!profileExpressive ||
        !isActive ||
        theme.brightness != Brightness.light ||
        effects == null) {
      return rowSurface;
    }

    return Theme(
      data: theme.copyWith(
        extensions: theme.extensions.values.map((extension) {
          if (extension is! AppEffectTokens) return extension;
          return extension.copyWith(
            cardShadow: extension.cardShadow.withValues(
              alpha: extension.cardShadow.a * 0.86,
            ),
            cardShadowBlur: extension.cardShadowBlur * 0.9,
          );
        }),
      ),
      child: rowSurface,
    );
  }
}

class _RequiredTabIndicator extends StatelessWidget {
  const _RequiredTabIndicator({required this.tokens});

  final AppExpressiveDestinationTokens tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requiredLabel = AppLocalizations.of(context).navEditorRequired;
    return Semantics(
      container: true,
      label: requiredLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: Color.lerp(tokens.surfaceSelected, tokens.pageCanvas, 0.36),
            borderRadius: context.shapeTokens.pill,
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 14, color: tokens.outlineAccent),
              const SizedBox(width: 4),
              Text(
                requiredLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.supportingForeground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool showDragAffordance;
  final IconData? trailingIcon;

  const _IconBadge({
    required this.icon,
    required this.isActive,
    this.showDragAffordance = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shapes = context.shapeTokens;
    final expressive = context.usesExpressivePresentation;
    final trainTokens = Theme.of(context).extension<AppExpressiveTrainTokens>();
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final profileDestination =
        destination?.family == AppExpressiveDestinationFamily.profile
        ? destination
        : null;
    final profileExpressive = expressive && profileDestination != null;
    final badgeColor = expressive && trainTokens != null
        ? trainTokens.navigationSelected
        : scheme.primary;
    final badgeForeground = expressive && trainTokens != null
        ? trainTokens.navigationSelectedForeground
        : scheme.primary;
    final foreground = profileDestination == null
        ? badgeForeground
        : isActive
        ? profileDestination.onSurfaceSelected
        : profileDestination.supportingForeground;
    final badgeSurface = profileDestination == null
        ? badgeColor
        : isActive
        ? profileDestination.surfaceSelected
        : context.surfaceTokens.settingsSection;

    if (!profileExpressive) {
      return SizedBox(
        width: 48,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: expressive && trainTokens != null
                    ? badgeSurface
                    : scheme.primary.withValues(alpha: 0.16),
                borderRadius: expressive
                    ? ExpressiveTrainShapes.focusInset
                    : shapes.settingsAction,
              ),
              child: Icon(icon, color: foreground, size: 22),
            ),
            if (trailingIcon != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  trailingIcon!,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: showDragAffordance ? 68 : 48,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: expressive && trainTokens != null
                  ? badgeSurface
                  : scheme.primary.withValues(alpha: 0.16),
              borderRadius: expressive
                  ? ExpressiveTrainShapes.focusInset
                  : shapes.settingsAction,
            ),
            child: Icon(icon, color: foreground, size: 22),
          ),
          if (showDragAffordance) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.drag_indicator,
              size: 20,
              color: profileDestination.supportingForeground,
            ),
          ],
        ],
      ),
    );
  }
}

BorderRadius _activeTabBorderRadius(
  int index, {
  required double outerRadius,
  required bool roundTopEdge,
  required bool roundBottomEdge,
}) {
  final roundedLeft = index.isEven ? 24.0 : 12.0;
  final roundedRight = index.isEven ? 12.0 : 24.0;
  return BorderRadius.only(
    topLeft: Radius.circular(roundTopEdge ? outerRadius : roundedLeft),
    bottomLeft: Radius.circular(roundBottomEdge ? outerRadius : roundedLeft),
    topRight: Radius.circular(roundTopEdge ? outerRadius : roundedRight),
    bottomRight: Radius.circular(roundBottomEdge ? outerRadius : roundedRight),
  );
}

bool _sameTabOrder(List<TabItem> first, List<TabItem> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
