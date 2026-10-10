import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/screens/profile/settings/profile_expressive_selection.dart';
import 'package:env_test/screens/profile/settings/ui_appearance_settings_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.uiAppearanceSettings}': true,
    });
  });

  testWidgets('light Expressive UI Appearance uses readable surface pairings', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appearanceApp(ExpressiveThemeDefinition.light()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final strings = AppLocalizations.of(
      tester.element(find.byType(UIAppearanceSettingsPage)),
    );
    final destination = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      Brightness.light,
    );
    final canvas = destination.pageCanvas;

    final back = find.byIcon(Icons.arrow_back);
    expect(back, findsOneWidget);
    expect(
      IconTheme.of(tester.element(back)).color,
      destination.supportingForeground,
    );
    expect(
      _contrastRatio(destination.supportingForeground, canvas),
      greaterThanOrEqualTo(4.5),
    );

    _expectTextContrast(
      tester,
      strings.displaySettingsTitle,
      background: canvas,
      expectedForeground: destination.supportingForeground,
    );
    _expectTextContrast(
      tester,
      strings.displaySettingsSubtitle,
      background: canvas,
      expectedForeground: destination.supportingForeground,
    );
    _expectTextContrast(
      tester,
      strings.navigationSettingsSubtitle,
      background: canvas,
      expectedForeground: destination.supportingForeground,
    );
    _expectTextContrast(
      tester,
      strings.navigationSettingsTitle,
      background: const Color(0xFFE8D9F4),
      expectedForeground: const Color(0xFF39254A),
    );
    _expectTextContrast(
      tester,
      strings.editBottomTabsTitle,
      background: destination.surfaceAccent,
      expectedForeground: destination.onSurfaceAccent,
    );
    _expectTextContrast(
      tester,
      strings.editBottomTabsSubtitle,
      background: destination.surfaceAccent,
      expectedForeground: destination.onSurfaceAccent.withValues(alpha: 0.78),
    );

    _expectScopedText(
      tester,
      strings.darkModeTitle,
      foreground: destination.onSurfaceTertiary,
      background: const Color(0xFFFFE8D7),
    );
    _expectScopedText(
      tester,
      strings.darkModeSubtitle,
      foreground: destination.onSurfaceTertiary.withValues(alpha: 0.82),
      background: const Color(0xFFFFE8D7),
    );
    _expectScopedText(
      tester,
      strings.weightUnitsTitle,
      foreground: destination.onSurfaceSecondary,
      background: const Color(0xFFE2F1E9),
    );
    _expectScopedText(
      tester,
      strings.weightUnitsSubtitle('lbs'),
      foreground: destination.onSurfaceSecondary.withValues(alpha: 0.82),
      background: const Color(0xFFE2F1E9),
    );
    _expectIconContrast(
      tester,
      Icons.dark_mode_outlined,
      foreground: destination.onSurfaceTertiary,
      background: destination.surfaceSelected,
    );
    _expectIconContrast(
      tester,
      Icons.auto_awesome_outlined,
      foreground: destination.onSurfaceTertiary,
      background: destination.surfaceSelected,
    );
    _expectIconContrast(
      tester,
      Icons.monitor_weight_outlined,
      foreground: destination.onSurfaceSecondary,
      background: destination.surfaceSelected,
    );
    _expectIconContrast(
      tester,
      Icons.language_outlined,
      foreground: destination.onSurfaceSecondary,
      background: destination.surfaceSelected,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark Expressive UI Appearance retains readable dark pairings', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appearanceApp(ExpressiveThemeDefinition.dark()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final strings = AppLocalizations.of(
      tester.element(find.byType(UIAppearanceSettingsPage)),
    );
    final destination = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      Brightness.dark,
    );

    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.arrow_back))).color,
      destination.supportingForeground,
    );
    _expectTextContrast(
      tester,
      strings.displaySettingsTitle,
      background: destination.pageCanvas,
      expectedForeground: destination.supportingForeground,
    );
    _expectScopedText(
      tester,
      strings.darkModeTitle,
      foreground: destination.onSurfaceTertiary,
      background: const Color(0xFF33231F),
    );
    _expectScopedText(
      tester,
      strings.weightUnitsTitle,
      foreground: destination.onSurfaceSecondary,
      background: const Color(0xFF18332F),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive language dialog has compact tonal selectable rows', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const layouts = <({Size size, double scale, double bottomInset})>[
      (size: Size(320, 900), scale: 1, bottomInset: 0),
      (size: Size(360, 800), scale: 1.3, bottomInset: 0),
      (size: Size(390, 844), scale: 1.5, bottomInset: 0),
      (size: Size(430, 1100), scale: 2, bottomInset: 0),
      (size: Size(600, 1000), scale: 1.3, bottomInset: 0),
      (size: Size(800, 390), scale: 1.5, bottomInset: 230),
      (size: Size(1024, 768), scale: 2, bottomInset: 280),
    ];
    for (final theme in [
      ExpressiveThemeDefinition.light(),
      ExpressiveThemeDefinition.dark(),
    ]) {
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        SharedPreferences.setMockInitialValues(<String, Object>{
          'guided_tutorial_completed.${TutorialIds.uiAppearanceSettings}': true,
        });
        await tester.pumpWidget(
          _appearanceApp(
            theme,
            textScale: layout.scale,
            bottomInset: layout.bottomInset,
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final languageTile = find.byKey(AppTestKeys.uiAppearanceLanguage);
        await tester.scrollUntilVisible(
          languageTile,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(languageTile);
        await tester.pumpAndSettle();
        await tester.tap(languageTile);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
          isTrue,
        );

        final selectedFinder = find.byWidgetPredicate(
          (widget) =>
              widget is RadioListTile<AppLanguagePreference> &&
              widget.value == AppLanguagePreference.system,
        );
        final unselectedFinder = find.byWidgetPredicate(
          (widget) =>
              widget is RadioListTile<AppLanguagePreference> &&
              widget.value == AppLanguagePreference.english,
        );
        expect(selectedFinder, findsOneWidget);
        expect(unselectedFinder, findsOneWidget);

        final selected = tester.widget<RadioListTile<AppLanguagePreference>>(
          selectedFinder,
        );
        final unselected = tester.widget<RadioListTile<AppLanguagePreference>>(
          unselectedFinder,
        );
        final choiceStyle = profileExpressiveChoiceStyle(
          tester.element(selectedFinder),
        );
        expect(selected.selected, isTrue);
        expect(selected.selectedTileColor, choiceStyle.selectedSurface);
        expect(unselected.selected, isFalse);
        expect(unselected.tileColor, choiceStyle.surface);
        expect(
          tester.getSize(selectedFinder).height,
          lessThanOrEqualTo(88),
          reason:
              'Language choices may grow for scaled text but should stay '
              'compact at $layout.',
        );
        expect(
          find.byType(RadioListTile<AppLanguagePreference>),
          findsNWidgets(7),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '${theme.brightness.name}, $layout',
        );

        await tester.ensureVisible(unselectedFinder);
        await tester.tap(unselectedFinder);
        await tester.pumpAndSettle();
        final providerContext = tester.element(
          find.byType(UIAppearanceSettingsPage),
        );
        expect(
          Provider.of<LocalePreferenceProvider>(
            providerContext,
            listen: false,
          ).preference,
          AppLanguagePreference.english,
        );
        await Provider.of<LocalePreferenceProvider>(
          providerContext,
          listen: false,
        ).setPreference(AppLanguagePreference.system);
      }
    }
  });
}

void _expectTextContrast(
  WidgetTester tester,
  String text, {
  required Color background,
  required Color expectedForeground,
}) {
  final finder = find.text(text);
  expect(finder, findsOneWidget, reason: text);
  final widget = tester.widget<Text>(finder);
  final foreground =
      widget.style?.color ??
      DefaultTextStyle.of(tester.element(finder)).style.color;
  expect(foreground, expectedForeground, reason: text);
  expect(
    _contrastRatio(foreground!, background),
    greaterThanOrEqualTo(4.5),
    reason: text,
  );
}

void _expectScopedText(
  WidgetTester tester,
  String text, {
  required Color foreground,
  required Color background,
}) {
  final finder = find.text(text);
  expect(finder, findsOneWidget, reason: text);
  final context = tester.element(finder);
  final widget = tester.widget<Text>(finder);
  final renderedForeground =
      widget.style?.color ??
      DefaultTextStyle.of(context).style.color ??
      Theme.of(context).colorScheme.onSurface;
  expect(renderedForeground, foreground, reason: text);
  expect(
    _contrastRatio(renderedForeground, background),
    greaterThanOrEqualTo(4.5),
    reason: text,
  );
}

void _expectIconContrast(
  WidgetTester tester,
  IconData icon, {
  required Color foreground,
  required Color background,
}) {
  final finder = find.byIcon(icon);
  expect(finder, findsOneWidget, reason: '$icon');
  final renderedForeground = tester.widget<Icon>(finder).color;
  expect(renderedForeground, foreground, reason: '$icon');
  expect(
    _contrastRatio(renderedForeground!, background),
    greaterThanOrEqualTo(4.5),
    reason: '$icon',
  );
}

double _contrastRatio(Color foreground, Color background) {
  final opaqueForeground = foreground.a == 1
      ? foreground
      : Color.alphaBlend(foreground, background);
  final first = opaqueForeground.computeLuminance();
  final second = background.computeLuminance();
  final brighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (brighter + 0.05) / (darker + 0.05);
}

Widget _appearanceApp(
  ThemeData theme, {
  double textScale = 1,
  double bottomInset = 0,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          capabilities: const AppThemeCapabilities(
            experimentalThemesEnabled: true,
            isReleaseMode: false,
          ),
        ),
      ),
      ChangeNotifierProvider(create: (_) => OnboardingConfig()..init()),
      ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
      ChangeNotifierProvider(create: (_) => LocalePreferenceProvider()),
    ],
    child: MaterialApp(
      theme: theme,
      locale: const Locale('en'),
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: bottomInset),
          padding: const EdgeInsets.only(top: 24, bottom: 12),
        ),
        child: child!,
      ),
      home: const AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.profile,
        child: UIAppearanceSettingsPage(),
      ),
    ),
  );
}
