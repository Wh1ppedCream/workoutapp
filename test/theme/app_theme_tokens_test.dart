import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_generation_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';

void main() {
  test(
    'settings consumers keep tab and scope shapes independent from inputs',
    () {
      for (final name in [
        'exercise_analytics_screen',
        'exercise_editor_screen',
      ]) {
        final source =
            File('lib/screens/profile/settings/$name.dart').readAsStringSync();
        expect(source, contains('borderRadius: shapes.settingsTabIndicator'));
        expect(source, isNot(contains('shapes.settingsInput')));
      }
      for (final name in ['flow_methods_page', 'workout_progress_flows_page']) {
        final source =
            File('lib/screens/profile/settings/$name.dart').readAsStringSync();
        expect(source, contains('shapes.settingsScopeIcon'));
        expect(source, isNot(contains('shapes.settingsInput')));
      }
    },
  );
  test('settings consumers resolve the new semantic ownership roles', () {
    final databaseSource =
        File(
          'lib/screens/profile/settings/database_settings_page.dart',
        ).readAsStringSync();
    expect(databaseSource, contains('semantic.databaseHealthy'));
    expect(databaseSource, contains('semantic.databaseWarning'));
    expect(databaseSource, isNot(contains('Colors.green')));
    expect(databaseSource, isNot(contains('Colors.orange')));

    final editorSource =
        File(
          'lib/screens/profile/settings/exercise_editor_screen.dart',
        ).readAsStringSync();
    expect(editorSource, contains('shapes.settingsTitleCard'));
    expect(editorSource, contains('surfaces.settingsHero'));
    expect(editorSource, contains('SettingsInlineActionButton('));
  });
  test(
    'specialized settings consumers use shared action and field recipes',
    () {
      for (final name in [
        'bodypart_ranking_screen',
        'muscle_ranking_screen',
        'bodypart_muscle_mapping_screen',
        'exercise_editor_screen',
        'goal_manual_entry_page',
      ]) {
        final source =
            File('lib/screens/profile/settings/$name.dart').readAsStringSync();
        expect(source, contains('SettingsSaveBar('), reason: name);
      }

      for (final name in [
        'bodypart_muscle_mapping_screen',
        'goal_manual_entry_page',
        'volume_boundaries_screen',
        'exercise_analytics_screen',
      ]) {
        final source =
            File('lib/screens/profile/settings/$name.dart').readAsStringSync();
        expect(source, contains('settingsFieldDecoration('), reason: name);
      }
    },
  );
  test('settings route slices retain shared ownership boundaries', () {
    String source(String name) =>
        File('lib/screens/profile/settings/$name.dart').readAsStringSync();

    final appearanceSource = source('ui_appearance_settings_page');
    expect(appearanceSource, contains('SettingsPageScaffold('));
    expect(appearanceSource, contains('SettingsSection('));
    expect(appearanceSource, contains('SettingsSwitchTile('));
    expect(appearanceSource, contains('SettingsValueText('));

    final userInformationSource = source('user_information_settings_page');
    expect(userInformationSource, contains('SettingsSaveBar('));
    expect(userInformationSource, contains('settingsInputDecoration('));
    expect(userInformationSource, contains('SettingsSection('));

    final navigationSource = source('nav_bar_settings_page');
    expect(navigationSource, contains('SettingsSaveBar('));
    expect(navigationSource, contains('decorated: false'));
    expect(navigationSource, contains('proxyDecorator'));
    expect(navigationSource, contains('Colors.transparent'));

    final profileSource = source('profile_page');
    expect(profileSource, contains('settingsTilesWithDividers('));
    expect(profileSource, contains('SettingsStatusBadge('));

    final databaseSource = source('database_settings_page');
    expect(databaseSource, contains('SettingsPageScaffold('));
    expect(databaseSource, contains('SettingsSection('));
    expect(databaseSource, contains('semantic.databaseHealthy'));

    final diagnosticsSource = source('diagnostics_settings_page');
    expect(diagnosticsSource, contains('SettingsSection('));
    expect(diagnosticsSource, contains('settingsTilesWithDividers('));

    final tutorialsSource = source('tutorials_settings_page');
    expect(tutorialsSource, contains('SettingsExpansionSection('));

    final editorSource = source('exercise_editor_screen');
    expect(editorSource, contains('SettingsSaveBar('));
    expect(editorSource, contains('settingsFieldDecoration('));
    expect(editorSource, contains('SettingsInlineActionButton('));
    expect(editorSource, contains('AlertDialog('));
  });
  test('settings label consumers use shared pill and badge primitives', () {
    final flowMethodsSource =
        File(
          'lib/screens/profile/settings/flow_methods_page.dart',
        ).readAsStringSync();
    final progressFlowsSource =
        File(
          'lib/screens/profile/settings/workout_progress_flows_page.dart',
        ).readAsStringSync();
    final tutorialsSource =
        File(
          'lib/screens/profile/settings/tutorials_settings_page.dart',
        ).readAsStringSync();
    final analyticsSource =
        File(
          'lib/screens/profile/settings/exercise_analytics_screen.dart',
        ).readAsStringSync();

    expect(flowMethodsSource, contains('SettingsLegendChip('));
    expect(flowMethodsSource, contains('SettingsCountBadge('));
    expect(flowMethodsSource, contains('flowTokens.profileScope'));
    expect(flowMethodsSource, contains('flowTokens.planScope'));
    expect(flowMethodsSource, contains('flowTokens.addSetAction'));
    expect(flowMethodsSource, isNot(contains('class _LegendChip')));
    expect(flowMethodsSource, isNot(contains('class _CountBadge')));
    expect(progressFlowsSource, contains('SettingsLegendChip('));
    expect(progressFlowsSource, contains('flowTokens.profileScope'));
    expect(progressFlowsSource, contains('flowTokens.planScope'));
    expect(progressFlowsSource, isNot(contains('class _LegendChip')));
    expect(tutorialsSource, contains('SettingsAccentPill('));
    expect(tutorialsSource, isNot(contains('class _ResetPill')));
    expect(analyticsSource, contains('SettingsAccentPill('));
  });
  test('Train and workout completion consumers use focused theme roles', () {
    final trainSource =
        File('lib/screens/exercise/train_page.dart').readAsStringSync();
    expect(trainSource, contains('semantic.startWorkoutAction'));
    expect(trainSource, contains('semantic.onStartWorkoutAction'));
    expect(trainSource, contains('dataVisualization.tertiarySeries'));
    expect(
      trainSource,
      contains('ProfileIdentityPalette.currentProfileAvatar'),
    );
    expect(trainSource, contains('surfaces.trainTabSurfaceOpacity'));
    expect(trainSource, contains('surfaces.splitWorkoutDividerOpacity'));
    expect(trainSource, isNot(contains('Colors.lightGreen')));
    expect(trainSource, isNot(contains('Colors.green.shade700')));
    expect(trainSource, isNot(contains('color: Colors.purple')));

    final weightCardSource =
        File('lib/widgets/weight_card.dart').readAsStringSync();
    expect(weightCardSource, contains('semantic.workoutCompleted'));
    expect(weightCardSource, contains('surfaces.workoutCardCompleteFill'));
    expect(weightCardSource, contains('surfaces.workoutSetCompleteFill'));
    expect(weightCardSource, contains('surfaces.workoutChangeSetOutline'));
    expect(weightCardSource, contains('shapes.control'));
    expect(weightCardSource, contains('context.shapeTokens.mediaThumbnail'));
    expect(weightCardSource, isNot(contains('Colors.green.withAlpha')));

    final completionSource =
        File('lib/widgets/session_complete_sheet.dart').readAsStringSync();
    expect(completionSource, contains('semantic.completionAccent'));
    expect(completionSource, contains('dataVisualization.sessionExercises'));
    expect(completionSource, contains('dataVisualization.sessionSets'));
    expect(completionSource, contains('dataVisualization.sessionDuration'));
    expect(completionSource, contains('dataVisualization.sessionVolume'));
    expect(completionSource, contains('shapes.workoutSection'));
    expect(
      completionSource,
      contains('context.surfaceTokens.completionMetricFill'),
    );
    expect(
      completionSource,
      contains('context.surfaceTokens.completionMetricBorder'),
    );
    expect(
      completionSource,
      contains('context.surfaceTokens.completionSetFill'),
    );
    expect(
      completionSource,
      contains('context.surfaceTokens.completionExerciseFill'),
    );
    expect(
      completionSource,
      contains('context.surfaceTokens.completionExerciseBorder'),
    );

    final optimizedSource =
        File(
          'lib/screens/exercise/optimized_workout_settings_page.dart',
        ).readAsStringSync();
    expect(optimizedSource, contains('semantic.startWorkoutAction'));
    expect(optimizedSource, contains('semantic.onStartWorkoutAction'));
    expect(optimizedSource, contains('surfaces.optimizedAction'));
    expect(optimizedSource, contains('shapes.pill'));

    final presetDetailSource =
        File(
          'lib/screens/exercise/preset_detail_screen.dart',
        ).readAsStringSync();
    expect(presetDetailSource, contains('semantic.editingActive'));
    expect(presetDetailSource, contains('semantic.editingInactive'));

    final planManagementSource =
        File(
          'lib/screens/exercise/plan_management_page.dart',
        ).readAsStringSync();
    expect(planManagementSource, contains('surfaces.planCard'));
    expect(planManagementSource, contains('shapes.planCard'));

    final presetsLoadedSource =
        File('lib/widgets/presets_loaded.dart').readAsStringSync();
    expect(presetsLoadedSource, contains('shapes.card'));
    expect(presetsLoadedSource, contains('PlanIdentityPalette.colors'));
    expect(presetsLoadedSource, contains('surfaces.planRevealBorderOpacity'));
    expect(presetsLoadedSource, isNot(contains('static const _palette')));

    final detailSource =
        File(
          'lib/screens/exercise/session_detail_screen.dart',
        ).readAsStringSync();
    expect(detailSource, contains('semantic.editingActive'));
    expect(detailSource, contains('surfaces.sessionSummary'));

    final badgesSource =
        File('lib/widgets/workout_record_badges.dart').readAsStringSync();
    expect(badgesSource, contains('dataVisualization.recordMonthly'));
    expect(badgesSource, contains('dataVisualization.recordAllTime'));
    expect(badgesSource, contains('dataVisualization.firstRecord'));
    expect(badgesSource, contains('shapes.recordBadge'));
    expect(badgesSource, contains('shapes.recordBadgeCompact'));

    final premadePlansSource =
        File('lib/screens/exercise/premade_plans_page.dart').readAsStringSync();
    expect(premadePlansSource, contains('surfaces.planFilter'));
    expect(premadePlansSource, contains('surfaces.planDuration'));
    expect(premadePlansSource, contains('surfaces.planGroup'));
    expect(premadePlansSource, contains('surfaces.planActionBar'));
    expect(premadePlansSource, contains('shapes.pill'));
    expect(premadePlansSource, contains('shapes.planCard'));
    expect(premadePlansSource, contains('motion.quick'));
    expect(premadePlansSource, contains('surfaces.planSwapBadgeOpacity'));
    expect(premadePlansSource, isNot(contains('Duration(milliseconds: 180)')));
    expect(premadePlansSource, isNot(contains('withValues(alpha: 0.55)')));

    final automaticFlowSource =
        File(
          'lib/screens/exercise/auto_preset_flow_screen.dart',
        ).readAsStringSync();
    expect(automaticFlowSource, contains('surfaces.flowControl'));
    expect(
      automaticFlowSource,
      isNot(contains('context.dataVisualizationTokens.neutral')),
    );
    expect(
      automaticFlowSource,
      contains('final loopback = context.flowTokens.loopback;'),
    );
    expect(automaticFlowSource, contains('shapes.flowControl'));
    expect(automaticFlowSource, contains('shapes.flowIcon'));
    expect(automaticFlowSource, contains('surfaces.flowErrorBorderOpacity'));
    expect(automaticFlowSource, contains('surfaces.flowControlBorderOpacity'));
    expect(
      automaticFlowSource,
      contains('surfaces.flowControlCollapsedOpacity'),
    );
    expect(
      automaticFlowSource,
      contains('surfaces.flowControlExpandedOpacity'),
    );
    expect(automaticFlowSource, contains('surfaces.flowControlIconOpacity'));
    expect(automaticFlowSource, contains('dataVisualization.grid'));
    expect(
      automaticFlowSource,
      isNot(contains('Colors.white.withValues(alpha: 0.15)')),
    );
    expect(automaticFlowSource, isNot(contains('withValues(alpha: .6)')));
    expect(automaticFlowSource, isNot(contains('withValues(alpha: .46)')));
    expect(automaticFlowSource, isNot(contains('withValues(alpha: .05)')));
    expect(automaticFlowSource, isNot(contains('withValues(alpha: .04)')));
    expect(automaticFlowSource, isNot(contains('withValues(alpha: .16)')));

    final flowWidgetsSource =
        File('lib/widgets/flow_widgets.dart').readAsStringSync();
    expect(flowWidgetsSource, contains('context.flowTokens'));
    expect(flowWidgetsSource, contains('context.surfaceTokens.dialog'));
    expect(flowWidgetsSource, isNot(contains('context.colors')));

    final flowScreenWidgetsSource =
        File('lib/widgets/flow_screen_widgets.dart').readAsStringSync();
    expect(flowScreenWidgetsSource, contains('context.flowTokens'));
    expect(flowScreenWidgetsSource, contains('context.surfaceTokens.dialog'));
    expect(flowScreenWidgetsSource, isNot(contains('context.colors')));

    final genericBarSource =
        File('lib/widgets/generic_bar.dart').readAsStringSync();
    expect(genericBarSource, contains('shapes.compact'));

    final focusedSetsSource =
        File('lib/widgets/focused_sets_list.dart').readAsStringSync();
    expect(focusedSetsSource, contains('shapes.pill'));

    final metricChipSource =
        File('lib/widgets/set_stat_chip.dart').readAsStringSync();
    expect(metricChipSource, contains('surfaces.metricChip'));
    expect(metricChipSource, contains('shapes.metric'));

    final presetInfoSource =
        File('lib/widgets/preset_info_card.dart').readAsStringSync();
    expect(presetInfoSource, contains('shapes.metric'));
    expect(presetInfoSource, contains('dataVisualization.heatmapLow'));
    expect(presetInfoSource, contains('surfaces.card'));
    expect(presetInfoSource, contains('semantic.strongContent'));

    final presetBarSource =
        File('lib/widgets/preset_bar.dart').readAsStringSync();
    expect(presetBarSource, contains('WorkoutThumbnailFrame'));
    expect(presetBarSource, contains('dataVisualization.heatmapLow'));

    final swapSource =
        File('lib/widgets/swap_exercise_sheet.dart').readAsStringSync();
    expect(swapSource, contains('swapSecondaryTextOpacity'));

    expect(detailSource, contains('shapes.metric'));
  });
  test('active-session consumers keep shared ownership boundaries', () {
    String source(String path) => File(path).readAsStringSync();

    final sessionSource = source('lib/screens/exercise/session_screen.dart');
    expect(sessionSource, contains('WorkoutFinishAction('));
    expect(sessionSource, contains('AppTestKeys.sessionFinish'));
    expect(sessionSource, contains('timerTextStyle.copyWith(fontSize: 20)'));
    expect(sessionSource, contains('timerTextStyle.copyWith(fontSize: 48)'));
    expect(sessionSource, contains('const Duration(milliseconds: 420)'));
    expect(sessionSource, isNot(contains('style: const TextStyle(fontSize:')));

    final exerciseCardSource = source('lib/widgets/exercise_card.dart');
    expect(exerciseCardSource, contains('return WeightCard('));
    expect(exerciseCardSource, contains('readOnlyMode: readOnlyMode'));

    final addFabSource = source('lib/widgets/add_exercise_fab.dart');
    expect(addFabSource, contains('context.semanticColors'));
    expect(addFabSource, contains('primaryAction'));
    expect(addFabSource, contains('onPrimaryAction'));
    expect(addFabSource, isNot(contains('app_colors.dart')));

    final ongoingFabSource = source('lib/widgets/ongoing_session_fab.dart');
    expect(ongoingFabSource, contains('semantic.ongoingSessionAction'));
    expect(ongoingFabSource, contains('semantic.ongoingSessionExit'));
    expect(ongoingFabSource, contains('WorkoutExitAction('));
    expect(ongoingFabSource, contains('surfaces.dialogChoice'));
    expect(ongoingFabSource, contains('shapes.dialogChoice'));
    expect(ongoingFabSource, contains('AppTestKeys.ongoingSessionMenu'));
    expect(ongoingFabSource, contains('AppTestKeys.ongoingSessionResume'));
    expect(ongoingFabSource, contains('AppTestKeys.ongoingSessionExit'));
    expect(ongoingFabSource, isNot(contains('Colors.green')));
    expect(ongoingFabSource, isNot(contains('Colors.red')));

    final durabilitySource = source(
      'lib/widgets/active_session_durability_banner.dart',
    );
    expect(durabilitySource, contains('context.shapeTokens'));
    expect(durabilitySource, contains('context.effectTokens'));
    expect(durabilitySource, contains('scheme.errorContainer'));
    expect(durabilitySource, contains('scheme.onErrorContainer'));
    expect(durabilitySource, isNot(contains('BorderRadius.circular(')));

    final actionsSource = source('lib/theme/widgets/workout_actions.dart');
    expect(actionsSource, contains('WorkoutFinishAction'));
    expect(actionsSource, contains('WorkoutExitAction'));
    expect(actionsSource, contains('context.semanticColors'));
    expect(actionsSource, contains('context.surfaceTokens'));
    expect(actionsSource, contains('context.shapeTokens'));
  });
  test('B5 keeps completion and record meanings independent', () {
    String source(String path) => File(path).readAsStringSync();

    final completionSource = source('lib/widgets/session_complete_sheet.dart');
    expect(completionSource, contains('dataVisualization.sessionExercises'));
    expect(completionSource, contains('dataVisualization.sessionSets'));
    expect(completionSource, contains('dataVisualization.sessionDuration'));
    expect(completionSource, contains('dataVisualization.sessionVolume'));
    expect(completionSource, contains('completionMetricFill'));
    expect(completionSource, contains('completionSetFill'));
    expect(completionSource, contains('completionExerciseFill'));
    expect(completionSource, contains('completionExerciseBorder'));
    expect(completionSource, contains('WorkoutRecordBadgeChip'));
    expect(completionSource, contains('WorkoutDoneAction('));

    final detailSource = source(
      'lib/screens/exercise/session_detail_screen.dart',
    );
    expect(detailSource, contains('semantic.editingActive'));
    expect(detailSource, contains('dataVisualization.heatmapLow'));
    expect(detailSource, contains('dataVisualization.heatmapHigh'));
    expect(detailSource, contains('surfaces.sessionSummary'));
    expect(detailSource, contains('shapes.metric'));
    expect(detailSource, contains('context.shapeTokens.mediaThumbnail'));
    expect(detailSource, contains('WorkoutRecordBadgeChip'));

    final badgesSource = source('lib/widgets/workout_record_badges.dart');
    expect(badgesSource, contains('dataVisualization.firstRecord'));
    expect(badgesSource, contains('dataVisualization.recordMonthly'));
    expect(badgesSource, contains('dataVisualization.recordAllTime'));
    expect(badgesSource, contains('context.surfaceTokens.firstRecordFill'));
    expect(badgesSource, contains('context.surfaceTokens.firstRecordBorder'));
    expect(badgesSource, contains('context.surfaceTokens.recordBadgeFill'));
    expect(badgesSource, contains('context.surfaceTokens.recordBadgeBorder'));
    expect(badgesSource, contains('shapes.recordBadge'));
    expect(badgesSource, contains('shapes.recordBadgeCompact'));

    final sheetHandleSource = source(
      'lib/theme/widgets/workout_sheet_handle.dart',
    );
    expect(sheetHandleSource, contains('context.surfaceTokens.workoutHandle'));
    expect(sheetHandleSource, contains('context.shapeTokens.pill'));

    final metricChipSource = source('lib/widgets/set_stat_chip.dart');
    expect(metricChipSource, contains('context.surfaceTokens'));
    expect(metricChipSource, contains('context.shapeTokens'));
    expect(metricChipSource, contains('surfaces.metricChip'));
    expect(metricChipSource, contains('shapes.metric'));
  });
  test('semantic health roles preserve copy and interpolation ownership', () {
    final base = AppSemanticColors.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    final target = base.copyWith(
      databaseHealthy: Colors.white,
      databaseWarning: Colors.black,
      trainProfileAvatar: Colors.orange,
      trainOptimizedAction: Colors.blue,
    );
    final midpoint = base.lerp(target, 0.5);

    expect(target.copyWith().databaseHealthy, Colors.white);
    expect(target.copyWith().databaseWarning, Colors.black);
    expect(target.copyWith().trainProfileAvatar, Colors.orange);
    expect(target.copyWith().trainOptimizedAction, Colors.blue);
    expect(
      midpoint.databaseHealthy,
      Color.lerp(base.databaseHealthy, Colors.white, 0.5),
    );
    expect(
      midpoint.databaseWarning,
      Color.lerp(base.databaseWarning, Colors.black, 0.5),
    );
    expect(
      midpoint.trainProfileAvatar,
      Color.lerp(base.trainProfileAvatar, Colors.orange, 0.5),
    );
    expect(
      midpoint.trainOptimizedAction,
      Color.lerp(base.trainOptimizedAction, Colors.blue, 0.5),
    );
  });
  test('flow scope and action roles preserve Classic values', () {
    final light = AppThemeFactory.light(AppThemeFamily.classic).flowTokens;
    final dark = AppThemeFactory.dark(AppThemeFamily.classic).flowTokens;

    expect(light.profileScope, const Color(0xFF00796B));
    expect(dark.profileScope, const Color(0xFF4DB6AC));
    expect(light.planScope, const Color(0xFFEF6C00));
    expect(dark.planScope, const Color(0xFFFFB74D));
    expect(light.addSetAction, const Color(0xFF26A69A));
    expect(dark.addSetAction, const Color(0xFF26A69A));

    final midpoint = light.lerp(dark, 0.5);
    expect(
      midpoint.profileScope,
      Color.lerp(light.profileScope, dark.profileScope, 0.5),
    );
    expect(
      midpoint.planScope,
      Color.lerp(light.planScope, dark.planScope, 0.5),
    );
    expect(
      midpoint.addSetAction,
      Color.lerp(light.addSetAction, dark.addSetAction, 0.5),
    );
  });
  test(
    'train and plan opacity roles preserve Classic values and interpolation',
    () {
      final light = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
      final dark = AppThemeFactory.dark(AppThemeFamily.classic).surfaceTokens;
      expect(light.trainTabSurfaceOpacity, 0.75);
      expect(dark.trainTabSurfaceOpacity, 0.75);
      expect(light.splitWorkoutDividerOpacity, 0.18);
      expect(dark.splitWorkoutDividerOpacity, 0.18);
      expect(light.planRevealBorderOpacity, 0.45);
      expect(dark.planRevealBorderOpacity, 0.45);

      final target = light.copyWith(
        trainTabSurfaceOpacity: 0.4,
        splitWorkoutDividerOpacity: 0.3,
        planRevealBorderOpacity: 0.6,
      );
      expect(target.copyWith().trainTabSurfaceOpacity, 0.4);
      expect(target.copyWith().splitWorkoutDividerOpacity, 0.3);
      expect(target.copyWith().planRevealBorderOpacity, 0.6);

      final midpoint = light.lerp(target, 0.5);
      expect(midpoint.trainTabSurfaceOpacity, 0.575);
      expect(midpoint.splitWorkoutDividerOpacity, 0.24);
      expect(midpoint.planRevealBorderOpacity, 0.525);
    },
  );
  test(
    'premade and flow opacity roles preserve Classic values and interpolation',
    () {
      final light = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
      final dark = AppThemeFactory.dark(AppThemeFamily.classic).surfaceTokens;

      for (final surface in [light, dark]) {
        expect(surface.planSwapBadgeOpacity, 0.55);
        expect(surface.flowErrorBorderOpacity, 0.6);
        expect(surface.flowControlBorderOpacity, 0.46);
        expect(surface.flowControlCollapsedOpacity, 0.05);
        expect(surface.flowControlExpandedOpacity, 0.04);
        expect(surface.flowControlIconOpacity, 0.16);
      }

      final target = light.copyWith(
        planSwapBadgeOpacity: 0.35,
        flowErrorBorderOpacity: 0.8,
        flowControlBorderOpacity: 0.2,
        flowControlCollapsedOpacity: 0.1,
        flowControlExpandedOpacity: 0.08,
        flowControlIconOpacity: 0.24,
      );
      expect(target.copyWith().planSwapBadgeOpacity, 0.35);
      expect(target.copyWith().flowErrorBorderOpacity, 0.8);
      expect(target.copyWith().flowControlBorderOpacity, 0.2);
      expect(target.copyWith().flowControlCollapsedOpacity, 0.1);
      expect(target.copyWith().flowControlExpandedOpacity, 0.08);
      expect(target.copyWith().flowControlIconOpacity, 0.24);

      final midpoint = light.lerp(target, 0.5);
      expect(midpoint.planSwapBadgeOpacity, closeTo(0.45, 1e-9));
      expect(midpoint.flowErrorBorderOpacity, closeTo(0.7, 1e-9));
      expect(midpoint.flowControlBorderOpacity, closeTo(0.33, 1e-9));
      expect(midpoint.flowControlCollapsedOpacity, closeTo(0.075, 1e-9));
      expect(midpoint.flowControlExpandedOpacity, closeTo(0.06, 1e-9));
      expect(midpoint.flowControlIconOpacity, closeTo(0.2, 1e-9));
    },
  );
  test('shape overrides and interpolation preserve independent roles', () {
    final base = AppShapeTokens.classic;
    final target = base.copyWith(
      trainTab: BorderRadius.circular(21),
      mediaThumbnail: BorderRadius.circular(39),
      compact: BorderRadius.circular(40),
      control: BorderRadius.circular(42),
      card: BorderRadius.circular(44),
      flowControl: BorderRadius.circular(47),
      flowIcon: BorderRadius.circular(49),
      recordBadge: BorderRadius.circular(45),
      recordBadgeCompact: BorderRadius.circular(46),
      sheet: BorderRadius.circular(46),
      pill: BorderRadius.circular(48),
      settingsAction: BorderRadius.circular(50),
      settingsPanel: BorderRadius.circular(52),
      settingsInput: BorderRadius.circular(54),
      settingsField: BorderRadius.circular(56),
      settingsPicker: BorderRadius.circular(58),
      settingsIcon: BorderRadius.circular(60),
      settingsTabIndicator: BorderRadius.circular(62),
      settingsScopeIcon: BorderRadius.circular(64),
      settingsTitleCard: BorderRadius.circular(65),
      profileTile: BorderRadius.circular(66),
      hero: BorderRadius.circular(68),
      actionBar: BorderRadius.circular(70),
      dialogChoice: BorderRadius.circular(72),
      outlineWidth: 3,
      focusRingWidth: 6,
    );
    final midpoint = base.lerp(target, 0.5);
    expect(target.trainTab, BorderRadius.circular(21));
    expect(
      midpoint.trainTab,
      BorderRadius.lerp(base.trainTab, BorderRadius.circular(21), 0.5),
    );
    expect(target.copyWith().trainTab, target.trainTab);
    expect(target.mediaThumbnail, BorderRadius.circular(39));
    expect(
      midpoint.mediaThumbnail,
      BorderRadius.lerp(base.mediaThumbnail, BorderRadius.circular(39), 0.5),
    );
    expect(target.copyWith().mediaThumbnail, target.mediaThumbnail);
    expect(target.compact, BorderRadius.circular(40));
    expect(
      midpoint.compact,
      BorderRadius.lerp(base.compact, BorderRadius.circular(40), 0.5),
    );
    expect(target.copyWith().compact, target.compact);
    expect(target.control, BorderRadius.circular(42));
    expect(
      midpoint.control,
      BorderRadius.lerp(base.control, BorderRadius.circular(42), 0.5),
    );
    expect(target.copyWith().control, target.control);
    expect(target.recordBadge, BorderRadius.circular(45));
    expect(
      midpoint.recordBadge,
      BorderRadius.lerp(base.recordBadge, BorderRadius.circular(45), 0.5),
    );
    expect(target.copyWith().recordBadge, target.recordBadge);
    expect(target.recordBadgeCompact, BorderRadius.circular(46));
    expect(
      midpoint.recordBadgeCompact,
      BorderRadius.lerp(
        base.recordBadgeCompact,
        BorderRadius.circular(46),
        0.5,
      ),
    );
    expect(target.copyWith().recordBadgeCompact, target.recordBadgeCompact);
    expect(target.flowControl, BorderRadius.circular(47));
    expect(
      midpoint.flowControl,
      BorderRadius.lerp(base.flowControl, BorderRadius.circular(47), 0.5),
    );
    expect(target.copyWith().flowControl, target.flowControl);
    expect(target.flowIcon, BorderRadius.circular(49));
    expect(
      midpoint.flowIcon,
      BorderRadius.lerp(base.flowIcon, BorderRadius.circular(49), 0.5),
    );
    expect(target.copyWith().flowIcon, target.flowIcon);
    expect(target.card, BorderRadius.circular(44));
    expect(
      midpoint.card,
      BorderRadius.lerp(base.card, BorderRadius.circular(44), 0.5),
    );
    expect(target.copyWith().card, target.card);
    expect(target.sheet, BorderRadius.circular(46));
    expect(
      midpoint.sheet,
      BorderRadius.lerp(base.sheet, BorderRadius.circular(46), 0.5),
    );
    expect(target.copyWith().sheet, target.sheet);
    expect(target.pill, BorderRadius.circular(48));
    expect(
      midpoint.pill,
      BorderRadius.lerp(base.pill, BorderRadius.circular(48), 0.5),
    );
    expect(target.copyWith().pill, target.pill);
    expect(target.settingsAction, BorderRadius.circular(50));
    expect(
      midpoint.settingsAction,
      BorderRadius.lerp(base.settingsAction, BorderRadius.circular(50), 0.5),
    );
    expect(target.copyWith().settingsAction, target.settingsAction);
    expect(target.settingsPanel, BorderRadius.circular(52));
    expect(
      midpoint.settingsPanel,
      BorderRadius.lerp(base.settingsPanel, BorderRadius.circular(52), 0.5),
    );
    expect(target.copyWith().settingsPanel, target.settingsPanel);
    expect(target.settingsInput, BorderRadius.circular(54));
    expect(
      midpoint.settingsInput,
      BorderRadius.lerp(base.settingsInput, BorderRadius.circular(54), 0.5),
    );
    expect(target.copyWith().settingsInput, target.settingsInput);
    expect(target.settingsField, BorderRadius.circular(56));
    expect(
      midpoint.settingsField,
      BorderRadius.lerp(base.settingsField, BorderRadius.circular(56), 0.5),
    );
    expect(target.copyWith().settingsField, target.settingsField);
    expect(target.settingsPicker, BorderRadius.circular(58));
    expect(
      midpoint.settingsPicker,
      BorderRadius.lerp(base.settingsPicker, BorderRadius.circular(58), 0.5),
    );
    expect(target.copyWith().settingsPicker, target.settingsPicker);
    expect(target.settingsIcon, BorderRadius.circular(60));
    expect(
      midpoint.settingsIcon,
      BorderRadius.lerp(base.settingsIcon, BorderRadius.circular(60), 0.5),
    );
    expect(target.copyWith().settingsIcon, target.settingsIcon);
    expect(target.settingsTabIndicator, BorderRadius.circular(62));
    expect(
      midpoint.settingsTabIndicator,
      BorderRadius.lerp(
        base.settingsTabIndicator,
        BorderRadius.circular(62),
        0.5,
      ),
    );
    expect(target.copyWith().settingsTabIndicator, target.settingsTabIndicator);
    expect(target.settingsScopeIcon, BorderRadius.circular(64));
    expect(
      midpoint.settingsScopeIcon,
      BorderRadius.lerp(base.settingsScopeIcon, BorderRadius.circular(64), 0.5),
    );
    expect(target.copyWith().settingsScopeIcon, target.settingsScopeIcon);
    expect(target.settingsTitleCard, BorderRadius.circular(65));
    expect(
      midpoint.settingsTitleCard,
      BorderRadius.lerp(base.settingsTitleCard, BorderRadius.circular(65), 0.5),
    );
    expect(target.copyWith().settingsTitleCard, target.settingsTitleCard);
    expect(target.profileTile, BorderRadius.circular(66));
    expect(
      midpoint.profileTile,
      BorderRadius.lerp(base.profileTile, BorderRadius.circular(66), 0.5),
    );
    expect(target.copyWith().profileTile, target.profileTile);
    expect(target.hero, BorderRadius.circular(68));
    expect(
      midpoint.hero,
      BorderRadius.lerp(base.hero, BorderRadius.circular(68), 0.5),
    );
    expect(target.copyWith().hero, target.hero);
    expect(target.actionBar, BorderRadius.circular(70));
    expect(
      midpoint.actionBar,
      BorderRadius.lerp(base.actionBar, BorderRadius.circular(70), 0.5),
    );
    expect(target.copyWith().actionBar, target.actionBar);
    expect(target.dialogChoice, BorderRadius.circular(72));
    expect(
      midpoint.dialogChoice,
      BorderRadius.lerp(base.dialogChoice, BorderRadius.circular(72), 0.5),
    );
    expect(target.copyWith().dialogChoice, target.dialogChoice);
    expect(midpoint.outlineWidth, 2);
    expect(midpoint.focusRingWidth, 4);
    expect(base.settingsTabIndicator, BorderRadius.circular(14));
    expect(base.settingsScopeIcon, BorderRadius.circular(14));
  });
  test('registers a complete Classic light token set', () {
    _expectCompleteTokenSet(AppThemeFactory.light(AppThemeFamily.classic));
  });

  test('registers a complete Classic dark token set', () {
    _expectCompleteTokenSet(AppThemeFactory.dark(AppThemeFamily.classic));
  });

  test('copyWith preserves every token field when not overridden', () {
    final semantic = AppSemanticColors.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    final semanticCopy = semantic.copyWith();
    expect(semanticCopy.positive, semantic.positive);
    expect(semanticCopy.onPositive, semantic.onPositive);
    expect(semanticCopy.warning, semantic.warning);
    expect(semanticCopy.databaseHealthy, semantic.databaseHealthy);
    expect(semanticCopy.databaseWarning, semantic.databaseWarning);
    expect(semanticCopy.onWarning, semantic.onWarning);
    expect(semanticCopy.negative, semantic.negative);
    expect(semanticCopy.onNegative, semantic.onNegative);
    expect(semanticCopy.info, semantic.info);
    expect(semanticCopy.onInfo, semantic.onInfo);
    expect(semanticCopy.strongContent, semantic.strongContent);
    expect(semanticCopy.mutedContent, semantic.mutedContent);
    expect(semanticCopy.measurementContainer, semantic.measurementContainer);
    expect(
      semanticCopy.onMeasurementContainer,
      semantic.onMeasurementContainer,
    );
    expect(semanticCopy.nutritionContainer, semantic.nutritionContainer);
    expect(semanticCopy.onNutritionContainer, semantic.onNutritionContainer);
    expect(semanticCopy.workoutContainer, semantic.workoutContainer);
    expect(semanticCopy.onWorkoutContainer, semantic.onWorkoutContainer);
    expect(semanticCopy.primaryAction, semantic.primaryAction);
    expect(semanticCopy.onPrimaryAction, semantic.onPrimaryAction);
    expect(semanticCopy.automaticPlanBadge, semantic.automaticPlanBadge);
    expect(semanticCopy.onAutomaticPlanBadge, semantic.onAutomaticPlanBadge);
    expect(semanticCopy.workoutAction, semantic.workoutAction);
    expect(semanticCopy.onWorkoutAction, semantic.onWorkoutAction);
    expect(semanticCopy.startWorkoutAction, semantic.startWorkoutAction);
    expect(semanticCopy.onStartWorkoutAction, semantic.onStartWorkoutAction);
    expect(semanticCopy.completionAccent, semantic.completionAccent);
    expect(
      semanticCopy.drawerHeaderForeground,
      semantic.drawerHeaderForeground,
    );
    expect(semanticCopy.ongoingSessionAction, semantic.ongoingSessionAction);
    expect(semanticCopy.ongoingSessionExit, semantic.ongoingSessionExit);
    expect(semanticCopy.workoutCompleted, semantic.workoutCompleted);
    expect(semanticCopy.workoutAddChangeSet, semantic.workoutAddChangeSet);
    expect(semanticCopy.swapCancel, semantic.swapCancel);
    expect(semanticCopy.swapConfirm, semantic.swapConfirm);
    expect(semanticCopy.onSwapConfirm, semantic.onSwapConfirm);
    expect(semanticCopy.swapMatch, semantic.swapMatch);
    expect(semanticCopy.focusRing, semantic.focusRing);
    expect(semanticCopy.disabledContent, semantic.disabledContent);
    expect(semanticCopy.disabledContainer, semantic.disabledContainer);

    final shapeCopy = AppShapeTokens.classic.copyWith();
    expect(shapeCopy.compact, AppShapeTokens.classic.compact);
    expect(shapeCopy.mediaThumbnail, AppShapeTokens.classic.mediaThumbnail);
    expect(shapeCopy.control, AppShapeTokens.classic.control);
    expect(shapeCopy.metric, AppShapeTokens.classic.metric);
    expect(shapeCopy.recordBadge, AppShapeTokens.classic.recordBadge);
    expect(
      shapeCopy.recordBadgeCompact,
      AppShapeTokens.classic.recordBadgeCompact,
    );
    expect(shapeCopy.workoutSection, AppShapeTokens.classic.workoutSection);
    expect(shapeCopy.planCard, AppShapeTokens.classic.planCard);
    expect(shapeCopy.flowControl, AppShapeTokens.classic.flowControl);
    expect(shapeCopy.flowIcon, AppShapeTokens.classic.flowIcon);
    expect(shapeCopy.card, AppShapeTokens.classic.card);
    expect(shapeCopy.sheet, AppShapeTokens.classic.sheet);
    expect(shapeCopy.pill, AppShapeTokens.classic.pill);
    expect(shapeCopy.settingsAction, AppShapeTokens.classic.settingsAction);
    expect(shapeCopy.settingsPanel, AppShapeTokens.classic.settingsPanel);
    expect(shapeCopy.settingsInput, AppShapeTokens.classic.settingsInput);
    expect(shapeCopy.settingsField, AppShapeTokens.classic.settingsField);
    expect(shapeCopy.settingsPicker, AppShapeTokens.classic.settingsPicker);
    expect(shapeCopy.settingsIcon, AppShapeTokens.classic.settingsIcon);
    expect(
      shapeCopy.settingsTitleCard,
      AppShapeTokens.classic.settingsTitleCard,
    );
    expect(shapeCopy.profileTile, AppShapeTokens.classic.profileTile);
    expect(shapeCopy.hero, AppShapeTokens.classic.hero);
    expect(shapeCopy.actionBar, AppShapeTokens.classic.actionBar);
    expect(shapeCopy.dialogChoice, AppShapeTokens.classic.dialogChoice);
    expect(shapeCopy.outlineWidth, AppShapeTokens.classic.outlineWidth);
    expect(shapeCopy.focusRingWidth, AppShapeTokens.classic.focusRingWidth);

    final surface = AppSurfaceTokens.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    final surfaceCopy = surface.copyWith();
    expect(surfaceCopy.panel, surface.panel);
    expect(
      surfaceCopy.workoutCardCompleteFill,
      surface.workoutCardCompleteFill,
    );
    expect(surfaceCopy.workoutSetCompleteFill, surface.workoutSetCompleteFill);
    expect(
      surfaceCopy.workoutChangeSetOutline,
      surface.workoutChangeSetOutline,
    );
    expect(surfaceCopy.panelRaised, surface.panelRaised);
    expect(surfaceCopy.card, surface.card);
    expect(surfaceCopy.planCard, surface.planCard);
    expect(surfaceCopy.presetFocus, surface.presetFocus);
    expect(
      surfaceCopy.swapSecondaryTextOpacity,
      surface.swapSecondaryTextOpacity,
    );
    expect(surfaceCopy.trainTabSurfaceOpacity, surface.trainTabSurfaceOpacity);
    expect(
      surfaceCopy.splitWorkoutDividerOpacity,
      surface.splitWorkoutDividerOpacity,
    );
    expect(
      surfaceCopy.planRevealBorderOpacity,
      surface.planRevealBorderOpacity,
    );
    expect(surfaceCopy.planSwapBadgeOpacity, surface.planSwapBadgeOpacity);
    expect(surfaceCopy.flowErrorBorderOpacity, surface.flowErrorBorderOpacity);
    expect(
      surfaceCopy.flowControlBorderOpacity,
      surface.flowControlBorderOpacity,
    );
    expect(
      surfaceCopy.flowControlCollapsedOpacity,
      surface.flowControlCollapsedOpacity,
    );
    expect(
      surfaceCopy.flowControlExpandedOpacity,
      surface.flowControlExpandedOpacity,
    );
    expect(surfaceCopy.flowControlIconOpacity, surface.flowControlIconOpacity);
    expect(surfaceCopy.flowControl, surface.flowControl);
    expect(surfaceCopy.planFilter, surface.planFilter);
    expect(surfaceCopy.planDuration, surface.planDuration);
    expect(surfaceCopy.planGroup, surface.planGroup);
    expect(surfaceCopy.metricChip, surface.metricChip);
    expect(surfaceCopy.planActionBar, surface.planActionBar);
    expect(surfaceCopy.optimizedAction, surface.optimizedAction);
    expect(surfaceCopy.subtleOutline, surface.subtleOutline);
    expect(surfaceCopy.input, surface.input);
    expect(surfaceCopy.sheet, surface.sheet);
    expect(surfaceCopy.dialog, surface.dialog);
    expect(surfaceCopy.media, surface.media);
    expect(surfaceCopy.mediaFrame, surface.mediaFrame);
    expect(surfaceCopy.mediaPlaceholder, surface.mediaPlaceholder);
    expect(surfaceCopy.mediaOutline, surface.mediaOutline);
    expect(surfaceCopy.catalogSelection, surface.catalogSelection);
    expect(surfaceCopy.catalogUsage, surface.catalogUsage);
    expect(surfaceCopy.catalogOutline, surface.catalogOutline);
    expect(surfaceCopy.divider, surface.divider);
    expect(surfaceCopy.settingsHero, surface.settingsHero);
    expect(surfaceCopy.settingsSection, surface.settingsSection);
    expect(surfaceCopy.settingsInput, surface.settingsInput);
    expect(surfaceCopy.settingsSaveBar, surface.settingsSaveBar);
    expect(surfaceCopy.dialogChoice, surface.dialogChoice);

    final motionCopy = AppMotionTokens.classic.copyWith();
    expect(motionCopy.instant, AppMotionTokens.classic.instant);
    expect(motionCopy.standard, AppMotionTokens.classic.standard);
    expect(motionCopy.emphasized, AppMotionTokens.classic.emphasized);
    expect(motionCopy.page, AppMotionTokens.classic.page);
    expect(motionCopy.quick, AppMotionTokens.classic.quick);
    expect(motionCopy.reduced, AppMotionTokens.classic.reduced);
    expect(motionCopy.standardCurve, AppMotionTokens.classic.standardCurve);
    expect(motionCopy.emphasizedCurve, AppMotionTokens.classic.emphasizedCurve);
    expect(motionCopy.reducedCurve, AppMotionTokens.classic.reducedCurve);

    final effects = AppEffectTokens.classic(Brightness.light);
    final effectsCopy = effects.copyWith();
    expect(effectsCopy.cardElevation, effects.cardElevation);
    expect(effectsCopy.dialogElevation, effects.dialogElevation);
    expect(effectsCopy.sheetElevation, effects.sheetElevation);
    expect(
      effectsCopy.exerciseDetailSheetElevation,
      effects.exerciseDetailSheetElevation,
    );
    expect(effectsCopy.feedbackElevation, effects.feedbackElevation);
    expect(effectsCopy.cardShadow, effects.cardShadow);
    expect(effectsCopy.cardShadowBlur, effects.cardShadowBlur);
    expect(effectsCopy.cardShadowOffset, effects.cardShadowOffset);
    expect(effectsCopy.shadowColor, effects.shadowColor);
    expect(effectsCopy.shadowOpacity, effects.shadowOpacity);
    expect(effectsCopy.shadowBlur, effects.shadowBlur);
    expect(effectsCopy.backdropBlurSigma, effects.backdropBlurSigma);
    expect(effectsCopy.noEffectsShadowOpacity, effects.noEffectsShadowOpacity);
    expect(effectsCopy.noEffectsShadowBlur, effects.noEffectsShadowBlur);
    expect(
      effectsCopy.noEffectsBackdropBlurSigma,
      effects.noEffectsBackdropBlurSigma,
    );

    final data = AppDataVisualizationTokens.fromBrightness(Brightness.light);
    final dataCopy = data.copyWith();
    expect(dataCopy.heatmapLow, data.heatmapLow);
    expect(dataCopy.heatmapHigh, data.heatmapHigh);
    expect(dataCopy.primarySeries, data.primarySeries);
    expect(dataCopy.secondarySeries, data.secondarySeries);
    expect(dataCopy.sessionExercises, data.sessionExercises);
    expect(dataCopy.sessionSets, data.sessionSets);
    expect(dataCopy.sessionDuration, data.sessionDuration);
    expect(dataCopy.sessionVolume, data.sessionVolume);
    expect(dataCopy.positive, data.positive);
    expect(dataCopy.negative, data.negative);
    expect(dataCopy.neutral, data.neutral);
    expect(dataCopy.grid, data.grid);
    expect(dataCopy.label, data.label);
    expect(dataCopy.selection, data.selection);
    expect(dataCopy.recordTodayContainer, data.recordTodayContainer);
    expect(dataCopy.recordTodayBorder, data.recordTodayBorder);
    expect(dataCopy.onRecordTodayContainer, data.onRecordTodayContainer);
    expect(dataCopy.recordMonthly, data.recordMonthly);
    expect(dataCopy.recordAllTime, data.recordAllTime);
    expect(dataCopy.firstRecord, data.firstRecord);
    expect(dataCopy.tertiarySeries, data.tertiarySeries);
    expect(dataCopy.carbohydrateSeries, data.carbohydrateSeries);
    expect(dataCopy.proteinRing, data.proteinRing);
    expect(dataCopy.fatRing, data.fatRing);
    expect(dataCopy.paginationActive, data.paginationActive);
    expect(dataCopy.paginationInactive, data.paginationInactive);

    final flow = AppFlowTokens.classic(Brightness.light);
    final flowCopy = flow.copyWith();
    expect(flowCopy.canvas, flow.canvas);
    expect(flowCopy.nodeBackground, flow.nodeBackground);
    expect(flowCopy.nodeBorder, flow.nodeBorder);
    expect(flowCopy.nodeText, flow.nodeText);
    expect(flowCopy.success, flow.success);
    expect(flowCopy.failure, flow.failure);
    expect(flowCopy.action, flow.action);
    expect(flowCopy.onAction, flow.onAction);
    expect(flowCopy.loopback, flow.loopback);
    expect(flowCopy.diagramSuccess, flow.diagramSuccess);
    expect(flowCopy.diagramLoopback, flow.diagramLoopback);
    expect(flowCopy.profileScope, flow.profileScope);
    expect(flowCopy.planScope, flow.planScope);
    expect(flowCopy.addSetAction, flow.addSetAction);

    final generation = AppGenerationTokens.classic(
      AppThemeFactory.light(AppThemeFamily.classic).colorScheme,
    );
    final generationCopy = generation.copyWith();
    expect(generationCopy.accent, generation.accent);
    expect(generationCopy.introGradientStart, generation.introGradientStart);
    expect(generationCopy.introGradientEnd, generation.introGradientEnd);
    expect(generationCopy.introBorder, generation.introBorder);
    expect(generationCopy.introIconFill, generation.introIconFill);
    expect(generationCopy.introShape, generation.introShape);
    expect(generationCopy.introIconShape, generation.introIconShape);
    expect(generationCopy.summarySurface, generation.summarySurface);
    expect(generationCopy.summaryBorder, generation.summaryBorder);
    expect(generationCopy.summaryPillShape, generation.summaryPillShape);
    expect(generationCopy.sectionSurface, generation.sectionSurface);
    expect(generationCopy.sectionBorder, generation.sectionBorder);
    expect(generationCopy.sectionIconFill, generation.sectionIconFill);
    expect(generationCopy.sectionShape, generation.sectionShape);
    expect(generationCopy.sectionIconShape, generation.sectionIconShape);
    expect(generationCopy.fieldLabel, generation.fieldLabel);
    expect(generationCopy.fieldBorder, generation.fieldBorder);
    expect(generationCopy.fieldFill, generation.fieldFill);
    expect(generationCopy.fieldShape, generation.fieldShape);
    expect(generationCopy.secondaryText, generation.secondaryText);
    expect(
      generationCopy.choiceSelectedSurface,
      generation.choiceSelectedSurface,
    );
    expect(
      generationCopy.choiceUnselectedSurface,
      generation.choiceUnselectedSurface,
    );
    expect(
      generationCopy.choiceSelectedBorder,
      generation.choiceSelectedBorder,
    );
    expect(
      generationCopy.choiceUnselectedBorder,
      generation.choiceUnselectedBorder,
    );
    expect(generationCopy.choiceShape, generation.choiceShape);
    expect(generationCopy.actionBarSurface, generation.actionBarSurface);
    expect(generationCopy.actionBarBorder, generation.actionBarBorder);
    expect(generationCopy.badge, generation.badge);
    expect(generationCopy.onBadge, generation.onBadge);
    expect(generationCopy.badgeShape, generation.badgeShape);

    final nutrition = AppNutritionTokens.classic(Brightness.light);
    final nutritionCopy = nutrition.copyWith();
    expect(nutritionCopy.pantryLogSurface, nutrition.pantryLogSurface);
    expect(nutritionCopy.addMealSurface, nutrition.addMealSurface);
    expect(nutritionCopy.planMealSurface, nutrition.planMealSurface);
    expect(nutritionCopy.textDetailsBorder, nutrition.textDetailsBorder);
  });

  test('provides safe fallbacks for incomplete ThemeData', () {
    _expectCompleteTokenSet(ThemeData());
  });

  test('lerp produces complete interpolated token sets', () {
    final classicLight = AppThemeFactory.light(AppThemeFamily.classic);
    final classicDark = AppThemeFactory.dark(AppThemeFamily.classic);

    final semantic = classicLight.semanticColors.lerp(
      classicDark.semanticColors,
      0.5,
    );
    expect(semantic.positive, isNotNull);
    expect(semantic.databaseHealthy, isNotNull);
    expect(semantic.databaseWarning, isNotNull);
    expect(semantic.disabledContainer, isNotNull);
    expect(semantic.measurementContainer, isNotNull);
    expect(semantic.onWorkoutContainer, isNotNull);
    expect(semantic.primaryAction, isNotNull);
    expect(semantic.ongoingSessionAction, isNotNull);
    expect(semantic.ongoingSessionExit, isNotNull);
    expect(semantic.strongContent, isNotNull);
    expect(semantic.automaticPlanBadge, isNotNull);
    expect(semantic.workoutAction, isNotNull);
    expect(semantic.startWorkoutAction, isNotNull);
    expect(semantic.completionAccent, isNotNull);
    expect(semantic.drawerHeaderForeground, isNotNull);
    expect(semantic.swapMatch, isNotNull);

    final shape = classicLight.shapeTokens.lerp(classicDark.shapeTokens, 0.5);
    expect(shape.card, isNotNull);
    expect(shape.recordBadge, isNotNull);
    expect(shape.recordBadgeCompact, isNotNull);
    expect(shape.flowControl, isNotNull);
    expect(shape.flowIcon, isNotNull);
    expect(shape.workoutSection, isNotNull);
    expect(shape.planCard, isNotNull);
    expect(shape.metric, isNotNull);
    expect(shape.settingsAction, isNotNull);
    expect(shape.profileTile, isNotNull);
    expect(shape.hero, isNotNull);
    expect(shape.actionBar, isNotNull);
    expect(shape.dialogChoice, isNotNull);
    expect(shape.settingsTitleCard, isNotNull);
    expect(shape.focusRingWidth, isNotNull);

    final surface = classicLight.surfaceTokens.lerp(
      classicDark.surfaceTokens,
      0.5,
    );
    expect(surface.panel, isNotNull);
    expect(surface.dialog, isNotNull);
    expect(surface.card, isNotNull);
    expect(surface.mediaFrame, isNotNull);
    expect(surface.mediaPlaceholder, isNotNull);
    expect(surface.mediaOutline, isNotNull);
    expect(surface.catalogSelection, isNotNull);
    expect(surface.catalogUsage, isNotNull);
    expect(surface.catalogOutline, isNotNull);
    expect(surface.planCard, isNotNull);
    expect(surface.presetFocus, isNotNull);
    expect(surface.swapSecondaryTextOpacity, isNotNull);
    expect(surface.trainTabSurfaceOpacity, isNotNull);
    expect(surface.splitWorkoutDividerOpacity, isNotNull);
    expect(surface.planRevealBorderOpacity, isNotNull);
    expect(surface.planSwapBadgeOpacity, isNotNull);
    expect(surface.flowErrorBorderOpacity, isNotNull);
    expect(surface.flowControlBorderOpacity, isNotNull);
    expect(surface.flowControlCollapsedOpacity, isNotNull);
    expect(surface.flowControlExpandedOpacity, isNotNull);
    expect(surface.flowControlIconOpacity, isNotNull);
    expect(surface.swapFilterBorder, isNotNull);
    expect(surface.flowControl, isNotNull);
    expect(surface.planFilter, isNotNull);
    expect(surface.planDuration, isNotNull);
    expect(surface.planGroup, isNotNull);
    expect(surface.metricChip, isNotNull);
    expect(surface.planActionBar, isNotNull);
    expect(surface.optimizedAction, isNotNull);
    expect(surface.subtleOutline, isNotNull);
    expect(surface.settingsHero, isNotNull);
    expect(surface.settingsSection, isNotNull);
    expect(surface.settingsInput, isNotNull);
    expect(surface.settingsSaveBar, isNotNull);
    expect(surface.dialogChoice, isNotNull);

    final motion = classicLight.motionTokens.lerp(
      classicDark.motionTokens,
      0.5,
    );
    expect(motion.standard, isNotNull);
    expect(motion.quick, isNotNull);
    expect(motion.reduced, Duration.zero);

    final effects = classicLight.effectTokens.lerp(
      classicDark.effectTokens,
      0.5,
    );
    expect(effects.shadowOpacity, isNotNull);
    expect(effects.cardShadow, isNotNull);
    expect(effects.cardShadowBlur, isNotNull);
    expect(effects.cardShadowOffset, isNotNull);
    expect(effects.exerciseDetailSheetElevation, 12);
    expect(effects.noEffectsBackdropBlurSigma, 0);

    final data = classicLight.dataVisualizationTokens.lerp(
      classicDark.dataVisualizationTokens,
      0.5,
    );
    expect(data.heatmapLow, isNotNull);
    expect(data.selection, isNotNull);
    expect(data.recordTodayContainer, isNotNull);
    expect(data.sessionExercises, isNotNull);
    expect(data.sessionSets, isNotNull);
    expect(data.sessionDuration, isNotNull);
    expect(data.sessionVolume, isNotNull);
    expect(data.recordMonthly, isNotNull);
    expect(data.recordAllTime, isNotNull);
    expect(data.firstRecord, isNotNull);
    expect(data.tertiarySeries, isNotNull);
    expect(data.paginationInactive, isNotNull);

    final flow = classicLight.flowTokens.lerp(classicDark.flowTokens, 0.5);
    expect(flow.canvas, isNotNull);
    expect(flow.nodeBackground, isNotNull);
    expect(flow.nodeBorder, isNotNull);
    expect(flow.nodeText, isNotNull);
    expect(flow.success, isNotNull);
    expect(flow.failure, isNotNull);
    expect(flow.action, isNotNull);
    expect(flow.onAction, isNotNull);
    expect(flow.loopback, isNotNull);
    expect(flow.diagramSuccess, isNotNull);
    expect(flow.diagramLoopback, isNotNull);
    expect(flow.profileScope, isNotNull);
    expect(flow.planScope, isNotNull);
    expect(flow.addSetAction, isNotNull);

    final generation = classicLight.generationTokens.lerp(
      classicDark.generationTokens,
      0.5,
    );
    expect(generation.accent, isNotNull);
    expect(generation.introGradientStart, isNotNull);
    expect(generation.introGradientEnd, isNotNull);
    expect(generation.introShape, isNotNull);
    expect(generation.introIconShape, isNotNull);
    expect(generation.summarySurface, isNotNull);
    expect(generation.sectionSurface, isNotNull);
    expect(generation.fieldFill, isNotNull);
    expect(generation.choiceSelectedSurface, isNotNull);
    expect(generation.actionBarSurface, isNotNull);
    expect(generation.badge, isNotNull);

    final nutrition = classicLight.nutritionTokens.lerp(
      classicDark.nutritionTokens,
      0.5,
    );
    expect(nutrition.pantryLogSurface, isNotNull);
    expect(nutrition.addMealSurface, isNotNull);
    expect(nutrition.planMealSurface, isNotNull);
    expect(nutrition.textDetailsBorder, isNotNull);
  });
}

void _expectCompleteTokenSet(ThemeData theme) {
  expect(theme.semanticColors, isA<AppSemanticColors>());
  expect(theme.shapeTokens, isA<AppShapeTokens>());
  expect(theme.surfaceTokens, isA<AppSurfaceTokens>());
  expect(theme.motionTokens, isA<AppMotionTokens>());
  expect(theme.effectTokens, isA<AppEffectTokens>());
  expect(theme.dataVisualizationTokens, isA<AppDataVisualizationTokens>());
  expect(theme.flowTokens, isA<AppFlowTokens>());
  expect(theme.generationTokens, isA<AppGenerationTokens>());
  expect(theme.nutritionTokens, isA<AppNutritionTokens>());
}
