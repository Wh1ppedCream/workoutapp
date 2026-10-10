import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/muscle_ranking_screen.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Analytics Rank labels fit standard, compact, and 2x layouts', (
    tester,
  ) async {
    try {
      for (final width in [393.0, 320.0]) {
        for (final textScale in [1.0, 2.0]) {
          await tester.binding.setSurfaceSize(Size(width, 900));
          for (final muscleRanking in [false, true]) {
            final mode =
                '${muscleRanking ? 'muscle' : 'body part'} / $width dp / $textScale';
            await _pumpRankingScreen(
              tester,
              width: width,
              textScale: textScale,
              family: AppThemeFamilyIdentity.expressivePreview,
              muscleRanking: muscleRanking,
            );

            final screen = find.byType(
              muscleRanking ? MuscleRankingScreen : BodyPartRankingScreen,
            );
            final strings = AppLocalizations.of(tester.element(screen));
            final field = find.byType(TextFormField);
            expect(field, findsOneWidget, reason: mode);
            if (muscleRanking) {
              final label = find.descendant(
                of: field,
                matching: find.text(strings.rankingsRank),
              );
              expect(label, findsOneWidget, reason: mode);
              expect(
                tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
                isFalse,
                reason: '$mode should render the full Rank label',
              );
            } else {
              // Expressive Body Part Rankings uses the Rank cue beside the
              // field, keeping its visible outline label-free.
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
              final editableField = tester.widget<TextField>(
                find.descendant(of: field, matching: find.byType(TextField)),
              );
              expect(
                editableField.decoration?.labelText,
                isNull,
                reason: '$mode field should have no visible floating label',
              );
              final semantics = tester.getSemantics(field).getSemanticsData();
              expect(
                semantics.hasFlag(SemanticsFlag.isTextField),
                isTrue,
                reason: '$mode rank field remains editable to accessibility',
              );
              expect(
                semantics.hasAction(SemanticsAction.setText),
                isTrue,
                reason: '$mode rank field retains its text-edit action',
              );
              expect(semantics.label, contains('Chest'));
              expect(semantics.label, contains(strings.rankingsRank));
              expect(semantics.label, contains('1'));
            }
            expect(tester.takeException(), isNull, reason: mode);
          }
        }
      }
    } finally {
      await tester.binding.setSurfaceSize(null);
    }
  });

  testWidgets('Classic and Neo ranking rows keep their current field width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 900));
    try {
      for (final family in [
        AppThemeFamilyIdentity.classic,
        AppThemeFamilyIdentity.neoBrutalism,
      ]) {
        for (final muscleRanking in [false, true]) {
          final mode =
              '${family.name} / ${muscleRanking ? 'muscle' : 'body part'}';
          await _pumpRankingScreen(
            tester,
            width: 393,
            textScale: 1,
            family: family,
            muscleRanking: muscleRanking,
          );

          expect(
            find.byType(SettingsRankingTile),
            findsOneWidget,
            reason: mode,
          );
          final field = find.byType(TextFormField);
          expect(field, findsOneWidget, reason: mode);
          final fieldWidth = find.ancestor(
            of: field,
            matching: find.byWidgetPredicate(
              (widget) => widget is SizedBox && widget.width == 58,
            ),
          );
          expect(fieldWidth, findsOneWidget, reason: mode);
          expect(tester.takeException(), isNull, reason: mode);
        }
      }
    } finally {
      await tester.binding.setSurfaceSize(null);
    }
  });

  testWidgets('Expressive Body Part Rankings can reorder and exposes save', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 900));
    try {
      final repository = _RankingLabelRepository(includeSecondBodyPart: true);
      await _pumpRankingScreen(
        tester,
        width: 393,
        textScale: 1,
        family: AppThemeFamilyIdentity.expressivePreview,
        muscleRanking: false,
        repository: repository,
      );

      final chest = find.text('Chest');
      final back = find.text('Back');
      expect(chest, findsOneWidget);
      expect(back, findsOneWidget);
      expect(tester.getRect(chest).top, lessThan(tester.getRect(back).top));

      final dragHandle = find.byType(ReorderableDragStartListener).first;
      expect(dragHandle.hitTestable(), findsOneWidget);
      final dragStart = tester.getCenter(dragHandle);
      final targetRow = find.ancestor(
        of: back,
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.margin != null,
        ),
      );
      expect(targetRow, findsOneWidget);
      final targetY = tester.getRect(targetRow).bottom + 80;
      final gesture = await tester.startGesture(dragStart);
      await tester.pump();
      await gesture.moveBy(const Offset(0, 24));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(Offset(dragStart.dx, targetY));
      await tester.pump(const Duration(milliseconds: 350));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.getRect(back).top, lessThan(tester.getRect(chest).top));
      final strings = AppLocalizations.of(
        tester.element(find.byType(BodyPartRankingScreen)),
      );
      final save = find.text(strings.rankingsSave);
      expect(save, findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repository.savedBodyPartRanks, {1: 2, 3: 1});
      expect(tester.takeException(), isNull);
    } finally {
      await tester.binding.setSurfaceSize(null);
    }
  });

  testWidgets(
    'Expressive Body Part rows stay compact, tappable, and readable in both modes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 900));
      try {
        for (final brightness in Brightness.values) {
          final repository = _RankingLabelRepository(
            includeSecondBodyPart: true,
          );
          await _pumpRankingScreen(
            tester,
            width: 393,
            textScale: 1.15,
            family: AppThemeFamilyIdentity.expressivePreview,
            muscleRanking: false,
            repository: repository,
            brightness: brightness,
          );

          final screen = find.byType(BodyPartRankingScreen);
          final strings = AppLocalizations.of(tester.element(screen));
          final rankCue = find.text(strings.rankingsRank);
          expect(rankCue, findsOneWidget, reason: brightness.name);
          expect(
            find.text(
              strings.rankingsHero(strings.volumeBodyParts.toLowerCase()),
            ),
            findsOneWidget,
            reason: '${brightness.name} description names body parts',
          );
          final cueColor = tester.widget<Text>(rankCue).style!.color!;
          final destination = Theme.of(tester.element(rankCue))
              .extension<AppExpressiveDestinationTokens>()!;
          final paintedCue = Color.alphaBlend(cueColor, destination.pageCanvas);
          expect(
            _contrastRatio(paintedCue, destination.pageCanvas),
            greaterThanOrEqualTo(4.5),
            reason: '${brightness.name} contextual Rank cue contrast',
          );

          final chest = find.text('Chest');
          final back = find.text('Back');
          final chestRow = _expressiveRankingRow(chest);
          final backRow = _expressiveRankingRow(back);
          final chestMargin = tester
              .widget<Container>(chestRow)
              .margin!
              .resolve(TextDirection.ltr);
          final chestRect = tester.getRect(chestRow);
          final backRect = tester.getRect(backRow);
          final interRowGap =
              backRect.top - (chestRect.bottom - chestMargin.bottom);
          expect(
            interRowGap,
            lessThanOrEqualTo(8),
            reason: '${brightness.name} compact inter-row spacing',
          );
          expect(
            tester.getSize(chestRow).height - chestMargin.vertical,
            closeTo(56, 0.1),
            reason: '${brightness.name} normal-width row remains 56dp tall',
          );

          final fields = find.byType(TextFormField);
          final dragHandles = find.byType(ReorderableDragStartListener);
          expect(fields, findsNWidgets(2), reason: brightness.name);
          expect(dragHandles, findsNWidgets(2), reason: brightness.name);
          for (var index = 0; index < 2; index++) {
            final fieldSize = tester.getSize(fields.at(index));
            final paintedBox = find.byKey(
              ValueKey('rank-painted-box-${index + 1}'),
            );
            final row = _expressiveRankingRow(index == 0 ? chest : back);
            final rowRect = tester.getRect(row);
            final rowMargin = tester
                .widget<Container>(row)
                .margin!
                .resolve(TextDirection.ltr);
            final fieldRect = tester.getRect(paintedBox);
            final paintedRowCenterY =
                (rowRect.top + rowRect.bottom - rowMargin.bottom) / 2;
            expect(fieldRect.width, 80, reason: brightness.name);
            expect(fieldRect.height, 52, reason: brightness.name);
            expect(
              fieldRect.center.dy,
              closeTo(paintedRowCenterY, 0.5),
              reason:
                  '${brightness.name} visible Rank box is vertically centered',
            );
            if (index == 0) {
              expect(
                fieldRect.right,
                closeTo(tester.getRect(rankCue).right, 1),
                reason: '${brightness.name} Rank heading aligns with box',
              );
            }
            expect(fieldSize.width, greaterThanOrEqualTo(48));
            expect(fieldSize.height, greaterThanOrEqualTo(48));
            final handleSize = tester.getSize(dragHandles.at(index));
            expect(handleSize.width, greaterThanOrEqualTo(48));
            expect(handleSize.height, greaterThanOrEqualTo(48));
          }
          expect(tester.takeException(), isNull, reason: brightness.name);
        }
      } finally {
        await tester.binding.setSurfaceSize(null);
      }
    },
  );
}

Finder _expressiveRankingRow(Finder name) => find.ancestor(
  of: name,
  matching: find.byWidgetPredicate(
    (widget) => widget is Container && widget.margin != null,
  ),
);

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Future<void> _pumpRankingScreen(
  WidgetTester tester, {
  required double width,
  required double textScale,
  required AppThemeFamilyIdentity family,
  required bool muscleRanking,
  _RankingLabelRepository? repository,
  Brightness brightness = Brightness.light,
}) async {
  repository ??= _RankingLabelRepository();
  final page = muscleRanking
      ? const MuscleRankingScreen()
      : const BodyPartRankingScreen();
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
              brightness: brightness,
            ),
            extensions: [AppThemeIdentity(family: family)],
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
}

class _RankingLabelRepository extends AppRepository {
  _RankingLabelRepository({this.includeSecondBodyPart = false});

  final bool includeSecondBodyPart;
  final BodyPart _bodyPart = BodyPart(1, 'Chest');
  final BodyPart _secondBodyPart = BodyPart(3, 'Back');
  final Muscle _muscle = Muscle(id: 2, name: 'Pectorals');
  final Map<int, int> savedBodyPartRanks = {};

  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [
    _bodyPart,
    if (includeSecondBodyPart) _secondBodyPart,
  ];

  @override
  Future<List<BodyPartRanking>> getAllBodyPartRanks() async => [
    BodyPartRanking(bodyPartId: _bodyPart.id, rank: 1),
    if (includeSecondBodyPart)
      BodyPartRanking(bodyPartId: _secondBodyPart.id, rank: 2),
  ];

  @override
  Future<int> setBodyPartRank(int bodypartId, int rank) async {
    savedBodyPartRanks[bodypartId] = rank;
    return savedBodyPartRanks.length;
  }

  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [_muscle];

  @override
  Future<List<MuscleRanking>> getAllMuscleRanks() async => [
    MuscleRanking(muscleId: _muscle.id, rank: 1),
  ];
}
