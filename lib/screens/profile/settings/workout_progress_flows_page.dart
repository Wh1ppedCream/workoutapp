import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/gym_models.dart';
import '../../../models/preset_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/settings_tiles.dart';
import '../../exercise/auto_preset_flow_screen.dart';

/// Manages progression flows at every persisted scope. App defaults are copied
/// into new gym profiles, profile defaults are copied into new plans, and plan
/// flows remain independent after that point.
class WorkoutProgressFlowsPage extends StatefulWidget {
  const WorkoutProgressFlowsPage({super.key});

  @override
  State<WorkoutProgressFlowsPage> createState() =>
      _WorkoutProgressFlowsPageState();
}

class _WorkoutProgressFlowsPageState extends State<WorkoutProgressFlowsPage> {
  AppRepository get _repository => context.read<AppRepository>();

  bool _isLoading = true;
  String? _loadError;
  int _loadRequest = 0;
  _FlowSummary _appSummary = const _FlowSummary.empty();
  List<_ProfileFlowGroup> _profiles = const [];

  @override
  void initState() {
    super.initState();
    _loadFlows();
  }

  Future<void> _loadFlows() async {
    final request = ++_loadRequest;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final initialResults = await Future.wait<Object>([
        _repository.fetchDefaultFlowDefinition('app'),
        _repository.fetchAllProfiles(),
      ]);
      final appDefinition = initialResults[0] as FlowDefinition;
      final profiles = initialResults[1] as List<GymProfile>;
      final groups =
          (await Future.wait(
            profiles.map(_loadProfileGroup),
          )).whereType<_ProfileFlowGroup>().toList();

      if (!mounted || request != _loadRequest) return;
      setState(() {
        _appSummary = _FlowSummary.fromDefinition(appDefinition);
        _profiles = groups;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _isLoading = false;
        _loadError = 'load_failed';
      });
    }
  }

  Future<_ProfileFlowGroup?> _loadProfileGroup(GymProfile profile) async {
    final profileId = profile.id;
    if (profileId == null) return null;

    final results = await Future.wait<Object>([
      _repository.fetchDefaultFlowDefinition('profile', profileId: profileId),
      _repository.fetchAllPresetsRaw(profileId: profileId),
    ]);
    final defaultFlow = results[0] as FlowDefinition;
    final rawPlans = results[1] as List<Map<String, dynamic>>;
    final plans = await Future.wait(
      rawPlans.map((plan) async {
        final planId = plan['id'] as int;
        final definition = await _repository.fetchFlowDefinition(planId);
        return _PlanFlow(
          id: planId,
          name: plan['name'] as String? ?? 'Unnamed plan',
          summary: _FlowSummary.fromDefinition(definition),
        );
      }),
    );

    return _ProfileFlowGroup(
      profile: profile,
      summary: _FlowSummary.fromDefinition(defaultFlow),
      plans: plans,
    );
  }

  Future<void> _openEditor(Widget editor) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => editor));
    if (!mounted) return;
    await _loadFlows();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final appColor = scheme.primary;
    final profileColor = _profileColor(context);
    final planColor = _planColor(context);

    return SettingsPageScaffold(
      title: strings.flowPageTitle,
      subtitle: strings.flowPageSubtitle,
      icon: Icons.account_tree_outlined,
      heroAccentColor: SettingsAccent.advanced,
      children: [
        SettingsInfoCard(
          icon: Icons.copy_all_outlined,
          title: strings.flowHowCopiedTitle,
          body: strings.flowHowCopiedBody,
        ),
        const SizedBox(height: 14),
        _ScopeLegend(
          appColor: appColor,
          profileColor: profileColor,
          planColor: planColor,
        ),
        const SizedBox(height: 18),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 52),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_loadError != null)
          _FlowLoadError(message: strings.flowLoadError, onRetry: _loadFlows)
        else ...[
          _FlowScopeCard(
            color: appColor,
            icon: Icons.apps_outlined,
            title: strings.rulesAppDefaultsTitle,
            subtitle: strings.flowAppDefaultsSubtitle,
            initiallyExpanded: true,
            child: _FlowEntryTile(
              color: appColor,
              icon: Icons.account_tree_outlined,
              title: strings.flowAppDefaultEntry,
              summary: _appSummary,
              onTap:
                  () => _openEditor(const AutoPresetFlowScreen.appDefaults()),
            ),
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            color: profileColor,
            title: strings.rulesGymProfilesTitle,
            subtitle: strings.flowGymProfilesSubtitle,
          ),
          const SizedBox(height: 10),
          if (_profiles.isEmpty)
            _EmptyFlowsCard(message: strings.flowNoProfiles)
          else
            for (var index = 0; index < _profiles.length; index++) ...[
              _ProfileFlowCard(
                group: _profiles[index],
                profileColor: profileColor,
                planColor: planColor,
                initiallyExpanded: index == 0,
                onOpenProfile:
                    () => _openEditor(
                      AutoPresetFlowScreen.profileDefaults(
                        profileId: _profiles[index].profile.id!,
                        profileName: _profiles[index].profile.name,
                      ),
                    ),
                onOpenPlan:
                    (plan) =>
                        _openEditor(AutoPresetFlowScreen(presetId: plan.id)),
              ),
              if (index < _profiles.length - 1) const SizedBox(height: 12),
            ],
        ],
      ],
    );
  }
}

class _ProfileFlowGroup {
  final GymProfile profile;
  final _FlowSummary summary;
  final List<_PlanFlow> plans;

  const _ProfileFlowGroup({
    required this.profile,
    required this.summary,
    required this.plans,
  });
}

class _PlanFlow {
  final int id;
  final String name;
  final _FlowSummary summary;

  const _PlanFlow({
    required this.id,
    required this.name,
    required this.summary,
  });
}

class _FlowSummary {
  final int nodes;
  final int branches;
  final int actions;

  const _FlowSummary({
    required this.nodes,
    required this.branches,
    required this.actions,
  });

  const _FlowSummary.empty() : nodes = 0, branches = 0, actions = 0;

  factory _FlowSummary.fromDefinition(FlowDefinition definition) {
    return _FlowSummary(
      nodes: definition.nodes.length,
      branches:
          definition.edges
              .where(
                (edge) =>
                    edge.outcome == 'success' || edge.outcome == 'failure',
              )
              .length,
      actions:
          definition.edges.where((edge) => edge.outcome == 'method').length,
    );
  }

  String label(AppLocalizations strings) {
    if (nodes == 0) return strings.flowNoSavedYet;
    return strings.flowSummary(nodes, branches, actions);
  }
}

class _ScopeLegend extends StatelessWidget {
  final Color appColor;
  final Color profileColor;
  final Color planColor;

  const _ScopeLegend({
    required this.appColor,
    required this.profileColor,
    required this.planColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LegendChip(
          color: appColor,
          label: AppLocalizations.of(context).rulesAppDefaultsChip,
        ),
        _LegendChip(
          color: profileColor,
          label: AppLocalizations.of(context).rulesGymProfilesTitle,
        ),
        _LegendChip(
          color: planColor,
          label: AppLocalizations.of(context).rulesPlansChip,
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

class _FlowScopeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool initiallyExpanded;
  final Widget child;

  const _FlowScopeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .52)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        collapsedBackgroundColor: color.withValues(alpha: .08),
        backgroundColor: color.withValues(alpha: .04),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .17),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: [child],
      ),
    );
  }
}

class _ProfileFlowCard extends StatelessWidget {
  final _ProfileFlowGroup group;
  final Color profileColor;
  final Color planColor;
  final bool initiallyExpanded;
  final VoidCallback onOpenProfile;
  final ValueChanged<_PlanFlow> onOpenPlan;

  const _ProfileFlowCard({
    required this.group,
    required this.profileColor,
    required this.planColor,
    required this.onOpenProfile,
    required this.onOpenPlan,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _FlowScopeCard(
      color: profileColor,
      icon: Icons.fitness_center_outlined,
      title: group.profile.name,
      subtitle: strings.flowPlansAvailable(group.plans.length),
      initiallyExpanded: initiallyExpanded,
      child: Column(
        children: [
          _FlowEntryTile(
            color: profileColor,
            icon: Icons.tune_outlined,
            title: strings.flowGymDefaultEntry,
            summary: group.summary,
            onTap: onOpenProfile,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.event_note_outlined, color: planColor, size: 20),
              const SizedBox(width: 8),
              Text(
                strings.rulesPlansTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: planColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (group.plans.isEmpty)
            _EmptyFlowsCard(message: strings.rulesNoPlans, compact: true)
          else
            for (var index = 0; index < group.plans.length; index++) ...[
              _FlowEntryTile(
                color: planColor,
                icon: Icons.account_tree_outlined,
                title: group.plans[index].name,
                summary: group.plans[index].summary,
                onTap: () => onOpenPlan(group.plans[index]),
              ),
              if (index < group.plans.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _FlowEntryTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final _FlowSummary summary;
  final VoidCallback onTap;

  const _FlowEntryTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: .34)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.label(AppLocalizations.of(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyFlowsCard extends StatelessWidget {
  final String message;
  final bool compact;

  const _EmptyFlowsCard({required this.message, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
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

class _FlowLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FlowLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: .32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.error.withValues(alpha: .38)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

Color _profileColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4DB6AC)
      : const Color(0xFF00796B);
}

Color _planColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFEF6C00);
}
