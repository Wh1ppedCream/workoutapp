import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/app_localization_extensions.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/catalog_entity_localizer.dart';
import '../../../services/safe_failure.dart';
import '../../exercise/exercise_catalog_page.dart';
import '../../../widgets/localized_catalog_entity_name.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';
import '../../../utils/localized_body_part_name.dart';

class ExerciseAnalyticsScreen extends StatefulWidget {
  final ExerciseDefinition? initialDefinition;

  const ExerciseAnalyticsScreen({super.key, this.initialDefinition});

  @override
  State<ExerciseAnalyticsScreen> createState() =>
      _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends State<ExerciseAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  AppRepository get _repo => context.read<AppRepository>();
  late final TabController _tabController;

  // --- Definitions ---
  ExerciseDefinition? _sel;
  bool _isLoadingDefs = true;
  SafeFailure? _definitionsFailure;

  // --- Muscles tab ---
  List<ExerciseMusclePercent> _muscleEntries = [];
  ExerciseAllocationSource _muscleSource = ExerciseAllocationSource.automatic;
  bool _isLoadingMuscles = false;

  // --- BodyParts tab ---
  Map<BodyPart, double> _bodyEntries = {};
  ExerciseAllocationSource _bodyPartSource = ExerciseAllocationSource.automatic;
  bool _isLoadingBody = false;

  final Map<int, TextEditingController> _muscleCreditControllers = {};
  final Map<int, TextEditingController> _bodyPartCreditControllers = {};
  bool _muscleCreditsDirty = false;
  bool _bodyPartCreditsDirty = false;
  bool _isSavingCredits = false;

  AppLocalizations get _strings => AppLocalizations.of(context);

  bool get _hasPendingCreditChanges =>
      _muscleCreditsDirty || _bodyPartCreditsDirty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDefinitions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers(_muscleCreditControllers);
    _disposeControllers(_bodyPartCreditControllers);
    super.dispose();
  }

  void _disposeControllers(Map<int, TextEditingController> controllers) {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
  }

  void _replaceControllers(
    Map<int, TextEditingController> controllers,
    Map<int, double> credits,
  ) {
    _disposeControllers(controllers);
    for (final entry in credits.entries) {
      controllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(2),
      );
    }
  }

  Future<void> _loadDefinitions() async {
    if (mounted) {
      setState(() {
        _isLoadingDefs = true;
        _definitionsFailure = null;
      });
    }
    try {
      final defs = await _repo.lookupDefsDetailed();
      if (!mounted) return;
      final initialDefinition = widget.initialDefinition;
      ExerciseDefinition? initialMatch;
      if (initialDefinition != null) {
        for (final definition in defs) {
          if (definition.id == initialDefinition.id) {
            initialMatch = definition;
            break;
          }
        }
      }
      setState(() {
        _sel = initialMatch ?? (defs.isNotEmpty ? defs.first : null);
        _definitionsFailure = null;
      });
      if (_sel != null) {
        await Future.wait([_loadMuscleEntries(_sel!), _loadBodyEntries(_sel!)]);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _definitionsFailure = SafeFailure.classify(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDefs = false;
        });
      }
    }
  }

  Future<void> _onSelectDef(ExerciseDefinition def) async {
    setState(() {
      _sel = def;
      _muscleEntries = [];
      _bodyEntries = {};
      _muscleCreditsDirty = false;
      _bodyPartCreditsDirty = false;
      _disposeControllers(_muscleCreditControllers);
      _disposeControllers(_bodyPartCreditControllers);
    });
    await Future.wait([_loadMuscleEntries(def), _loadBodyEntries(def)]);
  }

  Future<void> _pickExercise() async {
    final definition = await Navigator.of(context).push<ExerciseDefinition>(
      MaterialPageRoute(
        builder: (_) => ExerciseCatalogPage(onExercisePicked: (_) {}),
      ),
    );
    if (!mounted || definition == null) return;
    await _onSelectDef(definition);
  }

  Future<void> _loadMuscleEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingMuscles = true);
    try {
      final allocation = await _repo.resolveExerciseAllocation(def.id);
      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _muscleEntries =
            def.muscles
                .map(
                  (ranked) => ExerciseMusclePercent(
                    exerciseDefId: def.id,
                    muscleId: ranked.muscle.id,
                    percent: allocation.muscleCredits[ranked.muscle.id] ?? 0,
                  ),
                )
                .toList();
        _muscleSource = allocation.muscleSource;
        _replaceControllers(_muscleCreditControllers, allocation.muscleCredits);
      });
    } catch (e) {
      // swallow: muscle tab will just show empty
    } finally {
      if (mounted) {
        setState(() => _isLoadingMuscles = false);
      }
    }
  }

  Future<void> _loadBodyEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingBody = true);
    try {
      final allocation = await _repo.resolveExerciseAllocation(def.id);
      final allBodyParts = await _repo.fetchAllBodyParts();
      final byId = {for (final bodyPart in allBodyParts) bodyPart.id: bodyPart};
      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _bodyEntries = <BodyPart, double>{
          for (final entry in allocation.bodyPartCredits.entries)
            if (byId[entry.key] != null) byId[entry.key]!: entry.value,
        };
        _bodyPartSource = allocation.bodyPartSource;
        _replaceControllers(
          _bodyPartCreditControllers,
          allocation.bodyPartCredits,
        );
      });
    } catch (e) {
      // swallow
    } finally {
      if (mounted) {
        setState(() => _isLoadingBody = false);
      }
    }
  }

  void _markCreditsDirty(ExerciseAllocationDimension dimension) {
    final isDirty =
        dimension == ExerciseAllocationDimension.muscle
            ? _muscleCreditsDirty
            : _bodyPartCreditsDirty;
    if (isDirty) return;

    setState(() {
      if (dimension == ExerciseAllocationDimension.muscle) {
        _muscleCreditsDirty = true;
      } else {
        _bodyPartCreditsDirty = true;
      }
    });
  }

  Map<int, double>? _creditsFromControllers(
    Map<int, TextEditingController> controllers,
  ) {
    final credits = <int, double>{};
    for (final entry in controllers.entries) {
      final credit = double.tryParse(entry.value.text.trim());
      if (credit == null || !credit.isFinite || credit < 0) {
        return null;
      }
      credits[entry.key] = credit;
    }
    return credits;
  }

  Future<void> _savePendingCredits() async {
    final def = _sel;
    if (def == null || !_hasPendingCreditChanges || _isSavingCredits) return;

    final muscleCredits =
        _muscleCreditsDirty
            ? _creditsFromControllers(_muscleCreditControllers)
            : null;
    final bodyPartCredits =
        _bodyPartCreditsDirty
            ? _creditsFromControllers(_bodyPartCreditControllers)
            : null;
    if ((_muscleCreditsDirty && muscleCredits == null) ||
        (_bodyPartCreditsDirty && bodyPartCredits == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.allocationInvalidCredit)));
      return;
    }

    setState(() => _isSavingCredits = true);
    try {
      await Future.wait([
        if (muscleCredits != null)
          _repo.replacePersonalExerciseAllocationCredits(
            defId: def.id,
            dimension: ExerciseAllocationDimension.muscle,
            credits: muscleCredits,
          ),
        if (bodyPartCredits != null)
          _repo.replacePersonalExerciseAllocationCredits(
            defId: def.id,
            dimension: ExerciseAllocationDimension.bodyPart,
            credits: bodyPartCredits,
          ),
      ]);
      await Future.wait([_loadMuscleEntries(def), _loadBodyEntries(def)]);
      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _muscleCreditsDirty = false;
        _bodyPartCreditsDirty = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.allocationSaved)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_strings.allocationSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingCredits = false);
      }
    }
  }

  Future<void> _resetDimension(ExerciseAllocationDimension dimension) async {
    final def = _sel;
    if (def == null) return;
    if (_hasPendingCreditChanges) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_strings.allocationSaveOrDiscard)));
      return;
    }
    await _repo.resetPersonalExerciseAllocation(
      defId: def.id,
      dimension: dimension,
    );
    await Future.wait([_loadMuscleEntries(def), _loadBodyEntries(def)]);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      floatingActionButton:
          _hasPendingCreditChanges
              ? FloatingActionButton.extended(
                onPressed: _isSavingCredits ? null : _savePendingCredits,
                backgroundColor: SettingsAccent.advanced,
                foregroundColor: Colors.white,
                icon: Icon(
                  _isSavingCredits ? Icons.hourglass_top : Icons.save_outlined,
                ),
                label: Text(
                  _isSavingCredits
                      ? strings.allocationSaving
                      : strings.allocationSaveChanges,
                ),
              )
              : null,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: strings.commonBack,
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SettingsHeroCard(
                      title: strings.allocationTitle,
                      subtitle: strings.allocationSubtitle,
                      icon: Icons.account_tree_outlined,
                      accentColor: SettingsAccent.advanced,
                    ),
                  ),
                ),
                if (!_isLoadingDefs &&
                    _definitionsFailure == null &&
                    _sel != null) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SettingsInfoCard(
                        icon: Icons.info_outline,
                        title: strings.allocationHowTitle,
                        body: strings.allocationHowBody,
                        iconColor: SettingsAccent.advanced,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildExercisePicker(context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _AllocationTabBarDelegate(
                      backgroundColor: scheme.surface,
                      child: _buildTabBar(context),
                    ),
                  ),
                ],
              ],
          body: _buildTabBody(context),
        ),
      ),
    );
  }

  Widget _buildTabBody(BuildContext context) {
    if (_isLoadingDefs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_definitionsFailure != null) {
      return SafeErrorView(
        title: _strings.safeFailureLoadTitle,
        failure: _definitionsFailure!,
        onRetry: _loadDefinitions,
      );
    }

    if (_sel == null) {
      return Center(child: Text(_strings.allocationNoExercises));
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildMuscleTab(context), _buildBodyPartTab(context)],
    );
  }

  Widget _buildExercisePicker(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _pickExercise,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SettingsAccent.advanced.withValues(alpha: 0.42),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SettingsAccent.advanced.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: SettingsAccent.advanced,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _strings.allocationSelectedExercise,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _sel!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: SettingsAccent.advanced.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: SettingsAccent.advanced,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        tabs: [
          Tab(text: _strings.allocationMuscleCredit),
          Tab(text: _strings.allocationBodypartCredit),
        ],
      ),
    );
  }

  Widget _buildMuscleTab(BuildContext context) {
    if (_isLoadingMuscles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_muscleEntries.isEmpty) {
      return _AllocationEmptyState(
        icon: Icons.account_tree_outlined,
        title: _strings.allocationNoTargetMuscles,
        body: _strings.allocationNoTargetMusclesBody,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
      itemCount: _muscleEntries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _AllocationSectionHeader(
            title: _strings.allocationMuscleCredit,
            body: _strings.allocationMuscleCreditBody,
            source: _muscleSource,
            onReset:
                _muscleSource == ExerciseAllocationSource.personalOverride
                    ? () => _resetDimension(ExerciseAllocationDimension.muscle)
                    : null,
          );
        }

        final entry = _muscleEntries[index - 1];
        final muscle =
            _sel!.muscles
                .firstWhere((ranked) => ranked.muscle.id == entry.muscleId)
                .muscle;
        return _MuscleCreditCard(
          muscle: muscle,
          source: _muscleSource,
          controller: _muscleCreditControllers[entry.muscleId]!,
          onChanged:
              () => _markCreditsDirty(ExerciseAllocationDimension.muscle),
          onSubmitted: _savePendingCredits,
        );
      },
    );
  }

  Widget _buildBodyPartTab(BuildContext context) {
    if (_isLoadingBody) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bodyEntries.isEmpty) {
      return _AllocationEmptyState(
        icon: Icons.accessibility_new,
        title: _strings.allocationNoBodypartMapping,
        body: _strings.allocationNoBodypartMappingBody,
      );
    }

    final entries =
        _bodyEntries.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _AllocationSectionHeader(
            title: _strings.allocationBodypartCredit,
            body: _strings.allocationBodypartCreditBody,
            source: _bodyPartSource,
            onReset:
                _bodyPartSource == ExerciseAllocationSource.personalOverride
                    ? () =>
                        _resetDimension(ExerciseAllocationDimension.bodyPart)
                    : null,
          );
        }

        final entry = entries[index - 1];
        return _BodyPartCreditCard(
          bodyPart: entry.key,
          source: _bodyPartSource,
          controller: _bodyPartCreditControllers[entry.key.id]!,
          onChanged:
              () => _markCreditsDirty(ExerciseAllocationDimension.bodyPart),
          onSubmitted: _savePendingCredits,
        );
      },
    );
  }
}

class _AllocationTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Widget child;

  const _AllocationTabBarDelegate({
    required this.backgroundColor,
    required this.child,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AllocationTabBarDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.child != child;
  }
}

class _AllocationSectionHeader extends StatelessWidget {
  final String title;
  final String body;
  final ExerciseAllocationSource source;
  final VoidCallback? onReset;

  const _AllocationSectionHeader({
    required this.title,
    required this.body,
    required this.source,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: SettingsAccent.advanced,
                  ),
                ),
              ),
              if (onReset != null)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 17),
                  label: Text(AppLocalizations.of(context).allocationReset),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 2, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _sourceColor(source).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              source.localizedLabel(AppLocalizations.of(context)),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _sourceColor(source),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceColor(ExerciseAllocationSource source) => switch (source) {
  ExerciseAllocationSource.automatic => SettingsAccent.training,
  ExerciseAllocationSource.creatorDefault => SettingsAccent.progress,
  ExerciseAllocationSource.personalOverride => SettingsAccent.advanced,
  ExerciseAllocationSource.legacy => SettingsAccent.muted,
};

class _MuscleCreditCard extends StatelessWidget {
  final Muscle muscle;
  final ExerciseAllocationSource source;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final Future<void> Function() onSubmitted;

  const _MuscleCreditCard({
    required this.muscle,
    required this.source,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (source == ExerciseAllocationSource.personalOverride
                  ? SettingsAccent.advanced
                  : scheme.outlineVariant)
              .withValues(
                alpha:
                    source == ExerciseAllocationSource.personalOverride
                        ? 0.58
                        : 0.56,
              ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: SettingsAccent.advanced.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 19,
              color: SettingsAccent.advanced,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedCatalogEntityName(
                  entity: CatalogEntityDisplayName(
                    catalogId: muscle.catalogId,
                    canonicalName: muscle.name,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  source.localizedLabel(AppLocalizations.of(context)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        source == ExerciseAllocationSource.personalOverride
                            ? SettingsAccent.advanced
                            : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).allocationCredit,
                isDense: true,
              ),
              onChanged: (_) => onChanged(),
              onFieldSubmitted: (_) => onSubmitted(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPartCreditCard extends StatelessWidget {
  final BodyPart bodyPart;
  final ExerciseAllocationSource source;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final Future<void> Function() onSubmitted;

  const _BodyPartCreditCard({
    required this.bodyPart,
    required this.source,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sourceColor(source).withValues(alpha: 0.48)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: SettingsAccent.training.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.accessibility_new,
              size: 20,
              color: SettingsAccent.training,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizedBodyPartName(context, bodyPart.name),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 76,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).allocationCredit,
                isDense: true,
              ),
              onChanged: (_) => onChanged(),
              onFieldSubmitted: (_) => onSubmitted(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AllocationEmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
