import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('N5 state categories have explicit route owners', () {
    const stateCoverage = <String, Map<String, List<String>>>{
      'loading': {
        'lib/screens/exercise/train_page.dart': [
          'FutureBuilder',
          'CircularProgressIndicator',
        ],
        'lib/widgets/health_trends_section.dart': [
          'FutureBuilder',
          'CircularProgressIndicator',
        ],
      },
      'empty': {
        'lib/screens/exercise/exercise_catalog_page.dart': [
          '_displayedDefs.isEmpty',
          'CircularProgressIndicator',
        ],
        'lib/widgets/exercise_progress_section.dart': [
          'points.isEmpty',
          '_ExerciseProgressEmptyHero',
        ],
        'lib/widgets/health_trends_section.dart': [
          'trends.isEmpty',
          'entries.isEmpty',
        ],
      },
      'error': {
        'lib/screens/exercise/session_detail_screen.dart': [
          'SafeErrorView',
          'SafeFailure.classify',
        ],
        'lib/widgets/health_trends_section.dart': [
          'SafeErrorView',
          'SafeFailure.classify',
        ],
        'lib/screens/nutrition/nutrition_page.dart': [
          'SafeErrorView',
          'p.error',
        ],
      },
      'editing': {
        'lib/screens/nutrition/food_customization_page.dart': [
          'TextEditingController',
          'TonosFormField',
          'validator:',
        ],
        'lib/screens/profile/settings/user_information_settings_page.dart': [
          'DropdownButtonFormField',
          'SettingsSaveBar',
        ],
        'lib/screens/exercise/session_detail_screen.dart': [
          '_isEditing',
          '_buildEditableExerciseCards',
          'ExerciseCard',
          'TextFormField',
        ],
      },
      'destructive': {
        'lib/screens/exercise/session_detail_screen.dart': [
          'showDialog',
          '_deleteSession',
        ],
        'lib/widgets/health_trends_section.dart': [
          'showDialog',
          '_deleteEntry',
        ],
        'lib/screens/profile/settings/database_settings_page.dart': [
          'showDialog',
          'databaseImport',
        ],
      },
      'media': {
        'lib/widgets/exercise_media_thumbnail.dart': [
          'Image.file',
          'errorBuilder',
        ],
        'lib/theme/widgets/media_viewer_image.dart': [
          'showDialog',
          'errorBuilder',
        ],
        'lib/widgets/exercise_detail_sheet.dart': [
          '_showImageViewer',
          '_showHeatmapViewer',
        ],
      },
      'workout-completion': {
        'lib/widgets/session_complete_sheet.dart': [
          'WorkoutCompletionStatus',
          'CircularProgressIndicator',
        ],
        'lib/screens/exercise/session_screen.dart': [
          'finish()',
          'showModalBottomSheet',
        ],
      },
      'history': {
        'lib/screens/exercise/full_history_screen.dart': [
          'FutureBuilder',
          'SessionDetailScreen',
        ],
        'lib/screens/exercise/session_detail_screen.dart': [
          'PopScope',
          'showDialog',
        ],
      },
      'progress': {
        'lib/screens/measurement_trends_page.dart': [
          'ExerciseProgressSection',
          'HealthTrendsSection',
        ],
        'lib/widgets/exercise_progress_section.dart': [
          'FutureBuilder',
          'ExerciseProgressSection',
        ],
      },
      'nutrition': {
        'lib/screens/nutrition/nutrition_page.dart': [
          'NutritionProfile',
          'SafeErrorView',
        ],
        'lib/screens/nutrition/food_logging_page.dart': [
          'NutritionProfile',
          'SnackBar',
          'TonosField',
          'TonosFormField',
        ],
        'lib/screens/nutrition/log_entry_page.dart': [
          'NutritionProfile',
          'showModalBottomSheet',
        ],
      },
      'scanner': {
        'lib/screens/nutrition/barcode_scanner_page.dart': [
          'WidgetsBindingObserver',
          'didChangeAppLifecycleState',
        ],
        'lib/services/barcode_scanner_session.dart': [
          'start',
          'stop',
          'dispose',
        ],
      },
      'settings': {
        'lib/screens/profile/settings/ui_appearance_settings_page.dart': [
          'SettingsPageScaffold',
          'TonosDialogFrame',
        ],
        'lib/screens/profile/settings/nav_bar_settings_page.dart': [
          'SettingsSaveBar',
          'ReorderableListView',
        ],
        'lib/screens/profile/settings/database_settings_page.dart': [
          'TonosDialogFrame',
          'SnackBar',
        ],
      },
    };

    final fieldOwner = _withoutCommentsAndImports(
      File('lib/theme/widgets/tonos_field.dart').readAsStringSync(),
    );
    expect(fieldOwner, contains('class TonosFormField'));
    expect(fieldOwner, contains('TextFormField('));

    for (final category in stateCoverage.entries) {
      for (final route in category.value.entries) {
        final path = route.key;
        expect(File(path).existsSync(), isTrue, reason: path);
        final source = _withoutCommentsAndImports(
          File(path).readAsStringSync(),
        );
        expect(
          route.value.every(source.contains),
          isTrue,
          reason:
              '${category.key} route $path must retain every listed state owner.',
        );
      }
    }
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
