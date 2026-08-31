/// A span between two days.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/picker.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Twenty-four days that between them exercise every month name and a two-digit
/// day, so each half of the trigger can be held open at its widest.
final List<DateTime> _displaySamples = List<DateTime>.generate(
  24,
  (int index) => DateTime(2027, index % 12 + 1, 21 + index % 7),
);

/// Two ends, either of which may be missing.
///
/// A class rather than a record or a pair of parameters. A range is **one
/// value** — it is chosen in one gesture, cleared in one gesture and validated
/// as a whole — and the two names are what stop a caller writing the end into
/// the start. Half a range is a real state: it is what the picker holds between
/// the first press and the second.
@immutable
class PlDateRange {
  /// Creates a range. Either end may be `null`.
  const PlDateRange({this.start, this.end});

  /// Nothing chosen at all.
  static const PlDateRange empty = PlDateRange();

  /// The first day of the span.
  final DateTime? start;

  /// The last. `null` between the first press and the second.
  final DateTime? end;

  /// Whether both ends are still unset.
  bool get isEmpty => start == null && end == null;

  @override
  bool operator ==(Object other) {
    return other is PlDateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'PlDateRange($start – $end)';
}

/// A named range offered as a shortcut beside the calendars.
@immutable
class PlDateRangePreset {
  /// Creates a preset. [build] is called when it is taken.
  const PlDateRangePreset({required this.label, required this.build});

  /// What the button says.
  final Widget label;

  /// The range it stands for.
  ///
  /// A callback rather than a value, and always: a preset almost always depends
  /// on today, and "the last 7 days" computed once at startup is a range that
  /// would be wrong for anyone who left the app open overnight.
  final PlDateRange Function() build;
}

/// A span between two days.
///
/// ```dart
/// PlDateRangePicker(
///   label: const Text('Stay'),
///   startPlaceholder: const Text('Check in'),
///   endPlaceholder: const Text('Check out'),
///   value: stay,
///   onChanged: (PlDateRange next) => setState(() => stay = next),
/// )
/// ```
///
/// Two months side by side, because a range that crosses a month boundary is the
/// ordinary case and a one-month picker makes it a two-step navigation problem.
/// The two panels are one calendar in two halves: the left one has no forward
/// stepper, the right one has no back stepper, and either header's month and
/// year buttons move both.
///
/// The band between the ends is drawn as the pointer moves, before the second
/// press lands. That preview is the whole affordance — without it the first
/// press has no visible consequence and the control looks broken for the second
/// or so between the two.
///
/// Everything a [PlDatePicker] says about [names], the header and the bounds
/// holds here unchanged: this is that widget with a second end.
class PlDateRangePicker extends StatefulWidget {
  /// Creates a range picker.
  const PlDateRangePicker({
    required this.value,
    this.onChanged,
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
    this.monthCount = 2,
    this.startPlaceholder,
    this.endPlaceholder,
    this.presets = const <PlDateRangePreset>[],
    this.clearable = false,
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
  }) : assert(monthCount == 1 || monthCount == 2, 'monthCount is 1 or 2'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The chosen range. Never `null` — an empty one is [PlDateRange.empty].
  final PlDateRange value;

  /// Called with the new range, always as an object.
  ///
  /// It fires twice per selection: once with only a `start` when the first press
  /// lands, and once with both ends when the second does.
  final ValueChanged<PlDateRange>? onChanged;

  /// Whether the calendars are up. Leave it out and the picker holds its own.
  final bool? open;

  /// Called when they should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// Which month the left calendar opens on when there is no value.
  final DateTime? defaultMonth;

  /// The earliest day that may be chosen. Day-granular.
  final DateTime? minDate;

  /// The latest.
  final DateTime? maxDate;

  /// Blocks individual days inside the range that are still not available.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Which day the week starts on. Defaults to what [names] says.
  final PlassWeekday? weekStartsOn;

  /// The month and weekday names, and the order the header writes them in.
  final PlDateNames? names;

  /// The words the picker says about itself.
  final PlPickerLabels? labels;

  /// How each half of the trigger writes its end.
  final String Function(DateTime value)? formatValue;

  /// How many months are on screen at once.
  final int monthCount;

  /// Shown in the leading half of the trigger while that end is unchosen.
  final Widget? startPlaceholder;

  /// And in the trailing half.
  final Widget? endPlaceholder;

  /// Shortcuts listed beside the calendars.
  final List<PlDateRangePreset> presets;

  /// Offers the × that empties both ends.
  final bool clearable;

  /// Closes the popup once both ends are chosen.
  final bool closeOnSelect;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale, of the trigger and of one calendar cell alike.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Horizontal padding. Never the height.
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

  /// The glyph before the value. A calendar by default.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the calendars do not open.
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
  State<PlDateRangePicker> createState() => _PlDateRangePickerState();
}

class _PlDateRangePickerState extends State<PlDateRangePicker> {
  PlDateNames get _names =>
      widget.names ?? PlassTheme.defaultsOf(context).names ?? PlDateNames.english;
  PlPickerLabels get _labels =>
      widget.labels ?? PlassTheme.defaultsOf(context).labels ?? PlPickerLabels.english;

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _ownOpen = false;

  /// The first of the two presses.
  ///
  /// Held here rather than in `value` so a caller is never handed a range with
  /// only one end that it did not ask for — half a selection is this widget's
  /// business, not the screen's.
  DateTime? _anchor;

  /// The day under the pointer while the range is half chosen.
  DateTime? _preview;

  late DateTime _month = startOfMonth(widget.value.start ?? widget.defaultMonth ?? todayDate());

  bool get _open => widget.open ?? _ownOpen;

  PlassWeekday get _weekStart =>
      widget.weekStartsOn ?? PlassTheme.defaultsOf(context).weekStartsOn ?? _names.firstDayOfWeek;

  void _setOpen(bool next) {
    if (next && (widget.readOnly || widget.disabled || widget.onChanged == null)) {
      return;
    }

    setState(() {
      if (next) {
        _month = startOfMonth(widget.value.start ?? widget.defaultMonth ?? todayDate());
      } else {
        // An abandoned half-selection does not survive the popup closing.
        _anchor = null;
        _preview = null;
      }

      if (widget.open == null) {
        _ownOpen = next;
      }
    });

    widget.onOpenChanged?.call(next);
  }

  void _select(DateTime date) {
    final day = startOfDay(date);
    final anchor = _anchor;

    // The first press of a new selection — either there is no anchor, or the
    // range is already complete and this press starts over.
    if (anchor == null) {
      setState(() {
        _anchor = day;
        _preview = day;
      });
      widget.onChanged?.call(PlDateRange(start: day));

      return;
    }

    // The second. Pressing backwards is not a mistake to be rejected, it is the
    // same range said in the other order.
    final ordered = orderedRange(day, anchor)!;

    setState(() {
      _anchor = null;
      _preview = null;
    });
    widget.onChanged?.call(PlDateRange(start: ordered[0], end: ordered[1]));

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  void _applyPreset(PlDateRangePreset preset) {
    final range = preset.build();

    setState(() {
      _anchor = null;
      _preview = null;

      if (range.start != null) {
        _month = startOfMonth(range.start!);
      }
    });
    widget.onChanged?.call(range);

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  String _write(DateTime date) {
    return widget.formatValue?.call(date) ?? _names.medium(date);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final start = widget.value.start;
    final end = widget.value.end;
    final glyph = controlTextLeading[_size]!.size * iconScale;

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
      startIcon: widget.startIcon ?? PlassGlyph(PlassGlyphShape.calendar, size: glyph),
      fullWidth: widget.fullWidth,
      readOnly: widget.readOnly,
      disabled: widget.disabled,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      display: _display(tokens, start, end, glyph),
      semanticValue: start == null && end == null
          ? null
          : '${start == null ? '' : _write(start)} – ${end == null ? '' : _write(end)}',
      // Both halves at once: one sizer across the pair would reserve the widest
      // of the two twice over, and the trigger would sit wider than anything it
      // can actually hold. So the samples are whole rows.
      samples: <Widget>[
        for (final DateTime sample in _displaySamples) _display(tokens, sample, sample, glyph),
        // And the empty row: a placeholder is easily longer than any date, and a
        // trigger that shrank the moment the first end was chosen is the same
        // jump from the other direction.
        if (widget.startPlaceholder != null || widget.endPlaceholder != null)
          _display(tokens, null, null, glyph),
      ],
      empty: widget.value.isEmpty,
      clearable: widget.clearable,
      onClear: () => widget.onChanged?.call(PlDateRange.empty),
      clearLabel: _labels.clear,
      open: _open,
      onOpenChanged: _setOpen,
      popup: _popup(tokens),
    );
  }

  /// The two ends with an arrow between them.
  Widget _display(PlassTokens tokens, DateTime? start, DateTime? end, double glyph) {
    Widget half(DateTime? date, Widget? placeholder) {
      if (date != null) {
        return Text(_write(date));
      }

      return DefaultTextStyle.merge(
        style: TextStyle(color: tokens.mutedFg),
        child: placeholder ?? const SizedBox.shrink(),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        Flexible(child: half(start, widget.startPlaceholder)),
        // Flipped under RTL: the arrow points from the first end to the second,
        // and which side that is depends on the reading direction.
        PlassGlyph(
          PlassGlyphShape.arrowRight,
          size: glyph,
          color: tokens.mutedFg,
          quarterTurns: Directionality.of(context) == TextDirection.rtl ? 2 : 0,
        ),
        Flexible(child: half(end, widget.endPlaceholder)),
      ],
    );
  }

  Widget _popup(PlassTokens tokens) {
    final start = widget.value.start;
    final end = widget.value.end;
    final bandStart = _anchor ?? start;
    final bandEnd = _anchor != null ? _preview : end;
    final twoUp = widget.monthCount == 2;

    // Which end the next press will fill. The trigger says the same thing with
    // its two halves, but the trigger is behind the popup while the popup is up,
    // so the footer is the only place that can say it where it will be read.
    final String? hint = _anchor != null
        ? _labels.end
        : start == null
        ? _labels.start
        : null;

    PlassCalendar calendar({
      required DateTime month,
      required ValueChanged<DateTime> onMonthChanged,
      bool showPrevious = true,
      bool showNext = true,
      bool autofocus = false,
    }) {
      return PlassCalendar(
        month: month,
        onMonthChanged: onMonthChanged,
        selected: <DateTime?>[start, end, _anchor],
        onSelect: _select,
        names: _names,
        labels: _labels,
        weekStartsOn: _weekStart,
        size: _size,
        color: _color,
        rangeStart: bandStart,
        rangeEnd: bandEnd,
        onPreviewChanged: (DateTime? date) {
          if (_anchor != null) {
            setState(() => _preview = date ?? _anchor);
          }
        },
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        shouldDisableDate: widget.shouldDisableDate,
        // With both panels showing six full weeks, the 1st of August is a
        // trailing day of the July panel *and* the first day of the August one.
        // Two cells with the same name in one popup is ambiguous to a finger and
        // outright broken to a screen reader.
        showOutsideDays: false,
        showPreviousButton: showPrevious,
        showNextButton: showNext,
        autofocus: autofocus,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        // `IntrinsicHeight`, because the hairline between the presets and
        // the calendars has no height of its own and stretches to the row —
        // and a row that stretches inside a column with nothing bounding it
        // is a row asked to be infinitely tall.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: gap[_size]!,
            children: <Widget>[
              if (widget.presets.isNotEmpty)
                // `IntrinsicWidth`, because a scroll view fills whatever cross
                // axis it is given and what it is given here is the screen: the
                // column of shortcuts is as wide as its longest one.
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: cellSize[_size]! * 8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final PlDateRangePreset preset in widget.presets)
                            PlButton(
                              variant: PlassVariant.ghost,
                              size: _size,
                              color: _color,
                              density: PlassDensity.compact,
                              onPressed: () => _applyPreset(preset),
                              child: preset.label,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.presets.isNotEmpty) const PlassPickerDivider(),
              calendar(
                month: _month,
                onMonthChanged: (DateTime next) => setState(() => _month = next),
                showNext: !twoUp,
                autofocus: true,
              ),
              if (twoUp)
                calendar(
                  month: addMonths(_month, 1),
                  // The right panel is a month ahead, so moving it means moving
                  // the pair. Both headers drive one number.
                  onMonthChanged: (DateTime next) => setState(() => _month = addMonths(next, -1)),
                  showPrevious: false,
                ),
            ],
          ),
        ),
        if (widget.clearable || hint != null)
          PlassPickerFooter(
            size: _size,
            children: <Widget>[
              if (hint != null)
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
                  ),
                ),
              if (widget.clearable)
                PlButton(
                  variant: PlassVariant.ghost,
                  size: _size,
                  color: _color,
                  density: PlassDensity.compact,
                  onPressed: () {
                    setState(() {
                      _anchor = null;
                      _preview = null;
                    });
                    widget.onChanged?.call(PlDateRange.empty);
                    _setOpen(false);
                  },
                  child: Text(_labels.clear),
                ),
            ],
          ),
      ],
    );
  }
}
