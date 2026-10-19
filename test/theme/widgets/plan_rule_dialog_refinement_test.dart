import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/flow_methods_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Plan rule validates its name and preserves parameters in $brightness',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repo = _PlanRuleRepository();
        await _openDialog(tester, repo, brightness: brightness);
        final strings = AppLocalizations.of(
          tester.element(find.byType(AddPresetMethodDialog)),
        );
        final save = find.widgetWithText(FilledButton, strings.commonSave);
        expect(find.text(strings.rulesFactorHelper), findsOneWidget);
        await tester.tap(_choice(strings.rulesRuleTypeLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.flowMethodReps));
        await tester.pumpAndSettle();
        expect(find.text(strings.rulesAmountHelper), findsOneWidget);
        await tester.tap(_choice(strings.rulesRuleTypeLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.flowMethodWeight));
        await tester.pumpAndSettle();

        var button = tester.widget<FilledButton>(save);
        expect(button.onPressed, isNull);
        final disabledBackground = button.style!.backgroundColor!.resolve({
          WidgetState.disabled,
        })!;
        final disabledForeground = button.style!.foregroundColor!.resolve({
          WidgetState.disabled,
        })!;
        expect(
          _contrast(disabledForeground, disabledBackground),
          greaterThanOrEqualTo(3),
        );

        final fields = find.byType(TextField);
        await tester.enterText(fields.first, '   ');
        await tester.pumpAndSettle();
        expect(find.text(strings.rulesNameRequired), findsOneWidget);
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        expect(repo.saved, isNull);

        await tester.tap(_choice(strings.rulesOperationLabel));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(save).onPressed, isNull);

        await tester.enterText(fields.first, 'Reduce weight');
        await tester.enterText(fields.last, '1.25');
        await tester.pumpAndSettle();
        button = tester.widget<FilledButton>(save);
        expect(button.onPressed, isNotNull);
        expect(
          _contrast(
            button.style!.foregroundColor!.resolve({})!,
            button.style!.backgroundColor!.resolve({})!,
          ),
          greaterThanOrEqualTo(4.5),
        );
        for (final input in tester.widgetList<TextField>(fields)) {
          final inputTheme = Theme.of(tester.element(find.byWidget(input)))
              .inputDecorationTheme;
          expect(inputTheme.filled, isTrue);
          expect(inputTheme.enabledBorder, isA<OutlineInputBorder>());
          expect(input.decoration?.labelText, isNull);
        }

        await tester.tap(_choice(strings.rulesOperationLabel));
        await tester.pumpAndSettle();
        final subtract = find.text('−  ${strings.rulesOperationSubtract}');
        expect(subtract, findsOneWidget);
        await tester.tap(subtract);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repo.saved?.name, 'Reduce weight');
        expect(repo.saved?.type, MethodType.weight);
        expect(repo.saved?.params, {'sign': '-', 'factor': 1.25});
        expect(repo.saveCalls, 1);
        expect(find.byType(AddPresetMethodDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Plan menus open downward within the safe viewport in $brightness',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final (size, scale, keyboard, locale) in [
          (const Size(390, 844), 1.0, 0.0, const Locale('en')),
          (const Size(320, 720), 1.6, 280.0, const Locale('fr')),
        ]) {
          final repo = _PlanRuleRepository();
          await _openDialog(
            tester,
            repo,
            brightness: brightness,
            size: size,
            scale: scale,
            keyboardInset: keyboard,
            locale: locale,
          );
          final strings = AppLocalizations.of(
            tester.element(find.byType(AddPresetMethodDialog)),
          );
          final cancel = find.widgetWithText(
            OutlinedButton,
            strings.commonCancel,
          );
          expect(
            tester.getRect(cancel).bottom,
            lessThanOrEqualTo(size.height - keyboard),
          );
          for (final label in [
            strings.rulesRuleTypeLabel,
            strings.rulesOperationLabel,
          ]) {
            final trigger = _choice(label);
            await tester.ensureVisible(trigger);
            await tester.pumpAndSettle();
            await tester.tap(trigger);
            await tester.pumpAndSettle();
            final items = find.byType(MenuItemButton);
            final viewport = find
                .ancestor(
                  of: items.first,
                  matching: find.byType(SingleChildScrollView),
                )
                .first;
            final menuRect = tester.getRect(viewport);
            final fieldRect = tester.getRect(trigger);
            expect(menuRect.left, closeTo(fieldRect.left + 6, 2));
            expect(menuRect.right, lessThanOrEqualTo(size.width - 12));
            expect(menuRect.top, greaterThanOrEqualTo(0));
            expect(menuRect.bottom, lessThanOrEqualTo(size.height - keyboard));
            expect(menuRect.top, greaterThanOrEqualTo(fieldRect.bottom));
            if (label == strings.rulesOperationLabel) {
              final operationHeading = tester.getRect(
                find.text(strings.rulesOperationLabel),
              );
              final ruleTypeField = tester.getRect(
                _choice(strings.rulesRuleTypeLabel),
              );
              expect(menuRect.overlaps(operationHeading), isFalse);
              expect(menuRect.overlaps(ruleTypeField), isFalse);
              expect(operationHeading.top, greaterThanOrEqualTo(0));
              expect(
                operationHeading.bottom,
                lessThanOrEqualTo(size.height - keyboard),
              );
              expect(fieldRect.top, greaterThanOrEqualTo(0));
              expect(
                fieldRect.bottom,
                lessThanOrEqualTo(size.height - keyboard),
              );
              expect(operationHeading.bottom, lessThan(menuRect.top));
            }
            for (final item in items.evaluate()) {
              expect(
                tester.getSize(find.byWidget(item.widget)).height,
                greaterThanOrEqualTo(48),
              );
            }
            if (scale == 1) {
              expect(
                menuRect.height,
                lessThanOrEqualTo(
                  label == strings.rulesRuleTypeLabel ? 204 : 108,
                ),
              );
            }
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pumpAndSettle();
            expect(find.byType(MenuItemButton), findsNothing);
            expect(find.byType(AddPresetMethodDialog), findsOneWidget);
          }

          await tester.ensureVisible(_choice(strings.rulesRuleTypeLabel));
          await tester.tap(_choice(strings.rulesRuleTypeLabel));
          await tester.pumpAndSettle();
          final deleteSet = find.text(strings.flowMethodDeleteSet);
          await tester.ensureVisible(deleteSet);
          await tester.pumpAndSettle();
          await tester.tap(deleteSet);
          await tester.pumpAndSettle();
          expect(find.text(strings.rulesDeleteLastSetBody), findsOneWidget);
          expect(_choice(strings.rulesOperationLabel), findsNothing);
          await tester.tap(cancel);
          await tester.pumpAndSettle();
          expect(repo.saveCalls, 0);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('Add set defaults to copying the last set in $brightness', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repo = _PlanRuleRepository();
      await _openDialog(tester, repo, brightness: brightness);
      final strings = AppLocalizations.of(
        tester.element(find.byType(AddPresetMethodDialog)),
      );

      await tester.enterText(find.byType(TextField).first, 'Copy final set');
      await tester.tap(_choice(strings.rulesRuleTypeLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.flowMethodAddSet));
      await tester.pumpAndSettle();

      final explicit = find.byKey(
        const ValueKey<String>('plan-rule-add-set-explicit'),
      );
      final copy = find.byKey(const ValueKey<String>('plan-rule-add-set-copy'));
      expect(tester.widget<Semantics>(explicit).properties.selected, isTrue);
      expect(tester.getSize(explicit).height, greaterThanOrEqualTo(48));
      await tester.tap(copy);
      await tester.pumpAndSettle();
      expect(tester.widget<Semantics>(copy).properties.selected, isTrue);
      expect(find.text(strings.rulesCopyFromLastHelper), findsOneWidget);
      expect(find.text(strings.rulesCopyFromLastSet), findsOneWidget);
      expect(find.text(strings.rulesCopyIndex), findsNothing);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, strings.commonSave));
      await tester.pumpAndSettle();
      expect(repo.saved?.type, MethodType.addSet);
      expect(repo.saved?.params, {'copyFromSetIndex': -1});
      expect(repo.saveCalls, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Copy source validates ordinary set numbers and saves their correct index in $brightness',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repo = _PlanRuleRepository();
        await _openDialog(
          tester,
          repo,
          brightness: brightness,
          existing: FlowMethod(
            id: 2,
            presetId: 7,
            name: 'Copy a set',
            type: MethodType.addSet,
            params: const {'copyFromSetIndex': -1},
          ),
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(AddPresetMethodDialog)),
        );
        final save = find.widgetWithText(FilledButton, strings.commonSave);
        await tester.tap(_choice(strings.rulesCopyFromLabel));
        await tester.pumpAndSettle();
        final items = find.byType(MenuItemButton);
        final menuViewport = find
            .ancestor(
              of: items.first,
              matching: find.byType(SingleChildScrollView),
            )
            .first;
        expect(
          tester.getRect(menuViewport).top,
          greaterThanOrEqualTo(
            tester.getRect(_choice(strings.rulesCopyFromLabel)).bottom,
          ),
        );
        expect(tester.getRect(menuViewport).bottom, lessThanOrEqualTo(844));
        expect(tester.getSize(menuViewport).height, greaterThanOrEqualTo(144));
        await tester.ensureVisible(find.text(strings.rulesCopyFromFirstSet));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.rulesCopyFromFirstSet));
        await tester.pumpAndSettle();
        expect(find.text(strings.rulesCopyFromFirstHelper), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        await tester.tap(_choice(strings.rulesCopyFromLabel));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(strings.rulesCopyFromSpecificSet));
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.rulesCopyFromSpecificSet));
        await tester.pumpAndSettle();
        expect(find.text(strings.rulesCopySetNumberLabel), findsOneWidget);
        expect(find.text(strings.rulesCopySpecificHelper), findsOneWidget);
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        final setNumber = find.byType(TextField).last;
        for (final invalid in ['0', '-1', '2.5', 'abc', '']) {
          await tester.enterText(setNumber, invalid);
          await tester.pumpAndSettle();
          expect(tester.widget<FilledButton>(save).onPressed, isNull);
          expect(find.text(strings.rulesCopySetNumberInvalid), findsOneWidget);
          expect(repo.saveCalls, 0);
        }
        await tester.enterText(setNumber, '5');
        await tester.pumpAndSettle();
        expect(find.text(strings.rulesCopySetNumberInvalid), findsNothing);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repo.saved?.params, {'copyFromSetIndex': 4});
        expect(repo.saveCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Copy source stays reachable with large text and the keyboard', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _PlanRuleRepository();
    await _openDialog(
      tester,
      repo,
      size: const Size(320, 720),
      scale: 1.6,
      keyboardInset: 280,
      locale: const Locale('fr'),
      existing: FlowMethod(
        id: 2,
        presetId: 7,
        name: 'Existing copy',
        type: MethodType.addSet,
        params: const {'copyFromSetIndex': 4},
      ),
    );
    final strings = AppLocalizations.of(
      tester.element(find.byType(AddPresetMethodDialog)),
    );
    final choice = _choice(strings.rulesCopyFromLabel);
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    final items = find.byType(MenuItemButton);
    final viewport = find
        .ancestor(of: items.first, matching: find.byType(SingleChildScrollView))
        .first;
    expect(tester.getRect(viewport).bottom, lessThanOrEqualTo(440));
    expect(
      tester.getRect(viewport).top,
      greaterThanOrEqualTo(tester.getRect(choice).bottom),
    );
    await tester.ensureVisible(find.text(strings.rulesCopyFromFirstSet));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.rulesCopyFromFirstSet));
    await tester.pumpAndSettle();
    expect(find.text(strings.rulesCopyFromFirstHelper), findsOneWidget);
    final cancel = find.widgetWithText(OutlinedButton, strings.commonCancel);
    expect(tester.getRect(cancel).bottom, lessThanOrEqualTo(440));
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(repo.saveCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Classic and Neo retain their existing copy-index controls', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final theme in [
      ClassicThemeDefinition.light(),
      NeoBrutalismThemeDefinition.dark(),
    ]) {
      final repo = _PlanRuleRepository();
      await _openDialog(
        tester,
        repo,
        theme: theme,
        existing: FlowMethod(
          id: 2,
          presetId: 7,
          name: 'Existing copy',
          type: MethodType.addSet,
          params: const {'copyFromSetIndex': 4},
        ),
      );
      final strings = AppLocalizations.of(
        tester.element(find.byType(AddPresetMethodDialog)),
      );
      expect(_choice(strings.rulesCopyFromLabel), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byType(TextField).last)
            .decoration
            ?.labelText,
        strings.rulesCopyIndex,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, strings.commonSave));
      await tester.pumpAndSettle();
      expect(repo.saved?.params, {'copyFromSetIndex': 4});
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'First set saves index zero and specific set survives reopening',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final index in [0, 4]) {
        final repo = _PlanRuleRepository();
        await _openDialog(
          tester,
          repo,
          existing: FlowMethod(
            id: 2,
            presetId: 7,
            name: 'Existing copy',
            type: MethodType.addSet,
            params: {'copyFromSetIndex': index},
          ),
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(AddPresetMethodDialog)),
        );
        expect(
          find.text(
            index == 0
                ? strings.rulesCopyFromFirstSet
                : strings.rulesCopyFromSpecificSet,
          ),
          findsOneWidget,
        );
        if (index == 4) {
          expect(
            tester
                .widget<TextField>(find.byType(TextField).last)
                .controller!
                .text,
            '5',
          );
        }
        await tester.tap(find.widgetWithText(FilledButton, strings.commonSave));
        await tester.pumpAndSettle();
        expect(repo.saved?.params, {'copyFromSetIndex': index});
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Editing each plan rule type keeps existing values and defaults',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final (type, params) in <(MethodType, Map<String, dynamic>)>[
        (MethodType.weight, {'sign': '+', 'factor': 1.5}),
        (MethodType.rep, {'sign': '-', 'amount': 2}),
        (MethodType.addSet, {'weight': 40.0, 'reps': 8}),
        (MethodType.addSet, {'copyFromSetIndex': -1}),
        (MethodType.addSet, {'copyFromSetIndex': 0}),
        (MethodType.addSet, {'copyFromSetIndex': 4}),
        (MethodType.delSet, {}),
      ]) {
        final repo = _PlanRuleRepository();
        await _openDialog(
          tester,
          repo,
          existing: FlowMethod(
            id: 2,
            presetId: 7,
            name: 'Existing rule',
            type: type,
            params: params,
          ),
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(AddPresetMethodDialog)),
        );
        expect(find.text('Existing rule'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, strings.commonSave));
        await tester.pumpAndSettle();
        expect(repo.saved?.type, type);
        expect(repo.saved?.params, params);
        expect(repo.saved?.presetId, 7);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

Finder _choice(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

double _contrast(Color a, Color b) {
  final values = [a.computeLuminance(), b.computeLuminance()]..sort();
  return (values.last + 0.05) / (values.first + 0.05);
}

Future<void> _openDialog(
  WidgetTester tester,
  _PlanRuleRepository repo, {
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
  double scale = 1,
  double keyboardInset = 0,
  Locale locale = const Locale('en'),
  FlowMethod? existing,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    Provider<AppRepository>.value(
      value: repo,
      child: MaterialApp(
        theme:
            theme ??
            (brightness == Brightness.light
                ? ExpressiveThemeDefinition.light()
                : ExpressiveThemeDefinition.dark()),
        locale: locale,
        localizationsDelegates: tonosLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboardInset),
          ),
          child: child!,
        ),
        home: AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.profile,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<FlowMethod>(
                  context: context,
                  builder: (_) =>
                      AddPresetMethodDialog(presetId: 7, existing: existing),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

class _PlanRuleRepository extends AppRepository {
  FlowMethod? saved;
  int saveCalls = 0;

  @override
  Future<FlowMethod> upsertFlowMethod({
    required int presetId,
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) async {
    saveCalls++;
    return saved = FlowMethod(
      id: 1,
      presetId: presetId,
      name: name,
      type: type,
      params: Map.of(params),
    );
  }
}
