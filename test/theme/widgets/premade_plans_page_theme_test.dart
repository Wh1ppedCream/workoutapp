import 'package:env_test/data/premade_training_plans.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/premade_plans_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final targetPlan = premadeTrainingPlans.firstWhere(
    (plan) =>
        plan.sourceName == 'Homemade' &&
        plan.durationMinutes == 60 &&
        plan.exercises.any(
          (exercise) =>
              exercise.catalogId != null && exercise.equipment != 'Dumbbell',
        ),
  );
  final targetExercise = targetPlan.exercises.firstWhere(
    (exercise) =>
        exercise.catalogId != null && exercise.equipment != 'Dumbbell',
  );
  final replacementName = 'Test replacement for ${targetExercise.name}';

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode onboarding plan action bar keeps theme ownership', (
        tester,
      ) async {
        var saves = 0;
        var cancels = 0;
        await tester.pumpWidget(
          _app(
            theme,
            OnboardingPlanActionBar(
              addedCount: 3,
              isBusy: false,
              onCancel: () => cancels++,
              onSave: () => saves++,
            ),
          ),
        );

        final barFinder = find.byType(OnboardingPlanActionBar);
        final context = tester.element(barFinder);
        final surfaces = context.surfaceTokens;
        final shapes = context.shapeTokens;
        final bar = tester.widget<Container>(
          find.descendant(
            of: barFinder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).border is Border,
            ),
          ),
        );
        final decoration = bar.decoration! as BoxDecoration;
        expect(decoration.color, surfaces.planActionBar);
        expect(
          (decoration.border! as Border).top,
          BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        );

        final badge = tester.widget<Container>(
          find.descendant(
            of: barFinder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).color ==
                      theme.colorScheme.error,
            ),
          ),
        );
        expect((badge.decoration! as BoxDecoration).borderRadius, shapes.pill);
        final badgeText = tester.widget<Text>(find.text('3'));
        expect(
          badgeText.style,
          TextStyle(
            color: theme.colorScheme.onError,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        );

        final saveFinder = find.byWidgetPredicate(
          (widget) => widget is FilledButton,
        );
        final cancelFinder = find.byType(OutlinedButton);
        expect(tester.widget<FilledButton>(saveFinder).onPressed, isNotNull);
        expect(
          tester.widget<OutlinedButton>(cancelFinder).onPressed,
          isNotNull,
        );
        if (family == AppThemeFamily.neoBrutalism) {
          final save = tester.widget<FilledButton>(saveFinder);
          final foreground = tonosForegroundForSurface(
            context,
            surfaces.planActionBar,
          );
          expect(save.style!.foregroundColor!.resolve(const {}), foreground);
          expect(
            save.style!.foregroundColor!.resolve({WidgetState.disabled}),
            foreground.withValues(alpha: 0.45),
          );
        }

        await tester.tap(saveFinder);
        await tester.tap(cancelFinder);
        await tester.pump();
        expect(saves, 1);
        expect(cancels, 1);

        await tester.pumpWidget(
          _app(
            theme,
            OnboardingPlanActionBar(
              addedCount: 3,
              isBusy: true,
              onCancel: () => cancels++,
              onSave: () => saves++,
            ),
          ),
        );
        expect(tester.widget<FilledButton>(saveFinder).onPressed, isNull);
        expect(tester.widget<OutlinedButton>(cancelFinder).onPressed, isNull);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$mode premade route reflows and renders token-owned plan states',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            'guided_tutorial_completed.${TutorialIds.premadePlans}': true,
          });
          tester.view.physicalSize = const Size(320, 1600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final original = _definition(
            id: 1001,
            catalogId: targetExercise.catalogId!,
            name: targetExercise.name,
            equipment: targetExercise.equipment,
          );
          final replacement = _definition(
            id: 1002,
            catalogId: 'tonos.exercise.9999',
            name: replacementName,
            equipment: 'Dumbbell',
          );
          final repository = _PremadePlansRepository(
            original: original,
            replacement: replacement,
          );

          await tester.pumpWidget(
            Provider<AppRepository>.value(
              value: repository,
              child: _app(
                theme,
                PremadePlansPage(
                  profileId: 1,
                  onPlanAdded: () {},
                  onboardingMode: true,
                ),
                textScale: 1.25,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pumpAndSettle();

          final pageFinder = find.byType(PremadePlansPage);
          final context = tester.element(pageFinder);
          final strings = AppLocalizations.of(context);
          final surfaces = context.surfaceTokens;
          final shapes = context.shapeTokens;
          final durationDecoration = find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color ==
                    surfaces.planDuration &&
                (widget.decoration as BoxDecoration).borderRadius ==
                    shapes.planCard,
          );
          expect(durationDecoration, findsOneWidget);

          final durationRow =
              find
                  .ancestor(
                    of: find.text(strings.premadeOneHour),
                    matching: find.byType(Row),
                  )
                  .first;
          final durationSwitch = find.descendant(
            of: durationRow,
            matching: find.byType(Switch),
          );
          expect(durationSwitch, findsOneWidget);
          expect(tester.widget<Switch>(durationSwitch).value, isFalse);
          expect(
            tester.getTopLeft(durationSwitch).dy,
            greaterThan(
              tester.getBottomLeft(find.text(strings.premadeDescription)).dy,
            ),
            reason: 'At narrow width, the duration control stacks below copy.',
          );
          await tester.tap(durationSwitch);
          await tester.pumpAndSettle();
          expect(tester.widget<Switch>(durationSwitch).value, isTrue);
          await tester.tap(durationSwitch);
          await tester.pumpAndSettle();
          expect(tester.widget<Switch>(durationSwitch).value, isFalse);

          final group = find.text(targetPlan.planGroupName).first;
          await tester.ensureVisible(group);
          await tester.tap(group);
          await tester.pumpAndSettle();

          final planName = find.text(targetPlan.name).first;
          await tester.ensureVisible(planName);
          await tester.tap(planName);
          await tester.pumpAndSettle();

          final swapLabel = find.text(strings.premadeProfileSwap);
          expect(swapLabel, findsOneWidget);
          final swapBadge = tester.widget<DecoratedBox>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).color ==
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: surfaces.planSwapBadgeOpacity,
                      ) &&
                  (widget.decoration as BoxDecoration).borderRadius ==
                      shapes.pill,
            ),
          );
          expect(
            (swapBadge.decoration as BoxDecoration).color,
            theme.colorScheme.primaryContainer.withValues(
              alpha: surfaces.planSwapBadgeOpacity,
            ),
          );
          final swapText = tester.widget<Text>(swapLabel);
          expect(swapText.style?.color, theme.colorScheme.onPrimaryContainer);
          expect(swapText.style?.fontWeight, FontWeight.w800);

          final exerciseRowText = tester.widget<RichText>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is RichText &&
                  widget.text.toPlainText().startsWith(replacementName),
            ),
          );
          final spans = _textSpans(exerciseRowText.text).toList();
          final nameSpan = spans.firstWhere(
            (span) => span.text == replacementName,
          );
          expect(nameSpan.style?.fontWeight, FontWeight.w700);
          expect(
            spans.any((span) => span.style?.color == theme.colorScheme.primary),
            isTrue,
            reason: 'Equipment detail keeps the theme primary foreground.',
          );
          expect(
            spans.any(
              (span) => span.style?.color == theme.colorScheme.onSurfaceVariant,
            ),
            isTrue,
            reason: 'Set/repetition detail keeps the secondary ink role.',
          );

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Widget _app(ThemeData theme, Widget child, {double textScale = 1}) =>
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
      home: Scaffold(body: child),
    );

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is! TextSpan) return;
  yield span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    yield* _textSpans(child);
  }
}

ExerciseDefinition _definition({
  required int id,
  required String catalogId,
  required String name,
  required String equipment,
}) => ExerciseDefinition(
  id: id,
  catalogId: catalogId,
  name: name,
  equipmentList: [Equipment(id, equipment)],
  useManualBodyparts: true,
  multiplyByRating: false,
);

class _PremadePlansRepository extends AppRepository {
  _PremadePlansRepository({required this.original, required this.replacement});

  final ExerciseDefinition original;
  final ExerciseDefinition replacement;
  final _bodyPart = BodyPart(1, 'Chest');

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => const [
    <String, dynamic>{'name': 'Dumbbell'},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [replacement];

  @override
  Future<ExerciseDefinition?> fetchDefinitionByCatalogId(
    String catalogId,
  ) async => catalogId == original.catalogId ? original : null;

  @override
  Future<int> findExerciseDefinitionId(String name, String equipmentName) =>
      Future.error(StateError('No matching test definition.'));

  @override
  Future<List<ExerciseDefinition>> searchExerciseDefinitions(
    String query,
  ) async => const [];

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async => {
    _bodyPart: 1,
  };

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      [ExerciseMusclePercent(exerciseDefId: defId, muscleId: 1, percent: 1)];
}
