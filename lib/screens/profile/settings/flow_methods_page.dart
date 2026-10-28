// File: lib/screens/profile/settings/flow_methods_page.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../theme/widgets/tonos_expressive_motion.dart';
import '../../../theme/widgets/tonos_expressive_state_motion.dart';
import '../../../theme/widgets/tonos_expressive_inset_accordion.dart';
import '../../../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/preset_models.dart';
import '../../../models/gym_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/active_plan_store.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_dialog.dart';
import '../../../theme/widgets/tonos_field.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../widgets/settings_tiles.dart';

/// Same enum as in auto_preset_flow_screen.dart
enum AddSetMode { explicit, copy }

enum _CopySetSource { last, first, specific }

Widget _addSetModeOptions(
  BuildContext context, {
  required AddSetMode selected,
  required ValueChanged<AddSetMode> onChanged,
  bool expressiveSelectionGroup = false,
}) {
  final strings = AppLocalizations.of(context);
  if (expressiveSelectionGroup) {
    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final outline = tokens.outlineAccent.withValues(alpha: 0.38);
    Widget segment(AddSetMode value, String label, String keyName) {
      final isSelected = selected == value;
      final foreground = isSelected
          ? tokens.onSurfaceSelected
          : tokens.onSurfaceTertiary;
      return Expanded(
        child: Semantics(
          key: ValueKey<String>(keyName),
          button: true,
          selected: isSelected,
          inMutuallyExclusiveGroup: true,
          label: label,
          onTap: () => onChanged(value),
          child: ExcludeSemantics(
            child: Material(
              color: isSelected ? tokens.surfaceSelected : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? tokens.actionPrimary : Colors.transparent,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(value),
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceTertiary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          segment(
            AddSetMode.explicit,
            strings.flowExplicit,
            'plan-rule-add-set-explicit',
          ),
          segment(AddSetMode.copy, strings.rulesCopy, 'plan-rule-add-set-copy'),
        ],
      ),
    );
  }

  Radio<AddSetMode> option(AddSetMode value) => Radio<AddSetMode>(
    value: value,
    groupValue: selected,
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
  );

  Widget choice(AddSetMode value, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      option(value),
      Flexible(child: Text(label, softWrap: true)),
    ],
  );

  final expressive = context.usesExpressivePresentation;
  if (expressive) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        choice(AddSetMode.explicit, strings.flowExplicit),
        choice(AddSetMode.copy, strings.rulesCopy),
      ],
    );
  }

  return OverflowBar(
    children: [
      choice(AddSetMode.explicit, strings.flowExplicit),
      choice(AddSetMode.copy, strings.rulesCopy),
    ],
  );
}

/// A page to manage all FlowMethods:
///  • App-wide default methods
///  • Per-profile default methods
///  • Per-preset methods
class FlowMethodsPage extends StatefulWidget {
  const FlowMethodsPage({super.key});

  @override
  State<FlowMethodsPage> createState() => _FlowMethodsPageState();
}

class _FlowMethodsPageState extends State<FlowMethodsPage> {
  AppRepository get _repo => context.read<AppRepository>();

  bool _isLoading = true;
  bool _initialLoadStarted = false;
  int _loadRequest = 0;
  List<FlowMethod> _appMethods = [];
  List<GymProfile> _profiles = [];

  Map<int, List<FlowMethod>> _profileMethods = {};
  Map<int, List<Map<String, dynamic>>> _presetsByProfile = {};
  Map<int, List<FlowMethod>> _presetMethods = {};
  Map<int, Set<int>?> _activePlanIdsByProfile = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    final request = ++_loadRequest;
    final activePlanStore = context.usesExpressivePresentation
        ? _activePlanStoreOrNull()
        : null;
    setState(() => _isLoading = true);

    final initialResults = await Future.wait<Object>([
      _repo.fetchDefaultFlowMethods('app'),
      _repo.fetchAllProfiles(),
    ]);
    final appMethods = initialResults[0] as List<FlowMethod>;
    final profiles = initialResults[1] as List<GymProfile>;

    final loadedProfiles = await Future.wait(
      profiles.where((profile) => profile.id != null).map((profile) async {
        final profileId = profile.id!;
        final profileResults = await Future.wait<Object>([
          _repo.fetchDefaultFlowMethods('profile', profileId: profileId),
          _repo.fetchAllPresetsRaw(profileId: profileId),
        ]);
        final methods = profileResults[0] as List<FlowMethod>;
        final presets = profileResults[1] as List<Map<String, dynamic>>;
        final loadedPresets = await Future.wait(
          presets.map((preset) async {
            final presetId = preset['id'] as int;
            return MapEntry(presetId, await _repo.fetchFlowMethods(presetId));
          }),
        );
        Set<int>? activePlanIds;
        if (activePlanStore != null) {
          try {
            final storedActiveIds = await activePlanStore.load(profileId);
            activePlanIds = storedActiveIds.intersection(
              presets.map((preset) => preset['id'] as int).toSet(),
            );
          } catch (_) {
            // Status is presentation metadata; keep rule editing available if
            // an older preview or host cannot read active-plan membership.
          }
        }
        return _LoadedProfileMethods(
          profileId: profileId,
          methods: methods,
          presets: presets,
          presetMethods: Map.fromEntries(loadedPresets),
          activePlanIds: activePlanIds,
        );
      }),
    );

    final profileMethods = <int, List<FlowMethod>>{};
    final presetsByProfile = <int, List<Map<String, dynamic>>>{};
    final presetMethods = <int, List<FlowMethod>>{};
    final activePlanIdsByProfile = <int, Set<int>?>{};

    for (final loaded in loadedProfiles) {
      profileMethods[loaded.profileId] = loaded.methods;
      presetsByProfile[loaded.profileId] = loaded.presets;
      presetMethods.addAll(loaded.presetMethods);
      activePlanIdsByProfile[loaded.profileId] = loaded.activePlanIds;
    }

    if (!mounted || request != _loadRequest) return;
    setState(() {
      _appMethods = appMethods;
      _profiles = profiles;
      _profileMethods = profileMethods;
      _presetsByProfile = presetsByProfile;
      _presetMethods = presetMethods;
      _activePlanIdsByProfile = activePlanIdsByProfile;
      _isLoading = false;
    });
  }

  ActivePlanStore? _activePlanStoreOrNull() {
    try {
      return context.read<ActivePlanStore>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Future<void> _showAddEditDefault({
    required String scope,
    int? profileId,
    FlowMethod? existing,
  }) async {
    final isEdit = existing != null;
    final strings = AppLocalizations.of(context);
    final dialogTitle = isEdit
        ? (scope == 'app'
              ? strings.rulesEditAppDefault
              : strings.rulesEditProfileDefault)
        : (scope == 'app'
              ? strings.rulesAddAppDefault
              : strings.rulesAddProfileDefault);

    // Controllers
    final nameCtl = TextEditingController(text: existing?.name);
    MethodType type = existing?.type ?? MethodType.weight;
    String sign = existing?.params['sign'] as String? ?? '+';
    final factorCtl = TextEditingController(
      text: existing?.params['factor']?.toString() ?? '1.0',
    );
    final amountCtl = TextEditingController(
      text: existing?.params['amount']?.toString() ?? '0',
    );
    AddSetMode addMode =
        existing?.params.containsKey('copyFromSetIndex') == true
        ? AddSetMode.copy
        : AddSetMode.explicit;
    final weightCtl = TextEditingController(
      text: existing?.params['weight']?.toString() ?? '0.0',
    );
    final repsCtl = TextEditingController(
      text: existing?.params['reps']?.toString() ?? '0',
    );

    // Prepopulate copyIndex if editing an addSet method
    final copyIndex = existing != null && existing.type == MethodType.addSet
        ? (existing.params['copyFromSetIndex']?.toString() ?? '-1')
        : '-1';
    final copyIndexCtl = TextEditingController(text: copyIndex);

    final saved = await showTonosDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final expressive = ctx.usesExpressivePresentation;
          final fieldGap = expressive ? 8.0 : 12.0;
          final formContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TonosField(controller: nameCtl, labelText: strings.commonName),
              SizedBox(height: fieldGap),
              _FlowMethodsChoiceField<MethodType>(
                title: strings.rulesRuleTypeLabel,
                values: MethodType.values,
                value: type,
                label: (value) => _methodTypeLabel(value, strings),
                onChanged: (value) {
                  if (value != null) setSt(() => type = value);
                },
                nonExpressiveButton: () =>
                    TonosDialogDropdownButton<MethodType>(
                      value: type,
                      onChanged: (value) => setSt(() => type = value!),
                      items: MethodType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_methodTypeLabel(t, strings)),
                            ),
                          )
                          .toList(),
                    ),
              ),
              if (type == MethodType.weight) ...[
                SizedBox(height: fieldGap),
                _FlowMethodsChoiceField<String>(
                  title: strings.rulesOperationLabel,
                  values: const ['+', '-'],
                  value: sign,
                  label: (value) => value,
                  onChanged: (value) {
                    if (value != null) setSt(() => sign = value);
                  },
                  nonExpressiveButton: () => TonosDialogDropdownButton<String>(
                    value: sign,
                    onChanged: (value) => setSt(() => sign = value!),
                    items: const [
                      DropdownMenuItem(value: '+', child: Text('+')),
                      DropdownMenuItem(value: '-', child: Text('-')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TonosField(
                  controller: factorCtl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  labelText: strings.flowFactor,
                ),
              ] else if (type == MethodType.rep) ...[
                SizedBox(height: fieldGap),
                _FlowMethodsChoiceField<String>(
                  title: strings.rulesOperationLabel,
                  values: const ['+', '-'],
                  value: sign,
                  label: (value) => value,
                  onChanged: (value) {
                    if (value != null) setSt(() => sign = value);
                  },
                  nonExpressiveButton: () => TonosDialogDropdownButton<String>(
                    value: sign,
                    onChanged: (value) => setSt(() => sign = value!),
                    items: const [
                      DropdownMenuItem(value: '+', child: Text('+')),
                      DropdownMenuItem(value: '-', child: Text('-')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TonosField(
                  controller: amountCtl,
                  keyboardType: TextInputType.number,
                  labelText: strings.flowAmount,
                ),
              ] else if (type == MethodType.addSet) ...[
                SizedBox(height: fieldGap),
                _addSetModeOptions(
                  ctx,
                  selected: addMode,
                  onChanged: (value) => setSt(() => addMode = value),
                ),
                const SizedBox(height: 8),
                if (addMode == AddSetMode.explicit) ...[
                  TonosField(
                    controller: weightCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    labelText: strings.flowWeight,
                  ),
                  const SizedBox(height: 8),
                  TonosField(
                    controller: repsCtl,
                    keyboardType: TextInputType.number,
                    labelText: strings.flowReps,
                  ),
                ] else ...[
                  TonosField(
                    controller: copyIndexCtl,
                    keyboardType: TextInputType.number,
                    labelText: strings.rulesCopyIndex,
                  ),
                ],
              ] else if (type == MethodType.delSet) ...[
                SizedBox(height: fieldGap),
                Text(strings.rulesDeleteLastSetBody),
              ],
            ],
          );

          return TonosDialogFrame(
            styleFormControls: true,
            child: AlertDialog(
              scrollable: expressive,
              title: Text(dialogTitle),
              content: expressive
                  ? formContent
                  : SingleChildScrollView(child: formContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(strings.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(strings.commonSave),
                ),
              ],
            ),
          );
        },
      ),
    );

    final methodName = nameCtl.text.trim();
    final factor = double.tryParse(factorCtl.text) ?? 1.0;
    final amount = int.tryParse(amountCtl.text) ?? 0;
    final weight = double.tryParse(weightCtl.text) ?? 0.0;
    final reps = int.tryParse(repsCtl.text) ?? 0;
    final copyIndexValue = int.tryParse(copyIndexCtl.text) ?? -1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in [
        nameCtl,
        factorCtl,
        amountCtl,
        weightCtl,
        repsCtl,
        copyIndexCtl,
      ]) {
        controller.dispose();
      }
    });

    if (saved != true) {
      return;
    }
    if (!mounted) return;

    // build params
    final params = <String, dynamic>{};
    switch (type) {
      case MethodType.weight:
        params['sign'] = sign;
        params['factor'] = factor;
        break;
      case MethodType.rep:
        params['sign'] = sign;
        params['amount'] = amount;
        break;
      case MethodType.addSet:
        if (addMode == AddSetMode.explicit) {
          params['weight'] = weight;
          params['reps'] = reps;
        } else {
          params['copyFromSetIndex'] = copyIndexValue;
        }
        break;
      case MethodType.delSet:
        break;
    }
    if (methodName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.rulesNameRequired)));
      return;
    }

    await _repo.upsertDefaultFlowMethod(
      scope: scope,
      profileId: profileId,
      name: methodName,
      type: type,
      params: params,
    );
    if (existing != null && existing.name != methodName) {
      await _repo.renameDefaultFlowMethodReferences(
        scope: scope,
        profileId: profileId,
        oldName: existing.name,
        newName: methodName,
      );
      await _repo.deleteDefaultFlowMethod(
        scope: scope,
        profileId: profileId,
        name: existing.name,
      );
    }
    if (!isEdit && mounted) {
      await _offerRulePropagation(
        scope: scope,
        profileId: profileId,
        name: methodName,
        type: type,
        params: params,
      );
    }
    if (!mounted) return;
    await _loadAll();
  }

  Future<void> _offerRulePropagation({
    required String scope,
    required int? profileId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    final strings = AppLocalizations.of(context);
    final isAppDefault = scope == 'app';
    final destinationCount = isAppDefault
        ? _profiles.where((profile) => profile.id != null).length
        : profileId == null
        ? 0
        : (_presetsByProfile[profileId] ?? const []).length;
    if (destinationCount == 0 || (!isAppDefault && profileId == null)) return;

    final destinationLabel = isAppDefault
        ? strings.rulesProfilesLowercase
        : strings.rulesPlansLowercase;
    final confirmed = await showTonosDialog<bool>(
      context: context,
      builder: (dialogContext) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(strings.rulesAddToExistingTitle(destinationLabel)),
          content: Text(
            strings.rulesAddToExistingBody(
              name,
              destinationCount,
              destinationLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.rulesNotNow),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.rulesAddTo(destinationLabel)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final copied = isAppDefault
          ? await _repo.copyAppDefaultRuleToExistingProfiles(
              name: name,
              type: type,
              params: params,
            )
          : await _repo.copyProfileDefaultRuleToExistingPlans(
              profileId: profileId!,
              name: name,
              type: type,
              params: params,
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copied == 0
                ? strings.rulesNoExistingNeeded(destinationLabel)
                : strings.rulesCopiedMessage(name, copied, destinationLabel),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.rulesPropagationFailed)));
    }
  }

  Future<void> _showAddEditPresetMethod({
    required int presetId,
    FlowMethod? existing,
  }) async {
    final updated = await showTonosDialog<FlowMethod>(
      context: context,
      builder: (_) => TonosDialogFrame(
        styleFormControls: true,
        child: AddPresetMethodDialog(presetId: presetId, existing: existing),
      ),
    );
    if (updated == null) return;
    if (existing != null && existing.name != updated.name) {
      await _repo.renameFlowMethodReferences(
        presetId: presetId,
        oldName: existing.name,
        newName: updated.name,
      );
      await _repo.deleteFlowMethod(existing.id);
    }
    if (mounted) await _loadAll();
  }

  Widget _methodTile(
    FlowMethod m, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    Color? expressiveForeground,
  }) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final color = _methodTypeColor(m.type, context);
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final expressive = context.usesExpressivePresentation;
    final tileSurface = context.surfaceTokens.dialogChoice;
    final tileForeground = expressive
        ? expressiveForeground
        : neo
        ? tonosForegroundForSurface(context, tileSurface)
        : null;
    final tileSecondary = expressive
        ? expressiveForeground?.withValues(alpha: .82) ??
              Theme.of(context).colorScheme.onSurfaceVariant
        : neo
        ? tonosSecondaryForegroundForSurface(context, tileSurface)
        : color;
    final leadingColor = expressiveForeground ?? color;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: leadingColor.withValues(alpha: .16),
          borderRadius: shapes.settingsIcon,
        ),
        child: Icon(_methodTypeIcon(m.type), color: leadingColor, size: 21),
      ),
      title: Text(
        m.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: tileForeground,
        ),
      ),
      subtitle: Text(
        _methodTypeLabel(m.type, strings),
        style: theme.textTheme.bodySmall?.copyWith(color: tileSecondary),
      ),
      trailing: PopupMenuButton<_RuleAction>(
        popUpAnimationStyle: tonosOverlayMotion(context),
        tooltip: strings.rulesOptionsTooltip,
        shape: expressive
            ? RoundedRectangleBorder(borderRadius: ExpressiveTrainShapes.menu)
            : null,
        onSelected: (action) {
          if (action == _RuleAction.edit) {
            onEdit();
          } else {
            onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _RuleAction.edit,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined),
              title: Text(strings.commonEdit),
            ),
          ),
          PopupMenuItem(
            value: _RuleAction.delete,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline),
              title: Text(strings.commonDelete),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _ruleTiles(
    List<FlowMethod> methods, {
    required ValueChanged<FlowMethod> onEdit,
    required ValueChanged<FlowMethod> onDelete,
    Color? expressiveForeground,
  }) {
    return [
      for (var index = 0; index < methods.length; index++) ...[
        if (index > 0) const Divider(height: 1, indent: 68),
        _methodTile(
          methods[index],
          onEdit: () => onEdit(methods[index]),
          onDelete: () => onDelete(methods[index]),
          expressiveForeground: expressiveForeground,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.profile,
        child: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.profile,
      child: SettingsPageScaffold(
        title: strings.rulesPageTitle,
        subtitle: expressive
            ? strings.rulesPageSubtitleExpressive
            : strings.rulesPageSubtitle,
        icon: Icons.route_outlined,
        useExpressiveProfileHeroShape: true,
        children: [
          SettingsInfoCard(
            icon: Icons.copy_all_outlined,
            title: strings.rulesHowDefaultsTitle,
            body: expressive
                ? strings.rulesHowDefaultsBodyExpressive
                : strings.rulesHowDefaultsBody,
          ),
          const SizedBox(height: 14),
          if (!expressive) ...[
            _RuleScopeLegend(strings: strings),
            const SizedBox(height: 18),
          ],
          _RuleScopeCard(
            color: context.cs.primary,
            insetHeader: true,
            expressiveSurface: expressiveTokens?.surfacePrimary,
            expressiveForeground: expressiveTokens?.onSurfacePrimary,
            icon: Icons.apps_outlined,
            title: strings.rulesAppDefaultsTitle,
            subtitle: strings.rulesAppDefaultsSubtitle,
            count: _appMethods.length,
            initiallyExpanded: true,
            children: [
              if (_appMethods.isEmpty)
                _EmptyRuleState(
                  message: strings.rulesNoAppDefaults,
                  foregroundColor: expressiveTokens?.onSurfacePrimary,
                )
              else
                ..._ruleTiles(
                  _appMethods,
                  expressiveForeground: expressiveTokens?.onSurfacePrimary,
                  onEdit: (method) =>
                      _showAddEditDefault(scope: 'app', existing: method),
                  onDelete: (method) async {
                    await _repo.deleteDefaultFlowMethodAndReferences(
                      scope: 'app',
                      name: method.name,
                    );
                    if (!mounted) return;
                    await _loadAll();
                  },
                ),
              _AddRuleButton(
                color: context.cs.primary,
                label: strings.rulesAddApp,
                isAppDefault: true,
                onPressed: () => _showAddEditDefault(scope: 'app'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: strings.rulesGymProfilesTitle,
            subtitle: strings.rulesGymProfilesSubtitle,
          ),
          const SizedBox(height: 10),
          if (_profiles.isEmpty)
            _EmptyProfilesCard(message: strings.rulesNoProfiles)
          else
            for (
              var profileIndex = 0;
              profileIndex < _profiles.length;
              profileIndex++
            ) ...[
              Builder(
                builder: (context) {
                  final profile = _profiles[profileIndex];
                  final profileMethods =
                      _profileMethods[profile.id] ?? const [];
                  final presets = _presetsByProfile[profile.id] ?? const [];
                  final planRuleCount = presets.fold<int>(
                    0,
                    (total, preset) =>
                        total +
                        (_presetMethods[preset['id'] as int]?.length ?? 0),
                  );
                  final profileColor = _profileScopeColor(context);
                  final planColor = _planScopeColor(context);
                  final expressive = context.usesExpressivePresentation;
                  final expressiveTokens = expressive
                      ? AppExpressiveDestinationTokens.forFamily(
                          AppExpressiveDestinationFamily.profile,
                          Theme.of(context).brightness,
                        )
                      : null;
                  final activePlanIds = _activePlanIdsByProfile[profile.id];

                  Widget presetCard(Map<String, dynamic> preset) {
                    final presetId = preset['id'] as int;
                    final methods = _presetMethods[presetId] ?? const [];
                    return _RuleScopeCard(
                      color: planColor,
                      expressiveSurface: expressiveTokens?.surfaceAccent,
                      expressiveForeground: expressiveTokens?.onSurfaceAccent,
                      icon: Icons.event_note_outlined,
                      title: preset['name'] as String,
                      subtitle: expressive
                          ? strings.rulesPlanOnlySubtitleExpressive
                          : strings.rulesPlanOnlySubtitle,
                      count: methods.length,
                      compact: true,
                      children: [
                        if (methods.isEmpty)
                          _EmptyRuleState(
                            message: strings.rulesNoPlanRules,
                            foregroundColor: expressiveTokens?.onSurfaceAccent,
                          )
                        else
                          ..._ruleTiles(
                            methods,
                            expressiveForeground:
                                expressiveTokens?.onSurfaceAccent,
                            onEdit: (method) => _showAddEditPresetMethod(
                              presetId: presetId,
                              existing: method,
                            ),
                            onDelete: (method) async {
                              await _repo.deleteFlowMethodAndReferences(method);
                              if (!mounted) return;
                              await _loadAll();
                            },
                          ),
                        _AddRuleButton(
                          color: planColor,
                          label: strings.rulesAddPlan,
                          onPressed: () =>
                              _showAddEditPresetMethod(presetId: presetId),
                        ),
                      ],
                    );
                  }

                  List<Widget> planCardsFor(
                    List<Map<String, dynamic>> plans,
                  ) => [
                    for (var index = 0; index < plans.length; index++) ...[
                      presetCard(plans[index]),
                      if (index < plans.length - 1) const SizedBox(height: 8),
                    ],
                  ];

                  final activePlans = activePlanIds == null
                      ? const <Map<String, dynamic>>[]
                      : presets
                            .where(
                              (preset) =>
                                  activePlanIds.contains(preset['id'] as int),
                            )
                            .toList();
                  final archivedPlans = activePlanIds == null
                      ? const <Map<String, dynamic>>[]
                      : presets
                            .where(
                              (preset) =>
                                  !activePlanIds.contains(preset['id'] as int),
                            )
                            .toList();
                  final planContent = <Widget>[
                    if (presets.isEmpty)
                      _EmptyRuleState(
                        message: strings.rulesNoPlans,
                        foregroundColor: expressiveTokens?.onSurfaceSecondary,
                      )
                    else if (expressive && activePlanIds != null) ...[
                      if (activePlans.isNotEmpty) ...[
                        _PlanStatusHeading(
                          title: strings.trainActivePlans,
                          count: activePlans.length,
                          color: planColor,
                          foregroundColor: expressiveTokens?.onSurfaceSecondary,
                        ),
                        ...planCardsFor(activePlans),
                      ],
                      if (activePlans.isNotEmpty && archivedPlans.isNotEmpty)
                        const SizedBox(height: 12),
                      if (archivedPlans.isNotEmpty) ...[
                        _PlanStatusHeading(
                          title: strings.trainArchivedPlans,
                          count: archivedPlans.length,
                          color: planColor,
                          foregroundColor: expressiveTokens?.onSurfaceSecondary,
                        ),
                        ...planCardsFor(archivedPlans),
                      ],
                    ] else
                      ...planCardsFor(presets),
                  ];

                  return _RuleScopeCard(
                    color: profileColor,
                    insetHeader: true,
                    insetBodyPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                    headerBodySpacing: 12,
                    expressiveSurface: expressiveTokens?.surfaceSecondary,
                    expressiveForeground: expressiveTokens?.onSurfaceSecondary,
                    icon: Icons.fitness_center,
                    title: profile.name,
                    subtitle: strings.rulesProfileSummary(
                      profileMethods.length,
                      planRuleCount,
                    ),
                    count: profileMethods.length + planRuleCount,
                    semanticCountLabel: expressive
                        ? strings.rulesTotalCountSemantics(
                            profileMethods.length + planRuleCount,
                          )
                        : null,
                    initiallyExpanded: profileIndex == 0,
                    children: [
                      _RuleScopeCard(
                        color: profileColor,
                        expressiveSurface: expressiveTokens?.surfaceTertiary,
                        expressiveForeground:
                            expressiveTokens?.onSurfaceTertiary,
                        icon: Icons.tune,
                        title: strings.rulesProfileDefaultsTitle,
                        subtitle: expressive
                            ? strings.rulesProfileDefaultsSubtitleExpressive
                            : strings.rulesProfileDefaultsSubtitle,
                        count: profileMethods.length,
                        initiallyExpanded: true,
                        compact: true,
                        children: [
                          if (profileMethods.isEmpty)
                            _EmptyRuleState(
                              message: strings.rulesNoProfileDefaults,
                              foregroundColor:
                                  expressiveTokens?.onSurfaceTertiary,
                            )
                          else
                            ..._ruleTiles(
                              profileMethods,
                              expressiveForeground:
                                  expressiveTokens?.onSurfaceTertiary,
                              onEdit: (method) => _showAddEditDefault(
                                scope: 'profile',
                                profileId: profile.id,
                                existing: method,
                              ),
                              onDelete: (method) async {
                                await _repo
                                    .deleteDefaultFlowMethodAndReferences(
                                      scope: 'profile',
                                      profileId: profile.id,
                                      name: method.name,
                                    );
                                if (!mounted) return;
                                await _loadAll();
                              },
                            ),
                          _AddRuleButton(
                            color: profileColor,
                            label: strings.rulesAddProfile,
                            onPressed: () => _showAddEditDefault(
                              scope: 'profile',
                              profileId: profile.id,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _NestedHeading(
                          color: planColor,
                          icon: Icons.event_note_outlined,
                          title: strings.rulesPlansTitle,
                          count: presets.length,
                          expressiveForeground:
                              expressiveTokens?.onSurfaceSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...planContent,
                    ],
                  );
                },
              ),
              if (profileIndex < _profiles.length - 1)
                const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _LoadedProfileMethods {
  final int profileId;
  final List<FlowMethod> methods;
  final List<Map<String, dynamic>> presets;
  final Map<int, List<FlowMethod>> presetMethods;
  final Set<int>? activePlanIds;

  const _LoadedProfileMethods({
    required this.profileId,
    required this.methods,
    required this.presets,
    required this.presetMethods,
    required this.activePlanIds,
  });
}

enum _RuleAction { edit, delete }

Color _methodTypeColor(MethodType type, BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return switch (type) {
    MethodType.weight => scheme.primary,
    MethodType.rep => scheme.secondary,
    MethodType.addSet => context.flowTokens.addSetAction,
    MethodType.delSet => scheme.error,
  };
}

IconData _methodTypeIcon(MethodType type) {
  return switch (type) {
    MethodType.weight => Icons.fitness_center,
    MethodType.rep => Icons.repeat,
    MethodType.addSet => Icons.playlist_add,
    MethodType.delSet => Icons.playlist_remove,
  };
}

Color _profileScopeColor(BuildContext context) {
  return context.flowTokens.profileScope;
}

Color _planScopeColor(BuildContext context) {
  return context.flowTokens.planScope;
}

class _RuleScopeLegend extends StatelessWidget {
  final AppLocalizations strings;

  const _RuleScopeLegend({required this.strings});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SettingsLegendChip(
          color: scheme.primary,
          label: strings.rulesAppDefaultsChip,
        ),
        SettingsLegendChip(
          color: _profileScopeColor(context),
          label: strings.rulesProfilesChip,
        ),
        SettingsLegendChip(
          color: _planScopeColor(context),
          label: strings.rulesPlansChip,
        ),
      ],
    );
  }
}

class _RuleScopeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final bool initiallyExpanded;
  final bool compact;
  final bool insetHeader;
  final EdgeInsets insetBodyPadding;
  final double headerBodySpacing;
  final List<Widget> children;
  final Color? expressiveSurface;
  final Color? expressiveForeground;
  final String? semanticCountLabel;

  const _RuleScopeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    this.initiallyExpanded = false,
    this.compact = false,
    this.insetHeader = false,
    this.insetBodyPadding = EdgeInsets.zero,
    this.headerBodySpacing = 4,
    this.expressiveSurface,
    this.expressiveForeground,
    this.semanticCountLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final padding = compact ? 12.0 : 14.0;
    final surfaces = context.surfaceTokens;
    final expressive = context.usesExpressivePresentation;
    final neo = context.usesNeoPresentation;
    final cardSurface = expressive
        ? expressiveSurface ?? surfaces.settingsSection
        : neo
        ? surfaces.settingsSection
        : scheme.surfaceContainerHighest.withValues(alpha: compact ? .20 : .28);
    final cardForeground = expressive
        ? expressiveForeground ?? scheme.onSurface
        : neo
        ? tonosForegroundForSurface(context, cardSurface)
        : scheme.onSurface;
    final cardSecondary = expressive
        ? cardForeground.withValues(alpha: .82)
        : neo
        ? tonosSecondaryForegroundForSurface(context, cardSurface)
        : scheme.onSurfaceVariant;
    final cardRadius = expressive
        ? compact
              ? ExpressiveTrainShapes.compactControl
              : ExpressiveTrainShapes.activePlans
        : compact
        ? shapes.profileTile
        : shapes.settingsPanel;
    final leadingForeground = expressive || neo ? cardForeground : color;
    final leadingSurface = expressive
        ? leadingForeground.withValues(alpha: .14)
        : color.withValues(alpha: .17);
    final titleStyle =
        (compact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)
            ?.copyWith(
              fontWeight: FontWeight.w900,
              color: neo || expressive ? cardForeground : null,
            );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: cardSecondary,
    );
    final badge = expressive
        ? _ExpressiveRuleCountBadge(
            count: count,
            label:
                semanticCountLabel ??
                AppLocalizations.of(context).rulesCountSemantics(count),
          )
        : SettingsCountBadge(count: count, color: color);
    final leading = Container(
      width: compact ? 38 : 42,
      height: compact ? 38 : 42,
      decoration: BoxDecoration(
        color: leadingSurface,
        borderRadius: expressive
            ? ExpressiveTrainShapes.focusInset
            : compact
            ? shapes.control
            : shapes.settingsScopeIcon,
      ),
      child: Icon(icon, color: leadingForeground, size: compact ? 20 : 22),
    );
    final expressiveTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 2),
        Text(subtitle, style: subtitleStyle),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: cardRadius,
        border: expressive
            ? null
            : Border.all(
                color: neo
                    ? tonosOutlineForSurface(context, cardSurface)
                    : color.withValues(alpha: compact ? .36 : .52),
                width: shapes.outlineWidth,
              ),
      ),
      child: TonosSurfaceTheme(
        surface: cardSurface,
        child: expressive && insetHeader
            ? TonosExpressiveInsetAccordion(
                surface: cardSurface,
                foreground: cardForeground,
                outline: cardForeground.withValues(alpha: .38),
                borderRadius: cardRadius,
                initiallyExpanded: initiallyExpanded,
                childrenPadding: insetBodyPadding,
                headerBodySpacing: headerBodySpacing,
                tilePadding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 3,
                ),
                leading: leading,
                title: expressiveTitle,
                trailingPrefix: badge,
                iconColor: cardSecondary,
                children: children,
              )
            : ExpansionTile(
                initiallyExpanded: initiallyExpanded,
                iconColor: cardForeground,
                collapsedIconColor: cardForeground,
                tilePadding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 3,
                ),
                childrenPadding: EdgeInsets.zero,
                collapsedBackgroundColor: neo || expressive
                    ? cardSurface
                    : color.withValues(alpha: compact ? .05 : .08),
                backgroundColor: neo || expressive
                    ? cardSurface
                    : color.withValues(alpha: .04),
                leading: leading,
                title: expressive
                    ? expressiveTitle
                    : Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                subtitle: expressive
                    ? null
                    : Text(
                        subtitle,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                trailing: expressive
                    ? _RuleScopeTrailing(badge: badge, color: cardSecondary)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          badge,
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more, color: cardSecondary),
                        ],
                      ),
                children: children,
              ),
      ),
    );
  }
}

class _RuleScopeTrailing extends StatelessWidget {
  const _RuleScopeTrailing({required this.badge, required this.color});

  final Widget badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final controller = ExpansibleController.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: controller.isExpanded ? .5 : 0,
            duration: TonosExpressiveStateMotion.duration(
              context,
              TonosExpressiveStateMotion.standard,
            ),
            curve: TonosExpressiveStateMotion.spatial,
            child: Icon(Icons.expand_more, color: color),
          ),
        ],
      ),
    );
  }
}

class _ExpressiveRuleCountBadge extends StatelessWidget {
  const _ExpressiveRuleCountBadge({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      Theme.of(context).brightness,
    );
    final light = Theme.of(context).brightness == Brightness.light;
    final surface = light ? tokens.surfaceSelected : tokens.actionPrimary;
    final foreground = light
        ? tokens.onSurfaceSelected
        : tokens.onActionPrimary;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minWidth: 28),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: context.shapeTokens.pill,
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: .72),
              width: .75,
            ),
          ),
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ExpressivePlanCountBadge extends StatelessWidget {
  const _ExpressivePlanCountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      Theme.of(context).brightness,
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minWidth: 28),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .22),
            borderRadius: context.shapeTokens.pill,
            border: Border.all(color: color.withValues(alpha: .72), width: .75),
          ),
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tokens.onSurfaceTertiary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _profileScopeColor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.fitness_center_outlined, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _NestedHeading extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final int count;
  final Color? expressiveForeground;

  const _NestedHeading({
    required this.color,
    required this.icon,
    required this.title,
    required this.count,
    this.expressiveForeground,
  });

  @override
  Widget build(BuildContext context) {
    final expressive = context.usesExpressivePresentation;
    final neo = context.usesNeoPresentation;
    final strings = AppLocalizations.of(context);
    final foreground = expressive
        ? expressiveForeground ?? Theme.of(context).colorScheme.onSurface
        : neo
        ? tonosForegroundForSurface(
            context,
            context.surfaceTokens.settingsSection,
          )
        : color;
    return Row(
      children: [
        Icon(icon, color: foreground, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w900),
          ),
        ),
        expressive
            ? _ExpressivePlanCountBadge(
                count: count,
                color: color,
                label: strings.rulesPlanCountSemantics(count),
              )
            : SettingsCountBadge(count: count, color: color),
      ],
    );
  }
}

class _PlanStatusHeading extends StatelessWidget {
  const _PlanStatusHeading({
    required this.title,
    required this.count,
    required this.color,
    this.foregroundColor,
  });

  final String title;
  final int count;
  final Color color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor ?? color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _ExpressivePlanCountBadge(
            count: count,
            color: color,
            label: strings.rulesPlanCountSemantics(count),
          ),
        ],
      ),
    );
  }
}

class _EmptyRuleState extends StatelessWidget {
  final String message;
  final Color? foregroundColor;

  const _EmptyRuleState({required this.message, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expressive = context.usesExpressivePresentation;
    final neo = context.usesNeoPresentation;
    final surface = context.surfaceTokens.settingsSection;
    final foreground =
        foregroundColor ??
        (neo
            ? tonosForegroundForSurface(context, surface)
            : expressive
            ? AppExpressiveDestinationTokens.forFamily(
                AppExpressiveDestinationFamily.profile,
                Theme.of(context).brightness,
              ).supportingForeground
            : scheme.onSurfaceVariant);
    final secondary =
        foregroundColor ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, surface)
            : expressive
            ? AppExpressiveDestinationTokens.forFamily(
                AppExpressiveDestinationFamily.profile,
                Theme.of(context).brightness,
              ).supportingForeground
            : scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRuleButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onPressed;
  final bool isAppDefault;

  const _AddRuleButton({
    required this.color,
    required this.label,
    required this.onPressed,
    this.isAppDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final expressive = context.usesExpressivePresentation;
    final neo = context.usesNeoPresentation;
    final lightExpressiveAppDefault =
        expressive &&
        isAppDefault &&
        Theme.of(context).brightness == Brightness.light;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    final shapes = context.shapeTokens;
    final actionForeground = neo
        ? tonosForegroundForSurface(context, color)
        : color;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: expressive
              ? OutlinedButton.styleFrom(
                  backgroundColor: lightExpressiveAppDefault
                      ? expressiveTokens!.surfaceSelected
                      : expressiveTokens!.actionPrimary,
                  foregroundColor: lightExpressiveAppDefault
                      ? expressiveTokens.onSurfaceSelected
                      : expressiveTokens.onActionPrimary,
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: ExpressiveTrainShapes.compactControl,
                  ),
                )
              : neo
              ? OutlinedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: actionForeground,
                  disabledBackgroundColor: color.withValues(alpha: .42),
                  disabledForegroundColor: actionForeground.withValues(
                    alpha: .72,
                  ),
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: BorderSide(
                    color: tonosOutlineForSurface(context, color),
                    width: shapes.outlineWidth,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: shapes.settingsAction,
                  ),
                )
              : OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: .55)),
                ),
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 19),
          label: Text(label),
        ),
      ),
    );
  }
}

class _EmptyProfilesCard extends StatelessWidget {
  final String message;

  const _EmptyProfilesCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shapes = context.shapeTokens;
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    final neo = context.usesNeoPresentation;
    final surface = neo ? context.surfaceTokens.settingsSection : null;
    final secondary = neo && surface != null
        ? tonosSecondaryForegroundForSurface(context, surface)
        : expressive
        ? expressiveTokens!.onSurfaceTertiary
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: expressive
            ? expressiveTokens!.surfaceTertiary
            : neo
            ? surface
            : scheme.surfaceContainerHighest.withValues(alpha: .28),
        borderRadius: shapes.settingsPanel,
        border: expressive
            ? null
            : Border.all(
                color: neo
                    ? tonosOutlineForSurface(context, surface!)
                    : scheme.outlineVariant,
                width: neo ? shapes.outlineWidth : 1,
              ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: secondary),
        child: _EmptyRuleState(
          message: message,
          foregroundColor: expressiveTokens?.onSurfaceTertiary,
        ),
      ),
    );
  }
}

String _methodTypeLabel(MethodType type, AppLocalizations strings) {
  return switch (type) {
    MethodType.weight => strings.flowMethodWeight,
    MethodType.rep => strings.flowMethodReps,
    MethodType.addSet => strings.flowMethodAddSet,
    MethodType.delSet => strings.flowMethodDeleteSet,
  };
}

/// Field-anchored single-choice menu scoped to the Expressive Flow Methods
/// dialogs. Classic and Neo continue using their existing dropdown controls.
class _FlowMethodsChoiceField<T> extends StatefulWidget {
  const _FlowMethodsChoiceField({
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.onChanged,
    required this.nonExpressiveButton,
    this.planRuleStyle = false,
    this.scrollFieldIntoUpperArea = false,
  });

  final String title;
  final List<T> values;
  final T value;
  final String Function(T value) label;
  final ValueChanged<T?>? onChanged;
  final Widget Function() nonExpressiveButton;
  final bool planRuleStyle;
  final bool scrollFieldIntoUpperArea;

  @override
  State<_FlowMethodsChoiceField<T>> createState() =>
      _FlowMethodsChoiceFieldState<T>();
}

class _FlowMethodsChoiceFieldState<T>
    extends State<_FlowMethodsChoiceField<T>> {
  final GlobalKey _fieldKey = GlobalKey(debugLabel: 'Flow Methods choice');
  late final FocusNode _focusNode;
  bool _menuOpen = false;
  bool _fieldWidthMeasurementScheduled = false;
  double? _fieldWidth;
  double? _menuHeight;
  double _menuOffset = 0;

  Rect? _globalBounds(GlobalKey? key) {
    final renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  Future<void> _toggleMenu(MenuController controller) async {
    if (controller.isOpen) {
      controller.close();
      return;
    }
    if (!widget.planRuleStyle) {
      controller.open();
      return;
    }

    if (widget.scrollFieldIntoUpperArea) {
      final fieldContext = _fieldKey.currentContext;
      if (fieldContext != null) {
        await Scrollable.ensureVisible(
          fieldContext,
          alignment: 0.2,
          duration: Duration.zero,
        );
        await WidgetsBinding.instance.endOfFrame;
      }
      if (!mounted) return;
    }

    final field = _globalBounds(_fieldKey);
    if (field == null) return;
    final media = MediaQuery.of(context);
    final bottom =
        media.size.height - media.padding.bottom - media.viewInsets.bottom - 12;
    final below = math.max(0.0, bottom - field.bottom - 4);
    final style = Theme.of(context).textTheme.bodyLarge!
        .copyWith(fontWeight: FontWeight.w600);
    var desiredHeight = 14.0;
    for (final value in widget.values) {
      final painter = TextPainter(
        text: TextSpan(text: widget.label(value), style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 2,
      )..layout(maxWidth: math.max(1, field.width - 72));
      desiredHeight += math.max(48.0, painter.height + 8);
      painter.dispose();
    }
    final height = math.min(desiredHeight, below);
    setState(() {
      _fieldWidth = field.width;
      _menuHeight = height;
      _menuOffset = 4;
    });
    // MenuAnchor reads the new bounds before its overlay is inserted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.open();
    });
  }

  double? _renderedFieldWidth() {
    final renderObject = _fieldKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }
    return null;
  }

  void _scheduleFieldWidthMeasurement() {
    if (_fieldWidthMeasurementScheduled) return;
    _fieldWidthMeasurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fieldWidthMeasurementScheduled = false;
      if (!mounted) return;
      final width = _renderedFieldWidth();
      if (width == null ||
          (_fieldWidth != null && (_fieldWidth! - width).abs() < 0.5)) {
        return;
      }
      setState(() => _fieldWidth = width);
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Workout progress rule choice');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.usesExpressivePresentation) {
      return widget.nonExpressiveButton();
    }

    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final enabled = widget.onChanged != null && widget.values.isNotEmpty;
    final valueLabel = widget.label(widget.value);
    final decorationTheme = theme.inputDecorationTheme;
    final fieldBorder =
        decorationTheme.enabledBorder ??
        decorationTheme.border ??
        decorationTheme.focusedBorder;
    final fieldRadius = fieldBorder is OutlineInputBorder
        ? fieldBorder.borderRadius
        : context.shapeTokens.settingsInput;
    final screenSize = MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final dialogInsets =
        theme.dialogTheme.insetPadding ??
        const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    final configuredDialogMaxWidth =
        theme.dialogTheme.constraints?.maxWidth ?? 560.0;
    final dialogMaxWidth = configuredDialogMaxWidth.isFinite
        ? configuredDialogMaxWidth
        : screenSize.width - dialogInsets.horizontal;
    final fallbackWidth = math.max(
      0.0,
      math.min(
        screenSize.width -
            mediaQuery.padding.horizontal -
            dialogInsets.horizontal -
            48,
        dialogMaxWidth - 48,
      ),
    );
    final viewportMenuMaxHeight = math.max(
      0.0,
      screenSize.height -
          mediaQuery.padding.vertical -
          mediaQuery.viewInsets.vertical -
          dialogInsets.vertical * 2,
    );
    final menuMaxHeight = widget.planRuleStyle
        ? math.min(_menuHeight ?? 206, viewportMenuMaxHeight)
        : viewportMenuMaxHeight;
    _scheduleFieldWidthMeasurement();
    final width = _fieldWidth ?? fallbackWidth;

    return MenuAnchor(
      key: ValueKey<String>('rules-choice-${widget.title}'),
      useRootOverlay: true,
      consumeOutsideTap: true,
      crossAxisUnconstrained: false,
      childFocusNode: _focusNode,
      alignmentOffset: Offset(0, widget.planRuleStyle ? _menuOffset : 0),
      onOpen: () {
        final fieldWidth = _renderedFieldWidth();
        if (mounted) {
          setState(() {
            _menuOpen = true;
            if (fieldWidth != null) _fieldWidth = fieldWidth;
          });
        }
      },
      onClose: () {
        if (mounted) setState(() => _menuOpen = false);
      },
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        backgroundColor: WidgetStatePropertyAll(tokens.surfaceTertiary),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(2),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: widget.planRuleStyle
                ? tokens.outlineAccent.withValues(alpha: 0.5)
                : tokens.outlineAccent,
            width: 1,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: ExpressiveTrainShapes.focusInset,
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        maximumSize: WidgetStatePropertyAll(Size(width, menuMaxHeight)),
      ),
      menuChildren: [
        TonosExpressiveReveal(
          enabled: TonosExpressiveStateMotion.enabled(context),
          duration: const Duration(milliseconds: 160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < widget.values.length; index++)
                _menuItem(context, tokens, index),
            ],
          ),
        ),
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
          value: valueLabel,
          onTap: enabled ? () => unawaited(_toggleMenu(controller)) : null,
          child: ExcludeSemantics(
            child: InkWell(
              focusNode: _focusNode,
              canRequestFocus: enabled,
              borderRadius: fieldRadius,
              onTap: enabled ? () => unawaited(_toggleMenu(controller)) : null,
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (_) {
                  _scheduleFieldWidthMeasurement();
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: InputDecorator(
                    key: _fieldKey,
                    decoration: InputDecoration(
                      labelText: widget.planRuleStyle ? null : widget.title,
                      enabled: enabled,
                      suffixIcon: AnimatedRotation(
                        turns: widget.planRuleStyle && _menuOpen ? 0.5 : 0,
                        duration: TonosExpressiveStateMotion.duration(
                          context,
                          TonosExpressiveStateMotion.fast,
                        ),
                        curve: TonosExpressiveStateMotion.spatial,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: tokens.supportingForeground,
                        ),
                      ),
                    ),
                    isFocused: _focusNode.hasFocus || _menuOpen,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TonosExpressiveChangePulse(
                        value: widget.value,
                        scale: 1.015,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          valueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
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
  }

  Widget _menuItem(
    BuildContext context,
    AppExpressiveDestinationTokens tokens,
    int index,
  ) {
    final value = widget.values[index];
    final selected = value == widget.value;
    final foreground = selected
        ? tokens.onSurfaceSelected
        : tokens.onSurfaceTertiary;
    final background = selected
        ? tokens.surfaceSelected
        : tokens.surfaceTertiary;
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: MenuItemButton(
          key: ValueKey<int>(index),
          onPressed: () => widget.onChanged?.call(value),
          style: ButtonStyle(
            alignment: AlignmentDirectional.centerStart,
            foregroundColor: WidgetStatePropertyAll(foreground),
            backgroundColor: WidgetStatePropertyAll(background),
            minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            tapTargetSize: widget.planRuleStyle
                ? MaterialTapTargetSize.shrinkWrap
                : null,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.focusInset,
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: foreground,
                fontWeight: selected && !widget.planRuleStyle
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
          trailingIcon: widget.planRuleStyle
              ? SizedBox(
                  width: 20,
                  child: selected
                      ? Icon(Icons.check, size: 18, color: foreground)
                      : null,
                )
              : selected
              ? Icon(Icons.check, color: foreground)
              : null,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.label(value),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding or editing a workout progress rule on a plan.
class AddPresetMethodDialog extends StatefulWidget {
  final int presetId;
  final FlowMethod? existing;
  const AddPresetMethodDialog({
    super.key,
    required this.presetId,
    this.existing,
  });

  @override
  AddPresetMethodDialogState createState() => AddPresetMethodDialogState();
}

class AddPresetMethodDialogState extends State<AddPresetMethodDialog> {
  AppRepository get _repo => context.read<AppRepository>();

  bool _nameEdited = false;
  late TextEditingController _nameCtl;
  late MethodType _type;
  late String _sign;
  late TextEditingController _factorCtl;
  late TextEditingController _amountCtl;
  AddSetMode _addMode = AddSetMode.explicit;
  late TextEditingController _weightCtl;
  late TextEditingController _repsCtl;
  late TextEditingController _copyIndexCtl;
  late TextEditingController _copySetNumberCtl;
  late _CopySetSource _copySource;
  bool _copyNumberEdited = false;

  int? get _copySetNumber => int.tryParse(_copySetNumberCtl.text.trim());

  bool get _copySetNumberIsValid => (_copySetNumber ?? 0) >= 1;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _nameCtl = TextEditingController(text: ex?.name);
    _type = ex?.type ?? MethodType.weight;
    _sign = ex?.params['sign'] as String? ?? '+';
    _factorCtl = TextEditingController(text: ex?.params['factor']?.toString());
    _amountCtl = TextEditingController(text: ex?.params['amount']?.toString());
    _addMode = ex?.params.containsKey('copyFromSetIndex') == true
        ? AddSetMode.copy
        : AddSetMode.explicit;
    _weightCtl = TextEditingController(text: ex?.params['weight']?.toString());
    _repsCtl = TextEditingController(text: ex?.params['reps']?.toString());
    _copyIndexCtl = TextEditingController(
      text: ex?.params['copyFromSetIndex']?.toString() ?? '-1',
    );
    final copyIndex = (ex?.params['copyFromSetIndex'] as num?)?.toInt() ?? -1;
    _copySource = copyIndex < 0
        ? _CopySetSource.last
        : copyIndex == 0
        ? _CopySetSource.first
        : _CopySetSource.specific;
    _copySetNumberCtl = TextEditingController(
      text: copyIndex >= 0 ? '${copyIndex + 1}' : '',
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _factorCtl.dispose();
    _amountCtl.dispose();
    _weightCtl.dispose();
    _repsCtl.dispose();
    _copyIndexCtl.dispose();
    _copySetNumberCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    if (expressive) return _buildExpressiveDialog(strings);
    final fieldGap = expressive ? 8.0 : 12.0;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosField(controller: _nameCtl, labelText: strings.commonName),
        SizedBox(height: fieldGap),
        _FlowMethodsChoiceField<MethodType>(
          title: strings.rulesRuleTypeLabel,
          values: MethodType.values,
          value: _type,
          label: (value) => _methodTypeLabel(value, strings),
          onChanged: (value) {
            if (value != null) setState(() => _type = value);
          },
          nonExpressiveButton: () => TonosDialogDropdownButton<MethodType>(
            value: _type,
            onChanged: (value) => setState(() => _type = value!),
            items: MethodType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(_methodTypeLabel(t, strings)),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: fieldGap),
        if (_type == MethodType.weight) ...[
          _FlowMethodsChoiceField<String>(
            title: strings.rulesOperationLabel,
            values: const ['+', '-'],
            value: _sign,
            label: (value) => value,
            onChanged: (value) {
              if (value != null) setState(() => _sign = value);
            },
            nonExpressiveButton: () => TonosDialogDropdownButton<String>(
              value: _sign,
              onChanged: (value) => setState(() => _sign = value!),
              items: const [
                DropdownMenuItem(value: '+', child: Text('+')),
                DropdownMenuItem(value: '-', child: Text('-')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TonosField(
            controller: _factorCtl,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            labelText: strings.flowFactor,
          ),
        ] else if (_type == MethodType.rep) ...[
          _FlowMethodsChoiceField<String>(
            title: strings.rulesOperationLabel,
            values: const ['+', '-'],
            value: _sign,
            label: (value) => value,
            onChanged: (value) {
              if (value != null) setState(() => _sign = value);
            },
            nonExpressiveButton: () => TonosDialogDropdownButton<String>(
              value: _sign,
              onChanged: (value) => setState(() => _sign = value!),
              items: const [
                DropdownMenuItem(value: '+', child: Text('+')),
                DropdownMenuItem(value: '-', child: Text('-')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TonosField(
            controller: _amountCtl,
            keyboardType: TextInputType.number,
            labelText: strings.flowAmount,
          ),
        ] else if (_type == MethodType.addSet) ...[
          _addSetModeOptions(
            context,
            selected: _addMode,
            onChanged: (value) => setState(() => _addMode = value),
          ),
          const SizedBox(height: 8),
          if (_addMode == AddSetMode.explicit) ...[
            TonosField(
              controller: _weightCtl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              labelText: strings.flowWeight,
            ),
            const SizedBox(height: 8),
            TonosField(
              controller: _repsCtl,
              keyboardType: TextInputType.number,
              labelText: strings.flowReps,
            ),
          ] else ...[
            TonosField(
              controller: _copyIndexCtl,
              keyboardType: TextInputType.number,
              labelText: strings.rulesCopyIndex,
            ),
          ],
        ] else if (_type == MethodType.delSet) ...[
          Text(strings.rulesDeleteLastSetBody),
        ],
      ],
    );
    return AlertDialog(
      scrollable: expressive,
      title: Text(isEdit ? strings.rulesEditPlan : strings.rulesAddPlanTitle),
      content: expressive ? content : SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.commonCancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(strings.commonSave)),
      ],
    );
  }

  Widget _buildExpressiveDialog(AppLocalizations strings) {
    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final fieldSurface = Color.alphaBlend(
      tokens.pageCanvas.withValues(alpha: 0.5),
      tokens.surfaceTertiary,
    );
    final outline = tokens.outlineAccent.withValues(alpha: 0.45);
    const radius = BorderRadius.all(Radius.circular(18));
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? tokens.surfaceTertiary
            : fieldSurface,
      ),
      constraints: const BoxConstraints(minHeight: 52),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(outline),
      enabledBorder: border(outline),
      focusedBorder: border(tokens.actionPrimary, 2),
      disabledBorder: border(tokens.outlineAccent.withValues(alpha: 0.22)),
      errorBorder: border(theme.colorScheme.error),
      focusedErrorBorder: border(theme.colorScheme.error, 2),
      errorMaxLines: 3,
    );
    Widget field(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: tokens.onSurfaceTertiary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
    Widget numberField(
      String label,
      TextEditingController controller, {
      bool decimal = false,
      String? helperText,
      String? errorText,
      ValueChanged<String>? onChanged,
    }) => field(
      label,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TonosField(
            controller: controller,
            semanticLabel: label,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            textInputAction: TextInputAction.done,
            errorText: errorText,
            onChanged: onChanged,
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.supportingForeground,
              ),
            ),
          ],
        ],
      ),
    );
    Widget operationField() => field(
      strings.rulesOperationLabel,
      _FlowMethodsChoiceField<String>(
        title: strings.rulesOperationLabel,
        values: const ['+', '-'],
        value: _sign,
        label: (value) => value == '+'
            ? '+  ${strings.commonAdd}'
            : '−  ${strings.rulesOperationSubtract}',
        onChanged: (value) {
          if (value != null) setState(() => _sign = value);
        },
        planRuleStyle: true,
        scrollFieldIntoUpperArea: true,
        nonExpressiveButton: () => const SizedBox.shrink(),
      ),
    );
    final disabledSurface = Color.alphaBlend(
      tokens.actionPrimary.withValues(alpha: 0.12),
      tokens.surfaceTertiary,
    );
    final disabledForeground = Color.alphaBlend(
      tokens.onSurfaceTertiary.withValues(alpha: 0.6),
      disabledSurface,
    );
    final nameIsEmpty = _nameCtl.text.trim().isEmpty;
    final copyNumberIsInvalid =
        _type == MethodType.addSet &&
        _addMode == AddSetMode.copy &&
        _copySource == _CopySetSource.specific &&
        !_copySetNumberIsValid;

    return Theme(
      data: theme.copyWith(inputDecorationTheme: inputTheme),
      child: AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints(maxWidth: 440),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actionsOverflowButtonSpacing: 8,
        title: Text(
          widget.existing == null
              ? strings.rulesAddPlanTitle
              : strings.rulesEditPlan,
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field(
                strings.commonName,
                TonosField(
                  controller: _nameCtl,
                  semanticLabel: strings.commonName,
                  textInputAction: TextInputAction.next,
                  errorText: _nameEdited && nameIsEmpty
                      ? strings.rulesNameRequired
                      : null,
                  onChanged: (_) => setState(() => _nameEdited = true),
                ),
              ),
              const SizedBox(height: 16),
              field(
                strings.rulesRuleTypeLabel,
                _FlowMethodsChoiceField<MethodType>(
                  title: strings.rulesRuleTypeLabel,
                  values: MethodType.values,
                  value: _type,
                  label: (value) => _methodTypeLabel(value, strings),
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                  planRuleStyle: true,
                  nonExpressiveButton: () => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
              if (_type == MethodType.weight) ...[
                operationField(),
                const SizedBox(height: 16),
                numberField(
                  strings.flowFactor,
                  _factorCtl,
                  decimal: true,
                  helperText: strings.rulesFactorHelper,
                ),
              ] else if (_type == MethodType.rep) ...[
                operationField(),
                const SizedBox(height: 16),
                numberField(
                  strings.flowAmount,
                  _amountCtl,
                  helperText: strings.rulesAmountHelper,
                ),
              ] else if (_type == MethodType.addSet) ...[
                _addSetModeOptions(
                  context,
                  selected: _addMode,
                  onChanged: (value) => setState(() => _addMode = value),
                  expressiveSelectionGroup: true,
                ),
                const SizedBox(height: 16),
                if (_addMode == AddSetMode.explicit) ...[
                  numberField(strings.flowWeight, _weightCtl, decimal: true),
                  const SizedBox(height: 16),
                  numberField(strings.flowReps, _repsCtl),
                ] else ...[
                  field(
                    strings.rulesCopyFromLabel,
                    _FlowMethodsChoiceField<_CopySetSource>(
                      title: strings.rulesCopyFromLabel,
                      values: _CopySetSource.values,
                      value: _copySource,
                      label: (value) => switch (value) {
                        _CopySetSource.last => strings.rulesCopyFromLastSet,
                        _CopySetSource.first => strings.rulesCopyFromFirstSet,
                        _CopySetSource.specific =>
                          strings.rulesCopyFromSpecificSet,
                      },
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _copySource = value);
                        }
                      },
                      planRuleStyle: true,
                      scrollFieldIntoUpperArea: true,
                      nonExpressiveButton: () => const SizedBox.shrink(),
                    ),
                  ),
                  if (_copySource == _CopySetSource.specific) ...[
                    const SizedBox(height: 16),
                    numberField(
                      strings.rulesCopySetNumberLabel,
                      _copySetNumberCtl,
                      helperText: strings.rulesCopySpecificHelper,
                      errorText: _copyNumberEdited && copyNumberIsInvalid
                          ? strings.rulesCopySetNumberInvalid
                          : null,
                      onChanged: (_) =>
                          setState(() => _copyNumberEdited = true),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      _copySource == _CopySetSource.last
                          ? strings.rulesCopyFromLastHelper
                          : strings.rulesCopyFromFirstHelper,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.supportingForeground,
                      ),
                    ),
                  ],
                ],
              ] else
                Text(
                  strings.rulesDeleteLastSetBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.onSurfaceTertiary,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.onSurfaceTertiary,
              side: BorderSide(color: outline),
              minimumSize: const Size(88, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.compactControl,
              ),
            ),
            child: Text(strings.commonCancel),
          ),
          FilledButton(
            onPressed: nameIsEmpty || copyNumberIsInvalid ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: tokens.actionPrimary,
              foregroundColor: tokens.onActionPrimary,
              disabledBackgroundColor: disabledSurface,
              disabledForegroundColor: disabledForeground,
              minimumSize: const Size(88, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.compactControl,
              ),
            ),
            child: Text(strings.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.rulesNameRequired)));
      return;
    }
    final expressiveCopy =
        context.usesExpressivePresentation &&
        _type == MethodType.addSet &&
        _addMode == AddSetMode.copy;
    if (expressiveCopy &&
        _copySource == _CopySetSource.specific &&
        !_copySetNumberIsValid) {
      setState(() => _copyNumberEdited = true);
      return;
    }
    final params = <String, dynamic>{};
    switch (_type) {
      case MethodType.weight:
        params['sign'] = _sign;
        params['factor'] = double.tryParse(_factorCtl.text) ?? 1.0;
        break;
      case MethodType.rep:
        params['sign'] = _sign;
        params['amount'] = int.tryParse(_amountCtl.text) ?? 0;
        break;
      case MethodType.addSet:
        if (_addMode == AddSetMode.explicit) {
          params['weight'] = double.tryParse(_weightCtl.text) ?? 0.0;
          params['reps'] = int.tryParse(_repsCtl.text) ?? 0;
        } else {
          params['copyFromSetIndex'] = expressiveCopy
              ? switch (_copySource) {
                  _CopySetSource.last => -1,
                  _CopySetSource.first => 0,
                  _CopySetSource.specific => _copySetNumber! - 1,
                }
              : int.tryParse(_copyIndexCtl.text) ?? -1;
        }
        break;
      case MethodType.delSet:
        break;
    }
    await _repo.upsertFlowMethod(
      presetId: widget.presetId,
      name: name,
      type: _type,
      params: params,
    );
    if (!mounted) return;
    navigator.pop(
      FlowMethod(
        id: -1,
        presetId: widget.presetId,
        name: name,
        type: _type,
        params: params,
      ),
    );
  }
}
