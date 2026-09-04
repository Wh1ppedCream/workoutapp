import 'package:flutter/material.dart';

import '../models/definition_models.dart';
import '../services/exercise_content_localizer.dart';

/// Displays a translated built-in exercise name without changing its stored
/// canonical name. The canonical name is also the loading and error fallback.
class LocalizedExerciseName extends StatelessWidget {
  const LocalizedExerciseName({
    super.key,
    required this.definition,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
    this.localizer,
  });

  final ExerciseDefinition definition;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;
  final ExerciseContentLocalizer? localizer;

  @override
  Widget build(BuildContext context) {
    return LocalizedExerciseNameBuilder(
      definition: definition,
      localizer: localizer,
      builder:
          (context, name) => Text(
            name,
            maxLines: maxLines,
            overflow: overflow,
            style: style,
            textAlign: textAlign,
          ),
    );
  }
}

/// Resolves an exercise name for layouts that need more than a Text widget.
class LocalizedExerciseNameBuilder extends StatefulWidget {
  const LocalizedExerciseNameBuilder({
    super.key,
    required this.definition,
    required this.builder,
    this.localizer,
  });

  final ExerciseDefinition definition;
  final Widget Function(BuildContext context, String name) builder;
  final ExerciseContentLocalizer? localizer;

  @override
  State<LocalizedExerciseNameBuilder> createState() =>
      _LocalizedExerciseNameBuilderState();
}

class _LocalizedExerciseNameBuilderState
    extends State<LocalizedExerciseNameBuilder> {
  Locale? _locale;
  Future<String>? _nameFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != locale) {
      _locale = locale;
      _resolve();
    }
  }

  @override
  void didUpdateWidget(covariant LocalizedExerciseNameBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.catalogId != widget.definition.catalogId ||
        oldWidget.definition.name != widget.definition.name ||
        oldWidget.localizer != widget.localizer) {
      _resolve();
    }
  }

  void _resolve() {
    final locale = _locale;
    if (locale == null) return;
    _nameFuture = (widget.localizer ?? ExerciseContentLocalizer.instance)
        .resolveName(widget.definition, locale);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _nameFuture,
      initialData: widget.definition.name,
      builder:
          (context, snapshot) =>
              widget.builder(context, snapshot.data ?? widget.definition.name),
    );
  }
}
