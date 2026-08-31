/// A day and a time, in one popup.
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

/// Twenty-four moments that between them exercise every month name, a two-digit
/// day and every hour of the clock, so the trigger can be held open at the
/// widest thing it could ever say.
final List<DateTime> _displaySamples = List<DateTime>.generate(
  24,
  (int index) => DateTime(2027, index % 12 + 1, 21 + index % 7, index, 58),
);

/// A day and a time, in one popup.
///
/// ```dart
/// PlDateTimePicker(
///   label: const Text('Starts'),
///   minDate: DateTime.now(),
///   value: starts,
///   onChanged: (DateTime? next) => setState(() => starts = next),
/// )
/// ```
///
/// Not a date picker that grew a clock and not a time picker that grew a
/// calendar: the two panels sit side by side at exactly the same height — seven
/// rows of cells each, which is why the calendar's grid and the clock's columns
/// share the [cellSize] ladder — so the popup is one rectangle rather than two of
/// different sizes pushed together.
///
/// The bounds do more work here than anywhere else, and it is the one place this
/// parts company with [PlDatePicker]. [minDate] is read at **full precision**, so
/// a minimum of 09:30 on the 27th leaves the 27th selectable in the calendar and
/// greys out the morning in the clock. That is the behaviour a "not before now"
/// rule needs, and a day-granular check can only block the whole of today or
/// allow this morning.
///
/// Needs an [Overlay] above it.
class PlDateTimePicker extends StatefulWidget {
  /// Creates a picker.
  const PlDateTimePicker({
    required this.value,
    this.onChanged,
    this.open,
    this.onOpenChanged,
    this.defaultMonth,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.shouldDisableTime,
    this.weekStartsOn,
    this.names,
    this.labels,
    this.formatValue,
    this.hour12 = false,
    this.showSeconds = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.placeholder,
    this.clearable = false,
    this.showNowButton = true,
    this.closeOnSelect = false,
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
  }) : assert(hourStep > 0 && minuteStep > 0 && secondStep > 0, 'a step is at least one'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The chosen moment, or `null` for none.
  final DateTime? value;

  /// Called with the moment that was chosen, or `null` when it is emptied.
  final ValueChanged<DateTime?>? onChanged;

  /// Whether the panels are up. Leave it out and the picker holds its own.
  final bool? open;

  /// Called when they should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// Which month the calendar opens on when there is no value.
  final DateTime? defaultMonth;

  /// The earliest moment that may be chosen, at **full precision**.
  final DateTime? minDate;

  /// The latest, likewise.
  final DateTime? maxDate;

  /// Blocks individual days.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Blocks individual clock rows.
  final bool Function(DateTime value, PlassTimeUnit unit)? shouldDisableTime;

  /// Which day the week starts on. Defaults to what [names] says.
  final PlassWeekday? weekStartsOn;

  /// The month and weekday names, AM and PM, and the header's order.
  final PlDateNames? names;

  /// The words the picker says about itself.
  final PlPickerLabels? labels;

  /// How the trigger writes the chosen moment. Without it, the day in [names]'
  /// medium form and the time after it.
  final String Function(DateTime value)? formatValue;

  /// A 12-hour dial with an AM/PM column. See [PlTimePicker.hour12].
  final bool hour12;

  /// Adds the seconds column.
  final bool showSeconds;

  /// How far apart the rows of the hours column are.
  final int hourStep;

  /// See [hourStep].
  final int minuteStep;

  /// See [hourStep].
  final int secondStep;

  /// Shown in the trigger while nothing is chosen.
  final Widget? placeholder;

  /// Offers the × that empties the control.
  final bool clearable;

  /// Offers the shortcut to this moment in the footer.
  final bool showNowButton;

  /// Closes the popup as soon as a day is chosen.
  ///
  /// `false` here and `true` on a [PlDatePicker], because a moment is a day *and*
  /// a time and closing on the first of the two would leave the second
  /// unanswered.
  final bool closeOnSelect;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale, of the trigger and of one cell alike.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Horizontal padding, and how tightly the clock's columns sit together.
  final PlassDensity? density;

  /// Drop shadow depth of the **trigger**.
  final PlassElevation elevation;

  /// Label above the trigger.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the picker invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// The glyph before the value.
  ///
  /// A calendar by default, and not both: a control cannot say two things at
  /// once, and the date is the part a reader scans for.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the panels do not open.
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
  State<PlDateTimePicker> createState() => _PlDateTimePickerState();
}

class _PlDateTimePickerState extends State<PlDateTimePicker> {
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
      _month = startOfMonth(widget.value ?? widget.defaultMonth ?? todayDate());
    }

    if (widget.open == null) {
      setState(() => _ownOpen = next);
    } else {
      setState(() {});
    }

    widget.onOpenChanged?.call(next);
  }

  /// Blocks a clock row whose whole span falls outside the bounds.
  ///
  /// The same span test a [PlTimePicker] makes, moved onto the absolute timeline
  /// so that the check knows which day the columns are writing into.
  bool _isTimeBlocked(DateTime candidate, PlassTimeUnit unit) {
    final span = timeUnitSpan(unit, candidate);
    final midnight = startOfDay(candidate).millisecondsSinceEpoch;

    if (widget.minDate != null &&
        midnight + span[1] * 1000 < widget.minDate!.millisecondsSinceEpoch) {
      return true;
    }

    if (widget.maxDate != null &&
        midnight + span[0] * 1000 > widget.maxDate!.millisecondsSinceEpoch) {
      return true;
    }

    return widget.shouldDisableTime?.call(candidate, unit) ?? false;
  }

  void _selectDay(DateTime date) {
    // The day changes, the clock does not. A picker that reset the time to
    // midnight every time the date was corrected would make choosing a moment an
    // ordered task, and nobody reads a popup in the order it was written.
    final next = widget.value != null ? mergeDateAndTime(date, widget.value!) : startOfDay(date);

    widget.onChanged?.call(next);
    setState(() => _month = startOfMonth(next));

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  String _write(DateTime value) {
    if (widget.formatValue != null) {
      return widget.formatValue!(value);
    }

    final hour = widget.hour12
        ? value.hour % 12 == 0
              ? 12
              : value.hour % 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final seconds = widget.showSeconds ? ':${value.second.toString().padLeft(2, '0')}' : '';
    final meridiem = widget.hour12 ? ' ${value.hour < 12 ? _names.am : _names.pm}' : '';
    final clock =
        '${widget.hour12 ? hour : hour.toString().padLeft(2, '0')}:$minute$seconds$meridiem';

    return '${_names.medium(value)} $clock';
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final now = DateTime.now();
    final nowValue = withTime(now, seconds: widget.showSeconds ? now.second : 0);
    final nowBlocked =
        isDayOutside(nowValue, widget.minDate, widget.maxDate) ||
        (widget.shouldDisableDate?.call(nowValue) ?? false) ||
        _isTimeBlocked(nowValue, PlassTimeUnit.second);

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
        spacing: 6,
        children: <Widget>[
          // `IntrinsicHeight`, because the hairline between the two panels has no
          // height of its own and stretches to the row.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: gap[_size]!,
              children: <Widget>[
                PlassCalendar(
                  month: _month,
                  onMonthChanged: (DateTime next) => setState(() => _month = next),
                  selected: <DateTime?>[value],
                  onSelect: _selectDay,
                  names: _names,
                  labels: _labels,
                  weekStartsOn: _weekStart,
                  size: _size,
                  color: _color,
                  minDate: widget.minDate,
                  maxDate: widget.maxDate,
                  shouldDisableDate: widget.shouldDisableDate,
                  autofocus: true,
                ),
                const PlassPickerDivider(),
                PlassTimeGrid(
                  value: value,
                  // With no day chosen yet the clock writes onto today, and
                  // picking a day afterwards keeps whatever time was set.
                  referenceDate: value ?? todayDate(),
                  onChanged: (DateTime next) => widget.onChanged?.call(next),
                  names: _names,
                  labels: _labels,
                  hour12: widget.hour12,
                  size: _size,
                  density: _density,
                  color: _color,
                  showSeconds: widget.showSeconds,
                  hourStep: widget.hourStep,
                  minuteStep: widget.minuteStep,
                  secondStep: widget.secondStep,
                  shouldDisableTime: _isTimeBlocked,
                ),
              ],
            ),
          ),
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
              if (widget.showNowButton)
                PlButton(
                  variant: PlassVariant.ghost,
                  size: _size,
                  color: _color,
                  density: PlassDensity.compact,
                  disabled: nowBlocked,
                  onPressed: () {
                    widget.onChanged?.call(nowValue);
                    setState(() => _month = startOfMonth(nowValue));
                  },
                  child: Text(_labels.now),
                ),
              PlButton(
                size: _size,
                color: _color,
                density: PlassDensity.compact,
                onPressed: () => _setOpen(false),
                child: Text(_labels.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
