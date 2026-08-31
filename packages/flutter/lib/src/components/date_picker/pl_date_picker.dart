/// One day, chosen from a calendar.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/picker.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/date.dart' show PlDateNames, PlPickerLabels;

/// The smallest unit a [PlDatePicker] asks for.
///
/// A birthday is a day, a card's expiry is a month and a model year is a year,
/// and a control that makes someone answer a question it did not need the answer
/// to — *which* day of December 2027 does this card expire? — is a control that
/// will be answered wrongly.
enum PlDatePickerPrecision {
  /// One day, from the day grid. The calendar everyone means.
  day,

  /// One month, from the month grid. There is no day grid under it.
  month,

  /// One year, from the year grid.
  year,
}

/// The view each precision floors the calendar at.
const Map<PlDatePickerPrecision, PlassCalendarView> _precisionViews =
    <PlDatePickerPrecision, PlassCalendarView>{
      PlDatePickerPrecision.day: PlassCalendarView.day,
      PlDatePickerPrecision.month: PlassCalendarView.month,
      PlDatePickerPrecision.year: PlassCalendarView.year,
    };

/// Twenty-four instants that between them exercise everything a picker's display
/// can vary by: all twelve month names, all seven weekday names and a two-digit
/// day.
///
/// They exist to be measured, not read. A trigger is sized by its content, so
/// `Jul 1, 2026` and `Sep 28, 2026` are different widths and the field would
/// jump every time a date was chosen — with the whole row of controls beside it
/// shuffling along. Laying all of these out invisibly pins the trigger to the
/// widest thing it could ever say.
///
/// Both cycles are prime to twelve in the right way — `i % 12` walks the months
/// and `i % 7` walks the days 21…27 — so every name appears without the two
/// being multiplied out into eighty-four samples.
final List<DateTime> _displaySamples = List<DateTime>.generate(
  24,
  (int index) => DateTime(2027, index % 12 + 1, 21 + index % 7),
);

/// One day, chosen from a calendar.
///
/// ```dart
/// PlDatePicker(
///   label: const Text('Departure'),
///   placeholder: const Text('Pick a day'),
///   value: departure,
///   onChanged: (DateTime? next) => setState(() => departure = next),
/// )
/// ```
///
/// The trigger is a [PlTextField]'s shell wearing a calendar glyph, on purpose
/// and for the reason a [PlSelect]'s is: a form where the date field is a
/// different height, radius or material from the fields around it is a form that
/// looks assembled.
///
/// What the calendar is actually for is the header. A picker that only steps a
/// month at a time puts a birthday thirty years back a hundred and eighty presses
/// away, so the month name and the year are each a button that opens a grid of
/// its own — twelve months, then twelve years at a time. Any month of the year on
/// screen is two presses; any year at all is three.
///
/// [precision] stops the drilling short. A card's expiry is a month and a model
/// year is a year, and a control that makes someone answer a question it did not
/// need the answer to is a control that will be answered wrongly — so a month
/// picker's month grid is the last grid, and it has no day grid under it at all.
///
/// **There is no typing into the trigger.** Parsing a date out of free text is
/// locale-dependent in a way that cannot be done honestly without a date library,
/// and this package has no dependencies at all.
///
/// The words come from [names], which is what a `locale` string is in the React
/// build: the framework ships no `Intl`, so English is the default and an app
/// that already has `package:intl` builds a [PlDateNames] from it in three lines.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlDatePicker extends StatefulWidget {
  /// Creates a date picker.
  const PlDatePicker({
    required this.value,
    this.onChanged,
    this.precision = PlDatePickerPrecision.day,
    this.open,
    this.onOpenChanged,
    this.defaultMonth,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.weekStartsOn,
    this.names,
    this.labels,
    this.formatValue,
    this.placeholder,
    this.clearable = false,
    this.showTodayButton = true,
    this.closeOnSelect = true,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The chosen day, or `null` for none.
  final DateTime? value;

  /// Called with the day that was chosen, or `null` when the picker is emptied.
  final ValueChanged<DateTime?>? onChanged;

  /// How far down the picker goes: a day, a month or a year.
  ///
  /// The calendar opens on the grid for that unit and pressing a cell in it
  /// answers — a [PlDatePickerPrecision.month] picker never shows a day grid at
  /// all. The value is always a `DateTime`, normalised to the start of whatever
  /// was chosen: the 1st of the month, or the 1st of January.
  ///
  /// [minDate] and [maxDate] are then read at the same precision. A [minDate] of
  /// 15 July leaves July pickable on a month picker and hands back 1 July,
  /// because a bound on a control that returns a month is a bound on months.
  /// [shouldDisableDate] is day-granular and is not consulted at all.
  final PlDatePickerPrecision precision;

  /// Whether the calendar is up. Leave it out and the picker holds its own.
  final bool? open;

  /// Called when the calendar should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// Which month the calendar opens on when there is no value.
  final DateTime? defaultMonth;

  /// The earliest day that may be chosen. Day-granular — the time is ignored.
  final DateTime? minDate;

  /// The latest day that may be chosen.
  final DateTime? maxDate;

  /// Blocks individual days that are inside the range but still not available —
  /// weekends, holidays, a room that is already booked.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Which day the week starts on. Defaults to what [names] says.
  final PlassWeekday? weekStartsOn;

  /// The month and weekday names, and the order the header writes them in.
  final PlDateNames? names;

  /// The words the picker says about itself. Every one has an English default.
  final PlPickerLabels? labels;

  /// How the trigger writes the chosen day.
  ///
  /// A callback rather than React's `Intl.DateTimeFormatOptions`, for the reason
  /// [names] exists: there is no `Intl` in the framework to hand options to.
  /// Without it the value is written out of [names] at whatever [precision]
  /// asked for — the medium day, the month and year, or the bare year.
  final String Function(DateTime value)? formatValue;

  /// Shown in the trigger while nothing is chosen.
  final Widget? placeholder;

  /// Offers the × that empties the control.
  final bool clearable;

  /// Offers the shortcut to today in the footer — to this month or this year on
  /// a picker whose [precision] says so.
  final bool showTodayButton;

  /// Closes the popup as soon as a day is chosen.
  final bool closeOnSelect;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale, of the trigger and of one calendar cell alike.
  final PlassSize? size;

  /// Semantic colour role. It reaches the edge, the ring and the chosen day.
  final PlassColor? color;

  /// Horizontal padding. Never the height.
  final PlassDensity? density;

  /// Drop shadow depth of the **trigger**. `0`, like a [PlTextField].
  final PlassElevation elevation;

  /// Label above the trigger.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the picker invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// The glyph before the value. A calendar by default.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the calendar does not open.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the trigger.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlDatePicker> createState() => _PlDatePickerState();
}

class _PlDatePickerState extends State<PlDatePicker> {
  PlDateNames get _names =>
      widget.names ?? PlassTheme.defaultsOf(context).names ?? PlDateNames.english;
  PlPickerLabels get _labels =>
      widget.labels ?? PlassTheme.defaultsOf(context).labels ?? PlPickerLabels.english;

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _ownOpen = false;
  late DateTime _month = startOfMonth(widget.value ?? widget.defaultMonth ?? todayDate());

  bool get _open => widget.open ?? _ownOpen;

  PlassWeekday get _weekStart =>
      widget.weekStartsOn ?? PlassTheme.defaultsOf(context).weekStartsOn ?? _names.firstDayOfWeek;

  void _setOpen(bool next) {
    if (next && (widget.readOnly || widget.disabled || widget.onChanged == null)) {
      return;
    }

    if (next) {
      // Opening puts the calendar back on the chosen day. Without this, a picker
      // left on 2019 while browsing stays there the next time it is opened,
      // which reads as the control having forgotten its own value.
      _month = startOfMonth(widget.value ?? widget.defaultMonth ?? todayDate());
    }

    if (widget.open == null) {
      setState(() => _ownOpen = next);
    } else {
      setState(() {});
    }

    widget.onOpenChanged?.call(next);
  }

  void _select(DateTime date) {
    // The day changes; the time of day, if the value had one, does not. A picker
    // bound to a field that also carries a time should not silently reset it to
    // midnight every time the day is corrected.
    final next = widget.value != null ? mergeDateAndTime(date, widget.value!) : startOfDay(date);

    widget.onChanged?.call(next);
    setState(() => _month = startOfMonth(next));

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  String _write(DateTime date) {
    if (widget.formatValue != null) {
      return widget.formatValue!(date);
    }

    return switch (widget.precision) {
      PlDatePickerPrecision.day => _names.medium(date),
      PlDatePickerPrecision.month => _names.monthYear(date),
      PlDatePickerPrecision.year => '${date.year}',
    };
  }

  /// The footer's shortcut, which is "today" only on a picker that asks for a
  /// day. On the other two it is this month and this year, blocked by the same
  /// rule their grids grey a cell out with — `shouldDisableDate` is day-granular
  /// and has nothing to say about either.
  (DateTime, String, bool) _shortcut(DateTime now) {
    return switch (widget.precision) {
      PlDatePickerPrecision.day => (
        now,
        _labels.today,
        isDayOutside(now, widget.minDate, widget.maxDate) ||
            (widget.shouldDisableDate?.call(now) ?? false),
      ),
      PlDatePickerPrecision.month => (
        startOfMonth(now),
        _labels.thisMonth,
        isMonthOutside(now, widget.minDate, widget.maxDate),
      ),
      PlDatePickerPrecision.year => (
        startOfYear(now),
        _labels.thisYear,
        isYearOutside(now, widget.minDate, widget.maxDate),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final now = todayDate();
    final (DateTime shortcut, String shortcutLabel, bool shortcutBlocked) = _shortcut(now);
    final hasFooter = widget.showTodayButton || widget.clearable;

    return PlassPickerShell(
      variant: widget.variant,
      size: _size,
      color: _color,
      density: _density,
      elevation: widget.elevation,
      label: widget.label,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      startIcon:
          widget.startIcon ??
          PlassGlyph(PlassGlyphShape.calendar, size: controlTextLeading[_size]!.size * iconScale),
      fullWidth: widget.fullWidth,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      display: value != null
          ? Text(_write(value))
          : (widget.placeholder ?? const SizedBox.shrink()),
      semanticValue: value != null ? _write(value) : null,
      samples: <Widget>[
        for (final DateTime sample in _displaySamples) Text(_write(sample)),
        if (widget.placeholder != null) widget.placeholder!,
      ],
      empty: value == null,
      clearable: widget.clearable,
      onClear: () => widget.onChanged?.call(null),
      clearLabel: _labels.clear,
      open: _open,
      onOpenChanged: _setOpen,
      popup: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: hasFooter ? 6 : 0,
        children: <Widget>[
          PlassCalendar(
            month: _month,
            onMonthChanged: (DateTime next) => setState(() => _month = next),
            selected: <DateTime?>[value],
            onSelect: _select,
            names: _names,
            labels: _labels,
            weekStartsOn: _weekStart,
            precision: _precisionViews[widget.precision]!,
            size: _size,
            color: _color,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            shouldDisableDate: widget.shouldDisableDate,
            autofocus: true,
          ),
          if (hasFooter)
            PlassPickerFooter(
              size: _size,
              children: <Widget>[
                if (widget.clearable)
                  PlButton(
                    variant: PlassVariant.ghost,
                    size: _size,
                    color: _color,
                    density: PlassDensity.compact,
                    onPressed: () {
                      widget.onChanged?.call(null);
                      _setOpen(false);
                    },
                    child: Text(_labels.clear),
                  ),
                if (widget.showTodayButton)
                  PlButton(
                    variant: PlassVariant.ghost,
                    size: _size,
                    color: _color,
                    density: PlassDensity.compact,
                    disabled: shortcutBlocked,
                    onPressed: () => _select(shortcut),
                    child: Text(shortcutLabel),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
