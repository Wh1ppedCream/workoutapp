import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/screens/exercise/optimized_workout_settings_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode optimized settings retain numeric field recipes', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(430, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TickerMode(
              enabled: false,
              child: OptimizedWorkoutSettingsPage(
                initialMinutes: 45,
                initialMinSets: 2,
                initialMaxSets: 4,
                initialRepWeightMode: RepWeightGenerationMode.mixed,
                initialTargetRepCount: 8,
                initialStarterWeightIntensity: StarterWeightIntensity.medium,
                initialPreferredBodypartIds: const <int>{},
                initialBlacklistedBodypartIds: const <int>{},
                bodyParts: const <BodyPart>[],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(TonosFormField), findsNWidgets(4));
        final strings = AppLocalizations.of(
          tester.element(find.byType(OptimizedWorkoutSettingsPage)),
        );
        final labels = [
          strings.optimizedWorkoutDuration,
          strings.optimizedMinimumSets,
          strings.optimizedMaximumSets,
          strings.optimizedTargetReps,
        ];
        final suffixes = [
          strings.unitMinutesShort,
          strings.unitSets,
          strings.unitSets,
          strings.unitReps,
        ];
        final actions = [
          TextInputAction.next,
          TextInputAction.next,
          TextInputAction.done,
          TextInputAction.next,
        ];
        final fields = tester.widgetList<TextField>(find.byType(TextField));

        expect(fields, hasLength(4));
        for (var index = 0; index < fields.length; index++) {
          expect(fields.elementAt(index).decoration?.labelText, labels[index]);
          expect(
            fields.elementAt(index).decoration?.suffixText,
            suffixes[index],
          );
          expect(
            fields.elementAt(index).decoration?.border,
            const OutlineInputBorder(),
          );
          expect(fields.elementAt(index).keyboardType, TextInputType.number);
          expect(fields.elementAt(index).textInputAction, actions[index]);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
