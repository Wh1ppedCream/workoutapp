import 'package:env_test/models/models.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:env_test/widgets/set_stat_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets(
    'FocusedSetsList limits visible rows and rounds set labels down',
    (tester) async {
      await tester.pumpWidget(
        host(
          FocusedSetsList(
            maxVisible: 2,
            hits: [
              FocusedSetHit(bodyPart: BodyPart(1, 'Chest'), units: 8.9),
              FocusedSetHit(bodyPart: BodyPart(2, 'Back'), units: 4.2),
              FocusedSetHit(bodyPart: BodyPart(3, 'Legs'), units: 3),
            ],
          ),
        ),
      );

      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Legs'), findsNothing);
      expect(find.text('8'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    },
  );

  testWidgets('SetStatChip exposes its edit action accessibly', (tester) async {
    var didEdit = false;
    await tester.pumpWidget(
      host(
        SetStatChip(
          label: 'Recommended',
          value: '10 sets',
          onEdit: () => didEdit = true,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Edit recommended sets'));
    expect(didEdit, isTrue);
  });
}
