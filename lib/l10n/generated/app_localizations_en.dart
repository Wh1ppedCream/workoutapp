// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent% BW/wk';
  }

  @override
  String get dashboardExerciseFallback => 'Exercise';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$equipment - $_temp0';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total done';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return '$bodyPart body heatmap';
  }

  @override
  String get focusedSetsTitle => 'Focused Sets';

  @override
  String get bodyPartNeck => 'Neck';

  @override
  String get bodyPartShoulders => 'Shoulders';

  @override
  String get bodyPartChest => 'Chest';

  @override
  String get bodyPartCore => 'Core';

  @override
  String get bodyPartUpperBack => 'Upper Back';

  @override
  String get bodyPartLowerBack => 'Lower Back';

  @override
  String get bodyPartBiceps => 'Biceps';

  @override
  String get bodyPartTriceps => 'Triceps';

  @override
  String get bodyPartForearms => 'Forearms';

  @override
  String get bodyPartHips => 'Hips';

  @override
  String get bodyPartHamstrings => 'Hamstrings';

  @override
  String get bodyPartQuads => 'Quads';

  @override
  String get bodyPartCalves => 'Calves';

  @override
  String databaseSaveFile(String filename) {
    return 'Save $filename';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename was saved to your selected location.';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (production)';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1W';

  @override
  String get workoutReportRangeOneMonthShort => '1M';

  @override
  String get workoutReportRangeThreeMonthsShort => '3M';

  @override
  String get workoutReportRangeSixMonthsShort => '6M';

  @override
  String get workoutReportRangeOneYearShort => '1Y';

  @override
  String get workoutReportRangeAll => 'All';

  @override
  String get workoutReportRangeOneWeek => '1 Week';

  @override
  String get workoutReportRangeOneMonth => '1 Month';

  @override
  String get workoutReportRangeThreeMonths => '3 Months';

  @override
  String get workoutReportRangeSixMonths => '6 Months';

  @override
  String get workoutReportRangeOneYear => '1 Year';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
      zero: '0 workouts',
    );
    return '$_temp0';
  }

  @override
  String workoutReportMinutesCount(int count) {
    return '$count min';
  }

  @override
  String workoutReportHoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String workoutReportHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get workoutReportMinuteShort => 'min';

  @override
  String get workoutReportHourShort => 'hr';

  @override
  String get workoutReportNoWorkoutsYet => 'No workouts yet';

  @override
  String get workoutReportNoTrainingTimeYet => 'No training time yet';

  @override
  String get workoutReportNoVolumeYet => 'No volume logged yet';

  @override
  String get workoutReportNoWorkoutsBody => 'Complete a workout to start building this report.';

  @override
  String get workoutReportNoTrainingTimeBody => 'Finished sessions will add minutes here automatically.';

  @override
  String get workoutReportNoVolumeBody => 'Log weights in completed sets to build volume trends.';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'UI & Appearance';

  @override
  String get uiAppearanceSubtitle => 'Control the way Tonos looks and how the bottom tabs behave.';

  @override
  String get displaySettingsTitle => 'Display';

  @override
  String get displaySettingsSubtitle => 'Quick visual preferences.';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use the darker app theme.';

  @override
  String get replayOnboardingTitle => 'Replay Onboarding';

  @override
  String get replayOnboardingSubtitle => 'Turn this on to open setup again. It turns off after completion.';

  @override
  String get weightUnitsTitle => 'Weight Units';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'Show workout weights and volume in $unit.';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the language Tonos uses.';

  @override
  String get systemDefaultLanguage => 'System default';

  @override
  String get englishLanguage => 'English';

  @override
  String get canadianFrenchLanguage => 'Français (Canada)';

  @override
  String get navigationSettingsTitle => 'Navigation';

  @override
  String get navigationSettingsSubtitle => 'Choose which bottom tabs show up and in what order.';

  @override
  String get editBottomTabsTitle => 'Edit Bottom Tabs';

  @override
  String get editBottomTabsSubtitle => 'Reorder active tabs or hide unused ones.';

  @override
  String get displaySettingsTutorialTitle => 'Display settings';

  @override
  String get displaySettingsTutorialBody => 'Control dark mode, language, replay onboarding, and switch between pounds and kilograms.';

  @override
  String get bottomTabsTutorialTitle => 'Bottom tabs';

  @override
  String get bottomTabsTutorialBody => 'Edit which bottom tabs are shown and the order they appear in.';

  @override
  String get onboardingPageWelcome => 'Welcome';

  @override
  String get onboardingPageBasics => 'Basics';

  @override
  String get onboardingPageFocus => 'Focus';

  @override
  String get onboardingPageGymProfile => 'Gym Profile';

  @override
  String get onboardingPageEquipment => 'Equipment';

  @override
  String get onboardingPageWorkoutPlan => 'Workout Plan';

  @override
  String get onboardingPagePlanOverview => 'Plan Overview';

  @override
  String get onboardingPageSummary => 'Summary';

  @override
  String get onboardingPreviousStepTooltip => 'Previous step';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingFinishing => 'Finishing...';

  @override
  String get onboardingFinishSetup => 'Finish Setup';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkipSetupTitle => 'Skip setup?';

  @override
  String get onboardingSkipSetupBody => 'You can skip to the app homepage now and finish setup later. You can also reopen onboarding from the settings page.';

  @override
  String get onboardingCancel => 'Cancel';

  @override
  String get onboardingConfirm => 'OK';

  @override
  String onboardingFinishError(String error) {
    return 'Could not finish setup: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to Tonos';

  @override
  String get onboardingWelcomeSubtitle => 'A quick setup helps personalize workouts, nutrition, and progress tracking.';

  @override
  String get onboardingLanguageSelectionTitle => 'Choose your language';

  @override
  String get onboardingLanguageSelectionHelp => 'Setup updates immediately. You can change this later in Settings.';

  @override
  String get onboardingTrainFeatureTitle => 'Train with context';

  @override
  String get onboardingTrainFeatureBody => 'Use your preferences and history to shape workout suggestions.';

  @override
  String get onboardingNutritionFeatureTitle => 'Support nutrition goals';

  @override
  String get onboardingNutritionFeatureBody => 'Set the level of nutrition guidance you want from the app.';

  @override
  String get onboardingProgressFeatureTitle => 'Track progress';

  @override
  String get onboardingProgressFeatureBody => 'Keep your training and nutrition data connected over time.';

  @override
  String get onboardingBasicsTitle => 'Tell us the basics';

  @override
  String get onboardingBasicsSubtitle => 'These details are optional, but they help future calculations.';

  @override
  String get onboardingNameLabel => 'Name';

  @override
  String get onboardingNameHint => 'Enter your name';

  @override
  String get onboardingGenderLabel => 'Gender';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderOther => 'Other';

  @override
  String get onboardingGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get onboardingDateOfBirthLabel => 'Date of birth';

  @override
  String get onboardingSelectDate => 'Select date';

  @override
  String get onboardingHeightLabel => 'Height';

  @override
  String get onboardingHeightHint => 'e.g. 5\'10\" or 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => 'Workout weight units';

  @override
  String get onboardingCurrentWeightLabel => 'Current weight';

  @override
  String get onboardingWeightHintPounds => 'e.g. 160';

  @override
  String get onboardingWeightHintKilograms => 'e.g. 72';

  @override
  String get onboardingPounds => 'Pounds';

  @override
  String get onboardingKilograms => 'Kilograms';

  @override
  String get onboardingFocusTitle => 'What should Tonos personalize?';

  @override
  String get onboardingFocusSubtitle => 'Choose the areas you want to set up now. You can change this later.';

  @override
  String get onboardingNutritionDataTitle => 'Nutrition data';

  @override
  String get onboardingNutritionDataPausedBody => 'Nutrition setup is paused while this area is rebuilt.';

  @override
  String get onboardingLater => 'Later';

  @override
  String get onboardingExerciseDataTitle => 'Exercise data';

  @override
  String get onboardingExerciseDataBody => 'Set up your gym profile and first workout plans.';

  @override
  String get onboardingGymSpaceTitle => 'Where do you work out?';

  @override
  String get onboardingGymSpaceSubtitle => 'Choose a starting space. Its equipment will shape exercise suggestions and generated workouts.';

  @override
  String get onboardingEquipmentLoadError => 'Equipment could not be loaded.';

  @override
  String get onboardingTryAgain => 'Try again';

  @override
  String get onboardingGymCustomTitle => 'Customized Space';

  @override
  String get onboardingGymCustomSubtitle => 'Design your own profile by choosing every available item.';

  @override
  String get onboardingGymCustomDefaultName => 'Custom Space';

  @override
  String get onboardingGymSkipTitle => 'Skip this step';

  @override
  String get onboardingGymSkipSubtitle => 'Keep the General profile and choose your equipment later.';

  @override
  String get onboardingGymGeneralName => 'General';

  @override
  String get onboardingGymCommercialTitle => 'Commercial Gym';

  @override
  String get onboardingGymCommercialSubtitle => 'Start with every available equipment option, then remove anything your gym does not have.';

  @override
  String get onboardingGymCommercialDefaultName => 'Commercial Gym';

  @override
  String get onboardingGymHomeTitle => 'Home Gym';

  @override
  String get onboardingGymHomeSubtitle => 'A practical home setup with free weights, bands, a bench, and bodyweight equipment.';

  @override
  String get onboardingGymHomeDefaultName => 'Home Gym';

  @override
  String get onboardingGymCalisthenicsTitle => 'Calisthenics';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'Bodyweight-focused equipment including bars, rings, bands, and basic accessories.';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'Calisthenics';

  @override
  String get onboardingGymPowerliftingTitle => 'Powerlifting';

  @override
  String get onboardingGymPowerliftingSubtitle => 'A barbell-based space with plates, a power rack, and a bench.';

  @override
  String get onboardingGymPowerliftingDefaultName => 'Powerlifting';

  @override
  String get onboardingGymFreeWeightsTitle => 'Free Weights';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'Dumbbells, kettlebells, plates, a bench, and bodyweight movements.';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'Free Weights';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'Review your workout space';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Rename the profile or adjust its equipment before Tonos creates it.';

  @override
  String get onboardingProfileNameLabel => 'Profile name';

  @override
  String get onboardingIncludedEquipmentTitle => 'Included equipment';

  @override
  String get onboardingIncludedEquipmentBody => 'Only exercises supported by this equipment will be suggested when the profile is active.';

  @override
  String get onboardingNoEquipmentSelected => 'No equipment selected yet.';

  @override
  String get onboardingReset => 'Reset';

  @override
  String get onboardingEditProfile => 'Edit profile';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'Edit Workout Space';

  @override
  String get onboardingSelectEquipmentError => 'Select at least one equipment option.';

  @override
  String get onboardingWorkoutPlanTitle => 'Set up your workout plan';

  @override
  String get onboardingWorkoutPlanSubtitle => 'Choose how Tonos should prepare your first plans. You can always add, archive, or edit plans later.';

  @override
  String get onboardingManualPlanTitle => 'Manually create your own plans';

  @override
  String get onboardingManualPlanSubtitle => 'Start with a blank plan, then add exercises and sets yourself.';

  @override
  String get onboardingPremadePlanTitle => 'Use premade exercise plans';

  @override
  String get onboardingPremadePlanSubtitle => 'Browse built-in full body, upper/lower, push-pull-legs, and body-part split plans.';

  @override
  String get onboardingGeneratePlanTitle => 'Generate exercise plans';

  @override
  String get onboardingGeneratePlanSubtitle => 'Answer a few setup questions and let Tonos generate a custom plan for your profile.';

  @override
  String get onboardingSkipPlanTitle => 'Skip this step';

  @override
  String get onboardingSkipPlanSubtitle => 'Start without adding plans. You can set them up from Train later.';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans have been added to Active Plans.',
      one: '$count plan has been added to Active Plans.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'Review your plans';

  @override
  String get onboardingReviewPlansSubtitle => 'These plans were added to your active plans. Open any plan to inspect or adjust it before continuing.';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans are ready in Active Plans.',
      one: '$count plan is ready in Active Plans.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'Could not load plan overview yet.';

  @override
  String get onboardingNoAddedPlans => 'No added plans were found. Go back to add plans, or skip this step.';

  @override
  String get onboardingReadyTitle => 'Ready to start';

  @override
  String get onboardingReadySubtitle => 'Review your setup, then finish to enter Tonos.';

  @override
  String get onboardingSummaryName => 'Name';

  @override
  String get onboardingSummaryGender => 'Gender';

  @override
  String get onboardingSummaryDateOfBirth => 'DOB';

  @override
  String get onboardingSummaryHeight => 'Height';

  @override
  String get onboardingSummaryWeight => 'Weight';

  @override
  String get onboardingSummaryWorkoutUnits => 'Workout units';

  @override
  String get onboardingSummaryIncluded => 'Included';

  @override
  String get onboardingSummaryGymProfile => 'Gym profile';

  @override
  String get onboardingSummaryEquipment => 'Equipment';

  @override
  String get onboardingSummaryWorkoutPlans => 'Workout plans';

  @override
  String get onboardingSummaryProfileSection => 'Profile';

  @override
  String get onboardingSummaryTrainingSection => 'Training setup';

  @override
  String get onboardingSummaryNutritionSection => 'Nutrition preferences';

  @override
  String get onboardingSummaryDiet => 'Diet';

  @override
  String get onboardingSummaryProteinPreference => 'Protein preference';

  @override
  String get onboardingIncludedNutrition => 'Nutrition setup';

  @override
  String get onboardingIncludedExercise => 'Exercise setup';

  @override
  String get onboardingIncludedBasicOnly => 'Basic profile only';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans added',
      one: '$count plan added',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'Premade selected';

  @override
  String get onboardingPlanSummaryGenerated => 'Generate selected';

  @override
  String get onboardingPlanSummarySkipped => 'Skipped';

  @override
  String get onboardingPlanSummaryManual => 'Manual selected';

  @override
  String get onboardingPlanSummaryNotSelected => 'Not selected';

  @override
  String get onboardingNewPlan => 'New Plan';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'New Plan $number';
  }

  @override
  String get tabTrain => 'Train';

  @override
  String get tabTrainSecondary => 'Train2';

  @override
  String get tabCatalog => 'Catalog';

  @override
  String get tabLogbook => 'Logbook';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabNutrition => 'Nutrition';

  @override
  String get tabNutritionLog => 'Nutrition Log';

  @override
  String get tabCombinedHistory => 'Combined History';

  @override
  String get tabFormAndPosing => 'Form and Posing';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Personalize Tonos, manage training defaults, and keep your data healthy.';

  @override
  String get profileAccountSectionTitle => 'Account';

  @override
  String get profileAccountSectionSubtitle => 'Your identity and app-level appearance.';

  @override
  String get profileUserInformationTitle => 'User Information';

  @override
  String get profileUserInformationSubtitle => 'Name, body details, and activity profile.';

  @override
  String get profileUiAppearanceTitle => 'UI & Appearance';

  @override
  String get profileUiAppearanceSubtitle => 'Theme, onboarding, and bottom tab setup.';

  @override
  String get profileGuidedTutorialsTitle => 'Guided Tutorials';

  @override
  String get profileGuidedTutorialsSubtitle => 'Replay walkthroughs and reset guided help.';

  @override
  String get profileTrainingSectionTitle => 'Training';

  @override
  String get profileTrainingSectionSubtitle => 'Exercise defaults and progress-related controls.';

  @override
  String get profileGymWorkoutSettingsTitle => 'Gym & Workout Settings';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'Workout generation, rankings, flows, and equipment logic.';

  @override
  String get profileProgressSettingsTitle => 'Progress Settings';

  @override
  String get profileProgressSettingsSubtitle => 'Measurement and trend tracking setup.';

  @override
  String get profileDataSectionTitle => 'Data';

  @override
  String get profileDataSectionSubtitle => 'Database tools, exports, imports, and maintenance.';

  @override
  String get profileDatabaseSettingsTitle => 'Database Settings';

  @override
  String get profileDatabaseSettingsSubtitle => 'Import, export, health checks, and maintenance tools.';

  @override
  String get profileNutritionSectionTitle => 'Nutrition';

  @override
  String get profileNutritionSectionSubtitle => 'Nutrition settings are paused while this area is rebuilt.';

  @override
  String get profileDietNutritionSettingsTitle => 'Diet & Nutrition Settings';

  @override
  String get profileDietNutritionSettingsSubtitle => 'Nutrition goals and preferences will return later.';

  @override
  String get profileLater => 'Later';

  @override
  String get profileAccountTutorialTitle => 'Account settings';

  @override
  String get profileAccountTutorialBody => 'Update your personal info, display preferences, weight units, onboarding, bottom tabs, and guided tutorials from here.';

  @override
  String get profileTrainingTutorialTitle => 'Training settings';

  @override
  String get profileTrainingTutorialBody => 'Control gym profiles, generation rules, bodypart rankings, progress settings, and other training defaults.';

  @override
  String get profileDataTutorialTitle => 'Data tools';

  @override
  String get profileDataTutorialBody => 'Database settings are where you export, import, check, and maintain your local workout data.';

  @override
  String catalogLoadError(String error) {
    return 'Unable to load catalog: $error';
  }

  @override
  String get catalogNoData => 'No catalog data available yet.';

  @override
  String get catalogExerciseTitle => 'Exercise Catalog';

  @override
  String get catalogMostUsedExercises => 'Most used exercises';

  @override
  String get catalogNoExerciseHistory => 'Complete workouts to see your most common exercises here.';

  @override
  String get catalogTargetAnatomyTitle => 'Target Anatomy';

  @override
  String get catalogBodyparts => 'Bodyparts';

  @override
  String get catalogMuscles => 'Muscles';

  @override
  String get catalogNoBodypartHistory => 'No bodypart history yet.';

  @override
  String get catalogNoMuscleHistory => 'No muscle history yet.';

  @override
  String get catalogExerciseTutorialTitle => 'Exercise catalog';

  @override
  String get catalogExerciseTutorialBody => 'Your most used exercises show here first. Tap the card to open the full catalog, search movements, and review exercise details.';

  @override
  String get catalogAnatomyTutorialTitle => 'Target Anatomy';

  @override
  String get catalogAnatomyTutorialBody => 'This summarizes your most trained bodyparts and muscles. Tap either side to open the anatomy library for focused exercise lists.';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'Please keep at least two active tabs.';

  @override
  String get navEditorSavedMessage => 'Bottom tabs saved';

  @override
  String get navEditorTitle => 'Edit Bottom Tabs';

  @override
  String get navEditorSubtitle => 'Choose what appears in the bottom bar and reorder active tabs.';

  @override
  String get navEditorSave => 'Save Tabs';

  @override
  String get navEditorActiveTitle => 'Active Tabs';

  @override
  String get navEditorActiveSubtitle => 'Drag to reorder. Profile stays available.';

  @override
  String get navEditorInactiveTitle => 'Inactive Tabs';

  @override
  String get navEditorInactiveSubtitle => 'Turn these on whenever you want them back.';

  @override
  String get navEditorNoInactiveTabs => 'No inactive tabs.';

  @override
  String get navEditorAlwaysShown => 'Always shown';

  @override
  String get navEditorVisible => 'Visible in bottom navigation';

  @override
  String get navEditorHidden => 'Hidden from bottom navigation';

  @override
  String get trainTutorialSpacesTitle => 'Train has two spaces';

  @override
  String get trainTutorialSpacesBody => 'Overview keeps your ready-to-use workout controls up front. Plans is where you browse, generate, and manage your saved plans.';

  @override
  String get trainTutorialWeeklyTitle => 'Weekly overview';

  @override
  String get trainTutorialWeeklyBody => 'This shows what bodyparts you have trained recently. Tap the focused sets list to open the full weekly sets breakdown.';

  @override
  String get trainTutorialActivePlansTitle => 'Active plans';

  @override
  String get trainTutorialActivePlansBody => 'Active plans are the routines you want close at hand. Use the pen to choose which plans stay ready on the Overview tab.';

  @override
  String get trainTutorialStartTitle => 'Start or optimize';

  @override
  String get trainTutorialStartBody => 'Start Workout begins a blank session. Optimize builds a session from your history, profile equipment, focus, and recovery rules.';

  @override
  String get trainTutorialProfilesTitle => 'Gym profiles';

  @override
  String get trainTutorialProfilesBody => 'Switch profiles when you train somewhere different so generated workouts and exercise swaps only use available equipment.';

  @override
  String get trainSelectProfileFirst => 'Please select a gym profile first.';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generated $count plans.',
      one: 'Generated 1 plan.',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'New Plan $number',
      one: 'New Plan',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'Optimized workout $date $time';
  }

  @override
  String get trainRestTitle => 'Take some time to rest';

  @override
  String get trainRestBody => 'Your recent training is already at several bodypart limits, so an optimized workout would push recovery too far.';

  @override
  String get commonOkay => 'OK';

  @override
  String get trainNoEligibleExercises => 'No eligible exercises were found for this profile.';

  @override
  String get trainAnotherWorkoutActive => 'Another workout is already active, so it was kept unchanged.';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'Failed to start optimized workout: $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    return 'Optimized workout started. $count exercise(s) still need manual weights.';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    return 'Optimized workout started with starter weights for $count new exercise(s).';
  }

  @override
  String get trainGymProfilesTooltip => 'Gym profiles';

  @override
  String get trainOverviewTab => 'Overview';

  @override
  String get trainPlansTab => 'Plans';

  @override
  String get trainActivePlans => 'Active Plans';

  @override
  String get trainEditActivePlans => 'Edit active plans';

  @override
  String get trainSelectProfileForPlans => 'Select a gym profile to choose active plans.';

  @override
  String get trainChooseActivePlans => 'Tap the pen to choose which plans show here.';

  @override
  String get trainSelectedPlansMissing => 'Selected plans are no longer available. Tap the pen to update them.';

  @override
  String get trainArchivedPlans => 'Archived Plans';

  @override
  String get trainNoActivePlans => 'No active plans yet. Use the pen on the Overview Active Plans card to choose what stays ready.';

  @override
  String get trainNoArchivedPlans => 'No archived plans.';

  @override
  String get trainManagePlans => 'Manage plans';

  @override
  String get trainPremadePlans => 'Premade Plans';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curated routines are available to copy into your plans.',
      one: '1 curated routine is available to copy into your plans.',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'Browse Premade Plans';

  @override
  String get trainGenerateCustomPlans => 'Generate Custom Plans';

  @override
  String get trainManuallyAddPlan => 'Manually Add Plan';

  @override
  String get trainStartWorkout => 'Start Workout';

  @override
  String get trainOptimize => 'Optimize';

  @override
  String get trainOptimizedSettings => 'Optimized workout settings';

  @override
  String planManagementDefaultName(int id) {
    return 'Plan $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'Active plans';

  @override
  String get planManagementActiveTutorialBody => 'These plans stay visible on the Train overview. Use Archive when you want to hide one without deleting it.';

  @override
  String get planManagementArchivedTutorialTitle => 'Archived plans';

  @override
  String get planManagementArchivedTutorialBody => 'Archived plans are still saved. Activate any plan here when you want it back on the overview.';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return 'Could not update $plan: $error';
  }

  @override
  String get planManagementTitle => 'Manage Plans';

  @override
  String get planManagementLoadFailed => 'Unable to load plans';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get planManagementIntro => 'Choose what stays ready on your Train overview. Archived plans are still saved and can be activated anytime.';

  @override
  String get planManagementActiveSubtitle => 'Shown on the Train overview.';

  @override
  String get planManagementNoActive => 'No active plans yet. Activate a plan below to pin it to the overview.';

  @override
  String get planManagementArchive => 'Archive';

  @override
  String get planManagementArchivedSubtitle => 'Saved plans that stay out of the overview.';

  @override
  String get planManagementNoArchived => 'No archived plans.';

  @override
  String get planManagementActivate => 'Activate';

  @override
  String get planManagementAutomatic => 'Automatic plan';

  @override
  String get planManagementVisible => 'Visible on overview';

  @override
  String get planManagementHidden => 'Hidden from overview';

  @override
  String get presetsNoPlans => 'No plans found.';

  @override
  String get presetsNoProfile => 'No profile selected.';

  @override
  String get presetsLoadError => 'Error loading plans';

  @override
  String presetsShowMore(int count) {
    return 'Show $count more';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return 'Show $count more ($remaining left)';
  }

  @override
  String planDefaultName(int number) {
    return 'Plan $number';
  }

  @override
  String get planArchive => 'Archive';

  @override
  String get planActivate => 'Activate';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRename => 'Rename';

  @override
  String get planActivated => 'Plan activated.';

  @override
  String get planArchived => 'Plan archived.';

  @override
  String get planDeleteTitle => 'Delete Preset';

  @override
  String get planDeleteConfirmation => 'Are you sure you want to delete this plan?';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get planRenameTitle => 'Rename Plan';

  @override
  String get planNameLabel => 'Plan Name';

  @override
  String get optimizedTutorialBudgetTitle => 'Session budget';

  @override
  String get optimizedTutorialBudgetBody => 'Set how long the optimized workout should be and how many sets each exercise can receive.';

  @override
  String get optimizedTutorialRepsTitle => 'Reps and weight';

  @override
  String get optimizedTutorialRepsBody => 'These choices control the set pattern, target reps, and how conservative generated weights should be.';

  @override
  String get optimizedTutorialFocusTitle => 'Bodypart focus';

  @override
  String get optimizedTutorialFocusBody => 'Prefer or avoid bodyparts for the next optimized workout without changing your saved rankings.';

  @override
  String get commonReset => 'Reset';

  @override
  String get optimizedTutorialResetBody => 'Reset brings this page back to Tonos defaults if the current setup feels off.';

  @override
  String get optimizedTutorialActionsTitle => 'Save or start';

  @override
  String get optimizedTutorialActionsBody => 'Start Now uses the current on-screen values once. Save keeps the settings for future optimized workouts.';

  @override
  String optimizedValidationError(int maxSets) {
    return 'Enter a valid duration, rep target, and set range between 1-$maxSets.';
  }

  @override
  String get optimizedBudgetDescription => 'Used to budget 3 minutes per set plus 5 minutes to start each exercise.';

  @override
  String get optimizedWorkoutDuration => 'Workout duration';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get optimizedMinimumSets => 'Minimum sets per exercise';

  @override
  String get optimizedMaximumSets => 'Up to sets per exercise';

  @override
  String get unitSets => 'sets';

  @override
  String get optimizedRepsWeightsTitle => 'Reps & weights';

  @override
  String get optimizedRepsWeightsDescription => 'Uses history-based strength estimates when available, with Easy and Medium backing off more than Hard. New exercises use conservative starter estimates.';

  @override
  String get optimizedRepPattern => 'Rep pattern';

  @override
  String get repModeMixed => 'Mixed';

  @override
  String get repModePyramid => 'Pyramid';

  @override
  String get repModeConsistent => 'Consistent';

  @override
  String get optimizedTargetReps => 'Target reps';

  @override
  String get unitReps => 'reps';

  @override
  String get optimizedWeightIntensity => 'Weight intensity';

  @override
  String get intensityEasy => 'Easy';

  @override
  String get intensityMedium => 'Medium';

  @override
  String get intensityHard => 'Hard';

  @override
  String get optimizedBodypartFocusTitle => 'Bodypart focus';

  @override
  String get optimizedBodypartFocusDescription => 'These picks apply only to the next optimized workout you start. Tap once to prefer, tap twice to avoid, and tap again to clear.';

  @override
  String get optimizedBodypartsUnavailable => 'Bodyparts could not be loaded.';

  @override
  String get commonStartNow => 'Start Now';

  @override
  String get commonSave => 'Save';

  @override
  String get generateTutorialIntroTitle => 'Build plans';

  @override
  String get generateTutorialIntroBody => 'This page can create one plan or a balanced weekly bundle using your gym profile and training preferences.';

  @override
  String get generateWorkoutSetupTitle => 'Workout setup';

  @override
  String get generateTutorialSetupBody => 'Set session length, how many plans to create, and the maximum sets allowed for each exercise.';

  @override
  String get generateTrainingFocusTitle => 'Training focus';

  @override
  String get generateTutorialFocusBody => 'Prefer or avoid bodyparts here. The 7-day history toggle only biases generation when you want recent training considered.';

  @override
  String get generateRepsWeightsTitle => 'Reps & weights';

  @override
  String get generateTutorialRepsBody => 'Choose pyramid, mixed, or consistent set patterns plus the target reps and starter weight intensity.';

  @override
  String get generateSetAllocationTitle => 'Set allocation';

  @override
  String get generateTutorialAllocationBody => 'Pick whether sets are spread evenly or biased toward your bodypart or muscle rankings.';

  @override
  String get generateTutorialGenerateTitle => 'Generate';

  @override
  String get generateTutorialGenerateBody => 'When everything looks right, generate the plan or plan bundle. New plans can be reviewed and edited afterward.';

  @override
  String get generateValidationError => 'Please enter valid duration, plan count, set limit, and rep values.';

  @override
  String get generateNoViablePlans => 'No viable plans could be generated with the current settings.';

  @override
  String generateFailed(String error) {
    return 'Failed to generate plans: $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'Could not discard generated plans: $error';
  }

  @override
  String get generateIntroTitle => 'Build your plan week';

  @override
  String get generateIntroBody => 'Create one plan or a balanced bundle using your profile, focus, and limits.';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans',
      one: '1 plan',
    );
    return '$_temp0';
  }

  @override
  String generateDurationPill(String minutes) {
    return '$minutes min';
  }

  @override
  String generateMaxSetsPill(String sets) {
    return '$sets sets max';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans plan(s), $minutes min, $sets max sets';
  }

  @override
  String get generateSessionLength => 'Session length';

  @override
  String get generateSessionLengthHelp => 'Estimated as 3 min/set + 5 min/exercise.';

  @override
  String get generatePlansToCreate => 'Plans to create';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'Usually matches training days/week. Max $maxPlans.';
  }

  @override
  String get unitPlans => 'plans';

  @override
  String get generateMaxSetsPerExercise => 'Max sets per exercise';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return '$minSets-$maxSets sets allowed.';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred preferred, $avoided avoided, $history 7-day history';
  }

  @override
  String get generateHistoryUsing => 'using';

  @override
  String get generateHistoryNotUsing => 'not using';

  @override
  String get generateUseRecentTraining => 'Use recent training';

  @override
  String get generateUseRecentTrainingBody => 'Bias toward under-trained areas from the last 7 days.';

  @override
  String get generateBodypartFocusInstruction => 'Tap once to prefer, twice to avoid, third to clear.';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps reps, $intensity intensity';
  }

  @override
  String get generateMixedBody => 'Pyramid for 3+ sets; steady for shorter work.';

  @override
  String get generatePyramidBody => 'Peak set uses the generated working weight.';

  @override
  String get generateConsistentBody => 'Same reps and suggested weight each set.';

  @override
  String get generateTargetRepsHelp => 'Peak reps for pyramid; steady reps otherwise.';

  @override
  String get generateEasyBody => 'Most conservative history or starter recommendation.';

  @override
  String get generateMediumBody => 'Balanced working-weight recommendation.';

  @override
  String get generateHardBody => 'Heaviest recommendation, still rounded and effort-aware.';

  @override
  String get generateRequirementBodyparts => 'Bodypart rankings';

  @override
  String get generateRequirementMuscles => 'Muscle rankings';

  @override
  String get generateRequirementEven => 'Even coverage';

  @override
  String get generateEvenCoverageTitle => 'Even bodypart coverage';

  @override
  String get generateEvenCoverageBody => 'Spread work broadly across available bodyparts.';

  @override
  String get generateBodypartRankingsTitle => 'Use bodypart rankings';

  @override
  String get generateBodypartRankingsBody => 'Give higher-ranked bodyparts more planned work.';

  @override
  String get generateRankBodyparts => 'Rank Body Parts';

  @override
  String get generateMuscleRankingsTitle => 'Use muscle rankings';

  @override
  String get generateMuscleRankingsBody => 'Allocate work from your ranked muscle priorities.';

  @override
  String get generateRankMuscles => 'Rank Muscles';

  @override
  String get generateGenerating => 'Generating...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generate $count plans',
      one: 'Generate plan',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return 'Generated $generated of $requested plans. Your current settings limited the rest.';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generated $count plans. Review them when ready.',
      one: 'Generated plan added. Review it when ready.',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '$count more';
  }

  @override
  String get generateStarterEstimatedBody => 'Starter weights were estimated for new exercises. Adjust as needed after your first set.';

  @override
  String get generateStarterUnavailableBody => 'Some exercises still need manual weights because no safe starter estimate is available yet.';

  @override
  String get generateStarterDialogTitle => 'Starter weights added';

  @override
  String get generatePageTitle => 'Generate Plans';

  @override
  String get generateDiscarding => 'Discarding...';

  @override
  String get generateReviewPlans => 'Review Plans';

  @override
  String get sessionTutorialCardsTitle => 'Exercise cards';

  @override
  String get sessionTutorialCardsBody => 'Each card holds one exercise. Open it to edit weights and reps, then tick sets off as you complete them.';

  @override
  String get sessionTutorialAddTitle => 'Add exercises';

  @override
  String get sessionTutorialAddBody => 'Use this button when you want to add another exercise from the catalog during the workout.';

  @override
  String get sessionTutorialFinishTitle => 'Finish workout';

  @override
  String get sessionTutorialFinishBody => 'When you are done, finish the session so Tonos can save the workout and update your history, analytics, and progress widgets.';

  @override
  String get sessionTimerTitle => 'Workout Timer';

  @override
  String get sessionTitle => 'Workout Session';

  @override
  String get sessionNoExercises => 'No exercises added.';

  @override
  String get sessionNeedCompletedSet => 'Complete at least one set before finishing the workout.';

  @override
  String sessionSaveFailed(String error) {
    return 'Could not save workout. Your ongoing workout is still available. $error';
  }

  @override
  String get sessionFinishWorkout => 'Finish Workout';

  @override
  String get sessionResume => 'Resume';

  @override
  String get sessionExit => 'Exit';

  @override
  String get sessionCompletedSaved => 'Completed work saved to Logbook.';

  @override
  String get sessionCancelled => 'Workout cancelled.';

  @override
  String sessionEndFailed(String error) {
    return 'Could not end workout: $error';
  }

  @override
  String get sessionCancelQuestion => 'Cancel workout?';

  @override
  String get sessionCancelBody => 'This removes the ongoing workout without adding it to your history.';

  @override
  String get sessionKeepWorkout => 'Keep Workout';

  @override
  String get sessionCancelWorkout => 'Cancel Workout';

  @override
  String get sessionEndQuestion => 'End workout?';

  @override
  String get sessionCancelDelete => 'Cancel and Delete';

  @override
  String get sessionEndSave => 'End and Save Workout';

  @override
  String get sessionRememberChoice => 'Remember choice';

  @override
  String get sessionRememberChoiceBody => 'Change this later in Gym & Workout Settings.';

  @override
  String get sessionCompleteLoadError => 'Error loading session';

  @override
  String get sessionCompleteTitle => 'WORKOUT COMPLETE';

  @override
  String get sessionMetricExercises => 'Exercises';

  @override
  String get sessionMetricSets => 'Sets';

  @override
  String get sessionMetricDuration => 'Duration';

  @override
  String get sessionMetricVolume => 'Volume';

  @override
  String get commonDone => 'Done';

  @override
  String get recordMonthly => 'Monthly';

  @override
  String get recordAllTime => 'All Time';

  @override
  String get recordFirst => 'First Record';

  @override
  String recordRepBest(int reps) {
    return '$reps Rep Best';
  }

  @override
  String get recordVolumeBest => 'Best Volume';

  @override
  String sessionEstimatedMax(String weight) {
    return 'ERM=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationHoursCompact(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get planUnsavedChangesTitle => 'Unsaved Changes';

  @override
  String get planDiscardChangesQuestion => 'Discard changes?';

  @override
  String get planDiscard => 'Discard';

  @override
  String get planTutorialEditTitle => 'Edit plan';

  @override
  String get planTutorialEditBody => 'Use this to rename the plan, reorder exercises, add exercises, swap movements, and change sets.';

  @override
  String get planTutorialSummaryTitle => 'Plan summary';

  @override
  String get planTutorialSummaryBody => 'This shows estimated time, volume, and the main bodyparts this plan targets before you start it.';

  @override
  String get planTutorialExerciseCardsTitle => 'Exercise cards';

  @override
  String get planTutorialExerciseCardsBody => 'Open exercise cards to review the planned sets. In edit mode, use the menu to swap or remove exercises.';

  @override
  String get planTutorialStartOrSaveTitle => 'Start or save';

  @override
  String get planTutorialStartOrSaveBody => 'Start Session begins this plan as a workout. In edit mode, this changes to Save Preset so your changes are stored.';

  @override
  String get planGuideNameTitle => 'Name your plan';

  @override
  String get planGuideNameBody => 'Give this plan a name you will recognize, such as Upper Body or Day 1.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get planGuideBrowseTitle => 'Browse exercises';

  @override
  String get planGuideBrowseBody => 'Tap the + button to choose the first exercise in this plan.';

  @override
  String get planGuideWeightTitle => 'Choose a weight';

  @override
  String get planGuideWeightBody => 'Enter a starting weight for the first set. Use 0 for a bodyweight exercise.';

  @override
  String get planGuideWeightSet => 'Weight set';

  @override
  String get planGuideRepsTitle => 'Choose your reps';

  @override
  String get planGuideRepsBody => 'Enter how many repetitions you plan to perform for this set.';

  @override
  String get planGuideRepsSet => 'Reps set';

  @override
  String get planGuideAddSetTitle => 'Add more sets';

  @override
  String get planGuideAddSetBody => 'Use Add Set when you need another set. New sets start with the previous set\'s values.';

  @override
  String get planGuideSaveTitle => 'Save your plan';

  @override
  String get planGuideSaveBody => 'Tap Save Preset to keep this plan and return to the onboarding overview.';

  @override
  String planSaveFailed(String error) {
    return 'Could not save plan. The previous version is unchanged. $error';
  }

  @override
  String get planOngoingWorkoutKept => 'Your ongoing workout was kept. Finish or cancel it before starting this plan.';

  @override
  String get planDeleteBody => 'Are you sure you want to delete this preset?';

  @override
  String get planDeletePreset => 'Delete Preset';

  @override
  String get planDisableAutomatic => 'Disable Automatic';

  @override
  String get planMakeAutomatic => 'Make Automatic';

  @override
  String get planAutomaticSettings => 'Automatic Settings';

  @override
  String get planProgression => 'Plan Progression';

  @override
  String get planNoExercises => 'No exercises in this preset.';

  @override
  String get planSavePreset => 'Save Preset';

  @override
  String get planStartSession => 'Start Session';

  @override
  String get commonName => 'Name';

  @override
  String get commonBack => 'Back';

  @override
  String get flowMethodWeight => 'Weight';

  @override
  String get flowMethodReps => 'Repetitions';

  @override
  String get flowMethodAddSet => 'Add set';

  @override
  String get flowMethodDeleteSet => 'Delete set';

  @override
  String get flowAppDefaultTitle => 'App Default Progression';

  @override
  String get flowProfileDefaultTitle => 'Gym Default Progression';

  @override
  String get flowPlanSubtitle => 'Set how this plan progresses after each workout.';

  @override
  String get flowAppDefaultSubtitle => 'Set the starting progression flow for new gym profiles.';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return 'Set the starting progression flow for new plans in $profileName.';
  }

  @override
  String get flowThisGymProfile => 'this gym profile';

  @override
  String get flowManageMethods => 'Manage Actions';

  @override
  String get flowAddNewMethod => 'Add New Action';

  @override
  String get flowNewMethod => 'New Action';

  @override
  String get flowFactor => 'Factor';

  @override
  String get flowAmount => 'Amount';

  @override
  String get flowExplicit => 'Explicit';

  @override
  String get flowCopyFromSet => 'Copy from set';

  @override
  String get flowWeight => 'Weight';

  @override
  String get flowReps => 'Reps';

  @override
  String get flowSetIndex => 'Set index (-1 = last)';

  @override
  String get flowDeleteLastSetBody => 'This action will delete the last set.';

  @override
  String get flowMethodNameRequired => 'Action name cannot be empty';

  @override
  String get flowManageActionsTooltip => 'Manage progression actions';

  @override
  String get flowAddBranchTitle => 'Add a branch';

  @override
  String get flowAddBranchSubtitle => 'Choose where the next success or miss should lead.';

  @override
  String get flowBranchFrom => 'Branch From';

  @override
  String get flowSuccess => 'Success';

  @override
  String get flowMiss => 'Miss';

  @override
  String get flowAttachActionTitle => 'Attach a progression action';

  @override
  String get flowAttachActionSubtitle => 'Apply one adjustment of each type to a flow node.';

  @override
  String get flowApplyActionTo => 'Apply action to';

  @override
  String get flowProgressionAction => 'Progression action';

  @override
  String get flowAddAction => '+ Action';

  @override
  String get flowRemoveAction => '- Action';

  @override
  String get flowRemoveNode => '- Node';

  @override
  String get commonEdit => 'Edit';

  @override
  String get rulesEditAppDefault => 'Edit App Default Rule';

  @override
  String get rulesEditProfileDefault => 'Edit Profile Default Rule';

  @override
  String get rulesAddAppDefault => 'Add App Default Rule';

  @override
  String get rulesAddProfileDefault => 'Add Profile Default Rule';

  @override
  String get rulesCopy => 'Copy';

  @override
  String get rulesCopyIndex => 'Copy index';

  @override
  String get rulesDeleteLastSetBody => 'This will delete the last set.';

  @override
  String get rulesNameRequired => 'Rule name cannot be empty';

  @override
  String get rulesProfilesLowercase => 'profiles';

  @override
  String get rulesPlansLowercase => 'plans';

  @override
  String rulesAddToExistingTitle(String destination) {
    return 'Add to existing $destination?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return 'Make \"$name\" available in $count existing $destination? Existing rules with the same name and all saved progression flows will stay unchanged.';
  }

  @override
  String get rulesNotNow => 'Not now';

  @override
  String rulesAddTo(String destination) {
    return 'Add to $destination';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'No existing $destination needed this rule.';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return 'Added \"$name\" to $count $destination.';
  }

  @override
  String get rulesPropagationFailed => 'Could not add the rule to existing items.';

  @override
  String get rulesOptionsTooltip => 'Rule options';

  @override
  String get rulesPageTitle => 'Workout Progress Rules';

  @override
  String get rulesPageSubtitle => 'Create reusable rules for how weights, reps, and sets change after workout attempts.';

  @override
  String get rulesHowDefaultsTitle => 'How defaults work';

  @override
  String get rulesHowDefaultsBody => 'App defaults are copied into new gym profiles. Profile defaults are copied into new plans, so later edits do not unexpectedly rewrite existing plans.';

  @override
  String get rulesAppDefaultsTitle => 'App-wide defaults';

  @override
  String get rulesAppDefaultsSubtitle => 'The starting rules for new gym profiles.';

  @override
  String get rulesNoAppDefaults => 'No app-wide rules have been created yet.';

  @override
  String get rulesAddApp => 'Add app rule';

  @override
  String get rulesGymProfilesTitle => 'Gym profiles';

  @override
  String get rulesGymProfilesSubtitle => 'Each profile keeps its defaults and plan rules together.';

  @override
  String get rulesNoProfiles => 'Create a gym profile to add profile and plan rules.';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules profile rules • $planRules plan rules';
  }

  @override
  String get rulesProfileDefaultsTitle => 'Profile defaults';

  @override
  String get rulesProfileDefaultsSubtitle => 'Starting rules for new plans in this profile.';

  @override
  String get rulesNoProfileDefaults => 'This profile has no default rules.';

  @override
  String get rulesAddProfile => 'Add profile rule';

  @override
  String get rulesPlansTitle => 'Plans';

  @override
  String get rulesNoPlans => 'No plans belong to this gym profile yet.';

  @override
  String get rulesPlanOnlySubtitle => 'Rules used only by this plan.';

  @override
  String get rulesNoPlanRules => 'This plan has no specific progression rules.';

  @override
  String get rulesAddPlan => 'Add plan rule';

  @override
  String get rulesAppDefaultsChip => 'App defaults';

  @override
  String get rulesProfilesChip => 'Profiles';

  @override
  String get rulesPlansChip => 'Plans';

  @override
  String get rulesEditPlan => 'Edit Rule';

  @override
  String get rulesAddPlanTitle => 'Add Rule';

  @override
  String get commonRetry => 'Retry';

  @override
  String get flowPageTitle => 'Workout Progress Flows';

  @override
  String get flowPageSubtitle => 'Set the paths that decide how progression actions are applied after workout results.';

  @override
  String get flowHowCopiedTitle => 'How flows are copied';

  @override
  String get flowHowCopiedBody => 'App flows become the starting point for new gym profiles. Gym flows become the starting point for new plans. Later edits stay scoped to the flow you open here.';

  @override
  String get flowLoadError => 'Workout progression flows could not be loaded.';

  @override
  String get flowAppDefaultsSubtitle => 'The starting flow for new gym profiles.';

  @override
  String get flowAppDefaultEntry => 'App default flow';

  @override
  String get flowGymProfilesSubtitle => 'Each profile has defaults and its own plan flows.';

  @override
  String get flowNoProfiles => 'Create a gym profile to set profile and plan flows.';

  @override
  String get flowNoSavedYet => 'No saved flow yet';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes nodes | $branches branches | $actions actions';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$count plan flows available';
  }

  @override
  String get flowGymDefaultEntry => 'Gym default flow';

  @override
  String get gymSettingsTitle => 'Gym & Workout Settings';

  @override
  String get gymSettingsSubtitle => 'Tune workout generation, analytics, and workout-flow behavior.';

  @override
  String get gymSettingsLogicTitle => 'Workout Logic';

  @override
  String get gymSettingsLogicSubtitle => 'Settings that affect planning and generated workouts.';

  @override
  String get gymSettingsWorkoutTitle => 'Workout Settings';

  @override
  String get gymSettingsWorkoutSubtitle => 'Volume limits, analytics defaults, and training controls.';

  @override
  String get gymSettingsExitTitle => 'Ongoing Workout Exit';

  @override
  String get gymSettingsFlowToolsTitle => 'Flow Tools';

  @override
  String get gymSettingsFlowToolsSubtitle => 'Manage saved progression paths and actions.';

  @override
  String get gymSettingsFlowsSubtitle => 'Edit progression flows for app defaults, gyms, and plans.';

  @override
  String get gymSettingsRulesSubtitle => 'Manage weight, rep, and set progression rules.';

  @override
  String get gymExitAsk => 'Ask every time';

  @override
  String get gymExitDiscard => 'Cancel workout';

  @override
  String get gymExitSave => 'End and save';

  @override
  String get gymExitAskBody => 'Ask before ending completed work.';

  @override
  String get gymExitDiscardBody => 'Cancel without saving completed work.';

  @override
  String get gymExitSaveBody => 'Save completed work to Logbook.';

  @override
  String get commonAll => 'All';

  @override
  String get catalogGuideChooseTitle => 'Choose an exercise';

  @override
  String get catalogGuideChooseBody => 'Tap any exercise row to select it. Search or filters can help you find the right movement.';

  @override
  String get catalogGuideAddTitle => 'Add it to your plan';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return 'Tap + to add $exerciseName and return to your plan.';
  }

  @override
  String get catalogGuideSearchTitle => 'Search exercises';

  @override
  String get catalogGuideSearchBody => 'Search by exercise name when you already know what movement you want.';

  @override
  String get catalogFilters => 'Filters';

  @override
  String get catalogGuideFiltersBody => 'Filter by gym profile, equipment, bodypart, or muscle to narrow the catalog quickly.';

  @override
  String get catalogGuideRowsTitle => 'Exercise rows';

  @override
  String get catalogGuideRowsBody => 'Each row shows equipment and a heatmap. Tap the heatmap for details or select the row when choosing an exercise.';

  @override
  String get catalogSelectedFilters => 'Selected Filters';

  @override
  String get catalogUseWorkspaceProfile => 'Use Workspace Profile';

  @override
  String get catalogWorkspaceProfile => 'Workspace Profile';

  @override
  String get catalogEquipment => 'Equipment';

  @override
  String get catalogFocusArea => 'Area of Focus';

  @override
  String get catalogSpecificMuscle => 'Specific Muscle';

  @override
  String get catalogPageTitle => 'Exercise Catalog';

  @override
  String get catalogSearchExercises => 'Search Exercises';

  @override
  String get catalogNoMatches => 'No exercises match filters.';

  @override
  String get catalogOpenExerciseInfo => 'Open exercise information';

  @override
  String get commonClose => 'Close';

  @override
  String get exerciseDetailOpenImage => 'Open exercise image';

  @override
  String get exerciseDetailTutorialTitle => 'Exercise details';

  @override
  String get exerciseDetailTutorialBody => 'The sheet title is the exercise you opened. Close it from here when you are done.';

  @override
  String get exerciseDetailTabsTutorialTitle => 'Details, metrics, records';

  @override
  String get exerciseDetailTabsTutorialBody => 'Use these tabs to switch between instructions, best lifts, and recent workout records.';

  @override
  String get exerciseDetailContextTutorialTitle => 'Exercise context';

  @override
  String get exerciseDetailContextTutorialBody => 'The details tab shows equipment, trained bodyparts, muscles, and form notes for the exercise.';

  @override
  String get exerciseDetailSessionOpenFailed => 'Workout session could not be opened.';

  @override
  String get exerciseDetailSessionNotFound => 'Workout session could not be found.';

  @override
  String get exerciseDetailNoEquipment => 'No equipment listed for this exercise.';

  @override
  String get exerciseDetailTargetAnatomy => 'Target anatomy';

  @override
  String get exerciseDetailBodyParts => 'Body parts';

  @override
  String get exerciseDetailNoBodyParts => 'No body parts listed.';

  @override
  String get exerciseDetailMuscles => 'Muscles';

  @override
  String get exerciseDetailNoMuscles => 'No muscles listed.';

  @override
  String get exerciseDetailSetup => 'Set-up';

  @override
  String get exerciseDetailNoSetup => 'No setup instructions provided.';

  @override
  String get exerciseDetailExecution => 'Execution';

  @override
  String get exerciseDetailNoExecution => 'No execution notes provided.';

  @override
  String get exerciseDetailTips => 'Tips';

  @override
  String get exerciseDetailNoTips => 'No additional tips.';

  @override
  String get exerciseDetailFormGuide => 'Form guide';

  @override
  String get exerciseDetailOpenHeatmap => 'Open targeted body heatmap';

  @override
  String get exerciseDetailNoHeatmap => 'No targeted body areas available';

  @override
  String get exerciseDetailZoomHint => 'Pinch or drag to zoom';

  @override
  String get exerciseDetailLoadingBestLifts => 'Loading best lifts';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'Your completed set records are being calculated.';

  @override
  String get exerciseDetailMetricsUnavailable => 'Metrics unavailable';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'Try reopening this exercise to load its completed set records.';

  @override
  String get exerciseDetailNoBestLifts => 'No best lifts yet';

  @override
  String get exerciseDetailNoBestLiftsBody => 'Complete a weighted set for this exercise to begin tracking rep bests.';

  @override
  String get exerciseDetailWeek => 'Week';

  @override
  String get exerciseDetailMonth => 'Month';

  @override
  String get exerciseDetailAllTime => 'All time';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return '$timeframe metrics';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'Top est. 1RM';

  @override
  String get exerciseDetailVolumeBest => 'Volume best';

  @override
  String get exerciseDetailRepBests => 'Rep bests';

  @override
  String get exerciseDetailRepBestsBody => 'Best completed weight for each rep count';

  @override
  String exerciseDetailRanges(int count) {
    return '$count ranges';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'Unable to load exercise history.';

  @override
  String get exerciseDetailNoHistory => 'No history for this exercise.';

  @override
  String get exerciseDetailPerformanceTrend => 'Performance trend';

  @override
  String get exerciseDetailBestWeight => 'Best weight';

  @override
  String get exerciseDetailEstimatedOneRm => 'Estimated 1RM';

  @override
  String get exerciseDetailLoadingSessions => 'Loading sessions';

  @override
  String get exerciseDetailLoadMoreSessions => 'Load 10 more sessions';

  @override
  String get exerciseDetailResizeLabel => 'Resize exercise details';

  @override
  String get exerciseDetailResizeHint => 'Drag up or down to resize the sheet';

  @override
  String get exerciseDetailTabDetails => 'Details';

  @override
  String get exerciseDetailTabMetrics => 'Metrics';

  @override
  String get exerciseDetailTabRecords => 'Records';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return 'Open workout with $count completed sets';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return 'ERM $weight';
  }

  @override
  String get exerciseDetailReps => 'reps';

  @override
  String get exerciseDetailSetVolume => 'Set volume';

  @override
  String get exerciseDetailNoChartData => 'No completed set records to chart yet.';

  @override
  String get exerciseDetailWeightAbbreviation => 'Wt';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'Est';

  @override
  String get exerciseDetailTopAbbreviation => 'Top';

  @override
  String exerciseDetailSectionLabel(String title) {
    return '$title section';
  }

  @override
  String get logbookTutorialCalendarTitle => 'Logbook calendar';

  @override
  String get logbookTutorialCalendarBody => 'Use M, 3M, Y, and 4Y to browse workout history. Select a day, week, month, or year to see sessions and summary stats for that range.';

  @override
  String get fullHistoryTitle => 'All sessions';

  @override
  String get fullHistoryLoadError => 'Unable to load saved sessions.';

  @override
  String get fullHistoryEmpty => 'No sessions saved.';

  @override
  String fullHistorySessionSummary(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get weeklySetsTitle => 'Weekly sets overview';

  @override
  String get weeklySetsLoadError => 'Unable to load your weekly training overview.';

  @override
  String get weeklySetsBodyParts => 'Bodyparts';

  @override
  String get weeklySetsMuscles => 'Muscles';

  @override
  String get weeklySetsTotal => 'Total sets';

  @override
  String get weeklySetsTime => 'Time';

  @override
  String get weeklySetsVolume => 'Volume';

  @override
  String get weeklySetsNoBodyParts => 'No bodypart sets yet.';

  @override
  String get weeklySetsNoMuscles => 'No muscle sets yet.';

  @override
  String weeklySetsCount(String count) {
    return '$count sets';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'Weekly overview';

  @override
  String get weeklySetsTutorialOverviewBody => 'This summarizes the last seven days with a heatmap plus total sets, time, and volume.';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'Bodyparts or muscles';

  @override
  String get weeklySetsTutorialAnatomyBody => 'Switch between bodypart set units and individual muscle set units.';

  @override
  String get weeklySetsTutorialStatusTitle => 'Set status';

  @override
  String get weeklySetsTutorialStatusBody => 'Each row is tinted based on whether your recent work is under, inside, or above its recommended range. Tap a row for linked exercises.';

  @override
  String get workoutDetailTutorialSummaryTitle => 'Workout summary';

  @override
  String get workoutDetailTutorialSummaryBody => 'Review total sets, volume, duration, exercise count, and the bodyparts this workout hit.';

  @override
  String get workoutDetailTutorialExercisesTitle => 'Exercise records';

  @override
  String get workoutDetailTutorialExercisesBody => 'Each exercise shows the completed sets from that session. Tap details to inspect the exercise.';

  @override
  String get workoutDetailTutorialEditTitle => 'Edit session';

  @override
  String get workoutDetailTutorialEditBody => 'Use edit mode if you need to correct sets, reps, or exercises after the workout.';

  @override
  String get workoutDetailTutorialReuseTitle => 'Reuse this workout';

  @override
  String get workoutDetailTutorialReuseBody => 'Do the workout again or save the completed session as a reusable plan.';

  @override
  String get workoutDetailDeleteTitle => 'Delete session';

  @override
  String get workoutDetailDeleteBody => 'Are you sure you want to delete this session?';

  @override
  String get workoutDetailDeleteFailed => 'Could not delete this session.';

  @override
  String get workoutDetailChangesSaved => 'Changes saved.';

  @override
  String get workoutDetailSaveFailed => 'Could not save changes. The previous session is unchanged.';

  @override
  String get workoutDetailFinishCurrentFirst => 'Finish your current workout before repeating this one.';

  @override
  String get workoutDetailOngoingWorkoutKept => 'Your ongoing workout was kept. Finish or cancel it before repeating this workout.';

  @override
  String get workoutDetailRepeatFailed => 'Could not repeat this workout.';

  @override
  String get workoutDetailSaveAsPlan => 'Save as plan';

  @override
  String get workoutDetailPlanName => 'Plan name';

  @override
  String workoutDetailPlanSaved(String name) {
    return 'Saved \"$name\" as a plan.';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'Failed to save plan.';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'Workout $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'Unsaved changes';

  @override
  String get workoutDetailUnsavedBody => 'You have unsaved changes. Do you want to discard them and leave?';

  @override
  String get workoutDetailDiscard => 'Discard';

  @override
  String get workoutDetailTitle => 'Workout detail';

  @override
  String get workoutDetailStopEditing => 'Stop editing';

  @override
  String get workoutDetailEditSession => 'Edit session';

  @override
  String get workoutDetailDeleteSession => 'Delete session';

  @override
  String get workoutDetailLoadFailed => 'Unable to load this session.';

  @override
  String get workoutDetailEmpty => 'No exercises in this session.';

  @override
  String get workoutDetailSaveChanges => 'Save changes';

  @override
  String get workoutDetailRepeat => 'Do workout again';

  @override
  String get workoutDetailPastWorkout => 'Past workout';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$count completed sets';
  }

  @override
  String get workoutDetailVolume => 'Volume';

  @override
  String get workoutDetailDuration => 'Duration';

  @override
  String get workoutDetailExercises => 'Exercises';

  @override
  String get workoutDetailExerciseInfo => 'Exercise info';

  @override
  String get workoutDetailBest => 'Best';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'Unable to load workout calendar.';

  @override
  String get logbookNoWorkouts => 'No workouts logged';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => 'Previous month';

  @override
  String get logbookNextMonth => 'Next month';

  @override
  String get logbookPreviousThreeMonths => 'Previous 3 months';

  @override
  String get logbookNextThreeMonths => 'Next 3 months';

  @override
  String get logbookPreviousYear => 'Previous year';

  @override
  String get logbookNextYear => 'Next year';

  @override
  String logbookWeekShort(int week) {
    return 'W$week';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month week $week';
  }

  @override
  String get logbookWorkouts => 'Workouts';

  @override
  String get logbookTotalTime => 'Total time';

  @override
  String get logbookTotalVolume => 'Total volume';

  @override
  String get logbookViewAllSessions => 'View all sessions';

  @override
  String logbookSessionSummary(int minutes, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$minutes min - $_temp0 - $_temp1 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get dashboardHideSection => 'Hide section';

  @override
  String get dashboardAllSectionsShown => 'All sections are shown';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$count section(s) hidden';
  }

  @override
  String get dashboardShowHiddenSections => 'Show hidden sections';

  @override
  String get dashboardReset => 'Reset dashboard';

  @override
  String get dashboardEmptyTitle => 'Your dashboard is empty';

  @override
  String get dashboardEmptyBody => 'Add back any section whenever you are ready.';

  @override
  String get dashboardCustomize => 'Customize dashboard';

  @override
  String get dashboardSectionQuickActionsTitle => 'Quick actions';

  @override
  String get dashboardSectionQuickActionsBody => 'Log a measurement or start a workout.';

  @override
  String get dashboardSectionTrainingTitle => 'Ready to train';

  @override
  String get dashboardSectionTrainingBody => 'Select your gym profile, plans, and start a session.';

  @override
  String get dashboardSectionNutritionTitle => 'Nutrition dashboard';

  @override
  String get dashboardSectionNutritionBody => 'Review current calorie and macro targets.';

  @override
  String get dashboardSectionDataRecordsTitle => 'Data & records';

  @override
  String get dashboardSectionDataRecordsBody => 'Review and add daily nutrition entries.';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'Weekly focus';

  @override
  String get dashboardSectionWeeklyFocusBody => 'Review bodypart and muscle work from the last 7 days.';

  @override
  String get dashboardSectionWorkoutReportTitle => 'Workout report';

  @override
  String get dashboardSectionWorkoutReportBody => 'Compare workout count, time, and volume over time.';

  @override
  String get dashboardSectionExerciseProgressTitle => 'Exercise progress';

  @override
  String get dashboardSectionExerciseProgressBody => 'Follow strength trends for your selected exercises.';

  @override
  String get dashboardSectionHistoryTitle => 'Training history';

  @override
  String get dashboardSectionHistoryBody => 'Compare workout totals and focus across time ranges.';

  @override
  String get dashboardSectionHealthTrendsTitle => 'Health trends';

  @override
  String get dashboardSectionHealthTrendsBody => 'Track measurements such as bodyweight and sizes.';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'Recent workouts';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'Open your latest completed workout sessions.';

  @override
  String get dashboardSectionActivePlansTitle => 'Active plans';

  @override
  String get dashboardSectionActivePlansBody => 'Keep the plans you use most often close at hand.';

  @override
  String get dashboardSectionArchivedPlansTitle => 'Archived plans';

  @override
  String get dashboardSectionArchivedPlansBody => 'Browse plans that are not currently active.';

  @override
  String get dashboardSectionPremadePlansTitle => 'Premade plans';

  @override
  String get dashboardSectionPremadePlansBody => 'Browse routines that can be added to this profile.';

  @override
  String get dashboardSectionPlanToolsTitle => 'Plan tools';

  @override
  String get dashboardSectionPlanToolsBody => 'Generate a balanced plan or create one manually.';

  @override
  String get dashboardSectionCatalogTitle => 'Exercise catalog';

  @override
  String get dashboardSectionCatalogBody => 'Open your most used exercises and the full catalog.';

  @override
  String get dashboardSectionAnatomyTitle => 'Target anatomy';

  @override
  String get dashboardSectionAnatomyBody => 'Review the bodyparts and muscles you train most.';

  @override
  String get dashboardSectionFallbackTitle => 'Dashboard section';

  @override
  String get dashboardSectionFallbackBody => 'A dashboard section.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardDoneCustomizing => 'Done customizing';

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get dashboardMeasurement => 'Measurement';

  @override
  String get dashboardResumeWorkout => 'Resume workout';

  @override
  String get dashboardStartWorkout => 'Start workout';

  @override
  String dashboardTodayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'Recent workouts';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardRecentWorkoutsFailed => 'Could not load recent workouts.';

  @override
  String get dashboardRecentWorkoutsEmpty => 'Finish a workout and it will appear here.';

  @override
  String get userInfoProfileUpdateNote => 'Profile update';

  @override
  String get userInfoChangesSaved => 'Changes saved';

  @override
  String get userInfoSaveFailed => 'Could not save your changes.';

  @override
  String get userInfoTitle => 'User information';

  @override
  String get userInfoSubtitle => 'Keep basic profile details available for app calculations.';

  @override
  String get userInfoIdentityTitle => 'Identity';

  @override
  String get userInfoIdentitySubtitle => 'Basic personal details.';

  @override
  String get userInfoName => 'Name';

  @override
  String get userInfoNameHint => 'Enter your name';

  @override
  String get userInfoGender => 'Gender';

  @override
  String get userInfoDateOfBirth => 'Date of birth';

  @override
  String get userInfoDateHint => 'YYYY-MM-DD';

  @override
  String get userInfoBodyMetricsTitle => 'Body metrics';

  @override
  String get userInfoBodyMetricsSubtitle => 'Optional details used by progress and nutrition estimates.';

  @override
  String get userInfoHeight => 'Height';

  @override
  String get userInfoHeightHint => 'e.g. 5\'10\" or 178 cm';

  @override
  String get userInfoCurrentWeight => 'Current weight';

  @override
  String get userInfoWeightPoundsHint => 'e.g. 160';

  @override
  String get userInfoWeightKilogramsHint => 'e.g. 72';

  @override
  String get userInfoBodyFat => 'Body-fat % estimate';

  @override
  String get userInfoActivityTitle => 'Activity context';

  @override
  String get userInfoActivitySubtitle => 'Used later for recommendations and health estimates.';

  @override
  String get userInfoWeightTrend => 'Weight trend';

  @override
  String get userInfoAverageSteps => 'Estimated avg steps';

  @override
  String get userInfoGenderMale => 'Male';

  @override
  String get userInfoGenderFemale => 'Female';

  @override
  String get userInfoGenderOther => 'Other';

  @override
  String get userInfoGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get userInfoTrendGaining => 'Gaining weight';

  @override
  String get userInfoTrendLosing => 'Losing weight';

  @override
  String get userInfoTrendMaintaining => 'Maintaining weight';

  @override
  String get userInfoTrendNotSure => 'Not sure';

  @override
  String get userInfoActivityLow => 'Low (0-5k)';

  @override
  String get userInfoActivityModerate => 'Moderate (5-15k)';

  @override
  String get userInfoActivityHigh => 'High (15k+)';

  @override
  String get userInfoSaveChanges => 'Save changes';

  @override
  String get tutorialsSettingsTitle => 'Guided tutorials';

  @override
  String get tutorialsSettingsSubtitle => 'Replay a walkthrough when you want a quick refresher.';

  @override
  String get tutorialsControlsTitle => 'Tutorial controls';

  @override
  String get tutorialsControlsSubtitle => 'Testing or starting fresh?';

  @override
  String get tutorialsResetAllTitle => 'Reset all tutorials';

  @override
  String get tutorialsResetAllSubtitle => 'Makes every guided tutorial available again.';

  @override
  String get tutorialsResetAll => 'Reset all';

  @override
  String get tutorialsResetAllMessage => 'All tutorials have been reset.';

  @override
  String get tutorialsHowItWorksTitle => 'How tutorials work';

  @override
  String get tutorialsHowItWorksBody => 'Tutorials appear once, then stay out of the way. Expand a group to reset a specific walkthrough.';

  @override
  String get tutorialsMainTabsTitle => 'Main tabs';

  @override
  String get tutorialsMainTabsSubtitle => 'Replay walkthroughs for each main area.';

  @override
  String get tutorialsWorkoutTitle => 'Workout';

  @override
  String get tutorialsWorkoutSubtitle => 'Help for logging your first session.';

  @override
  String get tutorialsPlansTitle => 'Plans & workouts';

  @override
  String get tutorialsPlansSubtitle => 'Replay plan creation, editing, and workout detail help.';

  @override
  String get tutorialsCatalogTitle => 'Catalog & anatomy';

  @override
  String get tutorialsCatalogSubtitle => 'Replay exercise and target anatomy help.';

  @override
  String get tutorialsProgressTitle => 'Progress & settings';

  @override
  String get tutorialsProgressSubtitle => 'Replay progress detail and settings page help.';

  @override
  String tutorialsReplayTitle(String topic) {
    return 'Replay $topic tutorial';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'Shows next time you open $topic.';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return '$topic tutorial will replay next time.';
  }

  @override
  String get tutorialsReset => 'Reset';

  @override
  String get tutorialsTopicTrain => 'Train';

  @override
  String get tutorialsTopicCatalog => 'Catalog';

  @override
  String get tutorialsTopicLogbook => 'Logbook';

  @override
  String get tutorialsTopicProgress => 'Progress';

  @override
  String get tutorialsTopicProfile => 'Profile';

  @override
  String get tutorialsTopicFirstWorkout => 'first workout';

  @override
  String get tutorialsTopicGeneratePlans => 'Generate Plans';

  @override
  String get tutorialsTopicOptimizedSettings => 'optimized workout settings';

  @override
  String get tutorialsTopicPremadePlans => 'Premade Plans';

  @override
  String get tutorialsTopicPlanManagement => 'plan management';

  @override
  String get tutorialsTopicPlanDetail => 'plan details';

  @override
  String get tutorialsTopicPlanBuilder => 'plan builder';

  @override
  String get tutorialsTopicWorkoutDetail => 'workout details';

  @override
  String get tutorialsTopicExerciseCatalog => 'Exercise Catalog';

  @override
  String get tutorialsTopicExerciseDetail => 'exercise details';

  @override
  String get tutorialsTopicTargetAnatomy => 'Target Anatomy';

  @override
  String get tutorialsTopicBodypartDetail => 'bodypart details';

  @override
  String get tutorialsTopicMuscleDetail => 'muscle details';

  @override
  String get tutorialsTopicWeeklySets => 'Weekly Sets Overview';

  @override
  String get tutorialsTopicExerciseProgress => 'exercise progress';

  @override
  String get tutorialsTopicMeasurementTrend => 'measurement trend';

  @override
  String get tutorialsTopicGymProfile => 'Gym Profile editor';

  @override
  String get tutorialsTopicUiAppearance => 'UI & Appearance';

  @override
  String get tutorialsTopicDatabaseSettings => 'Database Settings';

  @override
  String get tutorialsTopicGuide => 'guided help';

  @override
  String get anatomyLibraryTitle => 'Exercise focus library';

  @override
  String get anatomyBodyParts => 'Bodyparts';

  @override
  String get anatomyMuscles => 'Muscles';

  @override
  String get anatomyLoadFailed => 'Unable to load anatomy filters.';

  @override
  String get anatomySearchLabel => 'Search bodyparts or muscles';

  @override
  String get anatomyNoBodyParts => 'No bodyparts match your search.';

  @override
  String get anatomyNoMuscles => 'No muscles match your search.';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => 'Search anatomy';

  @override
  String get anatomyTutorialSearchBody => 'Search for a bodypart or a specific muscle when you want targeted exercise options.';

  @override
  String get anatomyTutorialListsTitle => 'Bodyparts and muscles';

  @override
  String get anatomyTutorialListsBody => 'Switch tabs, then tap any row to see linked exercises, recent set totals, and recommended set boundaries.';

  @override
  String anatomyTargetExercises(String name) {
    return '$name exercises';
  }

  @override
  String get anatomyBodypartLoadFailed => 'Unable to load this bodypart.';

  @override
  String get anatomyMuscleLoadFailed => 'Unable to load this muscle.';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return 'Recommended sets updated for $name.';
  }

  @override
  String get anatomySaveFailed => 'Unable to save changes.';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked exercises',
      one: '1 linked exercise',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => 'Done (7 days)';

  @override
  String get anatomySetsLastSevenDays => 'Sets last 7 days';

  @override
  String anatomySetUnits(String count) {
    return '$count sets';
  }

  @override
  String get anatomyRecommended => 'Recommended';

  @override
  String get anatomyNotSet => 'Not set';

  @override
  String anatomySetRange(String min, String max) {
    return '$min-$max sets';
  }

  @override
  String get anatomyAssociatedMuscles => 'Associated muscles';

  @override
  String get anatomyRelatedBodyParts => 'Related bodyparts';

  @override
  String get anatomyNoMuscleLinks => 'No muscle links have been added for this bodypart yet.';

  @override
  String get anatomyNoBodyPartLinks => 'No bodypart links have been added for this muscle yet.';

  @override
  String get anatomyExercises => 'Exercises';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'No exercises are currently linked to $name.';
  }

  @override
  String get anatomyNoEquipment => 'No equipment listed';

  @override
  String get anatomyNoMusclesListed => 'No muscles listed';

  @override
  String get anatomyNoBodyPartsListed => 'No bodyparts listed';

  @override
  String anatomyOpenedFrom(String name) {
    return 'Opened from $name';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'Rank $rank for this muscle - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'Anatomy detail';

  @override
  String get anatomyTutorialBodypartDetailBody => 'The header shows recent sets, recommended set boundaries, and related anatomy links.';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'Muscle detail';

  @override
  String get anatomyTutorialMuscleDetailBody => 'The header shows recent sets, recommended set boundaries, and related bodyparts.';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'Linked exercises';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'These are exercises connected to this target. Tap one to open its full exercise details.';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'Exercises are ranked by how directly they train this muscle. Tap one for full details.';

  @override
  String get settingsWorkoutTitle => 'Workout Settings';

  @override
  String get settingsWorkoutSubtitle => 'Tune how the app understands anatomy, training bias, and volume targets.';

  @override
  String get settingsTrainingBiasTitle => 'Training Bias';

  @override
  String get settingsTrainingBiasSubtitle => 'Controls used by generated plans and optimized workouts.';

  @override
  String get settingsBodyPartRankings => 'Body Part Rankings';

  @override
  String get settingsBodyPartRankingsSubtitle => 'Prioritize which body parts should receive more work.';

  @override
  String get settingsMuscleRankings => 'Muscle Rankings';

  @override
  String get settingsMuscleRankingsSubtitle => 'Prioritize specific muscles inside the anatomy model.';

  @override
  String get settingsVolumeBoundaries => 'Volume Boundaries';

  @override
  String get settingsVolumeBoundariesSubtitle => 'Set recommended weekly ranges for body parts and muscles.';

  @override
  String get settingsExerciseDefinitionsTitle => 'Exercise Definitions';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'Maintain the anatomy and exercise data used by the app.';

  @override
  String get settingsAnatomyMapping => 'Body Part / Muscle Mapping';

  @override
  String get settingsAnatomyMappingSubtitle => 'Choose which muscles belong to each body part.';

  @override
  String get settingsExerciseSetAllocation => 'Exercise Set Allocation';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'Review how each exercise contributes to muscles and body parts.';

  @override
  String get settingsExerciseEditor => 'Exercise Editor';

  @override
  String get settingsExerciseEditorSubtitle => 'Update exercise names, details, equipment, and mappings.';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonImport => 'Import';

  @override
  String get commonExport => 'Export';

  @override
  String get databaseExportTitle => 'Export Database';

  @override
  String get databaseImportTitle => 'Import Database';

  @override
  String get databasePasteJson => 'Paste JSON here';

  @override
  String get databaseCopied => 'Copied to clipboard';

  @override
  String databaseExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get databaseImportSucceeded => 'Import succeeded';

  @override
  String databaseImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get nutritionSettingsTitle => 'Diet & Nutrition Settings';

  @override
  String get nutritionSettingsSubtitle => 'Configure nutrition targets and food-related preferences.';

  @override
  String get nutritionCurrentGoals => 'Current Goals';

  @override
  String get nutritionGoals => 'Goals';

  @override
  String get nutritionGoalsSubtitle => 'Set the targets used by nutrition tracking.';

  @override
  String get nutritionManualGoals => 'Manually Set Nutrition Goals';

  @override
  String get nutritionManualGoalsSubtitle => 'Enter calories, macros, and key nutrients yourself.';

  @override
  String get nutritionGoalsSaved => 'Goals saved';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'Calories: $calories / Protein: $protein / Carbs: $carbs / Fat: $fat / Fiber: $fiber / Sugar: $sugar / Sat. Fat: $satFat / Sodium: $sodium';
  }

  @override
  String get progressSettingsTitle => 'Progress Settings';

  @override
  String get progressSettingsSubtitle => 'Manage body measurements and trend tracking setup.';

  @override
  String get progressMeasurements => 'Measurements';

  @override
  String get progressMeasurementsSubtitle => 'Configure the body metrics you want to track over time.';

  @override
  String get progressMeasurementLibrary => 'Measurement Library';

  @override
  String get progressMeasurementLibrarySubtitle => 'Manage weight, height, body measurements, and custom metrics.';

  @override
  String get nutritionManualGoalsTitle => 'Manual Nutrition Goals';

  @override
  String get nutritionManualGoalsPageSubtitle => 'Set calorie, macro, and nutrient targets manually.';

  @override
  String get nutritionSaveGoals => 'Save Goals';

  @override
  String get nutritionSaving => 'Saving...';

  @override
  String get nutritionStartDate => 'Start Date';

  @override
  String get nutritionGoalStarts => 'Goal starts';

  @override
  String get nutritionCaloriesAndMacros => 'Calories & Macros';

  @override
  String get nutritionAdditionalNutrients => 'Additional Nutrients';

  @override
  String get nutritionCalories => 'Calories (kcal)';

  @override
  String get nutritionProtein => 'Protein (g)';

  @override
  String get nutritionCarbs => 'Carbs (g)';

  @override
  String get nutritionFat => 'Fat (g)';

  @override
  String get nutritionFiber => 'Fiber (g)';

  @override
  String get nutritionSugar => 'Sugar (g)';

  @override
  String get nutritionSatFat => 'Sat. Fat (g)';

  @override
  String get nutritionSodium => 'Sodium (mg)';

  @override
  String get nutritionEnterNumber => 'Enter a number';

  @override
  String get nutritionNumberAtLeastZero => 'Must be >= 0';

  @override
  String rankingsSaved(String target) {
    return '$target rankings saved';
  }

  @override
  String get rankingsSave => 'Save Rankings';

  @override
  String rankingsTitle(String target) {
    return '$target Rankings';
  }

  @override
  String rankingsHero(String target) {
    return 'Drag $target into the order you want generated training to prefer.';
  }

  @override
  String get rankingsNoBodyParts => 'No body parts defined';

  @override
  String get rankingsNoMuscles => 'No muscles defined';

  @override
  String rankingsLoadError(String target, String error) {
    return 'Unable to load $target: $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'Unable to save: $error';
  }

  @override
  String get rankingsRank => 'Rank';

  @override
  String get mappingTitle => 'Anatomy Mapping';

  @override
  String get mappingHero => 'Connect muscles to body parts so heatmaps, analytics, and generated workouts agree.';

  @override
  String get mappingSaved => 'Mappings saved';

  @override
  String mappingSaveFailed(String error) {
    return 'Unable to save: $error';
  }

  @override
  String get mappingSelectedBodyPart => 'Selected Body Part';

  @override
  String get mappingBodyPart => 'Body part';

  @override
  String get mappingChooseLinkedMuscles => 'Choose Linked Muscles';

  @override
  String get mappingLinkedMuscles => 'Linked Muscles';

  @override
  String get mappingChooseLinkedSubtitle => 'Select every muscle that belongs to this body part.';

  @override
  String mappingLinkedCount(int count) {
    return '$count muscles currently linked.';
  }

  @override
  String get mappingNoMuscles => 'No muscles defined.';

  @override
  String get mappingNoLinkedMuscles => 'No muscles linked yet. Tap Edit to add some.';

  @override
  String get volumeMaintenance => 'Maintenance';

  @override
  String get volumeMinEffective => 'Min Effective';

  @override
  String get volumeMaxAdaptive => 'Max Adaptive';

  @override
  String get volumeMaxRecoverable => 'Max Recoverable';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'Unable to load body part boundaries: $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'Unable to load muscle boundaries: $error';
  }

  @override
  String get volumeBodyPartSaved => 'Body part boundaries saved';

  @override
  String get volumeMuscleSaved => 'Muscle boundaries saved';

  @override
  String get volumeInvalidNumbers => 'Please enter valid numbers';

  @override
  String get volumeBodyParts => 'Body Parts';

  @override
  String get volumeMuscles => 'Muscles';

  @override
  String get volumeBodyPartTitle => 'Body Part Volume';

  @override
  String get volumeBodyPartSubtitle => 'Set weekly target ranges used by weekly analytics and workout generation.';

  @override
  String get volumeMuscleTitle => 'Muscle Volume';

  @override
  String get volumeMuscleSubtitle => 'Fine-tune weekly target ranges for individual muscles.';

  @override
  String get volumeSelection => 'Selection';

  @override
  String get volumeRecommendedRange => 'Recommended Range';

  @override
  String get volumeRecommendedRangeSubtitle => 'Numbers are set units per week.';

  @override
  String get volumeSaveBoundaries => 'Save Boundaries';

  @override
  String get nutritionDashboardTitle => 'Nutrition Dashboard';

  @override
  String nutritionDashboardError(String error) {
    return 'Unable to load nutrition: $error';
  }

  @override
  String get nutritionMenuTitle => 'Nutrition Menu';

  @override
  String get nutritionLogFood => 'Log Food';

  @override
  String get nutritionTrackMeasurement => 'Track Measurement';

  @override
  String get nutritionMeasuredItems => 'Measured Items';

  @override
  String get nutritionTodayRecords => 'Today\'s Records';

  @override
  String get nutritionGoalsMenu => 'Nutrition Goals';

  @override
  String get measurementWeight => 'Weight';

  @override
  String get measurementHips => 'Hips';

  @override
  String get measurementShoulders => 'Shoulders';

  @override
  String get measurementCalves => 'Calves';

  @override
  String get measurementTrackNew => 'Track a New Measurement';

  @override
  String get barcodeScannerTitle => 'Scan a barcode';

  @override
  String get barcodeSwitchCamera => 'Switch camera';

  @override
  String get barcodeTorchOn => 'Torch on';

  @override
  String get barcodeTorchOff => 'Torch off';

  @override
  String get barcodeTorchUnavailable => 'Torch is not available on this device';

  @override
  String get barcodeAlignHint => 'Align the barcode within the frame';

  @override
  String get progressTutorialWorkoutReportTitle => 'Workout report';

  @override
  String get progressTutorialWorkoutReportBody => 'This tracks workout count, training time, and volume over different time ranges. Tap a metric to change what the graph shows.';

  @override
  String get progressTutorialExerciseProgressTitle => 'Exercise progress';

  @override
  String get progressTutorialExerciseProgressBody => 'Track strength trends for selected exercises. Use the edit tile to add or remove exercises from this dashboard.';

  @override
  String get progressTutorialHealthTrendsTitle => 'Health trends';

  @override
  String get progressTutorialHealthTrendsBody => 'Log bodyweight and custom measurements here, then watch those measurements change over time.';

  @override
  String get measurementNewTitle => 'New Measurement';

  @override
  String get measurementPresets => 'Presets';

  @override
  String get measurementCustom => 'Custom';

  @override
  String get measurementPresetType => 'Preset Type';

  @override
  String get measurementVariation => 'Variation';

  @override
  String get measurementWakeUp => 'Wake-up';

  @override
  String get measurementBedtime => 'Bedtime';

  @override
  String get measurementOverall => 'Overall';

  @override
  String get measurementValueWeight => 'Weight';

  @override
  String get measurementUnits => 'Units';

  @override
  String get measurementFeet => 'Feet';

  @override
  String get measurementInches => 'Inches';

  @override
  String get measurementCentimeters => 'Centimeters';

  @override
  String get measurementWithPump => 'With pump';

  @override
  String get measurementWithoutPump => 'Without pump';

  @override
  String get measurementName => 'Measurement name';

  @override
  String get measurementNameHint => 'Chest size, resting heart rate...';

  @override
  String get measurementValue => 'Value';

  @override
  String get measurementUnit => 'Unit';

  @override
  String get measurementNote => 'Note';

  @override
  String get measurementOptional => 'Optional';

  @override
  String get measurementSaveNew => 'Save New Measurement';

  @override
  String get measurementCustomRequired => 'Enter a custom name, value, and unit';

  @override
  String measurementDefinitionNotFound(String name) {
    return 'Definition not found for $name';
  }

  @override
  String get measurementInvalidValue => 'Enter a valid numeric value';

  @override
  String get measurementHeight => 'Height';

  @override
  String get measurementForearm => 'Forearm';

  @override
  String get measurementArm => 'Arm';

  @override
  String get measurementNeck => 'Neck';

  @override
  String get measurementChest => 'Chest';

  @override
  String get measurementWaist => 'Waist';

  @override
  String get measurementThigh => 'Thigh';

  @override
  String get measurementInstructionsForearm => 'Measure around the widest part of your forearm.';

  @override
  String get measurementInstructionsArm => 'Measure around the widest part of your bicep.';

  @override
  String get measurementInstructionsNeck => 'Measure where the tape sits straight around your neck.';

  @override
  String get measurementInstructionsShoulder => 'Keep the tape straight around the side deltoids.';

  @override
  String get measurementInstructionsChest => 'Measure under the armpits and above the nipple line.';

  @override
  String get measurementInstructionsWaist => 'Measure around your belly button.';

  @override
  String get measurementInstructionsHip => 'Measure around the widest part of your glutes.';

  @override
  String get measurementInstructionsThigh => 'Measure around the widest part of your thigh.';

  @override
  String get measurementInstructionsCalf => 'Measure around the widest part of your calf.';

  @override
  String get nutritionCaloriesLabel => 'Calories';

  @override
  String get nutritionFatLabel => 'Fat';

  @override
  String get nutritionProteinLabel => 'Protein';

  @override
  String get nutritionCarbsLabel => 'Carbs';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | C $carbs g | F $fat g';
  }

  @override
  String get nutritionEditEntry => 'Edit entry';

  @override
  String get nutritionEditNotAvailable => 'Editing entries is not available yet';

  @override
  String get nutritionEntryDeleted => 'Entry deleted';

  @override
  String get gymProfileEditTitle => 'Edit Gym Profile';

  @override
  String get gymProfileNewTitle => 'New Gym Profile';

  @override
  String get gymProfileTutorialSpaceTitle => 'Workout space';

  @override
  String get gymProfileTutorialSpaceBody => 'Name this profile for where you train, like Home Gym, Commercial Gym, or Travel Setup.';

  @override
  String get gymProfileTutorialFindTitle => 'Find equipment';

  @override
  String get gymProfileTutorialFindBody => 'Use search when the equipment list gets long and you want to jump to one item quickly.';

  @override
  String get gymProfileTutorialAvailableTitle => 'Available equipment';

  @override
  String get gymProfileTutorialAvailableBody => 'Select what this workout space has. Generated plans and swaps use this to avoid unavailable exercises.';

  @override
  String get gymProfileTutorialSaveTitle => 'Save profile';

  @override
  String get gymProfileTutorialSaveBody => 'Save stores the profile and equipment. Cancel asks before discarding unsaved changes.';

  @override
  String get gymProfileSaveChangesTitle => 'Save changes?';

  @override
  String get gymProfileSaveChangesBody => 'You have unsaved gym profile changes. Save them before leaving?';

  @override
  String get gymProfileKeepEditing => 'Keep Editing';

  @override
  String get gymProfileDiscard => 'Discard';

  @override
  String get gymProfileSelectEquipment => 'Select at least one equipment item.';

  @override
  String gymProfileSaveFailed(String error) {
    return 'Unable to save profile: $error';
  }

  @override
  String get gymProfileEquipmentHint => 'Pick what this gym has so generated plans only use available equipment.';

  @override
  String get gymProfileSpace => 'Workout Space';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected of $total equipment options selected';
  }

  @override
  String get gymProfileName => 'Profile name';

  @override
  String get gymProfileNameHint => 'Home gym, Commercial gym, Travel setup...';

  @override
  String get gymProfileNameRequired => 'Name required';

  @override
  String get gymProfileFilterEquipment => 'Filter equipment by name';

  @override
  String get gymProfileEquipment => 'Equipment';

  @override
  String get gymProfileSelectAll => 'Select All';

  @override
  String get gymProfileClear => 'Clear';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total selected';
  }

  @override
  String get gymProfileSave => 'Save Profile';

  @override
  String get gymProfileSaving => 'Saving...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return 'No equipment matches \"$query\".';
  }

  @override
  String get equipmentCategoryBasics => 'Basics';

  @override
  String get equipmentCategoryFreeWeights => 'Free Weights';

  @override
  String get equipmentCategoryBenchesRacks => 'Benches & Racks';

  @override
  String get equipmentCategoryCableAttachments => 'Cable & Attachments';

  @override
  String get equipmentCategoryMachines => 'Machines';

  @override
  String get equipmentCategoryOther => 'Other Equipment';

  @override
  String get equipmentNoRequirement => 'No required equipment';

  @override
  String get equipmentBodyweightSupport => 'Bodyweight movement support';

  @override
  String get equipmentMachineBased => 'Machine based movement';

  @override
  String get equipmentCableAccessory => 'Cable station accessory';

  @override
  String get equipmentBenchRackSetup => 'Bench, rack, or station setup';

  @override
  String get equipmentFreeWeightTraining => 'Free weight training';

  @override
  String get equipmentAvailable => 'Available equipment';

  @override
  String get foodLoggingTitle => 'Food Logging';

  @override
  String get foodLogTime => 'Log time:';

  @override
  String get foodPortion => 'Portion:';

  @override
  String get foodQuantity => 'Qty:';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / unit';
  }

  @override
  String get foodRemove => 'Remove';

  @override
  String get foodAddAllToDiary => 'Add All to Diary';

  @override
  String get foodLogging => 'Logging...';

  @override
  String get foodTabScan => 'Scan';

  @override
  String get foodTabSearch => 'Search';

  @override
  String get foodTabPlanned => 'Pre-Planned';

  @override
  String get foodTabCustom => 'Custom';

  @override
  String get foodSearchHint => 'Search for a food...';

  @override
  String get foodNoRecentRecipes => 'No recent recipes yet.';

  @override
  String get foodRecentRecipe => 'Recent recipe';

  @override
  String get foodNoFoodsFound => 'No foods found.';

  @override
  String get foodInstantLogAfterScan => 'Instant log after scan';

  @override
  String get foodInstantLogAfterScanSubtitle => 'Add the scanned item immediately using the selected meal.';

  @override
  String get foodOpenCameraScanner => 'Open camera scanner';

  @override
  String get foodEnterBarcode => 'Enter barcode manually';

  @override
  String get foodEnterBarcodeHint => 'e.g. 012345678905';

  @override
  String get foodLogByBarcode => 'Log by barcode';

  @override
  String get foodNoBarcode => 'No valid barcode detected';

  @override
  String get foodBarcodeLogged => 'Logged item from barcode';

  @override
  String foodFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get foodCustomSavedBarcode => 'Custom food saved and barcode linked';

  @override
  String get foodFavorites => 'Favorites';

  @override
  String get foodRecentFoods => 'Recent foods';

  @override
  String get foodStartSearching => 'Start searching to find foods.';

  @override
  String get foodFavorite => 'Favorite';

  @override
  String get foodUnfavorite => 'Unfavorite';

  @override
  String get foodCustomize => 'Customize food';

  @override
  String get foodEditAndAdd => 'Edit and add';

  @override
  String get foodAddOne => 'Add 1';

  @override
  String get foodAddNew => 'Add New Food Item';

  @override
  String get foodCustomSaved => 'Custom food saved';

  @override
  String get foodNoteOptional => 'Note (optional)';

  @override
  String get foodTagsHint => 'Tags (comma-separated, e.g. post-workout, high-protein)';

  @override
  String get foodAddToPlate => 'Add to Plate';

  @override
  String get foodProfileNotReady => 'Profile not ready yet.';

  @override
  String get foodItemsLogged => 'Items logged to diary';

  @override
  String foodLogFailed(String error) {
    return 'Unable to log: $error';
  }

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialSkipAll => 'Skip All';

  @override
  String get tutorialDone => 'Done';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialSkipAllTitle => 'Skip all tutorials?';

  @override
  String get tutorialSkipAllBody => 'This hides every guided tutorial. You can turn them back on anytime in Settings > Guided Tutorials by using Reset All Tutorials.';

  @override
  String get tutorialKeep => 'Keep tutorials';

  @override
  String get tutorialSkipEverything => 'Skip all';

  @override
  String get flowSelectNode => 'Select Node';

  @override
  String get flowSelectMethod => 'Select Method';

  @override
  String get flowAddSuccess => '+ Success';

  @override
  String get flowAddFailure => '+ Failure';

  @override
  String get flowAddMethod => '+ Method';

  @override
  String get flowRemoveMethod => '- Method';

  @override
  String get flowNewEvent => 'New Event';

  @override
  String get flowEventKey => 'Event key';

  @override
  String get flowEventDisplayLabel => 'Display label (optional)';

  @override
  String get flowAddSuccessNode => 'Add Success Node';

  @override
  String get flowAddFailureNode => 'Add Failure Node';

  @override
  String get flowAddEvent => '+ Event';

  @override
  String get flowSelectEvent => 'Select Event';

  @override
  String get flowRemoveEvent => 'Remove Event';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get drawerOptionA => 'Option A';

  @override
  String get drawerOptionB => 'Option B';

  @override
  String get drawerOptionC => 'Option C';

  @override
  String get drawerGymProfiles => 'Gym Profiles';

  @override
  String drawerSavedSpaces(int count) {
    return '$count saved spaces';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name is active';
  }

  @override
  String get drawerActiveProfile => 'Active profile';

  @override
  String get drawerTapToSwitch => 'Tap to switch';

  @override
  String get drawerNewProfile => 'New Profile';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRemove => 'Remove';

  @override
  String get automaticSaving => 'Saving...';

  @override
  String get automaticValuesTab => 'Values';

  @override
  String get automaticMethodsTab => 'Methods';

  @override
  String get automaticGlobalIncrement => 'Global Increment Amount';

  @override
  String get automaticAutoSelect => 'Auto Select';

  @override
  String get automaticManualSelect => 'Manual Select';

  @override
  String get automaticSkipFirstSet => 'Skip First Set?';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return 'Set $number: $weight x $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return 'Set $parent.$child: $weight x $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return 'Could not save settings: $error';
  }

  @override
  String get automaticIncrementWhen => 'Increment when (decrement otherwise):';

  @override
  String get automaticWeightTarget => 'Completed weight >= target weight';

  @override
  String get automaticRepsTarget => 'Completed reps >= target reps';

  @override
  String get automaticVolumeTarget => 'Completed volume >= target volume';

  @override
  String get automaticScopeLabel => 'Successes, misses, and adjustments are counted by:';

  @override
  String get automaticWorkoutSession => 'Workout session';

  @override
  String get automaticPerExercise => 'Per exercise';

  @override
  String get automaticPerSet => 'Per set';

  @override
  String get automaticAdjustScope => 'Adjust:';

  @override
  String get automaticAdjustOneSet => '1 set';

  @override
  String get automaticAdjustAllSets => 'All sets';

  @override
  String get weightExpandSets => 'Expand sets';

  @override
  String get weightCollapseSets => 'Collapse sets';

  @override
  String get weightDetails => 'Details';

  @override
  String get weightRemoveExerciseTitle => 'Remove Exercise';

  @override
  String get weightRemoveExerciseBody => 'Are you sure you want to remove this exercise?';

  @override
  String get weightSwapExercise => 'Swap Exercise';

  @override
  String get weightMakeChangeSet => 'Make ChangeSet';

  @override
  String weightSetLabel(int number) {
    return 'Set $number';
  }

  @override
  String weightLabel(String unit) {
    return 'Weight ($unit)';
  }

  @override
  String get weightReps => 'Reps';

  @override
  String get weightRemoveSetTitle => 'Remove Set';

  @override
  String get weightRemoveSetBody => 'Are you sure you want to remove this set?';

  @override
  String weightChangeSetLabel(int number) {
    return 'CSet $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'Wt ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'Remove CSet';

  @override
  String get weightRemoveChangeSetBody => 'Are you sure you want to remove this CSet?';

  @override
  String get weightAddChangeSet => 'Add CSet';

  @override
  String get weightAddSet => 'Add Set';

  @override
  String get swapAlreadySelected => 'That exercise is already selected.';

  @override
  String get swapNeedsProfileEquipment => 'That exercise needs equipment outside this profile.';

  @override
  String swapLoadFailed(Object error) {
    return 'Could not load that replacement exercise.';
  }

  @override
  String get swapCurrent => 'Current';

  @override
  String get swapReplacement => 'Replacement';

  @override
  String get swapConfirm => 'Confirm Swap';

  @override
  String get swapNoBodypartData => 'No bodypart data found.';

  @override
  String get swapLoadingSelected => 'Loading selected exercise...';

  @override
  String get swapBrowseCatalog => 'Browse Exercise Catalog';

  @override
  String get swapNoEquipment => 'No equipment listed';

  @override
  String get swapTitle => 'Swap Exercise';

  @override
  String get swapFindingMatches => 'Finding similar bodypart and muscle matches...';

  @override
  String get swapChooseReplacement => 'Choose a similar replacement.';

  @override
  String get swapFilterProfileEquipment => 'Filter for profile equipment';

  @override
  String get swapBodypartsHit => 'Bodyparts Hit';

  @override
  String swapMatch(int percent) {
    return '$percent% match';
  }

  @override
  String get swapNoReplacements => 'No similar replacements found yet.';

  @override
  String get swapNoReplacementsBody => 'This exercise may need more muscle or bodypart metadata before it can be swapped well.';

  @override
  String get premadePlansTitle => 'Premade Plans';

  @override
  String get premadeTutorialLengthTitle => 'Plan length';

  @override
  String get premadeTutorialLengthBody => 'Switch between 1-hour and 2-hour versions. Longer versions include more exercises and total sets.';

  @override
  String get premadeTutorialEquipmentTitle => 'Profile equipment';

  @override
  String get premadeTutorialEquipmentBody => 'When this is on, Tonos swaps unavailable exercises for similar options your current gym profile can perform.';

  @override
  String get premadeTutorialLibraryTitle => 'Plan library';

  @override
  String get premadeTutorialLibraryBody => 'Open a split, preview a plan, then add it to your Active Plans so it appears on Train.';

  @override
  String get premadeSelectProfile => 'Please select a gym profile first.';

  @override
  String premadePlanAdded(String name) {
    return '$name added to Active Plans.';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return 'Could not add $name: $error';
  }

  @override
  String get premadeDescription => 'Copy coach, influencer, and app-curated routines into your own plans. Once added, you can edit them like any other plan.';

  @override
  String get premadeDiscarding => 'Discarding...';

  @override
  String get premadeReviewPlans => 'Review Plans';

  @override
  String get allocationSaveChanges => 'Save changes';

  @override
  String get allocationSaving => 'Saving';

  @override
  String get allocationInvalidCredit => 'Enter a zero or positive number for every credit.';

  @override
  String get allocationSaved => 'Exercise allocation saved.';

  @override
  String get allocationSaveFailed => 'Could not save the exercise allocation. Try again.';

  @override
  String get allocationSaveOrDiscard => 'Save or discard your edits before resetting.';

  @override
  String get allocationTitle => 'Exercise Set Allocation';

  @override
  String get allocationSubtitle => 'Review how completed sets contribute to target muscles and body parts.';

  @override
  String get allocationHowTitle => 'How set credit works';

  @override
  String get allocationHowBody => 'A primary muscle usually receives 1.00 credit for one completed set. Supporting muscles receive less credit. This guides anatomy summaries and recommendations, but never changes the sets you log.';

  @override
  String allocationLoadFailed(String error) {
    return 'Could not load exercises. $error';
  }

  @override
  String get allocationNoExercises => 'No exercises are available yet.';

  @override
  String get allocationSelectedExercise => 'Selected exercise';

  @override
  String get allocationMuscleCredit => 'Muscle credit';

  @override
  String get allocationBodypartCredit => 'Body-part credit';

  @override
  String get allocationNoTargetMuscles => 'No target muscles';

  @override
  String get allocationNoBodypartMapping => 'No body-part mapping';

  @override
  String get allocationReset => 'Reset';

  @override
  String get allocationCredit => 'Credit';

  @override
  String get allocationNoTargetMusclesBody => 'This exercise does not have target-muscle data yet.';

  @override
  String get allocationMuscleCreditBody => 'Change a value to create a personal allocation. It is used for muscle summaries and derived body-part focus.';

  @override
  String get allocationNoBodypartMappingBody => 'This exercise does not have body-part mapping data yet.';

  @override
  String get allocationBodypartCreditBody => 'Automatic values are derived from muscles and anatomy mapping. Editing one creates a direct personal body-part allocation.';

  @override
  String get healthTrendsTitle => 'Health Trends';

  @override
  String get healthMetric => 'Metric';

  @override
  String get healthUnableToLoad => 'Unable to load measurements';

  @override
  String get healthNoMeasurements => 'No measurements yet';

  @override
  String get healthNoMeasurementsBody => 'Create a metric to start tracking progress.';

  @override
  String get healthCreateMetric => 'Create metric';

  @override
  String healthLogMeasurement(String name) {
    return 'Log $name';
  }

  @override
  String healthEditMeasurement(String name) {
    return 'Edit $name';
  }

  @override
  String get healthTutorialSummaryTitle => 'Measurement summary';

  @override
  String get healthTutorialSummaryBody => 'See the latest value, change from the previous entry, and how many records exist.';

  @override
  String get healthTutorialChartTitle => 'Trend chart';

  @override
  String get healthTutorialChartBody => 'The chart shows how this measurement changes over time as you log more entries.';

  @override
  String get healthTutorialEntriesTitle => 'Entries';

  @override
  String get healthTutorialEntriesBody => 'Tap an entry to edit it, or remove entries that were logged by mistake.';

  @override
  String get healthTutorialLogTitle => 'Log new entry';

  @override
  String get healthTutorialLogBody => 'Use this button whenever you want to add a new measurement record.';

  @override
  String get healthDeleteEntryTitle => 'Delete entry?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return '$value from $date will be removed.';
  }

  @override
  String get healthLogEntry => 'Log entry';

  @override
  String healthLoadFailed(String error) {
    return 'Unable to load: $error';
  }

  @override
  String get healthEntries => 'Entries';

  @override
  String get healthNoEntries => 'No entries yet';

  @override
  String healthFirstEntry(String name) {
    return 'Log your first $name measurement.';
  }

  @override
  String get workoutReportLoadFailed => 'Unable to load workout report.';

  @override
  String get workoutReportTitle => 'Workout Report';

  @override
  String get workoutReportAdditionalDetails => 'Additional Details';

  @override
  String get recommendedSetsEdit => 'Edit recommended sets';

  @override
  String get recommendedSetsTitle => 'Recommended sets';

  @override
  String get recommendedSetsMinimum => 'Minimum recommended sets';

  @override
  String get recommendedSetsMaximum => 'Maximum recommended sets';

  @override
  String get recommendedSetsValidNumbers => 'Enter valid set numbers.';

  @override
  String get recommendedSetsNonNegative => 'Set numbers cannot be negative.';

  @override
  String get recommendedSetsRange => 'Maximum must be at least the minimum.';

  @override
  String get workoutReportWorkouts => 'Workouts';

  @override
  String get workoutReportTime => 'Time';

  @override
  String get workoutReportVolume => 'Volume';

  @override
  String get workoutReportWorkout => 'workout';

  @override
  String get workoutReportTotal => 'total';

  @override
  String get databaseSettingsTitle => 'Database Settings';

  @override
  String get databaseSettingsSubtitle => 'Backups, cloud media, health checks, and developer exports.';

  @override
  String get databaseBackupRestore => 'Backup & Restore';

  @override
  String get databaseBackupRestoreSubtitle => 'Move your local Tonos data in or out safely.';

  @override
  String get databaseExportBackup => 'Export Database Backup';

  @override
  String get databaseImportBackup => 'Import Database Backup';

  @override
  String get databaseImportBackupSubtitle => 'Replace local data from a saved export file.';

  @override
  String get databaseHealth => 'Health';

  @override
  String get databaseHealthSubtitle => 'A quick read on database size, schema, and search index state.';

  @override
  String get databaseCheckingHealth => 'Checking database health...';

  @override
  String get databaseCheckingHealthSubtitle => 'Reading schema, size, tables, and indexes.';

  @override
  String get databaseHealthFailed => 'Database health check failed';

  @override
  String get databaseMaintenance => 'Maintenance';

  @override
  String get databaseMaintenanceSubtitle => 'Safe tools for checks, optimization, and storage cleanup.';

  @override
  String get databaseRefreshHealth => 'Refresh Health';

  @override
  String get databaseIntegrityCheck => 'Run Integrity Check';

  @override
  String get databaseIntegrityCheckSubtitle => 'Ask SQLite to verify the local database file.';

  @override
  String get databaseOptimize => 'Optimize Database';

  @override
  String get databaseCheckpointWal => 'Checkpoint WAL';

  @override
  String get databaseCheckpointWalSubtitle => 'Flushes the write-ahead log into the database file.';

  @override
  String get databaseVacuum => 'Vacuum Database';

  @override
  String get databaseVacuumSubtitle => 'Reclaims free space after large deletes/imports.';

  @override
  String get databaseCloudContent => 'Cloud Content';

  @override
  String get databaseCloudContentSubtitle => 'Manage exercise, equipment, and anatomy media storage.';

  @override
  String get databaseWifiOnly => 'Wi-Fi Only Downloads';

  @override
  String get databaseWifiOnlySubtitle => 'New thumbnails and videos download only on Wi-Fi. Cached media still works offline.';

  @override
  String get databaseSyncExerciseMedia => 'Sync Remote Exercise Media';

  @override
  String get databaseSyncSharedMedia => 'Sync Shared Catalog Media';

  @override
  String get databaseSyncSharedMediaSubtitle => 'Equipment, bodypart, and muscle illustrations.';

  @override
  String get databaseClearMediaCache => 'Clear Downloaded Media Cache';

  @override
  String get databaseClearMediaCacheSubtitle => 'Removes cached remote media files from this device.';

  @override
  String get databaseDefinitionExports => 'Definition Exports';

  @override
  String get databaseDefinitionExportsSubtitle => 'Export app definition files for inspection or tooling.';

  @override
  String get exerciseEditorTitle => 'Exercise Editor';

  @override
  String get exerciseEditorLoadFailed => 'Exercise definitions could not load.';

  @override
  String get exerciseEditorChoose => 'Choose exercise';

  @override
  String get exerciseEditorEdit => 'Edit definition';

  @override
  String get exerciseEditorCreate => 'Create custom exercise';

  @override
  String get exerciseEditorSaveChanges => 'Save changes';

  @override
  String get exerciseEditorSaving => 'Saving';

  @override
  String get exerciseEditorMuscles => 'Muscles';

  @override
  String get exerciseEditorBodyparts => 'Bodyparts';

  @override
  String get exerciseEditorEquipment => 'Equipment';

  @override
  String get exerciseEditorGuide => 'Guide';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name is already shown.';
  }

  @override
  String get exerciseProgressTrendTitle => '1RM trend';

  @override
  String get exerciseProgressTrendBody => 'This chart compares actual recorded 1RM and estimated 1RM over time. Tap points for exact values.';

  @override
  String get exerciseProgressRecordings => 'Recordings';

  @override
  String get exerciseProgressRecordingsBody => 'Each recording opens the workout where that lift happened, so you can review the full context.';

  @override
  String get exerciseProgressTitle => '1RM Progress';

  @override
  String get exerciseProgressEmpty => 'Complete this exercise to start building progress history.';

  @override
  String get exerciseProgressActual => 'Actual 1RM';

  @override
  String get exerciseProgressEstimated => 'Estimated 1RM';

  @override
  String get exerciseProgressSessionOpenFailed => 'Workout session could not be opened.';

  @override
  String get exerciseProgressSessionMissing => 'Workout session could not be found.';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'Est. $value';
  }

  @override
  String get exerciseProgressNoActual => 'No actual 1RM';

  @override
  String exerciseProgressActualValue(String value) {
    return 'Actual $value';
  }

  @override
  String get musclePercentTitle => '% Hit per Muscle';

  @override
  String musclePercentLoadFailed(String error) {
    return 'Failed to load entries: $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'Failed to update percent: $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'Failed to reset to default: $error';
  }

  @override
  String musclePercentError(String error) {
    return 'Error: $error';
  }

  @override
  String get musclePercentNoExercises => 'No exercises defined';

  @override
  String get musclePercentEmpty => 'No muscle percentages set';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'Revert to default';

  @override
  String get sevenDayFocusTitle => 'Weekly Overview';

  @override
  String get sevenDayFocusLoadFailed => 'Unable to load 7-day focus';

  @override
  String get sevenDayFocusEmpty => 'No completed bodypart set units in the last 7 days.';

  @override
  String get sevenDayFocusMore => 'more';

  @override
  String get pastSessionsWeek => 'Week';

  @override
  String get pastSessionsMonth => 'Month';

  @override
  String get pastSessionsYear => 'Year';

  @override
  String get pastSessionsAll => 'All';

  @override
  String get pastSessionsShow => 'Show:';

  @override
  String get pastSessionsFullscreen => 'Fullscreen';

  @override
  String pastSessionsError(String error) {
    return 'Error: $error';
  }

  @override
  String get pastSessionsEmpty => 'No sessions yet.';

  @override
  String pastSessionsItem(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get historySummaryLoadFailed => 'Error loading history';

  @override
  String get historySummaryWorkouts => 'Workouts';

  @override
  String get historySummaryTotalTime => 'Total Time';

  @override
  String get historySummaryTotalVolume => 'Total Volume';

  @override
  String get planCoachSkipGuide => 'Skip guide';

  @override
  String get planCoachContinue => 'Continue';

  @override
  String get trainOptimizedSettingsTitle => 'Optimized workout settings';

  @override
  String get trainOptimizedSettingsBudgetBody => 'Used to budget 3 minutes per set plus 5 minutes to start each exercise.';

  @override
  String get trainOptimizedSettingsFocusBody => 'Bodypart picks apply only to the next optimized workout you start.';

  @override
  String get trainWorkoutDuration => 'Workout duration';

  @override
  String get trainMinutesShort => 'min';

  @override
  String get trainSetsPerExercise => 'Up to sets per exercise';

  @override
  String get trainSetsShort => 'sets';

  @override
  String get trainBodypartFocus => 'Bodypart focus';

  @override
  String get trainBodypartFocusHelp => 'Tap once to prefer a bodypart, tap again to avoid it, and tap a third time to clear it.';

  @override
  String get trainBodypartsLoadFailed => 'Bodyparts could not be loaded.';

  @override
  String get trainPlanGenerated => 'Plan generated. Opening it now.';

  @override
  String trainPlansGenerated(int count) {
    return 'Generated $count plans.';
  }

  @override
  String get trainActiveWorkoutKept => 'Another workout is already active, so it was kept unchanged.';

  @override
  String get trainMenuTitle => 'Training Menu';

  @override
  String get trainExerciseCatalog => 'Exercise Catalog';

  @override
  String get trainMuscleFilter => 'Muscle Filter';

  @override
  String get trainGymSettings => 'Gym & Workout Settings';

  @override
  String get trainTab => 'Train';

  @override
  String get trainHistoryTab => 'History';

  @override
  String get trainExercisePresets => 'Exercise Presets';

  @override
  String get trainGeneratePlans => 'Generate Custom Plans';

  @override
  String get trainAddPlan => 'Manually Add Preset';

  @override
  String get trainNewPlanFirst => 'New Preset';

  @override
  String trainNewPlan(int number) {
    return 'New Preset $number';
  }

  @override
  String get trainBuildingOptimized => 'Building Optimized Workout...';

  @override
  String get trainStartOptimized => 'Start Optimized Workout';

  @override
  String get trainNewSession => 'New Session';

  @override
  String get foodCustomizationTitle => 'Customize Food';

  @override
  String get foodCustomizationEditTitle => 'Edit Food';

  @override
  String get foodCustomizationName => 'Food Name';

  @override
  String get foodCustomizationEnterName => 'Enter a name';

  @override
  String get foodCustomizationBrand => 'Brand';

  @override
  String get foodCustomizationFoodPhoto => 'Food Photo';

  @override
  String get foodCustomizationLabelPhoto => 'Label Photo';

  @override
  String get foodCustomizationDensity => 'Density (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'Used to convert mL-based portions (cups, tbsp) into grams for macro math.';

  @override
  String get foodCustomizationCalories => 'Calories (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'Macronutrients';

  @override
  String get foodCustomizationMicronutrients => 'Micronutrients';

  @override
  String get foodCustomizationAdditionalComponents => 'Additional Components';

  @override
  String get foodCustomizationPortionInfo => 'Portion Info';

  @override
  String get foodCustomizationBasisPortion => 'Portioning basis for the nutritional values';

  @override
  String get foodCustomizationUsualPortion => 'Usual portion to be consumed by user';

  @override
  String get foodCustomizationAddPortion => 'Add portion';

  @override
  String get foodCustomizationUnit => 'Unit';

  @override
  String get foodCustomizationAmount => 'Amount';

  @override
  String get foodCustomizationWeight => 'Weight (g)';

  @override
  String get foodCustomizationVolume => 'Volume (mL)';

  @override
  String get dashboardArchivedPlans => 'Archived Plans';

  @override
  String get dashboardActivePlans => 'Active Plans';

  @override
  String get dashboardManagePlans => 'Manage plans';

  @override
  String get dashboardSelectProfilePlans => 'Select a gym profile to view its plans.';

  @override
  String get dashboardNoArchivedPlans => 'No archived plans for this profile.';

  @override
  String get dashboardNoActivePlans => 'No active plans yet. Use the pen to choose plans.';

  @override
  String dashboardPremadeCount(int count) {
    return '$count ready-to-use routines are available to add.';
  }

  @override
  String get dashboardBrowsePremadePlans => 'Browse Premade Plans';

  @override
  String get dashboardNewPlanFirst => 'New Plan';

  @override
  String dashboardNewPlan(int number) {
    return 'New Plan $number';
  }

  @override
  String get dashboardPlanTools => 'Plan Tools';

  @override
  String get dashboardPlanToolsBody => 'Build a plan from your training preferences or start a blank one.';

  @override
  String get dashboardManual => 'Manual';

  @override
  String get dashboardGenerate => 'Generate';

  @override
  String get dashboardMostUsedExercises => 'Most used exercises';

  @override
  String get dashboardMostUsedExercisesEmpty => 'Complete workouts to see your most common exercises here.';

  @override
  String premadeDiscardFailed(String error) {
    return 'Could not discard added plans: $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'Select a gym profile to adapt plans to available equipment.';

  @override
  String get premadeEquipmentExact => 'Premade plans are shown exactly as written.';

  @override
  String get premadeEquipmentChecking => 'Checking plan exercises against your profile...';

  @override
  String get premadeEquipmentMissing => 'No profile equipment found, so premade plans are unchanged.';

  @override
  String premadeEquipmentReplacements(int count) {
    return '$count unavailable exercise(s) will be swapped when plans are added.';
  }

  @override
  String get premadeEquipmentFits => 'Plans already fit the current profile equipment.';

  @override
  String get premadeOneHour => '1 hr';

  @override
  String get premadeTwoHours => '2 hr';

  @override
  String premadePlansAvailable(int count) {
    return '$count plan(s) available';
  }

  @override
  String get premadeNoTemplates => 'No plan templates yet';

  @override
  String premadePlansCount(int count) {
    return '$count plan(s)';
  }

  @override
  String get premadeTemplatesLater => 'Templates for this split can be added here later.';

  @override
  String premadeExerciseCount(int count) {
    return '$count exercises';
  }

  @override
  String premadeSetCount(int count) {
    return '$count sets';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$count swapped';
  }

  @override
  String get premadeAdding => 'Adding';

  @override
  String get premadeChecking => 'Checking';

  @override
  String get premadeProfileSwap => 'profile swap';

  @override
  String get healthEntryValueUnitRequired => 'Enter a value and unit first.';

  @override
  String get healthDefinitionFieldsRequired => 'Enter a name, unit, and valid value.';

  @override
  String get healthUnit => 'Unit';

  @override
  String get healthNote => 'Note';

  @override
  String get healthOptional => 'Optional';

  @override
  String get healthMetricName => 'Metric name';

  @override
  String get healthMetricNameHint => 'Arm size, resting heart rate...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'in, $weightUnit, %, bpm...';
  }

  @override
  String get healthStartingValue => 'Starting value';

  @override
  String get healthCreate => 'Create';

  @override
  String get exerciseProgressNoRecordings => 'No recordings yet';

  @override
  String get exerciseEditorDiscardTitle => 'Discard changes?';

  @override
  String get exerciseEditorDiscardBody => 'Your edits are not saved yet. You can keep editing or discard them.';

  @override
  String get exerciseEditorKeepEditing => 'Keep editing';

  @override
  String get exerciseEditorDiscard => 'Discard';

  @override
  String get exerciseEditorAddBodyparts => 'Add Associated Bodyparts';

  @override
  String get exerciseEditorAddMuscles => 'Add Associated Muscles';

  @override
  String get exerciseEditorAddEquipment => 'Add Equipment';

  @override
  String get databaseClearMediaTitle => 'Clear Downloaded Media?';

  @override
  String get databaseClearMediaBody => 'This removes cached exercise, equipment, and anatomy media. The app can download them again when needed.';

  @override
  String get databaseClearCache => 'Clear Cache';

  @override
  String get databaseCacheCleared => 'Downloaded media cache cleared.';

  @override
  String databaseClearCacheFailed(String error) {
    return 'Clear cache failed: $error';
  }

  @override
  String get databaseContentEnvironment => 'Content Environment';

  @override
  String get databaseLoadingEnvironment => 'Loading environment...';

  @override
  String get databaseChangeEnvironment => 'Change environment';

  @override
  String get databaseExerciseManifestUrl => 'Exercise Media Manifest URL';

  @override
  String get databaseNoExerciseManifestUrl => 'No remote manifest URL set for this environment.';

  @override
  String get databaseOverrideUrl => 'Override URL';

  @override
  String get databaseNoManifestSynced => 'No Manifest Synced';

  @override
  String databaseManifestVersion(int version) {
    return 'Manifest v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'Last checked: $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'Shared Catalog Media';

  @override
  String get databaseSharedMediaNotSynced => 'Not synced yet. Equipment, bodyparts, and muscles.';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'Manifest v$version. Last checked: $date';
  }

  @override
  String get databaseSharedManifestUrl => 'Shared Media Manifest URL';

  @override
  String get databaseNoSharedManifestUrl => 'No remote shared media URL set for this environment.';

  @override
  String get databaseDownloadedMediaCache => 'Downloaded Media Cache';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count files, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'Load Bundled Manifest';

  @override
  String get databaseTutorialFilesTitle => 'Database files';

  @override
  String get databaseTutorialFilesBody => 'Export a backup or import a saved database file. Imports require a backup first.';

  @override
  String get databaseTutorialHealthTitle => 'Database health';

  @override
  String get databaseTutorialHealthBody => 'This card shows schema version, database size, table counts, and search-index health.';

  @override
  String get databaseTutorialMaintenanceTitle => 'Maintenance tools';

  @override
  String get databaseTutorialMaintenanceBody => 'Use these actions for integrity checks, optimization, WAL checkpointing, or vacuuming when needed.';

  @override
  String get databaseExportSavedTitle => 'Database Export Saved';

  @override
  String get databaseExportSavedBody => 'The database export was saved to your selected location.';

  @override
  String databaseImportBlocked(String message) {
    return 'Import blocked: $message';
  }

  @override
  String get databaseImportBackupCanceled => 'Import canceled: backup was not saved.';

  @override
  String get databaseImportSucceededTitle => 'Import Succeeded';

  @override
  String databaseImportSucceededBody(String name) {
    return 'Imported $name. A backup of the previous local database was saved to your selected location first.';
  }

  @override
  String get databaseConfirmImportTitle => 'Confirm Import';

  @override
  String get databaseConfirmImportBody => 'This replaces the local database. A backup file of the current database will be written first.';

  @override
  String databaseImportFile(String name) {
    return 'File: $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'Tables: $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'Rows: $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'Export schema: v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'Format: legacy table map';

  @override
  String get databaseImportWarnings => 'Warnings:';

  @override
  String get databaseBackupAndImport => 'Back Up & Import';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'Database maintenance failed: $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'Save or cancel definition changes before editing set credit.';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return 'Remove $type?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return 'Remove \"$name\" from this exercise definition?';
  }

  @override
  String get exerciseEditorKeep => 'Keep';

  @override
  String get exerciseEditorMuscleOrderTitle => 'Target muscle order';

  @override
  String get exerciseEditorMuscleOrderBody => 'Order muscles by how strongly the exercise targets them. This helps Tonos estimate anatomy focus and make better exercise recommendations.';

  @override
  String get exerciseEditorExactSetCredit => 'Exact set credit';

  @override
  String get exerciseEditorExactSetCreditBody => 'Change the precise credit one set gives each muscle or body part in Exercise Set Allocation.';

  @override
  String get exerciseEditorSetCreditScaling => 'Set-credit scaling';

  @override
  String get exerciseEditorSetCreditScalingBody => 'Choose whether this exercise rating scales set credit.';

  @override
  String get exerciseEditorScaleCreditByRating => 'Scale credit by rating';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'Applies the exercise rating to analytic set totals.';

  @override
  String get exerciseEditorTargetMuscles => 'Target muscles';

  @override
  String get exerciseEditorOrderMusclesHint => 'Use arrows to order muscles by target emphasis.';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return '$count muscles currently associated.';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'No target muscles are associated yet.';

  @override
  String get exerciseEditorAddTargetMuscles => 'Add target muscles';

  @override
  String get exerciseEditorMoveUp => 'Move up';

  @override
  String get exerciseEditorMoveDown => 'Move down';

  @override
  String get exerciseEditorRemoveMuscle => 'Remove muscle';

  @override
  String get exerciseEditorMuscleItem => 'muscle';

  @override
  String get exerciseEditorAssociatedBodyparts => 'Associated body parts';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'These broad areas drive body heatmaps, weekly coverage, and equipment-aware workout recommendations.';

  @override
  String get exerciseEditorExactBodypartCredit => 'Exact body-part credit';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'Use Exercise Set Allocation when a set should count as a specific partial amount for a body part.';

  @override
  String get exerciseEditorBodypartsHint => 'Add every broad body area this exercise trains.';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return '$count body parts currently associated.';
  }

  @override
  String get exerciseEditorNoBodyparts => 'No body parts are associated yet.';

  @override
  String get exerciseEditorAutomaticPreview => 'Automatic preview';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'Current focus derived from the target-muscle structure.';

  @override
  String get exerciseEditorRemoveBodypart => 'Remove body part';

  @override
  String get exerciseEditorBodypartItem => 'body part';

  @override
  String get exerciseEditorAvailableEquipment => 'Available equipment';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'Associated equipment determines which profiles can use this exercise and which replacements Tonos can recommend.';

  @override
  String get exerciseEditorEquipmentHint => 'Add every item needed to perform this exercise.';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '$count items associated.';
  }

  @override
  String get exerciseEditorNoEquipment => 'No equipment is associated yet.';

  @override
  String get exerciseEditorRemoveEquipment => 'Remove equipment';

  @override
  String get exerciseEditorEquipmentItem => 'equipment';

  @override
  String get historySummaryAll => 'All';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'Add a valid exercise media manifest URL first.';

  @override
  String databaseContentSyncFailed(String error) {
    return 'Content sync failed: $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'Bundled content sync failed: $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'This content environment has no shared media URL.';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'Shared content sync failed: $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return 'Export $filename failed: $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'Exercise Media Manifest';

  @override
  String get databaseManifestUrl => 'Manifest URL';

  @override
  String get databaseClear => 'Clear';

  @override
  String get databaseNoManifestConfigured => 'No manifest URL configured yet.';

  @override
  String get databaseUseEnvironment => 'Use Environment';

  @override
  String get dashboardTargetAnatomy => 'Target Anatomy';

  @override
  String get dashboardBodyparts => 'Bodyparts';

  @override
  String get dashboardMuscles => 'Muscles';

  @override
  String get exerciseEditorCreateCustomTitle => 'Create custom exercise';

  @override
  String get exerciseEditorCreateCustomBody => 'Create a custom catalog definition, then add its target anatomy and guidance before saving.';

  @override
  String get exerciseEditorExerciseName => 'Exercise name';

  @override
  String get exerciseEditorNoEquipmentChoice => 'No equipment';

  @override
  String get exerciseEditorOpenedMessage => 'Exercise opened. Add its target anatomy, then save.';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'Could not create the custom exercise. $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'What this changes';

  @override
  String get exerciseEditorWhatChangesBody => 'Use this advanced editor to update an exercise name, target anatomy, equipment, form guidance, rating, and reference media. Exact per-set credit is managed separately so it stays consistent across the app.';

  @override
  String get exerciseEditorChooseCatalog => 'Choose an exercise from the catalog';

  @override
  String get exerciseEditorRating => 'Rating';

  @override
  String get databaseNever => 'Never';

  @override
  String databaseExportDefinition(String filename) {
    return 'Export $filename';
  }

  @override
  String get exerciseEditorAddMedia => 'Add media';

  @override
  String get exerciseEditorEditMedia => 'Edit media';

  @override
  String get exerciseEditorMediaImage => 'Image';

  @override
  String get exerciseEditorMediaVideo => 'Video';

  @override
  String get exerciseEditorMediaLink => 'Link';

  @override
  String get exerciseEditorMediaType => 'Type';

  @override
  String get exerciseEditorMediaTitle => 'Title';

  @override
  String get exerciseEditorMediaTitleHint => 'Optional display label';

  @override
  String get exerciseEditorMediaRemoteUrl => 'Remote URL';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'Thumbnail URL';

  @override
  String get exerciseEditorMediaThumbnailHint => 'Optional image preview URL';

  @override
  String get exerciseEditorSelectBeforeMedia => 'Select an existing exercise before attaching media.';

  @override
  String get exerciseEditorFormGuide => 'Form guide';

  @override
  String get exerciseEditorFormGuideBody => 'These notes appear in the exercise details sheet to help people set up, perform, and understand the movement safely.';

  @override
  String get exerciseEditorGuidance => 'Guidance';

  @override
  String get exerciseEditorGuidanceEditing => 'Write clear, practical cues. Changes are staged until saved.';

  @override
  String get exerciseEditorGuidanceReadOnly => 'The current exercise instructions and cues.';

  @override
  String get exerciseEditorSetUp => 'Set up';

  @override
  String get exerciseEditorSetUpHint => 'Starting position, equipment setup, and safety notes.';

  @override
  String get exerciseEditorHowToPerform => 'How to perform';

  @override
  String get exerciseEditorHowToPerformHint => 'The key movement steps and range of motion.';

  @override
  String get exerciseEditorCoachingTips => 'Coaching tips';

  @override
  String get exerciseEditorCoachingTipsHint => 'Helpful cues, common mistakes, and variations.';

  @override
  String get exerciseEditorReferenceMedia => 'Reference media';

  @override
  String get exerciseEditorReferenceMediaBody => 'Use media links for private reference material. Managed catalog media can be refreshed by the content sync pipeline.';

  @override
  String get exerciseEditorMediaLinks => 'Media links';

  @override
  String get exerciseEditorMediaLinksEditing => 'Add or update a remote image, video, or reference link.';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return '$count media item(s) currently linked.';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'No reference media is linked yet.';

  @override
  String get exerciseEditorAddMediaLink => 'Add media link';

  @override
  String get exerciseEditorRemoveMedia => 'Remove media';

  @override
  String get exerciseEditorMediaLinkItem => 'media link';

  @override
  String exerciseEditorMediaReference(String type) {
    return '$type reference';
  }

  @override
  String get bengaliBangladeshLanguage => 'Bangla (Bangladesh)';

  @override
  String get simplifiedChineseLanguage => 'Chinese (Simplified)';

  @override
  String get hindiLanguage => 'Hindi';

  @override
  String get spanishLanguage => 'Spanish';

  @override
  String get onboardingWeightHistoryTitle => 'Weight history';

  @override
  String get onboardingWeightHistorySubtitle => 'A few details help estimate nutrition targets more sensibly.';

  @override
  String get onboardingPreviouslyHeavier => 'Have you weighed 10+ lbs above your current weight before?';

  @override
  String get onboardingWeightTrendTitle => 'Current weight trend';

  @override
  String get onboardingWeightTrendGaining => 'Gaining weight';

  @override
  String get onboardingWeightTrendLosing => 'Losing weight';

  @override
  String get onboardingWeightTrendMaintaining => 'Maintaining weight';

  @override
  String get onboardingNotSure => 'Not sure';

  @override
  String get onboardingBodyFatEstimateTitle => 'Body-fat estimate';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'Choose the closest visual estimate. Precision is not required.';

  @override
  String get onboardingNutritionPreferencesTitle => 'Nutrition preferences';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'These preferences shape nutrition suggestions after setup.';

  @override
  String get onboardingPreferredDiet => 'Preferred diet';

  @override
  String get onboardingDietBalanced => 'Balanced';

  @override
  String get onboardingDietLowFat => 'Low fat';

  @override
  String get onboardingDietLowCarb => 'Low carb';

  @override
  String get onboardingDietKeto => 'Keto';

  @override
  String get onboardingCalorieFloor => 'Calorie floor';

  @override
  String get onboardingCalorieFloorHint => 'Minimum daily kcal';

  @override
  String get onboardingTrainingDuringProgram => 'Training during program';

  @override
  String get onboardingTrainingNone => 'None';

  @override
  String get onboardingTrainingLifting => 'Lifting';

  @override
  String get onboardingTrainingCardio => 'Cardio';

  @override
  String get onboardingTrainingLiftingAndCardio => 'Lifting and cardio';

  @override
  String get onboardingProteinPreference => 'Preferred protein intake';

  @override
  String get onboardingProteinLow => 'Low';

  @override
  String get onboardingProteinModerate => 'Moderate';

  @override
  String get onboardingProteinHigh => 'High';

  @override
  String get onboardingProteinVeryHigh => 'Very high';

  @override
  String get onboardingGoalPaceTitle => 'Goal pace';

  @override
  String get onboardingGoalPaceSubtitle => 'Preview a target weight and weekly goal rate.';

  @override
  String get onboardingInitialDailyBudget => 'Initial daily budget';

  @override
  String get onboardingProjectedEndDate => 'Projected end date';

  @override
  String get onboardingTargetWeight => 'Target weight';

  @override
  String get onboardingTargetGoalRate => 'Target goal rate';

  @override
  String get onboardingPerWeek => 'Per week';

  @override
  String get onboardingPerMonth => 'Per month';

  @override
  String get exerciseProgressTrackExercise => 'Track an exercise';

  @override
  String get exerciseProgressTrackExerciseBody => 'Choose an exercise to start watching its 1RM trend here.';

  @override
  String get healthCustomMetric => 'Custom metric';

  @override
  String get healthLatest => 'Latest';

  @override
  String get healthNoEntry => 'No entry';

  @override
  String get healthNotTrackedYet => 'Not tracked yet';

  @override
  String get healthChange => 'Change';

  @override
  String get healthNeedTwoEntries => 'Need 2 entries';

  @override
  String get healthVersusPrevious => 'Vs previous';

  @override
  String get healthRecords => 'Records';

  @override
  String get presetEstimatedTime => 'Estimated time';

  @override
  String get presetNoFocusData => 'No focus data yet.';

  @override
  String get presetFocusPreviewHelp => 'Add weight exercises with bodypart data to preview preset focus.';

  @override
  String get dashboardReorderHelp => 'Drag sections into the order that works best for you.';

  @override
  String get exerciseEditorCachedLocally => 'Cached locally';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return 'Synced $count exercise media entries (v$version).';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'Loaded bundled exercise media manifest (v$version).';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return 'Synced $count equipment and anatomy media entries (v$version).';
  }

  @override
  String get databaseHealthSchema => 'Schema';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / target v$target';
  }

  @override
  String get databaseHealthSize => 'Size';

  @override
  String get databaseHealthJournal => 'Journal';

  @override
  String get databaseHealthTables => 'Tables';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables tables, $indexes indexes, $triggers triggers';
  }

  @override
  String get databaseHealthFoodSearch => 'Food search';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods foods, $rows FTS rows';
  }

  @override
  String get databaseHealthPath => 'Path';

  @override
  String get dashboardWorkoutInProgress => 'Workout in progress';

  @override
  String get dashboardNoSavedPlans => 'No plans saved for this gym profile yet.';

  @override
  String get exerciseProgressOneRepMax => '1 Rep Max';

  @override
  String get exerciseProgressEstimatedOneRepMax => 'Est. 1RM';

  @override
  String get onboardingPageWeight => 'Weight';

  @override
  String get onboardingPageBodyFat => 'Body Fat';

  @override
  String get onboardingPageNutrition => 'Nutrition';

  @override
  String get onboardingPageGoal => 'Goal';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return '$count/$total this week';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return '$count all time';
  }

  @override
  String get dashboardVisualBodyFat => 'Visual Body Fat';

  @override
  String get dashboardNewMetric => 'New Metric';

  @override
  String get dashboardCurrentMetrics => 'Current Metrics';

  @override
  String get workoutReportDay => 'day';

  @override
  String get workoutReportDays => 'days';

  @override
  String get workoutReportWeek => 'week';

  @override
  String get workoutReportMonth => 'month';

  @override
  String workoutReportAveragePer(String period) {
    return 'Avg / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'workouts';

  @override
  String get workoutReportLongestStreak => 'Longest streak';

  @override
  String get workoutReportMostActive => 'Most active';

  @override
  String get workoutReportNoSessions => 'no sessions';

  @override
  String get workoutReportWeekday => 'weekday';

  @override
  String workoutReportMetricSemantics(String label) {
    return '$label report metric';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit logged';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$unit on $date';
  }

  @override
  String get profileDiagnosticsTitle => 'Diagnostics & Privacy';

  @override
  String get profileDiagnosticsSubtitle => 'Version, anonymous-diagnostics consent, sync history, and data deletion.';

  @override
  String get diagnosticsTitle => 'Diagnostics & Privacy';

  @override
  String get diagnosticsSubtitle => 'Understand and control release diagnostics.';

  @override
  String get diagnosticsAppSection => 'App information';

  @override
  String get diagnosticsAppSectionSubtitle => 'Useful when reporting a problem.';

  @override
  String get diagnosticsVersion => 'Version and build';

  @override
  String get diagnosticsLoading => 'Loading...';

  @override
  String get diagnosticsUnavailable => 'Unavailable';

  @override
  String get diagnosticsCrashSection => 'Anonymous diagnostics';

  @override
  String get diagnosticsCrashSectionSubtitle => 'Optional, categorical reports for app faults and media sync.';

  @override
  String get diagnosticsCrashReporting => 'Share anonymous diagnostics';

  @override
  String get diagnosticsCrashUnavailable => 'Not configured in this build. No anonymous diagnostics can be shared.';

  @override
  String get diagnosticsCrashEnabledBody => 'Enabled with your consent. Turning it off requests deletion of reports held by Tonos.';

  @override
  String get diagnosticsCrashDisabledBody => 'Off by default. Turn it on only if you want to help diagnose release problems.';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'Privacy by design';

  @override
  String get diagnosticsPrivacyPromiseBody => 'Reports contain only the app version, build number, platform, approved category, outcome, and coarse buckets. They never include error messages, stack traces, names, health data, database contents, screenshots, network addresses, traces, or analytics.';

  @override
  String get diagnosticsSyncSection => 'Content sync history';

  @override
  String get diagnosticsSyncSectionSubtitle => 'The 30 most recent media-manifest outcomes are kept only on this device.';

  @override
  String get diagnosticsNoSyncEvents => 'No sync diagnostics yet';

  @override
  String get diagnosticsNoSyncEventsBody => 'Exercise and shared-media sync outcomes will appear here without URLs or personal data.';

  @override
  String get diagnosticsClearHistory => 'Clear sync history';

  @override
  String get diagnosticsClearHistoryBody => 'Remove all locally stored sync diagnostic entries.';

  @override
  String get diagnosticsHistoryCleared => 'Sync diagnostic history cleared.';

  @override
  String get diagnosticsExerciseMedia => 'Exercise media';

  @override
  String get diagnosticsSharedMedia => 'Shared media';

  @override
  String get diagnosticsRemoteSource => 'Remote';

  @override
  String get diagnosticsBundledSource => 'Bundled';

  @override
  String get diagnosticsSyncSucceeded => 'Succeeded';

  @override
  String get diagnosticsSyncFailed => 'Failed';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation: $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration ms • manifest $version • $items items';
  }

  @override
  String get diagnosticsPrivacySection => 'Your data';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'Local storage, retention, and deletion.';

  @override
  String get diagnosticsLocalDataTitle => 'Fitness data stays local';

  @override
  String get diagnosticsLocalDataBody => 'Workout, nutrition, body metric, and profile records remain in the app database on this device unless you export a backup yourself.';

  @override
  String get diagnosticsDeletionTitle => 'Delete diagnostic and app data';

  @override
  String get diagnosticsDeletionBody => 'Clear sync history above and turn off anonymous diagnostics to request deletion of reports shared by this installation. Clear Tonos storage in device settings or uninstall Tonos to remove the local database and caches.';

  @override
  String get diagnosticsSendTestReport => 'Send a controlled diagnostics event';

  @override
  String get diagnosticsSendTestReportBody => 'Available only in an explicitly test-enabled build. It sends one fixed allowlisted event.';

  @override
  String get diagnosticsTestReportSent => 'Controlled diagnostics event sent.';

  @override
  String get diagnosticsTestReportFailed => 'The diagnostics event could not be sent. Check the build configuration and connection.';

  @override
  String get diagnosticsDeleteShared => 'Delete shared diagnostics';

  @override
  String get diagnosticsDeleteSharedBody => 'Requests deletion of reports this app can prove it sent. Provider recovery history may retain deleted rows for up to 30 days.';

  @override
  String get diagnosticsSharedDeleted => 'Shared diagnostics deletion requested.';

  @override
  String get diagnosticsSharedDeletionPending => 'Some deletion requests will retry when the app opens with a connection.';

  @override
  String get workoutDurabilityRestoreWarning => 'Tonos could not check for a saved workout. Retry before starting another workout.';

  @override
  String get workoutDurabilityDraftSaveWarning => 'Your workout backup is not up to date. Keep Tonos open and retry so this workout can be resumed safely.';

  @override
  String get workoutDurabilityProgressionWarning => 'Your workout is saved, but plan progression is still pending. Retry when storage is available.';

  @override
  String get databaseConfirmExportTitle => 'Export private data?';

  @override
  String get databaseConfirmExportBody => 'This backup is an unencrypted JSON file that can contain your workouts, nutrition, body metrics, profile, and preferences. Save it only to a location you trust.';

  @override
  String get databaseContinueExport => 'Export anyway';

  @override
  String get databaseExportFailedSafe => 'The database export could not be created. Your app data is unchanged.';

  @override
  String get databaseImportFileTooLarge => 'This import is too large. Choose a database backup smaller than 25 MB.';

  @override
  String get databaseImportBlockedSafe => 'This database backup could not be imported. Your current app data is unchanged.';

  @override
  String get databaseImportFailedSafe => 'The database import did not finish. Your current app data was kept safe.';
}
