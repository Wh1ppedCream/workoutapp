import 'package:env_test/models/temporal_semantics.dart';
import 'package:env_test/models/workout_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalCalendarDay', () {
    test('keeps calendar fields separate from an exact instant', () {
      final completion = DateTime(2026, 3, 8, 0, 30);

      expect(
        LocalCalendarDay.fromDateTime(completion).storageKey,
        '2026-03-08',
      );
      expect(
        TemporalSemantics.utcEpochMilliseconds(completion),
        completion.toUtc().millisecondsSinceEpoch,
      );
    });

    test('rejects invalid persisted calendar-day values', () {
      expect(LocalCalendarDay.tryParse('2026-02-29'), isNull);
      expect(LocalCalendarDay.tryParse('2026-2-9'), isNull);
      expect(LocalCalendarDay.tryParse('2026-02-29T12:00:00'), isNull);
    });

    test('keeps a persisted day when rendering an exact local time', () {
      final display = const LocalCalendarDay(
        2026,
        3,
        8,
      ).atLocalTime(DateTime.utc(2026, 3, 9, 2, 45));

      expect(display.year, 2026);
      expect(display.month, 3);
      expect(display.day, 8);
      expect(display.hour, DateTime.utc(2026, 3, 9, 2, 45).toLocal().hour);
    });
  });

  group('TemporalSemantics legacy compatibility', () {
    test('preserves the legacy source day while normalizing its instant', () {
      const legacyIso = '2026-01-01T00:30:00+14:00';
      final parsed = TemporalSemantics.tryParseLegacyTimestamp(legacyIso)!;

      expect(parsed.calendarDay.storageKey, '2026-01-01');
      expect(
        parsed.utcEpochMilliseconds,
        DateTime.parse(legacyIso).toUtc().millisecondsSinceEpoch,
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          parsed.utcEpochMilliseconds,
          isUtc: true,
        ).day,
        31,
      );
    });

    test('keeps a DST transition on its recorded calendar day', () {
      const beforeJump = '2026-03-08T01:59:59-05:00';
      const afterJump = '2026-03-08T03:00:00-04:00';
      final before = TemporalSemantics.tryParseLegacyTimestamp(beforeJump)!;
      final after = TemporalSemantics.tryParseLegacyTimestamp(afterJump)!;

      expect(before.calendarDay.storageKey, '2026-03-08');
      expect(after.calendarDay.storageKey, '2026-03-08');
      expect(after.utcEpochMilliseconds - before.utcEpochMilliseconds, 1000);
    });

    test('prefers an explicit persisted calendar day over zone conversion', () {
      final day = TemporalSemantics.readCalendarDay(
        calendarDay: '2026-03-08',
        legacyIso: '2026-03-09T03:30:00.000Z',
        epochMilliseconds:
            DateTime.utc(2026, 3, 9, 3, 30).millisecondsSinceEpoch,
      );

      expect(day.storageKey, '2026-03-08');
    });

    test('workout display labels keep their stored calendar day', () {
      final session = WorkoutSession(
        id: 1,
        date: DateTime.utc(2026, 3, 9, 2, 45).toLocal(),
        calendarDayKey: '2026-03-08',
        duration: 60,
      );

      expect(session.calendarDay.storageKey, '2026-03-08');
      expect(session.displayDateTime.day, 8);
      expect(session.displayDateTime.hour, session.date.hour);
    });
  });
}
