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
import 'package:env_test/widgets/exercise_media_thumbnail.dart';
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
      tokens.surfacePrimary,
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
    expect(find.text(strings.catalogSelectedFilters), findsOneWidget);
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
    await tester.tap(equipmentDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonSave));
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

      final theme = Theme.of(tester.element(find.byType(ExerciseCatalogPage)));
      final expressiveSurface = AppExpressiveDestinationTokens.forFamily(
        AppExpressiveDestinationFamily.catalog,
        scenario.brightness,
      ).surfaceAccent;
      final expectedPopupColor = scenario.expressive
          ? expressiveSurface
          : scenario.darkNeo
          ? theme.popupMenuTheme.color ?? theme.colorScheme.surfaceContainer
          : null;
      final profileDropdown = tester.widget<DropdownButton<int>>(
        find.byType(DropdownButton<int>),
      );
      expect(profileDropdown.dropdownColor, expectedPopupColor);
      for (final dropdown in tester.widgetList<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      )) {
        expect(dropdown.dropdownColor, expectedPopupColor);
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
    expect(media.size, 64);
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
      expect(
        filterShape.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(11),
          bottomLeft: Radius.circular(11),
          bottomRight: Radius.circular(16),
        ),
      );
      expect(filterShape.borderRadius, isNot(BorderRadius.circular(24)));

      final mediaFinder = find.byType(ExerciseMediaThumbnail).first;
      final mediaWidget = tester.widget<ExerciseMediaThumbnail>(mediaFinder);
      expect(mediaWidget.framed, isFalse);
      expect(
        mediaWidget.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(18),
        ),
      );
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
    final save = find.text(strings.commonSave);
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
    await tester.ensureVisible(find.text(strings.commonSave));
    await tester.tap(find.text(strings.commonSave));
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

  testWidgets('long catalog labels wrap at 320 dp and large text', (
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
    expect(tester.getSize(equipment).height, greaterThan(40));

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
      'Adjustable Bench, Barbell, Weight Plates',
    );
    expect(longTitleMetadata, findsOneWidget);
    expect(tester.getSize(longTitle).height, greaterThan(40));
    expect(tester.getSize(longTitleMetadata).height, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

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
      tokens.surfacePrimary,
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
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
    ExerciseDefinition(
      id: 2,
      name: 'Bench Press',
      equipmentList: [_CatalogBrowserDatabase.equipment[1]],
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
      equipmentList: [
        _CatalogBrowserDatabase.equipment[3],
        _CatalogBrowserDatabase.equipment[1],
        _CatalogBrowserDatabase.equipment[4],
      ],
      useManualBodyparts: false,
      multiplyByRating: false,
    ),
  ];
}

class _CatalogBrowserDatabase implements DatabaseHelper {
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
  Future<List<BodyPart>> fetchAllBodyParts() async => [
    BodyPart(1, 'Legs'),
    BodyPart(2, 'Chest'),
  ];

  @override
  Future<List<Muscle>> fetchAllMuscles() async => [
    Muscle(id: 1, name: 'Quadriceps'),
    Muscle(id: 2, name: 'Pectorals'),
  ];

  @override
  Future<List<Equipment>> fetchAllEquipment() async => equipment;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
