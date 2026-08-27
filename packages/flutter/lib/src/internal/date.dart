/// The arithmetic and the naming the four pickers share.
///
/// The Dart half of the React package's `internal/date.ts`, and it carries the
/// same rule: **no date library under it.** The Flutter package has no
/// dependencies at all beyond the framework, and one that quietly added
/// `package:intl` — or worse, picked a side in the `intl` / `jiffy` / `timezone`
/// argument on its consumer's behalf — would have made a decision that was not
/// its to make.
///
/// Which is also where the two packages part company. React gets `Intl` for
/// free from the platform, so a `locale` string is enough to produce every month
/// name, every weekday name and the order the header writes them in. The Flutter
/// framework ships nothing of the kind, so the words arrive as a [PlDateNames]
/// instead: English by default, and three lines of `DateFormat` for an app that
/// already has `package:intl` in its own `pubspec`.
///
/// Two rules hold everywhere below:
///
/// - **Local time, always.** A calendar day is a thing a person is looking at
///   on a wall, not an instant on a line. Every comparison here is made on the
///   local Y/M/D triple, so a picker in Seoul and a picker in São Paulo both
///   light up the cell that says 27.
/// - **Nothing is mutated.** `DateTime` is immutable in Dart, which makes this
///   free — but every function still returns a new value rather than reaching
///   into one it was handed.
///
/// None of it is exported from `plass_ui.dart` except [PlDateNames], which a
/// caller has to be able to build.
library;

import 'package:flutter/foundation.dart';

import 'package:plass_ui/src/types.dart';

/// Which unit the calendar is currently letting you pick.
enum PlassCalendarView {
  /// The days of one month.
  day,

  /// The twelve months of one year.
  month,

  /// Twelve years at a time.
  year,
}

/// How many years one page of the year grid holds. Four columns of three.
const int yearPageSize = 12;

/// The words a calendar draws that are not numbers.
///
/// **This is what a `locale` string is in the React package**, and it is an
/// object here because the framework has no `Intl` to ask. English is the
/// default so a picker works with no setup; an app that already depends on
/// `package:intl` builds one in three lines:
///
/// ```dart
/// PlDateNames(
///   months: List<String>.generate(12, (int i) => DateFormat.MMMM(locale).format(DateTime(2021, i + 1))),
///   monthsShort: List<String>.generate(12, (int i) => DateFormat.MMM(locale).format(DateTime(2021, i + 1))),
///   weekdays: List<String>.generate(7, (int i) => DateFormat.EEEE(locale).format(DateTime(2021, 8, i + 1))),
///   weekdaysShort: List<String>.generate(7, (int i) => DateFormat.E(locale).format(DateTime(2021, 8, i + 1))),
/// )
/// ```
///
/// Both weekday lists are **Sunday first**, whatever the week is drawn as
/// starting on: they are indexed by `DateTime.weekday % 7`, and rotating them
/// is the calendar's job rather than the caller's.
@immutable
class PlDateNames {
  /// Creates a set of names. Anything left out is English.
  ///
  /// The two month lists want twelve entries and the two weekday lists want
  /// seven. Nothing asserts it — the constructor is `const`, and a `const`
  /// expression cannot read `.length` off a parameter — so a short list is a
  /// range error at the cell that reaches past its end.
  const PlDateNames({
    this.months = _englishMonths,
    this.monthsShort = _englishMonthsShort,
    this.weekdays = _englishWeekdays,
    this.weekdaysShort = _englishWeekdaysShort,
    this.am = 'AM',
    this.pm = 'PM',
    this.monthBeforeYear = true,
    this.firstDayOfWeek = PlassWeekday.sunday,
  });

  /// English, and the default. Named so a caller can extend it with `copyWith`.
  static const PlDateNames english = PlDateNames();

  /// The twelve month names in full, January first.
  final List<String> months;

  /// The same twelve, abbreviated. What the month grid draws.
  final List<String> monthsShort;

  /// The seven weekday names in full, **Sunday first**.
  final List<String> weekdays;

  /// The same seven, abbreviated. What the day grid's column headers draw.
  ///
  /// Abbreviated rather than narrow: narrow gives `S M T W T F S` in English,
  /// where two pairs are indistinguishable. The full name goes on the header's
  /// semantics so a screen reader hears "Monday" rather than "Mon".
  final List<String> weekdaysShort;

  /// The first half of the day, for a 12-hour clock.
  final String am;

  /// And the second.
  final String pm;

  /// Whether the header writes the month before the year.
  ///
  /// `July 2026` in English and `2026년 7월` in Korean, and the header is two
  /// separate buttons rather than one string — so it cannot just print what a
  /// formatter gives it and has to be told which comes first. Getting this wrong
  /// is subtle and reads as broken to exactly the people it is wrong for.
  final bool monthBeforeYear;

  /// Which day the week starts on — Sunday in the US and Korea, Monday across
  /// most of Europe, Saturday in much of the Middle East.
  ///
  /// A picker's own `weekStartsOn` overrides it; this is the default for the
  /// language rather than for the screen.
  final PlassWeekday firstDayOfWeek;

  /// A copy with some of the names replaced.
  PlDateNames copyWith({
    List<String>? months,
    List<String>? monthsShort,
    List<String>? weekdays,
    List<String>? weekdaysShort,
    String? am,
    String? pm,
    bool? monthBeforeYear,
    PlassWeekday? firstDayOfWeek,
  }) {
    return PlDateNames(
      months: months ?? this.months,
      monthsShort: monthsShort ?? this.monthsShort,
      weekdays: weekdays ?? this.weekdays,
      weekdaysShort: weekdaysShort ?? this.weekdaysShort,
      am: am ?? this.am,
      pm: pm ?? this.pm,
      monthBeforeYear: monthBeforeYear ?? this.monthBeforeYear,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  /// The seven column headers, rotated so the first one is [start].
  List<String> weekdayRow(PlassWeekday start, {bool short = true}) {
    final source = short ? weekdaysShort : weekdays;
    final offset = start.index;

    return <String>[for (var i = 0; i < 7; i += 1) source[(offset + i) % 7]];
  }

  /// What a cell is called to a screen reader: the whole date, never the number.
  ///
  /// Deliberately not a format string. The order a language writes a date in is
  /// the one thing a template cannot carry across languages, and a caller who
  /// needs another order passes `formatValue` and says so.
  String spell(DateTime date) {
    final weekday = weekdays[date.weekday % 7];
    final month = months[date.month - 1];

    return monthBeforeYear
        ? '$weekday, $month ${date.day}, ${date.year}'
        : '${date.year} $month ${date.day} $weekday';
  }

  /// The medium form the trigger writes when no `formatValue` was given.
  String medium(DateTime date) {
    final month = monthsShort[date.month - 1];

    return monthBeforeYear ? '$month ${date.day}, ${date.year}' : '${date.year} $month ${date.day}';
  }

  static const List<String> _englishMonths = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _englishMonthsShort = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _englishWeekdays = <String>[
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> _englishWeekdaysShort = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
}

/// Every string a picker says that is not a date.
///
/// One object rather than eighteen parameters. These are a set: a caller who has
/// to translate "Previous month" has to translate "Next month" in the same
/// breath, and a widget with eighteen `*Label` parameters is a widget whose
/// signature is mostly apology.
@immutable
class PlPickerLabels {
  /// Creates a set of labels. Anything left out is English.
  const PlPickerLabels({
    this.previousMonth = 'Previous month',
    this.nextMonth = 'Next month',
    this.previousYear = 'Previous year',
    this.nextYear = 'Next year',
    this.previousYears = 'Previous years',
    this.nextYears = 'Next years',
    this.chooseMonth = 'Choose a month',
    this.chooseYear = 'Choose a year',
    this.today = 'Today',
    this.now = 'Now',
    this.clear = 'Clear',
    this.done = 'Done',
    this.hour = 'Hour',
    this.minute = 'Minute',
    this.second = 'Second',
    this.meridiem = 'AM/PM',
    this.start = 'Start',
    this.end = 'End',
  });

  /// English, and the default.
  static const PlPickerLabels english = PlPickerLabels();

  /// The calendar's steppers, in day view.
  final String previousMonth;

  /// See [previousMonth].
  final String nextMonth;

  /// The same steppers in month view, where they move by a year.
  final String previousYear;

  /// See [previousYear].
  final String nextYear;

  /// And in year view, where they move by a page of twelve.
  final String previousYears;

  /// See [previousYears].
  final String nextYears;

  /// The header button that opens the month grid.
  final String chooseMonth;

  /// And the one that opens the year grid.
  final String chooseYear;

  /// The footer's shortcut to today.
  final String today;

  /// Its shortcut to this moment.
  final String now;

  /// The action that empties the picker.
  final String clear;

  /// And the one that closes it.
  final String done;

  /// The clock's columns.
  final String hour;

  /// See [hour].
  final String minute;

  /// See [hour].
  final String second;

  /// See [hour].
  final String meridiem;

  /// Which end of a range the calendar is currently asking for.
  final String start;

  /// See [start].
  final String end;
}

/* ---------------------------------------------------------------------------
 * Construction
 * ------------------------------------------------------------------------ */

/// The same day with the clock wound back to midnight.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// The first day of the month this date is in, at midnight.
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

/// How many days a month has, leap years included.
///
/// Day `0` of the month after, which `DateTime` normalises to the last day of
/// this one — the same trick the React half uses, and the reason neither has a
/// table of month lengths or a leap-year rule to get wrong.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Today, at midnight. The one place the pickers read the clock for a *date*.
DateTime todayDate() => startOfDay(DateTime.now());

/* ---------------------------------------------------------------------------
 * Arithmetic
 * ------------------------------------------------------------------------ */

/// [amount] days later, keeping the time of day.
///
/// Built out of Y/M/D rather than by adding a [Duration], and that is not
/// fussiness: a `Duration` of 24 hours is not a day across a daylight-saving
/// boundary, and a calendar that skips or repeats a cell twice a year is a
/// calendar nobody can explain.
DateTime addDays(DateTime date, int amount) {
  return DateTime(date.year, date.month, date.day + amount, date.hour, date.minute, date.second);
}

/// [amount] months later, with the day of the month **clamped** rather than
/// allowed to overflow.
///
/// 31 January plus one month is 28 February, not 3 March. `DateTime` gives the
/// second answer on its own, which is why stepping a calendar forward from a
/// 31st without this skips February entirely.
DateTime addMonths(DateTime date, int amount) {
  final target = DateTime(date.year, date.month + amount);

  return DateTime(
    target.year,
    target.month,
    date.day < daysInMonth(target.year, target.month)
        ? date.day
        : daysInMonth(target.year, target.month),
    date.hour,
    date.minute,
    date.second,
  );
}

/// [amount] years later, through [addMonths] so the clamp comes with it.
DateTime addYears(DateTime date, int amount) => addMonths(date, amount * 12);

/* ---------------------------------------------------------------------------
 * Comparison
 *
 * All of it on the local Y/M/D triple. Two `DateTime`s that are the same
 * calendar day differ by milliseconds far more often than not — a value carrying
 * a time of day, a `min` built at noon — and every one of those comparisons has
 * to come out true.
 * ------------------------------------------------------------------------ */

/// Negative, zero or positive, the way a sort comparator wants it.
int compareDay(DateTime a, DateTime b) {
  return startOfDay(a).compareTo(startOfDay(b));
}

/// Are these the same calendar day?
bool isSameDay(DateTime? a, DateTime? b) {
  return a != null && b != null && compareDay(a, b) == 0;
}

/// Are these in the same calendar month?
bool isSameMonth(DateTime? a, DateTime? b) {
  return a != null && b != null && a.year == b.year && a.month == b.month;
}

/// Is this calendar *day* outside the allowed span?
///
/// Day-granular on purpose. A `maxDate` of 27 July at 09:00 still leaves the
/// 27th pickable — the bound is about which days exist, and the time of day is
/// the time picker's problem.
bool isDayOutside(DateTime date, DateTime? min, DateTime? max) {
  if (min != null && compareDay(date, min) < 0) {
    return true;
  }

  return max != null && compareDay(date, max) > 0;
}

/// The two ends of a band, smallest first, whichever way round they arrived.
List<DateTime>? orderedRange(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return null;
  }

  return compareDay(a, b) <= 0 ? <DateTime>[a, b] : <DateTime>[b, a];
}

/* ---------------------------------------------------------------------------
 * Time of day
 * ------------------------------------------------------------------------ */

/// Seconds since local midnight — what a time bound is compared on.
int secondsOfDay(DateTime date) => date.hour * 3600 + date.minute * 60 + date.second;

/// The same instant with one or more clock fields replaced.
DateTime withTime(DateTime date, {int? hours, int? minutes, int? seconds}) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    hours ?? date.hour,
    minutes ?? date.minute,
    seconds ?? date.second,
  );
}

/// [date]'s calendar day wearing [time]'s clock.
DateTime mergeDateAndTime(DateTime date, DateTime time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute, time.second);
}

/* ---------------------------------------------------------------------------
 * The grid
 * ------------------------------------------------------------------------ */

/// Six weeks of seven days, always — including the leading and trailing days
/// that belong to the neighbouring months.
///
/// Six rows whatever the month, and that is the whole point. A February that
/// starts on a Sunday needs four rows and a 31-day month starting on a Saturday
/// needs six; a grid that renders only the rows it needs is a grid that changes
/// height when you step a month forward, moving every cell out from under the
/// finger that just pressed one.
List<List<DateTime>> calendarWeeks(DateTime month, PlassWeekday weekStartsOn) {
  final first = startOfMonth(month);
  // `DateTime.weekday` counts Monday as 1 through Sunday as 7; the modulo turns
  // it into the Sunday-is-0 numbering `PlassWeekday` uses.
  final lead = (first.weekday % 7 - weekStartsOn.index + 7) % 7;
  final origin = addDays(first, -lead);

  return <List<DateTime>>[
    for (var week = 0; week < 6; week += 1)
      <DateTime>[for (var day = 0; day < 7; day += 1) addDays(origin, week * 7 + day)],
  ];
}

/// The first year on the page a given year falls on. 2026 becomes 2016 at 12 a
/// page.
int yearPageStart(int year) => year - ((year % yearPageSize) + yearPageSize) % yearPageSize;
