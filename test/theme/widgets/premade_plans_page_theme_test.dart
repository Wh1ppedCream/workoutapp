import 'package:env_test/data/premade_training_plans.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/premade_plans_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:material_ui/material_ui.dart';
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
      final theme = brightness == Brightness.light
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
        final planning = AppExpressivePlanningTokens.maybeOf(context);
        expect(
          decoration.color,
          planning?.actionSecondary ?? surfaces.planActionBar,
        );
        expect(
          (decoration.border! as Border).top,
          BorderSide(
            color:
                planning?.outline ??
                theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
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
          final isExpressive =
              AppExpressivePlanningTokens.maybeOf(context) != null;
          if (isExpressive) {
            expect(
              strings.premadeExpressivePlansCount(1),
              '1 plan',
              reason: 'Expressive plan counts use singular English wording.',
            );
            expect(
              strings.premadeExpressivePlansCount(2),
              '2 plans',
              reason: 'Expressive plan counts use plural English wording.',
            );
          }
          if (isExpressive) {
            // This deliberately incomplete equipment fixture has no compatible
            // complete plans. Expressive hides them until filtering is off.
            expect(find.byType(ExpansionTile), findsNothing);
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
          }
          final sourceExpansion = isExpressive
              ? find
                    .ancestor(
                      of: find.text(strings.premadeBuiltinPlansTitle),
                      matching: find.byType(ExpansionTile),
                    )
                    .first
              : find.byType(ExpansionTile).first;
          final sourcePressResponse = find.ancestor(
            of: sourceExpansion,
            matching: find.byType(TonosExpressivePressResponse),
          );
          expect(sourcePressResponse.evaluate().toList(), isEmpty);
          if (isExpressive) {
            final durationSelector = find.byType(SegmentedButton<int>);
            expect(durationSelector, findsOneWidget);
            final durationLabel = find.text(strings.optimizedWorkoutDuration);
            expect(durationLabel, findsOneWidget);
            expect(
              tester.widget<SegmentedButton<int>>(durationSelector).selected,
              {60},
            );
            expect(
              tester.getBottomLeft(durationLabel).dy,
              lessThan(tester.getTopLeft(durationSelector).dy),
            );
            final inlineDuration = find
                .ancestor(of: durationSelector, matching: find.byType(AppBar))
                .evaluate()
                .isNotEmpty;
            final introTop = tester
                .getTopLeft(find.text(strings.premadeExpressiveDescription))
                .dy;
            expect(
              tester.getTopLeft(durationSelector).dy,
              inlineDuration ? lessThan(introTop) : greaterThan(introTop),
              reason:
                  'The selector follows the approved narrow-toolbar fallback.',
            );
            final selector = tester.widget<SegmentedButton<int>>(
              durationSelector,
            );
            expect(
              selector.style!.backgroundColor!.resolve({WidgetState.selected}),
              AppExpressivePlanningTokens.maybeOf(context)!.actionPrimary,
            );
            await tester.tap(find.text(strings.premadeExpressiveTwoHours));
            await tester.pumpAndSettle();
            expect(
              tester.widget<SegmentedButton<int>>(durationSelector).selected,
              {120},
            );
            await tester.tap(find.text(strings.premadeExpressiveOneHour));
            await tester.pumpAndSettle();
            expect(
              tester.widget<SegmentedButton<int>>(durationSelector).selected,
              {60},
            );
            expect(find.text(strings.premadeBuiltinPlansTitle), findsOneWidget);
          } else {
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
            final durationRow = find
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
            await tester.tap(durationSwitch);
            await tester.pumpAndSettle();
            expect(tester.widget<Switch>(durationSwitch).value, isTrue);
            await tester.tap(durationSwitch);
            await tester.pumpAndSettle();
            expect(tester.widget<Switch>(durationSwitch).value, isFalse);
          }

          final group = find.text(targetPlan.planGroupName).first;
          await tester.ensureVisible(group);
          await tester.tap(group);
          await tester.pumpAndSettle();
          if (isExpressive) {
            final equipmentSwitch = find.byType(Switch);
            expect(tester.widget<Switch>(equipmentSwitch).value, isFalse);
            expect(
              find.text(strings.premadeExpressiveEquipmentAll),
              findsOneWidget,
            );

            final planCard = find.byKey(ValueKey(targetPlan.id));
            expect(planCard, findsOneWidget);
            final planName = find.descendant(
              of: planCard,
              matching: find.text(targetPlan.name),
            );
            await tester.ensureVisible(planName);
            await tester.tap(planName);
            await tester.pumpAndSettle();
            expect(find.text(strings.premadeProfileSwap), findsNothing);
            final categoryHeader = tester.widget<DecoratedBox>(
              find.byKey(
                ValueKey('premade-category-header-${targetPlan.planGroupName}'),
              ),
            );
            final categoryDecoration =
                categoryHeader.decoration as BoxDecoration;
            final expressiveTokens = AppExpressivePlanningTokens.maybeOf(
              context,
            )!;
            expect(
              categoryDecoration.color,
              Color.lerp(
                expressiveTokens.configurationSurface,
                expressiveTokens.planSupportSurface,
                0.18,
              ),
            );
            expect(categoryDecoration.borderRadius, expressiveTokens.rowShape);
            final previewExerciseName = find.descendant(
              of: planCard,
              matching: find.text(targetExercise.name),
            );
            expect(previewExerciseName, findsOneWidget);
            final previewDetails = find.descendant(
              of: find
                  .ancestor(
                    of: previewExerciseName,
                    matching: find.byType(Column),
                  )
                  .first,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Text && widget.data?.contains(' × ') == true,
              ),
            );
            expect(previewDetails, findsOneWidget);
            final previewDetailsText = tester
                .widget<Text>(previewDetails)
                .data!;
            expect(previewDetailsText, contains('${targetExercise.sets}'));
            expect(previewDetailsText, contains('${targetExercise.reps}'));
            if (targetExercise.name.toLowerCase().contains(
              targetExercise.equipment.toLowerCase(),
            )) {
              expect(
                previewDetailsText.toLowerCase(),
                isNot(contains(targetExercise.equipment.toLowerCase())),
                reason:
                    'Equipment already in the exercise name is not repeated.',
              );
            }
            expect(
              find.byWidgetPredicate(
                (widget) =>
                    widget is RichText &&
                    widget.text.toPlainText().startsWith(targetExercise.name),
              ),
              findsOneWidget,
              reason: 'The plan preview keeps its authored exercise unchanged.',
            );
          } else {
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
              spans.any(
                (span) => span.style?.color == theme.colorScheme.primary,
              ),
              isTrue,
              reason: 'Equipment detail keeps the theme primary foreground.',
            );
            expect(
              spans.any(
                (span) =>
                    span.style?.color == theme.colorScheme.onSurfaceVariant,
              ),
              isTrue,
              reason: 'Set/repetition detail keeps the secondary ink role.',
            );
          }

          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final entry in <(String, ThemeData, AppExpressivePlanningTokens)>[
    (
      'light',
      ExpressiveThemeDefinition.light(),
      AppExpressivePlanningTokens.light,
    ),
    (
      'dark',
      ExpressiveThemeDefinition.dark(),
      AppExpressivePlanningTokens.dark,
    ),
  ]) {
    testWidgets('Expressive ${entry.$1} premade plans preserve filter state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.${TutorialIds.premadePlans}': true,
      });
      tester.view.physicalSize = const Size(320, 1800);
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
            entry.$2,
            PremadePlansPage(
              profileId: 1,
              onPlanAdded: () {},
              onboardingMode: true,
            ),
            textScale: 2.0,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final page = find.byType(PremadePlansPage);
      final context = tester.element(page);
      final strings = AppLocalizations.of(context);
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: page, matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.backgroundColor, entry.$3.pageCanvas);
      final filterSurface = entry.$2.brightness == Brightness.dark
          ? entry.$3.configurationSurface
          : Color.lerp(entry.$3.equipmentSurface, entry.$3.pageCanvas, 0.14)!;
      final filterCard = find
          .ancestor(
            of: find.text(strings.premadeEquipmentFilterLabel),
            matching: find.byType(Card),
          )
          .first;
      expect(tester.widget<Card>(filterCard).color, filterSurface);
      expect(
        find.text(strings.premadeExpressiveEquipmentNoMatches),
        findsOneWidget,
        reason: 'The visibility filter explains when no plans qualify.',
      );

      final durationSelector = find.byType(SegmentedButton<int>);
      expect(durationSelector, findsOneWidget);
      expect(tester.widget<SegmentedButton<int>>(durationSelector).selected, {
        60,
      });
      await tester.tap(find.text(strings.premadeExpressiveTwoHours));
      await tester.pumpAndSettle();
      expect(tester.widget<SegmentedButton<int>>(durationSelector).selected, {
        120,
      });
      await tester.tap(find.text(strings.premadeExpressiveOneHour));
      await tester.pumpAndSettle();
      expect(tester.widget<SegmentedButton<int>>(durationSelector).selected, {
        60,
      });

      final equipmentRow = find
          .ancestor(
            of: find.text(strings.premadeEquipmentFilterLabel),
            matching: find.byType(Row),
          )
          .first;
      final equipmentSwitch = find.descendant(
        of: equipmentRow,
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(equipmentSwitch).value, isTrue);
      await tester.tap(equipmentSwitch);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(equipmentSwitch).value, isFalse);
      expect(find.text(strings.premadeExpressiveEquipmentAll), findsOneWidget);
      final homemadeSixtyMinutePlanCount = premadeTrainingPlans
          .where(
            (plan) =>
                plan.sourceName == 'Homemade' && plan.durationMinutes == 60,
          )
          .length;
      expect(
        find.text(
          strings.premadeExpressivePlansAvailable(homemadeSixtyMinutePlanCount),
        ),
        findsOneWidget,
        reason: 'Available count follows the selected duration and filter.',
      );
      final builtInPlansCard = find
          .ancestor(
            of: find.text(strings.premadeBuiltinPlansTitle),
            matching: find.byType(Card),
          )
          .first;
      final homemadeTwoHourPlanCount = premadeTrainingPlans
          .where(
            (plan) =>
                plan.sourceName == 'Homemade' && plan.durationMinutes == 120,
          )
          .length;
      await tester.tap(find.text(strings.premadeExpressiveTwoHours));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: builtInPlansCard,
          matching: find.text(
            strings.premadeExpressivePlansAvailable(homemadeTwoHourPlanCount),
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(strings.premadeExpressiveOneHour));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: builtInPlansCard,
          matching: find.text(
            strings.premadeExpressivePlansAvailable(
              homemadeSixtyMinutePlanCount,
            ),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Card && widget.color == entry.$3.planFocalSurface,
        ),
        findsWidgets,
      );
      final planGroup = find.text(targetPlan.planGroupName).first;
      await tester.ensureVisible(planGroup);
      await tester.drag(find.byType(ListView).first, const Offset(0, -360));
      await tester.pumpAndSettle();
      await tester.tap(planGroup);
      await tester.pumpAndSettle();
      final planCard = find.byKey(ValueKey(targetPlan.id));
      expect(planCard, findsOneWidget);
      expect(
        tester
            .widget<Card>(
              find.descendant(of: planCard, matching: find.byType(Card)).first,
            )
            .color,
        Color.lerp(
          entry.$3.configurationSurface,
          entry.$3.planSupportSurface,
          entry.$2.brightness == Brightness.dark ? 0.18 : 0.22,
        ),
      );

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, strings.premadeReviewPlans),
      );
      expect(saveButton.onPressed, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive ${brightness.name} premade plan keeps Add beside its title when wide',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.premadePlans}': true,
        });
        tester.view.physicalSize = const Size(600, 1200);
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
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();

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
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(PremadePlansPage)),
        );
        final equipmentSwitch = find.byType(Switch);
        expect(tester.widget<Switch>(equipmentSwitch).value, isTrue);
        await tester.tap(equipmentSwitch);
        await tester.pumpAndSettle();

        final category = find.text(targetPlan.planGroupName).first;
        await tester.ensureVisible(category);
        await tester.tap(category);
        await tester.pumpAndSettle();
        final planCard = find.byKey(ValueKey(targetPlan.id));
        final planTitle = find.descendant(
          of: planCard,
          matching: find.text(targetPlan.name),
        );
        await tester.ensureVisible(planTitle);
        await tester.tap(planTitle);
        await tester.pumpAndSettle();

        final addButton = find.descendant(
          of: planCard,
          matching: find.widgetWithText(FilledButton, strings.commonAdd),
        );
        expect(addButton, findsOneWidget);
        final titleRect = tester.getRect(planTitle);
        final addButtonRect = tester.getRect(addButton);
        expect(
          (titleRect.top - addButtonRect.top).abs(),
          lessThan(8),
          reason: 'At a roomy width, Add shares the plan title row.',
        );
        expect(tester.widget<FilledButton>(addButton).onPressed, isNotNull);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('Premade plan adapts across layouts', (tester) async {
    const layouts = <({Size size, double scale})>[
      (size: Size(320, 900), scale: 1),
      (size: Size(320, 900), scale: 2),
      (size: Size(390, 844), scale: 1.5),
      (size: Size(600, 1000), scale: 1.5),
      (size: Size(800, 390), scale: 1.5),
      (size: Size(1024, 768), scale: 2),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in Brightness.values) {
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.premadePlans}': true,
        });
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
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();

        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: repository,
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(layout.scale)),
                child: child!,
              ),
              home: PremadePlansPage(
                profileId: 1,
                onPlanAdded: () {},
                onboardingMode: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final page = find.byType(PremadePlansPage);
        final strings = AppLocalizations.of(tester.element(page));
        final durationLabel = find.text(strings.premadeExpressiveOneHour);
        await tester.ensureVisible(durationLabel);
        final durationSelector = find.byType(SegmentedButton<int>);
        expect(
          durationSelector.hitTestable(),
          findsOneWidget,
          reason: '$layout',
        );
        await tester.tap(find.text(strings.premadeExpressiveTwoHours));
        await tester.pumpAndSettle();
        expect(tester.widget<SegmentedButton<int>>(durationSelector).selected, {
          120,
        });
        expect(tester.takeException(), isNull, reason: '$brightness $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

Widget _app(ThemeData theme, Widget child, {double textScale = 1}) =>
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
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
