// File: lib/widgets/weight_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_dialog.dart';
import '../theme/widgets/workout_actions.dart';
import '../utils/weight_unit_formatter.dart';
import 'exercise_media_thumbnail.dart';

/// Displays and edits a [WeightExercise], including parent sets and change sets.
///
/// This widget is shared by active workout sessions and preset edit screens, so
/// it owns only presentation/editing state. The backing [WeightExercise] is
/// mutated immediately as users type, while parent widgets decide how/when to
/// persist those changes. Completed parent sets control the green row tint and
/// automatic collapse behavior.
class WeightCard extends StatefulWidget {
  final WeightExercise exercise;
  final bool readOnlyMode;
  final Set<int>? initialCompletedParents;
  final Map<int, Set<int>>? initialCompletedChildren;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onSetAdded;
  final VoidCallback? onSetDeleted;
  final VoidCallback? onValueChanged;
  final VoidCallback? onDetails;
  final int? definitionId;
  final VoidCallback? onSwapExercise;
  final bool forceCollapsed;

  /// Supplies a fixture-only unit without requiring the production provider.
  /// When omitted, the user's [UnitPreferenceProvider] remains authoritative.
  final WeightUnit? previewWeightUnit;
  final Key? firstSetWeightKey;
  final Key? firstSetRepsKey;
  final Key? addSetKey;
  final FocusNode? firstSetWeightFocusNode;
  final FocusNode? firstSetRepsFocusNode;
  final VoidCallback? onFirstSetWeightSubmitted;
  final VoidCallback? onFirstSetRepsSubmitted;

  const WeightCard({
    super.key,
    required this.exercise,
    this.readOnlyMode = false,
    this.initialCompletedParents,
    this.initialCompletedChildren,
    this.onDeleteExercise,
    this.onSetAdded,
    this.onSetDeleted,
    this.onValueChanged,
    this.onDetails,
    this.definitionId,
    this.onSwapExercise,
    this.forceCollapsed = false,
    this.previewWeightUnit,
    this.firstSetWeightKey,
    this.firstSetRepsKey,
    this.addSetKey,
    this.firstSetWeightFocusNode,
    this.firstSetRepsFocusNode,
    this.onFirstSetWeightSubmitted,
    this.onFirstSetRepsSubmitted,
  });

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  /// Parent set controllers stay in index order with [widget.exercise.sets].
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];

  bool _isChangeSetMode = false;
  bool _isCollapsed = false;

  /// Change sets are grouped by parent set index, matching the model shape.
  final Map<int, List<ExerciseSet>> _cSets = {};

  /// Completed parent set indexes for this card.
  final Set<int> _completedSets = {};
  WeightUnit _weightUnit = WeightUnit.pounds;

  @override
  void initState() {
    super.initState();
    _syncFromExercise(resetCollapsed: true);
  }

  @override
  void didUpdateWidget(covariant WeightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final exerciseChanged = oldWidget.exercise != widget.exercise;
    var unitChanged = false;
    if (oldWidget.previewWeightUnit != widget.previewWeightUnit) {
      final nextUnit =
          widget.previewWeightUnit ??
          context.read<UnitPreferenceProvider>().weightUnit;
      unitChanged = nextUnit != _weightUnit;
      _weightUnit = nextUnit;
    }
    if (exerciseChanged || unitChanged) {
      _syncFromExercise(resetCollapsed: exerciseChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previewUnit = widget.previewWeightUnit;
    if (previewUnit != null) {
      if (previewUnit == _weightUnit) return;
      _weightUnit = previewUnit;
      _syncFromExercise(resetCollapsed: false);
      return;
    }
    final nextUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    if (nextUnit == _weightUnit) return;
    _weightUnit = nextUnit;
    _syncFromExercise(resetCollapsed: false);
  }

  /// Rebuilds controllers and local mirrors whenever the card receives a new
  /// exercise instance. Old controllers are disposed after the frame so Flutter
  /// does not trip over a controller that is still attached during rebuild.
  void _syncFromExercise({required bool resetCollapsed}) {
    final oldWeightControllers = _weightControllers;
    final oldRepsControllers = _repsControllers;
    final sets = widget.exercise.sets;
    _weightControllers =
        sets
            .map(
              (s) => TextEditingController(
                text: WeightUnitFormatter.formatInputWeight(
                  s.weight,
                  _weightUnit,
                ),
              ),
            )
            .toList();
    _repsControllers =
        sets
            .map((s) => TextEditingController(text: s.reps.toString()))
            .toList();

    _completedSets.clear();
    if (widget.initialCompletedParents != null) {
      _completedSets.addAll(widget.initialCompletedParents!);
    } else {
      _completedSets.addAll(widget.exercise.completedParents);
    }

    _cSets.clear();
    widget.exercise.changeSets.forEach((parentIdx, children) {
      _cSets[parentIdx] = List<ExerciseSet>.from(children);
    });

    _isChangeSetMode = widget.exercise.changeSets.isNotEmpty;
    if (resetCollapsed) {
      _isCollapsed = _allSetsComplete(sets);
    }
    _disposeControllersAfterFrame([
      ...oldWeightControllers,
      ...oldRepsControllers,
    ]);
  }

  @override
  void dispose() {
    _disposeSetControllers();
    super.dispose();
  }

  void _disposeSetControllers() {
    _disposeControllers([..._weightControllers, ..._repsControllers]);
    _weightControllers = [];
    _repsControllers = [];
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (var c in controllers) {
      c.dispose();
    }
  }

  void _disposeControllersAfterFrame(List<TextEditingController> controllers) {
    if (controllers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _disposeControllers(controllers);
    });
  }

  void _updateWeightSet(int index) {
    final displayedWeight =
        double.tryParse(_weightControllers[index].text) ?? 0;
    final w = WeightUnitFormatter.toPounds(displayedWeight, _weightUnit);
    final r = int.tryParse(_repsControllers[index].text) ?? 0;
    widget.exercise.sets[index] = ExerciseSet(weight: w, reps: r);
    widget.onValueChanged?.call();
  }

  int _completedSetCount(List<ExerciseSet> sets) {
    return _completedSets
        .where((index) => index >= 0 && index < sets.length)
        .length;
  }

  bool _allSetsComplete(List<ExerciseSet> sets) {
    return sets.isNotEmpty && _completedSetCount(sets) >= sets.length;
  }

  void _removeCompletedSetIndex(int index) {
    final shifted = <int>{};
    for (final completedIndex in _completedSets) {
      if (completedIndex == index) continue;
      shifted.add(completedIndex > index ? completedIndex - 1 : completedIndex);
    }
    _completedSets
      ..clear()
      ..addAll(shifted);
    widget.exercise.completedParents
      ..clear()
      ..addAll(shifted);
  }

  void _removeChangeSetsForParentIndex(int index) {
    final shifted = <int, List<ExerciseSet>>{};
    _cSets.forEach((parentIndex, children) {
      if (parentIndex == index) return;
      shifted[parentIndex > index ? parentIndex - 1 : parentIndex] = children;
    });
    _cSets
      ..clear()
      ..addAll(shifted);
    widget.exercise.changeSets
      ..clear()
      ..addAll({
        for (final entry in shifted.entries) entry.key: List.from(entry.value),
      });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.card.outlined;
    final we = widget.exercise;
    final sets = we.sets;
    final readOnly = widget.readOnlyMode;
    final completedCount = _completedSetCount(sets);
    final allSetsComplete = _allSetsComplete(sets);
    final effectiveCollapsed = widget.forceCollapsed || _isCollapsed;
    final workoutFieldBorder = OutlineInputBorder(
      borderRadius: shapes.control,
      borderSide: BorderSide(
        color: semantic.onWorkoutContainer,
        width: shapes.outlineWidth,
      ),
    );
    final focusedWorkoutFieldBorder = OutlineInputBorder(
      borderRadius: shapes.control,
      borderSide: BorderSide(
        color: semantic.onWorkoutContainer,
        width: shapes.focusRingWidth,
      ),
    );
    final workoutFieldLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: semantic.onWorkoutContainer,
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w600,
    );
    final workoutSetLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      color:
          surfaces.useSemanticWorkoutCardFill
              ? semantic.onWorkoutContainer
              : null,
    );
    final doneColor =
        surfaces.useSemanticWorkoutCardFill
            ? semantic.onWorkoutContainer
            : allSetsComplete
            ? semantic.workoutCompleted
            : theme.textTheme.bodySmall?.color;
    final completedCardColor = semantic.workoutExerciseCompleted;
    final completedSetColor = semantic.workoutSetCompleted;
    final completedCheckboxColor =
        surfaces.useSemanticWorkoutCardFill
            ? completedSetColor
            : semantic.workoutCompleted;

    final cardTheme =
        surfaces.useSemanticWorkoutCardFill
            ? theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                onSurface: semantic.onWorkoutContainer,
                onSurfaceVariant: semantic.onWorkoutContainer,
              ),
              textTheme: theme.textTheme.apply(
                bodyColor: semantic.onWorkoutContainer,
                displayColor: semantic.onWorkoutContainer,
              ),
              textSelectionTheme: theme.textSelectionTheme.copyWith(
                cursorColor: semantic.onWorkoutContainer,
                selectionHandleColor: semantic.onWorkoutContainer,
                selectionColor: semantic.onWorkoutContainer.withValues(
                  alpha: surfaces.workoutTextSelectionOpacity,
                ),
              ),
              inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                filled: true,
                fillColor: Colors.transparent,
                labelStyle: workoutFieldLabelStyle,
                floatingLabelStyle: workoutFieldLabelStyle,
                hintStyle: TextStyle(
                  color: semantic.onWorkoutContainer.withValues(
                    alpha: surfaces.workoutInputHintOpacity,
                  ),
                ),
                suffixStyle: TextStyle(color: semantic.onWorkoutContainer),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 7,
                ),
                enabledBorder: workoutFieldBorder,
                focusedBorder: focusedWorkoutFieldBorder,
                border: workoutFieldBorder,
              ),
            )
            : theme;
    final cardShape =
        usesInkRecipe && theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape! as RoundedRectangleBorder).copyWith(
              borderRadius: shapes.compact,
            )
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: cardShape,
      color:
          allSetsComplete
              ? completedCardColor.withValues(
                alpha: surfaces.workoutCardCompleteFill,
              )
              : surfaces.useSemanticWorkoutCardFill
              ? semantic.workoutContainer
              : null,
      child: Theme(
        data: cardTheme,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      effectiveCollapsed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                    ),
                    tooltip:
                        effectiveCollapsed
                            ? strings.weightExpandSets
                            : strings.weightCollapseSets,
                    onPressed:
                        widget.forceCollapsed
                            ? null
                            : () =>
                                setState(() => _isCollapsed = !_isCollapsed),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          we.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                surfaces.useSemanticWorkoutCardFill
                                    ? semantic.onWorkoutContainer
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (allSetsComplete) ...[
                              Icon(
                                Icons.check_circle,
                                color: doneColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context).weightCardSetsDone(
                                  completedCount,
                                  sets.length,
                                ),
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: doneColor,
                                  fontWeight:
                                      allSetsComplete ? FontWeight.w700 : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.onDetails != null)
                    Semantics(
                      button: true,
                      label: strings.weightDetails,
                      child: _WeightExerciseThumbnailButton(
                        definitionId: widget.definitionId,
                        exercise: we,
                        onTap: widget.onDetails!,
                      ),
                    ),
                  PopupMenuButton<String>(
                    enabled: !readOnly,
                    icon: Icon(
                      Icons.more_vert,
                      color:
                          usesInkRecipe && theme.brightness == Brightness.dark
                              ? semantic.onWorkoutContainer
                              : null,
                    ),
                    onSelected: (choice) async {
                      if (choice == 'remove') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => TonosDialogFrame(
                                child: AlertDialog(
                                  title: Text(
                                    strings.weightRemoveExerciseTitle,
                                  ),
                                  content: Text(
                                    strings.weightRemoveExerciseBody,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: Text(strings.commonCancel),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(strings.commonRemove),
                                    ),
                                  ],
                                ),
                              ),
                        );
                        if (!mounted) return;
                        if (confirm == true) widget.onDeleteExercise?.call();
                      } else if (choice == 'changeSet') {
                        setState(() => _isChangeSetMode = !_isChangeSetMode);
                      } else if (choice == 'swap') {
                        widget.onSwapExercise?.call();
                      }
                    },
                    itemBuilder: (menuContext) {
                      final menuSurface =
                          Theme.of(menuContext).popupMenuTheme.color ??
                          Theme.of(menuContext).colorScheme.surfaceContainer;
                      final menuTextStyle =
                          usesInkRecipe && theme.brightness == Brightness.dark
                              ? (theme.textTheme.bodyLarge ?? const TextStyle())
                                  .copyWith(
                                    color: tonosForegroundForSurface(
                                      menuContext,
                                      menuSurface,
                                    ),
                                  )
                              : null;
                      return [
                        if (widget.onSwapExercise != null)
                          PopupMenuItem(
                            value: 'swap',
                            child: Text(
                              strings.weightSwapExercise,
                              style: menuTextStyle,
                            ),
                          ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(
                            strings.weightRemoveExerciseTitle,
                            style: menuTextStyle,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'changeSet',
                          child: Text(
                            strings.weightMakeChangeSet,
                            style: menuTextStyle,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              if (!effectiveCollapsed) ...[
                const Divider(height: 16),
                // Sets + ChangeSets
                ...List.generate(sets.length, (index) {
                  final children = <Widget>[];
                  final isSetComplete = _completedSets.contains(index);
                  if (usesInkRecipe && index > 0) {
                    children.add(
                      Divider(
                        color: surfaces.divider,
                        height: 1,
                        thickness: 1,
                        indent: 12,
                        endIndent: 12,
                      ),
                    );
                  }
                  // Parent set row
                  children.add(
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isSetComplete
                                ? completedSetColor.withValues(
                                  alpha: surfaces.workoutSetCompleteFill,
                                )
                                : null,
                        border:
                            isSetComplete && usesInkRecipe
                                ? Border(
                                  top: BorderSide(
                                    color: semantic.onWorkoutContainer,
                                    width:
                                        shapes.workoutCompletedSetBorderWidth,
                                  ),
                                  right: BorderSide(
                                    color: semantic.onWorkoutContainer,
                                    width:
                                        shapes.workoutCompletedSetBorderWidth,
                                  ),
                                  bottom: BorderSide(
                                    color: semantic.onWorkoutContainer,
                                    width:
                                        shapes.workoutCompletedSetBorderWidth,
                                  ),
                                  left: BorderSide(
                                    color: semantic.onWorkoutContainer,
                                    width:
                                        shapes
                                            .workoutCompletedSetAccentBorderWidth,
                                  ),
                                )
                                : _isChangeSetMode
                                ? Border.all(
                                  color: surfaces.workoutChangeSetOutline,
                                )
                                : isSetComplete &&
                                    surfaces.workoutSetCompleteOutline.a > 0
                                ? Border.all(
                                  color: surfaces.workoutSetCompleteOutline,
                                )
                                : null,
                        boxShadow:
                            isSetComplete && usesInkRecipe
                                ? [
                                  BoxShadow(
                                    color: effects.cardShadow,
                                    blurRadius: effects.cardShadowBlur,
                                    offset: effects.completedSetShadowOffset,
                                  ),
                                ]
                                : null,
                        borderRadius:
                            usesInkRecipe
                                ? shapes.workoutCompletedSet
                                : shapes.control,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 330;
                          final usesLocalizedLayout =
                              Localizations.localeOf(context).languageCode !=
                              'en';
                          final checkboxWidth = compact ? 34.0 : 40.0;
                          final setLabelWidth =
                              usesLocalizedLayout
                                  ? (compact ? 62.0 : 76.0)
                                  : (compact ? 48.0 : 58.0);
                          final removeWidth = compact ? 34.0 : 40.0;
                          final fieldGap = compact ? 10.0 : 14.0;
                          final stackFields =
                              MediaQuery.textScalerOf(context).scale(1) > 1.15;

                          Widget buildWeightField() {
                            return TextFormField(
                              key: index == 0 ? widget.firstSetWeightKey : null,
                              focusNode:
                                  index == 0
                                      ? widget.firstSetWeightFocusNode
                                      : null,
                              textInputAction:
                                  index == 0 &&
                                          widget.onFirstSetWeightSubmitted !=
                                              null
                                      ? TextInputAction.next
                                      : null,
                              controller: _weightControllers[index],
                              readOnly: readOnly,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: strings.weightLabel(
                                  _weightUnit.shortLabel,
                                ),
                                isDense: true,
                              ),
                              onChanged:
                                  readOnly
                                      ? null
                                      : (_) => _updateWeightSet(index),
                              onFieldSubmitted:
                                  index == 0
                                      ? (_) =>
                                          widget.onFirstSetWeightSubmitted
                                              ?.call()
                                      : null,
                            );
                          }

                          Widget buildRepsField() {
                            return TextFormField(
                              key: index == 0 ? widget.firstSetRepsKey : null,
                              focusNode:
                                  index == 0
                                      ? widget.firstSetRepsFocusNode
                                      : null,
                              textInputAction:
                                  index == 0 &&
                                          widget.onFirstSetRepsSubmitted != null
                                      ? TextInputAction.done
                                      : null,
                              controller: _repsControllers[index],
                              readOnly: readOnly,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: strings.weightReps,
                                isDense: true,
                              ),
                              onChanged:
                                  readOnly
                                      ? null
                                      : (_) => _updateWeightSet(index),
                              onFieldSubmitted:
                                  index == 0
                                      ? (_) =>
                                          widget.onFirstSetRepsSubmitted?.call()
                                      : null,
                            );
                          }

                          final fields =
                              stackFields
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      buildWeightField(),
                                      SizedBox(height: fieldGap),
                                      buildRepsField(),
                                    ],
                                  )
                                  : Row(
                                    children: [
                                      Expanded(child: buildWeightField()),
                                      SizedBox(width: fieldGap),
                                      Expanded(child: buildRepsField()),
                                    ],
                                  );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: checkboxWidth,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Checkbox(
                                    value: _completedSets.contains(index),
                                    semanticLabel: strings.weightSetLabel(
                                      index + 1,
                                    ),
                                    activeColor: completedCheckboxColor,
                                    visualDensity: VisualDensity.compact,
                                    onChanged:
                                        readOnly
                                            ? null
                                            : (ok) {
                                              if (ok == null) return;
                                              setState(() {
                                                if (ok) {
                                                  _completedSets.add(index);
                                                  widget
                                                      .exercise
                                                      .completedParents
                                                      .add(index);
                                                } else {
                                                  _completedSets.remove(index);
                                                  widget
                                                      .exercise
                                                      .completedParents
                                                      .remove(index);
                                                }
                                                if (_allSetsComplete(sets)) {
                                                  _isCollapsed = true;
                                                }
                                              });
                                              widget.onValueChanged?.call();
                                            },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: setLabelWidth,
                                child:
                                    usesLocalizedLayout
                                        ? FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            strings.weightSetLabel(index + 1),
                                            style: workoutSetLabelStyle,
                                            maxLines: 1,
                                          ),
                                        )
                                        : Text(
                                          strings.weightSetLabel(index + 1),
                                          style: workoutSetLabelStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: fields),
                              SizedBox(width: compact ? 6 : 10),
                              SizedBox(
                                width: removeWidth,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  tooltip: strings.weightRemoveSetTitle,
                                  constraints: BoxConstraints.tightFor(
                                    width: removeWidth,
                                    height: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed:
                                      readOnly
                                          ? null
                                          : () async {
                                            final confirm = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (ctx) => TonosDialogFrame(
                                                    child: AlertDialog(
                                                      title: Text(
                                                        strings
                                                            .weightRemoveSetTitle,
                                                      ),
                                                      content: Text(
                                                        strings
                                                            .weightRemoveSetBody,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                          child: Text(
                                                            strings
                                                                .commonCancel,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    true,
                                                                  ),
                                                          child: Text(
                                                            strings
                                                                .commonRemove,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            );
                                            if (!mounted) return;
                                            if (confirm == true) {
                                              setState(() {
                                                sets.removeAt(index);
                                                _weightControllers
                                                    .removeAt(index)
                                                    .dispose();
                                                _repsControllers
                                                    .removeAt(index)
                                                    .dispose();
                                                _removeCompletedSetIndex(index);
                                                _removeChangeSetsForParentIndex(
                                                  index,
                                                );
                                                _isChangeSetMode =
                                                    _cSets.isNotEmpty &&
                                                    _isChangeSetMode;
                                              });
                                              widget.onSetDeleted?.call();
                                              widget.onValueChanged?.call();
                                            }
                                          },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );

                  // Boxed ChangeSets UI
                  if (_isChangeSetMode ||
                      widget.exercise.changeSets.isNotEmpty) {
                    final cList = _cSets[index] ?? [];
                    for (var ci = 0; ci < cList.length; ci++) {
                      final cset = cList[ci];
                      children.add(
                        Transform.scale(
                          scale: 0.8,
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 32, bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: surfaces.workoutChangeSetOutline,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  strings.weightChangeSetLabel(ci + 1),
                                  style: workoutSetLabelStyle,
                                ),
                                const SizedBox(width: 8),
                                // Weight
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    readOnly: readOnly,
                                    keyboardType: TextInputType.number,
                                    initialValue:
                                        WeightUnitFormatter.formatInputWeight(
                                          cset.weight,
                                          _weightUnit,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: strings.weightShortLabel(
                                        _weightUnit.shortLabel,
                                      ),
                                    ),
                                    onChanged:
                                        readOnly
                                            ? null
                                            : (v) {
                                              final displayValue =
                                                  double.tryParse(v);
                                              if (displayValue != null) {
                                                cset.weight =
                                                    WeightUnitFormatter.toPounds(
                                                      displayValue,
                                                      _weightUnit,
                                                    );
                                              }
                                              widget
                                                      .exercise
                                                      .changeSets[index] =
                                                  List.from(_cSets[index]!);
                                              widget.onValueChanged?.call();
                                            },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Reps
                                SizedBox(
                                  width: 40,
                                  child: TextFormField(
                                    readOnly: readOnly,
                                    keyboardType: TextInputType.number,
                                    initialValue: cset.reps.toString(),
                                    decoration: InputDecoration(
                                      labelText: strings.weightReps,
                                    ),
                                    onChanged:
                                        readOnly
                                            ? null
                                            : (v) {
                                              cset.reps =
                                                  int.tryParse(v) ?? cset.reps;
                                              widget
                                                      .exercise
                                                      .changeSets[index] =
                                                  List.from(_cSets[index]!);
                                              widget.onValueChanged?.call();
                                            },
                                  ),
                                ),
                                if (!readOnly) ...[
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    tooltip: strings.weightRemoveChangeSetTitle,
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => TonosDialogFrame(
                                              child: AlertDialog(
                                                title: Text(
                                                  strings
                                                      .weightRemoveChangeSetTitle,
                                                ),
                                                content: Text(
                                                  strings
                                                      .weightRemoveChangeSetBody,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: Text(
                                                      strings.commonCancel,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: Text(
                                                      strings.commonRemove,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      );
                                      if (!mounted) return;
                                      if (confirm == true) {
                                        setState(() {
                                          _cSets[index]!.removeAt(ci);
                                          if (_cSets[index]!.isEmpty) {
                                            _cSets.remove(index);
                                            widget.exercise.changeSets.remove(
                                              index,
                                            );
                                          } else {
                                            widget.exercise.changeSets[index] =
                                                List.from(_cSets[index]!);
                                          }
                                        });
                                        widget.onValueChanged?.call();
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  // "Add CSet" button
                  if (!readOnly && _isChangeSetMode) {
                    children.add(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: WorkoutAddChangeSetAction(
                            label: strings.weightAddChangeSet,
                            onTap: () {
                              setState(() {
                                _cSets.putIfAbsent(index, () => []);
                                _cSets[index]!.add(
                                  ExerciseSet(
                                    weight: sets[index].weight,
                                    reps: sets[index].reps,
                                  ),
                                );
                                widget.exercise.changeSets[index] = List.from(
                                  _cSets[index]!,
                                );
                              });
                              widget.onValueChanged?.call();
                            },
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(children: children);
                }),

                // Add Set
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: widget.addSetKey,
                    style:
                        surfaces.useSemanticWorkoutCardFill
                            ? TextButton.styleFrom(
                              foregroundColor: semantic.onWorkoutContainer,
                            )
                            : null,
                    onPressed:
                        readOnly
                            ? null
                            : () {
                              setState(() {
                                final last =
                                    sets.isNotEmpty ? sets.last : ExerciseSet();
                                sets.add(
                                  ExerciseSet(
                                    weight: last.weight,
                                    reps: last.reps,
                                  ),
                                );
                                _weightControllers.add(
                                  TextEditingController(
                                    text: WeightUnitFormatter.formatInputWeight(
                                      last.weight,
                                      _weightUnit,
                                    ),
                                  ),
                                );
                                _repsControllers.add(
                                  TextEditingController(
                                    text: last.reps.toString(),
                                  ),
                                );
                                _isCollapsed = false;
                              });
                              widget.onSetAdded?.call();
                            },
                    icon: const Icon(Icons.add),
                    label: Text(strings.weightAddSet),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightExerciseThumbnailButton extends StatefulWidget {
  final int? definitionId;
  final WeightExercise exercise;
  final VoidCallback onTap;

  const _WeightExerciseThumbnailButton({
    required this.definitionId,
    required this.exercise,
    required this.onTap,
  });

  @override
  State<_WeightExerciseThumbnailButton> createState() =>
      _WeightExerciseThumbnailButtonState();
}

class _WeightExerciseThumbnailButtonState
    extends State<_WeightExerciseThumbnailButton> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<ExerciseDefinition?> _definitionFuture;

  @override
  void initState() {
    super.initState();
    _definitionFuture = _loadDefinition();
  }

  @override
  void didUpdateWidget(covariant _WeightExerciseThumbnailButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definitionId != widget.definitionId ||
        oldWidget.exercise.name != widget.exercise.name ||
        oldWidget.exercise.equipment != widget.exercise.equipment) {
      _definitionFuture = _loadDefinition();
    }
  }

  Future<ExerciseDefinition?> _loadDefinition() async {
    try {
      final definitionId =
          widget.definitionId ??
          await _repo.findOrCreateExerciseDefinition(
            widget.exercise.name,
            widget.exercise.equipment,
          );
      return _repo.fetchDefinitionById(definitionId);
    } catch (_) {
      // A custom or legacy exercise may not have a resolvable definition yet.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExerciseDefinition?>(
      future: _definitionFuture,
      builder: (context, snapshot) {
        final definition = snapshot.data;
        if (definition != null) {
          return ExerciseMediaThumbnail(
            definition: definition,
            size: 48,
            borderRadius: context.shapeTokens.mediaThumbnail,
            padding: EdgeInsets.zero,
            framed: false,
            onTap: widget.onTap,
          );
        }

        return SizedBox.square(
          dimension: 48,
          child: InkWell(
            borderRadius: context.shapeTokens.mediaThumbnail,
            onTap: widget.onTap,
            child: Center(
              child:
                  snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.fitness_center, size: 22),
            ),
          ),
        );
      },
    );
  }
}
