// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '每周体重的 $percent%';
  }

  @override
  String get dashboardExerciseFallback => '动作';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    return '$equipment - $count 次';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '已完成 $completed/$total';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return '$bodyPart 身体热图';
  }

  @override
  String get focusedSetsTitle => '重点组';

  @override
  String get bodyPartNeck => '颈部';

  @override
  String get bodyPartShoulders => '肩部';

  @override
  String get bodyPartChest => '胸部';

  @override
  String get bodyPartCore => '核心';

  @override
  String get bodyPartUpperBack => '上背部';

  @override
  String get bodyPartLowerBack => '下背部';

  @override
  String get bodyPartBiceps => '肱二头肌';

  @override
  String get bodyPartTriceps => '肱三头肌';

  @override
  String get bodyPartForearms => '前臂';

  @override
  String get bodyPartHips => '髋部';

  @override
  String get bodyPartHamstrings => '腘绳肌';

  @override
  String get bodyPartQuads => '股四头肌';

  @override
  String get bodyPartCalves => '小腿';

  @override
  String databaseSaveFile(String filename) {
    return '保存 $filename';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename 已保存到您选择的位置。';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label（生产）';
  }

  @override
  String dashboardDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1周';

  @override
  String get workoutReportRangeOneMonthShort => '1月';

  @override
  String get workoutReportRangeThreeMonthsShort => '3月';

  @override
  String get workoutReportRangeSixMonthsShort => '6月';

  @override
  String get workoutReportRangeOneYearShort => '1年';

  @override
  String get workoutReportRangeAll => '全部';

  @override
  String get workoutReportRangeOneWeek => '1周';

  @override
  String get workoutReportRangeOneMonth => '1个月';

  @override
  String get workoutReportRangeThreeMonths => '3个月';

  @override
  String get workoutReportRangeSixMonths => '6个月';

  @override
  String get workoutReportRangeOneYear => '1年';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric（$period）';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    return '$count 次训练';
  }

  @override
  String workoutReportMinutesCount(int count) {
    return '$count 分钟';
  }

  @override
  String workoutReportHoursCount(int count) {
    return '$count 小时';
  }

  @override
  String workoutReportHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get workoutReportMinuteShort => '分钟';

  @override
  String get workoutReportHourShort => '小时';

  @override
  String get workoutReportNoWorkoutsYet => '暂无训练';

  @override
  String get workoutReportNoTrainingTimeYet => '暂无训练时长';

  @override
  String get workoutReportNoVolumeYet => '暂无训练容量记录';

  @override
  String get workoutReportNoWorkoutsBody => '完成一次训练即可开始生成此报告。';

  @override
  String get workoutReportNoTrainingTimeBody => '已完成训练的分钟数会自动添加到这里。';

  @override
  String get workoutReportNoVolumeBody => '记录已完成组的重量，以生成训练容量趋势。';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => '界面与外观';

  @override
  String get uiAppearanceSubtitle => '控制 Tonos 的外观以及底部标签栏的行为。';

  @override
  String get displaySettingsTitle => '显示';

  @override
  String get displaySettingsSubtitle => '快速视觉偏好设置。';

  @override
  String get darkModeTitle => '深色模式';

  @override
  String get darkModeSubtitle => '使用深色应用主题。';

  @override
  String get replayOnboardingTitle => '重新播放引导';

  @override
  String get replayOnboardingSubtitle => '开启后可再次进入设置流程。完成后会自动关闭。';

  @override
  String get weightUnitsTitle => '重量单位';

  @override
  String weightUnitsSubtitle(String unit) {
    return '以 $unit 显示训练重量和训练量。';
  }

  @override
  String get languageTitle => '语言';

  @override
  String get languageSubtitle => '选择 Tonos 使用的语言。';

  @override
  String get systemDefaultLanguage => '系统默认';

  @override
  String get englishLanguage => 'English';

  @override
  String get canadianFrenchLanguage => 'Français (Canada)';

  @override
  String get navigationSettingsTitle => '导航';

  @override
  String get navigationSettingsSubtitle => '选择显示哪些底部标签及其顺序。';

  @override
  String get editBottomTabsTitle => '编辑底部标签';

  @override
  String get editBottomTabsSubtitle => '重新排序已启用的标签，或隐藏不使用的标签。';

  @override
  String get displaySettingsTutorialTitle => '显示设置';

  @override
  String get displaySettingsTutorialBody => '控制深色模式、语言、重新播放引导，以及磅和千克之间的切换。';

  @override
  String get bottomTabsTutorialTitle => '底部标签';

  @override
  String get bottomTabsTutorialBody => '编辑显示哪些底部标签以及它们的显示顺序。';

  @override
  String get onboardingPageWelcome => '欢迎';

  @override
  String get onboardingPageBasics => '基本信息';

  @override
  String get onboardingPageFocus => '重点';

  @override
  String get onboardingPageGymProfile => '健身房资料';

  @override
  String get onboardingPageEquipment => '器械';

  @override
  String get onboardingPageWorkoutPlan => '训练计划';

  @override
  String get onboardingPagePlanOverview => '计划概览';

  @override
  String get onboardingPageSummary => '摘要';

  @override
  String get onboardingPreviousStepTooltip => '上一步';

  @override
  String onboardingStepProgress(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get onboardingFinish => '完成';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingFinishing => '正在完成...';

  @override
  String get onboardingFinishSetup => '完成设置';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkipSetupTitle => '跳过设置？';

  @override
  String get onboardingSkipSetupBody => '您现在可以直接进入应用主页，之后再完成设置。也可以从设置页面重新打开引导。';

  @override
  String get onboardingCancel => '取消';

  @override
  String get onboardingConfirm => '确定';

  @override
  String onboardingFinishError(String error) {
    return '无法完成设置：$error';
  }

  @override
  String get onboardingWelcomeTitle => '欢迎使用 Tonos';

  @override
  String get onboardingWelcomeSubtitle => '快速设置可帮助个性化训练、营养和进度追踪。';

  @override
  String get onboardingLanguageSelectionTitle => '选择您的语言';

  @override
  String get onboardingLanguageSelectionHelp => '设置会立即更新。之后可在设置中更改。';

  @override
  String get onboardingTrainFeatureTitle => '基于情境训练';

  @override
  String get onboardingTrainFeatureBody => '使用您的偏好和历史记录来调整训练建议。';

  @override
  String get onboardingNutritionFeatureTitle => '支持营养目标';

  @override
  String get onboardingNutritionFeatureBody => '设定您希望从应用获得的营养指导程度。';

  @override
  String get onboardingProgressFeatureTitle => '追踪进度';

  @override
  String get onboardingProgressFeatureBody => '让训练和营养数据随时间保持关联。';

  @override
  String get onboardingBasicsTitle => '告诉我们基本信息';

  @override
  String get onboardingBasicsSubtitle => '这些信息是可选的，但能帮助后续计算。';

  @override
  String get onboardingNameLabel => '姓名';

  @override
  String get onboardingNameHint => '输入您的姓名';

  @override
  String get onboardingGenderLabel => '性别';

  @override
  String get onboardingGenderMale => '男';

  @override
  String get onboardingGenderFemale => '女';

  @override
  String get onboardingGenderOther => '其他';

  @override
  String get onboardingGenderPreferNotToSay => '不愿透露';

  @override
  String get onboardingDateOfBirthLabel => '出生日期';

  @override
  String get onboardingSelectDate => '选择日期';

  @override
  String get onboardingHeightLabel => '身高';

  @override
  String get onboardingHeightHint => '例如 5\'10\" 或 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => '训练重量单位';

  @override
  String get onboardingCurrentWeightLabel => '当前体重';

  @override
  String get onboardingWeightHintPounds => '例如 160';

  @override
  String get onboardingWeightHintKilograms => '例如 72';

  @override
  String get onboardingPounds => '磅';

  @override
  String get onboardingKilograms => '千克';

  @override
  String get onboardingFocusTitle => 'Tonos 应该个性化哪些内容？';

  @override
  String get onboardingFocusSubtitle => '选择现在想设置的领域。之后可随时更改。';

  @override
  String get onboardingNutritionDataTitle => '营养数据';

  @override
  String get onboardingNutritionDataPausedBody => '营养设置正在重建，此部分暂时暂停。';

  @override
  String get onboardingLater => '以后';

  @override
  String get onboardingExerciseDataTitle => '训练数据';

  @override
  String get onboardingExerciseDataBody => '设置您的健身房资料和首批训练计划。';

  @override
  String get onboardingGymSpaceTitle => '您在哪里训练？';

  @override
  String get onboardingGymSpaceSubtitle => '选择一个起始训练地点。其器械将影响训练建议和生成的训练内容。';

  @override
  String get onboardingEquipmentLoadError => '无法加载器械。';

  @override
  String get onboardingTryAgain => '重试';

  @override
  String get onboardingGymCustomTitle => '自定义训练地点';

  @override
  String get onboardingGymCustomSubtitle => '通过选择每种可用器械来设计自己的资料。';

  @override
  String get onboardingGymCustomDefaultName => '自定义地点';

  @override
  String get onboardingGymSkipTitle => '跳过此步骤';

  @override
  String get onboardingGymSkipSubtitle => '保留通用资料，之后再选择器械。';

  @override
  String get onboardingGymGeneralName => '通用';

  @override
  String get onboardingGymCommercialTitle => '商业健身房';

  @override
  String get onboardingGymCommercialSubtitle => '先选择全部可用器械，再移除健身房没有的器械。';

  @override
  String get onboardingGymCommercialDefaultName => '商业健身房';

  @override
  String get onboardingGymHomeTitle => '家庭健身房';

  @override
  String get onboardingGymHomeSubtitle => '包含自由重量、弹力带、长凳和自重器械的实用家庭配置。';

  @override
  String get onboardingGymHomeDefaultName => '家庭健身房';

  @override
  String get onboardingGymCalisthenicsTitle => '街头健身';

  @override
  String get onboardingGymCalisthenicsSubtitle => '以自重为主的器械，包括单杠、吊环、弹力带和基本配件。';

  @override
  String get onboardingGymCalisthenicsDefaultName => '街头健身';

  @override
  String get onboardingGymPowerliftingTitle => '力量举';

  @override
  String get onboardingGymPowerliftingSubtitle => '包含杠铃、杠铃片、深蹲架和长凳的训练地点。';

  @override
  String get onboardingGymPowerliftingDefaultName => '力量举';

  @override
  String get onboardingGymFreeWeightsTitle => '自由重量';

  @override
  String get onboardingGymFreeWeightsSubtitle => '哑铃、壶铃、杠铃片、长凳和自重动作。';

  @override
  String get onboardingGymFreeWeightsDefaultName => '自由重量';

  @override
  String get onboardingReviewWorkoutSpaceTitle => '检查您的训练地点';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => '在 Tonos 创建资料前，重命名资料或调整其器械。';

  @override
  String get onboardingProfileNameLabel => '资料名称';

  @override
  String get onboardingIncludedEquipmentTitle => '包含的器械';

  @override
  String get onboardingIncludedEquipmentBody => '当此资料启用时，只会建议由这些器械支持的训练动作。';

  @override
  String get onboardingNoEquipmentSelected => '尚未选择器械。';

  @override
  String get onboardingReset => '重置';

  @override
  String get onboardingEditProfile => '编辑资料';

  @override
  String get onboardingEditWorkoutSpaceTitle => '编辑训练地点';

  @override
  String get onboardingSelectEquipmentError => '至少选择一种器械。';

  @override
  String get onboardingWorkoutPlanTitle => '设置训练计划';

  @override
  String get onboardingWorkoutPlanSubtitle => '选择 Tonos 应如何准备您的首批计划。之后可以随时添加、归档或编辑计划。';

  @override
  String get onboardingManualPlanTitle => '手动创建自己的计划';

  @override
  String get onboardingManualPlanSubtitle => '从空白计划开始，然后自行添加动作和组数。';

  @override
  String get onboardingPremadePlanTitle => '使用预制训练计划';

  @override
  String get onboardingPremadePlanSubtitle => '浏览内置的全身、上下肢、推拉腿和身体部位分化计划。';

  @override
  String get onboardingGeneratePlanTitle => '生成训练计划';

  @override
  String get onboardingGeneratePlanSubtitle => '回答几个设置问题，让 Tonos 为您的资料生成自定义计划。';

  @override
  String get onboardingSkipPlanTitle => '跳过此步骤';

  @override
  String get onboardingSkipPlanSubtitle => '开始时不添加计划。之后可以从训练页设置。';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 个计划添加到活跃计划。',
      one: '已将 $count 个计划添加到活跃计划。',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => '检查您的计划';

  @override
  String get onboardingReviewPlansSubtitle => '这些计划已添加到您的活跃计划。继续前，可打开任意计划查看或调整。';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '活跃计划中已有 $count 个计划可用。',
      one: '活跃计划中已有 $count 个计划可用。',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => '暂时无法加载计划概览。';

  @override
  String get onboardingNoAddedPlans => '未找到已添加的计划。请返回添加计划，或跳过此步骤。';

  @override
  String get onboardingReadyTitle => '准备开始';

  @override
  String get onboardingReadySubtitle => '检查您的设置，然后完成以进入 Tonos。';

  @override
  String get onboardingSummaryName => '姓名';

  @override
  String get onboardingSummaryGender => '性别';

  @override
  String get onboardingSummaryDateOfBirth => '出生日期';

  @override
  String get onboardingSummaryHeight => '身高';

  @override
  String get onboardingSummaryWeight => '体重';

  @override
  String get onboardingSummaryWorkoutUnits => '训练单位';

  @override
  String get onboardingSummaryIncluded => '已包含';

  @override
  String get onboardingSummaryGymProfile => '健身房资料';

  @override
  String get onboardingSummaryEquipment => '器械';

  @override
  String get onboardingSummaryWorkoutPlans => '训练计划';

  @override
  String get onboardingSummaryProfileSection => '资料';

  @override
  String get onboardingSummaryTrainingSection => '训练设置';

  @override
  String get onboardingSummaryNutritionSection => '营养偏好';

  @override
  String get onboardingSummaryDiet => '饮食';

  @override
  String get onboardingSummaryProteinPreference => '蛋白质偏好';

  @override
  String get onboardingIncludedNutrition => '营养设置';

  @override
  String get onboardingIncludedExercise => '训练设置';

  @override
  String get onboardingIncludedBasicOnly => '仅基本资料';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 项',
      one: '已选择 $count 项',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个计划',
      one: '已添加 $count 个计划',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => '已选择预制计划';

  @override
  String get onboardingPlanSummaryGenerated => '已选择生成计划';

  @override
  String get onboardingPlanSummarySkipped => '已跳过';

  @override
  String get onboardingPlanSummaryManual => '已选择手动创建';

  @override
  String get onboardingPlanSummaryNotSelected => '未选择';

  @override
  String get onboardingNewPlan => '新计划';

  @override
  String onboardingNumberedNewPlan(int number) {
    return '新计划 $number';
  }

  @override
  String get tabTrain => '训练';

  @override
  String get tabTrainSecondary => '训练 2';

  @override
  String get tabCatalog => '目录';

  @override
  String get tabLogbook => '日志';

  @override
  String get tabProgress => '进度';

  @override
  String get tabProfile => '资料';

  @override
  String get tabDashboard => '仪表盘';

  @override
  String get tabNutrition => '营养';

  @override
  String get tabNutritionLog => '营养日志';

  @override
  String get tabCombinedHistory => '综合历史';

  @override
  String get tabFormAndPosing => '体态与造型';

  @override
  String get profileTitle => '资料';

  @override
  String get profileSubtitle => '个性化 Tonos、管理训练默认设置，并维护数据健康。';

  @override
  String get profileAccountSectionTitle => '账户';

  @override
  String get profileAccountSectionSubtitle => '您的身份信息和应用外观。';

  @override
  String get profileUserInformationTitle => '用户信息';

  @override
  String get profileUserInformationSubtitle => '姓名、身体信息和活动资料。';

  @override
  String get profileUiAppearanceTitle => '界面与外观';

  @override
  String get profileUiAppearanceSubtitle => '主题、引导和底部标签设置。';

  @override
  String get profileGuidedTutorialsTitle => '引导教程';

  @override
  String get profileGuidedTutorialsSubtitle => '重新播放演练并重置引导帮助。';

  @override
  String get profileTrainingSectionTitle => '训练';

  @override
  String get profileTrainingSectionSubtitle => '训练默认设置和进度相关控制。';

  @override
  String get profileGymWorkoutSettingsTitle => '健身房与训练设置';

  @override
  String get profileGymWorkoutSettingsSubtitle => '训练生成、排序、流程和器械逻辑。';

  @override
  String get profileProgressSettingsTitle => '进度设置';

  @override
  String get profileProgressSettingsSubtitle => '身体测量和趋势追踪设置。';

  @override
  String get profileDataSectionTitle => '数据';

  @override
  String get profileDataSectionSubtitle => '数据库工具、导出、导入和维护。';

  @override
  String get profileDatabaseSettingsTitle => '数据库设置';

  @override
  String get profileDatabaseSettingsSubtitle => '导入、导出、健康检查和维护工具。';

  @override
  String get profileNutritionSectionTitle => '营养';

  @override
  String get profileNutritionSectionSubtitle => '营养设置正在重建，此部分暂时暂停。';

  @override
  String get profileDietNutritionSettingsTitle => '饮食与营养设置';

  @override
  String get profileDietNutritionSettingsSubtitle => '营养目标和偏好将于之后回归。';

  @override
  String get profileLater => '以后';

  @override
  String get profileAccountTutorialTitle => '账户设置';

  @override
  String get profileAccountTutorialBody => '您可以在这里更新个人信息、显示偏好、重量单位、引导、底部标签和引导教程。';

  @override
  String get profileTrainingTutorialTitle => '训练设置';

  @override
  String get profileTrainingTutorialBody => '控制健身房资料、生成规则、身体部位排序、进度设置和其他训练默认项。';

  @override
  String get profileDataTutorialTitle => '数据工具';

  @override
  String get profileDataTutorialBody => '数据库设置可用于导出、导入、检查和维护您的本地训练数据。';

  @override
  String catalogLoadError(String error) {
    return '无法加载目录：$error';
  }

  @override
  String get catalogNoData => '暂时没有可用目录数据。';

  @override
  String get catalogExerciseTitle => '训练动作目录';

  @override
  String get catalogMostUsedExercises => '最常使用的动作';

  @override
  String get catalogNoExerciseHistory => '完成训练后，您最常做的动作会显示在这里。';

  @override
  String get catalogTargetAnatomyTitle => '目标解剖部位';

  @override
  String get catalogBodyparts => '身体部位';

  @override
  String get catalogMuscles => '肌肉';

  @override
  String get catalogNoBodypartHistory => '尚无身体部位历史记录。';

  @override
  String get catalogNoMuscleHistory => '尚无肌肉历史记录。';

  @override
  String get catalogExerciseTutorialTitle => '训练动作目录';

  @override
  String get catalogExerciseTutorialBody => '您最常做的动作会首先显示在这里。点击卡片可打开完整目录、搜索动作并查看动作详情。';

  @override
  String get catalogAnatomyTutorialTitle => '目标解剖部位';

  @override
  String get catalogAnatomyTutorialBody => '这里汇总您训练最多的身体部位和肌肉。点击任一侧可打开解剖目录，查看针对性的动作列表。';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '使用 $count 次',
      one: '使用 $count 次',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 组',
      one: '$count 组',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => '请至少保留两个启用的标签。';

  @override
  String get navEditorSavedMessage => '底部标签已保存';

  @override
  String get navEditorTitle => '编辑底部标签';

  @override
  String get navEditorSubtitle => '选择在底栏显示的内容，并重新排序启用的标签。';

  @override
  String get navEditorSave => '保存标签';

  @override
  String get navEditorActiveTitle => '启用的标签';

  @override
  String get navEditorActiveSubtitle => '拖动以重新排序。资料页始终可用。';

  @override
  String get navEditorInactiveTitle => '未启用的标签';

  @override
  String get navEditorInactiveSubtitle => '想恢复时随时启用它们。';

  @override
  String get navEditorNoInactiveTabs => '没有未启用的标签。';

  @override
  String get navEditorAlwaysShown => '始终显示';

  @override
  String get navEditorVisible => '在底部导航中显示';

  @override
  String get navEditorHidden => '从底部导航中隐藏';

  @override
  String get trainTutorialSpacesTitle => '训练有两个空间';

  @override
  String get trainTutorialSpacesBody => '概览将随时可用的训练控制放在前面。计划页用于浏览、生成和管理已保存的计划。';

  @override
  String get trainTutorialWeeklyTitle => '每周概览';

  @override
  String get trainTutorialWeeklyBody => '这里显示您最近训练过的身体部位。点击重点训练组列表可打开完整的每周训练组明细。';

  @override
  String get trainTutorialActivePlansTitle => '活跃计划';

  @override
  String get trainTutorialActivePlansBody => '活跃计划是您想随时使用的训练例程。使用编辑图标选择哪些计划会保留在概览标签上。';

  @override
  String get trainTutorialStartTitle => '开始或优化';

  @override
  String get trainTutorialStartBody => '开始训练会创建空白训练。优化会根据您的历史、资料器械、重点和恢复规则创建训练。';

  @override
  String get trainTutorialProfilesTitle => '健身房资料';

  @override
  String get trainTutorialProfilesBody => '在不同地点训练时切换资料，使生成的训练和动作替换仅使用可用器械。';

  @override
  String get trainSelectProfileFirst => '请先选择一个健身房资料。';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已生成 $count 个计划。',
      one: '已生成 1 个计划。',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '新计划 $number',
      one: '新计划',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return '优化训练 $date $time';
  }

  @override
  String get trainRestTitle => '休息一下';

  @override
  String get trainRestBody => '您最近的训练已达到多个身体部位限制，优化训练会给恢复带来过多压力。';

  @override
  String get commonOkay => '确定';

  @override
  String get trainNoEligibleExercises => '未找到适合此资料的训练动作。';

  @override
  String get trainAnotherWorkoutActive => '另一个训练已处于活动状态，因此保持不变。';

  @override
  String trainOptimizedStartFailed(String error) {
    return '无法开始优化训练：$error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '优化训练已开始。仍有 $count 个动作需要手动填写重量。',
      one: '优化训练已开始。仍有 1 个动作需要手动填写重量。',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '优化训练已开始。$count 个新动作使用了起始重量。',
      one: '优化训练已开始。1 个新动作使用了起始重量。',
    );
    return '$_temp0';
  }

  @override
  String get trainGymProfilesTooltip => '健身房资料';

  @override
  String get trainOverviewTab => '概览';

  @override
  String get trainPlansTab => '计划';

  @override
  String get trainActivePlans => '活跃计划';

  @override
  String get trainEditActivePlans => '编辑活跃计划';

  @override
  String get trainSelectProfileForPlans => '选择一个健身房资料以选择活跃计划。';

  @override
  String get trainChooseActivePlans => '点击编辑图标选择此处显示哪些计划。';

  @override
  String get trainSelectedPlansMissing => '所选计划已不可用。点击编辑图标以更新。';

  @override
  String get trainArchivedPlans => '已归档计划';

  @override
  String get trainNoActivePlans => '尚无活跃计划。使用概览中活跃计划卡片上的编辑图标选择要随时显示的计划。';

  @override
  String get trainNoArchivedPlans => '没有已归档计划。';

  @override
  String get trainManagePlans => '管理计划';

  @override
  String get trainPremadePlans => '预制计划';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个精选例程可复制到您的计划中。',
      one: '有 1 个精选例程可复制到您的计划中。',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => '浏览预制计划';

  @override
  String get trainGenerateCustomPlans => '生成自定义计划';

  @override
  String get trainManuallyAddPlan => '手动添加计划';

  @override
  String get trainStartWorkout => '开始训练';

  @override
  String get trainOptimize => '优化';

  @override
  String get trainOptimizedSettings => '优化训练设置';

  @override
  String planManagementDefaultName(int id) {
    return '计划 $id';
  }

  @override
  String get planManagementActiveTutorialTitle => '活跃计划';

  @override
  String get planManagementActiveTutorialBody => '这些计划会保持显示在训练概览中。想隐藏某个计划但不删除时，请使用归档。';

  @override
  String get planManagementArchivedTutorialTitle => '已归档计划';

  @override
  String get planManagementArchivedTutorialBody => '归档计划仍会保存。想让计划重新出现在概览中时，可在此启用它。';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return '无法更新 $plan：$error';
  }

  @override
  String get planManagementTitle => '管理计划';

  @override
  String get planManagementLoadFailed => '无法加载计划';

  @override
  String get commonTryAgain => '再试一次';

  @override
  String get planManagementIntro => '选择哪些计划在训练概览中随时可用。归档计划仍会保存，且可随时启用。';

  @override
  String get planManagementActiveSubtitle => '显示在训练概览中。';

  @override
  String get planManagementNoActive => '尚无活跃计划。启用下方计划即可将其固定到概览。';

  @override
  String get planManagementArchive => '归档';

  @override
  String get planManagementArchivedSubtitle => '保存在概览外的计划。';

  @override
  String get planManagementNoArchived => '没有已归档计划。';

  @override
  String get planManagementActivate => '启用';

  @override
  String get planManagementAutomatic => '自动计划';

  @override
  String get planManagementVisible => '在概览中可见';

  @override
  String get planManagementHidden => '已从概览隐藏';

  @override
  String get presetsNoPlans => '未找到计划。';

  @override
  String get presetsNoProfile => '未选择资料。';

  @override
  String get presetsLoadError => '加载计划时出错';

  @override
  String presetsShowMore(int count) {
    return '再显示 $count 个';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return '再显示 $count 个（剩余 $remaining 个）';
  }

  @override
  String planDefaultName(int number) {
    return '计划 $number';
  }

  @override
  String get planArchive => '归档';

  @override
  String get planActivate => '启用';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRename => '重命名';

  @override
  String get planActivated => '计划已启用。';

  @override
  String get planArchived => '计划已归档。';

  @override
  String get planDeleteTitle => '删除预设';

  @override
  String get planDeleteConfirmation => '确定要删除此计划吗？';

  @override
  String get commonCancel => '取消';

  @override
  String get planRenameTitle => '重命名计划';

  @override
  String get planNameLabel => '计划名称';

  @override
  String get optimizedTutorialBudgetTitle => '训练预算';

  @override
  String get optimizedTutorialBudgetBody => '设置优化训练的时长，以及每个动作可获得的训练组数。';

  @override
  String get optimizedTutorialRepsTitle => '重复次数和重量';

  @override
  String get optimizedTutorialRepsBody => '这些选项控制训练组模式、目标重复次数，以及生成重量的保守程度。';

  @override
  String get optimizedTutorialFocusTitle => '身体部位重点';

  @override
  String get optimizedTutorialFocusBody => '为下一次优化训练优先或避免特定身体部位，而不会更改您已保存的排名。';

  @override
  String get commonReset => '重置';

  @override
  String get optimizedTutorialResetBody => '如果当前设置不合适，“重置”会将此页面恢复为 Tonos 默认值。';

  @override
  String get optimizedTutorialActionsTitle => '保存或开始';

  @override
  String get optimizedTutorialActionsBody => '“立即开始”会一次性使用当前屏幕上的数值。“保存”会为以后的优化训练保留这些设置。';

  @override
  String optimizedValidationError(int maxSets) {
    return '请输入有效的时长、目标重复次数，以及介于 1-$maxSets 之间的训练组范围。';
  }

  @override
  String get optimizedBudgetDescription => '用于为每组安排 3 分钟，并为每个动作开始时安排 5 分钟。';

  @override
  String get optimizedWorkoutDuration => '训练时长';

  @override
  String get unitMinutesShort => '分钟';

  @override
  String get optimizedMinimumSets => '每个动作的最少训练组数';

  @override
  String get optimizedMaximumSets => '每个动作的最多训练组数';

  @override
  String get unitSets => '组';

  @override
  String get optimizedRepsWeightsTitle => '重复次数和重量';

  @override
  String get optimizedRepsWeightsDescription => '可用时会使用基于历史记录的力量估算；“轻松”和“中等”比“困难”降低得更多。新动作会使用保守的起始估算。';

  @override
  String get optimizedRepPattern => '重复次数模式';

  @override
  String get repModeMixed => '混合';

  @override
  String get repModePyramid => '金字塔';

  @override
  String get repModeConsistent => '稳定';

  @override
  String get optimizedTargetReps => '目标重复次数';

  @override
  String get unitReps => '次';

  @override
  String get optimizedWeightIntensity => '重量强度';

  @override
  String get intensityEasy => '轻松';

  @override
  String get intensityMedium => '中等';

  @override
  String get intensityHard => '困难';

  @override
  String get optimizedBodypartFocusTitle => '身体部位重点';

  @override
  String get optimizedBodypartFocusDescription => '这些选择只适用于您下一次开始的优化训练。点按一次表示优先，两次表示避免，再次点按可清除。';

  @override
  String get optimizedBodypartsUnavailable => '无法加载身体部位。';

  @override
  String get commonStartNow => '立即开始';

  @override
  String get commonSave => '保存';

  @override
  String get generateTutorialIntroTitle => '制定计划';

  @override
  String get generateTutorialIntroBody => '此页面可使用您的健身房档案和训练偏好创建一个计划或均衡的每周计划组合。';

  @override
  String get generateWorkoutSetupTitle => '训练设置';

  @override
  String get generateTutorialSetupBody => '设置训练时长、要创建的计划数，以及每个动作允许的最大训练组数。';

  @override
  String get generateTrainingFocusTitle => '训练重点';

  @override
  String get generateTutorialFocusBody => '在此处优先或避免身体部位。仅当您希望考虑近期训练时，7 天历史开关才会影响生成。';

  @override
  String get generateRepsWeightsTitle => '重复次数和重量';

  @override
  String get generateTutorialRepsBody => '选择金字塔、混合或稳定训练组模式，以及目标重复次数和起始重量强度。';

  @override
  String get generateSetAllocationTitle => '训练组分配';

  @override
  String get generateTutorialAllocationBody => '选择训练组是均匀分布，还是偏向您的身体部位或肌肉排名。';

  @override
  String get generateTutorialGenerateTitle => '生成';

  @override
  String get generateTutorialGenerateBody => '一切合适后，生成计划或计划组合。新计划之后可以查看和编辑。';

  @override
  String get generateValidationError => '请输入有效的时长、计划数量、训练组限制和重复次数。';

  @override
  String get generateNoViablePlans => '以当前设置无法生成可行计划。';

  @override
  String generateFailed(String error) {
    return '生成计划失败：$error';
  }

  @override
  String generateDiscardFailed(String error) {
    return '无法放弃生成的计划：$error';
  }

  @override
  String get generateIntroTitle => '制定您的计划周';

  @override
  String get generateIntroBody => '使用您的档案、重点和限制来创建一个计划或均衡计划组合。';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个计划',
      one: '1 个计划',
    );
    return '$_temp0';
  }

  @override
  String generateDurationPill(String minutes) {
    return '$minutes 分钟';
  }

  @override
  String generateMaxSetsPill(String sets) {
    return '最多 $sets 组';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans 个计划，$minutes 分钟，最多 $sets 组';
  }

  @override
  String get generateSessionLength => '训练时长';

  @override
  String get generateSessionLengthHelp => '按每组 3 分钟加每个动作 5 分钟估算。';

  @override
  String get generatePlansToCreate => '要创建的计划数';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return '通常与每周训练天数相同。最多 $maxPlans 个。';
  }

  @override
  String get unitPlans => '计划';

  @override
  String get generateMaxSetsPerExercise => '每个动作最多训练组数';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return '允许 $minSets–$maxSets 组。';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred 个优先，$avoided 个避免，$history 7 天历史';
  }

  @override
  String get generateHistoryUsing => '正在使用';

  @override
  String get generateHistoryNotUsing => '未使用';

  @override
  String get generateUseRecentTraining => '使用近期训练';

  @override
  String get generateUseRecentTrainingBody => '偏向过去 7 天训练不足的区域。';

  @override
  String get generateBodypartFocusInstruction => '点按一次表示优先，两次表示避免，第三次可清除。';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode，$reps 次，$intensity 强度';
  }

  @override
  String get generateMixedBody => '3 组以上使用金字塔模式；较短训练则保持稳定。';

  @override
  String get generatePyramidBody => '峰值训练组使用生成的工作重量。';

  @override
  String get generateConsistentBody => '每个训练组使用相同的重复次数和建议重量。';

  @override
  String get generateTargetRepsHelp => '金字塔模式使用峰值重复次数；其他模式使用稳定重复次数。';

  @override
  String get generateEasyBody => '最保守的历史记录或起始建议。';

  @override
  String get generateMediumBody => '均衡的工作重量建议。';

  @override
  String get generateHardBody => '最重的建议，仍会经过取整并考虑训练强度。';

  @override
  String get generateRequirementBodyparts => '身体部位排名';

  @override
  String get generateRequirementMuscles => '肌肉排名';

  @override
  String get generateRequirementEven => '均衡覆盖';

  @override
  String get generateEvenCoverageTitle => '均衡覆盖身体部位';

  @override
  String get generateEvenCoverageBody => '将训练量广泛分布到可用的身体部位。';

  @override
  String get generateBodypartRankingsTitle => '使用身体部位排名';

  @override
  String get generateBodypartRankingsBody => '为排名较高的身体部位分配更多计划训练量。';

  @override
  String get generateRankBodyparts => '为身体部位排名';

  @override
  String get generateMuscleRankingsTitle => '使用肌肉排名';

  @override
  String get generateMuscleRankingsBody => '根据您排名的肌肉优先级分配训练量。';

  @override
  String get generateRankMuscles => '为肌肉排名';

  @override
  String get generateGenerating => '正在生成……';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '生成 $count 个计划',
      one: '生成计划',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return '已生成 $requested 个计划中的 $generated 个。当前设置限制了其余计划。';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已生成 $count 个计划。准备好后可查看。',
      one: '已添加生成的计划。准备好后可查看。',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '另有 $count 个';
  }

  @override
  String get generateStarterEstimatedBody => '已为新动作估算起始重量。第一次训练组后可按需要调整。';

  @override
  String get generateStarterUnavailableBody => '部分动作仍需要手动设置重量，因为没有可用的安全起始估算。';

  @override
  String get generateStarterDialogTitle => '已添加起始重量';

  @override
  String get generatePageTitle => '生成计划';

  @override
  String get generateDiscarding => '正在放弃……';

  @override
  String get generateReviewPlans => '查看计划';

  @override
  String get sessionTutorialCardsTitle => '动作卡片';

  @override
  String get sessionTutorialCardsBody => '每张卡片对应一个动作。打开卡片可编辑重量和次数，完成后勾选组数。';

  @override
  String get sessionTutorialAddTitle => '添加动作';

  @override
  String get sessionTutorialAddBody => '训练期间想从目录添加其他动作时，使用此按钮。';

  @override
  String get sessionTutorialFinishTitle => '完成训练';

  @override
  String get sessionTutorialFinishBody => '完成后结束会话，Tonos 才能保存训练并更新历史、分析和进度组件。';

  @override
  String get sessionTimerTitle => '训练计时器';

  @override
  String get sessionTitle => '训练会话';

  @override
  String get sessionNoExercises => '尚未添加动作。';

  @override
  String get sessionNeedCompletedSet => '完成至少一组后才能结束训练。';

  @override
  String sessionSaveFailed(String error) {
    return '无法保存训练。正在进行的训练仍然可用。$error';
  }

  @override
  String get sessionFinishWorkout => '完成训练';

  @override
  String get sessionResume => '继续';

  @override
  String get sessionExit => '退出';

  @override
  String get sessionCompletedSaved => '已完成的训练已保存到日志。';

  @override
  String get sessionCancelled => '训练已取消。';

  @override
  String sessionEndFailed(String error) {
    return '无法结束训练：$error';
  }

  @override
  String get sessionCancelQuestion => '取消训练？';

  @override
  String get sessionCancelBody => '这会移除正在进行的训练，而不会将其添加到历史记录。';

  @override
  String get sessionKeepWorkout => '保留训练';

  @override
  String get sessionCancelWorkout => '取消训练';

  @override
  String get sessionEndQuestion => '结束训练？';

  @override
  String get sessionCancelDelete => '取消并删除';

  @override
  String get sessionEndSave => '结束并保存训练';

  @override
  String get sessionRememberChoice => '记住选择';

  @override
  String get sessionRememberChoiceBody => '之后可在健身房与训练设置中更改。';

  @override
  String get sessionCompleteLoadError => '加载训练时出错';

  @override
  String get sessionCompleteTitle => '训练完成';

  @override
  String get sessionMetricExercises => '动作';

  @override
  String get sessionMetricSets => '组数';

  @override
  String get sessionMetricDuration => '时长';

  @override
  String get sessionMetricVolume => '训练量';

  @override
  String get commonDone => '完成';

  @override
  String get recordMonthly => '每月';

  @override
  String get recordAllTime => '全部时间';

  @override
  String get recordFirst => '首次记录';

  @override
  String recordRepBest(int reps) {
    return '$reps 次最佳';
  }

  @override
  String get recordVolumeBest => '最佳训练量';

  @override
  String sessionEstimatedMax(String weight) {
    return '估算 1RM=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String durationHoursCompact(int hours) {
    return '$hours 小时';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get planUnsavedChangesTitle => '未保存的更改';

  @override
  String get planDiscardChangesQuestion => '放弃更改？';

  @override
  String get planDiscard => '放弃';

  @override
  String get planTutorialEditTitle => '编辑计划';

  @override
  String get planTutorialEditBody => '使用此处重命名计划、调整动作顺序、添加动作、替换动作和更改训练组。';

  @override
  String get planTutorialSummaryTitle => '计划概览';

  @override
  String get planTutorialSummaryBody => '开始前，这里会显示预计时间、训练容量以及此计划的主要目标身体部位。';

  @override
  String get planTutorialExerciseCardsTitle => '动作卡';

  @override
  String get planTutorialExerciseCardsBody => '打开动作卡以查看计划训练组。在编辑模式下，可使用菜单替换或移除动作。';

  @override
  String get planTutorialStartOrSaveTitle => '开始或保存';

  @override
  String get planTutorialStartOrSaveBody => '“开始训练”会将此计划作为一次训练开始。在编辑模式下，它会变为“保存预设”，以保存您的更改。';

  @override
  String get planGuideNameTitle => '命名计划';

  @override
  String get planGuideNameBody => '给此计划取一个您容易辨认的名称，例如“上半身”或“第 1 天”。';

  @override
  String get commonContinue => '继续';

  @override
  String get planGuideBrowseTitle => '浏览动作';

  @override
  String get planGuideBrowseBody => '点按 + 按钮，为此计划选择第一个动作。';

  @override
  String get planGuideWeightTitle => '选择重量';

  @override
  String get planGuideWeightBody => '为第一组输入起始重量。自重动作请使用 0。';

  @override
  String get planGuideWeightSet => '重量已设置';

  @override
  String get planGuideRepsTitle => '选择重复次数';

  @override
  String get planGuideRepsBody => '输入您计划在此训练组完成的重复次数。';

  @override
  String get planGuideRepsSet => '重复次数已设置';

  @override
  String get planGuideAddSetTitle => '添加更多训练组';

  @override
  String get planGuideAddSetBody => '需要更多训练组时，使用“添加训练组”。新训练组会沿用上一组的数值。';

  @override
  String get planGuideSaveTitle => '保存计划';

  @override
  String get planGuideSaveBody => '点按“保存预设”以保留此计划并返回引导概览。';

  @override
  String planSaveFailed(String error) {
    return '无法保存计划。先前版本未更改。$error';
  }

  @override
  String get planOngoingWorkoutKept => '已保留您正在进行的训练。请先完成或取消它，再开始此计划。';

  @override
  String get planDeleteBody => '确定要删除此预设吗？';

  @override
  String get planDeletePreset => '删除预设';

  @override
  String get planDisableAutomatic => '关闭自动模式';

  @override
  String get planMakeAutomatic => '设为自动';

  @override
  String get planAutomaticSettings => '自动设置';

  @override
  String get planProgression => '计划进阶';

  @override
  String get planNoExercises => '此预设中没有动作。';

  @override
  String get planSavePreset => '保存预设';

  @override
  String get planStartSession => '开始训练';

  @override
  String get commonName => '名称';

  @override
  String get commonBack => '返回';

  @override
  String get flowMethodWeight => '重量';

  @override
  String get flowMethodReps => '重复次数';

  @override
  String get flowMethodAddSet => '添加训练组';

  @override
  String get flowMethodDeleteSet => '删除训练组';

  @override
  String get flowAppDefaultTitle => '应用默认进阶流程';

  @override
  String get flowProfileDefaultTitle => '健身房默认进阶流程';

  @override
  String get flowPlanSubtitle => '设置此计划在每次训练后如何进阶。';

  @override
  String get flowAppDefaultSubtitle => '设置新健身房档案的起始进阶流程。';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return '设置 $profileName 中新计划的起始进阶流程。';
  }

  @override
  String get flowThisGymProfile => '此健身房档案';

  @override
  String get flowManageMethods => '管理操作';

  @override
  String get flowAddNewMethod => '添加新操作';

  @override
  String get flowNewMethod => '新操作';

  @override
  String get flowFactor => '系数';

  @override
  String get flowAmount => '数值';

  @override
  String get flowExplicit => '明确指定';

  @override
  String get flowCopyFromSet => '从训练组复制';

  @override
  String get flowWeight => '重量';

  @override
  String get flowReps => '重复次数';

  @override
  String get flowSetIndex => '训练组索引（-1 = 最后一组）';

  @override
  String get flowDeleteLastSetBody => '此操作将删除最后一个训练组。';

  @override
  String get flowMethodNameRequired => '操作名称不能为空';

  @override
  String get flowManageActionsTooltip => '管理进阶操作';

  @override
  String get flowAddBranchTitle => '添加分支';

  @override
  String get flowAddBranchSubtitle => '选择下一次成功或未达成时应前往的位置。';

  @override
  String get flowBranchFrom => '从此处分支';

  @override
  String get flowSuccess => '成功';

  @override
  String get flowMiss => '未达成';

  @override
  String get flowAttachActionTitle => '附加进阶操作';

  @override
  String get flowAttachActionSubtitle => '对流程节点应用每种类型的一项调整。';

  @override
  String get flowApplyActionTo => '将操作应用于';

  @override
  String get flowProgressionAction => '进阶操作';

  @override
  String get flowAddAction => '+ 操作';

  @override
  String get flowRemoveAction => '- 操作';

  @override
  String get flowRemoveNode => '- 节点';

  @override
  String get commonEdit => '编辑';

  @override
  String get rulesEditAppDefault => '编辑应用默认规则';

  @override
  String get rulesEditProfileDefault => '编辑资料默认规则';

  @override
  String get rulesAddAppDefault => '添加应用默认规则';

  @override
  String get rulesAddProfileDefault => '添加资料默认规则';

  @override
  String get rulesCopy => '复制';

  @override
  String get rulesCopyIndex => '复制索引';

  @override
  String get rulesDeleteLastSetBody => '这会删除最后一组。';

  @override
  String get rulesNameRequired => '规则名称不能为空';

  @override
  String get rulesProfilesLowercase => '资料';

  @override
  String get rulesPlansLowercase => '计划';

  @override
  String rulesAddToExistingTitle(String destination) {
    return '添加到现有$destination？';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return '让“$name”在 $count 个现有$destination中可用吗？同名现有规则和所有已保存的进阶流程将保持不变。';
  }

  @override
  String get rulesNotNow => '暂不';

  @override
  String rulesAddTo(String destination) {
    return '添加到 $destination';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return '没有现有$destination需要此规则。';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return '已将“$name”添加到 $count 个$destination。';
  }

  @override
  String get rulesPropagationFailed => '无法将规则添加到现有项目。';

  @override
  String get rulesOptionsTooltip => '规则选项';

  @override
  String get rulesPageTitle => '训练进度规则';

  @override
  String get rulesPageSubtitle => '创建可重复使用的规则，定义训练尝试后如何更改重量、次数和组数。';

  @override
  String get rulesHowDefaultsTitle => '默认规则如何工作';

  @override
  String get rulesHowDefaultsBody => '应用默认规则会复制到新健身房资料。资料默认规则会复制到新计划，因此之后的编辑不会意外改写现有计划。';

  @override
  String get rulesAppDefaultsTitle => '全应用默认规则';

  @override
  String get rulesAppDefaultsSubtitle => '新健身房资料的起始规则。';

  @override
  String get rulesNoAppDefaults => '尚未创建全应用规则。';

  @override
  String get rulesAddApp => '添加应用规则';

  @override
  String get rulesGymProfilesTitle => '健身房资料';

  @override
  String get rulesGymProfilesSubtitle => '每个资料将默认规则和计划规则保存在一起。';

  @override
  String get rulesNoProfiles => '创建健身房资料以添加资料和计划规则。';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules 条资料规则 • $planRules 条计划规则';
  }

  @override
  String get rulesProfileDefaultsTitle => '资料默认规则';

  @override
  String get rulesProfileDefaultsSubtitle => '此资料中新计划的起始规则。';

  @override
  String get rulesNoProfileDefaults => '此资料没有默认规则。';

  @override
  String get rulesAddProfile => '添加资料规则';

  @override
  String get rulesPlansTitle => '计划';

  @override
  String get rulesNoPlans => '此健身房资料尚未包含计划。';

  @override
  String get rulesPlanOnlySubtitle => '仅由此计划使用的规则。';

  @override
  String get rulesNoPlanRules => '此计划没有特定进阶规则。';

  @override
  String get rulesAddPlan => '添加计划规则';

  @override
  String get rulesAppDefaultsChip => '应用默认';

  @override
  String get rulesProfilesChip => '资料';

  @override
  String get rulesPlansChip => '计划';

  @override
  String get rulesEditPlan => '编辑规则';

  @override
  String get rulesAddPlanTitle => '添加规则';

  @override
  String get commonRetry => '重试';

  @override
  String get flowPageTitle => '训练进阶流程';

  @override
  String get flowPageSubtitle => '设置决定训练结果后如何应用进阶操作的路径。';

  @override
  String get flowHowCopiedTitle => '流程如何复制';

  @override
  String get flowHowCopiedBody => '应用流程会成为新健身房档案的起点。健身房流程会成为新计划的起点。之后的编辑仅影响您在此处打开的流程。';

  @override
  String get flowLoadError => '无法加载训练进阶流程。';

  @override
  String get flowAppDefaultsSubtitle => '新健身房档案的起始流程。';

  @override
  String get flowAppDefaultEntry => '应用默认流程';

  @override
  String get flowGymProfilesSubtitle => '每个档案都有默认值和自己的计划流程。';

  @override
  String get flowNoProfiles => '请创建健身房档案以设置档案和计划流程。';

  @override
  String get flowNoSavedYet => '尚无保存的流程';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes 个节点 ｜$branches 个分支 ｜$actions 个操作';
  }

  @override
  String flowPlansAvailable(int count) {
    return '有 $count 个计划流程可用';
  }

  @override
  String get flowGymDefaultEntry => '健身房默认流程';

  @override
  String get gymSettingsTitle => '健身房和训练设置';

  @override
  String get gymSettingsSubtitle => '调整训练生成、分析和训练流程行为。';

  @override
  String get gymSettingsLogicTitle => '训练逻辑';

  @override
  String get gymSettingsLogicSubtitle => '影响计划和生成训练的设置。';

  @override
  String get gymSettingsWorkoutTitle => '训练设置';

  @override
  String get gymSettingsWorkoutSubtitle => '训练量限制、分析默认值和训练控制。';

  @override
  String get gymSettingsExitTitle => '正在进行的训练退出方式';

  @override
  String get gymSettingsFlowToolsTitle => '流程工具';

  @override
  String get gymSettingsFlowToolsSubtitle => '管理已保存的进阶路径和操作。';

  @override
  String get gymSettingsFlowsSubtitle => '编辑应用默认值、健身房和计划的进阶流程。';

  @override
  String get gymSettingsRulesSubtitle => '管理重量、重复次数和训练组进阶规则。';

  @override
  String get gymExitAsk => '每次询问';

  @override
  String get gymExitDiscard => '取消训练';

  @override
  String get gymExitSave => '结束并保存';

  @override
  String get gymExitAskBody => '结束已完成的训练前先询问。';

  @override
  String get gymExitDiscardBody => '取消且不保存已完成的训练内容。';

  @override
  String get gymExitSaveBody => '将已完成的训练保存到训练日志。';

  @override
  String get commonAll => '全部';

  @override
  String get catalogGuideChooseTitle => '选择动作';

  @override
  String get catalogGuideChooseBody => '点按任一动作行以选择它。搜索或筛选条件可帮助您找到合适的动作。';

  @override
  String get catalogGuideAddTitle => '添加到计划';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return '点按 + 以添加 $exerciseName 并返回您的计划。';
  }

  @override
  String get catalogGuideSearchTitle => '搜索动作';

  @override
  String get catalogGuideSearchBody => '已知道想做什么动作时，可按动作名称搜索。';

  @override
  String get catalogFilters => '筛选条件';

  @override
  String get catalogGuideFiltersBody => '按健身房档案、器械、身体部位或肌肉筛选，可快速缩小目录范围。';

  @override
  String get catalogGuideRowsTitle => '动作行';

  @override
  String get catalogGuideRowsBody => '每一行显示器械和热力图。点按热力图可查看详情，选择动作时可点按该行。';

  @override
  String get catalogSelectedFilters => '已选筛选条件';

  @override
  String get catalogUseWorkspaceProfile => '使用当前空间档案';

  @override
  String get catalogWorkspaceProfile => '当前空间档案';

  @override
  String get catalogEquipment => '器械';

  @override
  String get catalogFocusArea => '重点区域';

  @override
  String get catalogSpecificMuscle => '特定肌肉';

  @override
  String get catalogPageTitle => '动作目录';

  @override
  String get catalogSearchExercises => '搜索动作';

  @override
  String get catalogNoMatches => '没有动作符合筛选条件。';

  @override
  String get catalogOpenExerciseInfo => '打开动作信息';

  @override
  String get commonClose => '关闭';

  @override
  String get exerciseDetailOpenImage => '打开动作图片';

  @override
  String get exerciseDetailTutorialTitle => '动作详情';

  @override
  String get exerciseDetailTutorialBody => '面板标题就是您打开的动作。完成后可从这里关闭。';

  @override
  String get exerciseDetailTabsTutorialTitle => '详情、指标和记录';

  @override
  String get exerciseDetailTabsTutorialBody => '使用这些标签页在说明、最佳举重记录和近期训练记录之间切换。';

  @override
  String get exerciseDetailContextTutorialTitle => '动作背景';

  @override
  String get exerciseDetailContextTutorialBody => '详情标签页会显示该动作的器械、训练的身体部位、肌肉和动作提示。';

  @override
  String get exerciseDetailSessionOpenFailed => '无法打开训练记录。';

  @override
  String get exerciseDetailSessionNotFound => '未找到训练记录。';

  @override
  String get exerciseDetailNoEquipment => '未列出器械。';

  @override
  String get exerciseDetailTargetAnatomy => '目标解剖部位';

  @override
  String get exerciseDetailBodyParts => '身体部位';

  @override
  String get exerciseDetailNoBodyParts => '未列出身体部位。';

  @override
  String get exerciseDetailMuscles => '肌肉';

  @override
  String get exerciseDetailNoMuscles => '未列出肌肉。';

  @override
  String get exerciseDetailSetup => '准备';

  @override
  String get exerciseDetailNoSetup => '未提供准备说明。';

  @override
  String get exerciseDetailExecution => '动作执行';

  @override
  String get exerciseDetailNoExecution => '未提供动作执行说明。';

  @override
  String get exerciseDetailTips => '提示';

  @override
  String get exerciseDetailNoTips => '没有其他提示。';

  @override
  String get exerciseDetailFormGuide => '动作指南';

  @override
  String get exerciseDetailOpenHeatmap => '打开目标身体热力图';

  @override
  String get exerciseDetailNoHeatmap => '没有可显示的目标身体区域';

  @override
  String get exerciseDetailZoomHint => '双指捏合或拖动以缩放';

  @override
  String get exerciseDetailLoadingBestLifts => '正在加载最佳举重记录';

  @override
  String get exerciseDetailLoadingBestLiftsBody => '正在计算您已完成训练组的记录。';

  @override
  String get exerciseDetailMetricsUnavailable => '指标不可用';

  @override
  String get exerciseDetailMetricsUnavailableBody => '请重新打开此动作以加载已完成训练组的记录。';

  @override
  String get exerciseDetailNoBestLifts => '尚无最佳举重记录';

  @override
  String get exerciseDetailNoBestLiftsBody => '完成该动作的负重训练组，即可开始追踪各重复次数的最佳记录。';

  @override
  String get exerciseDetailWeek => '周';

  @override
  String get exerciseDetailMonth => '月';

  @override
  String get exerciseDetailAllTime => '全部时间';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return '$timeframe 指标';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => '最高估算 1RM';

  @override
  String get exerciseDetailVolumeBest => '最佳容量';

  @override
  String get exerciseDetailRepBests => '重复次数最佳记录';

  @override
  String get exerciseDetailRepBestsBody => '每个重复次数对应的最佳已完成重量';

  @override
  String exerciseDetailRanges(int count) {
    return '$count 个范围';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => '无法加载动作历史记录。';

  @override
  String get exerciseDetailNoHistory => '此动作暂无历史记录。';

  @override
  String get exerciseDetailPerformanceTrend => '表现趋势';

  @override
  String get exerciseDetailBestWeight => '最佳重量';

  @override
  String get exerciseDetailEstimatedOneRm => '估算 1RM';

  @override
  String get exerciseDetailLoadingSessions => '正在加载训练记录';

  @override
  String get exerciseDetailLoadMoreSessions => '再加载 10 条训练记录';

  @override
  String get exerciseDetailResizeLabel => '调整动作详情大小';

  @override
  String get exerciseDetailResizeHint => '向上或向下拖动以调整底部面板大小';

  @override
  String get exerciseDetailTabDetails => '详情';

  @override
  String get exerciseDetailTabMetrics => '指标';

  @override
  String get exerciseDetailTabRecords => '记录';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return '打开包含 $count 个已完成训练组的训练';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 组',
      one: '1 组',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return '估算 1RM $weight';
  }

  @override
  String get exerciseDetailReps => '次';

  @override
  String get exerciseDetailSetVolume => '训练组容量';

  @override
  String get exerciseDetailNoChartData => '尚无可绘制图表的已完成训练组记录。';

  @override
  String get exerciseDetailWeightAbbreviation => '重量';

  @override
  String get exerciseDetailEstimatedAbbreviation => '估算';

  @override
  String get exerciseDetailTopAbbreviation => '最高';

  @override
  String exerciseDetailSectionLabel(String title) {
    return '$title部分';
  }

  @override
  String get logbookTutorialCalendarTitle => '日志日历';

  @override
  String get logbookTutorialCalendarBody => '使用 M、3M、Y 和 4Y 浏览训练历史。选择一天、一周、一个月或一年，可查看该范围内的训练和摘要统计。';

  @override
  String get fullHistoryTitle => '所有训练记录';

  @override
  String get fullHistoryLoadError => '无法加载已保存的训练记录。';

  @override
  String get fullHistoryEmpty => '尚未保存训练记录。';

  @override
  String fullHistorySessionSummary(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get weeklySetsTitle => '每周训练组概览';

  @override
  String get weeklySetsLoadError => '无法加载您的每周训练概览。';

  @override
  String get weeklySetsBodyParts => '身体部位';

  @override
  String get weeklySetsMuscles => '肌肉';

  @override
  String get weeklySetsTotal => '总训练组数';

  @override
  String get weeklySetsTime => '时间';

  @override
  String get weeklySetsVolume => '训练容量';

  @override
  String get weeklySetsNoBodyParts => '尚无身体部位训练组。';

  @override
  String get weeklySetsNoMuscles => '尚无肌肉训练组。';

  @override
  String weeklySetsCount(String count) {
    return '$count 组';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => '每周概览';

  @override
  String get weeklySetsTutorialOverviewBody => '这里使用热力图及总训练组数、时间和训练容量汇总过去 7 天。';

  @override
  String get weeklySetsTutorialAnatomyTitle => '身体部位或肌肉';

  @override
  String get weeklySetsTutorialAnatomyBody => '在身体部位训练组单位和单个肌肉训练组单位之间切换。';

  @override
  String get weeklySetsTutorialStatusTitle => '训练组状态';

  @override
  String get weeklySetsTutorialStatusBody => '每一行的颜色取决于近期训练量是低于、处于还是高于建议范围。点按一行可查看关联动作。';

  @override
  String get workoutDetailTutorialSummaryTitle => '训练概览';

  @override
  String get workoutDetailTutorialSummaryBody => '查看总训练组数、训练容量、时长、动作数量以及此次训练覆盖的身体部位。';

  @override
  String get workoutDetailTutorialExercisesTitle => '动作记录';

  @override
  String get workoutDetailTutorialExercisesBody => '每个动作都会显示该次训练中完成的训练组。点按详情可查看动作。';

  @override
  String get workoutDetailTutorialEditTitle => '编辑训练记录';

  @override
  String get workoutDetailTutorialEditBody => '如果训练后需要更正训练组、重复次数或动作，请使用编辑模式。';

  @override
  String get workoutDetailTutorialReuseTitle => '重复使用此训练';

  @override
  String get workoutDetailTutorialReuseBody => '再次进行此训练，或将已完成的训练记录保存为可重复使用的计划。';

  @override
  String get workoutDetailDeleteTitle => '删除训练记录';

  @override
  String get workoutDetailDeleteBody => '确定要删除此训练记录吗？';

  @override
  String get workoutDetailDeleteFailed => '无法删除此训练记录。';

  @override
  String get workoutDetailChangesSaved => '更改已保存。';

  @override
  String get workoutDetailSaveFailed => '无法保存更改。先前的训练记录未更改。';

  @override
  String get workoutDetailFinishCurrentFirst => '请先完成当前训练，再重复此训练。';

  @override
  String get workoutDetailOngoingWorkoutKept => '已保留您正在进行的训练。请先完成或取消它，再重复此训练。';

  @override
  String get workoutDetailRepeatFailed => '无法重复此训练。';

  @override
  String get workoutDetailSaveAsPlan => '另存为计划';

  @override
  String get workoutDetailPlanName => '计划名称';

  @override
  String workoutDetailPlanSaved(String name) {
    return '已将“$name”保存为计划。';
  }

  @override
  String get workoutDetailPlanSaveFailed => '保存计划失败。';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return '训练 $date';
  }

  @override
  String get workoutDetailUnsavedTitle => '未保存的更改';

  @override
  String get workoutDetailUnsavedBody => '您有未保存的更改。要放弃它们并离开吗？';

  @override
  String get workoutDetailDiscard => '放弃';

  @override
  String get workoutDetailTitle => '训练详情';

  @override
  String get workoutDetailStopEditing => '停止编辑';

  @override
  String get workoutDetailEditSession => '编辑训练记录';

  @override
  String get workoutDetailDeleteSession => '删除训练记录';

  @override
  String get workoutDetailLoadFailed => '无法加载此训练记录。';

  @override
  String get workoutDetailEmpty => '此训练记录中没有动作。';

  @override
  String get workoutDetailSaveChanges => '保存更改';

  @override
  String get workoutDetailRepeat => '再次进行此训练';

  @override
  String get workoutDetailPastWorkout => '过去的训练';

  @override
  String workoutDetailCompletedSets(int count) {
    return '已完成 $count 个训练组';
  }

  @override
  String get workoutDetailVolume => '训练容量';

  @override
  String get workoutDetailDuration => '时长';

  @override
  String get workoutDetailExercises => '动作';

  @override
  String get workoutDetailExerciseInfo => '动作信息';

  @override
  String get workoutDetailBest => '最佳';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => '无法加载训练日历。';

  @override
  String get logbookNoWorkouts => '没有已记录的训练';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次训练',
      one: '1 次训练',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => '上个月';

  @override
  String get logbookNextMonth => '下个月';

  @override
  String get logbookPreviousThreeMonths => '前 3 个月';

  @override
  String get logbookNextThreeMonths => '后 3 个月';

  @override
  String get logbookPreviousYear => '上一年';

  @override
  String get logbookNextYear => '下一年';

  @override
  String logbookWeekShort(int week) {
    return '第 $week 周';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month 第 $week 周';
  }

  @override
  String get logbookWorkouts => '训练';

  @override
  String get logbookTotalTime => '总时间';

  @override
  String get logbookTotalVolume => '总训练量';

  @override
  String get logbookViewAllSessions => '查看所有训练';

  @override
  String logbookSessionSummary(String duration, int exercises, int sets, String volume) {
    return '$duration - $exercises 个动作 - $sets 组 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '$hours 小时';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes 分 $seconds 秒';
  }

  @override
  String get dashboardHideSection => '隐藏版块';

  @override
  String get dashboardAllSectionsShown => '所有版块均已显示';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '已隐藏 $count 个版块';
  }

  @override
  String get dashboardShowHiddenSections => '显示已隐藏版块';

  @override
  String get dashboardReset => '重置仪表盘';

  @override
  String get dashboardEmptyTitle => '您的仪表盘为空';

  @override
  String get dashboardEmptyBody => '准备好后，您可以随时重新添加任意版块。';

  @override
  String get dashboardCustomize => '自定义仪表盘';

  @override
  String get dashboardSectionQuickActionsTitle => '快捷操作';

  @override
  String get dashboardSectionQuickActionsBody => '记录测量数据或开始训练。';

  @override
  String get dashboardSectionTrainingTitle => '准备训练';

  @override
  String get dashboardSectionTrainingBody => '选择健身房资料和计划，然后开始会话。';

  @override
  String get dashboardSectionNutritionTitle => '营养仪表盘';

  @override
  String get dashboardSectionNutritionBody => '查看当前热量和宏量营养目标。';

  @override
  String get dashboardSectionDataRecordsTitle => '数据与记录';

  @override
  String get dashboardSectionDataRecordsBody => '查看并添加每日营养记录。';

  @override
  String get dashboardSectionWeeklyFocusTitle => '每周重点';

  @override
  String get dashboardSectionWeeklyFocusBody => '查看过去 7 天的身体部位和肌肉训练。';

  @override
  String get dashboardSectionWorkoutReportTitle => '训练报告';

  @override
  String get dashboardSectionWorkoutReportBody => '比较不同时段的训练次数、时间和训练量。';

  @override
  String get dashboardSectionExerciseProgressTitle => '动作进度';

  @override
  String get dashboardSectionExerciseProgressBody => '追踪所选动作的力量趋势。';

  @override
  String get dashboardSectionHistoryTitle => '训练历史';

  @override
  String get dashboardSectionHistoryBody => '比较不同时间范围内的训练总量和重点。';

  @override
  String get dashboardSectionHealthTrendsTitle => '健康趋势';

  @override
  String get dashboardSectionHealthTrendsBody => '追踪体重和围度等测量数据。';

  @override
  String get dashboardSectionRecentWorkoutsTitle => '最近训练';

  @override
  String get dashboardSectionRecentWorkoutsBody => '打开最近完成的训练会话。';

  @override
  String get dashboardSectionActivePlansTitle => '活跃计划';

  @override
  String get dashboardSectionActivePlansBody => '将最常使用的计划放在手边。';

  @override
  String get dashboardSectionArchivedPlansTitle => '已归档计划';

  @override
  String get dashboardSectionArchivedPlansBody => '浏览当前未启用的计划。';

  @override
  String get dashboardSectionPremadePlansTitle => '预制计划';

  @override
  String get dashboardSectionPremadePlansBody => '浏览可添加到此资料的例程。';

  @override
  String get dashboardSectionPlanToolsTitle => '计划工具';

  @override
  String get dashboardSectionPlanToolsBody => '生成均衡计划，或手动创建计划。';

  @override
  String get dashboardSectionCatalogTitle => '训练动作目录';

  @override
  String get dashboardSectionCatalogBody => '打开最常使用的动作和完整目录。';

  @override
  String get dashboardSectionAnatomyTitle => '目标解剖部位';

  @override
  String get dashboardSectionAnatomyBody => '查看您训练最多的身体部位和肌肉。';

  @override
  String get dashboardSectionFallbackTitle => '仪表盘版块';

  @override
  String get dashboardSectionFallbackBody => '一个仪表盘版块。';

  @override
  String get dashboardTitle => '仪表盘';

  @override
  String get dashboardDoneCustomizing => '完成自定义';

  @override
  String get dashboardQuickActions => '快捷操作';

  @override
  String get dashboardMeasurement => '测量';

  @override
  String get dashboardResumeWorkout => '继续训练';

  @override
  String get dashboardStartWorkout => '开始训练';

  @override
  String dashboardTodayAt(String time) {
    return '今天，$time';
  }

  @override
  String get dashboardRecentWorkouts => '最近训练';

  @override
  String get dashboardViewAll => '查看全部';

  @override
  String get dashboardRecentWorkoutsFailed => '无法加载最近训练。';

  @override
  String get dashboardRecentWorkoutsEmpty => '完成一次训练后，它会显示在这里。';

  @override
  String get userInfoProfileUpdateNote => '档案更新';

  @override
  String get userInfoChangesSaved => '更改已保存';

  @override
  String get userInfoSaveFailed => '无法保存您的更改。';

  @override
  String get userInfoTitle => '用户信息';

  @override
  String get userInfoSubtitle => '保留可供应用计算使用的基本档案信息。';

  @override
  String get userInfoIdentityTitle => '身份信息';

  @override
  String get userInfoIdentitySubtitle => '基本个人信息。';

  @override
  String get userInfoName => '姓名';

  @override
  String get userInfoNameHint => '输入您的姓名';

  @override
  String get userInfoGender => '性别';

  @override
  String get userInfoDateOfBirth => '出生日期';

  @override
  String get userInfoDateHint => 'YYYY-MM-DD';

  @override
  String get userInfoBodyMetricsTitle => '身体指标';

  @override
  String get userInfoBodyMetricsSubtitle => '用于进度和营养估算的可选详细信息。';

  @override
  String get userInfoHeight => '身高';

  @override
  String get userInfoHeightHint => '例如 5 英尺 10 英寸或 178 厘米';

  @override
  String get userInfoCurrentWeight => '当前体重';

  @override
  String get userInfoWeightPoundsHint => '例如 160';

  @override
  String get userInfoWeightKilogramsHint => '例如 72';

  @override
  String get userInfoBodyFat => '体脂率估算';

  @override
  String get userInfoActivityTitle => '活动情况';

  @override
  String get userInfoActivitySubtitle => '后续将用于建议和健康估算。';

  @override
  String get userInfoWeightTrend => '体重趋势';

  @override
  String get userInfoAverageSteps => '预计平均步数';

  @override
  String get userInfoGenderMale => '男';

  @override
  String get userInfoGenderFemale => '女';

  @override
  String get userInfoGenderOther => '其他';

  @override
  String get userInfoGenderPreferNotToSay => '不愿透露';

  @override
  String get userInfoTrendGaining => '体重增加中';

  @override
  String get userInfoTrendLosing => '体重减少中';

  @override
  String get userInfoTrendMaintaining => '维持体重';

  @override
  String get userInfoTrendNotSure => '不确定';

  @override
  String get userInfoActivityLow => '低（0–5k）';

  @override
  String get userInfoActivityModerate => '中等（5–15k）';

  @override
  String get userInfoActivityHigh => '高（15k+）';

  @override
  String get userInfoSaveChanges => '保存更改';

  @override
  String get tutorialsSettingsTitle => '引导教程';

  @override
  String get tutorialsSettingsSubtitle => '想快速复习时，可重新播放引导。';

  @override
  String get tutorialsControlsTitle => '教程控制';

  @override
  String get tutorialsControlsSubtitle => '正在测试或想重新开始？';

  @override
  String get tutorialsResetAllTitle => '重置所有教程';

  @override
  String get tutorialsResetAllSubtitle => '让所有引导教程再次可用。';

  @override
  String get tutorialsResetAll => '重置全部';

  @override
  String get tutorialsResetAllMessage => '所有教程已重置。';

  @override
  String get tutorialsHowItWorksTitle => '教程的工作方式';

  @override
  String get tutorialsHowItWorksBody => '教程会显示一次，之后不会打扰您。展开一个分组可重置特定引导。';

  @override
  String get tutorialsMainTabsTitle => '主标签页';

  @override
  String get tutorialsMainTabsSubtitle => '重新查看每个主要区域的引导。';

  @override
  String get tutorialsWorkoutTitle => '训练';

  @override
  String get tutorialsWorkoutSubtitle => '记录首次训练的帮助。';

  @override
  String get tutorialsPlansTitle => '计划和训练';

  @override
  String get tutorialsPlansSubtitle => '重新查看计划创建、编辑和训练详情帮助。';

  @override
  String get tutorialsCatalogTitle => '目录和解剖部位';

  @override
  String get tutorialsCatalogSubtitle => '重新查看动作和目标解剖部位帮助。';

  @override
  String get tutorialsProgressTitle => '进度和设置';

  @override
  String get tutorialsProgressSubtitle => '重新查看进度详情和设置页面帮助。';

  @override
  String tutorialsReplayTitle(String topic) {
    return '重新播放 $topic 教程';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return '下次打开 $topic 时显示。';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return '$topic 教程将在下次重新播放。';
  }

  @override
  String get tutorialsReset => '重置';

  @override
  String get tutorialsTopicTrain => '训练';

  @override
  String get tutorialsTopicCatalog => '目录';

  @override
  String get tutorialsTopicLogbook => '训练日志';

  @override
  String get tutorialsTopicProgress => '进度';

  @override
  String get tutorialsTopicProfile => '档案';

  @override
  String get tutorialsTopicFirstWorkout => '第一次训练';

  @override
  String get tutorialsTopicGeneratePlans => '生成计划';

  @override
  String get tutorialsTopicOptimizedSettings => '优化训练设置';

  @override
  String get tutorialsTopicPremadePlans => '预制计划';

  @override
  String get tutorialsTopicPlanManagement => '计划管理';

  @override
  String get tutorialsTopicPlanDetail => '计划详情';

  @override
  String get tutorialsTopicPlanBuilder => '计划构建器';

  @override
  String get tutorialsTopicWorkoutDetail => '训练详情';

  @override
  String get tutorialsTopicExerciseCatalog => '动作目录';

  @override
  String get tutorialsTopicExerciseDetail => '动作详情';

  @override
  String get tutorialsTopicTargetAnatomy => '目标解剖部位';

  @override
  String get tutorialsTopicBodypartDetail => '身体部位详情';

  @override
  String get tutorialsTopicMuscleDetail => '肌肉详情';

  @override
  String get tutorialsTopicWeeklySets => '每周训练组概览';

  @override
  String get tutorialsTopicExerciseProgress => '动作进度';

  @override
  String get tutorialsTopicMeasurementTrend => '测量趋势';

  @override
  String get tutorialsTopicGymProfile => '健身房档案编辑器';

  @override
  String get tutorialsTopicUiAppearance => '界面和外观';

  @override
  String get tutorialsTopicDatabaseSettings => '数据库设置';

  @override
  String get tutorialsTopicGuide => '引导帮助';

  @override
  String get anatomyLibraryTitle => '动作重点资料库';

  @override
  String get anatomyBodyParts => '身体部位';

  @override
  String get anatomyMuscles => '肌肉';

  @override
  String get anatomyLoadFailed => '无法加载解剖部位筛选条件。';

  @override
  String get anatomySearchLabel => '搜索身体部位或肌肉';

  @override
  String get anatomyNoBodyParts => '没有身体部位匹配您的搜索。';

  @override
  String get anatomyNoMuscles => '没有肌肉匹配您的搜索。';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个动作',
      one: '1 个动作',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => '搜索解剖部位';

  @override
  String get anatomyTutorialSearchBody => '想查找有针对性的动作选项时，可搜索某个身体部位或特定肌肉。';

  @override
  String get anatomyTutorialListsTitle => '身体部位和肌肉';

  @override
  String get anatomyTutorialListsBody => '切换标签页，然后点按任一行以查看关联动作、近期训练组总数和建议训练组边界。';

  @override
  String anatomyTargetExercises(String name) {
    return '$name 动作';
  }

  @override
  String get anatomyBodypartLoadFailed => '无法加载此身体部位。';

  @override
  String get anatomyMuscleLoadFailed => '无法加载此肌肉。';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return '已更新 $name 的建议训练组数。';
  }

  @override
  String get anatomySaveFailed => '无法保存更改。';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个关联动作',
      one: '1 个关联动作',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => '已完成（7 天）';

  @override
  String get anatomySetsLastSevenDays => '过去 7 天训练组数';

  @override
  String anatomySetUnits(String count) {
    return '$count 组';
  }

  @override
  String get anatomyRecommended => '建议';

  @override
  String get anatomyNotSet => '未设置';

  @override
  String anatomySetRange(String min, String max) {
    return '$min–$max 组';
  }

  @override
  String get anatomyAssociatedMuscles => '关联肌肉';

  @override
  String get anatomyRelatedBodyParts => '相关身体部位';

  @override
  String get anatomyNoMuscleLinks => '尚未为此身体部位添加肌肉关联。';

  @override
  String get anatomyNoBodyPartLinks => '尚未为此肌肉添加身体部位关联。';

  @override
  String get anatomyExercises => '动作';

  @override
  String anatomyNoExercisesFor(String name) {
    return '当前没有与 $name 关联的动作。';
  }

  @override
  String get anatomyNoEquipment => '未列出器械';

  @override
  String get anatomyNoMusclesListed => '未列出肌肉';

  @override
  String get anatomyNoBodyPartsListed => '未列出身体部位';

  @override
  String anatomyOpenedFrom(String name) {
    return '从 $name 打开';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return '此肌肉的排名 $rank - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => '解剖部位详情';

  @override
  String get anatomyTutorialBodypartDetailBody => '标题区域会显示近期训练组、建议训练组边界和相关解剖部位链接。';

  @override
  String get anatomyTutorialMuscleDetailTitle => '肌肉详情';

  @override
  String get anatomyTutorialMuscleDetailBody => '标题区域会显示近期训练组、建议训练组边界和相关身体部位。';

  @override
  String get anatomyTutorialLinkedExercisesTitle => '关联动作';

  @override
  String get anatomyTutorialBodypartExercisesBody => '这些是与该目标关联的动作。点按任一动作可打开完整详情。';

  @override
  String get anatomyTutorialMuscleExercisesBody => '动作会按其训练此肌肉的直接程度排序。点按任一动作可查看完整详情。';

  @override
  String get settingsWorkoutTitle => '训练设置';

  @override
  String get settingsWorkoutSubtitle => '调整应用如何理解解剖部位、训练偏好和训练量目标。';

  @override
  String get settingsTrainingBiasTitle => '训练偏好';

  @override
  String get settingsTrainingBiasSubtitle => '用于生成计划和优化训练的控制项。';

  @override
  String get settingsBodyPartRankings => '身体部位排名';

  @override
  String get settingsBodyPartRankingsSubtitle => '优先安排应获得更多训练量的身体部位。';

  @override
  String get settingsMuscleRankings => '肌肉排名';

  @override
  String get settingsMuscleRankingsSubtitle => '在解剖模型中优先安排特定肌肉。';

  @override
  String get settingsVolumeBoundaries => '训练量边界';

  @override
  String get settingsVolumeBoundariesSubtitle => '为身体部位和肌肉设置建议每周范围。';

  @override
  String get settingsExerciseDefinitionsTitle => '动作定义';

  @override
  String get settingsExerciseDefinitionsSubtitle => '维护应用使用的解剖部位和动作数据。';

  @override
  String get settingsAnatomyMapping => '身体部位／肌肉映射';

  @override
  String get settingsAnatomyMappingSubtitle => '选择各身体部位包含哪些肌肉。';

  @override
  String get settingsExerciseSetAllocation => '动作训练组分配';

  @override
  String get settingsExerciseSetAllocationSubtitle => '查看每个动作如何计入肌肉和身体部位。';

  @override
  String get settingsExerciseEditor => '动作编辑器';

  @override
  String get settingsExerciseEditorSubtitle => '更新动作名称、详情、器械和映射。';

  @override
  String get commonCopy => '复制';

  @override
  String get commonImport => '导入';

  @override
  String get commonExport => '导出';

  @override
  String get databaseExportTitle => '导出数据库';

  @override
  String get databaseImportTitle => '导入数据库';

  @override
  String get databasePasteJson => '在此粘贴 JSON';

  @override
  String get databaseCopied => '已复制到剪贴板';

  @override
  String databaseExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get databaseImportSucceeded => '导入成功';

  @override
  String databaseImportFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get nutritionSettingsTitle => '饮食和营养设置';

  @override
  String get nutritionSettingsSubtitle => '配置营养目标和食物相关偏好。';

  @override
  String get nutritionCurrentGoals => '当前目标';

  @override
  String get nutritionGoals => '目标';

  @override
  String get nutritionGoalsSubtitle => '设置营养追踪使用的目标值。';

  @override
  String get nutritionManualGoals => '手动设置营养目标';

  @override
  String get nutritionManualGoalsSubtitle => '自行输入热量、宏量营养素和关键营养素。';

  @override
  String get nutritionGoalsSaved => '目标已保存';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return '热量：$calories ／蛋白质：$protein ／碳水：$carbs ／脂肪：$fat ／纤维：$fiber ／糖：$sugar ／饱和脂肪：$satFat ／钠：$sodium';
  }

  @override
  String get progressSettingsTitle => '进度设置';

  @override
  String get progressSettingsSubtitle => '管理身体测量和趋势追踪设置。';

  @override
  String get progressMeasurements => '测量';

  @override
  String get progressMeasurementsSubtitle => '配置想随时间追踪的身体指标。';

  @override
  String get progressMeasurementLibrary => '测量库';

  @override
  String get progressMeasurementLibrarySubtitle => '管理体重、身高、身体测量和自定义指标。';

  @override
  String get nutritionManualGoalsTitle => '手动营养目标';

  @override
  String get nutritionManualGoalsPageSubtitle => '手动设置热量、宏量营养素和营养素目标。';

  @override
  String get nutritionSaveGoals => '保存目标';

  @override
  String get nutritionSaving => '正在保存……';

  @override
  String get nutritionStartDate => '开始日期';

  @override
  String get nutritionGoalStarts => '目标开始日期';

  @override
  String get nutritionCaloriesAndMacros => '热量和宏量营养素';

  @override
  String get nutritionAdditionalNutrients => '其他营养素';

  @override
  String get nutritionCalories => '热量（kcal）';

  @override
  String get nutritionProtein => '蛋白质（克）';

  @override
  String get nutritionCarbs => '碳水化合物（克）';

  @override
  String get nutritionFat => '脂肪（克）';

  @override
  String get nutritionFiber => '膳食纤维（克）';

  @override
  String get nutritionSugar => '糖（克）';

  @override
  String get nutritionSatFat => '饱和脂肪（克）';

  @override
  String get nutritionSodium => '钠（毫克）';

  @override
  String get nutritionEnterNumber => '输入数字';

  @override
  String get nutritionNumberAtLeastZero => '必须大于或等于 0';

  @override
  String rankingsSaved(String target) {
    return '$target 排序已保存';
  }

  @override
  String get rankingsSave => '保存排序';

  @override
  String rankingsTitle(String target) {
    return '$target 排序';
  }

  @override
  String rankingsHero(String target) {
    return '将 $target 拖动到希望生成训练优先使用的顺序。';
  }

  @override
  String get rankingsNoBodyParts => '未定义身体部位';

  @override
  String get rankingsNoMuscles => '未定义肌肉';

  @override
  String rankingsLoadError(String target, String error) {
    return '无法加载 $target：$error';
  }

  @override
  String rankingsSaveError(String error) {
    return '无法保存：$error';
  }

  @override
  String get rankingsRank => '排序';

  @override
  String get mappingTitle => '解剖映射';

  @override
  String get mappingHero => '将肌肉关联到身体部位，使热图、分析和生成的训练保持一致。';

  @override
  String get mappingSaved => '映射已保存';

  @override
  String mappingSaveFailed(String error) {
    return '无法保存：$error';
  }

  @override
  String get mappingSelectedBodyPart => '选定身体部位';

  @override
  String get mappingBodyPart => '身体部位';

  @override
  String get mappingChooseLinkedMuscles => '选择关联肌肉';

  @override
  String get mappingLinkedMuscles => '关联肌肉';

  @override
  String get mappingChooseLinkedSubtitle => '选择属于此身体部位的每块肌肉。';

  @override
  String mappingLinkedCount(int count) {
    return '当前关联了 $count 块肌肉。';
  }

  @override
  String get mappingNoMuscles => '未定义肌肉。';

  @override
  String get mappingNoLinkedMuscles => '尚未关联肌肉。点击编辑以添加。';

  @override
  String get volumeMaintenance => '维持';

  @override
  String get volumeMinEffective => '最低有效量';

  @override
  String get volumeMaxAdaptive => '最大适应量';

  @override
  String get volumeMaxRecoverable => '最大可恢复量';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return '无法加载身体部位边界：$error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return '无法加载肌肉边界：$error';
  }

  @override
  String get volumeBodyPartSaved => '身体部位边界已保存';

  @override
  String get volumeMuscleSaved => '肌肉边界已保存';

  @override
  String get volumeInvalidNumbers => '请输入有效数字';

  @override
  String get volumeBodyParts => '身体部位';

  @override
  String get volumeMuscles => '肌肉';

  @override
  String get volumeBodyPartTitle => '身体部位训练量';

  @override
  String get volumeBodyPartSubtitle => '设置每周分析和训练生成使用的每周目标范围。';

  @override
  String get volumeMuscleTitle => '肌肉训练量';

  @override
  String get volumeMuscleSubtitle => '微调各个肌肉的每周目标范围。';

  @override
  String get volumeSelection => '选择';

  @override
  String get volumeRecommendedRange => '建议范围';

  @override
  String get volumeRecommendedRangeSubtitle => '数字表示每周训练组单位。';

  @override
  String get volumeSaveBoundaries => '保存边界';

  @override
  String get nutritionDashboardTitle => '营养仪表板';

  @override
  String nutritionDashboardError(String error) {
    return '无法加载营养数据：$error';
  }

  @override
  String get nutritionMenuTitle => '营养菜单';

  @override
  String get nutritionLogFood => '记录食物';

  @override
  String get nutritionTrackMeasurement => '追踪测量';

  @override
  String get nutritionMeasuredItems => '已测量项目';

  @override
  String get nutritionTodayRecords => '今日记录';

  @override
  String get nutritionGoalsMenu => '营养目标';

  @override
  String get measurementWeight => '体重';

  @override
  String get measurementHips => '臀围';

  @override
  String get measurementShoulders => '肩围';

  @override
  String get measurementCalves => '小腿围';

  @override
  String get measurementTrackNew => '追踪新测量';

  @override
  String get barcodeScannerTitle => '扫描条形码';

  @override
  String get barcodeSwitchCamera => '切换摄像头';

  @override
  String get barcodeTorchOn => '打开闪光灯';

  @override
  String get barcodeTorchOff => '关闭闪光灯';

  @override
  String get barcodeTorchUnavailable => '此设备不支持闪光灯';

  @override
  String get barcodeAlignHint => '将条形码对准框内';

  @override
  String get progressTutorialWorkoutReportTitle => '训练报告';

  @override
  String get progressTutorialWorkoutReportBody => '追踪不同时段的训练次数、训练时间和训练量。点击指标可更改图表显示内容。';

  @override
  String get progressTutorialExerciseProgressTitle => '动作进度';

  @override
  String get progressTutorialExerciseProgressBody => '追踪所选动作的力量趋势。使用编辑卡片添加或移除仪表盘动作。';

  @override
  String get progressTutorialHealthTrendsTitle => '健康趋势';

  @override
  String get progressTutorialHealthTrendsBody => '在此记录体重和自定义测量，然后观察它们如何随时间变化。';

  @override
  String get measurementNewTitle => '新建测量';

  @override
  String get measurementPresets => '预设';

  @override
  String get measurementCustom => '自定义';

  @override
  String get measurementPresetType => '预设类型';

  @override
  String get measurementVariation => '变体';

  @override
  String get measurementWakeUp => '起床时间';

  @override
  String get measurementBedtime => '就寝时间';

  @override
  String get measurementOverall => '整体';

  @override
  String get measurementValueWeight => '体重';

  @override
  String get measurementUnits => '单位';

  @override
  String get measurementFeet => '英尺';

  @override
  String get measurementInches => '英寸';

  @override
  String get measurementCentimeters => '厘米';

  @override
  String get measurementWithPump => '有泵感';

  @override
  String get measurementWithoutPump => '无泵感';

  @override
  String get measurementName => '测量名称';

  @override
  String get measurementNameHint => '胸围、静息心率……';

  @override
  String get measurementValue => '数值';

  @override
  String get measurementUnit => '单位';

  @override
  String get measurementNote => '备注';

  @override
  String get measurementOptional => '可选';

  @override
  String get measurementSaveNew => '保存新测量';

  @override
  String get measurementCustomRequired => '请输入自定义名称、数值和单位';

  @override
  String measurementDefinitionNotFound(String name) {
    return '未找到 $name 的定义';
  }

  @override
  String get measurementInvalidValue => '请输入有效数字';

  @override
  String get measurementHeight => '身高';

  @override
  String get measurementForearm => '前臂围';

  @override
  String get measurementArm => '手臂';

  @override
  String get measurementNeck => '颈围';

  @override
  String get measurementChest => '胸围';

  @override
  String get measurementWaist => '腰围';

  @override
  String get measurementThigh => '大腿围';

  @override
  String get measurementInstructionsForearm => '测量前臂最粗处的围度。';

  @override
  String get measurementInstructionsArm => '测量肱二头肌最粗处的围度。';

  @override
  String get measurementInstructionsNeck => '让软尺平直环绕颈部的位置测量。';

  @override
  String get measurementInstructionsShoulder => '让软尺平直环绕三角肌侧面测量。';

  @override
  String get measurementInstructionsChest => '在腋下并高于乳头线的位置测量。';

  @override
  String get measurementInstructionsWaist => '围绕肚脐测量。';

  @override
  String get measurementInstructionsHip => '测量臀部最宽处的围度。';

  @override
  String get measurementInstructionsThigh => '测量大腿最粗处的围度。';

  @override
  String get measurementInstructionsCalf => '测量小腿最粗处的围度。';

  @override
  String get nutritionCaloriesLabel => '热量';

  @override
  String get nutritionFatLabel => '脂肪';

  @override
  String get nutritionProteinLabel => '蛋白质';

  @override
  String get nutritionCarbsLabel => '碳水';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal ｜蛋白质 $protein 克 ｜碳水 $carbs 克 ｜脂肪 $fat 克';
  }

  @override
  String get nutritionEditEntry => '编辑记录';

  @override
  String get nutritionEditNotAvailable => '暂不支持编辑记录';

  @override
  String get nutritionEntryDeleted => '记录已删除';

  @override
  String get gymProfileEditTitle => '编辑健身房资料';

  @override
  String get gymProfileNewTitle => '新健身房资料';

  @override
  String get gymProfileTutorialSpaceTitle => '训练地点';

  @override
  String get gymProfileTutorialSpaceBody => '为您训练的地点命名，例如家庭健身房、商业健身房或旅行配置。';

  @override
  String get gymProfileTutorialFindTitle => '查找器械';

  @override
  String get gymProfileTutorialFindBody => '当器械列表很长且您想快速找到某一项时，请使用搜索。';

  @override
  String get gymProfileTutorialAvailableTitle => '可用器械';

  @override
  String get gymProfileTutorialAvailableBody => '选择此训练地点拥有的器械。生成的计划和替换会借此避开不可用动作。';

  @override
  String get gymProfileTutorialSaveTitle => '保存资料';

  @override
  String get gymProfileTutorialSaveBody => '保存会存储资料和器械。取消会在放弃未保存更改前询问您。';

  @override
  String get gymProfileSaveChangesTitle => '保存更改？';

  @override
  String get gymProfileSaveChangesBody => '您的健身房资料有未保存的更改。离开前保存吗？';

  @override
  String get gymProfileKeepEditing => '继续编辑';

  @override
  String get gymProfileDiscard => '放弃';

  @override
  String get gymProfileSelectEquipment => '至少选择一项器械。';

  @override
  String gymProfileSaveFailed(String error) {
    return '无法保存资料：$error';
  }

  @override
  String get gymProfileEquipmentHint => '选择此健身房拥有的器械，使生成的计划只使用可用器械。';

  @override
  String get gymProfileSpace => '训练地点';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '已选择 $selected/$total 种器械';
  }

  @override
  String get gymProfileName => '资料名称';

  @override
  String get gymProfileNameHint => '家庭健身房、商业健身房、旅行配置...';

  @override
  String get gymProfileNameRequired => '需要名称';

  @override
  String get gymProfileFilterEquipment => '按名称筛选器械';

  @override
  String get gymProfileEquipment => '器械';

  @override
  String get gymProfileSelectAll => '全选';

  @override
  String get gymProfileClear => '清除';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '已选择 $selected/$total';
  }

  @override
  String get gymProfileSave => '保存资料';

  @override
  String get gymProfileSaving => '正在保存...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return '没有器械匹配“$query”。';
  }

  @override
  String get equipmentCategoryBasics => '基础';

  @override
  String get equipmentCategoryFreeWeights => '自由重量';

  @override
  String get equipmentCategoryBenchesRacks => '长凳与架子';

  @override
  String get equipmentCategoryCableAttachments => '拉力器与配件';

  @override
  String get equipmentCategoryMachines => '器械';

  @override
  String get equipmentCategoryOther => '其他器械';

  @override
  String get equipmentNoRequirement => '无需器械';

  @override
  String get equipmentBodyweightSupport => '自重动作支持';

  @override
  String get equipmentMachineBased => '器械动作';

  @override
  String get equipmentCableAccessory => '拉力器训练站配件';

  @override
  String get equipmentBenchRackSetup => '长凳、架子或训练站配置';

  @override
  String get equipmentFreeWeightTraining => '自由重量训练';

  @override
  String get equipmentAvailable => '可用器械';

  @override
  String get foodLoggingTitle => '食物记录';

  @override
  String get foodLogTime => '记录时间：';

  @override
  String get foodPortion => '份量：';

  @override
  String get foodQuantity => '数量：';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams 克／单位';
  }

  @override
  String get foodRemove => '移除';

  @override
  String get foodAddAllToDiary => '全部添加到饮食日志';

  @override
  String get foodLogging => '正在记录……';

  @override
  String get foodTabScan => '扫描';

  @override
  String get foodTabSearch => '搜索';

  @override
  String get foodTabPlanned => '预先计划';

  @override
  String get foodTabCustom => '自定义';

  @override
  String get foodSearchHint => '搜索食物……';

  @override
  String get foodNoRecentRecipes => '尚无近期食谱。';

  @override
  String get foodRecentRecipe => '近期食谱';

  @override
  String get foodNoFoodsFound => '未找到食物。';

  @override
  String get foodInstantLogAfterScan => '扫描后立即记录';

  @override
  String get foodInstantLogAfterScanSubtitle => '使用所选餐次立即添加扫描的食物。';

  @override
  String get foodOpenCameraScanner => '打开摄像头扫描器';

  @override
  String get foodEnterBarcode => '手动输入条形码';

  @override
  String get foodEnterBarcodeHint => '例如 012345678905';

  @override
  String get foodLogByBarcode => '通过条形码记录';

  @override
  String get foodNoBarcode => '未检测到有效条形码';

  @override
  String get foodBarcodeLogged => '已记录条形码中的食物';

  @override
  String foodFailed(String error) {
    return '失败：$error';
  }

  @override
  String get foodCustomSavedBarcode => '自定义食物已保存并关联条形码';

  @override
  String get foodFavorites => '收藏';

  @override
  String get foodRecentFoods => '近期食物';

  @override
  String get foodStartSearching => '开始搜索以查找食物。';

  @override
  String get foodFavorite => '收藏';

  @override
  String get foodUnfavorite => '取消收藏';

  @override
  String get foodCustomize => '自定义食物';

  @override
  String get foodEditAndAdd => '编辑并添加';

  @override
  String get foodAddOne => '添加 1 份';

  @override
  String get foodAddNew => '添加新食物';

  @override
  String get foodCustomSaved => '自定义食物已保存';

  @override
  String get foodNoteOptional => '备注（可选）';

  @override
  String get foodTagsHint => '标签（以逗号分隔，例如训练后、高蛋白）';

  @override
  String get foodAddToPlate => '添加到餐盘';

  @override
  String get foodProfileNotReady => '档案尚未准备好。';

  @override
  String get foodItemsLogged => '已记录到饮食日志的食物';

  @override
  String foodLogFailed(String error) {
    return '无法记录：$error';
  }

  @override
  String get tutorialSkip => '跳过';

  @override
  String get tutorialSkipAll => '全部跳过';

  @override
  String get tutorialDone => '完成';

  @override
  String get tutorialNext => '下一步';

  @override
  String get tutorialSkipAllTitle => '跳过所有教程？';

  @override
  String get tutorialSkipAllBody => '这会隐藏所有引导教程。您随时可以在“设置 > 引导教程”中使用“重置所有教程”重新启用它们。';

  @override
  String get tutorialKeep => '保留教程';

  @override
  String get tutorialSkipEverything => '全部跳过';

  @override
  String get flowSelectNode => '选择节点';

  @override
  String get flowSelectMethod => '选择方法';

  @override
  String get flowAddSuccess => '+ 成功';

  @override
  String get flowAddFailure => '+ 失败';

  @override
  String get flowAddMethod => '+ 方法';

  @override
  String get flowRemoveMethod => '- 方法';

  @override
  String get flowNewEvent => '新事件';

  @override
  String get flowEventKey => '事件键';

  @override
  String get flowEventDisplayLabel => '显示标签（可选）';

  @override
  String get flowAddSuccessNode => '添加成功节点';

  @override
  String get flowAddFailureNode => '添加失败节点';

  @override
  String get flowAddEvent => '+ 事件';

  @override
  String get flowSelectEvent => '选择事件';

  @override
  String get flowRemoveEvent => '移除事件';

  @override
  String get drawerNavigation => '导航';

  @override
  String get drawerOptionA => '选项 A';

  @override
  String get drawerOptionB => '选项 B';

  @override
  String get drawerOptionC => '选项 C';

  @override
  String get drawerGymProfiles => '健身房档案';

  @override
  String drawerSavedSpaces(int count) {
    return '$count 个已保存空间';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name 已启用';
  }

  @override
  String get drawerActiveProfile => '当前档案';

  @override
  String get drawerTapToSwitch => '点按以切换';

  @override
  String get drawerNewProfile => '新建档案';

  @override
  String get commonAdd => '添加';

  @override
  String get commonRemove => '移除';

  @override
  String get automaticSaving => '正在保存...';

  @override
  String get automaticValuesTab => '数值';

  @override
  String get automaticMethodsTab => '方法';

  @override
  String get automaticGlobalIncrement => '全局递增量';

  @override
  String get automaticAutoSelect => '自动选择';

  @override
  String get automaticManualSelect => '手动选择';

  @override
  String get automaticSkipFirstSet => '跳过第一组？';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return '训练组 $number：$weight × $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return '训练组 $parent.$child：$weight × $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return '无法保存设置：$error';
  }

  @override
  String get automaticIncrementWhen => '满足以下条件时递增（否则递减）：';

  @override
  String get automaticWeightTarget => '完成重量 >= 目标重量';

  @override
  String get automaticRepsTarget => '完成次数 >= 目标次数';

  @override
  String get automaticVolumeTarget => '完成训练量 >= 目标训练量';

  @override
  String get automaticScopeLabel => '成功、未达成和调整按以下单位统计：';

  @override
  String get automaticWorkoutSession => '训练会话';

  @override
  String get automaticPerExercise => '每个动作';

  @override
  String get automaticPerSet => '每组';

  @override
  String get automaticAdjustScope => '调整：';

  @override
  String get automaticAdjustOneSet => '1 组';

  @override
  String get automaticAdjustAllSets => '所有组';

  @override
  String get weightExpandSets => '展开组数';

  @override
  String get weightCollapseSets => '收起组数';

  @override
  String get weightDetails => '详情';

  @override
  String get weightRemoveExerciseTitle => '移除动作';

  @override
  String get weightRemoveExerciseBody => '确定要移除此动作吗？';

  @override
  String get weightSwapExercise => '替换动作';

  @override
  String get weightMakeChangeSet => '创建变更组';

  @override
  String weightSetLabel(int number) {
    return '第 $number 组';
  }

  @override
  String weightLabel(String unit) {
    return '重量（$unit）';
  }

  @override
  String get weightReps => '次数';

  @override
  String get weightRemoveSetTitle => '移除组';

  @override
  String get weightRemoveSetBody => '确定要移除此组吗？';

  @override
  String weightChangeSetLabel(int number) {
    return '变更组 $number';
  }

  @override
  String weightShortLabel(String unit) {
    return '重量（$unit）';
  }

  @override
  String get weightRemoveChangeSetTitle => '移除变更组';

  @override
  String get weightRemoveChangeSetBody => '确定要移除此变更组吗？';

  @override
  String get weightAddChangeSet => '添加变更组';

  @override
  String get weightAddSet => '添加组';

  @override
  String get swapAlreadySelected => '该动作已被选中。';

  @override
  String get swapNeedsProfileEquipment => '此动作需要本资料之外的器械。';

  @override
  String swapLoadFailed(Object error) {
    return '无法加载该替代动作。';
  }

  @override
  String get swapCurrent => '当前';

  @override
  String get swapReplacement => '替代动作';

  @override
  String get swapConfirm => '确认替换';

  @override
  String get swapNoBodypartData => '未找到身体部位数据。';

  @override
  String get swapLoadingSelected => '正在加载所选动作……';

  @override
  String get swapBrowseCatalog => '浏览训练动作目录';

  @override
  String get swapNoEquipment => '未列出器械';

  @override
  String get swapTitle => '替换动作';

  @override
  String get swapFindingMatches => '正在查找相似的身体部位和肌肉匹配...';

  @override
  String get swapChooseReplacement => '选择相似的替代动作。';

  @override
  String get swapFilterProfileEquipment => '按资料器械筛选';

  @override
  String get swapBodypartsHit => '训练到的身体部位';

  @override
  String swapMatch(int percent) {
    return '匹配度 $percent%';
  }

  @override
  String get swapNoReplacements => '暂时未找到相似替代动作。';

  @override
  String get swapNoReplacementsBody => '此动作可能需要更多肌肉或身体部位元数据，才能更好地替换。';

  @override
  String get premadePlansTitle => '预制计划';

  @override
  String get premadeTutorialLengthTitle => '计划时长';

  @override
  String get premadeTutorialLengthBody => '在 1 小时和 2 小时版本之间切换。更长的版本包含更多动作和总训练组数。';

  @override
  String get premadeTutorialEquipmentTitle => '档案器械';

  @override
  String get premadeTutorialEquipmentBody => '开启后，Tonos 会将不可用动作替换为当前健身房档案可执行的类似选项。';

  @override
  String get premadeTutorialLibraryTitle => '计划资料库';

  @override
  String get premadeTutorialLibraryBody => '打开一个训练分化，预览计划，然后将其添加到活跃计划，以便它显示在“训练”中。';

  @override
  String get premadeSelectProfile => '请先选择健身房档案。';

  @override
  String premadePlanAdded(String name) {
    return '已将 $name 添加到活跃计划。';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return '无法添加 $name：$error';
  }

  @override
  String get premadeDescription => '将教练、健身达人和应用精选的训练方案复制到您自己的计划中。添加后，您可以像编辑其他计划一样编辑它们。';

  @override
  String get premadeDiscarding => '正在放弃……';

  @override
  String get premadeReviewPlans => '查看计划';

  @override
  String get allocationSaveChanges => '保存更改';

  @override
  String get allocationSaving => '正在保存';

  @override
  String get allocationInvalidCredit => '请为每个计入值输入零或正数。';

  @override
  String get allocationSaved => '动作分配已保存。';

  @override
  String get allocationSaveFailed => '无法保存动作分配，请重试。';

  @override
  String get allocationSaveOrDiscard => '重置前请保存或放弃您的编辑。';

  @override
  String get allocationTitle => '训练组分配';

  @override
  String get allocationSubtitle => '查看完成的训练组如何贡献给目标肌肉和身体部位。';

  @override
  String get allocationHowTitle => '训练组计入值的工作方式';

  @override
  String get allocationHowBody => '一个主要肌肉通常会从一个已完成训练组获得 1.00 计入值。辅助肌肉获得较少计入值。这会指导解剖部位摘要和建议，但绝不会更改您记录的训练组。';

  @override
  String allocationLoadFailed(String error) {
    return '无法加载动作。$error';
  }

  @override
  String get allocationNoExercises => '暂时没有可用动作。';

  @override
  String get allocationSelectedExercise => '已选动作';

  @override
  String get allocationMuscleCredit => '肌肉贡献值';

  @override
  String get allocationBodypartCredit => '身体部位贡献值';

  @override
  String get allocationNoTargetMuscles => '没有目标肌肉';

  @override
  String get allocationNoBodypartMapping => '没有身体部位映射';

  @override
  String get allocationReset => '重置';

  @override
  String get allocationCredit => '贡献值';

  @override
  String get allocationNoTargetMusclesBody => '此动作尚无目标肌肉数据。';

  @override
  String get allocationMuscleCreditBody => '更改数值即可创建个人分配。它用于肌肉摘要和派生的身体部位重点。';

  @override
  String get allocationNoBodypartMappingBody => '此动作尚无身体部位映射数据。';

  @override
  String get allocationBodypartCreditBody => '自动数值来自肌肉和解剖部位映射。编辑其中一项会创建直接的个人身体部位分配。';

  @override
  String get healthTrendsTitle => '健康趋势';

  @override
  String get healthMetric => '指标';

  @override
  String get healthUnableToLoad => '无法加载测量数据';

  @override
  String get healthNoMeasurements => '尚无测量';

  @override
  String get healthNoMeasurementsBody => '创建指标以开始追踪进度。';

  @override
  String get healthCreateMetric => '创建指标';

  @override
  String healthLogMeasurement(String name) {
    return '记录 $name';
  }

  @override
  String healthEditMeasurement(String name) {
    return '编辑 $name';
  }

  @override
  String get healthTutorialSummaryTitle => '测量概览';

  @override
  String get healthTutorialSummaryBody => '查看最新数值、相对上一条记录的变化，以及现有记录数量。';

  @override
  String get healthTutorialChartTitle => '趋势图表';

  @override
  String get healthTutorialChartBody => '随着您记录更多条目，图表会显示此测量值如何随时间变化。';

  @override
  String get healthTutorialEntriesTitle => '记录';

  @override
  String get healthTutorialEntriesBody => '点按条目可编辑，或移除误记的条目。';

  @override
  String get healthTutorialLogTitle => '记录新条目';

  @override
  String get healthTutorialLogBody => '想添加新的测量记录时，请使用此按钮。';

  @override
  String get healthDeleteEntryTitle => '删除记录？';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return '将移除 $date 的 $value。';
  }

  @override
  String get healthLogEntry => '记录条目';

  @override
  String healthLoadFailed(String error) {
    return '无法加载：$error';
  }

  @override
  String get healthEntries => '记录';

  @override
  String get healthNoEntries => '尚无记录';

  @override
  String healthFirstEntry(String name) {
    return '记录您的第一项 $name 测量。';
  }

  @override
  String get workoutReportLoadFailed => '无法加载训练报告。';

  @override
  String get workoutReportTitle => '训练报告';

  @override
  String get workoutReportAdditionalDetails => '更多详情';

  @override
  String get recommendedSetsEdit => '编辑建议组数';

  @override
  String get recommendedSetsTitle => '建议组数';

  @override
  String get recommendedSetsMinimum => '最小建议组数';

  @override
  String get recommendedSetsMaximum => '最大建议组数';

  @override
  String get recommendedSetsValidNumbers => '请输入有效的组数。';

  @override
  String get recommendedSetsNonNegative => '组数不能为负数。';

  @override
  String get recommendedSetsRange => '最大值必须不小于最小值。';

  @override
  String get workoutReportWorkouts => '训练';

  @override
  String get workoutReportTime => '时间';

  @override
  String get workoutReportVolume => '训练量';

  @override
  String get workoutReportWorkout => '训练';

  @override
  String get workoutReportTotal => '总计';

  @override
  String get databaseSettingsTitle => '数据库设置';

  @override
  String get databaseSettingsSubtitle => '备份、云端媒体、健康检查和开发者导出。';

  @override
  String get databaseBackupRestore => '备份与恢复';

  @override
  String get databaseBackupRestoreSubtitle => '安全地导出或导入本地 Tonos 数据。';

  @override
  String get databaseExportBackup => '导出数据库备份';

  @override
  String get databaseImportBackup => '导入数据库备份';

  @override
  String get databaseImportBackupSubtitle => '从已保存的导出文件替换本地数据。';

  @override
  String get databaseHealth => '健康状况';

  @override
  String get databaseHealthSubtitle => '快速查看数据库大小、架构和搜索索引状态。';

  @override
  String get databaseCheckingHealth => '正在检查数据库健康状况...';

  @override
  String get databaseCheckingHealthSubtitle => '正在读取架构、大小、表和索引。';

  @override
  String get databaseHealthFailed => '数据库健康检查失败';

  @override
  String get databaseMaintenance => '维护';

  @override
  String get databaseMaintenanceSubtitle => '用于检查、优化和存储清理的安全工具。';

  @override
  String get databaseRefreshHealth => '刷新健康状态';

  @override
  String get databaseIntegrityCheck => '运行完整性检查';

  @override
  String get databaseIntegrityCheckSubtitle => '要求 SQLite 验证本地数据库文件。';

  @override
  String get databaseOptimize => '优化数据库';

  @override
  String get databaseCheckpointWal => '检查点 WAL';

  @override
  String get databaseCheckpointWalSubtitle => '将预写日志刷新到数据库文件中。';

  @override
  String get databaseVacuum => '清理数据库';

  @override
  String get databaseVacuumSubtitle => '在大规模删除或导入后回收可用空间。';

  @override
  String get databaseCloudContent => '云端内容';

  @override
  String get databaseCloudContentSubtitle => '管理动作、器械和解剖媒体存储。';

  @override
  String get databaseWifiOnly => '仅 Wi-Fi 下载';

  @override
  String get databaseWifiOnlySubtitle => '新缩略图和视频仅在 Wi-Fi 下下载。缓存媒体仍可离线使用。';

  @override
  String get databaseSyncExerciseMedia => '同步远程动作媒体';

  @override
  String get databaseSyncSharedMedia => '同步共享目录媒体';

  @override
  String get databaseSyncSharedMediaSubtitle => '器械、身体部位和肌肉插图。';

  @override
  String get databaseClearMediaCache => '清除已下载媒体缓存';

  @override
  String get databaseClearMediaCacheSubtitle => '从此设备移除缓存的远程媒体文件。';

  @override
  String get databaseDefinitionExports => '定义导出';

  @override
  String get databaseDefinitionExportsSubtitle => '导出应用定义文件以供检查或工具使用。';

  @override
  String get exerciseEditorTitle => '动作编辑器';

  @override
  String get exerciseEditorLoadFailed => '无法加载动作定义。';

  @override
  String get exerciseEditorChoose => '选择动作';

  @override
  String get exerciseEditorEdit => '编辑定义';

  @override
  String get exerciseEditorCreate => '创建自定义动作';

  @override
  String get exerciseEditorSaveChanges => '保存更改';

  @override
  String get exerciseEditorSaving => '正在保存';

  @override
  String get exerciseEditorMuscles => '肌肉';

  @override
  String get exerciseEditorBodyparts => '身体部位';

  @override
  String get exerciseEditorEquipment => '器械';

  @override
  String get exerciseEditorGuide => '指南';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '已显示 $name。';
  }

  @override
  String get exerciseProgressTrendTitle => '1RM 趋势';

  @override
  String get exerciseProgressTrendBody => '此图表会随时间比较实际记录的 1RM 与估算 1RM。点按数据点可查看精确数值。';

  @override
  String get exerciseProgressRecordings => '记录';

  @override
  String get exerciseProgressRecordingsBody => '每条记录都会打开该次举重所在的训练，方便您查看完整背景。';

  @override
  String get exerciseProgressTitle => '1RM 进度';

  @override
  String get exerciseProgressEmpty => '完成此动作后即可开始建立进度历史。';

  @override
  String get exerciseProgressActual => '实际 1RM';

  @override
  String get exerciseProgressEstimated => '估算 1RM';

  @override
  String get exerciseProgressSessionOpenFailed => '无法打开训练记录。';

  @override
  String get exerciseProgressSessionMissing => '未找到训练记录。';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return '估算 $value';
  }

  @override
  String get exerciseProgressNoActual => '没有实际 1RM';

  @override
  String exerciseProgressActualValue(String value) {
    return '实际 $value';
  }

  @override
  String get musclePercentTitle => '每块肌肉的训练占比';

  @override
  String musclePercentLoadFailed(String error) {
    return '无法加载条目：$error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return '无法更新百分比：$error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return '无法重置为默认值：$error';
  }

  @override
  String musclePercentError(String error) {
    return '错误：$error';
  }

  @override
  String get musclePercentNoExercises => '未定义动作';

  @override
  String get musclePercentEmpty => '尚未设置肌肉百分比';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => '恢复默认值';

  @override
  String get sevenDayFocusTitle => '每周概览';

  @override
  String get sevenDayFocusLoadFailed => '无法加载 7 天训练重点';

  @override
  String get sevenDayFocusEmpty => '过去 7 天没有已完成的身体部位训练组单位。';

  @override
  String get sevenDayFocusMore => '更多';

  @override
  String get pastSessionsWeek => '周';

  @override
  String get pastSessionsMonth => '月';

  @override
  String get pastSessionsYear => '年';

  @override
  String get pastSessionsAll => '全部';

  @override
  String get pastSessionsShow => '显示：';

  @override
  String get pastSessionsFullscreen => '全屏';

  @override
  String pastSessionsError(String error) {
    return '错误：$error';
  }

  @override
  String get pastSessionsEmpty => '尚无训练记录。';

  @override
  String pastSessionsItem(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get historySummaryLoadFailed => '加载历史记录时出错';

  @override
  String get historySummaryWorkouts => '训练次数';

  @override
  String get historySummaryTotalTime => '总时间';

  @override
  String get historySummaryTotalVolume => '总训练量';

  @override
  String get planCoachSkipGuide => '跳过指南';

  @override
  String get planCoachContinue => '继续';

  @override
  String get trainOptimizedSettingsTitle => '优化训练设置';

  @override
  String get trainOptimizedSettingsBudgetBody => '用于为每组分配 3 分钟，并为每个动作开始分配 5 分钟。';

  @override
  String get trainOptimizedSettingsFocusBody => '身体部位选择只适用于您接下来开始的优化训练。';

  @override
  String get trainWorkoutDuration => '训练时长';

  @override
  String get trainMinutesShort => '分';

  @override
  String get trainSetsPerExercise => '每个动作最多组数';

  @override
  String get trainSetsShort => '组';

  @override
  String get trainBodypartFocus => '身体部位重点';

  @override
  String get trainBodypartFocusHelp => '点击一次以偏好某个身体部位，再点一次以避开它，第三次点击即可清除。';

  @override
  String get trainBodypartsLoadFailed => '无法加载身体部位。';

  @override
  String get trainPlanGenerated => '计划已生成。正在打开。';

  @override
  String trainPlansGenerated(int count) {
    return '已生成 $count 个计划。';
  }

  @override
  String get trainActiveWorkoutKept => '另一个训练已处于活动状态，因此保持不变。';

  @override
  String get trainMenuTitle => '训练菜单';

  @override
  String get trainExerciseCatalog => '训练动作目录';

  @override
  String get trainMuscleFilter => '肌肉筛选';

  @override
  String get trainGymSettings => '健身房与训练设置';

  @override
  String get trainTab => '训练';

  @override
  String get trainHistoryTab => '历史';

  @override
  String get trainExercisePresets => '动作预设';

  @override
  String get trainGeneratePlans => '生成自定义计划';

  @override
  String get trainAddPlan => '手动添加预设';

  @override
  String get trainNewPlanFirst => '新预设';

  @override
  String trainNewPlan(int number) {
    return '新预设 $number';
  }

  @override
  String get trainBuildingOptimized => '正在生成优化训练...';

  @override
  String get trainStartOptimized => '开始优化训练';

  @override
  String get trainNewSession => '新会话';

  @override
  String get foodCustomizationTitle => '自定义食物';

  @override
  String get foodCustomizationEditTitle => '编辑食物';

  @override
  String get foodCustomizationName => '食物名称';

  @override
  String get foodCustomizationEnterName => '输入名称';

  @override
  String get foodCustomizationBrand => '品牌';

  @override
  String get foodCustomizationFoodPhoto => '食物照片';

  @override
  String get foodCustomizationLabelPhoto => '标签照片';

  @override
  String get foodCustomizationDensity => '密度（克／毫升）';

  @override
  String get foodCustomizationDensityHelp => '用于将以毫升为单位的份量（杯、汤匙）转换为克，以便计算宏量营养素。';

  @override
  String get foodCustomizationCalories => '热量（kcal）';

  @override
  String get foodCustomizationMacronutrients => '宏量营养素';

  @override
  String get foodCustomizationMicronutrients => '微量营养素';

  @override
  String get foodCustomizationAdditionalComponents => '其他成分';

  @override
  String get foodCustomizationPortionInfo => '份量信息';

  @override
  String get foodCustomizationBasisPortion => '营养数值的份量依据';

  @override
  String get foodCustomizationUsualPortion => '用户通常食用的份量';

  @override
  String get foodCustomizationAddPortion => '添加份量';

  @override
  String get foodCustomizationUnit => '单位';

  @override
  String get foodCustomizationAmount => '数量';

  @override
  String get foodCustomizationWeight => '重量（克）';

  @override
  String get foodCustomizationVolume => '体积（毫升）';

  @override
  String get dashboardArchivedPlans => '已归档计划';

  @override
  String get dashboardActivePlans => '活跃计划';

  @override
  String get dashboardManagePlans => '管理计划';

  @override
  String get dashboardSelectProfilePlans => '选择一个健身房资料以查看其计划。';

  @override
  String get dashboardNoArchivedPlans => '此资料没有已归档计划。';

  @override
  String get dashboardNoActivePlans => '尚无活跃计划。使用编辑图标选择计划。';

  @override
  String dashboardPremadeCount(int count) {
    return '有 $count 个可直接添加的例程。';
  }

  @override
  String get dashboardBrowsePremadePlans => '浏览预制计划';

  @override
  String get dashboardNewPlanFirst => '新计划';

  @override
  String dashboardNewPlan(int number) {
    return '新计划 $number';
  }

  @override
  String get dashboardPlanTools => '计划工具';

  @override
  String get dashboardPlanToolsBody => '根据您的训练偏好创建计划，或从空白计划开始。';

  @override
  String get dashboardManual => '手动';

  @override
  String get dashboardGenerate => '生成';

  @override
  String get dashboardMostUsedExercises => '最常使用的动作';

  @override
  String get dashboardMostUsedExercisesEmpty => '完成训练后，您最常做的动作会显示在这里。';

  @override
  String premadeDiscardFailed(String error) {
    return '无法放弃已添加的计划：$error';
  }

  @override
  String get premadeEquipmentSelectProfile => '请选择健身房档案，以便根据可用器械调整计划。';

  @override
  String get premadeEquipmentExact => '预制计划会完全按原样显示。';

  @override
  String get premadeEquipmentChecking => '正在根据您的档案检查计划动作所需器械……';

  @override
  String get premadeEquipmentMissing => '未找到档案器械，因此预制计划保持不变。';

  @override
  String premadeEquipmentReplacements(int count) {
    return '添加计划时将替换 $count 个不可用动作。';
  }

  @override
  String get premadeEquipmentFits => '计划已适配当前档案的器械。';

  @override
  String get premadeOneHour => '1 小时';

  @override
  String get premadeTwoHours => '2 小时';

  @override
  String premadePlansAvailable(int count) {
    return '有 $count 个计划可用';
  }

  @override
  String get premadeNoTemplates => '尚无计划模板';

  @override
  String premadePlansCount(int count) {
    return '$count 个计划';
  }

  @override
  String get premadeTemplatesLater => '此训练分化的模板以后可在此添加。';

  @override
  String premadeExerciseCount(int count) {
    return '$count 个动作';
  }

  @override
  String premadeSetCount(int count) {
    return '$count 组';
  }

  @override
  String premadeSwappedCount(int count) {
    return '已替换 $count 个';
  }

  @override
  String get premadeAdding => '正在添加';

  @override
  String get premadeChecking => '正在检查';

  @override
  String get premadeProfileSwap => '档案替换';

  @override
  String get healthEntryValueUnitRequired => '请先输入数值和单位。';

  @override
  String get healthDefinitionFieldsRequired => '请输入名称、单位和有效数值。';

  @override
  String get healthUnit => '单位';

  @override
  String get healthNote => '备注';

  @override
  String get healthOptional => '可选';

  @override
  String get healthMetricName => '指标名称';

  @override
  String get healthMetricNameHint => '手臂围、静息心率……';

  @override
  String healthUnitHint(String weightUnit) {
    return '英寸、$weightUnit、%、bpm……';
  }

  @override
  String get healthStartingValue => '起始值';

  @override
  String get healthCreate => '创建';

  @override
  String get exerciseProgressNoRecordings => '尚无记录';

  @override
  String get exerciseEditorDiscardTitle => '放弃更改？';

  @override
  String get exerciseEditorDiscardBody => '您的修改尚未保存。您可以继续编辑或放弃修改。';

  @override
  String get exerciseEditorKeepEditing => '继续编辑';

  @override
  String get exerciseEditorDiscard => '放弃';

  @override
  String get exerciseEditorAddBodyparts => '添加关联身体部位';

  @override
  String get exerciseEditorAddMuscles => '添加关联肌肉';

  @override
  String get exerciseEditorAddEquipment => '添加器械';

  @override
  String get databaseClearMediaTitle => '清除已下载媒体？';

  @override
  String get databaseClearMediaBody => '这会移除缓存的动作、器械和解剖媒体。需要时应用可以重新下载它们。';

  @override
  String get databaseClearCache => '清除缓存';

  @override
  String get databaseCacheCleared => '已清除下载媒体缓存。';

  @override
  String databaseClearCacheFailed(String error) {
    return '清除缓存失败：$error';
  }

  @override
  String get databaseContentEnvironment => '内容环境';

  @override
  String get databaseLoadingEnvironment => '正在加载环境...';

  @override
  String get databaseChangeEnvironment => '更改环境';

  @override
  String get databaseExerciseManifestUrl => '动作媒体清单 URL';

  @override
  String get databaseNoExerciseManifestUrl => '此环境未设置远程清单 URL。';

  @override
  String get databaseOverrideUrl => '覆盖 URL';

  @override
  String get databaseNoManifestSynced => '未同步清单';

  @override
  String databaseManifestVersion(int version) {
    return '清单 v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return '上次检查：$date';
  }

  @override
  String get databaseSharedCatalogMedia => '共享目录媒体';

  @override
  String get databaseSharedMediaNotSynced => '尚未同步。器械、身体部位和肌肉。';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return '清单 v$version。上次检查：$date';
  }

  @override
  String get databaseSharedManifestUrl => '共享媒体清单 URL';

  @override
  String get databaseNoSharedManifestUrl => '此环境未设置远程共享媒体 URL。';

  @override
  String get databaseDownloadedMediaCache => '已下载媒体缓存';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count 个文件，$size';
  }

  @override
  String get databaseLoadBundledManifest => '加载内置清单';

  @override
  String get databaseTutorialFilesTitle => '数据库文件';

  @override
  String get databaseTutorialFilesBody => '导出备份或导入已保存的数据库文件。导入前需要备份。';

  @override
  String get databaseTutorialHealthTitle => '数据库健康状况';

  @override
  String get databaseTutorialHealthBody => '此卡片显示架构版本、数据库大小、表数量和搜索索引健康状况。';

  @override
  String get databaseTutorialMaintenanceTitle => '维护工具';

  @override
  String get databaseTutorialMaintenanceBody => '需要时可使用这些操作进行完整性检查、优化、WAL 检查点或清理。';

  @override
  String get databaseExportSavedTitle => '数据库导出已保存';

  @override
  String get databaseExportSavedBody => '数据库导出已保存到您选择的位置。';

  @override
  String databaseImportBlocked(String message) {
    return '导入被阻止：$message';
  }

  @override
  String get databaseImportBackupCanceled => '导入已取消：未保存备份。';

  @override
  String get databaseImportSucceededTitle => '导入成功';

  @override
  String databaseImportSucceededBody(String name) {
    return '已导入 $name。此前已将旧本地数据库的备份保存到您选择的位置。';
  }

  @override
  String get databaseConfirmImportTitle => '确认导入';

  @override
  String get databaseConfirmImportBody => '这会替换本地数据库。会先写入当前数据库的备份文件。';

  @override
  String databaseImportFile(String name) {
    return '文件：$name';
  }

  @override
  String databaseImportTables(int count) {
    return '表：$count';
  }

  @override
  String databaseImportRows(int count) {
    return '行数：$count';
  }

  @override
  String databaseImportSchema(int version) {
    return '导出架构：v$version';
  }

  @override
  String get databaseImportLegacyFormat => '格式：旧版表映射';

  @override
  String get databaseImportWarnings => '警告：';

  @override
  String get databaseBackupAndImport => '备份与导入';

  @override
  String databaseMaintenanceFailed(String error) {
    return '数据库维护失败：$error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => '请先保存或取消定义更改，再编辑训练组计入值。';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return '移除$type？';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return '要从此动作定义中移除“$name”吗？';
  }

  @override
  String get exerciseEditorKeep => '保留';

  @override
  String get exerciseEditorMuscleOrderTitle => '目标肌肉顺序';

  @override
  String get exerciseEditorMuscleOrderBody => '按动作对肌肉的训练强度排序。这可帮助 Tonos 估算解剖重点并提供更好的动作建议。';

  @override
  String get exerciseEditorExactSetCredit => '精确训练组计入值';

  @override
  String get exerciseEditorExactSetCreditBody => '在动作训练组分配中更改一个训练组对每块肌肉或身体部位贡献的精确计入值。';

  @override
  String get exerciseEditorSetCreditScaling => '训练组计入值缩放';

  @override
  String get exerciseEditorSetCreditScalingBody => '选择此动作评分是否应缩放训练组计入值。';

  @override
  String get exerciseEditorScaleCreditByRating => '按评分缩放计入值';

  @override
  String get exerciseEditorScaleCreditByRatingBody => '将动作评分应用于分析中的训练组总数。';

  @override
  String get exerciseEditorTargetMuscles => '目标肌肉';

  @override
  String get exerciseEditorOrderMusclesHint => '使用箭头按目标强调程度排序肌肉。';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return '当前关联了 $count 块肌肉。';
  }

  @override
  String get exerciseEditorNoTargetMuscles => '尚未关联目标肌肉。';

  @override
  String get exerciseEditorAddTargetMuscles => '添加目标肌肉';

  @override
  String get exerciseEditorMoveUp => '上移';

  @override
  String get exerciseEditorMoveDown => '下移';

  @override
  String get exerciseEditorRemoveMuscle => '移除肌肉';

  @override
  String get exerciseEditorMuscleItem => '肌肉';

  @override
  String get exerciseEditorAssociatedBodyparts => '关联身体部位';

  @override
  String get exerciseEditorAssociatedBodypartsBody => '这些大范围区域会用于身体热力图、每周覆盖情况和器械感知训练建议。';

  @override
  String get exerciseEditorExactBodypartCredit => '精确身体部位计入值';

  @override
  String get exerciseEditorExactBodypartCreditBody => '当一个训练组应按特定比例计入某个身体部位时，请使用动作训练组分配。';

  @override
  String get exerciseEditorBodypartsHint => '添加此动作训练到的每个大范围身体区域。';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return '当前关联了 $count 个身体部位。';
  }

  @override
  String get exerciseEditorNoBodyparts => '尚未关联身体部位。';

  @override
  String get exerciseEditorAutomaticPreview => '自动预览';

  @override
  String get exerciseEditorAutomaticPreviewBody => '根据目标肌肉结构得出的当前重点。';

  @override
  String get exerciseEditorRemoveBodypart => '移除身体部位';

  @override
  String get exerciseEditorBodypartItem => '身体部位';

  @override
  String get exerciseEditorAvailableEquipment => '可用器械';

  @override
  String get exerciseEditorAvailableEquipmentBody => '关联器械决定哪些档案可使用此动作，以及 Tonos 可推荐哪些替代动作。';

  @override
  String get exerciseEditorEquipmentHint => '添加完成此动作所需的每件器械。';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '当前关联了 $count 项器械。';
  }

  @override
  String get exerciseEditorNoEquipment => '尚未关联器械。';

  @override
  String get exerciseEditorRemoveEquipment => '移除器械';

  @override
  String get exerciseEditorEquipmentItem => '器械';

  @override
  String get historySummaryAll => '全部';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '$hours小时 $minutes分';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => '请先添加有效的动作媒体清单 URL。';

  @override
  String databaseContentSyncFailed(String error) {
    return '内容同步失败：$error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return '内置内容同步失败：$error';
  }

  @override
  String get databaseSharedMediaUrlMissing => '此内容环境没有共享媒体 URL。';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return '共享内容同步失败：$error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return '导出 $filename 失败：$error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => '动作媒体清单';

  @override
  String get databaseManifestUrl => '清单 URL';

  @override
  String get databaseClear => '清除';

  @override
  String get databaseNoManifestConfigured => '尚未配置清单 URL。';

  @override
  String get databaseUseEnvironment => '使用此环境';

  @override
  String get dashboardTargetAnatomy => '目标解剖部位';

  @override
  String get dashboardBodyparts => '身体部位';

  @override
  String get dashboardMuscles => '肌肉';

  @override
  String get exerciseEditorCreateCustomTitle => '创建自定义动作';

  @override
  String get exerciseEditorCreateCustomBody => '创建自定义目录定义，然后在保存前添加目标解剖部位和指导说明。';

  @override
  String get exerciseEditorExerciseName => '动作名称';

  @override
  String get exerciseEditorNoEquipmentChoice => '无需器械';

  @override
  String get exerciseEditorOpenedMessage => '已打开动作。添加其目标解剖部位，然后保存。';

  @override
  String exerciseEditorCreateFailed(String error) {
    return '无法创建自定义动作。$error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => '此处可更改的内容';

  @override
  String get exerciseEditorWhatChangesBody => '使用此高级编辑器可更新动作名称、目标解剖部位、器械、动作指导、评分和参考媒体。每组的精确计入值单独管理，以保持整个应用的一致性。';

  @override
  String get exerciseEditorChooseCatalog => '从目录中选择一个动作';

  @override
  String get exerciseEditorRating => '评分';

  @override
  String get databaseNever => '从不';

  @override
  String databaseExportDefinition(String filename) {
    return '导出 $filename';
  }

  @override
  String get exerciseEditorAddMedia => '添加媒体';

  @override
  String get exerciseEditorEditMedia => '编辑媒体';

  @override
  String get exerciseEditorMediaImage => '图片';

  @override
  String get exerciseEditorMediaVideo => '视频';

  @override
  String get exerciseEditorMediaLink => '链接';

  @override
  String get exerciseEditorMediaType => '类型';

  @override
  String get exerciseEditorMediaTitle => '标题';

  @override
  String get exerciseEditorMediaTitleHint => '可选显示标签';

  @override
  String get exerciseEditorMediaRemoteUrl => '远程 URL';

  @override
  String get exerciseEditorMediaThumbnailUrl => '缩略图 URL';

  @override
  String get exerciseEditorMediaThumbnailHint => '可选的图片预览 URL';

  @override
  String get exerciseEditorSelectBeforeMedia => '请先选择一个现有动作，再附加媒体。';

  @override
  String get exerciseEditorFormGuide => '动作指南';

  @override
  String get exerciseEditorFormGuideBody => '这些说明会显示在动作详情面板中，帮助用户安全地准备、执行和理解该动作。';

  @override
  String get exerciseEditorGuidance => '指导说明';

  @override
  String get exerciseEditorGuidanceEditing => '编写清晰、实用的提示。更改会暂存，直到保存后才生效。';

  @override
  String get exerciseEditorGuidanceReadOnly => '当前动作说明和提示。';

  @override
  String get exerciseEditorSetUp => '准备';

  @override
  String get exerciseEditorSetUpHint => '起始姿势、器械设置和安全提示。';

  @override
  String get exerciseEditorHowToPerform => '如何执行';

  @override
  String get exerciseEditorHowToPerformHint => '关键动作步骤和活动范围。';

  @override
  String get exerciseEditorCoachingTips => '教练提示';

  @override
  String get exerciseEditorCoachingTipsHint => '有用的提示、常见错误和变式。';

  @override
  String get exerciseEditorReferenceMedia => '参考媒体';

  @override
  String get exerciseEditorReferenceMediaBody => '使用媒体链接保存私人参考资料。由内容同步流程管理的目录媒体可随时刷新。';

  @override
  String get exerciseEditorMediaLinks => '媒体链接';

  @override
  String get exerciseEditorMediaLinksEditing => '添加或更新远程图片、视频或参考链接。';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return '当前已关联 $count 项媒体。';
  }

  @override
  String get exerciseEditorNoReferenceMedia => '尚未关联参考媒体。';

  @override
  String get exerciseEditorAddMediaLink => '添加媒体链接';

  @override
  String get exerciseEditorRemoveMedia => '移除媒体';

  @override
  String get exerciseEditorMediaLinkItem => '媒体链接';

  @override
  String exerciseEditorMediaReference(String type) {
    return '$type参考资料';
  }

  @override
  String get bengaliBangladeshLanguage => '孟加拉语（孟加拉国）';

  @override
  String get simplifiedChineseLanguage => '简体中文';

  @override
  String get hindiLanguage => '印地语';

  @override
  String get spanishLanguage => '西班牙语';

  @override
  String get onboardingWeightHistoryTitle => '体重历史';

  @override
  String get onboardingWeightHistorySubtitle => '这些信息有助于更合理地估算营养目标。';

  @override
  String get onboardingPreviouslyHeavier => '您以前的体重是否曾比当前体重高 10 磅以上？';

  @override
  String get onboardingWeightTrendTitle => '当前体重趋势';

  @override
  String get onboardingWeightTrendGaining => '体重增加';

  @override
  String get onboardingWeightTrendLosing => '体重下降';

  @override
  String get onboardingWeightTrendMaintaining => '体重维持';

  @override
  String get onboardingNotSure => '不确定';

  @override
  String get onboardingBodyFatEstimateTitle => '体脂估算';

  @override
  String get onboardingBodyFatEstimateSubtitle => '请选择最接近的视觉估算，无需十分精确。';

  @override
  String get onboardingNutritionPreferencesTitle => '营养偏好';

  @override
  String get onboardingNutritionPreferencesSubtitle => '这些偏好会影响设置完成后的营养建议。';

  @override
  String get onboardingPreferredDiet => '偏好的饮食方式';

  @override
  String get onboardingDietBalanced => '均衡';

  @override
  String get onboardingDietLowFat => '低脂';

  @override
  String get onboardingDietLowCarb => '低碳水';

  @override
  String get onboardingDietKeto => '生酮';

  @override
  String get onboardingCalorieFloor => '最低热量';

  @override
  String get onboardingCalorieFloorHint => '每日最低千卡';

  @override
  String get onboardingTrainingDuringProgram => '计划期间的训练';

  @override
  String get onboardingTrainingNone => '无';

  @override
  String get onboardingTrainingLifting => '力量训练';

  @override
  String get onboardingTrainingCardio => '有氧训练';

  @override
  String get onboardingTrainingLiftingAndCardio => '力量和有氧训练';

  @override
  String get onboardingProteinPreference => '偏好的蛋白质摄入量';

  @override
  String get onboardingProteinLow => '低';

  @override
  String get onboardingProteinModerate => '中等';

  @override
  String get onboardingProteinHigh => '高';

  @override
  String get onboardingProteinVeryHigh => '很高';

  @override
  String get onboardingGoalPaceTitle => '目标进度';

  @override
  String get onboardingGoalPaceSubtitle => '预览目标体重和每周目标速度。';

  @override
  String get onboardingInitialDailyBudget => '初始每日热量预算';

  @override
  String get onboardingProjectedEndDate => '预计结束日期';

  @override
  String get onboardingTargetWeight => '目标体重';

  @override
  String get onboardingTargetGoalRate => '目标速度';

  @override
  String get onboardingPerWeek => '每周';

  @override
  String get onboardingPerMonth => '每月';

  @override
  String get exerciseProgressTrackExercise => '跟踪一项动作';

  @override
  String get exerciseProgressTrackExerciseBody => '选择一项动作，在此查看其 1RM 趋势。';

  @override
  String get healthCustomMetric => '自定义指标';

  @override
  String get healthLatest => '最新';

  @override
  String get healthNoEntry => '暂无记录';

  @override
  String get healthNotTrackedYet => '尚未跟踪';

  @override
  String get healthChange => '变化';

  @override
  String get healthNeedTwoEntries => '需要 2 条记录';

  @override
  String get healthVersusPrevious => '与上一条相比';

  @override
  String get healthRecords => '记录';

  @override
  String get presetEstimatedTime => '预计时间';

  @override
  String get presetNoFocusData => '暂无重点数据。';

  @override
  String get presetFocusPreviewHelp => '添加包含身体部位数据的负重动作，以预览计划重点。';

  @override
  String get dashboardReorderHelp => '拖动各部分，按最适合您的顺序排列。';

  @override
  String get exerciseEditorCachedLocally => '已缓存到本地';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return '已同步 $count 条动作媒体记录（v$version）。';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return '已加载内置动作媒体清单（v$version）。';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return '已同步 $count 条器材和解剖媒体记录（v$version）。';
  }

  @override
  String get databaseHealthSchema => '架构';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / 目标 v$target';
  }

  @override
  String get databaseHealthSize => '大小';

  @override
  String get databaseHealthJournal => '日志';

  @override
  String get databaseHealthTables => '数据表';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables 个表，$indexes 个索引，$triggers 个触发器';
  }

  @override
  String get databaseHealthFoodSearch => '食物搜索';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods 种食物，$rows 行 FTS 数据';
  }

  @override
  String get databaseHealthPath => '路径';

  @override
  String get dashboardWorkoutInProgress => '训练进行中';

  @override
  String get dashboardNoSavedPlans => '此健身房资料尚未保存计划。';

  @override
  String get exerciseProgressOneRepMax => '单次最大重量';

  @override
  String get exerciseProgressEstimatedOneRepMax => '估算 1RM';

  @override
  String get onboardingPageWeight => '体重';

  @override
  String get onboardingPageBodyFat => '体脂';

  @override
  String get onboardingPageNutrition => '营养';

  @override
  String get onboardingPageGoal => '目标';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return '本周 $count/$total';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return '总计 $count';
  }

  @override
  String get dashboardVisualBodyFat => '目测体脂';

  @override
  String get dashboardNewMetric => '新指标';

  @override
  String get dashboardCurrentMetrics => '当前指标';

  @override
  String get workoutReportDay => '天';

  @override
  String get workoutReportDays => '天';

  @override
  String get workoutReportWeek => '周';

  @override
  String get workoutReportMonth => '月';

  @override
  String workoutReportAveragePer(String period) {
    return '平均 / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => '次训练';

  @override
  String get workoutReportLongestStreak => '最长连续记录';

  @override
  String get workoutReportMostActive => '最活跃';

  @override
  String get workoutReportNoSessions => '暂无训练';

  @override
  String get workoutReportWeekday => '星期';

  @override
  String workoutReportMetricSemantics(String label) {
    return '$label 报告指标';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '已记录 $unit';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$date的 $unit';
  }

  @override
  String get profileDiagnosticsTitle => '诊断与隐私';

  @override
  String get profileDiagnosticsSubtitle => '版本、崩溃报告许可、同步历史和数据删除。';

  @override
  String get diagnosticsTitle => '诊断与隐私';

  @override
  String get diagnosticsSubtitle => '了解并控制发行版诊断。';

  @override
  String get diagnosticsAppSection => '应用信息';

  @override
  String get diagnosticsAppSectionSubtitle => '报告问题时可提供帮助。';

  @override
  String get diagnosticsVersion => '版本和构建号';

  @override
  String get diagnosticsLoading => '正在加载...';

  @override
  String get diagnosticsUnavailable => '不可用';

  @override
  String get diagnosticsCrashSection => '匿名诊断';

  @override
  String get diagnosticsCrashSectionSubtitle => '针对应用故障和媒体同步的可选分类报告。';

  @override
  String get diagnosticsCrashReporting => '共享匿名诊断';

  @override
  String get diagnosticsCrashUnavailable => '此构建未配置，无法共享匿名诊断。';

  @override
  String get diagnosticsCrashEnabledBody => '已在您同意后启用。关闭后会请求删除 Tonos 保留的报告。';

  @override
  String get diagnosticsCrashDisabledBody => '默认关闭。仅在您愿意帮助诊断发行版本问题时开启。';

  @override
  String get diagnosticsPrivacyPromiseTitle => '隐私保护设计';

  @override
  String get diagnosticsPrivacyPromiseBody => '报告仅包含应用版本、构建号、平台、批准的类别、结果和粗略区间。绝不包含错误消息、堆栈跟踪、姓名、健康数据、数据库内容、屏幕截图、网络地址、跟踪信息或分析数据。';

  @override
  String get diagnosticsSyncSection => '内容同步历史';

  @override
  String get diagnosticsSyncSectionSubtitle => '最近 30 次媒体清单结果仅保存在此设备上。';

  @override
  String get diagnosticsNoSyncEvents => '暂无同步诊断';

  @override
  String get diagnosticsNoSyncEventsBody => '练习和共享媒体的同步结果会显示在这里，不含网址或个人数据。';

  @override
  String get diagnosticsClearHistory => '清除同步历史';

  @override
  String get diagnosticsClearHistoryBody => '删除本地保存的所有同步诊断条目。';

  @override
  String get diagnosticsHistoryCleared => '同步诊断历史已清除。';

  @override
  String get diagnosticsExerciseMedia => '练习媒体';

  @override
  String get diagnosticsSharedMedia => '共享媒体';

  @override
  String get diagnosticsRemoteSource => '远程';

  @override
  String get diagnosticsBundledSource => '内置';

  @override
  String get diagnosticsSyncSucceeded => '成功';

  @override
  String get diagnosticsSyncFailed => '失败';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation：$outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration 毫秒 • 清单 $version • $items 项';
  }

  @override
  String get diagnosticsPrivacySection => '您的数据';

  @override
  String get diagnosticsPrivacySectionSubtitle => '本地存储、保留和删除。';

  @override
  String get diagnosticsLocalDataTitle => '健身数据保留在本地';

  @override
  String get diagnosticsLocalDataBody => '除非您自行导出备份，否则训练、营养、身体指标和个人资料记录只保存在此设备的应用数据库中。';

  @override
  String get diagnosticsDeletionTitle => '删除诊断和应用数据';

  @override
  String get diagnosticsDeletionBody => '清除上方同步历史并关闭匿名诊断，以请求删除此安装发送的报告。在设备设置中清除 Tonos 存储或卸载 Tonos，即可删除本地数据库和缓存。';

  @override
  String get diagnosticsSendTestReport => '发送受控诊断事件';

  @override
  String get diagnosticsSendTestReportBody => '仅在明确启用测试的构建中可用。发送一个固定的允许事件。';

  @override
  String get diagnosticsTestReportSent => '受控诊断事件已发送。';

  @override
  String get diagnosticsTestReportFailed => '无法发送诊断事件。请检查构建配置和网络连接。';

  @override
  String get diagnosticsDeleteShared => '删除已共享的诊断信息';

  @override
  String get diagnosticsDeleteSharedBody => '请求删除此安装可证明已发送的报告。提供商的恢复历史可能会将已删除行保留最多 30 天。';

  @override
  String get diagnosticsSharedDeleted => '已请求删除已共享的诊断信息。';

  @override
  String get diagnosticsSharedDeletionPending => '部分删除请求会在应用连接网络后再次打开时重试。';

  @override
  String get workoutDurabilityRestoreWarning => 'Tonos 无法检查是否有已保存的训练。请重试后再开始新的训练。';

  @override
  String get workoutDurabilityDraftSaveWarning => '训练备份尚未更新。请保持 Tonos 打开并重试，以便安全恢复本次训练。';

  @override
  String get workoutDurabilityProgressionWarning => '训练已保存，但计划进度更新仍在等待中。存储可用后请重试。';

  @override
  String get databaseConfirmExportTitle => '导出私人数据？';

  @override
  String get databaseConfirmExportBody => '此备份是未加密的 JSON 文件，可能包含你的训练、营养、身体测量、个人资料和偏好设置。请只将其保存到可信的位置。';

  @override
  String get databaseContinueExport => '仍要导出';

  @override
  String get databaseExportFailedSafe => '无法创建数据库导出文件。你的应用数据未发生更改。';

  @override
  String get databaseImportFileTooLarge => '此导入文件过大。请选择小于 25 MB 的数据库备份。';

  @override
  String get databaseImportBlockedSafe => '无法导入此数据库备份。你当前的应用数据未发生更改。';

  @override
  String get databaseImportFailedSafe => '数据库导入未完成。你当前的应用数据已安全保留。';

  @override
  String get speedDialLogFood => '记录食物';

  @override
  String get speedDialLogMeasurement => '记录测量';

  @override
  String get healthTapToLog => '点击 + 以记录';
}
