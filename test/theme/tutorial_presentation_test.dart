import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_tutorial_tokens.dart';
import 'package:env_test/widgets/guided_tutorial_overlay.dart';
import 'package:env_test/widgets/onboarding_plan_builder_coach.dart';

Widget _host(
  Widget child, {
  AppTutorialTokens tokens = AppTutorialTokens.classic,
  bool reduced = false,
}) {
  final base = ClassicThemeDefinition.light();
  return MaterialApp(
    theme: base.copyWith(
      extensions: [
        ...base.extensions.values.where((e) => e is! AppTutorialTokens),
        tokens,
      ],
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder:
        (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
    home: Scaffold(body: child),
  );
}

void main() {
  test('tutorial recipes copy and interpolate every field', () {
    const base = AppTutorialTokens.classic;
    final target = base.copyWith(
      focusShape: BorderRadius.circular(2),
      cardShape: BorderRadius.circular(3),
      iconShape: BorderRadius.circular(4),
      coachShape: BorderRadius.circular(5),
      coachIconShape: BorderRadius.circular(6),
      inputShape: BorderRadius.circular(7),
      tileShape: BorderRadius.circular(8),
      sectionShape: BorderRadius.circular(9),
      compactShape: BorderRadius.circular(10),
      heroShape: BorderRadius.circular(11),
      pillShape: BorderRadius.circular(12),
      scrim: const Color(0xFF123456),
      measuringScrim: const Color(0xFF123456),
      confirmationScrim: const Color(0xFF123456),
      coachScrim: const Color(0xFF123456),
      accentForeground: const Color(0xFF123456),
      focusShadowOpacity: 0.12,
      focusShadowBlur: 7,
      focusShadowSpread: 3,
      focusShadowOffset: const Offset(1, 2),
      cardShadow: const BoxShadow(color: Colors.red, blurRadius: 4),
      coachShadow: const BoxShadow(color: Colors.red, blurRadius: 4),
      pageDuration: const Duration(milliseconds: 10),
      selectionDuration: const Duration(milliseconds: 10),
      guidedScrollDuration: const Duration(milliseconds: 10),
      coachDuration: const Duration(milliseconds: 10),
      effectsEnabled: false,
    );
    final midpoint = base.lerp(target, 0.5);
    expect(target.focusShape, BorderRadius.circular(2));
    expect(base.copyWith().focusShape, base.focusShape);
    expect(
      midpoint.focusShape,
      BorderRadius.lerp(base.focusShape, target.focusShape, 0.5),
    );
    expect(target.cardShape, BorderRadius.circular(3));
    expect(base.copyWith().cardShape, base.cardShape);
    expect(
      midpoint.cardShape,
      BorderRadius.lerp(base.cardShape, target.cardShape, 0.5),
    );
    expect(target.iconShape, BorderRadius.circular(4));
    expect(base.copyWith().iconShape, base.iconShape);
    expect(
      midpoint.iconShape,
      BorderRadius.lerp(base.iconShape, target.iconShape, 0.5),
    );
    expect(target.coachShape, BorderRadius.circular(5));
    expect(base.copyWith().coachShape, base.coachShape);
    expect(
      midpoint.coachShape,
      BorderRadius.lerp(base.coachShape, target.coachShape, 0.5),
    );
    expect(target.coachIconShape, BorderRadius.circular(6));
    expect(base.copyWith().coachIconShape, base.coachIconShape);
    expect(
      midpoint.coachIconShape,
      BorderRadius.lerp(base.coachIconShape, target.coachIconShape, 0.5),
    );
    expect(target.inputShape, BorderRadius.circular(7));
    expect(base.copyWith().inputShape, base.inputShape);
    expect(
      midpoint.inputShape,
      BorderRadius.lerp(base.inputShape, target.inputShape, 0.5),
    );
    expect(target.tileShape, BorderRadius.circular(8));
    expect(base.copyWith().tileShape, base.tileShape);
    expect(
      midpoint.tileShape,
      BorderRadius.lerp(base.tileShape, target.tileShape, 0.5),
    );
    expect(target.sectionShape, BorderRadius.circular(9));
    expect(base.copyWith().sectionShape, base.sectionShape);
    expect(
      midpoint.sectionShape,
      BorderRadius.lerp(base.sectionShape, target.sectionShape, 0.5),
    );
    expect(target.compactShape, BorderRadius.circular(10));
    expect(base.copyWith().compactShape, base.compactShape);
    expect(
      midpoint.compactShape,
      BorderRadius.lerp(base.compactShape, target.compactShape, 0.5),
    );
    expect(target.heroShape, BorderRadius.circular(11));
    expect(base.copyWith().heroShape, base.heroShape);
    expect(
      midpoint.heroShape,
      BorderRadius.lerp(base.heroShape, target.heroShape, 0.5),
    );
    expect(target.pillShape, BorderRadius.circular(12));
    expect(base.copyWith().pillShape, base.pillShape);
    expect(
      midpoint.pillShape,
      BorderRadius.lerp(base.pillShape, target.pillShape, 0.5),
    );
    expect(target.scrim, const Color(0xFF123456));
    expect(base.copyWith().scrim, base.scrim);
    expect(midpoint.scrim, Color.lerp(base.scrim, target.scrim, 0.5));
    expect(target.measuringScrim, const Color(0xFF123456));
    expect(base.copyWith().measuringScrim, base.measuringScrim);
    expect(
      midpoint.measuringScrim,
      Color.lerp(base.measuringScrim, target.measuringScrim, 0.5),
    );
    expect(target.confirmationScrim, const Color(0xFF123456));
    expect(base.copyWith().confirmationScrim, base.confirmationScrim);
    expect(
      midpoint.confirmationScrim,
      Color.lerp(base.confirmationScrim, target.confirmationScrim, 0.5),
    );
    expect(target.coachScrim, const Color(0xFF123456));
    expect(base.copyWith().coachScrim, base.coachScrim);
    expect(
      midpoint.coachScrim,
      Color.lerp(base.coachScrim, target.coachScrim, 0.5),
    );
    expect(target.accentForeground, const Color(0xFF123456));
    expect(base.copyWith().accentForeground, base.accentForeground);
    expect(
      midpoint.accentForeground,
      Color.lerp(base.accentForeground, target.accentForeground, 0.5),
    );
    expect(target.focusShadowOpacity, 0.12);
    expect(base.copyWith().focusShadowOpacity, base.focusShadowOpacity);
    expect(midpoint.focusShadowOpacity, closeTo(0.24, 1e-9));
    expect(target.focusShadowBlur, 7);
    expect(base.copyWith().focusShadowBlur, base.focusShadowBlur);
    expect(midpoint.focusShadowBlur, 14.5);
    expect(target.focusShadowSpread, 3);
    expect(base.copyWith().focusShadowSpread, base.focusShadowSpread);
    expect(midpoint.focusShadowSpread, 2.5);
    expect(target.focusShadowOffset, const Offset(1, 2));
    expect(base.copyWith().focusShadowOffset, base.focusShadowOffset);
    expect(
      midpoint.focusShadowOffset,
      Offset.lerp(base.focusShadowOffset, target.focusShadowOffset, 0.5),
    );
    expect(
      target.cardShadow,
      const BoxShadow(color: Colors.red, blurRadius: 4),
    );
    expect(base.copyWith().cardShadow, base.cardShadow);
    expect(
      midpoint.cardShadow,
      BoxShadow.lerp(base.cardShadow, target.cardShadow, 0.5),
    );
    expect(
      target.coachShadow,
      const BoxShadow(color: Colors.red, blurRadius: 4),
    );
    expect(base.copyWith().coachShadow, base.coachShadow);
    expect(
      midpoint.coachShadow,
      BoxShadow.lerp(base.coachShadow, target.coachShadow, 0.5),
    );
    expect(target.pageDuration, const Duration(milliseconds: 10));
    expect(base.copyWith().pageDuration, base.pageDuration);
    expect(
      midpoint.pageDuration,
      Duration(
        microseconds:
            ((base.pageDuration.inMicroseconds +
                        target.pageDuration.inMicroseconds) /
                    2)
                .round(),
      ),
    );
    expect(target.selectionDuration, const Duration(milliseconds: 10));
    expect(base.copyWith().selectionDuration, base.selectionDuration);
    expect(
      midpoint.selectionDuration,
      Duration(
        microseconds:
            ((base.selectionDuration.inMicroseconds +
                        target.selectionDuration.inMicroseconds) /
                    2)
                .round(),
      ),
    );
    expect(target.guidedScrollDuration, const Duration(milliseconds: 10));
    expect(base.copyWith().guidedScrollDuration, base.guidedScrollDuration);
    expect(
      midpoint.guidedScrollDuration,
      Duration(
        microseconds:
            ((base.guidedScrollDuration.inMicroseconds +
                        target.guidedScrollDuration.inMicroseconds) /
                    2)
                .round(),
      ),
    );
    expect(target.coachDuration, const Duration(milliseconds: 10));
    expect(base.copyWith().coachDuration, base.coachDuration);
    expect(
      midpoint.coachDuration,
      Duration(
        microseconds:
            ((base.coachDuration.inMicroseconds +
                        target.coachDuration.inMicroseconds) /
                    2)
                .round(),
      ),
    );
    expect(target.effectsEnabled, false);
    expect(base.copyWith().effectsEnabled, base.effectsEnabled);
    expect(midpoint.effectsEnabled, target.effectsEnabled);
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('missing guided target still allows dismissal', (tester) async {
    bool? finished;
    await tester.pumpWidget(
      _host(
        GuidedTutorialOverlay(
          steps: [
            GuidedTutorialStep(
              targetKey: GlobalKey(),
              title: 'Missing',
              body: 'Body',
            ),
          ],
          onFinished: (value) => finished = value,
        ),
      ),
    );
    // Advance each readiness retry rather than assuming one large pump runs
    // all sequential timers.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 70));
    }
    final strings = AppLocalizations.of(
      tester.element(find.byType(GuidedTutorialOverlay)),
    );
    await tester.tap(find.text(strings.tutorialSkip));
    expect(finished, isFalse);
    expect(tester.takeException(), isNull);
  });

  test('Classic tutorial recipes preserve geometry and distinct timings', () {
    for (final theme in [
      ClassicThemeDefinition.light(),
      ClassicThemeDefinition.dark(),
    ]) {
      final tokens = theme.tutorialTokens;
      expect(tokens.focusShape, BorderRadius.circular(22));
      expect(tokens.cardShape, BorderRadius.circular(26));
      expect(tokens.coachShape, BorderRadius.circular(20));
      expect(tokens.scrim, const Color(0xAD000000));
      expect(tokens.coachScrim, const Color.fromRGBO(0, 0, 0, 0.42));
      expect(tokens.focusShadowOpacity, 0.36);
      expect(tokens.focusShadowBlur, 22);
      expect(tokens.focusShadowSpread, 2);
      expect(tokens.focusShadowOffset, Offset.zero);
      expect(tokens.guidedScrollDuration, const Duration(milliseconds: 260));
      expect(tokens.coachDuration, const Duration(milliseconds: 220));
      expect(tokens.effectsEnabled, isTrue);
      expect(tokens.cardShadow.blurRadius, 28);
      expect(tokens.coachShadow.offset, const Offset(0, 10));
      expect(tokens.accentForeground, isNull);
    }
  });

  testWidgets('guided accent is scoped to Neo light mode', (tester) async {
    Future<(Color?, Color?)> pumpAccent(ThemeData theme) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(key: key, width: 100, height: 50),
                ),
                GuidedTutorialOverlay(
                  onFinished: (_) {},
                  steps: [
                    GuidedTutorialStep(
                      targetKey: key,
                      title: 'First',
                      body: 'First body',
                    ),
                    GuidedTutorialStep(
                      targetKey: key,
                      title: 'Second',
                      body: 'Second body',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.tips_and_updates_outlined),
      );
      final progress = tester.widget<Text>(find.text('1/2'));
      return (icon.color, progress.style?.color);
    }

    final neoLight = await pumpAccent(NeoBrutalismThemeDefinition.light());
    final neoDark = await pumpAccent(NeoBrutalismThemeDefinition.dark());
    final classicLight = await pumpAccent(ClassicThemeDefinition.light());
    final classicDark = await pumpAccent(ClassicThemeDefinition.dark());

    expect(neoLight.$1, const Color(0xFF7A5200));
    expect(neoLight.$2, const Color(0xFF7A5200));
    expect(neoDark.$1, NeoBrutalismThemeDefinition.dark().colorScheme.primary);
    expect(neoDark.$2, NeoBrutalismThemeDefinition.dark().colorScheme.primary);
    expect(classicLight.$1, ClassicThemeDefinition.light().colorScheme.primary);
    expect(classicLight.$2, ClassicThemeDefinition.light().colorScheme.primary);
    expect(classicDark.$1, ClassicThemeDefinition.dark().colorScheme.primary);
    expect(classicDark.$2, ClassicThemeDefinition.dark().colorScheme.primary);
  });

  testWidgets('plan-builder coach uses the Neo light tutorial accent', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: NeoBrutalismThemeDefinition.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(key: key, width: 100, height: 50),
              ),
              InteractiveTutorialOverlay(
                step: InteractiveTutorialStep(
                  targetKey: key,
                  stepNumber: 1,
                  totalSteps: 1,
                  icon: Icons.info,
                  title: 'Coach',
                  body: 'Body',
                ),
                onSkip: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      tester.widget<Icon>(find.byIcon(Icons.info)).color,
      const Color(0xFF7A5200),
    );
  });

  testWidgets('guided focus shadow follows tutorial effect tokens', (
    tester,
  ) async {
    final key = GlobalKey();
    const focusShape = BorderRadius.all(Radius.circular(13));
    final tokens = AppTutorialTokens.classic.copyWith(
      focusShape: focusShape,
      focusShadowOpacity: 0.12,
      focusShadowBlur: 7,
      focusShadowSpread: 3,
      focusShadowOffset: const Offset(1, 2),
    );
    await tester.pumpWidget(
      _host(
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(key: key, width: 100, height: 50),
            ),
            GuidedTutorialOverlay(
              onFinished: (_) {},
              steps: [
                GuidedTutorialStep(
                  targetKey: key,
                  title: 'Focus',
                  body: 'Focus effect',
                ),
              ],
            ),
          ],
        ),
        tokens: tokens,
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    final primary = ClassicThemeDefinition.light().colorScheme.primary;
    final focus = tester.widget<DecoratedBox>(
      find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == focusShape &&
            decoration.boxShadow?.isNotEmpty == true;
      }),
    );
    final shadow = (focus.decoration as BoxDecoration).boxShadow!.single;
    expect(shadow.color, primary.withValues(alpha: 0.12));
    expect(shadow.blurRadius, 7);
    expect(shadow.spreadRadius, 3);
    expect(shadow.offset, const Offset(1, 2));
  });

  testWidgets('guided progression and completion work with effects disabled', (
    tester,
  ) async {
    final key = GlobalKey();
    bool? finished;
    final tokens = AppTutorialTokens.classic.copyWith(
      effectsEnabled: false,
      cardShape: BorderRadius.circular(9),
    );
    await tester.pumpWidget(
      _host(
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(key: key, width: 100, height: 50),
            ),
            GuidedTutorialOverlay(
              steps: [
                GuidedTutorialStep(
                  targetKey: key,
                  title: 'First',
                  body: 'First body',
                ),
                GuidedTutorialStep(
                  targetKey: key,
                  title: 'Second',
                  body: 'Second body',
                ),
              ],
              onFinished: (value) => finished = value,
            ),
          ],
        ),
        tokens: tokens,
        reduced: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('First'), findsOneWidget);
    final cards = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (widget) =>
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius ==
                  BorderRadius.circular(9),
        );
    expect(cards.length, 1);
    expect((cards.single.decoration as BoxDecoration).boxShadow, isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Second'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    expect(finished, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guided skip-all confirmation persists only after confirmation', (
    tester,
  ) async {
    final key = GlobalKey();
    bool? finished;
    await tester.pumpWidget(
      _host(
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(key: key, width: 100, height: 50),
            ),
            GuidedTutorialOverlay(
              steps: [
                GuidedTutorialStep(
                  targetKey: key,
                  title: 'Guide',
                  body: 'Body',
                ),
              ],
              onFinished: (value) => finished = value,
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    final strings = AppLocalizations.of(
      tester.element(find.byType(GuidedTutorialOverlay)),
    );
    await tester.tap(find.text(strings.tutorialSkipAll));
    await tester.pump();
    expect(
      await const TutorialStateStore().isCompleted(TutorialIds.trainHome),
      isFalse,
    );
    await tester.tap(find.text(strings.tutorialKeep));
    await tester.pump();
    expect(finished, isNull);
    await tester.tap(find.text(strings.tutorialSkipAll));
    await tester.pump();
    await tester.tap(find.text(strings.tutorialSkipEverything));
    await tester.pumpAndSettle();
    expect(finished, isFalse);
    expect(
      await const TutorialStateStore().isCompleted(TutorialIds.trainHome),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('coach preserves live target taps and skip with reduced motion', (
    tester,
  ) async {
    final key = GlobalKey();
    var taps = 0;
    var skips = 0;
    await tester.pumpWidget(
      _host(
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: TextButton(
                key: key,
                onPressed: () => taps++,
                child: const Text('Target'),
              ),
            ),
            InteractiveTutorialOverlay(
              step: InteractiveTutorialStep(
                targetKey: key,
                stepNumber: 1,
                totalSteps: 1,
                icon: Icons.info,
                title: 'Coach',
                body: 'Body',
              ),
              onSkip: () => skips++,
            ),
          ],
        ),
        reduced: true,
        tokens: AppTutorialTokens.classic.copyWith(effectsEnabled: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      tester
          .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
          .duration,
      Duration.zero,
    );
    await tester.tap(find.text('Target'));
    expect(taps, 1);
    final strings = AppLocalizations.of(
      tester.element(find.byType(InteractiveTutorialOverlay)),
    );
    await tester.tap(find.text(strings.planCoachSkipGuide));
    expect(skips, 1);
    expect(tester.takeException(), isNull);
  });
}
