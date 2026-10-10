import 'package:material_ui/material_ui.dart';

import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../widgets/settings_tiles.dart';

enum AnalyticsSurfaceRole { primary, secondary, tertiary, accent, selected }

AppExpressiveDestinationTokens? analyticsDestinationTokens(
  BuildContext context,
) {
  final theme = Theme.of(context);
  if (theme.appThemeFamilyIdentity !=
      AppThemeFamilyIdentity.expressivePreview) {
    return null;
  }
  return theme.extension<AppExpressiveDestinationTokens>() ??
      AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.analytics,
        theme.brightness,
      );
}

Color analyticsSurfaceColor(
  AppExpressiveDestinationTokens tokens,
  AnalyticsSurfaceRole role,
) => switch (role) {
  AnalyticsSurfaceRole.primary => tokens.surfacePrimary,
  AnalyticsSurfaceRole.secondary => tokens.surfaceSecondary,
  AnalyticsSurfaceRole.tertiary => tokens.surfaceTertiary,
  AnalyticsSurfaceRole.accent => tokens.surfaceAccent,
  AnalyticsSurfaceRole.selected => tokens.surfaceSelected,
};

Color analyticsForegroundColor(
  AppExpressiveDestinationTokens tokens,
  AnalyticsSurfaceRole role,
) => switch (role) {
  AnalyticsSurfaceRole.primary => tokens.onSurfacePrimary,
  AnalyticsSurfaceRole.secondary => tokens.onSurfaceSecondary,
  AnalyticsSurfaceRole.tertiary => tokens.onSurfaceTertiary,
  AnalyticsSurfaceRole.accent => tokens.onSurfaceAccent,
  AnalyticsSurfaceRole.selected => tokens.onSurfaceSelected,
};

class AnalyticsZone extends StatelessWidget {
  const AnalyticsZone({
    super.key,
    required this.role,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.shape,
    this.outlined = false,
  });

  final AnalyticsSurfaceRole role;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final BorderRadiusGeometry? shape;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final tokens = analyticsDestinationTokens(context);
    if (tokens == null) return child;
    final color = analyticsSurfaceColor(tokens, role);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape ?? BorderRadius.circular(borderRadius),
        border: outlined
            ? Border.all(color: tokens.outlineAccent, width: 1.4)
            : null,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: analyticsForegroundColor(tokens, role)),
        child: IconTheme.merge(
          data: IconThemeData(color: analyticsForegroundColor(tokens, role)),
          child: child,
        ),
      ),
    );
  }
}

class AnalyticsRouteHeader extends StatelessWidget {
  const AnalyticsRouteHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.role = AnalyticsSurfaceRole.primary,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AnalyticsSurfaceRole role;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = analyticsDestinationTokens(context);
    if (tokens == null) {
      return SettingsHeroCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        accentColor: accentColor,
      );
    }
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final stackContent =
        MediaQuery.sizeOf(context).width <= 360 || textScale > 1.15;
    final iconTile = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: analyticsSurfaceColor(tokens, AnalyticsSurfaceRole.accent),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Icon(
        icon,
        color: analyticsForegroundColor(tokens, AnalyticsSurfaceRole.accent),
      ),
    );
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: analyticsForegroundColor(tokens, role),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: analyticsForegroundColor(
              tokens,
              role,
            ).withValues(alpha: 0.86),
          ),
        ),
      ],
    );
    return AnalyticsZone(
      role: role,
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
      borderRadius: 30,
      shape: ExpressiveTrainShapes.focusHero,
      child: stackContent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [iconTile, const SizedBox(height: 14), textContent],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconTile,
                const SizedBox(width: 16),
                Expanded(child: textContent),
              ],
            ),
    );
  }
}

class AnalyticsRankingRow extends StatelessWidget {
  const AnalyticsRankingRow({
    super.key,
    required this.index,
    required this.name,
    required this.rank,
    required this.icon,
    required this.rankLabel,
    required this.onRankSubmitted,
  });

  final int index;
  final Widget name;
  final int rank;
  final IconData icon;
  final String rankLabel;
  final ValueChanged<String> onRankSubmitted;

  @override
  Widget build(BuildContext context) {
    final tokens = analyticsDestinationTokens(context);
    if (tokens == null) {
      return SettingsRankingTile(
        index: index,
        name: name,
        rank: rank,
        icon: icon,
        rankLabel: rankLabel,
        onRankSubmitted: onRankSubmitted,
      );
    }
    final role = switch (index % 3) {
      0 => AnalyticsSurfaceRole.secondary,
      1 => AnalyticsSurfaceRole.tertiary,
      _ => AnalyticsSurfaceRole.accent,
    };
    final foreground = analyticsForegroundColor(tokens, role);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactLayout =
        MediaQuery.sizeOf(context).width <= 360 || textScale > 1.15;
    final rankFieldWidth = (72 * textScale).clamp(72.0, 120.0).toDouble();
    final rankField = SizedBox(
      width: rankFieldWidth,
      child: TextFormField(
        key: ValueKey('rank-$rank'),
        initialValue: rank.toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          labelText: rankLabel,
          isDense: true,
          filled: true,
          fillColor: tokens.pageCanvas.withValues(alpha: 0.58),
          labelStyle: TextStyle(color: foreground.withValues(alpha: 0.8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: tokens.outlineAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: tokens.outlineAccent),
          ),
        ),
        onFieldSubmitted: onRankSubmitted,
      ),
    );
    final leadingContent = Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle, color: foreground),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: tokens.onSurfacePrimary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground),
              child: name,
            ),
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (MediaQuery.sizeOf(context).width - 32)
                  .clamp(0.0, double.infinity)
                  .toDouble();
        return SizedBox(
          width: rowWidth,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: analyticsSurfaceColor(tokens, role),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomRight: const Radius.circular(22),
                bottomLeft: Radius.circular(index.isEven ? 8 : 22),
              ),
            ),
            child: compactLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leadingContent,
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: rankField,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: leadingContent),
                      const SizedBox(width: 8),
                      rankField,
                    ],
                  ),
          ),
        );
      },
    );
  }
}
