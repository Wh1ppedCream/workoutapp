import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode onboarding route retains its theme roles', (
        tester,
      ) async {
        await _pumpOnboarding(
          tester,
          theme: theme,
          size: const Size(390, 844),
          textScale: 1.25,
        );
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );

        expect(find.text(strings.onboardingWelcomeTitle), findsOneWidget);
        _expectLanguageField(tester, theme);
        _expectPageDots(tester, family, theme);
        _expectCardSurface(
          tester,
          family,
          theme,
          strings.onboardingWelcomeTitle,
        );
        _expectNoFlutterException(tester, 'welcome');

        await _advance(tester, strings.onboardingNext);
        expect(find.text(strings.onboardingBasicsTitle), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(3));
        final nameField = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        final nameDecoration = nameField.decoration!;
        final nameContext = tester.element(find.byType(TextField).first);
        expect(nameDecoration.labelText, strings.onboardingNameLabel);
        expect((nameDecoration.prefixIcon! as Icon).icon, Icons.person_outline);
        expect(
          (nameDecoration.border! as OutlineInputBorder).borderRadius,
          family == AppThemeFamily.neoBrutalism
              ? nameContext.shapeTokens.settingsField
              : nameContext.tutorialTokens.inputShape,
        );
        expect(
          nameDecoration.fillColor,
          family == AppThemeFamily.neoBrutalism
              ? nameContext.surfaceTokens.settingsInput
              : isNull,
        );
        await _tapVisible(tester, find.widgetWithText(ChoiceChip, 'kg'));
        _expectChoiceChipSurface(tester, family, theme, 'kg', selected: true);
        _expectChoiceChipSurface(tester, family, theme, 'lbs', selected: false);
        _expectNoFlutterException(tester, 'personal information');

        await _advance(tester, strings.onboardingNext);
        expect(find.text(strings.onboardingFocusTitle), findsOneWidget);
        final nutritionIntent = find.text(strings.onboardingNutritionDataTitle);
        _expectIntentTile(
          tester,
          family,
          theme,
          nutritionIntent,
          enabled: false,
          selected: false,
          statusLabel: strings.onboardingLater,
        );
        final exerciseIntent = find.text(strings.onboardingExerciseDataTitle);
        _expectIntentTile(
          tester,
          family,
          theme,
          exerciseIntent,
          enabled: true,
          selected: false,
        );
        await _tapVisible(tester, exerciseIntent);
        _expectIntentTile(
          tester,
          family,
          theme,
          exerciseIntent,
          enabled: true,
          selected: true,
        );
        _expectNoFlutterException(tester, 'usage intent selection');

        await _advance(tester, strings.onboardingNext);
        expect(find.text(strings.onboardingGymSpaceTitle), findsOneWidget);
        await tester.pumpAndSettle();
        final homeGym = find.text(strings.onboardingGymHomeTitle);
        _expectGymSpaceTile(tester, family, theme, homeGym, selected: false);
        await _tapVisible(tester, homeGym);
        _expectGymSpaceTile(tester, family, theme, homeGym, selected: true);
        await _advance(tester, strings.onboardingNext);

        expect(
          find.text(strings.onboardingReviewWorkoutSpaceTitle),
          findsOneWidget,
        );
        expect(find.byType(TextField), findsOneWidget);
        final profileNameFinder = find.byType(TextField);
        final profileNameField = tester.widget<TextField>(profileNameFinder);
        final profileNameDecoration = profileNameField.decoration!;
        expect(
          profileNameDecoration.labelText,
          strings.onboardingProfileNameLabel,
        );
        expect(
          (profileNameDecoration.prefixIcon! as Icon).icon,
          Icons.edit_outlined,
        );
        expect(
          (profileNameDecoration.border! as OutlineInputBorder).borderRadius,
          tester.element(profileNameFinder).tutorialTokens.inputShape,
        );
        _expectEmptyEquipmentSummary(tester, theme, strings);
        _expectNoFlutterException(tester, 'workout-space equipment');

        await tester.tap(findTonosTooltip(strings.onboardingPreviousStepTooltip));
        await tester.pumpAndSettle();
        final skipGym = find.text(strings.onboardingGymSkipTitle);
        _expectGymSpaceTile(tester, family, theme, skipGym, selected: false);
        await _tapVisible(tester, skipGym);
        _expectGymSpaceTile(tester, family, theme, skipGym, selected: true);
        await _advance(tester, strings.onboardingNext);

        expect(find.text(strings.onboardingWorkoutPlanTitle), findsOneWidget);
        final skipPlan = find.text(strings.onboardingSkipPlanTitle);
        _expectWorkoutPlanTile(
          tester,
          family,
          theme,
          skipPlan,
          selected: false,
        );
        await _tapVisible(tester, skipPlan);
        _expectWorkoutPlanTile(tester, family, theme, skipPlan, selected: true);
        await _advance(tester, strings.onboardingNext);

        expect(find.text(strings.onboardingReadyTitle), findsOneWidget);
        expect(
          find.text(strings.onboardingSummaryProfileSection),
          findsOneWidget,
        );
        _expectSummarySurfaces(tester, family, theme, strings);
        _expectNoFlutterException(tester, 'onboarding summary');
      });

      testWidgets('$mode onboarding renders the equipment-load error role', (
        tester,
      ) async {
        await _pumpOnboarding(
          tester,
          theme: theme,
          size: const Size(390, 844),
          repository: _FailingOnboardingThemeRepository(),
        );
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );

        await _advance(tester, strings.onboardingNext);
        await _advance(tester, strings.onboardingNext);
        await _tapVisible(
          tester,
          find.text(strings.onboardingExerciseDataTitle),
        );
        await _advance(tester, strings.onboardingNext);

        expect(find.text(strings.onboardingEquipmentLoadError), findsOneWidget);
        _expectEquipmentLoadError(tester, theme, strings);
        _expectNoFlutterException(tester, 'gym-equipment load error');
      });

      testWidgets('$mode onboarding reflows at large text scale', (
        tester,
      ) async {
        await _pumpOnboarding(
          tester,
          theme: theme,
          size: const Size(320, 760),
          textScale: 2,
          disableAnimations: true,
        );
        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );

        expect(find.text(strings.onboardingWelcomeTitle), findsOneWidget);
        expect(
          find.widgetWithText(TextButton, strings.onboardingSkip),
          findsOneWidget,
        );
        _expectNoFlutterException(tester, 'large-text welcome');

        await _advance(tester, strings.onboardingNext);
        expect(find.text(strings.onboardingBasicsTitle), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(3));
        _expectNoFlutterException(tester, 'large-text personal information');
      });
    }
  }

  const responsiveViewports = <({String label, Size size})>[
    (label: '320dp compact phone', size: Size(320, 760)),
    (label: '390dp phone', size: Size(390, 844)),
    (label: '600dp compact tablet', size: Size(600, 900)),
    (label: '800dp tablet', size: Size(800, 1100)),
    (label: '640dp compact landscape', size: Size(640, 360)),
  ];
  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();
    for (final viewport in responsiveViewports) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('Expressive onboarding keeps primary actions reachable at '
            '${viewport.label}, ${scale}x, ${brightness.name}', (tester) async {
          await _pumpOnboarding(
            tester,
            theme: theme,
            size: viewport.size,
            textScale: scale,
            disableAnimations: true,
          );
          final strings = await AppLocalizations.delegate.load(
            const Locale('en'),
          );
          final nextButton = find.widgetWithText(
            FilledButton,
            strings.onboardingNext,
          );
          final skipButton = find.widgetWithText(
            TextButton,
            strings.onboardingSkip,
          );
          expect(nextButton, findsOneWidget);
          expect(skipButton, findsOneWidget);
          void expectActionWithinViewport(Finder action) {
            final rect = tester.getRect(action);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(viewport.size.width));
            expect(rect.top, greaterThanOrEqualTo(0));
            expect(rect.bottom, lessThanOrEqualTo(viewport.size.height));
          }

          expectActionWithinViewport(nextButton);
          expectActionWithinViewport(skipButton);
          expect(find.byType(PageView), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(find.text(strings.onboardingBasicsTitle), findsOneWidget);
          final nameField = find.byType(TextField).first;
          await tester.ensureVisible(nameField);
          final fieldRect = tester.getRect(nameField);
          expect(fieldRect.left, greaterThanOrEqualTo(0));
          expect(fieldRect.right, lessThanOrEqualTo(viewport.size.width));
          expect(fieldRect.top, greaterThanOrEqualTo(0));
          expect(fieldRect.bottom, lessThanOrEqualTo(viewport.size.height));
          expectActionWithinViewport(nextButton);
          expectActionWithinViewport(skipButton);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('Expressive onboarding keeps Next above a compact keyboard inset', (
    tester,
  ) async {
    const size = Size(320, 780);
    const keyboardInset = 280.0;
    await _pumpOnboarding(
      tester,
      theme: ExpressiveThemeDefinition.light(),
      size: size,
      textScale: 2,
      viewInsets: const EdgeInsets.only(bottom: keyboardInset),
      disableAnimations: true,
    );
    final strings = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(strings.onboardingNext));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField).first;
    await tester.ensureVisible(nameField);
    await tester.tap(nameField);
    await tester.enterText(nameField, 'Alex');
    final availableBottom = size.height - keyboardInset;
    final nameRect = tester.getRect(nameField);
    final nextRect = tester.getRect(find.text(strings.onboardingNext));
    expect(nameRect.bottom, lessThanOrEqualTo(availableBottom));
    expect(nextRect.bottom, lessThanOrEqualTo(availableBottom));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpOnboarding(
  WidgetTester tester, {
  required ThemeData theme,
  required Size size,
  AppRepository? repository,
  double textScale = 1,
  EdgeInsets viewInsets = EdgeInsets.zero,
  bool disableAnimations = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final unitPreferences = UnitPreferenceProvider();
  final localePreferences = LocalePreferenceProvider();
  await Future.wait([unitPreferences.ready, localePreferences.ready]);
  addTearDown(unitPreferences.dispose);
  addTearDown(localePreferences.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppRepository>.value(
          value: repository ?? _OnboardingThemeRepository(),
        ),
        ChangeNotifierProvider<UnitPreferenceProvider>.value(
          value: unitPreferences,
        ),
        ChangeNotifierProvider<LocalePreferenceProvider>.value(
          value: localePreferences,
        ),
      ],
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            viewInsets: viewInsets,
            disableAnimations: disableAnimations,
          );
          return MediaQuery(data: mediaQuery, child: child!);
        },
        home: const OnboardingFlow(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _advance(WidgetTester tester, String label) async {
  final nextButton = find.widgetWithText(FilledButton, label);
  expect(nextButton, findsOneWidget);
  await tester.ensureVisible(nextButton);
  await tester.tap(nextButton);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _expectCardSurface(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  String title,
) {
  final cardScroll = find.ancestor(
    of: find.text(title),
    matching: find.byType(SingleChildScrollView),
  );
  final cardContainer =
      find
          .descendant(of: cardScroll.first, matching: find.byType(Container))
          .first;
  final decoration = tester.widget<Container>(cardContainer).decoration;
  expect(decoration, isA<BoxDecoration>());

  final cardContext = tester.element(cardScroll.first);
  final expectedColor =
      family == AppThemeFamily.neoBrutalism
          ? theme.surfaceTokens.settingsSection
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.34);
  final cardDecoration = decoration! as BoxDecoration;
  expect(cardDecoration.color, expectedColor);
  expect(
    cardDecoration.borderRadius,
    family == AppThemeFamily.neoBrutalism
        ? cardContext.shapeTokens.settingsPanel
        : cardContext.tutorialTokens.heroShape,
  );
  expect(
    cardDecoration.border!.top,
    BorderSide(
      color:
          family == AppThemeFamily.neoBrutalism
              ? tonosOutlineForSurface(cardContext, expectedColor)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
      width:
          family == AppThemeFamily.neoBrutalism
              ? cardContext.shapeTokens.outlineWidth
              : 1,
    ),
  );

  final iconContainer = tester.widget<Container>(
    find
        .descendant(of: cardScroll.first, matching: find.byType(Container))
        .at(1),
  );
  final iconDecoration = iconContainer.decoration! as BoxDecoration;
  expect(
    iconDecoration.color,
    family == AppThemeFamily.neoBrutalism
        ? cardContext.surfaceTokens.dialogChoice
        : theme.colorScheme.primary.withValues(alpha: 0.18),
  );
  expect(iconDecoration.shape, BoxShape.circle);
}

void _expectLanguageField(WidgetTester tester, ThemeData theme) {
  final fieldFinder = find.byType(
    DropdownButtonFormField<AppLanguagePreference>,
  );
  final field = tester.widget<DropdownButtonFormField<AppLanguagePreference>>(
    fieldFinder,
  );
  expect((field.decoration.prefixIcon! as Icon).icon, Icons.language_outlined);
  expect(
    field.decoration.contentPadding,
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  final decoratorFinder = find.descendant(
    of: fieldFinder,
    matching: find.byType(InputDecorator),
  );
  expect(decoratorFinder, findsOneWidget);
  final decorator = tester.widget<InputDecorator>(decoratorFinder);
  expect(decorator.decoration.border, theme.inputDecorationTheme.border);
}

void _expectPageDots(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
) {
  final dots =
      tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .where(
            (dot) =>
                dot.constraints?.minHeight == 7 &&
                dot.constraints?.maxHeight == 7,
          )
          .toList();
  expect(dots, hasLength(4));

  final activeDot = dots.singleWhere(
    (dot) => dot.constraints?.minWidth == 20 && dot.constraints?.maxWidth == 20,
  );
  final context = tester.element(find.byType(PageView));
  final decoration = activeDot.decoration! as BoxDecoration;
  expect(
    decoration.color,
    family == AppThemeFamily.neoBrutalism
        ? context.surfaceTokens.settingsHero
        : theme.colorScheme.primary,
  );
  expect(decoration.borderRadius, context.tutorialTokens.pillShape);
}

void _expectIntentTile(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  Finder label, {
  required bool enabled,
  required bool selected,
  String? statusLabel,
}) {
  final tileFinder = find.ancestor(
    of: label,
    matching: find.byType(AnimatedContainer),
  );
  final context = tester.element(tileFinder.first);
  final neo = family == AppThemeFamily.neoBrutalism;
  final surface =
      neo
          ? (selected
              ? context.surfaceTokens.settingsHero
              : context.surfaceTokens.dialogChoice)
          : null;
  final expectedBackground =
      neo
          ? surface
          : selected
          ? theme.colorScheme.primary.withValues(alpha: 0.16)
          : theme.colorScheme.surface.withValues(alpha: enabled ? 0.5 : 0.28);
  final expectedBorder =
      neo
          ? tonosOutlineForSurface(context, surface!)
          : selected
          ? theme.colorScheme.primary
          : theme.colorScheme.outlineVariant;
  final decoration =
      tester.widget<AnimatedContainer>(tileFinder.first).decoration!
          as BoxDecoration;
  expect(decoration.color, expectedBackground);
  expect(decoration.border!.top.color, expectedBorder);
  expect(
    decoration.border!.top.width,
    neo ? context.shapeTokens.outlineWidth : 1,
  );
  expect(
    decoration.borderRadius,
    neo ? context.shapeTokens.settingsInput : context.tutorialTokens.tileShape,
  );

  final expectedForeground =
      neo
          ? tonosForegroundForSurface(context, surface!)
          : enabled
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant;
  expect(tester.widget<Text>(label).style?.color, expectedForeground);
  final inkWell =
      find.ancestor(of: label, matching: find.byType(InkWell)).first;
  expect(tester.widget<InkWell>(inkWell).onTap, enabled ? isNotNull : isNull);

  final checkbox = find.descendant(
    of: tileFinder.first,
    matching: find.byType(Checkbox),
  );
  if (enabled) {
    expect(checkbox, findsOneWidget);
  } else {
    expect(checkbox, findsNothing);
    expect(statusLabel, isNotNull);
    final status = find.descendant(
      of: tileFinder.first,
      matching: find.text(statusLabel!),
    );
    expect(status, findsOneWidget);
    final statusContainer =
        find.ancestor(of: status, matching: find.byType(Container)).first;
    final statusDecoration =
        tester.widget<Container>(statusContainer).decoration! as BoxDecoration;
    final statusSurface =
        neo
            ? context.surfaceTokens.settingsInput
            : theme.colorScheme.surfaceContainerHighest;
    expect(statusDecoration.color, statusSurface);
    expect(
      statusDecoration.border!.top.color,
      neo
          ? tonosOutlineForSurface(context, statusSurface)
          : theme.colorScheme.outlineVariant,
    );
    expect(
      statusDecoration.borderRadius,
      neo ? context.shapeTokens.pill : context.tutorialTokens.pillShape,
    );
  }
}

void _expectGymSpaceTile(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  Finder label, {
  required bool selected,
}) {
  final tileFinder = find.ancestor(
    of: label,
    matching: find.byType(AnimatedContainer),
  );
  final context = tester.element(tileFinder.first);
  final neo = family == AppThemeFamily.neoBrutalism;
  final surface =
      neo
          ? (selected
              ? context.surfaceTokens.settingsHero
              : context.surfaceTokens.dialogChoice)
          : null;
  final expectedColor =
      neo
          ? surface
          : selected
          ? theme.colorScheme.primary.withValues(alpha: 0.16)
          : theme.colorScheme.surface.withValues(alpha: 0.46);
  final decoration =
      tester.widget<AnimatedContainer>(tileFinder.first).decoration!
          as BoxDecoration;
  expect(decoration.color, expectedColor);
  expect(
    decoration.border!.top.color,
    neo
        ? tonosOutlineForSurface(context, surface!)
        : selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant,
  );
  expect(
    decoration.border!.top.width,
    neo ? context.shapeTokens.outlineWidth : (selected ? 2 : 1),
  );

  final tileIcon =
      find.descendant(of: tileFinder.first, matching: find.byType(Icon)).first;
  final iconContainer =
      find.ancestor(of: tileIcon, matching: find.byType(Container)).first;
  final iconDecoration =
      tester.widget<Container>(iconContainer).decoration! as BoxDecoration;
  final foreground =
      neo
          ? tonosForegroundForSurface(context, surface!)
          : theme.colorScheme.primary;
  expect(iconDecoration.color, foreground.withValues(alpha: 0.16));
}

void _expectEmptyEquipmentSummary(
  WidgetTester tester,
  ThemeData theme,
  AppLocalizations strings,
) {
  final title = find.text(strings.onboardingIncludedEquipmentTitle);
  final panelFinder =
      find.ancestor(of: title, matching: find.byType(Container)).first;
  final context = tester.element(panelFinder);
  final decoration =
      tester.widget<Container>(panelFinder).decoration! as BoxDecoration;
  expect(decoration.color, theme.colorScheme.surface.withValues(alpha: 0.46));
  expect(decoration.borderRadius, context.tutorialTokens.sectionShape);
  expect(decoration.border!.top.color, theme.colorScheme.outlineVariant);
  expect(find.text(strings.onboardingNoEquipmentSelected), findsOneWidget);
}

void _expectWorkoutPlanTile(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  Finder label, {
  required bool selected,
}) {
  final tileFinder = find.ancestor(
    of: label,
    matching: find.byType(AnimatedContainer),
  );
  final context = tester.element(tileFinder.first);
  final neo = family == AppThemeFamily.neoBrutalism;
  final surface =
      neo
          ? (selected
              ? context.surfaceTokens.settingsHero
              : context.surfaceTokens.dialogChoice)
          : null;
  final decoration =
      tester.widget<AnimatedContainer>(tileFinder.first).decoration!
          as BoxDecoration;
  expect(
    decoration.color,
    neo
        ? surface
        : selected
        ? theme.colorScheme.primary.withValues(alpha: 0.16)
        : theme.colorScheme.surface.withValues(alpha: 0.46),
  );
  expect(
    decoration.border!.top.color,
    neo
        ? tonosOutlineForSurface(context, surface!)
        : selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant,
  );
  expect(
    decoration.border!.top.width,
    neo ? context.shapeTokens.outlineWidth : (selected ? 2 : 1),
  );

  final tileIcon =
      find.descendant(of: tileFinder.first, matching: find.byType(Icon)).first;
  final iconContainer =
      find.ancestor(of: tileIcon, matching: find.byType(Container)).first;
  final iconDecoration =
      tester.widget<Container>(iconContainer).decoration! as BoxDecoration;
  final foreground =
      neo
          ? tonosForegroundForSurface(context, surface!)
          : theme.colorScheme.primary;
  expect(iconDecoration.color, foreground.withValues(alpha: 0.16));
  expect(
    iconDecoration.borderRadius,
    neo ? context.shapeTokens.control : context.tutorialTokens.compactShape,
  );
}

void _expectSummarySurfaces(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  AppLocalizations strings,
) {
  final calloutLabel = find.text(strings.onboardingSummaryIncluded);
  final callout =
      find.ancestor(of: calloutLabel, matching: find.byType(Container)).first;
  final context = tester.element(callout);
  final neo = family == AppThemeFamily.neoBrutalism;
  final calloutSurface = neo ? context.surfaceTokens.dialogChoice : null;
  final calloutDecoration =
      tester.widget<Container>(callout).decoration! as BoxDecoration;
  expect(
    calloutDecoration.color,
    neo ? calloutSurface : theme.colorScheme.primary.withValues(alpha: 0.12),
  );
  expect(
    calloutDecoration.border!.top.color,
    neo
        ? tonosOutlineForSurface(context, calloutSurface!)
        : theme.colorScheme.primary.withValues(alpha: 0.3),
  );

  final sectionTitle = find.text(strings.onboardingSummaryProfileSection);
  final section =
      find.ancestor(of: sectionTitle, matching: find.byType(Container)).first;
  final sectionDecoration =
      tester.widget<Container>(section).decoration! as BoxDecoration;
  final sectionSurface = neo ? context.surfaceTokens.settingsInput : null;
  expect(
    sectionDecoration.color,
    neo ? sectionSurface : theme.colorScheme.surface.withValues(alpha: 0.46),
  );
  expect(
    sectionDecoration.border!.top.color,
    neo
        ? tonosOutlineForSurface(context, sectionSurface!)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
  );
}

void _expectEquipmentLoadError(
  WidgetTester tester,
  ThemeData theme,
  AppLocalizations strings,
) {
  final errorLabel = find.text(strings.onboardingEquipmentLoadError);
  final errorContainer =
      find.ancestor(of: errorLabel, matching: find.byType(Container)).first;
  final context = tester.element(errorContainer);
  final decoration =
      tester.widget<Container>(errorContainer).decoration! as BoxDecoration;
  expect(
    decoration.color,
    theme.colorScheme.errorContainer.withValues(alpha: 0.32),
  );
  expect(decoration.borderRadius, context.tutorialTokens.sectionShape);
  expect(find.text(strings.onboardingTryAgain), findsOneWidget);
}

void _expectChoiceChipSurface(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  String label, {
  required bool selected,
}) {
  final chipFinder = find.widgetWithText(ChoiceChip, label);
  final chip = tester.widget<ChoiceChip>(chipFinder);
  final context = tester.element(chipFinder);
  final labelText = tester.widget<Text>(
    find.descendant(of: chipFinder, matching: find.byType(Text)).first,
  );

  if (family == AppThemeFamily.neoBrutalism) {
    final surface =
        selected
            ? theme.surfaceTokens.settingsHero
            : theme.surfaceTokens.dialogChoice;
    expect(chip.selectedColor, surface);
    expect(chip.backgroundColor, surface);
    expect(
      chip.side,
      BorderSide(
        color: tonosOutlineForSurface(context, surface),
        width: context.shapeTokens.outlineWidth,
      ),
    );
    expect(labelText.style?.color, tonosForegroundForSurface(context, surface));
  } else {
    expect(chip.selectedColor, isNull);
    expect(chip.backgroundColor, isNull);
    expect(chip.side, isNull);
    expect(labelText.style, isNull);
  }
}

void _expectNoFlutterException(WidgetTester tester, String surface) {
  expect(
    tester.takeException(),
    isNull,
    reason: 'Unexpected error on $surface.',
  );
}

class _OnboardingThemeRepository extends AppRepository {
  @override
  Future<List<Equipment>> fetchAllEquipment() async => const <Equipment>[];
}

class _FailingOnboardingThemeRepository extends _OnboardingThemeRepository {
  @override
  Future<List<Equipment>> fetchAllEquipment() async {
    throw StateError('equipment unavailable');
  }
}
