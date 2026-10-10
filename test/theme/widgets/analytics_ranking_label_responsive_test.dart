import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/muscle_ranking_screen.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Analytics ranking labels fit Pixel, compact, and large text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final width in [393.0, 320.0]) {
      for (final textScale in [1.0, 1.5]) {
        await tester.binding.setSurfaceSize(Size(width, 900));

        for (final muscleRanking in [false, true]) {
          final mode =
              '${muscleRanking ? 'muscle' : 'body part'} / $width dp / $textScale';
          final repository = _RankingLabelRepository();
          final page = muscleRanking
              ? MuscleRankingScreen(key: ValueKey(mode))
              : BodyPartRankingScreen(key: ValueKey(mode));
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: TextScaler.linear(textScale),
              ),
              child: MultiProvider(
                providers: [Provider<AppRepository>.value(value: repository)],
                child: MaterialApp(
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xFF345B50),
                    ),
                    extensions: const [
                      AppThemeIdentity(
                        family: AppThemeFamilyIdentity.expressivePreview,
                      ),
                    ],
                  ),
                  themeAnimationDuration: Duration.zero,
                  localizationsDelegates: tonosLocalizationDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: page,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final screen = find.byType(
            muscleRanking ? MuscleRankingScreen : BodyPartRankingScreen,
          );
          final strings = AppLocalizations.of(tester.element(screen));
          final field = find.byType(TextFormField);
          expect(field, findsOneWidget, reason: mode);
          expect(
            find.byType(SliverReorderableList),
            findsOneWidget,
            reason: mode,
          );
          final textField = tester.widget<TextField>(
            find.descendant(of: field, matching: find.byType(TextField)),
          );
          final entityName = find.text(muscleRanking ? 'Pectorals' : 'Chest');
          final rankSemantics = tester.getSemantics(field).getSemanticsData();
          expect(
            rankSemantics.hasFlag(SemanticsFlag.isTextField),
            isTrue,
            reason: '$mode rank remains an accessible text field',
          );
          if (muscleRanking) {
            // Muscle Ranking retains its current label-inside-field treatment.
            expect(
              textField.decoration?.labelText,
              strings.rankingsRank,
              reason: mode,
            );
            final label = find.descendant(
              of: field,
              matching: find.text(strings.rankingsRank),
            );
            expect(label, findsOneWidget, reason: mode);
            expect(
              rankSemantics.label.split('\n'),
              contains(strings.rankingsRank),
              reason: '$mode accessible field label includes Rank',
            );
            expect(
              tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
              isFalse,
              reason: '$mode should render the full Rank label',
            );
          } else {
            // Body Part Rankings places Rank as a contextual cue outside its
            // editable field, so the field itself remains label-free.
            expect(
              find.text(strings.settingsBodyPartRankings),
              findsOneWidget,
              reason: '$mode should show one page title',
            );
            expect(find.byType(AppBar), findsNothing, reason: mode);
            expect(
              find.text(strings.rankingsRank),
              findsOneWidget,
              reason: '$mode should show one contextual Rank cue',
            );
            expect(
              find.descendant(
                of: field,
                matching: find.text(strings.rankingsRank),
              ),
              findsNothing,
              reason: '$mode should not put Rank inside the field',
            );
            expect(
              textField.decoration?.labelText,
              isNull,
              reason: '$mode field should have no visible floating label',
            );
            expect(rankSemantics.label, contains('Chest'), reason: mode);
            expect(
              rankSemantics.label,
              contains(strings.rankingsRank),
              reason: mode,
            );
            expect(rankSemantics.label, contains('1'), reason: mode);
          }
          expect(
            tester.getRect(field).right,
            lessThanOrEqualTo(width),
            reason: '$mode rank field should remain within the viewport',
          );
          final rankingRow = find.ancestor(
            of: field,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.margin ==
                      EdgeInsets.only(bottom: muscleRanking ? 12 : 8),
            ),
          );
          expect(rankingRow, findsOneWidget, reason: mode);
          expect(
            tester.getSize(rankingRow).width,
            lessThanOrEqualTo(width - 32),
            reason: '$mode ranking row uses its finite sliver width',
          );
          if (width <= 360 || textScale > 1.15) {
            expect(entityName, findsOneWidget, reason: mode);
            expect(
              tester.getRect(field).top,
              greaterThanOrEqualTo(tester.getRect(entityName).bottom),
              reason: '$mode should stack the rank field below the name',
            );
          }
          expect(tester.takeException(), isNull, reason: mode);
        }
      }
    }
    await tester.binding.setSurfaceSize(null);
    semantics.dispose();
  });
}

class _RankingLabelRepository extends AppRepository {
  final BodyPart _bodyPart = BodyPart(1, 'Chest');
  final Muscle _muscle = Muscle(id: 2, name: 'Pectorals');

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [_bodyPart];

  @override
  Future<List<BodyPartRanking>> getAllBodyPartRanks() async => [
    BodyPartRanking(bodyPartId: _bodyPart.id, rank: 1),
  ];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [_muscle];

  @override
  Future<List<MuscleRanking>> getAllMuscleRanks() async => [
    MuscleRanking(muscleId: _muscle.id, rank: 1),
  ];
}
