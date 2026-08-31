/// A time of day, chosen from columns.
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

export 'package:plass_ui/src/internal/date.dart' show PlassTimeUnit;

/// Every hour of the clock with a two-digit minute, so the trigger can be held
/// open at the widest thing it could ever say.
final List<DateTime> _displaySamples = List<DateTime>.generate(
  24,
  (int index) => DateTime(2027, 1, 1, index, 58, 58),
);

/// A time of day, chosen from columns.
///
/// ```dart
/// PlTimePicker(
///   label: const Text('Doors'),
///   minuteStep: 15,
///   value: doors,
///   onChanged: (DateTime? next) => setState(() => doors = next),
/// )
/// ```
///
/// Columns because they are the shape that answers what a time picker is
/// actually asked: "half past nine" is two glances, and "any time at all, on the
/// hour" is a column you never touch. A clock face is prettier and needs a
/// transform to read, which this library does not have.
///
/// The bounds are checked at the granularity of the column being drawn, which is
/// the detail that separates a working time picker from a frustrating one. With
/// a [minTime] of 09:30 the hour `9` stays available — the hour *contains*
/// allowed minutes — and it is the minute column that greys out `00` through
/// `25`. The naive check compares the whole candidate instant, hides the 9
/// entirely, and makes half past nine unreachable.
///
/// The value is a [DateTime] rather than a `TimeOfDay`, because everything else
/// in this package that carries a moment is one and because a bare time has
/// nowhere to record that it crossed a daylight-saving boundary. [referenceDate]
/// is the day a bare time is written onto.
///
/// Needs an [Overlay] above it.
class PlTimePicker extends StatefulWidget {
  /// Creates a time picker.
  const PlTimePicker({
    required this.value,
    this.onChanged,
    this.open,
    this.onOpenChanged,
    this.referenceDate,
    this.minTime,
    this.maxTime,
    this.shouldDisableTime,
    this.hour12 = false,
    this.showSeconds = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.names,
    this.labels,
    this.formatValue,
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

  /// The chosen time. A [DateTime], so it carries a day as well.
  final DateTime? value;

  /// Called with the time that was chosen, or `null` when the picker is emptied.
  final ValueChanged<DateTime?>? onChanged;

  /// Whether the columns are up. Leave it out and the picker holds its own.
  final bool? open;

  /// Called when they should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// The day a chosen time is written onto while there is no value yet.
  ///
  /// Held still for as long as the picker is mounted, so a popup left open
  /// across midnight does not quietly move the value onto a new day.
  final DateTime? referenceDate;

  /// The earliest time of day that may be chosen. Only the clock is read.
  final DateTime? minTime;

  /// The latest.
  final DateTime? maxTime;

  /// Blocks individual rows, given the instant a row would produce and the
  /// column it is in — so a rule may be as coarse as "no afternoons" or as fine
  /// as one minute.
  final bool Function(DateTime value, PlassTimeUnit unit)? shouldDisableTime;

  /// A 12-hour dial with an AM/PM column.
  ///
  /// A plain `false` default rather than React's "whatever the locale does":
  /// there is no `Intl` here to ask, and the same [PlDateNames] that carries the
  /// month names carries [PlDateNames.am] and [PlDateNames.pm] for when this is
  /// on.
  final bool hour12;

  /// Adds the seconds column.
  final bool showSeconds;

  /// How far apart the rows of the hours column are.
  final int hourStep;

  /// See [hourStep].
  final int minuteStep;

  /// See [hourStep].
  final int secondStep;

  /// Where AM and PM come from.
  final PlDateNames? names;

  /// The words the picker says about itself.
  final PlPickerLabels? labels;

  /// How the trigger writes the chosen time. Without it, `H:MM` — with seconds
  /// and a meridiem when those are on.
  final String Function(DateTime value)? formatValue;

  /// Shown in the trigger while nothing is chosen.
  final Widget? placeholder;

  /// Offers the × that empties the control.
  final bool clearable;

  /// Offers the shortcut to the current time in the footer.
  final bool showNowButton;

  /// Closes the popup as soon as any column is touched.
  ///
  /// `false` by default and unlike [PlDatePicker], because a time is two answers
  /// and closing after the first would make choosing 9:30 a matter of opening
  /// the popup twice.
  final bool closeOnSelect;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale, of the trigger and of one clock row alike.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// How tightly the columns sit together. Never their height.
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

  /// The glyph before the value. A clock by default.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the columns do not open.
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
  State<PlTimePicker> createState() => _PlTimePickerState();
}

class _PlTimePickerState extends State<PlTimePicker> {
  PlDateNames get _names =>
      widget.names ?? PlassTheme.defaultsOf(context).names ?? PlDateNames.english;
  PlPickerLabels get _labels =>
      widget.labels ?? PlassTheme.defaultsOf(context).labels ?? PlPickerLabels.english;

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _ownOpen = false;

  /// Held for as long as the picker is mounted. See [PlTimePicker.referenceDate].
  late final DateTime _fallbackDay = widget.referenceDate ?? DateTime.now();

  bool get _open => widget.open ?? _ownOpen;

  DateTime get _reference => widget.referenceDate ?? _fallbackDay;

  void _setOpen(bool next) {
    if (next && (widget.readOnly || widget.disabled || widget.onChanged == null)) {
      return;
    }

    if (widget.open == null) {
      setState(() => _ownOpen = next);
    } else {
      setState(() {});
    }

    widget.onOpenChanged?.call(next);
  }

  /// Whether a row's whole span falls outside the bounds. See the class doc.
  bool _isBlocked(DateTime candidate, PlassTimeUnit unit) {
    final span = timeUnitSpan(unit, candidate);

    if (widget.minTime != null && span[1] < secondsOfDay(widget.minTime!)) {
      return true;
    }

    if (widget.maxTime != null && span[0] > secondsOfDay(widget.maxTime!)) {
      return true;
    }

    return widget.shouldDisableTime?.call(candidate, unit) ?? false;
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

    return '${widget.hour12 ? hour : hour.toString().padLeft(2, '0')}:$minute$seconds$meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final now = DateTime.now();
    final nowValue = withTime(
      _reference,
      hours: now.hour,
      minutes: now.minute,
      seconds: widget.showSeconds ? now.second : 0,
    );
    final hasFooter = widget.showNowButton || widget.clearable || !widget.closeOnSelect;

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
          PlassGlyph(PlassGlyphShape.clock, size: controlTextLeading[_size]!.size * iconScale),
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
          PlassTimeGrid(
            value: value,
            referenceDate: _reference,
            onChanged: (DateTime next) {
              widget.onChanged?.call(next);

              if (widget.closeOnSelect) {
                _setOpen(false);
              }
            },
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
            shouldDisableTime: _isBlocked,
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
                if (widget.showNowButton)
                  PlButton(
                    variant: PlassVariant.ghost,
                    size: _size,
                    color: _color,
                    density: PlassDensity.compact,
                    disabled: _isBlocked(nowValue, PlassTimeUnit.second),
                    onPressed: () {
                      widget.onChanged?.call(nowValue);
                      _setOpen(false);
                    },
                    child: Text(_labels.now),
                  ),
                // The popup stays open while the columns are being read, so there
                // has to be something to press that means "that is the one".
                if (!widget.closeOnSelect)
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
