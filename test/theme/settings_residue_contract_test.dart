import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings residue routes retain explicit state owners', () {
    const routeMarkers = <String, List<String>>{
      'lib/screens/profile/settings/profile_page.dart': [
        'SettingsPageScaffold',
        'SettingsActionTile',
        'MeasurementsTrendsSettingsPage',
      ],
      'lib/screens/profile/settings/user_information_settings_page.dart': [
        'SettingsSaveBar',
        'DropdownButtonFormField',
        'showSnackBar',
      ],
      'lib/screens/profile/settings/ui_appearance_settings_page.dart': [
        'SettingsPageScaffold',
        'showDialog',
        'TonosDialogFrame',
        'SnackBar',
      ],
      'lib/screens/profile/settings/nav_bar_settings_page.dart': [
        'SettingsSaveBar',
        'ReorderableListView',
        'NavBarConfig',
      ],
      'lib/screens/profile/settings/tutorials_settings_page.dart': [
        'SettingsPageScaffold',
        'SettingsExpansionSection',
        'resetAll',
        'showSnackBar',
      ],
      'lib/screens/profile/settings/gym_exercise_settings_page.dart': [
        'SettingsPageScaffold',
        'showDialog',
        'TonosDialogFrame',
      ],
      'lib/screens/profile/settings/analytics_setting_screen.dart': [
        'SettingsPageScaffold',
        'SettingsActionTile',
      ],
      'lib/screens/profile/settings/bodypart_ranking_screen.dart': [
        'ReorderableListView',
        'SettingsSaveBar',
        'SafeErrorView',
        '_isSaving',
      ],
      'lib/screens/profile/settings/muscle_ranking_screen.dart': [
        'ReorderableListView',
        'SettingsSaveBar',
        'SafeErrorView',
        '_isSaving',
      ],
      'lib/screens/profile/settings/volume_boundaries_screen.dart': [
        'DropdownButtonFormField',
        'FilledButton.icon',
        '_showInvalidNumbers',
        'SafeErrorView',
        '_isSavingBodyPart',
        '_isSavingMuscle',
      ],
      'lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart': [
        'DropdownButtonFormField',
        'SettingsSaveBar',
        'SafeErrorView',
        '_isSaving',
      ],
      'lib/screens/profile/settings/exercise_analytics_screen.dart': [
        'FloatingActionButton.extended',
        'SafeErrorView',
        '_isSavingCredits',
        'allocationInvalidCredit',
      ],
      'lib/screens/profile/settings/exercise_editor_screen.dart': [
        'TonosDialogFrame',
        'SafeErrorView',
        'PopScope',
        '_isSaving',
      ],
      'lib/screens/profile/settings/flow_methods_page.dart': [
        'TonosDialogFrame',
        'showDialog',
        'ExpansionTile',
        'rulesNameRequired',
      ],
      'lib/screens/profile/settings/workout_progress_flows_page.dart': [
        'SettingsPageScaffold',
        'SafeErrorView',
        'ExpansionTile',
        'AutoPresetFlowScreen',
      ],
      'lib/screens/exercise/auto_preset_flow_screen.dart': [
        'TonosDialogFrame',
        'DropdownButtonFormField',
        'flowMethodNameRequired',
        'canDeleteNode',
      ],
      'lib/screens/profile/settings/database_settings_page.dart': [
        'SettingsPageScaffold',
        'TonosDialogFrame',
        'showDialog',
        'SnackBar',
        '_contentActionRunning',
      ],
      'lib/screens/profile/settings/diagnostics_settings_page.dart': [
        'SettingsPageScaffold',
        'onChanged',
        '_sendingTestEvent',
        '_deletingSharedDiagnostics',
        'showSnackBar',
      ],
      'lib/screens/profile/settings/measurements_trends_settings_page.dart': [
        'SettingsPageScaffold',
        'SettingsActionTile',
        'MeasuredItemsPage',
      ],
    };

    for (final entry in routeMarkers.entries) {
      final path = entry.key;
      expect(File(path).existsSync(), isTrue, reason: path);
      final source = _withoutCommentsAndImports(File(path).readAsStringSync());
      for (final marker in entry.value) {
        expect(
          source,
          contains(marker),
          reason: '$path should retain its $marker state owner.',
        );
      }
    }
  });

  test('shared settings primitives cover the residue boundary', () {
    final source = _withoutCommentsAndImports(
      File('lib/widgets/settings_tiles.dart').readAsStringSync(),
    );
    for (final marker in const [
      'SettingsValueText',
      'SettingsStatusBadge',
      'SettingsSaveBar',
      'SettingsRankingTile',
      'SettingsPageScaffold',
    ]) {
      expect(source, contains(marker));
    }

    final dialog = _withoutCommentsAndImports(
      File('lib/theme/widgets/tonos_dialog.dart').readAsStringSync(),
    );
    expect(dialog, contains('TonosDialogFrame'));
    expect(dialog, contains('dialogButtonForeground'));
  });
}

String _withoutComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\r\n]*'), '');
}

String _withoutCommentsAndImports(String source) {
  return _withoutComments(source)
      .split(RegExp(r'\r?\n'))
      .where((line) {
        final trimmed = line.trimLeft();
        return !trimmed.startsWith('import ') && !trimmed.startsWith('export ');
      })
      .join('\n');
}
