import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/muscle_ranking_screen.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/expressive_theme.dart';
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
      for (final textScale in [1.0, 1.5, 2.0]) {
        await tester.binding.setSurfaceSize(Size(width, 900));

        for (final muscleRanking in [false, true]) {
          final mode =
              '${muscleRanking ? 'muscle' : 'body part'} / $width dp / $textScale';
          final repository = _RankingLabelRepository();
          final page = muscleRanking
              ? MuscleRankingScreen(key: ValueKey(mode))
              : BodyPartRankingScreen(key: ValueKey(mode));
          await tester.pumpWidget(
            MultiProvider(
              providers: [Provider<AppRepository>.value(value: repository)],
              child: MaterialApp(
                theme: ExpressiveThemeDefinition.light(),
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: tonosLocalizationDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: page,
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
            rankSemantics.flagsCollection.isTextField,
            isTrue,
            reason: '$mode rank remains an accessible text field',
          );
          if (muscleRanking) {
            expect(
              find.text(strings.settingsMuscleRankings),
              findsOneWidget,
              reason: mode,
            );
            expect(find.byType(AppBar), findsNothing, reason: mode);
            expect(
              find.text(strings.rankingsRank),
              findsOneWidget,
              reason: '$mode should show one contextual Rank cue',
            );
            expect(
              textField.decoration?.labelText,
              isNull,
              reason: '$mode field should not repeat the Rank label',
            );
            expect(rankSemantics.label, contains('Pectorals'), reason: mode);
            expect(
              rankSemantics.label,
              contains(strings.rankingsRank),
              reason: mode,
            );
            expect(
              rankSemantics.value,
              '1',
              reason: '$mode exposes rank value',
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
                  widget.margin == const EdgeInsets.only(bottom: 8),
            ),
          );
          expect(rankingRow, findsOneWidget, reason: mode);
          expect(
            tester.getSize(rankingRow).width,
            lessThanOrEqualTo(width - 32),
            reason: '$mode ranking row uses its finite sliver width',
          );
          expect(entityName, findsOneWidget, reason: mode);
          expect(
            tester.getRect(field).overlaps(tester.getRect(entityName)),
            isFalse,
            reason: '$mode name and rank input must remain separate',
          );
          expect(tester.takeException(), isNull, reason: mode);
        }
      }
    }
    await tester.binding.setSurfaceSize(null);
    semantics.dispose();
  });

  testWidgets('Expressive muscle names wrap to two lines at Pixel width', (
    tester,
  ) async {
    const width = 393.0;
    await tester.binding.setSurfaceSize(const Size(width, 900));
    final repository = _RankingLabelRepository(includeLongMuscle: true);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(width, 900),
          textScaler: TextScaler.linear(1),
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
            home: const MuscleRankingScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final longName = find.text('Transverse Abdominis');
    expect(longName, findsOneWidget);
    final nameWidget = tester.widget<Text>(longName);
    expect(nameWidget.maxLines, 2);
    final paragraph = tester.renderObject<RenderParagraph>(longName);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}

class _RankingLabelRepository extends AppRepository {
  _RankingLabelRepository({this.includeLongMuscle = false});

  final bool includeLongMuscle;
  final BodyPart _bodyPart = BodyPart(1, 'Chest');
  final Muscle _muscle = Muscle(id: 2, name: 'Pectorals');
  final Muscle _longMuscle = Muscle(id: 3, name: 'Transverse Abdominis');

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [_bodyPart];

  @override
  Future<List<BodyPartRanking>> getAllBodyPartRanks() async => [
    BodyPartRanking(bodyPartId: _bodyPart.id, rank: 1),
  ];

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    _muscle,
    if (includeLongMuscle) _longMuscle,
  ];

  @override
  Future<List<MuscleRanking>> getAllMuscleRanks() async => [
    MuscleRanking(muscleId: _muscle.id, rank: 1),
    if (includeLongMuscle) MuscleRanking(muscleId: _longMuscle.id, rank: 2),
  ];
}
