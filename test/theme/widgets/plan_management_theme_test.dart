import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/plan_management_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_planning_tokens.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tools/theme_style_inventory.dart';

void main() {
  test('Plan Management has exact theme-owned style coverage', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'plan-management-theme-recipes',
    );

    expect(rule.pattern, 'lib/screens/exercise/plan_management_page.dart');
    expect(rule.classification, 'release_surface');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals([
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );

    final findings = report.findings
        .where((finding) => finding.ruleId == rule.id)
        .toList();
    expect(findings, hasLength(12));
    expect(findings.map((finding) => finding.kind).toSet(), {
      'color_transform',
      'decoration',
      'geometry',
      'text_style',
    });
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
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode Plan Management resolves its theme recipes', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          'guided_tutorial_completed.${TutorialIds.planManagement}': true,
        });
        await tester.binding.setSurfaceSize(const Size(430, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repository = _PlanManagementRepository();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              Provider<ActivePlanStore>.value(
                value: ActivePlanStore(repository: repository),
              ),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const PlanManagementPage(profileId: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(PlanManagementPage));
        final strings = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        final surfaces = context.surfaceTokens;
        final shapes = context.shapeTokens;
        final neo = family == AppThemeFamily.neoBrutalism;
        final neoPlanForeground = tonosForegroundForSurface(
          context,
          surfaces.planCard,
        );
        final planForeground = neo
            ? neoPlanForeground
            : Theme.of(context).textTheme.titleMedium?.color;
        final planSecondary = neo
            ? tonosSecondaryForegroundForSurface(context, surfaces.planCard)
            : scheme.onSurfaceVariant;
        final archivedStatusColor = neo
            ? neoPlanForeground
            : scheme.onSurfaceVariant;

        expect(find.text('Visible Plan'), findsOneWidget);
        expect(find.text('Archived Plan'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('Visible Plan')).style?.color,
          planForeground,
        );
        expect(
          tester.widget<Text>(find.text('Archived Plan')).style?.color,
          planForeground,
        );
        expect(find.text(strings.planManagementVisible), findsOneWidget);
        expect(find.text(strings.planManagementAutomatic), findsOneWidget);
        expect(
          find.byWidgetPredicate((widget) => widget is OutlinedButton),
          findsNWidgets(2),
        );
        expect(
          tester
              .widget<Text>(find.text(strings.planManagementVisible))
              .style
              ?.color,
          planSecondary,
        );
        expect(
          tester
              .widget<Text>(find.text(strings.planManagementAutomatic))
              .style
              ?.color,
          planSecondary,
        );

        final planTiles = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .where((box) {
              final decoration = box.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.planCard;
            })
            .toList();
        expect(planTiles, hasLength(2));
        for (final tile in planTiles) {
          final decoration = tile.decoration as BoxDecoration;
          expect(decoration.borderRadius, shapes.planCard);
          expect(decoration.border, Border.all(color: scheme.outlineVariant));
        }

        final avatars = tester
            .widgetList<CircleAvatar>(find.byType(CircleAvatar))
            .toList();
        expect(avatars, hasLength(2));
        expect(
          avatars[0].backgroundColor,
          scheme.primary.withValues(alpha: 0.16),
        );
        expect(avatars[0].child, isA<Icon>());
        expect((avatars[0].child as Icon).color, scheme.primary);
        expect(
          avatars[1].backgroundColor,
          archivedStatusColor.withValues(alpha: 0.16),
        );
        expect((avatars[1].child as Icon).color, archivedStatusColor);

        final countPills = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .where((box) {
              final decoration = box.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == scheme.primaryContainer &&
                  decoration.borderRadius == shapes.pill;
            })
            .toList();
        expect(countPills, hasLength(2));
        final countTexts = tester.widgetList<Text>(
          find.descendant(
            of: find.byWidgetPredicate((widget) {
              if (widget is! DecoratedBox ||
                  widget.decoration is! BoxDecoration) {
                return false;
              }
              final decoration = widget.decoration as BoxDecoration;
              return decoration.color == scheme.primaryContainer &&
                  decoration.borderRadius == shapes.pill;
            }),
            matching: find.byType(Text),
          ),
        );
        expect(countTexts, hasLength(2));
        for (final text in countTexts) {
          expect(text.data, '1');
          expect(text.style?.color, scheme.onPrimaryContainer);
          expect(text.style?.fontWeight, FontWeight.w900);
        }

        expect(tester.takeException(), isNull, reason: mode);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final entry in <(String, ThemeData, AppExpressivePlanningTokens)>[
    (
      'light',
      ExpressiveThemeDefinition.light(),
      AppExpressivePlanningTokens.light,
    ),
    (
      'dark',
      ExpressiveThemeDefinition.dark(),
      AppExpressivePlanningTokens.dark,
    ),
  ]) {
    testWidgets('Expressive ${entry.$1} Plan Management keeps plan actions', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'guided_tutorial_completed.${TutorialIds.planManagement}': true,
      });
      await tester.binding.setSurfaceSize(const Size(320, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _PlanManagementRepository();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            Provider<ActivePlanStore>.value(
              value: ActivePlanStore(repository: repository),
            ),
          ],
          child: MaterialApp(
            theme: entry.$2,
            themeAnimationDuration: Duration.zero,
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const PlanManagementPage(profileId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final page = find.byType(PlanManagementPage);
      final context = tester.element(page);
      final strings = AppLocalizations.of(context);
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: page, matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.backgroundColor, entry.$3.pageCanvas);

      final activeHeading = find.text(strings.trainActivePlans);
      final activeCardFinder = find
          .ancestor(of: activeHeading, matching: find.byType(Card))
          .first;
      expect(
        tester.widget<Card>(activeCardFinder).color,
        entry.$3.planFocalSurface,
      );

      final activeStatus = tester.widget<CircleAvatar>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CircleAvatar &&
              widget.child is Icon &&
              (widget.child! as Icon).icon == Icons.push_pin_outlined,
        ),
      );
      expect(
        activeStatus.backgroundColor,
        entry.$3.planAccent.withValues(alpha: 0.16),
      );
      expect((activeStatus.child! as Icon).color, entry.$3.planAccent);
      expect(find.text(strings.planManagementArchive), findsOneWidget);
      final expressive = AppExpressivePlanningTokens.maybeOf(context);
      expect(
        find.ancestor(
          of: find.text(strings.planManagementArchive),
          matching: find.byType(TonosExpressivePressResponse),
        ),
        expressive == null ? findsNothing : findsOneWidget,
      );

      final archiveAction = find.text(strings.planManagementArchive);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(archiveAction);
      await tester.pumpAndSettle();
      expect(repository.activePlanIds, isEmpty);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      final archivedHeading = find.text(strings.trainArchivedPlans);
      final archivedCardFinder = find
          .ancestor(of: archivedHeading, matching: find.byType(Card))
          .first;
      expect(
        tester.widget<Card>(archivedCardFinder).color,
        entry.$3.planSupportSurface,
      );
      expect(
        find.text(strings.planManagementActivate),
        findsAtLeastNWidgets(1),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

class _PlanManagementRepository extends AppRepository {
  Set<int> activePlanIds = {1};

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => [
    {'id': 1, 'name': 'Visible Plan', 'is_automatic': 0},
    {'id': 2, 'name': 'Archived Plan', 'is_automatic': 1},
  ];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async =>
      Set<int>.of(activePlanIds);

  @override
  Future<void> replaceActivePlans(int profileId, Set<int> presetIds) async {
    activePlanIds = Set<int>.of(presetIds);
  }

  @override
  Future<void> addActivePlan(int profileId, int presetId) async {
    activePlanIds.add(presetId);
  }

  @override
  Future<void> removeActivePlan(int profileId, int presetId) async {
    activePlanIds.remove(presetId);
  }
}
