import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/bodypart_muscle_mapping_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/widgets/workout_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class _Repository extends AppRepository {
  bool hold = false;
  final pending = <int, Completer<List<MuscleBodyPart>>>{};
  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [
    BodyPart(1, 'Chest'),
    BodyPart(2, 'Shoulders'),
  ];
  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    Muscle(id: 1, name: 'Pectorals'),
    Muscle(id: 2, name: 'Deltoids'),
  ];
  @override
  Future<List<MuscleBodyPart>> fetchMusclesForBodyPart(int id) {
    if (!hold) {
      return Future.value([MuscleBodyPart(muscleId: 1, bodyPartId: 1)]);
    }
    return (pending[id] = Completer<List<MuscleBodyPart>>()).future;
  }
}

Widget _app(Widget home) => MaterialApp(
  theme: ExpressiveThemeDefinition.light(),
  localizationsDelegates: tonosLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('mapping must discard a previous selection response', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      Provider<AppRepository>.value(
        value: repository,
        child: _app(const BodyPartMuscleMappingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    repository.hold = true;
    final choice = find.byKey(const ValueKey('mapping-body-part-choice'));
    await tester.tap(choice);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shoulders').last);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
      isNull,
    );
    await tester.tap(choice);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Chest').last);
    await tester.pump(const Duration(milliseconds: 300));
    repository.pending[1]!.complete([
      MuscleBodyPart(muscleId: 1, bodyPartId: 1),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Pectorals'), findsOneWidget);
    repository.pending[2]!.complete([
      MuscleBodyPart(muscleId: 2, bodyPartId: 2),
    ]);
    await tester.pumpAndSettle();
    expect(
      find.text('Pectorals'),
      findsOneWidget,
      reason: 'Chest is selected; late Shoulders response must not replace its links',
    );
    expect(find.text('Deltoids'), findsNothing);
  });

  testWidgets('add change-set action must expose button semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    try {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Center(
              child: WorkoutAddChangeSetAction(
                label: 'Add change set',
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final semantics = tester
          .getSemantics(find.text('Add change set'))
          .getSemanticsData();
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
    } finally {
      handle.dispose();
    }
  });
}
