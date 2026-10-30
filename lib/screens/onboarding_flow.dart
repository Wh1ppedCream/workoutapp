// File: lib/screens/onboarding_flow.dart

import 'package:material_ui/material_ui.dart';

import '../theme/widgets/tonos_expressive_navigation_motion.dart';
import '../theme/widgets/tonos_expressive_state_motion.dart';
import '../theme/widgets/tonos_overlay_routes.dart';

import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/theme_extensions.dart';
import '../theme/expressive_planning_tokens.dart';
import '../theme/tokens/app_tutorial_tokens.dart';
import '../theme/widgets/tonos_dialog.dart';
import '../l10n/safe_failure_localizations.dart';
import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/locale_preference_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/preset_session.dart';
import '../providers/selected_profile.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../services/catalog_entity_localizer.dart';
import '../utils/localized_digit_formatter.dart';
import '../utils/localized_formatters.dart';
import '../utils/weight_unit_formatter.dart';
import '../widgets/body_heatmap.dart';
import '../widgets/identity_color_palettes.dart';
import '../widgets/localized_catalog_entity_name.dart';
import '../widgets/preset_bar.dart';
import '../widgets/settings_tiles.dart';
import 'exercise/gym_profile_screen.dart';
import 'exercise/premade_plans_page.dart';
import 'exercise/preset_detail_screen.dart';
import 'exercise/preset_generation_qa.dart';

part 'onboarding/onboarding_models_and_templates.dart';
part 'onboarding/onboarding_plan_overview_list.dart';
part 'onboarding/onboarding_step_widgets.dart';

Duration _onboardingSelectionMotion(BuildContext context) =>
    context.usesExpressivePresentation
    ? TonosExpressiveStateMotion.duration(
        context,
        TonosExpressiveStateMotion.fast,
      )
    : tutorialMotion(context, context.tutorialTokens.selectionDuration);

InputDecoration _onboardingInputDecoration(
  BuildContext context, {
  required String? label,
  IconData? icon,
  String? hint,
  String? suffixText,
}) {
  final expressive = AppExpressivePlanningTokens.maybeOf(context);
  if (expressive != null) {
    final border = OutlineInputBorder(
      borderRadius: context.tutorialTokens.inputShape,
      borderSide: BorderSide(color: expressive.outline.withValues(alpha: 0.4)),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: icon == null ? null : Icon(icon),
      prefixIconColor: expressive.planSupportForeground,
      labelStyle: TextStyle(color: expressive.planSupportForeground),
      filled: true,
      fillColor: Color.lerp(
        expressive.planSupportSurface,
        expressive.pageCanvas,
        0.65,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: expressive.actionPrimary, width: 2),
      ),
    );
  }
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    prefixIcon: icon == null ? null : Icon(icon),
    border: OutlineInputBorder(borderRadius: context.tutorialTokens.inputShape),
  );
}

/// Initial setup flow for basic user details plus optional workout and
/// nutrition personalization.
class OnboardingFlow extends StatefulWidget {
  /// Exposes the paused setup pages in the isolated review app.
  /// Nutrition goal controls remain previews rather than persisted targets.
  final bool reviewMode;

  const OnboardingFlow({super.key, this.reviewMode = false});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

/// Exposes the actual route widgets for qualification without enabling paused
/// Nutrition pages or adding test-only state branches to onboarding.
@visibleForTesting
abstract final class OnboardingStyleHarness {
  static Widget card({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) => _OnboardingCard(
    icon: icon,
    title: title,
    subtitle: subtitle,
    children: children,
  );

  static Widget switchCard({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => _SwitchCard(title: title, value: value, onChanged: onChanged);

  static Widget intentTile({
    required IconData icon,
    required String title,
    required String body,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => _IntentTile(
    icon: icon,
    title: title,
    body: body,
    value: value,
    onChanged: onChanged,
  );

  static Widget gymSpaceTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) => _GymSpaceTile(
    template: _gymSpaceTemplates.first,
    title: title,
    subtitle: subtitle,
    selected: selected,
    onTap: onTap,
  );

  static Widget workoutPlanSetupTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) => _WorkoutPlanSetupTile(
    title: title,
    subtitle: subtitle,
    icon: Icons.fitness_center,
    selected: selected,
    onTap: onTap,
  );

  static Widget choiceGroup({
    required String title,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) => _ChoiceGroup<String>(
    title: title,
    options: options,
    value: value,
    onChanged: onChanged,
  );

  static Widget bodyFatTile({
    required String label,
    required String assetPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) => _BodyFatTile(
    label: label,
    assetPath: assetPath,
    isSelected: isSelected,
    onTap: onTap,
  );

  static Widget metricPreviewCard({
    required IconData icon,
    required String value,
    required String label,
  }) => _MetricPreviewCard(icon: icon, value: value, label: label);

  static Widget sliderPanel({
    required String title,
    required String valueLabel,
    required Widget child,
  }) => _SliderPanel(title: title, valueLabel: valueLabel, child: child);

  static Widget miniStat({required String label, required String value}) =>
      _MiniStat(label: label, value: value);

  static Widget planOverviewList({
    required AppRepository repository,
    required int? profileId,
    required Set<int> planIds,
    required int refreshToken,
    required VoidCallback onChanged,
  }) => _OnboardingPlanOverviewList(
    repository: repository,
    profileId: profileId,
    planIds: planIds,
    refreshToken: refreshToken,
    onChanged: onChanged,
  );

  static Widget infoCallout({required IconData icon, required String text}) =>
      _OnboardingInfoCallout(icon: icon, text: text);

  static Widget equipmentSummary({
    required String heading,
    required String count,
    required String description,
    required List<Widget> content,
  }) => _OnboardingEquipmentSummary(
    heading: heading,
    count: count,
    description: description,
    content: content,
  );

  static Widget skipSetupDialog({
    required String title,
    required String body,
    required String cancelLabel,
    required String confirmLabel,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) => _OnboardingSkipSetupDialog(
    title: title,
    body: body,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
    onCancel: onCancel,
    onConfirm: onConfirm,
  );
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _calorieFloorController = TextEditingController();
  final _gymProfileNameController = TextEditingController();

  int _currentPage = 0;
  bool _gymEquipmentLoaded = false;
  bool _isGymEquipmentLoading = true;
  bool _gymEquipmentLoadFailed = false;
  bool _isFinishing = false;
  bool _advancing = false;
  bool _pageTransitionInFlight = false;
  bool _showAllEquipment = false;
  String? _gender;
  DateTime? _dob;
  bool _weighedHeavy = false;
  String? _weightTrend;
  String? _bodyFatEstimate;
  String _preferredDiet = 'Balanced';
  String _trainingType = 'Lifting and cardio';
  String _proteinPreference = 'Moderate';
  bool _useNutritionData = false;
  bool _useExerciseData = false;
  bool _unitPreferenceLoaded = false;
  WeightUnit _selectedWeightUnit = WeightUnit.pounds;
  double? _weightInputCanonicalLbs;
  _GymSpaceTemplate? _selectedGymSpace;
  _WorkoutPlanSetupOption? _workoutPlanSetupOption;
  List<Equipment> _availableGymEquipment = const [];
  Set<String> _selectedGymEquipmentNames = {};
  int? _onboardingProfileId;
  int _onboardingPlansAdded = 0;
  int _planOverviewRefreshToken = 0;
  final List<int> _onboardingPlanIds = [];
  final Set<int> _onboardingDraftProfileIds = {};

  double _goalWeightValue = 140;
  final DateTime _projectedEndDate = DateTime.now().add(
    const Duration(days: 30),
  );
  double _weeklyRatePct = 0.5;
  double get _weeklyRateLbs => _goalWeightValue * _weeklyRatePct / 100;
  double get _monthlyRateLbs => _weeklyRateLbs * 4;
  double get _monthlyRatePct => _weeklyRatePct * 4;

  bool get _nutritionOnboardingEnabled => widget.reviewMode;

  AppLocalizations get _strings => AppLocalizations.of(context);

  bool get _showWorkoutPlanOverview =>
      _useExerciseData &&
      _workoutPlanSetupOption != _WorkoutPlanSetupOption.skip &&
      _onboardingPlanIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _useNutritionData = widget.reviewMode;
    _useExerciseData = widget.reviewMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final unitPreferences = context.watch<UnitPreferenceProvider>();
    if (!_unitPreferenceLoaded && unitPreferences.loaded) {
      _unitPreferenceLoaded = true;
      _selectedWeightUnit = unitPreferences.weightUnit;
    }
    if (!_gymEquipmentLoaded) {
      _gymEquipmentLoaded = true;
      _loadGymEquipment();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieFloorController.dispose();
    _gymProfileNameController.dispose();
    super.dispose();
  }

  List<_OnboardingPage> get _pages {
    final strings = _strings;
    return [
      _OnboardingPage(
        id: 'welcome',
        label: strings.onboardingPageWelcome,
        builder: _buildWelcomePage,
      ),
      _OnboardingPage(
        id: 'basics',
        label: strings.onboardingPageBasics,
        builder: _buildPersonalInfoPage,
      ),
      _OnboardingPage(
        id: 'focus',
        label: strings.onboardingPageFocus,
        builder: _buildUsageIntentPage,
      ),
      if (_nutritionOnboardingEnabled && _useNutritionData) ...[
        _OnboardingPage(
          id: 'weight',
          label: strings.onboardingPageWeight,
          builder: _buildWeightHistoryPage,
        ),
        _OnboardingPage(
          id: 'body-fat',
          label: strings.onboardingPageBodyFat,
          builder: _buildBodyFatPage,
        ),
        _OnboardingPage(
          id: 'nutrition',
          label: strings.onboardingPageNutrition,
          builder: _buildNutritionAndTrainingPage,
        ),
        _OnboardingPage(
          id: 'goal',
          label: strings.onboardingPageGoal,
          builder: _buildNutritionGoalPage,
        ),
      ],
      if (_useExerciseData) ...[
        _OnboardingPage(
          id: 'gym-profile',
          label: strings.onboardingPageGymProfile,
          builder: _buildGymSpacePage,
        ),
        if (_selectedGymSpace != null && !_selectedGymSpace!.skipSetup)
          _OnboardingPage(
            id: 'equipment',
            label: strings.onboardingPageEquipment,
            builder: _buildGymEquipmentPage,
          ),
        _OnboardingPage(
          id: 'workout-plan',
          label: strings.onboardingPageWorkoutPlan,
          builder: _buildWorkoutPlanPage,
        ),
        if (_showWorkoutPlanOverview)
          _OnboardingPage(
            id: 'plan-overview',
            label: strings.onboardingPagePlanOverview,
            builder: _buildWorkoutPlanOverviewPage,
          ),
      ],
      _OnboardingPage(
        id: 'summary',
        label: strings.onboardingPageSummary,
        builder: _buildSummaryPage,
      ),
    ];
  }

  bool _hasAnyInput() {
    return _nameController.text.trim().isNotEmpty ||
        _dob != null ||
        _heightController.text.trim().isNotEmpty ||
        _weightController.text.trim().isNotEmpty ||
        (_bodyFatEstimate?.isNotEmpty ?? false) ||
        (_weightTrend?.isNotEmpty ?? false) ||
        _gender != null;
  }

  Future<void> _loadGymEquipment() async {
    if (mounted && !_isGymEquipmentLoading) {
      setState(() {
        _isGymEquipmentLoading = true;
        _gymEquipmentLoadFailed = false;
      });
    }
    try {
      final equipment = await context.read<AppRepository>().fetchAllEquipment();
      if (!mounted) return;
      setState(() {
        _availableGymEquipment = equipment;
        _isGymEquipmentLoading = false;
        _gymEquipmentLoadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableGymEquipment = const [];
        _isGymEquipmentLoading = false;
        _gymEquipmentLoadFailed = true;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final repo = context.read<AppRepository>();
    final onboardingConfig = context.read<OnboardingConfig>();
    final unitPrefs = context.read<UnitPreferenceProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final enteredWeight = double.tryParse(_weightController.text.trim());
      final bodyWeightLbs =
          _weightInputCanonicalLbs ??
          (enteredWeight == null || enteredWeight <= 0
              ? null
              : WeightUnitFormatter.toPounds(
                  enteredWeight,
                  _selectedWeightUnit,
                ));
      final info = PersonalInfo(
        name: _clean(_nameController.text),
        gender: _gender,
        dob: _dob,
        height: _clean(_heightController.text),
        weight: bodyWeightLbs == null
            ? _clean(_weightController.text)
            : WeightUnitFormatter.formatPreciseInputWeight(
                bodyWeightLbs,
                WeightUnit.pounds,
              ),
        bodyFatEstimate: _bodyFatEstimate,
        weightTrend: _weightTrend,
        activityLevel: null,
      );

      if (_hasAnyInput()) {
        await repo.savePersonalInfoWithBodyWeight(
          info: info,
          bodyWeightValue: bodyWeightLbs == null
              ? null
              : WeightUnitFormatter.fromPounds(
                  bodyWeightLbs,
                  _selectedWeightUnit,
                ),
          bodyWeightUnit: _selectedWeightUnit,
          measurementNote: 'Onboarding',
        );
      }

      await unitPrefs.setWeightUnit(_selectedWeightUnit);
      final profileId = await _createOrUpdateSelectedGymProfile(repo);
      if (profileId != null) _onboardingProfileId = profileId;
      final draftProfileIds = <int>{
        ..._onboardingDraftProfileIds,
        if (_onboardingProfileId != null) _onboardingProfileId!,
      };
      for (final draftProfileId in draftProfileIds) {
        await repo.deleteDraftPresetsForProfile(draftProfileId);
      }
      await onboardingConfig.markCompleted();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _strings.onboardingFinishError(safeFailureMessage(_strings, error)),
          ),
        ),
      );
    }
  }

  Future<int?> _createOrUpdateSelectedGymProfile(AppRepository repo) async {
    final template = _selectedGymSpace;
    if (!_useExerciseData || template == null || template.skipSetup) {
      return null;
    }

    final selectedEquipment = _availableGymEquipment
        .where((item) => _selectedGymEquipmentNames.contains(item.name))
        .toList();
    if (selectedEquipment.isEmpty) {
      throw StateError(_strings.onboardingSelectEquipmentError);
    }

    final existingProfiles = await repo.fetchAllProfiles();
    final requestedName = _gymProfileNameController.text.trim().isEmpty
        ? _gymSpaceDefaultProfileName(template)
        : _gymProfileNameController.text.trim();

    final profileId = _onboardingProfileId;
    if (profileId != null &&
        existingProfiles.any((profile) => profile.id == profileId)) {
      final currentProfile = existingProfiles.firstWhere(
        (profile) => profile.id == profileId,
      );
      final profileName = _uniqueProfileName(
        requestedName,
        existingProfiles,
        ignoredProfileId: profileId,
      );
      await repo.saveGymProfileAtomic(
        existingProfile: currentProfile,
        name: profileName,
        equipmentIds: selectedEquipment.map((item) => item.id).toSet(),
      );
      await _selectProfile(profileId);
      return profileId;
    }

    final profileName = _uniqueProfileName(requestedName, existingProfiles);

    final createdProfileId = await repo.saveGymProfileAtomic(
      existingProfile: null,
      name: profileName,
      equipmentIds: selectedEquipment.map((item) => item.id).toSet(),
    );

    if (!mounted) return createdProfileId;
    _onboardingProfileId = createdProfileId;
    await _selectProfile(createdProfileId);
    return createdProfileId;
  }

  Future<void> _selectProfile(int profileId) async {
    if (!mounted) return;
    final selectedProfile = context.read<SelectedProfile>();
    await selectedProfile.loadProfiles(preferredProfileId: profileId);
  }

  String _uniqueProfileName(
    String requestedName,
    List<GymProfile> existingProfiles, {
    int? ignoredProfileId,
  }) {
    final existingNames = existingProfiles
        .where((profile) => profile.id != ignoredProfileId)
        .map((profile) => profile.name.toLowerCase())
        .toSet();
    if (!existingNames.contains(requestedName.toLowerCase())) {
      return requestedName;
    }

    var suffix = 2;
    while (existingNames.contains('$requestedName ($suffix)'.toLowerCase())) {
      suffix++;
    }
    return '$requestedName ($suffix)';
  }

  String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _selectGymSpace(_GymSpaceTemplate template) {
    final availableNames = _availableGymEquipment
        .map((equipment) => equipment.name)
        .toSet();
    final equipmentNames = template.includeAllEquipment
        ? availableNames
        : template.equipmentNames.intersection(availableNames);

    setState(() {
      _selectedGymSpace = template;
      _showAllEquipment = false;
      _gymProfileNameController.text = _gymSpaceDefaultProfileName(template);
      _selectedGymEquipmentNames = Set<String>.from(equipmentNames);
    });
  }

  void _goToGymEquipmentPage() {
    final equipmentPageIndex = _pages.indexWhere(
      (page) => page.id == 'equipment',
    );
    if (equipmentPageIndex == -1 || equipmentPageIndex == _currentPage) {
      return;
    }

    _goToPage(equipmentPageIndex);
  }

  void _resetGymEquipment() {
    final template = _selectedGymSpace;
    if (template == null || template.skipSetup) return;
    _selectGymSpace(template);
  }

  Future<int?> _ensureWorkoutPlanProfileId() async {
    final repo = context.read<AppRepository>();
    if (_selectedGymSpace != null && !_selectedGymSpace!.skipSetup) {
      return _createOrUpdateSelectedGymProfile(repo);
    }

    final selectedProfile = context.read<SelectedProfile>();
    await selectedProfile.loadProfiles();
    final currentId = selectedProfile.currentProfile?.id;
    if (currentId != null) {
      _onboardingProfileId = currentId;
      return currentId;
    }

    final profiles = selectedProfile.profiles;
    if (profiles.isNotEmpty) {
      final generalProfile = profiles.cast<GymProfile?>().firstWhere(
        (profile) => profile?.name.toLowerCase() == 'general',
        orElse: () => profiles.first,
      );
      if (generalProfile?.id != null) {
        await selectedProfile.selectProfile(generalProfile!);
        _onboardingProfileId = generalProfile.id;
        return generalProfile.id;
      }
    }

    final profileId = await repo.createProfile('General');
    await selectedProfile.loadProfiles();
    await selectedProfile.selectProfile(
      selectedProfile.profiles.firstWhere((profile) => profile.id == profileId),
    );
    _onboardingProfileId = profileId;
    return profileId;
  }

  bool _canAdvance(_OnboardingPage page) {
    if (page.id == 'gym-profile') {
      return _selectedGymSpace != null;
    }
    if (page.id == 'equipment') {
      return _gymProfileNameController.text.trim().isNotEmpty &&
          _selectedGymEquipmentNames.isNotEmpty;
    }
    if (page.id == 'workout-plan') {
      return _workoutPlanSetupOption != null;
    }
    return true;
  }

  bool get _hasSelectedOnboardingFocus =>
      (_nutritionOnboardingEnabled && _useNutritionData) || _useExerciseData;

  Future<bool> _confirmSkipOnboarding() async {
    // The confirmation route can outlive this page during an app teardown.
    // Capture localized copy now instead of reading from a disposed context.
    final strings = _strings;
    final result = await showTonosDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _OnboardingSkipSetupDialog(
          title: strings.onboardingSkipSetupTitle,
          body: strings.onboardingSkipSetupBody,
          cancelLabel: strings.onboardingCancel,
          confirmLabel: strings.onboardingConfirm,
          onCancel: () => Navigator.of(dialogContext).pop(false),
          onConfirm: () => Navigator.of(dialogContext).pop(true),
        );
      },
    );
    return result ?? false;
  }

  void _prepareSkippedSetupForFinish() {
    if (!_useExerciseData) return;
    final gymSpace = _selectedGymSpace;
    final hasIncompleteGymSetup =
        gymSpace == null ||
        (!gymSpace.skipSetup &&
            (_gymProfileNameController.text.trim().isEmpty ||
                _selectedGymEquipmentNames.isEmpty));
    if (hasIncompleteGymSetup) {
      _selectGymSpace(_skipGymSpaceTemplate);
    }
  }

  Future<void> _skipToHomeAfterConfirmation() async {
    _prepareSkippedSetupForFinish();
    if (!mounted) return;
    await _finishOnboarding();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _dob = picked);
  }

  Future<void> _nextAction() async {
    if (_advancing || _isFinishing || _pageTransitionInFlight) return;
    setState(() => _advancing = true);
    try {
      await _advanceToNextStep();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _strings.onboardingFinishError(safeFailureMessage(_strings, error)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Future<void> _advanceToNextStep() async {
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    final currentIndex = _currentPage >= pages.length
        ? lastPageIndex
        : _currentPage;
    final currentPage = pages[currentIndex];

    if (currentPage.id == 'focus' && !_hasSelectedOnboardingFocus) {
      final shouldSkip = await _confirmSkipOnboarding();
      if (!mounted || !shouldSkip) return;
      await _skipToHomeAfterConfirmation();
      return;
    }

    if (currentPage.id == 'gym-profile' && _selectedGymSpace?.id == 'custom') {
      await _openGymProfileEditor();
      if (!mounted) return;
      _goToGymEquipmentPage();
      return;
    }

    if (currentPage.id == 'workout-plan') {
      await _handleWorkoutPlanNext();
      return;
    }

    if (_currentPage < lastPageIndex) {
      _goToPage(_currentPage + 1);
      return;
    }
    _finishOnboarding();
  }

  Future<void> _handleWorkoutPlanNext() async {
    switch (_workoutPlanSetupOption) {
      case _WorkoutPlanSetupOption.skip:
        _goToNextPage();
        return;
      case _WorkoutPlanSetupOption.premade:
        await _openOnboardingPremadePlans();
        return;
      case _WorkoutPlanSetupOption.generate:
        await _openOnboardingPlanGenerator();
        return;
      case _WorkoutPlanSetupOption.manual:
        await _openOnboardingManualPlan();
        return;
      case null:
        return;
    }
  }

  void _goToNextPage() {
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    if (_currentPage >= lastPageIndex) {
      _finishOnboarding();
      return;
    }
    _goToPage(_currentPage + 1);
  }

  Future<void> _openOnboardingPremadePlans() async {
    final profileId = await _ensureWorkoutPlanProfileId();
    if (!mounted || profileId == null) return;

    final addedPlanIds = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder: (_) => PremadePlansPage(
          profileId: profileId,
          onboardingMode: true,
          initiallyMatchProfileEquipment: !widget.reviewMode,
          onPlanAdded: () {},
        ),
      ),
    );
    if (!mounted) return;
    if (addedPlanIds != null && addedPlanIds.isNotEmpty) {
      setState(() {
        _onboardingPlansAdded += addedPlanIds.length;
        _onboardingPlanIds.addAll(addedPlanIds);
        _planOverviewRefreshToken++;
      });
      _goToNextPage();
    }
  }

  Future<void> _openOnboardingPlanGenerator() async {
    final profileId = await _ensureWorkoutPlanProfileId();
    if (!mounted || profileId == null) return;

    final generatedPlanIds = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder: (_) => PresetGenerationQaScreen(
          profileId: profileId,
          onboardingMode: true,
        ),
      ),
    );
    if (!mounted || generatedPlanIds == null || generatedPlanIds.isEmpty) {
      return;
    }
    setState(() {
      _onboardingPlansAdded += generatedPlanIds.length;
      _onboardingPlanIds.addAll(generatedPlanIds);
      _planOverviewRefreshToken++;
    });
    _goToNextPage();
  }

  Future<void> _openOnboardingManualPlan() async {
    final profileId = await _ensureWorkoutPlanProfileId();
    if (!mounted || profileId == null) return;

    final repo = context.read<AppRepository>();
    final existingPlans = await repo.fetchAllPresetsRaw(profileId: profileId);
    if (!mounted) return;

    final existingDraft = await repo.fetchDraftPresetForProfile(profileId);
    final presetId =
        (existingDraft?['id'] as num?)?.toInt() ??
        await repo.createPreset(
          existingPlans.isEmpty
              ? _strings.onboardingNewPlan
              : _strings.onboardingNumberedNewPlan(existingPlans.length + 1),
          profileId: profileId,
          isDraft: true,
        );
    _onboardingDraftProfileIds.add(profileId);
    if (!mounted) return;

    final activeSession = context.read<ActiveSession>();
    final result = await Navigator.of(context).push<PresetDetailResult>(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ActiveSession>.value(value: activeSession),
            ChangeNotifierProvider(
              create: (_) => PresetSession(presetId, repository: repo),
            ),
          ],
          child: const PresetDetailScreen(
            startInEditingMode: true,
            showOnboardingManualPlanTutorial: true,
            closeAfterSave: true,
          ),
        ),
      ),
    );
    if (!mounted) return;

    if (result != PresetDetailResult.saved) {
      await repo.deletePreset(presetId);
      _onboardingDraftProfileIds.remove(profileId);
      return;
    }

    _onboardingDraftProfileIds.remove(profileId);
    setState(() {
      if (!_onboardingPlanIds.contains(presetId)) {
        _onboardingPlansAdded++;
        _onboardingPlanIds.add(presetId);
      }
      _planOverviewRefreshToken++;
    });
    _goToNextPage();
  }

  String _workoutPlanSummary() {
    if (_onboardingPlansAdded > 0) {
      return _strings.onboardingPlanSummaryAdded(_onboardingPlansAdded);
    }
    switch (_workoutPlanSetupOption) {
      case _WorkoutPlanSetupOption.premade:
        return _strings.onboardingPlanSummaryPremade;
      case _WorkoutPlanSetupOption.generate:
        return _strings.onboardingPlanSummaryGenerated;
      case _WorkoutPlanSetupOption.skip:
        return _strings.onboardingPlanSummarySkipped;
      case _WorkoutPlanSetupOption.manual:
        return _strings.onboardingPlanSummaryManual;
      case null:
        return _strings.onboardingPlanSummaryNotSelected;
    }
  }

  void _previousAction() {
    if (_advancing || _isFinishing || _pageTransitionInFlight) return;
    if (_currentPage <= 0) return;
    _goToPage(_currentPage - 1);
  }

  Future<void> _goToPage(int page) async {
    if (_pageTransitionInFlight || !_controller.hasClients) return;
    final expressive = context.usesExpressivePresentation;
    final duration = expressive
        ? TonosExpressiveStateMotion.duration(
            context,
            TonosExpressiveStateMotion.standard,
          )
        : tutorialMotion(context, context.tutorialTokens.pageDuration);
    if (duration == Duration.zero) {
      _controller.jumpToPage(page);
      return;
    }
    if (!expressive) {
      await _controller.animateToPage(
        page,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
      return;
    }
    // Keep navigation controls stable until the current slide settles. The
    // page index changes halfway through a slide, before it is safe to advance.
    setState(() => _pageTransitionInFlight = true);
    try {
      await _controller.animateToPage(
        page,
        duration: duration,
        curve: TonosExpressiveStateMotion.spatial,
      );
    } finally {
      if (mounted) setState(() => _pageTransitionInFlight = false);
    }
  }

  Future<void> _skipOrFinish() async {
    if (_advancing || _isFinishing || _pageTransitionInFlight) return;
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    if (_currentPage == lastPageIndex) {
      await _finishOnboarding();
      return;
    }
    final shouldSkip = await _confirmSkipOnboarding();
    if (!mounted || !shouldSkip) return;
    await _skipToHomeAfterConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    return _buildOnboardingScaffold(context);
  }

  Widget _buildOnboardingScaffold(BuildContext context) {
    final strings = _strings;
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final expressiveTokens = AppExpressivePlanningTokens.maybeOf(context);
    final safePage = _currentPage > lastPageIndex
        ? lastPageIndex
        : _currentPage;
    final canAdvance = _canAdvance(pages[safePage]);
    final actionLabel = _isFinishing
        ? strings.onboardingFinishing
        : safePage == lastPageIndex
        ? strings.onboardingFinishSetup
        : strings.onboardingNext;
    final VoidCallback? onAdvance =
        canAdvance && !_isFinishing && !_advancing && !_pageTransitionInFlight
        ? () {
            _nextAction();
          }
        : null;
    final nextButton = SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: expressiveTokens == null
            ? null
            : FilledButton.styleFrom(
                backgroundColor: expressiveTokens.actionPrimary,
                foregroundColor: expressiveTokens.actionPrimaryForeground,
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
        onPressed: onAdvance,
        child: Text(actionLabel),
      ),
    );

    return Scaffold(
      backgroundColor: expressiveTokens?.pageCanvas ?? scheme.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: expressiveTokens == null
          ? null
          : TonosExpressiveActionVisibility(
              visible: safePage == lastPageIndex,
              child: FloatingActionButton.extended(
                heroTag: 'onboardingAdvance',
                tooltip: actionLabel,
                onPressed: onAdvance,
                backgroundColor: canAdvance
                    ? expressiveTokens.actionPrimary
                    : Color.alphaBlend(
                        scheme.onSurface.withValues(alpha: 0.12),
                        expressiveTokens.pageCanvas,
                      ),
                foregroundColor: canAdvance
                    ? expressiveTokens.actionPrimaryForeground
                    : scheme.onSurface.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: expressiveTokens.rowShape,
                ),
                elevation: 3,
                disabledElevation: 0,
                icon: TonosExpressiveContentTransition(
                  value: _isFinishing,
                  direction: 0,
                  child: _isFinishing
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: expressiveTokens.actionPrimaryForeground,
                          ),
                        )
                      : const Icon(Icons.check),
                ),
                label: Text(actionLabel),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: _OnboardingHeader(
                currentPage: safePage,
                pageCount: pages.length,
                title: pages[safePage].label,
                onBack:
                    safePage == 0 ||
                        _advancing ||
                        _isFinishing ||
                        _pageTransitionInFlight
                    ? null
                    : _previousAction,
                onSkip:
                    _advancing ||
                        _isFinishing ||
                        _pageTransitionInFlight ||
                        (expressiveTokens != null && safePage == lastPageIndex)
                    ? null
                    : () {
                        _skipOrFinish();
                      },
                skipLabel: safePage == lastPageIndex
                    ? strings.onboardingFinish
                    : strings.onboardingSkip,
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    ignoring:
                        _advancing || _isFinishing || _pageTransitionInFlight,
                    child: PageView.builder(
                      controller: _controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() {
                        _currentPage = index;
                      }),
                      itemCount: pages.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            8,
                            18,
                            expressiveTokens != null && index != lastPageIndex
                                ? 4
                                : 12,
                          ),
                          child: pages[index].builder(),
                        );
                      },
                    ),
                  ),
                  if (expressiveTokens != null && safePage != lastPageIndex)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: expressiveTokens.pageCanvas,
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                          side: BorderSide(
                            color: expressiveTokens.outline.withValues(
                              alpha: 0.8,
                            ),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                          child: nextButton,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (expressiveTokens == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                  children: [
                    _PageDots(count: pages.length, activeIndex: safePage),
                    const SizedBox(height: 14),
                    nextButton,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    final strings = _strings;
    final language = context.watch<LocalePreferenceProvider>().preference;
    final theme = Theme.of(context);
    final neo = context.usesNeoPresentation;
    final expressive = context.usesExpressivePresentation;
    final surfaces = context.surfaceTokens;
    final cardForeground = neo
        ? tonosForegroundForSurface(context, surfaces.settingsSection)
        : theme.colorScheme.onSurface;
    final cardSecondary = neo
        ? tonosSecondaryForegroundForSurface(context, surfaces.settingsSection)
        : theme.colorScheme.onSurfaceVariant;
    return _OnboardingCard(
      icon: Icons.favorite,
      title: strings.onboardingWelcomeTitle,
      subtitle: strings.onboardingWelcomeSubtitle,
      children: [
        Text(
          strings.onboardingLanguageSelectionTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            color: neo ? cardForeground : null,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<AppLanguagePreference>(
          initialValue: language,
          isExpanded: true,
          decoration: expressive
              ? _onboardingInputDecoration(
                  context,
                  label: null,
                  icon: Icons.language_outlined,
                )
              : InputDecoration(
                  prefixIcon: const Icon(Icons.language_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
          items: AppLanguagePreference.values
              .map(
                (preference) => DropdownMenuItem(
                  value: preference,
                  child: Text(
                    _languagePreferenceLabel(preference),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (preference) {
            if (preference == null) return;
            _changeLanguage(preference);
          },
        ),
        const SizedBox(height: 8),
        Text(
          strings.onboardingLanguageSelectionHelp,
          style: theme.textTheme.bodySmall?.copyWith(color: cardSecondary),
        ),
        const SizedBox(height: 20),
        _FeatureRow(
          icon: Icons.fitness_center,
          title: strings.onboardingTrainFeatureTitle,
          body: strings.onboardingTrainFeatureBody,
        ),
        _FeatureRow(
          icon: Icons.restaurant_menu,
          title: strings.onboardingNutritionFeatureTitle,
          body: strings.onboardingNutritionFeatureBody,
        ),
        _FeatureRow(
          icon: Icons.insights,
          title: strings.onboardingProgressFeatureTitle,
          body: strings.onboardingProgressFeatureBody,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage() {
    final strings = _strings;
    const genderValues = ['Male', 'Female', 'Other', 'Prefer not to say'];
    return _OnboardingCard(
      icon: Icons.badge_outlined,
      title: strings.onboardingBasicsTitle,
      subtitle: strings.onboardingBasicsSubtitle,
      children: [
        _TextInput(
          controller: _nameController,
          label: strings.onboardingNameLabel,
          hint: strings.onboardingNameHint,
          icon: Icons.person_outline,
        ),
        _FieldGap.small,
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _gender,
          decoration: _onboardingInputDecoration(
            context,
            label: strings.onboardingGenderLabel,
            icon: Icons.wc_outlined,
          ),
          items: genderValues.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(_genderLabel(gender)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _gender = value),
        ),
        _FieldGap.small,
        _ActionField(
          icon: Icons.calendar_today,
          label: strings.onboardingDateOfBirthLabel,
          value: _dob == null
              ? strings.onboardingSelectDate
              : _formatDate(_dob!),
          onTap: _pickDob,
        ),
        _FieldGap.small,
        _TextInput(
          controller: _heightController,
          label: strings.onboardingHeightLabel,
          hint: strings.onboardingHeightHint,
          icon: Icons.height,
        ),
        _FieldGap.small,
        _ChoiceGroup<WeightUnit>(
          title: strings.onboardingWorkoutWeightUnits,
          options: WeightUnit.values,
          value: _selectedWeightUnit,
          labelBuilder: (unit) => unit.shortLabel,
          onChanged: (unit) {
            if (unit == null) return;
            _changeWeightUnit(unit);
          },
        ),
        _FieldGap.small,
        _TextInput(
          key: const Key('onboarding-current-weight'),
          controller: _weightController,
          label: strings.onboardingCurrentWeightLabel,
          hint: _selectedWeightUnit == WeightUnit.pounds
              ? strings.onboardingWeightHintPounds
              : strings.onboardingWeightHintKilograms,
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
          suffixText: _selectedWeightUnit.shortLabel,
          onChanged: (_) {
            _weightInputCanonicalLbs = null;
            _unitPreferenceLoaded = true;
          },
        ),
      ],
    );
  }

  Future<void> _changeLanguage(AppLanguagePreference preference) async {
    try {
      await context.read<LocalePreferenceProvider>().setPreference(preference);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.safeFailureSaveTitle),
          action: SnackBarAction(
            label: _strings.commonRetry,
            onPressed: () => _changeLanguage(preference),
          ),
        ),
      );
    }
  }

  void _changeWeightUnit(WeightUnit unit) {
    _unitPreferenceLoaded = true;
    if (unit == _selectedWeightUnit) return;
    final enteredWeight = double.tryParse(_weightController.text.trim());
    if (enteredWeight != null && enteredWeight > 0) {
      _weightInputCanonicalLbs ??= WeightUnitFormatter.toPounds(
        enteredWeight,
        _selectedWeightUnit,
      );
      _weightController.text = WeightUnitFormatter.formatInputWeight(
        _weightInputCanonicalLbs!,
        unit,
      );
    }
    setState(() => _selectedWeightUnit = unit);
  }

  Widget _buildUsageIntentPage() {
    final strings = _strings;
    final expressive = context.usesExpressivePresentation;
    return _OnboardingCard(
      icon: Icons.tune,
      title: strings.onboardingFocusTitle,
      subtitle: strings.onboardingFocusSubtitle,
      children: [
        _IntentTile(
          icon: Icons.restaurant_menu,
          title: expressive
              ? strings.onboardingIncludedNutrition
              : strings.onboardingNutritionDataTitle,
          body: _nutritionOnboardingEnabled
              ? strings.onboardingNutritionFeatureBody
              : expressive
              ? strings.onboardingNutritionSetupLaterBody
              : strings.onboardingNutritionDataPausedBody,
          value: _nutritionOnboardingEnabled && _useNutritionData,
          enabled: _nutritionOnboardingEnabled,
          statusLabel: strings.onboardingLater,
          onChanged: (value) => setState(() => _useNutritionData = value),
        ),
        const SizedBox(height: 12),
        _IntentTile(
          icon: Icons.fitness_center,
          title: expressive
              ? strings.onboardingWorkoutSetupTitle
              : strings.onboardingExerciseDataTitle,
          body: strings.onboardingExerciseDataBody,
          value: _useExerciseData,
          onChanged: (value) => setState(() => _useExerciseData = value),
        ),
      ],
    );
  }

  Widget _buildWeightHistoryPage() {
    final strings = _strings;
    return _OnboardingCard(
      icon: Icons.monitor_weight_outlined,
      title: strings.onboardingWeightHistoryTitle,
      subtitle: strings.onboardingWeightHistorySubtitle,
      children: [
        _SwitchCard(
          title: strings.onboardingPreviouslyHeavier,
          value: _weighedHeavy,
          onChanged: (value) => setState(() => _weighedHeavy = value),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: strings.onboardingWeightTrendTitle,
          options: const [
            'Gaining weight',
            'Losing weight',
            'Maintaining weight',
            'Not sure',
          ],
          value: _weightTrend,
          labelBuilder: (value) => switch (value) {
            'Gaining weight' => strings.onboardingWeightTrendGaining,
            'Losing weight' => strings.onboardingWeightTrendLosing,
            'Maintaining weight' => strings.onboardingWeightTrendMaintaining,
            _ => strings.onboardingNotSure,
          },
          onChanged: (value) => setState(() => _weightTrend = value),
        ),
      ],
    );
  }

  Widget _buildBodyFatPage() {
    final strings = _strings;
    final isFemale = _gender == 'Female';
    final options = isFemale
        ? const [
            '5-10%',
            '10-15%',
            '15-20%',
            '20-25%',
            '25-30%',
            '30-35%',
            '35-40%',
            '40-45%',
          ]
        : const [
            '0-5%',
            '5-10%',
            '10-15%',
            '15-20%',
            '20-25%',
            '25-30%',
            '30-35%',
            '35-40%',
          ];
    final paths = isFemale
        ? const [
            'assets/bodyfat_woman/5-10_woman.png',
            'assets/bodyfat_woman/10-15_woman.png',
            'assets/bodyfat_woman/15-20_woman.png',
            'assets/bodyfat_woman/20-25_woman.png',
            'assets/bodyfat_woman/25-30_woman.png',
            'assets/bodyfat_woman/30-35_woman.png',
            'assets/bodyfat_woman/35-40_woman.png',
            'assets/bodyfat_woman/40-45_woman.png',
          ]
        : const [
            'assets/bodyfat/0-5_bf.png',
            'assets/bodyfat/5-10_bf.png',
            'assets/bodyfat/10-15_bf.png',
            'assets/bodyfat/15-20_bf.png',
            'assets/bodyfat/20-25_bf.png',
            'assets/bodyfat/25-30_bf.png',
            'assets/bodyfat/30-35_bf.png',
            'assets/bodyfat/35-40_bf.png',
          ];

    return _OnboardingCard(
      icon: Icons.image_search,
      title: strings.onboardingBodyFatEstimateTitle,
      subtitle: strings.onboardingBodyFatEstimateSubtitle,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final label = options[index];
            final isSelected = _bodyFatEstimate == label;
            return _BodyFatTile(
              label: label,
              assetPath: paths[index],
              isSelected: isSelected,
              onTap: () => setState(() => _bodyFatEstimate = label),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutritionAndTrainingPage() {
    final strings = _strings;
    return _OnboardingCard(
      icon: Icons.restaurant,
      title: strings.onboardingNutritionPreferencesTitle,
      subtitle: strings.onboardingNutritionPreferencesSubtitle,
      children: [
        if (widget.reviewMode) ...[
          _OnboardingInfoCallout(
            icon: Icons.info_outline,
            text: strings.onboardingNutritionReviewNotice,
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _preferredDiet,
          decoration: _onboardingInputDecoration(
            context,
            label: strings.onboardingPreferredDiet,
            icon: Icons.restaurant_menu,
          ),
          items: const ['Balanced', 'Low fat', 'Low carb', 'Keto'].map((diet) {
            final label = switch (diet) {
              'Balanced' => strings.onboardingDietBalanced,
              'Low fat' => strings.onboardingDietLowFat,
              'Low carb' => strings.onboardingDietLowCarb,
              _ => strings.onboardingDietKeto,
            };
            return DropdownMenuItem(value: diet, child: Text(label));
          }).toList(),
          onChanged: (value) => setState(() => _preferredDiet = value!),
        ),
        _FieldGap.small,
        _TextInput(
          controller: _calorieFloorController,
          label: strings.onboardingCalorieFloor,
          hint: strings.onboardingCalorieFloorHint,
          icon: Icons.local_fire_department_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: strings.onboardingTrainingDuringProgram,
          options: const ['None', 'Lifting', 'Cardio', 'Lifting and cardio'],
          value: _trainingType,
          labelBuilder: (value) => switch (value) {
            'None' => strings.onboardingTrainingNone,
            'Lifting' => strings.onboardingTrainingLifting,
            'Cardio' => strings.onboardingTrainingCardio,
            _ => strings.onboardingTrainingLiftingAndCardio,
          },
          onChanged: (value) => setState(() => _trainingType = value!),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: strings.onboardingProteinPreference,
          options: const ['Low', 'Moderate', 'High', 'Very high'],
          value: _proteinPreference,
          labelBuilder: (value) => switch (value) {
            'Low' => strings.onboardingProteinLow,
            'Moderate' => strings.onboardingProteinModerate,
            'High' => strings.onboardingProteinHigh,
            _ => strings.onboardingProteinVeryHigh,
          },
          onChanged: (value) => setState(() => _proteinPreference = value!),
        ),
      ],
    );
  }

  Widget _buildNutritionGoalPage() {
    final strings = _strings;
    final locale = Localizations.localeOf(context);
    final goalWeight = LocalizedFormatters.number(
      _goalWeightValue.round(),
      locale,
      maximumFractionDigits: 0,
    );
    final weeklyRatePct = LocalizedFormatters.number(
      _weeklyRatePct,
      locale,
      minimumFractionDigits: 1,
      maximumFractionDigits: 1,
    );
    final weeklyRateLbs = LocalizedFormatters.number(
      _weeklyRateLbs,
      locale,
      minimumFractionDigits: 1,
      maximumFractionDigits: 1,
    );
    final monthlyRatePct = LocalizedFormatters.number(
      _monthlyRatePct,
      locale,
      minimumFractionDigits: 1,
      maximumFractionDigits: 1,
    );
    final monthlyRateLbs = LocalizedFormatters.number(
      _monthlyRateLbs,
      locale,
      minimumFractionDigits: 1,
      maximumFractionDigits: 1,
    );
    return _OnboardingCard(
      icon: Icons.flag_outlined,
      title: strings.onboardingGoalPaceTitle,
      subtitle: strings.onboardingGoalPaceSubtitle,
      children: [
        if (widget.reviewMode) ...[
          _OnboardingInfoCallout(
            icon: Icons.info_outline,
            text: strings.onboardingNutritionReviewNotice,
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: _MetricPreviewCard(
                icon: Icons.local_fire_department_outlined,
                value: '2025 kcal',
                label: widget.reviewMode
                    ? strings.onboardingExampleDailyBudget
                    : strings.onboardingInitialDailyBudget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricPreviewCard(
                icon: Icons.event,
                value: _shortDate(_projectedEndDate),
                label: widget.reviewMode
                    ? strings.onboardingExampleEndDate
                    : strings.onboardingProjectedEndDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SliderPanel(
          title: strings.onboardingTargetWeight,
          valueLabel: '$goalWeight lbs',
          child: Slider(
            value: _goalWeightValue,
            min: 100,
            max: 250,
            divisions: 150,
            label: goalWeight,
            onChanged: (value) => setState(() => _goalWeightValue = value),
          ),
        ),
        const SizedBox(height: 16),
        _SliderPanel(
          title: strings.onboardingTargetGoalRate,
          valueLabel: strings.onboardingBodyWeightPerWeek(weeklyRatePct),
          child: Slider(
            value: _weeklyRatePct,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: strings.onboardingBodyWeightPerWeek(weeklyRatePct),
            onChanged: (value) => setState(() => _weeklyRatePct = value),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: strings.onboardingPerWeek,
                value: '-$weeklyRateLbs lbs / $weeklyRatePct%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: strings.onboardingPerMonth,
                value: '-$monthlyRateLbs lbs / $monthlyRatePct%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGymSpacePage() {
    final strings = _strings;
    return _OnboardingCard(
      icon: Icons.location_on_outlined,
      title: strings.onboardingGymSpaceTitle,
      subtitle: strings.onboardingGymSpaceSubtitle,
      actionHint:
          context.usesExpressivePresentation && _selectedGymSpace == null
          ? strings.onboardingChooseOptionHint
          : null,
      children: [
        if (_isGymEquipmentLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_gymEquipmentLoadFailed) ...[
          _GymEquipmentLoadError(onRetry: _loadGymEquipment),
          const SizedBox(height: 12),
          _GymSpaceTile(
            template: _skipGymSpaceTemplate,
            title: _gymSpaceTitle(_skipGymSpaceTemplate),
            subtitle: _gymSpaceSubtitle(_skipGymSpaceTemplate),
            selected: _selectedGymSpace?.skipSetup ?? false,
            onTap: () => _selectGymSpace(_skipGymSpaceTemplate),
          ),
        ] else
          ..._gymSpaceTemplates.map((template) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GymSpaceTile(
                template: template,
                title: _gymSpaceTitle(template),
                subtitle: _gymSpaceSubtitle(template),
                selected: _selectedGymSpace?.id == template.id,
                onTap: () => _selectGymSpace(template),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGymEquipmentPage() {
    final strings = _strings;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final template = _selectedGymSpace;
    if (template == null || template.skipSetup) {
      return const SizedBox.shrink();
    }

    final selectedEquipment =
        _availableGymEquipment
            .where((item) => _selectedGymEquipmentNames.contains(item.name))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return _OnboardingCard(
      icon: Icons.fitness_center,
      title: strings.onboardingReviewWorkoutSpaceTitle,
      subtitle: strings.onboardingReviewWorkoutSpaceSubtitle,
      children: [
        TextField(
          controller: _gymProfileNameController,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          decoration: _onboardingInputDecoration(
            context,
            label: strings.onboardingProfileNameLabel,
            icon: Icons.edit_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _OnboardingEquipmentSummary(
          heading: strings.onboardingIncludedEquipmentTitle,
          count: LocalizedFormatters.number(
            selectedEquipment.length,
            Localizations.localeOf(context),
            maximumFractionDigits: 0,
          ),
          description: strings.onboardingIncludedEquipmentBody,
          action: expressive == null
              ? null
              : IconButton.filledTonal(
                  tooltip: strings.onboardingEditEquipment,
                  onPressed: _openGymProfileEditor,
                  style: IconButton.styleFrom(
                    backgroundColor: expressive.actionSecondary,
                    foregroundColor: expressive.actionSecondaryForeground,
                  ),
                  icon: const Icon(Icons.tune),
                ),
          content: selectedEquipment.isEmpty
              ? [
                  Text(
                    strings.onboardingNoEquipmentSelected,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ]
              : [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedEquipment
                        .take(
                          expressive == null || _showAllEquipment
                              ? selectedEquipment.length
                              : 6,
                        )
                        .map((equipment) {
                          return Chip(
                            avatar: Icon(
                              _onboardingEquipmentIcon(equipment.name),
                              size: 17,
                              color: expressive?.actionSecondaryForeground,
                            ),
                            label: LocalizedCatalogEntityName(
                              entity: CatalogEntityDisplayName(
                                catalogId: equipment.catalogId,
                                canonicalName: equipment.name,
                              ),
                            ),
                            labelStyle: expressive == null
                                ? null
                                : TextStyle(
                                    color: expressive.actionSecondaryForeground,
                                  ),
                            backgroundColor: expressive?.actionSecondary,
                            side: expressive == null
                                ? null
                                : BorderSide(
                                    color: expressive.outline.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                            shape: expressive == null
                                ? null
                                : RoundedRectangleBorder(
                                    borderRadius: expressive.rowShape,
                                  ),
                            visualDensity: VisualDensity.compact,
                          );
                        })
                        .toList(),
                  ),
                  if (expressive != null && selectedEquipment.length > 6)
                    TextButton.icon(
                      key: const Key('onboarding-equipment-toggle'),
                      onPressed: () => setState(
                        () => _showAllEquipment = !_showAllEquipment,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: expressive.equipmentForeground,
                      ),
                      icon: Icon(
                        _showAllEquipment
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      label: Text(
                        _showAllEquipment
                            ? strings.onboardingShowLessEquipment
                            : strings.onboardingShowAllEquipment(
                                selectedEquipment.length,
                              ),
                      ),
                    ),
                ],
        ),
        const SizedBox(height: 14),
        if (expressive != null)
          TextButton.icon(
            onPressed: _resetGymEquipment,
            icon: const Icon(Icons.restart_alt),
            label: Text(strings.onboardingReset),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetGymEquipment,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(strings.onboardingReset),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _openGymProfileEditor,
                  icon: const Icon(Icons.tune),
                  label: Text(strings.onboardingEditProfile),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _openGymProfileEditor() async {
    final draft = await Navigator.of(context).push<GymProfileDraft>(
      MaterialPageRoute(
        builder: (_) => GymProfileScreen(
          initialName: _gymProfileNameController.text.trim(),
          initialEquipmentNames: _selectedGymEquipmentNames,
          returnDraftOnly: true,
          title: _strings.onboardingEditWorkoutSpaceTitle,
        ),
      ),
    );
    if (draft == null || !mounted) return;
    setState(() {
      _gymProfileNameController.text = draft.name;
      _selectedGymEquipmentNames = Set<String>.from(draft.equipmentNames);
    });
  }

  Widget _buildWorkoutPlanPage() {
    final strings = _strings;
    return _OnboardingCard(
      icon: Icons.assignment_outlined,
      title: strings.onboardingWorkoutPlanTitle,
      subtitle: strings.onboardingWorkoutPlanSubtitle,
      actionHint:
          context.usesExpressivePresentation && _workoutPlanSetupOption == null
          ? strings.onboardingChooseOptionHint
          : null,
      children: [
        _WorkoutPlanSetupTile(
          title: strings.onboardingManualPlanTitle,
          subtitle: strings.onboardingManualPlanSubtitle,
          icon: Icons.edit_note,
          selected: _workoutPlanSetupOption == _WorkoutPlanSetupOption.manual,
          onTap: () {
            setState(() {
              _workoutPlanSetupOption = _WorkoutPlanSetupOption.manual;
            });
          },
        ),
        const SizedBox(height: 12),
        _WorkoutPlanSetupTile(
          title: strings.onboardingPremadePlanTitle,
          subtitle: strings.onboardingPremadePlanSubtitle,
          icon: Icons.library_books_outlined,
          selected: _workoutPlanSetupOption == _WorkoutPlanSetupOption.premade,
          onTap: () {
            setState(() {
              _workoutPlanSetupOption = _WorkoutPlanSetupOption.premade;
            });
          },
        ),
        const SizedBox(height: 12),
        _WorkoutPlanSetupTile(
          title: strings.onboardingGeneratePlanTitle,
          subtitle: strings.onboardingGeneratePlanSubtitle,
          icon: Icons.auto_awesome,
          selected: _workoutPlanSetupOption == _WorkoutPlanSetupOption.generate,
          onTap: () {
            setState(() {
              _workoutPlanSetupOption = _WorkoutPlanSetupOption.generate;
            });
          },
        ),
        const SizedBox(height: 12),
        _WorkoutPlanSetupTile(
          title: strings.onboardingSkipPlanTitle,
          subtitle: strings.onboardingSkipPlanSubtitle,
          icon: Icons.fast_forward,
          selected: _workoutPlanSetupOption == _WorkoutPlanSetupOption.skip,
          onTap: () {
            setState(() {
              _workoutPlanSetupOption = _WorkoutPlanSetupOption.skip;
            });
          },
        ),
        if (_onboardingPlansAdded > 0) ...[
          const SizedBox(height: 14),
          _OnboardingInfoCallout(
            icon: Icons.check_circle_outline,
            text: strings.onboardingPlansAdded(_onboardingPlansAdded),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkoutPlanOverviewPage() {
    final strings = _strings;
    final planCount = _onboardingPlanIds.length;
    return _OnboardingCard(
      icon: Icons.fact_check_outlined,
      title: strings.onboardingReviewPlansTitle,
      subtitle: strings.onboardingReviewPlansSubtitle,
      children: [
        _OnboardingPlanOverviewList(
          repository: context.read<AppRepository>(),
          profileId: _onboardingProfileId,
          planIds: Set<int>.from(_onboardingPlanIds),
          refreshToken: _planOverviewRefreshToken,
          onChanged: () {
            if (!mounted) return;
            setState(() => _planOverviewRefreshToken++);
          },
        ),
        const SizedBox(height: 14),
        _OnboardingInfoCallout(
          icon: Icons.check_circle_outline,
          text: strings.onboardingPlansReady(planCount),
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    final strings = _strings;
    final expressive = context.usesExpressivePresentation;
    final personalDetails = <(String, String)>[
      (strings.onboardingSummaryName, _nameController.text.trim()),
      (
        strings.onboardingSummaryGender,
        _gender == null ? '' : _genderLabel(_gender!),
      ),
      (
        strings.onboardingSummaryDateOfBirth,
        _dob == null ? '' : _formatDate(_dob!),
      ),
      (strings.onboardingSummaryHeight, _heightController.text.trim()),
      (strings.onboardingSummaryWeight, _weightController.text.trim()),
    ];
    final visibleDetails = personalDetails
        .where((detail) => !expressive || detail.$2.isNotEmpty)
        .toList();
    final usesNutrition = _nutritionOnboardingEnabled && _useNutritionData;
    final included = [
      if (usesNutrition) strings.onboardingIncludedNutrition,
      if (_useExerciseData)
        expressive
            ? strings.onboardingWorkoutSetupTitle
            : strings.onboardingIncludedExercise,
      if (!usesNutrition && !_useExerciseData)
        strings.onboardingIncludedBasicOnly,
    ];

    return _OnboardingCard(
      icon: Icons.check_circle,
      title: strings.onboardingReadyTitle,
      subtitle: strings.onboardingReadySubtitle,
      children: [
        _OnboardingSummaryCallout(
          label: strings.onboardingSummaryIncluded,
          value: included.join(', '),
        ),
        const SizedBox(height: 14),
        if (expressive && visibleDetails.isEmpty)
          _OnboardingInfoCallout(
            icon: Icons.person_outline,
            text: strings.onboardingPersonalDetailsSkipped,
          )
        else
          _OnboardingSummarySection(
            icon: Icons.person_outline,
            title: strings.onboardingSummaryProfileSection,
            children: [
              for (final (label, value) in visibleDetails)
                _SummaryRow(label: label, value: value),
            ],
          ),
        if (_useExerciseData) ...[
          const SizedBox(height: 12),
          _OnboardingSummarySection(
            icon: Icons.fitness_center_outlined,
            title: strings.onboardingSummaryTrainingSection,
            prominent: true,
            children: [
              if (!expressive)
                _SummaryRow(
                  label: strings.onboardingSummaryWorkoutUnits,
                  value: _weightUnitLabel(_selectedWeightUnit),
                ),
              _SummaryRow(
                label: strings.onboardingSummaryGymProfile,
                value: _selectedGymSpace?.skipSetup ?? true
                    ? strings.onboardingGymGeneralName
                    : _gymProfileNameController.text.trim(),
              ),
              if (!(_selectedGymSpace?.skipSetup ?? true))
                _SummaryRow(
                  label: strings.onboardingSummaryEquipment,
                  value: strings.onboardingEquipmentSelected(
                    _selectedGymEquipmentNames.length,
                  ),
                ),
              _SummaryRow(
                label: strings.onboardingSummaryWorkoutPlans,
                value: _workoutPlanSummary(),
              ),
              if (expressive)
                _SummaryRow(
                  label: strings.onboardingSummaryWorkoutUnits,
                  value: _weightUnitLabel(_selectedWeightUnit),
                ),
            ],
          ),
        ],
        if (usesNutrition) ...[
          const SizedBox(height: 12),
          _OnboardingSummarySection(
            icon: Icons.restaurant_menu_outlined,
            title: strings.onboardingSummaryNutritionSection,
            children: [
              _SummaryRow(
                label: strings.userInfoWeightTrend,
                value: _weightTrend ?? '',
              ),
              _SummaryRow(
                label: strings.userInfoBodyFat,
                value: _bodyFatEstimate ?? '',
              ),
              _SummaryRow(
                label: strings.onboardingSummaryDiet,
                value: _preferredDiet,
              ),
              _SummaryRow(
                label: strings.onboardingSummaryProteinPreference,
                value: _proteinPreference,
              ),
            ],
          ),
          if (widget.reviewMode) ...[
            const SizedBox(height: 12),
            _OnboardingInfoCallout(
              icon: Icons.info_outline,
              text: strings.onboardingNutritionReviewNotice,
            ),
          ],
        ],
      ],
    );
  }

  String _languagePreferenceLabel(AppLanguagePreference preference) {
    final strings = _strings;
    return switch (preference) {
      AppLanguagePreference.system => strings.systemDefaultLanguage,
      AppLanguagePreference.english => strings.englishLanguage,
      AppLanguagePreference.canadianFrench => strings.canadianFrenchLanguage,
      AppLanguagePreference.bengaliBangladesh =>
        strings.bengaliBangladeshLanguage,
      AppLanguagePreference.simplifiedChinese =>
        strings.simplifiedChineseLanguage,
      AppLanguagePreference.hindi => strings.hindiLanguage,
      AppLanguagePreference.spanish => strings.spanishLanguage,
    };
  }

  String _genderLabel(String gender) {
    final strings = _strings;
    return switch (gender) {
      'Male' => strings.onboardingGenderMale,
      'Female' => strings.onboardingGenderFemale,
      'Other' => strings.onboardingGenderOther,
      'Prefer not to say' => strings.onboardingGenderPreferNotToSay,
      _ => gender,
    };
  }

  String _weightUnitLabel(WeightUnit unit) {
    return switch (unit) {
      WeightUnit.pounds => _strings.onboardingPounds,
      WeightUnit.kilograms => _strings.onboardingKilograms,
    };
  }

  String _gymSpaceTitle(_GymSpaceTemplate template) {
    final strings = _strings;
    return switch (template.id) {
      'custom' => strings.onboardingGymCustomTitle,
      'skip' => strings.onboardingGymSkipTitle,
      'commercial' => strings.onboardingGymCommercialTitle,
      'home_gym' => strings.onboardingGymHomeTitle,
      'calisthenics' => strings.onboardingGymCalisthenicsTitle,
      'powerlifting' => strings.onboardingGymPowerliftingTitle,
      'free_weights' => strings.onboardingGymFreeWeightsTitle,
      _ => template.id,
    };
  }

  String _gymSpaceSubtitle(_GymSpaceTemplate template) {
    final strings = _strings;
    return switch (template.id) {
      'custom' => strings.onboardingGymCustomSubtitle,
      'skip' => strings.onboardingGymSkipSubtitle,
      'commercial' => strings.onboardingGymCommercialSubtitle,
      'home_gym' => strings.onboardingGymHomeSubtitle,
      'calisthenics' => strings.onboardingGymCalisthenicsSubtitle,
      'powerlifting' => strings.onboardingGymPowerliftingSubtitle,
      'free_weights' => strings.onboardingGymFreeWeightsSubtitle,
      _ => template.id,
    };
  }

  String _gymSpaceDefaultProfileName(_GymSpaceTemplate template) {
    final strings = _strings;
    return switch (template.id) {
      'custom' => strings.onboardingGymCustomDefaultName,
      'skip' => strings.onboardingGymGeneralName,
      'commercial' => strings.onboardingGymCommercialDefaultName,
      'home_gym' => strings.onboardingGymHomeDefaultName,
      'calisthenics' => strings.onboardingGymCalisthenicsDefaultName,
      'powerlifting' => strings.onboardingGymPowerliftingDefaultName,
      'free_weights' => strings.onboardingGymFreeWeightsDefaultName,
      _ => template.id,
    };
  }

  String _formatDate(DateTime date) {
    return preserveWesternDigits(
      MaterialLocalizations.of(context).formatMediumDate(date),
      Localizations.localeOf(context),
    );
  }

  String _shortDate(DateTime date) {
    return preserveWesternDigits(
      MaterialLocalizations.of(context).formatMediumDate(date),
      Localizations.localeOf(context),
    );
  }
}
