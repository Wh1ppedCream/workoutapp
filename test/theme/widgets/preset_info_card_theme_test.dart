import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';
import 'package:env_test/widgets/preset_info_card.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:env_test/utils/weight_unit_formatter.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
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
        final foreground = isNeo
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

        final iconColor = isNeo
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
  for (final brightness in Brightness.values) {
    for (final layout in [
      (width: 411.0, scale: 1.0),
      (width: 320.0, scale: 1.0),
      (width: 320.0, scale: 2.0),
    ]) {
      testWidgets(
        'Expressive ${brightness.name} plan hero preserves planned totals and focus at $layout',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(layout.width, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          SharedPreferences.setMockInitialValues({});
          final units = UnitPreferenceProvider();
          await units.ready;
          addTearDown(units.dispose);
          final exercise = WeightExercise(
            name: 'Bench Press - Barbell',
            equipment: 'Barbell',
            sets: [
              ExerciseSet(weight: 50, reps: 10),
              ExerciseSet(weight: 50, reps: 10),
            ],
            changeSets: {
              0: [ExerciseSet(weight: 25, reps: 8)],
            },
          );
          await tester.pumpWidget(
            ChangeNotifierProvider.value(
              value: units,
              child: MaterialApp(
                theme: brightness == Brightness.light
                    ? ExpressiveThemeDefinition.light()
                    : ExpressiveThemeDefinition.dark(),
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(layout.scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(19),
                    child: PresetInfoCard(
                      repository: _SummaryRepository(),
                      exercises: [exercise],
                      cardTypes: const [CardType.weight],
                      definitionIds: const [1],
                      compactExpressive: true,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final context = tester.element(find.byType(PresetInfoCard));
          final strings = AppLocalizations.of(context);
          expect(find.text(strings.durationMinutesCompact(14)), findsOneWidget);
          expect(
            find.text(
              WeightUnitFormatter.formatVolume(
                1200,
                units.weightUnit,
                locale: Localizations.localeOf(context),
              ),
            ),
            findsOneWidget,
          );
          // The approved hero rounds labels while retaining fractional bar data.
          expect(find.text('0.5'), findsNothing);
          final focusList = find.byType(FocusedSetsList);
          final focusWidget = tester.widget<FocusedSetsList>(focusList);
          expect(focusWidget.roundUnits, isTrue);
          expect(focusWidget.hits[2].units, closeTo(0.5, 0.0001));
          final countLabels = tester
              .widgetList<Text>(
                find.descendant(of: focusList, matching: find.byType(Text)),
              )
              .map((text) => text.data)
              .whereType<String>()
              .where((text) => RegExp(r'^\d+$').hasMatch(text));
          expect(countLabels, ['3', '2', '1', '0', '0', '0']);
          for (final name in _SummaryRepository.focus.keys.map(
            (part) => part.name,
          )) {
            expect(find.text(name), findsOneWidget);
          }

          final time = tester.getRect(
            find.byKey(const ValueKey('expressive-preset-time')),
          );
          final volume = tester.getRect(
            find.byKey(const ValueKey('expressive-preset-volume')),
          );
          if (layout.scale == 1) {
            expect(time.top, volume.top);
            expect(time.height, volume.height);
            expect(time.right, lessThan(volume.left));
          } else {
            expect(time.bottom, lessThan(volume.top));
          }
          final focus = find.byKey(
            const ValueKey('expressive-preset-focused-sets'),
          );
          await tester.ensureVisible(focus);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(Card), findsNothing);
        },
      );
    }
  }
}

class _EmptyRepository extends AppRepository {}

class _SummaryRepository extends AppRepository {
  static final focus = <BodyPart, double>{
    BodyPart(1, 'Shoulders'): 1,
    BodyPart(2, 'Core'): 0.5,
    BodyPart(3, 'Triceps'): 1 / 6,
    BodyPart(4, 'Chest'): 0.1,
    BodyPart(5, 'Upper Back'): 0.05,
    BodyPart(6, 'Lower Back'): 0.03,
  };

  @override
  Future<Map<BodyPart, double>> computeBodyPartPercents(int defId) async =>
      focus;
}
