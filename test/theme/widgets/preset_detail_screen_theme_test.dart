import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/preset_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/preset_detail_screen.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preset plan-name styling has exact route ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'preset-detail-plan-name-field',
    );

    expect(rule.pattern, 'lib/screens/exercise/preset_detail_screen.dart');
    expect(rule.classification, 'structural_theme');
    expect(
      rule.kinds,
      unorderedEquals(<String>['decoration', 'geometry', 'text_style']),
    );
    final findings = report.findings.where((f) => f.ruleId == rule.id).toList();
    expect(findings, hasLength(8));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == rule.pattern && finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppThemeFactory.light(family)
          : AppThemeFactory.dark(family);

      testWidgets(
        '${family.code} ${brightness.name} resolves the guided plan-name field',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          SharedPreferences.setMockInitialValues(<String, Object>{});

          final repository = _PresetRepository();
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                ChangeNotifierProvider(
                  create: (_) => PresetSession(1, repository: repository),
                ),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const PresetDetailScreen(
                  startInEditingMode: true,
                  showOnboardingManualPlanTutorial: true,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final field = tester.widget<TextField>(
            find.byKey(AppTestKeys.planName),
          );
          expect(field.style?.fontSize, 20);
          expect(field.style?.fontWeight, FontWeight.bold);
          final border = field.decoration!.border! as UnderlineInputBorder;
          expect(border.borderSide.color, theme.colorScheme.primary);
          expect(border.borderSide.width, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();
    testWidgets(
      'Expressive ${brightness.name} plan detail styling and edit toggle',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues(<String, Object>{});

        final repository = _PresetRepository();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              ChangeNotifierProvider(
                create: (_) => PresetSession(1, repository: repository),
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const PresetDetailScreen(startInEditingMode: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pageContext = tester.element(find.byType(PresetDetailScreen));
        final planning = AppExpressivePlanningTokens.maybeOf(pageContext)!;
        final pageScaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(PresetDetailScreen),
            matching: find.byType(Scaffold),
          ),
        );
        expect(pageScaffold.backgroundColor, planning.pageCanvas);
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
          planning.planSupportSurface,
        );
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).foregroundColor,
          planning.planSupportForeground,
        );

        final saveButton = tester.widget<ElevatedButton>(
          find.byKey(AppTestKeys.planSave),
        );
        expect(
          saveButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
          planning.actionPrimary,
        );
        expect(
          saveButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
          planning.actionPrimaryForeground,
        );
        await tester.tap(find.byKey(AppTestKeys.planEdit));
        await tester.pumpAndSettle();
        expect(find.byKey(AppTestKeys.planSave), findsNothing);
        expect(find.byKey(AppTestKeys.planStartSession), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _PresetRepository extends AppRepository {
  @override
  Future<PresetDefinition?> fetchPresetById(int presetId) async =>
      PresetDefinition(
        id: presetId,
        name: 'New Plan',
        createdAt: DateTime.utc(2026, 9, 1),
        profileId: 1,
        isDraft: true,
      );

  @override
  Future<List<Map<String, dynamic>>> fetchPresetExercises(int presetId) async =>
      const <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>?> fetchPresetAutoSettings(int presetId) async =>
      null;
}
