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

  /// The month and the year alone, for a picker whose `precision` stops there.
  ///
  /// `July 2026` in English and `2026 7월` in Korean — the same swap [medium]
  /// makes, because a control that asks for a month must not write it in an
  /// order the reader does not use.
  String monthYear(DateTime date) {
    final month = months[date.month - 1];

    return monthBeforeYear ? '$month ${date.year}' : '${date.year} $month';
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

/// Every word this package says on its own behalf.
///
/// There are two kinds of string in a widget library and only one of them
/// belongs here. A `PlButton`'s child, a `PlAlert`'s message and a
/// `PlIconButton`'s required `label` are the **caller's** words: they arrive in
/// whatever language the application is written in. What is in this class is the
/// other kind — the words a widget has to produce itself because nobody handed
/// it any: "Close" on a modal's ×, "Previous page" on a pagination arrow, "Skip
/// to content" on a layout's first link.
///
/// **A field is a meaning, not a widget.** "Close" is one word whether it is on
/// a modal, a drawer, a popover or a toast, so it is one field — a translator
/// who had to answer it four times would be transcribing rather than
/// translating.
///
/// The dates are deliberately absent. `DateFormat` and the platform already know
/// what July is called in more languages than this file ever will.
///
/// [PlPickerLabels] is another name for this class, kept because the pickers
/// were the first widgets that needed any of it.
@immutable
class PlassLabels {
  /// Creates a set of labels. Anything left out is English.
  const PlassLabels({
    this.close = 'Close',
    this.cancel = 'Cancel',
    this.confirm = 'Confirm',
    this.search = 'Search',
    this.selectAll = 'Select all',
    this.selectRow = 'Select row',
    this.sortedAscending = 'Sorted, smallest first',
    this.sortedDescending = 'Sorted, largest first',
    this.remove = 'Remove',
    this.dismiss = 'Dismiss',
    this.open = 'Open',
    this.previous = 'Previous',
    this.next = 'Next',
    this.reveal = 'Reveal',
    this.hide = 'Hide',
    this.increase = 'Increase',
    this.decrease = 'Decrease',
    this.preview = 'Preview',
    this.empty = 'Nothing here',
    this.breadcrumb = 'Breadcrumb',
    this.breadcrumbExpand = 'Show the hidden steps',
    this.carousel = 'Carousel',
    this.carouselPrevious = 'Previous slide',
    this.carouselNext = 'Next slide',
    this.commandPalette = 'Command palette',
    this.commandPalettePlaceholder = 'Search commands',
    this.gallery = 'Gallery',
    this.overlay = 'Overlay',
    this.pagination = 'Pagination',
    this.paginationPrevious = 'Previous page',
    this.paginationNext = 'Next page',
    this.paginationFirst = 'First page',
    this.paginationLast = 'Last page',
    this.rating = 'Rating',
    this.sidebar = 'Sidebar',
    this.sidebarClose = 'Close sidebar',
    this.sidebarResize = 'Resize sidebar',
    this.skipToContent = 'Skip to content',
    this.backToTop = 'Back to top',
    this.onThisPage = 'On this page',
    this.typing = 'Typing…',
    this.newTab = '(opens elsewhere)',
    this.transferAvailable = 'Available',
    this.transferSelected = 'Selected',
    this.transferToSelected = 'Move to selected',
    this.transferToAvailable = 'Move to available',
    this.copy = 'Copy',
    this.copied = 'Copied',
    this.copyFailed = 'Could not copy',
    this.raw = 'Raw',
    this.code = 'Code',
    this.previousMonth = 'Previous month',
    this.nextMonth = 'Next month',
    this.previousYear = 'Previous year',
    this.nextYear = 'Next year',
    this.previousYears = 'Previous years',
    this.nextYears = 'Next years',
    this.chooseMonth = 'Choose a month',
    this.chooseYear = 'Choose a year',
    this.today = 'Today',
    this.thisMonth = 'This month',
    this.thisYear = 'This year',
    this.now = 'Now',
    this.clear = 'Clear',
    this.done = 'Done',
    this.skip = 'Skip',
    this.hour = 'Hour',
    this.minute = 'Minute',
    this.second = 'Second',
    this.meridiem = 'AM/PM',
    this.start = 'Start',
    this.end = 'End',
  });

  /// English, and the default.
  static const PlassLabels english = PlassLabels();

  /// This set with a word or two replaced.
  ///
  /// What a pack is for: `ko.copyWith(start: '체크인')` keeps the
  /// translation and changes the one line this screen says differently.
  PlassLabels copyWith({
    String? close,
    String? cancel,
    String? confirm,
    String? search,
    String? selectAll,
    String? selectRow,
    String? sortedAscending,
    String? sortedDescending,
    String? remove,
    String? dismiss,
    String? open,
    String? previous,
    String? next,
    String? reveal,
    String? hide,
    String? increase,
    String? decrease,
    String? preview,
    String? empty,
    String? breadcrumb,
    String? breadcrumbExpand,
    String? carousel,
    String? carouselPrevious,
    String? carouselNext,
    String? commandPalette,
    String? commandPalettePlaceholder,
    String? gallery,
    String? overlay,
    String? pagination,
    String? paginationPrevious,
    String? paginationNext,
    String? paginationFirst,
    String? paginationLast,
    String? rating,
    String? sidebar,
    String? sidebarClose,
    String? sidebarResize,
    String? skipToContent,
    String? backToTop,
    String? onThisPage,
    String? typing,
    String? newTab,
    String? transferAvailable,
    String? transferSelected,
    String? transferToSelected,
    String? transferToAvailable,
    String? copy,
    String? copied,
    String? copyFailed,
    String? raw,
    String? code,
    String? previousMonth,
    String? nextMonth,
    String? previousYear,
    String? nextYear,
    String? previousYears,
    String? nextYears,
    String? chooseMonth,
    String? chooseYear,
    String? today,
    String? thisMonth,
    String? thisYear,
    String? now,
    String? clear,
    String? done,
    String? skip,
    String? hour,
    String? minute,
    String? second,
    String? meridiem,
    String? start,
    String? end,
  }) {
    return PlassLabels(
      close: close ?? this.close,
      cancel: cancel ?? this.cancel,
      confirm: confirm ?? this.confirm,
      search: search ?? this.search,
      selectAll: selectAll ?? this.selectAll,
      selectRow: selectRow ?? this.selectRow,
      sortedAscending: sortedAscending ?? this.sortedAscending,
      sortedDescending: sortedDescending ?? this.sortedDescending,
      remove: remove ?? this.remove,
      dismiss: dismiss ?? this.dismiss,
      open: open ?? this.open,
      previous: previous ?? this.previous,
      next: next ?? this.next,
      reveal: reveal ?? this.reveal,
      hide: hide ?? this.hide,
      increase: increase ?? this.increase,
      decrease: decrease ?? this.decrease,
      preview: preview ?? this.preview,
      empty: empty ?? this.empty,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      breadcrumbExpand: breadcrumbExpand ?? this.breadcrumbExpand,
      carousel: carousel ?? this.carousel,
      carouselPrevious: carouselPrevious ?? this.carouselPrevious,
      carouselNext: carouselNext ?? this.carouselNext,
      commandPalette: commandPalette ?? this.commandPalette,
      commandPalettePlaceholder: commandPalettePlaceholder ?? this.commandPalettePlaceholder,
      gallery: gallery ?? this.gallery,
      overlay: overlay ?? this.overlay,
      pagination: pagination ?? this.pagination,
      paginationPrevious: paginationPrevious ?? this.paginationPrevious,
      paginationNext: paginationNext ?? this.paginationNext,
      paginationFirst: paginationFirst ?? this.paginationFirst,
      paginationLast: paginationLast ?? this.paginationLast,
      rating: rating ?? this.rating,
      sidebar: sidebar ?? this.sidebar,
      sidebarClose: sidebarClose ?? this.sidebarClose,
      sidebarResize: sidebarResize ?? this.sidebarResize,
      skipToContent: skipToContent ?? this.skipToContent,
      backToTop: backToTop ?? this.backToTop,
      onThisPage: onThisPage ?? this.onThisPage,
      typing: typing ?? this.typing,
      newTab: newTab ?? this.newTab,
      transferAvailable: transferAvailable ?? this.transferAvailable,
      transferSelected: transferSelected ?? this.transferSelected,
      transferToSelected: transferToSelected ?? this.transferToSelected,
      transferToAvailable: transferToAvailable ?? this.transferToAvailable,
      copy: copy ?? this.copy,
      copied: copied ?? this.copied,
      copyFailed: copyFailed ?? this.copyFailed,
      raw: raw ?? this.raw,
      code: code ?? this.code,
      previousMonth: previousMonth ?? this.previousMonth,
      nextMonth: nextMonth ?? this.nextMonth,
      previousYear: previousYear ?? this.previousYear,
      nextYear: nextYear ?? this.nextYear,
      previousYears: previousYears ?? this.previousYears,
      nextYears: nextYears ?? this.nextYears,
      chooseMonth: chooseMonth ?? this.chooseMonth,
      chooseYear: chooseYear ?? this.chooseYear,
      today: today ?? this.today,
      thisMonth: thisMonth ?? this.thisMonth,
      thisYear: thisYear ?? this.thisYear,
      now: now ?? this.now,
      clear: clear ?? this.clear,
      done: done ?? this.done,
      skip: skip ?? this.skip,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      meridiem: meridiem ?? this.meridiem,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// The × on a modal, a drawer, a popover, a toast.
  final String close;

  /// The way out of a question that has two answers.
  final String cancel;

  /// The other one.
  final String confirm;

  /// Names a search field the caller did not name.
  final String search;

  /// Ticks everything in a list at once.
  final String selectAll;

  /// Ticks one row of a table, whose own name is the row's contents.
  final String selectRow;

  /// What a sorted column heading says it is.
  ///
  /// These two have no counterpart in the React package, and the difference is
  /// the platform rather than an oversight: a `<th aria-sort="ascending">`
  /// carries the same meaning without a word, and every screen reader speaks it
  /// in the reader's own language. Flutter's semantics have no sort direction,
  /// so the widget has to say it out loud, and a word said out loud has to be
  /// translated.
  final String sortedAscending;

  /// The other direction. See [sortedAscending].
  final String sortedDescending;

  /// Takes one thing out of a set.
  final String remove;

  /// Sends a message away without answering it.
  final String dismiss;

  /// Opens a list a field is attached to.
  final String open;

  /// A direction, on the widgets that only move one step.
  final String previous;

  /// See [previous].
  final String next;

  /// Uncovers hidden content.
  final String reveal;

  /// And re-covers it.
  final String hide;

  /// A number field's two steppers.
  final String increase;

  /// See [increase].
  final String decrease;

  /// Opens a picture over the screen.
  final String preview;

  /// What a list says when it has nothing in it.
  final String empty;

  /// The trail's own name.
  final String breadcrumb;

  /// The button that opens the steps it folded away.
  final String breadcrumbExpand;

  /// The reel's own name.
  final String carousel;

  /// Its two steppers, which move by a slide.
  final String carouselPrevious;

  /// See [carouselPrevious].
  final String carouselNext;

  /// The palette's own name.
  final String commandPalette;

  /// The placeholder in its field.
  final String commandPalettePlaceholder;

  /// The wall of pictures' own landmark.
  final String gallery;

  /// What a sheet over the whole screen is called when it has no name.
  final String overlay;

  /// The pager's own name.
  final String pagination;

  /// Its four steppers, which move by a page.
  final String paginationPrevious;

  /// See [paginationPrevious].
  final String paginationNext;

  /// See [paginationPrevious].
  final String paginationFirst;

  /// See [paginationPrevious].
  final String paginationLast;

  /// The stars' group.
  final String rating;

  /// The panel's own name.
  final String sidebar;

  /// The button that shuts it.
  final String sidebarClose;

  /// The handle that sizes it.
  final String sidebarResize;

  /// The first link on a screen, which jumps past the furniture.
  final String skipToContent;

  /// The button that goes back up a long screen.
  final String backToTop;

  /// The table of contents' own name.
  final String onThisPage;

  /// What a chat bubble says while somebody is still writing.
  final String typing;

  /// Read out after a link that leaves the screen, and never drawn.
  final String newTab;

  /// The two columns of a transfer.
  final String transferAvailable;

  /// See [transferAvailable].
  final String transferSelected;

  /// And the buttons between them.
  final String transferToSelected;

  /// See [transferToSelected].
  final String transferToAvailable;

  /// The code block's bar: the button, what it says once it has worked, and
  /// what it says when the clipboard refused.
  final String copy;

  /// See [copy].
  final String copied;

  /// See [copy].
  final String copyFailed;

  /// The toggle that drops a block's colouring.
  final String raw;

  /// What a block of code is called when it has neither a title nor a language.
  final String code;

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

  /// The same shortcut on a picker that only asks for a month or a year.
  final String thisMonth;

  /// See [thisMonth].
  final String thisYear;

  /// Its shortcut to this moment.
  final String now;

  /// The action that empties the picker.
  final String clear;

  /// And the one that closes it, or a tour.
  final String done;

  /// Leaves a sequence before the end of it.
  final String skip;

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

/// Another name for [PlassLabels], kept because the pickers were the first
/// widgets that needed any of it.
typedef PlPickerLabels = PlassLabels;

/* ---------------------------------------------------------------------------
 * Construction
 * ------------------------------------------------------------------------ */

/// The same day with the clock wound back to midnight.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// The first day of the month this date is in, at midnight.
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

/// The 1st of January of the year this date is in, at midnight.
DateTime startOfYear(DateTime date) => DateTime(date.year);

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

/// Is *every* day of this month outside the allowed span?
///
/// A month is unreachable only when nothing in it is reachable: the month a
/// `minDate` of the 15th falls in still exists, it just starts late. That is the
/// rule the month grid has always drawn, and it is also what a `month` picker
/// reads its bounds at — a bound on a control that returns a month is a bound on
/// months.
bool isMonthOutside(DateTime date, DateTime? min, DateTime? max) {
  return isDayOutside(
        DateTime(date.year, date.month, daysInMonth(date.year, date.month)),
        min,
        null,
      ) ||
      isDayOutside(DateTime(date.year, date.month), null, max);
}

/// The same question about a whole year, for a `year` picker.
bool isYearOutside(DateTime date, DateTime? min, DateTime? max) {
  return (min != null && date.year < min.year) || (max != null && date.year > max.year);
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

/// Which column of a clock a candidate time is being offered for.
enum PlassTimeUnit {
  /// The hours column.
  hour,

  /// The minutes column.
  minute,

  /// The seconds column, when it is drawn.
  second,

  /// The AM/PM column, on a 12-hour dial.
  meridiem,
}

/// The span of the day one row of one column covers, in seconds since midnight.
///
/// This is the detail that separates a working time picker from a frustrating
/// one. A bound has to be checked against the *span* a row stands for, not
/// against one instant inside it: with a `minTime` of 09:30, the hour `9` covers
/// 09:00:00–09:59:59, which overlaps what is allowed, so it stays available and
/// the minute column is where `00` through `25` grey out. Comparing the whole
/// candidate instead hides the 9 and makes half past nine unreachable.
List<int> timeUnitSpan(PlassTimeUnit unit, DateTime at) {
  final seconds = secondsOfDay(at);

  switch (unit) {
    case PlassTimeUnit.hour:
      final start = seconds ~/ 3600 * 3600;

      return <int>[start, start + 3599];
    case PlassTimeUnit.minute:
      final start = seconds ~/ 60 * 60;

      return <int>[start, start + 59];
    case PlassTimeUnit.second:
      return <int>[seconds, seconds];
    case PlassTimeUnit.meridiem:
      final start = at.hour < 12 ? 0 : 12 * 3600;

      return <int>[start, start + 12 * 3600 - 1];
  }
}

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
