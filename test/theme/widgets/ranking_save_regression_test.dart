import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_ranking_screen.dart';
import 'package:env_test/screens/profile/settings/muscle_ranking_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class _Repository extends AppRepository {
  int? savedRank;
  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [
    BodyPart(1, 'Chest'),
  ];
  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    Muscle(id: 2, name: 'Pectorals'),
  ];
  @override
  Future<List<BodyPartRanking>> getAllBodyPartRanks() async => [
    BodyPartRanking(bodyPartId: 1, rank: 1),
  ];
  @override
  Future<List<MuscleRanking>> getAllMuscleRanks() async => [
    MuscleRanking(muscleId: 2, rank: 1),
  ];
  @override
  Future<int> setBodyPartRank(int bodypartId, int rank) async {
    savedRank = rank;
    return 1;
  }

  @override
  Future<int> setMuscleRank(int muscleId, int rank) async {
    savedRank = rank;
    return 1;
  }
}

void main() {
  for (final muscle in [false, true]) {
    testWidgets('Save must include unsubmitted rank text muscle=$muscle', (
      tester,
    ) async {
      final repository = _Repository();
      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: repository,
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: muscle
                ? const MuscleRankingScreen()
                : const BodyPartRankingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final field = find.byType(TextFormField);
      await tester.enterText(field, '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '3');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(
        repository.savedRank,
        3,
        reason: 'The visible field says 3 when Save is tapped',
      );
    });
  }
}
