import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/session_record_badge_models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';
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

  testWidgets('stacked badges grow to fit wrapped labels', (tester) async {
    const badges = [
      WorkoutRecordBadge(
        tier: WorkoutRecordBadgeTier.allTime,
        type: WorkoutRecordBadgeType.repBest,
        reps: 8,
      ),
      WorkoutRecordBadge(
        tier: WorkoutRecordBadgeTier.allTime,
        type: WorkoutRecordBadgeType.volumeBest,
      ),
    ];
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.35)),
            child: const Center(
              child: WorkoutRecordBadgeStack(badges: badges, width: 68),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(WorkoutRecordBadgeStack)).height,
      greaterThan(28),
    );
    expect(find.text(strings.recordRepBest(8)), findsOneWidget);
    expect(find.text(strings.recordVolumeBest), findsOneWidget);
  });

  testWidgets('badge visuals resolve tokens in every theme mode', (
    tester,
  ) async {
    const firstRegularKey = ValueKey('first-regular');
    const firstCompactKey = ValueKey('first-compact');
    const allTimeRegularKey = ValueKey('all-time-regular');
    const allTimeCompactKey = ValueKey('all-time-compact');
    const monthlyRegularKey = ValueKey('monthly-regular');
    const legendKey = ValueKey('record-legend');

    Container containerFor(Key key) => tester.widget<Container>(
      find
          .descendant(of: find.byKey(key), matching: find.byType(Container))
          .first,
    );
    Text textFor(Key key) => tester.widget<Text>(
      find.descendant(of: find.byKey(key), matching: find.byType(Text)).first,
    );

    void expectBadge({
      required Key key,
      required Color color,
      required double fillOpacity,
      required double borderOpacity,
      required BorderRadius radius,
      required EdgeInsets padding,
      required double fontSize,
    }) {
      final container = containerFor(key);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, color.withValues(alpha: fillOpacity));
      expect(
        (decoration.border! as Border).top.color,
        color.withValues(alpha: borderOpacity),
      );
      expect(decoration.borderRadius, radius);
      expect(container.padding, padding);
      expect(textFor(key).style?.color, color);
      expect(textFor(key).style?.fontSize, fontSize);
    }

    for (final family in [
      AppThemeFamily.classic,
      AppThemeFamily.neoBrutalism,
    ]) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.light
                ? AppThemeFactory.light(family)
                : AppThemeFactory.dark(family);
        final surfaces = theme.surfaceTokens;
        final shapes = theme.shapeTokens;
        final data = theme.dataVisualizationTokens;
        final classicDensity = family == AppThemeFamily.classic;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            themeAnimationDuration: Duration.zero,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FirstRecordBadge(key: firstRegularKey),
                  FirstRecordBadge(key: firstCompactKey, compact: true),
                  WorkoutRecordBadgeChip(key: allTimeRegularKey, badge: badge),
                  WorkoutRecordBadgeChip(
                    key: allTimeCompactKey,
                    badge: badge,
                    compact: true,
                  ),
                  const WorkoutRecordBadgeChip(
                    key: monthlyRegularKey,
                    badge: WorkoutRecordBadge(
                      tier: WorkoutRecordBadgeTier.monthly,
                      type: WorkoutRecordBadgeType.volumeBest,
                    ),
                  ),
                  WorkoutRecordBadgeLegend(key: legendKey),
                ],
              ),
            ),
          ),
        );

        expectBadge(
          key: firstRegularKey,
          color: data.firstRecord,
          fillOpacity: surfaces.firstRecordFill,
          borderOpacity: surfaces.firstRecordBorder,
          radius: shapes.recordBadge,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          fontSize: classicDensity ? 9 : 12,
        );
        expectBadge(
          key: firstCompactKey,
          color: data.firstRecord,
          fillOpacity: surfaces.firstRecordFill,
          borderOpacity: surfaces.firstRecordBorder,
          radius: shapes.recordBadgeCompact,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          fontSize: classicDensity ? 7.5 : 10,
        );
        expectBadge(
          key: allTimeRegularKey,
          color: data.recordAllTime,
          fillOpacity: surfaces.recordBadgeFill,
          borderOpacity: surfaces.recordBadgeBorder,
          radius: shapes.recordBadge,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          fontSize: classicDensity ? 9 : 12,
        );
        expectBadge(
          key: allTimeCompactKey,
          color: data.recordAllTime,
          fillOpacity: surfaces.recordBadgeFill,
          borderOpacity: surfaces.recordBadgeBorder,
          radius: shapes.recordBadgeCompact,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          fontSize: classicDensity ? 7.5 : 10,
        );
        expectBadge(
          key: monthlyRegularKey,
          color: data.recordMonthly,
          fillOpacity: surfaces.recordBadgeFill,
          borderOpacity: surfaces.recordBadgeBorder,
          radius: shapes.recordBadge,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          fontSize: classicDensity ? 9 : 12,
        );
        final legendDots = find.descendant(
          of: find.byKey(legendKey),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
          ),
        );
        expect(legendDots, findsNWidgets(2));
        expect(
          (tester.widget<Container>(legendDots.at(0)).decoration!
                  as BoxDecoration)
              .color,
          data.recordMonthly,
        );
        expect(
          (tester.widget<Container>(legendDots.at(1)).decoration!
                  as BoxDecoration)
              .color,
          data.recordAllTime,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Neo badge text contrasts with its composited parent surface', (
    tester,
  ) async {
    const chipKey = ValueKey('contrast-aware-record-badge');
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      late Color background;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          themeAnimationDuration: Duration.zero,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final data = context.dataVisualizationTokens;
              final surfaces = context.surfaceTokens;
              final fill = data.recordAllTime.withValues(
                alpha: surfaces.recordBadgeFill,
              );
              background = Color.alphaBlend(
                fill,
                surfaces.exerciseDetailRecord,
              );
              return Scaffold(
                body: WorkoutRecordBadgeChip(
                  key: chipKey,
                  badge: badge,
                  foregroundSurface: surfaces.exerciseDetailRecord,
                ),
              );
            },
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.descendant(of: find.byKey(chipKey), matching: find.byType(Text)),
      );
      expect(
        _contrastRatio(text.style!.color!, background),
        greaterThanOrEqualTo(4.5),
      );
      expect(tester.takeException(), isNull);
    }
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

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
