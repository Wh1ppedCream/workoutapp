import 'dart:ui' show SemanticsFlag;

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
          expect(preset.presetChildSetIds.single, <int, List<int>>{
            0: <int>[103],
          });
          expect(
            (preset.exercises.single as WeightExercise).changeSets[0],
            hasLength(1),
          );
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

          expect(find.byType(TonosField), findsNWidgets(5));
          final fields =
              tester.widgetList<TextField>(find.byType(TextField)).toList();
          expect(fields, hasLength(5));
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
          expect(fields[4].decoration?.hintText, 'set');
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
          expect(tester.getSize(find.byType(TextField).at(4)).width, 60);
          _expectBoldOnlyEmphasis(tester, find.text('Squat'));
          await tester.enterText(find.byType(TextField).first, '2.5');
          expect(fields.first.controller?.text, '2.5');

          await _expectAutomaticControlStates(tester, family, theme, strings);

          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

Future<void> _expectAutomaticControlStates(
  WidgetTester tester,
  AppThemeFamily family,
  ThemeData theme,
  AppLocalizations strings,
) async {
  final semantics = tester.ensureSemantics();
  final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  try {
    final skipTile = find.ancestor(
      of: find.text(strings.automaticSkipFirstSet),
      matching: find.byType(CheckboxListTile),
    );
    expect(skipTile, findsOneWidget);
    final skipCheckbox = find.descendant(
      of: skipTile,
      matching: find.byType(Checkbox),
    );
    expect(skipCheckbox, findsOneWidget);
    expect(tester.widget<Checkbox>(skipCheckbox).activeColor, isNull);
    _expectResolvedControl(
      tester,
      skipCheckbox,
      theme,
      isCheckbox: true,
      selected: true,
      semanticsTarget: skipTile,
    );

    await tester.tap(find.text(strings.automaticManualSelect));
    await tester.pumpAndSettle();
    _expectBoldOnlyEmphasis(tester, find.text('Squat'));

    final manualCheckboxes = _findCheckboxesOutsideTiles(tester);
    expect(manualCheckboxes, hasLength(3));
    expect(
      find.text(strings.automaticChildSetLabel(1, 1, '20.0', 8)),
      findsOneWidget,
    );
    for (final checkbox in manualCheckboxes.take(2)) {
      final widget = tester.widget<Checkbox>(checkbox);
      expect(widget.value, isFalse);
      expect(widget.activeColor, isNull);
      expect(widget.onChanged, isNotNull);
      _expectResolvedControl(
        tester,
        checkbox,
        theme,
        isCheckbox: true,
        selected: false,
      );
    }
    _requestControlFocus(tester, manualCheckboxes.first);
    await tester.pumpAndSettle();
    _expectResolvedControl(
      tester,
      manualCheckboxes.first,
      theme,
      isCheckbox: true,
      selected: false,
      focused: true,
    );
    await tester.tap(manualCheckboxes.first);
    await tester.pumpAndSettle();
    _expectResolvedControl(
      tester,
      manualCheckboxes.first,
      theme,
      isCheckbox: true,
      selected: true,
      focused: true,
    );

    final childCheckbox = manualCheckboxes.last;
    expect(tester.widget<Checkbox>(childCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(childCheckbox).activeColor, isNull);
    expect(tester.widget<Checkbox>(childCheckbox).onChanged, isNotNull);
    _expectResolvedControl(
      tester,
      childCheckbox,
      theme,
      isCheckbox: true,
      selected: false,
    );
    await tester.tap(childCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(childCheckbox).value, isTrue);
    _expectResolvedControl(
      tester,
      childCheckbox,
      theme,
      isCheckbox: true,
      selected: true,
    );

    await tester.tap(find.text(strings.automaticMethodsTab));
    await tester.pumpAndSettle();
    _expectBoldOnlyEmphasis(tester, find.text(strings.automaticScopeLabel));
    _expectBoldOnlyEmphasis(tester, find.text(strings.automaticAdjustScope));

    final methodTiles = find.byType(CheckboxListTile);
    final methodCheckboxes = find.descendant(
      of: methodTiles,
      matching: find.byType(Checkbox),
    );
    expect(methodTiles, findsNWidgets(3));
    expect(methodCheckboxes, findsNWidgets(3));
    final methodValues = <bool?>[];
    for (var index = 0; index < methodCheckboxes.evaluate().length; index++) {
      final control = methodCheckboxes.at(index);
      final widget = tester.widget<Checkbox>(control);
      methodValues.add(widget.value);
      expect(widget.activeColor, isNull);
      expect(widget.onChanged, isNotNull);
      final tile = find.ancestor(
        of: control,
        matching: find.byType(CheckboxListTile),
      );
      _expectResolvedControl(
        tester,
        control,
        theme,
        isCheckbox: true,
        selected: widget.value ?? false,
        semanticsTarget: tile,
      );
    }
    expect(methodValues, <bool?>[true, true, false]);

    final radios = find.byWidgetPredicate((widget) => widget is Radio<dynamic>);
    expect(radios, findsNWidgets(5));
    final radioSelected = <bool>[];
    for (var index = 0; index < radios.evaluate().length; index++) {
      final control = radios.at(index);
      final widget = tester.widget<Radio<dynamic>>(control);
      final selected = widget.value == widget.groupValue;
      radioSelected.add(selected);
      expect(widget.activeColor, theme.colorScheme.primary);
      final inheritedRadioColor = _expectedControlColor(
        theme,
        isCheckbox: false,
        selected: true,
        focused: false,
      );
      expect(
        widget.activeColor == inheritedRadioColor,
        family == AppThemeFamily.classic,
        reason:
            'The route keeps primary ink when the Neo radio theme resolves purple.',
      );
      final tile = find.ancestor(
        of: control,
        matching: find.byWidgetPredicate(
          (candidate) => candidate is RadioListTile<dynamic>,
        ),
      );
      _expectResolvedControl(
        tester,
        control,
        theme,
        isCheckbox: false,
        selected: selected,
        routeRadioPrimary: true,
        semanticsTarget: tile,
      );
    }
    expect(radioSelected, <bool>[false, false, true, true, false]);

    final unselectedRadio = radios.at(0);
    final unselectedRadioTile = find.ancestor(
      of: unselectedRadio,
      matching: find.byWidgetPredicate(
        (candidate) => candidate is RadioListTile<dynamic>,
      ),
    );
    _expectResolvedControl(
      tester,
      unselectedRadio,
      theme,
      isCheckbox: false,
      selected: false,
      routeRadioPrimary: true,
      semanticsTarget: unselectedRadioTile,
    );
    await tester.tap(unselectedRadio);
    await tester.pumpAndSettle();
    _expectResolvedControl(
      tester,
      unselectedRadio,
      theme,
      isCheckbox: false,
      selected: true,
      routeRadioPrimary: true,
      semanticsTarget: unselectedRadioTile,
    );

    expect(tester.takeException(), isNull);
  } finally {
    semantics.dispose();
    FocusManager.instance.highlightStrategy = previousHighlightStrategy;
  }
}

List<Finder> _findCheckboxesOutsideTiles(WidgetTester tester) {
  return find
      .byType(Checkbox)
      .evaluate()
      .where((element) {
        final control = find.byElementPredicate(
          (candidate) => identical(candidate, element),
        );
        return find
            .ancestor(of: control, matching: find.byType(CheckboxListTile))
            .evaluate()
            .isEmpty;
      })
      .map((element) {
        return find.byElementPredicate(
          (candidate) => identical(candidate, element),
        );
      })
      .toList();
}

Finder _toggleablePaint(Finder control) {
  final paint = find.descendant(
    of: control,
    matching: find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is ToggleablePainter,
    ),
  );
  expect(paint, findsOneWidget);
  return paint;
}

ToggleablePainter _toggleablePainter(WidgetTester tester, Finder control) {
  return tester.widget<CustomPaint>(_toggleablePaint(control)).painter!
      as ToggleablePainter;
}

void _requestControlFocus(WidgetTester tester, Finder control) {
  Focus.of(tester.element(_toggleablePaint(control))).requestFocus();
}

void _expectResolvedControl(
  WidgetTester tester,
  Finder control,
  ThemeData theme, {
  required bool isCheckbox,
  required bool selected,
  bool focused = false,
  bool routeRadioPrimary = false,
  Finder? semanticsTarget,
}) {
  final painter = _toggleablePainter(tester, control);
  final active =
      !isCheckbox && routeRadioPrimary
          ? theme.colorScheme.primary
          : _expectedControlColor(
            theme,
            isCheckbox: isCheckbox,
            selected: true,
            focused: focused,
          );
  if (isCheckbox) {
    expect(
      theme.colorScheme.primary,
      active,
      reason: 'Removing activeColor must preserve the selected checkbox ink.',
    );
  }
  final inactive = _expectedControlColor(
    theme,
    isCheckbox: isCheckbox,
    selected: false,
    focused: focused,
  );
  expect(painter.activeColor, active);
  expect(painter.inactiveColor, inactive);
  expect(painter.position.value, selected ? 1 : 0);
  expect(painter.isFocused, focused);
  if (focused) {
    expect(painter.reactionFocusFade.value, greaterThan(0));
  }
  final semantics =
      tester.getSemantics(semanticsTarget ?? control).getSemanticsData();
  expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
  expect(
    semantics.hasFlag(SemanticsFlag.isChecked),
    selected,
    reason: semantics.toString(),
  );
}

Color _expectedControlColor(
  ThemeData theme, {
  required bool isCheckbox,
  required bool selected,
  required bool focused,
}) {
  final states = <WidgetState>{
    if (selected) WidgetState.selected,
    if (focused) WidgetState.focused,
  };
  final themedColor =
      isCheckbox
          ? theme.checkboxTheme.fillColor?.resolve(states)
          : theme.radioTheme.fillColor?.resolve(states);
  if (themedColor != null) return themedColor;
  if (isCheckbox) {
    return selected ? theme.colorScheme.primary : Colors.transparent;
  }
  if (selected) return theme.colorScheme.primary;
  return focused
      ? theme.colorScheme.onSurface
      : theme.colorScheme.onSurfaceVariant;
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
    <String, dynamic>{
      'id': 103,
      'parent_set_id': 101,
      'weight': 20.0,
      'reps': 8,
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
