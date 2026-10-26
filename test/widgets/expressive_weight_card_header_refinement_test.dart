import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/widgets/tonos_expressive_workout_shapes.dart';
import 'package:env_test/widgets/weight_card.dart';

const _weightKey = ValueKey('expressive-weight-field');
const _repsKey = ValueKey('expressive-reps-field');

void main() {
  for (final brightness in Brightness.values) {
    for (final layout in [
      (width: 320.0, scale: 1.0),
      (width: 411.0, scale: 1.15),
      (width: 320.0, scale: 2.0),
    ]) {
      testWidgets(
        'Inset workout header preserves set geometry and controls ${brightness.name} $layout',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(layout.width, 1100));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final theme = brightness == Brightness.light
              ? ExpressiveThemeDefinition.light()
              : ExpressiveThemeDefinition.dark();
          final exercise = _exercise();
          var detailsTapped = 0;
          Widget host({required bool inset}) => _host(
            exercise,
            theme: theme,
            textScale: layout.scale,
            insetWorkoutHeader: inset,
            onDetails: () => detailsTapped++,
          );
          await tester.pumpWidget(host(inset: false));
          await tester.pumpAndSettle();
          final card = find.descendant(
            of: find.byType(WeightCard),
            matching: find.byType(Card),
          );
          final originalCard = tester.widget<Card>(card);
          final originalHeight = tester.getSize(card).height;
          final originalField = tester.getRect(find.byKey(_weightKey));
          final titleLeft = tester.getTopLeft(find.text('Back Squat')).dx;
          Finder header() => find
              .descendant(
                of: find.byType(WeightCard),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration! as BoxDecoration).borderRadius !=
                          null,
                ),
              )
              .first;
          final originalHeaderColor =
              (tester.widget<Container>(header()).decoration! as BoxDecoration)
                  .color;

          await tester.pumpWidget(host(inset: true));
          await tester.pumpAndSettle();
          final currentCard = tester.widget<Card>(card);
          expect(currentCard.shape, originalCard.shape);
          expect(currentCard.color, originalCard.color);
          expect(currentCard.elevation, originalCard.elevation);
          expect(tester.getSize(card).height, closeTo(originalHeight, .01));
          expect(tester.getRect(find.byKey(_weightKey)), originalField);
          expect(tester.getTopLeft(find.text('Back Squat')).dx, titleLeft);
          final decoration =
              tester.widget<Container>(header()).decoration! as BoxDecoration;
          expect(decoration.color, originalHeaderColor);
          expect(decoration.border!.top.color.a, greaterThan(0));

          final strings = AppLocalizations.of(
            tester.element(find.byType(WeightCard)),
          );
          await tester.tap(find.byTooltip(strings.weightCollapseSets));
          await tester.pumpAndSettle();
          expect(find.byKey(_weightKey), findsNothing);
          expect(find.text(strings.weightCardSetsDone(0, 3)), findsOneWidget);
          await tester.tap(_detailsButton(strings.weightDetails));
          await tester.pump();
          expect(detailsTapped, 1);
          expect(find.byKey(_weightKey), findsNothing);
          await tester.tap(find.byTooltip(strings.weightExpandSets));
          await tester.pumpAndSettle();
          expect(tester.getRect(find.byKey(_weightKey)), originalField);
          expect(exercise.completedParents, isEmpty);
          expect(exercise.sets.first.weight, 100);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Expressive header fits compact width and keeps field focus local',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final exercise = _exercise();
      final weightFocus = FocusNode(debugLabel: 'weight test');
      final repsFocus = FocusNode(debugLabel: 'reps test');
      addTearDown(weightFocus.dispose);
      addTearDown(repsFocus.dispose);
      var detailsTapped = false;

      await tester.pumpWidget(
        _host(
          exercise,
          weightFocus: weightFocus,
          repsFocus: repsFocus,
          onDetails: () => detailsTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(WeightCard);
      final header = find
          .descendant(
            of: card,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).borderRadius != null,
            ),
          )
          .first;
      expect(tester.getRect(header).right, lessThanOrEqualTo(320));
      expect(tester.getSize(header).height, greaterThanOrEqualTo(56));
      expect(tester.takeException(), isNull);

      final localized = AppLocalizations.of(tester.element(card));
      final weightLabel = find.text(localized.weightLabel('lbs')).first;
      final repsLabel = find.text(localized.weightReps).first;
      expect(find.text(localized.weightLabel('lbs')), findsNWidgets(3));
      expect(find.text(localized.weightReps), findsNWidgets(3));
      final firstDivider = find.byType(Divider).first;
      final headerWidget = tester.widget<Container>(header);
      final headerBandBottom =
          tester.getRect(header).bottom -
          (headerWidget.margin?.resolve(TextDirection.ltr).bottom ?? 0);
      expect(headerWidget.margin?.resolve(TextDirection.ltr).bottom, 6);
      expect(
        tester.getRect(firstDivider).top,
        closeTo(headerBandBottom + 6, 1),
      );
      expect(tester.widget<Divider>(firstDivider).height, 1);
      final weightHitRegion = find
          .ancestor(of: weightLabel, matching: find.byType(GestureDetector))
          .first;
      final repsHitRegion = find
          .ancestor(of: repsLabel, matching: find.byType(GestureDetector))
          .first;
      expect(
        tester.getRect(weightHitRegion).overlaps(tester.getRect(repsHitRegion)),
        isFalse,
      );
      final firstRow = _setRows().first;
      final firstRowSize = tester.getSize(firstRow);
      final firstRowWidget = tester.widget<AnimatedContainer>(firstRow);
      expect(firstRowWidget.margin, const EdgeInsets.symmetric(vertical: 6));
      final weightHitRect = tester.getRect(weightHitRegion);
      final repsHitRect = tester.getRect(repsHitRegion);
      expect(weightHitRect.height, greaterThanOrEqualTo(48));
      expect(repsHitRect.height, greaterThanOrEqualTo(48));
      // At compact width the weight label wraps to two lines. Keep that
      // content-driven increase bounded while preserving its full label.
      expect(firstRowSize.height, closeTo(87, 2));
      expect(
        weightHitRect.overlaps(tester.getRect(find.byType(Checkbox).first)),
        isFalse,
      );
      expect(
        repsHitRect.overlaps(
          tester.getRect(find.byTooltip(localized.weightRemoveSetTitle).first),
        ),
        isFalse,
      );

      final outerCard = find.descendant(of: card, matching: find.byType(Card));
      await tester.tap(find.byTooltip(localized.weightCollapseSets));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(
        tester.getRect(outerCard).bottom - headerBandBottom,
        closeTo(24, 1),
      );
      await tester.tap(find.byTooltip(localized.weightExpandSets));
      await tester.pumpAndSettle();

      await tester.tap(weightLabel);
      await tester.pump();
      expect(weightFocus.hasFocus, isTrue);
      expect(repsFocus.hasFocus, isFalse);
      await tester.tap(repsLabel);
      await tester.pump();
      expect(repsFocus.hasFocus, isTrue);
      expect(weightFocus.hasFocus, isFalse);

      expect(find.byKey(_weightKey), findsOneWidget);
      expect(find.byKey(_repsKey), findsOneWidget);
      expect(
        tester
            .getSize(
              find
                  .byWidgetPredicate(
                    (widget) => widget is SizedBox && widget.width == 56,
                  )
                  .first,
            )
            .width,
        56,
      );

      final details = _detailsButton(localized.weightDetails);
      expect(details, findsOneWidget);
      await tester.tap(details);
      await tester.pump();
      expect(detailsTapped, isTrue);

      final menu = find.byTooltip(
        MaterialLocalizations.of(tester.element(card)).showMenuTooltip,
      );
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      expect(find.text(localized.weightRemoveExerciseTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('completed Expressive sets use semantic tonal roles', (
    tester,
  ) async {
    final themes = <ThemeData>[
      ExpressiveThemeDefinition.light(),
      ExpressiveThemeDefinition.dark(),
    ];

    for (final theme in themes) {
      final exercise = _exercise(completed: true);
      await tester.pumpWidget(
        _host(exercise, theme: theme, insetWorkoutHeader: true),
      );
      await tester.pumpAndSettle();

      final semantic = theme.extension<AppSemanticColors>()!;
      final surfaces = theme.extension<AppSurfaceTokens>()!;
      final completedHeader = semantic.workoutExerciseCompleted;

      final card = tester.widget<Card>(
        find.descendant(
          of: find.byType(WeightCard),
          matching: find.byType(Card),
        ),
      );
      expect(
        card.color,
        theme.brightness == Brightness.light
            ? surfaces.workoutCardCompleteColor
            : semantic.workoutExerciseCompleted.withValues(
                alpha: surfaces.workoutCardCompleteFill,
              ),
      );
      expect(find.byType(TextFormField), findsNothing);

      final header = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color == completedHeader,
      );
      expect(header, findsOneWidget);
      final localized = AppLocalizations.of(
        tester.element(find.byType(WeightCard)),
      );
      final headerTextColor = tester
          .widget<Text>(find.text('Back Squat'))
          .style!
          .color!;
      expect(
        _contrastRatio(headerTextColor, completedHeader),
        greaterThanOrEqualTo(4.5),
      );
      final menuIconColor = tester
          .widget<Icon>(find.byIcon(Icons.more_vert))
          .color!;
      expect(
        _contrastRatio(menuIconColor, completedHeader),
        greaterThanOrEqualTo(4.5),
      );
      final doneLabel = find.text(localized.weightCardSetsDone(3, 3));
      expect(doneLabel, findsOneWidget);
      expect(
        _contrastRatio(
          tester.widget<Text>(doneLabel).style!.color!,
          completedHeader,
        ),
        greaterThanOrEqualTo(4.5),
      );

      await tester.tap(find.byTooltip(localized.weightExpandSets));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNWidgets(3));
      final rows = tester.widgetList<AnimatedContainer>(_setRows());
      expect(rows, hasLength(3));
      final completedRowColor =
          (rows.first.decoration! as BoxDecoration).color!;
      expect(
        completedRowColor.a,
        closeTo(surfaces.workoutSetCompleteFill, 0.01),
      );
      final setText = tester.widget<Text>(
        find.text(localized.weightSetLabel(1)),
      );
      final rowOnSurface = theme.colorScheme.onSurface;
      final rowSurface = Color.alphaBlend(
        completedRowColor,
        Color.alphaBlend(card.color!, theme.colorScheme.surface),
      );
      expect(
        _contrastRatio(rowOnSurface, rowSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(setText.style!.color, rowOnSurface);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('completion tint is immediate with reduced motion', (
    tester,
  ) async {
    final exercise = _exercise();
    await tester.pumpWidget(_host(exercise, disableAnimations: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(exercise.completedParents, <int>{0});
    final firstSetRow = tester.widget<AnimatedContainer>(_setRows().first);
    expect(firstSetRow.duration, Duration.zero);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('large-text set fields keep their normal-width row geometry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_host(_exercise(), textScale: 2));
    await tester.pumpAndSettle();

    final firstRow = _setRows().first;
    expect(tester.getSize(firstRow).height, closeTo(224, 5));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('two-column field hit regions preserve labels at 2x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_host(_exercise(), textScale: 2));
    await tester.pumpAndSettle();

    final localized = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );
    final firstRow = _setRows().first;
    final firstRowRect = tester.getRect(firstRow);
    final weightHitRegion = find
        .ancestor(
          of: find.text(localized.weightLabel('lbs')).first,
          matching: find.byType(GestureDetector),
        )
        .first;
    final repsHitRegion = find
        .ancestor(
          of: find.text(localized.weightReps).first,
          matching: find.byType(GestureDetector),
        )
        .first;
    final weightRect = tester.getRect(weightHitRegion);
    final repsRect = tester.getRect(repsHitRegion);

    // Compact large text puts set actions above two equal field columns.
    final rowHeight = tester.getSize(firstRow).height;
    expect(rowHeight, closeTo(219, 2));
    final checkboxRect = tester.getRect(find.byType(Checkbox).first);
    final removeRect = tester.getRect(
      find.byTooltip(localized.weightRemoveSetTitle).first,
    );
    expect(weightRect.height, greaterThanOrEqualTo(48));
    expect(repsRect.height, greaterThanOrEqualTo(48));
    expect(weightRect.top, greaterThanOrEqualTo(checkboxRect.bottom));
    expect(repsRect.bottom, lessThanOrEqualTo(firstRowRect.bottom));
    expect(weightRect.right, lessThanOrEqualTo(repsRect.left));
    expect(weightRect.overlaps(repsRect), isFalse);
    expect(weightRect.overlaps(checkboxRect), isFalse);
    expect(repsRect.overlaps(removeRect), isFalse);
    for (final labelText in [
      localized.weightLabel('lbs'),
      localized.weightReps,
    ]) {
      final labelFinder = find.text(labelText).first;
      final label = tester.widget<Text>(labelFinder);
      expect(label.maxLines, isNull);
      expect(label.overflow, isNull);
      expect(
        tester.renderObject<RenderParagraph>(labelFinder).didExceedMaxLines,
        isFalse,
        reason:
            '$labelText should wrap only at word boundaries without clipping',
      );
    }
    expect(
      weightRect.overlaps(removeRect),
      isFalse,
      reason: 'the remove action stays clear of both field columns',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Expressive Add Set keeps its target and trims only bottom space',
    (tester) async {
      var added = false;
      final exercise = _exercise();
      await tester.pumpWidget(_host(exercise, onSetAdded: () => added = true));
      await tester.pumpAndSettle();

      final localized = AppLocalizations.of(
        tester.element(find.byType(WeightCard)),
      );
      final firstRow = _setRows().first;
      final originalRowSize = tester.getSize(firstRow);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        findsOneWidget,
      );

      final addSet = find.widgetWithText(TextButton, localized.weightAddSet);
      expect(tester.getSize(addSet).height, greaterThanOrEqualTo(48));
      await tester.tap(addSet);
      await tester.pumpAndSettle();

      expect(added, isTrue);
      expect(_setRows(), findsNWidgets(4));
      expect(tester.getSize(_setRows().first), originalRowSize);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

Finder _setRows() => find.byWidgetPredicate(
  (widget) =>
      widget is AnimatedContainer &&
      widget.decoration is BoxDecoration &&
      (widget.decoration! as BoxDecoration).borderRadius ==
          TonosExpressiveWorkoutShapes.setRow,
);

Finder _detailsButton(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

WeightExercise _exercise({bool completed = false}) => WeightExercise(
  name: 'Back Squat',
  equipment: 'Barbell',
  sets: List.generate(
    3,
    (index) => ExerciseSet(weight: 100 - index * 5, reps: 5 + index),
  ),
  completedParents: completed ? <int>{0, 1, 2} : <int>{},
);

Widget _host(
  WeightExercise exercise, {
  ThemeData? theme,
  FocusNode? weightFocus,
  FocusNode? repsFocus,
  VoidCallback? onDetails,
  VoidCallback? onSetAdded,
  bool disableAnimations = false,
  bool insetWorkoutHeader = false,
  double textScale = 1,
}) => Provider<AppRepository>.value(
  value: _EmptyRepository(),
  child: MaterialApp(
    theme: theme ?? ExpressiveThemeDefinition.light(),
    themeAnimationDuration: Duration.zero,
    locale: const Locale('en'),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: SingleChildScrollView(
            child: WeightCard(
              exercise: exercise,
              previewWeightUnit: WeightUnit.pounds,
              expressiveWorkoutPresentation: true,
              expressiveInsetExerciseHeader: insetWorkoutHeader,
              animateExpansion: true,
              firstSetWeightKey: _weightKey,
              firstSetRepsKey: _repsKey,
              firstSetWeightFocusNode: weightFocus,
              firstSetRepsFocusNode: repsFocus,
              onDetails: onDetails,
              onSetAdded: onSetAdded,
            ),
          ),
        ),
      ),
    ),
  ),
);

class _EmptyRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<int> findOrCreateExerciseDefinition(
    String name,
    String equipmentName,
  ) async => 1;

  @override
  Future<ExerciseDefinition?> fetchDefinitionById(int id) async => null;
}
