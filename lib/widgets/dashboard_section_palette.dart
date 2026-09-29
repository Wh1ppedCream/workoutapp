import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

const _dashboardBlueCategory = Color(0xFF64B5F6);
const _dashboardGreenCategory = Color(0xFF81C784);
const _dashboardOrangeCategory = Color(0xFFFFB74D);
const _dashboardTealCategory = Color(0xFF4DB6AC);
const _dashboardLavenderCategory = Color(0xFFCE93D8);
const _dashboardSlateCategory = Color(0xFF90A4AE);
const _dashboardPurpleCategory = Color(0xFFBA68C8);
const _dashboardFallbackCategory = Color(0xFF9E9E9E);

const dashboardHeroAccent = _dashboardBlueCategory;
const dashboardMeasurementActionAccent = _dashboardTealCategory;
const dashboardTrainingActionAccent = _dashboardGreenCategory;

class DashboardSectionDetails {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const DashboardSectionDetails({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

DashboardSectionDetails dashboardSectionDetails(
  AppLocalizations strings,
  String id,
) {
  switch (id) {
    case 'quickActions':
      return DashboardSectionDetails(
        title: strings.dashboardSectionQuickActionsTitle,
        description: strings.dashboardSectionQuickActionsBody,
        icon: Icons.bolt_outlined,
        color: _dashboardBlueCategory,
      );
    case 'training':
      return DashboardSectionDetails(
        title: strings.dashboardSectionTrainingTitle,
        description: strings.dashboardSectionTrainingBody,
        icon: Icons.fitness_center,
        color: _dashboardGreenCategory,
      );
    case 'nutritionDash':
      return DashboardSectionDetails(
        title: strings.dashboardSectionNutritionTitle,
        description: strings.dashboardSectionNutritionBody,
        icon: Icons.restaurant_outlined,
        color: _dashboardOrangeCategory,
      );
    case 'dataRecords':
      return DashboardSectionDetails(
        title: strings.dashboardSectionDataRecordsTitle,
        description: strings.dashboardSectionDataRecordsBody,
        icon: Icons.calendar_month_outlined,
        color: _dashboardBlueCategory,
      );
    case 'weeklyFocus':
      return DashboardSectionDetails(
        title: strings.dashboardSectionWeeklyFocusTitle,
        description: strings.dashboardSectionWeeklyFocusBody,
        icon: Icons.accessibility_new,
        color: _dashboardTealCategory,
      );
    case 'workoutMetrics':
      return DashboardSectionDetails(
        title: strings.dashboardSectionWorkoutReportTitle,
        description: strings.dashboardSectionWorkoutReportBody,
        icon: Icons.show_chart_outlined,
        color: _dashboardBlueCategory,
      );
    case 'exerciseProgress':
      return DashboardSectionDetails(
        title: strings.dashboardSectionExerciseProgressTitle,
        description: strings.dashboardSectionExerciseProgressBody,
        icon: Icons.trending_up_rounded,
        color: _dashboardLavenderCategory,
      );
    case 'historySummary':
      return DashboardSectionDetails(
        title: strings.dashboardSectionHistoryTitle,
        description: strings.dashboardSectionHistoryBody,
        icon: Icons.history_rounded,
        color: _dashboardBlueCategory,
      );
    case 'healthTrends':
      return DashboardSectionDetails(
        title: strings.dashboardSectionHealthTrendsTitle,
        description: strings.dashboardSectionHealthTrendsBody,
        icon: Icons.monitor_heart_outlined,
        color: _dashboardGreenCategory,
      );
    case 'recentWorkouts':
      return DashboardSectionDetails(
        title: strings.dashboardSectionRecentWorkoutsTitle,
        description: strings.dashboardSectionRecentWorkoutsBody,
        icon: Icons.event_note_outlined,
        color: _dashboardOrangeCategory,
      );
    case 'activePlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionActivePlansTitle,
        description: strings.dashboardSectionActivePlansBody,
        icon: Icons.assignment_turned_in_outlined,
        color: _dashboardGreenCategory,
      );
    case 'archivedPlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionArchivedPlansTitle,
        description: strings.dashboardSectionArchivedPlansBody,
        icon: Icons.inventory_2_outlined,
        color: _dashboardSlateCategory,
      );
    case 'premadePlans':
      return DashboardSectionDetails(
        title: strings.dashboardSectionPremadePlansTitle,
        description: strings.dashboardSectionPremadePlansBody,
        icon: Icons.auto_stories_outlined,
        color: _dashboardLavenderCategory,
      );
    case 'planTools':
      return DashboardSectionDetails(
        title: strings.dashboardSectionPlanToolsTitle,
        description: strings.dashboardSectionPlanToolsBody,
        icon: Icons.add_task_outlined,
        color: _dashboardLavenderCategory,
      );
    case 'exerciseCatalog':
      return DashboardSectionDetails(
        title: strings.dashboardSectionCatalogTitle,
        description: strings.dashboardSectionCatalogBody,
        icon: Icons.menu_book_outlined,
        color: _dashboardBlueCategory,
      );
    case 'targetAnatomy':
      return DashboardSectionDetails(
        title: strings.dashboardSectionAnatomyTitle,
        description: strings.dashboardSectionAnatomyBody,
        icon: Icons.bubble_chart_outlined,
        color: _dashboardPurpleCategory,
      );
    default:
      return DashboardSectionDetails(
        title: strings.dashboardSectionFallbackTitle,
        description: strings.dashboardSectionFallbackBody,
        icon: Icons.dashboard_outlined,
        color: _dashboardFallbackCategory,
      );
  }
}
