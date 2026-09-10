import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/session_record_badge_models.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
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

  testWidgets('record badge colors resolve from data visualization tokens', (
    tester,
  ) async {
    const allTimeColor = Color(0xFF123456);
    const monthlyColor = Color(0xFF654321);
    final dataTokens = AppDataVisualizationTokens.fromBrightness(
      Brightness.light,
    ).copyWith(recordAllTime: allTimeColor, recordMonthly: monthlyColor);

    await tester.pumpWidget(
      _host(const Locale('en'), badge, dataTokens: dataTokens),
    );
    await tester.pump();
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final allTimeText = tester.widget<Text>(
      find.text(english.recordRepBest(8)),
    );
    expect(allTimeText.style?.color, allTimeColor);

    await tester.pumpWidget(
      _host(
        const Locale('en'),
        const WorkoutRecordBadge(
          tier: WorkoutRecordBadgeTier.monthly,
          type: WorkoutRecordBadgeType.volumeBest,
        ),
        dataTokens: dataTokens,
      ),
    );
    await tester.pump();
    final monthlyText = tester.widget<Text>(
      find.text(english.recordVolumeBest),
    );
    expect(monthlyText.style?.color, monthlyColor);
  });
}

Widget _host(
  Locale locale,
  WorkoutRecordBadge badge, {
  AppDataVisualizationTokens? dataTokens,
}) {
  return MaterialApp(
    locale: locale,
    theme:
        dataTokens == null
            ? null
            : ThemeData(extensions: <ThemeExtension<dynamic>>[dataTokens]),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: WorkoutRecordBadgeChip(badge: badge)),
  );
}
