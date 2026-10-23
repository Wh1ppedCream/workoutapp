import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/swap_exercise_sheet.dart';
import 'package:material_ui/material_ui.dart';
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
      report.findings
          .where(
            (finding) =>
                finding.file == rule.pattern && finding.status == 'pending',
          )
          .toList(),
      isEmpty,
      reason: report.findings
          .where(
            (finding) =>
                finding.file == rule.pattern && finding.status == 'pending',
          )
          .map(
            (finding) => '${finding.line} ${finding.kind}: ${finding.snippet}',
          )
          .join('\n'),
    );
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
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
              localizationsDelegates: tonosLocalizationDelegates,
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

          final equipmentLines = tester
              .widgetList<Text>(find.byType(Text))
              .where(
                (text) =>
                    text.textSpan?.toPlainText().contains('Barbell') ?? false,
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
            if (theme.usesExpressivePresentation) {
              final planning = AppExpressivePlanningTokens.maybeOf(
                tester.element(find.byWidget(line)),
              )!;
              final card = tester.widget<Card>(
                find
                    .ancestor(
                      of: find.byWidget(line),
                      matching: find.byType(Card),
                    )
                    .first,
              );
              final foreground = card.color == planning.planSupportSurface
                  ? planning.planSupportForeground
                  : planning.configurationForeground;
              expect(
                equipmentSpan!.style?.color,
                foreground.withValues(
                  alpha: theme.surfaceTokens.swapSecondaryTextOpacity,
                ),
              );
            } else {
              expect(equipmentSpan!.style?.color, expectedColor);
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();

    testWidgets(
      'Expressive ${brightness.name} swap sheet uses planning surfaces and fixed actions',
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
            localizationsDelegates: tonosLocalizationDelegates,
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

        final planning = AppExpressivePlanningTokens.maybeOf(
          tester.element(find.byType(SwapExerciseSheet)),
        )!;
        final strings = AppLocalizations.of(
          tester.element(find.byType(SwapExerciseSheet)),
        );
        expect(find.text(strings.swapCurrent), findsOneWidget);
        expect(find.text(strings.swapReplacement), findsOneWidget);
        expect(find.text(strings.swapBodyPartsWorked), findsNWidgets(2));

        final currentCard = tester.widget<Card>(
          find
              .ancestor(
                of: find.text(strings.swapCurrent),
                matching: find.byType(Card),
              )
              .first,
        );
        final replacementCard = tester.widget<Card>(
          find
              .ancestor(
                of: find.text(strings.swapReplacement),
                matching: find.byType(Card),
              )
              .first,
        );
        expect(currentCard.color, planning.planSupportSurface);
        expect(replacementCard.color, planning.configurationSurface);

        final confirmButton = tester.widget<FilledButton>(
          find
              .ancestor(
                of: find.text(strings.swapConfirm),
                matching: find.byType(FilledButton),
              )
              .first,
        );
        expect(
          confirmButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
          planning.actionPrimary,
        );
        expect(find.text(strings.commonCancel).hitTestable(), findsOneWidget);
        expect(find.text(strings.swapConfirm).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Expressive swap load failures can be retried', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bodyPart = BodyPart(4, 'Chest');
    final muscle = Muscle(id: 7, name: 'Pectoralis major');
    ExerciseDefinition definition(int id, String name) => ExerciseDefinition(
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
      failFirstFilteredLookup: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
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

    final strings = AppLocalizations.of(
      tester.element(find.byType(SwapExerciseSheet)),
    );
    expect(find.text(strings.commonRetry), findsOneWidget);
    await tester.tap(find.text(strings.commonRetry));
    await tester.pumpAndSettle();
    expect(find.text(strings.swapReplacement), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
    this.failFirstFilteredLookup = false,
  });

  final List<ExerciseDefinition> definitions;
  final BodyPart bodyPart;
  final Muscle muscle;
  bool failFirstFilteredLookup;

  @override
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async {
    if (failFirstFilteredLookup) {
      failFirstFilteredLookup = false;
      throw StateError('temporary filtered lookup failure');
    }
    return definitions;
  }

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => definitions
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
