import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Exercise Catalog filter controls resolve correctly', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(480, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
        });

        final repository = _ExerciseCatalogRepository();
        final selectedProfile = SelectedProfile(repository: repository)
          ..currentProfile = _ExerciseCatalogDatabaseHelper.profiles.first;
        addTearDown(selectedProfile.dispose);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(
                value: selectedProfile,
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ExerciseCatalogPage(),
            ),
          ),
        );
        await _pumpFor(tester, const Duration(milliseconds: 600));

        final pageContext = tester.element(find.byType(ExerciseCatalogPage));
        final strings = AppLocalizations.of(pageContext);
        final isNeo = family == AppThemeFamily.neoBrutalism;
        final isDarkNeo = isNeo && brightness == Brightness.dark;
        final filterMenuSurface =
            theme.popupMenuTheme.color ?? theme.colorScheme.surfaceContainer;
        final expectedMenuSurface =
            isDarkNeo ? filterMenuSurface : theme.canvasColor;
        final expectedMenuTextColor =
            isDarkNeo
                ? tonosForegroundForSurface(pageContext, filterMenuSurface)
                : isNeo
                ? tonosForegroundForSurface(
                  pageContext,
                  pageContext.surfaceTokens.settingsInput,
                )
                : theme.textTheme.titleMedium?.color ??
                    theme.colorScheme.onSurface;

        final filterButton = find.byIcon(Icons.filter_list);
        expect(filterButton, findsOneWidget);
        await tester.tap(filterButton);
        await _pumpFor(tester, const Duration(milliseconds: 350));

        final dialogFinder = find.byType(AlertDialog);
        expect(dialogFinder, findsOneWidget);
        final dialogContext = tester.element(dialogFinder);
        final dialogTheme = Theme.of(dialogContext);
        final dialogMaterialFinder =
            find
                .descendant(of: dialogFinder, matching: find.byType(Material))
                .first;
        final dialogMaterial = tester.widget<Material>(dialogMaterialFinder);
        expect(
          dialogMaterial.color,
          dialogTheme.dialogTheme.backgroundColor ??
              dialogTheme.colorScheme.surfaceContainerHigh,
        );

        expect(find.text(strings.catalogSelectedFilters), findsOneWidget);
        expect(find.text(strings.catalogWorkspaceProfile), findsOneWidget);
        expect(find.text(strings.catalogEquipment), findsOneWidget);
        expect(find.text(strings.catalogFocusArea), findsOneWidget);
        expect(find.text(strings.catalogSpecificMuscle), findsOneWidget);

        final profileField = find.byType(DropdownButtonFormField<int>);
        final equipmentField = find
            .byType(DropdownButtonFormField<String>)
            .at(0);
        final areaField = find.byType(DropdownButtonFormField<String>).at(1);
        final muscleField = find.byType(DropdownButtonFormField<String>).at(2);
        final profileDropdown = find.descendant(
          of: profileField,
          matching: find.byType(DropdownButton<int>),
        );
        final equipmentDropdown = find.descendant(
          of: equipmentField,
          matching: find.byType(DropdownButton<String>),
        );
        final areaDropdown = find.descendant(
          of: areaField,
          matching: find.byType(DropdownButton<String>),
        );
        final muscleDropdown = find.descendant(
          of: muscleField,
          matching: find.byType(DropdownButton<String>),
        );

        expect(tester.widget<DropdownButton<int>>(profileDropdown).value, 1);
        final expectedEnabledIconColor =
            isNeo
                ? tonosForegroundForSurface(
                  pageContext,
                  pageContext.surfaceTokens.settingsInput,
                )
                : brightness == Brightness.light
                ? Colors.grey.shade700
                : Colors.white70;
        expect(
          _dropdownIconColor(tester, profileField),
          expectedEnabledIconColor,
        );

        await _verifyDropdownMenu<int>(
          tester: tester,
          field: profileField,
          dropdown: profileDropdown,
          selectedLabel: 'Home Gym',
          unselectedLabel: 'Travel Gym',
          selectedValue: 1,
          chosenValue: 2,
          expectedSurface: expectedMenuSurface,
          expectedTextColor: expectedMenuTextColor,
          expectedIconColor: expectedEnabledIconColor,
        );
        await _verifyDropdownMenu<String>(
          tester: tester,
          field: equipmentField,
          dropdown: equipmentDropdown,
          selectedLabel: strings.commonAll,
          unselectedLabel: 'Barbell',
          selectedValue: '__all__',
          chosenValue: 'Barbell',
          expectedSurface: expectedMenuSurface,
          expectedTextColor: expectedMenuTextColor,
          expectedIconColor: expectedEnabledIconColor,
        );
        await _verifyDropdownMenu<String>(
          tester: tester,
          field: areaField,
          dropdown: areaDropdown,
          selectedLabel: strings.commonAll,
          unselectedLabel: 'Chest',
          selectedValue: '__all__',
          chosenValue: 'Chest',
          expectedSurface: expectedMenuSurface,
          expectedTextColor: expectedMenuTextColor,
          expectedIconColor: expectedEnabledIconColor,
        );
        await _verifyDropdownMenu<String>(
          tester: tester,
          field: muscleField,
          dropdown: muscleDropdown,
          selectedLabel: strings.commonAll,
          unselectedLabel: 'Pectorals',
          selectedValue: '__all__',
          chosenValue: 'Pectorals',
          expectedSurface: expectedMenuSurface,
          expectedTextColor: expectedMenuTextColor,
          expectedIconColor: expectedEnabledIconColor,
        );

        final profileFilter = find.byType(SwitchListTile);
        expect(tester.widget<SwitchListTile>(profileFilter).value, isTrue);
        expect(
          tester
              .widget<Switch>(
                find.descendant(
                  of: profileFilter,
                  matching: find.byType(Switch),
                ),
              )
              .value,
          isTrue,
        );

        await tester.tap(profileFilter);
        await _pumpFor(tester, const Duration(milliseconds: 250));
        expect(tester.widget<SwitchListTile>(profileFilter).value, isFalse);
        expect(
          tester.widget<DropdownButton<int>>(profileDropdown).onChanged,
          isNull,
        );
        expect(
          _dropdownIconColor(tester, profileField),
          brightness == Brightness.light
              ? Colors.grey.shade400
              : Colors.white10,
        );
        final disabledProfileLabel = find.text('Travel Gym');
        expect(disabledProfileLabel, findsOneWidget);
        final disabledProfileTextColor = _renderParagraphColor(
          tester,
          disabledProfileLabel,
        );
        final disabledProfileDropdown = tester.widget<DropdownButton<int>>(
          profileDropdown,
        );
        expect(
          disabledProfileTextColor,
          isNeo
              ? disabledProfileDropdown.style?.color
              : Theme.of(tester.element(profileDropdown)).disabledColor,
        );

        await tester.tap(profileField);
        await _pumpFor(tester, const Duration(milliseconds: 250));
        expect(find.text('Home Gym'), findsNothing);

        await tester.tap(profileFilter);
        await _pumpFor(tester, const Duration(milliseconds: 250));
        expect(tester.widget<SwitchListTile>(profileFilter).value, isTrue);
        expect(
          tester.widget<DropdownButton<int>>(profileDropdown).onChanged,
          isNotNull,
        );
        expect(
          _dropdownIconColor(tester, profileField),
          expectedEnabledIconColor,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<void> _verifyDropdownMenu<T>({
  required WidgetTester tester,
  required Finder field,
  required Finder dropdown,
  required String selectedLabel,
  required String unselectedLabel,
  required T selectedValue,
  required T chosenValue,
  required Color expectedSurface,
  required Color expectedTextColor,
  required Color expectedIconColor,
}) async {
  final button = tester.widget<DropdownButton<T>>(dropdown);
  expect(button.value, selectedValue);
  expect(button.onChanged, isNotNull);
  expect(_dropdownIconColor(tester, field), expectedIconColor);

  await tester.tap(field);
  await _pumpFor(tester, const Duration(milliseconds: 1100));

  final selectedOption = find.text(selectedLabel).last;
  final unselectedOptions = find.text(unselectedLabel);
  expect(unselectedOptions, findsAtLeastNWidgets(1));
  final unselectedOption = unselectedOptions.last;
  expect(_menuOptionAutofocus(tester, selectedOption), isTrue);
  expect(_menuOptionAutofocus(tester, unselectedOption), isFalse);

  final menuContext = tester.element(unselectedOption);
  final resolvedSurface =
      button.dropdownColor ?? Theme.of(menuContext).canvasColor;
  expect(resolvedSurface, expectedSurface);
  expect(_dropdownMenuPainterColor(tester, unselectedOption), expectedSurface);

  expect(_renderParagraphColor(tester, selectedOption), expectedTextColor);
  expect(_renderParagraphColor(tester, unselectedOption), expectedTextColor);

  await tester.tap(unselectedOption);
  await _pumpFor(tester, const Duration(milliseconds: 350));
  expect(tester.widget<DropdownButton<T>>(dropdown).value, chosenValue);
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  await tester.pump();
  await tester.pump(duration);
  await tester.pump();
}

bool _menuOptionAutofocus(WidgetTester tester, Finder option) {
  final inkWell =
      find.ancestor(of: option, matching: find.byType(InkWell)).first;
  return tester.widget<InkWell>(inkWell).autofocus;
}

Color? _dropdownIconColor(WidgetTester tester, Finder field) {
  final iconFinder = find.descendant(
    of: field,
    matching: find.byIcon(Icons.arrow_drop_down),
  );
  final icon = tester.widget<Icon>(iconFinder);
  return icon.color ?? IconTheme.of(tester.element(iconFinder)).color;
}

Color? _renderParagraphColor(WidgetTester tester, Finder text) {
  final paragraph = tester.renderObject<RenderParagraph>(text);
  return paragraph.text.style?.color;
}

Color _dropdownMenuPainterColor(WidgetTester tester, Finder option) {
  final customPaints =
      find.ancestor(of: option, matching: find.byType(CustomPaint)).evaluate();
  for (final element in customPaints) {
    final painter = (element.widget as CustomPaint).painter;
    if (painter == null) continue;
    try {
      final color = (painter as dynamic).color;
      if (color is Color) return color;
    } on NoSuchMethodError {
      // Other CustomPaint ancestors do not expose a color field.
    }
  }
  throw TestFailure('Dropdown menu painter did not expose its surface color.');
}

class _ExerciseCatalogRepository extends AppRepository {
  _ExerciseCatalogRepository() : super(db: _ExerciseCatalogDatabaseHelper());

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}
}

class _ExerciseCatalogDatabaseHelper implements DatabaseHelper {
  static final profiles = [
    GymProfile(id: 1, name: 'Home Gym', createdAt: DateTime.utc(2026)),
    GymProfile(id: 2, name: 'Travel Gym', createdAt: DateTime.utc(2026)),
  ];

  static final _equipment = [Equipment(1, 'Barbell'), Equipment(2, 'Dumbbell')];

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    ExerciseDefinition(
      id: 1,
      name: 'Bench Press',
      equipmentList: [_equipment.first],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [
    {'id': 1, 'name': 'Barbell', 'catalog_id': null},
    {'id': 2, 'name': 'Dumbbell', 'catalog_id': null},
  ];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    BodyPart(1, 'Chest'),
    BodyPart(2, 'Legs'),
  ];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    Muscle(id: 1, name: 'Pectorals'),
    Muscle(id: 2, name: 'Biceps'),
  ];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => _equipment;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
