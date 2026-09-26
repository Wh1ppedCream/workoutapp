/// Stable representations for stored instants and user-facing calendar days.
///
/// An instant is always stored as UTC epoch milliseconds. A calendar day is a
/// separate date-only value, so it does not move when the device time zone
/// changes after the record was created.
class LocalCalendarDay implements Comparable<LocalCalendarDay> {
  final int year;
  final int month;
  final int day;

  const LocalCalendarDay(this.year, this.month, this.day)
    : assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 31);

  /// Uses the calendar fields supplied by the caller without converting zones.
  factory LocalCalendarDay.fromDateTime(DateTime value) {
    return LocalCalendarDay(value.year, value.month, value.day);
  }

  /// Parses a strict persisted date key, or the date prefix of a legacy ISO
  /// timestamp. The prefix preserves the day people previously saw in history.
  static LocalCalendarDay? tryParse(Object? value) {
    if (value is! String) return null;
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?:$|T)',
    ).firstMatch(value.trim());
    if (match == null) return null;

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;

    final validated = DateTime.utc(year, month, day);
    if (validated.year != year ||
        validated.month != month ||
        validated.day != day) {
      return null;
    }
    return LocalCalendarDay(year, month, day);
  }

  static LocalCalendarDay parse(Object? value) {
    final parsed = tryParse(value);
    if (parsed == null) {
      throw FormatException('Expected a calendar day in YYYY-MM-DD form.');
    }
    return parsed;
  }

  String get storageKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  DateTime toLocalDateTime() => DateTime(year, month, day);

  /// Combines this persisted day with an instant's local clock time for a
  /// stable date-and-time label after a device time-zone change.
  DateTime atLocalTime(DateTime instant) {
    final localTime = instant.toLocal();
    return DateTime(
      year,
      month,
      day,
      localTime.hour,
      localTime.minute,
      localTime.second,
      localTime.millisecond,
      localTime.microsecond,
    );
  }

  LocalCalendarDay addDays(int days) {
    return LocalCalendarDay.fromDateTime(
      toLocalDateTime().add(Duration(days: days)),
    );
  }

  @override
  int compareTo(LocalCalendarDay other) =>
      storageKey.compareTo(other.storageKey);

  @override
  bool operator ==(Object other) {
    return other is LocalCalendarDay &&
        year == other.year &&
        month == other.month &&
        day == other.day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => storageKey;
}

/// A parsed legacy timestamp plus the calendar day visible in its source text.
class LegacyTimestampValue {
  final int utcEpochMilliseconds;
  final LocalCalendarDay calendarDay;

  const LegacyTimestampValue({
    required this.utcEpochMilliseconds,
    required this.calendarDay,
  });
}

class TemporalSemantics {
  const TemporalSemantics._();

  static int utcEpochMilliseconds(DateTime value) =>
      value.toUtc().millisecondsSinceEpoch;

  static String legacyUtcIso8601(DateTime value) =>
      value.toUtc().toIso8601String();

  static int? tryReadEpochMilliseconds(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static DateTime? tryReadUtcInstant(Object? epochMilliseconds) {
    final epoch = tryReadEpochMilliseconds(epochMilliseconds);
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
  }

  /// Returns a local display time for a canonical epoch value, with a legacy
  /// ISO fallback while an upgraded database is being repaired.
  static DateTime readLocalDateTime({
    Object? epochMilliseconds,
    Object? legacyIso,
  }) {
    final instant = tryReadUtcInstant(epochMilliseconds);
    if (instant != null) return instant.toLocal();

    if (legacyIso is String) {
      final parsed = DateTime.tryParse(legacyIso);
      if (parsed != null) return parsed.toLocal();
    }
    throw FormatException('Expected a persisted instant.');
  }

  static LocalCalendarDay readCalendarDay({
    Object? calendarDay,
    Object? legacyIso,
    Object? epochMilliseconds,
  }) {
    final stored = LocalCalendarDay.tryParse(calendarDay);
    if (stored != null) return stored;

    final legacy = tryParseLegacyTimestamp(legacyIso);
    if (legacy != null) return legacy.calendarDay;

    final instant = tryReadUtcInstant(epochMilliseconds);
    if (instant != null) {
      return LocalCalendarDay.fromDateTime(instant.toLocal());
    }

    throw FormatException('Expected a persisted calendar day.');
  }

  /// Parses old ISO or epoch values without changing the source calendar day.
  static LegacyTimestampValue? tryParseLegacyTimestamp(Object? value) {
    final epoch = tryReadEpochMilliseconds(value);
    if (epoch != null) {
      final instant = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
      return LegacyTimestampValue(
        utcEpochMilliseconds: epoch,
        calendarDay: LocalCalendarDay.fromDateTime(instant.toLocal()),
      );
    }

    if (value is! String) return null;
    final text = value.trim();
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    return LegacyTimestampValue(
      utcEpochMilliseconds: utcEpochMilliseconds(parsed),
      calendarDay:
          LocalCalendarDay.tryParse(text) ??
          LocalCalendarDay.fromDateTime(parsed),
    );
  }
}
