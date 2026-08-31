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
///
/// [precision] is the floor. A calendar asked for a month opens on the month
/// grid and has no day grid under it at all, and one asked for a year opens on
/// the years — because a control that makes someone answer a question it did not
/// need the answer to is a control that will be answered wrongly.
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
    this.precision = PlassCalendarView.day,
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

  /// The smallest unit this calendar hands back.
  ///
  /// [PlassCalendarView.day] is the calendar everyone means. The other two stop
  /// the drilling one and two steps short: the grid the reader lands on is the
  /// last one, so pressing a cell in it selects rather than opening the grid
  /// below. The day grid is not merely hidden — it is unreachable, which is what
  /// makes the value the picker returns honest.
  final PlassCalendarView precision;

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

  late PlassCalendarView _openedView = widget.precision;

  /// The view actually drawn, clamped so a [PlassCalendar.precision] that
  /// tightens after the calendar is already up cannot leave a day grid on screen
  /// in a month picker. The enum is declared in drill order, deepest first.
  PlassCalendarView get _view =>
      _openedView.index < widget.precision.index ? widget.precision : _openedView;

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
      _openedView = next;
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
        _view == PlassCalendarView.month ? widget.precision : PlassCalendarView.month,
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
      onPressed: () =>
          _changeView(_view == PlassCalendarView.year ? widget.precision : PlassCalendarView.year),
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
    // Keyed, so switching view builds a fresh grid rather than reusing the last
    // one's cells. Without a key the cells are matched by position and their
    // `AnimatedContainer`s tween from the old grid's cell width to the new
    // one's — and three month cells beside a year cell is wider than the panel,
    // so the first frame of that tween overflows the row it is in.
    return switch (_view) {
      PlassCalendarView.day => KeyedSubtree(key: const ValueKey<String>('day'), child: _dayGrid()),
      PlassCalendarView.month => KeyedSubtree(
        key: const ValueKey<String>('month'),
        child: _monthGrid(),
      ),
      PlassCalendarView.year => KeyedSubtree(
        key: const ValueKey<String>('year'),
        child: _yearGrid(),
      ),
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
                    final first = DateTime(year, index + 1);

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
                      // A month is out of bounds only when every day in it is:
                      // the month a `minDate` falls in is still reachable, it
                      // just starts late.
                      disabled: isMonthOutside(first, widget.minDate, widget.maxDate),
                      focused: index + 1 == widget.month.month,
                      focusNode: index + 1 == widget.month.month ? _cursor : null,
                      onKey: (KeyEvent event) => _onCursorKey(event, months: true),
                      onPressed: () {
                        widget.onMonthChanged(first);

                        // The floor. A month picker's month grid is the last
                        // one, so pressing a cell in it answers the question
                        // rather than opening the grid below.
                        if (widget.precision == PlassCalendarView.month) {
                          widget.onSelect(first);
                        } else {
                          _changeView(PlassCalendarView.day);
                        }
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
                      disabled: isYearOutside(DateTime(year), widget.minDate, widget.maxDate),
                      focused: year == widget.month.year,
                      focusNode: year == widget.month.year ? _cursor : null,
                      onKey: (KeyEvent event) => _onCursorKey(event, months: false),
                      onPressed: () {
                        final terminal = widget.precision == PlassCalendarView.year;
                        // January, not whichever month the cursor happened to be
                        // on: the value a year picker hands back has to *be* a
                        // year, and one carrying an arbitrary month is a date
                        // wearing a year's clothes.
                        final picked = DateTime(year, terminal ? 1 : widget.month.month);

                        widget.onMonthChanged(picked);

                        if (terminal) {
                          widget.onSelect(picked);
                        } else {
                          _changeView(PlassCalendarView.month);
                        }
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

/* ---------------------------------------------------------------------------
 * The clock
 * ------------------------------------------------------------------------ */

/// How wide one clock column is, as a multiple of a day cell.
const double clockColumnFactor = 1.75;

/// Hours, minutes and — when asked for — seconds, as columns you scroll rather
/// than as a dial you drag.
///
/// Columns because they are the shape that answers what a time picker is
/// actually asked: "half past nine" is two glances, and "any time at all, on the
/// hour" is a column you never touch. A clock face is prettier and needs a
/// transform to read, which this library does not put on a control.
///
/// The chosen row in each column is scrolled into view once, on open. That is
/// the only imperative work here and it is not optional: a column of sixty
/// minutes that opens at `00` while the value is `45` has hidden its own answer.
///
/// The columns are the same seven cells tall the calendar's grid is, so a
/// `PlDateTimePicker`'s popup is one rectangle rather than two of different
/// heights pushed together.
class PlassTimeGrid extends StatefulWidget {
  /// Creates the clock.
  const PlassTimeGrid({
    required this.value,
    required this.referenceDate,
    required this.onChanged,
    required this.names,
    required this.labels,
    required this.hour12,
    this.size = PlassSize.md,
    this.density = PlassDensity.standard,
    this.color = PlassColor.primary,
    this.showSeconds = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.shouldDisableTime,
    super.key,
  });

  /// The time on screen, or `null` while nothing has been chosen.
  final DateTime? value;

  /// The day the columns write into while [value] is still `null`.
  final DateTime referenceDate;

  /// Called with the instant the pressed row produces.
  final ValueChanged<DateTime> onChanged;

  /// Where AM and PM come from.
  final PlDateNames names;

  /// What the columns are called.
  final PlPickerLabels labels;

  /// A 12-hour dial with an AM/PM column.
  final bool hour12;

  /// Height and type scale of one row.
  final PlassSize size;

  /// How tightly the columns sit together. Never their height.
  final PlassDensity density;

  /// The family a chosen row is filled with.
  final PlassColor color;

  /// Adds the seconds column.
  final bool showSeconds;

  /// How far apart the rows of the hours column are.
  final int hourStep;

  /// See [hourStep].
  final int minuteStep;

  /// See [hourStep].
  final int secondStep;

  /// Blocks individual rows, given the instant a row would produce and the
  /// column it is in.
  final bool Function(DateTime value, PlassTimeUnit unit)? shouldDisableTime;

  @override
  State<PlassTimeGrid> createState() => _PlassTimeGridState();
}

class _PlassTimeGridState extends State<PlassTimeGrid> {
  final Map<PlassTimeUnit, ScrollController> _scrollers = <PlassTimeUnit, ScrollController>{
    for (final PlassTimeUnit unit in PlassTimeUnit.values) unit: ScrollController(),
  };

  @override
  void initState() {
    super.initState();
    // Once, on open. Re-running it on every change would drag a column back
    // under the finger that is scrolling it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealChosen());
  }

  @override
  void dispose() {
    for (final ScrollController controller in _scrollers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  DateTime get _base => widget.value ?? widget.referenceDate;

  /// Brings the chosen row of each column into view *inside its own column*.
  ///
  /// Computed and jumped rather than asked for with `ensureVisible`, which walks
  /// every scrollable ancestor: the popup this runs in has only just been
  /// positioned, and a scroll that reached past the column would move the screen
  /// behind it.
  void _revealChosen() {
    if (!mounted || widget.value == null) {
      return;
    }

    final rowHeight = controlHeight[widget.size]! + _rowGap;
    final viewport = cellSize[widget.size]! * 7;

    void reveal(PlassTimeUnit unit, int index) {
      final controller = _scrollers[unit]!;

      if (!controller.hasClients) {
        return;
      }

      final target = (index * rowHeight - viewport / 2 + rowHeight / 2).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );

      controller.jumpTo(target);
    }

    reveal(PlassTimeUnit.hour, _hours.indexOf(_displayHour));
    reveal(PlassTimeUnit.minute, _minutes.indexOf(_base.minute));

    if (widget.showSeconds) {
      reveal(PlassTimeUnit.second, _seconds.indexOf(_base.second));
    }
  }

  int get _displayHour => widget.hour12
      ? _base.hour % 12 == 0
            ? 12
            : _base.hour % 12
      : _base.hour;

  List<int> get _hours {
    final count = ((widget.hour12 ? 12 : 24) / widget.hourStep).ceil();
    final raw = <int>[for (var i = 0; i < count; i += 1) i * widget.hourStep];

    // 12, 1, 2 … 11 — the order a 12-hour dial is read in, not 0…11.
    return widget.hour12 ? <int>[for (final int hour in raw) hour == 0 ? 12 : hour] : raw;
  }

  List<int> get _minutes => <int>[
    for (var i = 0; i < (60 / widget.minuteStep).ceil(); i += 1) i * widget.minuteStep,
  ];

  List<int> get _seconds => <int>[
    for (var i = 0; i < (60 / widget.secondStep).ceil(); i += 1) i * widget.secondStep,
  ];

  /// The instant taking this row would produce.
  DateTime _candidate(PlassTimeUnit unit, int raw) {
    switch (unit) {
      case PlassTimeUnit.hour:
        return withTime(_base, hours: widget.hour12 ? raw % 12 + (_base.hour >= 12 ? 12 : 0) : raw);
      case PlassTimeUnit.minute:
        return withTime(_base, minutes: raw);
      case PlassTimeUnit.second:
        return withTime(_base, seconds: raw);
      case PlassTimeUnit.meridiem:
        // `raw` is 0 for the first half of the day and 1 for the second.
        return withTime(_base, hours: _base.hour % 12 + raw * 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    String pad(int value) => value.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.density == PlassDensity.compact ? 2 : 4,
      children: <Widget>[
        _column(
          PlassTimeUnit.hour,
          widget.labels.hour,
          _hours,
          (int raw) => raw == _displayHour,
          (int raw) => widget.hour12 ? '$raw' : pad(raw),
        ),
        _column(
          PlassTimeUnit.minute,
          widget.labels.minute,
          _minutes,
          (int raw) => raw == _base.minute,
          pad,
        ),
        if (widget.showSeconds)
          _column(
            PlassTimeUnit.second,
            widget.labels.second,
            _seconds,
            (int raw) => raw == _base.second,
            pad,
          ),
        if (widget.hour12)
          _column(
            PlassTimeUnit.meridiem,
            widget.labels.meridiem,
            const <int>[0, 1],
            (int raw) => (_base.hour >= 12 ? 1 : 0) == raw,
            (int raw) => raw == 0 ? widget.names.am : widget.names.pm,
          ),
        // Three unlabelled lists of numbers, to anyone reading the screen rather
        // than looking at it. This is the sentence that says what they add up to.
        ExcludeSemantics(
          excluding: widget.value == null,
          child: Semantics(
            liveRegion: true,
            label: widget.value == null ? '' : _spokenTime(),
            child: SizedBox(width: 0, height: 0, child: Container(color: tokens.surface)),
          ),
        ),
      ],
    );
  }

  /// The whole time as one sentence, out of the picker's own words.
  String _spokenTime() {
    final base = _base;
    final hour = widget.hour12
        ? base.hour % 12 == 0
              ? 12
              : base.hour % 12
        : base.hour;
    final minute = base.minute.toString().padLeft(2, '0');
    final seconds = widget.showSeconds ? ':${base.second.toString().padLeft(2, '0')}' : '';
    final meridiem = widget.hour12 ? ' ${base.hour < 12 ? widget.names.am : widget.names.pm}' : '';

    return '$hour:$minute$seconds$meridiem';
  }

  Widget _column(
    PlassTimeUnit unit,
    String name,
    List<int> rows,
    bool Function(int raw) isChosen,
    String Function(int raw) render,
  ) {
    final side = cellSize[widget.size]!;

    return Semantics(
      container: true,
      label: name,
      explicitChildNodes: true,
      child: SizedBox(
        width: side * clockColumnFactor,
        height: side * 7,
        child: SingleChildScrollView(
          controller: _scrollers[unit],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: _rowGap,
            children: <Widget>[
              for (final int raw in rows)
                Builder(
                  builder: (BuildContext context) {
                    final at = _candidate(unit, raw);
                    final chosen = widget.value != null && isChosen(raw);
                    final disabled = widget.shouldDisableTime?.call(at, unit) ?? false;

                    return PlassCalendarCell(
                      label: '${render(raw)} $name',
                      size: widget.size,
                      color: widget.color,
                      width: side * clockColumnFactor,
                      selected: chosen,
                      disabled: disabled,
                      // The clock is not a grid: `Tab` walks past the whole of
                      // it, and a column is scrolled rather than arrowed.
                      focused: false,
                      onPressed: () => widget.onChanged(at),
                      child: Text(render(raw)),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Between two rows of one column.
const double _rowGap = 2;
