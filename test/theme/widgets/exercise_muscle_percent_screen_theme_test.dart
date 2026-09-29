import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise_muscle_percent_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('exercise muscle percent input has exact Material ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'exercise-muscle-percent-material-input',
    );

    expect(rule.pattern, 'lib/screens/exercise_muscle_percent_screen.dart');
    expect(rule.classification, 'material_component');
    expect(rule.kinds, <String>['decoration']);
    final findings = report.findings.where((f) => f.ruleId == rule.id).toList();
    expect(findings, hasLength(1));
    expect(findings.single.status, 'migrated');
    expect(
      report.findings.where(
        (finding) =>
            finding.file == rule.pattern && finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);

      testWidgets(
        '${family.code} ${brightness.name} delegates the percentage field to Material',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final muscle = Muscle(id: 4, name: 'Pectoralis major');
          final definition = ExerciseDefinition(
            id: 11,
            name: 'Cable Chest Press',
            muscles: [RankedMuscle(muscle: muscle, rank: 1)],
            useManualBodyparts: false,
            multiplyByRating: false,
          );
          final repository = _MusclePercentRepository(
            definition: definition,
            muscle: muscle,
          );

          await tester.pumpWidget(
            MultiProvider(
              providers: [Provider<AppRepository>.value(value: repository)],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const ExerciseMusclePercentScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(TextFormField), findsOneWidget);
          final decoration =
              tester
                  .widget<InputDecorator>(find.byType(InputDecorator))
                  .decoration;
          expect(
            decoration.labelText,
            AppLocalizations.of(
              tester.element(find.byType(TextFormField)),
            ).musclePercentLabel,
          );
          expect(decoration.filled, theme.inputDecorationTheme.filled);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class _MusclePercentRepository extends AppRepository {
  _MusclePercentRepository({required this.definition, required this.muscle});

  final ExerciseDefinition definition;
  final Muscle muscle;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [definition];

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      [
        ExerciseMusclePercent(
          exerciseDefId: defId,
          muscleId: muscle.id,
          percent: 1.25,
        ),
      ];

  @override
  Future<List<ExerciseMusclePercent>> fetchPercentsForExercise(
    int defId,
  ) async => const <ExerciseMusclePercent>[];
}
