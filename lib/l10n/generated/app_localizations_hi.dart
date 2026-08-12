// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent% शरीर का वजन/सप्ताह';
  }

  @override
  String get dashboardExerciseFallback => 'व्यायाम';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    return '$equipment - $count बार';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total पूरे';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return '$bodyPart शरीर हीटमैप';
  }

  @override
  String get focusedSetsTitle => 'लक्षित सेट';

  @override
  String get bodyPartNeck => 'गर्दन';

  @override
  String get bodyPartShoulders => 'कंधे';

  @override
  String get bodyPartChest => 'छाती';

  @override
  String get bodyPartCore => 'कोर';

  @override
  String get bodyPartUpperBack => 'ऊपरी पीठ';

  @override
  String get bodyPartLowerBack => 'निचली पीठ';

  @override
  String get bodyPartBiceps => 'बाइसेप्स';

  @override
  String get bodyPartTriceps => 'ट्राइसेप्स';

  @override
  String get bodyPartForearms => 'अग्रबाहु';

  @override
  String get bodyPartHips => 'कूल्हे';

  @override
  String get bodyPartHamstrings => 'हैमस्ट्रिंग';

  @override
  String get bodyPartQuads => 'क्वाड्रिसेप्स';

  @override
  String get bodyPartCalves => 'पिंडलियां';

  @override
  String databaseSaveFile(String filename) {
    return '$filename सहेजें';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename आपकी चुनी हुई जगह पर सहेजा गया।';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (प्रोडक्शन)';
  }

  @override
  String dashboardDaysAgo(int count) {
    return '$count दिन पहले';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1स';

  @override
  String get workoutReportRangeOneMonthShort => '1म';

  @override
  String get workoutReportRangeThreeMonthsShort => '3म';

  @override
  String get workoutReportRangeSixMonthsShort => '6म';

  @override
  String get workoutReportRangeOneYearShort => '1व';

  @override
  String get workoutReportRangeAll => 'सभी';

  @override
  String get workoutReportRangeOneWeek => '1 सप्ताह';

  @override
  String get workoutReportRangeOneMonth => '1 महीना';

  @override
  String get workoutReportRangeThreeMonths => '3 महीने';

  @override
  String get workoutReportRangeSixMonths => '6 महीने';

  @override
  String get workoutReportRangeOneYear => '1 वर्ष';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    return '$count वर्कआउट';
  }

  @override
  String workoutReportMinutesCount(int count) {
    return '$count मिनट';
  }

  @override
  String workoutReportHoursCount(int count) {
    return '$count घंटे';
  }

  @override
  String workoutReportHoursMinutes(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String get workoutReportMinuteShort => 'मिनट';

  @override
  String get workoutReportHourShort => 'घं';

  @override
  String get workoutReportNoWorkoutsYet => 'अभी कोई वर्कआउट नहीं है';

  @override
  String get workoutReportNoTrainingTimeYet => 'अभी कोई प्रशिक्षण समय नहीं है';

  @override
  String get workoutReportNoVolumeYet => 'अभी कोई वॉल्यूम दर्ज नहीं है';

  @override
  String get workoutReportNoWorkoutsBody => 'यह रिपोर्ट बनाना शुरू करने के लिए एक वर्कआउट पूरा करें।';

  @override
  String get workoutReportNoTrainingTimeBody => 'पूरे किए गए सत्रों के मिनट यहाँ अपने आप जुड़ेंगे।';

  @override
  String get workoutReportNoVolumeBody => 'वॉल्यूम की प्रवृत्तियाँ बनाने के लिए पूरे किए गए सेटों का वजन दर्ज करें।';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'UI और स्वरूप';

  @override
  String get uiAppearanceSubtitle => 'Tonos का रूप और नीचे के टैब का व्यवहार नियंत्रित करें।';

  @override
  String get displaySettingsTitle => 'डिस्प्ले';

  @override
  String get displaySettingsSubtitle => 'त्वरित दृश्य प्राथमिकताएँ।';

  @override
  String get darkModeTitle => 'डार्क मोड';

  @override
  String get darkModeSubtitle => 'ऐप की गहरी थीम का उपयोग करें।';

  @override
  String get replayOnboardingTitle => 'ऑनबोर्डिंग दोबारा चलाएँ';

  @override
  String get replayOnboardingSubtitle => 'सेटअप फिर से खोलने के लिए इसे चालू करें। पूरा होने के बाद यह बंद हो जाता है।';

  @override
  String get weightUnitsTitle => 'वजन इकाइयाँ';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'वर्कआउट वजन और वॉल्यूम को $unit में दिखाएँ।';
  }

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSubtitle => 'वह भाषा चुनें जिसका Tonos उपयोग करता है।';

  @override
  String get systemDefaultLanguage => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get englishLanguage => 'अंग्रेज़ी';

  @override
  String get canadianFrenchLanguage => 'फ़्रेंच (कनाडा)';

  @override
  String get navigationSettingsTitle => 'नेविगेशन';

  @override
  String get navigationSettingsSubtitle => 'चुनें कि कौन से नीचे के टैब दिखें और किस क्रम में।';

  @override
  String get editBottomTabsTitle => 'नीचे के टैब संपादित करें';

  @override
  String get editBottomTabsSubtitle => 'सक्रिय टैब का क्रम बदलें या अप्रयुक्त टैब छिपाएँ।';

  @override
  String get displaySettingsTutorialTitle => 'डिस्प्ले सेटिंग्स';

  @override
  String get displaySettingsTutorialBody => 'डार्क मोड, भाषा, ऑनबोर्डिंग दोबारा चलाना और पाउंड/किलोग्राम बदलना नियंत्रित करें।';

  @override
  String get bottomTabsTutorialTitle => 'नीचे के टैब';

  @override
  String get bottomTabsTutorialBody => 'दिखाए जाने वाले नीचे के टैब और उनका क्रम संपादित करें।';

  @override
  String get onboardingPageWelcome => 'स्वागत';

  @override
  String get onboardingPageBasics => 'बुनियादी जानकारी';

  @override
  String get onboardingPageFocus => 'फोकस';

  @override
  String get onboardingPageGymProfile => 'जिम प्रोफ़ाइल';

  @override
  String get onboardingPageEquipment => 'उपकरण';

  @override
  String get onboardingPageWorkoutPlan => 'वर्कआउट योजना';

  @override
  String get onboardingPagePlanOverview => 'योजना अवलोकन';

  @override
  String get onboardingPageSummary => 'सारांश';

  @override
  String get onboardingPreviousStepTooltip => 'पिछला चरण';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get onboardingFinish => 'समाप्त करें';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingFinishing => 'समाप्त किया जा रहा है...';

  @override
  String get onboardingFinishSetup => 'सेटअप पूरा करें';

  @override
  String get onboardingNext => 'अगला';

  @override
  String get onboardingSkipSetupTitle => 'सेटअप छोड़ें?';

  @override
  String get onboardingSkipSetupBody => 'आप अभी ऐप होमपेज पर जा सकते हैं और सेटअप बाद में पूरा कर सकते हैं। आप सेटिंग्स पेज से ऑनबोर्डिंग फिर से खोल सकते हैं।';

  @override
  String get onboardingCancel => 'रद्द करें';

  @override
  String get onboardingConfirm => 'ठीक है';

  @override
  String onboardingFinishError(String error) {
    return 'सेटअप पूरा नहीं हो सका: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Tonos में आपका स्वागत है';

  @override
  String get onboardingWelcomeSubtitle => 'एक त्वरित सेटअप वर्कआउट, पोषण और प्रगति ट्रैकिंग को व्यक्तिगत बनाने में मदद करता है।';

  @override
  String get onboardingLanguageSelectionTitle => 'अपनी भाषा चुनें';

  @override
  String get onboardingLanguageSelectionHelp => 'सेटअप तुरंत अपडेट हो जाता है। आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get onboardingTrainFeatureTitle => 'संदर्भ के साथ ट्रेन करें';

  @override
  String get onboardingTrainFeatureBody => 'वर्कआउट सुझावों को आकार देने के लिए अपनी प्राथमिकताएँ और इतिहास उपयोग करें।';

  @override
  String get onboardingNutritionFeatureTitle => 'पोषण लक्ष्यों में सहायता';

  @override
  String get onboardingNutritionFeatureBody => 'ऐप से पोषण मार्गदर्शन का स्तर चुनें जो आप चाहते हैं।';

  @override
  String get onboardingProgressFeatureTitle => 'प्रगति ट्रैक करें';

  @override
  String get onboardingProgressFeatureBody => 'अपने प्रशिक्षण और पोषण डेटा को समय के साथ जुड़ा रखें।';

  @override
  String get onboardingBasicsTitle => 'बुनियादी जानकारी दें';

  @override
  String get onboardingBasicsSubtitle => 'ये विवरण वैकल्पिक हैं, लेकिन ये भविष्य की गणनाओं में मदद करते हैं।';

  @override
  String get onboardingNameLabel => 'नाम';

  @override
  String get onboardingNameHint => 'अपना नाम दर्ज करें';

  @override
  String get onboardingGenderLabel => 'लिंग';

  @override
  String get onboardingGenderMale => 'पुरुष';

  @override
  String get onboardingGenderFemale => 'महिला';

  @override
  String get onboardingGenderOther => 'अन्य';

  @override
  String get onboardingGenderPreferNotToSay => 'न बताना पसंद करूंगा/करूंगी';

  @override
  String get onboardingDateOfBirthLabel => 'जन्म तिथि';

  @override
  String get onboardingSelectDate => 'तारीख चुनें';

  @override
  String get onboardingHeightLabel => 'कद';

  @override
  String get onboardingHeightHint => 'जैसे 5\'10\" या 178 सेमी';

  @override
  String get onboardingWorkoutWeightUnits => 'वर्कआउट वजन इकाइयाँ';

  @override
  String get onboardingCurrentWeightLabel => 'वर्तमान वजन';

  @override
  String get onboardingWeightHintPounds => 'जैसे 160';

  @override
  String get onboardingWeightHintKilograms => 'जैसे 72';

  @override
  String get onboardingPounds => 'पाउंड';

  @override
  String get onboardingKilograms => 'किलोग्राम';

  @override
  String get onboardingFocusTitle => 'Tonos किसे व्यक्तिगत बनाए?';

  @override
  String get onboardingFocusSubtitle => 'वे क्षेत्र चुनें जिन्हें आप अभी सेट करना चाहते हैं। आप इसे बाद में बदल सकते हैं।';

  @override
  String get onboardingNutritionDataTitle => 'पोषण डेटा';

  @override
  String get onboardingNutritionDataPausedBody => 'इस क्षेत्र का पुनर्निर्माण होने तक पोषण सेटअप रुका हुआ है।';

  @override
  String get onboardingLater => 'बाद में';

  @override
  String get onboardingExerciseDataTitle => 'व्यायाम डेटा';

  @override
  String get onboardingExerciseDataBody => 'अपनी जिम प्रोफ़ाइल और पहली वर्कआउट योजनाएँ सेट करें।';

  @override
  String get onboardingGymSpaceTitle => 'आप कहाँ वर्कआउट करते हैं?';

  @override
  String get onboardingGymSpaceSubtitle => 'शुरुआती स्थान चुनें। इसके उपकरण व्यायाम सुझावों और बनाई गई वर्कआउट को आकार देंगे।';

  @override
  String get onboardingEquipmentLoadError => 'उपकरण लोड नहीं हो सका।';

  @override
  String get onboardingTryAgain => 'फिर से प्रयास करें';

  @override
  String get onboardingGymCustomTitle => 'अनुकूलित स्थान';

  @override
  String get onboardingGymCustomSubtitle => 'हर उपलब्ध वस्तु चुनकर अपनी प्रोफ़ाइल डिज़ाइन करें।';

  @override
  String get onboardingGymCustomDefaultName => 'कस्टम स्थान';

  @override
  String get onboardingGymSkipTitle => 'यह चरण छोड़ें';

  @override
  String get onboardingGymSkipSubtitle => 'सामान्य प्रोफ़ाइल रखें और उपकरण बाद में चुनें।';

  @override
  String get onboardingGymGeneralName => 'सामान्य';

  @override
  String get onboardingGymCommercialTitle => 'कमर्शियल जिम';

  @override
  String get onboardingGymCommercialSubtitle => 'हर उपलब्ध उपकरण विकल्प से शुरू करें, फिर जो आपके जिम में नहीं है उसे हटा दें।';

  @override
  String get onboardingGymCommercialDefaultName => 'कमर्शियल जिम';

  @override
  String get onboardingGymHomeTitle => 'होम जिम';

  @override
  String get onboardingGymHomeSubtitle => 'फ्री वेट्स, बैंड, बेंच और बॉडीवेट उपकरण के साथ व्यावहारिक घरेलू सेटअप।';

  @override
  String get onboardingGymHomeDefaultName => 'होम जिम';

  @override
  String get onboardingGymCalisthenicsTitle => 'कैलिस्थेनिक्स';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'बार, रिंग, बैंड और बुनियादी एक्सेसरी सहित बॉडीवेट-केंद्रित उपकरण।';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'कैलिस्थेनिक्स';

  @override
  String get onboardingGymPowerliftingTitle => 'पावरलिफ्टिंग';

  @override
  String get onboardingGymPowerliftingSubtitle => 'प्लेट, पावर रैक और बेंच वाला बारबेल-आधारित स्थान।';

  @override
  String get onboardingGymPowerliftingDefaultName => 'पावरलिफ्टिंग';

  @override
  String get onboardingGymFreeWeightsTitle => 'फ्री वेट्स';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'डंबल, केटलबेल, प्लेट, बेंच और बॉडीवेट मूवमेंट।';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'फ्री वेट्स';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'अपने वर्कआउट स्थान की समीक्षा करें';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Tonos के इसे बनाने से पहले प्रोफ़ाइल का नाम बदलें या उसके उपकरण समायोजित करें।';

  @override
  String get onboardingProfileNameLabel => 'प्रोफ़ाइल नाम';

  @override
  String get onboardingIncludedEquipmentTitle => 'शामिल उपकरण';

  @override
  String get onboardingIncludedEquipmentBody => 'जब प्रोफ़ाइल सक्रिय होगी तो केवल इस उपकरण द्वारा समर्थित व्यायाम सुझाए जाएँगे।';

  @override
  String get onboardingNoEquipmentSelected => 'अभी कोई उपकरण चयनित नहीं है।';

  @override
  String get onboardingReset => 'रीसेट करें';

  @override
  String get onboardingEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'वर्कआउट स्थान संपादित करें';

  @override
  String get onboardingSelectEquipmentError => 'कम से कम एक उपकरण विकल्प चुनें।';

  @override
  String get onboardingWorkoutPlanTitle => 'अपनी वर्कआउट योजना सेट करें';

  @override
  String get onboardingWorkoutPlanSubtitle => 'चुनें कि Tonos आपकी पहली योजनाएँ कैसे तैयार करे। आप बाद में हमेशा योजनाएँ जोड़, संग्रहित या संपादित कर सकते हैं।';

  @override
  String get onboardingManualPlanTitle => 'अपनी योजनाएँ मैन्युअल रूप से बनाएँ';

  @override
  String get onboardingManualPlanSubtitle => 'खाली योजना से शुरू करें, फिर खुद व्यायाम और सेट जोड़ें।';

  @override
  String get onboardingPremadePlanTitle => 'तैयार व्यायाम योजनाओं का उपयोग करें';

  @override
  String get onboardingPremadePlanSubtitle => 'अंतर्निहित फुल बॉडी, अपर/लोअर, पुश-पुल-लेग्स और बॉडी-पार्ट स्प्लिट योजनाएँ देखें।';

  @override
  String get onboardingGeneratePlanTitle => 'व्यायाम योजनाएँ बनाएँ';

  @override
  String get onboardingGeneratePlanSubtitle => 'कुछ सेटअप प्रश्नों के उत्तर दें और Tonos को अपनी प्रोफ़ाइल के लिए एक कस्टम योजना बनाने दें।';

  @override
  String get onboardingSkipPlanTitle => 'यह चरण छोड़ें';

  @override
  String get onboardingSkipPlanSubtitle => 'योजनाएँ जोड़े बिना शुरू करें। आप उन्हें बाद में ट्रेन से सेट कर सकते हैं।';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ सक्रिय योजनाओं में जोड़ी गई हैं।',
      one: '$count योजना सक्रिय योजनाओं में जोड़ी गई है।',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'अपनी योजनाएँ देखें';

  @override
  String get onboardingReviewPlansSubtitle => 'ये योजनाएँ आपकी सक्रिय योजनाओं में जोड़ी गई हैं। जारी रखने से पहले किसी भी योजना को खोलकर देखें या समायोजित करें।';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ सक्रिय योजनाओं में तैयार हैं।',
      one: '$count योजना सक्रिय योजनाओं में तैयार है।',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'योजना अवलोकन अभी लोड नहीं हो सका।';

  @override
  String get onboardingNoAddedPlans => 'कोई जोड़ी गई योजना नहीं मिली। योजना जोड़ने के लिए वापस जाएँ या यह चरण छोड़ दें।';

  @override
  String get onboardingReadyTitle => 'शुरू करने के लिए तैयार';

  @override
  String get onboardingReadySubtitle => 'अपना सेटअप देखें, फिर Tonos में प्रवेश करने के लिए समाप्त करें।';

  @override
  String get onboardingSummaryName => 'नाम';

  @override
  String get onboardingSummaryGender => 'लिंग';

  @override
  String get onboardingSummaryDateOfBirth => 'जन्म तिथि';

  @override
  String get onboardingSummaryHeight => 'कद';

  @override
  String get onboardingSummaryWeight => 'वजन';

  @override
  String get onboardingSummaryWorkoutUnits => 'वर्कआउट इकाइयाँ';

  @override
  String get onboardingSummaryIncluded => 'शामिल';

  @override
  String get onboardingSummaryGymProfile => 'जिम प्रोफ़ाइल';

  @override
  String get onboardingSummaryEquipment => 'उपकरण';

  @override
  String get onboardingSummaryWorkoutPlans => 'वर्कआउट योजनाएँ';

  @override
  String get onboardingSummaryProfileSection => 'प्रोफ़ाइल';

  @override
  String get onboardingSummaryTrainingSection => 'प्रशिक्षण सेटअप';

  @override
  String get onboardingSummaryNutritionSection => 'पोषण प्राथमिकताएँ';

  @override
  String get onboardingSummaryDiet => 'आहार';

  @override
  String get onboardingSummaryProteinPreference => 'प्रोटीन प्राथमिकता';

  @override
  String get onboardingIncludedNutrition => 'पोषण सेटअप';

  @override
  String get onboardingIncludedExercise => 'व्यायाम सेटअप';

  @override
  String get onboardingIncludedBasicOnly => 'केवल बुनियादी प्रोफ़ाइल';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चयनित',
      one: '$count चयनित',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ जोड़ी गईं',
      one: '$count योजना जोड़ी गई',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'तैयार योजना चयनित';

  @override
  String get onboardingPlanSummaryGenerated => 'जनरेट करना चयनित';

  @override
  String get onboardingPlanSummarySkipped => 'छोड़ा गया';

  @override
  String get onboardingPlanSummaryManual => 'मैन्युअल चयनित';

  @override
  String get onboardingPlanSummaryNotSelected => 'चयनित नहीं';

  @override
  String get onboardingNewPlan => 'नई योजना';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'नई योजना $number';
  }

  @override
  String get tabTrain => 'प्रशिक्षण';

  @override
  String get tabTrainSecondary => 'प्रशिक्षण2';

  @override
  String get tabCatalog => 'कैटलॉग';

  @override
  String get tabLogbook => 'लॉगबुक';

  @override
  String get tabProgress => 'प्रगति';

  @override
  String get tabProfile => 'प्रोफ़ाइल';

  @override
  String get tabDashboard => 'डैशबोर्ड';

  @override
  String get tabNutrition => 'पोषण';

  @override
  String get tabNutritionLog => 'पोषण लॉग';

  @override
  String get tabCombinedHistory => 'संयुक्त इतिहास';

  @override
  String get tabFormAndPosing => 'फॉर्म और पोज़िंग';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileSubtitle => 'Tonos को व्यक्तिगत बनाएँ, प्रशिक्षण डिफ़ॉल्ट प्रबंधित करें और अपना डेटा स्वस्थ रखें।';

  @override
  String get profileAccountSectionTitle => 'खाता';

  @override
  String get profileAccountSectionSubtitle => 'आपकी पहचान और ऐप का स्वरूप।';

  @override
  String get profileUserInformationTitle => 'उपयोगकर्ता जानकारी';

  @override
  String get profileUserInformationSubtitle => 'नाम, शारीरिक विवरण और गतिविधि प्रोफ़ाइल।';

  @override
  String get profileUiAppearanceTitle => 'UI और स्वरूप';

  @override
  String get profileUiAppearanceSubtitle => 'थीम, ऑनबोर्डिंग और नीचे के टैब सेटअप।';

  @override
  String get profileGuidedTutorialsTitle => 'निर्देशित ट्यूटोरियल';

  @override
  String get profileGuidedTutorialsSubtitle => 'वॉकथ्रू दोबारा चलाएँ और निर्देशित सहायता रीसेट करें।';

  @override
  String get profileTrainingSectionTitle => 'प्रशिक्षण';

  @override
  String get profileTrainingSectionSubtitle => 'व्यायाम डिफ़ॉल्ट और प्रगति से जुड़े नियंत्रण।';

  @override
  String get profileGymWorkoutSettingsTitle => 'जिम और वर्कआउट सेटिंग्स';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'वर्कआउट बनाना, रैंकिंग, फ्लो और उपकरण तर्क।';

  @override
  String get profileProgressSettingsTitle => 'प्रगति सेटिंग्स';

  @override
  String get profileProgressSettingsSubtitle => 'माप और ट्रेंड ट्रैकिंग सेटअप।';

  @override
  String get profileDataSectionTitle => 'डेटा';

  @override
  String get profileDataSectionSubtitle => 'डेटाबेस उपकरण, एक्सपोर्ट, इम्पोर्ट और रखरखाव।';

  @override
  String get profileDatabaseSettingsTitle => 'डेटाबेस सेटिंग्स';

  @override
  String get profileDatabaseSettingsSubtitle => 'इम्पोर्ट, एक्सपोर्ट, स्वास्थ्य जाँच और रखरखाव उपकरण।';

  @override
  String get profileNutritionSectionTitle => 'पोषण';

  @override
  String get profileNutritionSectionSubtitle => 'इस क्षेत्र के पुनर्निर्माण के दौरान पोषण सेटिंग्स रुकी हुई हैं।';

  @override
  String get profileDietNutritionSettingsTitle => 'आहार और पोषण सेटिंग्स';

  @override
  String get profileDietNutritionSettingsSubtitle => 'पोषण लक्ष्य और प्राथमिकताएँ बाद में वापस आएँगी।';

  @override
  String get profileLater => 'बाद में';

  @override
  String get profileAccountTutorialTitle => 'खाता सेटिंग्स';

  @override
  String get profileAccountTutorialBody => 'यहाँ से अपनी व्यक्तिगत जानकारी, डिस्प्ले प्राथमिकताएँ, वज़न इकाइयाँ, ऑनबोर्डिंग, नीचे के टैब और निर्देशित ट्यूटोरियल अपडेट करें।';

  @override
  String get profileTrainingTutorialTitle => 'प्रशिक्षण सेटिंग्स';

  @override
  String get profileTrainingTutorialBody => 'जिम प्रोफ़ाइल, जनरेशन नियम, शरीर-भाग रैंकिंग, प्रगति सेटिंग्स और अन्य प्रशिक्षण डिफ़ॉल्ट नियंत्रित करें।';

  @override
  String get profileDataTutorialTitle => 'डेटा उपकरण';

  @override
  String get profileDataTutorialBody => 'डेटाबेस सेटिंग्स में आप अपने स्थानीय वर्कआउट डेटा को एक्सपोर्ट, इम्पोर्ट, जाँच और बनाए रखते हैं।';

  @override
  String catalogLoadError(String error) {
    return 'कैटलॉग लोड नहीं हो सका: $error';
  }

  @override
  String get catalogNoData => 'अभी कोई कैटलॉग डेटा उपलब्ध नहीं।';

  @override
  String get catalogExerciseTitle => 'व्यायाम कैटलॉग';

  @override
  String get catalogMostUsedExercises => 'सबसे अधिक उपयोग किए गए व्यायाम';

  @override
  String get catalogNoExerciseHistory => 'अपने सबसे सामान्य व्यायाम यहाँ देखने के लिए वर्कआउट पूरे करें।';

  @override
  String get catalogTargetAnatomyTitle => 'लक्षित शरीर रचना';

  @override
  String get catalogBodyparts => 'शरीर भाग';

  @override
  String get catalogMuscles => 'मांसपेशियाँ';

  @override
  String get catalogNoBodypartHistory => 'अभी कोई शरीर-भाग इतिहास नहीं।';

  @override
  String get catalogNoMuscleHistory => 'अभी कोई मांसपेशी इतिहास नहीं।';

  @override
  String get catalogExerciseTutorialTitle => 'व्यायाम कैटलॉग';

  @override
  String get catalogExerciseTutorialBody => 'आपके सबसे अधिक उपयोग किए गए व्यायाम पहले दिखते हैं। पूरा कैटलॉग खोलने, मूवमेंट खोजने और विवरण देखने के लिए कार्ड टैप करें।';

  @override
  String get catalogAnatomyTutorialTitle => 'लक्षित शरीर रचना';

  @override
  String get catalogAnatomyTutorialBody => 'यह आपके सबसे अधिक प्रशिक्षित शरीर भागों और मांसपेशियों को सारांशित करता है। केंद्रित व्यायाम सूची के लिए किसी भी तरफ टैप करें।';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार',
      one: '1 बार',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेट',
      one: '1 सेट',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'कृपया कम से कम दो सक्रिय टैब रखें।';

  @override
  String get navEditorSavedMessage => 'नीचे के टैब सहेज दिए गए';

  @override
  String get navEditorTitle => 'नीचे के टैब संपादित करें';

  @override
  String get navEditorSubtitle => 'नीचे की पट्टी में क्या दिखेगा चुनें और सक्रिय टैब का क्रम बदलें।';

  @override
  String get navEditorSave => 'टैब सहेजें';

  @override
  String get navEditorActiveTitle => 'सक्रिय टैब';

  @override
  String get navEditorActiveSubtitle => 'क्रम बदलने के लिए खींचें। प्रोफ़ाइल उपलब्ध रहेगी।';

  @override
  String get navEditorInactiveTitle => 'निष्क्रिय टैब';

  @override
  String get navEditorInactiveSubtitle => 'जब चाहें इन्हें फिर से चालू करें।';

  @override
  String get navEditorNoInactiveTabs => 'कोई निष्क्रिय टैब नहीं है।';

  @override
  String get navEditorAlwaysShown => 'हमेशा दिखाएँ';

  @override
  String get navEditorVisible => 'नीचे के नेविगेशन में दिखाई देता है';

  @override
  String get navEditorHidden => 'नीचे के नेविगेशन में छिपा हुआ';

  @override
  String get trainTutorialSpacesTitle => 'प्रशिक्षण में दो स्थान हैं';

  @override
  String get trainTutorialSpacesBody => 'अवलोकन आपके तैयार-से-उपयोग वर्कआउट नियंत्रणों को आगे रखता है। प्लान में आप अपने सहेजे हुए प्लान देख, बना और प्रबंधित कर सकते हैं।';

  @override
  String get trainTutorialWeeklyTitle => 'साप्ताहिक अवलोकन';

  @override
  String get trainTutorialWeeklyBody => 'यह दिखाता है कि आपने हाल में किन शरीर-भागों को प्रशिक्षित किया है। पूरा साप्ताहिक सेट विवरण खोलने के लिए फ़ोकस्ड सेट सूची टैप करें।';

  @override
  String get trainTutorialActivePlansTitle => 'सक्रिय प्लान';

  @override
  String get trainTutorialActivePlansBody => 'सक्रिय प्लान वे रूटीन हैं जिन्हें आप आसानी से उपलब्ध रखना चाहते हैं। अवलोकन टैब पर तैयार रहने वाले प्लान चुनने के लिए पेन का उपयोग करें।';

  @override
  String get trainTutorialStartTitle => 'शुरू करें या अनुकूलित करें';

  @override
  String get trainTutorialStartBody => 'वर्कआउट शुरू करें एक खाली सेशन शुरू करता है। अनुकूलित करें आपके इतिहास, प्रोफ़ाइल उपकरण, फ़ोकस और रिकवरी नियमों से सेशन बनाता है।';

  @override
  String get trainTutorialProfilesTitle => 'जिम प्रोफ़ाइल';

  @override
  String get trainTutorialProfilesBody => 'किसी अलग जगह प्रशिक्षण लेने पर प्रोफ़ाइल बदलें, ताकि बनाए गए वर्कआउट और व्यायाम बदलाव केवल उपलब्ध उपकरण का उपयोग करें।';

  @override
  String get trainSelectProfileFirst => 'कृपया पहले एक जिम प्रोफ़ाइल चुनें।';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लान बनाए गए।',
      one: '1 प्लान बनाया गया।',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'नया प्लान $number',
      one: 'नया प्लान',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'अनुकूलित वर्कआउट $date $time';
  }

  @override
  String get trainRestTitle => 'आराम करने के लिए कुछ समय लें';

  @override
  String get trainRestBody => 'आपका हालिया प्रशिक्षण पहले ही कई शरीर-भाग सीमाओं पर है, इसलिए अनुकूलित वर्कआउट रिकवरी पर बहुत अधिक दबाव डालेगा।';

  @override
  String get commonOkay => 'ठीक है';

  @override
  String get trainNoEligibleExercises => 'इस प्रोफ़ाइल के लिए कोई उपयुक्त व्यायाम नहीं मिला।';

  @override
  String get trainAnotherWorkoutActive => 'दूसरा वर्कआउट पहले से सक्रिय है, इसलिए उसे बिना बदलाव के रखा गया।';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'अनुकूलित वर्कआउट शुरू नहीं हो सका: $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    return 'अनुकूलित वर्कआउट शुरू हुआ। $count व्यायामों के लिए अभी भी मैन्युअल वज़न चाहिए।';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    return '$count नए व्यायामों के लिए शुरुआती वज़न के साथ अनुकूलित वर्कआउट शुरू हुआ।';
  }

  @override
  String get trainGymProfilesTooltip => 'जिम प्रोफ़ाइल';

  @override
  String get trainOverviewTab => 'अवलोकन';

  @override
  String get trainPlansTab => 'प्लान';

  @override
  String get trainActivePlans => 'सक्रिय प्लान';

  @override
  String get trainEditActivePlans => 'सक्रिय प्लान संपादित करें';

  @override
  String get trainSelectProfileForPlans => 'सक्रिय प्लान चुनने के लिए एक जिम प्रोफ़ाइल चुनें।';

  @override
  String get trainChooseActivePlans => 'यहाँ दिखने वाले प्लान चुनने के लिए पेन को टैप करें।';

  @override
  String get trainSelectedPlansMissing => 'चुने हुए प्लान अब उपलब्ध नहीं हैं। उन्हें अपडेट करने के लिए पेन को टैप करें।';

  @override
  String get trainArchivedPlans => 'संग्रहीत प्लान';

  @override
  String get trainNoActivePlans => 'अभी कोई सक्रिय प्लान नहीं है। तैयार रहने वाले प्लान चुनने के लिए अवलोकन सक्रिय प्लान कार्ड पर पेन का उपयोग करें।';

  @override
  String get trainNoArchivedPlans => 'कोई संग्रहीत प्लान नहीं है।';

  @override
  String get trainManagePlans => 'प्लान प्रबंधित करें';

  @override
  String get trainPremadePlans => 'तैयार प्लान';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुनी हुई रूटीन आपके प्लान में कॉपी करने के लिए उपलब्ध हैं।',
      one: '1 चुनी हुई रूटीन आपके प्लान में कॉपी करने के लिए उपलब्ध है।',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'तैयार प्लान देखें';

  @override
  String get trainGenerateCustomPlans => 'कस्टम प्लान बनाएँ';

  @override
  String get trainManuallyAddPlan => 'मैन्युअली प्लान जोड़ें';

  @override
  String get trainStartWorkout => 'वर्कआउट शुरू करें';

  @override
  String get trainOptimize => 'अनुकूलित करें';

  @override
  String get trainOptimizedSettings => 'अनुकूलित वर्कआउट सेटिंग्स';

  @override
  String planManagementDefaultName(int id) {
    return 'योजना $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'सक्रिय योजनाएँ';

  @override
  String get planManagementActiveTutorialBody => 'ये योजनाएँ ट्रेन अवलोकन पर दिखती रहती हैं। बिना हटाए किसी को छिपाना हो तो संग्रहित करें का उपयोग करें।';

  @override
  String get planManagementArchivedTutorialTitle => 'संग्रहित योजनाएँ';

  @override
  String get planManagementArchivedTutorialBody => 'संग्रहित योजनाएँ अभी भी सहेजी जाती हैं। अवलोकन में वापस लाने के लिए यहाँ कोई भी योजना सक्रिय करें।';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return '$plan अपडेट नहीं हो सका: $error';
  }

  @override
  String get planManagementTitle => 'योजनाएँ प्रबंधित करें';

  @override
  String get planManagementLoadFailed => 'योजनाएँ लोड नहीं हो सकीं';

  @override
  String get commonTryAgain => 'फिर से प्रयास करें';

  @override
  String get planManagementIntro => 'चुनें कि आपके ट्रेन अवलोकन पर क्या तैयार रहे। संग्रहित योजनाएँ सहेजी रहती हैं और कभी भी सक्रिय की जा सकती हैं।';

  @override
  String get planManagementActiveSubtitle => 'ट्रेन अवलोकन पर दिखाया गया।';

  @override
  String get planManagementNoActive => 'अभी कोई सक्रिय योजना नहीं। इसे अवलोकन पर पिन करने के लिए नीचे कोई योजना सक्रिय करें।';

  @override
  String get planManagementArchive => 'संग्रहित करें';

  @override
  String get planManagementArchivedSubtitle => 'सहेजी गई योजनाएँ जो अवलोकन से बाहर रहती हैं।';

  @override
  String get planManagementNoArchived => 'कोई संग्रहित योजना नहीं।';

  @override
  String get planManagementActivate => 'सक्रिय करें';

  @override
  String get planManagementAutomatic => 'स्वचालित योजना';

  @override
  String get planManagementVisible => 'अवलोकन पर दिख रहा है';

  @override
  String get planManagementHidden => 'अवलोकन से छिपी';

  @override
  String get presetsNoPlans => 'कोई प्लान नहीं मिला।';

  @override
  String get presetsNoProfile => 'कोई प्रोफ़ाइल नहीं चुनी गई।';

  @override
  String get presetsLoadError => 'प्लान लोड करने में त्रुटि';

  @override
  String presetsShowMore(int count) {
    return '$count और दिखाएँ';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return '$count और दिखाएँ ($remaining शेष)';
  }

  @override
  String planDefaultName(int number) {
    return 'योजना $number';
  }

  @override
  String get planArchive => 'संग्रहित करें';

  @override
  String get planActivate => 'सक्रिय करें';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonRename => 'नाम बदलें';

  @override
  String get planActivated => 'योजना सक्रिय हो गई।';

  @override
  String get planArchived => 'योजना संग्रहित हो गई।';

  @override
  String get planDeleteTitle => 'प्रीसेट हटाएँ';

  @override
  String get planDeleteConfirmation => 'क्या आप वाकई इस योजना को हटाना चाहते हैं?';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get planRenameTitle => 'योजना का नाम बदलें';

  @override
  String get planNameLabel => 'योजना नाम';

  @override
  String get optimizedTutorialBudgetTitle => 'सत्र बजट';

  @override
  String get optimizedTutorialBudgetBody => 'अनुकूलित वर्कआउट की अवधि और हर व्यायाम को मिलने वाले सेट की संख्या तय करें।';

  @override
  String get optimizedTutorialRepsTitle => 'रिप्स और वजन';

  @override
  String get optimizedTutorialRepsBody => 'ये विकल्प सेट पैटर्न, लक्षित रिप्स और जनरेट किए गए वजन की रूढ़िवादिता नियंत्रित करते हैं।';

  @override
  String get optimizedTutorialFocusTitle => 'शरीर-भाग फोकस';

  @override
  String get optimizedTutorialFocusBody => 'अपनी सहेजी रैंकिंग बदले बिना अगले अनुकूलित वर्कआउट के लिए शरीर भाग पसंद या टालें।';

  @override
  String get commonReset => 'रीसेट करें';

  @override
  String get optimizedTutorialResetBody => 'यदि वर्तमान सेटअप ठीक न लगे तो रीसेट इस पेज को Tonos डिफ़ॉल्ट पर वापस लाता है।';

  @override
  String get optimizedTutorialActionsTitle => 'सहेजें या शुरू करें';

  @override
  String get optimizedTutorialActionsBody => 'अभी शुरू करें वर्तमान स्क्रीन मानों को एक बार उपयोग करता है। सहेजें भविष्य के अनुकूलित वर्कआउट के लिए सेटिंग्स रखता है।';

  @override
  String optimizedValidationError(int maxSets) {
    return '1-$maxSets के बीच एक मान्य अवधि, रिप लक्ष्य और सेट रेंज दर्ज करें।';
  }

  @override
  String get optimizedBudgetDescription => 'हर सेट के लिए 3 मिनट और प्रत्येक व्यायाम शुरू करने के लिए 5 मिनट बजट में रखने हेतु उपयोग किया जाता है।';

  @override
  String get optimizedWorkoutDuration => 'वर्कआउट अवधि';

  @override
  String get unitMinutesShort => 'मि';

  @override
  String get optimizedMinimumSets => 'प्रति व्यायाम न्यूनतम सेट';

  @override
  String get optimizedMaximumSets => 'प्रति व्यायाम अधिकतम सेट';

  @override
  String get unitSets => 'सेट';

  @override
  String get optimizedRepsWeightsTitle => 'रिप्स और वजन';

  @override
  String get optimizedRepsWeightsDescription => 'उपलब्ध होने पर इतिहास-आधारित शक्ति अनुमान उपयोग करता है; आसान और मध्यम, कठिन की तुलना में अधिक पीछे हटते हैं। नए व्यायाम रूढ़िवादी शुरुआती अनुमान उपयोग करते हैं।';

  @override
  String get optimizedRepPattern => 'रिप पैटर्न';

  @override
  String get repModeMixed => 'मिश्रित';

  @override
  String get repModePyramid => 'पिरामिड';

  @override
  String get repModeConsistent => 'स्थिर';

  @override
  String get optimizedTargetReps => 'लक्षित रिप्स';

  @override
  String get unitReps => 'रिप्स';

  @override
  String get optimizedWeightIntensity => 'वजन तीव्रता';

  @override
  String get intensityEasy => 'आसान';

  @override
  String get intensityMedium => 'मध्यम';

  @override
  String get intensityHard => 'कठिन';

  @override
  String get optimizedBodypartFocusTitle => 'शरीर-भाग फोकस';

  @override
  String get optimizedBodypartFocusDescription => 'ये चयन केवल आपके शुरू किए जाने वाले अगले अनुकूलित वर्कआउट पर लागू होते हैं। पसंद के लिए एक बार, बचने के लिए दो बार और साफ़ करने के लिए फिर टैप करें।';

  @override
  String get optimizedBodypartsUnavailable => 'शरीर भाग लोड नहीं हो सके।';

  @override
  String get commonStartNow => 'अभी शुरू करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get generateTutorialIntroTitle => 'योजनाएँ बनाएँ';

  @override
  String get generateTutorialIntroBody => 'यह पेज आपकी जिम प्रोफ़ाइल और प्रशिक्षण प्राथमिकताओं से एक योजना या संतुलित साप्ताहिक बंडल बना सकता है।';

  @override
  String get generateWorkoutSetupTitle => 'वर्कआउट सेटअप';

  @override
  String get generateTutorialSetupBody => 'सत्र अवधि, बनाने वाली योजनाओं की संख्या और हर व्यायाम के लिए अधिकतम अनुमत सेट तय करें।';

  @override
  String get generateTrainingFocusTitle => 'प्रशिक्षण फोकस';

  @override
  String get generateTutorialFocusBody => 'यहाँ शरीर भाग पसंद या टालें। 7-दिन इतिहास टॉगल तभी निर्माण को प्रभावित करता है जब आप हाल के प्रशिक्षण पर विचार चाहते हैं।';

  @override
  String get generateRepsWeightsTitle => 'रिप्स और वजन';

  @override
  String get generateTutorialRepsBody => 'पिरामिड, मिश्रित या स्थिर सेट पैटर्न, लक्ष्य रिप्स और शुरुआती वजन तीव्रता चुनें।';

  @override
  String get generateSetAllocationTitle => 'सेट आवंटन';

  @override
  String get generateTutorialAllocationBody => 'चुनें कि सेट समान रूप से फैलें या आपकी शरीर-भाग/मांसपेशी रैंकिंग की ओर झुकें।';

  @override
  String get generateTutorialGenerateTitle => 'बनाएँ';

  @override
  String get generateTutorialGenerateBody => 'सब कुछ सही लगे तो योजना या योजना बंडल बनाएँ। नई योजनाओं की बाद में समीक्षा और संपादन किया जा सकता है।';

  @override
  String get generateValidationError => 'मान्य अवधि, योजना गिनती, सेट सीमा और रिप मान दर्ज करें।';

  @override
  String get generateNoViablePlans => 'वर्तमान सेटिंग्स के साथ कोई व्यवहार्य योजना नहीं बनाई जा सकी।';

  @override
  String generateFailed(String error) {
    return 'योजनाएँ बनाने में विफल: $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'जनरेट की गई योजनाएँ त्यागी नहीं जा सकीं: $error';
  }

  @override
  String get generateIntroTitle => 'अपना योजना सप्ताह बनाएँ';

  @override
  String get generateIntroBody => 'अपनी प्रोफ़ाइल, फोकस और सीमाओं के आधार पर एक योजना या संतुलित बंडल बनाएँ।';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ',
      one: '1 योजना',
    );
    return '$_temp0';
  }

  @override
  String generateDurationPill(String minutes) {
    return '$minutes मिनट';
  }

  @override
  String generateMaxSetsPill(String sets) {
    return 'अधिकतम $sets सेट';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans योजना(एँ), $minutes मिनट, अधिकतम $sets सेट';
  }

  @override
  String get generateSessionLength => 'सत्र अवधि';

  @override
  String get generateSessionLengthHelp => 'अनुमान: 3 मिनट/सेट + 5 मिनट/व्यायाम।';

  @override
  String get generatePlansToCreate => 'बनाने के लिए योजनाएँ';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'आमतौर पर प्रति सप्ताह प्रशिक्षण दिनों से मेल खाता है। अधिकतम $maxPlans।';
  }

  @override
  String get unitPlans => 'योजनाएँ';

  @override
  String get generateMaxSetsPerExercise => 'प्रति व्यायाम अधिकतम सेट';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return '$minSets-$maxSets सेट अनुमत हैं।';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred पसंदीदा, $avoided टाले गए, $history 7-दिन इतिहास';
  }

  @override
  String get generateHistoryUsing => 'उपयोग हो रहा है';

  @override
  String get generateHistoryNotUsing => 'उपयोग नहीं हो रहा';

  @override
  String get generateUseRecentTraining => 'हाल का प्रशिक्षण उपयोग करें';

  @override
  String get generateUseRecentTrainingBody => 'पिछले 7 दिनों में कम प्रशिक्षित क्षेत्रों की ओर झुकें।';

  @override
  String get generateBodypartFocusInstruction => 'पसंद के लिए एक बार, बचने के लिए दो बार और साफ़ करने के लिए तीसरी बार टैप करें।';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps रिप्स, $intensity तीव्रता';
  }

  @override
  String get generateMixedBody => '3+ सेट के लिए पिरामिड; कम काम के लिए स्थिर।';

  @override
  String get generatePyramidBody => 'पीक सेट जनरेट किया गया कार्य-वजन उपयोग करता है।';

  @override
  String get generateConsistentBody => 'हर सेट में समान रिप्स और सुझाया गया वजन।';

  @override
  String get generateTargetRepsHelp => 'पिरामिड के लिए पीक रिप्स; अन्यथा स्थिर रिप्स।';

  @override
  String get generateEasyBody => 'सबसे रूढ़िवादी इतिहास या शुरुआती सुझाव।';

  @override
  String get generateMediumBody => 'संतुलित कार्य-वजन सुझाव।';

  @override
  String get generateHardBody => 'सबसे भारी सुझाव, फिर भी राउंड किया गया और प्रयास के प्रति सजग।';

  @override
  String get generateRequirementBodyparts => 'शरीर-भाग रैंकिंग';

  @override
  String get generateRequirementMuscles => 'मांसपेशी रैंकिंग';

  @override
  String get generateRequirementEven => 'समान कवरेज';

  @override
  String get generateEvenCoverageTitle => 'समान शरीर-भाग कवरेज';

  @override
  String get generateEvenCoverageBody => 'उपलब्ध शरीर भागों में काम को व्यापक रूप से फैलाएँ।';

  @override
  String get generateBodypartRankingsTitle => 'शरीर-भाग रैंकिंग उपयोग करें';

  @override
  String get generateBodypartRankingsBody => 'उच्च रैंक वाले शरीर भागों को अधिक नियोजित काम दें।';

  @override
  String get generateRankBodyparts => 'शरीर भाग रैंक करें';

  @override
  String get generateMuscleRankingsTitle => 'मांसपेशी रैंकिंग उपयोग करें';

  @override
  String get generateMuscleRankingsBody => 'अपनी रैंक की गई मांसपेशी प्राथमिकताओं से काम आवंटित करें।';

  @override
  String get generateRankMuscles => 'मांसपेशियाँ रैंक करें';

  @override
  String get generateGenerating => 'बनाया जा रहा है...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ बनाएँ',
      one: 'योजना बनाएँ',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return '$requested में से $generated योजनाएँ बनाई गईं। आपकी वर्तमान सेटिंग्स ने बाकी को सीमित किया।';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count योजनाएँ बनाई गईं। तैयार होने पर देखें।',
      one: 'जनरेट की गई योजना जोड़ी गई। तैयार होने पर देखें।',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '$count और';
  }

  @override
  String get generateStarterEstimatedBody => 'नए व्यायामों के लिए शुरुआती वजन अनुमानित किए गए। अपने पहले सेट के बाद आवश्यकतानुसार समायोजित करें।';

  @override
  String get generateStarterUnavailableBody => 'कुछ व्यायामों को अभी भी मैन्युअल वजन चाहिए क्योंकि सुरक्षित शुरुआती अनुमान उपलब्ध नहीं है।';

  @override
  String get generateStarterDialogTitle => 'शुरुआती वजन जोड़े गए';

  @override
  String get generatePageTitle => 'योजनाएँ बनाएँ';

  @override
  String get generateDiscarding => 'त्यागा जा रहा है...';

  @override
  String get generateReviewPlans => 'योजनाएँ देखें';

  @override
  String get sessionTutorialCardsTitle => 'व्यायाम कार्ड';

  @override
  String get sessionTutorialCardsBody => 'हर कार्ड में एक व्यायाम होता है। वज़न और रेप संपादित करने के लिए इसे खोलें, फिर पूरे हुए सेट पर निशान लगाएँ।';

  @override
  String get sessionTutorialAddTitle => 'व्यायाम जोड़ें';

  @override
  String get sessionTutorialAddBody => 'वर्कआउट के दौरान कैटलॉग से कोई और व्यायाम जोड़ने के लिए इस बटन का उपयोग करें।';

  @override
  String get sessionTutorialFinishTitle => 'वर्कआउट पूरा करें';

  @override
  String get sessionTutorialFinishBody => 'जब आप पूरा कर लें, सेशन समाप्त करें ताकि Tonos वर्कआउट सहेज सके और आपका इतिहास, एनालिटिक्स और प्रगति विजेट अपडेट कर सके।';

  @override
  String get sessionTimerTitle => 'वर्कआउट टाइमर';

  @override
  String get sessionTitle => 'वर्कआउट सेशन';

  @override
  String get sessionNoExercises => 'कोई व्यायाम नहीं जोड़ा गया।';

  @override
  String get sessionNeedCompletedSet => 'वर्कआउट पूरा करने से पहले कम से कम एक सेट पूरा करें।';

  @override
  String sessionSaveFailed(String error) {
    return 'वर्कआउट सहेजा नहीं जा सका। आपका जारी वर्कआउट अभी भी उपलब्ध है। $error';
  }

  @override
  String get sessionFinishWorkout => 'वर्कआउट पूरा करें';

  @override
  String get sessionResume => 'जारी रखें';

  @override
  String get sessionExit => 'बाहर निकलें';

  @override
  String get sessionCompletedSaved => 'पूरा किया गया वर्कआउट लॉगबुक में सहेजा गया।';

  @override
  String get sessionCancelled => 'वर्कआउट रद्द किया गया।';

  @override
  String sessionEndFailed(String error) {
    return 'वर्कआउट समाप्त नहीं किया जा सका: $error';
  }

  @override
  String get sessionCancelQuestion => 'वर्कआउट रद्द करें?';

  @override
  String get sessionCancelBody => 'यह जारी वर्कआउट को आपके इतिहास में जोड़े बिना हटा देता है।';

  @override
  String get sessionKeepWorkout => 'वर्कआउट जारी रखें';

  @override
  String get sessionCancelWorkout => 'वर्कआउट रद्द करें';

  @override
  String get sessionEndQuestion => 'वर्कआउट समाप्त करें?';

  @override
  String get sessionCancelDelete => 'रद्द करें और हटाएँ';

  @override
  String get sessionEndSave => 'समाप्त करें और वर्कआउट सहेजें';

  @override
  String get sessionRememberChoice => 'चयन याद रखें';

  @override
  String get sessionRememberChoiceBody => 'इसे बाद में जिम और वर्कआउट सेटिंग्स में बदलें।';

  @override
  String get sessionCompleteLoadError => 'सेशन लोड करने में त्रुटि';

  @override
  String get sessionCompleteTitle => 'वर्कआउट पूरा हुआ';

  @override
  String get sessionMetricExercises => 'व्यायाम';

  @override
  String get sessionMetricSets => 'सेट';

  @override
  String get sessionMetricDuration => 'अवधि';

  @override
  String get sessionMetricVolume => 'वॉल्यूम';

  @override
  String get commonDone => 'पूर्ण';

  @override
  String get recordMonthly => 'मासिक';

  @override
  String get recordAllTime => 'अब तक';

  @override
  String get recordFirst => 'पहला रिकॉर्ड';

  @override
  String recordRepBest(int reps) {
    return '$reps रेप सर्वश्रेष्ठ';
  }

  @override
  String get recordVolumeBest => 'सर्वश्रेष्ठ वॉल्यूम';

  @override
  String sessionEstimatedMax(String weight) {
    return 'ERM=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutes मि';
  }

  @override
  String durationHoursCompact(int hours) {
    return '$hours घं';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '$hours घं $minutes मि';
  }

  @override
  String get planUnsavedChangesTitle => 'असहेजे बदलाव';

  @override
  String get planDiscardChangesQuestion => 'बदलाव त्यागें?';

  @override
  String get planDiscard => 'त्यागें';

  @override
  String get planTutorialEditTitle => 'योजना संपादित करें';

  @override
  String get planTutorialEditBody => 'इसका उपयोग योजना का नाम बदलने, व्यायाम पुनः क्रमित करने, व्यायाम जोड़ने, मूवमेंट बदलने और सेट बदलने के लिए करें।';

  @override
  String get planTutorialSummaryTitle => 'योजना सारांश';

  @override
  String get planTutorialSummaryBody => 'शुरू करने से पहले यह अनुमानित समय, वॉल्यूम और इस योजना के मुख्य लक्षित शरीर भाग दिखाता है।';

  @override
  String get planTutorialExerciseCardsTitle => 'व्यायाम कार्ड';

  @override
  String get planTutorialExerciseCardsBody => 'नियोजित सेट देखने के लिए व्यायाम कार्ड खोलें। संपादन मोड में, व्यायाम बदलने या हटाने के लिए मेनू उपयोग करें।';

  @override
  String get planTutorialStartOrSaveTitle => 'शुरू करें या सहेजें';

  @override
  String get planTutorialStartOrSaveBody => 'सत्र शुरू करें इस योजना को वर्कआउट के रूप में शुरू करता है। संपादन मोड में यह प्रीसेट सहेजें में बदलता है ताकि आपके बदलाव संग्रहीत हों।';

  @override
  String get planGuideNameTitle => 'अपनी योजना का नाम दें';

  @override
  String get planGuideNameBody => 'इस योजना को ऐसा नाम दें जिसे आप पहचानें, जैसे अपर बॉडी या दिन 1।';

  @override
  String get commonContinue => 'जारी रखें';

  @override
  String get planGuideBrowseTitle => 'व्यायाम ब्राउज़ करें';

  @override
  String get planGuideBrowseBody => 'इस योजना में पहला व्यायाम चुनने के लिए + बटन टैप करें।';

  @override
  String get planGuideWeightTitle => 'वजन चुनें';

  @override
  String get planGuideWeightBody => 'पहले सेट के लिए शुरुआती वजन दर्ज करें। बॉडीवेट व्यायाम के लिए 0 उपयोग करें।';

  @override
  String get planGuideWeightSet => 'वजन सेट किया गया';

  @override
  String get planGuideRepsTitle => 'अपनी रिप्स चुनें';

  @override
  String get planGuideRepsBody => 'इस सेट के लिए करने की योजना वाली रिप्स की संख्या दर्ज करें।';

  @override
  String get planGuideRepsSet => 'रिप्स सेट की गईं';

  @override
  String get planGuideAddSetTitle => 'और सेट जोड़ें';

  @override
  String get planGuideAddSetBody => 'जब आपको एक और सेट चाहिए तब सेट जोड़ें का उपयोग करें। नए सेट पिछले सेट के मानों से शुरू होते हैं।';

  @override
  String get planGuideSaveTitle => 'अपनी योजना सहेजें';

  @override
  String get planGuideSaveBody => 'इस योजना को रखने और ऑनबोर्डिंग अवलोकन पर लौटने के लिए प्रीसेट सहेजें टैप करें।';

  @override
  String planSaveFailed(String error) {
    return 'योजना सहेजी नहीं जा सकी। पिछला संस्करण अपरिवर्तित है। $error';
  }

  @override
  String get planOngoingWorkoutKept => 'आपका जारी वर्कआउट रखा गया है। इस योजना को शुरू करने से पहले उसे पूरा या रद्द करें।';

  @override
  String get planDeleteBody => 'क्या आप वाकई इस प्रीसेट को हटाना चाहते हैं?';

  @override
  String get planDeletePreset => 'प्रीसेट हटाएँ';

  @override
  String get planDisableAutomatic => 'स्वचालित बंद करें';

  @override
  String get planMakeAutomatic => 'स्वचालित बनाएँ';

  @override
  String get planAutomaticSettings => 'स्वचालित सेटिंग्स';

  @override
  String get planProgression => 'योजना प्रगति';

  @override
  String get planNoExercises => 'इस प्रीसेट में कोई व्यायाम नहीं है।';

  @override
  String get planSavePreset => 'प्रीसेट सहेजें';

  @override
  String get planStartSession => 'सत्र शुरू करें';

  @override
  String get commonName => 'नाम';

  @override
  String get commonBack => 'वापस';

  @override
  String get flowMethodWeight => 'वजन';

  @override
  String get flowMethodReps => 'रिप्स';

  @override
  String get flowMethodAddSet => 'सेट जोड़ें';

  @override
  String get flowMethodDeleteSet => 'सेट हटाएँ';

  @override
  String get flowAppDefaultTitle => 'ऐप डिफ़ॉल्ट प्रगति';

  @override
  String get flowProfileDefaultTitle => 'जिम डिफ़ॉल्ट प्रगति';

  @override
  String get flowPlanSubtitle => 'तय करें कि यह योजना हर वर्कआउट के बाद कैसे प्रगति करे।';

  @override
  String get flowAppDefaultSubtitle => 'नई जिम प्रोफ़ाइल के लिए शुरुआती प्रगति फ्लो सेट करें।';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return '$profileName में नई योजनाओं के लिए शुरुआती प्रगति फ्लो सेट करें।';
  }

  @override
  String get flowThisGymProfile => 'यह जिम प्रोफ़ाइल';

  @override
  String get flowManageMethods => 'क्रियाएँ प्रबंधित करें';

  @override
  String get flowAddNewMethod => 'नई क्रिया जोड़ें';

  @override
  String get flowNewMethod => 'नई क्रिया';

  @override
  String get flowFactor => 'गुणक';

  @override
  String get flowAmount => 'मात्रा';

  @override
  String get flowExplicit => 'स्पष्ट';

  @override
  String get flowCopyFromSet => 'सेट से कॉपी करें';

  @override
  String get flowWeight => 'वजन';

  @override
  String get flowReps => 'रिप्स';

  @override
  String get flowSetIndex => 'सेट इंडेक्स (-1 = अंतिम)';

  @override
  String get flowDeleteLastSetBody => 'यह क्रिया अंतिम सेट हटा देगी।';

  @override
  String get flowMethodNameRequired => 'क्रिया नाम खाली नहीं हो सकता';

  @override
  String get flowManageActionsTooltip => 'प्रगति क्रियाएँ प्रबंधित करें';

  @override
  String get flowAddBranchTitle => 'ब्रांच जोड़ें';

  @override
  String get flowAddBranchSubtitle => 'चुनें कि अगली सफलता या असफलता कहाँ ले जाए।';

  @override
  String get flowBranchFrom => 'इससे ब्रांच करें';

  @override
  String get flowSuccess => 'सफलता';

  @override
  String get flowMiss => 'चूक';

  @override
  String get flowAttachActionTitle => 'प्रगति क्रिया संलग्न करें';

  @override
  String get flowAttachActionSubtitle => 'फ्लो नोड पर प्रत्येक प्रकार का एक समायोजन लागू करें।';

  @override
  String get flowApplyActionTo => 'क्रिया लागू करें';

  @override
  String get flowProgressionAction => 'प्रगति क्रिया';

  @override
  String get flowAddAction => '+ क्रिया';

  @override
  String get flowRemoveAction => '- क्रिया';

  @override
  String get flowRemoveNode => '- नोड';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get rulesEditAppDefault => 'ऐप डिफ़ॉल्ट नियम संपादित करें';

  @override
  String get rulesEditProfileDefault => 'प्रोफ़ाइल डिफ़ॉल्ट नियम संपादित करें';

  @override
  String get rulesAddAppDefault => 'ऐप डिफ़ॉल्ट नियम जोड़ें';

  @override
  String get rulesAddProfileDefault => 'प्रोफ़ाइल डिफ़ॉल्ट नियम जोड़ें';

  @override
  String get rulesCopy => 'कॉपी करें';

  @override
  String get rulesCopyIndex => 'कॉपी इंडेक्स';

  @override
  String get rulesDeleteLastSetBody => 'यह अंतिम सेट हटा देगा।';

  @override
  String get rulesNameRequired => 'नियम नाम खाली नहीं हो सकता';

  @override
  String get rulesProfilesLowercase => 'प्रोफ़ाइल';

  @override
  String get rulesPlansLowercase => 'प्लान';

  @override
  String rulesAddToExistingTitle(String destination) {
    return 'मौजूदा $destination में जोड़ें?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return 'क्या \"$name\" को $count मौजूदा $destination में उपलब्ध करें? समान नाम के मौजूदा नियम और सभी सहेजे गए प्रगति फ्लो अपरिवर्तित रहेंगे।';
  }

  @override
  String get rulesNotNow => 'अभी नहीं';

  @override
  String rulesAddTo(String destination) {
    return '$destination में जोड़ें';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'किसी मौजूदा $destination को इस नियम की ज़रूरत नहीं है।';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return '\"$name\" को $count $destination में जोड़ा गया।';
  }

  @override
  String get rulesPropagationFailed => 'नियम को मौजूदा आइटम में जोड़ा नहीं जा सका।';

  @override
  String get rulesOptionsTooltip => 'नियम विकल्प';

  @override
  String get rulesPageTitle => 'वर्कआउट प्रगति नियम';

  @override
  String get rulesPageSubtitle => 'वर्कआउट प्रयासों के बाद वज़न, रेप और सेट कैसे बदलते हैं इसके लिए पुन: उपयोग योग्य नियम बनाएँ।';

  @override
  String get rulesHowDefaultsTitle => 'डिफ़ॉल्ट कैसे काम करते हैं';

  @override
  String get rulesHowDefaultsBody => 'ऐप डिफ़ॉल्ट नई जिम प्रोफ़ाइल में कॉपी होते हैं। प्रोफ़ाइल डिफ़ॉल्ट नए प्लान में कॉपी होते हैं, इसलिए बाद के बदलाव मौजूदा प्लान को अनपेक्षित रूप से नहीं बदलते।';

  @override
  String get rulesAppDefaultsTitle => 'ऐप-व्यापी डिफ़ॉल्ट';

  @override
  String get rulesAppDefaultsSubtitle => 'नई जिम प्रोफ़ाइल के शुरुआती नियम।';

  @override
  String get rulesNoAppDefaults => 'अभी कोई ऐप-व्यापी नियम नहीं बनाया गया है।';

  @override
  String get rulesAddApp => 'ऐप नियम जोड़ें';

  @override
  String get rulesGymProfilesTitle => 'जिम प्रोफ़ाइल';

  @override
  String get rulesGymProfilesSubtitle => 'हर प्रोफ़ाइल अपने डिफ़ॉल्ट और प्लान नियम एक साथ रखती है।';

  @override
  String get rulesNoProfiles => 'प्रोफ़ाइल और प्लान नियम जोड़ने के लिए जिम प्रोफ़ाइल बनाएँ।';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules प्रोफ़ाइल नियम • $planRules प्लान नियम';
  }

  @override
  String get rulesProfileDefaultsTitle => 'प्रोफ़ाइल डिफ़ॉल्ट';

  @override
  String get rulesProfileDefaultsSubtitle => 'इस प्रोफ़ाइल में नए प्लान के शुरुआती नियम।';

  @override
  String get rulesNoProfileDefaults => 'इस प्रोफ़ाइल में कोई डिफ़ॉल्ट नियम नहीं है।';

  @override
  String get rulesAddProfile => 'प्रोफ़ाइल नियम जोड़ें';

  @override
  String get rulesPlansTitle => 'प्लान';

  @override
  String get rulesNoPlans => 'इस जिम प्रोफ़ाइल से अभी कोई प्लान नहीं जुड़ा है।';

  @override
  String get rulesPlanOnlySubtitle => 'केवल इस प्लान में उपयोग किए जाने वाले नियम।';

  @override
  String get rulesNoPlanRules => 'इस प्लान में कोई विशिष्ट प्रगति नियम नहीं है।';

  @override
  String get rulesAddPlan => 'प्लान नियम जोड़ें';

  @override
  String get rulesAppDefaultsChip => 'ऐप डिफ़ॉल्ट';

  @override
  String get rulesProfilesChip => 'प्रोफ़ाइल';

  @override
  String get rulesPlansChip => 'प्लान';

  @override
  String get rulesEditPlan => 'नियम संपादित करें';

  @override
  String get rulesAddPlanTitle => 'नियम जोड़ें';

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get flowPageTitle => 'वर्कआउट प्रगति फ्लो';

  @override
  String get flowPageSubtitle => 'वे पथ सेट करें जो तय करते हैं कि वर्कआउट परिणाम के बाद प्रगति क्रियाएँ कैसे लागू हों।';

  @override
  String get flowHowCopiedTitle => 'फ्लो कैसे कॉपी होती हैं';

  @override
  String get flowHowCopiedBody => 'ऐप फ्लो नई जिम प्रोफ़ाइल के लिए शुरुआती बिंदु बनती हैं। जिम फ्लो नई योजनाओं के लिए शुरुआती बिंदु बनती हैं। बाद के बदलाव केवल उस फ्लो तक सीमित रहते हैं जिसे आप यहाँ खोलते हैं।';

  @override
  String get flowLoadError => 'वर्कआउट प्रगति फ्लो लोड नहीं हो सकीं।';

  @override
  String get flowAppDefaultsSubtitle => 'नई जिम प्रोफ़ाइल के लिए शुरुआती फ्लो।';

  @override
  String get flowAppDefaultEntry => 'ऐप डिफ़ॉल्ट फ्लो';

  @override
  String get flowGymProfilesSubtitle => 'हर प्रोफ़ाइल में डिफ़ॉल्ट और अपनी योजना फ्लो होती हैं।';

  @override
  String get flowNoProfiles => 'प्रोफ़ाइल और योजना फ्लो सेट करने के लिए जिम प्रोफ़ाइल बनाएँ।';

  @override
  String get flowNoSavedYet => 'अभी कोई सहेजा गया फ्लो नहीं';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes नोड | $branches ब्रांच | $actions क्रियाएँ';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$count योजना फ्लो उपलब्ध हैं';
  }

  @override
  String get flowGymDefaultEntry => 'जिम डिफ़ॉल्ट फ्लो';

  @override
  String get gymSettingsTitle => 'जिम और वर्कआउट सेटिंग्स';

  @override
  String get gymSettingsSubtitle => 'वर्कआउट निर्माण, विश्लेषण और वर्कआउट-फ्लो व्यवहार समायोजित करें।';

  @override
  String get gymSettingsLogicTitle => 'वर्कआउट लॉजिक';

  @override
  String get gymSettingsLogicSubtitle => 'योजना और जनरेट किए गए वर्कआउट को प्रभावित करने वाली सेटिंग्स।';

  @override
  String get gymSettingsWorkoutTitle => 'वर्कआउट सेटिंग्स';

  @override
  String get gymSettingsWorkoutSubtitle => 'वॉल्यूम सीमाएँ, विश्लेषण डिफ़ॉल्ट और प्रशिक्षण नियंत्रण।';

  @override
  String get gymSettingsExitTitle => 'जारी वर्कआउट से बाहर निकलना';

  @override
  String get gymSettingsFlowToolsTitle => 'फ्लो टूल्स';

  @override
  String get gymSettingsFlowToolsSubtitle => 'सहेजे गए प्रगति पथ और क्रियाएँ प्रबंधित करें।';

  @override
  String get gymSettingsFlowsSubtitle => 'ऐप डिफ़ॉल्ट, जिम और योजनाओं के लिए प्रगति फ्लो संपादित करें।';

  @override
  String get gymSettingsRulesSubtitle => 'वजन, रिप्स और सेट प्रगति नियम प्रबंधित करें।';

  @override
  String get gymExitAsk => 'हर बार पूछें';

  @override
  String get gymExitDiscard => 'वर्कआउट रद्द करें';

  @override
  String get gymExitSave => 'समाप्त करें और सहेजें';

  @override
  String get gymExitAskBody => 'पूरा हुआ काम समाप्त करने से पहले पूछें।';

  @override
  String get gymExitDiscardBody => 'पूरा हुआ काम सहेजे बिना रद्द करें।';

  @override
  String get gymExitSaveBody => 'पूरा हुआ काम लॉगबुक में सहेजें।';

  @override
  String get commonAll => 'सभी';

  @override
  String get catalogGuideChooseTitle => 'व्यायाम चुनें';

  @override
  String get catalogGuideChooseBody => 'चुनने के लिए किसी भी व्यायाम पंक्ति पर टैप करें। खोज या फ़िल्टर सही मूवमेंट ढूँढने में मदद कर सकते हैं।';

  @override
  String get catalogGuideAddTitle => 'इसे अपनी योजना में जोड़ें';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return '$exerciseName जोड़ने और अपनी योजना पर लौटने के लिए + टैप करें।';
  }

  @override
  String get catalogGuideSearchTitle => 'व्यायाम खोजें';

  @override
  String get catalogGuideSearchBody => 'जब आपको पहले से पता हो कि कौन सा मूवमेंट चाहिए तो व्यायाम नाम से खोजें।';

  @override
  String get catalogFilters => 'फ़िल्टर';

  @override
  String get catalogGuideFiltersBody => 'कैटलॉग को जल्दी सीमित करने के लिए जिम प्रोफ़ाइल, उपकरण, शरीर भाग या मांसपेशी से फ़िल्टर करें।';

  @override
  String get catalogGuideRowsTitle => 'व्यायाम पंक्तियाँ';

  @override
  String get catalogGuideRowsBody => 'हर पंक्ति उपकरण और हीटमैप दिखाती है। विवरण के लिए हीटमैप टैप करें या व्यायाम चुनने के लिए पंक्ति चुनें।';

  @override
  String get catalogSelectedFilters => 'चुने गए फ़िल्टर';

  @override
  String get catalogUseWorkspaceProfile => 'वर्कस्पेस प्रोफ़ाइल उपयोग करें';

  @override
  String get catalogWorkspaceProfile => 'वर्कस्पेस प्रोफ़ाइल';

  @override
  String get catalogEquipment => 'उपकरण';

  @override
  String get catalogFocusArea => 'फोकस क्षेत्र';

  @override
  String get catalogSpecificMuscle => 'विशिष्ट मांसपेशी';

  @override
  String get catalogPageTitle => 'व्यायाम कैटलॉग';

  @override
  String get catalogSearchExercises => 'व्यायाम खोजें';

  @override
  String get catalogNoMatches => 'कोई व्यायाम फ़िल्टर से मेल नहीं खाता।';

  @override
  String get catalogOpenExerciseInfo => 'व्यायाम जानकारी खोलें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get exerciseDetailOpenImage => 'व्यायाम छवि खोलें';

  @override
  String get exerciseDetailTutorialTitle => 'व्यायाम विवरण';

  @override
  String get exerciseDetailTutorialBody => 'शीट शीर्षक वही व्यायाम है जो आपने खोला। पूरा होने पर यहाँ से बंद करें।';

  @override
  String get exerciseDetailTabsTutorialTitle => 'विवरण, मेट्रिक्स, रिकॉर्ड';

  @override
  String get exerciseDetailTabsTutorialBody => 'निर्देश, सर्वश्रेष्ठ लिफ्ट और हाल के वर्कआउट रिकॉर्ड के बीच बदलने के लिए इन टैब का उपयोग करें।';

  @override
  String get exerciseDetailContextTutorialTitle => 'व्यायाम संदर्भ';

  @override
  String get exerciseDetailContextTutorialBody => 'विवरण टैब व्यायाम के लिए उपकरण, प्रशिक्षित शरीर के भाग, मांसपेशियाँ और फॉर्म नोट्स दिखाता है।';

  @override
  String get exerciseDetailSessionOpenFailed => 'वर्कआउट सत्र खोला नहीं जा सका।';

  @override
  String get exerciseDetailSessionNotFound => 'वर्कआउट सत्र नहीं मिला।';

  @override
  String get exerciseDetailNoEquipment => 'कोई उपकरण सूचीबद्ध नहीं है।';

  @override
  String get exerciseDetailTargetAnatomy => 'लक्षित शरीर रचना';

  @override
  String get exerciseDetailBodyParts => 'शरीर के भाग';

  @override
  String get exerciseDetailNoBodyParts => 'कोई शरीर भाग सूचीबद्ध नहीं है।';

  @override
  String get exerciseDetailMuscles => 'मांसपेशियाँ';

  @override
  String get exerciseDetailNoMuscles => 'कोई मांसपेशी सूचीबद्ध नहीं है।';

  @override
  String get exerciseDetailSetup => 'सेट-अप';

  @override
  String get exerciseDetailNoSetup => 'सेट-अप निर्देश उपलब्ध नहीं हैं।';

  @override
  String get exerciseDetailExecution => 'निष्पादन';

  @override
  String get exerciseDetailNoExecution => 'निष्पादन नोट्स उपलब्ध नहीं हैं।';

  @override
  String get exerciseDetailTips => 'सुझाव';

  @override
  String get exerciseDetailNoTips => 'कोई अतिरिक्त सुझाव नहीं।';

  @override
  String get exerciseDetailFormGuide => 'फॉर्म गाइड';

  @override
  String get exerciseDetailOpenHeatmap => 'लक्षित शरीर हीटमैप खोलें';

  @override
  String get exerciseDetailNoHeatmap => 'कोई लक्षित शरीर क्षेत्र उपलब्ध नहीं है';

  @override
  String get exerciseDetailZoomHint => 'ज़ूम करने के लिए पिंच या ड्रैग करें';

  @override
  String get exerciseDetailLoadingBestLifts => 'सर्वश्रेष्ठ लिफ्ट लोड की जा रही हैं';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'आपके पूरे किए गए सेट रिकॉर्ड की गणना की जा रही है।';

  @override
  String get exerciseDetailMetricsUnavailable => 'मेट्रिक्स उपलब्ध नहीं हैं';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'अपने पूरे किए गए सेट रिकॉर्ड लोड करने के लिए इस व्यायाम को फिर से खोलें।';

  @override
  String get exerciseDetailNoBestLifts => 'अभी कोई सर्वश्रेष्ठ लिफ्ट नहीं';

  @override
  String get exerciseDetailNoBestLiftsBody => 'प्रत्येक रिप गिनती के सर्वश्रेष्ठ वजन को ट्रैक करने के लिए इस व्यायाम का भार वाला सेट पूरा करें।';

  @override
  String get exerciseDetailWeek => 'सप्ताह';

  @override
  String get exerciseDetailMonth => 'माह';

  @override
  String get exerciseDetailAllTime => 'सभी समय';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return '$timeframe मेट्रिक्स';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'शीर्ष अनुमानित 1RM';

  @override
  String get exerciseDetailVolumeBest => 'सर्वश्रेष्ठ वॉल्यूम';

  @override
  String get exerciseDetailRepBests => 'रिप सर्वश्रेष्ठ';

  @override
  String get exerciseDetailRepBestsBody => 'प्रत्येक रिप गिनती के लिए सबसे अच्छा पूरा किया गया वजन';

  @override
  String exerciseDetailRanges(int count) {
    return '$count रेंज';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'व्यायाम इतिहास लोड नहीं हो सका।';

  @override
  String get exerciseDetailNoHistory => 'इस व्यायाम का कोई इतिहास नहीं है।';

  @override
  String get exerciseDetailPerformanceTrend => 'प्रदर्शन रुझान';

  @override
  String get exerciseDetailBestWeight => 'सर्वश्रेष्ठ वजन';

  @override
  String get exerciseDetailEstimatedOneRm => 'अनुमानित 1RM';

  @override
  String get exerciseDetailLoadingSessions => 'सत्र लोड किए जा रहे हैं';

  @override
  String get exerciseDetailLoadMoreSessions => '10 और सत्र लोड करें';

  @override
  String get exerciseDetailResizeLabel => 'व्यायाम विवरण का आकार बदलें';

  @override
  String get exerciseDetailResizeHint => 'शीट का आकार बदलने के लिए ऊपर या नीचे खींचें';

  @override
  String get exerciseDetailTabDetails => 'विवरण';

  @override
  String get exerciseDetailTabMetrics => 'मेट्रिक्स';

  @override
  String get exerciseDetailTabRecords => 'रिकॉर्ड';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return '$count पूरे किए गए सेट वाला वर्कआउट खोलें';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेट',
      one: '1 सेट',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return 'अनुमानित 1RM $weight';
  }

  @override
  String get exerciseDetailReps => 'रिप्स';

  @override
  String get exerciseDetailSetVolume => 'सेट वॉल्यूम';

  @override
  String get exerciseDetailNoChartData => 'चार्ट के लिए अभी कोई पूरे किए गए सेट रिकॉर्ड नहीं हैं।';

  @override
  String get exerciseDetailWeightAbbreviation => 'वजन';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'अनुमान';

  @override
  String get exerciseDetailTopAbbreviation => 'शीर्ष';

  @override
  String exerciseDetailSectionLabel(String title) {
    return '$title अनुभाग';
  }

  @override
  String get logbookTutorialCalendarTitle => 'लॉगबुक कैलेंडर';

  @override
  String get logbookTutorialCalendarBody => 'वर्कआउट इतिहास देखने के लिए M, 3M, Y और 4Y का उपयोग करें। उस सीमा के सेशन और सारांश आँकड़े देखने के लिए दिन, सप्ताह, महीना या वर्ष चुनें।';

  @override
  String get fullHistoryTitle => 'सभी सत्र';

  @override
  String get fullHistoryLoadError => 'सहेजे गए सत्र लोड नहीं हो सके।';

  @override
  String get fullHistoryEmpty => 'कोई सत्र सहेजा नहीं गया।';

  @override
  String fullHistorySessionSummary(String date, int minutes) {
    return '$date - $minutes मिनट';
  }

  @override
  String get weeklySetsTitle => 'साप्ताहिक सेट अवलोकन';

  @override
  String get weeklySetsLoadError => 'आपका साप्ताहिक प्रशिक्षण अवलोकन लोड नहीं हो सका।';

  @override
  String get weeklySetsBodyParts => 'शरीर भाग';

  @override
  String get weeklySetsMuscles => 'मांसपेशियाँ';

  @override
  String get weeklySetsTotal => 'कुल सेट';

  @override
  String get weeklySetsTime => 'समय';

  @override
  String get weeklySetsVolume => 'वॉल्यूम';

  @override
  String get weeklySetsNoBodyParts => 'अभी कोई शरीर-भाग सेट नहीं।';

  @override
  String get weeklySetsNoMuscles => 'अभी कोई मांसपेशी सेट नहीं।';

  @override
  String weeklySetsCount(String count) {
    return '$count सेट';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'साप्ताहिक अवलोकन';

  @override
  String get weeklySetsTutorialOverviewBody => 'यह हीटमैप के साथ पिछले सात दिनों का कुल सेट, समय और वॉल्यूम सारांशित करता है।';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'शरीर भाग या मांसपेशियाँ';

  @override
  String get weeklySetsTutorialAnatomyBody => 'शरीर-भाग सेट यूनिट और अलग-अलग मांसपेशी सेट यूनिट के बीच बदलें।';

  @override
  String get weeklySetsTutorialStatusTitle => 'सेट स्थिति';

  @override
  String get weeklySetsTutorialStatusBody => 'हर पंक्ति का रंग इस आधार पर होता है कि आपका हाल का काम सुझाई गई रेंज से कम, भीतर या ऊपर है। लिंक किए व्यायामों के लिए पंक्ति टैप करें।';

  @override
  String get workoutDetailTutorialSummaryTitle => 'वर्कआउट सारांश';

  @override
  String get workoutDetailTutorialSummaryBody => 'कुल सेट, वॉल्यूम, अवधि, व्यायाम गिनती और इस वर्कआउट में प्रशिक्षित शरीर भागों की समीक्षा करें।';

  @override
  String get workoutDetailTutorialExercisesTitle => 'व्यायाम रिकॉर्ड';

  @override
  String get workoutDetailTutorialExercisesBody => 'हर व्यायाम उस सत्र के पूरे किए गए सेट दिखाता है। व्यायाम देखने के लिए विवरण टैप करें।';

  @override
  String get workoutDetailTutorialEditTitle => 'सत्र संपादित करें';

  @override
  String get workoutDetailTutorialEditBody => 'वर्कआउट के बाद सेट, रिप्स या व्यायाम सुधारने हों तो संपादन मोड उपयोग करें।';

  @override
  String get workoutDetailTutorialReuseTitle => 'इस वर्कआउट का पुनः उपयोग करें';

  @override
  String get workoutDetailTutorialReuseBody => 'वर्कआउट फिर करें या पूरे सत्र को फिर से उपयोग की जा सकने वाली योजना के रूप में सहेजें।';

  @override
  String get workoutDetailDeleteTitle => 'सत्र हटाएँ';

  @override
  String get workoutDetailDeleteBody => 'क्या आप वाकई इस सत्र को हटाना चाहते हैं?';

  @override
  String get workoutDetailDeleteFailed => 'यह सत्र हटाया नहीं जा सका।';

  @override
  String get workoutDetailChangesSaved => 'बदलाव सहेज लिए गए।';

  @override
  String get workoutDetailSaveFailed => 'बदलाव सहेजे नहीं जा सके। पिछला सत्र अपरिवर्तित है।';

  @override
  String get workoutDetailFinishCurrentFirst => 'इसे दोहराने से पहले अपना वर्तमान वर्कआउट पूरा करें।';

  @override
  String get workoutDetailOngoingWorkoutKept => 'आपका जारी वर्कआउट रखा गया है। इस वर्कआउट को दोहराने से पहले उसे पूरा या रद्द करें।';

  @override
  String get workoutDetailRepeatFailed => 'यह वर्कआउट दोहराया नहीं जा सका।';

  @override
  String get workoutDetailSaveAsPlan => 'योजना के रूप में सहेजें';

  @override
  String get workoutDetailPlanName => 'योजना नाम';

  @override
  String workoutDetailPlanSaved(String name) {
    return '“$name” को योजना के रूप में सहेजा गया।';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'योजना सहेजने में विफल।';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'वर्कआउट $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'असहेजे बदलाव';

  @override
  String get workoutDetailUnsavedBody => 'आपके पास असहेजे बदलाव हैं। क्या आप उन्हें त्यागकर बाहर जाना चाहते हैं?';

  @override
  String get workoutDetailDiscard => 'त्यागें';

  @override
  String get workoutDetailTitle => 'वर्कआउट विवरण';

  @override
  String get workoutDetailStopEditing => 'संपादन बंद करें';

  @override
  String get workoutDetailEditSession => 'सत्र संपादित करें';

  @override
  String get workoutDetailDeleteSession => 'सत्र हटाएँ';

  @override
  String get workoutDetailLoadFailed => 'यह सत्र लोड नहीं हो सका।';

  @override
  String get workoutDetailEmpty => 'इस सत्र में कोई व्यायाम नहीं है।';

  @override
  String get workoutDetailSaveChanges => 'बदलाव सहेजें';

  @override
  String get workoutDetailRepeat => 'वर्कआउट फिर से करें';

  @override
  String get workoutDetailPastWorkout => 'पिछला वर्कआउट';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$count पूरे किए गए सेट';
  }

  @override
  String get workoutDetailVolume => 'वॉल्यूम';

  @override
  String get workoutDetailDuration => 'अवधि';

  @override
  String get workoutDetailExercises => 'व्यायाम';

  @override
  String get workoutDetailExerciseInfo => 'व्यायाम जानकारी';

  @override
  String get workoutDetailBest => 'सर्वश्रेष्ठ';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'वर्कआउट कैलेंडर लोड नहीं हो सका।';

  @override
  String get logbookNoWorkouts => 'कोई वर्कआउट लॉग नहीं है';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वर्कआउट',
      one: '1 वर्कआउट',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => 'पिछला महीना';

  @override
  String get logbookNextMonth => 'अगला महीना';

  @override
  String get logbookPreviousThreeMonths => 'पिछले 3 महीने';

  @override
  String get logbookNextThreeMonths => 'अगले 3 महीने';

  @override
  String get logbookPreviousYear => 'पिछला वर्ष';

  @override
  String get logbookNextYear => 'अगला वर्ष';

  @override
  String logbookWeekShort(int week) {
    return 'स$week';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month सप्ताह $week';
  }

  @override
  String get logbookWorkouts => 'वर्कआउट';

  @override
  String get logbookTotalTime => 'कुल समय';

  @override
  String get logbookTotalVolume => 'कुल वॉल्यूम';

  @override
  String get logbookViewAllSessions => 'सभी सेशन देखें';

  @override
  String logbookSessionSummary(int minutes, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises व्यायाम',
      one: '1 व्यायाम',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets सेट',
      one: '1 सेट',
    );
    return '$minutes मि - $_temp0 - $_temp1 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '$hours घं';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes मि';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds से';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours घं $minutes मि';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes मि $seconds से';
  }

  @override
  String get dashboardHideSection => 'अनुभाग छिपाएँ';

  @override
  String get dashboardAllSectionsShown => 'सभी अनुभाग दिखाए जा रहे हैं';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$count अनुभाग छिपे हैं';
  }

  @override
  String get dashboardShowHiddenSections => 'छिपे हुए अनुभाग दिखाएँ';

  @override
  String get dashboardReset => 'डैशबोर्ड रीसेट करें';

  @override
  String get dashboardEmptyTitle => 'आपका डैशबोर्ड खाली है';

  @override
  String get dashboardEmptyBody => 'जब तैयार हों, कोई भी अनुभाग फिर से जोड़ें।';

  @override
  String get dashboardCustomize => 'डैशबोर्ड अनुकूलित करें';

  @override
  String get dashboardSectionQuickActionsTitle => 'त्वरित क्रियाएँ';

  @override
  String get dashboardSectionQuickActionsBody => 'कोई माप लॉग करें या वर्कआउट शुरू करें।';

  @override
  String get dashboardSectionTrainingTitle => 'प्रशिक्षण के लिए तैयार';

  @override
  String get dashboardSectionTrainingBody => 'अपनी जिम प्रोफ़ाइल और प्लान चुनें, फिर सेशन शुरू करें।';

  @override
  String get dashboardSectionNutritionTitle => 'पोषण डैशबोर्ड';

  @override
  String get dashboardSectionNutritionBody => 'वर्तमान कैलोरी और मैक्रो लक्ष्य देखें।';

  @override
  String get dashboardSectionDataRecordsTitle => 'डेटा और रिकॉर्ड';

  @override
  String get dashboardSectionDataRecordsBody => 'रोज़ाना पोषण प्रविष्टियों की समीक्षा करें और जोड़ें।';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'साप्ताहिक फ़ोकस';

  @override
  String get dashboardSectionWeeklyFocusBody => 'पिछले 7 दिनों के शरीर-भाग और मांसपेशी कार्य की समीक्षा करें।';

  @override
  String get dashboardSectionWorkoutReportTitle => 'वर्कआउट रिपोर्ट';

  @override
  String get dashboardSectionWorkoutReportBody => 'समय के साथ वर्कआउट गिनती, समय और वॉल्यूम की तुलना करें।';

  @override
  String get dashboardSectionExerciseProgressTitle => 'व्यायाम प्रगति';

  @override
  String get dashboardSectionExerciseProgressBody => 'अपने चुने हुए व्यायामों के शक्ति रुझान देखें।';

  @override
  String get dashboardSectionHistoryTitle => 'प्रशिक्षण इतिहास';

  @override
  String get dashboardSectionHistoryBody => 'समय सीमाओं में वर्कआउट कुल और फ़ोकस की तुलना करें।';

  @override
  String get dashboardSectionHealthTrendsTitle => 'स्वास्थ्य रुझान';

  @override
  String get dashboardSectionHealthTrendsBody => 'शरीर वज़न और आकार जैसे माप ट्रैक करें।';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'हाल के वर्कआउट';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'अपने नवीनतम पूर्ण वर्कआउट सेशन खोलें।';

  @override
  String get dashboardSectionActivePlansTitle => 'सक्रिय प्लान';

  @override
  String get dashboardSectionActivePlansBody => 'जिन प्लान का आप सबसे अधिक उपयोग करते हैं उन्हें पास रखें।';

  @override
  String get dashboardSectionArchivedPlansTitle => 'संग्रहीत प्लान';

  @override
  String get dashboardSectionArchivedPlansBody => 'उन प्लान को देखें जो अभी सक्रिय नहीं हैं।';

  @override
  String get dashboardSectionPremadePlansTitle => 'तैयार प्लान';

  @override
  String get dashboardSectionPremadePlansBody => 'इस प्रोफ़ाइल में जोड़ी जा सकने वाली रूटीन देखें।';

  @override
  String get dashboardSectionPlanToolsTitle => 'प्लान उपकरण';

  @override
  String get dashboardSectionPlanToolsBody => 'संतुलित प्लान बनाएँ या मैन्युअली एक बनाएँ।';

  @override
  String get dashboardSectionCatalogTitle => 'व्यायाम कैटलॉग';

  @override
  String get dashboardSectionCatalogBody => 'अपने सबसे अधिक किए गए व्यायाम और पूरा कैटलॉग खोलें।';

  @override
  String get dashboardSectionAnatomyTitle => 'लक्षित शरीररचना';

  @override
  String get dashboardSectionAnatomyBody => 'उन शरीर-भागों और मांसपेशियों की समीक्षा करें जिन्हें आप सबसे अधिक प्रशिक्षित करते हैं।';

  @override
  String get dashboardSectionFallbackTitle => 'डैशबोर्ड अनुभाग';

  @override
  String get dashboardSectionFallbackBody => 'एक डैशबोर्ड अनुभाग।';

  @override
  String get dashboardTitle => 'डैशबोर्ड';

  @override
  String get dashboardDoneCustomizing => 'अनुकूलन पूरा हुआ';

  @override
  String get dashboardQuickActions => 'त्वरित क्रियाएँ';

  @override
  String get dashboardMeasurement => 'माप';

  @override
  String get dashboardResumeWorkout => 'वर्कआउट जारी रखें';

  @override
  String get dashboardStartWorkout => 'वर्कआउट शुरू करें';

  @override
  String dashboardTodayAt(String time) {
    return 'आज, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'हाल के वर्कआउट';

  @override
  String get dashboardViewAll => 'सभी देखें';

  @override
  String get dashboardRecentWorkoutsFailed => 'हाल के वर्कआउट लोड नहीं किए जा सके।';

  @override
  String get dashboardRecentWorkoutsEmpty => 'वर्कआउट पूरा करें और वह यहाँ दिखाई देगा।';

  @override
  String get userInfoProfileUpdateNote => 'प्रोफ़ाइल अपडेट';

  @override
  String get userInfoChangesSaved => 'बदलाव सहेजे गए';

  @override
  String get userInfoSaveFailed => 'आपके बदलाव सहेजे नहीं जा सके।';

  @override
  String get userInfoTitle => 'उपयोगकर्ता जानकारी';

  @override
  String get userInfoSubtitle => 'ऐप गणनाओं के लिए बुनियादी प्रोफ़ाइल विवरण उपलब्ध रखें।';

  @override
  String get userInfoIdentityTitle => 'पहचान';

  @override
  String get userInfoIdentitySubtitle => 'बुनियादी व्यक्तिगत विवरण।';

  @override
  String get userInfoName => 'नाम';

  @override
  String get userInfoNameHint => 'अपना नाम दर्ज करें';

  @override
  String get userInfoGender => 'लिंग';

  @override
  String get userInfoDateOfBirth => 'जन्म तिथि';

  @override
  String get userInfoDateHint => 'YYYY-MM-DD';

  @override
  String get userInfoBodyMetricsTitle => 'शरीर मेट्रिक्स';

  @override
  String get userInfoBodyMetricsSubtitle => 'प्रगति और पोषण अनुमानों के लिए वैकल्पिक विवरण।';

  @override
  String get userInfoHeight => 'कद';

  @override
  String get userInfoHeightHint => 'जैसे 5 फीट 10 इंच या 178 सेमी';

  @override
  String get userInfoCurrentWeight => 'वर्तमान वजन';

  @override
  String get userInfoWeightPoundsHint => 'जैसे 160';

  @override
  String get userInfoWeightKilogramsHint => 'जैसे 72';

  @override
  String get userInfoBodyFat => 'शरीर वसा % अनुमान';

  @override
  String get userInfoActivityTitle => 'गतिविधि संदर्भ';

  @override
  String get userInfoActivitySubtitle => 'बाद में सुझावों और स्वास्थ्य अनुमानों के लिए उपयोग किया जाता है।';

  @override
  String get userInfoWeightTrend => 'वजन रुझान';

  @override
  String get userInfoAverageSteps => 'अनुमानित औसत कदम';

  @override
  String get userInfoGenderMale => 'पुरुष';

  @override
  String get userInfoGenderFemale => 'महिला';

  @override
  String get userInfoGenderOther => 'अन्य';

  @override
  String get userInfoGenderPreferNotToSay => 'न बताना पसंद करें';

  @override
  String get userInfoTrendGaining => 'वजन बढ़ रहा है';

  @override
  String get userInfoTrendLosing => 'वजन घट रहा है';

  @override
  String get userInfoTrendMaintaining => 'वजन बनाए रखना';

  @override
  String get userInfoTrendNotSure => 'पता नहीं';

  @override
  String get userInfoActivityLow => 'कम (0-5k)';

  @override
  String get userInfoActivityModerate => 'मध्यम (5-15k)';

  @override
  String get userInfoActivityHigh => 'उच्च (15k+)';

  @override
  String get userInfoSaveChanges => 'बदलाव सहेजें';

  @override
  String get tutorialsSettingsTitle => 'निर्देशित ट्यूटोरियल';

  @override
  String get tutorialsSettingsSubtitle => 'जब त्वरित पुनरावलोकन चाहिए तब वॉकथ्रू फिर से चलाएँ।';

  @override
  String get tutorialsControlsTitle => 'ट्यूटोरियल नियंत्रण';

  @override
  String get tutorialsControlsSubtitle => 'परीक्षण कर रहे हैं या नई शुरुआत चाहते हैं?';

  @override
  String get tutorialsResetAllTitle => 'सभी ट्यूटोरियल रीसेट करें';

  @override
  String get tutorialsResetAllSubtitle => 'हर निर्देशित ट्यूटोरियल को फिर से उपलब्ध बनाता है।';

  @override
  String get tutorialsResetAll => 'सभी रीसेट करें';

  @override
  String get tutorialsResetAllMessage => 'सभी ट्यूटोरियल रीसेट हो गए हैं।';

  @override
  String get tutorialsHowItWorksTitle => 'ट्यूटोरियल कैसे काम करते हैं';

  @override
  String get tutorialsHowItWorksBody => 'ट्यूटोरियल एक बार दिखाई देते हैं, फिर रास्ते से हट जाते हैं। किसी खास वॉकथ्रू को रीसेट करने के लिए समूह फैलाएँ।';

  @override
  String get tutorialsMainTabsTitle => 'मुख्य टैब';

  @override
  String get tutorialsMainTabsSubtitle => 'हर मुख्य क्षेत्र के वॉकथ्रू फिर से देखें।';

  @override
  String get tutorialsWorkoutTitle => 'वर्कआउट';

  @override
  String get tutorialsWorkoutSubtitle => 'अपने पहले सत्र को लॉग करने में सहायता।';

  @override
  String get tutorialsPlansTitle => 'योजनाएँ और वर्कआउट';

  @override
  String get tutorialsPlansSubtitle => 'योजना बनाने, संपादन और वर्कआउट विवरण सहायता फिर से देखें।';

  @override
  String get tutorialsCatalogTitle => 'कैटलॉग और शरीर रचना';

  @override
  String get tutorialsCatalogSubtitle => 'व्यायाम और लक्षित शरीर रचना सहायता फिर से देखें।';

  @override
  String get tutorialsProgressTitle => 'प्रगति और सेटिंग्स';

  @override
  String get tutorialsProgressSubtitle => 'प्रगति विवरण और सेटिंग्स पेज सहायता फिर से देखें।';

  @override
  String tutorialsReplayTitle(String topic) {
    return '$topic ट्यूटोरियल फिर से चलाएँ';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'अगली बार $topic खोलने पर दिखेगा।';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return '$topic ट्यूटोरियल अगली बार फिर चलेगा।';
  }

  @override
  String get tutorialsReset => 'रीसेट करें';

  @override
  String get tutorialsTopicTrain => 'ट्रेन';

  @override
  String get tutorialsTopicCatalog => 'कैटलॉग';

  @override
  String get tutorialsTopicLogbook => 'लॉगबुक';

  @override
  String get tutorialsTopicProgress => 'प्रगति';

  @override
  String get tutorialsTopicProfile => 'प्रोफ़ाइल';

  @override
  String get tutorialsTopicFirstWorkout => 'पहला वर्कआउट';

  @override
  String get tutorialsTopicGeneratePlans => 'योजनाएँ बनाएँ';

  @override
  String get tutorialsTopicOptimizedSettings => 'अनुकूलित वर्कआउट सेटिंग्स';

  @override
  String get tutorialsTopicPremadePlans => 'तैयार योजनाएँ';

  @override
  String get tutorialsTopicPlanManagement => 'योजना प्रबंधन';

  @override
  String get tutorialsTopicPlanDetail => 'योजना विवरण';

  @override
  String get tutorialsTopicPlanBuilder => 'योजना बिल्डर';

  @override
  String get tutorialsTopicWorkoutDetail => 'वर्कआउट विवरण';

  @override
  String get tutorialsTopicExerciseCatalog => 'व्यायाम कैटलॉग';

  @override
  String get tutorialsTopicExerciseDetail => 'व्यायाम विवरण';

  @override
  String get tutorialsTopicTargetAnatomy => 'लक्षित शरीर रचना';

  @override
  String get tutorialsTopicBodypartDetail => 'शरीर-भाग विवरण';

  @override
  String get tutorialsTopicMuscleDetail => 'मांसपेशी विवरण';

  @override
  String get tutorialsTopicWeeklySets => 'साप्ताहिक सेट अवलोकन';

  @override
  String get tutorialsTopicExerciseProgress => 'व्यायाम प्रगति';

  @override
  String get tutorialsTopicMeasurementTrend => 'माप रुझान';

  @override
  String get tutorialsTopicGymProfile => 'जिम प्रोफ़ाइल संपादक';

  @override
  String get tutorialsTopicUiAppearance => 'UI और रूप-रंग';

  @override
  String get tutorialsTopicDatabaseSettings => 'डेटाबेस सेटिंग्स';

  @override
  String get tutorialsTopicGuide => 'निर्देशित सहायता';

  @override
  String get anatomyLibraryTitle => 'व्यायाम फोकस लाइब्रेरी';

  @override
  String get anatomyBodyParts => 'शरीर भाग';

  @override
  String get anatomyMuscles => 'मांसपेशियाँ';

  @override
  String get anatomyLoadFailed => 'शरीर रचना फ़िल्टर लोड नहीं हो सके।';

  @override
  String get anatomySearchLabel => 'शरीर भाग या मांसपेशी खोजें';

  @override
  String get anatomyNoBodyParts => 'कोई शरीर भाग आपकी खोज से मेल नहीं खाता।';

  @override
  String get anatomyNoMuscles => 'कोई मांसपेशी आपकी खोज से मेल नहीं खाती।';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count व्यायाम',
      one: '1 व्यायाम',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => 'शरीर रचना खोजें';

  @override
  String get anatomyTutorialSearchBody => 'लक्षित व्यायाम विकल्प चाहिए हों तो किसी शरीर भाग या विशिष्ट मांसपेशी की खोज करें।';

  @override
  String get anatomyTutorialListsTitle => 'शरीर भाग और मांसपेशियाँ';

  @override
  String get anatomyTutorialListsBody => 'टैब बदलें, फिर लिंक किए गए व्यायाम, हाल के सेट कुल और सुझाई गई सेट सीमाएँ देखने के लिए किसी पंक्ति पर टैप करें।';

  @override
  String anatomyTargetExercises(String name) {
    return '$name व्यायाम';
  }

  @override
  String get anatomyBodypartLoadFailed => 'यह शरीर भाग लोड नहीं हो सका।';

  @override
  String get anatomyMuscleLoadFailed => 'यह मांसपेशी लोड नहीं हो सकी।';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return '$name के सुझाए गए सेट अपडेट किए गए।';
  }

  @override
  String get anatomySaveFailed => 'बदलाव सहेजे नहीं जा सके।';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लिंक किए गए व्यायाम',
      one: '1 लिंक किया गया व्यायाम',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => 'पूर्ण (7 दिन)';

  @override
  String get anatomySetsLastSevenDays => 'पिछले 7 दिन के सेट';

  @override
  String anatomySetUnits(String count) {
    return '$count सेट';
  }

  @override
  String get anatomyRecommended => 'सुझाया गया';

  @override
  String get anatomyNotSet => 'सेट नहीं';

  @override
  String anatomySetRange(String min, String max) {
    return '$min-$max सेट';
  }

  @override
  String get anatomyAssociatedMuscles => 'संबंधित मांसपेशियाँ';

  @override
  String get anatomyRelatedBodyParts => 'संबंधित शरीर भाग';

  @override
  String get anatomyNoMuscleLinks => 'इस शरीर भाग के लिए अभी कोई मांसपेशी लिंक नहीं जोड़ा गया है।';

  @override
  String get anatomyNoBodyPartLinks => 'इस मांसपेशी के लिए अभी कोई शरीर-भाग लिंक नहीं जोड़ा गया है।';

  @override
  String get anatomyExercises => 'व्यायाम';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'अभी $name से कोई व्यायाम लिंक नहीं है।';
  }

  @override
  String get anatomyNoEquipment => 'कोई उपकरण सूचीबद्ध नहीं';

  @override
  String get anatomyNoMusclesListed => 'कोई मांसपेशी सूचीबद्ध नहीं';

  @override
  String get anatomyNoBodyPartsListed => 'कोई शरीर भाग सूचीबद्ध नहीं';

  @override
  String anatomyOpenedFrom(String name) {
    return '$name से खोला गया';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'इस मांसपेशी के लिए रैंक $rank - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'शरीर रचना विवरण';

  @override
  String get anatomyTutorialBodypartDetailBody => 'हेडर हाल के सेट, सुझाई गई सेट सीमाएँ और संबंधित शरीर रचना लिंक दिखाता है।';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'मांसपेशी विवरण';

  @override
  String get anatomyTutorialMuscleDetailBody => 'हेडर हाल के सेट, सुझाई गई सेट सीमाएँ और संबंधित शरीर भाग दिखाता है।';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'लिंक किए गए व्यायाम';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'ये इस लक्ष्य से जुड़े व्यायाम हैं। पूरा व्यायाम विवरण खोलने के लिए किसी पर टैप करें।';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'व्यायाम इस आधार पर रैंक किए जाते हैं कि वे इस मांसपेशी को कितनी सीधे प्रशिक्षित करते हैं। पूरे विवरण के लिए किसी पर टैप करें।';

  @override
  String get settingsWorkoutTitle => 'वर्कआउट सेटिंग्स';

  @override
  String get settingsWorkoutSubtitle => 'समायोजित करें कि ऐप शरीर रचना, प्रशिक्षण झुकाव और वॉल्यूम लक्ष्यों को कैसे समझता है।';

  @override
  String get settingsTrainingBiasTitle => 'प्रशिक्षण झुकाव';

  @override
  String get settingsTrainingBiasSubtitle => 'बनाई गई योजनाओं और अनुकूलित वर्कआउट द्वारा उपयोग किए जाने वाले नियंत्रण।';

  @override
  String get settingsBodyPartRankings => 'शरीर भाग रैंकिंग';

  @override
  String get settingsBodyPartRankingsSubtitle => 'प्राथमिकता दें कि किन शरीर भागों को अधिक काम मिलना चाहिए।';

  @override
  String get settingsMuscleRankings => 'मांसपेशी रैंकिंग';

  @override
  String get settingsMuscleRankingsSubtitle => 'शरीर रचना मॉडल में विशेष मांसपेशियों को प्राथमिकता दें।';

  @override
  String get settingsVolumeBoundaries => 'वॉल्यूम सीमाएँ';

  @override
  String get settingsVolumeBoundariesSubtitle => 'शरीर भागों और मांसपेशियों के लिए सुझाई गई साप्ताहिक रेंज तय करें।';

  @override
  String get settingsExerciseDefinitionsTitle => 'व्यायाम परिभाषाएँ';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'ऐप द्वारा उपयोग किए गए शरीर रचना और व्यायाम डेटा को बनाए रखें।';

  @override
  String get settingsAnatomyMapping => 'शरीर भाग / मांसपेशी मैपिंग';

  @override
  String get settingsAnatomyMappingSubtitle => 'चुनें कि प्रत्येक शरीर भाग में कौन सी मांसपेशियाँ आती हैं।';

  @override
  String get settingsExerciseSetAllocation => 'व्यायाम सेट आवंटन';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'समीक्षा करें कि प्रत्येक व्यायाम मांसपेशियों और शरीर भागों में कैसे योगदान देता है।';

  @override
  String get settingsExerciseEditor => 'व्यायाम संपादक';

  @override
  String get settingsExerciseEditorSubtitle => 'व्यायाम नाम, विवरण, उपकरण और मैपिंग अपडेट करें।';

  @override
  String get commonCopy => 'कॉपी करें';

  @override
  String get commonImport => 'आयात करें';

  @override
  String get commonExport => 'निर्यात करें';

  @override
  String get databaseExportTitle => 'डेटाबेस एक्सपोर्ट करें';

  @override
  String get databaseImportTitle => 'डेटाबेस इम्पोर्ट करें';

  @override
  String get databasePasteJson => 'JSON यहाँ पेस्ट करें';

  @override
  String get databaseCopied => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String databaseExportFailed(String error) {
    return 'एक्सपोर्ट नहीं हुआ: $error';
  }

  @override
  String get databaseImportSucceeded => 'इम्पोर्ट सफल हुआ';

  @override
  String databaseImportFailed(String error) {
    return 'इम्पोर्ट नहीं हुआ: $error';
  }

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get nutritionSettingsTitle => 'आहार और पोषण सेटिंग्स';

  @override
  String get nutritionSettingsSubtitle => 'पोषण लक्ष्य और खाद्य-संबंधी प्राथमिकताएँ कॉन्फ़िगर करें।';

  @override
  String get nutritionCurrentGoals => 'वर्तमान लक्ष्य';

  @override
  String get nutritionGoals => 'लक्ष्य';

  @override
  String get nutritionGoalsSubtitle => 'पोषण ट्रैकिंग द्वारा उपयोग किए जाने वाले लक्ष्य तय करें।';

  @override
  String get nutritionManualGoals => 'पोषण लक्ष्य मैन्युअल रूप से तय करें';

  @override
  String get nutritionManualGoalsSubtitle => 'कैलोरी, मैक्रो और मुख्य पोषक तत्व खुद दर्ज करें।';

  @override
  String get nutritionGoalsSaved => 'लक्ष्य सहेजे गए';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'कैलोरी: $calories / प्रोटीन: $protein / कार्ब्स: $carbs / वसा: $fat / फाइबर: $fiber / शुगर: $sugar / सैचुरेटेड वसा: $satFat / सोडियम: $sodium';
  }

  @override
  String get progressSettingsTitle => 'प्रगति सेटिंग्स';

  @override
  String get progressSettingsSubtitle => 'शरीर माप और ट्रेंड ट्रैकिंग सेटअप प्रबंधित करें।';

  @override
  String get progressMeasurements => 'माप';

  @override
  String get progressMeasurementsSubtitle => 'समय के साथ ट्रैक करने के लिए शरीर मीट्रिक कॉन्फ़िगर करें।';

  @override
  String get progressMeasurementLibrary => 'माप लाइब्रेरी';

  @override
  String get progressMeasurementLibrarySubtitle => 'वज़न, ऊँचाई, शरीर माप और कस्टम मीट्रिक प्रबंधित करें।';

  @override
  String get nutritionManualGoalsTitle => 'मैन्युअल पोषण लक्ष्य';

  @override
  String get nutritionManualGoalsPageSubtitle => 'कैलोरी, मैक्रो और पोषक लक्ष्य मैन्युअल रूप से तय करें।';

  @override
  String get nutritionSaveGoals => 'लक्ष्य सहेजें';

  @override
  String get nutritionSaving => 'सहेजा जा रहा है...';

  @override
  String get nutritionStartDate => 'आरंभ तिथि';

  @override
  String get nutritionGoalStarts => 'लक्ष्य शुरू होता है';

  @override
  String get nutritionCaloriesAndMacros => 'कैलोरी और मैक्रोज़';

  @override
  String get nutritionAdditionalNutrients => 'अतिरिक्त पोषक तत्व';

  @override
  String get nutritionCalories => 'कैलोरी (kcal)';

  @override
  String get nutritionProtein => 'प्रोटीन (g)';

  @override
  String get nutritionCarbs => 'कार्ब्स (g)';

  @override
  String get nutritionFat => 'वसा (g)';

  @override
  String get nutritionFiber => 'फाइबर (g)';

  @override
  String get nutritionSugar => 'शुगर (g)';

  @override
  String get nutritionSatFat => 'सैचुरेटेड वसा (g)';

  @override
  String get nutritionSodium => 'सोडियम (mg)';

  @override
  String get nutritionEnterNumber => 'संख्या दर्ज करें';

  @override
  String get nutritionNumberAtLeastZero => '0 या अधिक होना चाहिए';

  @override
  String rankingsSaved(String target) {
    return '$target रैंकिंग सहेजी गई';
  }

  @override
  String get rankingsSave => 'रैंकिंग सहेजें';

  @override
  String rankingsTitle(String target) {
    return '$target रैंकिंग';
  }

  @override
  String rankingsHero(String target) {
    return 'बनाए गए प्रशिक्षण में प्राथमिकता देने के लिए $target को इच्छित क्रम में खींचें।';
  }

  @override
  String get rankingsNoBodyParts => 'कोई शरीर-भाग परिभाषित नहीं है';

  @override
  String get rankingsNoMuscles => 'कोई मांसपेशी परिभाषित नहीं है';

  @override
  String rankingsLoadError(String target, String error) {
    return '$target लोड नहीं हो सका: $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'सहेजा नहीं जा सका: $error';
  }

  @override
  String get rankingsRank => 'रैंक';

  @override
  String get mappingTitle => 'शरीररचना मैपिंग';

  @override
  String get mappingHero => 'मांसपेशियों को शरीर-भागों से जोड़ें, ताकि हीटमैप, एनालिटिक्स और बनाए गए वर्कआउट एकमत रहें।';

  @override
  String get mappingSaved => 'मैपिंग सहेजी गई';

  @override
  String mappingSaveFailed(String error) {
    return 'सहेजा नहीं जा सका: $error';
  }

  @override
  String get mappingSelectedBodyPart => 'चुना गया शरीर-भाग';

  @override
  String get mappingBodyPart => 'शरीर-भाग';

  @override
  String get mappingChooseLinkedMuscles => 'जुड़ी मांसपेशियाँ चुनें';

  @override
  String get mappingLinkedMuscles => 'जुड़ी मांसपेशियाँ';

  @override
  String get mappingChooseLinkedSubtitle => 'इस शरीर-भाग की हर मांसपेशी चुनें।';

  @override
  String mappingLinkedCount(int count) {
    return '$count मांसपेशियाँ अभी जुड़ी हैं।';
  }

  @override
  String get mappingNoMuscles => 'कोई मांसपेशी परिभाषित नहीं है।';

  @override
  String get mappingNoLinkedMuscles => 'अभी कोई मांसपेशी नहीं जुड़ी है। कुछ जोड़ने के लिए संपादित करें टैप करें।';

  @override
  String get volumeMaintenance => 'रखरखाव';

  @override
  String get volumeMinEffective => 'न्यूनतम प्रभावी';

  @override
  String get volumeMaxAdaptive => 'अधिकतम अनुकूलनीय';

  @override
  String get volumeMaxRecoverable => 'अधिकतम पुनर्प्राप्त करने योग्य';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'शरीर-भाग सीमाएँ लोड नहीं हो सकीं: $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'मांसपेशी सीमाएँ लोड नहीं हो सकीं: $error';
  }

  @override
  String get volumeBodyPartSaved => 'शरीर-भाग सीमाएँ सहेजी गईं';

  @override
  String get volumeMuscleSaved => 'मांसपेशी सीमाएँ सहेजी गईं';

  @override
  String get volumeInvalidNumbers => 'कृपया मान्य संख्याएँ दर्ज करें';

  @override
  String get volumeBodyParts => 'शरीर-भाग';

  @override
  String get volumeMuscles => 'मांसपेशियाँ';

  @override
  String get volumeBodyPartTitle => 'शरीर-भाग वॉल्यूम';

  @override
  String get volumeBodyPartSubtitle => 'साप्ताहिक एनालिटिक्स और वर्कआउट जनरेशन में उपयोग होने वाली साप्ताहिक लक्ष्य सीमाएँ सेट करें।';

  @override
  String get volumeMuscleTitle => 'मांसपेशी वॉल्यूम';

  @override
  String get volumeMuscleSubtitle => 'अलग-अलग मांसपेशियों के लिए साप्ताहिक लक्ष्य सीमाओं को बेहतर बनाएँ।';

  @override
  String get volumeSelection => 'चयन';

  @override
  String get volumeRecommendedRange => 'सुझाई गई सीमा';

  @override
  String get volumeRecommendedRangeSubtitle => 'संख्याएँ प्रति सप्ताह सेट इकाइयाँ हैं।';

  @override
  String get volumeSaveBoundaries => 'सीमाएँ सहेजें';

  @override
  String get nutritionDashboardTitle => 'पोषण डैशबोर्ड';

  @override
  String nutritionDashboardError(String error) {
    return 'पोषण लोड नहीं हो सका: $error';
  }

  @override
  String get nutritionMenuTitle => 'पोषण मेनू';

  @override
  String get nutritionLogFood => 'खाद्य लॉग करें';

  @override
  String get nutritionTrackMeasurement => 'माप ट्रैक करें';

  @override
  String get nutritionMeasuredItems => 'मापे गए आइटम';

  @override
  String get nutritionTodayRecords => 'आज के रिकॉर्ड';

  @override
  String get nutritionGoalsMenu => 'पोषण लक्ष्य';

  @override
  String get measurementWeight => 'वजन';

  @override
  String get measurementHips => 'कूल्हे';

  @override
  String get measurementShoulders => 'कंधे';

  @override
  String get measurementCalves => 'पिंडलियाँ';

  @override
  String get measurementTrackNew => 'नया माप ट्रैक करें';

  @override
  String get barcodeScannerTitle => 'बारकोड स्कैन करें';

  @override
  String get barcodeSwitchCamera => 'कैमरा बदलें';

  @override
  String get barcodeTorchOn => 'टॉर्च चालू';

  @override
  String get barcodeTorchOff => 'टॉर्च बंद';

  @override
  String get barcodeTorchUnavailable => 'इस डिवाइस पर टॉर्च उपलब्ध नहीं है';

  @override
  String get barcodeAlignHint => 'बारकोड को फ्रेम के भीतर संरेखित करें';

  @override
  String get progressTutorialWorkoutReportTitle => 'वर्कआउट रिपोर्ट';

  @override
  String get progressTutorialWorkoutReportBody => 'यह अलग-अलग समय सीमाओं में वर्कआउट गिनती, प्रशिक्षण समय और वॉल्यूम ट्रैक करता है। ग्राफ़ में दिखने वाली चीज़ बदलने के लिए किसी मीट्रिक को टैप करें।';

  @override
  String get progressTutorialExerciseProgressTitle => 'व्यायाम प्रगति';

  @override
  String get progressTutorialExerciseProgressBody => 'चुने हुए व्यायामों की शक्ति के रुझान ट्रैक करें। इस डैशबोर्ड से व्यायाम जोड़ने या हटाने के लिए संपादन टाइल का उपयोग करें।';

  @override
  String get progressTutorialHealthTrendsTitle => 'स्वास्थ्य रुझान';

  @override
  String get progressTutorialHealthTrendsBody => 'यहाँ शरीर का वज़न और कस्टम माप लॉग करें, फिर समय के साथ उनमें बदलाव देखें।';

  @override
  String get measurementNewTitle => 'नया माप';

  @override
  String get measurementPresets => 'प्रीसेट्स';

  @override
  String get measurementCustom => 'कस्टम';

  @override
  String get measurementPresetType => 'प्रीसेट प्रकार';

  @override
  String get measurementVariation => 'भिन्नता';

  @override
  String get measurementWakeUp => 'जागने का समय';

  @override
  String get measurementBedtime => 'सोने का समय';

  @override
  String get measurementOverall => 'समग्र';

  @override
  String get measurementValueWeight => 'वजन';

  @override
  String get measurementUnits => 'इकाइयाँ';

  @override
  String get measurementFeet => 'फीट';

  @override
  String get measurementInches => 'इंच';

  @override
  String get measurementCentimeters => 'सेंटीमीटर';

  @override
  String get measurementWithPump => 'पंप के साथ';

  @override
  String get measurementWithoutPump => 'पंप के बिना';

  @override
  String get measurementName => 'माप का नाम';

  @override
  String get measurementNameHint => 'छाती का आकार, आराम की हृदय गति...';

  @override
  String get measurementValue => 'मान';

  @override
  String get measurementUnit => 'इकाई';

  @override
  String get measurementNote => 'नोट';

  @override
  String get measurementOptional => 'वैकल्पिक';

  @override
  String get measurementSaveNew => 'नया माप सहेजें';

  @override
  String get measurementCustomRequired => 'कस्टम नाम, मान और इकाई दर्ज करें';

  @override
  String measurementDefinitionNotFound(String name) {
    return '$name के लिए परिभाषा नहीं मिली';
  }

  @override
  String get measurementInvalidValue => 'मान्य संख्यात्मक मान दर्ज करें';

  @override
  String get measurementHeight => 'कद';

  @override
  String get measurementForearm => 'फोरआर्म';

  @override
  String get measurementArm => 'बांह';

  @override
  String get measurementNeck => 'गर्दन';

  @override
  String get measurementChest => 'छाती';

  @override
  String get measurementWaist => 'कमर';

  @override
  String get measurementThigh => 'जांघ';

  @override
  String get measurementInstructionsForearm => 'अपने फोरआर्म के सबसे चौड़े भाग के चारों ओर मापें।';

  @override
  String get measurementInstructionsArm => 'अपने बाइसेप के सबसे चौड़े भाग के चारों ओर मापें।';

  @override
  String get measurementInstructionsNeck => 'जहाँ टेप आपकी गर्दन के चारों ओर सीधा बैठता है वहाँ मापें।';

  @override
  String get measurementInstructionsShoulder => 'टेप को साइड डेल्टॉइड के चारों ओर सीधा रखें।';

  @override
  String get measurementInstructionsChest => 'बगल के नीचे और निप्पल लाइन के ऊपर मापें।';

  @override
  String get measurementInstructionsWaist => 'अपनी नाभि के चारों ओर मापें।';

  @override
  String get measurementInstructionsHip => 'अपने ग्लूट्स के सबसे चौड़े भाग के चारों ओर मापें।';

  @override
  String get measurementInstructionsThigh => 'अपनी जांघ के सबसे चौड़े भाग के चारों ओर मापें।';

  @override
  String get measurementInstructionsCalf => 'अपने पिंडली के सबसे चौड़े भाग के चारों ओर मापें।';

  @override
  String get nutritionCaloriesLabel => 'कैलोरी';

  @override
  String get nutritionFatLabel => 'वसा';

  @override
  String get nutritionProteinLabel => 'प्रोटीन';

  @override
  String get nutritionCarbsLabel => 'कार्ब्स';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | C $carbs g | F $fat g';
  }

  @override
  String get nutritionEditEntry => 'एंट्री संपादित करें';

  @override
  String get nutritionEditNotAvailable => 'एंट्रियों का संपादन अभी उपलब्ध नहीं है';

  @override
  String get nutritionEntryDeleted => 'एंट्री हटा दी गई';

  @override
  String get gymProfileEditTitle => 'जिम प्रोफ़ाइल संपादित करें';

  @override
  String get gymProfileNewTitle => 'नई जिम प्रोफ़ाइल';

  @override
  String get gymProfileTutorialSpaceTitle => 'वर्कआउट स्थान';

  @override
  String get gymProfileTutorialSpaceBody => 'जिस जगह आप प्रशिक्षण लेते हैं उसके लिए इस प्रोफ़ाइल को नाम दें, जैसे होम जिम, कमर्शियल जिम या यात्रा सेटअप।';

  @override
  String get gymProfileTutorialFindTitle => 'उपकरण खोजें';

  @override
  String get gymProfileTutorialFindBody => 'उपकरण सूची लंबी होने पर किसी एक आइटम पर तुरंत जाने के लिए खोज का उपयोग करें।';

  @override
  String get gymProfileTutorialAvailableTitle => 'उपलब्ध उपकरण';

  @override
  String get gymProfileTutorialAvailableBody => 'इस वर्कआउट स्थान में उपलब्ध उपकरण चुनें। बनाए गए प्लान और बदलाव अनुपलब्ध व्यायाम से बचने के लिए इसका उपयोग करते हैं।';

  @override
  String get gymProfileTutorialSaveTitle => 'प्रोफ़ाइल सहेजें';

  @override
  String get gymProfileTutorialSaveBody => 'सहेजें प्रोफ़ाइल और उपकरण सहेजता है। रद्द करें बिना सहेजे बदलाव छोड़ने से पहले पूछता है।';

  @override
  String get gymProfileSaveChangesTitle => 'बदलाव सहेजें?';

  @override
  String get gymProfileSaveChangesBody => 'आपके जिम प्रोफ़ाइल में बिना सहेजे बदलाव हैं। जाने से पहले उन्हें सहेजें?';

  @override
  String get gymProfileKeepEditing => 'संपादन जारी रखें';

  @override
  String get gymProfileDiscard => 'छोड़ दें';

  @override
  String get gymProfileSelectEquipment => 'कम से कम एक उपकरण आइटम चुनें।';

  @override
  String gymProfileSaveFailed(String error) {
    return 'प्रोफ़ाइल सहेजी नहीं जा सकी: $error';
  }

  @override
  String get gymProfileEquipmentHint => 'इस जिम में उपलब्ध उपकरण चुनें, ताकि बनाए गए प्लान केवल उपलब्ध उपकरण का उपयोग करें।';

  @override
  String get gymProfileSpace => 'वर्कआउट स्थान';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected में से $total उपकरण विकल्प चुने गए';
  }

  @override
  String get gymProfileName => 'प्रोफ़ाइल नाम';

  @override
  String get gymProfileNameHint => 'होम जिम, कमर्शियल जिम, यात्रा सेटअप...';

  @override
  String get gymProfileNameRequired => 'नाम आवश्यक है';

  @override
  String get gymProfileFilterEquipment => 'नाम से उपकरण फ़िल्टर करें';

  @override
  String get gymProfileEquipment => 'उपकरण';

  @override
  String get gymProfileSelectAll => 'सभी चुनें';

  @override
  String get gymProfileClear => 'साफ़ करें';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total चुने गए';
  }

  @override
  String get gymProfileSave => 'प्रोफ़ाइल सहेजें';

  @override
  String get gymProfileSaving => 'सहेजा जा रहा है...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return 'कोई उपकरण \"$query\" से मेल नहीं खाता।';
  }

  @override
  String get equipmentCategoryBasics => 'मूल बातें';

  @override
  String get equipmentCategoryFreeWeights => 'फ्री वेट';

  @override
  String get equipmentCategoryBenchesRacks => 'बेंच और रैक';

  @override
  String get equipmentCategoryCableAttachments => 'केबल और अटैचमेंट';

  @override
  String get equipmentCategoryMachines => 'मशीनें';

  @override
  String get equipmentCategoryOther => 'अन्य उपकरण';

  @override
  String get equipmentNoRequirement => 'कोई आवश्यक उपकरण नहीं';

  @override
  String get equipmentBodyweightSupport => 'बॉडीवेट व्यायाम सहायता';

  @override
  String get equipmentMachineBased => 'मशीन आधारित व्यायाम';

  @override
  String get equipmentCableAccessory => 'केबल स्टेशन सहायक उपकरण';

  @override
  String get equipmentBenchRackSetup => 'बेंच, रैक या स्टेशन सेटअप';

  @override
  String get equipmentFreeWeightTraining => 'फ्री वेट प्रशिक्षण';

  @override
  String get equipmentAvailable => 'उपलब्ध उपकरण';

  @override
  String get foodLoggingTitle => 'खाद्य लॉगिंग';

  @override
  String get foodLogTime => 'लॉग समय:';

  @override
  String get foodPortion => 'परोसने की मात्रा:';

  @override
  String get foodQuantity => 'मात्रा:';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / इकाई';
  }

  @override
  String get foodRemove => 'हटाएँ';

  @override
  String get foodAddAllToDiary => 'सभी को डायरी में जोड़ें';

  @override
  String get foodLogging => 'लॉग किया जा रहा है...';

  @override
  String get foodTabScan => 'स्कैन';

  @override
  String get foodTabSearch => 'खोजें';

  @override
  String get foodTabPlanned => 'पूर्व-नियोजित';

  @override
  String get foodTabCustom => 'कस्टम';

  @override
  String get foodSearchHint => 'खाद्य खोजें...';

  @override
  String get foodNoRecentRecipes => 'अभी कोई हाल की रेसिपी नहीं।';

  @override
  String get foodRecentRecipe => 'हाल की रेसिपी';

  @override
  String get foodNoFoodsFound => 'कोई खाद्य नहीं मिला।';

  @override
  String get foodInstantLogAfterScan => 'स्कैन के बाद तुरंत लॉग करें';

  @override
  String get foodInstantLogAfterScanSubtitle => 'चुने गए भोजन का उपयोग करके स्कैन किया गया आइटम तुरंत जोड़ें।';

  @override
  String get foodOpenCameraScanner => 'कैमरा स्कैनर खोलें';

  @override
  String get foodEnterBarcode => 'बारकोड मैन्युअल रूप से दर्ज करें';

  @override
  String get foodEnterBarcodeHint => 'जैसे 012345678905';

  @override
  String get foodLogByBarcode => 'बारकोड से लॉग करें';

  @override
  String get foodNoBarcode => 'कोई मान्य बारकोड नहीं मिला';

  @override
  String get foodBarcodeLogged => 'बारकोड से आइटम लॉग किया गया';

  @override
  String foodFailed(String error) {
    return 'विफल: $error';
  }

  @override
  String get foodCustomSavedBarcode => 'कस्टम खाद्य सहेजा गया और बारकोड लिंक किया गया';

  @override
  String get foodFavorites => 'पसंदीदा';

  @override
  String get foodRecentFoods => 'हाल के खाद्य';

  @override
  String get foodStartSearching => 'खाद्य खोजने के लिए खोज शुरू करें।';

  @override
  String get foodFavorite => 'पसंदीदा';

  @override
  String get foodUnfavorite => 'पसंदीदा से हटाएँ';

  @override
  String get foodCustomize => 'खाद्य अनुकूलित करें';

  @override
  String get foodEditAndAdd => 'संपादित करें और जोड़ें';

  @override
  String get foodAddOne => '1 जोड़ें';

  @override
  String get foodAddNew => 'नया खाद्य आइटम जोड़ें';

  @override
  String get foodCustomSaved => 'कस्टम खाद्य सहेजा गया';

  @override
  String get foodNoteOptional => 'नोट (वैकल्पिक)';

  @override
  String get foodTagsHint => 'टैग (कॉमा से अलग, जैसे वर्कआउट के बाद, उच्च-प्रोटीन)';

  @override
  String get foodAddToPlate => 'प्लेट में जोड़ें';

  @override
  String get foodProfileNotReady => 'प्रोफ़ाइल अभी तैयार नहीं है।';

  @override
  String get foodItemsLogged => 'डायरी में लॉग किए गए आइटम';

  @override
  String foodLogFailed(String error) {
    return 'लॉग नहीं हो सका: $error';
  }

  @override
  String get tutorialSkip => 'छोड़ें';

  @override
  String get tutorialSkipAll => 'सभी छोड़ें';

  @override
  String get tutorialDone => 'पूर्ण';

  @override
  String get tutorialNext => 'अगला';

  @override
  String get tutorialSkipAllTitle => 'सभी ट्यूटोरियल छोड़ें?';

  @override
  String get tutorialSkipAllBody => 'इससे हर निर्देशित ट्यूटोरियल छिप जाएगा। सेटिंग्स > निर्देशित ट्यूटोरियल में सभी ट्यूटोरियल रीसेट करके आप इन्हें कभी भी वापस चालू कर सकते हैं।';

  @override
  String get tutorialKeep => 'ट्यूटोरियल रखें';

  @override
  String get tutorialSkipEverything => 'सभी छोड़ें';

  @override
  String get flowSelectNode => 'नोड चुनें';

  @override
  String get flowSelectMethod => 'विधि चुनें';

  @override
  String get flowAddSuccess => '+ सफलता';

  @override
  String get flowAddFailure => '+ असफलता';

  @override
  String get flowAddMethod => '+ विधि';

  @override
  String get flowRemoveMethod => '- विधि';

  @override
  String get flowNewEvent => 'नया इवेंट';

  @override
  String get flowEventKey => 'इवेंट कुंजी';

  @override
  String get flowEventDisplayLabel => 'प्रदर्शन लेबल (वैकल्पिक)';

  @override
  String get flowAddSuccessNode => 'सफलता नोड जोड़ें';

  @override
  String get flowAddFailureNode => 'असफलता नोड जोड़ें';

  @override
  String get flowAddEvent => '+ इवेंट';

  @override
  String get flowSelectEvent => 'इवेंट चुनें';

  @override
  String get flowRemoveEvent => 'इवेंट हटाएँ';

  @override
  String get drawerNavigation => 'नेविगेशन';

  @override
  String get drawerOptionA => 'विकल्प A';

  @override
  String get drawerOptionB => 'विकल्प B';

  @override
  String get drawerOptionC => 'विकल्प C';

  @override
  String get drawerGymProfiles => 'जिम प्रोफ़ाइल';

  @override
  String drawerSavedSpaces(int count) {
    return '$count सहेजे गए स्थान';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name सक्रिय है';
  }

  @override
  String get drawerActiveProfile => 'सक्रिय प्रोफ़ाइल';

  @override
  String get drawerTapToSwitch => 'बदलने के लिए टैप करें';

  @override
  String get drawerNewProfile => 'नई प्रोफ़ाइल';

  @override
  String get commonAdd => 'जोड़ें';

  @override
  String get commonRemove => 'हटाएँ';

  @override
  String get automaticSaving => 'सहेजा जा रहा है...';

  @override
  String get automaticValuesTab => 'मान';

  @override
  String get automaticMethodsTab => 'विधियाँ';

  @override
  String get automaticGlobalIncrement => 'वैश्विक वृद्धि मात्रा';

  @override
  String get automaticAutoSelect => 'स्वतः चुनें';

  @override
  String get automaticManualSelect => 'मैन्युअल चयन';

  @override
  String get automaticSkipFirstSet => 'पहला सेट छोड़ें?';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return 'सेट $number: $weight x $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return 'सेट $parent.$child: $weight x $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return 'सेटिंग्स सहेजी नहीं जा सकीं: $error';
  }

  @override
  String get automaticIncrementWhen => 'वृद्धि कब करें (अन्यथा कमी):';

  @override
  String get automaticWeightTarget => 'पूरा वजन >= लक्षित वजन';

  @override
  String get automaticRepsTarget => 'पूरी की गई रिप्स >= लक्षित रिप्स';

  @override
  String get automaticVolumeTarget => 'पूरा वॉल्यूम >= लक्षित वॉल्यूम';

  @override
  String get automaticScopeLabel => 'सफलता, चूक और समायोजन की गिनती इस प्रकार होती है:';

  @override
  String get automaticWorkoutSession => 'वर्कआउट सत्र';

  @override
  String get automaticPerExercise => 'प्रति व्यायाम';

  @override
  String get automaticPerSet => 'प्रति सेट';

  @override
  String get automaticAdjustScope => 'समायोजित करें:';

  @override
  String get automaticAdjustOneSet => '1 सेट';

  @override
  String get automaticAdjustAllSets => 'सभी सेट';

  @override
  String get weightExpandSets => 'सेट फैलाएँ';

  @override
  String get weightCollapseSets => 'सेट समेटें';

  @override
  String get weightDetails => 'विवरण';

  @override
  String get weightRemoveExerciseTitle => 'व्यायाम हटाएँ';

  @override
  String get weightRemoveExerciseBody => 'क्या आप वाकई यह व्यायाम हटाना चाहते हैं?';

  @override
  String get weightSwapExercise => 'व्यायाम बदलें';

  @override
  String get weightMakeChangeSet => 'ChangeSet बनाएँ';

  @override
  String weightSetLabel(int number) {
    return 'सेट $number';
  }

  @override
  String weightLabel(String unit) {
    return 'वजन ($unit)';
  }

  @override
  String get weightReps => 'रिप्स';

  @override
  String get weightRemoveSetTitle => 'सेट हटाएँ';

  @override
  String get weightRemoveSetBody => 'क्या आप वाकई यह सेट हटाना चाहते हैं?';

  @override
  String weightChangeSetLabel(int number) {
    return 'CSet $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'वजन ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'CSet हटाएँ';

  @override
  String get weightRemoveChangeSetBody => 'क्या आप वाकई यह CSet हटाना चाहते हैं?';

  @override
  String get weightAddChangeSet => 'CSet जोड़ें';

  @override
  String get weightAddSet => 'सेट जोड़ें';

  @override
  String get swapAlreadySelected => 'वह व्यायाम पहले से चुना गया है।';

  @override
  String get swapNeedsProfileEquipment => 'उस व्यायाम को इस प्रोफ़ाइल के बाहर के उपकरण चाहिए।';

  @override
  String swapLoadFailed(Object error) {
    return 'वह विकल्प व्यायाम लोड नहीं हो सका।';
  }

  @override
  String get swapCurrent => 'वर्तमान';

  @override
  String get swapReplacement => 'विकल्प';

  @override
  String get swapConfirm => 'स्वैप की पुष्टि करें';

  @override
  String get swapNoBodypartData => 'कोई शरीर-भाग डेटा नहीं मिला।';

  @override
  String get swapLoadingSelected => 'चयनित व्यायाम लोड हो रहा है...';

  @override
  String get swapBrowseCatalog => 'व्यायाम कैटलॉग ब्राउज़ करें';

  @override
  String get swapNoEquipment => 'कोई उपकरण सूचीबद्ध नहीं';

  @override
  String get swapTitle => 'व्यायाम बदलें';

  @override
  String get swapFindingMatches => 'समान शरीर-भाग और मांसपेशी मैच खोजे जा रहे हैं...';

  @override
  String get swapChooseReplacement => 'समान विकल्प चुनें।';

  @override
  String get swapFilterProfileEquipment => 'प्रोफ़ाइल उपकरण के लिए फ़िल्टर करें';

  @override
  String get swapBodypartsHit => 'प्रशिक्षित शरीर भाग';

  @override
  String swapMatch(int percent) {
    return '$percent% मैच';
  }

  @override
  String get swapNoReplacements => 'अभी कोई समान विकल्प नहीं मिला।';

  @override
  String get swapNoReplacementsBody => 'अच्छी तरह बदलने से पहले इस व्यायाम को और मांसपेशी या शरीर-भाग मेटाडेटा की आवश्यकता हो सकती है।';

  @override
  String get premadePlansTitle => 'तैयार योजनाएँ';

  @override
  String get premadeTutorialLengthTitle => 'योजना अवधि';

  @override
  String get premadeTutorialLengthBody => '1-घंटे और 2-घंटे के संस्करणों में बदलें। लंबे संस्करणों में अधिक व्यायाम और कुल सेट होते हैं।';

  @override
  String get premadeTutorialEquipmentTitle => 'प्रोफ़ाइल उपकरण';

  @override
  String get premadeTutorialEquipmentBody => 'इसे चालू करने पर Tonos अनुपलब्ध व्यायाम को ऐसे समान विकल्प से बदलता है जो आपकी वर्तमान जिम प्रोफ़ाइल कर सकती है।';

  @override
  String get premadeTutorialLibraryTitle => 'योजना लाइब्रेरी';

  @override
  String get premadeTutorialLibraryBody => 'स्प्लिट खोलें, योजना देखें, फिर उसे सक्रिय योजनाओं में जोड़ें ताकि वह ट्रेन में दिखे।';

  @override
  String get premadeSelectProfile => 'कृपया पहले जिम प्रोफ़ाइल चुनें।';

  @override
  String premadePlanAdded(String name) {
    return '$name सक्रिय योजनाओं में जोड़ा गया।';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return '$name जोड़ा नहीं जा सका: $error';
  }

  @override
  String get premadeDescription => 'कोच, इन्फ्लुएंसर और ऐप-चयनित रूटीन को अपनी योजनाओं में कॉपी करें। जोड़ने के बाद आप इन्हें किसी भी अन्य योजना की तरह संपादित कर सकते हैं।';

  @override
  String get premadeDiscarding => 'त्यागा जा रहा है...';

  @override
  String get premadeReviewPlans => 'योजनाएँ देखें';

  @override
  String get allocationSaveChanges => 'बदलाव सहेजें';

  @override
  String get allocationSaving => 'सहेजा जा रहा है';

  @override
  String get allocationInvalidCredit => 'हर क्रेडिट के लिए शून्य या सकारात्मक संख्या दर्ज करें।';

  @override
  String get allocationSaved => 'व्यायाम आवंटन सहेजा गया।';

  @override
  String get allocationSaveFailed => 'व्यायाम आवंटन सहेजा नहीं जा सका। फिर से प्रयास करें।';

  @override
  String get allocationSaveOrDiscard => 'रीसेट करने से पहले अपने बदलाव सहेजें या त्यागें।';

  @override
  String get allocationTitle => 'व्यायाम सेट आवंटन';

  @override
  String get allocationSubtitle => 'समीक्षा करें कि पूरे किए गए सेट लक्षित मांसपेशियों और शरीर भागों में कैसे योगदान देते हैं।';

  @override
  String get allocationHowTitle => 'सेट क्रेडिट कैसे काम करता है';

  @override
  String get allocationHowBody => 'एक प्राथमिक मांसपेशी को आम तौर पर एक पूरे सेट के लिए 1.00 क्रेडिट मिलता है। सहायक मांसपेशियों को कम क्रेडिट मिलता है। यह शरीर रचना सारांश और सुझावों का मार्गदर्शन करता है, लेकिन आपके लॉग किए गए सेट कभी नहीं बदलता।';

  @override
  String allocationLoadFailed(String error) {
    return 'व्यायाम लोड नहीं हो सके। $error';
  }

  @override
  String get allocationNoExercises => 'अभी कोई व्यायाम उपलब्ध नहीं है।';

  @override
  String get allocationSelectedExercise => 'चयनित व्यायाम';

  @override
  String get allocationMuscleCredit => 'मांसपेशी क्रेडिट';

  @override
  String get allocationBodypartCredit => 'शरीर-भाग क्रेडिट';

  @override
  String get allocationNoTargetMuscles => 'कोई लक्षित मांसपेशी नहीं';

  @override
  String get allocationNoBodypartMapping => 'कोई शरीर-भाग मैपिंग नहीं';

  @override
  String get allocationReset => 'रीसेट करें';

  @override
  String get allocationCredit => 'क्रेडिट';

  @override
  String get allocationNoTargetMusclesBody => 'इस व्यायाम में अभी लक्षित मांसपेशी डेटा नहीं है।';

  @override
  String get allocationMuscleCreditBody => 'निजी आवंटन बनाने के लिए मान बदलें। यह मांसपेशी सारांश और व्युत्पन्न शरीर-भाग फोकस में उपयोग होता है।';

  @override
  String get allocationNoBodypartMappingBody => 'इस व्यायाम में अभी शरीर-भाग मैपिंग डेटा नहीं है।';

  @override
  String get allocationBodypartCreditBody => 'स्वचालित मान मांसपेशियों और शरीर रचना मैपिंग से प्राप्त होते हैं। किसी को संपादित करने पर निजी शरीर-भाग आवंटन बनता है।';

  @override
  String get healthTrendsTitle => 'स्वास्थ्य रुझान';

  @override
  String get healthMetric => 'मेट्रिक';

  @override
  String get healthUnableToLoad => 'माप लोड नहीं हो सके';

  @override
  String get healthNoMeasurements => 'अभी कोई माप नहीं';

  @override
  String get healthNoMeasurementsBody => 'प्रगति ट्रैक करने के लिए मेट्रिक बनाएँ।';

  @override
  String get healthCreateMetric => 'मेट्रिक बनाएँ';

  @override
  String healthLogMeasurement(String name) {
    return '$name लॉग करें';
  }

  @override
  String healthEditMeasurement(String name) {
    return '$name संपादित करें';
  }

  @override
  String get healthTutorialSummaryTitle => 'माप सारांश';

  @override
  String get healthTutorialSummaryBody => 'नवीनतम मान, पिछली एंट्री से बदलाव और मौजूद रिकॉर्ड की संख्या देखें।';

  @override
  String get healthTutorialChartTitle => 'रुझान चार्ट';

  @override
  String get healthTutorialChartBody => 'जैसे-जैसे आप और एंट्रियाँ लॉग करते हैं, चार्ट दिखाता है कि यह माप समय के साथ कैसे बदलता है।';

  @override
  String get healthTutorialEntriesTitle => 'एंट्रियाँ';

  @override
  String get healthTutorialEntriesBody => 'संपादित करने के लिए किसी एंट्री पर टैप करें, या गलती से लॉग हुई एंट्रियाँ हटाएँ।';

  @override
  String get healthTutorialLogTitle => 'नई एंट्री लॉग करें';

  @override
  String get healthTutorialLogBody => 'नया माप रिकॉर्ड जोड़ने के लिए जब चाहें इस बटन का उपयोग करें।';

  @override
  String get healthDeleteEntryTitle => 'एंट्री हटाएँ?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return '$date का $value हटा दिया जाएगा।';
  }

  @override
  String get healthLogEntry => 'एंट्री लॉग करें';

  @override
  String healthLoadFailed(String error) {
    return 'लोड नहीं हो सका: $error';
  }

  @override
  String get healthEntries => 'एंट्रियाँ';

  @override
  String get healthNoEntries => 'अभी कोई एंट्री नहीं';

  @override
  String healthFirstEntry(String name) {
    return 'अपना पहला $name माप लॉग करें।';
  }

  @override
  String get workoutReportLoadFailed => 'वर्कआउट रिपोर्ट लोड नहीं हो सकी।';

  @override
  String get workoutReportTitle => 'वर्कआउट रिपोर्ट';

  @override
  String get workoutReportAdditionalDetails => 'अतिरिक्त विवरण';

  @override
  String get recommendedSetsEdit => 'सुझाए गए सेट संपादित करें';

  @override
  String get recommendedSetsTitle => 'सुझाए गए सेट';

  @override
  String get recommendedSetsMinimum => 'न्यूनतम सुझाए गए सेट';

  @override
  String get recommendedSetsMaximum => 'अधिकतम सुझाए गए सेट';

  @override
  String get recommendedSetsValidNumbers => 'मान्य सेट संख्या दर्ज करें।';

  @override
  String get recommendedSetsNonNegative => 'सेट संख्या ऋणात्मक नहीं हो सकती।';

  @override
  String get recommendedSetsRange => 'अधिकतम कम से कम न्यूनतम होना चाहिए।';

  @override
  String get workoutReportWorkouts => 'वर्कआउट्स';

  @override
  String get workoutReportTime => 'समय';

  @override
  String get workoutReportVolume => 'वॉल्यूम';

  @override
  String get workoutReportWorkout => 'वर्कआउट';

  @override
  String get workoutReportTotal => 'कुल';

  @override
  String get databaseSettingsTitle => 'डेटाबेस सेटिंग्स';

  @override
  String get databaseSettingsSubtitle => 'बैकअप, क्लाउड मीडिया, स्वास्थ्य जाँच और डेवलपर एक्सपोर्ट।';

  @override
  String get databaseBackupRestore => 'बैकअप और पुनर्स्थापना';

  @override
  String get databaseBackupRestoreSubtitle => 'अपने स्थानीय Tonos डेटा को सुरक्षित रूप से अंदर या बाहर ले जाएँ।';

  @override
  String get databaseExportBackup => 'डेटाबेस बैकअप एक्सपोर्ट करें';

  @override
  String get databaseImportBackup => 'डेटाबेस बैकअप इम्पोर्ट करें';

  @override
  String get databaseImportBackupSubtitle => 'सहेजी गई एक्सपोर्ट फ़ाइल से स्थानीय डेटा बदलें।';

  @override
  String get databaseHealth => 'स्वास्थ्य';

  @override
  String get databaseHealthSubtitle => 'डेटाबेस आकार, स्कीमा और खोज इंडेक्स स्थिति का त्वरित विवरण।';

  @override
  String get databaseCheckingHealth => 'डेटाबेस स्वास्थ्य जाँचा जा रहा है...';

  @override
  String get databaseCheckingHealthSubtitle => 'स्कीमा, आकार, तालिकाएँ और इंडेक्स पढ़े जा रहे हैं।';

  @override
  String get databaseHealthFailed => 'डेटाबेस स्वास्थ्य जाँच नहीं हुई';

  @override
  String get databaseMaintenance => 'रखरखाव';

  @override
  String get databaseMaintenanceSubtitle => 'जाँच, अनुकूलन और स्टोरेज सफ़ाई के सुरक्षित उपकरण।';

  @override
  String get databaseRefreshHealth => 'स्वास्थ्य रीफ़्रेश करें';

  @override
  String get databaseIntegrityCheck => 'इंटीग्रिटी जाँच चलाएँ';

  @override
  String get databaseIntegrityCheckSubtitle => 'SQLite से स्थानीय डेटाबेस फ़ाइल सत्यापित करने को कहें।';

  @override
  String get databaseOptimize => 'डेटाबेस अनुकूलित करें';

  @override
  String get databaseCheckpointWal => 'WAL चेकपॉइंट';

  @override
  String get databaseCheckpointWalSubtitle => 'राइट-अहेड लॉग को डेटाबेस फ़ाइल में फ्लश करता है।';

  @override
  String get databaseVacuum => 'डेटाबेस वैक्यूम करें';

  @override
  String get databaseVacuumSubtitle => 'बड़े डिलीट/इम्पोर्ट के बाद खाली स्थान वापस पाता है।';

  @override
  String get databaseCloudContent => 'क्लाउड सामग्री';

  @override
  String get databaseCloudContentSubtitle => 'व्यायाम, उपकरण और शरीररचना मीडिया स्टोरेज प्रबंधित करें।';

  @override
  String get databaseWifiOnly => 'केवल Wi-Fi डाउनलोड';

  @override
  String get databaseWifiOnlySubtitle => 'नए थंबनेल और वीडियो केवल Wi-Fi पर डाउनलोड होंगे। कैश किया मीडिया ऑफ़लाइन भी काम करता है।';

  @override
  String get databaseSyncExerciseMedia => 'रिमोट व्यायाम मीडिया सिंक करें';

  @override
  String get databaseSyncSharedMedia => 'साझा कैटलॉग मीडिया सिंक करें';

  @override
  String get databaseSyncSharedMediaSubtitle => 'उपकरण, शरीर-भाग और मांसपेशी चित्रण।';

  @override
  String get databaseClearMediaCache => 'डाउनलोड किया गया मीडिया कैश साफ़ करें';

  @override
  String get databaseClearMediaCacheSubtitle => 'इस डिवाइस से कैश की गई रिमोट मीडिया फ़ाइलें हटाता है।';

  @override
  String get databaseDefinitionExports => 'परिभाषा एक्सपोर्ट';

  @override
  String get databaseDefinitionExportsSubtitle => 'निरीक्षण या टूलिंग के लिए ऐप परिभाषा फ़ाइलें एक्सपोर्ट करें।';

  @override
  String get exerciseEditorTitle => 'व्यायाम संपादक';

  @override
  String get exerciseEditorLoadFailed => 'व्यायाम परिभाषाएँ लोड नहीं हो सकीं।';

  @override
  String get exerciseEditorChoose => 'व्यायाम चुनें';

  @override
  String get exerciseEditorEdit => 'परिभाषा संपादित करें';

  @override
  String get exerciseEditorCreate => 'कस्टम व्यायाम बनाएँ';

  @override
  String get exerciseEditorSaveChanges => 'बदलाव सहेजें';

  @override
  String get exerciseEditorSaving => 'सहेजा जा रहा है';

  @override
  String get exerciseEditorMuscles => 'मांसपेशियाँ';

  @override
  String get exerciseEditorBodyparts => 'शरीर भाग';

  @override
  String get exerciseEditorEquipment => 'उपकरण';

  @override
  String get exerciseEditorGuide => 'गाइड';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name पहले से दिखाया गया है।';
  }

  @override
  String get exerciseProgressTrendTitle => '1RM रुझान';

  @override
  String get exerciseProgressTrendBody => 'यह चार्ट समय के साथ वास्तविक रिकॉर्ड किए गए 1RM और अनुमानित 1RM की तुलना करता है। सटीक मान के लिए बिंदुओं पर टैप करें।';

  @override
  String get exerciseProgressRecordings => 'रिकॉर्डिंग्स';

  @override
  String get exerciseProgressRecordingsBody => 'हर रिकॉर्डिंग उस वर्कआउट को खोलती है जहाँ वह लिफ्ट हुई थी, ताकि आप पूरा संदर्भ देख सकें।';

  @override
  String get exerciseProgressTitle => '1RM प्रगति';

  @override
  String get exerciseProgressEmpty => 'प्रगति इतिहास बनाना शुरू करने के लिए यह व्यायाम पूरा करें।';

  @override
  String get exerciseProgressActual => 'वास्तविक 1RM';

  @override
  String get exerciseProgressEstimated => 'अनुमानित 1RM';

  @override
  String get exerciseProgressSessionOpenFailed => 'वर्कआउट सत्र खोला नहीं जा सका।';

  @override
  String get exerciseProgressSessionMissing => 'वर्कआउट सत्र नहीं मिला।';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'अनुमान $value';
  }

  @override
  String get exerciseProgressNoActual => 'कोई वास्तविक 1RM नहीं';

  @override
  String exerciseProgressActualValue(String value) {
    return 'वास्तविक $value';
  }

  @override
  String get musclePercentTitle => 'प्रति मांसपेशी % हिट';

  @override
  String musclePercentLoadFailed(String error) {
    return 'एंट्रियाँ लोड नहीं हो सकीं: $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'प्रतिशत अपडेट नहीं हो सका: $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'डिफ़ॉल्ट पर रीसेट नहीं हो सका: $error';
  }

  @override
  String musclePercentError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get musclePercentNoExercises => 'कोई व्यायाम परिभाषित नहीं है';

  @override
  String get musclePercentEmpty => 'कोई मांसपेशी प्रतिशत सेट नहीं है';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'डिफ़ॉल्ट पर वापस जाएँ';

  @override
  String get sevenDayFocusTitle => 'साप्ताहिक अवलोकन';

  @override
  String get sevenDayFocusLoadFailed => '7-दिन फोकस लोड नहीं हो सका';

  @override
  String get sevenDayFocusEmpty => 'पिछले 7 दिनों में कोई पूरा किया गया शरीर-भाग सेट यूनिट नहीं।';

  @override
  String get sevenDayFocusMore => 'और';

  @override
  String get pastSessionsWeek => 'सप्ताह';

  @override
  String get pastSessionsMonth => 'माह';

  @override
  String get pastSessionsYear => 'वर्ष';

  @override
  String get pastSessionsAll => 'सभी';

  @override
  String get pastSessionsShow => 'दिखाएँ:';

  @override
  String get pastSessionsFullscreen => 'पूर्ण स्क्रीन';

  @override
  String pastSessionsError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get pastSessionsEmpty => 'अभी कोई सत्र नहीं।';

  @override
  String pastSessionsItem(String date, int minutes) {
    return '$date - $minutes मिनट';
  }

  @override
  String get historySummaryLoadFailed => 'इतिहास लोड करने में त्रुटि';

  @override
  String get historySummaryWorkouts => 'वर्कआउट';

  @override
  String get historySummaryTotalTime => 'कुल समय';

  @override
  String get historySummaryTotalVolume => 'कुल वॉल्यूम';

  @override
  String get planCoachSkipGuide => 'गाइड छोड़ें';

  @override
  String get planCoachContinue => 'जारी रखें';

  @override
  String get trainOptimizedSettingsTitle => 'अनुकूलित वर्कआउट सेटिंग्स';

  @override
  String get trainOptimizedSettingsBudgetBody => 'प्रत्येक सेट के लिए 3 मिनट और हर व्यायाम शुरू करने के लिए 5 मिनट का बजट उपयोग किया गया।';

  @override
  String get trainOptimizedSettingsFocusBody => 'शरीर-भाग चयन केवल आपके शुरू किए अगले अनुकूलित वर्कआउट पर लागू होते हैं।';

  @override
  String get trainWorkoutDuration => 'वर्कआउट अवधि';

  @override
  String get trainMinutesShort => 'मिनट';

  @override
  String get trainSetsPerExercise => 'प्रति व्यायाम अधिकतम सेट';

  @override
  String get trainSetsShort => 'सेट';

  @override
  String get trainBodypartFocus => 'शरीर-भाग फ़ोकस';

  @override
  String get trainBodypartFocusHelp => 'किसी शरीर-भाग को प्राथमिकता देने के लिए एक बार टैप करें, बचने के लिए दोबारा टैप करें और साफ़ करने के लिए तीसरी बार टैप करें।';

  @override
  String get trainBodypartsLoadFailed => 'शरीर-भाग लोड नहीं किए जा सके।';

  @override
  String get trainPlanGenerated => 'प्लान बनाया गया। इसे अभी खोला जा रहा है।';

  @override
  String trainPlansGenerated(int count) {
    return '$count प्लान बनाए गए।';
  }

  @override
  String get trainActiveWorkoutKept => 'दूसरा वर्कआउट पहले से सक्रिय है, इसलिए उसे बिना बदलाव के रखा गया।';

  @override
  String get trainMenuTitle => 'प्रशिक्षण मेनू';

  @override
  String get trainExerciseCatalog => 'व्यायाम कैटलॉग';

  @override
  String get trainMuscleFilter => 'मांसपेशी फ़िल्टर';

  @override
  String get trainGymSettings => 'जिम और वर्कआउट सेटिंग्स';

  @override
  String get trainTab => 'प्रशिक्षण';

  @override
  String get trainHistoryTab => 'इतिहास';

  @override
  String get trainExercisePresets => 'व्यायाम प्रीसेट';

  @override
  String get trainGeneratePlans => 'कस्टम प्लान बनाएँ';

  @override
  String get trainAddPlan => 'मैन्युअली प्रीसेट जोड़ें';

  @override
  String get trainNewPlanFirst => 'नया प्रीसेट';

  @override
  String trainNewPlan(int number) {
    return 'नया प्रीसेट $number';
  }

  @override
  String get trainBuildingOptimized => 'अनुकूलित वर्कआउट बनाया जा रहा है...';

  @override
  String get trainStartOptimized => 'अनुकूलित वर्कआउट शुरू करें';

  @override
  String get trainNewSession => 'नया सेशन';

  @override
  String get foodCustomizationTitle => 'खाद्य अनुकूलित करें';

  @override
  String get foodCustomizationEditTitle => 'खाद्य संपादित करें';

  @override
  String get foodCustomizationName => 'खाद्य नाम';

  @override
  String get foodCustomizationEnterName => 'नाम दर्ज करें';

  @override
  String get foodCustomizationBrand => 'ब्रांड';

  @override
  String get foodCustomizationFoodPhoto => 'खाद्य फोटो';

  @override
  String get foodCustomizationLabelPhoto => 'लेबल फोटो';

  @override
  String get foodCustomizationDensity => 'घनत्व (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'mL-आधारित परोसने की मात्रा (कप, बड़ा चम्मच) को मैक्रो गणना के लिए ग्राम में बदलने हेतु उपयोग किया जाता है।';

  @override
  String get foodCustomizationCalories => 'कैलोरी (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'मैक्रोन्यूट्रिएंट्स';

  @override
  String get foodCustomizationMicronutrients => 'माइक्रोन्यूट्रिएंट्स';

  @override
  String get foodCustomizationAdditionalComponents => 'अतिरिक्त घटक';

  @override
  String get foodCustomizationPortionInfo => 'परोसने की जानकारी';

  @override
  String get foodCustomizationBasisPortion => 'पोषण मानों के लिए परोसने का आधार';

  @override
  String get foodCustomizationUsualPortion => 'उपयोगकर्ता द्वारा सामान्यतः खाई जाने वाली मात्रा';

  @override
  String get foodCustomizationAddPortion => 'परोसने की मात्रा जोड़ें';

  @override
  String get foodCustomizationUnit => 'इकाई';

  @override
  String get foodCustomizationAmount => 'मात्रा';

  @override
  String get foodCustomizationWeight => 'वजन (g)';

  @override
  String get foodCustomizationVolume => 'आयतन (mL)';

  @override
  String get dashboardArchivedPlans => 'संग्रहीत प्लान';

  @override
  String get dashboardActivePlans => 'सक्रिय प्लान';

  @override
  String get dashboardManagePlans => 'प्लान प्रबंधित करें';

  @override
  String get dashboardSelectProfilePlans => 'इसके प्लान देखने के लिए जिम प्रोफ़ाइल चुनें।';

  @override
  String get dashboardNoArchivedPlans => 'इस प्रोफ़ाइल के लिए कोई संग्रहीत प्लान नहीं है।';

  @override
  String get dashboardNoActivePlans => 'अभी कोई सक्रिय प्लान नहीं है। प्लान चुनने के लिए पेन का उपयोग करें।';

  @override
  String dashboardPremadeCount(int count) {
    return 'जोड़ने के लिए $count तैयार रूटीन उपलब्ध हैं।';
  }

  @override
  String get dashboardBrowsePremadePlans => 'तैयार प्लान देखें';

  @override
  String get dashboardNewPlanFirst => 'नया प्लान';

  @override
  String dashboardNewPlan(int number) {
    return 'नया प्लान $number';
  }

  @override
  String get dashboardPlanTools => 'प्लान उपकरण';

  @override
  String get dashboardPlanToolsBody => 'अपनी प्रशिक्षण प्राथमिकताओं से प्लान बनाएँ या खाली प्लान शुरू करें।';

  @override
  String get dashboardManual => 'मैन्युअल';

  @override
  String get dashboardGenerate => 'बनाएँ';

  @override
  String get dashboardMostUsedExercises => 'सबसे अधिक किए गए व्यायाम';

  @override
  String get dashboardMostUsedExercisesEmpty => 'अपने सबसे सामान्य व्यायाम यहाँ देखने के लिए वर्कआउट पूरे करें।';

  @override
  String premadeDiscardFailed(String error) {
    return 'जोड़ी गई योजनाएँ त्यागी नहीं जा सकीं: $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'उपलब्ध उपकरण के अनुसार योजनाएँ अनुकूलित करने के लिए जिम प्रोफ़ाइल चुनें।';

  @override
  String get premadeEquipmentExact => 'तैयार योजनाएँ ठीक वैसी ही दिखाई जाती हैं जैसी लिखी गई हैं।';

  @override
  String get premadeEquipmentChecking => 'आपकी प्रोफ़ाइल के अनुसार योजना व्यायामों की जाँच हो रही है...';

  @override
  String get premadeEquipmentMissing => 'कोई प्रोफ़ाइल उपकरण नहीं मिला, इसलिए तैयार योजनाएँ अपरिवर्तित हैं।';

  @override
  String premadeEquipmentReplacements(int count) {
    return 'योजनाएँ जोड़ने पर $count अनुपलब्ध व्यायाम बदले जाएँगे।';
  }

  @override
  String get premadeEquipmentFits => 'योजनाएँ पहले से वर्तमान प्रोफ़ाइल उपकरण में फिट हैं।';

  @override
  String get premadeOneHour => '1 घंटा';

  @override
  String get premadeTwoHours => '2 घंटे';

  @override
  String premadePlansAvailable(int count) {
    return '$count योजना(एँ) उपलब्ध';
  }

  @override
  String get premadeNoTemplates => 'अभी कोई योजना टेम्पलेट नहीं';

  @override
  String premadePlansCount(int count) {
    return '$count योजना(एँ)';
  }

  @override
  String get premadeTemplatesLater => 'इस स्प्लिट के टेम्पलेट बाद में यहाँ जोड़े जा सकते हैं।';

  @override
  String premadeExerciseCount(int count) {
    return '$count व्यायाम';
  }

  @override
  String premadeSetCount(int count) {
    return '$count सेट';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$count बदले गए';
  }

  @override
  String get premadeAdding => 'जोड़ा जा रहा है';

  @override
  String get premadeChecking => 'जाँचा जा रहा है';

  @override
  String get premadeProfileSwap => 'प्रोफ़ाइल स्वैप';

  @override
  String get healthEntryValueUnitRequired => 'पहले मान और इकाई दर्ज करें।';

  @override
  String get healthDefinitionFieldsRequired => 'नाम, इकाई और मान्य मान दर्ज करें।';

  @override
  String get healthUnit => 'इकाई';

  @override
  String get healthNote => 'नोट';

  @override
  String get healthOptional => 'वैकल्पिक';

  @override
  String get healthMetricName => 'मेट्रिक नाम';

  @override
  String get healthMetricNameHint => 'बांह का आकार, आराम की हृदय गति...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'इंच, $weightUnit, %, bpm...';
  }

  @override
  String get healthStartingValue => 'शुरुआती मान';

  @override
  String get healthCreate => 'बनाएँ';

  @override
  String get exerciseProgressNoRecordings => 'अभी कोई रिकॉर्डिंग नहीं';

  @override
  String get exerciseEditorDiscardTitle => 'बदलाव त्यागें?';

  @override
  String get exerciseEditorDiscardBody => 'आपके बदलाव अभी सहेजे नहीं गए हैं। आप संपादन जारी रख सकते हैं या उन्हें त्याग सकते हैं।';

  @override
  String get exerciseEditorKeepEditing => 'संपादन जारी रखें';

  @override
  String get exerciseEditorDiscard => 'त्यागें';

  @override
  String get exerciseEditorAddBodyparts => 'संबंधित शरीर भाग जोड़ें';

  @override
  String get exerciseEditorAddMuscles => 'संबंधित मांसपेशियाँ जोड़ें';

  @override
  String get exerciseEditorAddEquipment => 'उपकरण जोड़ें';

  @override
  String get databaseClearMediaTitle => 'डाउनलोड किया गया मीडिया साफ़ करें?';

  @override
  String get databaseClearMediaBody => 'यह कैश किया गया व्यायाम, उपकरण और शरीररचना मीडिया हटाता है। ज़रूरत होने पर ऐप इन्हें फिर डाउनलोड कर सकता है।';

  @override
  String get databaseClearCache => 'कैश साफ़ करें';

  @override
  String get databaseCacheCleared => 'डाउनलोड किया गया मीडिया कैश साफ़ किया गया।';

  @override
  String databaseClearCacheFailed(String error) {
    return 'कैश साफ़ नहीं किया जा सका: $error';
  }

  @override
  String get databaseContentEnvironment => 'सामग्री परिवेश';

  @override
  String get databaseLoadingEnvironment => 'परिवेश लोड हो रहा है...';

  @override
  String get databaseChangeEnvironment => 'परिवेश बदलें';

  @override
  String get databaseExerciseManifestUrl => 'व्यायाम मीडिया मैनिफ़ेस्ट URL';

  @override
  String get databaseNoExerciseManifestUrl => 'इस परिवेश के लिए कोई रिमोट मैनिफ़ेस्ट URL सेट नहीं है।';

  @override
  String get databaseOverrideUrl => 'URL बदलें';

  @override
  String get databaseNoManifestSynced => 'कोई मैनिफ़ेस्ट सिंक नहीं हुआ';

  @override
  String databaseManifestVersion(int version) {
    return 'मैनिफ़ेस्ट v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'अंतिम जाँच: $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'साझा कैटलॉग मीडिया';

  @override
  String get databaseSharedMediaNotSynced => 'अभी सिंक नहीं हुआ। उपकरण, शरीर-भाग और मांसपेशियाँ।';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'मैनिफ़ेस्ट v$version। अंतिम जाँच: $date';
  }

  @override
  String get databaseSharedManifestUrl => 'साझा मीडिया मैनिफ़ेस्ट URL';

  @override
  String get databaseNoSharedManifestUrl => 'इस परिवेश के लिए कोई रिमोट साझा मीडिया URL सेट नहीं है।';

  @override
  String get databaseDownloadedMediaCache => 'डाउनलोड किया गया मीडिया कैश';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count फ़ाइलें, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'बंडल मैनिफ़ेस्ट लोड करें';

  @override
  String get databaseTutorialFilesTitle => 'डेटाबेस फ़ाइलें';

  @override
  String get databaseTutorialFilesBody => 'बैकअप एक्सपोर्ट करें या सहेजी डेटाबेस फ़ाइल इम्पोर्ट करें। इम्पोर्ट से पहले बैकअप ज़रूरी है।';

  @override
  String get databaseTutorialHealthTitle => 'डेटाबेस स्वास्थ्य';

  @override
  String get databaseTutorialHealthBody => 'यह कार्ड स्कीमा संस्करण, डेटाबेस आकार, तालिका गिनती और खोज इंडेक्स स्वास्थ्य दिखाता है।';

  @override
  String get databaseTutorialMaintenanceTitle => 'रखरखाव उपकरण';

  @override
  String get databaseTutorialMaintenanceBody => 'ज़रूरत पर इंटीग्रिटी जाँच, अनुकूलन, WAL चेकपॉइंट या वैक्यूमिंग के लिए इन क्रियाओं का उपयोग करें।';

  @override
  String get databaseExportSavedTitle => 'डेटाबेस एक्सपोर्ट सहेजा गया';

  @override
  String get databaseExportSavedBody => 'डेटाबेस एक्सपोर्ट आपकी चुनी हुई जगह पर सहेजा गया।';

  @override
  String databaseImportBlocked(String message) {
    return 'इम्पोर्ट रोका गया: $message';
  }

  @override
  String get databaseImportBackupCanceled => 'इम्पोर्ट रद्द किया गया: बैकअप सहेजा नहीं गया।';

  @override
  String get databaseImportSucceededTitle => 'इम्पोर्ट सफल हुआ';

  @override
  String databaseImportSucceededBody(String name) {
    return '$name इम्पोर्ट किया गया। पहले पिछला स्थानीय डेटाबेस आपकी चुनी जगह पर बैकअप के रूप में सहेजा गया।';
  }

  @override
  String get databaseConfirmImportTitle => 'इम्पोर्ट की पुष्टि करें';

  @override
  String get databaseConfirmImportBody => 'यह स्थानीय डेटाबेस बदल देगा। पहले वर्तमान डेटाबेस की बैकअप फ़ाइल लिखी जाएगी।';

  @override
  String databaseImportFile(String name) {
    return 'फ़ाइल: $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'तालिकाएँ: $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'पंक्तियाँ: $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'एक्सपोर्ट स्कीमा: v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'फ़ॉर्मेट: पुराना टेबल मैप';

  @override
  String get databaseImportWarnings => 'चेतावनियाँ:';

  @override
  String get databaseBackupAndImport => 'बैकअप और इम्पोर्ट';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'डेटाबेस रखरखाव नहीं हुआ: $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'सेट क्रेडिट संपादित करने से पहले परिभाषा बदलाव सहेजें या रद्द करें।';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return '$type हटाएँ?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return 'इस व्यायाम परिभाषा से \"$name\" हटाएँ?';
  }

  @override
  String get exerciseEditorKeep => 'रखें';

  @override
  String get exerciseEditorMuscleOrderTitle => 'लक्षित मांसपेशी क्रम';

  @override
  String get exerciseEditorMuscleOrderBody => 'मांसपेशियों को इस अनुसार क्रम दें कि व्यायाम उन्हें कितनी मजबूती से लक्षित करता है। इससे Tonos शरीर रचना फोकस का अनुमान लगाता है और बेहतर सुझाव देता है।';

  @override
  String get exerciseEditorExactSetCredit => 'सटीक सेट क्रेडिट';

  @override
  String get exerciseEditorExactSetCreditBody => 'व्यायाम सेट आवंटन में बदलें कि एक सेट प्रत्येक मांसपेशी या शरीर भाग के लिए कितना सटीक क्रेडिट देता है।';

  @override
  String get exerciseEditorSetCreditScaling => 'सेट-क्रेडिट स्केलिंग';

  @override
  String get exerciseEditorSetCreditScalingBody => 'चुनें कि क्या इस व्यायाम की रेटिंग सेट क्रेडिट को स्केल करती है।';

  @override
  String get exerciseEditorScaleCreditByRating => 'रेटिंग से क्रेडिट स्केल करें';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'विश्लेषणात्मक सेट कुल में व्यायाम रेटिंग लागू करता है।';

  @override
  String get exerciseEditorTargetMuscles => 'लक्षित मांसपेशियाँ';

  @override
  String get exerciseEditorOrderMusclesHint => 'लक्ष्य जोर के अनुसार मांसपेशियों को क्रम देने के लिए तीरों का उपयोग करें।';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return 'वर्तमान में $count मांसपेशियाँ जुड़ी हैं।';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'अभी कोई लक्षित मांसपेशी संबद्ध नहीं है।';

  @override
  String get exerciseEditorAddTargetMuscles => 'लक्षित मांसपेशियाँ जोड़ें';

  @override
  String get exerciseEditorMoveUp => 'ऊपर ले जाएँ';

  @override
  String get exerciseEditorMoveDown => 'नीचे ले जाएँ';

  @override
  String get exerciseEditorRemoveMuscle => 'मांसपेशी हटाएँ';

  @override
  String get exerciseEditorMuscleItem => 'मांसपेशी';

  @override
  String get exerciseEditorAssociatedBodyparts => 'संबंधित शरीर भाग';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'ये व्यापक क्षेत्र शरीर हीटमैप, साप्ताहिक कवरेज और उपकरण-सचेत वर्कआउट सुझावों को संचालित करते हैं।';

  @override
  String get exerciseEditorExactBodypartCredit => 'सटीक शरीर-भाग क्रेडिट';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'जब किसी सेट को किसी शरीर भाग के लिए विशेष आंशिक मात्रा में गिना जाना चाहिए तो व्यायाम सेट आवंटन का उपयोग करें।';

  @override
  String get exerciseEditorBodypartsHint => 'इस व्यायाम द्वारा प्रशिक्षित हर व्यापक शरीर क्षेत्र जोड़ें।';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return 'वर्तमान में $count शरीर भाग जुड़े हैं।';
  }

  @override
  String get exerciseEditorNoBodyparts => 'अभी कोई शरीर भाग संबद्ध नहीं है।';

  @override
  String get exerciseEditorAutomaticPreview => 'स्वचालित पूर्वावलोकन';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'लक्षित मांसपेशी संरचना से प्राप्त वर्तमान फोकस।';

  @override
  String get exerciseEditorRemoveBodypart => 'शरीर भाग हटाएँ';

  @override
  String get exerciseEditorBodypartItem => 'शरीर भाग';

  @override
  String get exerciseEditorAvailableEquipment => 'उपलब्ध उपकरण';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'संबंधित उपकरण तय करता है कि कौन सी प्रोफ़ाइल यह व्यायाम उपयोग कर सकती है और Tonos कौन से विकल्प सुझा सकता है।';

  @override
  String get exerciseEditorEquipmentHint => 'इस व्यायाम को करने के लिए आवश्यक हर वस्तु जोड़ें।';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return 'वर्तमान में $count वस्तुएँ जुड़ी हैं।';
  }

  @override
  String get exerciseEditorNoEquipment => 'अभी कोई उपकरण संबद्ध नहीं है।';

  @override
  String get exerciseEditorRemoveEquipment => 'उपकरण हटाएँ';

  @override
  String get exerciseEditorEquipmentItem => 'उपकरण';

  @override
  String get historySummaryAll => 'सभी';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'पहले वैध व्यायाम मीडिया मैनिफ़ेस्ट URL जोड़ें।';

  @override
  String databaseContentSyncFailed(String error) {
    return 'सामग्री सिंक नहीं हुई: $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'बंडल सामग्री सिंक नहीं हुई: $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'इस सामग्री परिवेश में कोई साझा मीडिया URL नहीं है।';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'साझा सामग्री सिंक नहीं हुई: $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return '$filename एक्सपोर्ट नहीं हुआ: $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'व्यायाम मीडिया मैनिफ़ेस्ट';

  @override
  String get databaseManifestUrl => 'मैनिफ़ेस्ट URL';

  @override
  String get databaseClear => 'साफ़ करें';

  @override
  String get databaseNoManifestConfigured => 'अभी कोई मैनिफ़ेस्ट URL कॉन्फ़िगर नहीं है।';

  @override
  String get databaseUseEnvironment => 'परिवेश उपयोग करें';

  @override
  String get dashboardTargetAnatomy => 'लक्षित शरीररचना';

  @override
  String get dashboardBodyparts => 'शरीर-भाग';

  @override
  String get dashboardMuscles => 'मांसपेशियाँ';

  @override
  String get exerciseEditorCreateCustomTitle => 'कस्टम व्यायाम बनाएँ';

  @override
  String get exerciseEditorCreateCustomBody => 'कस्टम कैटलॉग परिभाषा बनाएँ, फिर सहेजने से पहले उसकी लक्षित शरीर रचना और मार्गदर्शन जोड़ें।';

  @override
  String get exerciseEditorExerciseName => 'व्यायाम नाम';

  @override
  String get exerciseEditorNoEquipmentChoice => 'कोई उपकरण नहीं';

  @override
  String get exerciseEditorOpenedMessage => 'व्यायाम खुल गया। इसकी लक्षित शरीर रचना जोड़ें, फिर सहेजें।';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'कस्टम व्यायाम नहीं बनाया जा सका। $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'यह क्या बदलता है';

  @override
  String get exerciseEditorWhatChangesBody => 'इस उन्नत संपादक का उपयोग व्यायाम नाम, लक्षित शरीर रचना, उपकरण, फॉर्म मार्गदर्शन, रेटिंग और संदर्भ मीडिया को अपडेट करने के लिए करें। सटीक प्रति-सेट क्रेडिट अलग से प्रबंधित है ताकि यह पूरे ऐप में सुसंगत रहे।';

  @override
  String get exerciseEditorChooseCatalog => 'कैटलॉग से एक व्यायाम चुनें';

  @override
  String get exerciseEditorRating => 'रेटिंग';

  @override
  String get databaseNever => 'कभी नहीं';

  @override
  String databaseExportDefinition(String filename) {
    return '$filename एक्सपोर्ट करें';
  }

  @override
  String get exerciseEditorAddMedia => 'मीडिया जोड़ें';

  @override
  String get exerciseEditorEditMedia => 'मीडिया संपादित करें';

  @override
  String get exerciseEditorMediaImage => 'छवि';

  @override
  String get exerciseEditorMediaVideo => 'वीडियो';

  @override
  String get exerciseEditorMediaLink => 'लिंक';

  @override
  String get exerciseEditorMediaType => 'प्रकार';

  @override
  String get exerciseEditorMediaTitle => 'शीर्षक';

  @override
  String get exerciseEditorMediaTitleHint => 'वैकल्पिक प्रदर्शन लेबल';

  @override
  String get exerciseEditorMediaRemoteUrl => 'रिमोट URL';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'थंबनेल URL';

  @override
  String get exerciseEditorMediaThumbnailHint => 'वैकल्पिक छवि पूर्वावलोकन URL';

  @override
  String get exerciseEditorSelectBeforeMedia => 'मीडिया जोड़ने से पहले कोई मौजूदा व्यायाम चुनें।';

  @override
  String get exerciseEditorFormGuide => 'फॉर्म गाइड';

  @override
  String get exerciseEditorFormGuideBody => 'ये नोट्स व्यायाम विवरण शीट में दिखते हैं ताकि लोग मूवमेंट को सुरक्षित रूप से सेट-अप, कर और समझ सकें।';

  @override
  String get exerciseEditorGuidance => 'मार्गदर्शन';

  @override
  String get exerciseEditorGuidanceEditing => 'स्पष्ट, व्यावहारिक संकेत लिखें। बदलाव सहेजने तक चरणबद्ध रहते हैं।';

  @override
  String get exerciseEditorGuidanceReadOnly => 'वर्तमान व्यायाम निर्देश और संकेत।';

  @override
  String get exerciseEditorSetUp => 'सेट-अप';

  @override
  String get exerciseEditorSetUpHint => 'शुरुआती स्थिति, उपकरण सेट-अप और सुरक्षा नोट्स।';

  @override
  String get exerciseEditorHowToPerform => 'कैसे करें';

  @override
  String get exerciseEditorHowToPerformHint => 'मुख्य मूवमेंट चरण और गति की सीमा।';

  @override
  String get exerciseEditorCoachingTips => 'कोचिंग सुझाव';

  @override
  String get exerciseEditorCoachingTipsHint => 'उपयोगी संकेत, सामान्य गलतियाँ और विविधताएँ।';

  @override
  String get exerciseEditorReferenceMedia => 'संदर्भ मीडिया';

  @override
  String get exerciseEditorReferenceMediaBody => 'निजी संदर्भ सामग्री के लिए मीडिया लिंक का उपयोग करें। प्रबंधित कैटलॉग मीडिया को कंटेंट सिंक पाइपलाइन द्वारा रीफ़्रेश किया जा सकता है।';

  @override
  String get exerciseEditorMediaLinks => 'मीडिया लिंक';

  @override
  String get exerciseEditorMediaLinksEditing => 'रिमोट छवि, वीडियो या संदर्भ लिंक जोड़ें या अपडेट करें।';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return 'वर्तमान में $count मीडिया आइटम लिंक हैं।';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'अभी कोई संदर्भ मीडिया लिंक नहीं है।';

  @override
  String get exerciseEditorAddMediaLink => 'मीडिया लिंक जोड़ें';

  @override
  String get exerciseEditorRemoveMedia => 'मीडिया हटाएँ';

  @override
  String get exerciseEditorMediaLinkItem => 'मीडिया लिंक';

  @override
  String exerciseEditorMediaReference(String type) {
    return '$type संदर्भ';
  }

  @override
  String get bengaliBangladeshLanguage => 'बांग्ला (बांग्लादेश)';

  @override
  String get simplifiedChineseLanguage => 'सरलीकृत चीनी';

  @override
  String get hindiLanguage => 'हिंदी';

  @override
  String get spanishLanguage => 'स्पेनिश';

  @override
  String get onboardingWeightHistoryTitle => 'वज़न का इतिहास';

  @override
  String get onboardingWeightHistorySubtitle => 'कुछ जानकारियाँ पोषण लक्ष्यों का अधिक समझदारी से अनुमान लगाने में मदद करती हैं।';

  @override
  String get onboardingPreviouslyHeavier => 'क्या आपका वज़न पहले वर्तमान वज़न से 10+ पाउंड अधिक रहा है?';

  @override
  String get onboardingWeightTrendTitle => 'वर्तमान वज़न की दिशा';

  @override
  String get onboardingWeightTrendGaining => 'वज़न बढ़ रहा है';

  @override
  String get onboardingWeightTrendLosing => 'वज़न घट रहा है';

  @override
  String get onboardingWeightTrendMaintaining => 'वज़न स्थिर है';

  @override
  String get onboardingNotSure => 'पक्का नहीं';

  @override
  String get onboardingBodyFatEstimateTitle => 'शारीरिक वसा का अनुमान';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'सबसे करीब दिखने वाला अनुमान चुनें। बिल्कुल सटीक होना ज़रूरी नहीं है।';

  @override
  String get onboardingNutritionPreferencesTitle => 'पोषण प्राथमिकताएँ';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'सेटअप के बाद ये प्राथमिकताएँ पोषण सुझावों को आकार देती हैं।';

  @override
  String get onboardingPreferredDiet => 'पसंदीदा आहार';

  @override
  String get onboardingDietBalanced => 'संतुलित';

  @override
  String get onboardingDietLowFat => 'कम वसा';

  @override
  String get onboardingDietLowCarb => 'कम कार्ब';

  @override
  String get onboardingDietKeto => 'कीटो';

  @override
  String get onboardingCalorieFloor => 'न्यूनतम कैलोरी';

  @override
  String get onboardingCalorieFloorHint => 'न्यूनतम दैनिक किलो कैलोरी';

  @override
  String get onboardingTrainingDuringProgram => 'कार्यक्रम के दौरान प्रशिक्षण';

  @override
  String get onboardingTrainingNone => 'कोई नहीं';

  @override
  String get onboardingTrainingLifting => 'भार प्रशिक्षण';

  @override
  String get onboardingTrainingCardio => 'कार्डियो';

  @override
  String get onboardingTrainingLiftingAndCardio => 'भार प्रशिक्षण और कार्डियो';

  @override
  String get onboardingProteinPreference => 'पसंदीदा प्रोटीन सेवन';

  @override
  String get onboardingProteinLow => 'कम';

  @override
  String get onboardingProteinModerate => 'मध्यम';

  @override
  String get onboardingProteinHigh => 'अधिक';

  @override
  String get onboardingProteinVeryHigh => 'बहुत अधिक';

  @override
  String get onboardingGoalPaceTitle => 'लक्ष्य की गति';

  @override
  String get onboardingGoalPaceSubtitle => 'लक्षित वज़न और साप्ताहिक लक्ष्य दर देखें।';

  @override
  String get onboardingInitialDailyBudget => 'प्रारंभिक दैनिक बजट';

  @override
  String get onboardingProjectedEndDate => 'अनुमानित समाप्ति तिथि';

  @override
  String get onboardingTargetWeight => 'लक्षित वज़न';

  @override
  String get onboardingTargetGoalRate => 'लक्षित दर';

  @override
  String get onboardingPerWeek => 'प्रति सप्ताह';

  @override
  String get onboardingPerMonth => 'प्रति माह';

  @override
  String get exerciseProgressTrackExercise => 'किसी व्यायाम को ट्रैक करें';

  @override
  String get exerciseProgressTrackExerciseBody => 'यहाँ उसकी 1RM प्रवृत्ति देखने के लिए कोई व्यायाम चुनें।';

  @override
  String get healthCustomMetric => 'कस्टम माप';

  @override
  String get healthLatest => 'नवीनतम';

  @override
  String get healthNoEntry => 'कोई प्रविष्टि नहीं';

  @override
  String get healthNotTrackedYet => 'अभी ट्रैक नहीं किया गया';

  @override
  String get healthChange => 'बदलाव';

  @override
  String get healthNeedTwoEntries => '2 प्रविष्टियाँ चाहिए';

  @override
  String get healthVersusPrevious => 'पिछली से तुलना';

  @override
  String get healthRecords => 'रिकॉर्ड';

  @override
  String get presetEstimatedTime => 'अनुमानित समय';

  @override
  String get presetNoFocusData => 'अभी कोई फोकस डेटा नहीं है।';

  @override
  String get presetFocusPreviewHelp => 'प्लान का फोकस देखने के लिए शरीर के भाग की जानकारी वाले भार व्यायाम जोड़ें।';

  @override
  String get dashboardReorderHelp => 'सेक्शन को अपने लिए सबसे उपयुक्त क्रम में खींचें।';

  @override
  String get exerciseEditorCachedLocally => 'स्थानीय रूप से कैश किया गया';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return '$count व्यायाम मीडिया प्रविष्टियाँ सिंक हुईं (v$version)।';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'अंतर्निहित व्यायाम मीडिया मैनिफेस्ट लोड हुआ (v$version)।';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return '$count उपकरण और शरीर-रचना मीडिया प्रविष्टियाँ सिंक हुईं (v$version)।';
  }

  @override
  String get databaseHealthSchema => 'स्कीमा';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / लक्ष्य v$target';
  }

  @override
  String get databaseHealthSize => 'आकार';

  @override
  String get databaseHealthJournal => 'जर्नल';

  @override
  String get databaseHealthTables => 'टेबल';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables टेबल, $indexes इंडेक्स, $triggers ट्रिगर';
  }

  @override
  String get databaseHealthFoodSearch => 'भोजन खोज';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods भोजन, $rows FTS पंक्तियाँ';
  }

  @override
  String get databaseHealthPath => 'पथ';

  @override
  String get dashboardWorkoutInProgress => 'वर्कआउट जारी है';

  @override
  String get dashboardNoSavedPlans => 'इस जिम प्रोफ़ाइल के लिए कोई प्लान सहेजा नहीं गया है।';

  @override
  String get exerciseProgressOneRepMax => '1 रेप अधिकतम';

  @override
  String get exerciseProgressEstimatedOneRepMax => 'अनुमानित 1RM';

  @override
  String get onboardingPageWeight => 'वज़न';

  @override
  String get onboardingPageBodyFat => 'शारीरिक वसा';

  @override
  String get onboardingPageNutrition => 'पोषण';

  @override
  String get onboardingPageGoal => 'लक्ष्य';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return 'इस सप्ताह $count/$total';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return 'कुल $count';
  }

  @override
  String get dashboardVisualBodyFat => 'दृश्य शारीरिक वसा';

  @override
  String get dashboardNewMetric => 'नया माप';

  @override
  String get dashboardCurrentMetrics => 'वर्तमान माप';

  @override
  String get workoutReportDay => 'दिन';

  @override
  String get workoutReportDays => 'दिन';

  @override
  String get workoutReportWeek => 'सप्ताह';

  @override
  String get workoutReportMonth => 'महीना';

  @override
  String workoutReportAveragePer(String period) {
    return 'औसत / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'वर्कआउट';

  @override
  String get workoutReportLongestStreak => 'सबसे लंबी निरंतरता';

  @override
  String get workoutReportMostActive => 'सबसे सक्रिय';

  @override
  String get workoutReportNoSessions => 'कोई सत्र नहीं';

  @override
  String get workoutReportWeekday => 'सप्ताह का दिन';

  @override
  String workoutReportMetricSemantics(String label) {
    return '$label रिपोर्ट माप';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit दर्ज';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$date को $unit';
  }

  @override
  String get profileDiagnosticsTitle => 'डायग्नोस्टिक्स और गोपनीयता';

  @override
  String get profileDiagnosticsSubtitle => 'वर्ज़न, क्रैश रिपोर्ट सहमति, सिंक इतिहास और डेटा हटाना।';

  @override
  String get diagnosticsTitle => 'डायग्नोस्टिक्स और गोपनीयता';

  @override
  String get diagnosticsSubtitle => 'रिलीज़ डायग्नोस्टिक्स को समझें और नियंत्रित करें।';

  @override
  String get diagnosticsAppSection => 'ऐप की जानकारी';

  @override
  String get diagnosticsAppSectionSubtitle => 'समस्या बताते समय उपयोगी।';

  @override
  String get diagnosticsVersion => 'वर्ज़न और बिल्ड';

  @override
  String get diagnosticsLoading => 'लोड हो रहा है...';

  @override
  String get diagnosticsUnavailable => 'उपलब्ध नहीं';

  @override
  String get diagnosticsCrashSection => 'अनाम डायग्नोस्टिक्स';

  @override
  String get diagnosticsCrashSectionSubtitle => 'ऐप विफलताओं और मीडिया सिंक के लिए वैकल्पिक, श्रेणीबद्ध रिपोर्ट।';

  @override
  String get diagnosticsCrashReporting => 'अनाम डायग्नोस्टिक्स साझा करें';

  @override
  String get diagnosticsCrashUnavailable => 'इस बिल्ड में कॉन्फ़िगर नहीं है। कोई अनाम डायग्नोस्टिक्स साझा नहीं किया जा सकता।';

  @override
  String get diagnosticsCrashEnabledBody => 'आपकी सहमति से चालू है। इसे बंद करने पर Tonos में रखी रिपोर्ट हटाने का अनुरोध किया जाता है।';

  @override
  String get diagnosticsCrashDisabledBody => 'डिफ़ॉल्ट रूप से बंद। रिलीज़ की समस्या जाँचने में मदद करना चाहें तभी चालू करें।';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'डिज़ाइन से गोपनीयता';

  @override
  String get diagnosticsPrivacyPromiseBody => 'रिपोर्ट में केवल ऐप वर्ज़न, बिल्ड नंबर, प्लेटफ़ॉर्म, स्वीकृत श्रेणी, परिणाम और मोटे दायरे होते हैं। इनमें त्रुटि संदेश, स्टैक ट्रेस, नाम, स्वास्थ्य डेटा, डेटाबेस सामग्री, स्क्रीनशॉट, नेटवर्क पते, ट्रेस या एनालिटिक्स कभी नहीं होते।';

  @override
  String get diagnosticsSyncSection => 'कॉन्टेंट सिंक इतिहास';

  @override
  String get diagnosticsSyncSectionSubtitle => 'पिछले 30 मीडिया-मैनिफ़ेस्ट परिणाम केवल इस डिवाइस पर रखे जाते हैं।';

  @override
  String get diagnosticsNoSyncEvents => 'अभी कोई सिंक डायग्नोस्टिक नहीं';

  @override
  String get diagnosticsNoSyncEventsBody => 'बिना URL या निजी डेटा के सिंक परिणाम यहाँ दिखाई देंगे।';

  @override
  String get diagnosticsClearHistory => 'सिंक इतिहास साफ़ करें';

  @override
  String get diagnosticsClearHistoryBody => 'स्थानीय रूप से रखी सभी सिंक डायग्नोस्टिक प्रविष्टियाँ हटाएँ।';

  @override
  String get diagnosticsHistoryCleared => 'सिंक डायग्नोस्टिक इतिहास साफ़ हो गया।';

  @override
  String get diagnosticsExerciseMedia => 'व्यायाम मीडिया';

  @override
  String get diagnosticsSharedMedia => 'साझा मीडिया';

  @override
  String get diagnosticsRemoteSource => 'रिमोट';

  @override
  String get diagnosticsBundledSource => 'बंडल किया हुआ';

  @override
  String get diagnosticsSyncSucceeded => 'सफल';

  @override
  String get diagnosticsSyncFailed => 'विफल';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation: $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration मि.से. • मैनिफ़ेस्ट $version • $items आइटम';
  }

  @override
  String get diagnosticsPrivacySection => 'आपका डेटा';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'स्थानीय स्टोरेज, प्रतिधारण और हटाना।';

  @override
  String get diagnosticsLocalDataTitle => 'फ़िटनेस डेटा स्थानीय रहता है';

  @override
  String get diagnosticsLocalDataBody => 'जब तक आप स्वयं बैकअप एक्सपोर्ट नहीं करते, वर्कआउट, पोषण, शारीरिक माप और प्रोफ़ाइल रिकॉर्ड इसी डिवाइस के ऐप डेटाबेस में रहते हैं।';

  @override
  String get diagnosticsDeletionTitle => 'डायग्नोस्टिक और ऐप डेटा हटाएँ';

  @override
  String get diagnosticsDeletionBody => 'ऊपर का सिंक इतिहास साफ़ करें और इस इंस्टॉलेशन से साझा रिपोर्ट हटाने का अनुरोध करने के लिए अनाम डायग्नोस्टिक्स बंद करें। स्थानीय डेटाबेस और कैश हटाने के लिए डिवाइस सेटिंग में Tonos स्टोरेज साफ़ करें या ऐप अनइंस्टॉल करें।';

  @override
  String get diagnosticsSendTestReport => 'नियंत्रित डायग्नोस्टिक इवेंट भेजें';

  @override
  String get diagnosticsSendTestReportBody => 'केवल स्पष्ट रूप से परीक्षण-सक्षम बिल्ड में उपलब्ध। एक निश्चित स्वीकृत इवेंट भेजता है।';

  @override
  String get diagnosticsTestReportSent => 'नियंत्रित डायग्नोस्टिक इवेंट भेज दिया गया।';

  @override
  String get diagnosticsTestReportFailed => 'डायग्नोस्टिक इवेंट नहीं भेजा जा सका। बिल्ड कॉन्फ़िगरेशन और कनेक्शन जाँचें।';

  @override
  String get diagnosticsDeleteShared => 'साझा डायग्नोस्टिक्स हटाएँ';

  @override
  String get diagnosticsDeleteSharedBody => 'उन रिपोर्टों को हटाने का अनुरोध करता है जिन्हें यह इंस्टॉलेशन भेजना सिद्ध कर सकता है। प्रदाता के पुनर्प्राप्ति इतिहास में हटाई गई पंक्तियाँ 30 दिनों तक रह सकती हैं।';

  @override
  String get diagnosticsSharedDeleted => 'साझा डायग्नोस्टिक्स हटाने का अनुरोध किया गया।';

  @override
  String get diagnosticsSharedDeletionPending => 'कुछ हटाने के अनुरोध कनेक्शन के साथ ऐप खुलने पर फिर से आज़माए जाएंगे।';

  @override
  String get workoutDurabilityRestoreWarning => 'Tonos सहेजे गए वर्कआउट की जाँच नहीं कर सका। नया वर्कआउट शुरू करने से पहले पुनः प्रयास करें।';

  @override
  String get workoutDurabilityDraftSaveWarning => 'आपके वर्कआउट का बैकअप अद्यतित नहीं है। Tonos खुला रखें और पुनः प्रयास करें ताकि यह वर्कआउट सुरक्षित रूप से फिर से शुरू हो सके।';

  @override
  String get workoutDurabilityProgressionWarning => 'आपका वर्कआउट सहेजा गया है, लेकिन प्लान की प्रगति अभी लंबित है। स्टोरेज उपलब्ध होने पर पुनः प्रयास करें।';
}
