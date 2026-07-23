// File: lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/active_session.dart';
import '../providers/onboarding_provider.dart';
import '../providers/preset_session.dart';
import '../providers/selected_profile.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../services/active_plan_store.dart';
import '../widgets/body_heatmap.dart';
import '../widgets/preset_bar.dart';
import 'exercise/gym_profile_screen.dart';
import 'exercise/premade_plans_page.dart';
import 'exercise/preset_detail_screen.dart';
import 'exercise/preset_generation_qa.dart';

/// Initial setup flow for basic user details plus optional workout and
/// nutrition personalization.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
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
  _GymSpaceTemplate? _selectedGymSpace;
  _WorkoutPlanSetupOption? _workoutPlanSetupOption;
  List<Equipment> _availableGymEquipment = const [];
  Set<String> _selectedGymEquipmentNames = {};
  int? _onboardingProfileId;
  int _onboardingPlansAdded = 0;
  int _planOverviewRefreshToken = 0;
  final List<int> _onboardingPlanIds = [];

  double _goalWeightValue = 140;
  final DateTime _projectedEndDate = DateTime.now().add(
    const Duration(days: 30),
  );
  double _weeklyRateLbs = 0.7;
  double _weeklyRatePct = 0.5;
  double _monthlyRateLbs = 2.8;
  double _monthlyRatePct = 2.0;

  bool get _nutritionOnboardingEnabled => false;

  bool get _showWorkoutPlanOverview =>
      _useExerciseData &&
      _workoutPlanSetupOption != _WorkoutPlanSetupOption.skip &&
      _onboardingPlanIds.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_unitPreferenceLoaded) {
      _unitPreferenceLoaded = true;
      _selectedWeightUnit = context.read<UnitPreferenceProvider>().weightUnit;
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
    return [
      _OnboardingPage('Welcome', _buildWelcomePage),
      _OnboardingPage('Basics', _buildPersonalInfoPage),
      _OnboardingPage('Focus', _buildUsageIntentPage),
      if (_nutritionOnboardingEnabled && _useNutritionData) ...[
        _OnboardingPage('Weight', _buildWeightHistoryPage),
        _OnboardingPage('Body Fat', _buildBodyFatPage),
        _OnboardingPage('Nutrition', _buildNutritionAndTrainingPage),
        _OnboardingPage('Goal', _buildNutritionGoalPage),
      ],
      if (_useExerciseData) ...[
        _OnboardingPage('Gym Profile', _buildGymSpacePage),
        if (_selectedGymSpace != null && !_selectedGymSpace!.skipSetup)
          _OnboardingPage('Equipment', _buildGymEquipmentPage),
        _OnboardingPage('Workout Plan', _buildWorkoutPlanPage),
        if (_showWorkoutPlanOverview)
          _OnboardingPage('Plan Overview', _buildWorkoutPlanOverviewPage),
      ],
      _OnboardingPage('Summary', _buildSummaryPage),
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
      final info = PersonalInfo(
        name: _clean(_nameController.text),
        gender: _gender,
        dob: _dob,
        height: _clean(_heightController.text),
        weight: _clean(_weightController.text),
        bodyFatEstimate: _bodyFatEstimate,
        weightTrend: _weightTrend,
        activityLevel: null,
      );

      if (_hasAnyInput()) {
        await repo.savePersonalInfo(info);
      }

      await unitPrefs.setWeightUnit(_selectedWeightUnit);
      await _createOrUpdateSelectedGymProfile(repo);
      await onboardingConfig.markCompleted();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Could not finish setup: $error')),
      );
    }
  }

  Future<int?> _createOrUpdateSelectedGymProfile(AppRepository repo) async {
    final template = _selectedGymSpace;
    if (!_useExerciseData || template == null || template.skipSetup) {
      return null;
    }

    final selectedEquipment =
        _availableGymEquipment
            .where((item) => _selectedGymEquipmentNames.contains(item.name))
            .toList();
    if (selectedEquipment.isEmpty) {
      throw StateError('Select at least one equipment option.');
    }

    final existingProfiles = await repo.fetchAllProfiles();
    final requestedName =
        _gymProfileNameController.text.trim().isEmpty
            ? template.defaultProfileName
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
    final existingNames =
        existingProfiles
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
    final availableNames =
        _availableGymEquipment.map((equipment) => equipment.name).toSet();
    final equipmentNames =
        template.includeAllEquipment
            ? availableNames
            : template.equipmentNames.intersection(availableNames);

    setState(() {
      _selectedGymSpace = template;
      _gymProfileNameController.text = template.defaultProfileName;
      _selectedGymEquipmentNames = Set<String>.from(equipmentNames);
    });
  }

  void _goToGymEquipmentPage() {
    final equipmentPageIndex = _pages.indexWhere(
      (page) => page.label == 'Equipment',
    );
    if (equipmentPageIndex == -1 || equipmentPageIndex == _currentPage) {
      return;
    }

    _controller.animateToPage(
      equipmentPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
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
    if (page.label == 'Gym Profile') {
      return _selectedGymSpace != null;
    }
    if (page.label == 'Equipment') {
      return _gymProfileNameController.text.trim().isNotEmpty &&
          _selectedGymEquipmentNames.isNotEmpty;
    }
    if (page.label == 'Workout Plan') {
      return _workoutPlanSetupOption != null;
    }
    return true;
  }

  bool get _hasSelectedOnboardingFocus =>
      (_nutritionOnboardingEnabled && _useNutritionData) || _useExerciseData;

  Future<bool> _confirmSkipOnboarding() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Skip setup?'),
          content: const Text(
            'You can skip to the app homepage now and finish setup later. '
            'You can also reopen onboarding from the settings page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('OK'),
            ),
          ],
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
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    final currentIndex =
        _currentPage >= pages.length ? lastPageIndex : _currentPage;
    final currentPage = pages[currentIndex];

    if (currentPage.label == 'Focus' && !_hasSelectedOnboardingFocus) {
      final shouldSkip = await _confirmSkipOnboarding();
      if (!mounted || !shouldSkip) return;
      await _skipToHomeAfterConfirmation();
      return;
    }

    if (currentPage.label == 'Gym Profile' &&
        _selectedGymSpace?.id == 'custom') {
      await _openGymProfileEditor();
      if (!mounted) return;
      _goToGymEquipmentPage();
      return;
    }

    if (currentPage.label == 'Workout Plan') {
      await _handleWorkoutPlanNext();
      return;
    }

    if (_currentPage < lastPageIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
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
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openOnboardingPremadePlans() async {
    final profileId = await _ensureWorkoutPlanProfileId();
    if (!mounted || profileId == null) return;

    final addedPlanIds = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder:
            (_) => PremadePlansPage(
              profileId: profileId,
              onboardingMode: true,
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
        builder:
            (_) => PresetGenerationQaScreen(
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

    final nextNumber = existingPlans.length + 1;
    final name = nextNumber == 1 ? 'New Plan' : 'New Plan $nextNumber';
    final presetId = await repo.createPreset(name, profileId: profileId);
    if (!mounted) return;

    final activeSession = context.read<ActiveSession>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider<ActiveSession>.value(
                  value: activeSession,
                ),
                ChangeNotifierProvider(create: (_) => PresetSession(presetId)),
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

    final latestPlans = await repo.fetchAllPresetsRaw(profileId: profileId);
    final planStillExists = latestPlans.any(
      (row) => (row['id'] as num?)?.toInt() == presetId,
    );
    if (!planStillExists) {
      await ActivePlanStore.remove(profileId, presetId);
      return;
    }

    await ActivePlanStore.add(profileId, presetId);
    if (!mounted) return;
    setState(() {
      _onboardingPlansAdded++;
      _onboardingPlanIds.add(presetId);
      _planOverviewRefreshToken++;
    });
    _goToNextPage();
  }

  String _workoutPlanSummary() {
    if (_onboardingPlansAdded > 0) {
      return '$_onboardingPlansAdded added';
    }
    switch (_workoutPlanSetupOption) {
      case _WorkoutPlanSetupOption.premade:
        return 'Premade selected';
      case _WorkoutPlanSetupOption.generate:
        return 'Generate selected';
      case _WorkoutPlanSetupOption.skip:
        return 'Skipped';
      case _WorkoutPlanSetupOption.manual:
        return 'Manual selected';
      case null:
        return 'Not selected';
    }
  }

  void _previousAction() {
    if (_currentPage <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skipOrFinish() async {
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
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final safePage =
        _currentPage > lastPageIndex ? lastPageIndex : _currentPage;
    final canAdvance = _canAdvance(pages[safePage]);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: _OnboardingHeader(
                currentPage: safePage,
                pageCount: pages.length,
                title: pages[safePage].label,
                onBack: safePage == 0 ? null : _previousAction,
                onSkip: () {
                  _skipOrFinish();
                },
                skipLabel: safePage == lastPageIndex ? 'Finish' : 'Skip',
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: pages[index].builder(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
              child: Column(
                children: [
                  _PageDots(count: pages.length, activeIndex: safePage),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          canAdvance && !_isFinishing
                              ? () {
                                _nextAction();
                              }
                              : null,
                      child: Text(
                        _isFinishing
                            ? 'Finishing...'
                            : safePage == lastPageIndex
                            ? 'Finish Setup'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _OnboardingCard(
      icon: Icons.favorite,
      title: 'Welcome to Tonos',
      subtitle:
          'A quick setup helps personalize workouts, nutrition, and progress tracking.',
      children: const [
        _FeatureRow(
          icon: Icons.fitness_center,
          title: 'Train with context',
          body:
              'Use your preferences and history to shape workout suggestions.',
        ),
        _FeatureRow(
          icon: Icons.restaurant_menu,
          title: 'Support nutrition goals',
          body: 'Set the level of nutrition guidance you want from the app.',
        ),
        _FeatureRow(
          icon: Icons.insights,
          title: 'Track progress',
          body: 'Keep your training and nutrition data connected over time.',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage() {
    return _OnboardingCard(
      icon: Icons.badge_outlined,
      title: 'Tell us the basics',
      subtitle:
          'These details are optional, but they help future calculations.',
      children: [
        _TextInput(
          controller: _nameController,
          label: 'Name',
          hint: 'Enter your name',
          icon: Icons.person_outline,
        ),
        _FieldGap.small,
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: _inputDecoration(
            label: 'Gender',
            icon: Icons.wc_outlined,
          ),
          items:
              const ['Male', 'Female', 'Other', 'Prefer not to say'].map((
                gender,
              ) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
          onChanged: (value) => setState(() => _gender = value),
        ),
        _FieldGap.small,
        _ActionField(
          icon: Icons.calendar_today,
          label: 'Date of birth',
          value: _dob == null ? 'Select date' : _formatDate(_dob!),
          onTap: _pickDob,
        ),
        _FieldGap.small,
        _TextInput(
          controller: _heightController,
          label: 'Height',
          hint: 'e.g. 5\'10" or 178 cm',
          icon: Icons.height,
        ),
        _FieldGap.small,
        _ChoiceGroup<WeightUnit>(
          title: 'Workout weight units',
          options: WeightUnit.values,
          value: _selectedWeightUnit,
          labelBuilder: (unit) => unit.shortLabel,
          onChanged: (unit) {
            if (unit == null) return;
            setState(() => _selectedWeightUnit = unit);
          },
        ),
        _FieldGap.small,
        _TextInput(
          controller: _weightController,
          label: 'Current weight',
          hint:
              _selectedWeightUnit == WeightUnit.pounds ? 'e.g. 160' : 'e.g. 72',
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
          suffixText: _selectedWeightUnit.shortLabel,
        ),
      ],
    );
  }

  Widget _buildUsageIntentPage() {
    return _OnboardingCard(
      icon: Icons.tune,
      title: 'What should Tonos personalize?',
      subtitle:
          'Choose the areas you want to set up now. You can change this later.',
      children: [
        _IntentTile(
          icon: Icons.restaurant_menu,
          title: 'Nutrition data',
          body: 'Nutrition setup is paused while this area is rebuilt.',
          value: false,
          enabled: _nutritionOnboardingEnabled,
          statusLabel: 'Later',
          onChanged: (value) => setState(() => _useNutritionData = value),
        ),
        const SizedBox(height: 12),
        _IntentTile(
          icon: Icons.fitness_center,
          title: 'Exercise data',
          body: 'Set training frequency, activity, and experience.',
          value: _useExerciseData,
          onChanged: (value) => setState(() => _useExerciseData = value),
        ),
      ],
    );
  }

  Widget _buildWeightHistoryPage() {
    return _OnboardingCard(
      icon: Icons.monitor_weight_outlined,
      title: 'Weight history',
      subtitle: 'A few details help estimate nutrition targets more sensibly.',
      children: [
        _SwitchCard(
          title: 'Have you weighed 10+ lbs above your current weight before?',
          value: _weighedHeavy,
          onChanged: (value) => setState(() => _weighedHeavy = value),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: 'Current weight trend',
          options: const [
            'Gaining weight',
            'Losing weight',
            'Maintaining weight',
            'Not sure',
          ],
          value: _weightTrend,
          onChanged: (value) => setState(() => _weightTrend = value),
        ),
      ],
    );
  }

  Widget _buildBodyFatPage() {
    final isFemale = _gender == 'Female';
    final options =
        isFemale
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
    final paths =
        isFemale
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
      title: 'Body-fat estimate',
      subtitle:
          'Choose the closest visual estimate. Precision is not required.',
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
    return _OnboardingCard(
      icon: Icons.restaurant,
      title: 'Nutrition preferences',
      subtitle: 'These preferences shape nutrition suggestions after setup.',
      children: [
        DropdownButtonFormField<String>(
          value: _preferredDiet,
          decoration: _inputDecoration(
            label: 'Preferred diet',
            icon: Icons.restaurant_menu,
          ),
          items:
              const ['Balanced', 'Low fat', 'Low carb', 'Keto'].map((diet) {
                return DropdownMenuItem(value: diet, child: Text(diet));
              }).toList(),
          onChanged: (value) => setState(() => _preferredDiet = value!),
        ),
        _FieldGap.small,
        _TextInput(
          controller: _calorieFloorController,
          label: 'Calorie floor',
          hint: 'Minimum daily kcal',
          icon: Icons.local_fire_department_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: 'Training during program',
          options: const ['None', 'Lifting', 'Cardio', 'Lifting and cardio'],
          value: _trainingType,
          onChanged: (value) => setState(() => _trainingType = value!),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: 'Preferred protein intake',
          options: const ['Low', 'Moderate', 'High', 'Very high'],
          value: _proteinPreference,
          onChanged: (value) => setState(() => _proteinPreference = value!),
        ),
      ],
    );
  }

  Widget _buildNutritionGoalPage() {
    return _OnboardingCard(
      icon: Icons.flag_outlined,
      title: 'Goal pace',
      subtitle: 'Preview a target weight and weekly goal rate.',
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricPreviewCard(
                icon: Icons.local_fire_department_outlined,
                value: '2025 kcal',
                label: 'Initial daily budget',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricPreviewCard(
                icon: Icons.event,
                value: _shortDate(_projectedEndDate),
                label: 'Projected end date',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SliderPanel(
          title: 'Target weight',
          valueLabel: '${_goalWeightValue.round()} lbs',
          child: Slider(
            value: _goalWeightValue,
            min: 100,
            max: 250,
            divisions: 150,
            label: '${_goalWeightValue.round()}',
            onChanged: (value) => setState(() => _goalWeightValue = value),
          ),
        ),
        const SizedBox(height: 16),
        _SliderPanel(
          title: 'Target goal rate',
          valueLabel: '${_weeklyRatePct.toStringAsFixed(1)}% BW/wk',
          child: Slider(
            value: _weeklyRatePct,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${_weeklyRatePct.toStringAsFixed(1)}% BW/wk',
            onChanged:
                (value) => setState(() {
                  _weeklyRatePct = value;
                  _weeklyRateLbs = _goalWeightValue * value / 100;
                  _monthlyRatePct = value * 4;
                  _monthlyRateLbs = _weeklyRateLbs * 4;
                }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Per week',
                value:
                    '-${_weeklyRateLbs.toStringAsFixed(1)} lbs / ${_weeklyRatePct.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Per month',
                value:
                    '-${_monthlyRateLbs.toStringAsFixed(1)} lbs / ${_monthlyRatePct.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGymSpacePage() {
    return _OnboardingCard(
      icon: Icons.location_on_outlined,
      title: 'Where do you work out?',
      subtitle:
          'Choose a starting space. Its equipment will shape exercise suggestions and generated workouts.',
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
            selected: _selectedGymSpace?.skipSetup ?? false,
            onTap: () => _selectGymSpace(_skipGymSpaceTemplate),
          ),
        ] else
          ..._gymSpaceTemplates.map((template) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GymSpaceTile(
                template: template,
                selected: _selectedGymSpace?.id == template.id,
                onTap: () => _selectGymSpace(template),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGymEquipmentPage() {
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
      title: 'Review your workout space',
      subtitle:
          'Rename the profile or adjust its equipment before Tonos creates it.',
      children: [
        TextField(
          controller: _gymProfileNameController,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Profile name',
            prefixIcon: const Icon(Icons.edit_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Included equipment',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${selectedEquipment.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Only exercises supported by this equipment will be suggested when the profile is active.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (selectedEquipment.isEmpty)
                Text(
                  'No equipment selected yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      selectedEquipment.map((equipment) {
                        return Chip(
                          avatar: Icon(
                            _onboardingEquipmentIcon(equipment.name),
                            size: 17,
                          ),
                          label: Text(equipment.name),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetGymEquipment,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _openGymProfileEditor,
                icon: const Icon(Icons.tune),
                label: const Text('Edit profile'),
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
        builder:
            (_) => GymProfileScreen(
              initialName: _gymProfileNameController.text.trim(),
              initialEquipmentNames: _selectedGymEquipmentNames,
              returnDraftOnly: true,
              title: 'Edit Workout Space',
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
    return _OnboardingCard(
      icon: Icons.assignment_outlined,
      title: 'Set up your workout plan',
      subtitle:
          'Choose how Tonos should prepare your first plans. You can always add, archive, or edit plans later.',
      children: [
        _WorkoutPlanSetupTile(
          title: 'Manually create your own plans',
          subtitle:
              'Start with a blank plan, then add exercises and sets yourself.',
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
          title: 'Use premade exercise plans',
          subtitle:
              'Browse built-in full body, upper/lower, push-pull-legs, and body-part split plans.',
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
          title: 'Generate exercise plans',
          subtitle:
              'Answer a few setup questions and let Tonos generate a custom plan for your profile.',
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
          title: 'Skip this step',
          subtitle:
              'Start without adding plans. You can set them up from Train later.',
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
            text:
                '$_onboardingPlansAdded ${_onboardingPlansAdded == 1 ? 'plan has' : 'plans have'} been added to Active Plans.',
          ),
        ],
      ],
    );
  }

  Widget _buildWorkoutPlanOverviewPage() {
    final planCount = _onboardingPlanIds.length;
    return _OnboardingCard(
      icon: Icons.fact_check_outlined,
      title: 'Review your plans',
      subtitle:
          'These plans were added to your active plans. Open any plan to inspect or adjust it before continuing.',
      children: [
        _OnboardingPlanOverviewList(
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
          text:
              '$planCount ${planCount == 1 ? 'plan is' : 'plans are'} ready in Active Plans.',
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    final usesNutrition = _nutritionOnboardingEnabled && _useNutritionData;
    final included = [
      if (usesNutrition) 'Nutrition setup',
      if (_useExerciseData) 'Exercise setup',
      if (!usesNutrition && !_useExerciseData) 'Basic profile only',
    ];

    return _OnboardingCard(
      icon: Icons.check_circle,
      title: 'Ready to start',
      subtitle: 'Review your setup, then finish to enter Tonos.',
      children: [
        _SummaryRow(label: 'Name', value: _nameController.text.trim()),
        _SummaryRow(label: 'Gender', value: _gender ?? ''),
        _SummaryRow(
          label: 'DOB',
          value: _dob == null ? '' : _formatDate(_dob!),
        ),
        _SummaryRow(label: 'Height', value: _heightController.text.trim()),
        _SummaryRow(label: 'Weight', value: _weightController.text.trim()),
        _SummaryRow(label: 'Workout units', value: _selectedWeightUnit.label),
        _SummaryRow(label: 'Included', value: included.join(', ')),
        if (usesNutrition) ...[
          _SummaryRow(label: 'Weight trend', value: _weightTrend ?? ''),
          _SummaryRow(label: 'Body fat', value: _bodyFatEstimate ?? ''),
          _SummaryRow(label: 'Diet', value: _preferredDiet),
          _SummaryRow(label: 'Protein', value: _proteinPreference),
        ],
        if (_useExerciseData) ...[
          _SummaryRow(
            label: 'Gym profile',
            value:
                _selectedGymSpace?.skipSetup ?? true
                    ? 'General'
                    : _gymProfileNameController.text.trim(),
          ),
          if (!(_selectedGymSpace?.skipSetup ?? true))
            _SummaryRow(
              label: 'Equipment',
              value: '${_selectedGymEquipmentNames.length} selected',
            ),
          _SummaryRow(label: 'Workout plans', value: _workoutPlanSummary()),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _shortDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _OnboardingHeader extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final String skipLabel;

  const _OnboardingHeader({
    required this.currentPage,
    required this.pageCount,
    required this.title,
    required this.onBack,
    required this.onSkip,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = pageCount <= 1 ? 1.0 : (currentPage + 1) / pageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 72,
                  child:
                      onBack == null
                          ? null
                          : IconButton(
                            onPressed: onBack,
                            tooltip: 'Previous step',
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.chevron_left, size: 26),
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 76),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 72,
                  child: TextButton(onPressed: onSkip, child: Text(skipLabel)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Step ${currentPage + 1} of $pageCount',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffixText;

  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _ActionField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ActionField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(value),
      ),
    );
  }
}

class _IntentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool value;
  final bool enabled;
  final String? statusLabel;
  final ValueChanged<bool> onChanged;

  const _IntentTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = enabled && value;
    final iconColor = enabled ? scheme.primary : scheme.onSurfaceVariant;
    final foregroundColor =
        enabled ? scheme.onSurface : scheme.onSurfaceVariant;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    final backgroundColor =
        selected
            ? scheme.primary.withValues(alpha: 0.16)
            : scheme.surface.withValues(alpha: enabled ? 0.5 : 0.28);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.16),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(
                        alpha: enabled ? 1 : 0.78,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled && statusLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  statusLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              Checkbox(
                value: value,
                onChanged: enabled ? (next) => onChanged(next ?? false) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ChoiceGroup<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T option)? labelBuilder;

  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final selected = option == value;
                return ChoiceChip(
                  label: Text(labelBuilder?.call(option) ?? '$option'),
                  selected: selected,
                  onSelected: (_) => onChanged(option),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _BodyFatTile extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyFatTile({
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Icons.image_not_supported, color: scheme.outline),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.58),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPreviewCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricPreviewCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SliderPanel extends StatelessWidget {
  final String title;
  final String valueLabel;
  final Widget child;

  const _SliderPanel({
    required this.title,
    required this.valueLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? scheme.primary : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

enum _WorkoutPlanSetupOption { manual, premade, generate, skip }

class _OnboardingPlanItem {
  final int presetId;
  final String name;
  final bool isAutomatic;
  final int listIndex;
  final Map<String, double> focusFrequencyMap;

  const _OnboardingPlanItem({
    required this.presetId,
    required this.name,
    required this.isAutomatic,
    required this.listIndex,
    required this.focusFrequencyMap,
  });
}

class _OnboardingPlanOverviewList extends StatefulWidget {
  final int? profileId;
  final Set<int> planIds;
  final int refreshToken;
  final VoidCallback onChanged;

  const _OnboardingPlanOverviewList({
    required this.profileId,
    required this.planIds,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<_OnboardingPlanOverviewList> createState() =>
      _OnboardingPlanOverviewListState();
}

class _OnboardingPlanOverviewListState
    extends State<_OnboardingPlanOverviewList> {
  final _repo = AppRepository();
  Future<List<_OnboardingPlanItem>>? _plansFuture;
  int? _loadedProfileId;
  int? _loadedRefreshToken;
  Set<int> _loadedPlanIds = const <int>{};

  static const _palette = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureFuture();
  }

  @override
  void didUpdateWidget(covariant _OnboardingPlanOverviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFuture();
  }

  void _ensureFuture() {
    final profileId = widget.profileId;
    final planIds = Set<int>.from(widget.planIds);
    final shouldReload =
        _plansFuture == null ||
        _loadedProfileId != profileId ||
        _loadedRefreshToken != widget.refreshToken ||
        !_setEquals(_loadedPlanIds, planIds);
    if (!shouldReload) return;

    _loadedProfileId = profileId;
    _loadedRefreshToken = widget.refreshToken;
    _loadedPlanIds = planIds;
    _plansFuture =
        profileId == null
            ? Future.value(const <_OnboardingPlanItem>[])
            : _loadPlans(profileId, planIds);
  }

  Future<List<_OnboardingPlanItem>> _loadPlans(
    int profileId,
    Set<int> planIds,
  ) async {
    if (planIds.isEmpty) return const <_OnboardingPlanItem>[];
    final rows = await _repo.fetchPresetSummariesRaw(profileId: profileId);
    final order = {
      for (var index = 0; index < planIds.length; index++)
        planIds.elementAt(index): index,
    };
    final filteredRows =
        rows.where((row) => planIds.contains(row['id'] as int)).toList()..sort(
          (a, b) => (order[a['id'] as int] ?? 0).compareTo(
            order[b['id'] as int] ?? 0,
          ),
        );
    final presetIds = filteredRows.map((row) => row['id'] as int).toList();
    final focusRows = await _repo.fetchPresetFocusSetCountsRaw(
      presetIds: presetIds,
    );
    final focusSetCountsByPreset = _groupFocusSetCounts(focusRows);
    final unitsByDefinition = await _loadBodyPartUnitsByDefinition(
      focusSetCountsByPreset,
    );

    return [
      for (var index = 0; index < filteredRows.length; index++)
        _OnboardingPlanItem(
          presetId: filteredRows[index]['id'] as int,
          name: filteredRows[index]['name'] as String,
          isAutomatic: (filteredRows[index]['is_automatic'] as int? ?? 0) == 1,
          listIndex: index,
          focusFrequencyMap: _buildFocusFrequencyMap(
            focusSetCountsByPreset[filteredRows[index]['id'] as int] ??
                const <int, int>{},
            unitsByDefinition,
          ),
        ),
    ];
  }

  Map<int, Map<int, int>> _groupFocusSetCounts(
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <int, Map<int, int>>{};
    for (final row in rows) {
      final presetId = row['preset_id'] as int;
      final defId = row['def_id'] as int;
      final setCount = ((row['set_count'] as num?) ?? 0).toInt();
      if (setCount <= 0) continue;
      grouped.putIfAbsent(presetId, () => <int, int>{})[defId] = setCount;
    }
    return grouped;
  }

  Future<Map<int, Map<String, double>>> _loadBodyPartUnitsByDefinition(
    Map<int, Map<int, int>> focusSetCountsByPreset,
  ) async {
    final defIds = <int>{
      for (final counts in focusSetCountsByPreset.values) ...counts.keys,
    };
    if (defIds.isEmpty) return const <int, Map<String, double>>{};

    final result = <int, Map<String, double>>{};
    for (final defId in defIds) {
      final units = await _repo.computeBodyPartPercents(defId);
      result[defId] = {
        for (final entry in units.entries)
          if (entry.value > 0.0) entry.key.name: entry.value,
      };
    }
    return result;
  }

  Map<String, double> _buildFocusFrequencyMap(
    Map<int, int> setCountsByDefinition,
    Map<int, Map<String, double>> unitsByDefinition,
  ) {
    final bodyPartTotals = <String, double>{};
    setCountsByDefinition.forEach((defId, setCount) {
      final units = unitsByDefinition[defId];
      if (units == null || setCount <= 0) return;
      units.forEach((bodyPartName, unitsPerSet) {
        bodyPartTotals[bodyPartName] =
            (bodyPartTotals[bodyPartName] ?? 0.0) + unitsPerSet * setCount;
      });
    });
    if (bodyPartTotals.isEmpty) return const <String, double>{};

    final maxUnits = bodyPartTotals.values.fold<double>(
      0.0,
      (max, value) => value > max ? value : max,
    );
    if (maxUnits <= 0.0) return const <String, double>{};

    final frequencyMap = <String, double>{};
    bodyPartTotals.forEach((bodyPartName, units) {
      final svgIds = bodyPartNameToSvgIds[bodyPartName] ?? const <String>[];
      final normalized = units / maxUnits;
      for (final svgId in svgIds) {
        frequencyMap[svgId] = normalized;
      }
    });
    return frequencyMap;
  }

  bool _setEquals(Set<int> left, Set<int> right) {
    if (left.length != right.length) return false;
    for (final value in left) {
      if (!right.contains(value)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<_OnboardingPlanItem>>(
      future: _plansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            'Could not load plan overview yet.',
            style: TextStyle(color: scheme.error),
          );
        }

        final plans = snapshot.data ?? const <_OnboardingPlanItem>[];
        if (plans.isEmpty) {
          return Text(
            'No added plans were found. Go back to add plans, or skip this step.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          );
        }

        return Column(
          children: [
            for (final plan in plans)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PresetBar(
                  presetId: plan.presetId,
                  label: plan.name,
                  color: _palette[plan.listIndex % _palette.length],
                  index: plan.listIndex,
                  isAutomatic: plan.isAutomatic,
                  focusFrequencyMap: plan.focusFrequencyMap,
                  onRefresh: () {
                    _ensureFuture();
                    widget.onChanged();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GymSpaceTemplate {
  final String id;
  final String title;
  final String subtitle;
  final String defaultProfileName;
  final IconData icon;
  final Set<String> equipmentNames;
  final bool includeAllEquipment;
  final bool skipSetup;
  final bool highlighted;

  const _GymSpaceTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.defaultProfileName,
    required this.icon,
    this.equipmentNames = const {},
    this.includeAllEquipment = false,
    this.skipSetup = false,
    this.highlighted = false,
  });
}

const _gymSpaceTemplates = <_GymSpaceTemplate>[
  _GymSpaceTemplate(
    id: 'custom',
    title: 'Customized Space',
    subtitle: 'Design your own profile by choosing every available item.',
    defaultProfileName: 'Custom Space',
    icon: Icons.tune,
    highlighted: true,
  ),
  _GymSpaceTemplate(
    id: 'skip',
    title: 'Skip this step',
    subtitle: 'Keep the General profile and choose your equipment later.',
    defaultProfileName: 'General',
    icon: Icons.fast_forward,
    skipSetup: true,
  ),
  _GymSpaceTemplate(
    id: 'commercial',
    title: 'Commercial Gym',
    subtitle:
        'Start with every available equipment option, then remove anything your gym does not have.',
    defaultProfileName: 'Commercial Gym',
    icon: Icons.apartment,
    includeAllEquipment: true,
  ),
  _GymSpaceTemplate(
    id: 'home_gym',
    title: 'Home Gym',
    subtitle:
        'A practical home setup with free weights, bands, a bench, and bodyweight equipment.',
    defaultProfileName: 'Home Gym',
    icon: Icons.home_work_outlined,
    equipmentNames: {
      'None',
      'Bodyweight',
      'Dumbbell',
      'Kettlebell',
      'Adjustable Bench',
      'Resistance Band',
      'Ab Roller',
      'Weight Plates',
    },
  ),
  _GymSpaceTemplate(
    id: 'calisthenics',
    title: 'Calisthenics',
    subtitle:
        'Bodyweight-focused equipment including bars, rings, bands, and basic accessories.',
    defaultProfileName: 'Calisthenics',
    icon: Icons.accessibility_new,
    equipmentNames: {
      'None',
      'Bodyweight',
      'Adjustable Bench',
      'Dip Bars',
      'Ab Roller',
      'Resistance Band',
      'Weight Plates',
      'Pull-Up Bar',
      'Gymnastics Rings',
    },
  ),
  _GymSpaceTemplate(
    id: 'powerlifting',
    title: 'Powerlifting',
    subtitle: 'A barbell-based space with plates, a power rack, and a bench.',
    defaultProfileName: 'Powerlifting',
    icon: Icons.fitness_center,
    equipmentNames: {
      'Barbell',
      'Weight Plates',
      'Power Rack',
      'Adjustable Bench',
    },
  ),
  _GymSpaceTemplate(
    id: 'free_weights',
    title: 'Free Weights',
    subtitle:
        'Dumbbells, kettlebells, plates, a bench, and bodyweight movements.',
    defaultProfileName: 'Free Weights',
    icon: Icons.sports_gymnastics,
    equipmentNames: {
      'Dumbbell',
      'Weight Plates',
      'Adjustable Bench',
      'Bodyweight',
      'Kettlebell',
    },
  ),
];

final _skipGymSpaceTemplate = _gymSpaceTemplates.firstWhere(
  (template) => template.skipSetup,
);

class _GymSpaceTile extends StatelessWidget {
  final _GymSpaceTemplate template;
  final bool selected;
  final VoidCallback onTap;

  const _GymSpaceTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = template.highlighted ? scheme.tertiary : scheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? accent.withValues(alpha: 0.16)
                  : scheme.surface.withValues(alpha: 0.46),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? accent : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(template.icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: template.highlighted ? accent : null,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? accent : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _GymEquipmentLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GymEquipmentLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: scheme.error),
          const SizedBox(height: 8),
          Text(
            'Equipment could not be loaded.',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanSetupTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _WorkoutPlanSetupTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? scheme.primary.withValues(alpha: 0.16)
                  : scheme.surface.withValues(alpha: 0.46),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingInfoCallout extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OnboardingInfoCallout({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _onboardingEquipmentIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('bench')) return Icons.event_seat;
  if (lower.contains('machine') || lower.contains('smith')) {
    return Icons.precision_manufacturing;
  }
  if (lower.contains('cable') || lower.contains('attachment')) {
    return Icons.cable;
  }
  if (lower.contains('bodyweight') || lower == 'none') {
    return Icons.accessibility_new;
  }
  if (lower.contains('ring')) return Icons.radio_button_unchecked;
  if (lower.contains('band')) return Icons.linear_scale;
  if (lower.contains('rack') || lower.contains('pull-up')) {
    return Icons.view_week;
  }
  return Icons.fitness_center;
}

class _FieldGap {
  static const small = SizedBox(height: 14);
}

class _OnboardingPage {
  final String label;
  final Widget Function() builder;

  const _OnboardingPage(this.label, this.builder);
}
