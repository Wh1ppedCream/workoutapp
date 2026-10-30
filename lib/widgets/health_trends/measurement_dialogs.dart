part of '../health_trends_section.dart';

Future<_MeasurementEntryInput?> _showMeasurementEntryDialog({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  ModalRoute<dynamic>? dialogRoute;
  final input = await showTonosDialog<_MeasurementEntryInput>(
    context: context,
    builder: (dialogContext) {
      dialogRoute = ModalRoute.of(dialogContext);
      return TonosDialogFrame(
        styleFormControls: true,
        styleDarkNeoPickerSurfaces: true,
        child: builder(dialogContext),
      );
    },
  );
  if (input != null && context.mounted && context.usesExpressivePresentation) {
    // Let the overlay leave before updating the chart underneath it, so the
    // user sees the complete data transition rather than its last few frames.
    await dialogRoute?.completed;
  }
  return input;
}

class _MeasurementEntryDialog extends StatefulWidget {
  final String title;
  final MeasurementDefinition definition;
  final String defaultUnit;
  final Measurement? entry;
  final bool measurementLibrary;

  const _MeasurementEntryDialog({
    required this.title,
    required this.definition,
    required this.defaultUnit,
    this.entry,
    this.measurementLibrary = false,
  });

  @override
  State<_MeasurementEntryDialog> createState() =>
      _MeasurementEntryDialogState();
}

enum _HeightEntryMode {
  feetAndInches(HeightUnit.inches),
  feet(HeightUnit.feet),
  inches(HeightUnit.inches),
  centimeters(HeightUnit.centimeters);

  const _HeightEntryMode(this.unit);
  final HeightUnit unit;
}

class _MeasurementEntryDialogState extends State<_MeasurementEntryDialog> {
  late DateTime _timestamp;
  late final TextEditingController _valueController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  late _HeightEntryMode _heightMode;
  double? _heightCentimeters;
  bool get _heightUsesFeetAndInches =>
      _isHeight && _heightMode == _HeightEntryMode.feetAndInches;
  String? _bodyWeightVariation;
  bool _withPump = false;
  bool _pumpSelectionEdited = false;

  bool get _isHeight => widget.definition.type == MeasurementType.Height;
  bool get _isBodyWeight =>
      widget.definition.type == MeasurementType.BodyWeight;
  bool get _isBodyPart =>
      !_isHeight &&
      !_isBodyWeight &&
      widget.definition.type != MeasurementType.Custom;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final unit = entry?.unit ?? widget.defaultUnit;
    final note = entry?.note ?? '';
    final measurementContext =
        entry?.context ??
        MeasurementValidation.legacyContextFor(
          type: widget.definition.type,
          note: entry?.note,
        );
    _timestamp = entry?.timestamp ?? DateTime.now();
    final heightUnit = HeightUnit.tryParse(unit);
    _heightMode = switch (heightUnit) {
      HeightUnit.feet => _HeightEntryMode.feet,
      HeightUnit.inches => _HeightEntryMode.feetAndInches,
      _ => _HeightEntryMode.centimeters,
    };
    _valueController = TextEditingController(
      text: entry == null ? '' : _cleanNumber(entry.value),
    );
    _heightInchesController = TextEditingController();
    if (_isHeight) {
      _heightCentimeters = entry == null || heightUnit == null
          ? null
          : heightUnit.convert(entry.value, HeightUnit.centimeters);
      _populateHeightInputs(_heightCentimeters);
    }
    _unitController = TextEditingController(text: unit);
    _bodyWeightVariation = switch (measurementContext) {
      MeasurementContext.wakeUp => 'WakeUp',
      MeasurementContext.bedtime => 'BedTime',
      MeasurementContext.overall => 'Overall',
      _ => _isBodyWeight && _isKnownBodyWeightVariation(note) ? note : null,
    };
    _withPump =
        measurementContext == MeasurementContext.withPump ||
        (_isBodyPart && note == 'With pump');
    _noteController = TextEditingController(
      text: entry?.context == null && _usesPresetNote(note) ? '' : note,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _heightInchesController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final profileTokens = widget.measurementLibrary
        ? _profileMeasurementTokens(context)
        : null;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _timestamp,
      builder: profileTokens == null
          ? null
          : (pickerContext, child) {
              final theme = _profileMeasurementDialogTheme(
                pickerContext,
                profileTokens,
              );
              final pickerShape = RoundedRectangleBorder(
                borderRadius: pickerContext.shapeTokens.dialogChoice,
                side: BorderSide(
                  color: profileTokens.outlineAccent.withValues(alpha: 0.48),
                ),
              );
              return Theme(
                data: theme.copyWith(
                  datePickerTheme: theme.datePickerTheme.copyWith(
                    backgroundColor: _profileMeasurementDialogSurface(
                      pickerContext,
                      profileTokens,
                    ),
                    surfaceTintColor: Colors.transparent,
                    shape: pickerShape,
                    headerBackgroundColor: profileTokens.surfacePrimary,
                    headerForegroundColor: profileTokens.onSurfacePrimary,
                    dayForegroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      return states.contains(WidgetState.selected)
                          ? profileTokens.onActionPrimary
                          : profileTokens.supportingForeground;
                    }),
                    dayBackgroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      return states.contains(WidgetState.selected)
                          ? profileTokens.actionPrimary
                          : null;
                    }),
                    confirmButtonStyle: TextButton.styleFrom(
                      foregroundColor: profileTokens.actionPrimary,
                    ),
                    cancelButtonStyle: TextButton.styleFrom(
                      foregroundColor: profileTokens.actionPrimary,
                    ),
                  ),
                ),
                child: child!,
              );
            },
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  void _save() {
    final height = _isHeight ? _heightValueInCentimeters() : null;
    final value = _isHeight
        ? height == null
              ? null
              : HeightUnit.centimeters.convert(height, _heightMode.unit)
        : double.tryParse(_valueController.text.trim());
    final unit = _isHeight
        ? _heightMode.unit.symbol
        : _unitController.text.trim();
    if (value == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthEntryValueUnitRequired,
          ),
        ),
      );
      return;
    }
    try {
      MeasurementValidation.validateEntry(
        type: widget.definition.type,
        value: value,
        unit: unit,
        context: _resolvedContext(),
      );
    } on MeasurementValidationException catch (error) {
      final strings = AppLocalizations.of(context);
      final range =
          _isBodyWeight &&
              error.error == MeasurementValidationError.implausibleValue
          ? MeasurementValidation.bodyWeightRange(unit)
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            range == null
                ? _measurementValidationMessage(strings, error)
                : strings.healthBodyWeightRange(
                    _cleanNumber(range.min),
                    _cleanNumber(range.max),
                    unit,
                  ),
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _MeasurementEntryInput(
        timestamp: _timestamp,
        value: value,
        unit: unit,
        note: _resolvedNote(),
        context: _resolvedContext(),
      ),
    );
  }

  double? _heightValueInCentimeters() {
    if (_heightCentimeters != null) return _heightCentimeters;
    if (!_heightUsesFeetAndInches) {
      final value = double.tryParse(_valueController.text.trim());
      return value == null
          ? null
          : _heightMode.unit.convert(value, HeightUnit.centimeters);
    }
    final feetText = _valueController.text.trim();
    final inchesText = _heightInchesController.text.trim();
    if (feetText.isEmpty && inchesText.isEmpty) return null;
    final feet = feetText.isEmpty ? 0.0 : double.tryParse(feetText);
    final inches = inchesText.isEmpty ? 0.0 : double.tryParse(inchesText);
    if (feet == null ||
        inches == null ||
        feet < 0 ||
        inches < 0 ||
        inches >= 12) {
      return null;
    }
    return HeightUnit.inches.convert(
      feet * 12 + inches,
      HeightUnit.centimeters,
    );
  }

  void _heightInputChanged(String _) => _heightCentimeters = null;

  String _heightInputNumber(double value) =>
      value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');

  void _populateHeightInputs(double? centimeters) {
    if (centimeters == null) {
      _valueController.clear();
      _heightInchesController.clear();
    } else if (_heightUsesFeetAndInches) {
      final inches = HeightUnit.centimeters.convert(
        centimeters,
        HeightUnit.inches,
      );
      final feet = (inches / 12).floor();
      _valueController.text = feet.toString();
      _heightInchesController.text = _heightInputNumber(inches - feet * 12);
    } else {
      _valueController.text = _heightInputNumber(
        HeightUnit.centimeters.convert(centimeters, _heightMode.unit),
      );
      _heightInchesController.clear();
    }
  }

  String? _resolvedNote() {
    final typedNote = _noteController.text.trim();
    if (typedNote.isNotEmpty) return typedNote;
    return null;
  }

  MeasurementContext? _resolvedContext() {
    if (_isBodyWeight) {
      return switch (_bodyWeightVariation) {
        'WakeUp' => MeasurementContext.wakeUp,
        'BedTime' => MeasurementContext.bedtime,
        'Overall' => MeasurementContext.overall,
        _ => null,
      };
    }
    if (_isBodyPart) {
      final entry = widget.entry;
      if (!_pumpSelectionEdited && entry != null) {
        return entry.context ??
            MeasurementValidation.legacyContextFor(
              type: widget.definition.type,
              note: entry.note,
            );
      }
      return _withPump
          ? MeasurementContext.withPump
          : MeasurementContext.withoutPump;
    }
    return null;
  }

  bool _usesPresetNote(String note) {
    return MeasurementValidation.legacyContextFor(
          type: widget.definition.type,
          note: note,
        ) !=
        null;
  }

  bool _isKnownBodyWeightVariation(String note) {
    return note == 'WakeUp' || note == 'BedTime' || note == 'Overall';
  }

  void _setHeightUnit(_HeightEntryMode mode) {
    if (_heightMode == mode) return;
    final centimeters = _heightValueInCentimeters();
    setState(() {
      _heightMode = mode;
      _heightCentimeters = centimeters;
      _unitController.text = mode.unit.symbol;
      _populateHeightInputs(centimeters);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final destination = _progressDetailTokens(context);
    final profileTokens = widget.measurementLibrary
        ? _profileMeasurementTokens(context)
        : null;
    final expressiveLibrary = profileTokens != null;
    final expressiveProgressEntry = destination != null;
    final expressiveBodyWeight = _isBodyWeight && expressiveProgressEntry;
    final expressiveWeightDialog = expressiveBodyWeight;
    final expressiveForm = expressiveLibrary || expressiveProgressEntry;
    final compactLibraryLayout =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final surface = _measurementDetailSurface(
      context,
      role: _MeasurementDetailRole.dialog,
    );
    final dialogSurface = expressiveLibrary
        ? _profileMeasurementDialogSurface(context, profileTokens)
        : surface;
    final dialogForeground = expressiveLibrary
        ? profileTokens.supportingForeground
        : _measurementDetailForeground(
            context,
            role: _MeasurementDetailRole.dialog,
          );
    final dialogTokens = profileTokens ?? destination;
    final dialogFieldFill = expressiveForm
        ? Color.alphaBlend(
            dialogTokens!.surfaceSelected.withValues(
              alpha: expressiveLibrary && theme.brightness == Brightness.dark
                  ? 0.48
                  : 0.30,
            ),
            dialogSurface,
          )
        : null;
    final variationMenuHighlight = expressiveLibrary
        ? Color.alphaBlend(
            profileTokens.surfaceSelected.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.72 : 0.48,
            ),
            dialogSurface,
          )
        : null;
    final fieldPadding = expressiveForm
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : null;
    final fieldGap = expressiveForm ? 8.0 : 10.0;
    final dateGap = expressiveForm ? 10.0 : 12.0;
    Widget withWeightFieldLabel(String label, String key, Widget field) {
      if (!expressiveWeightDialog) return field;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            key: ValueKey('measurement-entry-label-$key'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: dialogForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(label: label, child: field),
        ],
      );
    }

    final feetField = TextField(
      key: const ValueKey('measurement-entry-height-feet'),
      controller: _valueController,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _heightInputChanged,
      decoration: InputDecoration(labelText: strings.measurementFeet),
    );
    final inchesField = TextField(
      key: const ValueKey('measurement-entry-height-inches'),
      controller: _heightInchesController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _heightInputChanged,
      decoration: InputDecoration(labelText: strings.measurementInches),
    );
    final dialog = AlertDialog(
      key: const ValueKey('measurement-trend-entry-dialog'),
      scrollable: expressiveForm,
      insetPadding: expressiveForm
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
          : null,
      actionsPadding: expressiveForm
          ? const EdgeInsets.fromLTRB(20, 4, 20, 12)
          : null,
      title: Text(widget.title),
      backgroundColor: expressiveForm ? dialogSurface : null,
      surfaceTintColor: expressiveForm ? Colors.transparent : null,
      titleTextStyle: expressiveForm
          ? theme.textTheme.titleLarge?.copyWith(
              color: dialogForeground,
              fontWeight: FontWeight.w800,
            )
          : null,
      contentTextStyle: expressiveForm
          ? theme.textTheme.bodyMedium?.copyWith(
              color: expressiveLibrary
                  ? profileTokens.supportingForeground
                  : _measurementDetailSupportingForeground(
                      context,
                      role: _MeasurementDetailRole.dialog,
                    ),
            )
          : null,
      shape: expressiveForm
          ? RoundedRectangleBorder(
              borderRadius: context.shapeTokens.healthTrendCard,
              side: BorderSide(
                color: dialogTokens!.outlineAccent.withValues(alpha: 0.48),
              ),
            )
          : null,
      contentPadding: expressiveForm
          ? const EdgeInsets.fromLTRB(24, 12, 24, 6)
          : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isHeight) ...[
              Wrap(
                key: const ValueKey('measurement-height-unit-selector'),
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final mode in _HeightEntryMode.values)
                    ChoiceChip(
                      key: ValueKey('measurement-height-unit-${mode.name}'),
                      label: Text(switch (mode) {
                        _HeightEntryMode.feetAndInches =>
                          '${strings.measurementFeet}/${strings.measurementInches}',
                        _HeightEntryMode.feet => strings.measurementFeet,
                        _HeightEntryMode.inches => strings.measurementInches,
                        _HeightEntryMode.centimeters =>
                          strings.measurementCentimeters,
                      }),
                      selected: _heightMode == mode,
                      onSelected: (_) => _setHeightUnit(mode),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (_heightUsesFeetAndInches)
              expressiveLibrary && compactLibraryLayout
                  ? Column(
                      children: [
                        feetField,
                        const SizedBox(height: 8),
                        inchesField,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: feetField),
                        const SizedBox(width: 10),
                        Expanded(child: inchesField),
                      ],
                    )
            else
              withWeightFieldLabel(
                strings.measurementWeight,
                'weight',
                TextField(
                  key: AppTestKeys.measurementEntryValue,
                  controller: _valueController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: _isHeight ? _heightInputChanged : null,
                  style: expressiveBodyWeight
                      ? theme.textTheme.headlineSmall?.copyWith(
                          color: dialogForeground,
                          fontWeight: FontWeight.w700,
                        )
                      : null,
                  decoration: InputDecoration(
                    contentPadding: fieldPadding,
                    prefixIcon: expressiveBodyWeight
                        ? const Icon(Icons.monitor_weight_outlined)
                        : null,
                    filled: expressiveForm,
                    fillColor: dialogFieldFill,
                    prefixIconColor: expressiveBodyWeight
                        ? destination.actionPrimary
                        : null,
                    labelText: expressiveWeightDialog
                        ? null
                        : _isHeight
                        ? switch (_heightMode) {
                            _HeightEntryMode.feet => strings.measurementFeet,
                            _HeightEntryMode.inches =>
                              strings.measurementInches,
                            _ => strings.measurementCentimeters,
                          }
                        : _measurementTitle(widget.definition, strings),
                    labelStyle: expressiveBodyWeight
                        ? theme.textTheme.bodySmall?.copyWith(
                            color: dialogForeground,
                          )
                        : null,
                    floatingLabelStyle: expressiveBodyWeight
                        ? theme.textTheme.bodySmall?.copyWith(
                            color: destination.actionPrimary,
                          )
                        : null,
                  ),
                ),
              ),
            SizedBox(height: fieldGap),
            if (!_isHeight)
              withWeightFieldLabel(
                strings.healthUnit,
                'unit',
                TextField(
                  key: AppTestKeys.measurementEntryUnit,
                  controller: _unitController,
                  decoration: InputDecoration(
                    contentPadding: fieldPadding,
                    labelText: expressiveWeightDialog
                        ? null
                        : strings.healthUnit,
                  ),
                ),
              ),
            if (!_isHeight) SizedBox(height: fieldGap),
            if (_isBodyWeight) ...[
              withWeightFieldLabel(
                strings.measurementVariation,
                'variation',
                Builder(
                  builder: (context) {
                    final dropdown = DropdownButtonFormField<String>(
                      key: const ValueKey('measurement-entry-variation'),
                      initialValue: _bodyWeightVariation,
                      hint: expressiveWeightDialog
                          ? Text(strings.measurementOptional)
                          : null,
                      isExpanded: expressiveForm,
                      dropdownColor: expressiveLibrary ? dialogSurface : null,
                      borderRadius: expressiveLibrary
                          ? context.shapeTokens.dialogChoice
                          : null,
                      itemHeight: expressiveLibrary ? 52 : null,
                      menuMaxHeight: expressiveLibrary ? 240 : null,
                      decoration: InputDecoration(
                        contentPadding: fieldPadding,
                        labelText: expressiveWeightDialog
                            ? null
                            : strings.measurementVariation,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'WakeUp',
                          child: Text(strings.measurementWakeUp),
                        ),
                        DropdownMenuItem(
                          value: 'BedTime',
                          child: Text(strings.measurementBedtime),
                        ),
                        DropdownMenuItem(
                          value: 'Overall',
                          child: Text(strings.measurementOverall),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _bodyWeightVariation = value);
                      },
                    );
                    if (!expressiveLibrary) return dropdown;

                    return Theme(
                      data: _profileMeasurementDialogTheme(
                        context,
                        profileTokens,
                      ).copyWith(focusColor: variationMenuHighlight),
                      child: dropdown,
                    );
                  },
                ),
              ),
              SizedBox(height: fieldGap),
            ],
            if (_isBodyPart)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _withPump,
                onChanged: (value) => setState(() {
                  _withPump = value ?? false;
                  _pumpSelectionEdited = true;
                }),
                title: Text(strings.measurementWithPump),
              ),
            withWeightFieldLabel(
              strings.healthNote,
              'note',
              TextField(
                key: const ValueKey('measurement-entry-note'),
                controller: _noteController,
                minLines: expressiveLibrary ? 1 : null,
                maxLines: expressiveLibrary ? 3 : 1,
                decoration: InputDecoration(
                  contentPadding: fieldPadding,
                  labelText: expressiveWeightDialog ? null : strings.healthNote,
                  hintText: strings.healthOptional,
                ),
              ),
            ),
            SizedBox(height: dateGap),
            SizedBox(
              width: expressiveProgressEntry || expressiveLibrary
                  ? double.infinity
                  : null,
              child: expressiveProgressEntry
                  ? OutlinedButton(
                      key: const ValueKey('measurement-entry-date'),
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: dialogFieldFill,
                        foregroundColor: dialogTokens!.actionPrimary,
                        side: BorderSide(
                          color: dialogTokens.outlineAccent.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDateTime(
                                _timestamp,
                                Localizations.localeOf(context),
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    )
                  : expressiveForm
                  ? OutlinedButton(
                      key: const ValueKey('measurement-entry-date'),
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dialogTokens!.actionPrimary,
                        side: BorderSide(
                          color: dialogTokens.outlineAccent.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        minimumSize: const Size(48, 48),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(
                              _timestamp,
                              Localizations.localeOf(context),
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ],
                      ),
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('measurement-entry-date'),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _formatDateTime(
                          _timestamp,
                          Localizations.localeOf(context),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: expressiveForm
              ? TextButton.styleFrom(minimumSize: const Size(72, 48))
              : null,
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          key: AppTestKeys.measurementEntrySave,
          onPressed: _save,
          style: expressiveForm
              ? FilledButton.styleFrom(minimumSize: const Size(72, 48))
              : null,
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ],
    );
    if (expressiveLibrary) {
      return Theme(
        data: _profileMeasurementDialogTheme(context, profileTokens),
        child: dialog,
      );
    }
    return expressiveProgressEntry
        ? _withMeasurementDetailSurfaceTheme(
            context,
            role: _MeasurementDetailRole.dialog,
            child: dialog,
            expressiveFormFields: expressiveForm,
          )
        : dialog;
  }
}

class _MeasurementDefinitionDialog extends StatefulWidget {
  final bool measurementLibrary;

  const _MeasurementDefinitionDialog({this.measurementLibrary = false});

  @override
  State<_MeasurementDefinitionDialog> createState() =>
      _MeasurementDefinitionDialogState();
}

class _MeasurementDefinitionDialogState
    extends State<_MeasurementDefinitionDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'in');
  final _initialValueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _initialValueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final initialText = _initialValueController.text.trim();
    final initialValue = initialText.isEmpty
        ? null
        : double.tryParse(initialText);

    if (name.isEmpty ||
        unit.isEmpty ||
        (initialText.isNotEmpty && initialValue == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).healthDefinitionFieldsRequired,
          ),
        ),
      );
      return;
    }
    try {
      MeasurementValidation.validateDefinition(name: name, unit: unit);
      if (initialValue != null) {
        MeasurementValidation.validateEntry(
          type: MeasurementType.Custom,
          value: initialValue,
          unit: unit,
        );
      }
    } on MeasurementValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _measurementValidationMessage(AppLocalizations.of(context), error),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _MeasurementDefinitionInput(
        name: name,
        unit: unit,
        initialValue: initialValue,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final profileTokens = widget.measurementLibrary
        ? _profileMeasurementTokens(context)
        : null;
    final dialog = AlertDialog(
      title: Text(AppLocalizations.of(context).healthCreateMetric),
      backgroundColor: profileTokens == null
          ? null
          : _profileMeasurementDialogSurface(context, profileTokens),
      surfaceTintColor: profileTokens == null ? null : Colors.transparent,
      titleTextStyle: profileTokens == null
          ? null
          : Theme.of(context).textTheme.titleLarge?.copyWith(
              color: profileTokens.supportingForeground,
              fontWeight: FontWeight.w800,
            ),
      contentTextStyle: profileTokens == null
          ? null
          : Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: profileTokens.supportingForeground),
      shape: profileTokens == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: context.shapeTokens.healthTrendCard,
              side: BorderSide(
                color: profileTokens.outlineAccent.withValues(alpha: 0.48),
              ),
            ),
      contentPadding: profileTokens == null
          ? null
          : const EdgeInsets.fromLTRB(24, 12, 24, 6),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthMetricName,
                hintText: AppLocalizations.of(context).healthMetricNameHint,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthUnit,
                hintText: AppLocalizations.of(context)
                    .healthUnitHint(weightUnit.shortLabel),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _initialValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthStartingValue,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              minLines: profileTokens == null ? null : 1,
              maxLines: profileTokens == null ? 1 : 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).healthNote,
                hintText: AppLocalizations.of(context).healthOptional,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).healthCreate),
        ),
      ],
    );
    return profileTokens == null
        ? dialog
        : Theme(
            data: _profileMeasurementDialogTheme(context, profileTokens),
            child: dialog,
          );
  }
}
