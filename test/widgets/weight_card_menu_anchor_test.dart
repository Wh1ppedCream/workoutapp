import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/weight_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('menu keeps its action order and supports keyboard dismissal', (
    tester,
  ) async {
    var swapCount = 0;
    await _pumpWeightCard(tester, onSwapExercise: () => swapCount++);

    final anchor = _menuButton();
    final focusNode = tester.widget<IconButton>(anchor).focusNode!;
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );
    final actionLabels = [
      strings.weightSwapExercise,
      strings.weightRemoveExerciseTitle,
      strings.weightMakeChangeSet,
    ];
    expect(find.byType(MenuItemButton), findsNWidgets(3));
    final actionTops = [
      for (final label in actionLabels) tester.getTopLeft(find.text(label)).dy,
    ];
    expect(actionTops, orderedEquals(actionTops.toList()..sort()));

    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(swapCount, 1);
    expect(find.byType(MenuItemButton), findsNothing);
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNWidgets(3));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(strings.weightSwapExercise), findsNothing);
    expect(focusNode.hasFocus, isTrue);
    expect(swapCount, 1);
  });

  testWidgets('swap and change-set actions retain their production behavior', (
    tester,
  ) async {
    var swapCount = 0;
    await _pumpWeightCard(tester, onSwapExercise: () => swapCount++);
    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );

    await _openMenu(tester);
    await tester.tap(find.text(strings.weightSwapExercise));
    await tester.pumpAndSettle();
    expect(swapCount, 1);
    expect(find.byType(MenuItemButton), findsNothing);

    await _openMenu(tester);
    await tester.tap(find.text(strings.weightMakeChangeSet));
    await tester.pumpAndSettle();
    expect(find.text(strings.weightAddChangeSet), findsOneWidget);
  });

  testWidgets('remove still requires confirmation before invoking its owner', (
    tester,
  ) async {
    var removeCount = 0;
    await _pumpWeightCard(tester, onDeleteExercise: () => removeCount++);
    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );

    final anchor = _menuButton();
    final focusNode = tester.widget<IconButton>(anchor).focusNode!;
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MenuItemButton>(find.byType(MenuItemButton).first).autofocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text(strings.weightRemoveExerciseBody), findsOneWidget);
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();
    expect(removeCount, 0);
    expect(focusNode.hasFocus, isTrue);

    await _openMenu(tester);
    await tester.tap(find.text(strings.weightRemoveExerciseTitle));
    await tester.pumpAndSettle();
    expect(find.text(strings.weightRemoveExerciseBody), findsOneWidget);
    await tester.tap(find.text(strings.commonCancel));
    await tester.pumpAndSettle();
    expect(removeCount, 0);

    await _openMenu(tester);
    await tester.tap(find.text(strings.weightRemoveExerciseTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.commonRemove));
    await tester.pumpAndSettle();
    expect(removeCount, 1);
  });

  testWidgets('read-only WeightCard keeps the menu anchor disabled', (
    tester,
  ) async {
    await _pumpWeightCard(tester, readOnly: true, onSwapExercise: () {});
    final anchor = _menuButton();
    expect(tester.widget<IconButton>(anchor).onPressed, isNull);

    await tester.tap(anchor);
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNothing);
  });

  testWidgets('outside taps dismiss without activating the underlying row', (
    tester,
  ) async {
    var outsideTapCount = 0;
    await _pumpWeightCard(
      tester,
      onSwapExercise: () {},
      onOutsideTap: () => outsideTapCount++,
    );
    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );

    await _openMenu(tester);
    await tester.tap(find.text('Outside action'));
    await tester.pumpAndSettle();
    expect(outsideTapCount, 0);
    expect(find.text(strings.weightSwapExercise), findsNothing);

    await _openMenu(tester);
    final setWeightField = find.byType(TextFormField).first;
    expect(setWeightField, findsOneWidget);
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Android back dismisses the open menu before leaving the page', (
    tester,
  ) async {
    await _pumpWeightCard(tester, onSwapExercise: () {});
    final strings = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );

    await _openMenu(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(WeightCard), findsOneWidget);
    expect(find.text(strings.weightSwapExercise), findsNothing);
  });

  testWidgets('anchor exposes one labelled action and menu items stay named', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpWeightCard(tester, onSwapExercise: () {});

      final anchor = _menuButton();
      final localizations = MaterialLocalizations.of(
        tester.element(find.byType(WeightCard)),
      );
      final anchorData = tester.getSemantics(anchor).getSemanticsData();
      expect(anchorData.tooltip, localizations.showMenuTooltip);
      expect(anchorData.hasAction(SemanticsAction.tap), isTrue);

      await _openMenu(tester);
      final menuItems = find.byType(MenuItemButton);
      expect(menuItems, findsNWidgets(3));
      final expectedLabels = [
        AppLocalizations.of(tester.element(find.byType(WeightCard)))
            .weightSwapExercise,
        AppLocalizations.of(tester.element(find.byType(WeightCard)))
            .weightRemoveExerciseTitle,
        AppLocalizations.of(tester.element(find.byType(WeightCard)))
            .weightMakeChangeSet,
      ];
      for (var i = 0; i < menuItems.evaluate().length; i++) {
        final data = tester.getSemantics(menuItems.at(i)).getSemanticsData();
        expect(data.label, expectedLabels[i]);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('menu stays within a compact viewport at 2x text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpWeightCard(tester, textScale: 2, onSwapExercise: () {});

    await _openMenu(tester);
    final labels = [
      AppLocalizations.of(tester.element(find.byType(WeightCard)))
          .weightSwapExercise,
      AppLocalizations.of(tester.element(find.byType(WeightCard)))
          .weightRemoveExerciseTitle,
      AppLocalizations.of(tester.element(find.byType(WeightCard)))
          .weightMakeChangeSet,
    ];
    for (final label in labels) {
      final rect = tester.getRect(find.text(label));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(640));
    }
    expect(tester.takeException(), isNull);
  });
}

Finder _menuButton() => find.widgetWithIcon(IconButton, Icons.more_vert);

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(_menuButton());
  await tester.pumpAndSettle();
  expect(find.byType(MenuItemButton), findsWidgets);
}

Future<void> _pumpWeightCard(
  WidgetTester tester, {
  bool readOnly = false,
  double textScale = 1,
  VoidCallback? onSwapExercise,
  VoidCallback? onDeleteExercise,
  VoidCallback? onOutsideTap,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final units = UnitPreferenceProvider();
  await units.ready;
  addTearDown(units.dispose);

  final exercise = WeightExercise(
    name: 'Squat',
    equipment: 'Barbell',
    sets: [ExerciseSet(weight: 100, reps: 5)],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<UnitPreferenceProvider>.value(
      value: units,
      child: MaterialApp(
        theme: AppThemeFactory.light(AppThemeFamily.classic),
        themeAnimationDuration: Duration.zero,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final media = MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale));
            return MediaQuery(
              data: media,
              child: Scaffold(
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        child: WeightCard(
                          exercise: exercise,
                          readOnlyMode: readOnly,
                          previewWeightUnit: WeightUnit.pounds,
                          onSwapExercise: onSwapExercise,
                          onDeleteExercise: onDeleteExercise,
                        ),
                      ),
                    ),
                    if (onOutsideTap != null)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: TextButton(
                          onPressed: onOutsideTap,
                          child: const Text('Outside action'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
