import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/profile/settings/database_settings_page.dart';
import 'package:env_test/screens/profile/settings/diagnostics_settings_page.dart';
import 'package:env_test/screens/profile/settings/gym_exercise_settings_page.dart';
import 'package:env_test/screens/profile/settings/measurements_trends_settings_page.dart';
import 'package:env_test/screens/profile/settings/profile_page.dart';
import 'package:env_test/screens/profile/settings/tutorials_settings_page.dart';
import 'package:env_test/screens/profile/settings/ui_appearance_settings_page.dart';
import 'package:env_test/screens/profile/settings/user_information_settings_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.profileHome}': true,
    });
  });

  testWidgets('Expressive Profile is isolated from Classic and Neo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final entry in <(String, ThemeData, bool)>[
      ('Expressive preview', ExpressiveThemeDefinition.light(), true),
      ('Classic', AppThemeFactory.light(AppThemeFamily.classic), false),
      ('Neo', AppThemeFactory.light(AppThemeFamily.neoBrutalism), false),
    ]) {
      await tester.pumpWidget(_profileApp(theme: entry.$2));
      await _pumpProfileAndFinishTutorial(tester);

      expect(tester.takeException(), isNull, reason: entry.$1);
      final profileContext = tester.element(find.byType(ProfilePage));
      expect(
        profileContext.usesExpressivePresentation,
        entry.$3,
        reason: entry.$1,
      );
      if (entry.$3) {
        expect(find.byType(SettingsPageScaffold), findsNothing);
        expect(find.byType(TonosSurface), findsAtLeastNWidgets(5));
        final rootTheme = Theme.of(tester.element(find.byType(ListView).first));
        final destination = rootTheme
            .extension<AppExpressiveDestinationTokens>();
        expect(destination?.family, AppExpressiveDestinationFamily.profile);
        final profileTokens = destination!;
        expect(profileTokens.surfacePrimary, const Color(0xFF51246B));
        expect(profileTokens.surfaceSecondary, const Color(0xFFBDE9DD));
        expect(profileTokens.surfaceAccent, const Color(0xFFC4DFFF));
        final strings = AppLocalizations.of(profileContext);

        final userInformationTile = tester.widget<SettingsActionTile>(
          find.byKey(AppTestKeys.profileUserInformation),
        );
        expect(userInformationTile.icon, Icons.badge_outlined);
        expect(userInformationTile.iconColor, SettingsAccent.account);
        expect(
          userInformationTile.subtitle,
          strings.profileUserInformationSubtitle,
        );
        expect(userInformationTile.onTap, isNotNull);
        expect(
          find.ancestor(
            of: find.text(strings.profileUserInformationTitle),
            matching: find.byType(TonosSurface),
          ),
          findsOneWidget,
          reason: 'User Information shares the Account surface at rest',
        );

        final sectionSurfaces = <String, Color>{
          strings.profileAccountSectionTitle: profileTokens.surfacePrimary,
          strings.profileTrainingSectionTitle: profileTokens.surfaceSecondary,
          strings.profileDataSectionTitle: profileTokens.surfaceAccent,
        };
        for (final section in sectionSurfaces.entries) {
          final sectionTitle = find.text(section.key);
          final sectionSurfaceFinder = find.ancestor(
            of: sectionTitle,
            matching: find.byType(TonosSurface),
          );
          expect(sectionSurfaceFinder, findsWidgets, reason: section.key);
          expect(
            tester.widget<TonosSurface>(sectionSurfaceFinder.first).color,
            section.value,
            reason: section.key,
          );
        }
        final diagnosticsTile = tester.widget<SettingsActionTile>(
          find.ancestor(
            of: find.text(strings.profileDiagnosticsTitle),
            matching: find.byType(SettingsActionTile),
          ),
        );
        expect(diagnosticsTile.iconColor, SettingsAccent.data);
      } else {
        expect(find.byType(SettingsPageScaffold), findsOneWidget);
        expect(find.byType(TonosSurface), findsNothing);
        final strings = AppLocalizations.of(profileContext);
        final diagnosticsTile = tester.widget<SettingsActionTile>(
          find.ancestor(
            of: find.text(strings.profileDiagnosticsTitle),
            matching: find.byType(SettingsActionTile),
          ),
        );
        expect(
          diagnosticsTile.iconColor,
          SettingsAccent.progress,
          reason: '${entry.$1} diagnostics retains the Classic accent',
        );
      }
    }

    await tester.pumpWidget(
      _profileApp(theme: ExpressiveThemeDefinition.dark()),
    );
    await _pumpProfileAndFinishTutorial(tester);
    final darkContext = tester.element(find.byType(ProfilePage));
    final darkStrings = AppLocalizations.of(darkContext);
    final darkDestination = Theme.of(
      tester.element(find.byType(ListView).first),
    ).extension<AppExpressiveDestinationTokens>()!;
    final darkUserInformationTile = tester.widget<SettingsActionTile>(
      find.byKey(AppTestKeys.profileUserInformation),
    );
    expect(darkUserInformationTile.icon, Icons.badge_outlined);
    expect(darkUserInformationTile.iconColor, SettingsAccent.account);
    expect(darkUserInformationTile.onTap, isNotNull);
    expect(
      find.ancestor(
        of: find.text(darkStrings.profileUserInformationTitle),
        matching: find.byType(TonosSurface),
      ),
      findsOneWidget,
    );
    final darkSections = <String, Color>{
      darkStrings.profileAccountSectionTitle: darkDestination.surfacePrimary,
      darkStrings.profileTrainingSectionTitle: darkDestination.surfaceSecondary,
      darkStrings.profileDataSectionTitle: darkDestination.surfaceAccent,
    };
    for (final section in darkSections.entries) {
      final sectionSurfaceFinder = find.ancestor(
        of: find.text(section.key),
        matching: find.byType(TonosSurface),
      );
      expect(
        tester.widget<TonosSurface>(sectionSurfaceFinder.first).color,
        section.value,
        reason: 'dark ${section.key}',
      );
    }
    expect(darkDestination.surfaceAccent, const Color(0xFF1F3E59));
  });

  testWidgets(
    'Expressive Profile preserves real root labels and destinations',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final observer = _RecordingNavigatorObserver();
      await tester.pumpWidget(
        _profileApp(
          theme: ExpressiveThemeDefinition.light(),
          navigatorObserver: observer,
        ),
      );
      await _pumpProfileAndFinishTutorial(tester);
      observer.pushedRoutes.clear();

      final profileContext = tester.element(find.byType(ProfilePage));
      final strings = AppLocalizations.of(profileContext);
      final destinations = <String, Type>{
        strings.profileUserInformationTitle: UserInformationSettingsPage,
        strings.profileUiAppearanceTitle: UIAppearanceSettingsPage,
        strings.profileGuidedTutorialsTitle: TutorialsSettingsPage,
        strings.profileGymWorkoutSettingsTitle: GymExerciseSettingsPage,
        strings.profileProgressSettingsTitle: MeasurementsTrendsSettingsPage,
        strings.profileDatabaseSettingsTitle: DatabaseSettingsPage,
        strings.profileDiagnosticsTitle: DiagnosticsSettingsPage,
      };

      for (final destination in destinations.entries) {
        final label = find.text(destination.key);
        await tester.ensureVisible(label);
        await tester.pumpAndSettle();
        expect(label, findsOneWidget, reason: destination.key);

        await tester.tap(label);
        expect(observer.pushedRoutes, hasLength(1), reason: destination.key);
        final route = observer.pushedRoutes.removeLast();
        expect(
          route,
          isA<MaterialPageRoute<dynamic>>(),
          reason: destination.key,
        );
        final page = (route as MaterialPageRoute<dynamic>).builder(
          profileContext,
        );
        expect(
          page,
          isA<AppExpressiveDestinationTheme>(),
          reason: destination.key,
        );
        final scopedPage = page as AppExpressiveDestinationTheme;
        expect(scopedPage.family, AppExpressiveDestinationFamily.profile);
        expect(
          scopedPage.child.runtimeType,
          destination.value,
          reason: destination.key,
        );

        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();
      }
      await tester.pumpAndSettle();

      final nutritionLabel = find.text(
        strings.profileDietNutritionSettingsTitle,
      );
      expect(nutritionLabel, findsOneWidget);
      final nutritionTile = tester.widget<SettingsActionTile>(
        find.ancestor(
          of: nutritionLabel,
          matching: find.byType(SettingsActionTile),
        ),
      );
      expect(nutritionTile.onTap, isNull);
      expect(nutritionTile.trailing, isA<SettingsStatusBadge>());
      final nutritionOpacity = tester.widget<Opacity>(
        find.ancestor(of: nutritionLabel, matching: find.byType(Opacity)),
      );
      expect(nutritionOpacity.opacity, 0.48);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive Profile handles 320dp across text scales and color schemes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final themeEntry in <(String, ThemeData)>[
        ('light', ExpressiveThemeDefinition.light()),
        ('dark', ExpressiveThemeDefinition.dark()),
      ]) {
        for (final scale in <double>[1, 1.15, 1.5, 2]) {
          await tester.pumpWidget(
            _profileApp(
              key: ValueKey<String>('${themeEntry.$1}-$scale'),
              theme: themeEntry.$2,
              textScale: scale,
            ),
          );
          await _pumpProfileAndFinishTutorial(tester);

          final profileContext = tester.element(find.byType(ProfilePage));
          final strings = AppLocalizations.of(profileContext);
          final userInformation = find.text(
            strings.profileUserInformationTitle,
          );
          await tester.ensureVisible(userInformation);
          await tester.pumpAndSettle();
          expect(
            userInformation,
            findsOneWidget,
            reason: '${themeEntry.$1}, text scale $scale',
          );
          expect(
            find.text(strings.profileGuidedTutorialsTitle),
            findsOneWidget,
            reason: '${themeEntry.$1}, text scale $scale',
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${themeEntry.$1}, text scale $scale before scrolling',
          );

          await tester.scrollUntilVisible(
            find.text(strings.profileDietNutritionSettingsTitle),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          final nutritionLabel = find.text(
            strings.profileDietNutritionSettingsTitle,
          );
          final nutritionTile = tester.widget<SettingsActionTile>(
            find.ancestor(
              of: nutritionLabel,
              matching: find.byType(SettingsActionTile),
            ),
          );
          expect(
            nutritionTile.onTap,
            isNull,
            reason: '${themeEntry.$1}, text scale $scale',
          );
          expect(
            find.text(strings.profileLater),
            findsOneWidget,
            reason: '${themeEntry.$1}, text scale $scale',
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${themeEntry.$1}, text scale $scale after scrolling',
          );
        }
      }
    },
  );

  testWidgets('Guided Tutorials remains a reachable Profile child route', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _profileApp(theme: ExpressiveThemeDefinition.light()),
    );
    await _pumpProfileAndFinishTutorial(tester);

    final strings = AppLocalizations.of(
      tester.element(find.byType(ProfilePage)),
    );
    await tester.tap(find.text(strings.profileGuidedTutorialsTitle));
    await tester.pumpAndSettle();

    expect(find.byType(TutorialsSettingsPage), findsOneWidget);
    expect(find.text(strings.tutorialsSettingsTitle), findsOneWidget);
    expect(find.text(strings.tutorialsControlsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpProfileAndFinishTutorial(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Widget _profileApp({
  Key? key,
  required ThemeData theme,
  NavigatorObserver? navigatorObserver,
  double textScale = 1,
}) {
  return MaterialApp(
    key: key,
    theme: theme,
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    navigatorObservers: <NavigatorObserver>[
      if (navigatorObserver != null) navigatorObserver,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: const ProfilePage(),
  );
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is MaterialPageRoute<dynamic>) pushedRoutes.add(route);
  }
}
