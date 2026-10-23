import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/gym_models.dart';
import 'package:env_test/models/nutrition_models.dart';
import 'package:env_test/providers/nutrition_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/repositories/food_catalog_repository.dart';
import 'package:env_test/screens/nutrition/log_entry_page.dart';
import 'package:env_test/screens/profile/settings/goal_manual_entry_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';
import 'package:env_test/widgets/data_records_section.dart';
import 'package:env_test/utils/localized_formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class _EmptyCatalog implements FoodCatalogSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repository extends AppRepository {
  final _catalog = FoodCatalogRepository(source: _EmptyCatalog());
  @override
  FoodCatalogRepository get foodCatalog => _catalog;
  @override
  Future<void> seedNutrientsIfEmpty() async {}
  @override
  Future<List<GymProfile>> fetchAllProfiles() async => [
    GymProfile(id: 1, name: 'Audit only', createdAt: DateTime(2026)),
    GymProfile(id: 2, name: 'Second profile', createdAt: DateTime(2026)),
  ];
  @override
  Future<DayTotals> getDayTotals(int profileId, DateTime date) async =>
      DayTotals(profileId: profileId, date: date);
  @override
  Future<NutritionGoal?> getActiveGoals(int profileId, DateTime date) async =>
      null;
  @override
  Future<List<DiaryEntryWithItem>> getDiaryEntriesWithItemsForDate(
    int profileId,
    DateTime date,
  ) async => [];
  @override
  Future<List<Food>> listFavorites(int profileId, {int limit = 100}) async =>
      [];
}

Widget _app(Widget home, {NutritionProfile? profile}) {
  final app = MaterialApp(
    theme: ExpressiveThemeDefinition.light(),
    localizationsDelegates: tonosLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
  return profile == null
      ? app
      : ChangeNotifierProvider<NutritionProfile>(
          create: (_) => profile,
          child: app,
        );
}

void main() {
  test(
    'nested records scopes preserve the selected profile and independent dates',
    () async {
      final parent = NutritionProfile(repository: _Repository());
      await parent.ready;
      await parent.selectProfile(parent.profiles.last);
      final outer = parent.createDayScope(DateTime(2026, 1, 2));
      await outer.ready;
      final inner = outer.createDayScope(DateTime(2026, 1, 3));
      await inner.ready;
      expect(parent.isToday, isTrue);
      expect(outer.profileId, 2);
      expect(inner.profileId, 2);
      expect(outer.day, DateTime(2026, 1, 2));
      expect(inner.day, DateTime(2026, 1, 3));
      inner.dispose();
      outer.dispose();
      parent.dispose();
    },
  );
  testWidgets('manual goal validator must reject non-finite numbers', (
    tester,
  ) async {
    final profile = NutritionProfile(repository: _Repository());
    await tester.pumpWidget(
      _app(const GoalManualEntryPage(), profile: profile),
    );
    await tester.pumpAndSettle();
    final field = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    for (final invalid in ['NaN', 'Infinity', '1e999']) {
      expect(field.validator!(invalid), isNotNull, reason: 'Reject $invalid');
    }
  });

  test('accepted non-finite values cannot be rounded for the summary', () {
    for (final value in ['NaN', 'Infinity', '1e999']) {
      final parsed = num.tryParse(value)!;
      expect(parsed < 0, isFalse);
      expect(parsed.isFinite, isFalse);
      expect(() => parsed.round(), throwsUnsupportedError);
    }
  });

  testWidgets('leaving historical records must restore the root day', (
    tester,
  ) async {
    final profile = NutritionProfile(repository: _Repository());
    final historical = DateTime.now().subtract(const Duration(days: 7));
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LogEntryPage(date: historical),
                ),
              ),
              child: const Text('Open old records'),
            ),
          ),
        ),
        profile: profile,
      ),
    );
    await tester.pumpAndSettle();
    expect(profile.isToday, isTrue);
    await tester.tap(find.text('Open old records'));
    await tester.pumpAndSettle();
    expect(profile.isToday, isTrue);
    final recordsProfile = tester
        .element(find.byType(Scaffold).last)
        .read<NutritionProfile>();
    expect(recordsProfile.day.day, historical.day);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      profile.isToday,
      isTrue,
      reason: 'Root summary and Add Meal have no historical-date label',
    );
  });

  testWidgets('records calendar headings match its rolling date columns', (
    tester,
  ) async {
    for (var day = 1; day <= 7; day++) {
      final now = DateTime(2026, 1, day);
      await tester.pumpWidget(
        _app(
          AppExpressiveDestinationTheme(
            family: AppExpressiveDestinationFamily.nutrition,
            child: Scaffold(
              body: SingleChildScrollView(
                child: DataRecordsSection(referenceDate: now),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final grid = tester.widget<GridView>(find.byType(GridView));
      final cells = (grid.childrenDelegate as SliverChildListDelegate).children;
      final first = cells.first as Semantics;
      final firstDate = DateTime(now.year, now.month, now.day - 27);
      // Verify the source-generated first cell before checking its weekday.
      expect(first.properties.label, contains('${firstDate.day}'));
      final locale = Localizations.localeOf(
        tester.element(find.byType(DataRecordsSection)),
      );
      final expected = List.generate(
        7,
        (index) => LocalizedFormatters.weekdayNarrow(
          DateTime(firstDate.year, firstDate.month, firstDate.day + index),
          locale,
        ),
      );
      final labels = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(DataRecordsSection),
              matching: find.byType(Text),
            ),
          )
          .map((text) => text.data)
          .whereType<String>()
          .toList();
      expect(labels.join('|'), contains(expected.join('|')));
      expect(cells.length, 28);
    }
  });
}
