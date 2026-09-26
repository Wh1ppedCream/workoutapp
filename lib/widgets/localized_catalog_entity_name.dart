import 'package:flutter/material.dart';

import '../services/catalog_entity_localizer.dart';

/// Displays a localized built-in catalog label while leaving custom names and
/// missing translations unchanged.
class LocalizedCatalogEntityName extends StatelessWidget {
  const LocalizedCatalogEntityName({
    super.key,
    required this.entity,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
    this.localizer,
  });

  final CatalogEntityDisplayName entity;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;
  final CatalogEntityLocalizer? localizer;

  @override
  Widget build(BuildContext context) {
    return LocalizedCatalogEntityNamesBuilder(
      entities: [entity],
      localizer: localizer,
      builder:
          (context, names) => Text(
            names.single,
            maxLines: maxLines,
            overflow: overflow,
            style: style,
            textAlign: textAlign,
          ),
    );
  }
}

/// Resolves lookup-entity labels for layouts that need a list or custom view.
class LocalizedCatalogEntityNamesBuilder extends StatefulWidget {
  const LocalizedCatalogEntityNamesBuilder({
    super.key,
    required this.entities,
    required this.builder,
    this.localizer,
  });

  final List<CatalogEntityDisplayName> entities;
  final Widget Function(BuildContext context, List<String> names) builder;
  final CatalogEntityLocalizer? localizer;

  @override
  State<LocalizedCatalogEntityNamesBuilder> createState() =>
      _LocalizedCatalogEntityNamesBuilderState();
}

class _LocalizedCatalogEntityNamesBuilderState
    extends State<LocalizedCatalogEntityNamesBuilder> {
  Locale? _locale;
  Future<List<String>>? _namesFuture;

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
  void didUpdateWidget(covariant LocalizedCatalogEntityNamesBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localizer != widget.localizer ||
        !_sameEntities(oldWidget.entities, widget.entities)) {
      _resolve();
    }
  }

  void _resolve() {
    final locale = _locale;
    if (locale == null) return;
    _namesFuture = (widget.localizer ?? CatalogEntityLocalizer.instance)
        .resolveNames(widget.entities, locale);
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.entities
        .map((entity) => entity.canonicalName)
        .toList(growable: false);
    return FutureBuilder<List<String>>(
      future: _namesFuture,
      initialData: fallback,
      builder:
          (context, snapshot) =>
              widget.builder(context, snapshot.data ?? fallback),
    );
  }

  bool _sameEntities(
    List<CatalogEntityDisplayName> first,
    List<CatalogEntityDisplayName> second,
  ) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index].catalogId != second[index].catalogId ||
          first[index].canonicalName != second[index].canonicalName) {
        return false;
      }
    }
    return true;
  }
}
