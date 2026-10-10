import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_generation_qa.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Expressive preset generation keeps form and action reachable', (
    tester,
  ) async {
    const layouts = <({Size size, double scale, double keyboardInset})>[
      (size: Size(320, 900), scale: 1, keyboardInset: 0),
      (size: Size(320, 900), scale: 2, keyboardInset: 280),
      (size: Size(390, 844), scale: 1.5, keyboardInset: 0),
      (size: Size(600, 1000), scale: 1, keyboardInset: 0),
      (size: Size(800, 390), scale: 1.5, keyboardInset: 0),
      (size: Size(1024, 768), scale: 2, keyboardInset: 0),
    ];
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ExpressiveThemeDefinition.light()
          : ExpressiveThemeDefinition.dark();
      for (final layout in layouts) {
        await tester.binding.setSurfaceSize(layout.size);
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.generatePlans}': true,
        });
        await tester.pumpWidget(
          Provider<AppRepository>.value(
            value: _GenerationRepository(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(layout.scale),
                  viewInsets: EdgeInsets.only(bottom: layout.keyboardInset),
                ),
                child: child!,
              ),
              home: const PresetGenerationQaScreen(profileId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(PresetGenerationQaScreen),
        );
        final strings = AppLocalizations.of(pageContext);
        final workoutSetup = find.text(strings.generateWorkoutSetupTitle);
        await tester.ensureVisible(workoutSetup);
        await tester.tap(workoutSetup);
        await tester.pumpAndSettle();

        final repsAndWeights = find.text(strings.generateRepsWeightsTitle);
        await tester.ensureVisible(repsAndWeights);
        await tester.tap(repsAndWeights);
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsNWidgets(4));
        final initialException = tester.takeException();
        expect(initialException, isNull, reason: '$brightness $layout');

        if (layout.keyboardInset > 0) {
          final sessionLength = find.byWidgetPredicate(
            (widget) =>
                widget is TextFormField &&
                widget.controller?.text == '60',
          );
          await tester.ensureVisible(sessionLength);
          await tester.tap(sessionLength);
          await tester.enterText(sessionLength, '50');
          await tester.pumpAndSettle();
        }

        final generate = find.byType(FloatingActionButton);
        expect(generate.hitTestable(), findsOneWidget, reason: '$layout');
        expect(
          tester.getRect(generate).bottom,
          lessThanOrEqualTo(layout.size.height - layout.keyboardInset),
          reason: '$layout',
        );
        expect(tester.takeException(), isNull, reason: '$brightness $layout');
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}

class _GenerationRepository extends AppRepository {
  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => const <BodyPart>[];
}
