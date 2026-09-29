import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/train2_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Train2 optimized settings use shared form fields', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(430, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        SharedPreferences.setMockInitialValues(<String, Object>{});
        final repository = _Train2Repository();
        final profile = _TestSelectedProfile(repository: repository);
        final session = ActiveSession(
          repository: repository,
          retryDelay: (_) async {},
        );
        final units = UnitPreferenceProvider();
        addTearDown(profile.dispose);
        addTearDown(session.dispose);
        addTearDown(units.dispose);
        await session.ready;
        await units.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              Provider<ActivePlanStore>.value(
                value: ActivePlanStore(repository: repository),
              ),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ChangeNotifierProvider<ActiveSession>.value(value: session),
              ChangeNotifierProvider<UnitPreferenceProvider>.value(
                value: units,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const TickerMode(enabled: false, child: Train2Page()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final toggle = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        expect(toggle.borderRadius, theme.shapeTokens.trainTab);
        expect(toggle.borderColor, Colors.transparent);
        expect(toggle.selectedBorderColor, Colors.transparent);
        expect(toggle.fillColor, theme.colorScheme.primary);
        expect(toggle.selectedColor, theme.colorScheme.onPrimary);

        final selectorFrame = find.byWidgetPredicate((widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.color ==
                  theme.colorScheme.surfaceContainerHighest &&
              decoration.borderRadius == theme.shapeTokens.trainTab;
        });
        expect(selectorFrame, findsOneWidget);

        final strings = AppLocalizations.of(
          tester.element(find.byType(Train2Page)),
        );
        final presetHeading = tester.widget<Text>(
          find.text(strings.trainExercisePresets),
        );
        expect(presetHeading.style?.fontSize, 24);
        expect(presetHeading.style?.fontWeight, FontWeight.bold);
        expect(presetHeading.style?.color, isNull);

        final profileMonogram = tester.widget<Text>(find.text('P'));
        expect(
          profileMonogram.style?.color,
          theme.semanticColors.onTrainProfileAvatar,
        );
        expect(profileMonogram.style?.fontWeight, FontWeight.bold);

        final settingsButton = findTonosTooltip(
          strings.trainOptimizedSettingsTitle,
        );
        expect(settingsButton, findsOneWidget);
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        expect(find.byType(TonosFormField), findsNWidgets(2));
        final focusBody = tester.widget<Text>(
          find.text(strings.trainOptimizedSettingsFocusBody),
        );
        expect(focusBody.style?.fontSize, 12);
        expect(focusBody.style?.color, isNull);

        final focusHeading = tester.widget<Text>(
          find.text(strings.trainBodypartFocus),
        );
        expect(focusHeading.style?.fontWeight, FontWeight.bold);
        expect(focusHeading.style?.color, isNull);

        final focusHelp = tester.widget<Text>(
          find.text(strings.trainBodypartFocusHelp),
        );
        expect(focusHelp.style?.fontSize, 12);
        expect(focusHelp.style?.color, isNull);

        final fields = tester.widgetList<TextField>(find.byType(TextField));
        expect(fields, hasLength(2));
        final labels = [
          strings.trainWorkoutDuration,
          strings.trainSetsPerExercise,
        ];
        final suffixes = [strings.trainMinutesShort, strings.trainSetsShort];
        for (var index = 0; index < fields.length; index++) {
          final field = fields.elementAt(index);
          expect(field.decoration?.labelText, labels[index]);
          expect(field.decoration?.suffixText, suffixes[index]);
          expect(field.decoration?.border, const OutlineInputBorder());
          expect(field.keyboardType, TextInputType.number);
        }
        expect(tester.takeException(), isNull, reason: mode);

        await tester.tap(find.text(strings.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull, reason: mode);
      });
    }
  }
}

class _Train2Repository extends AppRepository {
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => const <BodyPart>[];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => const <Map<String, dynamic>>[];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => const <int>{};

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<WorkoutReportSession>> fetchWorkoutReportSessions({
    DateTime? start,
    DateTime? end,
  }) async => const <WorkoutReportSession>[];
}

class _TestSelectedProfile extends SelectedProfile {
  _TestSelectedProfile({required super.repository}) {
    final profile = GymProfile(
      id: 1,
      name: 'Test profile',
      createdAt: DateTime(2026),
    );
    profiles = [profile];
    currentProfile = profile;
  }

  @override
  Future<void> loadProfiles({int? preferredProfileId}) async {}
}
