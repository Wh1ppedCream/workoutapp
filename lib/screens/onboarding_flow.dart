// File: lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

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

  // —— add these state fields at the top of your State class —— 
double _goalWeightValue = 140;      // TODO: initialize from user input / profile
DateTime _projectedEndDate =        // TODO: calculate based on goal
    DateTime.now().add(const Duration(days: 30));
double _weeklyRateLbs = 0.7;        // TODO: bind to goal-rate slider
double _weeklyRatePct = 0.5;        // TODO: bind to goal-rate slider
double _monthlyRateLbs = 2.8;       // TODO: calculate from weekly
double _monthlyRatePct = 2.0;       // TODO: calculate from weekly

  

  // List of all “big” sections in order, and whether the user opted into them
  List<_Section> get _sections => [
    _Section('Basics', true),                             // always true
    _Section('Logging nutritional data', _useNutritionData),
    _Section('Logging exercise data',    _useExerciseData),
    _Section('Logging measurements',      _useMeasurementsData),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _getOnboardingPages() {
    final pages = <Widget>[];
  //  int sectionIndex = 0;

     // — Welcome
  pages.add(_buildWelcomePage());
  // Progress: only “Basics” highlighted
  pages.add(_buildProgressPage(0));

  // — Basics chunk: Personal + Usage Intent
  pages.add(_buildPersonalInfoPage());
  pages.add(_buildUsageIntentPage());
  // Progress: Basics ✔, Nutrition highlighted (or ✕ if skipped)
  pages.add(_buildProgressPage(1));

  // — Nutrition chunk
  if (_useNutritionData) {
    pages.add(_buildWeightHistoryPage());
    pages.add(_buildBodyFatPage());
    pages.add(_buildNutritionAndTrainingPage());
    pages.add(_buildNutritionGoalPage());
  }
  // Progress: Nutrition ✔ (or ✕), Exercise highlighted
  pages.add(_buildProgressPage(2));

  // — Exercise chunk
  if (_useExerciseData) {
    pages.add(_buildExerciseActivityPage());
    pages.add(_buildExerciseDataPage());
  }
  // Progress: Exercise ✔ (or ✕), Measurements highlighted
  pages.add(_buildProgressPage(3));

  // — Measurements chunk
  if (_useMeasurementsData) {
    pages.add(_buildMeasurementsPage());
  }

   pages.add(_buildProgressPage(4));

  // — Final Summary
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
       // mark onboarding done
      context.read<OnboardingConfig>().markCompleted();
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _skipOrFinish() {
    final pages = _getOnboardingPages();
    final lastPageIndex = pages.length - 1;
    if (_currentPage == lastPageIndex) {
      // also mark done if they hit “Finish” via Skip button
      context.read<OnboardingConfig>().markCompleted();
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
          "Welcome to 'insert name'!",
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
          items: ['Male', 'Female']
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
		const SizedBox(height: 16),
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
            /*
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
        */
      ],
    );
  }

  // 2) New _buildBodyFatPage: just the estimator
Widget _buildBodyFatPage() {
  final isFemale = _gender == 'Female';

  // male options & assets
  final optionsMale = <String>[
    '0-5%', '5-10%', '10-15%', '15-20%',
    '20-25%', '25-30%', '30-35%', '35-40%',
  ];
  final pathsMale = <String>[
    'assets/bodyfat/0-5_bf.png',
    'assets/bodyfat/5-10_bf.png',
    'assets/bodyfat/10-15_bf.png',
    'assets/bodyfat/15-20_bf.png',
    'assets/bodyfat/20-25_bf.png',
    'assets/bodyfat/25-30_bf.png',
    'assets/bodyfat/30-35_bf.png',
    'assets/bodyfat/35-40_bf.png',
  ];

  // female options & assets
  final optionsFemale = <String>[
    '5-10%', '10-15%', '15-20%',
    '20-25%', '25-30%', '30-35%', '35-40%', '40-45%',
  ];
  final pathsFemale = <String>[
    'assets/bodyfat_woman/5-10_woman.png',
    'assets/bodyfat_woman/10-15_woman.png',
    'assets/bodyfat_woman/15-20_woman.png',
    'assets/bodyfat_woman/20-25_woman.png',
    'assets/bodyfat_woman/25-30_woman.png',
    'assets/bodyfat_woman/30-35_woman.png',
    'assets/bodyfat_woman/35-40_woman.png',
    'assets/bodyfat_woman/40-45_woman.png',
  ];

  // pick the right set
  final options = isFemale ? optionsFemale : optionsMale;
  final assetPaths = isFemale ? pathsFemale : pathsMale;

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'What is your body‑fat level?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Visually assess and estimate; don’t worry about being too precise',
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 16),

      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, i) {
          final label = options[i];
          final path  = assetPaths[i];
          final isSelected = _bodyFatEstimate == label;

          return GestureDetector(
            onTap: () => setState(() => _bodyFatEstimate = label),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(path, fit: BoxFit.cover),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

Widget _buildNutritionAndTrainingPage() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // — Nutrition prefs
      const Text(
        'Preferred diet',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      DropdownButton<String>(
        value: _preferredDiet,
        items: <String>['Balanced', 'Low fat', 'Low carb', 'Keto']
            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
            .toList(),
        onChanged: (v) => setState(() => _preferredDiet = v!),
      ),
      const SizedBox(height: 24),

      const Text(
        'Calorie floor',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: const InputDecoration(hintText: 'Minimum kcal'),
        onChanged: (v) => _calorieFloor = v,
      ),
      const SizedBox(height: 32),

      // — Training prefs
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
              )),
      const SizedBox(height: 24),

      const Text(
        'Preferred protein intake',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ...['Low', 'Moderate', 'High', 'Very high']
          .map((opt) => RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _proteinPreference,
                onChanged: (v) => setState(() => _proteinPreference = v!),
              )),
    ],
  );
}


Widget _buildNutritionGoalPage() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // — Top summary cards —
      Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.green.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TODO: replace with actual daily budget
                    Text(
                      '2025 kcal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'initial daily budget',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              color: Colors.grey.shade800,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TODO: replace with calculated end date
                    Text(
                      '${_projectedEndDate.month}/${_projectedEndDate.day}/${_projectedEndDate.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'projected end date',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 24),

      // — Target weight selector —
      const Text(
        'What is your target weight?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        '${_goalWeightValue.round()} lbs',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      Slider(
        value: _goalWeightValue,
        min: 100,
        max: 250,
        divisions: 150,
        label: '${_goalWeightValue.round()}',
        onChanged: (v) => setState(() => _goalWeightValue = v),
      ),

      const SizedBox(height: 32),

      // — Goal rate slider & stats —
      const Text(
        'What is your target goal rate?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      // TODO: swap this for a custom “standard/aggressive” selector if desired
      Slider(
        value: _weeklyRatePct,
        min: 0.1,
        max: 1.0,
        divisions: 9,
        label: '${_weeklyRatePct.toStringAsFixed(1)}% BW/wk',
        onChanged: (v) => setState(() {
          _weeklyRatePct = v;
          _weeklyRateLbs = (_goalWeightValue * v / 100);
          _monthlyRatePct = v * 4;
          _monthlyRateLbs = _weeklyRateLbs * 4;
        }),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('-${_weeklyRateLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('-${_weeklyRatePct.toStringAsFixed(1)} % BW',
                  style: const TextStyle(color: Colors.white70)),
              const Text('Per Week'),
            ],
          ),
          Column(
            children: [
              Text('-${_monthlyRateLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('-${_monthlyRatePct.toStringAsFixed(1)} % BW',
                  style: const TextStyle(color: Colors.white70)),
              const Text('Per Month'),
            ],
          ),
        ],
      ),

      const SizedBox(height: 32),

      // — Macronutrient breakdown (placeholder) —
      const Text(
        'Plan Summary',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      // TODO: replace with a real pie chart widget
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Carbs', style: TextStyle(color: Colors.green)),  
          Text('271g'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Protein', style: TextStyle(color: Colors.purple)),
          Text('120g'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Fat', style: TextStyle(color: Colors.amber)),
          Text('94g'),
        ],
      ),

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

// === NEW METHOD: Exercise section placeholder ===
Widget _buildExerciseDataPage() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.fitness_center, size: 80, color: Colors.blue),
      SizedBox(height: 16),
      Text(
        'Exercise Data',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12),
      Text('Coming soon: questions about your workout habits.'),
    ],
  );
}

// === NEW METHOD: Measurements section placeholder ===
Widget _buildMeasurementsPage() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.straighten, size: 80, color: Colors.teal),
      SizedBox(height: 16),
      Text(
        'Measurements',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12),
      Text('Coming soon: track your body measurements over time.'),
    ],
  );
}

 Widget _buildProgressPage(int currentSection) {
  final secs = _sections;
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          "Let's get started",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Your personalized program awaits', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 24),

        ...List.generate(secs.length, (i) {
          final s = secs[i];
          final hasCompleted    = i < currentSection;
          final shouldShowTick  = hasCompleted && s.included;
          final shouldShowCross = hasCompleted && !s.included;
          final isCurrent       = i == currentSection;

          Color circleBg;
          Widget inner;

          if (shouldShowTick) {
            // ✅ completed and included
            circleBg = Colors.green;
            inner    = const Icon(Icons.check, color: Colors.white);
          }
          else if (isCurrent) {
            // 🔵 the next chunk to do
            circleBg = Theme.of(context).colorScheme.primary;
            inner    = Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }
          else if (shouldShowCross) {
            // ❌ skipped *and* past
            circleBg = Colors.red;
            inner    = const Icon(Icons.close, color: Colors.white);
          }
          else {
            // ◯ future (not done, not skipped yet)
            circleBg = Colors.grey.shade400;
            inner    = Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white70),
            );
          }

          // label text—only full‑color for “done” or “current”
          final labelColor = (shouldShowTick || isCurrent)
              ? Theme.of(context).textTheme.bodyLarge!.color
              : Colors.grey;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: circleBg, child: inner),
                    if (i < secs.length - 1)
                      Container(width: 2, height: 40, color: Colors.grey.shade300),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(secs[i].title, style: TextStyle(fontSize: 16, color: labelColor)),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
      ],
    ),
  );
}

}


class _Section {
  final String title;
  final bool included;
  const _Section(this.title, this.included);
}