import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_detail_screen.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/body_heatmap.dart';
import 'package:env_test/widgets/exercise_card.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Session Detail surfaces use existing theme owners', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
        });
        final units = UnitPreferenceProvider();
        await units.ready;
        addTearDown(units.dispose);

        final repository = _SessionDetailRepository();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SessionDetailScreen(
                WorkoutSession(
                  id: 4,
                  date: DateTime(2026, 9, 26, 12),
                  duration: 2700,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaces = theme.extension<AppSurfaceTokens>()!;
        final shapes = theme.extension<AppShapeTokens>()!;
        final metricTiles = tester
            .widgetList<Container>(find.byType(Container))
            .where((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.sessionSummary &&
                  decoration.borderRadius == shapes.metric;
            })
            .toList();
        expect(metricTiles, hasLength(3));

        final setIndex = tester.widget<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is! Container ||
                widget.constraints !=
                    const BoxConstraints.tightFor(width: 28, height: 28)) {
              return false;
            }
            final decoration = widget.decoration;
            return decoration is BoxDecoration &&
                decoration.color == surfaces.panelRaised &&
                decoration.shape == BoxShape.circle;
          }),
        );
        expect(
          setIndex.constraints,
          const BoxConstraints.tightFor(width: 28, height: 28),
        );
        expect(tester.takeException(), isNull);

        final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
        await tester.ensureVisible(saveAsPlan);
        await tester.tap(saveAsPlan);
        await tester.pumpAndSettle();

        final fieldFinder = find.byKey(AppTestKeys.workoutPlanName);
        final inputDecoratorFinder = find.descendant(
          of: fieldFinder,
          matching: find.byType(InputDecorator),
        );
        expect(inputDecoratorFinder, findsOneWidget);
        final inputDecorator = tester.widget<InputDecorator>(
          inputDecoratorFinder,
        );
        expect(inputDecorator.decoration.labelText, isNotNull);
        final dialogInputTheme = Theme.of(tester.element(fieldFinder))
            .inputDecorationTheme;
        if (family == AppThemeFamily.neoBrutalism) {
          expect(dialogInputTheme.filled, isTrue);
          expect(dialogInputTheme.fillColor, surfaces.dialogChoice);
        } else {
          expect(dialogInputTheme, theme.inputDecorationTheme);
        }

        final strings = AppLocalizations.of(tester.element(fieldFinder));
        final saveDialog = find.byType(AlertDialog);
        expect(saveDialog, findsOneWidget);
        expect(
          find.descendant(
            of: saveDialog,
            matching: find.text(strings.workoutDetailSaveAsPlan),
          ),
          findsOneWidget,
        );
        expect(find.text(strings.workoutDetailPlanName), findsOneWidget);
        final planSave = find.byKey(AppTestKeys.workoutPlanSave);
        final cancel = find.text(strings.commonCancel);
        expect(planSave, findsOneWidget);
        expect(tester.widget<FilledButton>(planSave).onPressed, isNotNull);
        expect(
          find.ancestor(of: cancel, matching: find.byType(TextButton)),
          findsOneWidget,
        );
        expect(
          tester.getRect(planSave).left,
          greaterThan(tester.getRect(cancel).left),
          reason: 'Save is the primary trailing dialog action',
        );
        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip(strings.workoutDetailDeleteSession));
        await tester.pumpAndSettle();
        expect(find.text(strings.workoutDetailDeleteTitle), findsOneWidget);
        expect(find.text(strings.workoutDetailDeleteBody), findsOneWidget);
        final deleteAction = find.ancestor(
          of: find.text(strings.commonDelete),
          matching: find.byType(TextButton),
        );
        expect(deleteAction, findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(strings.commonDelete),
            matching: find.byType(FilledButton),
          ),
          findsNothing,
        );
        expect(
          find.ancestor(
            of: find.text(strings.commonCancel),
            matching: find.byType(TextButton),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(SessionDetailScreen), findsOneWidget);
        expect(repository.deleteSessionCalls, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'Expressive Session Detail retains summary data and save action',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      final theme = ExpressiveThemeDefinition.light();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: _SessionDetailRepository()),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SessionDetailScreen(
              WorkoutSession(
                id: 4,
                date: DateTime(2026, 9, 26, 12),
                duration: 2700,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(SessionDetailScreen)),
      );
      final title = find.text(strings.workoutDetailPastWorkout);
      expect(title, findsOneWidget);
      expect(
        tester.widget<Text>(title).style?.color,
        theme.extension<AppExpressiveTrainTokens>()!.focusForeground,
      );
      expect(find.text(strings.workoutDetailCompletedSets(1)), findsOneWidget);
      expect(find.text(strings.workoutDetailVolume), findsOneWidget);
      expect(find.text(strings.workoutDetailDuration), findsOneWidget);
      expect(find.text(strings.workoutDetailExercises), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);

      final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
      expect(saveAsPlan, findsOneWidget);
      expect(tester.widget<OutlinedButton>(saveAsPlan).onPressed, isNotNull);
      await tester.ensureVisible(saveAsPlan);
      await tester.tap(saveAsPlan);
      await tester.pumpAndSettle();
      expect(find.byKey(AppTestKeys.workoutPlanName), findsOneWidget);
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets('Session Detail edit cards opt in only for Expressive', (
    tester,
  ) async {
    final cases = <({ThemeData theme, bool expressive})>[
      (theme: AppThemeFactory.light(AppThemeFamily.classic), expressive: false),
      (theme: ExpressiveThemeDefinition.light(), expressive: true),
    ];

    for (final testCase in cases) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: _SessionDetailRepository()),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: testCase.theme,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SessionDetailScreen(
              WorkoutSession(
                id: 4,
                date: DateTime(2026, 9, 26, 12),
                duration: 2700,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(SessionDetailScreen)),
      );
      await tester.tap(find.byTooltip(strings.workoutDetailEditSession));
      await tester.pumpAndSettle();

      final exerciseCard = tester.widget<ExerciseCard>(
        find.byType(ExerciseCard),
      );
      expect(exerciseCard.expressiveWorkoutPresentation, testCase.expressive);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'Expressive Session Detail summary and action dock reflow responsively',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      final repository = _SessionDetailRepository(includeBodyParts: true);
      final theme = ExpressiveThemeDefinition.light();

      Future<void> pumpAt({
        required double width,
        required double scale,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, 1800));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.logbook,
                child: SessionDetailScreen(
                  WorkoutSession(
                    id: 4,
                    date: DateTime(2026, 9, 26, 12),
                    duration: 2700,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 520));
        await tester.pumpAndSettle();
      }

      await pumpAt(width: 393, scale: 1);
      final strings = AppLocalizations.of(
        tester.element(find.byType(SessionDetailScreen)),
      );
      final completedSetsLabel = find.text(
        strings.workoutDetailCompletedSets(1),
      );
      final completedSetsBadge = find.ancestor(
        of: completedSetsLabel,
        matching: find.byType(DecoratedBox),
      );
      final completedSetsBadgePadding = find.descendant(
        of: completedSetsBadge,
        matching: find.byType(Padding),
      );
      expect(
        tester.widget<Padding>(completedSetsBadgePadding).padding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
      final metricLabels = [
        find.text(strings.workoutDetailVolume),
        find.text(strings.workoutDetailDuration),
        find.text(strings.workoutDetailExercises),
      ];
      final metricTileRects = metricLabels
          .map(
            (label) => tester.getRect(
              find.ancestor(of: label, matching: find.byType(Container)).first,
            ),
          )
          .toList();
      final metricTopEdges = metricTileRects.map((rect) => rect.top);
      expect(
        metricTopEdges.reduce((a, b) => a > b ? a : b) -
            metricTopEdges.reduce((a, b) => a < b ? a : b),
        lessThan(1),
        reason: 'All three metric tiles share a top edge at 393dp.',
      );

      final heatmap = tester.getRect(find.byType(BodyHeatmap));
      final focusedSets = tester.getRect(find.text(strings.focusedSetsTitle));
      expect(heatmap.right, lessThan(focusedSets.left));
      expect((heatmap.top - focusedSets.top).abs(), lessThan(24));

      final repeatButton = find.ancestor(
        of: find.text(strings.workoutDetailRepeat),
        matching: find.byType(FilledButton),
      );
      final saveButton = find.byKey(AppTestKeys.workoutSaveAsPlan);
      expect(repeatButton, findsOneWidget);
      expect(saveButton, findsOneWidget);
      final repeatRect = tester.getRect(repeatButton);
      final saveRect = tester.getRect(saveButton);
      expect((repeatRect.center.dy - saveRect.center.dy).abs(), lessThan(3));
      expect(repeatRect.right, lessThanOrEqualTo(saveRect.left));
      expect(tester.getSize(repeatButton).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(saveButton).height, greaterThanOrEqualTo(48));
      expect(tester.widget<FilledButton>(repeatButton).onPressed, isNotNull);
      expect(tester.widget<OutlinedButton>(saveButton).onPressed, isNotNull);
      expect(
        tester.getSize(find.text(strings.workoutDetailRepeat)).height,
        lessThan(42),
      );
      expect(
        tester.getSize(find.text(strings.workoutDetailSaveAsPlan)).height,
        lessThan(42),
      );
      expect(tester.takeException(), isNull);

      await pumpAt(width: 393, scale: 1.15);
      final normalScaleRepeatRect = tester.getRect(repeatButton);
      final normalScaleSaveRect = tester.getRect(saveButton);
      expect(
        (normalScaleRepeatRect.center.dy - normalScaleSaveRect.center.dy).abs(),
        lessThan(3),
      );

      await pumpAt(width: 393, scale: 1.5);
      final scaledRepeatRect = tester.getRect(repeatButton);
      final scaledSaveRect = tester.getRect(saveButton);
      expect(scaledSaveRect.top, greaterThanOrEqualTo(scaledRepeatRect.bottom));
      expect(scaledRepeatRect.overlaps(scaledSaveRect), isFalse);

      await pumpAt(width: 320, scale: 1.5);
      final narrowHeatmap = tester.getRect(find.byType(BodyHeatmap));
      final narrowFocusedSets = tester.getRect(
        find.text(strings.focusedSetsTitle),
      );
      expect(narrowFocusedSets.top, greaterThanOrEqualTo(narrowHeatmap.bottom));

      await pumpAt(width: 320, scale: 2);
      final narrowRepeatRect = tester.getRect(repeatButton);
      final narrowSaveRect = tester.getRect(saveButton);
      expect(narrowRepeatRect.overlaps(narrowSaveRect), isFalse);
      expect(narrowSaveRect.top, greaterThanOrEqualTo(narrowRepeatRect.bottom));
      expect(narrowRepeatRect.left, greaterThanOrEqualTo(0));
      expect(narrowSaveRect.left, greaterThanOrEqualTo(0));
      expect(narrowRepeatRect.right, lessThanOrEqualTo(320));
      expect(narrowSaveRect.right, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive Logbook Session Detail uses destination dialog actions',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(320, 1800));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      final repository = _SessionDetailRepository();
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final destinationTokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.logbook,
          brightness,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.logbook,
                child: SessionDetailScreen(
                  WorkoutSession(
                    id: 4,
                    date: DateTime(2026, 9, 26, 12),
                    duration: 2700,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 520));
        await tester.pumpAndSettle();

        void expectDialogWithinSurface() {
          final rect = tester.getRect(find.byType(AlertDialog));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(320));
          expect(rect.bottom, lessThanOrEqualTo(1800));
          expect(tester.takeException(), isNull);
        }

        final detail = find.byType(SessionDetailScreen);
        expect(
          Theme.of(tester.element(detail))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.logbook,
        );
        final strings = AppLocalizations.of(tester.element(detail));
        await tester.ensureVisible(find.byKey(AppTestKeys.workoutSaveAsPlan));
        await tester.tap(find.byKey(AppTestKeys.workoutSaveAsPlan));
        await tester.pumpAndSettle();

        final field = find.byKey(AppTestKeys.workoutPlanName);
        final fieldTheme = Theme.of(tester.element(field)).inputDecorationTheme;
        expect(fieldTheme.filled, isTrue);
        expect(fieldTheme.fillColor, destinationTokens.surfaceAccent);
        final saveDialog = find.byType(AlertDialog);
        expect(saveDialog, findsOneWidget);
        expectDialogWithinSurface();
        expect(
          find.descendant(
            of: saveDialog,
            matching: find.text(strings.workoutDetailSaveAsPlan),
          ),
          findsOneWidget,
        );
        expect(find.text(strings.workoutDetailPlanName), findsOneWidget);
        final save = tester.widget<FilledButton>(
          find.byKey(AppTestKeys.workoutPlanSave),
        );
        expect(
          save.style?.backgroundColor?.resolve(const <WidgetState>{}),
          destinationTokens.actionPrimary,
        );
        expect(
          find.ancestor(
            of: find.text(strings.commonCancel),
            matching: find.byType(TextButton),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip(strings.workoutDetailDeleteSession));
        await tester.pumpAndSettle();
        expect(find.text(strings.workoutDetailDeleteTitle), findsOneWidget);
        expect(find.text(strings.workoutDetailDeleteBody), findsOneWidget);
        expectDialogWithinSurface();
        final deleteAction = find.ancestor(
          of: find.text(strings.commonDelete),
          matching: find.byType(FilledButton),
        );
        expect(deleteAction, findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(deleteAction)
              .style
              ?.backgroundColor
              ?.resolve(const <WidgetState>{}),
          theme.extension<AppSemanticColors>()!.negative,
        );
        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(SessionDetailScreen), findsOneWidget);
        expect(repository.deleteSessionCalls, 0);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Expressive Session Detail remains usable at 320dp across text scales',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(320, 1800));

      final repository = _SessionDetailRepository();
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        for (final scale in [1.0, 1.15, 1.5, 2.0]) {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                locale: const Locale('en'),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: SessionDetailScreen(
                  WorkoutSession(
                    id: 4,
                    date: DateTime(2026, 9, 26, 12),
                    duration: 2700,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final strings = AppLocalizations.of(
            tester.element(find.byType(SessionDetailScreen)),
          );
          expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
          expect(
            find.text(strings.workoutDetailCompletedSets(1)),
            findsOneWidget,
          );
          expect(find.text(strings.workoutDetailVolume), findsOneWidget);
          expect(find.text(strings.workoutDetailDuration), findsOneWidget);
          expect(find.text(strings.workoutDetailExercises), findsOneWidget);
          if (scale >= 1.8) {
            final metricRail = tester.widget<Wrap>(
              find
                  .ancestor(
                    of: find.text(strings.workoutDetailVolume),
                    matching: find.byType(Wrap),
                  )
                  .first,
            );
            expect(
              (metricRail.children.first as SizedBox).width,
              greaterThan(200),
            );

            final exerciseTitle = find.text('Squat');
            expect(tester.widget<Text>(exerciseTitle).maxLines, isNull);
            expect(
              tester
                  .renderObject<RenderParagraph>(exerciseTitle)
                  .didExceedMaxLines,
              isFalse,
            );
          }

          final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
          expect(saveAsPlan, findsOneWidget);
          expect(
            tester.widget<OutlinedButton>(saveAsPlan).onPressed,
            isNotNull,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, text scale $scale',
          );

          await tester.ensureVisible(saveAsPlan);
          await tester.tap(saveAsPlan);
          await tester.pumpAndSettle();
          expect(find.byKey(AppTestKeys.workoutPlanName), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '${brightness.name}, dialog at scale $scale',
          );
          await tester.tap(find.text(strings.commonCancel));
          await tester.pumpAndSettle();
        }
      }
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Expressive Logbook Session Detail keeps metadata and actions reachable '
    'across viewport classes',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guided_tutorial_completed.${TutorialIds.workoutDetail}': true,
      });
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      final repository = _SessionDetailRepository(includeBodyParts: true);
      const viewports = <({String label, Size size})>[
        (label: '320dp compact phone', size: Size(320, 760)),
        (label: '390dp phone', size: Size(390, 844)),
        (label: '600dp compact tablet', size: Size(600, 960)),
        (label: '800dp tablet', size: Size(800, 1100)),
        (label: '640dp compact landscape', size: Size(640, 360)),
      ];

      Future<void> pumpAt({
        required Size size,
        required double scale,
        required Brightness brightness,
        EdgeInsets viewInsets = EdgeInsets.zero,
      }) async {
        await tester.binding.setSurfaceSize(size);
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  viewInsets: viewInsets,
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.logbook,
                child: SessionDetailScreen(
                  WorkoutSession(
                    id: 4,
                    date: DateTime(2026, 9, 26, 12),
                    duration: 2700,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 520));
        await tester.pumpAndSettle();
      }

      for (final brightness in Brightness.values) {
        for (final viewport in viewports) {
          for (final scale in [1.0, 1.5, 2.0]) {
            await pumpAt(
              size: viewport.size,
              scale: scale,
              brightness: brightness,
            );
            final detail = find.byType(SessionDetailScreen);
            final strings = AppLocalizations.of(tester.element(detail));
            final list = find.byKey(AppTestKeys.workoutDetailList);
            expect(find.text(strings.workoutDetailPastWorkout), findsOneWidget);
            expect(
              find.text(strings.workoutDetailCompletedSets(1)),
              findsOneWidget,
            );
            for (final label in [
              strings.workoutDetailVolume,
              strings.workoutDetailDuration,
              strings.workoutDetailExercises,
            ]) {
              expect(find.text(label), findsOneWidget, reason: label);
            }

            expect(list, findsOneWidget);
            final scrollable = find.descendant(
              of: list,
              matching: find.byType(Scrollable),
            );
            await tester.scrollUntilVisible(
              find.text('Squat'),
              180,
              scrollable: scrollable,
            );
            await tester.pumpAndSettle();
            expect(find.text('Squat'), findsOneWidget);
            await tester.ensureVisible(find.text('Squat'));
            await tester.pumpAndSettle();
            final titleRect = tester.getRect(find.text('Squat'));
            final listRect = tester.getRect(list);
            expect(titleRect.bottom, greaterThan(listRect.top));
            expect(titleRect.top, lessThan(listRect.bottom));

            final repeat = find.ancestor(
              of: find.text(strings.workoutDetailRepeat),
              matching: find.byType(FilledButton),
            );
            final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
            expect(repeat, findsOneWidget);
            expect(saveAsPlan, findsOneWidget);
            final actionRects = [
              tester.getRect(repeat),
              tester.getRect(saveAsPlan),
            ];
            for (final rect in actionRects) {
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(viewport.size.width));
              expect(rect.top, greaterThanOrEqualTo(0));
              expect(rect.bottom, lessThanOrEqualTo(viewport.size.height));
            }
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${viewport.label}, '
                  '${scale}x, ${brightness.name}',
            );
          }
        }
      }

      const compactSize = Size(320, 760);
      const keyboardInset = 260.0;
      await pumpAt(
        size: compactSize,
        scale: 2,
        brightness: Brightness.light,
        viewInsets: const EdgeInsets.only(bottom: keyboardInset),
      );
      final saveAsPlan = find.byKey(AppTestKeys.workoutSaveAsPlan);
      await tester.ensureVisible(saveAsPlan);
      await tester.tap(saveAsPlan);
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      final availableBottom = compactSize.height - keyboardInset;
      final dialogSurface = find
          .descendant(of: dialog, matching: find.byType(Material))
          .first;
      expect(
        tester.getRect(dialogSurface).bottom,
        lessThanOrEqualTo(availableBottom),
      );
      final nameField = find.byKey(AppTestKeys.workoutPlanName);
      expect(nameField, findsOneWidget);
      final save = find.byKey(AppTestKeys.workoutPlanSave);
      await tester.ensureVisible(save);
      expect(
        tester.getRect(nameField).bottom,
        lessThanOrEqualTo(availableBottom),
      );
      expect(tester.getRect(save).bottom, lessThanOrEqualTo(availableBottom));
      final strings = AppLocalizations.of(
        tester.element(find.byType(SessionDetailScreen)),
      );
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  test('active-workout screen styles have exact measured ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final expectedRules = <(String, String, String, int)>[
      (
        'lib/screens/exercise/session_screen.dart',
        'text_style',
        'session-screen-timer-material-typography',
        1,
      ),
      (
        'lib/screens/exercise/session_screen.dart',
        'color',
        'session-screen-completion-sheet-surface',
        1,
      ),
      (
        'lib/screens/exercise/session_detail_screen.dart',
        'decoration',
        'session-detail-summary-material-and-token-owners',
        5,
      ),
    ];

    for (final (file, kind, id, count) in expectedRules) {
      final rule = inventory.ruleFor(file, kind);
      expect(rule?.id, id);
      expect(rule?.status, 'migrated');
      expect(
        report.findings.where((finding) => finding.ruleId == id),
        hasLength(count),
      );
    }

    final explicitSessionRuleIds = expectedRules.map((rule) => rule.$3).toSet();
    final explicitSessionFindings = report.findings.where(
      (finding) => explicitSessionRuleIds.contains(finding.ruleId),
    );
    expect(explicitSessionFindings, hasLength(7));
    expect(
      explicitSessionFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );
    final releaseScreenFindings = report.findings.where(
      (finding) =>
          finding.ruleId == 'release-screens' &&
          (finding.file == 'lib/screens/exercise/session_screen.dart' ||
              finding.file ==
                  'lib/screens/exercise/session_detail_screen.dart'),
    );
    expect(releaseScreenFindings, isNotEmpty);
    expect(
      releaseScreenFindings.map((finding) => finding.status),
      everyElement('pending'),
    );

    final sessionSource = File('lib/screens/exercise/session_screen.dart')
        .readAsStringSync();
    expect(sessionSource, contains('Theme.of(context).textTheme.bodyMedium'));
    expect(
      sessionSource,
      contains('context.surfaceDecorationTokens.sheet.outlined'),
    );
    final detailSource = File('lib/screens/exercise/session_detail_screen.dart')
        .readAsStringSync();
    expect(detailSource, contains('styleFormControls: true'));
    expect(detailSource, contains(': surfaces.sessionSummary),'));
    expect(detailSource, contains(': shapes.metric,'));
    expect(detailSource, contains('color: surfaces.panelRaised'));
    expect(detailSource, contains('shape: BoxShape.circle'));
  });
}

class _SessionDetailRepository extends AppRepository {
  _SessionDetailRepository({this.includeBodyParts = false});

  final bool includeBodyParts;
  int deleteSessionCalls = 0;

  @override
  Future<void> deleteSession(int id) async {
    deleteSessionCalls++;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExercises(int sessionId) async => [
    <String, dynamic>{'id': 8, 'type': 'weight', 'exercise_def_id': 12},
  ];

  @override
  Future<Map<int, WorkoutExerciseRecordBadges>> fetchSessionRecordBadges(
    int sessionId,
  ) async => const <int, WorkoutExerciseRecordBadges>{};

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int definitionId) async =>
      const <String, String?>{'name': 'Squat', 'equipmentName': 'Barbell'};

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int definitionId) async =>
      null;

  @override
  Future<List<Map<String, dynamic>>> fetchSets(int exerciseId) async => [
    <String, dynamic>{
      'id': 20,
      'parent_set_id': null,
      'weight': 100.0,
      'reps': 5,
    },
  ];

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(
    int definitionId,
  ) async => includeBodyParts
      ? <BodyPart, double>{BodyPart(1, 'Chest'): 1, BodyPart(2, 'Quads'): 0.5}
      : const <BodyPart, double>{};
}
