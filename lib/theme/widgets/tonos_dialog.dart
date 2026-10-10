import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';
import '../tokens/app_shape_tokens.dart';
import '../tokens/app_surface_tokens.dart';

/// Applies hard depth to the dialog's Material shape, inside route insets.
class TonosDialogFrame extends StatelessWidget {
  const TonosDialogFrame({
    super.key,
    required this.child,
    this.styleFormControls = false,
    this.styleDarkNeoPickerSurfaces = false,
  });

  final Widget child;

  /// Gives nested text fields a bright Neo control surface instead of letting
  /// the dialog's foreground recipe leak onto a charcoal input.
  final bool styleFormControls;

  /// Gives nested popup, date-picker, and time-picker routes a surface that
  /// pairs with the dark Neo dialog foreground. Callers opt in per flow.
  final bool styleDarkNeoPickerSurfaces;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effects = context.effectTokens;
    if (!context.usesNeoPresentation) {
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
    final needsDarkNeoPickerContrast =
        styleDarkNeoPickerSurfaces && theme.brightness == Brightness.dark;
    // Picker and popup routes capture this theme, so give them the same
    // readable surface/foreground pairing as the dialog itself.
    final pickerSurface = needsDarkNeoPickerContrast ? dialogSurface : null;
    final formButtonBackground = needsDarkNeoPickerContrast && styleFormControls
        ? WidgetStatePropertyAll<Color?>(context.surfaceTokens.dialogChoice)
        : null;
    final dialogButtonForeground = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled)
          ? foreground.withValues(alpha: 0.38)
          : foreground,
    );
    final outlinedButtonStyle = theme.outlinedButtonTheme.style?.copyWith(
      foregroundColor: dialogButtonForeground,
      backgroundColor: formButtonBackground,
    );
    final formInputTheme = styleFormControls
        ? _neoDialogFormInputTheme(context, theme)
        : theme.inputDecorationTheme;
    final dialogTheme = hasDepth
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
          surface: pickerSurface,
          surfaceDim: pickerSurface,
          surfaceBright: pickerSurface,
          surfaceContainerLowest: pickerSurface,
          surfaceContainerLow: pickerSurface,
          surfaceContainer: pickerSurface,
          surfaceContainerHigh: pickerSurface,
          surfaceContainerHighest: pickerSurface,
          onSurface: foreground,
          onSurfaceVariant: secondaryForeground,
        ),
        canvasColor: pickerSurface,
        popupMenuTheme: theme.popupMenuTheme.copyWith(color: pickerSurface),
        textTheme: theme.textTheme.apply(
          bodyColor: foreground,
          displayColor: foreground,
        ),
        iconTheme: theme.iconTheme.copyWith(color: foreground),
        inputDecorationTheme: formInputTheme,
        listTileTheme: theme.listTileTheme.copyWith(
          textColor: foreground,
          titleTextStyle:
              (theme.listTileTheme.titleTextStyle ??
                      theme.textTheme.titleMedium)
                  ?.copyWith(color: foreground),
          subtitleTextStyle:
              (theme.listTileTheme.subtitleTextStyle ??
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
          style: outlinedButtonStyle,
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

/// Applies the dialog's surface and readable foreground to dropdown controls.
///
/// Use inside [TonosDialogFrame] so Neo popup routes inherit the same contrast
/// recipe as the dialog. Classic and generic Material keep their defaults.
class TonosDialogDropdownButton<T> extends StatelessWidget {
  const TonosDialogDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usesNeoDialog = context.usesNeoPresentation;
    final dialogSurface =
        theme.dialogTheme.backgroundColor ?? context.surfaceTokens.dialog;
    final foreground = usesNeoDialog
        ? tonosForegroundForSurface(context, dialogSurface)
        : null;

    return DropdownButton<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: isExpanded,
      style: foreground == null ? null : TextStyle(color: foreground),
      dropdownColor: usesNeoDialog ? dialogSurface : null,
      iconEnabledColor: foreground,
    );
  }
}

InputDecorationThemeData _neoDialogFormInputTheme(
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
@immutable
class TonosChoiceOptionStyle {
  const TonosChoiceOptionStyle({
    required this.surface,
    required this.selectedSurface,
    required this.foreground,
    required this.selectedForeground,
    required this.outline,
    required this.selectedOutline,
    required this.borderRadius,
    this.compact = false,
    this.outlineWidth = 1,
    this.selectedOutlineWidth = 2,
  });

  final Color surface;
  final Color selectedSurface;
  final Color foreground;
  final Color selectedForeground;
  final Color outline;
  final Color selectedOutline;
  final BorderRadius borderRadius;
  final bool compact;
  final double outlineWidth;
  final double selectedOutlineWidth;
}

class TonosChoiceDialog<T> extends StatelessWidget {
  const TonosChoiceDialog({
    super.key,
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    this.subtitle,
    this.labelWidget,
    this.choiceKey,
    this.choicePreview,
    this.optionStyle,
  });

  final String title;
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final String Function(T)? subtitle;
  final Widget Function(BuildContext context, T value)? labelWidget;
  final Key Function(T)? choiceKey;
  final Widget Function(T)? choicePreview;
  final TonosChoiceOptionStyle? optionStyle;

  @override
  Widget build(BuildContext context) {
    final neo = context.usesNeoPresentation;
    final style = optionStyle;
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
              Padding(
                padding: EdgeInsets.only(
                  bottom: style?.compact == true ? 5 : 0,
                ),
                child: _buildChoice(context, value, neo, surfaces, shapes, ink),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(
    BuildContext context,
    T value,
    bool neo,
    AppSurfaceTokens surfaces,
    AppShapeTokens shapes,
    Color ink,
  ) {
    final isSelected = value == selected;
    final style = optionStyle;
    final shape = style == null
        ? null
        : RoundedRectangleBorder(
            borderRadius: style.borderRadius,
            side: BorderSide(
              color: isSelected ? style.selectedOutline : style.outline,
              width: isSelected
                  ? style.selectedOutlineWidth
                  : style.outlineWidth,
            ),
          );
    final foreground = isSelected
        ? style?.selectedForeground
        : style?.foreground;

    final tile = RadioListTile<T>(
      key: choiceKey?.call(value),
      value: value,
      groupValue: selected,
      selected: style != null && isSelected,
      dense: style?.compact ?? false,
      visualDensity: style?.compact == true ? VisualDensity.compact : null,
      contentPadding: style?.compact == true
          ? const EdgeInsets.symmetric(horizontal: 10)
          : null,
      minVerticalPadding: style?.compact == true ? 2.5 : null,
      fillColor: style == null
          ? (neo ? WidgetStatePropertyAll<Color?>(ink) : null)
          : WidgetStatePropertyAll<Color?>(foreground),
      tileColor: neo
          ? isSelected
                ? context.cs.primary
                : surfaces.planGroup
          : style?.surface,
      selectedTileColor: style?.selectedSurface,
      shape: neo
          ? RoundedRectangleBorder(
              borderRadius: shapes.control,
              side: BorderSide(
                color: tonosOutlineForSurface(
                  context,
                  isSelected ? context.cs.primary : surfaces.planGroup,
                ),
                width: isSelected ? shapes.focusRingWidth : shapes.outlineWidth,
              ),
            )
          : shape,
      title: labelWidget == null
          ? Text(
              label(value),
              style: neo
                  ? TextStyle(color: ink)
                  : style == null
                  ? null
                  : TextStyle(
                      color: foreground,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
            )
          : DefaultTextStyle.merge(
              style: TextStyle(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: labelWidget!(context, value),
            ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!(value),
              style: neo
                  ? TextStyle(color: ink)
                  : style == null
                  ? null
                  : TextStyle(color: foreground!.withValues(alpha: 0.78)),
            ),
      secondary: choicePreview?.call(value),
      onChanged: (value) => Navigator.of(context).pop(value),
    );
    return style?.compact == true
        ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: tile,
          )
        : tile;
  }
}
