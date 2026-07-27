import '../providers/nav_bar_config.dart';
import 'generated/app_localizations.dart';

extension LocalizedTabItem on TabItem {
  String localizedTitle(AppLocalizations strings) {
    return switch (this) {
      TabItem.train => strings.tabTrain,
      TabItem.train2 => strings.tabTrainSecondary,
      TabItem.catalog => strings.tabCatalog,
      TabItem.history => strings.tabLogbook,
      TabItem.measurementsTrends => strings.tabProgress,
      TabItem.profile => strings.tabProfile,
      TabItem.dashboard => strings.tabDashboard,
      TabItem.nutrition => strings.tabNutrition,
      TabItem.nutritionLog => strings.tabNutritionLog,
      TabItem.combinedHistory => strings.tabCombinedHistory,
      TabItem.formAndPosing => strings.tabFormAndPosing,
    };
  }
}
