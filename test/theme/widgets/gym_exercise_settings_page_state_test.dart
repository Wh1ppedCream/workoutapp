import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/screens/profile/settings/gym_exercise_settings_page.dart';
import 'package:env_test/services/workout_exit_preferences.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';

ToggleablePainter _toggleablePainter(WidgetTester tester, Finder control) {
  final paintFinder = find.descendant(
    of: control,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is ToggleablePainter,
    ),
  );
  expect(paintFinder, findsOneWidget);
  return tester.widget<CustomPaint>(paintFinder).painter! as ToggleablePainter;
}

void main() {
  final themes = <String, ThemeData>{
    'Classic light': ClassicThemeDefinition.light(),
    'Classic dark': ClassicThemeDefinition.dark(),
    'Neo light': NeoBrutalismThemeDefinition.light(),
    'Neo dark': NeoBrutalismThemeDefinition.dark(),
  };

  for (final entry in themes.entries) {
    testWidgets('${entry.key} gym exit behavior radio state', (tester) async {
      final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousHighlightStrategy;
      });
      await tester.binding.setSurfaceSize(const Size(420, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: entry.value,
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GymExerciseSettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(GymExerciseSettingsPage));
      final strings = AppLocalizations.of(pageContext);
      await tester.tap(find.text(strings.gymSettingsExitTitle).first);
      await tester.pumpAndSettle();

      final radioTileFinder = find.byType(RadioListTile<WorkoutExitBehavior>);
      final radioTiles =
          tester
              .widgetList<RadioListTile<WorkoutExitBehavior>>(radioTileFinder)
              .toList();
      final radioFinder = find.byType(Radio<WorkoutExitBehavior>);
      final radios =
          tester.widgetList<Radio<WorkoutExitBehavior>>(radioFinder).toList();
      expect(radioTiles, hasLength(3));
      expect(radios, hasLength(3));

      final dialogContext = tester.element(radioFinder.first);
      final theme = Theme.of(dialogContext);
      final neo = entry.key.startsWith('Neo');
      final dialogSurface =
          theme.dialogTheme.backgroundColor ??
          dialogContext.surfaceTokens.dialog;
      final dialogForeground = tonosForegroundForSurface(
        dialogContext,
        dialogSurface,
      );
      final selectedColor = neo ? dialogForeground : theme.colorScheme.primary;
      final unselectedColor =
          neo ? dialogForeground : theme.colorScheme.onSurfaceVariant;
      if (neo) {
        final fillColor = theme.radioTheme.fillColor!;
        expect(
          fillColor.resolve({WidgetState.selected, WidgetState.focused}),
          dialogForeground,
        );
        expect(fillColor.resolve({WidgetState.focused}), dialogForeground);
      }

      expect(
        radioTiles.map((radio) => radio.value),
        WorkoutExitBehavior.values,
      );
      for (var index = 0; index < radioTiles.length; index++) {
        final tile = radioTiles[index];
        final radio = radios[index];
        final painter = _toggleablePainter(tester, radioFinder.at(index));
        final selected = tile.value == tile.groupValue;
        expect(tile.fillColor, isNull);
        expect(tile.onChanged, isNotNull);
        expect(radio.value, tile.value);
        expect(painter.position.value, selected ? 1 : 0);
        expect(painter.activeColor, selectedColor);
        expect(painter.inactiveColor, unselectedColor);
        expect(
          find.ancestor(
            of: radioFinder.at(index),
            matching: find.byType(ExcludeFocus),
          ),
          findsOneWidget,
        );
      }

      expect(tester.takeException(), isNull);
    });
  }
}
