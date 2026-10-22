import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/nutrition_models.dart';
import '../../../providers/nutrition_profile.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../widgets/safe_error_view.dart';
import '../../../widgets/settings_tiles.dart';

class GoalManualEntryPage extends StatefulWidget {
  const GoalManualEntryPage({super.key});

  @override
  State<GoalManualEntryPage> createState() => _GoalManualEntryPageState();
}

class _GoalManualEntryPageState extends State<GoalManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _satFatCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final profile = context.read<NutritionProfile>();
    final goal = profile.activeGoal;
    final expressive = context.usesExpressivePresentation;

    _startDate = DateTime(profile.day.year, profile.day.month, profile.day.day);

    void set(TextEditingController controller, num? value) {
      if (value == null) return;
      controller.text =
          expressive && value.isFinite && value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toString();
    }

    set(_kcalCtrl, goal?.kcalTarget);
    set(_proteinCtrl, goal?.proteinG);
    set(_carbCtrl, goal?.carbsG);
    set(_fatCtrl, goal?.fatG);
    set(_fiberCtrl, goal?.fiberG);
    set(_sugarCtrl, goal?.sugarG);
    set(_satFatCtrl, goal?.satFatG);
    set(_sodiumCtrl, goal?.sodiumMg);
  }

  @override
  void dispose() {
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    _sugarCtrl.dispose();
    _satFatCtrl.dispose();
    _sodiumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (pickerContext, child) {
        if (!context.usesExpressivePresentation) return child!;
        final theme = Theme.of(pickerContext);
        final tokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.nutrition,
          theme.brightness,
        );
        return Theme(
          data: theme.copyWith(
            datePickerTheme: theme.datePickerTheme.copyWith(
              backgroundColor: tokens.pageCanvas,
              headerBackgroundColor: tokens.surfacePrimary,
              headerForegroundColor: tokens.onSurfacePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _saveGoals() async {
    final profile = context.read<NutritionProfile>();
    if (profile.current?.id == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final goal = NutritionGoal(
        profileId: profile.current!.id!,
        startDate: _startDate,
        kcalTarget: _toDouble(_kcalCtrl),
        proteinG: _toDouble(_proteinCtrl),
        fatG: _toDouble(_fatCtrl),
        carbsG: _toDouble(_carbCtrl),
        fiberG: _toDouble(_fiberCtrl),
        sugarG: _toDouble(_sugarCtrl),
        satFatG: _toDouble(_satFatCtrl),
        sodiumMg: _toDouble(_sodiumCtrl),
      );

      final saved = await profile.setGoals(goal);
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          safeFailureSnackBar(
            context,
            error: profile.error ?? StateError('goal save failed'),
            summary: AppLocalizations.of(context).safeFailureSaveTitle,
          ),
        );
        return;
      }
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.usesExpressivePresentation) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.nutrition,
        child: Builder(builder: _buildExpressive),
      );
    }
    return _buildClassicAndNeo(context);
  }

  Widget _buildClassicAndNeo(BuildContext context) {
    final canSave = context.watch<NutritionProfile>().current?.id != null;
    final strings = AppLocalizations.of(context);

    return SettingsPageScaffold(
      title: strings.nutritionManualGoalsTitle,
      subtitle: strings.nutritionManualGoalsPageSubtitle,
      icon: Icons.flag,
      bottomNavigationBar: SettingsSaveBar(
        label: _saving ? strings.nutritionSaving : strings.nutritionSaveGoals,
        onPressed: !canSave || _saving ? null : _saveGoals,
        cancelLabel: strings.commonCancel,
        onCancel: _saving ? null : () => Navigator.pop(context, false),
        saveIcon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        decorated: false,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              SettingsSection(
                title: strings.nutritionStartDate,
                children: [
                  SettingsActionTile(
                    icon: Icons.date_range,
                    title: strings.nutritionGoalStarts,
                    subtitle:
                        '${_startDate.year}-${_two(_startDate.month)}-${_two(_startDate.day)}',
                    trailing: const Icon(Icons.calendar_month),
                    onTap: _pickStartDate,
                  ),
                ],
              ),
              SettingsSection(
                title: strings.nutritionCaloriesAndMacros,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _numField(
                          context,
                          _kcalCtrl,
                          label: strings.nutritionCalories,
                          integerOnly: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                _proteinCtrl,
                                label: strings.nutritionProtein,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                context,
                                _carbCtrl,
                                label: strings.nutritionCarbs,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                _fatCtrl,
                                label: strings.nutritionFat,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                context,
                                _fiberCtrl,
                                label: strings.nutritionFiber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: strings.nutritionAdditionalNutrients,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                _sugarCtrl,
                                label: strings.nutritionSugar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                context,
                                _satFatCtrl,
                                label: strings.nutritionSatFat,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _numField(
                          context,
                          _sodiumCtrl,
                          label: strings.nutritionSodium,
                          integerOnly: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpressive(BuildContext context) {
    final canSave = context.watch<NutritionProfile>().current?.id != null;
    final strings = AppLocalizations.of(context);
    final tokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>()!;
    final wideFields =
        MediaQuery.sizeOf(context).width >= 380 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.2;
    final macrosSurface = Color.lerp(
      tokens.surfaceSecondary,
      tokens.pageCanvas,
      0.4,
    )!;
    final additionalSurface = Color.lerp(
      tokens.surfaceAccent,
      tokens.pageCanvas,
      0.4,
    )!;

    Widget nutrientField(
      TextEditingController controller,
      String label, {
      bool additional = false,
      bool integerOnly = false,
    }) => _numField(
      context,
      controller,
      label: label,
      integerOnly: integerOnly,
      sectionSurface: additional ? additionalSurface : macrosSurface,
      sectionForeground: additional
          ? tokens.onSurfaceAccent
          : tokens.onSurfaceSecondary,
    );

    Widget fieldPair(Widget first, Widget second) => wideFields
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          )
        : Column(children: [first, const SizedBox(height: 12), second]);

    return Scaffold(
      backgroundColor: tokens.pageCanvas,
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          strings.nutritionManualGoalsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: tokens.onSurfacePrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: tokens.surfacePrimary,
        foregroundColor: tokens.onSurfacePrimary,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.actionPrimary,
                foregroundColor: tokens.onActionPrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: context.nutritionTokens.portionShape,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.supportingForeground,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: tokens.outlineAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: context.nutritionTokens.portionShape,
                ),
              ),
            ),
          ),
          child: SettingsSaveBar(
            label: _saving
                ? strings.nutritionSaving
                : strings.nutritionSaveGoals,
            onPressed: !canSave || _saving ? null : _saveGoals,
            cancelLabel: strings.commonCancel,
            onCancel: _saving ? null : () => Navigator.pop(context, false),
            saveIcon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            decorated: false,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            primary: false,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: tokens.surfaceTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: context.nutritionTokens.sectionShape,
                    side: BorderSide(
                      color: tokens.onSurfaceTertiary.withValues(alpha: 0.18),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _pickStartDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.onSurfaceTertiary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius:
                                  context.nutritionTokens.compactShape,
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color: tokens.onSurfaceTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.nutritionStartDate,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: tokens.onSurfaceTertiary
                                            .withValues(alpha: 0.82),
                                      ),
                                ),
                                Text(
                                  MaterialLocalizations.of(context)
                                      .formatMediumDate(_startDate),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: tokens.onSurfaceTertiary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: tokens.onSurfaceTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _ExpressiveGoalSection(
                title: strings.nutritionCaloriesAndMacros,
                icon: Icons.restaurant_menu,
                color: macrosSurface,
                foreground: tokens.onSurfaceSecondary,
                helperText: strings.nutritionOptionalTargetsHint,
                child: Column(
                  children: [
                    nutrientField(
                      _kcalCtrl,
                      strings.nutritionCalories,
                      integerOnly: true,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = [
                          nutrientField(_proteinCtrl, strings.nutritionProtein),
                          nutrientField(_carbCtrl, strings.nutritionCarbs),
                          nutrientField(_fatCtrl, strings.nutritionFat),
                        ];
                        if (!wideFields || constraints.maxWidth < 300) {
                          return Column(
                            children: [
                              for (
                                var index = 0;
                                index < fields.length;
                                index++
                              ) ...[
                                if (index > 0) const SizedBox(height: 12),
                                fields[index],
                              ],
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var index = 0;
                              index < fields.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(width: 12),
                              Expanded(child: fields[index]),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              _ExpressiveGoalSection(
                title: strings.nutritionAdditionalNutrients,
                icon: Icons.science_outlined,
                color: additionalSurface,
                foreground: tokens.onSurfaceAccent,
                child: Column(
                  children: [
                    fieldPair(
                      nutrientField(
                        _fiberCtrl,
                        strings.nutritionFiber,
                        additional: true,
                      ),
                      nutrientField(
                        _sugarCtrl,
                        strings.nutritionSugar,
                        additional: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    fieldPair(
                      nutrientField(
                        _satFatCtrl,
                        strings.nutritionSatFat,
                        additional: true,
                      ),
                      nutrientField(
                        _sodiumCtrl,
                        strings.nutritionSodium,
                        additional: true,
                        integerOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numField(
    BuildContext context,
    TextEditingController controller, {
    required String label,
    bool integerOnly = false,
    Color? sectionSurface,
    Color? sectionForeground,
  }) {
    final tokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final inputShape = BorderRadius.circular(14);
    final fieldInk = sectionForeground ?? tokens?.supportingForeground;
    final expressiveDecoration = tokens == null
        ? null
        : InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: '—',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: Color.lerp(
              sectionSurface ?? tokens.pageCanvas,
              tokens.pageCanvas,
              Theme.of(context).brightness == Brightness.dark ? 0.58 : 0.85,
            ),
            hintStyle: TextStyle(
              color: fieldInk?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(color: fieldInk),
            floatingLabelStyle: WidgetStateTextStyle.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.error)
                    ? Theme.of(context).colorScheme.error
                    : states.contains(WidgetState.focused)
                    ? tokens.actionPrimary
                    : fieldInk?.withValues(alpha: 0.82),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(color: fieldInk!.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(color: tokens.actionPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          );
    final field = TextFormField(
      controller: controller,
      scrollPadding: tokens == null
          ? const EdgeInsets.all(20)
          : const EdgeInsets.fromLTRB(8, 32, 8, 88),
      keyboardType: integerOnly
          ? const TextInputType.numberWithOptions(signed: false, decimal: false)
          : const TextInputType.numberWithOptions(signed: false, decimal: true),
      style: tokens == null
          ? settingsInputTextStyle(context)
          : TextStyle(
              color: fieldInk,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
      textInputAction: tokens == null
          ? null
          : identical(controller, _sodiumCtrl)
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: tokens == null
          ? null
          : (_) {
              final scope = FocusScope.of(context);
              if (identical(controller, _sodiumCtrl)) {
                scope.unfocus();
              } else {
                scope.nextFocus();
              }
            },
      decoration:
          expressiveDecoration ??
          settingsFieldDecoration(context, label: label, isDense: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final parsed = num.tryParse(value);
        if (parsed == null) {
          return AppLocalizations.of(context).nutritionEnterNumber;
        }
        if (parsed < 0) {
          return AppLocalizations.of(context).nutritionNumberAtLeastZero;
        }
        return null;
      },
    );
    return tokens == null
        ? field
        : ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: field,
          );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  double? _toDouble(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}

class _ExpressiveGoalSection extends StatelessWidget {
  const _ExpressiveGoalSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.foreground,
    required this.child,
    this.helperText,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color foreground;
  final Widget child;
  final String? helperText;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(14),
      ),
      border: Border.all(color: foreground.withValues(alpha: 0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.08),
                borderRadius: context.nutritionTokens.compactShape,
              ),
              child: Icon(icon, size: 20, color: foreground),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: foreground.withValues(alpha: 0.82)),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
