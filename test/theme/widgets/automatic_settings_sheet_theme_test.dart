import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/widgets/tonos_field.dart';
import 'package:env_test/widgets/automatic_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.code} ${brightness.name} automatic settings use themed fields',
        (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          await tester.binding.setSurfaceSize(const Size(430, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final theme =
              brightness == Brightness.light
                  ? AppThemeFactory.light(family)
                  : AppThemeFactory.dark(family);
          final repository = _PresetRepository();
          final preset = PresetSession(1, repository: repository);
          await preset.ready;
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(preset.dispose);
          addTearDown(units.dispose);

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider<UnitPreferenceProvider>.value(
                  value: units,
                ),
              ],
              child: MaterialApp(
                theme: theme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return Center(
                        child: ElevatedButton(
                          onPressed:
                              () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                builder:
                                    (_) =>
                                        AutomaticSettingsSheet(preset: preset),
                              ),
                          child: const Text('Open automatic settings'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open automatic settings'));
          await tester.pumpAndSettle();

          expect(find.byType(TonosField), findsNWidgets(4));
          final fields =
              tester.widgetList<TextField>(find.byType(TextField)).toList();
          expect(fields, hasLength(4));
          final strings = AppLocalizations.of(
            tester.element(find.byType(AutomaticSettingsSheet)),
          );
          expect(
            fields.first.decoration?.labelText,
            strings.automaticGlobalIncrement,
          );
          expect(fields.first.decoration?.suffixText, 'lbs');
          expect(
            fields
                .skip(1)
                .every((field) => field.decoration?.labelText == 'IA'),
            isTrue,
          );
          expect(fields[2].decoration?.hintText, 'set');
          expect(
            fields.every(
              (field) =>
                  field.keyboardType ==
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            isTrue,
          );
          expect(
            fields.every(
              (field) => field.decoration?.border is OutlineInputBorder,
            ),
            isTrue,
          );
          final tabBar = tester.widget<TabBar>(find.byType(TabBar));
          expect(tabBar.labelColor, theme.colorScheme.primary);
          expect(
            tabBar.unselectedLabelColor,
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
          );
          expect(tabBar.indicatorColor, theme.colorScheme.primary);
          final expectedDivider = theme.colorScheme.onSurface.withValues(
            alpha: 0.12,
          );
          expect(
            find.byWidgetPredicate(
              (widget) => widget is Divider && widget.color == expectedDivider,
            ),
            findsOneWidget,
          );
          final decorators =
              tester
                  .widgetList<InputDecorator>(find.byType(InputDecorator))
                  .toList();
          expect(decorators, hasLength(fields.length));
          for (final decorator in decorators) {
            expect(
              decorator.decoration.filled,
              theme.inputDecorationTheme.filled,
            );
            expect(
              decorator.decoration.fillColor,
              theme.inputDecorationTheme.fillColor,
            );
            expect(
              decorator.decoration.labelStyle,
              theme.inputDecorationTheme.labelStyle,
            );
          }
          expect(tester.getSize(find.byType(TextField).at(1)).width, 80);
          expect(tester.getSize(find.byType(TextField).at(2)).width, 60);
          expect(tester.getSize(find.byType(TextField).at(3)).width, 60);
          _expectBoldOnlyEmphasis(tester, find.text('Squat'));
          await tester.enterText(find.byType(TextField).first, '2.5');
          expect(fields.first.controller?.text, '2.5');

          await tester.tap(find.text(strings.automaticManualSelect));
          await tester.pumpAndSettle();
          _expectBoldOnlyEmphasis(tester, find.text('Squat'));

          await tester.tap(find.text(strings.automaticMethodsTab));
          await tester.pumpAndSettle();
          _expectBoldOnlyEmphasis(
            tester,
            find.text(strings.automaticScopeLabel),
          );
          _expectBoldOnlyEmphasis(
            tester,
            find.text(strings.automaticAdjustScope),
          );

          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

void _expectBoldOnlyEmphasis(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final text = tester.widget<Text>(finder);
  final inherited = DefaultTextStyle.of(tester.element(finder)).style;
  expect(text.style?.fontWeight, FontWeight.bold);
  expect(text.style?.fontSize, isNull);
  expect(text.style?.color, isNull);

  final effective = inherited.merge(text.style);
  expect(effective.fontSize, inherited.fontSize);
  expect(effective.color, inherited.color);
  expect(effective.fontWeight, FontWeight.bold);
}

class _PresetRepository extends AppRepository {
  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'Test preset',
        createdAt: DateTime.utc(2026),
      );

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      <Map<String, dynamic>>[
        <String, dynamic>{'id': 11, 'type': 'weight', 'exercise_def_id': 21},
      ];

  @override
  Future<Map<String, String?>> fetchDefinitionInfo(int defId) async =>
      <String, String?>{'name': 'Squat', 'equipmentName': 'Barbell'};

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSets(
    int presetExerciseId,
  ) async => <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 101,
      'parent_set_id': null,
      'weight': 20.0,
      'reps': 8,
    },
    <String, dynamic>{
      'id': 102,
      'parent_set_id': null,
      'weight': 25.0,
      'reps': 6,
    },
  ];

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;

  @override
  Future<Map<String, dynamic>?> fetchPresetExerciseAuto(
    int presetExerciseId,
  ) async => null;

  @override
  Future<Map<String, dynamic>?> fetchPresetSetAuto(int presetSetId) async =>
      null;
}
