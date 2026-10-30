import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/widgets/automatic_settings_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/preset_repository_fixture.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    testWidgets(
      '${family.code} dismissing settings discards the method draft',
      (tester) async {
        final (repo, preset) = await _open(tester, family);
        await _editMethods(tester);
        expect(_flags(preset), [true, true, false, false]);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(_flags(preset), [true, true, false, false]);
        expect(repo.autoSaveCalls, 0);
        expect(repo.autoWrite, isNull);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${family.code} failed save retains draft without publishing it, then retries',
      (tester) async {
        final (repo, preset) = await _open(tester, family);
        repo.failAutoSave = true;
        await _editMethods(tester);
        final save = find.widgetWithText(ElevatedButton, 'Save');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repo.autoSaveCalls, 1);
        expect(repo.autoWrite, isNull);
        expect(_flags(preset), [true, true, false, false]);
        expect(find.byType(AutomaticSettingsSheet), findsOneWidget);

        ScaffoldMessenger.of(tester.element(save)).removeCurrentSnackBar();
        repo.failAutoSave = false;
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repo.autoSaveCalls, 2);
        expect(_flags(preset), [false, false, true, true]);
        expect(repo.autoWrite!.settings.weightCheck, isFalse);
        expect(repo.autoWrite!.settings.repCheck, isFalse);
        expect(repo.autoWrite!.settings.volumeCheck, isTrue);
        expect(repo.autoWrite!.settings.adjustAllSets, isTrue);
        expect(find.byType(AutomaticSettingsSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

List<bool> _flags(PresetSession preset) => [
  preset.weightCheck,
  preset.repCheck,
  preset.volumeCheck,
  preset.adjustAllSets,
];

Future<(PresetRepositoryFixture, PresetSession)> _open(
  WidgetTester tester,
  AppThemeFamily family,
) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(const Size(430, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repo = PresetRepositoryFixture();
  final preset = PresetSession(1, repository: repo);
  await preset.ready;
  addTearDown(preset.dispose);
  final units = UnitPreferenceProvider();
  await units.ready;
  addTearDown(units.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider<UnitPreferenceProvider>.value(
      value: units,
      child: MaterialApp(
        theme: AppThemeFactory.light(family),
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AutomaticSettingsSheet(preset: preset),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return (repo, preset);
}

Future<void> _editMethods(WidgetTester tester) async {
  final strings = AppLocalizations.of(
    tester.element(find.byType(AutomaticSettingsSheet)),
  );
  await tester.tap(find.text(strings.automaticMethodsTab));
  await tester.pumpAndSettle();
  for (final label in [
    strings.automaticWeightTarget,
    strings.automaticRepsTarget,
    strings.automaticVolumeTarget,
  ]) {
    final tile = find.widgetWithText(CheckboxListTile, label);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
  final allSets = find.byWidgetPredicate(
    (w) => w is RadioListTile<bool> && w.value,
  );
  await tester.ensureVisible(allSets);
  await tester.tap(allSets);
  await tester.pumpAndSettle();
}
