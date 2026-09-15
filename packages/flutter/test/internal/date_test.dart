/// The date arithmetic the calendars and the pickers stand on.
///
/// `test/internal/date.test.ts` holds the same tables, row for row, because the
/// two builds have to give the same answers. A day is written as
/// `(year, month, day)` with the month counted from 1 in both files, so the rows
/// read the same.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/types.dart';

typedef Day = (int, int, int);

DateTime day(Day parts) => DateTime(parts.$1, parts.$2, parts.$3);

Day parts(DateTime date) => (date.year, date.month, date.day);

void main() {
  group('addMonths', () {
    const List<(Day, int, Day)> rows = <(Day, int, Day)>[
      ((2026, 1, 31), 1, (2026, 2, 28)),
      ((2024, 1, 31), 1, (2024, 2, 29)),
      ((2026, 3, 31), -1, (2026, 2, 28)),
      ((2026, 12, 31), 2, (2027, 2, 28)),
      ((2026, 7, 15), -7, (2025, 12, 15)),
      ((2026, 5, 31), 1, (2026, 6, 30)),
      ((2026, 8, 31), -12, (2025, 8, 31)),
      ((0, 1, 31), -1, (-1, 12, 31)),
    ];

    for (final (Day from, int amount, Day to) in rows) {
      test('moves $from by $amount months to $to, clamping the day', () {
        expect(parts(addMonths(day(from), amount)), to);
      });
    }

    test('keeps the time of day', () {
      final DateTime moved = addMonths(DateTime(2026, 1, 31, 9, 30, 15), 1);

      expect((moved.hour, moved.minute, moved.second), (9, 30, 15));
    });
  });

  group('addYears', () {
    const List<(Day, int, Day)> rows = <(Day, int, Day)>[
      ((2024, 2, 29), 1, (2025, 2, 28)),
      ((2024, 2, 29), 4, (2028, 2, 29)),
      ((2024, 2, 29), -100, (1924, 2, 29)),
    ];

    for (final (Day from, int amount, Day to) in rows) {
      test('moves $from by $amount years to $to', () {
        expect(parts(addYears(day(from), amount)), to);
      });
    }
  });

  group('addDays', () {
    const List<(Day, int, Day)> rows = <(Day, int, Day)>[
      ((2026, 12, 31), 1, (2027, 1, 1)),
      ((2026, 3, 1), -1, (2026, 2, 28)),
      ((2024, 3, 1), -1, (2024, 2, 29)),
      ((2026, 7, 27), 7, (2026, 8, 3)),
    ];

    for (final (Day from, int amount, Day to) in rows) {
      test('moves $from by $amount days to $to', () {
        expect(parts(addDays(day(from), amount)), to);
      });
    }
  });

  group('daysInMonth', () {
    const List<(int, int, int)> rows = <(int, int, int)>[
      (2024, 2, 29),
      (2026, 2, 28),
      (1900, 2, 28),
      (2000, 2, 29),
      (2026, 4, 30),
      (2026, 12, 31),
    ];

    for (final (int year, int month, int days) in rows) {
      test('gives $year-$month $days days', () {
        expect(daysInMonth(year, month), days);
      });
    }
  });

  group('calendarWeeks', () {
    // The weekday is counted from Sunday as 0, as `PlassWeekday` is in both builds.
    const List<(Day, PlassWeekday, Day, Day)> rows = <(Day, PlassWeekday, Day, Day)>[
      ((2026, 7, 1), PlassWeekday.sunday, (2026, 6, 28), (2026, 8, 8)),
      ((2026, 7, 1), PlassWeekday.monday, (2026, 6, 29), (2026, 8, 9)),
      ((2026, 7, 1), PlassWeekday.saturday, (2026, 6, 27), (2026, 8, 7)),
      ((2026, 2, 1), PlassWeekday.sunday, (2026, 2, 1), (2026, 3, 14)),
      ((2026, 2, 1), PlassWeekday.monday, (2026, 1, 26), (2026, 3, 8)),
    ];

    for (final (Day month, PlassWeekday start, Day first, Day last) in rows) {
      test('starts $month on ${start.name} at $first and ends it at $last', () {
        final List<List<DateTime>> weeks = calendarWeeks(day(month), start);

        expect(weeks, hasLength(6));
        expect(weeks.every((List<DateTime> week) => week.length == 7), isTrue);
        expect(parts(weeks[0][0]), first);
        expect(parts(weeks[5][6]), last);
        expect(weeks[0][0].weekday % 7, start.index);
      });
    }
  });

  group('yearPageStart', () {
    const List<(int, int)> rows = <(int, int)>[
      (2026, 2016),
      (2016, 2016),
      (2027, 2016),
      (2028, 2028),
      (11, 0),
      (0, 0),
      (-1, -12),
      (-12, -12),
      (-13, -24),
    ];

    for (final (int year, int start) in rows) {
      test('puts $year on the page that starts at $start', () {
        expect(yearPageStart(year), start);
      });
    }
  });

  group('compareDay', () {
    test('reads the calendar day and not the clock', () {
      expect(compareDay(DateTime(2026, 7, 27, 23, 59), DateTime(2026, 7, 27)), 0);
      expect(compareDay(DateTime(2026, 7, 26, 23, 59), DateTime(2026, 7, 27)), lessThan(0));
    });
  });

  group('isMonthOutside and isYearOutside', () {
    final DateTime min = day((2026, 7, 15));
    final DateTime max = day((2026, 7, 15));

    test('keeps the month a bound falls in', () {
      expect(isMonthOutside(day((2026, 7, 1)), min, null), isFalse);
      expect(isMonthOutside(day((2026, 7, 31)), null, max), isFalse);
      expect(isMonthOutside(day((2026, 6, 30)), min, null), isTrue);
      expect(isMonthOutside(day((2026, 8, 1)), null, max), isTrue);
    });

    test('keeps the year a bound falls in', () {
      expect(isYearOutside(day((2026, 1, 1)), min, max), isFalse);
      expect(isYearOutside(day((2025, 12, 31)), min, null), isTrue);
      expect(isYearOutside(day((2027, 1, 1)), null, max), isTrue);
    });
  });

  group('displaySamples', () {
    test('holds twenty-four instants', () {
      expect(displaySamples, hasLength(24));
    });

    test('walks every month and every hour', () {
      expect(<int>{for (final DateTime sample in displaySamples) sample.month}, hasLength(12));
      expect(<int>{for (final DateTime sample in displaySamples) sample.hour}, hasLength(24));
    });

    test('writes a two-digit day, minute and second', () {
      for (final DateTime sample in displaySamples) {
        expect(sample.day, inInclusiveRange(21, 27));
        expect(sample.minute, 58);
        expect(sample.second, 58);
      }
    });
  });
}
