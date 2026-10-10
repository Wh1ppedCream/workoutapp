import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/nav_bar_settings_page.dart';
import 'package:env_test/screens/profile/settings/user_information_settings_page.dart';
import 'package:env_test/screens/profile/settings/profile_expressive_selection.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'Profile navigation colors and change-only save stay legible in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = NavBarConfig(
          buildPolicy: const NavigationBuildPolicy(
            experimentalTabsEnabled: false,
            isReleaseMode: false,
          ),
        );
        addTearDown(config.dispose);

        await tester.pumpWidget(
          ChangeNotifierProvider<NavBarConfig>.value(
            value: config,
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const NavBarSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final tokens = Theme.of(tester.element(find.byType(TonosSurface).first))
            .extension<AppExpressiveDestinationTokens>()!;
        final activeTile = find.ancestor(
          of: find.text('Train'),
          matching: find.byType(TonosSurface),
        );
        expect(
          tester.widget<TonosSurface>(activeTile.first).color,
          Color.lerp(tokens.surfaceSelected, tokens.pageCanvas, 0.34),
        );
        final activeBadge = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.fitness_center),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((activeBadge.child as Icon).color, tokens.onSurfaceSelected);

        final activeTrainTile = find.ancestor(
          of: find.text('Train'),
          matching: find.byType(ListTile),
        );
        final activeSwitchFinder = find.descendant(
          of: activeTrainTile.first,
          matching: find.byType(Switch),
        );
        final activeSwitch = tester.widget<Switch>(activeSwitchFinder.first);
        expect(activeSwitch.value, isTrue);
        expect(activeSwitch.onChanged, isNotNull);
        final activeSwitchTheme = Theme.of(
          tester.element(activeSwitchFinder.first),
        ).switchTheme;
        expect(
          activeSwitchTheme.thumbColor?.resolve({WidgetState.selected}),
          tokens.actionPrimary,
        );
        expect(
          activeSwitchTheme.trackColor?.resolve({WidgetState.selected}),
          tokens.surfaceSelected,
        );

        final inactiveHeading = tester.widget<Text>(find.text('Inactive Tabs'));
        expect(
          inactiveHeading.style?.color,
          Color.lerp(
            const Color(0xFF9E9E9E),
            tokens.supportingForeground,
            0.42,
          ),
        );

        final inactiveTrainTile = find.ancestor(
          of: find.text('Train2'),
          matching: find.byType(ListTile),
        );
        final inactiveSwitchFinder = find.descendant(
          of: inactiveTrainTile.first,
          matching: find.byType(Switch),
        );
        final inactiveSwitch = tester.widget<Switch>(
          inactiveSwitchFinder.first,
        );
        expect(inactiveSwitch.value, isFalse);
        expect(inactiveSwitch.onChanged, isNotNull);
        final inactiveSwitchTheme = Theme.of(
          tester.element(inactiveSwitchFinder.first),
        ).switchTheme;
        expect(
          inactiveSwitchTheme.thumbColor?.resolve(const <WidgetState>{}),
          Theme.of(tester.element(inactiveSwitchFinder.first))
              .colorScheme
              .onSurfaceVariant,
        );

        final lockedProfileTile = find.ancestor(
          of: find.text('Profile'),
          matching: find.byType(ListTile),
        );
        final requiredIndicator = find.descendant(
          of: lockedProfileTile.first,
          matching: find.text('Required'),
        );
        expect(requiredIndicator, findsOneWidget);
        expect(
          find.descendant(
            of: lockedProfileTile.first,
            matching: find.byIcon(Icons.lock_outline),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: lockedProfileTile.first,
            matching: find.byType(Switch),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: lockedProfileTile.first,
            matching: find.byIcon(Icons.drag_indicator),
          ),
          findsOneWidget,
        );
        expect(config.enabledTabs.contains(TabItem.profile), isTrue);
        final semantics = tester.ensureSemantics();
        try {
          expect(find.bySemanticsLabel('Required'), findsOneWidget);
        } finally {
          semantics.dispose();
        }
        await tester.tap(requiredIndicator);
        await tester.pump();
        expect(config.enabledTabs.contains(TabItem.profile), isTrue);
        expect(requiredIndicator, findsOneWidget);
        expect(find.byIcon(Icons.drag_indicator), findsNWidgets(5));
        final dragHandle = find.byType(ReorderableDragStartListener).first;
        expect(tester.getSize(dragHandle), const Size(68, 48));

        final save = find.byKey(AppTestKeys.navigationSave);
        expect(save, findsNothing);
        await tester.ensureVisible(activeSwitchFinder.first);
        await tester.tap(activeSwitchFinder.first);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        final saveButton = tester.widget<FloatingActionButton>(save);
        expect(saveButton.onPressed, isNotNull);
        expect(saveButton.backgroundColor, tokens.actionPrimary);
        expect(saveButton.foregroundColor, tokens.onActionPrimary);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(save, findsNothing);
        expect(config.enabledTabs.contains(TabItem.train), isFalse);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive Navigation Editor keeps rows and change-only Save reachable at 2x text in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = NavBarConfig(
          buildPolicy: const NavigationBuildPolicy(
            experimentalTabsEnabled: false,
            isReleaseMode: false,
          ),
        );
        addTearDown(config.dispose);

        await tester.pumpWidget(
          ChangeNotifierProvider<NavBarConfig>.value(
            value: config,
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const NavBarSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final trainTile = find.ancestor(
          of: find.text('Train'),
          matching: find.byType(ListTile),
        );
        await tester.scrollUntilVisible(
          trainTile.first,
          240,
          scrollable: find
              .descendant(
                of: find.byType(NavBarSettingsPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(trainTile.first);
        await tester.pumpAndSettle();
        final trainTitle = find.descendant(
          of: trainTile.first,
          matching: find.text('Train'),
        );
        final trainSwitch = find.descendant(
          of: trainTile.first,
          matching: find.byType(Switch),
        );
        expect(
          tester.getRect(trainTitle).overlaps(tester.getRect(trainSwitch)),
          isFalse,
        );

        final save = find.byKey(AppTestKeys.navigationSave);
        expect(save, findsNothing);
        await tester.tap(trainSwitch.first);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    for (final themeCase in <(String, ThemeData)>[
      ('Classic', ClassicThemeDefinition.light()),
      ('Neo', NeoBrutalismThemeDefinition.light()),
    ]) {
      testWidgets(
        '${themeCase.$1} navigation switch and drag affordance stay unchanged',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 1800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final config = NavBarConfig(
            buildPolicy: const NavigationBuildPolicy(
              experimentalTabsEnabled: false,
              isReleaseMode: false,
            ),
          );
          addTearDown(config.dispose);

          await tester.pumpWidget(
            ChangeNotifierProvider<NavBarConfig>.value(
              value: config,
              child: MaterialApp(
                theme: themeCase.$2,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const NavBarSettingsPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final trainListTile = find.ancestor(
            of: find.text('Train'),
            matching: find.byType(ListTile),
          );
          final trainSwitchFinder = find.descendant(
            of: trainListTile.first,
            matching: find.byType(Switch),
          );
          final trainSwitch = tester.widget<Switch>(trainSwitchFinder.first);
          expect(trainSwitch.value, isTrue);
          expect(trainSwitch.onChanged, isNotNull);
          final switchTheme = Theme.of(tester.element(trainSwitchFinder.first))
              .switchTheme;
          expect(switchTheme.thumbColor, themeCase.$2.switchTheme.thumbColor);
          expect(switchTheme.trackColor, themeCase.$2.switchTheme.trackColor);

          expect(
            tester.widget<ListTile>(trainListTile.first).contentPadding,
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          );
          expect(find.byIcon(Icons.drag_indicator), findsNothing);
          expect(find.byIcon(Icons.drag_handle), findsNWidgets(5));

          final profileListTile = find.ancestor(
            of: find.text('Profile'),
            matching: find.byType(ListTile),
          );
          final profileSwitchFinder = find.descendant(
            of: profileListTile.first,
            matching: find.byType(Switch),
          );
          expect(
            tester.widget<Switch>(profileSwitchFinder.first).onChanged,
            isNull,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'Expressive Navigation Editor reorders through an unclipped overlay proxy in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final config = NavBarConfig(
          buildPolicy: const NavigationBuildPolicy(
            experimentalTabsEnabled: false,
            isReleaseMode: false,
          ),
        );
        addTearDown(config.dispose);

        await tester.pumpWidget(
          ChangeNotifierProvider<NavBarConfig>.value(
            value: config,
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const NavBarSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final catalogRow = find
            .ancestor(of: find.text('Catalog'), matching: find.byType(ListTile))
            .first;
        final catalogHandle = find.descendant(
          of: catalogRow,
          matching: find.byType(ReorderableDragStartListener),
        );
        expect(catalogHandle, findsOneWidget);

        final drag = await tester.startGesture(tester.getCenter(catalogHandle));
        await tester.pump(const Duration(milliseconds: 50));
        for (var step = 0; step < 8; step++) {
          await drag.moveBy(const Offset(0, -20));
          await tester.pump(const Duration(milliseconds: 20));
        }

        final overlay = find.byType(Overlay).first;
        final draggedProxy = find.descendant(
          of: overlay,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.color == Colors.transparent &&
                widget.child is ScaleTransition,
          ),
        );
        expect(draggedProxy, findsOneWidget);
        expect(
          find.ancestor(
            of: draggedProxy,
            matching: find.byType(SettingsSection),
          ),
          findsNothing,
          reason: 'The drag avatar is rendered in Overlay, outside the clipped section.',
        );
        expect(tester.takeException(), isNull);

        await drag.up();
        await tester.pumpAndSettle();

        final trainRow = find
            .ancestor(of: find.text('Train'), matching: find.byType(ListTile))
            .first;
        final reorderedCatalogRow = find
            .ancestor(of: find.text('Catalog'), matching: find.byType(ListTile))
            .first;
        expect(
          tester.getRect(reorderedCatalogRow).top,
          lessThan(tester.getRect(trainRow).top),
        );
        final save = find.byKey(AppTestKeys.navigationSave);
        expect(save.hitTestable(), findsOneWidget);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(config.order.first, TabItem.catalog);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive user information keeps tonal form and save behavior in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = _FakeAppRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
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
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: const UserInformationSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(UserInformationSettingsPage),
        );
        final tokens = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.profile,
          brightness,
        );
        final strings = AppLocalizations.of(pageContext);
        final identitySubtitle = find.text(strings.userInfoIdentitySubtitle);
        final subtitleContext = tester.element(identitySubtitle);
        expect(
          Theme.of(subtitleContext).scaffoldBackgroundColor,
          tokens.pageCanvas,
        );
        expect(
          tester.widget<Text>(identitySubtitle).style?.color,
          tokens.supportingForeground,
        );

        final nameField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(AppTestKeys.userInformationName),
            matching: find.byType(TextField),
          ),
        );
        final decoration = nameField.decoration!;
        expect(decoration.filled, isTrue);
        expect(
          decoration.fillColor,
          Color.lerp(tokens.surfaceSelected, tokens.onSurfaceSelected, 0.12),
          reason: 'Resting field fill follows the quieter approved 0.12 mix.',
        );
        expect(decoration.fillColor, isNot(tokens.surfaceTertiary));
        expect(nameField.style?.color, tokens.onSurfaceSelected);
        expect(decoration.border, isA<OutlineInputBorder>());
        expect(
          (decoration.border! as OutlineInputBorder).borderSide.style,
          BorderStyle.none,
        );
        final nameInputDecorator = find.descendant(
          of: find.byKey(AppTestKeys.userInformationName),
          matching: find.byType(InputDecorator),
        );
        final cleanScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(cleanScaffold.bottomNavigationBar, isNull);
        expect(cleanScaffold.floatingActionButton, isNull);
        expect(find.byKey(AppTestKeys.userInformationSave), findsNothing);
        await tester.tap(find.byKey(AppTestKeys.userInformationName));
        await tester.pump();
        expect(
          tester.widget<InputDecorator>(nameInputDecorator.first).isFocused,
          isTrue,
        );
        expect(
          find.byKey(AppTestKeys.userInformationSave),
          findsNothing,
          reason: 'Focusing a text field without editing must not mark the '
              'form dirty or reveal the Save changes action.',
        );
        expect(
          (decoration.focusedBorder! as OutlineInputBorder).borderSide.width,
          2,
        );
        final errorBorder = decoration.errorBorder! as OutlineInputBorder;
        final focusedErrorBorder =
            decoration.focusedErrorBorder! as OutlineInputBorder;
        expect(errorBorder.borderRadius, ExpressiveTrainShapes.compactControl);
        expect(errorBorder.borderSide.style, BorderStyle.solid);
        expect(
          errorBorder.borderSide.color,
          tonosSettingsValidationErrorForSurface(
            pageContext,
            decoration.fillColor!,
          ),
        );
        expect(
          focusedErrorBorder.borderSide.width,
          Theme.of(pageContext).shapeTokens.focusRingWidth,
        );
        final genderFinder = _userInformationDropdownForLabel(
          strings.userInfoGender,
        );
        final genderField = tester
            .widget<ProfileExpressiveChoiceField<String?>>(genderFinder);
        final genderInkWell = tester.widget<InkWell>(
          find
              .descendant(of: genderFinder, matching: find.byType(InkWell))
              .first,
        );
        final genderBorder =
            (genderField.decoration.enabledBorder ??
                    genderField.decoration.border)!
                as OutlineInputBorder;
        expect(
          genderInkWell.borderRadius,
          genderBorder.borderRadius,
          reason:
              'Expressive choice ink follows the existing input silhouette.',
        );
        expect(genderField.decoration.fillColor, decoration.fillColor);
        expect(
          ((genderField.decoration.enabledBorder ??
                      genderField.decoration.border)!
                  as OutlineInputBorder)
              .borderSide
              .style,
          BorderStyle.none,
        );
        expect(
          (genderField.decoration.focusedBorder! as OutlineInputBorder)
              .borderSide
              .width,
          2,
        );
        for (final label in <String>[
          strings.userInfoGender,
          strings.userInfoBodyFat,
          strings.userInfoWeightTrend,
          strings.userInfoAverageSteps,
        ]) {
          await tester.scrollUntilVisible(
            find.text(label),
            240,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          final fieldFinder = _userInformationDropdownForLabel(label);
          expect(fieldFinder, findsOneWidget);
          final choiceField = tester
              .widget<ProfileExpressiveChoiceField<String?>>(fieldFinder);
          expect(choiceField.values, isNotEmpty);
          expect(choiceField.onChanged, isNotNull);
          expect(choiceField.decoration.fillColor, decoration.fillColor);
        }

        await tester.drag(find.byType(ListView).first, const Offset(0, 900));
        await tester.pumpAndSettle();
        await tester.ensureVisible(genderFinder);
        await tester.tap(genderFinder);
        await tester.pumpAndSettle();
        expect(find.text(strings.userInfoGenderFemale), findsOneWidget);
        await tester.tap(find.text(strings.userInfoGenderFemale));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          tester
              .widget<FloatingActionButton>(
                find.byKey(AppTestKeys.userInformationSave),
              )
              .onPressed,
          isNotNull,
        );
        await tester.tap(genderFinder);
        await tester.pumpAndSettle();
        final selectedGenderRow = tester.widget<RadioListTile<String?>>(
          find.byKey(
            const ValueKey<String>('user-info-dropdown-option-Female'),
          ),
        );
        expect(selectedGenderRow.selected, isTrue);
        expect(
          selectedGenderRow.selectedTileColor,
          profileExpressiveChoiceStyle(pageContext).selectedSurface,
        );
        expect(
          tester
              .getSize(
                find.byKey(
                  const ValueKey<String>('user-info-dropdown-option-Female'),
                ),
              )
              .height,
          greaterThanOrEqualTo(48),
        );
        expect(
          find
              .byKey(const ValueKey<String>('user-info-dropdown-option-Female'))
              .hitTestable(),
          findsOneWidget,
        );
        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();

        final currentWeightFinder = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == strings.userInfoCurrentWeight,
        );
        await tester.ensureVisible(currentWeightFinder);
        final currentWeightField = tester.widget<TextField>(
          currentWeightFinder,
        );
        expect(
          currentWeightField.decoration!.floatingLabelBehavior,
          FloatingLabelBehavior.always,
        );
        expect(
          currentWeightField.decoration!.suffixText,
          units.weightUnit.shortLabel,
        );
        expect(currentWeightField.keyboardType, TextInputType.number);

        await tester.enterText(
          find.byKey(AppTestKeys.userInformationName),
          'Taylor',
        );
        await tester.pump();
        expect(
          tester
              .widget<FloatingActionButton>(
                find.byKey(AppTestKeys.userInformationSave),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive User Information keeps a focused field and Save reachable with keyboard inset in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        const keyboardInset = 300.0;
        final repository = _FakeAppRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
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
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  viewInsets: const EdgeInsets.only(bottom: keyboardInset),
                ),
                child: child!,
              ),
              home: const UserInformationSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(
          find.byType(UserInformationSettingsPage),
        );
        final strings = AppLocalizations.of(pageContext);
        final currentWeightField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == strings.userInfoCurrentWeight,
        );
        await tester.scrollUntilVisible(
          currentWeightField,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(currentWeightField);
        await tester.pumpAndSettle();
        await tester.tap(currentWeightField);
        await tester.enterText(currentWeightField, '180');
        await tester.pumpAndSettle();

        final fieldRect = tester.getRect(currentWeightField);
        expect(fieldRect.top, greaterThanOrEqualTo(0));
        expect(fieldRect.bottom, lessThan(900 - keyboardInset));
        final save = find.byKey(AppTestKeys.userInformationSave);
        expect(tester.widget<FloatingActionButton>(save).onPressed, isNotNull);
        expect(save.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repository.saveCount, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Expressive User Information Weight trend choice opens and updates in ${brightness.name}',
      (tester) async {
        const height = 900.0;
        await tester.binding.setSurfaceSize(const Size(390, height));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = _FakeAppRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
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
              theme: brightness == Brightness.light
                  ? ExpressiveThemeDefinition.light()
                  : ExpressiveThemeDefinition.dark(),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const UserInformationSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppLocalizations.of(
          tester.element(find.byType(UserInformationSettingsPage)),
        );
        final trend = _userInformationDropdownForLabel(
          strings.userInfoWeightTrend,
        );
        final trendButton = trend;
        await tester.scrollUntilVisible(
          find.text(strings.userInfoWeightTrend),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.scrollUntilVisible(
          trendButton,
          240,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.drag(find.byType(ListView).first, const Offset(0, -220));
        await tester.pumpAndSettle();
        await tester.ensureVisible(trendButton);
        expect(trendButton.hitTestable(), findsOneWidget);
        await tester.tap(trendButton);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(strings.userInfoTrendMaintaining), findsOneWidget);
        final maintainOption = find.byKey(
          const ValueKey<String>(
            'user-info-dropdown-option-Maintaining weight',
          ),
        );
        await tester.tap(maintainOption);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text(strings.userInfoTrendMaintaining), findsOneWidget);
        expect(
          tester
              .widget<FloatingActionButton>(
                find.byKey(AppTestKeys.userInformationSave),
              )
              .onPressed,
          isNotNull,
        );
        await tester.tap(find.byKey(AppTestKeys.userInformationSave));
        await tester.pumpAndSettle();
        expect(repository.saveCount, 1);
        expect(find.byKey(AppTestKeys.userInformationSave), findsNothing);
      },
    );
  }

  for (final themeCase in <(String, ThemeData)>[
    ('Classic', ClassicThemeDefinition.light()),
    ('Neo', NeoBrutalismThemeDefinition.light()),
  ]) {
    testWidgets(
      '${themeCase.$1} User Information selectors and dirty-only Save FAB work',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = _FakeAppRepository();
        final units = UnitPreferenceProvider();
        await units.ready;
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
              theme: themeCase.$2,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const UserInformationSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final cleanScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(cleanScaffold.bottomNavigationBar, isNull);
        expect(find.byKey(AppTestKeys.userInformationSave), findsNothing);

        final strings = AppLocalizations.of(
          tester.element(find.byType(UserInformationSettingsPage)),
        );
        for (final label in <String>[
          strings.userInfoGender,
          strings.userInfoBodyFat,
          strings.userInfoWeightTrend,
          strings.userInfoAverageSteps,
        ]) {
          await tester.scrollUntilVisible(
            find.text(label),
            240,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          final fieldFinder = _userInformationDropdownForLabel(label);
          expect(fieldFinder, findsOneWidget);
          final buttonFinder = find.descendant(
            of: fieldFinder,
            matching: find.byType(DropdownButton<String?>),
          );
          final button = tester.widget<DropdownButton<String?>>(buttonFinder);
          expect(button.borderRadius, isNull);
          expect(button.elevation, 8);
          expect(button.selectedItemBuilder, isNull);
          for (final item in button.items!) {
            expect(item.child, isA<Text>());
          }
        }
        await tester.enterText(
          find.byKey(AppTestKeys.userInformationName),
          'Taylor',
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FloatingActionButton>(
                find.byKey(AppTestKeys.userInformationSave),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Finder _userInformationDropdownForLabel(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is ProfileExpressiveChoiceField<String?> &&
      widget.decoration.labelText == label,
);

class _FakeAppRepository extends AppRepository {
  int saveCount = 0;

  @override
  Future<PersonalInfo?> fetchPersonalInfo() async => null;

  @override
  Future<double?> fetchLatestBodyWeightLbs() async => null;

  @override
  Future<void> savePersonalInfoWithBodyWeight({
    required PersonalInfo info,
    double? bodyWeightValue,
    required WeightUnit bodyWeightUnit,
    String? measurementNote,
  }) async {
    saveCount++;
  }
}
