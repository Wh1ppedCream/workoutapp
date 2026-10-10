// File: lib/screens/profile/settings/volume_boundaries_screen.dart

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

class VolumeBoundariesScreen extends StatefulWidget {
  const VolumeBoundariesScreen({super.key});

  @override
  State<VolumeBoundariesScreen> createState() => _VolumeBoundariesScreenState();
}

class _VolumeBoundariesScreenState extends State<VolumeBoundariesScreen>
    with SingleTickerProviderStateMixin {
  AppRepository get _repo => context.read<AppRepository>();
  late final TabController _tabCtrl;

  List<BodyPart> _bodyParts = [];
  List<Muscle> _muscles = [];
  bool _isLoadingLookups = true;
  SafeFailure? _lookupFailure;

  BodyPart? _selectedBodyPart;
  Muscle? _selectedMuscle;

  final _bodyPartCtrls = List.generate(4, (_) => TextEditingController());
  final _muscleCtrls = List.generate(4, (_) => TextEditingController());

  bool _isLoadingBodyPart = false;
  bool _isLoadingMuscle = false;
  bool _isSavingBodyPart = false;
  bool _isSavingMuscle = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLookups();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (var controller in _bodyPartCtrls) {
      controller.dispose();
    }
    for (var controller in _muscleCtrls) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLookups() async {
    if (mounted) {
      setState(() {
        _isLoadingLookups = true;
        _lookupFailure = null;
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
        _selectedMuscle = muscles.isNotEmpty ? muscles.first : null;
        _lookupFailure = null;
      });
      if (_selectedBodyPart != null) {
        await _loadBodyPartBounds(_selectedBodyPart!.id);
      }
      if (_selectedMuscle != null) {
        await _loadMuscleBounds(_selectedMuscle!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lookupFailure = SafeFailure.classify(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _loadBodyPartBounds(int id) async {
    setState(() {
      _isLoadingBodyPart = true;
      for (var controller in _bodyPartCtrls) {
        controller.clear();
      }
    });
    try {
      final bounds = await _repo.fetchBodyPartVolumeBounds(id);
      if (!mounted) return;
      if (bounds != null) {
        setState(() => _setControllerText(_bodyPartCtrls, bounds));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).volumeLoadBodyPartFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingBodyPart = false);
      }
    }
  }

  Future<void> _loadMuscleBounds(int id) async {
    setState(() {
      _isLoadingMuscle = true;
      for (var controller in _muscleCtrls) {
        controller.clear();
      }
    });
    try {
      final bounds = await _repo.fetchMuscleVolumeBounds(id);
      if (!mounted) return;
      if (bounds != null) {
        setState(() => _setControllerText(_muscleCtrls, bounds));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).volumeLoadMuscleFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMuscle = false);
      }
    }
  }

  void _setControllerText(
    List<TextEditingController> controllers,
    VolumeBoundaries bounds,
  ) {
    controllers[0].text = bounds.maintenance.toString();
    controllers[1].text = bounds.minEffective.toString();
    controllers[2].text = bounds.maxAdaptive.toString();
    controllers[3].text = bounds.maxRecoverable.toString();
  }

  List<double>? _parseBounds(List<TextEditingController> controllers) {
    final values = controllers.map((controller) {
      return double.tryParse(controller.text.trim());
    }).toList();
    return values.any((value) => value == null) ? null : values.cast<double>();
  }

  Future<void> _saveBodyPart() async {
    if (_selectedBodyPart == null) return;
    final values = _parseBounds(_bodyPartCtrls);
    if (values == null) {
      _showInvalidNumbers();
      return;
    }

    setState(() => _isSavingBodyPart = true);
    try {
      final bounds = VolumeBoundaries(
        id: _selectedBodyPart!.id,
        maintenance: values[0],
        minEffective: values[1],
        maxAdaptive: values[2],
        maxRecoverable: values[3],
      );
      await _repo.setBodyPartVolumeBounds(_selectedBodyPart!.id, bounds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).volumeBodyPartSaved),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingBodyPart = false);
      }
    }
  }

  Future<void> _saveMuscle() async {
    if (_selectedMuscle == null) return;
    final values = _parseBounds(_muscleCtrls);
    if (values == null) {
      _showInvalidNumbers();
      return;
    }

    setState(() => _isSavingMuscle = true);
    try {
      final bounds = VolumeBoundaries(
        id: _selectedMuscle!.id,
        maintenance: values[0],
        minEffective: values[1],
        maxAdaptive: values[2],
        maxRecoverable: values[3],
      );
      await _repo.setMuscleVolumeBounds(_selectedMuscle!.id, bounds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).volumeMuscleSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingMuscle = false);
      }
    }
  }

  void _showInvalidNumbers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).volumeInvalidNumbers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destination = analyticsDestinationTokens(context);
    final tabs = TabBar(
      controller: _tabCtrl,
      indicatorColor: destination?.surfaceSecondary,
      labelColor: destination?.onSurfacePrimary,
      unselectedLabelColor: destination?.onSurfacePrimary.withValues(
        alpha: 0.7,
      ),
      tabs: [
        Tab(text: strings.volumeBodyParts),
        Tab(text: strings.volumeMuscles),
      ],
    );
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.analytics,
      child: Scaffold(
        backgroundColor: destination?.pageCanvas,
        appBar: AppBar(
          title: Text(strings.settingsVolumeBoundaries),
          backgroundColor: destination?.surfacePrimary,
          foregroundColor: destination?.onSurfacePrimary,
          scrolledUnderElevation: 0,
          bottom: destination == null
              ? tabs
              : PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: destination.surfaceAccent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: destination.outlineAccent.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: TabBar(
                        controller: _tabCtrl,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                          color: destination.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        labelColor: destination.onSurfaceSecondary,
                        unselectedLabelColor: destination.onSurfaceAccent,
                        labelPadding: EdgeInsets.zero,
                        tabs: [
                          Tab(text: strings.volumeBodyParts),
                          Tab(text: strings.volumeMuscles),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context);
    if (_isLoadingLookups) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_lookupFailure != null) {
      return SafeErrorView(
        title: strings.safeFailureLoadTitle,
        failure: _lookupFailure!,
        onRetry: _loadLookups,
      );
    }

    return TabBarView(
      controller: _tabCtrl,
      children: [
        _BoundaryTab<BodyPart>(
          title: strings.volumeBodyPartTitle,
          subtitle: strings.volumeBodyPartSubtitle,
          icon: Icons.accessibility_new,
          choiceId: 'body-part',
          selected: _selectedBodyPart,
          items: _bodyParts,
          itemName: (bodyPart) => localizedBodyPartName(context, bodyPart.name),
          onChanged: (bodyPart) {
            if (bodyPart == null) return;
            setState(() => _selectedBodyPart = bodyPart);
            _loadBodyPartBounds(bodyPart.id);
          },
          controllers: _bodyPartCtrls,
          isLoading: _isLoadingBodyPart,
          isSaving: _isSavingBodyPart,
          onSave: _saveBodyPart,
        ),
        _BoundaryTab<Muscle>(
          title: strings.volumeMuscleTitle,
          subtitle: strings.volumeMuscleSubtitle,
          icon: Icons.fitness_center,
          choiceId: 'muscle',
          selected: _selectedMuscle,
          items: _muscles,
          itemName: (muscle) => muscle.name,
          itemLabelFor: (context, muscle) => LocalizedCatalogEntityName(
            entity: CatalogEntityDisplayName(
              catalogId: muscle.catalogId,
              canonicalName: muscle.name,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onChanged: (muscle) {
            if (muscle == null) return;
            setState(() => _selectedMuscle = muscle);
            _loadMuscleBounds(muscle.id);
          },
          controllers: _muscleCtrls,
          isLoading: _isLoadingMuscle,
          isSaving: _isSavingMuscle,
          onSave: _saveMuscle,
        ),
      ],
    );
  }
}

class _BoundaryTab<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String choiceId;
  final T? selected;
  final List<T> items;
  final String Function(T item) itemName;
  final Widget Function(BuildContext context, T item)? itemLabelFor;
  final ValueChanged<T?> onChanged;
  final List<TextEditingController> controllers;
  final bool isLoading;
  final bool isSaving;
  final VoidCallback onSave;

  const _BoundaryTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.choiceId,
    required this.selected,
    required this.items,
    required this.itemName,
    this.itemLabelFor,
    required this.onChanged,
    required this.controllers,
    required this.isLoading,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dropdownIconColor = settingsInputForeground(context);
    final destination = analyticsDestinationTokens(context);
    final boundaryLabels = [
      strings.volumeMaintenance,
      strings.volumeMinEffective,
      strings.volumeMaxAdaptive,
      strings.volumeMaxRecoverable,
    ];
    if (destination != null) {
      final role = title == strings.volumeBodyPartTitle
          ? AnalyticsSurfaceRole.secondary
          : AnalyticsSurfaceRole.tertiary;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          AnalyticsRouteHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            role: role,
          ),
          const SizedBox(height: 16),
          AnalyticsZone(
            role: AnalyticsSurfaceRole.accent,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.volumeSelection,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: destination.onSurfaceAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _VolumeBoundaryChoiceField<T>(
                  fieldId: choiceId,
                  title: title,
                  items: items,
                  selected: selected,
                  itemName: itemName,
                  itemLabelFor: itemLabelFor,
                  enabled: !isLoading && !isSaving,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnalyticsZone(
            role: AnalyticsSurfaceRole.secondary,
            padding: const EdgeInsets.all(14),
            borderRadius: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.volumeRecommendedRange,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: destination.onSurfaceSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.volumeRecommendedRangeSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: destination.onSurfaceSecondary.withValues(
                      alpha: 0.82,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  for (var i = 0; i < controllers.length; i++) ...[
                    TextFormField(
                      controller: controllers[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _expressiveBoundaryFieldDecoration(
                        destination,
                        boundaryLabels[i],
                      ),
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: destination.onSurfaceAccent),
                    ),
                    if (i != controllers.length - 1) const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: destination.actionPrimary,
                        foregroundColor: destination.onActionPrimary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: isSaving ? null : onSave,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        isSaving
                            ? strings.nutritionSaving
                            : strings.volumeSaveBoundaries,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SettingsHeroCard(title: title, subtitle: subtitle, icon: icon),
        const SizedBox(height: 16),
        SettingsSection(
          title: strings.volumeSelection,
          accentColor: SettingsAccent.training,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<T>(
                isExpanded: true,
                initialValue: selected,
                dropdownColor: settingsDropdownMenuColor(context),
                style: settingsInputTextStyle(context),
                iconEnabledColor: dropdownIconColor,
                iconDisabledColor: settingsInputForeground(
                  context,
                  enabled: false,
                ),
                decoration: settingsFieldDecoration(context, label: title),
                selectedItemBuilder: (_) => items
                    .map(
                      (item) => settingsDropdownTriggerLabel(
                        context,
                        itemLabelFor?.call(context, item) ??
                            Text(itemName(item)),
                      ),
                    )
                    .toList(),
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: settingsDropdownMenuLabel(
                          context,
                          itemLabelFor?.call(context, item) ??
                              Text(itemName(item)),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isLoading || isSaving ? null : onChanged,
              ),
            ),
          ],
        ),
        SettingsSection(
          title: strings.volumeRecommendedRange,
          subtitle: strings.volumeRecommendedRangeSubtitle,
          accentColor: SettingsAccent.progress,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (var i = 0; i < controllers.length; i++) ...[
                      TextFormField(
                        controller: controllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: settingsFieldDecoration(
                          context,
                          label: boundaryLabels[i],
                        ),
                      ),
                      if (i != controllers.length - 1)
                        const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onSave,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isSaving
                              ? strings.nutritionSaving
                              : strings.volumeSaveBoundaries,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

InputDecoration _expressiveBoundaryFieldDecoration(
  AppExpressiveDestinationTokens tokens,
  String label,
) {
  const borderRadius = BorderRadius.all(Radius.circular(18));
  final restingBorder = BorderSide(
    color: tokens.outlineAccent.withValues(alpha: 0.58),
    width: 1,
  );
  OutlineInputBorder outline(BorderSide side) =>
      OutlineInputBorder(borderRadius: borderRadius, borderSide: side);

  return InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: tokens.surfaceAccent,
    labelStyle: TextStyle(
      color: tokens.onSurfaceAccent.withValues(alpha: 0.82),
    ),
    floatingLabelStyle: TextStyle(color: tokens.onSurfaceAccent),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enabledBorder: outline(restingBorder),
    focusedBorder: outline(BorderSide(color: tokens.outlineAccent, width: 2)),
    border: outline(restingBorder),
  );
}

class _VolumeBoundaryChoiceField<T> extends StatefulWidget {
  const _VolumeBoundaryChoiceField({
    super.key,
    required this.fieldId,
    required this.title,
    required this.items,
    required this.selected,
    required this.itemName,
    required this.onChanged,
    required this.enabled,
    this.itemLabelFor,
  });

  final String fieldId;
  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T item) itemName;
  final Widget Function(BuildContext context, T item)? itemLabelFor;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  State<_VolumeBoundaryChoiceField<T>> createState() =>
      _VolumeBoundaryChoiceFieldState<T>();
}

class _VolumeBoundaryChoiceFieldState<T>
    extends State<_VolumeBoundaryChoiceField<T>> {
  late final FocusNode _focusNode;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Volume boundary choice');
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
        : widget.itemName(widget.selected as T);
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
          key: ValueKey<String>('volume-choice-${widget.fieldId}'),
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
          builder: (context, controller, child) => PopScope(
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
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: enabled
                        ? () => controller.isOpen
                              ? controller.close()
                              : controller.open()
                        : null,
                    child: InputDecorator(
                      decoration:
                          _expressiveBoundaryFieldDecoration(
                            tokens,
                            widget.title,
                          ).copyWith(
                            enabled: enabled,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: tokens.onSurfaceAccent,
                            ),
                          ),
                      isFocused: _focusNode.hasFocus || _menuOpen,
                      isEmpty: widget.selected == null,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: DefaultTextStyle.merge(
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: tokens.onSurfaceAccent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: widget.selected == null
                              ? const SizedBox.shrink()
                              : _itemLabel(context, widget.selected as T),
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

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: MenuItemButton(
          key: ValueKey<String>(
            'volume-choice-${widget.fieldId}-option-$index',
          ),
          onPressed: () => widget.onChanged(item),
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
            child: _itemLabel(context, item, foreground: foreground),
          ),
        ),
      ),
    );
  }

  Widget _itemLabel(BuildContext context, T item, {Color? foreground}) {
    final label =
        widget.itemLabelFor?.call(context, item) ??
        Text(
          widget.itemName(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    final color =
        foreground ?? analyticsDestinationTokens(context)!.onSurfaceAccent;
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme.merge(
        data: IconThemeData(color: color),
        child: label,
      ),
    );
  }
}
