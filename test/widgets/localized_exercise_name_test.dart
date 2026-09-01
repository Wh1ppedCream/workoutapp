import 'dart:convert';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/definition_models.dart';
import 'package:env_test/services/exercise_content_localizer.dart';
import 'package:env_test/widgets/localized_exercise_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExerciseDefinition definition({String? catalogId}) => ExerciseDefinition(
    id: 7,
    catalogId: catalogId,
    name: 'Bench Press - Barbell',
    useManualBodyparts: false,
    multiplyByRating: false,
  );

  testWidgets('replaces a canonical name with its localized display name', (
    tester,
  ) async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader:
          () async => jsonEncode({
            'version': 1,
            'names': {
              'es': {'tonos.exercise.0007': 'Press de banca con barra'},
            },
            'locales': <String, Object?>{},
          }),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LocalizedExerciseName(
            definition: definition(catalogId: 'tonos.exercise.0007'),
            localizer: localizer,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Press de banca con barra'), findsOneWidget);
    expect(find.text('Bench Press - Barbell'), findsNothing);
  });

  testWidgets('keeps the stored name for a custom exercise', (tester) async {
    final localizer = ExerciseContentLocalizer(
      bundleLoader: () async => '{"version":1,"locales":{}}',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LocalizedExerciseName(
            definition: definition(),
            localizer: localizer,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bench Press - Barbell'), findsOneWidget);
  });
}
