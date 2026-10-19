// File: lib/widgets/meal_plan_add_bar.dart

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../screens/nutrition/pantry_log_page.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/plan_meal_page.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_segmented_action_bar.dart';

class MealPlanAddBar extends StatelessWidget {
  /// Scale factor for all dimensions (padding, radius, divider thickness).
  final double scale;

  const MealPlanAddBar({super.key, this.scale = 0.8});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.nutritionTokens;
    final labelStyle = Theme.of(context).textTheme.bodyMedium;

    final items = [
      TonosActionBarItem(
        label: 'Pantry Log',
        semanticLabel: 'Pantry Log',
        backgroundColor: nutrition.pantryLogSurface,
        foregroundColor: tonosForegroundForSurface(
          context,
          nutrition.pantryLogSurface,
        ),
        labelStyle: labelStyle,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PantryLogPage()));
        },
      ),
      TonosActionBarItem(
        label: 'Add Meal',
        semanticLabel: 'Add Meal',
        backgroundColor: nutrition.addMealSurface,
        foregroundColor: tonosForegroundForSurface(
          context,
          nutrition.addMealSurface,
        ),
        labelStyle: labelStyle,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const FoodLoggingPage()));
        },
      ),
      TonosActionBarItem(
        label: 'Plan Meal',
        semanticLabel: 'Plan Meal',
        backgroundColor: nutrition.planMealSurface,
        foregroundColor: tonosForegroundForSurface(
          context,
          nutrition.planMealSurface,
        ),
        labelStyle: labelStyle,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PlanMealPage()));
        },
      ),
    ];
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    if (context.usesExpressivePresentation &&
        destination?.family == AppExpressiveDestinationFamily.nutrition) {
      return _expressiveActions(context, destination!, items);
    }
    return TonosSegmentedActionBar(
      scale: scale,
      dividerColor: context.surfaceTokens.divider,
      items: items,
    );
  }

  Widget _expressiveActions(
    BuildContext context,
    AppExpressiveDestinationTokens tokens,
    List<TonosActionBarItem> items,
  ) => Padding(
    padding: EdgeInsets.only(top: 10 * scale),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final strings = AppLocalizations.of(context);
        final dark = Theme.of(context).brightness == Brightness.dark;
        final labels = [
          strings.nutritionPantryLogAction,
          strings.nutritionAddMealAction,
          strings.nutritionPlanMealAction,
        ];
        final stacked =
            constraints.maxWidth < 280 * scale ||
            MediaQuery.textScalerOf(context).scale(14) > 19.6;
        final shape = BorderRadius.lerp(
          BorderRadius.zero,
          ExpressiveTrainShapes.primaryAction,
          scale,
        )!;
        BorderRadius segmentShape(int index, {bool pressed = false}) {
          final radius = Radius.circular(14 * scale);
          if (index == 1) {
            return pressed ? BorderRadius.all(radius) : shape;
          }
          final corners = pressed ? BorderRadius.all(radius) : shape;
          if (stacked) {
            return BorderRadius.only(
              topLeft: index == 0 ? corners.topLeft : Radius.zero,
              topRight: index == 0 ? corners.topRight : Radius.zero,
              bottomLeft: index == 2 ? corners.bottomLeft : Radius.zero,
              bottomRight: index == 2 ? corners.bottomRight : Radius.zero,
            );
          }
          final first = Directionality.of(context) == TextDirection.ltr ? 0 : 2;
          return BorderRadius.only(
            topLeft: index == first ? corners.topLeft : Radius.zero,
            bottomLeft: index == first ? corners.bottomLeft : Radius.zero,
            topRight: index == 2 - first ? corners.topRight : Radius.zero,
            bottomRight: index == 2 - first ? corners.bottomRight : Radius.zero,
          );
        }

        Color actionSurface(int index) {
          final surface = switch (index) {
            0 => tokens.surfaceTertiary,
            1 => tokens.actionPrimary,
            _ => tokens.surfaceAccent,
          };
          return index == 1
              ? surface
              : Color.lerp(surface, tokens.pageCanvas, dark ? 0.2 : 0.42)!;
        }

        Color actionForeground(int index) {
          final foreground = switch (index) {
            0 => tokens.onSurfaceTertiary,
            1 => tokens.onActionPrimary,
            _ => tokens.onSurfaceAccent,
          };
          return index == 1
              ? foreground
              : Color.lerp(foreground, tokens.pageCanvas, dark ? 0.12 : 0.1)!;
        }

        Widget action(int index) {
          final primary = index == 1;
          final surface = actionSurface(index);
          final ink = actionForeground(index);
          final item = items[index];
          final label = Text(labels[index], textAlign: TextAlign.center);
          final visual = Semantics(
            key: ValueKey('nutrition-action-$index'),
            button: true,
            enabled: primary,
            child: Material(
              color: surface,
              child: InkWell(
                onTap: primary ? item.onPressed : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 64 * scale),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 10 * scale,
                    ),
                    child: DefaultTextStyle(
                      style:
                          (Theme.of(context).textTheme.labelLarge ??
                                  const TextStyle())
                              .copyWith(
                                color: ink,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                      child: primary
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 20 * scale,
                                  color: ink,
                                ),
                                SizedBox(width: 4 * scale),
                                Flexible(child: label),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                label,
                                SizedBox(height: 4 * scale),
                                Text(
                                  strings.nutritionActionUnavailable,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final response = TonosExpressivePressResponse(
            enabled: primary,
            allowReleaseOvershoot: false,
            borderRadius: segmentShape(index),
            pressedBorderRadius: segmentShape(index, pressed: true),
            pressedScale: primary
                ? TonosExpressiveMotionTiers.focalScale
                : TonosExpressiveMotionTiers.supportingScale,
            pressedOffset: primary
                ? TonosExpressiveMotionTiers.focalOffset
                : TonosExpressiveMotionTiers.supportingOffset,
            child: Tooltip(
              message: primary
                  ? labels[index]
                  : strings.nutritionActionUnavailableHint(labels[index]),
              child: visual,
            ),
          );
          if (!primary) return response;
          return Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ColoredBox(color: actionSurface(0))),
                    Expanded(child: ColoredBox(color: actionSurface(2))),
                  ],
                ),
              ),
              response,
            ],
          );
        }

        final dividerColor = Theme.of(context).colorScheme.outline.withValues(
          alpha: context.surfaceTokens.splitWorkoutDividerOpacity,
        );
        Widget bar(Widget child) => DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: shape,
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: dark ? 0.42 : 0.3),
            ),
          ),
          child: Material(
            key: const ValueKey('nutrition-action-bar-material'),
            color: tokens.pageCanvas,
            elevation: context.effectTokens.sheetElevation <= 0 ? 0 : 2 * scale,
            borderRadius: shape,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        );
        if (stacked) {
          return bar(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) Container(height: 1, color: dividerColor),
                  action(index),
                ],
              ],
            ),
          );
        }
        return bar(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) Container(width: 1, color: dividerColor),
                  Expanded(child: action(index)),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
