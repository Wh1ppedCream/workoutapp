import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/session_record_badge_models.dart';
import 'package:env_test/widgets/workout_record_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badge = WorkoutRecordBadge(
    tier: WorkoutRecordBadgeTier.allTime,
    type: WorkoutRecordBadgeType.repBest,
    reps: 8,
  );

  testWidgets('record badge labels refresh when the locale changes', (
    tester,
  ) async {
    Future<AppLocalizations> stringsFor(Locale locale) =>
        AppLocalizations.delegate.load(locale);

    await tester.pumpWidget(_host(const Locale('es'), badge));
    await tester.pump();
    final spanish = await stringsFor(const Locale('es'));
    final english = await stringsFor(const Locale('en'));
    expect(find.text(spanish.recordRepBest(8)), findsOneWidget);
    expect(find.text(english.recordRepBest(8)), findsNothing);

    await tester.pumpWidget(_host(const Locale('zh'), badge));
    await tester.pump();
    final chinese = await stringsFor(const Locale('zh'));
    expect(find.text(chinese.recordRepBest(8)), findsOneWidget);
    expect(find.text(spanish.recordRepBest(8)), findsNothing);
  });
}

Widget _host(Locale locale, WorkoutRecordBadge badge) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: WorkoutRecordBadgeChip(badge: badge)),
  );
}
