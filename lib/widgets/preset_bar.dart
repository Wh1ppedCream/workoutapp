// File: lib/widgets/preset_bar.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../repositories/app_repository.dart';
import '../providers/active_session.dart';
import '../providers/preset_session.dart';
import '../screens/exercise/preset_detail_screen.dart';
import 'body_heatmap.dart';
import 'generic_bar.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_dialog.dart';
import '../theme/widgets/workout_thumbnail_frame.dart';

/// A colored bar that *knows* how to open, rename, & delete its own preset.
class PresetBar extends StatelessWidget {
  final int presetId;
  final String label;
  final Color color;
  final int index;
  final bool isAutomatic;
  final Map<String, double> focusFrequencyMap;
  final VoidCallback onRefresh;
  final bool? isActivePlan;
  final Future<void> Function(bool active)? onSetActivePlan;

  /// Uniform scale factor for padding, font sizes, badge sizes, etc.
  final double scale;
  final bool useExpressiveTrainPresentation;
  final bool expressiveMotionEnabled;

  const PresetBar({
    super.key,
    required this.presetId,
    required this.label,
    required this.color,
    required this.index,
    this.isAutomatic = false,
    this.focusFrequencyMap = const <String, double>{},
    this.isActivePlan,
    this.onSetActivePlan,
    required this.onRefresh,
    this.scale = 1.0,
    this.useExpressiveTrainPresentation = false,
    this.expressiveMotionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = label.trim().isNotEmpty
        ? _planDisplayText(label)
        : strings.planDefaultName(index + 1);
    // pull theme defaults if needed (but we'll still use the passed‐in color)
    final accent = color;
    final usesInkRecipe = context.usesNeoPresentation;
    final trailingColor = usesInkRecipe
        ? context.cs.onPrimaryContainer
        : accent;

    if (useExpressiveTrainPresentation && context.usesExpressivePresentation) {
      return _buildExpressiveCard(
        context: context,
        title: title,
        accent: accent,
        strings: strings,
      );
    }

    return GenericBar(
      label: title,
      // use the same color as before, but via the themed accent slot
      color: accent,
      fillColor: context.surfaceTokens.planCard,
      foregroundColor: context.cs.onPrimaryContainer,
      markerColor: accent,
      onTap: () => _openDetail(context),
      scale: scale, // <-- pass down scale
      leading: _PresetFocusBadge(frequencyMap: focusFrequencyMap, scale: scale),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAutomatic) _AutomaticBadge(scale: scale),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: trailingColor,
              size: 24 * scale, // scale the icon
            ),
            onSelected: (action) => _handleMenu(context, action),
            itemBuilder: (_) => [
              if (isActivePlan != null)
                PopupMenuItem(
                  value: isActivePlan! ? 'archive' : 'activate',
                  child: Text(
                    isActivePlan! ? strings.planArchive : strings.planActivate,
                  ),
                ),
              PopupMenuItem(value: 'delete', child: Text(strings.commonDelete)),
              PopupMenuItem(value: 'rename', child: Text(strings.commonRename)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpressiveCard({
    required BuildContext context,
    required String title,
    required Color accent,
    required AppLocalizations strings,
  }) {
    final theme = Theme.of(context);
    final isActive = isActivePlan ?? true;
    final neutralContainer = theme.colorScheme.surfaceContainerLow;
    final cardFill = Color.alphaBlend(
      accent.withValues(alpha: isActive ? 0.16 : 0.13),
      neutralContainer,
    );
    final menuFill = theme.colorScheme.surfaceContainerHigh;
    final textColor = theme.colorScheme.onSurface;
    final scaleFactor = scale;
    final radius = index.isEven
        ? ExpressiveTrainShapes.planRow
        : ExpressiveTrainShapes.planRowAlternate;
    final inset = 5 * scaleFactor;
    final rowShape = RoundedRectangleBorder(borderRadius: radius);
    final effects = context.effectTokens;
    final shadows = effects.cardShadowBlur > 0 && effects.cardShadow.a > 0
        ? <BoxShadow>[
            BoxShadow(
              color: effects.cardShadow,
              blurRadius: effects.cardShadowBlur,
              offset: effects.cardShadowOffset,
            ),
          ]
        : const <BoxShadow>[];
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';

    // Keep the diagram on a neutral media surface with a low-chroma plan tint.
    // It stays below either plan-row wash (13% or 16%), so the fixed heatmap
    // colors remain the visual owner of the data.
    final heatmapBackground = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      context.surfaceTokens.mediaPlaceholder,
    );
    final card = TonosExpressivePressResponse(
      enabled: expressiveMotionEnabled,
      borderRadius: radius,
      pressedBorderRadius: ExpressiveTrainShapes.planRowPressed,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      child: Material(
        key: ValueKey<String>('expressive-plan-card-$presetId'),
        color: cardFill,
        shape: rowShape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetail(context),
          customBorder: rowShape,
          child: DecoratedBox(
            decoration: ShapeDecoration(shape: rowShape, shadows: shadows),
            child: Padding(
              padding: EdgeInsets.all(5 * scaleFactor),
              child: Row(
                children: [
                  Container(
                    key: ValueKey<String>('expressive-plan-identity-$presetId'),
                    width: 72 * scaleFactor,
                    height: 70 * scaleFactor,
                    padding: EdgeInsets.all(inset),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: radius,
                    ),
                    child: Center(
                      child: _PresetFocusBadge(
                        frequencyMap: focusFrequencyMap,
                        scale: scaleFactor * 0.9,
                        backgroundColor: heatmapBackground,
                        frameKey: ValueKey<String>(
                          'expressive-plan-heatmap-frame-$presetId',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scaleFactor),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: usesLocalizedLayout ? 2 : 1,
                      overflow: usesLocalizedLayout
                          ? TextOverflow.ellipsis
                          : TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isAutomatic) _AutomaticBadge(scale: scaleFactor),
                  SizedBox(width: 2 * scaleFactor),
                  TonosExpressivePressResponse(
                    enabled: expressiveMotionEnabled,
                    borderRadius: ExpressiveTrainShapes.compactControl,
                    pressedBorderRadius:
                        ExpressiveTrainShapes.compactControlPressed,
                    pressedScale: TonosExpressiveMotionTiers.compactScale,
                    pressedOffset: TonosExpressiveMotionTiers.compactOffset,
                    pressedRotation: TonosExpressiveMotionTiers.compactRotation,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: ExpressiveTrainShapes.menu,
                      ),
                      color: menuFill,
                      iconColor: theme.colorScheme.onSurface,
                      icon: Container(
                        key: ValueKey<String>(
                          'expressive-plan-menu-bubble-$presetId',
                        ),
                        width: 38 * scaleFactor,
                        height: 38 * scaleFactor,
                        decoration: BoxDecoration(
                          color: menuFill,
                          borderRadius: ExpressiveTrainShapes.compactControl,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.more_horiz,
                          color: textColor,
                          size: 22 * scaleFactor,
                        ),
                      ),
                      onSelected: (action) => _handleMenu(context, action),
                      itemBuilder: (_) => [
                        if (isActivePlan != null)
                          PopupMenuItem(
                            value: isActivePlan! ? 'archive' : 'activate',
                            child: Text(
                              isActivePlan!
                                  ? strings.planArchive
                                  : strings.planActivate,
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(strings.commonDelete),
                        ),
                        PopupMenuItem(
                          value: 'rename',
                          child: Text(strings.commonRename),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return TonosExpressiveReveal(
      key: ValueKey<String>('expressive-plan-$presetId'),
      staggerIndex: index % 5,
      enabled: expressiveMotionEnabled,
      child: card,
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(
              value: ctx.read<ActiveSession>(),
            ),
            ChangeNotifierProvider(
              create: (context) => PresetSession(
                presetId,
                repository: context.read<AppRepository>(),
              ),
            ),
          ],
          child: const PresetDetailScreen(),
        ),
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    final strings = AppLocalizations.of(context);
    if (action == 'activate' || action == 'archive') {
      final active = action == 'activate';
      await onSetActivePlan?.call(active);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(active ? strings.planActivated : strings.planArchived),
        ),
      );
    } else if (action == 'delete') {
      final repo = context.read<AppRepository>();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dCtx) => TonosDialogFrame(
          child: AlertDialog(
            title: Text(strings.planDeleteTitle),
            content: Text(strings.planDeleteConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx, false),
                child: Text(strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dCtx, true),
                child: Text(strings.commonDelete),
              ),
            ],
          ),
        ),
      );
      if (!context.mounted) return;
      if (confirm == true) {
        await repo.deletePreset(presetId);
        onRefresh();
      }
    } else if (action == 'rename') {
      final repo = context.read<AppRepository>();
      final newName = await showDialog<String>(
        context: context,
        builder: (_) => TonosDialogFrame(
          styleFormControls: true,
          child: _PresetRenameDialog(initialName: _planDisplayText(label)),
        ),
      );
      if (!context.mounted) return;
      if (newName != null && newName.isNotEmpty && newName != label) {
        await repo.updatePresetName(presetId, newName);
        onRefresh();
      }
    }
  }
}

class _PresetRenameDialog extends StatefulWidget {
  const _PresetRenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_PresetRenameDialog> createState() => _PresetRenameDialogState();
}

class _PresetRenameDialogState extends State<_PresetRenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(strings.planRenameTitle),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: strings.planNameLabel),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(strings.commonRename),
        ),
      ],
    );
  }
}

String _planDisplayText(String value) {
  return value
      .replaceAll(RegExp(r'\bPresets\b'), 'Plans')
      .replaceAll(RegExp(r'\bPreset\b'), 'Plan')
      .replaceAll(RegExp(r'\bpresets\b'), 'plans')
      .replaceAll(RegExp(r'\bpreset\b'), 'plan');
}

class _PresetFocusBadge extends StatelessWidget {
  final Map<String, double> frequencyMap;
  final double scale;
  final Color? backgroundColor;
  final Key? frameKey;

  const _PresetFocusBadge({
    required this.frequencyMap,
    required this.scale,
    this.backgroundColor,
    this.frameKey,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final heatmapBackground = backgroundColor ?? surfaces.mediaPlaceholder;
    final size = 60 * scale;

    return WorkoutThumbnailFrame(
      key: frameKey,
      scale: scale,
      backgroundColor: backgroundColor,
      child: BodyHeatmap(
        frequencyMap: frequencyMap,
        lowColor: tonosHeatmapLowForSurface(context, heatmapBackground),
        highColor: tonosHeatmapHighForSurface(context, heatmapBackground),
        width: size - 6 * scale,
        height: size - 6 * scale,
      ),
    );
  }
}

class _AutomaticBadge extends StatelessWidget {
  final double scale;
  const _AutomaticBadge({required this.scale});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Padding(
      padding: EdgeInsets.only(right: 8 * scale),
      child: CircleAvatar(
        radius: 8 * scale,
        backgroundColor: semantic.automaticPlanBadge,
        child: Text(
          'A',
          style: TextStyle(
            fontSize: 12 * scale,
            color: semantic.onAutomaticPlanBadge,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
