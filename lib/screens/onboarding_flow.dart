// File: lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/onboarding_provider.dart';
import '../repositories/app_repository.dart';

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

  int _currentPage = 0;
  String? _gender;
  DateTime? _dob;
  bool _weighedHeavy = false;
  String? _weightTrend;
  String? _bodyFatEstimate;
  String _exerciseFrequency = '1-3 sessions';
  String? _activityLevel;
  String _liftingExperience = 'No experience';
  String _cardioExperience = 'No experience';
  String _preferredDiet = 'Balanced';
  String _trainingType = 'Lifting and cardio';
  String _proteinPreference = 'Moderate';
  bool _useNutritionData = false;
  bool _useExerciseData = false;

  double _goalWeightValue = 140;
  final DateTime _projectedEndDate = DateTime.now().add(
    const Duration(days: 30),
  );
  double _weeklyRateLbs = 0.7;
  double _weeklyRatePct = 0.5;
  double _monthlyRateLbs = 2.8;
  double _monthlyRatePct = 2.0;

  bool get _nutritionOnboardingEnabled => false;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieFloorController.dispose();
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
        _OnboardingPage('Activity', _buildExerciseActivityPage),
        _OnboardingPage('Training', _buildExerciseDataPage),
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
        (_activityLevel?.isNotEmpty ?? false) ||
        _gender != null;
  }

  Future<void> _finishOnboarding() async {
    final repo = context.read<AppRepository>();
    final onboardingConfig = context.read<OnboardingConfig>();

    final info = PersonalInfo(
      name: _clean(_nameController.text),
      gender: _gender,
      dob: _dob,
      height: _clean(_heightController.text),
      weight: _clean(_weightController.text),
      bodyFatEstimate: _bodyFatEstimate,
      weightTrend: _weightTrend,
      activityLevel: _activityLevel,
    );

    if (_hasAnyInput()) {
      await repo.savePersonalInfo(info);
    }

    await onboardingConfig.markCompleted();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }

  String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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

  void _nextAction() {
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    if (_currentPage < lastPageIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _finishOnboarding();
  }

  void _skipOrFinish() {
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    if (_currentPage == lastPageIndex) {
      _finishOnboarding();
      return;
    }
    _controller.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final lastPageIndex = pages.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final safePage = _currentPage > lastPageIndex ? lastPageIndex : _currentPage;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: _OnboardingHeader(
                currentPage: _currentPage,
                pageCount: pages.length,
                title: pages[safePage].label,
                onSkip: _skipOrFinish,
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
                      onPressed: _nextAction,
                      child: Text(
                        safePage == lastPageIndex ? 'Finish Setup' : 'Next',
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
          body: 'Use your preferences and history to shape workout suggestions.',
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
      subtitle: 'These details are optional, but they help future calculations.',
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
          items: const ['Male', 'Female', 'Other', 'Prefer not to say']
              .map((gender) {
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
        _TextInput(
          controller: _weightController,
          label: 'Current weight',
          hint: 'e.g. 160 lbs or 72 kg',
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
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
      title: 'Body-fat estimate',
      subtitle: 'Choose the closest visual estimate. Precision is not required.',
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
          items: const ['Balanced', 'Low fat', 'Low carb', 'Keto'].map((diet) {
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
            onChanged: (value) => setState(() {
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

  Widget _buildExerciseActivityPage() {
    return _OnboardingCard(
      icon: Icons.directions_run,
      title: 'Training activity',
      subtitle: 'This helps calibrate workout and recovery assumptions.',
      children: [
        _ChoiceGroup<String>(
          title: 'Exercise frequency',
          options: const ['0', '1-3 sessions', '4-6 sessions', '7+ sessions'],
          value: _exerciseFrequency,
          onChanged: (value) => setState(() => _exerciseFrequency = value!),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: 'Activity level',
          options: const ['Low (0-5k)', 'Moderate (5-15k)', 'High (15k+)'],
          value: _activityLevel,
          onChanged: (value) => setState(() => _activityLevel = value),
        ),
      ],
    );
  }

  Widget _buildExerciseDataPage() {
    return _OnboardingCard(
      icon: Icons.fitness_center,
      title: 'Exercise experience',
      subtitle: 'Tell Tonos how familiar you are with training.',
      children: [
        _ChoiceGroup<String>(
          title: 'Weightlifting experience',
          options: const [
            'No experience',
            'Beginner (<1yr)',
            'Intermediate (1-4yr)',
            'Advanced (4yr+)',
          ],
          value: _liftingExperience,
          onChanged: (value) => setState(() => _liftingExperience = value!),
        ),
        const SizedBox(height: 16),
        _ChoiceGroup<String>(
          title: 'Cardio experience',
          options: const [
            'No experience',
            'Beginner (<1yr)',
            'Intermediate (1-4yr)',
            'Advanced (4yr+)',
          ],
          value: _cardioExperience,
          onChanged: (value) => setState(() => _cardioExperience = value!),
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
        _SummaryRow(label: 'DOB', value: _dob == null ? '' : _formatDate(_dob!)),
        _SummaryRow(label: 'Height', value: _heightController.text.trim()),
        _SummaryRow(label: 'Weight', value: _weightController.text.trim()),
        _SummaryRow(label: 'Included', value: included.join(', ')),
        if (usesNutrition) ...[
          _SummaryRow(label: 'Weight trend', value: _weightTrend ?? ''),
          _SummaryRow(label: 'Body fat', value: _bodyFatEstimate ?? ''),
          _SummaryRow(label: 'Diet', value: _preferredDiet),
          _SummaryRow(label: 'Protein', value: _proteinPreference),
        ],
        if (_useExerciseData) ...[
          _SummaryRow(label: 'Exercise freq.', value: _exerciseFrequency),
          _SummaryRow(label: 'Activity', value: _activityLevel ?? ''),
          _SummaryRow(label: 'Lifting exp.', value: _liftingExperience),
          _SummaryRow(label: 'Cardio exp.', value: _cardioExperience),
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
  final VoidCallback onSkip;
  final String skipLabel;

  const _OnboardingHeader({
    required this.currentPage,
    required this.pageCount,
    required this.title,
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
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(onPressed: onSkip, child: Text(skipLabel)),
          ],
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
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
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

  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
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
    final foregroundColor = enabled ? scheme.onSurface : scheme.onSurfaceVariant;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    final backgroundColor = selected
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                onChanged: enabled
                    ? (next) => onChanged(next ?? false)
                    : null,
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
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
          children: options.map((option) {
            final selected = option == value;
            return ChoiceChip(
              label: Text('$option'),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
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
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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

class _FieldGap {
  static const small = SizedBox(height: 14);
}

class _OnboardingPage {
  final String label;
  final Widget Function() builder;

  const _OnboardingPage(this.label, this.builder);
}
