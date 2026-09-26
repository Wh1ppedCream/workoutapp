import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/body_heatmap.dart';
import '../widgets/exercise_media_thumbnail.dart';
import '../widgets/focused_sets_list.dart';
import '../widgets/generic_bar.dart';
import '../widgets/settings_tiles.dart';
import '../widgets/seven_day_focus_card.dart';
import '../widgets/session_complete_sheet.dart';
import '../widgets/tonos_bottom_navigation_bar.dart';
import '../widgets/tonos_train_tabs.dart';
import '../widgets/weight_card.dart';
import 'theme_extensions.dart';
import 'widgets/tonos_action.dart';
import 'widgets/tonos_dialog.dart';
import 'widgets/tonos_surface.dart';
import 'widgets/workout_actions.dart';

/// Development-only pilot compositions used to review the Neo-Brutalism recipe.
enum NeoPilotPreview { train, workout, userInformation, weightUnits }

extension NeoPilotPreviewLabels on NeoPilotPreview {
  String get label => switch (this) {
    NeoPilotPreview.train => 'Train',
    NeoPilotPreview.workout => 'Workout',
    NeoPilotPreview.userInformation => 'User Information',
    NeoPilotPreview.weightUnits => 'Weight Units',
  };
}

class NeoBrutalismPilotGallery extends StatefulWidget {
  const NeoBrutalismPilotGallery({super.key, this.resetToken = 0});

  /// Changes whenever Theme Lab asks the fixture state to return to defaults.
  final int resetToken;

  @override
  State<NeoBrutalismPilotGallery> createState() =>
      _NeoBrutalismPilotGalleryState();
}

class _NeoBrutalismPilotGalleryState extends State<NeoBrutalismPilotGallery> {
  NeoPilotPreview _pilot = NeoPilotPreview.train;
  int _trainTab = 0;
  int _bottomTab = 0;
  bool _workoutFinished = false;
  bool _showCompletionLoading = false;
  bool _showCompletionError = false;
  bool _showEmptyPlan = false;
  bool _showUserError = false;
  String _gender = 'Male';
  String _unit = 'Pounds';
  late WeightExercise _workoutExercise;
  late WeightExercise _secondaryWorkoutExercise;
  final _nameController = TextEditingController(text: 'Alex');
  final _dateController = TextEditingController(text: '1990-01-01');
  final _heightController = TextEditingController(text: '180');
  final _weightController = TextEditingController(text: '80');

  @override
  void initState() {
    super.initState();
    _workoutExercise = _createWorkoutExercise();
    _secondaryWorkoutExercise = _createSecondaryWorkoutExercise();
  }

  @override
  void didUpdateWidget(covariant NeoBrutalismPilotGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      _resetFixtureState();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  WeightExercise _createWorkoutExercise() => WeightExercise(
    name: 'Barbell Squat',
    equipment: 'Barbell',
    sets: [
      ExerciseSet(weight: 40, reps: 8),
      ExerciseSet(weight: 40, reps: 8),
      ExerciseSet(weight: 40, reps: 8),
    ],
    completedParents: {0},
  );

  WeightExercise _createSecondaryWorkoutExercise() => WeightExercise(
    name: 'Bench Press - Barbell',
    equipment: 'Barbell',
    sets: [
      ExerciseSet(weight: 0, reps: 8),
      ExerciseSet(weight: 0, reps: 8),
      ExerciseSet(weight: 0, reps: 8),
    ],
  );

  void _resetFixtureState() {
    _pilot = NeoPilotPreview.train;
    _trainTab = 0;
    _bottomTab = 0;
    _workoutFinished = false;
    _showCompletionLoading = false;
    _showCompletionError = false;
    _showEmptyPlan = false;
    _showUserError = false;
    _gender = 'Male';
    _unit = 'Pounds';
    _workoutExercise = _createWorkoutExercise();
    _secondaryWorkoutExercise = _createSecondaryWorkoutExercise();
    _nameController.text = 'Alex';
    _dateController.text = '1990-01-01';
    _heightController.text = '180';
    _weightController.text = '80';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Neo-Brutalism pilot previews'),
        const SizedBox(height: 8),
        DropdownButtonFormField<NeoPilotPreview>(
          key: const ValueKey('theme-lab-pilot-dropdown'),
          value: _pilot,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Pilot preview'),
          items: [
            for (final pilot in NeoPilotPreview.values)
              DropdownMenuItem(value: pilot, child: Text(pilot.label)),
          ],
          onChanged: (pilot) {
            if (pilot != null) setState(() => _pilot = pilot);
          },
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: theme.motionTokens.standard,
          curve: theme.motionTokens.standardCurve,
          alignment: Alignment.topCenter,
          child: switch (_pilot) {
            NeoPilotPreview.train => _buildTrain(context),
            NeoPilotPreview.workout => _buildWorkout(context),
            NeoPilotPreview.userInformation => _buildUserInformation(context),
            NeoPilotPreview.weightUnits => _buildWeightUnits(context),
          },
        ),
      ],
    );
  }

  Widget _buildTrain(BuildContext context) {
    final colors = _colors(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    return Column(
      key: const ValueKey('neo-pilot-train'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Train', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Container(
              key: const ValueKey('neo-pilot-profile-avatar'),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.green,
                border: Border.all(color: colors.panelInk, width: 2),
                shape: BoxShape.circle,
              ),
              child: Text(
                'G',
                style: TextStyle(
                  color: colors.panelInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TonosTrainTabs(
          key: const ValueKey('neo-pilot-train-selector'),
          overviewLabel: 'Overview',
          plansLabel: 'Plans',
          selectedIndex: _trainTab,
          onChanged: (index) => setState(() => _trainTab = index),
        ),
        const SizedBox(height: 12),
        SevenDayFocusPresentation(
          key: const ValueKey('neo-pilot-weekly-overview'),
          heatmapFrequencyMap: bodyPartFrequencyMapFromNames({
            'Quads': 1.0,
            'Chest': 0.7,
            'Upper Back': 0.5,
          }),
          hits: [
            FocusedSetHit(bodyPart: BodyPart(1, 'Quads'), units: 6),
            FocusedSetHit(bodyPart: BodyPart(2, 'Chest'), units: 6),
            FocusedSetHit(bodyPart: BodyPart(3, 'Upper Back'), units: 3),
            FocusedSetHit(bodyPart: BodyPart(4, 'Calves'), units: 2),
          ],
          onFocusedSetsTap:
              () => _showFeedback(context, 'Weekly details are preview-only.'),
        ),
        const SizedBox(height: 12),
        if (!_showEmptyPlan)
          _panel(
            context,
            key: const ValueKey('neo-pilot-active-plans'),
            color: colors.pink,
            foregroundColor: colors.panelInk,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Active Plans', style: _heading(context)),
                const SizedBox(height: 8),
                GenericBar(
                  key: const ValueKey('neo-pilot-active-plan-row'),
                  label: 'Full Body',
                  fillColor: colors.cyan,
                  foregroundColor: colors.panelInk,
                  markerColor: const Color(0xFF1976D2),
                  leading: ExerciseMediaFrame(
                    size: 52,
                    padding: const EdgeInsets.all(2),
                    borderRadius: BorderRadius.circular(8),
                    child: BodyHeatmap(
                      frequencyMap: bodyPartFrequencyMapFromNames({
                        'Quads': 1.0,
                        'Chest': 0.7,
                      }),
                      lowColor: tonosHeatmapLowForSurface(
                        context,
                        context.surfaceTokens.mediaPlaceholder,
                      ),
                      highColor: tonosHeatmapHighForSurface(
                        context,
                        context.surfaceTokens.mediaPlaceholder,
                      ),
                      width: 48,
                      height: 48,
                    ),
                  ),
                  trailing: const Icon(Icons.more_vert),
                  onTap:
                      () => _showFeedback(
                        context,
                        'Plan details are preview-only.',
                      ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (largeText)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TonosAction(
                key: const ValueKey('neo-pilot-start-workout'),
                label: 'Start Workout',
                icon: const Icon(Icons.play_arrow),
                expand: true,
                onPressed:
                    () => _showFeedback(
                      context,
                      'Start Workout is preview-only.',
                    ),
              ),
              const SizedBox(height: 8),
              TonosAction(
                key: const ValueKey('neo-pilot-optimize'),
                label: 'Optimize',
                icon: const Icon(Icons.tune),
                variant: TonosActionVariant.tonal,
                expand: true,
                onPressed:
                    () => _showFeedback(context, 'Optimize is preview-only.'),
              ),
              const SizedBox(height: 8),
              TonosAction(
                key: const ValueKey('neo-pilot-empty-plan'),
                label: _showEmptyPlan ? 'Show active plan' : 'Show empty plan',
                variant: TonosActionVariant.outlined,
                expand: true,
                onPressed:
                    () => setState(() => _showEmptyPlan = !_showEmptyPlan),
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TonosAction(
                key: const ValueKey('neo-pilot-start-workout'),
                label: 'Start Workout',
                icon: const Icon(Icons.play_arrow),
                onPressed:
                    () => _showFeedback(
                      context,
                      'Start Workout is preview-only.',
                    ),
              ),
              TonosAction(
                key: const ValueKey('neo-pilot-optimize'),
                label: 'Optimize',
                icon: const Icon(Icons.tune),
                variant: TonosActionVariant.tonal,
                onPressed:
                    () => _showFeedback(context, 'Optimize is preview-only.'),
              ),
              TonosAction(
                key: const ValueKey('neo-pilot-empty-plan'),
                label: _showEmptyPlan ? 'Show active plan' : 'Show empty plan',
                variant: TonosActionVariant.outlined,
                onPressed:
                    () => setState(() => _showEmptyPlan = !_showEmptyPlan),
              ),
            ],
          ),
        if (_showEmptyPlan)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _panel(
              context,
              color: colors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'No active plans',
                    style: _heading(context, color: colors.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text('Create a plan to see it here.'),
                  const SizedBox(height: 8),
                  TonosAction(
                    label: 'Create plan',
                    onPressed:
                        () => _showFeedback(
                          context,
                          'Create plan is preview-only.',
                        ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        _continuousNavigation(context),
      ],
    );
  }

  Widget _buildWorkout(BuildContext context) {
    return Column(
      key: const ValueKey('neo-pilot-workout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeightCard(
          key: const ValueKey('neo-pilot-weight-card'),
          exercise: _workoutExercise,
          previewWeightUnit: WeightUnit.pounds,
          firstSetWeightKey: const ValueKey('neo-pilot-first-weight'),
          firstSetRepsKey: const ValueKey('neo-pilot-first-reps'),
          addSetKey: const ValueKey('neo-pilot-add-set'),
          onSetAdded: () => setState(() {}),
          onValueChanged: () => setState(() {}),
        ),
        WeightCard(
          key: const ValueKey('neo-pilot-secondary-weight-card'),
          exercise: _secondaryWorkoutExercise,
          previewWeightUnit: WeightUnit.pounds,
          forceCollapsed: true,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            WorkoutFinishAction(
              buttonKey: const ValueKey('neo-pilot-finish-workout'),
              label: _workoutFinished ? 'Workout Ready' : 'Finish Workout',
              onPressed: () {
                setState(() {
                  _workoutFinished = true;
                  _showCompletionLoading = false;
                  _showCompletionError = false;
                });
                _showFeedback(
                  context,
                  'Workout remains local to this preview.',
                );
              },
            ),
            TonosAction(
              key: const ValueKey('neo-pilot-completion-loading'),
              label:
                  _showCompletionLoading ? 'Show completion' : 'Show loading',
              variant: TonosActionVariant.outlined,
              onPressed:
                  () => setState(() {
                    _workoutFinished = true;
                    _showCompletionLoading = !_showCompletionLoading;
                    _showCompletionError = false;
                  }),
            ),
            TonosAction(
              key: const ValueKey('neo-pilot-completion-error'),
              label: _showCompletionError ? 'Show completion' : 'Show error',
              variant: TonosActionVariant.outlined,
              onPressed:
                  () => setState(() {
                    _workoutFinished = true;
                    _showCompletionError = !_showCompletionError;
                    _showCompletionLoading = false;
                  }),
            ),
            TonosAction(
              key: const ValueKey('neo-pilot-discard-workout'),
              label: 'Discard Workout',
              variant: TonosActionVariant.destructive,
              onPressed: () {
                setState(() {
                  _workoutFinished = false;
                  _showCompletionLoading = false;
                  _showCompletionError = false;
                });
                _showFeedback(context, 'Workout discarded from this preview.');
              },
            ),
          ],
        ),
        if (_workoutFinished) _buildCompletionPreview(context),
      ],
    );
  }

  Widget _buildCompletionPreview(BuildContext context) {
    if (_showCompletionLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: WorkoutCompletionStatus.loading(),
      );
    }
    if (_showCompletionError) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: WorkoutCompletionStatus.error(
          onClose:
              () => setState(() {
                _workoutFinished = false;
                _showCompletionError = false;
              }),
        ),
      );
    }

    final longValueExercise = WeightExercise(
      name: 'Romanian Deadlift - Barbell',
      equipment: 'Barbell',
      sets: [
        ExerciseSet(weight: 225, reps: 12),
        ExerciseSet(weight: 225, reps: 10),
        ExerciseSet(weight: 220, reps: 8),
      ],
      completedParents: {0, 1, 2},
    );
    const recordBadges = WorkoutExerciseRecordBadges(
      isFirstRecord: true,
      setBadges: {
        0: [
          WorkoutRecordBadge(
            tier: WorkoutRecordBadgeTier.monthly,
            type: WorkoutRecordBadgeType.repBest,
            reps: 12,
          ),
        ],
      },
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: WorkoutCompletionSurface(
        key: const ValueKey('neo-pilot-workout-completion'),
        padding: const EdgeInsets.all(12),
        child: WorkoutCompletionPresentation(
          exercises: [
            WorkoutCompletionExercise(
              exercise: _workoutExercise,
              weightUnit: WeightUnit.pounds,
              badges: recordBadges,
            ),
            WorkoutCompletionExercise(
              exercise: longValueExercise,
              weightUnit: WeightUnit.pounds,
              badges: WorkoutExerciseRecordBadges(isFirstRecord: false),
            ),
          ],
          totalSets:
              _workoutExercise.sets.length + longValueExercise.sets.length,
          duration: '1h 26m',
          volume: '6,710 lbs',
          showHandle: false,
          doneButtonKey: const ValueKey('neo-pilot-workout-done'),
          onDone:
              () => setState(() {
                _workoutFinished = false;
                _showCompletionLoading = false;
                _showCompletionError = false;
              }),
        ),
      ),
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    final inputTextStyle = settingsInputTextStyle(context);
    final surfaces = context.surfaceTokens;
    return Column(
      key: const ValueKey('neo-pilot-user-information'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHeroCard(
          title: 'User information',
          subtitle:
              'Keep basic profile details available for app calculations.',
          icon: Icons.badge_outlined,
          accentColor: SettingsAccent.account,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Identity',
          subtitle: 'Basic personal details.',
          accentColor: SettingsAccent.account,
          surfaceColor: surfaces.settingsSection,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _pilotField(
                    context,
                    'Name',
                    _nameController,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    isExpanded: true,
                    itemHeight: null,
                    dropdownColor: surfaces.settingsInput,
                    style: inputTextStyle,
                    iconEnabledColor: inputTextStyle?.color,
                    decoration: settingsInputDecoration(
                      context,
                      label: 'Gender',
                      icon: Icons.people_outline,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _gender = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  _pilotField(
                    context,
                    'Date of birth',
                    _dateController,
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Body metrics',
          accentColor: SettingsAccent.progress,
          surfaceColor: surfaces.planDuration,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _pilotField(
                    context,
                    'Height',
                    _heightController,
                    Icons.height,
                  ),
                  const SizedBox(height: 10),
                  _pilotField(
                    context,
                    'Current weight',
                    _weightController,
                    Icons.monitor_weight_outlined,
                    suffixText: 'lbs',
                  ),
                  const SizedBox(height: 10),
                  _pilotField(
                    context,
                    'Body-fat % estimate',
                    null,
                    Icons.percent,
                    enabled: false,
                  ),
                  const SizedBox(height: 10),
                  _pilotField(
                    context,
                    'Validation example',
                    null,
                    Icons.error_outline,
                    errorText: _showUserError ? 'Enter a valid value.' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        TonosAction(
          key: const ValueKey('neo-pilot-toggle-user-error'),
          label:
              _showUserError
                  ? 'Hide validation error'
                  : 'Show validation error',
          variant: TonosActionVariant.outlined,
          onPressed: () => setState(() => _showUserError = !_showUserError),
        ),
        const SizedBox(height: 12),
        SettingsSaveBar(
          label: 'Save changes',
          onPressed:
              () => _showFeedback(context, 'Preview changes kept locally.'),
        ),
      ],
    );
  }

  Widget _buildWeightUnits(BuildContext context) {
    final colors = _colors(context);
    return Column(
      key: const ValueKey('neo-pilot-weight-units'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          context,
          color: colors.yellow,
          raised: true,
          foregroundColor: colors.panelInk,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Weight Units', style: _heading(context)),
              const SizedBox(height: 4),
              Text(
                'Current selection: $_unit / ${_unit == 'Pounds' ? 'lbs' : 'kg'}',
              ),
              const SizedBox(height: 12),
              TonosAction(
                key: const ValueKey('neo-pilot-open-weight-units'),
                label: 'Open Weight Units',
                onPressed: () => _openWeightUnits(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          context,
          color: colors.purple,
          foregroundColor: colors.panelInk,
          child: const Text(
            'The dialog keeps the selected value, supports dismissal, and does not write to the profile.',
          ),
        ),
      ],
    );
  }

  Future<void> _openWeightUnits(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder:
          (_) => TonosChoiceDialog<String>(
            title: 'Weight Units',
            values: const ['Pounds', 'Kilograms'],
            selected: _unit,
            label: (unit) => unit,
            subtitle: (unit) => unit == 'Pounds' ? 'lbs' : 'kg',
            choiceKey: (unit) => ValueKey('neo-pilot-unit-$unit'),
          ),
    );
    if (mounted && selected != null) setState(() => _unit = selected);
  }

  Widget _pilotField(
    BuildContext context,
    String label,
    TextEditingController? controller,
    IconData icon, {
    bool enabled = true,
    String? errorText,
    String? suffixText,
  }) {
    final inputStyle = settingsInputTextStyle(context, enabled: enabled);
    return TextField(
      controller: controller,
      enabled: enabled,
      style: inputStyle,
      cursorColor: inputStyle?.color,
      decoration: settingsInputDecoration(
        context,
        label: label,
        icon: icon,
        suffixText: suffixText,
      ).copyWith(errorText: errorText),
    );
  }

  Widget _continuousNavigation(BuildContext context) {
    return TonosBottomNavigationBar(
      key: const ValueKey('neo-pilot-bottom-navigation'),
      currentIndex: _bottomTab,
      onTap: (index) => setState(() => _bottomTab = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Train',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logbook'),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _panel(
    BuildContext context, {
    Key? key,
    required Color color,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    bool raised = false,
    Color? foregroundColor,
  }) {
    return TonosSurface(
      key: key,
      variant:
          raised ? TonosSurfaceVariant.panelRaised : TonosSurfaceVariant.panel,
      color: color,
      padding: padding,
      borderRadius: BorderRadius.circular(8),
      child:
          foregroundColor == null
              ? child
              : DefaultTextStyle.merge(
                style: TextStyle(color: foregroundColor),
                child: IconTheme.merge(
                  data: IconThemeData(color: foregroundColor),
                  child: child,
                ),
              ),
    );
  }

  TextStyle _heading(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        color: color ?? _colors(context).panelInk,
        fontWeight: FontWeight.w800,
      );

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  _NeoPilotPalette _colors(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    return _NeoPilotPalette(
      ink: theme.colorScheme.onSurface,
      panelInk: const Color(0xFF161616),
      yellow: theme.colorScheme.primary,
      purple: theme.colorScheme.secondary,
      cyan: theme.colorScheme.tertiary,
      green: semantic.workoutCompleted,
      pink: semantic.swapCancel,
      surface: theme.colorScheme.surface,
    );
  }
}

class _NeoPilotPalette {
  const _NeoPilotPalette({
    required this.ink,
    required this.panelInk,
    required this.yellow,
    required this.purple,
    required this.cyan,
    required this.green,
    required this.pink,
    required this.surface,
  });

  final Color ink;
  final Color panelInk;
  final Color yellow;
  final Color purple;
  final Color cyan;
  final Color green;
  final Color pink;
  final Color surface;
}
