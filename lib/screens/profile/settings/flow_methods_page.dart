// File: lib/screens/profile/settings/flow_methods_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/preset_models.dart';
import '../../../models/gym_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../theme/theme_extensions.dart';
import '../../../widgets/settings_tiles.dart';

/// Same enum as in auto_preset_flow_screen.dart
enum AddSetMode { explicit, copy }

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
  int _loadRequest = 0;
  List<FlowMethod> _appMethods = [];
  List<GymProfile> _profiles = [];

  Map<int, List<FlowMethod>> _profileMethods = {};
  Map<int, List<Map<String, dynamic>>> _presetsByProfile = {};
  Map<int, List<FlowMethod>> _presetMethods = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    final request = ++_loadRequest;
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
        return _LoadedProfileMethods(
          profileId: profileId,
          methods: methods,
          presets: presets,
          presetMethods: Map.fromEntries(loadedPresets),
        );
      }),
    );

    final profileMethods = <int, List<FlowMethod>>{};
    final presetsByProfile = <int, List<Map<String, dynamic>>>{};
    final presetMethods = <int, List<FlowMethod>>{};

    for (final loaded in loadedProfiles) {
      profileMethods[loaded.profileId] = loaded.methods;
      presetsByProfile[loaded.profileId] = loaded.presets;
      presetMethods.addAll(loaded.presetMethods);
    }

    if (!mounted || request != _loadRequest) return;
    setState(() {
      _appMethods = appMethods;
      _profiles = profiles;
      _profileMethods = profileMethods;
      _presetsByProfile = presetsByProfile;
      _presetMethods = presetMethods;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDefault({
    required String scope,
    int? profileId,
    FlowMethod? existing,
  }) async {
    final isEdit = existing != null;
    final strings = AppLocalizations.of(context);
    final dialogTitle =
        isEdit
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
    final copyIndex =
        existing != null && existing.type == MethodType.addSet
            ? (existing.params['copyFromSetIndex']?.toString() ?? '-1')
            : '-1';
    final copyIndexCtl = TextEditingController(text: copyIndex);

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSt) => AlertDialog(
                  title: Text(dialogTitle),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nameCtl,
                          decoration: InputDecoration(
                            labelText: strings.commonName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<MethodType>(
                          value: type,
                          isExpanded: true,
                          onChanged: (v) => setSt(() => type = v!),
                          items:
                              MethodType.values
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(_methodTypeLabel(t, strings)),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                        if (type == MethodType.weight) ...[
                          DropdownButton<String>(
                            value: sign,
                            isExpanded: true,
                            onChanged: (v) => setSt(() => sign = v!),
                            items: const [
                              DropdownMenuItem(value: '+', child: Text('+')),
                              DropdownMenuItem(value: '-', child: Text('-')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: factorCtl,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: strings.flowFactor,
                            ),
                          ),
                        ] else if (type == MethodType.rep) ...[
                          DropdownButton<String>(
                            value: sign,
                            isExpanded: true,
                            onChanged: (v) => setSt(() => sign = v!),
                            items: const [
                              DropdownMenuItem(value: '+', child: Text('+')),
                              DropdownMenuItem(value: '-', child: Text('-')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountCtl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: strings.flowAmount,
                            ),
                          ),
                        ] else if (type == MethodType.addSet) ...[
                          Row(
                            children: [
                              Radio<AddSetMode>(
                                value: AddSetMode.explicit,
                                groupValue: addMode,
                                onChanged: (v) => setSt(() => addMode = v!),
                              ),
                              Text(strings.flowExplicit),
                              Radio<AddSetMode>(
                                value: AddSetMode.copy,
                                groupValue: addMode,
                                onChanged: (v) => setSt(() => addMode = v!),
                              ),
                              Text(strings.rulesCopy),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (addMode == AddSetMode.explicit) ...[
                            TextField(
                              controller: weightCtl,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: strings.flowWeight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: repsCtl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: strings.flowReps,
                              ),
                            ),
                          ] else ...[
                            TextField(
                              controller: copyIndexCtl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: strings.rulesCopyIndex,
                              ),
                            ),
                          ],
                        ] else if (type == MethodType.delSet) ...[
                          Text(strings.rulesDeleteLastSetBody),
                        ],
                      ],
                    ),
                  ),
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
          ),
    );

    final methodName = nameCtl.text.trim();
    final factor = double.tryParse(factorCtl.text) ?? 1.0;
    final amount = int.tryParse(amountCtl.text) ?? 0;
    final weight = double.tryParse(weightCtl.text) ?? 0.0;
    final reps = int.tryParse(repsCtl.text) ?? 0;
    final copyIndexValue = int.tryParse(copyIndexCtl.text) ?? -1;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.rulesNameRequired)));
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
    final destinationCount =
        isAppDefault
            ? _profiles.where((profile) => profile.id != null).length
            : profileId == null
            ? 0
            : (_presetsByProfile[profileId] ?? const []).length;
    if (destinationCount == 0 || (!isAppDefault && profileId == null)) return;

    final destinationLabel =
        isAppDefault
            ? strings.rulesProfilesLowercase
            : strings.rulesPlansLowercase;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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
    );
    if (confirmed != true || !mounted) return;

    try {
      final copied =
          isAppDefault
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
    final updated = await showDialog<FlowMethod>(
      context: context,
      builder:
          (_) => AddPresetMethodDialog(presetId: presetId, existing: existing),
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
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _methodTypeColor(m.type, cs);
    final strings = AppLocalizations.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(_methodTypeIcon(m.type), color: color, size: 21),
      ),
      title: Text(
        m.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        _methodTypeLabel(m.type, strings),
        style: theme.textTheme.bodySmall?.copyWith(color: color),
      ),
      trailing: PopupMenuButton<_RuleAction>(
        tooltip: strings.rulesOptionsTooltip,
        onSelected: (action) {
          if (action == _RuleAction.edit) {
            onEdit();
          } else {
            onDelete();
          }
        },
        itemBuilder:
            (context) => [
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
  }) {
    return [
      for (var index = 0; index < methods.length; index++) ...[
        if (index > 0) const Divider(height: 1, indent: 68),
        _methodTile(
          methods[index],
          onEdit: () => onEdit(methods[index]),
          onDelete: () => onDelete(methods[index]),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.rulesPageTitle,
      subtitle: strings.rulesPageSubtitle,
      icon: Icons.route_outlined,
      children: [
        SettingsInfoCard(
          icon: Icons.copy_all_outlined,
          title: strings.rulesHowDefaultsTitle,
          body: strings.rulesHowDefaultsBody,
        ),
        const SizedBox(height: 14),
        _RuleScopeLegend(strings: strings),
        const SizedBox(height: 18),
        _RuleScopeCard(
          color: context.cs.primary,
          icon: Icons.apps_outlined,
          title: strings.rulesAppDefaultsTitle,
          subtitle: strings.rulesAppDefaultsSubtitle,
          count: _appMethods.length,
          initiallyExpanded: true,
          children: [
            if (_appMethods.isEmpty)
              _EmptyRuleState(message: strings.rulesNoAppDefaults)
            else
              ..._ruleTiles(
                _appMethods,
                onEdit:
                    (method) =>
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
                final profileMethods = _profileMethods[profile.id] ?? const [];
                final presets = _presetsByProfile[profile.id] ?? const [];
                final planRuleCount = presets.fold<int>(
                  0,
                  (total, preset) =>
                      total +
                      (_presetMethods[preset['id'] as int]?.length ?? 0),
                );
                final profileColor = _profileScopeColor(context);
                final planColor = _planScopeColor(context);

                return _RuleScopeCard(
                  color: profileColor,
                  icon: Icons.fitness_center,
                  title: profile.name,
                  subtitle: strings.rulesProfileSummary(
                    profileMethods.length,
                    planRuleCount,
                  ),
                  count: profileMethods.length + planRuleCount,
                  initiallyExpanded: profileIndex == 0,
                  children: [
                    _RuleScopeCard(
                      color: profileColor,
                      icon: Icons.tune,
                      title: strings.rulesProfileDefaultsTitle,
                      subtitle: strings.rulesProfileDefaultsSubtitle,
                      count: profileMethods.length,
                      initiallyExpanded: true,
                      compact: true,
                      children: [
                        if (profileMethods.isEmpty)
                          _EmptyRuleState(
                            message: strings.rulesNoProfileDefaults,
                          )
                        else
                          ..._ruleTiles(
                            profileMethods,
                            onEdit:
                                (method) => _showAddEditDefault(
                                  scope: 'profile',
                                  profileId: profile.id,
                                  existing: method,
                                ),
                            onDelete: (method) async {
                              await _repo.deleteDefaultFlowMethodAndReferences(
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
                          onPressed:
                              () => _showAddEditDefault(
                                scope: 'profile',
                                profileId: profile.id,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _NestedHeading(
                      color: planColor,
                      icon: Icons.event_note_outlined,
                      title: strings.rulesPlansTitle,
                      count: presets.length,
                    ),
                    const SizedBox(height: 8),
                    if (presets.isEmpty)
                      _EmptyRuleState(message: strings.rulesNoPlans)
                    else
                      for (
                        var presetIndex = 0;
                        presetIndex < presets.length;
                        presetIndex++
                      ) ...[
                        Builder(
                          builder: (context) {
                            final preset = presets[presetIndex];
                            final presetId = preset['id'] as int;
                            final methods =
                                _presetMethods[presetId] ?? const [];
                            return _RuleScopeCard(
                              color: planColor,
                              icon: Icons.event_note_outlined,
                              title: preset['name'] as String,
                              subtitle: strings.rulesPlanOnlySubtitle,
                              count: methods.length,
                              compact: true,
                              children: [
                                if (methods.isEmpty)
                                  _EmptyRuleState(
                                    message: strings.rulesNoPlanRules,
                                  )
                                else
                                  ..._ruleTiles(
                                    methods,
                                    onEdit:
                                        (method) => _showAddEditPresetMethod(
                                          presetId: presetId,
                                          existing: method,
                                        ),
                                    onDelete: (method) async {
                                      await _repo.deleteFlowMethodAndReferences(
                                        method,
                                      );
                                      if (!mounted) return;
                                      await _loadAll();
                                    },
                                  ),
                                _AddRuleButton(
                                  color: planColor,
                                  label: strings.rulesAddPlan,
                                  onPressed:
                                      () => _showAddEditPresetMethod(
                                        presetId: presetId,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (presetIndex < presets.length - 1)
                          const SizedBox(height: 8),
                      ],
                  ],
                );
              },
            ),
            if (profileIndex < _profiles.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _LoadedProfileMethods {
  final int profileId;
  final List<FlowMethod> methods;
  final List<Map<String, dynamic>> presets;
  final Map<int, List<FlowMethod>> presetMethods;

  const _LoadedProfileMethods({
    required this.profileId,
    required this.methods,
    required this.presets,
    required this.presetMethods,
  });
}

enum _RuleAction { edit, delete }

Color _methodTypeColor(MethodType type, ColorScheme scheme) {
  return switch (type) {
    MethodType.weight => scheme.primary,
    MethodType.rep => scheme.secondary,
    MethodType.addSet => const Color(0xFF26A69A),
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
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4DB6AC)
      : const Color(0xFF00796B);
}

Color _planScopeColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFEF6C00);
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
        _LegendChip(color: scheme.primary, label: strings.rulesAppDefaultsChip),
        _LegendChip(
          color: _profileScopeColor(context),
          label: strings.rulesProfilesChip,
        ),
        _LegendChip(
          color: _planScopeColor(context),
          label: strings.rulesPlansChip,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
  final List<Widget> children;

  const _RuleScopeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    this.initiallyExpanded = false,
    this.compact = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = compact ? 12.0 : 14.0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: compact ? .20 : .28,
        ),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        border: Border.all(color: color.withValues(alpha: compact ? .36 : .52)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.symmetric(horizontal: padding, vertical: 3),
        childrenPadding: EdgeInsets.zero,
        collapsedBackgroundColor: color.withValues(alpha: compact ? .05 : .08),
        backgroundColor: color.withValues(alpha: .04),
        leading: Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .17),
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
          ),
          child: Icon(icon, color: color, size: compact ? 20 : 22),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (compact
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          subtitle,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CountBadge(count: count, color: color),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
          ],
        ),
        children: children,
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
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

  const _NestedHeading({
    required this.color,
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _CountBadge(count: count, color: color),
      ],
    );
  }
}

class _EmptyRuleState extends StatelessWidget {
  final String message;

  const _EmptyRuleState({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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

  const _AddRuleButton({
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: _EmptyRuleState(message: message),
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

  late TextEditingController _nameCtl;
  late MethodType _type;
  late String _sign;
  late TextEditingController _factorCtl;
  late TextEditingController _amountCtl;
  AddSetMode _addMode = AddSetMode.explicit;
  late TextEditingController _weightCtl;
  late TextEditingController _repsCtl;
  late TextEditingController _copyIndexCtl;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _nameCtl = TextEditingController(text: ex?.name);
    _type = ex?.type ?? MethodType.weight;
    _sign = ex?.params['sign'] as String? ?? '+';
    _factorCtl = TextEditingController(text: ex?.params['factor']?.toString());
    _amountCtl = TextEditingController(text: ex?.params['amount']?.toString());
    _addMode =
        ex?.params.containsKey('copyFromSetIndex') == true
            ? AddSetMode.copy
            : AddSetMode.explicit;
    _weightCtl = TextEditingController(text: ex?.params['weight']?.toString());
    _repsCtl = TextEditingController(text: ex?.params['reps']?.toString());
    _copyIndexCtl = TextEditingController(
      text: ex?.params['copyFromSetIndex']?.toString() ?? '-1',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(isEdit ? strings.rulesEditPlan : strings.rulesAddPlanTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtl,
              decoration: InputDecoration(labelText: strings.commonName),
            ),
            const SizedBox(height: 12),
            DropdownButton<MethodType>(
              value: _type,
              isExpanded: true,
              onChanged: (v) => setState(() => _type = v!),
              items:
                  MethodType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(_methodTypeLabel(t, strings)),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            if (_type == MethodType.weight) ...[
              DropdownButton<String>(
                value: _sign,
                isExpanded: true,
                onChanged: (v) => setState(() => _sign = v!),
                items: const [
                  DropdownMenuItem(value: '+', child: Text('+')),
                  DropdownMenuItem(value: '-', child: Text('-')),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _factorCtl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: strings.flowFactor),
              ),
            ] else if (_type == MethodType.rep) ...[
              DropdownButton<String>(
                value: _sign,
                isExpanded: true,
                onChanged: (v) => setState(() => _sign = v!),
                items: const [
                  DropdownMenuItem(value: '+', child: Text('+')),
                  DropdownMenuItem(value: '-', child: Text('-')),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: strings.flowAmount),
              ),
            ] else if (_type == MethodType.addSet) ...[
              Row(
                children: [
                  Radio<AddSetMode>(
                    value: AddSetMode.explicit,
                    groupValue: _addMode,
                    onChanged: (v) => setState(() => _addMode = v!),
                  ),
                  Text(strings.flowExplicit),
                  Radio<AddSetMode>(
                    value: AddSetMode.copy,
                    groupValue: _addMode,
                    onChanged: (v) => setState(() => _addMode = v!),
                  ),
                  Text(strings.rulesCopy),
                ],
              ),
              const SizedBox(height: 8),
              if (_addMode == AddSetMode.explicit) ...[
                TextField(
                  controller: _weightCtl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: strings.flowWeight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _repsCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: strings.flowReps),
                ),
              ] else ...[
                TextField(
                  controller: _copyIndexCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.rulesCopyIndex,
                  ),
                ),
              ],
            ] else if (_type == MethodType.delSet) ...[
              Text(strings.rulesDeleteLastSetBody),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.commonCancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtl.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.rulesNameRequired)),
              );
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
                  params['copyFromSetIndex'] =
                      int.tryParse(_copyIndexCtl.text) ?? -1;
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
            if (!context.mounted) return;
            Navigator.pop(
              context,
              FlowMethod(
                id: -1,
                presetId: widget.presetId,
                name: name,
                type: _type,
                params: params,
              ),
            );
          },
          child: Text(strings.commonSave),
        ),
      ],
    );
  }
}
