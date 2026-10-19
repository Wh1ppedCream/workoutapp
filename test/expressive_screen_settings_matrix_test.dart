import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/profile/settings/gym_exercise_settings_page.dart';
import 'package:env_test/screens/profile/settings/profile_page.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const scenarios = <({String name, Size size, double scale, double dpr})>[
    (name: 'short phone', size: Size(320, 480), scale: 1, dpr: 1),
    (name: 'large text phone', size: Size(320, 640), scale: 2, dpr: 1),
    (name: 'short landscape', size: Size(640, 320), scale: 2, dpr: 1),
    (name: 'tablet portrait', size: Size(600, 960), scale: 1.5, dpr: 1),
    (name: 'tablet landscape', size: Size(1024, 768), scale: 2, dpr: 1),
    (name: 'dense phone', size: Size(411, 914), scale: 1.15, dpr: 3),
    (name: 'dense tablet', size: Size(800, 1280), scale: 1.5, dpr: 2),
  ];

  for (final family in <AppThemeFamily?>[...AppThemeFamily.values, null]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family?.name ?? 'expressive'} ${brightness.name} Profile retains navigation through resize, safe insets, and accessibility settings',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            'guided_tutorial_completed.${TutorialIds.profileHome}': true,
          });
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final theme = family == null
              ? (brightness == Brightness.light
                    ? ExpressiveThemeDefinition.light()
                    : ExpressiveThemeDefinition.dark())
              : (brightness == Brightness.light
                    ? AppThemeFactory.light(family)
                    : AppThemeFactory.dark(family));

          for (final scenario in scenarios) {
            tester.view.devicePixelRatio = scenario.dpr;
            tester.view.physicalSize = scenario.size * scenario.dpr;
            await tester.pumpWidget(
              MaterialApp(
                theme: theme,
                locale: const Locale('fr'),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scenario.scale),
                    padding: const EdgeInsets.only(top: 24, bottom: 34),
                    viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
                    boldText: true,
                    highContrast: true,
                    disableAnimations: true,
                    accessibleNavigation: true,
                  ),
                  child: child!,
                ),
                home: const ProfilePage(),
              ),
            );
            await tester.pumpAndSettle();
            await tester.pump(const Duration(milliseconds: 600));
            await tester.pumpAndSettle();
            tester
                .state<ScrollableState>(find.byType(Scrollable).first)
                .position
                .jumpTo(0);
            await tester.pumpAndSettle();
            final strings = AppLocalizations.of(
              tester.element(find.byType(ProfilePage)),
            );

            for (final label in [
              strings.profileUserInformationTitle,
              strings.profileUiAppearanceTitle,
              strings.profileGuidedTutorialsTitle,
              strings.profileGymWorkoutSettingsTitle,
              strings.profileProgressSettingsTitle,
              strings.profileDatabaseSettingsTitle,
              strings.profileDiagnosticsTitle,
            ]) {
              final tile = find.ancestor(
                of: find.text(label),
                matching: find.byType(SettingsActionTile),
              );
              await tester.scrollUntilVisible(
                tile,
                180,
                scrollable: find.byType(Scrollable).first,
              );
              await tester.ensureVisible(tile);
              await tester.pumpAndSettle();
              expect(
                tile.hitTestable(),
                findsOneWidget,
                reason: '${scenario.name}: $label',
              );
              expect(tester.getSize(tile).height, greaterThanOrEqualTo(48));
              final rect = tester.getRect(tile);
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(scenario.size.width));
              expect(
                tester.takeException(),
                isNull,
                reason: '${scenario.name}: $label',
              );
            }

            final gym = find.text(strings.profileGymWorkoutSettingsTitle);
            await tester.scrollUntilVisible(
              gym,
              -180,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.ensureVisible(gym);
            await tester.pumpAndSettle();
            await tester.tap(gym);
            await tester.pumpAndSettle();
            expect(find.byType(GymExerciseSettingsPage), findsOneWidget);
            expect(tester.takeException(), isNull, reason: scenario.name);
            Navigator.of(tester.element(find.byType(GymExerciseSettingsPage)))
                .pop();
            await tester.pumpAndSettle();
            expect(find.byType(ProfilePage), findsOneWidget);
            await tester.pump(const Duration(milliseconds: 600));
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }
}
