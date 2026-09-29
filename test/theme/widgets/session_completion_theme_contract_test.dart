import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/session_complete_sheet.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.dark
              ? AppThemeFactory.dark(family)
              : AppThemeFactory.light(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets('$mode completion presentation resolves token recipes', (
        tester,
      ) async {
        late BuildContext context;
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (buildContext) {
                context = buildContext;
                return SingleChildScrollView(
                  child: WorkoutCompletionPresentation(
                    exercises: [_exercise()],
                    totalSets: 2,
                    duration: '8 min',
                    volume: '120 lbs',
                    onDone: () {},
                    showHandle: false,
                  ),
                );
              },
            ),
          ),
        );

        final isNeo = context.usesNeoPresentation;
        final surfaces = context.surfaceTokens;
        final shapes = context.shapeTokens;
        final semantic = context.semanticColors;
        final accent = _exerciseAccent('Bench Press', theme.colorScheme);
        final cardFill =
            isNeo
                ? surfaces.card
                : accent.withValues(alpha: surfaces.completionExerciseFill);
        final cardBorder =
            isNeo
                ? tonosOutlineForSurface(context, surfaces.card)
                : accent.withValues(alpha: surfaces.completionExerciseBorder);
        final cardFinder = find.byType(WorkoutCompletionExerciseCard);
        final card = tester.widget<Container>(
          find
              .descendant(of: cardFinder, matching: find.byType(Container))
              .first,
        );
        final cardDecoration = card.decoration! as BoxDecoration;
        expect(cardDecoration.color, cardFill);
        expect(
          cardDecoration.borderRadius,
          isNeo ? shapes.compact : shapes.workoutSection,
        );
        expect(cardDecoration.border!.top.color, cardBorder);
        expect(
          cardDecoration.border!.top.width,
          isNeo ? shapes.outlineWidth : 1,
        );

        final estimatedMaxTexts = find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data ?? '').startsWith('ERM='),
        );
        expect(estimatedMaxTexts, findsNWidgets(2));
        for (final text in tester.widgetList<Text>(estimatedMaxTexts)) {
          expect(text.style!.fontSize, 12);
          expect(text.style!.fontStyle, FontStyle.italic);
          expect(
            text.style!.color,
            isNeo
                ? tonosSecondaryForegroundForSurface(context, surfaces.card)
                : isNull,
          );
        }

        final dividers = find.descendant(
          of: cardFinder,
          matching: find.byType(Divider),
        );
        expect(dividers, isNeo ? findsOneWidget : findsNothing);
        if (isNeo) {
          expect(
            tester.widget<Divider>(dividers).color,
            tonosSecondaryForegroundForSurface(
              context,
              surfaces.card,
            ).withValues(alpha: 0.35),
          );
        }

        final setIndicatorFinder = find.descendant(
          of: cardFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
          ),
        );
        expect(setIndicatorFinder, findsNWidgets(2));
        final indicator = tester.widget<Container>(setIndicatorFinder.first);
        final indicatorDecoration = indicator.decoration! as BoxDecoration;
        expect(
          indicatorDecoration.color,
          accent.withValues(alpha: surfaces.completionSetFill),
        );
        expect(
          indicatorDecoration.border!.top.color,
          isNeo ? cardBorder : accent,
        );

        final presentationFinder = find.byType(WorkoutCompletionPresentation);
        final headerFinder = find.descendant(
          of: presentationFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    semantic.completionAccent,
          ),
        );
        expect(headerFinder, isNeo ? findsOneWidget : findsNothing);
        if (isNeo) {
          final header = tester.widget<Container>(headerFinder);
          final headerDecoration = header.decoration! as BoxDecoration;
          expect(headerDecoration.color, semantic.completionAccent);
          expect(
            headerDecoration.border!.top.color,
            tonosOutlineForSurface(context, semantic.completionAccent),
          );
          expect(headerDecoration.border!.top.width, shapes.outlineWidth);
          expect(headerDecoration.borderRadius, shapes.control);
        }
        final title = tester.widget<Text>(
          find.text(AppLocalizations.of(context).sessionCompleteTitle),
        );
        expect(
          title.style!.color,
          isNeo ? semantic.onWorkoutContainer : semantic.completionAccent,
        );

        final metricFinder = find.descendant(
          of: presentationFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.constraints?.minHeight == 70,
          ),
        );
        expect(metricFinder, findsNWidgets(4));
        final metrics = [
          context.dataVisualizationTokens.sessionExercises,
          context.dataVisualizationTokens.sessionSets,
          context.dataVisualizationTokens.sessionDuration,
          context.dataVisualizationTokens.sessionVolume,
        ];
        for (var index = 0; index < metrics.length; index++) {
          final metric = tester.widget<Container>(metricFinder.at(index));
          final decoration = metric.decoration! as BoxDecoration;
          final expectedFill =
              isNeo
                  ? surfaces.card
                  : metrics[index].withValues(
                    alpha: surfaces.completionMetricFill,
                  );
          final expectedBorder =
              isNeo
                  ? tonosOutlineForSurface(context, surfaces.card)
                  : metrics[index].withValues(
                    alpha: surfaces.completionMetricBorder,
                  );
          expect(decoration.color, expectedFill);
          expect(decoration.borderRadius, shapes.control);
          expect(decoration.border!.top.color, expectedBorder);
          expect(decoration.border!.top.width, isNeo ? shapes.outlineWidth : 1);
          final icon = tester.widget<Icon>(
            find
                .descendant(
                  of: metricFinder.at(index),
                  matching: find.byType(Icon),
                )
                .first,
          );
          expect(
            icon.color,
            isNeo
                ? tonosForegroundForSurface(
                  context,
                  surfaces.card,
                  parentSurface: surfaces.sheet,
                )
                : metrics[index],
          );
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('$mode completion error ink stays family-scoped', (
        tester,
      ) async {
        late BuildContext context;
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (buildContext) {
                context = buildContext;
                return WorkoutCompletionStatus.error(onClose: () {});
              },
            ),
          ),
        );
        final errorText = tester.widget<Text>(
          find.text(AppLocalizations.of(context).sessionCompleteLoadError),
        );
        expect(
          errorText.style?.color,
          context.surfaceDecorationTokens.sheet.outlined
              ? tonosForegroundForSurface(context, context.surfaceTokens.sheet)
              : isNull,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

WorkoutCompletionExercise _exercise() => WorkoutCompletionExercise(
  exercise: WeightExercise(
    name: 'Bench Press',
    equipment: 'Barbell',
    sets: [ExerciseSet(weight: 60, reps: 8), ExerciseSet(weight: 60, reps: 7)],
  ),
  weightUnit: WeightUnit.pounds,
  badges: const WorkoutExerciseRecordBadges(isFirstRecord: false),
);

Color _exerciseAccent(String name, ColorScheme colorScheme) {
  final palette = [
    colorScheme.primary,
    colorScheme.tertiary,
    colorScheme.secondary,
    colorScheme.error,
  ];
  final hash = name.codeUnits.fold<int>(
    0,
    (value, codeUnit) => value + codeUnit,
  );
  return palette[hash % palette.length];
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
