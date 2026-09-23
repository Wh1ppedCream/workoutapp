import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/onboarding_provider.dart';
import 'package:env_test/providers/theme_provider.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/screens/profile/settings/ui_appearance_settings_page.dart';
import 'package:env_test/theme/app_theme_capabilities.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_preferences.dart';
import 'package:env_test/utils/app_test_keys.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selects and persists an eligible family independently of mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.ui_appearance_settings_v1': true,
    });
    final themeProvider = ThemeProvider(
      capabilities: const AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: false,
      ),
    );
    final harness = _AppearanceHarness(themeProvider);
    addTearDown(harness.dispose);
    await harness.pump(tester);

    final strings = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byKey(AppTestKeys.uiAppearanceThemeFamily), findsOneWidget);
    expect(find.text(strings.themeFamilyClassic), findsOneWidget);

    await tester.tap(find.byKey(AppTestKeys.uiAppearanceThemeFamily));
    await tester.pumpAndSettle();

    final neoOption = find.byKey(
      AppTestKeys.uiAppearanceThemeFamilyOption(
        AppThemeFamily.neoBrutalism.code,
      ),
    );
    expect(
      find.byKey(AppTestKeys.uiAppearanceThemeFamilyOption('classic')),
      findsOneWidget,
    );
    expect(neoOption, findsOneWidget);
    final neoRadio = tester.widget<RadioListTile<AppThemeFamily>>(neoOption);
    expect(neoRadio.value, AppThemeFamily.neoBrutalism);
    expect(neoRadio.groupValue, AppThemeFamily.classic);
    expect(neoRadio.secondary, isNotNull);

    await tester.tap(neoOption);
    await tester.pumpAndSettle();

    expect(themeProvider.family, AppThemeFamily.neoBrutalism);
    expect(themeProvider.mode, ThemeMode.dark);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(AppThemePreferences.themeFamilyKey),
      AppThemeFamily.neoBrutalism.code,
    );
    expect(find.text(strings.themeFamilyNeoBrutalism), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    testWidgets('release selector switches and restores Neo in ${mode.name}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.ui_appearance_settings_v1': true,
        AppThemePreferences.themeModeKey: mode.name,
      });
      const capabilities = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: true,
        neoReleaseEnabled: true,
      );
      final provider = ThemeProvider(capabilities: capabilities);
      final harness = _AppearanceHarness(provider);
      addTearDown(harness.dispose);
      await harness.pump(tester);
      expect(provider.family, AppThemeFamily.classic);

      Future<void> choose(AppThemeFamily family) async {
        await tester.tap(find.byKey(AppTestKeys.uiAppearanceThemeFamily));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(AppTestKeys.uiAppearanceThemeFamilyOption(family.code)),
        );
        await tester.pumpAndSettle();
      }

      await choose(AppThemeFamily.neoBrutalism);
      expect(provider.family, AppThemeFamily.neoBrutalism);
      expect(provider.mode, mode);
      expect(
        Theme.of(
          tester.element(find.byType(UIAppearanceSettingsPage)),
        ).brightness,
        mode == ThemeMode.light ? Brightness.light : Brightness.dark,
      );

      final restarted = await ThemeProvider.load(capabilities: capabilities);
      addTearDown(restarted.dispose);
      expect(restarted.family, AppThemeFamily.neoBrutalism);
      expect(restarted.mode, mode);

      await choose(AppThemeFamily.classic);
      expect(provider.family, AppThemeFamily.classic);
      expect(provider.mode, mode);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(AppThemePreferences.themeFamilyKey),
        AppThemeFamily.classic.code,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'keeps the previous family and offers retry after a failed save',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.ui_appearance_settings_v1': true,
      });
      final preferences = await SharedPreferences.getInstance();
      final themeProvider = ThemeProvider(
        preferences: _RejectingFamilyPreferences(preferences),
        capabilities: const AppThemeCapabilities(
          experimentalThemesEnabled: true,
          isReleaseMode: false,
        ),
      );
      final harness = _AppearanceHarness(themeProvider);
      addTearDown(harness.dispose);
      await harness.pump(tester);
      final strings = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.tap(find.byKey(AppTestKeys.uiAppearanceThemeFamily));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          AppTestKeys.uiAppearanceThemeFamilyOption(
            AppThemeFamily.neoBrutalism.code,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(themeProvider.family, AppThemeFamily.classic);
      expect(find.text(strings.safeFailureSaveTitle), findsOneWidget);
      expect(find.text(strings.commonRetry), findsOneWidget);

      await tester.tap(find.text(strings.commonRetry));
      await tester.pumpAndSettle();
      expect(themeProvider.family, AppThemeFamily.classic);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('hides the selector when a release build exposes only Classic', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.ui_appearance_settings_v1': true,
    });
    final themeProvider = ThemeProvider(
      capabilities: const AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: true,
      ),
    );
    final harness = _AppearanceHarness(themeProvider);
    addTearDown(harness.dispose);
    await harness.pump(tester);

    expect(themeProvider.availableFamilies, <AppThemeFamily>[
      AppThemeFamily.classic,
    ]);
    expect(find.byKey(AppTestKeys.uiAppearanceThemeFamily), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps selector semantics readable at narrow 2x text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.ui_appearance_settings_v1': true,
    });
    final themeProvider = ThemeProvider(
      capabilities: const AppThemeCapabilities(
        experimentalThemesEnabled: true,
        isReleaseMode: false,
      ),
    );
    final harness = _AppearanceHarness(themeProvider);
    addTearDown(harness.dispose);
    await harness.pump(tester, textScale: 2.0);

    final strings = await AppLocalizations.delegate.load(const Locale('en'));
    final selector = find.byKey(AppTestKeys.uiAppearanceThemeFamily);
    await tester.scrollUntilVisible(
      selector,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(selector);
    await tester.pumpAndSettle();
    await tester.tap(selector);
    await tester.pumpAndSettle();
    final classicOption = find.byKey(
      AppTestKeys.uiAppearanceThemeFamilyOption(AppThemeFamily.classic.code),
    );
    final data = tester.getSemantics(classicOption).getSemanticsData();
    expect(data.label, contains(strings.themeFamilyClassic));
    expect(data.hasFlag(SemanticsFlag.hasCheckedState), isTrue);
    expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(tester.takeException(), isNull);
  });

  test('restores an eligible family after a provider restart', () async {
    SharedPreferences.setMockInitialValues({});
    const capabilities = AppThemeCapabilities(
      experimentalThemesEnabled: true,
      isReleaseMode: false,
    );
    final first = ThemeProvider(capabilities: capabilities);
    await first.ready;
    await first.setMode(ThemeMode.light);
    await first.setFamily(AppThemeFamily.neoBrutalism);
    first.dispose();

    final second = await ThemeProvider.load(capabilities: capabilities);
    addTearDown(second.dispose);
    expect(second.family, AppThemeFamily.neoBrutalism);
    expect(second.mode, ThemeMode.light);
  });

  test(
    'downgrade falls back without erasing an unavailable family code',
    () async {
      SharedPreferences.setMockInitialValues({
        AppThemePreferences.themeFamilyKey: AppThemeFamily.neoBrutalism.code,
        AppThemePreferences.themeModeKey: 'light',
      });
      const unavailable = AppThemeCapabilities(
        experimentalThemesEnabled: false,
        isReleaseMode: true,
      );

      final provider = await ThemeProvider.load(capabilities: unavailable);
      addTearDown(provider.dispose);
      expect(provider.family, AppThemeFamily.classic);
      expect(provider.mode, ThemeMode.light);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(AppThemePreferences.themeFamilyKey),
        AppThemeFamily.neoBrutalism.code,
      );
      final reenabled = await ThemeProvider.load(
        capabilities: const AppThemeCapabilities(
          experimentalThemesEnabled: false,
          isReleaseMode: true,
          neoReleaseEnabled: true,
        ),
      );
      addTearDown(reenabled.dispose);
      expect(reenabled.family, AppThemeFamily.neoBrutalism);
      expect(reenabled.mode, ThemeMode.light);
    },
  );

  test('selector copy is available in every bundled locale', () async {
    for (final locale in const [
      Locale('en'),
      Locale('es'),
      Locale('fr'),
      Locale('fr', 'CA'),
      Locale('bn'),
      Locale('hi'),
      Locale('zh'),
    ]) {
      final strings = await AppLocalizations.delegate.load(locale);
      expect(strings.themeFamilyTitle, isNotEmpty);
      expect(strings.themeFamilySubtitle, isNotEmpty);
      expect(strings.themeFamilyClassic, isNotEmpty);
      expect(strings.themeFamilyClassicDescription, isNotEmpty);
      expect(strings.themeFamilyNeoBrutalism, isNotEmpty);
      expect(strings.themeFamilyNeoBrutalismDescription, isNotEmpty);
    }
  });
}

class _AppearanceHarness {
  _AppearanceHarness(this.themeProvider)
    : onboarding = OnboardingConfig(),
      unitPreferences = UnitPreferenceProvider(),
      localePreferences = LocalePreferenceProvider();

  final ThemeProvider themeProvider;
  final OnboardingConfig onboarding;
  final UnitPreferenceProvider unitPreferences;
  final LocalePreferenceProvider localePreferences;

  Future<void> pump(WidgetTester tester, {double textScale = 1.0}) async {
    await Future.wait([
      themeProvider.ready,
      unitPreferences.ready,
      localePreferences.ready,
    ]);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<OnboardingConfig>.value(value: onboarding),
          ChangeNotifierProvider<UnitPreferenceProvider>.value(
            value: unitPreferences,
          ),
          ChangeNotifierProvider<LocalePreferenceProvider>.value(
            value: localePreferences,
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder:
              (context, provider, _) => MaterialApp(
                theme: AppThemeFactory.light(provider.family),
                darkTheme: AppThemeFactory.dark(provider.family),
                themeMode: provider.mode,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Builder(
                  builder:
                      (context) => MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(textScale)),
                        child: const UIAppearanceSettingsPage(),
                      ),
                ),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Delayed tutorials use fake time and are not transient callbacks.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  void dispose() {
    themeProvider.dispose();
    onboarding.dispose();
    unitPreferences.dispose();
    localePreferences.dispose();
  }
}

class _RejectingFamilyPreferences extends AppThemePreferences {
  _RejectingFamilyPreferences(SharedPreferences preferences)
    : super(preferences: Future<SharedPreferences>.value(preferences));

  @override
  Future<void> writeFamily(AppThemeFamily family) async {
    throw StateError('family write failed');
  }
}
