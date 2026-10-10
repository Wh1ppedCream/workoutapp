// file: lib/screens/profile/settings/user_information_settings_page.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../utils/weight_unit_formatter.dart';
import '../../../utils/app_test_keys.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/tokens/app_shape_tokens.dart';
import '../../../theme/tokens/app_settings_presentation_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import 'profile_expressive_selection.dart';
import '../../../widgets/settings_tiles.dart';

class UserInformationSettingsPage extends StatefulWidget {
  const UserInformationSettingsPage({super.key});

  @override
  State<UserInformationSettingsPage> createState() =>
      _UserInformationSettingsPageState();
}

class _UserInformationSettingsPageState
    extends State<UserInformationSettingsPage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _dobController = TextEditingController();

  String? _gender;
  String? _bodyFatEstimate;
  String? _weightTrend;
  String? _activityLevel;
  DateTime? _dob;
  bool _dirty = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<AppRepository>();
    final unitPreferences = context.read<UnitPreferenceProvider>();
    await unitPreferences.ready;
    final weightUnit = unitPreferences.weightUnit;
    final personalInfo = await repo.fetchPersonalInfo();
    final latestBodyWeightLbs = await repo.fetchLatestBodyWeightLbs();
    if (!mounted) return;

    setState(() {
      _loading = true;
      _nameController.text = personalInfo?.name ?? '';
      _gender = personalInfo?.gender;
      _dob = personalInfo?.dob;
      _dobController.text = _formatDate(personalInfo?.dob);
      _heightController.text = personalInfo?.height ?? '';
      _weightController.text = _formatStoredWeightForDisplay(
        personalInfo?.weight,
        weightUnit,
        latestBodyWeightLbs: latestBodyWeightLbs,
      );
      _bodyFatEstimate = personalInfo?.bodyFatEstimate;
      _weightTrend = personalInfo?.weightTrend;
      _activityLevel = personalInfo?.activityLevel;
      _dirty = false;
      _loading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: context.usesExpressivePresentation
          ? (dialogContext, child) => _withExpressiveProfileTheme(
              dialogContext,
              child ?? const SizedBox.shrink(),
            )
          : null,
    );
    if (picked == null) return;

    setState(() {
      _dob = picked;
      _dobController.text = _formatDate(picked);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    try {
      final repo = context.read<AppRepository>();
      final weightUnit = context.read<UnitPreferenceProvider>().weightUnit;
      final enteredWeight = double.tryParse(_weightController.text.trim());
      final info = PersonalInfo(
        name: _clean(_nameController.text),
        gender: _gender,
        dob: _dob,
        height: _clean(_heightController.text),
        weight: _cleanWeightForStorage(_weightController.text, weightUnit),
        bodyFatEstimate: _bodyFatEstimate,
        weightTrend: _weightTrend,
        activityLevel: _activityLevel,
      );
      await repo.savePersonalInfoWithBodyWeight(
        info: info,
        bodyWeightValue: enteredWeight != null && enteredWeight > 0
            ? enteredWeight
            : null,
        bodyWeightUnit: weightUnit,
        measurementNote: strings.userInfoProfileUpdateNote,
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.userInfoChangesSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.userInfoSaveFailed)));
    }
  }

  String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatStoredWeightForDisplay(
    String? storedWeight,
    WeightUnit unit, {
    double? latestBodyWeightLbs,
  }) {
    if (latestBodyWeightLbs != null && latestBodyWeightLbs > 0) {
      return WeightUnitFormatter.formatInputWeight(latestBodyWeightLbs, unit);
    }
    final cleaned = _clean(storedWeight ?? '');
    if (cleaned == null) return '';
    final pounds = double.tryParse(cleaned);
    if (pounds == null) return cleaned;
    return WeightUnitFormatter.formatInputWeight(pounds, unit);
  }

  String? _cleanWeightForStorage(String value, WeightUnit unit) {
    final cleaned = _clean(value);
    if (cleaned == null) return null;
    final displayWeight = double.tryParse(cleaned);
    if (displayWeight == null) return cleaned;
    final pounds = WeightUnitFormatter.toPounds(displayWeight, unit);
    return WeightUnitFormatter.formatInputWeight(pounds, WeightUnit.pounds);
  }

  void _markDirty() {
    if (_loading) return;
    setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressive = context.usesExpressivePresentation;
    final profileTokens = _profileTokens(context);
    final expressiveInk = usesExpressive
        ? profileTokens?.onSurfaceSelected
        : null;
    final dropdownInk = usesInkRecipe
        ? context.cs.onPrimaryContainer
        : expressiveInk;
    final inputTextStyle = usesExpressive
        ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: expressiveInk)
        : settingsInputTextStyle(context);
    final dropdownStyle = usesInkRecipe || usesExpressive
        ? Theme.of(context).textTheme.titleMedium?.copyWith(color: dropdownInk)
        : null;
    final bodyFatOptions = <String>[
      '0-5%',
      '5-10%',
      '10-15%',
      '15-20%',
      '20-25%',
      '25-30%',
      '30-35%',
      '35-40%',
      '40-45%',
    ];
    const trendOptions = [
      'Gaining weight',
      'Losing weight',
      'Maintaining weight',
      'Not sure',
    ];
    const activityOptions = ['Low (0-5k)', 'Moderate (5-15k)', 'High (15k+)'];
    const genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _withExpressiveProfileTheme(
      context,
      SettingsPageScaffold(
        title: strings.userInfoTitle,
        subtitle: strings.userInfoSubtitle,
        icon: Icons.badge_outlined,
        heroAccentColor: SettingsAccent.account,
        floatingActionButton: _dirty
            ? FloatingActionButton.extended(
                key: AppTestKeys.userInformationSave,
                onPressed: _save,
                backgroundColor: profileTokens?.actionPrimary,
                foregroundColor: profileTokens?.onActionPrimary,
                icon: const Icon(Icons.save_outlined),
                label: Text(strings.userInfoSaveChanges),
              )
            : null,
        children: [
          SettingsSection(
            title: strings.userInfoIdentityTitle,
            subtitle: strings.userInfoIdentitySubtitle,
            accentColor: SettingsAccent.account,
            surfaceColor: usesExpressive
                ? _profileTokens(context)?.surfacePrimary
                : usesInkRecipe
                ? surfaces.settingsSection
                : null,
            children: [
              _FieldPadding(
                child: TextFormField(
                  key: AppTestKeys.userInformationName,
                  controller: _nameController,
                  onChanged: (_) => _markDirty(),
                  style: inputTextStyle,
                  cursorColor: inputTextStyle?.color,
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoName,
                    hint: strings.userInfoNameHint,
                    icon: Icons.person_outline,
                  ),
                ),
              ),
              _FieldPadding(
                child: ProfileExpressiveChoiceField<String?>(
                  title: strings.userInfoGender,
                  values: genderOptions,
                  value: _gender,
                  label: (value) =>
                      value == null ? '' : _genderLabel(strings, value),
                  choiceKey: (value) =>
                      ValueKey<String>('user-info-dropdown-option-$value'),
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoGender,
                    icon: Icons.wc_outlined,
                  ),
                  textStyle: dropdownStyle,
                  onChanged: (value) {
                    _gender = value;
                    _markDirty();
                  },
                  nonExpressiveField: () => DropdownButtonFormField<String?>(
                    initialValue: _gender,
                    dropdownColor: usesInkRecipe
                        ? surfaces.settingsInput
                        : null,
                    elevation: 8,
                    style: dropdownStyle,
                    iconEnabledColor: dropdownInk,
                    isExpanded: true,
                    itemHeight: null,
                    items: genderOptions.map((gender) {
                      final label = _genderLabel(strings, gender);
                      return _userInformationDropdownItem(
                        context,
                        value: gender,
                        label: label,
                        selectedValue: _gender,
                        expressive: false,
                      );
                    }).toList(),
                    onChanged: (value) {
                      _gender = value;
                      _markDirty();
                    },
                    decoration: _profileInputDecoration(
                      context,
                      label: strings.userInfoGender,
                      icon: Icons.wc_outlined,
                    ),
                  ),
                ),
              ),
              _FieldPadding(
                child: GestureDetector(
                  onTap: _pickDob,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dobController,
                      style: inputTextStyle,
                      cursorColor: inputTextStyle?.color,
                      decoration: _profileInputDecoration(
                        context,
                        label: strings.userInfoDateOfBirth,
                        hint: strings.userInfoDateHint,
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: strings.userInfoBodyMetricsTitle,
            subtitle: strings.userInfoBodyMetricsSubtitle,
            accentColor: SettingsAccent.progress,
            surfaceColor: usesExpressive
                ? _profileTokens(context)?.surfaceTertiary
                : usesInkRecipe
                ? surfaces.planDuration
                : null,
            children: [
              _FieldPadding(
                child: TextFormField(
                  controller: _heightController,
                  onChanged: (_) => _markDirty(),
                  style: inputTextStyle,
                  cursorColor: inputTextStyle?.color,
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoHeight,
                    hint: strings.userInfoHeightHint,
                    icon: Icons.height,
                  ),
                ),
              ),
              _FieldPadding(
                child: TextFormField(
                  controller: _weightController,
                  onChanged: (_) => _markDirty(),
                  style: inputTextStyle,
                  cursorColor: inputTextStyle?.color,
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoCurrentWeight,
                    hint: weightUnit == WeightUnit.pounds
                        ? strings.userInfoWeightPoundsHint
                        : strings.userInfoWeightKilogramsHint,
                    icon: Icons.monitor_weight_outlined,
                    suffixText: weightUnit.shortLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              _FieldPadding(
                child: ProfileExpressiveChoiceField<String?>(
                  title: strings.userInfoBodyFat,
                  values: bodyFatOptions,
                  value: _bodyFatEstimate,
                  label: (value) => value ?? '',
                  choiceKey: (value) =>
                      ValueKey<String>('user-info-dropdown-option-$value'),
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoBodyFat,
                    icon: Icons.percent,
                  ),
                  textStyle: dropdownStyle,
                  onChanged: (value) {
                    _bodyFatEstimate = value;
                    _markDirty();
                  },
                  nonExpressiveField: () => DropdownButtonFormField<String?>(
                    initialValue: _bodyFatEstimate,
                    dropdownColor: usesInkRecipe
                        ? surfaces.settingsInput
                        : null,
                    elevation: 8,
                    style: dropdownStyle,
                    iconEnabledColor: dropdownInk,
                    isExpanded: true,
                    itemHeight: null,
                    items: bodyFatOptions
                        .map(
                          (option) => _userInformationDropdownItem(
                            context,
                            value: option,
                            label: option,
                            selectedValue: _bodyFatEstimate,
                            expressive: false,
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      _bodyFatEstimate = value;
                      _markDirty();
                    },
                    decoration: _profileInputDecoration(
                      context,
                      label: strings.userInfoBodyFat,
                      icon: Icons.percent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: strings.userInfoActivityTitle,
            subtitle: strings.userInfoActivitySubtitle,
            accentColor: SettingsAccent.training,
            surfaceColor: usesExpressive
                ? _profileTokens(context)?.surfaceSecondary
                : usesInkRecipe
                ? surfaces.flowControl
                : null,
            children: [
              _FieldPadding(
                child: ProfileExpressiveChoiceField<String?>(
                  title: strings.userInfoWeightTrend,
                  values: trendOptions,
                  value: _weightTrend,
                  label: (value) =>
                      value == null ? '' : _weightTrendLabel(strings, value),
                  choiceKey: (value) =>
                      ValueKey<String>('user-info-dropdown-option-$value'),
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoWeightTrend,
                    icon: Icons.trending_up,
                  ),
                  textStyle: dropdownStyle,
                  onChanged: (value) {
                    _weightTrend = value;
                    _markDirty();
                  },
                  nonExpressiveField: () => DropdownButtonFormField<String?>(
                    initialValue: _weightTrend,
                    dropdownColor: usesInkRecipe
                        ? surfaces.settingsInput
                        : null,
                    elevation: 8,
                    style: dropdownStyle,
                    iconEnabledColor: dropdownInk,
                    isExpanded: true,
                    itemHeight: null,
                    items: trendOptions.map((option) {
                      final label = _weightTrendLabel(strings, option);
                      return _userInformationDropdownItem(
                        context,
                        value: option,
                        label: label,
                        selectedValue: _weightTrend,
                        expressive: false,
                      );
                    }).toList(),
                    onChanged: (value) {
                      _weightTrend = value;
                      _markDirty();
                    },
                    decoration: _profileInputDecoration(
                      context,
                      label: strings.userInfoWeightTrend,
                      icon: Icons.trending_up,
                    ),
                  ),
                ),
              ),
              _FieldPadding(
                child: ProfileExpressiveChoiceField<String?>(
                  title: strings.userInfoAverageSteps,
                  values: activityOptions,
                  value: _activityLevel,
                  label: (value) =>
                      value == null ? '' : _activityLevelLabel(strings, value),
                  choiceKey: (value) =>
                      ValueKey<String>('user-info-dropdown-option-$value'),
                  decoration: _profileInputDecoration(
                    context,
                    label: strings.userInfoAverageSteps,
                    icon: Icons.directions_walk,
                  ),
                  textStyle: dropdownStyle,
                  onChanged: (value) {
                    _activityLevel = value;
                    _markDirty();
                  },
                  nonExpressiveField: () => DropdownButtonFormField<String?>(
                    initialValue: _activityLevel,
                    dropdownColor: usesInkRecipe
                        ? surfaces.settingsInput
                        : null,
                    elevation: 8,
                    style: dropdownStyle,
                    iconEnabledColor: dropdownInk,
                    isExpanded: true,
                    itemHeight: null,
                    items: activityOptions.map((option) {
                      final label = _activityLevelLabel(strings, option);
                      return _userInformationDropdownItem(
                        context,
                        value: option,
                        label: label,
                        selectedValue: _activityLevel,
                        expressive: false,
                      );
                    }).toList(),
                    onChanged: (value) {
                      _activityLevel = value;
                      _markDirty();
                    },
                    decoration: _profileInputDecoration(
                      context,
                      label: strings.userInfoAverageSteps,
                      icon: Icons.directions_walk,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }

  String _genderLabel(AppLocalizations strings, String value) {
    return switch (value) {
      'Male' => strings.userInfoGenderMale,
      'Female' => strings.userInfoGenderFemale,
      'Other' => strings.userInfoGenderOther,
      'Prefer not to say' => strings.userInfoGenderPreferNotToSay,
      _ => value,
    };
  }

  String _weightTrendLabel(AppLocalizations strings, String value) {
    return switch (value) {
      'Gaining weight' => strings.userInfoTrendGaining,
      'Losing weight' => strings.userInfoTrendLosing,
      'Maintaining weight' => strings.userInfoTrendMaintaining,
      'Not sure' => strings.userInfoTrendNotSure,
      _ => value,
    };
  }

  String _activityLevelLabel(AppLocalizations strings, String value) {
    return switch (value) {
      'Low (0-5k)' => strings.userInfoActivityLow,
      'Moderate (5-15k)' => strings.userInfoActivityModerate,
      'High (15k+)' => strings.userInfoActivityHigh,
      _ => value,
    };
  }
}

class _FieldPadding extends StatelessWidget {
  final Widget child;

  const _FieldPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: child,
    );
  }
}

DropdownMenuItem<String?> _userInformationDropdownItem(
  BuildContext context, {
  required String value,
  required String label,
  required String? selectedValue,
  required bool expressive,
}) {
  if (!expressive) {
    return DropdownMenuItem<String?>(value: value, child: Text(label));
  }

  final tokens = _profileTokens(context)!;
  final selected = value == selectedValue;
  final foreground = selected
      ? tokens.onSurfaceSelected
      : tokens.onSurfaceTertiary;
  final surface = Color.lerp(
    tokens.surfaceTertiary,
    tokens.surfaceSelected,
    selected ? 1 : 0.14,
  )!;

  return DropdownMenuItem<String?>(
    value: value,
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Ink(
        key: ValueKey<String>('user-info-dropdown-option-$value'),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration _profileInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  required IconData icon,
  String? suffixText,
  FloatingLabelBehavior? floatingLabelBehavior,
}) {
  final decoration = settingsInputDecoration(
    context,
    label: label,
    hint: hint,
    icon: icon,
    suffixText: suffixText,
  );
  if (!context.usesExpressivePresentation) return decoration;

  final destination = _profileTokens(context);
  final theme = Theme.of(context);
  final fieldForeground =
      destination?.onSurfaceSelected ?? theme.colorScheme.onSurface;
  final fieldSurface = Color.lerp(
    destination?.surfaceSelected ?? theme.colorScheme.surface,
    fieldForeground,
    0.12,
  )!;
  final errorForeground = tonosSettingsValidationErrorForSurface(
    context,
    fieldSurface,
  );

  InputBorder? expressiveBorder(InputBorder? border) {
    if (border is OutlineInputBorder) {
      return border.copyWith(
        borderRadius: ExpressiveTrainShapes.compactControl,
        borderSide: BorderSide.none,
      );
    }
    return border;
  }

  OutlineInputBorder expressiveErrorBorder(
    InputBorder? border, {
    required bool focused,
  }) {
    if (border is OutlineInputBorder) {
      return border.copyWith(
        borderRadius: ExpressiveTrainShapes.compactControl,
      );
    }
    return OutlineInputBorder(
      borderRadius: ExpressiveTrainShapes.compactControl,
      borderSide: BorderSide(
        color: errorForeground,
        width: focused
            ? context.shapeTokens.focusRingWidth
            : context.shapeTokens.outlineWidth,
      ),
    );
  }

  return decoration.copyWith(
    filled: true,
    fillColor: fieldSurface,
    labelStyle: TextStyle(color: fieldForeground.withValues(alpha: 0.84)),
    floatingLabelStyle: TextStyle(color: fieldForeground),
    hintStyle: TextStyle(color: fieldForeground.withValues(alpha: 0.72)),
    prefixIconColor: fieldForeground,
    suffixStyle: TextStyle(color: fieldForeground),
    floatingLabelBehavior: floatingLabelBehavior,
    errorStyle: TextStyle(color: errorForeground),
    border: expressiveBorder(decoration.border),
    enabledBorder: expressiveBorder(decoration.enabledBorder),
    focusedBorder: OutlineInputBorder(
      borderRadius: ExpressiveTrainShapes.compactControl,
      borderSide: BorderSide(
        color: destination?.outlineAccent ?? fieldForeground,
        width: 2,
      ),
    ),
    errorBorder: expressiveErrorBorder(decoration.errorBorder, focused: false),
    focusedErrorBorder: expressiveErrorBorder(
      decoration.focusedErrorBorder,
      focused: true,
    ),
    disabledBorder: expressiveBorder(decoration.disabledBorder),
  );
}

Widget _withExpressiveProfileTheme(BuildContext context, Widget child) {
  final theme = Theme.of(context);
  final expressive = theme.extension<AppExpressiveTrainTokens>();
  if (!context.usesExpressivePresentation || expressive == null) return child;
  final destination = _profileTokens(context)!;

  final updatedExtensions = theme.extensions.values
      .where(
        (extension) =>
            extension is! AppShapeTokens &&
            extension is! AppSettingsPresentationTokens,
      )
      .toList();
  updatedExtensions.add(
    theme.shapeTokens.copyWith(
      hero: ExpressiveTrainShapes.focusHero,
      sheet: ExpressiveTrainShapes.section,
      settingsPanel: ExpressiveTrainShapes.section,
      settingsAction: ExpressiveTrainShapes.compactControl,
      settingsInput: ExpressiveTrainShapes.compactControl,
      settingsField: ExpressiveTrainShapes.compactControl,
      dialogChoice: ExpressiveTrainShapes.menu,
    ),
  );
  updatedExtensions.add(
    theme.settingsPresentationTokens.copyWith(
      sectionHeaderUsesLabel: true,
      sectionHeaderFill: expressive.selectorTrack,
      sectionHeaderForeground: expressive.navigationLabel,
    ),
  );

  return AppExpressiveDestinationTheme(
    family: AppExpressiveDestinationFamily.profile,
    child: Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: expressive.pageCanvas,
        colorScheme: theme.colorScheme.copyWith(
          surface: destination.surfacePrimary,
          onSurface: destination.onSurfacePrimary,
          onSurfaceVariant: destination.supportingForeground,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: destination.onSurfacePrimary,
          displayColor: destination.onSurfacePrimary,
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          backgroundColor: destination.surfacePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: ExpressiveTrainShapes.menu,
          ),
          titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
            color: destination.onSurfacePrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        radioTheme: theme.radioTheme.copyWith(
          fillColor: WidgetStatePropertyAll<Color?>(
            destination.onSurfacePrimary,
          ),
        ),
        extensions: updatedExtensions,
      ),
      child: child,
    ),
  );
}

AppExpressiveDestinationTokens? _profileTokens(BuildContext context) {
  final tokens = Theme.of(context).extension<AppExpressiveDestinationTokens>();
  if (tokens?.family == AppExpressiveDestinationFamily.profile) return tokens;
  if (!context.usesExpressivePresentation) return null;
  return AppExpressiveDestinationTokens.forFamily(
    AppExpressiveDestinationFamily.profile,
    Theme.of(context).brightness,
  );
}
