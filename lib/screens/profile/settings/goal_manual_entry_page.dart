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

  @override
  void initState() {
    super.initState();
    final profile = context.read<NutritionProfile>();
    final goal = profile.activeGoal;

    _startDate = DateTime(profile.day.year, profile.day.month, profile.day.day);

    void set(TextEditingController controller, num? value) {
      if (value == null) return;
      controller.text = value.toString();
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
                          _kcalCtrl,
                          label: strings.nutritionCalories,
                          integerOnly: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                _proteinCtrl,
                                label: strings.nutritionProtein,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
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
                                _fatCtrl,
                                label: strings.nutritionFat,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
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
                                _sugarCtrl,
                                label: strings.nutritionSugar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                _satFatCtrl,
                                label: strings.nutritionSatFat,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _numField(
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
        MediaQuery.sizeOf(context).width >= 420 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.2;

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
      appBar: AppBar(
        title: Text(strings.nutritionManualGoalsTitle),
        backgroundColor: tokens.surfacePrimary,
        foregroundColor: tokens.onSurfacePrimary,
      ),
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
        decorated: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _ExpressiveGoalSection(
                title: strings.nutritionStartDate,
                color: tokens.surfaceTertiary,
                foreground: tokens.onSurfaceTertiary,
                child: Material(
                  color: tokens.surfacePrimary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickStartDate,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: tokens.onSurfacePrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.nutritionGoalStarts,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: tokens.onSurfacePrimary,
                                      ),
                                ),
                                Text(
                                  '${_startDate.year}-${_two(_startDate.month)}-${_two(_startDate.day)}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: tokens.onSurfacePrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.calendar_month,
                            color: tokens.onSurfacePrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _ExpressiveGoalSection(
                title: strings.nutritionCaloriesAndMacros,
                color: tokens.surfaceSecondary,
                foreground: tokens.onSurfaceSecondary,
                child: Column(
                  children: [
                    _numField(
                      _kcalCtrl,
                      label: strings.nutritionCalories,
                      integerOnly: true,
                    ),
                    const SizedBox(height: 12),
                    fieldPair(
                      _numField(_proteinCtrl, label: strings.nutritionProtein),
                      _numField(_carbCtrl, label: strings.nutritionCarbs),
                    ),
                    const SizedBox(height: 12),
                    fieldPair(
                      _numField(_fatCtrl, label: strings.nutritionFat),
                      _numField(_fiberCtrl, label: strings.nutritionFiber),
                    ),
                  ],
                ),
              ),
              _ExpressiveGoalSection(
                title: strings.nutritionAdditionalNutrients,
                color: tokens.surfaceAccent,
                foreground: tokens.onSurfaceAccent,
                child: Column(
                  children: [
                    fieldPair(
                      _numField(_sugarCtrl, label: strings.nutritionSugar),
                      _numField(_satFatCtrl, label: strings.nutritionSatFat),
                    ),
                    const SizedBox(height: 12),
                    _numField(
                      _sodiumCtrl,
                      label: strings.nutritionSodium,
                      integerOnly: true,
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
    TextEditingController controller, {
    required String label,
    bool integerOnly = false,
  }) {
    final tokens = context.usesExpressivePresentation
        ? Theme.of(context).extension<AppExpressiveDestinationTokens>()
        : null;
    final inputShape = BorderRadius.circular(14);
    final expressiveDecoration = tokens == null
        ? null
        : InputDecoration(
            labelText: label,
            isDense: true,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
            labelStyle: TextStyle(color: tokens.supportingForeground),
            floatingLabelStyle: TextStyle(color: tokens.outlineAccent),
            enabledBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(
                color: tokens.outlineAccent.withValues(alpha: 0.55),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: inputShape,
              borderSide: BorderSide(color: tokens.outlineAccent, width: 2),
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
    return TextFormField(
      controller: controller,
      keyboardType: integerOnly
          ? const TextInputType.numberWithOptions(signed: false, decimal: false)
          : const TextInputType.numberWithOptions(signed: false, decimal: true),
      style: tokens == null
          ? settingsInputTextStyle(context)
          : TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
    required this.color,
    required this.foreground,
    required this.child,
  });

  final String title;
  final Color color;
  final Color foreground;
  final Widget child;

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
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
