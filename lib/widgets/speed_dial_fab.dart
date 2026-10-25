// File: lib/widgets/speed_dial_fab.dart
// for logging food intake and measurements

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/nutrition_profile.dart';
import '../screens/nutrition/food_logging_page.dart';
import '../screens/nutrition/measured_items_page.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_expressive_navigation_motion.dart';
import '../theme/widgets/tonos_expressive_state_motion.dart';

/// A toggleable FAB that expands into food and measurement actions.
///
/// Pass [onFoodLogged] / [onMeasurementLogged] to react after a successful log.
class SpeedDialFab extends StatefulWidget {
  final Future<void> Function()? onFoodLogged;
  final Future<void> Function()? onMeasurementLogged;
  final String? toggleTooltip;
  final double actionWidth;

  const SpeedDialFab({
    super.key,
    this.onFoodLogged,
    this.onMeasurementLogged,
    this.toggleTooltip,
    this.actionWidth = 160,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab> {
  bool _open = false;
  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) => !context.usesExpressivePresentation
      ? _buildDial(context)
      : LayoutBuilder(
          builder: (context, constraints) => _buildDial(context, constraints),
        );

  Widget _buildDial(BuildContext context, [BoxConstraints? constraints]) {
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final active = TickerMode.valuesOf(context).enabled;
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final actionTextStyle = TextStyle(
      fontFamily: theme.textTheme.titleMedium?.fontFamily,
      fontSize: theme.textTheme.titleMedium?.fontSize ?? 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    var actionWidth = widget.actionWidth;
    var actionHeight = 60.0;
    final labelWidths = <String, double>{};
    if (expressive) {
      final painters = {
        for (final label in [
          strings.speedDialLogFood,
          strings.speedDialLogMeasurement,
        ])
          label: TextPainter(
            text: TextSpan(text: label, style: actionTextStyle),
            textDirection: Directionality.of(context),
            textScaler: textScaler,
            maxLines: 2,
          )..layout(),
      };
      actionWidth = math.min(
        math.max(
          0,
          math.min(MediaQuery.sizeOf(context).width, constraints!.maxWidth) -
              32,
        ),
        math.max(
          actionWidth,
          painters.values.map((p) => p.width + 72).reduce(math.max),
        ),
      );
      for (final entry in painters.entries) {
        final painter = entry.value;
        painter.layout(maxWidth: math.max(1, actionWidth - 72));
        labelWidths[entry.key] = painter.width;
        actionHeight = math.max(actionHeight, painter.height + 24);
        painter.dispose();
      }
    }
    Widget actionLabel(String label) => !expressive
        ? Text(label)
        : SizedBox(
            width: labelWidths[label],
            child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          );

    final toggle = FloatingActionButton(
      heroTag: 'toggle',
      tooltip: expressive
          ? _open
                ? strings.commonClose
                : widget.toggleTooltip ?? strings.nutritionAddEntryActionLabel
          : widget.toggleTooltip,
      onPressed: _toggle,
      child: AnimatedRotation(
        turns: _open ? 0.125 : 0,
        duration: expressive
            ? TonosExpressiveStateMotion.duration(
                context,
                TonosExpressiveStateMotion.fast,
              )
            : appMotionDuration(context, context.motionTokens.standard),
        child: const Icon(Icons.add),
      ),
    );
    final options = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'log_food',
          icon: const Icon(Icons.restaurant),
          label: actionLabel(strings.speedDialLogFood),
          onPressed: () async {
            _toggle();
            final profile = context.read<NutritionProfile>();
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<NutritionProfile>.value(
                  value: profile,
                  child: const FoodLoggingPage(),
                ),
              ),
            );
            if (!mounted) return;
            if (changed == true) {
              await widget.onFoodLogged?.call();
            }
          },
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'log_measurement',
          icon: const Icon(Icons.straighten),
          label: actionLabel(strings.speedDialLogMeasurement),
          onPressed: () async {
            _toggle();
            final profile = context.read<NutritionProfile>();
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<NutritionProfile>.value(
                  value: profile,
                  child: const MeasuredItemsPage(),
                ),
              ),
            );
            if (!mounted) return;
            if (changed == true) {
              await widget.onMeasurementLogged?.call();
            }
          },
        ),
        const SizedBox(height: 8),
      ],
    );
    Widget buildDial({double? availableHeight}) {
      final optionsHeight = actionHeight * 2 + 16;
      final maxOptionsHeight = availableHeight == null
          ? optionsHeight
          : math.max(0.0, availableHeight - 56);
      return SizedBox(
        width: actionWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TonosExpressiveActionVisibility(
              visible: _open,
              animateSize: false,
              child: maxOptionsHeight >= optionsHeight
                  ? options
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxOptionsHeight),
                      child: SingleChildScrollView(
                        primary: false,
                        child: options,
                      ),
                    ),
            ),
            expressive
                ? MergeSemantics(
                    child: Semantics(expanded: _open, child: toggle),
                  )
                : toggle,
          ],
        ),
      );
    }

    double? availableHeight;
    if (expressive) {
      final scaffold = Scaffold.maybeOf(context);
      // The FAB slot strips padding. Read the owning page's insets,
      // while using its local constraints (which exclude parent nav).
      final media = MediaQuery.of(scaffold?.context ?? context);
      availableHeight = math.max(
        56,
        constraints!.maxHeight -
            media.viewInsets.bottom -
            media.viewPadding.vertical -
            32,
      );
    }
    final dial = buildDial(availableHeight: availableHeight);
    return !expressive
        ? dial
        : PopScope<Object?>(
            canPop: !_open || !active,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && _open && active) _toggle();
            },
            child: Theme(
              data: theme.copyWith(
                floatingActionButtonTheme: theme.floatingActionButtonTheme
                    .copyWith(
                      extendedSizeConstraints: BoxConstraints.tightFor(
                        height: actionHeight,
                      ),
                      extendedPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      extendedTextStyle: actionTextStyle,
                    ),
              ),
              child: dial,
            ),
          );
  }
}
