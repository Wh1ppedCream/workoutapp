// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent% শরীরের ওজন/সপ্তাহ';
  }

  @override
  String get dashboardExerciseFallback => 'ব্যায়াম';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    return '$equipment - $count বার';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total সম্পন্ন';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return '$bodyPart শরীরের হিটম্যাপ';
  }

  @override
  String get focusedSetsTitle => 'লক্ষ্যভিত্তিক সেট';

  @override
  String get bodyPartNeck => 'ঘাড়';

  @override
  String get bodyPartShoulders => 'কাঁধ';

  @override
  String get bodyPartChest => 'বুক';

  @override
  String get bodyPartCore => 'কোর';

  @override
  String get bodyPartUpperBack => 'উপরের পিঠ';

  @override
  String get bodyPartLowerBack => 'নিচের পিঠ';

  @override
  String get bodyPartBiceps => 'বাইসেপস';

  @override
  String get bodyPartTriceps => 'ট্রাইসেপস';

  @override
  String get bodyPartForearms => 'অগ্রবাহু';

  @override
  String get bodyPartHips => 'নিতম্ব';

  @override
  String get bodyPartHamstrings => 'হ্যামস্ট্রিং';

  @override
  String get bodyPartQuads => 'কোয়াড্রিসেপস';

  @override
  String get bodyPartCalves => 'পিণ্ডলি';

  @override
  String databaseSaveFile(String filename) {
    return '$filename সংরক্ষণ করুন';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename আপনার নির্বাচিত স্থানে সংরক্ষণ করা হয়েছে।';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (প্রোডাকশন)';
  }

  @override
  String dashboardDaysAgo(int count) {
    return '$count দিন আগে';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1স';

  @override
  String get workoutReportRangeOneMonthShort => '1মা';

  @override
  String get workoutReportRangeThreeMonthsShort => '3মা';

  @override
  String get workoutReportRangeSixMonthsShort => '6মা';

  @override
  String get workoutReportRangeOneYearShort => '1ব';

  @override
  String get workoutReportRangeAll => 'সব';

  @override
  String get workoutReportRangeOneWeek => '1 সপ্তাহ';

  @override
  String get workoutReportRangeOneMonth => '1 মাস';

  @override
  String get workoutReportRangeThreeMonths => '3 মাস';

  @override
  String get workoutReportRangeSixMonths => '6 মাস';

  @override
  String get workoutReportRangeOneYear => '1 বছর';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    return '$countটি ওয়ার্কআউট';
  }

  @override
  String workoutReportMinutesCount(int count) {
    return '$count মিনিট';
  }

  @override
  String workoutReportHoursCount(int count) {
    return '$count ঘণ্টা';
  }

  @override
  String workoutReportHoursMinutes(int hours, int minutes) {
    return '$hours ঘণ্টা $minutes মিনিট';
  }

  @override
  String get workoutReportMinuteShort => 'মিনিট';

  @override
  String get workoutReportHourShort => 'ঘণ্টা';

  @override
  String get workoutReportNoWorkoutsYet => 'এখনও কোনো ওয়ার্কআউট নেই';

  @override
  String get workoutReportNoTrainingTimeYet => 'এখনও কোনো প্রশিক্ষণের সময় নেই';

  @override
  String get workoutReportNoVolumeYet => 'এখনও কোনো ভলিউম লগ করা হয়নি';

  @override
  String get workoutReportNoWorkoutsBody => 'এই রিপোর্ট তৈরি শুরু করতে একটি ওয়ার্কআউট সম্পূর্ণ করুন।';

  @override
  String get workoutReportNoTrainingTimeBody => 'সম্পূর্ণ সেশনগুলোর মিনিট এখানে স্বয়ংক্রিয়ভাবে যোগ হবে।';

  @override
  String get workoutReportNoVolumeBody => 'ভলিউমের প্রবণতা তৈরি করতে সম্পূর্ণ সেটগুলোর ওজন লগ করুন।';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'ইন্টারফেস ও চেহারা';

  @override
  String get uiAppearanceSubtitle => 'Tonos-এর চেহারা এবং নিচের ট্যাবগুলোর আচরণ নিয়ন্ত্রণ করুন।';

  @override
  String get displaySettingsTitle => 'প্রদর্শন';

  @override
  String get displaySettingsSubtitle => 'দ্রুত ভিজ্যুয়াল পছন্দসমূহ।';

  @override
  String get darkModeTitle => 'ডার্ক মোড';

  @override
  String get darkModeSubtitle => 'অ্যাপের গাঢ় থিম ব্যবহার করুন।';

  @override
  String get replayOnboardingTitle => 'প্রাথমিক সেটআপ আবার দেখুন';

  @override
  String get replayOnboardingSubtitle => 'সেটআপ আবার খুলতে এটি চালু করুন। সম্পন্ন হলে এটি বন্ধ হয়ে যাবে।';

  @override
  String get weightUnitsTitle => 'ওজনের একক';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'ওয়ার্কআউটের ওজন এবং ভলিউম $unit-এ দেখান।';
  }

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSubtitle => 'Tonos যে ভাষা ব্যবহার করবে তা নির্বাচন করুন।';

  @override
  String get systemDefaultLanguage => 'সিস্টেমের ডিফল্ট';

  @override
  String get englishLanguage => 'English';

  @override
  String get canadianFrenchLanguage => 'Français (Canada)';

  @override
  String get navigationSettingsTitle => 'নেভিগেশন';

  @override
  String get navigationSettingsSubtitle => 'কোন নিচের ট্যাবগুলো দেখাবে এবং তাদের ক্রম নির্বাচন করুন।';

  @override
  String get editBottomTabsTitle => 'নিচের ট্যাব সম্পাদনা করুন';

  @override
  String get editBottomTabsSubtitle => 'সক্রিয় ট্যাবগুলোর ক্রম বদলান বা অব্যবহৃত ট্যাব লুকান।';

  @override
  String get displaySettingsTutorialTitle => 'প্রদর্শন সেটিংস';

  @override
  String get displaySettingsTutorialBody => 'ডার্ক মোড, ভাষা, প্রাথমিক সেটআপ আবার দেখা এবং পাউন্ড ও কিলোগ্রামের মধ্যে পরিবর্তন নিয়ন্ত্রণ করুন।';

  @override
  String get bottomTabsTutorialTitle => 'নিচের ট্যাব';

  @override
  String get bottomTabsTutorialBody => 'কোন নিচের ট্যাব দেখানো হবে এবং তাদের প্রদর্শনের ক্রম সম্পাদনা করুন।';

  @override
  String get onboardingPageWelcome => 'স্বাগতম';

  @override
  String get onboardingPageBasics => 'প্রাথমিক তথ্য';

  @override
  String get onboardingPageFocus => 'লক্ষ্য';

  @override
  String get onboardingPageGymProfile => 'জিম প্রোফাইল';

  @override
  String get onboardingPageEquipment => 'সরঞ্জাম';

  @override
  String get onboardingPageWorkoutPlan => 'ওয়ার্কআউট পরিকল্পনা';

  @override
  String get onboardingPagePlanOverview => 'পরিকল্পনার সংক্ষিপ্তসার';

  @override
  String get onboardingPageSummary => 'সারসংক্ষেপ';

  @override
  String get onboardingPreviousStepTooltip => 'আগের ধাপ';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'ধাপ $current / $total';
  }

  @override
  String get onboardingFinish => 'শেষ করুন';

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingFinishing => 'শেষ করা হচ্ছে...';

  @override
  String get onboardingFinishSetup => 'সেটআপ শেষ করুন';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingSkipSetupTitle => 'সেটআপ এড়িয়ে যাবেন?';

  @override
  String get onboardingSkipSetupBody => 'আপনি এখন অ্যাপের হোম পেজে যেতে পারেন এবং পরে সেটআপ শেষ করতে পারেন। সেটিংস পেজ থেকে প্রাথমিক সেটআপ আবারও খুলতে পারবেন।';

  @override
  String get onboardingCancel => 'বাতিল';

  @override
  String get onboardingConfirm => 'ঠিক আছে';

  @override
  String onboardingFinishError(String error) {
    return 'সেটআপ শেষ করা যায়নি: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Tonos-এ স্বাগতম';

  @override
  String get onboardingWelcomeSubtitle => 'দ্রুত সেটআপ আপনার ওয়ার্কআউট, পুষ্টি এবং অগ্রগতি অনুসরণকে ব্যক্তিগতকৃত করতে সাহায্য করে।';

  @override
  String get onboardingLanguageSelectionTitle => 'আপনার ভাষা নির্বাচন করুন';

  @override
  String get onboardingLanguageSelectionHelp => 'সেটআপের পরিবর্তন সঙ্গে সঙ্গে কার্যকর হয়। পরে সেটিংস থেকে এটি বদলাতে পারবেন।';

  @override
  String get onboardingTrainFeatureTitle => 'প্রেক্ষাপটসহ প্রশিক্ষণ নিন';

  @override
  String get onboardingTrainFeatureBody => 'ওয়ার্কআউটের পরামর্শ তৈরি করতে আপনার পছন্দ এবং ইতিহাস ব্যবহার করুন।';

  @override
  String get onboardingNutritionFeatureTitle => 'পুষ্টির লক্ষ্যকে সহায়তা করুন';

  @override
  String get onboardingNutritionFeatureBody => 'অ্যাপ থেকে আপনি যে মাত্রার পুষ্টি নির্দেশনা চান তা নির্ধারণ করুন।';

  @override
  String get onboardingProgressFeatureTitle => 'অগ্রগতি অনুসরণ করুন';

  @override
  String get onboardingProgressFeatureBody => 'সময়ের সঙ্গে আপনার প্রশিক্ষণ এবং পুষ্টির তথ্য সংযুক্ত রাখুন।';

  @override
  String get onboardingBasicsTitle => 'প্রাথমিক তথ্য দিন';

  @override
  String get onboardingBasicsSubtitle => 'এই তথ্যগুলো ঐচ্ছিক, তবে ভবিষ্যতের হিসাব করতে সাহায্য করে।';

  @override
  String get onboardingNameLabel => 'নাম';

  @override
  String get onboardingNameHint => 'আপনার নাম লিখুন';

  @override
  String get onboardingGenderLabel => 'লিঙ্গ';

  @override
  String get onboardingGenderMale => 'পুরুষ';

  @override
  String get onboardingGenderFemale => 'নারী';

  @override
  String get onboardingGenderOther => 'অন্যান্য';

  @override
  String get onboardingGenderPreferNotToSay => 'বলতে চাই না';

  @override
  String get onboardingDateOfBirthLabel => 'জন্মতারিখ';

  @override
  String get onboardingSelectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get onboardingHeightLabel => 'উচ্চতা';

  @override
  String get onboardingHeightHint => 'যেমন 5\'10\" বা 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => 'ওয়ার্কআউটের ওজনের একক';

  @override
  String get onboardingCurrentWeightLabel => 'বর্তমান ওজন';

  @override
  String get onboardingWeightHintPounds => 'যেমন 160';

  @override
  String get onboardingWeightHintKilograms => 'যেমন 72';

  @override
  String get onboardingPounds => 'পাউন্ড';

  @override
  String get onboardingKilograms => 'কিলোগ্রাম';

  @override
  String get onboardingFocusTitle => 'Tonos কী ব্যক্তিগতকৃত করবে?';

  @override
  String get onboardingFocusSubtitle => 'এখন যে অংশগুলো সেটআপ করতে চান সেগুলো বেছে নিন। পরে এটি বদলাতে পারবেন।';

  @override
  String get onboardingNutritionDataTitle => 'পুষ্টির তথ্য';

  @override
  String get onboardingNutritionDataPausedBody => 'এই অংশটি পুনর্গঠন করা হচ্ছে বলে পুষ্টি সেটআপ সাময়িকভাবে বন্ধ আছে।';

  @override
  String get onboardingLater => 'পরে';

  @override
  String get onboardingExerciseDataTitle => 'ব্যায়ামের তথ্য';

  @override
  String get onboardingExerciseDataBody => 'আপনার জিম প্রোফাইল এবং প্রথম ওয়ার্কআউট পরিকল্পনা সেটআপ করুন।';

  @override
  String get onboardingGymSpaceTitle => 'আপনি কোথায় ওয়ার্কআউট করেন?';

  @override
  String get onboardingGymSpaceSubtitle => 'শুরু করার জন্য একটি স্থান বেছে নিন। এর সরঞ্জাম ব্যায়ামের পরামর্শ এবং তৈরি করা ওয়ার্কআউটকে প্রভাবিত করবে।';

  @override
  String get onboardingEquipmentLoadError => 'সরঞ্জাম লোড করা যায়নি।';

  @override
  String get onboardingTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get onboardingGymCustomTitle => 'কাস্টমাইজ করা স্থান';

  @override
  String get onboardingGymCustomSubtitle => 'প্রতিটি উপলভ্য সরঞ্জাম বেছে নিয়ে নিজের প্রোফাইল তৈরি করুন।';

  @override
  String get onboardingGymCustomDefaultName => 'কাস্টম স্থান';

  @override
  String get onboardingGymSkipTitle => 'এই ধাপটি এড়িয়ে যান';

  @override
  String get onboardingGymSkipSubtitle => 'সাধারণ প্রোফাইল রাখুন এবং পরে আপনার সরঞ্জাম বেছে নিন।';

  @override
  String get onboardingGymGeneralName => 'সাধারণ';

  @override
  String get onboardingGymCommercialTitle => 'বাণিজ্যিক জিম';

  @override
  String get onboardingGymCommercialSubtitle => 'সব উপলভ্য সরঞ্জাম দিয়ে শুরু করুন, এরপর আপনার জিমে নেই এমনগুলো বাদ দিন।';

  @override
  String get onboardingGymCommercialDefaultName => 'বাণিজ্যিক জিম';

  @override
  String get onboardingGymHomeTitle => 'হোম জিম';

  @override
  String get onboardingGymHomeSubtitle => 'ফ্রি ওয়েট, ব্যান্ড, বেঞ্চ এবং বডিওয়েট সরঞ্জামসহ ব্যবহারিক হোম সেটআপ।';

  @override
  String get onboardingGymHomeDefaultName => 'হোম জিম';

  @override
  String get onboardingGymCalisthenicsTitle => 'ক্যালিসথেনিক্স';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'বার, রিং, ব্যান্ড এবং মৌলিক আনুষঙ্গিকসহ বডিওয়েট-কেন্দ্রিক সরঞ্জাম।';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'ক্যালিসথেনিক্স';

  @override
  String get onboardingGymPowerliftingTitle => 'পাওয়ারলিফটিং';

  @override
  String get onboardingGymPowerliftingSubtitle => 'প্লেট, পাওয়ার র্যাক এবং বেঞ্চসহ বারবেল-কেন্দ্রিক প্রশিক্ষণ স্থান।';

  @override
  String get onboardingGymPowerliftingDefaultName => 'পাওয়ারলিফটিং';

  @override
  String get onboardingGymFreeWeightsTitle => 'ফ্রি ওয়েট';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'ডাম্বেল, কেটলবেল, প্লেট, একটি বেঞ্চ এবং বডিওয়েট মুভমেন্ট।';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'ফ্রি ওয়েট';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'আপনার ওয়ার্কআউট স্থান পর্যালোচনা করুন';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Tonos এটি তৈরি করার আগে প্রোফাইলের নাম পরিবর্তন করুন বা সরঞ্জাম ঠিক করুন।';

  @override
  String get onboardingProfileNameLabel => 'প্রোফাইলের নাম';

  @override
  String get onboardingIncludedEquipmentTitle => 'অন্তর্ভুক্ত সরঞ্জাম';

  @override
  String get onboardingIncludedEquipmentBody => 'প্রোফাইল সক্রিয় থাকলে শুধুমাত্র এই সরঞ্জাম সমর্থনকারী ব্যায়ামগুলোর পরামর্শ দেওয়া হবে।';

  @override
  String get onboardingNoEquipmentSelected => 'এখনও কোনো সরঞ্জাম নির্বাচিত হয়নি।';

  @override
  String get onboardingReset => 'রিসেট করুন';

  @override
  String get onboardingEditProfile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'ওয়ার্কআউট স্থান সম্পাদনা করুন';

  @override
  String get onboardingSelectEquipmentError => 'অন্তত একটি সরঞ্জাম নির্বাচন করুন।';

  @override
  String get onboardingWorkoutPlanTitle => 'আপনার ওয়ার্কআউট পরিকল্পনা সেটআপ করুন';

  @override
  String get onboardingWorkoutPlanSubtitle => 'Tonos কীভাবে আপনার প্রথম পরিকল্পনাগুলো প্রস্তুত করবে তা নির্বাচন করুন। পরে যেকোনো সময় পরিকল্পনা যোগ, আর্কাইভ বা সম্পাদনা করতে পারবেন।';

  @override
  String get onboardingManualPlanTitle => 'নিজের পরিকল্পনা নিজে তৈরি করুন';

  @override
  String get onboardingManualPlanSubtitle => 'খালি পরিকল্পনা দিয়ে শুরু করুন, তারপর নিজে ব্যায়াম ও সেট যোগ করুন।';

  @override
  String get onboardingPremadePlanTitle => 'তৈরি করা ব্যায়ামের পরিকল্পনা ব্যবহার করুন';

  @override
  String get onboardingPremadePlanSubtitle => 'অন্তর্নির্মিত ফুল বডি, আপার/লোয়ার, পুশ-পুল-লেগস এবং শরীরের অংশভিত্তিক পরিকল্পনা দেখুন।';

  @override
  String get onboardingGeneratePlanTitle => 'ব্যায়ামের পরিকল্পনা তৈরি করুন';

  @override
  String get onboardingGeneratePlanSubtitle => 'কয়েকটি সেটআপ প্রশ্নের উত্তর দিন এবং Tonos-কে আপনার প্রোফাইলের জন্য কাস্টম পরিকল্পনা তৈরি করতে দিন।';

  @override
  String get onboardingSkipPlanTitle => 'এই ধাপটি এড়িয়ে যান';

  @override
  String get onboardingSkipPlanSubtitle => 'পরিকল্পনা যোগ না করেই শুরু করুন। পরে Train থেকে সেটআপ করতে পারবেন।';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা সক্রিয় পরিকল্পনায় যোগ করা হয়েছে।',
      one: '$countটি পরিকল্পনা সক্রিয় পরিকল্পনায় যোগ করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'আপনার পরিকল্পনা পর্যালোচনা করুন';

  @override
  String get onboardingReviewPlansSubtitle => 'এই পরিকল্পনাগুলো আপনার সক্রিয় পরিকল্পনায় যোগ করা হয়েছে। চালিয়ে যাওয়ার আগে যেকোনো পরিকল্পনা খুলে দেখুন বা ঠিক করুন।';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা সক্রিয় পরিকল্পনায় প্রস্তুত।',
      one: '$countটি পরিকল্পনা সক্রিয় পরিকল্পনায় প্রস্তুত।',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'পরিকল্পনার সংক্ষিপ্তসার এখনও লোড করা যায়নি।';

  @override
  String get onboardingNoAddedPlans => 'কোনো যোগ করা পরিকল্পনা পাওয়া যায়নি। পরিকল্পনা যোগ করতে ফিরে যান অথবা এই ধাপটি এড়িয়ে যান।';

  @override
  String get onboardingReadyTitle => 'শুরু করার জন্য প্রস্তুত';

  @override
  String get onboardingReadySubtitle => 'আপনার সেটআপ পর্যালোচনা করুন, তারপর Tonos-এ প্রবেশ করতে শেষ করুন।';

  @override
  String get onboardingSummaryName => 'নাম';

  @override
  String get onboardingSummaryGender => 'লিঙ্গ';

  @override
  String get onboardingSummaryDateOfBirth => 'জন্মতারিখ';

  @override
  String get onboardingSummaryHeight => 'উচ্চতা';

  @override
  String get onboardingSummaryWeight => 'ওজন';

  @override
  String get onboardingSummaryWorkoutUnits => 'ওয়ার্কআউটের একক';

  @override
  String get onboardingSummaryIncluded => 'অন্তর্ভুক্ত';

  @override
  String get onboardingSummaryGymProfile => 'জিম প্রোফাইল';

  @override
  String get onboardingSummaryEquipment => 'সরঞ্জাম';

  @override
  String get onboardingSummaryWorkoutPlans => 'ওয়ার্কআউট পরিকল্পনা';

  @override
  String get onboardingSummaryProfileSection => 'প্রোফাইল';

  @override
  String get onboardingSummaryTrainingSection => 'প্রশিক্ষণ সেটআপ';

  @override
  String get onboardingSummaryNutritionSection => 'পুষ্টির পছন্দ';

  @override
  String get onboardingSummaryDiet => 'খাদ্যাভ্যাস';

  @override
  String get onboardingSummaryProteinPreference => 'প্রোটিনের পছন্দ';

  @override
  String get onboardingIncludedNutrition => 'পুষ্টি সেটআপ';

  @override
  String get onboardingIncludedExercise => 'ব্যায়াম সেটআপ';

  @override
  String get onboardingIncludedBasicOnly => 'শুধু প্রাথমিক প্রোফাইল';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি নির্বাচিত',
      one: '$countটি নির্বাচিত',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা যোগ করা হয়েছে',
      one: '$countটি পরিকল্পনা যোগ করা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'তৈরি করা পরিকল্পনা নির্বাচিত';

  @override
  String get onboardingPlanSummaryGenerated => 'তৈরি করার বিকল্প নির্বাচিত';

  @override
  String get onboardingPlanSummarySkipped => 'এড়িয়ে যাওয়া হয়েছে';

  @override
  String get onboardingPlanSummaryManual => 'ম্যানুয়াল বিকল্প নির্বাচিত';

  @override
  String get onboardingPlanSummaryNotSelected => 'নির্বাচন করা হয়নি';

  @override
  String get onboardingNewPlan => 'নতুন পরিকল্পনা';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'নতুন পরিকল্পনা $number';
  }

  @override
  String get tabTrain => 'প্রশিক্ষণ';

  @override
  String get tabTrainSecondary => 'প্রশিক্ষণ 2';

  @override
  String get tabCatalog => 'ক্যাটালগ';

  @override
  String get tabLogbook => 'লগবুক';

  @override
  String get tabProgress => 'অগ্রগতি';

  @override
  String get tabProfile => 'প্রোফাইল';

  @override
  String get tabDashboard => 'ড্যাশবোর্ড';

  @override
  String get tabNutrition => 'পুষ্টি';

  @override
  String get tabNutritionLog => 'পুষ্টি লগ';

  @override
  String get tabCombinedHistory => 'সমন্বিত ইতিহাস';

  @override
  String get tabFormAndPosing => 'ফর্ম ও পোজিং';

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get profileSubtitle => 'Tonos ব্যক্তিগতকৃত করুন, প্রশিক্ষণের ডিফল্ট নিয়ন্ত্রণ করুন এবং আপনার তথ্য ঠিক রাখুন।';

  @override
  String get profileAccountSectionTitle => 'অ্যাকাউন্ট';

  @override
  String get profileAccountSectionSubtitle => 'আপনার পরিচয় এবং অ্যাপ-স্তরের চেহারা।';

  @override
  String get profileUserInformationTitle => 'ব্যবহারকারীর তথ্য';

  @override
  String get profileUserInformationSubtitle => 'নাম, শরীরের তথ্য এবং কার্যকলাপের প্রোফাইল।';

  @override
  String get profileUiAppearanceTitle => 'ইন্টারফেস ও চেহারা';

  @override
  String get profileUiAppearanceSubtitle => 'থিম, প্রাথমিক সেটআপ এবং নিচের ট্যাব সেটআপ।';

  @override
  String get profileGuidedTutorialsTitle => 'নির্দেশিত টিউটোরিয়াল';

  @override
  String get profileGuidedTutorialsSubtitle => 'ধাপে ধাপে নির্দেশনা আবার দেখুন এবং গাইড করা সাহায্য রিসেট করুন।';

  @override
  String get profileTrainingSectionTitle => 'প্রশিক্ষণ';

  @override
  String get profileTrainingSectionSubtitle => 'ব্যায়ামের ডিফল্ট এবং অগ্রগতি-সম্পর্কিত নিয়ন্ত্রণ।';

  @override
  String get profileGymWorkoutSettingsTitle => 'জিম ও ওয়ার্কআউট সেটিংস';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'ওয়ার্কআউট তৈরি, র‍্যাঙ্কিং, ফ্লো এবং সরঞ্জাম সংক্রান্ত যুক্তি।';

  @override
  String get profileProgressSettingsTitle => 'অগ্রগতির সেটিংস';

  @override
  String get profileProgressSettingsSubtitle => 'মাপজোক ও প্রবণতা অনুসরণের সেটআপ।';

  @override
  String get profileDataSectionTitle => 'তথ্য';

  @override
  String get profileDataSectionSubtitle => 'ডাটাবেস টুল, এক্সপোর্ট, ইমপোর্ট এবং রক্ষণাবেক্ষণ।';

  @override
  String get profileDatabaseSettingsTitle => 'ডাটাবেস সেটিংস';

  @override
  String get profileDatabaseSettingsSubtitle => 'ইমপোর্ট, এক্সপোর্ট, স্বাস্থ্য পরীক্ষা এবং রক্ষণাবেক্ষণ টুল।';

  @override
  String get profileNutritionSectionTitle => 'পুষ্টি';

  @override
  String get profileNutritionSectionSubtitle => 'এই অংশটি পুনর্গঠন করা হচ্ছে বলে পুষ্টির সেটিংস সাময়িকভাবে বন্ধ আছে।';

  @override
  String get profileDietNutritionSettingsTitle => 'খাদ্য ও পুষ্টির সেটিংস';

  @override
  String get profileDietNutritionSettingsSubtitle => 'পুষ্টির লক্ষ্য এবং পছন্দ পরে ফিরে আসবে।';

  @override
  String get profileLater => 'পরে';

  @override
  String get profileAccountTutorialTitle => 'অ্যাকাউন্ট সেটিংস';

  @override
  String get profileAccountTutorialBody => 'এখান থেকে আপনার ব্যক্তিগত তথ্য, প্রদর্শনের পছন্দ, ওজনের একক, প্রাথমিক সেটআপ, নিচের ট্যাব এবং নির্দেশিত টিউটোরিয়াল আপডেট করুন।';

  @override
  String get profileTrainingTutorialTitle => 'প্রশিক্ষণের সেটিংস';

  @override
  String get profileTrainingTutorialBody => 'জিম প্রোফাইল, তৈরির নিয়ম, শরীরের অংশের র‍্যাঙ্কিং, অগ্রগতির সেটিংস এবং অন্যান্য প্রশিক্ষণ ডিফল্ট নিয়ন্ত্রণ করুন।';

  @override
  String get profileDataTutorialTitle => 'তথ্য টুল';

  @override
  String get profileDataTutorialBody => 'ডাটাবেস সেটিংসে আপনার স্থানীয় ওয়ার্কআউট তথ্য এক্সপোর্ট, ইমপোর্ট, পরীক্ষা এবং রক্ষণাবেক্ষণ করা যায়।';

  @override
  String catalogLoadError(String error) {
    return 'ক্যাটালগ লোড করা যায়নি: $error';
  }

  @override
  String get catalogNoData => 'এখনও কোনো ক্যাটালগ তথ্য নেই।';

  @override
  String get catalogExerciseTitle => 'ব্যায়াম ক্যাটালগ';

  @override
  String get catalogMostUsedExercises => 'সবচেয়ে বেশি ব্যবহৃত ব্যায়াম';

  @override
  String get catalogNoExerciseHistory => 'আপনার সবচেয়ে সাধারণ ব্যায়াম এখানে দেখতে ওয়ার্কআউট সম্পন্ন করুন।';

  @override
  String get catalogTargetAnatomyTitle => 'লক্ষ্য অ্যানাটমি';

  @override
  String get catalogBodyparts => 'শরীরের অংশ';

  @override
  String get catalogMuscles => 'পেশি';

  @override
  String get catalogNoBodypartHistory => 'এখনও শরীরের অংশের কোনো ইতিহাস নেই।';

  @override
  String get catalogNoMuscleHistory => 'এখনও পেশির কোনো ইতিহাস নেই।';

  @override
  String get catalogExerciseTutorialTitle => 'ব্যায়াম ক্যাটালগ';

  @override
  String get catalogExerciseTutorialBody => 'আপনার সবচেয়ে বেশি ব্যবহৃত ব্যায়ামগুলো এখানে আগে দেখায়। পুরো ক্যাটালগ খুলতে, মুভমেন্ট খুঁজতে এবং ব্যায়ামের বিবরণ দেখতে কার্ডে ট্যাপ করুন।';

  @override
  String get catalogAnatomyTutorialTitle => 'লক্ষ্য অ্যানাটমি';

  @override
  String get catalogAnatomyTutorialBody => 'এটি আপনার সবচেয়ে বেশি প্রশিক্ষিত শরীরের অংশ ও পেশিগুলোর সারসংক্ষেপ। নির্দিষ্ট ব্যায়ামের তালিকার জন্য যেকোনো পাশে ট্যাপ করে অ্যানাটমি লাইব্রেরি খুলুন।';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার',
      one: '1 বার',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count সেট',
      one: '1 সেট',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'অনুগ্রহ করে অন্তত দুটি সক্রিয় ট্যাব রাখুন।';

  @override
  String get navEditorSavedMessage => 'নিচের ট্যাব সংরক্ষণ করা হয়েছে';

  @override
  String get navEditorTitle => 'নিচের ট্যাব সম্পাদনা করুন';

  @override
  String get navEditorSubtitle => 'নিচের বারে কী দেখাবে তা নির্বাচন করুন এবং সক্রিয় ট্যাবগুলোর ক্রম বদলান।';

  @override
  String get navEditorSave => 'ট্যাব সংরক্ষণ করুন';

  @override
  String get navEditorActiveTitle => 'সক্রিয় ট্যাব';

  @override
  String get navEditorActiveSubtitle => 'ক্রম বদলাতে টেনে নিন। প্রোফাইল সবসময় উপলভ্য থাকবে।';

  @override
  String get navEditorInactiveTitle => 'নিষ্ক্রিয় ট্যাব';

  @override
  String get navEditorInactiveSubtitle => 'আবার চাইলে যেকোনো সময় এগুলো চালু করুন।';

  @override
  String get navEditorNoInactiveTabs => 'কোনো নিষ্ক্রিয় ট্যাব নেই।';

  @override
  String get navEditorAlwaysShown => 'সবসময় দেখানো হয়';

  @override
  String get navEditorVisible => 'নিচের নেভিগেশনে দৃশ্যমান';

  @override
  String get navEditorHidden => 'নিচের নেভিগেশন থেকে লুকানো';

  @override
  String get trainTutorialSpacesTitle => 'Train-এ দুটি স্থান আছে';

  @override
  String get trainTutorialSpacesBody => 'সংক্ষিপ্তসারে ব্যবহার-প্রস্তুত ওয়ার্কআউট নিয়ন্ত্রণ সামনে থাকে। পরিকল্পনা অংশে আপনি সংরক্ষিত পরিকল্পনা দেখতে, তৈরি করতে এবং পরিচালনা করতে পারেন।';

  @override
  String get trainTutorialWeeklyTitle => 'সাপ্তাহিক সংক্ষিপ্তসার';

  @override
  String get trainTutorialWeeklyBody => 'এতে সাম্প্রতিক সময়ে আপনি কোন শরীরের অংশ প্রশিক্ষণ দিয়েছেন তা দেখা যায়। পুরো সাপ্তাহিক সেটের বিভাজন খুলতে ফোকাসড সেটের তালিকায় ট্যাপ করুন।';

  @override
  String get trainTutorialActivePlansTitle => 'সক্রিয় পরিকল্পনা';

  @override
  String get trainTutorialActivePlansBody => 'সক্রিয় পরিকল্পনাগুলো হলো যেসব রুটিন হাতের কাছে রাখতে চান। সংক্ষিপ্তসার ট্যাবে কোন পরিকল্পনা প্রস্তুত থাকবে তা বেছে নিতে পেন ব্যবহার করুন।';

  @override
  String get trainTutorialStartTitle => 'শুরু করুন বা অপ্টিমাইজ করুন';

  @override
  String get trainTutorialStartBody => 'ওয়ার্কআউট শুরু একটি খালি সেশন শুরু করে। অপ্টিমাইজ আপনার ইতিহাস, প্রোফাইলের সরঞ্জাম, ফোকাস এবং পুনরুদ্ধারের নিয়ম থেকে সেশন তৈরি করে।';

  @override
  String get trainTutorialProfilesTitle => 'জিম প্রোফাইল';

  @override
  String get trainTutorialProfilesBody => 'ভিন্ন স্থানে প্রশিক্ষণ নিলে প্রোফাইল বদলান, যাতে তৈরি করা ওয়ার্কআউট এবং ব্যায়াম বদল কেবল উপলভ্য সরঞ্জাম ব্যবহার করে।';

  @override
  String get trainSelectProfileFirst => 'অনুগ্রহ করে আগে একটি জিম প্রোফাইল নির্বাচন করুন।';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা তৈরি করা হয়েছে।',
      one: '1টি পরিকল্পনা তৈরি করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    return 'নতুন পরিকল্পনা $number';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'অপ্টিমাইজ করা ওয়ার্কআউট $date $time';
  }

  @override
  String get trainRestTitle => 'কিছু সময় বিশ্রাম নিন';

  @override
  String get trainRestBody => 'আপনার সাম্প্রতিক প্রশিক্ষণ ইতিমধ্যে কয়েকটি শরীরের অংশের সীমায় আছে, তাই অপ্টিমাইজ করা ওয়ার্কআউট পুনরুদ্ধারে অতিরিক্ত চাপ দেবে।';

  @override
  String get commonOkay => 'ঠিক আছে';

  @override
  String get trainNoEligibleExercises => 'এই প্রোফাইলের জন্য উপযুক্ত কোনো ব্যায়াম পাওয়া যায়নি।';

  @override
  String get trainAnotherWorkoutActive => 'আরেকটি ওয়ার্কআউট ইতিমধ্যে সক্রিয় আছে, তাই সেটি অপরিবর্তিত রাখা হয়েছে।';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'অপ্টিমাইজ করা ওয়ার্কআউট শুরু করা যায়নি: $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'অপ্টিমাইজ করা ওয়ার্কআউট শুরু হয়েছে। $countটি ব্যায়ামে এখনও ম্যানুয়াল ওজন প্রয়োজন।',
      one: 'অপ্টিমাইজ করা ওয়ার্কআউট শুরু হয়েছে। 1টি ব্যায়ামে এখনও ম্যানুয়াল ওজন প্রয়োজন।',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'অপ্টিমাইজ করা ওয়ার্কআউট $countটি নতুন ব্যায়ামের প্রারম্ভিক ওজন দিয়ে শুরু হয়েছে।',
      one: 'অপ্টিমাইজ করা ওয়ার্কআউট 1টি নতুন ব্যায়ামের প্রারম্ভিক ওজন দিয়ে শুরু হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get trainGymProfilesTooltip => 'জিম প্রোফাইল';

  @override
  String get trainOverviewTab => 'সংক্ষিপ্তসার';

  @override
  String get trainPlansTab => 'পরিকল্পনা';

  @override
  String get trainActivePlans => 'সক্রিয় পরিকল্পনা';

  @override
  String get trainEditActivePlans => 'সক্রিয় পরিকল্পনা সম্পাদনা করুন';

  @override
  String get trainSelectProfileForPlans => 'সক্রিয় পরিকল্পনা বেছে নিতে একটি জিম প্রোফাইল নির্বাচন করুন।';

  @override
  String get trainChooseActivePlans => 'এখানে কোন পরিকল্পনা দেখাবে তা বেছে নিতে পেনে ট্যাপ করুন।';

  @override
  String get trainSelectedPlansMissing => 'নির্বাচিত পরিকল্পনাগুলো আর উপলভ্য নেই। সেগুলো আপডেট করতে পেনে ট্যাপ করুন।';

  @override
  String get trainArchivedPlans => 'আর্কাইভ করা পরিকল্পনা';

  @override
  String get trainNoActivePlans => 'এখনও কোনো সক্রিয় পরিকল্পনা নেই। কোন পরিকল্পনা প্রস্তুত থাকবে তা বেছে নিতে সংক্ষিপ্তসারের সক্রিয় পরিকল্পনা কার্ডে পেন ব্যবহার করুন।';

  @override
  String get trainNoArchivedPlans => 'কোনো আর্কাইভ করা পরিকল্পনা নেই।';

  @override
  String get trainManagePlans => 'পরিকল্পনা পরিচালনা করুন';

  @override
  String get trainPremadePlans => 'তৈরি করা পরিকল্পনা';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আপনার পরিকল্পনায় কপি করার জন্য $countটি নির্বাচিত রুটিন উপলভ্য।',
      one: 'আপনার পরিকল্পনায় কপি করার জন্য 1টি নির্বাচিত রুটিন উপলভ্য।',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'তৈরি করা পরিকল্পনা দেখুন';

  @override
  String get trainGenerateCustomPlans => 'কাস্টম পরিকল্পনা তৈরি করুন';

  @override
  String get trainManuallyAddPlan => 'ম্যানুয়ালি পরিকল্পনা যোগ করুন';

  @override
  String get trainStartWorkout => 'ওয়ার্কআউট শুরু করুন';

  @override
  String get trainOptimize => 'অপ্টিমাইজ করুন';

  @override
  String get trainOptimizedSettings => 'অপ্টিমাইজ করা ওয়ার্কআউট সেটিংস';

  @override
  String planManagementDefaultName(int id) {
    return 'পরিকল্পনা $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'সক্রিয় পরিকল্পনা';

  @override
  String get planManagementActiveTutorialBody => 'এই পরিকল্পনাগুলো Train-এর সংক্ষিপ্তসারে দৃশ্যমান থাকে। কোনো পরিকল্পনা মুছে না ফেলে লুকাতে চাইলে আর্কাইভ ব্যবহার করুন।';

  @override
  String get planManagementArchivedTutorialTitle => 'আর্কাইভ করা পরিকল্পনা';

  @override
  String get planManagementArchivedTutorialBody => 'আর্কাইভ করা পরিকল্পনাগুলো এখনও সংরক্ষিত থাকে। সংক্ষিপ্তসারে ফেরত আনতে চাইলে এখানে যেকোনো পরিকল্পনা সক্রিয় করুন।';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return '$plan আপডেট করা যায়নি: $error';
  }

  @override
  String get planManagementTitle => 'পরিকল্পনা পরিচালনা করুন';

  @override
  String get planManagementLoadFailed => 'পরিকল্পনা লোড করা যায়নি';

  @override
  String get commonTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get planManagementIntro => 'আপনার Train সংক্ষিপ্তসারে কোন পরিকল্পনা প্রস্তুত থাকবে তা বেছে নিন। আর্কাইভ করা পরিকল্পনাগুলো সংরক্ষিত থাকে এবং যেকোনো সময় সক্রিয় করা যায়।';

  @override
  String get planManagementActiveSubtitle => 'Train সংক্ষিপ্তসারে দেখানো হয়।';

  @override
  String get planManagementNoActive => 'এখনও কোনো সক্রিয় পরিকল্পনা নেই। নিচের পরিকল্পনা সক্রিয় করে সংক্ষিপ্তসারে পিন করুন।';

  @override
  String get planManagementArchive => 'আর্কাইভ';

  @override
  String get planManagementArchivedSubtitle => 'সংরক্ষিত পরিকল্পনা যা সংক্ষিপ্তসারের বাইরে থাকে।';

  @override
  String get planManagementNoArchived => 'কোনো আর্কাইভ করা পরিকল্পনা নেই।';

  @override
  String get planManagementActivate => 'সক্রিয় করুন';

  @override
  String get planManagementAutomatic => 'স্বয়ংক্রিয় পরিকল্পনা';

  @override
  String get planManagementVisible => 'সংক্ষিপ্তসারে দৃশ্যমান';

  @override
  String get planManagementHidden => 'সংক্ষিপ্তসার থেকে লুকানো';

  @override
  String get presetsNoPlans => 'কোনো পরিকল্পনা পাওয়া যায়নি।';

  @override
  String get presetsNoProfile => 'কোনো প্রোফাইল নির্বাচিত হয়নি।';

  @override
  String get presetsLoadError => 'পরিকল্পনা লোড করতে ত্রুটি হয়েছে';

  @override
  String presetsShowMore(int count) {
    return 'আরও $countটি দেখান';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return 'আরও $countটি দেখান ($remainingটি বাকি)';
  }

  @override
  String planDefaultName(int number) {
    return 'পরিকল্পনা $number';
  }

  @override
  String get planArchive => 'আর্কাইভ';

  @override
  String get planActivate => 'সক্রিয় করুন';

  @override
  String get commonDelete => 'মুছুন';

  @override
  String get commonRename => 'নাম পরিবর্তন করুন';

  @override
  String get planActivated => 'পরিকল্পনা সক্রিয় করা হয়েছে।';

  @override
  String get planArchived => 'পরিকল্পনা আর্কাইভ করা হয়েছে।';

  @override
  String get planDeleteTitle => 'Preset মুছুন';

  @override
  String get planDeleteConfirmation => 'আপনি কি নিশ্চিত যে এই পরিকল্পনাটি মুছতে চান?';

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get planRenameTitle => 'পরিকল্পনার নাম পরিবর্তন করুন';

  @override
  String get planNameLabel => 'পরিকল্পনার নাম';

  @override
  String get optimizedTutorialBudgetTitle => 'সেশনের সীমা';

  @override
  String get optimizedTutorialBudgetBody => 'অপ্টিমাইজ করা ওয়ার্কআউট কতক্ষণ চলবে এবং প্রতিটি ব্যায়াম কতটি সেট পেতে পারে তা নির্ধারণ করুন।';

  @override
  String get optimizedTutorialRepsTitle => 'রেপ ও ওজন';

  @override
  String get optimizedTutorialRepsBody => 'এই পছন্দগুলো সেটের ধরন, লক্ষ্য রেপ এবং তৈরি করা ওজন কতটা সতর্ক হবে তা নিয়ন্ত্রণ করে।';

  @override
  String get optimizedTutorialFocusTitle => 'শরীরের অংশের ফোকাস';

  @override
  String get optimizedTutorialFocusBody => 'সংরক্ষিত র‍্যাঙ্কিং না বদলে পরবর্তী অপ্টিমাইজ করা ওয়ার্কআউটের জন্য শরীরের অংশ পছন্দ করুন বা এড়িয়ে চলুন।';

  @override
  String get commonReset => 'রিসেট করুন';

  @override
  String get optimizedTutorialResetBody => 'বর্তমান সেটআপ ঠিক মনে না হলে রিসেট এই পেজকে Tonos-এর ডিফল্টে ফিরিয়ে আনে।';

  @override
  String get optimizedTutorialActionsTitle => 'সংরক্ষণ বা শুরু';

  @override
  String get optimizedTutorialActionsBody => 'এখনই শুরু একবারের জন্য বর্তমান স্ক্রিনের মান ব্যবহার করে। সংরক্ষণ ভবিষ্যতের অপ্টিমাইজ করা ওয়ার্কআউটের জন্য সেটিংস রাখে।';

  @override
  String optimizedValidationError(int maxSets) {
    return '1-$maxSets এর মধ্যে সঠিক সময়কাল, লক্ষ্য রেপ এবং সেটের সীমা লিখুন।';
  }

  @override
  String get optimizedBudgetDescription => 'প্রতিটি সেটের জন্য 3 মিনিট এবং প্রতিটি ব্যায়াম শুরু করতে 5 মিনিট ধরে হিসাব করা হয়।';

  @override
  String get optimizedWorkoutDuration => 'ওয়ার্কআউটের সময়কাল';

  @override
  String get unitMinutesShort => 'মিনিট';

  @override
  String get optimizedMinimumSets => 'প্রতি ব্যায়ামে সর্বনিম্ন সেট';

  @override
  String get optimizedMaximumSets => 'প্রতি ব্যায়ামে সর্বোচ্চ সেট';

  @override
  String get unitSets => 'সেট';

  @override
  String get optimizedRepsWeightsTitle => 'রেপ ও ওজন';

  @override
  String get optimizedRepsWeightsDescription => 'উপলভ্য থাকলে ইতিহাসভিত্তিক শক্তির অনুমান ব্যবহার করে। Easy ও Medium, Hard-এর চেয়ে বেশি সতর্ক থাকে। নতুন ব্যায়ামে রক্ষণশীল প্রারম্ভিক অনুমান ব্যবহার হয়।';

  @override
  String get optimizedRepPattern => 'রেপের ধরন';

  @override
  String get repModeMixed => 'মিশ্র';

  @override
  String get repModePyramid => 'পিরামিড';

  @override
  String get repModeConsistent => 'একই রকম';

  @override
  String get optimizedTargetReps => 'লক্ষ্য রেপ';

  @override
  String get unitReps => 'রেপ';

  @override
  String get optimizedWeightIntensity => 'ওজনের তীব্রতা';

  @override
  String get intensityEasy => 'সহজ';

  @override
  String get intensityMedium => 'মাঝারি';

  @override
  String get intensityHard => 'কঠিন';

  @override
  String get optimizedBodypartFocusTitle => 'শরীরের অংশের ফোকাস';

  @override
  String get optimizedBodypartFocusDescription => 'এই নির্বাচনগুলো শুধু পরবর্তী অপ্টিমাইজ করা ওয়ার্কআউটের জন্য প্রযোজ্য। পছন্দ করতে একবার ট্যাপ করুন, এড়াতে দুবার ট্যাপ করুন এবং পরিষ্কার করতে আবার ট্যাপ করুন।';

  @override
  String get optimizedBodypartsUnavailable => 'শরীরের অংশ লোড করা যায়নি।';

  @override
  String get commonStartNow => 'এখনই শুরু করুন';

  @override
  String get commonSave => 'সংরক্ষণ করুন';

  @override
  String get generateTutorialIntroTitle => 'পরিকল্পনা তৈরি করুন';

  @override
  String get generateTutorialIntroBody => 'এই পেজ আপনার জিম প্রোফাইল এবং প্রশিক্ষণের পছন্দ ব্যবহার করে একটি পরিকল্পনা বা ভারসাম্যপূর্ণ সাপ্তাহিক পরিকল্পনার প্যাকেজ তৈরি করতে পারে।';

  @override
  String get generateWorkoutSetupTitle => 'ওয়ার্কআউট সেটআপ';

  @override
  String get generateTutorialSetupBody => 'সেশনের দৈর্ঘ্য, কতটি পরিকল্পনা তৈরি করবেন এবং প্রতিটি ব্যায়ামে অনুমোদিত সর্বোচ্চ সেট নির্ধারণ করুন।';

  @override
  String get generateTrainingFocusTitle => 'প্রশিক্ষণের ফোকাস';

  @override
  String get generateTutorialFocusBody => 'এখানে শরীরের অংশ পছন্দ করুন বা এড়িয়ে চলুন। সাম্প্রতিক প্রশিক্ষণ বিবেচনা করতে চাইলে শুধু তখনই 7-দিনের ইতিহাস টগল তৈরি করাকে প্রভাবিত করবে।';

  @override
  String get generateRepsWeightsTitle => 'রেপ ও ওজন';

  @override
  String get generateTutorialRepsBody => 'পিরামিড, মিশ্র বা একই রকম সেটের ধরন, লক্ষ্য রেপ এবং প্রারম্ভিক ওজনের তীব্রতা বেছে নিন।';

  @override
  String get generateSetAllocationTitle => 'সেট বণ্টন';

  @override
  String get generateTutorialAllocationBody => 'সেট সমানভাবে ছড়িয়ে দেওয়া হবে নাকি শরীরের অংশ বা পেশির র‍্যাঙ্কিং অনুসারে বেশি দেওয়া হবে তা বেছে নিন।';

  @override
  String get generateTutorialGenerateTitle => 'তৈরি করুন';

  @override
  String get generateTutorialGenerateBody => 'সবকিছু ঠিক মনে হলে পরিকল্পনা বা পরিকল্পনার প্যাকেজ তৈরি করুন। নতুন পরিকল্পনা পরে পর্যালোচনা ও সম্পাদনা করা যাবে।';

  @override
  String get generateValidationError => 'সঠিক সময়কাল, পরিকল্পনার সংখ্যা, সেটের সীমা এবং রেপের মান লিখুন।';

  @override
  String get generateNoViablePlans => 'বর্তমান সেটিংসে কোনো উপযুক্ত পরিকল্পনা তৈরি করা যায়নি।';

  @override
  String generateFailed(String error) {
    return 'পরিকল্পনা তৈরি করা যায়নি: $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'তৈরি করা পরিকল্পনা বাতিল করা যায়নি: $error';
  }

  @override
  String get generateIntroTitle => 'আপনার পরিকল্পনার সপ্তাহ তৈরি করুন';

  @override
  String get generateIntroBody => 'আপনার প্রোফাইল, ফোকাস এবং সীমা ব্যবহার করে একটি পরিকল্পনা বা ভারসাম্যপূর্ণ প্যাকেজ তৈরি করুন।';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা',
      one: '1টি পরিকল্পনা',
    );
    return '$_temp0';
  }

  @override
  String generateDurationPill(String minutes) {
    return '$minutes মিনিট';
  }

  @override
  String generateMaxSetsPill(String sets) {
    return 'সর্বোচ্চ $sets সেট';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plansটি পরিকল্পনা, $minutes মিনিট, সর্বোচ্চ $sets সেট';
  }

  @override
  String get generateSessionLength => 'সেশনের দৈর্ঘ্য';

  @override
  String get generateSessionLengthHelp => 'প্রতি সেটে 3 মিনিট + প্রতি ব্যায়ামে 5 মিনিট ধরে অনুমান করা হয়েছে।';

  @override
  String get generatePlansToCreate => 'তৈরি করার পরিকল্পনা';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'সাধারণত প্রতি সপ্তাহের প্রশিক্ষণের দিনের সমান হয়। সর্বোচ্চ $maxPlans।';
  }

  @override
  String get unitPlans => 'পরিকল্পনা';

  @override
  String get generateMaxSetsPerExercise => 'প্রতি ব্যায়ামে সর্বোচ্চ সেট';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return '$minSets-$maxSets সেট অনুমোদিত।';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferredটি পছন্দ, $avoidedটি এড়ানো, $history 7-দিনের ইতিহাস';
  }

  @override
  String get generateHistoryUsing => 'ব্যবহার করা হচ্ছে';

  @override
  String get generateHistoryNotUsing => 'ব্যবহার করা হচ্ছে না';

  @override
  String get generateUseRecentTraining => 'সাম্প্রতিক প্রশিক্ষণ ব্যবহার করুন';

  @override
  String get generateUseRecentTrainingBody => 'গত 7 দিনের কম প্রশিক্ষিত অংশগুলোর দিকে অগ্রাধিকার দিন।';

  @override
  String get generateBodypartFocusInstruction => 'পছন্দ করতে একবার, এড়াতে দুবার এবং পরিষ্কার করতে তৃতীয়বার ট্যাপ করুন।';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps রেপ, $intensity তীব্রতা';
  }

  @override
  String get generateMixedBody => '3 বা তার বেশি সেটে পিরামিড; ছোট কাজের জন্য স্থির।';

  @override
  String get generatePyramidBody => 'সর্বোচ্চ সেটে তৈরি করা কাজের ওজন ব্যবহার হয়।';

  @override
  String get generateConsistentBody => 'প্রতিটি সেটে একই রেপ ও প্রস্তাবিত ওজন।';

  @override
  String get generateTargetRepsHelp => 'পিরামিডের জন্য সর্বোচ্চ রেপ; অন্যথায় স্থির রেপ।';

  @override
  String get generateEasyBody => 'সবচেয়ে রক্ষণশীল ইতিহাস বা প্রারম্ভিক পরামর্শ।';

  @override
  String get generateMediumBody => 'ভারসাম্যপূর্ণ কাজের ওজনের পরামর্শ।';

  @override
  String get generateHardBody => 'সবচেয়ে ভারী পরামর্শ, তবু গোল করা এবং প্রচেষ্টাসচেতন।';

  @override
  String get generateRequirementBodyparts => 'শরীরের অংশের র‍্যাঙ্কিং';

  @override
  String get generateRequirementMuscles => 'পেশির র‍্যাঙ্কিং';

  @override
  String get generateRequirementEven => 'সমান কভারেজ';

  @override
  String get generateEvenCoverageTitle => 'সমান শরীরের অংশ কভারেজ';

  @override
  String get generateEvenCoverageBody => 'উপলভ্য শরীরের অংশজুড়ে কাজ বিস্তৃতভাবে ছড়িয়ে দিন।';

  @override
  String get generateBodypartRankingsTitle => 'শরীরের অংশের র‍্যাঙ্কিং ব্যবহার করুন';

  @override
  String get generateBodypartRankingsBody => 'উচ্চ র‍্যাঙ্কের শরীরের অংশকে পরিকল্পনায় বেশি কাজ দিন।';

  @override
  String get generateRankBodyparts => 'শরীরের অংশ র‍্যাঙ্ক করুন';

  @override
  String get generateMuscleRankingsTitle => 'পেশির র‍্যাঙ্কিং ব্যবহার করুন';

  @override
  String get generateMuscleRankingsBody => 'আপনার র‍্যাঙ্ক করা পেশির অগ্রাধিকার থেকে কাজ বণ্টন করুন।';

  @override
  String get generateRankMuscles => 'পেশি র‍্যাঙ্ক করুন';

  @override
  String get generateGenerating => 'তৈরি করা হচ্ছে...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা তৈরি করুন',
      one: 'পরিকল্পনা তৈরি করুন',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return '$requestedটির মধ্যে $generatedটি পরিকল্পনা তৈরি হয়েছে। বর্তমান সেটিংস বাকি পরিকল্পনাগুলো সীমিত করেছে।';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিকল্পনা তৈরি হয়েছে। প্রস্তুত হলে দেখুন।',
      one: 'তৈরি করা পরিকল্পনা যোগ করা হয়েছে। প্রস্তুত হলে দেখুন।',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return 'আরও $countটি';
  }

  @override
  String get generateStarterEstimatedBody => 'নতুন ব্যায়ামের জন্য প্রারম্ভিক ওজন অনুমান করা হয়েছে। প্রথম সেটের পরে প্রয়োজনমতো ঠিক করুন।';

  @override
  String get generateStarterUnavailableBody => 'নিরাপদ প্রারম্ভিক অনুমান এখনও না থাকায় কিছু ব্যায়ামে ম্যানুয়াল ওজন প্রয়োজন।';

  @override
  String get generateStarterDialogTitle => 'প্রারম্ভিক ওজন যোগ করা হয়েছে';

  @override
  String get generatePageTitle => 'পরিকল্পনা তৈরি করুন';

  @override
  String get generateDiscarding => 'বাতিল করা হচ্ছে...';

  @override
  String get generateReviewPlans => 'পরিকল্পনা পর্যালোচনা করুন';

  @override
  String get sessionTutorialCardsTitle => 'ব্যায়ামের কার্ড';

  @override
  String get sessionTutorialCardsBody => 'প্রতিটি কার্ডে একটি ব্যায়াম থাকে। ওজন ও রেপ সম্পাদনা করতে কার্ড খুলুন, তারপর সেট শেষ হলে টিক দিন।';

  @override
  String get sessionTutorialAddTitle => 'ব্যায়াম যোগ করুন';

  @override
  String get sessionTutorialAddBody => 'ওয়ার্কআউটের সময় ক্যাটালগ থেকে আরেকটি ব্যায়াম যোগ করতে চাইলে এই বোতাম ব্যবহার করুন।';

  @override
  String get sessionTutorialFinishTitle => 'ওয়ার্কআউট শেষ করুন';

  @override
  String get sessionTutorialFinishBody => 'শেষ হলে সেশন সম্পন্ন করুন, যাতে Tonos ওয়ার্কআউট সংরক্ষণ করে এবং আপনার ইতিহাস, বিশ্লেষণ ও অগ্রগতি উইজেট আপডেট করতে পারে।';

  @override
  String get sessionTimerTitle => 'ওয়ার্কআউট টাইমার';

  @override
  String get sessionTitle => 'ওয়ার্কআউট সেশন';

  @override
  String get sessionNoExercises => 'কোনো ব্যায়াম যোগ করা হয়নি।';

  @override
  String get sessionNeedCompletedSet => 'ওয়ার্কআউট শেষ করার আগে অন্তত একটি সেট সম্পন্ন করুন।';

  @override
  String sessionSaveFailed(String error) {
    return 'ওয়ার্কআউট সংরক্ষণ করা যায়নি। চলমান ওয়ার্কআউট এখনও উপলভ্য আছে। $error';
  }

  @override
  String get sessionFinishWorkout => 'ওয়ার্কআউট শেষ করুন';

  @override
  String get sessionResume => 'পুনরায় শুরু করুন';

  @override
  String get sessionExit => 'বেরিয়ে যান';

  @override
  String get sessionCompletedSaved => 'সম্পন্ন কাজ লগবুকে সংরক্ষণ করা হয়েছে।';

  @override
  String get sessionCancelled => 'ওয়ার্কআউট বাতিল করা হয়েছে।';

  @override
  String sessionEndFailed(String error) {
    return 'ওয়ার্কআউট শেষ করা যায়নি: $error';
  }

  @override
  String get sessionCancelQuestion => 'ওয়ার্কআউট বাতিল করবেন?';

  @override
  String get sessionCancelBody => 'এটি চলমান ওয়ার্কআউটকে ইতিহাসে না যোগ করে সরিয়ে দেবে।';

  @override
  String get sessionKeepWorkout => 'ওয়ার্কআউট রাখুন';

  @override
  String get sessionCancelWorkout => 'ওয়ার্কআউট বাতিল করুন';

  @override
  String get sessionEndQuestion => 'ওয়ার্কআউট শেষ করবেন?';

  @override
  String get sessionCancelDelete => 'বাতিল ও মুছুন';

  @override
  String get sessionEndSave => 'ওয়ার্কআউট শেষ ও সংরক্ষণ করুন';

  @override
  String get sessionRememberChoice => 'পছন্দ মনে রাখুন';

  @override
  String get sessionRememberChoiceBody => 'পরে জিম ও ওয়ার্কআউট সেটিংস থেকে এটি পরিবর্তন করুন।';

  @override
  String get sessionCompleteLoadError => 'সেশন লোড করতে ত্রুটি হয়েছে';

  @override
  String get sessionCompleteTitle => 'ওয়ার্কআউট সম্পন্ন';

  @override
  String get sessionMetricExercises => 'ব্যায়াম';

  @override
  String get sessionMetricSets => 'সেট';

  @override
  String get sessionMetricDuration => 'সময়কাল';

  @override
  String get sessionMetricVolume => 'ভলিউম';

  @override
  String get commonDone => 'সম্পন্ন';

  @override
  String get recordMonthly => 'মাসিক';

  @override
  String get recordAllTime => 'সর্বকালের';

  @override
  String get recordFirst => 'প্রথম রেকর্ড';

  @override
  String recordRepBest(int reps) {
    return '$reps রেপ সেরা';
  }

  @override
  String get recordVolumeBest => 'সেরা ভলিউম';

  @override
  String sessionEstimatedMax(String weight) {
    return 'ERM=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutesমি';
  }

  @override
  String durationHoursCompact(int hours) {
    return '$hoursঘ';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '$hoursঘ $minutesমি';
  }

  @override
  String get planUnsavedChangesTitle => 'অসংরক্ষিত পরিবর্তন';

  @override
  String get planDiscardChangesQuestion => 'পরিবর্তন বাতিল করবেন?';

  @override
  String get planDiscard => 'বাতিল করুন';

  @override
  String get planTutorialEditTitle => 'পরিকল্পনা সম্পাদনা করুন';

  @override
  String get planTutorialEditBody => 'পরিকল্পনার নাম পরিবর্তন, ব্যায়ামের ক্রম বদল, ব্যায়াম যোগ, মুভমেন্ট বদল এবং সেট পরিবর্তন করতে এটি ব্যবহার করুন।';

  @override
  String get planTutorialSummaryTitle => 'পরিকল্পনার সারসংক্ষেপ';

  @override
  String get planTutorialSummaryBody => 'পরিকল্পনা শুরুর আগে এটি আনুমানিক সময়, ভলিউম এবং লক্ষ্য করা প্রধান শরীরের অংশ দেখায়।';

  @override
  String get planTutorialExerciseCardsTitle => 'ব্যায়ামের কার্ড';

  @override
  String get planTutorialExerciseCardsBody => 'পরিকল্পিত সেট দেখতে ব্যায়ামের কার্ড খুলুন। সম্পাদনা মোডে ব্যায়াম বদলাতে বা সরাতে মেনু ব্যবহার করুন।';

  @override
  String get planTutorialStartOrSaveTitle => 'শুরু বা সংরক্ষণ করুন';

  @override
  String get planTutorialStartOrSaveBody => 'সেশন শুরু এই পরিকল্পনাকে ওয়ার্কআউট হিসেবে শুরু করে। সম্পাদনা মোডে এটি Preset সংরক্ষণে বদলে যায়, যাতে আপনার পরিবর্তন সংরক্ষিত হয়।';

  @override
  String get planGuideNameTitle => 'পরিকল্পনার নাম দিন';

  @override
  String get planGuideNameBody => 'এই পরিকল্পনাকে এমন একটি নাম দিন যা আপনি চিনবেন, যেমন আপার বডি বা দিন 1।';

  @override
  String get commonContinue => 'চালিয়ে যান';

  @override
  String get planGuideBrowseTitle => 'ব্যায়াম দেখুন';

  @override
  String get planGuideBrowseBody => 'এই পরিকল্পনার প্রথম ব্যায়াম বেছে নিতে + বোতামে ট্যাপ করুন।';

  @override
  String get planGuideWeightTitle => 'ওজন বেছে নিন';

  @override
  String get planGuideWeightBody => 'প্রথম সেটের জন্য প্রারম্ভিক ওজন লিখুন। বডিওয়েট ব্যায়ামের জন্য 0 ব্যবহার করুন।';

  @override
  String get planGuideWeightSet => 'ওজন নির্ধারণ করা হয়েছে';

  @override
  String get planGuideRepsTitle => 'রেপ বেছে নিন';

  @override
  String get planGuideRepsBody => 'এই সেটে আপনি কতটি পুনরাবৃত্তি করবেন তা লিখুন।';

  @override
  String get planGuideRepsSet => 'রেপ নির্ধারণ করা হয়েছে';

  @override
  String get planGuideAddSetTitle => 'আরও সেট যোগ করুন';

  @override
  String get planGuideAddSetBody => 'আরেকটি সেট লাগলে সেট যোগ করুন ব্যবহার করুন। নতুন সেট আগের সেটের মান দিয়ে শুরু হয়।';

  @override
  String get planGuideSaveTitle => 'আপনার পরিকল্পনা সংরক্ষণ করুন';

  @override
  String get planGuideSaveBody => 'এই পরিকল্পনা রাখতে এবং প্রাথমিক সেটআপের সংক্ষিপ্তসারে ফিরতে Preset সংরক্ষণে ট্যাপ করুন।';

  @override
  String planSaveFailed(String error) {
    return 'পরিকল্পনা সংরক্ষণ করা যায়নি। আগের সংস্করণ অপরিবর্তিত আছে। $error';
  }

  @override
  String get planOngoingWorkoutKept => 'আপনার চলমান ওয়ার্কআউট রাখা হয়েছে। এই পরিকল্পনা শুরু করার আগে সেটি শেষ করুন বা বাতিল করুন।';

  @override
  String get planDeleteBody => 'আপনি কি নিশ্চিত যে এই Preset মুছতে চান?';

  @override
  String get planDeletePreset => 'Preset মুছুন';

  @override
  String get planDisableAutomatic => 'স্বয়ংক্রিয় বন্ধ করুন';

  @override
  String get planMakeAutomatic => 'স্বয়ংক্রিয় করুন';

  @override
  String get planAutomaticSettings => 'স্বয়ংক্রিয় সেটিংস';

  @override
  String get planProgression => 'পরিকল্পনার অগ্রগতি';

  @override
  String get planNoExercises => 'এই Preset-এ কোনো ব্যায়াম নেই।';

  @override
  String get planSavePreset => 'Preset সংরক্ষণ করুন';

  @override
  String get planStartSession => 'সেশন শুরু করুন';

  @override
  String get commonName => 'নাম';

  @override
  String get commonBack => 'ফিরে যান';

  @override
  String get flowMethodWeight => 'ওজন';

  @override
  String get flowMethodReps => 'পুনরাবৃত্তি';

  @override
  String get flowMethodAddSet => 'সেট যোগ করুন';

  @override
  String get flowMethodDeleteSet => 'সেট মুছুন';

  @override
  String get flowAppDefaultTitle => 'অ্যাপের ডিফল্ট অগ্রগতি';

  @override
  String get flowProfileDefaultTitle => 'জিমের ডিফল্ট অগ্রগতি';

  @override
  String get flowPlanSubtitle => 'প্রতিটি ওয়ার্কআউটের পরে এই পরিকল্পনা কীভাবে এগোবে তা নির্ধারণ করুন।';

  @override
  String get flowAppDefaultSubtitle => 'নতুন জিম প্রোফাইলের প্রারম্ভিক অগ্রগতি ফ্লো নির্ধারণ করুন।';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return '$profileName-এ নতুন পরিকল্পনার প্রারম্ভিক অগ্রগতি ফ্লো নির্ধারণ করুন।';
  }

  @override
  String get flowThisGymProfile => 'এই জিম প্রোফাইল';

  @override
  String get flowManageMethods => 'কাজ পরিচালনা করুন';

  @override
  String get flowAddNewMethod => 'নতুন কাজ যোগ করুন';

  @override
  String get flowNewMethod => 'নতুন কাজ';

  @override
  String get flowFactor => 'গুণক';

  @override
  String get flowAmount => 'পরিমাণ';

  @override
  String get flowExplicit => 'নির্দিষ্ট';

  @override
  String get flowCopyFromSet => 'সেট থেকে কপি করুন';

  @override
  String get flowWeight => 'ওজন';

  @override
  String get flowReps => 'রেপ';

  @override
  String get flowSetIndex => 'সেট সূচক (-1 = শেষ)';

  @override
  String get flowDeleteLastSetBody => 'এই কাজটি শেষ সেট মুছে দেবে।';

  @override
  String get flowMethodNameRequired => 'কাজের নাম খালি রাখা যাবে না';

  @override
  String get flowManageActionsTooltip => 'অগ্রগতির কাজ পরিচালনা করুন';

  @override
  String get flowAddBranchTitle => 'একটি শাখা যোগ করুন';

  @override
  String get flowAddBranchSubtitle => 'পরবর্তী সফলতা বা ব্যর্থতা কোথায় নিয়ে যাবে তা বেছে নিন।';

  @override
  String get flowBranchFrom => 'এখান থেকে শাখা';

  @override
  String get flowSuccess => 'সফল';

  @override
  String get flowMiss => 'ব্যর্থ';

  @override
  String get flowAttachActionTitle => 'একটি অগ্রগতির কাজ যুক্ত করুন';

  @override
  String get flowAttachActionSubtitle => 'ফ্লোর একটি নোডে প্রতিটি ধরনের একটি সমন্বয় প্রয়োগ করুন।';

  @override
  String get flowApplyActionTo => 'কাজ প্রয়োগ করুন';

  @override
  String get flowProgressionAction => 'অগ্রগতির কাজ';

  @override
  String get flowAddAction => '+ কাজ';

  @override
  String get flowRemoveAction => '- কাজ';

  @override
  String get flowRemoveNode => '- নোড';

  @override
  String get commonEdit => 'সম্পাদনা করুন';

  @override
  String get rulesEditAppDefault => 'অ্যাপের ডিফল্ট নিয়ম সম্পাদনা করুন';

  @override
  String get rulesEditProfileDefault => 'প্রোফাইলের ডিফল্ট নিয়ম সম্পাদনা করুন';

  @override
  String get rulesAddAppDefault => 'অ্যাপের ডিফল্ট নিয়ম যোগ করুন';

  @override
  String get rulesAddProfileDefault => 'প্রোফাইলের ডিফল্ট নিয়ম যোগ করুন';

  @override
  String get rulesCopy => 'কপি করুন';

  @override
  String get rulesCopyIndex => 'সূচক কপি করুন';

  @override
  String get rulesDeleteLastSetBody => 'এটি শেষ সেট মুছে দেবে।';

  @override
  String get rulesNameRequired => 'নিয়মের নাম খালি রাখা যাবে না';

  @override
  String get rulesProfilesLowercase => 'প্রোফাইল';

  @override
  String get rulesPlansLowercase => 'পরিকল্পনা';

  @override
  String rulesAddToExistingTitle(String destination) {
    return 'বিদ্যমান $destination-এ যোগ করবেন?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return '\"$name\"-কে কি $countটি বিদ্যমান $destination-এ উপলভ্য করবেন? একই নামের বিদ্যমান নিয়ম এবং সব সংরক্ষিত অগ্রগতি ফ্লো অপরিবর্তিত থাকবে।';
  }

  @override
  String get rulesNotNow => 'এখন নয়';

  @override
  String rulesAddTo(String destination) {
    return '$destination-এ যোগ করুন';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'এই নিয়মটির জন্য বিদ্যমান কোনো $destination প্রয়োজন নেই।';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return '\"$name\" $countটি $destination-এ যোগ করা হয়েছে।';
  }

  @override
  String get rulesPropagationFailed => 'বিদ্যমান আইটেমে নিয়ম যোগ করা যায়নি।';

  @override
  String get rulesOptionsTooltip => 'নিয়মের বিকল্প';

  @override
  String get rulesPageTitle => 'ওয়ার্কআউট অগ্রগতির নিয়ম';

  @override
  String get rulesPageSubtitle => 'ওয়ার্কআউটের চেষ্টার পরে ওজন, রেপ এবং সেট কীভাবে বদলাবে তার পুনর্ব্যবহারযোগ্য নিয়ম তৈরি করুন।';

  @override
  String get rulesHowDefaultsTitle => 'ডিফল্ট কীভাবে কাজ করে';

  @override
  String get rulesHowDefaultsBody => 'অ্যাপের ডিফল্ট নতুন জিম প্রোফাইলে কপি হয়। প্রোফাইল ডিফল্ট নতুন পরিকল্পনায় কপি হয়, তাই পরের পরিবর্তনগুলো বিদ্যমান পরিকল্পনাকে অপ্রত্যাশিতভাবে বদলায় না।';

  @override
  String get rulesAppDefaultsTitle => 'অ্যাপজুড়ে ডিফল্ট';

  @override
  String get rulesAppDefaultsSubtitle => 'নতুন জিম প্রোফাইলের প্রারম্ভিক নিয়ম।';

  @override
  String get rulesNoAppDefaults => 'এখনও কোনো অ্যাপজুড়ে নিয়ম তৈরি করা হয়নি।';

  @override
  String get rulesAddApp => 'অ্যাপের নিয়ম যোগ করুন';

  @override
  String get rulesGymProfilesTitle => 'জিম প্রোফাইল';

  @override
  String get rulesGymProfilesSubtitle => 'প্রতিটি প্রোফাইল তার ডিফল্ট এবং পরিকল্পনার নিয়ম একসঙ্গে রাখে।';

  @override
  String get rulesNoProfiles => 'প্রোফাইল এবং পরিকল্পনার নিয়ম যোগ করতে একটি জিম প্রোফাইল তৈরি করুন।';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRulesটি প্রোফাইল নিয়ম • $planRulesটি পরিকল্পনা নিয়ম';
  }

  @override
  String get rulesProfileDefaultsTitle => 'প্রোফাইলের ডিফল্ট';

  @override
  String get rulesProfileDefaultsSubtitle => 'এই প্রোফাইলে নতুন পরিকল্পনার প্রারম্ভিক নিয়ম।';

  @override
  String get rulesNoProfileDefaults => 'এই প্রোফাইলে কোনো ডিফল্ট নিয়ম নেই।';

  @override
  String get rulesAddProfile => 'প্রোফাইলের নিয়ম যোগ করুন';

  @override
  String get rulesPlansTitle => 'পরিকল্পনা';

  @override
  String get rulesNoPlans => 'এই জিম প্রোফাইলে এখনও কোনো পরিকল্পনা নেই।';

  @override
  String get rulesPlanOnlySubtitle => 'শুধু এই পরিকল্পনায় ব্যবহৃত নিয়ম।';

  @override
  String get rulesNoPlanRules => 'এই পরিকল্পনায় নির্দিষ্ট কোনো অগ্রগতির নিয়ম নেই।';

  @override
  String get rulesAddPlan => 'পরিকল্পনার নিয়ম যোগ করুন';

  @override
  String get rulesAppDefaultsChip => 'অ্যাপের ডিফল্ট';

  @override
  String get rulesProfilesChip => 'প্রোফাইল';

  @override
  String get rulesPlansChip => 'পরিকল্পনা';

  @override
  String get rulesEditPlan => 'নিয়ম সম্পাদনা করুন';

  @override
  String get rulesAddPlanTitle => 'নিয়ম যোগ করুন';

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get flowPageTitle => 'ওয়ার্কআউট অগ্রগতির ফ্লো';

  @override
  String get flowPageSubtitle => 'ওয়ার্কআউটের ফলাফলের পরে অগ্রগতির কাজ কীভাবে প্রয়োগ হবে তা নির্ধারণকারী পথ সেট করুন।';

  @override
  String get flowHowCopiedTitle => 'ফ্লো কীভাবে কপি হয়';

  @override
  String get flowHowCopiedBody => 'অ্যাপের ফ্লো নতুন জিম প্রোফাইলের প্রারম্ভিক বিন্দু হয়। জিমের ফ্লো নতুন পরিকল্পনার প্রারম্ভিক বিন্দু হয়। পরের সম্পাদনা শুধু এখানে খোলা ফ্লোতেই সীমাবদ্ধ থাকে।';

  @override
  String get flowLoadError => 'ওয়ার্কআউট অগ্রগতির ফ্লো লোড করা যায়নি।';

  @override
  String get flowAppDefaultsSubtitle => 'নতুন জিম প্রোফাইলের প্রারম্ভিক ফ্লো।';

  @override
  String get flowAppDefaultEntry => 'অ্যাপের ডিফল্ট ফ্লো';

  @override
  String get flowGymProfilesSubtitle => 'প্রতিটি প্রোফাইলে ডিফল্ট এবং নিজস্ব পরিকল্পনার ফ্লো থাকে।';

  @override
  String get flowNoProfiles => 'প্রোফাইল এবং পরিকল্পনার ফ্লো সেট করতে একটি জিম প্রোফাইল তৈরি করুন।';

  @override
  String get flowNoSavedYet => 'এখনও কোনো ফ্লো সংরক্ষিত নেই';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodesটি নোড | $branchesটি শাখা | $actionsটি কাজ';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$countটি পরিকল্পনার ফ্লো উপলভ্য';
  }

  @override
  String get flowGymDefaultEntry => 'জিমের ডিফল্ট ফ্লো';

  @override
  String get gymSettingsTitle => 'জিম ও ওয়ার্কআউট সেটিংস';

  @override
  String get gymSettingsSubtitle => 'ওয়ার্কআউট তৈরি, বিশ্লেষণ এবং ওয়ার্কআউট-ফ্লোর আচরণ ঠিক করুন।';

  @override
  String get gymSettingsLogicTitle => 'ওয়ার্কআউট যুক্তি';

  @override
  String get gymSettingsLogicSubtitle => 'পরিকল্পনা এবং তৈরি করা ওয়ার্কআউটকে প্রভাবিত করে এমন সেটিংস।';

  @override
  String get gymSettingsWorkoutTitle => 'ওয়ার্কআউট সেটিংস';

  @override
  String get gymSettingsWorkoutSubtitle => 'ভলিউম সীমা, বিশ্লেষণের ডিফল্ট এবং প্রশিক্ষণ নিয়ন্ত্রণ।';

  @override
  String get gymSettingsExitTitle => 'চলমান ওয়ার্কআউট থেকে বের হওয়া';

  @override
  String get gymSettingsFlowToolsTitle => 'ফ্লো টুল';

  @override
  String get gymSettingsFlowToolsSubtitle => 'সংরক্ষিত অগ্রগতির পথ এবং কাজ পরিচালনা করুন।';

  @override
  String get gymSettingsFlowsSubtitle => 'অ্যাপের ডিফল্ট, জিম এবং পরিকল্পনার অগ্রগতির ফ্লো সম্পাদনা করুন।';

  @override
  String get gymSettingsRulesSubtitle => 'ওজন, রেপ এবং সেট অগ্রগতির নিয়ম পরিচালনা করুন।';

  @override
  String get gymExitAsk => 'প্রতিবার জিজ্ঞাসা করুন';

  @override
  String get gymExitDiscard => 'ওয়ার্কআউট বাতিল করুন';

  @override
  String get gymExitSave => 'শেষ ও সংরক্ষণ করুন';

  @override
  String get gymExitAskBody => 'সম্পন্ন কাজ শেষ করার আগে জিজ্ঞাসা করুন।';

  @override
  String get gymExitDiscardBody => 'সম্পন্ন কাজ সংরক্ষণ না করে বাতিল করুন।';

  @override
  String get gymExitSaveBody => 'সম্পন্ন কাজ লগবুকে সংরক্ষণ করুন।';

  @override
  String get commonAll => 'সব';

  @override
  String get catalogGuideChooseTitle => 'একটি ব্যায়াম বেছে নিন';

  @override
  String get catalogGuideChooseBody => 'নির্বাচন করতে যেকোনো ব্যায়ামের সারিতে ট্যাপ করুন। অনুসন্ধান বা ফিল্টার সঠিক মুভমেন্ট খুঁজতে সাহায্য করতে পারে।';

  @override
  String get catalogGuideAddTitle => 'পরিকল্পনায় যোগ করুন';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return '$exerciseName যোগ করতে এবং আপনার পরিকল্পনায় ফিরতে + এ ট্যাপ করুন।';
  }

  @override
  String get catalogGuideSearchTitle => 'ব্যায়াম খুঁজুন';

  @override
  String get catalogGuideSearchBody => 'কোন মুভমেন্ট চান তা জানা থাকলে ব্যায়ামের নাম দিয়ে খুঁজুন।';

  @override
  String get catalogFilters => 'ফিল্টার';

  @override
  String get catalogGuideFiltersBody => 'দ্রুত ক্যাটালগ ছোট করতে জিম প্রোফাইল, সরঞ্জাম, শরীরের অংশ বা পেশি দিয়ে ফিল্টার করুন।';

  @override
  String get catalogGuideRowsTitle => 'ব্যায়ামের সারি';

  @override
  String get catalogGuideRowsBody => 'প্রতিটি সারিতে সরঞ্জাম এবং একটি হিটম্যাপ দেখানো হয়। বিস্তারিত দেখতে হিটম্যাপে ট্যাপ করুন অথবা ব্যায়াম বেছে নিতে সারি নির্বাচন করুন।';

  @override
  String get catalogSelectedFilters => 'নির্বাচিত ফিল্টার';

  @override
  String get catalogUseWorkspaceProfile => 'ওয়ার্কস্পেস প্রোফাইল ব্যবহার করুন';

  @override
  String get catalogWorkspaceProfile => 'ওয়ার্কস্পেস প্রোফাইল';

  @override
  String get catalogEquipment => 'সরঞ্জাম';

  @override
  String get catalogFocusArea => 'ফোকাসের অংশ';

  @override
  String get catalogSpecificMuscle => 'নির্দিষ্ট পেশি';

  @override
  String get catalogPageTitle => 'ব্যায়াম ক্যাটালগ';

  @override
  String get catalogSearchExercises => 'ব্যায়াম খুঁজুন';

  @override
  String get catalogNoMatches => 'কোনো ব্যায়াম ফিল্টারের সঙ্গে মেলেনি।';

  @override
  String get catalogOpenExerciseInfo => 'ব্যায়ামের তথ্য খুলুন';

  @override
  String get commonClose => 'বন্ধ করুন';

  @override
  String get exerciseDetailOpenImage => 'ব্যায়ামের ছবি খুলুন';

  @override
  String get exerciseDetailTutorialTitle => 'ব্যায়ামের বিবরণ';

  @override
  String get exerciseDetailTutorialBody => 'শিটের শিরোনাম আপনি যে ব্যায়াম খুলেছেন সেটি। কাজ শেষ হলে এখান থেকে বন্ধ করুন।';

  @override
  String get exerciseDetailTabsTutorialTitle => 'বিবরণ, মেট্রিক, রেকর্ড';

  @override
  String get exerciseDetailTabsTutorialBody => 'নির্দেশনা, সেরা লিফট এবং সাম্প্রতিক ওয়ার্কআউট রেকর্ডের মধ্যে বদলাতে এই ট্যাবগুলো ব্যবহার করুন।';

  @override
  String get exerciseDetailContextTutorialTitle => 'ব্যায়ামের প্রেক্ষাপট';

  @override
  String get exerciseDetailContextTutorialBody => 'বিবরণ ট্যাবে ব্যায়ামের সরঞ্জাম, প্রশিক্ষিত শরীরের অংশ, পেশি এবং ফর্ম নোট দেখায়।';

  @override
  String get exerciseDetailSessionOpenFailed => 'ওয়ার্কআউট সেশন খোলা যায়নি।';

  @override
  String get exerciseDetailSessionNotFound => 'ওয়ার্কআউট সেশন পাওয়া যায়নি।';

  @override
  String get exerciseDetailNoEquipment => 'এই ব্যায়ামের জন্য কোনো সরঞ্জাম তালিকাভুক্ত নেই।';

  @override
  String get exerciseDetailTargetAnatomy => 'লক্ষ্য অ্যানাটমি';

  @override
  String get exerciseDetailBodyParts => 'শরীরের অংশ';

  @override
  String get exerciseDetailNoBodyParts => 'কোনো শরীরের অংশ তালিকাভুক্ত নেই।';

  @override
  String get exerciseDetailMuscles => 'পেশি';

  @override
  String get exerciseDetailNoMuscles => 'কোনো পেশি তালিকাভুক্ত নেই।';

  @override
  String get exerciseDetailSetup => 'সেটআপ';

  @override
  String get exerciseDetailNoSetup => 'কোনো সেটআপ নির্দেশনা দেওয়া হয়নি।';

  @override
  String get exerciseDetailExecution => 'করণপদ্ধতি';

  @override
  String get exerciseDetailNoExecution => 'কোনো করণপদ্ধতির নোট দেওয়া হয়নি।';

  @override
  String get exerciseDetailTips => 'পরামর্শ';

  @override
  String get exerciseDetailNoTips => 'কোনো অতিরিক্ত পরামর্শ নেই।';

  @override
  String get exerciseDetailFormGuide => 'ফর্ম গাইড';

  @override
  String get exerciseDetailOpenHeatmap => 'লক্ষ্য করা শরীরের হিটম্যাপ খুলুন';

  @override
  String get exerciseDetailNoHeatmap => 'লক্ষ্য করা শরীরের কোনো অংশ উপলভ্য নেই';

  @override
  String get exerciseDetailZoomHint => 'জুম করতে চিমটি দিন বা টানুন';

  @override
  String get exerciseDetailLoadingBestLifts => 'সেরা লিফট লোড হচ্ছে';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'আপনার সম্পন্ন সেটের রেকর্ড হিসাব করা হচ্ছে।';

  @override
  String get exerciseDetailMetricsUnavailable => 'মেট্রিক উপলভ্য নয়';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'সম্পন্ন সেটের রেকর্ড লোড করতে এই ব্যায়ামটি আবার খুলুন।';

  @override
  String get exerciseDetailNoBestLifts => 'এখনও কোনো সেরা লিফট নেই';

  @override
  String get exerciseDetailNoBestLiftsBody => 'রেপ সেরা অনুসরণ শুরু করতে এই ব্যায়ামের একটি ওজনযুক্ত সেট সম্পন্ন করুন।';

  @override
  String get exerciseDetailWeek => 'সপ্তাহ';

  @override
  String get exerciseDetailMonth => 'মাস';

  @override
  String get exerciseDetailAllTime => 'সর্বকাল';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return '$timeframe মেট্রিক';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'সর্বোচ্চ আনুমানিক 1RM';

  @override
  String get exerciseDetailVolumeBest => 'সেরা ভলিউম';

  @override
  String get exerciseDetailRepBests => 'রেপ সেরা';

  @override
  String get exerciseDetailRepBestsBody => 'প্রতিটি রেপ সংখ্যার জন্য সম্পন্ন সেরা ওজন';

  @override
  String exerciseDetailRanges(int count) {
    return '$countটি পরিসর';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'ব্যায়ামের ইতিহাস লোড করা যায়নি।';

  @override
  String get exerciseDetailNoHistory => 'এই ব্যায়ামের কোনো ইতিহাস নেই।';

  @override
  String get exerciseDetailPerformanceTrend => 'পারফরম্যান্স প্রবণতা';

  @override
  String get exerciseDetailBestWeight => 'সেরা ওজন';

  @override
  String get exerciseDetailEstimatedOneRm => 'আনুমানিক 1RM';

  @override
  String get exerciseDetailLoadingSessions => 'সেশন লোড হচ্ছে';

  @override
  String get exerciseDetailLoadMoreSessions => 'আরও 10টি সেশন লোড করুন';

  @override
  String get exerciseDetailResizeLabel => 'ব্যায়ামের বিবরণের আকার বদলান';

  @override
  String get exerciseDetailResizeHint => 'শিটের আকার বদলাতে উপরে বা নিচে টানুন';

  @override
  String get exerciseDetailTabDetails => 'বিবরণ';

  @override
  String get exerciseDetailTabMetrics => 'মেট্রিক';

  @override
  String get exerciseDetailTabRecords => 'রেকর্ড';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return '$countটি সম্পন্ন সেটসহ ওয়ার্কআউট খুলুন';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count সেট',
      one: '1 সেট',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return 'ERM $weight';
  }

  @override
  String get exerciseDetailReps => 'রেপ';

  @override
  String get exerciseDetailSetVolume => 'সেটের ভলিউম';

  @override
  String get exerciseDetailNoChartData => 'চার্ট দেখানোর জন্য এখনও সম্পন্ন সেটের রেকর্ড নেই।';

  @override
  String get exerciseDetailWeightAbbreviation => 'ওজ';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'আনু';

  @override
  String get exerciseDetailTopAbbreviation => 'সেরা';

  @override
  String exerciseDetailSectionLabel(String title) {
    return '$title বিভাগ';
  }

  @override
  String get logbookTutorialCalendarTitle => 'লগবুক ক্যালেন্ডার';

  @override
  String get logbookTutorialCalendarBody => 'ওয়ার্কআউটের ইতিহাস দেখতে M, 3M, Y এবং 4Y ব্যবহার করুন। ওই পরিসরের সেশন ও সারসংক্ষেপ পরিসংখ্যান দেখতে একটি দিন, সপ্তাহ, মাস বা বছর নির্বাচন করুন।';

  @override
  String get fullHistoryTitle => 'সব সেশন';

  @override
  String get fullHistoryLoadError => 'সংরক্ষিত সেশন লোড করা যায়নি।';

  @override
  String get fullHistoryEmpty => 'কোনো সেশন সংরক্ষিত নেই।';

  @override
  String fullHistorySessionSummary(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get weeklySetsTitle => 'সাপ্তাহিক সেটের সংক্ষিপ্তসার';

  @override
  String get weeklySetsLoadError => 'আপনার সাপ্তাহিক প্রশিক্ষণের সংক্ষিপ্তসার লোড করা যায়নি।';

  @override
  String get weeklySetsBodyParts => 'শরীরের অংশ';

  @override
  String get weeklySetsMuscles => 'পেশি';

  @override
  String get weeklySetsTotal => 'মোট সেট';

  @override
  String get weeklySetsTime => 'সময়';

  @override
  String get weeklySetsVolume => 'ভলিউম';

  @override
  String get weeklySetsNoBodyParts => 'এখনও শরীরের অংশের কোনো সেট নেই।';

  @override
  String get weeklySetsNoMuscles => 'এখনও পেশির কোনো সেট নেই।';

  @override
  String weeklySetsCount(String count) {
    return '$count সেট';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'সাপ্তাহিক সংক্ষিপ্তসার';

  @override
  String get weeklySetsTutorialOverviewBody => 'এটি হিটম্যাপসহ গত 7 দিনের মোট সেট, সময় এবং ভলিউমের সারসংক্ষেপ।';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'শরীরের অংশ বা পেশি';

  @override
  String get weeklySetsTutorialAnatomyBody => 'শরীরের অংশের সেট এবং পৃথক পেশির সেটের মধ্যে বদলান।';

  @override
  String get weeklySetsTutorialStatusTitle => 'সেটের অবস্থা';

  @override
  String get weeklySetsTutorialStatusBody => 'সাম্প্রতিক কাজ সুপারিশকৃত পরিসরের নিচে, ভেতরে না উপরে আছে তার ভিত্তিতে প্রতিটি সারির রং বদলায়। সংযুক্ত ব্যায়াম দেখতে সারিতে ট্যাপ করুন।';

  @override
  String get workoutDetailTutorialSummaryTitle => 'ওয়ার্কআউটের সারসংক্ষেপ';

  @override
  String get workoutDetailTutorialSummaryBody => 'মোট সেট, ভলিউম, সময়কাল, ব্যায়ামের সংখ্যা এবং এই ওয়ার্কআউটে কাজ করা শরীরের অংশ দেখুন।';

  @override
  String get workoutDetailTutorialExercisesTitle => 'ব্যায়ামের রেকর্ড';

  @override
  String get workoutDetailTutorialExercisesBody => 'প্রতিটি ব্যায়ামে ওই সেশনের সম্পন্ন সেট দেখা যায়। ব্যায়ামটি দেখতে বিবরণে ট্যাপ করুন।';

  @override
  String get workoutDetailTutorialEditTitle => 'সেশন সম্পাদনা করুন';

  @override
  String get workoutDetailTutorialEditBody => 'ওয়ার্কআউটের পরে সেট, রেপ বা ব্যায়াম ঠিক করতে হলে সম্পাদনা মোড ব্যবহার করুন।';

  @override
  String get workoutDetailTutorialReuseTitle => 'এই ওয়ার্কআউট আবার ব্যবহার করুন';

  @override
  String get workoutDetailTutorialReuseBody => 'ওয়ার্কআউটটি আবার করুন অথবা সম্পন্ন সেশনকে পুনর্ব্যবহারযোগ্য পরিকল্পনা হিসেবে সংরক্ষণ করুন।';

  @override
  String get workoutDetailDeleteTitle => 'সেশন মুছুন';

  @override
  String get workoutDetailDeleteBody => 'আপনি কি নিশ্চিত যে এই সেশন মুছতে চান?';

  @override
  String get workoutDetailDeleteFailed => 'এই সেশন মুছা যায়নি।';

  @override
  String get workoutDetailChangesSaved => 'পরিবর্তন সংরক্ষিত হয়েছে।';

  @override
  String get workoutDetailSaveFailed => 'পরিবর্তন সংরক্ষণ করা যায়নি। আগের সেশন অপরিবর্তিত আছে।';

  @override
  String get workoutDetailFinishCurrentFirst => 'এটি আবার করার আগে আপনার বর্তমান ওয়ার্কআউট শেষ করুন।';

  @override
  String get workoutDetailOngoingWorkoutKept => 'আপনার চলমান ওয়ার্কআউট রাখা হয়েছে। এটি আবার করার আগে সেটি শেষ করুন বা বাতিল করুন।';

  @override
  String get workoutDetailRepeatFailed => 'এই ওয়ার্কআউট আবার করা যায়নি।';

  @override
  String get workoutDetailSaveAsPlan => 'পরিকল্পনা হিসেবে সংরক্ষণ করুন';

  @override
  String get workoutDetailPlanName => 'পরিকল্পনার নাম';

  @override
  String workoutDetailPlanSaved(String name) {
    return '\"$name\" পরিকল্পনা হিসেবে সংরক্ষিত হয়েছে।';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'পরিকল্পনা সংরক্ষণ করা যায়নি।';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'ওয়ার্কআউট $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'অসংরক্ষিত পরিবর্তন';

  @override
  String get workoutDetailUnsavedBody => 'আপনার অসংরক্ষিত পরিবর্তন আছে। সেগুলো বাতিল করে বের হতে চান?';

  @override
  String get workoutDetailDiscard => 'বাতিল করুন';

  @override
  String get workoutDetailTitle => 'ওয়ার্কআউটের বিবরণ';

  @override
  String get workoutDetailStopEditing => 'সম্পাদনা বন্ধ করুন';

  @override
  String get workoutDetailEditSession => 'সেশন সম্পাদনা করুন';

  @override
  String get workoutDetailDeleteSession => 'সেশন মুছুন';

  @override
  String get workoutDetailLoadFailed => 'এই সেশন লোড করা যায়নি।';

  @override
  String get workoutDetailEmpty => 'এই সেশনে কোনো ব্যায়াম নেই।';

  @override
  String get workoutDetailSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get workoutDetailRepeat => 'ওয়ার্কআউট আবার করুন';

  @override
  String get workoutDetailPastWorkout => 'আগের ওয়ার্কআউট';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$countটি সম্পন্ন সেট';
  }

  @override
  String get workoutDetailVolume => 'ভলিউম';

  @override
  String get workoutDetailDuration => 'সময়কাল';

  @override
  String get workoutDetailExercises => 'ব্যায়াম';

  @override
  String get workoutDetailExerciseInfo => 'ব্যায়ামের তথ্য';

  @override
  String get workoutDetailBest => 'সেরা';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'ওয়ার্কআউট ক্যালেন্ডার লোড করা যায়নি।';

  @override
  String get logbookNoWorkouts => 'কোনো ওয়ার্কআউট লগ করা হয়নি';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ওয়ার্কআউট',
      one: '1টি ওয়ার্কআউট',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => 'আগের মাস';

  @override
  String get logbookNextMonth => 'পরের মাস';

  @override
  String get logbookPreviousThreeMonths => 'আগের 3 মাস';

  @override
  String get logbookNextThreeMonths => 'পরের 3 মাস';

  @override
  String get logbookPreviousYear => 'আগের বছর';

  @override
  String get logbookNextYear => 'পরের বছর';

  @override
  String logbookWeekShort(int week) {
    return 'স$week';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month, সপ্তাহ $week';
  }

  @override
  String get logbookWorkouts => 'ওয়ার্কআউট';

  @override
  String get logbookTotalTime => 'মোট সময়';

  @override
  String get logbookTotalVolume => 'মোট ভলিউম';

  @override
  String get logbookViewAllSessions => 'সব সেশন দেখুন';

  @override
  String logbookSessionSummary(String duration, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercisesটি ব্যায়াম',
      one: '1টি ব্যায়াম',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets সেট',
      one: '1 সেট',
    );
    return '$duration - $_temp0 - $_temp1 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '$hoursঘ';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutesমি';
  }

  @override
  String durationSeconds(int seconds) {
    return '$secondsসে';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursঘ $minutesমি';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutesমি $secondsসে';
  }

  @override
  String get dashboardHideSection => 'বিভাগ লুকান';

  @override
  String get dashboardAllSectionsShown => 'সব বিভাগ দেখানো হচ্ছে';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$countটি বিভাগ লুকানো';
  }

  @override
  String get dashboardShowHiddenSections => 'লুকানো বিভাগ দেখান';

  @override
  String get dashboardReset => 'ড্যাশবোর্ড রিসেট করুন';

  @override
  String get dashboardEmptyTitle => 'আপনার ড্যাশবোর্ড খালি';

  @override
  String get dashboardEmptyBody => 'প্রস্তুত হলে যেকোনো বিভাগ আবার যোগ করুন।';

  @override
  String get dashboardCustomize => 'ড্যাশবোর্ড কাস্টমাইজ করুন';

  @override
  String get dashboardSectionQuickActionsTitle => 'দ্রুত কাজ';

  @override
  String get dashboardSectionQuickActionsBody => 'একটি মাপজোক লগ করুন বা ওয়ার্কআউট শুরু করুন।';

  @override
  String get dashboardSectionTrainingTitle => 'প্রশিক্ষণের জন্য প্রস্তুত';

  @override
  String get dashboardSectionTrainingBody => 'আপনার জিম প্রোফাইল ও পরিকল্পনা নির্বাচন করুন এবং একটি সেশন শুরু করুন।';

  @override
  String get dashboardSectionNutritionTitle => 'পুষ্টির ড্যাশবোর্ড';

  @override
  String get dashboardSectionNutritionBody => 'বর্তমান ক্যালরি এবং ম্যাক্রো লক্ষ্য পর্যালোচনা করুন।';

  @override
  String get dashboardSectionDataRecordsTitle => 'তথ্য ও রেকর্ড';

  @override
  String get dashboardSectionDataRecordsBody => 'দৈনিক পুষ্টি এন্ট্রি পর্যালোচনা ও যোগ করুন।';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'সাপ্তাহিক ফোকাস';

  @override
  String get dashboardSectionWeeklyFocusBody => 'গত 7 দিনের শরীরের অংশ ও পেশির কাজ পর্যালোচনা করুন।';

  @override
  String get dashboardSectionWorkoutReportTitle => 'ওয়ার্কআউট রিপোর্ট';

  @override
  String get dashboardSectionWorkoutReportBody => 'সময়ের সঙ্গে ওয়ার্কআউটের সংখ্যা, সময় এবং ভলিউম তুলনা করুন।';

  @override
  String get dashboardSectionExerciseProgressTitle => 'ব্যায়ামের অগ্রগতি';

  @override
  String get dashboardSectionExerciseProgressBody => 'নির্বাচিত ব্যায়ামগুলোর শক্তির প্রবণতা অনুসরণ করুন।';

  @override
  String get dashboardSectionHistoryTitle => 'প্রশিক্ষণের ইতিহাস';

  @override
  String get dashboardSectionHistoryBody => 'সময়ের পরিসরজুড়ে ওয়ার্কআউটের মোট এবং ফোকাস তুলনা করুন।';

  @override
  String get dashboardSectionHealthTrendsTitle => 'স্বাস্থ্যের প্রবণতা';

  @override
  String get dashboardSectionHealthTrendsBody => 'শরীরের ওজন এবং বিভিন্ন মাপজোক অনুসরণ করুন।';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'সাম্প্রতিক ওয়ার্কআউট';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'সর্বশেষ সম্পন্ন ওয়ার্কআউট সেশন খুলুন।';

  @override
  String get dashboardSectionActivePlansTitle => 'সক্রিয় পরিকল্পনা';

  @override
  String get dashboardSectionActivePlansBody => 'যে পরিকল্পনাগুলো আপনি বেশি ব্যবহার করেন সেগুলো হাতের কাছে রাখুন।';

  @override
  String get dashboardSectionArchivedPlansTitle => 'আর্কাইভ করা পরিকল্পনা';

  @override
  String get dashboardSectionArchivedPlansBody => 'বর্তমানে সক্রিয় নয় এমন পরিকল্পনা দেখুন।';

  @override
  String get dashboardSectionPremadePlansTitle => 'তৈরি করা পরিকল্পনা';

  @override
  String get dashboardSectionPremadePlansBody => 'এই প্রোফাইলে যোগ করা যায় এমন রুটিন দেখুন।';

  @override
  String get dashboardSectionPlanToolsTitle => 'পরিকল্পনা টুল';

  @override
  String get dashboardSectionPlanToolsBody => 'একটি ভারসাম্যপূর্ণ পরিকল্পনা তৈরি করুন অথবা ম্যানুয়ালি তৈরি করুন।';

  @override
  String get dashboardSectionCatalogTitle => 'ব্যায়াম ক্যাটালগ';

  @override
  String get dashboardSectionCatalogBody => 'আপনার সবচেয়ে বেশি ব্যবহৃত ব্যায়াম এবং পুরো ক্যাটালগ খুলুন।';

  @override
  String get dashboardSectionAnatomyTitle => 'লক্ষ্য অ্যানাটমি';

  @override
  String get dashboardSectionAnatomyBody => 'আপনার সবচেয়ে বেশি প্রশিক্ষিত শরীরের অংশ ও পেশি পর্যালোচনা করুন।';

  @override
  String get dashboardSectionFallbackTitle => 'ড্যাশবোর্ড বিভাগ';

  @override
  String get dashboardSectionFallbackBody => 'একটি ড্যাশবোর্ড বিভাগ।';

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get dashboardDoneCustomizing => 'কাস্টমাইজ শেষ';

  @override
  String get dashboardQuickActions => 'দ্রুত কাজ';

  @override
  String get dashboardMeasurement => 'মাপজোক';

  @override
  String get dashboardResumeWorkout => 'ওয়ার্কআউট আবার শুরু করুন';

  @override
  String get dashboardStartWorkout => 'ওয়ার্কআউট শুরু করুন';

  @override
  String dashboardTodayAt(String time) {
    return 'আজ, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'সাম্প্রতিক ওয়ার্কআউট';

  @override
  String get dashboardViewAll => 'সব দেখুন';

  @override
  String get dashboardRecentWorkoutsFailed => 'সাম্প্রতিক ওয়ার্কআউট লোড করা যায়নি।';

  @override
  String get dashboardRecentWorkoutsEmpty => 'একটি ওয়ার্কআউট শেষ করলে এটি এখানে দেখা যাবে।';

  @override
  String get userInfoProfileUpdateNote => 'প্রোফাইল আপডেট';

  @override
  String get userInfoChangesSaved => 'পরিবর্তন সংরক্ষিত হয়েছে';

  @override
  String get userInfoSaveFailed => 'আপনার পরিবর্তন সংরক্ষণ করা যায়নি।';

  @override
  String get userInfoTitle => 'ব্যবহারকারীর তথ্য';

  @override
  String get userInfoSubtitle => 'অ্যাপের হিসাবের জন্য প্রাথমিক প্রোফাইল তথ্য উপলভ্য রাখুন।';

  @override
  String get userInfoIdentityTitle => 'পরিচয়';

  @override
  String get userInfoIdentitySubtitle => 'প্রাথমিক ব্যক্তিগত তথ্য।';

  @override
  String get userInfoName => 'নাম';

  @override
  String get userInfoNameHint => 'আপনার নাম লিখুন';

  @override
  String get userInfoGender => 'লিঙ্গ';

  @override
  String get userInfoDateOfBirth => 'জন্মতারিখ';

  @override
  String get userInfoDateHint => 'YYYY-MM-DD';

  @override
  String get userInfoBodyMetricsTitle => 'শরীরের মেট্রিক';

  @override
  String get userInfoBodyMetricsSubtitle => 'অগ্রগতি ও পুষ্টির অনুমানে ব্যবহৃত ঐচ্ছিক তথ্য।';

  @override
  String get userInfoHeight => 'উচ্চতা';

  @override
  String get userInfoHeightHint => 'যেমন 5\'10\" বা 178 cm';

  @override
  String get userInfoCurrentWeight => 'বর্তমান ওজন';

  @override
  String get userInfoWeightPoundsHint => 'যেমন 160';

  @override
  String get userInfoWeightKilogramsHint => 'যেমন 72';

  @override
  String get userInfoBodyFat => 'শরীরের চর্বির আনুমানিক %';

  @override
  String get userInfoActivityTitle => 'কার্যকলাপের প্রেক্ষাপট';

  @override
  String get userInfoActivitySubtitle => 'পরে পরামর্শ এবং স্বাস্থ্য অনুমানে ব্যবহৃত হয়।';

  @override
  String get userInfoWeightTrend => 'ওজনের প্রবণতা';

  @override
  String get userInfoAverageSteps => 'আনুমানিক গড় পদক্ষেপ';

  @override
  String get userInfoGenderMale => 'পুরুষ';

  @override
  String get userInfoGenderFemale => 'নারী';

  @override
  String get userInfoGenderOther => 'অন্যান্য';

  @override
  String get userInfoGenderPreferNotToSay => 'বলতে চাই না';

  @override
  String get userInfoTrendGaining => 'ওজন বাড়ছে';

  @override
  String get userInfoTrendLosing => 'ওজন কমছে';

  @override
  String get userInfoTrendMaintaining => 'ওজন ধরে রাখছি';

  @override
  String get userInfoTrendNotSure => 'নিশ্চিত নই';

  @override
  String get userInfoActivityLow => 'কম (0-5k)';

  @override
  String get userInfoActivityModerate => 'মাঝারি (5-15k)';

  @override
  String get userInfoActivityHigh => 'বেশি (15k+)';

  @override
  String get userInfoSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get tutorialsSettingsTitle => 'নির্দেশিত টিউটোরিয়াল';

  @override
  String get tutorialsSettingsSubtitle => 'দ্রুত মনে করিয়ে নিতে চাইলে ধাপে ধাপে নির্দেশনা আবার দেখুন।';

  @override
  String get tutorialsControlsTitle => 'টিউটোরিয়াল নিয়ন্ত্রণ';

  @override
  String get tutorialsControlsSubtitle => 'পরীক্ষা করছেন বা নতুন করে শুরু করছেন?';

  @override
  String get tutorialsResetAllTitle => 'সব টিউটোরিয়াল রিসেট করুন';

  @override
  String get tutorialsResetAllSubtitle => 'প্রতিটি নির্দেশিত টিউটোরিয়াল আবার উপলভ্য করে।';

  @override
  String get tutorialsResetAll => 'সব রিসেট করুন';

  @override
  String get tutorialsResetAllMessage => 'সব টিউটোরিয়াল রিসেট করা হয়েছে।';

  @override
  String get tutorialsHowItWorksTitle => 'টিউটোরিয়াল কীভাবে কাজ করে';

  @override
  String get tutorialsHowItWorksBody => 'টিউটোরিয়াল একবার দেখানো হয়, তারপর পথে বাধা হয় না। নির্দিষ্ট নির্দেশনা রিসেট করতে একটি বিভাগ বিস্তৃত করুন।';

  @override
  String get tutorialsMainTabsTitle => 'প্রধান ট্যাব';

  @override
  String get tutorialsMainTabsSubtitle => 'প্রতিটি প্রধান অংশের নির্দেশনা আবার দেখুন।';

  @override
  String get tutorialsWorkoutTitle => 'ওয়ার্কআউট';

  @override
  String get tutorialsWorkoutSubtitle => 'আপনার প্রথম সেশন লগ করার সাহায্য।';

  @override
  String get tutorialsPlansTitle => 'পরিকল্পনা ও ওয়ার্কআউট';

  @override
  String get tutorialsPlansSubtitle => 'পরিকল্পনা তৈরি, সম্পাদনা এবং ওয়ার্কআউটের বিবরণের সাহায্য আবার দেখুন।';

  @override
  String get tutorialsCatalogTitle => 'ক্যাটালগ ও অ্যানাটমি';

  @override
  String get tutorialsCatalogSubtitle => 'ব্যায়াম এবং লক্ষ্য অ্যানাটমির সাহায্য আবার দেখুন।';

  @override
  String get tutorialsProgressTitle => 'অগ্রগতি ও সেটিংস';

  @override
  String get tutorialsProgressSubtitle => 'অগ্রগতির বিবরণ এবং সেটিংস পেজের সাহায্য আবার দেখুন।';

  @override
  String tutorialsReplayTitle(String topic) {
    return '$topic টিউটোরিয়াল আবার দেখুন';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'পরের বার $topic খুললে দেখাবে।';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return '$topic টিউটোরিয়াল পরের বার আবার দেখাবে।';
  }

  @override
  String get tutorialsReset => 'রিসেট করুন';

  @override
  String get tutorialsTopicTrain => 'প্রশিক্ষণ';

  @override
  String get tutorialsTopicCatalog => 'ক্যাটালগ';

  @override
  String get tutorialsTopicLogbook => 'লগবুক';

  @override
  String get tutorialsTopicProgress => 'অগ্রগতি';

  @override
  String get tutorialsTopicProfile => 'প্রোফাইল';

  @override
  String get tutorialsTopicFirstWorkout => 'প্রথম ওয়ার্কআউট';

  @override
  String get tutorialsTopicGeneratePlans => 'পরিকল্পনা তৈরি করুন';

  @override
  String get tutorialsTopicOptimizedSettings => 'অপ্টিমাইজ করা ওয়ার্কআউট সেটিংস';

  @override
  String get tutorialsTopicPremadePlans => 'তৈরি করা পরিকল্পনা';

  @override
  String get tutorialsTopicPlanManagement => 'পরিকল্পনা পরিচালনা';

  @override
  String get tutorialsTopicPlanDetail => 'পরিকল্পনার বিবরণ';

  @override
  String get tutorialsTopicPlanBuilder => 'পরিকল্পনা নির্মাতা';

  @override
  String get tutorialsTopicWorkoutDetail => 'ওয়ার্কআউটের বিবরণ';

  @override
  String get tutorialsTopicExerciseCatalog => 'ব্যায়াম ক্যাটালগ';

  @override
  String get tutorialsTopicExerciseDetail => 'ব্যায়ামের বিবরণ';

  @override
  String get tutorialsTopicTargetAnatomy => 'লক্ষ্য অ্যানাটমি';

  @override
  String get tutorialsTopicBodypartDetail => 'শরীরের অংশের বিবরণ';

  @override
  String get tutorialsTopicMuscleDetail => 'পেশির বিবরণ';

  @override
  String get tutorialsTopicWeeklySets => 'সাপ্তাহিক সেটের সংক্ষিপ্তসার';

  @override
  String get tutorialsTopicExerciseProgress => 'ব্যায়ামের অগ্রগতি';

  @override
  String get tutorialsTopicMeasurementTrend => 'মাপজোকের প্রবণতা';

  @override
  String get tutorialsTopicGymProfile => 'জিম প্রোফাইল সম্পাদক';

  @override
  String get tutorialsTopicUiAppearance => 'ইন্টারফেস ও চেহারা';

  @override
  String get tutorialsTopicDatabaseSettings => 'ডাটাবেস সেটিংস';

  @override
  String get tutorialsTopicGuide => 'নির্দেশিত সাহায্য';

  @override
  String get anatomyLibraryTitle => 'ব্যায়ামের ফোকাস লাইব্রেরি';

  @override
  String get anatomyBodyParts => 'শরীরের অংশ';

  @override
  String get anatomyMuscles => 'পেশি';

  @override
  String get anatomyLoadFailed => 'অ্যানাটমি ফিল্টার লোড করা যায়নি।';

  @override
  String get anatomySearchLabel => 'শরীরের অংশ বা পেশি খুঁজুন';

  @override
  String get anatomyNoBodyParts => 'আপনার অনুসন্ধানের সঙ্গে কোনো শরীরের অংশ মেলেনি।';

  @override
  String get anatomyNoMuscles => 'আপনার অনুসন্ধানের সঙ্গে কোনো পেশি মেলেনি।';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ব্যায়াম',
      one: '1টি ব্যায়াম',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => 'অ্যানাটমি খুঁজুন';

  @override
  String get anatomyTutorialSearchBody => 'নির্দিষ্ট ব্যায়ামের বিকল্প চাইলে শরীরের অংশ বা একটি নির্দিষ্ট পেশি খুঁজুন।';

  @override
  String get anatomyTutorialListsTitle => 'শরীরের অংশ ও পেশি';

  @override
  String get anatomyTutorialListsBody => 'ট্যাব বদলান, তারপর সংযুক্ত ব্যায়াম, সাম্প্রতিক মোট সেট এবং সুপারিশকৃত সেটের সীমা দেখতে যেকোনো সারিতে ট্যাপ করুন।';

  @override
  String anatomyTargetExercises(String name) {
    return '$name ব্যায়াম';
  }

  @override
  String get anatomyBodypartLoadFailed => 'এই শরীরের অংশ লোড করা যায়নি।';

  @override
  String get anatomyMuscleLoadFailed => 'এই পেশি লোড করা যায়নি।';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return '$name-এর সুপারিশকৃত সেট আপডেট করা হয়েছে।';
  }

  @override
  String get anatomySaveFailed => 'পরিবর্তন সংরক্ষণ করা যায়নি।';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সংযুক্ত ব্যায়াম',
      one: '1টি সংযুক্ত ব্যায়াম',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => 'সম্পন্ন (7 দিন)';

  @override
  String get anatomySetsLastSevenDays => 'গত 7 দিনের সেট';

  @override
  String anatomySetUnits(String count) {
    return '$count সেট';
  }

  @override
  String get anatomyRecommended => 'সুপারিশকৃত';

  @override
  String get anatomyNotSet => 'নির্ধারিত নয়';

  @override
  String anatomySetRange(String min, String max) {
    return '$min-$max সেট';
  }

  @override
  String get anatomyAssociatedMuscles => 'সম্পর্কিত পেশি';

  @override
  String get anatomyRelatedBodyParts => 'সম্পর্কিত শরীরের অংশ';

  @override
  String get anatomyNoMuscleLinks => 'এই শরীরের অংশের জন্য এখনও কোনো পেশি সংযোগ যোগ করা হয়নি।';

  @override
  String get anatomyNoBodyPartLinks => 'এই পেশির জন্য এখনও কোনো শরীরের অংশের সংযোগ যোগ করা হয়নি।';

  @override
  String get anatomyExercises => 'ব্যায়াম';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'বর্তমানে $name-এর সঙ্গে কোনো ব্যায়াম সংযুক্ত নেই।';
  }

  @override
  String get anatomyNoEquipment => 'কোনো সরঞ্জাম তালিকাভুক্ত নেই';

  @override
  String get anatomyNoMusclesListed => 'কোনো পেশি তালিকাভুক্ত নেই';

  @override
  String get anatomyNoBodyPartsListed => 'কোনো শরীরের অংশ তালিকাভুক্ত নেই';

  @override
  String anatomyOpenedFrom(String name) {
    return '$name থেকে খোলা হয়েছে';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'এই পেশির জন্য র‍্যাঙ্ক $rank - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'অ্যানাটমির বিবরণ';

  @override
  String get anatomyTutorialBodypartDetailBody => 'হেডারে সাম্প্রতিক সেট, সুপারিশকৃত সেটের সীমা এবং সম্পর্কিত অ্যানাটমির সংযোগ দেখা যায়।';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'পেশির বিবরণ';

  @override
  String get anatomyTutorialMuscleDetailBody => 'হেডারে সাম্প্রতিক সেট, সুপারিশকৃত সেটের সীমা এবং সম্পর্কিত শরীরের অংশ দেখা যায়।';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'সংযুক্ত ব্যায়াম';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'এগুলো এই লক্ষ্যের সঙ্গে সংযুক্ত ব্যায়াম। পূর্ণ ব্যায়ামের বিবরণ খুলতে একটিতে ট্যাপ করুন।';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'এই পেশিকে কতটা সরাসরি প্রশিক্ষণ দেয় তার ভিত্তিতে ব্যায়াম র‍্যাঙ্ক করা হয়। পূর্ণ বিবরণ দেখতে একটিতে ট্যাপ করুন।';

  @override
  String get settingsWorkoutTitle => 'ওয়ার্কআউট সেটিংস';

  @override
  String get settingsWorkoutSubtitle => 'অ্যাপ কীভাবে অ্যানাটমি, প্রশিক্ষণ পক্ষপাত এবং ভলিউম লক্ষ্য বোঝে তা ঠিক করুন।';

  @override
  String get settingsTrainingBiasTitle => 'প্রশিক্ষণের পক্ষপাত';

  @override
  String get settingsTrainingBiasSubtitle => 'তৈরি করা পরিকল্পনা এবং অপ্টিমাইজ করা ওয়ার্কআউটে ব্যবহৃত নিয়ন্ত্রণ।';

  @override
  String get settingsBodyPartRankings => 'শরীরের অংশের র‍্যাঙ্কিং';

  @override
  String get settingsBodyPartRankingsSubtitle => 'কোন শরীরের অংশ বেশি কাজ পাবে তা অগ্রাধিকার দিন।';

  @override
  String get settingsMuscleRankings => 'পেশির র‍্যাঙ্কিং';

  @override
  String get settingsMuscleRankingsSubtitle => 'অ্যানাটমি মডেলের ভেতর নির্দিষ্ট পেশিকে অগ্রাধিকার দিন।';

  @override
  String get settingsVolumeBoundaries => 'ভলিউমের সীমা';

  @override
  String get settingsVolumeBoundariesSubtitle => 'শরীরের অংশ ও পেশির জন্য সুপারিশকৃত সাপ্তাহিক পরিসর নির্ধারণ করুন।';

  @override
  String get settingsExerciseDefinitionsTitle => 'ব্যায়ামের সংজ্ঞা';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'অ্যাপে ব্যবহৃত অ্যানাটমি ও ব্যায়ামের তথ্য রক্ষণাবেক্ষণ করুন।';

  @override
  String get settingsAnatomyMapping => 'শরীরের অংশ / পেশির ম্যাপিং';

  @override
  String get settingsAnatomyMappingSubtitle => 'প্রতিটি শরীরের অংশে কোন পেশি অন্তর্ভুক্ত তা নির্বাচন করুন।';

  @override
  String get settingsExerciseSetAllocation => 'ব্যায়ামের সেট বণ্টন';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'প্রতিটি ব্যায়াম পেশি ও শরীরের অংশে কীভাবে অবদান রাখে তা পর্যালোচনা করুন।';

  @override
  String get settingsExerciseEditor => 'ব্যায়াম সম্পাদক';

  @override
  String get settingsExerciseEditorSubtitle => 'ব্যায়ামের নাম, বিবরণ, সরঞ্জাম এবং ম্যাপিং আপডেট করুন।';

  @override
  String get commonCopy => 'কপি করুন';

  @override
  String get commonImport => 'ইমপোর্ট করুন';

  @override
  String get commonExport => 'এক্সপোর্ট করুন';

  @override
  String get databaseExportTitle => 'ডাটাবেস এক্সপোর্ট করুন';

  @override
  String get databaseImportTitle => 'ডাটাবেস ইমপোর্ট করুন';

  @override
  String get databasePasteJson => 'এখানে JSON পেস্ট করুন';

  @override
  String get databaseCopied => 'ক্লিপবোর্ডে কপি করা হয়েছে';

  @override
  String databaseExportFailed(String error) {
    return 'এক্সপোর্ট ব্যর্থ হয়েছে: $error';
  }

  @override
  String get databaseImportSucceeded => 'ইমপোর্ট সফল হয়েছে';

  @override
  String databaseImportFailed(String error) {
    return 'ইমপোর্ট ব্যর্থ হয়েছে: $error';
  }

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get nutritionSettingsTitle => 'ডায়েট ও পুষ্টি সেটিংস';

  @override
  String get nutritionSettingsSubtitle => 'পুষ্টির লক্ষ্য এবং খাবার-সম্পর্কিত পছন্দ কনফিগার করুন।';

  @override
  String get nutritionCurrentGoals => 'বর্তমান লক্ষ্য';

  @override
  String get nutritionGoals => 'লক্ষ্য';

  @override
  String get nutritionGoalsSubtitle => 'পুষ্টি ট্র্যাকিংয়ে ব্যবহৃত লক্ষ্য নির্ধারণ করুন।';

  @override
  String get nutritionManualGoals => 'নিজে পুষ্টির লক্ষ্য নির্ধারণ করুন';

  @override
  String get nutritionManualGoalsSubtitle => 'ক্যালোরি, ম্যাক্রো এবং গুরুত্বপূর্ণ পুষ্টি উপাদান নিজে লিখুন।';

  @override
  String get nutritionGoalsSaved => 'লক্ষ্য সংরক্ষিত হয়েছে';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'ক্যালোরি: $calories / প্রোটিন: $protein / কার্বস: $carbs / ফ্যাট: $fat / ফাইবার: $fiber / চিনি: $sugar / স্যাচুরেটেড ফ্যাট: $satFat / সোডিয়াম: $sodium';
  }

  @override
  String get progressSettingsTitle => 'অগ্রগতি সেটিংস';

  @override
  String get progressSettingsSubtitle => 'শরীরের পরিমাপ ও ট্রেন্ড-ট্র্যাকিং সেটআপ পরিচালনা করুন।';

  @override
  String get progressMeasurements => 'পরিমাপ';

  @override
  String get progressMeasurementsSubtitle => 'সময়ের সঙ্গে যে শরীরের মেট্রিক ট্র্যাক করতে চান তা কনফিগার করুন।';

  @override
  String get progressMeasurementLibrary => 'পরিমাপ লাইব্রেরি';

  @override
  String get progressMeasurementLibrarySubtitle => 'ওজন, উচ্চতা, শরীরের পরিমাপ এবং কাস্টম মেট্রিক পরিচালনা করুন।';

  @override
  String get nutritionManualGoalsTitle => 'ম্যানুয়াল পুষ্টির লক্ষ্য';

  @override
  String get nutritionManualGoalsPageSubtitle => 'ক্যালোরি, ম্যাক্রো এবং পুষ্টির লক্ষ্য নিজে নির্ধারণ করুন।';

  @override
  String get nutritionSaveGoals => 'লক্ষ্য সংরক্ষণ করুন';

  @override
  String get nutritionSaving => 'সংরক্ষণ করা হচ্ছে...';

  @override
  String get nutritionStartDate => 'শুরুর তারিখ';

  @override
  String get nutritionGoalStarts => 'লক্ষ্য শুরু';

  @override
  String get nutritionCaloriesAndMacros => 'ক্যালোরি ও ম্যাক্রো';

  @override
  String get nutritionAdditionalNutrients => 'অতিরিক্ত পুষ্টি উপাদান';

  @override
  String get nutritionCalories => 'ক্যালোরি (kcal)';

  @override
  String get nutritionProtein => 'প্রোটিন (g)';

  @override
  String get nutritionCarbs => 'কার্বস (g)';

  @override
  String get nutritionFat => 'ফ্যাট (g)';

  @override
  String get nutritionFiber => 'ফাইবার (g)';

  @override
  String get nutritionSugar => 'চিনি (g)';

  @override
  String get nutritionSatFat => 'স্যাচুরেটেড ফ্যাট (g)';

  @override
  String get nutritionSodium => 'সোডিয়াম (mg)';

  @override
  String get nutritionEnterNumber => 'একটি সংখ্যা দিন';

  @override
  String get nutritionNumberAtLeastZero => '0 বা তার বেশি হতে হবে';

  @override
  String rankingsSaved(String target) {
    return '$target র‍্যাঙ্কিং সংরক্ষিত হয়েছে';
  }

  @override
  String get rankingsSave => 'র‍্যাঙ্কিং সংরক্ষণ করুন';

  @override
  String rankingsTitle(String target) {
    return '$target র‍্যাঙ্কিং';
  }

  @override
  String rankingsHero(String target) {
    return 'তৈরি প্রশিক্ষণে যেটিকে অগ্রাধিকার দিতে চান, $target-কে সেই ক্রমে টেনে আনুন।';
  }

  @override
  String get rankingsNoBodyParts => 'কোনো শরীরের অংশ সংজ্ঞায়িত নেই';

  @override
  String get rankingsNoMuscles => 'কোনো পেশি সংজ্ঞায়িত নেই';

  @override
  String rankingsLoadError(String target, String error) {
    return '$target লোড করা যায়নি: $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get rankingsRank => 'র‍্যাঙ্ক';

  @override
  String get mappingTitle => 'অ্যানাটমি ম্যাপিং';

  @override
  String get mappingHero => 'পেশিকে শরীরের অংশের সঙ্গে যুক্ত করুন, যাতে হিটম্যাপ, অ্যানালিটিক্স এবং তৈরি ওয়ার্কআউট একমত থাকে।';

  @override
  String get mappingSaved => 'ম্যাপিং সংরক্ষিত হয়েছে';

  @override
  String mappingSaveFailed(String error) {
    return 'সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get mappingSelectedBodyPart => 'নির্বাচিত শরীরের অংশ';

  @override
  String get mappingBodyPart => 'শরীরের অংশ';

  @override
  String get mappingChooseLinkedMuscles => 'যুক্ত পেশি বেছে নিন';

  @override
  String get mappingLinkedMuscles => 'যুক্ত পেশি';

  @override
  String get mappingChooseLinkedSubtitle => 'এই শরীরের অংশের অন্তর্ভুক্ত প্রতিটি পেশি নির্বাচন করুন।';

  @override
  String mappingLinkedCount(int count) {
    return 'বর্তমানে $countটি পেশি যুক্ত আছে।';
  }

  @override
  String get mappingNoMuscles => 'কোনো পেশি সংজ্ঞায়িত নেই।';

  @override
  String get mappingNoLinkedMuscles => 'এখনও কোনো পেশি যুক্ত নেই। কিছু যোগ করতে সম্পাদনায় ট্যাপ করুন।';

  @override
  String get volumeMaintenance => 'রক্ষণাবেক্ষণ';

  @override
  String get volumeMinEffective => 'সর্বনিম্ন কার্যকর';

  @override
  String get volumeMaxAdaptive => 'সর্বোচ্চ অভিযোজনযোগ্য';

  @override
  String get volumeMaxRecoverable => 'সর্বোচ্চ পুনরুদ্ধারযোগ্য';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'শরীরের অংশের সীমা লোড করা যায়নি: $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'পেশির সীমা লোড করা যায়নি: $error';
  }

  @override
  String get volumeBodyPartSaved => 'শরীরের অংশের সীমা সংরক্ষিত হয়েছে';

  @override
  String get volumeMuscleSaved => 'পেশির সীমা সংরক্ষিত হয়েছে';

  @override
  String get volumeInvalidNumbers => 'বৈধ সংখ্যা দিন';

  @override
  String get volumeBodyParts => 'শরীরের অংশ';

  @override
  String get volumeMuscles => 'পেশি';

  @override
  String get volumeBodyPartTitle => 'শরীরের অংশের ভলিউম';

  @override
  String get volumeBodyPartSubtitle => 'সাপ্তাহিক অ্যানালিটিক্স এবং ওয়ার্কআউট তৈরিতে ব্যবহৃত সাপ্তাহিক লক্ষ্য পরিসর নির্ধারণ করুন।';

  @override
  String get volumeMuscleTitle => 'পেশির ভলিউম';

  @override
  String get volumeMuscleSubtitle => 'স্বতন্ত্র পেশির জন্য সাপ্তাহিক লক্ষ্য পরিসর সূক্ষ্মভাবে ঠিক করুন।';

  @override
  String get volumeSelection => 'নির্বাচন';

  @override
  String get volumeRecommendedRange => 'প্রস্তাবিত পরিসর';

  @override
  String get volumeRecommendedRangeSubtitle => 'সংখ্যাগুলো প্রতি সপ্তাহের সেট ইউনিট।';

  @override
  String get volumeSaveBoundaries => 'সীমা সংরক্ষণ করুন';

  @override
  String get nutritionDashboardTitle => 'পুষ্টি ড্যাশবোর্ড';

  @override
  String nutritionDashboardError(String error) {
    return 'পুষ্টি লোড করা যায়নি: $error';
  }

  @override
  String get nutritionMenuTitle => 'পুষ্টি মেনু';

  @override
  String get nutritionLogFood => 'খাবার লগ করুন';

  @override
  String get nutritionTrackMeasurement => 'পরিমাপ ট্র্যাক করুন';

  @override
  String get nutritionMeasuredItems => 'পরিমাপ করা আইটেম';

  @override
  String get nutritionTodayRecords => 'আজকের রেকর্ড';

  @override
  String get nutritionGoalsMenu => 'পুষ্টির লক্ষ্য';

  @override
  String get measurementWeight => 'ওজন';

  @override
  String get measurementHips => 'নিতম্ব';

  @override
  String get measurementShoulders => 'কাঁধ';

  @override
  String get measurementCalves => 'পিণ্ডলি';

  @override
  String get measurementTrackNew => 'নতুন পরিমাপ ট্র্যাক করুন';

  @override
  String get barcodeScannerTitle => 'বারকোড স্ক্যান করুন';

  @override
  String get barcodeSwitchCamera => 'ক্যামেরা বদলান';

  @override
  String get barcodeTorchOn => 'টর্চ চালু';

  @override
  String get barcodeTorchOff => 'টর্চ বন্ধ';

  @override
  String get barcodeTorchUnavailable => 'এই ডিভাইসে টর্চ উপলভ্য নয়';

  @override
  String get barcodeAlignHint => 'ফ্রেমের মধ্যে বারকোডটি সারিবদ্ধ করুন';

  @override
  String get progressTutorialWorkoutReportTitle => 'ওয়ার্কআউট রিপোর্ট';

  @override
  String get progressTutorialWorkoutReportBody => 'এটি বিভিন্ন সময়সীমায় ওয়ার্কআউটের সংখ্যা, প্রশিক্ষণের সময় ও ভলিউম ট্র্যাক করে। গ্রাফে কী দেখাবে বদলাতে একটি মেট্রিকে ট্যাপ করুন।';

  @override
  String get progressTutorialExerciseProgressTitle => 'ব্যায়ামের অগ্রগতি';

  @override
  String get progressTutorialExerciseProgressBody => 'নির্বাচিত ব্যায়ামের শক্তির ট্রেন্ড ট্র্যাক করুন। এই ড্যাশবোর্ডে ব্যায়াম যোগ বা সরাতে সম্পাদনা টাইল ব্যবহার করুন।';

  @override
  String get progressTutorialHealthTrendsTitle => 'স্বাস্থ্য ট্রেন্ড';

  @override
  String get progressTutorialHealthTrendsBody => 'এখানে শরীরের ওজন ও কাস্টম পরিমাপ লগ করুন, তারপর সময়ের সঙ্গে সেগুলো কীভাবে বদলায় দেখুন।';

  @override
  String get measurementNewTitle => 'নতুন পরিমাপ';

  @override
  String get measurementPresets => 'প্রিসেট';

  @override
  String get measurementCustom => 'কাস্টম';

  @override
  String get measurementPresetType => 'প্রিসেটের ধরন';

  @override
  String get measurementVariation => 'ভিন্নতা';

  @override
  String get measurementWakeUp => 'জাগার সময়';

  @override
  String get measurementBedtime => 'ঘুমাতে যাওয়ার সময়';

  @override
  String get measurementOverall => 'সামগ্রিক';

  @override
  String get measurementValueWeight => 'ওজন';

  @override
  String get measurementUnits => 'ইউনিট';

  @override
  String get measurementFeet => 'পা';

  @override
  String get measurementInches => 'ইঞ্চি';

  @override
  String get measurementCentimeters => 'সেন্টিমিটার';

  @override
  String get measurementWithPump => 'পাম্পসহ';

  @override
  String get measurementWithoutPump => 'পাম্প ছাড়া';

  @override
  String get measurementName => 'পরিমাপের নাম';

  @override
  String get measurementNameHint => 'বুকের মাপ, বিশ্রামের হৃদস্পন্দন...';

  @override
  String get measurementValue => 'মান';

  @override
  String get measurementUnit => 'ইউনিট';

  @override
  String get measurementNote => 'নোট';

  @override
  String get measurementOptional => 'ঐচ্ছিক';

  @override
  String get measurementSaveNew => 'নতুন পরিমাপ সংরক্ষণ করুন';

  @override
  String get measurementCustomRequired => 'একটি কাস্টম নাম, মান এবং ইউনিট দিন';

  @override
  String measurementDefinitionNotFound(String name) {
    return '$name-এর সংজ্ঞা পাওয়া যায়নি';
  }

  @override
  String get measurementInvalidValue => 'একটি বৈধ সংখ্যাসূচক মান দিন';

  @override
  String get measurementHeight => 'উচ্চতা';

  @override
  String get measurementForearm => 'ফোরআর্ম';

  @override
  String get measurementArm => 'বাহু';

  @override
  String get measurementNeck => 'ঘাড়';

  @override
  String get measurementChest => 'বুক';

  @override
  String get measurementWaist => 'কোমর';

  @override
  String get measurementThigh => 'উরু';

  @override
  String get measurementInstructionsForearm => 'আপনার ফোরআর্মের সবচেয়ে চওড়া অংশ ঘিরে মাপুন।';

  @override
  String get measurementInstructionsArm => 'আপনার বাইসেপের সবচেয়ে চওড়া অংশ ঘিরে মাপুন।';

  @override
  String get measurementInstructionsNeck => 'ফিতাটি গলার চারপাশে সোজা থাকে এমন জায়গায় মাপুন।';

  @override
  String get measurementInstructionsShoulder => 'সাইড ডেল্টয়েডের চারপাশে ফিতাটি সোজা রাখুন।';

  @override
  String get measurementInstructionsChest => 'বগলের নিচে এবং নিপল লাইনের উপরে মাপুন।';

  @override
  String get measurementInstructionsWaist => 'নাভির চারপাশে মাপুন।';

  @override
  String get measurementInstructionsHip => 'আপনার গ্লুটসের সবচেয়ে চওড়া অংশ ঘিরে মাপুন।';

  @override
  String get measurementInstructionsThigh => 'আপনার উরুর সবচেয়ে চওড়া অংশ ঘিরে মাপুন।';

  @override
  String get measurementInstructionsCalf => 'আপনার পিণ্ডলির সবচেয়ে চওড়া অংশ ঘিরে মাপুন।';

  @override
  String get nutritionCaloriesLabel => 'ক্যালোরি';

  @override
  String get nutritionFatLabel => 'ফ্যাট';

  @override
  String get nutritionProteinLabel => 'প্রোটিন';

  @override
  String get nutritionCarbsLabel => 'কার্বস';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | C $carbs g | F $fat g';
  }

  @override
  String get nutritionEditEntry => 'এন্ট্রি সম্পাদনা করুন';

  @override
  String get nutritionEditNotAvailable => 'এন্ট্রি সম্পাদনা এখনও উপলভ্য নয়';

  @override
  String get nutritionEntryDeleted => 'এন্ট্রি মুছে ফেলা হয়েছে';

  @override
  String get gymProfileEditTitle => 'জিম প্রোফাইল সম্পাদনা করুন';

  @override
  String get gymProfileNewTitle => 'নতুন জিম প্রোফাইল';

  @override
  String get gymProfileTutorialSpaceTitle => 'ওয়ার্কআউট স্থান';

  @override
  String get gymProfileTutorialSpaceBody => 'আপনি যেখানে প্রশিক্ষণ নেন তার জন্য এই প্রোফাইলের নাম দিন, যেমন বাড়ির জিম, বাণিজ্যিক জিম বা ভ্রমণ সেটআপ।';

  @override
  String get gymProfileTutorialFindTitle => 'সরঞ্জাম খুঁজুন';

  @override
  String get gymProfileTutorialFindBody => 'সরঞ্জামের তালিকা বড় হলে এবং একটি নির্দিষ্ট আইটেমে দ্রুত যেতে চাইলে অনুসন্ধান ব্যবহার করুন।';

  @override
  String get gymProfileTutorialAvailableTitle => 'উপলভ্য সরঞ্জাম';

  @override
  String get gymProfileTutorialAvailableBody => 'এই ওয়ার্কআউট স্থানে কী আছে নির্বাচন করুন। তৈরি পরিকল্পনা ও বদলগুলো অনুপলভ্য ব্যায়াম এড়াতে এটি ব্যবহার করে।';

  @override
  String get gymProfileTutorialSaveTitle => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get gymProfileTutorialSaveBody => 'সংরক্ষণ করলে প্রোফাইল ও সরঞ্জাম সংরক্ষিত হয়। বাতিল করলে অসংরক্ষিত পরিবর্তন বাদ দেওয়ার আগে জিজ্ঞেস করে।';

  @override
  String get gymProfileSaveChangesTitle => 'পরিবর্তন সংরক্ষণ করবেন?';

  @override
  String get gymProfileSaveChangesBody => 'আপনার জিম প্রোফাইলে অসংরক্ষিত পরিবর্তন আছে। বের হওয়ার আগে সংরক্ষণ করবেন?';

  @override
  String get gymProfileKeepEditing => 'সম্পাদনা চালিয়ে যান';

  @override
  String get gymProfileDiscard => 'বাতিল করুন';

  @override
  String get gymProfileSelectEquipment => 'কমপক্ষে একটি সরঞ্জাম নির্বাচন করুন।';

  @override
  String gymProfileSaveFailed(String error) {
    return 'প্রোফাইল সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get gymProfileEquipmentHint => 'এই জিমে যা আছে তা বেছে নিন, যাতে তৈরি করা পরিকল্পনায় শুধু উপলভ্য সরঞ্জাম ব্যবহার হয়।';

  @override
  String get gymProfileSpace => 'ওয়ার্কআউট স্থান';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected / $totalটি সরঞ্জাম বিকল্প নির্বাচিত';
  }

  @override
  String get gymProfileName => 'প্রোফাইলের নাম';

  @override
  String get gymProfileNameHint => 'বাড়ির জিম, বাণিজ্যিক জিম, ভ্রমণ সেটআপ...';

  @override
  String get gymProfileNameRequired => 'নাম প্রয়োজন';

  @override
  String get gymProfileFilterEquipment => 'নাম দিয়ে সরঞ্জাম ফিল্টার করুন';

  @override
  String get gymProfileEquipment => 'সরঞ্জাম';

  @override
  String get gymProfileSelectAll => 'সব নির্বাচন করুন';

  @override
  String get gymProfileClear => 'পরিষ্কার করুন';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total নির্বাচিত';
  }

  @override
  String get gymProfileSave => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get gymProfileSaving => 'সংরক্ষণ করা হচ্ছে...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return '\"$query\"-এর সঙ্গে কোনো সরঞ্জাম মেলেনি।';
  }

  @override
  String get equipmentCategoryBasics => 'মূল বিষয়';

  @override
  String get equipmentCategoryFreeWeights => 'ফ্রি ওয়েট';

  @override
  String get equipmentCategoryBenchesRacks => 'বেঞ্চ ও র‍্যাক';

  @override
  String get equipmentCategoryCableAttachments => 'কেবল ও অ্যাটাচমেন্ট';

  @override
  String get equipmentCategoryMachines => 'মেশিন';

  @override
  String get equipmentCategoryOther => 'অন্যান্য সরঞ্জাম';

  @override
  String get equipmentNoRequirement => 'কোনো সরঞ্জাম প্রয়োজন নেই';

  @override
  String get equipmentBodyweightSupport => 'নিজের ওজনের মুভমেন্টের সহায়তা';

  @override
  String get equipmentMachineBased => 'মেশিনভিত্তিক মুভমেন্ট';

  @override
  String get equipmentCableAccessory => 'কেবল স্টেশন আনুষঙ্গিক';

  @override
  String get equipmentBenchRackSetup => 'বেঞ্চ, র‍্যাক বা স্টেশন সেট আপ';

  @override
  String get equipmentFreeWeightTraining => 'ফ্রি ওয়েট প্রশিক্ষণ';

  @override
  String get equipmentAvailable => 'উপলভ্য সরঞ্জাম';

  @override
  String get foodLoggingTitle => 'খাবার লগিং';

  @override
  String get foodLogTime => 'লগ করার সময়:';

  @override
  String get foodPortion => 'পরিমাণ:';

  @override
  String get foodQuantity => 'পরি.:';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / ইউনিট';
  }

  @override
  String get foodRemove => 'সরান';

  @override
  String get foodAddAllToDiary => 'সব ডায়েরিতে যোগ করুন';

  @override
  String get foodLogging => 'লগ করা হচ্ছে...';

  @override
  String get foodTabScan => 'স্ক্যান';

  @override
  String get foodTabSearch => 'অনুসন্ধান';

  @override
  String get foodTabPlanned => 'পূর্বপরিকল্পিত';

  @override
  String get foodTabCustom => 'কাস্টম';

  @override
  String get foodSearchHint => 'খাবার খুঁজুন...';

  @override
  String get foodNoRecentRecipes => 'এখনও কোনো সাম্প্রতিক রেসিপি নেই।';

  @override
  String get foodRecentRecipe => 'সাম্প্রতিক রেসিপি';

  @override
  String get foodNoFoodsFound => 'কোনো খাবার পাওয়া যায়নি।';

  @override
  String get foodInstantLogAfterScan => 'স্ক্যানের পরই লগ করুন';

  @override
  String get foodInstantLogAfterScanSubtitle => 'নির্বাচিত খাবার ব্যবহার করে স্ক্যান করা আইটেমটি সঙ্গে সঙ্গে যোগ করুন।';

  @override
  String get foodOpenCameraScanner => 'ক্যামেরা স্ক্যানার খুলুন';

  @override
  String get foodEnterBarcode => 'ম্যানুয়ালি বারকোড লিখুন';

  @override
  String get foodEnterBarcodeHint => 'যেমন 012345678905';

  @override
  String get foodLogByBarcode => 'বারকোড দিয়ে লগ করুন';

  @override
  String get foodNoBarcode => 'কোনো বৈধ বারকোড শনাক্ত হয়নি';

  @override
  String get foodBarcodeLogged => 'বারকোড থেকে আইটেম লগ করা হয়েছে';

  @override
  String foodFailed(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get foodCustomSavedBarcode => 'কাস্টম খাবার সংরক্ষিত এবং বারকোড যুক্ত হয়েছে';

  @override
  String get foodFavorites => 'প্রিয়গুলো';

  @override
  String get foodRecentFoods => 'সাম্প্রতিক খাবার';

  @override
  String get foodStartSearching => 'খাবার খুঁজতে অনুসন্ধান শুরু করুন।';

  @override
  String get foodFavorite => 'প্রিয়';

  @override
  String get foodUnfavorite => 'প্রিয় থেকে সরান';

  @override
  String get foodCustomize => 'খাবার কাস্টমাইজ করুন';

  @override
  String get foodEditAndAdd => 'সম্পাদনা করে যোগ করুন';

  @override
  String get foodAddOne => '1 যোগ করুন';

  @override
  String get foodAddNew => 'নতুন খাবার আইটেম যোগ করুন';

  @override
  String get foodCustomSaved => 'কাস্টম খাবার সংরক্ষিত হয়েছে';

  @override
  String get foodNoteOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get foodTagsHint => 'ট্যাগ (কমা দিয়ে আলাদা, যেমন ওয়ার্কআউটের-পরে, উচ্চ-প্রোটিন)';

  @override
  String get foodAddToPlate => 'প্লেটে যোগ করুন';

  @override
  String get foodProfileNotReady => 'প্রোফাইল এখনও প্রস্তুত নয়।';

  @override
  String get foodItemsLogged => 'আইটেম ডায়েরিতে লগ করা হয়েছে';

  @override
  String foodLogFailed(String error) {
    return 'লগ করা যায়নি: $error';
  }

  @override
  String get tutorialSkip => 'এড়িয়ে যান';

  @override
  String get tutorialSkipAll => 'সব এড়িয়ে যান';

  @override
  String get tutorialDone => 'সম্পন্ন';

  @override
  String get tutorialNext => 'পরবর্তী';

  @override
  String get tutorialSkipAllTitle => 'সব টিউটোরিয়াল এড়িয়ে যাবেন?';

  @override
  String get tutorialSkipAllBody => 'এতে সব নির্দেশিত টিউটোরিয়াল লুকানো হবে। Settings > Guided Tutorials-এ Reset All Tutorials ব্যবহার করে যেকোনো সময় আবার চালু করতে পারেন।';

  @override
  String get tutorialKeep => 'টিউটোরিয়াল রাখুন';

  @override
  String get tutorialSkipEverything => 'সব এড়িয়ে যান';

  @override
  String get flowSelectNode => 'নোড নির্বাচন করুন';

  @override
  String get flowSelectMethod => 'পদ্ধতি নির্বাচন করুন';

  @override
  String get flowAddSuccess => '+ সাফল্য';

  @override
  String get flowAddFailure => '+ ব্যর্থতা';

  @override
  String get flowAddMethod => '+ পদ্ধতি';

  @override
  String get flowRemoveMethod => '- পদ্ধতি';

  @override
  String get flowNewEvent => 'নতুন ইভেন্ট';

  @override
  String get flowEventKey => 'ইভেন্ট কী';

  @override
  String get flowEventDisplayLabel => 'প্রদর্শনের লেবেল (ঐচ্ছিক)';

  @override
  String get flowAddSuccessNode => 'সাফল্য নোড যোগ করুন';

  @override
  String get flowAddFailureNode => 'ব্যর্থতা নোড যোগ করুন';

  @override
  String get flowAddEvent => '+ ইভেন্ট';

  @override
  String get flowSelectEvent => 'ইভেন্ট নির্বাচন করুন';

  @override
  String get flowRemoveEvent => 'ইভেন্ট সরান';

  @override
  String get drawerNavigation => 'নেভিগেশন';

  @override
  String get drawerOptionA => 'বিকল্প A';

  @override
  String get drawerOptionB => 'বিকল্প B';

  @override
  String get drawerOptionC => 'বিকল্প C';

  @override
  String get drawerGymProfiles => 'জিম প্রোফাইল';

  @override
  String drawerSavedSpaces(int count) {
    return '$countটি সংরক্ষিত স্থান';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name সক্রিয়';
  }

  @override
  String get drawerActiveProfile => 'সক্রিয় প্রোফাইল';

  @override
  String get drawerTapToSwitch => 'বদলাতে ট্যাপ করুন';

  @override
  String get drawerNewProfile => 'নতুন প্রোফাইল';

  @override
  String get commonAdd => 'যোগ করুন';

  @override
  String get commonRemove => 'সরান';

  @override
  String get automaticSaving => 'সংরক্ষণ করা হচ্ছে...';

  @override
  String get automaticValuesTab => 'মান';

  @override
  String get automaticMethodsTab => 'পদ্ধতি';

  @override
  String get automaticGlobalIncrement => 'বৈশ্বিক বৃদ্ধি পরিমাণ';

  @override
  String get automaticAutoSelect => 'স্বয়ংক্রিয় নির্বাচন';

  @override
  String get automaticManualSelect => 'নিজে নির্বাচন করুন';

  @override
  String get automaticSkipFirstSet => 'প্রথম সেট বাদ দেবেন?';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return 'সেট $number: $weight x $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return 'সেট $parent.$child: $weight x $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return 'সেটিংস সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get automaticIncrementWhen => 'যখন বৃদ্ধি হবে (অন্যথায় কমবে):';

  @override
  String get automaticWeightTarget => 'সম্পন্ন ওজন >= লক্ষ্য ওজন';

  @override
  String get automaticRepsTarget => 'সম্পন্ন রিপস >= লক্ষ্য রিপস';

  @override
  String get automaticVolumeTarget => 'সম্পন্ন ভলিউম >= লক্ষ্য ভলিউম';

  @override
  String get automaticScopeLabel => 'সাফল্য, ব্যর্থতা ও সমন্বয় গণনা করা হয়:';

  @override
  String get automaticWorkoutSession => 'ওয়ার্কআউট সেশন';

  @override
  String get automaticPerExercise => 'প্রতি ব্যায়ামে';

  @override
  String get automaticPerSet => 'প্রতি সেটে';

  @override
  String get automaticAdjustScope => 'সমন্বয় করুন:';

  @override
  String get automaticAdjustOneSet => '1 সেট';

  @override
  String get automaticAdjustAllSets => 'সব সেট';

  @override
  String get weightExpandSets => 'সেট প্রসারিত করুন';

  @override
  String get weightCollapseSets => 'সেট গুটিয়ে নিন';

  @override
  String get weightDetails => 'বিস্তারিত';

  @override
  String get weightRemoveExerciseTitle => 'ব্যায়াম সরান';

  @override
  String get weightRemoveExerciseBody => 'আপনি কি এই ব্যায়াম সরাতে চান?';

  @override
  String get weightSwapExercise => 'ব্যায়াম বদলান';

  @override
  String get weightMakeChangeSet => 'ChangeSet তৈরি করুন';

  @override
  String weightSetLabel(int number) {
    return 'সেট $number';
  }

  @override
  String weightLabel(String unit) {
    return 'ওজন ($unit)';
  }

  @override
  String get weightReps => 'রিপস';

  @override
  String get weightRemoveSetTitle => 'সেট সরান';

  @override
  String get weightRemoveSetBody => 'আপনি কি এই সেট সরাতে চান?';

  @override
  String weightChangeSetLabel(int number) {
    return 'CSet $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'ওজন ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'CSet সরান';

  @override
  String get weightRemoveChangeSetBody => 'আপনি কি এই CSet সরাতে চান?';

  @override
  String get weightAddChangeSet => 'CSet যোগ করুন';

  @override
  String get weightAddSet => 'সেট যোগ করুন';

  @override
  String get swapAlreadySelected => 'ওই ব্যায়ামটি ইতিমধ্যেই নির্বাচিত।';

  @override
  String get swapNeedsProfileEquipment => 'ওই ব্যায়ামের জন্য এই প্রোফাইলের বাইরের সরঞ্জাম প্রয়োজন।';

  @override
  String swapLoadFailed(Object error) {
    return 'বিকল্প ব্যায়ামটি লোড করা যায়নি।';
  }

  @override
  String get swapCurrent => 'বর্তমান';

  @override
  String get swapReplacement => 'বিকল্প';

  @override
  String get swapConfirm => 'বদল নিশ্চিত করুন';

  @override
  String get swapNoBodypartData => 'কোনো শরীরের অংশের ডেটা পাওয়া যায়নি।';

  @override
  String get swapLoadingSelected => 'নির্বাচিত ব্যায়াম লোড হচ্ছে...';

  @override
  String get swapBrowseCatalog => 'ব্যায়াম ক্যাটালগ দেখুন';

  @override
  String get swapNoEquipment => 'কোনো সরঞ্জাম তালিকাভুক্ত নেই';

  @override
  String get swapTitle => 'ব্যায়াম বদলান';

  @override
  String get swapFindingMatches => 'অনুরূপ শরীরের অংশ ও পেশির মিল খোঁজা হচ্ছে...';

  @override
  String get swapChooseReplacement => 'একটি অনুরূপ বিকল্প বেছে নিন।';

  @override
  String get swapFilterProfileEquipment => 'প্রোফাইলের সরঞ্জাম অনুযায়ী ফিল্টার';

  @override
  String get swapBodypartsHit => 'কাজ করা শরীরের অংশ';

  @override
  String swapMatch(int percent) {
    return '$percent% মিল';
  }

  @override
  String get swapNoReplacements => 'এখনও কোনো অনুরূপ বিকল্প পাওয়া যায়নি।';

  @override
  String get swapNoReplacementsBody => 'ভালোভাবে বদল করতে এই ব্যায়ামের আরও পেশি বা শরীরের অংশের মেটাডেটা লাগতে পারে।';

  @override
  String get premadePlansTitle => 'তৈরি করা পরিকল্পনা';

  @override
  String get premadeTutorialLengthTitle => 'পরিকল্পনার দৈর্ঘ্য';

  @override
  String get premadeTutorialLengthBody => '1 ঘণ্টা ও 2 ঘণ্টার সংস্করণের মধ্যে বদলান। দীর্ঘ সংস্করণে আরও ব্যায়াম ও মোট সেট থাকে।';

  @override
  String get premadeTutorialEquipmentTitle => 'প্রোফাইলের সরঞ্জাম';

  @override
  String get premadeTutorialEquipmentBody => 'এটি চালু থাকলে Tonos আপনার বর্তমান জিম প্রোফাইলে করা যায় এমন অনুরূপ বিকল্প দিয়ে অনুপলভ্য ব্যায়াম বদলায়।';

  @override
  String get premadeTutorialLibraryTitle => 'পরিকল্পনা লাইব্রেরি';

  @override
  String get premadeTutorialLibraryBody => 'একটি স্প্লিট খুলুন, পরিকল্পনা প্রিভিউ করুন, তারপর এটি সক্রিয় পরিকল্পনায় যোগ করুন যাতে Train-এ দেখা যায়।';

  @override
  String get premadeSelectProfile => 'প্রথমে একটি জিম প্রোফাইল নির্বাচন করুন।';

  @override
  String premadePlanAdded(String name) {
    return '$name সক্রিয় পরিকল্পনায় যোগ করা হয়েছে।';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return '$name যোগ করা যায়নি: $error';
  }

  @override
  String get premadeDescription => 'কোচ, ইনফ্লুয়েন্সার এবং অ্যাপ-কিউরেট করা রুটিন আপনার নিজের পরিকল্পনায় কপি করুন। যোগ করার পর যেকোনো পরিকল্পনার মতো এগুলো সম্পাদনা করতে পারবেন।';

  @override
  String get premadeDiscarding => 'বাতিল করা হচ্ছে...';

  @override
  String get premadeReviewPlans => 'পরিকল্পনা পর্যালোচনা করুন';

  @override
  String get allocationSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get allocationSaving => 'সংরক্ষণ করা হচ্ছে';

  @override
  String get allocationInvalidCredit => 'প্রতিটি ক্রেডিটের জন্য শূন্য বা ধনাত্মক সংখ্যা দিন।';

  @override
  String get allocationSaved => 'ব্যায়াম বরাদ্দ সংরক্ষিত হয়েছে।';

  @override
  String get allocationSaveFailed => 'ব্যায়াম বরাদ্দ সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get allocationSaveOrDiscard => 'রিসেট করার আগে সম্পাদনাগুলো সংরক্ষণ বা বাতিল করুন।';

  @override
  String get allocationTitle => 'ব্যায়াম সেট বরাদ্দ';

  @override
  String get allocationSubtitle => 'সম্পন্ন সেটগুলো কীভাবে লক্ষ্য পেশি ও শরীরের অংশে অবদান রাখে তা পর্যালোচনা করুন।';

  @override
  String get allocationHowTitle => 'সেট ক্রেডিট কীভাবে কাজ করে';

  @override
  String get allocationHowBody => 'একটি সম্পন্ন সেটের জন্য প্রধান পেশি সাধারণত 1.00 ক্রেডিট পায়। সহায়ক পেশি কম ক্রেডিট পায়। এটি অ্যানাটমি সারাংশ ও সুপারিশ পরিচালনা করে, কিন্তু লগ করা সেট কখনও বদলায় না।';

  @override
  String allocationLoadFailed(String error) {
    return 'ব্যায়াম লোড করা যায়নি। $error';
  }

  @override
  String get allocationNoExercises => 'এখনও কোনো ব্যায়াম নেই।';

  @override
  String get allocationSelectedExercise => 'নির্বাচিত ব্যায়াম';

  @override
  String get allocationMuscleCredit => 'পেশির ক্রেডিট';

  @override
  String get allocationBodypartCredit => 'শরীরের অংশের ক্রেডিট';

  @override
  String get allocationNoTargetMuscles => 'কোনো লক্ষ্য পেশি নেই';

  @override
  String get allocationNoBodypartMapping => 'কোনো শরীরের অংশ ম্যাপিং নেই';

  @override
  String get allocationReset => 'রিসেট করুন';

  @override
  String get allocationCredit => 'ক্রেডিট';

  @override
  String get allocationNoTargetMusclesBody => 'এই ব্যায়ামের এখনও লক্ষ্য পেশির ডেটা নেই।';

  @override
  String get allocationMuscleCreditBody => 'ব্যক্তিগত বরাদ্দ তৈরি করতে একটি মান পরিবর্তন করুন। এটি পেশির সারাংশ ও নির্ধারিত শরীরের অংশ ফোকাসে ব্যবহৃত হয়।';

  @override
  String get allocationNoBodypartMappingBody => 'এই ব্যায়ামের এখনও শরীরের অংশ ম্যাপিং ডেটা নেই।';

  @override
  String get allocationBodypartCreditBody => 'স্বয়ংক্রিয় মান পেশি ও অ্যানাটমি ম্যাপিং থেকে তৈরি হয়। একটি সম্পাদনা করলে সরাসরি ব্যক্তিগত শরীরের অংশ বরাদ্দ তৈরি হয়।';

  @override
  String get healthTrendsTitle => 'স্বাস্থ্য ট্রেন্ড';

  @override
  String get healthMetric => 'মেট্রিক';

  @override
  String get healthUnableToLoad => 'পরিমাপ লোড করা যায়নি';

  @override
  String get healthNoMeasurements => 'এখনও কোনো পরিমাপ নেই';

  @override
  String get healthNoMeasurementsBody => 'অগ্রগতি ট্র্যাক করা শুরু করতে একটি মেট্রিক তৈরি করুন।';

  @override
  String get healthCreateMetric => 'মেট্রিক তৈরি করুন';

  @override
  String healthLogMeasurement(String name) {
    return '$name লগ করুন';
  }

  @override
  String healthEditMeasurement(String name) {
    return '$name সম্পাদনা করুন';
  }

  @override
  String get healthTutorialSummaryTitle => 'পরিমাপ সারাংশ';

  @override
  String get healthTutorialSummaryBody => 'সর্বশেষ মান, আগের এন্ট্রির তুলনায় পরিবর্তন এবং মোট রেকর্ডের সংখ্যা দেখুন।';

  @override
  String get healthTutorialChartTitle => 'ট্রেন্ড চার্ট';

  @override
  String get healthTutorialChartBody => 'আরও এন্ট্রি লগ করলে সময়ের সঙ্গে এই পরিমাপ কীভাবে বদলায় তা চার্টে দেখা যায়।';

  @override
  String get healthTutorialEntriesTitle => 'এন্ট্রি';

  @override
  String get healthTutorialEntriesBody => 'সম্পাদনা করতে একটি এন্ট্রিতে ট্যাপ করুন, বা ভুলে লগ হওয়া এন্ট্রি সরান।';

  @override
  String get healthTutorialLogTitle => 'নতুন এন্ট্রি লগ করুন';

  @override
  String get healthTutorialLogBody => 'যখনই একটি নতুন পরিমাপ রেকর্ড যোগ করতে চান এই বোতাম ব্যবহার করুন।';

  @override
  String get healthDeleteEntryTitle => 'এন্ট্রি মুছবেন?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return '$date-এর $value সরানো হবে।';
  }

  @override
  String get healthLogEntry => 'এন্ট্রি লগ করুন';

  @override
  String healthLoadFailed(String error) {
    return 'লোড করা যায়নি: $error';
  }

  @override
  String get healthEntries => 'এন্ট্রি';

  @override
  String get healthNoEntries => 'এখনও কোনো এন্ট্রি নেই';

  @override
  String healthFirstEntry(String name) {
    return 'আপনার প্রথম $name পরিমাপ লগ করুন।';
  }

  @override
  String get workoutReportLoadFailed => 'ওয়ার্কআউট রিপোর্ট লোড করা যায়নি।';

  @override
  String get workoutReportTitle => 'ওয়ার্কআউট রিপোর্ট';

  @override
  String get workoutReportAdditionalDetails => 'অতিরিক্ত বিবরণ';

  @override
  String get recommendedSetsEdit => 'প্রস্তাবিত সেট সম্পাদনা করুন';

  @override
  String get recommendedSetsTitle => 'প্রস্তাবিত সেট';

  @override
  String get recommendedSetsMinimum => 'সর্বনিম্ন প্রস্তাবিত সেট';

  @override
  String get recommendedSetsMaximum => 'সর্বোচ্চ প্রস্তাবিত সেট';

  @override
  String get recommendedSetsValidNumbers => 'বৈধ সেটের সংখ্যা দিন।';

  @override
  String get recommendedSetsNonNegative => 'সেটের সংখ্যা ঋণাত্মক হতে পারে না।';

  @override
  String get recommendedSetsRange => 'সর্বোচ্চ মান কমপক্ষে সর্বনিম্নের সমান হতে হবে।';

  @override
  String get workoutReportWorkouts => 'ওয়ার্কআউট';

  @override
  String get workoutReportTime => 'সময়';

  @override
  String get workoutReportVolume => 'ভলিউম';

  @override
  String get workoutReportWorkout => 'ওয়ার্কআউট';

  @override
  String get workoutReportTotal => 'মোট';

  @override
  String get databaseSettingsTitle => 'ডাটাবেস সেটিংস';

  @override
  String get databaseSettingsSubtitle => 'ব্যাকআপ, ক্লাউড মিডিয়া, স্বাস্থ্য পরীক্ষা এবং ডেভেলপার এক্সপোর্ট।';

  @override
  String get databaseBackupRestore => 'ব্যাকআপ ও পুনরুদ্ধার';

  @override
  String get databaseBackupRestoreSubtitle => 'আপনার স্থানীয় Tonos তথ্য নিরাপদে ভেতরে বা বাইরে নিন।';

  @override
  String get databaseExportBackup => 'ডাটাবেস ব্যাকআপ এক্সপোর্ট করুন';

  @override
  String get databaseImportBackup => 'ডাটাবেস ব্যাকআপ ইমপোর্ট করুন';

  @override
  String get databaseImportBackupSubtitle => 'সংরক্ষিত এক্সপোর্ট ফাইল থেকে স্থানীয় তথ্য প্রতিস্থাপন করুন।';

  @override
  String get databaseHealth => 'স্বাস্থ্য';

  @override
  String get databaseHealthSubtitle => 'ডাটাবেসের আকার, স্কিমা এবং অনুসন্ধান সূচকের অবস্থার দ্রুত সারাংশ।';

  @override
  String get databaseCheckingHealth => 'ডাটাবেসের স্বাস্থ্য পরীক্ষা করা হচ্ছে...';

  @override
  String get databaseCheckingHealthSubtitle => 'স্কিমা, আকার, টেবিল এবং সূচক পড়া হচ্ছে।';

  @override
  String get databaseHealthFailed => 'ডাটাবেসের স্বাস্থ্য পরীক্ষা ব্যর্থ হয়েছে';

  @override
  String get databaseMaintenance => 'রক্ষণাবেক্ষণ';

  @override
  String get databaseMaintenanceSubtitle => 'পরীক্ষা, অপ্টিমাইজেশন এবং স্টোরেজ পরিষ্কারের নিরাপদ টুল।';

  @override
  String get databaseRefreshHealth => 'স্বাস্থ্য রিফ্রেশ করুন';

  @override
  String get databaseIntegrityCheck => 'অখণ্ডতা পরীক্ষা চালান';

  @override
  String get databaseIntegrityCheckSubtitle => 'স্থানীয় ডাটাবেস ফাইল যাচাই করতে SQLite-কে বলুন।';

  @override
  String get databaseOptimize => 'ডাটাবেস অপ্টিমাইজ করুন';

  @override
  String get databaseCheckpointWal => 'WAL চেকপয়েন্ট';

  @override
  String get databaseCheckpointWalSubtitle => 'রাইট-অ্যাহেড লগ ডাটাবেস ফাইলে ফ্লাশ করে।';

  @override
  String get databaseVacuum => 'ডাটাবেস ভ্যাকুয়াম করুন';

  @override
  String get databaseVacuumSubtitle => 'বড় মুছা বা ইমপোর্টের পরে খালি স্থান পুনরুদ্ধার করে।';

  @override
  String get databaseCloudContent => 'ক্লাউড কনটেন্ট';

  @override
  String get databaseCloudContentSubtitle => 'ব্যায়াম, সরঞ্জাম এবং অ্যানাটমি মিডিয়া স্টোরেজ পরিচালনা করুন।';

  @override
  String get databaseWifiOnly => 'শুধু Wi-Fi ডাউনলোড';

  @override
  String get databaseWifiOnlySubtitle => 'নতুন থাম্বনেইল ও ভিডিও শুধু Wi-Fi-তে ডাউনলোড হয়। ক্যাশ করা মিডিয়া অফলাইনেও কাজ করে।';

  @override
  String get databaseSyncExerciseMedia => 'রিমোট ব্যায়াম মিডিয়া সিঙ্ক করুন';

  @override
  String get databaseSyncSharedMedia => 'শেয়ার করা ক্যাটালগ মিডিয়া সিঙ্ক করুন';

  @override
  String get databaseSyncSharedMediaSubtitle => 'সরঞ্জাম, শরীরের অংশ এবং পেশির ইলাস্ট্রেশন।';

  @override
  String get databaseClearMediaCache => 'ডাউনলোড করা মিডিয়ার ক্যাশ পরিষ্কার করুন';

  @override
  String get databaseClearMediaCacheSubtitle => 'এই ডিভাইস থেকে ক্যাশ করা রিমোট মিডিয়া ফাইল সরিয়ে দেয়।';

  @override
  String get databaseDefinitionExports => 'সংজ্ঞা এক্সপোর্ট';

  @override
  String get databaseDefinitionExportsSubtitle => 'পরিদর্শন বা টুলিংয়ের জন্য অ্যাপের সংজ্ঞা ফাইল এক্সপোর্ট করুন।';

  @override
  String get exerciseEditorTitle => 'ব্যায়াম সম্পাদক';

  @override
  String get exerciseEditorLoadFailed => 'ব্যায়ামের সংজ্ঞা লোড করা যায়নি।';

  @override
  String get exerciseEditorChoose => 'ব্যায়াম বেছে নিন';

  @override
  String get exerciseEditorEdit => 'সংজ্ঞা সম্পাদনা করুন';

  @override
  String get exerciseEditorCreate => 'কাস্টম ব্যায়াম তৈরি করুন';

  @override
  String get exerciseEditorSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get exerciseEditorSaving => 'সংরক্ষণ করা হচ্ছে';

  @override
  String get exerciseEditorMuscles => 'পেশি';

  @override
  String get exerciseEditorBodyparts => 'শরীরের অংশ';

  @override
  String get exerciseEditorEquipment => 'সরঞ্জাম';

  @override
  String get exerciseEditorGuide => 'গাইড';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name ইতিমধ্যে দেখানো হচ্ছে।';
  }

  @override
  String get exerciseProgressTrendTitle => '1RM প্রবণতা';

  @override
  String get exerciseProgressTrendBody => 'এই চার্ট সময়ের সঙ্গে বাস্তব রেকর্ড করা 1RM এবং আনুমানিক 1RM তুলনা করে। সঠিক মান দেখতে পয়েন্টে ট্যাপ করুন।';

  @override
  String get exerciseProgressRecordings => 'রেকর্ডিং';

  @override
  String get exerciseProgressRecordingsBody => 'প্রতিটি রেকর্ডিং সেই ওয়ার্কআউট খুলে যেখানে লিফটটি হয়েছিল, যাতে আপনি পুরো প্রেক্ষাপট পর্যালোচনা করতে পারেন।';

  @override
  String get exerciseProgressTitle => '1RM অগ্রগতি';

  @override
  String get exerciseProgressEmpty => 'অগ্রগতির ইতিহাস তৈরি শুরু করতে এই ব্যায়ামটি সম্পন্ন করুন।';

  @override
  String get exerciseProgressActual => 'বাস্তব 1RM';

  @override
  String get exerciseProgressEstimated => 'আনুমানিক 1RM';

  @override
  String get exerciseProgressSessionOpenFailed => 'ওয়ার্কআউট সেশন খোলা যায়নি।';

  @override
  String get exerciseProgressSessionMissing => 'ওয়ার্কআউট সেশন পাওয়া যায়নি।';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'আনু. $value';
  }

  @override
  String get exerciseProgressNoActual => 'কোনো বাস্তব 1RM নেই';

  @override
  String exerciseProgressActualValue(String value) {
    return 'বাস্তব $value';
  }

  @override
  String get musclePercentTitle => 'প্রতি পেশিতে % কাজ';

  @override
  String musclePercentLoadFailed(String error) {
    return 'এন্ট্রি লোড ব্যর্থ: $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'শতাংশ আপডেট ব্যর্থ: $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'ডিফল্টে রিসেট ব্যর্থ: $error';
  }

  @override
  String musclePercentError(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get musclePercentNoExercises => 'কোনো ব্যায়াম সংজ্ঞায়িত নেই';

  @override
  String get musclePercentEmpty => 'কোনো পেশির শতাংশ সেট করা নেই';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'ডিফল্টে ফিরুন';

  @override
  String get sevenDayFocusTitle => 'সাপ্তাহিক সারাংশ';

  @override
  String get sevenDayFocusLoadFailed => '7 দিনের ফোকাস লোড করা যায়নি';

  @override
  String get sevenDayFocusEmpty => 'গত 7 দিনে সম্পন্ন শরীরের অংশের কোনো সেট ইউনিট নেই।';

  @override
  String get sevenDayFocusMore => 'আরও';

  @override
  String get pastSessionsWeek => 'সপ্তাহ';

  @override
  String get pastSessionsMonth => 'মাস';

  @override
  String get pastSessionsYear => 'বছর';

  @override
  String get pastSessionsAll => 'সব';

  @override
  String get pastSessionsShow => 'দেখান:';

  @override
  String get pastSessionsFullscreen => 'পূর্ণ পর্দা';

  @override
  String pastSessionsError(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get pastSessionsEmpty => 'এখনও কোনো সেশন নেই।';

  @override
  String pastSessionsItem(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get historySummaryLoadFailed => 'ইতিহাস লোড করতে ত্রুটি';

  @override
  String get historySummaryWorkouts => 'ওয়ার্কআউট';

  @override
  String get historySummaryTotalTime => 'মোট সময়';

  @override
  String get historySummaryTotalVolume => 'মোট ভলিউম';

  @override
  String get planCoachSkipGuide => 'গাইড এড়িয়ে যান';

  @override
  String get planCoachContinue => 'চালিয়ে যান';

  @override
  String get trainOptimizedSettingsTitle => 'অপ্টিমাইজ করা ওয়ার্কআউট সেটিংস';

  @override
  String get trainOptimizedSettingsBudgetBody => 'প্রতিটি সেটের জন্য 3 মিনিট এবং প্রতিটি ব্যায়াম শুরু করতে 5 মিনিট বাজেট করতে ব্যবহার হয়।';

  @override
  String get trainOptimizedSettingsFocusBody => 'শরীরের অংশের পছন্দ শুধু আপনার শুরু করা পরবর্তী অপ্টিমাইজ করা ওয়ার্কআউটে প্রযোজ্য।';

  @override
  String get trainWorkoutDuration => 'ওয়ার্কআউটের সময়কাল';

  @override
  String get trainMinutesShort => 'মিনিট';

  @override
  String get trainSetsPerExercise => 'প্রতি ব্যায়ামে সর্বোচ্চ সেট';

  @override
  String get trainSetsShort => 'সেট';

  @override
  String get trainBodypartFocus => 'শরীরের অংশের ফোকাস';

  @override
  String get trainBodypartFocusHelp => 'একবার ট্যাপ করে একটি শরীরের অংশকে অগ্রাধিকার দিন, আবার ট্যাপ করে এড়িয়ে যান, তৃতীয়বার ট্যাপ করে পরিষ্কার করুন।';

  @override
  String get trainBodypartsLoadFailed => 'শরীরের অংশ লোড করা যায়নি।';

  @override
  String get trainPlanGenerated => 'পরিকল্পনা তৈরি হয়েছে। এখন এটি খোলা হচ্ছে।';

  @override
  String trainPlansGenerated(int count) {
    return '$countটি পরিকল্পনা তৈরি হয়েছে।';
  }

  @override
  String get trainActiveWorkoutKept => 'অন্য একটি ওয়ার্কআউট ইতিমধ্যেই সক্রিয়, তাই সেটি অপরিবর্তিত রাখা হয়েছে।';

  @override
  String get trainMenuTitle => 'প্রশিক্ষণ মেনু';

  @override
  String get trainExerciseCatalog => 'ব্যায়াম ক্যাটালগ';

  @override
  String get trainMuscleFilter => 'পেশি ফিল্টার';

  @override
  String get trainGymSettings => 'জিম ও ওয়ার্কআউট সেটিংস';

  @override
  String get trainTab => 'প্রশিক্ষণ';

  @override
  String get trainHistoryTab => 'ইতিহাস';

  @override
  String get trainExercisePresets => 'ব্যায়াম প্রিসেট';

  @override
  String get trainGeneratePlans => 'কাস্টম পরিকল্পনা তৈরি করুন';

  @override
  String get trainAddPlan => 'ম্যানুয়ালি প্রিসেট যোগ করুন';

  @override
  String get trainNewPlanFirst => 'নতুন প্রিসেট';

  @override
  String trainNewPlan(int number) {
    return 'নতুন প্রিসেট $number';
  }

  @override
  String get trainBuildingOptimized => 'অপ্টিমাইজ করা ওয়ার্কআউট তৈরি হচ্ছে...';

  @override
  String get trainStartOptimized => 'অপ্টিমাইজ করা ওয়ার্কআউট শুরু করুন';

  @override
  String get trainNewSession => 'নতুন সেশন';

  @override
  String get foodCustomizationTitle => 'খাবার কাস্টমাইজ করুন';

  @override
  String get foodCustomizationEditTitle => 'খাবার সম্পাদনা করুন';

  @override
  String get foodCustomizationName => 'খাবারের নাম';

  @override
  String get foodCustomizationEnterName => 'একটি নাম দিন';

  @override
  String get foodCustomizationBrand => 'ব্র্যান্ড';

  @override
  String get foodCustomizationFoodPhoto => 'খাবারের ছবি';

  @override
  String get foodCustomizationLabelPhoto => 'লেবেলের ছবি';

  @override
  String get foodCustomizationDensity => 'ঘনত্ব (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'ম্যাক্রো গণনার জন্য mL-ভিত্তিক পরিমাণ (কাপ, টেবিল চামচ) গ্রামে রূপান্তর করতে ব্যবহৃত হয়।';

  @override
  String get foodCustomizationCalories => 'ক্যালোরি (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'ম্যাক্রোনিউট্রিয়েন্ট';

  @override
  String get foodCustomizationMicronutrients => 'মাইক্রোনিউট্রিয়েন্ট';

  @override
  String get foodCustomizationAdditionalComponents => 'অতিরিক্ত উপাদান';

  @override
  String get foodCustomizationPortionInfo => 'পরিমাণের তথ্য';

  @override
  String get foodCustomizationBasisPortion => 'পুষ্টির মানের পরিমাণের ভিত্তি';

  @override
  String get foodCustomizationUsualPortion => 'ব্যবহারকারীর সাধারণ খাওয়ার পরিমাণ';

  @override
  String get foodCustomizationAddPortion => 'পরিমাণ যোগ করুন';

  @override
  String get foodCustomizationUnit => 'ইউনিট';

  @override
  String get foodCustomizationAmount => 'পরিমাণ';

  @override
  String get foodCustomizationWeight => 'ওজন (g)';

  @override
  String get foodCustomizationVolume => 'আয়তন (mL)';

  @override
  String get dashboardArchivedPlans => 'আর্কাইভ করা পরিকল্পনা';

  @override
  String get dashboardActivePlans => 'সক্রিয় পরিকল্পনা';

  @override
  String get dashboardManagePlans => 'পরিকল্পনা পরিচালনা করুন';

  @override
  String get dashboardSelectProfilePlans => 'পরিকল্পনা দেখতে একটি জিম প্রোফাইল নির্বাচন করুন।';

  @override
  String get dashboardNoArchivedPlans => 'এই প্রোফাইলে কোনো আর্কাইভ করা পরিকল্পনা নেই।';

  @override
  String get dashboardNoActivePlans => 'এখনও কোনো সক্রিয় পরিকল্পনা নেই। পরিকল্পনা বেছে নিতে কলম আইকন ব্যবহার করুন।';

  @override
  String dashboardPremadeCount(int count) {
    return 'যোগ করার জন্য $countটি প্রস্তুত রুটিন আছে।';
  }

  @override
  String get dashboardBrowsePremadePlans => 'তৈরি করা পরিকল্পনা দেখুন';

  @override
  String get dashboardNewPlanFirst => 'নতুন পরিকল্পনা';

  @override
  String dashboardNewPlan(int number) {
    return 'নতুন পরিকল্পনা $number';
  }

  @override
  String get dashboardPlanTools => 'পরিকল্পনা টুল';

  @override
  String get dashboardPlanToolsBody => 'আপনার প্রশিক্ষণ পছন্দ থেকে একটি পরিকল্পনা তৈরি করুন অথবা ফাঁকা একটি দিয়ে শুরু করুন।';

  @override
  String get dashboardManual => 'ম্যানুয়াল';

  @override
  String get dashboardGenerate => 'তৈরি করুন';

  @override
  String get dashboardMostUsedExercises => 'সবচেয়ে বেশি করা ব্যায়াম';

  @override
  String get dashboardMostUsedExercisesEmpty => 'এখানে আপনার সাধারণ ব্যায়াম দেখতে ওয়ার্কআউট সম্পন্ন করুন।';

  @override
  String premadeDiscardFailed(String error) {
    return 'যোগ করা পরিকল্পনা বাতিল করা যায়নি: $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'উপলভ্য সরঞ্জাম অনুযায়ী পরিকল্পনা মানিয়ে নিতে একটি জিম প্রোফাইল নির্বাচন করুন।';

  @override
  String get premadeEquipmentExact => 'তৈরি করা পরিকল্পনাগুলো ঠিক যেভাবে লেখা আছে সেভাবেই দেখানো হয়।';

  @override
  String get premadeEquipmentChecking => 'আপনার প্রোফাইলের সঙ্গে পরিকল্পনার ব্যায়ামগুলো পরীক্ষা করা হচ্ছে...';

  @override
  String get premadeEquipmentMissing => 'কোনো প্রোফাইল সরঞ্জাম পাওয়া যায়নি, তাই তৈরি করা পরিকল্পনাগুলো অপরিবর্তিত আছে।';

  @override
  String premadeEquipmentReplacements(int count) {
    return 'পরিকল্পনা যোগ হলে $countটি অনুপলভ্য ব্যায়াম বদলানো হবে।';
  }

  @override
  String get premadeEquipmentFits => 'পরিকল্পনাগুলো ইতিমধ্যেই বর্তমান প্রোফাইলের সরঞ্জামের সঙ্গে মানানসই।';

  @override
  String get premadeOneHour => '1 ঘণ্টা';

  @override
  String get premadeTwoHours => '2 ঘণ্টা';

  @override
  String premadePlansAvailable(int count) {
    return '$countটি পরিকল্পনা উপলভ্য';
  }

  @override
  String get premadeNoTemplates => 'এখনও কোনো পরিকল্পনা টেমপ্লেট নেই';

  @override
  String premadePlansCount(int count) {
    return '$countটি পরিকল্পনা';
  }

  @override
  String get premadeTemplatesLater => 'পরে এখানে এই স্প্লিটের টেমপ্লেট যোগ করা যাবে।';

  @override
  String premadeExerciseCount(int count) {
    return '$countটি ব্যায়াম';
  }

  @override
  String premadeSetCount(int count) {
    return '$countটি সেট';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$countটি বদলানো হয়েছে';
  }

  @override
  String get premadeAdding => 'যোগ করা হচ্ছে';

  @override
  String get premadeChecking => 'পরীক্ষা করা হচ্ছে';

  @override
  String get premadeProfileSwap => 'প্রোফাইল বদল';

  @override
  String get healthEntryValueUnitRequired => 'প্রথমে একটি মান ও ইউনিট দিন।';

  @override
  String get healthDefinitionFieldsRequired => 'একটি নাম, ইউনিট এবং বৈধ মান দিন।';

  @override
  String get healthUnit => 'ইউনিট';

  @override
  String get healthNote => 'নোট';

  @override
  String get healthOptional => 'ঐচ্ছিক';

  @override
  String get healthMetricName => 'মেট্রিকের নাম';

  @override
  String get healthMetricNameHint => 'বাহুর মাপ, বিশ্রামের হৃদস্পন্দন...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'in, $weightUnit, %, bpm...';
  }

  @override
  String get healthStartingValue => 'শুরুর মান';

  @override
  String get healthCreate => 'তৈরি করুন';

  @override
  String get exerciseProgressNoRecordings => 'এখনও কোনো রেকর্ডিং নেই';

  @override
  String get exerciseEditorDiscardTitle => 'পরিবর্তন বাতিল করবেন?';

  @override
  String get exerciseEditorDiscardBody => 'আপনার সম্পাদনাগুলো এখনও সংরক্ষিত হয়নি। আপনি সম্পাদনা চালিয়ে যেতে বা বাতিল করতে পারেন।';

  @override
  String get exerciseEditorKeepEditing => 'সম্পাদনা চালিয়ে যান';

  @override
  String get exerciseEditorDiscard => 'বাতিল করুন';

  @override
  String get exerciseEditorAddBodyparts => 'সম্পর্কিত শরীরের অংশ যোগ করুন';

  @override
  String get exerciseEditorAddMuscles => 'সম্পর্কিত পেশি যোগ করুন';

  @override
  String get exerciseEditorAddEquipment => 'সরঞ্জাম যোগ করুন';

  @override
  String get databaseClearMediaTitle => 'ডাউনলোড করা মিডিয়া পরিষ্কার করবেন?';

  @override
  String get databaseClearMediaBody => 'এটি ক্যাশ করা ব্যায়াম, সরঞ্জাম ও অ্যানাটমি মিডিয়া সরিয়ে দেবে। প্রয়োজন হলে অ্যাপ আবার সেগুলো ডাউনলোড করতে পারবে।';

  @override
  String get databaseClearCache => 'ক্যাশ পরিষ্কার করুন';

  @override
  String get databaseCacheCleared => 'ডাউনলোড করা মিডিয়া ক্যাশ পরিষ্কার করা হয়েছে।';

  @override
  String databaseClearCacheFailed(String error) {
    return 'ক্যাশ পরিষ্কার ব্যর্থ: $error';
  }

  @override
  String get databaseContentEnvironment => 'কনটেন্ট পরিবেশ';

  @override
  String get databaseLoadingEnvironment => 'পরিবেশ লোড হচ্ছে...';

  @override
  String get databaseChangeEnvironment => 'পরিবেশ পরিবর্তন করুন';

  @override
  String get databaseExerciseManifestUrl => 'ব্যায়াম মিডিয়া ম্যানিফেস্ট URL';

  @override
  String get databaseNoExerciseManifestUrl => 'এই পরিবেশের জন্য কোনো রিমোট ম্যানিফেস্ট URL সেট করা নেই।';

  @override
  String get databaseOverrideUrl => 'URL ওভাররাইড করুন';

  @override
  String get databaseNoManifestSynced => 'কোনো ম্যানিফেস্ট সিঙ্ক হয়নি';

  @override
  String databaseManifestVersion(int version) {
    return 'ম্যানিফেস্ট v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'সর্বশেষ পরীক্ষা: $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'শেয়ার করা ক্যাটালগ মিডিয়া';

  @override
  String get databaseSharedMediaNotSynced => 'এখনও সিঙ্ক হয়নি। সরঞ্জাম, শরীরের অংশ ও পেশি।';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'ম্যানিফেস্ট v$version। সর্বশেষ পরীক্ষা: $date';
  }

  @override
  String get databaseSharedManifestUrl => 'শেয়ার করা মিডিয়া ম্যানিফেস্ট URL';

  @override
  String get databaseNoSharedManifestUrl => 'এই পরিবেশের জন্য কোনো রিমোট শেয়ার করা মিডিয়া URL সেট করা নেই।';

  @override
  String get databaseDownloadedMediaCache => 'ডাউনলোড করা মিডিয়া ক্যাশ';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$countটি ফাইল, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'বান্ডেল করা ম্যানিফেস্ট লোড করুন';

  @override
  String get databaseTutorialFilesTitle => 'ডাটাবেস ফাইল';

  @override
  String get databaseTutorialFilesBody => 'একটি ব্যাকআপ এক্সপোর্ট করুন বা সংরক্ষিত ডাটাবেস ফাইল ইমপোর্ট করুন। ইমপোর্টের আগে ব্যাকআপ প্রয়োজন।';

  @override
  String get databaseTutorialHealthTitle => 'ডাটাবেসের স্বাস্থ্য';

  @override
  String get databaseTutorialHealthBody => 'এই কার্ডে স্কিমা সংস্করণ, ডাটাবেস আকার, টেবিলের সংখ্যা এবং সার্চ-ইনডেক্সের অবস্থা দেখা যায়।';

  @override
  String get databaseTutorialMaintenanceTitle => 'রক্ষণাবেক্ষণ টুল';

  @override
  String get databaseTutorialMaintenanceBody => 'প্রয়োজনে অখণ্ডতা পরীক্ষা, অপ্টিমাইজেশন, WAL চেকপয়েন্ট বা ভ্যাকুয়ামের জন্য এই কাজগুলো ব্যবহার করুন।';

  @override
  String get databaseExportSavedTitle => 'ডাটাবেস এক্সপোর্ট সংরক্ষিত';

  @override
  String get databaseExportSavedBody => 'ডাটাবেস এক্সপোর্টটি আপনার নির্বাচিত স্থানে সংরক্ষণ করা হয়েছে।';

  @override
  String databaseImportBlocked(String message) {
    return 'ইমপোর্ট আটকানো হয়েছে: $message';
  }

  @override
  String get databaseImportBackupCanceled => 'ইমপোর্ট বাতিল হয়েছে: ব্যাকআপ সংরক্ষণ করা যায়নি।';

  @override
  String get databaseImportSucceededTitle => 'ইমপোর্ট সফল';

  @override
  String databaseImportSucceededBody(String name) {
    return '$name ইমপোর্ট করা হয়েছে। প্রথমে আগের স্থানীয় ডাটাবেসের ব্যাকআপ আপনার নির্বাচিত স্থানে সংরক্ষণ করা হয়েছে।';
  }

  @override
  String get databaseConfirmImportTitle => 'ইমপোর্ট নিশ্চিত করুন';

  @override
  String get databaseConfirmImportBody => 'এতে স্থানীয় ডাটাবেস প্রতিস্থাপিত হবে। প্রথমে বর্তমান ডাটাবেসের একটি ব্যাকআপ ফাইল লেখা হবে।';

  @override
  String databaseImportFile(String name) {
    return 'ফাইল: $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'টেবিল: $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'সারি: $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'এক্সপোর্ট স্কিমা: v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'ফরম্যাট: লেগ্যাসি টেবিল ম্যাপ';

  @override
  String get databaseImportWarnings => 'সতর্কতা:';

  @override
  String get databaseBackupAndImport => 'ব্যাকআপ ও ইমপোর্ট';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'ডাটাবেস রক্ষণাবেক্ষণ ব্যর্থ: $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'সেট ক্রেডিট সম্পাদনার আগে সংজ্ঞা পরিবর্তন সংরক্ষণ বা বাতিল করুন।';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return '$type সরাবেন?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return 'এই ব্যায়ামের সংজ্ঞা থেকে \"$name\" সরাবেন?';
  }

  @override
  String get exerciseEditorKeep => 'রাখুন';

  @override
  String get exerciseEditorMuscleOrderTitle => 'লক্ষ্য পেশির ক্রম';

  @override
  String get exerciseEditorMuscleOrderBody => 'ব্যায়ামটি কোন পেশিকে কতটা লক্ষ্য করে সেই অনুযায়ী পেশিগুলো সাজান। এতে Tonos অ্যানাটমি ফোকাস অনুমান করতে এবং ভালো ব্যায়াম সুপারিশ করতে পারে।';

  @override
  String get exerciseEditorExactSetCredit => 'সুনির্দিষ্ট সেট ক্রেডিট';

  @override
  String get exerciseEditorExactSetCreditBody => 'Exercise Set Allocation-এ একটি সেট প্রতিটি পেশি বা শরীরের অংশকে কতটুকু সুনির্দিষ্ট ক্রেডিট দেয় তা পরিবর্তন করুন।';

  @override
  String get exerciseEditorSetCreditScaling => 'সেট-ক্রেডিট স্কেলিং';

  @override
  String get exerciseEditorSetCreditScalingBody => 'এই ব্যায়ামের রেটিং সেট ক্রেডিট স্কেল করবে কি না নির্বাচন করুন।';

  @override
  String get exerciseEditorScaleCreditByRating => 'রেটিং অনুযায়ী ক্রেডিট স্কেল করুন';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'অ্যানালিটিক সেট মোটে ব্যায়ামের রেটিং প্রয়োগ করে।';

  @override
  String get exerciseEditorTargetMuscles => 'লক্ষ্য পেশি';

  @override
  String get exerciseEditorOrderMusclesHint => 'লক্ষ্য জোরের ক্রমে পেশি সাজাতে তীরচিহ্ন ব্যবহার করুন।';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return 'বর্তমানে $countটি পেশি যুক্ত আছে।';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'এখনও কোনো লক্ষ্য পেশি যুক্ত নেই।';

  @override
  String get exerciseEditorAddTargetMuscles => 'লক্ষ্য পেশি যোগ করুন';

  @override
  String get exerciseEditorMoveUp => 'উপরে নিন';

  @override
  String get exerciseEditorMoveDown => 'নিচে নিন';

  @override
  String get exerciseEditorRemoveMuscle => 'পেশি সরান';

  @override
  String get exerciseEditorMuscleItem => 'পেশি';

  @override
  String get exerciseEditorAssociatedBodyparts => 'সম্পর্কিত শরীরের অংশ';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'এই বিস্তৃত অংশগুলো শরীরের হিটম্যাপ, সাপ্তাহিক কভারেজ এবং সরঞ্জাম-সচেতন ওয়ার্কআউট সুপারিশ পরিচালনা করে।';

  @override
  String get exerciseEditorExactBodypartCredit => 'সুনির্দিষ্ট শরীরের অংশ ক্রেডিট';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'কোনো সেটকে যদি শরীরের কোনো অংশের জন্য নির্দিষ্ট আংশিক পরিমাণ হিসেবে গণনা করতে হয়, Exercise Set Allocation ব্যবহার করুন।';

  @override
  String get exerciseEditorBodypartsHint => 'এই ব্যায়াম যেসব বিস্তৃত শরীরের অংশ প্রশিক্ষণ দেয়, সব যোগ করুন।';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return 'বর্তমানে $countটি শরীরের অংশ যুক্ত আছে।';
  }

  @override
  String get exerciseEditorNoBodyparts => 'এখনও কোনো শরীরের অংশ যুক্ত নেই।';

  @override
  String get exerciseEditorAutomaticPreview => 'স্বয়ংক্রিয় প্রিভিউ';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'লক্ষ্য-পেশি কাঠামো থেকে বর্তমান ফোকাস নির্ধারিত।';

  @override
  String get exerciseEditorRemoveBodypart => 'শরীরের অংশ সরান';

  @override
  String get exerciseEditorBodypartItem => 'শরীরের অংশ';

  @override
  String get exerciseEditorAvailableEquipment => 'উপলভ্য সরঞ্জাম';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'সম্পর্কিত সরঞ্জাম নির্ধারণ করে কোন প্রোফাইল এই ব্যায়াম ব্যবহার করতে পারবে এবং Tonos কোন বিকল্প সুপারিশ করতে পারবে।';

  @override
  String get exerciseEditorEquipmentHint => 'এই ব্যায়াম করতে প্রয়োজনীয় প্রতিটি সরঞ্জাম যোগ করুন।';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '$countটি সরঞ্জাম যুক্ত আছে।';
  }

  @override
  String get exerciseEditorNoEquipment => 'এখনও কোনো সরঞ্জাম যুক্ত নেই।';

  @override
  String get exerciseEditorRemoveEquipment => 'সরঞ্জাম সরান';

  @override
  String get exerciseEditorEquipmentItem => 'সরঞ্জাম';

  @override
  String get historySummaryAll => 'সব';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '$hoursঘ $minutesমি';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'প্রথমে একটি বৈধ ব্যায়াম মিডিয়া ম্যানিফেস্ট URL যোগ করুন।';

  @override
  String databaseContentSyncFailed(String error) {
    return 'কনটেন্ট সিঙ্ক ব্যর্থ: $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'বান্ডেল করা কনটেন্ট সিঙ্ক ব্যর্থ: $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'এই কনটেন্ট পরিবেশে কোনো শেয়ার করা মিডিয়া URL নেই।';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'শেয়ার করা কনটেন্ট সিঙ্ক ব্যর্থ: $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return '$filename এক্সপোর্ট ব্যর্থ: $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'ব্যায়াম মিডিয়া ম্যানিফেস্ট';

  @override
  String get databaseManifestUrl => 'ম্যানিফেস্ট URL';

  @override
  String get databaseClear => 'পরিষ্কার করুন';

  @override
  String get databaseNoManifestConfigured => 'এখনও কোনো ম্যানিফেস্ট URL কনফিগার করা হয়নি।';

  @override
  String get databaseUseEnvironment => 'এই পরিবেশ ব্যবহার করুন';

  @override
  String get dashboardTargetAnatomy => 'লক্ষ্য অ্যানাটমি';

  @override
  String get dashboardBodyparts => 'শরীরের অংশ';

  @override
  String get dashboardMuscles => 'পেশি';

  @override
  String get exerciseEditorCreateCustomTitle => 'কাস্টম ব্যায়াম তৈরি করুন';

  @override
  String get exerciseEditorCreateCustomBody => 'একটি কাস্টম ক্যাটালগ সংজ্ঞা তৈরি করুন, তারপর সংরক্ষণের আগে এর লক্ষ্য অ্যানাটমি ও নির্দেশনা যোগ করুন।';

  @override
  String get exerciseEditorExerciseName => 'ব্যায়ামের নাম';

  @override
  String get exerciseEditorNoEquipmentChoice => 'কোনো সরঞ্জাম নয়';

  @override
  String get exerciseEditorOpenedMessage => 'ব্যায়াম খোলা হয়েছে। এর লক্ষ্য অ্যানাটমি যোগ করুন, তারপর সংরক্ষণ করুন।';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'কাস্টম ব্যায়াম তৈরি করা যায়নি। $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'এতে কী পরিবর্তন হয়';

  @override
  String get exerciseEditorWhatChangesBody => 'এই উন্নত সম্পাদকে ব্যায়ামের নাম, লক্ষ্য অ্যানাটমি, সরঞ্জাম, ফর্ম নির্দেশনা, রেটিং এবং রেফারেন্স মিডিয়া আপডেট করুন। প্রতিটি সেটের সুনির্দিষ্ট ক্রেডিট আলাদাভাবে পরিচালিত হয়, যাতে পুরো অ্যাপে তা সামঞ্জস্যপূর্ণ থাকে।';

  @override
  String get exerciseEditorChooseCatalog => 'ক্যাটালগ থেকে একটি ব্যায়াম বেছে নিন';

  @override
  String get exerciseEditorRating => 'রেটিং';

  @override
  String get databaseNever => 'কখনও নয়';

  @override
  String databaseExportDefinition(String filename) {
    return '$filename এক্সপোর্ট করুন';
  }

  @override
  String get exerciseEditorAddMedia => 'মিডিয়া যোগ করুন';

  @override
  String get exerciseEditorEditMedia => 'মিডিয়া সম্পাদনা করুন';

  @override
  String get exerciseEditorMediaImage => 'ছবি';

  @override
  String get exerciseEditorMediaVideo => 'ভিডিও';

  @override
  String get exerciseEditorMediaLink => 'লিংক';

  @override
  String get exerciseEditorMediaType => 'ধরন';

  @override
  String get exerciseEditorMediaTitle => 'শিরোনাম';

  @override
  String get exerciseEditorMediaTitleHint => 'ঐচ্ছিক প্রদর্শন লেবেল';

  @override
  String get exerciseEditorMediaRemoteUrl => 'রিমোট URL';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'থাম্বনেইল URL';

  @override
  String get exerciseEditorMediaThumbnailHint => 'ঐচ্ছিক ছবি প্রিভিউ URL';

  @override
  String get exerciseEditorSelectBeforeMedia => 'মিডিয়া যোগ করার আগে একটি বিদ্যমান ব্যায়াম নির্বাচন করুন।';

  @override
  String get exerciseEditorFormGuide => 'ফর্ম গাইড';

  @override
  String get exerciseEditorFormGuideBody => 'এই নোটগুলো ব্যায়ামের বিস্তারিত শিটে দেখা যাবে, যাতে মানুষ নিরাপদে মুভমেন্ট সেট আপ, সম্পাদন ও বুঝতে পারে।';

  @override
  String get exerciseEditorGuidance => 'নির্দেশনা';

  @override
  String get exerciseEditorGuidanceEditing => 'পরিষ্কার, ব্যবহারিক সংকেত লিখুন। সংরক্ষণ না করা পর্যন্ত পরিবর্তনগুলো অস্থায়ী থাকবে।';

  @override
  String get exerciseEditorGuidanceReadOnly => 'বর্তমান ব্যায়ামের নির্দেশনা ও সংকেত।';

  @override
  String get exerciseEditorSetUp => 'সেট আপ';

  @override
  String get exerciseEditorSetUpHint => 'শুরুর অবস্থান, সরঞ্জাম সেট আপ এবং নিরাপত্তা নোট।';

  @override
  String get exerciseEditorHowToPerform => 'কীভাবে করবেন';

  @override
  String get exerciseEditorHowToPerformHint => 'মূল মুভমেন্ট ধাপ এবং গতির পরিসর।';

  @override
  String get exerciseEditorCoachingTips => 'কোচিং পরামর্শ';

  @override
  String get exerciseEditorCoachingTipsHint => 'সহায়ক সংকেত, সাধারণ ভুল এবং ভিন্নতা।';

  @override
  String get exerciseEditorReferenceMedia => 'রেফারেন্স মিডিয়া';

  @override
  String get exerciseEditorReferenceMediaBody => 'ব্যক্তিগত রেফারেন্স উপকরণের জন্য মিডিয়া লিংক ব্যবহার করুন। ম্যানেজ করা ক্যাটালগ মিডিয়া কনটেন্ট সিঙ্ক পাইপলাইনের মাধ্যমে রিফ্রেশ করা যায়।';

  @override
  String get exerciseEditorMediaLinks => 'মিডিয়া লিংক';

  @override
  String get exerciseEditorMediaLinksEditing => 'একটি রিমোট ছবি, ভিডিও বা রেফারেন্স লিংক যোগ বা আপডেট করুন।';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return 'বর্তমানে $countটি মিডিয়া আইটেম যুক্ত আছে।';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'এখনও কোনো রেফারেন্স মিডিয়া যুক্ত নেই।';

  @override
  String get exerciseEditorAddMediaLink => 'মিডিয়া লিংক যোগ করুন';

  @override
  String get exerciseEditorRemoveMedia => 'মিডিয়া সরান';

  @override
  String get exerciseEditorMediaLinkItem => 'মিডিয়া লিংক';

  @override
  String exerciseEditorMediaReference(String type) {
    return '$type রেফারেন্স';
  }

  @override
  String get bengaliBangladeshLanguage => 'বাংলা (বাংলাদেশ)';

  @override
  String get simplifiedChineseLanguage => 'সরলীকৃত চীনা';

  @override
  String get hindiLanguage => 'হিন্দি';

  @override
  String get spanishLanguage => 'স্প্যানিশ';

  @override
  String get onboardingWeightHistoryTitle => 'ওজনের ইতিহাস';

  @override
  String get onboardingWeightHistorySubtitle => 'কয়েকটি তথ্য পুষ্টির লক্ষ্য আরও যুক্তিসঙ্গতভাবে অনুমান করতে সাহায্য করে।';

  @override
  String get onboardingPreviouslyHeavier => 'আপনার বর্তমান ওজনের চেয়ে আগে কি 10+ পাউন্ড বেশি ওজন ছিল?';

  @override
  String get onboardingWeightTrendTitle => 'বর্তমান ওজনের প্রবণতা';

  @override
  String get onboardingWeightTrendGaining => 'ওজন বাড়ছে';

  @override
  String get onboardingWeightTrendLosing => 'ওজন কমছে';

  @override
  String get onboardingWeightTrendMaintaining => 'ওজন বজায় আছে';

  @override
  String get onboardingNotSure => 'নিশ্চিত নই';

  @override
  String get onboardingBodyFatEstimateTitle => 'শরীরের চর্বির অনুমান';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'সবচেয়ে কাছের দৃশ্যমান অনুমানটি বেছে নিন। নিখুঁত হওয়া জরুরি নয়।';

  @override
  String get onboardingNutritionPreferencesTitle => 'পুষ্টির পছন্দ';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'সেটআপের পরে এই পছন্দগুলো পুষ্টির পরামর্শ নির্ধারণ করে।';

  @override
  String get onboardingPreferredDiet => 'পছন্দের খাদ্যাভ্যাস';

  @override
  String get onboardingDietBalanced => 'সুষম';

  @override
  String get onboardingDietLowFat => 'কম চর্বি';

  @override
  String get onboardingDietLowCarb => 'কম কার্বোহাইড্রেট';

  @override
  String get onboardingDietKeto => 'কিটো';

  @override
  String get onboardingCalorieFloor => 'সর্বনিম্ন ক্যালরি';

  @override
  String get onboardingCalorieFloorHint => 'দৈনিক সর্বনিম্ন কিলোক্যালরি';

  @override
  String get onboardingTrainingDuringProgram => 'প্রোগ্রাম চলাকালীন প্রশিক্ষণ';

  @override
  String get onboardingTrainingNone => 'কোনোটিই নয়';

  @override
  String get onboardingTrainingLifting => 'ওজন প্রশিক্ষণ';

  @override
  String get onboardingTrainingCardio => 'কার্ডিও';

  @override
  String get onboardingTrainingLiftingAndCardio => 'ওজন প্রশিক্ষণ ও কার্ডিও';

  @override
  String get onboardingProteinPreference => 'পছন্দের প্রোটিন গ্রহণ';

  @override
  String get onboardingProteinLow => 'কম';

  @override
  String get onboardingProteinModerate => 'মাঝারি';

  @override
  String get onboardingProteinHigh => 'উচ্চ';

  @override
  String get onboardingProteinVeryHigh => 'খুব উচ্চ';

  @override
  String get onboardingGoalPaceTitle => 'লক্ষ্যের গতি';

  @override
  String get onboardingGoalPaceSubtitle => 'লক্ষ্য ওজন ও সাপ্তাহিক অগ্রগতির হার দেখুন।';

  @override
  String get onboardingInitialDailyBudget => 'প্রাথমিক দৈনিক বাজেট';

  @override
  String get onboardingProjectedEndDate => 'সম্ভাব্য শেষ তারিখ';

  @override
  String get onboardingTargetWeight => 'লক্ষ্য ওজন';

  @override
  String get onboardingTargetGoalRate => 'লক্ষ্যের হার';

  @override
  String get onboardingPerWeek => 'প্রতি সপ্তাহে';

  @override
  String get onboardingPerMonth => 'প্রতি মাসে';

  @override
  String get exerciseProgressTrackExercise => 'একটি ব্যায়াম অনুসরণ করুন';

  @override
  String get exerciseProgressTrackExerciseBody => 'এখানে 1RM প্রবণতা দেখতে একটি ব্যায়াম বেছে নিন।';

  @override
  String get healthCustomMetric => 'কাস্টম পরিমাপ';

  @override
  String get healthLatest => 'সর্বশেষ';

  @override
  String get healthNoEntry => 'কোনো এন্ট্রি নেই';

  @override
  String get healthNotTrackedYet => 'এখনও অনুসরণ করা হয়নি';

  @override
  String get healthChange => 'পরিবর্তন';

  @override
  String get healthNeedTwoEntries => '2টি এন্ট্রি প্রয়োজন';

  @override
  String get healthVersusPrevious => 'আগেরটির তুলনায়';

  @override
  String get healthRecords => 'রেকর্ড';

  @override
  String get presetEstimatedTime => 'আনুমানিক সময়';

  @override
  String get presetNoFocusData => 'এখনও কোনো ফোকাস তথ্য নেই।';

  @override
  String get presetFocusPreviewHelp => 'প্ল্যানের ফোকাস দেখতে শরীরের অংশের তথ্যসহ ওজনের ব্যায়াম যোগ করুন।';

  @override
  String get dashboardReorderHelp => 'আপনার সুবিধামতো ক্রমে সেকশনগুলো টেনে সাজান।';

  @override
  String get exerciseEditorCachedLocally => 'স্থানীয়ভাবে ক্যাশ করা';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return '$countটি ব্যায়াম মিডিয়া এন্ট্রি সিঙ্ক হয়েছে (v$version)।';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'অন্তর্ভুক্ত ব্যায়াম মিডিয়া ম্যানিফেস্ট লোড হয়েছে (v$version)।';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return '$countটি সরঞ্জাম ও অ্যানাটমি মিডিয়া এন্ট্রি সিঙ্ক হয়েছে (v$version)।';
  }

  @override
  String get databaseHealthSchema => 'স্কিমা';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / লক্ষ্য v$target';
  }

  @override
  String get databaseHealthSize => 'আকার';

  @override
  String get databaseHealthJournal => 'জার্নাল';

  @override
  String get databaseHealthTables => 'টেবিল';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tablesটি টেবিল, $indexesটি ইনডেক্স, $triggersটি ট্রিগার';
  }

  @override
  String get databaseHealthFoodSearch => 'খাবার অনুসন্ধান';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foodsটি খাবার, $rowsটি FTS সারি';
  }

  @override
  String get databaseHealthPath => 'পথ';

  @override
  String get dashboardWorkoutInProgress => 'ওয়ার্কআউট চলছে';

  @override
  String get dashboardNoSavedPlans => 'এই জিম প্রোফাইলে কোনো প্ল্যান সংরক্ষিত নেই।';

  @override
  String get exerciseProgressOneRepMax => '1 রিপ সর্বোচ্চ';

  @override
  String get exerciseProgressEstimatedOneRepMax => 'আনুমানিক 1RM';

  @override
  String get onboardingPageWeight => 'ওজন';

  @override
  String get onboardingPageBodyFat => 'শরীরের চর্বি';

  @override
  String get onboardingPageNutrition => 'পুষ্টি';

  @override
  String get onboardingPageGoal => 'লক্ষ্য';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return 'এই সপ্তাহে $count/$total';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return 'সর্বমোট $count';
  }

  @override
  String get dashboardVisualBodyFat => 'দৃশ্যমান শরীরের চর্বি';

  @override
  String get dashboardNewMetric => 'নতুন পরিমাপ';

  @override
  String get dashboardCurrentMetrics => 'বর্তমান পরিমাপ';

  @override
  String get workoutReportDay => 'দিন';

  @override
  String get workoutReportDays => 'দিন';

  @override
  String get workoutReportWeek => 'সপ্তাহ';

  @override
  String get workoutReportMonth => 'মাস';

  @override
  String workoutReportAveragePer(String period) {
    return 'গড় / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'ওয়ার্কআউট';

  @override
  String get workoutReportLongestStreak => 'দীর্ঘতম ধারাবাহিকতা';

  @override
  String get workoutReportMostActive => 'সবচেয়ে সক্রিয়';

  @override
  String get workoutReportNoSessions => 'কোনো সেশন নেই';

  @override
  String get workoutReportWeekday => 'সপ্তাহের দিন';

  @override
  String workoutReportMetricSemantics(String label) {
    return '$label রিপোর্ট পরিমাপ';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit লগ করা হয়েছে';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$date-এ $unit';
  }

  @override
  String get profileDiagnosticsTitle => 'ডায়াগনস্টিকস ও গোপনীয়তা';

  @override
  String get profileDiagnosticsSubtitle => 'ভার্সন, ক্র্যাশ রিপোর্টের সম্মতি, সিঙ্ক ইতিহাস ও ডেটা মুছে ফেলা।';

  @override
  String get diagnosticsTitle => 'ডায়াগনস্টিকস ও গোপনীয়তা';

  @override
  String get diagnosticsSubtitle => 'রিলিজ ডায়াগনস্টিকস বুঝুন ও নিয়ন্ত্রণ করুন।';

  @override
  String get diagnosticsAppSection => 'অ্যাপের তথ্য';

  @override
  String get diagnosticsAppSectionSubtitle => 'সমস্যা জানানোর সময় কাজে লাগে।';

  @override
  String get diagnosticsVersion => 'ভার্সন ও বিল্ড';

  @override
  String get diagnosticsLoading => 'লোড হচ্ছে...';

  @override
  String get diagnosticsUnavailable => 'পাওয়া যাচ্ছে না';

  @override
  String get diagnosticsCrashSection => 'বেনামী ডায়াগনস্টিকস';

  @override
  String get diagnosticsCrashSectionSubtitle => 'অ্যাপের ত্রুটি ও মিডিয়া সিঙ্কের জন্য ঐচ্ছিক বিভাগভিত্তিক রিপোর্ট।';

  @override
  String get diagnosticsCrashReporting => 'বেনামী ডায়াগনস্টিকস শেয়ার করুন';

  @override
  String get diagnosticsCrashUnavailable => 'এই বিল্ডে কনফিগার করা নেই। কোনো বেনামী ডায়াগনস্টিকস শেয়ার করা যাবে না।';

  @override
  String get diagnosticsCrashEnabledBody => 'আপনার সম্মতিতে চালু। বন্ধ করলে Tonos-এ রাখা রিপোর্ট মুছে ফেলার অনুরোধ করা হয়।';

  @override
  String get diagnosticsCrashDisabledBody => 'ডিফল্টভাবে বন্ধ। রিলিজ সমস্যার নির্ণয়ে সাহায্য করতে চাইলে চালু করুন।';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'নকশাতেই গোপনীয়তা';

  @override
  String get diagnosticsPrivacyPromiseBody => 'রিপোর্টে শুধু অ্যাপের সংস্করণ, বিল্ড নম্বর, প্ল্যাটফর্ম, অনুমোদিত বিভাগ, ফলাফল ও আনুমানিক সীমা থাকে। ত্রুটির বার্তা, স্ট্যাক ট্রেস, নাম, স্বাস্থ্য ডেটা, ডেটাবেসের বিষয়বস্তু, স্ক্রিনশট, নেটওয়ার্ক ঠিকানা, ট্রেস বা অ্যানালিটিকস কখনও থাকে না।';

  @override
  String get diagnosticsSyncSection => 'কনটেন্ট সিঙ্ক ইতিহাস';

  @override
  String get diagnosticsSyncSectionSubtitle => 'সর্বশেষ 30টি মিডিয়া ম্যানিফেস্ট ফলাফল শুধু এই ডিভাইসে রাখা হয়।';

  @override
  String get diagnosticsNoSyncEvents => 'এখনও কোনো সিঙ্ক ডায়াগনস্টিক নেই';

  @override
  String get diagnosticsNoSyncEventsBody => 'URL বা ব্যক্তিগত ডেটা ছাড়াই সিঙ্কের ফলাফল এখানে দেখা যাবে।';

  @override
  String get diagnosticsClearHistory => 'সিঙ্ক ইতিহাস মুছুন';

  @override
  String get diagnosticsClearHistoryBody => 'স্থানীয়ভাবে রাখা সব সিঙ্ক ডায়াগনস্টিক মুছে দিন।';

  @override
  String get diagnosticsHistoryCleared => 'সিঙ্ক ডায়াগনস্টিক ইতিহাস মুছে ফেলা হয়েছে।';

  @override
  String get diagnosticsExerciseMedia => 'ব্যায়ামের মিডিয়া';

  @override
  String get diagnosticsSharedMedia => 'শেয়ার করা মিডিয়া';

  @override
  String get diagnosticsRemoteSource => 'রিমোট';

  @override
  String get diagnosticsBundledSource => 'অন্তর্ভুক্ত';

  @override
  String get diagnosticsSyncSucceeded => 'সফল';

  @override
  String get diagnosticsSyncFailed => 'ব্যর্থ';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation: $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration মি.সে. • ম্যানিফেস্ট $version • $itemsটি আইটেম';
  }

  @override
  String get diagnosticsPrivacySection => 'আপনার ডেটা';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'স্থানীয় সংরক্ষণ, ধারণ ও মুছে ফেলা।';

  @override
  String get diagnosticsLocalDataTitle => 'ফিটনেস ডেটা স্থানীয় থাকে';

  @override
  String get diagnosticsLocalDataBody => 'আপনি নিজে ব্যাকআপ এক্সপোর্ট না করলে ওয়ার্কআউট, পুষ্টি, শরীরের মাপ ও প্রোফাইল এই ডিভাইসের অ্যাপ ডেটাবেসেই থাকে।';

  @override
  String get diagnosticsDeletionTitle => 'ডায়াগনস্টিক ও অ্যাপ ডেটা মুছুন';

  @override
  String get diagnosticsDeletionBody => 'উপরের সিঙ্ক ইতিহাস মুছুন এবং বেনামী ডায়াগনস্টিকস বন্ধ করে এই ইনস্টলেশন থেকে পাঠানো রিপোর্ট মুছে ফেলার অনুরোধ করুন। স্থানীয় ডেটাবেস ও ক্যাশ মুছতে ডিভাইস সেটিংসে Tonos-এর স্টোরেজ পরিষ্কার করুন বা অ্যাপ আনইনস্টল করুন।';

  @override
  String get diagnosticsSendTestReport => 'নিয়ন্ত্রিত ডায়াগনস্টিক ইভেন্ট পাঠান';

  @override
  String get diagnosticsSendTestReportBody => 'শুধু স্পষ্টভাবে পরীক্ষার জন্য সক্রিয় করা বিল্ডে উপলব্ধ। একটি নির্দিষ্ট অনুমোদিত ইভেন্ট পাঠায়।';

  @override
  String get diagnosticsTestReportSent => 'নিয়ন্ত্রিত ডায়াগনস্টিক ইভেন্ট পাঠানো হয়েছে।';

  @override
  String get diagnosticsTestReportFailed => 'ডায়াগনস্টিক ইভেন্ট পাঠানো যায়নি। বিল্ড কনফিগারেশন ও সংযোগ পরীক্ষা করুন।';

  @override
  String get diagnosticsDeleteShared => 'শেয়ার করা ডায়াগনস্টিকস মুছুন';

  @override
  String get diagnosticsDeleteSharedBody => 'এই ইনস্টলেশন থেকে পাঠানো প্রমাণযোগ্য রিপোর্ট মুছে ফেলার অনুরোধ করে। সরবরাহকারীর পুনরুদ্ধার ইতিহাসে মুছে ফেলা সারি 30 দিন পর্যন্ত থাকতে পারে।';

  @override
  String get diagnosticsSharedDeleted => 'শেয়ার করা ডায়াগনস্টিকস মুছে ফেলার অনুরোধ করা হয়েছে।';

  @override
  String get diagnosticsSharedDeletionPending => 'সংযোগ থাকলে অ্যাপ খোলার সময় কিছু মুছে ফেলার অনুরোধ আবার চেষ্টা করা হবে।';

  @override
  String get workoutDurabilityRestoreWarning => 'Tonos কোনো সংরক্ষিত ওয়ার্কআউট আছে কি না পরীক্ষা করতে পারেনি। নতুন ওয়ার্কআউট শুরুর আগে আবার চেষ্টা করুন।';

  @override
  String get workoutDurabilityDraftSaveWarning => 'আপনার ওয়ার্কআউটের ব্যাকআপ হালনাগাদ নয়। নিরাপদে আবার শুরু করতে Tonos খোলা রাখুন এবং আবার চেষ্টা করুন।';

  @override
  String get workoutDurabilityProgressionWarning => 'আপনার ওয়ার্কআউট সংরক্ষিত হয়েছে, তবে পরিকল্পনার অগ্রগতি এখনো অপেক্ষমাণ। স্টোরেজ পাওয়া গেলে আবার চেষ্টা করুন।';

  @override
  String get databaseConfirmExportTitle => 'ব্যক্তিগত ডেটা রপ্তানি করবেন?';

  @override
  String get databaseConfirmExportBody => 'এই ব্যাকআপটি এনক্রিপ্ট করা নয় এমন একটি JSON ফাইল, যাতে আপনার ওয়ার্কআউট, পুষ্টি, শারীরিক পরিমাপ, প্রোফাইল ও পছন্দ থাকতে পারে। এটি কেবল বিশ্বস্ত স্থানে সংরক্ষণ করুন।';

  @override
  String get databaseContinueExport => 'তবুও রপ্তানি করুন';

  @override
  String get databaseExportFailedSafe => 'ডেটাবেস রপ্তানি তৈরি করা যায়নি। আপনার অ্যাপের ডেটা অপরিবর্তিত আছে।';

  @override
  String get databaseImportFileTooLarge => 'এই আমদানিটি খুব বড়। 25 MB-এর চেয়ে ছোট ডেটাবেস ব্যাকআপ বেছে নিন।';

  @override
  String get databaseImportBlockedSafe => 'এই ডেটাবেস ব্যাকআপ আমদানি করা যায়নি। আপনার বর্তমান অ্যাপ ডেটা অপরিবর্তিত আছে।';

  @override
  String get databaseImportFailedSafe => 'ডেটাবেস আমদানি সম্পন্ন হয়নি। আপনার বর্তমান অ্যাপ ডেটা নিরাপদ রাখা হয়েছে।';

  @override
  String get speedDialLogFood => 'খাবার লগ করুন';

  @override
  String get speedDialLogMeasurement => 'পরিমাপ লগ করুন';

  @override
  String get healthTapToLog => '+ ট্যাপ করে লগ করুন';
}
