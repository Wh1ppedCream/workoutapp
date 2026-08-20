import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('fr', 'CA'),
    Locale('hi'),
    Locale('zh'),
  ];

  /// No description provided for @onboardingBodyWeightPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{percent}% BW/wk'**
  String onboardingBodyWeightPerWeek(String percent);

  /// No description provided for @dashboardExerciseFallback.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get dashboardExerciseFallback;

  /// No description provided for @dashboardExerciseUsage.
  ///
  /// In en, this message translates to:
  /// **'{equipment} - {count, plural, =1 {1 time} other {{count} times}}'**
  String dashboardExerciseUsage(String equipment, int count);

  /// No description provided for @weightCardSetsDone.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} done'**
  String weightCardSetsDone(int completed, int total);

  /// No description provided for @bodyHeatmapSemantics.
  ///
  /// In en, this message translates to:
  /// **'{bodyPart} body heatmap'**
  String bodyHeatmapSemantics(String bodyPart);

  /// No description provided for @focusedSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focused Sets'**
  String get focusedSetsTitle;

  /// No description provided for @bodyPartNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get bodyPartNeck;

  /// No description provided for @bodyPartShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get bodyPartShoulders;

  /// No description provided for @bodyPartChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodyPartChest;

  /// No description provided for @bodyPartCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get bodyPartCore;

  /// No description provided for @bodyPartUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get bodyPartUpperBack;

  /// No description provided for @bodyPartLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get bodyPartLowerBack;

  /// No description provided for @bodyPartBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get bodyPartBiceps;

  /// No description provided for @bodyPartTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get bodyPartTriceps;

  /// No description provided for @bodyPartForearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get bodyPartForearms;

  /// No description provided for @bodyPartHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get bodyPartHips;

  /// No description provided for @bodyPartHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get bodyPartHamstrings;

  /// No description provided for @bodyPartQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get bodyPartQuads;

  /// No description provided for @bodyPartCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get bodyPartCalves;

  /// No description provided for @databaseSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Save {filename}'**
  String databaseSaveFile(String filename);

  /// No description provided for @databaseFileSaved.
  ///
  /// In en, this message translates to:
  /// **'{filename} was saved to your selected location.'**
  String databaseFileSaved(String filename);

  /// No description provided for @databaseProductionEnvironment.
  ///
  /// In en, this message translates to:
  /// **'{label} (production)'**
  String databaseProductionEnvironment(String label);

  /// No description provided for @dashboardDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 day ago} other {{count} days ago}}'**
  String dashboardDaysAgo(int count);

  /// No description provided for @workoutReportRangeOneWeekShort.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get workoutReportRangeOneWeekShort;

  /// No description provided for @workoutReportRangeOneMonthShort.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get workoutReportRangeOneMonthShort;

  /// No description provided for @workoutReportRangeThreeMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get workoutReportRangeThreeMonthsShort;

  /// No description provided for @workoutReportRangeSixMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get workoutReportRangeSixMonthsShort;

  /// No description provided for @workoutReportRangeOneYearShort.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get workoutReportRangeOneYearShort;

  /// No description provided for @workoutReportRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workoutReportRangeAll;

  /// No description provided for @workoutReportRangeOneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get workoutReportRangeOneWeek;

  /// No description provided for @workoutReportRangeOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get workoutReportRangeOneMonth;

  /// No description provided for @workoutReportRangeThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get workoutReportRangeThreeMonths;

  /// No description provided for @workoutReportRangeSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get workoutReportRangeSixMonths;

  /// No description provided for @workoutReportRangeOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get workoutReportRangeOneYear;

  /// No description provided for @workoutReportChartTitle.
  ///
  /// In en, this message translates to:
  /// **'{metric} ({period})'**
  String workoutReportChartTitle(String metric, String period);

  /// No description provided for @workoutReportWorkoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 workouts} =1 {1 workout} other {{count} workouts}}'**
  String workoutReportWorkoutCount(int count);

  /// No description provided for @workoutReportMinutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String workoutReportMinutesCount(int count);

  /// No description provided for @workoutReportHoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 hour} other {{count} hours}}'**
  String workoutReportHoursCount(int count);

  /// No description provided for @workoutReportHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String workoutReportHoursMinutes(int hours, int minutes);

  /// No description provided for @workoutReportMinuteShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get workoutReportMinuteShort;

  /// No description provided for @workoutReportHourShort.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get workoutReportHourShort;

  /// No description provided for @workoutReportNoWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get workoutReportNoWorkoutsYet;

  /// No description provided for @workoutReportNoTrainingTimeYet.
  ///
  /// In en, this message translates to:
  /// **'No training time yet'**
  String get workoutReportNoTrainingTimeYet;

  /// No description provided for @workoutReportNoVolumeYet.
  ///
  /// In en, this message translates to:
  /// **'No volume logged yet'**
  String get workoutReportNoVolumeYet;

  /// No description provided for @workoutReportNoWorkoutsBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to start building this report.'**
  String get workoutReportNoWorkoutsBody;

  /// No description provided for @workoutReportNoTrainingTimeBody.
  ///
  /// In en, this message translates to:
  /// **'Finished sessions will add minutes here automatically.'**
  String get workoutReportNoTrainingTimeBody;

  /// No description provided for @workoutReportNoVolumeBody.
  ///
  /// In en, this message translates to:
  /// **'Log weights in completed sets to build volume trends.'**
  String get workoutReportNoVolumeBody;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tonos'**
  String get appTitle;

  /// No description provided for @uiAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'UI & Appearance'**
  String get uiAppearanceTitle;

  /// No description provided for @uiAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control the way Tonos looks and how the bottom tabs behave.'**
  String get uiAppearanceSubtitle;

  /// No description provided for @displaySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySettingsTitle;

  /// No description provided for @displaySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick visual preferences.'**
  String get displaySettingsSubtitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the darker app theme.'**
  String get darkModeSubtitle;

  /// No description provided for @replayOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay Onboarding'**
  String get replayOnboardingTitle;

  /// No description provided for @replayOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn this on to open setup again. It turns off after completion.'**
  String get replayOnboardingSubtitle;

  /// No description provided for @weightUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Units'**
  String get weightUnitsTitle;

  /// No description provided for @weightUnitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show workout weights and volume in {unit}.'**
  String weightUnitsSubtitle(String unit);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language Tonos uses.'**
  String get languageSubtitle;

  /// No description provided for @systemDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefaultLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @canadianFrenchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Français (Canada)'**
  String get canadianFrenchLanguage;

  /// No description provided for @navigationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationSettingsTitle;

  /// No description provided for @navigationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which bottom tabs show up and in what order.'**
  String get navigationSettingsSubtitle;

  /// No description provided for @editBottomTabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bottom Tabs'**
  String get editBottomTabsTitle;

  /// No description provided for @editBottomTabsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder active tabs or hide unused ones.'**
  String get editBottomTabsSubtitle;

  /// No description provided for @displaySettingsTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get displaySettingsTutorialTitle;

  /// No description provided for @displaySettingsTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Control dark mode, language, replay onboarding, and switch between pounds and kilograms.'**
  String get displaySettingsTutorialBody;

  /// No description provided for @bottomTabsTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Bottom tabs'**
  String get bottomTabsTutorialTitle;

  /// No description provided for @bottomTabsTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Edit which bottom tabs are shown and the order they appear in.'**
  String get bottomTabsTutorialBody;

  /// No description provided for @onboardingPageWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingPageWelcome;

  /// No description provided for @onboardingPageBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get onboardingPageBasics;

  /// No description provided for @onboardingPageFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get onboardingPageFocus;

  /// No description provided for @onboardingPageGymProfile.
  ///
  /// In en, this message translates to:
  /// **'Gym Profile'**
  String get onboardingPageGymProfile;

  /// No description provided for @onboardingPageEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get onboardingPageEquipment;

  /// No description provided for @onboardingPageWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get onboardingPageWorkoutPlan;

  /// No description provided for @onboardingPagePlanOverview.
  ///
  /// In en, this message translates to:
  /// **'Plan Overview'**
  String get onboardingPagePlanOverview;

  /// No description provided for @onboardingPageSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get onboardingPageSummary;

  /// No description provided for @onboardingPreviousStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get onboardingPreviousStepTooltip;

  /// No description provided for @onboardingStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepProgress(int current, int total);

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing...'**
  String get onboardingFinishing;

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get onboardingFinishSetup;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingSkipSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip setup?'**
  String get onboardingSkipSetupTitle;

  /// No description provided for @onboardingSkipSetupBody.
  ///
  /// In en, this message translates to:
  /// **'You can skip to the app homepage now and finish setup later. You can also reopen onboarding from the settings page.'**
  String get onboardingSkipSetupBody;

  /// No description provided for @onboardingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get onboardingCancel;

  /// No description provided for @onboardingConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get onboardingConfirm;

  /// No description provided for @onboardingFinishError.
  ///
  /// In en, this message translates to:
  /// **'Could not finish setup: {error}'**
  String onboardingFinishError(String error);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tonos'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick setup helps personalize workouts, nutrition, and progress tracking.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingLanguageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageSelectionTitle;

  /// No description provided for @onboardingLanguageSelectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Setup updates immediately. You can change this later in Settings.'**
  String get onboardingLanguageSelectionHelp;

  /// No description provided for @onboardingTrainFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Train with context'**
  String get onboardingTrainFeatureTitle;

  /// No description provided for @onboardingTrainFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Use your preferences and history to shape workout suggestions.'**
  String get onboardingTrainFeatureBody;

  /// No description provided for @onboardingNutritionFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Support nutrition goals'**
  String get onboardingNutritionFeatureTitle;

  /// No description provided for @onboardingNutritionFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Set the level of nutrition guidance you want from the app.'**
  String get onboardingNutritionFeatureBody;

  /// No description provided for @onboardingProgressFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get onboardingProgressFeatureTitle;

  /// No description provided for @onboardingProgressFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your training and nutrition data connected over time.'**
  String get onboardingProgressFeatureBody;

  /// No description provided for @onboardingBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us the basics'**
  String get onboardingBasicsTitle;

  /// No description provided for @onboardingBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These details are optional, but they help future calculations.'**
  String get onboardingBasicsSubtitle;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingGenderLabel;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingGenderOther;

  /// No description provided for @onboardingGenderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get onboardingGenderPreferNotToSay;

  /// No description provided for @onboardingDateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get onboardingDateOfBirthLabel;

  /// No description provided for @onboardingSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get onboardingSelectDate;

  /// No description provided for @onboardingHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get onboardingHeightLabel;

  /// No description provided for @onboardingHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5\'10\" or 178 cm'**
  String get onboardingHeightHint;

  /// No description provided for @onboardingWorkoutWeightUnits.
  ///
  /// In en, this message translates to:
  /// **'Workout weight units'**
  String get onboardingWorkoutWeightUnits;

  /// No description provided for @onboardingCurrentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get onboardingCurrentWeightLabel;

  /// No description provided for @onboardingWeightHintPounds.
  ///
  /// In en, this message translates to:
  /// **'e.g. 160'**
  String get onboardingWeightHintPounds;

  /// No description provided for @onboardingWeightHintKilograms.
  ///
  /// In en, this message translates to:
  /// **'e.g. 72'**
  String get onboardingWeightHintKilograms;

  /// No description provided for @onboardingPounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get onboardingPounds;

  /// No description provided for @onboardingKilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get onboardingKilograms;

  /// No description provided for @onboardingFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'What should Tonos personalize?'**
  String get onboardingFocusTitle;

  /// No description provided for @onboardingFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the areas you want to set up now. You can change this later.'**
  String get onboardingFocusSubtitle;

  /// No description provided for @onboardingNutritionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition data'**
  String get onboardingNutritionDataTitle;

  /// No description provided for @onboardingNutritionDataPausedBody.
  ///
  /// In en, this message translates to:
  /// **'Nutrition setup is paused while this area is rebuilt.'**
  String get onboardingNutritionDataPausedBody;

  /// No description provided for @onboardingLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingLater;

  /// No description provided for @onboardingExerciseDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise data'**
  String get onboardingExerciseDataTitle;

  /// No description provided for @onboardingExerciseDataBody.
  ///
  /// In en, this message translates to:
  /// **'Set up your gym profile and first workout plans.'**
  String get onboardingExerciseDataBody;

  /// No description provided for @onboardingGymSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you work out?'**
  String get onboardingGymSpaceTitle;

  /// No description provided for @onboardingGymSpaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a starting space. Its equipment will shape exercise suggestions and generated workouts.'**
  String get onboardingGymSpaceSubtitle;

  /// No description provided for @onboardingEquipmentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Equipment could not be loaded.'**
  String get onboardingEquipmentLoadError;

  /// No description provided for @onboardingTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get onboardingTryAgain;

  /// No description provided for @onboardingGymCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Customized Space'**
  String get onboardingGymCustomTitle;

  /// No description provided for @onboardingGymCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Design your own profile by choosing every available item.'**
  String get onboardingGymCustomSubtitle;

  /// No description provided for @onboardingGymCustomDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Custom Space'**
  String get onboardingGymCustomDefaultName;

  /// No description provided for @onboardingGymSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get onboardingGymSkipTitle;

  /// No description provided for @onboardingGymSkipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the General profile and choose your equipment later.'**
  String get onboardingGymSkipSubtitle;

  /// No description provided for @onboardingGymGeneralName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get onboardingGymGeneralName;

  /// No description provided for @onboardingGymCommercialTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Gym'**
  String get onboardingGymCommercialTitle;

  /// No description provided for @onboardingGymCommercialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with every available equipment option, then remove anything your gym does not have.'**
  String get onboardingGymCommercialSubtitle;

  /// No description provided for @onboardingGymCommercialDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Commercial Gym'**
  String get onboardingGymCommercialDefaultName;

  /// No description provided for @onboardingGymHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Gym'**
  String get onboardingGymHomeTitle;

  /// No description provided for @onboardingGymHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A practical home setup with free weights, bands, a bench, and bodyweight equipment.'**
  String get onboardingGymHomeSubtitle;

  /// No description provided for @onboardingGymHomeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Home Gym'**
  String get onboardingGymHomeDefaultName;

  /// No description provided for @onboardingGymCalisthenicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calisthenics'**
  String get onboardingGymCalisthenicsTitle;

  /// No description provided for @onboardingGymCalisthenicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight-focused equipment including bars, rings, bands, and basic accessories.'**
  String get onboardingGymCalisthenicsSubtitle;

  /// No description provided for @onboardingGymCalisthenicsDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Calisthenics'**
  String get onboardingGymCalisthenicsDefaultName;

  /// No description provided for @onboardingGymPowerliftingTitle.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get onboardingGymPowerliftingTitle;

  /// No description provided for @onboardingGymPowerliftingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A barbell-based space with plates, a power rack, and a bench.'**
  String get onboardingGymPowerliftingSubtitle;

  /// No description provided for @onboardingGymPowerliftingDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get onboardingGymPowerliftingDefaultName;

  /// No description provided for @onboardingGymFreeWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Weights'**
  String get onboardingGymFreeWeightsTitle;

  /// No description provided for @onboardingGymFreeWeightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells, kettlebells, plates, a bench, and bodyweight movements.'**
  String get onboardingGymFreeWeightsSubtitle;

  /// No description provided for @onboardingGymFreeWeightsDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Free Weights'**
  String get onboardingGymFreeWeightsDefaultName;

  /// No description provided for @onboardingReviewWorkoutSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your workout space'**
  String get onboardingReviewWorkoutSpaceTitle;

  /// No description provided for @onboardingReviewWorkoutSpaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename the profile or adjust its equipment before Tonos creates it.'**
  String get onboardingReviewWorkoutSpaceSubtitle;

  /// No description provided for @onboardingProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get onboardingProfileNameLabel;

  /// No description provided for @onboardingIncludedEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Included equipment'**
  String get onboardingIncludedEquipmentTitle;

  /// No description provided for @onboardingIncludedEquipmentBody.
  ///
  /// In en, this message translates to:
  /// **'Only exercises supported by this equipment will be suggested when the profile is active.'**
  String get onboardingIncludedEquipmentBody;

  /// No description provided for @onboardingNoEquipmentSelected.
  ///
  /// In en, this message translates to:
  /// **'No equipment selected yet.'**
  String get onboardingNoEquipmentSelected;

  /// No description provided for @onboardingReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get onboardingReset;

  /// No description provided for @onboardingEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get onboardingEditProfile;

  /// No description provided for @onboardingEditWorkoutSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Workout Space'**
  String get onboardingEditWorkoutSpaceTitle;

  /// No description provided for @onboardingSelectEquipmentError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one equipment option.'**
  String get onboardingSelectEquipmentError;

  /// No description provided for @onboardingWorkoutPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your workout plan'**
  String get onboardingWorkoutPlanTitle;

  /// No description provided for @onboardingWorkoutPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how Tonos should prepare your first plans. You can always add, archive, or edit plans later.'**
  String get onboardingWorkoutPlanSubtitle;

  /// No description provided for @onboardingManualPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Manually create your own plans'**
  String get onboardingManualPlanTitle;

  /// No description provided for @onboardingManualPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a blank plan, then add exercises and sets yourself.'**
  String get onboardingManualPlanSubtitle;

  /// No description provided for @onboardingPremadePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Use premade exercise plans'**
  String get onboardingPremadePlanTitle;

  /// No description provided for @onboardingPremadePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse built-in full body, upper/lower, push-pull-legs, and body-part split plans.'**
  String get onboardingPremadePlanSubtitle;

  /// No description provided for @onboardingGeneratePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate exercise plans'**
  String get onboardingGeneratePlanTitle;

  /// No description provided for @onboardingGeneratePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a few setup questions and let Tonos generate a custom plan for your profile.'**
  String get onboardingGeneratePlanSubtitle;

  /// No description provided for @onboardingSkipPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get onboardingSkipPlanTitle;

  /// No description provided for @onboardingSkipPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start without adding plans. You can set them up from Train later.'**
  String get onboardingSkipPlanSubtitle;

  /// No description provided for @onboardingPlansAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} plan has been added to Active Plans.} other{{count} plans have been added to Active Plans.}}'**
  String onboardingPlansAdded(int count);

  /// No description provided for @onboardingReviewPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your plans'**
  String get onboardingReviewPlansTitle;

  /// No description provided for @onboardingReviewPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These plans were added to your active plans. Open any plan to inspect or adjust it before continuing.'**
  String get onboardingReviewPlansSubtitle;

  /// No description provided for @onboardingPlansReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} plan is ready in Active Plans.} other{{count} plans are ready in Active Plans.}}'**
  String onboardingPlansReady(int count);

  /// No description provided for @onboardingPlanOverviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load plan overview yet.'**
  String get onboardingPlanOverviewLoadError;

  /// No description provided for @onboardingNoAddedPlans.
  ///
  /// In en, this message translates to:
  /// **'No added plans were found. Go back to add plans, or skip this step.'**
  String get onboardingNoAddedPlans;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your setup, then finish to enter Tonos.'**
  String get onboardingReadySubtitle;

  /// No description provided for @onboardingSummaryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingSummaryName;

  /// No description provided for @onboardingSummaryGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingSummaryGender;

  /// No description provided for @onboardingSummaryDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get onboardingSummaryDateOfBirth;

  /// No description provided for @onboardingSummaryHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get onboardingSummaryHeight;

  /// No description provided for @onboardingSummaryWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get onboardingSummaryWeight;

  /// No description provided for @onboardingSummaryWorkoutUnits.
  ///
  /// In en, this message translates to:
  /// **'Workout units'**
  String get onboardingSummaryWorkoutUnits;

  /// No description provided for @onboardingSummaryIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get onboardingSummaryIncluded;

  /// No description provided for @onboardingSummaryGymProfile.
  ///
  /// In en, this message translates to:
  /// **'Gym profile'**
  String get onboardingSummaryGymProfile;

  /// No description provided for @onboardingSummaryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get onboardingSummaryEquipment;

  /// No description provided for @onboardingSummaryWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout plans'**
  String get onboardingSummaryWorkoutPlans;

  /// No description provided for @onboardingSummaryProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get onboardingSummaryProfileSection;

  /// No description provided for @onboardingSummaryTrainingSection.
  ///
  /// In en, this message translates to:
  /// **'Training setup'**
  String get onboardingSummaryTrainingSection;

  /// No description provided for @onboardingSummaryNutritionSection.
  ///
  /// In en, this message translates to:
  /// **'Nutrition preferences'**
  String get onboardingSummaryNutritionSection;

  /// No description provided for @onboardingSummaryDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get onboardingSummaryDiet;

  /// No description provided for @onboardingSummaryProteinPreference.
  ///
  /// In en, this message translates to:
  /// **'Protein preference'**
  String get onboardingSummaryProteinPreference;

  /// No description provided for @onboardingIncludedNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition setup'**
  String get onboardingIncludedNutrition;

  /// No description provided for @onboardingIncludedExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise setup'**
  String get onboardingIncludedExercise;

  /// No description provided for @onboardingIncludedBasicOnly.
  ///
  /// In en, this message translates to:
  /// **'Basic profile only'**
  String get onboardingIncludedBasicOnly;

  /// No description provided for @onboardingEquipmentSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} selected} other{{count} selected}}'**
  String onboardingEquipmentSelected(int count);

  /// No description provided for @onboardingPlanSummaryAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} plan added} other{{count} plans added}}'**
  String onboardingPlanSummaryAdded(int count);

  /// No description provided for @onboardingPlanSummaryPremade.
  ///
  /// In en, this message translates to:
  /// **'Premade selected'**
  String get onboardingPlanSummaryPremade;

  /// No description provided for @onboardingPlanSummaryGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generate selected'**
  String get onboardingPlanSummaryGenerated;

  /// No description provided for @onboardingPlanSummarySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get onboardingPlanSummarySkipped;

  /// No description provided for @onboardingPlanSummaryManual.
  ///
  /// In en, this message translates to:
  /// **'Manual selected'**
  String get onboardingPlanSummaryManual;

  /// No description provided for @onboardingPlanSummaryNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get onboardingPlanSummaryNotSelected;

  /// No description provided for @onboardingNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get onboardingNewPlan;

  /// No description provided for @onboardingNumberedNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New Plan {number}'**
  String onboardingNumberedNewPlan(int number);

  /// No description provided for @tabTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get tabTrain;

  /// No description provided for @tabTrainSecondary.
  ///
  /// In en, this message translates to:
  /// **'Train2'**
  String get tabTrainSecondary;

  /// No description provided for @tabCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get tabCatalog;

  /// No description provided for @tabLogbook.
  ///
  /// In en, this message translates to:
  /// **'Logbook'**
  String get tabLogbook;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get tabNutrition;

  /// No description provided for @tabNutritionLog.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Log'**
  String get tabNutritionLog;

  /// No description provided for @tabCombinedHistory.
  ///
  /// In en, this message translates to:
  /// **'Combined History'**
  String get tabCombinedHistory;

  /// No description provided for @tabFormAndPosing.
  ///
  /// In en, this message translates to:
  /// **'Form and Posing'**
  String get tabFormAndPosing;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize Tonos, manage training defaults, and keep your data healthy.'**
  String get profileSubtitle;

  /// No description provided for @profileAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSectionTitle;

  /// No description provided for @profileAccountSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity and app-level appearance.'**
  String get profileAccountSectionSubtitle;

  /// No description provided for @profileUserInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get profileUserInformationTitle;

  /// No description provided for @profileUserInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, body details, and activity profile.'**
  String get profileUserInformationSubtitle;

  /// No description provided for @profileUiAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'UI & Appearance'**
  String get profileUiAppearanceTitle;

  /// No description provided for @profileUiAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, onboarding, and bottom tab setup.'**
  String get profileUiAppearanceSubtitle;

  /// No description provided for @profileGuidedTutorialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided Tutorials'**
  String get profileGuidedTutorialsTitle;

  /// No description provided for @profileGuidedTutorialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay walkthroughs and reset guided help.'**
  String get profileGuidedTutorialsSubtitle;

  /// No description provided for @profileTrainingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get profileTrainingSectionTitle;

  /// No description provided for @profileTrainingSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise defaults and progress-related controls.'**
  String get profileTrainingSectionSubtitle;

  /// No description provided for @profileGymWorkoutSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym & Workout Settings'**
  String get profileGymWorkoutSettingsTitle;

  /// No description provided for @profileGymWorkoutSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workout generation, rankings, flows, and equipment logic.'**
  String get profileGymWorkoutSettingsSubtitle;

  /// No description provided for @profileProgressSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Settings'**
  String get profileProgressSettingsTitle;

  /// No description provided for @profileProgressSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement and trend tracking setup.'**
  String get profileProgressSettingsSubtitle;

  /// No description provided for @profileDataSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get profileDataSectionTitle;

  /// No description provided for @profileDataSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Database tools, exports, imports, and maintenance.'**
  String get profileDataSectionSubtitle;

  /// No description provided for @profileDatabaseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Database Settings'**
  String get profileDatabaseSettingsTitle;

  /// No description provided for @profileDatabaseSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import, export, health checks, and maintenance tools.'**
  String get profileDatabaseSettingsSubtitle;

  /// No description provided for @profileNutritionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get profileNutritionSectionTitle;

  /// No description provided for @profileNutritionSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition settings are paused while this area is rebuilt.'**
  String get profileNutritionSectionSubtitle;

  /// No description provided for @profileDietNutritionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet & Nutrition Settings'**
  String get profileDietNutritionSettingsTitle;

  /// No description provided for @profileDietNutritionSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition goals and preferences will return later.'**
  String get profileDietNutritionSettingsSubtitle;

  /// No description provided for @profileLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get profileLater;

  /// No description provided for @profileAccountTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get profileAccountTutorialTitle;

  /// No description provided for @profileAccountTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Update your personal info, display preferences, weight units, onboarding, bottom tabs, and guided tutorials from here.'**
  String get profileAccountTutorialBody;

  /// No description provided for @profileTrainingTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Training settings'**
  String get profileTrainingTutorialTitle;

  /// No description provided for @profileTrainingTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Control gym profiles, generation rules, bodypart rankings, progress settings, and other training defaults.'**
  String get profileTrainingTutorialBody;

  /// No description provided for @profileDataTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Data tools'**
  String get profileDataTutorialTitle;

  /// No description provided for @profileDataTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Database settings are where you export, import, check, and maintain your local workout data.'**
  String get profileDataTutorialBody;

  /// No description provided for @catalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load catalog: {error}'**
  String catalogLoadError(String error);

  /// No description provided for @catalogNoData.
  ///
  /// In en, this message translates to:
  /// **'No catalog data available yet.'**
  String get catalogNoData;

  /// No description provided for @catalogExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Catalog'**
  String get catalogExerciseTitle;

  /// No description provided for @catalogMostUsedExercises.
  ///
  /// In en, this message translates to:
  /// **'Most used exercises'**
  String get catalogMostUsedExercises;

  /// No description provided for @catalogNoExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see your most common exercises here.'**
  String get catalogNoExerciseHistory;

  /// No description provided for @catalogTargetAnatomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Target Anatomy'**
  String get catalogTargetAnatomyTitle;

  /// No description provided for @catalogBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts'**
  String get catalogBodyparts;

  /// No description provided for @catalogMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get catalogMuscles;

  /// No description provided for @catalogNoBodypartHistory.
  ///
  /// In en, this message translates to:
  /// **'No bodypart history yet.'**
  String get catalogNoBodypartHistory;

  /// No description provided for @catalogNoMuscleHistory.
  ///
  /// In en, this message translates to:
  /// **'No muscle history yet.'**
  String get catalogNoMuscleHistory;

  /// No description provided for @catalogExerciseTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise catalog'**
  String get catalogExerciseTutorialTitle;

  /// No description provided for @catalogExerciseTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Your most used exercises show here first. Tap the card to open the full catalog, search movements, and review exercise details.'**
  String get catalogExerciseTutorialBody;

  /// No description provided for @catalogAnatomyTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Target Anatomy'**
  String get catalogAnatomyTutorialTitle;

  /// No description provided for @catalogAnatomyTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'This summarizes your most trained bodyparts and muscles. Tap either side to open the anatomy library for focused exercise lists.'**
  String get catalogAnatomyTutorialBody;

  /// No description provided for @catalogTimesUsed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String catalogTimesUsed(int count);

  /// No description provided for @catalogSetUnits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String catalogSetUnits(int count);

  /// No description provided for @navEditorMinimumTabsError.
  ///
  /// In en, this message translates to:
  /// **'Please keep at least two active tabs.'**
  String get navEditorMinimumTabsError;

  /// No description provided for @navEditorSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Bottom tabs saved'**
  String get navEditorSavedMessage;

  /// No description provided for @navEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bottom Tabs'**
  String get navEditorTitle;

  /// No description provided for @navEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what appears in the bottom bar and reorder active tabs.'**
  String get navEditorSubtitle;

  /// No description provided for @navEditorSave.
  ///
  /// In en, this message translates to:
  /// **'Save Tabs'**
  String get navEditorSave;

  /// No description provided for @navEditorActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Tabs'**
  String get navEditorActiveTitle;

  /// No description provided for @navEditorActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Profile stays available.'**
  String get navEditorActiveSubtitle;

  /// No description provided for @navEditorInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Inactive Tabs'**
  String get navEditorInactiveTitle;

  /// No description provided for @navEditorInactiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn these on whenever you want them back.'**
  String get navEditorInactiveSubtitle;

  /// No description provided for @navEditorNoInactiveTabs.
  ///
  /// In en, this message translates to:
  /// **'No inactive tabs.'**
  String get navEditorNoInactiveTabs;

  /// No description provided for @navEditorAlwaysShown.
  ///
  /// In en, this message translates to:
  /// **'Always shown'**
  String get navEditorAlwaysShown;

  /// No description provided for @navEditorVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible in bottom navigation'**
  String get navEditorVisible;

  /// No description provided for @navEditorHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden from bottom navigation'**
  String get navEditorHidden;

  /// No description provided for @trainTutorialSpacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Train has two spaces'**
  String get trainTutorialSpacesTitle;

  /// No description provided for @trainTutorialSpacesBody.
  ///
  /// In en, this message translates to:
  /// **'Overview keeps your ready-to-use workout controls up front. Plans is where you browse, generate, and manage your saved plans.'**
  String get trainTutorialSpacesBody;

  /// No description provided for @trainTutorialWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly overview'**
  String get trainTutorialWeeklyTitle;

  /// No description provided for @trainTutorialWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'This shows what bodyparts you have trained recently. Tap the focused sets list to open the full weekly sets breakdown.'**
  String get trainTutorialWeeklyBody;

  /// No description provided for @trainTutorialActivePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plans'**
  String get trainTutorialActivePlansTitle;

  /// No description provided for @trainTutorialActivePlansBody.
  ///
  /// In en, this message translates to:
  /// **'Active plans are the routines you want close at hand. Use the pen to choose which plans stay ready on the Overview tab.'**
  String get trainTutorialActivePlansBody;

  /// No description provided for @trainTutorialStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start or optimize'**
  String get trainTutorialStartTitle;

  /// No description provided for @trainTutorialStartBody.
  ///
  /// In en, this message translates to:
  /// **'Start Workout begins a blank session. Optimize builds a session from your history, profile equipment, focus, and recovery rules.'**
  String get trainTutorialStartBody;

  /// No description provided for @trainTutorialProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym profiles'**
  String get trainTutorialProfilesTitle;

  /// No description provided for @trainTutorialProfilesBody.
  ///
  /// In en, this message translates to:
  /// **'Switch profiles when you train somewhere different so generated workouts and exercise swaps only use available equipment.'**
  String get trainTutorialProfilesBody;

  /// No description provided for @trainSelectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a gym profile first.'**
  String get trainSelectProfileFirst;

  /// No description provided for @trainGeneratedPlans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Generated 1 plan.} other{Generated {count} plans.}}'**
  String trainGeneratedPlans(int count);

  /// No description provided for @trainNewPlanName.
  ///
  /// In en, this message translates to:
  /// **'{number, plural, =1{New Plan} other{New Plan {number}}}'**
  String trainNewPlanName(int number);

  /// No description provided for @trainOptimizedWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Optimized workout {date} {time}'**
  String trainOptimizedWorkoutName(String date, String time);

  /// No description provided for @trainRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Take some time to rest'**
  String get trainRestTitle;

  /// No description provided for @trainRestBody.
  ///
  /// In en, this message translates to:
  /// **'Your recent training is already at several bodypart limits, so an optimized workout would push recovery too far.'**
  String get trainRestBody;

  /// No description provided for @commonOkay.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOkay;

  /// No description provided for @trainNoEligibleExercises.
  ///
  /// In en, this message translates to:
  /// **'No eligible exercises were found for this profile.'**
  String get trainNoEligibleExercises;

  /// No description provided for @trainAnotherWorkoutActive.
  ///
  /// In en, this message translates to:
  /// **'Another workout is already active, so it was kept unchanged.'**
  String get trainAnotherWorkoutActive;

  /// No description provided for @trainOptimizedStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start optimized workout: {error}'**
  String trainOptimizedStartFailed(String error);

  /// No description provided for @trainOptimizedManualWeights.
  ///
  /// In en, this message translates to:
  /// **'Optimized workout started. {count} exercise(s) still need manual weights.'**
  String trainOptimizedManualWeights(int count);

  /// No description provided for @trainOptimizedStarterWeights.
  ///
  /// In en, this message translates to:
  /// **'Optimized workout started with starter weights for {count} new exercise(s).'**
  String trainOptimizedStarterWeights(int count);

  /// No description provided for @trainGymProfilesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Gym profiles'**
  String get trainGymProfilesTooltip;

  /// No description provided for @trainOverviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get trainOverviewTab;

  /// No description provided for @trainPlansTab.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get trainPlansTab;

  /// No description provided for @trainActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Active Plans'**
  String get trainActivePlans;

  /// No description provided for @trainEditActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Edit active plans'**
  String get trainEditActivePlans;

  /// No description provided for @trainSelectProfileForPlans.
  ///
  /// In en, this message translates to:
  /// **'Select a gym profile to choose active plans.'**
  String get trainSelectProfileForPlans;

  /// No description provided for @trainChooseActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Tap the pen to choose which plans show here.'**
  String get trainChooseActivePlans;

  /// No description provided for @trainSelectedPlansMissing.
  ///
  /// In en, this message translates to:
  /// **'Selected plans are no longer available. Tap the pen to update them.'**
  String get trainSelectedPlansMissing;

  /// No description provided for @trainArchivedPlans.
  ///
  /// In en, this message translates to:
  /// **'Archived Plans'**
  String get trainArchivedPlans;

  /// No description provided for @trainNoActivePlans.
  ///
  /// In en, this message translates to:
  /// **'No active plans yet. Use the pen on the Overview Active Plans card to choose what stays ready.'**
  String get trainNoActivePlans;

  /// No description provided for @trainNoArchivedPlans.
  ///
  /// In en, this message translates to:
  /// **'No archived plans.'**
  String get trainNoArchivedPlans;

  /// No description provided for @trainManagePlans.
  ///
  /// In en, this message translates to:
  /// **'Manage plans'**
  String get trainManagePlans;

  /// No description provided for @trainPremadePlans.
  ///
  /// In en, this message translates to:
  /// **'Premade Plans'**
  String get trainPremadePlans;

  /// No description provided for @trainPremadeDescription.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 curated routine is available to copy into your plans.} other{{count} curated routines are available to copy into your plans.}}'**
  String trainPremadeDescription(int count);

  /// No description provided for @trainBrowsePremadePlans.
  ///
  /// In en, this message translates to:
  /// **'Browse Premade Plans'**
  String get trainBrowsePremadePlans;

  /// No description provided for @trainGenerateCustomPlans.
  ///
  /// In en, this message translates to:
  /// **'Generate Custom Plans'**
  String get trainGenerateCustomPlans;

  /// No description provided for @trainManuallyAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Manually Add Plan'**
  String get trainManuallyAddPlan;

  /// No description provided for @trainStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get trainStartWorkout;

  /// No description provided for @trainOptimize.
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get trainOptimize;

  /// No description provided for @trainOptimizedSettings.
  ///
  /// In en, this message translates to:
  /// **'Optimized workout settings'**
  String get trainOptimizedSettings;

  /// No description provided for @planManagementDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Plan {id}'**
  String planManagementDefaultName(int id);

  /// No description provided for @planManagementActiveTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plans'**
  String get planManagementActiveTutorialTitle;

  /// No description provided for @planManagementActiveTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'These plans stay visible on the Train overview. Use Archive when you want to hide one without deleting it.'**
  String get planManagementActiveTutorialBody;

  /// No description provided for @planManagementArchivedTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived plans'**
  String get planManagementArchivedTutorialTitle;

  /// No description provided for @planManagementArchivedTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Archived plans are still saved. Activate any plan here when you want it back on the overview.'**
  String get planManagementArchivedTutorialBody;

  /// No description provided for @planManagementUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update {plan}: {error}'**
  String planManagementUpdateFailed(String plan, String error);

  /// No description provided for @planManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Plans'**
  String get planManagementTitle;

  /// No description provided for @planManagementLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plans'**
  String get planManagementLoadFailed;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @planManagementIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose what stays ready on your Train overview. Archived plans are still saved and can be activated anytime.'**
  String get planManagementIntro;

  /// No description provided for @planManagementActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shown on the Train overview.'**
  String get planManagementActiveSubtitle;

  /// No description provided for @planManagementNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active plans yet. Activate a plan below to pin it to the overview.'**
  String get planManagementNoActive;

  /// No description provided for @planManagementArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get planManagementArchive;

  /// No description provided for @planManagementArchivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved plans that stay out of the overview.'**
  String get planManagementArchivedSubtitle;

  /// No description provided for @planManagementNoArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived plans.'**
  String get planManagementNoArchived;

  /// No description provided for @planManagementActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get planManagementActivate;

  /// No description provided for @planManagementAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic plan'**
  String get planManagementAutomatic;

  /// No description provided for @planManagementVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible on overview'**
  String get planManagementVisible;

  /// No description provided for @planManagementHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden from overview'**
  String get planManagementHidden;

  /// No description provided for @presetsNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans found.'**
  String get presetsNoPlans;

  /// No description provided for @presetsNoProfile.
  ///
  /// In en, this message translates to:
  /// **'No profile selected.'**
  String get presetsNoProfile;

  /// No description provided for @presetsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading plans'**
  String get presetsLoadError;

  /// No description provided for @presetsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show {count} more'**
  String presetsShowMore(int count);

  /// No description provided for @presetsShowMoreRemaining.
  ///
  /// In en, this message translates to:
  /// **'Show {count} more ({remaining} left)'**
  String presetsShowMoreRemaining(int count, int remaining);

  /// No description provided for @planDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Plan {number}'**
  String planDefaultName(int number);

  /// No description provided for @planArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get planArchive;

  /// No description provided for @planActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get planActivate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get commonRename;

  /// No description provided for @planActivated.
  ///
  /// In en, this message translates to:
  /// **'Plan activated.'**
  String get planActivated;

  /// No description provided for @planArchived.
  ///
  /// In en, this message translates to:
  /// **'Plan archived.'**
  String get planArchived;

  /// No description provided for @planDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get planDeleteTitle;

  /// No description provided for @planDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan?'**
  String get planDeleteConfirmation;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @planRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Plan'**
  String get planRenameTitle;

  /// No description provided for @planNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planNameLabel;

  /// No description provided for @optimizedTutorialBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Session budget'**
  String get optimizedTutorialBudgetTitle;

  /// No description provided for @optimizedTutorialBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set how long the optimized workout should be and how many sets each exercise can receive.'**
  String get optimizedTutorialBudgetBody;

  /// No description provided for @optimizedTutorialRepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reps and weight'**
  String get optimizedTutorialRepsTitle;

  /// No description provided for @optimizedTutorialRepsBody.
  ///
  /// In en, this message translates to:
  /// **'These choices control the set pattern, target reps, and how conservative generated weights should be.'**
  String get optimizedTutorialRepsBody;

  /// No description provided for @optimizedTutorialFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodypart focus'**
  String get optimizedTutorialFocusTitle;

  /// No description provided for @optimizedTutorialFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Prefer or avoid bodyparts for the next optimized workout without changing your saved rankings.'**
  String get optimizedTutorialFocusBody;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @optimizedTutorialResetBody.
  ///
  /// In en, this message translates to:
  /// **'Reset brings this page back to Tonos defaults if the current setup feels off.'**
  String get optimizedTutorialResetBody;

  /// No description provided for @optimizedTutorialActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Save or start'**
  String get optimizedTutorialActionsTitle;

  /// No description provided for @optimizedTutorialActionsBody.
  ///
  /// In en, this message translates to:
  /// **'Start Now uses the current on-screen values once. Save keeps the settings for future optimized workouts.'**
  String get optimizedTutorialActionsBody;

  /// No description provided for @optimizedValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid duration, rep target, and set range between 1-{maxSets}.'**
  String optimizedValidationError(int maxSets);

  /// No description provided for @optimizedBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Used to budget 3 minutes per set plus 5 minutes to start each exercise.'**
  String get optimizedBudgetDescription;

  /// No description provided for @optimizedWorkoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Workout duration'**
  String get optimizedWorkoutDuration;

  /// No description provided for @unitMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutesShort;

  /// No description provided for @optimizedMinimumSets.
  ///
  /// In en, this message translates to:
  /// **'Minimum sets per exercise'**
  String get optimizedMinimumSets;

  /// No description provided for @optimizedMaximumSets.
  ///
  /// In en, this message translates to:
  /// **'Up to sets per exercise'**
  String get optimizedMaximumSets;

  /// No description provided for @unitSets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get unitSets;

  /// No description provided for @optimizedRepsWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reps & weights'**
  String get optimizedRepsWeightsTitle;

  /// No description provided for @optimizedRepsWeightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses history-based strength estimates when available, with Easy and Medium backing off more than Hard. New exercises use conservative starter estimates.'**
  String get optimizedRepsWeightsDescription;

  /// No description provided for @optimizedRepPattern.
  ///
  /// In en, this message translates to:
  /// **'Rep pattern'**
  String get optimizedRepPattern;

  /// No description provided for @repModeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get repModeMixed;

  /// No description provided for @repModePyramid.
  ///
  /// In en, this message translates to:
  /// **'Pyramid'**
  String get repModePyramid;

  /// No description provided for @repModeConsistent.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get repModeConsistent;

  /// No description provided for @optimizedTargetReps.
  ///
  /// In en, this message translates to:
  /// **'Target reps'**
  String get optimizedTargetReps;

  /// No description provided for @unitReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get unitReps;

  /// No description provided for @optimizedWeightIntensity.
  ///
  /// In en, this message translates to:
  /// **'Weight intensity'**
  String get optimizedWeightIntensity;

  /// No description provided for @intensityEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get intensityEasy;

  /// No description provided for @intensityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get intensityMedium;

  /// No description provided for @intensityHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get intensityHard;

  /// No description provided for @optimizedBodypartFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodypart focus'**
  String get optimizedBodypartFocusTitle;

  /// No description provided for @optimizedBodypartFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'These picks apply only to the next optimized workout you start. Tap once to prefer, tap twice to avoid, and tap again to clear.'**
  String get optimizedBodypartFocusDescription;

  /// No description provided for @optimizedBodypartsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts could not be loaded.'**
  String get optimizedBodypartsUnavailable;

  /// No description provided for @commonStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get commonStartNow;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @generateTutorialIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Build plans'**
  String get generateTutorialIntroTitle;

  /// No description provided for @generateTutorialIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This page can create one plan or a balanced weekly bundle using your gym profile and training preferences.'**
  String get generateTutorialIntroBody;

  /// No description provided for @generateWorkoutSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout setup'**
  String get generateWorkoutSetupTitle;

  /// No description provided for @generateTutorialSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Set session length, how many plans to create, and the maximum sets allowed for each exercise.'**
  String get generateTutorialSetupBody;

  /// No description provided for @generateTrainingFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Training focus'**
  String get generateTrainingFocusTitle;

  /// No description provided for @generateTutorialFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Prefer or avoid bodyparts here. The 7-day history toggle only biases generation when you want recent training considered.'**
  String get generateTutorialFocusBody;

  /// No description provided for @generateRepsWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reps & weights'**
  String get generateRepsWeightsTitle;

  /// No description provided for @generateTutorialRepsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose pyramid, mixed, or consistent set patterns plus the target reps and starter weight intensity.'**
  String get generateTutorialRepsBody;

  /// No description provided for @generateSetAllocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set allocation'**
  String get generateSetAllocationTitle;

  /// No description provided for @generateTutorialAllocationBody.
  ///
  /// In en, this message translates to:
  /// **'Pick whether sets are spread evenly or biased toward your bodypart or muscle rankings.'**
  String get generateTutorialAllocationBody;

  /// No description provided for @generateTutorialGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateTutorialGenerateTitle;

  /// No description provided for @generateTutorialGenerateBody.
  ///
  /// In en, this message translates to:
  /// **'When everything looks right, generate the plan or plan bundle. New plans can be reviewed and edited afterward.'**
  String get generateTutorialGenerateBody;

  /// No description provided for @generateValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid duration, plan count, set limit, and rep values.'**
  String get generateValidationError;

  /// No description provided for @generateNoViablePlans.
  ///
  /// In en, this message translates to:
  /// **'No viable plans could be generated with the current settings.'**
  String get generateNoViablePlans;

  /// No description provided for @generateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate plans: {error}'**
  String generateFailed(String error);

  /// No description provided for @generateDiscardFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not discard generated plans: {error}'**
  String generateDiscardFailed(String error);

  /// No description provided for @generateIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your plan week'**
  String get generateIntroTitle;

  /// No description provided for @generateIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Create one plan or a balanced bundle using your profile, focus, and limits.'**
  String get generateIntroBody;

  /// No description provided for @generatePlanCountPill.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plan} other{{count} plans}}'**
  String generatePlanCountPill(int count);

  /// No description provided for @generateDurationPill.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String generateDurationPill(String minutes);

  /// No description provided for @generateMaxSetsPill.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets max'**
  String generateMaxSetsPill(String sets);

  /// No description provided for @generateSetupSummary.
  ///
  /// In en, this message translates to:
  /// **'{plans} plan(s), {minutes} min, {sets} max sets'**
  String generateSetupSummary(String plans, String minutes, String sets);

  /// No description provided for @generateSessionLength.
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get generateSessionLength;

  /// No description provided for @generateSessionLengthHelp.
  ///
  /// In en, this message translates to:
  /// **'Estimated as 3 min/set + 5 min/exercise.'**
  String get generateSessionLengthHelp;

  /// No description provided for @generatePlansToCreate.
  ///
  /// In en, this message translates to:
  /// **'Plans to create'**
  String get generatePlansToCreate;

  /// No description provided for @generatePlansToCreateHelp.
  ///
  /// In en, this message translates to:
  /// **'Usually matches training days/week. Max {maxPlans}.'**
  String generatePlansToCreateHelp(int maxPlans);

  /// No description provided for @unitPlans.
  ///
  /// In en, this message translates to:
  /// **'plans'**
  String get unitPlans;

  /// No description provided for @generateMaxSetsPerExercise.
  ///
  /// In en, this message translates to:
  /// **'Max sets per exercise'**
  String get generateMaxSetsPerExercise;

  /// No description provided for @generateSetLimitHelp.
  ///
  /// In en, this message translates to:
  /// **'{minSets}-{maxSets} sets allowed.'**
  String generateSetLimitHelp(int minSets, int maxSets);

  /// No description provided for @generateFocusSummary.
  ///
  /// In en, this message translates to:
  /// **'{preferred} preferred, {avoided} avoided, {history} 7-day history'**
  String generateFocusSummary(int preferred, int avoided, String history);

  /// No description provided for @generateHistoryUsing.
  ///
  /// In en, this message translates to:
  /// **'using'**
  String get generateHistoryUsing;

  /// No description provided for @generateHistoryNotUsing.
  ///
  /// In en, this message translates to:
  /// **'not using'**
  String get generateHistoryNotUsing;

  /// No description provided for @generateUseRecentTraining.
  ///
  /// In en, this message translates to:
  /// **'Use recent training'**
  String get generateUseRecentTraining;

  /// No description provided for @generateUseRecentTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'Bias toward under-trained areas from the last 7 days.'**
  String get generateUseRecentTrainingBody;

  /// No description provided for @generateBodypartFocusInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap once to prefer, twice to avoid, third to clear.'**
  String get generateBodypartFocusInstruction;

  /// No description provided for @generateRepsSummary.
  ///
  /// In en, this message translates to:
  /// **'{mode}, {reps} reps, {intensity} intensity'**
  String generateRepsSummary(String mode, String reps, String intensity);

  /// No description provided for @generateMixedBody.
  ///
  /// In en, this message translates to:
  /// **'Pyramid for 3+ sets; steady for shorter work.'**
  String get generateMixedBody;

  /// No description provided for @generatePyramidBody.
  ///
  /// In en, this message translates to:
  /// **'Peak set uses the generated working weight.'**
  String get generatePyramidBody;

  /// No description provided for @generateConsistentBody.
  ///
  /// In en, this message translates to:
  /// **'Same reps and suggested weight each set.'**
  String get generateConsistentBody;

  /// No description provided for @generateTargetRepsHelp.
  ///
  /// In en, this message translates to:
  /// **'Peak reps for pyramid; steady reps otherwise.'**
  String get generateTargetRepsHelp;

  /// No description provided for @generateEasyBody.
  ///
  /// In en, this message translates to:
  /// **'Most conservative history or starter recommendation.'**
  String get generateEasyBody;

  /// No description provided for @generateMediumBody.
  ///
  /// In en, this message translates to:
  /// **'Balanced working-weight recommendation.'**
  String get generateMediumBody;

  /// No description provided for @generateHardBody.
  ///
  /// In en, this message translates to:
  /// **'Heaviest recommendation, still rounded and effort-aware.'**
  String get generateHardBody;

  /// No description provided for @generateRequirementBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Bodypart rankings'**
  String get generateRequirementBodyparts;

  /// No description provided for @generateRequirementMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscle rankings'**
  String get generateRequirementMuscles;

  /// No description provided for @generateRequirementEven.
  ///
  /// In en, this message translates to:
  /// **'Even coverage'**
  String get generateRequirementEven;

  /// No description provided for @generateEvenCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Even bodypart coverage'**
  String get generateEvenCoverageTitle;

  /// No description provided for @generateEvenCoverageBody.
  ///
  /// In en, this message translates to:
  /// **'Spread work broadly across available bodyparts.'**
  String get generateEvenCoverageBody;

  /// No description provided for @generateBodypartRankingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use bodypart rankings'**
  String get generateBodypartRankingsTitle;

  /// No description provided for @generateBodypartRankingsBody.
  ///
  /// In en, this message translates to:
  /// **'Give higher-ranked bodyparts more planned work.'**
  String get generateBodypartRankingsBody;

  /// No description provided for @generateRankBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Rank Body Parts'**
  String get generateRankBodyparts;

  /// No description provided for @generateMuscleRankingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use muscle rankings'**
  String get generateMuscleRankingsTitle;

  /// No description provided for @generateMuscleRankingsBody.
  ///
  /// In en, this message translates to:
  /// **'Allocate work from your ranked muscle priorities.'**
  String get generateMuscleRankingsBody;

  /// No description provided for @generateRankMuscles.
  ///
  /// In en, this message translates to:
  /// **'Rank Muscles'**
  String get generateRankMuscles;

  /// No description provided for @generateGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generateGenerating;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Generate plan} other{Generate {count} plans}}'**
  String generateButton(int count);

  /// No description provided for @generatePartialMessage.
  ///
  /// In en, this message translates to:
  /// **'Generated {generated} of {requested} plans. Your current settings limited the rest.'**
  String generatePartialMessage(int generated, int requested);

  /// No description provided for @generateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Generated plan added. Review it when ready.} other{Generated {count} plans. Review them when ready.}}'**
  String generateSuccessMessage(int count);

  /// No description provided for @generateMoreNames.
  ///
  /// In en, this message translates to:
  /// **'{count} more'**
  String generateMoreNames(int count);

  /// No description provided for @generateStarterEstimatedBody.
  ///
  /// In en, this message translates to:
  /// **'Starter weights were estimated for new exercises. Adjust as needed after your first set.'**
  String get generateStarterEstimatedBody;

  /// No description provided for @generateStarterUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Some exercises still need manual weights because no safe starter estimate is available yet.'**
  String get generateStarterUnavailableBody;

  /// No description provided for @generateStarterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter weights added'**
  String get generateStarterDialogTitle;

  /// No description provided for @generatePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Plans'**
  String get generatePageTitle;

  /// No description provided for @generateDiscarding.
  ///
  /// In en, this message translates to:
  /// **'Discarding...'**
  String get generateDiscarding;

  /// No description provided for @generateReviewPlans.
  ///
  /// In en, this message translates to:
  /// **'Review Plans'**
  String get generateReviewPlans;

  /// No description provided for @sessionTutorialCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise cards'**
  String get sessionTutorialCardsTitle;

  /// No description provided for @sessionTutorialCardsBody.
  ///
  /// In en, this message translates to:
  /// **'Each card holds one exercise. Open it to edit weights and reps, then tick sets off as you complete them.'**
  String get sessionTutorialCardsBody;

  /// No description provided for @sessionTutorialAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get sessionTutorialAddTitle;

  /// No description provided for @sessionTutorialAddBody.
  ///
  /// In en, this message translates to:
  /// **'Use this button when you want to add another exercise from the catalog during the workout.'**
  String get sessionTutorialAddBody;

  /// No description provided for @sessionTutorialFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get sessionTutorialFinishTitle;

  /// No description provided for @sessionTutorialFinishBody.
  ///
  /// In en, this message translates to:
  /// **'When you are done, finish the session so Tonos can save the workout and update your history, analytics, and progress widgets.'**
  String get sessionTutorialFinishBody;

  /// No description provided for @sessionTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Timer'**
  String get sessionTimerTitle;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Session'**
  String get sessionTitle;

  /// No description provided for @sessionNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises added.'**
  String get sessionNoExercises;

  /// No description provided for @sessionNeedCompletedSet.
  ///
  /// In en, this message translates to:
  /// **'Complete at least one set before finishing the workout.'**
  String get sessionNeedCompletedSet;

  /// No description provided for @sessionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save workout. Your ongoing workout is still available. {error}'**
  String sessionSaveFailed(String error);

  /// No description provided for @sessionFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get sessionFinishWorkout;

  /// No description provided for @sessionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get sessionResume;

  /// No description provided for @sessionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get sessionExit;

  /// No description provided for @sessionCompletedSaved.
  ///
  /// In en, this message translates to:
  /// **'Completed work saved to Logbook.'**
  String get sessionCompletedSaved;

  /// No description provided for @sessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Workout cancelled.'**
  String get sessionCancelled;

  /// No description provided for @sessionEndFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not end workout: {error}'**
  String sessionEndFailed(String error);

  /// No description provided for @sessionCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel workout?'**
  String get sessionCancelQuestion;

  /// No description provided for @sessionCancelBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the ongoing workout without adding it to your history.'**
  String get sessionCancelBody;

  /// No description provided for @sessionKeepWorkout.
  ///
  /// In en, this message translates to:
  /// **'Keep Workout'**
  String get sessionKeepWorkout;

  /// No description provided for @sessionCancelWorkout.
  ///
  /// In en, this message translates to:
  /// **'Cancel Workout'**
  String get sessionCancelWorkout;

  /// No description provided for @sessionEndQuestion.
  ///
  /// In en, this message translates to:
  /// **'End workout?'**
  String get sessionEndQuestion;

  /// No description provided for @sessionCancelDelete.
  ///
  /// In en, this message translates to:
  /// **'Cancel and Delete'**
  String get sessionCancelDelete;

  /// No description provided for @sessionEndSave.
  ///
  /// In en, this message translates to:
  /// **'End and Save Workout'**
  String get sessionEndSave;

  /// No description provided for @sessionRememberChoice.
  ///
  /// In en, this message translates to:
  /// **'Remember choice'**
  String get sessionRememberChoice;

  /// No description provided for @sessionRememberChoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Change this later in Gym & Workout Settings.'**
  String get sessionRememberChoiceBody;

  /// No description provided for @sessionCompleteLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading session'**
  String get sessionCompleteLoadError;

  /// No description provided for @sessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT COMPLETE'**
  String get sessionCompleteTitle;

  /// No description provided for @sessionMetricExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get sessionMetricExercises;

  /// No description provided for @sessionMetricSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sessionMetricSets;

  /// No description provided for @sessionMetricDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionMetricDuration;

  /// No description provided for @sessionMetricVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get sessionMetricVolume;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @recordMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recordMonthly;

  /// No description provided for @recordAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get recordAllTime;

  /// No description provided for @recordFirst.
  ///
  /// In en, this message translates to:
  /// **'First Record'**
  String get recordFirst;

  /// No description provided for @recordRepBest.
  ///
  /// In en, this message translates to:
  /// **'{reps} Rep Best'**
  String recordRepBest(int reps);

  /// No description provided for @recordVolumeBest.
  ///
  /// In en, this message translates to:
  /// **'Best Volume'**
  String get recordVolumeBest;

  /// No description provided for @sessionEstimatedMax.
  ///
  /// In en, this message translates to:
  /// **'ERM={weight}'**
  String sessionEstimatedMax(String weight);

  /// No description provided for @durationMinutesCompact.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesCompact(int minutes);

  /// No description provided for @durationHoursCompact.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursCompact(int hours);

  /// No description provided for @durationHoursMinutesCompact.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutesCompact(int hours, int minutes);

  /// No description provided for @planUnsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get planUnsavedChangesTitle;

  /// No description provided for @planDiscardChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get planDiscardChangesQuestion;

  /// No description provided for @planDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get planDiscard;

  /// No description provided for @planTutorialEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get planTutorialEditTitle;

  /// No description provided for @planTutorialEditBody.
  ///
  /// In en, this message translates to:
  /// **'Use this to rename the plan, reorder exercises, add exercises, swap movements, and change sets.'**
  String get planTutorialEditBody;

  /// No description provided for @planTutorialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan summary'**
  String get planTutorialSummaryTitle;

  /// No description provided for @planTutorialSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'This shows estimated time, volume, and the main bodyparts this plan targets before you start it.'**
  String get planTutorialSummaryBody;

  /// No description provided for @planTutorialExerciseCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise cards'**
  String get planTutorialExerciseCardsTitle;

  /// No description provided for @planTutorialExerciseCardsBody.
  ///
  /// In en, this message translates to:
  /// **'Open exercise cards to review the planned sets. In edit mode, use the menu to swap or remove exercises.'**
  String get planTutorialExerciseCardsBody;

  /// No description provided for @planTutorialStartOrSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Start or save'**
  String get planTutorialStartOrSaveTitle;

  /// No description provided for @planTutorialStartOrSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Start Session begins this plan as a workout. In edit mode, this changes to Save Preset so your changes are stored.'**
  String get planTutorialStartOrSaveBody;

  /// No description provided for @planGuideNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your plan'**
  String get planGuideNameTitle;

  /// No description provided for @planGuideNameBody.
  ///
  /// In en, this message translates to:
  /// **'Give this plan a name you will recognize, such as Upper Body or Day 1.'**
  String get planGuideNameBody;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @planGuideBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse exercises'**
  String get planGuideBrowseTitle;

  /// No description provided for @planGuideBrowseBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to choose the first exercise in this plan.'**
  String get planGuideBrowseBody;

  /// No description provided for @planGuideWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a weight'**
  String get planGuideWeightTitle;

  /// No description provided for @planGuideWeightBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a starting weight for the first set. Use 0 for a bodyweight exercise.'**
  String get planGuideWeightBody;

  /// No description provided for @planGuideWeightSet.
  ///
  /// In en, this message translates to:
  /// **'Weight set'**
  String get planGuideWeightSet;

  /// No description provided for @planGuideRepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your reps'**
  String get planGuideRepsTitle;

  /// No description provided for @planGuideRepsBody.
  ///
  /// In en, this message translates to:
  /// **'Enter how many repetitions you plan to perform for this set.'**
  String get planGuideRepsBody;

  /// No description provided for @planGuideRepsSet.
  ///
  /// In en, this message translates to:
  /// **'Reps set'**
  String get planGuideRepsSet;

  /// No description provided for @planGuideAddSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add more sets'**
  String get planGuideAddSetTitle;

  /// No description provided for @planGuideAddSetBody.
  ///
  /// In en, this message translates to:
  /// **'Use Add Set when you need another set. New sets start with the previous set\'s values.'**
  String get planGuideAddSetBody;

  /// No description provided for @planGuideSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your plan'**
  String get planGuideSaveTitle;

  /// No description provided for @planGuideSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Save Preset to keep this plan and return to the onboarding overview.'**
  String get planGuideSaveBody;

  /// No description provided for @planSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save plan. The previous version is unchanged. {error}'**
  String planSaveFailed(String error);

  /// No description provided for @planOngoingWorkoutKept.
  ///
  /// In en, this message translates to:
  /// **'Your ongoing workout was kept. Finish or cancel it before starting this plan.'**
  String get planOngoingWorkoutKept;

  /// No description provided for @planDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this preset?'**
  String get planDeleteBody;

  /// No description provided for @planDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get planDeletePreset;

  /// No description provided for @planDisableAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Disable Automatic'**
  String get planDisableAutomatic;

  /// No description provided for @planMakeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Make Automatic'**
  String get planMakeAutomatic;

  /// No description provided for @planAutomaticSettings.
  ///
  /// In en, this message translates to:
  /// **'Automatic Settings'**
  String get planAutomaticSettings;

  /// No description provided for @planProgression.
  ///
  /// In en, this message translates to:
  /// **'Plan Progression'**
  String get planProgression;

  /// No description provided for @planNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this preset.'**
  String get planNoExercises;

  /// No description provided for @planSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get planSavePreset;

  /// No description provided for @planStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get planStartSession;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @flowMethodWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get flowMethodWeight;

  /// No description provided for @flowMethodReps.
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get flowMethodReps;

  /// No description provided for @flowMethodAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get flowMethodAddSet;

  /// No description provided for @flowMethodDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get flowMethodDeleteSet;

  /// No description provided for @flowAppDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'App Default Progression'**
  String get flowAppDefaultTitle;

  /// No description provided for @flowProfileDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym Default Progression'**
  String get flowProfileDefaultTitle;

  /// No description provided for @flowPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set how this plan progresses after each workout.'**
  String get flowPlanSubtitle;

  /// No description provided for @flowAppDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the starting progression flow for new gym profiles.'**
  String get flowAppDefaultSubtitle;

  /// No description provided for @flowProfileDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the starting progression flow for new plans in {profileName}.'**
  String flowProfileDefaultSubtitle(String profileName);

  /// No description provided for @flowThisGymProfile.
  ///
  /// In en, this message translates to:
  /// **'this gym profile'**
  String get flowThisGymProfile;

  /// No description provided for @flowManageMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Actions'**
  String get flowManageMethods;

  /// No description provided for @flowAddNewMethod.
  ///
  /// In en, this message translates to:
  /// **'Add New Action'**
  String get flowAddNewMethod;

  /// No description provided for @flowNewMethod.
  ///
  /// In en, this message translates to:
  /// **'New Action'**
  String get flowNewMethod;

  /// No description provided for @flowFactor.
  ///
  /// In en, this message translates to:
  /// **'Factor'**
  String get flowFactor;

  /// No description provided for @flowAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get flowAmount;

  /// No description provided for @flowExplicit.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get flowExplicit;

  /// No description provided for @flowCopyFromSet.
  ///
  /// In en, this message translates to:
  /// **'Copy from set'**
  String get flowCopyFromSet;

  /// No description provided for @flowWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get flowWeight;

  /// No description provided for @flowReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get flowReps;

  /// No description provided for @flowSetIndex.
  ///
  /// In en, this message translates to:
  /// **'Set index (-1 = last)'**
  String get flowSetIndex;

  /// No description provided for @flowDeleteLastSetBody.
  ///
  /// In en, this message translates to:
  /// **'This action will delete the last set.'**
  String get flowDeleteLastSetBody;

  /// No description provided for @flowMethodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Action name cannot be empty'**
  String get flowMethodNameRequired;

  /// No description provided for @flowManageActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage progression actions'**
  String get flowManageActionsTooltip;

  /// No description provided for @flowAddBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a branch'**
  String get flowAddBranchTitle;

  /// No description provided for @flowAddBranchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where the next success or miss should lead.'**
  String get flowAddBranchSubtitle;

  /// No description provided for @flowBranchFrom.
  ///
  /// In en, this message translates to:
  /// **'Branch From'**
  String get flowBranchFrom;

  /// No description provided for @flowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get flowSuccess;

  /// No description provided for @flowMiss.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get flowMiss;

  /// No description provided for @flowAttachActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attach a progression action'**
  String get flowAttachActionTitle;

  /// No description provided for @flowAttachActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply one adjustment of each type to a flow node.'**
  String get flowAttachActionSubtitle;

  /// No description provided for @flowApplyActionTo.
  ///
  /// In en, this message translates to:
  /// **'Apply action to'**
  String get flowApplyActionTo;

  /// No description provided for @flowProgressionAction.
  ///
  /// In en, this message translates to:
  /// **'Progression action'**
  String get flowProgressionAction;

  /// No description provided for @flowAddAction.
  ///
  /// In en, this message translates to:
  /// **'+ Action'**
  String get flowAddAction;

  /// No description provided for @flowRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'- Action'**
  String get flowRemoveAction;

  /// No description provided for @flowRemoveNode.
  ///
  /// In en, this message translates to:
  /// **'- Node'**
  String get flowRemoveNode;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @rulesEditAppDefault.
  ///
  /// In en, this message translates to:
  /// **'Edit App Default Rule'**
  String get rulesEditAppDefault;

  /// No description provided for @rulesEditProfileDefault.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Default Rule'**
  String get rulesEditProfileDefault;

  /// No description provided for @rulesAddAppDefault.
  ///
  /// In en, this message translates to:
  /// **'Add App Default Rule'**
  String get rulesAddAppDefault;

  /// No description provided for @rulesAddProfileDefault.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Default Rule'**
  String get rulesAddProfileDefault;

  /// No description provided for @rulesCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get rulesCopy;

  /// No description provided for @rulesCopyIndex.
  ///
  /// In en, this message translates to:
  /// **'Copy index'**
  String get rulesCopyIndex;

  /// No description provided for @rulesDeleteLastSetBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the last set.'**
  String get rulesDeleteLastSetBody;

  /// No description provided for @rulesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Rule name cannot be empty'**
  String get rulesNameRequired;

  /// No description provided for @rulesProfilesLowercase.
  ///
  /// In en, this message translates to:
  /// **'profiles'**
  String get rulesProfilesLowercase;

  /// No description provided for @rulesPlansLowercase.
  ///
  /// In en, this message translates to:
  /// **'plans'**
  String get rulesPlansLowercase;

  /// No description provided for @rulesAddToExistingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to existing {destination}?'**
  String rulesAddToExistingTitle(String destination);

  /// No description provided for @rulesAddToExistingBody.
  ///
  /// In en, this message translates to:
  /// **'Make \"{name}\" available in {count} existing {destination}? Existing rules with the same name and all saved progression flows will stay unchanged.'**
  String rulesAddToExistingBody(String name, int count, String destination);

  /// No description provided for @rulesNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get rulesNotNow;

  /// No description provided for @rulesAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {destination}'**
  String rulesAddTo(String destination);

  /// No description provided for @rulesNoExistingNeeded.
  ///
  /// In en, this message translates to:
  /// **'No existing {destination} needed this rule.'**
  String rulesNoExistingNeeded(String destination);

  /// No description provided for @rulesCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to {count} {destination}.'**
  String rulesCopiedMessage(String name, int count, String destination);

  /// No description provided for @rulesPropagationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the rule to existing items.'**
  String get rulesPropagationFailed;

  /// No description provided for @rulesOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rule options'**
  String get rulesOptionsTooltip;

  /// No description provided for @rulesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress Rules'**
  String get rulesPageTitle;

  /// No description provided for @rulesPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create reusable rules for how weights, reps, and sets change after workout attempts.'**
  String get rulesPageSubtitle;

  /// No description provided for @rulesHowDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'How defaults work'**
  String get rulesHowDefaultsTitle;

  /// No description provided for @rulesHowDefaultsBody.
  ///
  /// In en, this message translates to:
  /// **'App defaults are copied into new gym profiles. Profile defaults are copied into new plans, so later edits do not unexpectedly rewrite existing plans.'**
  String get rulesHowDefaultsBody;

  /// No description provided for @rulesAppDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'App-wide defaults'**
  String get rulesAppDefaultsTitle;

  /// No description provided for @rulesAppDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The starting rules for new gym profiles.'**
  String get rulesAppDefaultsSubtitle;

  /// No description provided for @rulesNoAppDefaults.
  ///
  /// In en, this message translates to:
  /// **'No app-wide rules have been created yet.'**
  String get rulesNoAppDefaults;

  /// No description provided for @rulesAddApp.
  ///
  /// In en, this message translates to:
  /// **'Add app rule'**
  String get rulesAddApp;

  /// No description provided for @rulesGymProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym profiles'**
  String get rulesGymProfilesTitle;

  /// No description provided for @rulesGymProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each profile keeps its defaults and plan rules together.'**
  String get rulesGymProfilesSubtitle;

  /// No description provided for @rulesNoProfiles.
  ///
  /// In en, this message translates to:
  /// **'Create a gym profile to add profile and plan rules.'**
  String get rulesNoProfiles;

  /// No description provided for @rulesProfileSummary.
  ///
  /// In en, this message translates to:
  /// **'{profileRules} profile rules • {planRules} plan rules'**
  String rulesProfileSummary(int profileRules, int planRules);

  /// No description provided for @rulesProfileDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile defaults'**
  String get rulesProfileDefaultsTitle;

  /// No description provided for @rulesProfileDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Starting rules for new plans in this profile.'**
  String get rulesProfileDefaultsSubtitle;

  /// No description provided for @rulesNoProfileDefaults.
  ///
  /// In en, this message translates to:
  /// **'This profile has no default rules.'**
  String get rulesNoProfileDefaults;

  /// No description provided for @rulesAddProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile rule'**
  String get rulesAddProfile;

  /// No description provided for @rulesPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get rulesPlansTitle;

  /// No description provided for @rulesNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans belong to this gym profile yet.'**
  String get rulesNoPlans;

  /// No description provided for @rulesPlanOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules used only by this plan.'**
  String get rulesPlanOnlySubtitle;

  /// No description provided for @rulesNoPlanRules.
  ///
  /// In en, this message translates to:
  /// **'This plan has no specific progression rules.'**
  String get rulesNoPlanRules;

  /// No description provided for @rulesAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Add plan rule'**
  String get rulesAddPlan;

  /// No description provided for @rulesAppDefaultsChip.
  ///
  /// In en, this message translates to:
  /// **'App defaults'**
  String get rulesAppDefaultsChip;

  /// No description provided for @rulesProfilesChip.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get rulesProfilesChip;

  /// No description provided for @rulesPlansChip.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get rulesPlansChip;

  /// No description provided for @rulesEditPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get rulesEditPlan;

  /// No description provided for @rulesAddPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get rulesAddPlanTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @safeFailureLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load'**
  String get safeFailureLoadTitle;

  /// No description provided for @safeFailureSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to save changes'**
  String get safeFailureSaveTitle;

  /// No description provided for @safeFailureActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not complete that action'**
  String get safeFailureActionTitle;

  /// No description provided for @safeFailureValidation.
  ///
  /// In en, this message translates to:
  /// **'Check the information and try again.'**
  String get safeFailureValidation;

  /// No description provided for @safeFailureOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Reconnect and try again.'**
  String get safeFailureOffline;

  /// No description provided for @safeFailurePermission.
  ///
  /// In en, this message translates to:
  /// **'Tonos does not have permission to complete this action. Check device settings.'**
  String get safeFailurePermission;

  /// No description provided for @safeFailureStorage.
  ///
  /// In en, this message translates to:
  /// **'Tonos could not access device storage. Check available space and try again.'**
  String get safeFailureStorage;

  /// No description provided for @safeFailureInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The data could not be read safely. Choose another file or try again.'**
  String get safeFailureInvalidData;

  /// No description provided for @safeFailureNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested data is no longer available. Refresh and try again.'**
  String get safeFailureNotFound;

  /// No description provided for @safeFailureTemporary.
  ///
  /// In en, this message translates to:
  /// **'This is temporarily unavailable. Try again.'**
  String get safeFailureTemporary;

  /// No description provided for @safeFailureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get safeFailureUnknown;

  /// No description provided for @safeFailureWithGuidance.
  ///
  /// In en, this message translates to:
  /// **'{summary} {guidance}'**
  String safeFailureWithGuidance(String summary, String guidance);

  /// No description provided for @flowPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress Flows'**
  String get flowPageTitle;

  /// No description provided for @flowPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the paths that decide how progression actions are applied after workout results.'**
  String get flowPageSubtitle;

  /// No description provided for @flowHowCopiedTitle.
  ///
  /// In en, this message translates to:
  /// **'How flows are copied'**
  String get flowHowCopiedTitle;

  /// No description provided for @flowHowCopiedBody.
  ///
  /// In en, this message translates to:
  /// **'App flows become the starting point for new gym profiles. Gym flows become the starting point for new plans. Later edits stay scoped to the flow you open here.'**
  String get flowHowCopiedBody;

  /// No description provided for @flowLoadError.
  ///
  /// In en, this message translates to:
  /// **'Workout progression flows could not be loaded.'**
  String get flowLoadError;

  /// No description provided for @flowAppDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The starting flow for new gym profiles.'**
  String get flowAppDefaultsSubtitle;

  /// No description provided for @flowAppDefaultEntry.
  ///
  /// In en, this message translates to:
  /// **'App default flow'**
  String get flowAppDefaultEntry;

  /// No description provided for @flowGymProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each profile has defaults and its own plan flows.'**
  String get flowGymProfilesSubtitle;

  /// No description provided for @flowNoProfiles.
  ///
  /// In en, this message translates to:
  /// **'Create a gym profile to set profile and plan flows.'**
  String get flowNoProfiles;

  /// No description provided for @flowNoSavedYet.
  ///
  /// In en, this message translates to:
  /// **'No saved flow yet'**
  String get flowNoSavedYet;

  /// No description provided for @flowSummary.
  ///
  /// In en, this message translates to:
  /// **'{nodes} nodes | {branches} branches | {actions} actions'**
  String flowSummary(int nodes, int branches, int actions);

  /// No description provided for @flowPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} plan flows available'**
  String flowPlansAvailable(int count);

  /// No description provided for @flowGymDefaultEntry.
  ///
  /// In en, this message translates to:
  /// **'Gym default flow'**
  String get flowGymDefaultEntry;

  /// No description provided for @gymSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym & Workout Settings'**
  String get gymSettingsTitle;

  /// No description provided for @gymSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune workout generation, analytics, and workout-flow behavior.'**
  String get gymSettingsSubtitle;

  /// No description provided for @gymSettingsLogicTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Logic'**
  String get gymSettingsLogicTitle;

  /// No description provided for @gymSettingsLogicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Settings that affect planning and generated workouts.'**
  String get gymSettingsLogicSubtitle;

  /// No description provided for @gymSettingsWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Settings'**
  String get gymSettingsWorkoutTitle;

  /// No description provided for @gymSettingsWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Volume limits, analytics defaults, and training controls.'**
  String get gymSettingsWorkoutSubtitle;

  /// No description provided for @gymSettingsExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Workout Exit'**
  String get gymSettingsExitTitle;

  /// No description provided for @gymSettingsFlowToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow Tools'**
  String get gymSettingsFlowToolsTitle;

  /// No description provided for @gymSettingsFlowToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage saved progression paths and actions.'**
  String get gymSettingsFlowToolsSubtitle;

  /// No description provided for @gymSettingsFlowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit progression flows for app defaults, gyms, and plans.'**
  String get gymSettingsFlowsSubtitle;

  /// No description provided for @gymSettingsRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage weight, rep, and set progression rules.'**
  String get gymSettingsRulesSubtitle;

  /// No description provided for @gymExitAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask every time'**
  String get gymExitAsk;

  /// No description provided for @gymExitDiscard.
  ///
  /// In en, this message translates to:
  /// **'Cancel workout'**
  String get gymExitDiscard;

  /// No description provided for @gymExitSave.
  ///
  /// In en, this message translates to:
  /// **'End and save'**
  String get gymExitSave;

  /// No description provided for @gymExitAskBody.
  ///
  /// In en, this message translates to:
  /// **'Ask before ending completed work.'**
  String get gymExitAskBody;

  /// No description provided for @gymExitDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Cancel without saving completed work.'**
  String get gymExitDiscardBody;

  /// No description provided for @gymExitSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Save completed work to Logbook.'**
  String get gymExitSaveBody;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @catalogGuideChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise'**
  String get catalogGuideChooseTitle;

  /// No description provided for @catalogGuideChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any exercise row to select it. Search or filters can help you find the right movement.'**
  String get catalogGuideChooseBody;

  /// No description provided for @catalogGuideAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add it to your plan'**
  String get catalogGuideAddTitle;

  /// No description provided for @catalogGuideAddBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add {exerciseName} and return to your plan.'**
  String catalogGuideAddBody(String exerciseName);

  /// No description provided for @catalogGuideSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get catalogGuideSearchTitle;

  /// No description provided for @catalogGuideSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search by exercise name when you already know what movement you want.'**
  String get catalogGuideSearchBody;

  /// No description provided for @catalogFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get catalogFilters;

  /// No description provided for @catalogGuideFiltersBody.
  ///
  /// In en, this message translates to:
  /// **'Filter by gym profile, equipment, bodypart, or muscle to narrow the catalog quickly.'**
  String get catalogGuideFiltersBody;

  /// No description provided for @catalogGuideRowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise rows'**
  String get catalogGuideRowsTitle;

  /// No description provided for @catalogGuideRowsBody.
  ///
  /// In en, this message translates to:
  /// **'Each row shows equipment and a heatmap. Tap the heatmap for details or select the row when choosing an exercise.'**
  String get catalogGuideRowsBody;

  /// No description provided for @catalogSelectedFilters.
  ///
  /// In en, this message translates to:
  /// **'Selected Filters'**
  String get catalogSelectedFilters;

  /// No description provided for @catalogUseWorkspaceProfile.
  ///
  /// In en, this message translates to:
  /// **'Use Workspace Profile'**
  String get catalogUseWorkspaceProfile;

  /// No description provided for @catalogWorkspaceProfile.
  ///
  /// In en, this message translates to:
  /// **'Workspace Profile'**
  String get catalogWorkspaceProfile;

  /// No description provided for @catalogEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get catalogEquipment;

  /// No description provided for @catalogFocusArea.
  ///
  /// In en, this message translates to:
  /// **'Area of Focus'**
  String get catalogFocusArea;

  /// No description provided for @catalogSpecificMuscle.
  ///
  /// In en, this message translates to:
  /// **'Specific Muscle'**
  String get catalogSpecificMuscle;

  /// No description provided for @catalogPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Catalog'**
  String get catalogPageTitle;

  /// No description provided for @catalogSearchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search Exercises'**
  String get catalogSearchExercises;

  /// No description provided for @catalogNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No exercises match filters.'**
  String get catalogNoMatches;

  /// No description provided for @catalogOpenExerciseInfo.
  ///
  /// In en, this message translates to:
  /// **'Open exercise information'**
  String get catalogOpenExerciseInfo;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @exerciseDetailOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Open exercise image'**
  String get exerciseDetailOpenImage;

  /// No description provided for @exerciseDetailTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise details'**
  String get exerciseDetailTutorialTitle;

  /// No description provided for @exerciseDetailTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'The sheet title is the exercise you opened. Close it from here when you are done.'**
  String get exerciseDetailTutorialBody;

  /// No description provided for @exerciseDetailTabsTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Details, metrics, records'**
  String get exerciseDetailTabsTutorialTitle;

  /// No description provided for @exerciseDetailTabsTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Use these tabs to switch between instructions, best lifts, and recent workout records.'**
  String get exerciseDetailTabsTutorialBody;

  /// No description provided for @exerciseDetailContextTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise context'**
  String get exerciseDetailContextTutorialTitle;

  /// No description provided for @exerciseDetailContextTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'The details tab shows equipment, trained bodyparts, muscles, and form notes for the exercise.'**
  String get exerciseDetailContextTutorialBody;

  /// No description provided for @exerciseDetailSessionOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Workout session could not be opened.'**
  String get exerciseDetailSessionOpenFailed;

  /// No description provided for @exerciseDetailSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout session could not be found.'**
  String get exerciseDetailSessionNotFound;

  /// No description provided for @exerciseDetailNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment listed for this exercise.'**
  String get exerciseDetailNoEquipment;

  /// No description provided for @exerciseDetailTargetAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Target anatomy'**
  String get exerciseDetailTargetAnatomy;

  /// No description provided for @exerciseDetailBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Body parts'**
  String get exerciseDetailBodyParts;

  /// No description provided for @exerciseDetailNoBodyParts.
  ///
  /// In en, this message translates to:
  /// **'No body parts listed.'**
  String get exerciseDetailNoBodyParts;

  /// No description provided for @exerciseDetailMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get exerciseDetailMuscles;

  /// No description provided for @exerciseDetailNoMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscles listed.'**
  String get exerciseDetailNoMuscles;

  /// No description provided for @exerciseDetailSetup.
  ///
  /// In en, this message translates to:
  /// **'Set-up'**
  String get exerciseDetailSetup;

  /// No description provided for @exerciseDetailNoSetup.
  ///
  /// In en, this message translates to:
  /// **'No setup instructions provided.'**
  String get exerciseDetailNoSetup;

  /// No description provided for @exerciseDetailExecution.
  ///
  /// In en, this message translates to:
  /// **'Execution'**
  String get exerciseDetailExecution;

  /// No description provided for @exerciseDetailNoExecution.
  ///
  /// In en, this message translates to:
  /// **'No execution notes provided.'**
  String get exerciseDetailNoExecution;

  /// No description provided for @exerciseDetailTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get exerciseDetailTips;

  /// No description provided for @exerciseDetailNoTips.
  ///
  /// In en, this message translates to:
  /// **'No additional tips.'**
  String get exerciseDetailNoTips;

  /// No description provided for @exerciseDetailFormGuide.
  ///
  /// In en, this message translates to:
  /// **'Form guide'**
  String get exerciseDetailFormGuide;

  /// No description provided for @exerciseDetailOpenHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Open targeted body heatmap'**
  String get exerciseDetailOpenHeatmap;

  /// No description provided for @exerciseDetailNoHeatmap.
  ///
  /// In en, this message translates to:
  /// **'No targeted body areas available'**
  String get exerciseDetailNoHeatmap;

  /// No description provided for @exerciseDetailZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or drag to zoom'**
  String get exerciseDetailZoomHint;

  /// No description provided for @exerciseDetailLoadingBestLifts.
  ///
  /// In en, this message translates to:
  /// **'Loading best lifts'**
  String get exerciseDetailLoadingBestLifts;

  /// No description provided for @exerciseDetailLoadingBestLiftsBody.
  ///
  /// In en, this message translates to:
  /// **'Your completed set records are being calculated.'**
  String get exerciseDetailLoadingBestLiftsBody;

  /// No description provided for @exerciseDetailMetricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Metrics unavailable'**
  String get exerciseDetailMetricsUnavailable;

  /// No description provided for @exerciseDetailMetricsUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Try reopening this exercise to load its completed set records.'**
  String get exerciseDetailMetricsUnavailableBody;

  /// No description provided for @exerciseDetailNoBestLifts.
  ///
  /// In en, this message translates to:
  /// **'No best lifts yet'**
  String get exerciseDetailNoBestLifts;

  /// No description provided for @exerciseDetailNoBestLiftsBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a weighted set for this exercise to begin tracking rep bests.'**
  String get exerciseDetailNoBestLiftsBody;

  /// No description provided for @exerciseDetailWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get exerciseDetailWeek;

  /// No description provided for @exerciseDetailMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get exerciseDetailMonth;

  /// No description provided for @exerciseDetailAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get exerciseDetailAllTime;

  /// No description provided for @exerciseDetailTimeframeMetrics.
  ///
  /// In en, this message translates to:
  /// **'{timeframe} metrics'**
  String exerciseDetailTimeframeMetrics(String timeframe);

  /// No description provided for @exerciseDetailTopEstimatedOneRm.
  ///
  /// In en, this message translates to:
  /// **'Top est. 1RM'**
  String get exerciseDetailTopEstimatedOneRm;

  /// No description provided for @exerciseDetailVolumeBest.
  ///
  /// In en, this message translates to:
  /// **'Volume best'**
  String get exerciseDetailVolumeBest;

  /// No description provided for @exerciseDetailRepBests.
  ///
  /// In en, this message translates to:
  /// **'Rep bests'**
  String get exerciseDetailRepBests;

  /// No description provided for @exerciseDetailRepBestsBody.
  ///
  /// In en, this message translates to:
  /// **'Best completed weight for each rep count'**
  String get exerciseDetailRepBestsBody;

  /// No description provided for @exerciseDetailRanges.
  ///
  /// In en, this message translates to:
  /// **'{count} ranges'**
  String exerciseDetailRanges(int count);

  /// No description provided for @exerciseDetailHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load exercise history.'**
  String get exerciseDetailHistoryLoadFailed;

  /// No description provided for @exerciseDetailNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history for this exercise.'**
  String get exerciseDetailNoHistory;

  /// No description provided for @exerciseDetailPerformanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance trend'**
  String get exerciseDetailPerformanceTrend;

  /// No description provided for @exerciseDetailBestWeight.
  ///
  /// In en, this message translates to:
  /// **'Best weight'**
  String get exerciseDetailBestWeight;

  /// No description provided for @exerciseDetailEstimatedOneRm.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get exerciseDetailEstimatedOneRm;

  /// No description provided for @exerciseDetailLoadingSessions.
  ///
  /// In en, this message translates to:
  /// **'Loading sessions'**
  String get exerciseDetailLoadingSessions;

  /// No description provided for @exerciseDetailLoadMoreSessions.
  ///
  /// In en, this message translates to:
  /// **'Load 10 more sessions'**
  String get exerciseDetailLoadMoreSessions;

  /// No description provided for @exerciseDetailResizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resize exercise details'**
  String get exerciseDetailResizeLabel;

  /// No description provided for @exerciseDetailResizeHint.
  ///
  /// In en, this message translates to:
  /// **'Drag up or down to resize the sheet'**
  String get exerciseDetailResizeHint;

  /// No description provided for @exerciseDetailTabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get exerciseDetailTabDetails;

  /// No description provided for @exerciseDetailTabMetrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get exerciseDetailTabMetrics;

  /// No description provided for @exerciseDetailTabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get exerciseDetailTabRecords;

  /// No description provided for @exerciseDetailOpenWorkoutWithSets.
  ///
  /// In en, this message translates to:
  /// **'Open workout with {count} completed sets'**
  String exerciseDetailOpenWorkoutWithSets(int count);

  /// No description provided for @exerciseDetailSetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String exerciseDetailSetCount(int count);

  /// No description provided for @exerciseDetailEstimatedMax.
  ///
  /// In en, this message translates to:
  /// **'ERM {weight}'**
  String exerciseDetailEstimatedMax(String weight);

  /// No description provided for @exerciseDetailReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get exerciseDetailReps;

  /// No description provided for @exerciseDetailSetVolume.
  ///
  /// In en, this message translates to:
  /// **'Set volume'**
  String get exerciseDetailSetVolume;

  /// No description provided for @exerciseDetailNoChartData.
  ///
  /// In en, this message translates to:
  /// **'No completed set records to chart yet.'**
  String get exerciseDetailNoChartData;

  /// No description provided for @exerciseDetailWeightAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Wt'**
  String get exerciseDetailWeightAbbreviation;

  /// No description provided for @exerciseDetailEstimatedAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Est'**
  String get exerciseDetailEstimatedAbbreviation;

  /// No description provided for @exerciseDetailTopAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get exerciseDetailTopAbbreviation;

  /// No description provided for @exerciseDetailSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'{title} section'**
  String exerciseDetailSectionLabel(String title);

  /// No description provided for @logbookTutorialCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Logbook calendar'**
  String get logbookTutorialCalendarTitle;

  /// No description provided for @logbookTutorialCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Use M, 3M, Y, and 4Y to browse workout history. Select a day, week, month, or year to see sessions and summary stats for that range.'**
  String get logbookTutorialCalendarBody;

  /// No description provided for @fullHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'All sessions'**
  String get fullHistoryTitle;

  /// No description provided for @fullHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load saved sessions.'**
  String get fullHistoryLoadError;

  /// No description provided for @fullHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions saved.'**
  String get fullHistoryEmpty;

  /// No description provided for @fullHistorySessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{date} - {duration}'**
  String fullHistorySessionSummary(String date, String duration);

  /// No description provided for @weeklySetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly sets overview'**
  String get weeklySetsTitle;

  /// No description provided for @weeklySetsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your weekly training overview.'**
  String get weeklySetsLoadError;

  /// No description provided for @weeklySetsBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts'**
  String get weeklySetsBodyParts;

  /// No description provided for @weeklySetsMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get weeklySetsMuscles;

  /// No description provided for @weeklySetsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total sets'**
  String get weeklySetsTotal;

  /// No description provided for @weeklySetsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get weeklySetsTime;

  /// No description provided for @weeklySetsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get weeklySetsVolume;

  /// No description provided for @weeklySetsNoBodyParts.
  ///
  /// In en, this message translates to:
  /// **'No bodypart sets yet.'**
  String get weeklySetsNoBodyParts;

  /// No description provided for @weeklySetsNoMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscle sets yet.'**
  String get weeklySetsNoMuscles;

  /// No description provided for @weeklySetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String weeklySetsCount(String count);

  /// No description provided for @weeklySetsTutorialOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly overview'**
  String get weeklySetsTutorialOverviewTitle;

  /// No description provided for @weeklySetsTutorialOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This summarizes the last seven days with a heatmap plus total sets, time, and volume.'**
  String get weeklySetsTutorialOverviewBody;

  /// No description provided for @weeklySetsTutorialAnatomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts or muscles'**
  String get weeklySetsTutorialAnatomyTitle;

  /// No description provided for @weeklySetsTutorialAnatomyBody.
  ///
  /// In en, this message translates to:
  /// **'Switch between bodypart set units and individual muscle set units.'**
  String get weeklySetsTutorialAnatomyBody;

  /// No description provided for @weeklySetsTutorialStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Set status'**
  String get weeklySetsTutorialStatusTitle;

  /// No description provided for @weeklySetsTutorialStatusBody.
  ///
  /// In en, this message translates to:
  /// **'Each row is tinted based on whether your recent work is under, inside, or above its recommended range. Tap a row for linked exercises.'**
  String get weeklySetsTutorialStatusBody;

  /// No description provided for @workoutDetailTutorialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout summary'**
  String get workoutDetailTutorialSummaryTitle;

  /// No description provided for @workoutDetailTutorialSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Review total sets, volume, duration, exercise count, and the bodyparts this workout hit.'**
  String get workoutDetailTutorialSummaryBody;

  /// No description provided for @workoutDetailTutorialExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise records'**
  String get workoutDetailTutorialExercisesTitle;

  /// No description provided for @workoutDetailTutorialExercisesBody.
  ///
  /// In en, this message translates to:
  /// **'Each exercise shows the completed sets from that session. Tap details to inspect the exercise.'**
  String get workoutDetailTutorialExercisesBody;

  /// No description provided for @workoutDetailTutorialEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get workoutDetailTutorialEditTitle;

  /// No description provided for @workoutDetailTutorialEditBody.
  ///
  /// In en, this message translates to:
  /// **'Use edit mode if you need to correct sets, reps, or exercises after the workout.'**
  String get workoutDetailTutorialEditBody;

  /// No description provided for @workoutDetailTutorialReuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse this workout'**
  String get workoutDetailTutorialReuseTitle;

  /// No description provided for @workoutDetailTutorialReuseBody.
  ///
  /// In en, this message translates to:
  /// **'Do the workout again or save the completed session as a reusable plan.'**
  String get workoutDetailTutorialReuseBody;

  /// No description provided for @workoutDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get workoutDetailDeleteTitle;

  /// No description provided for @workoutDetailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this session?'**
  String get workoutDetailDeleteBody;

  /// No description provided for @workoutDetailDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this session.'**
  String get workoutDetailDeleteFailed;

  /// No description provided for @workoutDetailChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get workoutDetailChangesSaved;

  /// No description provided for @workoutDetailSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. The previous session is unchanged.'**
  String get workoutDetailSaveFailed;

  /// No description provided for @workoutDetailFinishCurrentFirst.
  ///
  /// In en, this message translates to:
  /// **'Finish your current workout before repeating this one.'**
  String get workoutDetailFinishCurrentFirst;

  /// No description provided for @workoutDetailOngoingWorkoutKept.
  ///
  /// In en, this message translates to:
  /// **'Your ongoing workout was kept. Finish or cancel it before repeating this workout.'**
  String get workoutDetailOngoingWorkoutKept;

  /// No description provided for @workoutDetailRepeatFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not repeat this workout.'**
  String get workoutDetailRepeatFailed;

  /// No description provided for @workoutDetailSaveAsPlan.
  ///
  /// In en, this message translates to:
  /// **'Save as plan'**
  String get workoutDetailSaveAsPlan;

  /// No description provided for @workoutDetailPlanName.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get workoutDetailPlanName;

  /// No description provided for @workoutDetailPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\" as a plan.'**
  String workoutDetailPlanSaved(String name);

  /// No description provided for @workoutDetailPlanSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save plan.'**
  String get workoutDetailPlanSaveFailed;

  /// No description provided for @workoutDetailDefaultPlanName.
  ///
  /// In en, this message translates to:
  /// **'Workout {date}'**
  String workoutDetailDefaultPlanName(String date);

  /// No description provided for @workoutDetailUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get workoutDetailUnsavedTitle;

  /// No description provided for @workoutDetailUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them and leave?'**
  String get workoutDetailUnsavedBody;

  /// No description provided for @workoutDetailDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get workoutDetailDiscard;

  /// No description provided for @workoutDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout detail'**
  String get workoutDetailTitle;

  /// No description provided for @workoutDetailStopEditing.
  ///
  /// In en, this message translates to:
  /// **'Stop editing'**
  String get workoutDetailStopEditing;

  /// No description provided for @workoutDetailEditSession.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get workoutDetailEditSession;

  /// No description provided for @workoutDetailDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get workoutDetailDeleteSession;

  /// No description provided for @workoutDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this session.'**
  String get workoutDetailLoadFailed;

  /// No description provided for @workoutDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this session.'**
  String get workoutDetailEmpty;

  /// No description provided for @workoutDetailSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get workoutDetailSaveChanges;

  /// No description provided for @workoutDetailRepeat.
  ///
  /// In en, this message translates to:
  /// **'Do workout again'**
  String get workoutDetailRepeat;

  /// No description provided for @workoutDetailPastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Past workout'**
  String get workoutDetailPastWorkout;

  /// No description provided for @workoutDetailCompletedSets.
  ///
  /// In en, this message translates to:
  /// **'{count} completed sets'**
  String workoutDetailCompletedSets(int count);

  /// No description provided for @workoutDetailVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get workoutDetailVolume;

  /// No description provided for @workoutDetailDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutDetailDuration;

  /// No description provided for @workoutDetailExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutDetailExercises;

  /// No description provided for @workoutDetailExerciseInfo.
  ///
  /// In en, this message translates to:
  /// **'Exercise info'**
  String get workoutDetailExerciseInfo;

  /// No description provided for @workoutDetailBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get workoutDetailBest;

  /// No description provided for @workoutDetailEstimatedOneRm.
  ///
  /// In en, this message translates to:
  /// **'1RM = {weight}'**
  String workoutDetailEstimatedOneRm(String weight);

  /// No description provided for @logbookCalendarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load workout calendar.'**
  String get logbookCalendarLoadFailed;

  /// No description provided for @logbookNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged'**
  String get logbookNoWorkouts;

  /// No description provided for @logbookWorkoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}}'**
  String logbookWorkoutCount(int count);

  /// No description provided for @logbookPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get logbookPreviousMonth;

  /// No description provided for @logbookNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get logbookNextMonth;

  /// No description provided for @logbookPreviousThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'Previous 3 months'**
  String get logbookPreviousThreeMonths;

  /// No description provided for @logbookNextThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'Next 3 months'**
  String get logbookNextThreeMonths;

  /// No description provided for @logbookPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get logbookPreviousYear;

  /// No description provided for @logbookNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get logbookNextYear;

  /// No description provided for @logbookWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String logbookWeekShort(int week);

  /// No description provided for @logbookMonthWeek.
  ///
  /// In en, this message translates to:
  /// **'{month} week {week}'**
  String logbookMonthWeek(String month, int week);

  /// No description provided for @logbookWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get logbookWorkouts;

  /// No description provided for @logbookTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get logbookTotalTime;

  /// No description provided for @logbookTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get logbookTotalVolume;

  /// No description provided for @logbookViewAllSessions.
  ///
  /// In en, this message translates to:
  /// **'View all sessions'**
  String get logbookViewAllSessions;

  /// No description provided for @logbookSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{duration} - {exercises, plural, =1{1 exercise} other{{exercises} exercises}} - {sets, plural, =1{1 set} other{{sets} sets}} - {volume}'**
  String logbookSessionSummary(
    String duration,
    int exercises,
    int sets,
    String volume,
  );

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(int hours);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @dashboardHideSection.
  ///
  /// In en, this message translates to:
  /// **'Hide section'**
  String get dashboardHideSection;

  /// No description provided for @dashboardAllSectionsShown.
  ///
  /// In en, this message translates to:
  /// **'All sections are shown'**
  String get dashboardAllSectionsShown;

  /// No description provided for @dashboardHiddenSectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} section(s) hidden'**
  String dashboardHiddenSectionCount(int count);

  /// No description provided for @dashboardShowHiddenSections.
  ///
  /// In en, this message translates to:
  /// **'Show hidden sections'**
  String get dashboardShowHiddenSections;

  /// No description provided for @dashboardReset.
  ///
  /// In en, this message translates to:
  /// **'Reset dashboard'**
  String get dashboardReset;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard is empty'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add back any section whenever you are ready.'**
  String get dashboardEmptyBody;

  /// No description provided for @dashboardCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize dashboard'**
  String get dashboardCustomize;

  /// No description provided for @dashboardSectionQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboardSectionQuickActionsTitle;

  /// No description provided for @dashboardSectionQuickActionsBody.
  ///
  /// In en, this message translates to:
  /// **'Log a measurement or start a workout.'**
  String get dashboardSectionQuickActionsBody;

  /// No description provided for @dashboardSectionTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to train'**
  String get dashboardSectionTrainingTitle;

  /// No description provided for @dashboardSectionTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'Select your gym profile, plans, and start a session.'**
  String get dashboardSectionTrainingBody;

  /// No description provided for @dashboardSectionNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition dashboard'**
  String get dashboardSectionNutritionTitle;

  /// No description provided for @dashboardSectionNutritionBody.
  ///
  /// In en, this message translates to:
  /// **'Review current calorie and macro targets.'**
  String get dashboardSectionNutritionBody;

  /// No description provided for @dashboardSectionDataRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & records'**
  String get dashboardSectionDataRecordsTitle;

  /// No description provided for @dashboardSectionDataRecordsBody.
  ///
  /// In en, this message translates to:
  /// **'Review and add daily nutrition entries.'**
  String get dashboardSectionDataRecordsBody;

  /// No description provided for @dashboardSectionWeeklyFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly focus'**
  String get dashboardSectionWeeklyFocusTitle;

  /// No description provided for @dashboardSectionWeeklyFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Review bodypart and muscle work from the last 7 days.'**
  String get dashboardSectionWeeklyFocusBody;

  /// No description provided for @dashboardSectionWorkoutReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout report'**
  String get dashboardSectionWorkoutReportTitle;

  /// No description provided for @dashboardSectionWorkoutReportBody.
  ///
  /// In en, this message translates to:
  /// **'Compare workout count, time, and volume over time.'**
  String get dashboardSectionWorkoutReportBody;

  /// No description provided for @dashboardSectionExerciseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise progress'**
  String get dashboardSectionExerciseProgressTitle;

  /// No description provided for @dashboardSectionExerciseProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Follow strength trends for your selected exercises.'**
  String get dashboardSectionExerciseProgressBody;

  /// No description provided for @dashboardSectionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Training history'**
  String get dashboardSectionHistoryTitle;

  /// No description provided for @dashboardSectionHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Compare workout totals and focus across time ranges.'**
  String get dashboardSectionHistoryBody;

  /// No description provided for @dashboardSectionHealthTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health trends'**
  String get dashboardSectionHealthTrendsTitle;

  /// No description provided for @dashboardSectionHealthTrendsBody.
  ///
  /// In en, this message translates to:
  /// **'Track measurements such as bodyweight and sizes.'**
  String get dashboardSectionHealthTrendsBody;

  /// No description provided for @dashboardSectionRecentWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get dashboardSectionRecentWorkoutsTitle;

  /// No description provided for @dashboardSectionRecentWorkoutsBody.
  ///
  /// In en, this message translates to:
  /// **'Open your latest completed workout sessions.'**
  String get dashboardSectionRecentWorkoutsBody;

  /// No description provided for @dashboardSectionActivePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plans'**
  String get dashboardSectionActivePlansTitle;

  /// No description provided for @dashboardSectionActivePlansBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the plans you use most often close at hand.'**
  String get dashboardSectionActivePlansBody;

  /// No description provided for @dashboardSectionArchivedPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived plans'**
  String get dashboardSectionArchivedPlansTitle;

  /// No description provided for @dashboardSectionArchivedPlansBody.
  ///
  /// In en, this message translates to:
  /// **'Browse plans that are not currently active.'**
  String get dashboardSectionArchivedPlansBody;

  /// No description provided for @dashboardSectionPremadePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Premade plans'**
  String get dashboardSectionPremadePlansTitle;

  /// No description provided for @dashboardSectionPremadePlansBody.
  ///
  /// In en, this message translates to:
  /// **'Browse routines that can be added to this profile.'**
  String get dashboardSectionPremadePlansBody;

  /// No description provided for @dashboardSectionPlanToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan tools'**
  String get dashboardSectionPlanToolsTitle;

  /// No description provided for @dashboardSectionPlanToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Generate a balanced plan or create one manually.'**
  String get dashboardSectionPlanToolsBody;

  /// No description provided for @dashboardSectionCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise catalog'**
  String get dashboardSectionCatalogTitle;

  /// No description provided for @dashboardSectionCatalogBody.
  ///
  /// In en, this message translates to:
  /// **'Open your most used exercises and the full catalog.'**
  String get dashboardSectionCatalogBody;

  /// No description provided for @dashboardSectionAnatomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Target anatomy'**
  String get dashboardSectionAnatomyTitle;

  /// No description provided for @dashboardSectionAnatomyBody.
  ///
  /// In en, this message translates to:
  /// **'Review the bodyparts and muscles you train most.'**
  String get dashboardSectionAnatomyBody;

  /// No description provided for @dashboardSectionFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard section'**
  String get dashboardSectionFallbackTitle;

  /// No description provided for @dashboardSectionFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'A dashboard section.'**
  String get dashboardSectionFallbackBody;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardDoneCustomizing.
  ///
  /// In en, this message translates to:
  /// **'Done customizing'**
  String get dashboardDoneCustomizing;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Measurement'**
  String get dashboardMeasurement;

  /// No description provided for @dashboardResumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get dashboardResumeWorkout;

  /// No description provided for @dashboardStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get dashboardStartWorkout;

  /// No description provided for @dashboardTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String dashboardTodayAt(String time);

  /// No description provided for @dashboardRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get dashboardRecentWorkouts;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAll;

  /// No description provided for @dashboardRecentWorkoutsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load recent workouts.'**
  String get dashboardRecentWorkoutsFailed;

  /// No description provided for @dashboardRecentWorkoutsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finish a workout and it will appear here.'**
  String get dashboardRecentWorkoutsEmpty;

  /// No description provided for @userInfoProfileUpdateNote.
  ///
  /// In en, this message translates to:
  /// **'Profile update'**
  String get userInfoProfileUpdateNote;

  /// No description provided for @userInfoChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get userInfoChangesSaved;

  /// No description provided for @userInfoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your changes.'**
  String get userInfoSaveFailed;

  /// No description provided for @userInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'User information'**
  String get userInfoTitle;

  /// No description provided for @userInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep basic profile details available for app calculations.'**
  String get userInfoSubtitle;

  /// No description provided for @userInfoIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get userInfoIdentityTitle;

  /// No description provided for @userInfoIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic personal details.'**
  String get userInfoIdentitySubtitle;

  /// No description provided for @userInfoName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get userInfoName;

  /// No description provided for @userInfoNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get userInfoNameHint;

  /// No description provided for @userInfoGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get userInfoGender;

  /// No description provided for @userInfoDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get userInfoDateOfBirth;

  /// No description provided for @userInfoDateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get userInfoDateHint;

  /// No description provided for @userInfoBodyMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Body metrics'**
  String get userInfoBodyMetricsTitle;

  /// No description provided for @userInfoBodyMetricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional details used by progress and nutrition estimates.'**
  String get userInfoBodyMetricsSubtitle;

  /// No description provided for @userInfoHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get userInfoHeight;

  /// No description provided for @userInfoHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5\'10\" or 178 cm'**
  String get userInfoHeightHint;

  /// No description provided for @userInfoCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get userInfoCurrentWeight;

  /// No description provided for @userInfoWeightPoundsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 160'**
  String get userInfoWeightPoundsHint;

  /// No description provided for @userInfoWeightKilogramsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 72'**
  String get userInfoWeightKilogramsHint;

  /// No description provided for @userInfoBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body-fat % estimate'**
  String get userInfoBodyFat;

  /// No description provided for @userInfoActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity context'**
  String get userInfoActivityTitle;

  /// No description provided for @userInfoActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used later for recommendations and health estimates.'**
  String get userInfoActivitySubtitle;

  /// No description provided for @userInfoWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get userInfoWeightTrend;

  /// No description provided for @userInfoAverageSteps.
  ///
  /// In en, this message translates to:
  /// **'Estimated avg steps'**
  String get userInfoAverageSteps;

  /// No description provided for @userInfoGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get userInfoGenderMale;

  /// No description provided for @userInfoGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get userInfoGenderFemale;

  /// No description provided for @userInfoGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get userInfoGenderOther;

  /// No description provided for @userInfoGenderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get userInfoGenderPreferNotToSay;

  /// No description provided for @userInfoTrendGaining.
  ///
  /// In en, this message translates to:
  /// **'Gaining weight'**
  String get userInfoTrendGaining;

  /// No description provided for @userInfoTrendLosing.
  ///
  /// In en, this message translates to:
  /// **'Losing weight'**
  String get userInfoTrendLosing;

  /// No description provided for @userInfoTrendMaintaining.
  ///
  /// In en, this message translates to:
  /// **'Maintaining weight'**
  String get userInfoTrendMaintaining;

  /// No description provided for @userInfoTrendNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get userInfoTrendNotSure;

  /// No description provided for @userInfoActivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (0-5k)'**
  String get userInfoActivityLow;

  /// No description provided for @userInfoActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (5-15k)'**
  String get userInfoActivityModerate;

  /// No description provided for @userInfoActivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (15k+)'**
  String get userInfoActivityHigh;

  /// No description provided for @userInfoSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get userInfoSaveChanges;

  /// No description provided for @tutorialsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided tutorials'**
  String get tutorialsSettingsTitle;

  /// No description provided for @tutorialsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay a walkthrough when you want a quick refresher.'**
  String get tutorialsSettingsSubtitle;

  /// No description provided for @tutorialsControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial controls'**
  String get tutorialsControlsTitle;

  /// No description provided for @tutorialsControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Testing or starting fresh?'**
  String get tutorialsControlsSubtitle;

  /// No description provided for @tutorialsResetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tutorials'**
  String get tutorialsResetAllTitle;

  /// No description provided for @tutorialsResetAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Makes every guided tutorial available again.'**
  String get tutorialsResetAllSubtitle;

  /// No description provided for @tutorialsResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get tutorialsResetAll;

  /// No description provided for @tutorialsResetAllMessage.
  ///
  /// In en, this message translates to:
  /// **'All tutorials have been reset.'**
  String get tutorialsResetAllMessage;

  /// No description provided for @tutorialsHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How tutorials work'**
  String get tutorialsHowItWorksTitle;

  /// No description provided for @tutorialsHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Tutorials appear once, then stay out of the way. Expand a group to reset a specific walkthrough.'**
  String get tutorialsHowItWorksBody;

  /// No description provided for @tutorialsMainTabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main tabs'**
  String get tutorialsMainTabsTitle;

  /// No description provided for @tutorialsMainTabsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay walkthroughs for each main area.'**
  String get tutorialsMainTabsSubtitle;

  /// No description provided for @tutorialsWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get tutorialsWorkoutTitle;

  /// No description provided for @tutorialsWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help for logging your first session.'**
  String get tutorialsWorkoutSubtitle;

  /// No description provided for @tutorialsPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans & workouts'**
  String get tutorialsPlansTitle;

  /// No description provided for @tutorialsPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay plan creation, editing, and workout detail help.'**
  String get tutorialsPlansSubtitle;

  /// No description provided for @tutorialsCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog & anatomy'**
  String get tutorialsCatalogTitle;

  /// No description provided for @tutorialsCatalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay exercise and target anatomy help.'**
  String get tutorialsCatalogSubtitle;

  /// No description provided for @tutorialsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & settings'**
  String get tutorialsProgressTitle;

  /// No description provided for @tutorialsProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay progress detail and settings page help.'**
  String get tutorialsProgressSubtitle;

  /// No description provided for @tutorialsReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay {topic} tutorial'**
  String tutorialsReplayTitle(String topic);

  /// No description provided for @tutorialsShownNextTime.
  ///
  /// In en, this message translates to:
  /// **'Shows next time you open {topic}.'**
  String tutorialsShownNextTime(String topic);

  /// No description provided for @tutorialsWillReplayNextTime.
  ///
  /// In en, this message translates to:
  /// **'{topic} tutorial will replay next time.'**
  String tutorialsWillReplayNextTime(String topic);

  /// No description provided for @tutorialsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tutorialsReset;

  /// No description provided for @tutorialsTopicTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get tutorialsTopicTrain;

  /// No description provided for @tutorialsTopicCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get tutorialsTopicCatalog;

  /// No description provided for @tutorialsTopicLogbook.
  ///
  /// In en, this message translates to:
  /// **'Logbook'**
  String get tutorialsTopicLogbook;

  /// No description provided for @tutorialsTopicProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tutorialsTopicProgress;

  /// No description provided for @tutorialsTopicProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tutorialsTopicProfile;

  /// No description provided for @tutorialsTopicFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'first workout'**
  String get tutorialsTopicFirstWorkout;

  /// No description provided for @tutorialsTopicGeneratePlans.
  ///
  /// In en, this message translates to:
  /// **'Generate Plans'**
  String get tutorialsTopicGeneratePlans;

  /// No description provided for @tutorialsTopicOptimizedSettings.
  ///
  /// In en, this message translates to:
  /// **'optimized workout settings'**
  String get tutorialsTopicOptimizedSettings;

  /// No description provided for @tutorialsTopicPremadePlans.
  ///
  /// In en, this message translates to:
  /// **'Premade Plans'**
  String get tutorialsTopicPremadePlans;

  /// No description provided for @tutorialsTopicPlanManagement.
  ///
  /// In en, this message translates to:
  /// **'plan management'**
  String get tutorialsTopicPlanManagement;

  /// No description provided for @tutorialsTopicPlanDetail.
  ///
  /// In en, this message translates to:
  /// **'plan details'**
  String get tutorialsTopicPlanDetail;

  /// No description provided for @tutorialsTopicPlanBuilder.
  ///
  /// In en, this message translates to:
  /// **'plan builder'**
  String get tutorialsTopicPlanBuilder;

  /// No description provided for @tutorialsTopicWorkoutDetail.
  ///
  /// In en, this message translates to:
  /// **'workout details'**
  String get tutorialsTopicWorkoutDetail;

  /// No description provided for @tutorialsTopicExerciseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Exercise Catalog'**
  String get tutorialsTopicExerciseCatalog;

  /// No description provided for @tutorialsTopicExerciseDetail.
  ///
  /// In en, this message translates to:
  /// **'exercise details'**
  String get tutorialsTopicExerciseDetail;

  /// No description provided for @tutorialsTopicTargetAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Target Anatomy'**
  String get tutorialsTopicTargetAnatomy;

  /// No description provided for @tutorialsTopicBodypartDetail.
  ///
  /// In en, this message translates to:
  /// **'bodypart details'**
  String get tutorialsTopicBodypartDetail;

  /// No description provided for @tutorialsTopicMuscleDetail.
  ///
  /// In en, this message translates to:
  /// **'muscle details'**
  String get tutorialsTopicMuscleDetail;

  /// No description provided for @tutorialsTopicWeeklySets.
  ///
  /// In en, this message translates to:
  /// **'Weekly Sets Overview'**
  String get tutorialsTopicWeeklySets;

  /// No description provided for @tutorialsTopicExerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'exercise progress'**
  String get tutorialsTopicExerciseProgress;

  /// No description provided for @tutorialsTopicMeasurementTrend.
  ///
  /// In en, this message translates to:
  /// **'measurement trend'**
  String get tutorialsTopicMeasurementTrend;

  /// No description provided for @tutorialsTopicGymProfile.
  ///
  /// In en, this message translates to:
  /// **'Gym Profile editor'**
  String get tutorialsTopicGymProfile;

  /// No description provided for @tutorialsTopicUiAppearance.
  ///
  /// In en, this message translates to:
  /// **'UI & Appearance'**
  String get tutorialsTopicUiAppearance;

  /// No description provided for @tutorialsTopicDatabaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Database Settings'**
  String get tutorialsTopicDatabaseSettings;

  /// No description provided for @tutorialsTopicGuide.
  ///
  /// In en, this message translates to:
  /// **'guided help'**
  String get tutorialsTopicGuide;

  /// No description provided for @anatomyLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise focus library'**
  String get anatomyLibraryTitle;

  /// No description provided for @anatomyBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts'**
  String get anatomyBodyParts;

  /// No description provided for @anatomyMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get anatomyMuscles;

  /// No description provided for @anatomyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load anatomy filters.'**
  String get anatomyLoadFailed;

  /// No description provided for @anatomySearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search bodyparts or muscles'**
  String get anatomySearchLabel;

  /// No description provided for @anatomyNoBodyParts.
  ///
  /// In en, this message translates to:
  /// **'No bodyparts match your search.'**
  String get anatomyNoBodyParts;

  /// No description provided for @anatomyNoMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscles match your search.'**
  String get anatomyNoMuscles;

  /// No description provided for @anatomyExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String anatomyExerciseCount(int count);

  /// No description provided for @anatomyTutorialSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search anatomy'**
  String get anatomyTutorialSearchTitle;

  /// No description provided for @anatomyTutorialSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search for a bodypart or a specific muscle when you want targeted exercise options.'**
  String get anatomyTutorialSearchBody;

  /// No description provided for @anatomyTutorialListsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts and muscles'**
  String get anatomyTutorialListsTitle;

  /// No description provided for @anatomyTutorialListsBody.
  ///
  /// In en, this message translates to:
  /// **'Switch tabs, then tap any row to see linked exercises, recent set totals, and recommended set boundaries.'**
  String get anatomyTutorialListsBody;

  /// No description provided for @anatomyTargetExercises.
  ///
  /// In en, this message translates to:
  /// **'{name} exercises'**
  String anatomyTargetExercises(String name);

  /// No description provided for @anatomyBodypartLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this bodypart.'**
  String get anatomyBodypartLoadFailed;

  /// No description provided for @anatomyMuscleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this muscle.'**
  String get anatomyMuscleLoadFailed;

  /// No description provided for @anatomyRecommendedSetsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recommended sets updated for {name}.'**
  String anatomyRecommendedSetsUpdated(String name);

  /// No description provided for @anatomySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save changes.'**
  String get anatomySaveFailed;

  /// No description provided for @anatomyLinkedExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 linked exercise} other{{count} linked exercises}}'**
  String anatomyLinkedExerciseCount(int count);

  /// No description provided for @anatomyDoneLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Done (7 days)'**
  String get anatomyDoneLastSevenDays;

  /// No description provided for @anatomySetsLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Sets last 7 days'**
  String get anatomySetsLastSevenDays;

  /// No description provided for @anatomySetUnits.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String anatomySetUnits(String count);

  /// No description provided for @anatomyRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get anatomyRecommended;

  /// No description provided for @anatomyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get anatomyNotSet;

  /// No description provided for @anatomySetRange.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} sets'**
  String anatomySetRange(String min, String max);

  /// No description provided for @anatomyAssociatedMuscles.
  ///
  /// In en, this message translates to:
  /// **'Associated muscles'**
  String get anatomyAssociatedMuscles;

  /// No description provided for @anatomyRelatedBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Related bodyparts'**
  String get anatomyRelatedBodyParts;

  /// No description provided for @anatomyNoMuscleLinks.
  ///
  /// In en, this message translates to:
  /// **'No muscle links have been added for this bodypart yet.'**
  String get anatomyNoMuscleLinks;

  /// No description provided for @anatomyNoBodyPartLinks.
  ///
  /// In en, this message translates to:
  /// **'No bodypart links have been added for this muscle yet.'**
  String get anatomyNoBodyPartLinks;

  /// No description provided for @anatomyExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get anatomyExercises;

  /// No description provided for @anatomyNoExercisesFor.
  ///
  /// In en, this message translates to:
  /// **'No exercises are currently linked to {name}.'**
  String anatomyNoExercisesFor(String name);

  /// No description provided for @anatomyNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment listed'**
  String get anatomyNoEquipment;

  /// No description provided for @anatomyNoMusclesListed.
  ///
  /// In en, this message translates to:
  /// **'No muscles listed'**
  String get anatomyNoMusclesListed;

  /// No description provided for @anatomyNoBodyPartsListed.
  ///
  /// In en, this message translates to:
  /// **'No bodyparts listed'**
  String get anatomyNoBodyPartsListed;

  /// No description provided for @anatomyOpenedFrom.
  ///
  /// In en, this message translates to:
  /// **'Opened from {name}'**
  String anatomyOpenedFrom(String name);

  /// No description provided for @anatomyRankForMuscle.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank} for this muscle - {bodyparts}'**
  String anatomyRankForMuscle(int rank, String bodyparts);

  /// No description provided for @anatomyTutorialDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Anatomy detail'**
  String get anatomyTutorialDetailTitle;

  /// No description provided for @anatomyTutorialBodypartDetailBody.
  ///
  /// In en, this message translates to:
  /// **'The header shows recent sets, recommended set boundaries, and related anatomy links.'**
  String get anatomyTutorialBodypartDetailBody;

  /// No description provided for @anatomyTutorialMuscleDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle detail'**
  String get anatomyTutorialMuscleDetailTitle;

  /// No description provided for @anatomyTutorialMuscleDetailBody.
  ///
  /// In en, this message translates to:
  /// **'The header shows recent sets, recommended set boundaries, and related bodyparts.'**
  String get anatomyTutorialMuscleDetailBody;

  /// No description provided for @anatomyTutorialLinkedExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked exercises'**
  String get anatomyTutorialLinkedExercisesTitle;

  /// No description provided for @anatomyTutorialBodypartExercisesBody.
  ///
  /// In en, this message translates to:
  /// **'These are exercises connected to this target. Tap one to open its full exercise details.'**
  String get anatomyTutorialBodypartExercisesBody;

  /// No description provided for @anatomyTutorialMuscleExercisesBody.
  ///
  /// In en, this message translates to:
  /// **'Exercises are ranked by how directly they train this muscle. Tap one for full details.'**
  String get anatomyTutorialMuscleExercisesBody;

  /// No description provided for @settingsWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Settings'**
  String get settingsWorkoutTitle;

  /// No description provided for @settingsWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune how the app understands anatomy, training bias, and volume targets.'**
  String get settingsWorkoutSubtitle;

  /// No description provided for @settingsTrainingBiasTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Bias'**
  String get settingsTrainingBiasTitle;

  /// No description provided for @settingsTrainingBiasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Controls used by generated plans and optimized workouts.'**
  String get settingsTrainingBiasSubtitle;

  /// No description provided for @settingsBodyPartRankings.
  ///
  /// In en, this message translates to:
  /// **'Body Part Rankings'**
  String get settingsBodyPartRankings;

  /// No description provided for @settingsBodyPartRankingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prioritize which body parts should receive more work.'**
  String get settingsBodyPartRankingsSubtitle;

  /// No description provided for @settingsMuscleRankings.
  ///
  /// In en, this message translates to:
  /// **'Muscle Rankings'**
  String get settingsMuscleRankings;

  /// No description provided for @settingsMuscleRankingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prioritize specific muscles inside the anatomy model.'**
  String get settingsMuscleRankingsSubtitle;

  /// No description provided for @settingsVolumeBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Volume Boundaries'**
  String get settingsVolumeBoundaries;

  /// No description provided for @settingsVolumeBoundariesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set recommended weekly ranges for body parts and muscles.'**
  String get settingsVolumeBoundariesSubtitle;

  /// No description provided for @settingsExerciseDefinitionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Definitions'**
  String get settingsExerciseDefinitionsTitle;

  /// No description provided for @settingsExerciseDefinitionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintain the anatomy and exercise data used by the app.'**
  String get settingsExerciseDefinitionsSubtitle;

  /// No description provided for @settingsAnatomyMapping.
  ///
  /// In en, this message translates to:
  /// **'Body Part / Muscle Mapping'**
  String get settingsAnatomyMapping;

  /// No description provided for @settingsAnatomyMappingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which muscles belong to each body part.'**
  String get settingsAnatomyMappingSubtitle;

  /// No description provided for @settingsExerciseSetAllocation.
  ///
  /// In en, this message translates to:
  /// **'Exercise Set Allocation'**
  String get settingsExerciseSetAllocation;

  /// No description provided for @settingsExerciseSetAllocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review how each exercise contributes to muscles and body parts.'**
  String get settingsExerciseSetAllocationSubtitle;

  /// No description provided for @settingsExerciseEditor.
  ///
  /// In en, this message translates to:
  /// **'Exercise Editor'**
  String get settingsExerciseEditor;

  /// No description provided for @settingsExerciseEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update exercise names, details, equipment, and mappings.'**
  String get settingsExerciseEditorSubtitle;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @databaseExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get databaseExportTitle;

  /// No description provided for @databaseImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get databaseImportTitle;

  /// No description provided for @databasePasteJson.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON here'**
  String get databasePasteJson;

  /// No description provided for @databaseCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get databaseCopied;

  /// No description provided for @databaseExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String databaseExportFailed(String error);

  /// No description provided for @databaseImportSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Import succeeded'**
  String get databaseImportSucceeded;

  /// No description provided for @databaseImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String databaseImportFailed(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @nutritionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet & Nutrition Settings'**
  String get nutritionSettingsTitle;

  /// No description provided for @nutritionSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure nutrition targets and food-related preferences.'**
  String get nutritionSettingsSubtitle;

  /// No description provided for @nutritionCurrentGoals.
  ///
  /// In en, this message translates to:
  /// **'Current Goals'**
  String get nutritionCurrentGoals;

  /// No description provided for @nutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get nutritionGoals;

  /// No description provided for @nutritionGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the targets used by nutrition tracking.'**
  String get nutritionGoalsSubtitle;

  /// No description provided for @nutritionManualGoals.
  ///
  /// In en, this message translates to:
  /// **'Manually Set Nutrition Goals'**
  String get nutritionManualGoals;

  /// No description provided for @nutritionManualGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter calories, macros, and key nutrients yourself.'**
  String get nutritionManualGoalsSubtitle;

  /// No description provided for @nutritionGoalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Goals saved'**
  String get nutritionGoalsSaved;

  /// No description provided for @nutritionGoalSummary.
  ///
  /// In en, this message translates to:
  /// **'Calories: {calories} / Protein: {protein} / Carbs: {carbs} / Fat: {fat} / Fiber: {fiber} / Sugar: {sugar} / Sat. Fat: {satFat} / Sodium: {sodium}'**
  String nutritionGoalSummary(
    String calories,
    String protein,
    String carbs,
    String fat,
    String fiber,
    String sugar,
    String satFat,
    String sodium,
  );

  /// No description provided for @progressSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Settings'**
  String get progressSettingsTitle;

  /// No description provided for @progressSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage body measurements and trend tracking setup.'**
  String get progressSettingsSubtitle;

  /// No description provided for @progressMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get progressMeasurements;

  /// No description provided for @progressMeasurementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure the body metrics you want to track over time.'**
  String get progressMeasurementsSubtitle;

  /// No description provided for @progressMeasurementLibrary.
  ///
  /// In en, this message translates to:
  /// **'Measurement Library'**
  String get progressMeasurementLibrary;

  /// No description provided for @progressMeasurementLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage weight, height, body measurements, and custom metrics.'**
  String get progressMeasurementLibrarySubtitle;

  /// No description provided for @nutritionManualGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Nutrition Goals'**
  String get nutritionManualGoalsTitle;

  /// No description provided for @nutritionManualGoalsPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set calorie, macro, and nutrient targets manually.'**
  String get nutritionManualGoalsPageSubtitle;

  /// No description provided for @nutritionSaveGoals.
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get nutritionSaveGoals;

  /// No description provided for @nutritionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get nutritionSaving;

  /// No description provided for @nutritionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get nutritionStartDate;

  /// No description provided for @nutritionGoalStarts.
  ///
  /// In en, this message translates to:
  /// **'Goal starts'**
  String get nutritionGoalStarts;

  /// No description provided for @nutritionCaloriesAndMacros.
  ///
  /// In en, this message translates to:
  /// **'Calories & Macros'**
  String get nutritionCaloriesAndMacros;

  /// No description provided for @nutritionAdditionalNutrients.
  ///
  /// In en, this message translates to:
  /// **'Additional Nutrients'**
  String get nutritionAdditionalNutrients;

  /// No description provided for @nutritionCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get nutritionCalories;

  /// No description provided for @nutritionProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get nutritionProtein;

  /// No description provided for @nutritionCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get nutritionCarbs;

  /// No description provided for @nutritionFat.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get nutritionFat;

  /// No description provided for @nutritionFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber (g)'**
  String get nutritionFiber;

  /// No description provided for @nutritionSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar (g)'**
  String get nutritionSugar;

  /// No description provided for @nutritionSatFat.
  ///
  /// In en, this message translates to:
  /// **'Sat. Fat (g)'**
  String get nutritionSatFat;

  /// No description provided for @nutritionSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium (mg)'**
  String get nutritionSodium;

  /// No description provided for @nutritionEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get nutritionEnterNumber;

  /// No description provided for @nutritionNumberAtLeastZero.
  ///
  /// In en, this message translates to:
  /// **'Must be >= 0'**
  String get nutritionNumberAtLeastZero;

  /// No description provided for @rankingsSaved.
  ///
  /// In en, this message translates to:
  /// **'{target} rankings saved'**
  String rankingsSaved(String target);

  /// No description provided for @rankingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Rankings'**
  String get rankingsSave;

  /// No description provided for @rankingsTitle.
  ///
  /// In en, this message translates to:
  /// **'{target} Rankings'**
  String rankingsTitle(String target);

  /// No description provided for @rankingsHero.
  ///
  /// In en, this message translates to:
  /// **'Drag {target} into the order you want generated training to prefer.'**
  String rankingsHero(String target);

  /// No description provided for @rankingsNoBodyParts.
  ///
  /// In en, this message translates to:
  /// **'No body parts defined'**
  String get rankingsNoBodyParts;

  /// No description provided for @rankingsNoMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscles defined'**
  String get rankingsNoMuscles;

  /// No description provided for @rankingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load {target}: {error}'**
  String rankingsLoadError(String target, String error);

  /// No description provided for @rankingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save: {error}'**
  String rankingsSaveError(String error);

  /// No description provided for @rankingsRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rankingsRank;

  /// No description provided for @mappingTitle.
  ///
  /// In en, this message translates to:
  /// **'Anatomy Mapping'**
  String get mappingTitle;

  /// No description provided for @mappingHero.
  ///
  /// In en, this message translates to:
  /// **'Connect muscles to body parts so heatmaps, analytics, and generated workouts agree.'**
  String get mappingHero;

  /// No description provided for @mappingSaved.
  ///
  /// In en, this message translates to:
  /// **'Mappings saved'**
  String get mappingSaved;

  /// No description provided for @mappingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save: {error}'**
  String mappingSaveFailed(String error);

  /// No description provided for @mappingSelectedBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Selected Body Part'**
  String get mappingSelectedBodyPart;

  /// No description provided for @mappingBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body part'**
  String get mappingBodyPart;

  /// No description provided for @mappingChooseLinkedMuscles.
  ///
  /// In en, this message translates to:
  /// **'Choose Linked Muscles'**
  String get mappingChooseLinkedMuscles;

  /// No description provided for @mappingLinkedMuscles.
  ///
  /// In en, this message translates to:
  /// **'Linked Muscles'**
  String get mappingLinkedMuscles;

  /// No description provided for @mappingChooseLinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select every muscle that belongs to this body part.'**
  String get mappingChooseLinkedSubtitle;

  /// No description provided for @mappingLinkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} muscles currently linked.'**
  String mappingLinkedCount(int count);

  /// No description provided for @mappingNoMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscles defined.'**
  String get mappingNoMuscles;

  /// No description provided for @mappingNoLinkedMuscles.
  ///
  /// In en, this message translates to:
  /// **'No muscles linked yet. Tap Edit to add some.'**
  String get mappingNoLinkedMuscles;

  /// No description provided for @volumeMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get volumeMaintenance;

  /// No description provided for @volumeMinEffective.
  ///
  /// In en, this message translates to:
  /// **'Min Effective'**
  String get volumeMinEffective;

  /// No description provided for @volumeMaxAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Max Adaptive'**
  String get volumeMaxAdaptive;

  /// No description provided for @volumeMaxRecoverable.
  ///
  /// In en, this message translates to:
  /// **'Max Recoverable'**
  String get volumeMaxRecoverable;

  /// No description provided for @volumeLoadBodyPartFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load body part boundaries: {error}'**
  String volumeLoadBodyPartFailed(String error);

  /// No description provided for @volumeLoadMuscleFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load muscle boundaries: {error}'**
  String volumeLoadMuscleFailed(String error);

  /// No description provided for @volumeBodyPartSaved.
  ///
  /// In en, this message translates to:
  /// **'Body part boundaries saved'**
  String get volumeBodyPartSaved;

  /// No description provided for @volumeMuscleSaved.
  ///
  /// In en, this message translates to:
  /// **'Muscle boundaries saved'**
  String get volumeMuscleSaved;

  /// No description provided for @volumeInvalidNumbers.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numbers'**
  String get volumeInvalidNumbers;

  /// No description provided for @volumeBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Body Parts'**
  String get volumeBodyParts;

  /// No description provided for @volumeMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get volumeMuscles;

  /// No description provided for @volumeBodyPartTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Part Volume'**
  String get volumeBodyPartTitle;

  /// No description provided for @volumeBodyPartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set weekly target ranges used by weekly analytics and workout generation.'**
  String get volumeBodyPartSubtitle;

  /// No description provided for @volumeMuscleTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle Volume'**
  String get volumeMuscleTitle;

  /// No description provided for @volumeMuscleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune weekly target ranges for individual muscles.'**
  String get volumeMuscleSubtitle;

  /// No description provided for @volumeSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get volumeSelection;

  /// No description provided for @volumeRecommendedRange.
  ///
  /// In en, this message translates to:
  /// **'Recommended Range'**
  String get volumeRecommendedRange;

  /// No description provided for @volumeRecommendedRangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Numbers are set units per week.'**
  String get volumeRecommendedRangeSubtitle;

  /// No description provided for @volumeSaveBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Save Boundaries'**
  String get volumeSaveBoundaries;

  /// No description provided for @nutritionDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Dashboard'**
  String get nutritionDashboardTitle;

  /// No description provided for @nutritionDashboardError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load nutrition: {error}'**
  String nutritionDashboardError(String error);

  /// No description provided for @nutritionMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Menu'**
  String get nutritionMenuTitle;

  /// No description provided for @nutritionLogFood.
  ///
  /// In en, this message translates to:
  /// **'Log Food'**
  String get nutritionLogFood;

  /// No description provided for @nutritionTrackMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Track Measurement'**
  String get nutritionTrackMeasurement;

  /// No description provided for @nutritionMeasuredItems.
  ///
  /// In en, this message translates to:
  /// **'Measured Items'**
  String get nutritionMeasuredItems;

  /// No description provided for @nutritionTodayRecords.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Records'**
  String get nutritionTodayRecords;

  /// No description provided for @nutritionGoalsMenu.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoalsMenu;

  /// No description provided for @measurementWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get measurementWeight;

  /// No description provided for @measurementHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get measurementHips;

  /// No description provided for @measurementShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get measurementShoulders;

  /// No description provided for @measurementCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get measurementCalves;

  /// No description provided for @measurementTrackNew.
  ///
  /// In en, this message translates to:
  /// **'Track a New Measurement'**
  String get measurementTrackNew;

  /// No description provided for @barcodeScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get barcodeScannerTitle;

  /// No description provided for @barcodeSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get barcodeSwitchCamera;

  /// No description provided for @barcodeTorchOn.
  ///
  /// In en, this message translates to:
  /// **'Torch on'**
  String get barcodeTorchOn;

  /// No description provided for @barcodeTorchOff.
  ///
  /// In en, this message translates to:
  /// **'Torch off'**
  String get barcodeTorchOff;

  /// No description provided for @barcodeTorchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Torch is not available on this device'**
  String get barcodeTorchUnavailable;

  /// No description provided for @barcodeAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Align the barcode within the frame'**
  String get barcodeAlignHint;

  /// No description provided for @progressTutorialWorkoutReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout report'**
  String get progressTutorialWorkoutReportTitle;

  /// No description provided for @progressTutorialWorkoutReportBody.
  ///
  /// In en, this message translates to:
  /// **'This tracks workout count, training time, and volume over different time ranges. Tap a metric to change what the graph shows.'**
  String get progressTutorialWorkoutReportBody;

  /// No description provided for @progressTutorialExerciseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise progress'**
  String get progressTutorialExerciseProgressTitle;

  /// No description provided for @progressTutorialExerciseProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Track strength trends for selected exercises. Use the edit tile to add or remove exercises from this dashboard.'**
  String get progressTutorialExerciseProgressBody;

  /// No description provided for @progressTutorialHealthTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health trends'**
  String get progressTutorialHealthTrendsTitle;

  /// No description provided for @progressTutorialHealthTrendsBody.
  ///
  /// In en, this message translates to:
  /// **'Log bodyweight and custom measurements here, then watch those measurements change over time.'**
  String get progressTutorialHealthTrendsBody;

  /// No description provided for @measurementNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Measurement'**
  String get measurementNewTitle;

  /// No description provided for @measurementPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get measurementPresets;

  /// No description provided for @measurementCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get measurementCustom;

  /// No description provided for @measurementPresetType.
  ///
  /// In en, this message translates to:
  /// **'Preset Type'**
  String get measurementPresetType;

  /// No description provided for @measurementVariation.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get measurementVariation;

  /// No description provided for @measurementWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake-up'**
  String get measurementWakeUp;

  /// No description provided for @measurementBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get measurementBedtime;

  /// No description provided for @measurementOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get measurementOverall;

  /// No description provided for @measurementValueWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get measurementValueWeight;

  /// No description provided for @measurementUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get measurementUnits;

  /// No description provided for @measurementFeet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get measurementFeet;

  /// No description provided for @measurementInches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get measurementInches;

  /// No description provided for @measurementCentimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimeters'**
  String get measurementCentimeters;

  /// No description provided for @measurementWithPump.
  ///
  /// In en, this message translates to:
  /// **'With pump'**
  String get measurementWithPump;

  /// No description provided for @measurementWithoutPump.
  ///
  /// In en, this message translates to:
  /// **'Without pump'**
  String get measurementWithoutPump;

  /// No description provided for @measurementName.
  ///
  /// In en, this message translates to:
  /// **'Measurement name'**
  String get measurementName;

  /// No description provided for @measurementNameHint.
  ///
  /// In en, this message translates to:
  /// **'Chest size, resting heart rate...'**
  String get measurementNameHint;

  /// No description provided for @measurementValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get measurementValue;

  /// No description provided for @measurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get measurementUnit;

  /// No description provided for @measurementNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get measurementNote;

  /// No description provided for @measurementOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get measurementOptional;

  /// No description provided for @measurementSaveNew.
  ///
  /// In en, this message translates to:
  /// **'Save New Measurement'**
  String get measurementSaveNew;

  /// No description provided for @measurementCustomRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom name, value, and unit'**
  String get measurementCustomRequired;

  /// No description provided for @measurementDefinitionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Definition not found for {name}'**
  String measurementDefinitionNotFound(String name);

  /// No description provided for @measurementInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid numeric value'**
  String get measurementInvalidValue;

  /// No description provided for @measurementHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get measurementHeight;

  /// No description provided for @measurementForearm.
  ///
  /// In en, this message translates to:
  /// **'Forearm'**
  String get measurementForearm;

  /// No description provided for @measurementArm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get measurementArm;

  /// No description provided for @measurementNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get measurementNeck;

  /// No description provided for @measurementChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measurementChest;

  /// No description provided for @measurementWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measurementWaist;

  /// No description provided for @measurementThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get measurementThigh;

  /// No description provided for @measurementInstructionsForearm.
  ///
  /// In en, this message translates to:
  /// **'Measure around the widest part of your forearm.'**
  String get measurementInstructionsForearm;

  /// No description provided for @measurementInstructionsArm.
  ///
  /// In en, this message translates to:
  /// **'Measure around the widest part of your bicep.'**
  String get measurementInstructionsArm;

  /// No description provided for @measurementInstructionsNeck.
  ///
  /// In en, this message translates to:
  /// **'Measure where the tape sits straight around your neck.'**
  String get measurementInstructionsNeck;

  /// No description provided for @measurementInstructionsShoulder.
  ///
  /// In en, this message translates to:
  /// **'Keep the tape straight around the side deltoids.'**
  String get measurementInstructionsShoulder;

  /// No description provided for @measurementInstructionsChest.
  ///
  /// In en, this message translates to:
  /// **'Measure under the armpits and above the nipple line.'**
  String get measurementInstructionsChest;

  /// No description provided for @measurementInstructionsWaist.
  ///
  /// In en, this message translates to:
  /// **'Measure around your belly button.'**
  String get measurementInstructionsWaist;

  /// No description provided for @measurementInstructionsHip.
  ///
  /// In en, this message translates to:
  /// **'Measure around the widest part of your glutes.'**
  String get measurementInstructionsHip;

  /// No description provided for @measurementInstructionsThigh.
  ///
  /// In en, this message translates to:
  /// **'Measure around the widest part of your thigh.'**
  String get measurementInstructionsThigh;

  /// No description provided for @measurementInstructionsCalf.
  ///
  /// In en, this message translates to:
  /// **'Measure around the widest part of your calf.'**
  String get measurementInstructionsCalf;

  /// No description provided for @nutritionCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutritionCaloriesLabel;

  /// No description provided for @nutritionFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutritionFatLabel;

  /// No description provided for @nutritionProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutritionProteinLabel;

  /// No description provided for @nutritionCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutritionCarbsLabel;

  /// No description provided for @nutritionMacroSummary.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal | P {protein} g | C {carbs} g | F {fat} g'**
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat);

  /// No description provided for @nutritionEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get nutritionEditEntry;

  /// No description provided for @nutritionEditNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Editing entries is not available yet'**
  String get nutritionEditNotAvailable;

  /// No description provided for @nutritionEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get nutritionEntryDeleted;

  /// No description provided for @gymProfileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Gym Profile'**
  String get gymProfileEditTitle;

  /// No description provided for @gymProfileNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Gym Profile'**
  String get gymProfileNewTitle;

  /// No description provided for @gymProfileTutorialSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout space'**
  String get gymProfileTutorialSpaceTitle;

  /// No description provided for @gymProfileTutorialSpaceBody.
  ///
  /// In en, this message translates to:
  /// **'Name this profile for where you train, like Home Gym, Commercial Gym, or Travel Setup.'**
  String get gymProfileTutorialSpaceBody;

  /// No description provided for @gymProfileTutorialFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find equipment'**
  String get gymProfileTutorialFindTitle;

  /// No description provided for @gymProfileTutorialFindBody.
  ///
  /// In en, this message translates to:
  /// **'Use search when the equipment list gets long and you want to jump to one item quickly.'**
  String get gymProfileTutorialFindBody;

  /// No description provided for @gymProfileTutorialAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get gymProfileTutorialAvailableTitle;

  /// No description provided for @gymProfileTutorialAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Select what this workout space has. Generated plans and swaps use this to avoid unavailable exercises.'**
  String get gymProfileTutorialAvailableBody;

  /// No description provided for @gymProfileTutorialSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get gymProfileTutorialSaveTitle;

  /// No description provided for @gymProfileTutorialSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Save stores the profile and equipment. Cancel asks before discarding unsaved changes.'**
  String get gymProfileTutorialSaveBody;

  /// No description provided for @gymProfileSaveChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get gymProfileSaveChangesTitle;

  /// No description provided for @gymProfileSaveChangesBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved gym profile changes. Save them before leaving?'**
  String get gymProfileSaveChangesBody;

  /// No description provided for @gymProfileKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get gymProfileKeepEditing;

  /// No description provided for @gymProfileDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get gymProfileDiscard;

  /// No description provided for @gymProfileSelectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select at least one equipment item.'**
  String get gymProfileSelectEquipment;

  /// No description provided for @gymProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save profile: {error}'**
  String gymProfileSaveFailed(String error);

  /// No description provided for @gymProfileEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Pick what this gym has so generated plans only use available equipment.'**
  String get gymProfileEquipmentHint;

  /// No description provided for @gymProfileSpace.
  ///
  /// In en, this message translates to:
  /// **'Workout Space'**
  String get gymProfileSpace;

  /// No description provided for @gymProfileEquipmentSelected.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} equipment options selected'**
  String gymProfileEquipmentSelected(int selected, int total);

  /// No description provided for @gymProfileName.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get gymProfileName;

  /// No description provided for @gymProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Home gym, Commercial gym, Travel setup...'**
  String get gymProfileNameHint;

  /// No description provided for @gymProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get gymProfileNameRequired;

  /// No description provided for @gymProfileFilterEquipment.
  ///
  /// In en, this message translates to:
  /// **'Filter equipment by name'**
  String get gymProfileFilterEquipment;

  /// No description provided for @gymProfileEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get gymProfileEquipment;

  /// No description provided for @gymProfileSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get gymProfileSelectAll;

  /// No description provided for @gymProfileClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get gymProfileClear;

  /// No description provided for @gymProfileSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} selected'**
  String gymProfileSelectedCount(int selected, int total);

  /// No description provided for @gymProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get gymProfileSave;

  /// No description provided for @gymProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get gymProfileSaving;

  /// No description provided for @gymProfileNoEquipmentMatch.
  ///
  /// In en, this message translates to:
  /// **'No equipment matches \"{query}\".'**
  String gymProfileNoEquipmentMatch(String query);

  /// No description provided for @equipmentCategoryBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get equipmentCategoryBasics;

  /// No description provided for @equipmentCategoryFreeWeights.
  ///
  /// In en, this message translates to:
  /// **'Free Weights'**
  String get equipmentCategoryFreeWeights;

  /// No description provided for @equipmentCategoryBenchesRacks.
  ///
  /// In en, this message translates to:
  /// **'Benches & Racks'**
  String get equipmentCategoryBenchesRacks;

  /// No description provided for @equipmentCategoryCableAttachments.
  ///
  /// In en, this message translates to:
  /// **'Cable & Attachments'**
  String get equipmentCategoryCableAttachments;

  /// No description provided for @equipmentCategoryMachines.
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get equipmentCategoryMachines;

  /// No description provided for @equipmentCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other Equipment'**
  String get equipmentCategoryOther;

  /// No description provided for @equipmentNoRequirement.
  ///
  /// In en, this message translates to:
  /// **'No required equipment'**
  String get equipmentNoRequirement;

  /// No description provided for @equipmentBodyweightSupport.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight movement support'**
  String get equipmentBodyweightSupport;

  /// No description provided for @equipmentMachineBased.
  ///
  /// In en, this message translates to:
  /// **'Machine based movement'**
  String get equipmentMachineBased;

  /// No description provided for @equipmentCableAccessory.
  ///
  /// In en, this message translates to:
  /// **'Cable station accessory'**
  String get equipmentCableAccessory;

  /// No description provided for @equipmentBenchRackSetup.
  ///
  /// In en, this message translates to:
  /// **'Bench, rack, or station setup'**
  String get equipmentBenchRackSetup;

  /// No description provided for @equipmentFreeWeightTraining.
  ///
  /// In en, this message translates to:
  /// **'Free weight training'**
  String get equipmentFreeWeightTraining;

  /// No description provided for @equipmentAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get equipmentAvailable;

  /// No description provided for @foodLoggingTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Logging'**
  String get foodLoggingTitle;

  /// No description provided for @foodLogTime.
  ///
  /// In en, this message translates to:
  /// **'Log time:'**
  String get foodLogTime;

  /// No description provided for @foodPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion:'**
  String get foodPortion;

  /// No description provided for @foodQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty:'**
  String get foodQuantity;

  /// No description provided for @foodGramsPerUnit.
  ///
  /// In en, this message translates to:
  /// **'{grams} g / unit'**
  String foodGramsPerUnit(int grams);

  /// No description provided for @foodRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get foodRemove;

  /// No description provided for @foodAddAllToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add All to Diary'**
  String get foodAddAllToDiary;

  /// No description provided for @foodLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging...'**
  String get foodLogging;

  /// No description provided for @foodTabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get foodTabScan;

  /// No description provided for @foodTabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get foodTabSearch;

  /// No description provided for @foodTabPlanned.
  ///
  /// In en, this message translates to:
  /// **'Pre-Planned'**
  String get foodTabPlanned;

  /// No description provided for @foodTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get foodTabCustom;

  /// No description provided for @foodSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a food...'**
  String get foodSearchHint;

  /// No description provided for @foodNoRecentRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recent recipes yet.'**
  String get foodNoRecentRecipes;

  /// No description provided for @foodRecentRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recent recipe'**
  String get foodRecentRecipe;

  /// No description provided for @foodNoFoodsFound.
  ///
  /// In en, this message translates to:
  /// **'No foods found.'**
  String get foodNoFoodsFound;

  /// No description provided for @foodInstantLogAfterScan.
  ///
  /// In en, this message translates to:
  /// **'Instant log after scan'**
  String get foodInstantLogAfterScan;

  /// No description provided for @foodInstantLogAfterScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the scanned item immediately using the selected meal.'**
  String get foodInstantLogAfterScanSubtitle;

  /// No description provided for @foodOpenCameraScanner.
  ///
  /// In en, this message translates to:
  /// **'Open camera scanner'**
  String get foodOpenCameraScanner;

  /// No description provided for @foodEnterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode manually'**
  String get foodEnterBarcode;

  /// No description provided for @foodEnterBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 012345678905'**
  String get foodEnterBarcodeHint;

  /// No description provided for @foodLogByBarcode.
  ///
  /// In en, this message translates to:
  /// **'Log by barcode'**
  String get foodLogByBarcode;

  /// No description provided for @foodNoBarcode.
  ///
  /// In en, this message translates to:
  /// **'No valid barcode detected'**
  String get foodNoBarcode;

  /// No description provided for @foodBarcodeLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged item from barcode'**
  String get foodBarcodeLogged;

  /// No description provided for @foodFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String foodFailed(String error);

  /// No description provided for @foodCustomSavedBarcode.
  ///
  /// In en, this message translates to:
  /// **'Custom food saved and barcode linked'**
  String get foodCustomSavedBarcode;

  /// No description provided for @foodFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get foodFavorites;

  /// No description provided for @foodRecentFoods.
  ///
  /// In en, this message translates to:
  /// **'Recent foods'**
  String get foodRecentFoods;

  /// No description provided for @foodStartSearching.
  ///
  /// In en, this message translates to:
  /// **'Start searching to find foods.'**
  String get foodStartSearching;

  /// No description provided for @foodFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get foodFavorite;

  /// No description provided for @foodUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get foodUnfavorite;

  /// No description provided for @foodCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize food'**
  String get foodCustomize;

  /// No description provided for @foodEditAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Edit and add'**
  String get foodEditAndAdd;

  /// No description provided for @foodAddOne.
  ///
  /// In en, this message translates to:
  /// **'Add 1'**
  String get foodAddOne;

  /// No description provided for @foodAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Food Item'**
  String get foodAddNew;

  /// No description provided for @foodCustomSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom food saved'**
  String get foodCustomSaved;

  /// No description provided for @foodNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get foodNoteOptional;

  /// No description provided for @foodTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma-separated, e.g. post-workout, high-protein)'**
  String get foodTagsHint;

  /// No description provided for @foodAddToPlate.
  ///
  /// In en, this message translates to:
  /// **'Add to Plate'**
  String get foodAddToPlate;

  /// No description provided for @foodProfileNotReady.
  ///
  /// In en, this message translates to:
  /// **'Profile not ready yet.'**
  String get foodProfileNotReady;

  /// No description provided for @foodItemsLogged.
  ///
  /// In en, this message translates to:
  /// **'Items logged to diary'**
  String get foodItemsLogged;

  /// No description provided for @foodLogFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to log: {error}'**
  String foodLogFailed(String error);

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialSkipAll.
  ///
  /// In en, this message translates to:
  /// **'Skip All'**
  String get tutorialSkipAll;

  /// No description provided for @tutorialDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tutorialDone;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialSkipAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip all tutorials?'**
  String get tutorialSkipAllTitle;

  /// No description provided for @tutorialSkipAllBody.
  ///
  /// In en, this message translates to:
  /// **'This hides every guided tutorial. You can turn them back on anytime in Settings > Guided Tutorials by using Reset All Tutorials.'**
  String get tutorialSkipAllBody;

  /// No description provided for @tutorialKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep tutorials'**
  String get tutorialKeep;

  /// No description provided for @tutorialSkipEverything.
  ///
  /// In en, this message translates to:
  /// **'Skip all'**
  String get tutorialSkipEverything;

  /// No description provided for @flowSelectNode.
  ///
  /// In en, this message translates to:
  /// **'Select Node'**
  String get flowSelectNode;

  /// No description provided for @flowSelectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get flowSelectMethod;

  /// No description provided for @flowAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'+ Success'**
  String get flowAddSuccess;

  /// No description provided for @flowAddFailure.
  ///
  /// In en, this message translates to:
  /// **'+ Failure'**
  String get flowAddFailure;

  /// No description provided for @flowAddMethod.
  ///
  /// In en, this message translates to:
  /// **'+ Method'**
  String get flowAddMethod;

  /// No description provided for @flowRemoveMethod.
  ///
  /// In en, this message translates to:
  /// **'- Method'**
  String get flowRemoveMethod;

  /// No description provided for @flowNewEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get flowNewEvent;

  /// No description provided for @flowEventKey.
  ///
  /// In en, this message translates to:
  /// **'Event key'**
  String get flowEventKey;

  /// No description provided for @flowEventDisplayLabel.
  ///
  /// In en, this message translates to:
  /// **'Display label (optional)'**
  String get flowEventDisplayLabel;

  /// No description provided for @flowAddSuccessNode.
  ///
  /// In en, this message translates to:
  /// **'Add Success Node'**
  String get flowAddSuccessNode;

  /// No description provided for @flowAddFailureNode.
  ///
  /// In en, this message translates to:
  /// **'Add Failure Node'**
  String get flowAddFailureNode;

  /// No description provided for @flowAddEvent.
  ///
  /// In en, this message translates to:
  /// **'+ Event'**
  String get flowAddEvent;

  /// No description provided for @flowSelectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select Event'**
  String get flowSelectEvent;

  /// No description provided for @flowRemoveEvent.
  ///
  /// In en, this message translates to:
  /// **'Remove Event'**
  String get flowRemoveEvent;

  /// No description provided for @drawerNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get drawerNavigation;

  /// No description provided for @drawerOptionA.
  ///
  /// In en, this message translates to:
  /// **'Option A'**
  String get drawerOptionA;

  /// No description provided for @drawerOptionB.
  ///
  /// In en, this message translates to:
  /// **'Option B'**
  String get drawerOptionB;

  /// No description provided for @drawerOptionC.
  ///
  /// In en, this message translates to:
  /// **'Option C'**
  String get drawerOptionC;

  /// No description provided for @drawerGymProfiles.
  ///
  /// In en, this message translates to:
  /// **'Gym Profiles'**
  String get drawerGymProfiles;

  /// No description provided for @drawerSavedSpaces.
  ///
  /// In en, this message translates to:
  /// **'{count} saved spaces'**
  String drawerSavedSpaces(int count);

  /// No description provided for @drawerProfileActive.
  ///
  /// In en, this message translates to:
  /// **'{name} is active'**
  String drawerProfileActive(String name);

  /// No description provided for @drawerActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Active profile'**
  String get drawerActiveProfile;

  /// No description provided for @drawerTapToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch'**
  String get drawerTapToSwitch;

  /// No description provided for @drawerNewProfile.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get drawerNewProfile;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @automaticSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get automaticSaving;

  /// No description provided for @automaticValuesTab.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get automaticValuesTab;

  /// No description provided for @automaticMethodsTab.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get automaticMethodsTab;

  /// No description provided for @automaticGlobalIncrement.
  ///
  /// In en, this message translates to:
  /// **'Global Increment Amount'**
  String get automaticGlobalIncrement;

  /// No description provided for @automaticAutoSelect.
  ///
  /// In en, this message translates to:
  /// **'Auto Select'**
  String get automaticAutoSelect;

  /// No description provided for @automaticManualSelect.
  ///
  /// In en, this message translates to:
  /// **'Manual Select'**
  String get automaticManualSelect;

  /// No description provided for @automaticSkipFirstSet.
  ///
  /// In en, this message translates to:
  /// **'Skip First Set?'**
  String get automaticSkipFirstSet;

  /// No description provided for @automaticSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {number}: {weight} x {reps}'**
  String automaticSetLabel(int number, String weight, int reps);

  /// No description provided for @automaticChildSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {parent}.{child}: {weight} x {reps}'**
  String automaticChildSetLabel(int parent, int child, String weight, int reps);

  /// No description provided for @automaticSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings: {error}'**
  String automaticSaveFailed(String error);

  /// No description provided for @automaticIncrementWhen.
  ///
  /// In en, this message translates to:
  /// **'Increment when (decrement otherwise):'**
  String get automaticIncrementWhen;

  /// No description provided for @automaticWeightTarget.
  ///
  /// In en, this message translates to:
  /// **'Completed weight >= target weight'**
  String get automaticWeightTarget;

  /// No description provided for @automaticRepsTarget.
  ///
  /// In en, this message translates to:
  /// **'Completed reps >= target reps'**
  String get automaticRepsTarget;

  /// No description provided for @automaticVolumeTarget.
  ///
  /// In en, this message translates to:
  /// **'Completed volume >= target volume'**
  String get automaticVolumeTarget;

  /// No description provided for @automaticScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Successes, misses, and adjustments are counted by:'**
  String get automaticScopeLabel;

  /// No description provided for @automaticWorkoutSession.
  ///
  /// In en, this message translates to:
  /// **'Workout session'**
  String get automaticWorkoutSession;

  /// No description provided for @automaticPerExercise.
  ///
  /// In en, this message translates to:
  /// **'Per exercise'**
  String get automaticPerExercise;

  /// No description provided for @automaticPerSet.
  ///
  /// In en, this message translates to:
  /// **'Per set'**
  String get automaticPerSet;

  /// No description provided for @automaticAdjustScope.
  ///
  /// In en, this message translates to:
  /// **'Adjust:'**
  String get automaticAdjustScope;

  /// No description provided for @automaticAdjustOneSet.
  ///
  /// In en, this message translates to:
  /// **'1 set'**
  String get automaticAdjustOneSet;

  /// No description provided for @automaticAdjustAllSets.
  ///
  /// In en, this message translates to:
  /// **'All sets'**
  String get automaticAdjustAllSets;

  /// No description provided for @weightExpandSets.
  ///
  /// In en, this message translates to:
  /// **'Expand sets'**
  String get weightExpandSets;

  /// No description provided for @weightCollapseSets.
  ///
  /// In en, this message translates to:
  /// **'Collapse sets'**
  String get weightCollapseSets;

  /// No description provided for @weightDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get weightDetails;

  /// No description provided for @weightRemoveExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Exercise'**
  String get weightRemoveExerciseTitle;

  /// No description provided for @weightRemoveExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this exercise?'**
  String get weightRemoveExerciseBody;

  /// No description provided for @weightSwapExercise.
  ///
  /// In en, this message translates to:
  /// **'Swap Exercise'**
  String get weightSwapExercise;

  /// No description provided for @weightMakeChangeSet.
  ///
  /// In en, this message translates to:
  /// **'Make ChangeSet'**
  String get weightMakeChangeSet;

  /// No description provided for @weightSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String weightSetLabel(int number);

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight ({unit})'**
  String weightLabel(String unit);

  /// No description provided for @weightReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get weightReps;

  /// No description provided for @weightRemoveSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Set'**
  String get weightRemoveSetTitle;

  /// No description provided for @weightRemoveSetBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this set?'**
  String get weightRemoveSetBody;

  /// No description provided for @weightChangeSetLabel.
  ///
  /// In en, this message translates to:
  /// **'CSet {number}'**
  String weightChangeSetLabel(int number);

  /// No description provided for @weightShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Wt ({unit})'**
  String weightShortLabel(String unit);

  /// No description provided for @weightRemoveChangeSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove CSet'**
  String get weightRemoveChangeSetTitle;

  /// No description provided for @weightRemoveChangeSetBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this CSet?'**
  String get weightRemoveChangeSetBody;

  /// No description provided for @weightAddChangeSet.
  ///
  /// In en, this message translates to:
  /// **'Add CSet'**
  String get weightAddChangeSet;

  /// No description provided for @weightAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get weightAddSet;

  /// No description provided for @swapAlreadySelected.
  ///
  /// In en, this message translates to:
  /// **'That exercise is already selected.'**
  String get swapAlreadySelected;

  /// No description provided for @swapNeedsProfileEquipment.
  ///
  /// In en, this message translates to:
  /// **'That exercise needs equipment outside this profile.'**
  String get swapNeedsProfileEquipment;

  /// No description provided for @swapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load that replacement exercise.'**
  String swapLoadFailed(Object error);

  /// No description provided for @swapCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get swapCurrent;

  /// No description provided for @swapReplacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get swapReplacement;

  /// No description provided for @swapConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Swap'**
  String get swapConfirm;

  /// No description provided for @swapNoBodypartData.
  ///
  /// In en, this message translates to:
  /// **'No bodypart data found.'**
  String get swapNoBodypartData;

  /// No description provided for @swapLoadingSelected.
  ///
  /// In en, this message translates to:
  /// **'Loading selected exercise...'**
  String get swapLoadingSelected;

  /// No description provided for @swapBrowseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Browse Exercise Catalog'**
  String get swapBrowseCatalog;

  /// No description provided for @swapNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment listed'**
  String get swapNoEquipment;

  /// No description provided for @swapTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap Exercise'**
  String get swapTitle;

  /// No description provided for @swapFindingMatches.
  ///
  /// In en, this message translates to:
  /// **'Finding similar bodypart and muscle matches...'**
  String get swapFindingMatches;

  /// No description provided for @swapChooseReplacement.
  ///
  /// In en, this message translates to:
  /// **'Choose a similar replacement.'**
  String get swapChooseReplacement;

  /// No description provided for @swapFilterProfileEquipment.
  ///
  /// In en, this message translates to:
  /// **'Filter for profile equipment'**
  String get swapFilterProfileEquipment;

  /// No description provided for @swapBodypartsHit.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts Hit'**
  String get swapBodypartsHit;

  /// No description provided for @swapMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String swapMatch(int percent);

  /// No description provided for @swapNoReplacements.
  ///
  /// In en, this message translates to:
  /// **'No similar replacements found yet.'**
  String get swapNoReplacements;

  /// No description provided for @swapNoReplacementsBody.
  ///
  /// In en, this message translates to:
  /// **'This exercise may need more muscle or bodypart metadata before it can be swapped well.'**
  String get swapNoReplacementsBody;

  /// No description provided for @premadePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Premade Plans'**
  String get premadePlansTitle;

  /// No description provided for @premadeTutorialLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan length'**
  String get premadeTutorialLengthTitle;

  /// No description provided for @premadeTutorialLengthBody.
  ///
  /// In en, this message translates to:
  /// **'Switch between 1-hour and 2-hour versions. Longer versions include more exercises and total sets.'**
  String get premadeTutorialLengthBody;

  /// No description provided for @premadeTutorialEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile equipment'**
  String get premadeTutorialEquipmentTitle;

  /// No description provided for @premadeTutorialEquipmentBody.
  ///
  /// In en, this message translates to:
  /// **'When this is on, Tonos swaps unavailable exercises for similar options your current gym profile can perform.'**
  String get premadeTutorialEquipmentBody;

  /// No description provided for @premadeTutorialLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan library'**
  String get premadeTutorialLibraryTitle;

  /// No description provided for @premadeTutorialLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Open a split, preview a plan, then add it to your Active Plans so it appears on Train.'**
  String get premadeTutorialLibraryBody;

  /// No description provided for @premadeSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Please select a gym profile first.'**
  String get premadeSelectProfile;

  /// No description provided for @premadePlanAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to Active Plans.'**
  String premadePlanAdded(String name);

  /// No description provided for @premadePlanAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add {name}: {error}'**
  String premadePlanAddFailed(String name, String error);

  /// No description provided for @premadeDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy coach, influencer, and app-curated routines into your own plans. Once added, you can edit them like any other plan.'**
  String get premadeDescription;

  /// No description provided for @premadeDiscarding.
  ///
  /// In en, this message translates to:
  /// **'Discarding...'**
  String get premadeDiscarding;

  /// No description provided for @premadeReviewPlans.
  ///
  /// In en, this message translates to:
  /// **'Review Plans'**
  String get premadeReviewPlans;

  /// No description provided for @allocationSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get allocationSaveChanges;

  /// No description provided for @allocationSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get allocationSaving;

  /// No description provided for @allocationInvalidCredit.
  ///
  /// In en, this message translates to:
  /// **'Enter a zero or positive number for every credit.'**
  String get allocationInvalidCredit;

  /// No description provided for @allocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Exercise allocation saved.'**
  String get allocationSaved;

  /// No description provided for @allocationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the exercise allocation. Try again.'**
  String get allocationSaveFailed;

  /// No description provided for @allocationSaveOrDiscard.
  ///
  /// In en, this message translates to:
  /// **'Save or discard your edits before resetting.'**
  String get allocationSaveOrDiscard;

  /// No description provided for @allocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Set Allocation'**
  String get allocationTitle;

  /// No description provided for @allocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review how completed sets contribute to target muscles and body parts.'**
  String get allocationSubtitle;

  /// No description provided for @allocationHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How set credit works'**
  String get allocationHowTitle;

  /// No description provided for @allocationHowBody.
  ///
  /// In en, this message translates to:
  /// **'A primary muscle usually receives 1.00 credit for one completed set. Supporting muscles receive less credit. This guides anatomy summaries and recommendations, but never changes the sets you log.'**
  String get allocationHowBody;

  /// No description provided for @allocationLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load exercises. {error}'**
  String allocationLoadFailed(String error);

  /// No description provided for @allocationNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises are available yet.'**
  String get allocationNoExercises;

  /// No description provided for @allocationSelectedExercise.
  ///
  /// In en, this message translates to:
  /// **'Selected exercise'**
  String get allocationSelectedExercise;

  /// No description provided for @allocationMuscleCredit.
  ///
  /// In en, this message translates to:
  /// **'Muscle credit'**
  String get allocationMuscleCredit;

  /// No description provided for @allocationBodypartCredit.
  ///
  /// In en, this message translates to:
  /// **'Body-part credit'**
  String get allocationBodypartCredit;

  /// No description provided for @allocationNoTargetMuscles.
  ///
  /// In en, this message translates to:
  /// **'No target muscles'**
  String get allocationNoTargetMuscles;

  /// No description provided for @allocationNoBodypartMapping.
  ///
  /// In en, this message translates to:
  /// **'No body-part mapping'**
  String get allocationNoBodypartMapping;

  /// No description provided for @allocationReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get allocationReset;

  /// No description provided for @allocationCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get allocationCredit;

  /// No description provided for @allocationNoTargetMusclesBody.
  ///
  /// In en, this message translates to:
  /// **'This exercise does not have target-muscle data yet.'**
  String get allocationNoTargetMusclesBody;

  /// No description provided for @allocationMuscleCreditBody.
  ///
  /// In en, this message translates to:
  /// **'Change a value to create a personal allocation. It is used for muscle summaries and derived body-part focus.'**
  String get allocationMuscleCreditBody;

  /// No description provided for @allocationNoBodypartMappingBody.
  ///
  /// In en, this message translates to:
  /// **'This exercise does not have body-part mapping data yet.'**
  String get allocationNoBodypartMappingBody;

  /// No description provided for @allocationBodypartCreditBody.
  ///
  /// In en, this message translates to:
  /// **'Automatic values are derived from muscles and anatomy mapping. Editing one creates a direct personal body-part allocation.'**
  String get allocationBodypartCreditBody;

  /// No description provided for @healthTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Trends'**
  String get healthTrendsTitle;

  /// No description provided for @healthMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get healthMetric;

  /// No description provided for @healthUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load measurements'**
  String get healthUnableToLoad;

  /// No description provided for @healthNoMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get healthNoMeasurements;

  /// No description provided for @healthNoMeasurementsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a metric to start tracking progress.'**
  String get healthNoMeasurementsBody;

  /// No description provided for @healthCreateMetric.
  ///
  /// In en, this message translates to:
  /// **'Create metric'**
  String get healthCreateMetric;

  /// No description provided for @healthLogMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Log {name}'**
  String healthLogMeasurement(String name);

  /// No description provided for @healthEditMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String healthEditMeasurement(String name);

  /// No description provided for @healthTutorialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement summary'**
  String get healthTutorialSummaryTitle;

  /// No description provided for @healthTutorialSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'See the latest value, change from the previous entry, and how many records exist.'**
  String get healthTutorialSummaryBody;

  /// No description provided for @healthTutorialChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend chart'**
  String get healthTutorialChartTitle;

  /// No description provided for @healthTutorialChartBody.
  ///
  /// In en, this message translates to:
  /// **'The chart shows how this measurement changes over time as you log more entries.'**
  String get healthTutorialChartBody;

  /// No description provided for @healthTutorialEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get healthTutorialEntriesTitle;

  /// No description provided for @healthTutorialEntriesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an entry to edit it, or remove entries that were logged by mistake.'**
  String get healthTutorialEntriesBody;

  /// No description provided for @healthTutorialLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log new entry'**
  String get healthTutorialLogTitle;

  /// No description provided for @healthTutorialLogBody.
  ///
  /// In en, this message translates to:
  /// **'Use this button whenever you want to add a new measurement record.'**
  String get healthTutorialLogBody;

  /// No description provided for @healthDeleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get healthDeleteEntryTitle;

  /// No description provided for @healthDeleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'{value} from {date} will be removed.'**
  String healthDeleteEntryBody(String value, String date);

  /// No description provided for @healthLogEntry.
  ///
  /// In en, this message translates to:
  /// **'Log entry'**
  String get healthLogEntry;

  /// No description provided for @healthLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load: {error}'**
  String healthLoadFailed(String error);

  /// No description provided for @healthEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get healthEntries;

  /// No description provided for @healthNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get healthNoEntries;

  /// No description provided for @healthFirstEntry.
  ///
  /// In en, this message translates to:
  /// **'Log your first {name} measurement.'**
  String healthFirstEntry(String name);

  /// No description provided for @workoutReportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load workout report.'**
  String get workoutReportLoadFailed;

  /// No description provided for @workoutReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Report'**
  String get workoutReportTitle;

  /// No description provided for @workoutReportAdditionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get workoutReportAdditionalDetails;

  /// No description provided for @recommendedSetsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit recommended sets'**
  String get recommendedSetsEdit;

  /// No description provided for @recommendedSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended sets'**
  String get recommendedSetsTitle;

  /// No description provided for @recommendedSetsMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum recommended sets'**
  String get recommendedSetsMinimum;

  /// No description provided for @recommendedSetsMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum recommended sets'**
  String get recommendedSetsMaximum;

  /// No description provided for @recommendedSetsValidNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter valid set numbers.'**
  String get recommendedSetsValidNumbers;

  /// No description provided for @recommendedSetsNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Set numbers cannot be negative.'**
  String get recommendedSetsNonNegative;

  /// No description provided for @recommendedSetsRange.
  ///
  /// In en, this message translates to:
  /// **'Maximum must be at least the minimum.'**
  String get recommendedSetsRange;

  /// No description provided for @workoutReportWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutReportWorkouts;

  /// No description provided for @workoutReportTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get workoutReportTime;

  /// No description provided for @workoutReportVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get workoutReportVolume;

  /// No description provided for @workoutReportWorkout.
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get workoutReportWorkout;

  /// No description provided for @workoutReportTotal.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get workoutReportTotal;

  /// No description provided for @databaseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Database Settings'**
  String get databaseSettingsTitle;

  /// No description provided for @databaseSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backups, cloud media, health checks, and developer exports.'**
  String get databaseSettingsSubtitle;

  /// No description provided for @databaseBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get databaseBackupRestore;

  /// No description provided for @databaseBackupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move your local Tonos data in or out safely.'**
  String get databaseBackupRestoreSubtitle;

  /// No description provided for @databaseExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Database Backup'**
  String get databaseExportBackup;

  /// No description provided for @databaseImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Database Backup'**
  String get databaseImportBackup;

  /// No description provided for @databaseImportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local data from a saved export file.'**
  String get databaseImportBackupSubtitle;

  /// No description provided for @databaseHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get databaseHealth;

  /// No description provided for @databaseHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick read on database size, schema, and search index state.'**
  String get databaseHealthSubtitle;

  /// No description provided for @databaseCheckingHealth.
  ///
  /// In en, this message translates to:
  /// **'Checking database health...'**
  String get databaseCheckingHealth;

  /// No description provided for @databaseCheckingHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reading schema, size, tables, and indexes.'**
  String get databaseCheckingHealthSubtitle;

  /// No description provided for @databaseHealthFailed.
  ///
  /// In en, this message translates to:
  /// **'Database health check failed'**
  String get databaseHealthFailed;

  /// No description provided for @databaseMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get databaseMaintenance;

  /// No description provided for @databaseMaintenanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe tools for checks, optimization, and storage cleanup.'**
  String get databaseMaintenanceSubtitle;

  /// No description provided for @databaseRefreshHealth.
  ///
  /// In en, this message translates to:
  /// **'Refresh Health'**
  String get databaseRefreshHealth;

  /// No description provided for @databaseIntegrityCheck.
  ///
  /// In en, this message translates to:
  /// **'Run Integrity Check'**
  String get databaseIntegrityCheck;

  /// No description provided for @databaseIntegrityCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask SQLite to verify the local database file.'**
  String get databaseIntegrityCheckSubtitle;

  /// No description provided for @databaseOptimize.
  ///
  /// In en, this message translates to:
  /// **'Optimize Database'**
  String get databaseOptimize;

  /// No description provided for @databaseCheckpointWal.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint WAL'**
  String get databaseCheckpointWal;

  /// No description provided for @databaseCheckpointWalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flushes the write-ahead log into the database file.'**
  String get databaseCheckpointWalSubtitle;

  /// No description provided for @databaseVacuum.
  ///
  /// In en, this message translates to:
  /// **'Vacuum Database'**
  String get databaseVacuum;

  /// No description provided for @databaseVacuumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reclaims free space after large deletes/imports.'**
  String get databaseVacuumSubtitle;

  /// No description provided for @databaseCloudContent.
  ///
  /// In en, this message translates to:
  /// **'Cloud Content'**
  String get databaseCloudContent;

  /// No description provided for @databaseCloudContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage exercise, equipment, and anatomy media storage.'**
  String get databaseCloudContentSubtitle;

  /// No description provided for @databaseWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Only Downloads'**
  String get databaseWifiOnly;

  /// No description provided for @databaseWifiOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'New thumbnails and videos download only on Wi-Fi. Cached media still works offline.'**
  String get databaseWifiOnlySubtitle;

  /// No description provided for @databaseSyncExerciseMedia.
  ///
  /// In en, this message translates to:
  /// **'Sync Remote Exercise Media'**
  String get databaseSyncExerciseMedia;

  /// No description provided for @databaseSyncSharedMedia.
  ///
  /// In en, this message translates to:
  /// **'Sync Shared Catalog Media'**
  String get databaseSyncSharedMedia;

  /// No description provided for @databaseSyncSharedMediaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment, bodypart, and muscle illustrations.'**
  String get databaseSyncSharedMediaSubtitle;

  /// No description provided for @databaseClearMediaCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Downloaded Media Cache'**
  String get databaseClearMediaCache;

  /// No description provided for @databaseClearMediaCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes cached remote media files from this device.'**
  String get databaseClearMediaCacheSubtitle;

  /// No description provided for @databaseDefinitionExports.
  ///
  /// In en, this message translates to:
  /// **'Definition Exports'**
  String get databaseDefinitionExports;

  /// No description provided for @databaseDefinitionExportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export app definition files for inspection or tooling.'**
  String get databaseDefinitionExportsSubtitle;

  /// No description provided for @exerciseEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Editor'**
  String get exerciseEditorTitle;

  /// No description provided for @exerciseEditorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Exercise definitions could not load.'**
  String get exerciseEditorLoadFailed;

  /// No description provided for @exerciseEditorChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose exercise'**
  String get exerciseEditorChoose;

  /// No description provided for @exerciseEditorEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit definition'**
  String get exerciseEditorEdit;

  /// No description provided for @exerciseEditorCreate.
  ///
  /// In en, this message translates to:
  /// **'Create custom exercise'**
  String get exerciseEditorCreate;

  /// No description provided for @exerciseEditorSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get exerciseEditorSaveChanges;

  /// No description provided for @exerciseEditorSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get exerciseEditorSaving;

  /// No description provided for @exerciseEditorMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get exerciseEditorMuscles;

  /// No description provided for @exerciseEditorBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts'**
  String get exerciseEditorBodyparts;

  /// No description provided for @exerciseEditorEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseEditorEquipment;

  /// No description provided for @exerciseEditorGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get exerciseEditorGuide;

  /// No description provided for @exerciseProgressAlreadyShown.
  ///
  /// In en, this message translates to:
  /// **'{name} is already shown.'**
  String exerciseProgressAlreadyShown(String name);

  /// No description provided for @exerciseProgressTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'1RM trend'**
  String get exerciseProgressTrendTitle;

  /// No description provided for @exerciseProgressTrendBody.
  ///
  /// In en, this message translates to:
  /// **'This chart compares actual recorded 1RM and estimated 1RM over time. Tap points for exact values.'**
  String get exerciseProgressTrendBody;

  /// No description provided for @exerciseProgressRecordings.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get exerciseProgressRecordings;

  /// No description provided for @exerciseProgressRecordingsBody.
  ///
  /// In en, this message translates to:
  /// **'Each recording opens the workout where that lift happened, so you can review the full context.'**
  String get exerciseProgressRecordingsBody;

  /// No description provided for @exerciseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'1RM Progress'**
  String get exerciseProgressTitle;

  /// No description provided for @exerciseProgressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete this exercise to start building progress history.'**
  String get exerciseProgressEmpty;

  /// No description provided for @exerciseProgressActual.
  ///
  /// In en, this message translates to:
  /// **'Actual 1RM'**
  String get exerciseProgressActual;

  /// No description provided for @exerciseProgressEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get exerciseProgressEstimated;

  /// No description provided for @exerciseProgressSessionOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Workout session could not be opened.'**
  String get exerciseProgressSessionOpenFailed;

  /// No description provided for @exerciseProgressSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Workout session could not be found.'**
  String get exerciseProgressSessionMissing;

  /// No description provided for @exerciseProgressEstimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Est. {value}'**
  String exerciseProgressEstimatedValue(String value);

  /// No description provided for @exerciseProgressNoActual.
  ///
  /// In en, this message translates to:
  /// **'No actual 1RM'**
  String get exerciseProgressNoActual;

  /// No description provided for @exerciseProgressActualValue.
  ///
  /// In en, this message translates to:
  /// **'Actual {value}'**
  String exerciseProgressActualValue(String value);

  /// No description provided for @musclePercentTitle.
  ///
  /// In en, this message translates to:
  /// **'% Hit per Muscle'**
  String get musclePercentTitle;

  /// No description provided for @musclePercentLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load entries: {error}'**
  String musclePercentLoadFailed(String error);

  /// No description provided for @musclePercentUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update percent: {error}'**
  String musclePercentUpdateFailed(String error);

  /// No description provided for @musclePercentResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset to default: {error}'**
  String musclePercentResetFailed(String error);

  /// No description provided for @musclePercentError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String musclePercentError(String error);

  /// No description provided for @musclePercentNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises defined'**
  String get musclePercentNoExercises;

  /// No description provided for @musclePercentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No muscle percentages set'**
  String get musclePercentEmpty;

  /// No description provided for @musclePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get musclePercentLabel;

  /// No description provided for @musclePercentRevert.
  ///
  /// In en, this message translates to:
  /// **'Revert to default'**
  String get musclePercentRevert;

  /// No description provided for @sevenDayFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get sevenDayFocusTitle;

  /// No description provided for @sevenDayFocusLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load 7-day focus'**
  String get sevenDayFocusLoadFailed;

  /// No description provided for @sevenDayFocusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed bodypart set units in the last 7 days.'**
  String get sevenDayFocusEmpty;

  /// No description provided for @sevenDayFocusMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get sevenDayFocusMore;

  /// No description provided for @pastSessionsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get pastSessionsWeek;

  /// No description provided for @pastSessionsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get pastSessionsMonth;

  /// No description provided for @pastSessionsYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get pastSessionsYear;

  /// No description provided for @pastSessionsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pastSessionsAll;

  /// No description provided for @pastSessionsShow.
  ///
  /// In en, this message translates to:
  /// **'Show:'**
  String get pastSessionsShow;

  /// No description provided for @pastSessionsFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get pastSessionsFullscreen;

  /// No description provided for @pastSessionsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String pastSessionsError(String error);

  /// No description provided for @pastSessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.'**
  String get pastSessionsEmpty;

  /// No description provided for @pastSessionsItem.
  ///
  /// In en, this message translates to:
  /// **'{date} - {duration}'**
  String pastSessionsItem(String date, String duration);

  /// No description provided for @historySummaryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get historySummaryLoadFailed;

  /// No description provided for @historySummaryWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get historySummaryWorkouts;

  /// No description provided for @historySummaryTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get historySummaryTotalTime;

  /// No description provided for @historySummaryTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get historySummaryTotalVolume;

  /// No description provided for @planCoachSkipGuide.
  ///
  /// In en, this message translates to:
  /// **'Skip guide'**
  String get planCoachSkipGuide;

  /// No description provided for @planCoachContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get planCoachContinue;

  /// No description provided for @trainOptimizedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimized workout settings'**
  String get trainOptimizedSettingsTitle;

  /// No description provided for @trainOptimizedSettingsBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Used to budget 3 minutes per set plus 5 minutes to start each exercise.'**
  String get trainOptimizedSettingsBudgetBody;

  /// No description provided for @trainOptimizedSettingsFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Bodypart picks apply only to the next optimized workout you start.'**
  String get trainOptimizedSettingsFocusBody;

  /// No description provided for @trainWorkoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Workout duration'**
  String get trainWorkoutDuration;

  /// No description provided for @trainMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get trainMinutesShort;

  /// No description provided for @trainSetsPerExercise.
  ///
  /// In en, this message translates to:
  /// **'Up to sets per exercise'**
  String get trainSetsPerExercise;

  /// No description provided for @trainSetsShort.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get trainSetsShort;

  /// No description provided for @trainBodypartFocus.
  ///
  /// In en, this message translates to:
  /// **'Bodypart focus'**
  String get trainBodypartFocus;

  /// No description provided for @trainBodypartFocusHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap once to prefer a bodypart, tap again to avoid it, and tap a third time to clear it.'**
  String get trainBodypartFocusHelp;

  /// No description provided for @trainBodypartsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts could not be loaded.'**
  String get trainBodypartsLoadFailed;

  /// No description provided for @trainPlanGenerated.
  ///
  /// In en, this message translates to:
  /// **'Plan generated. Opening it now.'**
  String get trainPlanGenerated;

  /// No description provided for @trainPlansGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated {count} plans.'**
  String trainPlansGenerated(int count);

  /// No description provided for @trainActiveWorkoutKept.
  ///
  /// In en, this message translates to:
  /// **'Another workout is already active, so it was kept unchanged.'**
  String get trainActiveWorkoutKept;

  /// No description provided for @trainMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Menu'**
  String get trainMenuTitle;

  /// No description provided for @trainExerciseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Exercise Catalog'**
  String get trainExerciseCatalog;

  /// No description provided for @trainMuscleFilter.
  ///
  /// In en, this message translates to:
  /// **'Muscle Filter'**
  String get trainMuscleFilter;

  /// No description provided for @trainGymSettings.
  ///
  /// In en, this message translates to:
  /// **'Gym & Workout Settings'**
  String get trainGymSettings;

  /// No description provided for @trainTab.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainTab;

  /// No description provided for @trainHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get trainHistoryTab;

  /// No description provided for @trainExercisePresets.
  ///
  /// In en, this message translates to:
  /// **'Exercise Presets'**
  String get trainExercisePresets;

  /// No description provided for @trainGeneratePlans.
  ///
  /// In en, this message translates to:
  /// **'Generate Custom Plans'**
  String get trainGeneratePlans;

  /// No description provided for @trainAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Manually Add Preset'**
  String get trainAddPlan;

  /// No description provided for @trainNewPlanFirst.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get trainNewPlanFirst;

  /// No description provided for @trainNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New Preset {number}'**
  String trainNewPlan(int number);

  /// No description provided for @trainBuildingOptimized.
  ///
  /// In en, this message translates to:
  /// **'Building Optimized Workout...'**
  String get trainBuildingOptimized;

  /// No description provided for @trainStartOptimized.
  ///
  /// In en, this message translates to:
  /// **'Start Optimized Workout'**
  String get trainStartOptimized;

  /// No description provided for @trainNewSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get trainNewSession;

  /// No description provided for @foodCustomizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Food'**
  String get foodCustomizationTitle;

  /// No description provided for @foodCustomizationEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get foodCustomizationEditTitle;

  /// No description provided for @foodCustomizationName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodCustomizationName;

  /// No description provided for @foodCustomizationEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get foodCustomizationEnterName;

  /// No description provided for @foodCustomizationBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get foodCustomizationBrand;

  /// No description provided for @foodCustomizationFoodPhoto.
  ///
  /// In en, this message translates to:
  /// **'Food Photo'**
  String get foodCustomizationFoodPhoto;

  /// No description provided for @foodCustomizationLabelPhoto.
  ///
  /// In en, this message translates to:
  /// **'Label Photo'**
  String get foodCustomizationLabelPhoto;

  /// No description provided for @foodCustomizationDensity.
  ///
  /// In en, this message translates to:
  /// **'Density (g/mL)'**
  String get foodCustomizationDensity;

  /// No description provided for @foodCustomizationDensityHelp.
  ///
  /// In en, this message translates to:
  /// **'Used to convert mL-based portions (cups, tbsp) into grams for macro math.'**
  String get foodCustomizationDensityHelp;

  /// No description provided for @foodCustomizationCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get foodCustomizationCalories;

  /// No description provided for @foodCustomizationMacronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get foodCustomizationMacronutrients;

  /// No description provided for @foodCustomizationMicronutrients.
  ///
  /// In en, this message translates to:
  /// **'Micronutrients'**
  String get foodCustomizationMicronutrients;

  /// No description provided for @foodCustomizationAdditionalComponents.
  ///
  /// In en, this message translates to:
  /// **'Additional Components'**
  String get foodCustomizationAdditionalComponents;

  /// No description provided for @foodCustomizationPortionInfo.
  ///
  /// In en, this message translates to:
  /// **'Portion Info'**
  String get foodCustomizationPortionInfo;

  /// No description provided for @foodCustomizationBasisPortion.
  ///
  /// In en, this message translates to:
  /// **'Portioning basis for the nutritional values'**
  String get foodCustomizationBasisPortion;

  /// No description provided for @foodCustomizationUsualPortion.
  ///
  /// In en, this message translates to:
  /// **'Usual portion to be consumed by user'**
  String get foodCustomizationUsualPortion;

  /// No description provided for @foodCustomizationAddPortion.
  ///
  /// In en, this message translates to:
  /// **'Add portion'**
  String get foodCustomizationAddPortion;

  /// No description provided for @foodCustomizationUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get foodCustomizationUnit;

  /// No description provided for @foodCustomizationAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get foodCustomizationAmount;

  /// No description provided for @foodCustomizationWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (g)'**
  String get foodCustomizationWeight;

  /// No description provided for @foodCustomizationVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume (mL)'**
  String get foodCustomizationVolume;

  /// No description provided for @dashboardArchivedPlans.
  ///
  /// In en, this message translates to:
  /// **'Archived Plans'**
  String get dashboardArchivedPlans;

  /// No description provided for @dashboardActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Active Plans'**
  String get dashboardActivePlans;

  /// No description provided for @dashboardManagePlans.
  ///
  /// In en, this message translates to:
  /// **'Manage plans'**
  String get dashboardManagePlans;

  /// No description provided for @dashboardSelectProfilePlans.
  ///
  /// In en, this message translates to:
  /// **'Select a gym profile to view its plans.'**
  String get dashboardSelectProfilePlans;

  /// No description provided for @dashboardNoArchivedPlans.
  ///
  /// In en, this message translates to:
  /// **'No archived plans for this profile.'**
  String get dashboardNoArchivedPlans;

  /// No description provided for @dashboardNoActivePlans.
  ///
  /// In en, this message translates to:
  /// **'No active plans yet. Use the pen to choose plans.'**
  String get dashboardNoActivePlans;

  /// No description provided for @dashboardPremadeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ready-to-use routines are available to add.'**
  String dashboardPremadeCount(int count);

  /// No description provided for @dashboardBrowsePremadePlans.
  ///
  /// In en, this message translates to:
  /// **'Browse Premade Plans'**
  String get dashboardBrowsePremadePlans;

  /// No description provided for @dashboardNewPlanFirst.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get dashboardNewPlanFirst;

  /// No description provided for @dashboardNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New Plan {number}'**
  String dashboardNewPlan(int number);

  /// No description provided for @dashboardPlanTools.
  ///
  /// In en, this message translates to:
  /// **'Plan Tools'**
  String get dashboardPlanTools;

  /// No description provided for @dashboardPlanToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Build a plan from your training preferences or start a blank one.'**
  String get dashboardPlanToolsBody;

  /// No description provided for @dashboardManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get dashboardManual;

  /// No description provided for @dashboardGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get dashboardGenerate;

  /// No description provided for @dashboardMostUsedExercises.
  ///
  /// In en, this message translates to:
  /// **'Most used exercises'**
  String get dashboardMostUsedExercises;

  /// No description provided for @dashboardMostUsedExercisesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see your most common exercises here.'**
  String get dashboardMostUsedExercisesEmpty;

  /// No description provided for @premadeDiscardFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not discard added plans: {error}'**
  String premadeDiscardFailed(String error);

  /// No description provided for @premadeEquipmentSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select a gym profile to adapt plans to available equipment.'**
  String get premadeEquipmentSelectProfile;

  /// No description provided for @premadeEquipmentExact.
  ///
  /// In en, this message translates to:
  /// **'Premade plans are shown exactly as written.'**
  String get premadeEquipmentExact;

  /// No description provided for @premadeEquipmentChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking plan exercises against your profile...'**
  String get premadeEquipmentChecking;

  /// No description provided for @premadeEquipmentMissing.
  ///
  /// In en, this message translates to:
  /// **'No profile equipment found, so premade plans are unchanged.'**
  String get premadeEquipmentMissing;

  /// No description provided for @premadeEquipmentReplacements.
  ///
  /// In en, this message translates to:
  /// **'{count} unavailable exercise(s) will be swapped when plans are added.'**
  String premadeEquipmentReplacements(int count);

  /// No description provided for @premadeEquipmentFits.
  ///
  /// In en, this message translates to:
  /// **'Plans already fit the current profile equipment.'**
  String get premadeEquipmentFits;

  /// No description provided for @premadeOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hr'**
  String get premadeOneHour;

  /// No description provided for @premadeTwoHours.
  ///
  /// In en, this message translates to:
  /// **'2 hr'**
  String get premadeTwoHours;

  /// No description provided for @premadePlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} plan(s) available'**
  String premadePlansAvailable(int count);

  /// No description provided for @premadeNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No plan templates yet'**
  String get premadeNoTemplates;

  /// No description provided for @premadePlansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} plan(s)'**
  String premadePlansCount(int count);

  /// No description provided for @premadeTemplatesLater.
  ///
  /// In en, this message translates to:
  /// **'Templates for this split can be added here later.'**
  String get premadeTemplatesLater;

  /// No description provided for @premadeExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String premadeExerciseCount(int count);

  /// No description provided for @premadeSetCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String premadeSetCount(int count);

  /// No description provided for @premadeSwappedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} swapped'**
  String premadeSwappedCount(int count);

  /// No description provided for @premadeAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding'**
  String get premadeAdding;

  /// No description provided for @premadeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get premadeChecking;

  /// No description provided for @premadeProfileSwap.
  ///
  /// In en, this message translates to:
  /// **'profile swap'**
  String get premadeProfileSwap;

  /// No description provided for @healthEntryValueUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a value and unit first.'**
  String get healthEntryValueUnitRequired;

  /// No description provided for @healthDefinitionFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name, unit, and valid value.'**
  String get healthDefinitionFieldsRequired;

  /// No description provided for @healthUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get healthUnit;

  /// No description provided for @healthNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get healthNote;

  /// No description provided for @healthOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get healthOptional;

  /// No description provided for @healthMetricName.
  ///
  /// In en, this message translates to:
  /// **'Metric name'**
  String get healthMetricName;

  /// No description provided for @healthMetricNameHint.
  ///
  /// In en, this message translates to:
  /// **'Arm size, resting heart rate...'**
  String get healthMetricNameHint;

  /// No description provided for @healthUnitHint.
  ///
  /// In en, this message translates to:
  /// **'in, {weightUnit}, %, bpm...'**
  String healthUnitHint(String weightUnit);

  /// No description provided for @healthStartingValue.
  ///
  /// In en, this message translates to:
  /// **'Starting value'**
  String get healthStartingValue;

  /// No description provided for @healthCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get healthCreate;

  /// No description provided for @exerciseProgressNoRecordings.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get exerciseProgressNoRecordings;

  /// No description provided for @exerciseEditorDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get exerciseEditorDiscardTitle;

  /// No description provided for @exerciseEditorDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits are not saved yet. You can keep editing or discard them.'**
  String get exerciseEditorDiscardBody;

  /// No description provided for @exerciseEditorKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get exerciseEditorKeepEditing;

  /// No description provided for @exerciseEditorDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get exerciseEditorDiscard;

  /// No description provided for @exerciseEditorAddBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Add Associated Bodyparts'**
  String get exerciseEditorAddBodyparts;

  /// No description provided for @exerciseEditorAddMuscles.
  ///
  /// In en, this message translates to:
  /// **'Add Associated Muscles'**
  String get exerciseEditorAddMuscles;

  /// No description provided for @exerciseEditorAddEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add Equipment'**
  String get exerciseEditorAddEquipment;

  /// No description provided for @databaseClearMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Downloaded Media?'**
  String get databaseClearMediaTitle;

  /// No description provided for @databaseClearMediaBody.
  ///
  /// In en, this message translates to:
  /// **'This removes cached exercise, equipment, and anatomy media. The app can download them again when needed.'**
  String get databaseClearMediaBody;

  /// No description provided for @databaseClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get databaseClearCache;

  /// No description provided for @databaseCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Downloaded media cache cleared.'**
  String get databaseCacheCleared;

  /// No description provided for @databaseClearCacheFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear cache failed: {error}'**
  String databaseClearCacheFailed(String error);

  /// No description provided for @databaseContentEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Content Environment'**
  String get databaseContentEnvironment;

  /// No description provided for @databaseLoadingEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Loading environment...'**
  String get databaseLoadingEnvironment;

  /// No description provided for @databaseChangeEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Change environment'**
  String get databaseChangeEnvironment;

  /// No description provided for @databaseExerciseManifestUrl.
  ///
  /// In en, this message translates to:
  /// **'Exercise Media Manifest URL'**
  String get databaseExerciseManifestUrl;

  /// No description provided for @databaseNoExerciseManifestUrl.
  ///
  /// In en, this message translates to:
  /// **'No remote manifest URL set for this environment.'**
  String get databaseNoExerciseManifestUrl;

  /// No description provided for @databaseOverrideUrl.
  ///
  /// In en, this message translates to:
  /// **'Override URL'**
  String get databaseOverrideUrl;

  /// No description provided for @databaseNoManifestSynced.
  ///
  /// In en, this message translates to:
  /// **'No Manifest Synced'**
  String get databaseNoManifestSynced;

  /// No description provided for @databaseManifestVersion.
  ///
  /// In en, this message translates to:
  /// **'Manifest v{version}'**
  String databaseManifestVersion(int version);

  /// No description provided for @databaseLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {date}'**
  String databaseLastChecked(String date);

  /// No description provided for @databaseSharedCatalogMedia.
  ///
  /// In en, this message translates to:
  /// **'Shared Catalog Media'**
  String get databaseSharedCatalogMedia;

  /// No description provided for @databaseSharedMediaNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet. Equipment, bodyparts, and muscles.'**
  String get databaseSharedMediaNotSynced;

  /// No description provided for @databaseManifestLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Manifest v{version}. Last checked: {date}'**
  String databaseManifestLastChecked(int version, String date);

  /// No description provided for @databaseSharedManifestUrl.
  ///
  /// In en, this message translates to:
  /// **'Shared Media Manifest URL'**
  String get databaseSharedManifestUrl;

  /// No description provided for @databaseNoSharedManifestUrl.
  ///
  /// In en, this message translates to:
  /// **'No remote shared media URL set for this environment.'**
  String get databaseNoSharedManifestUrl;

  /// No description provided for @databaseDownloadedMediaCache.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Media Cache'**
  String get databaseDownloadedMediaCache;

  /// No description provided for @databaseCacheUsage.
  ///
  /// In en, this message translates to:
  /// **'{count} files, {size}'**
  String databaseCacheUsage(int count, String size);

  /// No description provided for @databaseLoadBundledManifest.
  ///
  /// In en, this message translates to:
  /// **'Load Bundled Manifest'**
  String get databaseLoadBundledManifest;

  /// No description provided for @databaseTutorialFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Database files'**
  String get databaseTutorialFilesTitle;

  /// No description provided for @databaseTutorialFilesBody.
  ///
  /// In en, this message translates to:
  /// **'Export a backup or import a saved database file. Imports require a backup first.'**
  String get databaseTutorialFilesBody;

  /// No description provided for @databaseTutorialHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Database health'**
  String get databaseTutorialHealthTitle;

  /// No description provided for @databaseTutorialHealthBody.
  ///
  /// In en, this message translates to:
  /// **'This card shows schema version, database size, table counts, and search-index health.'**
  String get databaseTutorialHealthBody;

  /// No description provided for @databaseTutorialMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance tools'**
  String get databaseTutorialMaintenanceTitle;

  /// No description provided for @databaseTutorialMaintenanceBody.
  ///
  /// In en, this message translates to:
  /// **'Use these actions for integrity checks, optimization, WAL checkpointing, or vacuuming when needed.'**
  String get databaseTutorialMaintenanceBody;

  /// No description provided for @databaseExportSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Database Export Saved'**
  String get databaseExportSavedTitle;

  /// No description provided for @databaseExportSavedBody.
  ///
  /// In en, this message translates to:
  /// **'The database export was saved to your selected location.'**
  String get databaseExportSavedBody;

  /// No description provided for @databaseImportBlocked.
  ///
  /// In en, this message translates to:
  /// **'Import blocked: {message}'**
  String databaseImportBlocked(String message);

  /// No description provided for @databaseImportBackupCanceled.
  ///
  /// In en, this message translates to:
  /// **'Import canceled: backup was not saved.'**
  String get databaseImportBackupCanceled;

  /// No description provided for @databaseImportSucceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Succeeded'**
  String get databaseImportSucceededTitle;

  /// No description provided for @databaseImportSucceededBody.
  ///
  /// In en, this message translates to:
  /// **'Imported {name}. A backup of the previous local database was saved to your selected location first.'**
  String databaseImportSucceededBody(String name);

  /// No description provided for @databaseConfirmImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get databaseConfirmImportTitle;

  /// No description provided for @databaseConfirmImportBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces the local database. A backup file of the current database will be written first.'**
  String get databaseConfirmImportBody;

  /// No description provided for @databaseImportFile.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String databaseImportFile(String name);

  /// No description provided for @databaseImportTables.
  ///
  /// In en, this message translates to:
  /// **'Tables: {count}'**
  String databaseImportTables(int count);

  /// No description provided for @databaseImportRows.
  ///
  /// In en, this message translates to:
  /// **'Rows: {count}'**
  String databaseImportRows(int count);

  /// No description provided for @databaseImportSchema.
  ///
  /// In en, this message translates to:
  /// **'Export schema: v{version}'**
  String databaseImportSchema(int version);

  /// No description provided for @databaseImportLegacyFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: legacy table map'**
  String get databaseImportLegacyFormat;

  /// No description provided for @databaseImportWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings:'**
  String get databaseImportWarnings;

  /// No description provided for @databaseBackupAndImport.
  ///
  /// In en, this message translates to:
  /// **'Back Up & Import'**
  String get databaseBackupAndImport;

  /// No description provided for @databaseMaintenanceFailed.
  ///
  /// In en, this message translates to:
  /// **'Database maintenance failed: {error}'**
  String databaseMaintenanceFailed(String error);

  /// No description provided for @exerciseEditorSaveBeforeAllocation.
  ///
  /// In en, this message translates to:
  /// **'Save or cancel definition changes before editing set credit.'**
  String get exerciseEditorSaveBeforeAllocation;

  /// No description provided for @exerciseEditorRemoveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {type}?'**
  String exerciseEditorRemoveItemTitle(String type);

  /// No description provided for @exerciseEditorRemoveItemBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from this exercise definition?'**
  String exerciseEditorRemoveItemBody(String name);

  /// No description provided for @exerciseEditorKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get exerciseEditorKeep;

  /// No description provided for @exerciseEditorMuscleOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Target muscle order'**
  String get exerciseEditorMuscleOrderTitle;

  /// No description provided for @exerciseEditorMuscleOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Order muscles by how strongly the exercise targets them. This helps Tonos estimate anatomy focus and make better exercise recommendations.'**
  String get exerciseEditorMuscleOrderBody;

  /// No description provided for @exerciseEditorExactSetCredit.
  ///
  /// In en, this message translates to:
  /// **'Exact set credit'**
  String get exerciseEditorExactSetCredit;

  /// No description provided for @exerciseEditorExactSetCreditBody.
  ///
  /// In en, this message translates to:
  /// **'Change the precise credit one set gives each muscle or body part in Exercise Set Allocation.'**
  String get exerciseEditorExactSetCreditBody;

  /// No description provided for @exerciseEditorSetCreditScaling.
  ///
  /// In en, this message translates to:
  /// **'Set-credit scaling'**
  String get exerciseEditorSetCreditScaling;

  /// No description provided for @exerciseEditorSetCreditScalingBody.
  ///
  /// In en, this message translates to:
  /// **'Choose whether this exercise rating scales set credit.'**
  String get exerciseEditorSetCreditScalingBody;

  /// No description provided for @exerciseEditorScaleCreditByRating.
  ///
  /// In en, this message translates to:
  /// **'Scale credit by rating'**
  String get exerciseEditorScaleCreditByRating;

  /// No description provided for @exerciseEditorScaleCreditByRatingBody.
  ///
  /// In en, this message translates to:
  /// **'Applies the exercise rating to analytic set totals.'**
  String get exerciseEditorScaleCreditByRatingBody;

  /// No description provided for @exerciseEditorTargetMuscles.
  ///
  /// In en, this message translates to:
  /// **'Target muscles'**
  String get exerciseEditorTargetMuscles;

  /// No description provided for @exerciseEditorOrderMusclesHint.
  ///
  /// In en, this message translates to:
  /// **'Use arrows to order muscles by target emphasis.'**
  String get exerciseEditorOrderMusclesHint;

  /// No description provided for @exerciseEditorMusclesAssociated.
  ///
  /// In en, this message translates to:
  /// **'{count} muscles currently associated.'**
  String exerciseEditorMusclesAssociated(int count);

  /// No description provided for @exerciseEditorNoTargetMuscles.
  ///
  /// In en, this message translates to:
  /// **'No target muscles are associated yet.'**
  String get exerciseEditorNoTargetMuscles;

  /// No description provided for @exerciseEditorAddTargetMuscles.
  ///
  /// In en, this message translates to:
  /// **'Add target muscles'**
  String get exerciseEditorAddTargetMuscles;

  /// No description provided for @exerciseEditorMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get exerciseEditorMoveUp;

  /// No description provided for @exerciseEditorMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get exerciseEditorMoveDown;

  /// No description provided for @exerciseEditorRemoveMuscle.
  ///
  /// In en, this message translates to:
  /// **'Remove muscle'**
  String get exerciseEditorRemoveMuscle;

  /// No description provided for @exerciseEditorMuscleItem.
  ///
  /// In en, this message translates to:
  /// **'muscle'**
  String get exerciseEditorMuscleItem;

  /// No description provided for @exerciseEditorAssociatedBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Associated body parts'**
  String get exerciseEditorAssociatedBodyparts;

  /// No description provided for @exerciseEditorAssociatedBodypartsBody.
  ///
  /// In en, this message translates to:
  /// **'These broad areas drive body heatmaps, weekly coverage, and equipment-aware workout recommendations.'**
  String get exerciseEditorAssociatedBodypartsBody;

  /// No description provided for @exerciseEditorExactBodypartCredit.
  ///
  /// In en, this message translates to:
  /// **'Exact body-part credit'**
  String get exerciseEditorExactBodypartCredit;

  /// No description provided for @exerciseEditorExactBodypartCreditBody.
  ///
  /// In en, this message translates to:
  /// **'Use Exercise Set Allocation when a set should count as a specific partial amount for a body part.'**
  String get exerciseEditorExactBodypartCreditBody;

  /// No description provided for @exerciseEditorBodypartsHint.
  ///
  /// In en, this message translates to:
  /// **'Add every broad body area this exercise trains.'**
  String get exerciseEditorBodypartsHint;

  /// No description provided for @exerciseEditorBodypartsAssociated.
  ///
  /// In en, this message translates to:
  /// **'{count} body parts currently associated.'**
  String exerciseEditorBodypartsAssociated(int count);

  /// No description provided for @exerciseEditorNoBodyparts.
  ///
  /// In en, this message translates to:
  /// **'No body parts are associated yet.'**
  String get exerciseEditorNoBodyparts;

  /// No description provided for @exerciseEditorAutomaticPreview.
  ///
  /// In en, this message translates to:
  /// **'Automatic preview'**
  String get exerciseEditorAutomaticPreview;

  /// No description provided for @exerciseEditorAutomaticPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'Current focus derived from the target-muscle structure.'**
  String get exerciseEditorAutomaticPreviewBody;

  /// No description provided for @exerciseEditorRemoveBodypart.
  ///
  /// In en, this message translates to:
  /// **'Remove body part'**
  String get exerciseEditorRemoveBodypart;

  /// No description provided for @exerciseEditorBodypartItem.
  ///
  /// In en, this message translates to:
  /// **'body part'**
  String get exerciseEditorBodypartItem;

  /// No description provided for @exerciseEditorAvailableEquipment.
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get exerciseEditorAvailableEquipment;

  /// No description provided for @exerciseEditorAvailableEquipmentBody.
  ///
  /// In en, this message translates to:
  /// **'Associated equipment determines which profiles can use this exercise and which replacements Tonos can recommend.'**
  String get exerciseEditorAvailableEquipmentBody;

  /// No description provided for @exerciseEditorEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Add every item needed to perform this exercise.'**
  String get exerciseEditorEquipmentHint;

  /// No description provided for @exerciseEditorEquipmentAssociated.
  ///
  /// In en, this message translates to:
  /// **'{count} items associated.'**
  String exerciseEditorEquipmentAssociated(int count);

  /// No description provided for @exerciseEditorNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment is associated yet.'**
  String get exerciseEditorNoEquipment;

  /// No description provided for @exerciseEditorRemoveEquipment.
  ///
  /// In en, this message translates to:
  /// **'Remove equipment'**
  String get exerciseEditorRemoveEquipment;

  /// No description provided for @exerciseEditorEquipmentItem.
  ///
  /// In en, this message translates to:
  /// **'equipment'**
  String get exerciseEditorEquipmentItem;

  /// No description provided for @historySummaryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historySummaryAll;

  /// No description provided for @historySummaryDuration.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String historySummaryDuration(int hours, int minutes);

  /// No description provided for @planCoachStepTitle.
  ///
  /// In en, this message translates to:
  /// **'{step}/{total} - {title}'**
  String planCoachStepTitle(int step, int total, String title);

  /// No description provided for @databaseManifestUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a valid exercise media manifest URL first.'**
  String get databaseManifestUrlRequired;

  /// No description provided for @databaseContentSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Content sync failed: {error}'**
  String databaseContentSyncFailed(String error);

  /// No description provided for @databaseBundledContentSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Bundled content sync failed: {error}'**
  String databaseBundledContentSyncFailed(String error);

  /// No description provided for @databaseSharedMediaUrlMissing.
  ///
  /// In en, this message translates to:
  /// **'This content environment has no shared media URL.'**
  String get databaseSharedMediaUrlMissing;

  /// No description provided for @databaseSharedContentSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Shared content sync failed: {error}'**
  String databaseSharedContentSyncFailed(String error);

  /// No description provided for @databaseDefinitionExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export {filename} failed: {error}'**
  String databaseDefinitionExportFailed(String filename, String error);

  /// No description provided for @databaseExerciseManifestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Media Manifest'**
  String get databaseExerciseManifestDialogTitle;

  /// No description provided for @databaseManifestUrl.
  ///
  /// In en, this message translates to:
  /// **'Manifest URL'**
  String get databaseManifestUrl;

  /// No description provided for @databaseClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get databaseClear;

  /// No description provided for @databaseNoManifestConfigured.
  ///
  /// In en, this message translates to:
  /// **'No manifest URL configured yet.'**
  String get databaseNoManifestConfigured;

  /// No description provided for @databaseUseEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Use Environment'**
  String get databaseUseEnvironment;

  /// No description provided for @dashboardTargetAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Target Anatomy'**
  String get dashboardTargetAnatomy;

  /// No description provided for @dashboardBodyparts.
  ///
  /// In en, this message translates to:
  /// **'Bodyparts'**
  String get dashboardBodyparts;

  /// No description provided for @dashboardMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get dashboardMuscles;

  /// No description provided for @exerciseEditorCreateCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Create custom exercise'**
  String get exerciseEditorCreateCustomTitle;

  /// No description provided for @exerciseEditorCreateCustomBody.
  ///
  /// In en, this message translates to:
  /// **'Create a custom catalog definition, then add its target anatomy and guidance before saving.'**
  String get exerciseEditorCreateCustomBody;

  /// No description provided for @exerciseEditorExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseEditorExerciseName;

  /// No description provided for @exerciseEditorNoEquipmentChoice.
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get exerciseEditorNoEquipmentChoice;

  /// No description provided for @exerciseEditorOpenedMessage.
  ///
  /// In en, this message translates to:
  /// **'Exercise opened. Add its target anatomy, then save.'**
  String get exerciseEditorOpenedMessage;

  /// No description provided for @exerciseEditorCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the custom exercise. {error}'**
  String exerciseEditorCreateFailed(String error);

  /// No description provided for @exerciseEditorWhatChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'What this changes'**
  String get exerciseEditorWhatChangesTitle;

  /// No description provided for @exerciseEditorWhatChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Use this advanced editor to update an exercise name, target anatomy, equipment, form guidance, rating, and reference media. Exact per-set credit is managed separately so it stays consistent across the app.'**
  String get exerciseEditorWhatChangesBody;

  /// No description provided for @exerciseEditorChooseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise from the catalog'**
  String get exerciseEditorChooseCatalog;

  /// No description provided for @exerciseEditorRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get exerciseEditorRating;

  /// No description provided for @databaseNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get databaseNever;

  /// No description provided for @databaseExportDefinition.
  ///
  /// In en, this message translates to:
  /// **'Export {filename}'**
  String databaseExportDefinition(String filename);

  /// No description provided for @exerciseEditorAddMedia.
  ///
  /// In en, this message translates to:
  /// **'Add media'**
  String get exerciseEditorAddMedia;

  /// No description provided for @exerciseEditorEditMedia.
  ///
  /// In en, this message translates to:
  /// **'Edit media'**
  String get exerciseEditorEditMedia;

  /// No description provided for @exerciseEditorMediaImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get exerciseEditorMediaImage;

  /// No description provided for @exerciseEditorMediaVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get exerciseEditorMediaVideo;

  /// No description provided for @exerciseEditorMediaLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get exerciseEditorMediaLink;

  /// No description provided for @exerciseEditorMediaType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseEditorMediaType;

  /// No description provided for @exerciseEditorMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get exerciseEditorMediaTitle;

  /// No description provided for @exerciseEditorMediaTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Optional display label'**
  String get exerciseEditorMediaTitleHint;

  /// No description provided for @exerciseEditorMediaRemoteUrl.
  ///
  /// In en, this message translates to:
  /// **'Remote URL'**
  String get exerciseEditorMediaRemoteUrl;

  /// No description provided for @exerciseEditorMediaThumbnailUrl.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail URL'**
  String get exerciseEditorMediaThumbnailUrl;

  /// No description provided for @exerciseEditorMediaThumbnailHint.
  ///
  /// In en, this message translates to:
  /// **'Optional image preview URL'**
  String get exerciseEditorMediaThumbnailHint;

  /// No description provided for @exerciseEditorSelectBeforeMedia.
  ///
  /// In en, this message translates to:
  /// **'Select an existing exercise before attaching media.'**
  String get exerciseEditorSelectBeforeMedia;

  /// No description provided for @exerciseEditorFormGuide.
  ///
  /// In en, this message translates to:
  /// **'Form guide'**
  String get exerciseEditorFormGuide;

  /// No description provided for @exerciseEditorFormGuideBody.
  ///
  /// In en, this message translates to:
  /// **'These notes appear in the exercise details sheet to help people set up, perform, and understand the movement safely.'**
  String get exerciseEditorFormGuideBody;

  /// No description provided for @exerciseEditorGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get exerciseEditorGuidance;

  /// No description provided for @exerciseEditorGuidanceEditing.
  ///
  /// In en, this message translates to:
  /// **'Write clear, practical cues. Changes are staged until saved.'**
  String get exerciseEditorGuidanceEditing;

  /// No description provided for @exerciseEditorGuidanceReadOnly.
  ///
  /// In en, this message translates to:
  /// **'The current exercise instructions and cues.'**
  String get exerciseEditorGuidanceReadOnly;

  /// No description provided for @exerciseEditorSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get exerciseEditorSetUp;

  /// No description provided for @exerciseEditorSetUpHint.
  ///
  /// In en, this message translates to:
  /// **'Starting position, equipment setup, and safety notes.'**
  String get exerciseEditorSetUpHint;

  /// No description provided for @exerciseEditorHowToPerform.
  ///
  /// In en, this message translates to:
  /// **'How to perform'**
  String get exerciseEditorHowToPerform;

  /// No description provided for @exerciseEditorHowToPerformHint.
  ///
  /// In en, this message translates to:
  /// **'The key movement steps and range of motion.'**
  String get exerciseEditorHowToPerformHint;

  /// No description provided for @exerciseEditorCoachingTips.
  ///
  /// In en, this message translates to:
  /// **'Coaching tips'**
  String get exerciseEditorCoachingTips;

  /// No description provided for @exerciseEditorCoachingTipsHint.
  ///
  /// In en, this message translates to:
  /// **'Helpful cues, common mistakes, and variations.'**
  String get exerciseEditorCoachingTipsHint;

  /// No description provided for @exerciseEditorReferenceMedia.
  ///
  /// In en, this message translates to:
  /// **'Reference media'**
  String get exerciseEditorReferenceMedia;

  /// No description provided for @exerciseEditorReferenceMediaBody.
  ///
  /// In en, this message translates to:
  /// **'Use media links for private reference material. Managed catalog media can be refreshed by the content sync pipeline.'**
  String get exerciseEditorReferenceMediaBody;

  /// No description provided for @exerciseEditorMediaLinks.
  ///
  /// In en, this message translates to:
  /// **'Media links'**
  String get exerciseEditorMediaLinks;

  /// No description provided for @exerciseEditorMediaLinksEditing.
  ///
  /// In en, this message translates to:
  /// **'Add or update a remote image, video, or reference link.'**
  String get exerciseEditorMediaLinksEditing;

  /// No description provided for @exerciseEditorMediaLinksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} media item(s) currently linked.'**
  String exerciseEditorMediaLinksCount(int count);

  /// No description provided for @exerciseEditorNoReferenceMedia.
  ///
  /// In en, this message translates to:
  /// **'No reference media is linked yet.'**
  String get exerciseEditorNoReferenceMedia;

  /// No description provided for @exerciseEditorAddMediaLink.
  ///
  /// In en, this message translates to:
  /// **'Add media link'**
  String get exerciseEditorAddMediaLink;

  /// No description provided for @exerciseEditorRemoveMedia.
  ///
  /// In en, this message translates to:
  /// **'Remove media'**
  String get exerciseEditorRemoveMedia;

  /// No description provided for @exerciseEditorMediaLinkItem.
  ///
  /// In en, this message translates to:
  /// **'media link'**
  String get exerciseEditorMediaLinkItem;

  /// No description provided for @exerciseEditorMediaReference.
  ///
  /// In en, this message translates to:
  /// **'{type} reference'**
  String exerciseEditorMediaReference(String type);

  /// No description provided for @bengaliBangladeshLanguage.
  ///
  /// In en, this message translates to:
  /// **'Bangla (Bangladesh)'**
  String get bengaliBangladeshLanguage;

  /// No description provided for @simplifiedChineseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get simplifiedChineseLanguage;

  /// No description provided for @hindiLanguage.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindiLanguage;

  /// No description provided for @spanishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishLanguage;

  /// No description provided for @onboardingWeightHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight history'**
  String get onboardingWeightHistoryTitle;

  /// No description provided for @onboardingWeightHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few details help estimate nutrition targets more sensibly.'**
  String get onboardingWeightHistorySubtitle;

  /// No description provided for @onboardingPreviouslyHeavier.
  ///
  /// In en, this message translates to:
  /// **'Have you weighed 10+ lbs above your current weight before?'**
  String get onboardingPreviouslyHeavier;

  /// No description provided for @onboardingWeightTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Current weight trend'**
  String get onboardingWeightTrendTitle;

  /// No description provided for @onboardingWeightTrendGaining.
  ///
  /// In en, this message translates to:
  /// **'Gaining weight'**
  String get onboardingWeightTrendGaining;

  /// No description provided for @onboardingWeightTrendLosing.
  ///
  /// In en, this message translates to:
  /// **'Losing weight'**
  String get onboardingWeightTrendLosing;

  /// No description provided for @onboardingWeightTrendMaintaining.
  ///
  /// In en, this message translates to:
  /// **'Maintaining weight'**
  String get onboardingWeightTrendMaintaining;

  /// No description provided for @onboardingNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get onboardingNotSure;

  /// No description provided for @onboardingBodyFatEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Body-fat estimate'**
  String get onboardingBodyFatEstimateTitle;

  /// No description provided for @onboardingBodyFatEstimateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the closest visual estimate. Precision is not required.'**
  String get onboardingBodyFatEstimateSubtitle;

  /// No description provided for @onboardingNutritionPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition preferences'**
  String get onboardingNutritionPreferencesTitle;

  /// No description provided for @onboardingNutritionPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These preferences shape nutrition suggestions after setup.'**
  String get onboardingNutritionPreferencesSubtitle;

  /// No description provided for @onboardingPreferredDiet.
  ///
  /// In en, this message translates to:
  /// **'Preferred diet'**
  String get onboardingPreferredDiet;

  /// No description provided for @onboardingDietBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get onboardingDietBalanced;

  /// No description provided for @onboardingDietLowFat.
  ///
  /// In en, this message translates to:
  /// **'Low fat'**
  String get onboardingDietLowFat;

  /// No description provided for @onboardingDietLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low carb'**
  String get onboardingDietLowCarb;

  /// No description provided for @onboardingDietKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get onboardingDietKeto;

  /// No description provided for @onboardingCalorieFloor.
  ///
  /// In en, this message translates to:
  /// **'Calorie floor'**
  String get onboardingCalorieFloor;

  /// No description provided for @onboardingCalorieFloorHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum daily kcal'**
  String get onboardingCalorieFloorHint;

  /// No description provided for @onboardingTrainingDuringProgram.
  ///
  /// In en, this message translates to:
  /// **'Training during program'**
  String get onboardingTrainingDuringProgram;

  /// No description provided for @onboardingTrainingNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get onboardingTrainingNone;

  /// No description provided for @onboardingTrainingLifting.
  ///
  /// In en, this message translates to:
  /// **'Lifting'**
  String get onboardingTrainingLifting;

  /// No description provided for @onboardingTrainingCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get onboardingTrainingCardio;

  /// No description provided for @onboardingTrainingLiftingAndCardio.
  ///
  /// In en, this message translates to:
  /// **'Lifting and cardio'**
  String get onboardingTrainingLiftingAndCardio;

  /// No description provided for @onboardingProteinPreference.
  ///
  /// In en, this message translates to:
  /// **'Preferred protein intake'**
  String get onboardingProteinPreference;

  /// No description provided for @onboardingProteinLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get onboardingProteinLow;

  /// No description provided for @onboardingProteinModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get onboardingProteinModerate;

  /// No description provided for @onboardingProteinHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get onboardingProteinHigh;

  /// No description provided for @onboardingProteinVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get onboardingProteinVeryHigh;

  /// No description provided for @onboardingGoalPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal pace'**
  String get onboardingGoalPaceTitle;

  /// No description provided for @onboardingGoalPaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview a target weight and weekly goal rate.'**
  String get onboardingGoalPaceSubtitle;

  /// No description provided for @onboardingInitialDailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Initial daily budget'**
  String get onboardingInitialDailyBudget;

  /// No description provided for @onboardingProjectedEndDate.
  ///
  /// In en, this message translates to:
  /// **'Projected end date'**
  String get onboardingProjectedEndDate;

  /// No description provided for @onboardingTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get onboardingTargetWeight;

  /// No description provided for @onboardingTargetGoalRate.
  ///
  /// In en, this message translates to:
  /// **'Target goal rate'**
  String get onboardingTargetGoalRate;

  /// No description provided for @onboardingPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get onboardingPerWeek;

  /// No description provided for @onboardingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get onboardingPerMonth;

  /// No description provided for @exerciseProgressTrackExercise.
  ///
  /// In en, this message translates to:
  /// **'Track an exercise'**
  String get exerciseProgressTrackExercise;

  /// No description provided for @exerciseProgressTrackExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise to start watching its 1RM trend here.'**
  String get exerciseProgressTrackExerciseBody;

  /// No description provided for @healthCustomMetric.
  ///
  /// In en, this message translates to:
  /// **'Custom metric'**
  String get healthCustomMetric;

  /// No description provided for @healthLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get healthLatest;

  /// No description provided for @healthNoEntry.
  ///
  /// In en, this message translates to:
  /// **'No entry'**
  String get healthNoEntry;

  /// No description provided for @healthNotTrackedYet.
  ///
  /// In en, this message translates to:
  /// **'Not tracked yet'**
  String get healthNotTrackedYet;

  /// No description provided for @healthChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get healthChange;

  /// No description provided for @healthNeedTwoEntries.
  ///
  /// In en, this message translates to:
  /// **'Need 2 entries'**
  String get healthNeedTwoEntries;

  /// No description provided for @healthVersusPrevious.
  ///
  /// In en, this message translates to:
  /// **'Vs previous'**
  String get healthVersusPrevious;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get healthRecords;

  /// No description provided for @presetEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get presetEstimatedTime;

  /// No description provided for @presetNoFocusData.
  ///
  /// In en, this message translates to:
  /// **'No focus data yet.'**
  String get presetNoFocusData;

  /// No description provided for @presetFocusPreviewHelp.
  ///
  /// In en, this message translates to:
  /// **'Add weight exercises with bodypart data to preview preset focus.'**
  String get presetFocusPreviewHelp;

  /// No description provided for @dashboardReorderHelp.
  ///
  /// In en, this message translates to:
  /// **'Drag sections into the order that works best for you.'**
  String get dashboardReorderHelp;

  /// No description provided for @exerciseEditorCachedLocally.
  ///
  /// In en, this message translates to:
  /// **'Cached locally'**
  String get exerciseEditorCachedLocally;

  /// No description provided for @databaseExerciseMediaSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} exercise media entries (v{version}).'**
  String databaseExerciseMediaSyncSuccess(int count, int version);

  /// No description provided for @databaseBundledManifestLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded bundled exercise media manifest (v{version}).'**
  String databaseBundledManifestLoaded(int version);

  /// No description provided for @databaseSharedMediaSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} equipment and anatomy media entries (v{version}).'**
  String databaseSharedMediaSyncSuccess(int count, int version);

  /// No description provided for @databaseHealthSchema.
  ///
  /// In en, this message translates to:
  /// **'Schema'**
  String get databaseHealthSchema;

  /// No description provided for @databaseHealthSchemaValue.
  ///
  /// In en, this message translates to:
  /// **'v{current} / target v{target}'**
  String databaseHealthSchemaValue(int current, int target);

  /// No description provided for @databaseHealthSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get databaseHealthSize;

  /// No description provided for @databaseHealthJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get databaseHealthJournal;

  /// No description provided for @databaseHealthTables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get databaseHealthTables;

  /// No description provided for @databaseHealthTablesValue.
  ///
  /// In en, this message translates to:
  /// **'{tables} tables, {indexes} indexes, {triggers} triggers'**
  String databaseHealthTablesValue(int tables, int indexes, int triggers);

  /// No description provided for @databaseHealthFoodSearch.
  ///
  /// In en, this message translates to:
  /// **'Food search'**
  String get databaseHealthFoodSearch;

  /// No description provided for @databaseHealthFoodSearchValue.
  ///
  /// In en, this message translates to:
  /// **'{foods} foods, {rows} FTS rows'**
  String databaseHealthFoodSearchValue(int foods, int rows);

  /// No description provided for @databaseHealthPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get databaseHealthPath;

  /// No description provided for @dashboardWorkoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get dashboardWorkoutInProgress;

  /// No description provided for @dashboardNoSavedPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans saved for this gym profile yet.'**
  String get dashboardNoSavedPlans;

  /// No description provided for @exerciseProgressOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'1 Rep Max'**
  String get exerciseProgressOneRepMax;

  /// No description provided for @exerciseProgressEstimatedOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get exerciseProgressEstimatedOneRepMax;

  /// No description provided for @onboardingPageWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get onboardingPageWeight;

  /// No description provided for @onboardingPageBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get onboardingPageBodyFat;

  /// No description provided for @onboardingPageNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get onboardingPageNutrition;

  /// No description provided for @onboardingPageGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get onboardingPageGoal;

  /// No description provided for @dashboardRecordsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} this week'**
  String dashboardRecordsThisWeek(int count, int total);

  /// No description provided for @dashboardRecordsAllTime.
  ///
  /// In en, this message translates to:
  /// **'{count} all time'**
  String dashboardRecordsAllTime(int count);

  /// No description provided for @dashboardVisualBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Visual Body Fat'**
  String get dashboardVisualBodyFat;

  /// No description provided for @dashboardNewMetric.
  ///
  /// In en, this message translates to:
  /// **'New Metric'**
  String get dashboardNewMetric;

  /// No description provided for @dashboardCurrentMetrics.
  ///
  /// In en, this message translates to:
  /// **'Current Metrics'**
  String get dashboardCurrentMetrics;

  /// No description provided for @workoutReportDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get workoutReportDay;

  /// No description provided for @workoutReportDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get workoutReportDays;

  /// No description provided for @workoutReportWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get workoutReportWeek;

  /// No description provided for @workoutReportMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get workoutReportMonth;

  /// No description provided for @workoutReportAveragePer.
  ///
  /// In en, this message translates to:
  /// **'Avg / {period}'**
  String workoutReportAveragePer(String period);

  /// No description provided for @workoutReportWorkoutsLowercase.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workoutReportWorkoutsLowercase;

  /// No description provided for @workoutReportLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get workoutReportLongestStreak;

  /// No description provided for @workoutReportMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get workoutReportMostActive;

  /// No description provided for @workoutReportNoSessions.
  ///
  /// In en, this message translates to:
  /// **'no sessions'**
  String get workoutReportNoSessions;

  /// No description provided for @workoutReportWeekday.
  ///
  /// In en, this message translates to:
  /// **'weekday'**
  String get workoutReportWeekday;

  /// No description provided for @workoutReportMetricSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} report metric'**
  String workoutReportMetricSemantics(String label);

  /// No description provided for @workoutReportUnitLogged.
  ///
  /// In en, this message translates to:
  /// **'{unit} logged'**
  String workoutReportUnitLogged(String unit);

  /// No description provided for @workoutReportUnitOnDate.
  ///
  /// In en, this message translates to:
  /// **'{unit} on {date}'**
  String workoutReportUnitOnDate(String unit, String date);

  /// No description provided for @profileDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Privacy'**
  String get profileDiagnosticsTitle;

  /// No description provided for @profileDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, anonymous-diagnostics consent, sync history, and data deletion.'**
  String get profileDiagnosticsSubtitle;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Privacy'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand and control release diagnostics.'**
  String get diagnosticsSubtitle;

  /// No description provided for @diagnosticsAppSection.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get diagnosticsAppSection;

  /// No description provided for @diagnosticsAppSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Useful when reporting a problem.'**
  String get diagnosticsAppSectionSubtitle;

  /// No description provided for @diagnosticsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version and build'**
  String get diagnosticsVersion;

  /// No description provided for @diagnosticsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get diagnosticsLoading;

  /// No description provided for @diagnosticsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get diagnosticsUnavailable;

  /// No description provided for @diagnosticsCrashSection.
  ///
  /// In en, this message translates to:
  /// **'Anonymous diagnostics'**
  String get diagnosticsCrashSection;

  /// No description provided for @diagnosticsCrashSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional, categorical reports for app faults and media sync.'**
  String get diagnosticsCrashSectionSubtitle;

  /// No description provided for @diagnosticsCrashReporting.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous diagnostics'**
  String get diagnosticsCrashReporting;

  /// No description provided for @diagnosticsCrashUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not configured in this build. No anonymous diagnostics can be shared.'**
  String get diagnosticsCrashUnavailable;

  /// No description provided for @diagnosticsCrashEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'Enabled with your consent. Turning it off requests deletion of reports held by Tonos.'**
  String get diagnosticsCrashEnabledBody;

  /// No description provided for @diagnosticsCrashDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Turn it on only if you want to help diagnose release problems.'**
  String get diagnosticsCrashDisabledBody;

  /// No description provided for @diagnosticsPrivacyPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy by design'**
  String get diagnosticsPrivacyPromiseTitle;

  /// No description provided for @diagnosticsPrivacyPromiseBody.
  ///
  /// In en, this message translates to:
  /// **'Reports contain only the app version, build number, platform, approved category, outcome, and coarse buckets. They never include error messages, stack traces, names, health data, database contents, screenshots, network addresses, traces, or analytics.'**
  String get diagnosticsPrivacyPromiseBody;

  /// No description provided for @diagnosticsSyncSection.
  ///
  /// In en, this message translates to:
  /// **'Content sync history'**
  String get diagnosticsSyncSection;

  /// No description provided for @diagnosticsSyncSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The 30 most recent media-manifest outcomes are kept only on this device.'**
  String get diagnosticsSyncSectionSubtitle;

  /// No description provided for @diagnosticsNoSyncEvents.
  ///
  /// In en, this message translates to:
  /// **'No sync diagnostics yet'**
  String get diagnosticsNoSyncEvents;

  /// No description provided for @diagnosticsNoSyncEventsBody.
  ///
  /// In en, this message translates to:
  /// **'Exercise and shared-media sync outcomes will appear here without URLs or personal data.'**
  String get diagnosticsNoSyncEventsBody;

  /// No description provided for @diagnosticsClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear sync history'**
  String get diagnosticsClearHistory;

  /// No description provided for @diagnosticsClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all locally stored sync diagnostic entries.'**
  String get diagnosticsClearHistoryBody;

  /// No description provided for @diagnosticsHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Sync diagnostic history cleared.'**
  String get diagnosticsHistoryCleared;

  /// No description provided for @diagnosticsExerciseMedia.
  ///
  /// In en, this message translates to:
  /// **'Exercise media'**
  String get diagnosticsExerciseMedia;

  /// No description provided for @diagnosticsSharedMedia.
  ///
  /// In en, this message translates to:
  /// **'Shared media'**
  String get diagnosticsSharedMedia;

  /// No description provided for @diagnosticsRemoteSource.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get diagnosticsRemoteSource;

  /// No description provided for @diagnosticsBundledSource.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get diagnosticsBundledSource;

  /// No description provided for @diagnosticsSyncSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get diagnosticsSyncSucceeded;

  /// No description provided for @diagnosticsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get diagnosticsSyncFailed;

  /// No description provided for @diagnosticsSyncEventTitle.
  ///
  /// In en, this message translates to:
  /// **'{operation}: {outcome}'**
  String diagnosticsSyncEventTitle(String operation, String outcome);

  /// No description provided for @diagnosticsSyncEventDetails.
  ///
  /// In en, this message translates to:
  /// **'{source} • {timestamp} • {duration} ms • manifest {version} • {items} items'**
  String diagnosticsSyncEventDetails(
    String source,
    String timestamp,
    int duration,
    String version,
    String items,
  );

  /// No description provided for @diagnosticsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get diagnosticsPrivacySection;

  /// No description provided for @diagnosticsPrivacySectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local storage, retention, and deletion.'**
  String get diagnosticsPrivacySectionSubtitle;

  /// No description provided for @diagnosticsLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness data stays local'**
  String get diagnosticsLocalDataTitle;

  /// No description provided for @diagnosticsLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'Workout, nutrition, body metric, and profile records remain in the app database on this device unless you export a backup yourself.'**
  String get diagnosticsLocalDataBody;

  /// No description provided for @diagnosticsDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete diagnostic and app data'**
  String get diagnosticsDeletionTitle;

  /// No description provided for @diagnosticsDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'Clear sync history above and turn off anonymous diagnostics to request deletion of reports shared by this installation. Clear Tonos storage in device settings or uninstall Tonos to remove the local database and caches.'**
  String get diagnosticsDeletionBody;

  /// No description provided for @diagnosticsSendTestReport.
  ///
  /// In en, this message translates to:
  /// **'Send a controlled diagnostics event'**
  String get diagnosticsSendTestReport;

  /// No description provided for @diagnosticsSendTestReportBody.
  ///
  /// In en, this message translates to:
  /// **'Available only in an explicitly test-enabled build. It sends one fixed allowlisted event.'**
  String get diagnosticsSendTestReportBody;

  /// No description provided for @diagnosticsTestReportSent.
  ///
  /// In en, this message translates to:
  /// **'Controlled diagnostics event sent.'**
  String get diagnosticsTestReportSent;

  /// No description provided for @diagnosticsTestReportFailed.
  ///
  /// In en, this message translates to:
  /// **'The diagnostics event could not be sent. Check the build configuration and connection.'**
  String get diagnosticsTestReportFailed;

  /// No description provided for @diagnosticsDeleteShared.
  ///
  /// In en, this message translates to:
  /// **'Delete shared diagnostics'**
  String get diagnosticsDeleteShared;

  /// No description provided for @diagnosticsDeleteSharedBody.
  ///
  /// In en, this message translates to:
  /// **'Requests deletion of reports this app can prove it sent. Provider recovery history may retain deleted rows for up to 30 days.'**
  String get diagnosticsDeleteSharedBody;

  /// No description provided for @diagnosticsSharedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shared diagnostics deletion requested.'**
  String get diagnosticsSharedDeleted;

  /// No description provided for @diagnosticsSharedDeletionPending.
  ///
  /// In en, this message translates to:
  /// **'Some deletion requests will retry when the app opens with a connection.'**
  String get diagnosticsSharedDeletionPending;

  /// No description provided for @workoutDurabilityRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Tonos could not check for a saved workout. Retry before starting another workout.'**
  String get workoutDurabilityRestoreWarning;

  /// No description provided for @workoutDurabilityDraftSaveWarning.
  ///
  /// In en, this message translates to:
  /// **'Your workout backup is not up to date. Keep Tonos open and retry so this workout can be resumed safely.'**
  String get workoutDurabilityDraftSaveWarning;

  /// No description provided for @workoutDurabilityProgressionWarning.
  ///
  /// In en, this message translates to:
  /// **'Your workout is saved, but plan progression is still pending. Retry when storage is available.'**
  String get workoutDurabilityProgressionWarning;

  /// No description provided for @databaseConfirmExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export private data?'**
  String get databaseConfirmExportTitle;

  /// No description provided for @databaseConfirmExportBody.
  ///
  /// In en, this message translates to:
  /// **'This backup is an unencrypted JSON file that can contain your workouts, nutrition, body metrics, profile, and preferences. Save it only to a location you trust.'**
  String get databaseConfirmExportBody;

  /// No description provided for @databaseContinueExport.
  ///
  /// In en, this message translates to:
  /// **'Export anyway'**
  String get databaseContinueExport;

  /// No description provided for @databaseExportFailedSafe.
  ///
  /// In en, this message translates to:
  /// **'The database export could not be created. Your app data is unchanged.'**
  String get databaseExportFailedSafe;

  /// No description provided for @databaseImportFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This import is too large. Choose a database backup smaller than 25 MB.'**
  String get databaseImportFileTooLarge;

  /// No description provided for @databaseImportBlockedSafe.
  ///
  /// In en, this message translates to:
  /// **'This database backup could not be imported. Your current app data is unchanged.'**
  String get databaseImportBlockedSafe;

  /// No description provided for @databaseImportFailedSafe.
  ///
  /// In en, this message translates to:
  /// **'The database import did not finish. Your current app data was kept safe.'**
  String get databaseImportFailedSafe;

  /// No description provided for @speedDialLogFood.
  ///
  /// In en, this message translates to:
  /// **'Log food'**
  String get speedDialLogFood;

  /// No description provided for @speedDialLogMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Log measurement'**
  String get speedDialLogMeasurement;

  /// No description provided for @healthTapToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log'**
  String get healthTapToLog;

  /// No description provided for @healthMetricInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a unique metric name and a short unit without spaces.'**
  String get healthMetricInvalid;

  /// No description provided for @healthMeasurementEntryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a plausible positive value using a supported unit.'**
  String get healthMeasurementEntryInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'es',
    'fr',
    'hi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'CA':
            return AppLocalizationsFrCa();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
