// File: lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/safe_failure_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/catalog_entity_localizer.dart';
import '../../../services/safe_failure.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../utils/localized_body_part_name.dart';
import '../../../widgets/localized_catalog_entity_name.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';
import 'analytics_destination_surfaces.dart';

class BodyPartMuscleMappingScreen extends StatefulWidget {
  const BodyPartMuscleMappingScreen({super.key});

  @override
  State<BodyPartMuscleMappingScreen> createState() =>
      _BodyPartMuscleMappingScreenState();
}

class _BodyPartMuscleMappingScreenState
    extends State<BodyPartMuscleMappingScreen> {
  AppRepository get _repo => context.read<AppRepository>();
  List<BodyPart> _bodyParts = [];
  List<Muscle> _muscles = [];
  BodyPart? _selectedBodyPart;
  Set<int> _linkedMuscleIds = {};
  Set<int>? _originalLinked;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingMappings = false;
  int _mappingRequest = 0;
  SafeFailure? _mappingFailure;
  bool _editing = false;
  bool _selectedMusclesOnly = false;
  String _muscleSearchQuery = '';
  final TextEditingController _muscleSearchController = TextEditingController();
  SafeFailure? _failure;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _muscleSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _failure = null;
      });
    }
    try {
      final bodyParts = await _repo.fetchAllBodyPartsFull();
      final muscles = await _repo.fetchAllMusclesFull();
      if (!mounted) return;
      setState(() {
        _bodyParts = bodyParts;
        _muscles = muscles;
        _selectedBodyPart = bodyParts.isNotEmpty ? bodyParts.first : null;
        _isLoading = false;
        _failure = null;
      });
      if (_selectedBodyPart != null) {
        await _loadMappings(_selectedBodyPart!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = SafeFailure.classify(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMappings(int bodyPartId) async {
    final request = ++_mappingRequest;
    setState(() {
      _isLoadingMappings = true;
      _mappingFailure = null;
      _linkedMuscleIds = {};
    });
    try {
      final rows = await _repo.fetchMusclesForBodyPart(bodyPartId);
      if (!mounted ||
          request != _mappingRequest ||
          _selectedBodyPart?.id != bodyPartId) {
        return;
      }
      setState(() => _linkedMuscleIds = rows.map((r) => r.muscleId).toSet());
    } catch (error) {
      if (!mounted || request != _mappingRequest) return;
      setState(() => _mappingFailure = SafeFailure.classify(error));
    } finally {
      if (mounted && request == _mappingRequest) {
        setState(() => _isLoadingMappings = false);
      }
    }
  }

  Future<void> _saveMappings() async {
    if (_selectedBodyPart == null ||
        _originalLinked == null ||
        _isLoadingMappings ||
        _isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final bodyPartId = _selectedBodyPart!.id;
      final added = _linkedMuscleIds.difference(_originalLinked!);
      final removed = _originalLinked!.difference(_linkedMuscleIds);
      for (var id in added) {
        await _repo.linkMuscleToBodyPart(id, bodyPartId);
      }
      for (var id in removed) {
        await _repo.unlinkMuscleFromBodyPart(id, bodyPartId);
      }
      if (!mounted) return;
      setState(() {
        _editing = false;
        _isSaving = false;
        _originalLinked = null;
        _selectedMusclesOnly = false;
        _muscleSearchQuery = '';
        _muscleSearchController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mappingSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).mappingSaveFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    }
  }

  void _startEditing() {
    if (_isLoadingMappings ||
        _mappingFailure != null ||
        _selectedBodyPart == null) {
      return;
    }
    setState(() {
      _editing = true;
      _originalLinked = Set<int>.from(_linkedMuscleIds);
      _selectedMusclesOnly = false;
      _muscleSearchQuery = '';
      _muscleSearchController.clear();
    });
  }

  void _cancelEditing() {
    setState(() {
      _linkedMuscleIds = Set<int>.from(_originalLinked ?? _linkedMuscleIds);
      _editing = false;
      _originalLinked = null;
      _selectedMusclesOnly = false;
      _muscleSearchQuery = '';
      _muscleSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destination = analyticsDestinationTokens(context);
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.analytics,
      child: Scaffold(
        backgroundColor: destination?.pageCanvas,
        appBar: destination == null
            ? AppBar(
                title: Text(strings.mappingTitle),
                scrolledUnderElevation: 0,
              )
            : null,
        bottomNavigationBar: _editing
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: destination == null
                      ? 0
                      : MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SettingsSaveBar(
                  label: _isSaving
                      ? strings.nutritionSaving
                      : strings.commonSave,
                  onPressed: _isSaving ? null : _saveMappings,
                  cancelLabel: strings.commonCancel,
                  onCancel: _isSaving ? null : _cancelEditing,
                  saveIcon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  decorated: false,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                ),
              )
            : null,
        body: SafeArea(child: _buildBody()),
        floatingActionButton:
            (!_editing &&
                !_isLoading &&
                _failure == null &&
                !_isLoadingMappings &&
                _mappingFailure == null &&
                _selectedBodyPart != null)
            ? FloatingActionButton.extended(
                onPressed: _startEditing,
                backgroundColor: destination?.actionPrimary,
                foregroundColor: destination?.onActionPrimary,
                icon: const Icon(Icons.edit),
                label: Text(strings.commonEdit),
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context);
    final destination = analyticsDestinationTokens(context);
    final expressiveLightTokens =
        destination != null && Theme.of(context).brightness == Brightness.light
        ? destination
        : null;
    if (_isLoading) {
      return _withExpressiveBackButton(
        context,
        content: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_failure != null) {
      return _withExpressiveBackButton(
        context,
        content: SafeErrorView(
          title: strings.safeFailureLoadTitle,
          failure: _failure!,
          onRetry: _loadLookups,
        ),
      );
    }

    final linkedMuscles = _muscles
        .where((m) => _linkedMuscleIds.contains(m.id))
        .toList();
    final expressiveEditClearance = destination != null && _editing
        ? 72.0
        : 0.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 112 + expressiveEditClearance),
      children: [
        if (analyticsDestinationTokens(context) != null)
          _expressiveBackButton(context),
        AnalyticsRouteHeader(
          title: strings.mappingTitle,
          subtitle: strings.mappingHero,
          icon: Icons.hub,
        ),
        const SizedBox(height: 16),
        AnalyticsZone(
          role: AnalyticsSurfaceRole.accent,
          padding: const EdgeInsets.all(8),
          child: SettingsSection(
            title: strings.mappingSelectedBodyPart,
            accentColor: SettingsAccent.training,
            titleColor: expressiveLightTokens?.onSurfaceAccent,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: destination == null
                    ? DropdownButtonFormField<BodyPart>(
                        isExpanded: true,
                        initialValue: _selectedBodyPart,
                        dropdownColor: settingsDropdownMenuColor(context),
                        style: settingsInputTextStyle(context),
                        iconEnabledColor: settingsInputForeground(context),
                        iconDisabledColor: settingsInputForeground(
                          context,
                          enabled: false,
                        ),
                        decoration: settingsFieldDecoration(
                          context,
                          label: strings.mappingBodyPart,
                        ),
                        selectedItemBuilder: (_) => _bodyParts
                            .map(
                              (bodyPart) => settingsDropdownTriggerLabel(
                                context,
                                Text(
                                  localizedBodyPartName(context, bodyPart.name),
                                ),
                              ),
                            )
                            .toList(),
                        items: _bodyParts
                            .map(
                              (bodyPart) => DropdownMenuItem(
                                value: bodyPart,
                                child: settingsDropdownMenuLabel(
                                  context,
                                  Text(
                                    localizedBodyPartName(
                                      context,
                                      bodyPart.name,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: !_editing
                            ? (bodyPart) => _selectBodyPart(bodyPart)
                            : null,
                      )
                    : _ExpressiveBodyPartChoiceField(
                        items: _bodyParts,
                        selected: _selectedBodyPart,
                        title: strings.mappingBodyPart,
                        enabled: !_editing,
                        onChanged: _selectBodyPart,
                      ),
              ),
            ],
          ),
        ),
        if (analyticsDestinationTokens(context) != null)
          const SizedBox(
            key: ValueKey('mapping-section-separator'),
            height: 12,
          ),
        AnalyticsZone(
          role: AnalyticsSurfaceRole.secondary,
          padding: const EdgeInsets.all(8),
          borderRadius: 28,
          child: SettingsSection(
            title: _editing
                ? strings.mappingChooseLinkedMuscles
                : strings.mappingLinkedMuscles,
            accentColor: SettingsAccent.advanced,
            titleColor: expressiveLightTokens?.onSurfaceSecondary,
            subtitle: _editing
                ? '${strings.mappingChooseLinkedSubtitle} · ${strings.mappingSelectedCount(_linkedMuscleIds.length)}'
                : strings.mappingLinkedCount(linkedMuscles.length),
            children: _isLoadingMappings
                ? [const Center(child: CircularProgressIndicator())]
                : _mappingFailure != null
                ? [
                    SafeErrorView(
                      title: strings.safeFailureLoadTitle,
                      failure: _mappingFailure!,
                      onRetry: () => _loadMappings(_selectedBodyPart!.id),
                    ),
                  ]
                : _editing
                ? _editableMuscleTiles()
                : _readOnlyMuscleTiles(linkedMuscles),
          ),
        ),
      ],
    );
  }

  void _selectBodyPart(BodyPart? bodyPart) {
    setState(() => _selectedBodyPart = bodyPart);
    if (bodyPart != null) _loadMappings(bodyPart.id);
  }

  Widget _withExpressiveBackButton(
    BuildContext context, {
    required Widget content,
  }) {
    if (analyticsDestinationTokens(context) == null) return content;
    return Column(
      children: [
        _expressiveBackButton(context),
        Expanded(child: content),
      ],
    );
  }

  Widget _expressiveBackButton(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: IconButton(
      tooltip: AppLocalizations.of(context).commonBack,
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back),
    ),
  );

  List<Widget> _editableMuscleTiles() {
    if (_muscles.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(AppLocalizations.of(context).mappingNoMuscles),
        ),
      ];
    }

    final tokens = analyticsDestinationTokens(context);
    if (tokens != null) {
      return [
        _expressiveMuscleSearch(tokens),
        _expressiveSelectedOnly(tokens),
        LocalizedCatalogEntityNamesBuilder(
          entities: _muscles
              .map(
                (muscle) => CatalogEntityDisplayName(
                  catalogId: muscle.catalogId,
                  canonicalName: muscle.name,
                ),
              )
              .toList(growable: false),
          builder: (context, names) {
            final query = _muscleSearchQuery.trim().toLowerCase();
            final visibleIndexes = <int>[];
            for (var index = 0; index < _muscles.length; index++) {
              final muscle = _muscles[index];
              if (_selectedMusclesOnly &&
                  !_linkedMuscleIds.contains(muscle.id)) {
                continue;
              }
              if (query.isNotEmpty &&
                  !names[index].toLowerCase().contains(query)) {
                continue;
              }
              visibleIndexes.add(index);
            }
            if (visibleIndexes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                child: Text(
                  AppLocalizations.of(context).mappingNoFilteredMuscles,
                ),
              );
            }
            return Column(
              children: settingsTilesWithDividers(
                context,
                visibleIndexes
                    .map((index) {
                      final muscle = _muscles[index];
                      final linked = _linkedMuscleIds.contains(muscle.id);
                      return CheckboxListTile(
                        key: ValueKey('mapping-muscle-checkbox-${muscle.id}'),
                        value: linked,
                        onChanged: (checked) {
                          if (checked == null) return;
                          setState(() {
                            if (checked) {
                              _linkedMuscleIds.add(muscle.id);
                            } else {
                              _linkedMuscleIds.remove(muscle.id);
                            }
                          });
                        },
                        title: Text(names[index], softWrap: true),
                        controlAffinity: ListTileControlAffinity.trailing,
                        minVerticalPadding: 10,
                      );
                    })
                    .toList(growable: false),
              ),
            );
          },
        ),
      ];
    }

    return settingsTilesWithDividers(
      context,
      _muscles.map((muscle) {
        final linked = _linkedMuscleIds.contains(muscle.id);
        return CheckboxListTile(
          value: linked,
          onChanged: (checked) {
            if (checked == null) return;
            setState(() {
              if (checked) {
                _linkedMuscleIds.add(muscle.id);
              } else {
                _linkedMuscleIds.remove(muscle.id);
              }
            });
          },
          title: LocalizedCatalogEntityName(
            entity: CatalogEntityDisplayName(
              catalogId: muscle.catalogId,
              canonicalName: muscle.name,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          secondary: const Icon(Icons.fitness_center),
        );
      }).toList(),
    );
  }

  Widget _expressiveMuscleSearch(AppExpressiveDestinationTokens tokens) {
    final strings = AppLocalizations.of(context);
    final borderRadius = BorderRadius.circular(16);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: TextField(
        key: const ValueKey('mapping-muscle-search'),
        controller: _muscleSearchController,
        onChanged: (value) => setState(() => _muscleSearchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: strings.mappingSearchMuscles,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _muscleSearchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: strings.gymProfileClear,
                  onPressed: () {
                    _muscleSearchController.clear();
                    setState(() => _muscleSearchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
          isDense: true,
          filled: true,
          fillColor: tokens.surfacePrimary.withValues(alpha: 0.08),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          border: outline(tokens.outlineAccent.withValues(alpha: 0.62), 1),
          enabledBorder: outline(
            tokens.outlineAccent.withValues(alpha: 0.48),
            1,
          ),
          focusedBorder: outline(tokens.outlineAccent, 1.7),
        ),
      ),
    );
  }

  Widget _expressiveSelectedOnly(AppExpressiveDestinationTokens tokens) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, top: 2, bottom: 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilterChip(
          key: const ValueKey('mapping-selected-only-filter'),
          selected: _selectedMusclesOnly,
          showCheckmark: true,
          label: Text(strings.mappingSelectedOnly),
          onSelected: (selected) =>
              setState(() => _selectedMusclesOnly = selected),
          backgroundColor: tokens.surfaceAccent,
          selectedColor: tokens.surfaceSelected,
          checkmarkColor: tokens.onSurfaceSelected,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _selectedMusclesOnly
                ? tokens.onSurfaceSelected
                : tokens.onSurfaceAccent,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: tokens.outlineAccent.withValues(alpha: 0.55)),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  List<Widget> _readOnlyMuscleTiles(List<Muscle> linkedMuscles) {
    if (linkedMuscles.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(AppLocalizations.of(context).mappingNoLinkedMuscles),
        ),
      ];
    }

    return settingsTilesWithDividers(
      context,
      linkedMuscles
          .map(
            (muscle) => SettingsActionTile(
              icon: Icons.fitness_center,
              title: muscle.name,
              titleWidget: LocalizedCatalogEntityName(
                entity: CatalogEntityDisplayName(
                  catalogId: muscle.catalogId,
                  canonicalName: muscle.name,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const SizedBox.shrink(),
            ),
          )
          .toList(),
    );
  }
}

/// Anchored Expressive selector for the mapping route. The other theme
/// families continue to use the standard DropdownButtonFormField above.
class _ExpressiveBodyPartChoiceField extends StatefulWidget {
  const _ExpressiveBodyPartChoiceField({
    required this.items,
    required this.selected,
    required this.title,
    required this.enabled,
    required this.onChanged,
  });

  final List<BodyPart> items;
  final BodyPart? selected;
  final String title;
  final bool enabled;
  final ValueChanged<BodyPart?> onChanged;

  @override
  State<_ExpressiveBodyPartChoiceField> createState() =>
      _ExpressiveBodyPartChoiceFieldState();
}

class _ExpressiveBodyPartChoiceFieldState
    extends State<_ExpressiveBodyPartChoiceField> {
  late final FocusNode _focusNode;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Anatomy mapping body part');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = analyticsDestinationTokens(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final selectedLabel = widget.selected == null
        ? ''
        : localizedBodyPartName(context, widget.selected!.name);
    final enabled = widget.enabled && widget.items.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenSize.width - mediaQuery.padding.horizontal - 32;
        final width = math
            .max(
              0.0,
              math.min(
                availableWidth,
                screenSize.width - mediaQuery.padding.horizontal - 24,
              ),
            )
            .toDouble();
        final availableHeight = math.max(
          0.0,
          screenSize.height -
              mediaQuery.padding.vertical -
              mediaQuery.viewInsets.vertical -
              24,
        );
        final menuMaxHeight = math
            .min(availableHeight, screenSize.height / 2)
            .toDouble();

        return MenuAnchor(
          key: const ValueKey('mapping-body-part-choice'),
          useRootOverlay: true,
          consumeOutsideTap: true,
          crossAxisUnconstrained: false,
          childFocusNode: _focusNode,
          onOpen: () {
            if (mounted) setState(() => _menuOpen = true);
          },
          onClose: () {
            if (mounted) setState(() => _menuOpen = false);
          },
          style: MenuStyle(
            alignment: AlignmentDirectional.bottomStart,
            backgroundColor: WidgetStatePropertyAll(tokens.surfaceAccent),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(2),
            side: WidgetStatePropertyAll(
              BorderSide(color: tokens.outlineAccent, width: 1),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
            minimumSize: WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll(Size(width, menuMaxHeight)),
          ),
          menuChildren: [
            for (var index = 0; index < widget.items.length; index++)
              _menuItem(context, tokens, index),
          ],
          builder: (context, controller, child) => PopScope<Object?>(
            canPop: !controller.isOpen,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && controller.isOpen) controller.close();
            },
            child: Semantics(
              button: true,
              enabled: enabled,
              expanded: _menuOpen,
              label: widget.title,
              value: selectedLabel,
              onTap: enabled
                  ? () => controller.isOpen
                        ? controller.close()
                        : controller.open()
                  : null,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: width,
                  child: InkWell(
                    focusNode: _focusNode,
                    canRequestFocus: enabled,
                    borderRadius: BorderRadius.circular(16),
                    onTap: enabled
                        ? () => controller.isOpen
                              ? controller.close()
                              : controller.open()
                        : null,
                    child: InputDecorator(
                      decoration: _fieldDecoration(tokens, enabled).copyWith(
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: enabled
                              ? tokens.onSurfaceAccent
                              : tokens.onSurfaceAccent.withValues(alpha: 0.55),
                        ),
                      ),
                      isFocused: _focusNode.hasFocus || _menuOpen,
                      isEmpty: widget.selected == null,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          selectedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: tokens.onSurfaceAccent.withValues(
                              alpha: enabled ? 1 : 0.62,
                            ),
                          ),
                        ),
                      ),
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

  InputDecoration _fieldDecoration(
    AppExpressiveDestinationTokens tokens,
    bool enabled,
  ) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: tokens.outlineAccent, width: 1.6),
    );
    return InputDecoration(
      labelText: widget.title,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: tokens.onSurfaceAccent),
      floatingLabelStyle: TextStyle(color: tokens.onSurfaceAccent),
      filled: true,
      fillColor: tokens.surfacePrimary.withValues(
        alpha: enabled ? 0.07 : 0.035,
      ),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: focusBorder,
    );
  }

  Widget _menuItem(
    BuildContext context,
    AppExpressiveDestinationTokens tokens,
    int index,
  ) {
    final item = widget.items[index];
    final selected = item == widget.selected;
    final foreground = selected
        ? tokens.onSurfaceSelected
        : tokens.onSurfaceAccent;
    final background = selected ? tokens.surfaceSelected : tokens.surfaceAccent;
    final label = localizedBodyPartName(context, item.name);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: MenuItemButton(
          key: ValueKey('mapping-body-part-option-$index'),
          onPressed: widget.enabled ? () => widget.onChanged(item) : null,
          style: ButtonStyle(
            alignment: AlignmentDirectional.centerStart,
            foregroundColor: WidgetStatePropertyAll(foreground),
            backgroundColor: WidgetStatePropertyAll(background),
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          trailingIcon: selected
              ? Icon(Icons.check, color: foreground, size: 18)
              : null,
          child: SizedBox(
            width: double.infinity,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
