import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/gym_models.dart';
import '../../../models/preset_models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/active_plan_store.dart';
import '../../../services/safe_failure.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../widgets/safe_error_view.dart';
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
  SafeFailure? _loadFailure;
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
    final activePlanStore = _activePlanStoreOrNull();
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailure = null;
      });
    }

    try {
      final initialResults = await Future.wait<Object>([
        _repository.fetchDefaultFlowDefinition('app'),
        _repository.fetchAllProfiles(),
      ]);
      final appDefinition = initialResults[0] as FlowDefinition;
      final profiles = initialResults[1] as List<GymProfile>;
      final groups = (await Future.wait(
        profiles.map((profile) => _loadProfileGroup(profile, activePlanStore)),
      )).whereType<_ProfileFlowGroup>().toList();

      if (!mounted || request != _loadRequest) return;
      setState(() {
        _appSummary = _FlowSummary.fromDefinition(appDefinition);
        _profiles = groups;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _isLoading = false;
        _loadFailure = SafeFailure.classify(error);
      });
    }
  }

  ActivePlanStore? _activePlanStoreOrNull() {
    try {
      return context.read<ActivePlanStore>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Future<_ProfileFlowGroup?> _loadProfileGroup(
    GymProfile profile,
    ActivePlanStore? activePlanStore,
  ) async {
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
    final activePlanIds = await _loadActivePlanIds(
      profileId,
      plans,
      activePlanStore,
    );

    return _ProfileFlowGroup(
      profile: profile,
      summary: _FlowSummary.fromDefinition(defaultFlow),
      plans: plans,
      activePlanIds: activePlanIds,
    );
  }

  Future<void> _openEditor(Widget editor) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.profile,
          child: editor,
        ),
      ),
    );
    if (!mounted) return;
    await _loadFlows();
  }

  Future<Set<int>?> _loadActivePlanIds(
    int profileId,
    List<_PlanFlow> plans,
    ActivePlanStore? store,
  ) async {
    if (store == null) return null;

    try {
      final activePlanIds = await store.load(profileId);
      return activePlanIds.intersection(plans.map((plan) => plan.id).toSet());
    } catch (_) {
      // Grouping is optional presentation metadata; keep the flow list usable
      // if status cannot be loaded in a preview or older host configuration.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    final appColor = scheme.primary;
    final profileColor = _profileColor(context);
    final planColor = _planColor(context);

    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.profile,
      child: SettingsPageScaffold(
        title: strings.flowPageTitle,
        subtitle: expressive
            ? strings.flowPageSubtitleExpressive
            : strings.flowPageSubtitle,
        icon: Icons.account_tree_outlined,
        heroAccentColor: SettingsAccent.advanced,
        useExpressiveProfileHeroShape: true,
        children: [
          SettingsInfoCard(
            icon: Icons.copy_all_outlined,
            title: strings.flowHowCopiedTitle,
            body: expressive
                ? strings.flowHowCopiedBodyExpressive
                : strings.flowHowCopiedBody,
          ),
          if (expressive)
            const SizedBox(height: 14)
          else ...[
            const SizedBox(height: 14),
            _ScopeLegend(
              appColor: appColor,
              profileColor: profileColor,
              planColor: planColor,
            ),
            const SizedBox(height: 18),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 52),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadFailure != null)
            SafeErrorView(
              title: strings.flowLoadError,
              failure: _loadFailure!,
              onRetry: _loadFlows,
              compact: true,
            )
          else ...[
            _FlowScopeCard(
              color: appColor,
              expressiveSurface: expressiveTokens?.surfacePrimary,
              expressiveForeground: expressiveTokens?.onSurfacePrimary,
              icon: Icons.apps_outlined,
              title: strings.rulesAppDefaultsTitle,
              subtitle: strings.flowAppDefaultsSubtitle,
              initiallyExpanded: true,
              child: _FlowEntryTile(
                color: appColor,
                icon: Icons.account_tree_outlined,
                title: strings.flowAppDefaultEntry,
                summary: _appSummary,
                onTap: () =>
                    _openEditor(const AutoPresetFlowScreen.appDefaults()),
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
                  onOpenProfile: () => _openEditor(
                    AutoPresetFlowScreen.profileDefaults(
                      profileId: _profiles[index].profile.id!,
                      profileName: _profiles[index].profile.name,
                    ),
                  ),
                  onOpenPlan: (plan) =>
                      _openEditor(AutoPresetFlowScreen(presetId: plan.id)),
                ),
                if (index < _profiles.length - 1) const SizedBox(height: 12),
              ],
          ],
        ],
      ),
    );
  }
}

class _ProfileFlowGroup {
  final GymProfile profile;
  final _FlowSummary summary;
  final List<_PlanFlow> plans;
  final Set<int>? activePlanIds;

  const _ProfileFlowGroup({
    required this.profile,
    required this.summary,
    required this.plans,
    required this.activePlanIds,
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
      branches: definition.edges
          .where(
            (edge) => edge.outcome == 'success' || edge.outcome == 'failure',
          )
          .length,
      actions: definition.edges
          .where((edge) => edge.outcome == 'method')
          .length,
    );
  }

  bool get hasContent => nodes > 0 || branches > 0 || actions > 0;

  String label(AppLocalizations strings, {required bool expressive}) {
    if (!hasContent) {
      return expressive ? strings.flowTapToConfigure : strings.flowNoSavedYet;
    }
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
        SettingsLegendChip(
          color: appColor,
          label: AppLocalizations.of(context).rulesAppDefaultsChip,
        ),
        SettingsLegendChip(
          color: profileColor,
          label: AppLocalizations.of(context).rulesGymProfilesTitle,
        ),
        SettingsLegendChip(
          color: planColor,
          label: AppLocalizations.of(context).rulesPlansChip,
        ),
      ],
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
  final Color? expressiveSurface;
  final Color? expressiveForeground;

  const _FlowScopeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
    this.expressiveSurface,
    this.expressiveForeground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final expressive = context.usesExpressivePresentation;
    final neo = context.usesNeoPresentation;
    final cardSurface = expressive
        ? expressiveSurface ?? surfaces.settingsSection
        : neo
        ? surfaces.settingsSection
        : scheme.surfaceContainerHighest.withValues(alpha: .28);
    final cardForeground = expressive
        ? expressiveForeground ?? scheme.onSurface
        : neo
        ? tonosForegroundForSurface(context, cardSurface)
        : scheme.onSurface;
    final cardSecondary = expressive
        ? cardForeground
        : neo
        ? tonosSecondaryForegroundForSurface(context, cardSurface)
        : scheme.onSurfaceVariant;
    final cardRadius = expressive
        ? ExpressiveTrainShapes.activePlans
        : shapes.settingsPanel;
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
                    : color.withValues(alpha: .52),
                width: shapes.outlineWidth,
              ),
      ),
      child: TonosSurfaceTheme(
        surface: cardSurface,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: cardForeground,
          collapsedIconColor: cardForeground,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          collapsedBackgroundColor: neo || expressive
              ? cardSurface
              : color.withValues(alpha: .08),
          backgroundColor: neo || expressive
              ? cardSurface
              : color.withValues(alpha: .04),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .17),
              borderRadius: expressive
                  ? ExpressiveTrainShapes.focusInset
                  : shapes.settingsScopeIcon,
            ),
            child: Icon(
              icon,
              color: neo || expressive ? cardForeground : color,
              size: 22,
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: neo || expressive ? cardForeground : null,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: cardSecondary),
          ),
          children: [child],
        ),
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
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = context.usesExpressivePresentation
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    return _FlowScopeCard(
      color: profileColor,
      expressiveSurface: expressiveTokens?.surfaceSecondary,
      expressiveForeground: expressiveTokens?.onSurfaceSecondary,
      icon: Icons.fitness_center_outlined,
      title: group.profile.name,
      subtitle: expressive
          ? strings.flowPlansAvailableExpressive(group.plans.length)
          : strings.flowPlansAvailable(group.plans.length),
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
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: planColor, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (group.plans.isEmpty)
            _EmptyFlowsCard(message: strings.rulesNoPlans, compact: true)
          else ...[
            if (!expressive || group.activePlanIds == null) ...[
              ..._planRows(context, group.plans),
            ] else ...[
              ..._planStatusGroup(
                context,
                strings.trainActivePlans,
                group.plans
                    .where((plan) => group.activePlanIds!.contains(plan.id))
                    .toList(),
              ),
              if (group.activePlanIds!.isNotEmpty &&
                  group.activePlanIds!.length < group.plans.length)
                const SizedBox(height: 12),
              ..._planStatusGroup(
                context,
                strings.trainArchivedPlans,
                group.plans
                    .where((plan) => !group.activePlanIds!.contains(plan.id))
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Widget> _planStatusGroup(
    BuildContext context,
    String title,
    List<_PlanFlow> plans,
  ) {
    if (plans.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: planColor, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      ..._planRows(context, plans),
    ];
  }

  List<Widget> _planRows(BuildContext context, List<_PlanFlow> plans) => [
    for (var index = 0; index < plans.length; index++) ...[
      _FlowEntryTile(
        color: planColor,
        icon: Icons.account_tree_outlined,
        title: plans[index].name,
        summary: plans[index].summary,
        onTap: () => onOpenPlan(plans[index]),
      ),
      if (index < plans.length - 1) const SizedBox(height: 8),
    ],
  ];
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
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    final neo = context.usesNeoPresentation;
    final tileSurface = expressive
        ? expressiveTokens!.surfaceAccent
        : neo
        ? surfaces.dialogChoice
        : null;
    final tileForeground = expressive
        ? expressiveTokens!.onSurfaceAccent
        : neo && tileSurface != null
        ? tonosForegroundForSurface(context, tileSurface)
        : scheme.onSurface;
    final tileSecondary = expressive
        ? expressiveTokens!.onSurfaceAccent
        : neo && tileSurface != null
        ? tonosSecondaryForegroundForSurface(context, tileSurface)
        : scheme.onSurfaceVariant;
    return Material(
      color: expressive
          ? tileSurface!
          : neo
          ? tileSurface!
          : color.withValues(alpha: .06),
      borderRadius: expressive ? ExpressiveTrainShapes.planRow : shapes.card,
      child: InkWell(
        borderRadius: expressive ? ExpressiveTrainShapes.planRow : shapes.card,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: expressive
                ? ExpressiveTrainShapes.planRow
                : shapes.card,
            border: expressive
                ? null
                : Border.all(
                    color: neo
                        ? tonosOutlineForSurface(context, tileSurface!)
                        : color.withValues(alpha: .34),
                    width: neo ? shapes.outlineWidth : 1,
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  borderRadius: expressive
                      ? ExpressiveTrainShapes.compactControl
                      : shapes.control,
                ),
                child: Icon(
                  icon,
                  color: neo || expressive ? tileForeground : color,
                  size: 20,
                ),
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
                        color: neo || expressive ? tileForeground : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.label(
                        AppLocalizations.of(context),
                        expressive: context.usesExpressivePresentation,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: tileSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: neo || expressive ? tileForeground : color,
              ),
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
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
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
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.profile,
            Theme.of(context).brightness,
          )
        : null;
    final neo = context.usesNeoPresentation;
    final emptySurface = neo ? surfaces.panel : null;
    final foreground = expressive
        ? expressiveTokens!.onSurfaceTertiary
        : neo && emptySurface != null
        ? tonosForegroundForSurface(context, emptySurface)
        : scheme.onSurfaceVariant;
    final secondary = foreground;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: expressive
            ? expressiveTokens!.surfaceTertiary
            : neo
            ? emptySurface
            : scheme.surfaceContainerHighest.withValues(alpha: .24),
        borderRadius: shapes.card,
        border: expressive
            ? null
            : Border.all(
                color: neo
                    ? tonosOutlineForSurface(context, emptySurface!)
                    : scheme.outlineVariant.withValues(alpha: .5),
                width: neo ? shapes.outlineWidth : 1,
              ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: foreground),
          const SizedBox(width: 10),
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

Color _profileColor(BuildContext context) {
  return context.flowTokens.profileScope;
}

Color _planColor(BuildContext context) {
  return context.flowTokens.planScope;
}
