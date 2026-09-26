// File: lib/main.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/active_session.dart';
import 'providers/selected_profile.dart';
import 'providers/dashboard_config.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/nav_bar_config.dart';
import 'providers/nutrition_profile.dart';
import 'providers/unit_preference_provider.dart';
import 'providers/locale_preference_provider.dart';
import 'l10n/app_localization_extensions.dart';
import 'l10n/generated/app_localizations.dart';

import 'screens/dashboard_page.dart';
import 'screens/catalog_page.dart';
import 'screens/exercise/history_screen.dart';
import 'screens/exercise/train_page.dart';
import 'screens/exercise/train2_page.dart';
import 'screens/nutrition/nutrition_page.dart';
import 'screens/profile/settings/profile_page.dart';
import 'screens/onboarding_flow.dart'; // New import for onboarding
import 'screens/measurement_trends_page.dart';
import 'screens/nutrition_log_page.dart';
import 'screens/combined_history_page.dart';
import 'screens/form_posing_page.dart';

import 'widgets/ongoing_session_fab.dart';
import 'widgets/body_heatmap.dart';
import 'widgets/active_session_durability_banner.dart';
import 'widgets/tonos_bottom_navigation_bar.dart';

import 'theme/app_theme_factory.dart';
import 'theme/debug_theme_family_control.dart';
import 'theme/theme_lab_page.dart';

import 'repositories/app_repository.dart';
import 'services/active_plan_store.dart';
import 'services/diagnostics_service.dart';
import 'utils/app_test_keys.dart';

const _compileTimeThemeLab = bool.fromEnvironment('TONOS_THEME_LAB');

Future<void> main() async {
  final diagnostics = DiagnosticsService.instance;
  final launch = runZonedGuarded<Future<void>>(
    () async {
      final launchStopwatch = Stopwatch()..start();
      WidgetsFlutterBinding.ensureInitialized();
      await diagnostics.initialize();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(
          diagnostics.captureException(
            details.exception,
            details.stack ?? StackTrace.current,
            category: 'flutter_framework',
          ),
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        unawaited(
          diagnostics.captureException(
            error,
            stackTrace,
            category: 'platform_dispatcher',
          ),
        );
        return true;
      };

      unawaited(BodyHeatmap.preload());
      final themeProvider = await ThemeProvider.load();
      final repo = AppRepository();
      runApp(buildTonosApp(repo: repo, themeProvider: themeProvider));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[startup] first frame rendered in '
          '${launchStopwatch.elapsedMilliseconds}ms',
        );
      });
    },
    (error, stackTrace) {
      unawaited(
        diagnostics.captureException(
          error,
          stackTrace,
          category: 'uncaught_async',
        ),
      );
    },
  );
  if (launch != null) await launch;
}

/// Builds the production provider tree around an injected repository.
///
/// Device tests can disable repository ownership so pumping the widget tree
/// does not race their test-scoped repository lifecycle.
Widget buildTonosApp({
  required AppRepository repo,
  bool closeRepositoryOnDispose = true,
  ThemeProvider? themeProvider,
}) {
  final themeProviderNode =
      themeProvider == null
          ? ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          )
          : ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider);
  final app = MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repo), // repo FIRST
      Provider<ActivePlanStore>(
        create: (_) => ActivePlanStore(repository: repo),
      ),
      ChangeNotifierProvider(create: (_) => NutritionProfile(repository: repo)),
      ChangeNotifierProvider(create: (_) => OnboardingConfig()..init()),
      ChangeNotifierProvider(create: (_) => ActiveSession(repository: repo)),
      ChangeNotifierProvider(create: (_) => SelectedProfile(repository: repo)),
      ChangeNotifierProvider(create: (_) => DashboardConfig()),
      themeProviderNode,
      ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
      ChangeNotifierProvider(create: (_) => LocalePreferenceProvider()),
      ChangeNotifierProvider(create: (_) => NavBarConfig()),
    ],
    child: const MyApp(),
  );

  if (!closeRepositoryOnDispose) return app;
  return RepositoryLifecycle(repo: repo, child: app);
}

/// Ensures the repository is closed when the app is disposed (hot restart/quit).
class RepositoryLifecycle extends StatefulWidget {
  final AppRepository repo;
  final Widget child;
  const RepositoryLifecycle({
    super.key,
    required this.repo,
    required this.child,
  });
  @override
  State<RepositoryLifecycle> createState() => _RepositoryLifecycleState();
}

class _RepositoryLifecycleState extends State<RepositoryLifecycle> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warmUpRepository());
    });
  }

  Future<void> _warmUpRepository() async {
    final sw = Stopwatch()..start();
    try {
      await widget.repo.warmUp();
      debugPrint(
        '[startup] repository warm-up finished in ${sw.elapsedMilliseconds}ms',
      );
    } catch (error, stackTrace) {
      debugPrint('[startup] repository warm-up failed: ${error.runtimeType}');
      await DiagnosticsService.instance.captureException(
        error,
        stackTrace,
        category: 'repository_warmup',
      );
    }
  }

  @override
  void dispose() {
    unawaited(widget.repo.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, OnboardingConfig, LocalePreferenceProvider>(
      builder: (context, themeProv, onboardingConf, localePreferences, _) {
        final lightTheme = AppThemeFactory.light(themeProv.family);
        final darkTheme = AppThemeFactory.dark(themeProv.family);

        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: localePreferences.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProv.mode,
          builder: (context, child) {
            final showDebugToolbar =
                kDebugMode && const bool.fromEnvironment('TONOS_THEME_SWITCH');
            final appChild = child ?? const SizedBox.shrink();

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                statusBarBrightness: Theme.of(context).brightness,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ActiveSessionDurabilityBanner(child: appChild),
                  if (showDebugToolbar) const _DebugThemeToolbar(),
                ],
              ),
            );
          },

          home:
              !onboardingConf.initialized
                  ? const _StartupGate()
                  : kDebugMode && _compileTimeThemeLab
                  ? const ThemeLabPage()
                  : onboardingConf.showOnboarding
                  ? const OnboardingFlow()
                  : const MainScreen(),
          routes: {
            '/main': (_) => const MainScreen(),
            if (kDebugMode) '/__theme_lab': (_) => const ThemeLabPage(),
          },
        );
      },
    );
  }
}

/// Floating development-only controls that leave the app's layout unchanged.
class _DebugThemeToolbar extends StatelessWidget {
  const _DebugThemeToolbar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 4,
      right: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          DebugThemeFamilyControl(),
          SizedBox(width: 4),
          _DebugThemeSwitch(),
        ],
      ),
    );
  }
}

class _DebugThemeSwitch extends StatelessWidget {
  const _DebugThemeSwitch();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Keep text-field selection and keyboard focus during a live mode change.
    return DebugThemeActionButton(
      icon: isDark ? Icons.light_mode : Icons.dark_mode,
      semanticLabel: 'Debug: switch to ${isDark ? "light" : "dark"} mode',
      onPressed: () async {
        try {
          await context.read<ThemeProvider>().setMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          );
        } catch (error, stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'debug theme switch',
            ),
          );
        }
      },
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Map<TabItem, Widget> _pageCache = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _pageForTab(TabItem tab) {
    return _pageCache.putIfAbsent(tab, () {
      switch (tab) {
        case TabItem.dashboard:
          return const DashboardPage();
        case TabItem.train:
          return const TrainPage();
        case TabItem.train2:
          return const Train2Page();
        case TabItem.catalog:
          return const CatalogPage();
        case TabItem.history:
          return const HistoryScreen();
        case TabItem.nutrition:
          return const NutritionPage();
        case TabItem.profile:
          return const ProfilePage();
        case TabItem.measurementsTrends:
          return const MeasurementsTrendsPage();
        case TabItem.nutritionLog:
          return const NutritionLogPage();
        case TabItem.combinedHistory:
          return const CombinedHistoryPage();
        case TabItem.formAndPosing:
          return const FormPosingPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navConfig = context.watch<NavBarConfig>();
    final strings = AppLocalizations.of(context);

    // 1) While loading, show a spinner
    if (!navConfig.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2) Grab the *current* list of tabs & pages
    final tabs = navConfig.items;

    // 3) If the current index is now too big, clamp it
    if (_selectedIndex >= tabs.length) {
      _selectedIndex = tabs.length - 1;
    }
    final pages = [
      for (var i = 0; i < tabs.length; i++)
        TickerMode(
          enabled: i == _selectedIndex,
          child: KeyedSubtree(
            key: ValueKey(tabs[i]),
            child: _pageForTab(tabs[i]),
          ),
        ),
    ];

    final bottomNavigationBar = TonosBottomNavigationBar(
      items: [
        for (final tab in tabs)
          BottomNavigationBarItem(
            icon: KeyedSubtree(
              key: AppTestKeys.mainTab(tab.storageKey),
              child: Icon(tab.icon),
            ),
            label: tab.localizedTitle(strings),
          ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar:
          Localizations.localeOf(context).languageCode == 'en'
              ? bottomNavigationBar
              : MediaQuery.withNoTextScaling(child: bottomNavigationBar),
      floatingActionButton: Consumer<ActiveSession>(
        builder:
            (_, session, __) =>
                session.isActive
                    ? const OngoingSessionFab()
                    : const SizedBox.shrink(),
      ),
    );
  }
}
