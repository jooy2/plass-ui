/// A month, on the page rather than in a popup.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/picker.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/date.dart' show PlDateNames, PlPickerLabels;

/// The smallest unit a [PlCalendar] hands back.
///
/// The same three a [PlDatePicker] takes, and a **floor** rather than a starting
/// view: at [month] the month grid is the last grid and pressing a cell in it
/// answers, so there is no day grid under it at all.
enum PlCalendarPrecision {
  /// One day, from the day grid. The calendar everyone means.
  day,

  /// One month, from the month grid. There is no day grid under it.
  month,

  /// One year, from the year grid.
  year,
}

const Map<PlCalendarPrecision, PlassCalendarView> _views = <PlCalendarPrecision, PlassCalendarView>{
  PlCalendarPrecision.day: PlassCalendarView.day,
  PlCalendarPrecision.month: PlassCalendarView.month,
  PlCalendarPrecision.year: PlassCalendarView.year,
};

/// A month, on the page rather than in a popup.
///
/// It is the same grid a [PlDatePicker] opens — the three views, the single tab
/// stop, the arrow keys that step the month when they run off an edge — with the
/// trigger and the popup taken away. That is the whole difference and it is the
/// reason to have both: a picker is a **field** that happens to open a calendar
/// and belongs in a form beside other fields, and this is a calendar that is not
/// standing in for a field. A booking page, a dashboard's date rail and an
/// availability view all want the grid *visible*, and none of them wants a text
/// box above it.
///
/// Because it is not a field it has no label, no description and no error line —
/// put it in a [PlFieldset] if it needs one.
///
/// ```dart
/// PlCalendar(
///   value: departure,
///   onChanged: (DateTime? next) => setState(() => departure = next),
/// )
/// ```
class PlCalendar extends StatefulWidget {
  /// Creates a calendar.
  const PlCalendar({
    required this.value,
    this.onChanged,
    this.precision = PlCalendarPrecision.day,
    this.month,
    this.defaultMonth,
    this.onMonthChanged,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.weekStartsOn,
    this.names = PlDateNames.english,
    this.labels = PlPickerLabels.english,
    this.showOutsideDays = true,
    this.autofocus = false,
    this.disabled = false,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.elevation = 1,
    this.semanticLabel,
    super.key,
  });

  /// The chosen day, or `null`.
  final DateTime? value;

  /// Called with the day that was taken. A `null` [onChanged] makes it inert.
  final ValueChanged<DateTime?>? onChanged;

  /// The smallest unit it hands back, and a floor rather than a starting view.
  ///
  /// The value is normalised to the start of what was chosen — the 1st of the
  /// month, the 1st of January — never whichever day the cursor was resting on.
  final PlCalendarPrecision precision;

  /// The month on screen. Pass it with [onMonthChanged] to control it.
  final DateTime? month;

  /// The month it opens on when nothing controls it. Defaults to the value's.
  final DateTime? defaultMonth;

  /// Called when the month on screen changes.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Nothing before this day can be chosen. Read at the calendar's [precision].
  final DateTime? minDate;

  /// Nothing after it can be chosen. Read at the calendar's [precision].
  final DateTime? maxDate;

  /// Blocks individual days. Day-granular, so `month` and `year` never consult
  /// it.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Which day the week starts on. Taken from [names] when it is not given.
  final PlassWeekday? weekStartsOn;

  /// The words the calendar draws — the months, the weekdays.
  ///
  /// This is what a `locale` string is in the React build: the framework ships
  /// no `Intl`, so English is the default and an app that already has
  /// `package:intl` builds a [PlDateNames] from it in three lines.
  final PlDateNames names;

  /// The words it says about itself — the steppers, the headings.
  final PlPickerLabels labels;

  /// Draws the leading and trailing days belonging to the neighbouring months.
  final bool showOutsideDays;

  /// Takes the focus as it is inserted. Off, because a calendar in a page is not
  /// a popup — the opposite of the picker's.
  final bool autofocus;

  /// Greys the whole calendar out and takes it out of the focus order.
  ///
  /// There is no `readOnly` beside it, and that is not an omission: a read-only
  /// field still shows a value a reader can select and copy, and a calendar has
  /// nothing to copy. To block some days rather than all of them, use
  /// [shouldDisableDate].
  final bool disabled;

  /// What the sheet is made of. [PlassVariant.ghost] for a calendar already
  /// inside something that draws one.
  final PlassVariant variant;

  /// Cell, radius and type scale together. There is no `density` — padding on a
  /// grid of forty-two squares is what stops them being squares.
  final PlassSize size;

  /// The family the chosen day, the today marker and the focus ring take.
  final PlassColor color;

  /// Drop shadow depth.
  final int elevation;

  /// The name a screen reader gives the whole grid.
  final String? semanticLabel;

  @override
  State<PlCalendar> createState() => _PlCalendarState();
}

class _PlCalendarState extends State<PlCalendar> {
  late DateTime _ownMonth = startOfMonth(widget.value ?? widget.defaultMonth ?? todayDate());

  DateTime get _month => widget.month ?? _ownMonth;

  PlassWeekday get _weekStart => widget.weekStartsOn ?? widget.names.firstDayOfWeek;

  void _setMonth(DateTime next) {
    if (widget.month == null) {
      setState(() => _ownMonth = next);
    }

    widget.onMonthChanged?.call(next);
  }

  void _select(DateTime date) {
    // The day changes; the time of day, if the value had one, does not. A
    // calendar bound to something that also carries a time should not silently
    // reset it to midnight every time the day is corrected.
    final next = widget.value != null ? mergeDateAndTime(date, widget.value!) : startOfDay(date);

    widget.onChanged?.call(next);

    // The grid never navigates itself, so a day picked out of a trailing week
    // would otherwise be selected in a month that is no longer on screen.
    _setMonth(startOfMonth(next));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(PlassTokens.radius[widget.size]!);
    final inert = widget.disabled || widget.onChanged == null;

    Widget calendar = PlassCalendar(
      month: _month,
      onMonthChanged: _setMonth,
      selected: <DateTime?>[widget.value],
      onSelect: _select,
      names: widget.names,
      labels: widget.labels,
      weekStartsOn: _weekStart,
      precision: _views[widget.precision]!,
      size: widget.size,
      color: widget.color,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      shouldDisableDate: widget.shouldDisableDate,
      showOutsideDays: widget.showOutsideDays,
      autofocus: widget.autofocus && !inert,
    );

    if (widget.disabled) {
      // The design language's one use of opacity, and the reason it is allowed
      // here: the page shows *through* an unavailable control.
      calendar = ExcludeFocus(
        child: IgnorePointer(child: Opacity(opacity: 0.5, child: calendar)),
      );
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: PlassSurfaceBox(
        surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
        borderRadius: radius,
        reduceMotion: reduceMotion,
        child: Padding(padding: EdgeInsets.all(popupPadding[widget.size]!), child: calendar),
      ),
    );
  }
}
