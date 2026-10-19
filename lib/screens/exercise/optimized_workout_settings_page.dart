import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/expressive_planning_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/widgets/tonos_field.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/bodypart_focus_chips.dart';
import '../../widgets/guided_tutorial_overlay.dart';

enum OptimizedWorkoutSettingsAction { save, startNow }

class OptimizedWorkoutSettingsResult {
  final OptimizedWorkoutSettingsAction action;
  final int minutes;
  final int minSets;
  final int maxSets;
  final RepWeightGenerationMode repWeightMode;
  final int targetRepCount;
  final StarterWeightIntensity starterWeightIntensity;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const OptimizedWorkoutSettingsResult({
    required this.action,
    required this.minutes,
    required this.minSets,
    required this.maxSets,
    required this.repWeightMode,
    required this.targetRepCount,
    required this.starterWeightIntensity,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

class OptimizedWorkoutSettingsPage extends StatefulWidget {
  final int initialMinutes;
  final int initialMinSets;
  final int initialMaxSets;
  final RepWeightGenerationMode initialRepWeightMode;
  final int initialTargetRepCount;
  final StarterWeightIntensity initialStarterWeightIntensity;
  final Set<int> initialPreferredBodypartIds;
  final Set<int> initialBlacklistedBodypartIds;
  final List<BodyPart> bodyParts;

  const OptimizedWorkoutSettingsPage({
    super.key,
    required this.initialMinutes,
    required this.initialMinSets,
    required this.initialMaxSets,
    required this.initialRepWeightMode,
    required this.initialTargetRepCount,
    required this.initialStarterWeightIntensity,
    required this.initialPreferredBodypartIds,
    required this.initialBlacklistedBodypartIds,
    required this.bodyParts,
  });

  @override
  State<OptimizedWorkoutSettingsPage> createState() =>
      _OptimizedWorkoutSettingsPageState();
}

class _OptimizedWorkoutSettingsPageState
    extends State<OptimizedWorkoutSettingsPage> {
  final _budgetTutorialKey = GlobalKey(debugLabel: 'optimized_budget');
  final _repWeightTutorialKey = GlobalKey(debugLabel: 'optimized_rep_weight');
  final _focusTutorialKey = GlobalKey(debugLabel: 'optimized_focus');
  final _resetTutorialKey = GlobalKey(debugLabel: 'optimized_reset');
  final _actionsTutorialKey = GlobalKey(debugLabel: 'optimized_actions');
  late final TextEditingController _minutesController;
  late final TextEditingController _minSetsController;
  late final TextEditingController _maxSetsController;
  late final TextEditingController _targetRepsController;
  late RepWeightGenerationMode _repWeightMode;
  late StarterWeightIntensity _starterWeightIntensity;
  late Set<int> _preferredBodypartIds;
  late Set<int> _blacklistedBodypartIds;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.initialMinutes.toString(),
    );
    _minSetsController = TextEditingController(
      text: widget.initialMinSets.toString(),
    );
    _maxSetsController = TextEditingController(
      text: widget.initialMaxSets.toString(),
    );
    _targetRepsController = TextEditingController(
      text: widget.initialTargetRepCount.toString(),
    );
    _repWeightMode = widget.initialRepWeightMode;
    _starterWeightIntensity = widget.initialStarterWeightIntensity;
    _preferredBodypartIds = {...widget.initialPreferredBodypartIds};
    _blacklistedBodypartIds = {...widget.initialBlacklistedBodypartIds};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _minSetsController.dispose();
    _maxSetsController.dispose();
    _targetRepsController.dispose();
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _minutesController.text = SessionSpec.defaultSessionDurationMinutes
          .toString();
      _minSetsController.text = SessionSpec.preferredMinSetsPerExercise
          .toString();
      _maxSetsController.text = SessionSpec.defaultMaxSetsPerExercise
          .toString();
      _targetRepsController.text = SessionSpec.defaultTargetRepCount.toString();
      _repWeightMode = RepWeightGenerationMode.mixed;
      _starterWeightIntensity = StarterWeightIntensity.medium;
      _preferredBodypartIds = <int>{};
      _blacklistedBodypartIds = <int>{};
    });
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
        tutorialId: TutorialIds.optimizedWorkoutSettings,
        steps: [
          GuidedTutorialStep(
            targetKey: _budgetTutorialKey,
            icon: Icons.timer_outlined,
            title: strings.optimizedTutorialBudgetTitle,
            body: strings.optimizedTutorialBudgetBody,
          ),
          GuidedTutorialStep(
            targetKey: _repWeightTutorialKey,
            icon: Icons.fitness_center_outlined,
            title: strings.optimizedTutorialRepsTitle,
            body: strings.optimizedTutorialRepsBody,
          ),
          GuidedTutorialStep(
            targetKey: _focusTutorialKey,
            icon: Icons.track_changes_outlined,
            title: strings.optimizedTutorialFocusTitle,
            body: strings.optimizedTutorialFocusBody,
          ),
          GuidedTutorialStep(
            targetKey: _resetTutorialKey,
            icon: Icons.refresh,
            title: strings.commonReset,
            body: strings.optimizedTutorialResetBody,
          ),
          GuidedTutorialStep(
            targetKey: _actionsTutorialKey,
            icon: Icons.play_circle_outline,
            title: strings.optimizedTutorialActionsTitle,
            body: strings.optimizedTutorialActionsBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  void _submit(OptimizedWorkoutSettingsAction action) {
    final minutes = int.tryParse(_minutesController.text.trim());
    final minSets = int.tryParse(_minSetsController.text.trim());
    final maxSets = int.tryParse(_maxSetsController.text.trim());
    final targetReps = int.tryParse(_targetRepsController.text.trim());
    if (minutes == null ||
        minutes <= 0 ||
        minSets == null ||
        minSets < SessionSpec.defaultMinSetsPerExercise ||
        minSets > SessionSpec.maxAllowedSetsPerExercise ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise ||
        minSets > maxSets ||
        targetReps == null ||
        targetReps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).optimizedValidationError(SessionSpec.maxAllowedSetsPerExercise),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      OptimizedWorkoutSettingsResult(
        action: action,
        minutes: minutes,
        minSets: minSets,
        maxSets: maxSets,
        repWeightMode: _repWeightMode,
        targetRepCount: targetReps,
        starterWeightIntensity: _starterWeightIntensity,
        preferredBodypartIds: {..._preferredBodypartIds},
        blacklistedBodypartIds: {..._blacklistedBodypartIds},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final semantic = context.semanticColors;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final expressiveSectionShape = planning == null
        ? null
        : RoundedRectangleBorder(
            borderRadius: planning.focalShape,
            side: BorderSide(color: planning.outline.withValues(alpha: 0.42)),
          );
    final repsWeightsSurface = planning == null
        ? null
        : theme.brightness == Brightness.dark
        ? Color.lerp(
            planning.planSupportSurface,
            planning.planFocalSurface,
            0.18,
          )
        : planning.planSupportSurface;
    final fieldBorder = planning == null
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: planning.outline.withValues(alpha: 0.56),
            ),
          );
    final fieldFocusBorder = planning == null
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: planning.selectedSurface, width: 2),
          );
    final numericFieldTheme = planning == null
        ? theme
        : theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              bodyLarge: theme.textTheme.bodyLarge?.copyWith(
                color: planning.configurationForeground,
              ),
            ),
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              filled: true,
              fillColor: planning.configurationSurface,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocusBorder,
              border: fieldBorder,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixStyle: TextStyle(
                color: planning.configurationForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    Widget numericField({
      required TextEditingController controller,
      required String label,
      required String suffix,
      required TextInputAction textInputAction,
      required Color? labelColor,
    }) {
      if (planning == null) {
        return TonosFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: textInputAction,
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          TonosFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: textInputAction,
            semanticLabel: label,
            suffixText: suffix,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: planning.outline.withValues(alpha: 0.56),
              ),
            ),
          ),
        ],
      );
    }

    final settingsList = ListView(
      padding: planning == null
          ? const EdgeInsets.fromLTRB(16, 72, 16, 120)
          : const EdgeInsets.fromLTRB(16, 8, 16, 176),
      children: [
        KeyedSubtree(
          key: _budgetTutorialKey,
          child: Card(
            color: planning?.planFocalSurface,
            shape: expressiveSectionShape,
            elevation: planning == null ? null : 2,
            surfaceTintColor: planning == null ? null : Colors.transparent,
            clipBehavior: planning == null ? Clip.none : Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlanningSectionHeading(
                    icon: Icons.timer_outlined,
                    title: Text(
                      strings.optimizedTutorialBudgetTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: planning?.planFocalForeground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    planning: planning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.optimizedBudgetDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          planning?.planFocalForeground ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Theme(
                    data: numericFieldTheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        numericField(
                          controller: _minutesController,
                          label: strings.optimizedWorkoutDuration,
                          suffix: strings.unitMinutesShort,
                          textInputAction: TextInputAction.next,
                          labelColor: planning?.planFocalForeground,
                        ),
                        const SizedBox(height: 8),
                        numericField(
                          controller: _minSetsController,
                          label: strings.optimizedMinimumSets,
                          suffix: strings.unitSets,
                          textInputAction: TextInputAction.next,
                          labelColor: planning?.planFocalForeground,
                        ),
                        const SizedBox(height: 8),
                        numericField(
                          controller: _maxSetsController,
                          label: strings.optimizedMaximumSets,
                          suffix: strings.unitSets,
                          textInputAction: TextInputAction.done,
                          labelColor: planning?.planFocalForeground,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _repWeightTutorialKey,
          child: Card(
            color: repsWeightsSurface,
            shape: expressiveSectionShape,
            elevation: planning == null ? null : 2,
            surfaceTintColor: planning == null ? null : Colors.transparent,
            clipBehavior: planning == null ? Clip.none : Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlanningSectionHeading(
                    icon: Icons.tune,
                    title: Text(
                      strings.optimizedRepsWeightsTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: planning?.planSupportForeground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    planning: planning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.optimizedRepsWeightsDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          planning?.planSupportForeground ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsChoice<RepWeightGenerationMode>(
                    title: strings.optimizedRepPattern,
                    value: _repWeightMode,
                    options: [
                      _SettingsChoiceOption(
                        value: RepWeightGenerationMode.mixed,
                        label: strings.repModeMixed,
                      ),
                      _SettingsChoiceOption(
                        value: RepWeightGenerationMode.pyramid,
                        label: strings.repModePyramid,
                      ),
                      _SettingsChoiceOption(
                        value: RepWeightGenerationMode.consistent,
                        label: strings.repModeConsistent,
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _repWeightMode = value),
                  ),
                  const SizedBox(height: 10),
                  Theme(
                    data: numericFieldTheme,
                    child: numericField(
                      controller: _targetRepsController,
                      label: strings.optimizedTargetReps,
                      suffix: strings.unitReps,
                      textInputAction: TextInputAction.next,
                      labelColor: planning?.planSupportForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsChoice<StarterWeightIntensity>(
                    title: strings.optimizedWeightIntensity,
                    value: _starterWeightIntensity,
                    options: [
                      _SettingsChoiceOption(
                        value: StarterWeightIntensity.easy,
                        label: strings.intensityEasy,
                      ),
                      _SettingsChoiceOption(
                        value: StarterWeightIntensity.medium,
                        label: strings.intensityMedium,
                      ),
                      _SettingsChoiceOption(
                        value: StarterWeightIntensity.hard,
                        label: strings.intensityHard,
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _starterWeightIntensity = value),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _focusTutorialKey,
          child: Card(
            color: planning?.configurationSurface,
            shape: expressiveSectionShape,
            elevation: planning == null ? null : 2,
            surfaceTintColor: planning == null ? null : Colors.transparent,
            clipBehavior: planning == null ? Clip.none : Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlanningSectionHeading(
                    icon: Icons.accessibility_new,
                    title: Text(
                      strings.optimizedBodypartFocusTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: planning?.configurationForeground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    planning: planning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.optimizedBodypartFocusDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          planning?.configurationForeground ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (planning != null) ...[
                    const SizedBox(height: 10),
                    _BodypartFocusLegend(
                      tokens: planning,
                      strings: strings,
                      avoidedColor: semantic.negative,
                    ),
                  ],
                  const SizedBox(height: 12),
                  BodypartFocusChips(
                    bodyParts: widget.bodyParts,
                    preferredBodypartIds: _preferredBodypartIds,
                    blacklistedBodypartIds: _blacklistedBodypartIds,
                    emptyText: strings.optimizedBodypartsUnavailable,
                    expressiveTokens: planning,
                    expressiveNeutralSurface:
                        planning == null || theme.brightness == Brightness.dark
                        ? null
                        : Color.lerp(
                            planning.configurationSurface,
                            planning.planSupportSurface,
                            0.28,
                          ),
                    expressiveNeutralOutline:
                        planning == null || theme.brightness == Brightness.dark
                        ? null
                        : planning.outline.withValues(alpha: 0.72),
                    expressiveAvoidedSurfaceOpacity: planning == null
                        ? 0.14
                        : 0.17,
                    expressiveIndicatorSize: planning == null ? 18 : 16,
                    expressiveAvoidedUsesProhibitionIcon: planning != null,
                    expressiveShape: planning == null
                        ? null
                        : RoundedRectangleBorder(
                            borderRadius: planning.rowShape,
                          ),
                    showExpressiveStateIndicators: planning != null,
                    onChanged: (selection) => setState(() {
                      _preferredBodypartIds = selection.preferredBodypartIds;
                      _blacklistedBodypartIds =
                          selection.blacklistedBodypartIds;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    final expressiveActions = planning == null
        ? null
        : KeyedSubtree(
            key: _actionsTutorialKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width;
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final stackActions =
                    availableWidth < 380 ||
                    availableWidth - 32 < 250 * textScale;
                final startNowButton = _buildExpressiveActionButton(
                  planning: planning,
                  label: strings.commonStartNow,
                  tooltip: strings.commonStartNow,
                  icon: Icons.play_arrow_rounded,
                  heroTag: 'optimized-settings-start-now',
                  onPressed: () =>
                      _submit(OptimizedWorkoutSettingsAction.startNow),
                  primary: true,
                );
                final saveButton = _buildExpressiveActionButton(
                  planning: planning,
                  label: strings.commonSave,
                  tooltip: strings.commonSave,
                  icon: Icons.save_outlined,
                  heroTag: 'optimized-settings-save',
                  onPressed: () => _submit(OptimizedWorkoutSettingsAction.save),
                  primary: false,
                );
                if (stackActions) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      startNowButton,
                      const SizedBox(height: 8),
                      saveButton,
                    ],
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    startNowButton,
                    const SizedBox(width: 8),
                    saveButton,
                  ],
                );
              },
            ),
          );
    return Scaffold(
      resizeToAvoidBottomInset: planning == null ? null : true,
      backgroundColor: planning?.pageCanvas,
      appBar: planning == null
          ? null
          : AppBar(
              backgroundColor: planning.pageCanvas,
              foregroundColor: planning.onPage,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: BackButton(onPressed: () => Navigator.of(context).pop()),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.trainOptimizedSettings,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: planning.onPage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              actions: [
                KeyedSubtree(
                  key: _resetTutorialKey,
                  child: IconButton(
                    tooltip: strings.commonReset,
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
      body: planning == null
          ? SafeArea(
              child: Stack(
                children: [
                  settingsList,
                  Positioned(
                    top: 8,
                    left: 16,
                    child: _FloatingHeaderButton(
                      icon: Icons.close,
                      label: strings.commonCancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 16,
                    child: KeyedSubtree(
                      key: _resetTutorialKey,
                      child: _FloatingHeaderButton(
                        icon: Icons.refresh,
                        label: strings.commonReset,
                        onPressed: _resetToDefaults,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(top: false, child: settingsList),
      floatingActionButtonLocation: planning == null
          ? null
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: expressiveActions,
      bottomNavigationBar: planning == null
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: KeyedSubtree(
                key: _actionsTutorialKey,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            _submit(OptimizedWorkoutSettingsAction.startNow),
                        style: FilledButton.styleFrom(
                          backgroundColor: semantic.startWorkoutAction,
                          foregroundColor: semantic.onStartWorkoutAction,
                        ),
                        child: Text(strings.commonStartNow),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            _submit(OptimizedWorkoutSettingsAction.save),
                        child: Text(strings.commonSave),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  FloatingActionButton _buildExpressiveActionButton({
    required AppExpressivePlanningTokens planning,
    required String label,
    required String tooltip,
    required IconData icon,
    required String heroTag,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saveSurface = isDark
        ? Color.lerp(
            planning.configurationSurface,
            planning.actionPrimary,
            0.16,
          )!
        : planning.configurationSurface;
    final foreground = primary
        ? planning.actionPrimaryForeground
        : planning.configurationForeground;
    return FloatingActionButton.extended(
      heroTag: heroTag,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: primary ? planning.actionPrimary : saveSurface,
      foregroundColor: foreground,
      shape: RoundedRectangleBorder(
        borderRadius: planning.rowShape,
        side: BorderSide(
          color: planning.outline.withValues(
            alpha: !primary && isDark ? 0.78 : 0.42,
          ),
        ),
      ),
      elevation: 2,
      focusElevation: 3,
      icon: Icon(icon, color: foreground),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foreground),
      ),
    );
  }
}

class _PlanningSectionHeading extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final AppExpressivePlanningTokens? planning;

  const _PlanningSectionHeading({
    required this.icon,
    required this.title,
    required this.planning,
  });

  @override
  Widget build(BuildContext context) {
    final planning = this.planning;
    if (planning == null) return title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(top: 2, right: 12),
          decoration: BoxDecoration(
            color: planning.planAccent,
            borderRadius: planning.rowShape,
          ),
          child: Icon(icon, color: planning.planAccentForeground),
        ),
        Expanded(child: title),
      ],
    );
  }
}

class _SettingsChoiceOption<T> {
  final T value;
  final String label;

  const _SettingsChoiceOption({required this.value, required this.label});
}

class _SettingsChoice<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<_SettingsChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  const _SettingsChoice({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: planning?.planSupportForeground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = option.value == value;
            return ChoiceChip(
              label: Text(option.label),
              selected: selected,
              selectedColor: planning?.selectedSurface,
              backgroundColor: planning?.configurationSurface,
              showCheckmark: planning != null,
              checkmarkColor: planning?.actionPrimaryForeground,
              side: planning == null
                  ? null
                  : BorderSide(
                      color: selected
                          ? planning.selectedSurface
                          : planning.outline.withValues(alpha: 0.58),
                    ),
              labelStyle: planning == null
                  ? null
                  : TextStyle(
                      color: selected
                          ? planning.actionPrimaryForeground
                          : planning.configurationForeground,
                      fontWeight: FontWeight.w700,
                    ),
              shape: planning == null
                  ? null
                  : RoundedRectangleBorder(borderRadius: planning.rowShape),
              onSelected: (_) => onChanged(option.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BodypartFocusLegend extends StatelessWidget {
  final AppExpressivePlanningTokens tokens;
  final AppLocalizations strings;
  final Color avoidedColor;

  const _BodypartFocusLegend({
    required this.tokens,
    required this.strings,
    required this.avoidedColor,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = tokens.configurationForeground;
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _BodypartFocusLegendItem(
          icon: Icons.check_circle,
          label: _capitalize(strings.generateFocusPreferred),
          color: tokens.actionPrimary,
          foreground: foreground,
        ),
        _BodypartFocusLegendItem(
          icon: Icons.block,
          label: _capitalize(strings.generateFocusAvoided),
          color: avoidedColor,
          foreground: foreground,
        ),
        _BodypartFocusLegendItem(
          icon: Icons.radio_button_unchecked,
          label: _capitalize(strings.generateFocusNeutral),
          color: foreground,
          foreground: foreground,
        ),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value.substring(0, 1).toUpperCase()}${value.substring(1)}';
  }
}

class _BodypartFocusLegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;

  const _BodypartFocusLegendItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _FloatingHeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FloatingHeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final planning = AppExpressivePlanningTokens.maybeOf(context);
    final foreground =
        planning?.planFocalForeground ??
        (neo
            ? tonosForegroundForSurface(context, surfaces.optimizedAction)
            : null);
    return Material(
      color: planning?.planFocalSurface ?? surfaces.optimizedAction,
      borderRadius: planning == null ? shapes.pill : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
