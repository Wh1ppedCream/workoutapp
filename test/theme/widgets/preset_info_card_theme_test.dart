import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/preset_info_card.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode preset summary metrics use owned surface and shape', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => UnitPreferenceProvider(),
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: tonosLocalizationDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: PresetInfoCard(
                  repository: _EmptyRepository(),
                  exercises: const [],
                  cardTypes: const [],
                  definitionIds: const [],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(PresetInfoCard));
        final activeTheme = Theme.of(context);
        final surfaces = context.surfaceTokens;
        final shapes = context.shapeTokens;
        final isNeo = family == AppThemeFamily.neoBrutalism;
        final foreground =
            isNeo
                ? tonosForegroundForSurface(context, surfaces.card)
                : context.semanticColors.strongContent;
        final secondaryForeground = context.semanticColors.mutedContent;
        final helpText = tester.widget<Text>(
          find.text(AppLocalizations.of(context).presetFocusPreviewHelp),
        );
        expect(helpText.style, activeTheme.textTheme.bodySmall);
        final metricFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color == surfaces.card &&
              (widget.decoration! as BoxDecoration).borderRadius ==
                  shapes.metric,
        );
        expect(metricFinder, findsNWidgets(2));

        final iconColor =
            isNeo
                ? tonosForegroundForSurface(context, surfaces.card)
                : activeTheme.colorScheme.primary;
        for (final icon in tester.widgetList<Icon>(
          find.descendant(of: metricFinder, matching: find.byType(Icon)),
        )) {
          expect(icon.color, iconColor);
        }

        final metricTexts = tester.widgetList<Text>(
          find.descendant(of: metricFinder, matching: find.byType(Text)),
        );
        expect(metricTexts, hasLength(4));
        for (final text in metricTexts) {
          final isLabel =
              text.data == AppLocalizations.of(context).presetEstimatedTime ||
              text.data == AppLocalizations.of(context).logbookTotalVolume;
          expect(
            text.style,
            isLabel
                ? activeTheme.textTheme.bodySmall?.copyWith(
                  color: secondaryForeground,
                )
                : activeTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
          );
        }

        for (final container in tester.widgetList<Container>(metricFinder)) {
          final decoration = container.decoration! as BoxDecoration;
          expect(decoration.color, surfaces.card);
          expect(decoration.borderRadius, shapes.metric);
          if (isNeo) {
            expect(
              decoration.border,
              Border.all(
                color: tonosOutlineForSurface(context, surfaces.card),
                width: shapes.outlineWidth,
              ),
            );
          } else {
            expect(decoration.border, isNull);
          }
        }

        expect(
          find.byType(TonosSurface),
          isNeo ? findsOneWidget : findsNothing,
        );
        expect(find.byType(Card), isNeo ? findsNothing : findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _EmptyRepository extends AppRepository {}
