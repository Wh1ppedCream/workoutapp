import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/safe_failure.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/safe_error_view.dart';

class PlanManagementPage extends StatefulWidget {
  final int profileId;

  const PlanManagementPage({super.key, required this.profileId});

  @override
  State<PlanManagementPage> createState() => _PlanManagementPageState();
}

class _PlanManagementPageState extends State<PlanManagementPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _activePlansTutorialKey = GlobalKey(debugLabel: 'manage_active_plans');
  final _archivedPlansTutorialKey = GlobalKey(
    debugLabel: 'manage_archived_plans',
  );
  final _savingPlanIds = <int>{};

  var _isLoading = true;
  SafeFailure? _failure;
  List<_ManagedPlan> _plans = const <_ManagedPlan>[];
  Set<int> _activePlanIds = const <int>{};
  bool _tutorialQueued = false;
  bool _initialLoadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    unawaited(_loadPlans());
  }

  Future<void> _loadPlans() async {
    final repository = _repo;
    final activePlanStore = context.read<ActivePlanStore>();
    final strings = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _failure = null;
    });
    try {
      final rows = await repository.fetchPresetSummariesRaw(
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
                      : strings.planManagementDefaultName(id),
              isAutomatic: ((row['is_automatic'] as num?) ?? 0).toInt() == 1,
            );
          }).toList();
      final activeIds = await activePlanStore.load(widget.profileId);
      final validPlanIds = plans.map((plan) => plan.id).toSet();
      final validActiveIds = activeIds.intersection(validPlanIds);
      if (validActiveIds.length != activeIds.length) {
        await activePlanStore.save(widget.profileId, validActiveIds);
      }

      if (!mounted) return;
      setState(() {
        _plans = plans;
        _activePlanIds = validActiveIds;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueTutorial();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = SafeFailure.classify(error);
        _isLoading = false;
      });
    }
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      final strings = AppLocalizations.of(context);
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.planManagement,
        steps: [
          GuidedTutorialStep(
            targetKey: _activePlansTutorialKey,
            icon: Icons.push_pin_outlined,
            title: strings.planManagementActiveTutorialTitle,
            body: strings.planManagementActiveTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _archivedPlansTutorialKey,
            icon: Icons.inventory_2_outlined,
            title: strings.planManagementArchivedTutorialTitle,
            body: strings.planManagementArchivedTutorialBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
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
      if (active) {
        await context.read<ActivePlanStore>().add(widget.profileId, plan.id);
      } else {
        await context.read<ActivePlanStore>().remove(widget.profileId, plan.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _activePlanIds = previousIds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).planManagementUpdateFailed(
              plan.name,
              safeFailureMessage(AppLocalizations.of(context), error),
            ),
          ),
        ),
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
    final strings = AppLocalizations.of(context);
    final activePlans =
        _plans.where((plan) => _activePlanIds.contains(plan.id)).toList();
    final archivedPlans =
        _plans.where((plan) => !_activePlanIds.contains(plan.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.planManagementTitle),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _failure != null
              ? SafeErrorView(
                title: strings.planManagementLoadFailed,
                failure: _failure!,
                onRetry: _loadPlans,
              )
              : RefreshIndicator(
                onRefresh: _loadPlans,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Text(
                      strings.planManagementIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: _activePlansTutorialKey,
                      child: _PlanManagementSection(
                        title: strings.trainActivePlans,
                        subtitle: strings.planManagementActiveSubtitle,
                        emptyMessage: strings.planManagementNoActive,
                        plans: activePlans,
                        activePlanIds: _activePlanIds,
                        savingPlanIds: _savingPlanIds,
                        actionLabel: strings.planManagementArchive,
                        actionIcon: Icons.archive_outlined,
                        onAction: (plan) => _setPlanActive(plan, false),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: _archivedPlansTutorialKey,
                      child: _PlanManagementSection(
                        title: strings.trainArchivedPlans,
                        subtitle: strings.planManagementArchivedSubtitle,
                        emptyMessage: strings.planManagementNoArchived,
                        plans: archivedPlans,
                        activePlanIds: _activePlanIds,
                        savingPlanIds: _savingPlanIds,
                        actionLabel: strings.planManagementActivate,
                        actionIcon: Icons.check_circle_outline,
                        onAction: (plan) => _setPlanActive(plan, true),
                      ),
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
    final strings = AppLocalizations.of(context);
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
                        ? strings.planManagementAutomatic
                        : isActive
                        ? strings.planManagementVisible
                        : strings.planManagementHidden,
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
