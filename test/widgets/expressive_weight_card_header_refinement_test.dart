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
import 'package:env_test/widgets/weight_card.dart';

const _weightKey = ValueKey('expressive-weight-field');
const _repsKey = ValueKey('expressive-reps-field');

void main() {
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
      expect(
        headerWidget.margin?.resolve(TextDirection.ltr).bottom,
        6,
      );
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
      final firstRow = find.byType(AnimatedContainer).first;
      final firstRowSize = tester.getSize(firstRow);
      final firstRowWidget = tester.widget<AnimatedContainer>(firstRow);
      expect(
        firstRowWidget.margin,
        const EdgeInsets.symmetric(vertical: 6),
      );
      final weightHitRect = tester.getRect(weightHitRegion);
      final repsHitRect = tester.getRect(repsHitRegion);
      expect(
        weightHitRect.height,
        greaterThanOrEqualTo(firstRowSize.height - 13),
      );
      expect(
        repsHitRect.height,
        greaterThanOrEqualTo(firstRowSize.height - 13),
      );
      expect(firstRowSize.height, lessThanOrEqualTo(80));
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

      final details = find.bySemanticsLabel(localized.weightDetails);
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
      await tester.pumpWidget(_host(exercise, theme: theme));
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
      final rows = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
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
    final firstSetRow = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect(firstSetRow.duration, Duration.zero);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stacked field hit regions split the gap without growing rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_host(_exercise(), textScale: 2));
    await tester.pumpAndSettle();

    final localized = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );
    final firstRow = find.byType(AnimatedContainer).first;
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

    expect(tester.getSize(firstRow).height, closeTo(200, 2));
    expect(weightRect.top, lessThanOrEqualTo(firstRowRect.top + 7));
    expect(repsRect.bottom, greaterThanOrEqualTo(firstRowRect.bottom - 7));
    expect(weightRect.bottom, closeTo(repsRect.top, 1));
    expect(weightRect.overlaps(repsRect), isFalse);
    expect(
      weightRect.overlaps(tester.getRect(find.byType(Checkbox).first)),
      isFalse,
    );
    expect(
      repsRect.overlaps(
        tester.getRect(find.byTooltip(localized.weightRemoveSetTitle).first),
      ),
      isFalse,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Expressive Add Set keeps its target and trims only bottom space', (
    tester,
  ) async {
    var added = false;
    final exercise = _exercise();
    await tester.pumpWidget(
      _host(exercise, onSetAdded: () => added = true),
    );
    await tester.pumpAndSettle();

    final localized = AppLocalizations.of(
      tester.element(find.byType(WeightCard)),
    );
    final firstRow = find.byType(AnimatedContainer).first;
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
    expect(find.byType(AnimatedContainer), findsNWidgets(4));
    expect(tester.getSize(find.byType(AnimatedContainer).first), originalRowSize);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

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
