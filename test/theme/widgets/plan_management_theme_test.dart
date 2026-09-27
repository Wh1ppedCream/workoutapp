import 'dart:io';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/plan_management_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
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

    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(5));
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
      final theme =
          brightness == Brightness.light
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        final planForeground =
            neo
                ? neoPlanForeground
                : Theme.of(context).textTheme.titleMedium?.color;
        final planSecondary =
            neo
                ? tonosSecondaryForegroundForSurface(context, surfaces.planCard)
                : scheme.onSurfaceVariant;
        final archivedStatusColor =
            neo ? neoPlanForeground : scheme.onSurfaceVariant;

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

        final planTiles =
            tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).where((
              box,
            ) {
              final decoration = box.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == surfaces.planCard;
            }).toList();
        expect(planTiles, hasLength(2));
        for (final tile in planTiles) {
          final decoration = tile.decoration as BoxDecoration;
          expect(decoration.borderRadius, shapes.planCard);
          expect(decoration.border, Border.all(color: scheme.outlineVariant));
        }

        final avatars =
            tester.widgetList<CircleAvatar>(find.byType(CircleAvatar)).toList();
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

        final countPills =
            tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).where((
              box,
            ) {
              final decoration = box.decoration;
              return decoration is BoxDecoration &&
                  decoration.color == scheme.primaryContainer &&
                  decoration.borderRadius == shapes.pill;
            }).toList();
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
}

class _PlanManagementRepository extends AppRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => [
    {'id': 1, 'name': 'Visible Plan', 'is_automatic': 0},
    {'id': 2, 'name': 'Archived Plan', 'is_automatic': 1},
  ];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => {1};
}
