import 'package:flutter/material.dart';

/// Semantic field recipes. Visual styling remains owned by the active
/// Material input theme.
enum TonosFieldVariant { standard, search }

/// A small field boundary that keeps feature code independent of decoration
/// details while retaining the complete Material text-input API.
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
    this.semanticLabel,
  });

  final TonosFieldVariant variant;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
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
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
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
      minLines: minLines,
    );
    if (semanticLabel != null) {
      field = Semantics(label: semanticLabel, child: field);
    }
    return field;
  }
}
