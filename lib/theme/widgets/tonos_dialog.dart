import 'package:flutter/material.dart';

import '../theme_extensions.dart';

/// Applies hard depth to the dialog's Material shape, inside route insets.
class TonosDialogFrame extends StatelessWidget {
  const TonosDialogFrame({
    super.key,
    required this.child,
    this.styleFormControls = false,
  });

  final Widget child;

  /// Gives nested text fields a bright Neo control surface instead of letting
  /// the dialog's foreground recipe leak onto a charcoal input.
  final bool styleFormControls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effects = context.effectTokens;
    if (!context.surfaceDecorationTokens.panel.outlined) {
      return child;
    }
    final hasDepth =
        effects.cardShadow.a != 0 && effects.dialogShadowOffset != Offset.zero;
    final dialogSurface =
        theme.dialogTheme.backgroundColor ?? context.surfaceTokens.dialog;
    final foreground = tonosForegroundForSurface(context, dialogSurface);
    final secondaryForeground = tonosSecondaryForegroundForSurface(
      context,
      dialogSurface,
    );
    final dialogButtonForeground = WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.disabled)
              ? foreground.withValues(alpha: 0.38)
              : foreground,
    );
    final formInputTheme =
        styleFormControls
            ? _neoDialogFormInputTheme(context, theme)
            : theme.inputDecorationTheme;
    final dialogTheme =
        hasDepth
            ? theme.dialogTheme.copyWith(
              elevation: 0,
              clipBehavior: Clip.none,
              shape: TonosDialogShadowBorder(
                border:
                    theme.dialogTheme.shape ??
                    RoundedRectangleBorder(
                      borderRadius: context.shapeTokens.sheet,
                    ),
                color: effects.cardShadow,
                offset: effects.dialogShadowOffset,
              ),
            )
            : theme.dialogTheme;
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          onSurface: foreground,
          onSurfaceVariant: secondaryForeground,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: foreground,
          displayColor: foreground,
        ),
        iconTheme: theme.iconTheme.copyWith(color: foreground),
        inputDecorationTheme: formInputTheme,
        listTileTheme: theme.listTileTheme.copyWith(
          textColor: foreground,
          titleTextStyle: (theme.listTileTheme.titleTextStyle ??
                  theme.textTheme.titleMedium)
              ?.copyWith(color: foreground),
          subtitleTextStyle: (theme.listTileTheme.subtitleTextStyle ??
                  theme.textTheme.bodyMedium)
              ?.copyWith(color: secondaryForeground),
          iconColor: foreground,
        ),
        radioTheme: theme.radioTheme.copyWith(
          fillColor: WidgetStatePropertyAll<Color?>(foreground),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: theme.filledButtonTheme.style?.copyWith(
            foregroundColor: dialogButtonForeground,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: theme.elevatedButtonTheme.style?.copyWith(
            foregroundColor: dialogButtonForeground,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: theme.outlinedButtonTheme.style?.copyWith(
            foregroundColor: dialogButtonForeground,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: theme.textButtonTheme.style?.copyWith(
            foregroundColor: dialogButtonForeground,
          ),
        ),
        dialogTheme: dialogTheme.copyWith(
          titleTextStyle: theme.dialogTheme.titleTextStyle?.copyWith(
            color: foreground,
          ),
          contentTextStyle: theme.dialogTheme.contentTextStyle?.copyWith(
            color: foreground,
          ),
        ),
      ),
      child: child,
    );
  }
}

InputDecorationTheme _neoDialogFormInputTheme(
  BuildContext context,
  ThemeData theme,
) {
  final surfaces = context.surfaceTokens;
  final shapes = context.shapeTokens;
  final fieldSurface = surfaces.dialogChoice;
  final fieldForeground = tonosForegroundForSurface(context, fieldSurface);
  final fieldOutline = tonosOutlineForSurface(context, fieldSurface);

  return theme.inputDecorationTheme.copyWith(
    filled: true,
    fillColor: fieldSurface,
    labelStyle: TextStyle(color: fieldForeground.withValues(alpha: 0.78)),
    floatingLabelStyle: TextStyle(color: fieldForeground),
    hintStyle: TextStyle(color: fieldForeground.withValues(alpha: 0.62)),
    suffixStyle: TextStyle(color: fieldForeground),
    enabledBorder: OutlineInputBorder(
      borderRadius: shapes.dialogChoice,
      borderSide: BorderSide(color: fieldOutline, width: shapes.outlineWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: shapes.dialogChoice,
      borderSide: BorderSide(
        color: context.semanticColors.focusRing,
        width: shapes.focusRingWidth,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: shapes.dialogChoice,
      borderSide: BorderSide(
        color: fieldForeground.withValues(alpha: 0.38),
        width: shapes.outlineWidth,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: shapes.dialogChoice,
      borderSide: BorderSide(color: fieldOutline, width: shapes.outlineWidth),
    ),
  );
}

/// Paints only the exposed translated silhouette. Material still owns the
/// original fill, ink clipping, border and layout.
class TonosDialogShadowBorder extends ShapeBorder {
  const TonosDialogShadowBorder({
    required this.border,
    required this.color,
    required this.offset,
  });

  final ShapeBorder border;
  final Color color;
  final Offset offset;

  @override
  EdgeInsetsGeometry get dimensions => border.dimensions;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      border.getOuterPath(rect, textDirection: textDirection);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      border.getInnerPath(rect, textDirection: textDirection);

  Path shadowPath(Rect rect, {TextDirection? textDirection}) {
    final path = getOuterPath(rect, textDirection: textDirection);
    return Path.combine(PathOperation.difference, path.shift(offset), path);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      shadowPath(rect, textDirection: textDirection),
      Paint()..color = color,
    );
    border.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  ShapeBorder scale(double t) => TonosDialogShadowBorder(
    border: border.scale(t),
    color: color,
    offset: offset * t,
  );
}

/// Shares choice colors, selection framing and radios with the preview.
class TonosChoiceDialog<T> extends StatelessWidget {
  const TonosChoiceDialog({
    super.key,
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.subtitle,
    this.choiceKey,
  });

  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final String Function(T) subtitle;
  final Key Function(T)? choiceKey;

  @override
  Widget build(BuildContext context) {
    final neo = context.surfaceDecorationTokens.panel.outlined;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final ink = context.cs.onPrimaryContainer;
    return TonosDialogFrame(
      child: AlertDialog(
        title: Text(title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in values)
              RadioListTile<T>(
                key: choiceKey?.call(value),
                value: value,
                groupValue: selected,
                fillColor: neo ? WidgetStatePropertyAll<Color?>(ink) : null,
                tileColor:
                    neo
                        ? value == selected
                            ? context.cs.primary
                            : surfaces.planGroup
                        : null,
                shape:
                    neo
                        ? RoundedRectangleBorder(
                          borderRadius: shapes.control,
                          side: BorderSide(
                            color: tonosOutlineForSurface(
                              context,
                              value == selected
                                  ? context.cs.primary
                                  : surfaces.planGroup,
                            ),
                            width:
                                value == selected
                                    ? shapes.focusRingWidth
                                    : shapes.outlineWidth,
                          ),
                        )
                        : null,
                title: Text(
                  label(value),
                  style: neo ? TextStyle(color: ink) : null,
                ),
                subtitle: Text(
                  subtitle(value),
                  style: neo ? TextStyle(color: ink) : null,
                ),
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ),
    );
  }
}
