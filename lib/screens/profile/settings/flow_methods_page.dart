// File: lib/screens/profile/settings/flow_methods_page.dart

//TODO: VERY INCOMPLETE, LOTS OF DEFAULT-RELATED STUFF NOT WORKING
//TODO: REMOVING METHODS ALSO DOES NOT REMOVE FROM EXISTING FLOW
//TODO: FLOW CHART SCREENS ALSO DO NOT NAVIGATE TO THIS STILL

import 'package:flutter/material.dart';
import '../../../models/preset_models.dart';
import '../../../models/gym_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../theme/theme_extensions.dart';

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
        profileMethods[p.id!] =
            await _repo.fetchDefaultFlowMethods('profile', profileId: p.id!);
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
    final dialogTitle = isEdit
        ? 'Edit ${scope == 'app' ? 'App-wide' : 'Profile'} Default Method'
        : 'Add ${scope == 'app' ? 'App-wide' : 'Profile'} Default Method';

    // Controllers
    final nameCtl = TextEditingController(text: existing?.name);
    MethodType type = existing?.type ?? MethodType.weight;
    String sign = existing?.params['sign'] as String? ?? '+';
    final factorCtl = TextEditingController(
        text: existing?.params['factor']?.toString() ?? '1.0');
    final amountCtl = TextEditingController(
        text: existing?.params['amount']?.toString() ?? '0');
    AddSetMode addMode = AddSetMode.explicit;
    final weightCtl = TextEditingController(
        text: existing?.params['weight']?.toString() ?? '0.0');
    final repsCtl = TextEditingController(
        text: existing?.params['reps']?.toString() ?? '0');

    // Prepopulate copyIndex if editing an addSet method
    final copyIndex = existing != null && existing.type == MethodType.addSet
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
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
                  items: MethodType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.toShortString())))
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Factor'),
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
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                ] else if (type == MethodType.addSet) ...[
                  Row(children: [
                    Radio<AddSetMode>(
                        value: AddSetMode.explicit,
                        groupValue: addMode,
                        onChanged: (v) => setSt(() => addMode = v!)),
                    const Text('Explicit'),
                    Radio<AddSetMode>(
                        value: AddSetMode.copy,
                        groupValue: addMode,
                        onChanged: (v) => setSt(() => addMode = v!)),
                    const Text('Copy'),
                  ]),
                  const SizedBox(height: 8),
                  if (addMode == AddSetMode.explicit) ...[
                    TextField(
                      controller: weightCtl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: repsCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                    ),
                  ] else ...[
                    TextField(
                      controller: copyIndexCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Copy index'),
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
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
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
    disposeControllers();

    await _repo.upsertDefaultFlowMethod(
      scope: scope,
      profileId: profileId,
      name: methodName,
      type: type,
      params: params,
    );
    if (!mounted) return;
    await _loadAll();
  }

  Future<void> _showAddEditPresetMethod({
    required int presetId,
    FlowMethod? existing,
  }) async {
    final updated = await showDialog<FlowMethod>(
      context: context,
      builder: (_) => AddPresetMethodDialog(
        presetId: presetId,
        existing: existing,
      ),
    );
    if (updated != null && mounted) await _loadAll();
  }

  Widget _methodTile(
    FlowMethod m, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final cs = context.cs;
    final color = {
      MethodType.weight: cs.primary.withValues(alpha: .2),
      MethodType.rep: cs.secondary.withValues(alpha: .2),
      MethodType.addSet: cs.tertiary.withValues(alpha: .2),
      MethodType.delSet: cs.error.withValues(alpha: .2),
    }[m.type]!;

    return ListTile(
      leading: const Icon(Icons.drag_handle),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
            child:
                Text(m.type.toShortString(), style: TextStyle(fontSize: 12, color: cs.onSurface)),
          ),
          Expanded(child: Text(m.name)),
        ],
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Flow Methods')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // App-wide
          ExpansionTile(
            key: const ValueKey('app-defaults'),
            title: const Text('App-wide Defaults'),
            children: [
              for (var m in _appMethods)
                _methodTile(
                  m,
                  onEdit: () => _showAddEditDefault(scope: 'app', existing: m),
                  onDelete: () async {
                    await _repo.deleteDefaultFlowMethod(scope: 'app', name: m.name);
                    await _loadAll();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add method'),
                onTap: () => _showAddEditDefault(scope: 'app'),
              ),
            ],
          ),

          // Per-profile
          for (var p in _profiles)
            ExpansionTile(
              key: ValueKey('profile-${p.id}'),
              title: Text(p.name),
              children: [
                // Profile defaults
                ExpansionTile(
                  key: ValueKey('profile-${p.id}-defaults'),
                  title: const Text('Profile Defaults'),
                  children: [
                    for (var m in _profileMethods[p.id] ?? [])
                      _methodTile(
                        m,
                        onEdit: () => _showAddEditDefault(
                            scope: 'profile', profileId: p.id, existing: m),
                        onDelete: () async {
                          await _repo.deleteDefaultFlowMethod(
                              scope: 'profile', profileId: p.id, name: m.name);
                          await _loadAll();
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add method'),
                      onTap: () => _showAddEditDefault(
                          scope: 'profile', profileId: p.id),
                    ),
                  ],
                ),
                // Presets
                for (var pr in _presetsByProfile[p.id] ?? [])
                  ExpansionTile(
                    key: ValueKey('preset-${pr['id']}'),
                    title: Text(pr['name'] as String),
                    children: [
                      for (var m in _presetMethods[pr['id'] as int] ?? [])
                        _methodTile(
                          m,
                          onEdit: () => _showAddEditPresetMethod(
                            presetId: pr['id'] as int,
                            existing: m,
                          ),
                          onDelete: () async {
                            await _repo.deleteFlowMethod(m.id);
                            await _loadAll();
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Add method'),
                        onTap: () => _showAddEditPresetMethod(
                            presetId: pr['id'] as int),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Dialog for adding or editing a FlowMethod on a Preset
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
    _weightCtl = TextEditingController(text: ex?.params['weight']?.toString());
    _repsCtl = TextEditingController(text: ex?.params['reps']?.toString());
    _copyIndexCtl = TextEditingController(
        text: ex?.params['copyFromSetIndex']?.toString() ?? '-1');
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
      title: Text(isEdit ? 'Edit Method' : 'Add Method'),
      content: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _nameCtl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          DropdownButton<MethodType>(
            value: _type,
            isExpanded: true,
            onChanged: (v) => setState(() => _type = v!),
            items: MethodType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.toShortString())))
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
            Row(children: [
              Radio<AddSetMode>(
                  value: AddSetMode.explicit,
                  groupValue: _addMode,
                  onChanged: (v) => setState(() => _addMode = v!)),
              const Text('Explicit'),
              Radio<AddSetMode>(
                  value: AddSetMode.copy,
                  groupValue: _addMode,
                  onChanged: (v) => setState(() => _addMode = v!)),
              const Text('Copy'),
            ]),
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
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtl.text.trim();
            if (name.isEmpty) return;
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
                  params['copyFromSetIndex'] = int.tryParse(_copyIndexCtl.text) ?? -1;
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
            Navigator.pop(context, FlowMethod(
              id: -1,
              presetId: widget.presetId,
              name: name,
              type: _type,
              params: params,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
