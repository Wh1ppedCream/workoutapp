import 'dart:async';

import 'package:flutter/material.dart';

import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';

class PlanManagementPage extends StatefulWidget {
  final int profileId;

  const PlanManagementPage({super.key, required this.profileId});

  @override
  State<PlanManagementPage> createState() => _PlanManagementPageState();
}

class _PlanManagementPageState extends State<PlanManagementPage> {
  final _repo = AppRepository();
  final _savingPlanIds = <int>{};

  var _isLoading = true;
  String? _error;
  List<_ManagedPlan> _plans = const <_ManagedPlan>[];
  Set<int> _activePlanIds = const <int>{};

  @override
  void initState() {
    super.initState();
    unawaited(_loadPlans());
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rows = await _repo.fetchPresetSummariesRaw(
        profileId: widget.profileId,
      );
      final plans =
          rows.map((row) {
            final rawName = (row['name'] as String?)?.trim();
            final id = (row['id'] as num).toInt();
            return _ManagedPlan(
              id: id,
              name:
                  rawName?.isNotEmpty == true
                      ? _planDisplayText(rawName!)
                      : 'Plan $id',
              isAutomatic: ((row['is_automatic'] as num?) ?? 0).toInt() == 1,
            );
          }).toList();
      final activeIds = await ActivePlanStore.load(widget.profileId);
      final validPlanIds = plans.map((plan) => plan.id).toSet();
      final validActiveIds = activeIds.intersection(validPlanIds);
      if (validActiveIds.length != activeIds.length) {
        await ActivePlanStore.save(widget.profileId, validActiveIds);
      }

      if (!mounted) return;
      setState(() {
        _plans = plans;
        _activePlanIds = validActiveIds;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _setPlanActive(_ManagedPlan plan, bool active) async {
    if (_savingPlanIds.contains(plan.id)) return;
    final previousIds = Set<int>.of(_activePlanIds);
    final nextIds = Set<int>.of(_activePlanIds);
    if (active) {
      nextIds.add(plan.id);
    } else {
      nextIds.remove(plan.id);
    }
    setState(() {
      _activePlanIds = nextIds;
      _savingPlanIds.add(plan.id);
    });

    try {
      await ActivePlanStore.save(widget.profileId, nextIds);
    } catch (error) {
      if (!mounted) return;
      setState(() => _activePlanIds = previousIds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update ${plan.name}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _savingPlanIds.remove(plan.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activePlans =
        _plans.where((plan) => _activePlanIds.contains(plan.id)).toList();
    final archivedPlans =
        _plans.where((plan) => !_activePlanIds.contains(plan.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Plans'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _PlanManagementMessage(
                icon: Icons.error_outline,
                title: 'Unable to load plans',
                message: _error!,
                actionLabel: 'Try again',
                onAction: _loadPlans,
              )
              : RefreshIndicator(
                onRefresh: _loadPlans,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Text(
                      'Choose what stays ready on your Train overview. Archived plans are still saved and can be activated anytime.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PlanManagementSection(
                      title: 'Active Plans',
                      subtitle: 'Shown on the Train overview.',
                      emptyMessage:
                          'No active plans yet. Activate a plan below to pin it to the overview.',
                      plans: activePlans,
                      activePlanIds: _activePlanIds,
                      savingPlanIds: _savingPlanIds,
                      actionLabel: 'Archive',
                      actionIcon: Icons.archive_outlined,
                      onAction: (plan) => _setPlanActive(plan, false),
                    ),
                    const SizedBox(height: 16),
                    _PlanManagementSection(
                      title: 'Archived Plans',
                      subtitle: 'Saved plans that stay out of the overview.',
                      emptyMessage: 'No archived plans.',
                      plans: archivedPlans,
                      activePlanIds: _activePlanIds,
                      savingPlanIds: _savingPlanIds,
                      actionLabel: 'Activate',
                      actionIcon: Icons.check_circle_outline,
                      onAction: (plan) => _setPlanActive(plan, true),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _PlanManagementSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<_ManagedPlan> plans;
  final Set<int> activePlanIds;
  final Set<int> savingPlanIds;
  final String actionLabel;
  final IconData actionIcon;
  final ValueChanged<_ManagedPlan> onAction;

  const _PlanManagementSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.plans,
    required this.activePlanIds,
    required this.savingPlanIds,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _PlanCountPill(count: plans.length),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (plans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  emptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (var index = 0; index < plans.length; index++) ...[
                _PlanManagementTile(
                  plan: plans[index],
                  isActive: activePlanIds.contains(plans[index].id),
                  isSaving: savingPlanIds.contains(plans[index].id),
                  actionLabel: actionLabel,
                  actionIcon: actionIcon,
                  onAction: () => onAction(plans[index]),
                ),
                if (index != plans.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _PlanManagementTile extends StatelessWidget {
  final _ManagedPlan plan;
  final bool isActive;
  final bool isSaving;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _PlanManagementTile({
    required this.plan,
    required this.isActive,
    required this.isSaving,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor =
        isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: statusColor.withValues(alpha: 0.16),
              child: Icon(
                isActive ? Icons.push_pin_outlined : Icons.inventory_2_outlined,
                color: statusColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.isAutomatic
                        ? 'Automatic plan'
                        : isActive
                        ? 'Visible on overview'
                        : 'Hidden from overview',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: isSaving ? null : onAction,
              icon:
                  isSaving
                      ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(actionIcon, size: 16),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCountPill extends StatelessWidget {
  final int count;

  const _PlanCountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          '$count',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PlanManagementMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _PlanManagementMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _ManagedPlan {
  final int id;
  final String name;
  final bool isAutomatic;

  const _ManagedPlan({
    required this.id,
    required this.name,
    required this.isAutomatic,
  });
}

String _planDisplayText(String value) {
  return value
      .replaceAll(RegExp(r'\bPresets\b'), 'Plans')
      .replaceAll(RegExp(r'\bPreset\b'), 'Plan')
      .replaceAll(RegExp(r'\bpresets\b'), 'plans')
      .replaceAll(RegExp(r'\bpreset\b'), 'plan');
}
