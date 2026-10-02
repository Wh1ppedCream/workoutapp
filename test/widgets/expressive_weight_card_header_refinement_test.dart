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
      expect(card.color!.a, closeTo(surfaces.workoutCardCompleteFill, 0.01));
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
  bool disableAnimations = false,
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
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
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
