import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/neo_brutalism_pilot_gallery.dart';
import 'package:env_test/theme/theme_lab_page.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/widgets/tonos_action.dart';
import 'package:env_test/theme/widgets/tonos_dialog.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/theme/widgets/tonos_sheet.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/session_complete_sheet.dart';

void main() {
  testWidgets('completion fixtures use production success and state widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );
    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Workout');
    final finish = find.byKey(const ValueKey('neo-pilot-finish-workout'));
    await _ensureVisibleAndSettle(tester, finish);
    await tester.tap(finish);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutCompletionPresentation), findsOneWidget);
    expect(find.byType(WorkoutCompletionExerciseCard), findsNWidgets(2));

    final loading = find.byKey(const ValueKey('neo-pilot-completion-loading'));
    await _ensureVisibleAndSettle(tester, loading);
    await tester.tap(loading);
    await tester.pump();
    expect(
      tester
          .widget<WorkoutCompletionStatus>(find.byType(WorkoutCompletionStatus))
          .isLoading,
      isTrue,
    );

    // Do not pumpAndSettle while the deliberately indefinite spinner is active.
    final error = find.byKey(const ValueKey('neo-pilot-completion-error'));
    await tester.ensureVisible(error);
    await tester.pump();
    await tester.tap(error);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<WorkoutCompletionStatus>(find.byType(WorkoutCompletionStatus))
          .isLoading,
      isFalse,
    );

    await _scrollNeoLabToTop(tester);
    final reset = find.byKey(const ValueKey('theme-lab-reset'));
    await _ensureVisibleAndSettle(tester, reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Workout');
    expect(find.byType(WorkoutCompletionPresentation), findsNothing);
    expect(find.byType(WorkoutCompletionStatus), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final startsAtRoot in [true, false]) {
    testWidgets('close gallery from root=$startsAtRoot', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home:
              startsAtRoot
                  ? const ThemeLabPage()
                  : const Scaffold(body: Text('Previous page')),
          routes: {'/main': (_) => const Scaffold(body: Text('Main page'))},
        ),
      );
      if (!startsAtRoot) {
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const ThemeLabPage()),
        );
      }
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close Theme Lab'));
      await tester.pumpAndSettle();

      expect(find.byType(ThemeLabPage), findsNothing);
      expect(
        find.text(startsAtRoot ? 'Main page' : 'Previous page'),
        findsOneWidget,
      );
      expect(navigatorKey.currentState!.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders the development gallery and stress controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    expect(find.text('Theme Lab'), findsOneWidget);
    expect(find.text('Theme family'), findsOneWidget);
    expect(find.text('Locale'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Effects enabled'), findsOneWidget);
    expect(find.byType(TonosSurface), findsWidgets);
    expect(find.byType(SegmentedButton<Brightness>), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tonos actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosAction), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Tonos fields'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosField), findsNWidgets(3));

    await tester.scrollUntilVisible(
      find.text('Tonos sheets'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(TonosSheet), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.text('Material states'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const ValueKey('theme-lab-material-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('theme-lab-material-dropdown')),
      findsOneWidget,
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    for (final heading in [
      'Typography',
      'Data visualization',
      'Fitness states',
      'Stress states',
    ]) {
      await tester.scrollUntilVisible(
        find.text(heading),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(heading), findsOneWidget);
    }
  });

  testWidgets('exposes the Neo-Brutalism preview in development builds', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    final familyField = find.text('Classic');
    expect(familyField, findsOneWidget);

    await tester.tap(familyField.first);
    await tester.pumpAndSettle();
    expect(find.text('Neo-Brutalism'), findsOneWidget);
    await tester.tap(find.text('Neo-Brutalism'));
    await tester.pumpAndSettle();
    expect(find.text('Neo-Brutalism'), findsOneWidget);
  });

  testWidgets('effects switch removes optional preview depth', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    final familyField = find.text('Classic');
    expect(familyField, findsOneWidget);
    await tester.tap(familyField.first);
    await tester.pumpAndSettle();
    final neoFamily = find.text('Neo-Brutalism');
    expect(neoFamily, findsOneWidget);
    await tester.tap(neoFamily);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SwitchListTile, 'Effects enabled'));
    await tester.pump();

    final previewTheme = tester
        .widgetList<Theme>(find.byType(Theme))
        .map((theme) => theme.data)
        .firstWhere((theme) => theme.extension<AppEffectTokens>() != null);
    expect(previewTheme.effectTokens.cardElevation, 0);
    expect(previewTheme.effectTokens.dialogElevation, 0);
    expect(previewTheme.effectTokens.sheetElevation, 0);
    expect(previewTheme.effectTokens.exerciseDetailSheetElevation, 0);
    expect(previewTheme.effectTokens.feedbackElevation, 0);
    expect(previewTheme.effectTokens.swapSheetElevation, 0);
    expect(previewTheme.effectTokens.raisedPanelShadowOffset, Offset.zero);
    expect(previewTheme.effectTokens.primaryActionShadowOffset, Offset.zero);
    expect(previewTheme.effectTokens.dialogShadowOffset, Offset.zero);
    expect(
      previewTheme.effectTokens.progressRemoveBadgeShadow.color,
      Colors.transparent,
    );
    expect(previewTheme.extension<AppMediaTokens>()!.overlayShadow, isEmpty);
    expect(previewTheme.tutorialTokens.effectsEnabled, isFalse);
    expect(previewTheme.tutorialTokens.cardShadow.color, Colors.transparent);
    expect(previewTheme.tutorialTokens.coachShadow.color, Colors.transparent);
    final weeklyOverview = tester.widget<TonosSurface>(
      find.descendant(
        of: find.byKey(const ValueKey('neo-pilot-weekly-overview')),
        matching: find.byType(TonosSurface),
      ),
    );
    expect(weeklyOverview.variant, TonosSurfaceVariant.panelRaised);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('neo-pilot-weekly-overview')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              ((widget.decoration as BoxDecoration).boxShadow ??
                      const <BoxShadow>[])
                  .any((shadow) => shadow.color.a > 0),
        ),
      ),
      findsNothing,
    );
    final tooltipDecoration = previewTheme.tooltipTheme.decoration;
    expect(tooltipDecoration, isA<BoxDecoration>());
    expect((tooltipDecoration! as BoxDecoration).boxShadow, isEmpty);
  });

  testWidgets('reduced motion disables every preview motion role', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await _selectNeoFamily(tester);
    final pilotMotion = find.descendant(
      of: find.byType(NeoBrutalismPilotGallery),
      matching: find.byType(AnimatedSize),
    );
    expect(pilotMotion, findsOneWidget);
    expect(
      tester.widget<AnimatedSize>(pilotMotion).duration,
      isNot(Duration.zero),
    );
    await tester.tap(find.widgetWithText(SwitchListTile, 'Reduced motion'));
    await tester.pump();
    expect(tester.widget<AnimatedSize>(pilotMotion).duration, Duration.zero);

    final previewTheme = tester
        .widgetList<Theme>(find.byType(Theme))
        .map((theme) => theme.data)
        .firstWhere((theme) => theme.extension<AppMotionTokens>() != null);
    final motion = previewTheme.motionTokens;
    expect(motion.instant, Duration.zero);
    expect(motion.standard, Duration.zero);
    expect(motion.emphasized, Duration.zero);
    expect(motion.page, Duration.zero);
    expect(motion.quick, Duration.zero);
    expect(motion.pageTransition, Duration.zero);
    expect(motion.exerciseDetailSelection, Duration.zero);
    expect(motion.reduced, Duration.zero);
    expect(motion.standardCurve, motion.reducedCurve);
    expect(motion.emphasizedCurve, motion.reducedCurve);

    final tutorial = previewTheme.tutorialTokens;
    expect(tutorial.pageDuration, Duration.zero);
    expect(tutorial.selectionDuration, Duration.zero);
    expect(tutorial.guidedScrollDuration, Duration.zero);
    expect(tutorial.coachDuration, Duration.zero);
  });

  testWidgets(
    'Neo pilot fixtures expose local interactions and modal selection',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ThemeLabPage(),
        ),
      );

      await _selectNeoFamily(tester);
      await _selectNeoPilot(tester, 'Train');

      expect(
        find.byKey(const ValueKey('neo-pilot-profile-avatar')),
        findsOneWidget,
      );
      expect(find.text('Weekly Overview'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('neo-pilot-bottom-navigation')),
        findsOneWidget,
      );

      final emptyPlan = find.byKey(const ValueKey('neo-pilot-empty-plan'));
      await _ensureVisibleAndSettle(tester, emptyPlan);
      await tester.tap(emptyPlan);
      await tester.pumpAndSettle();
      expect(find.text('No active plans'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('neo-pilot-active-plans')),
        findsNothing,
      );

      await _selectNeoPilot(tester, 'Workout');
      expect(find.byKey(const ValueKey('neo-pilot-workout')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('neo-pilot-secondary-weight-card')),
        findsOneWidget,
      );
      expect(find.text('Bench Press - Barbell'), findsOneWidget);
      expect(find.text('0/3 done'), findsOneWidget);
      final incompleteSet = _weightCardCheckbox(1);
      await _ensureVisibleAndSettle(tester, incompleteSet);
      expect(tester.widget<Checkbox>(incompleteSet).value, isFalse);
      await tester.tap(incompleteSet);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(incompleteSet).value, isTrue);

      final addSet = find.byKey(const ValueKey('neo-pilot-add-set'));
      await _ensureVisibleAndSettle(tester, addSet);
      await tester.tap(addSet);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('neo-pilot-weight-card')),
          matching: find.byType(Checkbox),
        ),
        findsNWidgets(4),
      );

      final weightField = find.byKey(const ValueKey('neo-pilot-first-weight'));
      await _ensureVisibleAndSettle(tester, weightField);
      await tester.enterText(weightField, '45');
      await tester.pump();
      expect(tester.widget<TextFormField>(weightField).controller!.text, '45');

      final collapse = find.descendant(
        of: find.byKey(const ValueKey('neo-pilot-weight-card')),
        matching: find.byTooltip('Collapse sets'),
      );
      await _ensureVisibleAndSettle(tester, collapse);
      await tester.tap(collapse);
      await tester.pumpAndSettle();
      expect(weightField, findsNothing);
      final expand = find.descendant(
        of: find.byKey(const ValueKey('neo-pilot-weight-card')),
        matching: find.byTooltip('Expand sets'),
      );
      expect(expand, findsOneWidget);
      await tester.tap(expand);
      await tester.pumpAndSettle();
      expect(weightField, findsOneWidget);

      final removeSet = find.descendant(
        of: find.byKey(const ValueKey('neo-pilot-weight-card')),
        matching: find.byTooltip('Remove Set'),
      );
      expect(removeSet, findsNWidgets(4));
      await tester.tap(removeSet.last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('neo-pilot-weight-card')),
          matching: find.byTooltip('Remove Set'),
        ),
        findsNWidgets(3),
      );

      await _selectNeoPilot(tester, 'User Information');
      final toggleUserError = find.byKey(
        const ValueKey('neo-pilot-toggle-user-error'),
      );
      await _ensureVisibleAndSettle(tester, toggleUserError);
      await tester.tap(toggleUserError);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid value.'), findsOneWidget);

      await _selectNeoPilot(tester, 'Weight Units');
      final openWeightUnits = find.byKey(
        const ValueKey('neo-pilot-open-weight-units'),
      );
      await _ensureVisibleAndSettle(tester, openWeightUnits);
      await tester.tap(openWeightUnits);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TonosDialogFrame), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('neo-pilot-unit-Kilograms')));
      await tester.pumpAndSettle();
      expect(find.text('Current selection: Kilograms / kg'), findsOneWidget);
    },
  );

  testWidgets('Neo pilot navigation and dialog dismissal stay local', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Train');
    final navigation = find.byKey(
      const ValueKey('neo-pilot-bottom-navigation'),
    );
    final profile = find.descendant(
      of: navigation,
      matching: find.text('Profile'),
    );
    await _ensureVisibleAndSettle(tester, profile);
    await tester.tap(profile);
    await tester.pumpAndSettle();

    final materialNavigation = tester.widget<BottomNavigationBar>(
      find.descendant(
        of: navigation,
        matching: find.byType(BottomNavigationBar),
      ),
    );
    expect(materialNavigation.currentIndex, 4);
    expect(
      find.descendant(
        of: navigation,
        matching: find.byKey(
          const ValueKey('tonos-bottom-navigation-selected-segment'),
        ),
      ),
      findsOneWidget,
    );

    await _selectNeoPilot(tester, 'Weight Units');
    final openWeightUnits = find.byKey(
      const ValueKey('neo-pilot-open-weight-units'),
    );
    await _ensureVisibleAndSettle(tester, openWeightUnits);
    await tester.tap(openWeightUnits);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    final dialogContext = tester.element(find.byType(AlertDialog));
    Navigator.of(dialogContext).pop();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Current selection: Pounds / lbs'), findsOneWidget);
  });

  testWidgets('Neo pilot state survives a preview brightness change', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Workout');
    final incompleteSet = _weightCardCheckbox(1);
    await _ensureVisibleAndSettle(tester, incompleteSet);
    await tester.tap(incompleteSet);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(incompleteSet).value, isTrue);

    await _scrollNeoLabToTop(tester);
    await _ensureVisibleAndSettle(tester, find.text('Light'));
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    await _ensureVisibleAndSettle(tester, incompleteSet);
    expect(tester.widget<Checkbox>(incompleteSet).value, isTrue);
  });

  testWidgets('completed pilot sets preserve their cue when effects are off', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Workout');
    final completedSet = _weightCardCheckbox(0);
    expect(tester.widget<Checkbox>(completedSet).value, isTrue);
    expect(find.byKey(const ValueKey('neo-pilot-weight-card')), findsOneWidget);

    await _scrollNeoLabToTop(tester);
    await _ensureVisibleAndSettle(
      tester,
      find.widgetWithText(SwitchListTile, 'Effects enabled'),
    );
    await tester.tap(find.widgetWithText(SwitchListTile, 'Effects enabled'));
    await tester.pumpAndSettle();

    await _ensureVisibleAndSettle(tester, completedSet);
    expect(tester.widget<Checkbox>(completedSet).value, isTrue);
    expect(find.byKey(const ValueKey('neo-pilot-weight-card')), findsOneWidget);
  });

  testWidgets('Theme Lab reset restores controls and fixture state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ThemeLabPage(),
      ),
    );

    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'User Information');
    final toggleUserError = find.byKey(
      const ValueKey('neo-pilot-toggle-user-error'),
    );
    await _ensureVisibleAndSettle(tester, toggleUserError);
    await tester.tap(toggleUserError);
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid value.'), findsOneWidget);

    await _selectNeoPilot(tester, 'Train');
    final emptyPlan = find.byKey(const ValueKey('neo-pilot-empty-plan'));
    await _ensureVisibleAndSettle(tester, emptyPlan);
    await tester.tap(emptyPlan);
    await tester.pumpAndSettle();
    expect(find.text('No active plans'), findsOneWidget);

    await _scrollNeoLabToTop(tester);
    final reset = find.byKey(const ValueKey('theme-lab-reset'));
    await _ensureVisibleAndSettle(tester, reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();

    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Reduced motion'),
          )
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Effects enabled'),
          )
          .value,
      isTrue,
    );
    expect(find.text('Enter a valid value.'), findsNothing);
    expect(find.byKey(const ValueKey('neo-pilot-train')), findsNothing);

    await _selectNeoFamily(tester);
    await _selectNeoPilot(tester, 'Train');
    expect(
      find.byKey(const ValueKey('neo-pilot-active-plans')),
      findsOneWidget,
    );
  });

  testWidgets('Neo pilots survive a narrow viewport at 2x text scale', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 720));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 720),
            textScaler: TextScaler.linear(2),
          ),
          child: const Scaffold(
            body: SingleChildScrollView(child: NeoBrutalismPilotGallery()),
          ),
        ),
      ),
    );

    for (final label in [
      'Train',
      'Workout',
      'User Information',
      'Weight Units',
    ]) {
      await _selectStandaloneNeoPilot(tester, label);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Pilot $label should not overflow at 320px and 2x text scale.',
      );
    }
  });
}

Finder _weightCardCheckbox(int index) {
  return find
      .descendant(
        of: find.byKey(const ValueKey('neo-pilot-weight-card')),
        matching: find.byType(Checkbox),
      )
      .at(index);
}

Future<void> _ensureVisibleAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _scrollNeoLabToTop(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var attempt = 0; attempt < 8; attempt++) {
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _selectNeoFamily(WidgetTester tester) async {
  final familyField = find.text('Classic');
  expect(familyField, findsOneWidget);
  await _ensureVisibleAndSettle(tester, familyField);
  await tester.tap(familyField);
  await tester.pumpAndSettle();
  final neoFamily = find.text('Neo-Brutalism');
  expect(neoFamily, findsOneWidget);
  await tester.tap(neoFamily);
  await tester.pumpAndSettle();
}

Future<void> _selectNeoPilot(WidgetTester tester, String label) async {
  final pilotDropdown = find.byKey(const ValueKey('theme-lab-pilot-dropdown'));
  await _scrollNeoLabToTop(tester);
  await tester.scrollUntilVisible(
    pilotDropdown,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(pilotDropdown);
  await tester.pumpAndSettle();
  final option = find.text(label);
  expect(option, findsAtLeastNWidgets(1));
  await tester.tap(option.last);
  await tester.pumpAndSettle();
}

Future<void> _selectStandaloneNeoPilot(
  WidgetTester tester,
  String label,
) async {
  final pilotDropdown = find.byKey(const ValueKey('theme-lab-pilot-dropdown'));
  await tester.ensureVisible(pilotDropdown);
  await tester.tap(pilotDropdown);
  await tester.pumpAndSettle();
  final option = find.text(label);
  expect(option, findsAtLeastNWidgets(1));
  await tester.tap(option.last);
  await tester.pumpAndSettle();
}
