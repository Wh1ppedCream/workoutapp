import 'package:env_test/utils/localized_formatters.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting();

  final date = DateTime(2026, 8, 11, 17, 5);

  group('LocalizedFormatters', () {
    test('uses locale-specific date and time conventions', () {
      expect(
        LocalizedFormatters.date(date, const Locale('en')),
        'Aug 11, 2026',
      );
      expect(
        LocalizedFormatters.date(date, const Locale('fr')),
        '11 août 2026',
      );
      final englishTime = LocalizedFormatters.time(date, const Locale('en'));
      expect(englishTime, startsWith('5:05'));
      expect(englishTime, endsWith('PM'));
      expect(LocalizedFormatters.time(date, const Locale('fr')), '17:05');
    });

    test('formats calendar periods through the shared locale boundary', () {
      expect(
        LocalizedFormatters.longDate(date, const Locale('en')),
        'August 11, 2026',
      );
      expect(LocalizedFormatters.month(date, const Locale('fr')), 'août');
      expect(LocalizedFormatters.monthDay(date, const Locale('fr')), '11/08');
      expect(LocalizedFormatters.monthShort(date, const Locale('en')), 'Aug');
      expect(
        LocalizedFormatters.monthYear(date, const Locale('fr')),
        'août 2026',
      );
      expect(LocalizedFormatters.year(2026, const Locale('bn')), '2026');
      expect(
        LocalizedFormatters.dateRange(
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 11),
          const Locale('en'),
        ),
        'Aug 1 - Aug 11, 2026',
      );
      expect(
        LocalizedFormatters.weekdayShort(
          DateTime(2026, 8, 10),
          const Locale('en'),
        ),
        'Mon',
      );
      expect(
        LocalizedFormatters.weekdayNarrow(
          DateTime(2026, 8, 10),
          const Locale('en'),
        ),
        'M',
      );
      expect(
        LocalizedFormatters.weekdayNarrow(
          DateTime(2026, 8, 10),
          const Locale('fr'),
        ),
        'L',
      );
    });

    test('keeps Western digits for the Bangla product policy', () {
      final formatted = LocalizedFormatters.dateTime(date, const Locale('bn'));

      expect(formatted, isNot(contains('১')));
      expect(formatted, contains('2026'));
    });

    test(
      'renders stable date and number output for every supported locale',
      () {
        const locales = [
          Locale('en'),
          Locale('es'),
          Locale('fr'),
          Locale('fr', 'CA'),
          Locale('bn'),
          Locale('zh'),
          Locale('hi'),
        ];

        for (final locale in locales) {
          expect(LocalizedFormatters.dateTime(date, locale), isNotEmpty);
          expect(LocalizedFormatters.weekdayNarrow(date, locale), isNotEmpty);
          expect(LocalizedFormatters.number(12345.6, locale), contains('1'));
          expect(
            LocalizedFormatters.percent(
              0.125,
              locale,
              maximumFractionDigits: 1,
            ),
            contains('%'),
          );
        }
      },
    );

    test('uses locale-specific decimal separators', () {
      expect(
        LocalizedFormatters.number(
          12345.6,
          const Locale('en'),
          maximumFractionDigits: 1,
        ),
        '12,345.6',
      );
      expect(
        LocalizedFormatters.number(
          12345.6,
          const Locale('fr'),
          maximumFractionDigits: 1,
        ),
        contains(',6'),
      );
    });

    test('supports percentages and compact values', () {
      expect(
        LocalizedFormatters.percent(
          0.125,
          const Locale('en'),
          maximumFractionDigits: 1,
        ),
        '12.5%',
      );
      expect(
        LocalizedFormatters.compactNumber(12500, const Locale('en')),
        '12.5K',
      );
    });

    test('rejects an invalid fraction-digit range', () {
      expect(
        () => LocalizedFormatters.number(
          1.2,
          const Locale('en'),
          minimumFractionDigits: 2,
          maximumFractionDigits: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
