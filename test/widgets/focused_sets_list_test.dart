import 'package:env_test/models/models.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/utils/localized_body_part_name.dart';
import 'package:env_test/widgets/focused_sets_list.dart';
import 'package:env_test/widgets/set_stat_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {Locale? locale}) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

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

  testWidgets('FocusedSetsList localizes built-in labels', (tester) async {
    await tester.pumpWidget(
      host(
        FocusedSetsList(
          hits: [FocusedSetHit(bodyPart: BodyPart(1, 'Upper Back'), units: 6)],
        ),
        locale: const Locale('bn'),
      ),
    );

    expect(find.text('লক্ষ্যভিত্তিক সেট'), findsOneWidget);
    expect(find.text('উপরের পিঠ'), findsOneWidget);
    expect(find.text('Focused Sets'), findsNothing);
    expect(find.text('Upper Back'), findsNothing);
  });

  testWidgets(
    'localized body-part names translate built-ins and preserve custom names',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (buildContext) {
              context = buildContext;
              return const SizedBox();
            },
          ),
          locale: const Locale('zh'),
        ),
      );

      expect(localizedBodyPartName(context, 'Upper Back'), '上背部');
      expect(localizedBodyPartName(context, 'Biceps'), '肱二头肌');
      expect(localizedBodyPartName(context, 'Custom Area'), 'Custom Area');
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
