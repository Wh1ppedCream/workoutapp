// File: lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';

/// A personalized multi-step onboarding flow UI.
/// TODO: Persist user inputs to provider/storage when integrating.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // ----- Onboarding fields -----
  String _name = '';
  String _gender = 'Male';
  DateTime? _dob;
  String _height = '';
  String _weight = '';
  bool _weighedHeavy = false;
  String _weightTrend = 'Maintaining weight';
  String _bodyFatEstimate = '20-25%';
  String _exerciseFrequency = '1-3 sessions';
  String _activityLevel = 'Moderate';
  String _liftingExperience = 'No experience';
  String _cardioExperience = 'No experience';
  String _maintenanceCalories = '';
  String _targetWeight = '';
  String _preferredDiet = 'Balanced';
  String _calorieFloor = '';
  String _trainingType = 'Lifting and cardio';
  String _proteinPreference = 'Moderate';

  // New usage intent selections
  bool _useNutritionData = false;
  bool _useExerciseData = false;
  bool _useMeasurementsData = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _getOnboardingPages() {
    final pages = <Widget>[
      _buildWelcomePage(),
      _buildPersonalInfoPage(),
      _buildUsageIntentPage(),
    ];

    if (_useNutritionData) {
      pages.addAll([
        _buildAnthropometryPage(),
        _buildWeightHistoryPage(),
        _buildExerciseActivityPage(),
        _buildNutritionPreferencesPage(),
        _buildTrainingPreferencesPage(),
      ]);
    }

    // TODO: Add exercise-specific pages when _useExerciseData is true
    // TODO: Add measurement-specific pages when _useMeasurementsData is true

    pages.add(_buildSummaryPage());
    return pages;
  }

  void _nextAction() {
    final pages = _getOnboardingPages();
    final lastPageIndex = pages.length - 1;
    if (_currentPage < lastPageIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Navigate to main dashboard after onboarding
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _skipOrFinish() {
    final pages = _getOnboardingPages();
    final lastPageIndex = pages.length - 1;
    if (_currentPage == lastPageIndex) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      _controller.animateToPage(
        lastPageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getOnboardingPages();
    final lastPageIndex = pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // show “Step X of Y”
          'Step ${_currentPage + 1} of ${pages.length}',
        ),
        actions: [
          TextButton(
            onPressed: _skipOrFinish,
            child: Text(
              _currentPage == lastPageIndex ? 'Finish' : 'Skip',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: pages.length,
              itemBuilder: (_, idx) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: pages[idx],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (idx) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == idx ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == idx ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: _nextAction,
              child: Text(
                _currentPage == lastPageIndex ? 'Finish' : 'Next',
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Welcome to FitTrack!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'We’ll ask a few questions to personalize your experience.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage() {
    return ListView(
      children: [
        const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(hintText: 'Enter your name'),
          onChanged: (v) => _name = v, // TODO: persist
        ),
        const SizedBox(height: 16),
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _gender,
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _gender = v!), // TODO
        ),
        const SizedBox(height: 16),
        const Text('Date of birth', style: TextStyle(fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _dob = d); // TODO
          },
          child: Text(
            _dob == null ? 'Select date' : _dob!.toLocal().toString().split(' ')[0],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageIntentPage() {
    return ListView(
      children: [
        const Text(
          'What do you intend on using the app for?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Logging nutritional data'),
          value: _useNutritionData,
          onChanged: (v) => setState(() => _useNutritionData = v!), // TODO
        ),
        CheckboxListTile(
          title: const Text('Logging exercise data'),
          value: _useExerciseData,
          onChanged: (v) => setState(() => _useExerciseData = v!), // TODO
        ),
        CheckboxListTile(
          title: const Text('Logging bodily changes and measurements'),
          value: _useMeasurementsData,
          onChanged: (v) => setState(() => _useMeasurementsData = v!), // TODO
        ),
      ],
    );
  }

  Widget _buildAnthropometryPage() {
    return ListView(
      children: [
        const Text('Height', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(hintText: 'e.g. 5\'10" or 178 cm'),
          onChanged: (v) => _height = v, // TODO
        ),
        const SizedBox(height: 16),
        const Text('Current Weight', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(hintText: 'e.g. 160 lbs or 72 kg'),
          onChanged: (v) => _weight = v, // TODO
        ),
      ],
    );
  }

  Widget _buildWeightHistoryPage() {
    return ListView(
      children: [
        const Text(
          'Have you weighed >10 lbs above current weight before?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: const Text('Yes'),
          value: _weighedHeavy,
          onChanged: (v) => setState(() => _weighedHeavy = v), // TODO
        ),
        const SizedBox(height: 16),
        const Text('Current weight trend', style: TextStyle(fontWeight: FontWeight.bold)),
        ...[
          'Gaining weight',
          'Losing weight',
          'Maintaining weight',
          'Not sure',
        ]
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _weightTrend,
                  onChanged: (v) => setState(() => _weightTrend = v!), // TODO
                ))
            ,
        const SizedBox(height: 16),
        const Text('Bodyfat estimate', style: TextStyle(fontWeight: FontWeight.bold)),
        // TODO: replace with image grid for 5% increments
        DropdownButton<String>(
          value: _bodyFatEstimate,
          items: <String>[
            '0-5%',
            '5-10%',
            '10-15%',
            '15-20%',
            '20-25%',
            '25-30%',
            '30-35%',
            '35-40%',
            '40+%',
          ]
              .map((lbl) => DropdownMenuItem(value: lbl, child: Text(lbl)))
              .toList(),
          onChanged: (v) => setState(() => _bodyFatEstimate = v!),
        ),
      ],
    );
  }

  Widget _buildExerciseActivityPage() {
    return ListView(
      children: [
        const Text('Exercise frequency', style: TextStyle(fontWeight: FontWeight.bold)),
        ...['0', '1-3 sessions', '4-6 sessions', '7+ sessions']
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _exerciseFrequency,
                  onChanged: (v) => setState(() => _exerciseFrequency = v!),
                ))
            ,
        const SizedBox(height: 16),
        const Text('Activity level (steps)', style: TextStyle(fontWeight: FontWeight.bold)),
        ...['Low (0-5k)', 'Moderate (5-15k)', 'High (15k+)']
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _activityLevel,
                  onChanged: (v) => setState(() => _activityLevel = v!),
                ))
            ,
        const SizedBox(height: 16),
        const Text('Weightlifting experience', style: TextStyle(fontWeight: FontWeight.bold)),
        ...[
          'No experience',
          'Beginner (<1yr)',
          'Intermediate (1-4yr)',
          'Advanced (4yr+)',
        ]
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _liftingExperience,
                  onChanged: (v) => setState(() => _liftingExperience = v!),
                ))
            ,
        const SizedBox(height: 16),
        const Text('Cardio experience', style: TextStyle(fontWeight: FontWeight.bold)),
        ...[
          'No experience',
          'Beginner (<1yr)',
          'Intermediate (1-4yr)',
          'Advanced (4yr+)',
        ]
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _cardioExperience,
                  onChanged: (v) => setState(() => _cardioExperience = v!),
                ))
            ,
      ],
    );
  }

  Widget _buildNutritionPreferencesPage() {
    return ListView(
      children: [
        const Text(
          'Maintenance calorie estimate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          decoration: const InputDecoration(hintText: 'e.g. 2000 kcal'),
          onChanged: (v) => _maintenanceCalories = v, // TODO
        ),
        const SizedBox(height: 16),
        const Text('Target weight', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(hintText: 'e.g. 150 lbs'),
          onChanged: (v) => _targetWeight = v, // TODO
        ),
        const SizedBox(height: 16),
        const Text('Preferred diet', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _preferredDiet,
          items: <String>['Balanced', 'Low fat', 'Low carb', 'Keto']
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _preferredDiet = v!),
        ),
        const SizedBox(height: 16),
        const Text('Calorie floor', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(hintText: 'Minimum kcal'),
          onChanged: (v) => _calorieFloor = v, // TODO
        ),
      ],
    );
  }

  Widget _buildTrainingPreferencesPage() {
    return ListView(
      children: [
        const Text(
          'Training during program',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...['None', 'Lifting', 'Cardio', 'Lifting and cardio']
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _trainingType,
                  onChanged: (v) => setState(() => _trainingType = v!),
                ))
            ,
        const SizedBox(height: 16),
        const Text('Preferred protein intake', style: TextStyle(fontWeight: FontWeight.bold)),
        ...['Low', 'Moderate', 'High', 'Very high']
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: _proteinPreference,
                  onChanged: (v) => setState(() => _proteinPreference = v!),
                ))
            ,
      ],
    );
  }

  Widget _buildSummaryPage() {
    return ListView(
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Summary',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text('Name: $_name'),
        Text('Gender: $_gender'),
        Text('DOB: ${_dob?.toLocal().toString().split(' ')[0] ?? ''}'),
        const SizedBox(height: 12),
        const Text('Intends to use for:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (_useNutritionData) const Text('- Logging nutritional data'),
        if (_useExerciseData) const Text('- Logging exercise data'),
        if (_useMeasurementsData)
          const Text('- Logging bodily changes and measurements'),
        const SizedBox(height: 12),
        Text('Height: $_height'),
        Text('Weight: $_weight'),
        Text('Weighed >10lb before: ${_weighedHeavy ? 'Yes' : 'No'}'),
        Text('Trend: $_weightTrend'),
        Text('Bodyfat: $_bodyFatEstimate'),
        Text('Exercise freq: $_exerciseFrequency'),
        Text('Activity: $_activityLevel'),
        Text('Lifting exp: $_liftingExperience'),
        Text('Cardio exp: $_cardioExperience'),
        Text('Maintenance: $_maintenanceCalories'),
        Text('Target weight: $_targetWeight'),
        Text('Diet: $_preferredDiet'),
        Text('Calorie floor: $_calorieFloor'),
        Text('Training: $_trainingType'),
        Text('Protein: $_proteinPreference'),
        const SizedBox(height: 24),
        // TODO: Show calculated metrics (bodyfat loss rate, calorie budget, etc.)
      ],
    );
  }
}
