import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/widgets/body_heatmap.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:env_test/widgets/seven_day_focus_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Expressive hero preserves focus data and More action in both themes',
    (tester) async {
      var taps = 0;
      final hits = [
        FocusedSetHit(bodyPart: BodyPart(1, 'Shoulders'), units: 12),
        FocusedSetHit(bodyPart: BodyPart(2, 'Lower Back'), units: 3),
        FocusedSetHit(bodyPart: BodyPart(3, 'Core'), units: 2),
        FocusedSetHit(bodyPart: BodyPart(4, 'Quads'), units: 1),
      ];

      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? ExpressiveThemeDefinition.light()
            : ExpressiveThemeDefinition.dark();
        final tokens = theme.extension<AppExpressiveTrainTokens>()!;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: SevenDayFocusPresentation(
                  heatmapFrequencyMap: const {'Shoulders': 1, 'Core': 0.5},
                  hits: hits,
                  onFocusedSetsTap: () => taps++,
                ),
              ),
            ),
          ),
        );
        await _pumpFocusFrames(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('Weekly Overview'), findsOneWidget);
        expect(find.text('Shoulders'), findsOneWidget);
        expect(find.text('Lower Back'), findsOneWidget);
        expect(find.text('Core'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.byType(FocusedSetsList), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
        expect(
          find.byKey(const ValueKey('seven-day-focus-side-by-side')),
          findsOneWidget,
        );

        final hero = tester.widget<TonosSurface>(
          find.descendant(
            of: find.byType(SevenDayFocusPresentation),
            matching: find.byType(TonosSurface),
          ),
        );
        expect(hero.color, tokens.focusSurface);
        expect(hero.borderRadius, ExpressiveTrainShapes.focusHero);

        final heatmap = tester.widget<BodyHeatmap>(find.byType(BodyHeatmap));
        expect(
          heatmap.lowColor,
          tonosHeatmapLowForSurface(
            tester.element(find.byType(BodyHeatmap)),
            theme.surfaceTokens.dashboardHero,
          ),
        );
        expect(
          heatmap.highColor,
          tonosHeatmapHighForSurface(
            tester.element(find.byType(BodyHeatmap)),
            theme.surfaceTokens.dashboardHero,
          ),
        );

        final strings = AppLocalizations.of(
          tester.element(find.byType(SevenDayFocusPresentation)),
        );
        final moreText = find.text(strings.sevenDayFocusMore);
        final moreSemantics = tester.getSemantics(moreText);
        expect(
          moreSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          moreSemantics.getSemanticsData().flagsCollection.isButton,
          isTrue,
        );
        expect(
          tester.getSemantics(find.text('Shoulders')).id,
          moreSemantics.id,
          reason: 'focused-set rows and More form one details action',
        );
        if (brightness == Brightness.light) {
          await tester.tap(moreText);
          expect(taps, 1);
        }
      }
    },
  );

  testWidgets('Expressive hero stacks at compact width and 2x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SevenDayFocusPresentation(
              heatmapFrequencyMap: const {'Shoulders': 1},
              hits: [
                FocusedSetHit(bodyPart: BodyPart(1, 'Shoulders'), units: 12),
                FocusedSetHit(bodyPart: BodyPart(2, 'Lower Back'), units: 3),
                FocusedSetHit(bodyPart: BodyPart(3, 'Core'), units: 2),
              ],
              onFocusedSetsTap: () {},
            ),
          ),
        ),
      ),
    );
    await _pumpFocusFrames(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('seven-day-focus-stacked')),
      findsOneWidget,
    );
    expect(find.text('Weekly Overview'), findsOneWidget);
    expect(find.text('Shoulders'), findsOneWidget);
  });

  testWidgets('Expressive focus data appears immediately with a size reveal', (
    tester,
  ) async {
    Widget host({required bool loading}) => MaterialApp(
      theme: ExpressiveThemeDefinition.light(),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SevenDayFocusPresentation(
          heatmapFrequencyMap: const {'Shoulders': 1},
          hits: [FocusedSetHit(bodyPart: BodyPart(1, 'Shoulders'), units: 12)],
          onFocusedSetsTap: () {},
          loading: loading,
        ),
      ),
    );

    await tester.pumpWidget(host(loading: true));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('expressive-focus-loading')),
      findsOneWidget,
    );

    await tester.pumpWidget(host(loading: false));
    expect(find.byKey(const ValueKey('expressive-focus-data')), findsOneWidget);
    expect(find.text('Shoulders'), findsOneWidget);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: 180),
    );
  });

  testWidgets('Expressive focus content snaps while its tab is inactive', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SevenDayFocusPresentation(
            heatmapFrequencyMap: const {'Shoulders': 1},
            hits: [
              FocusedSetHit(bodyPart: BodyPart(1, 'Shoulders'), units: 12),
            ],
            onFocusedSetsTap: () {},
            motionEnabled: false,
          ),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });

  testWidgets('Expressive hero press response disables with reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ExpressiveThemeDefinition.light(),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: SevenDayFocusPresentation(
            heatmapFrequencyMap: const {},
            hits: const [],
            onFocusedSetsTap: () {},
          ),
        ),
      ),
    );
    await _pumpFocusFrames(tester);

    expect(find.byType(TonosExpressivePressResponse), findsOneWidget);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });

  testWidgets('Expressive details respond to press and respect TickerMode', (
    tester,
  ) async {
    var taps = 0;

    Future<void> pump({required bool tickersEnabled}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TickerMode(
            enabled: tickersEnabled,
            child: Scaffold(
              body: SevenDayFocusPresentation(
                heatmapFrequencyMap: const {},
                hits: [
                  FocusedSetHit(bodyPart: BodyPart(1, 'Shoulders'), units: 12),
                ],
                onFocusedSetsTap: () => taps++,
              ),
            ),
          ),
        ),
      );
      await _pumpFocusFrames(tester);
    }

    await pump(tickersEnabled: true);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: 180),
    );
    final responseFinder = find.byType(TonosExpressivePressResponse);
    expect(responseFinder, findsOneWidget);
    expect(
      tester.widget<TonosExpressivePressResponse>(responseFinder).pressedScale,
      0.965,
    );
    await tester.tap(find.text('Shoulders'));
    expect(taps, 1);

    await pump(tickersEnabled: false);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
    await tester.tap(find.text('Shoulders'));
    expect(taps, 2);
  });
}

Future<void> _pumpFocusFrames(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 400));
