import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/providers/nav_bar_config.dart';

void main() {
  test(
    'production shell keeps current and legacy Train entry points explicit',
    () {
      final source = _read('lib/main.dart');

      expect(source, contains("'/main': (_) => const MainScreen(),"));
      expect(source, contains('case TabItem.train:'));
      expect(source, contains('return const TrainPage();'));
      expect(source, contains('case TabItem.train2:'));
      expect(source, contains('return const Train2Page();'));
    },
  );

  test('development Theme Lab remains unavailable outside debug builds', () {
    final mainSource = _read('lib/main.dart');
    final themeLabSource = _read('lib/theme/theme_lab_page.dart');

    expect(mainSource, contains('kDebugMode && _compileTimeThemeLab'));
    expect(mainSource, contains("if (kDebugMode) '/__theme_lab'"));
    expect(
      themeLabSource,
      contains('if (!kDebugMode) return const SizedBox.shrink();'),
    );
  });

  test('release navigation policy keeps unfinished tabs gated', () {
    const releasePolicy = NavigationBuildPolicy(
      experimentalTabsEnabled: true,
      isReleaseMode: true,
    );
    const debugPolicy = NavigationBuildPolicy(
      experimentalTabsEnabled: true,
      isReleaseMode: false,
    );

    expect(releasePolicy.allows(TabItem.nutritionLog), isFalse);
    expect(releasePolicy.allows(TabItem.combinedHistory), isFalse);
    expect(releasePolicy.allows(TabItem.formAndPosing), isFalse);
    expect(debugPolicy.allows(TabItem.nutritionLog), isTrue);
    expect(debugPolicy.allows(TabItem.combinedHistory), isTrue);
    expect(debugPolicy.allows(TabItem.formAndPosing), isTrue);

    // Train2 is legacy but currently release-reachable, so the route ledger
    // must not describe it as debug-only without a separate product decision.
    expect(releasePolicy.allows(TabItem.train2), isTrue);
  });

  test(
    '12B plan and workout entry points remain reachable from release callers',
    () {
      final trainSource = _read('lib/screens/exercise/train_page.dart');
      final legacyTrainSource = _read('lib/screens/exercise/train2_page.dart');
      final dashboardSource = _read('lib/widgets/dashboard_sections.dart');
      final onboardingSource = _read('lib/screens/onboarding_flow.dart');
      final sessionSource = _read('lib/screens/exercise/session_screen.dart');
      final presetDetailSource = _read(
        'lib/screens/exercise/preset_detail_screen.dart',
      );
      final presetsSource = _read('lib/widgets/presets_loaded.dart');

      expect(trainSource, contains('PresetGenerationQaScreen'));
      expect(trainSource, contains('PremadePlansPage'));
      expect(trainSource, contains('SessionScreen'));
      expect(trainSource, contains('PresetDetailScreen'));
      expect(legacyTrainSource, contains('PresetGenerationQaScreen'));
      expect(legacyTrainSource, contains('SessionScreen'));
      expect(legacyTrainSource, contains('PresetDetailScreen'));
      expect(trainSource, contains('OptimizedWorkoutSettingsPage'));
      expect(dashboardSource, contains('PresetGenerationQaScreen'));
      expect(onboardingSource, contains('PresetGenerationQaScreen'));
      expect(onboardingSource, contains('onboardingMode: true'));
      expect(sessionSource, contains('SessionCompleteSheet'));
      expect(presetDetailSource, contains('SwapExerciseSheet'));
      expect(presetDetailSource, contains('PresetInfoCard'));
      expect(presetDetailSource, contains('AutoPresetFlowScreen'));
      expect(presetsSource, contains('PresetBar'));
      for (final path in [
        'lib/widgets/past_sessions_list.dart',
        'lib/widgets/history_content.dart',
        'lib/widgets/exercise_progress_section.dart',
        'lib/widgets/exercise_detail_sheet.dart',
      ]) {
        expect(_read(path), contains('SessionDetailScreen'), reason: path);
      }
    },
  );
}

String _read(String path) => File(path).readAsStringSync();
