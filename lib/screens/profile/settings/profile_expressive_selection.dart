import 'package:material_ui/material_ui.dart';

import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_dialog.dart';

/// Tonos's compact single-choice treatment for Expressive Profile settings.
TonosChoiceOptionStyle profileExpressiveChoiceStyle(BuildContext context) {
  final tokens = AppExpressiveDestinationTokens.forFamily(
    AppExpressiveDestinationFamily.profile,
    Theme.of(context).brightness,
  );
  final selectedSurface = Theme.of(context).brightness == Brightness.dark
      ? Color.lerp(tokens.surfaceSelected, tokens.onSurfaceSelected, 0.08)!
      : tokens.surfaceSelected;

  return TonosChoiceOptionStyle(
    surface: Color.lerp(tokens.surfacePrimary, tokens.surfaceAccent, 0.14)!,
    selectedSurface: selectedSurface,
    foreground: tokens.onSurfacePrimary,
    selectedForeground: tokens.onSurfaceSelected,
    outline: tokens.outlineAccent.withValues(alpha: 0.55),
    selectedOutline: tokens.outlineAccent,
    borderRadius: ExpressiveTrainShapes.focusInset,
    compact: true,
    outlineWidth: 0.75,
    selectedOutlineWidth: 1.5,
  );
}

Future<T?> showProfileExpressiveChoiceDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required T? selected,
  required String Function(T value) label,
  String Function(T value)? subtitle,
  Widget Function(BuildContext context, T value)? labelWidget,
  Key Function(T value)? choiceKey,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.profile,
      child: TonosChoiceDialog<T>(
        title: title,
        values: values,
        selected: selected,
        label: label,
        labelWidget: labelWidget,
        subtitle: subtitle,
        choiceKey: choiceKey,
        optionStyle: profileExpressiveChoiceStyle(dialogContext),
      ),
    ),
  );
}

/// Keeps a settings field's existing non-Expressive control while routing
/// Expressive taps through the shared contained-choice dialog.
class ProfileExpressiveChoiceField<T> extends StatelessWidget {
  const ProfileExpressiveChoiceField({
    super.key,
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.decoration,
    required this.textStyle,
    required this.onChanged,
    required this.nonExpressiveField,
    this.subtitle,
    this.labelWidget,
    this.choiceKey,
  });

  final String title;
  final List<T> values;
  final T? value;
  final String Function(T value) label;
  final String Function(T value)? subtitle;
  final Widget Function(BuildContext context, T value)? labelWidget;
  final Key Function(T value)? choiceKey;
  final InputDecoration decoration;
  final TextStyle? textStyle;
  final ValueChanged<T?>? onChanged;
  final Widget Function() nonExpressiveField;

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) return nonExpressiveField();

    return FormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      enabled: onChanged != null,
      builder: (field) {
        final selected = field.value;
        final selectedLabel = selected == null ? '' : label(selected);
        final fieldBorder =
            decoration.enabledBorder ??
            decoration.border ??
            decoration.focusedBorder;
        final fieldBorderRadius = fieldBorder is OutlineInputBorder
            ? fieldBorder.borderRadius
            : null;

        void openChoice() {
          _openChoice(field, selected);
        }

        return Semantics(
          button: true,
          enabled: onChanged != null,
          label: decoration.labelText,
          value: selectedLabel,
          onTap: onChanged == null ? null : openChoice,
          child: ExcludeSemantics(
            child: InkWell(
              borderRadius: fieldBorderRadius,
              onTap: onChanged == null ? null : openChoice,
              child: InputDecorator(
                decoration: decoration.copyWith(
                  enabled: onChanged != null,
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                isEmpty: selected == null,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DefaultTextStyle.merge(
                    style: textStyle,
                    child: selected == null
                        ? const SizedBox.shrink()
                        : labelWidget?.call(context, selected) ??
                              Text(
                                selectedLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openChoice(FormFieldState<T> field, T? selected) async {
    final result = await showProfileExpressiveChoiceDialog<T>(
      context: field.context,
      title: title,
      values: values,
      selected: selected,
      label: label,
      subtitle: subtitle,
      labelWidget: labelWidget,
      choiceKey: choiceKey,
    );
    if (result == null || !field.mounted) return;
    field.didChange(result);
    onChanged?.call(result);
  }
}

/// Retains a dropdown-like trigger while using the shared Expressive dialog.
class ProfileExpressiveChoiceButton<T> extends StatelessWidget {
  const ProfileExpressiveChoiceButton({
    super.key,
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.onChanged,
    required this.nonExpressiveButton,
    this.subtitle,
  });

  final String title;
  final List<T> values;
  final T value;
  final String Function(T value) label;
  final String Function(T value)? subtitle;
  final ValueChanged<T?>? onChanged;
  final Widget Function() nonExpressiveButton;

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) return nonExpressiveButton();

    return Semantics(
      button: true,
      enabled: onChanged != null,
      label: title,
      value: label(value),
      onTap: onChanged == null ? null : () => _open(context),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onChanged == null ? null : () => _open(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await showProfileExpressiveChoiceDialog<T>(
      context: context,
      title: title,
      values: values,
      selected: value,
      label: label,
      subtitle: subtitle,
    );
    if (result != null && context.mounted) onChanged?.call(result);
  }
}
