// File: lib/main.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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
import 'l10n/tonos_localization_delegates.dart';

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
import 'theme/tonos_preview_presentation.dart';

import 'repositories/app_repository.dart';
import 'services/active_plan_store.dart';
import 'services/diagnostics_service.dart';
import 'utils/app_test_keys.dart';

const _compileTimeThemeLab = bool.fromEnvironment('TONOS_THEME_LAB');
const _previewStartupStageTimeout = Duration(seconds: 45);

Future<void> main() => runTonosApp();

/// Runs the production app with the same provider tree and repository.
///
/// The optional callbacks are used only by the isolated preview entry point.
/// Its identity guard runs after binding initialization and before preferences
/// or SQLite; the normal [main] path supplies neither callback.
Future<void> runTonosApp({
  TonosPreviewPresentation? previewPresentation,
  Future<void> Function()? beforeDataAccess,
  Future<void> Function(AppRepository repository)? beforeRunApp,
}) async {
  final diagnostics = DiagnosticsService.instance;
  var previewIdentityGuardVerified = previewPresentation == null;
  var previewStartupFailureShown = false;
  Zone? previewStartupZone;

  void showPreviewStartupFailure(Object error) {
    if (previewStartupFailureShown) return;
    previewStartupFailureShown = true;
    final initializedZone = previewStartupZone;
    if (initializedZone == null) {
      debugPrint(
        '[expressive-preview] startup failure before binding initialization: $error',
      );
      return;
    }
    initializedZone.run<void>(() => showExpressivePreviewStartupFailure(error));
  }

  final launch = runZonedGuarded<Future<void>>(
    () async {
      final launchStopwatch = Stopwatch()..start();

      void previewCheckpoint(String stage) {
        if (previewPresentation == null) return;
        debugPrint(
          '[expressive-preview] +${launchStopwatch.elapsedMilliseconds}ms $stage',
        );
      }

      Future<T> runPreviewStage<T>(
        String stage,
        Future<T> Function() action,
      ) async {
        if (previewPresentation == null) return action();
        try {
          final result = await action().timeout(_previewStartupStageTimeout);
          return result;
        } catch (error, stackTrace) {
          previewCheckpoint('$stage failed: $error');
          Error.throwWithStackTrace(error, stackTrace);
        }
      }

      try {
        WidgetsFlutterBinding.ensureInitialized();
        previewStartupZone = Zone.current;
        if (!hasRequiredPreviewIdentityGuard(
          isExpressivePreview: previewPresentation != null,
          hasIdentityGuard: beforeDataAccess != null,
        )) {
          final error = StateError(
            'Expressive preview startup requires an identity guard before app data access.',
          );
          previewCheckpoint('identity guard missing: $error');
          showPreviewStartupFailure(error);
          return;
        }
        if (beforeDataAccess != null) {
          final identityAccepted = await runPreviewDataAccessGuard(
            guard: () => runPreviewStage(
              'beforeDataAccess preview identity guard',
              beforeDataAccess,
            ),
            onFailure: (error, stackTrace) {
              previewCheckpoint('identity guard failed: $error\n$stackTrace');
              showPreviewStartupFailure(error);
            },
          );
          if (!previewIdentityVerificationAllowsStartup(
            accepted: identityAccepted,
            startupFailureShown: previewStartupFailureShown,
          )) {
            return;
          }
          previewIdentityGuardVerified = true;
        }
        if (previewPresentation == null) {
          await diagnostics.initialize();
        } else {
          await runPreviewStage(
            'diagnostics.initialize',
            diagnostics.initialize,
          );
        }

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
        final themeProvider = previewPresentation == null
            ? await ThemeProvider.load()
            : await runPreviewStage('ThemeProvider.load', ThemeProvider.load);
        final repo = AppRepository();
        if (beforeRunApp != null) {
          await runPreviewStage(
            'beforeRunApp preview fixtures',
            () => beforeRunApp(repo),
          );
        }
        runApp(
          buildTonosApp(
            repo: repo,
            themeProvider: themeProvider,
            previewPresentation: previewPresentation,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint(
            '[startup] first frame rendered in '
            '${launchStopwatch.elapsedMilliseconds}ms',
          );
        });
      } catch (error, stackTrace) {
        if (previewPresentation == null) {
          Error.throwWithStackTrace(error, stackTrace);
        }
        previewCheckpoint('startup failed: $error\n$stackTrace');
        showPreviewStartupFailure(error);
      }
    },
    (error, stackTrace) {
      if (shouldCaptureTonosStartupDiagnostic(
        isExpressivePreview: previewPresentation != null,
        identityGuardVerified: previewIdentityGuardVerified,
      )) {
        unawaited(
          diagnostics.captureException(
            error,
            stackTrace,
            category: 'uncaught_async',
          ),
        );
      } else {
        debugPrint(
          '[expressive-preview] uncaught startup error before identity guard acceptance; '
          'diagnostic capture skipped: $error\n$stackTrace',
        );
        showPreviewStartupFailure(error);
      }
    },
  );
  if (launch != null) await launch;
}

@visibleForTesting
bool hasRequiredPreviewIdentityGuard({
  required bool isExpressivePreview,
  required bool hasIdentityGuard,
}) => !isExpressivePreview || hasIdentityGuard;

@visibleForTesting
bool shouldCaptureTonosStartupDiagnostic({
  required bool isExpressivePreview,
  required bool identityGuardVerified,
}) => !isExpressivePreview || identityGuardVerified;

@visibleForTesting
bool previewIdentityVerificationAllowsStartup({
  required bool accepted,
  required bool startupFailureShown,
}) => accepted && !startupFailureShown;

@visibleForTesting
Future<bool> runPreviewDataAccessGuard({
  required Future<void> Function() guard,
  required void Function(Object error, StackTrace stackTrace) onFailure,
}) async {
  try {
    await guard();
    return true;
  } catch (error, stackTrace) {
    onFailure(error, stackTrace);
    return false;
  }
}

/// Shows a preview-only startup failure without opening preferences or SQLite.
/// Missing/rejected identity checks and staged-startup timeouts intentionally
/// fail closed instead of falling through to the production storage path.
void showExpressivePreviewStartupFailure(Object error) {
  runApp(_ExpressivePreviewStartupFailure(error: error));
}

class _ExpressivePreviewStartupFailure extends StatelessWidget {
  const _ExpressivePreviewStartupFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Expressive preview could not start',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Builds the production provider tree around an injected repository.
///
/// Device tests can disable repository ownership so pumping the widget tree
/// does not race their test-scoped repository lifecycle.
Widget buildTonosApp({
  required AppRepository repo,
  bool closeRepositoryOnDispose = true,
  ThemeProvider? themeProvider,
  TonosPreviewPresentation? previewPresentation,
}) {
  final themeProviderNode = themeProvider == null
      ? ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider())
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
    child: MyApp(previewPresentation: previewPresentation),
  );

  if (!closeRepositoryOnDispose) return app;
  return RepositoryLifecycle(repo: repo, child: app);
}

/// Builds the app shell's system-bar style for the active theme brightness.
SystemUiOverlayStyle appSystemUiOverlayStyleFor(Brightness brightness) =>
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: brightness,
    );

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
  const MyApp({super.key, this.previewPresentation});

  final TonosPreviewPresentation? previewPresentation;

  @override
  Widget build(BuildContext context) {
    Widget buildMaterialApp() {
      return Consumer3<
        ThemeProvider,
        OnboardingConfig,
        LocalePreferenceProvider
      >(
        builder: (context, themeProv, onboardingConf, localePreferences, _) {
          final preview = previewPresentation;
          final lightTheme =
              preview?.lightTheme ?? AppThemeFactory.light(themeProv.family);
          final darkTheme =
              preview?.darkTheme ?? AppThemeFactory.dark(themeProv.family);

          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            navigatorKey: preview?.navigatorKey,
            navigatorObservers: preview == null
                ? const <NavigatorObserver>[]
                : <NavigatorObserver>[preview.navigatorObserver],
            locale: preview?.localeOverride ?? localePreferences.locale,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: preview?.themeMode ?? themeProv.mode,
            builder: (context, child) {
              final showDebugToolbar =
                  preview == null &&
                  kDebugMode &&
                  const bool.fromEnvironment('TONOS_THEME_SWITCH');
              final appChild = child ?? const SizedBox.shrink();

              if (preview == null) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: appSystemUiOverlayStyleFor(
                    Theme.of(context).brightness,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ActiveSessionDurabilityBanner(child: appChild),
                      if (showDebugToolbar) const _DebugThemeToolbar(),
                    ],
                  ),
                );
              }

              final inheritedMedia = MediaQuery.of(context);
              final scale = preview.textScaleOverride;
              return Theme(
                data: preview.activeTheme,
                child: MediaQuery(
                  data: inheritedMedia.copyWith(
                    disableAnimations:
                        inheritedMedia.disableAnimations ||
                        preview.reducedMotion ||
                        preview.effectsOff,
                    textScaler: scale == null
                        ? inheritedMedia.textScaler
                        : TextScaler.linear(scale),
                  ),
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: appSystemUiOverlayStyleFor(preview.brightness),
                    child: Builder(
                      builder: (previewContext) {
                        final appShell = ActiveSessionDurabilityBanner(
                          child: appChild,
                        );
                        final content = preview.controlsChromeEnabled
                            ? MediaQuery.removePadding(
                                context: previewContext,
                                removeTop: true,
                                child: appShell,
                              )
                            : appShell;
                        return Column(
                          verticalDirection: VerticalDirection.up,
                          children: [
                            Expanded(child: content),
                            TonosPreviewControls(presentation: preview),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            home: preview != null
                ? const MainScreen()
                : !onboardingConf.initialized
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

    final preview = previewPresentation;
    if (preview == null) return buildMaterialApp();
    return AnimatedBuilder(
      animation: preview,
      builder: (context, _) => buildMaterialApp(),
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
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: Consumer<ActiveSession>(
        builder: (_, session, __) => session.isActive
            ? const OngoingSessionFab()
            : const SizedBox.shrink(),
      ),
    );
  }
}
