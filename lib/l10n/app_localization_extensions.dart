import '../models/exercise_allocation_models.dart';
import '../models/unit_preference.dart';
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

extension LocalizedExerciseAllocationSource on ExerciseAllocationSource {
  String localizedLabel(AppLocalizations strings) {
    return switch (this) {
      ExerciseAllocationSource.automatic => strings.allocationSourceAutomatic,
      ExerciseAllocationSource.creatorDefault =>
        strings.allocationSourceCreatorDefault,
      ExerciseAllocationSource.personalOverride =>
        strings.allocationSourcePersonalOverride,
      ExerciseAllocationSource.legacy => strings.allocationSourceLegacy,
    };
  }
}

extension LocalizedWeightUnit on WeightUnit {
  String localizedLabel(AppLocalizations strings) {
    return switch (this) {
      WeightUnit.pounds => strings.onboardingPounds,
      WeightUnit.kilograms => strings.onboardingKilograms,
    };
  }
}
