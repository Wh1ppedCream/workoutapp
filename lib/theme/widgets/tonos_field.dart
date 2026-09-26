import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Semantic field recipes. Visual styling remains owned by the active
/// Material input theme.
enum TonosFieldVariant { standard, search }

/// A small field boundary that keeps feature code independent of decoration
/// details while leaving visual ownership to the active Material input theme.
class TonosField extends StatelessWidget {
  const TonosField({
    super.key,
    this.variant = TonosFieldVariant.standard,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.border,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
  });

  final TonosFieldVariant variant;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final TextAlign textAlign;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final decoration = _tonosInputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      border: border,
      contentPadding: contentPadding,
      prefixIcon:
          prefixIcon ??
          (variant == TonosFieldVariant.search
              ? const Icon(Icons.search)
              : null),
      suffixIcon: suffixIcon,
    );
    Widget field = TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      textAlign: textAlign,
    );
    if (semanticLabel != null) {
      field = Semantics(label: semanticLabel, child: field);
    }
    return field;
  }
}

/// A themed form field that retains Material form validation and save behavior.
class TonosFormField extends StatelessWidget {
  const TonosFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.border,
    this.isDense = false,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onTapOutside,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
  }) : assert(initialValue == null || controller == null);

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final InputBorder? border;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final TapRegionCallback? onTapOutside;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final TextAlign textAlign;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget field = TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: _tonosInputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        border: border,
        isDense: isDense,
        contentPadding: contentPadding,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      textAlign: textAlign,
    );
    if (semanticLabel != null) {
      field = Semantics(label: semanticLabel, child: field);
    }
    return field;
  }
}

InputDecoration _tonosInputDecoration({
  String? labelText,
  String? hintText,
  String? helperText,
  String? errorText,
  InputBorder? border,
  bool isDense = false,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) => InputDecoration(
  labelText: labelText,
  hintText: hintText,
  helperText: helperText,
  errorText: errorText,
  border: border,
  isDense: isDense,
  contentPadding: contentPadding,
  prefixIcon: prefixIcon,
  suffixIcon: suffixIcon,
);
