import 'dart:ui' show Tristate;

import 'package:env_test/db/database_helper.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:env_test/screens/exercise/exercise_catalog_page.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:env_test/widgets/add_exercise_fab.dart';
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
import 'package:env_test/widgets/swap_exercise_sheet.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Catalog destination scope installs Catalog-only color roles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(
        repository,
        profile,
        expressive: true,
        scale: 1,
        destinationScope: true,
      ),
    );
    await _settleCatalog(tester);

    final destinationTheme = Theme.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    );
    final tokens = destinationTheme.extension<AppExpressiveDestinationTokens>();
    expect(tokens?.family, AppExpressiveDestinationFamily.catalog);
    expect(tokens?.surfacePrimary, const Color(0xFF532471));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive browser opts into tonal dense search and rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 1),
    );
    await _settleCatalog(tester);

    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.catalog,
      Brightness.light,
    );
    final firstName = find.text('Goblet Squat');
    expect(firstName, findsOneWidget);
    expect(find.text('Cable Chest Press'), findsOneWidget);
    final resultAncestors = find.ancestor(
      of: find.byKey(const ValueKey('expressive-catalog-results')),
      matching: find.byType(Material),
    );
    for (final ancestor in resultAncestors.evaluate()) {
      final material = ancestor.widget as Material;
      if (material.color == tokens.surfaceAccent) {
        expect(tester.getSize(find.byWidget(material)).height, lessThan(400));
      }
    }
    expect(
      find.byKey(const ValueKey('expressive-catalog-results')),
      findsOneWidget,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      tokens.pageCanvas,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      tokens.pageCanvas,
    );
    final pressResponse = tester.widget<TonosExpressivePressResponse>(
      find
          .ancestor(
            of: firstName,
            matching: find.byType(TonosExpressivePressResponse),
          )
          .first,
    );
    expect(pressResponse.enabled, isTrue);
    expect(
      pressResponse.pressedScale,
      TonosExpressiveMotionTiers.supportingScale,
    );

    final filterTooltip = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    ).catalogFilters;
    expect(find.byTooltip(filterTooltip), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);

    final search = find.byType(TextField).first;
    final strings = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    );
    final searchDecoration = tester.widget<TextField>(search).decoration!;
    expect(searchDecoration.labelText, isNull);
    expect(searchDecoration.hintText, strings.catalogSearchExercises);
    final semanticsHandle = tester.ensureSemantics();
    await tester.tap(search);
    await tester.pump();
    final searchSemantics = tester
        .getSemantics(find.byType(EditableText))
        .getSemanticsData();
    expect(searchSemantics.flagsCollection.isTextField, isTrue);
    expect(searchSemantics.flagsCollection.isFocused, isNot(Tristate.none));
    expect(searchSemantics.hasAction(SemanticsAction.setText), isTrue);
    await tester.enterText(search, 'bench');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Goblet Squat'), findsNothing);
    expect(find.text('Incline Bench Press'), findsOneWidget);
    expect(find.text('Dumbbell Bench Press'), findsOneWidget);
    expect(find.text('Close-Grip Bench Press'), findsOneWidget);

    await tester.tap(find.byTooltip(filterTooltip));
    await tester.pumpAndSettle();
    final dialog = find.byKey(
      const ValueKey('expressive-catalog-filter-dialog'),
    );
    expect(dialog, findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text(strings.catalogFilters), findsOneWidget);
    expect(tester.takeException(), isNull);
    semanticsHandle.dispose();
  });

  testWidgets('Expressive filter draft cancels and saved filters apply', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 1),
    );
    await _settleCatalog(tester);
    final strings = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    );
    final filterButton = find.byTooltip(strings.catalogFilters);

    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    final profileToggle = find.byType(Switch);
    expect(tester.widget<Switch>(profileToggle).value, isTrue);
    await tester.tap(profileToggle);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();

    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    final equipmentDropdown = find
        .byType(DropdownButtonFormField<String>)
        .first;
    await tester.ensureVisible(equipmentDropdown);
    await tester.tap(equipmentDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.catalogApplyFilters));
    await tester.pumpAndSettle();

    expect(find.text('Goblet Squat'), findsNothing);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Incline Bench Press'), findsOneWidget);
    expect(find.text('Close-Grip Bench Press'), findsOneWidget);
    expect(find.text('Dumbbell Bench Press'), findsNothing);

    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    final reopenedEquipmentDropdown = find
        .byType(DropdownButtonFormField<String>)
        .first;
    await tester.ensureVisible(reopenedEquipmentDropdown);
    await tester.tap(reopenedEquipmentDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dumbbell').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();

    // Cancel discards the second draft and keeps the saved Barbell filter.
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Dumbbell Bench Press'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive Body Part and Muscle filters combine independently and Reset all is a draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: 1),
      );
      await _settleCatalog(tester);
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      );
      final filterButton = find.byTooltip(strings.catalogFilters);

      Future<void> openFilters() async {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();
      }

      await openFilters();
      expect(
        find.text(strings.catalogExpressiveFiltersCombined),
        findsOneWidget,
      );
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final areaField = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.ensureVisible(areaField);
      await tester.pumpAndSettle();
      await tester.tap(areaField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();

      final muscleField = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.ensureVisible(muscleField);
      await tester.pumpAndSettle();
      await tester.tap(muscleField);
      await tester.pumpAndSettle();
      final pectoralsOption = find.text('Pectorals').last;
      expect(pectoralsOption, findsOneWidget);
      await tester.tap(pectoralsOption);
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(find.text(strings.catalogNoFilteredMatches), findsOneWidget);
      expect(find.text('Goblet Squat'), findsNothing);
      expect(find.text('Bench Press'), findsNothing);

      await openFilters();
      await tester.tap(find.text(strings.catalogResetAllFilters));
      await tester.pumpAndSettle();
      expect(find.text(strings.catalogResetAllFilters), findsNothing);
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(find.text(strings.catalogNoFilteredMatches), findsOneWidget);

      await openFilters();
      await tester.tap(find.text(strings.catalogResetAllFilters));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(find.text('Goblet Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive search and filter changes reset results and expose state-specific recovery',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 680));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: 1.2),
      );
      await _settleCatalog(tester);

      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      );
      final results = find.byKey(const ValueKey('expressive-catalog-results'));
      final resultsScrollable = find
          .descendant(of: results, matching: find.byType(Scrollable))
          .first;
      double resultOffset() =>
          tester.state<ScrollableState>(resultsScrollable).position.pixels;
      final tokens = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.catalog,
        Brightness.light,
      );
      final filterButton = find.byTooltip(strings.catalogFilters);
      IconButton filterWidget() =>
          tester.widget<IconButton>(find.byType(IconButton));
      Color? filterBackground() =>
          filterWidget().style!.backgroundColor!.resolve({});

      expect(filterBackground(), isNot(tokens.surfaceSelected));
      await tester.scrollUntilVisible(
        find.text('Preacher Curl - Barbell (with Preacher Bench)'),
        120,
        scrollable: resultsScrollable,
      );
      await tester.pumpAndSettle();
      expect(resultOffset(), greaterThan(0));

      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      final equipmentDropdown = find
          .byType(DropdownButtonFormField<String>)
          .first;
      await tester.ensureVisible(equipmentDropdown);
      await tester.pumpAndSettle();
      await tester.tap(equipmentDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(resultOffset(), 0);
      expect(filterBackground(), tokens.surfaceSelected);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
      final activeBadge = tester.widget<Badge>(find.byType(Badge));
      expect(activeBadge.isLabelVisible, isTrue);
      expect(activeBadge.offset, const Offset(8, -8));
      expect(
        activeBadge.padding,
        const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      );
      expect(activeBadge.textStyle?.fontSize, 10);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      final search = find.byType(TextField).first;
      await tester.tap(search);
      await tester.pump();
      final searchEditable = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(searchEditable.focusNode.hasFocus, isTrue);
      await tester.enterText(search, 'no matching exercise');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text(strings.catalogClearSearch), findsOneWidget);
      expect(find.text(strings.catalogResetFilters), findsOneWidget);
      expect(find.text(strings.catalogEditFilters), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, strings.catalogResetFilters),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, strings.catalogClearSearch),
        findsOneWidget,
      );
      final editFiltersButton = find.widgetWithText(
        OutlinedButton,
        strings.catalogEditFilters,
      );
      expect(editFiltersButton, findsOneWidget);
      expect(
        tester.getSize(editFiltersButton).height,
        greaterThanOrEqualTo(48),
      );

      final editFilters = find.text(strings.catalogEditFilters);
      await tester.ensureVisible(editFilters);
      await tester.tap(editFilters);
      await tester.pumpAndSettle();
      expect(
        searchEditable.focusNode.hasFocus,
        isFalse,
        reason: 'Opening Filters should dismiss the browser search focus.',
      );
      expect(
        find.byKey(const ValueKey('expressive-catalog-filter-dialog')),
        findsOneWidget,
      );
      final preservedEquipment = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).first,
      );
      expect(preservedEquipment.initialValue, 'Barbell');
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(searchEditable.focusNode.hasFocus, isFalse);
      expect(
        tester.widget<TextField>(search).controller!.text,
        'no matching exercise',
      );

      await tester.tap(find.text(strings.catalogResetFilters));
      await tester.pumpAndSettle();
      expect(find.text(strings.catalogResetFilters), findsNothing);
      expect(find.text(strings.catalogEditFilters), findsNothing);
      expect(searchEditable.focusNode.hasFocus, isFalse);
      expect(
        find.widgetWithText(FilledButton, strings.catalogClearSearch),
        findsOneWidget,
      );

      await tester.tap(find.text(strings.catalogClearSearch));
      await tester.pumpAndSettle();
      expect(find.text('Goblet Squat'), findsOneWidget);
      expect(filterBackground(), isNot(tokens.surfaceSelected));

      await tester.scrollUntilVisible(
        find.text('Preacher Curl - Barbell (with Preacher Bench)'),
        120,
        scrollable: resultsScrollable,
      );
      await tester.pumpAndSettle();
      expect(resultOffset(), greaterThan(0));
      await tester.enterText(search, 'bench');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(resultOffset(), 0);
      expect(find.text('Bench Press'), findsOneWidget);
      final firstResult = find
          .ancestor(
            of: find.text('Bench Press'),
            matching: find.byType(TonosExpressivePressResponse),
          )
          .first;
      expect(
        tester.getRect(firstResult).top,
        greaterThanOrEqualTo(tester.getRect(results).top),
      );
      expect(
        tester.getRect(firstResult).bottom,
        lessThanOrEqualTo(tester.getRect(results).bottom),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expressive filter badge keeps one and three filter counts legible',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: 1),
      );
      await _settleCatalog(tester);
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      );
      final filterButton = find.byTooltip(strings.catalogFilters);

      Future<void> openFilters() async {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();
      }

      await openFilters();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('1')),
        findsOneWidget,
      );

      await openFilters();
      final equipmentField = find.byType(DropdownButtonFormField<String>).first;
      await tester.ensureVisible(equipmentField);
      await tester.tap(equipmentField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell').last);
      await tester.pumpAndSettle();
      final bodyPartField = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.ensureVisible(bodyPartField);
      await tester.tap(bodyPartField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legs').last);
      await tester.pumpAndSettle();
      final muscleField = find.byType(DropdownButtonFormField<String>).at(2);
      await tester.ensureVisible(muscleField);
      await tester.tap(muscleField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pectorals').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('4')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(tester.takeException(), isNull);

      await openFilters();
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('4')),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('3')),
        findsOneWidget,
      );

      await openFilters();
      await tester.tap(find.text(strings.catalogResetAllFilters));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.catalogApplyFilters));
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    },
  );

  testWidgets('filter dropdown popups use the correct family surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cases =
        <
          ({
            ThemeData theme,
            Brightness brightness,
            bool expressive,
            bool darkNeo,
          })
        >[
          (
            theme: ExpressiveThemeDefinition.light(),
            brightness: Brightness.light,
            expressive: true,
            darkNeo: false,
          ),
          (
            theme: ExpressiveThemeDefinition.dark(),
            brightness: Brightness.dark,
            expressive: true,
            darkNeo: false,
          ),
          (
            theme: ClassicThemeDefinition.light(),
            brightness: Brightness.light,
            expressive: false,
            darkNeo: false,
          ),
          (
            theme: NeoBrutalismThemeDefinition.light(),
            brightness: Brightness.light,
            expressive: false,
            darkNeo: false,
          ),
          (
            theme: NeoBrutalismThemeDefinition.dark(),
            brightness: Brightness.dark,
            expressive: false,
            darkNeo: true,
          ),
        ];

    for (final scenario in cases) {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(
          repository,
          profile,
          expressive: true,
          scale: 1,
          brightness: scenario.brightness,
          themeOverride: scenario.theme,
        ),
      );
      await _settleCatalog(tester);
      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      );
      final filterTooltip = find.byTooltip(strings.catalogFilters);
      await tester.tap(
        filterTooltip.evaluate().isNotEmpty
            ? filterTooltip
            : find.text(strings.catalogFilters),
      );
      await tester.pumpAndSettle();

      final filterFields = tester
          .widgetList<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .toList();
      expect(
        filterFields[1].decoration.labelText,
        scenario.expressive ? isNull : strings.catalogFocusArea,
      );
      expect(
        filterFields[2].decoration.labelText,
        scenario.expressive ? isNull : strings.catalogSpecificMuscle,
      );
      expect(
        find.text(
          scenario.expressive
              ? strings.catalogBodyPartFilter
              : strings.catalogFocusArea,
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          scenario.expressive
              ? strings.catalogMuscleFilter
              : strings.catalogSpecificMuscle,
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          scenario.expressive
              ? strings.catalogFilters
              : strings.catalogSelectedFilters,
        ),
        findsOneWidget,
      );

      final theme = Theme.of(tester.element(find.byType(ExerciseCatalogPage)));
      final expressiveSurface = theme.colorScheme.surfaceContainerHigh;
      final expectedPopupColor = scenario.expressive
          ? expressiveSurface
          : scenario.darkNeo
          ? theme.popupMenuTheme.color ?? theme.colorScheme.surfaceContainer
          : null;
      final profileDropdown = tester.widget<DropdownButton<int>>(
        find.byType(DropdownButton<int>),
      );
      const expressiveMenuMaxHeight = 280.0;
      expect(profileDropdown.dropdownColor, expectedPopupColor);
      expect(
        profileDropdown.menuMaxHeight,
        scenario.expressive ? closeTo(expressiveMenuMaxHeight, 0.1) : isNull,
      );
      expect(
        profileDropdown.borderRadius,
        scenario.expressive ? BorderRadius.circular(20) : isNull,
      );
      for (final dropdown in tester.widgetList<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      )) {
        expect(dropdown.dropdownColor, expectedPopupColor);
        expect(
          dropdown.menuMaxHeight,
          scenario.expressive ? closeTo(expressiveMenuMaxHeight, 0.1) : isNull,
        );
        expect(
          dropdown.borderRadius,
          scenario.expressive ? BorderRadius.circular(20) : isNull,
        );
      }

      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Expressive media fallback stays neutral and contained', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 1),
    );
    await _settleCatalog(tester);

    final media = tester.widget<ExerciseMediaThumbnail>(
      find.byType(ExerciseMediaThumbnail).first,
    );
    expect(media.size, 60);
    expect(media.framed, isFalse);
    expect(media.heatmapSurface, isNull);
    final pageContext = tester.element(find.byType(ExerciseCatalogPage));
    final expectedMediaSurface = pageContext.surfaceTokens.mediaPlaceholder;
    final mediaWells = find
        .ancestor(
          of: find.byType(ExerciseMediaThumbnail).first,
          matching: find.byType(Material),
        )
        .evaluate()
        .map((element) => element.widget as Material)
        .where((material) => material.color == expectedMediaSurface)
        .toList();
    expect(mediaWells, hasLength(1));
    expect(
      (mediaWells.single.shape as RoundedRectangleBorder).borderRadius,
      media.borderRadius,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Expressive filter and media controls retain shape and semantics',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: 1),
      );
      await _settleCatalog(tester);

      final strings = AppLocalizations.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      );
      final filterButton = find.byType(IconButton);
      expect(find.byTooltip(strings.catalogFilters), findsOneWidget);
      final iconButton = tester.widget<IconButton>(filterButton);
      expect(tester.getSize(filterButton), const Size(48, 48));
      final filterShape =
          iconButton.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(filterShape.borderRadius, BorderRadius.circular(14));
      expect(filterShape.borderRadius, isNot(BorderRadius.circular(24)));

      final mediaFinder = find.byType(ExerciseMediaThumbnail).first;
      final mediaWidget = tester.widget<ExerciseMediaThumbnail>(mediaFinder);
      expect(mediaWidget.framed, isFalse);
      expect(mediaWidget.borderRadius, BorderRadius.circular(12));
      final expectedMediaSurface = Theme.of(
        tester.element(find.byType(ExerciseCatalogPage)),
      ).surfaceTokens.mediaPlaceholder;
      final mediaSurface = find
          .ancestor(of: mediaFinder, matching: find.byType(Material))
          .evaluate()
          .map((element) => element.widget as Material)
          .where((material) => material.color == expectedMediaSurface)
          .toList();
      expect(mediaSurface, hasLength(1));
      expect(
        (mediaSurface.single.shape as RoundedRectangleBorder).borderRadius,
        mediaWidget.borderRadius,
      );

      final semanticsHandle = tester.ensureSemantics();
      try {
        final infoLabel = strings.catalogOpenExerciseInfo;
        final infoSemantics = tester
            .getSemantics(mediaFinder)
            .getSemanticsData();
        expect(infoSemantics.label, contains(infoLabel));
        expect(infoSemantics.flagsCollection.isButton, isTrue);
        expect(infoSemantics.hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semanticsHandle.dispose();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive filters remain reachable at 320 dp and 2x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 2),
    );
    await _settleCatalog(tester);
    final strings = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    );
    final filterButton = find.byTooltip(strings.catalogFilters);

    Future<void> openFilters() async {
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('expressive-catalog-filter-dialog')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    await openFilters();
    final cancel = find.text(strings.commonCancel);
    final save = find.text(strings.catalogApplyFilters);
    await tester.ensureVisible(cancel);
    await tester.ensureVisible(save);
    for (final action in [cancel, save]) {
      final rect = tester.getRect(action);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(780));
    }
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('expressive-catalog-filter-dialog')),
      findsNothing,
    );

    await openFilters();
    await tester.ensureVisible(find.text(strings.catalogApplyFilters));
    await tester.tap(find.text(strings.catalogApplyFilters));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('expressive-catalog-filter-dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expressive long filter labels wrap instead of truncating', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: true, scale: 2),
    );
    await _settleCatalog(tester);
    final strings = AppLocalizations.of(
      tester.element(find.byType(ExerciseCatalogPage)),
    );
    await tester.tap(find.byTooltip(strings.catalogFilters));
    await tester.pumpAndSettle();

    final equipmentDropdown = find
        .byType(DropdownButtonFormField<String>)
        .first;
    await tester.ensureVisible(equipmentDropdown);
    await tester.tap(equipmentDropdown);
    await tester.pumpAndSettle();
    final longEquipment = find.text('High-Pulley Cable Machine');
    expect(longEquipment, findsOneWidget);
    final dropdownScrollables = find.byType(Scrollable);
    final dropdownViewport = tester.getRect(dropdownScrollables.last);
    expect(dropdownViewport.height, lessThanOrEqualTo(440));
    expect(dropdownViewport.top, greaterThanOrEqualTo(0));
    expect(dropdownViewport.bottom, lessThanOrEqualTo(780));
    final popupLabel = tester.widget<Text>(longEquipment);
    expect(popupLabel.maxLines, isNull);
    expect(popupLabel.overflow, isNull);
    expect(tester.getSize(longEquipment).height, greaterThan(40));

    await tester.tap(longEquipment);
    await tester.pumpAndSettle();
    final selectedLabel = find.text('High-Pulley Cable Machine');
    expect(selectedLabel, findsOneWidget);
    final selectedText = tester.widget<Text>(selectedLabel);
    expect(selectedText.maxLines, isNull);
    expect(selectedText.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long catalog titles wrap and equipment stays accessible at 320 dp',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: 2),
      );
      await _settleCatalog(tester);
      final results = find.byKey(const ValueKey('expressive-catalog-results'));
      final resultsScrollable = find.descendant(
        of: results,
        matching: find.byType(Scrollable),
      );
      expect(resultsScrollable, findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Cable Chest Press'),
        240,
        scrollable: resultsScrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text('Cable Chest Press'), findsOneWidget);
      final equipment = find.text('High-Pulley Cable Machine');
      expect(equipment, findsOneWidget);
      final equipmentText = tester.widget<Text>(equipment);
      expect(equipmentText.maxLines, 1);
      expect(equipmentText.overflow, TextOverflow.ellipsis);
      expect(find.byTooltip('High-Pulley Cable Machine'), findsOneWidget);

      final longTitle = find.text(
        'Preacher Curl - Barbell (with Preacher Bench)',
      );
      await tester.scrollUntilVisible(
        longTitle,
        240,
        scrollable: resultsScrollable,
      );
      await tester.pumpAndSettle();
      expect(longTitle, findsOneWidget);
      final longTitleMetadata = find.text(
        'Barbell, Adjustable Bench, Weight Plates',
      );
      expect(longTitleMetadata, findsOneWidget);
      expect(tester.getSize(longTitle).height, greaterThan(40));
      final metadataText = tester.widget<Text>(longTitleMetadata);
      expect(metadataText.maxLines, 1);
      expect(metadataText.overflow, TextOverflow.ellipsis);
      expect(
        find.byTooltip('Barbell, Adjustable Bench, Weight Plates'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Classic and Neo keep their current browser presentation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final theme in <ThemeData>[
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.light(),
    ]) {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(
          repository,
          profile,
          expressive: true,
          scale: 1,
          themeOverride: theme,
        ),
      );
      await _settleCatalog(tester);
      expect(
        find.byKey(const ValueKey('expressive-catalog-results')),
        findsNothing,
      );
      expect(find.byType(TonosExpressivePressResponse), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  for (final scale in <double>[1, 1.15, 1.5, 2]) {
    testWidgets('Expressive browser stays within 320 dp at text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        _catalogApp(repository, profile, expressive: true, scale: scale),
      );
      await _settleCatalog(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.byTooltip(
          AppLocalizations.of(tester.element(find.byType(ExerciseCatalogPage)))
              .catalogFilters,
        ),
        findsOneWidget,
      );
      expect(find.text('Goblet Squat'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Expressive picker selection uses destination selected pair', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(
        repository,
        profile,
        expressive: true,
        scale: 1,
        picker: true,
      ),
    );
    await _settleCatalog(tester);
    await tester.tap(find.text('Goblet Squat'));
    await tester.pump();

    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.catalog,
      Brightness.light,
    );
    final selectedRow = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Goblet Squat'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(selectedRow.color, tokens.surfaceSelected);
    expect(
      find.byTooltip(
        AppLocalizations.of(tester.element(find.byType(ExerciseCatalogPage)))
            .commonAdd,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Expressive workout AddExerciseFab defaults to approved Catalog and returns selection (${brightness.name})',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
        });
        final repository = _CatalogBrowserRepository();
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = _CatalogBrowserDatabase.profiles.first;
        addTearDown(profile.dispose);
        ExerciseDefinition? picked;
        var closedCount = 0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                floatingActionButton: AddExerciseFab(
                  onWeightPicked: (definition) async {
                    picked = definition;
                  },
                  onCatalogClosed: () => closedCount++,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(AddExerciseFab));
        await _settleCatalog(tester);
        final catalog = find.byType(ExerciseCatalogPage);
        expect(catalog, findsOneWidget);
        expect(
          find.byKey(const ValueKey('expressive-catalog-search-panel')),
          findsOneWidget,
        );
        expect(
          Theme.of(tester.element(catalog))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.catalog,
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pump(const Duration(milliseconds: 300));
        final catalogAdd = find.descendant(
          of: catalog,
          matching: find.byType(FloatingActionButton),
        );
        expect(catalogAdd, findsOneWidget);
        await tester.pumpAndSettle();
        // The nested Catalog scaffold's FAB is positioned under the host
        // route's reserved system inset in this widget harness. Invoke the
        // rendered button callback after the exercise-row tap to verify the
        // actual selection/return contract; device coverage checks hit input.
        tester.widget<FloatingActionButton>(catalogAdd).onPressed!.call();
        await tester.pumpAndSettle();

        expect(picked?.id, 2);
        expect(closedCount, 1);
        expect(find.byType(ExerciseCatalogPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive workout AddExerciseFab cancellation does not select an exercise (${brightness.name})',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
        });
        final repository = _CatalogBrowserRepository();
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = _CatalogBrowserDatabase.profiles.first;
        addTearDown(profile.dispose);
        ExerciseDefinition? picked;
        var closedCount = 0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                floatingActionButton: AddExerciseFab(
                  expressiveWorkoutPresentation: true,
                  onWeightPicked: (definition) async {
                    picked = definition;
                  },
                  onCatalogClosed: () => closedCount++,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(AddExerciseFab));
        await _settleCatalog(tester);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(picked, isNull);
        expect(closedCount, 1);
        expect(find.byType(ExerciseCatalogPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive Preset Detail swap picker returns selection only on confirm (${brightness.name})',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.exercise_catalog_v1': true,
        });
        final repository = _CatalogBrowserRepository();
        final profile = SelectedProfile(repository: repository)
          ..currentProfile = _CatalogBrowserDatabase.profiles.first;
        addTearDown(profile.dispose);
        final currentDefinition = (await repository.lookupDefsDetailed()).first;
        ExerciseDefinition? replacement;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () async {
                        replacement = await Navigator.of(context)
                            .push<ExerciseDefinition>(
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  body: SwapExerciseSheet(
                                    repository: repository,
                                    currentDefinition: currentDefinition,
                                  ),
                                ),
                              ),
                            );
                      },
                      child: const Text('Open swap picker'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open swap picker'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        final strings = AppLocalizations.of(
          tester.element(find.byType(SwapExerciseSheet)),
        );
        await tester.tap(find.text(strings.swapBrowseCatalog));
        await _settleCatalog(tester);
        final catalog = find.byType(ExerciseCatalogPage);
        expect(catalog, findsOneWidget);
        expect(
          Theme.of(tester.element(catalog))
              .extension<AppExpressiveDestinationTokens>()
              ?.family,
          AppExpressiveDestinationFamily.catalog,
        );

        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        final catalogAdd = find.descendant(
          of: catalog,
          matching: find.byType(FloatingActionButton),
        );
        expect(catalogAdd, findsOneWidget);
        tester.widget<FloatingActionButton>(catalogAdd).onPressed!.call();
        await tester.pumpAndSettle();
        expect(replacement, isNull);

        await tester.tap(find.text(strings.swapConfirm));
        await tester.pumpAndSettle();
        expect(replacement?.id, 2);
        expect(find.byType(SwapExerciseSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Expressive swap picker cancellation does not return a replacement',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.exercise_catalog_v1': true,
      });
      final repository = _CatalogBrowserRepository();
      final profile = SelectedProfile(repository: repository)
        ..currentProfile = _CatalogBrowserDatabase.profiles.first;
      addTearDown(profile.dispose);
      final currentDefinition = (await repository.lookupDefsDetailed()).first;
      ExerciseDefinition? replacement;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<SelectedProfile>.value(value: profile),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      replacement = await Navigator.of(context)
                          .push<ExerciseDefinition>(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                body: SwapExerciseSheet(
                                  repository: repository,
                                  currentDefinition: currentDefinition,
                                ),
                              ),
                            ),
                          );
                    },
                    child: const Text('Open swap picker'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open swap picker'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      final strings = AppLocalizations.of(
        tester.element(find.byType(SwapExerciseSheet)),
      );
      await tester.tap(find.text(strings.swapBrowseCatalog));
      await _settleCatalog(tester);
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      final catalogAdd = find.descendant(
        of: find.byType(ExerciseCatalogPage),
        matching: find.byType(FloatingActionButton),
      );
      expect(catalogAdd, findsOneWidget);
      tester.widget<FloatingActionButton>(catalogAdd).onPressed!.call();
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.commonCancel));
      await tester.pumpAndSettle();

      expect(replacement, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Expressive browser uses chromatic blue slate surfaces in dark', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(
        repository,
        profile,
        expressive: true,
        scale: 1,
        brightness: Brightness.dark,
        destinationScope: true,
      ),
    );
    await _settleCatalog(tester);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.catalog,
      Brightness.dark,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      tokens.pageCanvas,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      tokens.pageCanvas,
    );
    expect(tokens.pageCanvas, isNot(const Color(0xFF000000)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker callers remain on the existing presentation by default', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'guided_tutorial_completed.exercise_catalog_v1': true,
    });
    final repository = _CatalogBrowserRepository();
    final profile = SelectedProfile(repository: repository)
      ..currentProfile = _CatalogBrowserDatabase.profiles.first;
    addTearDown(profile.dispose);

    await tester.pumpWidget(
      _catalogApp(repository, profile, expressive: false, scale: 1),
    );
    await _settleCatalog(tester);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TonosExpressivePressResponse), findsNothing);
    expect(
      find.byTooltip(
        AppLocalizations.of(tester.element(find.byType(ExerciseCatalogPage)))
            .catalogFilters,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _catalogApp(
  AppRepository repository,
  SelectedProfile profile, {
  required bool expressive,
  required double scale,
  Brightness brightness = Brightness.light,
  bool picker = false,
  bool destinationScope = false,
  ThemeData? themeOverride,
}) {
  final theme = brightness == Brightness.light
      ? ExpressiveThemeDefinition.light()
      : ExpressiveThemeDefinition.dark();
  return MultiProvider(
    providers: [
      Provider<AppRepository>.value(value: repository),
      ChangeNotifierProvider<SelectedProfile>.value(value: profile),
    ],
    child: MaterialApp(
      theme: themeOverride ?? theme,
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: tonosLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: destinationScope
          ? AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.catalog,
              child: ExerciseCatalogPage(
                onExercisePicked: picker ? (_) {} : null,
                expressiveCatalogPresentation: expressive,
              ),
            )
          : ExerciseCatalogPage(
              onExercisePicked: picker ? (_) {} : null,
              expressiveCatalogPresentation: expressive,
            ),
    ),
  );
}

Future<void> _settleCatalog(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

class _CatalogBrowserRepository extends AppRepository {
  _CatalogBrowserRepository() : super(db: _CatalogBrowserDatabase());

  @override
  Future<String?> getAppState(String key) async => '1';

  @override
  Future<void> setAppState(String key, String? value) async {}

  @override
  Future<void> ensureExerciseMediaManifestReady() async {}

  @override
  Future<ExerciseMediaItem?> fetchPrimaryExerciseMedia(int defId) async => null;

  @override
  Stream<ContentMediaCacheChange> get mediaCacheChanges =>
      const Stream<ContentMediaCacheChange>.empty();

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailed() async => [
    ExerciseDefinition(
      id: 1,
      name: 'Goblet Squat',
      equipmentList: [_CatalogBrowserDatabase.equipment.first],
      bodyParts: [_CatalogBrowserDatabase.bodyPart],
      muscles: [RankedMuscle(muscle: _CatalogBrowserDatabase.muscle, rank: 1)],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[1]],
      bodyParts: [_CatalogBrowserDatabase.chest],
      muscles: [
        RankedMuscle(muscle: _CatalogBrowserDatabase.pectorals, rank: 1),
      ],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 3,
      name: 'Incline Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[1]],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 4,
      name: 'Dumbbell Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[0]],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 5,
      name: 'Close-Grip Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[1]],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 6,
      name: 'Cable Chest Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[2]],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 7,
      name: 'Preacher Curl - Barbell (with Preacher Bench)',
      equipmentId: _CatalogBrowserDatabase.equipment[1].id,
      equipmentList: [
        _CatalogBrowserDatabase.equipment[3],
        _CatalogBrowserDatabase.equipment[1],
        _CatalogBrowserDatabase.equipment[4],
      ],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];

  @override
  Future<List<ExerciseDefinition>> lookupDefsFiltered({
    List<String>? equipmentNames,
    List<int>? bodypartIds,
    List<int>? muscleIds,
  }) async => lookupDefsDetailed();

  @override
  Future<List<ExerciseDefinition>> lookupDefsDetailedByIds(
    List<int> definitionIds,
  ) async => (await lookupDefsDetailed())
      .where((definition) => definitionIds.contains(definition.id))
      .toList();

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int defId) async {
    for (final definition in await lookupDefsDetailed()) {
      if (definition.id == defId) return definition;
    }
    return null;
  }

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async => {
    _CatalogBrowserDatabase.bodyPart: 1,
  };

  @override
  Future<List<ExerciseMusclePercent>> computeMusclePercents(int defId) async =>
      [
        ExerciseMusclePercent(
          exerciseDefId: defId,
          muscleId: _CatalogBrowserDatabase.muscle.id,
          percent: 1,
        ),
      ];
}

class _CatalogBrowserDatabase implements DatabaseHelper {
  static final bodyPart = BodyPart(1, 'Legs');
  static final muscle = Muscle(id: 1, name: 'Quadriceps');
  static final chest = BodyPart(2, 'Chest');
  static final pectorals = Muscle(id: 2, name: 'Pectorals');
  static final profiles = [
    GymProfile(id: 1, name: 'Home Gym', createdAt: DateTime.utc(2026)),
  ];
  static final equipment = [
    Equipment(1, 'Dumbbell'),
    Equipment(2, 'Barbell'),
    Equipment(3, 'High-Pulley Cable Machine'),
    Equipment(4, 'Adjustable Bench'),
    Equipment(5, 'Weight Plates'),
  ];

  @override
  Future<List<GymProfile>> fetchAllProfiles() async => profiles;

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [
    {'id': 1, 'name': 'Dumbbell', 'catalog_id': null},
    {'id': 2, 'name': 'Barbell', 'catalog_id': null},
    {'id': 3, 'name': 'High-Pulley Cable Machine', 'catalog_id': null},
    {'id': 4, 'name': 'Adjustable Bench', 'catalog_id': null},
    {'id': 5, 'name': 'Weight Plates', 'catalog_id': null},
  ];

  @override
  Future<List<BodyPart>> fetchAllBodyParts() async => [bodyPart, chest];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [muscle, pectorals];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => equipment;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
