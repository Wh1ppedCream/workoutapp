// File: lib/screens/profile/settings/flow_methods_page.dart

import 'package:flutter/material.dart';
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
  final _repo = AppRepository();

  bool _isLoading = true;
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
    setState(() => _isLoading = true);

    // 1) App-wide defaults
    final appMethods = await _repo.fetchDefaultFlowMethods('app');

    // 2) Load each profile, its default methods, its presets and preset methods
    final profiles = await _repo.fetchAllProfiles();
    final profileMethods = <int, List<FlowMethod>>{};
    final presetsByProfile = <int, List<Map<String, dynamic>>>{};
    final presetMethods = <int, List<FlowMethod>>{};

    for (var p in profiles) {
      // profile-default methods
      if (p.id != null) {
        profileMethods[p.id!] = await _repo.fetchDefaultFlowMethods(
          'profile',
          profileId: p.id!,
        );
      }

      // raw presets for this profile
      final rawPresets = await _repo.fetchAllPresetsRaw(profileId: p.id);
      presetsByProfile[p.id!] = rawPresets;

      // methods on each preset
      for (var pr in rawPresets) {
        final presetId = pr['id'] as int;
        presetMethods[presetId] = await _repo.fetchFlowMethods(presetId);
      }
    }

    if (!mounted) return;
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
    final dialogTitle =
        isEdit
            ? 'Edit ${scope == 'app' ? 'App' : 'Profile'} Default Rule'
            : 'Add ${scope == 'app' ? 'App' : 'Profile'} Default Rule';

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
    void disposeControllers() {
      nameCtl.dispose();
      factorCtl.dispose();
      amountCtl.dispose();
      weightCtl.dispose();
      repsCtl.dispose();
      copyIndexCtl.dispose();
    }

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
                          decoration: const InputDecoration(labelText: 'Name'),
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
                                      child: Text(_methodTypeLabel(t)),
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
                            decoration: const InputDecoration(
                              labelText: 'Factor',
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
                            decoration: const InputDecoration(
                              labelText: 'Amount',
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
                              const Text('Explicit'),
                              Radio<AddSetMode>(
                                value: AddSetMode.copy,
                                groupValue: addMode,
                                onChanged: (v) => setSt(() => addMode = v!),
                              ),
                              const Text('Copy'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (addMode == AddSetMode.explicit) ...[
                            TextField(
                              controller: weightCtl,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: repsCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                              ),
                            ),
                          ] else ...[
                            TextField(
                              controller: copyIndexCtl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Copy index',
                              ),
                            ),
                          ],
                        ] else if (type == MethodType.delSet) ...[
                          const Text('This will delete the last set.'),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
    if (saved != true) {
      disposeControllers();
      return;
    }

    // build params
    final params = <String, dynamic>{};
    switch (type) {
      case MethodType.weight:
        params['sign'] = sign;
        params['factor'] = double.tryParse(factorCtl.text) ?? 1.0;
        break;
      case MethodType.rep:
        params['sign'] = sign;
        params['amount'] = int.tryParse(amountCtl.text) ?? 0;
        break;
      case MethodType.addSet:
        if (addMode == AddSetMode.explicit) {
          params['weight'] = double.tryParse(weightCtl.text) ?? 0.0;
          params['reps'] = int.tryParse(repsCtl.text) ?? 0;
        } else {
          params['copyFromSetIndex'] = int.tryParse(copyIndexCtl.text) ?? -1;
        }
        break;
      case MethodType.delSet:
        break;
    }
    final methodName = nameCtl.text.trim();
    if (methodName.isEmpty) {
      disposeControllers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rule name cannot be empty')),
      );
      return;
    }
    disposeControllers();

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
    if (!mounted) return;
    await _loadAll();
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
        _methodTypeLabel(m.type),
        style: theme.textTheme.bodySmall?.copyWith(color: color),
      ),
      trailing: PopupMenuButton<_RuleAction>(
        tooltip: 'Rule options',
        onSelected: (action) {
          if (action == _RuleAction.edit) {
            onEdit();
          } else {
            onDelete();
          }
        },
        itemBuilder:
            (context) => const [
              PopupMenuItem(
                value: _RuleAction.edit,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: _RuleAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
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

    return SettingsPageScaffold(
      title: 'Workout Progress Rules',
      subtitle:
          'Create reusable rules for how weights, reps, and sets change after workout attempts.',
      icon: Icons.route_outlined,
      children: [
        SettingsInfoCard(
          icon: Icons.copy_all_outlined,
          title: 'How defaults work',
          body:
              'App defaults are copied into new gym profiles. Profile defaults are copied into new plans, so later edits do not unexpectedly rewrite existing plans.',
        ),
        const SizedBox(height: 14),
        const _RuleScopeLegend(),
        const SizedBox(height: 18),
        _RuleScopeCard(
          color: context.cs.primary,
          icon: Icons.apps_outlined,
          title: 'App-wide defaults',
          subtitle: 'The starting rules for new gym profiles.',
          count: _appMethods.length,
          initiallyExpanded: true,
          children: [
            if (_appMethods.isEmpty)
              const _EmptyRuleState(
                message: 'No app-wide rules have been created yet.',
              )
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
                  await _loadAll();
                },
              ),
            _AddRuleButton(
              color: context.cs.primary,
              label: 'Add app rule',
              onPressed: () => _showAddEditDefault(scope: 'app'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionHeading(
          title: 'Gym profiles',
          subtitle: 'Each profile keeps its defaults and plan rules together.',
        ),
        const SizedBox(height: 10),
        if (_profiles.isEmpty)
          const _EmptyProfilesCard()
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
                  subtitle:
                      '${profileMethods.length} profile rules  •  $planRuleCount plan rules',
                  count: profileMethods.length + planRuleCount,
                  initiallyExpanded: profileIndex == 0,
                  children: [
                    _RuleScopeCard(
                      color: profileColor,
                      icon: Icons.tune,
                      title: 'Profile defaults',
                      subtitle: 'Starting rules for new plans in this profile.',
                      count: profileMethods.length,
                      initiallyExpanded: true,
                      compact: true,
                      children: [
                        if (profileMethods.isEmpty)
                          const _EmptyRuleState(
                            message: 'This profile has no default rules.',
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
                              await _loadAll();
                            },
                          ),
                        _AddRuleButton(
                          color: profileColor,
                          label: 'Add profile rule',
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
                      title: 'Plans',
                      count: presets.length,
                    ),
                    const SizedBox(height: 8),
                    if (presets.isEmpty)
                      const _EmptyRuleState(
                        message: 'No plans belong to this gym profile yet.',
                      )
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
                              subtitle: 'Rules used only by this plan.',
                              count: methods.length,
                              compact: true,
                              children: [
                                if (methods.isEmpty)
                                  const _EmptyRuleState(
                                    message:
                                        'This plan has no specific progression rules.',
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
                                      await _loadAll();
                                    },
                                  ),
                                _AddRuleButton(
                                  color: planColor,
                                  label: 'Add plan rule',
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
  const _RuleScopeLegend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LegendChip(color: scheme.primary, label: 'App defaults'),
        _LegendChip(color: _profileScopeColor(context), label: 'Profiles'),
        _LegendChip(color: _planScopeColor(context), label: 'Plans'),
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
  const _EmptyProfilesCard();

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
      child: const _EmptyRuleState(
        message: 'Create a gym profile to add profile and plan rules.',
      ),
    );
  }
}

String _methodTypeLabel(MethodType type) {
  return switch (type) {
    MethodType.weight => 'Weight',
    MethodType.rep => 'Reps',
    MethodType.addSet => 'Add set',
    MethodType.delSet => 'Remove set',
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
  final _repo = AppRepository();

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
    return AlertDialog(
      title: Text(isEdit ? 'Edit Rule' : 'Add Rule'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtl,
              decoration: const InputDecoration(labelText: 'Name'),
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
                          child: Text(_methodTypeLabel(t)),
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
                decoration: const InputDecoration(labelText: 'Factor'),
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
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ] else if (_type == MethodType.addSet) ...[
              Row(
                children: [
                  Radio<AddSetMode>(
                    value: AddSetMode.explicit,
                    groupValue: _addMode,
                    onChanged: (v) => setState(() => _addMode = v!),
                  ),
                  const Text('Explicit'),
                  Radio<AddSetMode>(
                    value: AddSetMode.copy,
                    groupValue: _addMode,
                    onChanged: (v) => setState(() => _addMode = v!),
                  ),
                  const Text('Copy'),
                ],
              ),
              const SizedBox(height: 8),
              if (_addMode == AddSetMode.explicit) ...[
                TextField(
                  controller: _weightCtl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _repsCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                ),
              ] else ...[
                TextField(
                  controller: _copyIndexCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Copy index'),
                ),
              ],
            ] else if (_type == MethodType.delSet) ...[
              const Text('This will delete the last set.'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtl.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rule name cannot be empty')),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
