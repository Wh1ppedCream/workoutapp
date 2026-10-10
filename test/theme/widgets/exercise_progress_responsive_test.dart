import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/services.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';
import 'package:env_test/widgets/exercise_progress_section.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Exercise Progress adapts to size and theme mode without overflow',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['2'],
      });
      final repository = _ExerciseProgressRepository();
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<double> pumpAt({
        required double width,
        required double textScale,
        AppThemeFamily family = AppThemeFamily.neoBrutalism,
        Brightness brightness = Brightness.light,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, 2200));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppThemeFactory.dark(family)
                  : AppThemeFactory.light(family),
              locale: const Locale('fr'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: ExerciseProgressSection()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = await AppLocalizations.delegate.load(
          const Locale('fr'),
        );
        expect(find.text(strings.exerciseProgressOneRepMax), findsOneWidget);
        expect(
          find.text(strings.exerciseProgressEstimatedOneRepMax),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        return tester
            .getSize(
              find.byKey(const ValueKey('exercise-progress-selector-strip')),
            )
            .height;
      }

      final narrowHeight = await pumpAt(width: 320, textScale: 1);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );

      final wideHeight = await pumpAt(width: 420, textScale: 1);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      expect(wideHeight, greaterThan(0));

      final largeTextHeight = await pumpAt(width: 420, textScale: 2);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      expect(largeTextHeight, greaterThan(wideHeight));

      await pumpAt(width: 320, textScale: 2);
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      await pumpAt(
        width: 393,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.light,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      await pumpAt(
        width: 393,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      await pumpAt(
        width: 420,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.light,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      await pumpAt(
        width: 420,
        textScale: 1,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-side-by-side')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      expect(narrowHeight, greaterThan(0));

      await pumpAt(
        width: 320,
        textScale: 2,
        family: AppThemeFamily.classic,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await pumpAt(
        width: 320,
        textScale: 1,
        family: AppThemeFamily.classic,
        brightness: Brightness.light,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      await pumpAt(
        width: 320,
        textScale: 1,
        family: AppThemeFamily.neoBrutalism,
        brightness: Brightness.dark,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-hero-stacked')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      for (final scale in [1.0, 1.15, 1.5, 2.0]) {
        await pumpAt(
          width: 320,
          textScale: scale,
          family: AppThemeFamily.neoBrutalism,
          brightness: Brightness.light,
        );
        expect(
          find.byKey(const ValueKey('exercise-progress-hero-stacked')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Exercise Progress exposes localized selector and remove semantics separately',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['1', '2', '3'],
      });
      final repository = _ExerciseProgressRepository();
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.binding.setSurfaceSize(const Size(320, 1600));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(child: ExerciseProgressSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final selectorStrip = find.byKey(
        const ValueKey('exercise-progress-selector-strip'),
      );
      await tester.drag(selectorStrip, const Offset(-1000, 0));
      await tester.pumpAndSettle();
      final editFinder = find.bySemanticsLabel(strings.commonEdit);
      await tester.ensureVisible(editFinder);
      await tester.tap(editFinder);
      await tester.pumpAndSettle();

      const localizedName =
          'Very long barbell pressing exercise name for layout testing';
      const selectorName =
          'Very long incline dumbbell press exercise name for layout testing';
      final heroRemoveLabel = strings.exerciseProgressRemoveExerciseLabel(
        localizedName,
      );
      final selectorRemoveLabel = strings.exerciseProgressRemoveExerciseLabel(
        selectorName,
      );
      final selectorWidgetFinder = find.byKey(
        const ValueKey('exercise-progress-selector-3'),
      );
      expect(selectorWidgetFinder, findsOneWidget);
      await tester.ensureVisible(selectorWidgetFinder);
      await tester.pumpAndSettle();
      final selectorNameTextFinder = find.text(selectorName);
      expect(selectorNameTextFinder, findsOneWidget);
      final selectorFinder = find.bySemanticsLabel(selectorName);
      final selectorRemoveFinder = find.bySemanticsLabel(selectorRemoveLabel);
      expect(selectorFinder, findsOneWidget);
      expect(selectorRemoveFinder, findsOneWidget);
      expect(selectorStrip, findsOneWidget);
      expect(
        find.byKey(const ValueKey('exercise-progress-selector-values-stacked')),
        findsWidgets,
      );

      final selectorNameText = tester.widget<Text>(selectorNameTextFinder);
      expect(selectorNameText.maxLines, isNull);
      expect(selectorNameText.overflow, isNull);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(selectorRemoveLabel), findsNothing);
      expect(find.bySemanticsLabel(selectorName), findsOneWidget);

      await tester.drag(selectorStrip, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.bySemanticsLabel(strings.commonEdit));
      await tester.pumpAndSettle();
      final heroRemoveFinder = find.bySemanticsLabel(selectorRemoveLabel);
      expect(heroRemoveFinder, findsOneWidget);

      await tester.tap(heroRemoveFinder);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(selectorRemoveLabel), findsNothing);
      expect(find.bySemanticsLabel(selectorName), findsNothing);
      expect(find.bySemanticsLabel(heroRemoveLabel), findsWidgets);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );

  testWidgets('Expressive Exercise Progress preserves chart series roles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'exercise_progress_tile_ids_v1': <String>['2'],
      'guided_tutorial_completed.exercise_progress_detail_v1': true,
    });
    final repository = _ExerciseProgressRepository(compactTrendValues: true);
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 1800));

    final expressiveTheme = ExpressiveThemeDefinition.light();
    final surfaces = expressiveTheme.surfaceTokens;
    final destinationTokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.progress,
      Brightness.light,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: expressiveTheme,
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AppExpressiveDestinationTheme(
                family: AppExpressiveDestinationFamily.progress,
                child: ExerciseProgressSection(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final heroSurface = tester.widget<Ink>(
      find.byKey(const ValueKey('exercise-progress-hero-surface')),
    );
    final heroDecoration = heroSurface.decoration as BoxDecoration;
    expect(heroDecoration.color, destinationTokens.surfacePrimary);
    expect(heroDecoration.border, isNull);

    final identity = find.byKey(
      const ValueKey('exercise-progress-expressive-identity'),
    );
    final identitySurface = tester.widget<Container>(
      find.ancestor(of: identity, matching: find.byType(Container)).first,
    );
    expect(
      (identitySurface.decoration! as BoxDecoration).color,
      destinationTokens.surfaceSelected,
    );
    expect(
      tester.widget<Text>(identity).style?.color,
      destinationTokens.onSurfaceSelected,
    );

    final action = tester.widget<FilledButton>(
      find.byKey(const ValueKey('exercise-progress-header-edit')),
    );
    final actionFill = action.style?.backgroundColor?.resolve(
      const <WidgetState>{},
    );
    final actionForeground = action.style?.foregroundColor?.resolve(
      const <WidgetState>{},
    );
    expect(actionFill, destinationTokens.surfaceSelected);
    expect(actionForeground, destinationTokens.onSurfaceSelected);
    expect(
      _contrastRatio(actionForeground!, actionFill!),
      greaterThanOrEqualTo(4.5),
    );

    await tester.tap(
      find.byKey(const ValueKey('exercise-progress-header-edit')),
    );
    await tester.pumpAndSettle();
    final addAction = tester.widget<Ink>(
      find.byKey(
        const ValueKey('exercise-progress-expressive-add-action-surface'),
      ),
    );
    expect(
      (addAction.decoration! as BoxDecoration).color,
      destinationTokens.surfaceSelected,
    );
    await tester.tap(
      find.byKey(const ValueKey('exercise-progress-header-edit')),
    );
    await tester.pumpAndSettle();

    final chartInset = tester.widget<Container>(
      find.byKey(const ValueKey('exercise-progress-expressive-chart-inset')),
    );
    expect((chartInset.decoration! as BoxDecoration).color, Colors.transparent);

    final summaryRail = tester.widget<Container>(
      find.byKey(const ValueKey('exercise-progress-expressive-summary-rail')),
    );
    expect(
      (summaryRail.decoration! as BoxDecoration).color,
      Colors.transparent,
    );

    final plot = find.byKey(const ValueKey('exercise-progress-hero-plot'));
    final plotDecoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(of: plot, matching: find.byType(DecoratedBox))
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(plotDecoration.color, expressiveTheme.colorScheme.surface);

    final plotContext = tester.element(plot);
    expect(
      find.descendant(of: plot, matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
    final visualization = expressiveTheme
        .extension<AppDataVisualizationTokens>()!;
    final actualSeries = tonosPrimarySeriesForSurface(
      plotContext,
      surfaces.exerciseProgressHero,
    );
    final estimatedSeries = tonosSecondarySeriesForSurface(
      plotContext,
      surfaces.exerciseProgressHero,
    );
    expect(actualSeries, visualization.primarySeries);
    expect(estimatedSeries, visualization.secondarySeries);
    expect(actualSeries, isNot(estimatedSeries));
    expect(_contrastRatio(actualSeries, plotDecoration.color!), greaterThan(3));
    expect(
      _contrastRatio(estimatedSeries, plotDecoration.color!),
      greaterThan(3),
    );
    expect(
      _contrastRatio(plotContext.progressColors.label, plotDecoration.color!),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(
        tonosForegroundForSurface(
          plotContext,
          surfaces.exerciseProgressTooltip,
        ),
        surfaces.exerciseProgressTooltip,
      ),
      greaterThan(4.5),
    );
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);

  testWidgets(
    'Expressive Progress secondary previews echo the primary card in both modes',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['2'],
      });
      final repository = _ExerciseProgressRepository(compactTrendValues: true);
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.dark
            ? ExpressiveThemeDefinition.dark()
            : ExpressiveThemeDefinition.light();
        final roles = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          brightness,
        );
        await tester.binding.setSurfaceSize(const Size(390, 1800));
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
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: AppExpressiveDestinationTheme(
                    family: AppExpressiveDestinationFamily.progress,
                    child: ExerciseProgressSection(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final hero = tester.widget<Ink>(
          find.byKey(const ValueKey('exercise-progress-hero-surface')),
        );
        expect((hero.decoration! as BoxDecoration).color, roles.surfacePrimary);

        final selector = find.byKey(
          const ValueKey('exercise-progress-selector-2'),
        );
        expect(selector, findsOneWidget);
        final selectorSurface = tester.widget<Ink>(
          find.byKey(
            const ValueKey('exercise-progress-selector-surface-2'),
          ),
        );
        expect(
          (selectorSurface.decoration! as BoxDecoration).color,
          roles.surfacePrimary,
        );
        final identity = find.byKey(
          const ValueKey('exercise-progress-selector-identity-2'),
        );
        final identityDecoration =
            tester.widget<Container>(identity).decoration! as BoxDecoration;
        expect(identityDecoration.color, roles.surfaceSelected);
        final identityText = tester.widget<Text>(
          find.descendant(
            of: identity,
            matching: find.text(
              'Very long Romanian deadlift exercise name for layout testing',
            ),
          ),
        );
        expect(identityText.style!.color, roles.onSurfaceSelected);
        expect(
          _contrastRatio(identityText.style!.color!, identityDecoration.color!),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          find.descendant(of: selector, matching: find.byType(CustomPaint)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
    semanticsEnabled: true,
  );

  testWidgets(
    'Classic and Neo Exercise Progress resolve selected and selector series by surface',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['2'],
      });
      final repository = _ExerciseProgressRepository(compactTrendValues: true);
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 1600));

      for (final family in [
        AppThemeFamily.classic,
        AppThemeFamily.neoBrutalism,
      ]) {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: family == AppThemeFamily.classic
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: SingleChildScrollView(child: ExerciseProgressSection()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaces = tester.element(find.byType(Scaffold)).surfaceTokens;
        final hero = find.byKey(
          const ValueKey('exercise-progress-hero-surface'),
        );
        final heroChart = find
            .descendant(of: hero, matching: find.byType(CustomPaint))
            .first;
        final heroContext = tester.element(heroChart);
        expect(
          tonosPrimarySeriesForSurface(
            heroContext,
            surfaces.exerciseProgressHero,
          ),
          isNot(
            tonosSecondarySeriesForSurface(
              heroContext,
              surfaces.exerciseProgressHero,
            ),
          ),
        );

        final selector = find.byKey(
          const ValueKey('exercise-progress-selector-2'),
        );
        final selectorChart = find
            .descendant(of: selector, matching: find.byType(CustomPaint))
            .first;
        final selectorContext = tester.element(selectorChart);
        expect(
          tonosPrimarySeriesForSurface(
            selectorContext,
            surfaces.exerciseProgressSelector,
          ),
          isNot(
            tonosSecondarySeriesForSurface(
              selectorContext,
              surfaces.exerciseProgressSelector,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Exercise Progress chart exposes one navigable semantic point', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'exercise_progress_tile_ids_v1': <String>['2'],
      'guided_tutorial_completed.exercise_progress_detail_v1': true,
    });
    final repository = _ExerciseProgressRepository(compactTrendValues: true);
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 1800));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: ExerciseProgressSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final hero = find.byKey(const ValueKey('exercise-progress-hero-stacked'));
    await tester.ensureVisible(hero);
    await tester.tap(
      find.ancestor(of: hero, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    final chart = find.byKey(
      const ValueKey('exercise-progress-chart-semantics'),
    );
    expect(chart, findsOneWidget);
    var data = tester.getSemantics(chart).getSemanticsData();
    expect(data.flagsCollection.isFocused, isNot(Tristate.none));
    expect(data.label, contains('Very long barbell pressing exercise'));
    expect(data.label, contains('Estimated 1RM'));
    expect(data.label, contains('Actual 1RM'));
    expect(data.label, contains('lbs'));
    expect(data.value, contains('Est.'));
    expect(data.value, contains('Actual'));
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);

    final chartBox = tester.getRect(chart);
    final latestPointValue = data.value;
    await tester.ensureVisible(chart);
    await tester.tapAt(chartBox.topLeft + const Offset(28, 100));
    await tester.pump();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, contains('100'));
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    final firstPointValue = data.value;
    expect(firstPointValue, isNot(latestPointValue));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    data = tester.getSemantics(chart).getSemanticsData();
    expect(data.value, latestPointValue);
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);

  testWidgets('Exercise Progress chart reports an honest empty state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'exercise_progress_tile_ids_v1': <String>['2'],
      'guided_tutorial_completed.exercise_progress_detail_v1': true,
    });
    final repository = _ExerciseProgressRepository(emptyTrend: true);
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 1800));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppRepository>.value(value: repository),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
        ],
        child: MaterialApp(
          theme: AppThemeFactory.light(AppThemeFamily.classic),
          locale: const Locale('en'),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: ExerciseProgressSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final hero = find.byKey(const ValueKey('exercise-progress-hero-stacked'));
    await tester.ensureVisible(hero);
    await tester.tap(
      find.ancestor(of: hero, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    final emptyChart = find.byKey(
      const ValueKey('exercise-progress-chart-empty-semantics'),
    );
    expect(emptyChart, findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('exercise-progress-detail-chart-frame'),
            ),
          )
          .height,
      220,
      reason: 'Classic empty-chart presentation remains unchanged',
    );
    final data = tester.getSemantics(emptyChart).getSemanticsData();
    expect(data.label, contains('Very long barbell pressing exercise'));
    expect(data.value, 'No recordings yet');
    expect(
      find.byKey(const ValueKey('exercise-progress-chart-semantics')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);

  testWidgets('Expressive empty 1RM detail stays compact and adaptive', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'exercise_progress_tile_ids_v1': <String>['2'],
      'guided_tutorial_completed.exercise_progress_detail_v1': true,
    });
    final repository = _ExerciseProgressRepository(emptyTrend: true);
    final units = UnitPreferenceProvider();
    await units.ready;
    addTearDown(units.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<double> pumpEmptyDetail({
      required double textScale,
      double width = 320,
      double height = 1800,
    }) async {
      await tester.binding.setSurfaceSize(Size(width, height));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<UnitPreferenceProvider>.value(value: units),
          ],
          child: MaterialApp(
            key: ValueKey(
              'expressive-empty-progress-$width-$height-$textScale',
            ),
            theme: ExpressiveThemeDefinition.light(),
            locale: const Locale('en'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AppExpressiveDestinationTheme(
                  family: AppExpressiveDestinationFamily.progress,
                  child: ExerciseProgressSection(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hero = find.byKey(const ValueKey('exercise-progress-hero-surface'));
      expect(hero, findsOneWidget);
      await tester.ensureVisible(hero);
      await tester.tap(hero);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('exercise-progress-expressive-detail-chart')),
        findsOneWidget,
      );
      final detailScaffold = find.ancestor(
        of: find.byKey(
          const ValueKey('exercise-progress-expressive-detail-chart'),
        ),
        matching: find.byType(Scaffold),
      );
      expect(detailScaffold, findsOneWidget);
      expect(
        tester.widget<Scaffold>(detailScaffold).backgroundColor,
        AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          Brightness.light,
        ).pageCanvas,
      );
      expect(
        find.byKey(
          const ValueKey('exercise-progress-expressive-detail-empty-plot'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('exercise-progress-expressive-detail-legend'),
        ),
        findsNothing,
      );
      expect(find.text('No recordings yet'), findsOneWidget);
      expect(
        find.text('Complete this exercise to start building progress history.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      return tester
          .getSize(
            find.byKey(const ValueKey('exercise-progress-detail-chart-frame')),
          )
          .height;
    }

    final normalHeight = await pumpEmptyDetail(textScale: 1);
    expect(normalHeight, 112);
    final largeTextHeight = await pumpEmptyDetail(textScale: 2);
    expect(largeTextHeight, 140);
    expect(largeTextHeight, lessThan(220));

    for (final layout in [
      (width: 600.0, height: 1000.0, scale: 1.3),
      (width: 800.0, height: 390.0, scale: 1.5),
      (width: 1024.0, height: 768.0, scale: 2.0),
    ]) {
      final chartHeight = await pumpEmptyDetail(
        textScale: layout.scale,
        width: layout.width,
        height: layout.height,
      );
      expect(chartHeight, greaterThan(0), reason: '$layout');
      expect(chartHeight, lessThan(220), reason: '$layout');
      expect(tester.takeException(), isNull, reason: '$layout');
      await tester.pumpWidget(const SizedBox.shrink());
    }
  }, semanticsEnabled: true);

  testWidgets(
    'Expressive Exercise Progress composes home and recordings accessibly',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'exercise_progress_tile_ids_v1': <String>['2'],
        'guided_tutorial_completed.exercise_progress_detail_v1': true,
      });
      final repository = _ExerciseProgressRepository(
        compactTrendValues: true,
        noLatestActual: true,
      );
      final units = UnitPreferenceProvider();
      await units.ready;
      addTearDown(units.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<void> pumpExpressive({
        required double width,
        double height = 2100,
        required double textScale,
        Brightness brightness = Brightness.light,
      }) async {
        await tester.binding.setSurfaceSize(Size(width, height));
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? ExpressiveThemeDefinition.dark()
                  : ExpressiveThemeDefinition.light(),
              locale: const Locale('en'),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: AppExpressiveDestinationTheme(
                    family: AppExpressiveDestinationFamily.progress,
                    child: ExerciseProgressSection(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      for (final scale in [1.0, 1.15, 1.5, 2.0]) {
        await pumpExpressive(width: 320, textScale: scale);
        if (scale == 1) {
          final roles = AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.progress,
            Brightness.light,
          );
          final shell = tester.widget<TonosSurface>(
            find.byKey(const ValueKey('exercise-progress-expressive-shell')),
          );
          expect(shell.variant, TonosSurfaceVariant.panel);
          expect(shell.color, roles.pageCanvas);
          expect(
            tester
                .widget<Text>(
                  find.byKey(
                    const ValueKey('exercise-progress-expressive-title'),
                  ),
                )
                .style
                ?.color,
            ExpressiveThemeDefinition.light().colorScheme.onSurface,
          );
          final hero = tester.widget<Ink>(
            find.byKey(const ValueKey('exercise-progress-hero-surface')),
          );
          expect(
            (hero.decoration! as BoxDecoration).color,
            roles.surfacePrimary,
          );
          final identity = find.byKey(
            const ValueKey('exercise-progress-expressive-identity'),
          );
          final identitySurface = tester.widget<Container>(
            find.ancestor(of: identity, matching: find.byType(Container)).first,
          );
          expect(
            (identitySurface.decoration! as BoxDecoration).color,
            roles.surfaceSelected,
          );
          expect(
            tester.widget<Text>(identity).style?.color,
            roles.onSurfaceSelected,
          );
          expect(
            (tester
                        .widget<Container>(
                          find.byKey(
                            const ValueKey(
                              'exercise-progress-expressive-chart-inset',
                            ),
                          ),
                        )
                        .decoration!
                    as BoxDecoration)
                .color,
            Colors.transparent,
          );
          expect(
            (tester
                        .widget<Container>(
                          find.byKey(
                            const ValueKey(
                              'exercise-progress-expressive-summary-rail',
                            ),
                          ),
                        )
                        .decoration!
                    as BoxDecoration)
                .color,
            Colors.transparent,
          );
        }
        expect(
          find.byKey(
            const ValueKey('exercise-progress-expressive-hero-stacked'),
          ),
          findsOneWidget,
        );
        final rail = find.byKey(
          const ValueKey('exercise-progress-expressive-summary-rail'),
        );
        expect(rail, findsOneWidget);
        final railRect = tester.getRect(rail);
        expect(railRect.left, greaterThanOrEqualTo(0));
        expect(railRect.right, lessThanOrEqualTo(320));
        expect(
          find.byKey(const ValueKey('exercise-progress-header-edit')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: rail,
            matching: find.text(strings.exerciseProgressActual),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: rail, matching: find.text('—')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: rail,
            matching: find.text(strings.exerciseProgressEstimatedOneRepMax),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: rail,
            matching: find.text(
              WeightUnitFormatter.formatWeight(
                111,
                units.weightUnit,
                locale: const Locale('en'),
              ),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: rail, matching: find.text('0 lbs')),
          findsOneWidget,
        );
        if (scale == 1) {
          final neutralDelta = find.descendant(
            of: rail,
            matching: find.text('0 lbs'),
          );
          final neutralDeltaColor = tester
              .widget<Text>(neutralDelta)
              .style
              ?.color;
          final lightRoles = AppExpressiveDestinationTokens.forFamily(
            AppExpressiveDestinationFamily.progress,
            Brightness.light,
          );
          expect(
            neutralDeltaColor,
            lightRoles.onSurfacePrimary.withValues(alpha: 0.78),
          );
          expect(
            _contrastRatio(neutralDeltaColor!, lightRoles.surfacePrimary),
            greaterThanOrEqualTo(4.5),
          );
        }
        expect(
          find.descendant(of: rail, matching: find.text('--')),
          findsNothing,
        );
        final actualSemantics = tester
            .getSemantics(find.bySemanticsLabel(strings.exerciseProgressActual))
            .getSemanticsData();
        expect(actualSemantics.label, strings.exerciseProgressActual);
        expect(actualSemantics.value, strings.exerciseProgressNoActual);
        expect(tester.takeException(), isNull);
      }

      for (final scale in [1.0, 1.15, 1.5, 2.0]) {
        await pumpExpressive(width: 420, textScale: scale);
        expect(
          find.byKey(const ValueKey('exercise-progress-expressive-title')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }

      for (final layout in [
        (width: 600.0, height: 1000.0, scale: 1.3),
        (width: 800.0, height: 390.0, scale: 1.5),
        (width: 1024.0, height: 768.0, scale: 2.0),
      ]) {
        await pumpExpressive(
          width: layout.width,
          height: layout.height,
          textScale: layout.scale,
        );
        final hero = find.byKey(
          const ValueKey('exercise-progress-hero-surface'),
        );
        expect(hero, findsOneWidget, reason: 'home at $layout');
        await tester.ensureVisible(hero);
        await tester.tap(hero);
        await tester.pumpAndSettle();
        expect(
          find.byKey(
            const ValueKey('exercise-progress-expressive-detail-chart'),
          ),
          findsOneWidget,
          reason: 'detail chart at $layout',
        );
        final recordingsHeading = find.text(strings.exerciseProgressRecordings);
        await tester.scrollUntilVisible(
          recordingsHeading,
          160,
          scrollable: find.byType(Scrollable).last,
        );
        expect(
          find.byKey(
            const ValueKey('exercise-progress-expressive-recordings-group'),
          ),
          findsOneWidget,
          reason: 'recordings at $layout',
        );
        expect(tester.takeException(), isNull, reason: 'detail at $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }

      await pumpExpressive(
        width: 390,
        textScale: 1,
        brightness: Brightness.dark,
      );
      final darkRoles = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.progress,
        Brightness.dark,
      );
      expect(
        tester
            .widget<TonosSurface>(
              find.byKey(const ValueKey('exercise-progress-expressive-shell')),
            )
            .color,
        darkRoles.pageCanvas,
      );
      expect(
        tester
            .widget<TonosSurface>(
              find.byKey(const ValueKey('exercise-progress-expressive-shell')),
            )
            .variant,
        TonosSurfaceVariant.panel,
      );
      expect(
        (tester
                    .widget<Ink>(
                      find.byKey(
                        const ValueKey('exercise-progress-hero-surface'),
                      ),
                    )
                    .decoration!
                as BoxDecoration)
            .color,
        darkRoles.surfacePrimary,
      );
      final darkIdentity = find.byKey(
        const ValueKey('exercise-progress-expressive-identity'),
      );
      final darkIdentitySurface = tester.widget<Container>(
        find.ancestor(of: darkIdentity, matching: find.byType(Container)).first,
      );
      expect(
        (darkIdentitySurface.decoration! as BoxDecoration).color,
        darkRoles.surfaceSelected,
      );
      expect(
        tester.widget<Text>(darkIdentity).style?.color,
        darkRoles.onSurfaceSelected,
      );
      final darkSummaryRail = find.byKey(
        const ValueKey('exercise-progress-expressive-summary-rail'),
      );
      final darkNeutralDelta = find.descendant(
        of: darkSummaryRail,
        matching: find.text('0 lbs'),
      );
      final darkNeutralDeltaColor = tester
          .widget<Text>(darkNeutralDelta)
          .style
          ?.color;
      expect(
        darkNeutralDeltaColor,
        darkRoles.onSurfacePrimary.withValues(alpha: 0.78),
      );
      expect(
        _contrastRatio(darkNeutralDeltaColor!, darkRoles.surfacePrimary),
        greaterThanOrEqualTo(4.5),
      );
      final darkPlot = find.byKey(
        const ValueKey('exercise-progress-hero-plot'),
      );
      final darkPlotContext = tester.element(darkPlot);
      final darkTheme = Theme.of(darkPlotContext);
      final darkSurfaces = darkPlotContext.surfaceTokens;
      final darkVisualization = darkTheme
          .extension<AppDataVisualizationTokens>()!;
      final darkActualSeries = tonosPrimarySeriesForSurface(
        darkPlotContext,
        darkSurfaces.exerciseProgressHero,
      );
      final darkEstimatedSeries = tonosSecondarySeriesForSurface(
        darkPlotContext,
        darkSurfaces.exerciseProgressHero,
      );
      final darkPlotBox = tester.widget<DecoratedBox>(
        find
            .descendant(of: darkPlot, matching: find.byType(DecoratedBox))
            .first,
      );
      final darkPlotSurface = (darkPlotBox.decoration as BoxDecoration).color!;
      expect(darkActualSeries, darkVisualization.primarySeries);
      expect(darkEstimatedSeries, darkVisualization.secondarySeries);
      expect(_contrastRatio(darkActualSeries, darkPlotSurface), greaterThan(3));
      expect(
        _contrastRatio(darkEstimatedSeries, darkPlotSurface),
        greaterThan(3),
      );
      expect(
        _contrastRatio(darkPlotContext.progressColors.label, darkPlotSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(
          tonosForegroundForSurface(
            darkPlotContext,
            darkSurfaces.exerciseProgressTooltip,
          ),
          darkSurfaces.exerciseProgressTooltip,
        ),
        greaterThan(4.5),
      );
      final edit = find.byKey(const ValueKey('exercise-progress-header-edit'));
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.text(strings.commonDone), findsOneWidget);
      expect(find.bySemanticsLabel(strings.commonAdd), findsOneWidget);
      await tester.tap(edit);
      await tester.pumpAndSettle();

      // The most-used fixture (definition 1) is the default selection; choose
      // definition 2, then verify its selected hero semantics and session rows.
      final selector = find.byKey(
        const ValueKey('exercise-progress-selector-2'),
      );
      await tester.ensureVisible(selector);
      await tester.tap(selector);
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(
                'Very long Romanian deadlift exercise name for layout testing',
              ),
            )
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );

      final heroSurface = find.byKey(
        const ValueKey('exercise-progress-hero-surface'),
      );
      // The keyed tonal surface wraps the semantic InkWell rather than being
      // its descendant, so tap the surface's center and assert the detail
      // navigation it exposes.
      await tester.tap(heroSurface);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('exercise-progress-expressive-detail-chart')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('exercise-progress-expressive-detail-plot-inset'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('exercise-progress-expressive-recordings-group'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('exercise-progress-expressive-recording-22')),
        findsOneWidget,
      );
      expect(find.text(strings.exerciseProgressNoActual), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

class _ExerciseProgressRepository extends AppRepository {
  final bool emptyTrend;
  final bool compactTrendValues;
  final bool noLatestActual;

  _ExerciseProgressRepository({
    this.emptyTrend = false,
    this.compactTrendValues = false,
    this.noLatestActual = false,
  });

  final _definitions = <ExerciseDefinition>[
    ExerciseDefinition(
      id: 1,
      name: 'Very long barbell pressing exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Very long Romanian deadlift exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 3,
      name: 'Very long incline dumbbell press exercise name for layout testing',
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchMostUsedExerciseDefinitionsRaw({
    int limit = 5,
  }) async => <Map<String, dynamic>>[
    <String, dynamic>{'definition_id': 1},
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => [
    for (final definition in _definitions)
      if (definitionIds.contains(definition.id)) definition,
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchExerciseOneRmTrendRows({
    required int definitionId,
    int limit = 60,
  }) async => emptyTrend
      ? []
      : [
          <String, dynamic>{
            'session_id': definitionId * 10 + 1,
            'session_date': '2026-01-01T00:00:00.000Z',
            'completed_at_ms': DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
            'training_day': '2026-01-01',
            'actual_one_rm': compactTrendValues ? 100 : 1000000,
            'estimated_one_rm': noLatestActual && compactTrendValues
                ? 111
                : compactTrendValues
                ? 101
                : 1000001,
          },
          <String, dynamic>{
            'session_id': definitionId * 10 + 2,
            'session_date': '2026-01-02T00:00:00.000Z',
            'completed_at_ms': DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
            'training_day': '2026-01-02',
            'actual_one_rm': noLatestActual
                ? null
                : compactTrendValues
                ? 110
                : 9999999,
            'estimated_one_rm': compactTrendValues ? 111 : 10000000,
          },
        ];
}
