import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'localized_digit_formatter.dart';

/// Shared presentation formatters for values that are stored independently of
/// the current locale.
///
/// Callers must pass the date or time they intend to show. In particular, a
/// persisted instant should already have been converted to its display time,
/// while a [LocalCalendarDay] should be converted without a timezone shift.
class LocalizedFormatters {
  const LocalizedFormatters._();

  static String date(DateTime value, Locale locale) {
    return _format(DateFormat.yMMMd(_localeTag(locale)).format(value), locale);
  }

  static String shortDate(DateTime value, Locale locale) {
    return _format(DateFormat.MMMd(_localeTag(locale)).format(value), locale);
  }

  static String monthDay(DateTime value, Locale locale) {
    return _format(DateFormat.Md(_localeTag(locale)).format(value), locale);
  }

  static String weekdayShortDate(DateTime value, Locale locale) {
    return _format(DateFormat.MMMEd(_localeTag(locale)).format(value), locale);
  }

  static String longDate(DateTime value, Locale locale) {
    return _format(DateFormat.yMMMMd(_localeTag(locale)).format(value), locale);
  }

  static String month(DateTime value, Locale locale) {
    return _format(DateFormat.MMMM(_localeTag(locale)).format(value), locale);
  }

  static String monthShort(DateTime value, Locale locale) {
    return _format(DateFormat.MMM(_localeTag(locale)).format(value), locale);
  }

  static String dayMonth(DateTime value, Locale locale) {
    return _format(
      DateFormat('d MMM', _localeTag(locale)).format(value),
      locale,
    );
  }

  static String weekdayShort(DateTime value, Locale locale) {
    return _format(DateFormat.E(_localeTag(locale)).format(value), locale);
  }

  /// Formats a weekday using the locale's narrow calendar label.
  ///
  /// Calendar headers need a compact label, but the label must still come
  /// from the locale rather than an English initial or a hand-maintained
  /// language list.
  static String weekdayNarrow(DateTime value, Locale locale) {
    return _format(
      DateFormat('EEEEE', _localeTag(locale)).format(value),
      locale,
    );
  }

  static String monthYear(DateTime value, Locale locale) {
    return _format(DateFormat.yMMMM(_localeTag(locale)).format(value), locale);
  }

  static String year(int value, Locale locale) {
    return _format(NumberFormat('0', _localeTag(locale)).format(value), locale);
  }

  static String dateRange(DateTime start, DateTime end, Locale locale) {
    final tag = _localeTag(locale);
    final startFormatter =
        start.year == end.year ? DateFormat.MMMd(tag) : DateFormat.yMMMd(tag);
    final endFormatter = DateFormat.yMMMd(tag);
    return _format(
      '${startFormatter.format(start)} - ${endFormatter.format(end)}',
      locale,
    );
  }

  static String monthRange(
    DateTime startMonth,
    DateTime endMonth,
    Locale locale,
  ) {
    final tag = _localeTag(locale);
    final startFormatter =
        startMonth.year == endMonth.year
            ? DateFormat.MMM(tag)
            : DateFormat.yMMM(tag);
    final endFormatter = DateFormat.yMMM(tag);
    final range =
        ('${startFormatter.format(startMonth)} - '
                '${endFormatter.format(endMonth)}')
            .toUpperCase();
    return _format(range, locale);
  }

  static String time(DateTime value, Locale locale) {
    return _format(DateFormat.jm(_localeTag(locale)).format(value), locale);
  }

  static String dateTime(DateTime value, Locale locale) {
    final formatter = DateFormat.yMMMd(_localeTag(locale))..add_jm();
    return _format(formatter.format(value), locale);
  }

  /// Formats a number with locale-specific separators and decimal marks.
  static String number(
    num value,
    Locale locale, {
    int? minimumFractionDigits,
    int? maximumFractionDigits,
  }) {
    if (minimumFractionDigits != null && minimumFractionDigits < 0) {
      throw ArgumentError.value(
        minimumFractionDigits,
        'minimumFractionDigits',
        'must not be negative',
      );
    }
    if (maximumFractionDigits != null && maximumFractionDigits < 0) {
      throw ArgumentError.value(
        maximumFractionDigits,
        'maximumFractionDigits',
        'must not be negative',
      );
    }
    if (minimumFractionDigits != null &&
        maximumFractionDigits != null &&
        minimumFractionDigits > maximumFractionDigits) {
      throw ArgumentError(
        'minimumFractionDigits cannot exceed maximumFractionDigits.',
      );
    }

    final formatter = NumberFormat.decimalPattern(_localeTag(locale));
    if (minimumFractionDigits != null) {
      formatter.minimumFractionDigits = minimumFractionDigits;
    }
    if (maximumFractionDigits != null) {
      formatter.maximumFractionDigits = maximumFractionDigits;
    }
    return _format(formatter.format(value), locale);
  }

  /// Formats a fractional value as a locale-aware percentage.
  static String percent(
    num fraction,
    Locale locale, {
    int? minimumFractionDigits,
    int? maximumFractionDigits,
  }) {
    final formatter = NumberFormat.percentPattern(_localeTag(locale));
    if (minimumFractionDigits != null) {
      formatter.minimumFractionDigits = minimumFractionDigits;
    }
    if (maximumFractionDigits != null) {
      formatter.maximumFractionDigits = maximumFractionDigits;
    }
    return _format(formatter.format(fraction), locale);
  }

  /// Formats a large number using the locale's compact notation.
  static String compactNumber(num value, Locale locale) {
    return _format(
      NumberFormat.compact(locale: _localeTag(locale)).format(value),
      locale,
    );
  }

  static String _localeTag(Locale locale) => locale.toLanguageTag();

  static String _format(String value, Locale locale) {
    return preserveWesternDigits(value, locale);
  }
}
