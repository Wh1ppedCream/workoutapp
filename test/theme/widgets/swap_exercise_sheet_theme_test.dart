import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/swap_exercise_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('swap sheet secondary equipment ink has exact token ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'swap-exercise-secondary-equipment-ink',
    );

    expect(rule.pattern, 'lib/widgets/swap_exercise_sheet.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.kinds, <String>['color_transform']);
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
        '${family.code} ${brightness.name} uses the swap secondary-text token',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final bodyPart = BodyPart(4, 'Chest');
          final muscle = Muscle(id: 7, name: 'Pectoralis major');
          ExerciseDefinition definition(int id, String name) =>
              ExerciseDefinition(
                id: id,
                name: name,
                equipmentList: [Equipment(1, 'Barbell')],
                bodyParts: [bodyPart],
                muscles: [RankedMuscle(muscle: muscle, rank: 1)],
                useManualBodyparts: false,
                multiplyByRating: false,
              );
          final current = definition(11, 'Bench Press');
          final replacement = definition(12, 'Incline Press');
          final repository = _SwapRepository(
            definitions: [current, replacement],
            bodyPart: bodyPart,
            muscle: muscle,
          );

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SwapExerciseSheet(
                  repository: repository,
                  currentDefinition: current,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final equipmentLines =
              tester
                  .widgetList<Text>(find.byType(Text))
                  .where(
                    (text) =>
                        text.textSpan?.toPlainText().contains('Barbell') ??
                        false,
                  )
                  .toList();
          expect(equipmentLines, hasLength(2));

          final baseColor = theme.textTheme.bodySmall?.color;
          expect(baseColor, isNotNull);
          final expectedColor = baseColor!.withValues(
            alpha: theme.surfaceTokens.swapSecondaryTextOpacity,
          );
          for (final line in equipmentLines) {
            final equipmentSpan = _findSpan(line.textSpan!, 'Barbell');
            expect(equipmentSpan, isNotNull);
            expect(equipmentSpan!.style?.color, expectedColor);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

TextSpan? _findSpan(InlineSpan span, String text) {
  if (span is! TextSpan) return null;
  if (span.text?.contains(text) ?? false) return span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    final match = _findSpan(child, text);
    if (match != null) return match;
  }
  return null;
}

class _SwapRepository extends AppRepository {
  _SwapRepository({
    required this.definitions,
    required this.bodyPart,
    required this.muscle,
  });

  final List<ExerciseDefinition> definitions;
  final BodyPart bodyPart;
  final Muscle muscle;

  @override
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async => definitions;

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async =>
      definitions
          .where((definition) => definitionIds.contains(definition.id))
          .toList();

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int defId) async {
    for (final definition in definitions) {
      if (definition.id == defId) return definition;
    }
    return null;
  }

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async => {
    bodyPart: 1,
  };

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      [
        ExerciseMusclePercent(
          exerciseDefId: defId,
          muscleId: muscle.id,
          percent: 1,
        ),
      ];
}
