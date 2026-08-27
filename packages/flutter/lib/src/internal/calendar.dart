/// The calendar grid, written once for the pickers that draw one.
///
/// It lives here for the reason `internal/button_group.dart` does: a
/// `PlDateTimePicker` is a date picker and a clock in one popup and a
/// `PlDateRangePicker` is two calendars, so several components need this and
/// none of them should have to import another. The one thing it reaches *up*
/// for is [PlButton] — the header's steppers are buttons, they are not a new
/// kind of control, and `PlPagination` already makes that argument.
///
/// The day cells are deliberately **not** buttons. A cell has states a button
/// has no vocabulary for — inside a range, at the end of a range, today,
/// belonging to the month next door — and four of them have to be told apart at
/// a glance in a grid of forty-two.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The width of one day cell.
///
/// [controlHeight] as a length: a `md` day cell is 40, which is a `md`
/// [PlButton], which is a `md` text field. A calendar dropped beside a form is
/// on the form's grid.
const Map<PlassSize, double> cellSize = <PlassSize, double>{
  PlassSize.xs: 24,
  PlassSize.sm: 32,
  PlassSize.md: 40,
  PlassSize.lg: 48,
  PlassSize.xl: 56,
};

/// The header's own step of the ladder, one below the grid's.
///
/// A day cell is the content and the header is chrome around it, so the two
/// steppers and the two disclosure buttons are drawn a size down — which is also
/// the only way the row fits inside seven cells at every step, in every language.
/// A month name is `July` in one and `септември` in the next.
const Map<PlassSize, PlassSize> headerSizeScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.md,
  PlassSize.xl: PlassSize.lg,
};

/// A cell's corner, one step *down* the radius ladder from the popup it sits in.
const Map<PlassSize, PlassSize> cellRadiusScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.md,
  PlassSize.xl: PlassSize.lg,
};

/// Where a cell sits in a run of banded days, so the band knows where to stop.
enum PlassRangeEdge {
  /// Not in a band at all, so fully rounded.
  none,

  /// The first day of the run.
  start,

  /// The last.
  end,

  /// Both, which is a run of one.
  both,

  /// Somewhere in between, so square on both sides.
  middle,
}

/// One pressable square in a grid.
///
/// The state branch is an if/else ladder rather than layered modifiers, which
/// the design language asks for by name — "chosen" beating "inside the range" is
/// not something a component may leave to paint order.
///
/// The order is the order of importance. Unavailable first — a blocked day still
/// wearing the range's tint would be advertising that it is part of a range it
/// cannot join. Then chosen, then inside the range, then today, then the days
/// belonging to the month next door.
///
/// A chosen cell is the family's **gradient**, which makes it the one filled
/// token in the popup: the sheet under it is undyed glass, so what a reader is
/// looking for in a grid of forty-two is the only coloured thing on it.
class PlassCalendarCell extends StatefulWidget {
  /// Creates a cell.
  const PlassCalendarCell({
    required this.label,
    required this.size,
    required this.color,
    required this.onPressed,
    required this.child,
    this.width,
    this.selected = false,
    this.inRange = false,
    this.rangeEdge = PlassRangeEdge.none,
    this.current = false,
    this.muted = false,
    this.disabled = false,
    this.focused = false,
    this.focusNode,
    this.onHover,
    this.onKey,
    super.key,
  });

  /// What a screen reader hears. Always the full date, never the bare number.
  final String label;

  /// The size the whole calendar is on.
  final PlassSize size;

  /// The family a chosen cell is filled with.
  final PlassColor color;

  /// Called when the cell is taken. Not called while [disabled].
  final VoidCallback onPressed;

  /// The number, or the month's or year's name.
  final Widget child;

  /// How wide it is. Square on the day grid; stretched on the other two.
  final double? width;

  /// Drawn filled: this is the day the picker holds.
  final bool selected;

  /// Between the two ends of a range, or between one end and the pointer.
  final bool inRange;

  /// Where in that run it sits, so the band knows where to round.
  final PlassRangeEdge rangeEdge;

  /// Today, this month, this year — whichever unit the grid is showing.
  final bool current;

  /// Belongs to the month next door.
  final bool muted;

  /// Blocked. Still in the grid and still in the arrow-key path.
  final bool disabled;

  /// The grid's single tab stop.
  final bool focused;

  /// The node that tab stop uses, so the grid can move focus to it.
  final FocusNode? focusNode;

  /// The pointer arrived, which is what draws a half-chosen range's preview.
  final VoidCallback? onHover;

  /// The grid's own key handling, which moves the tab stop.
  final KeyEventResult Function(KeyEvent event)? onKey;

  @override
  State<PlassCalendarCell> createState() => _PlassCalendarCellState();
}

class _PlassCalendarCellState extends State<PlassCalendarCell> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusVisible = false;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);

    final side = cellSize[widget.size]!;
    final step = PlassTokens.radius[cellRadiusScale[widget.size]!]!;
    final round = Radius.circular(step);
    const square = Radius.zero;

    final BorderRadius radius = switch (widget.rangeEdge) {
      PlassRangeEdge.start => BorderRadius.horizontal(left: round),
      PlassRangeEdge.end => BorderRadius.horizontal(right: round),
      PlassRangeEdge.middle => BorderRadius.zero,
      _ => BorderRadius.all(round),
    };

    // A run that stops where it started keeps both corners, which `both` and
    // `none` already say — spelled out so the switch above stays exhaustive.
    final BorderRadius corners = widget.rangeEdge == PlassRangeEdge.middle
        ? const BorderRadius.all(square)
        : radius;

    Color? fill;
    Gradient? gradient;
    Color ink;
    FontWeight weight = FontWeight.w400;

    if (widget.disabled) {
      ink = tokens.mutedFg;
    } else if (widget.selected) {
      gradient = family.fill;
      ink = family.onSolid;
      weight = FontWeight.w600;
    } else if (widget.inRange) {
      fill = _pressed
          ? family.softPress
          : _hovered
          ? family.softHover
          : family.soft;
      ink = tokens.fg;
    } else if (widget.current) {
      fill = _pressed
          ? family.softHover
          : _hovered
          ? family.soft
          : null;
      ink = family.accent;
      weight = FontWeight.w600;
    } else {
      fill = _pressed
          ? family.softHover
          : _hovered
          ? family.soft
          : null;
      ink = widget.muted ? tokens.mutedFg : tokens.fg;
    }

    Widget cell = AnimatedContainer(
      duration: PlassTokens.duration,
      curve: PlassTokens.ease,
      width: widget.width ?? side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, gradient: gradient, borderRadius: corners),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: ink,
          fontSize: controlText[widget.size]!,
          fontWeight: weight,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
        child: widget.child,
      ),
    );

    if (widget.current) {
      // Today's mark. A dot rather than a ring, because the ring belongs to the
      // focus indicator and two rings in one cell is a cell saying nothing. It
      // takes the cell's own ink, so it turns white the moment the cell fills.
      cell = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cell,
          PositionedDirectional(
            bottom: side * 0.14,
            child: SizedBox.square(
              dimension: side * 0.09,
              child: DecoratedBox(
                decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.disabled) {
      cell = Opacity(opacity: disabledOpacity, child: cell);
    }

    if (_focusVisible) {
      // Turned inward: a ring drawn outside a cell in a gapless grid is a ring
      // drawn on its neighbours.
      cell = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: family.ring,
          borderRadius: corners,
          offset: -focusRingWidth,
        ),
        child: cell,
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: !widget.disabled,
      label: widget.label,
      onTap: widget.disabled ? null : widget.onPressed,
      excludeSemantics: true,
      child: Focus(
        focusNode: widget.focusNode,
        // Blocked days keep their focus stop, so a reader arrowing across a
        // month does not fall into a hole at every one of them.
        canRequestFocus: true,
        // One roving tab stop per grid: the focused cell is reachable and every
        // other one is skipped, which is what stops Tab walking forty-two cells.
        skipTraversal: !widget.focused,
        onFocusChange: (bool has) {
          if (mounted) {
            setState(
              () => _focusVisible =
                  has && FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
            );
          }
        },
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            if (!widget.disabled) {
              widget.onPressed();
            }

            return KeyEventResult.handled;
          }

          return widget.onKey?.call(event) ?? KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => _hovered = true);
            widget.onHover?.call();
          },
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.disabled ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: cell,
          ),
        ),
      ),
    );
  }
}

/// One month, with a way to reach every other one.
///
/// Three views on the same footprint: the days of a month, the twelve months of
/// a year, twelve years at a time. They are deliberately the same width *and*
/// the same height — the day view is seven rows counting its header, and the
/// other two spread four rows and three rows across that same height — so
/// switching view never resizes the popup under the finger that opened it.
///
/// Arrow keys move by one cell, `Home`/`End` to the ends of the week, and
/// running off an edge steps the calendar rather than stopping. One roving tab
/// stop, so `Tab` leaves the grid instead of walking forty-two cells — the
/// pattern the ARIA date-picker practice describes, and the reason no cell is
/// ever removed from the focus order.
class PlassCalendar extends StatefulWidget {
  /// Creates a calendar.
  const PlassCalendar({
    required this.month,
    required this.onMonthChanged,
    required this.selected,
    required this.onSelect,
    required this.names,
    required this.labels,
    required this.weekStartsOn,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.rangeStart,
    this.rangeEnd,
    this.onPreviewChanged,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.showOutsideDays = true,
    this.showPreviousButton = true,
    this.showNextButton = true,
    this.autofocus = false,
    super.key,
  });

  /// The month on screen. Controlled, so two panels can be kept a month apart.
  final DateTime month;

  /// Called when the panel moves to another month.
  final ValueChanged<DateTime> onMonthChanged;

  /// The days drawn filled — one for a single picker, up to two for a range.
  final List<DateTime?> selected;

  /// Called with the day that was taken.
  final ValueChanged<DateTime> onSelect;

  /// The words the calendar draws.
  final PlDateNames names;

  /// The words it says about itself.
  final PlPickerLabels labels;

  /// Which day the week starts on.
  final PlassWeekday weekStartsOn;

  /// Height and type scale of one cell.
  final PlassSize size;

  /// The family a chosen day is filled with.
  final PlassColor color;

  /// The two ends the band is drawn between. Both `null` outside range mode.
  final DateTime? rangeStart;

  /// See [rangeStart].
  final DateTime? rangeEnd;

  /// The day under the pointer, for a range that is only half chosen.
  final ValueChanged<DateTime?>? onPreviewChanged;

  /// The earliest day that may be taken.
  final DateTime? minDate;

  /// The latest.
  final DateTime? maxDate;

  /// Blocks individual days inside the range that are still not available.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Draws the leading and trailing days that belong to the neighbouring months.
  ///
  /// On by default, because pressing the 1st of next month from this month's
  /// panel is a real shortcut. A two-month range picker turns it *off*, and not
  /// as a matter of taste: with both panels showing six full weeks, the 1st of
  /// August appears twice, and two cells with the same name in one popup is
  /// ambiguous to a finger and outright broken to a screen reader.
  final bool showOutsideDays;

  /// Whether the back stepper is drawn. A hole its size is left when it is not,
  /// so two panels side by side keep their headings on one centre line.
  final bool showPreviousButton;

  /// See [showPreviousButton].
  final bool showNextButton;

  /// Takes the focus on mount — the popup has just opened.
  final bool autofocus;

  @override
  State<PlassCalendar> createState() => _PlassCalendarState();
}

class _PlassCalendarState extends State<PlassCalendar> {
  final FocusNode _cursor = FocusNode(debugLabel: 'PlassCalendar cursor');

  PlassCalendarView _view = PlassCalendarView.day;

  /// The one cell that carries the tab stop.
  ///
  /// It starts on the chosen day, or on today when today is on screen, or on the
  /// 1st — never nowhere, because a grid whose tab stop is nowhere cannot be
  /// reached by a keyboard at all.
  late DateTime _focused = _initialFocus();

  /// Set only by the interactions that *move* the focus, so nothing yanks it out
  /// from under someone doing something else on the screen.
  bool _pendingFocus = false;

  @override
  void initState() {
    super.initState();

    if (widget.autofocus) {
      _pendingFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocus());
    }
  }

  @override
  void didUpdateWidget(PlassCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Following the month keeps the tab stop inside the grid the reader is
    // looking at: stepping a month and then pressing an arrow lands somewhere
    // sensible instead of scrolling the panel back where it came from.
    if (!isSameMonth(_focused, widget.month)) {
      _focused = startOfMonth(widget.month);
    }

    if (_pendingFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocus());
    }
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  DateTime _initialFocus() {
    for (final DateTime? date in widget.selected) {
      if (date != null && isSameMonth(date, widget.month)) {
        return startOfDay(date);
      }
    }

    return isSameMonth(todayDate(), widget.month) ? todayDate() : startOfMonth(widget.month);
  }

  void _applyFocus() {
    if (!mounted || !_pendingFocus) {
      return;
    }

    _pendingFocus = false;
    _cursor.requestFocus();
  }

  bool _isDisabled(DateTime date) {
    return isDayOutside(date, widget.minDate, widget.maxDate) ||
        (widget.shouldDisableDate?.call(date) ?? false);
  }

  /// Moves the tab stop, pulling the month along when it lands outside.
  void _moveFocus(DateTime next) {
    setState(() {
      _pendingFocus = true;
      _focused = next;
    });

    if (!isSameMonth(next, widget.month)) {
      widget.onMonthChanged(startOfMonth(next));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocus());
    }
  }

  void _step(int direction) {
    switch (_view) {
      case PlassCalendarView.day:
        widget.onMonthChanged(addMonths(widget.month, direction));
      case PlassCalendarView.month:
        widget.onMonthChanged(addYears(widget.month, direction));
      case PlassCalendarView.year:
        widget.onMonthChanged(addYears(widget.month, direction * yearPageSize));
    }
  }

  void _changeView(PlassCalendarView next) {
    setState(() {
      _pendingFocus = true;
      _view = next;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocus());
  }

  @override
  Widget build(BuildContext context) {
    final side = cellSize[widget.size]!;

    return MouseRegion(
      onExit: (_) => widget.onPreviewChanged?.call(null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: gap[widget.size]!,
        children: <Widget>[
          _header(side),
          // Seven rows of cells, whichever view is drawn into it.
          SizedBox(width: side * 7, height: side * 7, child: _grid()),
        ],
      ),
    );
  }

  Widget _header(double side) {
    final labels = widget.labels;
    final chrome = headerSizeScale[widget.size]!;
    final stepLabels = switch (_view) {
      PlassCalendarView.day => <String>[labels.previousMonth, labels.nextMonth],
      PlassCalendarView.month => <String>[labels.previousYear, labels.nextYear],
      PlassCalendarView.year => <String>[labels.previousYears, labels.nextYears],
    };

    Widget stepper(int direction, bool shown) {
      if (!shown) {
        // A hole the size of the button that is not there.
        return SizedBox(width: controlHeight[chrome]!, height: controlHeight[chrome]!);
      }

      return PlButton(
        variant: PlassVariant.ghost,
        size: chrome,
        color: widget.color,
        density: PlassDensity.compact,
        semanticLabel: stepLabels[direction == -1 ? 0 : 1],
        onPressed: () => _step(direction),
        startIcon: PlassGlyph(
          PlassGlyphShape.chevron,
          quarterTurns: direction == -1 ? 1 : 3,
          size: controlText[chrome]! * iconScale,
        ),
      );
    }

    Widget disclosure(bool open) {
      return AnimatedRotation(
        turns: open ? 0.5 : 0,
        duration: PlassTokens.duration,
        curve: PlassTokens.ease,
        child: PlassGlyph(
          PlassGlyphShape.chevron,
          size: controlText[chrome]! * iconScale,
          color: PlassTheme.of(context).mutedFg,
        ),
      );
    }

    final monthButton = PlButton(
      key: const ValueKey<String>('month'),
      variant: PlassVariant.ghost,
      size: chrome,
      color: widget.color,
      density: PlassDensity.compact,
      semanticLabel: labels.chooseMonth,
      onPressed: () => _changeView(
        _view == PlassCalendarView.month ? PlassCalendarView.day : PlassCalendarView.month,
      ),
      endIcon: disclosure(_view == PlassCalendarView.month),
      child: Text(widget.names.months[widget.month.month - 1]),
    );

    final yearButton = PlButton(
      key: const ValueKey<String>('year'),
      variant: PlassVariant.ghost,
      size: chrome,
      color: widget.color,
      density: PlassDensity.compact,
      semanticLabel: labels.chooseYear,
      onPressed: () => _changeView(
        _view == PlassCalendarView.year ? PlassCalendarView.day : PlassCalendarView.year,
      ),
      endIcon: disclosure(_view == PlassCalendarView.year),
      child: Text('${widget.month.year}'),
    );

    final page = yearPageStart(widget.month.year);

    final Widget middle = switch (_view) {
      // A range, not a control: there is nothing above a page of years to open.
      // It keeps the row's height so switching views never moves it.
      PlassCalendarView.year => SizedBox(
        height: controlHeight[chrome]!,
        child: Center(
          child: Text(
            '$page–${page + yearPageSize - 1}',
            style: TextStyle(
              color: PlassTheme.of(context).fg,
              fontSize: controlText[chrome]!,
              fontWeight: FontWeight.w600,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
      PlassCalendarView.month => yearButton,
      // Flexible on both, so a month name longer than the row — and they vary
      // wildly between languages — truncates rather than overflowing.
      PlassCalendarView.day => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: gap[chrome]!,
        children: widget.names.monthBeforeYear
            ? <Widget>[Flexible(child: monthButton), Flexible(child: yearButton)]
            : <Widget>[Flexible(child: yearButton), Flexible(child: monthButton)],
      ),
    };

    return SizedBox(
      width: side * 7,
      child: Row(
        children: <Widget>[
          stepper(-1, widget.showPreviousButton),
          Expanded(child: Center(child: middle)),
          stepper(1, widget.showNextButton),
        ],
      ),
    );
  }

  Widget _grid() {
    return switch (_view) {
      PlassCalendarView.day => _dayGrid(),
      PlassCalendarView.month => _monthGrid(),
      PlassCalendarView.year => _yearGrid(),
    };
  }

  Widget _dayGrid() {
    final tokens = PlassTheme.of(context);
    final side = cellSize[widget.size]!;
    final weeks = calendarWeeks(widget.month, widget.weekStartsOn);
    final short = widget.names.weekdayRow(widget.weekStartsOn);
    final band = orderedRange(widget.rangeStart, widget.rangeEnd);
    final now = todayDate();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (final String label in short)
              SizedBox(
                width: side,
                height: side,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: tokens.mutedFg,
                      fontSize: metaText[widget.size]!,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (final List<DateTime> week in weeks)
          Row(
            children: <Widget>[for (final DateTime date in week) _dayCell(date, band, now, side)],
          ),
      ],
    );
  }

  Widget _dayCell(DateTime date, List<DateTime>? band, DateTime now, double side) {
    final outside = !isSameMonth(date, widget.month);

    // A hole the size of a cell rather than a missing one: the grid has to keep
    // its seven columns and six rows whatever month it is on.
    if (outside && !widget.showOutsideDays) {
      return SizedBox(width: side, height: side);
    }

    final chosen = widget.selected.any((DateTime? entry) => isSameDay(entry, date));
    final within = band != null && compareDay(date, band[0]) >= 0 && compareDay(date, band[1]) <= 0;
    final atStart = within && isSameDay(date, band[0]);
    final atEnd = within && isSameDay(date, band[1]);

    return PlassCalendarCell(
      key: ValueKey<int>(date.millisecondsSinceEpoch),
      label: widget.names.spell(date),
      size: widget.size,
      color: widget.color,
      selected: chosen,
      inRange: within && !chosen,
      rangeEdge: !within
          ? PlassRangeEdge.none
          : atStart && atEnd
          ? PlassRangeEdge.both
          : atStart
          ? PlassRangeEdge.start
          : atEnd
          ? PlassRangeEdge.end
          : PlassRangeEdge.middle,
      current: isSameDay(date, now) && !chosen,
      muted: outside,
      disabled: _isDisabled(date),
      focused: isSameDay(date, _focused),
      focusNode: isSameDay(date, _focused) ? _cursor : null,
      onHover: () => widget.onPreviewChanged?.call(date),
      onPressed: () {
        setState(() => _focused = date);
        widget.onSelect(date);
      },
      onKey: (KeyEvent event) => _onDayKey(event, date),
      child: Text('${date.day}'),
    );
  }

  KeyEventResult _onDayKey(KeyEvent event, DateTime date) {
    final offsetInWeek = (date.weekday % 7 - widget.weekStartsOn.index + 7) % 7;

    final DateTime? next = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => addDays(date, -1),
      LogicalKeyboardKey.arrowRight => addDays(date, 1),
      LogicalKeyboardKey.arrowUp => addDays(date, -7),
      LogicalKeyboardKey.arrowDown => addDays(date, 7),
      LogicalKeyboardKey.home => addDays(date, -offsetInWeek),
      LogicalKeyboardKey.end => addDays(date, 6 - offsetInWeek),
      LogicalKeyboardKey.pageUp => addMonths(date, -1),
      LogicalKeyboardKey.pageDown => addMonths(date, 1),
      _ => null,
    };

    if (next == null) {
      return KeyEventResult.ignored;
    }

    _moveFocus(next);

    return KeyEventResult.handled;
  }

  Widget _monthGrid() {
    final year = widget.month.year;
    final now = DateTime.now();
    final side = cellSize[widget.size]!;

    // The rows are spread over the height the day view occupies rather than
    // stretched to fill it: the popup keeps its size across a view change, and a
    // month cell stays a cell rather than becoming a panel.
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var row = 0; row < 4; row += 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var column = 0; column < 3; column += 1)
                Builder(
                  builder: (BuildContext context) {
                    final index = row * 3 + column;
                    // A month is out of bounds only when every day in it is: the
                    // month a `minDate` falls in is still reachable, it just
                    // starts late.
                    final first = DateTime(year, index + 1);
                    final last = DateTime(year, index + 1, daysInMonth(year, index + 1));

                    return PlassCalendarCell(
                      label: '${widget.names.months[index]} $year',
                      size: widget.size,
                      color: widget.color,
                      width: side * 7 / 3 - 4,
                      selected: widget.selected.any(
                        (DateTime? entry) =>
                            entry != null && entry.year == year && entry.month == index + 1,
                      ),
                      current: now.year == year && now.month == index + 1,
                      disabled:
                          (widget.minDate != null && compareDay(last, widget.minDate!) < 0) ||
                          (widget.maxDate != null && compareDay(first, widget.maxDate!) > 0),
                      focused: index + 1 == widget.month.month,
                      focusNode: index + 1 == widget.month.month ? _cursor : null,
                      onKey: (KeyEvent event) => _onCursorKey(event, months: true),
                      onPressed: () {
                        widget.onMonthChanged(DateTime(year, index + 1));
                        _changeView(PlassCalendarView.day);
                      },
                      child: Text(widget.names.monthsShort[index]),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }

  Widget _yearGrid() {
    final page = yearPageStart(widget.month.year);
    final now = DateTime.now().year;
    final side = cellSize[widget.size]!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var row = 0; row < 3; row += 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var column = 0; column < 4; column += 1)
                Builder(
                  builder: (BuildContext context) {
                    final year = page + row * 4 + column;

                    return PlassCalendarCell(
                      label: '$year',
                      size: widget.size,
                      color: widget.color,
                      width: side * 7 / 4 - 4,
                      selected: widget.selected.any(
                        (DateTime? entry) => entry != null && entry.year == year,
                      ),
                      current: year == now,
                      disabled:
                          (widget.minDate != null && year < widget.minDate!.year) ||
                          (widget.maxDate != null && year > widget.maxDate!.year),
                      focused: year == widget.month.year,
                      focusNode: year == widget.month.year ? _cursor : null,
                      onKey: (KeyEvent event) => _onCursorKey(event, months: false),
                      onPressed: () {
                        widget.onMonthChanged(DateTime(year, widget.month.month));
                        _changeView(PlassCalendarView.month);
                      },
                      child: Text('$year'),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }

  /// In month and year view the header's own month *is* the cursor, so moving
  /// the tab stop is moving the header — arrowing right off December lands on
  /// January of the next year and the year button follows.
  KeyEventResult _onCursorKey(KeyEvent event, {required bool months}) {
    final int? step = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => -1,
      LogicalKeyboardKey.arrowRight => 1,
      LogicalKeyboardKey.arrowUp => months ? -3 : -4,
      LogicalKeyboardKey.arrowDown => months ? 3 : 4,
      _ => null,
    };

    if (step == null) {
      return KeyEventResult.ignored;
    }

    final base = startOfMonth(widget.month);

    setState(() => _pendingFocus = true);
    widget.onMonthChanged(months ? addMonths(base, step) : addYears(base, step));
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocus());

    return KeyEventResult.handled;
  }
}
